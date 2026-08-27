# ZAA_IMPARMENTLOSS / SAPMZAAIMP — issue log

| # | Date | Issue | Cause | Fix | TR | Status |
|---|------|-------|-------|-----|----|--------|
| 1 | 27/08/26 | SM35 session `OVL202603BAA` fails immediately: `"LEAVE TO TRANSACTION" is not allowed in batch input` (msg 00 352) | ECC-era BDC targets `ABAA`/`ABZU`, which on S/4 dispatch via `RADISPATCH_AB01` | planned: replace BDC with AMFA BAPIs (C2) | — | **OPEN** |

---

## Issue 1 — batch input dies at step 1 (msg 00 352)

### Symptom

SM35 -> session `OVL202603BAA`, mode A. Log:

```
"LEAVE TO TRANSACTION" is not allowed in batch input   ABAA  1  SAPMSSY0  1000  A 00 352
Transaction error                                      ABAA  1                 S 00 357
1 transactions read / 0 processed / 1 with errors
```

### Diagnosis (evidence, 27/08/26)

Failure is at **index 1, module `SAPMSSY0`, dynpro `1000`** — the system frame,
before any application screen. None of the program's BDC data was consumed.

1. Session name `OVL202603BAA` maps to `MZAAIMPF01` FORM `OPEN_GROUP`,
   `WHEN 'IMPAIR' OR 'DEPCOM'` branch (`P_BUKRS` OVL + `P_GJAHR` 2026 +
   `P_MONAT` 03 + `'BAA'`). Confirms which path built it.
2. `MZAAIMPI01` records every screen against dynpro program **`SAPMA01B`**
   (screens 0100 / 0110 / 0140, 14 `BDC_DYNPRO` calls).
3. SE93 on OCQ: **`ABAA` -> program `RADISPATCH_AB01`, selection screen 1000.**
   Same for **`ABZU`**. Both are dispatchers, not posting programs.
4. `/nABAA` in dialog lands on transaction **`ABAAL`**, program `SAPLAMDPS2I`,
   screen 0100 (subscreen 221), GUI status `0100EDIT`. Nothing like `SAPMA01B`.
5. SE93 on `ABAAL`: program `SAPLAMDPS2I`, dynpro `0019`, package `FAA_SFWS_1`,
   plain dialog transaction — no dispatcher.

So: `ABAA` -> `RADISPATCH_AB01` -> `LEAVE TO TRANSACTION 'ABAAL'` -> batch input
refuses it. The `SAPMA01B` recording is ECC-era and unreachable on this system.

**Ruled out** — the OK-codes are all legal (`/00`, `=UPDA`, `=ENTR`; no `/n` or
`/o` anywhere), `BDC_OPEN_GROUP` / `BDC_INSERT` / `BDC_CLOSE_GROUP` are correctly
paired, and the `ZAA_IMPARMENTLOSS` ATC remediation of 05.06.2026 touches only
`EXPORT ... TO MEMORY ID` statements. None of these contribute.

### Scope

All seven BDC call sites in `MZAAIMPI01` are affected, so all six posting modes
are dead, not just impairment:

| Line (in include) | Transaction | Path |
|------|-------------|------|
| 105  | `ABAA` | impairment |
| 347  | `ABZU` | write-back |
| 534  | `ABAA` | |
| 719  | `ABAA` | |
| 943  | `ABZU` | |
| 1270 | `ABZU` | |
| 1322 | `ABAA` | |

### Open items before a fix can be written

- [x] SE93 on `ABZU` — also `RADISPATCH_AB01`. Broken identically. 27/08/26
- [x] SE93 on `ABAAL` — `SAPLAMDPS2I` dynpro 0019, package `FAA_SFWS_1`,
      plain dialog transaction, no dispatcher. 27/08/26
- [x] SE37 `BAPI_ASSET_*` — function group **AMFA**, "Fixed asset posting BAPIs".
      Full list captured below. 27/08/26
