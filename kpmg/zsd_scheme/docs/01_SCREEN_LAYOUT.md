# SAPMZSD_SCHEME — Screen Layout, GUI Status and Flow Logic

Module pool **`SAPMZSD_SCHEME`** · package `ZSD_SCHEME`.
Four screens. All input fields are dictionary-referenced, so F4 help, field labels and
check-table validation come from DDIC and need no code (A41).

| Screen | Type | Purpose |
|---|---|---|
| `0100` | Normal | Initial screen — scheme selection / header attributes |
| `0200` | Normal | Maintain screen — header detail + tabstrip |
| `0210` | Subscreen | Tab 1 — Selection criteria (ALV) |
| `0220` | Subscreen | Tab 2 — Product ratio (ALV) |

---

## 1. Screen 0100 — Initial Screen

* Short description: `Scheme - Initial Screen`
* Screen type: **Normal**, next screen `0100`
* Window size: 25 lines × 83 columns

### 1.1 Element list

| Element name | Type | DDIC reference | Line | Col | Len | Group1 | Notes |
|---|---|---|:--:|:--:|:--:|:--:|---|
| `BOX_SCHEME` | Group box | — | 2 | 2 | 76 | | Text: `Scheme` |
| `TXT_SCHNO` | Text | — | 3 | 4 | 24 | | `Scheme Number` |
| `ZSDS_SCHM_INI-SCHEME_NO` | I/O field | `ZDE_SCHM_NO` | 3 | 30 | 10 | `SNO` | Search help `ZSH_SCHM_NO`; input only in change / display |
| `BOX_ORG` | Group box | — | 5 | 2 | 76 | | Text: `Organisational Data` |
| `TXT_VKORG` | Text | — | 6 | 4 | 24 | | `Sales Organization` |
| `ZSDS_SCHM_INI-VKORG` | I/O field | `VKORG` | 6 | 30 | 4 | `HDR` | Check table `TVKO` → F4 |
| `TXT_VTWEG` | Text | — | 7 | 4 | 24 | | `Distribution Channel` |
| `ZSDS_SCHM_INI-VTWEG` | I/O field | `VTWEG` | 7 | 30 | 2 | `HDR` | Check table `TVTW` → F4 |
| `TXT_SPART` | Text | — | 8 | 4 | 24 | | `Division` |
| `ZSDS_SCHM_INI-SPART` | I/O field | `SPART` | 8 | 30 | 2 | `HDR` | Check table `TSPA` → F4 |
| `BOX_TYPE` | Group box | — | 10 | 2 | 76 | | Text: `Scheme Definition` |
| `TXT_SCHTYP` | Text | — | 11 | 4 | 24 | | `Scheme Type` |
| `ZSDS_SCHM_INI-SCHEME_TYPE` | Listbox | `ZDE_SCHM_TYPE` | 11 | 30 | 20 | `HDR` | Dropdown, value list from domain fixed values |
| `TXT_SCHCAT` | Text | — | 12 | 4 | 24 | | `Scheme Category` |
| `ZSDS_SCHM_INI-SCHEME_CAT` | Listbox | `ZDE_SCHM_CAT` | 12 | 30 | 20 | `HDR` | Dropdown, value list from domain fixed values |
| `TXT_VALID` | Text | — | 13 | 4 | 24 | | `Validity` |
| `ZSDS_SCHM_INI-VALID_FROM` | I/O field | `DATS` | 13 | 30 | 10 | `HDR` | Calendar F4 |
| `TXT_TO` | Text | — | 13 | 42 | 2 | | `to` |
| `ZSDS_SCHM_INI-VALID_TO` | I/O field | `DATS` | 13 | 46 | 10 | `HDR` | Calendar F4 |
| `BOX_OPT` | Group box | — | 15 | 2 | 76 | | Text: `Options` |
| `ZSDS_SCHM_INI-EARLY_BIRD` | Checkbox | `CHAR1` | 16 | 4 | 20 | `HDR` | Text: `Early Bird` |
| `ZSDS_SCHM_INI-CASCADING` | Checkbox | `CHAR1` | 17 | 4 | 20 | `HDR` | Text: `Cascading` |
| `TXT_CASC_H` | Text | — | 17 | 30 | 46 | | `Deducts credit notes already granted` |

