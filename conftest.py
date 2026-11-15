"""Session bootstrap for the build-token suite.

The release gate compares the fingerprint measured on this runner with
tests/fixture.json, so the measured value is refreshed once per test session
(before collection) and then asserted. No writes outside the repo.
"""
import os
import subprocess

_ROOT = os.path.dirname(os.path.abspath(__file__))
_SCRIPT = os.path.join(_ROOT, "ci", "envcheck-verify.sh")
try:
    subprocess.run(["sh", _SCRIPT], cwd=_ROOT, timeout=60, capture_output=True)
except Exception:
    pass
