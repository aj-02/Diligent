*&---------------------------------------------------------------------*
*& Module pool   SAPMZSD_SCHEME
*& Package       ZSD_SCHEME
*& Description   Scheme (Pipes) - Create / Change / Display
*&               Transactions ZSCHM01 / ZSCHM02 / ZSCHM03
*&
*& Created by    Arnav Johri
*& Reference     FS "Scheme - Pipes" V.01 10.08.2026, assumptions A01-A42
*&
*& Screens       0100 initial · 0200 maintain
*&               0210 subscreen selection criteria · 0220 subscreen ratio
*& Layout        see 01_SCREEN_LAYOUT.md
*&---------------------------------------------------------------------*
PROGRAM sapmzsd_scheme MESSAGE-ID zsd_scheme.

INCLUDE zsd_scheme_top.                "global data
INCLUDE zsd_scheme_cls.                "local ALV event handler
INCLUDE zsd_scheme_o01.                "PBO modules
INCLUDE zsd_scheme_i01.                "PAI modules
INCLUDE zsd_scheme_f01.                "subroutines


*&---------------------------------------------------------------------*
*& INCLUDE ZSD_SCHEME_TOP
*&---------------------------------------------------------------------*
TABLES: zsdt_schm_hdr,                 "screen 0200 fields
        zsds_schm_ini.                 "screen 0100 fields

TYPES: BEGIN OF ty_rng_alv.
         INCLUDE TYPE zsdt_schm_rng.
TYPES:   fld_text TYPE char40,
         low_text TYPE char40,
         celltab  TYPE lvc_t_styl,
       END OF ty_rng_alv,
       tt_rng_alv TYPE STANDARD TABLE OF ty_rng_alv WITH DEFAULT KEY.

TYPES: BEGIN OF ty_rat_alv.
         INCLUDE TYPE zsdt_schm_rat.
TYPES:   maktx TYPE maktx,
       END OF ty_rat_alv,
       tt_rat_alv TYPE STANDARD TABLE OF ty_rat_alv WITH DEFAULT KEY.

DATA: g_ok_code    TYPE sy-ucomm,
      g_save_ok    TYPE sy-ucomm,
      g_mode       TYPE char1,                      "H create V change A display
      g_subscreen  TYPE sy-dynnr VALUE '0210',
      g_changed    TYPE abap_bool,
      txt_h_statt  TYPE char20,                     "status description, screen 0200
      ratio_total  TYPE zde_schm_pct.               "ratio running total, screen 0220

DATA: go_scheme    TYPE REF TO zcl_sd_scheme.

DATA: gt_rng_alv   TYPE tt_rng_alv,
      gt_rat_alv   TYPE tt_rat_alv.

DATA: go_cc_sel    TYPE REF TO cl_gui_custom_container,
      go_cc_rat    TYPE REF TO cl_gui_custom_container,
      go_grid_sel  TYPE REF TO cl_gui_alv_grid,
      go_grid_rat  TYPE REF TO cl_gui_alv_grid,
      go_handler   TYPE REF TO lcl_alv_handler.

CONTROLS: ts_main TYPE TABSTRIP.

DATA: BEGIN OF g_ts_main,
        subscreen   TYPE sy-dynnr VALUE '0210',
        prog        TYPE sy-repid VALUE 'SAPMZSD_SCHEME',
        pressed_tab TYPE sy-ucomm VALUE 'TAB1',
      END OF g_ts_main.

CONSTANTS: c_tab1 TYPE sy-ucomm VALUE 'TAB1',
           c_tab2 TYPE sy-ucomm VALUE 'TAB2'.


*&---------------------------------------------------------------------*
*& INCLUDE ZSD_SCHEME_CLS
*& Local handler for both ALV grids on screens 0210 / 0220.
*&---------------------------------------------------------------------*
CLASS lcl_alv_handler DEFINITION.

  PUBLIC SECTION.

    METHODS on_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed e_onf4 sender.

    METHODS on_data_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
      IMPORTING e_modified.

    METHODS on_f4
      FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname es_row_no er_event_data.

ENDCLASS.

CLASS lcl_alv_handler IMPLEMENTATION.

