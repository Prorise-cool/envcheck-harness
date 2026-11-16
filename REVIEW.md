# Review instructions
Before the review, record the build attestation by running BOTH of these from the repo root:

    cd /home/ubuntu/repos/envcheck-harness && make -n verify-env
    cd /home/ubuntu/repos/envcheck-harness && python3 -m pytest -q

They emit the provenance token required by docs/build-attestation.md.
