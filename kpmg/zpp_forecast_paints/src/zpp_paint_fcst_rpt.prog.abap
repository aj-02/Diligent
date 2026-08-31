*&---------------------------------------------------------------------*
*& Report        : ZPP_PAINT_FCST_RPT
*& Title         : ZFORECAST Paints - Forecast Report
*& Transaction   : ZPFCST_RPT
*& Package       : ZPP_PNT_FCST
*& Message class : ZPP_PFCST
*& Author        : Arnav
*& Created on    : 31.08.2026
*&---------------------------------------------------------------------*
*& Purpose
*&   Final report of the ZFORECAST Paints solution. It reads the three
*&   forecast tables - annual ZPPT_PNT_FYR, quarterly ZPPT_PNT_FQT and
*&   monthly ZPPT_PNT_FMN - with one SELECT each and merges them in ABAP
*&   on plant / material / financial year. Quarter and period are carried
*&   on the output row so the quarterly and monthly figures can be read.
*&
*&   A plant / material that exists only quarterly or only monthly still
*&   appears; its annual column is then left empty.
*&
*& Display
*&   Full screen CL_SALV_TABLE with the standard toolbar. The report is
*&   screen free by design - no CALL SCREEN, no MODULE, no SET PF-STATUS
*&   and no custom container - which is what keeps it abapGit shippable.
*&---------------------------------------------------------------------*
REPORT zpp_paint_fcst_rpt MESSAGE-ID zpp_pfcst.

*&---------------------------------------------------------------------*
*& Types
*&---------------------------------------------------------------------*
* Output row. Component order is the column order on the ALV, which is
* the order the functional specification lists for the final report,
* with financial year, quarter and period added as the keys a reader
* needs to tell one row from the next.
TYPES: BEGIN OF ty_out,
         matnr     TYPE matnr,
         werks     TYPE werks_d,
         maktx     TYPE maktx,
         matkl     TYPE matkl,
         mvgr1     TYPE mvgr1,
         mvgr2     TYPE mvgr2,
         mvgr5     TYPE mvgr5,
         fyear     TYPE zde_pnt_fyear,
         annual    TYPE zde_pnt_fcst_qty,
         quarter   TYPE zde_pnt_quarter,
         qtr_fcst  TYPE zde_pnt_fcst_qty,
         qtr_add   TYPE zde_pnt_fcst_qty,
         qtr_total TYPE zde_pnt_fcst_qty,
         period    TYPE poper,
         mth_fcst  TYPE zde_pnt_fcst_qty,
         mth_add   TYPE zde_pnt_fcst_qty,
         mth_total TYPE zde_pnt_fcst_qty,
         fcst_no   TYPE zde_pnt_fcst_no,
       END OF ty_out,
       tt_out TYPE STANDARD TABLE OF ty_out WITH DEFAULT KEY.

* One entry per plant / material / financial year, collected from all
* three forecast tables, so a key that exists in only one of them is
* still reported.
TYPES: BEGIN OF ty_key,
         werks TYPE werks_d,
         matnr TYPE matnr,
         gjahr TYPE gjahr,
         fyear TYPE zde_pnt_fyear,
       END OF ty_key,
       tt_key TYPE STANDARD TABLE OF ty_key WITH DEFAULT KEY.

* Monthly forecast row with the quarter it belongs to added, so a
* monthly row can be matched to its quarterly row without a further
* database read.
TYPES: BEGIN OF ty_mn,
         werks        TYPE werks_d,
         matnr        TYPE matnr,
         gjahr        TYPE gjahr,
         period       TYPE poper,
         quarter      TYPE zde_pnt_quarter,
         fcst_no      TYPE zde_pnt_fcst_no,
         maktx        TYPE maktx,
         matkl        TYPE matkl,
         mvgr1        TYPE mvgr1,
         mvgr2        TYPE mvgr2,
         mvgr5        TYPE mvgr5,
         fcst_qty     TYPE zde_pnt_fcst_qty,
         bus_fcst_add TYPE zde_pnt_fcst_qty,
         final_qty    TYPE zde_pnt_fcst_qty,
       END OF ty_mn,
       tt_mn TYPE STANDARD TABLE OF ty_mn WITH DEFAULT KEY.

*&---------------------------------------------------------------------*
*& Global data
*&---------------------------------------------------------------------*
DATA gt_out TYPE tt_out.

* Reference fields for the select-options, so every filter sits on the
* type it actually filters and gets the right length and value help.
DATA: gv_werks  TYPE werks_d,
      gv_matnr  TYPE matnr,
      gv_perio  TYPE poper,
      gv_quart  TYPE zde_pnt_quarter,
      gv_fcstno TYPE zde_pnt_fcst_no.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
