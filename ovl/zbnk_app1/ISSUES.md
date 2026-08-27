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

**Status:** fix written and activated in OCQ/500 on 27.08.2026. **Not yet tested.**
Functional sign-off on the transmission-timing change still open. Do not move to QA/PRD
until both are done.

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


---

### Fix delivered 27.08.2026 — activated in OCQ, untested

| # | Object | Lines | Change |
|---|---|---|---|
| 1 | `ZFI_BNK_APP1_F01` | 1073 → 1188 | `F_PREPARE_OP_TAB2`: run-level `WHERE sent = ' '` filter commented out. New `FORM F_RUN_PENDING_COUNT` |
| 2 | `ZFI_BNK_APP1_I01` | 465 → 583 | `GET_SELECTED_ROW_TAB2` reordered |

Marker author `SAP_ABAP`, date 27/08/26. Originals preserved commented inside BOC/EOC.
Diffs verified: changes confined to the two regions named above, nothing else touched.

**New behaviour of `APPROVE2`:**

1. single-selection guard, e-token sign, verify, thumbprint check — all unchanged
2. write `ZFI_BATCH_SIGN` for the **selected batch only**, `COMMIT`; `ROLLBACK` and
   message on failure
3. `PERFORM f_run_pending_count` for the run
4. batches still pending → *"Batch approved. N of M batches in this run are approved -
   file not sent yet."*, stop
5. all approved → proxy send, `SENT = 'X'`, *"Run fully approved - file sent to the bank"*
6. run already sent → *"Approval saved. File for this run was already sent to the bank"*,
   **approval kept** (this is how the 21.08 orphans get their signature recorded)

`F_RUN_PENDING_COUNT` checks **both** levels, not only level 2: tab 2's worklist only
needs `FILE_DATA_SENT` populated, which one level-1 approval does for the whole run, so
a batch could otherwise reach the bank with neither signature.

**What the old code actually did — for the record.** It wrote exactly **one**
`ZFI_BATCH_SIGN` row, for the selected batch. Batches 002 and 003 never received
`DIGITL_SIGN = 'X'`. They were flagged sent at run level and dropped out of the
worklist. It was never three approvals from one click; it was one approval that marked
the run sent and made the other two batches unreachable.

### Open — must close before this leaves OCQ

1. **Functional sign-off** on the timing change: the bank file now waits until every
   batch in a run is approved at both levels. This changes when money moves.
2. **Test on a multi-batch run in QA.** Sequence: approve 1 of 3 → message says 1 of 3,
   `SENT` blank, 002/003 still listed; SE16 shows only 001 signed; approve 2nd, then 3rd
   → file sent once. Then the 21.08 run: 002/003 should reappear in tab 2 and approving
   them should say "already sent" while recording the signature.
3. **Tell the users.** The second signatory must now approve every batch of a run before
   the file goes out. Without warning this will come back as a "file not sent" ticket.
4. **What is in RAW_DATA — unresolved.** `ZFI_PAYMEDIUM_DMEE_20` has not been read. If
   the run's file covers all batches, unapproved payments did reach the bank on 21.08.
   If it covers only one batch, the other two were never transmitted at all and are
   stranded — a second defect. Check: `ZBNK_APP2` → Download Raw File on the 21.08 run,
   and see whether all three amounts appear.
5. **Falsification test not yet run:** `SE16 → ZFI_BATCH_SIGN`, `BATCH_NO` starting
   `OVL IN 20260821`. Expect one row with `DIGITL_SIGN = 'X'` at `SNRO = 2` and two
   blank. Three `X` rows would mean something else also writes signatures and the
   diagnosis is incomplete.
6. **`SNRO` is not in the key** of `ZFI_BATCH_SIGN` (key is `BATCH_NO` + `SIGNER`). A
   user configured as both level-1 and level-2 approver for one company code collapses
   to a single row, and `F_ENSURE_BATCH_SIGN`'s `ACCEPTING DUPLICATE KEYS` silently
   drops one. Not triggered here (68865 is level 2 only). DDIC key change if it bites.
7. **Transport release** — manual.
