*--- MAIN PROGRAM: SAPMZOVL_JV_CC_SUB ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SUB_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_exit .
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 9010.
    WHEN 'CANC'.
      LEAVE TO SCREEN 9010.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 9010.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REJ_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM rej_mail USING p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno .

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email       TYPE adr6-smtp_addr,
         bcs_exception TYPE REF TO cx_bcs.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.


  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been rejected for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).



    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
    CATCH cx_address_bcs.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
    CATCH cx_send_req_bcs INTO bcs_exception .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.



    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
    CATCH cx_send_req_bcs INTO bcs_exception .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
    CATCH cx_send_req_bcs INTO bcs_exception .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM fw_mail  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.


**  BOC by ss on 31.8.21

   IF gwa_jv_cc-FC_APPROVER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-FC_APPROVER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

**  EOC by ss on 31.8.21
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREA_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM crea_mail  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.
  DATA : message(100) TYPE c.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been created for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.

  REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

   SELECT SINGLE * FROM usr21 INTO v_user
    WHERE bname = GWA_JV_CC-PF_OFFICER.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.


**  BOC by ss on 31.8.21

  IF GWA_JV_CC-PRJ_MAN is not INITIAL.
  SELECT SINGLE * FROM usr21 INTO v_user   " for cc
    WHERE bname = GWA_JV_CC-PRJ_MAN.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

   IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

**  EOC by ss on 31.8.21
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
 CONCATENATE 'Request no' gwa_jv_cc-ccreqno 'created & mail sent successfully'
   INTO message SEPARATED BY space.


        MESSAGE message TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHNG_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM chng_mail  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

