# WoW 3.3.5a — patch Large Address Aware

Petit script PowerShell qui crée `Wow_LAA.exe` à partir de **votre propre sauvegarde** `Wow.exe.backup`, puis active le bit Large Address Aware (LAA) de son en-tête PE. Il ne modifie pas le fichier source.

Ce dépôt ne contient ni `Wow.exe`, ni `Wow_LAA.exe`, ni fichiers du jeu. Vous devez posséder votre propre installation.

[Read this guide in English](README.md).

## Utilisation

1. Fermez le jeu. Dans son dossier, assurez-vous d'avoir une sauvegarde nommée `Wow.exe.backup` provenant de votre installation.
2. Ouvrez PowerShell dans le dossier de ce dépôt.
3. Lancez le script avec le chemin de votre dossier de jeu :

   ```powershell
   .\Apply-WowLAA.ps1 -GameDirectory 'C:\Jeux\Wow 3.3.5'
   ```

Le script refuse d'écraser un `Wow_LAA.exe` déjà présent. Si vous souhaitez le régénérer, déplacez ou renommez d'abord ce fichier vous-même. Vérifiez le résultat avant de remplacer votre manière habituelle de lancer le jeu.

Si PowerShell bloque l'exécution, vous pouvez lancer cette commande depuis le dossier du dépôt :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Apply-WowLAA.ps1 -GameDirectory 'C:\Jeux\Wow 3.3.5'
```

## Ce que fait le script

Il valide les signatures `MZ` et `PE`, vérifie que le fichier est un exécutable PE32 x86, active le bit `0x0020` dans le champ `Characteristics`, écrit un nouveau fichier et relit ce champ pour vérifier le résultat. Il ne garantit pas à lui seul la résolution de tous les plantages du jeu.

## Publication

Publiez uniquement le script PowerShell, cette documentation et `.gitignore`. Le `.gitignore` écarte les exécutables et sauvegardes courants ; contrôlez toujours la liste des fichiers avant chaque envoi sur GitHub.
