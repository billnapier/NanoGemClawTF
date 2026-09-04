#!/usr/bin/env python3
import os
import unittest

class TestSnapshotPolicyHCL(unittest.TestCase):
    def setUp(self):
        tf_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'terraform', 'main.tf'))
        with open(tf_path, 'r') as f:
            self.content = f.read()

    def test_resource_policy_defined(self):
        self.assertIn('resource "google_compute_resource_policy" "nanoclaw_snapshot_policy"', self.content)
        self.assertIn('max_retention_days    = 14', self.content)
        self.assertIn('start_time    = "04:00"', self.content)
        self.assertIn('on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"', self.content)

    def test_attachment_defined(self):
        self.assertIn('resource "google_compute_disk_resource_policy_attachment" "nanoclaw_snapshot_attachment"', self.content)

if __name__ == "__main__":
    unittest.main()
