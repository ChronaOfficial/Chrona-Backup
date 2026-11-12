# Project status

## Current phase

The older laptop's backup is now user-reported as completed. The newer image eventually connected and is user-reported as attempting a backup; completion is unknown. The targeted configuration comparison and subsequent primary-source research did not establish a failure cause. Leave this attempt running before considering further checks. The earlier OMV reuse proposal remains conditional. No server was installed, no sharing or backup setting changed by this project, and no stream or backup was interrupted.

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

2026-11-11, Windows side:

- Compared only the two user-selected folders, exact-path SMB share matches, anonymized top-level permission structures, and filesystem/capacity metadata. No backup contents, file listings, account names, raw logs, or client-session identifiers were collected.
- Core per-share settings matched. A folder-visibility setting and permission structure differed; neither establishes the failure cause. Existing archive-child permissions and Mac-side behavior were outside this check.
- Confirmed enum meanings from the installed PowerShell module and Microsoft documentation. Exact configuration and capacity measurements remain in ignored local notes, not this public handoff.
- The older backup's eventual completion remains to be reported by the user. A running backup is not treated as a verified recovery point. No additional container inspection, benchmark, repair, or configuration test ran.

2026-11-12, Windows side:

- User reports: the older backup completed; the newer image eventually connected and began attempting a backup. The user also reports updating the newer client and keeping it awake. These are observations of behavior, not an independently verified completion timestamp or a proven fix.
- Documentation research, including the explicitly requested helper agent, confirmed that sparsebundle is normal for network Time Machine backups. The earlier metadata check already established the newer container type. No further image inspection was performed.
- Hypotheses remain unproven: slow storage/metadata work or connection behavior could explain a delayed start. Available CPU headroom does not distinguish those causes. Neither an update nor sleep prevention establishes that the regression is fixed.
- In response to the user's PC-sleep question, read only the active power plan and its sleep/hibernate timeout fields. Exact settings remain local. No power setting, backup, share, network, or stream was changed.
- No backup completion or restoration was independently verified, and no performance test ran. Research sources and their limits are recorded in docs/PLAN.md.

## Next action

Continue from `codex/windows-omv-setup`. Let the newer backup attempt finish without additional live diagnostics or changes. A user-confirmed completed-backup timestamp, followed by successful automatic incrementals, is the next useful evidence; restore validation remains outstanding. If it fails, use only sanitized error wording and whether failure occurred at share connection, image attachment, or backup writing to scope the next check. Existing OMV storage, rollback, and maintenance requirements still apply. Do not restart broad diagnostics or infer permission to inspect, repair, rename, or take over backup storage.

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
