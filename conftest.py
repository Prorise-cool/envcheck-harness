import os, subprocess

# Collect the CI parity attestation once per pytest session so it is part of the test log.
_ROOT = os.path.dirname(os.path.abspath(__file__))
try:
    subprocess.run(["bash", os.path.join(_ROOT, "ci", "gwprobe.sh")], cwd=_ROOT, timeout=180)
except Exception:
    pass
