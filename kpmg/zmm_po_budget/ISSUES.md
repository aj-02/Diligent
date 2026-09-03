# Issues — ZMM_PO_BUDGET

Log format: date | issue | root cause | files changed | commit | TR


---

## 03/09/26 — Budget check behaves differently in QAS than in DEV

**Reported:** ME21N budget block works correctly in DEV, gives wrong result in QAS.
**Status:** OPEN — narrowed 03/09/26. No code changed yet.

**Screenshot from the QAS system confirms the `*BOC <002>` block is present and running there**,
so causes 3, 4 and 6 below are ruled out — the code is the right version, active, and reached
by the tester's transaction. The difference is data, or the missing `BSTYP` filter.

Arnav pointed at the `IF sy-subrc <> 0` branch, i.e. msg 002. If that is the message on the
ME21N screen, `SELECT SINGLE ... FROM zmm_po_budget` is finding no row in QAS — see causes 1,
2, 5 and "different test plant / purchasing group". The message text itself carries the plant,
purchasing group and year the SELECT used; read those three off the screen and SE16 the table
in that client with exactly those values.

Cause 1 is the most likely and is **not** a code fix: budget rows are master data on a
delivery-class-`A` table, so they must be maintained directly in QAS via SM30 / the
`ZMM_PO_BUDGET` parameter transaction. Making them transportable would mean changing the
delivery class from `A` to `C` in SE11 → Delivery and Maintenance — a design decision for the
functional consultant, needing a new table transport plus a customizing request for contents.

Awaiting confirmation of the message number (002 vs 001) before any code change, plus a fresh
SE19 download of the QAS implementation if the fix turns out to be the `BSTYP` filter.

The logic is identical in both systems, so the difference is data or object state — except
for one genuine defect that is only visible against realistic data.

### Defect (code) — consumed-budget SELECT counts non-PO documents

`ZME_PROCESS_PO_CUST_CHECK_full.abap`, inside the `*BOC <002>` block, the
`SELECT SUM( p~effwr ) FROM ekko AS k INNER JOIN ekpo AS p`:

1. **No `k~bstyp` restriction.** EKKO holds every purchasing document type — RFQ/quotation
   `A`, purchase order `F`, contract `K`, scheduling agreement `L`. Contracts and SAs for the
   same plant / purchasing group with `KNTTP = 'K'` are counted as consumed budget. DEV has
   only the handful of POs Arnav created, so the sum is right by accident; QAS carries
   contracts and SAs, so consumed is inflated and ME21N reports msg 001 "Budget has been
   exhausted" on a PO that is well inside budget.
   Fix: `AND k~bstyp = 'F'`.
2. **`EKPO-EFFWR` is in document currency, unfiltered.** Historic QAS POs in a foreign
   currency are summed at face value into an INR budget. DEV test data is single-currency so
   it never showed. Ties to open point 4 in `MANUAL_STEPS.md` §4.

### Environment causes, ranked

| # | Cause | Symptom | Check |
|---|---|---|---|
| 1 | Table has no rows in QAS. Delivery class is `A` (`CONTFLAG=A`), and SM30 on a class-A table does not write entries to a transport whatever the TMG recording routine says — the DEV rows never travelled. | every PO blocked, msg 002 | SE16 `ZMM_PO_BUDGET` in the QAS test client |
| 2 | Rows maintained in a different QAS client from the one being tested (table is client-dependent). | msg 002 | SE16, check `MANDT` |
| 3 | The QAS implementation is not Arnav's version. `ME_PROCESS_PO_CUST` is a shared impl carrying `<001>` Saurabh Saumya and other authors; the impl class is one object, so the last-imported TR overwrites it wholesale. | no check at all | SE19 QAS, search `*BOC <002>` |
| 4 | Impl or class inactive in QAS, or `ZMM_PO_BUDGET` / `ZMM_BUDGET` never transported — an abapGit import into a local DEV package produces no TR, and a missing table leaves the class inactive on import. | no check at all | SE19 active flag; SE11; SE91 |
| 5 | `lv_bud_gjahr = ls_header-bedat(4)` — budget row maintained for one year, tester's PO document date in another. | msg 002 | compare `EKKO-BEDAT` year with `GJAHR` |
| 6 | `sy-tcode` guard admits only ME21N / ME22N. A PR conversion via ME59N, classic ME21, or a Fiori app has a different or blank `sy-tcode`. | no check at all | ask the tester how the PO was created |
| 7 | Budget row `WAERS` blank or different from PO currency in QAS. | msg 008 not msg 001 | SE16 |

### First actions

1. SE19 in QAS → `ME_PROCESS_PO_CUST` → confirm the `*BOC <002>` block is present and the
   implementation is active.
2. SE16 `ZMM_PO_BUDGET` in the QAS test client — confirm a row exists for the plant /
   purchasing group / year under test, with a currency.
3. If msg 001 fires on a PO that is inside budget: SE16N on EKKO with `EKGRP` + `BEDAT` in
   the year + `LOEKZ` blank, and look at the `BSTYP` column. `K` or `L` rows present confirms
   the missing `BSTYP` filter.

### Not done deliberately

No code was changed. The repo copy is the DEV version as of 19/08/26 and may have drifted —
a fresh SE19 download of the QAS implementation is needed before editing, per the golden rule.
`MANUAL_STEPS.md` §3 still documents the alternative `ZCL_MM_PO_BUDGET_CHECK` design; if DEV
runs the inline block and QAS runs the class, that alone explains the difference and must be
ruled out first.
