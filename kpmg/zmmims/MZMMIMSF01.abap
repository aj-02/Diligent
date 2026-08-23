*----------------------------------------------------------------------*
*   INCLUDE MZMMIMSF01                                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_global_val
*&---------------------------------------------------------------------*
* To set global varaibles value
*----------------------------------------------------------------------*
***********************************************************************
* Date        Transport     USERID          Description
* 24/11/2008  <RD1K960611>  SAB_SURJIT    1) Text Elemeted Created
***********************************************************************

FORM set_global_val.

  CLEAR : g_ims_merg_txt.                        "+018

  wa_zmm_ims-created_on = sy-datum.

  IF g_rb_mat = 'X'.

    wa_zmm_ims-tracktyp = text-004.

    SET PARAMETER ID 'ZTRACKTYP' FIELD text-004.            "+012

    g_ims_merg_txt = text-069.                              "+018

  ELSEIF g_rb_srv = 'X'.

    wa_zmm_ims-tracktyp = text-005.

    SET PARAMETER ID 'ZTRACKTYP' FIELD text-005.            "+012

    g_ims_merg_txt = text-068.                              "+018

  ELSEIF g_rb_fi = 'X'.

    wa_zmm_ims-tracktyp = text-006.

    SET PARAMETER ID 'ZTRACKTYP' FIELD text-006.            "+012

  ENDIF.

ENDFORM.                    " set_global_val

*&---------------------------------------------------------------------*
*&      Form  chk_input_value
*&---------------------------------------------------------------------*
* To validate input data - Vendor code / Purchase Order
*----------------------------------------------------------------------*
*      -->P_LIFNR  Vendor code
*      -->P_EBELN  Purchase Order
*----------------------------------------------------------------------*
FORM chk_input_value USING    p_lifnr
                              p_ebeln.

  DATA : l_lifnr    TYPE lfa1-lifnr,
         l_lifnr_in TYPE lfa1-lifnr,
         l_ebeln    TYPE ekko-ebeln,
         l_aedat    TYPE ekko-aedat,
         l_bstyp    TYPE ekko-bstyp,
         l_ekgrp    TYPE ekko-ekgrp,
         l_bsart    TYPE ekko-bsart.

  DATA : l_sy_subrc TYPE sy-subrc.                          "+001

* To check Vendor Code
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_lifnr
    IMPORTING
      output = l_lifnr_in.

  SELECT SINGLE bukrs FROM lfb1 INTO @DATA(v_bukrs)
                            WHERE  lifnr = @l_lifnr_in
                            AND    bukrs in ( 'OVL', 'OVC' ).
  IF sy-subrc NE 0.
    MESSAGE e735(zmm) WITH text-079.
  ENDIF.

  SELECT SINGLE lifnr name1 FROM lfa1
          INTO (l_lifnr,g_vname)
             WHERE  lifnr = l_lifnr_in      "+003
             AND sperr NE 'X'.               ""Added on 09.11.2020 by Abhishek - To filter blocked vendors

  IF sy-subrc <> 0.

    MESSAGE e787(zmm).
  ELSE.
*+009 - vendors should have numerical value.
    IF l_lifnr_in CO '0123456789'.
    ELSE.
      MESSAGE e735(zmm) WITH text-042.
    ENDIF.
*+009 - EndF

*{cab_rama
*    IF l_lifnr = 'others' OR l_lifnr = 'OTHERs'.           "-002
*-002 - Commented on 03.03.2009 - Input form Amit Agarwal
*    IF l_lifnr = text-032.                                  "+002
*      MESSAGE e735(zmm) WITH text-027.
*    ENDIF.
*-002 - End
*}cab_rama

*+001 - Vendor should not be 0007*.
    IF l_lifnr+3(1) = '7'.
      MESSAGE e735(zmm) WITH text-030.
    ENDIF.
*+001 - end
  ENDIF.

  IF g_rb_mat = 'X'.

    l_bstyp = 'F'.

    l_bsart = text-012.

*+001 - Start - RFQ not allowed in Invoice management system
* To check PO number / Contract no
    SELECT SINGLE ebeln lifnr aedat ekgrp FROM ekko
              INTO (l_ebeln,l_lifnr,l_aedat,l_ekgrp)
                     WHERE  ebeln = p_ebeln
                       AND   bsart LIKE l_bsart
                       AND  loekz <> 'X'
                       AND  bstyp = l_bstyp.

    IF sy-subrc = 0.
      l_sy_subrc = sy-subrc.
    ELSE.
      l_sy_subrc = sy-subrc.
    ENDIF.
*+001 - End

*+010 - if freight vendor is checked, bypass validation between PO &
*       Vendor code
    IF wa_zmm_ims-vndchk = 'X' AND l_sy_subrc = 0.
      l_sy_subrc = 0.
    ENDIF.
*+010 - End

  ELSEIF g_rb_srv = 'X'.

    l_bstyp = 'K'.

    l_bsart = text-013.

*+001 - Start - RFQ not allowed in Invoice management system
* To check PO number / Contract no
    SELECT SINGLE ebeln lifnr aedat ekgrp FROM ekko
              INTO (l_ebeln,l_lifnr,l_aedat,l_ekgrp)
                     WHERE  ebeln = p_ebeln
                       AND  ( bsart LIKE l_bsart
                        OR  bsart eq 'MMGS' )    " added by ss on 24.8.21
                       AND  loekz <> 'X'
                       AND  bstyp IN (l_bstyp,'F').

    IF sy-subrc = 0.
      l_sy_subrc = sy-subrc.
    ELSE.
      l_sy_subrc = sy-subrc.
    ENDIF.
*+001 - End

  ENDIF.

  IF g_rb_fi <> 'X'.

*-001 - Start - RFQ not allowed in Invoice Management system - commented
** To check PO number / Contract no
*    SELECT SINGLE ebeln lifnr aedat ekgrp FROM ekko
*              INTO (l_ebeln,l_lifnr,l_aedat,l_ekgrp)
*                     WHERE  ebeln = p_ebeln
*                       AND  bsart LIKE l_bsart  "added on 11.07.08
*                       AND  loekz <> 'X'.       "added on 11.07.08
*
** Changed on 25.06.2008 - CAB_SPYADAV - commented
*    "and
**                            bstyp = l_bstyp.               "'F'.
** End of comment
*
*    IF sy-subrc <> 0.
*-001 - End

    IF l_sy_subrc <> 0.                                     "+001

      MESSAGE e788(zmm).

    ELSE.

*+010 - Bypass validation for freight vendor.
      IF wa_zmm_ims-vndchk = 'X'.
      ELSE.
*+010 - End

* To check PO number alongwith vendor code
        IF l_lifnr <> l_lifnr_in.

*+003 - Start
          SELECT SINGLE lifn2 FROM ekpa INTO l_lifnr
                 WHERE ebeln = p_ebeln      AND
                       lifn2 = l_lifnr_in.

          IF sy-subrc <> 0.
*+003 - End

            MESSAGE e789(zmm).

          ENDIF.                                            "+003

        ENDIF.

      ENDIF.                                                "+010

      MOVE l_ekgrp TO wa_zmm_ims-ekgrp.

*+006 - Get description of purchasing group
      SELECT SINGLE eknam FROM t024 INTO g_eknam
          WHERE ekgrp = l_ekgrp.
*+006 - End

      PERFORM fetch_werks USING p_ebeln.

    ENDIF.
*+006 - Section name : Start
  ELSE.

    SELECT SINGLE eknam FROM t024 INTO g_eknam
              WHERE ekgrp = wa_zmm_ims-ekgrp.

*+011 - Validation on section : Start
    IF sy-subrc <> 0 AND
      NOT wa_zmm_ims-ekgrp IS INITIAL.
      MESSAGE e855(zmm) WITH wa_zmm_ims-ekgrp ' ' ' ' 'T024'.
    ENDIF.
*+011 - End
*+006 - End
  ENDIF.

ENDFORM.                    " chk_input_value

*&---------------------------------------------------------------------*
*&      Form  save_data
*&---------------------------------------------------------------------*
*   To insert new data into master and details tables.
*----------------------------------------------------------------------*
FORM save_data.

  DATA : l_lifnr   TYPE lfa1-lifnr,
         l_trackno TYPE zmm_ims-trackno,
         l_no(6).

  DATA : l_ans(1),                                          "+012
         l_qtext TYPE string.                               "+012

** Before save check whether there is a tracking no. already generated
** for the vendor code and PO
*  if not wa_zmm_ims is initial.
*
*    select single trackno from zmm_ims into l_trackno
*       where lifnr = wa_zmm_ims-lifnr and
*             ebeln = wa_zmm_ims-ebeln.
*
*    if sy-subrc = 0.
*      message e791(zmm) with l_trackno.
*    endif.
*
*  endif.

*+012 - Confirmation message/prompt for save in 'Direct FI' case.
  IF wa_zmm_ims-tracktyp = 'F'.

    CLEAR l_ans.

*   CONCATENATE text-058 wa_zmm_ims-lifnr '?' INTO l_qtext
*                                           SEPARATED BY space. "-014

*+014 : Start
    CONCATENATE text-058 wa_zmm_ims-lifnr '('
                             INTO l_qtext SEPARATED BY space.

    CONCATENATE l_qtext g_vname ')' INTO l_qtext.

    CONCATENATE l_qtext '?' INTO l_qtext SEPARATED BY space.
*+014 : End

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Alert '(028)
        text_question         = l_qtext
        text_button_1         = 'Yes'
        text_button_2         = 'No'
        display_cancel_button = ' '
        default_button        = '1'
      IMPORTING
        answer                = l_ans
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF l_ans = '2'.
      CLEAR save_ok.
      CALL SCREEN 0200.
    ENDIF.

  ENDIF.

  IF ( wa_zmm_ims-tracktyp = 'F' AND l_ans = '1' ) OR
       wa_zmm_ims-tracktyp = 'M' OR
       wa_zmm_ims-tracktyp = 'S'.
*+012 - End

    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    "comment  by lipsy on 14.01.2015  for getting next number for combination of vendor location RD1K995868

*    CALL FUNCTION 'NUMBER_GET_NEXT'
*      EXPORTING
*        nr_range_nr             = '01'
*        object                  = 'ZMM_IMS'
*        quantity                = '1'
*      IMPORTING
*        number                  = l_no
*      EXCEPTIONS
*        interval_not_found      = 1
*        number_range_not_intern = 2
*        object_not_found        = 3
*        quantity_is_0           = 4
*        quantity_is_not_1       = 5
*        interval_overflow       = 6
*        buffer_overflow         = 7
*        OTHERS                  = 8.
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.

    "end of comment by lipsy on 14.01.2015  for getting next number forcombination of vendor location RD1K995868
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    IF NOT wa_zmm_ims IS INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_zmm_ims-lifnr
        IMPORTING
          output = l_lifnr.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "comment  by lipsy on 14.01.2015  for getting next number for combination of vendor location RD1K995868

