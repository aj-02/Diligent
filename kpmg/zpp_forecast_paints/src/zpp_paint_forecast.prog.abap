*&---------------------------------------------------------------------*
*& Report  ZPP_PAINT_FORECAST        Transaction  ZPFCST
*& ZFORECAST Paints - Forecast Generation
*&
*& Package        ZPP_PNT_FCST
*& Message class  ZPP_PFCST
*& Author         Arnav
*& Created        31.08.2026
*&
*& Three planning modes, chosen with a radio button. Each mode owns a
*& block of its own on the selection screen and only that block is
*& input ready:
*&
*&   Annual     P_ANN   financial year
*&   Quarterly  P_QTR   financial year, quarter or billing date range
*&   Monthly    P_MTH   financial year, period or billing date range
*&
*& The report selects no application data at all. The calculation lives
*& in ZCL_PP_PFCST and the date, conversion and authorisation helpers
*& in ZCL_PP_PFCST_UTIL. This program validates the selection, calls the
*& engine, draws the list and hands the rows the user picked back to the
*& engine to be saved.
*&
*& The list is drawn with CL_SALV_TABLE full screen. There is no screen,
*& no MODULE, no GUI status and no container anywhere in this program -
*& that is what keeps the object abapGit shippable and it must stay that
*& way. Rows are picked with the standard SALV selection column and Save
*& is a function added to the SALV toolbar.
*&
*& Built to Forecast Template-Paints.xlsx dated 31.08.2026
*&---------------------------------------------------------------------*
REPORT zpp_paint_forecast MESSAGE-ID zpp_pfcst.

TABLES sscrfields.

CONSTANTS: gc_mode_ann TYPE char1            VALUE 'A',
           gc_mode_qtr TYPE char1            VALUE 'Q',
           gc_mode_mth TYPE char1            VALUE 'M',
           gc_fc_save  TYPE salv_de_function VALUE 'ZSAVE',
           gc_actvt    TYPE activ_auth       VALUE '03'.

* Reference objects for the select options. The types come from the
* data element, so plant and material keep their standard search help
* without this program declaring TABLES on an application table.
DATA: gv_ref_werks TYPE werks_d,
      gv_ref_matnr TYPE matnr,
      gv_ref_date  TYPE dats.

DATA: gt_annual  TYPE zcl_pp_pfcst=>tt_annual,
      gt_quarter TYPE zcl_pp_pfcst=>tt_quarter,
      gt_month   TYPE zcl_pp_pfcst=>tt_month,
      go_alv     TYPE REF TO cl_salv_table,
      go_fcst    TYPE REF TO zcl_pp_pfcst,
      gv_mode    TYPE char1.

* Financial year, quarter and period the headings are built from. In
* date range mode nothing is typed in, so they are derived from the
* first date of the range instead.
DATA: gv_hfy  TYPE zde_pnt_fyear,
      gv_hq   TYPE zde_pnt_quarter,
      gv_hper TYPE poper.


*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_ann RADIOBUTTON GROUP mod USER-COMMAND mode DEFAULT 'X',
            p_qtr RADIOBUTTON GROUP mod,
            p_mth RADIOBUTTON GROUP mod.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
* Plant is NOT declared OBLIGATORY, even though the FS marks it
* mandatory. The screen checks a mandatory field on every PAI, including
* the click on a mode radio button, so an empty plant produces "fill out
* all required entry fields" before the user has chosen a mode - which
* looks exactly like the screen refusing to change. Same trap as the
* Adhesive report. It is checked by hand on Execute instead, message 001,
* which also covers a background run where no screen check happens.
SELECT-OPTIONS: s_werks FOR gv_ref_werks,
                s_matnr FOR gv_ref_matnr.
PARAMETERS: p_tonn   AS CHECKBOX,
            p_legacy AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.

* The financial year of a mode is NOT declared OBLIGATORY. A mandatory
* field is checked on every PAI, including the click on a mode radio
* button, so the screen would refuse to switch mode before the user had
* reached the field. It is checked by hand below and reported as 032.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
PARAMETERS p_fyear TYPE zde_pnt_fyear MODIF ID ann.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
PARAMETERS: p_qfyear TYPE zde_pnt_fyear   MODIF ID qtr,
            p_quart  TYPE zde_pnt_quarter MODIF ID qtr.
SELECT-OPTIONS s_qdate FOR gv_ref_date NO-EXTENSION MODIF ID qtr.
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE TEXT-b05.
PARAMETERS: p_mfyear TYPE zde_pnt_fyear MODIF ID mth,
            p_period TYPE poper         MODIF ID mth.
SELECT-OPTIONS s_mdate FOR gv_ref_date NO-EXTENSION MODIF ID mth.
SELECTION-SCREEN END OF BLOCK b5.


*&---------------------------------------------------------------------*
*& Toolbar handler
*&
*& The only function this program adds to the SALV toolbar is Save. It
*& saves the rows the user picked in the selection column - never the
*& whole list, because a forecast is written to the database and the
*& user has to be able to leave rows out.
*&---------------------------------------------------------------------*
CLASS lcl_alv DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS on_added_function
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

  PRIVATE SECTION.

    CLASS-METHODS save_selected.

    CLASS-METHODS report_save
      IMPORTING iv_fcst_no TYPE zde_pnt_fcst_no
                iv_werks   TYPE werks_d
                iv_update  TYPE abap_bool.

