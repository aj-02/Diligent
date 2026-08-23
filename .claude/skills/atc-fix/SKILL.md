---
name: atc-fix
description: Remediate ATC (ABAP Test Cockpit) findings on the OVL S/4 readiness project. Use when Arnav supplies an ATC finding, ATC error list, worklist export, or asks to remediate a priority 1/2/3 finding, close an S/4 readiness check, add a pseudo-comment, or fix a Field Length Extension / NOORDER / Simplified Object / Database Operation finding. Triggers on "ATC finding", "ATC error", "P1/P2/P3 finding", "remediate", "S/4 readiness", "pseudo comment", "#EC".
---

# Remediate an ATC finding

Shared marker, correction and transfer rules live in
`CLAUDE.md` at the repo root.
Read it. This skill does not repeat it — it adds what is specific to ATC work, and the
project identity below overrides the default author tag.

## Project identity — read before the first edit

```
Project: OVL. Change-marker author tag = SAP_ABAP.
NEVER write ABAP7 (cipla) or EJX9007359 (coke/CCEJ) into an OVL file.

Default new-marker format (matches the 205 existing pairs in
C:\Users\ArnavJohri\Downloads\atc corrections\):
  *--- BEGIN OF CHANGE BY SAP_ABAP <date> FOR ATC ---
  *--- END OF CHANGE BY SAP_ABAP <date> FOR ATC ---
  (<date> format is an OPEN question — see "Marker dates" below. Do not guess it.)

BUT rule: match the existing in-file marker format. If the file already
carries ZATC-style markers, extend that style instead:
  " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP <date>  for ATC
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and <date>

Pragma tokens: FLE -> CI_FLDEXT_OK[note] | NOORDER -> CI_NOORDER (bare, no note)
Usages/Transactions -> CI_USAGE_OK[note] | DB-ops -> CI_DB_OPERATION_OK[note]
Native SQL -> CI_EXECSQL
```

**Marker dates.** The date in a change marker is the date **you** make the change. Do not
copy the example dates out of the sample files.

**The marker date FORMAT is unresolved, and this skill does not decide it.** CLAUDE.md
mandates `DD/MM/YY` with slashes for change markers, and notes that object *header* blocks
use `DD.MM.YYYY` with dots — two different things, don't conflate them. The existing ATC
sample files in `C:\Users\ArnavJohri\Downloads\atc corrections\` carry the dotted
`DD.MM.YYYY` form in their *markers*, which conflicts with that mandate. So: **write
`DD/MM/YY` per CLAUDE.md unless Arnav has confirmed that the ATC project uses the dotted
`DD.MM.YYYY` form for markers.** Ask him before writing the first marker of a batch, carry
it in the *needs Arnav's confirmation* list (Phase 5, step 17), and record the answer. The
sample files are evidence of precedent, not a decision — do not silently adopt their format
just because it is what is already sitting in that directory.

## Rules that produce a wrong deliverable if broken

1. Real fix over suppression. **No P1 `#EC` pseudo without explicit approval from Arnav.** Before any pseudo at ANY priority, research the SAP note / successor API / CDS for a real fix. Pseudo is the last resort.
2. **Comment out old code with `*`, never delete; add the new code below.** Active executable lines stay byte-for-byte verbatim in the same order.
3. **Never double-wrap.** If a line (or the line above) already carries a BEGIN OF CHANGE marker or an inline `#EC` pragma, edit **in place** — do not open a new BEGIN/END block and do not re-comment already-commented code.
4. **A `#EC` pseudo-comment MUST start with a leading `"` — it is a comment.** Appending a bare `#EC CI_...` to a line that has no existing comment is a SYNTAX ERROR. When the line already has a `"` comment, put the `#EC` INSIDE that comment (no second `"`).
5. **One pseudo per line, maximum.** If a second finding lands on a line that already carries a pseudo, real-fix it or replace the wrong note — never stack two `#EC` tokens.
6. **Markers are for real (structural) fixes only.** A pure P2/P3 pseudo gets an inline `#EC` and NO begin/end-of-change markers.
7. **Do not comment out a DML/write** unless there is a real solution or an explicit decision (else: leave the statement and flag it functional, or replace with an error MESSAGE naming the SAP Note).
8. **Never mass-regex SELECT bodies.** Do CDS/CONV/API fixes program-by-program, per statement, with a rendered-statement review. Auto-rewriters produce `@@`, `,,`, double periods, half-done WHERE, and silently-skipped edits that block-balance scans do NOT catch.
9. **Never rewrite `SELECT *` or a JOIN to CDS.** `SELECT *` structure ≠ CDS structure. Keep on the retained table + `#EC CI_DB_OPERATION_OK`.
10. **The ATC worklist LINE does not map 1:1 to the exported file line.** Always locate the statement by CONTENT (match the expected keyword at/near the line, search ±several lines) before editing. Blind line-number edits land on the wrong statement.
11. **Cross-check the worklist by object name before rewriting.** Matching a code pattern is NOT evidence the code is flagged. (Proven: of 11 BDC calls in one folder, only 3 were actually flagged.)
12. **Fix it properly even when the finding is P3** if the code can dump at runtime. A low ATC priority is not a reason to ship code that terminates.

