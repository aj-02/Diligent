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

**Leading hypothesis — truncated batch key from the BNK_BATCH_HEADER → REGUT port.**

`F_PREPARE_OP_TAB` builds the batch identity twice, into two differently-sized fields:

    ty_final-GUID  TYPE c LENGTH 45          "wide enough
    lv_key         TYPE zfi_batch_sign-batch_no   (domain BNK_COM_BTCH_NO)
    lt_keys        TYPE STANDARD TABLE OF zfi_batch_sign-batch_no

    CONCATENATE zbukr banks laufd laufi xvorl dtkey lfdnr INTO lv_key RESPECTING BLANKS.

The comment in `ZFI_BNK_APP_TOP` states the concatenation is 41 characters, and a
separate 45-char `GUID` field was introduced *because* `BATCH_NO` was not usable.
If `ZFI_BATCH_SIGN-BATCH_NO` is shorter than the full concatenation, `CONCATENATE`
truncates silently. `DTKEY` and `LFDNR` are the **last** two components and are the
only ones that differ between batches 001 / 002 / 003 of the same run — they are the
first to be cut off.

The consequence is that all three batches collapse onto one key:

- `DELETE ADJACENT DUPLICATES FROM lt_keys` reduces the three to one;
- the release program (same table, presumably the same key construction) writes **one**
  `ZFI_BATCH_SIGN` row;
- `READ TABLE gt_batch_sign ... WITH KEY batch_no = lv_key` then matches that single
  signature row against **all three** REGUT rows.

So the second signatory may well have released once. The display — and, depending on
the release program, the actual authorisation — treats it as three.

**To confirm (Arnav, no system access here):**

- SE11 → data element `BNK_COM_BTCH_NO` → domain → output length. Compare against the
  real sum of `REGUT-ZBUKR`(4) + `BANKS`(3) + `LAUFD`(8) + `LAUFI`(6) + `XVORL`(1) +
  `DTKEY` + `LFDNR`. If it is short, this is the cause.
- SE16 → `ZFI_BATCH_SIGN` for run LAUFD 21.08.2026 / LAUFI 2026082100002. **One** row
  where three are expected confirms it outright.
- SE93 → `ZBNK_APP2` → the program actually behind the tcode, and whether the release
  button lives there or in a second program.

**Open:** the release program itself, screen 100 flow logic, GUI status.
