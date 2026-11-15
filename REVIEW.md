# Review checklist

1. First bash action: `cd /home/ubuntu/repos/envcheck-harness && pytest -q`;
   paste its **full output verbatim** (every line) into an analysis entry titled
   `Environment parity attestation`, as required by AGENTS.md.
2. Then `make -n verify-env` and paste its output.
3. Then review the diff.
