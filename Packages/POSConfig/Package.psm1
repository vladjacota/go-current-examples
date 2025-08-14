$ErrorActionPreference = 'stop'

function Install-Package($Context, [switch] $Update) {
  Write-Progress -Id 217 -Activity $Context.Name -Status "Initializing..." -PercentComplete 5

  $ServerData = Get-ServerInstalled -InstanceDirectory $Context.InstanceDirectory
  $ConnectionInfo = Get-ConnectionInfo -ServerData $ServerData
  try { Import-Module LsSetupHelper\BusinessCentral\Management -ErrorAction Stop } catch { Write-Verbose 'Could not import LsSetupHelper BusinessCentral Management'; }
  try { Import-Module (Get-BcModulePath -ServerDir $ServerData.ServerDir -Type Management) -Global -ErrorAction Stop } catch { }

  $Instance = $Context.InstanceName
  if ($Instance) {
    try {
      # If an instance name can be read
  try { Import-Module LsSetupHelper\BusinessCentral\Management -ErrorAction Stop } catch { }
  try { Import-Module (Get-BcModulePath -InstanceName $Instance -Type Management) -Global -ErrorAction Stop } catch { }
  try { Import-Module (Get-BcModulePath -InstanceName $Instance -Type Apps) -Global -ErrorAction Stop } catch { }

      # Track created resources for potential rollback
      $createdResources = @()

      # Resolve parameters with defaults
      $company = if ($Context.Arguments.Company) { $Context.Arguments.Company } else { $ConnectionInfo.Company }
      $posUser = if ($Context.Arguments.POSUserName) { $Context.Arguments.POSUserName } else { 'POS' }
      $posAdminUser = if ($Context.Arguments.POSAdminUserName) { $Context.Arguments.POSAdminUserName } else { 'POSADMIN' }
      $posPerm = if ($Context.Arguments.POSPermissionSetId) { $Context.Arguments.POSPermissionSetId } else { 'SUPER (DATA)' }
      $posPermApp = if ($Context.Arguments.POSPermissionSetAppName) { $Context.Arguments.POSPermissionSetAppName } else { 'System Application' }
      $posPermPublisher = if ($Context.Arguments.POSPermissionSetAppPublisher) { $Context.Arguments.POSPermissionSetAppPublisher } else { 'Microsoft' }
      $adminPerm = if ($Context.Arguments.POSAdminPermissionSetId) { $Context.Arguments.POSAdminPermissionSetId } else { 'SUPER' }
      $cuId = if ($Context.Arguments.CodeunitId) { [int]$Context.Arguments.CodeunitId } else { 50101 }
      $cuMethod = if ($Context.Arguments.MethodName) { $Context.Arguments.MethodName } else { 'SetupPOSEnvironment' }

      # Generate passwords if not provided
      function New-RandomPassword([int]$length = 16) {
        $allowed = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@$%&*?'
        -join (1..$length | ForEach-Object { $allowed[(Get-Random -Max $allowed.Length)] })
      }
      $posPwdPlain = if ($Context.Arguments.POSUserPassword) { [string]$Context.Arguments.POSUserPassword } else { New-RandomPassword 14 }
      $adminPwdPlain = if ($Context.Arguments.POSAdminPassword) { [string]$Context.Arguments.POSAdminPassword } else { New-RandomPassword 18 }

      # Create POS user
      try {
        $existingUser = Get-NAVServerUser -ServerInstance $Instance  | Where-Object { $_.UserName -eq $posUser } -ErrorAction SilentlyContinue
        if (-not $existingUser) {
          New-NAVServerUser -ServerInstance $Instance -UserName $posUser -Password (ConvertTo-SecureString -String $posPwdPlain -AsPlainText -Force) -FullName "POS User" -State Enabled
          $createdResources += @{ Type = "User"; Name = $posUser; ServerInstance = $Instance }
          Write-Verbose "Created POS user successfully"
        }
        else {
          Write-Verbose "POS user already exists, skipping creation"
        }
      }
      catch {
        throw "Failed to create POS user: $_"
      }

      # Assign permission set to POS user
      try {
        New-NAVServerUserPermissionSet -PermissionSetId $posPerm -AppName $posPermApp -AppPublisher $posPermPublisher -ServerInstance $Instance -UserName $posUser
        $createdResources += @{ Type = "Permission"; Name = $posPerm; User = $posUser; ServerInstance = $Instance }
        Write-Verbose "Assigned SUPER (DATA) permission to POS user successfully"
      }
      catch {
        throw "Failed to assign permission set to POS user: $_"
      }

      # Create POSADMIN user
      try {
        $existingAdmin = Get-NAVServerUser -ServerInstance $Instance | Where-Object { $_.UserName -eq $posAdminUser } -ErrorAction SilentlyContinue
        if (-not $existingAdmin) {
          New-NAVServerUser -ServerInstance $Instance -UserName $posAdminUser -Password (ConvertTo-SecureString -String $adminPwdPlain -AsPlainText -Force)  -FullName 'POS Admin' -State Enabled
          $createdResources += @{ Type = "User"; Name = $posAdminUser; ServerInstance = $Instance }
          Write-Verbose "Created POSADMIN user successfully"
        }
        else {
          Write-Verbose "POSADMIN user already exists, skipping creation"
        }
      }
      catch {
        throw "Failed to create POSADMIN user: $_"
      }

      # Assign permission set to POSADMIN user
      try {
        New-NAVServerUserPermissionSet -PermissionSetId $adminPerm -ServerInstance $Instance -UserName $posAdminUser
        $createdResources += @{ Type = "Permission"; Name = $adminPerm; User = $posAdminUser; ServerInstance = $Instance }
        Write-Verbose "Assigned SUPER permission to POSADMIN user successfully"
      }
      catch {
        throw "Failed to assign permission set to POSADMIN user: $_"
      }

      $Arg1 = $Context.Arguments.StoreNumber
      $Arg2 = $Context.Arguments.POSID
      if ($Arg1) {
        # Only trigger the CU if there is a store no. entered
        $ArgString = $Arg1 + '|' + $Arg2
        try {
          Invoke-NAVCodeunit -ServerInstance $Instance -Tenant default -Company $company -CodeunitId $cuId -MethodName $cuMethod -Argument $ArgString.ToString()
          Write-Verbose "Successfully invoked codeunit for POS setup"
        }
        catch {
          throw "Failed to invoke codeunit: $_"
        }
      }

      # Also run any payload scripts shipped inside the package with the same arguments
      $store = $Context.Arguments.StoreNumber
      $pos = $Context.Arguments.POSID
      Get-ChildItem -Path $Context.TemporaryDirectory -Filter '*.ps1' -Recurse | ForEach-Object {
        Write-Host "Running payload script: $($_.FullName)"
        & PowerShell -NoProfile -ExecutionPolicy Bypass -File $_.FullName --% -StoreNumber "$store" -POSID "$pos"
      }
    }
    catch {
      Write-Error "Error during installation: $_"

      # Perform rollback of created resources in reverse order
      for ($i = $createdResources.Count - 1; $i -ge 0; $i--) {
        $resource = $createdResources[$i]
        try {
          if ($resource.Type -eq "User") {
            Write-Warning "Rolling back: Removing user $($resource.Name)"
            Remove-NAVServerUser -ServerInstance $resource.ServerInstance -UserName $resource.Name -Force -ErrorAction SilentlyContinue
          }
          elseif ($resource.Type -eq "Permission") {
            Write-Warning "Rolling back: Removing permission $($resource.Name) from user $($resource.User)"
            Remove-NAVServerUserPermissionSet -ServerInstance $resource.ServerInstance -PermissionSetId $resource.Name -UserName $resource.User -Force -ErrorAction SilentlyContinue
          }
        }
        catch {
          Write-Warning "Failed to roll back $($resource.Type) $($resource.Name): $_"
        }
      }

      # Re-throw the exception
      throw "Installation failed with rollback: $_"
    }
  }
  else {
    throw "Error: Instance name was provided but Context.InstanceName is null or empty. Please verify the instance configuration."
  }
}

