*&---------------------------------------------------------------------*
*& WRICEF        : 195_BRD_FS_ZMB5B_Report  (follow-up change)
*& Project       : UDAY  /  Astral Limited
*& Module        : MM / CO
*& Object        : ZRM07MLBD  (copy of standard MB5B program RM07MLBD)
*& Transaction   : ZMB5B
*& Change tag    : ZMB5B 195_BRD_FS
*& Date          : 18.08.2026
*&---------------------------------------------------------------------*
*& REQUIREMENT
*&   For radio button "Storage Loc./ Batch Stock" (LGBST) show two more
*&   fields in the report :
*&       - Receipt amount   ( total value of the goods receipts )
*&       - Issue amount     ( total value of the goods issues   )
*&---------------------------------------------------------------------*
*& WHY THE COLUMNS STAY EMPTY WHEN ONLY THE FIELD CATALOG IS CHANGED
*&
*&   The two figures already EXIST as fields in the output structures :
*&       BESTAND-SOLLWERT / -HABENWERT      (include RM07MLDD, l.566/567)
*&       STYPE_TOTALS_FLAT-SOLLWERT / -HABENWERT           (RM07MLDD)
*&   but the standard NEVER FILLS them outside valuated stock :
*&
*&   1) FORM summen_bilden (main program, l.3641)
*&        IF bwbst = ' '.       -> COLLECT sum_mat / sum_char
*&                                 ( these tables carry MENGE only,
*&                                   they have NO DMBTR component )
*&        ELSEIF bwbst = 'X'.   -> COLLECT mat_sum
*&                                 ( mat_sum HAS dmbtr, l.673 RM07MLDD )
*&
*&   2) FORM bestaende_berechnen (include RM07MLBD_FORM_01, l.1638)
*&        IF bwbst = 'X'.       -> MOVE mat_sum-dmbtr TO bestand-sollwert
*&                                 MOVE mat_sum-dmbtr TO bestand-habenwert
*&        ELSEIF lgbst = 'X'.   -> quantities only, no value at all
*&
*&   3) BESTAND-WAERS is filled by MOVE-CORRESPONDING g_s_mbew TO bestand
*&      in the BWBST branch only, so in the LGBST branch the currency key
*&      is initial as well -> even a filled amount would be rendered
*&      without / with a wrong currency.
*&
*&   4) FORM create_fieldcat_totals_flat (main program, l.2572)
*&        IF bwbst = 'X'.  -> only there are ANFWERT / SOLLWERT /
*&                            HABENWERT / ENDWERT / WAERS appended.
*&
*&   So the amounts have to be AGGREGATED and MOVED first; adding the
*&   columns to the field catalog alone can only produce empty columns.
*&
*&   Note : ANFWERT (opening value) and ENDWERT (closing value) are NOT
*&   delivered here. They are derived from MBEW-SALK3 (valuated stock),
*&   which does not exist per storage location - that is why the standard
*&   omits them in this view. Only the two requested fields are added.
*&---------------------------------------------------------------------*
*& OBJECTS TOUCHED
*&   ZRM07MLBD  (main program)  - all 7 units below.
*&   The four includes stay unchanged and keep their standard names,
*&   exactly as in the first delivery.
*&---------------------------------------------------------------------*


*&=====================================================================*
*& UNIT 1  -  global work table for the value sums                      *
*&   Place    : main program, directly after  INCLUDE: rm07mldd.        *
*&              (approx. line 332)                                      *
*&=====================================================================*

  INCLUDE:  rm07mldd.     " reportspezifische Datendefinitionen

*BOC By Arnav on 18/08/26
* ZMB5B 195_BRD_FS : receipt / issue amount for "Storage Loc./Batch
* Stock". The standard sum tables SUM_MAT and SUM_CHAR (RM07MLDD)
* aggregate quantities only, so the values are aggregated here.
  DATA : BEGIN OF gt_zwert_sum OCCURS 100,
           werks     LIKE mseg-werks,
           matnr     LIKE mseg-matnr,
           charg     LIKE mseg-charg,
           shkzg     LIKE mseg-shkzg,
           dmbtr(09) TYPE p DECIMALS 2,
         END OF gt_zwert_sum.
*EOC By Arnav on 18/08/26


