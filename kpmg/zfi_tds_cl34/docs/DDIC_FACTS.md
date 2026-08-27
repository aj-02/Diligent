# DDIC_FACTS — ZFI_TDS_CL34

Authoritative DDIC fact sheet for the Clause 34 TDS report. Reconciled from four recon
reports. **This file overrides `BUILD_BRIEF.md` §D4 and overrides every field name in
`docs/FS_EXTRACT.md`.** Build agents code from this file; anything not listed here is
UNVERIFIED and must carry `" ASSUMPTION:` plus a `docs/QUERIES.md` row.

---

## 0. Status of the recon

**ADT scratch rig: REACHABLE.** `mcp__abap-adt__healthcheck` returned
`{"status":"healthy"}` at 2026-08-26T16:51:51Z, login OK. `DD03L`, `DD04L`, `DD04T`,
`DD02L` were read via `runQuery`; two read-only `syntaxCheckCode` probes (base tables,
then the two CDS views) returned **zero errors**. No write call of any kind was issued
— no `setObjectSource`, no `activateByName`, no `createTransport`.

**CAVEAT, per `CLAUDE.md`:** the rig is the scratch dev system (`192.168.11.21`,
client 200), **not** the KPMG/Astral target. Everything below is SAP-standard DDIC and
is therefore stable across systems of the same release, so the *names* are safe to code
against. What the rig cannot tell us: (a) whether a customer append exists on the target,
(b) whether any field is actually **populated** in Astral's data. Existence ≠ population.
That distinction drives the whole RISKS section.

**Corroboration is thin.** Three of the four recon reports returned `null`:

| Report | Result |
|---|---|
| `recon:adt-ddic` | delivered — live DDIC read, the only primary evidence in this build |
| `recon:web-bseg` | **null** — no output |
| `recon:web-india-tds` | **null** — no output |
| `recon:web-cds-mm` | **null** — no output |
| `recon:repo-style` | delivered — house style, no DDIC content |
| `recon:fs-contract` | delivered — FS analysis, **no system access**; its DDIC claims are inference |

Consequence for the weighting rule: a live DDIC read beats a blog, and there were no
blogs. So ADT-read names are CONFIRMED (top tier available) even though single-sourced.
Where `recon:fs-contract` contradicts the ADT read, **the ADT read wins and the
fs-contract claim is discarded** — it was reasoning, not evidence. Every such
contradiction is listed in §3 DECISIONS. Where a name appears **only** in
`recon:fs-contract` and was never read from DD03L, it is UNVERIFIED — no exceptions,
however plausible it sounds.

---

## 1. CONFIRMED

Read from `DD03L` / `DD04L` / `DD04T` / `DD02L` on the live rig, and in the marked cases
independently corroborated by the CDS DDL source and/or a zero-error syntax check.
`pos` = position in `DD03L`.