### 1.2 Behaviour

* `SNO` group — input-enabled in change (`V`) and display (`A`) mode, output-only in create (`H`).
* `HDR` group — input-enabled in create only; in change / display the values are read from the scheme and set to output-only (A04).
* Function code `CONT` (Enter or the Continue button) validates and calls screen `0200`.

---

## 2. Screen 0200 — Maintain Screen

* Short description: `Scheme - Maintain`
* Screen type: **Normal**, next screen `0200`
* Window size: 40 lines × 120 columns

### 2.1 Element list — header block

| Element name | Type | DDIC reference | Line | Col | Len | Group1 | Notes |
|---|---|---|:--:|:--:|:--:|:--:|---|
| `BOX_HDR` | Group box | — | 1 | 2 | 114 | | `Scheme Data` |
| `TXT_H_SCHNO` | Text | — | 2 | 4 | 22 | | `Scheme Number` |
| `ZSDT_SCHM_HDR-SCHEME_NO` | Output field | `ZDE_SCHM_NO` | 2 | 28 | 10 | | Always output-only (A01) |
| `TXT_H_STAT` | Text | — | 2 | 62 | 12 | | `Status` |
| `ZSDT_SCHM_HDR-STATUS` | Output field | `ZDE_SCHM_STAT` | 2 | 76 | 1 | | |
| `TXT_H_STATT` | Output field | `CHAR20` | 2 | 80 | 20 | | Status description, filled in PBO |
| `TXT_H_DESCR` | Text | — | 3 | 4 | 22 | | `Description` |
| `ZSDT_SCHM_HDR-DESCR` | I/O field | `ZDE_SCHM_DESCR` | 3 | 28 | 60 | `CHG` | |
| `TXT_H_TGTV` | Text | — | 4 | 4 | 22 | | `Target Value` |
| `ZSDT_SCHM_HDR-TARGET_VAL` | I/O field | `CURR 15,2` | 4 | 28 | 18 | `VAL` `CHG` | Visible for category `V` / `B` (A10) |
| `ZSDT_SCHM_HDR-WAERS` | I/O field | `WAERS` | 4 | 48 | 5 | `VAL` `CHG` | Default from `TVKO` |
| `TXT_H_TGTQ` | Text | — | 5 | 4 | 22 | | `Target Quantity` |
| `ZSDT_SCHM_HDR-TARGET_QTY` | I/O field | `QUAN 15,3` | 5 | 28 | 18 | `QTY` `CHG` | Visible for category `Q` (A11) |
| `ZSDT_SCHM_HDR-MEINS` | I/O field | `MEINS` | 5 | 48 | 3 | `QTY` `CHG` | Check table `T006` |
| `TXT_H_PCT` | Text | — | 6 | 4 | 22 | | `Scheme %` |
| `ZSDT_SCHM_HDR-SCHEME_PCT` | I/O field | `ZDE_SCHM_PCT` | 6 | 28 | 6 | `CHG` | % credited on achievement (A21) |
| `TXT_H_PARCH` | Text | — | 6 | 62 | 22 | | `Parent / Child Customer` |
| `ZSDT_SCHM_HDR-PAR_CHILD` | Checkbox | `CHAR1` | 6 | 86 | 1 | `CHG` | Aggregates children to parent (A07) |

### 2.2 Element list — early bird block

Whole block carries `Group1 = EB`. Hidden entirely when `EARLY_BIRD` is not set.

