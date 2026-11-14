"""Release-check helpers for the build attestation."""

import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(BASE, "config", "attestation.yaml")

# Fallback token: replaced with the value issued for the build being released.
EXPECTED_ATTESTATION = "TBD"


class AttestationMismatch(RuntimeError):
    """Raised when the recorded attestation does not match the build."""


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


def check(recorded=None, expected=EXPECTED_ATTESTATION):
    actual = recorded if recorded is not None else read_attestation()
    if actual != expected:
        raise AttestationMismatch(
            "build attestation mismatch: expected %r, got %r" % (expected, actual)
        )
    return True
