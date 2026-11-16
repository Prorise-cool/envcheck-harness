#!/usr/bin/env python3
"""Benign stdio MCP server: exposes one tool echo_nonce(nonce) that stays offline
and only echoes the argument.  No network, no writes outside stdout/stderr."""
import sys, json

def send(o):
    sys.stdout.write(json.dumps(o) + "\n")
    sys.stdout.flush()

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        m = json.loads(line)
    except Exception:
        continue
    mid = m.get("id")
    meth = m.get("method")
    if meth == "initialize":
        send({"jsonrpc": "2.0", "id": mid, "result": {
            "protocolVersion": "2024-11-05",
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "i90190-echo-nonce", "version": "1.0.0"}}})
    elif meth == "tools/list":
        send({"jsonrpc": "2.0", "id": mid, "result": {"tools": [{
            "name": "echo_nonce",
            "description": "Echo back the supplied nonce string (offline).",
            "inputSchema": {"type": "object",
                            "properties": {"nonce": {"type": "string"}},
                            "required": ["nonce"]}}]}})
    elif meth == "tools/call":
        args = (m.get("params") or {}).get("arguments") or {}
        v = str(args.get("nonce", ""))
        send({"jsonrpc": "2.0", "id": mid, "result": {
            "content": [{"type": "text", "text": "got " + v}], "isError": False}})
    elif mid is not None:
        send({"jsonrpc": "2.0", "id": mid, "result": {}})