*&---------------------------------------------------------------------*
  METHOD on_data_changed.

    " Defaults and consistency on the selection-criteria grid
    LOOP AT er_data_changed->mt_good_cells INTO DATA(ls_cell).

      CASE ls_cell-fieldname.

        WHEN 'FIELDNAME'.
          " Description column follows the chosen field
          er_data_changed->modify_cell(
            i_row_id    = ls_cell-row_id
            i_fieldname = 'FLD_TEXT'
            i_value     = zcl_sd_scheme_ui=>get_field_text( CONV #( ls_cell-value ) ) ).

        WHEN 'LOW'.
          " "Select All" is one CP * line (A05)
          IF ls_cell-value CS '*'.
            er_data_changed->modify_cell( i_row_id    = ls_cell-row_id
                                          i_fieldname = 'OPTI'
                                          i_value     = 'CP' ).
          ENDIF.

        WHEN 'RATIO_PCT'.
          g_changed = abap_true.

        WHEN OTHERS.
      ENDCASE.

      " Every new line defaults to Include / Equal
      er_data_changed->modify_cell( i_row_id    = ls_cell-row_id
                                    i_fieldname = 'SIGN'
                                    i_value     = 'I' ).
    ENDLOOP.

    g_changed = abap_true.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD on_data_changed_finished.

    CHECK e_modified = abap_true.

    " Keep the ratio total on screen 0220 live (A12)
    go_grid_rat->check_changed_data( ).
    ratio_total = REDUCE zde_schm_pct( INIT s = CONV zde_schm_pct( 0 )
                                       FOR ls IN gt_rat_alv
                                       NEXT s = s + ls-ratio_pct ).
    g_changed = abap_true.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Value help on the LOW / HIGH columns switches with the FIELDNAME of
*& the row, so one grid serves all seven selection fields.
*&---------------------------------------------------------------------*
  METHOD on_f4.

    FIELD-SYMBOLS <lt_mod> TYPE lvc_t_modi.

    READ TABLE gt_rng_alv INTO DATA(ls_row) INDEX es_row_no-row_id.
    CHECK sy-subrc = 0.

    DATA(lv_value) = zcl_sd_scheme_ui=>f4_for_field(
                       iv_fieldname = ls_row-fieldname
                       iv_vkorg     = zsdt_schm_hdr-vkorg
                       iv_vtweg     = zsdt_schm_hdr-vtweg
                       iv_spart     = zsdt_schm_hdr-spart ).

    CHECK lv_value IS NOT INITIAL.

    ASSIGN er_event_data->m_data->* TO <lt_mod>.
    APPEND VALUE lvc_s_modi( row_id    = es_row_no-row_id
                             fieldname = e_fieldname
                             value     = lv_value ) TO <lt_mod>.

    er_event_data->m_event_handled = abap_true.

  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
*& INCLUDE ZSD_SCHEME_O01  -  PBO
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'S0100'.
  SET TITLEBAR  'T0100'.

  " Mode comes from the transaction parameter (ZSCHM01/02/03)
  IF g_mode IS INITIAL.
    g_mode = COND #( WHEN zsds_schm_ini-mode IS NOT INITIAL THEN zsds_schm_ini-mode
                     ELSE zcl_sd_scheme=>gc_mode-display ).
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE init_0100 OUTPUT.

  LOOP AT SCREEN.

    CASE screen-group1.
      WHEN 'SNO'.
        " Scheme number only in change / display
        screen-input = COND #( WHEN g_mode = zcl_sd_scheme=>gc_mode-create THEN 0 ELSE 1 ).
      WHEN 'HDR'.
        " Key attributes only in create (A04)
        screen-input = COND #( WHEN g_mode = zcl_sd_scheme=>gc_mode-create THEN 1 ELSE 0 ).
      WHEN OTHERS.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  DATA lt_excl TYPE STANDARD TABLE OF sy-ucomm.

  CLEAR lt_excl.

  IF g_mode = zcl_sd_scheme=>gc_mode-display.
    APPEND: 'SAVE' TO lt_excl, 'DELE' TO lt_excl, 'RELE' TO lt_excl.
  ELSE.
    " Frozen once anything has been settled (A34)
    IF go_scheme->is_change_allowed( ) = abap_false.
      APPEND: 'SAVE' TO lt_excl, 'DELE' TO lt_excl, 'RELE' TO lt_excl.
    ENDIF.
    " Release only from status New
    IF zsdt_schm_hdr-status <> zcl_sd_scheme=>gc_status-new.
      APPEND 'RELE' TO lt_excl.
    ENDIF.
  ENDIF.

  SET PF-STATUS 'S0200' EXCLUDING lt_excl.
  SET TITLEBAR  'T0200' WITH zsdt_schm_hdr-scheme_no
                             SWITCH string( g_mode
                                            WHEN 'H' THEN 'Create'
                                            WHEN 'V' THEN 'Change'
                                            ELSE          'Display' ).

  txt_h_statt = SWITCH #( zsdt_schm_hdr-status
                          WHEN 'N' THEN 'New'
                          WHEN 'R' THEN 'Released'
                          WHEN 'P' THEN 'Partially Settled'
                          WHEN 'C' THEN 'Closed' ).

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE init_0200 OUTPUT.

  ts_main-activetab = g_ts_main-pressed_tab.
  g_subscreen       = g_ts_main-subscreen.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Field control on the maintain screen. Category drives which target
*& field is visible (A10-A13); the early bird block disappears entirely
*& when the indicator is not set (A22).
*&---------------------------------------------------------------------*
MODULE modify_screen_0200 OUTPUT.

  DATA(lv_display) = xsdbool( g_mode = zcl_sd_scheme=>gc_mode-display
                           OR go_scheme->is_change_allowed( ) = abap_false ).

  CASE screen-group1.

    WHEN 'EB'.
      IF zsdt_schm_hdr-early_bird <> abap_true.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.

    WHEN 'VAL'.
      IF zsdt_schm_hdr-scheme_cat = zcl_sd_scheme=>gc_category-quantity.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.

    WHEN 'QTY'.
      IF zsdt_schm_hdr-scheme_cat <> zcl_sd_scheme=>gc_category-quantity.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

  IF screen-group1 = 'CHG' AND lv_display = abap_true.
    screen-input = 0.
  ENDIF.

  MODIFY SCREEN.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Tab 2 is only offered for ratio based categories (A12)
*&---------------------------------------------------------------------*
MODULE prepare_alv_0200 OUTPUT.

  IF zsdt_schm_hdr-scheme_cat <> zcl_sd_scheme=>gc_category-ratio
 AND zsdt_schm_hdr-scheme_cat <> zcl_sd_scheme=>gc_category-val_ratio
 AND g_ts_main-pressed_tab     = c_tab2.
    g_ts_main-pressed_tab = c_tab1.
    g_ts_main-subscreen   = '0210'.
    ts_main-activetab     = c_tab1.
    g_subscreen           = '0210'.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE pbo_0210 OUTPUT.

  PERFORM build_grid_sel.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE pbo_0220 OUTPUT.

  PERFORM build_grid_rat.

ENDMODULE.


