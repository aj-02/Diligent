# CJ88 settlement reversal — FLQ update termination (OVL)

## What this is

Not a Z object. This folder holds the diagnosis of a **standard SAP** update-task
termination that blocks CJ88 (actual settlement, reversal) for OVL projects.

- Reported by Gitesh S Lad (Finance & Accounts Officer, Corporate Accounts), user `78087`,
  for project `OV.13AA2002`, period 001/2026, value date 30.04.2026.
- Reproduced by `SAP_ABAP` on 26/08/26 15:31–15:42, client 500 (role **Test** — the client
  is *named* "Production Clients", which is misleading; SCC4 says Test).
- 41 update records in SM13, all `CJ88`, all **Error (no retry)**.

## Symptom

Express document "Update was canceled" after CJ88 reversal. SM13 record status
`Error (no retry)`, all 11 modules showing `Initial` (module status lives in VBMOD and is
reverted by the rollback — that is normal for a terminated V1 update, it does **not** mean
nothing ran).

ST22 dump:

```
RAISE_EXCEPTION · SAPLFLQEXT · LFLQEXTF01 line 81 · FORM UPDATE_ITEM
Exception INS_ERROR_IT · Application component FIN-FSCM-FQM
Main program RSM13000 (update task)
```

**The whole update LUW rolls back.** The CJ88 basic list reports "Settlement Reversed 24"
because that log is written before the update runs — the reversals did **not** post. Always
re-check CJI3 / S_ALR_87013543 before letting anyone re-run.

## The update LUW (SM13 → Modules)

```
 1 VOUCHER_POST_RA              7 FCLM_FI_STAGING_ADD
 2 POST_DOCUMENT                8 FCLM_STAGING_RAISEEVENT
 3 K_DOCUMENT_UPDATE            9 FLQ_INSERT_EXTSN      <-- dies
 4 K_COBK_REVERSE              10 K_SETTLEMENT_DOCUMENT_INSERT
 5 FINS_ACDOC_POSTING_INSERT   11 K_SETTLEMENT_RULES_UPDATE
 6 FINS_ACDOC_POSTING_CHANGE
```

`FINS_ACDOC_*` confirms S/4 (ACDOCA). `FCLM_*` confirms **One Exposure / new Cash
Management is active**. `FLQ_INSERT_EXTSN` confirms **classic Liquidity Calculation is
also still active** — both liquidity engines running on the same posting.

## Root cause

`FLQ_INSERT_EXTSN` (`LFLQEXTU12`) appends every passed item to the function-group global
`G_T_ITEM_INS` and registers `PERFORM update_item ON COMMIT`. At COMMIT,
`FORM update_item` (`LFLQEXTF01`, lines 62–83) does a bare `INSERT flqitemfi`; on
`sy-subrc <> 0` it raises `INS_ERROR_IT`.

