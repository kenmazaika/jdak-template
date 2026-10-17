#!/usr/bin/env python3
"""Smart conflict resolver for the Vault <-> Dropbox bisync.

bisync runs with --conflict-resolve none --conflict-loser num --conflict-suffix
sync-conflict, so when both sides changed the same file it renames BOTH copies
(path1 -> name.sync-conflict1, path2 -> name.sync-conflict2) and copies each to
both sides. Nothing is picked as a winner by a clock; nothing is discarded.

This worker is the "resolve it smartly" step:
  * 3-way merge (git merge-file) of the two sides against the last-synced base,
  * clean merge  -> write the canonical file, remove the conflict copies,
  * real conflict -> write the marker-annotated merge, stash both raw sides for
                     review, and REPORT it (escalate to the agent),
  * single side / binary -> restore the newest to the canonical name, stash the
                     other for review, REPORT it.

Exit codes: 0 = ok (changed nothing fatal), 10 = needs review, 2 = error.
Run without --apply to dry-run (report only).
"""
import argparse, json, os, re, subprocess, sys, tempfile, time, shutil

SUFFIX = re.compile(r"^(?P<canon>.+?)\.sync-conflict(?P<n>\d+)$")
LEGACY = re.compile(r"^(?P<canon>.+?)\.\.path(?P<n>[12])$")


def is_binary(path):
    try:
        with open(path, "rb") as f:
            return b"\x00" in f.read(8192)
    except OSError:
        return True


def read_text(path):
    with open(path, "r", encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def git_base(root, ref, canon):
    if not ref:
        return ""
    try:
        out = subprocess.run(
            ["git", "-C", root, "show", f"{ref}:{canon}"],
            capture_output=True, text=True, check=True,
        )
        return out.stdout
    except Exception:
        return ""


def scan(root):
    groups = {}
    for dirpath, _dirs, files in os.walk(root):
        if ".git" in dirpath.split(os.sep):
            continue
        for fn in files:
            m = SUFFIX.match(fn) or LEGACY.match(fn)
            if not m:
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, root)
            canon = os.path.relpath(
                os.path.join(dirpath, m.group("canon")), root)
            groups.setdefault(canon, []).append(rel)
    for g in groups.values():
        g.sort()
    return groups


def three_way(side_a, side_b, base_text):
    """Return (merged_text, conflicts:int, error:str|None)."""
    with tempfile.TemporaryDirectory() as td:
        b = os.path.join(td, "base")
        with open(b, "w", encoding="utf-8") as f:
            f.write(base_text)
        r = subprocess.run(
            ["git", "merge-file", "-p",
             "-L", "local", "-L", "base", "-L", "remote",
             side_a, b, side_b],
            capture_output=True, text=True,
        )
        if r.returncode < 0:
            return "", 0, (r.stderr.strip() or f"merge-file rc={r.returncode}")
        return r.stdout, r.returncode, None


def resolve(root, canon, sides, ref, review_dir, apply_):
    abs_canon = os.path.join(root, canon)
    entry = {"path": canon, "sides": sides, "action": None}
    texts = [read_text(os.path.join(root, s)) for s in sides]
    binary = any(is_binary(os.path.join(root, s)) for s in sides)

    if len(sides) == 1:
        entry["action"] = "restored"
        if apply_:
            os.makedirs(os.path.dirname(abs_canon) or root, exist_ok=True)
            shutil.copy2(os.path.join(root, sides[0]), abs_canon)
            os.remove(os.path.join(root, sides[0]))
        return entry, False

    if binary or len(sides) != 2:
        # can't merge: newest keeps the canonical name, others stashed for review
        ranked = sorted(
            sides, key=lambda s: os.stat(os.path.join(root, s)).st_mtime, reverse=True)
        entry["action"] = "binary_restore"
        entry["kept"] = ranked[0]
        entry["review"] = ranked[1:]
        if apply_:
            os.makedirs(review_dir, exist_ok=True)
            for s in ranked[1:]:
                shutil.copy2(os.path.join(root, s), os.path.join(review_dir, os.path.basename(s)))
                os.remove(os.path.join(root, s))
            shutil.copy2(os.path.join(root, ranked[0]), abs_canon)
            os.remove(os.path.join(root, ranked[0]))
        return entry, True

    a, bx = os.path.join(root, sides[0]), os.path.join(root, sides[1])
    merged, conflicts, err = three_way(a, bx, git_base(root, ref, canon))
    if err:
        entry["action"] = "error"
        entry["error"] = err
        return entry, True
    if conflicts == 0:
        entry["action"] = "merged"
    else:
        entry["action"] = "merge_conflict"
        entry["conflicts"] = conflicts
    if apply_:
        os.makedirs(review_dir, exist_ok=True)
        if entry["action"] == "merge_conflict":
            for s in sides:
                shutil.copy2(os.path.join(root, s), os.path.join(review_dir, os.path.basename(s)))
        os.makedirs(os.path.dirname(abs_canon) or root, exist_ok=True)
        with open(abs_canon, "w", encoding="utf-8", errors="surrogateescape") as f:
            f.write(merged)
        for s in sides:
            os.remove(os.path.join(root, s))
    return entry, entry["action"] in ("merge_conflict", "error")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--base-ref", default="")
    ap.add_argument("--suffix", default="sync-conflict")
    ap.add_argument("--review-dir", required=True)
    ap.add_argument("--report", default="")
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()

    root = os.path.abspath(args.root)
    groups = scan(root) if not args.suffix else scan(root)
    results, needs_review = [], []
    for canon, sides in sorted(groups.items()):
        entry, review = resolve(root, canon, sides, args.base_ref, args.review_dir, args.apply)
        results.append(entry)
        if review:
            needs_review.append(canon)

    report = {
        "ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "root": root, "base_ref": args.base_ref, "applied": args.apply,
        "conflicts": results, "needs_review": needs_review,
    }
    if args.report:
        os.makedirs(os.path.dirname(args.report), exist_ok=True)
        with open(args.report, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)
    print(json.dumps(report, indent=2))
    return 10 if needs_review else 0


if __name__ == "__main__":
    sys.exit(main())
