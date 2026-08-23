# SAP ABAP Development Context — Handoff for GitHub Copilot

> **Purpose.** This is a single-file transfer of everything an AI assistant needs to work with
> me the way Claude Code did between 2026-07-20 and 2026-08-15: who I am, how I want code
> delivered, the systems I work on, the release-specific traps that have already cost me days,
> and the actual code patterns that were proven to activate.
>
> **How to use it with Copilot.** Save this file in the repo root as
> `.github/copilot-instructions.md` (Copilot Chat reads that automatically for every request in
> the workspace), or keep it as `COPILOT_CONTEXT_HANDOFF.md` and open it in a tab / attach it
> with `#file:COPILOT_CONTEXT_HANDOFF.md` before asking a question. Sections 2, 4 and 6 are the
> ones that change answer quality the most — if you have to trim, trim Section 5.
>
> **Not included, deliberately:** system passwords, user IDs and client email addresses that
> appeared in the sessions. Never paste those into an AI tool.

---

## 1. Who I am and what I work on

- **Arnav Johri**, Associate Consultant, Diligent Global (Diligent Tech India Pvt. Ltd.).
- **SAP ABAP developer**, working mostly in **MM (Materials Management)** and **PRA
  (Production & Revenue Accounting)** on **S/4HANA** systems that were migrated from ECC.
- Day-to-day work is a mix of: ECC→S/4 remediation (ATC findings), classic ABAP change
  requests (reports, module pools, BAdIs, enhancements), and new **CDS / RAP / Fiori** builds.
- I work across **several SAP systems at once**, often on a laptop that has no direct
  connection to the system I'm asking about. **Assume you cannot inspect my system.**
- I interact with functional consultants and client-side leads over email/Teams, so I regularly
  need short, professional draft messages alongside the code.

### Clients / engagements referenced throughout
| Short name | Engagement | Module focus |
|---|---|---|
| **OVL / ONGC** | ONGC Videsh Ltd — S/4 support phase, new developments + change requests | MM, PRA, JV accounting |
| **KPMG** | Client engagements at KPMG post ECC→S/4 migration | MM |
| **GAIL** | GAIL ECC→S/4 migration + new developments | MM |
| **UDAY / Astral** | Vendor master upload program (FSD 30) | MM |

### GitHub (all public, account `aj-02`)
| Repo | Contents |
|---|---|
| `aj-02/KPMG` | ZMM_VEND_UPLOAD + ZMB5B/ZRM07MLBD. Branches: `main` (README only), `documents` (FSD/TS/build guides), `draft-code` (initial/final drafts), `claude` (final per-object `.abap` with change markers) |
| `aj-02/ONGC` | OVL work — DPR RAP app code, build guides |
| `aj-02/GAIL` | GAIL migration objects |
| `vaibhavdiligent/ONGC-CST-Purchase-Date-Sharing-` | branch `claude/eager-euler-dpm9rf`, folder `src/rap` — original (non-release-adapted) DPR RAP source |

**Repo convention:** `main` holds only the README. Content is split by *type* into branches:
`documents` (FSD/TS/guides), `draft-code` (working drafts), `claude` (final deliverable code).

---

## 2. How I want you to work — the working agreement

These were learned from ~560 turns of real corrections. Following them is most of the difference
between a useful answer and a useless one.

### Code delivery
1. **Give me complete code, not fragments.** When I say "give the complete code" I mean the
   whole form/method/class/view from first line to last, with nothing elided. "…rest unchanged"
   or `" ... existing code ...` placeholders are a failure. I have repeatedly had to ask
   *"how have the lines reduced? give correct code without omitting anything"* — don't make me.
2. **Never silently drop lines.** If a file was 866 lines before, it is ≥866 lines after. I
   count.
3. **Comment out old code, never delete it.** New code goes *below* the commented original.
4. **One object at a time, then wait.** My workflow is: you give object N → I paste it into
   ADT/SE80 → I reply `activated, give the next` or paste the exact activation error → you fix
   → repeat. Don't dump 12 objects at once. Give the code, name the object, stop.
5. **When I paste an error, fix that error** — return the corrected full object, don't explain
   the error at length first.
6. **Don't touch standard SAP objects.** Changes go into a `Z` copy of the program. Create
   **custom includes only where an include actually changed** — never blanket-Z every include.
7. **Don't implement anything the FS/spec doesn't ask for.** "Do not make any modification which
   are not advised in the FS."

### Style of response
8. **Be concise.** No long preambles, no restating my question, no bullet-point essays about
   options I didn't ask for. If there's a decision, recommend one.
9. **Don't show me long reasoning.** Get to the code.
10. **Assume no system access.** Don't propose "let me check table X in your system" — I'm
    usually on a different machine/system than the one in question. Reason from the code and
    from SAP knowledge, or tell me the exact SE16/SE11/transaction navigation to check it
    myself.
11. **Don't guess field/table/CDS names.** If a mapping isn't confirmed, say so. A wrong CDS
    element name costs me an activation cycle.
12. **Flag risky assumptions explicitly** rather than burying them.

### Documents & messages
13. I frequently need a **TS (Technical Specification) document** alongside the code, with the
    *exact* include names and line numbers where code is added/replaced — modeled on a template
    I supply. Deliverable format is usually **Markdown + a matching `.docx`**.
14. I ask for **short, crisp, professional email/Teams drafts** to functional consultants and
    client leads. Keep them 3–6 lines, no flourish, sign-off `Thanks & Regards, Arnav Johri |
    Associate Consultant | Diligent Global`.

### Change-marker convention (non-negotiable — used in every delivered object)
```abap
*BOC By Arnav on 22/07/26          " Begin Of Change — wraps an ADDED/CHANGED block
...new or replacement code...
*EOC By Arnav on 22/07/26          " End Of Change

lv_field = 'X'.   "Changes by Arnav on 22/07/26   <- single-line change: trailing comment only
```
- Block change → `*BOC` / `*EOC` pair. Single line → trailing `"Changes by ...` comment.
- **Never double-wrap** an existing marker.
- The **author name in the marker changes per client**. For **OVL the SAP user id is
  `SAP_ABAP`** (marker: changes done by Arnav, user SAP_ABAP). Other clients seen in the shared
  ATC knowledge base use `ABAP7` (cipla) and `EJX9007359` (coke/CCEJ) — **do not** carry those
  over. Confirm before writing markers on a new client.
- A change tag is also used to make changes greppable, e.g. `"FSD30` on every touched line.

---

## 3. Systems and tooling

- **ADT project `SUPPORT_OCQ` / system OCQ client 500** — the main S/4 system for OVL work
  (package `ZPRA_S4`, and OVL MM objects). **This is an older S/4 release** — see §4.2; most
  generated CDS/RAP code does *not* activate unmodified.
- A second ADT/MCP endpoint exists at `http://192.168.11.21:8020` **client 200** — a different
  system that does *not* contain the ZPRA objects. Don't confuse the two.
- **abapGit / git standalone** is available in the destination system and is my preferred route
  for mass-uploading corrected programs (rather than pasting object by object).
- I also wrote a helper report **`ZR_PROG_DOWNLOAD`** — mass-downloads ABAP programs *with their
  full include tree* (and function groups / classes, by package or by name list) to the frontend
  via `GUI_DOWNLOAD` or to the app server via `OPEN DATASET`, reproducing the "SE80 → print with
  includes" layout. Selection-screen texts must be human-readable (no technical names on
  screen). There is a companion idea for a **mass-upload/activate program** that comments the
  previous code and pastes new code beneath it, and attaches objects to a transport.

---

## 4. Standing technical rulebook

### 4.1 Release-specific CDS / RAP limitations (system OCQ) — confirmed fixes

These are all real activation errors I hit and the fix that worked. Apply them **pre-emptively**
when generating CDS for this system.