*&=====================================================================*
*& UNIT 2  -  aggregate MSEG-DMBTR per material / batch and debit-credit*
*&   Form     : summen_bilden   (main program, approx. line 3641)       *
*&   Place    : at the very end of the form, between the closing        *
*&              ENDIF. of the "IF bwbst = ' ' ... ELSEIF bwbst = 'X'"   *
*&              block and ENDFORM.          (approx. line 3922)         *
*&                                                                      *
*&   At this point G_T_MSEG_LEAN contains exactly the accepted material *
*&   document items - the standard loops above have already DELETEd the *
*&   automatically created / transfer postings. DMBTR and WAERS are     *
*&   part of STYPE_MSEG_LEAN and are therefore already selected from    *
*&   MATDOC by f1000_select_mseg_mkpf - nothing extra is read.          *
*&=====================================================================*

    IF curm = '3'.            "Materialbelege auf Buchungskreisebene
      SORT mat_sum BY bwkey matnr shkzg DESCENDING.
      LOOP AT mat_sum.
        MOVE-CORRESPONDING mat_sum TO mat_sum_buk.
        COLLECT mat_sum_buk.
      ENDLOOP.
    ENDIF.
  ENDIF.

*BOC By Arnav on 18/08/26
* ZMB5B 195_BRD_FS : sum the values for the radio button
* "Storage Loc./Batch Stock"
  IF  lgbst = 'X'.
    REFRESH                  gt_zwert_sum.

    LOOP AT g_t_mseg_lean    INTO  g_s_mseg_lean.
      CLEAR                  gt_zwert_sum.

      MOVE : g_s_mseg_lean-werks  TO  gt_zwert_sum-werks,
             g_s_mseg_lean-matnr  TO  gt_zwert_sum-matnr,
             g_s_mseg_lean-shkzg  TO  gt_zwert_sum-shkzg,
             g_s_mseg_lean-dmbtr  TO  gt_zwert_sum-dmbtr.

*     on material level the stocks are summarised over the batches
      IF  xchar = 'X'.
        MOVE  g_s_mseg_lean-charg TO  gt_zwert_sum-charg.
      ENDIF.

      COLLECT                gt_zwert_sum.
    ENDLOOP.

    SORT  gt_zwert_sum       BY  werks matnr charg shkzg.
  ENDIF.
*EOC By Arnav on 18/08/26

ENDFORM.                               " SUMMEN_BILDEN


*&=====================================================================*
*& UNIT 3a -  call the new form                                         *
*&   Place    : main program, END-OF-SELECTION, directly after          *
*&              PERFORM bestaende_berechnen.   (approx. line 1400)      *
*&=====================================================================*

    PERFORM summen_bilden.

    PERFORM bestaende_berechnen.
*BOC By Arnav on 18/08/26
*   ZMB5B 195_BRD_FS : the standard fills the value fields for the
*   valuated stock only - add them for the storage location view
    PERFORM zf_lgbst_wert_ergaenzen.
*EOC By Arnav on 18/08/26
  ENDIF. "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "hana_20120607_V1


*&=====================================================================*
*& UNIT 3b -  the new form                                              *
*&   Place    : main program, directly after                            *
*&              ENDFORM.  " SUMMEN_BILDEN         (approx. line 3923)   *
*&=====================================================================*

*BOC By Arnav on 18/08/26
*&---------------------------------------------------------------------*
*&      Form  ZF_LGBST_WERT_ERGAENZEN
*&---------------------------------------------------------------------*
*&      ZMB5B 195_BRD_FS
*&      Fill BESTAND-SOLLWERT (receipt amount), BESTAND-HABENWERT
*&      (issue amount) and BESTAND-WAERS for the radio button
*&      "Storage Loc./Batch Stock". The standard form
*&      BESTAENDE_BERECHNEN (include RM07MLBD_FORM_01) does this for
*&      the valuated stock (BWBST) only.
*&---------------------------------------------------------------------*
FORM zf_lgbst_wert_ergaenzen.

  CHECK : lgbst = 'X'.

  LOOP AT bestand.

*   total value of the goods receipts
    CLEAR                    gt_zwert_sum.

    READ TABLE gt_zwert_sum  WITH KEY
                             werks = bestand-werks
                             matnr = bestand-matnr
                             charg = bestand-charg
                             shkzg = 'S'
                             BINARY SEARCH.

    MOVE  gt_zwert_sum-dmbtr TO  bestand-sollwert.

*   total value of the goods issues
    CLEAR                    gt_zwert_sum.

    READ TABLE gt_zwert_sum  WITH KEY
                             werks = bestand-werks
                             matnr = bestand-matnr
                             charg = bestand-charg
                             shkzg = 'H'
                             BINARY SEARCH.

    MOVE  gt_zwert_sum-dmbtr TO  bestand-habenwert.

