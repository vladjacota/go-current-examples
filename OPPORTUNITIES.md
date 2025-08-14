# Opportunities backlog

This file tracks new automation/examples to add for Update Service.

- [x] Staged promotion flow: copy packages from a staging server to a target server
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
