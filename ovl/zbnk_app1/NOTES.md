# ovl/zbnk_app1 — ZFI_BNK_APP1 (bank batch approval / digital signature)

## What it is

Module pool `ZFI_BNK_APP1`, tcode expected `ZBNK_APP1` (confirm in SE93). Tabstrip
with three tabs, each its own ALV grid and its own container:

| Tab | Function code | Worklist built by | Meaning |
|-----|---------------|-------------------|---------|
| 1 | `APPROVE1` | `F_PREPARE_OP_TAB1` | first signatory (`SNRO = '1'`) |
| 2 | `APPROVE2` | `F_PREPARE_OP_TAB2` | second signatory (`SNRO = '2'`) — signs *and transmits* |
| 3 | `DOWNLOAD1` / `DOWNLOAD2` | `F_PREPARE_OP_TAB3` | already sent (`ZFI_PAYM_FILE-SENT = 'X'`) |

Include tree (complete, 6 includes):

| Include | Lines | Contents |
|---|---|---|
| `ZFI_BNK_APP1_TOP` | 108 | `ty_final`, three parallel sets of globals (1/2/3), tabstrip controls |
| `ZBCM_CLASS` | 60 | local class definition |
| `ZBCM_CLASS_DECLARE` | 301 | `lcl_file_verifier` implementation |
| `ZFI_BNK_APP1_O01` | 161 | PBO modules |
| `ZFI_BNK_APP1_I01` | 465 | PAI — `GET_SELECTED_ROW_TAB1/2/3`, `USER_COMMAND_0100/0101/0102/0103` |
| `ZFI_BNK_APP1_F01` | 1073 | worklist builders, fieldcats, `F_ENSURE_BATCH_SIGN`, `F_LOAD_REGUHM`, `F_SKIP_BATCHNO`, downloads, `FREE_OBJECTS1/2` |

## PASTE-ONLY

Module pool with SE51 screens, tabstrip subscreens and SE41 statuses. abapGit does not
serialise these. No `src/`, no `.abapgit.xml`.

## Signing chain

`SSFS_CALL_CONTROL` (e-token signs the document) → `SSFS_SERVER_VERIFY` → thumbprint
checked against `ZUSER_SIGNER` for `SY-UNAME` with `ACTIVE = 'X'`. Tab 2 additionally
calls proxy `ZCO_SIOS_BANK_INTERFACE_ENCRYP` → `sios_bank_interface_encryption`, which
is the actual transmission to the bank.

Approver assignment comes from `ZFI_BNK_RULE`: rule `90700005` = level 1,
`90700006` = level 2, matched on `ZRULE_ID = REGUT-ZBUKR`.

## The governing defect — run-level vs batch-level

**`ZFI_PAYM_FILE` holds one record per payment run (`LAUFD` + `LAUFI`). `REGUT` holds one
row per batch (`LFDNR`) within that run.** Every `READ TABLE gt_paymN ... WITH KEY laufd =
... laufi = ...` in this program and in `ZFI_BNK_APP` ignores `DTKEY`/`LFDNR`, so all
batches of one run share a single file record — same `RAW_DATA`, same `FILE_DATA_SENT`,
same `SENT` flag.

Consequences, all live:

- tab 2 approval on any one batch sets `SENT = 'X'` for the whole run and transmits the
  file containing every batch;
- the tab-2 worklist (`WHERE sent = ' '`) then drops all sibling batches;
- tab 1 approval writes `FILE_DATA_SENT = doc_sig`, so a second level-1 signature in the
  same run overwrites the first;
- sibling batches keep `ZFI_BATCH_SIGN-DIGITL_SIGN = ' '` — sent but unsigned, and
  unreachable from any worklist.

This is fallout from the ECC→S/4 port: `BNK_BATCH_HEADER` gave one batch per run,
`REGUT` gives many. See ISSUES.md.

## Existing patch for the same disease

`F_ENSURE_BATCH_SIGN` (F01) self-heals missing approver rows because
`ZFI_PAYMEDIUM_DMEE_20` creates them against a **predicted** `LFDNR`
(`SELECT MAX( lfdnr ) + 1`) before REGUT is committed — the prediction repeats across
batches in one run and later rows overwrite earlier ones. Same root assumption, patched
in the signature table only.

`F_SKIP_BATCHNO` / `F_LOAD_REGUHM` exclude batches that already carry a `REGUHM-BATCHNO`.

## Gotchas

- Three near-duplicate code paths (`*1` / `*2` / `*3` globals) — a fix in one is not a
  fix in the others.
- `USER_COMMAND_0100` is entirely commented out.
- `BACK` / `CANCEL` / `EXIT` **are** handled here (`LEAVE PROGRAM`) — unlike the sibling
  monitor `ZFI_BNK_APP`, where they are missing. See `ovl/zbnk_app2/ISSUES.md` issue 1.
- Tab 1's `MODIFY zfi_paym_file` runs before the signature row is written, with no
  `COMMIT`/rollback pairing between the two.

## Related objects

`ZFI_PAYM_FILE`, `ZFI_BATCH_SIGN`, `ZFI_BNK_RULE`, `ZUSER_SIGNER`, `REGUT`, `REGUHM`,
FM `ZFI_PAYMEDIUM_DMEE_20`, FM `ZBCM_BNK_SEND_MAIL`, enhancement implementations
`ZBCM1` / `ZBCM4` / `ZBCM_SIGN`, proxy class `ZCO_SIOS_BANK_INTERFACE_ENCRYP`.

## work/

Clean-extracted include sources from the SE80 download in `original/`, line-number
prefixes and page headers stripped. Line counts verified against the SE80 footers.
Use these to diff against a fresh download; they are derived, never edited by hand.