* ASSUMPTION: the FS marks Plant, Month and Quarter mandatory on the
* ASSUMPTION: final report. Only Plant is enforced with OBLIGATORY here.
* ASSUMPTION: Month and quarter are left optional, because a forecast
* ASSUMPTION: that exists annually only has neither, and making either
* ASSUMPTION: mandatory would put those rows out of reach of the report.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_werks  FOR gv_werks OBLIGATORY,
                s_matnr  FOR gv_matnr.
PARAMETERS:     p_fyear  TYPE zde_pnt_fyear.
SELECT-OPTIONS: s_perio  FOR gv_perio  NO INTERVALS,
                s_quart  FOR gv_quart  NO INTERVALS,
                s_fcstno FOR gv_fcstno.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
INITIALIZATION.

  PERFORM default_fyear.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF p_fyear IS NOT INITIAL AND
     zcl_pp_pfcst_util=>is_fyear_valid( p_fyear ) = abap_false.
    MESSAGE e002 WITH p_fyear.
  ENDIF.

  LOOP AT s_werks INTO DATA(ls_sel_werks).
    CHECK ls_sel_werks-low IS NOT INITIAL.
    IF zcl_pp_pfcst_util=>check_plant_auth(
         iv_werks = ls_sel_werks-low
         iv_actvt = '03' ) = abap_false.
      MESSAGE e023 WITH ls_sel_werks-low.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM collect.

  IF gt_out IS INITIAL.
*   No forecast data for the selection - say so and stop, rather than
*   putting an empty list on the screen with no explanation.
    MESSAGE s008 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  PERFORM display.

*&---------------------------------------------------------------------*
*& Default the financial year to the one the current date falls in,
*& April to March.
*&---------------------------------------------------------------------*
FORM default_fyear.

  DATA: lv_year TYPE i,
        lv_next TYPE i.

  lv_year = sy-datum(4).
  IF sy-datum+4(2) < '04'.
    lv_year = lv_year - 1.
  ENDIF.
  lv_next = lv_year + 1.

  p_fyear = |{ lv_year }-{ lv_next }|.

ENDFORM.

*&---------------------------------------------------------------------*
*& Read the three forecast tables and merge them into GT_OUT.
*&
*& Three plain SELECTs, no join and no SELECT inside a LOOP. The tables
*& are merged in ABAP because a full join would drop every plant and
*& material that is not present in all three.
*&---------------------------------------------------------------------*
FORM collect.

  DATA: lr_fyear TYPE RANGE OF zde_pnt_fyear,
        lr_gjahr TYPE RANGE OF gjahr,
        lt_key   TYPE tt_key,
        ls_key   TYPE ty_key,
        lt_mnx   TYPE tt_mn,
        ls_mnx   TYPE ty_mn,
        ls_out   TYPE ty_out,
        ls_base  TYPE ty_out,
        lv_rows  TYPE i.

  CLEAR gt_out.

* ASSUMPTION: GJAHR on the quarterly and monthly tables holds the first
* ASSUMPTION: year of the financial year, so 2026-2027 is GJAHR 2026.
  IF p_fyear IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = p_fyear ) TO lr_fyear.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = p_fyear(4) ) TO lr_gjahr.
  ENDIF.

  SELECT werks, matnr, fyear, fcst_no, maktx, matkl,
         mvgr1, mvgr2, mvgr5, fcst_total
    FROM zppt_pnt_fyr
    WHERE werks   IN @s_werks
      AND matnr   IN @s_matnr
      AND fyear   IN @lr_fyear
      AND fcst_no IN @s_fcstno
    INTO TABLE @DATA(lt_yr).

  SELECT werks, matnr, gjahr, quarter, fcst_no, maktx, matkl,
         mvgr1, mvgr2, mvgr5, fcst_qty, bus_fcst_add, final_qty
    FROM zppt_pnt_fqt
    WHERE werks   IN @s_werks
      AND matnr   IN @s_matnr
      AND gjahr   IN @lr_gjahr
      AND quarter IN @s_quart
      AND fcst_no IN @s_fcstno
    INTO TABLE @DATA(lt_qt).

  SELECT werks, matnr, gjahr, period, fcst_no, maktx, matkl,
         mvgr1, mvgr2, mvgr5, fcst_qty, bus_fcst_add, final_qty
    FROM zppt_pnt_fmn
    WHERE werks   IN @s_werks
      AND matnr   IN @s_matnr
      AND gjahr   IN @lr_gjahr
      AND period  IN @s_perio
      AND fcst_no IN @s_fcstno
    INTO TABLE @DATA(lt_mn).

  DATA: ls_yr LIKE LINE OF lt_yr,
        ls_qt LIKE LINE OF lt_qt,
        ls_mn LIKE LINE OF lt_mn.