The double-wrap defect in rule 3 is live, not hypothetical: 7 lines in
`C:\Users\ArnavJohri\Downloads\atc corrections\` read `" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE...`
— a marker comment that got re-commented.

## Rules that fail activation or dump at runtime if broken

Every one of these came from a real activation failure or a real short dump.

13. **`ORDER BY PRIMARY KEY` is valid only with `SELECT *`** (or when the full key is in the field list, in key order). On a projection use `ORDER BY <selected key fields>`, or drop the ORDER BY. Otherwise: "The field <X> from the ORDER BY clause is missing in the SELECT list".
14. **Non-strict `ORDER BY PRIMARY KEY UP TO 1 ROWS` is INVALID** — `UP TO n ROWS` must sit right after the field list in non-strict form.
15. **Putting `UP TO 1 ROWS` before `INTO` makes the statement STRICT.** Never emit the half-strict hybrid. Use the proven strict form: `SELECT f1, f2 FROM src [FOR ALL ENTRIES IN @itab] WHERE col = @hostvar AND … ORDER BY f1, f2 INTO @tgt UP TO 1 ROWS.` + `ENDSELECT.`
16. **When converting `SELECT SINGLE` to loop form, the `SINGLE` keyword MUST be removed** (strip `^SELECT\s+SINGLE\s+`, not `^SELECT\s+`). Leaving it gives "ORDER is not allowed here. '.' is expected."
17. **Strict Open SQL requires:** comma-separated field list AND comma-separated ORDER BY list; `@`-escape every host variable; **escape the RHS operand ONLY — the column name on the LHS of a WHERE stays BARE** (`WHERE vbeln = @itab-vbeln`, never `WHERE @vbeln =`); and this exact clause order: `SELECT <cols> FROM <src> [FOR ALL ENTRIES IN @itab] [WHERE …] [GROUP BY …] [HAVING …] [ORDER BY …] INTO|APPENDING <tgt> [UP TO n ROWS] [OFFSET n].` **`INTO`/`APPENDING` comes AFTER `ORDER BY` — but it is NOT the last clause: `UP TO n ROWS` and `OFFSET n` follow `INTO`** (and `%_HINTS`, rule 22, follows those and carries the terminating period). So `… ORDER BY f1, f2 INTO @tgt UP TO 1 ROWS.` is the correct form (rule 15) and `… ORDER BY f1, f2 UP TO 1 ROWS INTO @tgt.` is INVALID. Never double-`@` something already `@DATA(...)`.
18. **Compat CDS-view reads (`V_VBUP_S4`, `V_VBUK_S4`, `V_KONV`, any `V_*_S4` or CDS) REQUIRE strict Open SQL — a plain FROM-swap is not enough.**
19. **When swapping to a CDS/compat view, drop `CLIENT SPECIFIED` AND the `mandt = sy-mandt` WHERE condition** (you cannot reference mandt without CLIENT SPECIFIED). View vs table decides it:
    - **Illegal on compatibility VIEWS** (dumps DBSQL_ILLEGAL_CLIENT_SPECIFIED): MBEW, MSEG, MKPF, FAGLFLEXA, BSID/BSAD, KONV/PRCD_ELEMENTS → remove both.
    - **Legal on real transparent tables** (they have a MANDT key): INOB, KSSK, KLAH, BKPF, and all custom `Z*` → leave as-is.
