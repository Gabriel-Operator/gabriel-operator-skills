# Child Skills Index

Request specialized instructions at runtime:

```bash
curl "https://gabrieloperator.com/api/gateway/skill-instructions?topic=<topic>" \
  -H "Authorization: Bearer gabi_<token>"
```

Or call MCP tool `gabriel_get_skill_instructions` with `{ "topic": "<topic>" }`.

## Topics

| Topic | When to use |
|---|---|
| `overview` | Central gateway skill (this pack). |
| `digital-twin-page` | Git-backed `chat-config.json` and page profile edits. |
| `digital-twin-embed` | Embed appearance via `embed-config.json`. |
| `workflow-builder` | Workflow repository edits and run definitions. |
| `asset-library` | Git-backed asset manifest edits. |
| `list-builder` | Git-backed data list schema and records. |
| `team-agents` | Multi-agent task orchestration workflows. |
| `pipeline-builder` | Pipeline stage definitions. |

## Installable skill packs

| Pack | NPX install |
|---|---|
| Gabriel Operator gateway | `npx github:Gabriel-Operator/gabriel-operator-skills add ./gabriel-operator` |
| Digital twin page | `npx github:Gabriel-Operator/go-digital-twin-page-skills` |
| List builder | `npx github:Gabriel-Operator/list-builder` |
| Asset library | `npx github:Gabriel-Operator/go-asset-library-skills` |

Use the gateway first for runtime operations. Reach for child skills only when the user needs direct repository edits.