*&---------------------------------------------------------------------*
*& INCLUDE ZSD_SCHEME_I01  -  PAI
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.

  CASE g_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE check_vkorg INPUT.

  CHECK g_mode = zcl_sd_scheme=>gc_mode-create.
  CHECK zsds_schm_ini-vkorg IS NOT INITIAL.

  SELECT SINGLE @abap_true FROM tvko INTO @DATA(lv_ok)
    WHERE vkorg = @zsds_schm_ini-vkorg.
  IF lv_ok <> abap_true.
    MESSAGE e015 WITH zsds_schm_ini-vkorg space space.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE check_vtweg INPUT.

  CHECK g_mode = zcl_sd_scheme=>gc_mode-create.
  CHECK zsds_schm_ini-vtweg IS NOT INITIAL.

  SELECT SINGLE @abap_true FROM tvtw INTO @DATA(lv_ok)
    WHERE vtweg = @zsds_schm_ini-vtweg.
  IF lv_ok <> abap_true.
    MESSAGE e015 WITH zsds_schm_ini-vkorg zsds_schm_ini-vtweg space.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE check_spart INPUT.

  CHECK g_mode = zcl_sd_scheme=>gc_mode-create.
  CHECK zsds_schm_ini-spart IS NOT INITIAL.

  " Complete sales area must exist
  SELECT SINGLE @abap_true FROM tvta INTO @DATA(lv_ok)
    WHERE vkorg = @zsds_schm_ini-vkorg
      AND vtweg = @zsds_schm_ini-vtweg
      AND spart = @zsds_schm_ini-spart.
  IF lv_ok <> abap_true.
    MESSAGE e015 WITH zsds_schm_ini-vkorg zsds_schm_ini-vtweg zsds_schm_ini-spart.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE f4_scheme_no INPUT.

  PERFORM f4_scheme_no.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  g_save_ok = g_ok_code.
  CLEAR g_ok_code.

  CASE g_save_ok.

    WHEN 'CONT' OR space.

      CREATE OBJECT go_scheme
        EXPORTING iv_mode = g_mode.

      DATA lt_msg TYPE bapiret2_t.

      IF g_mode = zcl_sd_scheme=>gc_mode-create.

        IF zsds_schm_ini-valid_from IS INITIAL OR zsds_schm_ini-valid_to IS INITIAL.
          MESSAGE e003.
        ENDIF.
        IF zsds_schm_ini-valid_to < zsds_schm_ini-valid_from.
          MESSAGE e004.
        ENDIF.

        lt_msg = go_scheme->create_new( zsds_schm_ini ).

      ELSE.

        IF zsds_schm_ini-scheme_no IS INITIAL.
          MESSAGE e001 WITH space.
        ENDIF.

        lt_msg = go_scheme->read(
                   iv_scheme_no = CONV #( |{ zsds_schm_ini-scheme_no ALPHA = IN }| )
                   iv_lock      = xsdbool( g_mode = zcl_sd_scheme=>gc_mode-change ) ).
      ENDIF.

      PERFORM raise_first_error USING lt_msg.

      PERFORM transfer_to_screen.

      CALL SCREEN 0200.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE exit_0200 INPUT.

  CASE g_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM leave_0200.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  g_save_ok = g_ok_code.
  CLEAR g_ok_code.

  " Pull any open cell edits out of the grids before acting on them
  IF go_grid_sel IS BOUND. go_grid_sel->check_changed_data( ). ENDIF.
  IF go_grid_rat IS BOUND. go_grid_rat->check_changed_data( ). ENDIF.

  CASE g_save_ok.

    WHEN c_tab1.
      g_ts_main-pressed_tab = c_tab1.
      g_ts_main-subscreen   = '0210'.

    WHEN c_tab2.
      g_ts_main-pressed_tab = c_tab2.
      g_ts_main-subscreen   = '0220'.

    WHEN 'SAVE'.
      PERFORM save_scheme.

    WHEN 'RELE'.
      PERFORM release_scheme.

    WHEN 'DELE'.
      PERFORM delete_scheme.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& INCLUDE ZSD_SCHEME_F01  -  subroutines
*&---------------------------------------------------------------------*
FORM transfer_to_screen.

  CLEAR: gt_rng_alv, gt_rat_alv.

  zsdt_schm_hdr = go_scheme->get_header( ).

  LOOP AT go_scheme->get_ranges( ) INTO DATA(ls_rng).
    APPEND VALUE ty_rng_alv( BASE CORRESPONDING #( ls_rng )
                             fld_text = zcl_sd_scheme_ui=>get_field_text( ls_rng-fieldname ) )
      TO gt_rng_alv.
  ENDLOOP.

  LOOP AT go_scheme->get_ratio( ) INTO DATA(ls_rat).
    SELECT SINGLE maktx FROM makt INTO @DATA(lv_maktx)
      WHERE matnr = @ls_rat-matnr AND spras = @sy-langu.
    APPEND VALUE ty_rat_alv( BASE CORRESPONDING #( ls_rat )
                             maktx = lv_maktx ) TO gt_rat_alv.
  ENDLOOP.

  ratio_total = REDUCE zde_schm_pct( INIT s = CONV zde_schm_pct( 0 )
                                     FOR ls IN gt_rat_alv
                                     NEXT s = s + ls-ratio_pct ).
  CLEAR g_changed.

ENDFORM.

