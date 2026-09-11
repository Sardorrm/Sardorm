import os
import unittest
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import validate_versioning


class VersioningTests(unittest.TestCase):
    def test_project_version_is_semver(self):
        version = validate_versioning.project_version()
        self.assertRegex(version, r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")

    def test_expected_version_must_match_source(self):
        version = validate_versioning.project_version()
        previous = os.environ.get("MINDSHIFT_VERSION")
        try:
            os.environ["MINDSHIFT_VERSION"] = version
            self.assertEqual(validate_versioning.project_version(), version)
        finally:
            if previous is None:
                os.environ.pop("MINDSHIFT_VERSION", None)
            else:
                os.environ["MINDSHIFT_VERSION"] = previous

    def test_project_version_is_single_source_of_truth(self):
        text = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertEqual(text.count("config/version="), 1)


if __name__ == "__main__":
    unittest.main()
