*--- MAIN PROGRAM: MZMMINWARDREGISTER_ARCHF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMINWARDREGISTERF01                                      *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 12/09/2008      <RD1K960036>    SAB_SUMODH
*
*
*  1) Variable size changed in line 145.
************************************************************************


*&---------------------------------------------------------------------*
*&      Form  get_serialno
*&---------------------------------------------------------------------*
*& To get next available serial no.
*----------------------------------------------------------------------*
FORM get_serialno.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZMM_INWARD'
      quantity                = '1'
    IMPORTING
      number                  = zmm_inwardhd-inwno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " get_serialno

*&---------------------------------------------------------------------*
*&      Form  lock_record
*&---------------------------------------------------------------------*
*& Lock a record for insertion / change .
*----------------------------------------------------------------------*
FORM lock_record.

  CALL FUNCTION 'ENQUEUE_EZ_ZMM_INWARDHD'
    EXPORTING
      mandt          = sy-mandt
      inwno          = zmm_inwardhd-inwno
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " lock_record

*&---------------------------------------------------------------------*
*&      Form  SET_TIMESTAMP
*&---------------------------------------------------------------------*
*& Get current Date & Time values
*----------------------------------------------------------------------*
*      -->l_TIMESTAMP  Time Stamp value
*----------------------------------------------------------------------*
FORM set_timestamp USING l_timestamp.

  DATA  l_tstamp LIKE oifbbp1-ftmstm.

  CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
    EXPORTING
      i_datum           = sy-datum
      i_time            = sy-uzeit
    IMPORTING
      e_timestamp       = l_tstamp
    EXCEPTIONS
      date_not_received = 1
      time_not_received = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    l_timestamp  =  l_tstamp.
  ENDIF.

ENDFORM.                    " SET_TIMESTAMP

*&---------------------------------------------------------------------*
*&      Form  Unlock_record
*&---------------------------------------------------------------------*
*& To unlock the locked record
*----------------------------------------------------------------------*
FORM unlock_record.

  CALL FUNCTION 'DEQUEUE_EZ_ZMM_INWARDHD'
    EXPORTING
      mandt = sy-mandt
      inwno = zmm_inwardhd-inwno.
  IF sy-subrc = 0 .
*
  ENDIF .
ENDFORM.                    " Unlock_record

*&---------------------------------------------------------------------*
*&      Form  CLEAR_DATA
*&---------------------------------------------------------------------*
*& Initialise screen values
*----------------------------------------------------------------------*
FORM clear_data.

  CLEAR: zmm_inwardhd-inwno,
         zmm_inwardhd-inwdt,
         zmm_inwardhd-ebeln,
         zmm_inwardhd-rcnno,
         zmm_inwardhd-cfloc,
         zmm_location-locds,
         zmm_cnfrcnhd-rcndt,
         zmm_cnfrcnhd-ebeln,
         ekko-aedat,
         ekko-lifnr,
         ekko-reswk,
         t001w-name1,
         L_EBELN_OLD,
         lfa1-name1.
*        g_ok_code.
*        sy-ucomm.

ENDFORM.                    " CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  DISP_CFLOC
*&---------------------------------------------------------------------*
*& To Display F4 help for CF Loction(s).
*----------------------------------------------------------------------*
FORM disp_cfloc.

  DATA: l_choice LIKE sy-tabix,
" Begin of <RD1K960036>.
*        l_msg(50).
        l_msg(80).
  " End of <RD1K960036>.

  DATA: BEGIN OF ist_locn OCCURS 0,
         loccd LIKE zmm_location-loccd,
         sp(1),
         locds LIKE zmm_location-locds,
  END OF ist_locn.

  REFRESH ist_locn.

  SELECT loccd locds INTO CORRESPONDING FIELDS OF TABLE ist_locn
    FROM zmm_location.

  MESSAGE i022(zmm) INTO l_msg.

  IF NOT ist_locn[] IS INITIAL.
    CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
      EXPORTING
        endpos_col   = 85
        endpos_row   = 22
        startpos_col = 60
        startpos_row = 03
        titletext    = l_msg
      IMPORTING
        choise       = l_choice
      TABLES
        valuetab     = ist_locn
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF NOT l_choice IS INITIAL.
        READ TABLE ist_locn INDEX l_choice.
        IF sy-subrc EQ 0.
          zmm_inwardhd-cfloc = ist_locn-loccd.
        ENDIF.
      ENDIF.
    ENDIF.

    REFRESH ist_locn.
  ENDIF.