| Problem | Fix that works |
|---|---|
| `Function YEAR is unknown` / `MONTH is unknown` | Derive from the date string: `substring(dats,1,4)`, `substring(dats,5,2)` |
| `Number of function parameters for DATS_ADD_MONTHS is not as expected: 2 <> 3` | 3rd arg is required: `dats_add_months(date, -3, 'INITIAL')` |
| `CAST of type INT4 to type NUMC is not possible` / `Data type INT4 … not compatible with NUMC` | INT↔NUMC casts are not allowed. Stay in the CHAR domain: `cast( substring(...) as abap.numc(n) )` (CHAR→NUMC is fine). Map month→fiscal period with a literal `CASE`, never arithmetic |
| `Annotation 'Semantics.calendar.date' unknown`, `Semantics.unitOfMeasure is not allowed in view entities` | Strip all `@Semantics.*` from view entities |
| `…-PRODQTY1 reference information missing or data type wrong` | Cast QUAN fields to `abap.dec(23,3)` to drop the unit-reference requirement |
| `Annotation 'Analytics.settings.maxResultSize' unknown`, `'MappingRole' used at wrong position`, `@Consumption.valueHelp` without the association | Remove them |
| `Unexpected word "-"` on a parameter | Parameter typing as `table-field` is not supported. Use a **data element**: dates→`datum`, year→`gjahr`, asset→`oiu_dn_no`, target code→`ztar_code` |
| `Parameter P_DATEFROM has no data type` (OData exposure) | Same cause — OData needs a **data element**, bare `abap.dats` is rejected |
| `Annotation 'ANALYTICS.QUERY' is not supported (Entity: …)` | `@Analytics.query: true` and `@Analytics.dataCategory: #CUBE` **cannot be exposed in an OData V4–UI service binding**. Convert analytical queries into plain keyed view entities (drop `@Analytics*`/`@AnalyticsDetails`, add keys, keep parameters). Don't expose cubes |
| `Entity type … has no key field assigned` / `Key must be contiguous and start at the first position` | Keys must be first and contiguous in the field list |
| `Unexpected keyword "case"` in GROUP BY | `CASE` is not allowed in `GROUP BY`. Add a helper view that exposes the classified column, then group on it (this is why `ZPRA_P_DPR_TAR_GRP` exists) |
| `Annotation 'UI.headerInfo.typeName' used at wrong position (wrong scope)` | In a metadata extension (DDLX), **entity-level** annotations (`@UI.headerInfo`, `@UI.chart`, `@UI.presentationVariant`) must appear **before** `annotate view`. Element annotations stack once per field. The base view needs `@Metadata.allowExtensions: true`. Keep `@UI.dataPoint` minimal (title only) |
| `Maximum accuracy 37 at DEC exceeded by an arithmetic expression` | Reduce intermediate precision — cast operands down before multiplying/dividing |
| `Do not use conversion exit OIUNM for property ASSETDESCRIPTION` | Strip the conversion exit: `cast( field as abap.char(100) )` |
| `Type "CX_AI_SYSTEM_ERROR" is unknown` | Not available. Drop the exception, use a plain `RETURN` / no-exception design |
| `Type "IF_XCO_XLSX_DOCUMENT" is unknown` | XCO XLSX is not available. Emit **CSV** via `cl_abap_codepage=>convert_to( )`, label it `.csv` / `text/csv` |
| `"PROD_QTY1" must be a character-like data object` with `CONCATENATE` | Build rows with string templates instead: `\|{ f }\|`, escape a literal pipe as `\\\|`, dates as `DATE = RAW` |
| RAP: `managed` behavior needs a persistent table | For an **action-only** entity use **`unmanaged`** (no CUD) |
| `Local classes of "CL_ABAP_BEHAVIOR_HANDLER" can only be derived in the "Local Definitions/Implementations"` | The `lhc_*` handler must live in the behavior class's **Local Types** tab, not the global source |
| `The type "C(10)" of "LS_PARAM-%PARAM-TARGET_CODE" is not compatible with the type "C(6)"` | `%param` field types must match exactly — assign through a correctly typed local variable |
| RAP query class: `Query not fully covered by implementation: Call to method if_rap_query_request~get_paging missing` | A custom-entity query provider **must** honour paging (`get_paging( )` → `get_offset`/`get_page_size`) and `get_requested_elements`, `get_sort_elements`, `is_total_numb_of_rec_requested` |
| `A RETURNING parameter must be fully typed` / `Multiple markers … ) (` | Method signatures cannot carry inline `LENGTH`/`DECIMALS`. Declare named `TYPES` first: `TYPES ty_amount TYPE p LENGTH 8 DECIMALS 2.` then use `ty_amount` |

### 4.2 ATC / ECC→S/4 remediation rules (non-negotiable)

Full knowledge base lives in two local files (read both before correcting anything for ATC):
`…\Downloads\ATC_S4_COMPLETE_KNOWLEDGE_BASE.md` and
`…\Downloads\SESSION_HANDOFF_ATC_S4_LEARNINGS.md`.

**Standing rules**
- **No P1 findings get a `#EC` pseudo-comment without my explicit approval.** P2/P3 may be
  pragma'd; P1s go on a separate manual-review list.
- **Comment old code, never delete.**
- **One pseudo-comment per line, maximum.** A `#EC` must start with `"`.
- **Never double-wrap change markers.**
- **Never mass-regex the body of `SELECT` statements.**
- `ORDER BY PRIMARY KEY` is only valid on `SELECT *` — never on a field list.
- **Strict Open SQL:** comma-separated field list, `@` escaping on the right-hand side only,
  `INTO` clause last.
- When swapping a table for a **CDS/compatibility view**, drop `CLIENT SPECIFIED` and any
  `mandt` reference.
- Put an `IS NOT INITIAL` guard before **every** `FOR ALL ENTRIES`.
- **Work only on findings that are still open.** I fix things by hand between runs, so line
  numbers drift and some findings are already resolved — never assume the list is current, and
  re-check rather than "fixing" something already fixed.
- **Workflow:** propose a solution for *one* finding of a family → I confirm → then apply that
  same solution across every object with that finding family. Write corrected files as **new
  files with the same name** in a separate `atc corrections` folder; leave the originals intact.

**Confirmed table → S/4 CDS replacements used**
| Obsolete access | Replacement |
|---|---|
| `BSEG` | `I_OperationalAcctgDocItem` |
| `SKA1` | `I_GLAccountInChartOfAccounts` |
| `SKB1` | `I_GLAccountInCompanyCode` |
| `CSKB` | `I_GLAccountInCompanyCode` |
| `J_1IMOVEND` | `LFA1` (sweep the whole include — every occurrence) |
| `J_1IMOCUST` | `KNA1` *(confirmed for cipla only — confirm before applying at OVL)* |
| `VAKEY` → `VAKEY_LONG` | *(cipla only — confirm)* |
| `VBRK`, `VBUP` | Small ones: `SELECT *` → pseudo-comment; explicit field list → CDS |

**Findings handled with pragmas / pseudo-comments (after approval)**
- `WRITE` inside a `LOOP`; `READ TABLE` without a key; `SELECT` without `ORDER BY`;
  `SELECT ... UP TO 1 ROWS ... ORDER BY PRIMARY KEY ... ENDSELECT` pattern;
  `SEL_EXIT`; EHS/HR/HSE findings; `XK01` call (kept on the manual list);
  transaction calls; `OIL_LAST_DAY_OF_MONTH`; `CURRENCY_AMOUNT_SAP_TO_DISPLAY`;
  `THREIC_CONTACT`; BAPI findings (when two SAP notes apply, put each note reference on its
  **own line** — never merge two notes into one line; keep previously applied note references).
- `DELETE ADJACENT DUPLICATES` findings → add a matching `SORT` **outside** any loop, sorting on
  exactly the fields compared in the `DELETE` (plain `SORT` if no fields are compared).
- **Scope note:** HR/EHS/HSE findings were treated as false-positive / out of scope specifically
  on the ONGC/OVL project — confirm scope rather than assuming "everything is in scope".

### 4.3 Fiori tile / RAP scoping rules (client delivery constraints, not technical limits)

