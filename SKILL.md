---
name: gabriel-operator
description: >
  Central Gabriel Operator gateway skill for coding agents. Use this to discover,
  run, and configure digital twins, AI operators, data lists, and asset-library
  items through the Gabriel REST API or MCP gateway before reaching for
  specialized git-backed skills.
metadata:
  author: gabriel-operator
  version: "1.0"
---

# Gabriel Operator Gateway Skill

## Goal

Use the Gabriel Operator gateway as the first control plane for a user's workspace.
The gateway exposes the same workspace concepts users see in Gabriel Operator:

- Digital twins / personas / pages
- AI operators and workflow runs
- Data lists
- Generated media and asset-library items
- Skill instructions for deeper git-backed edits

Use this central skill before asking the user to install separate
`digital-twin-page`, `workflow-builder`, `asset-library`, or `list-builder`
skills. Those specialized skills are still useful for direct repository edits,
but the gateway is the unified runtime/API entrypoint.

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
| `digital-twin:chat` | Chat with a digital twin. |
| `digital-twin:tools` | Let a digital twin use its configured tools. |
| `digital-twin:admin` | Patch digital twin configuration. |
| `digital-twin:media` | List, save, or delete media assets. |
| `automation:read` | List AI operators and read run status. |
| `automation:run` | Start AI operator runs. |

Never ask the user for a password or browser session when a scoped `gabi_` token
can perform the task.

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

Run the digital twin:

```bash
curl -X POST https://gabrieloperator.com/api/gateway/sessions/<sessionId>/messages \
  -H "Authorization: Bearer gabi_<token>" \
  -H "Content-Type: application/json" \
  -d '{ "message": "Summarize what you can do and list your available tools." }'
```

## MCP Tool Catalog

| Tool | Purpose |
|---|---|
| `gabriel_list_resources` | Discover digital twins, AI operators, data lists, and recent assets. |
| `gabriel_create_session` | Create a target-bound gateway session. |
| `gabriel_run_twin` | Send a message to the session's digital twin. |
| `gabriel_update_twin_config` | Patch safe chat/config fields for the session's digital twin. |
| `gabriel_setup_meetings` | Configure meeting notetaker settings for a digital twin. |
| `gabriel_join_meeting` | Invite a digital twin's configured meeting notetaker to a meeting URL. |
| `gabriel_list_meetings` | List recent meeting notetaker sessions for a digital twin. |
| `gabriel_get_meeting` | Read status for a meeting notetaker session. |
| `gabriel_get_meeting_artifacts` | Fetch transcript, notes, and recording metadata for a completed meeting. |
| `gabriel_cancel_meeting` | Cancel a scheduled meeting notetaker session. |
| `gabriel_list_operators` | List AI operators visible to the token owner. |
| `gabriel_run_operator` | Start the operator bound to a session. |
| `gabriel_get_run_status` | Read the latest status for an operator run. |
| `gabriel_list_data_lists` | List workspace data lists, optionally for a page. |
| `gabriel_update_data_list` | Patch metadata/schema fields for the session's data list. |
| `gabriel_list_assets` | List generated media and external asset-library items. |
| `gabriel_save_asset` | Save generated media or external URLs into the asset library. |
| `gabriel_delete_asset` | Delete an asset owned by the token owner. |
| `gabriel_get_skill_instructions` | Get central or specialized skill guidance. |

## Standard Workflow

1. Call `gabriel_list_resources`.
2. Select a target by id.
3. Call `gabriel_create_session` with the target type and id.
4. Run exactly the operation the user requested.
5. Use `gabriel_get_run_status` for operator runs until a terminal state is reached.
6. Summarize the outcome using user-facing names, not raw internal ids unless the user asked for ids.

Every run or modification must use a session id. Do not modify a digital twin,
operator, list, or asset directly without creating a gateway session first.

## Digital Twin Rules

Use `gabriel_run_twin` for persona chat, connected-tool use, and questions about
what the twin can do.

Use `gabriel_update_twin_config` only when the user explicitly asks to change the
twin configuration. This maps to the safe chat/config fields exposed by Gabriel's
configuration UI. Do not attempt unrestricted database updates.

For deep git-backed page edits, request `gabriel_get_skill_instructions` and then
use the `digital-twin-page` skill if the user has a connected repository.

## Meeting Note Taker Rules

Use `gabriel_join_meeting` when the user asks to invite a notetaker to a Google
Meet, Zoom, Microsoft Teams, Slack huddle, or other Recall-supported HTTPS
meeting URL.

The target digital twin must already have Meeting Note-Takers enabled. Prefer
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

## Safety

- Prefer gateway/MCP tools over browser UI control.
- Never store or print raw token values except when the user has just created one
  and is explicitly configuring their local agent.
- Do not claim an operation succeeded unless the gateway returned success.
- Do not store prompt or request payload bodies in audit logs.
- Use scoped sessions for every concrete action.
