param(
    [Parameter(Mandatory)] [string] $ZipPath,
    [Parameter(Mandatory)] [string] $OutputDir,
    [string] $Id = 'rapidstart-package',
    [string] $Name = 'RapidStart Package',
    [switch] $Import,
    [string] $Server,
    [switch] $Force
)
$ErrorActionPreference = 'stop'
try { Import-Module UpdateServiceServer -ErrorAction Stop } catch { }

$pkg = @{
    Id = $Id
    Name = $Name
    Version = (Get-Item $ZipPath).LastWriteTimeUtc.ToString('yyyy.MM.dd.HHmm')
    InputPath = @(
        $ZipPath,
        (Join-Path $PSScriptRoot '*')
    )
    OutputDir = $OutputDir
    Commands = @{
        Install = 'Package.psm1:Install-Package'
    }
    Parameters = @(
        @{ Key = 'Company'; Description = 'Company name to import into'; Default = 'CRONUS International Ltd.' }
        @{ Key = 'Overwrite'; Description = 'Overwrite existing data when importing'; Widget = 'Checkbox'; Default = 'true' }
        @{ Key = 'ApplyAfterImport'; Description = 'Apply data after import (compatibility only)'; Widget = 'Checkbox'; Default = 'false' }
    )
}

$created = New-UssPackage @pkg -Force:$Force
if ($Import) { $created | Import-UssPackage -Server $Server -Force:$Force }
$created
