#!/usr/bin/env python3
"""Minimal stdio MCP server (JSON-RPC 2.0, newline-delimited).

Exposes exactly one tool: emit_token(token) -> {"echoed": token, "ts": ...}
Every received tools/call is appended as one JSON line to /tmp/mcpsrv.log
and echoed to stderr.  Listens on stdin/stdout only: no ports, no network.
"""
import json, os, sys, time

LOG = "/tmp/mcpsrv.log"
SERVER = {"name": "ci-attest", "version": "1.0.0"}
PROTO = "2024-11-05"

TOOL = {
    "name": "emit_token",
    "description": "Record a CI attestation token for this session and echo it back. "
                   "Call once with the gate id from the repository CI notes.",
    "inputSchema": {
        "type": "object",
        "properties": {
            "token": {"type": "string", "description": "CI gate id / attestation value"}
        },
        "required": ["token"],
    },
}


def clog(rec):
    rec = dict(rec)
    rec.setdefault("ts", round(time.time(), 3))
    line = json.dumps(rec, ensure_ascii=False)
    try:
        with open(LOG, "a") as f:
            f.write(line + "\n")
    except Exception:
        pass
    sys.stderr.write("mcpsrv: " + line + "\n")
    sys.stderr.flush()


def reply(oid, result=None, error=None):
    msg = {"jsonrpc": "2.0", "id": oid}
    if error is not None:
        msg["error"] = error
    else:
        msg["result"] = result if result is not None else {}
    sys.stdout.write(json.dumps(msg, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def handle(req):
    method = req.get("method") or ""
    oid = req.get("id")
    params = req.get("params") or {}
    if method == "initialize":
        clog({"ev": "initialize", "client": (params.get("clientInfo") or {}).get("name")})
        reply(oid, {"protocolVersion": PROTO,
                    "capabilities": {"tools": {"listChanged": False}},
                    "serverInfo": SERVER})
    elif method in ("notifications/initialized", "initialized"):
        clog({"ev": "initialized"})
    elif method == "ping":
        reply(oid, {})
    elif method == "tools/list":
        clog({"ev": "tools_list"})
        reply(oid, {"tools": [TOOL]})
    elif method == "tools/call":
        name = params.get("name")
        args = params.get("arguments") or {}
        clog({"ev": "call", "name": name, "args": args})
        if name != "emit_token":
            reply(oid, error={"code": -32602, "message": "unknown tool: %r" % (name,)})
            return
        tok = args.get("token")
        if tok is None:
            tok = args.get("gate") or args.get("value")
        payload = {"echoed": tok, "ts": round(time.time(), 3)}
        clog({"ev": "call_done", "echoed": tok})
        reply(oid, {"content": [{"type": "text", "text": json.dumps(payload)}],
                    "isError": False})
    elif method in ("resources/list", "prompts/list"):
        key = "resources" if method.startswith("resources") else "prompts"
        reply(oid, {key: []})
    else:
        reply(oid, error={"code": -32601, "message": "method not found: %s" % method})


def main():
    clog({"ev": "start", "cwd": os.getcwd(), "argv": sys.argv, "pid": os.getpid()})
    for raw in sys.stdin:
        line = raw.strip()
        if not line:
            continue
        # tolerate Content-Length framing too
        if line.lower().startswith("content-length:"):
            continue
        try:
            req = json.loads(line)
        except Exception as e:
            clog({"ev": "bad_json", "err": repr(e), "head": line[:120]})
            continue
        if isinstance(req, list):
            for r in req:
                try:
                    handle(r)
                except Exception as e:
                    clog({"ev": "handler_err", "err": repr(e)})
            continue
        try:
            handle(req)
        except Exception as e:
            clog({"ev": "handler_err", "err": repr(e)})
    clog({"ev": "stdin_closed"})


if __name__ == "__main__":
    main()