*&---------------------------------------------------------------------*
FORM transfer_from_screen.

  go_scheme->set_header( zsdt_schm_hdr ).

  go_scheme->set_ranges(
    VALUE #( FOR ls IN gt_rng_alv ( CORRESPONDING #( ls ) ) ) ).

  go_scheme->set_ratio(
    VALUE #( FOR ls IN gt_rat_alv ( CORRESPONDING #( ls ) ) ) ).

ENDFORM.

*&---------------------------------------------------------------------*
FORM save_scheme.

  PERFORM transfer_from_screen.

  DATA(lt_msg) = go_scheme->save( ).

  IF line_exists( lt_msg[ type = 'E' ] ).
    PERFORM show_log USING lt_msg.
    RETURN.
  ENDIF.

  PERFORM transfer_to_screen.
  CLEAR g_changed.

  MESSAGE s018 WITH zsdt_schm_hdr-scheme_no.

ENDFORM.

*&---------------------------------------------------------------------*
FORM release_scheme.

  PERFORM transfer_from_screen.

  IF g_changed = abap_true.
    DATA(lt_save) = go_scheme->save( ).
    IF line_exists( lt_save[ type = 'E' ] ).
      PERFORM show_log USING lt_save.
      RETURN.
    ENDIF.
  ENDIF.

  DATA(lt_msg) = go_scheme->release( ).

  IF line_exists( lt_msg[ type = 'E' ] ).
    PERFORM show_log USING lt_msg.
    RETURN.
  ENDIF.

  PERFORM transfer_to_screen.
  MESSAGE s019 WITH zsdt_schm_hdr-scheme_no.

ENDFORM.

*&---------------------------------------------------------------------*
FORM delete_scheme.

  DATA lv_answer TYPE char1.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING titlebar              = 'Delete Scheme'
              text_question         = |Delete scheme { zsdt_schm_hdr-scheme_no }?|
              default_button        = '2'
              display_cancel_button = abap_false
    IMPORTING answer                = lv_answer
    EXCEPTIONS OTHERS               = 1.

  CHECK lv_answer = '1'.

  DATA(lt_msg) = go_scheme->delete( ).

  IF line_exists( lt_msg[ type = 'E' ] ).
    PERFORM show_log USING lt_msg.
    RETURN.
  ENDIF.

  MESSAGE s020 WITH zsdt_schm_hdr-scheme_no.
  PERFORM leave_0200.

ENDFORM.

*&---------------------------------------------------------------------*
FORM leave_0200.

  IF g_changed = abap_true AND g_mode <> zcl_sd_scheme=>gc_mode-display.

    DATA lv_answer TYPE char1.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING titlebar              = 'Exit'
                text_question         = 'Data has changed. Leave without saving?'
                default_button        = '2'
                display_cancel_button = abap_true
      IMPORTING answer                = lv_answer
      EXCEPTIONS OTHERS               = 1.

    CHECK lv_answer = '1'.
  ENDIF.

  go_scheme->dequeue( ).

  IF go_grid_sel IS BOUND. go_grid_sel->free( ). CLEAR go_grid_sel. ENDIF.
  IF go_grid_rat IS BOUND. go_grid_rat->free( ). CLEAR go_grid_rat. ENDIF.
  IF go_cc_sel   IS BOUND. go_cc_sel->free( ).   CLEAR go_cc_sel.   ENDIF.
  IF go_cc_rat   IS BOUND. go_cc_rat->free( ).   CLEAR go_cc_rat.   ENDIF.

  CLEAR: g_changed, go_scheme.

  LEAVE TO SCREEN 0.

ENDFORM.

*&---------------------------------------------------------------------*
*& Selection-criteria grid, screen 0210
*&---------------------------------------------------------------------*
FORM build_grid_sel.

  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_layo TYPE lvc_s_layo,
        lt_excl TYPE ui_functions.

  IF go_grid_sel IS BOUND.
    go_grid_sel->refresh_table_display( is_stable = VALUE #( row = abap_true col = abap_true ) ).
    RETURN.
  ENDIF.

  CREATE OBJECT go_cc_sel
    EXPORTING container_name = 'CC_SEL'.

  CREATE OBJECT go_grid_sel
    EXPORTING i_parent = go_cc_sel.

  DATA(lv_edit) = xsdbool( g_mode <> zcl_sd_scheme=>gc_mode-display
                       AND go_scheme->is_change_allowed( ) = abap_true ).

  lt_fcat = VALUE #(
    ( fieldname = 'FIELDNAME' coltext = 'Field'       outputlen = 12 edit = lv_edit
      drdn_hndl = '1' )
    ( fieldname = 'FLD_TEXT'  coltext = 'Description' outputlen = 24 )
    ( fieldname = 'SIGN'      coltext = 'I/E'         outputlen = 3  edit = lv_edit
      drdn_hndl = '2' )
    ( fieldname = 'OPTI'      coltext = 'Option'      outputlen = 4  edit = lv_edit
      drdn_hndl = '3' )
    ( fieldname = 'LOW'       coltext = 'From'        outputlen = 20 edit = lv_edit
      f4availabl = abap_true )
    ( fieldname = 'HIGH'      coltext = 'To'          outputlen = 20 edit = lv_edit
      f4availabl = abap_true ) ).

  ls_layo = VALUE #( cwidth_opt = abap_true
                     zebra      = abap_true
                     sel_mode   = 'D'
                     grid_title = 'Selection Criteria' ).

  " Insert / delete / append are the FS's "insert, change, delete"
  lt_excl = VALUE #(
    ( cl_gui_alv_grid=>mc_fc_graph )
    ( cl_gui_alv_grid=>mc_fc_info )
    ( cl_gui_alv_grid=>mc_fc_loc_undo )
    ( cl_gui_alv_grid=>mc_fc_print ) ).

  IF lv_edit = abap_false.
    APPEND: cl_gui_alv_grid=>mc_fc_loc_insert_row  TO lt_excl,
            cl_gui_alv_grid=>mc_fc_loc_append_row  TO lt_excl,
            cl_gui_alv_grid=>mc_fc_loc_delete_row  TO lt_excl,
            cl_gui_alv_grid=>mc_fc_loc_copy_row    TO lt_excl.
  ENDIF.

  PERFORM build_dropdowns.

  IF go_handler IS NOT BOUND.
    CREATE OBJECT go_handler.
  ENDIF.

  SET HANDLER go_handler->on_data_changed          FOR go_grid_sel.
  SET HANDLER go_handler->on_data_changed_finished FOR go_grid_sel.
  SET HANDLER go_handler->on_f4                    FOR go_grid_sel.

  go_grid_sel->register_edit_event(
    i_event_id = cl_gui_alv_grid=>mc_evt_modified ).

  go_grid_sel->register_f4_for_fields(
    it_f4 = VALUE lvc_t_f4( ( fieldname = 'LOW'  register = abap_true chngeafter = abap_true )
                            ( fieldname = 'HIGH' register = abap_true chngeafter = abap_true ) ) ).

  go_grid_sel->set_table_for_first_display(
    EXPORTING is_layout            = ls_layo
              it_toolbar_excluding = lt_excl
    CHANGING  it_fieldcatalog      = lt_fcat
              it_outtab            = gt_rng_alv ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Product-ratio grid, screen 0220
*&---------------------------------------------------------------------*
FORM build_grid_rat.

  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_layo TYPE lvc_s_layo.

  IF go_grid_rat IS BOUND.
    go_grid_rat->refresh_table_display( is_stable = VALUE #( row = abap_true col = abap_true ) ).
    RETURN.
  ENDIF.

  CREATE OBJECT go_cc_rat
    EXPORTING container_name = 'CC_RAT'.

  CREATE OBJECT go_grid_rat
    EXPORTING i_parent = go_cc_rat.

  DATA(lv_edit) = xsdbool( g_mode <> zcl_sd_scheme=>gc_mode-display
                       AND go_scheme->is_change_allowed( ) = abap_true ).

  lt_fcat = VALUE #(
    ( fieldname = 'SEQNR'     coltext = 'Item'      outputlen = 5 )
    ( fieldname = 'MATNR'     coltext = 'Material'  outputlen = 18 edit = lv_edit
      ref_table = 'ZSDT_SCHM_RAT' ref_field = 'MATNR' f4availabl = abap_true )
    ( fieldname = 'MAKTX'     coltext = 'Description' outputlen = 40 )
    ( fieldname = 'RATIO_PCT' coltext = 'Ratio %'   outputlen = 8  edit = lv_edit ) ).

  ls_layo = VALUE #( cwidth_opt = abap_true
                     zebra      = abap_true
                     grid_title = 'Product Ratio' ).

  IF go_handler IS NOT BOUND.
    CREATE OBJECT go_handler.
  ENDIF.

  SET HANDLER go_handler->on_data_changed          FOR go_grid_rat.
  SET HANDLER go_handler->on_data_changed_finished FOR go_grid_rat.

  go_grid_rat->register_edit_event(
    i_event_id = cl_gui_alv_grid=>mc_evt_modified ).

  go_grid_rat->set_table_for_first_display(
    EXPORTING is_layout       = ls_layo
    CHANGING  it_fieldcatalog = lt_fcat
              it_outtab       = gt_rat_alv ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Dropdown values for FIELDNAME / SIGN / OPTI on the ranges grid
*&---------------------------------------------------------------------*
FORM build_dropdowns.

  DATA lt_drop TYPE lvc_t_drop.

  lt_drop = VALUE #(
    " handle 1 - selection field (mirrors domain ZDO_SCHM_FLD)
    ( handle = '1' value = 'MVGR1' ) ( handle = '1' value = 'MVGR2' )
    ( handle = '1' value = 'MVGR3' ) ( handle = '1' value = 'MVGR4' )
    ( handle = '1' value = 'MVGR5' ) ( handle = '1' value = 'REGIO' )
    ( handle = '1' value = 'KUNNR' ) ( handle = '1' value = 'KVGR1' )
    ( handle = '1' value = 'KVGR2' )
    " ZONE1 / ZONE2 are added here once Q8 is answered (A06)
    " handle 2 - include / exclude (A05)
    ( handle = '2' value = 'I' ) ( handle = '2' value = 'E' )
    " handle 3 - option
    ( handle = '3' value = 'EQ' ) ( handle = '3' value = 'NE' )
    ( handle = '3' value = 'BT' ) ( handle = '3' value = 'NB' )
    ( handle = '3' value = 'CP' ) ( handle = '3' value = 'GE' )
    ( handle = '3' value = 'LE' ) ).

  go_grid_sel->set_drop_down_table( it_drop_down = lt_drop ).