ENDFORM.                    " DISP_CFLOC

*&---------------------------------------------------------------------*
*&      Form  DISP_RCNNO
*&---------------------------------------------------------------------*
*& To Display F4 help for RCN No(s).
*----------------------------------------------------------------------*
FORM disp_rcnno.

  DATA: l_choice LIKE sy-tabix,
        l_msg(80).

  DATA: BEGIN OF ist_rcnno OCCURS 0,
         rcnno LIKE zmm_cnfrcnhd-rcnno,
         space(1),
         rcndt like zmm_cnfrcnhd-rcndt,
  END OF ist_rcnno.

  REFRESH ist_rcnno.

  SELECT rcnno rcndt INTO CORRESPONDING FIELDS OF TABLE ist_rcnno
    FROM zmm_cnfrcnhd.

  MESSAGE i022(zmm) INTO l_msg.

  IF NOT ist_rcnno[] IS INITIAL.
    CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
      EXPORTING
        endpos_col   = 85
        endpos_row   = 22
        startpos_col = 60
        startpos_row = 03
        titletext    = l_msg
      IMPORTING
        choise       = l_choice
      TABLES
        valuetab     = ist_rcnno
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF NOT l_choice IS INITIAL.
        READ TABLE ist_rcnno INDEX l_choice.
        IF sy-subrc EQ 0.
          zmm_inwardhd-rcnno = ist_rcnno-rcnno.
        ENDIF.
      ENDIF.
    ENDIF.

    REFRESH ist_rcnno.
  ENDIF.

ENDFORM.                    " DISP_RCNNO

*&---------------------------------------------------------------------*
*&      Form  disp_inwno
*&---------------------------------------------------------------------*
*& To Display F4 help for Inward No(s).
*----------------------------------------------------------------------*
FORM disp_inwno.

  DATA: l_choice LIKE sy-tabix,
        l_msg(80).

  DATA: BEGIN OF ist_inwno OCCURS 0,
         inwno LIKE zmm_inwardhd-inwno,
         sp(1),
         inwdt LIKE zmm_inwardhd-inwdt,
         sp1(1),
         cfloc LIKE zmm_inwardhd-cfloc,
  END OF ist_inwno.

  REFRESH ist_inwno.

  SELECT inwno inwdt cfloc INTO CORRESPONDING FIELDS OF TABLE ist_inwno
    FROM zmm_inwardhd.

  MESSAGE i022(zmm) INTO l_msg.

  IF NOT ist_inwno[] IS INITIAL.
    CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
      EXPORTING
        endpos_col   = 85
        endpos_row   = 22
        startpos_col = 60
        startpos_row = 03
        titletext    = l_msg
      IMPORTING
        choise       = l_choice
      TABLES
        valuetab     = ist_inwno
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF NOT l_choice IS INITIAL.
        READ TABLE ist_inwno INDEX l_choice.
        IF sy-subrc EQ 0.
          zmm_inwardhd-inwno = ist_inwno-inwno.
        ENDIF.
      ELSE.
        MESSAGE e024.
      ENDIF.
    ENDIF.

    REFRESH ist_inwno.
  ENDIF.

ENDFORM.                    " disp_inwno

