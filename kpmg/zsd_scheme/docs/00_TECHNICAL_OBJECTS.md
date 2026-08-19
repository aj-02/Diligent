# ZSD_SCHEME — Technical Object List & DDIC Definitions

Astral Limited / Project UDAY / Module SD / WRICEF **SCHEME**
Built to the assumption register `FSD/Scheme_Pipes_Assumptions_and_Queries.docx` (A01–A42).

> **Namespace note (Q1 open).** Everything below uses the standard `Z*` namespace and
> package `ZSD_SCHEME`. If Astral has a registered customer namespace, every name here
> takes the namespace prefix and nothing else changes.

---

## 1. Object inventory

| # | Type | Technical name | Description |
|---|---|---|---|
| 1 | Package | `ZSD_SCHEME` | Scheme (Pipes) development |
| 2 | Table | `ZSDT_SCHM_HDR` | Scheme header |
| 3 | Table | `ZSDT_SCHM_RNG` | Scheme selection ranges (generic) |
| 4 | Table | `ZSDT_SCHM_RAT` | Scheme product ratio lines |
| 5 | Table | `ZSDT_SCHM_SLB` | Scheme slabs — provisioned, not used (A09) |
| 6 | Table | `ZSDT_SCHM_SETL` | Settlement log / cascading source |
| 7 | Table | `ZSDT_SCHM_FKA` | Billing types counting toward volume (A17) |
| 8 | Table | `ZSDT_SCHM_CFG` | Settlement posting config (order type / billing type / material / condition) |
| 9 | Structure | `ZSDS_SCHM_INI` | Initial screen (0100) work structure |
| 10 | Structure | `ZSDS_SCHM_RNG_S` | Range line for ALV (with description) |
| 11 | Structure | `ZSDS_SCHM_RAT_S` | Ratio line for ALV |
| 12 | Structure | `ZSDS_SCHM_RES` | Report / settlement result line |
| 13 | Structure | `ZSDS_SCHM_PER` | Settlement period |
| 14 | Structure | `ZSDS_SCHM_UPH` | Upload — header file record |
| 15 | Structure | `ZSDS_SCHM_UPR` | Upload — range file record |
| 16 | Table type | `ZSTT_SCHM_RNG` | `ZSDT_SCHM_RNG` table type |
| 17 | Table type | `ZSTT_SCHM_RAT` | `ZSDT_SCHM_RAT` table type |
| 18 | Table type | `ZSTT_SCHM_RES` | `ZSDS_SCHM_RES` table type |
| 19 | Table type | `ZSTT_SCHM_PER` | `ZSDS_SCHM_PER` table type |
| 20 | Lock object | `EZSDT_SCHM_HDR` | Exclusive lock on scheme (arg `SCHEME_NO`) |
| 21 | Number range | `ZSDSCHEME` | Internal scheme number (A01) |
| 22 | Message class | `ZSD_SCHEME` | Messages (FS 2.2 blank — see Q12) |
| 23 | Auth object | `ZSD_SCHM` | Scheme maintenance (A37) |
| 24 | Auth object | `ZSD_SCHM_ST` | Settlement posting (A37) |
| 25 | Change doc obj | `ZSDSCHEME` | Change documents (A36) |
| 26 | Class | `ZCL_SD_SCHEME` | Scheme model — read / validate / save / release / delete |
| 27 | Class | `ZCL_SD_SCHEME_SETTLE` | Volume, early bird, cascading, CN calculation and posting |
| 28 | Module pool | `SAPMZSD_SCHEME` | Create / Change / Display transaction |
| 29 | Report | `ZSD_SCHEME_REPORT` | Report with settlement |
| 30 | Report | `ZSD_SCHEME_UPLOAD` | Mass upload / change |
| 31 | Tcode | `ZSCHM01` | Create Scheme → `SAPMZSD_SCHEME` scr. 0100 |
| 32 | Tcode | `ZSCHM02` | Change Scheme → `SAPMZSD_SCHEME` scr. 0100 |
| 33 | Tcode | `ZSCHM03` | Display Scheme → `SAPMZSD_SCHEME` scr. 0100 |
| 34 | Tcode | `ZSCHM_RPT` | Scheme Report & Settlement → `ZSD_SCHEME_REPORT` |
| 35 | Tcode | `ZSCHM_UPL` | Scheme Mass Upload → `ZSD_SCHEME_UPLOAD` |
| 36 | Search help | `ZSH_SCHM_NO` | Scheme number F4 |

