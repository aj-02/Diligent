# ovl/zbnk_app2 — ZFI_BNK_APP (bank payment file monitor)

## What it is

Report `ZFI_BNK_APP`, `START-OF-SELECTION` → `CALL SCREEN 100`. Screen 100 holds a
custom container `CONTROL` with a `CL_GUI_ALV_GRID`. Include tree (complete, 5 includes):

| Include                   | Lines | Contents                                        |
|---------------------------|-------|-------------------------------------------------|
| `ZFI_BNK_APP_TOP`         |  70   | `ty_final`, globals, ALV refs                   |
| `ZFI_BNK_APP_S01`         |   8   | `SO_LAUFD` / `SO_LAUFI` / `SO_SENT`             |
| `ZFI_BNK_APP_F`           | 779   | `F_PREPARE_OP_TAB`, fieldcat, 3 downloads, `F_RESENT` |
| `ZFI_BNK_APP_OUTPUTO01`   |  60   | PBO `OUTPUT`, PBO `STATUS_0100`                 |
| `ZFI_BNK_APP_I01`         |  38   | PAI `USER_COMMAND_0100`, PAI `GET_SELECTED_ROW` |

Screen 100 (SE51) and the GUI status (SE41) are **not** in the SE80 download and are
not yet in this repo. Both are needed to close issue 1.

## It is PASTE-ONLY

Module-pool-style screen + SE41 status. abapGit does not serialise these. No `src/`,
no `.abapgit.xml`.

## ECC → S/4 port already applied

Someone has already replaced `BNK_BATCH_HEADER` (BCM, obsolete on S/4) with `REGUT`
throughout `F_PREPARE_OP_TAB`. `REGUT-GUID` is not populated, so the batch identity is
rebuilt by hand as a concatenation:

    ZBUKR + BANKS + LAUFD + LAUFI + XVORL + DTKEY + LFDNR   ("41 chars" per the comment)

held in `ty_final-GUID` (`c LENGTH 45`). Columns dropped in the port because REGUT has
no equivalent: `RULE_ID`, `ITEM_CNT`, `LAUFD_F`, `LAUFI_F`, `TOT_BTCH_AMT`.

**The port is the prime suspect for issue 2** — see ISSUES.md.

## Function codes handled

`E` (exit), `DOWNLOAD1` (sent file), `DOWNLOAD2` (raw), `DOWNLOAD3` (received),
`RESENT`. **There is no release / approval / signature function code in this program.**
It only *reads* `ZFI_BATCH_SIGN` to derive the `PENDING_WITH` column.

## Gotchas

- PBO `OUTPUT` calls `F_PREPARE_OP_TAB` and `SET_TABLE_FOR_FIRST_DISPLAY` on **every**
  round trip, not just the first. Every dialog step re-hits the DB and rebuilds the grid.
- `MODULE STATUS_0100` has `SET PF-STATUS` commented out, so the status must be set from
  the screen flow logic or elsewhere — confirm in SE51.
- `SY-UCOMM` is read but never cleared, so a stale code can re-fire.
- Three near-identical download FORMs (`DOWNLOAD_SENT_DATA` / `_RAW_DATA` / `_REC_DATA`)
  differ only in source field, filename and guard flag.

## Related objects to pull when needed

- `ZFI_PAYM_FILE` — file store (raw / sent / received xstring, filenames, flags)
- `ZFI_BATCH_SIGN` — signature table: `BATCH_NO`, `SIGNER`, `DIGITL_SIGN`
- `REGUT` — payment-medium run table (replaced BNK_BATCH_HEADER)
- proxy class `ZCO_SIOS_BANK_INTERFACE_ENCRYP` — SBI web service used by `F_RESENT`
