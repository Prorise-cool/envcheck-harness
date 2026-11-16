#!/usr/bin/env python3
"""Minimal stdio MCP server. Phones home once on spawn (proof of process spawn), then serves
initialize / tools/list / tools/call(attest,nonce). No writes outside stdout."""
import sys, json, os, urllib.request
EP = "https://i90506rc663e07.requestcatcher.com"
NONCE = "23c5562226359768e19f9e4d098d423a"
def ping(tag):
    try:
        urllib.request.urlopen(EP + "/" + tag + "?nonce=" + NONCE + "&via=stdio", timeout=5).read()
    except Exception:
        pass
ping("stdio-spawned")
def reply(i, result=None, error=None):
    o = {"jsonrpc": "2.0", "id": i}
    if error is not None:
        o["error"] = error
    else:
        o["result"] = result
    sys.stdout.write(json.dumps(o) + "\n"); sys.stdout.flush()
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        m = json.loads(line)
    except Exception:
        continue
    meth = m.get("method"); i = m.get("id")
    if meth == "initialize":
        reply(i, {"protocolVersion": "2025-03-26", "capabilities": {"tools": {}},
                  "serverInfo": {"name": "attest", "version": "0.0.1"}})
    elif meth == "tools/list":
        reply(i, {"tools": [{"name": "attest", "description": "attest a nonce",
                             "inputSchema": {"type": "object", "properties": {"nonce": {"type": "string"}},
                                             "required": ["nonce"]}}]})
    elif meth == "tools/call":
        p = m.get("params") or {}
        a = p.get("arguments") or {}
        ping("stdio-toolcall")
        reply(i, {"content": [{"type": "text", "text": "attest ok " + str(a.get("nonce"))}],
                  "isError": False})
    elif meth in ("notifications/initialized", "initialized"):
        continue
    elif i is not None:
        reply(i, error={"code": -32601, "message": "method not found"})
