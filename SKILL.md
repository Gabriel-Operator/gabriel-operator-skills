---
name: gabriel-operator
description: >
  Central Gabriel Operator gateway skill for coding agents. Use this to discover,
  run, and configure AI Personas, AI operators, data lists, and asset-library
  items through the Gabriel REST API or MCP gateway before reaching for
  specialized git-backed skills.
metadata:
  author: gabriel-operator
  version: "1.2"
---

# Gabriel Operator Gateway Skill

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
| `gabriel_update_twin_config` | Patch safe chat/config fields for the session's AI Persona. |
| `gabriel_create_page` | Create a new AI Persona page. |
| `gabriel_publish_twin` | Publish an AI Persona. |
| `gabriel_mint_persona_key` | Mint a persona-scoped `/api/v1` key (returned once). |
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
| `gabriel_create_data_list` | Create a list and collection. Pass `pageId`. |
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
| `gabriel_promote_workspace` | Assign portable resource keys and write registry v2. |
| `gabriel_validate_workspace` | Validate the bundle — read `ok`, not HTTP status. |
| `gabriel_publish_workspace` | Pin submodule revisions on the persona root. |
| `gabriel_list_assets` | List generated media and external asset-library items. |
| `gabriel_save_asset` | Save generated media or external URLs into the asset library. |
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

## AI Persona Rules

Use `gabriel_run_twin` for persona chat, connected-tool use, and questions about
what the twin can do.

Use `gabriel_update_twin_config` only when the user explicitly asks to change the
twin configuration. This maps to the safe chat/config fields exposed by Gabriel's
configuration UI. Do not attempt unrestricted database updates.

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
