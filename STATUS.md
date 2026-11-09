# Project status

## Current phase

OpenMediaVault 8 VM deployment recommended and concrete installation handoff prepared. Exact Windows storage, capacity, Hyper-V, and LAN-switch inputs remain outstanding. No backup repair, server installation, storage allocation, or configuration change has been performed by this project.

## Completed

- Created shared instructions, privacy boundaries, handoff workflow, and validation plan.
- Prepared an allowlisted, read-only Windows readiness script with local-only output.
- Explicitly left architecture, target storage, and maintenance scheduling undecided.
- Reviewed Apple Time Machine destination/recovery documentation and its archived SMB server specification, Samba's implementation and relevant regression notes, and Microsoft's power/update/storage guidance.
- Expanded docs/PLAN.md with native compatibility requirements, a capacity/rollback budget, bounded power-helper requirements, truthful completion monitoring, and a full migration gate distinct from discovery or file restores.
- Researched an established server implementation: OMV 8 exposes native Time Machine support in its SMB interface and uses Debian-maintained Samba. Added the concrete VM installation sequence and the rule to expose only the new VM system disk to the ISO installer.

## Validation status

Static review passed, including an independent review of the allowlisted PowerShell output and privacy boundaries. Local documentation links and ignore rules for reports, credentials, and disk images were checked. The Windows readiness script requires its first real Windows execution; static review on macOS does not validate Windows providers or permissions. No backup or restore test has run.

2026-10-25, Mac-side documentation review: primary sources and installed command documentation were read. No backup queries, personal-file inspection, benchmark, power assertion, update change, or server deployment was performed. Documentation establishes an implementation path, not working backups on either computer. Every backup/recovery acceptance gate remains not run.

Two independent reviews checked the updated requirements against the source documentation and privacy/streaming boundaries. Relative links in the four changed documents resolve, and the Git whitespace check passed. These are documentation checks only.

2026-11-09, Mac side: one approved, filtered metadata attempt did not return usable destination information and was stopped. It does not establish a backup failure cause. The user redirected work to researching and preparing an established backup server; no more live troubleshooting queries were run. The draft collector was removed and is not a deliverable. Current research distinguishes manually mounting a backup image from selecting a native Time Machine network destination. No installation or backup/restore validation has run.

## Next action

Windows-side chat: read the deployment sequence at the top of docs/PLAN.md. Establish only the necessary installation inputs and prepare the OMV VM/storage setup for local execution. Do not restart broad diagnostics. Keep paths, drive letters, mappings, and credentials local. Schedule any required reboot or network interruption, and make any old-backup removal target concrete before deletion. The repository coordinates files; it does not provide remote execution on the PC.

## Decisions still needed

- Apply the recommended OMV native Time Machine destination to the exact local storage/host configuration.
- Storage capacity, ownership, physical-device contention, and preservation of existing history.
- Any maintenance window needed for deployment.
- Completed-backup freshness threshold and notification method.

## Handoff update format

When updating this file, include:

1. Date and working side (Mac or Windows), with no host identifiers.
2. What was actually observed or tested, and whether it passed.
3. What changed, if anything.
4. Remaining unknowns and blockers.
5. One concrete next action and the relevant commit/PR.

Do not paste raw output, private file paths, addresses, credentials, or backup contents here.
