*--- MAIN PROGRAM: MZMMVENDORF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMVENDORF01 .
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 24/11/2008      <RD1K960611>    SAB_SUMODH
*
*1)Native SQL Replaced.
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  CLEAR_SCR_210
*&---------------------------------------------------------------------*
*       CLEAR HEADER SUBSCREEN
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_scr_210.

  PERFORM unlock_table.

  CLEAR : zmm_hvencrt, save_ok, ok_code, ist_vend,ist_lfa1,wa_vend,
          g_crt1,g_crt2,ist_zmm_dvencrt,g_vend,g_mess,g_src_button,
          g_no_vend,ist_req,
*          ist_return_tab,
           g_linno, g_fname,g_ans,
          g_mod_button,g_stat,ist_reqn, g_analyse,g_crt3.

  REFRESH :ist_lfa1,ist_vend, ist_zmm_dvencrt,ist_req,
*  ist_return_tab,
           ist_reqn, ist_vendor1.

  CLEAR : ist_linetab, ist_texttable, ist_linetab_temp,g_loc_text,
          g_com_text, ist_vendor1.

  REFRESH : ist_linetab, ist_texttable, ist_linetab_temp.

  IF NOT w_editor2 IS INITIAL.
    CALL METHOD w_editor2->delete_text.
  ENDIF.
  FREE w_container.
  CLEAR w_container.
  REFRESH CONTROL 'TAB_CTL' FROM SCREEN 220.  "GCU 25.01.2006

ENDFORM.                    " CLEAR_SCR_210
*&---------------------------------------------------------------------*
*&      Form  FILL_STR_SPACES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_VEND_VEND_NAME1  text
*      <--P_L_NAME1  text
*----------------------------------------------------------------------*
FORM fill_str_spaces USING    p_field
                     CHANGING l_name1.
ENDFORM.                    " FILL_STR_SPACES
*&---------------------------------------------------------------------*
*&      Form  HIT_LFA1
*&---------------------------------------------------------------------*
*       search vendors
*----------------------------------------------------------------------*
*      -->P_FIELD  text
*----------------------------------------------------------------------*
FORM hit_lfa1 USING wa_vend-vend-name1 wa_vend-vend-name2
                           wa_vend-vend-ort01.
  DATA : l_str_len(2) TYPE n.
  DATA : l_city(50), l_count(2) TYPE n.
  DATA : name1     LIKE lfa1-name1, name2(60), city(60).
  DATA : sub_str11(60),sub_str12(60),sub_str13(60),sub_str14(60).
  DATA : sub_str15(60),sub_str16(60),sub_str17(60),sub_str18(60).
  DATA : sub_str21(60),sub_str22(60),sub_str23(60),sub_str24(60).
  DATA : sub_str25(60),sub_str26(60),sub_str27(60),sub_str28(60).

  CLEAR l_count.

  CLEAR ist_lfa1.REFRESH ist_lfa1.
  CLEAR l_str_len.
  IF NOT wa_vend-vend-name1 IS INITIAL.
    PERFORM remove_title USING l_str_len
                         CHANGING wa_vend-vend-name1.    "remove 'M/S'
    l_str_len = strlen( wa_vend-vend-name1 ).
    IF l_str_len EQ 35.
      name1 = wa_vend-vend-name1+0(34).
    ELSE.
      name1 = wa_vend-vend-name1.
    ENDIF.

    l_str_len = strlen( name1 ).
    TRANSLATE name1 TO UPPER CASE.
*ns
    PERFORM get_search_string USING l_str_len
                                CHANGING name1 l_count.
  ENDIF.

  IF NOT wa_vend-vend-name2  IS INITIAL.
    PERFORM remove_title USING l_str_len
                         CHANGING wa_vend-vend-name2 .    "remove 'M/S'
    l_str_len = strlen( wa_vend-vend-name2 ).
    IF l_str_len EQ 35.
      name2 = wa_vend-vend-name2+0(34).
    ELSE.
      name2 = wa_vend-vend-name2.
    ENDIF.
    l_str_len = strlen( name2 ).
    TRANSLATE name2 TO UPPER CASE.
    PERFORM get_search_string USING l_str_len
                                CHANGING name2 l_count.
  ENDIF.

  IF NOT wa_vend-vend-ort01 IS INITIAL.
    l_str_len = strlen( wa_vend-vend-ort01 ).
    IF l_str_len EQ 35.

      l_city = wa_vend-vend-ort01+0(34).
    ELSE.
      l_city = wa_vend-vend-ort01.
    ENDIF.
*-----------city search string -----------------------------------*

    CLEAR :l_str_len, l_count.

    l_str_len = strlen( l_city ).
    TRANSLATE l_city TO UPPER CASE.

    CONCATENATE '%' l_city '%' INTO l_city.

  ENDIF.

  IF NOT ist_vend[] IS INITIAL.
    READ TABLE ist_vend INDEX tab_ctl-current_line.
  ENDIF.

  IF NOT sy-ucomm = '/CS'.
    CONCATENATE name1 name2 INTO
                             l_search_string.
  ENDIF.

**** Few changes done in the following part of this subroutine for
**** Search Operations - CAB_AJIT 24.01.2006

  DATA : l_field2_flag.
  DATA : l_name1(45), l_name2.


  SPLIT name1 AT '%' INTO l_name1 l_name2.
  CONCATENATE l_name1 '%' INTO l_name1.

  IF sy-ucomm = '/CS'.
    IF l_city = ' '.
      l_city = '%'.
    ENDIF.
    CLEAR g_fname.
    GET CURSOR FIELD g_fname .
    IF g_fname = 'WA_VEND-VEND-NAME1' .
*Begin of <RD1K960611>.
      EXEC SQL                    "#EC CI_EXECSQL
        PERFORMING store_vendors.
*        SELECT * INTO :IST_LFA1
*        FROM   lfa1
*        WHERE
*        upper(name1) LIKE :l_name1 AND
**               upper(ort01) like :l_city) AND
*              (ktokk = 'IMMI' OR
*               ktokk = 'IMMF' OR
*               ktokk = 'SVWI' OR
*               ktokk = 'SVWF')

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR   ,pstlz

          INTO :WA_LFA5
                 FROM LFA1
                 WHERE
                 (upper(name1) LIKE :l_name1  AND

                  upper(ort01) like :l_city) AND


                   (ktokk = 'IMMI' OR
                    ktokk = 'IMMF' OR
                    ktokk = 'SVWI' OR
                    ktokk = 'SVWF' OR
                    ktokk = 'LEA1' OR
                    ktokk = 'LEA2' OR
                    ktokk = 'CONT' OR
                    ktokk = 'LAQ1' OR
                    ktokk = 'GOVT' OR
                    ktokk = 'INVT' OR
                    ktokk = 'SUBD' OR
                    ktokk = 'UTLT' OR
                    ktokk = 'TRNI' )
*" Addition by ruhani garg on 07.05.2019

      ENDEXEC.
*End of <RD1K960611>.
      l_field2_flag = 'X'.

*Begin of <RD1K960611>.
    ELSEIF g_fname = 'WA_VEND-VEND-ORT01'.
      EXEC SQL                    "#EC CI_EXECSQL
        PERFORMING store_vendors.
*        SELECT * INTO :IST_LFA1
*        FROM   lfa1
*        WHERE
*              (upper(ort01) LIKE :l_city) AND
*              (ktokk = 'IMMI' OR
*               ktokk = 'IMMF' OR
*               ktokk = 'SVWI' OR
*               ktokk = 'SVWF')


        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR
            ,pstlz

          INTO :WA_LFA5
         FROM LFA1
         WHERE
             (upper(ort01) LIKE :l_city) AND
             (ktokk = 'IMMI' OR
                    ktokk = 'IMMF' OR
                    ktokk = 'SVWI' OR
                    ktokk = 'SVWF' OR
                    ktokk = 'LEA1' OR
                    ktokk = 'LEA2' OR
                    ktokk = 'CONT' OR
                    ktokk = 'LAQ1' OR
                    ktokk =  'GOVT' OR
                    ktokk = 'INVT' OR
                    ktokk = 'SUBD' OR
                    ktokk = 'UTLT' OR
                    ktokk = 'TRNI' )
*TRNI added by ruhani garg on 07.05.2019
      ENDEXEC.
*End of <RD1K960611>.
      l_field2_flag = 'X'.
    ELSEIF g_fname = 'WA_VEND-VEND-NAME2'.
* Begin of <RD1K960611>.
      EXEC SQL                    "#EC CI_EXECSQL
        PERFORMING store_vendors.
*        SELECT * INTO :IST_LFA1
*        FROM   lfa1
*        WHERE
*        upper(name1) LIKE :l_name1 AND
*              (ktokk = 'IMMI' OR
*               ktokk = 'IMMF' OR
*               ktokk = 'SVWI' OR
*               ktokk = 'SVWF')

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR

            ,pstlz

           INTO :WA_LFA5
                  FROM LFA1
                  WHERE
                  (upper(name1) LIKE :l_name1)  AND
                  (ktokk = 'IMMI' OR
                    ktokk = 'IMMF' OR
                    ktokk = 'SVWI' OR
                    ktokk = 'SVWF' OR
                    ktokk = 'LEA1' OR
                    ktokk = 'LEA2' OR
                    ktokk = 'CONT' OR
                    ktokk = 'LAQ1' OR
                    ktokk = 'GOVT' OR
                    ktokk = 'INVT' OR
                    ktokk = 'SUBD' OR
                    ktokk = 'UTLT' OR
                    ktokk = 'TRNI' )
*Added by ruhani Garg on 07.05.2019

      ENDEXEC.
*End of <RD1K960611>.
      l_field2_flag = 'X'.
    ENDIF.
  ELSE.
* Begin of <RD1K960611>.
    EXEC SQL                    "#EC CI_EXECSQL
      PERFORMING store_vendors.

*      SELECT * INTO :IST_LFA1
*      FROM   lfa1
*      WHERE
*      (upper(name1) LIKE :l_search_string  AND
*             upper(ort01) LIKE :l_city) AND
*            (ktokk = 'IMMI' OR
*             ktokk = 'IMMF' OR
*             ktokk = 'SVWI' OR
*             ktokk = 'SVWF')

      SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR

        ,pstlz


        INTO :WA_LFA5
                FROM LFA1
                WHERE
                (upper(name1) LIKE :l_search_string AND

                   upper(ort01) LIKE :l_city) AND


* Begin of <> on 16122010
                    (ktokk = 'IMMI' OR
                    ktokk = 'IMMF' OR
                    ktokk = 'SVWI' OR
                    ktokk = 'SVWF' OR
                    ktokk = 'LEA1' OR
                    ktokk = 'LEA2' OR
                    ktokk = 'CONT' OR
                    ktokk = 'LAQ1' OR
                    ktokk = 'GOVT' OR
                    ktokk = 'INVT' OR
                    ktokk = 'SUBD' OR
                    ktokk = 'UTLT' OR
                    ktokk = 'TRNI' )
* TRNI value added by ruhani Garg on 07.05.2019
*                  (ktokk = 'IMMI' OR
*                   ktokk = 'IMMF' OR
*                   ktokk = 'SVWI' OR
*                   ktokk = 'SVWF')
* End of <> on 16122010
    ENDEXEC.
*End of <RD1K960611>.
    l_field2_flag = 'X'.

  ENDIF.

  IF sy-ucomm = 'ENTE' OR sy-ucomm = 'OPT1'.
*Begin of <RD1K960611>.
    EXEC SQL                    "#EC CI_EXECSQL
      PERFORMING store_vendors.

*      SELECT * INTO :IST_LFA1
*      FROM   lfa1
*      WHERE
*      (upper(name1) LIKE :l_name1 AND
**               upper(name2) LIKE :name2 AND
*             upper(ort01) like :l_city) AND
*            (ktokk = 'IMMI' OR
*             ktokk = 'IMMF' OR
*             ktokk = 'SVWI' OR
*             ktokk = 'SVWF')

      SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR   ,pstlz
        INTO  :WA_LFA5
               FROM LFA1
               where
           (upper(name1) LIKE :l_name1 AND

*               upper(name2) LIKE :name2 AND

                  upper(ort01) like :l_city) AND
* Begin of <> on 16122010
                    (ktokk = 'IMMI' OR
                    ktokk = 'IMMF' OR
                    ktokk = 'SVWI' OR
                    ktokk = 'SVWF' OR
                    ktokk = 'LEA1' OR
                    ktokk = 'LEA2' OR
                    ktokk = 'CONT' OR
                    ktokk = 'LAQ1' OR
                    ktokk = 'GOVT' OR
                    ktokk = 'INVT' OR
                    ktokk = 'SUBD' OR
                    ktokk = 'UTLT' OR
                    ktokk = 'TRNI' )
* Added by ruhani garg on 07.05.2019

*                  (ktokk = 'IMMI' OR
*                   ktokk = 'IMMF' OR
*                   ktokk = 'SVWI' OR
*                   ktokk = 'SVWF')
* End of <> on 16122010
    ENDEXEC.
*End of <RD1K960611>.
    l_field2_flag = 'X'.
  ENDIF.

  IF l_field2_flag = 'X'.




    """"""""""""""""""""""""""""""""""""""
    "added by lipsy on 12.11.2015 RD1K999141
    CLEAR:v_name1_correct.
    v_name1_correct = name1.
    CONDENSE v_name1_correct.


    REFRESH:lt_result[].

    FIND ALL OCCURRENCES OF '%' IN v_name1_correct RESULTS lt_result.

    IF sy-subrc = 0.


      CLEAR:count_name1,ls_result, v_offset,v_name1_c.
      LOOP AT lt_result INTO ls_result.
        count_name1 = count_name1 + 1.

        """""""""""""""""""""""""
        "added by lipsy 8.02.2016
        IF count_name1 = 1.
          v_name1_c = v_name1_correct.
        ENDIF.
        "eadded by lipsy 8.02.2016
        """"""""""""""""""""""""""""""""""""""

        IF count_name1 = 2.
          v_offset = ls_result-offset + 1 .
          v_name1_c = v_name1_correct+0(v_offset).
          EXIT.
        ENDIF.

      ENDLOOP.



    ENDIF.




    l_search_string =  v_name1_c.


    "end of addition by lipsy on 12.11.2015 RD1K999141



    """"""""""""""""""""""""""""""""""""""""""
    """"""""""""""""""""""
    "commented by lipsy on 12.11.2015 RD1K999141
*    CONCATENATE name1 name2 INTO
*                            l_search_string.

    "end of comment by lipsy on 12.11.2015 RD1K999141
    """"""""""""""""""""""""""""""""""""""""""""
  ENDIF.

  IF l_field2_flag = 'X' OR sy-ucomm = 'ENTE'.

    CLEAR l_field2_flag.

    DATA : l_wa_lfa1 LIKE LINE OF ist_lfa1.
    DATA : l_wa_char(80) TYPE c.

    LOOP AT ist_lfa1 INTO wa_lfa1.

      TRANSLATE l_search_string TO UPPER CASE.

      CONCATENATE wa_lfa1-name1 wa_lfa1-name2 INTO l_wa_char.

      TRANSLATE l_wa_char TO UPPER CASE.

      TRANSLATE l_search_string USING '%*'.

      IF l_wa_char CP l_search_string.

      ELSE.

        DELETE ist_lfa1.

      ENDIF.

      TRANSLATE l_search_string USING '*%'.

    ENDLOOP.

  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 16.11.2015 RD1K999141
  REFRESH:itab_lifnr_pan[].

  IF wa_vend-vend-j_1ipanno IS NOT INITIAL.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: CIN vendor master J_1IMOVEND merged into LFA1 (SAP Note 2627221) - read redirected to LFA1.
*    SELECT * FROM j_1imovend
*   INTO CORRESPONDING FIELDS OF TABLE
*   itab_lifnr_pan
*    WHERE j_1ipanno = wa_vend-vend-j_1ipanno.
    SELECT * FROM lfa1
   INTO CORRESPONDING FIELDS OF TABLE
   itab_lifnr_pan
    WHERE j_1ipanno = wa_vend-vend-j_1ipanno.  "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    REFRESH:ist_lfa3[].
    CLEAR:ist_lfa3.
    IF itab_lifnr_pan[] IS NOT INITIAL.
      SELECT * FROM  lfa1
      INTO CORRESPONDING FIELDS OF TABLE ist_lfa3
      FOR ALL ENTRIES IN itab_lifnr_pan
     WHERE lifnr =  itab_lifnr_pan-lifnr.  "#EC CI_NOORDER

      APPEND LINES OF ist_lfa3[] TO  ist_lfa1[].
    ENDIF.
  ENDIF.
  "end of addition by lipsy on 16.11.2015 RD1K999141
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""







*-----END CHANGE SEARCH PROCEDURE ON 9.1.2006
  IF NOT ist_lfa1[] IS INITIAL.
    SORT ist_lfa1 BY lifnr.

    DELETE ADJACENT DUPLICATES FROM ist_lfa1.
**ajit
    IF sy-ucomm = 'ENTE'.
      DESCRIBE TABLE ist_lfa1 LINES g_rec_found.
    ELSE.
      g_rec_found = 0.
    ENDIF.
  ELSE.


  ENDIF.


  """"""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 16.11.2015 RD1K999141

  """"""""""""""
  "added by lipsy on 28.12.2015

  IF zmm_hvencrt-srmid IS NOT INITIAL.
    IF zmm_hvencrt-lifnr_srm IS NOT INITIAL.
      CLEAR:wa_lfa1_srm.
      CLEAR:  v_lifnr_srm_repl.
      v_lifnr_srm_repl = zmm_hvencrt-lifnr_srm.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = v_lifnr_srm_repl
        IMPORTING
          output = v_lifnr_srm_repl.

      SELECT SINGLE mandt lifnr land1 name1 name2 ort01 adrnr pstlz
             INTO  CORRESPONDING FIELDS OF  wa_lfa1_srm
                    FROM lfa1
                    WHERE lifnr = v_lifnr_srm_repl.



      APPEND wa_lfa1_srm TO ist_lfa1 .

    ENDIF.
  ENDIF.
  "end of addition by lipsy on 28.12.2015
  """""""""""""""""

  SORT ist_lfa1 BY lifnr mandt DESCENDING.
  DELETE ADJACENT DUPLICATES FROM ist_lfa1 COMPARING lifnr.
  IF ist_lfa1-lifnr IS NOT INITIAL.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: CIN vendor master J_1IMOVEND merged into LFA1 (SAP Note 2627221) - read redirected to LFA1.
*    SELECT * FROM j_1imovend
*     INTO CORRESPONDING FIELDS OF TABLE
*     itab_lifnr_pan FOR ALL ENTRIES IN
*     ist_lfa1 WHERE lifnr =  ist_lfa1-lifnr.
    SELECT * FROM lfa1
     INTO CORRESPONDING FIELDS OF TABLE
     itab_lifnr_pan FOR ALL ENTRIES IN
     ist_lfa1 WHERE lifnr =  ist_lfa1-lifnr.  "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    CLEAR:v_index_pan.
    LOOP AT ist_lfa1.

      v_index_pan = sy-tabix.

      READ TABLE  itab_lifnr_pan INTO wa_lifnr_pan WITH KEY lifnr = ist_lfa1-lifnr.

      IF sy-subrc = 0.

        ist_lfa1-j_1ipanno = wa_lifnr_pan-j_1ipanno.

      ENDIF.

      MODIFY ist_lfa1 FROM  ist_lfa1 INDEX   v_index_pan  TRANSPORTING j_1ipanno.

      CLEAR:v_index_pan.

    ENDLOOP.
  ENDIF.
  "end of addition by lipsy on 16.11.2015 RD1K999141
  """"""""""""""""""""""""""""""""""""""""""""""""""

***********************************************************************
************************************************************ CAB_AJIT *

ENDFORM.                                                    " HIT_LFA1
*&---------------------------------------------------------------------*
*&      Form  UPDATE_REC_FOUND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_rec_found.
  DESCRIBE TABLE ist_vend LINES g_vend.
  DESCRIBE TABLE ist_lfa1 LINES g_rec_found.
  CLEAR ist_vend.
  IF wa_vend-vend-seqno IS INITIAL.
    wa_vend-vend-seqno = tab_ctl-current_line.
  ENDIF.
  READ TABLE ist_vend INDEX tab_ctl-current_line.
  wa_vend-vend-ven_fnd = g_rec_found.

  IF g_vend EQ tab_ctl-current_line.
    MODIFY ist_vend FROM wa_vend INDEX tab_ctl-current_line.
  ELSEIF g_vend LT tab_ctl-current_line .
    APPEND wa_vend TO ist_vend.
  ENDIF.

  TYPES: BEGIN OF ty_pan,
           lifnr     TYPE lifnr,
           j_1ipanno TYPE j_1ipanno,
         END OF ty_pan.

  DATA: it_pan TYPE TABLE OF ty_pan,
        wa_pan LIKE LINE OF it_pan.

  IF ist_lfa1[] IS NOT INITIAL.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: CIN vendor master J_1IMOVEND merged into LFA1 (SAP Note 2627221) - read redirected to LFA1.
*    SELECT lifnr j_1ipanno
*          INTO CORRESPONDING FIELDS OF TABLE it_pan
*          FROM j_1imovend
*          FOR ALL ENTRIES IN ist_lfa1
*          WHERE lifnr = ist_lfa1-lifnr.
    SELECT lifnr j_1ipanno
          INTO CORRESPONDING FIELDS OF TABLE it_pan
          FROM lfa1
          FOR ALL ENTRIES IN ist_lfa1
          WHERE lifnr = ist_lfa1-lifnr.  "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
    IF it_pan[] IS NOT INITIAL.

      LOOP AT ist_lfa1.

        READ TABLE it_pan INTO wa_pan WITH KEY lifnr = ist_lfa1-lifnr.
        IF sy-subrc = 0.

          ist_lfa1-j_1ipanno = wa_pan-j_1ipanno.
          MODIFY ist_lfa1 TRANSPORTING j_1ipanno WHERE lifnr = ist_lfa1-lifnr .
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.
ENDFORM.                    " UPDATE_REC_FOUND
*&---------------------------------------------------------------------*
*&      Form  CREATE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_request.
  PERFORM check_mandatory_fields.
  """""""""""""""""""""""""""""""""""""""""""""
  "ADDED BY LIPSY ON 3.07.2015  RD1K997727
  IF flag_gst EQ 0.

    IF v_exist_pan = 'X' .

*    PERFORM confirm_PAN_ATTACH .
*      IF g_ans = '1'.
      PERFORM confirm_user_action USING text-001 text-002.
      IF g_ans = '1'.
        MESSAGE i803(zmm) WITH text-100.
        PERFORM modify_db.
      ENDIF.
*      endif.

    ELSE.

      "END OF ADDITION BY LIPSY ON 3.07.2015  RD1K997727
      """"""""""""""""""""""""""""""""""""""""""""""""""""
      IF sy-ucomm NE 'ENTE'.  "" kp05102019
        PERFORM confirm_user_action USING text-001 text-002.
        IF g_ans = '1'.
          MESSAGE i803(zmm) WITH text-100.
          PERFORM modify_db.
        ENDIF.
      ENDIF.
      """"""""""""""""""""""""""""""
      "ADDED BY LIPSY ON 3.07.2015 RD1K997727
    ENDIF.
    "END OF ADDITION BY LIPSY ON 3.07.2015 RD1K997727
    """""""""""""""""""""""""""""""""

  ENDIF.
ENDFORM.                    " CREATE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  confirm_user_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_user_action USING p_title p_question.
  CLEAR g_ans.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = p_title
      text_question         = p_question
      text_button_1         = 'Yes'(003)
      text_button_2         = 'No'(004)
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = g_ans.

ENDFORM.                    " confirm_user_action
*&---------------------------------------------------------------------*
*&      Form  check_mandatory_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_mandatory_fields.
  CLEAR : wa_vend, g_rej_all.
  break abapuser02.
*  break mmuser01.
  """""""""""""""""""""""""""""""
  "ADDED BY LIPSY ON 3.07.2015 RD1K997727

  CLEAR: v_exist_pan.

  "END OF ADDITION BY LIPSY ON 3.07.2015 RD1K997727
  """"""""""""""""""""""""""""""""""
  IF NOT ist_vend[] IS INITIAL.

    LOOP AT ist_vend INTO wa_vend.
      CONDENSE wa_vend-vend-name1.
      MODIFY ist_vend FROM wa_vend INDEX sy-tabix
                                   TRANSPORTING vend-name1.
      IF wa_vend-vend-stras1 IS INITIAL OR wa_vend-vend-ort01 IS INITIAL
       OR wa_vend-vend-land1 IS INITIAL OR wa_vend-vend-brsch IS INITIAL
       OR wa_vend-vend-waers IS INITIAL OR wa_vend-vend-name1 IS INITIAL
                                 OR ( wa_vend-vend-j_1kftbus = 'OEM' AND
                                      wa_vend-vend-zoem_rem IS INITIAL ).
        MESSAGE e055(00).
      ENDIF.


      IF zmm_hvencrt-bukrs = 'OVL'. " add by aparna on 11/03/2025
        IF zmm_hvencrt-udyog_aadhaar IS INITIAL.
*          IF wa_vend-vend-brsch =  'Z025' OR
*             wa_vend-vend-brsch =  'Z026' OR
*             wa_vend-vend-brsch =  'Z027' OR
*             wa_vend-vend-brsch =  'Z028' OR
*             wa_vend-vend-brsch =  'Z029' OR
*             wa_vend-vend-brsch =  'Z030' OR
*             wa_vend-vend-brsch =  'Z031' OR
*             wa_vend-vend-brsch =  'Z032' OR
*             wa_vend-vend-brsch =  'Z033' OR
*             wa_vend-vend-brsch =  'Z034' .
*            .
          SELECT SINGLE  brsch , udyog_aadhaar_no FROM zmm_vms_industry INTO @DATA(ls_vms) WHERE   " ADD BY ROHIT ON 12/03/2025
           udyog_aadhaar_no EQ 'X' AND brsch EQ @wa_vend-vend-brsch.
          IF sy-subrc EQ 0.
            MESSAGE 'Please Enter Udyam Number' TYPE 'S' DISPLAY LIKE 'E'.
            flag_gst = 1.
            EXIT.

          ENDIF.
        ENDIF.

        IF zmm_hvencrt-udyog_aadhaar IS NOT INITIAL.   "  soc add by rohit on 07/04/2025
          DATA : udm_no TYPE i.
          udm_no =  strlen( zmm_hvencrt-udyog_aadhaar  ).

          IF udm_no LT '19'.
*            flag = abap_true.
            MESSAGE 'Udyam Number should be 19 digit ' TYPE 'I' DISPLAY LIKE 'E'.
            flag_gst = 1.
            EXIT.
          ENDIF.

        ENDIF .
      ENDIF.    " eoc by rohit on 07.04.2025

      IF ( zmm_hvencrt-ktokk = 'IMMI' OR zmm_hvencrt-ktokk = 'SVWI')
       AND  (    "WA_VEND-VEND-ORT02 IS INITIAL OR
     wa_vend-vend-pstlz IS INITIAL OR wa_vend-vend-regio IS INITIAL ).
        MESSAGE e055(00).
      ENDIF.

*+SP007 -Checks all obligatory fields in Z-table - ZMM_VENCHK -26/10/07
      IF zmm_hvencrt-bukrs <> 'OVC'.   " added by ss on 22.3.2021
        IF NOT ( g_vat IS INITIAL ) AND wa_vend-vend-stcd1 IS INITIAL.
          MESSAGE e055(00).
        ENDIF.

        IF NOT ( g_cst IS INITIAL ) AND wa_vend-vend-stcd2 IS INITIAL.
          MESSAGE e055(00).
        ENDIF.

        IF NOT ( g_pan IS INITIAL ) AND wa_vend-vend-j_1ipanno IS INITIAL.
          MESSAGE e055(00).
        ENDIF.

        IF NOT ( g_stx IS INITIAL ) AND wa_vend-vend-j_1isern IS INITIAL.
          MESSAGE e055(00).
        ENDIF.

        IF NOT ( g_bnk IS INITIAL ) AND wa_vend-vend-bankn IS INITIAL.
*         and lfbk-banks is initial and lfbk-banks is initial.
          MESSAGE e055(00).
        ENDIF.
      ENDIF.      "added by ss


      IF sy-ucomm = 'SAVE'.

        IF zmm_hvencrt-bukrs <> 'OVC'. "added by ss on 22.3.21
          IF wa_vend-vend-gst_no = '' AND wa_vend-vend-ven_class = '' AND wa_vend-vend-ven_class NE '0'.
            MESSAGE 'Please Enter Correct Vendor GST Classification.' TYPE 'E'."E'.
          ENDIF.
        ENDIF.

      ENDIF. "added by ss on 22.3.21
*+SP007 - End

*      IF G_TRANS_MODE = 'A' AND WA_VEND-REJ_FLG IS INITIAL.
      IF g_trans_mode = 'A'.
        IF wa_vend-vend-sortl IS INITIAL AND
           wa_vend-vend-rsn IS INITIAL.
          MESSAGE e055(00).
        ENDIF.
      ENDIF.

      IF wa_vend-vend-rsn = ' '.
        g_rej_all = 1.
      ENDIF.
**********************************************************************
      CLEAR flag_gst.
      IF zmm_hvencrt-bukrs <> 'OVC'. "added by ss on 22.3.21
        IF wa_vend-vend-ven_class NE '0'.

          IF wa_vend-vend-gst_no+0(2) NE wa_vend-vend-regio.

            MESSAGE 'First two chars of GST No. should be Region code' TYPE 'S' DISPLAY LIKE 'E'.
            flag_gst = 1.
            EXIT.

          ELSEIF wa_vend-vend-gst_no+2(10) NE  wa_vend-vend-j_1ipanno.

            MESSAGE '3rd to 12th Chars of GST No. should be equal to Pan No.' TYPE 'S' DISPLAY LIKE 'E'.
            flag_gst = 1.
            EXIT.

          ENDIF.
          flag_gst = 0.
        ENDIF. "added by ss on 22.3.21
      ENDIF.

**********************************************************************

      """"""""""""""""""""""""""""""

      "ADDED BY LIPSY ON 3.07.2015 RD1K997727
      IF zmm_hvencrt-bukrs <> 'OVC'. "added by ss on 22.3.21
        IF wa_vend-vend-j_1ipanno IS NOT INITIAL.

          v_exist_pan = 'X'.

        ENDIF.
      ENDIF. "added by ss on 22.3.21
      "END OF ADDITION BY LIPSY ON 3.07.2015 RD1K997727
      """"""""""""""""""""""""""""""""""""""""""""""
      CLEAR: wa_vend.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " check_mandatory_fields
*&---------------------------------------------------------------------*
*&      Form  GENERATE_REQUEST
*&---------------------------------------------------------------------*
*       vendor extension req number gen
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_request USING object
                      CHANGING g_req_num.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = c_nr_range_nr
      object                  = object
      quantity                = '1'
    IMPORTING
      number                  = g_req_num
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
  ELSE.
    IF g_unblock_vendor = 'X'.
      CONCATENATE 'VU' g_req_num INTO zmm_vend_unblock-reqno.
* Begin of <> on 07122010
    ELSEIF g_block_vendor = 'X'.
      CONCATENATE 'VB' g_req_num INTO zmm_vend_block-reqno.
* End of <> on 07122010
    ELSE.
      CONCATENATE 'VC' g_req_num INTO zmm_hvencrt-reqno.
    ENDIF.
  ENDIF.

  CLEAR g_req_num.
ENDFORM.                    " GENERATE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_db.
  CLEAR :g_crt1, g_crt2,g_crt3.

  CASE g_trans_mode.
    WHEN 'N'.
      PERFORM generate_request USING c_nr_object
                               CHANGING g_req_num.
*      PERFORM lock_table.
      PERFORM update_zmm_hvencrt ON COMMIT.
      PERFORM update_zmm_dvencrt ON COMMIT.
      IF g_crt1 IS INITIAL AND
         g_crt2 IS INITIAL.
        COMMIT WORK.
        MESSAGE s728(zmm) WITH zmm_hvencrt-reqno.
      ELSE.
        MESSAGE e732(zmm).
      ENDIF.
      PERFORM save_text.
    WHEN 'M'.
      PERFORM lock_table.
      READ TABLE ist_vend WITH KEY vend-del_flag = 'X'.
      IF sy-subrc IS INITIAL.
        PERFORM del_zmm_dvencrt ON COMMIT.
      ENDIF.
      PERFORM update_zmm_hvencrt ON COMMIT.
      PERFORM update_zmm_dvencrt ON COMMIT.

      """"""""""""""""""""""""""""
      "added by lipsy for rejection
      IF v_user_comm = 'CHNGREPL'.

        IF zmm_hvencrt-reqcl = 'R'.
          SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
            WHERE  appl = 'SRM'.

          """"""calling srm

*BREAK-POINT.
          IF NOT l_logsys  IS INITIAL.



            CALL FUNCTION 'ZSRM_VENDOR_ECC_REJECT'
              DESTINATION l_logsys
              EXPORTING
                v_ptner = zmm_hvencrt-srmid
              IMPORTING
                return  = return_reject.

            IF return_reject = 'Y'.
              PERFORM save_text.

              IF ist_linetab[] IS NOT INITIAL.
                UPDATE zmm_hvencrt SET
                rejected_by = sy-uname
                rejected_on = sy-datum
                reqcl = 'R'
                WHERE reqno = zmm_hvencrt-reqno.


                PERFORM clear_scr_210.

                PERFORM clear_scr_220.
                CLEAR: v_user_comm.
                MESSAGE s247(zmm_oth) .
                LEAVE TO SCREEN 0.

              ELSE.
                MESSAGE s248(zmm_oth).
                LEAVE TO SCREEN 200.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.



        IF zmm_hvencrt-reqcl = 'MS'.
          """"""""""""""
          "add by lipsy

          v_reqcl_srm = zmm_hvencrt-reqcl.

          "eadd by lipsy
          """"""""""""""""""""""""""
          IF zmm_hvencrt-srmid  IS NOT INITIAL.

            PERFORM save_text.
*PERFORM SEND_MAIL_MV.

            IF ist_linetab[] IS NOT INITIAL.
              PERFORM send_mail_mv.
              UPDATE zmm_hvencrt SET
         aeusn = sy-uname
         aedtm = sy-datum
         reqcl = 'MS'
         WHERE reqno = zmm_hvencrt-reqno.
              MESSAGE s249(zmm_oth) .
              LEAVE TO SCREEN 0.
            ELSE.
              MESSAGE s248(zmm_oth).
              LEAVE TO SCREEN 200.
            ENDIF.
          ENDIF.

        ENDIF.

      ENDIF.
      "eadd by lipsy
      """"""""""""""""""""""""""""""
      IF g_crt1 IS INITIAL AND
         g_crt2 IS INITIAL AND
         g_crt3 IS INITIAL.
        COMMIT WORK.
        MESSAGE s268(zmm).
      ELSE.
        MESSAGE a735(zmm) WITH 'Error Document not modified'.
      ENDIF.
      PERFORM unlock_table.
      PERFORM save_text.
  ENDCASE.
ENDFORM.                    " MODIFY_DB
*&---------------------------------------------------------------------*
*&      Form  LOCK_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_table.

  CALL FUNCTION 'ENQUEUE_EZMM_HVENCRT'
    EXPORTING
      mode_zmm_hvencrt = 'E'
      mandt            = sy-mandt
      reqno            = zmm_hvencrt-reqno
    EXCEPTIONS
      foreign_lock     = 1
      system_failure   = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

    CALL FUNCTION 'ENQUEUE_EZMM_DVENCRT'
      EXPORTING
        mode_zmm_dvencrt = 'E'
        mandt            = sy-mandt
        reqno            = zmm_hvencrt-reqno
      EXCEPTIONS
        foreign_lock     = 1
        system_failure   = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.


ENDFORM.                    " LOCK_TABLE
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_hvencrt.
  zmm_hvencrt-mandt = sy-mandt.
  IF g_trans_mode = 'N'.
    zmm_hvencrt-erfdt = sy-datum.
    zmm_hvencrt-ernam = sy-uname.
  ELSEIF g_trans_mode = 'M'.
    zmm_hvencrt-aedtm = sy-datum.
    zmm_hvencrt-aeusn = sy-uname.
  ENDIF.
  CLEAR : zmm_hvencrt-rel_flag,
          zmm_hvencrt-released_by,
          zmm_hvencrt-release_date.
  IF zmm_hvencrt-ass_flag = ' '.
    """"""""""""""""""
    "ADD BY LIPSY
    CLEAR:v_reqcl_new.
    v_reqcl_new =  zmm_hvencrt-reqcl .
    "EADD BY LIPSY
    """"""""""""""""""""""""""
    zmm_hvencrt-reqcl = 'N'.
    """"""""""""""""""""""""
    "ADD BY LIPSY
    IF g_trans_mode = 'M' .
      IF sy-uname+0(3) = 'CMM'.
        zmm_hvencrt-reqcl = v_reqcl_new.
      ENDIF.
    ENDIF.
    "EADD BY LIPSY

    """""""""""""""""""""""""""
  ELSEIF zmm_hvencrt-ass_flag = 'R' OR
         zmm_hvencrt-ass_flag = 'P'.

    """"""""""""""""""""""""""""""""""""""""
    "ADD BY LIPSY
    IF sy-uname+0(3) = 'CMM'.
    ELSE.
      """""""""""""""""""""""""""""""""""""""""""

      zmm_hvencrt-reqcl = 'IR'.

      """""""""""""""""""""""""""""""""""""
      "ADD BY LIPSY
    ENDIF.

    """"""""""""""""""""""""""""""""""""

  ENDIF.
  IF NOT zmm_hvencrt-reqno IS INITIAL AND
     NOT zmm_hvencrt-ktokk IS INITIAL.
**    Added by ss on 15.9.21
    IF zmm_hvencrt-rel_flag IS INITIAL.
      zmm_hvencrt-rejected_by = ' '.
      zmm_hvencrt-rejected_on = ' '.
    ENDIF.

**    EOC by ss on 15.9.21
    MODIFY zmm_hvencrt.
    IF NOT sy-subrc IS INITIAL.
      g_crt1 = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*       update detail ztable
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_dvencrt.
  CLEAR ist_zmm_dvencrt.REFRESH ist_zmm_dvencrt.
  CLEAR ist_row_del.REFRESH ist_row_del.

  IF NOT ist_vend[] IS INITIAL.
    LOOP AT ist_vend INTO wa_vend WHERE vend-del_flag <> 'X'.
      MOVE-CORRESPONDING wa_vend-vend TO ist_zmm_dvencrt.
      ist_zmm_dvencrt-reqno = zmm_hvencrt-reqno.
      ist_zmm_dvencrt-mandt = sy-mandt.
      IF g_trans_mode = 'N'.
        ist_zmm_dvencrt-erfdt = sy-datum.
        ist_zmm_dvencrt-ernam = sy-uname.
      ELSE.
        IF ist_zmm_dvencrt-erfdt IS INITIAL.
          ist_zmm_dvencrt-erfdt = sy-datum.
          ist_zmm_dvencrt-ernam = sy-uname.
        ENDIF.
        ist_zmm_dvencrt-aedtm = sy-datum.
        ist_zmm_dvencrt-aeusn = sy-uname.
      ENDIF.
      APPEND ist_zmm_dvencrt.
    ENDLOOP.
  ENDIF.

  IF NOT ist_zmm_dvencrt[] IS INITIAL .
    MODIFY zmm_dvencrt FROM TABLE ist_zmm_dvencrt[].
    IF NOT sy-subrc IS INITIAL.
      g_crt2 = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*&      Form  DISP_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_address.
  READ TABLE ist_lfa1 INDEX tab_srch-current_line.

  IF sy-subrc IS INITIAL.
    PERFORM get_address USING ist_lfa1-lifnr.
  ENDIF.
  CHECK NOT addr1_val IS INITIAL.
  g_scr = '0201'.
ENDFORM.                    " DISP_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  GET_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LIFNR  text
*----------------------------------------------------------------------*
FORM get_address USING    p_lifnr.
  CLEAR : ekko,addr1_val.
  ekko-lifnr = p_lifnr.

  CALL FUNCTION 'MM_ADDRESS_GET'
    EXPORTING
      i_ekko    = ekko
    IMPORTING
      e_address = addr1_val
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    " GET_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  update_vendor_flg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_VEND  text
*      -->P_FND_FLG  text
*----------------------------------------------------------------------*
FORM update_vendor_flg TABLES   ist_vend STRUCTURE ist_vend
                       USING    fnd_flg.
  IF NOT ist_vend[] IS INITIAL.
    DESCRIBE TABLE ist_vend LINES g_vend.
    READ TABLE ist_vend INDEX g_vend.
    IF sy-subrc IS INITIAL AND NOT fnd_flg IS INITIAL.
      ist_vend-fnd_flg = fnd_flg.
      IF ( ( zmm_hvencrt-ktokk = 'SVWI' OR
         zmm_hvencrt-ktokk = 'IMMI' ) AND
         ( zmm_hvencrt-ekorg = 'PMAT' OR
         zmm_hvencrt-ekorg = 'PSRV' ) ).


*  Begin on 22.3.21 by ss.
*    ist_vend-vend-waers = 'INR'.
        IF zmm_hvencrt-bukrs = 'OVC'.
          ist_vend-vend-waers = 'COP'.
        ELSE.
          ist_vend-vend-waers = 'INR'.
        ENDIF.
*   * EOC by ss.

      ENDIF.
      MODIFY ist_vend INDEX g_vend TRANSPORTING fnd_flg vend-waers.
      CLEAR : g_opn_flg, fnd_flg.
    ENDIF.
  ENDIF.

ENDFORM.                    " update_vendor_flg
*&---------------------------------------------------------------------*
*&      Form  SET_PFSTATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0103   text
*----------------------------------------------------------------------*
FORM set_pfstatus USING p_code.
* Begin of <> on 13022012

  """""""""""""""""""""""""""""""""""""""
  "added by lipsy on 9.02.2013 RD1K979902
  IF p_code = 'CHAN'.
    IF  g_block_vendor_att = 'X' OR g_unblock_vendor = 'X'.
    ELSE.
*  "end of addition by lipsy on 9.02.2013 RD1K979902
*
      """"""""""""""""""""""""""""""""
      ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui .
      ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .
      """""""""""""""""""""""""""""""""""""""""""""""""""
      ""added by lipsy on 9.02.2013 RD1K979902
    ENDIF.
  ELSE.

    """"""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*
    ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui .
    """""""""commented by lipsy for attach in assign unblock RD1K983016 on 27.08.2013
*  ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .

    """""""""end of comment by lipsy for attach in assign unblock RD1K983016 on 27.08.2013
  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "" "end of addition by lipsy on 9.02.2013 RD1K979902

  """"""""""""""""""""""""""""""""""""""""
  ist_gui-fcode = 'HELP' . APPEND ist_gui . CLEAR ist_gui .
*  ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
  ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
  DELETE ist_gui WHERE fcode = p_code.


  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 10.12.2014 for removing unblock button on changing status to ir by assigner.

  IF p_code = 'UNBL'.
    IF zmm_vend_unblock-reqclu = 'IR'.
      ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
    ENDIF.
  ENDIF.



  "end of addition  by lipsy on 10.12.2014 for removing unblock button on changing status to ir by assigner.


* End of <> on 13022012

ENDFORM.                    " SET_PFSTATUS
*&---------------------------------------------------------------------*
*&      Form  DELETE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_request.
  PERFORM confirm_user_action USING text-024 text-007.
  IF g_ans = '1'.
    PERFORM lock_table.
    PERFORM del_zmm_hvencrt ON COMMIT.
    PERFORM del_zmm_dvencrt ON COMMIT.
    IF g_crt1 IS INITIAL AND
       g_crt2 IS INITIAL.
      COMMIT WORK.
      MESSAGE s415(zmm) WITH zmm_hvencrt-reqno.
      PERFORM delete_notes.
    ELSE.
      MESSAGE e506(zmm) WITH zmm_hvencrt-reqno.
    ENDIF.
    PERFORM unlock_table.
  ENDIF.

ENDFORM.                    " DELETE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_table.

  IF NOT zmm_hvencrt-reqno IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZMM_HVENCRT'
      EXPORTING
        mode_zmm_hvencrt = 'E'
        mandt            = sy-mandt
        reqno            = zmm_hvencrt-reqno.

    CALL FUNCTION 'DEQUEUE_EZMM_DVENCRT'
      EXPORTING
        mode_zmm_dvencrt = 'E'
        mandt            = sy-mandt
        reqno            = zmm_hvencrt-reqno.
  ENDIF.

ENDFORM.                    " UNLOCK_TABLE
*&---------------------------------------------------------------------*
*&      Form  DEL_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_zmm_hvencrt.
*  ZMM_HVENCRT-DEL_REQ = 'X'.
  zmm_hvencrt-aedtm = sy-datum.
  zmm_hvencrt-aeusn = sy-uname.
  DELETE FROM zmm_hvencrt WHERE reqno = zmm_hvencrt-reqno.
  IF NOT sy-subrc IS INITIAL.
    g_crt1 = 'X'.
  ENDIF.

ENDFORM.                    " DEL_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*&      Form  DEL_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*       delete details table data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_zmm_dvencrt.
  CLEAR : wa_vend,ist_zmm_dvencrt,ist_temp.
  REFRESH :ist_zmm_dvencrt,ist_temp.

  IF NOT zmm_hvencrt-reqno IS INITIAL AND
     NOT ist_vend[] IS INITIAL.
    IF g_trans_mode = 'M'.
      LOOP AT ist_vend INTO wa_vend WHERE vend-del_flag = 'X'.
        DELETE FROM zmm_dvencrt WHERE reqno = zmm_hvencrt-reqno AND
                                      seqno = wa_vend-vend-seqno.

        IF NOT sy-subrc IS INITIAL.
          g_crt3 = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      DELETE FROM zmm_dvencrt WHERE reqno = zmm_hvencrt-reqno.
      IF NOT sy-subrc IS INITIAL.
        g_crt3 = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " DEL_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*&      Form  RELEASE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_request.
  DATA : l_err_flag.

  IF NOT ist_vend[] IS INITIAL.
    LOOP AT ist_vend WHERE vend-rsn <> ' '.
      MESSAGE w848(zmm).
      l_err_flag = 'X'.
      EXIT.
    ENDLOOP.
  ENDIF.
  CHECK l_err_flag IS INITIAL.
  CLEAR g_ok_9000.
  g_src = '3'.
  CALL SCREEN '9000' STARTING AT 15 10  ENDING AT 95 15.
  CLEAR g_src.
  g_ok_9000 = sy-ucomm.
  CHECK g_ok_9000 = 'AGR'.
  CLEAR g_ok_9000.
  """"""""""""""""""""""""""""""""""""""
  "added by lipsy on 6.7.2015 RD1K997727

***  PERFORM check_attachment_pan. commendted by cab_dns
  "end of addition by lipsy on 6.7.2015 RD1K997727
  """""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM lock_table.
  PERFORM rel_zmm_hvencrt ON COMMIT.
  IF g_crt1 IS INITIAL AND
     g_crt2 IS INITIAL.
    COMMIT WORK.
    g_mess = 'successfuly'.
    CONCATENATE ' ' g_mess ' ' INTO g_mess.
    MESSAGE s736(zmm) WITH zmm_hvencrt-reqno g_mess.
  ELSE.
    g_mess = 'error in releasing'.
    CONCATENATE ' ' g_mess ' ' INTO g_mess.
    MESSAGE e736(zmm) WITH zmm_hvencrt-reqno g_mess.
  ENDIF.
  PERFORM unlock_table.

ENDFORM.                    " RELEASE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  rel_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rel_zmm_hvencrt.
  zmm_hvencrt-rel_flag = 'X'.
  zmm_hvencrt-release_date = sy-datum.
  zmm_hvencrt-released_by = sy-uname.
  IF zmm_hvencrt-ass_flag <> ' '.
    zmm_hvencrt-reqcl = 'IC'.
  ELSE.
    zmm_hvencrt-reqcl = 'N'.
  ENDIF.
  MODIFY zmm_hvencrt.
  IF NOT sy-subrc IS INITIAL.
    g_crt1 = 'X'.
  ENDIF.
ENDFORM.                    " rel_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*&      Form  CHANGE_REQUEST
*&---------------------------------------------------------------------*
*       Chnage request
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_request.
  PERFORM compare_req_data.
  PERFORM check_mandatory_fields.
  IF flag_gst EQ 0.

    PERFORM confirm_user_action USING text-011 text-012.
    IF g_ans = '1'.
      MESSAGE i803(zmm) WITH text-100.
      PERFORM modify_db.
    ENDIF.

  ENDIF.
ENDFORM.                    " CHANGE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  compare_req_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM compare_req_data.
*  DATA  : BEGIN OF l_ist_vend OCCURS 0,
*            mark,
*            vend LIKE zmm_dvencrt,
*            sortl LIKE lfa1-sortl,
*            fnd_flg,               "'X' - FOUND 'Y'-NFOUND
*           END OF l_ist_vend .

  DATA :
    l_vend           LIKE STANDARD TABLE OF ist_vend-vend WITH HEADER LINE,
    l_ist_zmmdvencrt LIKE STANDARD TABLE OF zmm_dvencrt WITH HEADER
LINE.

  SELECT * FROM zmm_dvencrt INTO TABLE l_ist_zmmdvencrt WHERE
                                        reqno = zmm_hvencrt-reqno AND
                                        lifnr = ' '.

  IF sy-subrc IS INITIAL.
    LOOP AT ist_vend.
      MOVE-CORRESPONDING ist_vend-vend TO l_vend.
      APPEND l_vend.
    ENDLOOP.
    IF l_vend[] = l_ist_zmmdvencrt[] AND
       g_ltext_mod IS INITIAL.  "#EC CI_NOORDER
      """"""""""""""""""""""""""""""""
      """"""""""""""""""""ADD BY LIPSY
      IF  sy-uname+0(3) = 'CMM'.
      ELSE.
        "EADD BY LIPSY
        """""""""""""""""""""""""""""
        MESSAGE e740(zmm).

        """""""""""""""
        "ADD BY LIPSY
      ENDIF.
      "EADD BY LIPSY
      """"""""""""""""""""""
    ENDIF.
  ENDIF.

ENDFORM.                    " compare_req_data
*&---------------------------------------------------------------------*
*&      Form  SEARCH_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*       check z table for open vendor requests
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_zmm_dvencrt.

  DATA l_name1_name2(100).

  CLEAR ist_vendor.
  REFRESH ist_vendor.

  IF g_trans_mode = 'N' OR
     g_trans_mode = 'M'.

    LOOP AT ist_vend INTO wa_vend WHERE fnd_flg = ' '.

      IF NOT wa_vend-vend-name1 IS INITIAL AND
         NOT wa_vend-vend-name2 IS INITIAL AND
         NOT wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
        TRANSLATE wa_vend-vend-name2 TO UPPER CASE.
        TRANSLATE wa_vend-vend-ort01 TO UPPER CASE.

*{- comment on 6/6/6
*        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
*                            TABLE ist_vendor WHERE
**        ( name1 = wa_vend-vend-name1 OR name2 = wa_vend-vend-name2 )
**AND
*          name1 = wa_vend-vend-name1 AND
*          name2 = wa_vend-vend-name2  AND
*          ort01 = wa_vend-vend-ort01 AND
*          lifnr = ' ' AND del_flag = ' ' .
*}- comment on 6/6/6
*{+ add on 6/6/6

        CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
        CONCATENATE wa_vend-vend-name2 '%' INTO wa_vend-vend-name2.
        CONCATENATE '%' wa_vend-vend-ort01 '%' INTO wa_vend-vend-ort01.

        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
          name1 LIKE wa_vend-vend-name1 AND
          name2 LIKE wa_vend-vend-name2  AND
          ort01 LIKE wa_vend-vend-ort01 AND
          lifnr = ' ' AND del_flag = ' ' .

        CONCATENATE wa_vend-vend-name1 wa_vend-vend-name2 INTO l_name1_name2.

        SELECT * FROM zmm_dvencrt APPENDING CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
          name1 LIKE l_name1_name2 AND
          ort01 LIKE wa_vend-vend-ort01 AND
          lifnr = ' ' AND del_flag = ' ' .

*}+add on 6/6/6

      ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
             NOT wa_vend-vend-name2 IS INITIAL AND
                 wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
        TRANSLATE wa_vend-vend-name2 TO UPPER CASE.

        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
*      ( name1 = wa_vend-vend-name1 OR name2 = wa_vend-vend-name2 )  AND
          name1 = wa_vend-vend-name1 AND
          name2 = wa_vend-vend-name2  AND
           lifnr = ' ' AND del_flag = ' ' .

      ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
                 wa_vend-vend-name2 IS INITIAL AND
                 wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.


        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
           name1 = wa_vend-vend-name1 AND
           lifnr = ' ' AND
           del_flag = ' ' .

      ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
                wa_vend-vend-name2 IS INITIAL AND
             NOT wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
        TRANSLATE wa_vend-vend-ort01 TO UPPER CASE.

*{- comment on 6/6/6
*        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
*                            TABLE ist_vendor WHERE
*                            name1 = wa_vend-vend-name1 AND
*                            ort01 = wa_vend-vend-ort01  AND
*                            lifnr = ' ' AND
*                            del_flag = ' ' .
*}- comment on 6/6/6
*{+ add on 6/6/6
        CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
        CONCATENATE '%' wa_vend-vend-ort01 '%' INTO wa_vend-vend-ort01.

        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
                            name1 LIKE wa_vend-vend-name1 AND
                            ort01 LIKE wa_vend-vend-ort01  AND
                            lifnr = ' ' AND
                            del_flag = ' ' .
*}+ add on 6/6/6

      ENDIF.

*      IF sy-subrc IS INITIAL.                              "-rk002
      IF NOT ist_vendor[] IS INITIAL.                       "+rk002
        LOOP AT ist_vendor.
          SELECT SINGLE reqcl FROM zmm_hvencrt INTO @DATA(v_reqst) WHERE reqno = @ist_vendor-reqno.  "#EC CI_NOORDER
          IF v_reqst NE 'R'.
            MESSAGE w735(zmm) WITH text-089.
            PERFORM popup_hitlist TABLES ist_vendor
                                  USING 'ZMM_ADDREQ' text-037  '1'.
            g_ok_9000 = sy-ucomm.
            EXIT.  "#EC CI_NOORDER
          ELSE.
            DELETE ist_vendor INDEX sy-tabix.  "#EC CI_NOORDER
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ELSEIF g_trans_mode = 'A'.

    LOOP AT ist_vend INTO wa_vend.

      IF NOT wa_vend-vend-name1 IS INITIAL AND
         NOT wa_vend-vend-name2 IS INITIAL AND
         NOT wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
        TRANSLATE wa_vend-vend-name2 TO UPPER CASE.
        TRANSLATE wa_vend-vend-ort01 TO UPPER CASE.
*{- comment on 6/6/6
*        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
*                            TABLE ist_vendor WHERE
**        ( name1 = wa_vend-vend-name1 OR name2 = wa_vend-vend-name2 )
**AND
*          name1 = wa_vend-vend-name1 AND
*          name2 = wa_vend-vend-name2  AND
*          ort01 = wa_vend-vend-ort01 AND
*          reqno <> wa_vend-vend-reqno AND
*          lifnr = ' ' AND del_flag = ' ' .

*}- comment on 6/6/6
*{+ add on 6/6/6

        CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
        CONCATENATE wa_vend-vend-name2 '%' INTO wa_vend-vend-name2.
        CONCATENATE '%' wa_vend-vend-ort01 '%' INTO wa_vend-vend-ort01.

        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
          name1 LIKE wa_vend-vend-name1 AND
          name2 LIKE wa_vend-vend-name2  AND
          ort01 LIKE wa_vend-vend-ort01 AND
          reqno <> wa_vend-vend-reqno AND
          lifnr = ' ' AND del_flag = ' ' .

        CONCATENATE wa_vend-vend-name1 wa_vend-vend-name2 INTO l_name1_name2.

        SELECT * FROM zmm_dvencrt APPENDING CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
          name1 LIKE l_name1_name2 AND
          reqno <> wa_vend-vend-reqno AND
          ort01 LIKE wa_vend-vend-ort01 AND
          lifnr = ' ' AND del_flag = ' ' .
*}+add on 6/6/6

      ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
             NOT wa_vend-vend-name2 IS INITIAL AND
                 wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
        TRANSLATE wa_vend-vend-name2 TO UPPER CASE.

        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
*      ( name1 = wa_vend-vend-name1 OR name2 = wa_vend-vend-name2 )  AND
           name1 = wa_vend-vend-name1 AND
           name2 = wa_vend-vend-name2  AND
           reqno <> wa_vend-vend-reqno AND
           lifnr = ' ' AND del_flag = ' ' .

      ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
                 wa_vend-vend-name2 IS INITIAL AND
                 wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.


        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
           name1 = wa_vend-vend-name1 AND
           reqno <> wa_vend-vend-reqno AND
           lifnr = ' ' AND
           del_flag = ' ' .

      ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
                wa_vend-vend-name2 IS INITIAL AND
             NOT wa_vend-vend-ort01 IS INITIAL.

        TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
        TRANSLATE wa_vend-vend-ort01 TO UPPER CASE.
*{- comment on 6/6/6
        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
                            name1 = wa_vend-vend-name1 AND
                            ort01 = wa_vend-vend-ort01  AND
                            reqno <> wa_vend-vend-reqno AND
                            lifnr = ' ' AND
                            del_flag = ' ' .
*}- comment on 6/6/6
*{+ add on 6/6/6
        CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
        CONCATENATE '%' wa_vend-vend-ort01 '%' INTO wa_vend-vend-ort01.

        SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF
                            TABLE ist_vendor WHERE
                            name1 LIKE wa_vend-vend-name1 AND
                            ort01 LIKE wa_vend-vend-ort01  AND
                            reqno <> wa_vend-vend-reqno AND
                            lifnr = ' ' AND
                            del_flag = ' ' .
*}+ add on 6/6/6
      ENDIF.

      IF NOT ist_vendor[] IS INITIAL.
        LOOP AT ist_vendor.
          ist_vendor-seqno = wa_vend-vend-seqno.
          MODIFY ist_vendor INDEX sy-tabix.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF sy-subrc IS INITIAL.     " and  zmm_hvencrt-reqno = ' '.


      IF ist_vendor[] IS INITIAL.
        MESSAGE i604(zmm). " WITH text-079.
        EXIT.
      ELSE.
        LOOP AT ist_vendor.
          SELECT SINGLE reqcl FROM zmm_hvencrt INTO @DATA(v_reqsta) WHERE reqno = @ist_vendor-reqno.  "#EC CI_NOORDER
          IF v_reqsta NE 'R'.
            PERFORM popup_hitlist TABLES ist_vendor
                                  USING 'ZMM_ADDREQ' text-037  '4'.
            g_ok_9000 = sy-ucomm.
            EXIT.  "#EC CI_NOORDER
          ELSE.
            DELETE ist_vendor INDEX sy-tabix.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.


  ENDIF.

ENDFORM.                    " SEARCH_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*&      Form  BDC_MK01
*&---------------------------------------------------------------------*
*       Create Vendor run bdc for tcode mk01
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_mk01.
  IF NOT ist_vend[] IS INITIAL.
    PERFORM check_mandatory_fields.
    IF  g_rej_all IS INITIAL.
      PERFORM confirm_user_action USING text-015 text-018.
    ELSE.
      PERFORM confirm_user_action USING text-015 text-016.
    ENDIF.
    IF g_ans = '1'.
      PERFORM run_bdc.
      PERFORM ass_zmm_hvencrt ON COMMIT.
      PERFORM ass_zmm_dvencrt ON COMMIT.
      IF g_crt1 IS INITIAL AND
         g_crt2 IS INITIAL.
        COMMIT WORK.

        """""""""""""""""""""""""""""""""""""""""""""""""""""
*        "added by lipsy on 18.09.2015 for srm vendor replicate RD1K998437

        """""""""""""""""""""""""""""""""""""""""
        "added by lipsy on 12.11.2015 RD1K999141

        IF  zmm_hvencrt-ass_flag = 'F' AND    "FULL ASSIGNMENT OF REQUEST
         zmm_hvencrt-reqcl = 'C'.
          "end of addition by lipsy on 12.11.2015 RD1K999141
          """"""""""""""""""""""""""""""""""""""""""""""
          IF zmm_hvencrt-srmid IS NOT INITIAL.
            PERFORM replicate_vendors_srm.
          ENDIF.

          """"""""""""""""""""""""
          "added by lipsy on 12.11.2015 RD1K999141
        ELSE.
        ENDIF.
        "end of addition by lipsy on 12.11.2015 RD1K999141

        """""""""""""""""""""""""""""""""""""""
*        "end of addition by lipsy on 18.09.2015 for srm vendor replicate RD1K998437
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ELSE.
        MESSAGE e735(zmm) WITH text-020.
      ENDIF.
    ELSE.
      g_no_vend = 1.
    ENDIF.
  ENDIF.

*  IF g_no_vend EQ 1.
*    MESSAGE i735(zmm) WITH text-021.
*  ELSE.
*    MESSAGE s744(zmm) WITH g_str zmm_hvencrt-reqno.
*  ENDIF.

  PERFORM unlock_table.

ENDFORM.                                                    " BDC_MK01
*&---------------------------------------------------------------------*
*&      Form  run_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM   run_bdc.
*Begin of <RD1K960611>.
*  DATA :
*    l_kalsk(2) TYPE n,
*    l_fdgrv TYPE lfb1-fdgrv.
*  CLEAR :
*    ist_vend, l_kalsk, ist_bdcdata.
*  REFRESH:
*    ist_bdcdata.
*
*
*  IF zmm_hvencrt-ktokk+3(1) = 'I'.
*    l_kalsk = '01'.
*  ELSE.
*    l_kalsk = '02'.
*  ENDIF.
*
*  CASE zmm_hvencrt-ktokk.
*    WHEN 'IMMI'.
*      l_fdgrv = 'DO'.
*    WHEN 'IMMF'.
*      l_fdgrv = 'FO'.
*    WHEN 'SVWI'.
*      l_fdgrv = 'DL'.
*    WHEN 'SVWF'.
*      l_fdgrv = 'FL'.
*  ENDCASE.
*
*  LOOP AT ist_vend WHERE vend-rsn = ' '.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0100'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'USE_ZAV'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RF02K-BUKRS'
*                                  zmm_hvencrt-bukrs.
*    PERFORM bdc_field       USING 'RF02K-EKORG'
*                                  zmm_hvencrt-ekorg.
*    PERFORM bdc_field       USING 'RF02K-KTOKK'
*                                  zmm_hvencrt-ktokk.
*    PERFORM bdc_field       USING 'USE_ZAV'
*                                  'X'.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=$2OC'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'ADDR1_DATA-REGION'.
*    PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
*                                 ist_vend-vend-name1.
*    PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
*                                  ist_vend-vend-name2.
*    PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'
*                                  ist_vend-vend-sortl.
*    PERFORM bdc_field       USING 'ADDR1_DATA-POST_CODE1'
*                                  ist_vend-vend-pstlz.
*    PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
*                                  ist_vend-vend-ort01.
*    PERFORM bdc_field       USING 'ADDR1_DATA-COUNTRY'
*                                  ist_vend-vend-land1.
*    PERFORM bdc_field       USING 'ADDR1_DATA-REGION'
*                                   ist_vend-vend-regio.
*    PERFORM bdc_field       USING 'SZA1_D0100-TEL_NUMBER'
*                                      ist_vend-vend-telf1.
*    PERFORM bdc_field       USING 'SZA1_D0100-FAX_NUMBER'
*                                  ist_vend-vend-telfx+0(26).
*    PERFORM bdc_field       USING 'SZA1_D0100-SMTP_ADDR'
*                                      ist_vend-vend-email.
**---
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'ADDR1_DATA-LOCATION'.
*    PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL1'
*                                  ist_vend-vend-suppl1.
*    PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL2'
*                                  ist_vend-vend-suppl2.
*    PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
*                                  ist_vend-vend-stras1.
*    PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL3'
*                                  ist_vend-vend-suppl3.
*    PERFORM bdc_field       USING 'ADDR1_DATA-LOCATION'
*                                  ist_vend-vend-ort02.
*
**---
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0120'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFA1-BRSCH'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'LFA1-BRSCH'
*                                  ist_vend-vend-brsch.
*    PERFORM bdc_field       USING 'LFA1-STCD1'
*                                  ist_vend-vend-stcd1.
*    PERFORM bdc_field       USING 'LFA1-STCD2'
*                                      ist_vend-vend-stcd2.
*    IF  zmm_hvencrt-ktokk = 'IMMI' OR
*        zmm_hvencrt-ktokk = 'IMMF'.
*
*      PERFORM bdc_field       USING 'LFA1-J_1KFTBUS'
*                                        ist_vend-vend-j_1kftbus.
*    ENDIF.
*
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFA1-XZEMP'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=ENTR'.
*    PERFORM bdc_field       USING 'LFA1-XZEMP'
*                                  'X'.
*    IF NOT ist_vend-vend-banks IS INITIAL AND
*       NOT ist_vend-vend-bankl IS INITIAL AND
*       NOT ist_vend-vend-bankn IS INITIAL.
*
*      PERFORM bdc_field       USING 'LFBK-BANKS(01)'
*                                    ist_vend-vend-banks.
*      PERFORM bdc_field       USING 'LFBK-BANKL(01)'
*                                    ist_vend-vend-bankl.
*      PERFORM bdc_field       USING 'LFBK-BANKN(01)'
*                                    ist_vend-vend-bankn.
*      PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
*      PERFORM bdc_field       USING 'BDC_CURSOR'
*                                    'LFBK-BANKS(01)'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '=ENTR'.
*      PERFORM bdc_field       USING 'LFA1-XZEMP'
*                                    'X'.
*    ENDIF.
*
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0210'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFB1-FDGRV'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    IF  zmm_hvencrt-ktokk = 'IMMI' OR
*        zmm_hvencrt-ktokk = 'SVWI'.
*
*      PERFORM bdc_field       USING 'LFB1-AKONT'
*                                    '190101'.
*    ELSE.
*      PERFORM bdc_field       USING 'LFB1-AKONT'
*                                    '190104'.
*
*    ENDIF.
*    PERFORM bdc_field       USING 'LFB1-ZUAWA'
*                                  '014'.
*
*    PERFORM bdc_field       USING 'LFB1-FDGRV'
*                                  l_fdgrv.
*
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0215'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFB1-REPRF'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'LFB1-ZTERM'
*                                  '0001'.
*    PERFORM bdc_field       USING 'LFB1-REPRF'
*                                  'X'.
**+SP011- In case of company code 'OVL',set payment method value to be
**      '9' - start
*    if zmm_hvencrt-bukrs = 'OVL'.
*
*      PERFORM bdc_field       USING 'LFB1-ZWELS'
*                                    '9'.
*    else.
**+SP011- end
*
**+SP009 - Update Payment Methods based on Bank Key
*      if ist_vend-vend-bankl = ' '.
*
*        PERFORM bdc_field       USING 'LFB1-ZWELS'
*                                      'C'.
*      else.
*
*        if ist_vend-vend-bankl+0(4) = text-086.
*
*          PERFORM bdc_field       USING 'LFB1-ZWELS'
*                                        'S'.
*        else.
*
*          PERFORM bdc_field       USING 'LFB1-ZWELS'
*                                        'N'.
*        endif.
*
*      endif.
**+SP009 - end
*    endif.                                                  "+SP011
*
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0220'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFB1-EIKTO'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    IF zmm_hvencrt-ekorg <> 'POBV'.
*      PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '/00'.
*      PERFORM bdc_field       USING 'BDC_CURSOR'
*                                    'LFB1-QLAND'.
*    ENDIF.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0310'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFM1-WEBRE'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'LFM1-WAERS'
*                                  ist_vend-vend-waers.
*    PERFORM bdc_field       USING 'LFM1-KALSK'
*                                  l_kalsk.
*    IF zmm_hvencrt-ktokk = 'IMMI' OR zmm_hvencrt-ktokk = 'SVWI'.
*
*      PERFORM bdc_field       USING 'LFM1-WEBRE'
*                                    'X'.
*    ENDIF.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0320'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF02K-LIFNR'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=UPDA'.
*
*    PERFORM background TABLES ist_bdcstatus2
*                                       USING  'XK01'        " s_tcode
*                                               'N'          " s_mode
*                                               'A'          " s_update
*                                               zmm_hvencrt-reqno
*                                               ' '.
*
*    CLEAR :ist_vend,ist_bdcdata.
*    REFRESH ist_bdcdata.
*
*  ENDLOOP.
  DATA :
    l_kalsk(2) TYPE n,
    l_fdgrv    TYPE lfb1-fdgrv.
  CLEAR :
    ist_vend, l_kalsk, ist_bdcdata.
  REFRESH:
    ist_bdcdata.
* Begin of <> on 17122010
  IF zmm_hvencrt-ktokk = 'IMMF' OR zmm_hvencrt-ktokk = 'SVWF'.
    l_kalsk = '02'.
  ELSE.
    l_kalsk = '01'.
  ENDIF.
*  IF zmm_hvencrt-ktokk+3(1) = 'I'.
*    l_kalsk = '01'.
*  ELSE.
*    l_kalsk = '02'.
*  ENDIF.
* End of <> on 17122010
  CASE zmm_hvencrt-ktokk.
    WHEN 'IMMI'.
      l_fdgrv = 'DO'.
    WHEN 'IMMF'.
      l_fdgrv = 'FO'.
    WHEN 'SVWI'.
      l_fdgrv = 'DL'.
    WHEN 'SVWF'.
      l_fdgrv = 'FL'.

* Begin of <> on 17122010
    WHEN OTHERS.
      l_fdgrv = 'DO'.
* End of <> on 17122010
  ENDCASE.
*{   INSERT         OCPK900113                                        2

*}   INSERT
  DATA val TYPE c LENGTH 13.
  val = zmm_hvencrt-udyog_aadhaar+6.
  LOOP AT ist_vend WHERE vend-rsn = ' '.
* Begin of <> on 17122010
    IF    zmm_hvencrt-ktokk = 'LEA1' OR
          zmm_hvencrt-ktokk = 'LEA2' OR
          zmm_hvencrt-ktokk = 'CONT' OR
          zmm_hvencrt-ktokk = 'LAQ1' OR
          zmm_hvencrt-ktokk = 'GOVT' OR
          zmm_hvencrt-ktokk = 'INVT' OR
          zmm_hvencrt-ktokk = 'SUBD' OR
          zmm_hvencrt-ktokk = 'UTLT' OR
          zmm_hvencrt-ktokk = 'TRNI'.
* TRNI value added by Ruhani Garg on 07.05.2019

**BOC by SS on 21.3.211
*      IF ZMM_HVENCRT-BUKRS = 'OVC'.
*        PERFORM F_BDC_XK01_OVC.
*      ELSE.
**EOC by SS on 21.3.211


      PERFORM bdc_dynpro      USING 'SAPMF02K' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'USE_ZAV'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'RF02K-BUKRS'
                                    zmm_hvencrt-bukrs.
      PERFORM bdc_field       USING 'RF02K-EKORG'
                                    zmm_hvencrt-ekorg.
      PERFORM bdc_field       USING 'RF02K-KTOKK'
                                    zmm_hvencrt-ktokk.
      PERFORM bdc_field       USING 'USE_ZAV'
                                    'X'.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=$2OC'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'ADDR1_DATA-REGION'.
      PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
                                   ist_vend-vend-name1.
      PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
                                    ist_vend-vend-name2.
      PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'
                                    ist_vend-vend-sortl.
      PERFORM bdc_field       USING 'ADDR1_DATA-POST_CODE1'
                                    ist_vend-vend-pstlz.
      PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
                                    ist_vend-vend-ort01.
      PERFORM bdc_field       USING 'ADDR1_DATA-COUNTRY'
                                    ist_vend-vend-land1.
      PERFORM bdc_field       USING 'ADDR1_DATA-REGION'
                                     ist_vend-vend-regio.
      PERFORM bdc_field       USING 'SZA1_D0100-TEL_NUMBER'
                                        ist_vend-vend-telf1.

      PERFORM bdc_field       USING 'SZA1_D0100-MOB_NUMBER'
                                        ist_vend-vend-mob_number.

      PERFORM bdc_field       USING 'SZA1_D0100-FAX_NUMBER'
                                    ist_vend-vend-telfx+0(26)."rohit comment 8-12-2025
      PERFORM bdc_field       USING 'SZA1_D0100-SMTP_ADDR'
                                        ist_vend-vend-email.

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'ADDR1_DATA-LOCATION'.
      PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL1'
                                    ist_vend-vend-suppl1.
      PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL2'
                                    ist_vend-vend-suppl2.
      PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
                                    ist_vend-vend-stras1.
      PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL3'
                                    ist_vend-vend-suppl3.
      PERFORM bdc_field       USING 'ADDR1_DATA-LOCATION'
                                    ist_vend-vend-ort02.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0120'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'LFA1-J_1KFTIND'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '/00'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFA1-BRSCH'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFA1-BRSCH'
                                    ist_vend-vend-brsch.
**************************************************************************
      PERFORM bdc_field       USING 'LFA1-STCD5'
                                   ist_vend-vend-cin_number.
**************************************************************************
      PERFORM bdc_field       USING 'LFA1-J_1KFTBUS'
                                     ist_vend-vend-j_1kftbus.
*{   INSERT         OCPK900113                                        4
      PERFORM bdc_field       USING 'LFA1-STCD3'
                                 ist_vend-vend-gst_no.

      """"""""""""""""add by Rohit on 21.03.2025

      PERFORM bdc_field       USING 'LFA1-STENR'
                                      val.
      " zmm_hvencrt-udyog_aadhaar." comment by rohit
      """""""""""""""""""""""""""""""end of change by rohit on 21.03.2025.
*}   INSERT
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFA1-XZEMP'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM bdc_field       USING 'LFA1-XZEMP'
                                     'X'.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0380'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'KNVK-NAMEV(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0210'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-FDGRV'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFB1-AKONT'
                                     '190101'.
      PERFORM bdc_field       USING 'LFB1-ZUAWA'
                                     '012'.
      PERFORM bdc_field       USING 'LFB1-FDGRV'
                                     l_fdgrv.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0215'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-ZWELS'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFB1-ZTERM'
                                    '0001'.
      PERFORM bdc_field       USING 'LFB1-REPRF'
                                     'X'.


* Begin of <> 09072012
*      IF zmm_hvencrt-ktokk = 'GOVT' .
*        perform bdc_field       using 'LFB1-ZWELS'
*                                      'T'.
*      ELSEIF zmm_hvencrt-ktokk = 'UTLT' .
*        perform bdc_field       using 'LFB1-ZWELS'
*                                      'U'.
*      ELSE.
*        perform bdc_field       using 'LFB1-ZWELS'
*                                     'C'.
*      ENDIF.
      PERFORM bdc_field       USING 'LFB1-ZWELS'
                              'C'.

* End of <> on 09072012
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0220'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-EIKTO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RF02K-LIFNR'.

      PERFORM bdc_field       USING 'LFB1-QLAND'
                                        'IN'.
*perform bdc_transaction using 'XK01'.

    ELSE.
* End of <> on 17122010

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'USE_ZAV'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'RF02K-BUKRS'
                                    zmm_hvencrt-bukrs.
      PERFORM bdc_field       USING 'RF02K-EKORG'
                                    zmm_hvencrt-ekorg.
      PERFORM bdc_field       USING 'RF02K-KTOKK'
                                    zmm_hvencrt-ktokk.
      PERFORM bdc_field       USING 'USE_ZAV'
                                    'X'.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=$2OC'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'ADDR1_DATA-REGION'.
      PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
                                   ist_vend-vend-name1.
      PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
                                    ist_vend-vend-name2.
      PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'
                                    ist_vend-vend-sortl.
      PERFORM bdc_field       USING 'ADDR1_DATA-POST_CODE1'
                                    ist_vend-vend-pstlz.
      PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
                                    ist_vend-vend-ort01.
      PERFORM bdc_field       USING 'ADDR1_DATA-COUNTRY'
                                    ist_vend-vend-land1.
      PERFORM bdc_field       USING 'ADDR1_DATA-REGION'
                                     ist_vend-vend-regio.
      PERFORM bdc_field       USING 'SZA1_D0100-TEL_NUMBER'
                                        ist_vend-vend-telf1.
*+SP013 - Mobile Number
      PERFORM bdc_field       USING 'SZA1_D0100-MOB_NUMBER'
                                        ist_vend-vend-mob_number.
*+SP013 - End
      PERFORM bdc_field       USING 'SZA1_D0100-FAX_NUMBER'
                                    ist_vend-vend-telfx+0(26).
      PERFORM bdc_field       USING 'SZA1_D0100-SMTP_ADDR'
                                        ist_vend-vend-email.
*---
**  not in ovc bdc recording ++
*      IF  ZMM_HVENCRT-BUKRS <> 'OVC'."added by ss on 21.3.21 " commented on 23.3.21
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'ADDR1_DATA-LOCATION'.
      PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL1'
                                    ist_vend-vend-suppl1.
      PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL2'
                                    ist_vend-vend-suppl2.
      PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
                                    ist_vend-vend-stras1.
      PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL3'
                                    ist_vend-vend-suppl3.
      PERFORM bdc_field       USING 'ADDR1_DATA-LOCATION'
                                    ist_vend-vend-ort02.
*      ENDIF."added by ss on 21.3.21 " commented on 23.3.21
**  not in ovc bdc recording end

*---
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0120'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFA1-BRSCH'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFA1-BRSCH'
                                    ist_vend-vend-brsch.
**        incase of OVC skip below fields
      IF zmm_hvencrt-bukrs <> 'OVC'. "added by ss on 21.3.21
        PERFORM bdc_field       USING 'LFA1-STCD1'
                                      ist_vend-vend-stcd1.
        PERFORM bdc_field       USING 'LFA1-STCD2'
                                          ist_vend-vend-stcd2.
*{   INSERT         OCPK900113                                        6
        PERFORM bdc_field       USING 'LFA1-STCD3'
                                           ist_vend-vend-gst_no.

        """"""""""""""""add by Rohit on 21.03.2025

        PERFORM bdc_field       USING 'LFA1-STENR'
                            val." zmm_hvencrt-udyog_aadhaar.
        """""""""""""""""""""""""""""""end of change by rohit on 21.03.2025.
*}   INSERT
      ENDIF. "added by ss on 21.3.21

**************************************************************************
      PERFORM bdc_field       USING 'LFA1-STCD5'
                                   ist_vend-vend-cin_number.
**************************************************************************
**        Skip ended
      IF  zmm_hvencrt-ktokk = 'IMMI' OR
          zmm_hvencrt-ktokk = 'IMMF'.

        PERFORM bdc_field       USING 'LFA1-J_1KFTBUS'
                                          ist_vend-vend-j_1kftbus.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFA1-XZEMP'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM bdc_field       USING 'LFA1-XZEMP'
                                    'X'.
      IF NOT ist_vend-vend-banks IS INITIAL AND
         NOT ist_vend-vend-bankl IS INITIAL AND
         NOT ist_vend-vend-bankn IS INITIAL.

        PERFORM bdc_field       USING 'LFBK-BANKS(01)'
                                      ist_vend-vend-banks.
        PERFORM bdc_field       USING 'LFBK-BANKL(01)'
                                      ist_vend-vend-bankl.
        PERFORM bdc_field       USING 'LFBK-BANKN(01)'
                                      ist_vend-vend-bankn.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFBK-BANKS(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTR'.
        PERFORM bdc_field       USING 'LFA1-XZEMP'
                                      'X'.
      ENDIF.
*Begin of <RD1K960611>.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0380'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTR'.
*End of <RD1K960611>.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0210'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-FDGRV'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      IF  zmm_hvencrt-ktokk = 'IMMI' OR
          zmm_hvencrt-ktokk = 'SVWI' OR
* BEgin of <. on 17122010
          zmm_hvencrt-ktokk = 'LEA1' OR
          zmm_hvencrt-ktokk = 'LEA2' OR
          zmm_hvencrt-ktokk = 'CONT' OR
          zmm_hvencrt-ktokk = 'LAQ1' OR
          zmm_hvencrt-ktokk = 'INVT' OR
          zmm_hvencrt-ktokk = 'SUBD' OR
          zmm_hvencrt-ktokk = 'UTLT' OR
          zmm_hvencrt-ktokk = 'TRNI'.
* TRNI value added by RUhani Garg on 07.05.2019

* End of <> on 17122010
**check with sandeep if he needs the same conditions for AKONT or check on Bukrs and pass 190101 in akont
        PERFORM bdc_field       USING 'LFB1-AKONT'
                                      '190101'.
      ELSE.
        PERFORM bdc_field       USING 'LFB1-AKONT'
                                      '190104'.

      ENDIF.
      PERFORM bdc_field       USING 'LFB1-ZUAWA'
                                    '014'.

      PERFORM bdc_field       USING 'LFB1-FDGRV'
                                    l_fdgrv.

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0215'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-REPRF'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFB1-ZTERM'
                                    '0001'.
      PERFORM bdc_field       USING 'LFB1-REPRF'
                                    'X'.
*+SP011- In case of company code 'OVL',set payment method value to be
*      '9' - start
*      *******SOC BY ROHIT ON 14-06-2024

      SELECT SINGLE * FROM setleaf INTO @DATA(wa_cc) WHERE setname = 'ZFI_BCM_PM_BUKRS' AND valfrom = @zmm_hvenext-bukrs.
      IF sy-subrc = 0.

*** EOC BY ROHIT ON 14-06-2024

**      IF zmm_hvencrt-bukrs = 'OVL'.

*+SP012 - Update Payment Methods based on Bank Key for company code
*        'OVL' - start

*      PERFORM bdc_field       USING 'LFB1-ZWELS'
*                                    '9'.                    "-SP012

        IF ist_vend-vend-bankl = ' '.

          PERFORM bdc_field       USING 'LFB1-ZWELS'
                                        'C'.
        ELSE.

          IF ist_vend-vend-bankl+0(4) = text-086.

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          '9'.
          ELSE.

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          '8'.
          ENDIF.

        ENDIF.

*+SP012- end
**BOC by ss on 21.3.21
      ELSEIF zmm_hvencrt-bukrs = 'OVC'.
        PERFORM bdc_field       USING 'LFB1-ZWELS'
                                        'C'.
**EOC by ss on 21.3.21
      ELSE.
*+SP011- end

*+SP009 - Update Payment Methods based on Bank Key
        IF ist_vend-vend-bankl = ' '.

          PERFORM bdc_field       USING 'LFB1-ZWELS'
                                        'C'.
        ELSE.

          IF ist_vend-vend-bankl+0(4) = text-086.

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          'S'.
          ELSE.

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          'N'.
          ENDIF.

        ENDIF.
*    *+SP009 - end
      ENDIF.                                                "+SP011

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0220'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-EIKTO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
* Begin of <> on 17122010
      IF zmm_hvencrt-bukrs <> 'OVC'."add by ss

        IF NOT zmm_hvencrt-ekorg IS INITIAL.
* End of <> on 17122010
          IF zmm_hvencrt-ekorg <> 'POBV'.
            PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
*            PERFORM bdc_field       USING 'BDC_CURSOR'
*                                          'LFB1-QLAND'
*                                          'IN'.
            PERFORM bdc_field       USING 'LFB1-QLAND'
                                              'IN'.                  " CHANGE BY ROHIT ON 10.05.2024
          ENDIF.
        ENDIF.
      ENDIF. "added by ss
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0310'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFM1-WEBRE'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFM1-WAERS'
                                    ist_vend-vend-waers.
      PERFORM bdc_field       USING 'LFM1-KALSK'
                                    l_kalsk.
      IF zmm_hvencrt-ktokk = 'IMMI' OR zmm_hvencrt-ktokk = 'SVWI'.

        PERFORM bdc_field       USING 'LFM1-WEBRE'
                                      'X'.
      ENDIF.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0320'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RF02K-LIFNR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=UPDA'.
    ENDIF.
*    ENDIF."added by ss
*Begin RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
    DATA s_mode(1).
*{   REPLACE        OCPK900113                                        3
*\    s_mode = 'N'. " 'A'.




    s_mode = 'N'.
*}   REPLACE
*End RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919

                                                            "17122010
    PERFORM background TABLES ist_bdcstatus2
                                       USING  'XK01'        " s_tcode
                                               s_mode   " 'N'   " s_mode
*{   REPLACE        OCPK900113                                        1
*\                                               'A'          " s_update
                                               'A'          " s_update
*}   REPLACE
                                               zmm_hvencrt-reqno
                                               ' '.
*{   INSERT         OCPK900113                                        5
    DATA : wa_lfa1 TYPE lfa1,
           wa_lfbw TYPE lfbw,
           wa_lfb1 TYPE lfb1.
    DATA : wa_j_1imovend TYPE j_1imovend.  "#EC CI_USAGE_OK[2877717]


    SELECT SINGLE *
      INTO wa_lfa1
      FROM lfa1
      WHERE lifnr  = ist_vend-vend-lifnr.

*      ********************************************
*                                                        " SOC BY ROHIT ON 06-05-2024.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0106'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF02K-D0610'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RF02K-LIFNR'
*                                  ist_vend-vend-lifnr.
*    PERFORM bdc_field       USING 'RF02K-BUKRS'
*                                  'OVL'.
*    PERFORM bdc_field       USING 'RF02K-D0610'
*                                  'X'.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=ENTR'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFBW-QSREC(01)'.
*    PERFORM bdc_field       USING 'LFB1-QLAND'
*                                  'IN'.
*    PERFORM bdc_field       USING 'LFBW-WITHT(01)'
*                                  'I0'.
*    PERFORM bdc_field       USING 'LFBW-WT_SUBJCT(01)'
*                                  'X'.
*    PERFORM bdc_field       USING 'LFBW-QSREC(01)'
*                                  '00'.
*    PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=UPDA'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'LFBW-WT_SUBJCT(01)'.
*    PERFORM bdc_field       USING 'LFB1-QLAND'
*                                  'IN'.          " EOC BY ROHIT on 06-05-2024.
**      ******************************************

    IF wa_lfa1 IS NOT INITIAL.
      wa_lfa1-stcd3 = ist_vend-vend-gst_no.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFA1 BP-managed; field set via VMD_EI_API central (FORM zz_s4_lfa1_cen).
*      MODIFY lfa1 FROM wa_lfa1.
      PERFORM zz_s4_lfa1_cen USING wa_lfa1-lifnr 'STCD3' wa_lfa1-stcd3.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.

    """"""""""""""""""""""""""""""""""""""""ADD BY ROHIT ON 21.03.2025
    IF zmm_hvencrt-udyog_aadhaar IS NOT INITIAL.
      wa_lfa1-stenr = zmm_hvencrt-udyog_aadhaar.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFA1 BP-managed; field set via VMD_EI_API central (FORM zz_s4_lfa1_cen).
*      MODIFY lfa1 FROM wa_lfa1.
      PERFORM zz_s4_lfa1_cen USING wa_lfa1-lifnr 'STENR' wa_lfa1-stenr.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.



    """"""""""""""""""""""""""""""""""""""""ADD BY ROHIT ON 21.03.2025






    wa_lfbw-lifnr = ist_vend-vend-lifnr.    " soc by rohit on 06-05-2024.
    wa_lfbw-witht = 'I0'.
    wa_lfbw-wt_subjct = 'X'.
    wa_lfbw-qsrec = '00'.
    wa_lfbw-bukrs = zmm_hvencrt-bukrs.
    MODIFY lfbw FROM wa_lfbw.
*    WA_LFB1-LIFNR = IST_VEND-VEND-LIFNR.                " eoc by rohit on 06-05-2024.
*    wa_lfb1-qland = 'IN'.
*    MODIFY LFB1 FROM WA_LFB1.

    SELECT SINGLE *
      INTO wa_j_1imovend
      FROM j_1imovend
      WHERE lifnr  = ist_vend-vend-lifnr.

    IF wa_j_1imovend IS NOT INITIAL.
      wa_j_1imovend-ven_class = ist_vend-vend-ven_class.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: J_1IMOVEND CIN fields merged into LFA1 (BP); set VEN_CLASS via VMD_EI_API.
*      MODIFY j_1imovend FROM wa_j_1imovend.
      PERFORM zz_s4_set_ven_class USING ist_vend-vend-lifnr ist_vend-vend-ven_class.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ELSE.
      wa_j_1imovend-lifnr = ist_vend-vend-lifnr.


      wa_j_1imovend-ven_class = ist_vend-vend-ven_class..
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: J_1IMOVEND CIN fields merged into LFA1 (BP); set VEN_CLASS via VMD_EI_API.
*      MODIFY j_1imovend FROM wa_j_1imovend.
      PERFORM zz_s4_set_ven_class USING ist_vend-vend-lifnr ist_vend-vend-ven_class.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC


    ENDIF.
*}   INSERT

    CLEAR :ist_vend,ist_bdcdata.
    REFRESH ist_bdcdata.

  ENDLOOP.
*End of <RD1K960611>.
ENDFORM.                    " run_bdc

**&---------------------------------------------------------------------
*
**       BDC DYNPRO
**----------------------------------------------------------------------
*
**      -->P_0487   text
**      -->P_0488   text
**----------------------------------------------------------------------
*
FORM bdc_dynpro USING l_program l_dynpro.
  CLEAR ist_bdcdata.
  ist_bdcdata-program  = l_program.
  ist_bdcdata-dynpro   = l_dynpro.
  ist_bdcdata-dynbegin = 'X'.
  APPEND ist_bdcdata.
ENDFORM.                    " bdc_dynpro
**&---------------------------------------------------------------------
*
**       BDC FIELD
**----------------------------------------------------------------------
*
**      -->P_0501   text
**      -->P_0502   text
**----------------------------------------------------------------------
*
FORM bdc_field USING l_fnam l_fval.

  CLEAR ist_bdcdata.
  ist_bdcdata-fnam = l_fnam.
  ist_bdcdata-fval = l_fval.
  APPEND ist_bdcdata.

ENDFORM.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  background
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_BDCSTATUS2  text
*      -->P_1370   text
*      -->P_1371   text
*      -->P_1372   text
*----------------------------------------------------------------------*
FORM background TABLES   ist_xmessages STRUCTURE bdcmsgcoll
                USING    p_tcode
                         p_mode
                         p_update
                         l_reqno
                         p_flag.
  DATA: lin       LIKE sy-tfill, l_str(50).
  DATA: l_index LIKE sy-tabix.
  CLEAR g_vend_err.
  REFRESH ist_xmessages.
*  break cab_sudhir.
  CALL TRANSACTION p_tcode USING ist_bdcdata MODE p_mode
                      UPDATE p_update MESSAGES INTO ist_xmessages.
  IF sy-subrc <> 0.
    g_vend_err = 1.
  ELSE.
    IF p_tcode = 'J1ID'.
      EXIT.
    ENDIF.
    IF p_flag = 'B'.
      CONCATENATE 'VENDOR' ist_lfa1-lifnr 'BLOCKED' INTO
                  ist_bdcstatus-msgtx SEPARATED BY space.
      ist_bdcstatus-tcode = 'XK02'.  "#EC CI_USAGE_OK[2226131]
      APPEND ist_bdcstatus.
      EXIT.
    ENDIF.
  ENDIF.

  CLEAR lin.
  DESCRIBE TABLE ist_xmessages LINES lin.
  IF lin > 0.
    LOOP AT ist_xmessages.
      IF ( ist_xmessages-msgtyp = 'E' OR
           ist_xmessages-msgtyp = 'S' ) .

        MOVE-CORRESPONDING ist_xmessages TO: ist_bdcstatus, msg_log.
        ist_bdcstatus-reqno = l_reqno.
        msg_log-msgno  = ist_xmessages-msgnr.
        msg_log-msgty  = ist_xmessages-msgtyp.

        CALL FUNCTION 'MESSAGE_TEXTS_READ'
          EXPORTING
            msg_log_imp     = msg_log
*        IMPORTING
*           MSG_TEXT_EXP    = msg_text
          TABLES
            t_msg_texts_exp = ist_msg_text.
        LOOP AT ist_msg_text.
          ist_bdcstatus-indx = ist_msg_text-indx.
          ist_bdcstatus-msgtx = ist_msg_text-msgtx.
          APPEND ist_bdcstatus.
        ENDLOOP.
        CLEAR ist_msg_text.
        REFRESH ist_msg_text.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF g_vend_err = 1.
    IF p_tcode = 'J1ID'.
      ist_bdcstatus-msgtx = text-078.
      APPEND ist_bdcstatus.
      EXIT.
    ELSE.
      ist_bdcstatus-msgtx = text-054.
      APPEND ist_bdcstatus.
    ENDIF.
  ENDIF.

  IF NOT ist_vend IS INITIAL.
    LOOP AT ist_xmessages.
      IF ist_xmessages-msgtyp = 'S' AND
         ist_xmessages-msgid  = 'F2' AND
         ( ist_xmessages-msgnr  = '173' OR
           ist_xmessages-msgnr  = '175' OR
           ist_xmessages-msgnr  = '271' ) AND
         ist_xmessages-msgv1 <> ' '.
        ist_vend-vend-lifnr = ist_xmessages-msgv1.
        ist_vend-vend-ass_flag = 'X'.
        MODIFY ist_vend .
      ELSE.
        CONCATENATE ist_xmessages-msgid ist_xmessages-msgnr INTO
        ist_vend-vend-rsn.
        MODIFY ist_vend.
      ENDIF.
    ENDLOOP.
  ELSEIF NOT ist_unbl[] IS INITIAL.
    READ TABLE ist_unbl WITH KEY lifnr = ist_lfa1-lifnr.
    g_index = sy-tabix.
    LOOP AT ist_xmessages.
      IF ist_xmessages-msgtyp = 'S' AND
         ist_xmessages-msgid  = 'F2' AND
         ist_xmessages-msgnr  = '056'.
        ist_unbl-ass_flag = 'X'.
        MODIFY ist_unbl INDEX g_index TRANSPORTING ass_flag.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " background
*&---------------------------------------------------------------------*
*&      Form  disp_status
*&---------------------------------------------------------------------*
*       Display/send to mail - BDC Status in internal table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_status.
  DATA : l_no TYPE sy-tabix.
  DATA : l_thead_upd_ind  TYPE i.
  DATA : l_null(3) VALUE '0<>'.
  DATA : l_text(30).
  DATA : l_date(10).

  CLEAR ist_bdcstatus.

  DESCRIBE TABLE ist_bdcstatus LINES l_no.
  IF l_no > 0 .
*-----------------------------------------------------------*
    CLEAR ist_texttable. REFRESH ist_texttable.

    WRITE: / 'STATUS OF VENDOR CODE CREATION' COLOR COL_POSITIVE.
    ULINE.
    LOOP AT ist_bdcstatus.
      IF ist_bdcstatus-indx = '2'.
        WRITE ist_bdcstatus-msgtx.
      ELSE.
        WRITE :/ ist_bdcstatus-msgtx.
      ENDIF.
    ENDLOOP.
*---end of code add on 12/04/2006---------------------------*
  ENDIF.
  PERFORM populate_email_text USING text-060.
  REFRESH :ist_bdcstatus.
  REFRESH ist_gui .CLEAR ist_gui.

  IF ist_gui[] IS INITIAL.
    ist_gui-fcode = 'CREA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'DISP' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'REPO' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .
  ENDIF.
  SET PF-STATUS 'PF_MAIN' EXCLUDING ist_gui.
ENDFORM.                    " disp_status
*&---------------------------------------------------------------------*
*&      Form  ass_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ass_zmm_hvencrt .
  CLEAR : g_str, g_no_vend.
  READ TABLE ist_vend WITH KEY vend-lifnr = ' '.
  IF sy-subrc IS INITIAL.
    LOOP AT ist_vend WHERE vend-lifnr <> ' '.
      zmm_hvencrt-ass_flag = 'P'.   "PARTIAL ASSIGNMENT OF REQUEST
      g_str = 'Partially'.
      zmm_hvencrt-reqcl = 'IR'.
      EXIT.

    ENDLOOP.

    IF ist_vend-vend-rsn = 'B' OR ist_vend-vend-rsn = 'C'.
      zmm_hvencrt-ass_flag = 'R'.     "FULL REQUEST REJECTED
      zmm_hvencrt-reqcl = 'IR'.
      zmm_hvencrt-rejected_by = sy-uname.  " added by ss on 15.9.21
      zmm_hvencrt-rejected_on = sy-datum.  " added by ss on 15.9.21
      g_no_vend = 1.
    ENDIF.

    IF ist_vend-vend-rsn NE 'B' AND ist_vend-vend-rsn NE 'C'.
      zmm_hvencrt-ass_flag = 'R'.     "FULL REQUEST REJECTED
      zmm_hvencrt-reqcl = 'R'.
      zmm_hvencrt-rejected_by = sy-uname.  " added by ss on 15.9.21
      zmm_hvencrt-rejected_on = sy-datum.  " added by ss on 15.9.21
      g_no_vend = 1.
    ENDIF.
  ELSE.
    zmm_hvencrt-ass_flag = 'F'.   "FULL ASSIGNMENT OF REQUEST
    zmm_hvencrt-reqcl = 'C'.
    g_str = 'Fully'.
  ENDIF.

  LOOP AT ist_vend.

    IF ist_vend-vend-sortl IS NOT INITIAL.   " added by ss on 21.9.2021
      zmm_hvencrt-assign_date = sy-datum.
      zmm_hvencrt-assigned_by = sy-uname.
    ELSEIF ist_vend-vend-rsn IS NOT INITIAL.  "added by ss on 22.9.2021

    ENDIF.  "**  added by ss on  21.9.2021

  ENDLOOP.

  MODIFY zmm_hvencrt.
  IF NOT sy-subrc IS INITIAL.
    g_crt1 = 'X'.
  ENDIF.

ENDFORM.                    " ass_ZMM_HVENCRT
*&---------------------------------------------------------------------*
*&      Form  ASS_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ass_zmm_dvencrt.
  CLEAR : wa_vend, ist_zmm_dvencrt.
  REFRESH ist_zmm_dvencrt.
  IF NOT ist_vend[] IS INITIAL.
    LOOP AT ist_vend INTO wa_vend.
      MOVE-CORRESPONDING wa_vend-vend TO ist_zmm_dvencrt.
      ist_zmm_dvencrt-reqno = zmm_hvencrt-reqno.
      ist_zmm_dvencrt-mandt = sy-mandt.
      ist_zmm_dvencrt-aedtm = sy-datum.
      ist_zmm_dvencrt-aeusn = sy-uname.
      APPEND ist_zmm_dvencrt.
    ENDLOOP.
  ENDIF.
  IF NOT ist_zmm_dvencrt[] IS INITIAL.
    MODIFY zmm_dvencrt FROM TABLE ist_zmm_dvencrt[].
    IF NOT sy-subrc IS INITIAL.
      g_crt2 = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " ASS_ZMM_DVENCRT
*&---------------------------------------------------------------------*
*&      Form  GET_SEARCH_STRING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_SEARCH_STRING  text
*----------------------------------------------------------------------*
FORM get_search_string USING l_str_len
                       CHANGING l_search_string l_count.
  DO.
    REPLACE 'MR.' WITH space INTO l_search_string.
    REPLACE 'SH.' WITH space INTO l_search_string.
    REPLACE 'DR.' WITH space INTO l_search_string.
    REPLACE '&' WITH space INTO l_search_string.
    REPLACE '.' WITH space INTO l_search_string.
    REPLACE ',' WITH space INTO l_search_string.
    REPLACE '-' WITH space INTO l_search_string.
    REPLACE ';' WITH space INTO l_search_string.
    REPLACE '"' WITH space INTO l_search_string.
    REPLACE '#' WITH space INTO l_search_string.
    REPLACE 'LTD' WITH space INTO l_search_string.
    REPLACE 'PVT' WITH space INTO l_search_string.
    REPLACE 'PRIVATE' WITH space INTO l_search_string.
    REPLACE 'LIMITED' WITH space INTO l_search_string.

*  DO.
    l_count = l_count + 1.
    REPLACE space WITH '%' INTO l_search_string.
    IF l_search_string+l_str_len(1) <> '%'.
      CONTINUE.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                    " GET_SEARCH_STRING
*&---------------------------------------------------------------------*
*&      Form  del_rec
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_rec.

  CLEAR ist_zmm_dvencrt.REFRESH ist_zmm_dvencrt.
  LOOP AT ist_vend WHERE mark = 'X'.
    MOVE-CORRESPONDING ist_vend-vend TO ist_zmm_dvencrt.
    ist_zmm_dvencrt-del_flag = 'X'.
    ist_zmm_dvencrt-aedtm = sy-datum.
    ist_zmm_dvencrt-aeusn = sy-uname.
    APPEND ist_zmm_dvencrt. CLEAR ist_zmm_dvencrt.
  ENDLOOP.
  MODIFY zmm_dvencrt FROM TABLE ist_zmm_dvencrt[].
  IF NOT sy-subrc IS INITIAL.
    g_crt2 = 'X'.
  ENDIF.

ENDFORM.                    " del_rec
*&---------------------------------------------------------------------*
*&      Form  mark_rec_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_rec_del.
  CLEAR : wa_vend.
  LOOP AT ist_vend INTO wa_vend.
    IF wa_vend-mark = 'X'.
      wa_vend-vend-del_flag = 'X'.
      CLEAR wa_vend-mark.
    ENDIF.
    wa_vend-fnd_flg = 'M'.
    MODIFY ist_vend FROM wa_vend INDEX sy-tabix.
    CLEAR wa_vend.
  ENDLOOP.
ENDFORM.                    " mark_rec_del
*&---------------------------------------------------------------------*
*&      Form  create_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0875   text
*      <--P_G_STATUS_ICON  text
*----------------------------------------------------------------------*
FORM create_icon USING  p_icon
                 CHANGING g_status_icon.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = p_icon
      add_stdinf            = 'X'
    IMPORTING
      result                = g_status_icon
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " create_icon
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_mail.
  DATA l_str(50).
  DATA : l_sms TYPE string.
  CLEAR :l_str , l_sms.


  PERFORM setup_trx_and_rtx_mailboxes.
* Begin of <> on 10012012
*  break-point. " cab_sudhir.
  IF save_ok = 'UNBL'.
    """"""""""""""""""""""""""
    ""added by lipsy on 4.03.2013
    IF g_crt1 = 'X'.
    ELSE.
      """""""end of addition by lipsy on 4.03.2013
      """"""""""""""""""""""""
      CONCATENATE text-309 zmm_vend_unblock-reqno INTO l_str
                                             SEPARATED BY space.
      CONCATENATE 'Vendor Unblock Request' zmm_vend_unblock-reqno INTO l_sms SEPARATED BY space.
      CONCATENATE  l_sms 'has been processed.' INTO l_sms SEPARATED BY space.

      PERFORM get_user USING zmm_vend_unblock-assigned_by. "ERNAM.
      PERFORM create_and_send_mail_object USING zmm_vend_unblock-ernam
                                                l_str.
      PERFORM send_sms USING l_sms zmm_vend_unblock-ernam."cab_dns

      """""""""""""""""""""""""
      ""added by lipsy on 4.03.2013
    ENDIF.
    """""""end of addition by lipsy on 4.03.2013
    """"""""""""""""""""""""

  ELSEIF save_ok = 'BLOC'.
    CONCATENATE text-309 zmm_vend_block-reqno INTO l_str
                                           SEPARATED BY space.

    CONCATENATE 'Vendor Block Request' zmm_vend_block-reqno INTO l_sms SEPARATED BY space.
    CONCATENATE  l_sms 'has been Assigned.' INTO l_sms SEPARATED BY space.

    PERFORM get_user USING zmm_vend_block-assigned_by. "ERNAM.
    PERFORM create_and_send_mail_object USING zmm_vend_block-ernam
                                             l_sms.
  ELSE.
* End of <> on 10012012
    IF NOT zmm_hvencrt-ernam IS INITIAL.
      CONCATENATE text-034 zmm_hvencrt-reqno INTO l_str
                                             SEPARATED BY space.
      CONCATENATE l_str 'has been processed' INTO l_sms SEPARATED BY space.
      PERFORM get_user USING zmm_hvencrt-assigned_by.

      """"""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 1.10.2015 for srm vendor replicate RD1K998437

      IF zmm_hvencrt-srmid IS NOT INITIAL.

        PERFORM create_and_send_mail_object USING zmm_hvencrt-released_by
                                                    l_str.
        PERFORM send_sms USING l_sms zmm_hvencrt-released_by.

      ELSE.
        "end of addition by lipsy on 1.10.2015 for srm vendor replicate RD1K998437
        """""""""""""""""""""""""""""""""""""""""""""
        PERFORM create_and_send_mail_object USING zmm_hvencrt-ernam
                                                  l_str.
        PERFORM send_sms USING l_sms zmm_hvencrt-ernam. "cab_dns

        """"""""""""""""""""""""""""""""""""""""""""
        """added by lipsy on 1.10.2015  for srm vendor replicate RD1K998437
      ENDIF.
      "end of addition by lipsy on 1.10.2015 for srm vendor replicate RD1K998437
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


*     PERFORM send_sms USING txt_num.
    ELSEIF zmm_hvenext-ernam <> ' '.
      CONCATENATE text-044 zmm_hvenext-reqno INTO l_str
                                             SEPARATED BY space.
      PERFORM get_user USING zmm_hvenext-assigned_by.
      PERFORM create_and_send_mail_object USING zmm_hvenext-ernam
                                                l_str.
    ENDIF.
  ENDIF.
ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  remove_title
*&---------------------------------------------------------------------*
*       remove M/S sp.characters FROM PASSED STRING
*----------------------------------------------------------------------*
*      -->P_NAME1  text
*      <--P_L_STR_LEN  text
*----------------------------------------------------------------------*
FORM remove_title USING l_str_len
                  CHANGING name1.

  l_str_len = strlen( name1 ).
  TRANSLATE name1 TO UPPER CASE.
  IF name1+0(3) = 'M/S'.
    l_str_len = l_str_len - 4.
    name1 = name1+4(l_str_len).
    l_str_len = strlen( name1 ).
  ENDIF.
ENDFORM.                    " remove_title
*&---------------------------------------------------------------------*
*&      Form  popup_hitlist
*&---------------------------------------------------------------------*
*       hist list from zmm_dvencrt table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_hitlist TABLES ist_tab1
                   USING tablename text p_val.
  SORT ist_vendor1.
  DELETE ADJACENT DUPLICATES FROM ist_vendor1.
  g_src = p_val.
  CALL SCREEN '9000' STARTING AT 5 10  ENDING AT 100 15.

  CLEAR g_src.
ENDFORM.                    " popup_hitlist
*&---------------------------------------------------------------------*
*&      Form  CLEAR_SCR_310
*&---------------------------------------------------------------------*
*       clear variables
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_scr_310.
  CLEAR : g_ans,
          g_crt1,
          g_crt2,
          g_mess,
          g_req_num,
          g_loc_text,
          g_com_text,
          g_no_vend,
          g_trans_mode,
          g_lifnr,
          g_datar,
          g_cursorfield,
          g_cursorline.

  CLEAR : ist_req,
          zmm_hvenext,
          zmm_dvenext,
          ist_extn[],
          ist_bdcstatus,
          ist_unbl,
* Begin of <> on 1412010
          ist_bl,
          zmm_vend_block,
          ist_zmm_vend_block,
          wa_zmm_vend_block,
* End of <> on 14122010
          zmm_vend_unblock,
          ist_zmm_vend_unblock,
          wa_zmm_vend_unblock,
           l_unblock_create_flag .

  REFRESH : ist_req,
            ist_unbl,
            ist_bl,                                         "14142010
            ist_extn[],
            ist_bdcstatus.

  IF g_unblock_vendor = 'X'.
    g_trans_mode = 'U'.
  ENDIF.


  """"""""""""""""""""""""""""""""""""
  """""""""""

  "ADDED BY LIPSY ON 28.02.2013

  CLEAR : ist_linetab, ist_texttable, ist_linetab_temp.

  REFRESH : ist_linetab, ist_texttable, ist_linetab_temp.
  IF NOT w_editor2 IS INITIAL.
    CALL METHOD w_editor2->delete_text.
  ENDIF.
  FREE w_container.
  CLEAR w_container.


  "END OF ADDITION BY LIPSY ON 28.02.2013
  """""""""""""

  """"""""""""""""""""""""""""""""""""""""""""

ENDFORM.                    " CLEAR_SCR_310
*&---------------------------------------------------------------------*
*&      Form  CREATE_EXT_REQUEST
*&---------------------------------------------------------------------*
*       vendor extension req creation
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_ext_request.
*  PERFORM confirm_user_action using TEXT-001 TEXT-038.
  PERFORM check_extn_mandatory_fields.
  PERFORM confirm_user_action USING text-044 text-045.
  IF g_ans = '1'.
    PERFORM modify_db_ext.
*  else.
*    G_NO_VEND = 1.
  ENDIF.

  IF g_ans NE 1.
    MESSAGE i735(zmm) WITH text-046.
  ELSE.
*    Message s744(ZMM) with g_str ZMM_HVENCRT-REQNO.
  ENDIF.

ENDFORM.                    " CREATE_EXT_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CHANGE_EXT_REQUEST
*&---------------------------------------------------------------------*
*       vendor extension req change
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_ext_request.
  DATA l_ist_dvenext LIKE STANDARD TABLE OF zmm_dvenext WITH HEADER LINE.
  CLEAR l_ist_dvenext .REFRESH l_ist_dvenext .

  PERFORM confirm_user_action USING text-040 text-041.

  IF g_ans = '1'.
    SELECT * FROM zmm_dvenext INTO TABLE l_ist_dvenext WHERE
                                         reqno = zmm_hvenext-reqno.  "#EC CI_NOORDER
    LOOP AT ist_extn INTO wa_extn.
      READ TABLE l_ist_dvenext WITH KEY lifnr = wa_extn-lifnr.
      IF sy-subrc IS INITIAL.
        DELETE l_ist_dvenext INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    PERFORM modify_db_ext.

    IF NOT l_ist_dvenext[] IS INITIAL.
      PERFORM lock_table_ext.
      DELETE zmm_dvenext FROM TABLE l_ist_dvenext[].
      IF sy-subrc <> 0.
        MESSAGE w735(zmm) WITH text-047.
      ENDIF.
      PERFORM unlock_table_ext.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHANGE_EXT_REQUEST
*&---------------------------------------------------------------------*
*&      Form  DELETE_EXT_REQUEST
*&---------------------------------------------------------------------*
*       delete vendor extension request
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_ext_request.
  PERFORM confirm_user_action USING text-040 text-043.
  IF g_ans = '1'.
    PERFORM modify_db_ext.
  ENDIF.
ENDFORM.                    " DELETE_EXT_REQUEST
*&---------------------------------------------------------------------*
*&      Form  RELEASE_EXT_REQUEST
*&---------------------------------------------------------------------*
*       release vendor extension request
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_ext_request.
  PERFORM confirm_user_action USING text-040 text-042.
  IF g_ans = '1'.
    PERFORM modify_db_ext.
  ENDIF.
ENDFORM.                    " RELEASE_EXT_REQUEST
*&---------------------------------------------------------------------*
*&      Form  check_extn
*&---------------------------------------------------------------------*
*       check if vendor already extended to Pur. org & comp code
*----------------------------------------------------------------------*
*      <--P_L_EXTN_FLAG  text
*----------------------------------------------------------------------*
FORM check_extn CHANGING p_extn_flag.

  SELECT SINGLE * FROM  lfm1
                  WHERE lifnr = ist_extn-lifnr
                  AND   ekorg = ist_extn-ekorg.
  IF sy-subrc IS INITIAL.
    SELECT SINGLE * FROM  lfb1
                    WHERE lifnr = ist_extn-lifnr
                    AND   bukrs = zmm_hvenext-bukrs.
    IF sy-subrc IS INITIAL.
      p_extn_flag = 'X'.
*      MESSAGE w167(f2) WITH ist_extn-lifnr zmm_hvenext-bukrs
*                            ist_extn-ekorg.
    ELSE.
*      MESSAGE w166(f2) WITH ist_extn-lifnr ist_extn-ekorg.
    ENDIF.
*    p_extn_flag = 'X'.
  ENDIF.
  IF p_extn_flag = 'X'.
    READ TABLE ist_extn INTO wa_extn INDEX tab_ext-current_line.
    IF sy-subrc IS INITIAL.
      wa_extn = ist_extn.
      MODIFY ist_extn FROM wa_extn INDEX tab_ext-current_line.
      DELETE ist_extn INDEX tab_ext-current_line.
      PERFORM adj_seqno.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_extn
*&---------------------------------------------------------------------*
*&      Form  ADJ_SEQNO
*&---------------------------------------------------------------------*
*       ADJ SEQNO DURING ADD/DEL ITEMS
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM adj_seqno.
  CLEAR wa_extn.
  IF NOT ist_extn[] IS INITIAL.
    LOOP AT ist_extn INTO wa_extn.
      wa_extn-seqno = sy-tabix.
      MODIFY ist_extn FROM wa_extn INDEX sy-tabix.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " ADJ_SEQNO
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DB_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_db_ext.
  CLEAR g_req_num.
  CASE g_trans_mode.
    WHEN 'N'.
      PERFORM generate_request_ext CHANGING g_req_num.
      PERFORM lock_table_ext.
      PERFORM update_zmm_hvenext ON COMMIT.
      PERFORM update_zmm_dvenext ON COMMIT.

      IF g_crt1 IS INITIAL AND g_crt2 IS INITIAL.
        COMMIT WORK.
        MESSAGE s728(zmm) WITH zmm_hvenext-reqno.
      ELSE.
        MESSAGE e732(zmm).
      ENDIF.

      PERFORM unlock_table_ext.

    WHEN 'M'.

      PERFORM lock_table_ext.
      PERFORM update_zmm_hvenext ON COMMIT.
      PERFORM update_zmm_dvenext ON COMMIT.

      IF g_crt1 IS INITIAL AND g_crt2 IS INITIAL.
        COMMIT WORK.
        MESSAGE s268(zmm).
      ELSE.
        MESSAGE e735(zmm) WITH 'Error Document not modified'.
      ENDIF.

      PERFORM unlock_table_ext.

    WHEN 'R'.

      PERFORM lock_table_ext.
      PERFORM update_zmm_hvenext ON COMMIT.
      IF g_crt1 IS INITIAL.
        COMMIT WORK.
        g_mess = 'successfuly'.
        CONCATENATE ' ' g_mess ' ' INTO g_mess.
        MESSAGE s736(zmm) WITH zmm_hvenext-reqno g_mess.
      ELSE.
        g_mess = 'error in releasing'.
        CONCATENATE ' ' g_mess ' ' INTO g_mess.
        MESSAGE e736(zmm) WITH zmm_hvenext-reqno g_mess.
      ENDIF.
      PERFORM unlock_table_ext.
    WHEN 'X'.

      PERFORM lock_table_ext.
      PERFORM update_zmm_hvenext ON COMMIT.
      PERFORM update_zmm_dvenext ON COMMIT.
      IF g_crt1 IS INITIAL AND
         g_crt2 IS INITIAL.
        COMMIT WORK.
        MESSAGE s415(zmm) WITH zmm_hvenext-reqno.
      ELSE.
        MESSAGE e506(zmm) WITH zmm_hvenext-reqno.
      ENDIF.
      PERFORM unlock_table_ext.

    WHEN 'A'.
      IF g_vend_err IS INITIAL.
        PERFORM lock_table_ext.
        PERFORM update_zmm_hvenext ON COMMIT.
        IF g_crt1 IS INITIAL.
          COMMIT WORK.
        ELSE.
          MESSAGE e735(zmm) WITH text-020.
        ENDIF.
        PERFORM unlock_table_ext.
      ENDIF.
  ENDCASE.

ENDFORM.                    " MODIFY_DB_EXT
*&---------------------------------------------------------------------*
*&      Form  LOCK_TABLE_EXT
*&---------------------------------------------------------------------*
*       LOCK VENDOR EXTN TABLES
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_table_ext.
  CALL FUNCTION 'ENQUEUE_EZMM_HVENEXT'
    EXPORTING
      mode_zmm_hvenext = 'E'
      mandt            = sy-mandt
      reqno            = zmm_hvenext-reqno
    EXCEPTIONS
      foreign_lock     = 1
      system_failure   = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EZMM_DVENEXT'
      EXPORTING
        mode_zmm_dvenext = 'E'
        mandt            = sy-mandt
*       reqno            = zmm_dvenext-reqno         "-rk004
        reqno            = zmm_hvenext-reqno          "+rk004
      EXCEPTIONS
        foreign_lock     = 1
        system_failure   = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " LOCK_TABLE_EXT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_HVENEXT
*&---------------------------------------------------------------------*
*       UPDATE TABLE ZMM_HVENEXT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_hvenext.
  zmm_hvenext-mandt = sy-mandt.
  CASE g_trans_mode.
    WHEN 'N'.
      zmm_hvenext-erfdt = sy-datum.
      zmm_hvenext-ernam = sy-uname.
    WHEN 'M'.
      zmm_hvenext-aedtm = sy-datum.
      zmm_hvenext-aeusn = sy-uname.
      CLEAR zmm_hvenext-rel_flag.
    WHEN 'R'.
      zmm_hvenext-released_by = sy-uname.
      zmm_hvenext-release_date = sy-datum.
      zmm_hvenext-rel_flag = 'X'.
    WHEN 'A'.
      zmm_hvenext-assigned_by = sy-uname.
      zmm_hvenext-assign_date = sy-datum.
      zmm_hvenext-ass_flag = 'X'.
    WHEN 'X'.
      DELETE FROM zmm_hvenext WHERE reqno = zmm_hvenext-reqno.
      IF NOT sy-subrc IS INITIAL.
        g_crt1 = 'X'.
      ENDIF.
      EXIT.
  ENDCASE.

  IF NOT zmm_hvenext-reqno IS INITIAL. "AND
*     NOT ZMM_HVENEXT-EKGRP IS INITIAL.
    MODIFY zmm_hvenext.
    IF NOT sy-subrc IS INITIAL.
      g_crt1 = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " UPDATE_ZMM_HVENEXT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_DVENEXT
*&---------------------------------------------------------------------*
*       UPDATE TABLE ZMM_DVENEXT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_dvenext.
  CLEAR :ist_extn,ist_dvenext.
  REFRESH ist_dvenext.
  IF NOT ist_extn[] IS INITIAL.

    CASE g_trans_mode.

      WHEN 'N' OR 'M'.
        LOOP AT ist_extn.
          MOVE-CORRESPONDING ist_extn TO ist_dvenext.
          ist_dvenext-reqno = zmm_hvenext-reqno.
          ist_dvenext-mandt = sy-mandt.
          APPEND ist_dvenext.
        ENDLOOP.
      WHEN 'X'.
        LOOP AT ist_extn.
          MOVE-CORRESPONDING ist_extn TO ist_dvenext.
          APPEND ist_dvenext.
        ENDLOOP.

        DELETE zmm_dvenext FROM TABLE ist_dvenext[].
        IF NOT sy-subrc IS INITIAL.
          g_crt2 = 'X'.
        ENDIF.
        EXIT.

    ENDCASE.

    MODIFY zmm_dvenext FROM TABLE ist_dvenext[].
    IF NOT sy-subrc IS INITIAL.
      g_crt2 = 'X'.
    ENDIF.

  ENDIF.

ENDFORM.                    " UPDATE_ZMM_DVENEXT
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_TABLE_ext
*&---------------------------------------------------------------------*
*       UNLOCK VENDOR EXTENSION TABLES
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_table_ext.
  CALL FUNCTION 'DEQUEUE_EZMM_HVENEXT'
    EXPORTING
      mode_zmm_hvenext = 'E'
      mandt            = sy-mandt
*     reqno            = zmm_hvencrt-reqno.          "-rk004
      reqno            = zmm_hvenext-reqno.           "+rk004

  CALL FUNCTION 'DEQUEUE_EZMM_DVENEXT'
    EXPORTING
      mode_zmm_dvenext = 'E'
      mandt            = sy-mandt
*     reqno            = zmm_hvencrt-reqno.          "-rk004
      reqno            = zmm_hvenext-reqno.           "+rk004


ENDFORM.                    " UNLOCK_TABLE_ext
*&---------------------------------------------------------------------*
*&      Form  BDC_MK01_EXT
*&---------------------------------------------------------------------*
*       Vendor extension assign
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_mk01_ext.

  IF NOT ist_extn[] IS INITIAL.
*    PERFORM confirm_user_action using TEXT-044 TEXT-045.
*    IF g_ans = '1'.
    PERFORM run_bdc_ext.
*    PERFORM MODIFY_DB_EXT.
*    ELSE.
*    G_NO_VEND = 1.
*    ENDIF.
  ENDIF.

*  IF G_NO_VEND EQ 1.
*    Message I735(zmm) with text-046.
*  ELSE.
**    Message s744(ZMM) with g_str ZMM_HVENCRT-REQNO.
*  ENDIF.

ENDFORM.                    " BDC_MK01_EXT
*&---------------------------------------------------------------------*
*&      Form  run_bdc_ext
*&---------------------------------------------------------------------*
*       BDC for vendor extension
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM run_bdc_ext.
  DATA :
    l_kalsk(2)        TYPE n,
    l_fdgrv           TYPE lfb1-fdgrv,
    l_bukrs_extn_flag,
    l_ekorg_extn_flag.

  DATA : l_bankl TYPE lfbk-bankl.                           "+SP011

  CLEAR :
   ist_extn, l_kalsk,ist_lfa1,l_fdgrv,
   l_bukrs_extn_flag,l_ekorg_extn_flag.
  REFRESH :
   ist_lfa1.
  LOOP AT ist_extn.
    SELECT SINGLE * FROM lfb1 WHERE
                    lifnr = ist_extn-lifnr AND
                    bukrs = zmm_hvenext-bukrs .
    IF sy-subrc = 0.
      l_bukrs_extn_flag = 'X'.
    ENDIF.

    SELECT SINGLE * FROM lfm1 WHERE
                    lifnr = ist_extn-lifnr AND
                    ekorg = ist_extn-ekorg .

    IF sy-subrc = 0.
      l_ekorg_extn_flag = 'X'.
    ENDIF.

    SELECT SINGLE * FROM lfa1 INTO ist_lfa1 WHERE
                                    lifnr = ist_extn-lifnr.

    IF sy-subrc IS INITIAL AND
       ( ist_extn-ekorg = 'PMAT'  OR ist_extn-ekorg = 'PSRV' ).
      IF ist_lfa1-ktokk+3(1) = 'I'.
        l_kalsk = '01'.
      ELSE.
        l_kalsk = '02'.
      ENDIF.
    ELSEIF sy-subrc IS INITIAL AND
          ( ist_extn-ekorg <> 'PMAT'  OR ist_extn-ekorg <> 'PSRV' ).

      SELECT SINGLE * FROM t001w WHERE werks = ist_extn-werks.

      IF sy-subrc = 0 AND t001w-land1 = ist_lfa1-land1.
        l_kalsk = '01'.
      ELSEIF sy-subrc = 0 AND t001w-land1 <> ist_lfa1-land1.
        l_kalsk = '02'.
      ENDIF.
    ENDIF.

    CASE ist_lfa1-ktokk.
      WHEN 'IMMI'.
        l_fdgrv = 'DO'.
      WHEN 'IMMF'.
        l_fdgrv = 'FO'.
      WHEN 'SVWI'.
        l_fdgrv = 'DL'.
      WHEN 'SVWF'.
        l_fdgrv = 'FL'.
*    WHEN 'TRNI'.            "ADDED BY ROHIT ON 17/06/2024
*      l_fdgrv = 'DO'.
      WHEN 'GOVT'.            "ADDED BY ROHIT ON 17/06/2024
        l_fdgrv = 'DO'.
    ENDCASE.

    PERFORM bdc_dynpro      USING 'SAPMF02K' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'USE_ZAV'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF02K-LIFNR'
                                  ist_extn-lifnr.
    PERFORM bdc_field       USING 'RF02K-BUKRS'
                                  zmm_hvenext-bukrs.
    PERFORM bdc_field       USING 'RF02K-EKORG'
                                  ist_extn-ekorg.
    PERFORM bdc_field       USING 'RF02K-KTOKK'
                                  ist_lfa1-ktokk.
    PERFORM bdc_field       USING 'USE_ZAV'
                                  'X'.
    IF l_bukrs_extn_flag <>'X'.

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0210'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-FDGRV'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      IF ist_lfa1-ktokk = 'IMMI' OR
         ist_lfa1-ktokk = 'SVWI' OR
         ist_lfa1-ktokk = 'LEA1' OR
         ist_lfa1-ktokk = 'LEA2' OR
         ist_lfa1-ktokk = 'GOVT' OR
         ist_lfa1-ktokk = 'CONT' OR
         ist_lfa1-ktokk = 'LAQ1' OR
         ist_lfa1-ktokk = 'INVT' OR
         ist_lfa1-ktokk = 'SUBD' OR
         ist_lfa1-ktokk = 'UTLT' OR
         ist_lfa1-ktokk = 'TRNI'. "Added by ruhani Garg
        PERFORM bdc_field       USING 'LFB1-AKONT'
                                     '190101'.
      ELSE.
        PERFORM bdc_field       USING 'LFB1-AKONT'
                                      '190104'.
      ENDIF.

      PERFORM bdc_field       USING 'LFB1-ZUAWA'
                                    '014'.
      PERFORM bdc_field       USING 'LFB1-FDGRV'
                                     l_fdgrv.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0215'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-REPRF'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFB1-ZTERM'
                                    '0001'.
      PERFORM bdc_field       USING 'LFB1-REPRF'
                                    'X'.

*+SP011- In case of company code 'OVL',set payment method value to be
*      '9' - start
*******SOC BY ROHIT ON 14-06-2024

      SELECT SINGLE * FROM setleaf INTO @DATA(wa_cc) WHERE setname = 'ZFI_BCM_PM_BUKRS' AND valfrom = @zmm_hvenext-bukrs.
      IF sy-subrc = 0.

*** EOC BY ROHIT ON 14-06-2024
*      IF zmm_hvenext-bukrs = 'OVL'.

*+SP012 - Update Payment Methods based on Bank Key for company code
*        'OVL' - start

*      PERFORM bdc_field       USING 'LFB1-ZWELS'
*                                    '9'.                    "-SP012

        CLEAR : l_bankl.                                    "+SP014

        SELECT SINGLE bankl FROM lfbk INTO l_bankl
                       WHERE lifnr = ist_extn-lifnr.  "#EC CI_NOORDER  "+SP014

*       if ist_vend-vend-bankl = ' '.                       "-SP014
        IF l_bankl = ' '.                                   "+SP014

          PERFORM bdc_field       USING 'LFB1-ZWELS'
                                        'C'.
        ELSE.

*         if ist_vend-vend-bankl+0(4) = text-086.           "-SP014
          IF l_bankl+0(4) = text-086.                       "+SP014

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          '9'.
          ELSE.

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          '8'.
          ENDIF.

        ENDIF.

*+SP012- end

      ELSE.

        CLEAR : l_bankl.

        SELECT SINGLE bankl FROM lfbk INTO l_bankl
                       WHERE lifnr = ist_extn-lifnr.  "#EC CI_NOORDER
*+SP011 - end

*+SP009 - Update Payment Methods based on Bank Key
*     if ist_vend-vend-bankl = ' '.                         "-SP011
        IF l_bankl = ' '.                                   "+SP011

          PERFORM bdc_field       USING 'LFB1-ZWELS'
                                        'C'.
        ELSE.

*       if ist_vend-vend-bankl+0(4) = text-086.             "-SP011
          IF l_bankl+0(4) = text-086.                       "+SP011

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          'S'.
          ELSE.

            PERFORM bdc_field       USING 'LFB1-ZWELS'
                                          'N'.
          ENDIF.

        ENDIF.
*+SP009 - end

      ENDIF.                                                "+SP011

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0220'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFB1-EIKTO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      IF zmm_hvenext-bukrs <> 'OBV'.
* Begin of <> on 71122010
        IF ist_lfa1-ktokk = 'LEA1' OR
           ist_lfa1-ktokk = 'LEA2' OR
           ist_lfa1-ktokk = 'CONT' OR
           ist_lfa1-ktokk = 'GOVT' OR
           ist_lfa1-ktokk = 'LAQ1' OR
           ist_lfa1-ktokk = 'INVT' OR
           ist_lfa1-ktokk = 'SUBD' OR
           ist_lfa1-ktokk = 'UTLT' OR
           ist_lfa1-ktokk = 'TRNI'.

          PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'RF02K-LIFNR'.
        ELSE.
* End of <> on 17122010
          PERFORM bdc_dynpro      USING 'SAPMF02K' '0610'.
          PERFORM bdc_field       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'LFB1-QLAND'.
        ENDIF.
      ENDIF.
      IF l_ekorg_extn_flag <> 'X'.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0310'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFM1-WEBRE'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'LFM1-WAERS'
                                      ist_extn-waers.
        PERFORM bdc_field       USING 'LFM1-KALSK'
                                      l_kalsk.

        IF ( ( ( ist_lfa1-ktokk = 'IMMI' OR ist_lfa1-ktokk = 'SVWI') AND
            ( ist_extn-ekorg = 'PMAT'  OR ist_extn-ekorg = 'PSRV' ) ) OR
                                               ist_extn-ekorg = 'POBV' ).

          PERFORM bdc_field       USING 'LFM1-WEBRE'
                                        'X'.

        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0320'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RF02K-LIFNR'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTR'.
      ENDIF.
    ELSE.

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0310'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'LFM1-WEBRE'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'LFM1-WAERS'
                                    ist_extn-waers.
      PERFORM bdc_field       USING 'LFM1-KALSK'
                                    l_kalsk.
      IF ( ( ( ist_lfa1-ktokk = 'IMMI' OR ist_lfa1-ktokk = 'SVWI') AND
          ( ist_extn-ekorg = 'PMAT'  OR ist_extn-ekorg = 'PSRV' ) ) OR
           ist_extn-ekorg = 'POBV' ).

        PERFORM bdc_field       USING 'LFM1-WEBRE'
                                      'X'.

      ENDIF.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0320'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RF02K-LIFNR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTR'.
    ENDIF.
    PERFORM bdc_dynpro      USING 'SAPLSPO1' '0300'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=YES'.
    PERFORM background TABLES ist_bdcstatus2
                                       USING  'XK01'       " s_tcode
                                               'N'         " s_mode
                                               'A'         " s_update
                                               zmm_hvenext-reqno
                                               ' ' .  "#EC CI_USAGE_OK[2226131]

    IF sy-subrc = 0.
      MESSAGE s819(zmm). "WITH ist_extn-lifnr ist_extn-ekorg.
    ENDIF.
    CLEAR :
       ist_extn,ist_bdcdata,ist_lfa1,
       l_bukrs_extn_flag,l_ekorg_extn_flag.
    REFRESH ist_bdcdata.
  ENDLOOP.

ENDFORM.                    " run_bdc_ext
*&---------------------------------------------------------------------*
*&      Form  GENERATE_REQUEST_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_G_REQ_NUM  text
*----------------------------------------------------------------------*
FORM generate_request_ext CHANGING p_g_req_num.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = c_nr_range_nr
      object                  = c_nr_obj_ext
      quantity                = '1'
    IMPORTING
      number                  = g_req_num
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
  ELSE.
    CONCATENATE 'VE' g_req_num INTO zmm_hvenext-reqno.
  ENDIF.

ENDFORM.                    " GENERATE_REQUEST_EXT
*&---------------------------------------------------------------------*
*&      Form  read_screen_field
*&---------------------------------------------------------------------*
*       read country value from the screen
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_screen_field USING p_field.
  CLEAR: dyfields[], dyfields.
  dyfields-fieldname = p_field.
  dyfields-stepl = g_r_count.
  APPEND dyfields.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dyfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " read_screen_field
*&---------------------------------------------------------------------*
*&      Form  LIST_BOX
*&---------------------------------------------------------------------*
*       populate listbox
*----------------------------------------------------------------------*
*      -->P_2499   text
*----------------------------------------------------------------------*
FORM list_box USING p_field.

  REFRESH : g_list.  CLEAR g_value.
  CLEAR g_list.
  g_id = p_field.

  CASE g_id.
    WHEN 'IST_EXTN-WERKS'.
      SELECT werks FROM t024w INTO TABLE ist_plant WHERE
                                   ekorg = ist_extn-ekorg.  "#EC CI_NOORDER
      IF sy-subrc = 0.
        LOOP AT ist_plant.
          SELECT SINGLE name1 FROM t001w INTO g_value-text WHERE
                                         werks = ist_plant-werks.
          g_value-key  = ist_plant-werks.
          APPEND g_value TO g_list.
          CLEAR g_value.
        ENDLOOP.
      ENDIF.

    WHEN 'WA_VEND-VEND-ort01'.
      SELECT ort01 FROM zmm_cities INTO TABLE ist_cities.  "#EC CI_NOORDER

      LOOP AT ist_t005t.
        g_value-key  = ist_cities-ort01.
*        g_value-text = ist_t005t-landx.
        APPEND g_value TO g_list.
        CLEAR g_value.
      ENDLOOP.
*{   INSERT         OCPK900113                                        1
    WHEN 'WA_VEND-VEND-VEN_CLASS'.
      DATA : it_dd07v TYPE TABLE OF dd07v,
             wa_dd07v TYPE dd07v.
      SELECT domvalue_l ddtext INTO CORRESPONDING FIELDS OF TABLE it_dd07v FROM dd07v WHERE domname = 'J_1IGTAXKD'.  "#EC CI_NOORDER

      LOOP AT it_dd07v INTO wa_dd07v.
        g_value-key  = wa_dd07v-domvalue_l.
        g_value-text = wa_dd07v-ddtext.
        APPEND g_value TO g_list.
        CLEAR g_value.
      ENDLOOP.
*}   INSERT

    WHEN 'WA_VEND-VEND-LAND1'.
      SELECT land1 landx FROM t005t INTO TABLE ist_t005t WHERE
                                              spras = 'EN'.  "#EC CI_NOORDER
      CASE zmm_hvencrt-ktokk.
        WHEN 'IMMF'.
          IF zmm_hvencrt-ekorg = 'PMAT'.
            DELETE ist_t005t WHERE land1 = 'IN'.
          ENDIF.
        WHEN 'SVWF'.
          IF zmm_hvencrt-ekorg = 'PSRV'.
            DELETE ist_t005t WHERE land1 = 'IN'.
          ENDIF.
      ENDCASE.

      LOOP AT ist_t005t.
        g_value-key  = ist_t005t-land1.
        g_value-text = ist_t005t-landx.
        APPEND g_value TO g_list.
        CLEAR g_value.
      ENDLOOP.
    WHEN 'WA_VEND-VEND-WAERS'.
      SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt WHERE
                                          spras = 'EN'.  "#EC CI_NOORDER
      LOOP AT ist_tcurt.
        g_value-key  = ist_tcurt-waers.
        g_value-text = ist_tcurt-ltext.
        APPEND g_value TO g_list.
        CLEAR g_value.
      ENDLOOP.
    WHEN 'WA_VEND-VEND-BRSCH'.
*      SELECT brsch brtxt FROM t016t INTO TABLE ist_t016t WHERE
*                                              spras = 'EN'.
*      LOOP AT ist_t016t.
*        g_value-key  = ist_t016t-brsch.
*        g_value-text = ist_t016t-brtxt.
**       IF g_value-key+0(1) = 'V'.                         "-SP008
*        IF g_value-key+0(1) = 'V'     OR
*           g_value-key      = 'Z025'  OR
*           g_value-key      = 'Z026'  OR
*           g_value-key      = 'Z027'  OR
*           g_value-key      = 'Z028'  OR
*           g_value-key      = 'Z029'  OR
*           g_value-key      = 'Z030'.                       "+SP008
*
*          APPEND g_value TO g_list.
*        ENDIF.
*        CLEAR g_value.
*      ENDLOOP.
      REFRESH:it_vms_ind[].
      SELECT brsch brtxt
             FROM zmm_vms_industry
             INTO CORRESPONDING FIELDS OF TABLE it_vms_ind.  "#EC CI_NOORDER
*             WHERE industry1 = 'X'.                        "Commented on 02.06.2020 by Abhishek

      LOOP AT it_vms_ind INTO wa_vms_ind.
        g_value-key  = wa_vms_ind-brsch.
        g_value-text = wa_vms_ind-brtxt.
        APPEND g_value TO g_list.
        CLEAR g_value.
      ENDLOOP.

    WHEN  'WA_VEND-VEND-BRSCH2'.

      REFRESH:it_vms_ind[].
      SELECT brsch brtxt
             FROM zmm_vms_industry
             INTO CORRESPONDING FIELDS OF TABLE it_vms_ind
             WHERE industry2 = 'X'.  "#EC CI_NOORDER

      LOOP AT it_vms_ind INTO wa_vms_ind.

        g_value-key  = wa_vms_ind-brsch.
        g_value-text = wa_vms_ind-brtxt.
        APPEND g_value TO g_list.
        CLEAR g_value.

      ENDLOOP.
    WHEN  'WA_VEND-VEND-BRSCH3'.

      REFRESH:it_vms_ind[].
      SELECT brsch brtxt
             FROM zmm_vms_industry
             INTO CORRESPONDING FIELDS OF TABLE it_vms_ind
             WHERE industry3 = 'X'.  "#EC CI_NOORDER

      LOOP AT it_vms_ind INTO wa_vms_ind.

        g_value-key  = wa_vms_ind-brsch.
        g_value-text = wa_vms_ind-brtxt.
        APPEND g_value TO g_list.
        CLEAR g_value.

      ENDLOOP.

    WHEN 'WA_VEND-VEND-RSN'.
      g_value-key  = 'A'.
      g_value-text = 'Already Exist'.
      APPEND g_value TO g_list.
      CLEAR g_value.

      g_value-key  = 'B'.
      g_value-text = 'Spell check'.
      APPEND g_value TO g_list.
      CLEAR g_value.

      g_value-key  = 'C'.
      g_value-text = 'Read Notes'.
      APPEND g_value TO g_list.
      CLEAR g_value.

    WHEN 'WA_VEND-VEND-J_1KFTBUS'.
      g_value-key  = 'OEM'.
      APPEND g_value TO g_list.
      CLEAR g_value.

      g_value-key  = 'OTHERS'.
      APPEND g_value TO g_list.
      CLEAR g_value.

    WHEN 'IST_EXTN-EKORG'.
      IF zmm_hvenext-bukrs IS INITIAL.
        EXIT.
      ELSE.
        IF zmm_hvenext-bukrs <> 'OBV'.
          g_value-key  = 'PMAT'.
*      g_value-text = 'Materials'.
          APPEND g_value TO g_list.
          CLEAR g_value.

          g_value-key  = 'PSRV'.
*      g_value-text = 'Service'.
          APPEND g_value TO g_list.
          CLEAR g_value.
        ELSEIF zmm_hvenext-bukrs = 'OBV'.
          g_value-key  = 'POBV'.
*      g_value-text = 'Materials'.
          APPEND g_value TO g_list.
          CLEAR g_value.
        ENDIF.
      ENDIF.
    WHEN 'ZMM_VEND_UNBLOCK-SPERQ'.
      g_value-key  = 'BL'.
      g_value-text = 'Black-listing of Vendor'.
      APPEND g_value TO g_list.
      CLEAR g_value.

      g_value-key  = 'DV'.
      g_value-text = 'Duplicate Vendor Code'.
      APPEND g_value TO g_list.
      CLEAR g_value.
  ENDCASE.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_id
      values = g_list.

ENDFORM.                    " LIST_BOX
*&---------------------------------------------------------------------*
*&      Form  get_row_count
*&---------------------------------------------------------------------*
*       get row count in table control for dynp values read
*----------------------------------------------------------------------*
*      <--P_L_R_COUNT  text
*----------------------------------------------------------------------*
FORM get_row_count CHANGING l_r_count.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = l_r_count
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " get_row_count
*&---------------------------------------------------------------------*
*&      Form  del_row
*&---------------------------------------------------------------------*
*       del table control row
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_row.
  CLEAR : ist_vend.
  LOOP AT ist_vend WHERE mark = 'X'.
    DELETE ist_vend INDEX sy-tabix.
    REFRESH ist_lfa1.
    CLEAR ist_vend.
  ENDLOOP.

ENDFORM.                    " del_row
*&---------------------------------------------------------------------*
*&      Form  GET_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_HVENEXT_ASSIGNED_BY  text
*----------------------------------------------------------------------*
FORM get_user USING p_user.
  CLEAR : wa_user_address, wa_user_usr03.

  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
    EXPORTING
      user_name              = p_user
    IMPORTING
      user_address           = wa_user_address
      user_usr03             = wa_user_usr03
    EXCEPTIONS
      user_address_not_found = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_USER
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLETE_VENDOR_ADDRESS
*&---------------------------------------------------------------------*
*       subroutine for reading vendor address
*----------------------------------------------------------------------*
*      -->P_G_ADDRNUMBER  text
*----------------------------------------------------------------------*
FORM get_complete_vendor_address USING    p_g_addrnumber.
  CLEAR wa_addr1_complete.

  CALL FUNCTION 'ADDR_GET_COMPLETE'
    EXPORTING
      addrnumber              = p_g_addrnumber
    IMPORTING
      addr1_complete          = wa_addr1_complete
    EXCEPTIONS
      parameter_error         = 1
      address_not_exist       = 2
      internal_error          = 3
      wrong_access_to_archive = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF NOT wa_addr1_complete IS INITIAL.
    LOOP AT wa_addr1_complete-addr1_tab INTO wa_addr1_tab.
      MOVE-CORRESPONDING wa_addr1_tab-data TO addr1_data.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_COMPLETE_VENDOR_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  POSTAL_CHECK
*&---------------------------------------------------------------------*
*       POSTAL CHECK FUNCTION
*----------------------------------------------------------------------*
*      -->P_WA_VEND_VEND_PSTLZ  text
*----------------------------------------------------------------------*
FORM postal_check USING    p_postal p_country p_region.

  CALL FUNCTION 'ADDR_POSTAL_CODE_CHECK'
    EXPORTING
      country                        = p_country
      postal_code_city               = p_postal
*     POSTAL_CODE_PO_BOX             = ' '
*     POSTAL_CODE_COMPANY            = ' '
*     PO_BOX                         = ' '
      region                         = p_region
*     POSTAL_ADDRESS                 =
* IMPORTING
*     T005_WA                        =
*     T005_WA_PO_BOX                 =
    EXCEPTIONS
      country_not_valid              = 1
      region_not_valid               = 2
      postal_code_city_not_valid     = 3
      postal_code_po_box_not_valid   = 4
      postal_code_company_not_valid  = 5
      po_box_missing                 = 6
      postal_code_po_box_missing     = 7
      postal_code_missing            = 8
      postal_code_pobox_comp_missing = 9
      po_box_region_not_valid        = 10
      po_box_country_not_valid       = 11
      pobox_and_poboxnum_filled      = 12
      OTHERS                         = 13.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " POSTAL_CHECK
*&---------------------------------------------------------------------*
*&      Form  GUI_STATUS_SET
*&---------------------------------------------------------------------*
*       SET GUI STATUS
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gui_status_set.
  CLEAR : ist_gui.
  REFRESH ist_gui .

  IF ist_gui[] IS INITIAL.
    ist_gui-fcode = 'CREA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'DISP' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'MODF' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'REPO' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .

    ist_gui-fcode = 'UPDTADDR' . APPEND ist_gui . CLEAR ist_gui .

*    ist_gui-fcode = 'ADDC' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005
    ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "+SP005

    ist_gui-fcode = 'UPDTBANK'. APPEND ist_gui . CLEAR ist_gui. "+SP009.
* Begin of <> on 111010 By Sudhir Sharma
    ist_gui-fcode = 'SEARCH'. APPEND ist_gui . CLEAR ist_gui.
    ist_gui-fcode = 'BLOC'. APPEND ist_gui . CLEAR ist_gui. "SS06122010
    ist_gui-fcode = 'HELP'.   APPEND ist_gui . CLEAR ist_gui. "17102011
* End of <>

    ist_gui-fcode = 'URP' . APPEND ist_gui . CLEAR ist_gui . "+SP015
    ist_gui-fcode = 'GST' . APPEND ist_gui . CLEAR ist_gui . "+SP015

**********Added on 02.06.2020 by Abhishek********************************
    ist_gui-fcode = 'WITHOLD' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'IND_UPD' . APPEND ist_gui . CLEAR ist_gui .
*************************************************************************
  ENDIF.

ENDFORM.                    " GUI_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  FINE_SEARCH_LFA1
*&---------------------------------------------------------------------*
*       FINE SEARCH LFA1
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fine_search_lfa1 USING p_flag.
  DATA :
    l_namestring       TYPE string,l_name1_name2(100).

  CLEAR :ist_lfa1, wa_vend, ist_vendor1.
  REFRESH ist_vendor1.

*  LOOP AT ist_vend INTO wa_vend WHERE fnd_flg = ' '.
  LOOP AT ist_vend INTO wa_vend WHERE vend-ass_flag = p_flag.
    IF g_trans_mode <> 'A' AND wa_vend-fnd_flg <> ' '.
      CONTINUE.
    ENDIF.

    CONCATENATE wa_vend-vend-name1 wa_vend-vend-name2 INTO l_namestring.

    CONDENSE l_namestring NO-GAPS.


    IF NOT wa_vend-vend-name1 IS INITIAL AND
       NOT wa_vend-vend-name2 IS INITIAL AND
       NOT wa_vend-vend-ort01 IS INITIAL.

      TRANSLATE wa_vend-vend-name1 TO UPPER CASE.
      TRANSLATE wa_vend-vend-name2 TO UPPER CASE.
      TRANSLATE wa_vend-vend-ort01 TO UPPER CASE.

      CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
      CONCATENATE wa_vend-vend-name2 '%' INTO wa_vend-vend-name2.
      CONCATENATE '%' wa_vend-vend-ort01 '%' INTO wa_vend-vend-ort01.
*Begin of <RD1K960611>.
      EXEC SQL                    "#EC CI_EXECSQL
        PERFORMING fine_search.
*        SELECT * INTO :ist_lfa1
*        FROM   lfa1
*        WHERE upper(name1) LIKE :wa_vend-vend-name1
*        and   upper(name2) like :wa_vend-vend-name2
*        and   upper(ort01) like :wa_vend-vend-ort01
*        and   lifnr <> :' '
*        and   loevm = :' '

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR,pstlz INTO :WA_LFA5
                 FROM LFA1
                 WHERE
                upper(name1) LIKE :wa_vend-vend-name1
               and   upper(name2) like :wa_vend-vend-name2
               and   upper(ort01) like :wa_vend-vend-ort01
               and   lifnr <> :' '
               and   loevm = :' '
      ENDEXEC.
*End of <RD1K960611>.
      CONCATENATE wa_vend-vend-name1 wa_vend-vend-name2 INTO l_name1_name2
                                                                          .

*      IF sy-subrc <> 0 AND p_flag <> ' '.
*Begin of <RD1K960611>.
      EXEC SQL                  "#EC CI_EXECSQL
        PERFORMING fine_search.
*        SELECT * INTO :ist_lfa1
*        FROM   lfa1
*        WHERE upper(name1) LIKE :l_name1_name2
*        and   upper(ort01) like :wa_vend-vend-ort01
*        and   lifnr <> :' '
*        and   loevm = :' '

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR,pstlz INTO :WA_LFA5
                 FROM LFA1
                 WHERE
                upper(name1) LIKE :l_name1_name2
              and   upper(ort01) like :wa_vend-vend-ort01
               and   lifnr <> :' '
               and   loevm = :' '
      ENDEXEC.
*End of <RD1K960611>.
*
    ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
           NOT wa_vend-vend-name2 IS INITIAL AND
               wa_vend-vend-ort01 IS INITIAL.

      CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
      CONCATENATE wa_vend-vend-name2 '%' INTO wa_vend-vend-name2.
*Begin of <RD1k960611>.
      EXEC SQL                  "#EC CI_EXECSQL
        PERFORMING fine_search.
*        SELECT * INTO :ist_lfa1
*        FROM   lfa1
*        WHERE upper(name1) LIKE :wa_vend-vend-name1
*        and   upper(name2) like :wa_vend-vend-name2
*        and   lifnr <> :' '
*        and   loevm = :' '

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR ,pstlz


          INTO :WA_LFA5
                 FROM LFA1
                 WHERE
                upper(name1) LIKE :wa_vend-vend-name1
               and   upper(name2) like :wa_vend-vend-name2
               and   lifnr <> :' '
               and   loevm = :' '
      ENDEXEC.
*End of <RD1K960611>.
    ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
               wa_vend-vend-name2 IS INITIAL AND
               wa_vend-vend-ort01 IS INITIAL.

      CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
*Begin of <RD1K960611>.
      EXEC SQL                  "#EC CI_EXECSQL
        PERFORMING fine_search.
*        SELECT * INTO :ist_lfa1
*        FROM   lfa1
*        WHERE upper(name1) LIKE :wa_vend-vend-name1
*        and   lifnr <> :' '
*        and   loevm = :' '

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR ,pstlz INTO :WA_LFA5
                FROM LFA1
                WHERE
              upper(name1) LIKE :wa_vend-vend-name1
               and   lifnr <> :' '
              and   loevm = :' '
      ENDEXEC.

*End of <RD1k960611>.
    ELSEIF NOT wa_vend-vend-name1 IS INITIAL AND
               wa_vend-vend-name2 IS INITIAL AND
           NOT wa_vend-vend-ort01 IS INITIAL.

      CONCATENATE wa_vend-vend-name1 '%' INTO wa_vend-vend-name1.
      CONCATENATE '%' wa_vend-vend-ort01 '%' INTO wa_vend-vend-ort01.
*Begin of <RD1k960611>.
      EXEC SQL                  "#EC CI_EXECSQL
        PERFORMING fine_search.
*        SELECT * INTO :ist_lfa1
*        FROM   lfa1
*        WHERE upper(name1) LIKE :wa_vend-vend-name1
*        and   upper(ort01) like :wa_vend-vend-ort01
*        and   lifnr <> :' '
*        and   loevm = :' '

        SELECT LIFNR,LAND1,NAME1,NAME2,ORT01,ADRNR ,pstlz INTO :WA_LFA5
                FROM LFA1
                WHERE
              (upper(name1) LIKE :wa_vend-vend-name1)
              and   (upper(ort01) like :wa_vend-vend-ort01)
               and   (lifnr <> :' ')
              and   (loevm = :' ')
      ENDEXEC.
*End of <RD1K960611>.
    ENDIF.
    IF g_trans_mode = 'A'.
      DELETE ist_vendor1 WHERE lifnr = wa_vend-vend-lifnr.
      LOOP AT ist_vendor1.
        CALL FUNCTION 'ZMM_REPLACE_CHARACTERS'
          EXPORTING
            i_string         = ist_vendor1-namestring
            i_search_pattern = ',&#@!*.-;'
          IMPORTING
            e_string         = ist_vendor1-namestring.

        MODIFY ist_vendor1 INDEX sy-tabix.
      ENDLOOP.
      DELETE ist_vendor1 WHERE namestring <> l_namestring.
      CLEAR l_namestring.
      CONTINUE.
    ENDIF.
    IF NOT ist_vendor1[] IS INITIAL.   " and  zmm_hvencrt-reqno = ' '.
      MESSAGE w735(zmm) WITH text-067.
      PERFORM popup_hitlist TABLES ist_vendor1
                            USING 'zmm_venadd' text-056 '2'.
      g_ok_9000 = sy-ucomm.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " FINE_SEARCH_LFA1
*&---------------------------------------------------------------------*
*&      Form  undo_rec_del
*&---------------------------------------------------------------------*
*       undo rec deletion in change mode
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM undo_rec_del.
  CLEAR : wa_vend.
  LOOP AT ist_vend INTO wa_vend.
    IF wa_vend-vend-del_flag = 'X' AND
       wa_vend-mark = 'X'.
      wa_vend-vend-del_flag = ' '.
      CLEAR wa_vend-mark.
    ENDIF.
    wa_vend-fnd_flg = 'M'.
    MODIFY ist_vend FROM wa_vend INDEX sy-tabix.
    CLEAR wa_vend.
  ENDLOOP.
  g_ans = 2.
ENDFORM.                    " undo_rec_del
*&---------------------------------------------------------------------*
*&      Form  create_container
*&---------------------------------------------------------------------*
*       subroutine to create container for text editor
*----------------------------------------------------------------------*
FORM create_container.
  IF w_editor1 IS INITIAL.
    w_repid = sy-repid.
    CREATE OBJECT w_container
      EXPORTING
        container_name              = 'DISP_CONTAINER'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE i493(zz) WITH 'w_container' sy-subrc.
      STOP.
    ENDIF.

    CREATE OBJECT w_split_cont1
      EXPORTING
        parent        = w_container
        orientation   = 1
        sash_position = 1.

    CREATE OBJECT w_editor1
      EXPORTING
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
*                            cl_gui_textedit=>wordwrap_at_fixed_position
*       wordwrap_position          = c_line_length
*       wordwrap_to_linebreak_mode = cl_gui_textedit=>true
        wordwrap_to_linebreak_mode = cl_gui_textedit=>false
        parent                     = w_split_cont1->bottom_right_container
      EXCEPTIONS
        error_cntl_create          = 1
        error_cntl_init            = 2
        error_cntl_link            = 3
        error_dp_create            = 4
        gui_type_not_supported     = 5
        OTHERS                     = 6.

    IF sy-subrc <> 0.
      MESSAGE i493(zz) WITH 'w_editor' sy-subrc.
      STOP.
    ENDIF.
  ENDIF.


  CALL METHOD w_editor1->set_readonly_mode.

  IF w_editor2 IS INITIAL.
    w_repid = sy-repid.
    CREATE OBJECT w_container
      EXPORTING
        container_name              = 'EDIT_CONTAINER'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE i493(zz) WITH 'w_container' sy-subrc.
      STOP.
    ENDIF.

    CREATE OBJECT w_split_cont2
      EXPORTING
        parent        = w_container
        orientation   = 1
        sash_position = 1.


    CREATE OBJECT w_editor2
      EXPORTING
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
*                       cl_gui_textedit=>wordwrap_at_fixed_position
*       wordwrap_position          = c_line_length
*       wordwrap_to_linebreak_mode = cl_gui_textedit=>true
        wordwrap_to_linebreak_mode = cl_gui_textedit=>false
        parent                     = w_split_cont2->bottom_right_container
      EXCEPTIONS
        error_cntl_create          = 1
        error_cntl_init            = 2
        error_cntl_link            = 3
        error_dp_create            = 4
        gui_type_not_supported     = 5
        OTHERS                     = 6.
    IF sy-subrc <> 0.
      MESSAGE i493(zz) WITH 'w_editor' sy-subrc.
      STOP.
    ENDIF.
  ENDIF.


  IF g_trans_mode = 'D' OR g_trans_mode = 'X' OR g_trans_mode = 'R'.
    CALL METHOD w_editor2->set_readonly_mode.

    """"""""""
    "add by lipsy on 14.1.2016
    IF  v_user_comm  = 'CHNGREPL'.
      CALL METHOD w_editor2->set_readonly_mode
        EXPORTING
          readonly_mode = 0.

    ENDIF.
    "eadd by lipsy
    """""""""
  ELSE.
    CALL METHOD w_editor2->set_readonly_mode
      EXPORTING
        readonly_mode = 0.
  ENDIF.

ENDFORM.                    " create_container
*&---------------------------------------------------------------------*
*&      Form  populate_text
*&---------------------------------------------------------------------*
*       subroutine to call FM to read & display long text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_text.

  DATA  :  BEGIN OF ist_linetab_read OCCURS 10.
          INCLUDE STRUCTURE tline.
  DATA  :  END OF ist_linetab_read.

  DATA  :  BEGIN OF ist_inlinetab OCCURS 10.
          INCLUDE STRUCTURE tline.
  DATA  :  END OF ist_inlinetab.

  DATA  :  BEGIN OF ist_src OCCURS 500,
             line(132),
           END  OF ist_src.
  DATA: l_theader LIKE thead.
  DATA: l_text(132).
  DATA: l_date(10).

  l_theader-tdid = 'NOTE'..
  l_theader-tdobject = 'ZMMVC'.
  l_theader-tdlinesize = '72'.
  l_theader-tdspras = 'E'.

  """""""""""""""""""""""""""""""
  """""added by lipsy on 28.02.2013
  IF zmm_hvencrt-reqno IS NOT INITIAL.
    ""end of addition by lipsy on 28.02.2013

    """""""""""""""""""""""""""""""""""""""""""



    CONCATENATE l_theader-tdid zmm_hvencrt-reqno INTO l_theader-tdname.


    """"""""""""""""""""""""""""""""""

    """""added by lipsy on 28.02.2013  RD1K979902


  ELSEIF zmm_vend_unblock-reqno IS NOT INITIAL.
    CONCATENATE l_theader-tdid zmm_vend_unblock-reqno INTO l_theader-tdname.

  ELSEIF zmm_vend_block-reqno IS NOT INITIAL.
    CONCATENATE l_theader-tdid zmm_vend_block-reqno INTO l_theader-tdname.

  ENDIF.

  ""end of addition by lipsy on 28.02.2013  RD1K979902



  """"""""""""""""""""""""""""""""""""

  CALL FUNCTION 'READ_TEXT_INLINE'
    EXPORTING
      id           = l_theader-tdid
      inline_count = l_theader-tdlinesize
      language     = l_theader-tdspras
      name         = l_theader-tdname
      object       = l_theader-tdobject
    TABLES
      inlines      = ist_inlinetab
      lines        = ist_linetab_read
    EXCEPTIONS
      id           = 1
      language     = 2
      name         = 3
      not_found    = 4
      object       = 5.

  CLEAR l_date.
  WRITE sy-datum TO l_date DD/MM/YYYY.

  CONCATENATE sy-uname l_date ':' INTO l_text SEPARATED BY space.

  LOOP AT ist_linetab_read.
    IF ist_linetab_read-tdline = l_text.                    "TEXT-066.
      CALL METHOD w_editor1->highlight_selection
        EXPORTING
          highlight_mode = 1.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    EXPORTING
      language    = sy-langu
    TABLES
      itf_text    = ist_linetab_read
      text_stream = ist_src.

* start of comment on 14.09.2006
*  CALL  METHOD  w_editor1->set_text_as_r3table
*              EXPORTING
*                table = ist_src[].
* end of comment on 14.09.2006

  CALL METHOD w_editor1->set_text_as_stream
    EXPORTING
      text            = ist_src[]
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.

*  call  method  w_editor2->delete_text.


ENDFORM.                    " populate_text
*&---------------------------------------------------------------------*
*&      Form  get_text
*&---------------------------------------------------------------------*
*       get text in table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_text.
  DATA  :  l_thead_upd_ind  TYPE i.
  DATA  :  l_text(132).
  DATA  :  l_date(10).
  CLEAR :  g_ltext_mod.

  CALL METHOD w_editor2->get_text_as_stream
    IMPORTING
      text                   = ist_texttable
      is_modified            = l_thead_upd_ind
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      OTHERS                 = 3.


  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      text_stream = ist_texttable
      itf_text    = ist_linetab.

  IF NOT ist_linetab[] IS INITIAL.
    g_ltext_mod = 'X'.
    CLEAR ist_linetab_temp.
    REFRESH ist_linetab_temp.
    ist_linetab_temp[] = ist_linetab[].
    CLEAR ist_linetab.
    REFRESH ist_linetab.
    ist_linetab-tdformat = '*'.

    CLEAR l_date.
    WRITE sy-datum TO l_date DD/MM/YYYY.
    CONCATENATE sy-uname l_date ':' INTO l_text SEPARATED BY space.
    ist_linetab-tdline =  l_text.          "'CREATOR:'(066).
    APPEND ist_linetab.
    APPEND LINES OF ist_linetab_temp TO ist_linetab.
  ENDIF.

  IF g_trans_mode = 'M' OR g_trans_mode = 'A' OR g_trans_mode = 'X'
"""""""""""""""""""""""""""""""""""""
    """""""""""added by lipsy on 17.06.2013 for including approval mode
    OR g_trans_mode = 'AP'OR g_trans_mode = 'RL'
    "end of addition by lipsy on 17.06.2013 for including approval mode
    """""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""""""
    "add by lipsy
    OR v_user_comm  = 'CHNGREPL'.
    "eadd by lipsy 14.01.2016
    """"""""""""""""""""""""""""""""""""""""""""""""""

    CLEAR ist_texttable. REFRESH ist_texttable.
    CALL METHOD w_editor1->get_text_as_stream
      IMPORTING
        text                   = ist_texttable
        is_modified            = l_thead_upd_ind
      EXCEPTIONS
        error_dp               = 1
        error_cntl_call_method = 2
        OTHERS                 = 3.


    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      TABLES
        text_stream = ist_texttable
        itf_text    = ist_linetab_temp.

    APPEND LINES OF ist_linetab TO ist_linetab_temp.
    ist_linetab[] = ist_linetab_temp[].
  ENDIF.



ENDFORM.                    " get_text
*&---------------------------------------------------------------------*
*&      Form  SAVE_TEXT
*&---------------------------------------------------------------------*
*       save long text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_text.
  DATA: l_theader LIKE thead.
  CLEAR l_theader.
  l_theader-tdobject   = 'ZMMVC'.
  l_theader-tdid       = 'NOTE'.
  l_theader-tdspras    =  sy-langu.
  l_theader-tdlinesize =  72.
  l_theader-tdtxtlines =  2.

  """"""""""""""""""""""""""""""""

  """""added by lipsy on 28.02.2013  RD1K979902


  IF zmm_hvencrt-reqno IS NOT INITIAL.

    ""end of addition by lipsy on 28.02.2013  RD1K979902

    """""""""""""""""
    """""""""""""""""

    """""""""""""""""""""""""""""""""""

    CONCATENATE 'NOTE' zmm_hvencrt-reqno INTO l_theader-tdname.

    """""""""""""""""""""""""""""""""""""
    """""added by lipsy on 28.02.2013 RD1K979902


  ELSEIF zmm_vend_unblock-reqno IS NOT INITIAL.
    CONCATENATE l_theader-tdid zmm_vend_unblock-reqno INTO l_theader-tdname.

  ELSEIF zmm_vend_block-reqno IS NOT INITIAL.
    CONCATENATE l_theader-tdid zmm_vend_block-reqno INTO l_theader-tdname.
  ENDIF.

  ""end of addition by lipsy on 28.02.2013 RD1K979902



  """"""""""""""""""""""""""""""""""""""



  IF NOT ist_linetab[] IS INITIAL.
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = l_theader
        savemode_direct = 'X'
      IMPORTING
        newheader       = l_theader
      TABLES
        lines           = ist_linetab
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      COMMIT  WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " SAVE_TEXT
*&---------------------------------------------------------------------*
*&      Form  get_company_code
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_HVENCRT_BUKRS  text
*----------------------------------------------------------------------*
FORM get_company_code USING    p_bukrs.
  CLEAR g_com_text.
  SELECT SINGLE butxt FROM t001 INTO g_com_text WHERE
                                     bukrs = p_bukrs.

ENDFORM.                    " get_company_code
*&---------------------------------------------------------------------*
*&      Form  get_location_text
*&---------------------------------------------------------------------*
*       get location text
*----------------------------------------------------------------------*
*      -->P_ZMM_HVENEXT_REQLOC  text
*----------------------------------------------------------------------*
FORM get_location_text USING    p_loc.

  CLEAR g_loc_text.
  SELECT SINGLE bldg FROM zlocmst INTO g_loc_text WHERE
                                locid = p_loc.

ENDFORM.                    " get_location_text
*&---------------------------------------------------------------------*
*&      Form  store_vendors
*&---------------------------------------------------------------------*
*       populate internal table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM store_vendors.
*  APPEND ist_lfa1.
*   APPEND WA_LFA5 to


  MOVE-CORRESPONDING wa_lfa5 TO ist_lfa1.
  APPEND ist_lfa1.


ENDFORM.                    " store_vendors
*&---------------------------------------------------------------------*
*&      Form  special_char
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--L_SEARCH_STRING  text
*----------------------------------------------------------------------*
FORM special_char CHANGING l_search_string.

  REPLACE '&' WITH space INTO l_search_string.
  REPLACE '.'
              WITH space INTO l_search_string.
  REPLACE ',' WITH space INTO l_search_string.
  REPLACE '-' WITH space INTO l_search_string.
  REPLACE ';' WITH space INTO l_search_string.
  REPLACE '"' WITH space INTO l_search_string.
  REPLACE '#' WITH space INTO l_search_string.
  REPLACE 'LTD' WITH space INTO l_search_string.
  REPLACE 'PVT' WITH space INTO l_search_string.
  REPLACE 'LIMITED' WITH space INTO l_search_string.

ENDFORM.                    " special_char
*&---------------------------------------------------------------------*
*&      Form  fine_search
*&---------------------------------------------------------------------*
*       populate fine search results
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fine_search.
*Begin of <RD1k960611>.
  MOVE-CORRESPONDING wa_lfa5 TO ist_lfa1.

*  APPEND ist_lfa1. " - Test SAB_PUNIT


*End of <RD1K960611>.
  MOVE-CORRESPONDING ist_lfa1 TO ist_vendor1.
  CONCATENATE ist_lfa1-name1 ist_lfa1-name2 INTO ist_vendor1-namestring.
  APPEND ist_vendor1.
ENDFORM.                    " fine_search
*&---------------------------------------------------------------------*
*&      Form  validate_bukrs
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
*      -->P_ZMM_HVENEXT_BUKRS  text
*----------------------------------------------------------------------*
FORM validate_bukrs USING    p_bukrs.
  DATA l_bukrs LIKE t001-bukrs.
  SELECT SINGLE bukrs FROM t001 INTO l_bukrs WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e002(me) WITH p_bukrs.
  ENDIF.
  IF NOT zmm_hvenext-bukrs IS INITIAL.
    PERFORM check_cc_po.
  ENDIF.
ENDFORM.                    " validate_bukrs
*&---------------------------------------------------------------------*
*&      Form  disp_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_list.
  IMPORT ist_reqn FROM MEMORY ID 'VMDATA'.
  IF sy-subrc = 0.
    IF NOT ist_reqn[] IS INITIAL.
      PERFORM generate_fcat.
      PERFORM event_get.
      PERFORM call_alv_list.
      FREE MEMORY ID 'VMDATA'.
    ELSE.
      MESSAGE e000(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " disp_list
*&---------------------------------------------------------------------*
*&      Form  GENERATE_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_fcat.
  CLEAR ist_fcat.
  REFRESH ist_fcat.

  ist_fcat-fieldname = 'REQNO'.
  ist_fcat-ref_tabname = 'ZMM_HVENCRT'.
  ist_fcat-seltext_l = text-068.
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname = 'DDTEXT'.
  ist_fcat-ref_tabname = 'ist_reqn'.
  ist_fcat-outputlen = 30.
  ist_fcat-seltext_l = text-069.
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname = 'BUKRS'.
  ist_fcat-ref_tabname = 'ZMM_HVENCRT'.
  ist_fcat-seltext_l = text-070.
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname = 'REQLOC'.
  ist_fcat-ref_tabname = 'ZMM_HVENCRT'.
  ist_fcat-seltext_l = text-071.
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname = 'ERNAM'.
  ist_fcat-ref_tabname = 'ZMM_HVENCRT'.
  ist_fcat-seltext_l = text-072.
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname = 'ERFDT'.
  ist_fcat-ref_tabname = 'ZMM_HVENCRT'.
  ist_fcat-seltext_l = text-073.
  APPEND ist_fcat.
  CLEAR ist_fcat.
* Begin of <> on 10012012
  ist_fcat-fieldname = 'RELEASED_BY'.
  ist_fcat-ref_tabname = 'ZMM_HVENCRT'.
  ist_fcat-seltext_l = text-325.
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname = 'RELEASE_DATE'.
  ist_fcat-ref_tabname = 'ist_reqn'.
  ist_fcat-outputlen = 30.
  ist_fcat-seltext_l = text-324.
  APPEND ist_fcat.
  CLEAR ist_fcat.

* End of <> on 10012012
ENDFORM.                    " GENERATE_FCAT
*&---------------------------------------------------------------------*
*&      Form  OUPUT_HEADER
*&---------------------------------------------------------------------*
*       Header to ALV_LIST DISPLAY
*----------------------------------------------------------------------*
FORM output_header.


  WRITE: / 'Db-click on request no to assign Vendor code'.

  SKIP 2.
ENDFORM.                    " OUPUT_HEADER

*&---------------------------------------------------------------------*
*&      Form  OUPUT_FOOTER
*&---------------------------------------------------------------------*
*       Header to ALV_LIST DISPLAY
*----------------------------------------------------------------------*
FORM output_footer.

  SKIP 2.
  WRITE: / 'Report Generated By:' ,sy-uname,
         / 'Report Generated On:' ,sy-datum.

ENDFORM.                    " OUPUT_HEADER

*&---------------------------------------------------------------------*
*&      Form  event_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM event_get.
  CLEAR : it_events, ls_events.
  REFRESH ls_events.

  repid = sy-repid.

  it_events-name = slis_ev_top_of_page.
  it_events-form = 'OUTPUT_HEADER'.
  APPEND it_events TO ls_events.
  CLEAR it_events.

  it_events-name = slis_ev_end_of_page.
  it_events-form = 'OUTPUT_FOOTER'.
  APPEND it_events TO ls_events.
  CLEAR it_events.

  it_events-name = 'USER_COMMAND'.
  it_events-form = 'PROCESS_USER_COMMAND'.
  APPEND it_events TO ls_events.
  CLEAR it_events .

ENDFORM.                    " event_get
*&---------------------------------------------------------------------*
*&      Form  call_alv_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_alv_list.
  l_layout-zebra                = 'X'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = repid
      is_layout          = l_layout
      it_fieldcat        = ist_fcat[]
      it_events          = ls_events
    TABLES
      t_outtab           = ist_reqn.

ENDFORM.                    " call_alv_list

*---------------------------------------------------------------------*
*       FORM process_user_command                                     *
*---------------------------------------------------------------------*
*  -->  R_UCOMM                                                       *
*  -->  RS_SELFIELD                                                   *
*---------------------------------------------------------------------*
FORM process_user_command USING r_ucomm     LIKE sy-ucomm
                                rs_selfield TYPE slis_selfield.
  CLEAR ist_reqn.
  IF rs_selfield-sel_tab_field = 'IST_REQN-REQNO'.
    ist_reqn-reqno = rs_selfield-value.
  ELSE.
    IF rs_selfield-tabindex > 0 AND
       NOT ist_reqn[] IS INITIAL.
      READ TABLE ist_reqn INDEX rs_selfield-tabindex.
    ENDIF.
  ENDIF.

  MOVE ist_reqn-reqno TO zmm_hvencrt-reqno.
  CALL SCREEN 0200.

ENDFORM.                    " call_transcation
*&---------------------------------------------------------------------*
*&      Form  chk_for_duplicate_entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_for_duplicate_entry.
  IF NOT ist_vend[] IS INITIAL AND NOT save_ok = 'DELR'.
    READ TABLE ist_vend WITH KEY vend-name1 = wa_vend-vend-name1
                                 vend-ort01 = wa_vend-vend-ort01
                                 mark = ' '
                                 TRANSPORTING NO FIELDS .
    IF sy-subrc IS INITIAL AND sy-tabix <> tab_ctl-current_line.
      MESSAGE i000(zol) WITH text-075 sy-tabix.
    ENDIF.
  ENDIF.
ENDFORM.                    " chk_for_duplicate_entry
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       Highest auth will have value 95 and auth to do all
*       Next level 78, 43
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check.
  CLEAR : g_actvt, g_frgco.

*  AUTHORITY-CHECK OBJECT 'ZMMVCE'
*                ID 'ACTVT' FIELD :'95'.
*  IF sy-subrc = 0.
*    g_actvt = '95'.
*  ELSE.

  AUTHORITY-CHECK OBJECT 'ZMMVCE'
                  ID 'ACTVT' FIELD :'78'.
  IF sy-subrc = 0.
    g_actvt = '78'.
*  ELSE.

*    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*                     ID 'FRGCO' FIELD : 'E4'.
*    IF sy-subrc = 0.
*      g_frgco = 'E4'.
*    ELSE.
*      AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*                 ID 'FRGCO' FIELD : 'OM'.
*      IF sy-subrc = 0.
*        g_frgco = 'OM'.
*      ENDIF.
*
*    ENDIF.
*    AUTHORITY-CHECK OBJECT 'ZMMVCE'
*                    ID 'ACTVT' FIELD :'01'.
*    IF sy-subrc = 0.
*      g_actvt = '01'.
*    ENDIF.
  ENDIF.


*  IF ( g_frgco = 'E4' OR g_frgco = 'OM' ) AND
*      g_actvt IS INITIAL.
*    g_actvt = '43'.
*  ENDIF.

  CASE g_actvt.
    WHEN '00'.
      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
      ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .
  ENDCASE.
ENDFORM.                    " authority_check


*&---------------------------------------------------------------------*
*&      List Processing commands
*&---------------------------------------------------------------------*

AT USER-COMMAND.
  CHECK ( g_src EQ '4' AND sy-ucomm = 'CANC' ) OR
        ( g_src NE '4' AND sy-ucomm <> 'CANC' ).
  SET SCREEN 0.
  LEAVE SCREEN.
*&---------------------------------------------------------------------*
*&      Form  get_cities_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_cities_list.

  CLEAR ist_return_tab.
*  IF ( ZMM_HVENCRT-KTOKK = 'IMMI' OR
*       ZMM_HVENCRT-KTOKK = 'SVWI' ).
  SELECT ort01 FROM zmm_cities INTO TABLE ist_cities.  "#EC CI_NOORDER
  IF sy-subrc IS INITIAL.
    SORT ist_cities ASCENDING.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'ORT01'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_cities
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    wa_vend-vend-ort01 = ist_return_tab-fieldval.
  ENDIF.
*  endif.

ENDFORM.                    " get_cities_list
*&---------------------------------------------------------------------*
*&      Form  print_preview
*&---------------------------------------------------------------------*
*       address Print Preview
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_preview.
  DATA: g_address_group LIKE tsad7-addr_group,
        BEGIN OF g_address_groups OCCURS 0.
          INCLUDE STRUCTURE adagroups.
  DATA: END OF g_address_groups,
  g_group_text LIKE tsad7t-group_text.
  DATA: g_address_number LIKE adrc-addrnumber,
        g_address_handle LIKE szad_field-handle,
        g_nation         LIKE adrc-nation,
        g_date_from      LIKE adrc-date_from.
  DATA: returncode LIKE szad_field-returncode.
  DATA: BEGIN OF error_table OCCURS 0.
          INCLUDE STRUCTURE addr_error.
  DATA: END OF error_table.
  DATA: g_addr_ref LIKE addr_ref.
*  IF g_trans_mode = 'N' OR
*     g_trans_mode = 'M'.
  CLEAR addr1_data.
  READ TABLE ist_vend INDEX g_linno.
  IF sy-subrc = 0 AND
     ist_vend-mark = 'X' AND
     NOT ist_vend-vend-land1 IS INITIAL .

    addr1_data-name1   = ist_vend-vend-name1.
    addr1_data-name2   = ist_vend-vend-stras1.
    addr1_data-name3   = ist_vend-vend-suppl1.
    addr1_data-name4   = ist_vend-vend-suppl2.
    addr1_data-city1   = ist_vend-vend-suppl3.
    addr1_data-city2   = ist_vend-vend-ort02.
    addr1_data-country = ist_vend-vend-land1.
    addr1_data-home_city = ist_vend-vend-ort01.
    CLEAR ist_vend-mark.
    MODIFY ist_vend INDEX g_linno TRANSPORTING mark.
  ELSE.
    EXIT.
  ENDIF.
  g_address_handle = 'LFA1'.
  g_address_group = 'BP'.
  g_addr_ref-addr_group = 'BP'.
  CALL FUNCTION 'ADDR_INSERT'
    EXPORTING
      address_data        = addr1_data
      address_group       = g_address_group
      address_handle      = g_address_handle
      date_from           = '00010101'
      language            = sy-langu
      check_empty_address = 'X'
      check_address       = 'X'
    IMPORTING
      address_data        = addr1_data
      returncode          = returncode
    TABLES
      error_table         = error_table
    EXCEPTIONS
      address_exists      = 1
      parameter_error     = 2
      internal_error      = 3
      OTHERS              = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'ADDRESS_SHOW_PRINTFORM'
    EXPORTING
      address_type    = '1'
      address_number  = g_address_number
      address_handle  = g_address_handle
      sender_country  = addr1_data-country
      number_of_lines = 15.

  CALL FUNCTION 'ADDR_DELETE'
    EXPORTING
      address_handle    = g_address_handle
      address_number    = g_address_number
      address_reference = g_addr_ref
*     DATE_FROM         = '00010101'
    IMPORTING
      returncode        = returncode
*     RELATIONS_EXIST   =
    TABLES
      error_table       = error_table
*   EXCEPTIONS
*     ADDRESS_NOT_EXIST = 1
*     PARAMETER_ERROR   = 2
*     INTERNAL_ERROR    = 3
*     REFERENCE_NOT_EXIST       = 4
*     OTHERS            = 5
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " print_preview
*&---------------------------------------------------------------------*
*&      Form  check_extn_mandatory_fields
*&---------------------------------------------------------------------*
*       CHECK MANDATORY FIELDS B4 VENDOR EXTENSION TO PUR ORG/COMP CODE
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_extn_mandatory_fields.
  CLEAR :
     g_cursorfield, g_cursorline.

  IF ist_extn[] IS INITIAL.
    MESSAGE e055(00).
    EXIT.
  ELSE.
    PERFORM check_cc_po.
    LOOP AT ist_extn INTO wa_extn.
      IF wa_extn-ekorg IS INITIAL.
        g_cursorfield = 'IST_EXTN-EKORG'.
        g_cursorline = sy-tabix.
        MESSAGE e055(00).
      ELSE.
        CASE wa_extn-ekorg.
          WHEN 'PMAT' OR 'PSRV'.
            CHECK wa_extn-waers IS INITIAL.
            g_cursorfield = 'IST_EXTN-WAERS'.
            g_cursorline = sy-tabix.
            MESSAGE e055(00).
          WHEN 'POBV'.
            CHECK wa_extn-waers IS INITIAL OR
                  wa_extn-werks IS INITIAL.
            IF wa_extn-waers IS INITIAL.
              g_cursorfield = 'IST_EXTN-WAERS'.
              g_cursorline = sy-tabix.
            ELSE.
              g_cursorfield = 'IST_EXTN-WERKS'.
              g_cursorline = sy-tabix.
            ENDIF.
            MESSAGE e055(00).
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " check_extn_mandatory_fields
*&---------------------------------------------------------------------*
*&      Form  extn_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM extn_status.

  IF NOT ist_bdcstatus[] IS INITIAL.
    WRITE :1(10) 'REQUEST NO' COLOR 5,
           20(20) 'VENDOR EXTN. STATUS' COLOR 5.
    SKIP 1.
    LOOP AT ist_bdcstatus.
      WRITE :/1(10) ist_bdcstatus-reqno,
              20(72) ist_bdcstatus-msgtx.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " extn_status
*&---------------------------------------------------------------------*
*&      Form  block_other_vendors
*&---------------------------------------------------------------------*
*       block vendors found in search
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM block_other_vendors.
  CLEAR ist_lfa1.
  REFRESH ist_lfa1.
  PERFORM fine_search_lfa1 USING 'X'.
  IF NOT ist_vendor1[] IS INITIAL.
    SELECT * FROM lfa1 INTO TABLE ist_lfa1 FOR ALL ENTRIES IN
                       ist_vendor1 WHERE lifnr = ist_vendor1-lifnr
                                   AND sperm <> 'X'
                                   AND sperr <> 'X'.  "#EC CI_NOORDER
    DELETE ist_lfa1 WHERE lifnr = ' '.
    PERFORM check_bsik.
  ENDIF.
  IF NOT ist_lfa1[] IS INITIAL.
    PERFORM check_po.
    PERFORM call_xk02 USING 'B'.
  ENDIF.
ENDFORM.                    " block_other_vendors
*&---------------------------------------------------------------------*
*&      Form  check_bsik
*&---------------------------------------------------------------------*
*       CHECK FI TABLES FOR VENDOR ENTRY
*       IF ENTRY FOUND AND LT 2 YEARS DONOT BLOCK ELSE BLOCK
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bsik.

  DATA : l_cutoff_date LIKE sy-datum.
  l_cutoff_date = sy-datum.
  l_cutoff_date+0(4) = l_cutoff_date+0(4) - 2.

*{-commented on 11.05.2006
*  IF NOT ist_lfa1[] IS INITIAL.
*    SELECT lifnr FROM bsik INTO CORRESPONDING FIELDS OF TABLE ist_lifnr
*               FOR ALL ENTRIES IN ist_lfa1 WHERE lifnr = ist_lfa1-lifnr
**                                          AND budat GE l_cutoff_date.
*                                                 AND budat EQ sy-datum.
*    LOOP AT ist_lifnr.
*      READ TABLE ist_lfa1 WITH KEY lifnr = ist_lifnr-lifnr
*                                   TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        DELETE ist_lfa1 INDEX sy-tabix.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*}-commented on 11.05.2006

  IF NOT ist_lfa1[] IS INITIAL.
    SELECT lifnr FROM lfc1 INTO CORRESPONDING FIELDS OF TABLE ist_lifnr
               FOR ALL ENTRIES IN ist_lfa1 WHERE lifnr = ist_lfa1-lifnr.  "#EC CI_NOORDER
*{-commented on 11.05.2006
*                                          AND erdat GE l_cutoff_date.
*}-commented on 11.05.2006

    LOOP AT ist_lifnr.
      READ TABLE ist_lfa1 WITH KEY lifnr = ist_lifnr-lifnr
                                   TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE ist_lfa1 INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " check_bsik
*&---------------------------------------------------------------------*
*&      Form  check_po
*&---------------------------------------------------------------------*
*       if vendor not found in ekko delete entry
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_po.
  DATA : ist_cdhdr LIKE STANDARD TABLE OF cdhdr WITH HEADER LINE.
  DATA : l_cutoff_date LIKE sy-datum.
  DATA : l_tabix LIKE sy-tabix.

  l_cutoff_date = sy-datum.
  l_cutoff_date+0(4) = l_cutoff_date+0(4) - 2.

  CLEAR ist_lifnr.
  REFRESH ist_lifnr.

  SELECT lifnr ebeln FROM ekko INTO CORRESPONDING FIELDS OF
                         TABLE ist_lifnr FOR ALL ENTRIES IN ist_lfa1
                          WHERE lifnr = ist_lfa1-lifnr.

  LOOP AT ist_lifnr.
    READ TABLE ist_lfa1 WITH KEY lifnr = ist_lifnr-lifnr
                                 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      DELETE ist_lfa1 INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " check_po
*&---------------------------------------------------------------------*
*&      Form  create_unblock_request
*&---------------------------------------------------------------------*
*       routine to create vendor unblock requests
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM action_unblock_request.
  IF g_trans_mode = 'N'.
    CLEAR g_message.
    CONCATENATE 'Please confirm that vendor has not been banned or banning has not been initiated.'
' Do you still want to generate a request for vendor unblock?' INTO g_message. "080911 SS
    PERFORM check_unbl_mandatory_fields.
    PERFORM confirm_user_action USING text-305 g_message. "text-306. "080911 SS
  ELSEIF g_trans_mode = 'M'.
    CLEAR g_message.

    IF wa_zmm_vend_unblock-zrelease = 'X' OR wa_zmm_vend_unblock-zapprove = 'X'.
      CONCATENATE 'Release Strategy will be reset.'
      ' Do you still want to change the request for vendor unblock?' INTO g_message.
    ELSE.
      CONCATENATE 'Please confirm that vendor has not been banned or banning has not been initiated.'
    ' Do you still want to change the request for vendor unblock?' INTO g_message. "080911 SS
    ENDIF.
    PERFORM check_unbl_mandatory_fields.
    PERFORM confirm_user_action USING text-305 g_message.   "text-311.
*Begin of <> on 02022012
  ELSEIF g_trans_mode = 'RL'.
    CLEAR g_message.
    CONCATENATE  'Please confirm that vendor has not been banned or banning has not been initiated. ' 'You also confirm that address of the vendor and other details are correct. '
  ' Do you still want to release the request for vendor unblock?' INTO g_message.
    PERFORM confirm_user_action USING text-305 g_message.   "text-326
  ELSEIF g_trans_mode = 'AP'.
    CLEAR g_message.
    CONCATENATE  'Please confirm that vendor has not been banned or banning has not been initiated. ' 'You also confirm that address of the vendor and other details are correct. '
  ' Do you still want to approve the request for vendor unblock?' INTO g_message.
    PERFORM confirm_user_action USING text-305 g_message.
* End of <> on 02022012
  ELSEIF g_trans_mode = 'X'.
    PERFORM confirm_user_action USING text-305 text-314.    "+RK004
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "added by lipsy on 10.12.2014 for updating table with IR status on changing status to ir by assigner.
    " RD1K994952
  ELSEIF g_trans_mode = 'A'.
    PERFORM confirm_user_action USING text-305 text-330.    "+RK004
    IF g_ans = '1'.
      UPDATE zmm_vend_unblock  SET reqclu = 'IR'
                             zrelease = ''
                            releasedby = ''
                            releasedon = ''
                            zapprove     = ''
                            approvedby = ''
                            approvedon = ''
                            WHERE reqno = zmm_vend_unblock-reqno.
      IF sy-subrc = 0.
        PERFORM save_text.
        PERFORM send_mail_assrej.
        PERFORM send_sms_assrej USING zmm_vend_unblock-reqno
                               zmm_vend_unblock-ernam.
        PERFORM clear_scr_310.
        LEAVE TO SCREEN '400'.
      ENDIF.
    ENDIF.
    "end of addition  by lipsy on 10.12.2014 for updating table with IR status on  changing status to ir by assigner.
    " RD1K994952
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  ENDIF.
  IF g_ans = '1'.
    PERFORM modify_db_unbl.
  ENDIF.

ENDFORM.                    " create_unblock_request
*&---------------------------------------------------------------------*
*&      Form  check_unbl_mandatory_fields
*&---------------------------------------------------------------------*
*       check mandatory fields
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_unbl_mandatory_fields.
  IF ist_unbl[] IS INITIAL.
    MESSAGE e055(00).
    EXIT.
  ELSE.

* Begin of <> on 05012011
    LOOP AT ist_unbl.
      """""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 5.12.2014 for  correction of block check box " RD1K994952

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ist_unbl-lifnr
        IMPORTING
          output = g_lifnr_check.

      READ TABLE ist_unbl_temp INTO wa_unbl_temp WITH KEY lifnr = g_lifnr_check.

      ""end of addition by lipsy on 5.12.2014 for correction of block check box " RD1K994952
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "commented by lipsy on 5.12.2014 for  correction of block check box " RD1K994952
*      READ TABLE ist_unbl_temp into wa_unbl_temp with key lifnr = ist_unbl-lifnr.
      ""end of comment by lipsy on 5.12.2014 for  correction of block check box " RD1K994952
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      IF sy-subrc = 0.
        CONCATENATE wa_unbl_temp-sperm wa_unbl_temp-sperr wa_unbl_temp-blrfq wa_unbl_temp-loevm INTO g_strlen1.
      ENDIF.
      CONCATENATE ist_unbl-sperm ist_unbl-sperr ist_unbl-blrfq ist_unbl-loevm INTO g_strlen2.

*      if strlen( g_strlen1 ) < '4'.
      IF NOT g_strlen2 IS INITIAL.  "SS 03082011
        IF g_strlen2 >= g_strlen1. "g_strlen2 <= g_strlen1. 19042011 20042011

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """"""""""added by lipsy on 12.12.2014 to remove error in change mode if already returned from
          "assigner " RD1K994952

          IF   ist_unbl-reqclu = 'IR'.
          ELSE.

            """"""end of add by lipsy on 12.12.2014 to remove error in change mode if already returned from
            "assigner " RD1K994952
            """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
            MESSAGE e238(zmm).

            """"""""""""""""""""""""""""""""""""""""""""""""""""
            """"""""""added by lipsy on 12.12.2014 to remove error in change mode if already returned from
            "assigner " RD1K994952
          ENDIF.
          """"""end of add by lipsy on 12.12.2014 to remove error in change mode if already returned from
          "assigner " RD1K994952
          """""""""""""""""""""""""""""""""""""""""""""""""""""""
        ENDIF.
      ENDIF.
*      endif.

    ENDLOOP.
* End of <> on 05012011
    LOOP AT ist_unbl.
      IF ist_unbl-lifnr IS INITIAL OR ist_unbl-rsn IS INITIAL.
        IF ist_unbl-lifnr IS INITIAL.
          g_cursorfield = 'IST_UNBL-LIFNR'.
          g_cursorline = sy-tabix.
        ELSE.
          g_cursorfield = 'IST_UNBL-RSN'.
          g_cursorline = sy-tabix.
        ENDIF.
        MESSAGE e055(00).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " check_unbl_mandatory_fields
*&---------------------------------------------------------------------*
*&      Form  modify_db_unbl
*&---------------------------------------------------------------------*
*       UPDATE DB TABLE
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_db_unbl.
  CLEAR :g_crt1, g_req_num.

  IF g_trans_mode = 'N'.
    PERFORM generate_request USING c_nr_object1
                             CHANGING g_req_num.
  ENDIF.
*
*  IF g_trans_mode = 'A' .
*    PERFORM update_mobnum.
*    PERFORM update_email.
*  ENDIF.

  PERFORM lock_table_unbl.
*  PERFORM update_zmm_vend_unblock ON COMMIT.
  IF g_crt1 IS INITIAL.

    PERFORM update_zmm_vend_unblock.
    COMMIT WORK AND WAIT .
    PERFORM display_message USING g_trans_mode 'S'.
  ELSE.
*    ROLLBACK WORK.
    PERFORM display_message USING g_trans_mode 'A'.
  ENDIF.
  PERFORM unlock_table_unbl.


  """""""""""""""""""""""""""""""""""""""""


  """"""""added by lipsy on 28.02.2013
  IF g_trans_mode = 'N' OR  g_trans_mode = 'M' OR g_trans_mode = 'AP' OR g_trans_mode = 'RL'.

    PERFORM save_text.
  ENDIF.

  IF g_trans_mode = 'M' .
    DATA  :  BEGIN OF ist_linetab_read OCCURS 10.
            INCLUDE STRUCTURE tline.
    DATA  :  END OF ist_linetab_read.

    DATA  :  BEGIN OF ist_inlinetab OCCURS 10.
            INCLUDE STRUCTURE tline.
    DATA  :  END OF ist_inlinetab.

    DATA  :  BEGIN OF ist_src OCCURS 500,
               line(132),
             END  OF ist_src.
    DATA: l_theader LIKE thead.
    DATA: l_text(132).
    DATA: l_date(10).

    l_theader-tdid = 'NOTE'..
    l_theader-tdobject = 'ZMMVC'.
    l_theader-tdlinesize = '72'.
    l_theader-tdspras = 'E'.
    """""""""""""""""""""""""



    """""""""""""""""""""""""
    """""added by lipsy on 28.02.2013
    IF zmm_vend_unblock-reqno IS NOT INITIAL.
      CONCATENATE l_theader-tdid zmm_vend_unblock-reqno INTO l_theader-tdname.
    ENDIF.
    ""end of addition by lipsy on 28.02.2013
    """""""""""""""""

    """"""""""""""""
    CALL FUNCTION 'READ_TEXT_INLINE'
      EXPORTING
        id           = l_theader-tdid
        inline_count = l_theader-tdlinesize
        language     = l_theader-tdspras
        name         = l_theader-tdname
        object       = l_theader-tdobject
      TABLES
        inlines      = ist_inlinetab
        lines        = ist_linetab_read
      EXCEPTIONS
        id           = 1
        language     = 2
        name         = 3
        not_found    = 4
        object       = 5.

    CLEAR:v_lines_old,v_lines_new.


    DESCRIBE TABLE ist_inlinetab[] LINES v_lines_old.

    DESCRIBE TABLE ist_linetab_temp[] LINES v_lines_new.



    READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH  KEY reqno = zmm_vend_unblock-reqno.

    IF sy-subrc = 0.
      IF v_lines_new NE v_lines_old.

        IF wa_zmm_vend_unblock-reqclu = 'IR'.
          IF sy-uname = zmm_vend_unblock-ernam.
            UPDATE zmm_vend_unblock  SET reqclu = 'IC'
                                         WHERE reqno = wa_zmm_vend_unblock-reqno.
          ENDIF.
        ELSEIF wa_zmm_vend_unblock-reqclu = 'N'.
          UPDATE zmm_vend_unblock  SET reqclu = 'IC'
                                       WHERE reqno = wa_zmm_vend_unblock-reqno.

        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

  """"""""""added by lipsy on 28.02.2013

  """"""""""""""""""""""""""""""""""""""""


ENDFORM.                    " modify_db_unbl
*&---------------------------------------------------------------------*
*&      Form  lock_table_unbl
*&---------------------------------------------------------------------*
*       LOCK TABLE zmm_vend_unblock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_table_unbl.
  CALL FUNCTION 'ENQUEUE_EZMM_VEND_UNBL'
    EXPORTING
      mode_zmm_vend_unblock = 'E'
      mandt                 = sy-mandt
      reqno                 = zmm_vend_unblock-reqno
*     SEQNO                 =
*     X_REQNO               = ' '
*     X_SEQNO               = ' '
*     _SCOPE                = '2'
*     _WAIT                 = ' '
*     _COLLECT              = ' '
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " lock_table_unbl
*&---------------------------------------------------------------------*
*&      Form  update_zmm_vend_unblock
*&---------------------------------------------------------------------*
*       update table zmm_vend_unblock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_vend_unblock.
  DATA : l_adrnr    TYPE lfa1-adrnr, "04082011 SS
         l_date(10).
  CLEAR :ist_zmm_vend_unblock, wa_zmm_vend_unblock.
  IF NOT ist_unbl[] IS INITIAL.
    LOOP AT ist_unbl.
      MOVE-CORRESPONDING ist_unbl TO wa_zmm_vend_unblock.
*      wa_zmm_vend_unblock-zpstlz = ist_unbl-pstlz.                 "05032012
      IF g_trans_mode = 'N'.
        wa_zmm_vend_unblock-reqno = zmm_vend_unblock-reqno.
        wa_zmm_vend_unblock-sperq = zmm_vend_unblock-sperq.
        wa_zmm_vend_unblock-bukrs = zmm_vend_unblock-bukrs.
        wa_zmm_vend_unblock-erfdt = sy-datum.
        wa_zmm_vend_unblock-ernam = sy-uname.

        """""""""""""""""""""""""""""
        "added by lipsy on 27.02.2013 for updating request status in table  RD1K979902
        wa_zmm_vend_unblock-reqclu = 'N'.
        "end of add by lipsy on 27.02.2013 for updating request status in table RD1K979902

        """""""""""""""""""""""""""""""""""
      ELSEIF g_trans_mode = 'M'  .
        wa_zmm_vend_unblock-reqno = zmm_vend_unblock-reqno.
        wa_zmm_vend_unblock-sperq = zmm_vend_unblock-sperq.
        wa_zmm_vend_unblock-bukrs = zmm_vend_unblock-bukrs.
        wa_zmm_vend_unblock-erfdt = zmm_vend_unblock-erfdt.
        wa_zmm_vend_unblock-ernam = zmm_vend_unblock-ernam.
        IF wa_zmm_vend_unblock-zrelease = 'X' OR wa_zmm_vend_unblock-zapprove = 'X'.
          CLEAR : wa_zmm_vend_unblock-zrelease,
                  wa_zmm_vend_unblock-releasedby,
                  wa_zmm_vend_unblock-releasedon,
                  wa_zmm_vend_unblock-zapprove,
                  wa_zmm_vend_unblock-approvedby,
                  wa_zmm_vend_unblock-approvedon.
        ENDIF.
        """"""""""""""""""""""""""""""""""""
        """"""""""""""""""""""""""""""

        """"""""""""""""""
        "addition  by lipsy 12.12.2014 for keeping request status
        "as 'IR' if returned from assigner " RD1K994952
        IF zmm_vend_unblock-reqclu = 'IR'.
        ELSE.
          "end of addition   by lipsy 12.12.2014 for keeping request status
          " as 'IR' if returned from assigner " RD1K994952
          """""""""""""""""""""""
          "added by lipsy on 13.03.2013 for updating request status in table  RD1K979902
          wa_zmm_vend_unblock-reqclu = 'N'.
          "end of add by lipsy on 13.03.2013 for updating request status in table RD1K979902

          """"""""""""""""""""""""""""""""""
          "addition  by lipsy 12.12.2014 for keeping request status
          " as 'IR' if returned from assigner " RD1K994952



        ENDIF.
        "end of addition  by lipsy 12.12.2014 for keeping request status
        " as 'IR' if returned from assigner " RD1K994952
        """""""""""""""""""""""""""""""""""""""


* Begin of <> on 02022012
      ELSEIF g_trans_mode = 'RL'  .
        wa_zmm_vend_unblock-reqno = zmm_vend_unblock-reqno.
        wa_zmm_vend_unblock-sperq = zmm_vend_unblock-sperq.
        wa_zmm_vend_unblock-bukrs = zmm_vend_unblock-bukrs.
        wa_zmm_vend_unblock-zrelease   = 'X'.
        wa_zmm_vend_unblock-releasedon = sy-datum.
        wa_zmm_vend_unblock-releasedby = sy-uname.

        """"""""""""""""""""""""""""
        "addition by lipsy 12.12.2014 for keeping request status
        "as 'IR' if returned from assigner " RD1K994952
        IF zmm_vend_unblock-reqclu = 'IR'.
        ELSE.
          "end of addition   by lipsy 12.12.2014 for keeping request status
          "as 'IR' if returned from assigner " RD1K994952
          """""""""""""""""""
          "added by lipsy on 27.02.2013 for updating request status in table  RD1K979902
          wa_zmm_vend_unblock-reqclu = 'N'.
          "end of add by lipsy on 27.02.2013 for updating request status in table RD1K979902
          """""""""""""""""""""
          "addition by lipsy 12.12.2014 for keeping request status
          " as 'IR' if returned from assigner " RD1K994952

        ENDIF.
        "end of addition   by lipsy 12.12.2014 for keeping request status
        "as 'IR' if returned from assigner" RD1K994952
        """"""""""""""""""""""""


      ELSEIF g_trans_mode = 'AP'  .
        """"""""""""""""""""""""""""""""

        """""""""""""""""""""""""""""""""""""


        wa_zmm_vend_unblock-reqno = zmm_vend_unblock-reqno.
        wa_zmm_vend_unblock-sperq = zmm_vend_unblock-sperq.
        wa_zmm_vend_unblock-bukrs = zmm_vend_unblock-bukrs.


        """""""""""""""""""""""""""""""""""""
        "added by lipsy on 04.03.2013 for rejection by approver
        IF ist_unbl-rejnu = 'Rejected by Approver'.
          PERFORM send_mail_assign.
        ELSE.
          "end of add by lipsy on 04.03.2013 for rejection by approver

          """""""""""""""""""""""""""""""""""""""""
          wa_zmm_vend_unblock-zapprove   = 'X'.
          wa_zmm_vend_unblock-approvedon = sy-datum.
          wa_zmm_vend_unblock-approvedby = sy-uname.

          """""""""""""""""""""""""""""""""""""""""""""
          """""""""""""""""""""""""
          "added by lipsy on 27.02.2013 for updating request status in table  RD1K979902
          """""""""""""""

          """"""""""""""
          """""""""""""""""""""""""""""""""""""""""""""""
          "addition by lipsy 12.12.2014 for keeping request status
          "as 'IR' if returned from assigner " RD1K994952
          IF zmm_vend_unblock-reqclu = 'IR'.
            wa_zmm_vend_unblock-reqclu = 'IC'.

          ENDIF.
          "end of addition   by lipsy 12.12.2014 for keeping request status
          "as 'IR' if returned from assigner" RD1K994952
          """"""""""""""""""""""""

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.
        "end of add by lipsy on 27.02.2013 for updating request status in table RD1K979902


        """""""""""""""""""""""""""""

        """""""""""""""""""""""""""""""""""""""""""""

* End of <> on 02022012
      ELSEIF g_trans_mode = 'A'.
        """"""""""""""""""""""""""""
        "added by lipsy on 4.03.2013
        IF ist_unbl-rejnu = 'Rejected by Assigner'.
          CLEAR:wa_unbl_rej.
          READ TABLE ist_unbl INTO wa_unbl_rej WITH  KEY  rejnu =  'Rejected by Assigner'.
          IF sy-subrc = 0.
            READ TABLE ist_unbl INTO wa_unbl_rej WITH  KEY  rejnu =  ''.
            IF sy-subrc = 0.
            ELSE.
              g_crt1 = 'X'.
            ENDIF.
          ENDIF.
        ELSE.

          IF ist_unbl-rejnu = 'Rejected by Approver'.

          ELSE.
            "end of addition by lipsy on 4.03.2013

            """"""""""""""""""""""""""


            wa_zmm_vend_unblock-ass_flag   = 'X'.
            wa_zmm_vend_unblock-assigned_by = sy-uname.
            wa_zmm_vend_unblock-assign_date = sy-datum.

            """"""""""""""""""""""""""
            """""""""""""""""
            "added by lipsy on 4.03.2013
          ENDIF.
        ENDIF.
        "end of addition by lipsy on 4.03.2013
        """""""""""
        """"""""""""""""""""""""""""
      ENDIF.
      APPEND wa_zmm_vend_unblock TO ist_zmm_vend_unblock.
*    ENDLOOP.    "04082011 SS
*{+RK004
      IF g_trans_mode = 'X'.

*      READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH
*                                      KEY del_flag = 'X'.
*      IF sy-subrc = 0.
*        DELETE FROM zmm_vend_unblock
*               WHERE reqno = zmm_vend_unblock-reqno
*               AND del_flag = 'X'.
*      ELSE.
        DELETE FROM zmm_vend_unblock
               WHERE reqno = zmm_vend_unblock-reqno.
*      ENDIF.
        IF sy-subrc <> 0.
          g_crt1 = 'X'.
        ENDIF.
        EXIT.
      ENDIF.
*}+RK004
      IF g_trans_mode = 'M'.
        DELETE FROM zmm_vend_unblock WHERE reqno = zmm_vend_unblock-reqno.
        IF sy-subrc <> 0.
          g_crt1 = 'X'.
          EXIT.
        ENDIF.
      ENDIF.

      MODIFY zmm_vend_unblock FROM TABLE ist_zmm_vend_unblock.
      IF sy-subrc <> 0.
        g_crt1 = 'X'.
      ELSE.
* Begin of <> on 04082011
        IF g_trans_mode = 'A'OR g_trans_mode = 'N' OR g_trans_mode = 'M'.
* Begin of <> on 16022012
          IF NOT ist_unbl-pstlz IS INITIAL.
            PERFORM update_postal.
          ENDIF.
*          if not ist_unbl-email is initial.
** Begin of <> on 06012012
**            update lfa1 set : pstlz = ist_unbl-pstlz
**                        where lifnr =  ist_unbl-lifnr.
*** End of <> on 06012012
*
*
** End of <> on 16022012
**COMMIT WORK AND WAIT .
**
*
*            SELECT SINGLE adrnr FROM lfa1 INTO l_adrnr WHERE
*                                    lifnr = ist_unbl-lifnr.
*            wa_adr6-addrnumber = l_adrnr.
*            l_date = '01010001'.
*            CALL FUNCTION 'CONVERT_DATE_INPUT'
*              EXPORTING
*                INPUT                          = L_DATE
*               PLAUSIBILITY_CHECK              = 'X'
*             IMPORTING
*               OUTPUT                          = wa_adr6-DATE_FROM
**             EXCEPTIONS
**               PLAUSIBILITY_CHECK_FAILED       = 1
**               WRONG_FORMAT_IN_INPUT           = 2
**               OTHERS                          = 3
*                      .
*            IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*            ENDIF.
*
**            wa_adr6-DATE_FROM  = '00010101'.
*            wa_adr6-CONSNUMBER = '001'.
*
*            wa_adr6-FLGDEFAULT = 'X'.
*            wa_adr6-HOME_FLAG  = 'X'.
*            wa_adr6-smtp_addr  = ist_unbl-email.
*            wa_adr6-SMTP_SRCH  = ist_unbl-email.
*            TRANSLATE wa_adr6-SMTP_SRCH  to UPPER CASE.
*            modify adr6 from wa_adr6.
*          endif.


*        PERFORM update_mobile_email.

          IF g_trans_mode = 'A'.
            PERFORM update_mobnum.
            PERFORM update_email.
          ENDIF.
        ELSEIF g_trans_mode = 'RL'.
*          message i942(zmm) with zmm_vend_unblock-reqno.
          CONCATENATE wa_zmm_vend_unblock-lifnr l_lfnr INTO l_lfnr SEPARATED BY space.
        ELSEIF g_trans_mode = 'AP'.
          """""""""""""""""""""""""""""""
          "added by lipsy on 4.03.2013
          CLEAR:wa_unbl_rej.
          READ TABLE ist_unbl INTO wa_unbl_rej WITH  KEY  rejnu = 'Rejected by Approver'.
          IF sy-subrc = 0.
            READ TABLE ist_unbl INTO wa_unbl_rej WITH  KEY  rejnu =  ''.
            IF sy-subrc = 0.


              "end of addition by lipsy on 4.03.2013

              """"""""""""""""""""""""""""""""""
*              message i944(zmm) with zmm_vend_unblock-reqno. "cab_dns
              CONCATENATE wa_zmm_vend_unblock-lifnr l_lfnr INTO l_lfnr SEPARATED BY space.


              """"""""""""""""""""""""""""""""
              "added by lipsy on 4.03.2013
            ELSE.
            ENDIF.
          ELSE.
*            message i944(zmm) with zmm_vend_unblock-reqno. "cab_dns
            CONCATENATE wa_zmm_vend_unblock-lifnr l_lfnr INTO l_lfnr SEPARATED BY space.
          ENDIF.
          "end of addition by lipsy on 4.03.2013

          """"""""""""""""""""""""""""""""""""
        ENDIF.
* End of <> on 04082011
      ENDIF.
    ENDLOOP. "04082011 SS

    IF g_trans_mode = 'RL' AND l_lfnr IS NOT INITIAL.
      MESSAGE i942(zmm) WITH zmm_vend_unblock-reqno.
    ELSEIF g_trans_mode = 'AP' AND l_lfnr IS NOT INITIAL.
      MESSAGE i944(zmm) WITH zmm_vend_unblock-reqno.
    ENDIF.
    CLEAR l_lfnr.
  ENDIF.
ENDFORM.                    " update_zmm_vend_unblock
*&---------------------------------------------------------------------*
*&      Form  unlock_table_unbl
*&---------------------------------------------------------------------*
*       UNLOCK TABLE zmm_vend_unblock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_table_unbl.
  CALL FUNCTION 'DEQUEUE_EZMM_VEND_UNBL'
    EXPORTING
      mode_zmm_vend_unblock = 'E'
      mandt                 = sy-mandt
      reqno                 = zmm_vend_unblock-reqno
*     SEQNO                 =
*     X_REQNO               = ' '
*     X_SEQNO               = ' '
*     _SCOPE                = '3'
*     _SYNCHRON             = ' '
*     _COLLECT              = ' '
    .

ENDFORM.                    " unlock_table_unbl
*&---------------------------------------------------------------------*
*&      Form  unblock_bdc
*&---------------------------------------------------------------------*
*       unblock vendor
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unblock_bdc.
  CLEAR g_ans.
  """"""""""""""""""""""""""""
  """"added by lipsy on 19.12.2014 for giving unblock message for ir status  RD1K994952
  IF zmm_vend_unblock-reqclu = 'IR'.

    MESSAGE 'Request status is IR,cannot be unblocked' TYPE 'E'.

  ENDIF.
  """"end of addition by lipsy on 19.12.2014 for giving unblock message for ir status  RD1K994952
  """"""""""""""""""""""""""""""""""""""
  PERFORM confirm_user_action USING text-307 text-308.
  IF g_ans = '1'.
    PERFORM call_xk02 USING 'U'.
  ENDIF.

ENDFORM.                    " unblock_bdc
*&---------------------------------------------------------------------*
*&      Form  call_xk02
*&---------------------------------------------------------------------*
*       Unblock vendor through BDC
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_xk02 USING p_flag.
  DATA :
    l_block_str(72),
    l_rowcount(2)   TYPE n,
    g_task_no(20).

  CLEAR :
    ist_bdcdata, ist_bdcstatus, ist_lfa1, g_index.
  REFRESH :
    ist_bdcdata. " ist_bdcdata, ist_bdcstatus, ist_lfa1.   "16020212 17022012

  IF p_flag = 'U'.
    LOOP AT ist_unbl WHERE del_flag = ' '.
      MOVE-CORRESPONDING ist_unbl TO ist_lfa1.

*+SP006 - RFQ Unblock
      """"""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""""added by lipsy on 19.12.2014 for addition of zeroes to
*lifnr " RD1K994952

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ist_unbl-lifnr
        IMPORTING
          output = g_lifnr_rfq.

      SELECT SINGLE sperq FROM lfa1 INTO (ist_lfa1-sperq)
                       WHERE lifnr = g_lifnr_rfq.


      """"""""""""""""end of addition by lipsy on 19.12.2014 for addition of zeroes to
*lifnr" RD1K994952
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""""commented by lipsy on 19.12.2014 for addition of zeroes to
*lifnr " RD1K994952

*      SELECT SINGLE SPERQ FROM lfa1 INTO (ist_lfa1-sperq)
*                    WHERE lifnr = ist_unbl-lifnr.



      """"""""""""""""end of comment by lipsy on 19.12.2014 for addition of zeroes to
*lifnr" RD1K994952
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


      IF ist_lfa1-sperq = '05' AND
         ist_unbl-blrfq <> 'X'.
        CLEAR ist_lfa1-sperq.
      ENDIF.
*+SP006

      APPEND ist_lfa1.
    ENDLOOP.
  ENDIF.

  LOOP AT ist_lfa1.

    CLEAR l_block_str.
    g_index = sy-tabix.

    IF p_flag = 'B'.
      ist_lfa1-sperm = 'X'.
      ist_lfa1-sperr = 'X'.
      CONCATENATE text-312 zmm_hvencrt-reqno INTO l_block_str
                                             SEPARATED BY space.
    ELSE.
*      ist_lfa1-sperm = ' '.                                 "-SP006
*      ist_lfa1-sperr = ' '.                                 "-SP006
      CONCATENATE text-309 zmm_vend_unblock-reqno INTO l_block_str
                                                  SEPARATED BY space.
    ENDIF.

    """""""""""""""""""""""""""""""""
    """"""""""
    "added by lipsy on 4.03.2013
    CLEAR:wa_unbl_rej.
    READ TABLE  ist_unbl INTO wa_unbl_rej WITH  KEY lifnr = ist_lfa1-lifnr.
    IF sy-subrc = 0.
      IF   wa_unbl_rej-rejnu =  'Rejected by Assigner'
        OR wa_unbl_rej-rejnu =  'Rejected by Approver'.
      ELSE.

        "end of addition by lipsy on 4.03.2013

        """""""""""""

        """""""""""""""""""""""""""""""
* Begin of <> on 05032012
        PERFORM bdc_operation_xk02.
** Begin of <> on 07122010
*    perform bdc_dynpro      using 'SAPMF02K' '0101'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'RF02K-D0110'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '/00'.
*    perform bdc_field       using 'RF02K-LIFNR'
*                                  ist_lfa1-lifnr.
*    perform bdc_field       using 'RF02K-D0110'
*                                  'X'.           "record-D0110_002.
*    perform bdc_dynpro      using 'SAPMF02K' '0110'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'LFA1-NAME1'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '=0510'.
**    perform bdc_field       using 'LFA1-NAME1'
**                                  record-NAME1_003.
**    perform bdc_field       using 'LFA1-SORTL'
**                                  record-SORTL_004.
**    perform bdc_field       using 'LFA1-STRAS'
**                                  record-STRAS_005.
**    perform bdc_field       using 'LFA1-ORT01'
**                                  record-ORT01_006.
**    perform bdc_field       using 'LFA1-PSTLZ'
**                                  record-PSTLZ_007.
**    perform bdc_field       using 'LFA1-LAND1'
**                                  record-LAND1_008.
**    perform bdc_field       using 'LFA1-REGIO'
**                                  record-REGIO_009.
**    perform bdc_field       using 'LFA1-SPRAS'
**                                  record-SPRAS_010.
*    perform bdc_dynpro      using 'SAPMF02K' '0510'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'LFA1-SPERR'. "'LFA1-SPERQ'. 05032012
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '/00'.         "'=PF03'. 05032012
*    if ist_lfa1-sperr is initial.                     "if added on 02032012
*      perform bdc_field       using 'LFA1-SPERR'
*                                    ist_lfa1-sperr.
*    endif.
*    if ist_lfa1-sperm is initial.                     "if added on 02032012
*      perform bdc_field       using 'LFA1-SPERM'
*                                    ist_lfa1-sperm.
*    endif.
**+SP006 - RFQ Block
*    if p_flag = 'U'.
*      if ist_lfa1-sperq is initial.                     "if added on 02032012
*        PERFORM bdc_field       USING 'LFA1-SPERQ'
*                                      ist_lfa1-sperq.
*      endif.
*    else.                                                   "02032012
*      if ist_lfa1-sperq is initial.                  "if added on 02032012
*        PERFORM bdc_field       USING 'LFA1-SPERQ'
*                                      ist_lfa1-sperq.
*      endif.
*    endif.
**+SP006
*    PERFORM get_textlines CHANGING l_rowcount.
*
**    perform bdc_field       using 'LFA1-SPERQ'
**                                  ist_lfa1-sperq.
** Begin of <> on 05032012
*    perform bdc_dynpro      using 'SAPMF02K' '0510'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'LFA1-SPERQ'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '=PF03'.
** End of <> on 05032012
*    perform bdc_dynpro      using 'SAPMF02K' '0110'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'LFA1-NAME1'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '=0520'.
**    perform bdc_field       using 'LFA1-NAME1'
**                                  record-NAME1_014.
**    perform bdc_field       using 'LFA1-SORTL'
**                                  record-SORTL_015.
**    perform bdc_field       using 'LFA1-STRAS'
**                                  record-STRAS_016.
**    perform bdc_field       using 'LFA1-ORT01'
**                                  record-ORT01_017.
**    perform bdc_field       using 'LFA1-PSTLZ'
**                                  record-PSTLZ_018.
**    perform bdc_field       using 'LFA1-LAND1'
**                                  record-LAND1_019.
**    perform bdc_field       using 'LFA1-REGIO'
**                                  record-REGIO_020.
**    perform bdc_field       using 'LFA1-SPRAS'
**                                  record-SPRAS_021.
** Begin of <> on 05032012
**    perform bdc_dynpro      using 'SAPMF02K' '0520'.
**    perform bdc_field       using 'BDC_CURSOR'
**                                  'LFA1-LOEVM'.
**    perform bdc_field       using 'BDC_OKCODE'
**                                  '=UPDA'.
*    perform bdc_dynpro      using 'SAPMF02K' '0520'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'LFA1-LOEVM'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '/00'.
** End of <> on 056032012
*    if ist_lfa1-loevm is initial.                  "if added on 02032012
*      perform bdc_field       using 'LFA1-LOEVM'
*                                    ist_lfa1-loevm.
*    endif.
** Begin of <> on 05032012
*    perform bdc_dynpro      using 'SAPMF02K' '0520'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'RF02K-LIFNR'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '=UPDA'.
*
** End of <> on 05032012
**    PERFORM bdc_dynpro      USING 'SAPMF02K' '0101'.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  'USE_ZAV'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '/00'.
**    PERFORM bdc_field       USING 'RF02K-LIFNR'
**                                  ist_lfa1-lifnr.
**    PERFORM bdc_field       USING 'RF02K-D0110'
**                                  'X'.
**    PERFORM bdc_field       USING 'USE_ZAV'
**                                  'X'.
**    PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=0510'.
**    PERFORM bdc_dynpro      USING 'SAPMF02K' '0510'.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  'LFA1-SPERM'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=TEXT'.
**    PERFORM bdc_field       USING 'LFA1-SPERM'
**                                  ist_lfa1-sperm.
**    PERFORM bdc_field       USING 'LFA1-SPERR'
**                                  ist_lfa1-sperr.
**
***+SP006 - RFQ Block
**    if p_flag = 'U'.
**      PERFORM bdc_field       USING 'LFA1-SPERQ'
**                                    ist_lfa1-sperq.
**    endif.
***+SP006
**    PERFORM get_textlines CHANGING l_rowcount.
**
*** Begin of <> on 06122010
**    perform bdc_dynpro      using 'SAPMF02K' '0520'.
**    perform bdc_field       using 'BDC_CURSOR'
**                                  'LFA1-LOEVM'.
**    perform bdc_field       using 'BDC_OKCODE'
**                                   '=UPDA'.
**    PERFORM bdc_field       USING 'LFA1-LOEVM'
**                                  ist_lfa1-loevm.
*** End of <> on 06122010
**
**    PERFORM bdc_dynpro      USING 'SAPLFTXT' '0100'.
**
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  'RTEXT-LTEXT(02)'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=TEDE'.
**    PERFORM bdc_dynpro      USING 'SAPLSTXX' '1100'.
**
**    CONCATENATE 'RSTXT-TXLINE(' l_rowcount ')' INTO
**                                              g_task_no.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  g_task_no.
**    IF NOT tlinetab[] IS INITIAL.
**
**      PERFORM bdc_field       USING 'BDC_OKCODE'
**                                    '=EDNP'.
***      l_rowcount = l_rowcount + 1.
***
***      CONCATENATE 'RSTXT-TXLINE(' l_rowcount ')' INTO
***                                          g_task_no.
**    ENDIF.
***    PERFORM bdc_field       USING 'BDC_CURSOR'
***                                  'RSTXT-TXLINE(02)'.
**    PERFORM bdc_dynpro      USING 'SAPLSTXX' '1100'.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  g_task_no.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=TXVB'.
**    PERFORM bdc_field       USING g_task_no
**                                  l_block_str.
***    PERFORM bdc_field       USING 'RSTXT-TXLINE(02)'
***                                  l_block_str.
**    PERFORM bdc_dynpro      USING 'SAPLSTXX' '1100'.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  g_task_no.
***    PERFORM bdc_field       USING 'BDC_CURSOR'
***                                  'RSTXT-TXLINE(02)'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=TXBA'.
**    PERFORM bdc_dynpro      USING 'SAPLFTXT' '0100'.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  'TXT01'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=BACK'.
**    PERFORM bdc_dynpro      USING 'SAPMF02K' '0510'.
**    PERFORM bdc_field       USING 'BDC_CURSOR'
**                                  'LFA1-SPERQ'.
**    PERFORM bdc_field       USING 'BDC_OKCODE'
**                                  '=UPDA'.
** End of <> on 07122010
** End of <> on 02032012
* End of <> on 05032012
        PERFORM background TABLES ist_bdcstatus2
                                           USING  'XK02'       " s_tcode
                                                  'N'     " 'A' " s_mode
                                                  'A'          " s_update
                                                  zmm_vend_unblock-reqno
                                                  p_flag.  "#EC CI_USAGE_OK[2226131]

        CLEAR :
           ist_unbl,ist_bdcdata,tlinetab,tinlinetab.
        REFRESH :
           ist_bdcdata,tlinetab,tinlinetab.

        IF NOT ist_bdcstatus[] IS INITIAL.
          READ TABLE ist_bdcstatus INDEX 1.
          IF ist_bdcstatus-msgtyp = 'E'.
            MESSAGE e321(zmm) WITH ist_bdcstatus-msgtx.  "Message 042(F2)
          ENDIF.
        ENDIF.

        """"""""""""""""""""""""""""""
        """"""""""""""
        "added by lipsy on 4.03.2013
      ENDIF.
    ENDIF.
    "end of addition  by lipsy on 4.03.2013
    """""""""

    """"""""""""""""""""""""""""""""
  ENDLOOP.

  REFRESH : ist_lfa1,ist_bdcstatus .                        "16022012
  CLEAR :  g_vend_err.
ENDFORM.                                                    " call_xk02
*&---------------------------------------------------------------------*
*&      Form  update_ztable
*&---------------------------------------------------------------------*
*       uptable ztable after assign vendor unblock action
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_ztable.

  CLEAR :g_crt1.
  CHECK g_ans = 1.

  IF g_vend_err IS INITIAL.

    PERFORM lock_table_unbl.
* PERFORM update_zmm_vend_unblock ON COMMIT.

    IF g_crt1 IS INITIAL.
      PERFORM update_zmm_vend_unblock.
      COMMIT WORK AND WAIT.
      PERFORM send_mail.                                    "10012012
      MESSAGE s730(zmm) WITH zmm_vend_unblock-reqno.

    ELSE.

      ROLLBACK WORK.
      MESSAGE e735(zmm) WITH text-310.

    ENDIF.

    PERFORM unlock_table_unbl.

    """"""""added by lipsy on 28.02.2013 RD1K979902

    IF g_trans_mode = 'A' OR  g_trans_mode = 'AP' .

      PERFORM save_text.

    ENDIF.

    IF g_trans_mode = 'AP'.

      READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH  KEY  zapprove = 'X'.

      IF sy-subrc = 0.

        UPDATE zmm_vend_unblock  SET reqclu = 'A'
              WHERE reqno = wa_zmm_vend_unblock-reqno.

      ENDIF.

    ENDIF.

    IF g_trans_mode = 'A'.

      DATA  :  BEGIN OF ist_linetab_read OCCURS 10.
              INCLUDE STRUCTURE tline.
      DATA  :  END OF ist_linetab_read.

      DATA  :  BEGIN OF ist_inlinetab OCCURS 10.
              INCLUDE STRUCTURE tline.
      DATA  :  END OF ist_inlinetab.

      DATA  :  BEGIN OF ist_src OCCURS 500,
                 line(132),
               END  OF ist_src.
      DATA: l_theader LIKE thead.
      DATA: l_text(132).
      DATA: l_date(10).

      l_theader-tdid = 'NOTE'..
      l_theader-tdobject = 'ZMMVC'.
      l_theader-tdlinesize = '72'.
      l_theader-tdspras = 'E'.

      """""added by lipsy on 28.02.2013 RD1K979902

      IF zmm_vend_unblock-reqno IS NOT INITIAL.

        CONCATENATE l_theader-tdid zmm_vend_unblock-reqno INTO l_theader-tdname.

      ENDIF.
      ""end of addition by lipsy on 28.02.2013 RD1K979902


      CALL FUNCTION 'READ_TEXT_INLINE'
        EXPORTING
          id           = l_theader-tdid
          inline_count = l_theader-tdlinesize
          language     = l_theader-tdspras
          name         = l_theader-tdname
          object       = l_theader-tdobject
        TABLES
          inlines      = ist_inlinetab
          lines        = ist_linetab_read
        EXCEPTIONS
          id           = 1
          language     = 2
          name         = 3
          not_found    = 4
          object       = 5.

      DESCRIBE TABLE ist_inlinetab[] LINES v_lines_old.

      DESCRIBE TABLE ist_linetab_temp[] LINES v_lines_new.

      READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH  KEY  ass_flag = ''.

      IF sy-subrc = 0.

        READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH  KEY  ass_flag = 'X'.
* IF wa_zmm_vend_unblock-ass_flag = 'X'.
        IF sy-subrc = 0.

          IF v_lines_new NE v_lines_old.

            UPDATE zmm_vend_unblock  SET reqclu = 'IR'
                                         WHERE reqno = wa_zmm_vend_unblock-reqno.

          ELSE.
            UPDATE zmm_vend_unblock  SET reqclu = 'IC'
                                         WHERE reqno = wa_zmm_vend_unblock-reqno
                                         AND lifnr = wa_zmm_vend_unblock-lifnr.
          ENDIF.


        ENDIF.

        READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH  KEY  rejnu =  'Rejected by Assigner'.

        IF sy-subrc = 0.

          UPDATE zmm_vend_unblock  SET reqclu = 'IR'
                   WHERE reqno = wa_zmm_vend_unblock-reqno.

          PERFORM send_mail_assign.

        ENDIF.

      ELSE.

        UPDATE zmm_vend_unblock  SET reqclu = 'C'
                                     WHERE reqno = zmm_vend_unblock-reqno .

      ENDIF.

      IF g_crt1 IS INITIAL.

        MESSAGE s730(zmm) WITH zmm_vend_unblock-reqno.

      ENDIF.

    ENDIF.

    "end of addition by lipsy on 28.02.2013 RD1K979902


  ENDIF.
ENDFORM.                    " update_ztable

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
*       routine for message output
*----------------------------------------------------------------------*
*      -->P_G_TRANS_MODE  text
*      -->P_7483   text
*----------------------------------------------------------------------*
FORM display_message USING    p_g_trans_mode
                              msg_typ.
  CASE p_g_trans_mode.
    WHEN 'N'.
      IF msg_typ = 'S'.
        IF g_unblock_vendor = 'X'.
          MESSAGE s728(zmm) WITH zmm_vend_unblock-reqno.
        ELSEIF g_block_vendor = 'X'.
          MESSAGE s728(zmm) WITH zmm_vend_block-reqno.
        ENDIF.
      ELSE.
        MESSAGE a732(zmm).
      ENDIF.
    WHEN 'M'.
      IF msg_typ = 'S'.
        IF g_unblock_vendor = 'X'.
          MESSAGE s730(zmm) WITH zmm_vend_unblock-reqno.
        ELSEIF g_block_vendor = 'X'.
          MESSAGE s730(zmm) WITH zmm_vend_block-reqno.
        ENDIF.
      ELSE.
        MESSAGE a732(zmm).
      ENDIF.
*{+RK004
    WHEN 'X'.
      IF g_unblock_vendor = 'X'.
        IF msg_typ = 'S'.
          MESSAGE s415(zmm) WITH zmm_vend_unblock-reqno.
        ELSE.
          MESSAGE a506(zmm) WITH zmm_vend_unblock-reqno.
        ENDIF.
      ELSEIF g_block_vendor = 'X'.
        IF msg_typ = 'S'.
          MESSAGE s415(zmm) WITH zmm_vend_block-reqno.
        ELSE.
          MESSAGE a506(zmm) WITH zmm_vend_block-reqno.
        ENDIF.
      ENDIF.
*}+RK004
  ENDCASE.
ENDFORM.                    " DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  vendor_excise_details_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vendor_excise_details_update.

  DELETE ist_vend WHERE vend-lifnr = ' '.

  DELETE ist_vend WHERE vend-j_1ipanno = ' ' AND
                        vend-j_1isern = ' ' AND
                        vend-stcd1 = ' ' AND
                        vend-stcd2 = ' '.


  IF ist_vend[] IS INITIAL.
    EXIT.
  ENDIF.


*{+rk001
  DATA l_return TYPE sy-subrc.

  PERFORM check_viewname_enque_auth USING 'U'
                                          'J_1IMOVEND'
                                    CHANGING l_return.
  CHECK l_return EQ 0.
*}+rk001
  DATA :
    l_digit1    TYPE n,
    l_digit2    TYPE n,
    l_lifnr(30),
    l_sern(30),
    l_cstno(30),
    l_vatno(30),
    l_panno(30),
    l_usnam(30),
    l_aedat(20).

  WRITE sy-datum TO l_aedat DD/MM/YYYY.                     "+rk003


  PERFORM bdc_dynpro      USING 'SAPMJ1ID' '0200'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RB6'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=EX'.
  PERFORM bdc_field       USING 'RB11'
                                ''.
  PERFORM bdc_field       USING 'RB6'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPLJ1I0' '0800'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_1IMOVEND-J_1IEXCD(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NEWL'.

  READ TABLE ist_vend INDEX 1.

  PERFORM bdc_dynpro      USING 'SAPLJ1I0' '0800'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_1IMOVEND-J_1IEXCD(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'J_1IMOVEND-LIFNR(01)'
                                ist_vend-vend-lifnr.
  PERFORM bdc_field       USING 'J_1IMOVEND-J_1ICSTNO(01)'
                                ist_vend-vend-stcd2.
  PERFORM bdc_field       USING 'J_1IMOVEND-J_1ILSTNO(01)'
                                ist_vend-vend-stcd1.
**  PERFORM bdc_field       USING 'J_1IMOVEND-J_1IPANNO(01)'
**                                ist_vend-vend-j_1ipanno.
  PERFORM bdc_field       USING 'J_1IMOVEND-AEDAT(01)'
*                                  sy-datum.                  "-rk003
                                l_aedat.
  PERFORM bdc_field       USING 'J_1IMOVEND-USNAM(01)'
                                sy-uname.
  PERFORM bdc_field       USING 'J_1IMOVEND-J_1ISERN(01)'
                                ist_vend-vend-j_1isern.
*{   INSERT         OCPK900113                                        1
*PERFORM bdc_field       USING 'J_1IMOVEND-VEN_CLASS(01)'
*                                ist_vend-vend-VEN_CLASS.
*}   INSERT

  DELETE ist_vend INDEX 1.
  LOOP AT ist_vend WHERE vend-lifnr <> ' '.

    PERFORM bdc_dynpro      USING 'SAPLJ1I0' '0800'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'J_1IMOVEND-J_1IEXCD(02)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=NEXT'.
    PERFORM bdc_field       USING 'J_1IMOVEND-LIFNR(02)'
                                  ist_vend-vend-lifnr.
    PERFORM bdc_field       USING 'J_1IMOVEND-J_1ICSTNO(02)'
                                  ist_vend-vend-stcd2.
    PERFORM bdc_field       USING 'J_1IMOVEND-J_1ILSTNO(02)'
                                  ist_vend-vend-stcd1.
    PERFORM bdc_field       USING 'J_1IMOVEND-J_1IPANNO(02)'
                                  ist_vend-vend-j_1ipanno.
    PERFORM bdc_field       USING 'J_1IMOVEND-AEDAT(02)'
*                                  sy-datum.                  "-rk003
                                  l_aedat.
    PERFORM bdc_field       USING 'J_1IMOVEND-USNAM(02)'
                                  sy-uname.
    PERFORM bdc_field       USING 'J_1IMOVEND-J_1ISERN(02)'
                                  ist_vend-vend-j_1isern.

  ENDLOOP.
  PERFORM bdc_dynpro      USING 'SAPLJ1I0' '0800'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_1IMOVEND-LIFNR(02)'.

*>>>>>>>>>>>>>>>>>>>>
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SAVE'.
  PERFORM bdc_dynpro      USING 'SAPLJ1I0' '0800'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_1IMOVEND-LIFNR(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM bdc_dynpro      USING 'SAPLJ1I0' '0800'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'J_1IMOVEND-LIFNR(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM bdc_dynpro      USING 'SAPMJ1ID' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/EEXIT'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'EXCISE'.
  PERFORM background TABLES ist_bdcstatus2
                                     USING  'J1ID'        " s_tcode
*{   REPLACE        OCPK900113                                        2
*\                                             'N'          " s_mode
                                             'A'          " s_mode
*}   REPLACE
                                             'A'          " s_update
                                             zmm_hvencrt-reqno
                                          ' '.

ENDFORM.                    " vendor_excise_details_update
*&---------------------------------------------------------------------*
*&      Form  CALL_ADV_SEARCH
*&---------------------------------------------------------------------*
*       ROUTINE TO CALL ADVANCED SEARCH SCREEN
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_adv_search.

  CALL FUNCTION 'ZMM_ADV_VENDOR_SEARCH' .

ENDFORM.                    " CALL_ADV_SEARCH
*&---------------------------------------------------------------------*
*&      Form  get_textlines
*&---------------------------------------------------------------------*
*       longtext lines
*----------------------------------------------------------------------*
*      <--P_L_ROWCOUNT  text
*----------------------------------------------------------------------*
FORM get_textlines CHANGING p_l_rowcount.
  DATA : l_name LIKE thead-tdname.

  MOVE ist_lfa1-lifnr TO l_name.

  CALL FUNCTION 'READ_TEXT_INLINE'
    EXPORTING
      id              = '0002'
      inline_count    = '5'
      language        = 'E'
      name            = l_name
      object          = 'LFA1'
*     LOCAL_CAT       = ' '
* IMPORTING
*     HEADER          =
    TABLES
      inlines         = tinlinetab
      lines           = tlinetab
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      not_found       = 4
      object          = 5
      reference_check = 6
      OTHERS          = 7.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DESCRIBE TABLE tlinetab LINES p_l_rowcount.
  p_l_rowcount = p_l_rowcount + 2.


ENDFORM.                    " get_textlines
*&---------------------------------------------------------------------*
*&      Form  call_vendor_maintenance_screen
*&---------------------------------------------------------------------*
*       ROUTINE TO CALL VENDOR MAINTENANCE SCREEN
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_vendor_maintenance_screen.
  DATA : ist_t_gui LIKE STANDARD TABLE OF rsmpe WITH HEADER LINE.

  ist_t_gui-func = 'SAVE'.
  APPEND ist_t_gui.

  CALL FUNCTION 'ZMM_MAINTAIN_VENDOR'
    TABLES
      t_gui = ist_t_gui.

ENDFORM.                    " call_vendor_maintenance_screen
*&---------------------------------------------------------------------*
*&      Form  check_cc_po
*&---------------------------------------------------------------------*
*       company code purchase org combination
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_cc_po.

  IF zmm_hvenext-bukrs = 'OBV'.
    LOOP AT ist_extn WHERE ekorg = 'PMAT' OR ekorg = 'PSRV'..
      MESSAGE e852(zmm) WITH zmm_hvenext-bukrs ist_extn-ekorg.
      EXIT.
    ENDLOOP.
  ELSEIF zmm_hvenext-bukrs <> 'OBV'.
    LOOP AT ist_extn WHERE ekorg = 'POBV'..
      MESSAGE e852(zmm) WITH zmm_hvenext-bukrs ist_extn-ekorg.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " check_cc_po
*&---------------------------------------------------------------------*
*&      Form  delete_notes
*&---------------------------------------------------------------------*
*       DELETE LONG TEXT IN NOTES COMPONENT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_notes.
  CLEAR l_tdname.
  CONCATENATE 'NOTE' zmm_hvencrt-reqno INTO l_tdname.

  IF NOT stxh IS INITIAL.
    CALL FUNCTION 'DELETE_TEXT'
      EXPORTING
        client          = sy-mandt
        id              = 'NOTE'
        language        = sy-langu
        name            = l_tdname
        object          = 'ZMMVC'
        savemode_direct = 'X'
      EXCEPTIONS
        not_found       = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CLEAR :stxh, l_tdname.
  ENDIF.
ENDFORM.                    " delete_notes
*&---------------------------------------------------------------------*
*&      Form  check_viewname_enque_auth
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_action    action
*      -->p_viewname  maintenance view name
*      <--p_l_return  return code
*----------------------------------------------------------------------*
FORM check_viewname_enque_auth USING    p_action
                                        p_viewname
                               CHANGING p_l_return.
  DATA l_text(70)  TYPE c.
  DATA: rangetab TYPE TABLE OF vimsellist INITIAL SIZE 50
       WITH HEADER LINE.

  CALL FUNCTION 'VIEW_ENQUEUE'
    EXPORTING
      view_name        = p_viewname
      action           = 'E'
      enqueue_mode     = 'E'
      enqueue_range    = ' '
    TABLES
      sellist          = rangetab
    EXCEPTIONS
      foreign_lock     = 1
      system_failure   = 2
      table_not_found  = 5
      client_reference = 7.

  p_l_return = sy-subrc.
  CASE p_l_return.
    WHEN 1.
      CLEAR ist_bdcstatus.
      l_text = text-101.
      REPLACE '&' WITH sy-msgv1(12) INTO l_text.
      ist_bdcstatus-msgtx = l_text.
      APPEND ist_bdcstatus.
    WHEN 0.
      CALL FUNCTION 'VIEW_ENQUEUE'
        EXPORTING
          view_name        = p_viewname
          action           = 'D'
          enqueue_mode     = 'E'
          enqueue_range    = ' '
        TABLES
          sellist          = rangetab
        EXCEPTIONS
          foreign_lock     = 1
          system_failure   = 2
          table_not_found  = 5
          client_reference = 7.
  ENDCASE.
ENDFORM.                    " check_viewname_enque_auth
*&---------------------------------------------------------------------*
*&      Form  read_user_guidelines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_user_guidelines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ST'
      language                = 'E'
      name                    = 'ZMMVEND_MAIL'
      object                  = 'TEXT'
    TABLES
      lines                   = tlinetab
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " read_user_guidelines

*&---------------------------------------------------------------------*
*&      Form  process_attach_file
*&---------------------------------------------------------------------*
* To attach PC file i.e. *.DOC or *.TXT or *.XLS etc. with Request no.
*----------------------------------------------------------------------*
*  -->  p_tr_mode Transaction mode i.e. Create/Change/Display/Delete
*----------------------------------------------------------------------*
FORM process_attach_file USING p_tr_mode.
  DATA :  ist_att_files LIKE TABLE OF swotobjid,
          wa_att_files  LIKE swotobjid.

  DATA att_data TYPE sodocchgi1.

  IF p_tr_mode = 'N'.

    CHECK NOT zmm_vend_unblock-bukrs IS INITIAL.

    MESSAGE i856(zmm).

  ELSEIF p_tr_mode = 'M'.

    CHECK NOT zmm_vend_unblock-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_unblock-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    APPEND wa_att_files TO ist_att_files.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
      EXPORTING
        attachment_data     = att_data "''
        attachment_type     = 'DOC'
      TABLES
        application_objects = ist_att_files.

  ELSEIF p_tr_mode = 'D'.

    CHECK NOT zmm_vend_unblock-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_unblock-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_DISP_API1'
      EXPORTING
        application_object = wa_att_files.

  ELSEIF p_tr_mode = 'X'.

    CHECK NOT zmm_vend_unblock-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_unblock-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_DISP_API1'
      EXPORTING
        application_object = wa_att_files.

  ENDIF.

ENDFORM.                    " process_attach_file

*&---------------------------------------------------------------------*
*&      Form  chk_unbl_del_flg
*&---------------------------------------------------------------------*
* To check deletion flag in internal table IST_UNBL - If deletion flag
* for all entries in internal table have a value 'X', display warning
* message & make deletion flag blank
*----------------------------------------------------------------------*
*  -->  p_tr_mode Transaction mode i.e. Create/Change/Display/Delete
*----------------------------------------------------------------------*
FORM chk_unbl_del_flg USING p_tr_mode.

  DATA : l_no  TYPE sy-tabix,
         l_cnt TYPE sy-tabix.

  IF p_tr_mode = 'DELE'.

    DESCRIBE TABLE ist_unbl LINES l_no.

    LOOP AT ist_unbl.
      IF ist_unbl-del_flag = 'X'.
        l_cnt = l_cnt + 1.
      ENDIF.
    ENDLOOP.

    IF l_cnt = l_no.

      MESSAGE w858(zmm).

      LOOP AT ist_unbl.
        CLEAR ist_unbl-del_flag.
        MODIFY ist_unbl INDEX sy-tabix.
      ENDLOOP.
    ENDIF.

  ELSEIF p_tr_mode = 'DELR'.

    DESCRIBE TABLE ist_vend LINES l_no.

    LOOP AT ist_vend INTO wa_vend.

      IF wa_vend-vend-del_flag = 'X'.

        l_cnt = l_cnt + 1.

      ELSEIF wa_vend-mark = 'X'.

        l_cnt = l_cnt + 1.

      ENDIF.

    ENDLOOP.

    IF l_cnt = l_no.
      MESSAGE e735(zmm) WITH text-028.
    ENDIF.

  ENDIF.
ENDFORM.                    " chk_unbl_del_flg

*&---------------------------------------------------------------------*
*&      Form  process_list_attach_file
*&---------------------------------------------------------------------*
* To display a list of attached PC file
*----------------------------------------------------------------------*
*  -->  p_tr_mode Transaction mode i.e. Create/Change/Display/Delete
*----------------------------------------------------------------------*
FORM process_list_attach_file USING    p_tr_mode.
  DATA :  ist_att_files LIKE TABLE OF swotobjid,
          wa_att_files  LIKE swotobjid.

  DATA : ist_exclude LIKE soxet OCCURS 0 WITH HEADER LINE.

  ist_exclude-fcode = 'EXPO'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'IMPO'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'HGEN'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'OLNK'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'REFL'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'COPY'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'CHNG'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'PRIN'.
  APPEND ist_exclude.

  CLEAR : ist_exclude.

  IF p_tr_mode = 'M' OR
     p_tr_mode = 'D' OR
     p_tr_mode = 'X' OR
     p_tr_mode = 'A'

  """"""""""""""""""""""""""""""""""""""""
   "added by lipsy for list in release and approve on 28.08.2013 RD1K983016

    OR  p_tr_mode = 'AP' OR

         p_tr_mode = 'RL'
    """"end of add by lipsy for list in release and approve on 28.08.2013 RD1K983016


    """""""""""""""""""""""""""""""""""""


    .



    CHECK NOT zmm_vend_unblock-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_unblock-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = wa_att_files
      TABLES
        func_exclude       = ist_exclude.
  ENDIF.

ENDFORM.                    " process_list_attach_file

*&---------------------------------------------------------------------*
*&      Form  chk_block_flg
*&---------------------------------------------------------------------*
* To check various blocking flag before modification in internal table
*----------------------------------------------------------------------*
*      -->P_TRANS_MODE  transaction mode
*----------------------------------------------------------------------*
FORM chk_block_flg USING    p_trans_mode.

  IF p_trans_mode = 'N' OR
     p_trans_mode = 'M' OR
     p_trans_mode = 'A'.
* Begin of < > on 19042011 by Sudhir Sharma
*    SELECT SINGLE * FROM lfa1 INTO ist_lfa1 WHERE
*                                lifnr = ist_bl-lifnr .
*    if sy-subrc = 0.
*
*      if not ist_lfa1-sperm is initial.
*        clear : ist_bl-sperm.
*      endif.
*
*      if not ist_lfa1-sperr is initial.
*        clear : ist_bl-sperr.
*      endif.
*
*      if not ist_lfa1-sperq <> '05'.
*        clear : ist_bl-blrfq.
*      endif.
*
*      if not ist_lfa1-loevm is initial.
*        clear : ist_bl-loevm.
*      endif.
*
*    endif.

* End of < > on 19042011
  ENDIF.
ENDFORM.                    " chk_block_flg

*&---------------------------------------------------------------------*
*&      Module  check_mand_fields  INPUT
*&---------------------------------------------------------------------*
* To check mandatory fields during creation/updation of vendor master
* using tr. code ZMM_VMS
*----------------------------------------------------------------------*
MODULE check_mand_fields INPUT.

  IF wa_vend-vend-ven_class NE '0' AND wa_vend-vend-gst_no IS INITIAL.
*      MESSAGE 'Please enter GST number' TYPE 'E'.
  ELSEIF    wa_vend-vend-ven_class EQ  '0' AND wa_vend-vend-gst_no IS NOT INITIAL.

    MESSAGE 'Please remove GST number for Ven Class 0' TYPE 'E'.

  ENDIF.

  IF NOT ( zmm_hvencrt-ktokk = 'IMMF' OR  zmm_hvencrt-ktokk = 'SVWF' ).

    IF NOT zmm_hvencrt-bukrs IS INITIAL.

      SELECT * FROM zmm_venchk INTO TABLE ist_zmm_venchk
          WHERE bukrs = zmm_hvencrt-bukrs.

    ENDIF.

  ENDIF.



  LOOP AT ist_zmm_venchk INTO wa_zmm_venchk.

    CASE wa_zmm_venchk-fldnam.
      WHEN 'STCD1'.

        IF wa_vend-vend-stcd1 IS INITIAL.

*       set cursor field 'WA_VEND-VEND-STCD1' line tab_ctl-current_line.
*          message i862(zmm).

          g_vat = text-081.
        ENDIF.

      WHEN 'STCD2'.
        IF wa_vend-vend-stcd2 IS INITIAL.
          g_cst = text-082.
        ENDIF.

      WHEN 'J_1IPANNO'.
        IF wa_vend-vend-j_1ipanno IS INITIAL.
          g_pan = text-083.
        ENDIF.

      WHEN 'J_1ISERN'.
        IF wa_vend-vend-j_1isern IS INITIAL.
          g_stx = text-084.
        ENDIF.

      WHEN 'BANK'.
        IF lfbk-banks IS INITIAL OR
           lfbk-bankl IS INITIAL OR
           wa_vend-vend-bankn IS INITIAL.
          g_bnk = text-085.
        ENDIF.

*        if lfbk-bankl is initial.
*          g_bnk = text-085.
*        endif.
*
*        if wa_vend-vend-bankn is initial.
*          g_bnk = text-085.
*        endif.

    ENDCASE.

  ENDLOOP.

ENDMODULE.                 " check_mand_fields  INPUT

*&---------------------------------------------------------------------*
*&      Form  clear_scr_220
*&---------------------------------------------------------------------*
*  To refresh global variable - screen 220
*----------------------------------------------------------------------*
FORM clear_scr_220.
  REFRESH : ist_zmm_venchk.

  CLEAR : wa_zmm_venchk.

  CLEAR : g_vat,
          g_cst,
          g_pan,
          g_stx,
          g_bnk.
ENDFORM.                    " clear_scr_220

*&---------------------------------------------------------------------*
*&      Form  upd_screen_attr_220
*&---------------------------------------------------------------------*
* To make mandatory entry of following screen fields during creation /
* updation of vendor master - screen 220
*     1. VAT  2.PAN  3.CST  4. Bank 5. Service Tax
*----------------------------------------------------------------------*
FORM upd_screen_attr_220.

**  BOC by ss on 21.3.21
  IF zmm_hvencrt-bukrs = 'OVC'.
    IF screen-name    = 'WA_VEND-VEND-STCD1'.
      screen-input    = '0' .
    ENDIF.
    IF screen-group4 = 'CST' AND screen-name    = 'WA_VEND-VEND-STCD2'.
      screen-input    = '0' .
    ENDIF.
    IF screen-group4 = 'PAN' AND screen-name    = 'WA_VEND-VEND-J_1IPANNO'.
      screen-input    = '0' .
    ENDIF.

    IF screen-group4 = 'STX' AND screen-name    = 'WA_VEND-VEND-J_1ISERN'.
      screen-input    = '0' .
    ENDIF.

    IF screen-group4 = 'OAR' AND screen-name    = 'WA_VEND-VEND-GST_NO'.
      screen-input    = '0' .
    ENDIF.

    IF screen-group4 = 'OAR' AND screen-name    = 'WA_VEND-VEND-VEN_CLASS'.
      screen-input    = '0' .
    ENDIF.
  ELSE.
**    EOC by ss on 21.3.21

    IF NOT g_vat IS INITIAL AND screen-group4 = 'VAT'.
      screen-input    = '1' .
      screen-required = '1' .
*                MODIFY SCREEN.
    ENDIF.

    IF NOT g_cst IS INITIAL AND screen-group4 = g_cst.
      screen-input    = '1' .
      screen-required = '1' .
*                MODIFY SCREEN.
    ENDIF.

    IF NOT g_pan IS INITIAL AND screen-group4 = g_pan.
      screen-input    = '1' .
      screen-required = '1' .
*                MODIFY SCREEN.
    ENDIF.


*    IF wa_vend-vend-j_1ipanno IS NOT INITIAL.
*      DATA chk_pan(1) TYPE C.
*      chk_pan = wa_vend-vend-j_1ipanno+4(1).
*      IF chk_pan = 'C'.
*       SCREEN-INPUT    = '1' .
*       SCREEN-REQUIRED = '1' .
*      ENDIF.
*    ENDIF.

    IF NOT g_stx IS INITIAL AND screen-group4 = g_stx.
      screen-input    = '1' .
      screen-required = '1' .
*                MODIFY SCREEN.
    ENDIF.

    IF NOT g_bnk IS INITIAL AND screen-group4 = g_bnk.
      screen-input    = '1' .
      screen-required = '1' .
*                MODIFY SCREEN.
    ENDIF.
  ENDIF. "MOD by ss on 21.3.21
ENDFORM.                    " upd_screen_attr_220

*&---------------------------------------------------------------------*
*&      Form  upd_screen_attr_bank_220
*&---------------------------------------------------------------------*
* To make O/P only entry for Bank related screen fields
* It is required temporally for 3-months wef 08.05.2008
*----------------------------------------------------------------------*
FORM upd_screen_attr_bank_220.

  IF screen-group4 = text-085.   "BNK
    screen-input    = '0' .
    screen-output   = '1' .
  ENDIF.

ENDFORM.                    " upd_screen_attr_bank_220
*&---------------------------------------------------------------------*
*&      Form  POPUP_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_TEXT  text
*----------------------------------------------------------------------*
FORM popup_message  USING  l_text.
  CLEAR l_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = l_text
      titel         = 'Vendor Management System'
    IMPORTING
      answer        = l_answer.


ENDFORM.                    " POPUP_MESSAGE

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row

      READ TABLE  g_tc319_itab INTO zfivmsbank INDEX 1.  "#EC CI_NOORDER
      DATA : l_line TYPE i.

      DESCRIBE TABLE  g_tc319_itab LINES l_line.

      l_line = l_line + 1.
      tc319-lines = l_line.
      CLEAR : g_create .
      CLEAR : g_tc319_wa,    g_exist .
      INSERT INITIAL LINE INTO g_tc319_itab INDEX l_line.
      g_tc319_wa-srno = l_line.
      MODIFY g_tc319_itab FROM g_tc319_wa INDEX l_line.  "#EC CI_NOORDER
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      IF g_okcode931 = 'CHANGE' OR g_okcode531 = 'CHANGE'.  "08092010
        g_tc319_itab_temp[] = g_tc319_itab[].
        g_tc531_itab_temp[] = g_tc531_itab[].
        g_zvms_reqno   = zfivmsbank-reqno.
      ENDIF.

      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

    WHEN 'POSI'.
      PERFORM search_request.
      CLEAR p_ok.


  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  DATA_DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM DDATA_DOWNLOAD .
*
*  write sy-datum to g_date_rd DDMMYY.
*  g_time_rd = sy-uzeit.
*  concatenate 'C:\SPAN\' 'D_'  g_date_rd g_time_rd '.txt' into g_filename.
*
*  CALL FUNCTION 'GUI_DOWNLOAD'
*   EXPORTING
*     FILENAME                        = g_filename
**    FILETYPE                        = 'DAT'
*     WRITE_FIELD_SEPARATOR           = '*'
*   TABLES
*     DATA_TAB                        = ist_ddata_sbi
*  EXCEPTIONS
*    FILE_WRITE_ERROR                = 1
*    NO_BATCH                        = 2
*    GUI_REFUSE_FILETRANSFER         = 3
*    INVALID_TYPE                    = 4
*    NO_AUTHORITY                    = 5
*    UNKNOWN_ERROR                   = 6
*    HEADER_NOT_ALLOWED              = 7
*    SEPARATOR_NOT_ALLOWED           = 8
*    FILESIZE_NOT_ALLOWED            = 9
*    HEADER_TOO_LONG                 = 10
*    DP_ERROR_CREATE                 = 11
*    DP_ERROR_SEND                   = 12
*    DP_ERROR_WRITE                  = 13
*    UNKNOWN_DP_ERROR                = 14
*    ACCESS_DENIED                   = 15
*    DP_OUT_OF_MEMORY                = 16
*    DISK_FULL                       = 17
*    DP_TIMEOUT                      = 18
*    FILE_NOT_FOUND                  = 19
*    DATAPROVIDER_EXCEPTION          = 20
*    CONTROL_FLUSH_ERROR             = 21
*    OTHERS                          = 22.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*ENDFORM.                    " DATA_DOWNLOAD
*
**&---------------------------------------------------------------------*
**&      Form  DATA_DOWNLOAD
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM RDATA_DOWNLOAD .
*  clear : g_filename, g_date_rd , g_time_rd.
*
*  write sy-datum to g_date_rd DDMMYY.
*  g_time_rd = sy-uzeit.
*  concatenate 'C:\SPAN\' 'R_'  g_date_rd g_time_rd '.txt' into g_filename.
*
*  CALL FUNCTION 'GUI_DOWNLOAD'
*   EXPORTING
*     FILENAME                        = g_filename
**    FILETYPE                        = 'DAT'
*     WRITE_FIELD_SEPARATOR           = '*'
*   TABLES
*     DATA_TAB                        = ist_rdata_sbi
*  EXCEPTIONS
*    FILE_WRITE_ERROR                = 1
*    NO_BATCH                        = 2
*    GUI_REFUSE_FILETRANSFER         = 3
*    INVALID_TYPE                    = 4
*    NO_AUTHORITY                    = 5
*    UNKNOWN_ERROR                   = 6
*    HEADER_NOT_ALLOWED              = 7
*    SEPARATOR_NOT_ALLOWED           = 8
*    FILESIZE_NOT_ALLOWED            = 9
*    HEADER_TOO_LONG                 = 10
*    DP_ERROR_CREATE                 = 11
*    DP_ERROR_SEND                   = 12
*    DP_ERROR_WRITE                  = 13
*    UNKNOWN_DP_ERROR                = 14
*    ACCESS_DENIED                   = 15
*    DP_OUT_OF_MEMORY                = 16
*    DISK_FULL                       = 17
*    DP_TIMEOUT                      = 18
*    FILE_NOT_FOUND                  = 19
*    DATAPROVIDER_EXCEPTION          = 20
*    CONTROL_FLUSH_ERROR             = 21
*    OTHERS                          = 22.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*ENDFORM.                    " DATA_DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  CHECK_LIFNR_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM   check_lifnr_flow .
  DATA :  l_exist,
          sr(2)                  TYPE i,
          l_lifnr                TYPE zfivmsbank-lifnr ,    "17052013

          l_zfivmsbank-name1     TYPE zfivmsbank-name1,
          l_zfivmsbank-bankl     TYPE zfivmsbank-bankl,
          l_zfivmsbank-bankn     TYPE zfivmsbank-bankn,
          l_zfivmsbank-koinh     TYPE zfivmsbank-koinh,
          l_zfivmsbank-bankl_new TYPE zfivmsbank-bankl_new,
          l_zfivmsbank-bankn_new TYPE zfivmsbank-bankn_new,
          l_zfivmsbank-koinh_new TYPE zfivmsbank-koinh_new,
          l_zfivmsbank-zlist     TYPE zfivmsbank-zlist,
          l_zfivmsbank-attach    TYPE zfivmsbank-attach.

  SELECT * FROM zfivmsbank INTO TABLE ist_zfivmsbank WHERE lifnr = zfivmsbank-lifnr.
  IF cb_nor = 'X'.
    DELETE ist_zfivmsbank WHERE reqno+0(3) = 'EMD'.
  ENDIF.

  IF cb_emd = 'X'.
    DELETE ist_zfivmsbank WHERE reqno+0(3) NE 'EMD'.
  ENDIF.
*   READ zfivmsbank INTO  WA_zfivmsbank WHERE lifnr = zfivmsbank-lifnr.

  IF ist_zfivmsbank[] IS NOT INITIAL.

    SORT ist_zfivmsbank DESCENDING BY cdate cputm.
* Begin of <> on 16112010
* Begin of <> on 03122010
*    read table ist_zfivmsbank into wa_zfivmsbank index 1.
*    read table ist_zfivmsbank into wa_zfivmsbank with key status = 'Registration Successful'.
    READ TABLE ist_zfivmsbank INTO wa_zfivmsbank INDEX 1.

* End of <> on 03122010
    TRANSLATE wa_zfivmsbank-status TO UPPER CASE.
* Begin of <> on 06092011
    CLEAR : wa_zfivmsbank-zvendtimestamp, wa_zfivmsbank-attach, wa_zfivmsbank-zlist,
            wa_zfivmsbank-srno, wa_zfivmsbank-ccode, wa_zfivmsbank-username,wa_zfivmsbank-cpf,
            wa_zfivmsbank-cdate,wa_zfivmsbank-cputm,wa_zfivmsbank-hof_cpf_no,
            wa_zfivmsbank-hof_name,wa_zfivmsbank-vmc_cpf_no,wa_zfivmsbank-vmc_name,wa_zfivmsbank-deregistration,
            wa_zfivmsbank-registration,wa_zfivmsbank-vmc_apdate , wa_zfivmsbank-vmc_aptime , wa_zfivmsbank-hof_rldate , wa_zfivmsbank-hof_rltime.
*wa_zfivmsbank-status,  "290911
* End of <> on 06092011
* Begin of Comment on 05042011 06042011
*      if wa_zfivmsbank-status = 'REGISTRATION SUCCESSFUL'.
*        l_zfivmsbank-name1    = wa_zfivmsbank-name1.
*        clear : wa_zfivmsbank.
*        wa_zfivmsbank-lifnr = zfivmsbank-lifnr.
*        wa_zfivmsbank-name1 = l_zfivmsbank-name1.
**              wa_zfivmsbank-bankl,
**              wa_zfivmsbank-bankn,
**              wa_zfivmsbank-koinh,
**              wa_zfivmsbank-bankl_new,
**              wa_zfivmsbank-bankn_new,
**              wa_zfivmsbank-koinh_new,
**              wa_zfivmsbank-status,
**              wa_zfivmsbank-attach,
**              wa_zfivmsbank-zlist.
** Begin of <> on 181110
*        describe table G_TC319_ITAB lines sr.
*        wa_zfivmsbank-srno = sr.
*        select single * from lfbk into wa_lfbk where lifnr = zfivmsbank-lifnr.
*        if sy-subrc = 0.
*          wa_zfivmsbank-bankl = wa_lfbk-bankl.
*          wa_zfivmsbank-bankn = wa_lfbk-bankn.
*          wa_zfivmsbank-koinh = wa_lfbk-koinh.
*        endif.
*
*        l_zfivmsbank-bankl_new = zfivmsbank-bankl_new.
*        l_zfivmsbank-bankn_new = zfivmsbank-bankn_new.
*        l_zfivmsbank-koinh_new = zfivmsbank-koinh_new.
*        l_zfivmsbank-zlist     = zfivmsbank-zlist .
*        l_zfivmsbank-attach    = zfivmsbank-attach.
*
** End of <> on 181110
** Begin of <> on 03122010
**    else.
**      read table ist_zfivmsbank into wa_zfivmsbank with key status = 'Registration Failure'.
**   if sy-subrc = 0.
** End of <> on 03122010
*      elseif wa_zfivmsbank-status = 'REGISTRATION FAILURE'.
*        l_zfivmsbank-name1    = wa_zfivmsbank-name1.
*        l_zfivmsbank-bankl    = wa_zfivmsbank-bankl.
*        l_zfivmsbank-bankn    = wa_zfivmsbank-bankn.
*        l_zfivmsbank-koinh    = wa_zfivmsbank-koinh.
*
*        clear : wa_zfivmsbank.
*        wa_zfivmsbank-lifnr = zfivmsbank-lifnr.
*        wa_zfivmsbank-name1 = l_zfivmsbank-name1.
*        wa_zfivmsbank-bankl = l_zfivmsbank-bankl.
*        wa_zfivmsbank-bankn = l_zfivmsbank-bankn.
*        wa_zfivmsbank-koinh = l_zfivmsbank-koinh.
**                wa_zfivmsbank-bankl_new,
**                wa_zfivmsbank-bankn_new,
**                wa_zfivmsbank-koinh_new,
**                wa_zfivmsbank-status,
**                wa_zfivmsbank-attach,
**                wa_zfivmsbank-zlist.
*
*        describe table G_TC319_ITAB lines sr.
*        wa_zfivmsbank-srno = sr.
*
*        l_zfivmsbank-bankl_new = zfivmsbank-bankl_new.
*        l_zfivmsbank-bankn_new = zfivmsbank-bankn_new.
*        l_zfivmsbank-koinh_new = zfivmsbank-koinh_new.
*        l_zfivmsbank-zlist     = zfivmsbank-zlist .
*        l_zfivmsbank-attach    = zfivmsbank-attach.
** End of <> on 181110
**      else.
**        read table ist_zfivmsbank into wa_zfivmsbank index 1.
*      endif.
*    endif.
* End of <> on 16112010
* End of Comment on 05042011
* 06042011

    IF  zfivmsbank-bankl_new IS INITIAL AND
        zfivmsbank-bankn_new IS INITIAL AND
        zfivmsbank-koinh_new IS INITIAL. " AND
*        ZFIVMSBANK-ZBNKT IS INITIAL.     "Added By ss on 19.4.21
      IF wa_zfivmsbank-status = 'REGISTRATION SUCCESSFUL'.
        MOVE-CORRESPONDING wa_zfivmsbank TO zfivmsbank.   "Logic added on 12102011
        CLEAR : zfivmsbank-bankl_new,
                zfivmsbank-bankn_new ,
                zfivmsbank-koinh_new.

        zfivmsbank-bankl = wa_zfivmsbank-bankl_new.
        zfivmsbank-bankn = wa_zfivmsbank-bankn_new.
        zfivmsbank-koinh = wa_zfivmsbank-koinh_new.
      ELSE.
        MOVE-CORRESPONDING wa_zfivmsbank TO zfivmsbank.
      ENDIF.
    ELSE.
      IF   zfivmsbank-bankl_new = wa_zfivmsbank-bankl_new AND
           zfivmsbank-bankn_new = wa_zfivmsbank-bankn_new AND
           zfivmsbank-koinh_new = wa_zfivmsbank-koinh_new.
*           ZFIVMSBANK-ZBNKT = WA_ZFIVMSBANK-ZBNKT . " commented by hiren
        MOVE-CORRESPONDING wa_zfivmsbank TO zfivmsbank.
      ENDIF.
    ENDIF.
* 06042011
*    if not l_zfivmsbank-bankl_new is initial OR
*       not l_zfivmsbank-bankn_new is initial OR
*       not l_zfivmsbank-koinh_new is initial OR
*       not l_zfivmsbank-attach    is initial OR
*       not l_zfivmsbank-zlist     is initial .
*
*      zfivmsbank-bankl_new = l_zfivmsbank-bankl_new.
*      zfivmsbank-bankn_new = l_zfivmsbank-bankn_new.
*      zfivmsbank-koinh_new = l_zfivmsbank-koinh_new.
*      zfivmsbank-zlist     = l_zfivmsbank-zlist .
*      zfivmsbank-attach    = l_zfivmsbank-attach.
*    endif.

* 06042011
* Begin of <> on 151110
    SELECT SINGLE *  FROM lfa1 INTO wa_lfa1 WHERE lifnr = zfivmsbank-lifnr
* Begin of <> on 09122010

*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*Begin RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*        and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK','GOVT','LEA1','LEA2','LAQ1','INVT','SUBD','UTLT','CONT').

**  Commenetd by ss on 10.8.2021
*        AND KTOKK IN ('SVWI','SVWF','IMMI','IMMF','BANK','GOVT','LEA1','LEA2','LAQ1','INVT','SUBD','UTLT','CONT','NOMI', 'SHYG', 'TRNI')."Added by ruhani garg
AND ktokk NE 'VEMP'.  " added by ss on 10.8.2021





*End RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586

*    and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK').
* End of <> on 09122010
    IF sy-subrc = 0.
* BEGIN OF <> ON 16052013
      zfivmsbank-name1 = wa_lfa1-name1.
* END OF <> ON 16052013
*      if not wa_lfa1-sperr is initial.            "03122010
      IF NOT zfivmsbank-status IS INITIAL.
        TRANSLATE wa_zfivmsbank-status TO UPPER CASE.
        IF zfivmsbank-status <> 'REJECTED BY HOF'         AND
           zfivmsbank-status <> 'REJECTED BY VMC'         AND "24122010
           zfivmsbank-status <> 'REGISTRATION FAILURE'    AND "24122010
           zfivmsbank-status <> 'REGISTRATION SUCCESSFUL' AND "24022011
           zfivmsbank-status <> 'REJECTED BY VMC FOR OVL' AND
           zfivmsbank-status <> 'CHANGE OF BRANCH CODE'   AND
            zfivmsbank-status <> 'NEW' .                    "31052012
          g_exist_ztable = 'X'.
          l_exist = 'X'.
* Begin of <RD1K984792> on 16052013 17052013
          l_lifnr = zfivmsbank-lifnr.
          CLEAR zfivmsbank.
          zfivmsbank-lifnr = l_lifnr.
          MESSAGE e347(zfi) WITH zfivmsbank-lifnr.
*          message s347(zfi) with zfivmsbank-lifnr.
* End of <RD1K984792> on 16052013
        ENDIF.
      ENDIF.
*      endif.
    ENDIF.
*  endif.
* End of <> on 151110
  ELSE.
    CLEAR g_exist_ztable.
    SELECT SINGLE *  FROM lfa1 INTO wa_lfa1 WHERE lifnr = zfivmsbank-lifnr
* Begin of <> on 09122010

*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*Begin RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*        and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK','GOVT','LEA1','LEA2','LAQ1','INVT','SUBD','UTLT','CONT').

**  Commented by ss on 10.8.2021
*        AND KTOKK IN ('SVWI','SVWF','IMMI','IMMF','BANK','GOVT','LEA1','LEA2','LAQ1','INVT','SUBD','UTLT','CONT','NOMI', 'SHYG', 'TRNI'). "Added by ruhani garg

AND ktokk NE 'VEMP'.  " added by ss on 10.8.2021


*End RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586

*    and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK').
* End of <> on 09122010
    IF sy-subrc = 0.
      SELECT SINGLE * FROM lfbk INTO wa_lfbk WHERE lifnr = zfivmsbank-lifnr.  "#EC CI_NOORDER
      IF sy-subrc = 0.
        zfivmsbank-lifnr = wa_lfbk-lifnr.
        zfivmsbank-name1 = wa_lfa1-name1.
        zfivmsbank-bankl = wa_lfbk-bankl.
        zfivmsbank-bankn = wa_lfbk-bankn.
        zfivmsbank-koinh = wa_lfbk-koinh.
        CLEAR : wa_lfa1 ,wa_lfbk  .
      ELSE.

        zfivmsbank-lifnr = wa_lfa1-lifnr.
        zfivmsbank-name1 = wa_lfa1-name1.
        zfivmsbank-bankl = wa_lfbk-bankl.
        zfivmsbank-bankn = wa_lfbk-bankn.
        zfivmsbank-koinh = wa_lfbk-koinh.

      ENDIF.
    ELSE.
      MESSAGE e217(zfi) WITH zfivmsbank-lifnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_LIFNR_FLOW

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro_s
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0087   text
*      -->P_0088   text
*----------------------------------------------------------------------*
FORM bdc_dynpro_s USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  bdc_field_s
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0722   text
*      -->P_0723   text
*----------------------------------------------------------------------*
FORM bdc_field_s USING fnam fval.

  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.

ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  UPDATE_FK02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM UPDATE_FK02 .
*
*perform bdc_dynpro_s      using 'SAPMF02K' '0106'.
*perform bdc_field_s       using 'BDC_CURSOR'
*                              'RF02K-D0130'.
*perform bdc_field_s       using 'BDC_OKCODE'
*                              '/00'.
*perform bdc_field_s       using 'RF02K-LIFNR'
*                               zfivmsbank-lifnr. "record-LIFNR_001.
*perform bdc_field_s       using 'RF02K-BUKRS'
*                               zfivmsbank-ccode.  "record-BUKRS_002.
*perform bdc_field_s       using 'RF02K-D0130'
*                              'X'.               "record-D0130_003.
*perform bdc_dynpro_s      using 'SAPMF02K' '0130'.
*perform bdc_field_s       using 'BDC_CURSOR'
*                              'LFBK-BANKS(01)'.
*perform bdc_field_s       using 'BDC_OKCODE'
*                              '=BDEL'.
*perform bdc_field_s       using 'LFA1-XZEMP'
*                              'X'.               "record-XZEMP_004.
*perform bdc_dynpro_s      using 'SAPMF02K' '0130'.
*perform bdc_field_s       using 'BDC_CURSOR'
*                              'LFBK-BANKS(01)'.
*perform bdc_field_s       using 'BDC_OKCODE'
*                              '=UPDA'.
*perform bdc_field_s       using 'LFA1-XZEMP'
*                              'X'.               "record-XZEMP_005.
*perform bdc_transaction using 'FK02'.
*
*perform bdc_dynpro_s      using 'SAPMF02K' '0106'.
*perform bdc_field_s       using 'BDC_CURSOR'
*                              'RF02K-D0215'.
*perform bdc_field_s       using 'BDC_OKCODE'
*                              '/00'.
*perform bdc_field_s       using 'RF02K-LIFNR'
*                              zfivmsbank-lifnr. "record-LIFNR_006.
*perform bdc_field_s       using 'RF02K-BUKRS'
*                              zfivmsbank-ccode.  "record-BUKRS_007.
*perform bdc_field_s       using 'RF02K-D0215'
*                              'X'.               "record-D0215_008.
*perform bdc_dynpro_s      using 'SAPMF02K' '0215'.
*perform bdc_field_s       using 'BDC_CURSOR'
*                              'LFB1-ZWELS'.
*perform bdc_field_s       using 'BDC_OKCODE'
*                              '=UPDA'.
*perform bdc_field_s       using 'LFB1-ZTERM'
*                              '0001'.            "record-ZTERM_009.
*perform bdc_field_s       using 'LFB1-REPRF'
*                              'X'.               "record-REPRF_010.
*perform bdc_field_s       using 'LFB1-ZWELS'
*                              'C'.               "record-ZWELS_011.
*perform bdc_transaction using 'FK02'.
*
*ENDFORM.                    " UPDATE_FK02
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1725   text
*----------------------------------------------------------------------*
FORM bdc_transaction  USING    tcode.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.


  REFRESH messtab.
*Begin RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*  CALL TRANSACTION TCODE USING BDCDATA
*                   MODE   'N'     ""'E'  16052013  "'A'   "'N' "'E'   <RD1K975271> 01032011 28072012
*                   UPDATE 'S'
*                   MESSAGES INTO MESSTAB.
  DATA: l_mode(1).
  l_mode = 'N'.
  CALL TRANSACTION tcode USING bdcdata
                   MODE   l_mode " 'A'  ""'E'  16052013  "'A'   "'N' "'E'   <RD1K975271> 01032011 28072012
                   UPDATE 'S'
                   MESSAGES INTO messtab.
*End RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919

  l_subrc = sy-subrc.
  WRITE: / 'CALL_TRANSACTION',
           tcode,
           'returncode:'(i05),
           l_subrc,
           'RECORD:',
           sy-index.
  LOOP AT messtab.
* Begin of <> on 24022011
*    IF MESSTAB-MSGID = 'F2' AND MESSTAB-MSGNR = '042'.   " Commented by ss on 6.7.2021
    IF messtab-msgid = 'F2' AND
      ( messtab-msgnr = '042' OR messtab-msgnr = '056' ).  " Added by ss on 6.7.2021
*      ZFIVMSBANK-STATUS = 'APPROVED BY HOF'.  " Commented by ss on 11.10.2021
      zfivmsbank-status = 'REGISTRATION SUCCESSFUL'.  " added by ss on 11.10.2021
      MODIFY zfivmsbank.
* Begin of <> on 17052013
      IF messtab-msgid = 'F2' AND messtab-msgnr = '042'
                              AND ( zfivmsbank-status = 'APPROVED BY HOF'
                              OR  zfivmsbank-status = 'REGISTRATION SUCCESSFUL').  " added by ss on 11.10.2021
        g_asy_reqno = zfivmsbank-reqno.
        g_asy_lifnr = zfivmsbank-lifnr.
        g_asy_uname = messtab-msgv2. ""SY-UNAME.
*               message e591(zfi) with ZFIVMSBANK-REQNO ZFIVMSBANK-LIFNR sy-uname.
      ENDIF.
* End of <> on 17052013
    ELSE.
* End of <> on 24022011
      SELECT SINGLE * FROM t100 INTO wa_t100 WHERE sprsl = messtab-msgspra
                                AND   arbgb = messtab-msgid
                                AND   msgnr = messtab-msgnr.
      IF sy-subrc = 0.
        l_mstring = wa_t100-text.
        IF l_mstring CS '&1'.
          REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
          REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
          REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
          REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
        ELSE.
          REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
          REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
          REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
          REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
        ENDIF.
        CONDENSE l_mstring.
        WRITE: / messtab-msgtyp, l_mstring(250).
      ELSE.
        WRITE: / messtab.
      ENDIF.
    ENDIF.
  ENDLOOP.
  SKIP.
  REFRESH bdcdata.
ENDFORM.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  BDC_XK05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_xk05 .

  PERFORM bdc_dynpro_s      USING 'SAPMF02K' '0500'.
  PERFORM bdc_field_s       USING 'BDC_CURSOR'
                                'RF02K-BUKRS'.
  PERFORM bdc_field_s       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field_s       USING 'RF02K-LIFNR'
                                zfivmsbank-lifnr. "record-LIFNR_001.
*perform bdc_field_s       using 'RF02K-BUKRS'
*                              record-BUKRS_002.
  PERFORM bdc_dynpro_s      USING 'SAPMF02K' '0510'.
  PERFORM bdc_field_s       USING 'BDC_CURSOR'
                                'LFA1-SPERR'.
  PERFORM bdc_field_s       USING 'BDC_OKCODE'
                                '=UPDA'.
  PERFORM bdc_field_s       USING 'LFA1-SPERR'
                                  'X'.   "record-SPERR_003.

  PERFORM bdc_transaction USING 'XK05'.  "#EC CI_USAGE_OK

ENDFORM.                                                    " BDC_XK05
*&---------------------------------------------------------------------*
*&      Form  PROCESS_ATTACH_FILE_BL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TRANS_MODE  text
*----------------------------------------------------------------------*
FORM process_attach_file_bl  USING  p_tr_mode.
  DATA :  ist_att_files LIKE TABLE OF swotobjid,
          wa_att_files  LIKE swotobjid.

  IF p_tr_mode = 'N'.

    CHECK NOT zmm_vend_block-bukrs IS INITIAL.

    MESSAGE i856(zmm).

  ELSEIF p_tr_mode = 'M'.

    CHECK NOT zmm_vend_block-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_block-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    APPEND wa_att_files TO ist_att_files.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
      EXPORTING
        attachment_data     = ''
        attachment_type     = 'DOC'
      TABLES
        application_objects = ist_att_files.

  ELSEIF p_tr_mode = 'D'.

    CHECK NOT zmm_vend_block-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_block-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_DISP_API1'
      EXPORTING
        application_object = wa_att_files.

  ELSEIF p_tr_mode = 'X'.

    CHECK NOT zmm_vend_block-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_block-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_DISP_API1'
      EXPORTING
        application_object = wa_att_files.

  ENDIF.
ENDFORM.                    " PROCESS_ATTACH_FILE_BL
*&---------------------------------------------------------------------*
*&      Form  PROCESS_LIST_ATTACH_FILE_BL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TRANS_MODE  text
*----------------------------------------------------------------------*
FORM process_list_attach_file_bl  USING p_tr_mode.
  DATA :  ist_att_files LIKE TABLE OF swotobjid,
          wa_att_files  LIKE swotobjid.

  DATA : ist_exclude LIKE soxet OCCURS 0 WITH HEADER LINE.

  ist_exclude-fcode = 'EXPO'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'IMPO'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'HGEN'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'OLNK'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'REFL'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'COPY'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'CHNG'.
  APPEND ist_exclude.

  ist_exclude-fcode = 'PRIN'.
  APPEND ist_exclude.

  CLEAR : ist_exclude.

  IF p_tr_mode = 'M' OR
     p_tr_mode = 'D' OR
     p_tr_mode = 'X' OR
     p_tr_mode = 'A'

  """""""""""""""""""""""""""""""""
     "added by lipsy for list in release and approve on 28.08.2013 RD1K983016

    OR  p_tr_mode = 'AP' OR

         p_tr_mode = 'RL'
    """"end of add by lipsy for list in release and approve on 28.08.2013 RD1K983016


    """""""""""""""""""""""""""""""""""""


   """"""""""""""""""""""""""""
    .

    CHECK NOT zmm_vend_block-reqno IS INITIAL.

    wa_att_files-logsys  = zmm_vend_block-reqno.
    wa_att_files-objtype = 'ATT'.
    wa_att_files-objkey  = '01'.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = wa_att_files
      TABLES
        func_exclude       = ist_exclude.
  ENDIF.
ENDFORM.                    " PROCESS_LIST_ATTACH_FILE_BL
*&---------------------------------------------------------------------*
*&      Form  CHECK_ATTACHMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_attachment .
  LOOP AT g_tc319_itab INTO g_tc319_wa.
    IF         NOT g_tc319_wa-bankl     IS INITIAL AND
               NOT g_tc319_wa-bankn     IS INITIAL AND
               NOT g_tc319_wa-koinh     IS INITIAL AND
               NOT g_tc319_wa-bankl_new IS INITIAL AND
               NOT g_tc319_wa-bankn_new IS INITIAL AND
               NOT g_tc319_wa-koinh_new IS INITIAL.
      IF NOT g_tc319_wa-attach IS INITIAL.
        g_attachment = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_ATTACHMENT
*&---------------------------------------------------------------------*
*&      Form  POPUP_MESSAGE_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_TEXT  text
*----------------------------------------------------------------------*
*FORM POPUP_MESSAGE_DISPLAY USING L_TEXT.
** Begin of <> on 150911
*                 CALL FUNCTION 'POPUP_TO_INFORM'
*                   EXPORTING
*                     TITEL         = 'Vendor Management System'
*                     TXT1          =  L_TEXT
*                     TXT2          =  '.'
**                    TXT3          = ' '
**                    TXT4          = ' '
*                           .
** End of <> on 150911
*ENDFORM.                    " POPUP_MESSAGE_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  CHECK_ATTACH_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_attach_files .
  LOOP AT g_tc319_itab INTO g_tc319_wa.
    IF NOT g_tc319_wa-bankl     IS INITIAL AND    "zfivmsbank
         NOT g_tc319_wa-bankn     IS INITIAL AND
         NOT g_tc319_wa-koinh     IS INITIAL AND
         NOT g_tc319_wa-bankl_new IS INITIAL AND
         NOT g_tc319_wa-bankn_new IS INITIAL AND
         NOT g_tc319_wa-koinh_new IS INITIAL.
      IF g_tc319_wa-attach <> 'X'.
        MESSAGE w419(zfi) WITH g_tc319_wa-lifnr.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_ATTACH_FILES
*&---------------------------------------------------------------------*
*&      Form  LIST_FILES_0531
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files_0531 .
  DATA : l_list TYPE zfivmsbank-zlist.
  IF g_okcode531 = 'LIST'.
    CLEAR g_att_files_wa.

    CONCATENATE g_tc531_wa-srno(3) g_tc531_wa-reqno+3(7) INTO docno_lifnr.

    g_att_files_wa-logsys  = '01'.
    g_att_files_wa-objtype = 'VENDOR'.
    g_att_files_wa-objkey  = docno_lifnr.

    REFRESH exclude_tab[].
    exclude_tab-fcode = 'EXPO'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'IMPO'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'HGEN'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'OLNK'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'REFL'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'COPY'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'CHNG'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'PRIN'.
    APPEND exclude_tab.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa
        function           = ' '
      TABLES
        func_exclude       = exclude_tab.
    "
  ENDIF.
ENDFORM.                    " LIST_FILES_0531
*&---------------------------------------------------------------------*
*&      Form  CHECK_BANKL_BANKN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bankl_bankn .

  LOOP AT g_tc319_itab INTO g_tc319_wa .
* Begin of <> on 17042012
    SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
    WHERE bankl = g_tc319_wa-bankl_new AND bankn = g_tc319_wa-bankn_new.
    IF sy-subrc = 0.
      CLEAR : l_text, l_text1 ,l_text2 , l_text3.
      SORT ist_zfivmsbank_bankl DESCENDING BY bankl bankn.
      READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
      SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
      g_tc319_wa-zflag = 'X'.
      MODIFY g_tc319_itab FROM g_tc319_wa.
      SHIFT g_tc319_wa-lifnr LEFT DELETING LEADING '0'.
      CONCATENATE 'Combination of Bank Account & IFSC Code requested for Vendor:-'g_tc319_wa-lifnr  INTO l_text1.
      CONCATENATE 'Already exists in Vendor Master :-' wa_zfivmsbank_bankl-lifnr INTO l_text2.
      CONCATENATE 'Do You Want to' ' Create New Request?' INTO l_text3.
      PERFORM popup_info USING l_text l_text1 l_text2 l_text3.

    ELSE..
* End of <> on 17042012
      SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
      WHERE bankl_new = g_tc319_wa-bankl_new AND bankn_new = g_tc319_wa-bankn_new.

      IF sy-subrc = 0.
        CLEAR : l_text, l_text1 ,l_text2 , l_text3.
        SORT ist_zfivmsbank_bankl DESCENDING BY vmc_apdate vmc_aptime. " 281211 cdate cputm.
        READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
        SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
* Begin of <RD1K979928> on 02042012
        g_tc319_wa-zflag = 'X'.
        MODIFY g_tc319_itab FROM g_tc319_wa.
* End of <RD1K979928> on 02042012
* Begin of <> on 25012012
        SHIFT g_tc319_wa-lifnr LEFT DELETING LEADING '0'.
        CONCATENATE 'With the same Combination of Bank Account' '& IFSC Code requested for'   INTO l_text.
        CONCATENATE 'Vendor:-'g_tc319_wa-lifnr ' , another request for updation of Vendor :-' wa_zfivmsbank_bankl-lifnr   INTO l_text1.
        CONCATENATE 'is' ' in process with status-' wa_zfivmsbank_bankl-status INTO l_text2.
        CONCATENATE 'Kindly check in the Report tab using Bank Key' '/Bank Account?' INTO l_text3.

*        concatenate 'Request with the same bank details exists for the Vendor-' wa_zfivmsbank_bankl-lifnr into l_text.
*        concatenate ' of CCode-' g_ccode  into l_text1.
*        concatenate 'Kindly check in the Report tab using Bank Key' '/Bank Account.' into l_text2.
*     concatenate 'Request with the same bank details exists for the Vendor' wa_zfivmsbank_bankl-lifnr 'of CCode' g_ccode into l_text.

        PERFORM popup_info USING l_text l_text1 l_text2 l_text3.
* End of <> on 25012012
*     message i426(zfi) with wa_zfivmsbank_bankl-lifnr g_ccode.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_BANKL_BANKN
*&---------------------------------------------------------------------*
*&      Form  POPUP_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_TEXT  text
*----------------------------------------------------------------------*
FORM popup_info  USING  l_text l_text1 l_text2 l_text3.
* CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
**      titlebar              = p_title
*      text_question         = l_text        "p_question
*      text_button_1         = 'Yes'(003)
*      text_button_2         = 'No'(004)
*      default_button        = '1'
*      display_cancel_button = ' '
*    IMPORTING
*      answer                = g_ans.

*****************************************************
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
      defaultoption  = 'Y'
      diagnosetext1  = l_text
      diagnosetext2  = l_text1
      diagnosetext3  = l_text2
      textline1      = l_text3
*     TEXTLINE2      = ''
      titel          = 'Create VMS Details'
*     START_COLUMN   = 25
*     START_ROW      = 6
      cancel_display = ''
    IMPORTING
      answer         = g_ans.

ENDFORM.                    " POPUP_INFO
*&---------------------------------------------------------------------*
*&      Form  UPDATE_POSTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_postal .

  PERFORM bdc_dynpro_s      USING 'SAPMF02K' '0101'.
  PERFORM bdc_field_s       USING 'BDC_CURSOR'
                                'RF02K-D0110'.
  PERFORM bdc_field_s       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field_s       USING 'RF02K-LIFNR'
                                ist_unbl-lifnr.      "record-LIFNR_001.
  PERFORM bdc_field_s       USING 'RF02K-D0110'
                                'X'.                 "record-D0110_002.
  PERFORM bdc_dynpro_s      USING 'SAPMF02K' '0110'.
  PERFORM bdc_field_s       USING 'BDC_CURSOR'
                                'LFA1-PSTLZ'.
  PERFORM bdc_field_s       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field_s       USING 'LFA1-NAME1'
                                ist_unbl-name1.    "record-NAME1_003.
  PERFORM bdc_field_s       USING 'LFA1-SORTL'
                                ist_unbl-sortl.    "record-SORTL_004.
  PERFORM bdc_field_s       USING 'LFA1-ORT01'
                                ist_unbl-ort01.    "record-ORT01_005.
  PERFORM bdc_field_s       USING 'LFA1-PSTLZ'
                                ist_unbl-pstlz.     "record-PSTLZ_006.
  PERFORM bdc_field_s       USING 'LFA1-LAND1'
                                ist_unbl-land1.   "record-LAND1_007.
  PERFORM bdc_field_s       USING 'LFA1-REGIO'
                                ist_unbl-regio.   "record-REGIO_008.
  PERFORM bdc_field_s       USING 'LFA1-SPRAS'
                                'EN'.             "record-SPRAS_009.

  PERFORM bdc_transaction USING 'XK02'.  "#EC CI_USAGE_OK[2226131]

ENDFORM.                    " UPDATE_POSTAL
*&---------------------------------------------------------------------*
*&      Form  BDC_OPERATION_XK02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_operation_xk02 .
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0101'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF02K-D0110'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

  """""""""""""""""""""""""""""""""""""""
  ""commented by lipsy on 13.03.2013 for correct vendor
*  perform bdc_field       using 'RF02K-LIFNR'
*                                ist_unbl-lifnr.
  ""commented by lipsy on 13.03.2013 for correct vendor

  """"""""""""""""""""""""""""""""
  """"""""""""""""""""""""""""""
  ""added by lipsy on 13.03.2013 for correct vendor

  PERFORM bdc_field       USING 'RF02K-LIFNR'
                                ist_lfa1-lifnr.
  ""end of add by lipsy on 13.03.2013 for correct vendor
  """"""""""""""""""""""""""""""


  """""""""""""""""""""""""""""""""""""""""""""
  PERFORM bdc_field       USING 'RF02K-D0110'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0110'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'LFA1-NAME1'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=0510'.
*perform bdc_field       using 'LFA1-NAME1'
*                              record-NAME1_003.
*perform bdc_field       using 'LFA1-SORTL'
*                              record-SORTL_004.
*perform bdc_field       using 'LFA1-STRAS'
*                              record-STRAS_005.
*perform bdc_field       using 'LFA1-ORT01'
*                              record-ORT01_006.
*perform bdc_field       using 'LFA1-PSTLZ'
*                              record-PSTLZ_007.
*perform bdc_field       using 'LFA1-LAND1'
*                              record-LAND1_008.
*perform bdc_field       using 'LFA1-REGIO'
*                              record-REGIO_009.
*perform bdc_field       using 'LFA1-SPRAS'
*                              record-SPRAS_010.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0510'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'LFA1-SPERR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'LFA1-SPERR'
                                ist_lfa1-sperr. "record-SPERR_011.
  PERFORM bdc_field       USING 'LFA1-SPERM'
                                ist_lfa1-sperm.  "record-SPERM_012.
  PERFORM bdc_field       USING 'LFA1-SPERQ'
                                ist_lfa1-sperq.  "record-SPERQ_013.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0510'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'LFA1-SPERQ'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=PF03'.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0110'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'LFA1-NAME1'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=0520'.
*perform bdc_field       using 'LFA1-NAME1'
*                              record-NAME1_014.
*perform bdc_field       using 'LFA1-SORTL'
*                              record-SORTL_015.
*perform bdc_field       using 'LFA1-STRAS'
*                              record-STRAS_016.
*perform bdc_field       using 'LFA1-ORT01'
*                              record-ORT01_017.
*perform bdc_field       using 'LFA1-PSTLZ'
*                              record-PSTLZ_018.
*perform bdc_field       using 'LFA1-LAND1'
*                              record-LAND1_019.
*perform bdc_field       using 'LFA1-REGIO'
*                              record-REGIO_020.
*perform bdc_field       using 'LFA1-SPRAS'
*                              record-SPRAS_021.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0520'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'LFA1-LOEVM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'LFA1-LOEVM'
                                ist_lfa1-loevm.  "record-LOEVM_022.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0520'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF02K-LIFNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=UPDA'.
*perform bdc_transaction using 'XK02'.

ENDFORM.                    " BDC_OPERATION_XK02
*&---------------------------------------------------------------------*
*&      Form  REG_SUCCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reg_success .
  MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
  zfivmsbank-vmc_cpf_no = g_cpf.
  zfivmsbank-vmc_name   = sy-uname.
  zfivmsbank-vmc_apdate = sy-datum.
  zfivmsbank-vmc_aptime = sy-uzeit.
  IF NOT zfivmsbank-bankl     IS INITIAL AND
     NOT zfivmsbank-bankn     IS INITIAL AND
     NOT zfivmsbank-koinh     IS INITIAL AND
     NOT zfivmsbank-bankl_new IS INITIAL AND
     NOT zfivmsbank-bankn_new IS INITIAL AND
     NOT zfivmsbank-koinh_new IS INITIAL.
    zfivmsbank-registration   = 'R'.
    zfivmsbank-deregistration = 'D'.
  ELSEIF NOT zfivmsbank-bankl_new IS INITIAL AND
         NOT zfivmsbank-bankn_new IS INITIAL AND
         NOT zfivmsbank-koinh_new IS INITIAL.
    zfivmsbank-registration   = 'R'.
  ENDIF.

  zfivmsbank-status = 'REGISTRATION SUCCESSFUL'.
  PERFORM update_fk02.   "Change sequence of process on 19062012
*   MODIFY ZFIVMSBANK.
  IF sy-subrc = 0.
*    perform update_fk02.
    MODIFY zfivmsbank.
    IF zfivmsbank-bankl_new(4) = 'SBIN'.
      IF zfivmsbank-ccode = 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*        UPDATE lfb1 SET : zwels = '9'
*        WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.  Commented on 07052012
        PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr '9'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
      ELSEIF zfivmsbank-ccode <> 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*        UPDATE lfb1 SET : zwels = 'S'
*        WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.   Commented on 07052012
        PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr 'S'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
      ENDIF.
    ENDIF.
    IF zfivmsbank-bankl_new(4) <> 'SBIN'.
      IF zfivmsbank-ccode = 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*        UPDATE lfb1 SET : zwels = '8'
*        WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.  Commented on 07052012
        PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr '8'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
      ELSEIF zfivmsbank-ccode <> 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*        UPDATE lfb1 SET : zwels = 'N'
*        WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.   Commented on 07052012
        PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr 'N'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
      ENDIF.
    ENDIF.

  ENDIF.

  g_vmc = 'X'.

ENDFORM.                    " REG_SUCCESS
*&---------------------------------------------------------------------*
*&      Form  REG_REL_VMC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reg_rel_vmc .
  MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
  zfivmsbank-vmc_cpf_no = g_cpf.
  zfivmsbank-vmc_name   = sy-uname.
  zfivmsbank-vmc_apdate = sy-datum.
  zfivmsbank-vmc_aptime = sy-uzeit.
  IF NOT zfivmsbank-bankl     IS INITIAL AND
     NOT zfivmsbank-bankn     IS INITIAL AND
     NOT zfivmsbank-koinh     IS INITIAL AND
     NOT zfivmsbank-bankl_new IS INITIAL AND
     NOT zfivmsbank-bankn_new IS INITIAL AND
     NOT zfivmsbank-koinh_new IS INITIAL.
    zfivmsbank-registration   = 'R'.
    zfivmsbank-deregistration = 'D'.
  ELSEIF NOT zfivmsbank-bankl_new IS INITIAL AND
         NOT zfivmsbank-bankn_new IS INITIAL AND
         NOT zfivmsbank-koinh_new IS INITIAL.
    zfivmsbank-registration   = 'R'.
  ENDIF.
* Begin of Change on 02052011
  IF zfivmsbank-ccode = 'OVL'.
*-----------Commented & Added by Manisha bh.Dt:04.05.2017-----------*
*    zfivmsbank-status = 'RELEASE BY VMC FOR OVL'.  ""changes by hiren Commented by ss on 9/3/21
    zfivmsbank-status = 'REGISTRATION SUCCESSFUL'. "uncommented by ss on 9/3/21
*-------------------------------------------------------------------*
  ELSE.
* End of Change on 02052011
    zfivmsbank-status = 'RELEASE BY VMC'.   "APPROVED 270911
  ENDIF.
  PERFORM update_fk02.                                      "19062012
*  MODIFY ZFIVMSBANK.    "19062012
  IF sy-subrc = 0.
* Begin of <> on 20042012
* Begin of Change on 250910
    IF zfivmsbank-registration = 'R'. "zfivmsbank-deregistration = 'D'.
* Begin of Change on 011210
*                    update lfa1 set sperr = 'X'
*                              where lifnr = zfivmsbank-lifnr.
      PERFORM bdc_xk05.
* End of Change on 011210
* Begin of Change for BDC T Code FK02 on 271010
      IF zfivmsbank-status = 'RELEASE BY VMC' OR zfivmsbank-status = 'RELEASE BY VMC FOR OVL'  "APPROVED 270911
        OR zfivmsbank-status = 'REGISTRATION SUCCESSFUL'. "added by ss on 9/3/21
* Begin of <> on 04052012
        MODIFY zfivmsbank.                                  "19062012
*        perform update_fk02.   "19062012

        IF zfivmsbank-bankl_new(4) = 'SBIN'.
          IF zfivmsbank-ccode = 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*            UPDATE lfb1 SET : zwels = '9'
*            WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.   Commented on 07052012
            PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr '9'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
          ELSEIF zfivmsbank-ccode <> 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*            UPDATE lfb1 SET : zwels = 'S'
*            WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.   Commented on 07052012
            PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr 'S'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
          ENDIF.
        ENDIF.
        IF zfivmsbank-bankl_new(4) <> 'SBIN'.
          IF zfivmsbank-ccode = 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*            UPDATE lfb1 SET : zwels = '8'
*            WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.    Commented on 07052012
            PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr '8'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
          ELSEIF zfivmsbank-ccode <> 'OVL'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFB1 BP-managed; payment method ZWELS via VMD_EI_API (FORM zz_s4_lfb1_zwels).
*            UPDATE lfb1 SET : zwels = 'N'
*            WHERE lifnr = zfivmsbank-lifnr. " and bukrs = zfivmsbank-ccode.    Commented on 07052012
            PERFORM zz_s4_lfb1_zwels USING zfivmsbank-lifnr 'N'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
          ENDIF.
        ENDIF.
*                          LIFNR = zfivmsbank-lifnr.
*                          CCODE = zfivmsbank-ccode.
*                          export : LIFNR to MEMORY ID 'LIFNR',
*                                   CCODE to MEMORY ID 'CCODE'.
*                          submit zupdate_fk02_1 and return.
*
*                          commit WORK.
*                          wait UP TO 9 SECONDS.
*                          submit zupdate_fk02_2 and return.
**                    perform update_fk02.
* End of <> on 04052012
      ENDIF.
* End of Change
    ENDIF.
* End of Change on 250910
* End of <> on 20042012
    g_vmc = 'X'.
  ENDIF.
ENDFORM.                    " REG_REL_VMC
*&---------------------------------------------------------------------*
*&      Form  REG_REJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reg_reject .
  MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
  zfivmsbank-vmc_cpf_no = g_cpf.
  zfivmsbank-vmc_name   = sy-uname.
  zfivmsbank-vmc_apdate = sy-datum.
  zfivmsbank-vmc_aptime = sy-uzeit.

  IF zfivmsbank-ccode = 'OVL'.
    zfivmsbank-status = 'REJECTED BY VMC FOR OVL'.

  ELSE.
    zfivmsbank-status = 'REJECTED BY VMC'.
  ENDIF.
  MODIFY zfivmsbank.
ENDFORM.                    " REG_REJECT
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_mail_assign .
  "form added by lipsy on 1.08.2013 for  getting mail in block and unblock
  """"""""""""" RD1K979902

  DATA l_str_as(50).
  CLEAR l_str_as.

  PERFORM setup_trx_and_rtx_mailboxes.
  IF g_trans_mode = 'AP'  .

    IF zmm_vend_unblock-reqno IS NOT INITIAL.
      CONCATENATE 'Vendor rejected by approver request no :' zmm_vend_unblock-reqno ist_unbl-lifnr INTO l_str_as

                                          SEPARATED BY space.
    ELSEIF zmm_vend_block-reqno IS NOT INITIAL.

      CONCATENATE 'Vendor rejected by approver request no :' zmm_vend_block-reqno ist_bl-lifnr INTO l_str_as

                                        SEPARATED BY space.
    ENDIF.


  ELSEIF  g_trans_mode = 'A'.

    IF zmm_vend_unblock-reqno IS NOT INITIAL.

      CONCATENATE 'Vendor rejected by assigner request no :' zmm_vend_unblock-reqno ist_unbl-lifnr INTO l_str_as
                                                 SEPARATED BY space.
    ELSEIF zmm_vend_block-reqno IS NOT INITIAL.

      CONCATENATE 'Vendor rejected by assigner request no :' zmm_vend_block-reqno ist_bl-lifnr INTO l_str_as
                                            SEPARATED BY space.
    ENDIF.
  ELSE.

    IF zmm_vend_unblock-reqno IS NOT INITIAL.
      CONCATENATE 'Vendor blocked based on request no :' zmm_vend_unblock-reqno INTO l_str_as
                                                 SEPARATED BY space.
    ELSEIF zmm_vend_block-reqno IS NOT INITIAL.
      CONCATENATE 'Vendor blocked based on request no :' zmm_vend_block-reqno INTO l_str_as
                                               SEPARATED BY space.
    ENDIF.


  ENDIF.
  IF zmm_vend_unblock-reqno IS NOT INITIAL.

    PERFORM get_user USING zmm_vend_unblock-assigned_by.
    PERFORM create_and_send_mail_object USING zmm_vend_unblock-ernam
                                              l_str_as.
  ELSEIF zmm_vend_block-reqno IS NOT INITIAL.

    PERFORM get_user USING zmm_vend_block-assigned_by.
    PERFORM create_and_send_mail_object USING zmm_vend_block-ernam
                                               l_str_as.


  ENDIF.
  """""end of addition by lipsy on 1.08.2013 for  getting mail in block and unblock
  """""""" RD1K979902

ENDFORM.                    " SEND_MAIL_ASSIGN
*&---------------------------------------------------------------------*
*&      Module  CHECK_MOBNUMBER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mobnumber INPUT.

  DATA: l_mobile_num TYPE zmm_dvencrt-mob_number.
  DATA:len TYPE i.
  CLEAR l_mobile_num.
  l_mobile_num = ist_unbl-mob_number.
  CONDENSE l_mobile_num.
  IF NOT l_mobile_num IS INITIAL.
    len = strlen( l_mobile_num ).
* Begin of <> 01092014
    SHIFT ist_unbl-lifnr LEFT DELETING LEADING '0'.
    IF ist_unbl-lifnr(1) = '4' OR ist_unbl-lifnr(1) =  '6'.
    ELSE.
* end of <>
      IF l_mobile_num CO ' 0123456789' AND ( len EQ 10 ).
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'IST_UNBL-MOB_NUMBER'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
        MESSAGE e973(zmm).
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_MOBNUMBER  INPUT
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sms USING l_text created_by .
  DATA: http_client TYPE REF TO if_http_client.
  DATA: msg(100),
        l_enddate         TYPE pa0009-endda VALUE '99991231',
        ist_pa9205        TYPE TABLE OF pa9205,
        wa_pa9205         TYPE          pa9205,
        wf_string         TYPE string,
        mob_no(12),
        result            TYPE string,l_reason_desc(35), l_result(50),
        disp_txt          TYPE string.

  CLEAR: mob_no, msg, wf_string, result.
  CLEAR: l_reason_desc, l_result.


  SELECT * FROM pa9205 INTO CORRESPONDING FIELDS OF TABLE ist_pa9205 WHERE pernr = created_by"ZMM_VEND_UNBLOCK-ERNAM
                                                                          AND subty = '01'                  "22112013 by Sudhir Sharma
                                                                        AND endda = l_enddate.
  IF sy-subrc = 0.
    SORT ist_pa9205 BY begda DESCENDING.
    READ TABLE ist_pa9205 INTO wa_pa9205 INDEX 1.

    IF sy-subrc = 0.
*      if g_bwart = 'FC1' or g_bwart = 'F51'.
*        USERID1 = g_ernam.
*        g_pernr = g_ernam.
*        CONCATENATE 'File Tracking No.'  '-' RM07M-CHARG 'Archived/Closed'  INTO msg.
*      elseif g_bwart = 'F41'.
*        CONCATENATE text-004 '-' RM07M-CHARG  '-' MCHA-ZZDES '-' TEXT-005 '-' G_PERNR INTO msg.
*      endif.

*      CONCATENATE text-309  ZMM_VEND_UNBLOCK-REQNO INTO msg.
*      CONCATENATE text-309  ZMM_VEND_UNBLOCK-REQNO INTO msg.

*      CONCATENATE text-309 ZMM_VEND_UNBLOCK-REQNO INTO msg
*                                             SEPARATED BY space.

      msg = l_text.
      SHIFT wa_pa9205-zphone LEFT DELETING LEADING '0'.
      CONCATENATE '91' wa_pa9205-zphone INTO  mob_no.

      CLEAR wf_string .
      CONCATENATE
        'http://10.205.48.190:13013/cgi-bin/sendsms?'
        'username=ongc&password=ongc12&from=ONGC-OL&to=' mob_no
        '&text=' msg
        '&remLen=400'  "180'  20032013
      INTO wf_string .

      CALL METHOD cl_http_client=>create_by_url
        EXPORTING
          url                = wf_string
        IMPORTING
          client             = http_client
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
          OTHERS             = 4.


      CALL METHOD http_client->send
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2.

      CALL METHOD http_client->receive
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3.
      CLEAR result .
      result = http_client->response->get_cdata( ).

      MOVE result TO l_result .
      CONCATENATE 'Message from SMS gateway:' l_result+2 INTO l_result.
    ENDIF.
  ENDIF.



ENDFORM.                    " SEND_SMS
*&---------------------------------------------------------------------*
*&      Module  REFRESH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE refresh INPUT.
  IF g_trans_mode = 'D'.
    REFRESH CONTROL 'TAB_UNBL' FROM SCREEN '0420'.
    REFRESH ist_unbl[].

  ENDIF.

ENDMODULE.                 " REFRESH  INPUT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MOBNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_mobnum .

  DATA: v_objty        TYPE ad_ownertp,
        v_objid        TYPE ad_objkey,
        v_contx        TYPE ad_context VALUE '0001',
        v_addnr        TYPE ad_addrnum,
        update_flag(1).

*  DATA: t_adsmtp TYPE TABLE OF bapiadsmtp WITH HEADER LINE,
*        t_adsmtx TYPE TABLE OF bapiadsmtx WITH HEADER LINE,
*  DATA:      t_return TYPE TABLE OF bapiret2   WITH HEADER LINE.



  IF NOT ist_unbl[] IS INITIAL.

    LOOP AT ist_unbl.

      MOVE-CORRESPONDING ist_unbl TO wa_zmm_vend_unblock.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ist_unbl-lifnr
        IMPORTING
          output = ist_unbl-lifnr.

      obj_id = ist_unbl-lifnr.
      v_objty = 'LFA1'.
*v_objid = p_kunnr.

      CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
        EXPORTING
          obj_type       = v_objty
          obj_id         = obj_id
          context        = v_contx
        IMPORTING
          address_number = v_addnr
        TABLES
*         bapiadsmtp     = t_adsmtp
          bapiadtel      = bapiadtel.
      return         =   return.





      IF bapiadtel[] IS INITIAL.
        bapiadtel-telephone    = ist_unbl-mob_number.
        bapiadtel-r_3_user     = '3'.
        bapiadtel_x-telephone  = 'X'.
        bapiadtel_x-r_3_user   = 'X'.
        bapiadtel_x-updateflag = 'I'.
        APPEND: bapiadtel, bapiadtel_x.
        CLEAR: bapiadtel, bapiadtel_x.
        update_flag = 'X'.
      ELSE.

        LOOP AT bapiadtel.

          IF bapiadtel-telephone IS NOT INITIAL AND bapiadtel-telephone NE ist_unbl-mob_number.
            REFRESH bapiadtel[].
            CLEAR bapiadtel.
            bapiadtel-telephone    = ist_unbl-mob_number.
            bapiadtel-r_3_user     = '3'.
*            MODIFY bapiadtel.
            bapiadtel_x-telephone  = 'X'.
            update_flag = 'X'.
            APPEND : bapiadtel.
          ENDIF.

          bapiadtel_x-r_3_user   = 'X'.
          bapiadtel_x-updateflag = 'U'.
          APPEND : bapiadtel_x.
          CLEAR: bapiadtel, bapiadtel_x.
        ENDLOOP.


      ENDIF.

      IF update_flag NE 'X'.

        REFRESH : bapiadtel,bapiadtel_x.
        CONTINUE.
      ENDIF.

      objtype = 'LFA1'.

      obj_id_ext = ' '.
      context = '0001'.

      DATA : addrno TYPE bapi4001_1-addr_no.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = IST_UNBL-LIFNR
*              IMPORTING
*                OUTPUT = IST_UNBL-LIFNR.
*
*            obj_id = IST_UNBL-LIFNR.

      CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
        EXPORTING
          obj_type       = objtype
          obj_id         = obj_id
*         OBJ_ID_EXT     = obj_id_ext
          context        = context
*         ACCEPT_ERROR   = ' '
*         SAVE_ADDRESS   = 'X'
*         IV_CHECK_ADDRESS            = 'X'
*         IV_TIME_DEPENDENT_COMM_DATA = ' '
        IMPORTING
          address_number = addrno
        TABLES
*         BAPIAD1VL      =
          bapiadtel      = bapiadtel
*         BAPIADFAX      =
*         BAPIADTTX      =
*         BAPIADTLX      =
*         BAPIADSMTP     = bapiadsmtp
*         BAPIADRML      =
*         BAPIADX400     =
*         BAPIADRFC      =
*         BAPIADPRT      =
*         BAPIADSSF      =
*         BAPIADURI      =
*         BAPIADPAG      =
*         BAPIAD_REM     =
*         BAPICOMREM     =
*         BAPIADUSE      =
*         BAPIAD1VL_X    =
          bapiadtel_x    = bapiadtel_x
*         BAPIADFAX_X    =
*         BAPIADTTX_X    =
*         BAPIADTLX_X    =
*         BAPIADSMT_X    = BAPIADSMT_X
*         BAPIADRML_X    =
*         BAPIADX40_X    =
*         BAPIADRFC_X    =
*         BAPIADPRT_X    =
*         BAPIADSSF_X    =
*         BAPIADURI_X    =
*         BAPIADPAG_X    =
*         BAPIAD_RE_X    =
*         BAPICOMRE_X    =
*         BAPIADUSE_X    =
          return         = return.


      IF return IS INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

      ENDIF.


      REFRESH: bapiadtel,bapiadtel_x.
      CLEAR: update_flag.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " UPDATE_MOBNUM
*&---------------------------------------------------------------------*
*&      Form  UPDATE_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_email .
  DATA: v_objty        TYPE ad_ownertp,
        v_objid        TYPE ad_objkey,
        v_contx        TYPE ad_context VALUE '0001',
        v_addnr        TYPE ad_addrnum,
        update_flag(1).

  DATA: t_adsmtp TYPE TABLE OF bapiadsmtp WITH HEADER LINE,
        t_adsmtx TYPE TABLE OF bapiadsmtx WITH HEADER LINE,
        t_return TYPE TABLE OF bapiret2   WITH HEADER LINE.



  IF NOT ist_unbl[] IS INITIAL.

    LOOP AT ist_unbl.

      MOVE-CORRESPONDING ist_unbl TO wa_zmm_vend_unblock.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ist_unbl-lifnr
        IMPORTING
          output = ist_unbl-lifnr.

      obj_id = ist_unbl-lifnr.
      v_objty = 'LFA1'.
*v_objid = p_kunnr.

      CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
        EXPORTING
          obj_type       = v_objty
          obj_id         = obj_id
          context        = v_contx
        IMPORTING
          address_number = v_addnr
        TABLES
          bapiadsmtp     = bapiadsmtp
          return         = return.

      DATA: l_email TYPE ad_smtpadr.

*SELECT SINGLE smtp_addr INTO l_email FROM adr6 WHERE ADDRNUMBER = v_addnr.


      IF bapiadsmtp[] IS INITIAL.

        SELECT SINGLE smtp_addr INTO l_email FROM adr6 WHERE addrnumber = v_addnr.
        IF sy-subrc = 0.
          bapiadsmt_x-updateflag = 'U'.
        ELSE.
          bapiadsmt_x-updateflag = 'I'.
        ENDIF.

        bapiadsmtp-e_mail      = ist_unbl-email.
        bapiadsmtp-email_srch  = ist_unbl-email.
        bapiadsmtp-valid_from  = sy-datum.
        bapiadsmtp-home_flag = 'X'.
*    bapiadsmtp-R_3_USER    = '3'.
        bapiadsmt_x-e_mail     = 'X'.
        bapiadsmt_x-email_srch = 'X'.
        bapiadsmt_x-valid_from = 'X'.
        bapiadsmt_x-home_flag  = 'X'.
*        bapiadsmt_x-UPDATEFLAG = 'I'.
        APPEND: bapiadsmtp, bapiadsmt_x.
        CLEAR: bapiadsmtp, bapiadsmt_x.
        update_flag = 'X'.
      ELSE.

        LOOP AT bapiadsmtp.
          IF bapiadsmtp-e_mail IS NOT INITIAL AND bapiadsmtp-e_mail NE ist_unbl-email.
            REFRESH bapiadsmtp[].
            CLEAR bapiadsmtp.
            bapiadsmtp-e_mail      = ist_unbl-email.
            bapiadsmtp-email_srch  = ist_unbl-email.
            bapiadsmtp-valid_from  = sy-datum.
            bapiadsmtp-home_flag = 'X'.
            bapiadsmt_x-email_srch = 'X'.
*       bapiadsmtp-R_3_USER    = '3'.
            MODIFY bapiadsmtp.
            update_flag = 'X'.
          ENDIF.
*       BAPIADSMT_X-E_MAIL     = 'X'.
*       bapiadsmt_x-R_3_USER   = 'X'.
          bapiadsmt_x-e_mail     = 'X'.
          bapiadsmt_x-valid_from = 'X'.
          bapiadsmt_x-home_flag  = 'X'.
          bapiadsmt_x-updateflag = 'U'.
        ENDLOOP.

      ENDIF.

      IF update_flag NE 'X'.
        REFRESH: bapiadsmtp,bapiadsmt_x.
        CONTINUE.
      ENDIF.
      objtype = 'LFA1'.

      obj_id_ext = ' '.
      context = '0001'.

      DATA : addrno TYPE bapi4001_1-addr_no.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = IST_UNBL-LIFNR
*              IMPORTING
*                OUTPUT = IST_UNBL-LIFNR.
*
*            obj_id = IST_UNBL-LIFNR.

      CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
        EXPORTING
          obj_type       = objtype
          obj_id         = obj_id
*         OBJ_ID_EXT     = obj_id_ext
          context        = context
*         ACCEPT_ERROR   = ' '
*         SAVE_ADDRESS   = 'X'
*         IV_CHECK_ADDRESS            = 'X'
*         IV_TIME_DEPENDENT_COMM_DATA = ' '
        IMPORTING
          address_number = addrno
        TABLES
*         BAPIAD1VL      =
*         BAPIADTEL      = BAPIADTEL
*         BAPIADFAX      =
*         BAPIADTTX      =
*         BAPIADTLX      =
          bapiadsmtp     = bapiadsmtp
*         BAPIADRML      =
*         BAPIADX400     =
*         BAPIADRFC      =
*         BAPIADPRT      =
*         BAPIADSSF      =
*         BAPIADURI      =
*         BAPIADPAG      =
*         BAPIAD_REM     =
*         BAPICOMREM     =
*         BAPIADUSE      =
*         BAPIAD1VL_X    =
*         BAPIADTEL_X    = BAPIADTEL_X
*         BAPIADFAX_X    =
*         BAPIADTTX_X    =
*         BAPIADTLX_X    =
          bapiadsmt_x    = bapiadsmt_x
*         BAPIADRML_X    =
*         BAPIADX40_X    =
*         BAPIADRFC_X    =
*         BAPIADPRT_X    =
*         BAPIADSSF_X    =
*         BAPIADURI_X    =
*         BAPIADPAG_X    =
*         BAPIAD_RE_X    =
*         BAPICOMRE_X    =
*         BAPIADUSE_X    =
          return         = return.


      IF return IS INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*                EXPORTING
*                  WAIT = 'X'.

      ENDIF.


      REFRESH:bapiadsmtp,bapiadsmt_x.
      CLEAR: update_flag.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " UPDATE_EMAIL
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MOBILE_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_mobile_email .

  DATA: v_objty        TYPE ad_ownertp,
        v_objid        TYPE ad_objkey,
        v_contx        TYPE ad_context VALUE '0001',
        v_addnr        TYPE ad_addrnum,
        update_flag(1).

  DATA: t_adsmtp TYPE TABLE OF bapiadsmtp WITH HEADER LINE,
        t_adsmtx TYPE TABLE OF bapiadsmtx WITH HEADER LINE,
        t_return TYPE TABLE OF bapiret2   WITH HEADER LINE.



  IF NOT ist_unbl[] IS INITIAL.

    LOOP AT ist_unbl.

      MOVE-CORRESPONDING ist_unbl TO wa_zmm_vend_unblock.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ist_unbl-lifnr
        IMPORTING
          output = ist_unbl-lifnr.

      obj_id = ist_unbl-lifnr.
      v_objty = 'LFA1'.
*v_objid = p_kunnr.

      CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
        EXPORTING
          obj_type       = v_objty
          obj_id         = obj_id
          context        = v_contx
        IMPORTING
          address_number = v_addnr
        TABLES
          bapiadsmtp     = bapiadsmtp
          bapiadtel      = bapiadtel
          return         = return.


      IF bapiadtel[] IS INITIAL.
        bapiadtel-telephone    = ist_unbl-mob_number.
        bapiadtel-r_3_user     = '3'.
        bapiadtel_x-telephone  = 'X'.
        bapiadtel_x-r_3_user   = 'X'.
        bapiadtel_x-updateflag = 'I'.
        APPEND: bapiadtel, bapiadtel_x.
        CLEAR: bapiadtel, bapiadtel_x.
        update_flag = 'X'.
      ELSE.

        LOOP AT bapiadtel.

          IF bapiadtel-telephone IS NOT INITIAL AND bapiadtel-telephone NE ist_unbl-mob_number.
            REFRESH bapiadtel[].
            CLEAR bapiadtel.
            bapiadtel-telephone    = ist_unbl-mob_number.
            bapiadtel-r_3_user     = '3'.
*            MODIFY bapiadtel.
            bapiadtel_x-telephone  = 'X'.
            update_flag = 'X'.
            APPEND : bapiadtel.
          ENDIF.

          bapiadtel_x-r_3_user   = 'X'.
          bapiadtel_x-updateflag = 'U'.
          APPEND : bapiadtel_x.
          CLEAR: bapiadtel, bapiadtel_x.
        ENDLOOP.


      ENDIF.

      IF bapiadsmtp[] IS INITIAL.
        bapiadsmtp-e_mail      = ist_unbl-email.
        bapiadsmtp-email_srch  = ist_unbl-email.
        bapiadsmtp-valid_from  = sy-datum.
        bapiadsmtp-home_flag = 'X'.
*    bapiadsmtp-R_3_USER    = '3'.
        bapiadsmt_x-e_mail     = 'X'.
        bapiadsmt_x-email_srch = 'X'.
        bapiadsmt_x-valid_from = 'X'.
        bapiadsmt_x-home_flag  = 'X'.
        bapiadsmt_x-updateflag = 'I'.
        APPEND: bapiadsmtp, bapiadsmt_x.
        CLEAR: bapiadsmtp, bapiadsmt_x.
        update_flag = 'X'.
      ELSE.

        LOOP AT bapiadsmtp.
          IF bapiadsmtp-e_mail IS NOT INITIAL AND bapiadsmtp-e_mail NE ist_unbl-email.
            REFRESH bapiadsmtp[].
            CLEAR bapiadsmtp.
            bapiadsmtp-e_mail      = ist_unbl-email.
            bapiadsmtp-email_srch  = ist_unbl-email.
            bapiadsmtp-valid_from  = sy-datum.
            bapiadsmtp-home_flag = 'X'.
            bapiadsmt_x-email_srch = 'X'.
*       bapiadsmtp-R_3_USER    = '3'.
            MODIFY bapiadsmtp.
            update_flag = 'X'.
          ENDIF.
*       BAPIADSMT_X-E_MAIL     = 'X'.
*       bapiadsmt_x-R_3_USER   = 'X'.
          bapiadsmt_x-e_mail     = 'X'.
          bapiadsmt_x-valid_from = 'X'.
          bapiadsmt_x-home_flag  = 'X'.
          bapiadsmt_x-updateflag = 'U'.
        ENDLOOP.

      ENDIF.

      IF update_flag NE 'X'.

        REFRESH : bapiadtel,bapiadtel_x.
        CONTINUE.
      ENDIF.

      objtype = 'LFA1'.

      obj_id_ext = ' '.
      context = '0001'.

      DATA : addrno TYPE bapi4001_1-addr_no.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = IST_UNBL-LIFNR
*              IMPORTING
*                OUTPUT = IST_UNBL-LIFNR.
*
*            obj_id = IST_UNBL-LIFNR.

      CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
        EXPORTING
          obj_type       = objtype
          obj_id         = obj_id
*         OBJ_ID_EXT     = obj_id_ext
          context        = context
*         ACCEPT_ERROR   = ' '
*         SAVE_ADDRESS   = 'X'
*         IV_CHECK_ADDRESS            = 'X'
*         IV_TIME_DEPENDENT_COMM_DATA = ' '
        IMPORTING
          address_number = addrno
        TABLES
*         BAPIAD1VL      =
          bapiadtel      = bapiadtel
*         BAPIADFAX      =
*         BAPIADTTX      =
*         BAPIADTLX      =
*         BAPIADSMTP     = bapiadsmtp
*         BAPIADRML      =
*         BAPIADX400     =
*         BAPIADRFC      =
*         BAPIADPRT      =
*         BAPIADSSF      =
*         BAPIADURI      =
*         BAPIADPAG      =
*         BAPIAD_REM     =
*         BAPICOMREM     =
*         BAPIADUSE      =
*         BAPIAD1VL_X    =
          bapiadtel_x    = bapiadtel_x
*         BAPIADFAX_X    =
*         BAPIADTTX_X    =
*         BAPIADTLX_X    =
*         BAPIADSMT_X    = BAPIADSMT_X
*         BAPIADRML_X    =
*         BAPIADX40_X    =
*         BAPIADRFC_X    =
*         BAPIADPRT_X    =
*         BAPIADSSF_X    =
*         BAPIADURI_X    =
*         BAPIADPAG_X    =
*         BAPIAD_RE_X    =
*         BAPICOMRE_X    =
*         BAPIADUSE_X    =
          return         = return.


      IF return IS INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*                EXPORTING
*                  WAIT = 'X'.

      ENDIF.


      REFRESH: bapiadtel,bapiadtel_x.
      CLEAR: update_flag.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " UPDATE_MOBILE_EMAIL
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_ASSREJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_mail_assrej .
  IF  g_trans_mode = 'A'.

    IF zmm_vend_unblock-reqno IS NOT INITIAL.


      PERFORM send_mail_ir USING zmm_vend_unblock-reqno
                                 zmm_vend_unblock-ernam.
    ENDIF.
  ENDIF.
ENDFORM.                    " SEND_MAIL_ASSREJ
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS_ASSREJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sms_assrej USING p_unbreq
                    p_ername.

  DATA : l_phone TYPE pa9205-zphone.

  DATA : l_pernr  TYPE pa9205-pernr.
  DATA : l_mobileno(12),
         l_msg(255),
         l_url          TYPE string,
         l_result       TYPE string,
         l_result1(50).

  DATA: l_client_ref TYPE REF TO if_http_client.

  MOVE p_ername TO l_pernr.




  SELECT SINGLE zphone FROM pa9205 INTO l_phone
           WHERE pernr = l_pernr AND
                 subty = '01'    AND
                 endda GE sy-datum.  "#EC CI_NOORDER

  IF sy-subrc EQ 0 AND NOT l_phone IS INITIAL.

    CONCATENATE '91' l_phone+1(10) INTO  l_mobileno.

    CONCATENATE 'Your VMS unblock request No' p_unbreq 'has been reverted by the assigner .please check the correspondence in the request'
       INTO l_msg SEPARATED BY space.

    CONCATENATE l_msg '.'  INTO l_msg.





    CLEAR l_url.
    CONCATENATE text-331 l_mobileno text-332 l_msg text-334 INTO l_url.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = l_url
      IMPORTING
        client             = l_client_ref
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    CALL METHOD l_client_ref->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2.

    CALL METHOD l_client_ref->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    CLEAR l_result .

    l_result = l_client_ref->response->get_cdata( ).

    MOVE l_result TO l_result1.

    CONCATENATE text-335 l_result1+2 INTO l_result1.


  ENDIF.

ENDFORM.                    " SEND_SMS_ASSREJ
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_IR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_VEND_UNBLOCK_REQNO  text
*      -->P_ZMM_VEND_UNBLOCK_ERNAM  text
*----------------------------------------------------------------------*
FORM send_mail_ir  USING    p_reqno
                            p_ernam.


  DATA : wa_docdata TYPE sodocchgi1.

  DATA : ist_objcont TYPE solisti1  OCCURS 0  WITH HEADER LINE,
         ist_reclist TYPE somlreci1 OCCURS 0  WITH HEADER LINE.



  CONCATENATE text-336 p_reqno 'reverted'
             INTO wa_docdata-obj_descr SEPARATED BY space.


  wa_docdata-obj_name  = text-337.
  wa_docdata-obj_langu = sy-langu.



  CLEAR ist_objcont.
  CONCATENATE 'Your VMS unblock request No' p_reqno 'has been reverted by the assigner .Please check the correspondence in the request'
  INTO ist_objcont SEPARATED BY space.
  CONCATENATE  ist_objcont '.'  INTO ist_objcont.
  APPEND ist_objcont.


  ist_reclist-receiver =   p_ernam.


  ist_reclist-rec_type = 'B'.
  ist_reclist-express  = 'X'.

  APPEND ist_reclist.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = wa_docdata
      document_type              = 'RAW'
    TABLES
      object_content             = ist_objcont
      receivers                  = ist_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  IF sy-subrc EQ 0.
    MESSAGE i321(zmm) WITH 'Mail Sent to :'   p_ernam. "usnam.
  ELSE.
    MESSAGE i321(zmm) WITH 'Error in sending mail to :'  p_ernam.
  ENDIF.




ENDFORM.                    " SEND_MAIL_IR
*&---------------------------------------------------------------------*
*&      Form  SEARCH_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_request .
  CLEAR zfivmsbank-reqno .
  CALL SCREEN 152  STARTING AT  10 10
                    ENDING   AT  50 25 .

ENDFORM.                    " SEARCH_REQUEST
*&---------------------------------------------------------------------*
*&      Form  TC109_REQUEST_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tc109_request_search .
  DATA: l_tabix TYPE sy-tabix,
        l_len1  TYPE i.
  l_len1 = strlen( zfivmsbank-reqno ).

  WHILE l_len1 < 10.
    CONCATENATE '0'  zfivmsbank-reqno INTO zfivmsbank-reqno.
    l_len1 = strlen( zfivmsbank-reqno ).
  ENDWHILE.
  IF g_srch_flag = 'X'.

    IF zfivmsbank-reqno IS NOT INITIAL.
      READ TABLE g_tc109_itab INTO g_tc109_wa
          WITH KEY  reqno = zfivmsbank-reqno.
      IF sy-subrc = 0.
        l_tabix = sy-tabix.
        tc109-top_line = l_tabix.
        SET CURSOR 1 1.
        CLEAR g_srch_flag.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " TC109_REQUEST_SEARCH
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_USER_PAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_015  text
*      -->P_TEXT_018  text
*----------------------------------------------------------------------*
FORM confirm_user_pan  USING    p_title
                                p_question.
  CLEAR g_ans.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = p_title
      text_question         = p_question
      text_button_1         = 'Yes'
      text_button_2         = 'No'(004)
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = g_ans_pan.

ENDFORM.                    " CONFIRM_USER_PAN

*+SP015 : Start
*&---------------------------------------------------------------------*
*&      Form  FETCH_LIFNR
*&---------------------------------------------------------------------*
* To fetch vendor list from
*  1. DB table ZMM_DVENCRT for setting related partner Status in
*     Set Related Partner mode
*  2. DB table ZMM_VMS_TP_SET in Release Related Partner mode
*  3. DB table ZMM_VMS_TP_SET in Approve Related Partner mode
*----------------------------------------------------------------------*
*      -->P_EVENT  Event type i.e. Set/Release/Approve
*----------------------------------------------------------------------*
FORM fetch_lifnr  USING    p_event.

  DATA : BEGIN OF wa_zmm_hvencrt,
           bukrs TYPE zmm_hvencrt-bukrs,
           reqno TYPE zmm_dvencrt-reqno,
           lifnr TYPE zmm_dvencrt-lifnr,
           name1 TYPE zmm_dvencrt-name1,
         END OF wa_zmm_hvencrt.

  DATA : ist_zmm_hvencrt LIKE TABLE OF wa_zmm_hvencrt,
         ist_zmm_dvencrt LIKE TABLE OF wa_zmm_hvencrt,
         wa_zmm_dvencrt  LIKE wa_zmm_hvencrt.

  DATA : ist_zmm_vms_tp_set_t TYPE TABLE OF zmm_vms_tp_set,
         wa_zmm_vms_tp_set_t  TYPE  zmm_vms_tp_set.

  DATA : l_bukrs TYPE pa0001-bukrs,
         l_pernr TYPE pa0001-pernr.

  DATA : l_index TYPE sy-tabix.

*  IF  sy-uname CO '0123456789'.
  MOVE sy-uname TO l_pernr.
*  ENDIF.

  SELECT SINGLE bukrs FROM pa0001 INTO l_bukrs
    WHERE pernr EQ l_pernr  AND "sy-uname AND
          endda GE sy-datum.  "#EC CI_NOORDER

*  l_bukrs = 'DLI'.


  CASE p_event.

    WHEN 'SRP'.

      IF NOT l_bukrs IS INITIAL.

        SELECT bukrs reqno FROM zmm_hvencrt
           INTO CORRESPONDING FIELDS OF TABLE ist_zmm_hvencrt
              WHERE bukrs = l_bukrs AND
                    ktokk IN ('IMMF','IMMI','SVWF','SVWI').

        IF NOT ist_zmm_hvencrt[] IS INITIAL.

          SELECT lifnr name1 FROM zmm_dvencrt
             INTO CORRESPONDING FIELDS OF TABLE ist_zmm_dvencrt
                FOR ALL ENTRIES IN ist_zmm_hvencrt
                    WHERE reqno           = ist_zmm_hvencrt-reqno AND
                          rel_partner_flg = ''.

          IF NOT ist_zmm_dvencrt[] IS INITIAL.

            DELETE ist_zmm_dvencrt WHERE lifnr IS INITIAL.

            LOOP AT ist_zmm_dvencrt INTO wa_zmm_dvencrt.

              wa_zmm_dvencrt-bukrs = l_bukrs.

              MODIFY ist_zmm_dvencrt FROM wa_zmm_dvencrt INDEX sy-tabix
                         TRANSPORTING bukrs.

            ENDLOOP.

          ENDIF.

        ENDIF.

      ENDIF.

      IF NOT ist_zmm_dvencrt[] IS INITIAL.

        SELECT * FROM zmm_vms_tp_set INTO TABLE ist_zmm_vms_tp_set_t
           FOR ALL ENTRIES IN ist_zmm_dvencrt
               WHERE  bukrs = l_bukrs   AND
                      lifnr = ist_zmm_dvencrt-lifnr.

        LOOP AT ist_zmm_dvencrt INTO wa_zmm_dvencrt.

          CLEAR wa_zmm_vms_tp_set.

*Discard all vendors of which related partner status have already been set
          READ TABLE ist_zmm_vms_tp_set_t INTO wa_zmm_vms_tp_set_t
                       WITH KEY lifnr = wa_zmm_dvencrt-lifnr.
*Commented : Start
*          IF sy-subrc EQ 0.
*
*            MOVE-CORRESPONDING wa_zmm_vms_tp_set_t TO wa_zmm_vms_tp_set.
*
*            IF wa_zmm_vms_tp_set_t-rel_partner_flg = 'Y'.
*
*              wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*
*            ELSEIF wa_zmm_vms_tp_set_t-rel_partner_flg = 'N'.
*
*              CLEAR wa_zmm_vms_tp_set-rel_partner_flg.
*
*            ENDIF.
*
*            MOVE wa_zmm_dvencrt-name1 TO wa_zmm_vms_tp_set-name1.
*
*          ELSE.
*
*            MOVE-CORRESPONDING wa_zmm_dvencrt TO wa_zmm_vms_tp_set.
*
*          ENDIF.
*
*           APPEND wa_zmm_vms_tp_set TO ist_zmm_vms_tp_set.
*Commented : End

          IF sy-subrc NE 0.

            MOVE-CORRESPONDING wa_zmm_dvencrt TO wa_zmm_vms_tp_set.

            CONDENSE wa_zmm_vms_tp_set-lifnr.

            APPEND wa_zmm_vms_tp_set TO ist_zmm_vms_tp_set.

          ENDIF.

        ENDLOOP.

        DESCRIBE TABLE ist_zmm_vms_tp_set LINES vms_ctrl_tp-lines.

        CALL SCREEN 0750.

      ELSE.
*
      ENDIF.

    WHEN 'RRP'.

      IF NOT l_bukrs IS INITIAL.

        SELECT * FROM zmm_vms_tp_set
           INTO CORRESPONDING FIELDS OF TABLE ist_zmm_vms_tp_set
             WHERE bukrs         = l_bukrs AND
                   rp_flg_rel_by = ''.

        IF NOT ist_zmm_vms_tp_set[] IS INITIAL.

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            l_index = sy-tabix.

            SELECT SINGLE name1 FROM zmm_dvencrt
               INTO wa_zmm_vms_tp_set-name1
                   WHERE lifnr = wa_zmm_vms_tp_set-lifnr.  "#EC CI_NOORDER

*            IF wa_zmm_vms_tp_set-rel_partner_flg = 'Y'.
*
*              wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*
*            ELSEIF wa_zmm_vms_tp_set-rel_partner_flg = 'N'.
*
*              CLEAR wa_zmm_vms_tp_set-rel_partner_flg.
*
*            ENDIF.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                   INDEX l_index TRANSPORTING name1. "rel_partner_flg.

          ENDLOOP.

        ENDIF.

        DESCRIBE TABLE ist_zmm_vms_tp_set LINES vms_ctrl_tp-lines.

        CALL SCREEN 0750.

      ENDIF.

    WHEN 'ARPC'.

      IF NOT l_bukrs IS INITIAL.

        SELECT * FROM zmm_vms_tp_set
           INTO CORRESPONDING FIELDS OF TABLE ist_zmm_vms_tp_set
             WHERE bukrs          EQ l_bukrs AND
                   rp_flg_rel_by     NE ''      AND
                   rp_flg_aprv_c1_by EQ ''.

        IF NOT ist_zmm_vms_tp_set[] IS INITIAL.

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            l_index = sy-tabix.

            SELECT SINGLE name1 FROM zmm_dvencrt
               INTO wa_zmm_vms_tp_set-name1
                   WHERE lifnr = wa_zmm_vms_tp_set-lifnr.  "#EC CI_NOORDER

*            IF wa_zmm_vms_tp_set-rel_partner_flg = 'Y'.
*
*              wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*
*            ELSEIF wa_zmm_vms_tp_set-rel_partner_flg = 'N'.
*
*              CLEAR wa_zmm_vms_tp_set-rel_partner_flg.
*
*            ENDIF.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                   INDEX l_index TRANSPORTING name1." rel_partner_flg.

          ENDLOOP.

        ENDIF.

        DESCRIBE TABLE ist_zmm_vms_tp_set LINES vms_ctrl_tp-lines.

        CALL SCREEN 0750.

      ENDIF.

    WHEN 'ARP'.

      IF NOT l_bukrs IS INITIAL.

        SELECT * FROM zmm_vms_tp_set
           INTO CORRESPONDING FIELDS OF TABLE ist_zmm_vms_tp_set
             WHERE bukrs          EQ l_bukrs AND
                   rp_flg_aprv_c1_by  NE ''      AND
                   rp_flg_aprv_by     EQ ''.

        IF NOT ist_zmm_vms_tp_set[] IS INITIAL.

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            l_index = sy-tabix.

            SELECT SINGLE name1 FROM zmm_dvencrt
               INTO wa_zmm_vms_tp_set-name1
                   WHERE lifnr = wa_zmm_vms_tp_set-lifnr.  "#EC CI_NOORDER

*            IF wa_zmm_vms_tp_set-rel_partner_flg = 'Y'.
*
*              wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*
*            ELSEIF wa_zmm_vms_tp_set-rel_partner_flg = 'N'.
*
*              CLEAR wa_zmm_vms_tp_set-rel_partner_flg.
*
*            ENDIF.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                   INDEX l_index TRANSPORTING name1." rel_partner_flg.

          ENDLOOP.

        ENDIF.

        DESCRIBE TABLE ist_zmm_vms_tp_set LINES vms_ctrl_tp-lines.

        CALL SCREEN 0750.

      ENDIF.

  ENDCASE.

ENDFORM.                    " FETCH_LIFNR
*&---------------------------------------------------------------------*
*&      Form  SAVE_RP_DETAILS
*&---------------------------------------------------------------------*
* To commit related party status in db table ZMM_VMS_TP_SET
*----------------------------------------------------------------------*
*      -->P_EVENT  Event type i.e. Set/Release/Approve
*----------------------------------------------------------------------*
FORM save_rp_details USING p_event.

  DATA : ist_zmm_vms_tp_set_f TYPE TABLE OF zmm_vms_tp_set,
         wa_zmm_vms_tp_set_f  TYPE zmm_vms_tp_set.

  CASE p_event.

    WHEN 'SRP'.  "Set Related Partner

      LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set WHERE sel = 'X'.

        MOVE-CORRESPONDING wa_zmm_vms_tp_set TO wa_zmm_vms_tp_set_f.

*        IF wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'Y'. "Yes
*        ELSE.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'N'. "No
*        ENDIF.

        IF NOT wa_zmm_vms_tp_set-rel_partner_flg IS INITIAL.

          wa_zmm_vms_tp_set_f-rp_flg_set_by = sy-uname.
          wa_zmm_vms_tp_set_f-rp_flg_set_on = sy-datum.

          APPEND wa_zmm_vms_tp_set_f TO ist_zmm_vms_tp_set_f.

        ENDIF.

      ENDLOOP.

    WHEN 'RRP'.  "Release Related Partner

      LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set WHERE sel = 'X'.

        MOVE-CORRESPONDING wa_zmm_vms_tp_set TO wa_zmm_vms_tp_set_f.

*        IF wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'Y'. "Yes
*        ELSE.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'N'. "No
*        ENDIF.

        wa_zmm_vms_tp_set_f-rp_flg_rel_by = sy-uname.
        wa_zmm_vms_tp_set_f-rp_flg_rel_on = sy-datum.

        APPEND wa_zmm_vms_tp_set_f TO ist_zmm_vms_tp_set_f.

      ENDLOOP.

    WHEN 'ARPC'.  "Approved Related Partner(C1)

      LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set WHERE sel = 'X'.

        MOVE-CORRESPONDING wa_zmm_vms_tp_set TO wa_zmm_vms_tp_set_f.

*        IF wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'Y'. "Yes
*        ELSE.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'N'. "No
*        ENDIF.

        wa_zmm_vms_tp_set_f-rp_flg_aprv_c1_by = sy-uname.
        wa_zmm_vms_tp_set_f-rp_flg_aprv_c1_on = sy-datum.

        APPEND wa_zmm_vms_tp_set_f TO ist_zmm_vms_tp_set_f.

      ENDLOOP.

    WHEN 'ARP'.  "Approved Related Partner(L1)

      REFRESH : ist_upd_vnd_rp_dtl.
      CLEAR : wa_upd_vnd_rp_dtl.

      LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set WHERE sel = 'X'.

        MOVE-CORRESPONDING wa_zmm_vms_tp_set TO wa_zmm_vms_tp_set_f.

*        IF wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'Y'. "Yes
*        ELSE.
*          wa_zmm_vms_tp_set_f-rel_partner_flg = 'N'. "No
*        ENDIF.

        wa_zmm_vms_tp_set_f-rp_flg_aprv_by = sy-uname.
        wa_zmm_vms_tp_set_f-rp_flg_aprv_on = sy-datum.

        APPEND wa_zmm_vms_tp_set_f TO ist_zmm_vms_tp_set_f.

*For updating related partner flag in DB table ZMM_DVENCRT
        MOVE-CORRESPONDING wa_zmm_vms_tp_set_f TO wa_upd_vnd_rp_dtl.
        APPEND wa_upd_vnd_rp_dtl TO ist_upd_vnd_rp_dtl.

      ENDLOOP.

  ENDCASE.

  IF NOT ist_zmm_vms_tp_set_f[] IS INITIAL.

    MODIFY zmm_vms_tp_set FROM TABLE ist_zmm_vms_tp_set_f.

    IF sy-subrc EQ 0.

      PERFORM upd_rel_partner_vms_dtl USING p_event.

      COMMIT WORK.

      MESSAGE s174(zmm_oth).

      CLEAR save_ok.

      CLEAR ok_code.

      LEAVE TO SCREEN 0700.

    ELSE.

      ROLLBACK WORK.
      MESSAGE e175(zmm_oth).

    ENDIF.

  ELSE.

    MESSAGE i176(zmm_oth).

    CLEAR save_ok.
    CLEAR ok_code.

  ENDIF.

ENDFORM.                    " SAVE_RP_DETAILS

*&---------------------------------------------------------------------*
*&      Form  UPD_REL_PARTNER_VMS_DTL
*&---------------------------------------------------------------------*
* When Related Partner status get approved, Update REL_PARTNER_FLG
* field of DB table ZMM_DVENCRT
*----------------------------------------------------------------------*
*      -->P_EVENT  Event i.e. Approve Related Partner(ARP)
*----------------------------------------------------------------------*
FORM upd_rel_partner_vms_dtl  USING    p_event.

  DATA : ist_zmm_dvencrt_t TYPE TABLE OF zmm_dvencrt,
         wa_zmm_dvencrt_t  TYPE zmm_dvencrt.

  DATA : l_index TYPE sy-tabix.

  IF p_event = 'ARP'.

    IF NOT ist_upd_vnd_rp_dtl[] IS INITIAL.

      SELECT * FROM zmm_dvencrt INTO TABLE ist_zmm_dvencrt_t
         FOR ALL ENTRIES IN ist_upd_vnd_rp_dtl
              WHERE lifnr = ist_upd_vnd_rp_dtl-lifnr.

      IF NOT ist_zmm_dvencrt_t[] IS INITIAL.

        LOOP AT ist_zmm_dvencrt_t INTO wa_zmm_dvencrt_t.

          l_index = sy-tabix.

          CLEAR wa_upd_vnd_rp_dtl.

          READ TABLE ist_upd_vnd_rp_dtl INTO wa_upd_vnd_rp_dtl
                              WITH KEY lifnr = wa_zmm_dvencrt_t-lifnr.
          IF sy-subrc EQ 0.

            wa_zmm_dvencrt_t-rel_partner_flg =
                                 wa_upd_vnd_rp_dtl-rel_partner_flg.

            MODIFY ist_zmm_dvencrt_t FROM wa_zmm_dvencrt_t
                       INDEX l_index TRANSPORTING rel_partner_flg.

          ENDIF.

        ENDLOOP.

        UPDATE zmm_dvencrt FROM TABLE ist_zmm_dvencrt_t.

        IF sy-subrc NE 0.

          ROLLBACK WORK.
          MESSAGE e175(zmm_oth).

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " UPD_REL_PARTNER_VMS_DTL

*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L1
*&---------------------------------------------------------------------*
* To check L1 authorization for Related Partner Approval
*----------------------------------------------------------------------*
*      -->P_EVENT  Event type i.e. Approval by C1/L1
*----------------------------------------------------------------------*
FORM auth_check_l1 USING p_event.

  IF p_event = 'ARPC'.         "Approval by Incharge Finance

    AUTHORITY-CHECK OBJECT 'M_BANF_FRG'
             ID 'FRGCD' FIELD 'C1'.

    IF sy-subrc NE 0.

      MESSAGE e177(zmm_oth).

    ENDIF.

  ELSEIF p_event = 'ARP'.      "Approval by L1

    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'FRGCO' FIELD 'L1'.

    IF sy-subrc NE 0.

      MESSAGE e177(zmm_oth).

    ENDIF.

  ENDIF.

ENDFORM.                    " AUTH_CHECK_L1

*&---------------------------------------------------------------------*
*&      Form  GET_RP_VENDOR
*&---------------------------------------------------------------------*
* To search a vendor from Vendor list : Screen 0750
*----------------------------------------------------------------------*
FORM get_rp_vendor .

  DATA : ist_sval LIKE sval OCCURS 0 WITH HEADER LINE.

  DATA : l_lifnr TYPE zmm_vms_tp_set-lifnr.

  MOVE : 'ZMM_VMS_TP_SET' TO ist_sval-tabname,
         'LIFNR'          TO ist_sval-fieldname,
         'X'              TO ist_sval-field_obl.

  ist_sval-fieldtext = text-338.
  APPEND ist_sval.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = text-339
    TABLES
      fields          = ist_sval
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE ist_sval INDEX 1.
  l_lifnr = ist_sval-value.

  READ TABLE ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set
                WITH KEY lifnr = l_lifnr.

  IF sy-subrc EQ 0.

    vms_ctrl_tp-current_line = sy-tabix.
    vms_ctrl_tp-top_line = sy-tabix.

    SET CURSOR FIELD 'WA_ZMM_VMS_TP_SET_TC-LIFNR'
                      LINE vms_ctrl_tp-current_line.

  ENDIF.

ENDFORM.                    " GET_RP_VENDOR

*&---------------------------------------------------------------------*
*&      Form  DISP_RP_PROCESS_GUIDE
*&---------------------------------------------------------------------*
* To display process guide for Related Partner
*----------------------------------------------------------------------*
FORM disp_rp_process_guide .

  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
  DATA : wa_att_files LIKE swotobjid.

  wa_att_files-logsys  = 'RPHELP'.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

  REFRESH ist_exclude_tab[].
  MOVE 'ENTR' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CHNG' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CREA' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'DELE' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'IMPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'EXPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'OLNK' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'PRIN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'COPY' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'HGEN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'REFL' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'MOVE' TO ist_exclude_tab. APPEND ist_exclude_tab.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = wa_att_files
    TABLES
      func_exclude       = ist_exclude_tab.

ENDFORM.                    " DISP_RP_PROCESS_GUIDE
*+sp015 : End
*&---------------------------------------------------------------------*
*&      Form  ATTACH_FILES_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_files_change .

  DATA l_att_data TYPE sodocchgi1.

  CLEAR: g_att_files_wa_ch.
  REFRESH: g_att_files_ch.

  g_att_files_wa_ch-logsys  = '01'.
  g_att_files_wa_ch-objtype = 'VMS_CH'.
  g_att_files_wa_ch-objkey  = zmm_hvencrt-reqno.

  APPEND g_att_files_wa_ch TO g_att_files_ch.

  IF zmm_hvencrt-reqno IS NOT INITIAL.
    CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
      EXPORTING
        attachment_data     = l_att_data
        attachment_type     = 'DOC'
      TABLES
        application_objects = g_att_files_ch.
  ENDIF.


ENDFORM.                    " ATTACH_FILES_CHANGE
*&---------------------------------------------------------------------*
*&      Form  LIST_FILES_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files_change .
  CLEAR g_att_files_wa_ch.
  REFRESH:g_att_files_ch.

  g_att_files_wa_ch-objtype = 'VMS_CH'.


  g_att_files_wa_ch-logsys  = '01'.
  g_att_files_wa_ch-objkey  = zmm_hvencrt-reqno.


  APPEND    g_att_files_wa_ch TO g_att_files_ch.

  REFRESH exclude_tab_ch[].

  MOVE 'ENTR' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'CHNG' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'CREA' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'DELE' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'IMPO' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'EXPO' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'OLNK' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'PRIN' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'COPY' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'HGEN' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'REFL' TO exclude_tab_ch. APPEND exclude_tab_ch.
  MOVE 'MOVE' TO exclude_tab_ch. APPEND exclude_tab_ch.


  IF zmm_hvencrt-reqno IS NOT INITIAL.
    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa_ch "g_att_files_wa
        function           = ' '
      TABLES
        func_exclude       = exclude_tab_ch.
  ENDIF.



ENDFORM.                    " LIST_FILES_CHANGE
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_PAN_ATTACH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_062  text
*      -->P_TEXT_063  text
*----------------------------------------------------------------------*
FORM confirm_pan_attach  ."USING    P_TITLE
  "  P_QUESTION.
  CLEAR g_ans.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Attach Scan copy of the PAN number'
      text_question         = 'You confirm that PAN number is correct.'
                              & 'Please attach scan copy of the PAN in change mode. Without Scan copy, request will not be assigned.'
                              & 'Do you want to confirm?'
      text_button_1         = 'Yes'(003)
      text_button_2         = 'No'(004)
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = g_ans.
ENDFORM.                    " CONFIRM_PAN_ATTACH
*&---------------------------------------------------------------------*
*&      Form  CHECK_ATTACHMENT_PAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_attachment_pan .

  REFRESH:itab_pan_details[].

  SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE itab_pan_details WHERE
    reqno = zmm_hvencrt-reqno.

  DELETE itab_pan_details[] WHERE j_1ipanno IS INITIAL.



  IF itab_pan_details[] IS NOT INITIAL.

    SELECT instid_a typeid_a
     FROM srgbtbrel INTO CORRESPONDING FIELDS OF TABLE itab_attach_check
     WHERE typeid_a = 'VMS_CH'
     AND instid_a =  zmm_hvencrt-reqno.

    IF sy-subrc = 0.
    ELSE.
      PERFORM release_attach_pan.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_ATTACHMENT_PAN
*&---------------------------------------------------------------------*
*&      Form  RELEASE_ATTACH_PAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_attach_pan .
  MESSAGE e181(zmm_oth).
ENDFORM.                    " RELEASE_ATTACH_PAN
*&---------------------------------------------------------------------*
*&      Form  LIST_BOX_INDUSTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_box_industry .

ENDFORM.                    " LIST_BOX_INDUSTRY
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REPLICATE_VENDORS_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM replicate_vendors_srm .

  WAIT UP TO 50 SECONDS.

  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
    WHERE  appl = 'SRM'.

  """"""calling srm
  IF NOT l_logsys  IS INITIAL.
    CLEAR: v_ptner.
    v_ptner =  zmm_hvencrt-srmid .
    CALL FUNCTION 'ZSRM_VENDOR_ECC_REPLICATE' DESTINATION l_logsys
      EXPORTING
        v_lifnr         = wa_vend-vend-lifnr
        v_fname         = wa_vend-vend-name_first
        v_lname         = wa_vend-vend-name_last
        v_telno         = wa_vend-vend-mob_number
        v_email         = wa_vend-vend-email
        vcountry        = wa_vend-vend-land1
        v_ptner         = v_ptner
      TABLES
        itab_return_srm = itab_return_srm.
  ENDIF.
ENDFORM.                    " REPLICATE_VENDORS_SRM
*&---------------------------------------------------------------------*
*&      Form  REPLICATE_VENDORS_SRM_CMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM replicate_vendors_srm_cmm .
* wait up to 50 seconds.

*   wait up to 90 seconds.


  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
    WHERE  appl = 'SRM'.

  """"""calling srm

*BREAK-POINT.
  IF NOT l_logsys  IS INITIAL.


    CALL FUNCTION 'ZSRM_VENDOR_VENMAP_CHECK'
      DESTINATION l_logsys
      EXPORTING
        p_vendor = ist_lfa1-lifnr
      IMPORTING
        v_return = v_return.

    IF v_return = 'Y'.
      MESSAGE s196(zmm_oth).
      LEAVE TO SCREEN 200.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ist_lfa1-lifnr
        IMPORTING
          output = ist_lfa1-lifnr.

      CLEAR: v_ptner.
      v_ptner =  zmm_hvencrt-srmid .


      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = v_ptner
        IMPORTING
          output = v_ptner.
      CLEAR:wa_vend .
      READ TABLE ist_vend INTO wa_vend INDEX 1.

      "comment by lipsy
*  if ist_lfa1-PSTLZ is not initial.
      "ecomm by lipsy

      "add by lipsy
      CLEAR: v_lifnr_extend.
      v_lifnr_extend = ist_lfa1-lifnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = v_lifnr_extend
        IMPORTING
          output = v_lifnr_extend.

      SELECT SINGLE * FROM lfa1
        INTO CORRESPONDING FIELDS OF wa_postal
        WHERE
        lifnr =   v_lifnr_extend.

      IF wa_postal-pstlz IS INITIAL.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFA1 BP-managed; postal code via VMD_EI_API address (FORM zz_s4_lfa1_pstlz).
*        UPDATE lfa1 SET pstlz =  wa_vend-vend-pstlz
*               WHERE lifnr =  wa_postal-lifnr.
        PERFORM zz_s4_lfa1_pstlz USING wa_postal-lifnr wa_vend-vend-pstlz.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      ENDIF.

      SELECT SINGLE * FROM lfa1
        INTO CORRESPONDING FIELDS OF wa_postal1
        WHERE
        lifnr =   v_lifnr_extend.


      IF wa_postal1-pstlz IS NOT INITIAL.


        "eadd by lipsy
      ELSE.
        MESSAGE s193(zmm_oth).
        LEAVE TO SCREEN 200.
      ENDIF.

      """"""
      "comm by lipsy
*clear: v_LIFNR_extend.
*  v_LIFNR_extend = ist_lfa1-LIFNR.
*
*      call function 'CONVERSION_EXIT_ALPHA_INPUT'
*        exporting
*          input  = v_LIFNR_extend
*        importing
*          output = v_LIFNR_extend.

      "ec by lipsy

      REFRESH:lt_lfm_extend[].
      SELECT *  INTO CORRESPONDING FIELDS OF TABLE  lt_lfm_extend FROM lfm1 WHERE lifnr = v_lifnr_extend.  "#EC CI_NOORDER

      CLEAR: wa_lfm_extend.
      READ TABLE lt_lfm_extend INTO wa_lfm_extend WITH KEY ekorg = 'PMAT'.
      IF sy-subrc = 0.

      ELSE.
        READ TABLE lt_lfm_extend INTO wa_lfm_extend WITH KEY ekorg = 'PSRV'.
        IF sy-subrc = 0.


        ELSE.
          MESSAGE s194(zmm_oth).
          LEAVE TO SCREEN 200.

        ENDIF.
      ENDIF.



      CLEAR:lv_blocked.
      CALL FUNCTION 'ZSRM_CHECK_VENDOR_BLOCK'
        EXPORTING
          vendor = ist_lfa1-lifnr
        IMPORTING
          result = lv_blocked.

      IF lv_blocked = 'N'.


        MESSAGE s195(zmm_oth).
        LEAVE TO SCREEN 200.

      ELSE.

        CALL FUNCTION 'ZSRM_VENDOR_ECC_REPLICATE_NW' DESTINATION l_logsys
          EXPORTING
            v_lifnr         = ist_lfa1-lifnr
            v_fname         = wa_vend-vend-name_first
            v_lname         = wa_vend-vend-name_last
            v_telno         = wa_vend-vend-mob_number
            v_email         = wa_vend-vend-email
            vcountry        = wa_vend-vend-land1
            v_ptner         = v_ptner
          TABLES
            itab_return_srm = itab_return_srm.


        CLEAR:count_srm_replicate.



        IF itab_return_srm[] IS NOT INITIAL.
          LOOP AT itab_return_srm INTO wa_return_srm.
            IF wa_return_srm-status = 'RP'.

              UPDATE zmm_hvencrt SET reqcl = 'RP'
                    WHERE reqno = zmm_hvencrt-reqno.

              UPDATE zmm_dvencrt SET lifnr = ist_lfa1-lifnr
                      WHERE reqno = zmm_hvencrt-reqno.

              CLEAR: wa_lfa1_compare,wa_adr6_compare.


              SELECT  SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF wa_lfa1_compare
              WHERE lifnr = ist_lfa1-lifnr.

              SELECT  SINGLE * FROM adr6 INTO CORRESPONDING FIELDS OF wa_adr6_compare
              WHERE addrnumber = wa_lfa1_compare-adrnr.  "#EC CI_NOORDER

              IF wa_adr6_compare-smtp_addr IS INITIAL.

*    if v_exist_email is not initial.
                CLEAR: v_lifnr_update.
                v_lifnr_update =  ist_lfa1-lifnr.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = v_lifnr_update
                  IMPORTING
                    output = v_lifnr_update.

                obj_id_new =  v_lifnr_update.
                v_objty_new = 'LFA1'.
*v_objid = p_kunnr.

                CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
                  EXPORTING
                    obj_type       = v_objty_new
                    obj_id         = obj_id_new
                    context        = v_contx_new
                  IMPORTING
                    address_number = v_addnr_new
                  TABLES
                    bapiadsmtp     = bapiadsmtp_new
*                   bapiadtel      = bapiadtel
                    return         = return.


                IF bapiadsmtp_new[] IS INITIAL.
                  bapiadsmtp_new-e_mail      = wa_vend-vend-email.
                  bapiadsmtp_new-email_srch  = wa_vend-vend-email.
                  bapiadsmtp_new-valid_from  = sy-datum.
                  bapiadsmtp_new-home_flag = 'X'.
*    bapiadsmtp-R_3_USER    = '3'.
                  bapiadsmt_x_new-e_mail     = 'X'.
                  bapiadsmt_x_new-email_srch = 'X'.
                  bapiadsmt_x_new-valid_from = 'X'.
                  bapiadsmt_x_new-home_flag  = 'X'.
                  bapiadsmt_x_new-updateflag = 'I'.
                  APPEND: bapiadsmtp_new, bapiadsmt_x_new.
                  CLEAR: bapiadsmtp_new, bapiadsmt_x_new.

                  objtype_new = 'LFA1'.

*      obj_id_ext = ' '.
                  context_new = '0001'.

*      data : addrno type bapi4001_1-addr_no.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = IST_UNBL-LIFNR
*              IMPORTING
*                OUTPUT = IST_UNBL-LIFNR.
*
*            obj_id = IST_UNBL-LIFNR.

                  CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
                    EXPORTING
                      obj_type       = objtype_new
                      obj_id         = obj_id_new
*                     OBJ_ID_EXT     = obj_id_ext
                      context        = context_new
*                     ACCEPT_ERROR   = ' '
*                     SAVE_ADDRESS   = 'X'
*                     IV_CHECK_ADDRESS            = 'X'
*                     IV_TIME_DEPENDENT_COMM_DATA = ' '
                    IMPORTING
                      address_number = addrno
                    TABLES
*                     BAPIAD1VL      =
*                     BAPIADTEL      = BAPIADTEL
*                     BAPIADFAX      =
*                     BAPIADTTX      =
*                     BAPIADTLX      =
                      bapiadsmtp     = bapiadsmtp_new
*                     BAPIADRML      =
*                     BAPIADX400     =
*                     BAPIADRFC      =
*                     BAPIADPRT      =
*                     BAPIADSSF      =
*                     BAPIADURI      =
*                     BAPIADPAG      =
*                     BAPIAD_REM     =
*                     BAPICOMREM     =
*                     BAPIADUSE      =
*                     BAPIAD1VL_X    =
*                     BAPIADTEL_X    = BAPIADTEL_X
*                     BAPIADFAX_X    =
*                     BAPIADTTX_X    =
*                     BAPIADTLX_X    =
                      bapiadsmt_x    = bapiadsmt_x_new
*                     BAPIADRML_X    =
*                     BAPIADX40_X    =
*                     BAPIADRFC_X    =
*                     BAPIADPRT_X    =
*                     BAPIADSSF_X    =
*                     BAPIADURI_X    =
*                     BAPIADPAG_X    =
*                     BAPIAD_RE_X    =
*                     BAPICOMRE_X    =
*                     BAPIADUSE_X    =
                      return         = return_new.


                  IF return_new IS INITIAL.

                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
**                EXPORTING
**                  WAIT = 'X'.

                  ENDIF.
                  REFRESH:bapiadsmtp_new,bapiadsmt_x_new.

*endif.

                ENDIF.
*     update ADR6 set SMTP_ADDR = wa_vend-vend-email
*       WHERE ADDRNUMBER = WA_LFA1_COMPARE-ADRNR..

              ENDIF.
              """""""""""""""""""""""""""""""""""""""""""""
              "update mobile
              CLEAR:wa_adrc_comparetel.
              SELECT  SINGLE * FROM adrc INTO CORRESPONDING FIELDS OF wa_adrc_comparetel
              WHERE addrnumber = wa_lfa1_compare-adrnr.  "#EC CI_NOORDER
              IF wa_adrc_comparetel-tel_number IS INITIAL.
                CLEAR: v_lifnr_update,obj_id_new,v_objty_new,v_addnr_new.
                v_lifnr_update =  ist_lfa1-lifnr.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = v_lifnr_update
                  IMPORTING
                    output = v_lifnr_update.
                obj_id_new =  v_lifnr_update.
                v_objty_new = 'LFA1'.


                CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
                  EXPORTING
                    obj_type       = v_objty_new
                    obj_id         = obj_id_new
                    context        = v_contx_new
                  IMPORTING
                    address_number = v_addnr_new
                  TABLES
*                   bapiadsmtp     = bapiadsmtp_new
                    bapiadtel      = bapiadtel_new
                    return         = return.


                IF bapiadtel_new[] IS INITIAL.
                  bapiadtel_new-telephone    = wa_vend-vend-mob_number.
                  bapiadtel_new-r_3_user     = '3'.
                  bapiadtel_x_new-telephone  = 'X'.
                  bapiadtel_x_new-r_3_user   = 'X'.
                  bapiadtel_x_new-updateflag = 'I'.
                  APPEND: bapiadtel_new, bapiadtel_x_new.
                  CLEAR: bapiadtel_new, bapiadtel_x_new.


                  objtype_new = 'LFA1'.
                  context_new = '0001'.




*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = IST_UNBL-LIFNR
*              IMPORTING
*                OUTPUT = IST_UNBL-LIFNR.
*
*            obj_id = IST_UNBL-LIFNR.
                  CLEAR:addrno,return_new.
                  CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
                    EXPORTING
                      obj_type       = objtype_new
                      obj_id         = obj_id_new
*                     OBJ_ID_EXT     = obj_id_ext
                      context        = context_new
*                     ACCEPT_ERROR   = ' '
*                     SAVE_ADDRESS   = 'X'
*                     IV_CHECK_ADDRESS            = 'X'
*                     IV_TIME_DEPENDENT_COMM_DATA = ' '
                    IMPORTING
                      address_number = addrno
                    TABLES
*                     BAPIAD1VL      =
                      bapiadtel      = bapiadtel_new
*                     BAPIADFAX      =
*                     BAPIADTTX      =
*                     BAPIADTLX      =
*                     bapiadsmtp     = bapiadsmtp_new
*                     BAPIADRML      =
*                     BAPIADX400     =
*                     BAPIADRFC      =
*                     BAPIADPRT      =
*                     BAPIADSSF      =
*                     BAPIADURI      =
*                     BAPIADPAG      =
*                     BAPIAD_REM     =
*                     BAPICOMREM     =
*                     BAPIADUSE      =
*                     BAPIAD1VL_X    =
                      bapiadtel_x    = bapiadtel_x_new
*                     BAPIADFAX_X    =
*                     BAPIADTTX_X    =
*                     BAPIADTLX_X    =
*                     bapiadsmt_x    = bapiadsmt_x_new
*                     BAPIADRML_X    =
*                     BAPIADX40_X    =
*                     BAPIADRFC_X    =
*                     BAPIADPRT_X    =
*                     BAPIADSSF_X    =
*                     BAPIADURI_X    =
*                     BAPIADPAG_X    =
*                     BAPIAD_RE_X    =
*                     BAPICOMRE_X    =
*                     BAPIADUSE_X    =
                      return         = return_new.


                  IF return_new IS INITIAL.

                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
**                EXPORTING
**                  WAIT = 'X'.

                  ENDIF.
                  REFRESH: bapiadtel_new,bapiadtel_x_new.
                ENDIF.
              ENDIF.
              """"""""""""""""""""""""""""""""""""""""""""""""""








              MESSAGE s190(zmm_oth).
              LEAVE TO SCREEN 100.


            ENDIF.
          ENDLOOP.

        ELSE.

          MESSAGE s191(zmm_oth).
          LEAVE TO SCREEN 100.


        ENDIF.


      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    " REPLICATE_VENDORS_SRM_CMM
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_MV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_mail_mv .
  DATA: receivers    LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
        mail_content LIKE solisti1 OCCURS 0 WITH HEADER LINE,
        mail_data    LIKE sodocchgi1.

  CLEAR: mail_data, mail_content, receivers.
  REFRESH: mail_content, receivers.
  mail_data-obj_name = 'ONGC E-Tender User Id'.
  MOVE 'ONGC E-Tender User Id' TO mail_data-obj_descr.
  mail_data-obj_langu = sy-langu.


  LOOP AT ist_linetab.

    IF sy-tabix NE 1.

      MOVE ist_linetab-tdline TO mail_content-line.

      APPEND mail_content.

      CLEAR mail_content-line.
    ENDIF.
  ENDLOOP.
*  clear MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  move TEXT-v06 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*
*  clear MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  move TEXT-v07 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*
*  move TEXT-v08 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  move TEXT-v09 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*
*  clear MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  concatenate TEXT-v10 V_USER into MAIL_CONTENT-LINE
*        SEPARATED BY SPACE.
*  APPEND MAIL_CONTENT.
*
*  CONCATENATE TEXT-v11 V_PASSWD
*              INTO MAIL_CONTENT-LINE
*        SEPARATED BY SPACE.
*  APPEND MAIL_CONTENT.
*  MOVE TEXT-v14 TO MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*
*  clear MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  move TEXT-v12 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.

*  case sy-mandt.
*
*    when '200'.
*      move TEXT-v17 to MAIL_CONTENT-LINE.
*
*    when '400'.
*      move TEXT-v18 to MAIL_CONTENT-LINE.
*
*    when '500'.
*      move TEXT-v13 to MAIL_CONTENT-LINE.
*
*  endcase.
*
*  APPEND MAIL_CONTENT.
*
*  clear MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  move TEXT-v15 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.
*  move TEXT-v16 to MAIL_CONTENT-LINE.
*  APPEND MAIL_CONTENT.

  READ TABLE ist_vend INTO wa_vend_mail INDEX 1.


  receivers-receiver = wa_vend_mail-vend-email.
  receivers-rec_type = 'U'.
  receivers-com_type = 'INT'.
  APPEND receivers.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = mail_data
    TABLES
      object_content             = mail_content
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  COMMIT WORK.



*  WRITE:/.
*  write:/ 'Mail sent to Vendor email id: '.
*  condense v_email.
*  zemail = v_email.
*  condense zemail.
ENDFORM.                    " SEND_MAIL_MV
*&---------------------------------------------------------------------*
*&      Form  CHECK_BANKL_BANKN1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bankl_bankn1 .

  LOOP AT g_tc321_itab INTO g_tc321_wa .
* Begin of <> on 17042012
    SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
    WHERE bankl = g_tc321_wa-bankl_new AND bankn = g_tc321_wa-bankn_new.
    IF sy-subrc = 0.
      CLEAR : l_text_1, l_text1_1 ,l_text2_1 , l_text3_1.
      SORT ist_zfivmsbank_bankl DESCENDING BY bankl bankn.
      READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
      SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
      g_tc321_wa-zflag = 'X'.
      MODIFY g_tc321_itab FROM g_tc321_wa.
      SHIFT g_tc321_wa-lifnr LEFT DELETING LEADING '0'.
      CONCATENATE 'Combination of Bank Account & IFSC Code requested for Vendor:-'g_tc321_wa-lifnr  INTO l_text1_1.
      CONCATENATE 'Already exists in Vendor Master :-' wa_zfivmsbank_bankl-lifnr INTO l_text2_1.
      CONCATENATE 'Do You Want to' ' Create New Request?' INTO l_text3_1.
      PERFORM popup_info USING l_text_1 l_text1_1 l_text2_1 l_text3_1.

    ELSE..
* End of <> on 17042012
      SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
      WHERE bankl_new = g_tc321_wa-bankl_new AND bankn_new = g_tc321_wa-bankn_new.

      IF sy-subrc = 0.
        CLEAR : l_text_1, l_text1_1 ,l_text2_1 , l_text3_1.
        SORT ist_zfivmsbank_bankl DESCENDING BY vmc_apdate vmc_aptime. " 281211 cdate cputm.
        READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
        SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
* Begin of <RD1K979928> on 02042012
        g_tc321_wa-zflag = 'X'.
        MODIFY g_tc321_itab FROM g_tc321_wa.
* End of <RD1K979928> on 02042012
* Begin of <> on 25012012
        SHIFT g_tc321_wa-lifnr LEFT DELETING LEADING '0'.
        CONCATENATE 'With the same Combination of Bank Account' '& IFSC Code requested for'   INTO l_text_1.
        CONCATENATE 'Vendor:-'g_tc321_wa-lifnr ' , another request for updation of Vendor :-' wa_zfivmsbank_bankl-lifnr   INTO l_text1_1.
        CONCATENATE 'is' ' in process with status-' wa_zfivmsbank_bankl-status INTO l_text2_1.
        CONCATENATE 'Kindly check in the Report tab using Bank Key' '/Bank Account?' INTO l_text3_1.

*        concatenate 'Request with the same bank details exists for the Vendor-' wa_zfivmsbank_bankl-lifnr into l_text.
*        concatenate ' of CCode-' g_ccode  into l_text1.
*        concatenate 'Kindly check in the Report tab using Bank Key' '/Bank Account.' into l_text2.
*     concatenate 'Request with the same bank details exists for the Vendor' wa_zfivmsbank_bankl-lifnr 'of CCode' g_ccode into l_text.

        PERFORM popup_info USING l_text_1 l_text1_1 l_text2_1 l_text3_1.
* End of <> on 25012012
*     message i426(zfi) with wa_zfivmsbank_bankl-lifnr g_ccode.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BDC_XK01_OVC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bdc_xk01_ovc .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BDC_XK01_OVC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_att.
  DATA: ls_object TYPE sibflporb,
        ls_logsys TYPE logsys.
  DATA: lt_links    TYPE obl_t_link.
  CONSTANTS: ls_relation TYPE oblreltype  VALUE 'ATTA',
             ls_catid_bo LIKE ls_object-catid VALUE 'BO'.

  CLEAR: g_att_files_wa_ch.
  REFRESH: g_att_files_ch.

  g_att_files_wa_ch-logsys = '01'.
  g_att_files_wa_ch-objtype = 'VMS_CH'.
  g_att_files_wa_ch-objkey = zmm_hvencrt-reqno..

  MOVE: g_att_files_wa_ch-objkey  TO ls_object-instid,
        g_att_files_wa_ch-objtype TO ls_object-typeid,
        g_att_files_wa_ch-logsys  TO ls_logsys,
        ls_catid_bo        TO ls_object-catid.

  TRY.

      CALL METHOD cl_binary_relation=>read_links_of_binrel
        EXPORTING
          is_object   = ls_object
          ip_logsys   = ls_logsys
          ip_relation = ls_relation
*         ip_role     = ls_role
*         ip_propnam  =
*         ip_no_buffer = SPACE
        IMPORTING
          et_links    = lt_links
*         et_roles    =
        .
    CATCH cx_obl_parameter_error .
    CATCH cx_obl_internal_error .
    CATCH cx_obl_model_error .
  ENDTRY.

  IF lt_links[] IS INITIAL.
    MESSAGE 'Attachment Missing' TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.

*-- S/4 helper FORMs (vendor master via VMD_EI_API) - SAP_ABAP 16.06.2026 --------------------
FORM zz_s4_lfb1_zwels USING p_lifnr p_zwels.
  DATA: ls_vm TYPE vmds_ei_main, ls_ve TYPE vmds_ei_extern, ls_co TYPE vmds_ei_company,
        ls_vd TYPE vmds_ei_main, lt_bu TYPE TABLE OF bukrs, lv_bu TYPE bukrs.
  CLEAR: ls_vm, ls_ve, ls_vd. REFRESH lt_bu.
  ls_ve-header-object_instance-lifnr = p_lifnr.
  ls_ve-header-object_task = 'U'.
  SELECT bukrs FROM lfb1 INTO TABLE @lt_bu WHERE lifnr = @p_lifnr ORDER BY PRIMARY KEY.
  LOOP AT lt_bu INTO lv_bu.
    CLEAR ls_co. ls_co-task = 'U'. ls_co-data_key-bukrs = lv_bu.
    ls_co-data-zwels = p_zwels. ls_co-datax-zwels = abap_true.
    APPEND ls_co TO ls_ve-company_data-company.
  ENDLOOP.
  CHECK ls_ve-company_data-company IS NOT INITIAL.
  APPEND ls_ve TO ls_vm-vendors.
  CALL METHOD vmd_ei_api=>maintain_bapi EXPORTING iv_test_run = space iv_collect_messages = 'X'
       is_master_data = ls_vm IMPORTING es_master_data_defective = ls_vd.
  IF ls_vd-vendors IS INITIAL. COMMIT WORK. ELSE. ROLLBACK WORK. ENDIF.
ENDFORM.
FORM zz_s4_lfa1_cen USING p_lifnr p_field p_value.
  DATA: ls_vm TYPE vmds_ei_main, ls_ve TYPE vmds_ei_extern, ls_vd TYPE vmds_ei_main.
  FIELD-SYMBOLS: <fd> TYPE any, <fx> TYPE any.
  CLEAR: ls_vm, ls_ve, ls_vd.
  ls_ve-header-object_instance-lifnr = p_lifnr.
  ls_ve-header-object_task = 'U'.
  ASSIGN COMPONENT p_field OF STRUCTURE ls_ve-central_data-central-data TO <fd>.
  IF sy-subrc = 0. <fd> = p_value. ENDIF.
  ASSIGN COMPONENT p_field OF STRUCTURE ls_ve-central_data-central-datax TO <fx>.
  IF sy-subrc = 0. <fx> = 'X'. ENDIF.
  APPEND ls_ve TO ls_vm-vendors.
  CALL METHOD vmd_ei_api=>maintain_bapi EXPORTING iv_test_run = space iv_collect_messages = 'X'
       is_master_data = ls_vm IMPORTING es_master_data_defective = ls_vd.
  IF ls_vd-vendors IS INITIAL. COMMIT WORK. ELSE. ROLLBACK WORK. ENDIF.
ENDFORM.
FORM zz_s4_lfa1_pstlz USING p_lifnr p_pstlz.
  DATA: ls_vm TYPE vmds_ei_main, ls_ve TYPE vmds_ei_extern, ls_vd TYPE vmds_ei_main.
  CLEAR: ls_vm, ls_ve, ls_vd.
  ls_ve-header-object_instance-lifnr = p_lifnr.
  ls_ve-header-object_task = 'U'.
  ls_ve-central_data-address-postal-data-postl_cod1  = p_pstlz.
  ls_ve-central_data-address-postal-datax-postl_cod1 = abap_true.
  APPEND ls_ve TO ls_vm-vendors.
  CALL METHOD vmd_ei_api=>maintain_bapi EXPORTING iv_test_run = space iv_collect_messages = 'X'
       is_master_data = ls_vm IMPORTING es_master_data_defective = ls_vd.
  IF ls_vd-vendors IS INITIAL. COMMIT WORK. ELSE. ROLLBACK WORK. ENDIF.
ENDFORM.
*--- S/4 helper: set vendor VEN_CLASS via VMD_EI_API (replaces MODIFY j_1imovend) SAP_ABAP 16.06.2026 ---
FORM zz_s4_set_ven_class USING p_lifnr TYPE lifnr p_venclass TYPE lfa1-ven_class.
  DATA: ls_vmd_main TYPE vmds_ei_main, ls_vmd_ext TYPE vmds_ei_extern, ls_vmd_def TYPE vmds_ei_main.
  CLEAR: ls_vmd_main, ls_vmd_ext, ls_vmd_def.
  ls_vmd_ext-header-object_instance-lifnr = p_lifnr.
  ls_vmd_ext-header-object_task = 'U'.
  ls_vmd_ext-central_data-central-data-ven_class  = p_venclass.
  ls_vmd_ext-central_data-central-datax-ven_class = abap_true.
  APPEND ls_vmd_ext TO ls_vmd_main-vendors.
  CALL METHOD vmd_ei_api=>maintain_bapi
    EXPORTING iv_test_run = space iv_collect_messages = 'X' is_master_data = ls_vmd_main
    IMPORTING es_master_data_defective = ls_vmd_def.
  IF ls_vmd_def-vendors IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.
