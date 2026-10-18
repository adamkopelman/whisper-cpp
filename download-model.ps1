# Downloads the Whisper model this build uses (ggml-tiny.bin, multilingual, ~74 MB) from
# https://huggingface.co/ggerganov/whisper.cpp into models/ggml-tiny.bin next to this script,
# and verifies its SHA-256. Safe to re-run: an existing, verified model is left alone.
#
#   powershell -ExecutionPolicy Bypass -File download-model.ps1
#
# Works in Windows PowerShell 5.1 and PowerShell 7+.
param([switch]$Force)
$ErrorActionPreference = 'Stop'

$Url    = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin'
$Sha256 = 'be07e048e1e599ad46341c8d2a135645097a538221678b7acdd1b1919c6e1b21'
$Dir    = Join-Path $PSScriptRoot 'models'
$Dest   = Join-Path $Dir 'ggml-tiny.bin'
$Part   = "$Dest.part"

function Get-Sha256([string]$Path) { (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }

if ((Test-Path -LiteralPath $Dest) -and -not $Force) {
    if ((Get-Sha256 $Dest) -eq $Sha256) { Write-Host "OK: $Dest is already present and verified."; exit 0 }
    Write-Host "Existing $Dest has the wrong checksum; downloading it again."
}

New-Item -ItemType Directory -Force -Path $Dir | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'   # the progress bar makes Invoke-WebRequest very slow in 5.1
Write-Host "Downloading $Url ..."
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Part

$actual = Get-Sha256 $Part
if ($actual -ne $Sha256) {
    Remove-Item -LiteralPath $Part -Force
    throw "Checksum mismatch for ggml-tiny.bin: expected $Sha256, got $actual. Nothing was installed."
}
Move-Item -LiteralPath $Part -Destination $Dest -Force
Write-Host "OK: saved and verified $Dest"
