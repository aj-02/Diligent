*&---------------------------------------------------------------------*
*& Report  ZR_JV_POST
*& JV Transfer: Colombia OCV->OVL | Cutback | NB | Corporate Items
*& Z Tables:
*&   ZJV_MAP_COCODE - JV/Recovery Indicator -> Receiving Co.Code
*&   ZJV_MAP_GL     - GL Account Mapping
*&   ZJV_MAP_RCNTR  - Cost Center Mapping
*&   ZJV_MAP_WBS    - WBS Element Mapping
*&   ZJV_MAP_PRCTR  - Profit Center Mapping
*& Source Table:
*&   JVSO1          - JV Accounting (Ledgers 4A / 4C)
*&---------------------------------------------------------------------*
REPORT zr_jv_post.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: jvso1.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*TYPES: BEGIN OF ty_jv_map,
*         op_bukrs  TYPE bukrs,
*         op_vname  TYPE jv_name,
*         op_recid  TYPE jv_recind,
*         offset_gl TYPE zfi_offset_capexgl,
*         rec_bukrs TYPE bukrs,
*       END OF ty_jv_map.
TYPES: BEGIN OF ty_jv_map,
         op_bukrs  TYPE zfi_de_send_bukrs,
         op_vname  TYPE zfi_de_send_venture,
         op_recid  TYPE jv_recind,
         offset_gl TYPE allgkonto,
         type      TYPE zfi_de_type,   " indicates whether OFFSET_GL is a vendor or GL account
         rec_bukrs TYPE zfi_de_rec_bukrs,
       END OF ty_jv_map.

*TYPES: BEGIN OF ty_gl_map,
*         op_bukrs  TYPE bukrs,
*         op_saknr  TYPE saknr,
*         rec_bukrs TYPE bukrs,
*         rec_saknr TYPE saknr,
*       END OF ty_gl_map.
TYPES: BEGIN OF ty_gl_map,
         op_bukrs      TYPE bukrs,
         op_saknr      TYPE saknr,
         rec_bukrs     TYPE bukrs,
         rec_saknr     TYPE saknr,
         default_kostl TYPE kostl,   " NEW
         default_prctr TYPE prctr,   " NEW
       END OF ty_gl_map.

TYPES: BEGIN OF ty_rcntr_map,
         op_bukrs  TYPE bukrs,
         op_kostl  TYPE kostl,
         rec_bukrs TYPE bukrs,
         rec_kostl TYPE kostl,
       END OF ty_rcntr_map.

TYPES: BEGIN OF ty_wbs_map,
         op_bukrs  TYPE bukrs,
         op_posid  TYPE ps_posid,
         rec_bukrs TYPE bukrs,
         rec_posid TYPE ps_posid,
       END OF ty_wbs_map.

TYPES: BEGIN OF ty_prctr_map,
         op_bukrs  TYPE bukrs,
         op_prctr  TYPE prctr,
         rec_bukrs TYPE bukrs,
         rec_prctr TYPE prctr,
       END OF ty_prctr_map.

TYPES: BEGIN OF ty_jvso1,
  GL_SIRID type GU_RECID,
         rldnr  TYPE rldnr,
         rbukrs TYPE bukrs,
         rrcty  TYPE rrcty,
         rvers  TYPE rvers,
         ryear  TYPE gjahr,
         poper  TYPE poper,
         rjvnam TYPE jv_name,
         rrecin TYPE jv_recind,
         racct  TYPE racct,
         regrou TYPE jv_egroup,
         rcntr  TYPE kostl,
         rordnr TYPE aufnr,
         rprojk TYPE ps_psp_pnr,
         rprctr TYPE prctr,
         budat  TYPE budat,
         tsl    TYPE vtcur9,
         hsl    TYPE vlcur9,
         ksl    TYPE vgcur9,
       END OF ty_jvso1.

*TYPES: BEGIN OF ty_subtotal,
*         rbukrs     TYPE bukrs,
*         rjvnam     TYPE jv_name,
*         rrecin     TYPE jv_recind,
*         racct      TYPE racct,
*         rcntr      TYPE kostl,
*         rordnr     TYPE aufnr,
*         rprojk     TYPE ps_psp_pnr,
*         rprctr     TYPE prctr,
*         budat      TYPE budat,
*         tsl        TYPE vtcur9,
*         hsl        TYPE vlcur9,
*         ksl        TYPE vgcur9,
*         recv_bukrs TYPE bukrs,
*         recv_saknr TYPE saknr,
*         recv_kostl TYPE kostl,
*         recv_posid TYPE ps_posid,
*         recv_prctr TYPE prctr,
*         send_curr  TYPE waers,
*         recv_curr  TYPE waers,
*         post_date  TYPE budat,
*       END OF ty_subtotal.
TYPES: BEGIN OF ty_subtotal,
         rbukrs        TYPE bukrs,
         rjvnam        TYPE jv_name,
         rrecin        TYPE jv_recind,
         racct         TYPE racct,
         rcntr         TYPE kostl,
         rordnr        TYPE aufnr,
         rprojk        TYPE ps_psp_pnr,
         rprctr        TYPE prctr,
         budat         TYPE budat,
         tsl           TYPE vtcur9,
         hsl           TYPE vlcur9,
         ksl           TYPE vgcur9,
         recv_bukrs    TYPE bukrs,
         recv_saknr    TYPE saknr,
         recv_kostl    TYPE kostl,
         recv_posid    TYPE ps_posid,
         recv_prctr    TYPE prctr,
         default_kostl TYPE kostl,   " NEW - carried from ZJV_MAP_GL
         default_prctr TYPE prctr,   " NEW - carried from ZJV_MAP_GL
         send_curr     TYPE waers,
         recv_curr     TYPE waers,
         post_date     TYPE budat,
       END OF ty_subtotal.

TYPES: BEGIN OF ty_alv_result,
         msgty      TYPE bapi_mtype,
         comp_code  TYPE bukrs,
         doc_number TYPE belnr_d,
         message    TYPE string,
       END OF ty_alv_result.

*----------------------------------------------------------------------*
* INTERNAL TABLES
*----------------------------------------------------------------------*
DATA: gt_jv_map     TYPE TABLE OF ty_jv_map,
      gt_gl_map     TYPE TABLE OF ty_gl_map,
      gt_rcntr_map  TYPE TABLE OF ty_rcntr_map,
      gt_wbs_map    TYPE TABLE OF ty_wbs_map,
      gt_prctr_map  TYPE TABLE OF ty_prctr_map,
      gt_jvso1      TYPE TABLE OF ty_jvso1,
      gt_subtotal   TYPE TABLE OF ty_subtotal,
      gt_alv_result TYPE TABLE OF ty_alv_result.

DATA: GS_JV_MAP_TRF TYPE ZJV_MAP_TRF.

*----------------------------------------------------------------------*
* WORK AREAS
*----------------------------------------------------------------------*
DATA: gs_jvso1      TYPE ty_jvso1,
      gs_jv_map     TYPE ty_jv_map,
      gs_gl_map     TYPE ty_gl_map,
      gs_rcntr_map  TYPE ty_rcntr_map,
      gs_wbs_map    TYPE ty_wbs_map,
      gs_prctr_map  TYPE ty_prctr_map,
      gs_alv_result TYPE ty_alv_result.

*----------------------------------------------------------------------*
* BAPI Structures
*----------------------------------------------------------------------*
DATA: gs_doc_header     TYPE bapiache09,
      gt_accountgl      TYPE TABLE OF bapiacgl09,
      gt_currencyamount TYPE TABLE OF bapiaccr09,
      gt_return         TYPE TABLE OF bapiret2,
      gs_accountgl      TYPE bapiacgl09,
      gs_currencyamount TYPE bapiaccr09,
      gs_return         TYPE bapiret2,
      gv_obj_type       TYPE bapiache09-obj_type,
      gv_obj_key        TYPE bapiache09-obj_key,
      gv_obj_sys        TYPE bapiache09-obj_sys.

DATA: gt_accountpayable TYPE STANDARD TABLE OF bapiacap09,
      gs_accountpayable TYPE bapiacap09.

*----------------------------------------------------------------------*
* VARIABLES
*----------------------------------------------------------------------*
DATA: gv_test_run  TYPE abap_bool,
      gv_post_date TYPE budat,         " posting date for the current batch
      lt_racct     TYPE RANGE OF saknr,
      ls_racct     LIKE LINE OF lt_racct.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE sel_par.
PARAMETERS:
  p_bukrs TYPE bukrs OBLIGATORY,
  p_gjahr TYPE gjahr OBLIGATORY,
  p_poper TYPE poper OBLIGATORY,
  p_jv    TYPE jv_name OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE proc_op.
PARAMETERS:
  p_test TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  sel_par = 'Selection Parameters'.
  proc_op = 'Processing Options'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*


START-OF-SELECTION.



  gv_test_run = p_test.

  PERFORM load_mapping_tables.
  perform validate_posting.
  PERFORM read_jvso1.
  PERFORM aggregate_subtotals.
  PERFORM apply_mappings.
  PERFORM determine_cost_element.
   PERFORM resolve_wbs_element.
  PERFORM post_documents.
  PERFORM display_summary.

*----------------------------------------------------------------------*
* FORM: LOAD_MAPPING_TABLES
*----------------------------------------------------------------------*
FORM load_mapping_tables.

*  SELECT op_bukrs op_vname op_recid offset_gl rec_bukrs
**    rec_vname rec_recid
*    FROM zjv_map_cocode
*    INTO TABLE gt_jv_map
*   WHERE op_bukrs = p_bukrs.
SELECT op_bukrs op_vname op_recid offset_gl type rec_bukrs
  FROM zjv_map_cocode
  INTO TABLE gt_jv_map
 WHERE op_bukrs = p_bukrs.

*  SELECT op_bukrs op_saknr rec_bukrs rec_saknr
*    FROM zjv_map_gl
*    INTO TABLE gt_gl_map
*   WHERE op_bukrs = p_bukrs.
SELECT op_bukrs op_saknr rec_bukrs rec_saknr default_kostl default_prctr
  FROM zjv_map_gl
  INTO TABLE gt_gl_map
 WHERE op_bukrs = p_bukrs.

  " Build account range from the mapped GLs (FIX #5: was inside sy-subrc block;
  " moved out so it is always built whenever gt_gl_map has data).
  CLEAR lt_racct.
  LOOP AT gt_gl_map INTO DATA(ls_gl).
    CLEAR ls_racct.
    ls_racct-sign   = 'I'.
    ls_racct-option = 'EQ'.
    ls_racct-low    = ls_gl-op_saknr.
    APPEND ls_racct TO lt_racct.
  ENDLOOP.

  SELECT op_bukrs op_kostl rec_bukrs rec_kostl
    FROM zjv_map_rcntr
    INTO TABLE gt_rcntr_map
   WHERE op_bukrs = p_bukrs.

  SELECT op_bukrs op_posid rec_bukrs rec_posid
    FROM zjv_map_wbs
    INTO TABLE gt_wbs_map
   WHERE op_bukrs = p_bukrs.

  SELECT op_bukrs op_prctr rec_bukrs rec_prctr
    FROM zjv_map_prctr
    INTO TABLE gt_prctr_map
   WHERE op_bukrs = p_bukrs.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: READ_JVSO1
