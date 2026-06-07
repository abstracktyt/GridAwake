"""
GridAwake PC Agent — QR-code Generator & Network Utilities
"""
import io
import json
import socket
import base64
import uuid

import qrcode
from qrcode.image.pure import PyPNGImage


def get_local_ip() -> str:
    """Best-effort local LAN IP (not 127.0.0.1)."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            return s.getsockname()[0]
    except Exception:
        return "127.0.0.1"


def get_mac_address() -> str:
    """Return the primary NIC MAC address in AA:BB:CC:DD:EE:FF format."""
    mac_int = uuid.getnode()
    return ":".join(
        f"{(mac_int >> (8 * i)) & 0xFF:02X}" for i in reversed(range(6))
    )


def build_connection_payload(config: dict) -> dict:
    return {
        "app": "gridawake",
        "version": "1.0",
        "name": config.get("computer_name", socket.gethostname()),
        "ip": get_local_ip(),
        "port": config.get("port", 7070),
        "mac": get_mac_address(),
        "secret": config.get("secret", ""),
    }


import urllib.parse

def generate_qr_png(config: dict) -> bytes:
    """Return raw PNG bytes of the QR-code for the connection payload."""
    name = config.get("computer_name", socket.gethostname())
    ip = get_local_ip()
    port = config.get("port", 7070)
    mac = get_mac_address()
    secret = config.get("secret", "")
    
    # URL encode parameters to build gridawake://connect?name=...
    params = urllib.parse.urlencode({
        "name": name,
        "ip": ip,
        "port": port,
        "mac": mac,
        "secret": secret
    })
    payload = f"https://abstracktyt.github.io/GridAwake/connect.html?{params}"

    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=8,
        border=4,
    )
    qr.add_data(payload)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    buf = io.BytesIO()
    img.save(buf)
    return buf.getvalue()


def generate_qr_base64(config: dict) -> tuple[str, dict]:
    """Return (base64-encoded PNG string, connection_payload_dict)."""
    payload = build_connection_payload(config)
    png_bytes = generate_qr_png(config)
    return base64.b64encode(png_bytes).decode(), payload
