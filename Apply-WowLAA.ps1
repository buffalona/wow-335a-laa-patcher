param(
    # Directory containing the game backup. Change this path if needed.
    [string]$GameDirectory = 'C:\Jeux\Wow 3.3.5'
)

$source = Join-Path $GameDirectory 'Wow.exe.backup'
$target = Join-Path $GameDirectory 'Wow_LAA.exe'

# Work from a backup and refuse to overwrite an existing output file.
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Backup not found: $source"
}
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
[System.IO.File]::WriteAllBytes($target, $bytes)
$check = [System.IO.File]::ReadAllBytes($target)
$verified = [BitConverter]::ToUInt16($check, $offset)
if (($verified -band 0x0020) -eq 0) {
    throw 'LAA verification failed.'
}

Write-Host "SUCCESS: $target created and patched!" -ForegroundColor Green
