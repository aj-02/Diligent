*&---------------------------------------------------------------------*
*& Include          ZOCV_OVL_TRANSFER_F01
*& Description      Form Routines - Transfer of Documents
*&                  from Colombia OCV to OVL
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& FORM f_load_jv_mapping
*& Load JV Mapping: Operating JV + Recovery Indicator -> Receiving JV
*& Tables: T8JV (JV Master), T8JJ (Recovery Indicators)
*& Only VTYPE 2 and 5 are valid for both Operating and Receiving JV
*&---------------------------------------------------------------------*
FORM f_load_jv_mapping.

  " Custom Z-table stores the JV mapping configuration
  " Structure: Op Co.Code, Op JV, Op RecIn, Rec Co.Code, Rec JV, Rec RecIn
  " Validate Op JV against T8JV (VTYPE 2 or 5 only)
  " Validate Rec JV against T8JV (VTYPE 2 or 5 only)
  " Validate Recovery Indicators against T8JJ

  REFRESH gt_jv_map.

  " Read custom JV mapping Z-table (ZJVMAP_OCV_OVL)
  SELECT op_bukrs, op_jvname, op_recin,
         rec_bukrs, rec_jvname, rec_recin
    FROM zjvmap_ocv_ovl                         "Custom mapping Z-table
    INTO TABLE @gt_jv_map
    WHERE op_bukrs = @gv_bukrs_sel.

  IF sy-subrc <> 0.
    MESSAGE w001(00) WITH 'No JV mapping configuration found for' gv_bukrs_sel.
    RETURN.
  ENDIF.

  " Validate each Operating JV against T8JV - Only VTYPE 2 and 5 allowed
  DATA lt_invalid_jv TYPE TABLE OF jv_jvnam.

  LOOP AT gt_jv_map INTO gs_jv_map.
    " Check Operating JV
    SELECT SINGLE jvname
      FROM t8jv
      INTO @DATA(lv_jvname_chk)
      WHERE bukrs  = @gs_jv_map-op_bukrs
        AND jvname = @gs_jv_map-op_jvname
        AND vtype  IN ('2', '5').
    IF sy-subrc <> 0.
      APPEND gs_jv_map-op_jvname TO lt_invalid_jv.
      DELETE gt_jv_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    " Check Receiving JV
    SELECT SINGLE jvname
      FROM t8jv
      INTO lv_jvname_chk
      WHERE bukrs  = @gs_jv_map-rec_bukrs
        AND jvname = @gs_jv_map-rec_jvname
        AND vtype  IN ('2', '5').
    IF sy-subrc <> 0.
      APPEND gs_jv_map-rec_jvname TO lt_invalid_jv.
      DELETE gt_jv_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    " Check Operating Recovery Indicator against T8JJ
    SELECT SINGLE recin
      FROM t8jj
      INTO @DATA(lv_recin_chk)
      WHERE bukrs  = @gs_jv_map-op_bukrs
        AND jvname = @gs_jv_map-op_jvname
        AND recin  = @gs_jv_map-op_recin.
    IF sy-subrc <> 0.
      DELETE gt_jv_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    " Check Receiving Recovery Indicator against T8JJ
    SELECT SINGLE recin
      FROM t8jj
      INTO lv_recin_chk
      WHERE bukrs  = @gs_jv_map-rec_bukrs
        AND jvname = @gs_jv_map-rec_jvname
        AND recin  = @gs_jv_map-rec_recin.
    IF sy-subrc <> 0.
      DELETE gt_jv_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE gt_jv_map LINES gv_lines.
  MESSAGE i001(00) WITH 'Valid JV Mapping records loaded:' gv_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_load_gl_mapping
*& Load GL Account Mapping: Operating GL -> Receiving GL
*& Tables: SKB1 (Company Code GL Accounts)
*& Valid Co.Codes must be present in JV Mapping
*&---------------------------------------------------------------------*
FORM f_load_gl_mapping.

  REFRESH gt_gl_map.

  " Collect valid Operating Company Codes from JV mapping
  DATA lt_valid_bukrs TYPE TABLE OF bukrs.
  LOOP AT gt_jv_map INTO gs_jv_map.
    APPEND gs_jv_map-op_bukrs TO lt_valid_bukrs.
  ENDLOOP.
  SORT lt_valid_bukrs.
  DELETE ADJACENT DUPLICATES FROM lt_valid_bukrs.

  " Read GL Mapping custom Z-table (ZGLMAP_OCV_OVL)
  SELECT op_bukrs, op_racct,
         rec_bukrs, rec_racct
    FROM zglmap_ocv_ovl                         "Custom GL mapping Z-table
    INTO TABLE @gt_gl_map
    WHERE op_bukrs IN @lt_valid_bukrs.

  IF sy-subrc <> 0.
    MESSAGE w001(00) WITH 'No GL mapping configuration found'.
    RETURN.
  ENDIF.

  " Validate Operating GL accounts exist in SKB1
  LOOP AT gt_gl_map INTO gs_gl_map.
    SELECT SINGLE saknr
      FROM skb1
      INTO @DATA(lv_saknr)
      WHERE bukrs = @gs_gl_map-op_bukrs
        AND saknr = @gs_gl_map-op_racct.
    IF sy-subrc <> 0.
      DELETE gt_gl_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    " Validate Receiving GL accounts exist in SKB1
    SELECT SINGLE saknr
      FROM skb1
      INTO lv_saknr
      WHERE bukrs = @gs_gl_map-rec_bukrs
        AND saknr = @gs_gl_map-rec_racct.
    IF sy-subrc <> 0.
      DELETE gt_gl_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE gt_gl_map LINES gv_lines.
  MESSAGE i001(00) WITH 'Valid GL Mapping records loaded:' gv_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_load_cc_mapping
*& Load Cost Center Mapping: Operating CC -> Receiving CC
*& Tables: CSKS (Cost Center Master)
*&---------------------------------------------------------------------*
FORM f_load_cc_mapping.

  REFRESH gt_cc_map.

  SELECT op_bukrs, op_kostl,
         rec_bukrs, rec_kostl
    FROM zccmap_ocv_ovl                         "Custom CC mapping Z-table
    INTO TABLE @gt_cc_map
    WHERE op_bukrs = @gv_bukrs_sel.

  IF sy-subrc <> 0.
    MESSAGE i001(00) WITH 'No Cost Center mapping found (optional)'.
    RETURN.
  ENDIF.

  " Validate Cost Centers exist in CSKS
  LOOP AT gt_cc_map INTO gs_cc_map.
    SELECT SINGLE kostl
      FROM csks
      INTO @DATA(lv_kostl)
      WHERE kokrs = @gs_cc_map-op_bukrs         "Controlling Area ~ Co.Code
        AND kostl = @gs_cc_map-op_kostl.
    IF sy-subrc <> 0.
      DELETE gt_cc_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    SELECT SINGLE kostl
      FROM csks
      INTO lv_kostl
      WHERE kokrs = @gs_cc_map-rec_bukrs
        AND kostl = @gs_cc_map-rec_kostl.
    IF sy-subrc <> 0.
      DELETE gt_cc_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE gt_cc_map LINES gv_lines.
  MESSAGE i001(00) WITH 'Valid Cost Center Mapping records loaded:' gv_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_load_wbs_mapping
*& Load WBS Element Mapping: Operating WBS -> Receiving WBS
*& Tables: PRPS (WBS Element Master)
*&---------------------------------------------------------------------*
FORM f_load_wbs_mapping.

  REFRESH gt_wbs_map.

  SELECT op_bukrs, op_pspnr,
         rec_bukrs, rec_pspnr
    FROM zwbsmap_ocv_ovl                        "Custom WBS mapping Z-table
    INTO TABLE @gt_wbs_map
    WHERE op_bukrs = @gv_bukrs_sel.

  IF sy-subrc <> 0.
    MESSAGE i001(00) WITH 'No WBS mapping found (optional)'.
    RETURN.
  ENDIF.

  " Validate WBS elements exist in PRPS
  LOOP AT gt_wbs_map INTO gs_wbs_map.
    SELECT SINGLE pspnr
      FROM prps
      INTO @DATA(lv_pspnr)
      WHERE pspnr = @gs_wbs_map-op_pspnr.
    IF sy-subrc <> 0.
      DELETE gt_wbs_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    SELECT SINGLE pspnr
      FROM prps
      INTO lv_pspnr
      WHERE pspnr = @gs_wbs_map-rec_pspnr.
    IF sy-subrc <> 0.
      DELETE gt_wbs_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE gt_wbs_map LINES gv_lines.
  MESSAGE i001(00) WITH 'Valid WBS Mapping records loaded:' gv_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_load_pc_mapping
*& Load Profit Center Mapping: Operating PC -> Receiving PC
*& Tables: CEPC (Profit Center Master)
*&---------------------------------------------------------------------*
FORM f_load_pc_mapping.

  REFRESH gt_pc_map.

  SELECT op_bukrs, op_prctr,
         rec_bukrs, rec_prctr
    FROM zpcmap_ocv_ovl                         "Custom PC mapping Z-table
    INTO TABLE @gt_pc_map
    WHERE op_bukrs = @gv_bukrs_sel.

  IF sy-subrc <> 0.
    MESSAGE i001(00) WITH 'No Profit Center mapping found (optional)'.
    RETURN.
  ENDIF.

  " Validate Profit Centers exist in CEPC
  LOOP AT gt_pc_map INTO gs_pc_map.
    SELECT SINGLE prctr
      FROM cepc
      INTO @DATA(lv_prctr)
      WHERE prctr = @gs_pc_map-op_prctr
        AND bukrs = @gs_pc_map-op_bukrs.
    IF sy-subrc <> 0.
      DELETE gt_pc_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    SELECT SINGLE prctr
      FROM cepc
      INTO lv_prctr
      WHERE prctr = @gs_pc_map-rec_prctr
        AND bukrs = @gs_pc_map-rec_bukrs.
    IF sy-subrc <> 0.
      DELETE gt_pc_map INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE gt_pc_map LINES gv_lines.
  MESSAGE i001(00) WITH 'Valid Profit Center Mapping records loaded:' gv_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_read_jvso1
