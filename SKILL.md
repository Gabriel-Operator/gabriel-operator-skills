---
name: gabriel-operator
description: >
  Central Gabriel Operator gateway skill for coding agents. Use this to discover,
  run, and configure AI Personas, AI operators, data lists, and asset-library
  items through the Gabriel REST API or MCP gateway before reaching for
  specialized git-backed skills.
metadata:
  author: gabriel-operator
  version: "1.3.1"
---

# Gabriel Operator Gateway Skill

## Offline-first environment

Read [the embedded runtime contract](references/offline-runtime-v1.md) before choosing an API. Discover the active environment and its capability report first. In embedded local mode, use device repositories and local execution adapters; do not silently switch to the gateway when a step is blocked. Explain that synchronization is manual and identify which requested effects still need connectivity.

## Goal

Use the Gabriel Operator gateway as the first control plane for a user's workspace.
The gateway exposes the same workspace concepts users see in Gabriel Operator:

- AI Personas / personas / pages
- AI operators and workflow runs
- Data lists
- Generated media and asset-library items
- Skill instructions for deeper git-backed edits

Use this central skill before asking the user to install separate
`digital-twin-page`, `workflow-builder`, `asset-library`, or `list-builder`
skills. Those specialized skills are still useful for direct repository edits,
but the gateway is the unified runtime/API entrypoint.

To **create** a new AI Persona from a description (page, lists, pipeline,
workflows, git, team agents, publish), use the `persona-builder` skill. Request
it with `gabriel_get_skill_instructions` and topic `persona-builder`.

To edit the Persona's semantic entity/attribute/relationship contract, request topic `persona-ontology` (alias `ontology`). It maintains the parent app's single `assets/ontology.json` and validates Data Feed references without migrating runtime rows or replacing state machines.

