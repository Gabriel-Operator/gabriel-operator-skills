# MCP Gateway Reference

## Connection

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

For local development, replace the origin with your server origin, for example `http://localhost:3000/mcp/gateway`.

## Required token scopes

| Scope | Use |
|---|---|
| `api:access` | REST gateway reads, data lists, and asset-library operations. |
| `mcp:access` | MCP gateway connection. |
| `digital-twin:chat` | Chat with a digital twin. |
| `digital-twin:tools` | Let a digital twin use its configured tools. |
| `digital-twin:admin` | Patch digital twin configuration and lifecycle tools. |
| `digital-twin:media` | List, save, or delete media assets. |
| `automation:read` | List AI operators and read run status. |
| `automation:run` | Start AI operator runs. |

Create an **MCP Gateway** preset token in your Gabriel profile Developer settings.

## MCP vs REST config shape

- **MCP** `gabriel_update_twin_config` expects `{ sessionId, config: { ...fields } }`.
- **REST** `PATCH /api/gateway/sessions/:sessionId/twin-config` expects a flat JSON body with the config fields.

## Standard workflow

1. `gabriel_list_resources`
2. `gabriel_create_session` with `targetType` and `targetId`
3. Run the operation (`gabriel_run_twin`, `gabriel_run_operator`, etc.)
4. `gabriel_get_run_status` for operator runs until terminal state

## Audit

Every gateway tool call is logged server-side. Use `gabriel_list_audit_logs` or `GET /api/gateway/audit-logs` to inspect recent activity.