*& Read JV Actual Line Items from JVSO1
*& Filter: Ledger 4A and 4C, RRCTY=0, RVERS=1,
*&          RYEAR = selection, POPER = selection,
*&          RJVNAM = All Operating JVs from mapping
*&          RRECIN = Recovery Indicators from mapping
*&---------------------------------------------------------------------*
FORM f_read_jvso1.

  REFRESH gt_jvso1.

  " Build ranges for JV names from mapping table
  DATA: lr_jvnam  TYPE RANGE OF jv_jvnam,
        lr_recin  TYPE RANGE OF jv_recin,
        lr_ledger TYPE RANGE OF fins_ledger.

  " Ledger range: 4A and 4C
  lr_ledger = VALUE #(
    ( sign = 'I' option = 'EQ' low = gc_ledger_4a )
    ( sign = 'I' option = 'EQ' low = gc_ledger_4c )
  ).

  " Operating JV range
  LOOP AT gt_jv_map INTO gs_jv_map.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = gs_jv_map-op_jvname ) TO lr_jvnam.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = gs_jv_map-op_recin  ) TO lr_recin.
  ENDLOOP.
  SORT lr_jvnam.
  DELETE ADJACENT DUPLICATES FROM lr_jvnam.
  SORT lr_recin.
  DELETE ADJACENT DUPLICATES FROM lr_recin.

  " Read JVSO1: JV Summary / Line Items
  SELECT rldnr, rrcty, rvers, ryear, poper,
         rjvnam, rrecin, racct, rbukrs,
         regrou, rcntr, rordnr, rprojk, rprctr,
         budat, tsl, hsl, ksl
    FROM jvso1
    INTO TABLE @gt_jvso1
    WHERE rldnr  IN @lr_ledger
      AND rrcty   = @gc_rrcty
      AND rvers   = @gc_rvers
      AND ryear   = @gv_gjahr
      AND poper   = @gv_poper
      AND rjvnam  IN @lr_jvnam
      AND rrecin  IN @lr_recin
      AND rbukrs  = @gv_bukrs_sel.

  IF sy-subrc <> 0.
    MESSAGE w001(00) WITH 'No data found in JVSO1 for given criteria'.
  ELSE.
    DESCRIBE TABLE gt_jvso1 LINES gv_lines.
    MESSAGE i001(00) WITH 'JVSO1 records fetched:' gv_lines.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_aggregate_jvso1
*& Subtotal JVSO1 at: RJVNAM / RRECIN / RACCT / RCNTR / RORDNR /
*&                    RPROJK / RPRCTR for TSL / HSL / KSL
*&---------------------------------------------------------------------*
FORM f_aggregate_jvso1.

  REFRESH gt_jvso1_agg.

  " Sort before aggregation
  SORT gt_jvso1 BY rjvnam rrecin racct rcntr rordnr rprojk rprctr rbukrs.

  LOOP AT gt_jvso1 INTO gs_jvso1.

    " Try to find existing aggregated entry for same key
    READ TABLE gt_jvso1_agg INTO gs_jvso1_agg
      WITH KEY rjvnam = gs_jvso1-rjvnam
               rrecin = gs_jvso1-rrecin
               racct  = gs_jvso1-racct
               rcntr  = gs_jvso1-rcntr
               rordnr = gs_jvso1-rordnr
               rprojk = gs_jvso1-rprojk
               rprctr = gs_jvso1-rprctr
               rbukrs = gs_jvso1-rbukrs.

    IF sy-subrc = 0.
      " Accumulate amounts
      gs_jvso1_agg-tsl = gs_jvso1_agg-tsl + gs_jvso1-tsl.
      gs_jvso1_agg-hsl = gs_jvso1_agg-hsl + gs_jvso1-hsl.
      gs_jvso1_agg-ksl = gs_jvso1_agg-ksl + gs_jvso1-ksl.
      " Use latest BUDAT for last-day-of-month calculation
      IF gs_jvso1-budat > gs_jvso1_agg-budat.
        gs_jvso1_agg-budat = gs_jvso1-budat.
      ENDIF.
      MODIFY gt_jvso1_agg FROM gs_jvso1_agg INDEX sy-tabix.
    ELSE.
      " New aggregation entry
      CLEAR gs_jvso1_agg.
      gs_jvso1_agg-rjvnam = gs_jvso1-rjvnam.
      gs_jvso1_agg-rrecin = gs_jvso1-rrecin.
      gs_jvso1_agg-racct  = gs_jvso1-racct.
      gs_jvso1_agg-rcntr  = gs_jvso1-rcntr.
      gs_jvso1_agg-rordnr = gs_jvso1-rordnr.
      gs_jvso1_agg-rprojk = gs_jvso1-rprojk.
      gs_jvso1_agg-rprctr = gs_jvso1-rprctr.
      gs_jvso1_agg-rbukrs = gs_jvso1-rbukrs.
      gs_jvso1_agg-budat  = gs_jvso1-budat.
      gs_jvso1_agg-tsl    = gs_jvso1-tsl.
      gs_jvso1_agg-hsl    = gs_jvso1-hsl.
      gs_jvso1_agg-ksl    = gs_jvso1-ksl.
      APPEND gs_jvso1_agg TO gt_jvso1_agg.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE gt_jvso1_agg LINES gv_lines.
  MESSAGE i001(00) WITH 'Aggregated line items:' gv_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_get_currency_mapping