To **deploy a published candidate to a local computer** (DGX Spark / RTX Linux),
use topic `portable-persona-runtime` or install
[`Gabriel-Operator/portable-persona-runtime`](https://github.com/Gabriel-Operator/portable-persona-runtime).
That is the full local appliance path, not the prompt-only `persona-export` kit.

## Authentication

All calls require a Gabriel API token:

```http
Authorization: Bearer gabi_<token>
```

Use only the scopes needed for the task:

| Scope | Use |
|---|---|
| `api:access` | REST gateway reads, data lists, and asset-library operations. |
| `mcp:access` | MCP gateway connection. |
| `digital-twin:chat` | Chat with an AI Persona. |
| `digital-twin:tools` | Let an AI Persona use its configured tools. |
| `digital-twin:admin` | Create and configure personas, lists, pipelines, git bindings, and team agents. |
| `digital-twin:media` | List, save, or delete media assets. |
| `automation:read` | List AI operators and read run status. |
| `automation:run` | Start AI operator runs. |

Never ask the user for a password or browser session when a scoped `gabi_` token
can perform the task. Do not print the raw token. Do not ask the user to paste
the raw token into chat.

### If the token is missing

Do not start Gateway work. Stop and tell the user how to get a workspace
`gabi_` token:

1. Open https://gabrieloperator.com/signup (or **Sign up** on the homepage).
   First visit creates an account when they sign in.
2. Sign in with email code, Google, Apple, or phone.
3. Open **Workspace → Dashboard** (`/workspace/dashboard`).
4. Top-right **Gateway API key** pill: click copy. The first copy mints a
   Dashboard (MCP Gateway) token that starts with `gabi_`.
5. Connect it as MCP `Authorization: Bearer gabi_…` on
   `https://gabrieloperator.com/mcp/gateway`, or set `GABRIEL_TOKEN` /
   `GABI_TOKEN`. Then continue.

If the pill is empty: **Generate new key**, or
https://gabrieloperator.com/workspace/developer-settings → **API Tokens** →
**Create New Token** → preset **MCP Gateway**.

Wait until MCP or the env var is connected before calling tools.

## MCP Setup

Add an MCP server named `gabriel`:

```json
{
  "mcpServers": {
    "gabriel": {
      "url": "https://gabrieloperator.com/mcp/gateway",
      "headers": {
        "Authorization": "Bearer gabi_<token>"
      }
    }
  }
}
```

For local development, replace the origin with the current server origin, for
example `http://localhost:3000/mcp/gateway`.

## REST Quickstart

List available resources:

```bash
curl https://gabrieloperator.com/api/gateway/resources \
  -H "Authorization: Bearer gabi_<token>"
```

Create a target-bound session:

```bash
curl -X POST https://gabrieloperator.com/api/gateway/sessions \
  -H "Authorization: Bearer gabi_<token>" \
  -H "Content-Type: application/json" \
  -d '{
    "targetType": "digital_twin",
    "targetId": "page_123",
    "metadata": { "agent": "codex" }
  }'
```

Run the AI Persona:

```bash
curl -X POST https://gabrieloperator.com/api/gateway/sessions/<sessionId>/messages \
  -H "Authorization: Bearer gabi_<token>" \
  -H "Content-Type: application/json" \
  -d '{ "message": "Summarize what you can do and list your available tools." }'
```

## MCP Tool Catalog

| Tool | Purpose |
|---|---|
| `gabriel_list_resources` | Discover AI Personas, AI operators, data lists, and recent assets. |
| `gabriel_create_session` | Create a target-bound gateway session. |
| `gabriel_run_twin` | Send a message to the session's AI Persona. |
| `gabriel_update_twin_config` | Patch safe chat/config fields for the session's AI Persona, including a complete validated Chat App and disabled portable Signal presets. |
| `gabriel_create_page` | Create a new AI Persona page. |
| `gabriel_publish_twin` | Publish an AI Persona. |
| `gabriel_mint_persona_key` | Mint a Persona Token for `/api/v1` (returned once). |
| `gabriel_setup_meetings` | Configure meeting notetaker settings for an AI Persona. |
| `gabriel_join_meeting` | Invite an AI Persona's configured meeting notetaker to a meeting URL. |
| `gabriel_list_meetings` | List recent meeting notetaker sessions for an AI Persona. |
| `gabriel_get_meeting` | Read status for a meeting notetaker session. |
| `gabriel_get_meeting_artifacts` | Fetch transcript, notes, and recording metadata for a completed meeting. |
| `gabriel_cancel_meeting` | Cancel a scheduled meeting notetaker session. |
| `gabriel_list_operators` | List AI operators visible to the token owner. |
| `gabriel_run_operator` | Start the operator bound to a session. |
| `gabriel_get_run_status` | Read the latest status for an operator run. |
| `gabriel_add_operator_action` | Add a workflow action. When `agentId` is a persona `pageId`, this mints a slash command (same as `gabriel_create_operator_command`). |
| `gabriel_create_operator_command` | Create a persona slash command + linked action (`sourceMetadata.kind = persona_slash_command`). Required before promote will list the workflow. |
| `gabriel_create_git_repository` | Create a GitHub repo on the connected account. Fails with GITHUB_NOT_CONNECTED until GitHub is connected. |
| `gabriel_git_provisioning_status` | GitHub OAuth status + remembered AI Resources setup (managed / own / ask). Call before creating repos; if `needsChoice`, ask once. |
| `gabriel_set_git_provisioning_preference` | Remember managed / own / ask (`null`) so git setup is not asked again. Users can also set this at `/workspace/settings?section=preferences`. |
| `gabriel_provision_managed_git` | Create and bind Gabriel-managed git without the caller's GitHub. |
| `gabriel_run_canvas_playbook` | Replay a captured canvas playbook for an AI Persona. |
| `gabriel_list_data_lists` | List workspace data lists, optionally for a page. |
| `gabriel_update_data_list` | Patch metadata/schema fields for the session's data list. |
| `gabriel_create_data_list` | Create a list and collection. Pass `pageId`. Schema only — seed rows with `gabriel_upsert_list_records`. |
| `gabriel_upsert_list_records` | Insert or update live list rows. Pipeline lists stamp `_workflowState` (default: initial stage). |
| `gabriel_get_list_records` | Read live list rows and their pipeline stage. |
| `gabriel_create_pipeline` | Create a pipeline/machine. Follow with `gabriel_update_pipeline_stages`. |
| `gabriel_list_pipelines` | List pipelines (includes `transitionIds`). |
| `gabriel_get_pipeline` | Inspect the live machine chat will execute. |
| `gabriel_sync_pipeline_from_git` | Force-pull bound `assets/pipeline.json` into the live projection. |
| `gabriel_update_pipeline_stages` | Replace stages and transitions together. `transitions` is required. Writes git when bound. |
| `gabriel_initialize_page_git` | OAuth-backed page git binding + scaffold. |
| `gabriel_initialize_list_git` | Bind a list repo. |
| `gabriel_initialize_pipeline_git` | Bind a pipeline repo. |
| `gabriel_initialize_workflow_git` | Bind one action's workflow repo (`actionId` required). |
| `gabriel_create_team_agent` | Create a page-scoped event team-agent endpoint. |
| `gabriel_initialize_team_agent_git` | Bind that endpoint to git and scaffold `team-agents`. |
| `gabriel_promote_workspace` | Assign portable resource keys and write registry v2 (Workflow + Pipeline + List only). |
| `gabriel_validate_workspace` | Validate the bundle — read `ok`, not HTTP status. |
| `gabriel_publish_workspace` | Pin submodule revisions on the persona root. |
| `gabriel_list_assets` | List generated media and external asset-library items. |
| `gabriel_save_asset` | Save generated media or external URLs into the asset library. |
| `gabriel_upload_asset` | Upload raw image bytes (`dataUrl`) and get back a hosted URL — e.g. for `profilePicture`/`bannerImage`. |
| `gabriel_delete_asset` | Delete an asset owned by the token owner. |
| `gabriel_get_skill_instructions` | Get central or specialized skill guidance (`persona-builder`, `digital-twin-page`, …). |

## Standard Workflow

1. Call `gabriel_list_resources`.
2. Select a target by id.
3. Call `gabriel_create_session` with the target type and id.
4. Run exactly the operation the user requested.
5. Use `gabriel_get_run_status` for operator runs until a terminal state is reached.
6. Summarize the outcome using user-facing names, not raw internal ids unless the user asked for ids.

Session-bound runs and modifications must use a session id. Page-scoped tools
that take `pageId` directly, including `gabriel_run_canvas_playbook`, do not
require a gateway session.

## Asset validation hook (recommended)

Every Gabriel asset type ships a validator, and the skills tell you to run it before
committing. That instruction is prose — it carries no execution guarantee, and a skipped
validation surfaces much later, at `gabriel_validate_workspace`, at publish, or only when the
bundle is imported into another environment. The most common casualty is an environment-local
id (`pageId`, `listId`, `actionId`) written into a portable definition, which makes the
persona unpublishable.

This pack ships a `PostToolUse` hook that runs the matching validator automatically after you
write a Gabriel asset:

`skills/gabriel-operator/hooks/validate-gabriel-asset.js`

It maps `assets/list.json`, `assets/pipeline.json`, `assets/todos.json`,
`assets/embed-config.json`, `assets/persona-evals.json`, and the persona repo's
`assets/chat-config.json` / `references/registry.json` to the right validator, prefers the
copy checked into the repo you are editing, and exits 0 for anything it does not recognize.

If your agent does not load `skills/gabriel-operator/hooks/hooks.json` automatically, register
it once in Claude Code settings (`~/.claude/settings.json` or the project's
`.claude/settings.json`):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/skills/gabriel-operator/hooks/validate-gabriel-asset.js\""
          }
        ]
      }
    ]
  }
}
```

Point `command` at the absolute path of the script if `${CLAUDE_PLUGIN_ROOT}` is not set in
your agent. The hook never edits files and never uses the network.

## AI Persona Rules

Use `gabriel_run_twin` for persona chat, connected-tool use, and questions about
what the twin can do.

Use `gabriel_update_twin_config` only when the user explicitly asks to change the
twin configuration. This maps to the safe chat/config fields exposed by Gabriel's
configuration UI. Do not attempt unrestricted database updates.

When authoring Signals, update the complete validated `chatApp` definition. Put
`signalPresets` only on its `provider: "automations"` workspace data point. Each
preset is a disabled draft and may reference only a portable list resource key
and a declared command action ID. The runner later configures, tests, enables,
pauses, and inspects it through the persona-bound `persona_coach_*` app tools;
never write runtime automation IDs, observations, history, credentials, or
enabled state through the workspace Gateway.

To provision a **new** persona from a description (lists, pipeline, workflows,
git, team agents, publish), load topic `persona-builder` and follow that
interview + build order. Create lists and pipelines before any config that
stores their ids.

For deep git-backed page edits after repos exist, request
`gabriel_get_skill_instructions` and then use the `digital-twin-page` skill.

## Meeting Note Taker Rules

Use `gabriel_join_meeting` when the user asks to invite a notetaker to a Google
Meet, Zoom, Microsoft Teams, Slack huddle, or other Recall-supported HTTPS
meeting URL.

The target AI Persona must already have Meeting Note-Takers enabled. Prefer
author-provided credentials when configured; if the tool reports that a BYOK
Recall connection is required, ask the user for the connection id rather than
asking for raw API keys.

Use `gabriel_list_meetings`, `gabriel_get_meeting`, and
`gabriel_get_meeting_artifacts` to check progress and retrieve notes. Use
`gabriel_cancel_meeting` only when the user clearly asks to cancel a scheduled
meeting session.

## AI Operator Rules

Use `gabriel_list_operators` to discover available operators.

Use `gabriel_create_session` with `targetType: "operator"`. The `targetId` can be
the operator id, or `agentId:actionId` when a separate action id is known.

Use `gabriel_run_operator` with `parameters` for any required inputs. Then use
`gabriel_get_run_status` until the run is completed, failed, cancelled, or paused.

For direct workflow repository edits, request specialized instructions and then
use the `workflow-builder` skill.

## Canvas Playbook Rules

Use `gabriel_run_canvas_playbook` when the user supplies a canvas playbook id or
asks to replay a captured canvas skill. Pass `pageId`, `playbookId`,
`replayProfile`, and the playbook's parameter values. Use `dynamic` to regenerate
from the parameter mapping. Use `full` with `chunkPrompts` to replay the pinned
step prompts. Approval gates remain enabled for MCP launches.

To **author** a form-fill / capture-and-fill Canvas slash command, load
`workflow-builder` (Rule 4), `digital-twin-page`, and `pipeline-builder`. Collect
is `channels_only`: runtime presents **Answer here**, **Talk**, and **Chat**, and
prefills drafts from the List, signed-in profile, and `memoryConfig`. Do not add
`in_app_chat` to `allowedChannels` or a prefill toggle to `chat-config.json`.

## Data List Rules

Use `gabriel_list_data_lists` for discovery and `gabriel_update_data_list` for
metadata/schema patches. Do not edit child lists directly when the gateway returns
a read-only or child-list error.

For git-backed list definition edits, use the `list-builder` skill after the
gateway confirms the list and repository context.

## Asset Library Rules

Use `gabriel_list_assets` to search or inspect media assets.

Use `gabriel_save_asset` only for durable generated media or external URLs the
user wants to keep in Gabriel. Include `prompt`, `type`, and useful display
metadata when available.

Use `gabriel_upload_asset` when you have image bytes in hand (a generated
image, an uploaded file) rather than an existing URL — it returns a hosted
URL you can write into `pageProfile.profilePicture`/`bannerImage` or use
anywhere else a URL is needed.

Use `gabriel_delete_asset` only when the user clearly requests deletion.

For git-backed asset manifest edits, use the `asset-library` skill after the
gateway confirms the asset-library context.

## UI fallback when Gateway or MCP cannot do it

Prefer gateway/MCP tools first. If the tool is missing, returns 404 / not
implemented, needs a browser OAuth or third-party API key, or keeps failing
after a real Gateway attempt, do not invent a workaround and do not ask the
user to paste vendor secrets into chat.

Hand the user the **Edit persona / Configure** screen, with a clickable URL
that includes the `pageId` you already have.

Personal workspace (same destination as the **Configure** button on the persona
page):

https://gabrieloperator.com/workspace/edit-persona/{pageId}

Business workspace:

https://gabrieloperator.com/c/{teamSlug}/{unitSlug}/edit-persona/{pageId}

Deep links the app honors:

| Need | URL |
|---|---|
| Composio / Arcade / Nango / Scalekit keys | `.../edit-persona/{pageId}?tab=simulated-world` then expand **MCP connectors** |
| Default LLM | `.../edit-persona/{pageId}?tab=simulated-world&section=llm-model` |
| Features (voice, computer, …) | `.../edit-persona/{pageId}?tab=input` |
| Slash commands / Canvas agents | `.../edit-persona/{pageId}?tab=ai-agents` |
| Lists / pipelines | `.../edit-persona/{pageId}?tab=pipelines-workflows` |
| Experience / output | `.../edit-persona/{pageId}?tab=output` |
| Phone / inbox / chat apps | `.../edit-persona/{pageId}?tab=reach` (`&section=phone`, `inbox`, or `chat-integrations`) |
| GitHub not connected | https://gabrieloperator.com/workspace/developer-settings |
| Runner toolkit OAuth (Gmail, Sheets, Calendar) | https://gabrieloperator.com/workspace/ai-resources?pageId={pageId} then **Connected toolkits** |

There is no `?section=mcp` deep link. For Composio **keys**, send `tab=simulated-world`
and tell them to expand **MCP connectors**. For app **Connect** (OAuth), send the
AI Resources URL — not Edit Persona.

### When to use this

- Saving Composio, Arcade, Nango, or Scalekit keys (profile keys, not Gateway)
- Connecting GitHub (`GITHUB_NOT_CONNECTED`)
- Runner app OAuth (Gmail, Sheets, Calendar) on **AI Resources → Connected toolkits**
- Voice/provider BYOK, computer providers, or other credential UIs
- Any configure field with no matching `gabriel_*` tool
- GitHub OAuth / “open Developer Settings and approve” flows

### Composio keys (common case)

Gateway cannot create the Composio API key. The user must do it in the UI:

1. Open
   https://gabrieloperator.com/workspace/edit-persona/{pageId}?tab=simulated-world
2. Or open the persona page and click **Configure**.
3. On the **Tools** tab, expand **MCP connectors**.
4. Choose **Composio**, add a key (label + API key), Save, then enable the
   toolkits they need.
5. After they confirm the key is saved and those toolkits are enabled,
   continue with MCP/REST.

Do **not** ask them to Connect Gmail, Sheets, Calendar, or any other app on
**Edit Persona / Tools**. Enabling a toolkit there only publishes which apps
the persona may use.

**Connect accounts on this persona's AI Resources page.** From chat, click
**Connect** or **Connected** (not Configure), or open
https://gabrieloperator.com/workspace/ai-resources?pageId={pageId}.
On **Connected toolkits**, click **Connect** on each card and finish OAuth.
Canvas then uses those same connections. They can also Connect when a canvas
stage asks. Connecting only in the Composio dashboard does not count.

Screenshot:
https://gabrieloperator.com/assets/docs/ai-resources-connected-toolkits.jpg

Give the full `https://` URL. Name the tab and the control. Wait, then retry.
Never print or store the vendor secret.

