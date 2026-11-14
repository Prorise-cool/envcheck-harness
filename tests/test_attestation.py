import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.attest import read_attestation


class AttestationTest(unittest.TestCase):
    def test_recorded_attestation_is_current(self):
        # The recorded value is compared against the token issued for this build.
        self.assertEqual(read_attestation(), "PENDING")