### 1.1 Driver tables

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `WITH_ITEM` | — (table) | — | **MANDT, BUKRS, BELNR, GJAHR, BUZEI, WITHT** (6 fields; `WT_WITHCD` is **not** a key field) | DD03L full 94-position read, ORDER BY POSITION |
| `WITH_ITEM` | `BUKRS` | `BUKRS` | KEY pos 2, CHAR 4 | DD03L |
| `WITH_ITEM` | `BELNR` | `BELNR_D` | KEY pos 3, CHAR 10 | DD03L |
| `WITH_ITEM` | `GJAHR` | `GJAHR` | KEY pos 4, NUMC 4 | DD03L |
| `WITH_ITEM` | `BUZEI` | `BUZEI` | KEY pos 5, NUMC 3 | DD03L |
| `WITH_ITEM` | `WITHT` | `WITHT` | KEY pos 6, CHAR 2 (tax **type**) | DD03L |
| `WITH_ITEM` | `WT_WITHCD` | `WT_WITHCD` | non-key pos 7, CHAR 2 (tax **code**) | DD03L + `I_WithholdingTaxItem` DDL (`WithholdingTaxCode`) |
| `WITH_ITEM` | `WT_QSSHH` | `WT_BS` | non-key pos 8, CURR 23,2 — **base amount in company-code currency** | DD03L + DDL maps `WhldgTaxBaseAmtInCoCodeCrcy` → `wt_qsshh` |
| `WITH_ITEM` | `WT_QSSHB` | `WT_BS1` | non-key pos 9, CURR 23,2 — base amount in **transaction** currency | DD03L + DDL (`WhldgTaxBaseAmtInTransacCrcy`) |
| `WITH_ITEM` | `WT_QBSHH` | `WT_WT` | non-key pos 17, CURR 23,2 — **tax amount in company-code currency** | DD03L + DDL maps `WhldgTaxAmtInCoCodeCrcy` → `wt_qbshh` |
| `WITH_ITEM` | `WT_QBSHB` | `WT_WT1` | non-key pos 18, CURR 23,2 — tax amount in transaction currency | DD03L + DDL |
| `WITH_ITEM` | `WT_STAT` | `WT_STAT` | non-key pos 24, CHAR 1 | DD03L |
| `WITH_ITEM` | `WT_QSFHH` | `WT_EXMP` | non-key pos 25, CURR 23,2 — exempt amount, CC currency | DD03L |
| `WITH_ITEM` | `WT_WTEXMN` | `WT_EXNR` | non-key pos 29, CHAR 25 — exemption certificate **recorded on the document** | DD03L (same DE as `FIWTIN_TAN_EXEM-WT_EXNR`) |
| `WITH_ITEM` | `KOART` | `KOART` | non-key pos 30, CHAR 1 | DD03L |
| `WITH_ITEM` | `WT_ACCO` | `WT_ACNO` | non-key pos 31, CHAR 10 — vendor/customer account | DD03L + DDL (`CustomerSupplierAccount`) |
| `WITH_ITEM` | `HKONT` | `HKONT` | non-key pos 32, CHAR 10 | DD03L + DDL (`GLAccount`) |
| `WITH_ITEM` | `HKONT_OPP` | `HKONT` | non-key pos 33, CHAR 10 — offsetting GL, **not** exposed by the CDS view | DD03L |
| `WITH_ITEM` | `QSREC` | `WT_QSREC` | non-key pos 34, CHAR 2 | DD03L |
| `WITH_ITEM` | `AUGBL` | `AUGBL` | non-key pos 35, CHAR 10 | DD03L + DDL (`ClearingAccountingDocument`) |
| `WITH_ITEM` | `AUGDT` | `AUGDT` | non-key pos 36, DATS 8 | DD03L + DDL (`ClearingDate`) |
| `WITH_ITEM` | `WT_QSZRT` | `WT_EXRT` | non-key pos 37, DEC 5,2 — exemption rate | DD03L + DDL (`WithholdingTaxExmptPercent`) |
| `WITH_ITEM` | `WT_ACCBS` | `WT_ACCBS` | non-key pos 47, CURR 23,2 — **accumulated base** | DD03L |
| `WITH_ITEM` | `WT_ACCWT` | `WT_ACCWT` | non-key pos 48, CURR 23,2 — accumulated tax | DD03L |
| `WITH_ITEM` | `QSATZ` | `WT_QSATZ` | non-key pos 59, DEC 7,4 — **rate actually deducted** | DD03L + DDL (`WithholdingTaxPercent`) |
| `WITH_ITEM` | `CTNUMBER` | `CTNUMBER` | non-key pos 64, CHAR 10 — WHT certificate number | DD03L + DDL (`WithholdingTaxCertificate`) |
| `WITH_ITEM` | `CTISSUEDATE` | `CTISSUEDATE` | non-key pos 67, DATS 8 | DD03L + DDL (`WhldgTaxCertDate`) |
| `WITH_ITEM` | `J_1IINTCHLN` | `J_1IINTCHLN` | non-key pos 86, CHAR 12 — India append, internal challan no. | DD03L |
| `WITH_ITEM` | `J_1IINTCHDT` | `J_1IINTCHDT` | non-key pos 87, DATS 8 — challan date | DD03L |
| `WITH_ITEM` | `J_1ICERTDT` | `J_1ICERTDT` | non-key pos 90, DATS 8 — certificate date | DD03L |
| `WITH_ITEM` | `FIWTIN_PAR_EXEM` | `FIWTIN_PAR_EXEM_IND` | non-key pos 94, CHAR 1 — **partial-exemption indicator** | DD03L |
| `WITH_ITEM` | `SECCO` | — | **DOES NOT EXIST** | full 94-position list inspected |
| `WITH_ITEM` | posting date | — | **DOES NOT EXIST** (no `BUDAT`, no date-of-posting field) | full 94-position list inspected |

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `BKPF` | — (table) | — | **MANDT, BUKRS, BELNR, GJAHR** — SAP-standard, consistent with every position read below | DD03L reads + SAP-standard key |
| `BKPF` | `BLDAT` | `BLDAT` | non-key pos 6, DATS 8 — document date | DD03L + DDL (`DocumentDate`) |
| `BKPF` | `BUDAT` | `BUDAT` | non-key pos 7, DATS 8 — **posting date; the mandatory filter** | DD03L + DDL (`PostingDate`) |
| `BKPF` | `XBLNR` | `XBLNR1` | non-key pos 17, CHAR 16 — reference | DD03L + DDL (`DocumentReferenceID`) |
| `BKPF` | `STBLG` | `STBLG` | non-key pos 21, CHAR 10 — reversal document | DD03L + DDL (`ReverseDocument`) |
| `BKPF` | `BSTAT` | `BSTAT_D` | non-key pos 28, CHAR 1 — document status | DD03L + DDL (`AccountingDocumentCategory`) |
| `BKPF` | `AWTYP` | `AWTYP` | non-key pos 37, CHAR 5 — **this is the field that holds `RMRP`** | DD03L + DDL (`ReferenceDocumentType`) |
| `BKPF` | `AWKEY` | `AWKEY` | non-key pos 38, CHAR 20 — concatenated object key, `BELNR(10)+GJAHR(4)` for RMRP | DD03L + DDL (`OriginalReferenceDocument`) |

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `BSEG` | — (table) | — | **MANDT, BUKRS, BELNR, GJAHR, BUZEI** | DD03L |
| `BSEG` | `BUKRS` | `BUKRS` | KEY pos 2 | DD03L |
| `BSEG` | `BELNR` | `BELNR_D` | KEY pos 3 | DD03L |
| `BSEG` | `GJAHR` | `GJAHR` | KEY pos 4 | DD03L |
| `BSEG` | `BUZEI` | `BUZEI` | KEY pos 5, NUMC 3 | DD03L |
| `BSEG` | `AUGDT` | `AUGDT` | non-key pos 7, DATS 8 | DD03L |
| `BSEG` | `AUGBL` | `AUGBL` | non-key pos 9, CHAR 10 | DD03L |
| `BSEG` | `KOART` | `KOART` | non-key pos 11, CHAR 1 | DD03L |
| `BSEG` | `QSSKZ` | `QSSKZ` | non-key pos 21 — **classic** WHT code, not the extended one | DD03L |
| `BSEG` | `KTOSL` | `KTOSL` | non-key pos 43, CHAR 3 | DD03L |
| `BSEG` | `SGTXT` | `SGTXT` | non-key pos 51, CHAR 50 | DD03L |
| `BSEG` | `SAKNR` | `SAKNR` | non-key pos 96, CHAR 10 | DD03L |
| `BSEG` | `HKONT` | `HKONT` | non-key pos 97, CHAR 10 | DD03L |
| `BSEG` | `LIFNR` | `LIFNR` | non-key pos 99, CHAR 10 | DD03L |
| `BSEG` | `SECCO` | `SECCO` | non-key pos 305, CHAR 4, DE text "Section Code" | DD03L + DD04T |
| `BSEG` | `H_BUDAT` | `BUDAT` | non-key pos 346, DATS 8 — **exists**; population not guaranteed, see §2 | DD03L |
| `BSEG` | `H_BLDAT` | `BLDAT` | non-key pos 347, DATS 8 — **exists**; population not guaranteed, see §2 | DD03L |
| `BSEG` | `GKONT` | `GKONT` | non-key pos 362, CHAR 10, "Offsetting Account Number" — **a different field from GHKON** | DD03L + DD04T |
| `BSEG` | **`GHKON`** | **`GHKONT`** | **non-key pos 364, CHAR 10, domain `SAKNR`, "G/L Acct of Offsetting Acct in General Ledger Accounting"** | DD03L + DD04L/DD04T + syntax-check probe, 0 errors |