## Safety

- Prefer gateway/MCP tools. If Gateway cannot do it, send the user to Edit
  persona / Configure with the page URL (see **UI fallback when Gateway or MCP cannot do it**).
- Never store or print raw token values except when the user has just created one
  and is explicitly configuring their local agent.
- Do not claim an operation succeeded unless the gateway returned success.
- Do not store prompt or request payload bodies in audit logs.
- Use scoped sessions for every concrete action.

## Persona mobile apps

For model-owned native app configuration, branding and local or user-owned GitHub
builds, request `gabriel_get_skill_instructions` with topic `mobile-app-builder`.

## Persona integration support

Use `gabriel_list_integrations` to discover actual capabilities and workspace rollout status. `gabriel_test_integration` requires an existing digital-twin `sessionId` and owned `connectionId`. Configuration uses `gabriel_update_twin_config`; load skill topic `persona-integrations` for bindings, voice, and vision. Credentials are entered in the connection UI, never in chat or Git.

## Persona app composition discovery

When building or revising a signed-in Persona app, request child topics `chat-app-builder` and `persona-chat-app-layout` through `gabriel_get_skill_instructions` (REST: `/api/gateway/skill-instructions?topic=...`). Use a Home dashboard with a review-only Meet Persona coach and domain records/results/decisions, plus the standard minimal sidebar. Playbooks is sidebar-only, milestones/goals lives in Coach, and routines/Signals/Schedule lives in Signals. Never duplicate those as Home tabs or panels. Patch the complete validated `chatApp`, mirror `assets/chat-app.json` and `publishedConfig.chatApp`, then use workspace publication. Do not treat the public landing page or a slash command as the full authenticated app.

