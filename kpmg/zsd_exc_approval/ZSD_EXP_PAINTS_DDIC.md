# ZSD_EXP_PAINTS_DDIC.md — SE11 build sheet, objects 1 / 2 / 3

WRICEF 141.B "Exceptional approval format — Paints" · Astral Limited · project UDAY · module SD
Contract: `BUILD_SPEC_141B.md` §2, §3, §4 (the spec wins over the FS)
Author: Arnav Johri, Diligent · 02.09.2026 · Transport: `<TR to be filled by Arnav>`
Package: the Z package for the UDAY SD track (same package for all objects on this sheet)

**This sheet is not code.** Nothing here can be pasted into SE38 and nothing here comes out of
an abapGit ZIP. Every object below is typed by hand into SE11, in the order printed.

---

## 0. Read before you start SE11

### 0.1 Creation order is not optional

DDIC objects only activate when everything they point at is already active. Work top to
bottom and activate at each step:

| Step | Object | Cannot be created before |
|---|---|---|
| 1 | 5 domains (§1) | — |
| 2 | 6 data elements (§2) | their domains are **active** |
| 3 | Table `ZSD_EXP_PAINTS` (§3) | all 6 data elements are **active** |
| 4 | Technical settings (§3.6) | the table exists (SE11 asks for them at first activation) |
| 5 | Table maintenance generator (§4) | the table is **active** |

Then, and only then, the two programs (`ZSD_EXP_PAINTS_UPLOAD`, `ZSD_EXC_APPR_PAINTS`)
have something to compile against.

### 0.2 THE FIRST-ACTIVATION FAILURE — read this twice

> **The three CURR fields (`ZEXC_AMOUNT`, `ZEX_AMNT`, `ZCM_AMNT`) CANNOT ACTIVATE AT ALL
> until `WAERS` exists in the table AND is assigned to each of them as their reference
> field on the "Currency/Quantity Fields" tab.**
>
> A CURR field in a transparent table is meaningless to the database without a currency key
> to say what the number is denominated in, so SE11 refuses activation outright — it is an
> **error**, not a warning, and it fires **three times**, once per amount field, naming the
> field and a missing reference field.
>
> The assignment does **not** live on the Fields tab. It lives on a **separate tab**
> ("Currency/Quantity Fields"), which is why this is the single most common way this table
> fails its first activation: the field list looks complete, so nobody looks at the other tab.

Correct sequence when you build the table:

1. Type **all 17 fields including `WAERS`** on the Fields tab (§3.3).
2. Switch to the **Currency/Quantity Fields** tab and fill the three rows in §3.5.
3. Fill the technical settings when prompted (§3.6).
4. *Then* activate.

`WAERS` sits at position 13, after the three amount fields. That is fine — the reference
field has to exist in the table, it does not have to sit above the fields that reference it.

### 0.3 Rows on this sheet that are NOT in the FS

Functional will ask. These five rows are additions, and each is defensible on its own terms.
Nothing else on this sheet is an addition.

| Row | Field | Status | Why it is here | If functional says drop it |
|---|---|---|---|---|
| 13 | `WAERS` | **Mandatory — not droppable as things stand** | A CURR field cannot be activated without a currency reference (§0.2). The FS defines three amount fields and no currency key, so the table as specified does not activate. | The only way to drop `WAERS` is to stop the three amounts being currency amounts — i.e. re-type them as `DEC 23,2`. That loses currency-aware display and currency conversion in the report and is **not** recommended. Open issue 9. |
| 14 | `ERNAM` | Recommended, droppable | Created-by. | Drop all four (14–17) only if "Log data changes" is switched on **and** `rec/client` covers this client — see §3.6. Open issue 9. |
| 15 | `ERDAT` | Recommended, droppable | Created-on. | as above |
| 16 | `AENAM` | Recommended, droppable | Changed-by. | as above |
| 17 | `AEDAT` | Recommended, droppable | Changed-on. | as above |

Why 14–17 are recommended: this table is maintained from two directions — by hand in SM30
through the generated TMG, and in bulk by `ZSD_EXP_PAINTS_UPLOAD` — and the FS gives it no
audit trail at all. When a credit exception is later disputed, "who put this row in and when"
is the first question asked. The four fields cost 40 bytes a row and are set by the upload
program without any extra user effort (build spec §5.4).

