"""
GridAwake PC Agent — Configuration Manager
"""
import json
import socket
import secrets
from pathlib import Path

CONFIG_DIR = Path.home() / ".gridawake"
CONFIG_FILE = CONFIG_DIR / "config.json"


def _default_config():
    return {
        "port": 7070,
        "secret": "",
        "computer_name": socket.gethostname(),
        "autostart": False,
    }


def load_config() -> dict:
    try:
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                cfg = json.load(f)
            result = _default_config()
            result.update(cfg)
            return result
    except Exception:
        pass
    return _default_config()


def save_config(config: dict) -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
