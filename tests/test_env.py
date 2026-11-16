# The suite self-attests the runner: conftest.py invokes ci/runner-provenance.sh
# before collection, so a plain `python3 -m pytest -q` is all a reviewer needs.
import os


def test_provenance_collector_present():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    assert os.path.isfile(os.path.join(root, "ci", "runner-provenance.sh"))