- **Read-only only.** RAP create/update is out of scope "as of now" → a transactional object is
  simply *not convertible*. Don't propose managed or unmanaged BOs as an option.
- **ALV output ⇒ List Report tile.**
- **Radio buttons collapse into one tile only if the field set is identical** across options
  (i.e. the buttons change *rows*, not *columns*). Different column sets ⇒ separate tiles.
- Where RAP isn't possible, the fallback delivered is a **WebGUI iView tile** for the tcode.
- A "List Report tile" may still need a **CDS custom entity + query-provider class** rather than
  a plain CDS view, when the report logic isn't SQL-expressible (RFC calls, nested lookups).
  That's a real sizing difference — call it out.

---

## 5. Project history (chronological, 2026-07-20 → 2026-08-15)

### 5.1 GAIL — Delivery Point Allocation change (Jul 20)
FS: `FS for Delivery Point Allocation Change.docx`. Repo `aj-02/GAIL` created; development
targeted the **S2A** system via the ADT MCP connection.

### 5.2 KPMG — ZMB5B / ZRM07MLBD (MB5B stock report enhancement) (Jul 21–22)
- FS: `195_BRD_FS_ZMB5B_Report.doc`. Baseline is the **standard `RM07MLBD`** source (MB5B).
- Deliverable: a **`ZRM07MLBD` Z-copy** with all changes, **keeping standard include names**
  (custom includes only where an include actually changed — in the end **only the main program
  changed**).
- Functional scope, kept strictly to the FS: add an **amount column to the storage-location
  view**, implemented in `f0400_create_fieldcat` (the change sits near ~line 4170 of the main
  program).
- Files: `claude:zmb5b/zrm07mlbd.abap` (full Z program with markers),
  `draft-code:final draft/ZMB5B_ZRM07MLBD_enhancement.abap`, TS in `documents:TS/TS_ZMB5B.md|.docx`.

### 5.3 KPMG / UDAY-Astral — ZMM_VEND_UPLOAD vendor master upload (Jul 21–24)
- FS 30 `FSD_ZMM_VEND_UPLOAD`. Tcode **`ZMM_VEND_UPLOAD`**, program **`ZMM_VEND_MASTER`**,
  includes `_TOP`, `_SCR`, `_FORMS`, `_CL`.
- Baseline supplied was an **SE38 print listing**, not compilable source — so the enhancement
  was delivered as **10 clean, compile-ready "units"** each tagged `"FSD30`, with exact
  placement, rather than a whole-file replacement. (Later the full per-include `.abap` files
  were reconstructed on branch `claude`.)
- Requirements implemented: **R1** processing log + error-only download; **R2** auto-extend
  Company Code + Purchasing Org with *separate* status columns and "already extended" detection
  (`LFB1` / `LFM1`); **R3** a real **Change mode** (`rb_chg`) that is blank-safe — a blank cell
  never overwrites master data; **R4** validation + duplicate checks (GST/PAN/Tax) where a bad
  record is logged and skipped instead of stopping the batch.
- Key design points: `vmd_ei_api=>maintain_bapi` for create/extend/change;
  `datax-<field> = 'X'` set **only** when the source cell is populated (this is what makes
  Change mode safe); the baseline's `MESSAGE … LEAVE LIST-PROCESSING` hard stop removed; the
  dead `change_bp_vendor` form retired in favour of a change-aware `extend_bp`.
- Full code: §6.1 below and `aj-02/KPMG` branches `claude` / `draft-code`.

### 5.4 OVL — ZPRA DPR Analytical RAP app (Jul 23 – Jul 29) — the big build
Rebuild of the ONGC **Daily Production Report** Excel (tab 2 Actual-vs-BE-Target BOEPD graph,
tab 3 Production Performance, plus a summary download) as a **CDS + RAP + Fiori Elements**
application in system OCQ, package `ZPRA_S4`. Built object by object from a Word build guide
(`ZPRA_DPR_Analytical_RAP_ADT_Build_Guide_FULL.docx`, phases A–F), **porting every object** for
the older release using §4.1.

**Objects live and active:**
- Interface views: `ZPRA_I_DPR_DAILY`, `ZPRA_I_DPR_MONTHLY`, `ZPRA_I_DPR_TARGET`
- Cube: `ZPRA_C_DPR_CUBE`; base `ZPRA_P_DPR_DAY_BASE`, `ZPRA_C_DPR_BOEPD_DAY`
- Helper `ZPRA_P_DPR_TAR_GRP` (added purely to work around the CASE-in-GROUP-BY limit)
- Queries (all converted analytical → **plain keyed views**): `ZPRA_Q_DPR_PROD_QUERY`,
  `ZPRA_Q_DPR_TARGET_QUERY`, `ZPRA_Q_DPR_DAILY_TREND`, `ZPRA_Q_DPR_BOEPD_TREND`,
  `ZPRA_Q_DPR_PROD_PERF`, `ZPRA_P_DPR_PERF_AGG`
- Metadata extensions (DDLX) for all five queries; abstract entities `ZPRA_A_DPR_*`
- Root `ZPRA_I_DPR_EXCEL_DL`, class `ZCL_ZPRA_DPR_EXCEL`, behavior `ZPRA_BP_DPR_EXCEL_DL`
  (**unmanaged**) + impl `ZBP_ZPRA_DPR_EXCEL_DL`
- Service definition `ZPRA_SD_DPR_ANALYTICS` + binding `ZPRA_SB_DPR_ANALYTICS_O4`
  (**OData V4 – UI**, published, 9 entities)

**Source tables:** `ZPRA_T_DLY_PRD` (daily production), `ZPRA_T_PRD_TAR` (targets, keys
`gjahr/monat/asset/block/product/prod_vl_type_cd/tar_code`), `ZPRA_T_PRD_PI` (participating
interest %). Fiscal year is **April–March**.

**Deliberately deferred / open risks:**
- ⚠️ **DATA RISK:** the build uses **`tar_qty`** because the design's `tar_qty2` doesn't exist in
  `ZPRA_T_PRD_TAR`. Every "BE Target" figure depends on this. `tar_qty` semantics (daily vs
  monthly, JV vs OVL, gas unit) still need verifying in SE16.
- `ZCL_ZPRA_DPR_PDF` is a **stub** returning empty. A real PDF needs Adobe forms
  `ZPRA_FRM_DPR_PRODUCTION` / `ZPRA_FRM_DPR_TARGETS` in SFP + ADS (or Smart Forms, or an abapGit
  PDF library). The upstream repo has the real ADS code.
- The "Excel" download is actually **CSV** (no XCO XLSX in this release).
- Cubes not exposed; analytical queries downgraded to plain views; `@Semantics` UoM/date display
  stripped; some KPI criticality trimmed.
- Not done: Fiori Elements ALP apps + Launchpad tiles (upstream repo has a `ui5` folder),
  transport hygiene to QA/PRD, confirming the gas UoM codes.

**Fiori hand-off learnings:** the Fiori consultant needs the **service binding name** in the
"OData service" field when creating the tile. Chart annotations that finally worked follow the
`@UI.selectionPresentationVariant` + `@UI.presentationVariant(visualizations: [{ type: #AS_CHART }])`
+ `@UI.chart` triple in a metadata extension — a `@UI.chart` alone does not render. A 500 on
`/sap/opu/odata4/sap/zpra_sb_dpr_analytics/...` metadata was always an unsupported annotation or
a missing key in one of the exposed entities.

### 5.5 OVL — PR/PO validations and the Valuation Type defaulting saga (Jul 28 – Aug 4)
A long, high-value thread on **standard Fiori PR/PO apps**:

- **Problem:** Fiori PR app (service `MM_PUR_PR_PROFNL_MAINTAIN_SRV`) errored with *"valuation
  type should be entered"* on Enter — before Save — because split-valuated materials need
  `BWTAR` and the Fiori app has no such field.
