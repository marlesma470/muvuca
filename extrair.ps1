# ============================================================
# Extrair sistema a partir de arquivos .b64 (PowerShell)
# ============================================================

$totalParts = 1
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $baseDir

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Extraindo arquivos do sistema..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

for ($i=1; $i -le $totalParts; $i++) {
    $fname = "parte_" + $i.ToString("000") + ".b64"
    if (-not (Test-Path $fname)) {
        Write-Host "ERRO: Arquivo $fname nao encontrado." -ForegroundColor Red
        Read-Host "Pressione Enter para sair"
        exit 1
    }
}

$tempFiles = @()
for ($i=1; $i -le $totalParts; $i++) {
    $fname = "parte_" + $i.ToString("000") + ".b64"
    $outFile = "temp_$i.bin"
    Write-Host "Processando $fname -> $outFile..." -ForegroundColor Yellow
    $b64 = Get-Content -Path $fname -Raw
    try {
        $bytes = [Convert]::FromBase64String($b64)
        [System.IO.File]::WriteAllBytes($outFile, $bytes)
        $tempFiles += $outFile
    } catch {
        Write-Host "ERRO ao decodificar $fname : $_" -ForegroundColor Red
        Read-Host "Pressione Enter para sair"
        exit 1
    }
}

Write-Host "Combinando partes..." -ForegroundColor Yellow
$allBin = "todos.bin"
if (Test-Path $allBin) { Remove-Item $allBin }
$fs = [System.IO.File]::OpenWrite($allBin)
try {
    foreach ($file in $tempFiles) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $fs.Write($bytes, 0, $bytes.Length)
    }
} finally {
    $fs.Close()
    $fs.Dispose()
}

foreach ($file in $tempFiles) {
    Remove-Item $file -Force
}

Write-Host "Reconstruindo arquivos individuais..." -ForegroundColor Yellow
$reader = [System.IO.StreamReader]::new($allBin)
while (($line = $reader.ReadLine()) -ne $null) {
    if ($line -eq "") { continue }
    $parts = $line -split '\|', 2
    if ($parts.Count -ne 2) { continue }
    $path = $parts[0]
    $b64 = $parts[1]
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    try {
        $bytes = [Convert]::FromBase64String($b64)
        [System.IO.File]::WriteAllBytes($path, $bytes)
    } catch {
        Write-Host "ERRO ao criar $path : $_" -ForegroundColor Red
        Read-Host "Pressione Enter para sair"
        exit 1
    }
}
$reader.Close()

Remove-Item $allBin -Force

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  EXTRAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Todos os arquivos foram reconstruidos."
Write-Host "Execute o launcher (Launcher.exe ou executar_launcher.vbs)."
Read-Host "Pressione Enter para sair"
