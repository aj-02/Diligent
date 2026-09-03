# Issues — ZMM_PO_BUDGET

Log format: date | issue | root cause | files changed | commit | TR


---

## 03/09/26 — Budget message never displayed in QAS (ME21N) — FIXED, awaiting retest

**Reported:** budget block works in DEV, wrong result in QAS. Narrowed by Arnav to: the
budget row EXISTS in QAS, the `mmpur_message_forced` statement IS reached in the debugger,
but no error text appears on the ME21N screen; deep-diving `LSBAL_DISPLAY_BASEF05` shows the
message never arrives at the log display at all.

**Root cause — defect in the `<002>` block, not a data problem.**

`mmpur_message_forced` only puts the text into the purchasing message collector. ME21N
renders a collected message against the document object that owns it, and
`mmpur_remove_msg_by_context ls_item_data-id mmcnt_context_badi` (line ~125, runs at the
start of every CHECK call) re-keys BAdI messages by object id. A message with no object id
is not in that set and is discarded before it reaches the Application Log display — which is
exactly what the `LSBAL_DISPLAY_BASEF05` trace showed.

The working `ZMM_MSGS 007` block by Hemang, ~450 lines above in the same method, does five
things; the `<002>` block did two:

| step | ZMM_MSGS 007 (works) | `<002>` before fix |
|---|---|---|
| `mmpur_context mmcnt_context_badi` | line 112 | inherited |
| `mmpur_business_obj_id ls_item_data-id` | line 163 | **missing** |
| `mmpur_metafield mmmfd_matnr` | line 165 | missing (cursor only) |
| `mmpur_message_forced` | line 167 | present |
| `item->invalidate( )` | line 172 | **missing** |
| `ch_failed = abap_true` | line 173 | present |

**Why DEV and not QAS.** `mmpur_business_obj_id` sets a framework global. With none set by
the block itself, the message inherited whatever id earlier processing had left behind. In
DEV that global happened to hold a live item and the message rendered; in QAS the earlier
path (gated at line 153 on `lt_po_doctyp` / `ls_header-bsart`) does not run for the document
type being tested, the global is blank or stale, and the message is orphaned. `ch_failed`
still blocked the save, so the symptom was a refused save with no explanation.

**Fix applied 03/09/26** — inside the existing `*BOC <002>` block, extended not re-wrapped,
old lines commented out in place:

- item loop changed from `lt_details` (data only) to `lt_items` (references), so the item id
  and the item reference are both available; same rows selected either way
- `lv_bud_objid` / `lo_bud_item` capture the first account-assigned item
- `mmpur_business_obj_id lv_bud_objid.` before each of the three `mmpur_message_forced` calls
- `lo_bud_item->invalidate( )` after each, guarded by `IS BOUND`

Files: `ZME_PROCESS_PO_CUST_CHECK_full.abap` (973 → 1027 lines),
`BADI_CHECK_SNIPPET.abap` (111 → 175 lines, the paste unit).

Types used are all proven by working code in the same method — `MEPOITEM-ID` (line 163),
`purchase_order_items` (line 79), `item->invalidate( )` (line 172). No metafield constant was
added: `mmmfd_*` only positions the cursor and no correct constant for an item value field is
confirmed.

**Deliberately NOT changed.** The consumed-budget `SELECT` still has no `k~bstyp = 'F'`
restriction, so contracts (`K`) and scheduling agreements (`L`) count as consumed budget, and
`EKPO-EFFWR` is still summed across document currencies. Both are marked `KNOWN GAP` in the
source. They are a separate issue and will surface as msg 001 firing on a PO that is inside
budget — raise with the functional consultant before changing, since it is a scope question
(does a contract consume PO budget?).

**Retest in QAS:** budget row present + PO over budget → msg 001 must now appear on the item.
Budget row absent → msg 002 with plant / purchasing group / year filled in. Also confirm
`SE91 → ZMM_BUDGET` messages 001, 002, 008 exist in QAS — the message id is passed to the
macro as a character literal, so a missing message class would activate cleanly and still
show nothing at runtime.

**Superseded.** The earlier 03/09/26 entry ranked seven environment causes (empty table,
wrong client, class version, year mismatch, `sy-tcode`, currency). Arnav ruled out the code
version by screenshot and the empty table by SE16, and the real cause was none of them.
Those checks remain valid for any future "no message" report.
