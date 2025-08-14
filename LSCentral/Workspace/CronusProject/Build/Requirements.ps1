param(
    $Server = 'localhost',
    $RestManagementPort = '16551'
)
#requires -RunAsAdministrator

<#
    .SYNOPSIS
        Install requirements for build.
#>

$ErrorActionPreference = 'stop'

$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
try
{
    Import-Module UpdateService
}
catch
{
    Invoke-WebRequest -Uri "http://$($Server):$($RestManagementPort)/ManagementFile/install" -UseBasicParsing | % { & ([ScriptBlock]::Create([System.Text.Encoding]::Utf8.GetString($_.Content))) }
    Import-Module UpdateService
}

$Arguments = @{
    'update-service-server' = @{
        'ConnectionString' = ''
    }
}

$Packages = @(
    @{ Id = 'ls-setup-helper'; Version = '^!'}
    @{ Id = 'ls-package-tools'; Version = '^!'}
    @{ Id = 'update-service-server'; Version = '^!'}
)

if (($Packages | Get-UscUpdates))
{
    Write-Host "Installing requirements for build..."
    $Packages | Install-UscPackage -UpdateStrategy Automatic -Arguments $Arguments
    $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
}

Write-Host 'Current installed packages:'
$Packages | Get-UscInstalledPackage | Format-Table -Property 'Id', 'Version' | Out-String | Write-Host