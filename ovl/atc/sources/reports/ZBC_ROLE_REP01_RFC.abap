*--- MAIN PROGRAM: ZBC_ROLE_REP01_RFC ---*
*&---------------------------------------------------------------------*
*& Report  ZBC_ROLE_REP01_RFC                                          *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Program created for auth check & assinning roles
*& Modification of basis program for "End User Authorisations
*& CAB_AJIT : AJIT SINGH                                               *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 67.
************************************************************************

REPORT  zbc_role_rep01_rfc            .

TABLES : zauth_user,zauth_head.

DATA: BEGIN OF itab OCCURS 0,
        auth_req_no   TYPE zauth_head-auth_req_no,
        auth_req_date TYPE zauth_head-auth_req_date,
        requested_by  TYPE zauth_head-requested_by,
        released_on   TYPE zauth_head-released_on,
        approved_by   LIKE zauth_head-approved_by,
        approved_on   LIKE zauth_head-approved_on,
        created_by    TYPE zauth_head-created_by,
        created_on    TYPE zauth_head-created_on,
        remarks(80),
        remarks1(20),
        expcnt        TYPE i,
        mail          TYPE zauth_head-mail,
      END OF itab.

DATA : auth_req_no LIKE zauth_head-auth_req_no.
*DATA  zauth_head.
DATA  check_flag.

GET PARAMETER ID 'ZROLEREQNO' FIELD auth_req_no.

PERFORM check_auth.
break cab_rama.
IF check_flag <> 'X'.

  PERFORM select_data USING auth_req_no.

  DATA: l_date(10) TYPE c .
  CLEAR l_date .

  IF itab-released_on IS INITIAL AND itab-auth_req_no NE space.

    UPDATE zauth_head SET released_on = sy-datum WHERE
         auth_req_no = auth_req_no.
    WRITE itab-released_on DD/MM/YYYY TO l_date .
    itab-released_on = l_date .
    itab-requested_by = sy-uname .

    itab-remarks1 = 'Request Released'.

  ENDIF.

  IF itab-released_on NE '00000000' AND
      itab-approved_on EQ '00000000' AND
      itab-auth_req_no NE space.

*Begin of <RD1K963151>.
    DATA : zapprover LIKE zauth_head-approved_by.
    IMPORT zapprover TO zapprover FROM MEMORY ID 'ID1'.

*      update zauth_head set approved_on = sy-datum
*                               approved_by = sy-uname
*             where
*             auth_req_no = auth_req_no.
    UPDATE zauth_head SET approved_on = sy-datum
                             approved_by = zapprover
           WHERE
           auth_req_no = auth_req_no.
*End of <RD1K963151>.
    itab-approved_on = sy-datum.

    WRITE itab-approved_on DD/MM/YYYY TO l_date .
    itab-approved_on = l_date .

    itab-approved_by = sy-uname.
    itab-remarks1 = 'Request Approved'.

  ENDIF.

  CALL FUNCTION 'ZXX_SU02'
*  DESTINATION 'CLNT200_V'
    DESTINATION 'ROLE_ASN_RFC'
    EXPORTING
      auth_req_no           = auth_req_no
    EXCEPTIONS
      role_assignment_error = 1
*     OTHERS                = 2
    .
  IF itab-created_on EQ '00000000' AND
        itab-created_by EQ '' AND
        auth_req_no NE space.

    UPDATE zauth_head SET created_on = sy-datum
                             created_by = sy-uname
           WHERE
           auth_req_no = auth_req_no.
    IF sy-tcode <> 'ZDELEGATE'.
*      message i056(zbc) with auth_req_no.
    ENDIF.
    DATA :g_userid_n    TYPE persno,
          g_subuserid_n TYPE persno,
          l_cpf_no      TYPE zauth_item-cpf_no,
          l_from_dt     TYPE zauth_item-from_dat,
          l_to_dt       TYPE zauth_item-to_dat,
          l_flag_msg    TYPE c.

    CLEAR : l_flag_msg,g_userid_n,g_subuserid_n,l_cpf_no,l_from_dt,
l_to_dt.



" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
    SELECT cpf_no from_dat to_dat "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
         FROM zauth_item
 INTO (l_cpf_no, l_from_dt, l_to_dt)
         WHERE
            auth_req_no = auth_req_no AND to_dat NE sy-datum.
    ENDSELECT.
    g_userid_n = sy-uname.
*    G_USERID_n = G_USERID.
    g_subuserid_n = l_cpf_no.

    CALL FUNCTION 'ZMM_SEND_SMS'
      EXPORTING
        cpfno_s     = g_userid_n
        cpfno_r     = g_subuserid_n
        from_dat    = l_from_dt
        to_dat      = l_to_dt
        auth_req_no = auth_req_no
      IMPORTING
        flag_msg    = l_flag_msg.

    IF l_flag_msg = ''.
*      message i055(zbc) with auth_req_no.
    ENDIF.
  ENDIF.
**************************************************
ELSE.

  CLEAR check_flag.
  MESSAGE i057(zbc).

ENDIF.

*&---------------------------------------------------------------------*
*&      Form  check_auth
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_auth.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
*  SELECT SINGLE * FROM zauth_user WHERE bname = sy-uname.
 SELECT * FROM ZAUTH_USER   UP TO 1 ROWS WHERE BNAME = SY-UNAME  ORDER
BY  BNAME PRIMARY_MODULE .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
  IF sy-subrc EQ 0.

    IF zauth_user-approve_flag <> 'X'.
      MESSAGE i054(zbc).
      check_flag = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_auth
*&---------------------------------------------------------------------*
*&      Form  select_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AUTH_REQ_NO  text
*----------------------------------------------------------------------*

FORM select_data USING auth_req_no LIKE zauth_head-auth_req_no.
*Begin of <RD1K963151>.
  IF sy-tcode = 'ZDELEGATE'.
    IMPORT l_val TO auth_req_no FROM MEMORY ID 'ID2'.
  ENDIF.
*Begin of <RD1K963151>.
  SELECT * FROM zauth_head
  INTO
   CORRESPONDING FIELDS OF TABLE itab
  WHERE
    auth_req_no = auth_req_no.

  LOOP AT itab.
    SELECT COUNT(*) INTO itab-expcnt FROM zauth_excp
    WHERE auth_req_no = itab-auth_req_no.
    MODIFY itab.
  ENDLOOP.

ENDFORM.                    " select_data

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL
