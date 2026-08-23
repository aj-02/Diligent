# ZSD_SCHEME — NOTES

## What it is

The Scheme (Pipes) build for Astral / UDAY / SD.

- `SAPMZSD_SCHEME` — a **module pool** (`PROGRAM sapmzsd_scheme MESSAGE-ID zsd_scheme.`)
  with four SE51 screens (0100 initial, 0200 maintain, 0210 and 0220 subscreens under
  tabstrip `TS_MAIN`), two GUI statuses (`S0100`, `S0200`), two titles (`T0100`, `T0200`),
  8 PBO and 8 PAI modules, and two `CL_GUI_ALV_GRID` instances in custom controls
  `CC_SEL` / `CC_RAT`.
- `ZCL_SD_SCHEME` — global class, model + validation.
- `ZCL_SD_SCHEME_SETTLE` — global class, volume / early-bird / cascading logic and CN posting.
- `ZCL_SD_SCHEME_UI` — global class, field texts and switchable F4.
- `ZSD_SCHEME_REPORT` (464 lines) — report with settlement, tcode `ZSCHM_RPT`.
- `ZSD_SCHEME_UPLOAD` (397 lines) — mass upload, tcode `ZSCHM_UPL`.

Tcodes `ZSCHM01` / `ZSCHM02` / `ZSCHM03` are parameter transactions on screen 0100 passing
`MODE` = H / V / A.

## Gotchas

- `SAPMZSD_SCHEME.abap` is a **single file containing five includes concatenated**
  (`ZSD_SCHEME_TOP`, `_CLS`, `_O01`, `_I01`, `_F01`). Creating it means creating five
  includes, not one program.
- `ZSD_SCHEME_REPORT` is a report but is **not** screen-free: `CALL SCREEN 0100` (l.163),
  `SET PF-STATUS 'S0100'` (l.216), `cl_gui_custom_container`. It needs its own SE51 screen
  0100 and SE41 status before it will activate. `ZSD_SCHEME_UPLOAD` is the opposite —
  selection screen + `CL_SALV_TABLE` + `cl_gui_frontend_services` only, no screen work.
- One generic range table (`ZSDT_SCHM_RNG`) replaces seven child tables; "Select All" is one
  row `I / CP / *`. Adding a new selection field means extending domain `ZDO_SCHM_FLD`'s
  fixed values plus the mapping in `ZCL_SD_SCHEME_SETTLE=>build_ranges` — no DDIC change.
- **Open point (Q2):** the FS maps sold-to / distribution channel to the analytical fields
  `VBRP-KUNAG_ANA` / `VTWEG_AUFT`; the code uses `VBRK-KUNAG` / `VBRK-VTWEG` instead because
  the analytical fields may not be active. `KNA1-ZZ1_LOC1_CUS` / `ZZ1_LOC2_CUS` /
  `ZZ1_SP_CODE_CUS` are read via `ASSIGN COMPONENT` so the class compiles whether or not
  those extension fields exist.
- Segregation of duties is enforced by **removing the Post button from the GUI status** when
  `ZSD_SCHM_ST ACTVT 16` is missing, not only by a check at posting time.
- `ZSDT_SCHM_SLB` (slabs) is created empty on purpose so slab payout stays a code change,
  never a table conversion.
- Nothing about the posting is hardcoded — order type / billing type / material / condition
  come from `ZSDT_SCHM_CFG` via SM30.
- Validation lives only in `ZCL_SD_SCHEME` so the online transaction and the mass upload
  cannot diverge (A39). Uploaded schemes are always status New — release stays manual (A40).

## Dependencies

7 tables, 8 domains, 10 data elements, 4 structures, 4 table types; number range
`ZSDSCHEME`; lock object `EZSDT_SCHM_HDR`; message class `ZSD_SCHEME` (35 messages);
auth objects `ZSD_SCHM` / `ZSD_SCHM_ST`; change document object `ZSDSCHEME`; SM30 views
`ZSDV_SCHM_FKA` / `ZSDV_SCHM_CFG`; search help `ZSH_SCHM_NO`.

Build order is in `00_TECHNICAL_OBJECTS.md` §11; screen layout in `01_SCREEN_LAYOUT.md`.

## Shipping: PASTE-ONLY (for the package as a whole)

Nothing here is serialised today — flat `.abap` files, no `src/`, no `.abapgit.xml`.
The module pool's screens (SE51), GUI statuses (SE41), SM30 views (SE54), number range
(SNRO), auth objects (SU21) and change-document object (SCDO) are not serialisable by
abapGit, and `ZSD_SCHEME_REPORT` needs a hand-built screen too.

If the effort ever justifies it, the DDIC set + the three classes + `ZSD_SCHEME_UPLOAD`
are the abapGit-able subset; the rest stays manual regardless.

## Stays manual regardless

SE51 screens 0100 / 0200 / 0210 / 0220 · SE41 statuses `S0100` / `S0200` and titles ·
SNRO `ZSDSCHEME` · SU21 `ZSD_SCHM` / `ZSD_SCHM_ST` · SCDO `ZSDSCHEME` ·
lock object `EZSDT_SCHM_HDR` · SE54 views `ZSDV_SCHM_FKA` / `ZSDV_SCHM_CFG` ·
SE93 tcodes ZSCHM01 / 02 / 03 / ZSCHM_RPT / ZSCHM_UPL.
