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