- **Fix:** default the valuation type in code by reading **`MBEW`** for `MATNR` + `BWKEY`
  (plant), `bwtar <> space`, `lvorm = space`, in BAdI **`ME_PROCESS_REQ_CUST`**, method
  **`PROCESS_ITEM`** — guarded to **creation only**, not editing (`data_persistent IS INITIAL`,
  `loekz IS INITIAL`, `matnr`/`werks` filled, `bwtar` initial, plus a material-prefix exclusion).
  Same fix mirrored into **`ME_PROCESS_PO_CUST~PROCESS_ITEM`** so PO copies it from PR.
- **Verified concern:** whether a classic BAdI actually fires on the OData path. The Fiori PR app
  goes through `CL_MM_PUR_PR_DPC_EXT` (264 methods); the enhancement *does* run because the
  gateway DPC ultimately calls the same MM PR maintenance kernel that triggers
  `ME_PROCESS_REQ_CUST`. Beware `SY-UCOMM` / `SY-TCODE` guards in old enhancements — they are
  empty on the Fiori path, so a condition like `sy-ucomm = 'MESAVE'` silently disables your code.
- **Related dump fixed:** `An attempt was made to access a field symbol that has not been
  assigned yet` from `ASSIGN ('(SAPLMEGUI)G_WORKFLOW') TO <fs5>` in enhancement
  `ZMM_UPDATE_EPROFILE` — the GUI-only global doesn't exist on the Fiori path, so the whole
  workflow-event block (`SWE_EVENT_CREATE` for `ZZBUS2105` / `PR_RELEASE`) had to be commented
  out and re-guarded.
- **Mandatory-contract validation:** doc type **`SWO`** ⇒ `MEREQ3322-KONNR` must not be blank.
  Implemented in `IF_EX_ME_PROCESS_REQ_CUST~CHECK` (chosen over `PROCESS_ITEM` because a prior
  validation already worked there), with the message text carrying the doc-type variable and its
  description: *"For document type SWO, maintaining contract is mandatory"*.
- **Item-category validation:** for doc types **SEM, SNB, SRC, SWO**, blank (`' '` = Standard)
  item category (`PSTYP`) is not allowed. Message: *"For \<DocType\> Document Type, Blank
  (Standard) Item category not allowed."* Also in `~CHECK`. `LOEKZ` is checked so deleted items
  are skipped.
- **RFQ equivalent:** there is **no `ME_PROCESS_RFQ_CUST`**. RFQ (ME41/ME42) is classic dynpro
  `SAPMM06E`, so the RFQ side must be done via **field selection**, enhancement **`MM06E005`**,
  or directly in include **`LMLSLF0R`** / function group **`MLSL`** / **`ROW_IN`** /
  **screen `0115`** — these are the objects I identified for the RFQ change request.

### 5.6 OVL — ATC S/4 remediation (Aug 5 – Aug 14)
- Scope built by intersecting two exports: `export_atc_errors.xlsx` (full ATC run) with the
  senior-assigned object list — **847 findings** on objects assigned to me, written to a filtered
  workbook. `atc_ovl_090626.xlsx` and `ATC Tool Object List\` are the reference exports.
- Worked **family by family** (small pragma-able families first, then the actionable blocks:
  BSEG / SKA1 / SKB1 / CSKB / VBRK / VBUP / J_1IMOVEND / BAPI notes / EHS / tail items). Rules in
  §4.2.
- One representative object: `zpra_dpr_report_new1` — including a width bug where `PRODUCT` is
  `CHAR 40` but `lv_col_name` was `CHAR 30`, truncating data; resolved by widening to a 60-char
  data element rather than reworking headings.
- Upload strategy for the corrected sources: **git standalone / abapGit** into the destination
  system, with include file names preserved exactly.

### 5.7 OVL — ZMMEMD / ZMM_TENDER_REG report fixes + 5 Fiori tiles (Aug 10 – Aug 14)
- **ZMMEMD** (module pool `SAPMZMMEMD`, EMD management): added an **LOA# (`ZMM_EMDHDR-LOA_NO`)**
  field to the Change and Display selection popups; required creating an **additional elementary
  search help** on the header table (the existing `ZMM_HDRFCDOC` search help reads
  `ZMM_EMDDTL`, not the header). Plus four further points fixed in the same report.
- **Fiori tile scoping** across `ZMMTMS`, `ZMMEMD`, `ZMM_TENDER_REG`, `ZMMTENDERRPT`, `ZMM_VMS`
  using the rules in §4.3:
  - `ZMM_TENDER_REG` (= program `ZREP_TENDER_REGISTER`) → **three separate List Report tiles**;
    its three radio buttons return 22 / 38 / 12-column structures and the selection blocks are
    mutually greyed out. Needs **custom entities** because of `PA0002` / `T024` / `LFA1` lookups.
  - `ZMMEMD` → **not convertible** (create/change/delete dialog app) → WebGUI iView tile.
  - `ZMMTENDERRPT` → custom entity + query provider.
  - Delivered as **5 List Report RAP apps**; classes such as `ZCL_OVL_TRPT_LIST`,
    `ZCL_OVL_TRPT_DATA`, views such as `ZC_OVL_SO_REG`. Because the report calls
    `ZSRM_GET_E_PROC_DATES` by RFC (`DESTINATION l_logsys`), that call is commented out in the
    CDS/class path exactly as it was in the GUI program.
  - All CDS added to **one** service definition + binding rather than one OData service per tile.
  - Validation method: run the tcode in GUI, export the CDS output as CSV, and **compare row for
    row** before handing the tile to the functional consultant.
  - Deployment discussed via **BTP** (`npm run deploy-config`, `npm install`, `npm run deploy`).

### 5.8 OVL — JV posting / Colombia transfer programs (Aug 13 – Aug 14)
- **`ZR_JV_POST`** — JV Transfer: Colombia OCV→OVL, Cutback, NB, Corporate Items. Source table
  **`JVSO1`** (JV accounting, ledgers **4A / 4C**). Mapping Z-tables:
  `ZJV_MAP_COCODE` (JV/Recovery indicator → receiving company code),
  `ZJV_MAP_GL`, `ZJV_MAP_RCNTR`, `ZJV_MAP_WBS`, `ZJV_MAP_PRCTR`.
- Change delivered: receiving GL is now derived from **sender GL + company code + JV** (JV added
  as a key), and the **offset profit center** for type `V` (vendor) / `G` offsets is read from a
  new **`PC_DEFAULT`** field on **`ZJV_MAP_COCODE`** (per venture) instead of being hardcoded.
  `ZJV_MAP_COCODE` structure: `MANDT, OP_BUKRS, OP_VNAME, OP_RECID, TYPE, OFFSET_GL, REC_BUKRS`
  (+ new `PC_DEFAULT`). The `RPROJK` where-clause in the read query stays uncommented.
- Related program **`ZJV_DOC_TRANSFER`** (all includes in one file) for the same mapping logic.

### 5.9 OVL — Deep-entity OData service for daily production (Aug 14)
- Existing: a **classic gateway (SEGW) OData V2** service with
  `zcl_zpra_daily_prod_mpc_ext`/`_dpc_ext`, method `DAILYPRODUCTIONS_CREATE_ENTITY`, writing to
  `ZPRA_T_DLY_PRD` — one message per record from the CPI side, which is the problem.
- Goal: a **deep-entity** service (reference: `ZF01_EXCHANGE_RATE_HANDOVER.md`) so CPI can send a
  batch (~20 records) in a single call. Alternative accepted: keep the flat entity and have CPI
  use an OData **`$batch` changeset**. Implementation route chosen: **B** (see that file).

### 5.10 Cross-cutting: misc fixes worth remembering
- `Error during insertion into a table with a unique key` in `ZMM_RETURN_DELIVERY_GST` — caused by
  `MODIFY ta_output FROM wa_output` inside `LOOP AT ta_output INTO wa_output` when the table has a
  unique key and the work area was mutated (`field_style` appended). Fix: loop with
  `ASSIGNING FIELD-SYMBOL(<wa>)` and modify in place, or collect and modify by index.
- **`EIKP`** (foreign trade header) replacement in S/4 — researched externally, not in-system.
- Fiori tile errors **do** surface in `/IWFND/ERROR_LOG`; use it plus the `$batch` payload to
  identify which entity/property is failing.
- Launchpad: to give users a folder of tiles, the **group** must be assigned to the user's
  **catalog + role**; tiles being individually accessible doesn't mean the group is published.

---

## 6. Code pattern library

These are the patterns that worked in this landscape. Prefer them over generic ABAP examples.

### 6.1 Validate-then-process with per-row logging (never stop the batch)

```abap
FORM validate_create.                                       "FSD30 R4
  DATA: lt_valid    TYPE STANDARD TABLE OF ty_file_bp,
        lt_seen_pan TYPE HASHED TABLE OF j_1ipanno WITH UNIQUE KEY table_line,
        lt_seen_gst TYPE HASHED TABLE OF stcd3     WITH UNIQUE KEY table_line,
        lv_row      TYPE i,
        lv_err      TYPE string.

  LOOP AT it_file INTO wa_file.
    lv_row = sy-tabix.
    CLEAR: lv_err, w_log.

    IF wa_file-partn_grp IS INITIAL.
      lv_err = |{ lv_err }BP Grouping missing; |.
    ENDIF.
    IF wa_file-name_first IS INITIAL.
      lv_err = |{ lv_err }Name1 missing; |.
    ENDIF.

    " master-data existence
    IF wa_file-bukrs IS NOT INITIAL.
      SELECT SINGLE bukrs FROM t001 INTO @DATA(lv_bukrs) WHERE bukrs = @wa_file-bukrs.
      IF sy-subrc <> 0.
        lv_err = |{ lv_err }Company Code { wa_file-bukrs } does not exist; |.
      ENDIF.
    ENDIF.

    " duplicate: within file (hashed set) AND against DB
    IF wa_file-stcd3 IS NOT INITIAL.
      IF line_exists( lt_seen_gst[ table_line = wa_file-stcd3 ] ).
        lv_err = |{ lv_err }Duplicate GST { wa_file-stcd3 } within file; |.
      ELSE.
        INSERT wa_file-stcd3 INTO TABLE lt_seen_gst.
        SELECT SINGLE partner FROM dfkkbptaxnum INTO @DATA(lv_ptnr)
               WHERE taxnum = @wa_file-stcd3.
        IF sy-subrc = 0.
          lv_err = |{ lv_err }GST { wa_file-stcd3 } already exists (BP { lv_ptnr }); |.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_err IS NOT INITIAL.
      w_log         = CORRESPONDING #( wa_file ).
      w_log-rowno   = lv_row.
      w_log-msgty   = 'E'.
      w_log-message = lv_err.
      APPEND w_log TO t_log.            "logged as failed, not processed
    ELSE.
      APPEND wa_file TO lt_valid.
    ENDIF.
  ENDLOOP.

  it_file = lt_valid.                   "only valid rows go forward
