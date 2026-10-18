# Read-only Windows readiness summary

`Get-HostReadiness.ps1` runs on Windows PowerShell 5.1 or PowerShell 7 on Windows. Review the code before its first execution. It has been prepared on macOS and has not yet been executed against Windows providers.

## Scope

Default fields:

- Windows edition, version, and build.
- Total/free visible physical RAM.
- CPU model, core/thread counts, and CPU virtualization capability fields.
- Whether Windows reports an active hypervisor, plus the Hyper-V optional feature state.

Optional fields:

- `-IncludeStorage`: physical disk capacity/media/bus/health status, and filesystem capacity/free-space/health summaries. No labels, drive letters, paths, serials, or volume identifiers. Entries are not mapped to one another; do not guess which one is the backup disk.
- `-IncludeNetwork`: physical adapter link status and negotiated link speed. No addresses, adapter names, or MAC addresses.

The script does not inspect files, list shares, query process command lines, read event/backup logs, access credentials, benchmark disks, change settings, install anything, or contact the network. It prints a JSON summary to the local terminal. It does not upload or save it. This is a one-time capability/capacity snapshot, not a CPU-load, disk-throughput, or streaming-performance measurement.

## Run in the project folder

After the field scope is agreed for the local Windows session:

```powershell
.\scripts\windows\Get-HostReadiness.ps1
```

If storage and link metadata are in scope:

```powershell
.\scripts\windows\Get-HostReadiness.ps1 -IncludeStorage -IncludeNetwork
```

Optional local persistence (the `local/` directory is ignored by Git):

```powershell
New-Item -ItemType Directory -Path .\local -Force | Out-Null
.\scripts\windows\Get-HostReadiness.ps1 -IncludeStorage -IncludeNetwork |
    Set-Content -Encoding UTF8 .\local\host-readiness.json
```

Do not commit the JSON or paste it into a public issue. Write a deliberate, minimal summary instead. Do not use Git force-add to bypass ignore rules.

## Interpret conservatively

- Query failures produce `unavailable` and an exception type, without the raw error message. They do not trigger elevation or installation. Do not interpret unavailable telemetry as zero/free/healthy.
- Empty results remain explicit and are not a positive readiness result.
- Feature state `Enabled` does not prove Hyper-V is ready to host this workload. `HypervisorPresent` does not identify which virtualization feature started it. CPU capability fields can be inconclusive when a hypervisor is already running.
- Disk health strings are limited provider telemetry, not a SMART self-test or proof of disk integrity.
- Negotiated link speed is not measured backup throughput. This script does not test simultaneous streaming performance.
- If execution policy blocks the file, report the block and use the user's existing approved workflow. Do not change execution policy or rerun with `-ExecutionPolicy Bypass` automatically.

Provider references: [Win32_Processor](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor), [Win32_OptionalFeature](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-optionalfeature), [Get-PhysicalDisk](https://learn.microsoft.com/en-us/powershell/module/storage/get-physicaldisk), [Get-Volume](https://learn.microsoft.com/en-us/powershell/module/storage/get-volume), [Get-NetAdapter](https://learn.microsoft.com/en-us/powershell/module/netadapter/get-netadapter).
