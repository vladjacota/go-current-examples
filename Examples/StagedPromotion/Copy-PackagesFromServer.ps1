param(
    [Parameter(Mandatory)] [string[]] $Id,
    [Parameter(Mandatory)] [string] $SourceServer,
    [switch] $SourceUseSsl,
    [string] $SourceIdentity,
    [switch] $Force
)
$ErrorActionPreference = 'stop'
try { Import-Module UpdateServiceServer -ErrorAction Stop } catch { }

foreach ($pkg in $Id) {
    Write-Host "Copying package: $pkg from $SourceServer..."
    Copy-UssPackageFromServer -Id $pkg -SourceServer $SourceServer -SourceUseSsl:$SourceUseSsl -SourceIdentity $SourceIdentity -Force:$Force
}
Write-Host 'Done.'
