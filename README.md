# WoW 3.3.5a — Large Address Aware patch

This PowerShell script creates `Wow_LAA.exe` from **your own backup** named `Wow.exe.backup` and enables the Large Address Aware (LAA) flag in its PE header. It leaves the source file unchanged.

This repository contains no `Wow.exe`, `Wow_LAA.exe`, or game files. You need your own installation.

[Lire ce guide en français](README.fr.md).

## Usage

1. Close the game. In the game directory, make sure you have a backup from your installation named `Wow.exe.backup`.
2. Open PowerShell in this repository's directory.
3. Run the script with the path to your game directory:

   ```powershell
   .\Apply-WowLAA.ps1 -GameDirectory 'C:\Jeux\Wow 3.3.5'
   ```

The script refuses to overwrite an existing `Wow_LAA.exe`. To generate it again, move or rename that file yourself first. Check the result before changing how you normally launch the game.

If PowerShell blocks script execution, you can run this command from the repository directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Apply-WowLAA.ps1 -GameDirectory 'C:\Jeux\Wow 3.3.5'
```

## What the script does

It validates the `MZ` and `PE` signatures, checks that the file is a PE32 x86 executable, sets bit `0x0020` in the `Characteristics` field, writes a new file, and reads that field back to verify the result. This alone does not guarantee that every game crash will be fixed.

## Publishing

Publish only the PowerShell script, this documentation, and `.gitignore`. The `.gitignore` excludes common executables and backup files; always check the file list before pushing changes to GitHub.