*   the currency key is taken from MBEW in mode valuated stock only,
*   so read it from the organisational data of the plant
    PERFORM  f9300_read_organ
                             USING  c_werks   bestand-werks.

    MOVE  g_s_organ-waers    TO  bestand-waers.

    MODIFY                   bestand.
  ENDLOOP.

ENDFORM.                     " zf_lgbst_wert_ergaenzen
*EOC By Arnav on 18/08/26


*&=====================================================================*
*& UNIT 4  -  field catalog of the flat totals list ("Totals only")     *
*&   Form     : create_fieldcat_totals_flat (main program, appr. l.2440)*
*&   Anchor   : the block  IF  bwbst = 'X'.  ... ENDIF.  (appr. l.2572) *
*&   TEXT-101 / TEXT-102 are the existing text symbols                  *
*&   "Total value of goods receipts" / "... goods issues" - no new text *
*&   elements are needed.                                               *
*&=====================================================================*

  IF  bwbst = 'X'.
*   process the values, too
    MOVE : TEXT-100          TO  g_s_fieldcat-seltext_l,   "opening value
           TEXT-100          TO  g_s_fieldcat-seltext_m,
           TEXT-100          TO  g_s_fieldcat-seltext_s,
           TEXT-100          TO  g_s_fieldcat-reptext_ddic,
           'L'               TO  g_s_fieldcat-ddictxt,
           23                TO  g_s_fieldcat-outputlen,
           'WAERS'           TO  g_s_fieldcat-cfieldname,
           7                 TO  g_s_fieldcat-intlen,
           'P'               TO  g_s_fieldcat-inttype,
           'CURR'            TO  g_s_fieldcat-datatype.
    PERFORM fc_s_flat USING 'ANFWERT' 'MSEG' 'DMBTR'.

    MOVE : TEXT-101          TO  g_s_fieldcat-seltext_l,  "sum GR values
           'L'               TO  g_s_fieldcat-ddictxt,
           23                TO  g_s_fieldcat-outputlen,
           'WAERS'           TO  g_s_fieldcat-cfieldname.
    PERFORM fc_s_flat USING 'SOLLWERT' 'MSEG' 'DMBTR'.

    MOVE : TEXT-102          TO  g_s_fieldcat-seltext_l,  "sum GI values
           'L'               TO  g_s_fieldcat-ddictxt,
           23                TO  g_s_fieldcat-outputlen,
           'WAERS'           TO  g_s_fieldcat-cfieldname.
    PERFORM fc_s_flat USING 'HABENWERT' 'MSEG' 'DMBTR'.

    MOVE : TEXT-103          TO  g_s_fieldcat-seltext_l,   "end value
           TEXT-103          TO  g_s_fieldcat-seltext_m,
           TEXT-103          TO  g_s_fieldcat-seltext_s,
           TEXT-103          TO  g_s_fieldcat-reptext_ddic,
           'L'               TO  g_s_fieldcat-ddictxt,
           23                TO  g_s_fieldcat-outputlen,
           'WAERS'           TO  g_s_fieldcat-cfieldname,
           7                 TO  g_s_fieldcat-intlen,
           'P'               TO  g_s_fieldcat-inttype,
           'CURR'            TO  g_s_fieldcat-datatype.
    PERFORM fc_s_flat USING 'ENDWERT' 'MSEG' 'DMBTR'.

    PERFORM fc_s_flat USING 'WAERS' 'T001' 'WAERS'.

