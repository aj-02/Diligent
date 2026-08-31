# ZFI_CP_MASS_VEN_PAY — issue log

| # | Date | Issue | Cause | Fix | TR |
|---|------|-------|-------|-----|-----|
| 1 | 31/08/26 | Sachin Thakur (F&A): earlier error gone, but ZFIAPP posted payment document 1726000164 (27.06.2026, co. code OVL) **without consuming a cheque** — FCHN shows "No check information was found"; last cheque in the register is 277581 dated 29.04.2026 | Diagnosed, not yet fixed — see below | open | — |

## Issue 1 — analysis (31/08/26, from the 08.08.2026 listing)

F-53 and FCH5 are two separate CALL TRANSACTIONs in two LUWs. The F-53 posting commits
(`UPDATE 'S'`) before the cheque step runs, and **every failure in the cheque step is
silent**, so the payment document survives with no cheque and no message to the user.

Three silent exits, all in `ZFI_CP_MAS_VEN_AI001`:

1. `find_chec_no` — `SELECT SINGLE * FROM pcec WHERE zbukr/hbkid/hktid/stapl`. When
   `sy-subrc <> 0` (wrong or exhausted lot on the selection screen) `g_checl` stays
   initial, `bdc_fch5` skips FCH5 on its `IF NOT g_checl IS INITIAL`, and nothing is said.
2. `bdc_fch5` — after `CALL TRANSACTION 'FCH5' MODE 'N'` the routine ignores `sy-subrc`
   and only reads the success message FS 568. Any FCH5 error (number already used,
   number voided, number outside `PCEC-CHECF..CHECT`, document/fiscal-year mismatch)
   is discarded. `ZFI_CP_VEND_DOCS-CHECL` also stays blank in that case.
3. The number itself is guessed: `g_checl = PCEC-CHECL + 1` (or `PCEC-CHECF` if CHECL is
   blank). PAYR is never read, so a number already used or **voided** — the register shows
   277579 "voided by 125511, destroyed/unusable" — is offered to FCH5 and rejected. The
   lot ceiling `PCEC-CHECT` is never tested either, so an exhausted lot fails the same way,
   on every run, from the moment the lot runs out.

Secondary trap in the same path: `g_gjahr` for FCH5 comes from `DATE_TO_PERIOD_CONVERT`
with hardcoded `i_periv = 'V3'`. If the company code's fiscal-year variant is not V3, the
year passed to FCH5 will not match the payment document for postings in Jan–Mar, and FCH5
fails — silently, as above.

`p_ch1` (the flag guarding `gen_chec_number`) is a plain `DATA ... VALUE 'X'`. If screen
0200 binds it to a checkbox, unticking it also skips the cheque with no message. SE51 0200
field list needed to confirm — screens are not in the download.

### Checks for Arnav / basis before coding the fix

- SE16 `PCEC` — ZBUKR / HBKID / HKTID / STAPL as entered on the ZFIAPP selection screen:
  does the row exist, and what are CHECF / CHECT / CHECL? If `CHECL + 1 > CHECT`, the lot
  is exhausted and that alone explains it (last cheque 277581, 29.04.2026).
- SE16 `PAYR` — ZBUKR/HBKID/HKTID, CHECT = CHECL+1: already used or voided?
- SE16 `PAYR` — VBLNR = 1726000164: expected empty (FCHN already says so).
- SE16 `ZFI_CP_VEND_DOCS` — PDOCNR = 1726000164: if the row exists with CHECL blank, the
  cheque step ran and failed (exits 2/3); if there is no row at all, F-53's success message
  was not caught either.
- SM35 / ST22 for the FCH5 CALL TRANSACTION at the time of posting.
- SE51 screen 0200: is `p_ch1` a checkbox the user can untick?

### Proposed fix (not yet written — needs a fresh SE80 download first)

- `find_chec_no`: message the user and abort the cheque step when PCEC is not found;
  loop forward from `CHECL + 1` to `CHECT`, skipping numbers already in PAYR (used or
  voided); message when the lot is exhausted.
- `bdc_fch5`: evaluate `sy-subrc` and the E messages from `ist_msgs`; on failure show the
  formatted FCH5 message plus the posted document number so the user knows a document
  exists without a cheque.
- `p_ch1 <> 'X'` path: tell the user the document was posted without a cheque.
- Optionally hold the derived number under `ENQUEUE_E_PCEC` (or a Z lock) across
  find/FCH5 so parallel users cannot take the same number.
