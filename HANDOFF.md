# Windows-side handoff

## Latest Windows checkpoint

2026-11-11: the user requested a targeted, read-only configuration comparison with an older laptop destination. Core share settings matched, and the limited differences do not establish the cause of failed backups. The older backup was reported as running, not completed. Detailed configuration stays local. No settings, backup contents, or running workloads changed; see STATUS.md for the narrow next action.

See `codex/windows-omv-setup` and the bounded reuse assessment in docs/PLAN.md. One explicitly approved outer-container check found a standard sparsebundle. Exclusive VM ownership of the existing NTFS disk is a technically plausible in-place hosting option, but requires a revised storage layout and maintenance approval; it is not a verified fix or an authorized disk handoff. Preserve the history and do not create a fresh archive by assumption. No installation, image mount, backup modification, or stream interruption occurred. The user requested that diagnostics stay bounded; do not restart a broad investigation. Detailed host and storage findings remain local and must not be copied into Git.

## Goal and working arrangement

Keep the existing Windows streaming workload running while establishing reliable, unattended Time Machine backups from a Mac. The desired experience is that backups happen automatically during ordinary use. The repository is the handoff between local chats on the two computers.

Two approaches remain open:

1. Diagnose and repair the existing mounted-disk-image-over-SMB arrangement.
2. Provide a Time Machine-aware SMB destination through a small Linux VM on Hyper-V if the evidence and storage plan justify it.

No failure cause or replacement architecture has been proven. Do not begin by erasing history or assuming the HDD is defective.

The 2026-10-25 documentation review in docs/PLAN.md makes native Apple backup and restore compatibility the acceptance requirement. Read it before choosing packages or writing a keep-awake wrapper. Samba has had Time Machine-specific regressions; verify the actual maintained package and fixes. The storage budget must preserve existing history, and full recovery remains untested until migration to a separate compatible target succeeds.

## First Windows session

**2026-11-09 direction:** prioritize the concrete OpenMediaVault 8 VM deployment sequence at the top of docs/PLAN.md. The user wants an established solution and has stopped the open-ended diagnostic path. The numbered assessment steps below are background guidance, not a mandatory investigation before deployment. Collect only the installation inputs actually needed, within the existing privacy scope. No more Mac troubleshooting queries are authorized by this handoff. The prior Mac metadata attempt was inconclusive and provides no failure diagnosis.

The user has now explicitly authorized setup and will pull the repository on the PC. Follow the updated authorized phase in AGENTS.md: implement locally after selecting the exact storage/capacity, and ask only where an actual host interruption or unresolved destructive scope requires it. Do not stop at another generic proposal. The target behavior is automatic Time Machine backups when the Mac is back on its home network, with an alert when completed backups become stale.

Keep the HDD inside Windows and place the VM's data VHDX on the explicitly chosen volume. Do not attach that data VHDX or any physical host disk to the OMV installer; install with only the new small VM system disk attached. Selecting a fresh native network share in Time Machine replaces the manual image attachment workflow. The exact storage/deletion plan and any host interruption must still be deliberate, local actions.

1. Read AGENTS.md and the script usage notes. Confirm the checkout is current and identify the authorized project folder.
2. Explain the allowlisted system fields. Run the readiness script locally in the user's scoped assessment, without saving or publishing raw output through Git. Start without storage/network switches if those fields have not been agreed for that session.
3. Record whether Hyper-V telemetry is enabled, disabled, absent, or inconclusive. An active hypervisor can change CPU virtualization reporting. Do not enable features during assessment.
4. Establish a storage plan with the user using system metadata only. The privacy-preserving report does not map volumes to physical disks or identify the correct backup target; do not guess a target from array order or size.
5. Confirm whether stream reads/recordings and backup writes use the same physical device without examining media files or process command lines. Ask the user for that relationship if necessary.
6. Prepare a short comparison of repair versus a Samba VM, required capacity, maintenance interruptions, rollback, and tests. Account for both histories and free-space reserves before proposing new storage. Keep machine-specific mappings and sensitive details in ignored local notes.
7. Update STATUS.md with a sanitized summary and the next action. Commit only reviewed project files on a task branch and open a pull request. Tell the user which update the Mac-side chat should read.

## Next Mac session

Read the Windows summary and reconcile the plan. Collect no additional Mac diagnostics until their exact scope is established. Prior backup errors must be summarized without personal paths. Do not collect raw Time Machine logs by default.

## Before deployment

- Choose repair or replacement based on evidence.
- Agree the exact storage target and enough capacity to keep the existing backup while validating a replacement.
- Schedule any reboot or network interruption with the user.
- Prepare a recovery procedure independent of files kept only on the Mac.
- Implement and verify the acceptance gates in docs/PLAN.md.

## Boundaries that travel with the handoff

No personal-file inspection. No backup deletion or conversion. No secrets or raw host reports in Git. No unapproved disruption to the live stream. No unsupported promise that a VM alone will fix slow or failed backups.
