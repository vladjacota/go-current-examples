param(
    $Target = 'Dev',
    $Server,
    $Port,
    [switch] $Force
)
$ErrorActionPreference = 'stop'
Import-Module UpdateServiceServer

$PackagesDir = Join-Path $PSScriptRoot "..\Packages\$Target"

if (!(Test-Path $PackagesDir))
{
    throw "No packages do deploy."
}

Import-UssPackage -Path (Join-Path $PackagesDir '*') -Server $Server -Force:$Force