*----------------------------------------------------------------------*
FORM read_jvso1.

  " FIX #5: Guard against empty driver tables. Empty FOR ALL ENTRIES
  " or empty IN-range would otherwise pull the entire JVSO1 table.
  IF gt_jv_map IS INITIAL OR lt_racct IS INITIAL.
    APPEND VALUE #( msgty   = 'E'
                    message = 'Mapping tables (JV / GL) are empty - nothing to read'
                  ) TO gt_alv_result.
    RETURN.
  ENDIF.

  SELECT GL_SIRID, rldnr, rbukrs, rrcty, rvers, ryear, poper, rjvnam, rrecin, racct,
         regrou, rcntr, rordnr, rprojk, rprctr, budat, tsl, hsl, ksl
    FROM jvso1
    INTO TABLE @gt_jvso1
    FOR ALL ENTRIES IN @gt_jv_map
   WHERE rldnr  IN ('4A')
     AND rrcty  =  '0'
     AND rvers  =  '001'
     AND rbukrs =  @p_bukrs
     AND ryear  =  @p_gjahr
     AND poper  =  @p_poper
     AND rjvnam =  @p_jv
     AND rrecin =  @gt_jv_map-op_recid
     AND racct  IN @lt_racct.

  IF gt_jvso1 IS INITIAL.
    " FIX #6: do not raise an 'E' message inside S-O-S - it short dumps.
    APPEND VALUE #( msgty   = 'I'
                    message = 'No JVSO1 records found for the given selection'
                  ) TO gt_alv_result.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: AGGREGATE_SUBTOTALS
*----------------------------------------------------------------------*
FORM aggregate_subtotals.
  DATA: ls_sub TYPE ty_subtotal.
  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.

  SORT gt_jvso1 BY rbukrs rjvnam rrecin racct rcntr rordnr rprojk rprctr.

  LOOP AT gt_jvso1 INTO gs_jvso1.
    READ TABLE gt_subtotal ASSIGNING <fs_sub>
      WITH KEY rbukrs = gs_jvso1-rbukrs
               rjvnam = gs_jvso1-rjvnam
**               rrecin = gs_jvso1-rrecin
               racct  = gs_jvso1-racct
               rcntr  = gs_jvso1-rcntr.
*               rordnr = gs_jvso1-rordnr
*               rprojk = gs_jvso1-rprojk
*               rprctr = gs_jvso1-rprctr.
    IF sy-subrc = 0.
      <fs_sub>-tsl = <fs_sub>-tsl + gs_jvso1-tsl.
      <fs_sub>-hsl = <fs_sub>-hsl + gs_jvso1-hsl.
      <fs_sub>-ksl = <fs_sub>-ksl + gs_jvso1-ksl.
      " Keep the latest BUDAT in the same group so post_date calc is stable
      IF gs_jvso1-budat > <fs_sub>-budat.
        <fs_sub>-budat = gs_jvso1-budat.
      ENDIF.
    ELSE.
      CLEAR ls_sub.
      ls_sub-rbukrs = gs_jvso1-rbukrs.
      ls_sub-rjvnam = gs_jvso1-rjvnam.
      ls_sub-rrecin = gs_jvso1-rrecin.
      ls_sub-racct  = gs_jvso1-racct.
      ls_sub-rcntr  = gs_jvso1-rcntr.
      ls_sub-rordnr = gs_jvso1-rordnr.
      ls_sub-rprojk = gs_jvso1-rprojk.
      ls_sub-rprctr = gs_jvso1-rprctr.
      ls_sub-budat  = gs_jvso1-budat.
      ls_sub-tsl    = gs_jvso1-tsl.
      ls_sub-hsl    = gs_jvso1-hsl.
      ls_sub-ksl    = gs_jvso1-ksl.
      APPEND ls_sub TO gt_subtotal.
    ENDIF.
  ENDLOOP.
ENDFORM.
*FORM aggregate_subtotals.
*  DATA: ls_sub TYPE ty_subtotal.
*  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
*
*  SORT gt_jvso1 BY rbukrs rjvnam rrecin racct rcntr rordnr rprojk rprctr.
*
*  LOOP AT gt_jvso1 INTO gs_jvso1.
*    READ TABLE gt_subtotal ASSIGNING <fs_sub>
*      WITH KEY rbukrs = gs_jvso1-rbukrs
*               rjvnam = gs_jvso1-rjvnam
*               rrecin = gs_jvso1-rrecin
*               racct  = gs_jvso1-racct
*               rcntr  = gs_jvso1-rcntr
*               rordnr = gs_jvso1-rordnr
*               rprojk = gs_jvso1-rprojk
*               rprctr = gs_jvso1-rprctr.
*    IF sy-subrc = 0.
*      <fs_sub>-tsl = <fs_sub>-tsl + gs_jvso1-tsl.
*      <fs_sub>-hsl = <fs_sub>-hsl + gs_jvso1-hsl.
*      <fs_sub>-ksl = <fs_sub>-ksl + gs_jvso1-ksl.
*      IF gs_jvso1-budat > <fs_sub>-budat.
*        <fs_sub>-budat = gs_jvso1-budat.
*      ENDIF.
*    ELSE.
*      CLEAR ls_sub.
*      ls_sub-rbukrs = gs_jvso1-rbukrs.
*      ls_sub-rjvnam = gs_jvso1-rjvnam.
*      ls_sub-rrecin = gs_jvso1-rrecin.
*      ls_sub-racct  = gs_jvso1-racct.
*      ls_sub-rcntr  = gs_jvso1-rcntr.
*      ls_sub-rordnr = gs_jvso1-rordnr.
*      ls_sub-rprojk = gs_jvso1-rprojk.
*      ls_sub-rprctr = gs_jvso1-rprctr.
*      ls_sub-budat  = gs_jvso1-budat.
*      ls_sub-tsl    = gs_jvso1-tsl.
*      ls_sub-hsl    = gs_jvso1-hsl.
*      ls_sub-ksl    = gs_jvso1-ksl.
*      APPEND ls_sub TO gt_subtotal.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.

*----------------------------------------------------------------------*
* FORM: APPLY_MAPPINGS
*----------------------------------------------------------------------*
FORM apply_mappings.
*  DATA: lv_last_day TYPE d.
*  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
*
*  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
*
*    " JV / Recovery Indicator -> Receiving Co.Code
*    READ TABLE gt_jv_map INTO gs_jv_map
*      WITH KEY op_bukrs = <fs_sub>-rbukrs
*               op_vname = <fs_sub>-rjvnam
*               op_recid = <fs_sub>-rrecin.
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*    <fs_sub>-recv_bukrs = gs_jv_map-rec_bukrs.
*
*    " GL mapping
*    READ TABLE gt_gl_map INTO gs_gl_map
*      WITH KEY op_bukrs  = <fs_sub>-rbukrs
*               op_saknr  = <fs_sub>-racct
*               rec_bukrs = <fs_sub>-recv_bukrs.
*    IF sy-subrc = 0.
*      <fs_sub>-recv_saknr = gs_gl_map-rec_saknr.
*    ENDIF.
*
*    " Cost center mapping
*    IF <fs_sub>-rcntr IS NOT INITIAL.
*      READ TABLE gt_rcntr_map INTO gs_rcntr_map
*        WITH KEY op_bukrs  = <fs_sub>-rbukrs
*                 op_kostl  = <fs_sub>-rcntr
*                 rec_bukrs = <fs_sub>-recv_bukrs.
*      IF sy-subrc = 0.
*        <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
*      ENDIF.
*    ENDIF.
*
*    " WBS mapping
*    IF <fs_sub>-rprojk IS NOT INITIAL.
*      READ TABLE gt_wbs_map INTO gs_wbs_map
*        WITH KEY op_bukrs  = <fs_sub>-rbukrs
*                 op_posid  = <fs_sub>-rprojk
*                 rec_bukrs = <fs_sub>-recv_bukrs.
*      IF sy-subrc = 0.
*        <fs_sub>-recv_posid = gs_wbs_map-rec_posid.
*      ENDIF.
*    ENDIF.
*
*    " Profit center mapping
*    IF <fs_sub>-rprctr IS NOT INITIAL.
*      READ TABLE gt_prctr_map INTO gs_prctr_map
*        WITH KEY op_bukrs  = <fs_sub>-rbukrs
*                 op_prctr  = <fs_sub>-rprctr
*                 rec_bukrs = <fs_sub>-recv_bukrs.
*      IF sy-subrc = 0.
*        <fs_sub>-recv_prctr = gs_prctr_map-rec_prctr.
*      ENDIF.
*    ENDIF.
*
*    " Currencies (currently hardcoded USD - swap in JV_AND_FI_CURRENCIES later)
*    IF <fs_sub>-rbukrs IS NOT INITIAL.
*      <fs_sub>-send_curr = 'USD'.
*    ENDIF.
*    " FIX #9: was checking rbukrs - should test the receiver's company code
*    IF <fs_sub>-recv_bukrs IS NOT INITIAL.
*      <fs_sub>-recv_curr = 'USD'.
*    ENDIF.
*
*    " Posting date = last day of the BUDAT month
*    CHECK <fs_sub>-budat IS NOT INITIAL.
*
*    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
*      EXPORTING
*        day_in            = <fs_sub>-budat
*      IMPORTING
*        last_day_of_month = lv_last_day
*      EXCEPTIONS
*        day_in_no_date    = 1
*        OTHERS            = 2.
*
*    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
*                                 THEN lv_last_day
*                                 ELSE <fs_sub>-budat ).
*
*  ENDLOOP.
*----------------------------------------------------------------------*
* FORM: APPLY_MAPPINGS
*----------------------------------------------------------------------*
*FORM apply_mappings.
  DATA: lv_last_day  TYPE d,
        lv_key_kostl TYPE char12.
  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.

  LOOP AT gt_subtotal ASSIGNING <fs_sub>.

    " JV / Recovery Indicator -> Receiving Co.Code
    READ TABLE gt_jv_map INTO gs_jv_map
      WITH KEY op_bukrs = <fs_sub>-rbukrs
               op_vname = <fs_sub>-rjvnam
               op_recid = <fs_sub>-rrecin.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    <fs_sub>-recv_bukrs = gs_jv_map-rec_bukrs.

    " GL mapping
