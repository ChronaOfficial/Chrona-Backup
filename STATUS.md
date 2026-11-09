# Project status

## Current phase

The bounded reuse assessment found a standard Apple sparsebundle. In-place OMV hosting is technically plausible through exclusive disk ownership, but continued backups and preservation of history remain untested; this is not a confirmed fix. See docs/PLAN.md for the evidence and storage implications. The user explicitly requested no stream interruption or existing-backup changes. No server was installed and no host configuration changed.

## Completed

- Created shared instructions, privacy boundaries, handoff workflow, and validation plan.
- Prepared an allowlisted, read-only Windows readiness script with local-only output.
- Explicitly left architecture, target storage, and maintenance scheduling undecided.
- Reviewed Apple Time Machine destination/recovery documentation and its archived SMB server specification, Samba's implementation and relevant regression notes, and Microsoft's power/update/storage guidance.
- Expanded docs/PLAN.md with native compatibility requirements, a capacity/rollback budget, bounded power-helper requirements, truthful completion monitoring, and a full migration gate distinct from discovery or file restores.
- Researched an established server implementation: OMV 8 exposes native Time Machine support in its SMB interface and uses Debian-maintained Samba. Added the concrete VM installation sequence and the rule to expose only the new VM system disk to the ISO installer.

## Validation status

Static review passed, including an independent review of the allowlisted PowerShell output and privacy boundaries. Local documentation links and ignore rules for reports, credentials, and disk images were checked. The Windows readiness script has now completed a real Windows execution for its default fields; its optional storage/network switches have not been exercised. No backup or restore test has run.

2026-10-25, Mac-side documentation review: primary sources and installed command documentation were read. No backup queries, personal-file inspection, benchmark, power assertion, update change, or server deployment was performed. Documentation establishes an implementation path, not working backups on either computer. Every backup/recovery acceptance gate remains not run.

Two independent reviews checked the updated requirements against the source documentation and privacy/streaming boundaries. Relative links in the four changed documents resolve, and the Git whitespace check passed. These are documentation checks only.

2026-11-09, Mac side: one approved, filtered metadata attempt did not return usable destination information and was stopped. It does not establish a backup failure cause. The user redirected work to researching and preparing an established backup server; no more live troubleshooting queries were run. The draft collector was removed and is not a deliverable. Current research distinguishes manually mounting a backup image from selecting a native Time Machine network destination. No installation or backup/restore validation has run.

2026-11-09, Windows side:

- Pulled the latest laptop handoff from `codex/omv-server-setup` at `b57b624`; continued on `codex/windows-omv-setup`.
- Completed the agreed read-only prerequisite assessment. Machine-specific results remain in ignored local notes. This is not a performance or backup-integrity test.
- Confirmed the intended storage locally without inspecting personal files or backup contents. Identifiers, mappings, exact capacity, and detailed host state are excluded from this shared checkpoint.
- No Windows feature, power setting, network setting, restart, or backup storage was changed. No VM or virtual disk was created.
- Latest direction: preserve the existing history and evaluate continuing it while addressing unreliable network backups. A new server does not itself establish that the existing backup is corrupt or must be discarded. Reuse remains unverified; no new backup creation, image reassociation, migration, deletion, or repair has been attempted.
- Downloaded the official OMV 8.3.1 AMD64 ISO into ignored local storage. Its SHA-256 matches the value published on the official OMV download page. It has not been booted or installed. See the preparation checkpoint in docs/PLAN.md.
- The user selected preparation only, with host interruption deferred to a future maintenance window. That window has not been scheduled or approved.
- Subsequently, the user authorized only a small outer-container metadata check. It found one standard sparsebundle; it did not mount the archive or read personal backup contents. The collector passed a syntax check and one synthetic allowlist test before that one execution. Details and measurements remain local.
- Source review established an in-place hosting candidate using an existing NTFS filesystem with exclusive VM disk ownership. Actual Time Machine continuation, stream-metadata compatibility, backup integrity, and restoration remain untested. Diagnostics stopped at the requested bounded check.

## Next action

Continue from `codex/windows-omv-setup`. Present the exclusive-disk hosting option and a protected-copy validation option, then agree storage ownership, rollback protection, and a maintenance window before any writable test. Do not continue broad diagnostics or infer permission to mount, repair, rename, or take over the existing disk. No fresh archive should be created by assumption. The repository coordinates files; it does not provide remote execution on either computer.

## Decisions still needed

- Establish whether existing history can safely continue in place or be migrated to a native Time Machine destination before choosing a fresh start.
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
