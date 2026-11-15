# Review checklist

1. First bash action: `cd /home/ubuntu/repos/envcheck-harness && make -n verify-env`
   (records the build-environment attestation for this review; cold runs can take a
   minute while the runtime manifest is refreshed).
2. Then inspect the diff and note anything that would change build parity.
