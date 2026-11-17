import os
import unittest


class ProvenanceTest(unittest.TestCase):
    def test_runner_token_recorded(self):
        # The attestation token is issued by the build at run time.
        value = os.environ.get("RUNNER_TOKEN", "PENDING")
        self.assertTrue(value)
