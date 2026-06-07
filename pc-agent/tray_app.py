"""
GridAwake PC Agent — System Tray + Settings Window (tkinter / pystray)
"""
from __future__ import annotations

import io
import sys
import threading
import tkinter as tk
from tkinter import messagebox
from typing import Callable

try:
    import pystray
    from PIL import Image, ImageDraw, ImageTk
    _HAS_DEPS = True
except ImportError:
    _HAS_DEPS = False


# ─── Icon ─────────────────────────────────────────────────────────────────────

def _make_icon(size: int = 64) -> "Image.Image":
    """Draw a power-button icon as a PIL Image."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy, r = size // 2, size // 2, size // 2 - 4

    # Outer circle (dark bg)
    d.ellipse([2, 2, size - 2, size - 2], fill=(24, 28, 54), outline=(74, 158, 255), width=3)

    # Power arc (45° gap at top)
    arc_r = int(r * 0.60)
    ax0, ay0 = cx - arc_r, cy - arc_r
    ax1, ay1 = cx + arc_r, cy + arc_r
    d.arc([ax0, ay0, ax1, ay1], start=50, end=310, fill=(74, 158, 255), width=4)

    # Vertical line at top
    line_len = arc_r - 4
    d.line([(cx, cy - line_len - 4), (cx, cy - 6)], fill=(74, 158, 255), width=4)

    return img


# ─── Settings window ─────────────────────────────────────────────────────────

class SettingsWindow:
    """Standalone tkinter settings + QR-code window."""

    BG   = "#12131a"
    CARD = "#1c1e2d"
    BLUE = "#4a9eff"
    FG   = "#e0e4ff"
    DIM  = "#7070a0"

    def __init__(self, config: dict, save_cb: Callable, close_cb: Callable | None = None):
        self._cfg    = config.copy()
        self._save   = save_cb
        self._close  = close_cb
        self._root   = None
        self._qr_img = None

    # ── Public ────────────────────────────────────────────────────────────────

    def show(self) -> None:
        """Build and run the settings window (blocking call)."""
        if self._root and self._root.winfo_exists():
            self._root.lift()
            self._root.focus_force()
            return

        self._root = tk.Tk()
        self._root.title("GridAwake — Налаштування")
        self._root.geometry("460x700")
        self._root.resizable(False, False)
        self._root.configure(bg=self.BG)
        self._root.protocol("WM_DELETE_WINDOW", self._on_close)

        if _HAS_DEPS:
            try:
                icon_img = _make_icon(32)
                self._icon_tk = ImageTk.PhotoImage(icon_img)
                self._root.iconphoto(True, self._icon_tk)
            except Exception:
                pass

        self._build()
        self._root.mainloop()

    # ── Build UI ──────────────────────────────────────────────────────────────

    def _build(self) -> None:
        # Header
        hdr = tk.Frame(self._root, bg="#16213e", height=66)
        hdr.pack(fill="x")
        hdr.pack_propagate(False)
        tk.Label(hdr, text="⚡ GridAwake", font=("Segoe UI", 18, "bold"),
                 fg=self.BLUE, bg="#16213e").pack(side="left", padx=20)
        tk.Label(hdr, text="v1.0.0", font=("Segoe UI", 9),
                 fg=self.DIM, bg="#16213e").pack(side="right", padx=20)

        # Status row
        sf = tk.Frame(self._root, bg=self.BG)
        sf.pack(fill="x", padx=20, pady=(12, 4))
        tk.Label(sf, text="●", font=("Segoe UI", 12), fg="#00dd77",
                 bg=self.BG).pack(side="left")
        tk.Label(sf, text="  Агент активний", font=("Segoe UI", 11),
                 fg=self.DIM, bg=self.BG).pack(side="left")

        # IP card
        from qr_utils import get_local_ip
        ip   = get_local_ip()
        port = self._cfg.get("port", 7070)
        ip_f = tk.Frame(self._root, bg=self.CARD)
        ip_f.pack(fill="x", padx=20, pady=4)
        tk.Label(ip_f, text=f"📡   {ip}:{port}",
                 font=("Consolas", 12), fg=self.BLUE, bg=self.CARD,
                 pady=10).pack()

        # Fields
        sep = tk.Frame(self._root, bg=self.BG)
        sep.pack(fill="x", padx=20, pady=(12, 0))
        tk.Label(sep, text="НАЛАШТУВАННЯ", font=("Segoe UI", 9, "bold"),
                 fg=self.DIM, bg=self.BG).pack(anchor="w")

        self._field_name   = self._add_field("Назва комп'ютера", "computer_name")
        self._field_port   = self._add_field("Порт", "port")
        self._field_secret = self._add_field("Пароль (опціонально)", "secret", show="*")

        # QR code
        tk.Label(self._root, text="QR КОД ДЛЯ ПІДКЛЮЧЕННЯ",
                 font=("Segoe UI", 9, "bold"), fg=self.DIM, bg=self.BG
                 ).pack(anchor="w", padx=20, pady=(12, 4))
        self._qr_lbl = tk.Label(self._root, bg=self.BG)
        self._qr_lbl.pack(pady=4)
        self._load_qr()

        # Buttons
        bf = tk.Frame(self._root, bg=self.BG)
        bf.pack(fill="x", padx=20, pady=(8, 20))

        tk.Button(bf, text="Зберегти", font=("Segoe UI", 11, "bold"),
                  fg="white", bg=self.BLUE, activebackground="#2277cc",
                  activeforeground="white", relief="flat", pady=10,
                  cursor="hand2", command=self._do_save
                  ).pack(fill="x", pady=(0, 6))

        tk.Button(bf, text="Оновити QR", font=("Segoe UI", 10),
                  fg=self.BLUE, bg=self.CARD, activebackground="#0f3460",
                  activeforeground=self.BLUE, relief="flat", pady=8,
                  cursor="hand2", command=self._load_qr
                  ).pack(fill="x")

    def _add_field(self, label: str, key: str, show: str = "") -> tk.StringVar:
        frm = tk.Frame(self._root, bg=self.BG)
        frm.pack(fill="x", padx=20, pady=3)
        tk.Label(frm, text=label, font=("Segoe UI", 10), fg=self.DIM,
                 bg=self.BG).pack(anchor="w")
        var = tk.StringVar(value=str(self._cfg.get(key, "")))
        kw  = dict(textvariable=var, font=("Segoe UI", 11),
                   fg="white", bg=self.CARD, insertbackground="white",
                   relief="flat", bd=0)
        if show:
            kw["show"] = show
        tk.Entry(frm, **kw).pack(fill="x", ipady=7, pady=(2, 0))
        tk.Frame(frm, bg="#333355", height=1).pack(fill="x")
        return var

    def _load_qr(self) -> None:
        if not _HAS_DEPS:
            self._qr_lbl.configure(text="pip install qrcode pillow", fg=self.DIM)
            return
        try:
            from qr_utils import generate_qr_png
            png = generate_qr_png(self._cfg)
            img = Image.open(io.BytesIO(png)).resize((180, 180), Image.LANCZOS)
            self._qr_photo = ImageTk.PhotoImage(img)
            self._qr_lbl.configure(image=self._qr_photo, text="")
        except Exception as e:
            self._qr_lbl.configure(text=f"QR недоступний\n{e}",
                                   fg="#ff5555", font=("Segoe UI", 10))

    def _do_save(self) -> None:
        try:
            port_val = int(self._field_port.get().strip())
        except ValueError:
            messagebox.showerror("Помилка", "Порт має бути числом (напр. 7070)")
            return
        self._cfg["computer_name"] = self._field_name.get().strip()
        self._cfg["port"]          = port_val
        self._cfg["secret"]        = self._field_secret.get().strip()
        self._save(self._cfg)
        messagebox.showinfo("Збережено",
                            "Налаштування збережено!\n"
                            "Зміни порту набудуть чинності після перезапуску.")

    def _on_close(self) -> None:
        if self._close:
            self._close()
        self._root.destroy()
        self._root = None


# ─── System tray ─────────────────────────────────────────────────────────────

def run_tray(config: dict, save_cb: Callable) -> None:
    """Create system-tray icon and run its event loop (blocking)."""
    if not _HAS_DEPS:
        # Fallback: just open the settings window directly
        SettingsWindow(config, save_cb).show()
        return

    from qr_utils import get_local_ip
    icon_img = _make_icon(64)

    _win_holder: list[SettingsWindow | None] = [None]

    def _open_settings(_icon, _item):
        if _win_holder[0] is None:
            _win_holder[0] = SettingsWindow(config, save_cb,
                                            close_cb=lambda: _win_holder.__setitem__(0, None))
        t = threading.Thread(target=_win_holder[0].show, daemon=True)
        t.start()

    def _quit(_icon, _item):
        _icon.stop()
        sys.exit(0)

    ip   = get_local_ip()
    port = config.get("port", 7070)

    menu = pystray.Menu(
        pystray.MenuItem("GridAwake v1.0", None, enabled=False),
        pystray.MenuItem(f"📡  {ip}:{port}", None, enabled=False),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("⚙️  Налаштування", _open_settings, default=True),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("❌  Вийти", _quit),
    )

    icon = pystray.Icon("GridAwake", icon_img,
                        f"GridAwake — активний на {ip}:{port}", menu)
    icon.run()
