$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $zip = Join-Path $Context.TemporaryDirectory 'rapidstart.zip'
    $company = $Context.Arguments.Company
    $overwrite = $Context.Arguments.Overwrite
    $apply = $Context.Arguments.ApplyAfterImport

    if (-not (Test-Path $zip)) { throw "RapidStart archive not found: $zip" }

    # Ensure BC modules are available on the host
    try { Import-Module LsSetupHelper\BusinessCentral\Management -ErrorAction Stop } catch { }
    try { Import-Module (Get-BcModulePath -InstanceName $Context.InstanceName -Type Management) -Global -ErrorAction Stop } catch { }

    if (-not $company) {
        # Fallback to server company if not provided
        try {
            $serverData = Get-Content -Path (Join-Path $Context.InstanceDirectory 'bc-server.json') -Raw | ConvertFrom-Json
            $company = (Get-CompanyFromConnection -ConnectionString $serverData.ConnectionString)
        } catch { }
    }
    if (-not $company) { throw "Company is required" }

    $tmp = Join-Path $Context.TemporaryDirectory 'rapidstart'
    [System.IO.Directory]::CreateDirectory($tmp) | Out-Null
    Expand-Archive -Path $zip -DestinationPath $tmp -Force

    $packages = Get-ChildItem $tmp -Filter '*.rapidstart' -File
    if ($packages.Count -eq 0) { throw 'No .rapidstart files found in archive.' }

    foreach ($pkg in $packages) {
        Import-NavData -ApplicationObjectFile $pkg.FullName -CompanyName $company -IncludeGlobalData:$true -IncludeApplicationData:$true -Force:$overwrite | Out-Null
        if ($apply) {
            # Apply data after import when supported
            # In modern BC, data is applied during import; this flag is provided for compatibility.
        }
    }
}

function Get-CompanyFromConnection {
    param([Parameter(Mandatory)] $ConnectionString)
    try {
        Import-Module LsSetupHelper\Sql\Utils -ErrorAction Stop
        $row = Invoke-SqlcmdEx -Query "select top 1 Name from dbo.Company" -ConnectionString $ConnectionString | Select-Object -First 1
        return ($row.Name)
    } catch { return $null }
}
