# Script para preparar las imágenes de cartas desde el repositorio GitHub
# https://github.com/mcmd/playingcards.io-spanish.playing.cards

param (
    [string]$repoPath = ".\playingcards.io-spanish.playing.cards",
    [string]$outputPath = ".\MiChinchonWeb\assets\sprites\cards"
)

# Verificar que el directorio del repositorio existe
if (-not (Test-Path $repoPath)) {
    Write-Error "El directorio del repositorio '$repoPath' no existe."
    Write-Host "Por favor, clona el repositorio primero con:"
    Write-Host "git clone https://github.com/mcmd/playingcards.io-spanish.playing.cards.git"
    exit 1
}

# Verificar que el directorio de salida existe, si no, crearlo
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    Write-Host "Creado directorio de salida: $outputPath"
}

# Crear estructura de directorios para las cartas
$barajaDir = Join-Path $outputPath "baraja-española"
$palos = @("oros", "copas", "espadas", "bastos")

# Crear directorio principal
if (-not (Test-Path $barajaDir)) {
    New-Item -ItemType Directory -Path $barajaDir -Force | Out-Null
}

# Crear directorios para cada palo
foreach ($palo in $palos) {
    $paloDir = Join-Path $barajaDir $palo
    if (-not (Test-Path $paloDir)) {
        New-Item -ItemType Directory -Path $paloDir -Force | Out-Null
    }
}

# Función para mapear nombres de cartas
function Map-CardName {
    param (
        [string]$originalName
    )
    
    # Extraer palo y valor del nombre original
    if ($originalName -match "(oros|copas|espadas|bastos)_(\w+)\.png") {
        $palo = $matches[1]
        $valorStr = $matches[2]
        
        # Mapear valor
        switch ($valorStr) {
            "as" { $valor = "1" }
            "sota" { $valor = "10" }
            "caballo" { $valor = "11" }
            "rey" { $valor = "12" }
            default { $valor = $valorStr }
        }
        
        return @{
            Palo = $palo
            Valor = $valor
            NuevoNombre = "$valor.png"
        }
    }
    elseif ($originalName -eq "dorso.png") {
        return @{
            Palo = ""
            Valor = "dorso"
            NuevoNombre = "dorso.png"
        }
    }
    
    return $null
}

# Buscar las imágenes PNG en el repositorio
$pngDir = Join-Path $repoPath "png"
if (-not (Test-Path $pngDir)) {
    Write-Error "Directorio 'png' no encontrado en el repositorio. Estructura inesperada."
    exit 1
}

$cardFiles = Get-ChildItem -Path $pngDir -Filter "*.png"

# Contadores
$copiedCount = 0
$errorCount = 0

# Copiar archivo de dorso primero si existe
$dorsoFile = $cardFiles | Where-Object { $_.Name -eq "dorso.png" }
if ($dorsoFile) {
    Copy-Item $dorsoFile.FullName -Destination (Join-Path $barajaDir "dorso.png")
    $copiedCount++
    Write-Host "Copiado: dorso.png"
}
else {
    Write-Warning "No se encontró imagen del dorso de la carta."
}

# Procesar cada archivo de carta
foreach ($file in $cardFiles) {
    if ($file.Name -eq "dorso.png") {
        continue  # Ya procesado
    }
    
    $cardInfo = Map-CardName $file.Name
    
    if ($cardInfo -eq $null) {
        Write-Warning "No se pudo interpretar el nombre del archivo: $($file.Name)"
        $errorCount++
        continue
    }
    
    # Destino de la copia
    if ($cardInfo.Palo -ne "") {
        $destinationPath = Join-Path (Join-Path $barajaDir $cardInfo.Palo) $cardInfo.NuevoNombre
        
        # Crear el directorio de destino si no existe
        $destinationDir = Split-Path $destinationPath -Parent
        if (-not (Test-Path $destinationDir)) {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }
        
        # Copiar el archivo
        Copy-Item $file.FullName -Destination $destinationPath
        $copiedCount++
        Write-Host "Copiado: $($file.Name) -> $($cardInfo.Palo)/$($cardInfo.NuevoNombre)"
    }
}

# Resumen
Write-Host "`nProceso completado."
Write-Host "Archivos copiados: $copiedCount"
if ($errorCount -gt 0) {
    Write-Host "Errores: $errorCount" -ForegroundColor Yellow
}

Write-Host "`nLas imágenes de cartas han sido preparadas en: $barajaDir"
Write-Host "Ahora puedes continuar con el desarrollo del juego Chinchón."