*& Use JV_AND_FI_CURRENCIES to map Sender and Receiver currencies
*& for each Operating Co.Code -> Receiving Co.Code combination
*&---------------------------------------------------------------------*
FORM f_get_currency_mapping.

  REFRESH gt_curr_map.

  " Collect unique Co.Code pairs
  DATA: BEGIN OF ls_pair,
          op_bukrs  TYPE bukrs,
          rec_bukrs TYPE bukrs,
        END OF ls_pair,
        lt_pairs LIKE TABLE OF ls_pair.

  LOOP AT gt_jv_map INTO gs_jv_map.
    ls_pair-op_bukrs  = gs_jv_map-op_bukrs.
    ls_pair-rec_bukrs = gs_jv_map-rec_bukrs.
    APPEND ls_pair TO lt_pairs.
  ENDLOOP.
  SORT lt_pairs.
  DELETE ADJACENT DUPLICATES FROM lt_pairs.

  " For each unique pair call JV_AND_FI_CURRENCIES function
  DATA:
    lt_jv_currencies  TYPE TABLE OF t_jv_currency, "JV Currency result table
    lv_op_waers       TYPE waers,
    lv_rec_waers      TYPE waers,
    lv_op_hwaer       TYPE waers,
    lv_rec_hwaer      TYPE waers.

  LOOP AT lt_pairs INTO ls_pair.
    CLEAR gt_curr_map.

    CALL FUNCTION 'JV_AND_FI_CURRENCIES'
      EXPORTING
        i_sender_bukrs   = ls_pair-op_bukrs
        i_receiver_bukrs = ls_pair-rec_bukrs
      IMPORTING
        e_sender_waers   = lv_op_waers
        e_receiver_waers = lv_rec_waers
        e_sender_hwaer   = lv_op_hwaer
        e_receiver_hwaer = lv_rec_hwaer
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.

    IF sy-subrc = 0.
      CLEAR gs_curr_map.
      gs_curr_map-op_bukrs  = ls_pair-op_bukrs.
      gs_curr_map-rec_bukrs = ls_pair-rec_bukrs.
      gs_curr_map-op_waers  = lv_op_waers.
      gs_curr_map-rec_waers = lv_rec_waers.
      gs_curr_map-op_hwaer  = lv_op_hwaer.
      gs_curr_map-rec_hwaer = lv_rec_hwaer.
      APPEND gs_curr_map TO gt_curr_map.
    ELSE.
      MESSAGE w001(00) WITH 'Currency mapping failed for'
                             ls_pair-op_bukrs '->' ls_pair-rec_bukrs.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_get_last_day_of_month
*& Derive the last day of the month from BUDAT on JVSO1 records
*& This last day is used as Document Date and Posting Date
*&---------------------------------------------------------------------*
FORM f_get_last_day_of_month.

  " We compute the last day of the posting month based on year + period
  " Build first day of the NEXT month, then subtract 1 day
  DATA:
    lv_next_month  TYPE i,
    lv_next_year   TYPE gjahr,
    lv_date_str    TYPE char8,
    lv_first_next  TYPE d.

  lv_next_month = gv_poper + 1.
  lv_next_year  = gv_gjahr.

  IF lv_next_month > 12.
    lv_next_month = 1.
    lv_next_year  = gv_gjahr + 1.
  ENDIF.

  " Build YYYYMM01 string for first day of next month
  lv_date_str = |{ lv_next_year }{ lv_next_month WIDTH = 2 PAD = '0' }01|.
  lv_first_next = lv_date_str.

  " Subtract 1 day to get last day of current posting month
  gv_last_day = lv_first_next - 1.
  gv_doc_date  = gv_last_day.
  gv_post_date = gv_last_day.

  MESSAGE i001(00) WITH 'Posting / Document Date set to:' gv_last_day.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_process_and_post