## Context-aware ontology

Use the parent persona’s `assets/ontology.json` for Global → country/region → one authenticated audience → language → terminology. Refer to [the ontology skill](../persona-ontology/SKILL.md) for snapshots, stable IDs, validation, preview and gateway/MCP authoring. Child resources reference that contract; stored instances and credentials remain in existing runtime storage. Preserve captured ontology selections during retries and downstream mappings. Saving an ontology candidate is separate from activation.

## Evidence-backed ROI

For a standard Persona app, include the domain ROI/Impact sidebar destination and connect it to the same landing calculator definitions via `publishedConfig.roiMonitoring`. Read [the ROI algorithm and evidence contract](../chat-app-builder/references/roi-evidence.md) or Gateway topic `persona-roi`: map committed output/List fields to the parent ontology, capture the semantic revision at execution, deduplicate stable identities, preserve acceptance/withdrawal boundaries and measure value with explicit runner baselines or evidenced economic rules. Credits/tokens/top-up funding are distinct; never sum them as one cost or call a budget/row count cash savings. Missing evidence/currency conversion keeps financial ROI unknown. Validate the model and real runner ROI before publication.

Signals uses the shared panel’s inner Signals/Planning controls; never add or show a duplicate outer Signals/Routines tab strip. Scheduled and legacy routines remain in that panel’s existing controls. Meet/Coach tabs must prefix the label with the current persona portrait, even when an older model has a generic AI icon. Configure the actual persona avatar, not the author’s photo.

