$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $zip = Join-Path $Context.TemporaryDirectory 'rapidstart.zip'
    $company = $Context.Arguments.Company
    $overwrite = $Context.Arguments.Overwrite
    $apply = $Context.Arguments.ApplyAfterImport

    if (-not (Test-Path $zip)) { throw "RapidStart archive not found: $zip" }
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