FLQITEMFI key (SAP's own declaration, `LFLQEXTTOP` line 56):

```
zbukr  belnr  gjahr  buzei  bukrs  gsber  lqpos  lqorig  guid
```

The item being inserted, from the dump's Selected Variables:

| Field | Value |
|---|---|
| MANDT / ZBUKR | 500 / OVL |
| **BELNR** | **`%       1`** |
| GJAHR / BUZEI | 2026 / 002 |
| BUKRS / GSBER | OVL / *(blank)* |
| LQPOS | ZOC_UNASSIGNED |
| LQORIG / GUID | *(blank)* / *(blank)* |
| LQDAY / TWAER | 20260430 / INR |
| WRBTR / DMBTR | 11,736,489.63- |

The **real** FI document, from the same dump (Directory of Application Tables → SAPLF005):

```
BKPF: 500 OVL 5326000389 2026 PS 20260821 20260430 01 20260826154255
BSEG: 500 OVL 5326000389 2026 002
```

**FLQ writes `BELNR = '%       1'` — the accounting-interface placeholder object key —
instead of the assigned document number 5326000389.** The placeholder is never substituted
back into the liquidity item.

With BELNR a constant and GSBER / LQORIG / GUID all blank, the FLQITEMFI key varies only by
`BUZEI` + `LQPOS`. Every settlement document in a run therefore produces the *same* key.
The first document commits its row; every document behind it collides.

`SY-TABIX = 1` and `SY-DBCNT = 0` in the dump prove the collision is against a row already
on the database, not a duplicate inside `g_t_item_ins`.

Confirmed in SE16 — FLQITEMFI, ZBUKR = OVL, GJAHR = 2026, three orphan rows:

```
OVL  %       1  2026  2  OVL   ZOC_UNASSIGNED    30.04.2026 INR  20,062,536.75-  25.08.2026 16:49:44  78087
OVL  %       1  2026  2  OVL   Z_IC_UNASSIGNED   30.04.2026 INR   7,847,163.75   21.08.2026 18:38:17  78087
OVL  %       1  2026  3  OVL   ZOC_UNASSIGNED    30.04.2026 INR  48,460,601.19-  25.08.2026 20:05:23  78087
```

Row 1 is the exact collision partner of the dumped INSERT. `BUZEI 2` appears twice with
different LQPOS because LQPOS is in the key — which is why a couple of documents got through
before the run stalled.

## Why there is no code fix

Every object in the chain is standard SAP: `SAPLFLQEXT` (06.06.2015), `SAPLKO78`
(27.11.2018), `SAPLF005`. `FLQ_INSERT_EXTSN` only writes what it is handed — the defect is
upstream, in whatever builds the item during the settlement accounting-interface flush
(`SY-XPROG = SAPLKO78`, `SY-XFORM = XAB_WFLUSH`).

Where-used on `FLQ_INSERT_EXTSN` is **empty** — the FM is called dynamically
(`CALL FUNCTION <var> IN UPDATE TASK`), so the dispatcher has to be found by source scan
(`RS_ABAP_SOURCE_SCAN` / `CODE_SCANNER` on `FLQ_INSERT`, programs `SAPLFLQ*`), not by
where-used.

No Z modification of standard. An **implicit enhancement** in `FORM UPDATE_ITEM` to filter
placeholder-BELNR items or turn the INSERT into a MODIFY is technically possible and is
**deliberately rejected** — it would silently suppress or overwrite Finance data inside an
update task, and it fixes the symptom while leaving the document number wrong. Only revisit
with written FI sign-off.

## Recommended remedy

**Deactivate classic Liquidity Calculation for company code OVL.**
IMG → Financial Supply Chain Management → Cash and Liquidity Management → Liquidity
Calculation → activation per company code.

Rationale, not just workaround: One Exposure (`FCLM_*`) is already active on the same
postings; classic LC is a simplification-list item on S/4; and the data it is writing here
is junk (a document number that does not exist, liquidity items literally named
`ZOC_UNASSIGNED` / `Z_IC_UNASSIGNED`).

`ASSUMPTION:` classic Liquidity Calculation is not in functional scope for OVL. Not yet
confirmed by FI — that is the open question in ISSUES.md.

Reversible: it is a customizing flag, so it can be switched back on. But deactivation is
**not retroactive** — postings made while it is off leave a gap in FLQITEMFI/FLQITEMBS and
`FLQSUM` drifts out of step. A reconstruction report exists in the LC menu; its name and
scope on this release are **unverified**. Confirm before anyone plans on "turn it back on
later".

The exact activation node/table was not confirmed from this machine. Locate it with
`SE16 → TSTC, TCODE = FLQ*` or `SE11 → FLQC* / FLQ_C*` before changing anything — do not
guess the transaction.

## Test to prove the fix

1. Deactivate LC for OVL in client 500.
2. Re-run CJ88 for `OV.13AA2002`, period 001/2026, reversal, update run.
3. SM13 → update record → Modules: `FLQ_INSERT_EXTSN` should be **gone** from the 11.
4. No new ST22 dumps.

Do this **before** deleting the three orphan rows — otherwise you are testing the cleanup,
not the fix. The rows are junk and should be removed afterwards, but deleting them alone
buys only one or two more documents per BUZEI/LQPOS combination.

## Gotchas

- Do **not** press "Repeat Update" in SM13. `Error (no retry)` records are not repeatable,
  and forcing a retry on a duplicate-key insert either fails again or half-applies.
- A session breakpoint will not fire — `FLQ_INSERT_EXTSN` runs in the update work process.
  Needs `/h` → Settings → **Update Debugging**. In this case ST22 answered everything and no
  debugging was required.
- `cj88.TXT` (function group KO71, 12,507 lines) was downloaded first and is **not**
  relevant — it contains none of the 11 update modules and no FLQ reference. Not filed.
- Client 500 is role **Test** despite being named "Production Clients". Worth raising with
  Basis separately.

## Files here

- `original/FLQEXT.TXT` — SE80 download of function group FLQEXT (SAPLFLQEXT), 3,636 lines,
  19 includes. The crash site (`LFLQEXTF01/UPDATE_ITEM`) and the buffer that feeds it
  (`LFLQEXTU12/FLQ_INSERT_EXTSN`) are both in here.
- `evidence/ST22_RAISE_EXCEPTION_20260826_154256.txt` — full dump text.
