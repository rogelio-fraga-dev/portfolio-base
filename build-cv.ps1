# build-cv.ps1
# Gera o PDF do curriculo a partir do HTML e valida se o resultado continua
# legivel para os robos de triagem (ATS).
#
# Uso:  .\build-cv.ps1            # curriculo.html  -> curriculo.pdf   (portugues)
#       .\build-cv.ps1 -Idioma en # en/resume.html  -> en/resume.pdf   (ingles)
#       .\build-cv.ps1 -Idioma todos
#
# Por que este script existe: o curriculo.pdf ficou 3 meses desatualizado em
# relacao ao curriculo.html porque a exportacao era manual. Agora e um comando.

param(
  [ValidateSet("pt", "en", "todos")]
  [string]$Idioma = "pt"
)

$ErrorActionPreference = "Stop"

$repo = $PSScriptRoot

# Cada idioma tem o seu HTML, o seu PDF e os seus cabecalhos esperados no texto
# extraido - validar os cabecalhos em portugues num PDF em ingles reprovaria sempre.
$versoes = @{
  pt = @{
    Html       = Join-Path $repo "curriculo.html"
    Pdf        = Join-Path $repo "curriculo.pdf"
    Cabecalhos = @("Resumo Profissional", "Habilidades Técnicas", "Experiência Profissional",
                   "Projetos", "Formação Acadêmica", "Idiomas")
  }
  en = @{
    Html       = Join-Path $repo "en\resume.html"
    Pdf        = Join-Path $repo "en\resume.pdf"
    Cabecalhos = @("Professional Summary", "Technical Skills", "Professional Experience",
                   "Projects", "Education", "Languages")
  }
}

$alvos = if ($Idioma -eq "todos") { @("pt", "en") } else { @($Idioma) }

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

# ---------- 2. localizar o pdftotext (validacao) ----------
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

$falhas = 0
function Check($nome, $ok, $detalhe) {
  if ($ok) { Write-Host "  OK   $nome" -ForegroundColor Green }
  else     { Write-Host "  FALHA $nome -> $detalhe" -ForegroundColor Red; $script:falhas++ }
}

foreach ($chave in $alvos) {
  $versao = $versoes[$chave]
  $html = $versao.Html
  $pdf = $versao.Pdf
  if (-not (Test-Path $html)) { throw "HTML nao encontrado: $html" }
  Write-Host "`n=== $chave ===" -ForegroundColor Cyan

  # ---------- 3. exportar ----------
  # --no-pdf-header-footer e OBRIGATORIO: sem ele o Chrome carimba o caminho
  # file:///... e o numero da pagina como TEXTO REAL, e o ATS le esse lixo
  # misturado com a experiencia profissional.
  # --user-data-dir isola o processo: sem isso o Edge pode entregar o comando
  # para uma janela ja aberta em vez de executar o trabalho. O perfil leva o
  # idioma no nome porque, com o mesmo perfil, a segunda chamada seguida era
  # entregue ao processo da primeira e o segundo PDF nunca era gerado.
  if (Test-Path $pdf) { Remove-Item $pdf -Force }

  # Duas chamadas seguidas podem colidir: a segunda termina sem escrever nada.
  # Por isso cada tentativa usa um perfil novo, e esperamos o arquivo aparecer.
  $gerou = $false
  foreach ($tentativa in 1..3) {
    $perfil = Join-Path $env:TEMP "chrome-cv-$chave-$tentativa-$PID"
    & $browser `
      --headless `
      --disable-gpu `
      --no-pdf-header-footer `
      --run-all-compositor-stages-before-draw `
      --virtual-time-budget=10000 `
      --user-data-dir="$perfil" `
      --print-to-pdf="$pdf" `
      "file:///$($html -replace '\\','/')"

    $limite = (Get-Date).AddSeconds(20)
    while (-not (Test-Path $pdf) -and (Get-Date) -lt $limite) { Start-Sleep -Milliseconds 400 }
    if (Test-Path $pdf) { $gerou = $true; break }
    Write-Warning "tentativa $tentativa nao gerou o PDF; repetindo com um perfil novo."
  }

  if (-not $gerou) { throw "O PDF nao foi gerado: $pdf" }
  Write-Host "PDF gerado: $pdf"

  # ---------- 4. validar ----------
  if (-not $pdftotext) {
    Write-Warning "pdftotext nao encontrado - pulando a validacao ATS."
    continue
  }

  $texto = & $pdftotext -enc UTF-8 $pdf - | Out-String
  $linhas = $texto -split "`r?`n" | Where-Object { $_.Trim() -ne "" }

  Write-Host "`nValidacao ATS:"

  # A primeira linha extraida precisa ser o nome. Se nao for, o parser registra
  # o candidato com o nome errado - foi exatamente o bug do curriculo antigo,
  # que era lido como "CONTATO".
  Check "nome na primeira linha" `
        ($linhas[0].Trim() -eq "Rogélio Claro Fraga") `
        "primeira linha extraida: '$($linhas[0])'"

  foreach ($h in $versao.Cabecalhos) {
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
}

if ($falhas -gt 0) { Write-Host "`n$falhas verificacao(oes) falharam." -ForegroundColor Red; exit 1 }
Write-Host "`nTudo certo - o PDF esta legivel para os robos de triagem." -ForegroundColor Green
