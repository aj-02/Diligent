# ZMM_PO_BUDGET — NOTES

## What it is

WRICEF 050_BRD_FS, Astral / UDAY — budget control on indirect purchase. A PO is blocked when
the account-assigned value exceeds Budget + Additional Budget held in `ZMM_PO_BUDGET` for
plant / purchasing group / year.

Four moving parts, and **only one of them travels by ZIP**:

1. **DDIC + messages** — domain `ZDO_BUDGET_AMT`, data elements `ZDE_BUDGET` /
   `ZDE_ADD_BUDGET`, table `ZMM_PO_BUDGET`, message class `ZMM_BUDGET`
   (in `src/`, built as `ZMM_PO_BUDGET.zip`).
2. **The check itself** — pasted into the **existing** `ME_PROCESS_PO_CUST` implementation's
   `CHECK` method (`ZME_PROCESS_PO_CUST_CHECK_full.abap`, 973 lines; insert block alone in
   `BADI_CHECK_SNIPPET.abap`, 111 lines).
3. **SE54 table-maintenance event 01** routine — `ZMM_BUDGET_BEFORE_SAVE.abap` (78 lines).
4. **A PBO screen module** inside the generated maintenance function group.

## Gotchas

- `ME_PROCESS_PO_CUST` is a **classic** BAdI and an implementation already exists in this
  system, carrying other people's changes (`<001>` Saurabh Saumya 20.01.2026, plus blocks by
  other authors, e.g. "Start change by archna gupta"). The delivered code is an **insert into
  that method**, not a new implementation. Arnav's block is `<002>`.
- Insert point matters: **immediately BEFORE** `CHECK sy-tcode NE 'ME29N'`. `CHECK` exits the
  method when false, so anything after it is skipped for ME29N and for `gv_pstyp = 'U'`.
  The code relies on variables the method already builds (`ls_header`, `lt_details`) and on
  `INCLUDE mm_messages_mac` already being at the top.
- `CHECK` is the right method, **not** `POST` — `CHECK` is where `ch_failed = 'X'` actually
  stops the save. Use `mmpur_message_forced` so the message attaches to the document properly.
- The TMG rule needs **both** halves. Event 01 is the enforcement: it runs on the database
  write, cannot be bypassed, and survives TMG regeneration. The screen module only greys the
  field out and **is lost on every regeneration** — greying alone would silently reopen the
  budget field after a regeneration.
- `sy-subrc <> 0` is what cancels the save and must be set **before** the `MESSAGE` statement:
  a type E message returns to the screen immediately and anything after it never runs.
- The field symbols `<action>` and `<vim_total_struc>` come from the maintenance framework;
  confirm the generated names before activating.
- `WAERS` is on the table but **not in the FS** — added because the FS compares an amount with
  no currency.
- Only `KNTTP = 'K'` items are counted and deleted items are ignored; multiple plants in one
  document are already rejected earlier in the method, so one plant bucket suffices.
- Seven open points are recorded in `MANUAL_STEPS.md` §4. Two are scope decisions (scheduling
  agreements ME31L / ME32L do not run through this BAdI at all and need `MM06E005` or a scope
  cut; direct vs indirect); three are one-liners marked `OPEN POINT` in
  `ZCL_MM_PO_BUDGET_CHECK` (no budget row → block or allow, calendar vs fiscal year, currency
  conversion). The ME22N double-count case must be tested explicitly.

## Known documentation contradictions — resolve before relying on either

- **`MANUAL_STEPS.md` §1 misdescribes the ZIP.** It lists `zcl_mm_po_budget_check.clas.*` as
  being inside `ZMM_PO_BUDGET.zip`, and §5 says "activate the six objects". The ZIP actually
  contains **7 files and no class at all**: `.abapgit.xml`, `package.devc.xml`,
  `zde_add_budget.dtel.xml`, `zde_budget.dtel.xml`, `zdo_budget_amt.doma.xml`,
  `zmm_budget.msag.xml`, `zmm_po_budget.tabl.xml`. `src/` matches the ZIP. The class files
  live only in `zmm_po_budget_deferred/`.
- **Two mutually exclusive designs are both present.** `MANUAL_STEPS.md` §3 describes a fresh
  SE19 classic-BAdI implementation whose `CHECK` method calls
  `ZCL_MM_PO_BUDGET_CHECK=>check_document( )`. `ZME_PROCESS_PO_CUST_CHECK_full.abap` and
  `BADI_CHECK_SNIPPET.abap` deliver the opposite — inline code pasted into the already
  existing implementation, with no class involved. Both cannot be live. **Confirm which one
  was actually delivered before activating either.**
- `abapgit_pilot/` claims the same object names with different definitions (9-field table, no
  message class). Importing both into one system will collide.

## Shipping: HYBRID

- **abapGit ZIP:** DDIC + message class via `ZMM_PO_BUDGET.zip` (abapGit standalone, offline
  repo). Before importing, confirm none of the object names already exist in the target.
- **Paste / SE-transaction work for everything else:** the BAdI method body (SE19 / SE80),
  the event 01 routine (SE54 → Environment → Events), the PBO screen module (SE80, generated
  FG), the TMG itself (SE11 → Utilities), and the SE93 parameter transaction on SM30.

Sequence is in `MANUAL_STEPS.md` §5 — read it together with the contradictions above.

## Stays manual regardless

SE11 TMG generation · SE54 event 01 · the PBO screen module (and re-applying it after every
TMG regeneration) · SE19 classic BAdI work · SE93 parameter transaction.
