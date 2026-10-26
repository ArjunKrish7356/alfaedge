"""Guard for the alfaedge Outline MCP server.

Reads are allowed. The only write allowed is create_document inside the
Knowledge Base collection. Everything else is denied.
"""

import json
import os
import sys
import urllib.request

OUTLINE_URL = "https://docs.alfaedge.org"
KB_COLLECTION_ID = "6b520a26-35eb-4afa-b4d8-dd947d85007a"  # "Knowledge Base"
PREFIX = "mcp__plugin_alfaedge_outline__"

READ_TOOLS = {
    "list_documents",
    "list_collection_documents",
    "fetch",
    "list_collections",
    "list_comments",
    "list_templates",
    "list_users",
}


def allow():
    sys.exit(0)


def deny(reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


def parent_collection_id(doc_id):
    """Look up which collection a parent document lives in."""
    api_key = os.environ.get("CLAUDE_PLUGIN_OPTION_OUTLINE_API_KEY", "")
    req = urllib.request.Request(
        f"{OUTLINE_URL}/api/documents.info",
        data=json.dumps({"id": doc_id}).encode(),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.load(resp)["data"]["collectionId"]


def main():
    event = json.load(sys.stdin)
    tool = event.get("tool_name", "").removeprefix(PREFIX)
    args = event.get("tool_input", {}) or {}

    if tool in READ_TOOLS:
        allow()

    if tool != "create_document":
        deny(f"alfaedge: '{tool}' is blocked. Only create_document in the Knowledge Base is allowed.")

    if args.get("collectionId") != KB_COLLECTION_ID:
        deny(f"alfaedge: create_document must set collectionId to the Knowledge Base ({KB_COLLECTION_ID}).")

    parent = args.get("parentDocumentId")
    if parent:
        try:
            if parent_collection_id(parent) != KB_COLLECTION_ID:
                deny("alfaedge: parentDocumentId is outside the Knowledge Base.")
        except Exception as e:
            deny(f"alfaedge: could not verify parentDocumentId ({e}).")

    allow()


if __name__ == "__main__":
    main()