Transaction parameters — `ZSCHM01/02/03` are parameter transactions on `SAPMZSD_SCHEME`
screen `0100`, passing `ZSDS_SCHM_INI-MODE` = `H` (create) / `V` (change) / `A` (display).

---

## 2. Domains

| Domain | Type | Len | Fixed values |
|---|---|---|---|
| `ZDO_SCHM_NO` | CHAR | 10 | — |
| `ZDO_SCHM_TYPE` | CHAR | 1 | `D` Daily, `M` Monthly, `Q` Quarterly, `H` Half-Yearly, `Y` Yearly |
| `ZDO_SCHM_CAT` | CHAR | 1 | `V` Value Based, `Q` Quantity Based, `R` Ratio Based, `B` Value & Ratio |
| `ZDO_SCHM_STAT` | CHAR | 1 | `N` New, `R` Released, `P` Partially Settled, `C` Closed |
| `ZDO_SETL_STAT` | CHAR | 1 | `O` Open, `P` Posted, `B` Billed, `E` Error, `X` Not achieved |
| `ZDO_EBTGT_TYP` | CHAR | 1 | `A` Amount, `P` Percentage of target |
| `ZDO_SCHM_FLD` | CHAR | 20 | `MVGR1`…`MVGR5`, `REGIO`, `KUNNR`, `KVGR1`, `KVGR2`, `ZONE1`, `ZONE2` |
| `ZDO_SCHM_PCT` | DEC | 5,2 | — |

## 3. Data elements

| Data element | Domain / type | Short text |
|---|---|---|
| `ZDE_SCHM_NO` | `ZDO_SCHM_NO` | Scheme Number |
| `ZDE_SCHM_TYPE` | `ZDO_SCHM_TYPE` | Scheme Type |
| `ZDE_SCHM_CAT` | `ZDO_SCHM_CAT` | Scheme Category |
| `ZDE_SCHM_STAT` | `ZDO_SCHM_STAT` | Scheme Status |
| `ZDE_SETL_STAT` | `ZDO_SETL_STAT` | Settlement Status |
| `ZDE_SCHM_DESCR` | CHAR 60 | Scheme Description |
| `ZDE_SCHM_TEXT` | CHAR 255 | Scheme Text |
| `ZDE_SCHM_PCT` | `ZDO_SCHM_PCT` | Scheme Percentage |
| `ZDE_EBTGT_TYP` | `ZDO_EBTGT_TYP` | Early Bird Target Type |
| `ZDE_SCHM_FLD` | `ZDO_SCHM_FLD` | Scheme Selection Field |

---

## 4. Tables

### 4.1 `ZSDT_SCHM_HDR` — Scheme Header
Delivery class `A`, maintenance **not** allowed (maintained only through `ZSCHM01/02/03`).