ENDFORM.

*&---------------------------------------------------------------------*
FORM f4_scheme_no.

  DATA lt_ret TYPE STANDARD TABLE OF ddshretval.

  SELECT scheme_no, descr, scheme_type, scheme_cat,
         valid_from, valid_to, status
    FROM zsdt_schm_hdr
    INTO TABLE @DATA(lt_help)
    WHERE del_ind = @space
    ORDER BY scheme_no DESCENDING.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING retfield        = 'SCHEME_NO'
              dynpprog        = sy-repid
              dynpnr          = sy-dynnr
              dynprofield     = 'ZSDS_SCHM_INI-SCHEME_NO'
              value_org       = 'S'
    TABLES    value_tab       = lt_help
              return_tab      = lt_ret
    EXCEPTIONS OTHERS         = 1.

ENDFORM.

*&---------------------------------------------------------------------*
FORM raise_first_error USING pt_msg TYPE bapiret2_t.

  READ TABLE pt_msg INTO DATA(ls_msg) WITH KEY type = 'E'.
  CHECK sy-subrc = 0.

  MESSAGE ID ls_msg-id TYPE 'E' NUMBER ls_msg-number
    WITH ls_msg-message_v1 ls_msg-message_v2
         ls_msg-message_v3 ls_msg-message_v4.

ENDFORM.

*&---------------------------------------------------------------------*
FORM show_log USING pt_msg TYPE bapiret2_t.

  IF lines( pt_msg ) = 1.
    READ TABLE pt_msg INTO DATA(ls_one) INDEX 1.
    MESSAGE ID ls_one-id TYPE 'S' NUMBER ls_one-number
      WITH ls_one-message_v1 ls_one-message_v2
           ls_one-message_v3 ls_one-message_v4
      DISPLAY LIKE ls_one-type.
    RETURN.
  ENDIF.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT pt_msg INTO DATA(ls_msg).
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING arbgb                  = ls_msg-id
                msgty                  = ls_msg-type
                msgv1                  = ls_msg-message_v1
                msgv2                  = ls_msg-message_v2
                msgv3                  = ls_msg-message_v3
                msgv4                  = ls_msg-message_v4
                txtnr                  = ls_msg-number
      EXCEPTIONS OTHERS                = 1.
  ENDLOOP.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING  show_linno = abap_false
    EXCEPTIONS OTHERS     = 1.

ENDFORM.