The alternative — table logging instead of the four fields — is compared in §3.6. Recommendation
there: **do both**, and the reason is given.

### 0.4 Names on this sheet that are taken on trust

Per the live lesson from the sibling object (`ZSD_EXC_APPR_ADHESIVE` failed its first
activation on `INFOCATEGORY`, a field name the FS asserted and nobody verified): a field name
out of a functional spec is not knowledge.

Almost nothing on this sheet is exposed to that risk, because objects 1–3 are all **new Z
objects** — their names are correct by construction, since we are the ones creating them. The
exposure is limited to the standard names being reused and to two FS-supplied numbers:

| Item | What is trusted | Check |
|---|---|---|
| Data element `DATUM` (rows 6, 7, 9) | That a standard **data element** named `DATUM` exists, generic date, domain `DATUM`, DATS 8. `DATUM` is certainly a domain; that it is also a data element is the part being trusted. | SE11 → Data type → `DATUM` → the radio button must land on **Data element**. If it only exists as a domain, use `SYDATUM` instead, or create `ZSD_DE_EXC_DATE` on domain `DATUM`. Three rows change, nothing else. |
| `MANDT`, `KUNNR`, `WAERS`, `ERNAM`, `ERDAT`, `AENAM`, `AEDAT` | Standard data elements, lengths as printed in §3.3. | High confidence — all long-standing SAP standard. Confirm the length column matches after you press Enter; SE11 fills it from the data element. |
| `T000`, `KNA1`, `TCURC` | Standard check tables. | High confidence. |
| CURR **length 23** (§1.4) | An FS figure, not a technical requirement. Unusually wide — see the flag in §1.4. | Ask functional; build 23 meanwhile. |
| `ZEX_AMNT` existing at all (row 10) | The FS declares it, but **no output column reads it** (build spec C4, open issue 8). | Ask functional whether it is a real second figure or a copy-paste duplicate of `ZEXC_AMOUNT`. Build it meanwhile — dropping a field later is cheap, discovering it was needed is not. |

The genuinely unverified DDIC names for 141.B (`ACDOCA-HSL / RLDNR / BLART / KUNNR`,
`UKMBP_CMS_SGM-CREDIT_SGMNT`) are **not** on this sheet. They belong to the two programs and
are listed in `VERIFY_IN_SE11_141B.md`.

---

## 1. Object 1a — Domains (5)

SE11 → **Data type** → type the name → radio button **Domain** → Create.

For every domain below: **Short Description** as printed, then the **Definition** tab, then the
**Value Range** tab. Leave "Convers. routine" empty on all five — no conversion routine is
wanted anywhere in this table, the MM-YYYY display for the month is done in ABAP
(build spec §3), not by a DDIC conversion exit.

Save to the UDAY SD Z package and the TR, then **activate before moving on**.

### 1.1 ZSD_DO_EXC_SRNO

| SE11 field | Value |
|---|---|
| Domain | `ZSD_DO_EXC_SRNO` |
| Short Description | Exceptional Approval Serial Number |
| **Definition tab** | |
| Data Type | `NUMC` |
| No. Characters | `10` |
| Decimal Places | `0` (leave blank; NUMC has none) |
| Output Length | `10` |
| Convers. Routine | *(empty)* |
| Sign | **not** ticked |
| Lower Case | **not** ticked (irrelevant for NUMC) |
| **Value Range tab** | |
| Fixed values | *(none)* |
| Intervals | *(none)* |
| Value Table | *(none)* |

Note: NUMC 10 pads with leading zeros. The upload program strips/re-pads on the way in
(build spec §5.3 rule 1). There is **no number range object** behind this — the serial number
is supplied by the user in the file or typed in SM30 (open issue 9, deviation 14). If
functional later wants SNRO, that is an added object, not a change here.

### 1.2 ZSD_DO_EXC_MONTH