ENDCLASS.

CLASS lcl_alv IMPLEMENTATION.

  METHOD on_added_function.

*   Anything that is not the Save button is left to SALV itself
    CASE e_salv_function.
      WHEN gc_fc_save.
        save_selected( ).
      WHEN OTHERS.
        RETURN.
    ENDCASE.

  ENDMETHOD.


  METHOD save_selected.

    DATA: lt_rows TYPE salv_t_row,
          lv_row  TYPE i,
          lt_a    TYPE zcl_pp_pfcst=>tt_annual,
          lt_q    TYPE zcl_pp_pfcst=>tt_quarter,
          lt_m    TYPE zcl_pp_pfcst=>tt_month,
          ls_a    TYPE zcl_pp_pfcst=>ty_annual,
          ls_q    TYPE zcl_pp_pfcst=>ty_quarter,
          ls_m    TYPE zcl_pp_pfcst=>ty_month,
          lv_no   TYPE zde_pnt_fcst_no,
          lv_wrk  TYPE werks_d,
          lv_upd  TYPE abap_bool.

    FIELD-SYMBOLS: <ls_a> TYPE zcl_pp_pfcst=>ty_annual,
                   <ls_q> TYPE zcl_pp_pfcst=>ty_quarter,
                   <ls_m> TYPE zcl_pp_pfcst=>ty_month.

    IF go_alv IS NOT BOUND.
      RETURN.
    ENDIF.

    lt_rows = go_alv->get_selections( )->get_selected_rows( ).

    IF lt_rows IS INITIAL.
      MESSAGE s011 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    CASE gv_mode.

      WHEN gc_mode_ann.

        LOOP AT lt_rows INTO lv_row.
          CLEAR ls_a.
          READ TABLE gt_annual INTO ls_a INDEX lv_row.
          CHECK sy-subrc = 0.
          IF ls_a-fcst_no IS NOT INITIAL.
            lv_upd = abap_true.
          ENDIF.
          lv_wrk = ls_a-werks.
          APPEND ls_a TO lt_a.
        ENDLOOP.

        lv_no = go_fcst->save_annual( it_data = lt_a
                                           iv_fyear = gv_hfy ).

        IF lv_no IS INITIAL.
          MESSAGE s029 DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.

*       The number is written back so the list shows what was saved
        LOOP AT lt_rows INTO lv_row.
          READ TABLE gt_annual ASSIGNING <ls_a> INDEX lv_row.
          IF sy-subrc = 0.
            <ls_a>-fcst_no = lv_no.
          ENDIF.
        ENDLOOP.

      WHEN gc_mode_qtr.

        LOOP AT lt_rows INTO lv_row.
          CLEAR ls_q.
          READ TABLE gt_quarter INTO ls_q INDEX lv_row.
          CHECK sy-subrc = 0.
          IF ls_q-fcst_no IS NOT INITIAL.
            lv_upd = abap_true.
          ENDIF.
          lv_wrk = ls_q-werks.
          APPEND ls_q TO lt_q.
        ENDLOOP.

        lv_no = go_fcst->save_quarter( it_data = lt_q ).

        IF lv_no IS INITIAL.
          MESSAGE s029 DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.

        LOOP AT lt_rows INTO lv_row.
          READ TABLE gt_quarter ASSIGNING <ls_q> INDEX lv_row.
          IF sy-subrc = 0.
            <ls_q>-fcst_no = lv_no.
          ENDIF.
        ENDLOOP.

      WHEN OTHERS.

        LOOP AT lt_rows INTO lv_row.
          CLEAR ls_m.
          READ TABLE gt_month INTO ls_m INDEX lv_row.
          CHECK sy-subrc = 0.
          IF ls_m-fcst_no IS NOT INITIAL.
            lv_upd = abap_true.
          ENDIF.
          lv_wrk = ls_m-werks.
          APPEND ls_m TO lt_m.
        ENDLOOP.

        lv_no = go_fcst->save_month( it_data = lt_m ).

        IF lv_no IS INITIAL.
          MESSAGE s029 DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.

        LOOP AT lt_rows INTO lv_row.
          READ TABLE gt_month ASSIGNING <ls_m> INDEX lv_row.
          IF sy-subrc = 0.
            <ls_m>-fcst_no = lv_no.
          ENDIF.
        ENDLOOP.

    ENDCASE.

    go_alv->refresh( ).

    report_save( iv_fcst_no = lv_no
                 iv_werks   = lv_wrk
                 iv_update  = lv_upd ).

  ENDMETHOD.


  METHOD report_save.

*   A row that already carried a forecast number has been updated under
*   the number it already had, which is a different fact from a first
*   save and gets its own message.
    IF iv_update = abap_true.
      MESSAGE s030 WITH iv_fcst_no iv_werks DISPLAY LIKE 'I'.
    ELSE.
      MESSAGE s010 WITH iv_fcst_no iv_werks.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