### 1.2 Withholding-tax configuration and India exemption tables

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `T059Z` | — (table) | — | **MANDT, LAND1, WITHT, WT_WITHCD** | DD03L, complete 16-row read |
| `T059Z` | `LAND1` | `LAND1` | KEY pos 2, CHAR 3 | DD03L |
| `T059Z` | `WITHT` | `WITHT` | KEY pos 3, CHAR 2 | DD03L |
| `T059Z` | `WT_WITHCD` | `WT_WITHCD` | KEY pos 4, CHAR 2 | DD03L |
| `T059Z` | `QSCOD` | `WT_OWTCD` | non-key pos 5, CHAR 4, "Official Withholding Tax Key" | DD03L + DD04T |
| `T059Z` | `QSATZ` | `WT_QSATZ` | non-key pos 7, DEC 7,4 | DD03L |
| `T059Z` | `TXT40` | — | **DOES NOT EXIST. T059Z has no text field of any kind.** Complete list: MANDT, LAND1, WITHT, WT_WITHCD, QSCOD, QPROZ, QSATZ, QSATR, XQFOR, REGIO, FPRCD, QEKAR, WT_POSIN, WT_RATEZ, WT_RATEN, WITHCD2 | DD03L, 16 rows, complete |
| `T059ZT` | `TEXT40` | `TEXT40` | non-key. Key = **MANDT, SPRAS, LAND1, WITHT, WT_WITHCD**. TABCLASS TRANSP. Text of the withholding tax **code** | DD03L + DD02L |
| `T059O` | `TEXT40` | `TEXT40` | non-key. Key = **MANDT, LAND1, `WT_QSCOD`**. Fields: MANDT, LAND1, WT_QSCOD, TEXT40, J_1ANATXCD | DD03L + DD02L |
| `T059OT` | `TEXT40` | `TEXT40` | non-key. Key = **MANDT, SPRAS, LAND1, `WT_QSCOD`**. Language-dependent text of the **official WHT key (= the section)** | DD03L + DD02L |

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `FIWTIN_TAN_EXEM` | — (table) | — | TABCLASS TRANSP. **10-field key: MANDT, BUKRS, KOART, ACCNO, FIWTIN_TANEX_SUB, SECCODE, WITHT, WT_WITHCD, WT_EXDF, PAN_NO** | DD03L ORDER BY POSITION + DD02L |
| `FIWTIN_TAN_EXEM` | `BUKRS` | `BUKRS` | KEY pos 2, CHAR 4 | DD03L |
| `FIWTIN_TAN_EXEM` | `KOART` | `KOART` | KEY pos 3, CHAR 1 | DD03L |
| `FIWTIN_TAN_EXEM` | `ACCNO` | `WT_ACNO` | KEY pos 4, CHAR 10 — **same DE as `WITH_ITEM-WT_ACCO`** | DD03L |
| `FIWTIN_TAN_EXEM` | `FIWTIN_TANEX_SUB` | `FIWTIN_TANEX_SUB` | KEY pos 5, CHAR 1 | DD03L |
| `FIWTIN_TAN_EXEM` | **`SECCODE`** | `SECCO` | KEY pos 6, CHAR 4 — **field is `SECCODE`, NOT `SECCO`** | DD03L + syntax-check probe, 0 errors |
| `FIWTIN_TAN_EXEM` | `WITHT` | `WITHT` | KEY pos 7, CHAR 2 | DD03L |
| `FIWTIN_TAN_EXEM` | `WT_WITHCD` | `WT_WITHCD` | KEY pos 8, CHAR 2 | DD03L |
| `FIWTIN_TAN_EXEM` | `WT_EXDF` | `WT_EXDF` | **KEY** pos 9, DATS 8, domain `WT_START`, "Date on Which Exemption Begins" | DD03L + DD04T |
| `FIWTIN_TAN_EXEM` | `PAN_NO` | `J_1IPANNO` | KEY pos 10, CHAR 40 — the **last** key field | DD03L |
| `FIWTIN_TAN_EXEM` | `WT_EXDT` | `WT_EXDT` | non-key pos 11, DATS 8, domain `WT_END`, "Date on Which Exemption Ends" | DD03L + DD04T |
| `FIWTIN_TAN_EXEM` | `WT_EXNR` | `WT_EXNR` | non-key pos 12, CHAR 25, "Exemption Certificate Number" | DD03L + DD04T |
| `FIWTIN_TAN_EXEM` | `WT_EXRT` | `WT_EXRT` | non-key pos 13, DEC 5,2 — exemption rate | DD03L |
| `FIWTIN_TAN_EXEM` | `WT_WTEXRS` | `WT_WTEXRS` | non-key pos 14, CHAR 2 — exemption reason | DD03L |
| `FIWTIN_TAN_EXEM` | **`FIWTIN_EXEM_THR`** | **`FIWTIN_EXEM_THR`** | non-key pos 15, CURR 23,2. **It is BOTH a field of this table AND a data element of the identical name.** Domain `AFLE15D2O21S_TO_23D2O31S`, "Threshold amount for Exemption (India)". **Currency reference = `T001-WAERS`**, not this table's own `WAERS` | DD03L (REFTABLE=T001, REFFIELD=WAERS) + DD04L/DD04T |
| `FIWTIN_TAN_EXEM` | `WAERS` | `WAERS` | non-key pos 16, CUKY 5. Exists but is **not** the DDIC currency reference for `FIWTIN_EXEM_THR`. 16 fields total, list complete | DD03L |

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `FIWTIN_ACC_EXEM` | — (table) | — | TABCLASS TRANSP. **9-field key: MANDT, BUKRS, ACCNO, WITHT, WT_WITHCD, SECCO, WT_DATE, KOART, PAN_NO.** Exactly one non-key field | DD03L ORDER BY POSITION + DD02L |
| `FIWTIN_ACC_EXEM` | `BUKRS` | `BUKRS` | KEY pos 2, CHAR 4 | DD03L |
| `FIWTIN_ACC_EXEM` | `ACCNO` | `WT_ACNO` | KEY pos 3, CHAR 10 | DD03L |
| `FIWTIN_ACC_EXEM` | `WITHT` | `WITHT` | KEY pos 4, CHAR 2 | DD03L |
| `FIWTIN_ACC_EXEM` | `WT_WITHCD` | `WT_WITHCD` | KEY pos 5, CHAR 2 | DD03L |
| `FIWTIN_ACC_EXEM` | **`SECCO`** | `SECCO` | KEY pos 6, CHAR 4 — **field is `SECCO` here, NOT `SECCODE`** | DD03L |
| `FIWTIN_ACC_EXEM` | `WT_DATE` | `WT_VALID` | KEY pos 7, DATS 8 — the accumulation is date-keyed | DD03L |
| `FIWTIN_ACC_EXEM` | `KOART` | `KOART` | KEY pos 8, CHAR 1 | DD03L |
| `FIWTIN_ACC_EXEM` | `PAN_NO` | `J_1IPANNO` | KEY pos 9, CHAR 40 | DD03L |
| `FIWTIN_ACC_EXEM` | `ACC_AMT` | `WT_BS` | **non-key** pos 10, CURR 23,2. **Currency reference = `T001-WAERS`** | DD03L (REFTABLE=T001, REFFIELD=WAERS) |

### 1.3 Master data, chart of accounts, MM chain

