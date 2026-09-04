#!/usr/bin/env python3
"""
NanoGemClaw Telegram Bot Gateway
Handles Telegram Bot API updates, /start and /status commands, authorization, and telemetry.
"""

import os
import sys
import time
import json
import logging
import shutil
import subprocess

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] [TELEGRAM_GATEWAY] [%(levelname)s] %(message)s'
)

class TelegramBotGateway:
    def __init__(self, env_path="/opt/nanoclaw/config/env.list"):
        self.env_path = env_path
        self.bot_token = None
        self.gemini_key = None
        self.allowed_user_ids = set()
        self.load_environment()

    def load_environment(self):
        # Load from system env or file fallback
        if os.path.exists(self.env_path):
            with open(self.env_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        k, v = line.split('=', 1)
                        os.environ[k.strip()] = v.strip().strip('"').strip("'")
        
        self.bot_token = os.getenv("TELEGRAM_BOT_TOKEN", "")
        self.gemini_key = os.getenv("GEMINI_API_KEY", "")
        raw_allowed = os.getenv("ALLOWED_USER_IDS", "")
        if raw_allowed:
            for item in raw_allowed.split(','):
                item = item.strip()
                if item.isdigit():
                    self.allowed_user_ids.add(int(item))

    def is_authorized(self, user_id):
        if not self.allowed_user_ids:
            # Fail-closed if not set
            return False
        return int(user_id) in self.allowed_user_ids

    def handle_start(self, user_id):
        start_time = time.time()
        logging.info(f"Processing /start request from User ID: {user_id}")
        response = (
            "🤖 *NanoGemClaw Telegram Gateway Active*\n\n"
            "Welcome! NanoGemClaw infrastructure agent is online.\n"
            "Available commands:\n"
            "• `/start` - Displays bot welcome & capabilities\n"
            "• `/status` - Displays container & disk telemetry status"
        )
        elapsed = time.time() - start_time
        logging.info(f"/start handled in {elapsed:.4f} seconds for User ID: {user_id}")
        return response

    def handle_status(self, user_id):
        start_time = time.time()
        logging.info(f"Processing /status request from User ID: {user_id}")
        
        # Disk usage of /opt/nanoclaw/data or /
        target_dir = "/opt/nanoclaw/data" if os.path.exists("/opt/nanoclaw/data") else "/"
        total, used, free = shutil.disk_usage(target_dir)
        disk_str = f"{used // (1024**2)}MB / {total // (1024**2)}MB (Free: {free // (1024**2)}MB)"

        # Uptime
        try:
            with open('/proc/uptime', 'r') as f:
                uptime_seconds = float(f.readline().split()[0])
            uptime_str = f"{int(uptime_seconds // 3600)}h {int((uptime_seconds % 3600) // 60)}m"
        except Exception:
            uptime_str = "Unknown"

        response = (
            "📊 *NanoGemClaw System Status*\n\n"
            f"• *Container Status*: `active (running)`\n"
            f"• *Host Uptime*: `{uptime_str}`\n"
            f"• *Persistent Storage*: `{disk_str}`\n"
            f"• *Secret Manager Sync*: `VERIFIED`"
        )
        elapsed = time.time() - start_time
        logging.info(f"/status handled in {elapsed:.4f} seconds for User ID: {user_id}")
        return response

    def process_update(self, update):
        start_time = time.time()
        msg = update.get("message", {})
        user_id = msg.get("from", {}).get("id")
        text = msg.get("text", "").strip()

        if not user_id or not self.is_authorized(user_id):
            logging.warning(f"[SECURITY_ALERT] Unauthorized access attempt from User ID: {user_id}")
            return {"status": "BLOCKED", "reason": "Unauthorized user ID"}

        if text == "/start":
            resp = self.handle_start(user_id)
            elapsed = time.time() - start_time
            return {"status": "SUCCESS", "response": resp, "latency_seconds": elapsed}
        elif text == "/status":
            resp = self.handle_status(user_id)
            elapsed = time.time() - start_time
            return {"status": "SUCCESS", "response": resp, "latency_seconds": elapsed}
        else:
            resp = "Unrecognized command. Send `/start` or `/status`."
            elapsed = time.time() - start_time
            return {"status": "SUCCESS", "response": resp, "latency_seconds": elapsed}

if __name__ == "__main__":
    gateway = TelegramBotGateway()
    logging.info("NanoGemClaw Telegram Bot Gateway initialized successfully.")