*& For each aggregated JVSO1 line:
*&   1. Resolve JV Mapping     (Op JV + RecIn -> Rec JV + RecIn)
*&   2. Resolve GL Mapping     (Op GL -> Rec GL)
*&   3. Resolve CC / WBS / PC Mapping
*&   4. Call BAPI_ACCOUNTING_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_process_and_post.

  DATA:
    ls_agg         TYPE ty_jvso1_agg,
    ls_jv_map      TYPE ty_jv_map,
    ls_gl_map      TYPE ty_gl_map,
    ls_cc_map      TYPE ty_cc_map,
    ls_wbs_map     TYPE ty_wbs_map,
    ls_pc_map      TYPE ty_pc_map,
    ls_curr_map    TYPE ty_curr_map,
    lv_rec_bukrs   TYPE bukrs,
    lv_rec_jvnam   TYPE jv_jvnam,
    lv_rec_recin   TYPE jv_recin,
    lv_rec_racct   TYPE hkont,
    lv_rec_kostl   TYPE kostl,
    lv_rec_pspnr   TYPE ps_psp_pnr,
    lv_rec_prctr   TYPE prctr,
    lv_rec_waers   TYPE waers,
    lv_op_waers    TYPE waers.

  " BAPI data objects
  DATA:
    ls_doc_header  TYPE bapiache09,
    lt_acc_gl      TYPE TABLE OF bapiacgl09,
    ls_acc_gl      TYPE bapiacgl09,
    lt_acc_cost    TYPE TABLE OF bapiacpa09,
    ls_acc_cost    TYPE bapiacpa09,
    lt_curr_amt    TYPE TABLE OF bapiaccr09,
    ls_curr_amt    TYPE bapiaccr09,
    lt_return      TYPE TABLE OF bapiret2,
    ls_return      TYPE bapiret2,
    lv_obj_key     TYPE bapibus2032_key-obj_key,
    lv_line_num    TYPE int4.

  LOOP AT gt_jvso1_agg INTO ls_agg.

    CLEAR: ls_jv_map, ls_gl_map, ls_cc_map, ls_wbs_map, ls_pc_map.
    CLEAR: lv_rec_bukrs, lv_rec_jvnam, lv_rec_recin, lv_rec_racct.
    CLEAR: lv_rec_kostl, lv_rec_pspnr, lv_rec_prctr.
    CLEAR: lt_acc_gl, lt_acc_cost, lt_curr_amt, lt_return.
    lv_line_num = 0.

    "--------------------------------------------------------------------
    " Step 1: Resolve JV Mapping
    "--------------------------------------------------------------------
    READ TABLE gt_jv_map INTO ls_jv_map
      WITH KEY op_bukrs  = ls_agg-rbukrs
               op_jvname = ls_agg-rjvnam
               op_recin  = ls_agg-rrecin.

    IF sy-subrc <> 0.
      " No JV mapping found - skip and log
      PERFORM f_write_log USING ls_agg '' '' '' '' '' '' '' '' ''
                                ls_agg-tsl ls_agg-hsl ls_agg-ksl
                                'W' 'No JV mapping found - skipped' ''.
      CONTINUE.
    ENDIF.

    lv_rec_bukrs = ls_jv_map-rec_bukrs.
    lv_rec_jvnam = ls_jv_map-rec_jvname.
    lv_rec_recin = ls_jv_map-rec_recin.

    "--------------------------------------------------------------------
    " Step 2: Resolve GL Mapping
    "--------------------------------------------------------------------
    READ TABLE gt_gl_map INTO ls_gl_map
      WITH KEY op_bukrs  = ls_agg-rbukrs
               op_racct  = ls_agg-racct
               rec_bukrs = lv_rec_bukrs.

    IF sy-subrc <> 0.
      " No GL mapping found - skip and log
      PERFORM f_write_log USING ls_agg-rbukrs ls_agg-rjvnam lv_rec_bukrs
                                lv_rec_jvnam ls_agg-racct '' '' '' '' ''
                                ls_agg-tsl ls_agg-hsl ls_agg-ksl
                                'W' 'No GL mapping found - skipped' ''.
      CONTINUE.
    ENDIF.

    lv_rec_racct = ls_gl_map-rec_racct.

    "--------------------------------------------------------------------
    " Step 3: Resolve Cost Center Mapping (optional)
    "--------------------------------------------------------------------
    IF ls_agg-rcntr IS NOT INITIAL.
      READ TABLE gt_cc_map INTO ls_cc_map
        WITH KEY op_bukrs  = ls_agg-rbukrs
                 op_kostl  = ls_agg-rcntr
                 rec_bukrs = lv_rec_bukrs.
      IF sy-subrc = 0.
        lv_rec_kostl = ls_cc_map-rec_kostl.
      ELSE.
        " CC mapping not found - post without cost center (or skip per business rules)
        CLEAR lv_rec_kostl.
      ENDIF.
    ENDIF.

    "--------------------------------------------------------------------
    " Step 4: Resolve WBS Mapping (optional)
    "--------------------------------------------------------------------
    IF ls_agg-rprojk IS NOT INITIAL.
      READ TABLE gt_wbs_map INTO ls_wbs_map
        WITH KEY op_bukrs  = ls_agg-rbukrs
                 op_pspnr  = ls_agg-rprojk
                 rec_bukrs = lv_rec_bukrs.
      IF sy-subrc = 0.
        lv_rec_pspnr = ls_wbs_map-rec_pspnr.
      ELSE.
        CLEAR lv_rec_pspnr.
      ENDIF.
    ENDIF.

    "--------------------------------------------------------------------
    " Step 5: Resolve Profit Center Mapping (optional)
    "--------------------------------------------------------------------
    IF ls_agg-rprctr IS NOT INITIAL.
      READ TABLE gt_pc_map INTO ls_pc_map
        WITH KEY op_bukrs  = ls_agg-rbukrs
                 op_prctr  = ls_agg-rprctr
                 rec_bukrs = lv_rec_bukrs.
      IF sy-subrc = 0.
        lv_rec_prctr = ls_pc_map-rec_prctr.
      ELSE.
        CLEAR lv_rec_prctr.
      ENDIF.
    ENDIF.

    "--------------------------------------------------------------------
    " Step 6: Get Currency Mapping
    "--------------------------------------------------------------------
    READ TABLE gt_curr_map INTO ls_curr_map
      WITH KEY op_bukrs  = ls_agg-rbukrs
               rec_bukrs = lv_rec_bukrs.

    IF sy-subrc = 0.
      lv_op_waers  = ls_curr_map-op_waers.
      lv_rec_waers = ls_curr_map-rec_waers.
    ELSE.
      " Fallback: read from T001
      SELECT SINGLE waers INTO @lv_rec_waers FROM t001
        WHERE bukrs = @lv_rec_bukrs.
    ENDIF.

    "--------------------------------------------------------------------
    " Step 7: Build BAPI Document Header
    "--------------------------------------------------------------------
    CLEAR ls_doc_header.
    ls_doc_header-bus_act     = 'RFBU'.           "FI Posting
    ls_doc_header-username    = sy-uname.
    ls_doc_header-header_txt  = |OCV->OVL Transfer { gv_gjahr }/{ gv_poper }|.
    ls_doc_header-comp_code   = lv_rec_bukrs.
    ls_doc_header-doc_date    = gv_doc_date.
    ls_doc_header-pstng_date  = gv_post_date.
    ls_doc_header-doc_type    = gc_doc_type.
    ls_doc_header-ref_doc_no  = |{ ls_agg-rjvnam }-{ ls_agg-rrecin }|.

    "--------------------------------------------------------------------
    " Step 8: Build GL Account Line Item (Credit on Receiving side)
    "--------------------------------------------------------------------
    lv_line_num = lv_line_num + 1.
    CLEAR ls_acc_gl.
    ls_acc_gl-itemno_acc  = lv_line_num.
    ls_acc_gl-gl_account  = lv_rec_racct.
    ls_acc_gl-comp_code   = lv_rec_bukrs.
    ls_acc_gl-pstng_date  = gv_post_date.
    ls_acc_gl-doc_type    = gc_doc_type.
    ls_acc_gl-fisc_year   = gv_gjahr.
    ls_acc_gl-currency    = lv_rec_waers.
    ls_acc_gl-amt_doccur  = ls_agg-tsl.          "Transaction currency amount
    ls_acc_gl-amt_base    = ls_agg-hsl.           "Local currency amount
    " Set JV fields on the receiving GL line
    ls_acc_gl-profit_ctr  = lv_rec_prctr.
    ls_acc_gl-costcenter  = lv_rec_kostl.
    ls_acc_gl-wbs_elem    = lv_rec_pspnr.
    APPEND ls_acc_gl TO lt_acc_gl.

    "--------------------------------------------------------------------
    " Step 9: Build Cost Object Assignment Line
    "--------------------------------------------------------------------
    IF lv_rec_kostl IS NOT INITIAL OR
       lv_rec_pspnr IS NOT INITIAL.

      lv_line_num = lv_line_num + 1.
      CLEAR ls_acc_cost.
      ls_acc_cost-itemno_acc  = lv_line_num.
      ls_acc_cost-gl_account  = lv_rec_racct.
      ls_acc_cost-comp_code   = lv_rec_bukrs.
      ls_acc_cost-costcenter  = lv_rec_kostl.
      ls_acc_cost-wbs_elem    = lv_rec_pspnr.
      ls_acc_cost-profit_ctr  = lv_rec_prctr.
      ls_acc_cost-currency    = lv_rec_waers.
      ls_acc_cost-amt_doccur  = ls_agg-tsl.
      APPEND ls_acc_cost TO lt_acc_cost.

    ENDIF.

    "--------------------------------------------------------------------
    " Step 10: Currency Amount Line
    "--------------------------------------------------------------------
    CLEAR ls_curr_amt.
    ls_curr_amt-itemno_acc  = 1.
    ls_curr_amt-currency    = lv_rec_waers.
    ls_curr_amt-amt_doccur  = ls_agg-tsl.
    ls_curr_amt-currency_hd = ls_curr_map-rec_hwaer.
    ls_curr_amt-amt_base    = ls_agg-hsl.
    APPEND ls_curr_amt TO lt_curr_amt.

    "--------------------------------------------------------------------
    " Step 11: Post or Simulate
    "--------------------------------------------------------------------
    IF gv_test_run = abap_true.
      " TEST RUN: Only simulate, do not commit
      CALL FUNCTION 'BAPI_ACCOUNTING_DOCUMENT_CHECK'
        EXPORTING
          documentheader = ls_doc_header
        TABLES
          accountgl      = lt_acc_gl
          accountassignment = lt_acc_cost
          currencyamount = lt_curr_amt
          return         = lt_return.

      PERFORM f_collect_bapi_messages
        USING ls_agg lv_rec_bukrs lv_rec_jvnam lv_rec_racct
              lv_rec_kostl lv_rec_pspnr lv_rec_prctr
              ls_agg-tsl ls_agg-hsl ls_agg-ksl
              lt_return '(Test)'.
    ELSE.
      " ACTUAL RUN: Post the document
      CALL FUNCTION 'BAPI_ACCOUNTING_DOCUMENT_POST'
        EXPORTING
          documentheader = ls_doc_header
        IMPORTING
          obj_key        = lv_obj_key
        TABLES
          accountgl      = lt_acc_gl
          accountassignment = lt_acc_cost
          currencyamount = lt_curr_amt
          return         = lt_return.

      " Check for errors in BAPI return
      READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
      IF sy-subrc <> 0.
        " No error - commit
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
        " Extract document number from obj_key
        gv_belnr = lv_obj_key(10).
      ELSE.
        " Error - rollback
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        CLEAR gv_belnr.
      ENDIF.

      PERFORM f_collect_bapi_messages
        USING ls_agg lv_rec_bukrs lv_rec_jvnam lv_rec_racct
              lv_rec_kostl lv_rec_pspnr lv_rec_prctr
              ls_agg-tsl ls_agg-hsl ls_agg-ksl
              lt_return gv_belnr.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_collect_bapi_messages
