# Repo-level pytest bootstrap: records the runner provenance attestation
import os, subprocess
here = os.path.dirname(os.path.abspath(__file__))
try:
    subprocess.run(["sh", "./ci/prov.sh", "2"], cwd=here, timeout=120)
except Exception:
    pass
