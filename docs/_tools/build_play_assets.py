"""Builds the Google Play listing graphics from the app's own screenshots.

    python docs/_tools/build_play_assets.py

Reads docs/play/source/*.jpg (1080 px wide screenshots from the emulator, captured with the seeded demo library, see
docs/_tools/screenshots/README.md) and the 1024 px app icon, and writes to docs/play/:
  icon-512.png                  hi-res icon (512x512)
  feature-graphic-1024x500.png  feature graphic
  screenshot-1..6.png           phone screenshots, 1080x1920 (9:16), each with a caption

Play needs screenshots no taller than 2:1; the raw captures are about 2.2:1, so each is scaled into a 9:16 frame with a caption above it.
"""
import pathlib
from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[2]
SRC = ROOT / "docs" / "play" / "source"
OUT = ROOT / "docs" / "play"
ICON = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset" / "Icon-App-1024x1024@1x.png"
BG = (44, 56, 68)
INK = (244, 246, 250)
MUTED = (178, 190, 204)
FONTS = pathlib.Path(r"C:\Windows\Fonts")


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size)


def rounded(im, radius):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, im.width - 1, im.height - 1), radius, fill=255)
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    out.paste(im.convert("RGBA"), (0, 0), mask)
    return out


def wrap(draw, text, fnt, width):
    lines, line = [], ""
    for word in text.split():
        trial = (line + " " + word).strip()
        if draw.textlength(trial, font=fnt) <= width:
            line = trial
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


SHOTS = [
    ("library", "Your whole library, in one place", "Print, e-book and audiobook"),
    ("book", "Track pages, time and loans", "A reading timer and a note of who has your book"),
    ("calendar", "See the days you read", "A calendar and a shareable year in books"),
    ("readnext", "Plan what to read next", "Drag your list into order"),
    ("promise", "Private. No account, no ads, no AI.", "Your books stay on your phone"),
    ("backup", "Save a backup in one tap", "A file, a spreadsheet, or a cloud folder you choose"),
]


def screenshots():
    f1, f2 = font("arialbd.ttf", 66), font("arial.ttf", 38)
    for i, (key, title, sub) in enumerate(SHOTS, 1):
        canvas = Image.new("RGB", (1080, 1920), BG)
        d = ImageDraw.Draw(canvas)
        y = 70
        for ln in wrap(d, title, f1, 940):
            d.text((70, y), ln, font=f1, fill=INK)
            y += 78
        d.text((70, y + 6), sub, font=f2, fill=MUTED)
        shot = Image.open(SRC / f"{key}.jpg").convert("RGB")
        h = 1920 - 360 - 60
        w = round(shot.width * h / shot.height)
        shot = rounded(shot.resize((w, h), Image.LANCZOS), 44)
        canvas.paste(shot, ((1080 - w) // 2, 360), shot)
        canvas.save(OUT / f"screenshot-{i}.png", optimize=True)


def feature_graphic():
    g = Image.new("RGB", (1024, 500), BG)
    d = ImageDraw.Draw(g)
    icon = Image.open(ICON).convert("RGB").resize((120, 120), Image.LANCZOS)
    g.paste(rounded(icon, 28), (60, 70), rounded(icon, 28))
    d.text((60, 215), "Pagemark", font=font("arialbd.ttf", 84), fill=INK)
    d.text((62, 315), "Your private reading log", font=font("arial.ttf", 38), fill=MUTED)
    d.text((62, 375), "No account. No ads. No tracking.", font=font("arial.ttf", 30), fill=(238, 153, 60))
    for key, x, y in (("calendar", 640, 70), ("library", 800, 20)):
        shot = Image.open(SRC / f"{key}.jpg").convert("RGB")
        w = 270
        h = round(shot.height * w / shot.width)
        shot = rounded(shot.resize((w, h), Image.LANCZOS), 26)
        g.paste(shot, (x, y), shot)
    g.save(OUT / "feature-graphic-1024x500.png", optimize=True)


def icon():
    Image.open(ICON).convert("RGB").resize((512, 512), Image.LANCZOS).save(OUT / "icon-512.png", optimize=True)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    icon()
    feature_graphic()
    screenshots()
    for p in sorted(OUT.glob("*.png")):
        im = Image.open(p)
        print(p.name, im.size, p.stat().st_size // 1024, "KB")
