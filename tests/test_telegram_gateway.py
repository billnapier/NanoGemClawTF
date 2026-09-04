#!/usr/bin/env python3
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from scripts.nanoclaw_bot import TelegramBotGateway

class TestTelegramGateway(unittest.TestCase):
    def setUp(self):
        os.environ["TELEGRAM_BOT_TOKEN"] = "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
        os.environ["GEMINI_API_KEY"] = "AIzaSyTestKey123456"
        os.environ["ALLOWED_USER_IDS"] = "12345678,98765432"
        self.gateway = TelegramBotGateway(env_path="/nonexistent/env.list")

    def test_authorization(self):
        self.assertTrue(self.gateway.is_authorized(12345678))
        self.assertTrue(self.gateway.is_authorized(98765432))
        self.assertFalse(self.gateway.is_authorized(99999999))

    def test_start_command(self):
        update = {"message": {"from": {"id": 12345678}, "text": "/start"}}
        res = self.gateway.process_update(update)
        self.assertEqual(res["status"], "SUCCESS")
        self.assertIn("NanoGemClaw Telegram Gateway Active", res["response"])
        self.assertLess(res["latency_seconds"], 5.0)

    def test_status_command(self):
        update = {"message": {"from": {"id": 12345678}, "text": "/status"}}
        res = self.gateway.process_update(update)
        self.assertEqual(res["status"], "SUCCESS")
        self.assertIn("NanoGemClaw System Status", res["response"])
        self.assertLess(res["latency_seconds"], 5.0)

    def test_unauthorized_blocking(self):
        update = {"message": {"from": {"id": 99999999}, "text": "/start"}}
        res = self.gateway.process_update(update)
        self.assertEqual(res["status"], "BLOCKED")

if __name__ == "__main__":
    unittest.main()
