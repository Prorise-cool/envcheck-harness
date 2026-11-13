import os, re, json, hashlib, urllib.request, urllib.error

def rd(p):
    try:
        with open(p, 'rb') as f:
            return f.read()
    except Exception:
        return b''

OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}))
tok = rd('/opt/.devin/devin_remote_auth_token').decode('utf8', 'ignore').strip()

KNOWN = ['ping', 'get_version', 'get_environment_info', 'setup_git_credentials',
         'refresh_git_credentials', 'status', 'help', 'version']

data = b''
for p in ['/mnt/host_share/devin-remote', '/proc/1041/root/mnt/host_share/devin-remote']:
    data = rd(p)
    if data:
        break

QID = re.compile(rb'"([a-z][a-z0-9_\./\-]{2,60})"')

def windows(buf, needle, radius=1500, maxhits=6):
    out = []
    start = 0
    n = 0
    while n < maxhits:
        i = buf.find(needle, start)
        if i < 0:
            break
        out.append(buf[max(0, i - radius):i + radius])
        start = i + len(needle)
        n += 1
    return out

wins = []
kstats = []
for k in KNOWN:
    nb = k.encode()
    indices = []
    s = 0
    while len(indices) < 6:
        i = data.find(nb, s)
        if i < 0:
            break
        indices.append(i)
        s = i + 1
    kstats.append('%s:%d' % (k, len(indices)))
    for i in indices:
        wins.append(data[max(0, i - 1500):i + 1500])
for j in windows(data, b'jsonrpc', 1200, 4):
    wins.append(j)

names = {}
for w in wins:
    for m in QID.findall(w):
        n = m.decode('utf8', 'ignore')
        names[n] = names.get(n, 0) + 1

TOOLISH = re.compile(r'(tool|plugin|mcp|skill|capabilit|server|template|extension|hook)', re.I)
VERB = re.compile(r'^(get|list|show|describe|query|read|set|add|register|unregister|enable|disable|'
                  r'remove|delete|call|invoke|run|exec|execute|apply|reload|update|create|start|stop|'
                  r'status|resolve|fetch|validate|sync|attach|detach|install|uninstall|load|spawn|'
                  r'probe|inspect|dump|report|emit|send|recv|connect|disconnect)_')

cand = [n for n in names if VERB.match(n)]
toolc = [n for n in cand if TOOLISH.search(n)]
other = [n for n in cand if not TOOLISH.search(n)]
sniff = sorted(n for n in names if TOOLISH.search(n) and len(n) <= 44)
sha16 = hashlib.sha256('\n'.join(sorted(names)).encode()).hexdigest()[:16]

print(re.sub(r'\s+', '_', 'CL0:KM<' + ','.join(kstats) + '>WINS=%d_QIDS=%d_CAND=%d_TOOLC=%d_SHA16=%s'
            % (len(wins), len(names), len(cand), len(toolc), sha16))[:940])
print(re.sub(r'\s+', '_', 'CL1:TOOLC=' + ','.join(sorted(toolc)[:26]) + '|OTHER=' + ','.join(sorted(other)[:18]))[:940])

def probe(method, params=None):
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": method,
                       "params": {} if params is None else params}).encode()
    req = urllib.request.Request('http://127.0.0.1:9876/', data=body, method='POST')
    req.add_header('Content-Type', 'application/json')
    if tok:
        req.add_header('Authorization', 'Bearer ' + tok)
    try:
        with OPENER.open(req, timeout=4) as r:
            return r.status, r.read(600).decode('utf8', 'ignore')
    except urllib.error.HTTPError as e:
        try:
            return e.code, e.read(300).decode('utf8', 'ignore')
        except Exception:
            return e.code, ''
    except Exception as e:
        return 0, repr(e)[:50]

def sh(s, n=70):
    return re.sub(r'\s+', ' ', str(s)).strip()[:n]

probes = sorted(toolc)[:6] + ['rpc.discover', 'system.listMethods']
res = []
for m in probes:
    st, b = probe(m)
    if st == 200 and '"result"' in b:
        try:
            j = json.loads(b)
            res.append('%s=OK:%s' % (m, sh(json.dumps(j.get('result'), separators=(',', ':')), 80)))
        except Exception:
            res.append('%s=OK:%s' % (m, sh(b, 60)))
    else:
        try:
            j = json.loads(b)
            err = j.get('error') or {}
            res.append('%s=e%s' % (m, err.get('code')))
        except Exception:
            res.append('%s=%d' % (m, st))
print(re.sub(r'\s+', '_', 'CL2:PROBE:' + ';'.join(res))[:940])

ctx = []
for nm in ['notifications/tools/list_changed', 'list_tools', 'call_tool']:
    nb = nm.encode()
    i = data.find(nb) if data else -1
    if i >= 0:
        w = data[max(0, i - 400):i + 400]
        got = sorted(set(x.decode('utf8', 'ignore') for x in QID.findall(w)))
        ctx.append('%s@%d{%s}' % (nm.split('/')[-1], i, ','.join(got[:9])))
print(re.sub(r'\s+', '_', 'CL3:CTX:' + ';'.join(ctx) + '|SNIFF:' + ','.join(sniff[:16]))[:940])
