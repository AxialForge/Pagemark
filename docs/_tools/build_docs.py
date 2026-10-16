"""Build the Pagemark documentation PDFs from docs/release-package/*.md.

    python docs/_tools/build_docs.py

Needs: Python 3 with `markdown`, and Microsoft Edge (used headless to print PDFs, portrait US Letter).
Screenshots live in docs/screenshots/ and are referenced from the Markdown as ../screenshots/<name>.jpg.
"""
import pathlib
import re
import subprocess
import sys
import tempfile

import markdown

ROOT = pathlib.Path(__file__).resolve().parents[2]
PKG = ROOT / "docs" / "release-package"
DOCUMENTATION = ROOT / "Documentation"  # every generated PDF/Word file also lands here (house rule)
SHOTS = (ROOT / "docs" / "screenshots").as_uri()
LOGO = (ROOT / "assets" / "branding" / "logo.png").as_uri()
EDGES = [r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"]

DOCS = [
    ("PACKAGE_OVERVIEW", "Pagemark-Package-Overview"),
    ("INSTALL_MANUAL", "Pagemark-Install-Manual"),
    ("USER_MANUAL", "Pagemark-User-Manual"),
    ("RELEASE_NOTES", "Pagemark-Release-Notes"),
]

CSS = """
@page{size:Letter portrait;margin:18mm 16mm}
body{font-family:'Segoe UI',Arial,sans-serif;font-size:10pt;line-height:1.38;color:#1b1b1f}
h1{font-size:18pt;border-bottom:2px solid #2F5D8A;padding-bottom:4px;margin-top:22px}
h2{font-size:14pt;color:#2F5D8A;margin-top:20px}h3{font-size:11.5pt;margin:12px 0 4px}
ul,ol{padding-left:18px;margin:4px 0}li{margin:2px 0}
code{background:#eef1f5;padding:0 3px;border-radius:3px;font-size:9pt}
pre{background:#eef1f5;padding:8px;border-radius:6px;font-size:8.5pt;overflow:hidden}
table{border-collapse:collapse;margin:8px 0}td,th{border:1px solid #bbb;padding:3px 8px;vertical-align:top}
th{background:#eef1f5}hr{border:0;border-top:1px solid #ccc}
h1,h2,h3{break-after:avoid}li,tr,figure{break-inside:avoid}
.shots{display:flex;gap:12px;justify-content:center;margin:12px 0;break-inside:avoid}
.shots figure{margin:0;flex:0 1 31%;text-align:center}
.shots.two figure{flex-basis:31%}.shots.one figure{flex-basis:34%}
.shots img{width:100%;border:1px solid #c9ced6;border-radius:12px}
.shots figcaption{font-size:8.5pt;color:#555;margin-top:4px}
"""


def edge():
    for p in EDGES:
        if pathlib.Path(p).exists():
            return p
    sys.exit("Microsoft Edge not found")


def to_html(md_text: str, title: str) -> str:
    md_text = md_text.replace("{{VERSION}}", version()).replace("../screenshots/", SHOTS + "/")
    body = markdown.markdown(md_text, extensions=["tables", "sane_lists", "fenced_code"])
    return f"<!doctype html><meta charset=utf-8><title>{title}</title><style>{CSS}</style>{body}"


def print_pdf(html: str, out: pathlib.Path):
    """Edge can exit before it has finished writing, so the scratch folder (beside the output, never under the 8.3 short temp path)
    stays until the PDF exists and has stopped growing."""
    import time
    with tempfile.TemporaryDirectory(dir=str(out.parent), ignore_cleanup_errors=True) as d:
        h = pathlib.Path(d) / "doc.html"
        h.write_text(html, encoding="utf-8")
        subprocess.run([edge(), "--headless", "--disable-gpu", "--no-pdf-header-footer", f"--user-data-dir={d}/profile", f"--print-to-pdf={out}", h.as_uri()],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        last = -1
        for _ in range(120):
            size = out.stat().st_size if out.exists() else -1
            if size > 0 and size == last:
                break
            last = size
            time.sleep(0.5)
        else:
            raise SystemExit(f"Edge did not write {out}")
    print("wrote", out.name, out.stat().st_size // 1024, "KB")


def version():
    m = re.search(r"^version:\s*([\d.]+)", (ROOT / "pubspec.yaml").read_text(encoding="utf-8"), re.M)
    return m.group(1) if m else "?"


def release_notes():
    """RELEASE_NOTES.md is generated from CHANGELOG.md (continuation lines joined) so the two never drift."""
    c = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
    body = c[re.search(r"^## \[\d", c, re.M).start():]  # skip the empty [Unreleased] block
    body = re.sub(r"\n- (.*)\n  (?=\S)", lambda m: "\n- " + m.group(1) + " ", body)
    for _ in range(3):  # bullets wrapped over several lines
        body = re.sub(r"\n  (?=\S)", " ", body)
    hdr = ("# Pagemark — Release Notes\n\nEvery release from the first (0.1.0) to the current one (" + version() + "), newest first. "
           "Releases are published at https://github.com/AxialForge/Pagemark/releases and the same text is inside the app under "
           "Settings → Updates → Version history.\n\n---\n\n")
    (PKG / "RELEASE_NOTES.md").write_text(hdr + body, encoding="utf-8")


def main():
    release_notes()
    parts = []
    for src, out in DOCS:
        text = (PKG / f"{src}.md").read_text(encoding="utf-8")
        print_pdf(to_html(text, out), PKG / f"{out}.pdf")
        parts.append(text)
    v = version()
    cover = f"""<div style="text-align:center;margin-top:110px">
<img src="{LOGO}" width="140" />
<h1 style="border:0;font-size:34pt;margin-bottom:0">Pagemark</h1>
<p style="font-size:15pt;margin-top:4px">Complete Documentation</p>
<p>Version {v}</p>
<p style="margin-top:40px">A private, fully local book tracker for Android</p>
</div>

<div style="margin:60px auto 0;width:70%">

**Contents**

1. Package Overview &mdash; simple, medium and advanced
2. Install Manual
3. User Manual
4. Release Notes

<p style="font-size:9pt;margin-top:40px">https://github.com/AxialForge/Pagemark &middot; &copy; 2026 AxialForge &middot; MIT License</p>
</div>"""
    brk = '\n\n<div style="page-break-before: always;"></div>\n\n'
    print_pdf(to_html(brk.join([cover] + parts), "Pagemark documentation"), PKG / "Pagemark-Documentation.pdf")


def publish_copies():
    """Copies the built PDFs into <project>/Documentation and writes a Word file of each document (with its pictures) beside them.
    The set shares one revision, '<name> Rev <major.minor>': the first build is 1.0, each rebuild the next minor; older files stay."""
    import shutil
    import importlib.util
    DOCUMENTATION.mkdir(exist_ok=True)
    spec = importlib.util.spec_from_file_location("bar", pathlib.Path(__file__).with_name("build_audit_report.py"))
    bar = importlib.util.module_from_spec(spec)
    src = pathlib.Path(__file__).with_name("build_audit_report.py").read_text(encoding="utf-8").rsplit("\nmain()", 1)[0]
    exec(compile(src, "build_audit_report.py", "exec"), bar.__dict__)
    first = DOCS[0][1]
    rev = bar.next_rev(DOCUMENTATION, first)
    titles = {"Pagemark-Package-Overview": "Package Overview", "Pagemark-Install-Manual": "Install Manual", "Pagemark-User-Manual": "User Manual",
              "Pagemark-Release-Notes": "Release Notes"}
    for src_name, out in DOCS:
        text = (PKG / f"{src_name}.md").read_text(encoding="utf-8").replace("{{VERSION}}", version())
        shutil.copyfile(PKG / f"{out}.pdf", DOCUMENTATION / f"{out} Rev {rev}.pdf")
        meta = [f"Version {version()}", f"Revision {rev}"]
        bar.build_docx(DOCUMENTATION / f"{out} Rev {rev}.docx", f"Pagemark {titles[out]}", meta, [(out, text)], base=PKG)
    shutil.copyfile(PKG / "Pagemark-Documentation.pdf", DOCUMENTATION / f"Pagemark-Documentation Rev {rev}.pdf")
    print("published revision", rev, "to", DOCUMENTATION)


if __name__ == "__main__":
    main()
    publish_copies()
