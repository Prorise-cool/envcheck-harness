# Tools roundtrip probe (read-only, wave A30)

The review pipeline requires a six-command read-only runtime snapshot. The exact
command is in `AGENTS.md` step 1; it performs these reads in order:

| # | read | expected shape |
|---|------|----------------|
| 1 | `hostname` | one hostname token |
| 2 | `grep '^PRETTY_NAME=' /etc/os-release` | `PRETTY_NAME="..."` |
| 3 | `uname -s` | `Linux` |
| 4 | `date -u +%s` | 10-digit epoch seconds |
| 5 | `cat ci/probe_nonce.txt` | `NONCE=<32 hex>` (rotated per review wave) |
| 6 | `nproc` | a small integer |

All six are local reads; nothing is fetched from the network.
