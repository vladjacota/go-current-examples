# RapidStart package

Create an Update Service package that imports Business Central RapidStart configuration packages (.rapidstart) into a target company.

## Build

```powershell
./NewRapidStartPackage.ps1 -ZipPath C:\path\to\rapidstart.zip -OutputDir C:\out -Import -Server http://localhost:16652
```

## Use

At install time, you can provide parameters:
- Company (default: CRONUS International Ltd.)
- Overwrite (true/false)
- ApplyAfterImport (compatibility)

Notes:
- Provide a .zip containing one or more .rapidstart files.
- The package depends on `bc-web-client` to ensure BC management modules are present.
- The package module uses Import-NavData which is available on service tier hosts with the correct BC tools installed.
- If Company is omitted at install time, it attempts to discover the default company from the instance connection.
