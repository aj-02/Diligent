# ZMB5B — NOTES

## What it is

`ZRM07MLBD` — a Z copy of SAP standard `RM07MLBD` (MB5B), driven by tcode `ZMB5B`.
WRICEF 195_BRD_FS, project UDAY / Astral.

Two files, and only one of them is a program:

- `zrm07mlbd.abap` (6,206 lines) — the whole program.
- `ZMB5B_receipt_issue_amount.abap` (446 lines) — **not a program**: a 7-unit paste
  instruction sheet (UNIT 1–7 plus unit tests) for the receipt/issue-amount follow-up,
  each unit naming a target FORM and an approximate line number.

## What the change does

For radio button "Storage Loc./Batch Stock" (`LGBST`), adds **Receipt amount** and
**Issue amount** columns.

## Gotchas

- The two figures already exist as fields (`BESTAND-SOLLWERT` / `-HABENWERT`,
  `STYPE_TOTALS_FLAT-...`, both from include `RM07MLDD`) but the standard never fills
  them outside valuated stock. **Three gates** leave the columns empty if only the field
  catalog is touched:
  - `FORM summen_bilden` collects into `SUM_MAT` / `SUM_CHAR`, which carry `MENGE` only
    and have no `DMBTR`;
  - `FORM bestaende_berechnen` fills the values in the `BWBST = 'X'` branch only;
  - `FORM create_fieldcat_totals_flat` appends the amount columns in the `BWBST` branch only.
- `BESTAND-WAERS` is filled by `MOVE-CORRESPONDING g_s_mbew` in the `BWBST` branch only —
  in the `LGBST` branch the currency key is initial too, so even a correct amount renders
  without a currency or with the wrong one.
- `ANFWERT` / `ENDWERT` are deliberately **not** delivered: they derive from `MBEW-SALK3`,
  which does not exist per storage location. Only the two requested fields were added.
- The paste sheet's line numbers ("approx. line 3641", "approx. line 2572") are against one
  specific print. **Re-locate by FORM name, never by line number**, and diff a fresh SE38
  download against the repo copy before applying anything — the repo copy is a snapshot,
  not necessarily the running version.

## Dependencies

SAP standard includes `RM07MLDD`, `RM07MLBD_FORM_01`, `RM07MLBD_FORM_02` — kept under
their **standard names**, unchanged. The standard `ENHANCEMENT-POINT`s `rm07mlbd_g4`–`g7`
on spot `ES_RM07MLBD` are still present in the copy.

## Shipping: PASTE-ONLY

It is a copy of a standard SAP program and it includes SAP standard includes by their
standard names — abapGit cannot round-trip that, and a serialised pull would put the
standard includes at risk. There is no `src/` and no `.abapgit.xml` here.

Paste `zrm07mlbd.abap` in SE38, or apply the 7 units by hand.

## Stays manual regardless

- Creation of `ZRM07MLBD` itself and the `ZMB5B` transaction code (SE93).
- Never serialise or overwrite the four SAP standard includes.
