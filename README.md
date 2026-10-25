# Chrona Backup

Shared project for building dependable, unattended Mac backups to an existing Windows PC while preserving its streaming workload.

**Status: planning and diagnostics only. No replacement backup server has been installed or validated.**

The backup engine will remain Apple's Time Machine, with recovery through Apple's tools. The [documentation-reviewed plan](docs/PLAN.md) covers native SMB requirements, capacity and rollback, sleep/update limits, completed-backup monitoring, and a separate full-recovery test. A keep-awake utility alone does not satisfy the project.

## Start on the Windows PC

Clone this repository, open its folder in the local assistant, and give it this instruction:

> Read AGENTS.md, HANDOFF.md, and STATUS.md. Continue the Windows assessment described there. Work only within the documented scope. Do not inspect personal files, their names, or their contents. Keep the live stream running. Begin with the scoped system-readiness report and a storage plan; do not install, reconfigure networking, restart, or modify existing backups yet.

The initial report script is [Get-HostReadiness.ps1](scripts/windows/Get-HostReadiness.ps1). Its [usage notes](scripts/windows/README.md) explain exactly what it reads. It is not an installer and does not contact the network.

## How the two computers coordinate

- This repository carries reviewed code, plans, decisions, and non-sensitive progress.
- Commands run on the computer where its local assistant is working. GitHub does not execute local setup or relay chat messages.
- Pull before starting a turn that changes project files. Use a task branch such as `codex/windows-assessment` or `codex/mac-backup-validation`, then commit specific reviewed files and open a pull request.
- Keep [STATUS.md](STATUS.md) current with evidence, unknowns, and the next action. A push does not wake another chat; tell that chat to pull and read the update.
- Never force-push shared history or overwrite the other computer's uncommitted work.

## What success means

An automatically mounted drive or a running backup is not evidence of a completed backup. Completion requires a successful full backup, automatic incremental backups, tested restores, reconnect/restart behavior, and an alert when successful backups become stale. See [the implementation and validation plan](docs/PLAN.md).

## Data handling

The initial repository contains only general instructions and code suitable for public review. Check repository visibility before publishing any machine-specific information. Keep raw reports and private configuration in the ignored `local/` directory on each computer. Even in a private repository, never commit backup contents, personal filenames, credentials, encryption keys, or pairing codes.

The existing backup must remain intact while a repair or replacement is evaluated. No backup destination, virtual disk, partition, or physical disk has been chosen by this scaffold.