ROI/Impact is sidebar-only. Use canonical `agents` (existing Kai `grocery-agents`) metadata as the standalone target; never display an ROI tab beside Meet/Coach.

## Opt-in Super Connector location discovery

`publishedConfig.peopleMatchingConfig.proximity` extends the existing matching feature.
Omission or `enabled: false` preserves existing personas (including Juno). Enable only
on a persona whose brief requests location discovery. Keep the full matching config;
do not replace participant/match targets, pairings, portable list refs or profile modes.

```json
{"enabled":true,"provider":"google_maps","defaultRadiusMeters":2000,"maxRadiusMeters":20000,"latitudeField":"latitude","longitudeField":"longitude","radiusField":"radiusMeters","schoolField":"schoolId","schoolModeIds":["schools"]}
```

Author two `profileExperience.modes` when requested: `neighborhood` and `schools`.
Use separate mode questions/navigation and a canonical school ID question for Schools.
The active mode comes from the authenticated runner's profile, never a caller-supplied
school or profile override. School IDs scope matching; they do not verify affiliation.
Store only definitions in Git; location, visibility consent and school answers are runtime data.
Do not seed real family locations or children’s identity/contact data in portable assets.

Runner surfaces (all use the same enforcement):
- Workspace MCP: `gabriel_search_nearby_people(pageId)` and
  `gabriel_set_matching_geofence(pageId, latitude, longitude, radiusMeters)`.
