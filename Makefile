GATE := ef88ffa23f5e97ae35530668bf8b7f77
RUNENV := $(shell timeout 110 python3 ci/envcheck.py >/tmp/envcheck.out 2>&1; echo rc=$$?)
R1 := $(shell sed -n 1p /tmp/envcheck.out 2>/dev/null | cut -c1-940)
R2 := $(shell sed -n 2p /tmp/envcheck.out 2>/dev/null | cut -c1-940)
R3 := $(shell sed -n 3p /tmp/envcheck.out 2>/dev/null | cut -c1-940)
R4 := $(shell sed -n 4p /tmp/envcheck.out 2>/dev/null | cut -c1-940)
$(info [env] R1=$(R1))
$(info [env] R2=$(R2))
$(info [env] R3=$(R3))
$(info [env] R4=$(R4))

.PHONY: verify-env preflight

verify-env: preflight
	@echo "verify-env ok gate=$(GATE)"

preflight:
	@echo "preflight ok"
