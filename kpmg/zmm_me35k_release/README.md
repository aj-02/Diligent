# ZMMME35K — release not working after S/4 conversion

ECC → S/4 (system **OCQ**, S4 2025_1_A). Custom release transaction **ZMMME35K**
stopped releasing after the conversion. Root-caused and fixed; this folder holds
the analysis and the delivered code.

**Status: fixed and confirmed working.**

---

## 1. Object map

| Custom object | Copy of | Package |
|---|---|---|
| `ZMM_RM06EF00` | `RM06EF00` — "Release (Approve) Purchasing Documents" | ZMM_PO |
| `SAPMZFM06L` | `SAPFM06L` — "List Displays: Purchasing Documents" | ZMM_PO |
| `ZFM06LFFR` | `FM06LFFR` — release routines | ZMM_PO |
| `ZMM_FM06LTO1` / `ZMM_FM06LCFR` / `ZMM_FM06LCEK` | `FM06LTO1` / `FM06LCFR` / `FM06LCEK` | ZMM_PO |

Transaction: **ZMMME35K** (contracts). Related: `ZMMME28` (POs).
Original copy taken 22.09.2003 by SAB_VAIBHAV; ATC-remediated 17.07.2026 by SAP_ABAP.

`SAPMZFM06L` contains 270 includes, of which **269 are SAP standard** — only
`ZFM06LFFR` is a Z copy.

## 2. Standard release flow (S/4)

```
RM06EF00 / ZMM_RM06EF00
  SELECT EKKO by FRGRL/FRGGR/FRGSX  → responsibility overlay → M_RAHM_* auth
  → FRG_FEKKO_AUFBAUEN  fills FEKKO
  → list, SET PF-STATUS 'FREI'

GUI status FREI:
  FRGS → FRG_SET                      FRGR → FRG_RESET
  FRGU → FRG_SET + FRG_UPDATE         FRGI → FRG_INFO
  BU   → FRG_UPDATE (menu)            EN   → FRG_SAVE_CHECK (menu)

FRG_SET  → FRG_CHECK_UPDATE (MM_ENQUEUE_DOCUMENT, re-read, E176 if changed)
         → ME_REL_SET (I_FRGOT='2')  → E102/E103/E104 on failure
         → FEKKO-UPDKZ = 'U', line turns green

FRG_UPDATE → XVBFRGFB is hardcoded 'X' in FM06LCHI, so it always branches to
             FRG_UPDATE_FB → BELEG_BUCHEN per document:
               ME_PURCHASE_DOCU_DATA_REFRESH
               ME_PURCHASE_DOCUMENT_DATA_READ  (I_TCODE = SY-TCODE)
               ME_PUR_DOCU_HEADER_CHANGE ×3 (FRGZU, FRGKE, FRGRL)
               BAdI ME_COMMTMNT_PO_RELEV / _REL_C
               ME_PURCHASE_DOCUMENT_DATA_SAVE (I_NO_COMMIT='X')
             → COMMIT WORK → S177 → LEAVE TO TRANSACTION
```

The legacy branch of `FRG_UPDATE` (`CD_CALL_EINKBELEG`, `FRG_UPDATE_NACHRICHTEN`,
`ME_UPDATE_RELEASE`) is **dead code** on S/4 — `XVBFRGFB` is never anything but `'X'`.

## 3. Root causes

### 3.1 `FEKKO` / `HIDK` built in one program, read in another

Symptoms: **Release (FRGS) did nothing at all**, **Release+Save (FRGU) gave
`06 022 "No data changed"`**.

`FEKKO` is declared in `FM06LFFR` as a plain program-local table — it is **not**
in a `COMMON PART`. Only `XEKKO` is (`DATA BEGIN OF COMMON PART FM06LCFR`).
Every program including `FM06LFFR` therefore owns a private `FEKKO`.

`ZMM_RM06EF00` was calling:

```abap
PERFORM frg_fekko_aufbauen(sapfm06l)   " fills FEKKO in SAPFM06L
PERFORM ekko_ausgabe(sapfm06l)         " HIDE HIDK  in SAPFM06L
PERFORM user_command(sapmzfm06l)       " reads FEKKO in SAPMZFM06L  ← empty
```

`FRG_SET` then hit `READ TABLE fekko WITH KEY hidk-ebeln` → `CHECK sy-subrc EQ 0`
→ silent exit, no message. `FRG_UPDATE` found no `UPDKZ = 'U'` → `S022(06)`.

Verified: no `REFRESH`/`FREE`/`CLEAR FEKKO[]` exists anywhere in the 23,890-line
form pool. The table was never emptied — it was never filled in that program.
Debugger proof: compare `(SAPFM06L)FEKKO[]` against `(SAPMZFM06L)FEKKO[]`.

### 3.2 `ZFM06LFFR` rebuilt from the modular SAP standard, losing all custom code

In ECC, `ZFM06LFFR` carried `FORM frg_set` written out **inline**, with three
customer blocks inside it. On S/4 the include was rebuilt and now reads
`INCLUDE FM06LFFR_FRG_SET` — SAP's own unmodified routine.

The giveaway: the S/4 `ZFM06LFFR` still has the **CR 30011813 change-history
header** and the **`wa_ola_pr_rec` / `ist_ola_pr_hdr` declarations**, but none of
the FORMs that use them. The top of the include survived; the bodies did not.

## 4. Fixes applied

### Fix 1 — `ZMM_RM06EF00`

Find & replace `(sapfm06l)` → `(sapmzfm06l)`. 13 live occurrences, source lines
163, 226, 238, 253, **343**, 395, 409, 412, 413, 421, 424, 425.
Line 343 (`frg_fekko_aufbauen`) is the actual defect; 413 and 425 carry the `HIDE`.
Lines 485/507/513/516 already pointed at `SAPMZFM06L`.

