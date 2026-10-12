# Media MCP and paired execution

Use `gabriel_get_media_capabilities({pageId})` to discover enabled operations and
`gabriel_get_media_execution_status({pageId})` to check the paired runtime. Gateway
tools require `pageId`; bound-persona tools have the same stems with `persona_`.

Available families cover generation (image/video/audio), video/audio editing and
extension, asset import/content, projects/timeline commands, edit-session drafts
and review, undo/redo, rendering, job status and cancellation. Long operations
return jobs. Disconnected execution remains `waiting_for_executor`; never run
processing on the hosted application server as a fallback.

Use stable asset IDs, explicit execution/artifact references, public URLs or opaque
paired-local handles. A remote MCP call does not gain access to the caller's disk.
Saved-project edits require `expectedRevision`. Fetch a conversational draft's
preview and summary, obtain user approval, then approve its exact session revision.
Reject or refresh stale drafts; preserve originals.

Only completed jobs with final media artifacts count as completed rendering. Use
`gabriel_get_media_content` for authenticated references. Reuse accepted provider
receipts and idempotency keys rather than submitting/charging again.

`gabriel_create_page` accepts `templatePageId`, `templateRevision` and
`idempotencyKey`. Runtime credentials and device bindings are not copied.
Inspect the returned skill/dependency inventory and setup requirements. Complete pinned
packages include scripts, references and assets; pairing, paths and runtime credentials
must be resolved in the new persona, not copied from its source.

The companion supports a pinned `--workspace-id` and explicit local Codex/Claude Code
credentials/version via `--harness`, `--harness-version`, `--harness-api-key-env`.
Global login state is not mounted. Installed skills are read-only; upload genuine
motion/media outputs and use their asset IDs in timeline commands.

Full local Remotion and dual-MCP round trips pass using isolated persistence/model
fixtures. Live provider/cloud/full-account checks, Desktop OAuth reuse, migration of
every legacy Canvas coding stage, and cloned-persona update provisioning remain open.
Do not advertise an unverified dedicated cloud adapter. See the repository's
`docs/implementation/archer-media-execution.md` for acceptance commands and limitations.