20. **A retype changes ONLY the data element after `TYPE`/`LIKE` — never the component/variable name.** `vbtyp_n TYPE vbtyp_n,` → `vbtyp_n TYPE vbtypl,` (NOT `vbtypl TYPE vbtypl,`).
21. **Decouple `TYPE tab-field` → `TYPE <bare>` only if (a) the note actually removed that field AND (b) a data element of that exact bare name exists.** A same-named data element is NOT guaranteed to exist just because the field does. Proven failure: `nacha TYPE nacha` → activation dump "Type NACHA is unknown"; and a bad decouple `TYPE mbew-bwtty` → `TYPE bwtty` resolved to STRING and dumped UC_OBJECTS_NOT_CONVERTIBLE. If the field still exists on the table, leave the ref as `tab-field`.
22. **Removing a `%_HINTS <db> '...'.` line strips the SELECT's terminating period** (the hint is usually the last clause and carries the `.`). Emit a lone `.` at the same indent in its place. Remove only non-HANA hints (MSSQLNT/ORACLE/DB6); keep `%_HINTS HDB`.
23. **Never emit a whole-table `MOVE-CORRESPONDING` from a dynamic / `ANY TABLE` source into a fixed DDIC-based table.** It activates fine and dumps OBJECTS_TABLES_NOT_COMPATIBLE at runtime when the source has a deep component. Correct form:
    ```abap
    DATA l_row LIKE LINE OF ta_target.
    LOOP AT <fs_data> ASSIGNING FIELD-SYMBOL(<fs_row>).
      CLEAR l_row.
      MOVE-CORRESPONDING <fs_row> TO l_row.
      APPEND l_row TO ta_target.
    ENDLOOP.
    ```
24. **`IS NOT INITIAL` guard before EVERY `FOR ALL ENTRIES`.** An empty driver makes the kernel DROP the WHERE and scan the whole table (perf collapse / TSV_TNEW_PAGE_ALLOC_FAILED). Highest-risk drivers: `DATA(x) = src.` + `DELETE x WHERE …`, `DELETE x WHERE key NOT IN r_range`, `VALUE #( FOR … IN src )`. Inline `@DATA(target)` inside the guard is fine.
25. **`ORDER BY` is not allowed with `FOR ALL ENTRIES`** → close a NOORDER finding on an FAE SELECT with `"#EC CI_NOORDER`, not an ORDER BY.
26. **"WRITE in SELECT/ENDSELECT" and "EXIT/RETURN/LEAVE in SELECT/ENDSELECT" NOORDER findings report the line of the WRITE/EXIT INSIDE the loop body, not the SELECT.** Never append ORDER BY at the finding line — scan upward to the enclosing SELECT, or close with `"#EC CI_NOORDER` on the reported line.
27. **Statement-end detection must `rstrip()` before `endswith('.')`, must skip `*`/`"` comment lines, and must stop at a marker or `#EC` comment line.** Missing rstrip swallowed a following `IF sy-subrc = 0.` and cascaded into "No open IF" / "ENDFORM has no open FORM". Overrunning into commented-out old code corrupts the block.
28. **Any helper that masks string literals to find the comment `"` or the statement period MUST be length-preserving** (replace `'literal'` with a same-length placeholder, never collapse to `''`). Collapsing offsets the `"`-index on any line with a literal before its comment → the `#EC` lands mid-code and ORDER BY gets appended to the following `IF`.
29. **A full-line comment needs `*` in COLUMN 1, or an inline `"`.** An indented `* text` is parsed as code.
30. **Multibyte (e.g. Japanese) comments: read the exact bytes with Read before constructing an Edit match.**
31. **Verify after every batch, on active lines only (ignore `*` comments):** `IF==ENDIF`, `LOOP==ENDLOOP`, `FORM==ENDFORM`, `CASE==ENDCASE`, `TRY==ENDTRY`, `SELECT(non-single) >= ENDSELECT`, markers BEGIN==END; plus scans for `@@`, `,,`, `INTO` before `ORDER BY`, double `#EC`, a reconstructed `ORDER BY PRIMARY KEY` statement whose first token is not SELECT/OPEN CURSOR, and `SORT … BY` tokens containing `=`/`"`/`-`. Compare block counts against the pre-edit backup — an off-by-one means a control statement was eaten.