- [ ] `ABZU` successor transaction name (`/nABZU` -> System -> Status)
- [ ] TABW: transaction type group behind `X20` / `X30`
- [ ] SE37 interface of `BAPI_ASSET_VALUE_ADJUST_POST` and
      `BAPI_ASSET_WRITEUP_POST`
- [ ] Delete the dead session `OVL202603BAA` in SM35

### Released BAPIs available on OCQ (function group AMFA)

Every posting BAPI has a `_CHECK` twin that validates without posting.

| BAPI | Short text |
|------|-----------|
| `BAPI_ASSET_ACQUISITION_POST`  | Post Asset Acquisition |
| `BAPI_ASSET_DOWNPAYMENT_POST`  | Post Down Payment |
| `BAPI_ASSET_INV_SUPPORT_POST`  | Post Investment Support |
| `BAPI_ASSET_POSTCAP_POST`      | Post post-capitalization |
| `BAPI_ASSET_RETIREMENT_POST`   | Post asset retirement |
| `BAPI_ASSET_REVALUATION_POST`  | Post Revaluation |
| `BAPI_ASSET_REVERSAL_POST`     | Post Asset Document Reversal |
| `BAPI_ASSET_SUB_COST_REV_POST` | Post Subsequent Costs and Revenue |
| `BAPI_ASSET_TRANSFER_POST`     | Post Intracompany Transfer |
| `BAPI_ASSET_VALUE_ADJUST_POST` | **Post Depreciation** — replaces `ABAA` |
| `BAPI_ASSET_WRITEUP_POST`      | **Post Write-Up** — replaces `ABZU` |

### BAPI test result — 27/08/26

`BAPI_ASSET_VALUE_ADJUST_CHECK` run in SE37, asset 106009197/0000, `ASSETTRTYP`
`X20`, amount 1,221.00 INR, `PSTNG_DATE` 31.03.2026, `TRANS_DATE` 12.08.2026,
`FIS_PERIOD` 03. Nothing posted — `_CHECK` validates only.

```
RETURN: EAA 370  You cannot post to this fixed asset; Fiscal year already closed
ADJUSTAREAVALUES: 0 entries   RETURN_ALL: 0 entries
```

**Interpretation.** The BAPI accepted the interface, parsed
`GENERALPOSTINGDATA`, resolved company code OVL and the asset, and reached
business validation. It did not reject `X20`. The failure is a period rule.
Caveat: the BAPI may validate fiscal year before transaction type, so this is a
strong signal rather than proof — retest with an open-year posting date to
confirm outright.

`BAPIFAPO_VALUE_ADJUSTMENT` components: `AMOUNT`, `CURRE`, `CUR`, `VALUEDATE`,
`AMOUNT_LONG`. **No text field** — so `ANEK-SGTXT` must map into
`FURTHERPOSTINGDATA` (`BAPIFAPO_ADD_INFO`), still to be captured. Fill `AMOUNT`
or `AMOUNT_LONG`, not both.

### DEFECT 2 — the failed run targeted a closed fiscal year

`EAA 370` says AA fiscal year **2026 is closed for company code OVL**. The run
that built session `OVL202603BAA` used posting date 31.03.2026 / period 3 —
inside that closed year.

**Even with working batch input, that run could not have posted.** This is a
second, independent defect:

| # | Defect | Nature |
|---|--------|--------|
| 1 | `LEAVE TO TRANSACTION` in batch input | S/4 conversion — code fix required |
| 2 | Run targets a closed AA fiscal year | business / data — functional decision |

**For functional:** which period is the impairment actually meant to post to?
Fixing the code alone will not make this run succeed.

### BAPI test sequence — CONFIRMED 27/08/26

Four `BAPI_ASSET_VALUE_ADJUST_CHECK` runs in SE37, asset 106009197/0000
(cap. date 01.09.2016, prior-year acquisition), `ASSETTRTYP` `X20`, INR.
Nothing posted at any point — `_CHECK` validates only.