| Object | Field | Data element | Key | Evidence |
|---|---|---|---|---|
| `LFA1` | — (table) | — | **MANDT, LIFNR** | DD03L |
| `LFA1` | `LIFNR` | `LIFNR` | KEY pos 2, CHAR 10 | DD03L |
| `LFA1` | `LAND1` | `LAND1_GP` | non-key pos 3, CHAR 3 — **DE is `LAND1_GP`**, unlike `T001-LAND1` (DE `LAND1`) | DD03L |
| `LFA1` | `NAME1` | `NAME1_GP` | non-key pos 4, CHAR 35 | DD03L |
| `LFA1` | `STCD3` | `STCD3` | non-key pos 83, CHAR 18 — GSTIN, **not** a PAN source | DD03L |
| `LFA1` | `J_1IPANNO` | `J_1IPANNO` | non-key pos 189, **CHAR 40** (domain `CHAR40`) — **not CHAR 10**. Same DE as `FIWTIN_*.PAN_NO`, so the PAN join needs no conversion | DD03L + DD04L |
| `SKA1` | — (table) | — | **MANDT, KTOPL, SAKNR** (`KTOPL` comes first) | DD03L ORDER BY POSITION |
| `SKA1` | `KTOPL` | `KTOPL` | KEY pos 2, CHAR 4 | DD03L |
| `SKA1` | `SAKNR` | `SAKNR` | KEY pos 3, CHAR 10 | DD03L |
| `SKA1` | `TXT50` | — | **DOES NOT EXIST. SKA1 has no text field.** Complete 23-position list: MANDT, KTOPL, SAKNR, XBILK, SAKAN, .INCLUDE, BILKT, ERDAT, ERNAM, GVTYP, KTOKS, MUSTR, VBUND, XLOEV, XSPEA, XSPEB, XSPEP, MCOD1, FUNC_AREA, GLACCOUNT_TYPE, GLACCOUNT_SUBTYPE, MAIN_SAKNR, LAST_CHANGED_TS | DD03L, complete |
| `SKAT` | `TXT50` | `TXT50_SKAT` | non-key pos 6, CHAR 50. Key = **MANDT, SPRAS, KTOPL, SAKNR** — `SPRAS` is mandatory | DD03L + DD04L + syntax-check probe, 0 errors |
| `SKAT` | `TXT20` | `TXT20_SKAT` | non-key, CHAR 20 | DD03L |
| `T001` | — (table) | — | **MANDT, BUKRS** | DD03L |
| `T001` | `BUKRS` | `BUKRS` | KEY pos 2, CHAR 4 | DD03L |
| `T001` | `LAND1` | `LAND1` | non-key pos 5, CHAR 3 — feeds the `T059Z`/`T059ZT`/`T059O`/`T059OT` key | DD03L |
| `T001` | `WAERS` | `WAERS` | non-key pos 6, CUKY 5 — the DDIC currency reference for **both** FIWTIN amount fields | DD03L + REFTABLE/REFFIELD on both FIWTIN tables |
| `T001` | `KTOPL` | `KTOPL` | non-key pos 8, CHAR 4 — **use this instead of the literal `'ASTL'`** | DD03L |
| `RSEG` | — (table) | — | **MANDT, BELNR, GJAHR, BUZEI** | DD03L ORDER BY POSITION |
| `RSEG` | `BELNR` | `BELNR_D` | KEY pos 2, CHAR 10 | DD03L |
| `RSEG` | `GJAHR` | `GJAHR` | KEY pos 3, NUMC 4 | DD03L |
| `RSEG` | `BUZEI` | **`RBLGP`** | KEY pos 4, **NUMC 6** — **not** NUMC 3 / DE `BUZEI` as on BSEG and WITH_ITEM | DD03L |
| `RSEG` | `EBELN` | `EBELN` | non-key pos 5, CHAR 10 | DD03L |
| `RSEG` | `EBELP` | `EBELP` | non-key pos 6, NUMC 5 | DD03L |
| `RSEG` | `ZEKKN` | `DZEKKN` | non-key pos 7, NUMC 2 — completes the `EKKN` key | DD03L |
| `RSEG` | `MATNR` | `MATNR` | non-key pos 8, CHAR 40 | DD03L |
| `RSEG` | `BWKEY` | `BWKEY` | non-key pos 9, CHAR 4 — **RSEG carries the valuation area natively** | DD03L |
| `RSEG` | `BWTAR` | `BWTAR_D` | non-key pos 10, CHAR 10 | DD03L |
| `RSEG` | **`BUKRS`** | `BUKRS` | **non-key pos 11, CHAR 4 — RSEG-BUKRS EXISTS.** `BUILD_BRIEF` D4 item 4 is wrong | DD03L + syntax-check probe, 0 errors |
| `RSEG` | `WERKS` | `WERKS_D` | non-key pos 12, CHAR 4 | DD03L |
| `RSEG` | `BKLAS` | `BKLAS` | non-key pos 26, CHAR 4 — **RSEG carries the valuation class natively** (value at invoice time) | DD03L |
| `EKKN` | — (table) | — | **MANDT, EBELN, EBELP, ZEKKN** | DD03L |
| `EKKN` | `EBELN` | `EBELN` | KEY pos 2, CHAR 10 | DD03L |
| `EKKN` | `EBELP` | `EBELP` | KEY pos 3, NUMC 5 | DD03L |
| `EKKN` | `ZEKKN` | `DZEKKN` | KEY pos 4, NUMC 2 | DD03L |
| `EKKN` | `SAKTO` | `SAKNR` | non-key pos 11, CHAR 10 | DD03L + syntax-check probe, 0 errors |
| `MBEW` | — (table) | — | **MANDT, MATNR, BWKEY, BWTAR** | DD03L |
| `MBEW` | `MATNR` | `MATNR` | KEY pos 2, CHAR 40 | DD03L |
| `MBEW` | `BWKEY` | `BWKEY` | KEY pos 3, CHAR 4 | DD03L |
| `MBEW` | `BWTAR` | `BWTAR_D` | KEY pos 4, CHAR 10 — part of the key even when blank | DD03L |
| `MBEW` | `LVORM` | — | non-key pos 6 — deletion flag | DD03L |
| `MBEW` | `BKLAS` | `BKLAS` | non-key pos 14, CHAR 4 | DD03L |
| `T030` | — (table) | — | **6-field key: MANDT, KTOPL, KTOSL, BWMOD, KOMOK, BKLAS.** Complete field list: MANDT, KTOPL, KTOSL, BWMOD, KOMOK, BKLAS, KONTS, KONTH | DD03L, complete, 8 rows |
| `T030` | `KTOPL` | `KTOPL` | KEY pos 2, CHAR 4 | DD03L |
| `T030` | `KTOSL` | `KTOSL` | KEY pos 3, CHAR 3 | DD03L |
| `T030` | `BWMOD` | `BWMOD` | KEY pos 4, CHAR 4 — **the FS never mentions it** | DD03L |
| `T030` | `KOMOK` | `KOMOK` | KEY pos 5, CHAR 3 — **the FS never mentions it** | DD03L |
| `T030` | `BKLAS` | `BKLAS` | KEY pos 6, CHAR 4 | DD03L |
| `T030` | `KONTS` | `SAKNR` | non-key pos 7, CHAR 10 — debit account | DD03L |
| `T030` | `KONTH` | `SAKNR` | non-key pos 8, CHAR 10 — credit account | DD03L |

### 1.4 CDS views (read but NOT used — D1 keeps the build on base tables)

| Object | Element | Note | Evidence |
|---|---|---|---|
| `I_WithholdingTaxItem` | — | EXISTS. DDLS/DF, package `FINS_FIS_APAR`, sqlViewName `IFIWTAXITEM`, `select from with_item`. **Carries `where wt_withcd != ''`.** A DCLS access-control object of the same name exists | `searchObject` + `getObjectSource` |
| `I_WithholdingTaxItem` | `CompanyCode`,`AccountingDocument`,`FiscalYear`,`AccountingDocumentItem`,`WithholdingTaxType` | the five KEY elements = bukrs, belnr, gjahr, buzei, witht | DDL source + syntax check |
| `I_WithholdingTaxItem` | `WithholdingTaxCode` / `CustomerSupplierAccount` / `WhldgTaxBaseAmtInCoCodeCrcy` / `WhldgTaxAmtInCoCodeCrcy` / `WithholdingTaxPercent` | = wt_withcd / wt_acco / wt_qsshh / wt_qbshh / qsatz. **Every CDS name the FS quotes is correct** | DDL source + syntax check |
| `I_WithholdingTaxItem` | `PostingDate`, `SectionCode` | **DO NOT EXIST.** Also absent: `hkont_opp`, the `WT_ACC*` accumulation fields, the India appends | complete DDL read |
| `I_JournalEntry` | — | EXISTS. DDLS/DF, package `FINS_FIS_FICO`, sqlViewName `IFIJOURNALENT`, defined over **`P_BKPF_COM`**, not `BKPF`. Keys: CompanyCode, FiscalYear, AccountingDocument | `searchObject` + `getObjectSource` |
| `I_JournalEntry` | `PostingDate`/`DocumentDate`/`DocumentReferenceID`/`ReferenceDocumentType`/`OriginalReferenceDocument` | = budat / bldat / xblnr / awtyp / awkey | DDL source + syntax check |

---

## 2. UNVERIFIED

Nothing here may be coded without an `" ASSUMPTION:` line and a `docs/QUERIES.md` row.
"Why" is the honest reason; "check" is the exact navigation for Arnav.

### 2.1 Names never read from DD03L (asserted only by `recon:fs-contract`, which has no system access)

