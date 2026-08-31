# ZFI_CP_MASS_VEN_PAY (tcode ZFIAPP) — OVL

Mass vendor payment + cheque creation. Module pool style: `START-OF-SELECTION` →
`get_vendors` → `CALL SCREEN 100` (vendor list) → screen 200 (open items of one vendor).

Includes: `ZFI_CP_MASS_VEN_PAY_TOP`, `ZFI_CP_MAS_VEN_AI001` (PAI/forms),
`ZFI_CP_MAS_VEN_BO001` (PBO), `ZFI_CP_MAS_VEN_E0001` (events).

## Flow on 'POST' (USER_COMMAND_0200)

    pre_post_checks → cal_tot_amt → get_confirmation
      → rem_pay_block        (payment block removal; S/4 fix routes through
                              zz_s4_bseg_zlspr → FI_DOCUMENT_CHANGE, no direct BSEG UPDATE)
      → bdc_f53              CALL TRANSACTION 'F-53' MODE 'N' UPDATE 'S'
      → get_mesg_f53         reads F5 312 → g_refdoc = payment document number
      → IF g_refdoc <> '' AND p_ch1 = 'X':
            gen_chec_number → find_chec_no (PCEC → next number)
                            → bdc_fch5    CALL TRANSACTION 'FCH5' MODE 'N'

Cheque number is **derived by the program** (`PCEC-CHECL + 1`, or `PCEC-CHECF` when
CHECL is blank) and handed to FCH5. SAP is never asked for the next free number.

## Gotchas

- **Two separate LUWs.** F-53 commits before FCH5 runs. Anything that goes wrong in the
  cheque step leaves the payment document posted with no cheque — there is no rollback.
- **The cheque step is fire-and-forget.** `bdc_fch5` ignores `sy-subrc` of the
  CALL TRANSACTION and only reads success message FS 568. Any FCH5 error is discarded
  and the user sees nothing.
- `find_chec_no` does not read PAYR (used / voided numbers) and does not test the derived
  number against the lot ceiling `PCEC-CHECT`. No lock either — two users get the same number.
- `g_gjahr` for FCH5 comes from `DATE_TO_PERIOD_CONVERT` with **hardcoded `i_periv = 'V3'`**;
  exceptions are commented out and `sy-subrc` is checked against an empty IF.
- Hardcoded in `bdc_f53`: `BKPF-BLART = 'BP'`, `BKPF-WAERS = 'INR'`, `RF05A-AGUMS = 'PF'`.
- Screens 0100/0200 are SE51 objects — **paste-only**, not in any download and not
  abapGit-serialisable. `p_ch1` (the cheque flag) is a plain DATA with `VALUE 'X'`; whether
  screen 0200 binds it to a checkbox has to be confirmed in SE51.
- Custom log table `ZFI_CP_VEND_DOCS` (BUKRS/LIFNR/BUDAT/BELNR/PDOCNR/CHECL) is written
  after F-53; CHECL is filled only if FCH5 reported FS 568.

## Source

`original/ZFI_CP_MASS_VEN_PAY.ABAP` is the ZR_PROG_DOWNLOAD listing of 08.08.2026 taken
from OCQ/500 for the ATC work (same file as `ovl/atc/sources/reports/`). It is **not**
verified against what is running in the production/dev client — ask for a fresh download
before changing anything.
