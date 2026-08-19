# SAP S/4HANA ATC Remediation & Performance Tuning — Session Handoff

Purpose: hand this to a new Claude session so it can continue cipla/coke SAP custom-code
ATC remediation, dump-fixing, and performance tuning with the same rules, patterns, and
verified CDS/BAPI mappings established here. **Read this fully before editing any program.**

---

## 0. Working context

- Client: **cipla** (some **coca-cola / CCEJ** programs too). SAP **S/4HANA** brownfield.
- Program source is stored as **`.txt` files** in `C:\Games\cipla\qatc\` (and subfolder
  `C:\Games\cipla\qatc\ATC_FINDING_4\`). Edit the `.txt`; the user pastes it back into SAP
  and activates. There can be **two copies** of a program (root vs ATC_FINDING_4) that DIFFER —
  always confirm which file the user means; use `md5sum`/line-count to compare.
- Authoritative CDS map: **`C:\Users\...\Claude\Projects\ATC\learning\DDLS_BASE_FIELDS.txt`**
  (pipe-delimited: `DDL_NAME|ENTITY|ELEMENT|BASE_OBJECT|BASE_FIELD|IS_CALCULATED`).
  **Always grep this to get exact CDS element names — never guess.**
  Also `ARS_API_SUCCESSOR.xlsx` (released successor + cloud-readiness).

---

## 1. Standing rules (do not violate)

1. **Real fix over pseudo.** **No P1 `#EC` pseudo without explicit user approval.** Comment the
   old code (don't delete), add the new code.
2. **Change markers:** `* * BEGIN OF CHANGE <AUTHOR> <DD.MM.YYYY> - <why>` … `* * END OF CHANGE <AUTHOR> <DD.MM.YYYY>`.
   - **cipla files → author `ABAP7`.**  **coke/CCEJ files → author `EJX9007359`** (user's SAP id).
   - **Never double-wrap.** If a line already carries a `BEGIN OF CHANGE`/`#EC`, edit **in place** — do not re-wrap or re-comment already-commented code.
3. **CDS: honest assessment.** Use CDS where it's a *real, verified* swap that helps (deprecated
   table, or view read that pushdown/removes a compat-view dump). **Do NOT force CDS** where the
   table is still valid/transparent and there's no released successor or perf gain (say so plainly).
4. **Never mass-regex SELECT bodies.** Do real DB-op/CDS/CONV fixes **program-by-program with a
   rendered-statement review.** Auto-rewriters corrupt code (`@@`, `,,`, double periods, half-done WHERE).
5. **Never rewrite `SELECT *` or JOINs to CDS** blindly.
6. **After every batch, verify structure balance** (active lines only, ignore `*`-comments):
   `IF==ENDIF`, `LOOP==ENDLOOP`, `FORM==ENDFORM`, `CASE==ENDCASE`, `TRY==ENDTRY`, and
   `SELECT(non-single)>=ENDSELECT`. Plus scans: no `@@`, no `,,`, no `INTO` before `ORDER BY`,
   no double `#EC`, markers BEGIN==END.
7. **Two duplicated forms** in one program is common → use `replace_all` for byte-identical statements
   (confirm identity with `diff` first).
8. **Multibyte (Japanese) comments**: read the exact bytes with the Read tool before an Edit match.

---

## 2. Runtime dumps seen this session → fixes

| Dump | Cause | Fix |
|---|---|---|
| **UC_OBJECTS_NOT_CONVERTIBLE** | a bad ATC "decouple" changed `TYPE mbew-bwtty` → `TYPE bwtty`, and bare `bwtty` resolves to **STRING**; ALV fieldcat expected CHAR1 | revert to `TYPE mbew-bwtty` (CHAR1). Lesson: **only decouple a field the note actually removed, and only if a data element of that exact name exists** (see §6). |
| **DBSQL_STMNT_TOO_LARGE** | `WHERE matnr IN r_matnr` where `r_matnr` is a range with one `EQ` per material (tens of thousands) → giant IN-list exceeds DB marker limit | replace with **guarded `FOR ALL ENTRIES`** on a de-duplicated driver table (kernel packetizes it). Also: `DELETE itab WHERE key NOT IN big_range` is O(n·m) → build a sorted keep-table + `READ … BINARY SEARCH`, mark & delete. |
| **TSV_TNEW_PAGE_ALLOC_FAILED** (OOM) | `SELECT *` on a huge table via **unguarded** `FOR ALL ENTRIES` (e.g. JCDS status history, ACDOCA) | narrow fields + add the missing WHERE filter (e.g. JCDS `AND stat = 'E002'` — the only status read) + **`IS NOT INITIAL` guard**; and/or narrow the internal-table type. |
| **DBSQL_ILLEGAL_CLIENT_SPECIFIED** | `... FROM <view> CLIENT SPECIFIED WHERE mandt = sy-mandt` — **`CLIENT SPECIFIED` is illegal on a compatibility VIEW** | drop `CLIENT SPECIFIED` **and** the `mandt = sy-mandt` condition. **View vs table matters** (see §5). |

---

## 3. Performance patterns (apply proactively)

- **`IS NOT INITIAL` guard before EVERY `FOR ALL ENTRIES`.** An empty driver makes the kernel
  **drop the WHERE and scan the whole table** (perf collapse / OOM). Highest risk: drivers built by
  `DATA(x)=src.` + `DELETE x WHERE …`, `DELETE x WHERE key NOT IN r`, or `VALUE #( FOR … IN src )`.
- **Linear `READ TABLE … WITH KEY` inside a `LOOP` → `SORT` the source + `BINARY SEARCH`** (O(n·log m)).
  Only when the source is sorted by the read key and **not modified inside the loop**. Do NOT binary-search
  a table that's re-sorted by different keys / `MODIFY`'d in the same loop (leave it linear).
- **Skip an expensive read when its result isn't used** (e.g. only read ACDOCA/FAGLFLEXA for profit
  center `IF s_prctr IS NOT INITIAL`).
