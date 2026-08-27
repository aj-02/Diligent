# TS — ZFI_TDS_CL34 (Clause 34 TDS Report)

Technical specification for the report built from `Clause 34 TDS Report FS.xlsx`.
Template: `COPILOT_CONTEXT_HANDOFF.md` §8.7. Build contract: `kpmg/zfi_tds_cl34/BUILD_BRIEF.md`.
DDIC evidence: `kpmg/zfi_tds_cl34/docs/DDIC_FACTS.md`. Open points: `kpmg/zfi_tds_cl34/docs/QUERIES.md`.

---

## 1. Document control

| Item | Value |
|---|---|
| Object | `ZFI_TDS_CL34` |
| Title | TDS Report — Clause 34 compliance |
| Client / project | KPMG — UDAY / Astral |
| Module | FI (withholding tax, India) |
| Object type | Executable report (ALV list) |
| Author | Arnav Johri, Associate Consultant |
| Date | 26.08.2026 |
| Version | 1.0 |
| Related FS | Clause 34 TDS Report FS.xlsx, v1, 21.08.2026 |
| FS owners | Ankita Parikh (functional, FI/TDS) · Bhavin Suthar (MM / account determination) |
| Transport | `<TR>` — to be filled on creation |
| Shipping | **PASTE-ONLY** — no `.abapgit.xml`, no `src/` serialisation. See `NOTES.md`. |

---

## 2. Purpose / background

Clause 34 of the tax audit report requires TDS deduction to be evidenced document by
document. FS objective [A14]: *"GL wise and document number wise TDS deduction details
will be provided."*

The report lists every FI document in which withholding tax was deducted from a vendor,
one row per withholding-tax item, with the GL that carried the expense, the vendor's PAN,
the section and rate applied, the clearing (payment) document, and the vendor's exemption
certificate and accumulated base amount. It is a read-only list — nothing is posted,
changed or written.

Applicability [A15] is company codes 1000 and 4000. These are stated as applicability, not
as a filter, so neither is hardcoded anywhere; the company code is an obligatory selection
field.

---

## 3. Objects affected

| Name | Type | New / changed | Package | TR |
|---|---|---|---|---|
| `ZFI_TDS_CL34` | Executable program (type 1) | New | `<pkg>` | `<TR>` |
| `ZFI_TDS_CL34_TOP` | Include (type I) | New | `<pkg>` | `<TR>` |
| `ZFI_TDS_CL34_SCR` | Include (type I) | New | `<pkg>` | `<TR>` |
| `ZFI_TDS_CL34_FORMS` | Include (type I) | New | `<pkg>` | `<TR>` |

No standard SAP object is modified. No DDIC object, message class, number range,
screen, GUI status or transaction code is created — the FS asks for a report and
nothing else. A transaction code is not part of this build; the report runs from SE38
unless one is requested separately.

### 3.1 Manual steps that do not travel with the source

The object ships by paste, so the following are maintained by hand after creation. The
same list is carried verbatim in the trailer comment of `ZFI_TDS_CL34_SCR`.

1. Create the three includes as type **INCLUDE (I)**, not as executable programs.
   `ZFI_TDS_CL34_TOP` must not carry a `REPORT` / `PROGRAM` statement of its own.
2. `Goto → Attributes`:
   - Title: `TDS Report - Clause 34 compliance`
   - **Fixed point arithmetic: MUST be ticked.** Every `SELECT` in this program uses
     strict ABAP SQL (comma-separated field lists, `@`-escaped host variables), which the
     compiler accepts only when this attribute is on. With it off, the first strict SELECT
     fails with *"This ABAP SQL statement uses additions that can only be used when the
     fixed point arithmetic flag is activated"* and the follow-on errors point at the
     inline-declared target (`Field "LT_CC" is unknown`) rather than at the attribute.
3. `Goto → Text elements → Selection texts`: `S_BUKRS` Company Code · `S_SECCO` Section
   Code · `S_LIFNR` Vendor Code · `P_GJAHR` Fiscal Year · `S_BUDAT` Posting Date.
   Do **not** tick "Dictionary reference" — the DDIC labels for `WT_ACCO` and `SECCO` are
   not the words the FS asks for.
