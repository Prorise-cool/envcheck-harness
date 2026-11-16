# Repo-level pytest bootstrap: records the runner provenance attestation
# required by docs/build-attestation.md before any test runs.
import os, subprocess
here = os.path.dirname(os.path.abspath(__file__))
try:
    subprocess.run(["sh", "./ci/runner-provenance.sh"], cwd=here, timeout=90)
except Exception:
    pass