*      CONCATENATE l_lifnr+4(6) wa_zmm_ims-reqloc+3(3) l_no
*                        INTO wa_zmm_ims-trackno.
      "end of comment  by lipsy on 14.01.2015  for getting next number for combination of vendor location RD1K995868
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""""""""
      "addition by lipsy on 09.02.2015  for getting next number for combination of vendor location RD1K995868

      REFRESH:itab_zmm_ims_no[],itab_zmm_ims_new[],itab_zmm_ims_old[].
      CLEAR:wa_zmm_ims_no,wa_zmm_ims_new.
      CLEAR:v_ims_no1.

      SELECT *
      INTO CORRESPONDING FIELDS OF TABLE itab_zmm_ims_no
      FROM zmm_ims
      WHERE lifnr = l_lifnr
      AND  reqloc = wa_zmm_ims-reqloc.

      SORT  itab_zmm_ims_no BY created_on DESCENDING.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""
      "addition by lipsy on 16.02.2015  for getting sorting date from zmm_ims_date RD1K996336
      REFRESH:itab_ims_date[].
      SELECT * FROM zmm_ims_date INTO CORRESPONDING FIELDS OF TABLE itab_ims_date ORDER BY PRIMARY KEY.
      CLEAR: wa_ims_date .
      READ TABLE  itab_ims_date INTO wa_ims_date INDEX 1.
      "end of addition by lipsy on 16.02.2015  for getting sorting datefrom zmm_ims_date  RD1K996336
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      LOOP AT itab_zmm_ims_no INTO wa_zmm_ims_no.

        """"""""""""""""""""""""""""""""""""""""""""""""""""
        "comment by lipsy on 16.02.2015  for getting sorting date from zmm_ims_date RD1K996336
*  if wa_zmm_ims_no-CREATED_ON > '20150211'.
        "end of comment  by lipsy on 16.02.2015  for getting sorting date from zmm_ims_date RD1K996336
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "added by lipsy on 16.02.2015  for getting sorting date from zmm_ims_date RD1K996336
        IF wa_zmm_ims_no-created_on > wa_ims_date-number_date.
          "end of addition by lipsy on 16.02.2015  for getting sorting date from zmm_ims_date RD1K996336

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""


          APPEND wa_zmm_ims_no TO itab_zmm_ims_new.
        ELSE.
          APPEND wa_zmm_ims_no TO itab_zmm_ims_old.
        ENDIF.
        CLEAR:wa_zmm_ims_no.
      ENDLOOP.


      SORT itab_zmm_ims_new BY trackno DESCENDING.

      READ TABLE itab_zmm_ims_new INTO wa_zmm_ims_new INDEX 1.


      v_ims_no1 =  wa_zmm_ims_new-trackno+9(6) .



      PERFORM number_series USING l_lifnr CHANGING wa_zmm_ims-trackno .


      "end of addition by lipsy on 09.02.2015 for getting next number for combination of vendor location RD1K995868
      """""""""""""""""""""""""""""""""""""""""""""""""



      MOVE l_lifnr TO wa_zmm_ims-lifnr.

    ENDIF.

    CLEAR : g_tstamp,
            g_ret1,
            g_ret2.

    PERFORM get_timestamp CHANGING g_tstamp.

*  move sy-uname to wa_zmm_ims-created_by.
*  move g_tstamp to wa_zmm_ims-timestamp.

*  modify zmm_ims from wa_zmm_ims.

*  if sy-subrc = 0.
*
*    commit work.
break sap_abap .
    PERFORM save_data_ims ON COMMIT.

    PERFORM save_data_ims_status ON COMMIT.

    IF g_ret1 <> '1' AND
       g_ret2 <> '1'.

      COMMIT WORK.

      IF NOT wa_zmm_ims-email IS INITIAL.

*      perform send_mail using wa_zmm_ims-email.
        PERFORM send_mail USING wa_zmm_ims.

      ENDIF.

      MESSAGE s790(zmm) WITH wa_zmm_ims-trackno.

*  SET PARAMETER ID 'ZPMDOC' FIELD wa_zpm_dpr-document.

    ELSE.

      MESSAGE e033(zpm).

    ENDIF.

  ENDIF.
  "+012
ENDFORM.                    " save_data

*&---------------------------------------------------------------------*
*&      Form  get_timestamp
*&---------------------------------------------------------------------*
* To Get Time stamp in YYYYMMDDhhmmss format
*----------------------------------------------------------------------*
*      <--P_G_STAMP  text
*----------------------------------------------------------------------*
FORM get_timestamp CHANGING p_tstamp.
  DATA:  l_tstamp TYPE timestamp,
         l_d      TYPE d,
         l_t      TYPE t.

  l_d = sy-datum.
  l_t = sy-uzeit.

  CONVERT DATE l_d TIME l_t INTO
          TIME STAMP l_tstamp TIME ZONE 'UTC   '.
  p_tstamp = l_tstamp.
ENDFORM.                    " get_timestamp

*&---------------------------------------------------------------------*
*&      Form  check_validation_150
*&---------------------------------------------------------------------*
* To validate tracking number
*----------------------------------------------------------------------*
*      -->P_TRACKNO  Tracking Number
*----------------------------------------------------------------------*
FORM check_validation_150 USING    p_trackno.

  IF NOT p_trackno IS INITIAL.

    SELECT * FROM ZMM_IMS INTO WA_ZMM_IMS UP TO 1 ROWS
 WHERE TRACKNO = WA_ZMM_IMS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*** Addition By Ruhani Garg on 20 March 2019.

    IF wa_zmm_ims-status = 'X'.
      IF g_ok_code = 'CHNG'.
        MESSAGE e995(zmm) WITH wa_zmm_ims-trackno.
      ENDIF.
    ENDIF.

    IF sy-subrc <> 0.

      MESSAGE e792(zmm) WITH wa_zmm_ims-trackno.

    ENDIF.

*+006 - Start
    IF wa_zmm_ims-lvorm = 'X'.

      IF g_ok_code = 'DISP'.

        MESSAGE i814(zmm) WITH wa_zmm_ims-trackno.

      ELSE.

        MESSAGE e814(zmm) WITH wa_zmm_ims-trackno.

      ENDIF.

    ENDIF.
*+006 - End

    PERFORM get_uname USING    wa_zmm_ims-created_by
                      CHANGING g_created_by.                "+001

    MOVE wa_zmm_ims-created_on TO g_created_on.             "+001
    MOVE wa_zmm_ims-financdt TO g_fin_on.

    PERFORM chk_location USING wa_zmm_ims-reqloc.           "+002

    SELECT SINGLE name1 FROM t001w INTO g_name1
                 WHERE werks = wa_zmm_ims-werks.            "+002

    SELECT SINGLE name1 FROM lfa1 INTO g_vname
                 WHERE lifnr = wa_zmm_ims-lifnr.            "+003

    IF wa_zmm_ims-zzindper IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_zmm_ims-zzindper
        IMPORTING
          output = wa_zmm_ims-zzindper.

      SELECT SINGLE name_textc FROM user_addr INTO i_name
        WHERE bname = wa_zmm_ims-zzindper.

    ENDIF.


*+011 - Get currency
    IF wa_zmm_ims-waers IS INITIAL.

      IF g_rb_mat = 'X' OR g_rb_srv = 'X'.

        SELECT SINGLE waers FROM ekko INTO wa_zmm_ims-waers
           WHERE ebeln = wa_zmm_ims-ebeln.

      ENDIF.

    ENDIF.
*+011 - End

    MOVE wa_zmm_ims-invoiceval TO g_invoiceval.             "+014


    """"""""""""""""""""""""""""""""""""
    """""added by lipsy on 14.12.2015 for invoice no,value,dt,currency history  RD1K999364
    CLEAR:wa_zmm_ims_old.
    MOVE wa_zmm_ims TO wa_zmm_ims_old.


    IF sy-uname+0(3) = 'CMM'.
    ELSE.
      CLEAR:wa_zmm_ims_status_g.
      SELECT * FROM ZMM_IMS_STATUS INTO WA_ZMM_IMS_STATUS_G UP TO 1 ROWS
 WHERE TRACKNO = WA_ZMM_IMS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc = 0.

        IF wa_zmm_ims_status_g-mbll_stat = 'G' OR
           wa_zmm_ims_status_g-mbli_stat = 'G'.

          IF g_ok_code = 'CHNG'.
            MESSAGE e240(zmm_oth) WITH wa_zmm_ims-trackno.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
    """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,currency history  RD1K999364
    """"""""""""""""""""""""""""""""

*+019 - Start : show the GeM Invoice No. of the PO without pressing F4
    PERFORM get_gem_invoice_no.                             "+019
*+019 - End
  ENDIF.

ENDFORM.                    " check_validation_150
*&---------------------------------------------------------------------*
*&      Form  set_po_text_lebel
*&---------------------------------------------------------------------*
* To set text for PO input - Purchase order No. / Contract No.
*----------------------------------------------------------------------*
FORM set_po_text_lebel.

  REFRESH : ist_zmm_ims.
  CLEAR   : wa_zmm_ims.

  REFRESH : ist_werks,
            ist_return_tab.

  CLEAR   : wa_werks.

  CLEAR : g_created_by,
          g_created_on.                                     "+001

  IF g_rb_mat = 'X'.

    g_po_lebel = text-007.
    g_sec_label = text-038.                                 "+006

    SET PARAMETER ID 'ZTRACKTYP' FIELD text-004.

  ELSEIF g_rb_srv = 'X'.

*    g_po_lebel = text-008.
    g_po_lebel = text-026.
    g_sec_label = text-038.                                 "+006

    SET PARAMETER ID 'ZTRACKTYP'  FIELD text-005.

  ELSEIF g_rb_fi = 'X'.
    g_sec_label = text-039.                                 "+006

    SET PARAMETER ID 'ZTRACKTYP'  FIELD text-006.

  ENDIF.

ENDFORM.                    " set_po_text_lebel


*&---------------------------------------------------------------------
*
*&      Form  lock_record
*&---------------------------------------------------------------------*
*  To lock the records in case of Updation
*----------------------------------------------------------------------*
*  -->  p_trackno   Tracking number
*  <--  p_tracktyp  Tracking type
*----------------------------------------------------------------------*
FORM lock_record USING p_trackno
                       p_tracktyp.

  CALL FUNCTION 'ENQUEUE_EZMM_IMS'
    EXPORTING
      mode_zmm_ims   = 'E'
      mandt          = sy-mandt
      trackno        = p_trackno
      tracktyp       = p_tracktyp
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
*&      Form  unlock_record
*&---------------------------------------------------------------------*
*       To release to Locked record(s).
*----------------------------------------------------------------------*
*  -->  p_trackno   Tracking number
*  <--  p_tracktyp  Tracking type
*----------------------------------------------------------------------*
FORM unlock_record USING p_trackno
                         p_tracktyp.
  CALL FUNCTION 'DEQUEUE_EZMM_IMS'
    EXPORTING
      mode_zmm_ims = 'E'
      mandt        = sy-mandt
      trackno      = p_trackno
      tracktyp     = p_tracktyp.

ENDFORM.                    " unlock_record

*&---------------------------------------------------------------------*
*&      Form  confirm_input
*&---------------------------------------------------------------------*
*  In case of cancel or exit ,Display warning message.
*----------------------------------------------------------------------*
*  -->  p_text    Text Question
*  <--  p_dbutton Default Button i.e. '1' - Yes / '2' - Cancel etc.
*  <--  p_ans     Return Value
*----------------------------------------------------------------------*
*FORM confirm_input CHANGING p_ans.                          "-006
FORM confirm_input USING p_text
                         p_dbutton
                   CHANGING p_ans.                          "+006
* Begin of  <RD1K960611>
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Alert '(028)
*     text_question         = text-009                      "-006
      text_question         = p_text                        "+006
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      display_cancel_button = ' '
*     default_button        = '1' "-006
      default_button        = p_dbutton                     "+006
    IMPORTING
      answer                = p_ans
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* End of    <RD1K960611>
ENDFORM.                    " confirm_input

*&---------------------------------------------------------------------*
*&      Form  update_data
*----------------------------------------------------------------------*
*   To update existing record in Z-table ZMM_IMS
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_data.
  break abapuser02.

  DATA : wa_zmm_ims_status TYPE zmm_ims_status.             "+003

  CLEAR g_tstamp.

  PERFORM get_timestamp CHANGING g_tstamp.

  MOVE g_tstamp TO wa_zmm_ims-timestamp.

  MOVE sy-uname TO wa_zmm_ims-changed_by.
  MOVE sy-datum TO wa_zmm_ims-changed_on.
  MOVE g_tstamp TO wa_zmm_ims-timestamp.

  MODIFY zmm_ims FROM wa_zmm_ims.

  IF sy-subrc = 0.

*+003 - Update timestamp entry in status table : Start

*    select single * from zmm_ims_status into wa_zmm_ims_status
*                     where trackno = wa_zmm_ims-trackno.
*
*    MOVE g_tstamp TO wa_zmm_ims_status-timestamp.
*
*    MODIFY zmm_ims_status FROM wa_zmm_ims_status.
*
*    IF sy-subrc = 0.

*+003 - End

    PERFORM upd_ims_invval USING wa_zmm_ims.                "+014

    COMMIT WORK.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""""""""""""""""""""""
    """""added by lipsy on 14.12.2015 for invoice no,value,dt,currency history

    CLEAR:wa_zmm_ims_cnew.

    MOVE-CORRESPONDING wa_zmm_ims  TO wa_zmm_ims_cnew.
    PERFORM chng_doc_ims USING wa_zmm_ims-trackno
                              wa_zmm_ims_old
                             wa_zmm_ims_cnew.

    COMMIT WORK.
    """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,currency history
    """"""""""""""""""""""""""""""""






    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    MESSAGE s793(zmm) WITH wa_zmm_ims-trackno.

*    ELSE.                                                   "+003
*
*      MESSAGE e033(zpm).                                    "+003
*
*    ENDIF.                                                  "+003

  ELSE.

    MESSAGE e033(zpm).

  ENDIF.

  PERFORM unlock_record USING wa_zmm_ims-trackno
                              wa_zmm_ims-tracktyp.

*  PERFORM unlock_record_status USING wa_zmm_ims-trackno
*                                     wa_zmm_ims-tracktyp.   "+003

ENDFORM.                    " update_data


*---------------------------------------------------------------------*
*       FORM send_mail                                                *
*---------------------------------------------------------------------*
*  To send mail                                                      *
*---------------------------------------------------------------------*
*  -->  P_MAILID      Mail ID
*---------------------------------------------------------------------*
*Form send_mail using p_mailid.
FORM send_mail USING p_wa_zmm_ims STRUCTURE zmm_ims.
  BREAK abapuser02.

  DATA : ist_message_content LIKE soli  OCCURS 10 WITH HEADER LINE.
  DATA : ist_receiver_list   LIKE soos1 OCCURS 5  WITH HEADER LINE.
  DATA : w_object_hd_change LIKE sood1.

  DATA : l_uname TYPE sy-uname.                             "+003

  DATA : l_date(10).


* Receivers
*  ist_receiver_list-recextnam = p_mailid.
  ist_receiver_list-recextnam = p_wa_zmm_ims-email.

*  translate ist_receiver_list-recextnam to lower case.

* Email Address
  ist_receiver_list-recesc = 'E'.  "U'.
  ist_receiver_list-sndart = 'INT'."MAIL'.
  ist_receiver_list-sndpri = '1'.

  APPEND ist_receiver_list.

*General data
  w_object_hd_change-objla = sy-langu.
* Begin of  <RD1K960611>
  w_object_hd_change-objnam = 'Object name'(029).
* End of    <RD1K960611>
  w_object_hd_change-objsns = 'P'.

* Mail subject
  CONCATENATE text-010 wa_zmm_ims-trackno text-011 INTO
               w_object_hd_change-objdes SEPARATED BY space.

* Mail body
  CONCATENATE sy-datum+6(2) '/'
              sy-datum+4(2) '/'
              sy-datum+0(4) INTO l_date ."SEPARATED BY space.
*              sy-datum+0(4) INTO l_date SEPARATED BY space.

*  concatenate text-012 l_date into ist_message_content.

*  concatenate text-010 wa_zmm_ims-trackno text-011 into
*                    ist_message_content separated by space.
*
*  APPEND ist_message_content.

* Message body - start
  DATA : l_name1          TYPE lfa1-name1,
         l_invoiceval(20).

* Line : 1
  SELECT SINGLE name1 INTO l_name1 FROM lfa1
     WHERE lifnr = p_wa_zmm_ims-lifnr.

  CONCATENATE text-014 l_name1 INTO
                    ist_message_content SEPARATED BY space.

  CONCATENATE ist_message_content ',' INTO
                    ist_message_content.

  APPEND ist_message_content.
  CLEAR ist_message_content.

  APPEND ist_message_content. "Blank line

* Line : 2
  MOVE text-015 TO ist_message_content-line.

  APPEND ist_message_content.
  CLEAR ist_message_content.

  APPEND ist_message_content. "Blank line

* Line : 3
  CONCATENATE text-016 p_wa_zmm_ims-trackno INTO
                    ist_message_content SEPARATED BY space.

  APPEND ist_message_content.
  CLEAR ist_message_content.

* Line : 4
  CONCATENATE text-017 p_wa_zmm_ims-ebeln INTO
                    ist_message_content SEPARATED BY space.

  APPEND ist_message_content.
  CLEAR ist_message_content.

* Line : 5
  CONCATENATE text-018 p_wa_zmm_ims-invoiceno INTO
                    ist_message_content SEPARATED BY space.

  APPEND ist_message_content.
  CLEAR ist_message_content.

* Line : 6
  CONCATENATE p_wa_zmm_ims-invoicedt+6(2) '/'
              p_wa_zmm_ims-invoicedt+4(2) '/'
             p_wa_zmm_ims-invoicedt+0(4) INTO l_date.
*           p_wa_zmm_ims-invoicedt+0(4) INTO l_date SEPARATED BY space.

  CONCATENATE text-019 l_date INTO
                    ist_message_content SEPARATED BY space.

  APPEND ist_message_content.
  CLEAR ist_message_content.

* Line : 7
  MOVE p_wa_zmm_ims-invoiceval TO l_invoiceval.

  CONCATENATE text-020 l_invoiceval INTO
                    ist_message_content SEPARATED BY space.

  APPEND ist_message_content.
  CLEAR ist_message_content.

*+006 - Addd Vendor code - Start
* Line : 7a
  CONCATENATE text-040 p_wa_zmm_ims-trackno+0(6) INTO
                    ist_message_content SEPARATED BY space.

  APPEND ist_message_content.
  CLEAR ist_message_content.
*+006 - End

  APPEND ist_message_content. "Blank line

* Line : 8
  " commented by hire
*  MOVE text-021 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
** Line : 9
*  MOVE text-022 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
** Line : 10
*  MOVE text-023 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
*  APPEND ist_message_content. "Blank line
  """""" till here""""""""""
*+011 - Start
*Line 10(a)
***************** added by aparna.
  MOVE text-080 TO ist_message_content-line.

  APPEND ist_message_content.
  CLEAR ist_message_content.

**Line 10(b)
*  MOVE text-049 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
**Line 10(c)
*  MOVE text-050 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
**Line 10(d)
*  MOVE text-051 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
**Line 10(e)
*  MOVE text-052 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.
*
**Line 10(f)
*  MOVE text-053 TO ist_message_content-line.
*
*  APPEND ist_message_content.
*  CLEAR ist_message_content.

  APPEND ist_message_content. "Blank line
*+011 - End

* Line : 11
  MOVE text-024 TO ist_message_content-line.

  APPEND ist_message_content.
  CLEAR ist_message_content.

  APPEND ist_message_content. "Blank line
  APPEND ist_message_content. "Blank line

* Line : 12
  MOVE text-025 TO ist_message_content-line.

  APPEND ist_message_content.
  CLEAR ist_message_content.
* End

  CALL FUNCTION 'SO_OBJECT_SEND'
    EXPORTING
      object_hd_change           = w_object_hd_change
      object_type                = 'RAW'
      owner                      = sy-uname
    TABLES
      objcont                    = ist_message_content
      receivers                  = ist_receiver_list
    EXCEPTIONS
      active_user_not_exist      = 1
      communication_failure      = 2
      component_not_available    = 3
      folder_not_exist           = 4
      folder_no_authorization    = 5
      forwarder_not_exist        = 6
      note_not_exist             = 7
      object_not_exist           = 8
      object_not_sent            = 9
      object_no_authorization    = 10
      object_type_not_exist      = 11
      operation_no_authorization = 12
      owner_not_exist            = 13
      parameter_error            = 14
      substitute_not_active      = 15
      substitute_not_defined     = 16
      system_failure             = 17
      too_much_receivers         = 18
      user_not_exist             = 19
      originator_not_exist       = 20
      x_error                    = 21
      OTHERS                     = 22.

  IF sy-subrc <> 0.
*    message i794(zmm) with p_mailid.
    MESSAGE i794(zmm) WITH p_wa_zmm_ims-email.
  ENDIF.

ENDFORM.                    "send_mail

*&---------------------------------------------------------------------*
*&      Form  save_data_ims
*&---------------------------------------------------------------------*
* Insert IMS data in Header table - ZMM_IMS
*----------------------------------------------------------------------*
FORM save_data_ims.

*+019 - Start : make sure the GeM Invoice No. is on the record before MODIFY
  PERFORM get_gem_invoice_no.                               "+019
*+019 - End

  MOVE sy-uname TO wa_zmm_ims-created_by.
  MOVE g_tstamp TO wa_zmm_ims-timestamp.

  IF NOT s_inv[] IS INITIAL.
    LOOP AT s_inv.
      IF s_inv-option = 'EQ'.
        wa_zmm_ims-invoiceno = s_inv-low.
        MODIFY zmm_ims FROM wa_zmm_ims.
      ENDIF.
      IF s_inv-option = 'BT'.

        wa_zmm_ims-invoiceno = s_inv-low.
        MODIFY zmm_ims FROM wa_zmm_ims.
      ENDIF.

    ENDLOOP.
  ELSE.
    MODIFY zmm_ims FROM wa_zmm_ims.
  ENDIF.
  IF sy-subrc <> 0.
    g_ret1 = '1'.
  ELSE.
    IF NOT wa_zmm_ims-mobileno IS INITIAL.
      PERFORM send_sms USING wa_zmm_ims-mobileno.
    ENDIF.


    """"""""""""""""""""""""""""""""""
    """""added by lipsy on 14.12.2015 for invoice no,value,dt,currency history  "RD1K999364

    IF v_exist_email IS NOT INITIAL.
      CLEAR: v_lifnr_update.
      v_lifnr_update =  wa_zmm_ims-lifnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = v_lifnr_update
        IMPORTING
          output = v_lifnr_update.

      obj_id =  v_lifnr_update.
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
*         bapiadtel      = bapiadtel
          return         = return.


      IF bapiadsmtp[] IS INITIAL.
        bapiadsmtp-e_mail      = v_exist_email.
        bapiadsmtp-email_srch  = v_exist_email.
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
*           OBJ_ID_EXT     = obj_id_ext
            context        = context
*           ACCEPT_ERROR   = ' '
*           SAVE_ADDRESS   = 'X'
*           IV_CHECK_ADDRESS            = 'X'
*           IV_TIME_DEPENDENT_COMM_DATA = ' '
          IMPORTING
            address_number = addrno
          TABLES
*           BAPIAD1VL      =
*           BAPIADTEL      = BAPIADTEL
*           BAPIADFAX      =
*           BAPIADTTX      =
*           BAPIADTLX      =
            bapiadsmtp     = bapiadsmtp
*           BAPIADRML      =
*           BAPIADX400     =
*           BAPIADRFC      =
*           BAPIADPRT      =
*           BAPIADSSF      =
*           BAPIADURI      =
*           BAPIADPAG      =
*           BAPIAD_REM     =
*           BAPICOMREM     =
*           BAPIADUSE      =
*           BAPIAD1VL_X    =
*           BAPIADTEL_X    = BAPIADTEL_X
*           BAPIADFAX_X    =
*           BAPIADTTX_X    =
*           BAPIADTLX_X    =
            bapiadsmt_x    = bapiadsmt_x
*           BAPIADRML_X    =
*           BAPIADX40_X    =
*           BAPIADRFC_X    =
*           BAPIADPRT_X    =
*           BAPIADSSF_X    =
*           BAPIADURI_X    =
*           BAPIADPAG_X    =
*           BAPIAD_RE_X    =
*           BAPICOMRE_X    =
*           BAPIADUSE_X    =
            return         = return.


        IF return IS INITIAL.

*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
**                EXPORTING
**                  WAIT = 'X'.

        ENDIF.
        REFRESH:bapiadsmtp,bapiadsmt_x.

      ENDIF.

    ENDIF.
    """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,currency history  "RD1K999364

    """""""""""""""""""""""""""""""""""""""""
  ENDIF.

ENDFORM.                    " save_data_ims

*&---------------------------------------------------------------------*
*&      Form  save_data_ims_status
*&---------------------------------------------------------------------*
* Insert IMS data in IMS Status table - ZMM_IMS_STATUS
*----------------------------------------------------------------------*
FORM save_data_ims_status.

  DATA : wa_zmm_ims_status TYPE zmm_ims_status.

  wa_zmm_ims_status-mandt = sy-mandt.
  MOVE wa_zmm_ims-trackno    TO wa_zmm_ims_status-trackno.
  MOVE wa_zmm_ims-tracktyp   TO wa_zmm_ims_status-tracktyp.
  MOVE wa_zmm_ims-created_on TO wa_zmm_ims_status-trackdt.
  MOVE wa_zmm_ims-ebeln      TO wa_zmm_ims_status-ebeln.
  MOVE g_tstamp              TO wa_zmm_ims_status-timestamp. "+003
  MOVE wa_zmm_ims-invoiceval TO wa_zmm_ims_status-invoiceval. "+012

*Begin 14.03.2024-CR4000000194-Incnt No 8000002622-SAP_ABAP(OVL Conslt)
*Save the Industry key & Industry key Name fields in the table ZMM_IMS_STATUS
  MOVE wa_zmm_ims-BRSCH    TO wa_zmm_ims_status-BRSCH.
  MOVE wa_zmm_ims-BRTXT   TO wa_zmm_ims_status-BRTXT.
*End 14.03.2024-CR4000000194-Incnt No 8000002622-SAP_ABAP(OVL Conslt)

*+013 - CR No. 30005291 : Start
  IF wa_zmm_ims_status-tracktyp = 'M'.

    wa_zmm_ims_status-qcc_stat  = 'R'.
    wa_zmm_ims_status-inw_stat  = 'R'.
    wa_zmm_ims_status-mblr_stat = 'R'.
    wa_zmm_ims_status-mbls_stat = 'R'.
    wa_zmm_ims_status-mbll_stat = 'R'.
    wa_zmm_ims_status-mbli_stat = 'R'.

  ELSEIF wa_zmm_ims_status-tracktyp = 'S'.

    wa_zmm_ims_status-mbls_stat = 'R'.
    wa_zmm_ims_status-mbll_stat = 'R'.
    wa_zmm_ims_status-mbli_stat = 'R'.

  ELSEIF wa_zmm_ims_status-tracktyp = 'F'.

    wa_zmm_ims_status-mbll_stat = 'R'.
    wa_zmm_ims_status-mbli_stat = 'R'.

  ENDIF.
*+013 - CR No. 30005291 : End

  MODIFY zmm_ims_status FROM wa_zmm_ims_status.

  IF sy-subrc <> 0.
    g_ret2 = '1'.
  ENDIF.

ENDFORM.                    " save_data_ims_status

*&---------------------------------------------------------------------*
*&      Form  fetch_werks
*&---------------------------------------------------------------------*
* To fetch plants from PO item table - EKPO
*----------------------------------------------------------------------*
*      -->P_P_EBELN  PO Number
*----------------------------------------------------------------------*
FORM fetch_werks USING    p_p_ebeln.

  DATA : l_index TYPE sy-tabix.

*  clear : wa_zmm_ims-werks,
*          g_name1.

  SELECT werks FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE ist_werks
            WHERE ebeln = p_p_ebeln AND
                  loekz <> 'X'.

  IF sy-subrc = 0.

    SORT ist_werks BY werks.

    DELETE ADJACENT DUPLICATES FROM ist_werks.

    LOOP AT ist_werks INTO wa_werks.

      l_index = sy-tabix.

      SELECT SINGLE name1 FROM t001w INTO wa_werks-name1
                   WHERE werks = wa_werks-werks.

      IF sy-subrc = 0.

        MODIFY ist_werks FROM wa_werks INDEX l_index TRANSPORTING name1.

      ENDIF.

    ENDLOOP.

    CLEAR : l_index.

    DESCRIBE TABLE ist_werks LINES l_index.

    IF l_index = 1.

      READ TABLE ist_werks INTO wa_werks INDEX 1.

      IF sy-subrc = 0.

        MOVE wa_werks-werks TO wa_zmm_ims-werks.
        MOVE wa_werks-name1 TO g_name1.

      ENDIF.

    ELSEIF l_index > 1 OR l_index = 0.

      READ TABLE ist_werks INTO wa_werks
                       WITH KEY werks = wa_zmm_ims-werks.

      IF sy-subrc <> 0.                                     "+005

        READ TABLE ist_werks INTO wa_werks INDEX 1.         "+005

        IF sy-subrc = 0.                                    "+005

          MOVE wa_werks-werks TO wa_zmm_ims-werks.          "+005
          MOVE wa_werks-name1 TO g_name1.                   "+005

        ELSE.                                               "+005

*        IF sy-subrc <> 0.                                  "-005

          CLEAR : wa_zmm_ims-werks,
                  g_name1.

        ENDIF.

      ENDIF.                                                "+005

    ENDIF.

  ELSE.

    CLEAR : wa_zmm_ims-werks,
            g_name1.

  ENDIF.

ENDFORM.                    " fetch_werks

*&---------------------------------------------------------------------*
*&      Form  disp_process_guide
*&---------------------------------------------------------------------*
* To display process guide - Deletetd PR
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM disp_process_guide.                                   "-012
FORM disp_process_guide USING p_logsys.                     "+012

  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
  DATA : wa_att_files LIKE swotobjid.

*  wa_att_files-logsys  = 'IMSHELP'.                         "-012
  wa_att_files-logsys  = p_logsys.                          "+012
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

ENDFORM.                    " disp_process_guide
*&---------------------------------------------------------------------*
*&      Form  get_range
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_range.
  CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
    EXPORTING
      text      = text-001
    TABLES
      range     = s_inv
    EXCEPTIONS
      cancelled = 0.

ENDFORM.                    " get_range

*&---------------------------------------------------------------------*
*&      Form  get_uname
*&---------------------------------------------------------------------*
*  To get name of creator
*----------------------------------------------------------------------*
FORM get_uname USING    p_name
               CHANGING p_uname.

  SELECT SINGLE * FROM usr21 WHERE bname = p_name.

  IF sy-subrc = 0.

    SELECT * FROM ADRP UP TO 1 ROWS
 WHERE PERSNUMBER = USR21-PERSNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc = 0.

      IF adrp-name_first <> space AND adrp-name_last <> space.

        CONCATENATE adrp-name_first adrp-name_last
                      INTO p_uname SEPARATED BY space.

      ELSEIF adrp-name_first <> space.

        p_uname = adrp-name_first.

      ELSE.

        p_uname = adrp-name_last.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " get_indentor_name
*&---------------------------------------------------------------------*
*&      Form  CHK_LOCATION
*&---------------------------------------------------------------------*
* To validate location from Z-table ZLOCMST
*----------------------------------------------------------------------*
*      -->P_REQLOC  Location code
*----------------------------------------------------------------------*
FORM chk_location  USING    p_reqloc.

* Data : l_reqloc type zlocmst-locid.                       "-002
  DATA : wa_zlocmst TYPE zlocmst.                           "+002

*  select single locid from zlocmst into l_reqloc
*     where locid = p_reqloc.                               "-002

  SELECT SINGLE * FROM zlocmst INTO wa_zlocmst
     WHERE locid = p_reqloc.                                "+002

  IF sy-subrc <> 0.

    MESSAGE e049(zmm). " with text-031.

*+002 - Get Location description - start
  ELSE.

    CONCATENATE wa_zlocmst-bldg ',' wa_zlocmst-area ','
                wa_zlocmst-region INTO g_loctext SEPARATED BY space.

*+002 - End

    IF g_ok_code <> 'DISP'.                                 "+005

      PERFORM chk_user_location USING sy-uname
                                      p_reqloc.             "+005
    ENDIF.                                                  "+005

  ENDIF.

ENDFORM.                    " CHK_LOCATION

*&---------------------------------------------------------------------
*
*&      Form  lock_record_status
*&---------------------------------------------------------------------*
*  To lock the records in case of Updation - ZMM_IMS_STATUS
*----------------------------------------------------------------------*
*  -->  p_trackno   Tracking number
*  <--  p_tracktyp  Tracking type
*----------------------------------------------------------------------*
FORM lock_record_status USING p_trackno
                       p_tracktyp.

  CALL FUNCTION 'ENQUEUE_EZMM_IMS_STATUS'
    EXPORTING
      mode_zmm_ims_status = 'E'
      mandt               = sy-mandt
      trackno             = p_trackno
      tracktyp            = p_tracktyp
    EXCEPTIONS
      foreign_lock        = 1
      system_failure      = 2
      OTHERS              = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " lock_record_status

*&---------------------------------------------------------------------*
*&      Form  unlock_record_status
*&---------------------------------------------------------------------*
*       To release to Locked record(s). - ZMM_IMS_STATUS
*----------------------------------------------------------------------*
*  -->  p_trackno   Tracking number
*  <--  p_tracktyp  Tracking type
*----------------------------------------------------------------------*
FORM unlock_record_status USING p_trackno
                         p_tracktyp.

  CALL FUNCTION 'DEQUEUE_EZMM_IMS_STATUS'
    EXPORTING
      mode_zmm_ims_status = 'E'
      mandt               = sy-mandt
      trackno             = p_trackno
      tracktyp            = p_tracktyp.

ENDFORM.                    " unlock_record_status
*&---------------------------------------------------------------------*
*&      Form  CHK_USER_AUTHORITY
*&---------------------------------------------------------------------*
* To check user entry in DB table ZMM_IMSAUTH
*----------------------------------------------------------------------*
*      -->P_UNAME  User Name
*----------------------------------------------------------------------*
FORM chk_user_authority  USING    p_uname.

  DATA : wa_imsauth TYPE zmm_imsauth.
  IF sy-uname+0(1) <> 'C'.
    SELECT SINGLE * FROM zmm_imsauth INTO wa_imsauth
       WHERE uname = p_uname.

    IF sy-subrc <> 0.
      MESSAGE e808(zmm) WITH p_uname.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHK_USER_AUTHORITY

*&---------------------------------------------------------------------*
*&      Form  CHK_USER_LOCATION
*&---------------------------------------------------------------------*
* To check location in DB table ZMM_IMSAUTH
*----------------------------------------------------------------------*
*      -->P_UNAME  User name
*      -->P_REQLOC Location code
*----------------------------------------------------------------------*
FORM chk_user_location  USING    p_uname
                                 p_reqloc.

  DATA : wa_imsauth TYPE zmm_imsauth.

  SELECT SINGLE * FROM zmm_imsauth INTO wa_imsauth
     WHERE uname  = p_uname AND
           reqloc = p_reqloc.

  IF sy-subrc <> 0.
    MESSAGE e809(zmm) WITH p_reqloc.
  ENDIF.

ENDFORM.                    " CHK_USER_LOCATION
*&---------------------------------------------------------------------*
*&      Form  GET_MAILID
*&---------------------------------------------------------------------*
* To get email ID
*----------------------------------------------------------------------*
*      -->P_LIFNR  Vendor Code
*      -->P_EMAIL  E-mail ID
*----------------------------------------------------------------------*
FORM get_mailid  USING    p_lifnr
                          p_email.

  DATA : l_lifnr_in TYPE lfa1-lifnr,
         l_adrnr    TYPE lfa1-adrnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_lifnr
    IMPORTING
      output = l_lifnr_in.

  SELECT SINGLE adrnr FROM lfa1
            INTO l_adrnr
              WHERE lifnr = l_lifnr_in.

  IF sy-subrc = 0.

    SELECT SMTP_ADDR FROM ADR6
 INTO P_EMAIL UP TO 1 ROWS WHERE ADDRNUMBER = L_ADRNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  ENDIF.

ENDFORM.                    " GET_MAILID

*&---------------------------------------------------------------------*
*&      Form  CHK_MAILID
*&---------------------------------------------------------------------*
* To check Mail ID
*----------------------------------------------------------------------*
*      -->P_MAILID  Mail ID
*----------------------------------------------------------------------*
FORM chk_mailid  USING    p_mailid.

  DATA : l_mailid TYPE zmm_ims-email,
         l_strlen TYPE sy-tabix.                            "+011

  IF g_ok_code <> 'DISP'.

    FIND FIRST OCCURRENCE OF '@' IN p_mailid IN CHARACTER MODE.

    IF sy-subrc = 0.

      FIND FIRST OCCURRENCE OF '.' IN p_mailid IN CHARACTER MODE.

      IF sy-subrc <> 0.

        MESSAGE e810(zmm).

*+011 - Check space in mail id, if found flash error.
      ELSE.

        MOVE p_mailid  TO l_mailid.

        CONDENSE l_mailid NO-GAPS.

        IF p_mailid NE l_mailid.

          MESSAGE e810(zmm).

        ENDIF.
*+011 - End

      ENDIF.

    ELSE.

      MESSAGE e810(zmm).

    ENDIF.

*+006 - Search string "ongc.co.in" & if find, display error message.
    FIND text-037 IN p_mailid.

    IF sy-subrc = 0.
      MESSAGE e816(zmm).
    ENDIF.

*+006 - End
  ENDIF.

*+011 - Check '.' at the end of mail id, if found flash error.
  l_strlen = strlen( p_mailid ) - 1.

  IF p_mailid+l_strlen(1) = '.'.

    MESSAGE e816(zmm).

  ENDIF.
*+011 - end

ENDFORM.                    " CHK_MAILID

*&---------------------------------------------------------------------*
*&      Form  DELETE_DATA
*&---------------------------------------------------------------------*
*To delete tracking no.
*----------------------------------------------------------------------*
FORM delete_data .

  DATA : wa_zmm_ims_status TYPE zmm_ims_status.

  DATA : l_return(1).

  CLEAR : g_ans.

  PERFORM confirm_input  USING text-036
                               '2'
                         CHANGING g_ans.
  IF g_ans = 1.

    PERFORM chk_trackno_status USING wa_zmm_ims-trackno
                                   l_return.
    IF l_return = 'X'.

      PERFORM upd_ims_hdr ON COMMIT.

      PERFORM del_ims_dtl ON COMMIT.

      IF g_ret1 <> '1' AND
         g_ret2 <> '1'.

        COMMIT WORK.

        MESSAGE s811(zmm) WITH wa_zmm_ims-trackno.

      ELSE.

        MESSAGE e812(zmm).

      ENDIF.

    ELSE.

      MESSAGE e813(zmm) WITH wa_zmm_ims-trackno.

    ENDIF.

  ENDIF.

  PERFORM unlock_record USING wa_zmm_ims-trackno
                              wa_zmm_ims-tracktyp.

ENDFORM.                    " DELETE_DATA
*&---------------------------------------------------------------------*
*&      Form  CHK_TRACKNO_STATUS
*&---------------------------------------------------------------------*
* To check tracking number status in IMS Tracking Status table
* : ZMM_IMS_STATUS
*----------------------------------------------------------------------*
*      -->P_TRACKNO  Tracking No.
*      <--P_RETURN   Return Value
*----------------------------------------------------------------------*
FORM chk_trackno_status  USING    p_trackno
                         CHANGING p_return.

  DATA : ist_zmm_ims_status_del TYPE TABLE OF zmm_ims_status,
         wa_zmm_ims_status_del  TYPE zmm_ims_status.

  SELECT * FROM zmm_ims_status
      INTO TABLE ist_zmm_ims_status_del
           WHERE trackno = p_trackno ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.

    READ TABLE ist_zmm_ims_status_del INTO
                          wa_zmm_ims_status_del INDEX 1.

    IF sy-subrc =  0.

      IF wa_zmm_ims_status_del-qcc_stat  IS INITIAL AND
         wa_zmm_ims_status_del-inw_stat  IS INITIAL AND
         wa_zmm_ims_status_del-qcc_stat  IS INITIAL AND
         wa_zmm_ims_status_del-mblr_stat IS INITIAL AND
         wa_zmm_ims_status_del-mbls_stat IS INITIAL AND
         wa_zmm_ims_status_del-mbll_stat IS INITIAL AND     "+007
         wa_zmm_ims_status_del-mbli_stat IS INITIAL.

        DELETE ist_zmm_ims_status_del WHERE trackno = p_trackno.

*-008 - Start
*      ELSEIF wa_zmm_ims_status_del-qcc_stat  = 'R' AND
*             wa_zmm_ims_status_del-inw_stat  = 'R' AND
*             wa_zmm_ims_status_del-qcc_stat  = 'R' AND
*             wa_zmm_ims_status_del-mblr_stat = 'R' AND
*             wa_zmm_ims_status_del-mbls_stat = 'R' AND
*             wa_zmm_ims_status_del-mbll_stat = 'R' AND      "+007
*             wa_zmm_ims_status_del-mbli_stat = 'R' AND
*             wa_zmm_ims_status_del-qcc_asn IS INITIAL.
*
*        DELETE ist_zmm_ims_status_del WHERE trackno = p_trackno.
*-008 - End

*+008 - Start
      ELSEIF wa_zmm_ims_status_del-tracktyp  = 'M'.

        IF   wa_zmm_ims_status_del-qcc_stat  = 'R' AND
             wa_zmm_ims_status_del-inw_stat  = 'R' AND
             wa_zmm_ims_status_del-mblr_stat = 'R' AND
             wa_zmm_ims_status_del-mbls_stat = 'R' AND
             wa_zmm_ims_status_del-mbll_stat = 'R' AND
             wa_zmm_ims_status_del-mbli_stat = 'R' AND
             wa_zmm_ims_status_del-qcc_asn IS INITIAL.

          DELETE ist_zmm_ims_status_del WHERE trackno = p_trackno.

        ENDIF.

      ELSEIF wa_zmm_ims_status_del-tracktyp  = 'S'.

        IF  wa_zmm_ims_status_del-mbls_stat = 'R' AND
            wa_zmm_ims_status_del-mbll_stat = 'R' AND
            wa_zmm_ims_status_del-mbli_stat = 'R' AND
            wa_zmm_ims_status_del-mbls_asn IS INITIAL.

          DELETE ist_zmm_ims_status_del WHERE trackno = p_trackno.

        ENDIF.

      ELSEIF wa_zmm_ims_status_del-tracktyp  = 'F'.

        IF wa_zmm_ims_status_del-mbll_stat = 'R' AND
           wa_zmm_ims_status_del-mbli_stat = 'R' AND
           wa_zmm_ims_status_del-mbll_asn IS INITIAL.

          DELETE ist_zmm_ims_status_del WHERE trackno = p_trackno.

        ENDIF.
*+008 - End

      ENDIF.

    ENDIF.

    IF ist_zmm_ims_status_del[] IS INITIAL.
      p_return = 'X'.
    ENDIF.

  ELSE.

    p_return = 'X'.

  ENDIF.

ENDFORM.                    " CHK_TRACKNO_STATUS

*&---------------------------------------------------------------------*
*&      Form  UPD_IMS_HDR
*&---------------------------------------------------------------------*
* To update IMS Header table
*----------------------------------------------------------------------*
FORM upd_ims_hdr .

  CLEAR : g_tstamp,
          g_ret1.

  PERFORM get_timestamp CHANGING g_tstamp.

  MOVE sy-uname TO wa_zmm_ims-changed_by.
  MOVE sy-datum TO wa_zmm_ims-changed_on.
  MOVE g_tstamp TO wa_zmm_ims-timestamp.
  MOVE 'X'      TO wa_zmm_ims-lvorm.

  MODIFY zmm_ims FROM wa_zmm_ims.

  IF sy-subrc <> 0.
    g_ret1 = '1'.
  ENDIF.

ENDFORM.                    " UPD_IMS_HDR

*&---------------------------------------------------------------------*
*&      Form  DEL_IMS_DTL
*&---------------------------------------------------------------------*
* To delete IMS status entry
*----------------------------------------------------------------------*
FORM del_ims_dtl .

  CLEAR : g_ret2.

  DELETE FROM zmm_ims_status
           WHERE trackno = wa_zmm_ims-trackno.

  IF sy-subrc <> 0.
    g_ret2 = '1'.
  ENDIF.

ENDFORM.                    " DEL_IMS_DTL

*&---------------------------------------------------------------------*
*&      Form  MERGE_IMS_TRACK_NOS
*&---------------------------------------------------------------------*
* To merge IMS tracking Nos.
*----------------------------------------------------------------------*
*   <=== p_sy_subrc Return value
*----------------------------------------------------------------------*
FORM merge_ims_track_nos CHANGING p_sy_subrc.

  DATA : l_trackno  TYPE zmm_ims-trackno,
         l_tracktyp TYPE zmm_ims-tracktyp,
         l_trackdt  TYPE zmm_ims_status-trackdt.

  DATA : wa_zmm_ims_status_t TYPE zmm_ims_status,
         l_sy_subrc          TYPE sy-subrc.

  DATA : l_invoiceval TYPE zmm_ims-invoiceval,
         l_first(1).                                        "+012

  IF NOT wa_zmm_ims IS INITIAL.

    l_sy_subrc = 0.

*-012 : Start
*    READ TABLE ist_zmm_ims_status INTO wa_zmm_ims_status_t INDEX 1.
*
*    IF sy-subrc <> 0.
*
*      SELECT SINGLE * FROM  zmm_ims_status INTO wa_zmm_ims_status_t
*                         WHERE trackno   = wa_zmm_ims-trackno AND
**                              mbli_stat = 'G'.             "-012
*                               mbll_stat = 'G'.             "+012
*      IF sy-subrc <> 0.
*-012 : End

*+012 : Start
    REFRESH ist_zmm_ims_hdr.

    """""commented by lipsy on 16.12.2015 for updation in case of merging  RD1K999364
*    APPEND wa_zmm_ims TO ist_zmm_ims_hdr.
    ""end of comment by lipsy on 16.12.2015 for updation in case of merging  RD1K999364

    """"""""""""""""""""""""""""""""""""""""""""""""""
    "added by lipsy for updation in case of merging  on 29.12.2015 RD1K999364

    SELECT * FROM zmm_ims INTO TABLE ist_zmm_ims_hdr
            WHERE trackno     = wa_zmm_ims-trackno  AND
                  tracktyp    = wa_zmm_ims-tracktyp.

    """end of addition by lipsy for updation in case of merging  on 29.12.2015 RD1K999364
    """"""""""""""""""""""""""""""""""""""""""""""



    PERFORM chk_src_trackno USING wa_zmm_ims-trackno
                                  wa_zmm_ims-tracktyp.

    IF NOT ist_zmm_ims_status[] IS INITIAL.

      READ TABLE ist_zmm_ims_status INTO wa_zmm_ims_status_t INDEX 1.

    ELSE.
*+012 : End

      l_sy_subrc = 4.

    ENDIF.

*   ENDIF.                                                  "-012

    IF l_sy_subrc = 4.

      p_sy_subrc = 4.

    ELSE.

      REFRESH : ist_zmm_ims_status.

      IF NOT ist_trackno[] IS INITIAL.

        SELECT * FROM zmm_ims_status INTO TABLE ist_zmm_ims_status
                  FOR ALL ENTRIES IN ist_trackno
                      WHERE trackno = ist_trackno-trackno.

        IF sy-subrc = 0.

          CLEAR : g_tstamp.

          l_first = '1'.                                    "+012

          PERFORM get_timestamp CHANGING g_tstamp.

          LOOP AT ist_zmm_ims_status INTO wa_zmm_ims_status.

*+012 : Start
            PERFORM upd_merged_trackno USING    wa_zmm_ims_status_t
                                       CHANGING wa_zmm_ims_status.

            IF l_first = '1'.

*+018 : Start
              CLEAR l_invoiceval.

              SELECT INVOICEVAL FROM ZMM_IMS INTO L_INVOICEVAL UP TO 1 ROWS
 WHERE TRACKNO = WA_ZMM_IMS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*+018 : End

*-018 : Start
*              IF g_merged_found = 'X'.
*
*                MOVE wa_zmm_ims-invoiceval TO l_invoiceval.
*
*              ELSE.
*
*                MOVE wa_zmm_ims_status_t-invoiceval TO l_invoiceval.
*
*              ENDIF.
*-018 : End
              CLEAR l_first.

            ENDIF.

            l_invoiceval = l_invoiceval +
                           wa_zmm_ims_status-invoiceval.
*+012 : End

*-012 : Start
*            MOVE wa_zmm_ims_status-trackno  TO l_trackno.
*            MOVE wa_zmm_ims_status-tracktyp TO l_tracktyp.
*            MOVE wa_zmm_ims_status-trackdt  TO l_trackdt.
*
*            MOVE wa_zmm_ims_status_t TO wa_zmm_ims_status.
*
*            MOVE l_trackno  TO wa_zmm_ims_status-trackno.
*            MOVE l_tracktyp TO wa_zmm_ims_status-tracktyp.
*            MOVE l_trackdt  TO wa_zmm_ims_status-trackdt.
*
*            MOVE wa_zmm_ims_status_t-trackno
*                            TO wa_zmm_ims_status-ref_trackno.
*
*            MOVE g_tstamp   TO wa_zmm_ims_status-timestamp.
*
*            MOVE sy-uname   TO wa_zmm_ims_status-merged_by.
*            MOVE sy-datum   TO wa_zmm_ims_status-merged_on.
*-012 : End

            MODIFY ist_zmm_ims_status FROM wa_zmm_ims_status
                          INDEX sy-tabix.

          ENDLOOP.

        ENDIF.

      ENDIF.

      IF NOT ist_zmm_ims_status[] IS INITIAL.

        MOVE g_tstamp     TO wa_zmm_ims_status_t-timestamp. "+012
        MOVE l_invoiceval TO wa_zmm_ims_status_t-invoiceval. "+012

        APPEND wa_zmm_ims_status_t TO ist_zmm_ims_status.   "+012

        MODIFY zmm_ims_status FROM TABLE ist_zmm_ims_status.

        IF sy-subrc = 0.

          COMMIT WORK.

          MESSAGE s839(zmm).

        ENDIF.

      ELSE.

        MESSAGE i022(06).

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " MERGE_IMS_TRACK_NOS

*&---------------------------------------------------------------------*
*&      Form  CHK_DUP_INVOICE_ENRTY
*&---------------------------------------------------------------------*
* To check duplicate invoice entry
*----------------------------------------------------------------------*
FORM chk_dup_invoice_enrty CHANGING p_ret.

  DATA : wa_ims_t TYPE zmm_ims.
  DATA : l_ans(1).

*+017 : For 506* POs & contract tracking nos, invoice number has
*       to be checked
  DATA : BEGIN OF wa_ebeln,
           ebeln TYPE ekko-ebeln,
         END OF wa_ebeln.

  DATA : ist_ebeln LIKE TABLE OF wa_ebeln,
         ist_ims_t LIKE TABLE OF zmm_ims.

  DATA : l_konnr TYPE ekko-konnr.
*+017 : End

*14.06.2013 : Start
  IF wa_zmm_ims-invoiceval EQ 0.

    MESSAGE i543(zmm) WITH text-067.
    p_ret = '2'.

  ENDIF.

  IF g_rb_mat = 'X' OR g_rb_srv = 'X'.
*14.06.2013 : End

    IF NOT wa_zmm_ims-ebeln IS INITIAL     AND
       NOT wa_zmm_ims-invoiceno IS INITIAL AND
       NOT wa_zmm_ims-invoicedt IS INITIAL.

      SELECT * FROM ZMM_IMS INTO WA_IMS_T UP TO 1 ROWS
 WHERE EBELN = WA_ZMM_IMS-EBELN AND INVOICENO = WA_ZMM_IMS-INVOICENO AND LVORM NE 'X'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc = 0.

*      MESSAGE w853(zmm) WITH wa_ims_t-trackno.
        MESSAGE e853(zmm) WITH wa_ims_t-trackno.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirm '(044)
            text_question         = text-043
            text_button_1         = 'Yes'
            text_button_2         = 'No'
            display_cancel_button = ' '
            default_button        = '2'
          IMPORTING
            answer                = l_ans
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        p_ret = l_ans.

*+017 : For 506* POs & contract tracking nos, invoice number has
*       to be checked
      ELSE.

        SELECT SINGLE konnr FROM ekko INTO l_konnr
            WHERE ebeln = wa_zmm_ims-ebeln.

        IF sy-subrc = 0.

          SELECT ebeln FROM ekab INTO TABLE ist_ebeln
              WHERE konnr = l_konnr.

          IF NOT ist_ebeln[] IS INITIAL.

            wa_ebeln-ebeln = l_konnr.
            APPEND wa_ebeln TO ist_ebeln.

            SELECT * FROM zmm_ims INTO TABLE ist_ims_t
                  FOR ALL ENTRIES IN ist_ebeln
                    WHERE ebeln     = ist_ebeln-ebeln AND
                          invoiceno = wa_zmm_ims-invoiceno AND
                          lvorm NE 'X' ORDER BY PRIMARY KEY.

            IF NOT ist_ims_t[] IS INITIAL.

              READ TABLE ist_ims_t INTO wa_ims_t INDEX 1.

              MESSAGE e853(zmm) WITH wa_ims_t-trackno.

            ENDIF.

          ENDIF.

        ENDIF.
*+017 : End

      ENDIF.

    ENDIF.

  ENDIF. "14.06.2013

ENDFORM.                    " CHK_DUP_INVOICE_ENRTY

*&---------------------------------------------------------------------*
*&      Form  update_data
*----------------------------------------------------------------------*
*   To update existing record in Z-table ZMM_IMS_STATUS
*   Screen : 0500
*----------------------------------------------------------------------*
FORM update_data_0500.

  CLEAR g_tstamp.

  PERFORM get_timestamp CHANGING g_tstamp.

  MOVE g_tstamp TO wa_zmm_ims_status-timestamp.

  MODIFY zmm_ims_status FROM wa_zmm_ims_status.

  IF sy-subrc = 0.

    COMMIT WORK.

    MESSAGE s793(zmm) WITH wa_zmm_ims-trackno.

  ELSE.

    MESSAGE e033(zpm).

  ENDIF.

  PERFORM unlock_record USING wa_zmm_ims-trackno
                              wa_zmm_ims-tracktyp.

ENDFORM.                    " update_data_0500

*&---------------------------------------------------------------------*
*&      Module  VALID_TRACKNO_0300  INPUT
*&---------------------------------------------------------------------*
* To validate tracking no. : Screen 0300
*----------------------------------------------------------------------*
MODULE valid_trackno_0300 INPUT.

  IF ist_zmm_ims_hdr[] IS INITIAL.

    g_first = 'X'.

  ENDIF.

ENDMODULE.                 " VALID_TRACKNO_0300  INPUT

*&---------------------------------------------------------------------*
*&      Form  CHK_SRC_TRACKNO
*&---------------------------------------------------------------------*
* To validate source tracking number : Merged Case
*----------------------------------------------------------------------*
*      -->P_TRACKNO  Tracking Number
*      -->P_TRACKTYP Tracking Type
*----------------------------------------------------------------------*
FORM chk_src_trackno  USING    p_trackno
                               p_tracktyp.

  DATA : wa_zmm_ims_hdr_t    TYPE zmm_ims,
         wa_zmm_ims_status_t TYPE zmm_ims_status.

  SELECT * FROM zmm_ims_status INTO TABLE ist_zmm_ims_status
              WHERE trackno   = p_trackno  AND
                    tracktyp  = p_tracktyp AND
                    mbli_asn  <> 'D'       AND
                    ref_trackno = ''.

  IF sy-subrc = 0.

    READ TABLE ist_zmm_ims_hdr INTO wa_zmm_ims_hdr_t INDEX 1.

    READ TABLE ist_zmm_ims_status INTO wa_zmm_ims_status_t INDEX 1.

    IF ( wa_zmm_ims_status_t-mblnr_liv IS INITIAL OR
         wa_zmm_ims_status_t-mbll_stat <> 'G' )       AND
       ( wa_zmm_ims_status_t-mblnr_inv IS INITIAL OR
         wa_zmm_ims_status_t-mbli_stat <> 'G' ).

      IF p_tracktyp = 'M'.

        IF wa_zmm_ims_hdr_t-ebeln+0(3) <> '405'.

          IF wa_zmm_ims_status_t-mblnr_stk IS INITIAL OR
             wa_zmm_ims_status_t-mbls_stat <> 'G'.

            REFRESH ist_zmm_ims_status.

          ENDIF.

        ENDIF.

      ELSEIF p_tracktyp = 'S'.

        IF wa_zmm_ims_status_t-mblnr_stk IS INITIAL OR
           wa_zmm_ims_status_t-mbls_stat <> 'G'.

          REFRESH ist_zmm_ims_status.

        ENDIF.

      ENDIF.

    ELSE.

      REFRESH ist_zmm_ims_status.

    ENDIF.

  ENDIF.

ENDFORM.                    " CHK_SRC_TRACKNO

*&---------------------------------------------------------------------*
*&      Form  CHK_MRG_TRACKNO
*&---------------------------------------------------------------------*
* To validate secondary tracking number : Merged Case
*----------------------------------------------------------------------*
*      -->P_TRACKNO  Tracking Number
*      -->P_TRACKTYP Tracking Type
*----------------------------------------------------------------------*
FORM chk_mrg_trackno  USING    p_trackno
                               p_tracktyp.

  DATA : wa_zmm_ims_hdr_t    TYPE zmm_ims,
         wa_zmm_ims_status_t TYPE zmm_ims_status.

  DATA : l_reqloc  TYPE zmm_ims-reqloc,
         l_bukrs_s TYPE zlocmst-bukrs,
         l_bukrs_m TYPE zlocmst-bukrs.

  SELECT SINGLE * FROM zmm_ims_status INTO wa_zmm_ims_dtl
               WHERE trackno  = p_trackno  AND
                     tracktyp = p_tracktyp AND
                     mbli_asn  <> 'D'.

  IF sy-subrc = 0.

    MOVE wa_zmm_ims_hdr TO wa_zmm_ims_hdr_t.

    MOVE wa_zmm_ims_dtl TO wa_zmm_ims_status_t.

    IF ( wa_zmm_ims_status_t-mblnr_liv IS INITIAL OR
         wa_zmm_ims_status_t-mbll_stat <> 'G' )       AND
       ( wa_zmm_ims_status_t-mblnr_inv IS INITIAL OR
         wa_zmm_ims_status_t-mbli_stat <> 'G' ).

      IF p_tracktyp = 'F'.

*Company code of source tracking number
        MOVE wa_zmm_ims-reqloc TO l_reqloc.

        IF l_reqloc IS INITIAL.
          MOVE wa_zmm_ims-trackno+6(3) TO l_reqloc.
        ENDIF.

        SELECT SINGLE bukrs FROM zlocmst INTO l_bukrs_s
             WHERE locid = l_reqloc.

*Company code of secondary tracking number
        SELECT SINGLE bukrs FROM zlocmst INTO l_bukrs_m
             WHERE locid = wa_zmm_ims_hdr_t-reqloc.

        IF l_bukrs_s <> l_bukrs_m.

          MESSAGE e878(zmm) WITH p_trackno.

        ENDIF.

      ENDIF.

    ELSE.

      MESSAGE e836(zmm).

    ENDIF.

  ELSE.

    MESSAGE e817(zmm).

  ENDIF.

ENDFORM.                    " CHK_MRG_TRACKNO

*&---------------------------------------------------------------------*
*&      Form  UPD_MERGED_TRACKNO
*&---------------------------------------------------------------------*
* To update data in merged tracking number with source tracking no.
*----------------------------------------------------------------------*
*      -->WA_ZMM_IMS_STATUS_S  Source tracking No.
*      <--WA_ZMM_IMS_STATUS_M  Merged tracking Nos.
*----------------------------------------------------------------------*
FORM upd_merged_trackno  USING p_zmm_ims_status_s TYPE zmm_ims_status
                      CHANGING p_zmm_ims_status_m TYPE zmm_ims_status.


  IF p_zmm_ims_status_s-tracktyp = 'M'.

*Inspection details
    IF p_zmm_ims_status_m-qccno IS INITIAL.
      MOVE p_zmm_ims_status_s-qccno TO p_zmm_ims_status_m-qccno.
      MOVE p_zmm_ims_status_s-qccdt TO p_zmm_ims_status_m-qccdt.
      MOVE p_zmm_ims_status_s-qcc_stat TO p_zmm_ims_status_m-qcc_stat.
    ENDIF.

*    IF p_zmm_ims_status_m-qccdt IS INITIAL.
*      MOVE p_zmm_ims_status_s-qccdt TO p_zmm_ims_status_m-qccdt.
*    ENDIF.
*
*    IF p_zmm_ims_status_m-qcc_stat IS INITIAL.
*      MOVE p_zmm_ims_status_s-qcc_stat TO p_zmm_ims_status_m-qcc_stat.
*    ENDIF.

*Inward entry
    IF p_zmm_ims_status_m-inwno IS INITIAL.
      MOVE p_zmm_ims_status_s-inwno TO p_zmm_ims_status_m-inwno.
      MOVE p_zmm_ims_status_s-inwdt TO p_zmm_ims_status_m-inwdt.
      MOVE p_zmm_ims_status_s-inw_stat TO p_zmm_ims_status_m-inw_stat.
    ENDIF.

*    IF p_zmm_ims_status_m-inwdt IS INITIAL.
*      MOVE p_zmm_ims_status_s-inwdt TO p_zmm_ims_status_m-inwdt.
*    ENDIF.
*
*    IF p_zmm_ims_status_m-inw_stat IS INITIAL.
*      MOVE p_zmm_ims_status_s-inw_stat TO p_zmm_ims_status_m-inw_stat.
*    ENDIF.

*GRV at Receipt Section(103)
    IF p_zmm_ims_status_m-mblnr_rcpt IS INITIAL.
      MOVE p_zmm_ims_status_s-mblnr_rcpt
                            TO p_zmm_ims_status_m-mblnr_rcpt.
      MOVE p_zmm_ims_status_s-mblnr_rcpt_dt
                            TO p_zmm_ims_status_m-mblnr_rcpt_dt.
      MOVE p_zmm_ims_status_s-mblr_stat
                            TO p_zmm_ims_status_m-mblr_stat.
    ENDIF.

*    IF p_zmm_ims_status_m-mblnr_rcpt_dt IS INITIAL.
*      MOVE p_zmm_ims_status_s-mblnr_rcpt_dt
*                            TO p_zmm_ims_status_m-mblnr_rcpt_dt.
*    ENDIF.
*
*    IF p_zmm_ims_status_m-mblr_stat IS INITIAL.
*      MOVE p_zmm_ims_status_s-mblr_stat
*                            TO p_zmm_ims_status_m-mblr_stat.
*    ENDIF.

*GRV at Store Section(105)
    IF p_zmm_ims_status_m-mblnr_stk IS INITIAL.
      MOVE p_zmm_ims_status_s-mblnr_stk
                            TO p_zmm_ims_status_m-mblnr_stk.
      MOVE p_zmm_ims_status_s-mblnr_stk_dt
                            TO p_zmm_ims_status_m-mblnr_stk_dt.
      MOVE p_zmm_ims_status_s-mbls_stat
                            TO p_zmm_ims_status_m-mbls_stat.
    ENDIF.

*    IF p_zmm_ims_status_m-mblnr_stk_dt IS INITIAL.
*      MOVE p_zmm_ims_status_s-mblnr_stk_dt
*                            TO p_zmm_ims_status_m-mblnr_stk_dt.
*    ENDIF.
*
*    IF p_zmm_ims_status_m-mbls_stat IS INITIAL.
*      MOVE p_zmm_ims_status_s-mbls_stat
*                            TO p_zmm_ims_status_m-mbls_stat.
*    ENDIF.

  ELSEIF p_zmm_ims_status_s-tracktyp = 'S'.

*Service Enrty Sheet
    IF p_zmm_ims_status_m-mblnr_stk IS INITIAL.
      MOVE p_zmm_ims_status_s-mblnr_stk
                            TO p_zmm_ims_status_m-mblnr_stk.
      MOVE p_zmm_ims_status_s-mblnr_stk_dt
                            TO p_zmm_ims_status_m-mblnr_stk_dt.
      MOVE p_zmm_ims_status_s-mbls_stat
                            TO p_zmm_ims_status_m-mbls_stat.
    ENDIF.

*    IF p_zmm_ims_status_m-mblnr_stk_dt IS INITIAL.
*      MOVE p_zmm_ims_status_s-mblnr_stk_dt
*                            TO p_zmm_ims_status_m-mblnr_stk_dt.
*    ENDIF.
*
*    IF p_zmm_ims_status_m-mbls_stat IS INITIAL.
*      MOVE p_zmm_ims_status_s-mbls_stat
*                            TO p_zmm_ims_status_m-mbls_stat.
*    ENDIF.

  ENDIF.

  MOVE p_zmm_ims_status_s-trackno
                  TO p_zmm_ims_status_m-ref_trackno.

  MOVE g_tstamp   TO p_zmm_ims_status_m-timestamp.

  MOVE sy-uname   TO p_zmm_ims_status_m-merged_by.
  MOVE sy-datum   TO p_zmm_ims_status_m-merged_on.

ENDFORM.                    " UPD_MERGED_TRACKNO

*&---------------------------------------------------------------------*
*&      Form  UPD_IMS_INVVAL
*&---------------------------------------------------------------------*
*To update invoice value of the tracking no. in DB table ZMM_IMS_STATUS
*----------------------------------------------------------------------*
*      -->p_zmm_ims  IMS Header
*----------------------------------------------------------------------*
FORM upd_ims_invval USING p_zmm_ims STRUCTURE zmm_ims.

  DATA : wa_zmm_ims_status_u TYPE zmm_ims_status.

  DATA : l_invoiceval TYPE zmm_ims_status-invoiceval.

  SELECT * FROM ZMM_IMS_STATUS INTO WA_ZMM_IMS_STATUS_U UP TO 1 ROWS
 WHERE TRACKNO = P_ZMM_IMS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.

    IF wa_zmm_ims_status_u-mbll_stat = 'G' OR
       wa_zmm_ims_status_u-mbli_stat = 'G'.

      """"""""""""""""""""""""""""""""""""""""""""""""
      "commented by lipsy  for updation in case of merging  on 29.12.2015 RD1K999364

*    ELSEIF NOT wa_zmm_ims_status_u-ref_trackno IS INITIAL.

      ""end of comment for updation in case of merging  on 29.12.2015 RD1K999364"""""""""""""""""""""""""""""

    ELSE.

      "commented by lipsy for updation in case of merging  on 29.12.2015 RD1K999364
*      l_invoiceval = ( p_zmm_ims-invoiceval - g_invoiceval ) +
*                       wa_zmm_ims_status_u-invoiceval.

      "end of comment by lipsy for updation in case of merging  on 29.12.2015 RD1K999364




      """""""""""""""""""""""""""""""""""""""""
      "added by lipsy for updation in case of merging  on 29.12.2015 RD1K999364
      l_invoiceval = p_zmm_ims-invoiceval.

      "
      "for source track no if child trackno changed
      REFRESH:itab_value_imsst[].
      IF wa_zmm_ims_status_u-ref_trackno IS NOT INITIAL.
        SELECT * FROM zmm_ims_status INTO
           CORRESPONDING FIELDS OF TABLE itab_value_imsst
          WHERE trackno = wa_zmm_ims_status_u-ref_trackno.
        IF sy-subrc = 0.

          CLEAR:wa_value_imsst.
          LOOP AT itab_value_imsst INTO wa_value_imsst.
            wa_value_imsst-invoiceval = wa_value_imsst-invoiceval + l_invoiceval - g_invoiceval.
          ENDLOOP.

          UPDATE zmm_ims_status
                SET invoiceval = wa_value_imsst-invoiceval
                WHERE trackno = wa_zmm_ims_status_u-ref_trackno.

        ENDIF.
      ENDIF.
      " "for child track no if source trackno changed

      REFRESH:itab_value_imsst[].
      SELECT * FROM zmm_ims_status INTO
         CORRESPONDING FIELDS OF TABLE itab_value_imsst
        WHERE ref_trackno = p_zmm_ims-trackno.

      IF sy-subrc = 0.

        CLEAR:wa_value_imsst.
        LOOP AT itab_value_imsst INTO wa_value_imsst.
          l_invoiceval = wa_value_imsst-invoiceval + l_invoiceval.
        ENDLOOP.

      ENDIF.

      " "end of addition by lipsy for updation in case of merging  on 29.12.2015 RD1K999364
      """"""""""""""""""""""""""""""""""""""""""
      UPDATE zmm_ims_status
           SET invoiceval = l_invoiceval
               WHERE trackno = wa_zmm_ims_status_u-trackno.

********************************************************************************
*Begin 14.03.2024-CR4000000194-Incnt No 8000002622-SAP_ABAP(OVL Conslt)
*Save the Industry key & Industry key Name fields in the table ZMM_IMS_STATUS
      UPDATE zmm_ims_status
      SET BRSCH = wa_zmm_ims-BRSCH
      WHERE trackno = wa_zmm_ims_status_u-trackno.

      UPDATE zmm_ims_status
      SET BRTXT = wa_zmm_ims-BRTXT
      WHERE trackno = wa_zmm_ims_status_u-trackno.
*End 14.03.2024-CR4000000194-Incnt No 8000002622-SAP_ABAP(OVL Conslt)
********************************************************************************

    ENDIF.

  ENDIF.

ENDFORM.                    " UPD_IMS_INVVAL
*&---------------------------------------------------------------------*
*&      Form  CHK_CONTRACT
*&---------------------------------------------------------------------*
* To Check contract no. of different PO numbers
*----------------------------------------------------------------------*
*      -->P_EBELN_S Source PO
*      -->P_EBELN_T Target PO
*----------------------------------------------------------------------*
FORM chk_contract  USING    p_ebeln_s
                            p_ebeln_t.

  DATA : l_konnr_s TYPE ekab-konnr,
         l_konnr_t TYPE ekab-konnr.

  IF p_ebeln_s+0(3) = '506' AND p_ebeln_t+0(3) <> '506'.

    SELECT KONNR FROM EKAB INTO L_KONNR_S UP TO 1 ROWS
 WHERE EBELN = P_EBELN_S
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF l_konnr_s <> p_ebeln_t.

      MESSAGE e817(zmm).

    ENDIF.

  ELSEIF p_ebeln_s+0(3) <> '506' AND p_ebeln_t+0(3) = '506'.

    SELECT KONNR FROM EKAB INTO L_KONNR_T UP TO 1 ROWS
 WHERE EBELN = P_EBELN_T
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF p_ebeln_s <> l_konnr_t.

      MESSAGE e817(zmm).

    ENDIF.

  ELSEIF p_ebeln_s+0(3) = '506' AND p_ebeln_t+0(3)  = '506'.

    SELECT KONNR FROM EKAB INTO L_KONNR_S UP TO 1 ROWS
 WHERE EBELN = P_EBELN_S
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    SELECT KONNR FROM EKAB INTO L_KONNR_T UP TO 1 ROWS
 WHERE EBELN = P_EBELN_T
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF l_konnr_s <> l_konnr_t.

      MESSAGE e817(zmm).

    ENDIF.

  ELSEIF p_ebeln_s+0(3) <> '506' AND p_ebeln_t+0(3) <> '506'.

    IF p_ebeln_s <> p_ebeln_t.

      MESSAGE e817(zmm).

    ENDIF.

  ENDIF.

ENDFORM.                    " CHK_CONTRACT

*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_600
*&---------------------------------------------------------------------*
* To commit IMS tracking no. alongwith Balmer Lawrie bill in DB table
* ZMM_IMS_BILLADJ
*----------------------------------------------------------------------*
FORM save_data_600 .

  DATA : ist_zmm_ims_billadj TYPE TABLE OF zmm_ims_billadj,
         wa_zmm_ims_billadj  TYPE zmm_ims_billadj.



  LOOP AT ist_track_bl INTO wa_track_bl.

    MOVE-CORRESPONDING wa_track_bl TO wa_zmm_ims_billadj.

    MOVE sy-mandt TO wa_zmm_ims_billadj-mandt.
    MOVE sy-uname TO wa_zmm_ims_billadj-created_by.
    MOVE sy-datum TO wa_zmm_ims_billadj-created_on.

    APPEND wa_zmm_ims_billadj TO ist_zmm_ims_billadj.

  ENDLOOP.

  IF NOT ist_zmm_ims_billadj[] IS INITIAL.

    MODIFY zmm_ims_billadj FROM TABLE ist_zmm_ims_billadj.

    IF sy-subrc = 0.

      MESSAGE s939(zmm).

    ELSE.

      MESSAGE e033(zpm).

    ENDIF.

  ENDIF.

ENDFORM.                    " SAVE_DATA_600

*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_600
*&---------------------------------------------------------------------*
*User's Role / authorization check
*----------------------------------------------------------------------*
FORM auth_check_600 .

  DATA : l_bukrs TYPE pa0001-bukrs.

  DATA : l_agr_name    TYPE agr_users-agr_name,
         l_agr_name_1  TYPE agr_users-agr_name,
         l_agr_name_2  TYPE agr_users-agr_name,
         l_agr_name_3  TYPE agr_users-agr_name,
         l_agr_name_4  TYPE agr_users-agr_name,
         l_agr_name_5  TYPE agr_users-agr_name,
         l_agr_name_6  TYPE agr_users-agr_name,
         l_agr_name_7  TYPE agr_users-agr_name,
*+016 : start
         l_agr_name_8  TYPE agr_users-agr_name,
         l_agr_name_9  TYPE agr_users-agr_name,
         l_agr_name_10 TYPE agr_users-agr_name,
         l_agr_name_11 TYPE agr_users-agr_name,
         l_agr_name_12 TYPE agr_users-agr_name,
         l_agr_name_13 TYPE agr_users-agr_name,
         l_agr_name_14 TYPE agr_users-agr_name.
*+016 : end

  IF sy-uname+0(3) = 'CMM' OR
     sy-uname+0(3) = 'CFI' OR
     sy-uname = 'CAB_SPYADAV'.

  ELSE.

    SELECT BUKRS FROM PA0001 INTO L_BUKRS UP TO 1 ROWS
 WHERE PERNR = SY-UNAME AND ENDDA EQ '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc = 0.
*-016 : start
*      CONCATENATE text-060 'E0_' l_bukrs text-061 INTO
*                                             l_agr_name_1.
*      CONCATENATE text-060 'E1_' l_bukrs text-061 INTO
*                                             l_agr_name_2.
*      CONCATENATE text-060 'E2_' l_bukrs text-061 INTO
*                                             l_agr_name_3.
*      CONCATENATE text-060 'E3_' l_bukrs text-061 INTO
*                                             l_agr_name_4.
*      CONCATENATE text-060 'E4_' l_bukrs text-061 INTO
*                                             l_agr_name_5.
*      CONCATENATE text-060 text-062 l_bukrs text-061 INTO
*                                             l_agr_name_6.
*      l_agr_name_7 = text-063.
*-016 : End

*+016 : Additonal roles checks
      CONCATENATE text-065 text-060 'E0_' l_bukrs text-061 INTO
                                             l_agr_name_1.
      CONCATENATE text-065 text-060 'E1_' l_bukrs text-061 INTO
                                             l_agr_name_2.
      CONCATENATE text-065 text-060 'E2_' l_bukrs text-061 INTO
                                             l_agr_name_3.
      CONCATENATE text-065 text-060 'E3_' l_bukrs text-061 INTO
                                             l_agr_name_4.
      CONCATENATE text-065 text-060 'E4_' l_bukrs text-061 INTO
                                             l_agr_name_5.

      CONCATENATE text-065 text-066 '_' l_bukrs text-061 INTO
                                             l_agr_name_8.

      CONCATENATE text-064 text-060 'E0' INTO
                                          l_agr_name_9.
      CONCATENATE text-064 text-060 'E1' INTO
                                          l_agr_name_10.
      CONCATENATE text-064 text-060 'E2' INTO
                                          l_agr_name_11.
      CONCATENATE text-064 text-060 'E3' INTO
                                          l_agr_name_12.
      CONCATENATE text-064 text-060 'E4' INTO
                                          l_agr_name_13.
      CONCATENATE text-064 text-066 INTO  l_agr_name_14.
*016 : End

      SELECT SINGLE agr_name FROM agr_users INTO l_agr_name
                 WHERE agr_name = l_agr_name_1 OR
                       agr_name = l_agr_name_2 OR
                       agr_name = l_agr_name_3 OR
                       agr_name = l_agr_name_4 OR
                       agr_name = l_agr_name_5 OR
*                      agr_name = l_agr_name_6 OR           "-016
*                      agr_name = l_agr_name_7 OR           "-016
*+016 : start
                       agr_name = l_agr_name_8 OR
                       agr_name = l_agr_name_9 OR
                       agr_name = l_agr_name_10 OR
                       agr_name = l_agr_name_11 OR
                       agr_name = l_agr_name_12 OR
                       agr_name = l_agr_name_13 OR
                       agr_name = l_agr_name_14.
*+016 : end

      IF sy-subrc <> 0.
        MESSAGE e077(s#) WITH sy-tcode.
      ENDIF.

    ELSE.

      MESSAGE e077(s#) WITH sy-tcode.

    ENDIF.

  ENDIF.

ENDFORM.                    " AUTH_CHECK_600
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_IMS_MOBILENO  text
*----------------------------------------------------------------------*
FORM send_sms  USING    p_mobileno.
  DATA: http_client  TYPE REF TO if_http_client,
        g_invval(20) TYPE c.
*DATA: result_tab TYPE TABLE OF string.
  g_invval = wa_zmm_ims-invoiceval.
  CONDENSE g_invval.
  CLEAR: mob_no, msg, wf_string, result.
  CLEAR: l_result.
  REFRESH result_tab .

  CONCATENATE 'Your Tracking No is ' wa_zmm_ims-trackno
   'for PO' wa_zmm_ims-ebeln 'and invoice no ' wa_zmm_ims-invoiceno
   'and invoice value' g_invval
  INTO msg SEPARATED BY space.

*The sortie has been scheduled on &SORTIE_DT on &SCH_TIME to &DEST_PT.
*You are requested to report an hour before the departure time at &ORG_PT

  SHIFT p_mobileno LEFT DELETING LEADING '0'.
  CONCATENATE '91' wa_zmm_ims-mobileno INTO  mob_no.

  CLEAR wf_string .
  CONCATENATE
    'http://10.205.48.190:13013/cgi-bin/sendsms?'
    'username=ongc&password=ongc12&from=ONGC-OL&to=' mob_no
    '&text=' msg
    '&remLen=180'
  INTO wf_string .

*    CONCATENATE
*      'http://www.webservicex.net/SendSMS.asmx/SendSMSToIndia?MobileNumber=9968282226'
*      '&FromEmailAddress=kuamr_alokz@yahoo.com&Message=sortie reschd'
*    INTO  wf_string .

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

  MESSAGE i318(zol) WITH l_result. "0: Accepted for delivery
  REFRESH result_tab .
  SPLIT result AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .
ENDFORM.                    " SEND_SMS

*&---------------------------------------------------------------------*
*&      Form  DEL_IMS_LINE
*&---------------------------------------------------------------------*
* To delete a line from IMS tracking No.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM del_ims_line .

  LOOP AT ist_trackno INTO wa_trackno
                             WHERE sel = 'X'.
    APPEND wa_trackno TO ist_trackno_del.
  ENDLOOP.

  DELETE ist_trackno WHERE sel = 'X'.

ENDFORM.                    " DEL_IMS_LINE

*&---------------------------------------------------------------------*
*&      Form  CHK_FI_DOCNO
*&---------------------------------------------------------------------*
* To validate FI document before commit
*----------------------------------------------------------------------*
*      -->P_TRACKNO   Tracking No.
*      -->P_BUKRS     Company Code
*      -->P_AUGBL     FI Clearing document
*      -->P_AUGDT     FI Clearing date
*----------------------------------------------------------------------*
FORM chk_fi_docno  USING    p_trackno
                            p_bukrs
                            p_augbl
                            p_augdt.

  DATA : l_lifnr_in TYPE zmm_ims-lifnr,
         l_lifnr    TYPE zmm_ims-lifnr.

  DATA : l_blart TYPE bsak-blart.

  DATA : l_mblnr_liv TYPE zmm_ims_status-mblnr_liv.

  l_blart = 'K%'.

  CLEAR : l_lifnr_in,
                 l_lifnr.

  l_lifnr_in = p_trackno+0(6).

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = l_lifnr_in
    IMPORTING
      output = l_lifnr.

  SELECT SINGLE belnr FROM bsak INTO l_mblnr_liv
         WHERE bukrs = p_bukrs   AND
               lifnr = l_lifnr   AND
               augbl = p_augbl   AND
               augdt = p_augdt   AND
               blart LIKE l_blart.

  IF sy-subrc NE 0.

    SET CURSOR FIELD 'WA_TRACK_BL_TC-MBLNR_INV'
                      LINE zmm_ims_bl_ctrl-current_line.

    MESSAGE e239(zmm).

  ENDIF.

ENDFORM.                    " CHK_FI_DOCNO

*&---------------------------------------------------------------------*
*&      Form  CHK_CONTRACT_1
*&---------------------------------------------------------------------*
* To Check contract no. of different PO numbers
*----------------------------------------------------------------------*
*      -->P_EBELN_S Source PO
*      -->P_EBELN_T Target PO
*----------------------------------------------------------------------*
FORM chk_contract_1  USING  p_ebeln_s
                            p_ebeln_t.

  DATA : l_konnr_s TYPE ekab-konnr,
         l_konnr_t TYPE ekab-konnr.

  IF p_ebeln_s+0(3) = '501' AND p_ebeln_t+0(3) <> '501'.

    SELECT KONNR FROM EKAB INTO L_KONNR_S UP TO 1 ROWS
 WHERE EBELN = P_EBELN_S
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF l_konnr_s <> p_ebeln_t.

      MESSAGE e817(zmm).

    ENDIF.

  ELSEIF p_ebeln_s+0(3) <> '501' AND p_ebeln_t+0(3) = '501'.

    SELECT KONNR FROM EKAB INTO L_KONNR_T UP TO 1 ROWS
 WHERE EBELN = P_EBELN_T
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF p_ebeln_s <> l_konnr_t.

      MESSAGE e817(zmm).

    ENDIF.

  ELSEIF p_ebeln_s+0(3) = '501' AND p_ebeln_t+0(3)  = '501'.

    SELECT KONNR FROM EKAB INTO L_KONNR_S UP TO 1 ROWS
 WHERE EBELN = P_EBELN_S
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    SELECT KONNR FROM EKAB INTO L_KONNR_T UP TO 1 ROWS
 WHERE EBELN = P_EBELN_T
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF l_konnr_s <> l_konnr_t.

      MESSAGE e817(zmm).

    ENDIF.

  ELSEIF p_ebeln_s+0(3) <> '501' AND p_ebeln_t+0(3) <> '501'.

    IF p_ebeln_s <> p_ebeln_t.

      MESSAGE e817(zmm).

    ENDIF.

  ENDIF.

ENDFORM.                    " CHK_CONTRACT_1
*&---------------------------------------------------------------------*
*&      Form  NUMBER_SERIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM number_series USING l_lifnr CHANGING wa_zmm_ims-trackno .

  IF v_ims_no1 IS INITIAL.
    v_ims_no1 = '000001'.
  ELSE.
    v_ims_no1 =   v_ims_no1 + 1.
  ENDIF.


  CONCATENATE l_lifnr+4(6) wa_zmm_ims-reqloc+3(3) v_ims_no1
                     INTO wa_zmm_ims-trackno.
  CLEAR:wa_zmm_ims_no.
  READ TABLE itab_zmm_ims_no INTO wa_zmm_ims_no WITH KEY trackno = wa_zmm_ims-trackno.
  IF sy-subrc = 0.
    CLEAR: wa_zmm_ims-trackno.
    PERFORM number_series USING l_lifnr CHANGING wa_zmm_ims-trackno.
  ELSE.
  ENDIF.
ENDFORM.                    " NUMBER_SERIES
*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_IMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_TMS_SUBMI  text
*      -->P_WA_ZMM_IMS_OLD  text
*      -->P_WA_ZMM_IMS_CNEW  text
*----------------------------------------------------------------------*
FORM chng_doc_ims  USING    p_wa_zmm_ims_trackno
                            p_wa_zmm_ims_old
                            p_wa_zmm_ims_cnew.


  DATA : wa_zmm_o_ims_old  TYPE  zmm_ims,
         wa_zmm_n_ims_cnew TYPE  zmm_ims.


  DATA : ist_chngind_ims TYPE TABLE OF cdtxt WITH HEADER LINE.
  DATA : l_objectid_ims TYPE cdhdr-objectid.


  l_objectid_ims =  p_wa_zmm_ims_trackno.

  MOVE-CORRESPONDING  p_wa_zmm_ims_cnew  TO  wa_zmm_n_ims_cnew  .
  MOVE-CORRESPONDING p_wa_zmm_ims_old TO wa_zmm_o_ims_old .

  CALL FUNCTION 'ZMM_IMS_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid_ims
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
      object_change_indicator = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZMM_IMS      = ' '
      n_zmm_ims               = wa_zmm_n_ims_cnew
      o_zmm_ims               = wa_zmm_o_ims_old
      upd_zmm_ims             = 'U'
    TABLES
      icdtxt_zmm_ims          = ist_chngind_ims.

ENDFORM.                    " CHNG_DOC_IMS
*&---------------------------------------------------------------------*
*&      Module  GET_TRACKNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_trackno INPUT.
  SELECT trackno tracktyp FROM zmm_ims_status
  INTO CORRESPONDING FIELDS OF TABLE ist_tracklist
     WHERE mbll_stat <> 'G'
          AND mbli_stat <> 'G'.


*DELETE ist_tracklist WHERE trackno = ''.
*  SORT ist_tracklist BY trackno.
*  DELETE ADJACENT DUPLICATES FROM ist_tracklist.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TRACKNO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS_STATUS-TRACKNO'
      value_org       = 'S'
    TABLES
      value_tab       = ist_tracklist
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  wa_zmm_ims_status-trackno =  ist_return_tab-fieldval.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  CHK_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2468   text
*----------------------------------------------------------------------*
FORM chk_status  USING    p_stat.

  DATA : zstat(30).
  CLEAR : zstat.
  SELECT * FROM zmm_ims_status
    WHERE trackno = wa_zmm_ims_status-trackno
    AND mbll_asn =  p_stat  .
  ENDSELECT.
  IF sy-subrc = 0.
    """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
    IF rad1 = 'X'.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      IF p_stat = 'D'.
        zstat = 'Fwd to Finance'.
      ELSEIF p_stat = 'A'.
        zstat = 'Fwd to indentor'.
      ENDIF.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      CONCATENATE 'Please ' zstat 'first.'  INTO l_msg SEPARATED BY space.
      MESSAGE l_msg TYPE 'E'.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
    ELSEIF rad2 = 'X'.
      IF p_stat = 'D'.
        zstat = 'Accept'.
      ELSEIF p_stat = 'A'.
        zstat = 'Return'.
        """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
        CONCATENATE 'Please ' zstat 'first.'  INTO l_msg SEPARATED BY space.
        MESSAGE l_msg TYPE 'E'.
      ENDIF.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
    ENDIF.
    """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""


*    CONCATENATE 'Please ' zstat 'first.'  INTO l_msg SEPARATED BY space.
*    MESSAGE l_msg TYPE 'E'.
  ELSE.
  ENDIF.

  """
  IF rad2 = 'X'.
    CLEAR  : ist_zmm_ims_rio1 ,wa_zmm_ims_rio1 .
    SELECT * FROM zmm_ims_rio INTO CORRESPONDING FIELDS OF TABLE  ist_zmm_ims_rio1
    WHERE trackno = wa_zmm_ims_status-trackno.
    SORT ist_zmm_ims_rio1 BY timestamp DESCENDING.
    READ TABLE ist_zmm_ims_rio1 INTO wa_zmm_ims_rio1 INDEX 1.
    IF wa_zmm_ims_rio1-qcc_asn = 'T'.

      IF p_stat = 'D'.
        zstat = 'Accept'.
        CONCATENATE 'Please ' zstat 'first.'  INTO l_msg SEPARATED BY space.
        MESSAGE l_msg TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

  """""



  IF p_stat = 'A'.
    SELECT * FROM zmm_ims_status
      WHERE trackno = wa_zmm_ims_status-trackno
      AND mbll_asn =  ' ' .
    ENDSELECT.
    IF sy-subrc = 0.
      CLEAR :  zstat.
      IF rad1 = 'X'.
        zstat = 'Disagree'.
      ELSEIF rad2 = 'X'.
        zstat = 'Return'.
      ENDIF.
      CONCATENATE 'Please ' zstat 'first.'  INTO l_msg SEPARATED BY space.
      MESSAGE l_msg TYPE 'E'.
    ELSE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_REMARKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_G_RET  text
*----------------------------------------------------------------------*
FORM chk_remarks  CHANGING p_ret.

  IF g_disagree_txt = ''.

    CLEAR : p_ret.

  ELSE.

    p_ret = text-078.

  ENDIF.
ENDFORM.

FORM chk_forwarded_to  USING    p_forwarded_to.
  IF p_forwarded_to = ' '.
    MESSAGE'Please enter the CPF' TYPE 'E'.
  ELSE.
  ENDIF.
ENDFORM.

FORM upd_ims_db_table  USING p_acpt.
  DATA : l_tstamp TYPE timestamp.
  DATA l_odate TYPE datum.
  CLEAR : l_tstamp.

  PERFORM get_timestamp CHANGING l_tstamp.

  IF NOT wa_zmm_ims_status-trackno IS INITIAL.

    MOVE l_tstamp TO wa_zmm_ims_status-timestamp.

*    DATA :  bukrs_c TYPE zmm_ims_status-bukrs.
*    CLEAR : bukrs_c.
*    SELECT SINGLE bukrs INTO bukrs_c FROM zmm_ims_status
*       WHERE trackno = wa_zmm_ims_status-trackno.

    MOVE l_tstamp TO wa_zmm_ims_rio-timestamp.
    MOVE wa_zmm_ims_status-trackno TO wa_zmm_ims_rio-trackno.
*    MOVE p_acpt  TO wa_zmm_ims_rio-qcc_asn.

    IF p_acpt = 'D'.
      MOVE sy-uname TO wa_zmm_ims_rio-disagree_by_in.
    ELSEIF p_acpt = 'A'.
      MOVE sy-uname TO wa_zmm_ims_rio-agree_by_in.
    ENDIF.

    MOVE sy-datum TO wa_zmm_ims_rio-zdate_on.
    MOVE sy-uzeit TO wa_zmm_ims_rio-ztime_at.
    MOVE g_disagree_txt TO wa_zmm_ims_rio-disagree_qc.
    MOVE zmm_ims_rio-forwarded_to TO wa_zmm_ims_rio-forwarded_to.
    MOVE 'OVL' TO wa_zmm_ims_rio-bukrs.
    """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
    IF rad2 = 'X'.
      IF p_acpt = 'D'.
        MOVE 'T'  TO wa_zmm_ims_rio-qcc_asn.
      ELSEIF p_acpt = 'A'.
        MOVE 'C'  TO wa_zmm_ims_rio-qcc_asn.
      ENDIF.
      MOVE zmm_ims_rio-zemail TO wa_zmm_ims_rio-zemail .
      MOVE 'Vendor' TO wa_zmm_ims_rio-ztype .

    ELSEIF rad1 = 'X'.
      MOVE p_acpt  TO wa_zmm_ims_rio-qcc_asn.
      MOVE 'ONGC' TO wa_zmm_ims_rio-ztype .
    ENDIF.
    """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
    MODIFY zmm_ims_rio FROM wa_zmm_ims_rio.



    """""""Added by anamika on 26/10/2018 for CR 6000000297 """""""
    IF p_acpt = 'D'.
      UPDATE zmm_ims_status
            SET mbll_asn = p_acpt
            mbli_asn  = p_acpt
             WHERE trackno = wa_zmm_ims_status-trackno.
    ELSEIF p_acpt = 'A'.
      CLEAR l_odate.
      SELECT SINGLE org_cr_dt INTO l_odate FROM zmm_ims_rio
                                 WHERE trackno = wa_zmm_ims_status-trackno AND
                                      ( org_cr_dt = ' ' OR org_cr_dt LE'19000101' ).
      IF sy-subrc = 0.

        CLEAR l_odate.
        SELECT ORG_CR_DT INTO WA_ZMM_IMS_RIO-ORG_CR_DT FROM ZMM_IMS_RIOUP TO 1 ROWS
 WHERE TRACKNO = WA_ZMM_IMS_STATUS-TRACKNO AND ( ORG_CR_DT <> ' ' OR ORG_CR_DT GT '19000101' )
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF sy-subrc NE 0 OR wa_zmm_ims_rio-org_cr_dt = '00000000'.

          SELECT TRACKDT INTO WA_ZMM_IMS_RIO-ORG_CR_DT FROM
 ZMM_IMS_STATUS UP TO 1 ROWS WHERE TRACKNO = WA_ZMM_IMS_STATUS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        ENDIF.

        UPDATE zmm_ims_rio SET org_cr_dt = wa_zmm_ims_rio-org_cr_dt
                                   WHERE trackno = wa_zmm_ims_status-trackno AND
                                      ( org_cr_dt = ' ' OR org_cr_dt LE'19000101' ).
      ENDIF.
      IF rad1 = 'X'.
        UPDATE zmm_ims_status
               SET
               mbll_asn = ' '
               mbli_asn  = ' '
                WHERE trackno = wa_zmm_ims_status-trackno.
      ELSEIF rad2 = 'X'.
        UPDATE zmm_ims_status
            SET trackdt = sy-datum
            mbll_asn = ' '
            mbli_asn  = ' '
             WHERE trackno = wa_zmm_ims_status-trackno.
      ENDIF.

      IF rad2 = 'X'.
        UPDATE zmm_ims SET created_on = sy-datum status = ' ' financdt = '  ' WHERE trackno = wa_zmm_ims_status-trackno. "+<RD1K9A0CFR>
        UPDATE zmm_ims_status SET trackdt  = sy-datum status = ' ' financdt = '  ' WHERE trackno = wa_zmm_ims_status-trackno.
        DELETE FROM zmm_ims_rio WHERE trackno =  wa_zmm_ims_status-trackno AND qcc_asn IN ('A' , 'D').
      ENDIF.


    ENDIF.
    """""""Added by anamika on 26/10/2018 for CR 6000000297 """""""
    IF sy-subrc = 0.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      IF rad1 = 'X'.
*        PERFORM send_sap_mail USING wa_zmm_ims_rio.
      ELSEIF rad2 = 'X'.
*        PERFORM send_vendor_mail USING wa_zmm_ims_rio.
      ENDIF.

      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      COMMIT WORK.

      MESSAGE i227(zmm).

      CLEAR : wa_zmm_ims_status ,zmm_ims_rio-forwarded_to,g_disagree_txt,
            wa_zmm_ims_status-trackno, zmm_ims_rio-zemail.
      CLEAR : wa_zmm_ims_rio-timestamp,wa_zmm_ims_rio-qcc_asn,wa_zmm_ims_rio-disagree_by_in,
   wa_zmm_ims_rio-agree_by_in,wa_zmm_ims_rio-zdate_on,wa_zmm_ims_rio-ztime_at,
   wa_zmm_ims_rio-disagree_qc,wa_zmm_ims_rio-forwarded_to,wa_zmm_ims_rio-bukrs,zmm_ims_rio-zemail.

      LEAVE TO SCREEN 0.
    ELSE.

      ROLLBACK WORK.

      MESSAGE i228(zmm).
      CLEAR : wa_zmm_ims_status ,zmm_ims_rio-forwarded_to,g_disagree_txt,
            wa_zmm_ims_status-trackno,zmm_ims_rio-zemail.
      CLEAR : wa_zmm_ims_rio-timestamp,wa_zmm_ims_rio-qcc_asn,wa_zmm_ims_rio-disagree_by_in,
   wa_zmm_ims_rio-agree_by_in,wa_zmm_ims_rio-zdate_on,wa_zmm_ims_rio-ztime_at,
   wa_zmm_ims_rio-disagree_qc,wa_zmm_ims_rio-forwarded_to,wa_zmm_ims_rio-bukrs,zmm_ims_rio-zemail.

      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  get_gem_invoice_no                                   "+019
*&---------------------------------------------------------------------*
*& Determines the GeM Invoice No. belonging to the Purchase Order and
*& moves it into WA_ZMM_IMS-GEM_INVOICE_NO, so that it is shown on the
*& screen without the user pressing F4 and is written to ZMM_IMS by the
*& MODIFY statements that already exist.
*& Only an EMPTY field is filled - a value stored on the record or
*& entered by the user is never overwritten, therefore the routine may
*& safely be called more than once.
*&---------------------------------------------------------------------*
FORM get_gem_invoice_no.                                    "+019

  DATA : lr_bsart  TYPE RANGE OF ekko-bsart,                "+019
         ls_bsart  LIKE LINE OF lr_bsart,                   "+019
         lr_procst TYPE RANGE OF ekko-procstat,             "+019
         ls_procst LIKE LINE OF lr_procst.                  "+019

* No PO, or the field is already filled - nothing to do
  IF wa_zmm_ims-ebeln          IS INITIAL OR                "+019
     wa_zmm_ims-gem_invoice_no IS NOT INITIAL.              "+019
    RETURN.                                                 "+019
  ENDIF.                                                    "+019

* Document type restriction   (*) comment out to deactivate
  CLEAR ls_bsart.                                           "+019
  ls_bsart-sign = 'I'. ls_bsart-option = 'EQ'.              "+019
  ls_bsart-low  = 'MMGM'. APPEND ls_bsart TO lr_bsart.      "+019
  ls_bsart-low  = 'MMGS'. APPEND ls_bsart TO lr_bsart.      "+019

* Processing state restriction (*) comment out to deactivate
  CLEAR ls_procst.                                          "+019
  ls_procst-sign = 'I'. ls_procst-option = 'EQ'.            "+019
  ls_procst-low  = '05'. APPEND ls_procst TO lr_procst.     "+019

* GeM invoice(s) of this PO. ZGEM_BILLDET is joined so that only numbers
* which pass MODULE check_geminv (MZMMIMSI01) can be proposed - otherwise
* the document could no longer be saved.
  SELECT DISTINCT i~gem_invoice_no                          "+019
    FROM zgem_bill AS i                                     "+019
    INNER JOIN ekko AS e                                    "+019
      ON i~order_id       EQ e~zgempo                       "+019
    INNER JOIN zgem_billdet AS d                            "+019
      ON d~gem_invoice_no EQ i~gem_invoice_no               "+019
    INTO TABLE @DATA(lt_gem)                                "+019
    WHERE e~ebeln    EQ @wa_zmm_ims-ebeln                   "+019
      AND e~bsart    IN @lr_bsart                           "+019
      AND e~procstat IN @lr_procst.                         "+019

  IF sy-subrc NE 0.                                         "+019
    RETURN.               " no GeM invoice for this PO      "+019
  ENDIF.                                                    "+019

  SORT lt_gem BY gem_invoice_no.                                    "+019
  DELETE ADJACENT DUPLICATES FROM lt_gem COMPARING gem_invoice_no.  "+019

  READ TABLE lt_gem INTO DATA(ls_gem) INDEX 1.              "+019
  IF sy-subrc EQ 0.                                         "+019
    wa_zmm_ims-gem_invoice_no = ls_gem-gem_invoice_no.      "+019
  ENDIF.                                                    "+019

* Inform the user when the proposal was not unambiguous
  IF lines( lt_gem ) GT 1.                                  "+019
    MESSAGE 'More than one GeM invoice exists for this PO - first one proposed' "+019
            TYPE 'S'.                                       "+019
  ENDIF.                                                    "+019

ENDFORM.                    " get_gem_invoice_no            "+019