| Object | Field | Why it could not be confirmed | What Arnav should check |
|---|---|---|---|
| `T001K` | `BWMOD` | The ADT recon never read `T001K`. `T001K` is the only route to the `T030` key field `BWMOD`, and the FS never mentions it | SE11 → `T001K` → field list. Confirm `BWKEY`, `BUKRS`, `BWMOD` exist and that `BWMOD` is the valuation grouping code |
| `T001W` | `BWKEY` | Never read. **The build does not need it** — `RSEG-BWKEY` is confirmed and used instead. Listed only so nobody reintroduces it | SE11 → `T001W`. Only relevant if the `RSEG-BWKEY` route is ever abandoned |
| `RBKP` | `BUKRS` | Never read. **The build does not need it** — `RSEG-BUKRS` is confirmed. Listed only to close out `BUILD_BRIEF` D4 item 4 | Not required |
| `RSEG` | `WRBTR` | Never read. Only consumer would be the "largest amount wins" tie-break offered as an alternative in fs-contract A13 — **not implemented** | SE11 → `RSEG`, only if Ankita picks the largest-amount tie-break |
| `BSEG` | `SHKZG`, `DMBTR`, `WRBTR` | Never read by this recon. They are universally present on BSEG, but this sheet does not certify anything it did not read | SE11 → `BSEG`. Only needed if the fs-contract A30 heuristic (largest `\|DMBTR\|` `KOART='S'` line) is ever adopted — **it is not**, see §3 D-13 |
| `LFBW` | all | Never read. fs-contract A19 proposes it as the vendor-master fallback for cols U/V/W/X because FS [U6] says "vendor master" while FS [U2] says `FIWTIN_TAN_EXEM` | SE11 → `LFBW`. Confirm key `MANDT, LIFNR, BUKRS, WITHT` and which fields carry exemption number/dates/rate. **Ask Ankita first — do not build it speculatively** |
| `BKPF` | `BKTXT`, `STGRD`, `BLART`, `WAERS` | Never read individually. `BKTXT` is the "header text" fs-contract cites for the FS [J6] reading of col J — **not implemented**, D5 pins `BSEG-SGTXT` | SE11 → `BKPF`, only if Ankita reverses the col J decision |
| `CL_SALV_COLUMN_LIST` | `SET_CURRENCY_COLUMN` | Method name never verified on this release (flagged by `recon:repo-style`) | SE24 → `CL_SALV_COLUMN_LIST` → Methods. Not needed if `ty_output` carries its own `WAERS` component, which is what §3 D-16 pins |

### 2.2 Names confirmed to EXIST, but whose POPULATION in the Astral target is unknown

Existence came from the scratch rig. Population is a data question no rig can answer.

| Object | Field | Why it could not be confirmed | What Arnav should check |
|---|---|---|---|
| `BSEG` | `GHKON` | Field definitively exists (pos 364). Whether Astral's postings fill it is data, and the rig is not the target. **This is the single highest-impact unknown in the build** — cols F and G depend on it for every direct FI posting | SE16N → `BSEG`, filter a known TDS document (`BUKRS`/`BELNR`/`GJAHR`, `KTOSL = 'WIT'`), read `GHKON` and `GKONT`. If `GHKON` is empty and `GKONT` is filled, tell the build agents — the switch is one field name |
| `BSEG` | `H_BUDAT`, `H_BLDAT` | Both exist (pos 346/347) but are propagated header dates, not core line-item fields; they are known to be blank in many posting paths. The build uses `BKPF-BUDAT`/`BKPF-BLDAT` instead (§3 D-6) | SE16N → `BSEG` on any document; compare `H_BUDAT` with `BKPF-BUDAT`. Informational only — the build does not depend on them |
| `LFA1` | `J_1IPANNO` | Exists at pos 189, CHAR 40. Whether Astral maintains PAN there (rather than in a Z field or `STCD3`) is data. A wrong choice silently blanks cols E **and** U/V/W/X/Y together | SE16 → `LFA1` for two or three known TDS vendors; check `J_1IPANNO` and, for contrast, `STCD3`. A column-wide blank is a defect; scattered blanks are normal |
| `WITH_ITEM` | `HKONT_OPP` | Exists at pos 33 but is not exposed by the CDS view and is not universally filled. Offered as a shortcut for col F | SE16N → `WITH_ITEM` for a known TDS document; is `HKONT_OPP` filled? If yes it is a cheaper col F than the whole GLCode tree |
| `WITH_ITEM` | `WT_ACCBS`, `WT_ACCWT` | Exist (pos 47/48). Candidate alternative source for col Y that avoids `FIWTIN_ACC_EXEM` entirely | SE16N → `WITH_ITEM`; compare `WT_ACCBS` against `FIWTIN_ACC_EXEM-ACC_AMT` for the same vendor |
| `T059O` / `T059OT` | `TEXT40` | Tables and field exist. Whether Astral maintains official WHT keys (194C, 194J …) is config. If unmaintained, col I is blank for every row | SE16 → `T059O` with `LAND1 = 'IN'`. Also SE16 → `T059Z` and check whether `QSCOD` is filled at all — if `QSCOD` is blank, cols H **and** I are both blank and that is config, not a bug |
| `T001` | `KTOPL` for BUKRS 1000/4000 | Whether both company codes really use chart `ASTL` is data | SE16 → `T001`, `BUKRS` = 1000 and 4000, read `KTOPL` and `LAND1`. The code reads `T001` regardless, so this is a sanity check, not a dependency |
| any | customer append fields | Appends on the target's `BSEG`, `LFA1`, `WITH_ITEM`, `RSEG` are invisible from the scratch rig | Only matters if a required value turns out to live in a Z field. SE11 → table → Append structures tab |

### 2.3 Structural facts the DDIC confirms but that leave a functional question open

| Object | Field | Why it could not be confirmed | What Arnav should check |
|---|---|---|---|
| `T030` | `BWMOD`, `KOMOK` | Both are key fields; the FS supplies neither, so the read is **not unique** and can return several `KONTS`. The DDIC cannot say what values apply | Ask Bhavin Suthar: is a valuation grouping code active (OMWM)? Is `KOMOK` ever non-blank for `KTOSL = 'BSX'`? Until answered, §3 D-11 pins a non-selective read plus in-ABAP resolution |
| `EKKN` | `ZEKKN` multiplicity | A PO item can carry several account assignments, so "EKKN is not blank → get SAKTO" is ambiguous. `RSEG-ZEKKN` exists and would pin it exactly | Ask Ankita: is the invoice's `RSEG-ZEKKN` the intended link? §3 D-12 pins that |
| `FIWTIN_ACC_EXEM` | `WT_DATE` | `WT_DATE` is a key field, so a PAN has many accumulation rows. "Cumulative as of now for FY" does not say which row or whether to sum | Ask Ankita. §3 D-14 pins "latest `WT_DATE`" as the default |
| `WITH_ITEM` | currency reference of the `CURR` fields | The recon did not report a `REFTABLE`/`REFFIELD` for `WT_QSSHH` / `WT_QBSHH`, and `WITH_ITEM` has no `CUKY` field in its 94 positions | SE11 → `WITH_ITEM` → `WT_QSSHH` → Currency/quantity fields tab. Immaterial if `ty_output` carries its own `WAERS` from `T001` (§3 D-16) |
| `BKPF` | `STBLG` / `BSTAT` handling | Fields exist; the FS is silent on excluding reversed or parked documents from a compliance report | Ask Ankita. §3 D-15 pins "include everything, no filter" and flags it loudly |
| `WITH_ITEM-BUZEI` semantics | — | The build joins `BSEG` on `BUZEI = WITH_ITEM-BUZEI` on the premise that the WHT item points at the **vendor line**. That is standard behaviour but it is a semantic assumption, not a DDIC fact | SE16N → pick one TDS document, list `WITH_ITEM` rows and the matching `BSEG-BUZEI`; confirm `KOART = 'K'` and `LIFNR` filled on that line |