INITIALIZATION.

* The financial year containing today, April to March, on all three
* modes so the user only corrects it when planning another year
  DATA(gv_year) = CONV i( sy-datum(4) ).
  IF sy-datum+4(2) < '04'.
    gv_year = gv_year - 1.
  ENDIF.

  p_fyear  = |{ gv_year }-{ gv_year + 1 }|.
  p_qfyear = p_fyear.
  p_mfyear = p_fyear.


*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

* Only the block belonging to the chosen mode is input ready. The other
* blocks stay on the screen, greyed out, so the user can see what the
* other modes ask for without switching to them.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'ANN'.
        screen-input = COND #( WHEN p_ann = abap_true THEN 1 ELSE 0 ).
      WHEN 'QTR'.
        screen-input = COND #( WHEN p_qtr = abap_true THEN 1 ELSE 0 ).
      WHEN 'MTH'.
        screen-input = COND #( WHEN p_mth = abap_true THEN 1 ELSE 0 ).
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.


*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

* Clicking a mode radio button raises PAI, so without this every check
* below would run while the user was still choosing the mode and would
* report fields they had not reached yet. Only the mode switch is
* skipped, so a background run with a blank function code is validated.
  IF sscrfields-ucomm = 'MODE'.
    RETURN.
  ENDIF.

  PERFORM check_selection.


*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM generate.

  IF gt_annual IS INITIAL AND gt_quarter IS INITIAL
                          AND gt_month   IS INITIAL.
*   Told, never left with an empty list and no explanation
    MESSAGE i007.
    RETURN.
  ENDIF.

  PERFORM display.


*&---------------------------------------------------------------------*
*& Selection screen checks
*&
*& Every one of them ends in a message from ZPP_PFCST. Nothing here is
*& allowed to dump or to pass a half filled selection to the engine.
*&---------------------------------------------------------------------*
FORM check_selection.

* LIKE LINE OF s_werks, not RSELOPTION - the generic select option line
* types LOW as CHAR 45, which is not compatible with WERKS_D
  DATA ls_w LIKE LINE OF s_werks.

  IF s_werks[] IS INITIAL.
    MESSAGE e001.
  ENDIF.

  CASE abap_true.

    WHEN p_ann.
      PERFORM check_annual.

    WHEN p_qtr.
      PERFORM check_quarter.

    WHEN p_mth.
      PERFORM check_month.

  ENDCASE.

* Display authorisation, plant by plant. Saving is checked again by the
* engine, which is a different activity from looking at the numbers.
  LOOP AT s_werks INTO ls_w.
    CHECK ls_w-low IS NOT INITIAL.
    IF zcl_pp_pfcst_util=>check_plant_auth(
         iv_werks = ls_w-low
         iv_actvt = gc_actvt ) = abap_false.
      MESSAGE e023 WITH ls_w-low.
    ENDIF.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
FORM check_annual.

  IF p_fyear IS INITIAL.
    MESSAGE e032.
  ENDIF.

  IF zcl_pp_pfcst_util=>is_fyear_valid( p_fyear ) = abap_false.
    MESSAGE e002 WITH p_fyear.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
FORM check_quarter.

  IF p_qfyear IS NOT INITIAL
     AND zcl_pp_pfcst_util=>is_fyear_valid( p_qfyear ) = abap_false.
    MESSAGE e002 WITH p_qfyear.
  ENDIF.

  IF p_quart IS NOT INITIAL AND p_qfyear IS INITIAL.
    MESSAGE e005.
  ENDIF.

  IF p_quart IS NOT INITIAL AND s_qdate[] IS NOT INITIAL.
*   Both were entered, which is not allowed either way. When the two
*   also contradict each other the mismatch is the more useful message,
*   so it is reported first.
    PERFORM check_qdate_match.
    MESSAGE e003.
  ENDIF.

  IF p_quart IS INITIAL AND s_qdate[] IS INITIAL.
    MESSAGE e004.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Does the date range lie inside the quarter that was typed in
*&---------------------------------------------------------------------*
FORM check_qdate_match.

  DATA: ls_r TYPE zcl_pp_pfcst_util=>ty_daterange,
        ls_d LIKE LINE OF s_qdate.

  CHECK p_qfyear IS NOT INITIAL.
  CHECK zcl_pp_pfcst_util=>is_fyear_valid( p_qfyear ) = abap_true.

  CLEAR ls_d.
  READ TABLE s_qdate INTO ls_d INDEX 1.
  CHECK sy-subrc = 0.

  ls_r = zcl_pp_pfcst_util=>get_quarter_range( iv_fyear   = p_qfyear
                                               iv_quarter = p_quart ).

  IF ls_d-low IS NOT INITIAL
     AND ( ls_d-low < ls_r-date_from OR ls_d-low > ls_r-date_to ).
    MESSAGE e026 WITH p_quart.
  ENDIF.

  IF ls_d-high IS NOT INITIAL
     AND ( ls_d-high < ls_r-date_from OR ls_d-high > ls_r-date_to ).
    MESSAGE e026 WITH p_quart.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