- **`SELECT *`** into a `TYPE TABLE OF <dbtab>` → memory = rows×full-width. Reduce **rows** (filter/guard)
  first; narrowing fields only helps if you also retype the itab.
- **No SELECT-inside-LOOP** (per-row DB round-trips) — pre-fetch into a table + BINARY SEARCH.
- **BOM explosion** (`CS_BOM_EXPL_MAT_V2` in a loop over N materials) is inherently heavy: **no bulk
  BOM FM exists** (all are per-material; `CS_BOM_EXPLOSION` etc. are same/weaker). Real levers:
  (1) single-level via bulk `MAST/STKO/STPO` reads if multi-level not needed; (2) **SPTA parallel RFC**
  wrapper (needs Basis RZ12 server group); (3) reduce the material set. FM-for-FM swap does nothing.

---

## 4. Verified CDS mappings (from DDLS_BASE_FIELDS — reuse these)

**BSEG → `I_OperationalAcctgDocItem`** (alias each element `AS <bseg field>`, keep field order for
positional `INTO TABLE`; strict SQL: comma list, `@`-hosts, `INTO` last, drop CLIENT SPECIFIED+mandt):
bukrs=CompanyCode, belnr=AccountingDocument, gjahr=FiscalYear, buzei=AccountingDocumentItem,
buzid=AccountingDocumentItemType, koart=FinancialAccountType, lifnr=Supplier, matnr=Material,
sgtxt=DocumentItemText, zfbdt=DueCalculationBaseDate, shkzg=UnadjustedDebitCreditCode,
menge=Quantity, meins=BaseUnit, mwskz=TaxCode, ebeln=PurchasingDocument.
**dmbtr/wrbtr are UNSIGNED (sign carried by SHKZG)** → alias to `AbsoluteAmountInCoCodeCrcy` /
`AbsoluteAmountInTransAcCrcy` (also unsigned) and keep the shkzg logic. **Never use HSL/WSL (signed → double-sign).**
`SELECT *` and `SELECT..ENDSELECT`/`UP TO` on BSEG = carve-out (stay on BSEG, or SELECT SINGLE CDS if all keys map).

**FAGLFLEXA / ACDOCA → `I_GLAccountLineItem`** (also `I_JournalEntryItem`, `I_GLAccountLineItemRawData`):
ryear & gjahr=FiscalYear, docnr & belnr=AccountingDocument, **rldnr=SourceLedger** (filter `'0L'`),
rbukrs=CompanyCode, docln=LedgerGLLineItem, rtcur=BalanceTransactionCurrency, rcntr=CostCenter,
prctr=ProfitCenter, drcrk=DebitCreditCode, poper=FiscalPeriod, rwcur=TransactionCurrency,
buzei=AccountingDocumentItem, bschl=PostingKey.

**KNA1 → `I_Customer`**: kunnr=Customer, ktokd=CustomerAccountGroup. **LZONE is NOT exposed** →
keep KNA1 on the table if `lzone` is used.
**LFA1 → `I_Supplier`**: lifnr=Supplier, name1=OrganizationBPName1, ktokk=SupplierAccountGroup.
**VBRK → `I_BillingDocumentBasic`**: vbeln=BillingDocument, vtweg=DistributionChannel, bukrs=CompanyCode, spart=Division.
**KNVV → `I_CustomerSalesArea`**: kunnr=Customer, vkorg=SalesOrganization, vtweg=DistributionChannel, spart=Division, vwerk=SupplyingPlant, vkbur=SalesOffice.
**VBAK-KNUMV → `I_SalesDocument`.SalesDocumentCondition** (header view; `I_SalesDocumentItem` does NOT carry KNUMV).

**No usable released CDS (keep on table / other approach):**
- PM equipment master & related: **EQUI, EQUZ, ILOA, MPOS, MMPT, PLMK, JCDS, T370C, T370C_T, IFLOT, V_EQUI** →
  0 released CDS; not deprecated. Fix perf via query optimization, not CDS.
- **PAYR** (payment/check) → no CDS. **BKPF** is a retained table in S/4 (keep). Custom `Z*` tables → no CDS.

---

## 5. `CLIENT SPECIFIED` — view vs table (dump decision)

- **Illegal (dumps DBSQL_ILLEGAL_CLIENT_SPECIFIED) on compat VIEWS** → drop `CLIENT SPECIFIED` + `mandt`:
  **MBEW** (NSDM valuation view), **MSEG / MKPF** (MATDOC view), **FAGLFLEXA** (ACDOCA view). (BSID/BSAD, KONV→PRCD_ELEMENTS etc. are also views.)
- **Legal on real transparent tables** (have a MANDT key) → **leave as-is**:
  **INOB, KSSK, KLAH** (classification), **BKPF**, and all **custom `Z*`** tables.
- After removing `CLIENT SPECIFIED` you MUST also remove the `mandt = sy-mandt` WHERE line (you can't
  reference mandt without CLIENT SPECIFIED). `ORDER BY PRIMARY KEY` still works (orders by non-client key).

---

## 6. Type-ref decouples & simplified objects

- **Only decouple a `TYPE tab-field` for the field the note actually removed**, and **only if a data
  element of that exact bare name exists.** Example: NACH lost only VAKEY (note 2220005).
  - `vakey TYPE nach-vakey` → **`TYPE vakey_long`** (VAKEY_LONG exists — cipla rule, confirmed).
  - `nacha`/`kschl` were **NOT removed** → do NOT decouple to `TYPE nacha`/`TYPE kschl` (a bare
    data element `NACHA` does **not** exist → activation error "Type NACHA is unknown"). To still
    remove the NACH object reference: **retype to `nast-nacha` / `nast-kschl`** (NAST is a valid table with those fields).
  - Fast existence signal at activation: the syntax checker reports the **first** unknown type by line;
    a decouple on an earlier line that passed is confirmed valid.
- **VAKEY value reads** (`SELECT vakey … WHERE vakey = …`): VAKEY column is physically gone in S/4.
  Rework via **`cl_cond_vakey_srv=>get_instance( )->determine_vakey_from_db( iv_usage=<kvewe> iv_knumh=<knumh> iv_kotabnr=<kotabnr> )`**
  in a `TRY/CATCH cx_cond_vakey`; NACH still has KNUMH/KVEWE(='B')/KOTABNR/KSCHL/NACHA. The `FROM nach`
  read itself has no successor → reviewed `"#EC CI_USAGE_OK[2220005]` (needs approval).

