# diligent

SAP ABAP work — Arnav Johri, Diligent Tech India Pvt. Ltd.

Single consolidated repository. Everything lives on `main`; there are no
per-topic branches. Organised client / project first, then object.

## Layout

```
kpmg/                          KPMG engagements
  zmb5b/                       MB5B receipt & issue amount report (RM07MLBD copy)
  zmm_vend_upload/             Vendor master upload — ZMM_VEND_MASTER (FSD 30)
  zsd_scheme/                  Scheme (Pipes) — SD, Astral / Project UDAY
  zpp_forecast/                Adhesive forecasting — ZFORECAST, Astral / Project UDAY
ovl/                           OVL
  zpra_dpr/                    ZPRA Daily Production Report — analytical RAP / CPI
  ztest_t001/                  abapGit round-trip test (importable repo)
  COPILOT_CONTEXT_HANDOFF.md   Cross-project AI assistant context
```

Each object folder uses the same three-way split:

| Folder | Holds |
|---|---|
| `src/` | Current ABAP source — the thing you'd actually paste or serialize into a system |
| `docs/` | BRD / FSD / TS, technical object lists, screen layouts, build guides |
| `drafts/` | Baselines, SE38 print listings, superseded delta drafts — history, not deliverables |

## Notes per object

- **zmb5b** — `src/zrm07mlbd.abap` is the working copy of the `RM07MLBD` clone. `drafts/RM07MLBD_initial.TXT`
  and `RM07MLBD_final.TXT` are SE38 print listings (tokens run together, page headers) and are
  *not* compilable; they are kept as the baseline record only.
- **zmm_vend_upload** — delivered as a delta against a print-listing baseline; see
  `drafts/README.md` for the change-unit table.
- **zsd_scheme / zpp_forecast** — `docs/00_TECHNICAL_OBJECTS.md` carries the full DDIC definitions
  (domains, data elements, tables, structures, lock objects, number ranges) that the ABAP in `src/`
  depends on. Read it before creating anything in a system.
- **ovl/ztest_t001** — laid out in abapGit format (`.abapgit.xml` + `src/*.prog.abap|xml`). To import
  it, either zip that folder's contents (`.abapgit.xml` must be at the ZIP root) and use an abapGit
  **offline** repo, or point an **online** repo at a repository whose root holds `.abapgit.xml`.

## Not in this repo

`.mcp.json` and `.claude/` hold system connection details and stay local by design.
Superseded history for zmb5b / zmm_vend_upload also remains on the branches of `aj-02/KPMG`,
which is kept untouched as a backup.
