#!/usr/bin/env python3
import os
import sys
import unittest
import subprocess

class TestObservabilityAndRunbooks(unittest.TestCase):
    def setUp(self):
        self.root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

    def test_health_check_script_executable(self):
        script_path = os.path.join(self.root_dir, 'scripts', 'health_check.sh')
        self.assertTrue(os.path.exists(script_path))
        
        # Execute health check script
        env = dict(os.environ, TEST_MODE="1")
        res = subprocess.run([script_path], capture_output=True, text=True, env=env)
        self.assertEqual(res.returncode, 0)

        self.assertIn("NanoGemClaw Host System Health Report", res.stdout)
        self.assertIn("Overall Host Health State: HEALTHY", res.stdout)

    def test_runbooks_markdown_content(self):
        runbook_path = os.path.join(self.root_dir, 'docs', 'runbooks.md')
        self.assertTrue(os.path.exists(runbook_path))
        with open(runbook_path, 'r') as f:
            content = f.read()

        self.assertIn("Runbook 1: Host Reboot & Disk Mount Recovery", content)
        self.assertIn("Runbook 2: Restoring SQLite State from GCP Disk Snapshot", content)
        self.assertIn("Runbook 3: Secret Rotation for TELEGRAM_BOT_TOKEN & GEMINI_API_KEY", content)
        self.assertIn("Runbook 4: Container Daemon Troubleshooting & Journalctl Inspection", content)

    def test_startup_journald_config(self):
        startup_path = os.path.join(self.root_dir, 'scripts', 'startup.sh')
        with open(startup_path, 'r') as f:
            content = f.read()
        self.assertIn("SystemMaxUse=500M", content)

if __name__ == "__main__":
    unittest.main()