*  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
*    WHERE bname = @p_user.
*  SELECT SINGLE smtp_addr
*  FROM adr6
*  INTO p_email
*  WHERE persnumber = v_user-persnumber
*   AND  addrnumber = v_user-addrnumber.

 CONCATENATE 'Cash call request Changed:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been changed for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'The due date of payment is- ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please consider this as fund requirement intimation and arrange necessary funds.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @data(v_user)
    WHERE bname = @gwa_jv_cc-treasury1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury1.
  IF p_email IS NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
    TRY.
        lo_send_request->add_recipient(
            EXPORTING
            i_recipient = lo_recipient
            i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
    ENDTRY.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-treasury2.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury2.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

  CLEAR : p_email.

  IF gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-treasury3.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPR_MAIL_FC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM appr_mail_fc  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
   WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been concurred for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.


  CLEAR : p_email.

    IF gwa_jv_cc-RP_APPROVER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-RP_APPROVER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TREA_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM trea_mail  USING  p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been created for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'The due date of payment is- ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please consider this as fund requirement intimation and arrange necessary funds.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @gwa_jv_cc-treasury1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury1.
  IF p_email IS NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
    TRY.
        lo_send_request->add_recipient(
            EXPORTING
            i_recipient = lo_recipient
            i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
    ENDTRY.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-treasury2.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury2.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

  CLEAR : p_email.

  IF gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-treasury3.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
*        MESSAGE 'Mail Sent' TYPE 'S'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CNB_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM cnb_mail  USING  p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been approved by Competent Authority for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'Document no.' gwa_jv_cc-belnr 'posted for cash call due.The due date of payment is - ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please take necessary action for payment.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @data(v_user)
   WHERE bname = @gwa_jv_cc-cb_acc1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if p_email is NOT INITIAL.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-cb_acc1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  endif.

  CLEAR : p_email.
  IF gwa_jv_cc-cb_acc2 IS NOT INITIAL.
   SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-cb_acc2.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-cb_acc2.
    if p_email is NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
    TRY.
        lo_send_request->add_recipient(
        EXPORTING
        i_recipient = lo_recipient
        i_express = 'X'
        i_copy = abap_true ).
    ENDTRY.
    endif.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-cb_acc3 IS NOT INITIAL.
      SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-cb_acc3.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if p_email is NOT INITIAL.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-cb_acc3.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
    TRY.
        lo_send_request->add_recipient(
        EXPORTING
        i_recipient = lo_recipient
        i_express = 'X'
        i_copy = abap_true ).
    ENDTRY.
    ENDIF.
  ENDIF.

*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
*        MESSAGE 'Mail Sent' TYPE 'S'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPR_MAIL_RP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM appr_mail_rp  USING  p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been approved by Competent Authority for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'Document no.' gwa_jv_cc-belnr 'posted for cash call due.The due date of payment is - ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please take necessary action for payment/record keeping.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
 SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
   WHERE bname = @gwa_jv_cc-prj_cord.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-prj_cord.
    if p_email is NOT INITIAL.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  endif.



  CLEAR : p_email.
*  IF gwa_jv_cc-cb_acc3 IS NOT INITIAL.
*   SELECT SINGLE * FROM usr21 INTO v_user
*   WHERE bname = gwa_jv_cc-fc_approver.
*  SELECT SINGLE smtp_addr
*  FROM adr6
*  INTO p_email
*  WHERE persnumber = v_user-persnumber
*   AND  addrnumber = v_user-addrnumber.
**  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-prj_cord.
*    if p_email is NOT INITIAL.
**  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-pf_officer.
*  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*  TRY.
*      lo_send_request->add_recipient(
*      EXPORTING
*      i_recipient = lo_recipient
*      i_express = 'X'
*      i_copy = abap_true ).
*  ENDTRY.
*  ENDIF.


  CLEAR : p_email.
*  IF gwa_jv_cc-cb_acc3 IS NOT INITIAL.
   SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-pf_officer.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-prj_cord.
    if p_email is NOT INITIAL.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-fc_approver.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
  TRY.
      lo_send_request->add_recipient(
      EXPORTING
      i_recipient = lo_recipient
      i_express = 'X'
      i_copy = abap_true ).
  ENDTRY.
endif.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POST_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_doc .


DATA g_date(10).
 DATA: l_mstring(480).
data: amt TYPE p.
data: lv_sgtxt(50), lv_type(21). " added on 12.10.21

** BOC by ss on 19.7.21
*Check for cashcall type
*i.e. 1-Project cashcall,
*2-Marine JIB cashcall,
*3-Abandonment cashcall

** Added by ss on 12.10.21
IF GWA_JV_CC-CCTYPE eq 1.
  lv_type = 'Project Cashcall'.
  ELSEIF GWA_JV_CC-CCTYPE eq 2.
    lv_type = 'Marine JIB Cashcall'.
  ELSEIF GWA_JV_CC-CCTYPE eq 3.
  lv_type = 'Abandonment Cashcall'.
ENDIF.
CONCATENATE GWA_JV_CC-VNAME  lv_type 'for'  GWA_JV_CC-OPP_MONTH
INTO LV_SGTXT SEPARATED BY space.

**  EOC by ss on 12.10.21


if  GWA_JV_CC-cctype eq '3'.
clear amt.
amt = GWA_JV_CC-WRBTR.
  clear g_date.
CONCATENATE GWA_JV_CC-due_dt+6(2) '.' GWA_JV_CC-due_dt+4(2) '.' GWA_JV_CC-due_dt+0(4)
INTO g_date.
*perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWUM'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BKPF-BLDAT'
                              g_date.  " Due date
perform bdc_field       using 'BKPF-BLART'
                              'JC'.
perform bdc_field       using 'BKPF-BUKRS'
                              GWA_JV_CC-BUKRS.
clear g_date.
CONCATENATE GWA_JV_CC-post_dt+6(2) '.' GWA_JV_CC-post_dt+4(2) '.' GWA_JV_CC-post_dt+0(4)
INTO g_date.
perform bdc_field       using 'BKPF-BUDAT'
                              g_date.
*perform bdc_field       using 'BKPF-MONAT'
*                              '10'.
perform bdc_field       using 'BKPF-WAERS'
                              GWA_JV_CC-waers.
perform bdc_field       using 'BKPF-XBLNR'
                              GWA_JV_CC-ccreqno.
perform bdc_field       using 'BKPF-BKTXT'
                              GWA_JV_CC-ccreqno.
*perform bdc_field       using 'FS006-DOCID'
*                              '*'.
perform bdc_field       using 'RF05A-NEWBS'
                              '40'.  "'2A'. " added by ss on 19.7.21
perform bdc_field       using 'RF05A-NEWKO'
                               '91916'.  "GWA_JV_CC-PARTN.
*perform bdc_field       using 'RF05A-NEWUM'
*                              '~'.
perform bdc_dynpro      using 'SAPMF05A' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWKO'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BSEG-WRBTR'
                              GWA_JV_CC-WRBTR.
perform bdc_field       using 'BSEG-ZFBDT'
                              g_date.   " Due date
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                             lv_sgtxt. " 'JV CC'.  " added on 12.10.21
perform bdc_field       using 'RF05A-NEWBS'
                              '50'.
perform bdc_field       using 'RF05A-NEWKO'
                              '91299'.
perform bdc_field       using 'DKACB-FMORE'
                              'X'.

perform bdc_dynpro      using 'SAPLKACB' '0002'.

perform bdc_field       using 'BDC_CURSOR'
                              'COBL-PRCTR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using 'COBL-GSBER'
                              'JV'.
perform bdc_field       using 'COBL-PRCTR'
                              GWA_JV_CC-PRCTR.

perform bdc_dynpro      using 'SAPMF05A' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'BSEG-WRBTR'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BSEG-WRBTR'
                              GWA_JV_CC-WRBTR.
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                              lv_sgtxt. "'JV CC'.   " 12.10.21
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.
perform bdc_field       using 'DKACB-FMORE'
                              'X'.
perform bdc_dynpro      using 'SAPLKACB' '0002'.

perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using 'COBL-GSBER'
                              'JV'.
perform bdc_field       using 'COBL-PRCTR'
                              GWA_JV_CC-PRCTR.

** EOC by ss on 19.7.2021
else.
clear amt.
amt = GWA_JV_CC-WRBTR.
  clear g_date.
CONCATENATE GWA_JV_CC-due_dt+6(2) '.' GWA_JV_CC-due_dt+4(2) '.' GWA_JV_CC-due_dt+0(4)
INTO g_date.
*perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWUM'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BKPF-BLDAT'
                              g_date.
perform bdc_field       using 'BKPF-BLART'
                              'JC'.
perform bdc_field       using 'BKPF-BUKRS'
                              GWA_JV_CC-BUKRS.

clear g_date.
CONCATENATE GWA_JV_CC-post_dt+6(2) '.' GWA_JV_CC-post_dt+4(2) '.' GWA_JV_CC-post_dt+0(4)
INTO g_date.
perform bdc_field       using 'BKPF-BUDAT'
                              g_date.
*perform bdc_field       using 'BKPF-MONAT'
*                              '10'.
perform bdc_field       using 'BKPF-WAERS'
                              GWA_JV_CC-waers.
perform bdc_field       using 'BKPF-XBLNR'
                              GWA_JV_CC-ccreqno.
perform bdc_field       using 'BKPF-BKTXT'
                              GWA_JV_CC-ccreqno.
perform bdc_field       using 'FS006-DOCID'
                              '*'.
perform bdc_field       using 'RF05A-NEWBS'
                               '2A'.
perform bdc_field       using 'RF05A-NEWKO'
                               GWA_JV_CC-PARTN.
perform bdc_field       using 'RF05A-NEWUM'
                              '~'.
perform bdc_dynpro      using 'SAPMF05A' '0304'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWUM'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
if GWA_JV_CC-waers ne 'COP'.
perform bdc_field       using 'BSEG-WRBTR'
                               GWA_JV_CC-WRBTR.
else.
perform bdc_field       using 'BSEG-WRBTR'
                               amt.
ENDIF.
perform bdc_field       using 'BSEG-GSBER'
                              'JV'.
perform bdc_field       using 'BSEG-ZFBDT'
                               g_date.
perform bdc_field       using 'BSEG-PRCTR'
                               GWA_JV_CC-PRCTR.
perform bdc_field       using 'BSEG-FIPOS'
                              'PAYABLE'.
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                               lv_sgtxt."GWA_JV_CC-ccreqno.  " added on 12.10.2021
perform bdc_field       using 'RF05A-NEWBS'
                               '3A'.
perform bdc_field       using 'RF05A-NEWKO'
                               GWA_JV_CC-PARTN.
perform bdc_field       using 'RF05A-NEWUM'
                              ':'.
perform bdc_dynpro      using 'SAPMF05A' '0304'.
perform bdc_field       using 'BDC_CURSOR'
                              'BSEG-SGTXT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=AB'.
if GWA_JV_CC-waers ne 'COP'.
perform bdc_field       using 'BSEG-WRBTR'
                               GWA_JV_CC-WRBTR.
else.
perform bdc_field       using 'BSEG-WRBTR'
                               amt.
ENDIF.
perform bdc_field       using 'BSEG-GSBER'
                              'JV'.
perform bdc_field       using 'BSEG-ZFBDT'
                               g_date.
perform bdc_field       using 'BSEG-PRCTR'
                              GWA_JV_CC-PRCTR.
perform bdc_field       using 'BSEG-FIPOS'
                              'PAYABLE'.
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                              lv_sgtxt.  "'JV CC'." added on 12.10.21
perform bdc_dynpro      using 'SAPMF05A' '0700'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWBS'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.
*perform bdc_field       using 'BKPF-XBLNR'
*                              'CC'.
*perform bdc_field       using 'BKPF-BKTXT'
*                              'CC'.

endif. " Added by ss on 19.7.21

  DATA: l_mode(1).
  l_mode = 'E'.
DATA: ls_messtab TYPE bdcmsgcoll,
      ls_return  TYPE bapiret2.
 CALL TRANSACTION 'F-02' USING bdcdata
                   MODE   l_mode " 'A'  ""'E'  16052013  "'A'   "'N' "'E'   <RD1K975271> 01032011 28072012
                   UPDATE 'S'
                   MESSAGES INTO messtab.

 READ TABLE messtab WITH KEY MSGTYP = 'S'
                             MSGID  = 'F5'
                             MSGNR  = '312'.
 IF sy-subrc = 0.
  gwa_jv_cc-belnr = messtab-msgv1.

  else.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*   CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
*   TABLES
*   imt_bdcmsgcoll = messtab[]
*   ext_return  = bapiret2.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = ls_messtab-msgtyp
        cl     = ls_messtab-msgid
        number = ls_messtab-msgnr
        par1   = ls_messtab-msgv1
        par2   = ls_messtab-msgv2
        par3   = ls_messtab-msgv3
        par4   = ls_messtab-msgv4
      IMPORTING
        return = ls_return.
 APPEND ls_return TO bapiret2.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC

*Display messages from BAPIRET2
   CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
   TABLES
   it_return = bapiret2.

 ENDIF.
clear: bdcdata , messtab , bapiret2.
REFRESH: bdcdata,messtab , bapiret2.
ENDFORM.

FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                  " bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0831   text
*      -->P_0832   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
*  IF FVAL <> NODATA.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    SHIFT bdcdata-fval LEFT DELETING LEADING space.
    APPEND BDCDATA.
*  ENDIF.
ENDFORM.


FORM get_OTF_DATa TABLES i_objbin.
  DATA  g_att_files2 LIKE TABLE OF swotobjid.

  CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.
*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.

    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM zjv_cc_comm_log INTO TABLE git_clog WHERE ccreqno = gwa_jv_cc-ccreqno.

        CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*       g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
        g_att_files_wa-objtype = 'ATT'.
        g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

        APPEND g_att_files_wa TO g_att_files2.

         IF g_att_files2 IS NOT INITIAL.
               PERFORM GET_FILE .
         ENDIF.

      IF gwa_jv_cc-vtype = '1'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COMM'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF gwa_jv_cc-vtype = '2'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

      CALL FUNCTION v_fm
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          wa_req             = gwa_jv_cc
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
        TABLES
          it_log             = git_clog
          file_details1      = file_details1
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      ENDIF.
*      endif.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      li_otf[]  = gt_otf-otfdata[].
        CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
          max_linewidth         = 12376
*         ARCHIVE_INDEX         = ' '
*         copynumber            = copy
*         ASCII_BIDI_VIS2LOG    = ' '
*         PDF_DELETE_OTFTAB     = ' '
*         PDF_USERNAME          = ' '
        IMPORTING
          bin_filesize          = v_len_in
          bin_file              = v_bin_file
        TABLES
          otf                   = li_otf
          lines                 = li_pdf_tab
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          err_bad_otf           = 4
          OTHERS                = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = v_bin_file
*         APPEND_TO_TABLE       = ' '
*   IMPORTING
*         OUTPUT_LENGTH         =
        TABLES
          binary_tab = i_objbin[].

  endform.
*&---------------------------------------------------------------------*
*&      Form  DEL_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_MAIL .

    DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request Deletion:' gwa_jv_cc-CCREQNO INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.


  CONCATENATE '<tr><p>Cash Call request' gwa_jv_cc-CCREQNO 'has been deleted.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please cancel the fund requirement initiated earlier.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @gwa_jv_cc-treasury1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury1.
  IF p_email IS NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
    TRY.
        lo_send_request->add_recipient(
            EXPORTING
            i_recipient = lo_recipient
            i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
    ENDTRY.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-treasury2.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury2.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

  CLEAR : p_email.

  IF gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-treasury3.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.



    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
*        MESSAGE 'Mail Sent' TYPE 'S'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.

ENDFORM.

form chng_mail_pm USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno..
  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.
  DATA : message(100) TYPE c.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request Changed:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been changed for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.

  REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
 CONCATENATE 'Request no' gwa_jv_cc-ccreqno ' changed & mail sent successfully'
   INTO message SEPARATED BY space.


        MESSAGE message TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
  ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPR_MAIL_REV
*&---------------------------------------------------------------------*
FORM appr_mail_rev  USING    p_user TYPE uname
                             p_name type ad_namtext
                             p_reqno type zccreqno.



  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-fc_approver IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-fc_approver.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.




*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL_REV
*&---------------------------------------------------------------------*

FORM fw_mail_rev  USING p_user TYPE uname
                        p_name TYPE ad_namtext
                        p_reqno TYPE zccreqno.
   DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-reviewer IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-reviewer.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.











ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL1
*&---------------------------------------------------------------------*

FORM fw_mail1  USING  p_user TYPE uname
                      p_name TYPE ad_namtext
                      p_reqno TYPE zccreqno.

DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.

  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_JV_CC_FC_APPROVER  text
*      -->P_GV_NAME4  text
*      -->P_GWA_JV_CC_CCREQNO  text
*----------------------------------------------------------------------*
FORM  fw_mail2  USING  p_user TYPE uname
                      p_name TYPE ad_namtext
                      p_reqno TYPE zccreqno.

DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-FC_APPROVER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-FC_APPROVER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.

  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.

ENDFORM.

FORM GET_FILE.

   data neighbors   like neighbor occurs 0 with header line.
   DATA APPLICATION_OBJECT TYPE SWOTOBJID.

*DATA FILE_DETAILS1 LIKE sood5 occurs 0 WITH HEADER LINE.
data attachments like sood2 occurs 0 with header line.
data objhead     like soli  occurs 0 with header line.
data objcont     like soli  occurs 0 with header line.
data objpara     like selc  occurs 0 with header line.
data objparb     like soop1 occurs 0 with header line.
data exclude_tab like soxet occurs 0 with header line.
data sel_tab     like soxst occurs 0 with header line.
data fol_id      like soodk.
data obj_id      like soodk.
data obj_hd_dsp  like sood2.
data sel_count   like sy-tabix.
data next_func   like sy-ucomm.
data ok-code     like sy-ucomm.
data attach_size like sy-tabix.
data att_size_p  type p decimals 1.
data att_size_i  type i.
data page_rcode  like sonv-rcode.
data field_name(30).

data line_so910100 like sy-tabix value '6'.

* Data for note editor
  data objcont_save like soli  occurs 0 with header line.
  data objcont_help like soli  occurs 0 with header line.
* Table with content for editor call
  data: begin of content occurs 0,
           line(72),
        end of content.
  data objnam_save like sood2-objnam.
  data objdes_save like sood2-objdes.
  data f_update type c.
DATA APP_OBJECT    LIKE BORIDENT.
DATA FILTER        LIKE SOFOR.

constants:
      on  like sonv-flag value 'X',
      off like sonv-flag value ' '.

constants:
      ok  like sy-subrc value '00',
      cok like sy-subrc value '7000',  "return code = cancelled
      nok like sy-subrc value '9000',
      mok like sy-subrc value '8900'.

  MOVE-CORRESPONDING g_att_files_wa TO APPLICATION_OBJECT.
  MOVE-CORRESPONDING APPLICATION_OBJECT TO APP_OBJECT.
  CHECK NOT APP_OBJECT IS INITIAL.

  clear: neighbors, neighbors[].


 DATA: ls_object   TYPE SIBFLPORB,
       ls_logsys   TYPE LOGSYS.
*data attachments like sood5 occurs 0 with header line.

 DATA: lt_links    TYPE OBL_T_LINK.

 CONSTANTS: ls_relation TYPE OBLRELTYPE      VALUE 'ATTA',
            ls_catid_bo LIKE ls_object-catid VALUE 'BO'.
*            ls_role     TYPE OBLROLTYPE      VALUE 'APPLOBJ'.

 FIELD-SYMBOLS: <ls_links> TYPE OBL_S_LINK.

 MOVE: app_object-objkey  TO ls_object-instid,
       app_object-objtype TO ls_object-typeid,
       app_object-logsys  TO ls_logsys,
       ls_catid_bo        TO ls_object-catid.

 TRY.

   CALL METHOD cl_binary_relation=>read_links_of_binrel
     EXPORTING
       is_object    = ls_object
       ip_logsys    = ls_logsys
       ip_relation  = ls_relation
*       ip_role      = ls_role
*       ip_propnam   =
*       ip_no_buffer = SPACE
     IMPORTING
        et_links     = lt_links
*       et_roles     =
       .
    CATCH cx_obl_parameter_error .
    CATCH cx_obl_internal_error .
    CATCH cx_obl_model_error .
  ENDTRY.
  LOOP AT lt_links ASSIGNING <ls_links>.
    MOVE: <ls_links>-instid_b TO neighbors-objkey,
          <ls_links>-typeid_b TO neighbors-objtype.
    APPEND neighbors.
  ENDLOOP.

*}   INSERT
  CLEAR ATTACHMENTS. REFRESH ATTACHMENTS.

* LOOP AT RELATIONS.
  LOOP AT NEIGHBORS.
    MOVE ON TO FILTER-NOCONT.
*   MOVE RELATIONS-OBJKEY_B(17)    TO FOL_ID.
*   MOVE RELATIONS-OBJKEY_B+17(17) TO OBJ_ID.
    MOVE NEIGHBORS-OBJKEY(17)    TO FOL_ID.
    MOVE NEIGHBORS-OBJKEY+17(17) TO OBJ_ID.
    CALL FUNCTION 'SO_OBJECT_READ'
         EXPORTING
              FILTER            = FILTER
              FOLDER_ID         = FOL_ID
              OBJECT_ID         = OBJ_ID
              OWNER             = SY-UNAME
         IMPORTING
              OBJECT_HD_DISPLAY = OBJ_HD_DSP
         EXCEPTIONS
              OTHERS            = 1.
    IF SY-SUBRC EQ OK.
*   MOVE RELATIONS-OBJKEY_B(46)   TO ATTACHMENTS.
      MOVE NEIGHBORS-OBJKEY(46)     TO ATTACHMENTS.
      MOVE-CORRESPONDING OBJ_HD_DSP TO ATTACHMENTS.
      APPEND ATTACHMENTS.
    ENDIF.
  ENDLOOP.



  IF SY-SUBRC EQ 0.
    MOVE: ATTACHMENTS[] TO FILE_DETAILS1[].
  ELSE.

  ENDIF.

  LOOP AT FILE_DETAILS1 INTO DATA(WA_FILE_DETAILS).
*    wa_file_details-ownnam.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*    SELECT SINGLE NAME_LAST from USER_ADDR into @DATA(lv_fullname) where
*      BNAME eq @wa_file_details-ownnam.
    SELECT NAME_LAST from USER_ADDR UP TO 1 ROWS into @DATA(lv_fullname) where
      BNAME eq @wa_file_details-ownnam ORDER BY name_last. ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
      CLEAR wa_file_details-croadr.
      wa_file_details-croadr = lv_fullname.

    Modify file_details1 FROM wa_file_details TRANSPORTING CROADR WHERE ownnam = wa_file_details-ownnam.
    Clear : wa_file_details,lv_fullname.
  ENDLOOP.

 SORT FILE_DETAILS1 by CHDAT CHTIM ASCENDING.

ENDFORM.