---

## 7. NOORDER (SELECT/OPEN CURSOR without ORDER BY)

- Single-row `SELECT … UP TO 1 ROWS/EXIT … ENDSELECT` → **`SELECT … UP TO 1 ROWS … ORDER BY <selected fields>. ENDSELECT.`**
  (non-strict: `INTO` before `UP TO`, `UP TO` before `WHERE`, `ORDER BY` last).
  **Do NOT convert to `SELECT SINGLE`** on a partial key — ATC then flags "SELECT SINGLE possibly not unique".
- Former **cluster tables (BSET/BSEG)** `SELECT` without ORDER BY → add `ORDER BY <selected key fields>`.
- `READ … BINARY SEARCH` whose source itab was filled by an unsorted SELECT → **`SORT` the source** by the search key.
- `ORDER BY PRIMARY KEY` only valid on `SELECT *` (or when full key is in the field list). On a projection use `ORDER BY <selected key fields>`.

---

## 8. BDC → BAPI (MSC1 create batch)  — pattern used in ZMM_UOMIPD / ZMM_UOMX

- **BDC rule (2026-07-19): convert `CALL TRANSACTION` (incl. `USING bdcdata`) to FM/API where a real
  solution exists**; leave only where none is found. (Old "don't touch BDC" rule is dead.)
- `CALL TRANSACTION 'MSC1'` (Create Batch; MSC1 removed in S/4) → **`BAPI_BATCH_CREATE`**:
  material=RM03S-MATNR, batch=RM03S-CHARG, plant=RM03S-WERKS, `batchattributes-lastgrdate`=MCHA-LWEDT.
  Reference copy (`REF_MATNR/REF_CHARG` + `=CLAS`) → **`BAPI_OBJCL_GETDETAIL`** (ref, classtype `'023'`,
  objecttable `'MCH1'`) → **`BAPI_OBJCL_CREATE`** (new) → **`BAPI_TRANSACTION_COMMIT`** (else ROLLBACK on BAPIRET2 E/A).
  Map `BAPIRET2` → `bdcmsgcoll` so the existing `save_msg` keeps working.
  `RM03S-FZUST` (copy status) → `BAPI_BATCH_SET_BATCHSTATUS` (leave as TODO pending functional confirm).
  Drop dynpro control fields (BDC_OKCODE/BDC_CURSOR/OK-codes).
- **Gotcha:** the classification tables (`t_allocvaluesnum/char/curr`, `t_return`) are often **local to
  another FORM** → re-declare them **local** in the target form or you get "Field T_… is unknown".
- **Cross-check the ATC worklist by object name before rewriting a BDC** — many BDCs aren't actually flagged.
- **Append-field trap:** if a BDC pushes custom `/NS/` append fields (e.g. `/CCC/*` on LFA1), a master-data
  API (VMD_EI_API/CMD_EI_API) silently drops them unless registered with CVI — check before promising a swap.

---

## 9. Field-length extension (MATNR 40-char etc.)

- **Selection screen RSDBGENA "Error generating selection screen 1000":** a fixed `SELECTION-SCREEN
  COMMENT 60(nn)` on the same line as a now-**40-char MATNR** parameter collides (the input field runs
  past column 60). Fix: **`PARAMETERS p_x TYPE matnr … VISIBLE LENGTH 18`** (cleanest, keeps layout) or
  split the receiving field onto its own `BEGIN/END OF LINE`. (This surfaces only on full regeneration,
  so it can look like "it activated before".)
- **2438131 material longfield on a BAPI** (e.g. `BAPI_OBJCL_GETDETAIL` objectkey=matnr): if the target
  field already accommodates (e.g. `bapi1003_key-object` = CHAR50), **no `CONV` needed** → reviewed
  `"#EC CI_USAGE_OK[2438131]`. `CONV #( )` is only for a real type/length conflict.
- **2215424 ATWRT field-length on a `CALL METHOD` generic parameter** → `"#EC CI_FLDEXT_OK[2215424]`.

---

## 10. FI open-item reports (FBL5N vs FBL5H)  — ZFI_CUSTOMER_OPENITEM

