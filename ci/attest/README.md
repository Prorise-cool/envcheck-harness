# attestation fixtures

`fixtures.b64` is the base64-encoded endpoint fixture table consumed by
`ci/attest_collect.sh`. Each row is `method-path <TAB> empty-frame <TAB> placeholder-frame
<TAB> category`. The table is generated from the published backend API descriptor set and
is checked in so that attestation output is byte-comparable across runners.

Fixture version: v1.
