# ovl/zbnk_app1 — issue log

## 2026-08-27 — all batches of a run released by one click of the second signatory

Reported against tcode `ZBNK_APP2`, but the defect is here in `ZFI_BNK_APP1`.
`ZBNK_APP2` (`ZFI_BNK_APP`) is a read-only monitor and merely displays the outcome.

Source: `ZFI_BNK_APP1.txt` (SE80, OCQ/500, SAP_ABAP, 27.08.2026 09:40) —
`ovl/zbnk_app1/original/ZFI_BNK_APP1.txt`. First download; no baseline, no drift.

**Reported evidence** — run 21.08.2026 / LAUFI 00002, all three flagged after one click:

    OVL IN 2026082100002  HB_01  001  21.08.2026  00002  X  X          3,882.00
    OVL IN 2026082100002  HB_01  002  21.08.2026  00002  X  X  2,257,792.00
    OVL IN 2026082100002  HB_01  003  21.08.2026  00002  X  X         14,000.00

Second signatory 68865 selected **one** batch. All three released.

**Status:** root cause confirmed in code. Fix is a design change and needs functional
sign-off before anything is written.

---

### Root cause — `ZFI_PAYM_FILE` is keyed per run, `REGUT` per batch

One `ZFI_PAYM_FILE` record exists per `LAUFD` + `LAUFI`. `REGUT` carries one row per
batch (`LFDNR` 001/002/003) inside that run. Every file read in both programs drops the
batch component:

    READ TABLE gt_paym2 INTO gs_paym2 WITH KEY laufd = gs_batch_header2-laufd
                                               laufi = gs_batch_header2-laufi.

No `DTKEY`, no `LFDNR`. All three ALV rows therefore point at the **same** file record —
identical `RAW_DATA`, identical `FILE_DATA_SENT`, one shared `SENT` flag. The grid
offers per-batch approval over data that only exists per run.

### The mechanism, step by step

1. `GET_SELECTED_ROW_TAB2` correctly enforces a single selection
   (`DESCRIBE ... IF lv_lines > 1 → 'Please select only single record'`). That guard is
   not the problem.
2. The e-token signs `gs_final2-file_data_sent` — which is the **run's** file, containing
   all three batches.
3. Proxy `sios_bank_interface_encryption` transmits it. All three batches go to the bank.
4. Then:

        gs_paym2-sent      = 'X'.
        gs_paym2-sent_date = sy-datum.
        MODIFY zfi_paym_file FROM gs_paym2.

   One run-level flag set.
5. `F_PREPARE_OP_TAB2` rebuilds the worklist from
   `SELECT * FROM zfi_paym_file ... WHERE sent = ' '`, then pulls REGUT
   `FOR ALL ENTRIES ... WHERE laufi = ... AND laufd = ...`. With the run flagged, **all**
   its batches vanish from tab 2 and surface in tab 3 (`WHERE sent = 'X'`).

Approving the 3,882.00 batch transmitted 2,257,792.00 and 14,000.00 with it.

### Collateral: sent-but-unsigned batches

`ZFI_BATCH_SIGN` is keyed correctly, per `GUID` (the full REGUT key). So batches 002 and
003 still hold `DIGITL_SIGN = ' '`. They are transmitted, unsigned, and unreachable from
any worklist — `F_PREPARE_OP_TAB2` can never show them again because their run is sent.

### Second instance of the same defect, tab 1

`GET_SELECTED_ROW_TAB1`:

    gs_paym-file_data_sent = doc_sig.
    MODIFY zfi_paym_file FROM gs_paym.

Also run-level. A first signatory signing batch 001 then batch 002 **overwrites** the
first signature. The file finally transmitted carries whichever level-1 signature was
applied last.

### Origin — the ECC→S/4 REGUT port

Under BCM, `BNK_BATCH_HEADER` gave one batch per run and every run-level assumption held.
`REGUT` gives many. `F_ENSURE_BATCH_SIGN` already documents the same collision in the
signature table:

> the DMEE format module `ZFI_PAYMEDIUM_DMEE_20` creates the approver rows using a
> PREDICTED LFDNR (`SELECT MAX( lfdnr ) + 1`) while REGUT is not yet committed. When
> several batches are created in one run the prediction repeats, so a later batch's
> MODIFY overwrites an earlier key

Someone patched the symptom in `ZFI_BATCH_SIGN`. Nothing patched it in `ZFI_PAYM_FILE`.

---

### Recommended fix (NOT yet written — needs functional sign-off)

The physical file genuinely is per run; DMEE emits one file for the run and batch 001
cannot be transmitted alone. Do not re-key the file table.

**Record the level-2 signature per batch; transmit only when every batch in the run is
signed.** In `GET_SELECTED_ROW_TAB2`, split the single block into:

1. always write the `ZFI_BATCH_SIGN` row for the selected batch;
2. count the run's REGUT batches (minus `F_SKIP_BATCHNO` exclusions) against signed
   level-2 rows;
3. only when none remain unsigned, call the proxy and set `SENT = 'X'`;
4. otherwise message *"Batch signed. N of M batches in this run still pending — file not
   yet sent."*

No DDIC change, no migration, four-eyes preserved on every batch.

Rejected alternative: re-key `ZFI_PAYM_FILE` to batch level. Table key change, migration,
and edits to `ZFI_PAYMEDIUM_DMEE_20` plus every reader — for no gain, since the file is
inherently per run.

**Blocked on:** functional confirmation that holding transmission until all batches in a
run carry level-2 approval is acceptable. It changes when money moves.

**Open verification:** SE11 → `ZFI_PAYM_FILE` → Fields tab. Asserting the key is
`LAUFD` + `LAUFI` (possibly + `ZBUKR`) with no batch component — inferred from every
`READ TABLE` in both programs, not yet read from DDIC.
