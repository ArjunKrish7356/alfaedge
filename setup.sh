#!/usr/bin/env bash
# AlfaEdge plugin setup for Claude Code (macOS / Linux).
#
#   curl -fsSL https://raw.githubusercontent.com/ArjunKrish7356/alfaedge/master/setup.sh | bash
#
# Local test:  ALFAEDGE_SOURCE="$PWD" bash setup.sh

set -euo pipefail

SOURCE="${ALFAEDGE_SOURCE:-ArjunKrish7356/alfaedge}"
PLUGIN="alfaedge@alfaedge"
OUTLINE="https://docs.alfaedge.org"
SERVER="plugin:alfaedge:outline"

# stdin is the script itself under `curl | bash`, so read answers from the terminal.
TTY=/dev/tty

ok()   { printf '  \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✘\033[0m %s\n' "$*"; exit 1; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }
ask()  { local a; read -r -p "  $1 " a < "$TTY"; printf '%s' "$a"; }

# ── 1. Requirements ─────────────────────────────────────────────
step "1/6  Checking requirements"
for bin in claude curl python3; do
  command -v "$bin" >/dev/null 2>&1 || fail "'$bin' not found. Install it and re-run."
done
ok "claude, curl, python3 found"

# ── 2. Install / update plugin ──────────────────────────────────
step "2/6  Installing plugin"
if claude plugin list 2>/dev/null | grep -q "$PLUGIN"; then
  claude plugin marketplace update alfaedge >/dev/null 2>&1 || true
  claude plugin update "$PLUGIN" >/dev/null 2>&1 || true
  ok "already installed — updated to latest"
else
  claude plugin install alfaedge --marketplace "$SOURCE" -y >/dev/null \
    || fail "install failed. Run: claude plugin install alfaedge --marketplace $SOURCE"
  ok "installed $PLUGIN"
fi

# ── 3. API key ──────────────────────────────────────────────────
step "3/6  Outline API key"
NEED_KEY=1
key_saved() {
  claude plugin configure "$PLUGIN" --json 2>/dev/null | python3 -c \
    'import json,sys; sys.exit(0 if "outline_api_key" in json.load(sys.stdin).get("configured", []) else 1)'
}
if key_saved; then
  case "$(ask 'A key is already saved. Replace it? [y/N]')" in
    [yY]*) ;;
    *) NEED_KEY=0; ok "keeping saved key" ;;
  esac
fi

valid_key() {
  # Header goes in via stdin so the key never shows up in `ps`.
  local code
  code=$(printf 'Authorization: Bearer %s\n' "$1" | curl -s -o /dev/null -w '%{http_code}' \
    -X POST "$OUTLINE/api/auth.info" -H @- -H 'Content-Type: application/json' -d '{}') || code=000
  [ "$code" = "200" ]
}

if [ "$NEED_KEY" = 1 ]; then
  echo "  Create one at: $OUTLINE → Settings → API"
  for try in 1 2 3; do
    read -r -s -p "  Paste key (hidden): " KEY < "$TTY"; echo
    KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"
    KEY="${KEY#Bearer}"   # people often paste "Bearer ol_api_…"
    [ -z "$KEY" ] && { warn "empty key"; continue; }
    [[ "$KEY" == ol_api_* ]] || warn "key usually starts with ol_api_"
    if valid_key "$KEY"; then ok "key works with $OUTLINE"; break; fi
    warn "Outline rejected this key (try $try/3)"
    [ "$try" = 3 ] && fail "no valid key. Check it at $OUTLINE → Settings → API and re-run."
  done
  # Same storage as /plugin configure: secure store (macOS Keychain), not settings.json.
  python3 -c 'import json,sys; print(json.dumps({"outline_api_key": sys.argv[1]}))' "$KEY" \
    | claude plugin configure "$PLUGIN" --values-stdin >/dev/null \
    || fail "could not save key. Run /plugin configure $PLUGIN inside Claude Code."
  unset KEY
  ok "key saved to Claude's secure storage"
fi

# ── 4. MCP connection ───────────────────────────────────────────
step "4/6  Checking MCP connection"
# Run outside any repo so a project .mcp.json can't interfere.
STATUS="$(cd "$HOME" && claude mcp list 2>&1 | grep "$SERVER" || true)"
if echo "$STATUS" | grep -q "Connected"; then
  ok "$SERVER connected"
else
  fail "MCP not connected: ${STATUS:-server not found}"
fi

# ── 5. Tool test ────────────────────────────────────────────────
step "5/6  Testing a tool call (takes a few seconds)"
TOOL="mcp__plugin_alfaedge_outline__list_collections"
OUT="$(cd "$HOME" && claude -p "Call $TOOL once. Reply with only the number of collections, or FAIL if it errors." \
  --allowedTools "$TOOL" 2>&1 || true)"
if [[ "$OUT" =~ ^[[:space:]]*[0-9]+[[:space:]]*$ ]]; then
  ok "list_collections works ($(echo "$OUT" | tr -d '[:space:]') collections visible)"
else
  warn "tool test unclear: $(echo "$OUT" | head -3)"
fi

# ── 6. Done ─────────────────────────────────────────────────────
step "6/6  Done 🎉"
echo "  You can start Claude Code now:  claude"
echo "  Try:  /alfaedge:kb-find <topic>"
