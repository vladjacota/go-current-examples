# Staged promotion: copy packages from another server

This script copies one or more packages from a source Update Service server into the local server.

Usage (PowerShell):

```powershell
# Copy bc-al-compiler and ls-package-tools from the public server
./Copy-PackagesFromServer.ps1 -Id bc-al-compiler, ls-package-tools -SourceServer gocurrent.lsretail.com -SourceUseSsl
```

Notes:
- No -Port parameter is used; pass full URL to your local server when importing packages elsewhere.
- Requires UpdateServiceServer module to be installed.