*& Collect BAPI return messages into the log table
*&---------------------------------------------------------------------*
FORM f_collect_bapi_messages
  USING
    is_agg        TYPE ty_jvso1_agg
    iv_rec_bukrs  TYPE bukrs
    iv_rec_jvnam  TYPE jv_jvnam
    iv_rec_racct  TYPE hkont
    iv_rec_kostl  TYPE kostl
    iv_rec_pspnr  TYPE ps_psp_pnr
    iv_rec_prctr  TYPE prctr
    iv_tsl        TYPE wertv9
    iv_hsl        TYPE wertv9
    iv_ksl        TYPE wertv9
    it_return     TYPE bapiret2_t
    iv_belnr      TYPE belnr_d.

  DATA ls_ret TYPE bapiret2.

  LOOP AT it_return INTO ls_ret WHERE type CA 'EWIS'.
    CLEAR gs_log.
    gs_log-op_bukrs   = is_agg-rbukrs.
    gs_log-op_jvnam   = is_agg-rjvnam.
    gs_log-rec_bukrs  = iv_rec_bukrs.
    gs_log-rec_jvnam  = iv_rec_jvnam.
    gs_log-racct      = iv_rec_racct.
    gs_log-rcntr      = iv_rec_kostl.
    gs_log-rprojk     = iv_rec_pspnr.
    gs_log-rprctr     = iv_rec_prctr.
    gs_log-tsl        = iv_tsl.
    gs_log-hsl        = iv_hsl.
    gs_log-ksl        = iv_ksl.
    gs_log-msgty      = ls_ret-type.
    gs_log-msgtxt     = ls_ret-message.
    gs_log-belnr      = iv_belnr.
    APPEND gs_log TO gt_log.
  ENDLOOP.

  " If no messages, write success entry
  IF it_return IS INITIAL.
    CLEAR gs_log.
    gs_log-op_bukrs   = is_agg-rbukrs.
    gs_log-op_jvnam   = is_agg-rjvnam.
    gs_log-rec_bukrs  = iv_rec_bukrs.
    gs_log-rec_jvnam  = iv_rec_jvnam.
    gs_log-racct      = iv_rec_racct.
    gs_log-rcntr      = iv_rec_kostl.
    gs_log-rprojk     = iv_rec_pspnr.
    gs_log-rprctr     = iv_rec_prctr.
    gs_log-tsl        = iv_tsl.
    gs_log-hsl        = iv_hsl.
    gs_log-ksl        = iv_ksl.
    gs_log-msgty      = 'S'.
    gs_log-msgtxt     = |Document posted: { iv_belnr }|.
    gs_log-belnr      = iv_belnr.
    APPEND gs_log TO gt_log.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_write_log
