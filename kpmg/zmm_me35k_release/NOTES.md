# ZMM_ME35K_RELEASE — NOTES

## What it is

ECC → S/4 (system OCQ, S4 2025_1_A) regression: the custom release transaction `ZMMME35K`
stopped releasing after conversion. `README.md` records it as fixed and confirmed working —
that is the author's claim; nothing here is reproducible from the repo alone.

Every object involved is a frozen 2003 Z copy of SAP standard code:
`ZMM_RM06EF00` ← `RM06EF00`, `SAPMZFM06L` ← `SAPFM06L` (270 includes, 269 of them still SAP
standard), `ZFM06LFFR` ← `FM06LFFR`, plus `ZMM_FM06LTO1` / `ZMM_FM06LCFR` / `ZMM_FM06LCEK`.
Package ZMM_PO.

Three files, two of which are edit instructions rather than whole objects:

- `ZFM06LFFR_FRG_SET.abap` (602 lines) — **new Z include**, main program `SAPMZFM06L`;
  restores the custom `FORM frg_set` plus `GET_1ST_PR_REL_DT` / `GET_ALL_OLAS_PRS` /
  `GET_OLA_PR_DTL` / `GET_OLD_PR_DTL_R`.
- `ZFM06LFFR_change.abap` (40 lines) — the one-line include swap inside `ZFM06LFFR`.
- `ZMM_RM06EF00_perform_fix.abap` (72 lines) — 13 `PERFORM` target corrections
  `(sapfm06l)` → `(sapmzfm06l)`.

## Root causes

1. `FEKKO` is declared in `FM06LFFR` as a plain program-local table — it is **not** in a
   `COMMON PART` (only `XEKKO` is, via `FM06LCFR`). Every program including `FM06LFFR`
   therefore owns a private `FEKKO`. `ZMM_RM06EF00` built `FEKKO` by calling into
   `SAPFM06L` but handled the click by calling into `SAPMZFM06L`, so `FRG_SET` read an empty
   table and exited silently on `CHECK sy-subrc EQ 0`; `FRG_UPDATE` then found no
   `UPDKZ = 'U'` and reported `06 022 "No data changed"`. The same split emptied `HIDK`.
2. On S/4, `ZFM06LFFR` was rebuilt from the modular SAP standard and now reads
   `INCLUDE FM06LFFR_FRG_SET` — SAP's own routine. The CR 30011813 header and the
   `ist_ola_pr_hdr` / `wa_ola_pr_rec` declarations survived at the top; every custom block
   inside `FRG_SET` was lost.

## Fixes

- Route all 13 live `PERFORM`s in `ZMM_RM06EF00` to `(sapmzfm06l)` — line 343
  (`frg_fekko_aufbauen`) is the actual defect; 343, 413 and 425 carry the `HIDE`.
- New include `ZFM06LFFR_FRG_SET` (main program `SAPMZFM06L`) restoring the custom `FRG_SET`
  and its helper FORMs, wired in by swapping exactly one include line in `ZFM06LFFR`.

## Gotchas

- **Never edit SAP's `FM06LFFR_FRG_SET`.** `SAPFM06L` shares it, so standard ME35K / ME28 /
  ME35L would change for every user.
- **Do not activate `BDP_CHECK`, `CHECK_FINAL_REL` or `READ_CHANGE_DOC`** in `ZMM_RM06EF00`
  without a business decision. They are defined and never called — in ECC as well as S/4 —
  and implement tender-committee governance. Note that `CHECK_FINAL_REL` does
  `SELECT ... WHERE ebeln IN s_ebeln` then `READ TABLE ... INDEX 1`, judging the whole list
  by its first document.
- Activation order: `ZFM06LFFR_FRG_SET` → `ZFM06LFFR` → `ZMM_RM06EF00` → `SAPMZFM06L`.
  Syntax-check from `SAPMZFM06L`, not from the include.
- Prerequisites on S/4: message class `ZMM` msg 192, `ZMM_OTH` msg 239, and
  `ist_ola_pr_hdr` / `wa_ola_pr_hdr` declared in `ZFM06LFFR` (already present).
- Deliberate differences from the ECC source: `ME_REL_SET` keeps the S/4 standard
  `EXCEPTIONS` block with E102 / E103 / E104 handling (ECC has it commented out, which risks
  a short dump); `FORM ITERATION` is not carried over (its only call site is commented out in
  ECC, superseded by `GET_ALL_OLAS_PRS`); dead commented blocks dropped. No executable
  statement changed.
- Line numbers in `ZMM_RM06EF00_perform_fix.abap` refer to the 21.08.2026 print. Locate by
  FORM name and diff a fresh SE38 download before applying.

## Known, not fixed, carried forward

- `lo_buffer->close( )` deleted, so `CL_MMBSI_SRM_CTR_BUFFER` is never reset.
- `PERFORM start_via_table_manager` deleted, so ZMMME35K stays on classic WRITE lists.
- The clone predates SAP notes since 2005 (`SELOPT_CNT_CALL`, T160L / note 1876863,
  enhancement points all missing).
- With `MM_SFWS_P2PSE`, `BSTYP='K'` + `STATU='K'` documents are deleted from the list, so
  central contracts can silently disappear.
- `MESSAGE a239` reads `wa_ekko_ola-bedat` after the LOOP ended, so with several OLAs it
  reports whichever was read last.
- `SY-TCODE = ZMMME35K` is passed to `ME_PURCHASE_DOCUMENT_DATA_READ` and needs a T160 entry.

## Shipping: PASTE-ONLY

Modifications to Z copies of standard SAP programs, plus an include that belongs to a module
pool's form pool — abapGit cannot round-trip these, and two of the three files are edit
instructions (a one-line include swap, a list of 13 PERFORM corrections), not whole objects.

Strategic note: the long-term target is to move the genuine business logic into a BAdI or a
Flexible Workflow precondition and leave SAP's ME35K untouched.

## Stays manual regardless

Creating include `ZFM06LFFR_FRG_SET` and assigning `SAPMZFM06L` as its main program;
the include-line swap in `ZFM06LFFR`; the 13 PERFORM corrections; activation in the order
above; the T160 entry for `ZMMME35K`.
