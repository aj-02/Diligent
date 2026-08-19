# diligent

SAP ABAP work — Arnav Johri, Diligent Tech India Pvt. Ltd.

Single consolidated repository. Everything lives on `main`; there are no per-topic
branches. Organised client / project first, then object.

## Layout

```
kpmg/                            KPMG engagements
  zmb5b/                         MB5B receipt & issue amount report (RM07MLBD copy)
  zmm_vend_upload/               Vendor master upload — ZMM_VEND_MASTER (FSD 30)
  zsd_scheme/                    Scheme (Pipes) — SD, Astral / Project UDAY
  zpp_forecast/                  Adhesive forecasting — ZFORECAST, Astral / Project UDAY

ovl/                             OVL
  atc/                           ECC→S/4 ATC remediation
    kb/                          Knowledge base + session handover notes
    worklists/                   ATC run exports, error lists, program sheets
    object-list/                 Objects in scope, by category (BDC / Dialog / Enhancement /
                                 Reports / Smartforms)
    corrections/                 Corrected sources + manual-review list
    sources/
      modpool/                   Module pools and their includes (MZ* / SAPMZ*)
      reports/                   Executable reports (Z* / Y*)
      changedoc/                 Generated change-document includes (F*CD[CFTV])
  zpra_dpr/                      ZPRA Daily Production Report — analytical RAP / CPI
  jv-cash-call/                  SAPMZOVL_JV_CASH_CALL module pool
  ocv-to-ovl-transfer/           Colombia OCV → OVL document transfer
  zf01_exchange_rate/            Exchange rate OData V2 interface (CPI → TCURR)
  mm-fiori/                      MM programs assessed for Fiori tiles
  ztest_t001/                    abapGit round-trip test (importable repo)
  COPILOT_CONTEXT_HANDOFF.md     Cross-project AI assistant context
```

Object folders use the same split where it applies:

| Folder | Holds |
|---|---|
| `src/` | Current ABAP source — what you'd paste or serialize into a system |
| `docs/` | BRD / FSD / TS, technical object lists, screen layouts, build guides |
| `drafts/` | Baselines, SE38 print listings, superseded deltas — history, not deliverables |

## Notes

- **kpmg/zmb5b** — `src/zrm07mlbd.abap` is the working copy of the `RM07MLBD` clone.
  `drafts/RM07MLBD_*.TXT` are SE38 print listings (tokens run together, page headers) and are
  *not* compilable; they are the baseline record only.
- **kpmg/zmm_vend_upload** — delivered as a delta against a print-listing baseline; see
  `drafts/README.md` for the change-unit table.
- **kpmg/zsd_scheme, kpmg/zpp_forecast** — `docs/00_TECHNICAL_OBJECTS.md` carries the full DDIC
  definitions (domains, data elements, tables, structures, lock objects, number ranges) that the
  ABAP in `src/` depends on. Read it before creating anything in a system.
- **ovl/atc/sources** — raw downloads of in-scope objects, split by kind. Corrected versions live
  in `ovl/atc/corrections/`, not here; treat `sources/` as the pre-remediation snapshot.
- **ovl/ztest_t001** — abapGit format (`.abapgit.xml` + `src/*.prog.abap|xml`). To import, zip that
  folder's contents (`.abapgit.xml` must be at the ZIP root) into an abapGit **offline** repo, or
  point an **online** repo at a repository whose root holds `.abapgit.xml`.

## Not in this repo

`.mcp.json` and `.claude/` hold system connection details — including a plaintext SAP password —
and stay local by design. Two archives are also ignored because their contents are already tracked
unpacked next to them (`final_code.zip`, `ZTEST_T001.zip`).

Superseded history for zmb5b / zmm_vend_upload remains on the branches of `aj-02/KPMG`, kept
untouched as a backup.