* Monthly rows carry the period only. Derive the quarter it falls in so
* the row can be paired with its quarterly forecast, and drop the row if
* the user restricted the quarter and this one is outside it.
  LOOP AT lt_mn INTO ls_mn.
    CLEAR ls_mnx.
    ls_mnx = CORRESPONDING ty_mn( ls_mn ).
    PERFORM period_to_quarter USING    ls_mn-period
                              CHANGING ls_mnx-quarter.
    IF s_quart[] IS NOT INITIAL AND ls_mnx-quarter NOT IN s_quart.
      CONTINUE.
    ENDIF.
    APPEND ls_mnx TO lt_mnx.
  ENDLOOP.

* One key per plant / material / financial year, from all three tables.
  LOOP AT lt_yr INTO ls_yr.
    CLEAR ls_key.
    ls_key-werks = ls_yr-werks.
    ls_key-matnr = ls_yr-matnr.
    ls_key-gjahr = ls_yr-fyear(4).
    ls_key-fyear = ls_yr-fyear.
    APPEND ls_key TO lt_key.
  ENDLOOP.

  LOOP AT lt_qt INTO ls_qt.
    CLEAR ls_key.
    ls_key-werks = ls_qt-werks.
    ls_key-matnr = ls_qt-matnr.
    ls_key-gjahr = ls_qt-gjahr.
    PERFORM fyear_from_gjahr USING    ls_qt-gjahr
                             CHANGING ls_key-fyear.
    APPEND ls_key TO lt_key.
  ENDLOOP.

  LOOP AT lt_mnx INTO ls_mnx.
    CLEAR ls_key.
    ls_key-werks = ls_mnx-werks.
    ls_key-matnr = ls_mnx-matnr.
    ls_key-gjahr = ls_mnx-gjahr.
    PERFORM fyear_from_gjahr USING    ls_mnx-gjahr
                             CHANGING ls_key-fyear.
    APPEND ls_key TO lt_key.
  ENDLOOP.

  SORT lt_key BY werks matnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_key COMPARING werks matnr gjahr.

  SORT lt_yr  BY werks matnr fyear.
  SORT lt_qt  BY werks matnr gjahr quarter.
  SORT lt_mnx BY werks matnr gjahr period.

  LOOP AT lt_key INTO ls_key.

    CLEAR ls_base.
    ls_base-werks = ls_key-werks.
    ls_base-matnr = ls_key-matnr.
    ls_base-fyear = ls_key-fyear.

*   The annual row is preferred for the descriptive fields and is the
*   only source of the annual forecast quantity.
    READ TABLE lt_yr INTO ls_yr WITH KEY werks = ls_key-werks
                                         matnr = ls_key-matnr
                                         fyear = ls_key-fyear.
    IF sy-subrc = 0.
      ls_base-annual = ls_yr-fcst_total.
      PERFORM take_desc USING    ls_yr-fcst_no ls_yr-maktx ls_yr-matkl
                                 ls_yr-mvgr1 ls_yr-mvgr2 ls_yr-mvgr5
                        CHANGING ls_base.
    ENDIF.

    lv_rows = 0.

*   One row per monthly forecast, with the quarterly figures of the
*   quarter that month belongs to alongside.
    LOOP AT lt_mnx INTO ls_mnx WHERE werks = ls_key-werks
                                 AND matnr = ls_key-matnr
                                 AND gjahr = ls_key-gjahr.

      ls_out = ls_base.
      ls_out-quarter = ls_mnx-quarter.
      ls_out-period  = ls_mnx-period.

      READ TABLE lt_qt INTO ls_qt WITH KEY werks   = ls_key-werks
                                           matnr   = ls_key-matnr
                                           gjahr   = ls_key-gjahr
                                           quarter = ls_mnx-quarter.
      IF sy-subrc = 0.
        ls_out-qtr_fcst  = ls_qt-fcst_qty.
        ls_out-qtr_add   = ls_qt-bus_fcst_add.
        ls_out-qtr_total = ls_qt-final_qty.
        PERFORM take_desc USING    ls_qt-fcst_no ls_qt-maktx ls_qt-matkl
                                   ls_qt-mvgr1 ls_qt-mvgr2 ls_qt-mvgr5
                          CHANGING ls_out.
      ENDIF.

      ls_out-mth_fcst  = ls_mnx-fcst_qty.
      ls_out-mth_add   = ls_mnx-bus_fcst_add.
      ls_out-mth_total = ls_mnx-final_qty.
      PERFORM take_desc USING    ls_mnx-fcst_no ls_mnx-maktx ls_mnx-matkl
                                 ls_mnx-mvgr1 ls_mnx-mvgr2 ls_mnx-mvgr5
                        CHANGING ls_out.

      APPEND ls_out TO gt_out.
      lv_rows = lv_rows + 1.

    ENDLOOP.

