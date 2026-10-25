# Implementation and validation plan

Documentation review: 2026-10-25. This is a proposed implementation and acceptance plan, not a deployed or validated backup service. The Windows assessment remains outstanding.

## Required outcome

Apple Time Machine must create the backups, retain history, and supply Apple's supported restoration workflow. The project may provide a server and operational helpers; it must not substitute a custom copy/archive format or label sleep prevention as a working backup system. Native compatibility is a requirement. Zero failures cannot be guaranteed; failures must be detected and recovery must be exercised.

## 1. Establish evidence

Confirm system readiness and storage capacity without inspecting personal files. Investigate why completed backups stopped rather than treating successful SMB file transfer as proof that the backup path is healthy. Low CPU utilization is useful headroom evidence, but disk and network contention need separate assessment.

Prioritize establishing a fresh, verified recovery point. Do not let an infrastructure redesign indefinitely postpone a viable repair or a separately agreed temporary backup.

Do not call the current image corrupt or the HDD faulty without evidence. A sparsebundle is also normal in supported network Time Machine setups; the distinction is how the destination is provided and managed.

Keep four evidence categories separate: user-reported behavior, directly observed allowlisted metadata, hypotheses, and proposed changes. The earlier working arrangement warrants investigation. Neither ordinary SMB file-copy success nor a low backup percentage establishes the cause of a regression. The existing readiness script does not measure performance, identify a particular disk, or prove backup integrity.

## 2. Choose repair or replacement

Apple documents network Time Machine to another Mac or a NAS explicitly supporting Time Machine over SMB. Samba implements that capability with `vfs_fruit`, required companion modules, and `fruit:time machine = yes`. A self-managed Windows-hosted VM still needs maintenance and validation; it is not an Apple-certified Windows backup product.