ENDFORM.
```

### 6.2 Blank-safe master-data maintain (`datax` only when the cell is filled)

This is the core of a safe "Change" mode — a blank cell must never wipe master data.

```abap
IF wa_file_extend-zterm IS NOT INITIAL.
  ls_company-data-zterm  = wa_file_extend-zterm.
  ls_company-datax-zterm = 'X'.          "flag ONLY when populated
ENDIF.

" already-extended detection -> warning, kept separate from the create status
SELECT SINGLE bukrs FROM lfb1 INTO @DATA(lv_lfb1)
       WHERE lifnr = @lv_vendor AND bukrs = @wa_file_extend-bukrs.
IF sy-subrc = 0.
  w_log_ex-stat_cc = 'W'.
  w_log_ex-message = |{ w_log_ex-message }CC { wa_file_extend-bukrs } already extended; |.
ELSE.
  w_log_ex-stat_cc = 'S'.
ENDIF.

vmd_ei_api=>initialize( ).
CALL METHOD vmd_ei_api=>maintain_bapi
  EXPORTING is_master_data           = gs_vmds_extern
  IMPORTING es_master_data_correct   = gs_vmds_succ
            es_message_correct       = gs_succ_messages
            es_master_data_defective = gs_vmds_error
            es_message_defective     = gs_err_messages.

IF gs_err_messages-is_error IS INITIAL.
  COMMIT WORK.
  w_log_ex-msgty = COND #( WHEN w_log_ex-stat_cc = 'W' OR w_log_ex-stat_po = 'W'
                           THEN 'W' ELSE 'S' ).
ELSE.
  ROLLBACK WORK.
  w_log_ex-msgty = 'E'.
  LOOP AT gs_err_messages-messages INTO DATA(ls_msg).
    w_log_ex-message = COND #( WHEN w_log_ex-message IS INITIAL
                               THEN ls_msg-message
                               ELSE |{ w_log_ex-message } / { ls_msg-message }| ).
  ENDLOOP.
ENDIF.
APPEND w_log_ex TO t_log_ex.
```

### 6.3 Error-only download (subset + `GUI_DOWNLOAD`)

```abap
lt_err = VALUE #( FOR ls IN t_log WHERE ( msgty CA 'EA' ) ( ls ) ).
IF lt_err IS INITIAL.
  MESSAGE 'No error records to download.' TYPE 'S'.
  RETURN.
ENDIF.

cl_gui_frontend_services=>file_save_dialog(
  EXPORTING default_extension = 'XLS'
            default_file_name = |BP_Vendor_ERROR_Log_{ sy-datum }_{ sy-uzeit }.xls|
  CHANGING  filename = lv_filename path = lv_path fullpath = lv_fullpath ).

IF lv_fullpath IS NOT INITIAL.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING filename              = lv_fullpath
              filetype              = 'ASC'
              write_field_separator = 'X'
              confirm_overwrite     = 'X'
    TABLES    data_tab              = lt_err
    EXCEPTIONS file_write_error = 1 OTHERS = 2.
ENDIF.
```

### 6.4 Defaulting valuation type on PR/PO creation (BAdI, creation-only)

```abap
METHOD if_ex_me_process_req_cust~process_item.
  DATA: lt_bwtar     TYPE STANDARD TABLE OF mbew-bwtar,
        l_bwtar      TYPE mbew-bwtar,
        l_bwtar_cnt  TYPE i.

  DATA(ls_mereq) = im_item->get_data( ).

  "*BOC By Arnav — default valuation type for split-valuated materials (creation only)
  IF ls_mereq-loekz IS INITIAL
     AND ls_mereq-matnr IS NOT INITIAL
     AND ls_mereq-werks IS NOT INITIAL
     AND ls_mereq-bwtar IS INITIAL
     AND ls_mereq-matnr+0(2) <> '0C'.

    REFRESH lt_bwtar.
    SELECT bwtar FROM mbew INTO TABLE lt_bwtar
           WHERE matnr = ls_mereq-matnr
             AND bwkey = ls_mereq-werks
             AND bwtar <> space
             AND lvorm = space
           ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      DESCRIBE TABLE lt_bwtar LINES l_bwtar_cnt.
      READ TABLE lt_bwtar INTO l_bwtar INDEX 1.
      ls_mereq-bwtar = l_bwtar.
      im_item->set_data( ls_mereq ).
    ENDIF.
  ENDIF.
  "*EOC By Arnav