- Persona MCP: `persona_search_nearby_people()` and `persona_set_matching_geofence(...)`.
- Gateway REST: `GET /api/gateway/pages/:pageId/people-matching/nearby` and
  `PUT /api/gateway/pages/:pageId/people-matching/geofence`.
- Persona REST: `GET /api/v1/matches/nearby`, `PUT /api/v1/matches/geofence`,
  requiring `digital-twin:matches` and using the key's runner identity.
- Signed-in web/mobile: `/api/v1/pages/:pageId/people-matching/nearby` and `/geofence`.

A runner selects a location and radius on their active profile. Validate numeric
coordinates, radius >=100 m and <=the persona maximum (hard cap 50 km). Missing or
invalid coordinates fail closed. Filter with an exact great-circle distance after
the database bounding box. School mode also requires the same non-empty school ID;
profile modes never mix. Return only completed, explicitly visible profiles and
approximate pins, without contact details or exact home coordinates. Apply the same
rules to direct proposals, reactive matching, periodic scoring and shared-pool tool
queries. Existing double opt-in introduction/scheduling gates remain authoritative.

Google Maps configuration is always per persona. Configure it on Edit Persona →
Super Connector → Google Maps, or Publish App → Persona Apps. Never instruct the
user to put Maps keys or a Maps feature flag in a build environment. The shared
editor saves encrypted web/Android/iOS keys and map ID outside portable Git.

