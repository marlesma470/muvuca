<#
.SYNOPSIS
    Exporta todos os arquivos .py para um unico .txt com um prompt para IA.
#>

$arquivoSaida = "sistema_completo_python_para_IA.txt"
$diretorioAtual = Get-Location
$arquivosPY = Get-ChildItem -Path $diretorioAtual -Filter "*.py" -File -Recurse

if ($arquivosPY.Count -eq 0) {
    Write-Host "Nenhum arquivo .py encontrado na pasta: $diretorioAtual" -ForegroundColor Yellow
    Write-Host "Pressione qualquer tecla para sair..."
    Read-Host
    exit
}

$caminhoSaida = Join-Path -Path $diretorioAtual -ChildPath $arquivoSaida
Clear-Content -Path $caminhoSaida -ErrorAction SilentlyContinue

$promptIA = @"
PROMPT PARA IA (LEIA COM ATENCAO)

Voce e um engenheiro de software senior especialista em analise de sistemas Python.
Abaixo estao TODOS os arquivos de codigo-fonte (extensao .py) de um sistema desenvolvido em Python.
Seu objetivo e ler e COMPREENDER 100% o funcionamento do sistema, incluindo:
- Estrutura de modulos, pacotes e hierarquias
- Fluxos de dados e logica de negocios
- Dependencias entre os arquivos
- Possiveis padroes de projeto utilizados

Apos analisar integralmente o codigo, voce devera estar apto a:
1. Responder perguntas detalhadas sobre qualquer parte do sistema.
2. Sugerir melhorias, correcoes de bugs ou refatoracoes.
3. Acrescentar novas funcionalidades seguindo o mesmo estilo e arquitetura.

DIRETRIZES OBRIGATORIAS PARA RESPOSTAS COM CODIGO:
- Quando for solicitar a geracao de codigo, SEMPRE forneca o codigo completo do(s) arquivo(s) envolvidos.
- Para alteracoes que afetem multiplos arquivos, gere 100% do PRIMEIRO arquivo alterado e entao pergunte se o usuario deseja receber 100% do proximo arquivo. Nao envie varios arquivos de uma vez sem confirmacao.
- NUNCA inclua comentarios desnecessarios no codigo gerado. Apenas mantenha comentarios se forem essenciais para a compreensao de logica complexa ou para documentacao publica (docstrings). Evite comentarios obvios ou explicativos que poluam o codigo.
- Todo codigo gerado deve ser funcional, compilavel e seguir as boas praticas de Python (PEP 8).

Para isso, estude cada arquivo na ordem em que sao apresentados. Ao final, confirme que compreendeu o sistema e aguarde as solicitacoes do usuario.

Abaixo esta o conteudo completo de todos os arquivos .py do sistema.

"@

Add-Content -Path $caminhoSaida -Value $promptIA -Encoding UTF8
Add-Content -Path $caminhoSaida -Value "`n" -Encoding UTF8
Add-Content -Path $caminhoSaida -Value "========== INICIO DOS CODIGOS-FONTE ==========" -Encoding UTF8
Add-Content -Path $caminhoSaida -Value "`n" -Encoding UTF8

foreach ($arquivo in $arquivosPY) {
    # Obtém o caminho relativo a partir do diretório atual
    $caminhoRelativo = $arquivo.FullName.Substring($diretorioAtual.Path.Length + 1)
    $titulo = "`n=== ARQUIVO: $caminhoRelativo ===`n"
    $conteudo = Get-Content -Path $arquivo.FullName -Raw -Encoding UTF8
    Add-Content -Path $caminhoSaida -Value $titulo -Encoding UTF8
    Add-Content -Path $caminhoSaida -Value $conteudo -Encoding UTF8
    Add-Content -Path $caminhoSaida -Value "`n" -Encoding UTF8
}

Write-Host "`nProcesso concluido com sucesso!" -ForegroundColor Green
Write-Host "Arquivo gerado: $caminhoSaida" -ForegroundColor Cyan
$tamanhoKB = [math]::Round((Get-Item $caminhoSaida).Length / 1KB, 2)
Write-Host "Tamanho do arquivo: $tamanhoKB KB" -ForegroundColor Gray
Write-Host "`nCopie o conteudo deste arquivo e cole em uma IA (ChatGPT, Claude, Gemini, etc.)" -ForegroundColor Yellow
Read-Host "Pressione Enter para sair"