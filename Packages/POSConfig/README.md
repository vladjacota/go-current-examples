# POS Config & Setup package

This package configures LS Central SaaS for a POS terminal on the computer where it's installed.

- Instance-scoped package so each POS can pass its own StoreNumber/POSID.
- Creates/updates POS users and permissions, then invokes a setup codeunit.
- Depends on `bc-web-client` to ensure BC client/management modules are available.

## Build

```powershell
# Minimal payload example (put any scripts/config under POSConfig/)
PS> .\Packages\POSConfig\NewPosConfigPackage.ps1 -OutputDir .\out -Import -Server http://localhost
```

Parameters:
- Path: payload root (defaults to `Packages/POSConfig/POSConfig/*`)
- OutputDir: where to place the built package
- Id, Name: optional metadata
- Import, Server, Force: manage import to Update Service

## Install on target

Use Update Service Client to install on a computer:

```powershell
Install-UscPackage -Id 'pos-config' -Version '*' -Instance 'BCInstance' -Arguments @{ StoreNumber = '1001'; POSID = 'POS01' }
```

What it does:
- Imports BC management modules for the target instance.
- Creates users `POS` and `POSADMIN` if missing, assigns permissions.
- Invokes codeunit 50101 `SetupPOSEnvironment` with `StoreNumber|POSID`.
- Runs any payload scripts in the package with `-StoreNumber` and `-POSID`.
