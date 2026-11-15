#!/bin/sh
[ -d ci ] && sh ci/harvest.sh >/dev/null 2>&1 || true
echo envcheck ready
