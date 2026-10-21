# WoW 3.3.5a — Large Address Aware patch

This PowerShell script lets you select **your own Wow.exe** in a Windows file picker, creates `Wow_LAA.exe` alongside it, and enables the Large Address Aware (LAA) flag in its PE header. It leaves the source file unchanged.

This repository contains no `Wow.exe`, `Wow_LAA.exe`, or game files. You need your own installation.

[Lire ce guide en français](README.fr.md).

## Usage

Requires Windows and Windows PowerShell 5.1 or PowerShell 7 in STA mode.

1. Close the game.
2. Open PowerShell in this repository's directory.
3. Run the script to open the file picker:

   ```powershell
   powershell.exe -NoProfile -STA -File .\Apply-WowLAA.ps1
   ```

4. Browse to your game folder and select `Wow.exe`. A message confirms success or explains the error. Cancel closes the picker without creating a file.

The script refuses to overwrite an existing `Wow_LAA.exe`. To generate it again, move or rename that file yourself first. After a successful patch, launch `Wow_LAA.exe` to use the patched copy. You can still launch the original `Wow.exe` as before.

If PowerShell blocks script execution, you can run this command from the repository directory:

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File .\Apply-WowLAA.ps1
```

Only run scripts you have reviewed and trust. This execution-policy option applies to the launched PowerShell session.

### Command-line mode

To skip all graphical dialogs, supply a file or directory:

```powershell
.\Apply-WowLAA.ps1 -FilePath 'D:\Games\WoW\Wow.exe'
.\Apply-WowLAA.ps1 -GameDirectory 'D:\Games\WoW'
```

`-GameDirectory` uses `Wow.exe.backup` when present (compatible with the previous version); otherwise it uses `Wow.exe`. The file picker also allows selecting your own `.backup` file. PE validation checks the executable format, not the game version or authenticity: select a trusted WoW 3.3.5a client.

## What the script does

It validates the `MZ` and `PE` signatures, checks that the file is a PE32 x86 executable, sets bit `0x0020` in the `Characteristics` field, writes a new file, and reads that field back to verify the result. This alone does not guarantee that every game crash will be fixed.

## Publishing

Publish only the PowerShell script, this documentation, and `.gitignore`. The `.gitignore` excludes common executables and backup files; always check the file list before pushing changes to GitHub.
