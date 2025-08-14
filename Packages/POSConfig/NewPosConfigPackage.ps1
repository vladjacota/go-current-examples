<#!
.SYNOPSIS
  Create a POS Config & Setup package for LS Central SaaS.

.PARAMETER Path
  Path to a folder or file(s) to include in the package (e.g., JSON, REG, scripts). Defaults to POSConfig subfolder.

.PARAMETER OutputDir
  Output folder for the built package (.zip). Mandatory.

.PARAMETER Id
  Package Id. Defaults to 'pos-config'.

.PARAMETER Name
  Package display name. Defaults to 'POS Config & Setup'.

.PARAMETER Import
  If set, import the package to an Update Service server after building.

.PARAMETER Server
  Update Service server URL/hostname used when -Import is specified.

.PARAMETER Force
  Overwrite existing package on disk or on server.
#>
param(
  [string] $Path,
  [Parameter(Mandatory)] [string] $OutputDir,
  [string] $Id = 'pos-config',
  [string] $Name = 'POS Config & Setup',
  [switch] $Import,
  [string] $Server,
  [switch] $Force
)
$ErrorActionPreference = 'stop'
try { Import-Module UpdateServiceServer -ErrorAction Stop } catch { }

if (-not $Path) { $Path = Join-Path $PSScriptRoot 'POSConfig\*' }

$pkg = @{
  Id = $Id
  Name = $Name
  Version = '1.0.0'
  InputPath = @(
    $Path,
    (Join-Path $PSScriptRoot '*')
  )
  OutputDir = $OutputDir
  Instance = $true
  Commands = @{ Install = 'Package.psm1:Install-Package'; Update = 'Package.psm1:Install-Package' }
  Parameters = @(
    @{ Key = 'StoreNumber'; Description = 'Store ID' }
    @{ Key = 'POSID'; Description = 'POS Terminal ID' }
  )
  Dependencies = @(
    @{ Id = 'bc-web-client'; VersionQuery = '' }
  )
}
$created = New-UssPackage @pkg -Force:$Force
if ($Import) { $created | Import-UssPackage -Server $Server -Force:$Force }
$created