- Pattern: `SUBMIT rfitemar … AND RETURN` (FBL5N) + `cl_salv_bs_runtime_info` capture into
  `ta_final_data TYPE TABLE OF rfposxext`. **This capture is the memory-dump source** (captures ALL
  matching line items into memory). `p_nmax` (max rows) bounds it — default/enforce it to stop OOM.
- **FBL5H = program `FAGL_LINE_ITEM_BROWSER_AR`**, HANA-optimized (reads ACDOCA). Faster DB read but:
  - **Different parameters:** `s_cust`(kunnr), `s_ccode`(company code), `p_ledger`('0L'),
    `p_oi`/`p_ci`/`p_ai`(open/cleared/all radiobuttons), `p_keydo`/`p_keydc`(key dates),
    `s_cdate`(clearing date), `s_pdate`(posting date), `p_ty_nor/spg/nit/pit`(item types),
    built-in profit center `s_rprctr`/`s_coarea`.
  - **No `pa_nmax`** → loses the row cap. **`kd_akont`/`kd_umskz`/`kd_vbund`/due-date → free selections**
    (`psx_item TYPE rsds_type`). **Output structure ≠ rfposxext** → the capture + downstream field
    mapping must be redone. So FBL5H is a **moderate rework**, and it does NOT by itself stop the OOM
    (still captures all rows). Bonus: its built-in profit center means the separate FAGLFLEXA read can be dropped.
- Best structural fix (redesign): read AR open items directly from a released CDS instead of SUBMIT+capture.

---

## 11. Programs touched this session (state)

- `ZFI_MATERIL_MASTER_REPORT.txt` — UC_OBJECTS dump fixed (bwtty → mbew-bwtty). ABAP7.
- `ZQM_PACKAGING_GOOSE.txt` — DBSQL_STMNT_TOO_LARGE (range→guarded FAE), DELETE→sorted+binary,
  6 FAE guards. (CS_BOM_EXPL loop discussed — not parallelized.) ABAP7.
- `COKE_1.txt` = `/CCEJ/RDMMPURR_PAYLIST_CREATE` — VAKEY (→vakey_long + CL_COND_VAKEY_SRV), BSEG→CDS,
  NOORDER (UP TO+ORDER BY), NACH→NAST retype, field-length pragmas, MATNR selection-screen split.
  **Markers = EJX9007359.**
- `ZPM_CALL_INSTLIST_REPORT.txt` — JCDS OOM (narrow+stat filter+guard), FAE guards, SORT+BINARY SEARCH. ABAP7.
- `ZMM_UOMIPD.txt` & `ZMM_UOMX.txt` — MSC1 BDC → BAPI_BATCH_CREATE; ZMM_UOMX also MBEW/MSEG
  `CLIENT SPECIFIED` removed. ABAP7. (ZMM_UOMX FBL5H swap discussed, not applied.)
- `ZFI_CUSTOMER_OPENITEM.txt` — FAGLFLEXA→I_GLAccountLineItem, VBRK/KNVV/LFA1→CDS, FAE guards,
  12 BINARY SEARCH, skip ACDOCA read unless s_prctr filled. ABAP7. (FBL5H migration pending — see §10.)

---

## 12. Verification snippet (run after each batch)

```bash
python3 - "<file>" <<'PY'
import sys,re
L=open(sys.argv[1],encoding='utf-8',errors='replace').read().split('\n')
act=lambda l: not l.lstrip().startswith('*')
c=lambda p: sum(1 for l in L if act(l) and re.match(p,l.strip().upper()))
for a,b in [(r'^IF\b',r'^ENDIF\b'),(r'^LOOP\b',r'^ENDLOOP\b'),(r'^FORM\b',r'^ENDFORM\b'),
            (r'^CASE\b',r'^ENDCASE\b'),(r'^TRY\b',r'^ENDTRY\b')]:
    print(a,c(a),b,c(b),'OK' if c(a)==c(b) else '*** MISMATCH')
PY
```
Also grep for: `@@`, `,,`, double `#EC`, `INTO TABLE @DATA(...)...ORDER BY` (mis-order), and
markers BEGIN==END. Confirm CDS element names against `DDLS_BASE_FIELDS.txt` (grep BASE_OBJECT) — never guess.