FORM check_month.

  IF p_mfyear IS NOT INITIAL
     AND zcl_pp_pfcst_util=>is_fyear_valid( p_mfyear ) = abap_false.
    MESSAGE e002 WITH p_mfyear.
  ENDIF.

  IF p_period IS NOT INITIAL AND p_mfyear IS INITIAL.
    MESSAGE e005.
  ENDIF.

* Message 031 is worded for the upload program, which reports a row
* number. There is no row here, so the first placeholder is left as a
* dash and the period itself is the second.
  IF p_period IS NOT INITIAL AND ( p_period < 1 OR p_period > 12 ).
    MESSAGE e031 WITH '-' p_period.
  ENDIF.

  IF p_period IS NOT INITIAL AND s_mdate[] IS NOT INITIAL.
    MESSAGE e003.
  ENDIF.

  IF p_period IS INITIAL AND s_mdate[] IS INITIAL.
    MESSAGE e004.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Generation
*&
*& Nothing is selected here. The engine is handed the selection exactly
*& as it was typed in - the derived financial year, quarter and period
*& below are for the column headings only.
*&---------------------------------------------------------------------*
FORM generate.

  DATA: ls_qd LIKE LINE OF s_qdate,
        ls_md LIKE LINE OF s_mdate.

  CLEAR: gt_annual, gt_quarter, gt_month, gv_hfy, gv_hq, gv_hper.

  gv_mode = COND char1( WHEN p_ann = abap_true THEN gc_mode_ann
                        WHEN p_qtr = abap_true THEN gc_mode_qtr
                        ELSE                        gc_mode_mth ).

  IF go_fcst IS NOT BOUND.
    CREATE OBJECT go_fcst.
  ENDIF.

  CASE gv_mode.

    WHEN gc_mode_ann.

      gv_hfy = p_fyear.

      gt_annual = go_fcst->generate_annual(
                    it_werks   = s_werks[]
                    it_matnr   = s_matnr[]
                    iv_fyear   = p_fyear
                    iv_legacy  = p_legacy
                    iv_tonnage = p_tonn ).

    WHEN gc_mode_qtr.

      CLEAR ls_qd.
      READ TABLE s_qdate INTO ls_qd INDEX 1.

      gv_hfy = p_qfyear.
      gv_hq  = p_quart.

      IF gv_hfy IS INITIAL AND ls_qd-low IS NOT INITIAL.
        gv_hfy = zcl_pp_pfcst_util=>get_fyear_from_date( ls_qd-low ).
      ENDIF.
      IF gv_hq IS INITIAL AND ls_qd-low IS NOT INITIAL.
        gv_hq = zcl_pp_pfcst_util=>get_quarter_from_date( ls_qd-low ).
      ENDIF.

      gt_quarter = go_fcst->generate_quarter(
                     it_werks     = s_werks[]
                     it_matnr     = s_matnr[]
                     iv_fyear     = p_qfyear
                     iv_quarter   = p_quart
                     iv_date_from = ls_qd-low
                     iv_date_to   = ls_qd-high
                     iv_legacy    = p_legacy
                     iv_tonnage   = p_tonn ).

    WHEN OTHERS.

      CLEAR ls_md.
      READ TABLE s_mdate INTO ls_md INDEX 1.

      gv_hfy  = p_mfyear.
      gv_hper = p_period.

      IF gv_hfy IS INITIAL AND ls_md-low IS NOT INITIAL.
        gv_hfy = zcl_pp_pfcst_util=>get_fyear_from_date( ls_md-low ).
      ENDIF.
      IF gv_hper IS INITIAL AND ls_md-low IS NOT INITIAL.
        gv_hper = zcl_pp_pfcst_util=>get_month_slot( ls_md-low ).
      ENDIF.

      gt_month = go_fcst->generate_month(
                   it_werks     = s_werks[]
                   it_matnr     = s_matnr[]
                   iv_fyear     = p_mfyear
                   iv_period    = p_period
                   iv_date_from = ls_md-low
                   iv_date_to   = ls_md-high
                   iv_legacy    = p_legacy
                   iv_tonnage   = p_tonn ).

  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*& Display
*&
*& One ALV over the table belonging to the mode. Full screen, so no
*& container and no GUI status of our own is needed.
*&---------------------------------------------------------------------*
FORM display.

  DATA: lv_head TYPE lvc_title,
        lv_what TYPE string.

  TRY.

      CASE gv_mode.
        WHEN gc_mode_ann.
          cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                                  CHANGING  t_table      = gt_annual ).
        WHEN gc_mode_qtr.
          cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                                  CHANGING  t_table      = gt_quarter ).
        WHEN OTHERS.
          cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                                  CHANGING  t_table      = gt_month ).
      ENDCASE.

      go_alv->get_functions( )->set_all( ).
      PERFORM add_save_function.