*&---------------------------------------------------------------------*
*&      Form  delete_data
*&---------------------------------------------------------------------*
*& To delete entries from ZMM_INWARDHD & ZMM_INWARDDT tables
*----------------------------------------------------------------------*
FORM delete_data.

  DATA: l_yesno(1),
        l_txt10(40),
        l_txt11(40),
        l_txt12(40).

  IF sy-ucomm  EQ 'DELETE'.
    MESSAGE i067(zfi) INTO l_txt10.
    MESSAGE i068(zfi) INTO l_txt11.
    MESSAGE i013(zmm) INTO l_txt12.

    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        defaultoption = 'N'
        textline1     = l_txt10
        textline2     = l_txt11
        titel         = l_txt12
        start_column  = 25
        start_row     = 6
      IMPORTING
        answer        = l_yesno.

    IF l_yesno = 'J'.
      REFRESH ist_inwardhd1.
      REFRESH ist_inwarddt1.
      CALL FUNCTION 'Z_UPDATE_ZMM_INWARDHD' IN UPDATE TASK
        EXPORTING
          l_mode     = '3'  "Delete mode
          l_inwno    = zmm_inwardhd-inwno
        TABLES
          l_inwardhd = ist_inwardhd1.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'Z_UPDATE_ZMM_INWARDDT' IN UPDATE TASK
          EXPORTING
            l_mode     = '3'  "Delete mode
            l_rcnno    = zmm_inwardhd-rcnno
          TABLES
            l_inwarddt = ist_inwarddt1.

        IF sy-subrc EQ 0.
          COMMIT WORK.
          PERFORM unlock_record.
          MESSAGE i015 WITH zmm_inwardhd-inwno.
        ELSE.
          ROLLBACK WORK.
          MESSAGE e016 WITH zmm_inwardhd-inwno.
        ENDIF.
      ELSE.
        ROLLBACK WORK.
        PERFORM unlock_record.
        MESSAGE e016 WITH zmm_inwardhd-inwno.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " delete_data

*&---------------------------------------------------------------------*
*&      Form  menu_navigate
*&---------------------------------------------------------------------*
*& For menu navigation trap
*----------------------------------------------------------------------*
FORM menu_navigate.

  IF sy-ucomm = 'G_CREA'.
    g_crea = 'X'.
    g_disp = ' '.
    g_chan = ' '.
    g_dele = ' '.
    g_flg  = 'Y'.
    g_mode = 'Create'.
  ELSEIF sy-ucomm = 'G_CHAN'.
    g_crea = ' '.
    g_disp = ' '.
    g_chan = 'X'.
    g_dele = ' '.
    g_flg  = ' '.
    g_mode = 'Change'.
  ELSEIF sy-ucomm = 'G_DISP'.
    g_crea = ' '.
    g_disp = 'X'.
    g_chan = ' '.
    g_dele = ' '.
    g_flg  = ' '.
    g_mode = 'Display'.
  ELSEIF sy-ucomm = 'G_DELE'.
    g_crea = ' '.
    g_disp = ' '.
    g_chan = ' '.
    g_dele = 'X'.
    g_flg  = ' '.
    g_mode = 'Delete'.
  ENDIF.

  g_flg = 'Y'.
  g_disp = 'X'.
  g_crea = ''.

  CASE 'X'.
    WHEN g_crea.
      REFRESH ist_inwardhd1.
      REFRESH ist_inwarddt.
      CALL SCREEN 9010.
    WHEN g_chan.
      REFRESH ist_inwardhd1.
      REFRESH ist_inwarddt.
      CALL SCREEN 9020.
    WHEN g_disp.
      REFRESH ist_inwardhd1.
      REFRESH ist_inwarddt.
      CALL SCREEN 9020.
    WHEN g_dele.
      REFRESH ist_inwardhd1.
      REFRESH ist_inwarddt.
      CALL SCREEN 9020.
  ENDCASE.

  sy-ucomm = 'INW'.

ENDFORM.                    " menu_naviagate
*&---------------------------------------------------------------------*
*&      Form  indelno-para
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM indelno-para.
*Inserted on 14.07.2003 as suggested by Parjinder

  IF NOT ist_inwarddt-indelno IS INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ist_inwarddt-indelno
      IMPORTING
        output = ist_inwarddt-indelno.

    SELECT SINGLE * FROM likp
      WHERE vbeln = ist_inwarddt-indelno.
    IF sy-subrc EQ 0.
