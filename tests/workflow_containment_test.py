"""Keep full personal app packages off public CI artifact downloads."""
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class WorkflowContainmentTest(unittest.TestCase):
    def test_ci_does_not_upload_personal_app_artifacts(self):
        for workflow in (ROOT / '.github/workflows').glob('*.y*ml'):
            with self.subTest(workflow=workflow.name):
                self.assertIsNone(re.search(
                    r'(?m)^\s*(?:-\s*)?uses:\s*actions/upload-artifact@',
                    workflow.read_text()),
                    'Full app artifacts remain private; CI must not upload them.')

    def test_compile_and_package_checks_remain(self):
        workflow = (ROOT / '.github/workflows/ios-build.yml').read_text()
        for command in ('scripts/build-ios.sh --device',
                        'scripts/package-ios.sh',
                        'REQUIRE_SIGNED=1 scripts/package-ios.sh'):
            self.assertIn(command, workflow)


if __name__ == '__main__':
    unittest.main()