*    READ TABLE gt_gl_map INTO gs_gl_map
*      WITH KEY op_bukrs  = <fs_sub>-rbukrs
*               op_saknr  = <fs_sub>-racct
*               rec_bukrs = <fs_sub>-recv_bukrs.
*    IF sy-subrc = 0.
*      <fs_sub>-recv_saknr = gs_gl_map-rec_saknr.
*    ENDIF.
" GL mapping
READ TABLE gt_gl_map INTO gs_gl_map
  WITH KEY op_bukrs  = <fs_sub>-rbukrs
           op_saknr  = <fs_sub>-racct
           rec_bukrs = <fs_sub>-recv_bukrs.
IF sy-subrc = 0.
  <fs_sub>-recv_saknr    = gs_gl_map-rec_saknr.
  <fs_sub>-default_kostl = gs_gl_map-default_kostl.   " NEW
  <fs_sub>-default_prctr = gs_gl_map-default_prctr.   " NEW
ENDIF.

    " ---------------------------------------------------------------------
    " Cost center mapping - ZJV_MAP_RCNTR-OP_KOSTL is CHAR12 and can hold
    " EITHER an ALPHA-converted cost center OR an ALPHA-converted order
    " number. Order-based lookup (via RORDNR) takes precedence; if it
    " doesn't resolve, fall back to the direct cost center (RCNTR) lookup.
    " ---------------------------------------------------------------------
    CLEAR <fs_sub>-recv_kostl.

    " 1) Try ORDER-based lookup first
    IF <fs_sub>-rordnr IS NOT INITIAL.
      CLEAR lv_key_kostl.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_sub>-rordnr
        IMPORTING
          output = lv_key_kostl.

      READ TABLE gt_rcntr_map INTO gs_rcntr_map
        WITH KEY op_bukrs  = <fs_sub>-rbukrs
                 op_kostl  = lv_key_kostl
                 rec_bukrs = <fs_sub>-recv_bukrs.
      IF sy-subrc = 0.
        <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
      ENDIF.
    ENDIF.

    " 2) Fall back to direct cost center (RCNTR) lookup if order lookup
    "    didn't resolve one, or there was no order on the line at all.
    IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-rcntr IS NOT INITIAL.
      CLEAR lv_key_kostl.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_sub>-rcntr
        IMPORTING
          output = lv_key_kostl.

      READ TABLE gt_rcntr_map INTO gs_rcntr_map
        WITH KEY op_bukrs  = <fs_sub>-rbukrs
                 op_kostl  = lv_key_kostl
                 rec_bukrs = <fs_sub>-recv_bukrs.
      IF sy-subrc = 0.
        <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
      ENDIF.
    ENDIF.

    " 3) Flag if neither lookup produced a cost center but the line had
    "    an order and/or a cost center to begin with.
    IF <fs_sub>-recv_kostl IS INITIAL
       AND ( <fs_sub>-rordnr IS NOT INITIAL OR <fs_sub>-rcntr IS NOT INITIAL ).
      APPEND VALUE #(
        msgty   = 'W'
        message = |No cost center map found in ZJV_MAP_RCNTR for CoCd |
               && |{ <fs_sub>-rbukrs } (Order { <fs_sub>-rordnr }, |
               && |CC { <fs_sub>-rcntr })|
      ) TO gt_alv_result.
    ENDIF.
    " ---------------------------------------------------------------------

    " WBS mapping
    IF <fs_sub>-rprojk IS NOT INITIAL.
      READ TABLE gt_wbs_map INTO gs_wbs_map
        WITH KEY op_bukrs  = <fs_sub>-rbukrs
                 op_posid  = <fs_sub>-rprojk
                 rec_bukrs = <fs_sub>-recv_bukrs.
      IF sy-subrc = 0.
        <fs_sub>-recv_posid = gs_wbs_map-rec_posid.
      ENDIF.
    ENDIF.

    " Profit center mapping
    IF <fs_sub>-rprctr IS NOT INITIAL.
      READ TABLE gt_prctr_map INTO gs_prctr_map
        WITH KEY op_bukrs  = <fs_sub>-rbukrs
                 op_prctr  = <fs_sub>-rprctr
                 rec_bukrs = <fs_sub>-recv_bukrs.
      IF sy-subrc = 0.
        <fs_sub>-recv_prctr = gs_prctr_map-rec_prctr.
      ENDIF.
    ENDIF.

    " Currencies (currently hardcoded USD - swap in JV_AND_FI_CURRENCIES later)
    IF <fs_sub>-rbukrs IS NOT INITIAL.
      <fs_sub>-send_curr = 'USD'.
    ENDIF.
    " FIX #9: was checking rbukrs - should test the receiver's company code
    IF <fs_sub>-recv_bukrs IS NOT INITIAL.
      <fs_sub>-recv_curr = 'USD'.
    ENDIF.

    " Posting date = last day of the BUDAT month
    CHECK <fs_sub>-budat IS NOT INITIAL.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = <fs_sub>-budat
      IMPORTING
        last_day_of_month = lv_last_day
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.

    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
                                 THEN lv_last_day
                                 ELSE <fs_sub>-budat ).

  ENDLOOP.
ENDFORM.



*----------------------------------------------------------------------*
* FORM: POST_DOCUMENTS
*----------------------------------------------------------------------*
FORM post_documents.
  DATA: lv_curr_recv TYPE bukrs,
        lv_linenum   TYPE i,
        lv_amount    TYPE vgcur9,
        lv_sum       TYPE vgcur9.
  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.

*  SORT gt_subtotal BY recv_bukrs rjvnam rrecin racct.
*
*  CLEAR: lv_curr_recv, lv_linenum, gv_post_date.
*  REFRESH: gt_accountgl, gt_currencyamount.
*
**CALL FUNCTION 'FI_PERIOD_DETERMINE'
**
**  EXPORTING
**   i_budat              = gv_post_date
**   I_BUKRS              = ' '
**   I_RLDNR              = ' '
**   I_PERIV              = ' '
**   I_GJAHR              = 0000
**   I_MONAT              = 00
**   X_XMO16              = ' '
** IMPORTING
**   E_GJAHR              = p_gjahr
**   E_MONAT              = p_poper
**   E_POPER              = p_poper
** EXCEPTIONS
**   FISCAL_YEAR          = 1
**   PERIOD               = 2
**   PERIOD_VERSION       = 3
**   POSTING_PERIOD       = 4
**   SPECIAL_PERIOD       = 5
**   VERSION              = 6
**   POSTING_DATE         = 7
**   OTHERS               = 8.
*
**DATA gv_bukrs TYPE t001-bukrs.
*          .
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*IF P_POPER < 3.
*  P_POPER = P_POPER + 9.
*ELSE.
*  P_POPER = P_POPER - 3.
*ENDIF.
*
*
*
*  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
*    CHECK <fs_sub>-recv_bukrs IS NOT INITIAL.
*
*    " Co.Code break -> post the previous batch
**    IF lv_curr_recv <> <fs_sub>-recv_bukrs
**   AND lv_curr_recv IS NOT INITIAL.
**      PERFORM post_bapi_document USING lv_curr_recv.
**      REFRESH: gt_accountgl, gt_currencyamount.
**      lv_linenum   = 0.
**      CLEAR gv_post_date.
**    ENDIF.
**
**   CLEAR: lv_linenum.
**    DO 2 TIMES.
*
*
*
*
*    lv_curr_recv = <fs_sub>-recv_bukrs.
*    " FIX #13: capture posting date when we build the batch instead of
*    " re-reading inside POST_BAPI_DOCUMENT.
*    IF gv_post_date IS INITIAL.
*      gv_post_date = <fs_sub>-post_date.
*    ENDIF.
*
**    CALL FUNCTION 'FI_PERIOD_DETERMINE'
**  EXPORTING
**    i_budat = gv_post_date
**    i_bukrs = p_bukrs
**  IMPORTING
***    e_gjahr = p_gjahr
**    e_poper = p_poper
**  EXCEPTIONS
**    OTHERS  = 1.
*
*    ADD 1 TO lv_linenum.
*
*    CLEAR gs_accountgl.
*    gs_accountgl-itemno_acc  = lv_linenum.
*    gs_accountgl-gl_account  = <fs_sub>-recv_saknr.
*    gs_accountgl-comp_code   = <fs_sub>-recv_bukrs.
*    gs_accountgl-costcenter  = <fs_sub>-recv_kostl.
*    gs_accountgl-orderid     = <fs_sub>-rordnr.
*    gs_accountgl-wbs_element = <fs_sub>-recv_posid.
*    gs_accountgl-profit_ctr  = <fs_sub>-recv_prctr.
**    gs_accountgl-func_area = 'PT01'.
*    gs_accountgl-FUNC_AREA_LONG = 'OPG000'.
*
*    " FIX #1: was '16' (year-end special period) - use the period parameter
*    gs_accountgl-fis_period  = p_poper.
*    " FIX #7: duplicate fisc_year assignment removed
*    gs_accountgl-fisc_year   = p_gjahr.
*
*    " FIX #2 + #3: Derive Debit/Credit from sign of KSL and feed an
*    " absolute amount to the BAPI. Hardcoding 'H' would leave the
*    " document unbalanced and BAPI returns "Balance in trans.curr. <> 0".
**    READ TABLE gt_accountgl into data(ls_accountgl) with key comp_code = gs_accountgl-comp_code costcenter = gs_accountgl-costcenter gl_account = gs_accountgl-gl_account.
**    IF sy-subrc is INITIAL.
**      gs_accountgl-de_cre_ind = 'S'.   " Credit
**      lv_amount               = lv_sum * -1.
**    else.
*    gs_accountgl-de_cre_ind = 'S'.   " Debit
*    lv_amount               = <fs_sub>-ksl.
*    lv_sum = lv_sum + lv_amount.
**    ENDIF.
*
*
*    " FIX #8: doc_type belongs on the header, not on each line - removed
*    " FIX #4: func_area '0001' is rarely a real value - leave blank or
*    " derive from cost object via substitution. Uncomment & map if needed.
*    " gs_accountgl-func_area = '0001'.
*
*    APPEND gs_accountgl TO gt_accountgl.
*
*    CLEAR gs_currencyamount.
*    gs_currencyamount-itemno_acc = lv_linenum.
*    gs_currencyamount-currency   = <fs_sub>-recv_curr.
*    gs_currencyamount-amt_doccur = lv_amount.
*    APPEND gs_currencyamount TO gt_currencyamount.
**    ENDDO.
*
*  ENDLOOP.
**  READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
**  IF sy-subrc IS INITIAL.
**    ADD 1 TO lv_linenum.
**    gs_accountgl-itemno_acc  = lv_linenum.
**    gs_accountgl-de_cre_ind = 'H'.
**    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.
**    gs_accountgl-gl_account = ls_jv_map-offset_gl.
**    APPEND gs_accountgl TO gt_accountgl.
**
**    READ TABLE gt_currencyamount INTO gs_currencyamount INDEX 1.
**    gs_currencyamount-itemno_acc = lv_linenum.
**    gs_currencyamount-currency   = <fs_sub>-recv_curr.
**    gs_currencyamount-amt_doccur = lv_sum * -1.
**    APPEND gs_currencyamount TO gt_currencyamount.
**
**  ENDIF.
**  PERFORM post_bapi_document USING lv_curr_recv.
**  CLEAR: gt_currencyamount, gs_doc_header, gt_return, gt_accountgl.
*
**  READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
**  IF sy-subrc IS INITIAL.
**    ADD 1 TO lv_linenum.
**
**    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.
**
**    " FIX: offsetting line now posts as a VENDOR line (account type K,
**    " de_cre_ind 'H') so it resolves to posting key 31 (Invoice/Credit
**    " vendor) instead of GL posting key 50. Per-subtotal lines above
**    " are unchanged and still post as GL (PK 40).
**    CLEAR gs_accountpayable.
**    gs_accountpayable-itemno_acc = lv_linenum.
**    gs_accountpayable-vendor_no  = ls_jv_map-offset_gl. " rename if field differs
**    gs_accountpayable-comp_code  = lv_curr_recv.
***    gs_accountpayable-de_cre_ind = 'H'.
**    APPEND gs_accountpayable TO gt_accountpayable.
**
**    CLEAR gs_currencyamount.
**    gs_currencyamount-itemno_acc = lv_linenum.
**    gs_currencyamount-currency   = <fs_sub>-recv_curr.
**    gs_currencyamount-amt_doccur = lv_sum * -1.
**    APPEND gs_currencyamount TO gt_currencyamount.
**
**  ENDIF.
*
*READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
*  IF sy-subrc IS INITIAL.
*    ADD 1 TO lv_linenum.
*    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.
*
*    IF ls_jv_map-type = 'V'.   " <-- confirm actual domain value for "Vendor"
*      " Offset account is a VENDOR -> post via BAPIACAP09 (PK 31/21)
*      CLEAR gs_accountpayable.
*      gs_accountpayable-itemno_acc = lv_linenum.
*      gs_accountpayable-vendor_no  = ls_jv_map-offset_gl.
*      gs_accountpayable-comp_code  = lv_curr_recv.
**      gs_accountpayable-de_cre_ind = 'H'.
*      APPEND gs_accountpayable TO gt_accountpayable.
*    ELSE.
*      " Offset account is a GL account -> post via BAPIACGL09 (PK 40/50)
*      CLEAR gs_accountgl.
*      gs_accountgl-itemno_acc = lv_linenum.
*      gs_accountgl-gl_account = ls_jv_map-offset_gl.
*      gs_accountgl-comp_code  = lv_curr_recv.
*      gs_accountgl-de_cre_ind = 'H'.
*      gs_accountgl-fis_period = p_poper.
*      gs_accountgl-fisc_year  = p_gjahr.
*      APPEND gs_accountgl TO gt_accountgl.
*    ENDIF.
*
*    CLEAR gs_currencyamount.
*    gs_currencyamount-itemno_acc = lv_linenum.
*    gs_currencyamount-currency   = <fs_sub>-recv_curr.
*    gs_currencyamount-amt_doccur = lv_sum * -1.
*    APPEND gs_currencyamount TO gt_currencyamount.
*  ENDIF.