| SE11 field | Value |
|---|---|
| Domain | `ZSD_DO_EXC_MONTH` |
| Short Description | Exceptional Approval Month (YYYYMM) |
| **Definition tab** | |
| Data Type | `NUMC` |
| No. Characters | `6` |
| Decimal Places | `0` (leave blank) |
| Output Length | `6` |
| Convers. Routine | *(empty)* — see note |
| Sign | not ticked |
| Lower Case | not ticked |
| **Value Range tab** | |
| Fixed values / Intervals / Value Table | *(none)* |

**Stored as `YYYYMM`, displayed as `MM-YYYY`.** That is Parth Shah's document comment and it
is settled in the build spec: storing `MM-YYYY` as text would sort and compare wrongly
(`01-2027` sorts before `12-2026`). The display flip happens in ABAP — `month(4)` is the year,
`month+4(2)` is the month. Do **not** attach a conversion routine here to try to do it in DDIC;
that would break the upload program's own parsing and the report's offset access.

No fixed values: a range check (month 01–12) cannot be expressed as a domain fixed value on a
6-character field. The upload program validates it instead (build spec §5.3 rule 3).

### 1.3 ZSD_DO_EXC_TYPE

| SE11 field | Value |
|---|---|
| Domain | `ZSD_DO_EXC_TYPE` |
| Short Description | Exceptional Approval Type |
| **Definition tab** | |
| Data Type | `CHAR` |
| No. Characters | `1` |
| Decimal Places | *(blank)* |
| Output Length | `1` |
| Convers. Routine | *(empty)* |
| Sign | not ticked |
| Lower Case | **not** ticked (values are digits; upper-case storage keeps SM30 and the upload consistent) |
| **Value Range tab — Single Vals** | |

| Fix. Val. | Short Description |
|---|---|
| `1` | Credit Limit |
| `2` | Overdue |
| `3` | Credit Limit & Overdue |

| | |
|---|---|
| Intervals | *(none)* |
| Value Table | *(none)* — the fixed values are the check |

Two consequences of the fixed values, both wanted:

- SM30 (the TMG of §4) gets an automatic F4 dropdown and rejects anything but 1/2/3.
- The upload program's rule 4 (`ZEXC_APPR_TYPE in 1/2/3`) is then belt-and-braces, which is
  correct — the file bypasses no check.

**Keep these three descriptions in step with the report.** `ZSD_EXC_APPR_PAINTS` renders the
type as readable text from a `CASE` on 1/2/3 through text symbols and deliberately does **not**
read `DD07T` (build spec §6.3 item 10). If functional renames a type here, the report's text
symbols must be changed to match — SE11 will not tell you.

### 1.4 ZSD_DO_EXC_AMOUNT

| SE11 field | Value |
|---|---|
| Domain | `ZSD_DO_EXC_AMOUNT` |
| Short Description | Exceptional Approval Amount |
| **Definition tab** | |
| Data Type | `CURR` |
| No. Characters | `23` |
| Decimal Places | `2` |
| Output Length | *(leave what SE11 proposes — press Enter after typing length and decimals and do **not** overtype it; it is derived from length + decimals + separators + sign)* |
| Convers. Routine | *(empty)* |
| Sign | **ticked** — amounts must be able to hold a negative |
| Lower Case | not ticked |
| **Value Range tab** | |
| Fixed values / Intervals / Value Table | *(none)* |

**FLAG — length 23 is the FS figure and it is unusually wide.** A standard SAP amount is 13,2
(`WRBTR`, `DMBTR`) or 15,2; 23 digits is a value larger than any real Astral receivable. It is
technically legal (CURR allows up to 31 digits) and it will activate, so build it as specified,
but raise it with functional because there are two live consequences:

- Moving a `ZSD_DO_EXC_AMOUNT` value into a standard 13-digit amount field can overflow and
  **short-dump at runtime**, not at activation. Nothing in the current build does that, but any
  later interface or BAPI call would.
- The ALV column is very wide, which is what the user will complain about first.

Recommendation if functional has no view: `15,2`. Do not change it unilaterally — it is an FS
number and it costs an SE11 change plus a table conversion once data exists.

Both `ZSD_DE_EXC_AMOUNT` and `ZSD_DE_CM_AMOUNT` sit on this one domain, so a later length
change is one edit here, not two.

### 1.5 ZSD_DO_EXC_REMARKS