| # | Changed | `RETURN` | Read |
|---|---------|----------|------|
| 1 | `PSTNG_DATE` 31.03.2026, `FIS_PERIOD` 03, amt 1,221.00 | `EAA 370` fiscal year already closed | AA FY2026 closed for OVL — see DEFECT 2 |
| 2 | `PSTNG_DATE`/`TRANS_DATE` 27.08.2026, `FIS_PERIOD` blank | `EAA 632` cutoff value 2.36 in area 01 | got past year check; amount was the run total, not the row |
| 3 | amount 10.00 | `EAA 627` special deprec. negative in areas 20/30/31/40 (+2x `590`) | not magnitude — those areas hold no special deprec. balance |
| 4 | **`DEPR_AREA` = `01`** | **`AU 176` (type W) BAdI check for depr. calcul.** | **clean — warning only, no errors** |

**Conclusion: the BAPI accepts transaction type `X20` and reaches full business
validation.** Technical approach confirmed. `EAA 632` proved magnitude, `EAA 627`
proved area scope, and scoping to area 01 cleared both. `AA 590` was a knock-on
of `627`, not an independent transaction-type objection.

`AU 176` is a standard S/4 new-AA advisory (type W), not a blocker.

#### Open functional question — which depreciation areas?

`DEPR_AREA = 00` (all areas) fails: areas 20/30/31/40 hold no special
depreciation balance and go negative. `DEPR_AREA = 01` is clean.

**Do not simply hardcode `01`.** The old BDC passed no area at all, so `ABAA`
posted to whatever the transaction type configuration allowed. Restricting to
area 01 changes what lands in the other areas and ledgers. Functional must
confirm which areas impairment is meant to post to before this is fixed in code.

Relevant: every amount field in `ZAA_IMPARMENTLOSS` is typed `LIKE ANLC-SAFAP`
(special depreciation) and `P_SAFAP` is an obligatory selection parameter — this
program has always worked in special-depreciation terms. `X20` carries debit/
credit indicator `H` in TABW.

#### Equivalence proof — DONE 27/08/26

`ABAAL` run in dialog, same asset and values (106009197/0000, `X20`, 10.00,
27.08.2026), simulated not posted. Message log:

```
Type W  Item 000  Check on BAdI implementation for depr. calcul. required
Status bar: 0 errors, 1 warning
```

**Identical to `BAPI_ASSET_VALUE_ADJUST_CHECK` with `DEPR_AREA = 01`** — same
message, same type, same count. The BAPI is a faithful replacement for the
transaction at validation level.

Note the dialog transaction raised **no** `EAA 627` area errors without being
told an area, whereas the BAPI with `DEPR_AREA = 00` did. So `ABAAL` scopes the
depreciation areas itself from configuration; the BAPI expects the caller to do
it. That is why `DEPR_AREA` must be set explicitly in our call.

**What is proven:** message-level equivalence.
**What is not yet proven:** value-level equivalence — that `DEPR_AREA = 01`
lands the same amounts in the same areas as the dialog does. Confirm with one
real posting in a sandbox, comparing AW01N before/after for a dialog posting
against a BAPI posting. This is a test activity, not a blocker to writing the
code, but it must happen before go-live and it overlaps the open functional
question on area scope above.

### DEFECT 3 / open design question — depreciation area derivation

Established 27/08/26, in this order:

| Test | Result |
|------|--------|
| BAPI, `DEPR_AREA` = `00` | `EAA 627` special deprec. negative, areas 20/30/31/40 |
| BAPI, `DEPR_AREA` = blank | **identical** — blank behaves as `00` |
| BAPI, `DEPR_AREA` = `01` | clean, `AU 176` warning only |
| `ABAAL` dialog, **no area given** | clean, `AU 176` warning only |
| SE16 `TABWA`, `BWASL` = `X20` | **no entries** — type is not area-limited |

