# AlfaEdge

AlfaEdge team tools for Claude Code: search and write docs in the Outline knowledge base.

## Skills

- `kb-find`: search the Outline knowledge base
- `kb-write`: write docs to the Outline knowledge base

## Setup (macOS / Linux)

**Before you start:**
- [Claude Code](https://claude.com/claude-code) installed (`claude` works in your terminal)
- `curl` and `python3`
- An Outline API key: https://docs.alfaedge.org → Settings → API

**Run in your terminal:**

```
curl -fsSL https://raw.githubusercontent.com/ArjunKrish7356/alfaedge/master/setup.sh | bash
```

**What it does:**

```
1/6  check claude, curl, python3
2/6  install the alfaedge plugin   (already installed → update)
3/6  ask for your Outline API key  (hidden input)
       ├ tests the key against docs.alfaedge.org
       └ saves it to Claude's secure storage (macOS Keychain)
4/6  check the Outline MCP server connects
5/6  test one Outline tool call
6/6  done → start Claude Code: claude
```

- Paste only the key (starts with `ol_api_`). If you paste `Bearer …`, the script strips it.
- Safe to re-run: it updates the plugin and asks before replacing a saved key.

### Manual install (alternative)

Inside Claude Code:

```
/plugin marketplace add ArjunKrish7356/alfaedge
/plugin install alfaedge@alfaedge
```

Paste the bare key when asked (no `Bearer`).

## Troubleshooting

| Problem | Fix |
|---|---|
| `401 Bad Authorization header format` / key rejected | Re-run the setup script and enter a fresh key |
| MCP not connected after changing the key | `/mcp` → `alfaedge:outline` → reconnect, or restart Claude Code (`/reload-plugins` alone does **not** retry a failed server) |
| `claude` / `python3` not found | Install it, then re-run the setup script |