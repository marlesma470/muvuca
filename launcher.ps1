# ============================================================
# Launcher - Automação Custódia (execução oculta)
# ============================================================

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainPy = Join-Path $baseDir "main.py"
$logFile = Join-Path $baseDir "launcher_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile
}

Write-Log "=========================================="
Write-Log "INICIANDO LAUNCHER"
Write-Log "Diretório base: $baseDir"
Write-Log "=========================================="

# 1. Verifica main.py
if (-not (Test-Path $mainPy)) {
    Write-Log "ERRO: main.py não encontrado em $mainPy"
    exit 1
}
Write-Log "✅ main.py encontrado."

# 2. Detecta Python portátil
$pythonCmd = $null
$pythonPortatil = Join-Path $baseDir "python-portable\python.exe"
if (Test-Path $pythonPortatil) {
    $pythonCmd = $pythonPortatil
    Write-Log "✅ Usando Python portátil (python.exe): $pythonCmd"
} else {
    $pythonPortatilAlt = Join-Path $baseDir "PythonPortatil\python.exe"
    if (Test-Path $pythonPortatilAlt) {
        $pythonCmd = $pythonPortatilAlt
        Write-Log "✅ Usando Python portátil (PythonPortatil): $pythonCmd"
    } else {
        if (Get-Command py -ErrorAction SilentlyContinue) {
            $pythonCmd = "py"
            Write-Log "✅ Usando Python do sistema (py)"
        } elseif (Get-Command python -ErrorAction SilentlyContinue) {
            $pythonCmd = "python"
            Write-Log "✅ Usando Python do sistema (python)"
        } else {
            Write-Log "ERRO: Python não encontrado."
            exit 1
        }
    }
}

Write-Log "Comando Python final: $pythonCmd"

# 3. Verifica se o Python funciona
$pythonVersion = & $pythonCmd --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "ERRO: Python não responde: $pythonVersion"
    exit 1
}
Write-Log "✅ Python versão: $pythonVersion"

# 4. Verifica PySide6 (apenas se for portátil)
if ($pythonCmd -match "python\.exe$") {
    $pysideCheck = & $pythonCmd -c "import PySide6" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✅ PySide6 já está instalado."
    } else {
        Write-Log "⚠️ PySide6 não encontrado. Tentando instalar..."
        $reqFile = Join-Path $baseDir "requirements.txt"
        if (Test-Path $reqFile) {
            Write-Log "Instalando dependências..."
            $pipInstall = & $pythonCmd -m pip install -r $reqFile 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✅ Dependências instaladas com sucesso."
            } else {
                Write-Log "❌ Falha ao instalar dependências."
                Write-Log "Saída: $pipInstall"
            }
        } else {
            Write-Log "requirements.txt não encontrado."
        }
    }
}

# 5. Executa o sistema (sem janela de terminal)
Write-Log "Executando sistema (oculto): $pythonCmd $mainPy"

# Tenta usar pythonw.exe se disponível (não abre console)
$pythonw = $null
if ($pythonCmd -match "python\.exe$") {
    $pythonw = $pythonCmd -replace "python\.exe$", "pythonw.exe"
    if (Test-Path $pythonw) {
        Write-Log "✅ Usando pythonw.exe (sem console)"
        $execCmd = $pythonw
    } else {
        $execCmd = $pythonCmd
        Write-Log "⚠️ pythonw.exe não encontrado, usando python.exe (pode abrir console)"
    }
} else {
    $execCmd = $pythonCmd
}

# Inicia o processo em modo oculto
$process = Start-Process -FilePath $execCmd -ArgumentList "`"$mainPy`"" -WorkingDirectory $baseDir -PassThru -WindowStyle Hidden

if ($process) {
    Write-Log "Processo iniciado (PID: $($process.Id))"
    Start-Sleep -Seconds 2
    if ($process.HasExited) {
        Write-Log "⚠️ Processo já terminou com código: $($process.ExitCode)"
        $errorOutput = & $execCmd "`"$mainPy`"" 2>&1
        Write-Log "Erro: $errorOutput"
    } else {
        Write-Log "✅ Processo em execução (PID: $($process.Id))"
    }
} else {
    Write-Log "ERRO: Não foi possível iniciar o processo."
}

Write-Log "=========================================="