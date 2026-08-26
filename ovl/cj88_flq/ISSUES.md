# Issues — CJ88 / FLQ (OVL)

Log format: date | issue | root cause | files changed | commit | TR

---

## 26/08/26 — CJ88 settlement reversal terminates in update task

**Issue.** Gitesh S Lad (user `78087`) reports "Update was canceled" express documents when
reversing WBS settlement via CJ88 for project `OV.13AA2002`, period 001/2026, value date
30.04.2026. Reproduced by `SAP_ABAP` on 26/08/26 15:31–15:42 in client 500 — 41 SM13 update
records, all CJ88, all `Error (no retry)`.

**Root cause.** Standard SAP. `FLQ_INSERT_EXTSN` (classic Liquidity Calculation) is
registered in the CJ88 update LUW as module 9 of 11. The liquidity item it is handed carries
`BELNR = '%       1'` — the accounting-interface placeholder object key — instead of the
assigned FI document number (`5326000389/2026/002`, present in BKPF/BSEG in the same dump).
With `GSBER`, `LQORIG` and `GUID` all blank and `LQPOS` = the catch-all `ZOC_UNASSIGNED`, the
FLQITEMFI primary key is effectively constant across every document in the run. The first
document commits its row; each one behind it hits a duplicate key, `INSERT flqitemfi` returns
`sy-subrc = 4`, and `LFLQEXTF01 / FORM update_item` line 81 raises `INS_ERROR_IT` — which
terminates the update and rolls the whole LUW back.

Three orphan rows confirmed in SE16 (FLQITEMFI, ZBUKR = OVL, GJAHR = 2026, BELNR `%       1`),
written 21.08 and 25.08.2026 by `78087`.

**Consequence.** The CJ88 log reports "Settlement Reversed 24" but nothing posts — that log
is written before the update runs. Reversals must be re-verified in CJI3 /
S_ALR_87013543 before any re-run.

**Fix.** None in code — every object in the chain is standard SAP and must not be modified.
Recommended remedy is to deactivate classic Liquidity Calculation for company code OVL
(One Exposure / `FCLM_*` is already active on the same postings, and classic LC is a
simplification-list item on S/4). Full analysis in NOTES.md.

**Files changed.** None — diagnosis only. `original/FLQEXT.TXT` and
`evidence/ST22_RAISE_EXCEPTION_20260826_154256.txt` filed as evidence.

**TR.** n/a — no code. A customizing transport will be needed for the deactivation once FI
approves.

**Status.** Open, waiting on FI.

### Open questions for FI / Cash Management

1. Is classic Liquidity Calculation in functional scope for OVL at all, given One Exposure is
   live? (Drives the whole remedy.)
2. If it is in scope: who configured the queries producing `ZOC_UNASSIGNED` and
   `Z_IC_UNASSIGNED`, and is a catch-all assignment intended?
3. If LC is deactivated and later re-activated, is the resulting gap in FLQITEMFI/FLQITEMBS
   acceptable, or must it be reconstructed? (Deactivation is not retroactive.)

### Open technical checks

- [ ] SE18/SE19 + CMOD — any customer implementation on FLQ BAdIs/exits? (Would mean the
      defect is ours and fixable.)
- [ ] IMG → FSCM → Cash and Liquidity Management → Liquidity Calculation — is LC flagged
      active for OVL, and what is the exact activation node/table on this release?
- [ ] `RS_ABAP_SOURCE_SCAN` on `FLQ_INSERT`, programs `SAPLFLQ*` — find the dynamic caller
      that builds the item with the placeholder BELNR. (Where-used is empty; the call is
      dynamic.)
- [ ] Confirm classic Liquidity Calculation's status in the Simplification List for this
      exact S/4 release.
- [ ] After the fix is proven: delete the three orphan `%       1` rows from FLQITEMFI.