*        break cab_subodhk.
*        Select single * into wa_lips from lips
*            where vbeln = ist_inwarddt-indelno
*            and   vgbel = zmm_cnfrcnhd-ebeln.
*        if sy-subrc = 0.
      MOVE: likp-lfdat TO ist_inwarddt-lfdat,
            likp-traid TO ist_inwarddt-traid.
*         else.
*           message e122(zmm) with ist_inwarddt-indelno.
*
*        endif.
*********Inserted else part of sy-subrc on 05.08.2003 ****
    ELSE.
      message e122(zmm) with ist_inwarddt-indelno.
**********************************************************
    ENDIF.
     SHIFT ist_inwarddt-indelno LEFT DELETING LEADING '0'.
  ENDIF.
*End of Insertion 14.07.2003

ENDFORM.                    " indelno-para
*&---------------------------------------------------------------------*
*&      Form  get-othdet
*&---------------------------------------------------------------------*
*       To get the header information in case of RCN ( not PO ), mode  *
*       change/display -- Subodh.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get-othdet.
  Select single * from zmm_cnfrcnhd
         where rcnno = zmm_inwardhd-rcnno.
  if sy-subrc = 0.
    SELECT SINGLE * FROM ekko WHERE
      ebeln = zmm_cnfrcnhd-ebeln.
    IF sy-subrc NE 0.
      MESSAGE e018 WITH zmm_inwardhd-rcnno.
    ELSE.
      ekko-aedat = ''.
      ekko-lifnr = ekko-lifnr.
*              ekko-reswk = ekko-reswk.
      SELECT SINGLE * FROM lfa1 WHERE lifnr = ekko-lifnr.
      IF sy-subrc EQ 0.
        lfa1-name1 = lfa1-name1.
      ENDIF.
    ENDIF.
  else.
    MESSAGE e019 WITH zmm_inwardhd-rcnno.
  endif.
  zmm_cnfrcnhd-ebeln = zmm_cnfrcnhd-ebeln.

ENDFORM.                    " get-othdet
*&---------------------------------------------------------------------*
*&      Form  GET_DLY_FROM_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DLY_FROM_PO .
* break cab_sudhir.
  DATA : ist_return_tab_doc  LIKE STANDARD TABLE OF ddshretval
                                         WITH  HEADER LINE.

  DATA : ist_field_tab_doc LIKE STANDARD TABLE OF dfies
                                         WITH  HEADER LINE.

  DATA : ist_dynpfld_mapping_doc LIKE STANDARD TABLE OF dselc
                                         WITH  HEADER LINE.
  DATA : dyfields_1  LIKE dynpread OCCURS 1 WITH HEADER LINE.

  DATA : BEGIN OF wa_object_doc,
           xblnr like ekes-xblnr,
           vbeln like ekes-vbeln,
         END OF wa_object_doc.

  DATA : ist_object_f4_doc LIKE STANDARD TABLE OF wa_object_doc INITIAL
                                                       SIZE 100.

  REFRESH : ist_object_f4_doc,ist_return_tab_doc.

  dyfields_1-fieldname = 'ZMM_INWARDHD-EBELN'.

  APPEND dyfields_1.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dyfields_1.

  READ TABLE dyfields_1 INDEX 1.

  MOVE dyfields_1-fieldvalue TO ZMM_INWARDHD-EBELN.


  SELECT vbeln xblnr INTO CORRESPONDING FIELDS OF TABLE ist_object_f4_doc
  FROM ekes where ebeln = ZMM_INWARDHD-EBELN.

  SORT ist_object_f4_doc BY vbeln xblnr.

  DELETE ADJACENT DUPLICATES FROM ist_object_f4_doc.

  REFRESH : ist_dynpfld_mapping_doc.

  ist_dynpfld_mapping_doc-fldname   = 'F0001'.
  ist_dynpfld_mapping_doc-dyfldname = 'IST_INWARDDT-INDELNO'.
  APPEND ist_dynpfld_mapping_doc.

  CLEAR : ist_dynpfld_mapping_doc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FIELD'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'IST_INWARDDT-INDELNO'
      value_org       = 'S'
    TABLES
      value_tab       = ist_object_f4_doc
      field_tab       = ist_field_tab_doc
      return_tab      = ist_return_tab_doc
      dynpfld_mapping = ist_dynpfld_mapping_doc
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  IST_INWARDDT-INDELNO =  ist_return_tab_doc-fieldval.


