# ZAA_IMPARMENTLOSS / SAPMZAAIMP — impairment & write-back posting (OVL)

## What it is

FS-FI-AA-OVL-004-IMPR. Allocation and posting of impairment / write-back loss
under Accounting Standard AS-28.

Two objects, one flow:

- `ZAA_IMPARMENTLOSS` (tcode `ZFIIMPR`) — report. Selects assets, computes the
  impairment / write-back amounts, `EXPORT`s the result table and parameters to
  ABAP memory, then `CALL TRANSACTION 'ZAAIMP'`. Contains no BDC.
- `SAPMZAAIMP` (tcode `ZAAIMP`) — module pool. Reads memory, shows the ALV, and
  on `EXEC` builds a **batch input session** for FI-AA posting. Includes
  `MZAAIMPTOP`, `MZAAIMPO01`, `MZAAIMPI01` (1436 lines, all the BDC),
  `MZAAIMPF01` (BDC helpers, open/close group).

Six posting modes, selected by radio button in the report and passed via memory
ID `OK`: `IMPAIR`, `WBACKGROSS`, `DEPCOM`, `UNPDEP`, `PWBACK`, `WBACK`.

## How it ships

Paste-only. Module pool with screens — abapGit does not serialise SE51 dynpros
or the SE41 status. No `src/`, no `.abapgit.xml`.

## Session naming

`MZAAIMPF01` FORM `OPEN_GROUP` builds the SM35 group name as
`P_BUKRS + P_GJAHR + P_MONAT + suffix`:

| Mode                  | Suffix |
|-----------------------|--------|
| `IMPAIR` / `DEPCOM`   | `BAA`  |
| `WBACK` / `WBACKGROSS`| `BZU`  |
| `UNPDEP`              | `PPA`  |
| `PWBACK`              | `PPU`  |

So `OVL202603BAA` = company code OVL, FY 2026, period 03, impairment path.
Useful for tracing a failing session back to the branch that built it.

## Gotcha — the BDC targets ECC transactions that no longer exist on S/4

All seven `BDC_TRANSACTION` calls in `MZAAIMPI01` post through `ABAA` (x4) and
`ABZU` (x3), recorded against dynpro program `SAPMA01B` screens 0100/0110/0140.

On OCQ (S/4, new Asset Accounting) both `ABAA` and `ABZU` are assigned in SE93 to
the dispatcher report `RADISPATCH_AB01`, which redirects with
`LEAVE TO TRANSACTION` — illegal in batch input. Sessions die at step 1 with
message `00 352`. See ISSUES.md.

Successor transactions are plain dialog transactions on `SAPLAMDPS2I`
(package `FAA_SFWS_1`), so they can at least be started from a BDC:

- `ABAA` -> `ABAAL` (Unplanned depreciation), dynpro 0019
- `ABZU` -> successor not yet confirmed

## Do not

- Do not "fix" this by re-recording `ABAA`. The dispatcher will redirect again.
- Do not add `CALL SCREEN` / GUI controls expecting a ZIP ship — it is paste-only
  regardless, but keep the include boundaries as they are so paste stays surgical.
