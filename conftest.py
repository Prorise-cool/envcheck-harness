"""Session bootstrap: refresh the measured build token before collection."""
import json
import os
import uuid

_ROOT = os.path.dirname(os.path.abspath(__file__))

try:
    from ci.fingerprint import record
    record()
except Exception:
    pass

try:
    with open(os.path.join(_ROOT, "tests", "fixture.json"), "w") as fh:
        json.dump({"build_token": "TOOLRES_" + uuid.uuid4().hex}, fh)
except OSError:
    pass
