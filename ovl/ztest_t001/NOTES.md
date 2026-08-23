# ZTEST_T001 — NOTES

## What it is

The smallest possible abapGit repository: one executable report
(`REPORT ztest_t001.` → `WRITE / 'Hello World'`), no DDIC, no package object, no
dependencies. Purpose is to prove the offline-ZIP (or online-clone) import path works on a
system with no ADT connection, before risking a real object on it.

## Contents

- `.abapgit.xml` at repo root — `STARTING_FOLDER /src/`, IGNORE `.gitignore` / `LICENSE` /
  `README.md`.
- `src/ztest_t001.prog.abap` (10 lines).
- `src/ztest_t001.prog.xml` — TRDIR attributes + report title text.

Duplicated as `ZTEST_T001.zip` at the repository top level (4 files).

## Gotchas

- **`.abapgit.xml` must be at the git repository root** — abapGit always reads it from there,
  never from a subfolder. For an **online** clone this folder must either be pushed as its own
  standalone repository (it is already laid out as one), or the containing repository needs an
  `.abapgit.xml` at *its* root with `<STARTING_FOLDER>/ztest_t001/src/</STARTING_FOLDER>`.
- Verification step that is easy to skip and worth doing: after the pull, open abapGit's
  diff / stage view. A freshly pulled object should show **zero** local changes against the
  repo. Any diff means a field in the XML did not round-trip — which is exactly the failure
  mode you are testing for.
- `$TMP` will not prompt for a transport; a transportable package will.
- The ZIP contains `README.md` even though `.abapgit.xml` lists it under `IGNORE` — harmless
  (abapGit skips it on deserialise) but **do not read the ZIP listing as proof the IGNORE list
  works**.

## Shipping: abapGit ZIP

SE38 → `ZABAPGIT_STANDALONE` → New Offline → Import package from ZIP → Pull →
run `ZTEST_T001`, expect `Hello World`.
