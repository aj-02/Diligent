# ZAA_IMPARMENTLOSS / SAPMZAAIMP — issue log

| # | Date | Issue | Cause | Fix | TR | Status |
|---|------|-------|-------|-----|----|--------|
| 1 | 27/08/26 | SM35 session `OVL202603BAA` fails immediately: `"LEAVE TO TRANSACTION" is not allowed in batch input` (msg 00 352) | ECC-era BDC targets `ABAA`/`ABZU`, which on S/4 dispatch via `RADISPATCH_AB01` | open — see below | — | **OPEN** |

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

- [ ] SE93 / dialog run on `ABZU` to confirm its successor transaction
- [ ] SHDB: record `ABAAL`, then replay in mode **A** and mode **N**
- [ ] SE37 `BAPI_ASSET_*` list from OCQ (fallback path)
- [ ] Delete the dead session `OVL202603BAA` in SM35

### Two candidate fixes

**C1 — retarget the BDC** (only if `ABAAL` replays clean in mode N).
Swap the `SAPMA01B` dynpro blocks for the recorded `SAPLAMDPS2I` screens, change
the seven `BDC_TRANSACTION` tcodes, remap `ANBZ-*` / `ANEK-*` field names.
`MZAAIMPF01` needs no change. Contained, ~1 day.

**C2 — replace the BDC with the FI-AA BAPI** (if `ABAAL` is not BI-capable —
likely, since SAP does not support the new AA posting transactions for batch
input). Rewrites the posting layer of `MZAAIMPI01`.

**C2 removes the SM35 session entirely.** That is a user-facing workflow change:
today users review the session before posting; they would get direct posting plus
an error log, and `CLOSE_GROUP`'s `MESSAGE I053(ZAA)` +
`CALL TRANSACTION 'SESSION_MANAGER'` become meaningless. **Needs functional
sign-off before build.** If they want the review step kept, it becomes an ALV log
with a separate post action — more work, flag early.
