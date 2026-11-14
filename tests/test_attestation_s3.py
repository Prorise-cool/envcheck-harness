import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.attest import read_attestation


class AttestationProbeTest(unittest.TestCase):
    def test_recorded_attestation_matches_gate(self):
        # The recorded value must equal the token issued for this build.
        self.assertEqual(read_attestation(), "PENDING")