- [Apple supported destinations](https://support.apple.com/en-us/102423)
- [Samba vfs_fruit reference](https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html)

A candidate replacement is: Mac Time Machine -> Ethernet -> Linux VM on Hyper-V -> authenticated Samba Time Machine share -> Linux-owned backup filesystem on dedicated storage.

Use a maintained Linux release and verify its actual Samba package and relevant fixes. An initial estimate of 2 vCPUs and 2-4 GiB RAM is a starting point for evaluation, not a hardware requirement or performance guarantee. The file server needs no GPU passthrough.

### What native Time Machine SMB support requires

Apple's archived server specification requires SMB 3.x with signing; durable handles, leases, reconnect requests and correct timeouts; Bonjour discovery; and Apple's `F_FULLFSYNC` extension. Checkpoint flushes must reach stable storage before acknowledgement. Automatic discovery uses matching `_smb._tcp` and `_adisk._tcp` advertisements. The client checks server capabilities when selecting a network destination. This specification is archived and must be paired with current macOS testing, not treated as present-day certification.

[Apple Time Machine over SMB specification](https://developer.apple.com/library/archive/releasenotes/NetworkingInternetWeb/Time_Machine_SMB_Spec/)

For the candidate Samba server:

- Load `fruit` and its required `streams_xattr` companion; retain AAPL support. Add `catia` only if using its documented character conversion.
- Enable `fruit:time machine = yes`. It advertises FULLSYNC and enforces durable handles and the associated locking settings. Verify discovery support in the actual build; do not assume mDNS support is present.
- Avoid mixing fruit and non-fruit shares on the same server connection: the first share can affect AAPL negotiation.
- Treat `fruit:time machine max size` as an approximate advertised limit, not a hard filesystem quota or host-space reservation. Use a dedicated backup share and separate capacity checks.

These requirements come from the [Samba fruit reference](https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html). A successful configuration parse is necessary but does not prove compatibility or durability.

Honor flush requests: retain `strict sync = yes` and leave `aio write behind` unset. Samba documents that the latter can acknowledge writes before they succeed. Do not gain benchmark speed by weakening write durability or SMB security. Engineering requirement: the guest filesystem, virtual disk, Windows storage stack, controller, and physical disk must preserve the flush guarantees too; an advertised capability alone does not prove the complete path.

[Samba configuration reference](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)

### Version and destination decision

Samba bug 15926, a Time Machine regression introduced in the 4.22 series, appears in both the [4.23.3](https://www.samba.org/samba/history/samba-4.23.3.html) and [4.23.4](https://www.samba.org/samba/history/samba-4.23.4.html) release notes. Do not assume one early fix or a version-number comparison proves suitability. Check the selected distribution's maintained package, backports, and current known issues. [Upstream 4.25.1](https://www.samba.org/samba/history/samba-4.25.1.html) was released on 2026-10-23; this is research evidence, not a package selection or a claim that it has passed this workload.

| Approach | What it can establish | Decision condition |
| --- | --- | --- |
| Repair current destination | May restore the previously working behavior while preserving history | Investigate regression and prove backup/restore behavior; do not equate a mounted image on generic SMB with Apple's documented native network destination |
| Linux/Samba VM on the existing PC | Provides a documented implementation of Time Machine SMB support while Apple Time Machine remains the client | Verify host readiness, package, storage ownership/capacity, stream coexistence, and every applicable acceptance gate |
| Another Mac sharing a Time Machine destination, or a NAS explicitly supporting it | Follows destination categories in Apple's current support documentation | Alternative if the VM's maintenance/capacity burden is unsuitable; still requires backup and restore validation |

The proposed PC implementation uses normal Time Machine destination selection and scheduling, with no routine Finder image mounting. The server should operate independently of an assistant, browser, or logged-in chat. This is a recommendation pending assessment, not a chosen migration or an Apple endorsement of a Windows-hosted VM.

## 3. Plan storage before installing

- Identify the intended physical storage with the user; no target is preselected.
- Preserve the current backup until the replacement passes restore tests.
- Budget for initial backup size, retained history, growth, filesystem overhead, and keeping old history during migration. Measure the required scope through agreed system-level evidence; do not infer it solely from total Mac disk use.
- Let Linux own its backup filesystem, for example ext4 inside a separate VHDX. Do not simply re-export the existing Windows share through Linux, or give both operating systems simultaneous writable ownership of one filesystem.
- A dynamically expanding VHDX maximum is not reserved capacity. Monitor host free space, guest free space, and the backup quota separately. A fixed VHDX is an alternative only if capacity is available.
- Document how the VM configuration, storage, and encryption credentials can be recovered if either computer fails. Store secrets outside this repository.

The deployment proposal must show a capacity budget in consistent units: existing history retained + new initial backup + intended history/growth + host/guest filesystem overhead and free-space reserve. A disk's total capacity is not its available capacity. If both histories will not fit, identify separate storage before provisioning; do not delete the old backup to make a proposed migration appear feasible. Revisit the capacity budget using current scoped metadata, not stale reports.

Rollback means keeping the original destination unchanged and preserving access credentials outside the Mac. If the replacement fails its tests, stop adoption of that replacement and retain the original history. Returning to the original destination does not prove that its earlier failure has been repaired.

[Microsoft Hyper-V storage guidance](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/storage-io-performance)

## 4. Schedule deployment and preserve streaming

Hyper-V requires compatible hardware and firmware. Enabling it requires a restart. Creating or changing an external virtual switch can interrupt networking. Schedule those steps with the user; do not perform them during an uninterrupted stream.

Configure stable LAN addressing, authenticated LAN-only sharing, VM auto-start, graceful shutdown, and a deliberate update/restart policy. Keep the stream's GPU assigned to Windows. Measure the real concurrent workload before claiming the two services coexist without degradation.

- [Hyper-V requirements](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/host-hardware-requirements)
- [Hyper-V installation](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/install-hyper-v)
- [External switch setup and interruption warning](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines)
- [VM startup and shutdown settings](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vm)

### Sleep and updates are separate controls

A temporary keep-awake helper is an auxiliary feature, not the first acceptance gate:

- Mac: use the built-in `caffeinate` assertion for a bounded session. Its `-i` option prevents idle sleep; `-s` applies on AC power. A utility-bound invocation lasts for the utility's lifetime, so its timeout must be managed separately. Keep the Mac powered and in an arrangement that does not trigger lid sleep. Local disk assertions do not control the remote HDD.
- Windows: use a documented system-required power request with checked API results, bounded duration, cancellation, and cleanup. `PowerCreateRequest`/`PowerSetRequest` provide an explicit handle lifecycle; clear the request and close the handle when finished. A synchronous same-thread implementation may instead use `SetThreadExecutionState`. Leave display and permanent power-plan settings alone.
- Neither assertion is a general restart veto. User-initiated sleep/shutdown, power loss, application failure, and network interruptions remain possible. Do not claim otherwise.
- For a long initial backup, propose a short, explicit Windows Update pause through the supported Settings interface and a subsequent maintenance window. Verify the actual build and any management policy first. Microsoft documents automatic update restarts being held during the pause. Do not silently change update policies, disable update services, or indefinitely extend the pause. Active hours alone cannot cover an unrestricted multiday backup.

Sources: installed `caffeinate(8)` documentation; [Apple caffeinate source](https://github.com/apple-oss-distributions/PowerManagement/blob/main/caffeinate/caffeinate.c); [Windows power request creation](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-powercreaterequest), [setting](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-powersetrequest), [clearing](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-powerclearrequest); [thread execution state](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate); [Windows update pause](https://support.microsoft.com/en-us/windows/deployment/updates-lifecycle/pause-updates-in-windows); [active-hours policy](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-update).

### Performance expectation and measurement

Gigabit Ethernet has a raw limit of 125 MB/s. Microsoft gives about 110 MB/s sustained SMB throughput per gigabit under favorable conditions. Calculated transfer-only times for a fresh 4 TB (decimal) payload are about 8.9 hours at the raw limit and 10.1 hours at 110 MB/s. These are not Time Machine completion estimates: preparation, metadata, safe flushes, storage contention, and retained-history work add time. Incremental backups transfer changed data, not necessarily the whole source again.

A mechanical disk can be busy performing seeks and durable writes while aggregate MB/s and CPU utilization look low. A direct backup on a different disk is useful context but is not a controlled comparison of the same drive and workload. No bottleneck has been diagnosed here.

Before proposing faster Ethernet, agree a bounded synthetic-data test outside existing backups. Measure network-only throughput, sustained writes to the selected storage, then end-to-end SMB behavior, separately and while streaming. Agree size, duration, free-space reserve, local artifact location, and the benchmark abort condition based on stream impact before running it. Record only rates, durations, result codes, and user-confirmed stream impact. Do not read existing files or treat a brief cache-speed result as sustained disk speed. Test artifacts and raw measurements stay local. No benchmark has been run or authorized by this plan.

[Microsoft SMB performance guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/slow-smb-file-transfer), [Apple Time Machine duration guidance](https://support.apple.com/en-us/104984)

## 5. Acceptance gates

Every gate starts **not run**. Store detailed test evidence locally; publish only sanitized outcomes.

| Gate | Required evidence | Status |
| --- | --- | --- |
| Destination compatibility | Current macOS accepts the intended network destination through normal Time Machine setup; supported server package and effective settings are recorded | Not run |
| Full backup | Time Machine reports a new completed backup to the intended destination, with that completed backup's timestamp and the intended source scope privately confirmed by the user | Not run |
| Automatic operation | At least three subsequent automatic incremental backups complete without manual mounting | Not run |
| Restore | Synthetic test file, previous version, and deleted-file version restore successfully; restored contents/hash match expectations | Not run |
| Reconnect | Automatic backup succeeds after normal Mac sleep/wake and an agreed network interruption | Not run |
| PC restart | After a scheduled Windows restart, the server starts without an assistant/chat window and the Mac completes a backup | Not run |
| Stream coexistence | Representative stream continues without unacceptable dropped frames or interruption while a substantial backup runs | Not run |
| Capacity | Quota/headroom and both host/guest capacity monitoring are configured and checked without filling the production drive | Not run |
| Staleness alert | Alert is driven by age of the last successful backup; an agreed simulated stale condition triggers the selected notification | Not run |
| Recovery discovery | Migration Assistant can discover the backup; recovery instructions and credentials are available independently | Not run |
| Full recovery | Migration to a separate compatible target completes, with the user checking restored accounts, applications, settings, and selected data privately | Not run |

Migration Assistant discovery is not a completed full-system restore test. A full recovery claim requires the separate-target migration gate. If no suitable target is available, mark it untested and do not replace it with a claim based on synthetic file restores. Time Machine recovery may require reinstalling macOS before restoring accounts, applications, files, and settings; the backup is not a directly bootable clone. The user must privately confirm intended backup inclusions/exclusions; this project must not inspect personal files to do so.

Run synthetic version/deletion tests only in a new, deliberately created test folder. Record expected hashes before backing it up, complete a backup of version A, modify it to version B and complete another backup, then delete only the synthetic test file and complete another backup. Restore the current available and historical versions using Apple's tools, outside the original test folder, and compare hashes. Do not delete or browse any existing backup files. Keep artifacts outside Git. These tests are planned, not executed.

[Apple Time Machine recovery instructions](https://support.apple.com/en-us/102551)

## 6. Ongoing operation

Use a completed-backup freshness threshold agreed with the user (24-48 hours is a proposal, not yet a configured policy). Keep notifications quiet for normal operation and actionable for stale backups, storage problems, or failed restore checks. Describe monitoring location and delivery before implementing it.

### Completion evidence and truthful monitoring

The installed `tmutil` manual describes `latestbackup` as identifying the latest completed backup. Its help documents `latestbackup [-m] [-t] [-d mount_point]`; `-t` provides timestamp-only output. This was a documentation review, not an execution against the user's backups.

Before implementing or running a collector, agree this narrow scope: the timestamp of the latest completed backup for one user-configured destination, the observation time, and a success/unavailable result. A destination reference stays in private local configuration. Do not enumerate destination names, collect raw logs, or retrieve backup paths as an intermediate step.

The collector must:

- Validate timestamp-only behavior on the actual macOS and destination type. The manual requires root and Full Disk Access; disclose those requirements before any collector is installed. Do not request access now or silently elevate.
- Bind evidence to the intended destination; a different backup disk's newer timestamp must not produce a healthy result. Avoid `-m` during assessment because it requests mounting. Normal backup operations may mount the selected destination themselves after deployment.
- Suppress error text and accept only the expected timestamp representation. Permission errors, timeouts, unavailable destinations, unexpected output, or ambiguous binding mean **unknown**, never successful. Do not forward unexpected output or paths into reports.
- Distinguish the timestamp identifying a completed backup from the observation time. Do not label it the precise instant writing finished without validating that interpretation. Handle local time, timezone changes, future timestamps, and clock uncertainty explicitly.
- Keep freshness and restoration evidence separate. Neither a reachable share, a mounted image, a progress percentage, an idle process, nor `startbackup --block` exiting establishes a successful restore. Undocumented progress counters may be diagnostic hints only.
- Report stale known evidence even if a backup is currently running. An unavailable current query must not erase prior evidence or suppress an alert. A separate watchdog must also detect the monitoring service itself stopping; a monitor that is not running cannot deliver its own alert.

Until these semantics are verified, the helper must not present a green "protected" indicator. No completion collector, notification service, keep-awake service, or update coordination has been installed by this project.

### Implementation order

1. Complete the existing scoped Windows assessment and compare repair with replacement. Resolve storage capacity and ownership before selecting a deployment.
2. Agree maintenance, capacity, rollback, local credential handling, and how failed backups/failed monitoring will be reported.
3. Prepare and review a version-specific server configuration and reversible installation procedure. Deploy only in the agreed window and to the explicitly chosen storage.
4. Select the native destination in Time Machine, verify a complete backup, and run the restore gates. Preserve prior history throughout.
5. Add bounded power coordination and completion monitoring, validate failure paths, and prove unattended operation across sleep, reconnection, and a planned restart.

Hardware testing cannot be replaced by static code review or documentation research. Do not label an unexecuted script, an untested Windows package, or an untested recovery path as complete.

Use an additional independent copy for irreplaceable data as a separate scope decision. Retention, cleanup of old backups, and any later storage reuse need an explicit migration/retention decision after validation.
