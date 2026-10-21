[CmdletBinding(DefaultParameterSetName = 'File')]
param(
    # Optional: select Wow.exe automatically from this directory.
    [Parameter(Mandatory = $true, ParameterSetName = 'Directory')]
    [ValidateNotNullOrEmpty()]
    [string]$GameDirectory,

    # Without a path, show the Windows file picker instead.
    [Parameter(ParameterSetName = 'File')]
    [ValidateNotNullOrEmpty()]
    [string]$FilePath
)

$ErrorActionPreference = 'Stop'
$useGui = -not $PSBoundParameters.ContainsKey('GameDirectory') -and
    -not $PSBoundParameters.ContainsKey('FilePath')
$guiReady = $false

try {
if ($useGui) {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        throw 'The file picker requires Windows. Use -FilePath for command-line mode.'
    }
    if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
        throw 'Start the script with powershell.exe -STA -File .\Apply-WowLAA.ps1'
    }
    Add-Type -AssemblyName System.Windows.Forms
    $guiReady = $true
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    try {
        $dialog.Title = 'Select your WoW 3.3.5a executable (Wow.exe)'
        $dialog.Filter = 'WoW executable (Wow.exe)|Wow.exe|Executable or backup (*.exe;*.backup)|*.exe;*.backup'
        $dialog.CheckFileExists = $true
        $dialog.Multiselect = $false
        $dialog.RestoreDirectory = $true
        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            Write-Host 'Selection cancelled. No file was created.'
            return
        }
        $FilePath = $dialog.FileName
    }
    finally {
        $dialog.Dispose()
    }
}
elseif ($PSCmdlet.ParameterSetName -eq 'Directory') {
    # Preserve the old backup-based command when a backup already exists.
    $FilePath = Join-Path $GameDirectory 'Wow.exe.backup'
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        $FilePath = Join-Path $GameDirectory 'Wow.exe'
    }
}

if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
    throw "Source file not found: $FilePath"
}
$source = (Resolve-Path -LiteralPath $FilePath).ProviderPath
$target = Join-Path ([System.IO.Path]::GetDirectoryName($source)) 'Wow_LAA.exe'

# Read the selected source without modifying it; create a separate output.
if (Test-Path -LiteralPath $target) {
    throw "File already exists: $target. Nothing was overwritten."
}

$bytes = [System.IO.File]::ReadAllBytes($source)

# A Windows executable starts with the MZ signature. The PE header address
# is stored at offset 0x3C; check bounds before reading it.
if ($bytes.Length -lt 256 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    throw 'Invalid MZ file.'
}
$pe = [BitConverter]::ToInt32($bytes, 0x3C)
if ($pe -lt 64 -or $pe -gt $bytes.Length - 26) {
    throw 'Invalid PE header.'
}
if ($bytes[$pe] -ne 0x50 -or $bytes[$pe + 1] -ne 0x45 -or
    $bytes[$pe + 2] -ne 0 -or $bytes[$pe + 3] -ne 0) {
    throw 'Invalid PE signature.'
}

# This script supports PE32 x86 executables only.
$machine = [BitConverter]::ToUInt16($bytes, $pe + 4)
$magic = [BitConverter]::ToUInt16($bytes, $pe + 24)
if ($machine -ne 0x014C -or $magic -ne 0x010B) {
    throw 'The file is not a PE32 x86 executable.'
}

# Characteristics is a 16-bit field 22 bytes after the start of the PE header.
# Bit 0x0020 means IMAGE_FILE_LARGE_ADDRESS_AWARE.
$offset = $pe + 22
$flags = [BitConverter]::ToUInt16($bytes, $offset)
$newFlags = [UInt16]($flags -bor 0x0020)
$flagBytes = [BitConverter]::GetBytes($newFlags)
$bytes[$offset] = $flagBytes[0]
$bytes[$offset + 1] = $flagBytes[1]

# Create a new file, then read the field again to verify the patch.
# CreateNew also prevents overwriting if another process creates the file
# after the existence check above.
$output = [System.IO.File]::Open($target, [System.IO.FileMode]::CreateNew)
try {
    $output.Write($bytes, 0, $bytes.Length)
}
finally {
    $output.Dispose()
}
$check = [System.IO.File]::ReadAllBytes($target)
$verified = [BitConverter]::ToUInt16($check, $offset)
if (($verified -band 0x0020) -eq 0) {
    throw 'LAA verification failed.'
}

Write-Host "SUCCESS: $target created and patched!" -ForegroundColor Green
if ($useGui) {
    [void][System.Windows.Forms.MessageBox]::Show(
        "Created and verified: $target`nThe original file was left unchanged.",
        'WoW LAA patcher',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information)
}
}
catch {
    if ($guiReady) {
        [void][System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message, 'WoW LAA patcher - Error',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    throw
}