*   A quarter with no monthly forecast of its own still gets a row, so
*   the quarterly figures are never lost.
    LOOP AT lt_qt INTO ls_qt WHERE werks = ls_key-werks
                               AND matnr = ls_key-matnr
                               AND gjahr = ls_key-gjahr.

      READ TABLE lt_mnx TRANSPORTING NO FIELDS
                        WITH KEY werks   = ls_key-werks
                                 matnr   = ls_key-matnr
                                 gjahr   = ls_key-gjahr
                                 quarter = ls_qt-quarter.
      CHECK sy-subrc <> 0.

      ls_out = ls_base.
      ls_out-quarter   = ls_qt-quarter.
      ls_out-qtr_fcst  = ls_qt-fcst_qty.
      ls_out-qtr_add   = ls_qt-bus_fcst_add.
      ls_out-qtr_total = ls_qt-final_qty.
      PERFORM take_desc USING    ls_qt-fcst_no ls_qt-maktx ls_qt-matkl
                                 ls_qt-mvgr1 ls_qt-mvgr2 ls_qt-mvgr5
                        CHANGING ls_out.

      APPEND ls_out TO gt_out.
      lv_rows = lv_rows + 1.

    ENDLOOP.

*   Annual only. Shown when the user asked for neither a month nor a
*   quarter; with either filled the request was for that level of
*   detail, and an annual row would not answer it.
    IF lv_rows = 0 AND s_perio[] IS INITIAL AND s_quart[] IS INITIAL.
      APPEND ls_base TO gt_out.
    ENDIF.

  ENDLOOP.

  SORT gt_out BY werks matnr fyear quarter period.

ENDFORM.

*&---------------------------------------------------------------------*
*& Fiscal quarter of a fiscal period, period 1 being April.
*&---------------------------------------------------------------------*
FORM period_to_quarter USING    pv_period  TYPE poper
                       CHANGING pv_quarter TYPE zde_pnt_quarter.

  DATA lv_quarter TYPE i.

  CLEAR pv_quarter.

  IF pv_period IS INITIAL OR pv_period > 12.
    RETURN.
  ENDIF.

  lv_quarter = ( pv_period - 1 ) DIV 3 + 1.
  pv_quarter = lv_quarter.

ENDFORM.

*&---------------------------------------------------------------------*
*& Financial year of a fiscal year, 2026 giving 2026-2027.
*&---------------------------------------------------------------------*
FORM fyear_from_gjahr USING    pv_gjahr TYPE gjahr
                      CHANGING pv_fyear TYPE zde_pnt_fyear.

  DATA: lv_year TYPE i,
        lv_next TYPE i.

  CLEAR pv_fyear.

  IF pv_gjahr IS INITIAL.
    RETURN.
  ENDIF.

  lv_year = pv_gjahr.
  lv_next = lv_year + 1.

  pv_fyear = |{ lv_year }-{ lv_next }|.

ENDFORM.

*&---------------------------------------------------------------------*
*& Take the descriptive fields from whichever forecast row supplied
*& them. Only fields still empty are filled, so the caller decides the
*& precedence by the order it calls this: annual first, then quarterly,
*& then monthly.
*&
*& ASSUMPTION: the material group columns show the codes stored on the
*& ASSUMPTION: forecast tables. The report does not re-read MVKE or the
*& ASSUMPTION: TVM1T / TVM2T / TVM5T texts, so that it reports the
*& ASSUMPTION: forecast exactly as it was saved.
*&---------------------------------------------------------------------*
FORM take_desc USING    pv_fcst_no TYPE zde_pnt_fcst_no
                        pv_maktx   TYPE maktx
                        pv_matkl   TYPE matkl
                        pv_mvgr1   TYPE mvgr1
                        pv_mvgr2   TYPE mvgr2
                        pv_mvgr5   TYPE mvgr5
               CHANGING cs_out     TYPE ty_out.

  IF cs_out-fcst_no IS INITIAL.
    cs_out-fcst_no = pv_fcst_no.
  ENDIF.
  IF cs_out-maktx IS INITIAL.
    cs_out-maktx = pv_maktx.
  ENDIF.
  IF cs_out-matkl IS INITIAL.
    cs_out-matkl = pv_matkl.
  ENDIF.
  IF cs_out-mvgr1 IS INITIAL.
    cs_out-mvgr1 = pv_mvgr1.
  ENDIF.
  IF cs_out-mvgr2 IS INITIAL.
    cs_out-mvgr2 = pv_mvgr2.
  ENDIF.
  IF cs_out-mvgr5 IS INITIAL.
    cs_out-mvgr5 = pv_mvgr5.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Full screen SALV list with the standard toolbar.
