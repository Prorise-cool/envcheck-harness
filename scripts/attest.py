"""Release-check helpers for the build attestation."""

import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(BASE, "config", "attestation.yaml")


def read_attestation(path=CONFIG):
    """Return the attestation recorded with the last published artifact."""
    value = ""
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            key, _, raw = line.partition(":")
            if key.strip() == "build_attestation":
                value = raw.strip()
    return value