SORT gt_subtotal BY recv_bukrs rjvnam rrecin racct.

  CLEAR: lv_curr_recv, lv_linenum, gv_post_date, lv_sum.
  REFRESH: gt_accountgl, gt_currencyamount, gt_accountpayable.

  IF p_poper < 3.
    p_poper = p_poper + 9.
  ELSE.
    p_poper = p_poper - 3.
  ENDIF.

  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
    CHECK <fs_sub>-recv_bukrs IS NOT INITIAL.

    lv_curr_recv = <fs_sub>-recv_bukrs.

    " FIX #13: capture posting date when we build the batch instead of
    " re-reading inside POST_BAPI_DOCUMENT.
    IF gv_post_date IS INITIAL.
      gv_post_date = <fs_sub>-post_date.
    ENDIF.

    ADD 1 TO lv_linenum.

    CLEAR gs_accountgl.
    gs_accountgl-itemno_acc  = lv_linenum.
    gs_accountgl-gl_account  = <fs_sub>-recv_saknr.
    gs_accountgl-comp_code   = <fs_sub>-recv_bukrs.
    gs_accountgl-costcenter  = <fs_sub>-recv_kostl.
*    gs_accountgl-orderid     = <fs_sub>-rordnr.
    gs_accountgl-wbs_element = <fs_sub>-recv_posid.
    gs_accountgl-profit_ctr  = <fs_sub>-recv_prctr.
    gs_accountgl-func_area_long = 'OPG000'.

    " FIX #1: was '16' (year-end special period) - use the period parameter
    gs_accountgl-fis_period  = p_poper.
    " FIX #7: duplicate fisc_year assignment removed
    gs_accountgl-fisc_year   = p_gjahr.

    " FIX #2 + #3 + NEW: Derive Debit/Credit from the sign of KSL and feed
    " an ABSOLUTE amount to the BAPI. Hardcoding 'S' or 'H' would leave the
    " document unbalanced whenever a line's natural sign flips, and now
    " that we can have GL (40/50) OR Vendor (21/31) offsets, the indicator
    " must be derived, not hardcoded, on both the detail lines and the
    " offset line.
    IF <fs_sub>-ksl >= 0.
      gs_accountgl-de_cre_ind = 'S'.   " Debit
    ELSE.
      gs_accountgl-de_cre_ind = 'H'.   " Credit
    ENDIF.

    " Keep a SIGNED running total - this is what the offset line balances
    " against. Do NOT take abs() here, only when writing amt_doccur.
    lv_sum = lv_sum + <fs_sub>-ksl.

    APPEND gs_accountgl TO gt_accountgl.

    CLEAR gs_currencyamount.
    gs_currencyamount-itemno_acc = lv_linenum.
    gs_currencyamount-currency   = <fs_sub>-recv_curr.
    gs_currencyamount-amt_doccur = <fs_sub>-ksl.   " BAPI requires unsigned amount
    APPEND gs_currencyamount TO gt_currencyamount.

  ENDLOOP.

  " ---- Offset line: balances the whole batch, can be GL or Vendor ----
" ---- Offset line: balances the whole batch, can be GL or Vendor ----
  READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
  IF sy-subrc IS INITIAL.
    ADD 1 TO lv_linenum.
    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.  "#EC CI_NOORDER

    DATA: lv_offset_amt TYPE vgcur9,
          lv_offset_ind TYPE bapiacgl09-de_cre_ind.

    lv_offset_amt = lv_sum * -1.        " signed balancing amount

    IF ls_jv_map-type = 'V'.            " <-- confirm actual domain value for "Vendor"
      " Offset account is a VENDOR -> post via BAPIACAP09.
      " No DE_CRE_IND field here - sign lives in amt_doccur itself:
      " negative = credit/invoice (PK31), positive = debit (PK21).
      CLEAR gs_accountpayable.
      gs_accountpayable-itemno_acc = lv_linenum.
      gs_accountpayable-vendor_no  = ls_jv_map-offset_gl.
      gs_accountpayable-comp_code  = lv_curr_recv.
      gs_accountpayable-profit_ctr  = 'CLCP5NB02P'.
      APPEND gs_accountpayable TO gt_accountpayable.

      CLEAR gs_currencyamount.
      gs_currencyamount-itemno_acc = lv_linenum.
      gs_currencyamount-currency   = <fs_sub>-recv_curr.
      gs_currencyamount-amt_doccur = lv_offset_amt.   " SIGNED - do not take abs() for vendor lines
      APPEND gs_currencyamount TO gt_currencyamount.

    ELSE.
      " Offset account is a GL account -> post via BAPIACGL09.
      " GL lines DO need DE_CRE_IND, and amt_doccur must be unsigned.
      IF lv_offset_amt >= 0.
        lv_offset_ind = 'S'.
      ELSE.
        lv_offset_ind = 'H'.
      ENDIF.

      CLEAR gs_accountgl.
      gs_accountgl-itemno_acc = lv_linenum.
      gs_accountgl-gl_account = ls_jv_map-offset_gl.
      gs_accountgl-comp_code  = lv_curr_recv.
      gs_accountgl-fis_period = p_poper.
      gs_accountgl-fisc_year  = p_gjahr.
      gs_accountgl-de_cre_ind = lv_offset_ind.
      APPEND gs_accountgl TO gt_accountgl.

      CLEAR gs_currencyamount.
      gs_currencyamount-itemno_acc = lv_linenum.
      gs_currencyamount-currency   = <fs_sub>-recv_curr.
      gs_currencyamount-amt_doccur = conv #( lv_offset_amt ).   " unsigned, sign lives in de_cre_ind
      APPEND gs_currencyamount TO gt_currencyamount.
    ENDIF.
  ENDIF.






  PERFORM post_bapi_document USING lv_curr_recv.
  CLEAR: gt_currencyamount, gs_doc_header, gt_return, gt_accountgl, gt_accountpayable.

  IF lv_curr_recv IS NOT INITIAL AND gt_accountgl IS NOT INITIAL.

  ENDIF.
ENDFORM.




*----------------------------------------------------------------------*
* FORM: POST_BAPI_DOCUMENT
*----------------------------------------------------------------------*
FORM post_bapi_document USING lv_recv_bukrs TYPE bukrs.
  DATA: lv_has_error TYPE abap_bool.

  CLEAR gs_doc_header.
  gs_doc_header-bus_act    = 'RFBU'.
  gs_doc_header-username   = sy-uname.
  gs_doc_header-comp_code  = lv_recv_bukrs.
  gs_doc_header-doc_date   = gv_post_date.
  gs_doc_header-pstng_date = gv_post_date.
  gs_doc_header-trans_date = gv_post_date.
  gs_doc_header-doc_type   = 'CL'.
  gs_doc_header-ref_doc_no = 'ZR_JV_POST'.
  gs_doc_header-header_txt = 'JV Transfer Auto Post'.
  gs_doc_header-fis_period = p_poper.
  gs_doc_header-fisc_year  = p_gjahr.

  REFRESH gt_return.

*  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
*    EXPORTING
*      documentheader = gs_doc_header
*    TABLES
*      accountgl      = gt_accountgl
*      currencyamount = gt_currencyamount
*      return         = gt_return.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_USAGE_OK[2628704]
"#EC CI_USAGE_OK[2438131]
    EXPORTING
      documentheader = gs_doc_header
    TABLES
      accountgl      = gt_accountgl
      accountpayable = gt_accountpayable
      currencyamount = gt_currencyamount
      return         = gt_return.




  " If CHECK already returned errors, do not call POST
  lv_has_error = abap_false.
  LOOP AT gt_return INTO gs_return
       WHERE type = 'E' OR type = 'A'.
    lv_has_error = abap_true.
    EXIT.
  ENDLOOP.

  IF lv_has_error = abap_false.
    CLEAR: gv_obj_type, gv_obj_key, gv_obj_sys.
