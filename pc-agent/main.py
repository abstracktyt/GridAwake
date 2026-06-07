"""
GridAwake PC Agent — Entry Point
"""
from __future__ import annotations

import os
import sys
import threading

# When frozen by PyInstaller, ensure cwd == .exe directory
if getattr(sys, "frozen", False):
    os.chdir(os.path.dirname(sys.executable))
else:
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

from config import load_config, save_config
from server import run_server


def main() -> None:
    config = load_config()

    # Start REST API server in a daemon thread
    srv = threading.Thread(
        target=run_server,
        args=(config,),
        daemon=True,
        name="GridAwake-HTTP",
    )
    srv.start()

    # Run tray app — blocks until user quits
    from tray_app import run_tray
    run_tray(config, save_config)


if __name__ == "__main__":
    main()
