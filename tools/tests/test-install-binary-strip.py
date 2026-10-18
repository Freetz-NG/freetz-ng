#!/usr/bin/env python3
"""Exercise the actual installation macro in an isolated directory; no firmware build."""
import argparse, json, pathlib, shutil, subprocess
parser = argparse.ArgumentParser()
parser.add_argument("--workdir", required=True)
parser.add_argument("--elf", help="Existing dynamic ELF to copy and patch; never executed")
parser.add_argument("--patchelf", help="Native patchelf for target ELFs; defaults to tools/patchelf-target")
args = parser.parse_args()
repo = pathlib.Path(__file__).resolve().parents[2]
work = pathlib.Path(args.workdir).resolve()
work.relative_to(repo)
work.mkdir(parents=True, exist_ok=True)
text = (repo / "make/pkgs/Makefile.in").read_text()
start = text.index("define INSTALL_BINARY_STRIP\n")
macro = text[start:text.index("endef", start) + 5]
source = pathlib.Path(args.elf or shutil.which("true") or "").resolve()
patch_tool = pathlib.Path(args.patchelf).resolve() if args.patchelf else repo / "tools/patchelf-target"
if not source.is_file() or not patch_tool.is_file():
    parser.error("Provide an existing dynamic ELF with --elf and a native tool with --patchelf")
reader_tool = shutil.which("readelf")
if not reader_tool:
    parser.error("readelf is required")
if "INTERP" not in subprocess.check_output([reader_tool, "-l", str(source)], text=True):
    parser.error("The ELF fixture must have a PT_INTERP; it will never be executed")
results = []
for name, separate, reader, patcher, strip, expect in [
    ("missing-patchelf", "y", reader_tool, "/nonexistent/patchelf-target", "touch stripped", False),
    ("failing-patchelf", "y", reader_tool, "/bin/false", "touch stripped", False),
    ("failing-readelf", "y", "/bin/false", str(patch_tool), "touch stripped", False),
    ("failing-strip", "y", reader_tool, str(patch_tool), "/bin/false", False),
    ("separate-success", "y", reader_tool, str(patch_tool), "touch stripped", True),
    ("eval-rule-success", "y", reader_tool, str(patch_tool), "touch stripped", True),
    ("shared-success", "n", "/bin/false", "/nonexistent/patchelf-target", "touch stripped", True),
]:
    folder = work / name
    folder.mkdir(exist_ok=True)
    dest = folder / "out/busybox"
    dest.unlink(missing_ok=True)
    (folder / "stripped").unlink(missing_ok=True)
    makefile = folder / "Makefile"
    makefile.write_text("SHELL := /bin/bash\n" + macro + "\n" +
        f"FREETZ_SEPARATE_AVM_UCLIBC := {separate}\nTARGET_READELF := {reader}\nPATCHELF_TARGET := {patcher}\n" +
        f"TARGET_STRIP := {strip}\nFREETZ_LIBRARY_DIR := /usr/lib/freetz\n{dest}: {source}\n\t$(INSTALL_BINARY_STRIP)\n")
    if name == "eval-rule-success":
        recipe = "define TEST_RULE\n" + str(dest) + ": " + str(source) + "\n\t$(value INSTALL_BINARY_STRIP)\nendef\n$(eval $(TEST_RULE))\n"
        old = makefile.read_text()
        old = old[:old.index(str(dest) + ": " + str(source))] + recipe
        makefile.write_text(old)
    run = subprocess.run(["make", "-f", str(makefile)], cwd=folder, capture_output=True, text=True)
    (folder / "test.log").write_text(run.stdout + run.stderr)
    ok = (run.returncode == 0) == expect and dest.exists() == expect
    if not expect and name != "failing-strip":
        ok = ok and not (folder / "stripped").exists()
    if name == "separate-success":
        interp = subprocess.check_output([str(patch_tool), "--print-interpreter", str(dest)], text=True).strip()
        ok = ok and interp == "/usr/lib/freetz/ld-uClibc.so.1"
    results.append({"case": name, "exit": run.returncode, "destination_exists": dest.exists(), "passed": ok})
# Verify the exact production dependency fragment with parallel make and an existing configure stamp.
start = text.index("# Installation may patch ELF interpreters")
dep = text[start:text.index("# tools dont like", start)]
folder = work / "dependency-order"
folder.mkdir(exist_ok=True)
(folder / ".configured").touch()
(folder / "ready").unlink(missing_ok=True)
(folder / "Makefile").write_text("SHELL := /bin/bash\n.DEFAULT_GOAL := check\nFREETZ_SEPARATE_AVM_UCLIBC := y\nPKG := TEST\nTEST_DIR := .\n" + dep +
    "\n.PHONY: patchelf-target-host check\npatchelf-target-host:\n\t@sleep 0.1; touch ready\ncheck: .configured\n\t@test -f ready\n")
run = subprocess.run(["make", "-j4", "-f", "Makefile"], cwd=folder, capture_output=True, text=True)
(folder / "test.log").write_text(run.stdout + run.stderr)
results.append({"case": "parallel-dependency-existing-stamp", "exit": run.returncode, "passed": run.returncode == 0})
(work / "results.json").write_text(json.dumps(results, indent=2))
print(json.dumps(results, indent=2))
raise SystemExit(0 if all(r["passed"] for r in results) else 1)
