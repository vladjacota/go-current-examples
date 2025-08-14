param(
    [string] $InstanceName = 'POS',
    [string[]] $PackageIds = @('epson-opos-adk','toshiba-upos'),
    [hashtable] $Arguments = @{},
    [switch] $Force
)
#requires -RunAsAdministrator
$ErrorActionPreference = 'stop'
Import-Module UpdateService

if (-not $Arguments.ContainsKey('bc-server')) {
    $Arguments['bc-server'] = @{ }
}

$packages = @()
foreach ($id in $PackageIds) { $packages += @{ Id = $id; Version = '' } }

$packages | Get-UscUpdates -InstanceName $InstanceName | Out-Null
$packages | Install-UscPackage -InstanceName $InstanceName -UpdateStrategy 'Manual' -Arguments $Arguments -Force:$Force