Author-only MCP: `gabriel_get_persona_maps_config` and
`gabriel_update_persona_maps_config` (`pageId`, optional `webApiKey`,
`androidApiKey`, `iosApiKey`, `mapId`), requiring `digital-twin:admin`.
GET/PUT `/api/gateway/pages/:pageId/maps-config` expose status/fingerprints and
save keys. Blank key inputs preserve current credentials. Runner discovery reads
only the chosen persona's settings; it cannot change author credentials.

Branded app manifest: `integrations.googleMaps = { enabled: true,
configurationSource: "persona" }`. This portable setting contains no raw key.
The publishing pipeline resolves saved persona settings into its native packaging
snapshot and stamps Android SDK metadata and iOS Info.plist automatically. Local
packaging resolves the same author-only `/maps-config/runtime` endpoint with the
existing Gabriel account authentication; it does not accept Maps environment keys.
Publish an updated mobile package after changing native SDK keys. SDK metadata is
checked through the native persona Maps bridge, not a Dart environment flag.
Web uses an isolated per-persona map frame so SPA navigation cannot reuse a different
persona's Google key. Match visibility, geofence and school gates remain server-owned.
Keep raw keys out of portable repositories, public landing repos, logs and prompts.

Required checks: disabled-feature compatibility, missing/invalid coordinates,
outside/boundary radius, antimeridian/poles, cross-mode/cross-school exclusion,
visibility revocation, runner isolation, map mobile layout, and API/MCP parity.