| SE11 field | Value |
|---|---|
| Domain | `ZSD_DO_EXC_REMARKS` |
| Short Description | Exceptional Approval Remarks |
| **Definition tab** | |
| Data Type | `CHAR` |
| No. Characters | `250` |
| Decimal Places | *(blank)* |
| Output Length | `250` |
| Convers. Routine | *(empty)* |
| Sign | not ticked |
| Lower Case | **ticked** |
| **Value Range tab** | |
| Fixed values / Intervals / Value Table | *(none)* |

"Lower Case" ticked is a build decision, not an FS instruction: remarks are free prose typed by
a credit controller, and without this flag SE11 upper-cases everything on the way in, so
`Approved by CFO for Q3` comes back as `APPROVED BY CFO FOR Q3` in the report. Tick it.

---

## 2. Object 1b — Data elements (6)

SE11 → **Data type** → type the name → radio button **Data element** → Create.

For every one: **Short Description**, then the **Data Type** tab (radio **Elementary Type** →
**Domain** → the domain name), then the **Field Label** tab. Leave the **Further
Characteristics** tab alone — no search help, no parameter ID, no change-document flag on any
of the six.

### 2.1 The four field labels, and their length limits

SE11 asks for four labels, each with its own **Length** column. The maxima are fixed by SE11:

| Label | Max length | Where it shows |
|---|---|---|
| Short | **10** | narrow SM30 / dynpro labels |
| Medium | **20** | SM30 column headers |
| Long | **40** | selection screen texts, F1 |
| Heading | **55** | ALV / list column heading |

Leave the **Length** column at whatever SE11 proposes (it proposes the maximum). Type the text
as printed below; the character count in brackets is given so you can see the fit at a glance.

### 2.2 ZSD_DE_EXC_SRNO

| SE11 field | Value |
|---|---|
| Data element | `ZSD_DE_EXC_SRNO` |
| Short Description | Exceptional Approval Serial Number |
| Elementary Type → Domain | `ZSD_DO_EXC_SRNO` |
| Short label | `Sr. No.` (7) |
| Medium label | `Serial No.` (10 — well inside the 20-character Medium limit; 10 is the **Short** limit) |
| Long label | `Serial Number` (13) |
| Heading | `Sr. No.` (7) |

### 2.3 ZSD_DE_EXC_MONTH

| SE11 field | Value |
|---|---|
| Data element | `ZSD_DE_EXC_MONTH` |
| Short Description | Exceptional Approval Month |
| Elementary Type → Domain | `ZSD_DO_EXC_MONTH` |
| Short label | `Month` (5) |
| Medium label | `Appr. Month` (11) |
| Long label | `Exceptional Approval Month` (26) |
| Heading | `Month` (5) |

### 2.4 ZSD_DE_EXC_TYPE

| SE11 field | Value |
|---|---|
| Data element | `ZSD_DE_EXC_TYPE` |
| Short Description | Exceptional Approval Type |
| Elementary Type → Domain | `ZSD_DO_EXC_TYPE` |
| Short label | `Type` (4) |
| Medium label | `Appr. Type` (10) |
| Long label | `Exceptional Approval Type` (25) |
| Heading | `Type` (4) |

### 2.5 ZSD_DE_EXC_AMOUNT

| SE11 field | Value |
|---|---|
| Data element | `ZSD_DE_EXC_AMOUNT` |
| Short Description | Exceptional Approval Amount |
| Elementary Type → Domain | `ZSD_DO_EXC_AMOUNT` |
| Short label | `Exc. Amt` (8) |
| Medium label | `Exceptional Amt` (15) |
| Long label | `Exceptional Amount` (18) |
| Heading | `Exc. Amount` (11) |

### 2.6 ZSD_DE_CM_AMOUNT

| SE11 field | Value |
|---|---|
| Data element | `ZSD_DE_CM_AMOUNT` |
| Short Description | Collection Commitment Amount |
| Elementary Type → Domain | `ZSD_DO_EXC_AMOUNT` (same domain as 2.5 — deliberate) |
| Short label | `Coll.Comm.` (10) — **see the note below** |
| Medium label | `Collection Comm.` (16) |
| Long label | `Collection Commitment Amount` (28) |
| Heading | `Coll. Commitment` (16) |

