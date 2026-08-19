*--- MAIN PROGRAM: MZMMCONVINSSPRSNVSF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMCONVINSSPRSNVSF01                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  upd_resvitem_tbl
*&---------------------------------------------------------------------*
* To udate internal table ist_resvitem
*----------------------------------------------------------------------*
FORM upd_resvitem_tbl.
  DATA : ist_resvitem_t LIKE TABLE OF wa_resvitem.

  REFRESH :   ist_resvitem_b.

*  ist_resvitem_b[] = ist_resvitem[].

  LOOP AT ist_resvitem INTO wa_resvitem.

    SELECT maktx FROM makt INTO wa_resvitem-maktx UP TO 1 ROWS
 WHERE matnr = wa_resvitem-matnr
 ORDER BY PRIMARY KEY .
    ENDSELECT.

*    wa_resvitem-ps_psp_pnr = rkpf-ps_psp_pnr.

    wa_resvitem-bdmng = wa_resvitem-bdmng - wa_resvitem-enmng.

    wa_resvitem-lgort = wa_resvdtl-lgort.

    APPEND wa_resvitem TO ist_resvitem_b.

    APPEND wa_resvitem TO ist_resvitem_t.

    wa_resvitem-umlgo = wa_resvdtl-umlgo.

    CONCATENATE wa_resvitem-charg+0(2) TEXT-001 INTO wa_resvitem-charg_r.

    CONCATENATE TEXT-004 wa_resvitem-bwart+1(2) INTO wa_resvitem-bwart.

    CLEAR : wa_resvitem-lgort,
            wa_resvitem-charg.

    APPEND wa_resvitem TO ist_resvitem_t.
  ENDLOOP.

  ist_resvitem[]   = ist_resvitem_t[].
ENDFORM.                    " upd_resvitem_tbl

*&---------------------------------------------------------------------*
*&      Form  confirm_input
*&---------------------------------------------------------------------*
*  In case of cancel or exit ,Display warning message.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_input.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Alert '
      text_question         = TEXT-006
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      display_cancel_button = ''
      default_button        = '1'
    IMPORTING
      answer                = g_ans.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " confirm_input

*&---------------------------------------------------------------------*
*&      Form  trans_spares_mvstk
*&---------------------------------------------------------------------*
* To convert insurance spares to non valuated stock
*----------------------------------------------------------------------*
FORM trans_spares_mvstk.
  DATA : ist_goodsmvt_item  TYPE TABLE OF bapi2017_gm_item_create.

  DATA : wa_goodsmvt_header TYPE    bapi2017_gm_head_01,
         wa_goodsmvt_code   TYPE    bapi2017_gm_code,
         wa_goodsmvt_item   TYPE    bapi2017_gm_item_create.

  DATA : ist_return TYPE TABLE OF bapiret2,
         wa_return  TYPE bapiret2.

  DATA : l_rsnum TYPE resb-rsnum.

  DATA : l_ps_psp_pnr LIKE wa_goodsmvt_item-wbs_elem,
         l_asset_no   LIKE wa_goodsmvt_item-asset_no,
         l_asset_sub  LIKE wa_goodsmvt_item-sub_number.

  DATA : ist_mesg   TYPE esp1_message_tab_type WITH HEADER LINE.

  DATA : l_no1 TYPE sy-tabix,
         l_no2 TYPE sy-tabix.

  CLEAR : g_mat_doc_no,
          l_ps_psp_pnr,
          l_asset_no,
          l_rsnum.

  CLEAR : rkpf.

* - populate header
  wa_goodsmvt_header-pstng_date = gohead-budat.
  wa_goodsmvt_header-doc_date   = gohead-bldat.
  wa_goodsmvt_header-header_txt = TEXT-005.

* - populate code
  wa_goodsmvt_code-gm_code = '03'.

