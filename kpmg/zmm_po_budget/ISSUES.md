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

**Why DEV and not QAS — NOT ESTABLISHED. Earlier claim in this entry was wrong.**

An earlier version of this entry claimed the missing `mmpur_business_obj_id` explained the
DEV/QAS split, via a stale framework global. Arnav correctly rejected that: a missing macro
call is a system-independent code defect and would fail in both systems. The stale-global
story was a hypothesis, never verified against the macro internals. Retracted.

The fix below is still correct on its own merits — it matches the proven `ZMM_MSGS 007` block
in the same method and removes a dependency on framework state the block does not control —
but it is not the explanation for the two systems behaving differently.

What can actually differ between two systems running identical source, in check order:

1. **`ZMM_BUDGET` messages missing in QAS.** The only candidate that explains both halves.
   The message id reaches the macro as a character literal `'ZMM_BUDGET'`, so unlike
   `MESSAGE e002(zmm_budget)` there is NO syntax check — the class can be absent and the code
   still activates clean. At runtime the collector cannot resolve the T100 text, the entry is
   dropped, and it never reaches `LSBAL_DISPLAY_BASEF05`, which is exactly what the debug
   showed. The table transported; the message class may have been on a different TR.
   **Check: SE91 in QAS, ZMM_BUDGET, messages 001 / 002 / 008.**
2. **The QAS method source is not the DEV source.** `ZME_PROCESS_PO_CUST` is one shared impl
   class carrying blocks from Hemang, Saurabh, UDAYABAP03, Raj and Arnav. It is a single
   object, so the last TR imported into QAS overwrites the whole class, not just its own
   block. The screenshot proves the `<002>` block is present; it proves nothing about the
   other ~900 lines. **Check: download the QAS version and diff against the DEV copy.**
3. **Client-dependent config drives different code paths.** Line ~153,
   `IF line_exists( lt_po_doctyp[ low = ls_header-bsart ] )`, is fed from TVARVC
   (`ty_tvarv` / `it_type`, added by Raj). TVARVC is maintained per client in STVARV and does
   not travel with the workbench request. This matters directly: raw `MESSAGE e021(zmm)`,
   `e052(zmm)`, `e024(zmm)` statements sit AFTER the `<002>` block, and a raw `MESSAGE TYPE E`
   returns to the screen immediately, so collected MM messages behind it are never flushed to
   the log. A QAS-only config path tripping one of those would kill the budget message.
   **Check: STVARV in both systems vs the test PO's BSART.**
4. **The DEV test may not have been the same test.** `ch_failed = 'X'` blocks the save on its
   own and ME21N shows a generic refusal with none of Arnav's text. If DEV only ever showed
   the refusal and never the words "No budget maintained for plant..." or "Budget has been
   exhausted...", then it never worked in either system, there is no difference to explain,
   and the missing `mmpur_business_obj_id` is the whole story. **Confirm this before chasing
   1 to 3.**

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
