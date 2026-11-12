# Implementation and validation plan

Documentation review: 2026-11-09. This is a proposed implementation and acceptance plan, not a deployed or validated backup service. The recommended implementation is now OpenMediaVault 8 in a Windows-hosted VM. Exact host deployment inputs remain outstanding.

## Latest direction: preserve and evaluate reuse of existing history

2026-11-12 research note: [Apple's disk-image documentation](https://support.apple.com/guide/disk-utility/create-a-disk-image-dskutl11888/mac) describes sparsebundles as growing read/write images stored in multiple files and commonly used for network Time Machine backups. An embedded `.dmg` in the basename is not evidence of an invalid container; the approved outer-metadata check already identified a standard sparsebundle. Do not rename or convert the active archive based on its filename. A conventional single-file image and a sparsebundle can exercise storage and file access differently, but no latency, locking, or integrity cause was measured here.

The user reports that the older backup completed and the newer image eventually connected and began a backup attempt. Newer completion remains unknown. [Apple's sleep settings](https://support.apple.com/en-ie/guide/mac-help/mchle41a6ccd/mac) distinguish display sleep from system sleep; keeping a client awake may help an interrupted session, but does not diagnose its cause or control the server's power state. [Microsoft's SMB performance guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/slow-smb-file-transfer) explains per-file overhead and storage latency; low CPU utilization alone does not establish a healthy or fast storage path. These are hypotheses, not findings about this archive. [Apple's macOS 27.2.1 release](https://developer.apple.com/news/releases/?id=11092026d) and [update summary](https://support.apple.com/en-mo/127257) establish a published update with general fixes, not a documented resolution of this particular failure. Let the active attempt finish; assess completed-backup evidence before proposing another check. Client versions, power settings, and other detailed observations stay local.

2026-11-11 comparison note: a user-requested, read-only comparison of the two selected destinations found matching core SMB settings and limited visibility/permission differences, without establishing causation. Detailed settings and capacities stay local. [Microsoft's SMB share reference](https://learn.microsoft.com/en-us/powershell/module/smbshare/set-smbshare?view=windowsserver2025-ps#-folderenumerationmode) distinguishes access-based visibility from unrestricted listings; visibility policy is not itself a filesystem write-permission grant. Top-level ACL comparison does not establish effective access to every item in an existing archive. Windows volume free space also does not establish the free space inside a mounted backup image. Do not change settings or adopt OMV as a diagnosed fix on this evidence alone.

The user wants the existing Time Machine history to continue if feasible while fixing unreliable network backups. The source backup must not be treated as disposable or corrupt without evidence. Resolve reuse before executing the fresh-destination portions of the earlier OMV sequence below. Preparation is authorized; host interruption, backup inspection, reassociation, copying, deletion, or filesystem changes do not follow from this documentation update.

Distinguish continuing the current image through a repaired connection from migrating that image to a native Time Machine server. The existing plan places backup data inside a new Linux-owned VHDX; an existing image outside that VHDX does not become guest storage automatically. Migration needs an explicit capacity and rollback plan. Re-exporting a Windows SMB mount through Linux is not a demonstrated compatibility fix. Neither physical-drive ownership nor filesystem format should change by inference.

Apple documents [inheritance of history by a replacement Mac](https://support.apple.com/en-euro/guide/mac-help/mh35732/27/mac/27); that is not proof of a supported in-place Windows-to-OMV migration. Apple also documents [network-backup verification](https://support.apple.com/guide/mac-help/verify-your-backup-disk-mh26840/mac). Any verification proposal must state its exact scope first and keep personal contents and paths out of reports; no verification was run here. Continued write compatibility still requires a completed incremental backup and restore testing after the destination is configured.

OMV documents [mounting existing NTFS filesystems](https://docs.openmediavault.org/en/8.x/administration/storage/filesystems.html), but filesystem mount support alone does not prove the required Time Machine/Samba behavior on the existing archive. Hyper-V [physical-disk attachment](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vmharddiskdrive) requires an offline host disk. That would change storage ownership and remove direct host access, and is not part of the currently authorized VHDX layout. Do not attempt it, attach existing storage to an installer, or format the source disk as a shortcut.

### Result of the bounded reuse assessment

After explicit user approval, a single Windows metadata-only check identified one standard Apple sparsebundle and read only allowlisted outer format fields. No image bands, backed-up personal contents, backup dates, or identifiers were collected. No image was mounted or changed. Private measurements remain local. This establishes the container type, not archive integrity or successful Time Machine recognition.

**Conclusion:** reuse of the existing archive is technically plausible; a fresh history is not required merely because the SMB server changes. This is an engineering inference from the container type and documented server/storage capabilities, not a verified repair. There is no proven cause for the existing failed updates.

| Storage approach | Reuse implication |
| --- | --- |
| Earlier new-data-VHDX layout | Does not automatically include the existing archive; preserving history would require a deliberate complete-image migration and sufficient space. |
| Existing physical disk assigned exclusively to OMV | Candidate for in-place reuse: mount its existing NTFS filesystem and share the folder containing the intact sparsebundle. No reformat or conversion is inherent in this design. The disk must be offline to Windows while assigned to the guest, and the VM's own OS/configuration must be stored on a different host disk. This changes the earlier storage-ownership plan and is not authorized for execution yet. |
| Copy intact archive to Linux-owned storage | Candidate for testing continuation without risking the original history, but requires separately agreed destination space and a complete, consistent copy. No other disk has been selected or accessed for this purpose. |

OMV's [NTFS backend](https://github.com/openmediavault/openmediavault/blob/ae01ca2a4d857f4f8763121b0ab1a10e700e40b1/deb/openmediavault/usr/share/php/openmediavault/system/filesystem/backend/ntfs.inc) supports existing mounts. Its [Samba template](https://github.com/openmediavault/openmediavault/blob/ae01ca2a4d857f4f8763121b0ab1a10e700e40b1/deb/openmediavault/srv/salt/omv/deploy/samba/files/shares.j2) enables `fruit`, `streams_xattr`, and Time Machine capability for the share; it does not adopt or repair an archive. These are upstream-source observations, not installed-package validation. [NTFS-3G documents extended-attribute support](https://github.com/tuxera/ntfs-3g/wiki/Using-Extended-Attributes), while [Samba documents its own alternate-stream mapping](https://www.samba.org/samba/docs/current/man-html/vfs_streams_xattr.8.html). Consequently, NTFS itself is not a categorical blocker, but the actual driver, permissions, stream metadata, and durability behavior must be validated rather than assumed compatible with Windows-written data.

The remaining proof is narrow: in an approved maintenance window and preferably against a protected copy, confirm the existing history is recognized, complete an incremental backup into that same history, and restore a synthetic file. Recognition alone is insufficient. Stop on any request to erase, replace, repair, or start a new history. No ownership handoff, identity reassociation, rename, filesystem repair, or writable test is authorized by this assessment. The user requested no further broad diagnostics.

## Recommended implementation: established NAS software

Use OpenMediaVault (OMV) 8, which is based on Debian 13 and uses Debian's maintained Samba packages. Its SMB share interface includes Time Machine support, and its generated configuration loads `fruit` and `streams_xattr` and enables the Time Machine capability. This supplies an existing server implementation and management interface; the project does not need a new backup engine or a custom NAS administration application.

Sources: [OMV 8 release and installation route](https://www.openmediavault.org/?p=4002), [official SMB interface source](https://github.com/openmediavault/openmediavault/blob/master/deb/openmediavault/workbench/src/app/pages/services/smb/smb-share-form-page.component.ts), [official Samba configuration template](https://github.com/openmediavault/openmediavault/blob/master/deb/openmediavault/srv/salt/omv/deploy/samba/files/shares.j2), [OMV Samba package ownership](https://docs.openmediavault.org/en/8.x/administration/services/samba.html).

The physical HDD stays installed in Windows. Windows stores a separate data VHDX file there; OMV owns the Linux filesystem inside that virtual disk. The Mac selects the OMV network share directly in Time Machine, and Time Machine creates/manages its own backup image. Do not re-export the existing Windows SMB share through OMV. The VM still depends on Windows uptime and the physical drive; this uses an established implementation of native Time Machine server features, not a guarantee that every previous failure has been diagnosed or eliminated.

### Why change the current arrangement

Connecting through Finder with Command-K is normal. Sparsebundles are also normal for network Time Machine. The distinction is between selecting a supported network destination in Time Machine and manually attaching an image and selecting that virtual volume as a local destination. In the latter case, the prior share mount and image attachment are external prerequisites (an engineering inference). Apple's network-destination workflow manages reconnection itself. Ordinary file copies do not establish support for the additional Time Machine server capabilities. Research does not prove that this distinction caused a particular stalled backup, and CPU architecture alone is not evidence of the cause.

[Apple network-destination behavior](https://support.apple.com/en-nz/guide/mac-help/mh15139/mac), [Apple disk-image documentation](https://support.apple.com/guide/disk-utility/create-a-disk-image-dskutl11888/22.7/mac/27).

### The requested persistent connection

Existing Mac software such as [AutoMounter](https://www.pixeleyes.co.nz/automounter/) can automatically mount/re-mount network shares, including after switching between Ethernet and Wi-Fi. It addresses share availability, not proof that Time Machine has a valid completed backup. It does not turn ordinary Windows sharing into a native Time Machine server or guarantee a writable image survives an interrupted session. It is therefore an optional mounting convenience, not the proposed replacement backup system.

Use native Time Machine scheduling/reconnection and Samba's documented durable-handle support as the foundation. Keep the host available with supported power/update settings, and use completed-backup monitoring to catch failures or stale protection. Do not create a custom network transport, constantly remount an in-use image, force-stop backups on an unchanged progress counter, or equate a periodic ping with a safe storage session. No sleep, disk-spin-down, or network-power cause has been established. The server needs no GPU; the proposed small VM resource budget remains an estimate, not a claim of measured stream coexistence.

### Concrete Windows-side deployment sequence

This is the implementation handoff. Do not make an open-ended troubleshooting exercise a prerequisite. Confirm only what the installation needs before changing the host:

1. Identify the user-selected Windows volume and current available capacity; keep the path and drive letter private. Establish the replacement size and space for existing history. Do not infer a physical disk from a reported nominal capacity. The user has allowed replacement of the old backup if necessary, but the exact deletion target, scope, and capacity plan must be concrete before any deletion. No deletion is part of VM installation.
2. Establish whether Hyper-V and a suitable LAN virtual switch already exist. Reuse an appropriate switch. If enabling Hyper-V or creating/changing a switch is necessary, schedule the required Windows restart/network interruption with the user; preserve the live stream until then.
3. Download the current OMV 8 AMD64 installer from the project's official download route. Create a small Generation 2 VM, provisionally 2 vCPUs, 2-4 GiB RAM, and a new 32 GiB system VHDX. These are initial allocations, not measured guarantees. Keep Secure Boot enabled with the Microsoft UEFI Certificate Authority template where supported by the selected installer. Do not disable host security to work around an installation issue.
4. **Attach only the new VM system disk during ISO installation.** OMV's installer consumes its selected disk and may automatically select the first available one. Do not attach the data VHDX, physical Windows disks, or existing backup image at this stage. Boot only the VM from the ISO; do not reboot the Windows PC into it. After installation, eject the ISO from the VM and update OMV's packages through its supported interface.
5. Create and attach a separate data VHDX on the intended internal HDD, sized from the capacity plan. Create a Linux filesystem on this new virtual disk through OMV. Formatting applies only to this newly created virtual disk, never the host HDD. Prefer reserved capacity when feasible; if using dynamic allocation, separately monitor host free space because its maximum is not reserved.
6. In OMV, create a dedicated authenticated backup account and shared folder with read/write permissions. Enable SMB and enable Time Machine support on that share. Configure discovery and restrict access to the LAN. Retain safe write and SMB security settings. Change default administrative credentials and keep all secrets outside Git. Use OMV's interface rather than editing its generated smb.conf directly.
7. Resolve the history-reuse decision above first. If a fresh destination is explicitly selected after that review, on the Mac use System Settings -> General -> Time Machine -> Add Backup Disk and select the OMV **network share**. Supply the new share credentials, choose backup encryption, and store its recovery password independently. Let Time Machine create the new image in that fresh-start case. A history-preserving migration requires its own verified procedure; do not treat this fresh-start step as that procedure. Do not remove the old destination until the transition is deliberate.
8. Configure VM automatic startup and graceful shutdown. Keep the host awake during backup availability, use a deliberate update window, and run the first complete Time Machine backup. Establish automatic incrementals, a synthetic-file restore, and completed-backup staleness alerts. The full recovery claim still requires the migration gate below, but speculative benchmarks are not a prerequisite to beginning deployment.

Installer source: [OMV ISO instructions and disk selection warning](https://docs.openmediavault.org/en/8.x/installation/via_iso.html). Host sources: [Microsoft Hyper-V virtual disks](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/storage-io-performance), [Linux on Hyper-V best practices](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v), [VM firmware configuration](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vmfirmware).

Only deployment preparation is complete. No VM, share, replacement disk, or completed backup exists as a result of this research. The Windows-side task must perform the actual installation locally; Git does not provide remote control.

### Windows preparation checkpoint: 2026-11-09

The user requested preparation only until a maintenance window. Do not enable Windows features, restart Windows, or change host networking until that interruption is explicitly approved. Machine-specific prerequisites and storage selection are recorded only in ignored local notes. Existing backup contents remain untouched. Resolve history reuse, the capacity budget, and reserves before allocating any replacement data disk.

The [official download page](https://www.openmediavault.org/download.html) linked OMV `8.3.1` AMD64 at preparation time. The downloaded installer is `openmediavault_8.3.1-amd64.iso`, 1,244,774,400 bytes, with verified SHA-256 `5ada7dea09dbb10365b6f245515e71c79c5398d8f8f1acda675ee6d8b572d2e5`. It is stored under ignored `local/installers/` and is not in Git. Verification establishes download integrity against the published checksum; boot, Secure Boot compatibility, installed package versions, and Time Machine operation are untested. Recheck the official release and checksum before deployment if the preparation becomes stale.

If the OMV VHDX approach proceeds after the reuse decision, follow the sequence above in an approved maintenance window: complete required Hyper-V prerequisites and restart if needed, configure a suitable LAN connection, then install with only a new 32 GiB system VHDX attached. Initial resources remain 2 vCPUs and 4 GiB RAM, subject to actual workload validation. Add a separate data VHDX only after agreeing the capacity budget and completing OS installation. No Windows feature enablement or VM-creation command has run during preparation.

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
