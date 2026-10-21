# WoW 3.3.5a — Large Address Aware patch

This PowerShell script lets you select **your own Wow.exe** in a Windows file picker, creates `Wow_LAA.exe` alongside it, and enables the Large Address Aware (LAA) flag in its PE header. It leaves the source file unchanged.

This repository contains no `Wow.exe`, `Wow_LAA.exe`, or game files. You need your own installation.

[Lire ce guide en français](README.fr.md).

## Usage

Requires Windows and Windows PowerShell 5.1 or PowerShell 7 in STA mode.

1. Close the game.
2. On GitHub, click **Code > Download ZIP**, then right-click the downloaded ZIP and select **Extract All**. Open the extracted folder containing `Apply-WowLAA.ps1`.
3. In File Explorer's address bar, type `powershell` and press Enter. Review the script, then run these two commands to unblock this downloaded file and open the file picker:

   ```powershell
   Unblock-File -LiteralPath .\Apply-WowLAA.ps1
   powershell.exe -NoProfile -STA -File .\Apply-WowLAA.ps1
   ```

4. Browse to your game folder and select `Wow.exe`. A message confirms success or explains the error. Cancel closes the picker without creating a file.

The script refuses to overwrite an existing `Wow_LAA.exe`. To generate it again, move or rename that file yourself first. After a successful patch, launch `Wow_LAA.exe` to use the patched copy. You can still launch the original `Wow.exe` as before.

### If PowerShell says the script is not digitally signed

Under the `RemoteSigned` execution policy, Windows may block an unsigned script downloaded from the Internet. The `Unblock-File` command above removes the Internet download mark from this file only; it does not change your execution policy. Only unblock a script you have reviewed and trust. Repeat this step when downloading a new copy.

If execution is still blocked, run `Get-ExecutionPolicy -List` to check the policies in effect. Unblocking a file does not satisfy an `AllSigned` policy or override an organization's policy.

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
