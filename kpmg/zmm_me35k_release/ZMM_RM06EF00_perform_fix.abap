*&---------------------------------------------------------------------*
*&  Correction to ZMM_RM06EF00  (package ZMM_PO)
*&---------------------------------------------------------------------*
*  DEFECT
*    Release does nothing (FRGS) and Release+Save reports 06 022
*    "No data changed" (FRGU).
*
*  ROOT CAUSE
*    FEKKO is declared in include FM06LFFR as a plain program-local
*    table - it is NOT in a COMMON PART (only XEKKO is, via FM06LCFR).
*    Every program that includes FM06LFFR therefore owns a private FEKKO.
*
*    ZMM_RM06EF00 builds FEKKO by calling into SAPFM06L, but handles the
*    user's click by calling into SAPMZFM06L. FRG_SET then reads an
*    empty FEKKO and exits on CHECK SY-SUBRC EQ 0 without any message.
*    The same split empties HIDK: the HIDE runs in SAPFM06L, so the
*    hide-restore never reaches SAPMZFM06L.
*
*  CORRECTION
*    Route every PERFORM to the same form pool: SAPMZFM06L.
*    SAPMZFM06L is identical to SAPFM06L apart from include ZFM06LFFR,
*    which differs only by a comment header and two unused declarations.
*
*  Source line numbers refer to the 21.08.2026 print of ZMM_RM06EF00.
*&---------------------------------------------------------------------*

*--- Line 163 ---------------------------------------------------------*
  PERFORM anforderungsbild(sapmzfm06l) USING xselkb xselkk
                                             xselkl xselka.

*--- Line 226 (AT SELECTION-SCREEN ON listu) --------------------------*
  PERFORM listumfang(sapmzfm06l) USING listu.

*--- Line 238 (AT SELECTION-SCREEN) -----------------------------------*
  PERFORM listumfang(sapmzfm06l) USING listu.

*--- Line 253 ---------------------------------------------------------*
  PERFORM pf_status(sapmzfm06l) USING xselkb xselkk         " Note 125229
                                      xselkl xselka.        " Note 125229

*--- Line 259 ---------------------------------------------------------*
  PERFORM frg_init(sapmzfm06l) USING p_frgco p_mitpos.

*--- Line 343  ** THE CRITICAL ONE - this is what fills FEKKO ** -------*
              PERFORM frg_fekko_aufbauen(sapmzfm06l) USING hfdpos.

*--- Line 395 ---------------------------------------------------------*
  PERFORM get_table_manager(sapmzfm06l) CHANGING l_manager.

*--- Line 409 ---------------------------------------------------------*
    PERFORM selpa_check_kopf(sapmzfm06l)." Note 125229

*--- Line 412 ---------------------------------------------------------*
    PERFORM ekko_anschrift(sapmzfm06l).

*--- Line 413  ** does HIDE HIDK - needed for FRG_SET to find the row **
    PERFORM ekko_ausgabe(sapmzfm06l).

*--- Line 421 ---------------------------------------------------------*
        PERFORM selpa_check_pos(sapmzfm06l).                " Note 125229

*--- Line 424 ---------------------------------------------------------*
        PERFORM fc_me_read_history(sapmzfm06l).             "65349

*--- Line 425  ** does HIDE HIDP ** -----------------------------------*
        PERFORM ekpo_ausgabe(sapmzfm06l).

*--- Lines 485 / 507 / 513 / 516 - already correct, leave as they are --*
* perform clear_hidk_hidp(sapmzfm06l).
* perform user_command(sapmzfm06l).
* perform top(sapmzfm06l).
* perform top(sapmzfm06l).