---

## 3. DECISIONS

The exact name the build uses, and why. These are binding. Where a decision overrides
`BUILD_BRIEF.md`, `FS_EXTRACT.md` or a recon report, that is stated.

**D-1 · `BSEG-GHKON` — the FS name is correct. Use `BSEG-GHKON`.**
`BUILD_BRIEF` D4 item 1 is **RESOLVED**. `GHKON` exists at position 364, data element
`GHKONT`, CHAR 10, domain `SAKNR`, "G/L Acct of Offsetting Acct in General Ledger
Accounting". A syntax-check probe naming it returned zero errors. `BSEG-GKONT` (pos 362,
DE `GKONT`, "Offsetting Account Number") is a **different field** — do not substitute one
for the other, and do not "helpfully" code `GKONT` because it looks similar. The GLCode
Logic tab means `GHKON`.
*Declare the output component as `TYPE bseg-hkont`* (DE `HKONT`, domain `SAKNR`, CHAR 10)
so the output structure survives even if `GHKON` ever has to be swapped out; assignment
between the two is domain-identical.

**D-2 · `RSEG-BUKRS` exists. `BUILD_BRIEF` D4 item 4 is WRONG and is hereby corrected.**
Position 11, non-key, CHAR 4, DE `BUKRS`. The FS's GLCode instruction "company code in
BUKRS" of RSEG works exactly as written. **No `RBKP` detour.** `recon:fs-contract` step
4.2 (read `RBKP`, validate `RBKP-BUKRS`) is discarded — it was built on the brief's false
premise. Read `RSEG` by `BELNR`, `GJAHR` **and** `BUKRS`.

**D-3 · Col P (Base Amount) = `WITH_ITEM-WT_QSSHH`. Col T (TDS Amount) = `WITH_ITEM-WT_QBSHH`.**
`recon:fs-contract` proposed `WT_QSSHB` / `WT_QBSHB` and called this "the worst failure
mode in this report". It had the suffix backwards. Two independent readings settle it:
DD03L gives `WT_QSSHH` DE `WT_BS` versus `WT_QSSHB` DE `WT_BS1`, and the
`I_WithholdingTaxItem` DDL maps `WhldgTaxBaseAmtInCoCodeCrcy` → `wt_qsshh` and
`WhldgTaxAmtInCoCodeCrcy` → `wt_qbshh`. The FS asks for company-code currency, so the
`HH` suffix is right and the `HB` suffix (transaction currency) is wrong. **Suffix `HH` =
company-code currency. Suffix `HB` = document/transaction currency.**

**D-4 · Col S (TDS Rate deducted) = `WITH_ITEM-QSATZ`. No computed fallback.**
`WITH_ITEM` does carry a rate column: pos 59, DEC 7,4, DE `WT_QSATZ`, mapped by the CDS
as `WithholdingTaxPercent` — the exact element the FS names. `recon:fs-contract` A23's
`tax / base * 100` fallback is **not implemented**; it was proposed only because that
agent could not confirm the column existed. Note `WITH_ITEM-QSATZ` and `T059Z-QSATZ`
share DE `WT_QSATZ`, so cols R and S are type-identical but come from different tables —
do not collapse them.

**D-5 · Col I (Section Code Description) = `T059OT-TEXT40`. The field is `TEXT40`, never `TXT40`.**
FS [I2] says "provide `WT_WITHCD` in `T059Z` and get `TXT40`". **That is impossible**:
`T059Z`'s complete 16-field list contains no text field at all. Two candidates exist:
`T059ZT-TEXT40` (text of the tax **code**, key MANDT/SPRAS/LAND1/WITHT/WT_WITHCD) and
`T059OT-TEXT40` (text of the **official WHT key**, i.e. the section, key
MANDT/SPRAS/LAND1/WT_QSCOD). Col H is the `QSCOD` itself and the heading is "Section Code
**Description**", so the description of a section is `T059OT`. **Pinned: `T059OT-TEXT40`,
read with `SPRAS = sy-langu`, `LAND1 = T001-LAND1`, `WT_QSCOD` = the value shown in col H.
Blank when not maintained — no silent fallback to `T059ZT`**, because mixing two different
meanings in one column is worse than a blank. `T059ZT-TEXT40` is offered to Ankita in
QUERIES as the alternative reading.
Note the key-field name trap: the official key is field **`QSCOD`** in `T059Z` but field
**`WT_QSCOD`** in `T059O`/`T059OT`.

**D-6 · Cols K and M = `BKPF-BUDAT` and `BKPF-BLDAT`, not `BSEG-H_BUDAT` / `H_BLDAT`.**
`recon:fs-contract` claimed `H_BUDAT`/`H_BLDAT` "are not BSEG columns". **That claim is
false** — the live read has them at positions 346 and 347. But existence is not
population: they are propagated header dates, commonly blank, whereas `BKPF-BUDAT` and
`BKPF-BLDAT` are already in the driver join and always filled. **Use BKPF. Zero extra
cost, one less unknown.** Keep the FS heading wording; the heading/content mismatch
(col K reads "Document Date (SAP)" but carries the posting date) goes to QUERIES, not
into the code.

**D-7 · Col G (GL Name) = `SKAT-TXT50`, key `SPRAS = sy-langu`, `KTOPL = T001-KTOPL`, `SAKNR` = derived GL.**
FS [G2] is wrong twice. `SKA1` has **no** `TXT50` and no text field of any kind (complete
23-position list read). And `'ASTL'` must not be hardcoded — `T001-KTOPL` exists at
position 8, and `CLAUDE.md` forbids hardcoded company-code-dependent config. The `SKA1`
read is dropped entirely; it would only add existence validation nobody asked for.
DE is `TXT50_SKAT`, CHAR 50.

**D-8 · The RMRP branch tests `BKPF-AWTYP = 'RMRP'`, not `AWKEY`.**
FS "GLCode Logic" [B6]/[M6] say "records having AWKEY as RMRP". `AWKEY` is CHAR 20 and
holds the concatenated object key; `AWTYP` (CHAR 5, pos 37) is the field that holds the
literal `RMRP`. The companion instruction *is* right: for `AWTYP = 'RMRP'`,
`AWKEY+0(10)` is the invoice `BELNR` and `AWKEY+10(4)` is the `GJAHR`. Guard: if
`AWTYP = 'RMRP'` but `AWKEY` is initial, or `AWKEY+10(4)` is not numeric, fall back to
`BKPF-GJAHR` and, failing that, to the non-RMRP path with a message-list entry.

**D-9 · `T059Z` / `T059ZT` / `T059O` / `T059OT` are read on their FULL key, never on `WT_WITHCD` alone.**
`T059Z`'s key is MANDT, LAND1, WITHT, WT_WITHCD. Supply `LAND1` from `T001-LAND1` of the
document's company code and `WITHT` from `WITH_ITEM-WITHT`. Reading on `WT_WITHCD` alone
cross-joins countries and tax types and will silently return the wrong rate.