*    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*      EXPORTING
*        documentheader = gs_doc_header
*      IMPORTING
*        obj_type       = gv_obj_type
*        obj_key        = gv_obj_key
*        obj_sys        = gv_obj_sys
*      TABLES
*        accountgl      = gt_accountgl
*        currencyamount = gt_currencyamount
*        return         = gt_return.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2628704]
"#EC CI_USAGE_OK[2438131]
      EXPORTING
        documentheader = gs_doc_header
      IMPORTING
        obj_type       = gv_obj_type
        obj_key        = gv_obj_key
        obj_sys        = gv_obj_sys
      TABLES
        accountgl      = gt_accountgl
        accountpayable = gt_accountpayable
        currencyamount = gt_currencyamount
        return         = gt_return.

    LOOP AT gt_return INTO gs_return
         WHERE type = 'E' OR type = 'A'.
      lv_has_error = abap_true.
      EXIT.
    ENDLOOP.
  ENDIF.

  " Commit / Rollback based on final error state
  IF lv_has_error = abap_false AND gv_test_run = abap_false.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    gs_jv_map_trf-test_run = 'X'.
    INSERT ZJV_MAP_TRF FROM gs_jv_map_trf.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

  " FIX #10: write the ALV log AFTER the final error state is known so
  " every row of a successful posting shows the correct doc number, and
  " no row of a failed posting shows a doc number.
  LOOP AT gt_return INTO gs_return.
    CHECK gs_return-type = 'E'.
    CLEAR gs_alv_result.
    gs_alv_result-msgty     = gs_return-type.
    gs_alv_result-comp_code = lv_recv_bukrs.
    gs_alv_result-doc_number = COND #(
        WHEN lv_has_error = abap_false AND gv_test_run = abap_false
        THEN gv_obj_key
        ELSE space ).
    gs_alv_result-message   = gs_return-message.
    APPEND gs_alv_result TO gt_alv_result.
  ENDLOOP.

  IF gv_test_run = abap_true.
    CLEAR gs_alv_result.
    gs_alv_result-msgty     = 'I'.
    gs_alv_result-comp_code = lv_recv_bukrs.
    gs_alv_result-message   = |Test Run - No FI document created for company code { lv_recv_bukrs }|.
    APPEND gs_alv_result TO gt_alv_result.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: DISPLAY_SUMMARY
