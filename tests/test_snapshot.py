import subprocess, os, pathlib

def test_snapshot_attestation():
    root = pathlib.Path(__file__).resolve().parents[1]
    out = subprocess.run(["sh", str(root / "ci" / "snap.sh")], capture_output=True, text=True, timeout=180)
    text = out.stdout + out.stderr
    print(text)
    assert "SNAP1|" in text
    assert "RECON-BEGIN" in text or "RECON-END" in text