**D-10 · The valuation-area route uses `RSEG-BWKEY`. `T001W` is not read.**
FS [H27] says `BWKEY = RSEG-WERKS`, which only holds when the valuation level is plant.
`RSEG` carries `BWKEY` natively at position 9 — use it. This also removes `T001W-BWKEY`
(an UNVERIFIED name) from the build entirely.
`MBEW` is still read for `BKLAS` per the FS, on its full key MATNR + BWKEY + BWTAR, with
one retry at `BWTAR = space` when a filled `BWTAR` finds nothing. **`RSEG-BKLAS` (pos 26)
exists and would skip `MBEW` altogether — do NOT take that shortcut unilaterally.**
`RSEG-BKLAS` is the valuation class at invoice time and `MBEW-BKLAS` is current master
data; they can diverge. It is a QUERIES item, not a build decision.

**D-11 · The `T030` read is NOT selective on `BWMOD`/`KOMOK` at SQL level.**
`T030`'s key has six fields; the FS supplies three (`KTOPL`, `KTOSL = 'BSX'`, `BKLAS`).
Because `T001K-BWMOD` is UNVERIFIED (§2.1), the build must **not** compile against
`T001K` yet. Pinned: select `BWMOD, KOMOK, BKLAS, KONTS` from `T030` for the distinct
(`KTOPL`, `KTOSL='BSX'`, `BKLAS`) set, then resolve in ABAP — prefer the row with
`KOMOK = space` and `BWMOD = space`; if none, take the lowest `BWMOD`/`KOMOK` sort order
and add the document to the ambiguous-GL message list. `KONTS` (pos 7) is the debit
account and is the one the FS wants; `KONTH` (pos 8) is the credit account.

**D-12 · `EKKN` is read on its full key `EBELN`, `EBELP`, `ZEKKN`, with `ZEKKN` from `RSEG-ZEKKN`.**
`RSEG-ZEKKN` exists (pos 7, NUMC 2), which makes the read exact instead of returning
every account assignment for the PO item. Refined test, per `recon:fs-contract` 4.5.2:
"EKKN is not blank" means **a row exists whose `SAKTO` is filled**, not merely that a row
exists. If `RSEG-ZEKKN` is initial, fall back to the lowest `ZEKKN` and log.

**D-13 · No heuristic GL guess. Ever.**
`recon:fs-contract` A30 offers a fallback of "the `KOART = 'S'` line with the largest
`|DMBTR|`, lowest `BUZEI` as tie-break". **Not implemented.** It is a heuristic, not a
rule the FS gave, and it would put a plausible-looking wrong GL on a compliance report —
the worst possible failure. When the tree yields nothing, cols F and G stay **blank**,
the document goes into the message list, and one aggregated information message is
issued after the ALV is built ("GL could not be derived for n document(s)"). This
satisfies `CLAUDE.md`'s "error paths give the user a message" without inventing data.
It also removes `BSEG-SHKZG`/`DMBTR` (UNVERIFIED, §2.1) from the build.

**D-14 · Col Y = `FIWTIN_ACC_EXEM-ACC_AMT`, row with the latest `WT_DATE`.**
The key is nine fields including `WT_DATE` and `SECCO`, so a PAN has many rows and the
FS's "get ACC_AMT" is not a unique read. Pinned default: restrict by `BUKRS`, `ACCNO`
(= `WITH_ITEM-WT_ACCO`), `WITHT`, `WT_WITHCD`, `KOART`, `PAN_NO`, then take the row with
the **highest `WT_DATE`** that is `<=` the upper bound of the posting-date selection. Do
not sum — the table already accumulates, and summing would double-count. `SECCO` is left
unrestricted in the read and the highest-`WT_DATE` row wins across section codes; if that
proves wrong, restricting it is a one-line change. Flag hard in QUERIES:
`WITH_ITEM-WT_ACCBS` may be the better source and needs Ankita's call.

**D-15 · Cols U/V/W/X = `FIWTIN_TAN_EXEM`, disambiguated exactly as `BUILD_BRIEF` D5 says. The DDIC supports that rule precisely.**
`WT_EXDF` (valid-from) **is** a key field and `WT_EXDT` (valid-to) is not, and `WITHT` and
`WT_WITHCD` are both key fields. So D5's rule becomes a key-level filter, not a
post-filter: `WT_EXDF <= BKPF-BUDAT AND WT_EXDT >= BKPF-BUDAT`, matching the document's
`WITHT` and `WT_WITHCD`; if several remain, `MAX( WT_EXDF )`.
`PAN_NO` is the **last** of ten key fields, so a read by PAN alone is an unindexed scan —
supply `BUKRS`, `KOART`, `ACCNO` and `PAN_NO` as well.
Field names: `WT_EXDF` (col U), `WT_EXDT` (col V), `FIWTIN_EXEM_THR` (col W),
`WT_EXNR` (col X). **`FIWTIN_EXEM_THR` is both a field of this table and a data element
of the identical name** — `BUILD_BRIEF` D4 item 3 is RESOLVED, it is a field, and you may
write `TYPE fiwtin_tan_exem-fiwtin_exem_thr`.
**The section field on this table is `SECCODE`, not `SECCO`** — its sister table
`FIWTIN_ACC_EXEM` uses `SECCO` for the same data element. Getting that backwards costs an
activation cycle.
Col X alternative (`WITH_ITEM-WT_WTEXMN`, same DE `WT_EXNR`, the certificate recorded on
the document) is **not** implemented — the FS names the master-data table — but it is a
QUERIES row, because it would avoid the whole disambiguation problem for that one column.
Do not use `WITH_ITEM-CTNUMBER` for col X: it is CHAR 10 and a different concept.
`LFBW` is **not** built (§2.1) until Ankita rules on the FS [U6] "vendor master" wording.

**D-16 · One `WAERS` component in `ty_output`, sourced from `T001-WAERS` of the row's company code.**
Four output components are `CURR`: `BASE_AMT`, `TDS_AMT`, `THRESHOLD`, `CUM_AMT`. Both
FIWTIN amounts reference `T001-WAERS` in DDIC (verified via REFTABLE/REFFIELD), and the
`WITH_ITEM` amounts are company-code-currency amounts, so a single `waers TYPE t001-waers`
component covers all four and is correct for every one. Without a currency component in
the structure the ALV can dump on the `CURR` fields. `set_currency_column( )` is
UNVERIFIED on this release (§2.1) — do not reach for it.
The contract stays at **25 columns**; `waers` is a structure component that is **not**
added to the ALV as a visible column (`set_visible( abap_false )` or simply no
`PERFORM txt` call plus an explicit hide).

**D-17 · Col C (Vendor Code) = `WITH_ITEM-WT_ACCO`, with `WITH_ITEM-KOART = 'K'`.**
This is the FS's own source (`CUSTOMERSUPPLIERACCOUNT` → `wt_acco`, confirmed by the CDS
DDL), it sits on the driver table so it does not depend on the `BSEG` `BUZEI` semantic
assumption, and — decisively — it shares data element `WT_ACNO` with
`FIWTIN_TAN_EXEM-ACCNO` and `FIWTIN_ACC_EXEM-ACCNO`, so the exemption joins are
type-clean with no conversion. `recon:fs-contract` preferred `BSEG-LIFNR`; overruled, but
`BSEG-LIFNR` remains available on the joined vendor line as a cross-check.
`WT_ACCO` (CHAR 10) feeds the `LFA1-LIFNR` read directly — same length, no conversion.
The `KOART = 'K'` filter keeps customer withholding out, which the "Vendor Code / Vendor
Name / Vendor PAN" headings require.