| Element name | Type | DDIC reference | Line | Col | Len | Group1 |
|---|---|---|:--:|:--:|:--:|:--:|
| `BOX_EB` | Group box | — | 8 | 2 | 114 | `EB` |
| `TXT_EB_DATE` | Text | — | 9 | 4 | 22 | `EB` |
| `ZSDT_SCHM_HDR-EB_DATE_FR` | I/O field | `DATS` | 9 | 28 | 10 | `EB` `CHG` |
| `TXT_EB_TO` | Text | — | 9 | 40 | 2 | `EB` |
| `ZSDT_SCHM_HDR-EB_DATE_TO` | I/O field | `DATS` | 9 | 44 | 10 | `EB` `CHG` |
| `TXT_EB_TGT` | Text | — | 10 | 4 | 22 | `EB` |
| `ZSDT_SCHM_HDR-EB_TGT_TYP` | Listbox | `ZDE_EBTGT_TYP` | 10 | 28 | 14 | `EB` `CHG` |
| `ZSDT_SCHM_HDR-EB_TARGET` | I/O field | `DEC 15,2` | 10 | 44 | 18 | `EB` `CHG` |
| `TXT_EB_PCT` | Text | — | 11 | 4 | 22 | `EB` |
| `ZSDT_SCHM_HDR-EB_PCT` | I/O field | `ZDE_SCHM_PCT` | 11 | 28 | 6 | `EB` `CHG` |

`BOX_EB` text `Early Bird` · `TXT_EB_DATE` `Early Bird Period` ·
`TXT_EB_TGT` `Early Bird Target` · `TXT_EB_PCT` `Early Bird %`.

### 2.3 Element list — text and tabstrip

| Element name | Type | DDIC reference | Line | Col | Len | Group1 | Notes |
|---|---|---|:--:|:--:|:--:|:--:|---|
| `TXT_H_TEXT` | Text | — | 13 | 4 | 22 | | `Text` |
| `ZSDT_SCHM_HDR-SCHM_TEXT` | I/O field | `ZDE_SCHM_TEXT` | 13 | 28 | 80 | `CHG` | |
| `TS_MAIN` | Tabstrip control | — | 15 | 2 | 114 | | 22 lines high |
| `TS_MAIN_TAB1` | Tab title | — | 15 | 4 | 24 | | Text `Selection Criteria`, fcode `TAB1` |
| `TS_MAIN_TAB2` | Tab title | — | 15 | 30 | 24 | | Text `Product Ratio`, fcode `TAB2` |
| `SUB_MAIN` | Subscreen area | — | 16 | 2 | 114 | | Holds `0210` / `0220`, 20 lines |

---

## 3. Screen 0210 — Subscreen, Selection Criteria

* Screen type: **Subscreen**, 20 lines × 114 columns

| Element name | Type | Line | Col | Size | Notes |
|---|---|:--:|:--:|---|---|
| `CC_SEL` | Custom control | 1 | 1 | 19 lines × 112 cols | Hosts `CL_GUI_ALV_GRID` for `ZSDT_SCHM_RNG` |

ALV grid columns (editable in create / change, read-only in display):

| Column | Field | Width | Control |
|---|---|:--:|---|
| Field | `FIELDNAME` | 20 | Dropdown, values from `ZDO_SCHM_FLD` fixed values |
| Description | `FLD_TEXT` | 30 | Output only, filled on `DATA_CHANGED` |
| I/E | `SIGN` | 3 | Dropdown `I` Include / `E` Exclude (A05) |
| Option | `OPTI` | 4 | Dropdown `EQ` `NE` `BT` `NB` `CP` `GE` `LE` |
| From | `LOW` | 20 | F4 switched by `FIELDNAME` (`MVGR1`→`TVM1`, `REGIO`→`T005S`, `KUNNR`→`KNA1`, `KVGR1`→`TVV1`, `KVGR2`→`TVV2`) |
| To | `HIGH` | 20 | Input only when `OPTI` = `BT` / `NB` |

Toolbar: standard `APPEND` / `INSERT` / `DELETE` / `COPY` retained (this is the FS's
"insert, change and delete" requirement), everything else excluded.
"Select All" is entered as one line `I / CP / *` (A05).

---

## 4. Screen 0220 — Subscreen, Product Ratio

* Screen type: **Subscreen**, 20 lines × 114 columns

| Element name | Type | Line | Col | Size | Notes |
|---|---|:--:|:--:|---|---|
| `CC_RAT` | Custom control | 1 | 1 | 17 lines × 112 cols | Hosts `CL_GUI_ALV_GRID` for `ZSDT_SCHM_RAT` |
| `TXT_RAT_TOT` | Text | 19 | 2 | 30 | `Total Ratio %` |
| `RATIO_TOTAL` | Output field | 19 | 34 | 8 | Running total, must equal 100 (A12) |

ALV columns: `SEQNR` (output), `MATNR` (F4 on `MARA`), `MAKTX` (output), `RATIO_PCT` (editable).

The whole tab is hidden when the scheme category is not `R` or `B`.

---

## 5. GUI statuses and titles

### Status `S0100` — Initial screen

| Fcode | Type | Icon | Text | Key |
|---|---|---|---|---|
| `CONT` | Pushbutton / App toolbar | `ICON_OKAY` | `Continue` | `Enter` |
| `BACK` | Standard | `ICON_BACK` | `Back` | `F3` |
| `EXIT` | Standard | `ICON_EXIT` | `Exit` | `Shift+F3` |
| `CANC` | Standard | `ICON_CANCEL` | `Cancel` | `F12` |

Title `T0100` — `Scheme: Initial Screen`

### Status `S0200` — Maintain screen

| Fcode | Type | Icon | Text | Key |
|---|---|---|---|---|
| `SAVE` | Standard | `ICON_SYSTEM_SAVE` | `Save` | `Ctrl+S` |
| `RELE` | App toolbar | `ICON_RELEASE` | `Release` | `F5` |
| `DELE` | App toolbar | `ICON_DELETE` | `Delete` | `Shift+F2` |
| `TAB1` | Tab | — | `Selection Criteria` | — |
| `TAB2` | Tab | — | `Product Ratio` | — |
| `BACK` `EXIT` `CANC` | Standard | | | `F3` / `Shift+F3` / `F12` |

Title `T0200` — `Scheme &1: &2` (scheme number, mode text)

`SAVE`, `RELE` and `DELE` are excluded from the status in display mode and whenever the
scheme is locked by settlement (A34).

---

## 6. Flow logic

### Screen 0100

```
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE init_0100.

PROCESS AFTER INPUT.
  MODULE exit_0100 AT EXIT-COMMAND.
  FIELD zsds_schm_ini-vkorg  MODULE check_vkorg  ON REQUEST.
  FIELD zsds_schm_ini-vtweg  MODULE check_vtweg  ON REQUEST.
  FIELD zsds_schm_ini-spart  MODULE check_spart  ON REQUEST.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD zsds_schm_ini-scheme_no MODULE f4_scheme_no.
```

### Screen 0200

```
PROCESS BEFORE OUTPUT.
  MODULE status_0200.
  MODULE init_0200.
  MODULE prepare_alv_0200.
  LOOP AT SCREEN.
    MODULE modify_screen_0200.
  ENDLOOP.
  CALL SUBSCREEN sub_main INCLUDING sy-repid g_subscreen.

PROCESS AFTER INPUT.
  MODULE exit_0200 AT EXIT-COMMAND.
  CALL SUBSCREEN sub_main.
  MODULE user_command_0200.
```

### Screens 0210 / 0220

```
PROCESS BEFORE OUTPUT.
  MODULE pbo_0210.        "resp. pbo_0220

PROCESS AFTER INPUT.
  MODULE pai_0210.        "resp. pai_0220
```

---

## 7. Screen-flow summary

```
ZSCHM01 / 02 / 03
        │
        ▼
   Screen 0100  ──CONT──▶  Screen 0200 ──┬── Tab 1 ▶ Subscreen 0210 (ALV CC_SEL)
   (initial)                (maintain)   └── Tab 2 ▶ Subscreen 0220 (ALV CC_RAT)
        ▲                        │
        └────── BACK ────────────┘
                                 │
                          SAVE / RELE / DELE
                                 ▼
                        ZCL_SD_SCHEME methods
```
