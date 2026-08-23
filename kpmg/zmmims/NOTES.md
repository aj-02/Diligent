# ZMMIMS — NOTES

## What it is

Corrections to `SAPMZMMIMS` (tcode `ZMMIMS`), a **pre-existing custom module pool** dating
to 2008 with change markers from several authors (+005, +012, +018). This work is marker
**+019** — GeM Invoice No. handling (F4 fix plus auto-display of the invoice number).

Four files, two whole includes and two fragments:

- `MZMMIMSF01.abap` (3,511 lines) — the FORM include.
- `MZMMIMSI01.abap` (2,002 lines) — the PAI / module include; screens 0100 / 0150 / 0200
  (`MODULE cancel_0100 INPUT`, `MODULE user_command_0100 INPUT`, `CALL SCREEN '0200'`,
  `CALL SCREEN '0150'`).
- `MZMMIMSI01_GET_GEMINV.abap` (136 lines) — the single replacement
  `MODULE get_geminv INPUT` (F4 help).
- `ZMMIMS_GEM_INV_AUTO_DISPLAY.abap` (172 lines) — a patch sheet: new
  `FORM get_gem_invoice_no` appended to `MZMMIMSF01`, plus three call points
  (`MODULE valid_input_200` for create, `FORM save_data_ims` as a safety net before the
  `MODIFY`, `FORM check_validation_150` for change / display of pre-existing documents).

## Gotchas

- `IST_RETURN_TAB` is declared `WITH HEADER LINE` in `MZMMIMSTOP` and is **shared by every
  search help in the program** (plant, purchasing group, currency, tracking no., indentor
  CPF). The original `GET_GEMINV` neither refreshed it nor guarded the assignment, so a
  cancelled or empty F4 left behind the value picked in a *different* search help — that is
  the "number appearing automatically". Always `CLEAR` **and** `REFRESH` it.
- `DELETE ADJACENT DUPLICATES` ran **before** the PO filter, so when one GeM invoice existed
  against several POs the surviving row could carry a different `EBELN` and got deleted —
  the correct invoice vanished from the hit list.
- `EBELN` was missing from the `WHERE` clause: the whole `ZGEM_BILL` table was joined against
  EKKO / LFA1 and read into memory on every F4.
- The `EKKO-BSART IN ('MMGM','MMGS') AND EKKO-PROCSTAT = '05'` restriction is retained but
  isolated in a RANGE so it can be switched off in one place. **If nothing is proposed,
  check `BSART` / `PROCSTAT` of the PO in SE16 first** — that restriction is the likeliest
  cause of an empty hit list.
- Auto-fill only ever writes into an **initial** field, so calling the FORM more than once is
  harmless and a user's own entry is never overwritten.
- Only invoices that also exist in `ZGEM_BILLDET` may be proposed — `MODULE check_geminv`
  validates against that table with a type E message, so proposing anything else makes the
  document unsaveable. With several GeM invoices on one PO the first (ascending) is filled
  and an information message is issued.
- The patch sheets locate their inserts by line number. Locate by FORM / MODULE name instead,
  and diff a fresh SE80 download against the repo copy before applying — the repo copy is a
  snapshot, not necessarily the running version.

## Dependencies

Tables `ZGEM_BILL`, `ZGEM_BILLDET`, `EKKO` (`ZGEMPO`), `LFA1`, `ZMM_IMS`.
Field `ZMM_IMS-GEM_INVOICE_NO` is persisted by the existing `MODIFY zmm_ims FROM wa_zmm_ims`
in `FORM save_data_ims`.

## Shipping: PASTE-ONLY

These are includes of a module pool with SE51 screens 0100 / 0150 / 0200; abapGit cannot
round-trip the screens, and two of the four files are fragments with named insertion points
rather than complete objects. No `src/`, no `.abapgit.xml`.

Apply in SE80 against a fresh download.

## Stays manual regardless

SE51 screens of `SAPMZMMIMS` and everything else in that pool — this work only touches
includes and never re-creates the program.