**The build spec prints the short label as `Coll. Comm.`, which is 11 characters and will not
fit** — the Short label maximum is 10. Type `Coll.Comm.` (10, space removed) as printed above.
This is the only label on the sheet that needed adjusting; it is a typing fix, not a design
change, and does not need functional sign-off.

### 2.7 ZSD_DE_EXC_REMARKS

| SE11 field | Value |
|---|---|
| Data element | `ZSD_DE_EXC_REMARKS` |
| Short Description | Exceptional Approval Remarks |
| Elementary Type → Domain | `ZSD_DO_EXC_REMARKS` |
| Short label | `Remarks` (7) |
| Medium label | `Remarks` (7) |
| Long label | `Remarks` (7) |
| Heading | `Remarks` (7) |

---

## 3. Object 2 — Transparent table ZSD_EXP_PAINTS

SE11 → **Database table** → `ZSD_EXP_PAINTS` → Create.

### 3.1 Header

| SE11 field | Value |
|---|---|
| Database table | `ZSD_EXP_PAINTS` |
| Short Description | Exceptional Approval Data - Paints |

Note the table name is `ZSD_EXP_PAINTS` — **P**, not C — while the report is
`ZSD_EXC_APPR_PAINTS`. They differ by one letter and both appear in the same programs.
Type it carefully; a typo here is discovered only when the report fails to activate.

### 3.2 Delivery and Maintenance tab

| SE11 field | Value | Why |
|---|---|---|
| Delivery Class | `A` — Application table (master and transaction data) | The rows are business data created in each client, not customizing shipped from SAP and not transported as content. |
| Data Browser/Table View Maint. | **Display/Maintenance Allowed** | Anything less blocks the TMG of §4 and blocks SM30. "Allowed with Restrictions" would let SE16 show it but stop SM30 maintenance — that is not what is wanted. |

### 3.3 Fields tab — all 17 rows, in position order

Type the **Field** name and the **Data element** only. SE11 fills Data Type, Length, Decimals
and the field's Short Description from the data element as soon as you press Enter — the values
in those columns below are what you should **see**, so use them as a check, not as something to
type. If a length comes back different from the table, stop and find out why before activating.

The **Key** flag must be ticked on rows 1–4 and nowhere else. Key fields have to be contiguous
from the top, which they are. SE11 sets the **Initial Values** flag on the key fields itself;
leave the rest as it sets them.

| Pos | Field | Key | Init | Data element | Type | Len | Dec | Check table | Curr/Qty ref | Source |
|---|---|:--:|:--:|---|---|---|---|---|---|---|
| 1 | `MANDT` | **X** | X | `MANDT` | CLNT | 3 | – | `T000` | – | standard |
| 2 | `ZSRN` | **X** | X | `ZSD_DE_EXC_SRNO` | NUMC | 10 | – | – | – | FS |
| 3 | `ZCUSTOMER` | **X** | X | `KUNNR` | CHAR | 10 | – | `KNA1` | – | FS |
| 4 | `ZEXC_APPR_MONTH` | **X** | X | `ZSD_DE_EXC_MONTH` | NUMC | 6 | – | – | – | FS |
| 5 | `ZEXC_APPR_TYPE` | | | `ZSD_DE_EXC_TYPE` | CHAR | 1 | – | – | – | FS |
| 6 | `ZEXC_DATE_FROM` | | | `DATUM` | DATS | 8 | – | – | – | FS |
| 7 | `ZEXC_DATE_TO` | | | `DATUM` | DATS | 8 | – | – | – | FS |
| 8 | `ZEXC_AMOUNT` | | | `ZSD_DE_EXC_AMOUNT` | CURR | 23 | 2 | – | **`WAERS`** | FS |
| 9 | `ZCOMMIT_DATE` | | | `DATUM` | DATS | 8 | – | – | – | FS |
| 10 | `ZEX_AMNT` | | | `ZSD_DE_EXC_AMOUNT` | CURR | 23 | 2 | – | **`WAERS`** | FS |
| 11 | `ZCM_AMNT` | | | `ZSD_DE_CM_AMOUNT` | CURR | 23 | 2 | – | **`WAERS`** | FS |
| 12 | `ZREMARKS` | | | `ZSD_DE_EXC_REMARKS` | CHAR | 250 | – | – | – | FS |
| 13 | `WAERS` | | | `WAERS` | CUKY | 5 | – | `TCURC` | – | **NOT FS — mandatory, §0.3** |
| 14 | `ERNAM` | | | `ERNAM` | CHAR | 12 | – | – | – | **NOT FS — recommended, §0.3** |
| 15 | `ERDAT` | | | `ERDAT` | DATS | 8 | – | – | – | **NOT FS — recommended, §0.3** |
| 16 | `AENAM` | | | `AENAM` | CHAR | 12 | – | – | – | **NOT FS — recommended, §0.3** |
| 17 | `AEDAT` | | | `AEDAT` | DATS | 8 | – | – | – | **NOT FS — recommended, §0.3** |

