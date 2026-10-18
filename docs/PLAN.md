# Implementation and validation plan

## 1. Establish evidence

Confirm system readiness and storage capacity without inspecting personal files. Investigate why completed backups stopped rather than treating successful SMB file transfer as proof that the backup path is healthy. Low CPU utilization is useful headroom evidence, but disk and network contention need separate assessment.

Prioritize establishing a fresh, verified recovery point. Do not let an infrastructure redesign indefinitely postpone a viable repair or a separately agreed temporary backup.

Do not call the current image corrupt or the HDD faulty without evidence. A sparsebundle is also normal in supported network Time Machine setups; the distinction is how the destination is provided and managed.

## 2. Choose repair or replacement

Apple documents network Time Machine to another Mac or a NAS explicitly supporting Time Machine over SMB. Samba implements that capability with `vfs_fruit`, required companion modules, and `fruit:time machine = yes`. A self-managed Windows-hosted VM still needs maintenance and validation; it is not an Apple-certified Windows backup product.

- [Apple supported destinations](https://support.apple.com/en-us/102423)
- [Samba vfs_fruit reference](https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html)

A candidate replacement is: Mac Time Machine -> Ethernet -> Linux VM on Hyper-V -> authenticated Samba Time Machine share -> Linux-owned backup filesystem on dedicated storage.

Use a maintained Linux release and verify its actual Samba package and relevant fixes. An initial estimate of 2 vCPUs and 2-4 GiB RAM is a starting point for evaluation, not a hardware requirement or performance guarantee. The file server needs no GPU passthrough.

## 3. Plan storage before installing

- Identify the intended physical storage with the user; no target is preselected.
- Preserve the current backup until the replacement passes restore tests.
- Budget for initial backup size, retained history, growth, filesystem overhead, and keeping old history during migration. Measure the required scope through agreed system-level evidence; do not infer it solely from total Mac disk use.
- Let Linux own its backup filesystem, for example ext4 inside a separate VHDX. Do not simply re-export the existing Windows share through Linux, or give both operating systems simultaneous writable ownership of one filesystem.
- A dynamically expanding VHDX maximum is not reserved capacity. Monitor host free space, guest free space, and the backup quota separately. A fixed VHDX is an alternative only if capacity is available.
- Document how the VM configuration, storage, and encryption credentials can be recovered if either computer fails. Store secrets outside this repository.

[Microsoft Hyper-V storage guidance](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/storage-io-performance)

## 4. Schedule deployment and preserve streaming

Hyper-V requires compatible hardware and firmware. Enabling it requires a restart. Creating or changing an external virtual switch can interrupt networking. Schedule those steps with the user; do not perform them during an uninterrupted stream.

Configure stable LAN addressing, authenticated LAN-only sharing, VM auto-start, graceful shutdown, and a deliberate update/restart policy. Keep the stream's GPU assigned to Windows. Measure the real concurrent workload before claiming the two services coexist without degradation.

- [Hyper-V requirements](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/host-hardware-requirements)
- [Hyper-V installation](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/install-hyper-v)
- [External switch setup and interruption warning](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines)
- [VM startup and shutdown settings](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vm)

## 5. Acceptance gates

Every gate starts **not run**. Store detailed test evidence locally; publish only sanitized outcomes.

| Gate | Required evidence | Status |
| --- | --- | --- |
| Full backup | Time Machine reports a completed backup to the intended destination, with a completion timestamp | Not run |
| Automatic operation | At least three subsequent automatic incremental backups complete without manual mounting | Not run |
| Restore | Synthetic test file, previous version, and deleted-file version restore successfully; restored contents/hash match expectations | Not run |
| Reconnect | Automatic backup succeeds after normal Mac sleep/wake and an agreed network interruption | Not run |
| PC restart | After a scheduled Windows restart, the server starts without an assistant/chat window and the Mac completes a backup | Not run |
| Stream coexistence | Representative stream continues without unacceptable dropped frames or interruption while a substantial backup runs | Not run |
| Capacity | Quota/headroom and both host/guest capacity monitoring are configured and checked without filling the production drive | Not run |
| Staleness alert | Alert is driven by age of the last successful backup; an agreed simulated stale condition triggers the selected notification | Not run |
| Recovery | Migration Assistant can discover the backup; recovery instructions and credentials are available independently | Not run |

Migration Assistant discovery is not a completed full-system restore test. If a spare target is available, perform a full migration test and record its scope separately. Time Machine recovery may require reinstalling macOS before restoring accounts, applications, files, and settings; the backup is not a directly bootable clone.

[Apple Time Machine recovery instructions](https://support.apple.com/en-us/102551)

## 6. Ongoing operation

Use a completed-backup freshness threshold agreed with the user (24-48 hours is a proposal, not yet a configured policy). Keep notifications quiet for normal operation and actionable for stale backups, storage problems, or failed restore checks. Describe monitoring location and delivery before implementing it.

Use an additional independent copy for irreplaceable data as a separate scope decision. Retention, cleanup of old backups, and any later storage reuse need an explicit migration/retention decision after validation.
