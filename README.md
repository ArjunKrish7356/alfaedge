# AlfaEdge

AlfaEdge team tools for Claude Code: search and write docs in the Outline knowledge base.

## Install

```
/plugin marketplace add ArjunKrish7356/alfaedge
/plugin install alfaedge@alfaedge
```

On install you'll be asked for an Outline API key. Create one at https://docs.alfaedge.org → Settings → API.

- Paste only the key (starts with `ol_api_`).
- Do **not** type `Bearer` — the plugin adds it.

## Troubleshooting

`401 Bad Authorization header format`:

1. Key was entered with `Bearer ` in front, or is wrong/expired.
2. Re-enter the bare key in the plugin config.
3. Open `/mcp` → select `alfaedge:outline` → reconnect (or restart Claude Code).
   - `/reload-plugins` alone does **not** retry a server that already failed.

## Skills

- `kb-find`: search the Outline knowledge base
- `kb-write`: write docs to the Outline knowledge base