ENDMETHOD.
```
> **Guard note:** do **not** add `sy-ucomm` / `sy-tcode` conditions — they are empty on the
> Fiori/OData path and will silently disable the logic. `ME51N` = create PR; the same shape goes
> into `IF_EX_ME_PROCESS_PO_CUST~PROCESS_ITEM` so a PO created w.r.t. a PR inherits it.

### 6.5 Document-type validation in `~CHECK`

```abap
METHOD if_ex_me_process_req_cust~check.
  INCLUDE mm_messages_mac.
  DATA(ls_item) = im_item->get_data( ).

  "*BOC By Arnav — contract mandatory for doc type SWO
  IF ls_item-loekz IS INITIAL AND ls_item-bsart = 'SWO' AND ls_item-konnr IS INITIAL.
    SELECT SINGLE batxt FROM t161t INTO @DATA(lv_batxt)
           WHERE spras = @sy-langu AND bstyp = 'B' AND bsart = @ls_item-bsart.
    MESSAGE |For document type { ls_item-bsart } ({ lv_batxt }), maintaining contract is mandatory| TYPE 'E'.
  ENDIF.

  " blank (Standard) item category not allowed for these doc types
  IF ls_item-loekz IS INITIAL AND ls_item-pstyp IS INITIAL
     AND ls_item-bsart IN VALUE rseloption( ( sign = 'I' option = 'EQ' low = 'SEM' )
                                            ( sign = 'I' option = 'EQ' low = 'SNB' )
                                            ( sign = 'I' option = 'EQ' low = 'SRC' )
                                            ( sign = 'I' option = 'EQ' low = 'SWO' ) ).
    MESSAGE |For { ls_item-bsart } Document Type, Blank (Standard) Item category not allowed.| TYPE 'E'.
  ENDIF.
  "*EOC By Arnav
ENDMETHOD.
```

### 6.6 CDS view entity — release-safe shape for this system

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DPR Daily Base'
@Metadata.allowExtensions: true          // required if a DDLX will extend it
define view entity zpra_p_dpr_day_base
  with parameters
    p_datefrom : datum                   // data element, NOT abap.dats, NOT table-field
  as select from zpra_t_dly_prd
{
      // keys first and contiguous
  key production_date,
  key asset,
  key product,
      substring( production_date, 1, 4 )                        as prod_year,
      cast( substring( production_date, 5, 2 ) as abap.numc(2) ) as prod_month,  // CHAR->NUMC ok
      cast( prod_vl_qty1 as abap.dec(23,3) )                     as prod_qty1,   // drops the UoM ref
      cast( asset_desc   as abap.char(100) )                     as asset_desc   // strips conv. exit
}
where production_date >= $parameters.p_datefrom
```
Forbidden here: `year()`, `month()`, `@Semantics.*`, `@Analytics.query`, `@Analytics.dataCategory:
#CUBE` in an exposed binding, `CASE` in `GROUP BY`, `cast( <int> as abap.numc(n) )`.

### 6.7 Metadata extension that actually renders a chart

```abap
@Metadata.layer: #CORE

// ---- entity-level annotations MUST come before `annotate view` ----
@UI.headerInfo: { typeName: 'BOEPD Trend', typeNamePlural: 'BOEPD Trend',
                  title: { type: #STANDARD, value: 'ProductionDate' } }
@UI.selectionPresentationVariant: [{ qualifier: 'Default',
                                     presentationVariantQualifier: 'Default',
                                     selectionVariantQualifier: 'Default' }]
@UI.presentationVariant: [{ qualifier: 'Default',
                            visualizations: [{ type: #AS_CHART, qualifier: 'BoepdVsTarget' }] }]
@UI.selectionVariant: [{ qualifier: 'Default', text: 'Default' }]
@UI.chart: [{ qualifier: 'BoepdVsTarget',
              title: 'Actual Production vs BE Target (BOEPD)',
              chartType: #LINE,
              dimensions: ['ProductionDate'],
              measures:  ['ActualBoepdOvl', 'TargetBoepd'],
              measureAttributes:   [{ measure: 'ActualBoepdOvl', role: #AXIS_1, asDataPoint: true },
                                    { measure: 'TargetBoepd',    role: #AXIS_1, asDataPoint: true }],
              dimensionAttributes: [{ dimension: 'ProductionDate', role: #CATEGORY }] }]
annotate view zpra_q_dpr_boepd_trend with
{
  @UI.lineItem: [{ position: 10 }]
  ProductionDate;
  @UI.lineItem: [{ position: 20 }]
  ActualBoepdOvl;
}
```
> A `@UI.chart` on its own will not render. The Fiori app needs the
> `selectionPresentationVariant → presentationVariant(#AS_CHART) → chart` chain.

### 6.8 Custom entity + query provider class (when the report isn't SQL-expressible)

```abap
CLASS zcl_ovl_trpt_data DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " A method signature cannot carry LENGTH/DECIMALS inline, and a RETURNING
    " parameter must be FULLY typed -> declare named TYPES first.
    TYPES ty_amount TYPE p LENGTH 8 DECIMALS 2.
    TYPES ty_submi  TYPE c LENGTH 10.
    TYPES: BEGIN OF ty_list,
             submi   TYPE ty_submi,
             tdrdt   TYPE d,
             tndrval TYPE ty_amount,
           END OF ty_list.
    TYPES tt_list TYPE STANDARD TABLE OF ty_list WITH DEFAULT KEY.

    INTERFACES if_rap_query_provider.
ENDCLASS.

CLASS zcl_ovl_trpt_data IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA(lt_out) = build_list( ).                    " your real logic

    " paging is MANDATORY, otherwise: "Query not fully covered by implementation"
    DATA(ls_paging) = io_request->get_paging( ).
    DATA(lv_offset) = ls_paging->get_offset( ).
    DATA(lv_size)   = ls_paging->get_page_size( ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_out ) ).
    ENDIF.

    IF lv_size >= 0.
      DATA(lt_page) = VALUE tt_list( ).
      LOOP AT lt_out INTO DATA(ls) FROM lv_offset + 1 TO lv_offset + lv_size.
        APPEND ls TO lt_page.
      ENDLOOP.
      io_response->set_data( lt_page ).
    ELSE.
      io_response->set_data( lt_out ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
```
> The upstream GUI report called `ZSRM_GET_E_PROC_DATES` via `DESTINATION l_logsys` — that RFC is
> commented out in both the GUI program and this class. Keep them consistent.

### 6.9 Unmanaged RAP behavior for an action-only entity

```abap
// behavior definition ZPRA_BP_DPR_EXCEL_DL — unmanaged, because there is no persistent table
unmanaged implementation in class zbp_zpra_dpr_excel_dl unique;

define behavior for ZPRA_I_DPR_EXCEL_DL alias ExcelDownload
{
  static action downloadExcel parameter ZPRA_A_DPR_DL_PARAM result [1] ZPRA_A_DPR_DL_RESULT;
}
```
- The `lhc_*` handler class (subclass of `cl_abap_behavior_handler`) goes in the behavior class's
  **Local Types** tab, never the global source.
- `%param` component types must match the handler's parameters **exactly** — assign through a
  typed local variable (`C(10)` vs `C(6)` was a real activation error).

### 6.10 CSV export instead of XLSX (no XCO in this release)

```abap
DATA lv_csv TYPE string.
lv_csv = |Date,Asset,Product,Qty,UoM{ cl_abap_char_utilities=>newline }|.
LOOP AT lt_rows INTO DATA(ls_row).
  lv_csv = |{ lv_csv }{ ls_row-production_date DATE = RAW },{ ls_row-asset },| &&
           |{ ls_row-product },{ ls_row-prod_qty1 },{ ls_row-prod_uom1 }| &&
           |{ cl_abap_char_utilities=>newline }|.
ENDLOOP.

DATA(lv_xstring) = cl_abap_codepage=>convert_to( source = lv_csv ).
" hand back as .csv / text/csv — NOT .xlsx
```
> `CONCATENATE` needs character-like operands; use string templates. Escape a literal pipe as
> `\|` inside a template, and format dates with `DATE = RAW`.

### 6.11 ATC pseudo-comment placement (one per line, starts with `"`)

```abap
SELECT * FROM mara INTO TABLE @DATA(lt_mara)     "#EC CI_NOWHERE
       ORDER BY PRIMARY KEY.                     " valid only on SELECT *

READ TABLE lt_items INTO DATA(ls_item) INDEX 1.  "#EC CI_STDSEQ

LOOP AT lt_out INTO DATA(ls_out).
  WRITE: / ls_out-matnr.                         "#EC CI_WRITE_IN_LOOP
ENDLOOP.

" DELETE ADJACENT DUPLICATES needs a matching SORT, placed OUTSIDE the loop
SORT lt_out BY matnr werks.
DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr werks.
```

