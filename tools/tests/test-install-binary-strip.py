#!/usr/bin/env python3
"""Test patchelf failure propagation; never execute the ELF fixtures."""
import argparse
import json
import os
import pathlib
import shlex
import shutil
import subprocess

parser = argparse.ArgumentParser(__doc__)
parser.add_argument("--workdir", required=True, help="New directory within this checkout")
parser.add_argument("--elf", help="Existing dynamic ELF fixture")
parser.add_argument("--patchelf", help="Existing native patchelf for the fixture")
parser.add_argument("--no-interp-elf", required=True, help="Existing ELF without PT_INTERP")
args = parser.parse_args()
repo = pathlib.Path(__file__).resolve().parents[2]
work = pathlib.Path(args.workdir).resolve()
work.relative_to(repo)
reader = shutil.which("readelf")
source = pathlib.Path(args.elf or shutil.which("true") or "").resolve()
patcher = pathlib.Path(args.patchelf or repo / "tools/patchelf-target").resolve()
no_interp = pathlib.Path(args.no_interp_elf).resolve()
env = dict(os.environ, LC_ALL="C")
for key in ("MAKEFLAGS", "MFLAGS", "MAKEFILES", "GNUMAKEFLAGS"):
    env.pop(key, None)
if not reader or not source.is_file() or not patcher.is_file():
    parser.error("Existing readelf, dynamic ELF and native patchelf are required")
def headers(p):
    return subprocess.check_output([reader, "-l", str(p)], env=env, text=True)
if "INTERP" not in headers(source):
    parser.error("--elf must have PT_INTERP")
if no_interp.read_bytes()[:4] != b"\x7fELF" or "INTERP" in headers(no_interp):
    parser.error("--no-interp-elf must be valid ELF without PT_INTERP")
def macro(path, name):
    text = path.read_text()
    start = text.index("define " + name + "\n")
    return text[start:text.index("endef", start) + len("endef")]
definitions = macro(repo / "make/include/300-helper.mk", "INSTALL_FILE") + "\n"
definitions += macro(repo / "make/pkgs/Makefile.in", "INSTALL_BINARY_STRIP") + "\n"
work.mkdir(parents=True, exist_ok=False)
script = work / "script"
script.write_text("#!/bin/sh\nexit 0\n")
missing = shlex.quote(str(work / "absent-patchelf"))
fail = "/bin/sh -c 'exit 23' --"
cases = [
    ("missing-patchelf", source, "y", missing, 127, False),
    ("failing-patchelf", source, "y", fail, 23, False),
    ("separate-success", source, "y", shlex.quote(str(patcher)), 0, False),
    ("eval-success", source, "y", shlex.quote(str(patcher)), 0, True),
    ("eval-failure", source, "y", fail, 23, True),
    ("shared-success", source, "", missing, 0, False),
    ("non-elf-skip", script, "y", missing, 0, False),
    ("no-interp-skip", no_interp, "y", missing, 0, False),
]
results = []
for name, fixture, separate, tool, status, use_eval in cases:
    folder = work / name
    folder.mkdir()
    # Strip replacement records whether execution reached the next command.
    text = "SHELL := /bin/bash\n" + definitions
    text += f"FREETZ_SEPARATE_AVM_UCLIBC := {separate}\nTARGET_READELF := {reader}\n"
    text += f"PATCHELF_TARGET := {tool}\nTARGET_STRIP := touch stripped\n"
    text += "FREETZ_LIBRARY_DIR := /usr/lib/freetz\n"
    text += "define TEST_RULE\nout: " + str(fixture) + "\n\t$(value INSTALL_BINARY_STRIP)\nendef\n$(eval $(TEST_RULE))\n" if use_eval else "out: " + str(fixture) + "\n\t$(INSTALL_BINARY_STRIP)\n"
    (folder / "Makefile").write_text(text)
    run = subprocess.run(["make", "-f", "Makefile"], cwd=folder, env=env, capture_output=True, text=True)
    log = run.stdout + run.stderr
    (folder / "test.log").write_text(log)
    success = status == 0
    passed = (run.returncode == 0) == success
    passed &= (folder / "out").exists() == success
    passed &= (folder / "stripped").exists() == success
    if not success:
        passed &= f"Error {status}" in log
    if success and separate == "y" and fixture == source:
        actual = subprocess.check_output([str(patcher), "--print-interpreter", str(folder / "out")], env=env, text=True).strip()
        passed &= actual == "/usr/lib/freetz/ld-uClibc.so.1"
    results.append(dict(case=name, exit=run.returncode, expected_patch_status=status, passed=passed))
(work / "results.json").write_text(json.dumps(results, indent=2) + "\n")
print(json.dumps(results, indent=2))
raise SystemExit(0 if all(r["passed"] for r in results) else 1)
