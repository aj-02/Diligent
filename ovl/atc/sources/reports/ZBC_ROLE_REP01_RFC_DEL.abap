*--- MAIN PROGRAM: ZBC_ROLE_REP01_RFC_DEL ---*
*&---------------------------------------------------------------------*
*& Report  ZBC_ROLE_REP01_RFC_DEL
*
*&                                                                     *
*&---------------------------------------------------------------------*
*& Program created for auth check & assinning/deletion roles
*& Modification of basis program for "End User Authorisations
*& Created by CAB_AJIT : AJIT SINGH                                    *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 184.
************************************************************************

REPORT  ZBC_ROLE_REP01_RFC_DEL            .

tables: zroledel_head,
         zroledel_item,
         agr_users,
         zauth_user,
         usr02,
         agr_define.

 data: begin of itab occurs 0,
         roledel_req_no type zroledel_head-roledel_req_no,
         roledel_req_date type zroledel_head-roledel_req_date,
         requested_by type zroledel_head-requested_by,
         released_on type zroledel_head-released_on,
         approved_by like zroledel_head-approved_by,
         approved_on like zroledel_head-approved_on,
         deleted_by type zroledel_head-deleted_by,
         deleted_on type zroledel_head-deleted_on,
         remarks(80),
         remarks1(20),
         expcnt type i,
       end of itab.
 data: bdcdata like bdcdata occurs 0 with header line.
 data: nodata(1) value '/'.
 data: messtab like bdcmsgcoll occurs 0 with header line.

*****cab_akshay for multiple entries deletion***************************
 data: wa_agr_users like agr_users .
 data: counter type i .
*****end****************************************************************

 data: l_module like zusrmst-primary_module.
 data: begin of dtab occurs 0,
         roledel_req_no type zroledel_item-roledel_req_no,
         cpf_no      type zroledel_item-cpf_no,
         role        type zroledel_item-role,
*  Start of changes made by CBC_BHATIABS for inclusion of from/to fields
*  on 05-10-2006
         from_dat    TYPE zroledel_item-from_dat,
         to_dat      TYPE zroledel_item-to_dat,
*  End of changes made by CBC_BHATIABS for inclusion of from/to fields
*  on 05-10-2006
       end of dtab.

 data: begin of etab occurs 0,
         roledel_req_no type zroledel_item-roledel_req_no,
         cpf_no      type zroledel_item-cpf_no,
         role        type zroledel_item-role,
*  Start of changes made by CBC_BHATIABS for inclusion of from/to fields
*  on 05-10-2006
         from_dat    TYPE zroledel_item-from_dat,
         to_dat      TYPE zroledel_item-to_dat,
*  End of changes made by CBC_BHATIABS for inclusion of from/to fields
*  on 05-10-2006
      end of etab.

 types: begin of tab_type,
         fcode like rsmpe-func,
       end of tab_type.

 data: tab type standard table of tab_type with
                non-unique default key initial size 10,
       wa_tab type tab_type.
 data: tab1(50) occurs 0 with header line.

 clear tab.

data : auth_req_no like zauth_head-auth_req_no.

DATA  check_flag.

get parameter id 'ZROLEREQNO' field auth_req_no.

perform check_auth.
break cab_rama.
if check_flag <> 'X'.

  perform select_data using auth_req_no.

  data: l_date(10) type c .
  clear l_date .

  if itab-released_on is initial and itab-roledel_req_no ne space .
     update zroledel_head set released_on = sy-datum where
         roledel_req_no = itab-roledel_req_no.
     itab-released_on = sy-datum.
     write itab-released_on dd/mm/yyyy to l_date .
     itab-released_on = l_date .
     itab-requested_by = sy-uname .
     itab-remarks1 = 'Request Released'.

  endif.

  if itab-released_on ne '00000000' and
      itab-approved_on eq '00000000' and
      itab-roledel_req_no ne space.
     update zroledel_head set approved_on = sy-datum
                           approved_by = sy-uname
         where
         roledel_req_no = itab-roledel_req_no.
     itab-approved_on = sy-datum.
     write itab-approved_on dd/mm/yyyy to l_date .
     itab-approved_on = l_date .
     itab-approved_by = sy-uname.
     itab-remarks1 = 'Request Approved'.

  endif.

CALL FUNCTION 'ZXX_SU03'
*  DESTINATION 'CLNT200_V'
     DESTINATION 'ROLE_ASN_RFC'
  EXPORTING
    AUTH_REQ_NO                 = auth_req_no
 EXCEPTIONS
   ROLE_ASSIGNMENT_ERROR       = 1
*   OTHERS                      = 2
          .
IF itab-deleted_on eq '00000000' and
      itab-deleted_by eq '' and
      auth_req_no ne space.

  update zroledel_head set
           deleted_on = sy-datum
           deleted_by = sy-uname where
           roledel_req_no = itab-roledel_req_no.
  message i058(zbc) with auth_req_no.

else.

   message i059(zbc) with auth_req_no.

ENDIF.
**************************************************
else.

  clear check_flag.
  message i057(zbc).

endif.

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
* select single * from zauth_user where bname = sy-uname.
 SELECT * FROM ZAUTH_USER   UP TO 1 ROWS WHERE BNAME = SY-UNAME  ORDER
BY  BNAME PRIMARY_MODULE .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
   if sy-subrc eq 0.
     if zauth_user-approve_flag <> 'X'.
      message i054(zbc).
      check_flag = 'X'.
     endif.
   endif.

ENDFORM.                    " check_auth
*&---------------------------------------------------------------------*
*&      Form  select_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AUTH_REQ_NO  text
*----------------------------------------------------------------------*

form select_data using auth_req_no like zauth_head-auth_req_no.
*Begin of <RD1K963151>.
IF SY-TCODE = 'ZDELEGATE'.
  IMPORT g_del_reqno TO auth_req_no FROM MEMORY ID 'ID3'.
  ENDIF.
*End of <RD1K963151>.
     select * from zroledel_head
     into
      corresponding fields of table itab
     where
       roledel_req_no = auth_req_no.

     loop at itab.
     endloop.

 endform.                    " select_data

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL
