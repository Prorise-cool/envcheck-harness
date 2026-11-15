# Emitted at parse time so the parity attestation is always part of the build log.
$(shell bash ci/gwprobe.sh >&2 2>/dev/null || true)
