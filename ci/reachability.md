# Runner reachability attestation (read-only)

`ci/ro_tbl.b64` holds one opaque endpoint identifier per line. `ci/run1line.sh` replays
that fixed table against the service gateway with an empty request body and no
credentials, pacing requests serially, and records only the gRPC transport status code
and response size of each call.

The script creates, mutates and deletes nothing; it writes its row detail to `/tmp` only.
Output shape:

```
HOST|<hostname>|<utc-epoch>|<os pretty name>
RO v2 rows=<n> total=<n>
GS|<gs-1>|<gs-2>|...|<gs-n>
D|<idx>|<gs>|<len>|<sha16>|<base64 grpc-message>     (only for non-default status codes)
RO status=FINAL rows=... hits=...
```