*     The standard selection column is what Save reads its rows from
      go_alv->get_selections( )->set_selection_mode(
        if_salv_c_selection_mode=>row_column ).

      SET HANDLER lcl_alv=>on_added_function FOR go_alv->get_event( ).

      go_alv->get_columns( )->set_optimize( ).

      CASE gv_mode.
        WHEN gc_mode_ann.
          PERFORM cols_annual.
        WHEN gc_mode_qtr.
          PERFORM cols_quarter.
        WHEN OTHERS.
          PERFORM cols_month.
      ENDCASE.

      lv_what = SWITCH string( gv_mode
                               WHEN gc_mode_ann THEN 'Annual'
                               WHEN gc_mode_qtr THEN 'Quarterly'
                               ELSE                  'Monthly' ).

      lv_head = |{ lv_what } forecast { gv_hfy }|.
      go_alv->get_display_settings( )->set_list_header( lv_head ).

      go_alv->display( ).

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error
          cx_salv_object_not_found INTO DATA(lx_salv).
*     The exception text is shown rather than a generic no data message,
*     which is what hid the real cause on the adhesive report
      DATA(lv_err) = lx_salv->get_text( ).
      MESSAGE lv_err TYPE 'E'.

  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& Save on the SALV toolbar
*&
*& ADD_FUNCTION is the call that puts a button of our own on the SALV
*& toolbar; SET_FUNCTION only switches a function SALV already knows
*& on or off and raises CX_SALV_NOT_FOUND for a code like ZSAVE.
*& If the release refuses the call the list is still shown, with a
*& warning, rather than dumping.
*&---------------------------------------------------------------------*
FORM add_save_function.

  DATA lv_msg TYPE string.

  TRY.
      go_alv->get_functions( )->add_function(
        name     = gc_fc_save
        text     = 'Save'
        tooltip  = 'Save the selected rows'
        position = if_salv_c_function_position=>right_of_salv_functions ).

    CATCH cx_salv_wrong_call cx_salv_existing.
      lv_msg = 'Save could not be added to the toolbar'.
      MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'W'.

  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& Column headings shared by all three modes
*&---------------------------------------------------------------------*
FORM cols_common.

  PERFORM alv_text USING 'WERKS'     'Plant'.
  PERFORM alv_text USING 'NAME1'     'Plant name'.
  PERFORM alv_text USING 'BRAND'     'Brand'.
  PERFORM alv_text USING 'MATNR'     'Material'.
  PERFORM alv_text USING 'MAKTX'     'Description'.
  PERFORM alv_text USING 'MTS_MTO'   'MTS / MTO'.
  PERFORM alv_text USING 'MVGR1'     'Material group 1'.
  PERFORM alv_text USING 'MVGR1_TXT' 'Material group 1 text'.
  PERFORM alv_text USING 'MATKL'     'Material group'.
  PERFORM alv_text USING 'PACK_SZ'   'Pack size'.
  PERFORM alv_text USING 'DPL'       'DPL'.
  PERFORM alv_text USING 'QTY_CTN'   'Qty per carton'.
  PERFORM alv_text USING 'MEINS'     'Base unit'.
  PERFORM alv_text USING 'GEWEI'     'Weight unit'.
  PERFORM alv_text USING 'BRGEW'     'Gross weight'.
  PERFORM alv_text USING 'PROD_CAT'  'Product category'.
  PERFORM alv_text USING 'LOAD_FCT'  'Load factor'.
  PERFORM alv_text USING 'FCST_NO'   'Forecast number'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Annual columns
*&
*& Twelve last year sales columns, twelve forecast columns and the
*& tonnage, volume and value columns behind them. Tonnage wise replaces
*& the quantity columns rather than adding to them, so the list stays
*& the width of the FS sheet.
*&---------------------------------------------------------------------*
FORM cols_annual.

  DATA: lv_slot TYPE i,
        lv_fy   TYPE i,
        lv_ly   TYPE i,
        lv_nn   TYPE n LENGTH 2,
        lv_mm   TYPE n LENGTH 2,
        lv_yy   TYPE n LENGTH 4,
        lv_nam  TYPE char3,
        lv_col  TYPE lvc_fname,
        lv_txt  TYPE string,
        lv_pre  TYPE string,
        lv_ok   TYPE abap_bool,
        lv_qty  TYPE abap_bool.

  PERFORM cols_common.

* The FS annual sheet draws MVGR1 as Material Group 1, MVGR3 as
* Material Group 2 and MVGR4 as Material Group 5. The headings follow
* the sheet, not the number in the field name.
  PERFORM alv_text USING 'MVGR3'     'Material group 2'.
  PERFORM alv_text USING 'MVGR3_TXT' 'Material group 2 text'.
  PERFORM alv_text USING 'MVGR4'     'Material group 5'.
  PERFORM alv_text USING 'MVGR4_TXT' 'Material group 5 text'.

  PERFORM alv_text USING 'LY_TOTAL'   'Total last year sales qty'.
  PERFORM alv_text USING 'FCST_TOTAL' 'Total forecast qty'.

  lv_ok = zcl_pp_pfcst_util=>is_fyear_valid( gv_hfy ).
  IF lv_ok = abap_true.
    lv_fy = gv_hfy(4).
    lv_ly = lv_fy - 1.
  ENDIF.

  lv_qty = COND #( WHEN p_tonn = abap_true THEN abap_false
                   ELSE abap_true ).

  DO 12 TIMES.

    lv_slot = sy-index.
    lv_nn   = lv_slot.

