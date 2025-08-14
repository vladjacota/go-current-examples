# Opportunities backlog

This file tracks new automation/examples to add for Update Service.

- [x] Staged promotion flow: copy packages from a staging server to a target server
- [x] RapidStart import package
  - Scope: package .rapidstart zip and import into target company using Import-NavData
  - Files: `Packages/RapidStart/*`
  - Success: RapidStart data imported into specified company
  - Inputs: one or more package Ids; source server host; optional identity and SSL flag
  - Behavior: uses Copy-UssPackageFromServer for each Id; logs results; no -Port usage
  - Success: selected packages appear on the destination Update Service server

- [ ] POS local bootstrap installer
  - Scope: install OPOS driver (Epson/Toshiba), required certificates, and pre-req tools using Install-UscPackage
  - Inputs: package Id selection; optional certificate paths; instance arguments
  - Success: POS host prepared with drivers and certs; idempotent reruns

- [ ] Certificate rotation example
  - Scope: build/import public/private cert packages and switch active cert on schedule
  - Inputs: .cer/.pfx paths, secure password; target stores; update strategy
  - Success: new certs deployed and validated without downtime

- [ ] Environment validator (preflight)
  - Scope: check installed packages and instance arguments; verify prerequisites before install
  - Success: clear PASS/FAIL output; optional auto-fix through package install

- [ ] Bundle strategy examples
  - Scope: demonstrate Version and VersionQuery filters for Dev/RC/Release; safe updates
  - Success: scripts install/update correct bundle per environment

---

## Discovered buildable packages (from this repo)

- Development tools
  - 7-Zip (`7-zip`) via `Packages/DevelopmentPackages/7Zip/NewPackage.ps1`
  - Visual Studio Code (`vs-code`) via `Packages/DevelopmentPackages/VS Code/NewPackage.ps1`
  - Git (`git`) via `Packages/DevelopmentPackages/Git/NewPackage.ps1`
  - Chrome (`chrome`) via `Packages/DevelopmentPackages/Chrome/NewPackage.ps1`
  - TortoiseGit (`tortoise-git`) via `Packages/DevelopmentPackages/TortoiseGit/NewPackage.ps1`
  - Service Tier Administration Tool (`service-tier-administration`) via `Packages/DevelopmentPackages/ServiceTierAdministrator/NewPackage.ps1`
  - SSMS (`sql-management-studio`) via `Packages/DevelopmentPackages/SqlManagementStudio/NewPackage.ps1`
- SQL Server packages via `Packages/Sql/NewSqlServerPackage.ps1`
  - `sql-server`, `sql-server-express`, `sql-server-developer` (Edition param)
- OPOS/UPOS drivers
  - Epson OPOS ADK (`epson-opos-adk`) via `Packages/OPOS/epson-opos-adk/EpsonPackage.psm1`
  - Toshiba UnifiedPOS (`toshiba-upos`) via `Packages/OPOS/toshiba-upos/ToshibaUposPackage.psm1`
- Certificates (generic creator) via `Packages/Certificates/NewCertificatePackages.psm1`
  - Public/private certificate packages (Ids configurable) – example: `my-public-certificate`, `my-private-certificate`
- Generic MSI wrapper via `Packages/Msi/MsiPackage.psm1`
  - Create arbitrary packages from .msi setups (Id/Name provided)
- App packages from AL context (examples)
  - See `LSCentral/Packages/New-AppPackageFromContext/*.ps1` (example Ids); demonstrates creating app packages and dependencies

## Candidate bundles (compositions)

- LS Central – Latest
  - `ls-central-demo-database`, `bc-web-client`, `bc-system-application-runtime`, `bc-base-application-runtime`, `ls-central-app-runtime`, `map/ls-central-to-bc`
  - Script examples: `LSCentral/Scripts/Install-LatestRelease.ps1`
- LS Central – Latest (existing DB)
  - `bc-server`, `bc-web-client`, `bc-system-symbols`, `bc-system-application-runtime`, `bc-base-application-runtime`, `ls-central-app-runtime`, `map/ls-central-to-bc`
  - Script examples: `LSCentral/Scripts/Install-LatestReleaseWithExistingDb.ps1`
- Cronus – Release / Release Candidate / Dev Branch
  - Base: `ls-central-demo-database`, `bc-web-client`, `ls-central-app`, `map/ls-central-to-bc`, `cronus-base-app`, `cronus-api-app`, `bc-cronus-license`
  - Scripts: `Workspace/CronusProject/Scripts/InstallRelease.ps1`, `InstallReleaseCandidate.ps1`, `InstallDevBranch.ps1` (VersionQuery varies)
- POS stack (drivers/tools)
  - `epson-opos-adk` or `toshiba-upos` (+ optional cert packages)
  - New example added: `Examples/POSBootstrap/Install-PosStack.ps1`
- Dev Workstation
  - `vs-code`, `git`, `tortoise-git`, `chrome`, `7-zip`, `sql-management-studio`
  - To implement: one-click script to install/update all
- SQL Stack
  - `sql-server-express` (or `sql-server`/`sql-server-developer`) + `sql-management-studio`
  - To implement: safe install with instance args and reboot handling
- Certificate Bootstrap
  - Public + private certificate packages into appropriate stores
  - To implement: creation + import + verification

Next: implement “Certificate rotation example” or “Environment validator (preflight)”.
