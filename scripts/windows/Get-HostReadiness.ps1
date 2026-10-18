#requires -Version 5.1
<#
.SYNOPSIS
Print an allowlisted, read-only Windows readiness summary as local JSON.
.DESCRIPTION
No files, logs, credentials, shares, or process command lines are inspected.
No settings are changed and no network requests or uploads are performed.
Storage and network metadata are opt-in. See README.md for field scope.
#>
[CmdletBinding()]
param(
    [switch]$IncludeStorage,
    [switch]$IncludeNetwork
)

if ($env:OS -ne 'Windows_NT') {
    throw 'This script is intended for Windows only.'
}

function Invoke-ReadinessQuery {
    param([Parameter(Mandatory = $true)][scriptblock]$Query)
    try {
        $values = @(& $Query)
        $queryStatus = 'available'
        if ($values.Count -eq 0) { $queryStatus = 'no_results' }
        [ordered]@{ Status = $queryStatus; Data = $values }
    }
    catch {
        # Raw exception messages may contain system paths or identifiers.
        [ordered]@{
            Status = 'unavailable'
            ErrorType = $_.Exception.GetType().Name
            Data = @()
        }
    }
}

$summary = [ordered]@{
    SchemaVersion = 1
    CapturedAtUtc = [DateTime]::UtcNow.ToString('o')
    Scope = 'Read-only system metadata; no personal-file inspection'
    OperatingSystem = Invoke-ReadinessQuery {
        Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption, Version, BuildNumber, TotalVisibleMemorySize, FreePhysicalMemory -ErrorAction Stop |
            ForEach-Object {
                [ordered]@{
                    Edition = $_.Caption
                    Version = $_.Version
                    Build = $_.BuildNumber
                    TotalVisibleMemoryKiB = $_.TotalVisibleMemorySize
                    FreePhysicalMemoryKiB = $_.FreePhysicalMemory
                }
            }
    }
    Processor = Invoke-ReadinessQuery {
        Get-CimInstance -ClassName Win32_Processor -Property Name, NumberOfCores, NumberOfLogicalProcessors, VirtualizationFirmwareEnabled, SecondLevelAddressTranslationExtensions, VMMonitorModeExtensions -ErrorAction Stop |
            ForEach-Object {
                [ordered]@{
                    Model = $_.Name
                    Cores = $_.NumberOfCores
                    LogicalProcessors = $_.NumberOfLogicalProcessors
                    VirtualizationFirmwareEnabled = $_.VirtualizationFirmwareEnabled
                    SecondLevelAddressTranslation = $_.SecondLevelAddressTranslationExtensions
                    VMMonitorModeExtensions = $_.VMMonitorModeExtensions
                }
            }
    }
    Hypervisor = Invoke-ReadinessQuery {
        Get-CimInstance -ClassName Win32_ComputerSystem -Property HypervisorPresent -ErrorAction Stop |
            ForEach-Object { [ordered]@{ Present = $_.HypervisorPresent } }
    }
    HyperVFeature = Invoke-ReadinessQuery {
        Get-CimInstance -ClassName Win32_OptionalFeature -Filter "Name='Microsoft-Hyper-V-All'" -Property InstallState -ErrorAction Stop |
            ForEach-Object {
                $featureState = switch ($_.InstallState) {
                    1 { 'Enabled' }
                    2 { 'Disabled' }
                    3 { 'Absent' }
                    default { 'Unknown' }
                }
                [ordered]@{ State = $featureState }
            }
    }
    PhysicalDisks = [ordered]@{ Status = 'not_requested'; Data = @() }
    Volumes = [ordered]@{ Status = 'not_requested'; Data = @() }
    PhysicalLinks = [ordered]@{ Status = 'not_requested'; Data = @() }
}

if ($IncludeStorage) {
    $summary.PhysicalDisks = Invoke-ReadinessQuery {
        Get-PhysicalDisk -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                SizeBytes = $_.Size
                MediaType = [string]$_.MediaType
                BusType = [string]$_.BusType
                HealthStatus = [string]$_.HealthStatus
                OperationalStatus = @($_.OperationalStatus | ForEach-Object { [string]$_ })
            }
        }
    }
    $summary.Volumes = Invoke-ReadinessQuery {
        Get-Volume -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                FileSystemType = [string]$_.FileSystemType
                SizeBytes = $_.Size
                FreeBytes = $_.SizeRemaining
                HealthStatus = [string]$_.HealthStatus
            }
        }
    }
}

if ($IncludeNetwork) {
    $summary.PhysicalLinks = Invoke-ReadinessQuery {
        Get-NetAdapter -Physical -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                Status = [string]$_.Status
                LinkSpeed = [string]$_.LinkSpeed
            }
        }
    }
}

$summary | ConvertTo-Json -Depth 8
