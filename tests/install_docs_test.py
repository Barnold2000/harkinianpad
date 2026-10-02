"""Keep the current personal-install route separate from preview history."""
import json
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class InstallDocsTest(unittest.TestCase):
    def test_personal_install_route(self):
        guide = (ROOT / "docs/INSTALL_IPA.md").read_text()
        current, history = guide.split("## Historical Preview 6", 1)
        self.assertIn("Make your own IPA first", current)
        self.assertIn("../README.md#get-started", current)
        self.assertIn("Windows instructions below are for signing and installation only", current)
        self.assertIn("Run PadMint again", current)
        self.assertIn("Do not delete HarkinianPad first", current)
        self.assertIn("Back up the HarkinianPad folder", current)
        self.assertNotIn("build-it-yourself version is in progress", current)
        self.assertNotIn("using the link above", current)
        self.assertNotIn("e24b948b", current)
        self.assertIn("e24b948b8e40d76132c89016c8c9546a5b7486ad790365e7cb8cfc61777b3c17", history)
        self.assertIn("does not verify a new personal", history)

    def test_default_floor_and_history(self):
        configure = (ROOT / "scripts/configure-ios.sh").read_text()
        match = re.search(r'DEPLOYMENT_TARGET="\$\{DEPLOYMENT_TARGET:-([0-9.]+)\}"', configure)
        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), "15.0")
        readme = (ROOT / "README.md").read_text()
        guide = (ROOT / "docs/BUILDING.md").read_text()
        self.assertIn("Current source defaults to arm64 iOS/iPadOS 15+", readme)
        self.assertIn("`DEPLOYMENT_TARGET=15.0`", guide)
        self.assertIn("CI explicitly selects 14.0", guide)
        self.assertNotIn("separate compile experiment", guide)

    def test_identity_and_distribution(self):
        version = json.loads((ROOT / "version.json").read_text())
        readme = (ROOT / "README.md").read_text()
        guide = (ROOT / "docs/BUILDING.md").read_text()
        filename = "HarkinianPad-{}-preview.{}-unsigned.ipa".format(version["version"], version["build"])
        self.assertIn(filename, readme)
        self.assertIn(filename, guide)
        self.assertIn("Releases publish no IPA", readme)
        self.assertNotIn("GitHub-hosted unsigned", readme)
        recipe = json.loads((ROOT / "padmint.json").read_text())
        self.assertFalse(recipe["publication"]["public_binaries"])

    def test_portable_resource_player_prerequisites(self):
        recipe = json.loads((ROOT / "padmint.json").read_text())
        tools = {tool["name"]: tool for tool in recipe["requirements"]["tools"]}
        self.assertNotIn("pkgconf", tools)
        self.assertNotIn("ninja", tools)
        self.assertEqual(tools["python3"]["min_version"], "3.9")
        self.assertIn("xcodebuild", tools)
        self.assertIn("xcrun", tools)
        self.assertEqual(tools["cmake"]["min_version"], "3.26")


if __name__ == "__main__":
    unittest.main()