* - populate line items
  WRITE : wa_resvdtl-rsnum TO l_rsnum NO-ZERO.
  CONDENSE l_rsnum.

  SELECT SINGLE ps_psp_pnr anln1 anln2 FROM rkpf
             INTO (rkpf-ps_psp_pnr,rkpf-anln1,rkpf-anln2)
                    WHERE rsnum = wa_resvdtl-rsnum.

  MOVE rkpf-anln1 TO l_asset_no.
  MOVE rkpf-anln2 TO l_asset_sub.

  CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
    EXPORTING
      input  = rkpf-ps_psp_pnr
    IMPORTING
      output = l_ps_psp_pnr.

  LOOP AT ist_resvitem INTO wa_resvitem
                        WHERE chk = 'X'.

* Movement Type X21 or X41 etc
    IF wa_resvitem-charg_r IS INITIAL.
      wa_goodsmvt_item-material  = wa_resvitem-matnr.
      wa_goodsmvt_item-plant     = wa_resvitem-werks.
      wa_goodsmvt_item-stge_loc  = wa_resvitem-lgort.
      wa_goodsmvt_item-batch     = wa_resvitem-charg.
      wa_goodsmvt_item-move_type = wa_resvitem-bwart.
      wa_goodsmvt_item-wbs_elem  = l_ps_psp_pnr.
      wa_goodsmvt_item-asset_no  = l_asset_no.
      wa_goodsmvt_item-sub_number = l_asset_sub.
      wa_goodsmvt_item-entry_qnt = wa_resvitem-bdmng.
      wa_goodsmvt_item-entry_uom = wa_resvitem-meins.
      CONCATENATE TEXT-008 l_rsnum INTO
          wa_goodsmvt_item-item_text.

      APPEND wa_goodsmvt_item TO ist_goodsmvt_item.
    ELSE.
* Movement Type Y21 or Y41 etc
      wa_goodsmvt_item-material   = wa_resvitem-matnr.
      wa_goodsmvt_item-plant      = wa_resvitem-werks.
      wa_goodsmvt_item-stge_loc   = wa_resvitem-umlgo.
      wa_goodsmvt_item-batch      = wa_resvitem-charg_r.
      wa_goodsmvt_item-move_type  = wa_resvitem-bwart.
      wa_goodsmvt_item-wbs_elem   = l_ps_psp_pnr.
      wa_goodsmvt_item-asset_no   = l_asset_no.
      wa_goodsmvt_item-sub_number = l_asset_sub.
      wa_goodsmvt_item-entry_qnt  = wa_resvitem-bdmng.
      wa_goodsmvt_item-entry_uom  = wa_resvitem-meins.

      CONCATENATE TEXT-008 l_rsnum INTO
          wa_goodsmvt_item-item_text.

      APPEND wa_goodsmvt_item TO ist_goodsmvt_item.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE ist_resvitem  LINES l_no1.
  DESCRIBE TABLE ist_goodsmvt_item LINES l_no2.

*  if not ist_goodsmvt_item[] is initial.
  IF l_no1 = l_no2.
    "Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE' "#EC CI_USAGE_OK[2438131]
      EXPORTING
        goodsmvt_header  = wa_goodsmvt_header
        goodsmvt_code    = wa_goodsmvt_code
      IMPORTING
        materialdocument = g_mat_doc_no
      TABLES
        goodsmvt_item    = ist_goodsmvt_item
        return           = ist_return.
    "Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC

    IF ist_return[] IS INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = wa_return.

      IF wa_return IS INITIAL.
        PERFORM upd_resveration_dtl USING wa_resvdtl-rsnum
                                           g_mat_doc_no.

        MESSAGE i395(zmm) WITH g_mat_doc_no.

        MESSAGE s379(zmm) WITH g_mat_doc_no.

        CLEAR : save_ok,
                g_ok_code.

        LEAVE TO SCREEN 100.
      ELSE.
        MESSAGE i396(zmm).
      ENDIF.
    ELSE.
      LOOP AT ist_return INTO wa_return.
        MOVE wa_return-type   TO ist_mesg-msgty.
        MOVE wa_return-id     TO ist_mesg-msgid.
        MOVE wa_return-number TO ist_mesg-msgno.

        APPEND ist_mesg.
      ENDLOOP.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          i_message_tab = ist_mesg.

*      message e378(zmm).
    ENDIF.
  ELSE.
    MESSAGE i376(zmm).
  ENDIF.
ENDFORM.                    " trans_spares_mvstk

