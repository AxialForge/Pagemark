# PGM-230 evidence: scan the committed PDFs for personal data and report the version string each one claims.
# Usage: python -I pgm230_pdf_scan.py <repo_root>   (needs pypdf; read-only)
import os, re, sys
import pypdf

root = sys.argv[1]
pdfs = [os.path.join(root, "docs", f) for f in os.listdir(os.path.join(root, "docs")) if f.endswith(".pdf")]
pdfs += [os.path.join(root, "docs", "release-package", f) for f in os.listdir(os.path.join(root, "docs", "release-package")) if f.endswith(".pdf")]
needles = [r"192\.168", r"Apocrypha", r"Costarella", r"josephkresevic", r"gmail", r"C:\\Users", r"joe963", r"storePassword"]
for p in sorted(pdfs):
    r = pypdf.PdfReader(p)
    text = "\n".join((pg.extract_text() or "") for pg in r.pages)
    vers = sorted(set(re.findall(r"Version\s+(\d+\.\d+\.\d+)", text)))
    hits = [n for n in needles if re.search(n, text)]
    print(os.path.relpath(p, root), "pages", len(r.pages), "versions-claimed", vers, "needles", hits)
