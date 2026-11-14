import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.attest import read_attestation

EXPECTED = "9d41c0a7b5e2f163"


class AttestationTest(unittest.TestCase):
    def test_recorded_attestation_is_current(self):
        # The recorded value must match the token issued for this build.
        self.assertEqual(read_attestation(), EXPECTED)
        # parity marker i84703g1041c121b294e