4. `Goto → Text elements → Text symbols`: `b01` = `Selection`.

---

## 4. Detailed design

### 4.1 Include split and flow

| Include | Contents |
|---|---|
| `ZFI_TDS_CL34` | Header block, `INCLUDE` statements, `INITIALIZATION`, `AT SELECTION-SCREEN`, `START-OF-SELECTION`, `END-OF-SELECTION`. No logic. |
| `ZFI_TDS_CL34_TOP` | `TABLES`, all `TYPES`, all `CONSTANTS`, all global `DATA`. No executable statement. |
| `ZFI_TDS_CL34_SCR` | The five selection-screen fields inside block `B1`, plus the manual-steps trailer comment. |
| `ZFI_TDS_CL34_FORMS` | Every form routine. |

Run shape:

```
INITIALIZATION       → INIT_DEFAULTS          propose the period, nothing else
AT SELECTION-SCREEN  → VALIDATE_SELECTION     the only TYPE 'E' in the program
START-OF-SELECTION   → FETCH_WT_ITEMS         the ONE read of the driver set
                     → BUILD_OUTPUT           master data, config, exemptions, GL, 25 columns
                       (empty result → REPORT_GL_GAPS or the generic message, then RETURN)
END-OF-SELECTION     → REPORT_GL_GAPS         one aggregated diagnostic message
                     → DISPLAY_ALV            CL_SALV_TABLE
```

`REPORT_GL_GAPS` runs **before** `DISPLAY_ALV` because `display( )` does not return until
the user leaves the list; a message issued after it would land on the calling screen.

### 4.2 Form routines

| Form | Does |
|---|---|
| `INIT_DEFAULTS` | Proposes fiscal year and posting-date period from `SY-DATUM`. Both guarded by `IS INITIAL`. |
| `VALIDATE_SELECTION` | Company codes exist in T001; fiscal year not more than one year ahead; no posting-date range ending before it starts. |
| `FETCH_WT_ITEMS` | The **only** form that reads withholding-tax data (D1). Driver `WITH_ITEM ⋈ BKPF`, then BSEG of those documents, then the section-code filter in ABAP, then the BKPF headers. |
| `BUILD_DOCKEY` | Distinct BUKRS/BELNR/GJAHR of the current driver set. Called twice. |
| `READ_VENDOR_LINE` | The vendor line of one document — cols J/N/O and the section-code filter, from the one place. |
| `BUILD_OUTPUT` | Orchestrates the lookups and fills the 25 columns. Issues no message. |
| `FETCH_COMPANY_DATA` | T001 — country, currency, chart of accounts. |
| `FETCH_VENDOR_DATA` | LFA1 — name and PAN. |
| `FETCH_TAX_CONFIG` | T059Z on the full key, then T059OT for the section text. |
| `DERIVE_GL_CODES` | Per document: RMRP branch or direct-FI branch. Logs failures, never messages. |
| `FETCH_MM_DATA` | Set-based reads for the RMRP branch: RSEG → EKKN → MBEW → T030. |
| `DERIVE_GL_DIRECT` | Offsetting GL of the `KTOSL = 'WIT'` line. |
| `DERIVE_GL_RMRP` | Reference key → RSEG item → EKKN account, else MBEW valuation class → T030 BSX. |
| `READ_EKKN_GL` / `READ_BKLAS` | Helpers of the RMRP branch. |
| `FETCH_GL_TEXTS` | SKAT in the logon language, for the derived GLs only. |
| `FETCH_EXEMPTIONS` | FIWTIN_TAN_EXEM and FIWTIN_ACC_EXEM on the six restricting key fields. |
| `READ_EXEMPTION` / `READ_CUMULATIVE` | Pick one certificate row / one accumulation row per output row. |
| `BUDAT_UPPER` | Upper bound of the posting-date selection, the "as of" date of col Y. |
| `REPORT_GL_GAPS` | ONE aggregated status message for GL gaps, GL ambiguity and skipped items. |
| `DISPLAY_ALV` / `TXT` | `CL_SALV_TABLE` list, headings from the FS wording. |

### 4.3 Performance shape