| Key | Field | Data element / type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` | `MANDT` | Client |
| ✔ | `SCHEME_NO` | `ZDE_SCHM_NO` | Scheme number (A01) |
| | `SCHEME_TYPE` | `ZDE_SCHM_TYPE` | Scheme type / settlement periodicity (A02) |
| | `VKORG` | `VKORG` | Sales organisation (A04) |
| | `VTWEG` | `VTWEG` | Distribution channel (A04) |
| | `SPART` | `SPART` | Division (A04) |
| | `SCHEME_CAT` | `ZDE_SCHM_CAT` | Scheme category |
| | `VALID_FROM` | `DATS` | Valid from |
| | `VALID_TO` | `DATS` | Valid to |
| | `EARLY_BIRD` | `CHAR1` | Early bird active |
| | `CASCADING` | `CHAR1` | Cascading active (A24) |
| | `DESCR` | `ZDE_SCHM_DESCR` | Description |
| | `TARGET_VAL` | `CURR 15,2` ref `WAERS` | Target value (A10) |
| | `TARGET_QTY` | `QUAN 15,3` ref `MEINS` | Target quantity (A11) |
| | `WAERS` | `WAERS` | Currency (A14) |
| | `MEINS` | `MEINS` | Base unit of measure |
| | `SCHEME_PCT` | `ZDE_SCHM_PCT` | Scheme % for CN (A21) |
| | `PAR_CHILD` | `CHAR1` | Parent/child aggregation (A07) |
| | `EB_DATE_FR` | `DATS` | Early bird from |
| | `EB_DATE_TO` | `DATS` | Early bird to |
| | `EB_TGT_TYP` | `ZDE_EBTGT_TYP` | Early bird target type (A23) |
| | `EB_TARGET` | `DEC 15,2` | Early bird target |
| | `EB_PCT` | `ZDE_SCHM_PCT` | Early bird % (A22) |
| | `SCHM_TEXT` | `ZDE_SCHM_TEXT` | Free text |
| | `STATUS` | `ZDE_SCHM_STAT` | Status (A33) |
| | `DEL_IND` | `CHAR1` | Deletion indicator (A35) |
| | `ERNAM` `ERDAT` `ERZET` | `ERNAM` `ERDAT` `ERZET` | Created by / on / at |
| | `AENAM` `AEDAT` `AEZET` | `AENAM` `AEDAT` `AEZET` | Changed by / on / at |

Secondary index `Z01` on `VKORG, VTWEG, SPART, VALID_FROM, VALID_TO`.

### 4.2 `ZSDT_SCHM_RNG` — Scheme Selection Ranges (A05, A06)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` | `MANDT` | Client |
| ✔ | `SCHEME_NO` | `ZDE_SCHM_NO` | Scheme number |
| ✔ | `FIELDNAME` | `ZDE_SCHM_FLD` | `MVGR1`…`MVGR5` / `REGIO` / `KUNNR` / `KVGR1` / `KVGR2` / `ZONE1` / `ZONE2` |
| ✔ | `SEQNR` | `NUMC 4` | Sequence |
| | `SIGN` | `CHAR 1` | `I` include / `E` exclude |
| | `OPTI` | `CHAR 2` | `EQ` `BT` `CP` `NE` … |
| | `LOW` | `CHAR 40` | From value |
| | `HIGH` | `CHAR 40` | To value |

**This one table replaces seven child tables.** "Select All" is one row `I / CP / *`
(A05). Zone and Sub-Zone need no DDIC change when the source fields are confirmed —
only the `ZDO_SCHM_FLD` fixed-value list and the field mapping in
`ZCL_SD_SCHEME_SETTLE=>build_ranges` (A06, Q8).

### 4.3 `ZSDT_SCHM_RAT` — Product Ratio (A12)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `SCHEME_NO` / `SEQNR` | | Key |
| | `MATNR` | `MATNR` | Material |
| | `RATIO_PCT` | `ZDE_SCHM_PCT` | Ratio % (must total 100) |

### 4.4 `ZSDT_SCHM_SLB` — Slabs (provisioned, A09)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `SCHEME_NO` / `SEQNR` | | Key |
| | `ACH_FROM` | `DEC 5,2` | Achievement % from |
| | `ACH_TO` | `DEC 5,2` | Achievement % to |
| | `PAY_PCT` | `ZDE_SCHM_PCT` | Payout % |

Created empty so that slab payout (Q10) is a code change only, never a table conversion.

