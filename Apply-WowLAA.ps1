param(
    # Dossier contenant la sauvegarde du jeu. Modifiez ce chemin si nécessaire.
    [string]$GameDirectory = 'C:\Jeux\Wow 3.3.5'
)

$source = Join-Path $GameDirectory 'Wow.exe.backup'
$target = Join-Path $GameDirectory 'Wow_LAA.exe'

# On travaille sur une sauvegarde et on refuse d'écraser un résultat existant.
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Sauvegarde introuvable : $source"
}
if (Test-Path -LiteralPath $target) {
    throw "Le fichier existe déjà : $target. Aucun fichier écrasé."
}

$bytes = [System.IO.File]::ReadAllBytes($source)

# Un exécutable Windows commence par la signature MZ. L'adresse de l'en-tête PE
# se trouve à l'offset 0x3C ; on vérifie les limites avant de la lire.
if ($bytes.Length -lt 256 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    throw 'Fichier MZ invalide.'
}
$pe = [BitConverter]::ToInt32($bytes, 0x3C)
if ($pe -lt 64 -or $pe -gt $bytes.Length - 26) {
    throw 'En-tête PE invalide.'
}
if ($bytes[$pe] -ne 0x50 -or $bytes[$pe + 1] -ne 0x45 -or
    $bytes[$pe + 2] -ne 0 -or $bytes[$pe + 3] -ne 0) {
    throw 'Signature PE invalide.'
}

# Le script cible uniquement les exécutables PE32 pour processeur x86.
$machine = [BitConverter]::ToUInt16($bytes, $pe + 4)
$magic = [BitConverter]::ToUInt16($bytes, $pe + 24)
if ($machine -ne 0x014C -or $magic -ne 0x010B) {
    throw "Le fichier n'est pas un exécutable PE32 x86."
}

# Characteristics est un champ de 16 bits situé 22 octets après le début PE.
# Le bit 0x0020 indique IMAGE_FILE_LARGE_ADDRESS_AWARE.
$offset = $pe + 22
$flags = [BitConverter]::ToUInt16($bytes, $offset)
$newFlags = [UInt16]($flags -bor 0x0020)
$flagBytes = [BitConverter]::GetBytes($newFlags)
$bytes[$offset] = $flagBytes[0]
$bytes[$offset + 1] = $flagBytes[1]

# On crée un nouveau fichier puis on relit le champ pour confirmer le patch.
[System.IO.File]::WriteAllBytes($target, $bytes)
$check = [System.IO.File]::ReadAllBytes($target)
$verified = [BitConverter]::ToUInt16($check, $offset)
if (($verified -band 0x0020) -eq 0) {
    throw 'Échec de la vérification LAA.'
}

Write-Host "SUCCÈS : $target créé et patché !" -ForegroundColor Green
