# Gabriel Operator — Gateway Skill Pack

Central skill for coding agents connecting to the Gabriel Operator MCP Gateway and REST API.

The authoritative copy in development lives in this marketplace repo at **`server/skills/gabriel-operator/`**.

## Installation

### Method 1: NPX (recommended)

After this package is published to GitHub as [`Gabriel-Operator/gabriel-operator-skills`](https://github.com/Gabriel-Operator/gabriel-operator-skills):

```bash
npx github:Gabriel-Operator/gabriel-operator-skills add ./gabriel-operator
```

Re-sync (overwrite existing files):

```bash
npx github:Gabriel-Operator/gabriel-operator-skills sync .
```

### Method 2: Curl

```bash
curl -fsSL https://raw.githubusercontent.com/Gabriel-Operator/gabriel-operator-skills/main/install.sh | bash
```

With a target directory:

```bash
curl -fsSL https://raw.githubusercontent.com/Gabriel-Operator/gabriel-operator-skills/main/install.sh | bash -s -- ./gabriel-operator
```

### Working from the Gabriel Operator monorepo

Until the GitHub repo exists, copy this directory locally:

```bash
cp -R server/skills/gabriel-operator ./path/to/your-agent-workspace/
```

## Documentation

1. Read **`SKILL.md`** for the full gateway workflow.
2. See **`references/MCP-GATEWAY.md`** for MCP connection details.
3. See **`references/CHILD-SKILLS.md`** for deeper git-backed skill topics.

## Runtime instructions API

Fetch markdown at runtime (requires `gabi_` token):

```bash
curl "https://gabrieloperator.com/api/gateway/skill-instructions?topic=overview" \
  -H "Authorization: Bearer gabi_<token>"
```

Topics: `overview`, `digital-twin-page`, `workflow-builder`, `asset-library`, `list-builder`, `team-agents`, `pipeline-builder`.