*BOC By Arnav on 18/08/26
* ZMB5B 195_BRD_FS : receipt amount and issue amount for the radio
* button "Storage Loc./Batch Stock". The opening / closing value are
* not shown here - they are derived from the valuated stock (MBEW),
* which does not exist per storage location.
  ELSEIF  lgbst = 'X'.

    MOVE : TEXT-101          TO  g_s_fieldcat-seltext_l,  "sum GR values
           TEXT-101          TO  g_s_fieldcat-seltext_m,
           TEXT-101          TO  g_s_fieldcat-seltext_s,
           TEXT-101          TO  g_s_fieldcat-reptext_ddic,
           'L'               TO  g_s_fieldcat-ddictxt,
           23                TO  g_s_fieldcat-outputlen,
           'WAERS'           TO  g_s_fieldcat-cfieldname,
           7                 TO  g_s_fieldcat-intlen,
           'P'               TO  g_s_fieldcat-inttype,
           'CURR'            TO  g_s_fieldcat-datatype.
    PERFORM fc_s_flat USING 'SOLLWERT' 'MSEG' 'DMBTR'.

    MOVE : TEXT-102          TO  g_s_fieldcat-seltext_l,  "sum GI values
           TEXT-102          TO  g_s_fieldcat-seltext_m,
           TEXT-102          TO  g_s_fieldcat-seltext_s,
           TEXT-102          TO  g_s_fieldcat-reptext_ddic,
           'L'               TO  g_s_fieldcat-ddictxt,
           23                TO  g_s_fieldcat-outputlen,
           'WAERS'           TO  g_s_fieldcat-cfieldname,
           7                 TO  g_s_fieldcat-intlen,
           'P'               TO  g_s_fieldcat-inttype,
           'CURR'            TO  g_s_fieldcat-datatype.
    PERFORM fc_s_flat USING 'HABENWERT' 'MSEG' 'DMBTR'.

    PERFORM fc_s_flat USING 'WAERS' 'T001' 'WAERS'.
*EOC By Arnav on 18/08/26
  ENDIF.


*&=====================================================================*
*& UNIT 5  -  output table of the flat totals list                      *
*&   Form     : create_table_totals_flat (main program, appr. l.2341)   *
*&   Anchor   : the block  IF  bwbst = 'X'.  ... ENDIF. (appr. l.2374)  *
*&   The goods issue is shown with a negative sign, exactly like the    *
*&   quantity HABEN two lines above.                                    *
*&=====================================================================*

    IF  bwbst = 'X'.
      g_s_totals_flat-habenwert   = g_s_totals_flat-habenwert * -1.

      PERFORM  colorize_totals_flat   USING 'ANFWERT'.
      PERFORM  colorize_totals_flat   USING 'SOLLWERT'.
      PERFORM  colorize_totals_flat   USING 'HABENWERT'.
      PERFORM  colorize_totals_flat   USING 'ENDWERT'.
*BOC By Arnav on 18/08/26
* ZMB5B 195_BRD_FS : same sign handling and colours for the storage
* location view
    ELSEIF  lgbst = 'X'.
      g_s_totals_flat-habenwert   = g_s_totals_flat-habenwert * -1.

      PERFORM  colorize_totals_flat   USING 'SOLLWERT'.
      PERFORM  colorize_totals_flat   USING 'HABENWERT'.
*EOC By Arnav on 18/08/26
    ENDIF.


*&=====================================================================*
*& UNIT 6  -  hierarchical totals list ( checkbox "Totals with levels" )*
*&   Form     : create_table_totals_hq (main program, appr. l.2064)     *
*&   Anchors  : the two blocks "IF bwbst = 'X'." for the GR line        *
*&              (appr. l.2123) and for the GI line (appr. l.2140)       *
*&=====================================================================*

*   line with the good receipts
*BOC By Arnav on 18/08/26
*    IF  bwbst = 'X'.
    IF  bwbst = 'X'  OR  lgbst = 'X'.                 "ZMB5B 195_BRD_FS
*EOC By Arnav on 18/08/26
      MOVE : TEXT-030          TO  g_s_totals_item-stock_type+2,
             bestand-soll      TO  g_s_totals_item-menge,
             bestand-sollwert  TO  g_s_totals_item-wert.
    ELSE.
      MOVE : TEXT-005          TO  g_s_totals_item-stock_type+2,
             bestand-soll      TO  g_s_totals_item-menge.
    ENDIF.

*   line with the good issues
*BOC By Arnav on 18/08/26
*    IF  bwbst = 'X'.
    IF  bwbst = 'X'  OR  lgbst = 'X'.                 "ZMB5B 195_BRD_FS
*EOC By Arnav on 18/08/26
      MOVE : TEXT-031          TO  g_s_totals_item-stock_type+2.
      g_s_totals_item-menge    = bestand-haben      * -1.
      g_s_totals_item-wert     = bestand-habenwert  * -1.
    ELSE.
      MOVE : TEXT-006          TO  g_s_totals_item-stock_type+2.
      g_s_totals_item-menge    = bestand-haben      * -1.
    ENDIF.

*   ... and in FORM create_table_totals_hq_1 (appr. l.2209) so that the
*   value column is coloured in this view as well :
*BOC By Arnav on 18/08/26
*  IF  bwbst = 'X'.
  IF  bwbst = 'X'  OR  lgbst = 'X'.                   "ZMB5B 195_BRD_FS