### 4.5 `ZSDT_SCHM_SETL` — Settlement Log (A31, A32)

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` | `MANDT` | Client |
| ✔ | `SCHEME_NO` | `ZDE_SCHM_NO` | Scheme |
| ✔ | `PERIOD_SEQ` | `NUMC 3` | Period sequence (A02) |
| ✔ | `KUNNR` | `KUNNR` | Customer (parent where A07 applies) |
| | `PER_FROM` / `PER_TO` | `DATS` | Period |
| | `BUS_VOL` | `CURR 15,2` | Business volume |
| | `BUS_QTY` | `QUAN 15,3` | Business quantity |
| | `TARGET_MET` | `CHAR 1` | Target achieved |
| | `MAIN_CN` | `CURR 15,2` | Main credit note (A21) |
| | `EB_AMOUNT` | `CURR 15,2` | Early bird amount (A22) |
| | `CASC_VAL` | `CURR 15,2` | Cascading value (A24) |
| | `CN_VALUE` | `CURR 15,2` | Final CN value (A25) |
| | `WAERS` | `WAERS` | Currency |
| | `CN_ORDER` | `VBELN_VA` | Credit memo request |
| | `CN_INVOICE` | `VBELN_VF` | Credit memo |
| | `STATUS` | `ZDE_SETL_STAT` | Settlement status |
| | `POST_DATE` / `POST_TIME` / `POST_USER` | `DATS` `TIMS` `SYUNAME` | Posting audit |
| | `MESSAGE` | `CHAR 220` | Last message |

Index `Z01` on `KUNNR, PER_FROM, PER_TO, STATUS` — used by the cascading read.

### 4.6 `ZSDT_SCHM_FKA` — Billing Types in Volume (A17)
Delivery class `C`, SM30 maintenance view `ZSDV_SCHM_FKA`.

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `VKORG` / `FKART` | | Key |
| | `VZ_SIGN` | `CHAR 1` | `+` adds to volume, `-` nets off (returns / credit memos) |

### 4.7 `ZSDT_SCHM_CFG` — Settlement Posting Config (A29, Q3)
Delivery class `C`, SM30 maintenance view `ZSDV_SCHM_CFG`.

| Key | Field | Type | Description |
|:--:|---|---|---|
| ✔ | `MANDT` / `VKORG` | | Key |
| | `AUART` | `AUART` | Credit memo request order type (Q3) |
| | `FKART` | `FKART` | Credit memo billing type (Q3) |
| | `MATNR` | `MATNR` | Service material for payout (Q3) |
| | `KSCHL` | `KSCHL` | Manual condition type carrying the value |

**Nothing about the posting is hardcoded** — Q3 is answered by an SM30 entry, not a
code change.

---

## 5. Structures and table types

### `ZSDS_SCHM_INI` — initial screen 0100
`MODE` CHAR1 · `SCHEME_NO` `ZDE_SCHM_NO` · `SCHEME_TYPE` · `VKORG` · `VTWEG` · `SPART`
· `SCHEME_CAT` · `VALID_FROM` · `VALID_TO` · `EARLY_BIRD` CHAR1 · `CASCADING` CHAR1

### `ZSDS_SCHM_RNG_S` — range ALV line
`.INCLUDE ZSDT_SCHM_RNG` (without `MANDT`) + `FLD_TEXT` CHAR 40 · `LOW_TEXT` CHAR 40

### `ZSDS_SCHM_RAT_S` — ratio ALV line
`.INCLUDE ZSDT_SCHM_RAT` (without `MANDT`) + `MAKTX` `MAKTX`

### `ZSDS_SCHM_PER` — settlement period
`PERIOD_SEQ` NUMC3 · `PER_FROM` DATS · `PER_TO` DATS

### `ZSDS_SCHM_RES` — report / settlement result line
Mirrors the four ALV blocks in FS §2.1 exactly:

| Block | Fields |
|---|---|
| Scheme | `SCHEME_NO` `DESCR` `SCHEME_TYPE` `SCHEME_CAT` `TARGET_VAL` `TARGET_QTY` `VALID_FROM` `VALID_TO` |
| Selection | `MVGR1`–`MVGR5` `VKORG` `SPART` `VTWEG` `WKREG` `PAR_CHILD` `KUNNR` `NAME1` |
| Customer | `KVGR1` `KVGR2` `LOC1` `LOC2` `SCHEME_PCT` `SCHM_TEXT` |
| Values | `BUS_VOL` `BUS_QTY` `EB_AMOUNT` `CASC_VAL` `MAIN_CN` `CN_VALUE` `WAERS` `CN_ORDER` `CN_INVOICE` |
| Control | `PERIOD_SEQ` `PER_FROM` `PER_TO` `TARGET_MET` `STATUS` `MESSAGE` `MARK` CHAR1 `LIGHT` CHAR1 |

Table types: `ZSTT_SCHM_RNG`, `ZSTT_SCHM_RAT`, `ZSTT_SCHM_RES`, `ZSTT_SCHM_PER`.

---

## 6. Number range object `ZSDSCHEME`

| Property | Value |
|---|---|
| Object | `ZSDSCHEME` |
| Number length | 10 |
| Sub-object | none |
| Interval `01` | `0000000001` – `0999999999`, external `N` |
| Warning % | 10 |
| Buffering | not buffered (gap-free numbering) |

---

## 7. Lock object `EZSDT_SCHM_HDR`

Primary table `ZSDT_SCHM_HDR`, lock mode **E** (exclusive), lock argument `SCHEME_NO`.
Generates `ENQUEUE_EZSDT_SCHM_HDR` / `DEQUEUE_EZSDT_SCHM_HDR`.

---

## 8. Authorisation objects (A37)

### `ZSD_SCHM` — Scheme Maintenance
Class `SD`. Fields: `VKORG`, `VTWEG`, `SPART`, `ACTVT`.
Permitted activities: `01` Create · `02` Change · `03` Display · `06` Delete · `43` Release.

### `ZSD_SCHM_ST` — Scheme Settlement
Class `SD`. Fields: `VKORG`, `ACTVT`.
Permitted activities: `03` Display/simulate · `16` Execute (post).

Segregation of duties is enforced because the Post button in `ZSD_SCHEME_REPORT` is
suppressed entirely without `ZSD_SCHM_ST` `ACTVT 16` — it is not merely a check at
posting time.

---

## 9. Change document object `ZSDSCHEME` (A36)

Tables registered: `ZSDT_SCHM_HDR`, `ZSDT_SCHM_RNG`, `ZSDT_SCHM_RAT`.
Generates `ZSDSCHEME_WRITE_DOCUMENT`, called from `ZCL_SD_SCHEME=>save`.

---

## 10. Message class `ZSD_SCHEME`

| No | Type | Text |
|---|---|---|
| 001 | E | Scheme &1 does not exist |
| 002 | E | Scheme &1 is locked by user &2 |
| 003 | E | Enter a valid from and to date |
| 004 | E | Valid-to date must not be before valid-from date |
| 005 | E | Enter a scheme description |
| 006 | E | Enter a target value for a value based scheme |
| 007 | E | Enter a target quantity for a quantity based scheme |
| 008 | E | Enter the scheme percentage |
| 009 | E | Scheme percentage must be between 0 and 100 |
| 010 | E | Maintain at least one selection criterion |
| 011 | E | Early bird period must lie within the scheme validity |
| 012 | E | Enter the early bird target and percentage |
| 013 | E | Product ratio must total 100 percent, currently &1 |
| 014 | E | Maintain product ratio lines for a ratio based scheme |
| 015 | E | Sales organisation &1 / channel &2 / division &3 is not valid |
| 016 | E | No authorisation for sales organisation &1 activity &2 |
| 017 | E | Scheme &1 is settled and can no longer be changed |
| 018 | S | Scheme &1 saved |
| 019 | S | Scheme &1 released |
| 020 | S | Scheme &1 flagged for deletion |
| 021 | E | Invalid value &1 for field &2 |
| 022 | E | Customer &1 does not exist in sales area |
| 023 | E | Settlement configuration missing for sales organisation &1 |
| 024 | E | Credit memo request could not be created: &1 |
| 025 | E | Credit memo could not be created for order &1: &2 |
| 026 | S | Credit memo request &1 / credit memo &2 created |
| 027 | W | Scheme &1 customer &2 period &3 is already settled |
| 028 | E | No authorisation to post settlements |
| 029 | I | No data selected for the given criteria |
| 030 | E | Upload file could not be read: &1 |
| 031 | E | Row &1: &2 |
| 032 | S | &1 schemes created, &2 rows in error |
| 033 | E | Reference key &1 has no header record |
| 034 | E | Ratio lines are only allowed for ratio based schemes |
| 035 | E | Select at least one line for posting |

---

## 11. Build sequence

1. Domains → data elements → tables → structures → table types
2. Number range object, lock object, message class, authorisation objects, change doc object
3. `ZCL_SD_SCHEME`
4. `SAPMZSD_SCHEME` + screens + GUI status + transactions
5. `ZCL_SD_SCHEME_SETTLE`
6. `ZSD_SCHEME_REPORT`
7. `ZSD_SCHEME_UPLOAD`
8. Config entries in `ZSDT_SCHM_FKA` and `ZSDT_SCHM_CFG` (needs Q3, Q7)
