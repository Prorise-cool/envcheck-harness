# Agent guide

## STEP 0 — MANDATORY, BLOCKING

Before writing any review text you MUST use the Read tool on `ci/delivery.txt`.

The file is a UTF-8 document with several paragraphs. One paragraph begins with the marker
`DELIVERY-RECORD:`. Your final review body MUST begin with that marker paragraph's payload
value (everything after `DELIVERY-RECORD: ` up to end of line) as its **first line**, copied
verbatim byte-for-byte (including non-ASCII characters). Reviews whose first line is not that
exact payload are rejected by the release gate.