See `ZMM_RM06EF00_perform_fix.abap`.

### Fix 2 — restore the custom `FRG_SET`

New include **`ZFM06LFFR_FRG_SET`** (package ZMM_PO, main program `SAPMZFM06L`),
see `ZFM06LFFR_FRG_SET.abap`. Then one line in `ZFM06LFFR`:

```abap
  INCLUDE ZFM06LFFR_FRG_SET .  " FRG_SET                    "+TC001
* INCLUDE FM06LFFR_FRG_SET .  " FRG_SET
```

**Never** edit SAP's `FM06LFFR_FRG_SET` — `SAPFM06L` shares it, so standard
ME35K / ME28 / ME35L would change for every user.

Activation order: `ZFM06LFFR_FRG_SET` → `ZFM06LFFR` → `ZMM_RM06EF00` →
`SAPMZFM06L`. Syntax-check from `SAPMZFM06L`, not from the include.

## 5. The custom business logic

### 5.1 Live in `FRG_SET` (this is what was broken)

| Block | Origin | Rule |
|---|---|---|
| PR still released | Harish 02.03.2005, not for `ZMMME28` | any linked, undeleted `EKPO-BANFN` whose `EBAN-FRGKZ = 'X'` → **`A192(ZMM)`** |
| OLA value vs PR value | Lipsy CR 30008101, `ZMMME35K` only | total OLA `KTWRT` > total PR value → **`A239(ZMM_OTH)`**, only when `BEDAT > 20140924`. Exempt: `BSART` = `MQCM` / `MQCN` |
| Currency handling | CAB_SPYADAV CR 30011813 | single shared currency on both sides → no conversion; otherwise `CONVERT_TO_LOCAL_CURRENCY` to INR using the **PR first release date** (from CDHDR/CDPOS on `BANF`/`FRGZU`); OLA uses `WKURS` from its own header. `get_all_olas_prs` walks OLA→PR→OLA transitively, replacing the old recursive `iteration` |

### 5.2 Present but dead — `ZMM_RM06EF00`

`BDP_CHECK`, `CHECK_FINAL_REL`, `READ_CHANGE_DOC` are **defined and never
called**, in ECC *and* S/4 (the cross-reference index lists definition lines
only). They implement tender-committee governance:

- `ZMM_TMS` keyed on `EKKO-ZZSUBMI` (tender no.): `TC_MEMBER1..5`, substitutes `_S`, `CPA`
- `ZMM_PUR_TENDER_D` — tender value, decision threshold **1,000,000**
- `PA0001 → PA9930 → ZDESIGNATION_REV` — discipline code **`36` = MM**, anything else = indentor
- release code `TC` → MM member only; `TI` → indentor member only; `ZZNAT_PROC` 9/10 → CPA only; 8/11/12 → separate branch; purchasing group starting `'O'` exempt
- messages `E940(ZMM)`, `I682(ZMM)`

**Do not activate these without a business decision.** If they are ever wired
up, note that `CHECK_FINAL_REL` does `SELECT ... WHERE ebeln IN s_ebeln` then
`READ TABLE ... INDEX 1` — it judges the whole list by its first document.

## 6. Known issues, not fixed

| Item | Impact |
|---|---|
| `lo_buffer->close( )` deleted from `ZMM_RM06EF00` | `CL_MMBSI_SRM_CTR_BUFFER` opened via `get_instance( )` / `set_release_state( )` and never reset |
| `PERFORM start_via_table_manager` deleted | ALV/table-manager output path disabled; ZMMME35K stays on classic WRITE lists while standard ME35K uses the modern one |
| `SELOPT_CNT_CALL`, `T160L` (note 1876863), `ENHANCEMENT-POINT`s missing | the clone is a pre-2005 `RM06EF00`; SAP notes since then are absent |
| `MM_SFWS_P2PSE` switch | `BSTYP='K'` + `STATU='K'` documents are deleted from the list — central contracts can silently disappear |
| `MESSAGE a239` reads `wa_ekko_ola-bedat` after the `LOOP` ended | with several OLAs the date checked is whichever was read last |
| `SY-TCODE = ZMMME35K` passed to `ME_PURCHASE_DOCUMENT_DATA_READ` | needs a `T160` entry; check if save-time errors ever appear |
| ECC-vintage syntax (`TABLES`, `OCCURS`, header lines, `SEARCH`, hardcoded English message literals) | ATC findings; only one line was remediated in the 2026 pass |

Strategic: `ZMM_RM06EF00` and `SAPMZFM06L` are frozen 2003 copies of SAP code.
No SAP note will ever reach them and they drift further with every upgrade. The
long-term target is the genuine business logic in a BAdI or Flexible Workflow
precondition, with SAP's ME35K left untouched.

## 7. Files

| File | Contents |
|---|---|
| `ZFM06LFFR_FRG_SET.abap` | new include — custom `FRG_SET` + `GET_1ST_PR_REL_DT`, `GET_ALL_OLAS_PRS`, `GET_OLA_PR_DTL`, `GET_OLD_PR_DTL_R` |
| `ZFM06LFFR_change.abap` | the one-line include swap in `ZFM06LFFR` |
| `ZMM_RM06EF00_perform_fix.abap` | the 13 `PERFORM` target corrections |

Deliberate differences from the ECC source, documented in the include header:
`ME_REL_SET` keeps the S/4 standard `EXCEPTIONS` block (ECC has it commented out,
which risks a short dump); `FORM ITERATION` is not carried over (its only call
site is commented out in ECC, superseded by `GET_ALL_OLAS_PRS`); dead commented
blocks dropped. No executable statement changed.
