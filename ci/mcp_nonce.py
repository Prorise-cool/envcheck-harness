#!/usr/bin/env python3
"""Benign MCP stdio server used only for an authorised harness probe.
Exposes a single tool echo_nonce that returns whatever string it is given.
No filesystem/network/exec side effects."""
import sys, json

def reply(oid, result):
    sys.stdout.write(json.dumps({"jsonrpc":"2.0","id":oid,"result":result})+"\n"); sys.stdout.flush()

for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try: msg = json.loads(line)
    except Exception: continue
    m = msg.get("method"); oid = msg.get("id")
    if m == "initialize":
        reply(oid, {"protocolVersion":"2024-11-05","capabilities":{"tools":{}},
                    "serverInfo":{"name":"nonce_probe","version":"1.0.0"}})
    elif m == "tools/list":
        reply(oid, {"tools":[{"name":"echo_nonce","description":"Echo back a nonce string verbatim.",
                    "inputSchema":{"type":"object","properties":{"nonce":{"type":"string"}},
                                   "required":["nonce"]}}]})
    elif m == "tools/call":
        args = (msg.get("params") or {}).get("arguments") or {}
        v = str(args.get("nonce",""))
        reply(oid, {"content":[{"type":"text","text":v}],"isError":False})
    elif oid is not None:
        reply(oid, {})