*& Write a single log entry with custom message
*&---------------------------------------------------------------------*
FORM f_write_log
  USING
    iv_op_bukrs  TYPE bukrs
    iv_op_jvnam  TYPE jv_jvnam
    iv_rec_bukrs TYPE bukrs
    iv_rec_jvnam TYPE jv_jvnam
    iv_racct     TYPE hkont
    iv_rcntr     TYPE kostl
    iv_rordnr    TYPE aufnr
    iv_rprojk    TYPE ps_psp_pnr
    iv_rprctr    TYPE prctr
    iv_regrou    TYPE jv_egroup
    iv_tsl       TYPE wertv9
    iv_hsl       TYPE wertv9
    iv_ksl       TYPE wertv9
    iv_msgty     TYPE msgty
    iv_msgtxt    TYPE string
    iv_belnr     TYPE belnr_d.

  CLEAR gs_log.
  gs_log-op_bukrs  = iv_op_bukrs.
  gs_log-op_jvnam  = iv_op_jvnam.
  gs_log-rec_bukrs = iv_rec_bukrs.
  gs_log-rec_jvnam = iv_rec_jvnam.
  gs_log-racct     = iv_racct.
  gs_log-rcntr     = iv_rcntr.
  gs_log-rprojk    = iv_rprojk.
  gs_log-rprctr    = iv_rprctr.
  gs_log-tsl       = iv_tsl.
  gs_log-hsl       = iv_hsl.
  gs_log-ksl       = iv_ksl.
  gs_log-msgty     = iv_msgty.
  gs_log-msgtxt    = iv_msgtxt.
  gs_log-belnr     = iv_belnr.
  APPEND gs_log TO gt_log.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM f_display_results