**Conclusion.** `ABAAL` derives per-area values itself from each depreciation
area's own rules. `BAPI_ASSET_VALUE_ADJUST_*` does not — it applies the amount
it is given to every area, so areas holding no special depreciation balance go
negative.

**This is not a like-for-like swap.** The screen performed business logic
implicitly; the BAPI requires it stated explicitly. The old ECC BDC also passed
no area and relied on the same screen derivation, so this logic has never
existed in our code and cannot be recovered from it.

Options:

1. `DEPR_AREA = 01` — clean, but posts to area 01 only. Almost certainly
   narrower than what `ABAAL` does. **Do not adopt without confirmation.**
2. Populate `ADJUSTAREAVALUES` with explicit per-area amounts. Correct approach,
   but requires knowing which areas get what.

**Needed to decide:** the actual per-area amounts `ABAAL` produces for one
posting. Two ways to get them, cheapest first:

- `ABAAL` entry screen — look for a depreciation-area tab / `Goto` -> areas
  view listing each area with its amount. Read-only if it exists.
- Otherwise post one document in a sandbox and read `ANEP` for it (`AFABE` =
  depreciation area, per line). Creates a real FI document — needs approval and
  a suitable client/asset; reversible via `AB08`.

#### RESOLVED IN THE CODE — 27/08/26

The area is neither in the ALV list nor in the BDC. `IST_FINAL` has no area
field, and `SAPMZAAIMP` contains no `AFABE` / area reference in any of its 1964
lines. **It is hardcoded in the report's `SELECT`s on `ANLC`**, which is
area-keyed, so every read already pins an area:

| Mode | FORM in `ZAA_IMPARMENTLOSS` | Area read |
|------|------------------------------|-----------|
| `IMPAIR`     | `POST_ADDITIONAL_IMPAIRMENT`     | `AFABE = '01'` |
| `WBACKGROSS` | `POST_WRITEBACKGROSS_IMPAIRMENT` | `'01' OR '20'`, loops `'01'` |
| `DEPCOM`     | `DEPRICIATION_COMPARISON`        | `'01' OR '20'` |
| `UNPDEP`     | `UNPLANNED_DEPRICIATION`         | **`AFABE = '70'`** |
| `PWBACK`     | `WRITEBACK_IMPAIRMENT_PP`        | `AFABE = '01'` |
| `WBACK`      | `POST_WRITEBACK_IMPAIRMENT`      | `'01' OR '20'`, loops `'01'` |

**Consequence.** Passing `DEPR_AREA = '01'` is not a new hardcode — it makes
explicit what the program has assumed since 2005. The amounts posted are
computed *from* area 01 values, so posting them to area 01 is coherent, and the
`EAA 627` errors were the BAPI objecting to areas the program never intended.
Area 20 is genuinely in use (the comparison modes read 01 against 20) and holds
no special depreciation balance.

**`UNPDEP` reads area `70`, not `01`.** The area is per-mode. A single constant
`'01'` in the new code would be wrong for that path.

**Recommendation:** derive `DEPR_AREA` per mode from the table above rather than
using one constant; isolate it in a single FORM. Take it to functional as a
proposal with this evidence, not as an open question. Still worth their yes,
because reading from an area is not strictly the same as posting to it and the
old screen posted more broadly.

### BAPI field mapping — confirmed from SE37, 27/08/26

`BAPIFAPO_GEN_INFO` components (read off the SE37 test screen, not guessed):

`USERNAME`, `DOC_TYPE`, `DOC_DATE`, `PSTNG_DATE`, `FIS_PERIOD`, `TRANS_DATE`,
`COMP_CODE`, `ASSETMAINO`, `ASSETSUBNO`, `ASSETTRTYP`, `DEPR_AREA`,
`LEDGER_GROUP`, `ACC_PRINCIPLE`.

**The transaction type is `ASSETTRTYP` in GENERALPOSTINGDATA, not in
VALUEADJUSTDATA.** Asset value date is `TRANS_DATE`, not a field with `BZDAT`
in the name.