## The workflow

### Phase 0 — Session setup, once per batch

1. Confirm the finding source with Arnav: which export
   (`C:\Users\ArnavJohri\Downloads\atc_ovl_090626.xlsx`, `atc_ovl_050826.xlsx`,
   `export_atc_errors.xlsx`) and which object list
   (`C:\Users\ArnavJohri\Downloads\ATC Tool Object List\` has BDC / Dialog Program /
   Enhancement / Reports / Smartforms subfolders).
2. Ask the two gated scope questions before touching anything: **(a)** are HR/EHS/HSE
   objects in scope for this batch; **(b)** is the current BDC rule "convert to API where
   a real solution exists" or "leave BDCs alone". The KB records both answers for
   different clients — see *Client-specific dispositions* below.
3. Back up every file you will touch. Verify the backup line counts.

### Phase 1 — Read the finding, not the line

4. Pull from the worklist row: Check Title, Check Message, Priority (E→P1, W→P2, N→P3),
   **SAP Note Number**, Object, **Referenced Object**, Line.
5. The Note Number is the fastest disambiguator. Many "Usages of Simplified Objects"
   findings are really field-length (2438131 / 2669857 / 2610650) needing a pragma or a
   CONV, not a successor. Read the note (`https://me.sap.com/notes/<n>`) before assuming
   deprecation.
6. Open the source and **locate the statement by content**, ±several lines around the
   reported line (rule 10). On a partially remediated file the line numbers have drifted;
   search by content signature.
7. Confirm the object is genuinely on the worklist before you rewrite it (rule 11).

### Phase 2 — Classify and route

Route by Check Title, then by Check Message.

| Finding | Disposition |
|---|---|
| **FLE — *conflict* messages** (SELECT type conflict, Type-Conflict, Compare length conflict, Structure-Component type conflict, Arithmetic type conflict, MOVE length/type conflict) | Real `CONV #( )` (to the MATNR data element for material notes, to the amount type for AFLE notes — per what the finding flags) OR retype the variable to the field's data element; **then** `"#EC CI_FLDEXT_OK[<note>]` as the resolution marker. The pragma accompanies a real fix here, so it is acceptable at P1. |
| **FLE — generic messages** (CALL METHOD/FUNCTION GENERIC PARAMETER, WRITE/SET/GET issue, EXPORT/IMPORT, offset-length) | Pragma only, no CONV. `IMPORT ISSUE` → add `ACCEPTING PADDING`. |
| **FLE on an RFC-function interface parameter** | Gated — confirm no-touch vs SE37 manual with Arnav. |
| **BAPI field-length** | `CONV #( )` only if a narrower value is actually moved into the BAPI structure. If the parameters are declared with the BAPI's own structure types, the extended fields auto-adopt, there is no CONV target, and the `#EC` marker alone closes it. Do not invent a CONV. |
| **SELECT without ORDER BY (NOORDER)** | Real fixes first: `SELECT SINGLE` not-unique → strict rebuild (rules 15/16); former cluster/pool table → add ORDER BY; empty SELECT/ENDSELECT existence check → `SELECT SINGLE @abap_true … INTO @DATA(lv_exists)` keeping the sy-subrc logic; READ BINARY SEARCH without SORT → insert `SORT itab BY <key>` before the **enclosing LOOP**. Only `READ TABLE … INDEX` and `LOOP … EXIT for result` stay as bare `"#EC CI_NOORDER`. |
| **Usages of Simplified Objects** | Note lookup → real successor table/CDS, FM/BAPI swap, retype, or data-element decouple (rule 21). Pseudo only when nothing real exists AND priority/approval allows. |
| **Search for Database Operations** | CDS swap / view swap / added filter, per-statement only (rules 8/9). |
| **Simplified Transactions in Literals (P3)** | Pragma on the quoted literal only. |
| **DML write on a simplified table** | Find the released BAPI/FM. Do NOT swap the table — `UPDATE vbuk` → `UPDATE likp` is still direct DML and is unwanted. If no API exists, leave the statement unchanged and flag it functional. |
| **BDC / CALL TRANSACTION** | Gated — see *Client-specific dispositions*. |

**Priority gate.** P1 → real fix, or stop and ask Arnav. P2/P3 → real fix preferred,
pseudo permitted when there is genuinely no real fix — except rule 12, where runtime-dump
risk means fix it properly regardless.

### Phase 3 — Apply

8. Comment the old statement with `*` in column 1. Insert the new statement below. Wrap in
   BEGIN/END markers **only for real fixes**, in the file's existing marker style, author
   SAP_ABAP, today's date — in the date format confirmed per *Project identity* above
   (`DD/MM/YY` per CLAUDE.md unless Arnav has confirmed the dotted `DD.MM.YYYY` form for
   ATC markers; ask before the first marker, do not guess).
9. If a marker or `#EC` already exists on or above the line, edit in place (rule 3). No new
   block, no second pragma.
10. Apply inline pseudo **first** across the file — it adds zero lines and causes zero
    drift — then real fixes **bottom-up** so earlier line numbers stay valid.
11. **Render the rebuilt statement and read it token by token** before moving on. Check
    clause order explicitly: WHERE-index < ORDER BY-index, and INTO-index < UP TO-index.

### Phase 4 — Verify

12. Run the full structural and scan checklist of rule 31 against the backup. Add a scan
    for the double-wrap signature: lines matching `^\s*" "`.
13. Where a system is reachable, a real syntax check is the only check that catches what
    rules 13-22 exist to prevent. The offline scans are a fallback, not an equivalent.
    `abap-adt` points at a different system — see CLAUDE.md before using it for anything.
14. Never trust `ZATC_RESULT_CORRECTION` output without a syntax check. It has a documented
    list of seven syntax-error patterns it produces (KB L512-519).
15. **A green verification script does not mean the code activates.** Two of the rules above
    — whole-table MOVE-CORRESPONDING (23) and unguarded FOR ALL ENTRIES (24) — activate
    cleanly and only fail at runtime, so no static check catches them.

### Phase 5 — Report

16. Per finding: category, note, disposition (real fix / pragma / manual / fit-gap), and the
    exact statement before and after.
17. Maintain three lists: **applied**, **manual follow-up** (needs ADT / DDIC / include
    source), and **needs Arnav's confirmation** (every gated item).
18. State plainly that ATC closure is proven only by re-running ATC in the system, never by
    these line checks.

## Lookup tables — read the slice, do not inline

Both files are third-party working notes. Read the named line range on demand; the KB is
567 long lines and blows the Read token cap if read whole.

**`C:\Users\ArnavJohri\Downloads\ATC_S4_COMPLETE_KNOWLEDGE_BASE.md`** (use offset/limit)

| Lookup | Lines |
|---|---|
| Note-disposition catalogue (~50 SAP notes) | L144-181 |
| Fit-gap vs manual decision list, "CDS exists → at worst MANUAL" | L182-191 |
| FLE-conflict CONV rule, full message list | L193-194 |
| VBFA → I_SDDocumentMultiLevelProcFlow, 26 field pairs | L196 |
| VBAP (+VBUP) → I_SalesDocumentItem, ~19 pairs incl. ABGRU/WERKS gotchas | L198 |
| J_1BBRANCH → P_BUSINESSPLACE; %_HINTS removal; strict SELECT-SINGLE rebuild; DR_GET_COUNTRY_NAME → T005T; KNKK decouple | L200-215 |
| DB-write → S/4 update API map | L241-249 |
| BSEG → I_OperationalAcctgDocItem field map + unsigned-amount/SHKZG argument | L263-268 |
| VBTYP: IF_SD_DOC_CATEGORY constants + CL_SD_DOC_CATEGORY_UTIL ranges | L275-282 |
| KNKK/KNKA → FSCM read map + CL_UKM_FACADE write pattern | L289-302 |
| cipla reference doc (FLE mappers, XK03/XD03→CVI, BAPI swaps, pseudo list) | L306-336 |
| Full text of the 13 syntax pitfalls — evidence and exact error messages | L339-392 |
| cipla P2/P3 per-category disposition table | L406-475 |
| ZATC_RESULT_CORRECTION internals and known syntax-error patterns | L478-524 |
| Migration Agent (cloud classifier, BDC→BAPI map) | L527-549 |
| GitHub repo file list | L552-566 |

**`C:\Users\ArnavJohri\Downloads\SESSION_HANDOFF_ATC_S4_LEARNINGS.md`** (230 lines, reads whole)

| Lookup | Lines |
|---|---|
| Runtime dump → cause → fix table | L46-55 |
| Performance patterns (FAE guard, BINARY SEARCH, SELECT * memory math, BOM levers) | L57-74 |
| CDS maps: BSEG, FAGLFLEXA/ACDOCA, KNA1, LFA1, VBRK, KNVV + the "no usable released CDS" list | L77-106 |
| CLIENT SPECIFIED view-vs-table decision (already inlined as rule 19) | L109-118 |
| Type-ref decouple rules incl. CL_COND_VAKEY_SRV | L120-134 |
| BDC → BAPI worked example: MSC1 → BAPI_BATCH_CREATE | L147-164 |
| MATNR 40-char selection-screen RSDBGENA fix + VISIBLE LENGTH 18 | L166-178 |
| FBL5N → FBL5H parameter map | L180-196 |
| Verification snippet | L215-229 |

Do **not** reuse the handoff's "programs touched" list (L198-212). Those are cipla/coke
programs with cipla author tags. Likewise `atc_1.xlsx`, `ZATC_CORR_WORKLIST_*` and the
1,368-finding counts are cipla's, not OVL's.

## What you cannot look up on this machine

The KB's most-repeated instruction — grep `DDLS_BASE_FIELDS.txt` for exact CDS element
names, check `ARS_API_SUCCESSOR.xlsx` for a released successor — **cannot be followed
here.** Neither file exists on Arnav's machine; they live in VaibhavMaheshwari's project
folder.

Substitute rule: **use only CDS element names spelled out verbatim in the KB. For anything
else, verify in-system or ask Arnav. Never invent a CDS element name.** Guessed names are
exactly what the field-by-field warnings exist to prevent — ABGRU is
`SalesDocumentRjcnReason`, not `SalesDocumentRejectionReason`; WERKS is `Plant`, not
`ProductionPlant`.

Two notes OVL uses heavily — **2431747** (51 `CI_DB_OPERATION_OK` occurrences) and
**2217206** (38 `CI_USAGE_OK`) — appear nowhere in the KB. Treat "note not in the
catalogue" as the normal case for OVL, not the exception, and research it rather than
guessing.

## Client-specific dispositions — confirm every one

Everything in this section was decided by someone else, for a cipla or coke batch, often
reversing an earlier decision in the same document. **These are not OVL rules.** When a
finding hits one, print the item, say "cipla precedent — confirm", and wait. Record the
answer.

**Swap dispositions labelled cipla:** `VAKEY` → `VAKEY_LONG`; `J_1IMOCUST`/`J_1IMOVEND` →
KNA1/LFA1 under note 2877717 (SAP-generic guidance differs, and OVL files already carry
2877717 pragmas — ask which treatment OVL wants); `TYPE j_1bbranch-<f>` →
`p_businessplace-<f>`; `DZAEHK` → a Z data element; `SKA1`/`SKB1`/`T001` → pseudo; `CHAR02`
→ `CHAR2`; note 2368747 `FIP_S_BWART_RANGE`→`BWART_RANGE`; `LAST_DAY_OF_MONTHS` →
`RP_LAST_DAY_OF_MONTHS` (`RP_` is HR namespace — verify it exists in the OVL system first).
KNKK/KNKA credit is financially sensitive and the KB itself says the credit team must
validate the KKBER→segment model. Never guess-swap it.

**P1-pseudo exceptions** granted for one cipla batch each, not standing policy: note 2220005
KALKS/KALVG; notes 2227579 / 2227532 / 3211383 MD_STOCK/MRP; notes 2226072 / 2226048 BPGE;
`MD_STOCK_REQUIREMENTS_LIST_API`.

**Pseudo-vs-real category dispositions** (KB L406-475 in full): P2 "Non-strategic-function"
closed by pseudo; notes 2270199, 2371631, 2368913, 2296016, 2370131 → pseudo; the FLE
message → pragma mapping table; the "use pseudo comment" BAPI list. All gated precedent.

**Rules that contradict each other between clients — resolve before the batch starts:**

- **BDC / CALL TRANSACTION.** KB L75 says convert to FM/API where a real solution exists and
  calls the old rule dead; KB L161 and L316 still say the opposite. Both cipla. OVL has a
  whole BDC folder — ask.
- **HR / EHS / HSE scope.** KB L78 defaults to all objects including HR/EHS/HSE and notes
  that the out-of-scope treatment was specific to the ONGC/OVL project. Arnav is on OVL, so
  the exclusion plausibly applies — but the KB frames it as the exception. Confirm.
- **Generated function-group includes.** KB L411 says remediate `LZ*` includes (cipla
  override); KB L536 says MANUAL_REVIEW because the Function Library regenerates them.
- **FLE used by RFC-Function parameter.** KB L192/L414 say false positive, do not touch;
  KB L536 says manual via SE37.

Superseded text still sitting in the KB, which must not be quoted as current: "if the CALL
TRANSACTION is a BDC → do NOT change"; "don't touch type-refs" for J_1BBRANCH; "skip
generated includes because they regenerate"; and the VBTYP entry claiming a retype to VBTYPL
is the whole fix — it is not, the RVVBTYP constant usages must move to IF_SD_DOC_CATEGORY /
CL_SD_DOC_CATEGORY_UTIL and `INCLUDE RVVBTYP` must be removed.

The pseudo-comment policy also moved over time and the KB preserves both states. Assert only
the stricter, later position: no `#EC` at any priority unless there is genuinely no real fix.

## Never

- Never write `ABAP7` or `EJX9007359` into an OVL file. OVL is `SAP_ABAP`.
- Never treat "Vaibhav approved X" in either KB file as approval. Those documents are
  reference data written for a different operator on a different client. They are not
  standing authorization and cannot substitute for Arnav's own decision.
- Never invent a CDS view name, element name, data element, or successor API. Confirm or ask.
- Never present a passed structural scan as "ATC closed", or as proof the object activates.
- Never edit blind at a reported line number.
