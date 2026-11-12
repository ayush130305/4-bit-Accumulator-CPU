#!/usr/bin/env python3
# drc_report_txt.py - Plain-text DRC report (SCL wants <name>_drc.txt) from a KLayout .lyrdb
# Lists every rule category of the deck with its violation count.
# Usage: python3 flow/drc_report_txt.py <drc.lyrdb> <gds> <deck> <top> <out.txt>
import datetime, os, re, subprocess, sys, xml.etree.ElementTree as ET

rdb, gds, deck, top, out = sys.argv[1:6]
root = ET.parse(rdb).getroot()
cats = [(c.findtext("name") or "").strip("'") for c in root.iter("category")]
desc = {(c.findtext("name") or "").strip("'"): (c.findtext("description") or "") for c in root.iter("category")}
counts = {c: 0 for c in cats}
for it in root.iter("item"):
    counts[(it.findtext("category") or "").strip("'")] = counts.get((it.findtext("category") or "").strip("'"), 0) + 1
kver = subprocess.run(["klayout", "-v"], capture_output=True, text=True).stdout.strip()
total = sum(counts.values())
with open(out, "w") as f:
    f.write("DRC REPORT\n")
    f.write("==========\n")
    f.write("Layout     : %s\n" % os.path.basename(gds))
    f.write("Top cell   : %s\n" % top)
    f.write("Rule deck  : %s (modified %s)\n" % (deck, datetime.datetime.fromtimestamp(os.path.getmtime(deck)).strftime("%d-%m-%Y")))
    f.write("Tool       : %s\n" % kver)
    f.write("Run date   : %s\n" % datetime.datetime.now().strftime("%d-%m-%Y %H:%M"))
    f.write("Rule checks: %d\n" % len(cats))
    f.write("Violations : %d\n" % total)
    f.write("Result     : %s\n\n" % ("CLEAN" if total == 0 else "NOT CLEAN"))
    f.write("%-8s  %s\n" % ("Count", "Rule"))
    f.write("%-8s  %s\n" % ("-----", "----"))
    for c in cats:
        f.write("%-8d  %s\n" % (counts[c], c))
print("DRC_TXT: %d rules, %d violations -> %s" % (len(cats), total, out))
