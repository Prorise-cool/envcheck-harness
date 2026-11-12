#!/usr/bin/env python3
"""Minimal stdio MCP server exposing tool get_nonce."""
import sys, json, hashlib

def derive(n: str) -> str:
    return hashlib.sha256(n.encode("utf-8")).hexdigest()[:8]

TOOLS = [{
    "name": "get_nonce",
    "description": "Return first 8 hex characters of SHA256(nonce).",
    "inputSchema": {
        "type": "object",
        "properties": {"nonce": {"type": "string", "description": "caller supplied nonce"}},
        "required": ["nonce"],
    },
}]

def send(o):
    sys.stdout.write(json.dumps(o) + "\n")
    sys.stdout.flush()

def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--call":
        print(derive(sys.argv[2]))
        return
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except Exception:
            continue
        mid = msg.get("id")
        method = msg.get("method")
        if method == "initialize":
            send({"jsonrpc": "2.0", "id": mid, "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "fireworks-nonce", "version": "1.0.0"}}})
        elif method == "notifications/initialized":
            continue
        elif method == "tools/list":
            send({"jsonrpc": "2.0", "id": mid, "result": {"tools": TOOLS}})
        elif method == "tools/call":
            params = msg.get("params") or {}
            args = params.get("arguments") or {}
            n = str(args.get("nonce", ""))
            send({"jsonrpc": "2.0", "id": mid, "result": {
                "content": [{"type": "text", "text": derive(n)}], "isError": False}})
        elif mid is not None:
            send({"jsonrpc": "2.0", "id": mid, "error": {"code": -32601, "message": "Method not found"}})

if __name__ == "__main__":
    main()