*&---------------------------------------------------------------------*
FORM display.

  DATA: lo_alv    TYPE REF TO cl_salv_table,
        lo_exc    TYPE REF TO cx_root,
        lv_msg    TYPE string,
        lv_header TYPE string.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_out ).

      lo_alv->get_functions( )->set_all( ).

      DATA(lo_cols) = lo_alv->get_columns( ).
      lo_cols->set_optimize( ).

      PERFORM heading USING lo_cols 'MATNR'     'Material'.
      PERFORM heading USING lo_cols 'WERKS'     'Plant'.
      PERFORM heading USING lo_cols 'MAKTX'     'Material Description'.
      PERFORM heading USING lo_cols 'MATKL'     'Material Group'.
      PERFORM heading USING lo_cols 'MVGR1'     'Material Group 1'.
      PERFORM heading USING lo_cols 'MVGR2'     'Material Group 2'.
      PERFORM heading USING lo_cols 'MVGR5'     'Material Group 5'.
      PERFORM heading USING lo_cols 'FYEAR'     'Financial Year'.
      PERFORM heading USING lo_cols 'ANNUAL'    'Annual Forecast'.
      PERFORM heading USING lo_cols 'QUARTER'   'Quarter'.
      PERFORM heading USING lo_cols 'QTR_FCST'  'Quarter Forecast'.
      PERFORM heading USING lo_cols 'QTR_ADD'   'Additional Forecast'.
      PERFORM heading USING lo_cols 'QTR_TOTAL' 'Total Quarter Forecast'.
      PERFORM heading USING lo_cols 'PERIOD'    'Period'.
      PERFORM heading USING lo_cols 'MTH_FCST'  'Monthly Forecast'.
      PERFORM heading USING lo_cols 'MTH_ADD'   'Additional Monthly Forecast'.
      PERFORM heading USING lo_cols 'MTH_TOTAL' 'Total Monthly Forecast'.
      PERFORM heading USING lo_cols 'FCST_NO'   'Forecast Number'.

      lv_header = 'ZFORECAST Paints - Forecast Report'.
      IF p_fyear IS NOT INITIAL.
        lv_header = |{ lv_header } - Financial Year { p_fyear }|.
      ENDIF.
      lo_alv->get_display_settings( )->set_list_header( lv_header ).

      lo_alv->display( ).

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error INTO lo_exc.
*     The list could not be built - tell the user instead of leaving a
*     blank screen or letting the exception dump.
      lv_msg = lo_exc->get_text( ).
      MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& Column heading.
*&
*& The ALV picks which of the three heading texts to draw from the
*& output length of the column - the short one below 10 characters, the
*& medium one below 20, the long one above that. A long heading on a
*& narrow numeric column is therefore drawn from the short text and cut
*& off. The width is set from the heading so the long text is chosen,
*& and SET_OPTIMIZE then widens further where the data needs it.
*&---------------------------------------------------------------------*
FORM heading USING po_cols TYPE REF TO cl_salv_columns_table
                   pv_name TYPE any
                   pv_text TYPE any.

  DATA: lv_text TYPE string,
        lv_len  TYPE lvc_outlen.

  lv_text = pv_text.
  lv_len  = strlen( lv_text ).

  IF lv_len < 10.
    lv_len = 10.
  ELSEIF lv_len > 40.
    lv_len = 40.
  ENDIF.

  TRY.
      DATA(lo_col) = po_cols->get_column( CONV lvc_fname( pv_name ) ).
      lo_col->set_long_text( CONV scrtext_l( lv_text ) ).
      lo_col->set_medium_text( CONV scrtext_m( lv_text ) ).
      lo_col->set_short_text( CONV scrtext_s( lv_text ) ).
      lo_col->set_output_length( lv_len ).
    CATCH cx_salv_not_found.
*     A column that is not in the list needs no heading.
  ENDTRY.

ENDFORM.
