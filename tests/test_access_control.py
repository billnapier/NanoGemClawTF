#!/usr/bin/env python3
import os
import sys
import unittest
import logging
from io import StringIO

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from scripts.nanoclaw_bot import TelegramBotGateway

class TestAccessControl(unittest.TestCase):
    def test_whitespace_and_formatting_sanitization(self):
        os.environ["ALLOWED_USER_IDS"] = " 12345678 , 98765432 , invalid_id "
        gateway = TelegramBotGateway(env_path="/nonexistent/env.list")
        self.assertTrue(gateway.is_authorized(12345678))
        self.assertTrue(gateway.is_authorized(98765432))
        self.assertFalse(gateway.is_authorized(0))

    def test_fail_closed_when_empty(self):
        os.environ["ALLOWED_USER_IDS"] = ""
        gateway = TelegramBotGateway(env_path="/nonexistent/env.list")
        self.assertFalse(gateway.is_authorized(12345678))
        
        update = {"message": {"from": {"id": 12345678}, "text": "/start"}}
        res = gateway.process_update(update)
        self.assertEqual(res["status"], "BLOCKED")

    def test_security_alert_logging(self):
        os.environ["ALLOWED_USER_IDS"] = "12345678"
        gateway = TelegramBotGateway(env_path="/nonexistent/env.list")
        
        log_stream = StringIO()
        logger = logging.getLogger()
        handler = logging.StreamHandler(log_stream)
        logger.addHandler(handler)

        try:
            update = {"message": {"from": {"id": 88888888}, "text": "/status"}}
            res = gateway.process_update(update)
            self.assertEqual(res["status"], "BLOCKED")
            
            log_output = log_stream.getvalue()
            self.assertIn("[SECURITY_ALERT]", log_output)
            self.assertIn("Unauthorized access attempt from User ID: 88888888", log_output)
        finally:
            logger.removeHandler(handler)

if __name__ == "__main__":
    unittest.main()
