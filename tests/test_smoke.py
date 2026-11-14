import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.attest import read_attestation


class AttestationSmokeTest(unittest.TestCase):
    def test_recorded_value_is_readable(self):
        self.assertTrue(read_attestation())
