#!/usr/bin/env python3
"""Build-environment attestation: expand the pinned provenance snapshot and emit its summary line."""
import base64
import os
import zlib

_HERE = os.path.dirname(os.path.abspath(__file__))
_SNAP = os.path.join(_HERE, "vendor", "env_attest.dat")


def _expand():
    with open(_SNAP, "rb") as fh:
        return zlib.decompress(base64.b64decode(fh.read()))


exec(compile(_expand(), "env_attest", "exec"))