Every database read is set-based. No `SELECT` sits inside a `LOOP`. Each buffer is filled
once with `FOR ALL ENTRIES` over a de-duplicated key table (guarded by `IS NOT INITIAL`)
and is then read with `BINARY SEARCH` over a table sorted on exactly the key of the read,
so the row loop stays O(n log n) on a list that can return tens of thousands of rows.

---

## 5. Selection screen (FS "Input Screen" tab)

Block `B1`, text symbol `b01` = "Selection".

| Field | Kind | Declared over | Obligatory | Selection text |
|---|---|---|---|---|
| `S_BUKRS` | SELECT-OPTIONS | `BKPF-BUKRS` | **yes** | Company Code |
| `S_SECCO` | SELECT-OPTIONS | `BSEG-SECCO` | no | Section Code |
| `S_LIFNR` | SELECT-OPTIONS | `WITH_ITEM-WT_ACCO` | no | Vendor Code |
| `P_GJAHR` | PARAMETERS | `BKPF-GJAHR` | **yes** | Fiscal Year |
| `S_BUDAT` | SELECT-OPTIONS | `BKPF-BUDAT` | **yes** | Posting Date |

Company code, fiscal year and posting date are the FS's "mandatory filter" and are
therefore `OBLIGATORY` (D3). Each `SELECT-OPTIONS` is declared over the field it actually
filters, so the length and the dictionary value help are the correct ones — section code
exists on the line item only (neither BKPF nor WITH_ITEM has it), and the account of a
withholding item is `WT_ACCO`, not `LIFNR`.

Section code is applied in ABAP rather than in the `WHERE` clause: it lives on BSEG, and
the same BSEG read serves the vendor line and the GL derivation, so pushing it into the
database would cost a second read of the same rows.

---

## 6. Output — 25 columns (FS "Output Screen" tab)

Source mapping per `docs/DDIC_FACTS.md` §2. Structure `TY_OUTPUT` in `ZFI_TDS_CL34_TOP`;
every component is typed against a real dictionary field, never against a literal
`CHAR(n)` / `DEC(n,m)`.

| # | Heading (as shipped) | Component | Source field |
|---|---|---|---|
| A | Sr | `SR` | computed `TYPE i`, continuous across the list |
| B | Document number | `BELNR` | `WITH_ITEM-BELNR` |
| C | Vendor Code | `LIFNR` | `WITH_ITEM-WT_ACCO` (with `KOART = 'K'`) |
| D | Vendor Name | `NAME1` | `LFA1-NAME1` |
| E | Vendor PAN | `PAN_NO` | `LFA1-J_1IPANNO` (CHAR **40**) |
| F | GL Code | `GL_CODE` | derived — §7 |
| G | GL Name | `GL_NAME` | `SKAT-TXT50` (`SPRAS = SY-LANGU`, `KTOPL` from `T001`) |
| H | Section | `SECTION` | `T059Z-QSCOD` |
| I | Section Code Description | `SEC_DESC` | `T059OT-TEXT40` (key `SPRAS`/`LAND1`/`WT_QSCOD`) |
| J | Nature of Payment | `NATURE` | `BSEG-SGTXT` of the vendor line |
| K | Document Date (SAP) | `BUDAT` | `BKPF-BUDAT` |
| L | Invoice No. | `XBLNR` | `BKPF-XBLNR` |
| M | Invoice Date | `BLDAT` | `BKPF-BLDAT` |
| N | Payment Doc No. | `AUGBL` | `BSEG-AUGBL` of the vendor line |
| O | Payment Date | `AUGDT` | `BSEG-AUGDT` of the vendor line |
| P | Base Amount | `BASE_AMT` | `WITH_ITEM-WT_QSSHH` (company-code currency) |
| Q | Tax Code | `TAXCODE` | `WITH_ITEM-WT_WITHCD` |
| R | TDS Rate as per section | `RATE_SEC` | `T059Z-QSATZ` |
| S | TDS Rate deducted | `RATE_DED` | `WITH_ITEM-QSATZ` |
| T | TDS Amount | `TDS_AMT` | `WITH_ITEM-WT_QBSHH` (company-code currency) |
| U | Valid From | `EXDF` | `FIWTIN_TAN_EXEM-WT_EXDF` |
| V | Valid To | `EXDT` | `FIWTIN_TAN_EXEM-WT_EXDT` |
| W | Threshold Applicability (Y/N) | `THRESHOLD` | `FIWTIN_TAN_EXEM-FIWTIN_EXEM_THR` (an **amount**) |
| X | Certificate Number | `CERT_NO` | `FIWTIN_TAN_EXEM-WT_EXNR` |
| Y | Cumulative Amount as of now for FY | `CUM_AMT` | `FIWTIN_ACC_EXEM-ACC_AMT` |
| — | *(hidden, technical)* | `WAERS` | `T001-WAERS` — currency of P/T/W/Y |

