@echo off
title Extrair sistema - Automação Custódia
echo Executando extrair.ps1...
powershell -ExecutionPolicy Bypass -File "%~dp0extrair.ps1"
if %errorlevel% neq 0 (
    echo.
    echo ERRO na execucao.
    pause
)
