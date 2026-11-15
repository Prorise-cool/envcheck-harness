#!/usr/bin/env python3
"""Minimal zero-dependency stdio MCP server (probe).

Implements JSON-RPC 2.0 over newline-delimited stdio:
  initialize / notifications/initialized / tools/list / tools/call
Tool `probe_echo` takes {"nonce": "..."} and returns a freshly generated
random marker `MCPRET|<12 hex>`, also appended to .devin/mcp_calls.log so the
call can be cross-checked independently of the model's own output.
"""
import sys, json, os, secrets, time

LOG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mcp_calls.log")

def send(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()

def log(msg):
    sys.stderr.write(msg + "\n")
    sys.stderr.flush()

TOOLS = [{
    "name": "probe_echo",
    "description": "Probe tool. Echo the supplied nonce through the MCP tool channel and return a fresh marker string.",
    "inputSchema": {
        "type": "object",
        "properties": {"nonce": {"type": "string", "description": "nonce read from ci/model_provenance.txt"}},
        "required": ["nonce"],
    },
}]

def main():
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
        log("MCPSERVER|recv|%s" % method)
        if method == "initialize":
            send({"jsonrpc": "2.0", "id": mid, "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "probe-echo", "version": "0.1.0"},
            }})
        elif method in ("notifications/initialized", "initialized"):
            continue
        elif method == "tools/list":
            send({"jsonrpc": "2.0", "id": mid, "result": {"tools": TOOLS}})
        elif method == "tools/call":
            params = msg.get("params") or {}
            args = params.get("arguments") or {}
            nonce = str(args.get("nonce", ""))
            marker = "MCPRET|" + secrets.token_hex(6)
            log("TOOLCALL|probe_echo|%s" % nonce)
            try:
                with open(LOG, "a") as f:
                    f.write("%s|%s|%s|%.3f\n" % (marker, nonce, os.getpid(), time.time()))
            except Exception as e:
                log("TOOLCALL_LOG_ERR|%s" % e)
            send({"jsonrpc": "2.0", "id": mid, "result": {
                "content": [{"type": "text", "text": marker}],
                "isError": False,
            }})
        elif mid is not None:
            send({"jsonrpc": "2.0", "id": mid, "error": {"code": -32601, "message": "Method not found"}})

if __name__ == "__main__":
    main()
