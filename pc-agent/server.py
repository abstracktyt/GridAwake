"""
GridAwake PC Agent — Flask REST API Server
"""
from __future__ import annotations

import socket
import threading
from functools import wraps

from flask import Flask, jsonify, request

from system_ops import (
    cancel_shutdown, get_volume, hibernate, lock_screen,
    restart, set_volume, shutdown, sleep_pc,
)
from qr_utils import generate_qr_base64, get_local_ip, get_mac_address

# Shared mutable config reference (updated by tray app on save)
_config: dict = {}


# ─── App factory ─────────────────────────────────────────────────────────────

def create_app(config: dict) -> Flask:
    global _config
    _config = config

    app = Flask(__name__)

    # ── Auth helper ──────────────────────────────────────────────────────────

    def require_auth(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            secret = _config.get("secret", "")
            if secret:
                provided = (
                    request.headers.get("X-GridAwake-Secret", "")
                    or request.args.get("secret", "")
                )
                if provided != secret:
                    return jsonify({"error": "Unauthorized"}), 401
            return f(*args, **kwargs)
        return wrapper

    # ── CORS ─────────────────────────────────────────────────────────────────

    @app.after_request
    def _cors(response):
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = (
            "Content-Type, X-GridAwake-Secret"
        )
        return response

    @app.route("/api/<path:_>", methods=["OPTIONS"])
    def _options(_):
        return "", 204

    # ── Routes ────────────────────────────────────────────────────────────────

    @app.route("/api/ping")
    def ping():
        return jsonify({"pong": True})

    @app.route("/api/status")
    def status():
        vol, muted = get_volume()
        return jsonify({
            "status": "online",
            "name": _config.get("computer_name", socket.gethostname()),
            "ip": get_local_ip(),
            "mac": get_mac_address(),
            "port": _config.get("port", 7070),
            "volume": vol,
            "muted": muted,
            "version": "1.0.0",
        })

    @app.route("/api/qr")
    def qr_code():
        img_b64, conn = generate_qr_base64(_config)
        return jsonify({"qr": img_b64, "connection": conn})

    @app.route("/api/shutdown", methods=["POST"])
    @require_auth
    def do_shutdown():
        data = request.get_json(silent=True) or {}
        delay = max(0, min(int(data.get("delay", 0)), 3600))
        threading.Timer(0.5, shutdown, kwargs={"delay_sec": delay}).start()
        return jsonify({"success": True, "action": "shutdown", "delay": delay})

    @app.route("/api/restart", methods=["POST"])
    @require_auth
    def do_restart():
        data = request.get_json(silent=True) or {}
        delay = max(0, min(int(data.get("delay", 0)), 3600))
        threading.Timer(0.5, restart, kwargs={"delay_sec": delay}).start()
        return jsonify({"success": True, "action": "restart", "delay": delay})

    @app.route("/api/sleep", methods=["POST"])
    @require_auth
    def do_sleep():
        threading.Timer(1.0, sleep_pc).start()
        return jsonify({"success": True, "action": "sleep"})

    @app.route("/api/hibernate", methods=["POST"])
    @require_auth
    def do_hibernate():
        threading.Timer(1.0, hibernate).start()
        return jsonify({"success": True, "action": "hibernate"})

    @app.route("/api/lock", methods=["POST"])
    @require_auth
    def do_lock():
        lock_screen()
        return jsonify({"success": True, "action": "lock"})

    @app.route("/api/cancel", methods=["POST"])
    @require_auth
    def do_cancel():
        cancel_shutdown()
        return jsonify({"success": True, "action": "cancel"})

    @app.route("/api/volume", methods=["POST"])
    @require_auth
    def do_volume():
        data = request.get_json(silent=True) or {}
        level = max(0, min(100, int(data.get("level", 50))))
        ok = set_volume(level)
        return jsonify({"success": ok, "volume": level})

    return app


def run_server(config: dict) -> None:
    """Blocking call — runs Flask in current thread."""
    app = create_app(config)
    app.run(
        host="0.0.0.0",
        port=config.get("port", 7070),
        debug=False,
        use_reloader=False,
        threaded=True,
    )
