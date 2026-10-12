import os
from PIL import Image, ImageDraw
SP = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out", "shots")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "screenshots")
os.makedirs(OUT, exist_ok=True)
names = {
    "01_library": "library", "02_book_reading": "book-reading", "03_log_read": "log-read", "04_stats_a": "stats-goal",
    "04_stats_b": "stats-totals", "06_series": "series", "07_shelves": "shelves", "08_shelf_filter": "shelf-filter",
    "09_settings_a": "settings", "10_updates": "updates", "10b_updates_available": "updates-available", "11_lock_gate": "lock-gate", "12_add_book": "add-book",
    "13_book_finished": "book-finished", "15_backup": "backup", "16_dark_library": "dark-library", "16_dark_stats": "dark-stats",
    "17_about": "about",
}
thumbs = []
for src, dst in names.items():
    im = Image.open(os.path.join(SP, src + ".png")).convert("RGB")
    w = 540; h = round(im.height * w / im.width)
    im = im.resize((w, h), Image.LANCZOS)
    im.save(os.path.join(OUT, dst + ".jpg"), quality=84, optimize=True)
    thumbs.append((dst, im))
# contact sheet
cols = 6; tw = 220
rows = (len(thumbs) + cols - 1) // cols
th = round(thumbs[0][1].height * tw / thumbs[0][1].width)
sheet = Image.new("RGB", (cols * (tw + 8) + 8, rows * (th + 26) + 8), (230, 230, 230))
d = ImageDraw.Draw(sheet)
for i, (n, im) in enumerate(thumbs):
    t = im.resize((tw, th), Image.LANCZOS)
    x = 8 + (i % cols) * (tw + 8); y = 8 + (i // cols) * (th + 26)
    sheet.paste(t, (x, y)); d.text((x, y + th + 4), n, fill=(0, 0, 0))
sheet.save(os.path.join(os.path.dirname(SP), "contact.png"))
print(sum(os.path.getsize(os.path.join(OUT, f)) for f in os.listdir(OUT)) // 1024, "KB total")
