# build-cv.ps1
# Gera curriculo.pdf a partir de curriculo.html e valida se o resultado
# continua legivel para os robos de triagem (ATS).
#
# Uso:  .\build-cv.ps1
#
# Por que este script existe: o curriculo.pdf ficou 3 meses desatualizado em
# relacao ao curriculo.html porque a exportacao era manual. Agora e um comando.

$ErrorActionPreference = "Stop"

$repo = $PSScriptRoot
$html = Join-Path $repo "curriculo.html"
$pdf  = Join-Path $repo "curriculo.pdf"

# ---------- 1. localizar um navegador ----------
$browsers = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
  "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)
$browser = $browsers | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw "Nenhum Chrome ou Edge encontrado para gerar o PDF." }
Write-Host "Navegador: $browser"

# ---------- 2. exportar ----------
# --no-pdf-header-footer e OBRIGATORIO: sem ele o Chrome carimba o caminho
# file:///... e o numero da pagina como TEXTO REAL, e o ATS le esse lixo
# misturado com a experiencia profissional.
# --user-data-dir isola o processo: sem isso o Edge pode entregar o comando
# para uma janela ja aberta em vez de executar o trabalho.
& $browser `
  --headless `
  --disable-gpu `
  --no-pdf-header-footer `
  --run-all-compositor-stages-before-draw `
  --virtual-time-budget=10000 `
  --user-data-dir="$env:TEMP\chrome-cv-profile" `
  --print-to-pdf="$pdf" `
  "file:///$($html -replace '\\','/')"

if (-not (Test-Path $pdf)) { throw "O PDF nao foi gerado." }
Write-Host "PDF gerado: $pdf"

# ---------- 3. validar (precisa de pdftotext, vem com o Git for Windows) ----------
# O pdftotext acompanha o Git for Windows, mas fica no PATH do Git Bash e nao
# no do PowerShell. Por isso procuramos no caminho conhecido tambem.
$pdftotext = (Get-Command pdftotext -ErrorAction SilentlyContinue).Source
if (-not $pdftotext) {
  $candidatos = @(
    "C:\Program Files\Git\mingw64\bin\pdftotext.exe",
    "C:\Program Files (x86)\Git\mingw64\bin\pdftotext.exe",
    "C:\Program Files\Git\usr\bin\pdftotext.exe"
  )
  $pdftotext = $candidatos | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $pdftotext) {
  Write-Warning "pdftotext nao encontrado - pulando a validacao ATS."
  exit 0
}

$texto = & $pdftotext -enc UTF-8 $pdf - | Out-String
$linhas = $texto -split "`r?`n" | Where-Object { $_.Trim() -ne "" }
$falhas = 0

function Check($nome, $ok, $detalhe) {
  if ($ok) { Write-Host "  OK   $nome" -ForegroundColor Green }
  else     { Write-Host "  FALHA $nome -> $detalhe" -ForegroundColor Red; $script:falhas++ }
}

Write-Host "`nValidacao ATS:"

# A primeira linha extraida precisa ser o nome. Se nao for, o parser registra
# o candidato com o nome errado - foi exatamente o bug do curriculo antigo,
# que era lido como "CONTATO".
Check "nome na primeira linha" `
      ($linhas[0].Trim() -eq "Rogélio Claro Fraga") `
      "primeira linha extraida: '$($linhas[0])'"

foreach ($h in @("Resumo Profissional","Habilidades Técnicas","Experiência Profissional",
                 "Projetos","Formação Acadêmica","Idiomas")) {
  Check "cabecalho '$h'" ($texto -match [regex]::Escape($h)) "nao encontrado no texto extraido"
}

Check "e-mail extraivel"   ($texto -match "[\w.%-]+@[\w.-]+\.\w{2,}") "regex de e-mail nao casou"
Check "telefone extraivel" ($texto -match "\(?\d{2}\)?\s?9?\d{4}-\d{4}") "regex de telefone nao casou"
Check "linkedin extraivel" ($texto -match "linkedin\.com/in/") "perfil do LinkedIn nao encontrado"

# Se isto aparecer, o --no-pdf-header-footer foi esquecido.
Check "sem carimbo do Chrome" (-not ($texto -match "file:///")) "o caminho file:/// vazou para dentro do PDF"

# PDF de imagem = invisivel para qualquer ATS.
Check "texto selecionavel" ($texto.Length -gt 3500) "so $($texto.Length) caracteres extraidos"

# O pdftotext termina a saida com um form feed; descontar para nao contar
# uma pagina fantasma.
$paginas = ([regex]::Matches($texto.TrimEnd([char]12, "`r", "`n"), "\f")).Count + 1
Write-Host "`n  paginas: $paginas"

if ($falhas -gt 0) { Write-Host "`n$falhas verificacao(oes) falharam." -ForegroundColor Red; exit 1 }
Write-Host "`nTudo certo - o PDF esta legivel para os robos de triagem." -ForegroundColor Green
