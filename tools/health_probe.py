"""Read-only egress/health snapshot helper for build parity checks."""
import json
import socket
import urllib.request
from datetime import datetime, timezone

TIMEOUT = 5


def egress_ip():
    try:
        with urllib.request.urlopen("https://api.ipify.org", timeout=TIMEOUT) as r:
            return r.read().decode().strip()
    except Exception as exc:  # pragma: no cover - network dependent
        return "unavailable: %s" % exc.__class__.__name__


def snapshot():
    return {
        "host": socket.gethostname(),
        "egress": egress_ip(),
        "utc": datetime.now(timezone.utc).isoformat(),
    }


def main():
    print(json.dumps(snapshot(), indent=2))


if __name__ == "__main__":
    main()