ENDFORM.                    " GET_DLY_FROM_PO
*&---------------------------------------------------------------------*
*&      Module  CHECK_DATE_AMT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATE_AMT INPUT.

  if not IST_INWARDDT-LADNO is initial.
    loop at screen.
      if screen-name = 'IST_INWARDDT-LADDT' OR
         screen-name = 'IST_INWARDDT-LADCUR' OR
         screen-name = 'IST_INWARDDT-LADAMT'.
        screen-required = 1.
        modify screen.
      endif.
    endloop.
  ELSE.
    loop at screen.
      if screen-name = 'IST_INWARDDT-LADDT' OR
         screen-name = 'IST_INWARDDT-LADCUR' OR
         screen-name = 'IST_INWARDDT-LADAMT'.
        screen-required = 0.
        modify screen.
      endif.
    endloop.
  ENDIF.
ENDMODULE.                 " CHECK_DATE_AMT  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LRBEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LRBEN INPUT.

  if
       ist_inwarddt-lrben is initial or
       ist_inwarddt-lrdat is initial or
       ist_inwarddt-docty is initial or
       ist_inwarddt-packs is initial or
       ist_inwarddt-packr is initial or
       ist_inwarddt-itemsrecd is initial.

      loop at screen.
        if screen-name = 'IST_INWARDDT-LRBEN'     OR
           screen-name = 'IST_INWARDDT-LRDAT'     OR
           screen-name = 'IST_INWARDDT-DOCTY'     OR
           screen-name = 'IST_INWARDDT-PACKS'     OR
           screen-name = 'IST_INWARDDT-PACKR'     OR
           screen-name = 'IST_INWARDDT-ITEMSRECD'.
             screen-INPUT = 1.
             screen-required = 1.

             IF ist_inwarddt-lrben is initial  .
                 set CURSOR FIELD 'IST_INWARDDT-LRBEN' LINE disprec-current_line.
               ELSEIF  ist_inwarddt-lrdat is initial .
                 set CURSOR FIELD 'IST_INWARDDT-LRDAT' LINE disprec-current_line.
               ELSEIF ist_inwarddt-docty is initial.
                 set CURSOR FIELD 'IST_INWARDDT-DOCTY' LINE disprec-current_line.
               ELSEIF ist_inwarddt-packr is initial.
                  set CURSOR FIELD 'IST_INWARDDT-PACKR' LINE disprec-current_line.
               ELSEIF ist_inwarddt-packs is initial.
                 set CURSOR FIELD 'IST_INWARDDT-PACKS' LINE disprec-current_line.
               ELSEIF ist_inwarddt-itemsrecd is initial.
                 set CURSOR FIELD 'IST_INWARDDT-ITEMSRECD' LINE disprec-current_line.
             ENDIF.

             modify screen.

             MESSAGE e994(zmm).
        endif.
      endloop.

    endif.