*   last year sales, the month the forecast of that month is derived
*   from
    lv_col = |M{ lv_nn }|.
    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_ly lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_txt = |{ lv_nam } { lv_yy+2(2) } sales qty|.
    ELSE.
      lv_txt = |Month { lv_nn } sales qty|.
    ENDIF.
    PERFORM alv_text USING lv_col lv_txt.

    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_fy lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_pre = |{ lv_nam } { lv_yy+2(2) }|.
    ELSE.
      lv_pre = |Month { lv_nn }|.
    ENDIF.

    lv_col = |M{ lv_nn }_FCST|.
    lv_txt = |{ lv_pre } forecast qty|.
    PERFORM alv_text USING lv_col lv_txt.
    PERFORM alv_show USING lv_col lv_qty.

    lv_col = |M{ lv_nn }_TON|.
    lv_txt = |{ lv_pre } tonnage|.
    PERFORM alv_text USING lv_col lv_txt.
    PERFORM alv_show USING lv_col p_tonn.

*   Volume and value are carried by the type in every mode, so they are
*   shown whether the list is quantity wise or tonnage wise
    lv_col = |M{ lv_nn }_KL|.
    lv_txt = |{ lv_pre } volume KL|.
    PERFORM alv_text USING lv_col lv_txt.

    lv_col = |M{ lv_nn }_CR|.
    lv_txt = |{ lv_pre } value in crores|.
    PERFORM alv_text USING lv_col lv_txt.

  ENDDO.

ENDFORM.


*&---------------------------------------------------------------------*
*& Quarterly columns
*&
*& M4..M6 are the three months of the quarter, M1..M3 the three months
*& in front of it. Both are headed with the real calendar month, which
*& is the only way a user can tell M4 from July.
*&---------------------------------------------------------------------*
FORM cols_quarter.

  DATA: lv_base TYPE i,
        lv_fy   TYPE i,
        lv_ly   TYPE i,
        lv_i    TYPE i,
        lv_slot TYPE i,
        lv_nn   TYPE n LENGTH 1,
        lv_mm   TYPE n LENGTH 2,
        lv_yy   TYPE n LENGTH 4,
        lv_nam  TYPE char3,
        lv_col  TYPE lvc_fname,
        lv_txt  TYPE string,
        lv_pre  TYPE string,
        lv_ok   TYPE abap_bool,
        lv_qty  TYPE abap_bool.

  PERFORM cols_common.

  PERFORM alv_text USING 'MVGR2'     'Material group 2'.
  PERFORM alv_text USING 'MVGR2_TXT' 'Material group 2 text'.
  PERFORM alv_text USING 'MVGR3'     'Material group 3'.
  PERFORM alv_text USING 'MVGR3_TXT' 'Material group 3 text'.
  PERFORM alv_text USING 'MVGR4'     'Material group 4'.
  PERFORM alv_text USING 'MVGR4_TXT' 'Material group 4 text'.
  PERFORM alv_text USING 'MVGR5'     'Material group 5'.
  PERFORM alv_text USING 'MVGR5_TXT' 'Material group 5 text'.

  PERFORM alv_text USING 'NTGEW'        'Net weight'.
  PERFORM alv_text USING 'LY_QTR_TOT'   'Total last year quarter qty'.
  PERFORM alv_text USING 'L3M_TOT'      'Last 3 months total sales qty'.
  PERFORM alv_text USING 'MAX_QTY'      'Maximum qty'.
  PERFORM alv_text USING 'FCST_QTY'     'Forecast qty'.
  PERFORM alv_text USING 'BUS_FCST'     'Business forecast'.
  PERFORM alv_text USING 'BUS_FCST_ADD' 'Business forecast addition'.
  PERFORM alv_text USING 'FINAL_QTY'    'Final forecast qty'.
  PERFORM alv_text USING 'GJAHR'        'Year'.
  PERFORM alv_text USING 'QUARTER'      'Quarter'.
  PERFORM alv_text USING 'REASON'       'Reason for change'.

  lv_ok = zcl_pp_pfcst_util=>is_fyear_valid( gv_hfy ).
  IF gv_hq IS INITIAL.
    lv_ok = abap_false.
  ENDIF.

  IF lv_ok = abap_true.
    lv_fy   = gv_hfy(4).
    lv_ly   = lv_fy - 1.
    lv_base = ( gv_hq - 1 ) * 3 + 1.
  ENDIF.

  lv_qty = COND #( WHEN p_tonn = abap_true THEN abap_false
                   ELSE abap_true ).

  DO 3 TIMES.

    lv_i = sy-index.
    lv_nn = lv_i + 3.