*----------------------------------------------------------------------*
FORM display_summary.

  DATA: lo_alv     TYPE REF TO cl_salv_table,
        lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column_table,
        lo_display TYPE REF TO cl_salv_display_settings,
        lo_funcs   TYPE REF TO cl_salv_functions_list.

  IF gt_alv_result IS INITIAL.
    APPEND VALUE #( msgty   = 'I'
                    message = 'Run completed - no result rows generated'
                  ) TO gt_alv_result.
  ENDIF.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_alv_result ).
    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE |ALV Error: { lx_msg->get_text( ) }| TYPE 'E'.
      RETURN.
  ENDTRY.

  lo_funcs = lo_alv->get_functions( ).
  lo_funcs->set_all( abap_true ).

  lo_display = lo_alv->get_display_settings( ).
  lo_display->set_list_header( 'JV Transfer Posting Results' ).
  lo_display->set_striped_pattern( abap_true ).

  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).

  TRY.
      lo_column ?= lo_columns->get_column( 'MSGTY' ).
      lo_column->set_long_text( 'Type' ).
      lo_column->set_medium_text( 'Type' ).
      lo_column->set_short_text( 'Type' ).
      lo_column->set_output_length( 5 ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column ?= lo_columns->get_column( 'COMP_CODE' ).
      lo_column->set_long_text( 'Company Code' ).
      lo_column->set_medium_text( 'Comp.Code' ).
      lo_column->set_short_text( 'CoCd' ).
      lo_column->set_output_length( 10 ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column ?= lo_columns->get_column( 'DOC_NUMBER' ).
      lo_column->set_long_text( 'Document Number' ).
      lo_column->set_medium_text( 'Doc. Number' ).
      lo_column->set_short_text( 'Doc.No.' ).
      lo_column->set_output_length( 15 ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column ?= lo_columns->get_column( 'MESSAGE' ).
      lo_column->set_long_text( 'Message' ).
      lo_column->set_medium_text( 'Message' ).
      lo_column->set_short_text( 'Message' ).
      lo_column->set_output_length( 120 ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  lo_alv->display( ).
ENDFORM.








**&---------------------------------------------------------------------*
**& Report  ZR_JV_POST
**& JV Transfer: Colombia OCV->OVL | Cutback | NB | Corporate Items
**& Z Tables:
**&   ZJV_MAP_COCODE - JV/Recovery Indicator -> Receiving Co.Code
**&   ZJV_MAP_GL     - GL Account Mapping
**&   ZJV_MAP_RCNTR  - Cost Center Mapping
**&   ZJV_MAP_WBS    - WBS Element Mapping
**&   ZJV_MAP_PRCTR  - Profit Center Mapping
**& Source Table:
**&   JVSO1          - JV Accounting (Ledgers 4A / 4C)
**&---------------------------------------------------------------------*
*REPORT zr_jv_post.
*
**----------------------------------------------------------------------*
** TABLES
**----------------------------------------------------------------------*
*TABLES: jvso1.
*
**----------------------------------------------------------------------*
** TYPES
**----------------------------------------------------------------------*
*" ZJV_MAP_COCODE: OP_BUKRS/OP_VNAME/OP_RECID -> REC_BUKRS/REC_VNAME/REC_RECID
*TYPES: BEGIN OF ty_jv_map,
*         op_bukrs  TYPE bukrs,
*         op_vname  TYPE jv_name,
*         op_recid  TYPE jv_recind,
*         rec_bukrs TYPE bukrs,
*         rec_vname TYPE jv_name,
*         rec_recid TYPE jv_recind,
*       END OF ty_jv_map.
*
*" ZJV_MAP_GL: OP_BUKRS/OP_SAKNR -> REC_BUKRS/REC_SAKNR
*TYPES: BEGIN OF ty_gl_map,
*         op_bukrs  TYPE bukrs,
*         op_saknr  TYPE saknr,
*         rec_bukrs TYPE bukrs,
*         rec_saknr TYPE saknr,
*       END OF ty_gl_map.
*
*" ZJV_MAP_RCNTR: OP_BUKRS/OP_KOSTL -> REC_BUKRS/REC_KOSTL
*TYPES: BEGIN OF ty_rcntr_map,
*         op_bukrs  TYPE bukrs,
*         op_kostl  TYPE kostl,
*         rec_bukrs TYPE bukrs,
*         rec_kostl TYPE kostl,
*       END OF ty_rcntr_map.
*
*" ZJV_MAP_WBS: OP_BUKRS/OP_POSID -> REC_BUKRS/REC_POSID
*TYPES: BEGIN OF ty_wbs_map,
*         op_bukrs  TYPE bukrs,
*         op_posid  TYPE ps_posid,
*         rec_bukrs TYPE bukrs,
*         rec_posid TYPE ps_posid,
*       END OF ty_wbs_map.
*
*" ZJV_MAP_PRCTR: OP_BUKRS/OP_PRCTR -> REC_BUKRS/REC_PRCTR
*TYPES: BEGIN OF ty_prctr_map,
*         op_bukrs  TYPE bukrs,
*         op_prctr  TYPE prctr,
*         rec_bukrs TYPE bukrs,
*         rec_prctr TYPE prctr,
*       END OF ty_prctr_map.
*
*" JVSO1 line items (Company Code = RBUKRS)
*TYPES: BEGIN OF ty_jvso1,
*         rldnr  TYPE rldnr,
*         rbukrs TYPE bukrs,
*         rrcty  TYPE rrcty,
*         rvers  TYPE rvers,
*         ryear  TYPE gjahr,
*         poper  TYPE poper,
*         rjvnam TYPE jv_name,
*         rrecin TYPE jv_recind,
*         racct  TYPE racct,
*         regrou TYPE jv_egroup,
*         rcntr  TYPE kostl,
*         rordnr TYPE aufnr,
*         rprojk TYPE ps_psp_pnr,
*         rprctr TYPE prctr,
*         budat  TYPE budat,
*         tsl    TYPE VTCUR9,
*         hsl    TYPE VLCUR9,
*         ksl    TYPE VGCUR9,
*       END OF ty_jvso1.
*
*" Aggregated Subtotal line
*TYPES: BEGIN OF ty_subtotal,
*         rbukrs      TYPE bukrs,
*         rjvnam      TYPE jv_name,
*         rrecin      TYPE jv_recind,
*         racct       TYPE racct,
*         rcntr       TYPE kostl,
*         rordnr      TYPE aufnr,
*         rprojk      TYPE ps_psp_pnr,
*         rprctr      TYPE prctr,
*         budat       TYPE budat,
*         tsl         TYPE vtcur9,
*         hsl         TYPE vlcur9,
*         ksl         TYPE vgcur9,
*         recv_bukrs  TYPE bukrs,
*         recv_saknr  TYPE saknr,
*         recv_kostl  TYPE kostl,
*         recv_posid  TYPE ps_posid,
*         recv_prctr  TYPE prctr,
*         send_curr   TYPE waers,
*         recv_curr   TYPE waers,
*         post_date   TYPE budat,
*       END OF ty_subtotal.
*
*" ALV Result Table Type
*TYPES: BEGIN OF ty_alv_result,
*         msgty       TYPE bapi_mtype,       " S / E / W / I
*         comp_code   TYPE bukrs,            " Receiving Company Code
*         doc_number  TYPE belnr_d,          " Posted Document Number
*         message     TYPE string,           " Message Text
*       END OF ty_alv_result.
*
**----------------------------------------------------------------------*
** INTERNAL TABLES
**----------------------------------------------------------------------*
*DATA: gt_jv_map    TYPE TABLE OF ty_jv_map,
*      gt_gl_map    TYPE TABLE OF ty_gl_map,
*      gt_rcntr_map TYPE TABLE OF ty_rcntr_map,
*      gt_wbs_map   TYPE TABLE OF ty_wbs_map,
*      gt_prctr_map TYPE TABLE OF ty_prctr_map,
*      gt_jvso1     TYPE TABLE OF ty_jvso1,
*      gt_subtotal  TYPE TABLE OF ty_subtotal,
*      gt_alv_result TYPE TABLE OF ty_alv_result.   " ALV Results.
*
**----------------------------------------------------------------------*
** WORK AREAS
**----------------------------------------------------------------------*
*DATA: gs_jvso1      TYPE ty_jvso1,
*      gs_jv_map     TYPE ty_jv_map,
*      gs_gl_map     TYPE ty_gl_map,
*      gs_rcntr_map  TYPE ty_rcntr_map,
*      gs_wbs_map    TYPE ty_wbs_map,
*      gs_prctr_map  TYPE ty_prctr_map,
*      gs_alv_result TYPE ty_alv_result.
*
**----------------------------------------------------------------------*
** BAPI Structures
**----------------------------------------------------------------------*
*DATA: gs_doc_header     TYPE bapiache09,
*      gt_accountgl      TYPE TABLE OF bapiacgl09,
*      gt_currencyamount TYPE TABLE OF bapiaccr09,
*      gt_return         TYPE TABLE OF bapiret2,
*      gs_accountgl      TYPE bapiacgl09,
*      gs_currencyamount TYPE bapiaccr09,
*      gs_return         TYPE bapiret2,
*      gv_obj_type       TYPE bapiache09-obj_type,
*      gv_obj_key        TYPE bapiache09-obj_key,
*      gv_obj_sys        TYPE bapiache09-obj_sys.
*
**----------------------------------------------------------------------*
** VARIABLES
**----------------------------------------------------------------------*
*DATA: gv_test_run  TYPE abap_bool,
*      gv_lines_ok  TYPE i,
*      gv_lines_err TYPE i,
*      lt_racct TYPE RANGE OF saknr,
*      ls_racct LIKE LINE OF lt_racct.
*
**----------------------------------------------------------------------*
** SELECTION SCREEN
**----------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE sel_par.
*  PARAMETERS:
*    p_bukrs TYPE bukrs OBLIGATORY,
*    p_gjahr TYPE gjahr OBLIGATORY,
*    p_poper TYPE poper OBLIGATORY.
*SELECTION-SCREEN END OF BLOCK b1.
*
*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE proc_op.
*  PARAMETERS:
*    p_test TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
*SELECTION-SCREEN END OF BLOCK b2.
*
**----------------------------------------------------------------------*
** INITIALIZATION
**----------------------------------------------------------------------*
*INITIALIZATION.
*  sel_par = 'Selection Parameters'.
*  proc_op = 'Processing Options'.
*
**----------------------------------------------------------------------*
** START-OF-SELECTION
**----------------------------------------------------------------------*
*START-OF-SELECTION.
*
*  gv_test_run = p_test.
*
*  PERFORM load_mapping_tables.
*  PERFORM read_jvso1.
*  PERFORM aggregate_subtotals.
*  PERFORM apply_mappings.
**  PERFORM set_posting_dates.
*  PERFORM post_documents.
*  PERFORM display_summary.
*
**----------------------------------------------------------------------*
** FORM: LOAD_MAPPING_TABLES
**----------------------------------------------------------------------*
*FORM load_mapping_tables.
*
*  SELECT op_bukrs op_vname op_recid rec_bukrs rec_vname rec_recid
*    FROM zjv_map_cocode
*    INTO TABLE gt_jv_map
*    WHERE op_bukrs = p_bukrs.
*    IF sy-subrc = 0.
*    ENDIF.
*
*  SELECT op_bukrs op_saknr rec_bukrs rec_saknr
*    FROM zjv_map_gl
*    INTO TABLE gt_gl_map
*    WHERE op_bukrs = p_bukrs.
*    IF sy-subrc = 0.
*CLEAR lt_racct.
*LOOP AT gt_gl_map INTO DATA(ls_gl).
*  CLEAR ls_racct.
*  ls_racct-sign   = 'I'.
*  ls_racct-option = 'EQ'.
*  ls_racct-low    = ls_gl-op_saknr.
*  APPEND ls_racct TO lt_racct.
*ENDLOOP.
*    ENDIF.
*
*  SELECT op_bukrs op_kostl rec_bukrs rec_kostl
*    FROM zjv_map_rcntr
*    INTO TABLE gt_rcntr_map
*    WHERE op_bukrs = p_bukrs.
*    IF sy-subrc = 0.
*    ENDIF.
*
*  SELECT op_bukrs op_posid rec_bukrs rec_posid
*    FROM zjv_map_wbs
*    INTO TABLE gt_wbs_map
*    WHERE op_bukrs = p_bukrs.
*    IF sy-subrc = 0.
*    ENDIF.
*
*  SELECT op_bukrs op_prctr rec_bukrs rec_prctr
*    FROM zjv_map_prctr
*    INTO TABLE gt_prctr_map
*    WHERE op_bukrs = p_bukrs.
*    IF sy-subrc = 0.
*    ENDIF.
*ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: READ_JVSO1
**----------------------------------------------------------------------*
*FORM read_jvso1.
*
*IF gt_jv_map IS NOT INITIAL.
*  SELECT rldnr, rbukrs, rrcty, rvers, ryear, poper, rjvnam, rrecin, racct,
*         regrou, rcntr, rordnr, rprojk, rprctr, budat, tsl, hsl, ksl
*    FROM jvso1
*    INTO TABLE @gt_jvso1
*    FOR ALL ENTRIES IN @gt_jv_map
*    WHERE rldnr  IN ('4A', '4C')
*      AND rrcty  =  '0'
*      AND rvers  =  '001'
*      AND ryear  =  @p_gjahr
*      AND poper  =  @p_poper AND rjvnam = @gt_jv_map-op_vname AND rrecin = @gt_jv_map-op_recid
*    AND racct IN @lt_racct.
*  IF gt_jvso1 IS INITIAL.
*    MESSAGE 'No JVSO1 records found' TYPE 'E'.
*  ENDIF.
*  ENDIF.
*ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: AGGREGATE_SUBTOTALS
**----------------------------------------------------------------------*
*FORM aggregate_subtotals.
*  DATA: ls_sub TYPE ty_subtotal.
*  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
*
*  SORT gt_jvso1 BY rbukrs rjvnam rrecin racct rcntr rordnr rprojk rprctr.
*
*  LOOP AT gt_jvso1 INTO gs_jvso1.
*    READ TABLE gt_subtotal ASSIGNING <fs_sub>
*      WITH KEY rbukrs = gs_jvso1-rbukrs
*               rjvnam = gs_jvso1-rjvnam
*               rrecin = gs_jvso1-rrecin
*               racct  = gs_jvso1-racct
*               rcntr  = gs_jvso1-rcntr
*               rordnr = gs_jvso1-rordnr
*               rprojk = gs_jvso1-rprojk
*               rprctr = gs_jvso1-rprctr.
*    IF sy-subrc = 0.
*      <fs_sub>-tsl = <fs_sub>-tsl + gs_jvso1-tsl.
*      <fs_sub>-hsl = <fs_sub>-hsl + gs_jvso1-hsl.
*      <fs_sub>-ksl = <fs_sub>-ksl + gs_jvso1-ksl.
*    ELSE.
*      CLEAR ls_sub.
*      ls_sub-rbukrs = gs_jvso1-rbukrs.
*      ls_sub-rjvnam = gs_jvso1-rjvnam.
*      ls_sub-rrecin = gs_jvso1-rrecin.
*      ls_sub-racct  = gs_jvso1-racct.
*      ls_sub-rcntr  = gs_jvso1-rcntr.
*      ls_sub-rordnr = gs_jvso1-rordnr.
*      ls_sub-rprojk = gs_jvso1-rprojk.
*      ls_sub-rprctr = gs_jvso1-rprctr.
*      ls_sub-budat  = gs_jvso1-budat.
*      ls_sub-tsl    = gs_jvso1-tsl.
*      ls_sub-hsl    = gs_jvso1-hsl.
*      ls_sub-ksl    = gs_jvso1-ksl.
*      APPEND ls_sub TO gt_subtotal.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: APPLY_MAPPINGS
**----------------------------------------------------------------------*
*FORM apply_mappings.
*  DATA: lv_send_curr TYPE waers,
*        lv_recv_curr TYPE waers,
*        lv_last_day TYPE d.
*  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
*
*  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
*
*    READ TABLE gt_jv_map INTO gs_jv_map
*      WITH KEY op_bukrs = <fs_sub>-rbukrs
*               op_vname = <fs_sub>-rjvnam
*               op_recid = <fs_sub>-rrecin.
*    IF sy-subrc <> 0.
**      MESSAGE 'No JV map found for line' TYPE 'W'.
*      CONTINUE.
*    ENDIF.
*    <fs_sub>-recv_bukrs = gs_jv_map-rec_bukrs.
*
*    READ TABLE gt_gl_map INTO gs_gl_map
*      WITH KEY op_bukrs  = <fs_sub>-rbukrs
*               op_saknr  = <fs_sub>-racct
*               rec_bukrs = <fs_sub>-recv_bukrs.
*    IF sy-subrc = 0.
*      <fs_sub>-recv_saknr = gs_gl_map-rec_saknr.
*    ELSE.
**      MESSAGE 'WARN: No GL map found for line' TYPE 'W'.
*    ENDIF.
*
*    IF <fs_sub>-rcntr IS NOT INITIAL.
*      READ TABLE gt_rcntr_map INTO gs_rcntr_map
*        WITH KEY op_bukrs  = <fs_sub>-rbukrs
*                 op_kostl  = <fs_sub>-rcntr
*                 rec_bukrs = <fs_sub>-recv_bukrs.
*      IF sy-subrc = 0.
*        <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
*      ELSE.
**        MESSAGE 'WARN: No CC map found for line' TYPE 'W'.
*      ENDIF.
*    ENDIF.
*
*    IF <fs_sub>-rprojk IS NOT INITIAL.
*      READ TABLE gt_wbs_map INTO gs_wbs_map
*        WITH KEY op_bukrs  = <fs_sub>-rbukrs
*                 op_posid  = <fs_sub>-rprojk
*                 rec_bukrs = <fs_sub>-recv_bukrs.
*      IF sy-subrc = 0.
*        <fs_sub>-recv_posid = gs_wbs_map-rec_posid.
*      ENDIF.
*    ENDIF.
*
*    IF <fs_sub>-rprctr IS NOT INITIAL.
*      READ TABLE gt_prctr_map INTO gs_prctr_map
*        WITH KEY op_bukrs  = <fs_sub>-rbukrs
*                 op_prctr  = <fs_sub>-rprctr
*                 rec_bukrs = <fs_sub>-recv_bukrs.
*      IF sy-subrc = 0.
*        <fs_sub>-recv_prctr = gs_prctr_map-rec_prctr.
*      ELSE.
**        MESSAGE 'WARN: No PC map found for line' TYPE 'W'.
*      ENDIF.
*    ENDIF.
*
**if <fs_sub>-rbukrs is not initial.
**    CALL FUNCTION 'JV_AND_FI_CURRENCIES'
**      EXPORTING
**        i_bukrs    = <fs_sub>-rbukrs
**      IMPORTING
**        e_currency = lv_send_curr
**      EXCEPTIONS
**        OTHERS     = 1.
**    IF sy-subrc = 0.
**      <fs_sub>-send_curr = lv_send_curr.
**     ENDIF.
**
**endif.
*if <fs_sub>-rbukrs is not initial.
*      <fs_sub>-send_curr = 'USD'.
*endif.
*
*
**if <fs_sub>-recv_bukrs is not initial.
**    CALL FUNCTION 'JV_AND_FI_CURRENCIES'
**      EXPORTING
**        i_bukrs    = <fs_sub>-recv_bukrs
**      IMPORTING
**        e_currency = lv_recv_curr
**      EXCEPTIONS
**        OTHERS     = 1.
**    IF sy-subrc = 0. <fs_sub>-recv_curr = lv_recv_curr. ENDIF.
**
**endif.
*
*if <fs_sub>-rbukrs is not initial.
*      <fs_sub>-recv_curr = 'USD'.
*endif.
*
*CHECK <fs_sub>-budat IS NOT INITIAL.
*
*    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
*      EXPORTING
*        day_in            = <fs_sub>-budat
*      IMPORTING
*        last_day_of_month = lv_last_day
*      EXCEPTIONS
*        day_in_no_date    = 1
*        OTHERS            = 2.
*
*    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
*                                 THEN lv_last_day
*                                 ELSE <fs_sub>-budat ).
*
*  ENDLOOP.
*ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: SET_POSTING_DATES
**----------------------------------------------------------------------*
**FORM set_posting_dates.
**  DATA: lv_last_day TYPE d.
**  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
**
**  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
**    CHECK <fs_sub>-budat IS NOT INITIAL.
**
**    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
**      EXPORTING
**        day_in            = <fs_sub>-budat
**      IMPORTING
**        last_day_of_month = lv_last_day
**      EXCEPTIONS
**        day_in_no_date    = 1
**        OTHERS            = 2.
**
**    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
**                                 THEN lv_last_day
**                                 ELSE <fs_sub>-budat ).
**  ENDLOOP.
**ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: POST_DOCUMENTS
**----------------------------------------------------------------------*
*FORM post_documents.
*  DATA: lv_curr_recv TYPE bukrs,
*        lv_linenum   TYPE i.
*  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
*
*  SORT gt_subtotal BY recv_bukrs rjvnam rrecin racct.
*
*  CLEAR: lv_curr_recv, lv_linenum.
*  REFRESH: gt_accountgl, gt_currencyamount.
*
*  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
*    CHECK <fs_sub>-recv_bukrs IS NOT INITIAL.
*
*    IF lv_curr_recv <> <fs_sub>-recv_bukrs
*    AND lv_curr_recv IS NOT INITIAL.
*      PERFORM post_bapi_document USING lv_curr_recv.
*      REFRESH: gt_accountgl, gt_currencyamount.
*      lv_linenum = 0.
*    ENDIF.
*
*    lv_curr_recv = <fs_sub>-recv_bukrs.
*    ADD 1 TO lv_linenum.
*
*    CLEAR gs_accountgl.
*    gs_accountgl-itemno_acc  = lv_linenum.
*    gs_accountgl-gl_account  = <fs_sub>-recv_saknr.
*    gs_accountgl-comp_code   = <fs_sub>-recv_bukrs.
*    gs_accountgl-costcenter  = <fs_sub>-recv_kostl.
*    gs_accountgl-orderid     = <fs_sub>-rordnr.
*    gs_accountgl-wbs_element = <fs_sub>-recv_posid.
*    gs_accountgl-profit_ctr  = <fs_sub>-recv_prctr.
*
*    Gs_accountgl-fis_period = '16'.
*    Gs_accountgl-fisc_year  = p_gjahr.
*    Gs_accountgl-fisc_year  = p_gjahr.
*    Gs_accountgl-de_cre_ind = 'H'.
*    Gs_accountgl-doc_type = 'SA'.
*    Gs_accountgl-func_area = '0001'.
*
*
*
*
*    APPEND gs_accountgl TO gt_accountgl.
*
*    CLEAR gs_currencyamount.
*    gs_currencyamount-itemno_acc = lv_linenum.
*    gs_currencyamount-currency   = <fs_sub>-recv_curr.
*    gs_currencyamount-amt_doccur = <fs_sub>-ksl.
*    APPEND gs_currencyamount TO gt_currencyamount.
*
*  ENDLOOP.
*
*  IF lv_curr_recv IS NOT INITIAL AND gt_accountgl IS NOT INITIAL.
*    PERFORM post_bapi_document USING lv_curr_recv.
*  ENDIF.
*ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: POST_BAPI_DOCUMENT
**----------------------------------------------------------------------*
*FORM post_bapi_document USING lv_recv_bukrs TYPE bukrs.
*  DATA: lv_post_date TYPE budat,
*        lv_has_error TYPE abap_bool.
*  FIELD-SYMBOLS: <fs_s> TYPE ty_subtotal.
*
*  READ TABLE gt_subtotal ASSIGNING <fs_s>
*    WITH KEY recv_bukrs = lv_recv_bukrs.
*  IF sy-subrc = 0.
*    lv_post_date = <fs_s>-post_date.
*  ENDIF.
*
*  CLEAR gs_doc_header.
*  gs_doc_header-bus_act    = 'RFBU'.
*  gs_doc_header-username   = sy-uname.
*  gs_doc_header-comp_code  = lv_recv_bukrs.
*  gs_doc_header-doc_date   = lv_post_date.
*  gs_doc_header-pstng_date = lv_post_date.
*  GS_DOC_HEADER-trans_date = lv_post_date.
*  gs_doc_header-doc_type   = 'SA'.
*  gs_doc_header-ref_doc_no = 'ZR_JV_POST'.
*  gs_doc_header-header_txt = 'JV Transfer Auto Post'.
*  GS_DOC_HEADER-fis_period = p_poper.
*  GS_DOC_HEADER-fisc_year = p_gjahr.
*
*  REFRESH gt_return.
*
**  CALL FUNCTION 'BAPI_ACCOUNTING_DOCUMENT_POST'
**    EXPORTING
**      documentheader = gs_doc_header
**    IMPORTING
**      obj_type       = gv_obj_type
**      obj_key        = gv_obj_key
**      obj_sys        = gv_obj_sys
**    TABLES
**      accountgl      = gt_accountgl
**      currencyamount = gt_currencyamount
**      return         = gt_return.
*
* CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
*    EXPORTING
*      documentheader = gs_doc_header
*    TABLES
*      accountgl      = gt_accountgl
*      currencyamount = gt_currencyamount
*      return         = gt_return.
*
*  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*    EXPORTING
*      documentheader = gs_doc_header
*    IMPORTING
*      obj_type       = gv_obj_type
*      obj_key        = gv_obj_key
*      obj_sys        = gv_obj_sys
*    TABLES
*      accountgl      = gt_accountgl
*      currencyamount = gt_currencyamount
*      return         = gt_return.
*
*
*
*
*
*  " Collect ALL BAPI return messages into ALV result table
* lv_has_error = abap_false.
*  LOOP AT gt_return INTO gs_return.
*
*    CLEAR gs_alv_result.
*    gs_alv_result-msgty      = gs_return-type.
*    gs_alv_result-comp_code  = lv_recv_bukrs.
*    gs_alv_result-doc_number = COND #( WHEN lv_has_error = abap_false
*                                       THEN gv_obj_key
*                                       ELSE space ).
*    gs_alv_result-message    = gs_return-message.
*    APPEND gs_alv_result TO gt_alv_result.
*
*    IF gs_alv_result-msgty = 'E' OR gs_alv_result-msgty = 'A'.
*      lv_has_error = abap_true.
*    ENDIF.
*
*  ENDLOOP.
*
*  IF lv_has_error = abap_false AND GV_TEST_RUN = abap_false.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING wait = 'X'.
**    ADD 1 TO gv_lines_ok.
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
**    ADD 1 TO gv_lines_err.
*  ENDIF.
*
*  IF GV_TEST_RUN = abap_true.
*    CLEAR gs_alv_result.
*    gs_alv_result-msgty     = 'I'.
*    gs_alv_result-comp_code = lv_recv_bukrs.
*    gs_alv_result-message   = |Test Run - No FI document created for company code { lv_recv_bukrs }|.
*    APPEND gs_alv_result TO gt_alv_result.
*  ENDIF.
*ENDFORM.
*
**----------------------------------------------------------------------*
** FORM: DISPLAY_SUMMARY
**----------------------------------------------------------------------*
*FORM display_summary.
*
*DATA: lo_alv     TYPE REF TO cl_salv_table,
*        lo_columns TYPE REF TO cl_salv_columns_table,
*        lo_column  TYPE REF TO cl_salv_column_table,
*        lo_display TYPE REF TO cl_salv_display_settings,
*        lo_funcs   TYPE REF TO cl_salv_functions_list.
*
**  " Add summary lines at the end of ALV table
**  CLEAR gs_alv_result.
**  gs_alv_result-msgty   = 'I'.
**  gs_alv_result-message = |Total Subtotal Lines : { lines( gt_subtotal ) }|.
**  APPEND gs_alv_result TO gt_alv_result.
**
**  CLEAR gs_alv_result.
**  gs_alv_result-msgty   = 'S'.
**  gs_alv_result-message = |Documents Posted OK  : { gv_lines_ok }|.
**  APPEND gs_alv_result TO gt_alv_result.
**
**  IF gv_lines_err > 0.
**    CLEAR gs_alv_result.
**    gs_alv_result-msgty   = 'E'.
**    gs_alv_result-message = |Documents in ERROR   : { gv_lines_err }|.
**    APPEND gs_alv_result TO gt_alv_result.
**  ENDIF.
**
**  IF gv_test_run = abap_true.
**    CLEAR gs_alv_result.
**    gs_alv_result-msgty   = 'I'.
**    gs_alv_result-message = 'TEST RUN - No FI documents were created'.
**    APPEND gs_alv_result TO gt_alv_result.
**  ENDIF.
*
*  " Create ALV instance
*  TRY.
*      cl_salv_table=>factory(
*        IMPORTING
*          r_salv_table = lo_alv
*        CHANGING
*          t_table      = gt_alv_result ).
*
*    CATCH cx_salv_msg INTO DATA(lx_msg).
*      MESSAGE |ALV Error: { lx_msg->get_text( ) }| TYPE 'E'.
*      RETURN.
*  ENDTRY.
*
*  " Toolbar
*  lo_funcs = lo_alv->get_functions( ).
*  lo_funcs->set_all( abap_true ).
*
*  " Title & striped rows
*  lo_display = lo_alv->get_display_settings( ).
*  lo_display->set_list_header( 'JV Transfer Posting Results' ).
*  lo_display->set_striped_pattern( abap_true ).
*
*  " Optimize all columns
*  lo_columns = lo_alv->get_columns( ).
*  lo_columns->set_optimize( abap_true ).
*
*  " Column: MSGTY
*  TRY.
*      lo_column ?= lo_columns->get_column( 'MSGTY' ).
*      lo_column->set_long_text( 'Type' ).
*      lo_column->set_medium_text( 'Type' ).
*      lo_column->set_short_text( 'Type' ).
*      lo_column->set_output_length( 5 ).
*    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
*  ENDTRY.
*
*  " Column: COMP_CODE
*  TRY.
*      lo_column ?= lo_columns->get_column( 'COMP_CODE' ).
*      lo_column->set_long_text( 'Company Code' ).
*      lo_column->set_medium_text( 'Comp.Code' ).
*      lo_column->set_short_text( 'CoCd' ).
*      lo_column->set_output_length( 10 ).
*    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
*  ENDTRY.
*
*  " Column: DOC_NUMBER
*  TRY.
*      lo_column ?= lo_columns->get_column( 'DOC_NUMBER' ).
*      lo_column->set_long_text( 'Document Number' ).
*      lo_column->set_medium_text( 'Doc. Number' ).
*      lo_column->set_short_text( 'Doc.No.' ).
*      lo_column->set_output_length( 15 ).
*    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
*  ENDTRY.
*
*  " Column: MESSAGE
*  TRY.
*      lo_column ?= lo_columns->get_column( 'MESSAGE' ).
*      lo_column->set_long_text( 'Message' ).
*      lo_column->set_medium_text( 'Message' ).
*      lo_column->set_short_text( 'Message' ).
*      lo_column->set_output_length( 120 ).
*    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
*  ENDTRY.
*
*  lo_alv->display( ).
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_POSTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_posting .
  select single *
  from ZJV_MAP_TRF
  into @data(ls_map)
  where op_bukrs = @p_bukrs
    and op_vname = @p_jv
    and gjahr = @p_gjahr
    and period = @p_poper.
    IF sy-subrc is INITIAL and LS_MAP-test_run = 'X'.
      MESSAGE: 'Document already posted for the given selection' type 'E'.
    ENDIF.

    gs_jv_map_trf-op_bukrs = P_BUKRS.
    gs_jv_map_trf-op_vname = P_JV.
    gs_jv_map_trf-gjahr = p_gjahr.
    gs_jv_map_trf-period = p_poper.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_COST_ELEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM determine_cost_element .
*TYPES: BEGIN OF ty_cskb,
*           kokrs TYPE kokrs,
*           kstar TYPE kstar,
*         END OF ty_cskb.
*
*  DATA: lt_cskb     TYPE HASHED TABLE OF ty_cskb
*                     WITH UNIQUE KEY kokrs kstar,
*        ls_cskb      TYPE ty_cskb,
*        lt_saknr_rng TYPE RANGE OF saknr,
*        ls_saknr_rng LIKE LINE OF lt_saknr_rng.
*
*  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
*
*  CHECK gt_subtotal IS NOT INITIAL.
*
*  " Build a range of distinct receiver GL accounts already mapped
*  LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_saknr IS NOT INITIAL.
*    CLEAR ls_saknr_rng.
*    ls_saknr_rng-sign   = 'I'.
*    ls_saknr_rng-option = 'EQ'.
*    ls_saknr_rng-low    = <fs_sub>-recv_saknr.
*    COLLECT ls_saknr_rng INTO lt_saknr_rng.
*  ENDLOOP.
*
*  CHECK lt_saknr_rng IS NOT INITIAL.
*
*  " Bulk lookup: which of these GL accounts are Cost Elements in CO Area OVL
*  SELECT DISTINCT kokrs kstar
*    FROM cskb
*    INTO TABLE lt_cskb
*   WHERE kokrs = 'OVL'
*     AND kstar IN lt_saknr_rng.
*
*  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
*    CHECK <fs_sub>-recv_saknr IS NOT INITIAL.
*
*    READ TABLE lt_cskb TRANSPORTING NO FIELDS
*      WITH TABLE KEY kokrs = 'OVL'
*                      kstar = <fs_sub>-recv_saknr.
*
*    IF sy-subrc = 0.
*      " Cost Element -> must carry Cost Center or WBS.
*      " (If your mapping can produce BOTH, decide precedence here.
*      "  Currently: Cost Center wins if both are populated.)
*      IF <fs_sub>-recv_kostl IS NOT INITIAL.
*        CLEAR <fs_sub>-recv_posid.
*      ENDIF.
*      " If neither Cost Center nor WBS got mapped for a true cost element,
*      " that's a data/config gap - flag it rather than silently posting
*      " an incomplete CO assignment.
*      IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-recv_posid IS INITIAL.
*        APPEND VALUE #(
*          msgty   = 'E'
*          message = |Cost element { <fs_sub>-recv_saknr } for CoCd |
*                 && |{ <fs_sub>-recv_bukrs } has no mapped Cost Center |
*                 && |or WBS - posting line will be rejected|
*        ) TO gt_alv_result.
*      ENDIF.
*    ELSE.
*      " Not a Cost Element -> CO object not applicable, keep only Profit Center
*      CLEAR: <fs_sub>-recv_kostl, <fs_sub>-recv_posid.
*    ENDIF.
*
*  ENDLOOP.
  TYPES: BEGIN OF ty_cskb,
           kokrs TYPE kokrs,
           kstar TYPE kstar,
           datab TYPE datab,
           datbi TYPE datbi,
         END OF ty_cskb.

  DATA: lt_cskb      TYPE STANDARD TABLE OF ty_cskb,   " CHANGED: no longer hashed/unique-key -
        ls_cskb      TYPE ty_cskb,                      " a KSTAR can have several validity segments
        lt_saknr_rng TYPE RANGE OF saknr,
        ls_saknr_rng LIKE LINE OF lt_saknr_rng,
        lv_check_date TYPE d,
        lv_found      TYPE abap_bool.

  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.

  CHECK gt_subtotal IS NOT INITIAL.

  LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_saknr IS NOT INITIAL.
    CLEAR ls_saknr_rng.
    ls_saknr_rng-sign   = 'I'.
    ls_saknr_rng-option = 'EQ'.
    ls_saknr_rng-low    = <fs_sub>-recv_saknr.
    COLLECT ls_saknr_rng INTO lt_saknr_rng.
  ENDLOOP.

  CHECK lt_saknr_rng IS NOT INITIAL.

  " Primary cost elements only (KATYP = '1'); pull ALL validity segments,
  " date filtering happens per-line below since each line can have a
  " different post_date.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT kokrs kstar datab datbi
    FROM cskb
    INTO TABLE lt_cskb
   WHERE kokrs = 'OVL'
     AND kstar IN lt_saknr_rng
     AND katyp = '01'.  "#EC CI_DB_OPERATION_OK[2389136]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
    CHECK <fs_sub>-recv_saknr IS NOT INITIAL.

    " NEW: date the cost element must be valid on - use the line's own
    " posting date (already resolved in apply_mappings).
    lv_check_date = <fs_sub>-post_date.
    IF lv_check_date IS INITIAL.
      lv_check_date = <fs_sub>-budat.   " fallback, shouldn't normally hit
    ENDIF.

    CLEAR lv_found.
    LOOP AT lt_cskb INTO ls_cskb
         WHERE kokrs = 'OVL'
           AND kstar = <fs_sub>-recv_saknr
           AND datab <= lv_check_date
           AND datbi >= lv_check_date.
      lv_found = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_found = abap_true.
      " Primary cost element, valid on the posting date -> must carry Cost Center or WBS.
      IF <fs_sub>-recv_kostl IS NOT INITIAL.
        CLEAR <fs_sub>-recv_posid.   " Cost Center wins if both are populated
      ENDIF.

      IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-recv_posid IS INITIAL.
        IF <fs_sub>-default_kostl IS NOT INITIAL.
          <fs_sub>-recv_kostl = <fs_sub>-default_kostl.
          CLEAR <fs_sub>-recv_posid.
        ELSEIF <fs_sub>-default_prctr IS NOT INITIAL.
          <fs_sub>-recv_prctr = <fs_sub>-default_prctr.
        ENDIF.
      ENDIF.

      IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-recv_posid IS INITIAL.
        APPEND VALUE #(
          msgty   = 'E'
          message = |Cost element { <fs_sub>-recv_saknr } for CoCd |
                 && |{ <fs_sub>-recv_bukrs } has no mapped or default |
                 && |Cost Center/WBS - posting line will be rejected|
        ) TO gt_alv_result.
      ENDIF.

    ELSE.
      " Either not a primary cost element, or KSTAR exists but isn't
      " valid on the posting date -> CO object not applicable/expired,
      " keep only Profit Center.
      CLEAR: <fs_sub>-recv_kostl, <fs_sub>-recv_posid.

      " Optional: flag when the account WAS mapped as a cost element
      " record elsewhere but just isn't valid on this date, so it doesn't
      " silently look identical to "not a cost element at all". Drop this
      " if you don't want the extra noise in the log.
      READ TABLE lt_cskb TRANSPORTING NO FIELDS
        WITH KEY kokrs = 'OVL' kstar = <fs_sub>-recv_saknr.
      IF sy-subrc = 0.
        APPEND VALUE #(
          msgty   = 'W'
          message = |Cost element { <fs_sub>-recv_saknr } exists in CSKB |
                 && |but has no validity segment covering { lv_check_date DATE = USER } |
                 && |for CoCd { <fs_sub>-recv_bukrs }|
        ) TO gt_alv_result.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  RESOLVE_WBS_ELEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM resolve_wbs_element .

  TYPES: BEGIN OF ty_prps,
           objnr TYPE j_objnr,
           posid TYPE ps_posid,
         END OF ty_prps.

  DATA: lt_prps  TYPE HASHED TABLE OF ty_prps
                 WITH UNIQUE KEY objnr,
        lv_objnr TYPE j_objnr,
        lt_objnr_rng TYPE RANGE OF j_objnr,
        ls_objnr_rng LIKE LINE OF lt_objnr_rng.

  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.

  CHECK gt_subtotal IS NOT INITIAL.

  " Build OBJNR range: 'PR' + internal WBS number, for every line
  " that currently carries a raw internal number in recv_posid.
  LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_posid IS NOT INITIAL.
    CONCATENATE 'PR' <fs_sub>-recv_posid INTO lv_objnr.

    CLEAR ls_objnr_rng.
    ls_objnr_rng-sign   = 'I'.
    ls_objnr_rng-option = 'EQ'.
    ls_objnr_rng-low    = lv_objnr.
    COLLECT ls_objnr_rng INTO lt_objnr_rng.
  ENDLOOP.

  CHECK lt_objnr_rng IS NOT INITIAL.

  SELECT objnr posid
    FROM prps
    INTO TABLE lt_prps
   WHERE objnr IN lt_objnr_rng.

  LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_posid IS NOT INITIAL.
    CONCATENATE 'PR' <fs_sub>-recv_posid INTO lv_objnr.

    READ TABLE lt_prps INTO DATA(ls_prps)
      WITH TABLE KEY objnr = lv_objnr.

    IF sy-subrc = 0.
      <fs_sub>-recv_posid = ls_prps-posid.   " overwrite internal no. with real WBS element
    ELSE.
      APPEND VALUE #(
        msgty   = 'E'
        message = |WBS internal no. { <fs_sub>-recv_posid } (OBJNR { lv_objnr }) |
               && |not found in PRPS - line will be rejected|
      ) TO gt_alv_result.
      CLEAR <fs_sub>-recv_posid.
    ENDIF.
  ENDLOOP.

ENDFORM.
