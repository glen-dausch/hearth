# One-command developer setup for Windows. Safe to run again.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

function Step($t) { Write-Host ""; Write-Host "=== $t ===" -ForegroundColor Cyan }

Step "Checking Python"
$py = $null
if (Get-Command py -ErrorAction SilentlyContinue) { $py = @("py", "-3.12") }
elseif (Get-Command python -ErrorAction SilentlyContinue) { $py = @("python") }
else { Write-Host "Python not found. Install it with: winget install Python.Python.3.12" -ForegroundColor Red; exit 1 }
& $py[0] @($py[1..($py.Count)] | Where-Object { $_ }) --version
if ($LASTEXITCODE -ne 0) { Write-Host "Python 3.12 not found. Install it with: winget install Python.Python.3.12" -ForegroundColor Red; exit 1 }

Step "Creating virtual environment (.venv)"
if (-not (Test-Path .\.venv)) { & $py[0] @($py[1..($py.Count)] | Where-Object { $_ }) -m venv .venv }
$venvPy = ".\.venv\Scripts\python.exe"

Step "Installing tools"
& $venvPy -m pip install --upgrade pip
& $venvPy -m pip install -e ".[dev]"
if ($LASTEXITCODE -ne 0) { Write-Host "Install failed." -ForegroundColor Red; exit 1 }

Step "Turning on pre-commit safety checks"
if (Test-Path .\.git) {
    & $venvPy -m pre_commit install
} else {
    Write-Host "No git repository yet. Run 'git init -b main' and then run this script again." -ForegroundColor Yellow
}

Step "Running tests and style check"
& $venvPy -m pytest
$t = $LASTEXITCODE
& $venvPy -m ruff check .
$r = $LASTEXITCODE

if ($t -eq 0 -and $r -eq 0) { Write-Host "`nWarehouse ready." -ForegroundColor Green }
else { Write-Host "`nSomething failed above. Paste the output to Claude." -ForegroundColor Yellow }