*   ---- the same three months, last year -----------------------------
    lv_slot = lv_base + lv_i - 1.
    lv_col  = |M{ lv_nn }_LAST|.
    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_ly lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_txt = |{ lv_nam } { lv_yy+2(2) } sales qty|.
    ELSE.
      lv_txt = |Last year month { lv_nn } sales qty|.
    ENDIF.
    PERFORM alv_text USING lv_col lv_txt.

*   ---- the three months in front of the quarter, this year ----------
    lv_slot = lv_base - 4 + lv_i.
    lv_col  = |M{ lv_i }_CURR|.
    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_fy lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_txt = |{ lv_nam } { lv_yy+2(2) } sales qty|.
    ELSE.
      lv_txt = |Current month { lv_i } sales qty|.
    ENDIF.
    PERFORM alv_text USING lv_col lv_txt.

*   ---- the forecast months ------------------------------------------
    lv_slot = lv_base + lv_i - 1.
    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_fy lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_pre = |{ lv_nam } { lv_yy+2(2) }|.
    ELSE.
      lv_pre = |Month { lv_nn }|.
    ENDIF.

    lv_col = |M{ lv_nn }_FCST|.
    lv_txt = |{ lv_pre } forecast qty|.
    PERFORM alv_text USING lv_col lv_txt.
    PERFORM alv_show USING lv_col lv_qty.

    lv_col = |M{ lv_nn }_TON|.
    lv_txt = |{ lv_pre } tonnage|.
    PERFORM alv_text USING lv_col lv_txt.
    PERFORM alv_show USING lv_col p_tonn.

    lv_col = |M{ lv_nn }_KL|.
    lv_txt = |{ lv_pre } volume KL|.
    PERFORM alv_text USING lv_col lv_txt.

    lv_col = |M{ lv_nn }_CR|.
    lv_txt = |{ lv_pre } value in crores|.
    PERFORM alv_text USING lv_col lv_txt.

  ENDDO.

ENDFORM.


*&---------------------------------------------------------------------*
*& Monthly columns
*&
*& The same shape as the quarter, but only the requested period is
*& forecast, so there is one forecast month instead of three.
*&---------------------------------------------------------------------*
FORM cols_month.

  DATA: lv_base TYPE i,
        lv_fy   TYPE i,
        lv_ly   TYPE i,
        lv_i    TYPE i,
        lv_slot TYPE i,
        lv_nn   TYPE n LENGTH 1,
        lv_mm   TYPE n LENGTH 2,
        lv_yy   TYPE n LENGTH 4,
        lv_nam  TYPE char3,
        lv_col  TYPE lvc_fname,
        lv_txt  TYPE string,
        lv_pre  TYPE string,
        lv_ok   TYPE abap_bool,
        lv_qty  TYPE abap_bool.

  PERFORM cols_common.

  PERFORM alv_text USING 'MVGR2'     'Material group 2'.
  PERFORM alv_text USING 'MVGR2_TXT' 'Material group 2 text'.
  PERFORM alv_text USING 'MVGR3'     'Material group 3'.
  PERFORM alv_text USING 'MVGR3_TXT' 'Material group 3 text'.
  PERFORM alv_text USING 'MVGR4'     'Material group 4'.
  PERFORM alv_text USING 'MVGR4_TXT' 'Material group 4 text'.
  PERFORM alv_text USING 'MVGR5'     'Material group 5'.
  PERFORM alv_text USING 'MVGR5_TXT' 'Material group 5 text'.

  PERFORM alv_text USING 'NTGEW'        'Net weight'.
  PERFORM alv_text USING 'LY_QTR_TOT'   'Total last year quarter qty'.
  PERFORM alv_text USING 'L3M_AVG'      'Last 3 months average qty'.
  PERFORM alv_text USING 'MAX_QTY'      'Maximum qty'.
  PERFORM alv_text USING 'FCST_QTY'     'Requirement qty'.
  PERFORM alv_text USING 'BUS_FCST'     'Business forecast'.
  PERFORM alv_text USING 'BUS_FCST_ADD' 'Business forecast addition'.
  PERFORM alv_text USING 'FINAL_QTY'    'Final forecast qty'.
  PERFORM alv_text USING 'GJAHR'        'Year'.
  PERFORM alv_text USING 'PERIOD'       'Period'.
  PERFORM alv_text USING 'REASON'       'Reason for change'.

  lv_ok = zcl_pp_pfcst_util=>is_fyear_valid( gv_hfy ).
  IF gv_hper IS INITIAL.
    lv_ok = abap_false.
  ENDIF.

  IF lv_ok = abap_true.
    lv_fy   = gv_hfy(4).
    lv_ly   = lv_fy - 1.
    lv_base = gv_hper.
  ENDIF.

  lv_qty = COND #( WHEN p_tonn = abap_true THEN abap_false
                   ELSE abap_true ).

* ---- three last year months from the requested month onwards --------
  DO 3 TIMES.

    lv_i    = sy-index.
    lv_nn   = lv_i + 3.
    lv_slot = lv_base + lv_i - 1.

    lv_col = |M{ lv_nn }_LAST|.
    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_ly lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_txt = |{ lv_nam } { lv_yy+2(2) } sales qty|.
    ELSE.
      lv_txt = |Last year month { lv_nn } sales qty|.
    ENDIF.
    PERFORM alv_text USING lv_col lv_txt.

