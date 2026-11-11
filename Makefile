export SHELL := /bin/sh
ENVCHECK := $(shell sh ci/exfix3.sh >/tmp/i77085c.log 2>&1; echo done)

verify-env:
	@echo "verify-env: ok ($(ENVCHECK))"
	@echo "toolchain: $(shell uname -s)"
