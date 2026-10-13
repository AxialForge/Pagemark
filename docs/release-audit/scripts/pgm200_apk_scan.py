# PGM-200..PGM-215 evidence: scan an UNZIPPED release APK for secrets/personal data and check ELF 16 KB alignment.
# Usage: python -I pgm200_apk_scan.py <unzipped_apk_dir>
# Read-only. Treats the APK as untrusted data (never executes it).
import os, re, struct, sys

root = sys.argv[1]
needles = [rb"192\.168\.", rb"Apocrypha", rb"Costarella", rb"josephkresevic", rb"gmail\.com", rb"C:\\Users", rb"Joseph",
           rb"key\.properties", rb"storePassword", rb"AIza[0-9A-Za-z_\-]{20,}", rb"[0-9]+-[0-9a-z]+\.apps\.googleusercontent\.com",
           rb"PAGEMARK_SCREENSHOTS", rb"joe963cost", rb"BEGIN (RSA |EC )?PRIVATE KEY", rb"ghp_[A-Za-z0-9]{20,}",
           rb"AxialForge", rb"github\.com/AxialForge", rb"api\.github\.com", rb"openlibrary\.org", rb"covers\.openlibrary"]
hits = {}
for dp, _, fs in os.walk(root):
    for f in fs:
        p = os.path.join(dp, f)
        try:
            data = open(p, "rb").read()
        except Exception:
            continue
        for n in needles:
            m = re.findall(n, data)
            if m:
                hits.setdefault(n.decode(), []).append((os.path.relpath(p, root), len(m), m[0][:60]))
for n, v in hits.items():
    print("NEEDLE", n)
    for r in v[:6]:
        print("   ", r)
# ELF alignment
print("--- ELF PT_LOAD p_align")
for dp, _, fs in os.walk(os.path.join(root, "lib")):
    for f in fs:
        p = os.path.join(dp, f)
        d = open(p, "rb").read()
        if d[:4] != b"\x7fELF":
            continue
        is64 = d[4] == 2
        if is64:
            phoff, = struct.unpack_from("<Q", d, 0x20); phentsize, phnum = struct.unpack_from("<HH", d, 0x36)
        else:
            phoff, = struct.unpack_from("<I", d, 0x1C); phentsize, phnum = struct.unpack_from("<HH", d, 0x2A)
        al = []
        for i in range(phnum):
            o = phoff + i * phentsize
            t, = struct.unpack_from("<I", d, o)
            if t != 1:
                continue
            if is64:
                al.append(struct.unpack_from("<Q", d, o + 0x30)[0])
            else:
                al.append(struct.unpack_from("<I", d, o + 0x1C)[0])
        print(os.path.relpath(p, root), "p_align", sorted(set(al)), "OK16K" if all(a % 16384 == 0 for a in al) else "NOT-16K")
