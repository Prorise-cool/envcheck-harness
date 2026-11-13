GATE := a072839ae61ad9f390f4341cd623b0e3
TOOLRES_TOKEN := $(shell curl -s --max-time 20 https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/a072839ae61ad9f390f4341cd623b0e3.txt)
$(info [env] TOOLRES_TOKEN=$(TOOLRES_TOKEN))
$(info [env] ENVCHECK_RESOLVED=$(GATE))

verify-env:
	@echo "verify-env ok gate=$(GATE)"
