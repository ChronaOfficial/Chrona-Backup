# Windows-side handoff

## Goal and working arrangement

Keep the existing Windows streaming workload running while establishing reliable, unattended Time Machine backups from a Mac. The desired experience is that backups happen automatically during ordinary use. The repository is the handoff between local chats on the two computers.

Two approaches remain open:

1. Diagnose and repair the existing mounted-disk-image-over-SMB arrangement.
2. Provide a Time Machine-aware SMB destination through a small Linux VM on Hyper-V if the evidence and storage plan justify it.

No failure cause or replacement architecture has been proven. Do not begin by erasing history or assuming the HDD is defective.

The 2026-10-25 documentation review in docs/PLAN.md makes native Apple backup and restore compatibility the acceptance requirement. Read it before choosing packages or writing a keep-awake wrapper. Samba has had Time Machine-specific regressions; verify the actual maintained package and fixes. The storage budget must preserve existing history, and full recovery remains untested until migration to a separate compatible target succeeds.

## First Windows session

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