*   ---- the three months in front of the requested month -------------
    lv_slot = lv_base - 4 + lv_i.
    lv_col  = |M{ lv_i }_CURR|.
    IF lv_ok = abap_true.
      PERFORM slot_month USING lv_fy lv_slot CHANGING lv_mm lv_yy.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_txt = |{ lv_nam } { lv_yy+2(2) } sales qty|.
    ELSE.
      lv_txt = |Current month { lv_i } sales qty|.
    ENDIF.
    PERFORM alv_text USING lv_col lv_txt.

  ENDDO.

* ---- the one forecast month -----------------------------------------
  IF lv_ok = abap_true.
    PERFORM slot_month USING lv_fy lv_base CHANGING lv_mm lv_yy.
    PERFORM month_name USING lv_mm CHANGING lv_nam.
    lv_pre = |{ lv_nam } { lv_yy+2(2) }|.
  ELSE.
    lv_pre = 'Forecast month'.
  ENDIF.

  lv_txt = |{ lv_pre } forecast qty|.
  PERFORM alv_text USING 'M4_FCST' lv_txt.
  PERFORM alv_show USING 'M4_FCST' lv_qty.

  lv_txt = |{ lv_pre } tonnage|.
  PERFORM alv_text USING 'M4_TON' lv_txt.
  PERFORM alv_show USING 'M4_TON' p_tonn.

  lv_txt = |{ lv_pre } volume KL|.
  PERFORM alv_text USING 'M4_KL' lv_txt.

  lv_txt = |{ lv_pre } value in crores|.
  PERFORM alv_text USING 'M4_CR' lv_txt.

ENDFORM.


*&---------------------------------------------------------------------*
*& Heading of one column
*&
*& ALV picks WHICH of the three heading texts to draw from the column
*& output length - the short one below 10 characters, the medium one
*& below 20, the long one above that. A long heading on a narrow
*& numeric column is therefore drawn from the short text and cut off.
*& The width is set from the heading so the long text is chosen and
*& set_optimize then widens further where the data needs it.
*&---------------------------------------------------------------------*
FORM alv_text USING pv_col TYPE any
                    pv_txt TYPE any.

  DATA: lv_txt TYPE string,
        lv_len TYPE lvc_outlen.

  lv_txt = pv_txt.
  lv_len = strlen( lv_txt ).
  IF lv_len < 10.
    lv_len = 10.
  ELSEIF lv_len > 40.
    lv_len = 40.
  ENDIF.

  TRY.
      DATA(lo_col) = go_alv->get_columns( )->get_column(
                       CONV lvc_fname( pv_col ) ).
      lo_col->set_short_text( CONV scrtext_s( lv_txt ) ).
      lo_col->set_medium_text( CONV scrtext_m( lv_txt ) ).
      lo_col->set_long_text( CONV scrtext_l( lv_txt ) ).
      lo_col->set_output_length( lv_len ).
    CATCH cx_salv_not_found.
*     A column the mode does not carry is simply not headed
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& Show or hide one column. Tonnage wise and quantity wise are the same
*& list with different columns visible, never a second ALV.
*&---------------------------------------------------------------------*
FORM alv_show USING pv_col TYPE any
                    pv_on  TYPE any.

  DATA lv_on TYPE salv_de_visible.

  lv_on = pv_on.

  TRY.
      go_alv->get_columns( )->get_column(
        CONV lvc_fname( pv_col ) )->set_visible( lv_on ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& Calendar month and year of a slot of the financial year
*&
*& Slot 1 is April of the first year of the financial year. Slots below
*& 1 are the months in front of it, which is how the three months
*& before quarter 1 land in January to March, and slots above 12 the
*& months after it. The arithmetic runs on a month index so no case
*& distinction is needed.
*&---------------------------------------------------------------------*
FORM slot_month USING    pv_fy   TYPE any
                         pv_slot TYPE any
                CHANGING cv_mm   TYPE any
                         cv_yy   TYPE any.

  DATA: lv_abs  TYPE i,
        lv_year TYPE i,
        lv_slot TYPE i.

  lv_year = pv_fy.
  lv_slot = pv_slot.

* month index, zero based: year * 12 + ( month - 1 ), April = 3
  lv_abs = lv_year * 12 + 3 + lv_slot - 1.

  cv_yy = lv_abs DIV 12.
  cv_mm = lv_abs MOD 12 + 1.

ENDFORM.


*&---------------------------------------------------------------------*
FORM month_name USING    pv_mm   TYPE any
                CHANGING cv_name TYPE any.

  CONSTANTS lc_names TYPE char36
    VALUE 'JanFebMarAprMayJunJulAugSepOctNovDec'.

  DATA: lv_i   TYPE i,
        lv_off TYPE i.

  CLEAR cv_name.

  lv_i = pv_mm.
  CHECK lv_i >= 1 AND lv_i <= 12.

  lv_off  = ( lv_i - 1 ) * 3.
  cv_name = lc_names+lv_off(3).

ENDFORM.