Notes on individual rows:

- **Row 1 `MANDT`** — the client field is mandatory and must be position 1 and part of the key.
  `T000` comes from the domain's value table; you do not create a foreign key for `MANDT` by
  hand, SE11 handles the client field itself.
- **Row 4 `ZEXC_APPR_MONTH` in the key** — this is what allows one customer to hold several
  approvals in different months. `ZSRN` alone would also be unique, but the four-part key makes
  the natural business key visible and lets the upload program detect duplicates on a key that
  means something (build spec §5.3 rules 9–10).
- **Row 10 `ZEX_AMNT`** — built because the FS declares it, but **no output column reads it**
  (build spec C4, open issue 8). Keep it, and get functional to say whether it is a real second
  figure or a duplicate of row 8 before go-live.
- **Rows 8, 10, 11** — see §3.5. They do not activate without it.
- **Row 12 `ZREMARKS` CHAR 250** — deliberately a CHAR, not a STRING: a STRING would put the
  column in a LOB and stop it appearing normally in SE16/SM30 and in the ALV.

### 3.4 Foreign keys

Put the cursor on the field, press the **Foreign Keys** button (the key icon above the field
list), and accept SE11's proposal unless it errors. Two foreign keys, no more:

| Field | Check table | Cardinality | Field-type proposal | Purpose |
|---|---|---|---|---|
| `ZCUSTOMER` | `KNA1` | `1 : CN` | accept what SE11 proposes (it proposes "key fields/candidates" because `ZCUSTOMER` is part of this table's key) | rejects a customer that does not exist, and gives F4 on the customer in SM30 |
| `WAERS` | `TCURC` | `1 : CN` | accept what SE11 proposes (non-key field) | rejects an invalid currency, gives F4 in SM30 |

**Cardinality is written check-table-side : foreign-key-table-side, and the LEFT position accepts
only `1` or `C`.** There is no `N` on the left, so `N : 1` — which earlier drafts of this sheet
printed — is not a pair SE11 will take; it is rejected at the input field and you cannot save the
foreign key with it. Read `1 : CN` as: every row of `ZSD_EXP_PAINTS` points at exactly one row of
the check table (`1`), and one customer — or one currency — may be referenced by any number of
approval rows including none (`CN`). Cardinality is a semantic attribute only: it does not change
the runtime check and leaving it blank still activates, but a value you cannot type stops you at
the foreign-key dialog.

The generated FK condition for `ZCUSTOMER` should come out as `KNA1-MANDT = ZSD_EXP_PAINTS-MANDT`
and `KNA1-KUNNR = ZSD_EXP_PAINTS-ZCUSTOMER`. If SE11 proposes anything else, stop — it means the
data element on row 3 is not `KUNNR`.

No foreign key on `ZEXC_APPR_TYPE`: its check is the domain fixed values (§1.3), which is
cheaper and needs no check table.

### 3.5 Currency/Quantity Fields tab — the activation blocker

**Do this before the first activation attempt.** Three rows, all pointing at the table's own
`WAERS`:

| Field | Reference table | Reference field |
|---|---|---|
| `ZEXC_AMOUNT` | `ZSD_EXP_PAINTS` | `WAERS` |
| `ZEX_AMNT` | `ZSD_EXP_PAINTS` | `WAERS` |
| `ZCM_AMNT` | `ZSD_EXP_PAINTS` | `WAERS` |

Reference table is this table itself — the currency lives on the same row as the amounts, which
is what you want, because a single approval row is denominated in one currency.

If you activate without these three rows filled you get three activation errors, one per amount
field, each naming a missing reference field. That is not a warning you can ignore and it is not
a problem with the domain — go back to this tab and fill it in.

The reference field must be type **CUKY**, which `WAERS` (row 13) is. If row 13 is missing or was
typed with the wrong data element, these three rows cannot be filled in at all.

### 3.6 Technical settings

At the first activation SE11 will demand these (or reach them with **Goto → Technical Settings**).

| SE11 field | Value | Reason |
|---|---|---|
| Data class | `APPL0` — Master data, transparent tables | The rows behave like master data: created once per customer per approval month, read constantly by the report, changed rarely. `APPL1` (transaction data) would be the choice if rows churned; they do not. Either activates — this is a tablespace placement decision, not a correctness one. |
| Size category | `1` | Expect a few hundred approvals a month, so low tens of thousands of rows over the life of the system. Category `0` would also work; `1` leaves headroom. **Size category can be raised later without losing data**, so do not agonise over it. |
| Buffering | **Buffering not allowed** | Two reasons, and state both if challenged: (a) the table is written by the TMG *and* by the mass-upload program, and the report must never read a stale image straight after an upload — a buffered read can serve the pre-upload picture until the buffer is invalidated across all app servers; (b) there is nothing to gain — `ZSD_EXC_APPR_PAINTS` reads the table **once** per run, so buffering would save one database call per report execution. |
| Buffering type | *(not applicable — greyed out once "not allowed" is chosen)* | |
| Log data changes | **Ticked** | See below. |

**"Log data changes" vs. the four audit fields (rows 14–17).** The build spec calls table logging
the alternative to the audit fields. Recommendation: **do both**, because they are not equivalent.

| | Log data changes | Rows 14–17 |
|---|---|---|
| Records | every field change, old and new value, per change | who created / last changed the row, and when |
| Read by | SCU3 / RSVTPROT, by a Basis-capable user | SE16, SM30 and the report, by anyone |
| Depends on | profile parameter **`rec/client`** covering this client — if Basis has not set it, **ticking the box logs nothing** | nothing |
| Retention | table `DBTABLOG`, periodically purged by Basis | as long as the row exists |
| Cost | a `DBTABLOG` write per change | 40 bytes per row |

So: tick the box, keep the four fields, and **ask Basis to confirm `rec/client` includes the
productive client** — otherwise the tick is decoration. If functional insists on dropping rows
14–17, the logging tick is the fallback and that confirmation stops being optional.

### 3.7 Enhancement category

**Extras → Enhancement Category → "Can be enhanced (deep)"**, then save.

Without it, activation raises the "enhancement category missing" warning. The table still
activates, but the warning follows the object into every later activation and into ATC. Set it
once now.

### 3.8 Activate

Activate the table. Expected result: active, no errors, and at most the enhancement-category
warning if §3.7 was skipped.

If it fails, the order to check things in:

1. Three errors naming the amount fields → §3.5, the Currency/Quantity Fields tab.
2. "Data element does not exist" → a data element from §2 is not active yet, or `DATUM` is not
   a data element on this system (§0.4).
3. Foreign key errors → §3.4, usually the wrong data element on row 3. If the foreign-key
   dialog will not accept the cardinality, you typed `N : 1` — the left position takes only
   `1` or `C` (§3.4).
4. Key fields not contiguous → the Key flag was ticked below row 4.

---

## 4. Object 3 — Table maintenance generator

**Only after the table is active.** SE11 → display `ZSD_EXP_PAINTS` → **Utilities → Table
Maintenance Generator**.

| SE11 field | Value | Note |
|---|---|---|
| Authorization Group | `&NC&` | Placeholder for "no authorization group assigned". Replace it the moment functional names a real group — FS says "Authorization TBD" (open issue 15), so this is knowingly provisional and must not be forgotten before go-live. |
| Authorization object | `S_TABU_DIS` (SE11's default) | Leave it. With `&NC&` this means anyone with `S_TABU_DIS` on `&NC&` can maintain the table — which is exactly why the group needs replacing. |
| Function group | `ZSD_EXC_PAINTS` | New function group, created by the generator. Note it is `ZSD_EXC_PAINTS` (with a **C**) while the table is `ZSD_EXP_PAINTS` (with a **P**) — that is what the build spec says; keep it. |
| Package | the UDAY SD Z package (same as the table) | The generator will prompt for package and TR for the generated function group and screens. |
| Maintenance type | **one step** | The table is flat, 17 columns, no header/detail split. A two-step maintenance would add an overview list plus a single-record screen for no benefit. |
| Overview screen | `0001` | |
| Single screen | *(blank)* | One-step maintenance has no single screen. |
| Recording routine | **standard recording routine** | Per build spec §4. See the flag below. |

Then **Create** (the "Create" / find-screen-number button generates the screens and the function
group).

**Flag on the recording routine.** "Standard recording routine" means changes made through SM30
are written to a transport request in any client where automatic recording of changes is on.
That is right for DEV and it is right if the data is maintained in DEV and transported. It is
**wrong** if the business intends to maintain exceptional approvals directly in production, which
is the normal pattern for delivery-class-A application data — users would be asked for a
transport request they cannot create. The build spec settles on "standard recording routine", so
build that, but put the question to functional along with issue 15: **where is this table
maintained, DEV or production?** Switching later is a regeneration, not a rebuild.

**Access.** After generation the table is maintained through **SM30 → `ZSD_EXP_PAINTS` →
Maintain**. No SE93 parameter transaction is in scope for 141.B; if functional wants a named
transaction code for the users, that is an extra object and needs the authorization group
settled first.

**Regenerate after any table change.** If a field is ever added, removed or retyped on
`ZSD_EXP_PAINTS`, the TMG must be regenerated (Utilities → Table Maintenance Generator →
Generated Objects → Change/Delete, then generate again). A TMG left stale against a changed
table dumps in SM30.

### 4.1 The TMG is always manual — it never appears in a ZIP

**abapGit does not serialise a table maintenance generator.** The generated screens (SE51) and
GUI status (SE41) are not serialised, so the TMG is not in any ZIP this project ever produces —
if the DDIC objects on this sheet were ever shipped by abapGit, the table would arrive in the
target system **without** its maintenance dialog and SM30 would report that no maintenance is
defined.

The TMG is therefore regenerated by hand in **every** system it is needed in — or, more
usually, generated once in DEV and moved by transport (the generated function group and screens
are ordinary transportable repository objects, they just cannot travel through git). This is the
same rule that already applies to `kpmg/zmm_po_budget/` and `kpmg/zsd_scheme/` in this repo, and
it sits in CLAUDE.md under "What stays manual, always".

---

## 5. Sign-off checklist

Tick these before telling functional the DDIC is done:

- [ ] 5 domains active, `ZSD_DO_EXC_TYPE` shows fixed values 1/2/3 with the right texts
- [ ] 6 data elements active, `ZSD_DE_CM_AMOUNT` short label typed as `Coll.Comm.` (§2.6)
- [ ] Table active, 17 fields, key = rows 1–4 only
- [ ] Currency/Quantity Fields tab holds three rows, all `ZSD_EXP_PAINTS` / `WAERS` (§3.5)
- [ ] Foreign keys on `ZCUSTOMER` → `KNA1` and `WAERS` → `TCURC`
- [ ] Technical settings: `APPL0`, size `1`, buffering **not allowed**, log data changes ticked
- [ ] Enhancement category set (§3.7)
- [ ] TMG generated, function group `ZSD_EXC_PAINTS`, one step, screen 0001
- [ ] SM30 → `ZSD_EXP_PAINTS` opens and a test row can be entered and saved
- [ ] Raised with functional: `WAERS` and rows 14–17 (§0.3), CURR length 23 (§1.4),
      `ZEX_AMNT` (issue 8), authorization group and maintenance client (issue 15, §4),
      `rec/client` confirmation from Basis (§3.6)

Everything on this sheet is in the same transport as the two programs, or in its own — either
is fine, but the DDIC objects must reach QA **before** the programs, or the programs will not
activate there.