Heading wording is the FS's own, byte for byte, with one exception: FS [X7] spells
"Ceritificate"; the report ships "Certificate Number". Registered as QUERIES Q13.
Column W keeps the FS heading "(Y/N)" although the FS description [W6] asks for the
amount — the contradiction is the FS's own and stays visible (QUERIES Q4).

`WAERS` is carried in the row and set technical. It is **not** wired to the four amount
columns: `CL_SALV_COLUMN_LIST=>SET_CURRENCY_COLUMN` is UNVERIFIED on this release
(QUERIES Q8).

---

## 7. GL derivation (FS "GLCode Logic" tab)

One GL per FI document. The result is held in `GT_GLMAP`; documents that cannot be
resolved go to `GT_GLMSG` and keep their output row with F and G blank.

```
                    BKPF-AWTYP = 'RMRP'  and AWKEY filled ?
                    ├── no ─────────────► DIRECT FI POSTING
                    │                     BSEG line of the document with KTOSL = 'WIT'
                    │                     → GL = BSEG-GHKON  (lowest BUZEI that carries one)
                    │                     no WIT line / no GHKON → logged, F+G blank
                    │
                    └── yes ────────────► LOGISTICS INVOICE
                          AWKEY+0(10) → RSEG-BELNR, AWKEY+10(4) → RSEG-GJAHR
                          (non-numeric year → fall back to BKPF-GJAHR)
                          lowest RSEG item whose BUKRS = the document's company code
                          │
                          ├── EKKN row exists with SAKTO filled ?
                          │     yes → GL = EKKN-SAKTO
                          │           (RSEG-ZEKKN preferred; else lowest ZEKKN with an account)
                          │
                          └── no  → stock posting
                                    MBEW on MATNR + RSEG-BWKEY (+ BWTAR, retry blank)
                                    → BKLAS
                                    T030 on KTOPL + KTOSL = 'BSX' + BKLAS
                                    → GL = T030-KONTS
```

Three points where this departs from the FS text, all on DDIC evidence:

- The FS calls RMRP a value of `AWKEY`. It is a value of **`BKPF-AWTYP`**; `AWKEY` is the
  20-character reference key the invoice number and year are cut from. The test is on
  `AWTYP`.
- `MBEW` is read on **`RSEG-BWKEY`** (valuation area), not on `RSEG-WERKS` as the FS
  [H27] says. `WERKS` is correct only under plant-level valuation; `BWKEY` is correct
  under both.
- `KTOPL` is read from **`T001`** per company code, not hardcoded to `'ASTL'` as FS [G2]
  says.

`T030` is read on `KTOPL` + `KTOSL` + `BKLAS` only — **not** on `BWMOD` / `KOMOK`, because
`T001K-BWMOD` could not be verified on this landscape and compiling against an unverified
field is worse than resolving the ambiguity in ABAP. The buffer is sorted so the blank
valuation grouping code and blank account modifier come first; where no such general entry
exists the first of the sort is taken and, if a second entry of the same valuation class
carries a **different** account, the document is logged in `GT_GLAMB` and counted in the
run's status message. QUERIES Q3 for Bhavin Suthar.

No heuristic GL guess is made anywhere. A document whose GL cannot be derived keeps its
row with F and G blank and is counted — never a short dump, never a silent skip.

---

## 8. Requirement mapping

