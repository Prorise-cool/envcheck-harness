#!/bin/sh
base64 -d "$(dirname "$0")/attest.b64" | sh