ENDMODULE.                 " CHECK_LRBEN  INPUT
*&---------------------------------------------------------------------*
*&      Form  MM_EKKO_RET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MM_EKKO_RET .
  RANGES  : r_ebeln FOR ekko-ebeln.
  REFRESH :g_t_frange ,g_t_all_fields ,g_t_aind_str1_ais,l_t_as_key.
  CLEAR :g_s_aind_str1_ais,g_s_all_fields,g_s_frange,g_s_as_key.

  SELECT aind_str1~archindex aind_str1~itype aind_str1~skey
    INTO TABLE g_t_aind_str1_ais
    FROM aind_str1 JOIN aind_str2 ON aind_str1~archindex = aind_str2~archindex
    WHERE itype  = 'I'
      AND object = 'MM_EKKO'
      AND active = 'X'.

  READ TABLE g_t_aind_str1_ais INTO g_s_aind_str1_ais INDEX 2.
  IF sy-subrc NE 0.
    MESSAGE 'No Active Info Structure Found !' TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'AS_API_INFOSTRUC_FIND'
    EXPORTING
      i_fieldcat         = g_s_aind_str1_ais-skey
    IMPORTING
      e_all_fields       = g_t_all_fields
    EXCEPTIONS
      no_infostruc_found = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. MESSAGE 'No Info Structure Found !'           TYPE 'E'.
      WHEN 2. MESSAGE 'Info Structure Find - Error Other !' TYPE 'E'.
    ENDCASE.
  ENDIF.
  SORT g_t_all_fields.

  " Purchasing Document
  IF zmm_inwardhd-ebeln IS NOT INITIAL.
    READ TABLE g_t_all_fields INTO g_s_all_fields WITH KEY fieldname = 'EBELN' BINARY SEARCH.
    IF sy-subrc EQ 0.
      REFRESH  g_s_frange-selopt_t.
      MOVE 'EBELN' TO g_s_frange-fieldname.
      r_ebeln-sign = 'I'.
      r_ebeln-option = 'EQ'.
      r_ebeln-high = zmm_inwardhd-ebeln.
      r_ebeln-low = zmm_inwardhd-ebeln.
      MOVE-CORRESPONDING r_ebeln TO g_s_selopt.
      APPEND  g_s_selopt  TO  g_s_frange-selopt_t.
      APPEND  g_s_frange   TO  g_t_frange.
      CLEAR G_S_FRANGE.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'AS_API_READ'
    EXPORTING
      i_fieldcat                = g_s_aind_str1_ais-skey
      i_selections              = g_t_frange
    IMPORTING
      e_result                  = l_t_as_key[]
    EXCEPTIONS
      parameters_invalid        = 1
      no_infostruc_found        = 2
      field_missing_in_fieldcat = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. MESSAGE 'Paramaters Invalid !'             TYPE 'E'.
      WHEN 2. MESSAGE 'No Info Structure Found !'        TYPE 'E'.
      WHEN 3. MESSAGE 'Field Missing in Field Catelog !' TYPE 'E'.
      WHEN 4. MESSAGE 'Archive Read Error'               TYPE 'E'.
    ENDCASE.
  ENDIF.

  SORT l_t_as_key BY archivekey archiveofs .
  DELETE ADJACENT DUPLICATES FROM l_t_as_key COMPARING ALL FIELDS.

  LOOP AT l_t_as_key INTO g_s_as_key.
* read information from archive
    CALL FUNCTION 'ARCHIVE_READ_OBJECT'
      EXPORTING
        object         = 'MM_EKKO'
        archivkey      = g_s_as_key-archivekey
        offset         = g_s_as_key-archiveofs
      IMPORTING
        archive_handle = l_handle
      EXCEPTIONS
        OTHERS         = 1.

    IF sy-subrc <> 0.
      MESSAGE 'No Suitable Data Found in Archive !' TYPE 'E'.
    ELSE.
      CALL FUNCTION 'ARCHIVE_GET_TABLE'                     "#EC *
        EXPORTING
          archive_handle          = l_handle
          record_structure        = 'EKKO'
          all_records_of_object   = 'X'
          automatic_conversion    = 'X'
        TABLES
          table                   = ct_ekko
        EXCEPTIONS
          end_of_object           = 1
          internal_error          = 2
          wrong_access_to_archive = 3
          OTHERS                  = 4.

      APPEND LINES OF ct_ekko TO it_ekko_arch.

      REFRESH:  ct_ekko .
      CLEAR  :  ct_ekko .
    ENDIF.
  ENDLOOP.

ENDFORM.                    " MM_EKKO_RET