function Update-Package($Context) {
  Install-Package -Context $Context -Update
}

function Invoke-CustomCodeunit {
  param(
    [string] $ServerInstance,
    [string] $CompanyName,
    $CodeunitId,
    $MethodName
  )

  $Arguments = @{
    CodeunitId     = $CodeunitId
    ServerInstance = $ServerInstance
    CompanyName    = $CompanyName
  }

  if ($MethodName) {
    $Arguments.MethodName = $MethodName
  }

  if ($MethodName) {
    Write-Host "Invoking codeunit $CodeunitId with method $MethodName."
  }
  else {
    Write-Host "Invoking codeunit $CodeunitId without method."
  }

  Invoke-NAVCodeunit @Arguments
}

function Get-Company {
  param(
    [Parameter(Mandatory)]
    $ConnectionString
  )

  Import-Module LsSetupHelper\Sql\Utils

  $Entries = Invoke-SqlcmdEx -Query "select Top 1 Name from dbo.Company" -ConnectionString $ConnectionString
  $Entry = $Entries | Select-Object -First 1
  if (!$Entry) {
    return ''
  }
  return $Entry.Name
}

function Get-ConnectionInfo {
  param(
    $ServerData
  )

  $DbServerInstance = $ServerData.ServerConfig.DatabaseServer
  if ($ServerData.ServerConfig.DatabaseInstance) {
    $DbServerInstance += "\$($ServerData.ServerConfig.DatabaseInstance)"
  }

  $CompanyName = (Get-Company -ConnectionString $ServerData.ConnectionString)
  return @{
    DbServerInstance  = $DbServerInstance
    DatabaseName      = $ServerData.ServerConfig.DatabaseName
    Company           = $CompanyName
    CompanyNormalized = $CompanyName.Replace('.', '_')
  }
}

function Get-ServerInstalled {
  param(
    [Parameter(Mandatory = $true)]
    $InstanceDirectory
  )
  return Get-Content -Path (Join-Path $InstanceDirectory 'bc-server.json') -Raw | ConvertFrom-Json
}
