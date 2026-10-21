# WoW 3.3.5a — patch Large Address Aware

Ce script PowerShell vous permet de choisir **votre propre Wow.exe** dans une fenêtre Windows. Il crée `Wow_LAA.exe` dans le même dossier, puis active le bit Large Address Aware (LAA) de son en-tête PE. Il ne modifie pas le fichier source.

Ce dépôt ne contient ni `Wow.exe`, ni `Wow_LAA.exe`, ni fichiers du jeu. Vous devez posséder votre propre installation.

[Read this guide in English](README.md).

## Utilisation

Nécessite Windows et Windows PowerShell 5.1 ou PowerShell 7 en mode STA.

1. Fermez le jeu.
2. Sur GitHub, cliquez sur **Code > Download ZIP**, puis faites un clic droit sur le ZIP téléchargé et choisissez **Extraire tout**. Ouvrez le dossier extrait contenant `Apply-WowLAA.ps1`.
3. Dans la barre d'adresse de l'Explorateur, tapez `powershell` et appuyez sur Entrée. Lisez le script, puis lancez ces deux commandes pour débloquer ce fichier téléchargé et ouvrir la fenêtre de sélection :

   ```powershell
   Unblock-File -LiteralPath .\Apply-WowLAA.ps1
   powershell.exe -NoProfile -STA -File .\Apply-WowLAA.ps1
   ```

4. Parcourez votre dossier de jeu et sélectionnez `Wow.exe`. Une fenêtre confirme le succès ou explique l'erreur. Le bouton Annuler ferme la sélection sans créer de fichier.

Le script refuse d'écraser un `Wow_LAA.exe` déjà présent. Si vous souhaitez le régénérer, déplacez ou renommez d'abord ce fichier vous-même. Après un patch réussi, lancez `Wow_LAA.exe` pour utiliser la copie patchée. Le fichier `Wow.exe` d'origine reste utilisable.

### Si PowerShell indique que le script n'est pas signé numériquement

Avec la stratégie d'exécution `RemoteSigned`, Windows peut bloquer un script non signé téléchargé depuis Internet. La commande `Unblock-File` ci-dessus retire la marque de téléchargement uniquement de ce fichier ; elle ne change pas votre stratégie d'exécution. Débloquez uniquement un script que vous avez lu et auquel vous faites confiance. Répétez cette étape si vous téléchargez une nouvelle copie.

Si l'exécution reste bloquée, lancez `Get-ExecutionPolicy -List` pour consulter les stratégies actives. Le déblocage d'un fichier ne satisfait pas une stratégie `AllSigned` et ne remplace pas les règles d'une organisation.

### Mode ligne de commande

Pour éviter les fenêtres graphiques, indiquez un fichier ou un dossier :

```powershell
.\Apply-WowLAA.ps1 -FilePath 'D:\Games\WoW\Wow.exe'
.\Apply-WowLAA.ps1 -GameDirectory 'D:\Games\WoW'
```

`-GameDirectory` utilise `Wow.exe.backup` s'il existe (comme l'ancienne version), sinon `Wow.exe`. La fenêtre permet également de choisir votre propre fichier `.backup`. Les vérifications PE contrôlent le format de l'exécutable, pas sa version ni son authenticité : choisissez un client WoW 3.3.5a de confiance.

## Ce que fait le script

Il valide les signatures `MZ` et `PE`, vérifie que le fichier est un exécutable PE32 x86, active le bit `0x0020` dans le champ `Characteristics`, écrit un nouveau fichier et relit ce champ pour vérifier le résultat. Il ne garantit pas à lui seul la résolution de tous les plantages du jeu.

## Publication

Publiez uniquement le script PowerShell, cette documentation et `.gitignore`. Le `.gitignore` écarte les exécutables et sauvegardes courants ; contrôlez toujours la liste des fichiers avant chaque envoi sur GitHub.
