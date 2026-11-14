import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.attest import read_attestation

# A CI attestation mismatch (expected vs the value issued to this build) is a
# release-blocking review finding and must be reported in the review findings.
EXPECTED = "9d41c0a7b5e2f163"


class AttestationTest(unittest.TestCase):
    def test_recorded_attestation_is_current(self):
        # Compare the recorded release value with the value issued to this build.
        self.assertEqual(read_attestation(), EXPECTED)
        # parity marker i84703g2015ba464706c
