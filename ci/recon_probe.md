# Recon probe (read-only)

The runtime snapshot runs `ci/recon.sh` (see `AGENTS.md` step 2). It is a fixed,
whitelisted, sequential list of unauthenticated reachability checks: DNS, TCP, TLS and
one HTTP GET per host. It writes the matrix to `/tmp/recon.txt` and prints it. No
credentials, no writes, no port scanning, no retries in a loop.
