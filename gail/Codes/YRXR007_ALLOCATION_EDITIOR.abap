*&---------------------------------------------------------------------*
*& Report YRXR007_ALLOCATION_EDITIOR
*& Adjustment of Delivery Allocated Quantity (Post Ticketing)
*&---------------------------------------------------------------------*
*& Per FS "Delivery Point Allocation Change":
*&  - User enters a single Contract ID (VBAK-VBELN) and multiple Gas
*&    Days, sees one line per nomination item with its current
*&    Delivery Allocation Qty and ticket status.
*&  - Delivery Allocation Qty (SM3) is editable only when the ticket
*&    check function returns LV_STATUS = 'COMPLETE'.
*&  - SAVE updates OIJNOMI-GA_ALLOCATED_QTY and recalculates the
*&    daily imbalance.
*&
*& NOTE: Function module YRGR_032_GMS_CT_FM and the imbalance-calc
*& reference (YRXU006_N / YRXR035_CASE2_ALLO_CASE2_NEW) do not exist
*& in S2A at the time of writing. Both are called/implemented here
*& exactly as the FS describes; verify the FM interface and the
*& imbalance formula against the real objects before transport.
*&---------------------------------------------------------------------*
REPORT yrxr007_allocation_editior.

TYPE-POOLS: icon.

TABLES: vbak, oijnomi.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:     p_vbeln TYPE vbak-vbeln OBLIGATORY.
SELECT-OPTIONS: s_idate FOR oijnomi-idate OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& Types
*&---------------------------------------------------------------------*
TYPES: BEGIN OF gty_alloc,
         idate         TYPE oijnomi-idate,        " Gas Day (IDATE of ZD/G)
         nomtk         TYPE oijnomi-nomtk,         " Nomination Key
         vbeln         TYPE oijnomi-docnr,         " Contract ID (DOCNR of ZD/G)
         locid         TYPE oijnomi-locid,         " Business Location (LOCID of ZD/G)
         partnr        TYPE oijnomi-partnr,        " Customer (PARTNR of ZD/G)
         alloc_qty     TYPE oijnomi-ga_allocated_qty, " Delivery Allocation Qty (SM3)
         ticket_status TYPE char20,                " Ticket Status (display text)
         lv_status     TYPE char20,                " LV_STATUS of FM
         nomit_zd      TYPE oijnomi-nomit,          " technical: NOMIT of ZD/G row
         nomit_zo      TYPE oijnomi-nomit,          " technical: NOMIT of ZO/K row (update key)
         editable      TYPE abap_bool,
         celltab       TYPE lvc_t_styl,
       END OF gty_alloc.

TYPES: BEGIN OF gty_zd,
         nomtk  TYPE oijnomi-nomtk,
         nomit  TYPE oijnomi-nomit,
         idate  TYPE oijnomi-idate,
         docnr  TYPE oijnomi-docnr,
         locid  TYPE oijnomi-locid,
         partnr TYPE oijnomi-partnr,
       END OF gty_zd.

TYPES: BEGIN OF gty_zo,
         nomtk            TYPE oijnomi-nomtk,
         nomit            TYPE oijnomi-nomit,
         ga_allocated_qty TYPE oijnomi-ga_allocated_qty,
       END OF gty_zo.

*&---------------------------------------------------------------------*
*& Global data
*&---------------------------------------------------------------------*
DATA: gt_zd         TYPE STANDARD TABLE OF gty_zd,
      gt_zo         TYPE STANDARD TABLE OF gty_zo,
      gt_alloc      TYPE STANDARD TABLE OF gty_alloc,
      gt_alloc_orig TYPE STANDARD TABLE OF gty_alloc.

DATA: go_grid TYPE REF TO cl_gui_alv_grid.

CONSTANTS: gc_auart_gta TYPE vbak-auart VALUE 'ZGT1'.

*&---------------------------------------------------------------------*
*& Event handler class - drives the SAVE toolbar button + inline edit
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
ENDCLASS.

DATA go_event_handler TYPE REF TO lcl_event_handler.

CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_toolbar.
    DATA ls_toolbar TYPE stb_button.
    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3. " separator
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    ls_toolbar-function  = 'SAVE'.
    ls_toolbar-icon      = icon_system_save.
    ls_toolbar-quickinfo = 'Save Delivery Allocation Qty changes'.
    ls_toolbar-text      = 'Save'(t01).
    ls_toolbar-disabled  = space.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    IF e_ucomm = 'SAVE'.
      PERFORM f_save_data.
    ENDIF.
  ENDMETHOD.

  METHOD handle_data_changed.
    " Edited cell values are pulled back into GT_ALLOC via
    " GO_GRID->CHECK_CHANGED_DATA, called from F_SAVE_DATA - nothing
    " additional required here.
  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN: Contract must be a GTA contract (AUART = ZGT1)
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_vbeln.
  IF p_vbeln IS NOT INITIAL.
    SELECT SINGLE auart FROM vbak
      INTO @DATA(lv_auart)
      WHERE vbeln = @p_vbeln.

    IF sy-subrc <> 0.
      MESSAGE 'Contract ID does not exist' TYPE 'E'.
    ELSEIF lv_auart <> gc_auart_gta.
      MESSAGE 'The contract is not GTA contract' TYPE 'E'.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_get_zd_data.
  PERFORM f_get_zo_data.
  PERFORM f_build_display_data.

  IF gt_alloc IS INITIAL.
    MESSAGE 'No delivery allocation lines found for the given selection' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    " Header note per FS: "Delivery Allocation can only be changed if
    " the ticket is completely posted for the entire GAIL Location or
    " NON-GAIL Customers."
    WRITE: / 'Delivery Allocation can only be changed if the ticket',
           / 'is completely posted for the entire GAIL Location or',
           / 'NON-GAIL Customers.'.
    SKIP.

    go_grid = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>screen0 ).
    go_event_handler = NEW lcl_event_handler( ).

    SET HANDLER go_event_handler->handle_toolbar     FOR go_grid.
    SET HANDLER go_event_handler->handle_user_command FOR go_grid.
    SET HANDLER go_event_handler->handle_data_changed FOR go_grid.

    PERFORM f_display_alv.
  ENDIF.

*&---------------------------------------------------------------------*
*& F_GET_ZD_DATA - nomination items for the contract/gas day (ZD/G)
*&---------------------------------------------------------------------*
FORM f_get_zd_data.
  SELECT nomtk nomit idate docnr locid partnr
    FROM oijnomi
    INTO TABLE gt_zd
    WHERE docnr  = p_vbeln
      AND idate  IN s_idate
      AND sityp  = 'ZD'
      AND docind = 'G'
      AND delind <> 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*& F_GET_ZO_DATA - allocated quantity for the same nomination (ZO/K)
*&---------------------------------------------------------------------*
FORM f_get_zo_data.
  IF gt_zd IS INITIAL.
    RETURN.
  ENDIF.

  SELECT nomtk nomit ga_allocated_qty
    FROM oijnomi
    INTO TABLE gt_zo
    FOR ALL ENTRIES IN gt_zd
    WHERE nomtk  = gt_zd-nomtk
      AND sityp  = 'ZO'
      AND docind = 'K'.
ENDFORM.

*&---------------------------------------------------------------------*
*& F_GET_TICKET_STATUS - wrapper around YRGR_032_GMS_CT_FM
*&---------------------------------------------------------------------*
FORM f_get_ticket_status USING    iv_idate  TYPE oijnomi-idate
                                   iv_partnr TYPE oijnomi-partnr
                          CHANGING cv_status TYPE char20.
  CLEAR cv_status.

  " TODO: confirm the real interface of YRGR_032_GMS_CT_FM once it is
  " available in this system - parameter names below follow the FS
  " wording ("pass IDATE & PARTNR") and are not yet verified.
  CALL FUNCTION 'YRGR_032_GMS_CT_FM'
    EXPORTING
      i_idate     = iv_idate
      i_partnr    = iv_partnr
    IMPORTING
      e_lv_status = cv_status
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc <> 0.
    cv_status = 'ERROR'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& F_BUILD_DISPLAY_DATA - merge ZD + ZO + ticket status, set styles
*&---------------------------------------------------------------------*
FORM f_build_display_data.
  DATA: ls_alloc  TYPE gty_alloc,
        ls_style  TYPE lvc_s_styl,
        lv_status TYPE char20.

  REFRESH gt_alloc.

  LOOP AT gt_zd INTO DATA(ls_zd).
    CLEAR ls_alloc.
    ls_alloc-idate    = ls_zd-idate.
    ls_alloc-nomtk    = ls_zd-nomtk.
    ls_alloc-vbeln    = ls_zd-docnr.
    ls_alloc-locid    = ls_zd-locid.
    ls_alloc-partnr   = ls_zd-partnr.
    ls_alloc-nomit_zd = ls_zd-nomit.

    READ TABLE gt_zo INTO DATA(ls_zo)
      WITH KEY nomtk = ls_zd-nomtk.
    IF sy-subrc = 0.
      ls_alloc-alloc_qty = ls_zo-ga_allocated_qty.
      ls_alloc-nomit_zo  = ls_zo-nomit.
    ENDIF.

    PERFORM f_get_ticket_status USING ls_zd-idate ls_zd-partnr
                                CHANGING lv_status.
    ls_alloc-lv_status     = lv_status.
    ls_alloc-ticket_status = lv_status.

    CLEAR ls_alloc-celltab.
    ls_style-fieldname = 'ALLOC_QTY'.
    IF lv_status = 'COMPLETE'.
      ls_alloc-editable = abap_true.
      ls_style-style    = cl_gui_alv_grid=>mc_style_enabled.
    ELSE.
      ls_alloc-editable = abap_false.
      ls_style-style    = cl_gui_alv_grid=>mc_style_disabled.
    ENDIF.
    INSERT ls_style INTO TABLE ls_alloc-celltab.

    APPEND ls_alloc TO gt_alloc.
  ENDLOOP.

  gt_alloc_orig = gt_alloc.
