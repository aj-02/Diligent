# ZSD_EXP_PAINTS.zip — what is in it, and what is NOT proven

Built 03/09/26 from `src/`. 19 files, 32 KB.

## Contents

| Objects | Count | In the ZIP |
|---|---|---|
| Domains | 5 | yes |
| Data elements | 6 | yes |
| Table ZSD_EXP_PAINTS | 1 | yes — fields, key, currency references, technical settings |
| Programs | 2 | yes — source **and** all text elements (TPOOL) |
| Table maintenance generator | 1 | **no — abapGit does not serialise a TMG, ever** |
| Foreign keys | 2 | **no — deliberately left out, see below** |

The TPOOL is the real saving: 54 text symbols + 5 selection texts for the upload program,
38 + 10 for the report. That is ~107 lines you would otherwise type into SE38 by hand.

## Import

`ZABAPGIT_STANDALONE` -> New Offline Repo -> Import package from ZIP -> Pull.
Import DDIC first, activate, then the programs — the programs do not activate until
ZSD_EXP_PAINTS is active.

## THE HONEST STATUS — read before relying on this

**No hand-written abapGit ZIP has ever been confirmed to import on this landscape.**
CLAUDE.md says so, and checking the evidence for this build made it worse, not better:

1. `kpmg/zfi_tds_cl34/` — four import attempts, all short-dumped `XML_FORMAT_ERROR` /
   `CX_XSLT_FORMAT_ERROR` in `FROM_XML`. Its `PROGDIR` order is correct, so that was ruled
   out and the root cause was never found. It shipped by paste.
2. `kpmg/zpp_forecast_v2/` — its NOTES.md calls it "the only object in this repository that
   ships this way cleanly", but **there is no record anywhere that its ZIP was ever
   imported**, and all three of its `prog.xml` files carry `PROGDIR` in the order
   `NAME, SUBC, FIXPT, VARCL, UCCHECK`. The correct order is
   `NAME, VARCL, SUBC, FIXPT, UCCHECK` (`varcl` is component 5 of
   `zif_abapgit_sap_report=>ty_progdir`, `subc` 11, `fixpt` 23, `uccheck` 30).
   `CALL TRANSFORMATION id` raises on the first out-of-sequence element, so the forecast
   ZIP would fail on `VARCL`. Copying its shape would have reproduced that defect.

**This ZIP uses the correct order**, verified after generation. That fixes one known
defect; it does not make the ZIP proven, because the `zfi_tds_cl34` failure was something
else and is still unexplained.

So: try the ZIP, and if it dumps, fall back to the manual path — `ZSD_EXP_PAINTS_DDIC.md`
for objects 1-3 and paste for the two programs. Nothing is lost by trying; do not schedule
around it working.

## Left out on purpose

- **Foreign keys** (`ZCUSTOMER` -> KNA1, `WAERS` -> TCURC). They serialise as
  `DD08V_TABLE` / `DD05M_TABLE`, which is more hand-written structure and more chance of
  the same format error. Add them in SE11 in two minutes — `ZSD_EXP_PAINTS_DDIC.md` §3.4,
  where SE11 proposes both.
- **Enhancement category.** Omitted rather than guessed. Set it after import:
  Extras -> Enhancement Category -> "Can be enhanced (deep)" (DDIC sheet §3.7).
- **Log data changes.** Tick it in Technical Settings after import (DDIC sheet §3.6).
- **The TMG.** Always manual, always (DDIC sheet §4).

## One value to check after import

`ZSD_DO_EXC_AMOUNT` carries `OUTPUTLEN 000031`, computed for CURR 23,2 with a sign, not
read off a system. If SE11 objects to it, blank the Output Length field and press Enter —
SE11 recalculates it from length + decimals.
