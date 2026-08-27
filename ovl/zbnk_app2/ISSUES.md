# ovl/zbnk_app2 — issue log

## 2026-08-27 — two issues reported against tcode ZBNK_APP2

Source supplied: `ZFI_BNK_APP.txt` (SE80, OCQ/500, SAP_ABAP, 27.08.2026 09:15) —
filed at `ovl/zbnk_app2/original/ZFI_BNK_APP.txt`. First download of this object;
no repo baseline existed, so no drift to report.

---

### Issue 1 — Back (F3) / Exit / Cancel dead after the batch list is displayed

**Status:** cause identified in the ABAP; needs SE51 + SE41 to confirm and fix.

`ZFI_BNK_APP_I01`, `MODULE USER_COMMAND_0100 INPUT`:

    lv_code = sy-ucomm.
    CASE lv_code.
      WHEN 'E'.
        LEAVE TO SCREEN 0.
    ENDCASE.

Only `'E'` is handled. `BACK`, `EXIT` and `CANC` — the codes the standard F3 /
Shift+F3 / F12 keys carry in almost every GUI status — fall straight through the
`CASE` and nothing happens. That is the reported symptom exactly.

Three things must be confirmed before the fix is written:

1. SE41 → the status actually set on screen 100: the real function codes behind
   F3 / Shift+F3 / F12, and whether any is typed `E` (Exit command).
2. SE51 → screen 100 flow logic: which PAI modules run, in what order, and whether
   any module carries `AT EXIT-COMMAND`. Without one, a module cannot fire ahead of
   field processing.
3. SE51 → whether `SET PF-STATUS` is issued anywhere; `MODULE STATUS_0100` has it
   commented out.

Contributing: `SY-UCOMM` is never cleared, so a stale code survives the round trip.

**Not** caused by the ALV container — `LEAVE TO SCREEN 0` from a normal PAI module is
valid with a `CL_GUI_CUSTOM_CONTAINER` on the screen.

---

### Issue 2 — one batch selected, all batches of the run released by signatory 68865

Reported rows (all three flagged X X after a single release):

    OVL IN 2026082100002  HB_01  001  21.08.2026  00002  X  X          3,882.00
    OVL IN 2026082100002  HB_01  002  21.08.2026  00002  X  X  2,257,792.00
    OVL IN 2026082100002  HB_01  003  21.08.2026  00002  X  X         14,000.00

**Status:** release code not yet supplied. `ZFI_BNK_APP` contains no release,
approval or signature-write logic of any kind — it only reads `ZFI_BATCH_SIGN` to
fill the `PENDING_WITH` column. The program that writes the signature is a different
object and has not been downloaded.

**Hypothesis tested and DISPROVEN (27.08.2026): batch-key truncation.**

Proposed cause was that `F_PREPARE_OP_TAB` builds a 41-char composite key into
`lv_key TYPE zfi_batch_sign-batch_no` and `CONCATENATE` truncates it silently
(`SY-SUBRC = 4`, never checked), collapsing batches 001/002/003 onto one key.

Killed by three checks:

| Check | Result |
|---|---|
| SE11 `BNK_COM_BTCH_NO` length | NUMC 10 — but this is the data element on `ty_final-batch_no`, **not** on `ZFI_BATCH_SIGN-BATCH_NO`, which is what `lv_key` inherits. Wrong field checked. |
| SE16 `ZFI_BATCH_SIGN` `BATCH_NO > 9999999999` | 0 rows — no alpha-truncated keys stored |
| SE16 `ZFI_BATCH_SIGN` `BATCH_NO = 2026082100` | 0 rows — no numeric-truncated keys stored |

Decisive counter-argument from the code itself: `F_PREPARE_OP_TAB` appends to the grid
**only** when a signature row matches (`READ TABLE gt_batch_sign ... IF sy-subrc EQ 0`).
Three rows are displayed, so three distinct keys matched three distinct signature
records. The keys are not colliding.

`ZFI_BATCH_SIGN-BATCH_NO`'s real type is still unverified — SE11 Fields tab still open.

**SE93 confirmed:** `ZBNK_APP2` → program `ZFI_BNK_APP`, selection screen 1000,
package `ZFI_OTH`, text "Bank Batch". Right object; it simply contains no release code.

**Where-used on `ZFI_BATCH_SIGN` (11 hits) — the writer is one of these:**

| Object | Type | Note |
|---|---|---|
| `ZFI_BNK_APP1_TOP` / `_F01` / `_I01` | includes | sibling screen program — **prime suspect**, likely tcode ZBNK_APP1 |
| `ZFI_BNK_APP_F` / `_TOP` | includes | this monitor, read-only |
| `ZFI_BNK_APRV_MON` | program | "Monitor BNK process" |
| `ZBCM_BNK_SEND_MAIL` | FM | "BCM Bank App send mail" |
| `ZFI_PAYMEDIUM_DMEE_20` | FM | "Interface Btwn Paymt Program->DMEE 20" |
| `ZBCM1` | enhancement impl | "bcm digital signaute" |
| `ZBCM4` | enhancement impl | "bcm signature" |
| `ZBCM_SIGN` | enhancement impl | — |

Two candidate release paths: the Z program `ZFI_BNK_APP1`, or standard BCM approval
with the three `ZBCM*` enhancements hooked in.

**Next:** download `ZFI_BNK_APP1` with its include tree; confirm SE93 `ZBNK_APP1`.
Ask the user which transaction 68865 actually released from — if it is a standard BCM
approval screen, the defect is in `ZBCM1` / `ZBCM4` / `ZBCM_SIGN` instead.

**Working expectation, untested:** the release routine loops the full internal table
(or re-reads by `LAUFD`/`LAUFI`) rather than restricting to the rows returned by
`get_selected_rows`.

**Open:** `ZFI_BNK_APP1` source, `ZBCM*` sources, `ZFI_BATCH_SIGN` field list,
screen 100 flow logic, GUI status.
