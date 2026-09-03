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

**Why DEV and not QAS — STILL UNRESOLVED. Four explanations tried, all wrong.**

Retracted in order, each killed by a fact from the real system:

1. *Stale framework global, source unidentified* — rejected by Arnav: a missing macro call is
   system-independent and would fail in both systems.
2. *Missing message class in QAS* — ruled out, SE91 confirms `ZMM_BUDGET` exists in QAS.
3. *Dormant in DEV, only the happy path tested* — disproved, the error message DOES display
   in DEV.
4. *`mmpur_business_obj_id` at line 163 never runs in QAS because `ZRAW` is absent from TVARVC
   `ZPO_DOCTYPE`* — disproved, `ZRAW` is absent in DEV too. So line 163 runs in NEITHER
   system, the object id is unset in both, and DEV displays the message anyway. This also
   disproves the premise underneath all four: a message with no object id can display fine.

**Every one of these was reasoned from `ZME_PROCESS_PO_CUST_CHECK_full.abap`, which is the
DEV source as supplied 19/08/2026. The QAS source has never been seen or diffed.** That is the
golden-rule check flagged in the first reply of this thread and it is still outstanding. Same
code plus same config cannot give different results; `ZPO_DOCTYPE` matches and the message
class matches, so the source itself is the remaining variable.

**Blocking question, never confirmed:** in QAS with the budget exceeded, does the PO SAVE or
is it BLOCKED? "Blocked, no message" is a display problem. "Saves normally" means `ch_failed`
is being cleared after the `<002>` block and the message is a side issue — a different bug
entirely. Everything above assumed "blocked" without checking.

**Next step:** SE19 QAS → `ME_PROCESS_PO_CUST` → implementation → class → SE24 → method
`IF_EX_ME_PROCESS_PO_CUST~CHECK` → copy the source into `incoming/` and diff against the DEV
copy. Compare in particular anything touching `ch_failed` after the `CHECK sy-tcode NE 'ME29N'`
line, and any raw `MESSAGE ... TYPE 'E'` between the `<002>` block and `ENDMETHOD` — a raw
`MESSAGE E` returns to the screen immediately and would discard the collected MM messages.

**Status of the fix below:** it is defensible practice and matches the `ZMM_MSGS 007` block,
but it is NOT the cause of the DEV/QAS difference and must not be described as such. Whether
it is worth pasting at all should be decided after the source diff.

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