*&---------------------------------------------------------------------*
*&      Form  chk_stk_val
*&---------------------------------------------------------------------*
* To check stock value of material - for plant & storage location
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_stk_val.
  DATA : l_chk(1).

  LOOP AT ist_resvitem_b INTO wa_resvitem_b.
    SELECT SINGLE * FROM mard
      WHERE matnr = wa_resvitem_b-matnr AND
            werks = wa_resvitem_b-werks AND
            lgort = wa_resvitem_b-lgort.

    IF wa_resvitem_b-bdmng > mard-labst.
      MESSAGE e181(m7) WITH sy-datum mard-labst ''.
    ENDIF.
  ENDLOOP.

  CLEAR : l_chk.

  LOOP AT ist_resvitem INTO wa_resvitem.
    IF wa_resvitem-chk <> 'X'.
      l_chk = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF l_chk = 'X'.
    MESSAGE i376(zmm).
  ELSE.
    MESSAGE s026(migo).
  ENDIF.

  CLEAR : wa_resvitem_b,
          wa_resvitem.
ENDFORM.                    " chk_stk_val

*&---------------------------------------------------------------------*
*&      Form  upd_resveration_dtl
*&---------------------------------------------------------------------*
* To Update (set) deletion flag ,final issue flag & Item text in the
* reservation document using BDC by calling tr. code MB22
*----------------------------------------------------------------------*
*      -->p_rsnum         Reservation No.
*      -->p_mat_doc_no    Material Document No.
*----------------------------------------------------------------------*
FORM upd_resveration_dtl USING    p_rsnum
                                  p_mat_doc_no.
  DATA : BEGIN OF wa_resb,
           rsnum TYPE resb-rsnum,
           rspos TYPE resb-rspos,
           lgort TYPE resb-lgort,
           charg TYPE resb-charg,
