[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$NotebookPath,
    [Parameter(Mandatory=$true)][ValidateSet("word", "pdf", "latex", "markdown")][string]$Format,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [string]$Page,
    [string]$ZimCommand = "zim"
)
$ErrorActionPreference = "Stop"
function Find-Command([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { throw "Comando '$Name' non trovato. Installalo e verifica che sia disponibile nel PATH." }
    return $cmd.Source
}
if (-not (Test-Path -LiteralPath $NotebookPath)) { throw "Notebook non trovato: $NotebookPath" }
$NotebookPath = (Resolve-Path -LiteralPath $NotebookPath).Path
$zim = Find-Command $ZimCommand
$outputFull = [System.IO.Path]::GetFullPath($OutputPath)
$outputDir = Split-Path -Parent $outputFull
if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("zim-export-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempDir | Out-Null
try {
    if ($Format -eq "latex" -or $Format -eq "pdf") {
        $zimFormat = "latex"
        $intermediate = Join-Path $tempDir "document.tex"
    } else {
        $zimFormat = "markdown"
        $intermediate = Join-Path $tempDir "document.md"
    }
    $zimArgs = @("--export", "--output=$intermediate", "--format=$zimFormat", "--singlefile", "--overwrite", $NotebookPath)
    if ($Page) { $zimArgs += $Page }
    Write-Host "Esportazione da Zim in $zimFormat..."
    & $zim @zimArgs
    if ($LASTEXITCODE -ne 0) { throw "Zim ha terminato con codice di errore $LASTEXITCODE." }
    if (-not (Test-Path -LiteralPath $intermediate)) { throw "Zim non ha creato il file intermedio atteso: $intermediate" }
    switch ($Format) {
        "markdown" { Copy-Item -LiteralPath $intermediate -Destination $outputFull -Force }
        "latex" { Copy-Item -LiteralPath $intermediate -Destination $outputFull -Force }
        "word" {
            $pandoc = Find-Command "pandoc"
            Write-Host "Conversione in Word (DOCX) con Pandoc..."
            & $pandoc $intermediate "--output=$outputFull"
            if ($LASTEXITCODE -ne 0) { throw "Pandoc ha terminato con codice di errore $LASTEXITCODE." }
        }
        "pdf" {
            $latexmk = Find-Command "latexmk"
            Write-Host "Compilazione PDF con LaTeX..."
            & $latexmk "-pdf" "-interaction=nonstopmode" "-halt-on-error" "-outdir=$tempDir" $intermediate
            if ($LASTEXITCODE -ne 0) { throw "La compilazione LaTeX è fallita. Controlla l'installazione TeX e i pacchetti richiesti." }
            $pdf = Join-Path $tempDir "document.pdf"
            if (-not (Test-Path -LiteralPath $pdf)) { throw "La compilazione non ha prodotto document.pdf." }
            Copy-Item -LiteralPath $pdf -Destination $outputFull -Force
        }
    }
    Write-Host "Esportazione completata: $outputFull" -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