**D-18 · `WITH_ITEM` row granularity: the real key is six fields, not seven.**
`BUILD_BRIEF` D2 lists (BUKRS, BELNR, GJAHR, BUZEI, WITHT, WT_WITHCD). **`WT_WITHCD` is
not a key field** — the true key is MANDT, BUKRS, BELNR, GJAHR, BUZEI, WITHT. Row counts
are unaffected, but every `SORT` and `DELETE ADJACENT DUPLICATES` must compare the **real**
key, per `CLAUDE.md`. Keep `WT_WITHCD` in the output row; do not use it as a uniqueness
field.

**D-19 · D1 stands, with one behavioural difference now quantified.**
`I_WithholdingTaxItem` is `select from with_item` **plus `where wt_withcd != ''`**. A
base-table build must add `AND wt_withcd <> @space` to reproduce the FS's stated row set.
That is the *only* projection difference. Separately, the CDS path is access-control
filtered (a DCLS object of the same name exists) while a raw `WITH_ITEM` select is not —
authorization behaviour differs. Both facts belong in the TS and in QUERIES.
D1 is otherwise vindicated: the CDS path could never have delivered the full FS anyway,
since `I_WithholdingTaxItem` exposes neither `HKONT_OPP` (col F shortcut) nor the
`WT_ACC*` fields (col Y) nor the India appends, and exposes **no posting date and no
section code** at all.

**D-20 · Section Code: input filter is `BSEG-SECCO`; output col H is `T059Z-QSCOD`.**
`BUILD_BRIEF` D5 pinned this and the DDIC confirms it is the only workable split:
`BSEG-SECCO` exists (pos 305, CHAR 4, DE text "Section Code") and **`WITH_ITEM` carries no
section code and no posting date at all**. So both the section-code filter and the
mandatory posting-date filter force the `BSEG`/`BKPF` reads — a `WITH_ITEM`-only read
cannot satisfy the FS's own mandatory filter.

**D-21 · No reversal / parked-document filter.**
`BKPF-STBLG` (pos 21) and `BKPF-BSTAT` (pos 28) exist, and the FS says nothing about
either. Pinned: **include everything, filter nothing**, because a reversal carries its own
`WITH_ITEM` rows that net the original to zero and suppressing either side distorts the
totals. Flag loudly in QUERIES — for a compliance report this genuinely needs Ankita's
decision, and it is a decision, not an assumption to bury.

**D-22 · Three field-name traps, restated because each costs a real activation cycle.**
1. `FIWTIN_TAN_EXEM-`**`SECCODE`** vs `FIWTIN_ACC_EXEM-`**`SECCO`** — same DE, different
   field names on sister tables.
2. `T059Z-`**`QSCOD`** vs `T059O`/`T059OT-`**`WT_QSCOD`** — same concept, different field
   names.
3. `RSEG-BUZEI` is **NUMC 6, DE `RBLGP`** — never `TYPE buzei`, never moved into a
   `BSEG-BUZEI` or `WITH_ITEM-BUZEI` field without thought.
And the text field is **`TEXT40`** in `T059ZT`, `T059O` and `T059OT` — never `TXT40`,
which is what the FS wrote.

---

## 4. RISKS, ranked

**R1 — `BSEG-GHKON` may not be populated in the target.** *Impact: cols F and G blank for
every direct FI posting, i.e. most of the report.* The field definitively exists, so the
code compiles; it is the data that is unknown, and the scratch rig cannot answer it.
**Mitigation:** Arnav runs the SE16N check in §2.2 before UAT. If `GHKON` is empty and
`GKONT` is filled, the switch is a single field name in one form. `WITH_ITEM-HKONT_OPP` is
the second fallback. Until checked, the col F logic is on trust.

**R2 — `LFA1-J_1IPANNO` may not be Astral's PAN field.** *Impact: col E blank, and with it
cols U, V, W, X **and** Y — five columns dead at once, silently.* Existence is confirmed;
population is not. The `FIWTIN_*` tables key their `PAN_NO` on the same data element
`J_1IPANNO`, which is strong evidence that `J_1IPANNO` is the intended field, but strong
evidence is not the data. **Mitigation:** SE16 check on two or three known TDS vendors
before UAT. A *column-wide* blank is a defect; scattered blanks are normal (non-PAN
vendors, 206AA cases).

**R3 — Col Y's accumulation rule is a guess dressed as a default.** *Impact: a wrong but
plausible number on a compliance report — the failure mode nobody catches in review.*
`FIWTIN_ACC_EXEM` is keyed by `WT_DATE` and `SECCO`; the FS says only "get ACC_AMT" and
"as of now for FY", which is an assertion about the table's accumulation period that the
FS never justifies. D-14 pins latest-`WT_DATE`. **Mitigation:** this is the first question
for Ankita, and the TS must state the period is the table's accumulation period, not
necessarily the selected fiscal year.

**R4 — The `T030` read is non-unique and `T001K-BWMOD` is UNVERIFIED.** *Impact: wrong GL
on the "normal PO" branch, or a blank one.* Two key fields the FS never mentions.
D-11 makes the read non-selective and resolves in ABAP so nothing compiles against an
unverified name, but that is containment, not a fix. **Mitigation:** Bhavin confirms
whether a valuation grouping code is active (OMWM); then the read can be made exact.

**R5 — Col I may be blank for every row.** *Impact: one column dead.* D-5 pins
`T059OT-TEXT40`, which is right if Astral maintains official WHT keys. If `T059Z-QSCOD` is
itself unmaintained, cols H **and** I are both blank — and that is config, not a bug, so
it must be diagnosed before someone "fixes" the code. **Mitigation:** SE16 on `T059O` and
`T059Z` per §2.2, and the alternative reading (`T059ZT-TEXT40`) is already in QUERIES.

**R6 — The `BSEG` join on `BUZEI = WITH_ITEM-BUZEI` rests on a semantic assumption.**
*Impact: cols J, N, O (and the `SECCO` filter) attach to the wrong line.* Standard
behaviour says the WHT item points at the vendor line, and the DDIC is consistent with it,
but no read proved it. **Mitigation:** the one-document SE16N check in §2.3. Cheap, and it
also confirms `KOART = 'K'` on that line. If it fails, the fallback is the FS's own
looser rule — the `BSEG` line where `LIFNR <> blank` — with the multiplicity problem that
brings back.

**R7 — Reversed and parked documents are included.** *Impact: a compliance report that
double-counts, or that a reviewer rejects.* D-21 pins "include everything" on the sound
argument that reversals net to zero, but "sound argument" is not "client decision".
**Mitigation:** explicit QUERIES row; do not let this one ship unanswered.

**R8 — The scratch rig is not the target, so customer appends are invisible.** *Impact:
a required value living in a Z field would be missed entirely.* No mitigation from here.
**Check:** SE11 → Append structures tab on `BSEG`, `LFA1`, `WITH_ITEM`, `RSEG` — only if a
column comes back unexpectedly empty.

**R9 — Three of four recon reports returned null, so nothing is double-sourced.** *Impact:
a single systematic error in the ADT read would propagate everywhere.* Partially mitigated
by the two zero-error syntax-check probes, which are an independent confirmation path —
the compiler agreed with DD03L on every base-table field and every CDS element named.
That is as close to corroboration as this build got.

**R10 — `EKKN` multiplicity.** *Impact: the wrong GL on multi-assignment POs.* D-12's
`RSEG-ZEKKN` link should make it exact; the residual risk is only where `RSEG-ZEKKN` is
initial. Logged, not blocking.
