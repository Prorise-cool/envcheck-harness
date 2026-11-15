#!/bin/sh
# i86336 — READ-ONLY internal reachability probe (whitelist only, serial, <=3 ports/host, <=3 paths)
# POSIX sh compatible (no bashisms). Optional $1 = tee file. No writes, no auth, no port scanning.
OUT="${1:-}"
python3 - "$OUT" <<'PY'
import socket, ssl, sys, os, json, time, hashlib, datetime, threading
for k in ("http_proxy","https_proxy","HTTP_PROXY","HTTPS_PROXY","ALL_PROXY","all_proxy"):
    os.environ.pop(k, None)
OUT = sys.argv[1] if len(sys.argv) > 1 else ""
class Tee(object):
    def __init__(self, path, stream):
        self.s = stream
        self.f = open(path, "w", encoding="utf-8") if path else None
    def write(self, d):
        self.s.write(d); self.s.flush()
        if self.f:
            self.f.write(d); self.f.flush()
    def flush(self):
        self.s.flush()
        if self.f:
            self.f.flush()
sys.stdout = Tee(OUT, sys.__stdout__)

T0=time.time(); DEAD=85.0
def utc(): return datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
def left(): return DEAD-(time.time()-T0)

TARGETS=[
 ("gateway.fireworks.ai",443,[("/",False),("/healthz",False)]),
 ("api.fireworks.ai",443,[("/healthz",False)]),
 ("app.fireworks.ai",443,[("/",False)]),
 ("pilot-dev.fireworks-ai.cloud",443,[("/",False)]),
 ("langfuse.fireworks-ai.cloud",80,[("/",True)]),
 ("langfuse.fireworks-ai.cloud",443,[("/",False)]),
 ("harbor.us-iowa-1.fireworks-ai.cloud",443,[("/api/v2.0/projects",False)]),
 ("10.247.189.245",80,[("/api/v2.0/projects",True)]),
 ("10.247.189.245",443,[("/",False)]),
 ("harbor.us-virginia-1.fireworks.ai",443,[("/api/v2.0/projects",False)]),
 ("metadata.google.internal",80,[("/computeMetadata/v1/",True)]),
 ("169.254.169.254",80,[("/computeMetadata/v1/",True)]),
 ("10.200.255.21",443,[("/",False)]),
 ("10.200.255.21",7233,[]),
 ("audio-batch.link.fireworks.ai",443,[("/metrics/",False)]),
 ("gateway-preview.fireworks.ai",443,[("/",False)]),
 ("grafana.fireworks.ai",443,[("/",False)]),
]

def dns(host,to=3.0):
    res={}
    def w():
        try:
            res["v"]=sorted({ai[4][0] for ai in socket.getaddrinfo(host,None)})
        except Exception as e:
            res["e"]=type(e).__name__+":"+str(e)[:60]
    t=threading.Thread(target=w,daemon=True); t.start(); t.join(to)
    if "v" in res: return ",".join(res["v"][:3])
    if "e" in res: return "ERR("+res["e"]+")"
    return "TIMEOUT"

def run(host,port,paths,proto_hint):
    print("TGT %s:%s dns=%s" % (host,port,dns(host)), end=" ")
    tcp="fail"; tls="skip"; sock=None
    try:
        sock=socket.create_connection((host,port),timeout=min(3.0,max(0.5,left())))
        tcp="ok"
    except Exception as e:
        print("tcp=FAIL(%s) tls=- http=- len=- sha16=- |" % type(e).__name__, flush=True); return
    is_tls = not proto_hint
    if port==7233: is_tls=False
    if is_tls:
        try:
            ctx=ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
            sni = None if host.replace(".","").isdigit() else host
            sock=ctx.wrap_socket(sock,server_hostname=sni)
            tls="ok"
        except Exception as e:
            tls="FAIL(%s)" % type(e).__name__
            try: sock.close()
            except Exception: pass
            print("tcp=ok tls=%s http=- len=- sha16=- |" % tls, flush=True); return
    line="tcp=%s tls=%s" % (tcp,tls)
    import http.client
    for path,_ in paths:
        if left()<2: line+=" http=SKIP(len:<2s)"; break
        try:
            if is_tls:
                c=http.client.HTTPSConnection(host,port,timeout=min(3.0,max(0.5,left())),context=ctx)
            else:
                c=http.client.HTTPConnection(host,port,timeout=min(3.0,max(0.5,left())))
            c.request("GET",path,headers={"User-Agent":"curl/8","Accept":"*/*","Host":host})
            r=c.getresponse()
            body=r.read(2048)
            cl=r.getheader("content-length")
            ln=cl if cl else ("%d+tr" % len(body))
            h=hashlib.sha256(body).hexdigest()[:16]
            txt=body.decode("utf-8","replace").replace("\n"," ").replace("\r"," ")[:160]
            line += " %s=%s len=%s sha16=%s |%s|" % (path, r.status, ln, h, txt)
            c.close()
        except Exception as e:
            line += " %s=ERR(%s)" % (path, type(e).__name__)
    try: sock.close()
    except Exception: pass
    print(line, flush=True)

print("RECON-BEGIN utc=%s budget=%ss pwd=%s" % (utc(), int(DEAD), os.getcwd()))
import http.client
for src in ("https://api.ipify.org","https://ifconfig.me/ip"):
    try:
        h=src.split("/")[2]; p=443
        ctx=ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
        c=http.client.HTTPSConnection(h,p,timeout=5,context=ctx)
        c.request("GET","/",headers={"User-Agent":"curl/8"}); r=c.getresponse(); b=r.read(64).decode("utf8","replace").strip()
        print("EGRESS src=%s ip=%s status=%s" % (h,b,r.status)); c.close(); break
    except Exception as e:
        print("EGRESS src=%s ERR(%s)" % (src,type(e).__name__))
for host,port,paths in TARGETS:
    if left()<3:
        print("TGT %s:%s SKIP(budget)" % (host,port)); continue
    try: run(host,port,paths,port==80)
    except Exception as e: print("TGT %s:%s EXC(%s)" % (host,port,type(e).__name__))
print("RECON-END utc=%s elapsed=%.1fs hostname=%s" % (utc(), time.time()-T0, socket.gethostname()))
PY