| FS requirement | Implemented by |
|---|---|
| [A14] GL wise and document number wise TDS details | `BUILD_OUTPUT`, one row per WITH_ITEM key + `DERIVE_GL_CODES` |
| [A15] Company codes 1000 / 4000 | `S_BUKRS` obligatory; neither code hardcoded |
| Input Screen [C4]–[G12] — five fields | `ZFI_TDS_CL34_SCR` |
| Mandatory filter: company code, fiscal year, posting date | `OBLIGATORY` on `S_BUKRS`, `P_GJAHR`, `S_BUDAT`; applied in the driver `WHERE` |
| Output Screen [B2]–[Y2] — 25 columns | `TY_OUTPUT` + `BUILD_OUTPUT`; mapping table §6 |
| Output Screen [A7]–[Y7] — headings | `DISPLAY_ALV` / `TXT`, FS wording (one corrected spelling, Q13) |
| GLCode Logic [D2]–[H32] | `DERIVE_GL_CODES`, `DERIVE_GL_DIRECT`, `DERIVE_GL_RMRP`, `FETCH_MM_DATA` §7 |
| [A21] Output type: list of documents | `CL_SALV_TABLE` ALV list, all standard functions on |

Not built, because the FS did not ask for it: transaction code, variant, spool/background
handling, download-to-file, ALV layout variants beyond the standard `set_all( )` toolbar.

**Authorisation IS built**, though the FS did not ask for it. The report shows TDS base
amounts, tax amounts, vendor names and vendor PANs, so it should not be readable for a
company code the user has no rights to. `I_WithholdingTaxItem` carries its own DCLS, but
that only covers the driver select — the `BKPF`, `BSEG`, `LFA1` and exemption reads are
plain table selects with no check of their own, and the whole design has to survive being
switched to base tables (§10.1). `CHECK_AUTHORISATION` checks
`F_BKPF_BUK` (`BUKRS`, `ACTVT` = `03`) against every company code the selection resolves to.
It is called **twice**: from `VALIDATE_SELECTION` for the dialog case, where `TYPE 'E'` keeps
the user on the field, and again at `START-OF-SELECTION`, because `AT SELECTION-SCREEN` does
not run in a background job started from a variant and a fiscal-year compliance extract is
exactly the kind of report that gets scheduled. The object name is an assumption — see Q16.

---

## 9. Test scenarios

| # | Input | Expected | Actual |
|---|---|---|---|
| 1 | Company code 1000, current FY, full-year posting range | One row per withholding item; Sr continuous from 1 | |
| 2 | Direct FI vendor invoice with TDS (FB60) | F/G filled from the `KTOSL='WIT'` line's `GHKON`; K/L/M from BKPF | |
| 3 | MIRO invoice with account assignment on the PO | F = `EKKN-SAKTO` of the PO item | |
| 4 | MIRO invoice for stock material (no account assignment) | F = `T030-KONTS` for the material's `BKLAS`, `KTOSL = 'BSX'` | |
| 5 | Document cleared by a payment | N = clearing document, O = clearing date | |
| 6 | Open (uncleared) item | N and O blank; row still present | |
| 7 | Vendor with a valid exemption certificate on the posting date | U/V/W/X filled from the certificate valid on `BUDAT` | |
| 8 | Vendor with no certificate | U/V/W/X blank together; the row survives | |
| 9 | Vendor with no PAN in LFA1 | E blank and U–Y blank together; row survives (QUERIES Q10) | |
| 10 | Section Code entered on the selection screen | Only documents whose vendor line carries that `SECCO`; items with no vendor line counted in the status message, not dropped silently | |
| 11 | Selection that matches nothing | "No TDS documents found for the given selection" | |
| 12 | Selection where every item is discarded for want of a vendor line | The diagnostic count is shown, **not** the generic "no documents found" | |
| 13 | Document whose GL cannot be derived | Row present, F and G blank, counted in the aggregated status message | |
| 14 | Posting-date To earlier than From | Error on the selection screen, cursor back in the field | |
| 15 | Company code that does not exist in T001 | Error on the selection screen naming the company code | |
| 16 | Fiscal year more than one year ahead | Error on the selection screen | |
| 17 | Same selection run twice over unchanged data | Byte-identical list — the exemption and accumulation picks are total-ordered | |

---

## 10. Open points

The full register is `docs/QUERIES.md` (Q1–Q20). **Q12 comes before all of them** — if the
two CDS views the FS names are absent or their element names differ, the program does not
activate at all. After that, ranked by what changes a number on a compliance report:

1. **Q1 — column Y accumulation rule.** `FIWTIN_ACC_EXEM` is keyed by `SECCO`, so a vendor
   accumulates once per section code. The build shows the latest `WT_DATE` row not after
   the upper posting-date bound, never a sum. Ankita Parikh.
2. **Q2 — columns U–X certificate pick.** `FIWTIN_TAN_EXEM` is keyed by `SECCODE` and
   `FIWTIN_TANEX_SUB`, neither of which the FS restricts on. Ankita Parikh.
3. **Q3 — T030 valuation grouping code.** Is one active (OMWM) for 1000 / 4000? If yes,
   `T001K-BWMOD` must be verified in SE11 and pushed into the T030 key. Bhavin Suthar.
4. **Q11 — is `BSEG-GHKON` populated** on the WIT line for direct FI postings on Astral?
   If not, F and G are blank for every direct posting; the fallback order is `BSEG-GKONT`,
   then `WITH_ITEM-HKONT_OPP`. One-field switch.
5. **Q10 — is `LFA1-J_1IPANNO` populated?** A blank PAN blanks E *and* U–Y together.
6. **Q6 — reversed and parked documents** are currently reported, not excluded. Client
   decision.

### 10.1 The report is built to the FS as written

Every FS instruction is implemented as the FS states it, with **one** exception, set out in
§10.2. That is a deliberate position, not an oversight.

An earlier draft of this object departed from the FS in five places on the strength of a
DDIC read taken from a development system that is **not** the Astral landscape. Those
departures have been withdrawn. A field list read from the wrong system is not evidence
about this one, and the FS is the signed document. Where the FS may be wrong, the target
system will say so at activation — that is a faster and more reliable answer than an
inference from a different box, and each one is a small, isolated change:

| FS cell | As written, as built | If it fails | Query |
|---|---|---|---|
| [B2] | `I_WithholdingTaxItem` ⋈ `I_JournalEntry` | equivalent `WITH_ITEM` + `BKPF` select is written out verbatim in the `FETCH_WT_ITEMS` comment | Q12 |
| [I2] | `T059Z-TXT40` | move col I to `T059OT-TEXT40` (closer) or `T059ZT-TEXT40` | Q9 |
| [K2] [M2] | `BSEG-H_BUDAT` / `H_BLDAT` | `BKPF-BUDAT` / `BLDAT`, already buffered — one line | Q17 |
| [G2] | `KTOPL` hardcoded `'ASTL'` | read from `T001`; the value is the named constant `GC_KTOPL_GL` | Q18 |
| [H27] | `MBEW-BWKEY` = `RSEG-WERKS` | pass `RSEG-BWKEY` instead | Q19 |

The riskiest of these by far is **[B2]**: a wrong CDS element name stops activation
outright, so it is the first thing to try. The whole withholding read is isolated in **one
form, `FETCH_WT_ITEMS`** — everything downstream works off `GT_WITEM` / `GT_BKPF` /
`GT_BSEG` and never touches a view, so swapping the data source is a single-form change.

### 10.2 The one departure — the RMRP branch test

The GLCode Logic tab says *"For records having AWKEY as RMRP"*. The report tests
**`BKPF-AWTYP`**.

The FS is its own evidence here. Two rows below that instruction it says *"Get AWKEY and
provide first 10 digits of AWKEY in BELNR of RSEG and Fiscal year in GJAHR"*. A field
cannot both equal `RMRP` and hold a ten-digit invoice number followed by a four-digit
year. `RMRP` is the reference *transaction*, which is `AWTYP`; `AWKEY` is the reference
*key* the same tab then cuts the invoice number out of.

This one was not left literal because, unlike the five above, **it fails silently**.
`AWKEY = 'RMRP'` matches no document at all: every purchase-order invoice would fall
through to the direct-FI branch, column F would be wrong for most of the report, and
nothing would error. Registered as QUERIES Q14 for Bhavin Suthar.

---

*Prepared by Arnav Johri, 26.08.2026. Verify against a fresh SE38 download before any
further change — the repo copy is a snapshot, not necessarily the running version.*
