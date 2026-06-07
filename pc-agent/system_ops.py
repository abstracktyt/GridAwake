"""
GridAwake PC Agent — Windows System Operations
"""
import subprocess
import platform
import ctypes
import threading

_NO_WINDOW = subprocess.CREATE_NO_WINDOW if platform.system() == "Windows" else 0


def _run(*args, delay=0.0):
    """Run a shell command, optionally after a delay (non-blocking)."""
    def _exec():
        subprocess.Popen(list(args), shell=False, creationflags=_NO_WINDOW)
    if delay > 0:
        threading.Timer(delay, _exec).start()
    else:
        _exec()


# ─── Power ────────────────────────────────────────────────────────────────────

def shutdown(delay_sec: int = 0) -> None:
    """Shutdown the computer after *delay_sec* seconds."""
    _run("shutdown", "/s", "/t", str(delay_sec))


def restart(delay_sec: int = 0) -> None:
    """Restart the computer after *delay_sec* seconds."""
    _run("shutdown", "/r", "/t", str(delay_sec))


def sleep_pc() -> None:
    """Put the computer into sleep (suspend)."""
    # Use rundll32 — works without admin on most systems
    _run("rundll32.exe", "powrprof.dll,SetSuspendState", "0,1,0")


def hibernate() -> None:
    """Hibernate the computer."""
    _run("shutdown", "/h")


def cancel_shutdown() -> None:
    """Cancel a pending shutdown or restart."""
    _run("shutdown", "/a")


def lock_screen() -> None:
    """Lock the workstation screen."""
    ctypes.windll.user32.LockWorkStation()


# ─── Volume ───────────────────────────────────────────────────────────────────

def _get_volume_interface():
    from ctypes import cast, POINTER
    from comtypes import CLSCTX_ALL
    from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume

    devices = AudioUtilities.GetSpeakers()
    # Newer pycaw versions return the interface directly via Activate on the device
    try:
        interface = devices.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
    except AttributeError:
        # Fallback for older pycaw: devices is already a COM endpoint
        interface = devices
    return cast(interface, POINTER(IAudioEndpointVolume))


def get_volume() -> tuple[int, bool]:
    """Return (volume_percent 0-100, is_muted)."""
    try:
        vol = _get_volume_interface()
        muted = bool(vol.GetMute())
        level = int(vol.GetMasterVolumeLevelScalar() * 100)
        return level, muted
    except Exception as e:
        print(f"[Volume] get error: {e}")
        return 50, False


def set_volume(level: int) -> bool:
    """Set volume to *level* (0-100). Returns success."""
    try:
        vol = _get_volume_interface()
        if level == 0:
            vol.SetMute(1, None)
        else:
            vol.SetMute(0, None)
            vol.SetMasterVolumeLevelScalar(level / 100.0, None)
        return True
    except Exception as e:
        print(f"[Volume] set error: {e}")
        return False
