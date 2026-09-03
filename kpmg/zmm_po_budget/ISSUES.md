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

**Why DEV and not QAS — never established. Six explanations tried, all disproved.**

1. *Stale framework global, source unidentified* — rejected: a missing macro call is
   system-independent and would fail in both systems.
2. *Message class missing in QAS* — SE91 confirms `ZMM_BUDGET` exists in QAS.
3. *Dormant in DEV, only the happy path tested* — the error message DOES display in DEV.
4. *`mmpur_business_obj_id` (line 163) skipped in QAS because `ZRAW` is absent from TVARVC
   `ZPO_DOCTYPE`* — `ZRAW` is absent in DEV too, so line 163 runs in neither system and DEV
   displays anyway. This also disproves the premise under 1 and 4: a message with no object
   id can display fine.
5. *Message 001 text missing in QAS* — SE91 confirms 001 exists with text.
6. *Different number of CHECK calls, Enter vs straight-Save* — the block is entered twice in
   DEV and once in QAS, but pressing Enter in QAS does not make the message appear.

Confirmed facts: the statement is reached in QAS; `ch_failed` works (ME21N offers Hold, so
over-budget POs ARE blocked in QAS); the message never reaches `LSBAL_DISPLAY_BASEF05`.

**Resolution taken 03/09/26 — stop diagnosing the collector, stop using it.**

`mmpur_message_forced` fails silently by design: it hands the text to the purchasing message
collector and something downstream decides whether to render it. Known silent-drop paths
include no business object id, `mmpur_remove_msg_by_context` clearing it on a later CHECK
call, a context mismatch, the item object being re-instantiated between check and display,
and a raw `MESSAGE TYPE 'E'` elsewhere in the method returning to the screen and discarding
what is pending. A plain `MESSAGE` has none of them - it displays or it dumps.

Decisive practical point that should have carried more weight from the start: **eight other
validations in this same method already use raw `MESSAGE ... TYPE 'E'` and they work in QAS**
(lines ~452, 464, 469, 538, 595, 722, 909, 967). The `<002>` block was the only one on the
collector route.

All three budget messages switched to plain `MESSAGE e00X(zmm_budget)`. This also gains a
syntax check on the message id, which the literal `'ZMM_BUDGET'` passed to the macro never had.

**Trade-off, accepted:** a type E message returns to the screen immediately, so validations
placed after the `<002>` block do not run on that round trip. This already matches how the
other eight checks in this method behave, and they run normally once the budget is corrected.
`ch_failed` is set BEFORE each MESSAGE for the same reason.

**Root cause of the DEV/QAS difference remains unknown and is now moot.** If it ever needs to
be chased, the one check never done is a diff of the QAS method source against the DEV copy.

**Fix applied 03/09/26** — inside the existing `*BOC <002>` block, extended not re-wrapped,
old `mmpur_message_forced` lines commented out in place directly above their replacements:

- `mmpur_message_forced 'E' 'ZMM_BUDGET' '002' ...` -> `MESSAGE e002(zmm_budget) WITH ...`
- `mmpur_message_forced 'E' 'ZMM_BUDGET' '008' ...` -> `MESSAGE e008(zmm_budget) WITH ...`
- `mmpur_message_forced 'E' 'ZMM_BUDGET' '001' ...` -> `MESSAGE e001(zmm_budget).`
- `ch_failed = abap_true.` moved BEFORE each MESSAGE - a type E message returns to the screen
  immediately and anything after it never runs

An interim version of this fix added `mmpur_business_obj_id` and `invalidate( )` and looped
`lt_items` instead of `lt_details`. That machinery was built on explanation 4, which was
disproved, so it has been removed - the block is back to the simple `lt_details` loop of the
19/08/2026 original with only the three message statements changed.

Files: `ZME_PROCESS_PO_CUST_CHECK_full.abap` (973 -> 994 lines),
`BADI_CHECK_SNIPPET.abap` (111 -> 137 lines, the paste unit).

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