| Current BDC field | BAPI target | Source in program |
|---|---|---|
| `ANBZ-BUKRS`  | `GENERALPOSTINGDATA-COMP_CODE`   | `P_BUKRS` |
| `ANBZ-ANLN1`  | `GENERALPOSTINGDATA-ASSETMAINO`  | `IST_DISPLAY-ANLN1` |
| `ANBZ-ANLN2`  | `GENERALPOSTINGDATA-ASSETSUBNO`  | `IST_DISPLAY-ANLN2` |
| `ANEK-BLDAT`  | `GENERALPOSTINGDATA-DOC_DATE`    | `sy-datum` |
| `ANEK-BUDAT`  | `GENERALPOSTINGDATA-PSTNG_DATE`  | `P_BUDAT` |
| `ANBZ-PERID`  | `GENERALPOSTINGDATA-FIS_PERIOD`  | `P_MONAT` |
| `ANBZ-BWASL`  | `GENERALPOSTINGDATA-ASSETTRTYP`  | `IST_DISPLAY-TTYPE` |
| `ANBZ-BZDAT`  | `GENERALPOSTINGDATA-TRANS_DATE`  | `IST_DISPLAY-BZDAT` |
| `RA01B-BLART` | `GENERALPOSTINGDATA-DOC_TYPE`    | `'AA'`, write-up legs only |
| `ANBZ-DMBTR`  | `VALUEADJUSTDATA-...` | components not yet captured |
| `ANEK-SGTXT`  | not yet located | `P_GJAHR` / literal text |
| `ANBZ-SAFAV` / `ANBZ-NAFAV` | likely `WRITEUPAREAVALUES` | write-up legs |

`LEDGER_GROUP` and `ACC_PRINCIPLE` are new-AA additions with no BDC equivalent —
leave initial unless ledger-specific posting is required. `DEPR_AREA` initial
(`00`) posts to all areas per configuration, matching current screen behaviour.

### Data issue found while preparing the BAPI test — 27/08/26

The run that produced the failed session used:

| Parameter | Value |
|---|---|
| `P_BUDAT` posting date   | 31.03.2026 |
| `P_BZDAT` asset value date | 12.08.2026 |
| `P_MONAT` period         | 3 |

Asset value date is **after** the posting date, and on an April–March fiscal
year variant they fall in different fiscal years — FI-AA requires the asset
value date to lie in the fiscal year of the posting date. 31.03.2026 would also
be period 12, not period 3.

This will be rejected independently of the `LEAVE TO TRANSACTION` problem.
**Open question for functional:** were these test entries, or the real
parameters? If real, there is a second defect behind the first.

The report itself still selects and calculates correctly on S/4 (verified
27/08/26 — ALV populated, Total NBV 44,120,688,927.03, Total Impairment
1,221.00, sample asset 106009197/0000). Only the posting layer is broken.

### Mode -> screen -> transaction map (traced 27/08/26)

`STATUS_0200` dispatches on the memory-ID `OK` value to one screen per mode.
Each screen has its own `USER_COMMAND` module with its own `EXEC` branch, so
the seven BDC sites are not interchangeable — each belongs to one mode.

| Mode | Screen | BDC site (file line) | Tcode | Transaction types |
|------|--------|----------------------|-------|-------------------|
| `IMPAIR`     | 0200 | 388  | `ABAA` | `X20` / `X30` |
| `WBACK`      | 0300 | 630  | `ABZU` | |
| `DEPCOM`     | 0400 | 817  | `ABAA` | |
| `UNPDEP`     | 0500 | 1002 | `ABAA` | `641` / `651` |
| `PWBACK`     | 0600 | 1226 | `ABZU` | `X21` / `X32` |
| `WBACKGROSS` | 0700 | 1553 **and** 1605 | `ABZU` **then** `ABAA` | `X70` / `X71` |

**`WBACKGROSS` posts twice per run and is the awkward one.** It loops
`IMPWBRATIO <> 0` into an `ABZU` session, calls `CLOSE_GROUP`, then
`OPEN_GROUP1` and loops `DEPDIFF <> 0` into a *second* session for `ABAA`
("DEP.ON IMPAIRMENT WRITTEN BACK"). Two sessions, two transactions, one user
action. In the BAPI rewrite this becomes two BAPI calls per asset that must
succeed or fail as a unit — decide the commit boundary deliberately.

Note also that the `WBACKGROSS`/`ABZU` leg does **not** use `ANBZ-DMBTR`. It
switches on the transaction type:

```
IF IST_DISPLAY-TTYPE = 'X70'.  ANBZ-SAFAV = amount.   " special depreciation
ELSE.                          ANBZ-NAFAV = amount.   " ordinary depreciation
ENDIF.
```

plus `RA01B-BLART = 'AA'` (document type). So the write-up legs carry
area-specific amounts, which is what `WRITEUPAREAVALUES` in the BAPI is for.
Do not assume a single amount field across all six modes.

### Transaction types in use

Set in `ZAA_IMPARMENTLOSS`: `X20`, `X21`, `X30`, `X32`, `X70`, `X71`, `641`,
`651`. (`65D`/`64D`/`65J`/`64J` appear only in commented-out code.)

TABW confirmed 27/08/26:

| Type | Group | Text |
|------|-------|------|
| `X20` | 62 | Impairment on prior-yr acquis. - Fixed Asset |
| `X30` | 63 | Impairment on curr.-yr acquis - Fixed Asset |

Groups 62 / 63 are the unplanned-depreciation groups, consistent with
`BAPI_ASSET_VALUE_ADJUST_POST`. **Not yet confirmed for the other six types.**

### Mapping

| Current BDC | Replacement |
|---|---|
| `ABAA` — unplanned depreciation (4 sites) | `BAPI_ASSET_VALUE_ADJUST_POST` |
| `ABZU` — write-up (3 sites) | `BAPI_ASSET_WRITEUP_POST` |

`ABZU`'s SE93 transaction text is "Write-up", which matches
`BAPI_ASSET_WRITEUP_POST` exactly. Still to confirm: that
`BAPI_ASSET_VALUE_ADJUST_POST` accepts the transaction types this program
uses (`X20` / `X30`, set in `ZAA_IMPARMENTLOSS` FORM
`POST_ADDITIONAL_IMPAIRMENT`) — check the transaction type group in TABW.

### Two candidate fixes

**C1 — retarget the BDC** (only if `ABAAL` replays clean in mode N).
Swap the `SAPMA01B` dynpro blocks for the recorded `SAPLAMDPS2I` screens, change
the seven `BDC_TRANSACTION` tcodes, remap `ANBZ-*` / `ANEK-*` field names.
`MZAAIMPF01` needs no change. Contained, ~1 day.

**C2 — replace the BDC with the FI-AA BAPIs. RECOMMENDED as of 27/08/26.**

Both transactions map to released BAPIs in function group AMFA (see above), so
this is no longer a speculative path. It is also the supported one: SAP does not
support the new AA posting transactions for batch input, so C1 would be building
on something that may break again at the next upgrade.

**The `_CHECK` twins remove the main objection to C2.** The earlier concern was
that dropping the SM35 session takes away the users' review-before-post step.
It does not have to:

1. Loop the rows, call `BAPI_ASSET_VALUE_ADJUST_CHECK` /
   `BAPI_ASSET_WRITEUP_CHECK` for each.
2. Show the ALV with what would post, plus any BAPI errors per row.
3. User confirms.
4. Loop again with the `_POST` BAPIs, then `BAPI_TRANSACTION_COMMIT`.

That is a closer match to how users work today than the session was, and the
errors are per-asset and readable instead of buried in an SM35 log. Still worth
walking functional through it, but it is no longer a workflow downgrade to
apologise for.