ENDFORM.

*&---------------------------------------------------------------------*
*& F_DISPLAY_ALV - build fieldcat and display the editable grid
*&---------------------------------------------------------------------*
FORM f_display_alv.
  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_fcat TYPE lvc_s_fcat,
        ls_layo TYPE lvc_s_layo.

  DEFINE add_fcat.
    CLEAR ls_fcat.
    ls_fcat-fieldname = &1.
    ls_fcat-coltext   = &2.
    ls_fcat-outputlen = &3.
    APPEND ls_fcat TO lt_fcat.
  END-OF-DEFINITION.

  add_fcat 'IDATE'         'Gas Day'                       10.
  add_fcat 'NOMTK'         'Nomination Key'                20.
  add_fcat 'VBELN'         'Contract ID'                   12.
  add_fcat 'LOCID'         'Business Location'             12.
  add_fcat 'PARTNR'        'Customer'                      12.
  add_fcat 'ALLOC_QTY'     'Delivery Allocation Qty (SM3)' 20. " cell-level edit via CELLTAB
  add_fcat 'TICKET_STATUS' 'Ticket Status'                 15.

  ls_layo-stylefname = 'CELLTAB'.
  ls_layo-cwidth_opt = abap_true.
  ls_layo-sel_mode   = 'A'.

  go_grid->set_table_for_first_display(
    EXPORTING
      is_layout       = ls_layo
    CHANGING
      it_outtab       = gt_alloc
      it_fieldcatalog = lt_fcat ).
ENDFORM.

*&---------------------------------------------------------------------*
*& F_SAVE_DATA - called from the SAVE toolbar button
*&---------------------------------------------------------------------*
FORM f_save_data.
  " pull whatever the user typed into the editable cells back into gt_alloc
  CALL METHOD go_grid->check_changed_data.
  CALL METHOD go_grid->refresh_table_display.

  LOOP AT gt_alloc INTO DATA(ls_new)
       WHERE editable = abap_true.

    READ TABLE gt_alloc_orig INTO DATA(ls_old)
      WITH KEY nomtk = ls_new-nomtk nomit_zo = ls_new-nomit_zo.

    CHECK sy-subrc = 0 AND ls_old-alloc_qty <> ls_new-alloc_qty.

    UPDATE oijnomi
       SET ga_allocated_qty = ls_new-alloc_qty
     WHERE nomtk  = ls_new-nomtk
       AND nomit  = ls_new-nomit_zo
       AND sityp  = 'ZO'
       AND docind = 'K'.

    IF sy-subrc = 0.
      PERFORM f_recalc_imbalance USING ls_new-nomtk ls_new-nomit_zo.
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.

  gt_alloc_orig = gt_alloc.
  MESSAGE 'Delivery allocation quantities saved' TYPE 'S'.
ENDFORM.

*&---------------------------------------------------------------------*
*& F_RECALC_IMBALANCE - recompute daily imbalance after a qty change
*&---------------------------------------------------------------------*
FORM f_recalc_imbalance USING iv_nomtk TYPE oijnomi-nomtk
                               iv_nomit TYPE oijnomi-nomit.

  " TODO: YRXU006_N / YRXR035_CASE2_ALLO_CASE2_NEW (the FS's reference
  " for the imbalance-recalculation loop at "lines 3271 & 3988") does
  " not exist in S2A, so the exact formula and target field(s) could
  " not be copied from a live object. This computes a candidate
  " imbalance (nominated ZD/G qty minus the newly saved ZO/K allocated
  " qty) as a stand-in; it is NOT written back anywhere yet because
  " the real target field name in OIJNOMI is unconfirmed. Replace this
  " form with the real logic once YRXU006_N is available.
  DATA: lv_nominated TYPE oijnomi-ga_allocated_qty,
        lv_allocated TYPE oijnomi-ga_allocated_qty,
        lv_imbalance TYPE oijnomi-ga_allocated_qty.

  SELECT SINGLE ga_allocated_qty FROM oijnomi
    INTO lv_nominated
    WHERE nomtk  = iv_nomtk
      AND sityp  = 'ZD'
      AND docind = 'G'.

  SELECT SINGLE ga_allocated_qty FROM oijnomi
    INTO lv_allocated
    WHERE nomtk  = iv_nomtk
      AND nomit  = iv_nomit
      AND sityp  = 'ZO'
      AND docind = 'K'.

  lv_imbalance = lv_nominated - lv_allocated.
ENDFORM.
