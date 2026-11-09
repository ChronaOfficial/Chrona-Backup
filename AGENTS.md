# Project instructions

## Objective

Deliver stable, automatic Time Machine backups using an existing Windows PC, with verified restoration and successful-backup monitoring. Preserve the PC's live streaming workload. Treat an earlier working setup as evidence to investigate a regression before choosing a replacement.

## User boundaries

- Do not browse, enumerate, search, open, or copy personal files or their names/contents. This includes existing backup contents and stream project/media files.
- System configuration and hardware metadata are distinct from personal-file access. Limit collection to the explicit fields in the readiness script and the agreed diagnostic scope.
- Do not collect raw backup logs, event logs, process command lines, environment dumps, share listings, usernames, hostnames, serial numbers, IP/MAC addresses, or volume labels. Logs can contain personal paths even when their purpose is diagnostic.
- If additional evidence is necessary, first describe the exact field and the narrow collection method. Do not treat authorization for one diagnostic command as broader access.
- Do not change, delete, resize, compact, repair, detach, reformat, or reuse existing backup storage during assessment. Do not change Time Machine settings as part of inspection.
- Do not stop the stream or reboot the PC without the user's explicit approval for that interruption. Enabling Hyper-V or changing an external virtual switch can interrupt the host and belongs in a planned maintenance window.
- Do not disable security protections, open public listeners, or weaken script execution policy to make setup easier.

## Repository handling

- Read README.md, HANDOFF.md, and STATUS.md before implementation.
- Publish only generic code and a deliberately sanitized summary. A private repo is not permission to publish personal information.
- Raw reports, local configuration, restore-test artifacts, and credentials belong outside Git, normally under ignored `local/`. Never use `git add .` or `git add -A`; stage explicit reviewed project paths.
- Check staged content and current repository visibility before pushing. Never commit a generated host report, an existing backup image, a virtual disk, credentials, or a pairing code.
- Use `codex/` task branches. Pull before edits, and reconcile the latest status instead of overwriting it. Prefer pull requests after the initial bootstrap.
- Git coordinates files, not live agents. Do not assume another chat was notified or is monitoring the repo.

## Implementation discipline

- Record observed facts, user reports, hypotheses, and proposed changes separately. Do not claim a failure cause from a low progress percentage or available disk space alone.
- Compare repairing the existing destination with a native Time Machine SMB destination before committing to a migration.
- If choosing a Linux VM, verify CPU/firmware, RAM, storage, network, and installed Samba versions. No GPU passthrough is needed for a file server. Resource allocations are estimates until measured.
- Use primary vendor documentation and record sources in docs/PLAN.md. Verify version-sensitive details before implementation.
- Create a capacity and rollback plan before creating backup storage. Preserve old history until replacement restore tests pass. Never attach one writable filesystem to Windows and Linux concurrently.
- Build automation around actual completed-backup timestamps and restoration evidence, not just reachability, mounting, or process startup.
- Use synthetic files for restore testing. The backup software will read the user's selected backup source normally; this does not authorize an assistant to inspect its personal contents.
- Mark unrun tests and unsupported/inconclusive telemetry accurately. Do not claim a Windows script was executed if it was only reviewed on macOS.

## Current authorized phase

As of 2026-11-09 the user has authorized setting up the backup solution and will pull this repository on the Windows PC for local implementation. Implement the OpenMediaVault 8 VM and native Time Machine destination described in docs/PLAN.md, using the existing internal Windows HDD. Confirm the exact local storage location and required capacity before allocating new virtual disks. Perform only the installation prerequisite checks actually needed; do not restart broad Mac diagnostics or speculative benchmarking.

This authorizes installation and configuration of the new VM/server in the local Windows task. It does not authorize interrupting the live stream, rebooting the host, or changing host networking in a way that interrupts it without explicit approval for that interruption. Use existing suitable networking where available. Keep credentials and host-specific inputs local.

The user has also allowed deleting the old backup if necessary for the replacement. This is an exception to the default history-preservation plan, not a request to erase it now. Identify the exact backup target and make the capacity/deletion plan concrete and reviewable before exercising that authorization. Do not erase other data or reformat the physical Windows disk by inference. A successful backup and restore remain necessary before claiming the new service works.