*EOC By Arnav on 18/08/26
*   colorize the values


*&=====================================================================*
*& UNIT 7  -  header block of the standard (non "totals only") output   *
*&   Form     : create_alv_form_content_top (main program, appr. l.1770)*
*&   Without this unit the two amounts are visible in the totals lists  *
*&   only - the default MB5B output shows the receipts / issues in the  *
*&   header block above the document lines.                             *
*&                                                                      *
*&   G_OFFSET_VALUE and G_OFFSET_CURR are calculated in                 *
*&   FORM calculate_offsets for every radio button, so no change is     *
*&   needed there.                                                      *
*&=====================================================================*

* line : total quantity and value of goods receipts --------------------
  IF bwbst IS INITIAL.
*   total quantities of goods receipts
    MOVE : TEXT-005               TO  l_text+2.
    WRITE  g_s_bestand-soll       TO l_figure
                                  UNIT  g_s_bestand-meins.
    MOVE  l_figure                TO  l_text+g_offset_qty(24).
    MOVE  l_f_meins_external      TO  l_text+g_offset_unit. "n1018717
*   ... standard /CWM block unchanged ...
    ENHANCEMENT-POINT ehp605_rm07mlbd_02 SPOTS es_rm07mlbd .
*BOC By Arnav on 18/08/26
*   ZMB5B 195_BRD_FS : receipt amount for "Storage Loc./Batch Stock"
    IF  lgbst = 'X'.
      WRITE g_s_bestand-sollwert  TO l_figure
                                  CURRENCY  g_s_bestand-waers.
      MOVE  l_figure              TO  l_text+g_offset_value(24).
      MOVE  g_s_bestand-waers     TO  l_text+g_offset_curr.
    ENDIF.
*EOC By Arnav on 18/08/26
  ELSE.
*   ... standard valuated stock block unchanged ...
  ENDIF.

* line : total quantity and value of goods issues ----------------------
  IF bwbst IS INITIAL.
*   total quantities of goods issues
    MOVE : TEXT-006               TO  l_text+2.
    COMPUTE  g_s_bestand-haben    =  g_s_bestand-haben * -1.
    WRITE  g_s_bestand-haben      TO l_figure
                                  UNIT  g_s_bestand-meins.
    MOVE  l_figure                TO  l_text+g_offset_qty(24).
    MOVE  l_f_meins_external      TO  l_text+g_offset_unit. "n1018717
*   ... standard /CWM block unchanged ...
    ENHANCEMENT-POINT ehp605_rm07mlbd_04 SPOTS es_rm07mlbd .
*BOC By Arnav on 18/08/26
*   ZMB5B 195_BRD_FS : issue amount for "Storage Loc./Batch Stock"
    IF  lgbst = 'X'.
      COMPUTE g_s_bestand-habenwert = g_s_bestand-habenwert * -1.
      WRITE g_s_bestand-habenwert TO l_figure
                                  CURRENCY  g_s_bestand-waers.
      MOVE  l_figure              TO  l_text+g_offset_value(24).
      MOVE  g_s_bestand-waers     TO  l_text+g_offset_curr.
    ENDIF.
*EOC By Arnav on 18/08/26
  ELSE.
*   ... standard valuated stock block unchanged ...
  ENDIF.


*&=====================================================================*
*& UNIT TESTS                                                           *
*&=====================================================================*
*&  UT-01  ZMB5B, "Storage Loc./Batch Stock", checkbox "Totals only" :
*&         the columns "Total value of goods receipts" and "... goods
*&         issues" are filled, the issue value is negative, the currency
*&         key column shows the company code currency.
*&  UT-02  Cross-check one line : SUM( MSEG-DMBTR ) of that material /
*&         plant in the date range, split by MSEG-SHKZG ('S' = receipt,
*&         'H' = issue) - use MB51 or table MSEG/MATDOC. Values match.
*&  UT-03  Same run with checkbox "Batch" (XCHAR) : the values are
*&         summarised per batch.
*&  UT-04  Same run with checkbox "Totals with levels" (XSUM) : the two
*&         "value" lines are filled.
*&  UT-05  Default output (no "totals only") : the header block per
*&         material shows the two amounts next to the quantities.
*&  UT-06  Regression : "Valuated Stock" and "Special Stock" radio
*&         buttons behave exactly as before.
*&  UT-07  Regression : the detail list still shows the DMBTR column
*&         delivered with the first change unit.
*&=====================================================================*