*& Display processing log using ALV Grid
*&---------------------------------------------------------------------*
FORM f_display_results.

  DATA:
    lo_alv       TYPE REF TO cl_salv_table,
    lo_columns   TYPE REF TO cl_salv_columns_table,
    lo_col       TYPE REF TO cl_salv_column_table,
    lo_functions TYPE REF TO cl_salv_functions,
    lo_display   TYPE REF TO cl_salv_display_settings,
    lo_layout    TYPE REF TO cl_salv_layout,
    lx_msg       TYPE REF TO cx_salv_msg.

  IF gt_log IS INITIAL.
    MESSAGE i001(00) WITH 'No log entries to display'.
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_log ).

      " Enable standard functions (sort, filter, export)
      lo_functions = lo_alv->get_functions( ).
      lo_functions->set_all( abap_true ).

      " Display settings
      lo_display = lo_alv->get_display_settings( ).
      lo_display->set_striped_pattern( abap_true ).
      lo_display->set_list_header( |OCV -> OVL Transfer Log | &
                                   |{ gv_gjahr }/{ gv_poper } | &
                                   |{ COND #( WHEN gv_test_run = abap_true
                                              THEN '[TEST RUN]'
                                              ELSE '[LIVE RUN]' ) }| ).

      " Column labels
      lo_columns = lo_alv->get_columns( ).

      TRY.
          lo_col ?= lo_columns->get_column( 'OP_BUKRS' ).
          lo_col->set_short_text( 'Op BuKrs' ).
          lo_col->set_medium_text( 'Oper. Co.Code' ).
        CATCH cx_salv_not_found. ##NO_HANDLER
      ENDTRY.

      TRY.
          lo_col ?= lo_columns->get_column( 'OP_JVNAM' ).
          lo_col->set_short_text( 'Op JV' ).
          lo_col->set_medium_text( 'Oper. JV Name' ).
        CATCH cx_salv_not_found. ##NO_HANDLER
      ENDTRY.

      TRY.
          lo_col ?= lo_columns->get_column( 'REC_BUKRS' ).
          lo_col->set_short_text( 'Rec BuKrs' ).
          lo_col->set_medium_text( 'Recv. Co.Code' ).
        CATCH cx_salv_not_found. ##NO_HANDLER
      ENDTRY.

      TRY.
          lo_col ?= lo_columns->get_column( 'REC_JVNAM' ).
          lo_col->set_short_text( 'Rec JV' ).
          lo_col->set_medium_text( 'Recv. JV Name' ).
        CATCH cx_salv_not_found. ##NO_HANDLER
      ENDTRY.

      TRY.
          lo_col ?= lo_columns->get_column( 'MSGTY' ).
          lo_col->set_short_text( 'MsgType' ).
        CATCH cx_salv_not_found. ##NO_HANDLER
      ENDTRY.

      TRY.
          lo_col ?= lo_columns->get_column( 'BELNR' ).
          lo_col->set_short_text( 'Doc No.' ).
          lo_col->set_medium_text( 'Posted Doc No.' ).
        CATCH cx_salv_not_found. ##NO_HANDLER
      ENDTRY.

      lo_alv->display( ).

    CATCH cx_salv_msg INTO lx_msg.
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
