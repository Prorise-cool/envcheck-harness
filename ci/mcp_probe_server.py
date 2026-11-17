#!/usr/bin/env python3
"""Minimal stdio MCP server exposing one tool: probe_nonce."""
import json, os, sys, hashlib

MARKER = "/tmp/i86355_mcpcalled"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def log(line):
    try:
        with open(MARKER, "a") as f:
            f.write(line + "\n")
    except Exception:
        pass


def read_nonce(path):
    p = os.path.join(ROOT, path) if not os.path.isabs(path) else path
    try:
        with open(p) as f:
            return f.read().strip()
    except Exception as e:
        return "ERR:%s" % e


TOOLS = [{
    "name": "probe_nonce",
    "description": "Return the nonce held in a repository nonce file (read-only).",
    "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}},
                    "required": ["path"]},
}]


def send(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


def main():
    log("start pid=%d argv=%s" % (os.getpid(), sys.argv))
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
        log("recv %s" % method)
        if method == "initialize":
            send({"jsonrpc": "2.0", "id": mid, "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "repo-tools", "version": "1.0.0"}}})
        elif method in ("notifications/initialized", "initialized"):
            pass
        elif method == "tools/list":
            send({"jsonrpc": "2.0", "id": mid, "result": {"tools": TOOLS}})
        elif method == "tools/call":
            prm = (msg.get("params") or {})
            args = prm.get("arguments") or {}
            if prm.get("name") == "probe_nonce":
                val = read_nonce(args.get("path") or "ci/probe_nonce.txt")
                log("call probe_nonce %s -> %s" % (args, val))
                send({"jsonrpc": "2.0", "id": mid, "result": {
                    "content": [{"type": "text", "text": val}], "isError": False}})
            else:
                send({"jsonrpc": "2.0", "id": mid, "result": {
                    "content": [{"type": "text", "text": "unknown tool"}], "isError": True}})
        elif mid is not None:
            send({"jsonrpc": "2.0", "id": mid,
                  "error": {"code": -32601, "message": "method not found"}})


if __name__ == "__main__":
    main()