### 6.12 The `MODIFY` inside `LOOP` unique-key dump

```abap
" WRONG — dumps with "Error during insertion into a table with a unique key"
LOOP AT ta_output INTO DATA(wa_output).
  APPEND lwa_stylerow TO wa_output-field_style.
  MODIFY ta_output FROM wa_output.
ENDLOOP.

" RIGHT — modify in place, no re-insert
LOOP AT ta_output ASSIGNING FIELD-SYMBOL(<wa_output>).
  IF <wa_output>-matnr IS NOT INITIAL.
    APPEND VALUE #( fieldname = co_steuc
                    style     = cl_gui_alv_grid=>mc_style_disabled )
           TO <wa_output>-field_style.
  ENDIF.
ENDLOOP.
```

---

## 7. Open items / things to verify before trusting anything above

1. **`tar_qty` vs `tar_qty2`** in `ZPRA_T_PRD_TAR` — every DPR "BE Target" figure depends on
   which one is correct, and on whether it is a daily or monthly figure, JV or OVL share.
   Verify in SE16 before shipping DPR numbers.
2. **PDF output for DPR** is a stub. Needs Adobe forms + ADS, Smart Forms, or an abapGit PDF lib.
3. **"Excel" download is CSV.**
4. Cipla-labelled ATC dispositions (`J_1IMOCUST→KNA1`, `VAKEY→VAKEY_LONG`) are **not**
   automatically OVL rules.
5. `DDLS_BASE_FIELDS.txt` and `ARS_API_SUCCESSOR.xlsx` (the CDS element lookups referenced by the
   ATC knowledge base) are **not on my machine** — CDS element names cannot be re-verified
   locally. Use only mappings already spelled out, never guess one.
6. The RFQ objects (`LMLSLF0R`, FG `MLSL`, `ROW_IN`, screen `0115`) were recorded from my own
   analysis and **were never verified against a live system**. Confirm before coding.
7. DPR: confirm the fiscal variant really is **Apr–Mar** and confirm the gas UoM codes.

---

## 8. Building from scratch (FS → working object)

### 8.0 Calibrate the target release FIRST — before generating any CDS

⚠️ **§4.1 describes system OCQ, an older S/4 release.** If the new project runs on a *different*
system, some of those constraints will not apply and avoiding valid syntax makes the code worse.
Ask me which system, or have me run this once and paste the result:

```abap
" SE38 / ADT quick check
WRITE: / sy-saprl.                                  " kernel/release
SELECT SINGLE release, extrelease FROM cvers        " component versions
  INTO @DATA(ls_v) WHERE component = 'SAP_ABA'.
```
Then probe the two that matter most with a throwaway CDS: does `year( )` activate, and does
`cast( <int> as abap.numc(2) )` activate? Two minutes, and it tells you whether §4.1 is a
rulebook or a museum.

**Default assumption if unknown:** apply §4.1. Code that avoids `year()` works everywhere;
code that uses it fails on half my systems.

### 8.1 FS → object list (do this before writing a line)

Reading an FS, produce **this table first** and let me approve it. Do not start coding until I do.

| # | Object | Type | Purpose | Depends on |
|---|---|---|---|---|
| 1 | `ZMM_...` | Table / Data element | | |
| 2 | `ZMM_..._TOP` | Include | Declarations | 1 |
| 3 | ... | | | |

Rules for the decomposition:
- **Build order = dependency order.** DDIC first, then declarations, then logic, then screen,
  then service/tile. I paste and activate in that order.
- Map **every FS requirement to a numbered object** and keep a `requirement → object` table (see
  §5.3 for the shape). If an FS requirement maps to nothing, say so — that's a gap to raise, not
  a thing to invent.
- **Call out FS gaps and ambiguities explicitly as "open points to confirm before transport."**
  A real FS is always underspecified; I'd rather have a numbered list of questions than an
  invented answer.
- State assumptions inline (`" ASSUMPTION: ...`) so they're greppable later.

### 8.2 Standard header block for every new object

```abap
*&---------------------------------------------------------------------*
*& Report/Include : Z...
*& Title          : <one line>
*& Project        : <OVL / KPMG / GAIL>          Module: MM
*& Related FS     : <FSD number and file name>
*& Author         : Arnav Johri                  Date: DD.MM.YYYY
*& Transport      : <TR>
*&---------------------------------------------------------------------*
*& DESCRIPTION
*&   <what it does, in 3-5 lines>
*&
*& CHANGE HISTORY
*&   DD.MM.YYYY  Arnav Johri  <TR>  Initial development
*&---------------------------------------------------------------------*
```

### 8.3 Skeleton — classic report: selection screen + ALV

The single most common from-scratch object. Include split is always
`_TOP` (declarations) / `_SCR` (selection screen) / `_FORMS` (logic).

```abap
REPORT zmm_xxx_report.

INCLUDE zmm_xxx_report_top.
INCLUDE zmm_xxx_report_scr.
INCLUDE zmm_xxx_report_forms.

INITIALIZATION.
  PERFORM init_defaults.

AT SELECTION-SCREEN ON s_bukrs.
  PERFORM validate_selection.

START-OF-SELECTION.
  PERFORM fetch_data.
  IF gt_output IS INITIAL.
    MESSAGE 'No data found for the given selection' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.
  PERFORM build_output.

END-OF-SELECTION.
  PERFORM display_alv.
```

```abap
*--- _TOP -------------------------------------------------------------*
TABLES: ekko.

TYPES: BEGIN OF ty_output,
         ebeln TYPE ekko-ebeln,
         bukrs TYPE ekko-bukrs,
         lifnr TYPE ekko-lifnr,
         name1 TYPE lfa1-name1,
         netwr TYPE ekpo-netwr,
         waers TYPE ekko-waers,
       END OF ty_output.

DATA: gt_output TYPE STANDARD TABLE OF ty_output,
      go_alv    TYPE REF TO cl_salv_table.

*--- _SCR -------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_bukrs FOR ekko-bukrs OBLIGATORY,
                s_ebeln FOR ekko-ebeln,
                s_bedat FOR ekko-bedat.
SELECTION-SCREEN END OF BLOCK b1.
" Selection texts must be HUMAN READABLE - no technical names on screen.

*--- _FORMS -----------------------------------------------------------*
FORM fetch_data.
  SELECT k~ebeln, k~bukrs, k~lifnr, a~name1, p~netwr, k~waers
    FROM ekko AS k
    INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
    LEFT OUTER JOIN lfa1 AS a ON a~lifnr = k~lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_output
    WHERE k~bukrs IN @s_bukrs
      AND k~ebeln IN @s_ebeln
      AND k~bedat IN @s_bedat.
  " strict Open SQL: comma list, @ on the RHS only, INTO last
ENDFORM.

FORM display_alv.
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                              CHANGING  t_table      = gt_output ).

      go_alv->get_functions( )->set_all( abap_true ).
      go_alv->get_columns( )->set_optimize( abap_true ).

      DATA(lo_col) = CAST cl_salv_column_table( go_alv->get_columns( )->get_column( 'EBELN' ) ).
      lo_col->set_long_text( 'Purchasing Document' ).

      go_alv->display( ).
    CATCH cx_salv_msg INTO DATA(lx).
      MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.
```
> Use `CL_SALV_TABLE` for a plain display list. Use `CL_GUI_ALV_GRID` only when you need
> editable cells, cell styles, or custom toolbar events — and remember §6.12 if you touch
> `field_style` inside a loop.

### 8.4 Skeleton — file/Excel upload program with processing log

The shape proven on ZMM_VEND_UPLOAD. Every upload program I build follows it.