*        erfmg  type resb-erfmg,
           bdter TYPE resb-bdter,
           kzear TYPE resb-kzear,
           xwaok TYPE resb-xwaok,
           xloek TYPE resb-xloek,
         END OF wa_resb.

  DATA : ist_resb LIKE TABLE OF wa_resb.

  DATA : l_sgtxt TYPE resb-sgtxt.

  DATA : l_date  TYPE resb-bdter.

  DATA : l_cnt   TYPE sy-tabix.

  SELECT rsnum rspos lgort charg bdter kzear xwaok xloek
      INTO TABLE ist_resb FROM resb
          WHERE rsnum = p_rsnum
            AND bwart = wa_resvdtl-bwart ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.

    READ TABLE ist_resb INTO wa_resb INDEX 1.

    DESCRIBE TABLE ist_resb LINES l_cnt.

    PERFORM bdc_dynpro      USING 'SAPMM07R' '0560'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RM07M-RSNUM'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RM07M-RSNUM'
                                   wa_resb-rsnum.
    PERFORM bdc_field       USING 'RM07M-RSPOS'
                                   ''.
    PERFORM bdc_field       USING 'XFULL'
                                  'X'.

    PERFORM bdc_dynpro      USING 'SAPMM07R' '0521'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RESB-ERFMG(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=PF02'.
    PERFORM bdc_field       USING 'DKACB-FMORE'
                                  'X'.
    CONCATENATE TEXT-007 p_mat_doc_no INTO l_sgtxt SEPARATED BY space.

    l_cnt = l_cnt - 1.

    LOOP AT ist_resb INTO wa_resb.

      IF sy-tabix <= l_cnt.

        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.

        IF wa_resvdtl-bwart = 'X21'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'COBL-PS_POSID'.
        ELSE.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'COBL-ANLN1'.
        ENDIF.

        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTE'.
        PERFORM bdc_dynpro      USING 'SAPMM07R' '0510'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RESB-SGTXT'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=KPN'.
        IF wa_resb-xloek <> 'X'.

          PERFORM bdc_field       USING 'RESB-CHARG'
                                         wa_resb-charg.
*        perform bdc_field       using 'RESB-ERFMG'
*                                       wa_resb-erfmg.

          WRITE wa_resb-bdter   TO l_date DD/MM/YY .

          PERFORM bdc_field       USING 'RESB-BDTER'
                                        l_date.
          PERFORM bdc_field       USING 'RESB-KZEAR'
                                        'X'.
          PERFORM bdc_field       USING 'RESB-XWAOK'
                                         wa_resb-xwaok.
          PERFORM bdc_field       USING 'RESB-XLOEK'
                                        'X'.

          PERFORM bdc_field       USING 'RESB-SGTXT'
                                         l_sgtxt.
          PERFORM bdc_field       USING 'DKACB-FMORE'
                                       'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    l_cnt = l_cnt + 1.

    READ TABLE ist_resb INTO wa_resb INDEX l_cnt.

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.

    IF wa_resvdtl-bwart = 'X21'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-PS_POSID'.
    ELSE.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-ANLN1'.
    ENDIF.

    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTE'.
    PERFORM bdc_dynpro      USING 'SAPMM07R' '0510'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RESB-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BU'.
    IF wa_resb-xloek <> 'X'.

      PERFORM bdc_field       USING 'RESB-CHARG'
                                     wa_resb-charg.
*    perform bdc_field       using 'RESB-ERFMG'
*                                   wa_resb-erfmg.

      WRITE wa_resb-bdter   TO l_date DD/MM/YY .

      PERFORM bdc_field       USING 'RESB-BDTER'
                                     l_date.
      PERFORM bdc_field       USING 'RESB-KZEAR'
                                    'X'.
      PERFORM bdc_field       USING 'RESB-XWAOK'
                                     wa_resb-xwaok.
      PERFORM bdc_field       USING 'RESB-XLOEK'
                                    'X'.

      PERFORM bdc_field       USING 'RESB-SGTXT'
                                     l_sgtxt.
      PERFORM bdc_field       USING 'DKACB-FMORE'
                                     'X'.
    ENDIF.

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.

    IF wa_resvdtl-bwart = 'X21'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-PS_POSID'.
    ELSE.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-ANLN1'.
    ENDIF.

    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTE'.
    CALL TRANSACTION 'MB22' USING      ist_bdcdata
                                       MODE 'E'
                                       UPDATE 'S'
                             MESSAGES INTO ist_msg .
  ENDIF.

ENDFORM.                    " upd_resveration_dtl

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       BDC DYNPRO
*----------------------------------------------------------------------*
*      -->P_0487   text
*      -->P_0488   text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING l_program l_dynpro.
  CLEAR ist_bdcdata.
  ist_bdcdata-program  = l_program.
  ist_bdcdata-dynpro   = l_dynpro.
  ist_bdcdata-dynbegin = 'X'.
  APPEND ist_bdcdata.
ENDFORM.                    " bdc_dynpro

*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       BDC FIELD
*----------------------------------------------------------------------*
*      -->P_0501   text
*      -->P_0502   text
*----------------------------------------------------------------------*
FORM bdc_field USING l_fnam l_fval.

  CLEAR ist_bdcdata.
  ist_bdcdata-fnam = l_fnam.
  ist_bdcdata-fval = l_fval.
  APPEND ist_bdcdata.
ENDFORM.                    " bdc_field

*&---------------------------------------------------------------------*
*&      Form  select_all_entries
*&---------------------------------------------------------------------*
*   To select the row in table control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all_entries.
  LOOP AT ist_resvitem INTO wa_resvitem.
    wa_resvitem-chk = 'X'.
    MODIFY ist_resvitem FROM wa_resvitem INDEX sy-tabix.
  ENDLOOP.

  CLEAR :wa_resvitem.
ENDFORM.                    " select_all_entries
*&---------------------------------------------------------------------*
*&      Form  deselect_all_entries
*&---------------------------------------------------------------------*
*  To deselect the row in table control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_all_entries.
  LOOP AT ist_resvitem INTO wa_resvitem.
    wa_resvitem-chk = ' '.
    MODIFY ist_resvitem FROM wa_resvitem INDEX sy-tabix.
  ENDLOOP.

  CLEAR :wa_resvitem.
ENDFORM.                    " deselect_all_entries

*&---------------------------------------------------------------------*
*&      Form  get_resb_data
*&---------------------------------------------------------------------*
* To fetch reservation details
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_resb_data.
  REFRESH : ist_resvitem.
  CLEAR   : wa_resvitem.

  SELECT * FROM resb INTO TABLE ist_resb
  "corresponding fields of table ist_resvitem
                 WHERE rsnum = wa_resvdtl-rsnum ORDER BY PRIMARY KEY.  " and
*                       bwart = wa_resvdtl-bwart. " and
*                       lgort = wa_resvdtl-lgort and
*                        kzear <> 'X'            and
*                        xloek <> 'X'.


  IF sy-subrc <> 0.
    MESSAGE e667(zmm).
  ELSE.

    PERFORM chk_rsnum.

    READ TABLE ist_resb INDEX 1.

    IF ist_resb-kzear = 'X' AND
        ist_resb-xloek = 'X'.
      MESSAGE e377(zmm) WITH wa_resvdtl-rsnum.
    ELSE.
      LOOP AT ist_resb.
        MOVE-CORRESPONDING ist_resb TO wa_resvitem.
        APPEND wa_resvitem TO ist_resvitem.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_resb_data

*&---------------------------------------------------------------------*
*&      Form  chk_rsnum
*&---------------------------------------------------------------------*
* To Validate reservation number
*             - Validation for Valuation Type
*             - Validation on subasset number
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_rsnum.
  DATA : ist_mesg   TYPE esp1_message_tab_type WITH HEADER LINE.
  DATA : l_charg TYPE resb-charg.
  DATA : l_found(1),
         l_no TYPE sy-tabix.


*Validation on subasset number
  CLEAR : rkpf.

  SELECT SINGLE * FROM rkpf
    WHERE rsnum = wa_resvdtl-rsnum.

  MOVE rkpf-bwart TO wa_resvdtl-bwart.

  IF NOT ( wa_resvdtl-bwart = 'X21' OR
               wa_resvdtl-bwart = 'X41' ).
    MESSAGE e368(zmm).
  ENDIF.

  READ TABLE ist_resb INDEX 1.

  IF NOT ist_resb-lgort IS INITIAL.
    MOVE ist_resb-lgort TO wa_resvdtl-lgort.
  ENDIF.

  IF wa_resvdtl-bwart = 'X41'.
    IF  ( rkpf-anln2 IS INITIAL OR
          rkpf-anln2 = '0000' ).
      MESSAGE e393(zmm) WITH rkpf-anln1 wa_resvdtl-rsnum.
    ELSE.
      SELECT SINGLE * FROM anla
         WHERE anln1 = rkpf-anln1
           AND anln2 = rkpf-anln2
           AND ord43 = 'STDB'.                 "Asset standby

      IF sy-subrc <> 0.
        MESSAGE e394(zmm)." with rkpf-anln1.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : l_found,
          l_no.

*Validation for Valuation Type
  LOOP AT ist_resb.
    CLEAR : l_charg.

    CONCATENATE ist_resb-charg+0(2) TEXT-001 INTO l_charg.

    SELECT SINGLE * FROM mbew
        WHERE matnr = ist_resb-matnr
          AND bwkey = ist_resb-werks
          AND bwtar = l_charg.

    IF sy-subrc <> 0.
      l_found = '0'.
      l_no = l_no + 1.

      MOVE 'E'            TO ist_mesg-msgty.
      MOVE 'ZMM'          TO ist_mesg-msgid.
      MOVE '392'          TO ist_mesg-msgno.
      MOVE l_charg        TO ist_mesg-msgv1.
      MOVE ist_resb-matnr TO ist_mesg-msgv2.
      MOVE ist_resb-werks TO ist_mesg-msgv3.
      MOVE l_no           TO ist_mesg-lineno.

      APPEND ist_mesg.
    ENDIF.
  ENDLOOP.

  IF l_found = '0'.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = ist_mesg.

    READ TABLE ist_mesg INDEX 1.

    MESSAGE e392(zmm) WITH ist_mesg-msgv1 ist_mesg-msgv2 ist_mesg-msgv3.
  ENDIF.
ENDFORM.                    " chk_rsnum