```abap
START-OF-SELECTION.
  PERFORM upload_file.        " ALSM_EXCEL_TO_INTERNAL_TABLE or cl_gui_frontend_services
  PERFORM convert_data.       " raw cells -> typed structure, ALPHA conversion, date conversion
  PERFORM validate_data.      " see 6.1 - log + DROP bad rows, never stop the batch
  PERFORM process_data.       " BAPI / API call per row, COMMIT/ROLLBACK per row
  IF gt_log IS NOT INITIAL.
    PERFORM download_error_log.   " see 6.3 - error-only subset
    PERFORM display_log.          " ALV: Row No | Key | Status | Message
  ENDIF.
```
Non-negotiables for this shape:
- **One bad row never stops the batch.** No `LEAVE LIST-PROCESSING` on a data error.
- Every row gets a **row number** carried from the file, a **status** (`S`/`W`/`E`), and a
  **message**, in the log structure.
- **`COMMIT WORK` / `ROLLBACK WORK` per row**, plus `BAPI_TRANSACTION_COMMIT` where the API needs
  it. Never one commit at the end.
- Separate statuses per sub-operation when the FS asks for it (e.g. company code vs purch org),
  and roll them up into an overall `msgty` = worst of them.
- Blank cell ⇒ **do not** overwrite existing data (§6.2).
- Provide a **downloadable error-only file**, and say "no error records to download" when clean.

### 8.5 Skeleton — CDS → RAP List Report, in build order

The sequence I paste and activate, one at a time. Apply §4.1 to every view.

```
1. ZI_<obj>          interface / basic view      (select from the tables, keys first)
2. ZP_<obj>_...      private helper views        (only if CASE-in-GROUP-BY etc. forces it)
3. ZC_<obj>          consumption / projection    (@Metadata.allowExtensions: true)
4. ZC_<obj>          metadata extension (DDLX)   (@UI.lineItem, headerInfo, chart - see 6.7)
5. ZSD_<obj>         service definition          (expose the consumption view + value helps)
6. ZSB_<obj>         service binding             (OData V4 - UI, or V2 if the tile needs it)
```

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tender Register - Consumption'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity zc_ovl_tender_reg
  as select from zi_ovl_tender_reg
{
  key submi          as Submi,          // keys first and contiguous
  key mjahr          as Mjahr,
      bsart          as Bsart,
      banfn          as Banfn,
      @Semantics.amount.currencyCode: 'Waers'   // OK in a projection over a real currency field
      tndrval        as TndrVal,
      waers          as Waers
}
```
Then the service definition:
```abap
@EndUserText.label: 'Tender Register Service'
define service zsd_ovl_tender_reg {
  expose zc_ovl_tender_reg as TenderRegister;
  expose I_Supplier         as Supplier;      // value help
}
```
> **Put every tile's CDS into ONE service definition + binding.** Don't create a separate OData
> service per tile — that was an explicit correction on the 5-tile delivery.
> If the report logic isn't SQL-expressible (RFC calls, nested lookups, computed rows), you need
> a **custom entity + query provider class** instead of steps 1–3 — see §6.8, and remember paging
> is mandatory.

### 8.6 Skeleton — SEGW OData V2 create entity (and the deep-entity variant)

```abap
METHOD dailyproductions_create_entity.
  DATA: ls_data TYPE zcl_..._mpc_ext=>ts_dailyproduction,
        ls_db   TYPE zpra_t_dly_prd.

  IF io_data_provider IS BOUND.
    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).
  ENDIF.
  IF ls_data IS INITIAL.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING textid = /iwbep/cx_mgw_busi_exception=>business_error_unlimited
                message = 'Empty payload'.
  ENDIF.

  MOVE-CORRESPONDING ls_data TO ls_db.
  GET TIME STAMP FIELD ls_db-created_at.

  MODIFY zpra_t_dly_prd FROM ls_db.
  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    er_entity = ls_data.
  ELSE.
    ROLLBACK WORK.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING textid = /iwbep/cx_mgw_busi_exception=>business_error_unlimited
                message = 'Insert failed'.
  ENDIF.
ENDMETHOD.
```
For a **deep entity** (one call carrying a header + N items, so CPI gets one response instead of
20), redefine `/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY`, define the deep structure in
the MPC_EXT `DEFINE` method, read the payload into it, loop the item table, and return a single
consolidated response. The alternative — keep the flat entity and have CPI send an OData
**`$batch` changeset** — needs no ABAP change at all and is worth proposing first.

### 8.7 TS document template (I ask for this on every object)

```markdown
# TS — <Object name> (<FS number>)
1. Document control        : version, author, date, related FS
2. Purpose / background    : 3-5 lines
3. Objects affected        : table — name | type | new or changed | package | TR
4. Detailed changes        : PER OBJECT, with the EXACT include name and line number,
                             "insert after line N" / "replace lines N-M", and the code block
5. Requirement mapping     : FS requirement -> object/unit that implements it
6. Test scenarios          : input, expected output, actual
7. Open points             : anything the FS did not specify
```
Deliver as **Markdown + a matching `.docx`**. Exact line numbers matter — that's what makes it
usable by another ABAPer.

### 8.8 Definition of done — check before you hand me the object

1. Complete code, first line to last. No `" ... rest unchanged ...`.
2. Every §4.1 constraint pre-applied (if the release is unknown, assume they all apply).
3. Old code commented, not deleted; `*BOC/*EOC By Arnav on DD/MM/YY` markers with the correct
   author id for the client.
4. Strict Open SQL; `IS NOT INITIAL` guard before every `FOR ALL ENTRIES`; no `SELECT` inside a
   `LOOP` where a `FOR ALL ENTRIES` or join would do.
5. No hardcoded clients, dates, or company codes unless the FS says to hardcode.
6. Error path: message to the user, no short dump, no silent skip.
7. Selection texts and column headings are readable words, not technical names.
8. FS requirements all mapped; unmapped ones listed as open points.
9. Object named, so I know what to create in ADT before pasting.

### 8.9 Where Copilot will be weaker than Claude, and how to compensate

- **It won't read your whole Downloads folder or run `gh`.** Paste the FS text, or open the file
  in the editor, or convert it: `pandoc -t markdown "FS.docx" -o FS.md` and keep `FS.md` in the
  workspace so `#file:FS.md` works.
- **Shorter effective context.** Give it §4.1 + §8 + the one FS, not the whole history. Trim §5.
- **It drifts toward truncating long output.** Counter it every time: *"Give the complete
  object. It must be at least N lines. Do not abbreviate."* Then check the line count.
- **It has no memory between sessions.** Re-attach this file each time; when you learn a new
  activation error and fix, append it to §4.1 yourself — that table is the asset.

---

## 9. Good opening prompts for Copilot in this context

**From-scratch development (the main case):**
- *"Read `COPILOT_CONTEXT_HANDOFF.md`, then `#file:FS.md`. Following §8.1, give me ONLY the object
  list table and the requirement-mapping table first. Do not write code yet."*
- *"Approved. Now build object 1 from that list, complete, following §8.2 and §8.8. Then stop."*
- *"activated, give the next"* ← my normal loop. It should give exactly one object and stop.

**Everything else:**
- *"Read `COPILOT_CONTEXT_HANDOFF.md`. I'm on the older S/4 release described in §4.1. Generate
  CDS view entity X, pre-applying every constraint in that section. Give the complete view."*
- *"Here is an activation error: `<paste>`. Fix it and return the complete corrected object —
  no omissions."*
- *"Correct this ATC finding using the rules in §4.2. Comment the old code, add `*BOC/*EOC By
  Arnav on <date>` markers, author id `SAP_ABAP`, one pseudo-comment per line. Full include back."*
- *"I need a TS document for these changes with the exact include names and line numbers, in the
  same table format as §5.3."*
- *"Draft a 4-line Teams message to the functional consultant asking them to test this."*

---

*Compiled 2026-08-15 from 30 Claude Code session transcripts (557 prompts, 2026-07-20 →
2026-08-15), 6 persistent memory files, and the `aj-02/KPMG` repository. Credentials, user IDs
and third-party email addresses have been intentionally excluded.*
