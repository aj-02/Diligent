REPORT zfi_rem_pyblck .
*-----  PROGRAM FOR Removing payment blocks 'X'  ****
***********************************************************************
* Program    :                                                        *
*                                                                     *
*                                                                     *
* Author     : S.R.Sudha                     Date : 14.03.2008
*
*                                                                     *
* Login Id   : CAB_SUDHA                                              *
*                                                                      *
* Description: For removing payment blocks in documents for vendor as *
*               per i/p
*  FS-no     : FS-FI-GL-41
*                                                                     *
* Tran.Code  : ZFIBLOCKX
*
*                                                                     *
***********************************************************************
*Change History
*By            ID   Login       FS  given By           Description
*       Date
*S.R.Sudha   +001   CAB_SUDHA   N.Mallikarjun          Paymnt Ref Added
*       4.4.2008
*S.R.Sudha   +002   CAB_SUDHA   N.Mallikarjun          JV Cash call Sp
*      22.04.2008                                 glPayment method added
*
*            +003   CAB_SUDHA   N.Mallikarjun           Req. of new
*  payment blocks   R- rejection, S- stale cheque , D - old lineitems
*                   auth object added
***********************************************************************
************************************************************************
*  Date         Transport   USERID          Description
* 19/12/2008  <RD1K960891> CAB_SUDHA  Payment block for customers
* 25.02.09  cab_rama        FS-FI-AP-083_01 30000782    001
* 28.10.2009 RD1K967585  CAB_ALOK     CR30002778, various validations for line items
*                                         in 'Payment Block from X to Blank' option,
*                                         Separate ALV for exception items,
*                                         Addition of INV REF & Subtotal in Reports,
*                                        Creation of activity logs in separate Z table.
* 09.03.2010 RD1K970594 CAB_ALOK      CR30003739: Correction in Invoice ref. logic,
*                                            Addition of 'Curr key' in reports
* 26.03.2010               SAB_SUMAN      30003849.
* 07.10.2010 RD1K973788 CAB_ALOK      CR 30004826 - Condition on kunnr
* 20.04.2010 RD1K975843 CAB_ALOK      CR 30005441 - Validations in view of CVP:
*                                     Validations based on:
*                                     payment method,
*                                     Add column for field Base Line and validate,
*                                     payment method in all linked documents,
*                                     business area - send complete document to exceptions,
*                                     joint validation of liability doc and credit memo.
*                                     Addition of Doc. no. in selection,
*                                     conditon 'Inconsistent PM in Docs' to be checked before
*                                     conditon 'Diff Pymt Method in vendor master'.
*                                     base line date to be placed before posting date field
*                                     CHANGE in due date check condition: all linked documents to go
*                                     to 'Exception'  if 1. RD > CD > LD & 2. RD > LD > CD, where CD - Current date
*                                     RD - Due date in Recovery document, LD - Due date in Liability document,
*                                     'X/BLANK  to S' was not updating table BSEG
* 05.08.2011 RD1K975843 CAB_ALOK      add field for Due date in exception tab after posting date field
*
*18.12.2015 <RD1K999458> CAB_RAMA(ANAMIKA) Warning message to avoid excess payment CR 30013754*
*                                                                                  *
*05.05.2016 <RD1K9A00LE> CAB_RAMA(ANAMIKA) Changes as per CR 30014262              *
*                                                                                  *
************************************************************************
*----------------------------------------------------------------------*
TYPE-POOLS : slis.
*Begin of <RD1K967585> CAB_ALOK 08.12.2009 CR30002778
*TABLES : bsik, t001, bkpf, bsid .
TABLES : bsik, t001, bkpf, bsid, zfi_rem_pyblck_l, vcnum . " ZFI_REM_PYBLCK_L for storing logs
*end of <RD1K967585> CAB_ALOK 08.12.2009 CR30002778
TYPES : BEGIN OF ST_budget,
          row(30) type c,
        END OF ST_budget.
data :ist_budget type standard table of st_budget,
      wa_budget  type st_budget.
DATA : ist_bsik  TYPE TABLE OF bsik.
DATA : ist_bseg TYPE TABLE OF  bseg.
DATA : wa_bsik  TYPE bsik.
DATA : wa_bseg TYPE  bseg.

DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .

DATA: BEGIN OF ist_bkpf OCCURS 0,
        blart LIKE bkpf-blart,
        belnr LIKE bkpf-belnr,
        bldat LIKE bkpf-bldat,
        budat LIKE bkpf-budat,
        waers LIKE bkpf-waers,
        usnam LIKE bkpf-usnam,
        ppnam LIKE bkpf-ppnam,
        gjahr LIKE bkpf-gjahr, "Added PN
        bukrs LIKE bkpf-bukrs, "Added PN
      END OF ist_bkpf.

DATA : BEGIN OF ist_srcbsik OCCURS 0 ,
         selcbox(1) TYPE c,
         lifnr      LIKE bsik-lifnr , "Vendor no.
         umskz      LIKE bsik-umskz,
         bukrs      LIKE bsik-bukrs ,  " company code
         gjahr      LIKE bsik-gjahr,
         belnr      LIKE bsik-belnr,  "Doc No.
         buzei      LIKE bsik-buzei,
         budat      LIKE bsik-budat,
         bschl      LIKE bsik-bschl,  " Posting Key
         zlsch      LIKE bsik-zlsch,    "Payment Method                      "+002
         zlspr      LIKE  bsik-zlspr,  " Payment Block Key
         shkzg      LIKE bsik-shkzg,   "Debit/Credit Indicator
         gsber      LIKE  bsik-gsber,
         dmbtr      LIKE bsik-dmbtr,
* Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
         subtot     TYPE p  DECIMALS 2,
* end of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
         wrbtr      LIKE bsik-wrbtr,
* begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
         waers      LIKE bsik-waers, " Currency Key
* end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
         kidno      LIKE  bsik-kidno,     " Payment Ref.                        "+001
         usnam      LIKE bkpf-usnam,
         xref1_hd   LIKE bkpf-xref1_hd,
         rebzg      LIKE bsik-rebzg,        " Invoice Ref.
         reason     TYPE string,
* begin RD1K975843 CAB_ALOK CR 30005441
         ZFBDT      type BSEG-ZFBDT, " due date/baseline date
* end RD1K975843 CAB_ALOK CR 30005441
*Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
*       activ(1),   " ambiguous
         inactiv(1),          " if X, then that line will be deactive
         netamt     LIKE bsik-dmbtr,
         serial_no  TYPE i,
         subgrp     TYPE i ,     "

*end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
         rebzz      type bsik-rebzz,
*{30007662
         blart      type bsik-blart,
         fipos      type bsik-fipos,
         fistl      type bsik-fistl,
*}30007662
*{
         ebeln      type bsik-ebeln,
         ebelp      type bsik-ebelp.
*}
*       include structure  bsis.
DATA:  END OF ist_srcbsik .
DATA : wa_srcbsik LIKE ist_srcbsik.
DATA : wa_srcbsik_l LIKE ist_srcbsik.



"""""""Added by Anamika on 21/12/2015 for RD1K999458""""
DATA : ist_srcbsik_copy LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : wa_srcbsik_copy LIKE ist_srcbsik.
"""""""Added by Anamika on 21/12/2015 for RD1K999458""""

"""""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
DATA : ist_ZFI_PAYREF_CC  TYPE TABLE OF ZFI_PAYREF_CC.
"""""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""


*Begin of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
DATA : ist_srcbsik_orig LIKE STANDARD TABLE OF ist_srcbsik .
DATA : wa_srcbsik_orig LIKE LINE OF ist_srcbsik_orig .
DATA : ist_srcbsik_inactiv LIKE STANDARD TABLE OF ist_srcbsik .
DATA : wa_srcbsik_inactiv LIKE LINE OF ist_srcbsik_inactiv.
*end of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : ist_debit LIKE ist_srcbsik OCCURS 0.
DATA : wa_debit  LIKE ist_srcbsik.
*-----------Start of <RD1K960891>
DATA : BEGIN OF ist_srcbsid OCCURS 0 ,
         selcbox(1) TYPE c,
         kunnr      LIKE bsid-kunnr ,   "customer no.
         umskz      LIKE bsid-umskz,
         bukrs      LIKE bsid-bukrs,
         gjahr      LIKE bsid-gjahr,
         belnr      LIKE bsid-belnr,    "Doc No.
         buzei      LIKE bsid-buzei,
         budat      LIKE bsid-budat,
         bschl      LIKE bsid-bschl,   " Posting Key
         zlsch      LIKE bsid-zlsch,   "Payment Method                            "+002
         zlspr      LIKE  bsid-zlspr,  " Payment Block Key
         shkzg      LIKE bsid-shkzg,   "Debit/Credit Indicator
         gsber      LIKE  bsid-gsber,
         dmbtr      LIKE bsid-dmbtr,
*Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
         subtot     TYPE p  DECIMALS 2,
*end of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
         wrbtr      LIKE bsid-wrbtr,
* begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
         waers      LIKE bsid-waers, " Currency Key
* end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
         kidno      LIKE  bsid-kidno,    " Payment Ref.                          "+001
         usnam      LIKE bkpf-usnam,
         xref1_hd   LIKE bkpf-xref1_hd,
         rebzg      LIKE bsid-rebzg,  " Invoice Ref.
         reason     TYPE string,
*Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
*       activ(1),   " ambiguous
         inactiv(1), " if X, then that line will be deactive
         netamt     LIKE bsid-dmbtr,
         serial_no  TYPE i,
         subgrp     TYPE i .     "
*end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
*       include structure  bsis.
DATA:  END OF ist_srcbsid .

DATA : wa_srcbsid LIKE ist_srcbsid.
*Begin of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
DATA : ist_srcbsid_orig LIKE STANDARD TABLE OF ist_srcbsid .
DATA : wa_srcbsid_orig LIKE LINE OF ist_srcbsid_orig .
DATA : ist_srcbsid_inactiv LIKE STANDARD TABLE OF ist_srcbsid .
DATA : wa_srcbsid_inactiv LIKE LINE OF ist_srcbsid_inactiv.
*end of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
DATA : ist_bsid  TYPE TABLE OF bsid.
DATA : wa_bsid  TYPE bsid.
*-----------End of <RD1K960891>

DATA : w_repid TYPE sy-repid.

DATA:  is_layout         TYPE  slis_layout_alv,
*begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
       is_layout_inactiv TYPE  slis_layout_alv,
*end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
       ist_fieldcat      TYPE  slis_fieldcat_alv  , "line.
       ist_fcat          TYPE  TABLE OF slis_fieldcat_alv,
       lt_sorttab        TYPE slis_t_sortinfo_alv,
       ls_sorttab        TYPE slis_sortinfo_alv. " sort structure for ALV
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*  ALV of inactive items: Inactive items to be shown in separate list.
DATA: ist_fieldcat_inactiv TYPE  slis_fieldcat_alv  , "work area.
      ist_fcat_inactiv     TYPE  TABLE OF slis_fieldcat_alv. "IST
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
DATA  : mpos TYPE i .
DATA : gt_list_top_of_page TYPE slis_t_listheader,
       gt_list_end_of_list TYPE slis_t_listheader,
       gt_events           TYPE slis_t_event.
*begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
DATA : gt_events_inactiv   TYPE slis_t_event.
DATA : pmtblock_to TYPE bsik-zlspr.
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778

* begin RD1K975843 CAB_ALOK CR 30005441
data: t_days_diff type i.
types: begin of TY_MSG,
         LIV_DOC(30),
         CREDIT_MEMO(30),
*          LIV_LIFNR type LIFNR,
*          LIV_BUKRS type BUKRS,
*          LIV_GJAHR type GJAHR,
*          LIV_BELNR type BSIK-BELNR,
*          CR_MEMO_BUKRS type BUKRS,
*          CR_MEMO_LIFNR type LIFNR,
*          CR_MEMO_BELNR type BSIK-BELNR,
       end of TY_MSG.
data: IST_MSG type STANDARD TABLE OF TY_MSG,
      WA_MSG  type TY_MSG.
* end RD1K975843 CAB_ALOK CR 30005441
DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
*{begin of 30007662
data :g_budget        type fmit-hsl16, "bseg-dmbtr,
      g_budget_c(16)," type bseg-dmbtr,
*            l_budget type bseg-dmbtr,
      g_dmbtr         type bseg-dmbtr,
      g_budget_d(25),"g_budget_d(16)
      g_budget_as(25),"g_budget_as(16)
      g_budget_av(25)."g_budget_av(16).
*}end of 30007662
SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.

SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,  "<RD1K960891>
                 s_kunnr FOR bsid-kunnr ,  "<RD1K960891>
                 s_year  FOR bsik-gjahr,
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778    "business area removed
*                 s_gsber FOR bsik-gsber,
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
                 s_budat FOR bsik-budat,
                 s_usnam FOR bkpf-usnam,
*  *Start of addition Prabu K on 06.07.2009
                 s_xref1 FOR bkpf-xref1_hd ,
*  End of addition Prabu K on 06.07.2009
* begin RD1K975843 CAB_ALOK      CR 30005441
                 S_BELNR FOR BSIK-BELNR.
* end RD1K975843 CAB_ALOK      CR 30005441
PARAMETERS : p_bukrs LIKE bsik-bukrs OBLIGATORY .

SKIP  2.

SELECTION-SCREEN : END OF BLOCK blk1.

SELECTION-SCREEN : BEGIN OF BLOCK  blk2 WITH FRAME.

SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(76) text-003 FOR FIELD p_x2sp.
PARAMETERS : p_x2sp RADIOBUTTON GROUP rad1 .
SELECTION-SCREEN END OF LINE.
SKIP.
SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(76) text-004 FOR FIELD p_sp2x.
PARAMETERS : p_sp2x RADIOBUTTON GROUP rad1 .
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(76) text-005 FOR FIELD p_sp2r.
PARAMETERS:  p_sp2r RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(76) text-006 FOR FIELD p_x2s.
PARAMETERS:   p_x2s  RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF LINE.
* Begin of RD1K971966 CAB_ALOK CR30004183
*SELECTION-SCREEN BEGIN OF  LINE .
*SELECTION-SCREEN COMMENT 2(76) text-007 FOR FIELD p_s2x.
*PARAMETERS:   p_s2x  RADIOBUTTON GROUP rad1.
*SELECTION-SCREEN END OF LINE.
* end of RD1K971966 CAB_ALOK CR30004183
*selection-screen begin of  line .
*SELECTION-SCREEN COMMENT 2(76) text-008 FOR FIELD p_sp2s.
*parameters:  p_sp2s RADIOBUTTON GROUP rad1.
*selection-screen end of line.
SELECTION-SCREEN : END OF BLOCK blk2.




CONSTANTS  : g_zlspr_x  LIKE bseg-zlspr  VALUE 'X',
             g_zlspr_sp LIKE bseg-zlspr VALUE ' ',
             g_zlspr_s  LIKE bseg-zlspr  VALUE 'S',
             g_zlspr_r  LIKE bseg-zlspr  VALUE 'R'.

* *Start of addition Prabu K on 11.07.2009
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-low.


  TYPES : BEGIN OF ty_t526,
            sachx TYPE sachx,
            werks TYPE sbmod,
          END OF ty_t526.

  TYPES: BEGIN OF ty_final,
           bukrs TYPE bukrs,
           persa TYPE persa,
           sachx TYPE sachx,
         END OF ty_final.
  TYPES: BEGIN OF ty_t5009,
           persa TYPE persa,
           bukrs TYPE bukrs,
         END OF ty_t5009.
  DATA: lv_area TYPE STANDARD TABLE OF ty_t526,
        wa_area LIKE LINE OF lv_area.

  DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009,
        wa_t5009 LIKE LINE OF  it_t5009.

  DATA: it_final TYPE STANDARD TABLE OF ty_final,
        wa_final LIKE LINE OF  it_final.

  SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER

  SORT lv_area BY sachx.
  DELETE ADJACENT DUPLICATES FROM lv_area
  COMPARING sachx.

*  select persa bukrs  from t500p into table it_t5009 for all entries
*                         in lv_area where persa = lv_area-sachx.

  SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.

  SORT it_t5009  BY persa.
  DELETE ADJACENT DUPLICATES FROM it_t5009
  COMPARING persa.

  LOOP AT lv_area INTO wa_area.

    READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
    wa_final-sachx = wa_area-sachx.
    wa_final-persa = wa_t5009-persa.
    wa_final-bukrs = wa_t5009-bukrs.
    APPEND wa_final TO it_final.
  ENDLOOP.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SACHX'
      dynpprog        = 'ZFI_REM_PYBLCK'
      dynpnr          = sy-dynnr
      dynprofield     = 'S_XREF1-LOW'
      value_org       = 'S'
    TABLES
      value_tab       = it_final
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
*
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-high.
  TYPES : BEGIN OF ty_t526,
            sachx TYPE sachx,
            werks TYPE sbmod,
          END OF ty_t526.

  TYPES: BEGIN OF ty_final,
           bukrs TYPE bukrs,
           persa TYPE persa,
           sachx TYPE sachx,
         END OF ty_final.
  TYPES: BEGIN OF ty_t5009,
           persa TYPE persa,
           bukrs TYPE bukrs,
         END OF ty_t5009.
  DATA: lv_area TYPE STANDARD TABLE OF ty_t526,
        wa_area LIKE LINE OF lv_area.

  DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009,
        wa_t5009 LIKE LINE OF  it_t5009.

  DATA: it_final TYPE STANDARD TABLE OF ty_final,
        wa_final LIKE LINE OF  it_final.

  SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER

  SORT lv_area BY sachx.
  DELETE ADJACENT DUPLICATES FROM lv_area
  COMPARING sachx.

*  select persa bukrs  from t500p into table it_t5009 for all entries
*                         in lv_area where persa = lv_area-sachx.

  SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.

  SORT it_t5009  BY persa.
  DELETE ADJACENT DUPLICATES FROM it_t5009
  COMPARING persa.

  LOOP AT lv_area INTO wa_area.

    READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
    wa_final-sachx = wa_area-sachx.
    wa_final-persa = wa_t5009-persa.
    wa_final-bukrs = wa_t5009-bukrs.
    APPEND wa_final TO it_final.
  ENDLOOP.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SACHX'
      dynpprog        = 'ZFI_REM_PYBLCK'
      dynpnr          = sy-dynnr
      dynprofield     = 'S_XREF1-HIGH'
      value_org       = 'S'
    TABLES
      value_tab       = it_final
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
*
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.
* End of addition Prabu K on 11.07.2009


AT SELECTION-SCREEN ON p_bukrs .
  SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e010(fi) WITH p_bukrs.
  ENDIF.
*---------Start of <RD1K960891>

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
              ID 'ACTVT' FIELD '02'
              ID 'BUKRS' FIELD p_bukrs.

  IF sy-subrc <> 0.
    MESSAGE  e091(8b) WITH p_bukrs.
  ENDIF.
*-----------End of <RD1K960891>

*------------------------------------------------------*
START-OF-SELECTION.
*------------------------------------------------------*
*---+003

* remove before TP
* IF NOT sy-uname = 'CAB_ALOK' .
  IF p_sp2r = 'X'.
    PERFORM authority_check USING '02' .
  ENDIF.
* ENDIF.
*----+003
*---+004
* remove before TP
*  IF NOT sy-uname = 'CAB_ALOK' .
  IF p_x2sp = 'X' OR  p_sp2x  = 'X'.
    PERFORM authority_check_x USING '02' .
  ENDIF.
*  ENDIF.
*---+004
*-----------Start of <RD1K960891>

  IF NOT s_lifnr  IS INITIAL.
    PERFORM get_docs.
    PERFORM validate_docs.
    PERFORM display_docs.
*Begin of <RD1K975843> CAB_ALOK CR 30005441
    PERFORM display_messages.
*end of <RD1K975843> CAB_ALOK CR 30005441
  ELSEIF  NOT s_kunnr IS INITIAL.
    PERFORM get_docs_cust.
    PERFORM validate_docs_cust.
    PERFORM display_docs_cust.
  ENDIF.
*-----------End of <RD1K960891>

*&---------------------------------------------------------------------*
*&      Form  display_docs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_docs.
  PERFORM init_fieldcat.
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*  make fieldcat for inactive items
  PERFORM init_fieldcat_inactiv.
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
  PERFORM eventtab_build TABLES gt_events.
  PERFORM comment_build TABLES gt_list_top_of_page.
  PERFORM  sort_build .
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*    PERFORM  print_alv.
*  display multiple list ALV
  PERFORM print_multi_alv..
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778

ENDFORM.                    " display_docs
*&---------------------------------------------------------------------*
*&      Form  init_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat.
  w_repid  = sy-repid.

  mpos = 0.
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'SELCBOX'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
*  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Select'.
*  ist_fieldcat-lowercase  = 'Y'.
  ist_fieldcat-checkbox = 'X'.
  ist_fieldcat-input = 'X'.
*  ist_fieldcat-edit = 'X'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'LIFNR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'VendorNumber.'.
  ist_fieldcat-seltext_m  = 'Vendor No.'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BELNR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Doc. No.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'GSBER'.
*  ist_fieldcat-tabname = 'IST_SRCBSIK'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'Business Area'.
*  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*---+001

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KIDNO'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Payment Reference'.
  ist_fieldcat-seltext_m  = 'Pymt Ref'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*-------+001
*---+002
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Invoice Reference'.
  ist_fieldcat-seltext_m  = 'Inv Ref'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'SHKZG'.
*  ist_fieldcat-tabname = 'IST_SRCBSIK'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'Indicator'.
**  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*-------+002

*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'GJAHR'.
*  ist_fieldcat-tabname = 'IST_SRCBSIK'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'Year'.
*  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUZEI'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Item.no.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* begin RD1K975843 CAB_ALOK CR 30005441
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REASON'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Caution'.
  ist_fieldcat-lowercase  = 'Y'.
  ist_fieldcat-emphasize = 'C31'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
* end RD1K975843 CAB_ALOK CR 30005441

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BSCHL'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Posting Key.'.
  ist_fieldcat-seltext_m  = 'PK'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* begin RD1K975843 CAB_ALOK CR 30005441
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZFBDT'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Due Dt.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
* end RD1K975843 CAB_ALOK CR 30005441

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUDAT'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Posting Date'.
  ist_fieldcat-seltext_m  = 'Post Dt'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'DMBTR'.
*  ist_fieldcat-tabname = 'IST_SRCBSIK'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
*  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778

*Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'SUBTOT'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'SubTotal'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*End of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WRBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat-seltext_m  = 'Amt In Doc Cur'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WAERS'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Curr'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
* end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSCH'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'PaymntMethod'.
  ist_fieldcat-seltext_m  = 'PM'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSPR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'PaymntBlock'.
  ist_fieldcat-seltext_m  = 'PB'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*  *Start of addition Prabu K on 06.07.2009
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-seltext_m  = 'Loc'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* End of addition Prabu K on 06.07.2009
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778  IF NOT s_usnam IS INITIAL.
*    mpos = mpos + 1.
*    ist_fieldcat-fieldname = 'USNAM'.
*    ist_fieldcat-tabname = 'IST_SRCBSIK'.
*    ist_fieldcat-ddictxt = 'M'.
*    ist_fieldcat-col_pos =  mpos.
*    ist_fieldcat-seltext_m  = 'Created By'.
*    ist_fieldcat-lowercase  = 'Y'.
*    APPEND ist_fieldcat TO ist_fcat.
*    CLEAR ist_fieldcat.
*  ENDIF.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
ENDFORM.                    " init_fieldcat
*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build TABLES  p_gt_events.
  DATA : ls_event TYPE slis_alv_event.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events.

  READ TABLE gt_events WITH KEY name =  slis_ev_user_command
                            INTO ls_event.
  IF sy-subrc <> 0.
    MOVE slis_ev_user_command TO ls_event-name.
    MOVE 'MAKE_COMMAND' TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.
  CLEAR ls_event.


*begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events_inactiv.
  CLEAR ls_event.
*end  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
ENDFORM.                    " eventtab_build
*&---------------------------------------------------------------------*
*&      Form  comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM comment_build TABLES    p_gt_list_top_of_page.

ENDFORM.                    " comment_build
*&---------------------------------------------------------------------*
*&      Form  sort_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_build.

  w_repid = sy-repid.
  is_layout-key_hotspot = 'X'.
  is_layout-colwidth_optimize = 'X'.
*begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
  is_layout_inactiv-key_hotspot = 'X'.
  is_layout_inactiv-colwidth_optimize = 'X'.
*end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778

*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ls_sorttab-fieldname = 'KIDNO'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ls_sorttab-fieldname = 'LIFNR'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ls_sorttab-fieldname = 'BSCHL'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*  ls_sorttab-fieldname = 'BELNR'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*  ls_sorttab-fieldname = 'BUDAT'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778

ENDFORM.                    " sort_build
*&---------------------------------------------------------------------*
*&      Form  print_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
*FORM print_alv.
*
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*       EXPORTING
*            i_callback_program       = w_repid
*            i_callback_pf_status_set = 'ALV_PFST'
*            i_callback_user_command  = 'MAKE_COMMAND'
*            is_layout                = is_layout
*            it_fieldcat              = ist_fcat[]
*            it_sort                  = lt_sorttab
*            it_events                = gt_events
*            i_save                   = 'A'
*       TABLES
*            t_outtab                 = ist_srcbsik.
*  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*
*ENDFORM.                    " print_alv
*End of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778

*&---------------------------------------------------------------------*
*&      Form  PRINT_MULTI_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
FORM print_multi_alv .

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = w_repid
      i_callback_pf_status_set = 'ALV_PFST'
      i_callback_user_command  = 'MAKE_COMMAND'
      is_layout                = is_layout
      it_fieldcat              = ist_fcat[]
*     it_sort                  =            " data of ist_srcbsik already arranged in reqd grouping
      it_events                = gt_events
      i_save                   = 'A'
    TABLES
      t_outtab                 = ist_srcbsik
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " PRINT_MULTI_ALV
*End of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778

*---------------------------------------------------------------------*
*       FORM alv_pfst                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
FORM alv_pfst USING rt_extab TYPE slis_t_extab.
  IF  p_x2sp = 'X'.
    SET PF-STATUS 'S100'.
  ELSE.
    SET PF-STATUS 'S200'.
  ENDIF.
ENDFORM.                    "alv_pfst

*---------------------------------------------------------------------*
*       FORM make_command                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  R_UCOMM                                                       *
*  -->  RS_SELFIELD                                                   *
*---------------------------------------------------------------------*
FORM make_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
*-----------------------------------------------------*
*-----------------------------------------------------*
  DATA : index_aux LIKE sy-tabix.
  index_aux = rs_selfield-tabindex.

  CASE r_ucomm.

    WHEN 'REL'.

*Begin of <RD1K981426> CAB_RAMA CR 30007673
      ist_srcbsik_l[] = ist_srcbsik[].
      IF p_x2sp = 'X'.
        loop at ist_srcbsik into wa_srcbsik where selcbox = 'X' AND KIDNO <> 'PERIOD END LIABILITY'.
          if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
            or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').

            """""""Added by Anamika on 21/12/2015 for RD1K999458""""
            DATA : l_text1(250).
            DATA: BEGIN OF ist_errmsg OCCURS 0,
                    text(100),
                  END OF ist_errmsg.

  """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
   select * from  ZFI_PAYREF_CC into CORRESPONDING FIELDS OF table ist_ZFI_PAYREF_CC
     where BUKRS = p_BUKRS and CHECK_VALID = 'X'.
            IF sy-subrc eq 0.
"""""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""



            l_text1 = 'Kindly ensure recovery of below documents with same payment reference.' .
            move  l_text1 to ist_errmsg-text.
            append ist_errmsg.

"""""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy where belnr in S_BELNR .

            IF sy-subrc eq 0.

      delete ist_srcbsik_copy where BELNR = wa_srcbsik_copy-BELNR.
                                       ENDIF.
endloop.
"""""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""

            if s_BELNR IS not INITIAL.
              if ist_srcbsik_copy[] IS not INITIAL.

                LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy.
                  move WA_srcbsik_copy-BELNR to ist_errmsg-text.
                  append ist_errmsg.
                ENDLOOP.


                CALL FUNCTION 'ZPOPUP_WITH_TABLE_DISPLAY_OK'
                  EXPORTING
                    titletext    = 'Warning/Error'
                    endpos_col   = 100
                    endpos_row   = 25
                    startpos_col = 20
                    startpos_row = 05
                  TABLES
                    valuetab     = ist_errmsg
                  EXCEPTIONS
                    break_off    = 1
                    OTHERS       = 2.

                REFRESH ist_errmsg.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                endif.

                LEAVE to screen 0.
              else.
              endif.

            endif.

"""""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
else.
  endif.
"""""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
            """""""Added by Anamika on 21/12/2015 for RD1K999458""""


            loop at ist_srcbsik_l into wa_srcbsik_l
              where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
              or bschl = '21'  or bschl = '26' )
              and kidno = wa_srcbsik-kidno
              AND KIDNO <> 'PERIOD END LIABILITY'
              and lifnr = wa_srcbsik-lifnr.

              MESSAGE e100(zfi) WITH text-010.
            endloop.
          endif.
        endloop.
      ENDIF.
*END of <RD1K981426> CAB_RAMA CR 30007673
**{begin of 30007662
*      data :g_budget type bseg-dmbtr,
*            g_budget_c(16)," type bseg-dmbtr,
**            l_budget type bseg-dmbtr,
*            g_dmbtr type bseg-dmbtr.
      IF p_x2sp = 'X'.
*        sort ist_srcbsik_l by lifnr bukrs gjahr belnr bschl zlsch fipos fistl.
        loop at ist_srcbsik_l into wa_srcbsik_l where selcbox = 'X' and
          shkzg = 'H' and
         ( ( BLART = 'NI' and BSCHL = '39' and UMSKZ = 'F' )
          or ( BELNR = wa_srcbsik_l-belnr and ZLSCH = 'L' ) ) .
          clear :g_budget,g_budget_c,g_dmbtr.
*{
          DATA : wa_xbseg TYPE bseg.

          DATA : l_eindt      TYPE sy-datum, "eket-eindt,
                 l_year_max   TYPE bkpf-gjahr,
                 l_year_budat TYPE bkpf-gjahr,
                 l_year_curr  TYPE bkpf-gjahr.

          DATA : l_fikrs  TYPE fkrs-fikrs,
                 l_budget TYPE fmit-hsl16.

          DATA : l_fistl TYPE fistl,    "ekpo-fistl
                 l_fipos TYPE fm_fipex. "ekpo-fipos.

          DATA : l_bukrs      TYPE t001-bukrs,
                 l_budat      TYPE sy-datum,
                 ist_fmavc001 TYPE TABLE OF fmavc001,
                 wa_fmavc001  TYPE fmavc001.

          DATA : l_dmbtr TYPE bseg-dmbtr.

          loop at ist_srcbsik into wa_srcbsik
            where BELNR = wa_srcbsik_l-belnr
            and fipos = wa_srcbsik_l-fipos
            and fistl = wa_srcbsik_l-fistl
            and shkzg = 'H'.

            if wa_srcbsik-shkzg = 'H'.
              g_dmbtr = wa_srcbsik-dmbtr * ( -1 ) + g_dmbtr.
            elseif wa_srcbsik-shkzg = 'S'.
              g_dmbtr = wa_srcbsik-dmbtr + g_dmbtr.
            endif.
          endloop.

          SELECT MAX( gjahr ) FROM fmioi INTO l_year_max
                WHERE refbn = wa_srcbsik_l-ebeln AND
                      rfpos = wa_srcbsik_l-ebelp AND
                      cfstat IN ('00','32').
          select single bukrs budat from bkpf
            into (l_bukrs,l_budat)
            where bukrs = wa_srcbsik_l-bukrs
                               and belnr = wa_srcbsik_l-belnr
                               and gjahr = wa_srcbsik_l-gjahr .

          CALL FUNCTION 'FI_PERIOD_DETERMINE'
            EXPORTING
              i_budat     = l_budat
              i_periv     = 'V3'
            IMPORTING
              e_gjahr     = l_year_budat
            EXCEPTIONS
              fiscal_year = 1.

          IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.


          CALL FUNCTION 'FI_PERIOD_DETERMINE'
            EXPORTING
              i_budat     = sy-datum
              i_periv     = 'V3'
            IMPORTING
              e_gjahr     = l_year_curr
            EXCEPTIONS
              fiscal_year = 1.

          if ( l_year_curr eq l_year_budat ) and ( l_year_budat eq l_year_max ).
*no action
          elseif ( l_year_curr gt l_year_budat ) and  ( l_year_budat eq l_year_max ).
*check FM for l_year_curr
            perform get_budget using 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
                                   changing g_budget.
            if g_dmbtr > g_budget.
              MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
            endif.
          elseif ( l_year_curr eq l_year_budat ) and ( l_year_budat gt l_year_max ).
*check FM for l_year_curr
            perform get_budget using 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
                                   changing g_budget.
            if g_dmbtr > g_budget.
              MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
            endif.
          elseif ( l_year_curr GT l_year_budat ) and ( l_year_budat NE l_year_max ).
*check FM for l_year_curr
            perform get_budget using 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
                                   changing g_budget.
            if g_dmbtr > g_budget.
              MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
            endif.
          ENDIF.
        endloop.
      endif.

*}end of 30007662
      DELETE ist_srcbsik WHERE  selcbox <> 'X'.


*Begin of <RD1K975843> CAB_ALOK CR 30005441
** Validation for credit memo
      IF p_x2sp = 'X'.
        Perform validate_liab_doc_credit_memo.
      endif.
*End of <RD1K975843> CAB_ALOK CR 30005441
      PERFORM   get_upd_bsik.
      PERFORM   get_upd_bseg.
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      PERFORM   update_zfi_rem_pyblck_l.    "update logs
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      LEAVE SCREEN.

    WHEN 'ALL'.
      PERFORM  select_all.
    WHEN 'SAL'.
      PERFORM  deselect_all.

    WHEN '&F03' OR 'BACK' .
      LEAVE  PROGRAM.
*Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
    WHEN 'REP'.
      PERFORM display_inactive_alv.
*End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778

  ENDCASE.

ENDFORM.                    "make_command
*---------------------------------------------------------------------*
*&      Form  select_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all.
  LOOP AT ist_srcbsik.
    ist_srcbsik-selcbox = 'X'.
    MODIFY ist_srcbsik.
  ENDLOOP.

ENDFORM.                    " select_all
*&---------------------------------------------------------------------*
*&      Form  deselect_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_all.
  LOOP AT ist_srcbsik.
    ist_srcbsik-selcbox = ' '.
    MODIFY ist_srcbsik.
  ENDLOOP.
ENDFORM.                    " deselect_all
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  get_upd_bsik
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upd_bsik.

  DATA : l_tabix  TYPE sy-tabix.

  CHECK NOT ist_srcbsik[] IS INITIAL.

  SELECT * INTO TABLE ist_bsik   FROM bsik
    FOR ALL ENTRIES  IN  ist_srcbsik
    WHERE   lifnr = ist_srcbsik-lifnr
          AND  bukrs  =  p_bukrs
           AND gjahr = ist_srcbsik-gjahr
           AND belnr = ist_srcbsik-belnr
           AND buzei = ist_srcbsik-buzei.
*------------X  to blank
  IF NOT ist_bsik IS INITIAL.
    IF p_x2sp = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_x.
          wa_bsik-zlspr =  space.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

*---------------blank to X
    IF p_sp2x = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_sp.
          wa_bsik-zlspr =  'X'.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr
   .
        ENDIF.
      ENDLOOP.
*
*      MODIFY  bsik FROM TABLE ist_bsik.
*
*      COMMIT WORK.
    ENDIF.
*---------+003
*------------------Blank to R
    IF p_sp2r = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_sp.
          wa_bsik-zlspr =  g_zlspr_r.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

*------------Blank to S
*  IF p_sp2s = 'X'.
*      LOOP AT ist_bsik INTO wa_bsik.
*        l_tabix =   sy-tabix .
*        IF wa_bsik-zlspr =  g_zlspr_sp.
*          wa_bsik-zlspr =  g_zlspr_s.
*       MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bsik FROM TABLE ist_bsik.
*
*      COMMIT WORK.
*    ENDIF.

*----------------X to S
    IF p_x2s = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_x  OR wa_bsik-zlspr =  g_zlspr_sp.
          wa_bsik-zlspr =  g_zlspr_s.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

* Begin of RD1K971966 CAB_ALOK CR30004183
**-----------S to X
*    IF p_s2x = 'X'.
*      LOOP AT ist_bsik INTO wa_bsik.
*        l_tabix =   sy-tabix .
*        IF wa_bsik-zlspr =  g_zlspr_s.
*          wa_bsik-zlspr =  g_zlspr_x.
*          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bsik FROM TABLE ist_bsik.
*
*      COMMIT WORK.
*    ENDIF.
* End of RD1K971966 CAB_ALOK CR30004183

*-------+003
  ENDIF.
*  LEAVE SCREEN.
ENDFORM.                    " get_upd_bsik
*
*&---------------------------------------------------------------------*
*&      Form  get_upd_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upd_bseg.
  DATA : l_tabix  TYPE sy-tabix.

  CHECK NOT ist_srcbsik[] IS INITIAL.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT * INTO TABLE ist_bseg   FROM bseg
    FOR ALL ENTRIES  IN  ist_srcbsik
    WHERE
           bukrs  =  p_bukrs
     AND   belnr = ist_srcbsik-belnr
     AND   gjahr = ist_srcbsik-gjahr
     AND   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  IF NOT ist_bseg IS INITIAL.
*---------------  X to Blank
    IF p_x2sp = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_x.
          wa_bseg-zlspr =   g_zlspr_sp.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*------------space to X
    IF p_sp2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_sp.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*----+003
*------Blank to R


    IF p_sp2r = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_sp.
          wa_bseg-zlspr =  g_zlspr_r.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY  bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      COMMIT WORK.
    ENDIF.

**------Blank to S

*  IF p_sp2s = 'X'.
*      LOOP AT ist_bseg INTO wa_bseg.
*        l_tabix =   sy-tabix .
*        IF wa_bseg-zlspr =  g_zlspr_sp.
*          wa_bseg-zlspr =  g_zlspr_s.
*       MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bseg FROM TABLE ist_bseg.
*
*      COMMIT WORK.
*    ENDIF.

*-------X  to S  and  Blank TO S
    IF p_x2s = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
* begin RD1K975843 CAB_ALOK
*        IF wa_bsik-zlspr =  g_zlspr_x  OR wa_bsik-zlspr =  g_zlspr_sp.
        IF wa_bseg-zlspr =  g_zlspr_x  OR wa_bseg-zlspr =  g_zlspr_sp.
* end RD1K975843 CAB_ALOK
          wa_bseg-zlspr =  g_zlspr_s.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY  bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      COMMIT WORK.
    ENDIF.
* Begin of RD1K971966 CAB_ALOK CR30004183
**------------------------S To X
*    IF p_s2x = 'X'.
*      LOOP AT ist_bseg INTO wa_bseg.
*        l_tabix =   sy-tabix .
*        IF wa_bseg-zlspr =  g_zlspr_s.
*          wa_bseg-zlspr =  g_zlspr_x.
*          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bseg FROM TABLE ist_bseg.
*
*      COMMIT WORK.
*    ENDIF.
* End of RD1K971966 CAB_ALOK CR30004183
*------+003
  ENDIF.



ENDFORM.                    " get_upd_bseg
*&---------------------------------------------------------------------*
*&      Form  get_docs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_docs.
  SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl zlsch
* begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
*   zlspr shkzg gsber dmbtr wrbtr kidno rebzg APPENDING
   zlspr shkzg gsber dmbtr wrbtr waers kidno rebzg
* end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
* begin RD1K975843 CAB_ALOK CR 30005441
   zfbdt rebzz
* end RD1K975843 CAB_ALOK CR 30005441
*{30007662
   blart fipos fistl
*}30007662
*{
    ebeln ebelp
*}
 APPENDING CORRESPONDING FIELDS OF TABLE
                ist_srcbsik  FROM bsik
                WHERE bukrs  =  p_bukrs
                AND lifnr  IN s_lifnr
                AND gjahr IN s_year
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*                AND gsber IN s_gsber
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
* begin RD1K975843 CAB_ALOK      CR 30005441
                AND BELNR in S_BELNR
* end RD1K975843 CAB_ALOK      CR 30005441
                AND budat IN  s_budat.



  """""""Added by Anamika on 21/12/2015 for RD1K999458""""
  clear : ist_srcbsik_copy,wa_srcbsik_copy .
  refresh : ist_srcbsik_copy[].
  if s_BELNR IS not INITIAL.
    read TABLE ist_srcbsik into wa_srcbsik_copy index 1.  "#EC CI_NOORDER

    SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
    zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg kidno APPENDING
  CORRESPONDING FIELDS OF TABLE
                 ist_srcbsik_copy  FROM bsik
                 WHERE
                      bukrs  =  p_bukrs
                AND lifnr  IN s_lifnr
                AND  ZLSPR IN ('A','X','S','R')
                AND BSCHL IN ('21','26')
                AND SHKZG = 'S'
                AND KIDNO ne 'PERIOD END LIABILITY '
                AND KIDNO EQ wa_srcbsik_copy-KIDNO.
    SORT ist_srcbsik BY lifnr bschl belnr budat .
    SORT ist_srcbsik_copy.
    DELETE ADJACENT DUPLICATES  FROM ist_srcbsik_copy.  "#EC CI_NOORDER
  ENDIF.
  """""""Added by Anamika on 21/12/2015 for RD1K999458""""


  IF p_x2sp = 'X'.
    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_x.
  ELSEIF p_sp2x = 'X'.
    DELETE  ist_srcbsik WHERE NOT  zlspr IS INITIAL.
*-----+003
  ELSEIF p_sp2r = 'X'.
    DELETE  ist_srcbsik WHERE NOT  zlspr IS INITIAL.
  ELSEIF p_x2s = 'X'.
    DELETE  ist_srcbsik WHERE ( zlspr <> g_zlspr_x AND zlspr  <>
g_zlspr_sp ).
* Begin of RD1K971966 CAB_ALOK CR30004183
*  ELSEIF p_s2x = 'X'.
*    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_s.
* end of RD1K971966 CAB_ALOK CR30004183

*  ELSEIF p_sp2s = 'X'.
*    DELETE  ist_srcbsik WHERE NOT  zlspr IS initial.
  ENDIF.
*---+003


*/..Begin of Change CR :30012666
  data : WA_ZFI_BCM_PAYORDR TYPE ZFI_BCM_PAYORDR,
         l_tab              type sy-tabix.
  IF P_SP2X = 'X'.
    LOOP AT ist_srcbsik INTO wa_srcbsik.
      l_tab = sy-tabix.
      clear : WA_ZFI_BCM_PAYORDR.

      SELECT SINGLE * FROM ZFI_BCM_PAYORDR
        INTO CORRESPONDING FIELDS OF WA_ZFI_BCM_PAYORDR
        WHERE bukrs =  wa_srcbsik-bukrs
        and belnr =  wa_srcbsik-belnr
        and lifnr =  wa_srcbsik-lifnr.  "#EC CI_NOORDER

      if not WA_ZFI_BCM_PAYORDR-pyord is initial
        and ( WA_ZFI_BCM_PAYORDR-zstatus = '001' or WA_ZFI_BCM_PAYORDR-zstatus = '002' ) .
        wa_srcbsik-inactiv = 'X'.
        wa_srcbsik-reason = text-013.
        MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tab TRANSPORTING inactiv reason.
      endif.
      CLEAR: wa_srcbsik.
    endloop.
* Again move inactive lines to ist_srcbsik_inactiv
    LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
      APPEND wa_srcbsik TO ist_srcbsik_inactiv.
    ENDLOOP.
    DELETE ist_srcbsik WHERE inactiv = 'X'.
  ENDIF.
*/..End of Change CR :30012666

*  *Start of addition Prabu K on 03.07.2009
  DATA wa_bkpf TYPE bkpf.
  LOOP AT ist_srcbsik INTO wa_srcbsik.

    SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcbsik-belnr
       AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
    IF sy-subrc NE 0.
      DELETE TABLE ist_srcbsik FROM wa_srcbsik.
    ELSE.
      wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
      MODIFY ist_srcbsik FROM wa_srcbsik.
    ENDIF.
  ENDLOOP.
*  End of addition Prabu K on 03.07.2009
  IF NOT s_usnam   IS INITIAL.
    IF NOT ist_srcbsik[] IS INITIAL.
      SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
                        INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
                         FROM  bkpf
                        FOR ALL ENTRIES IN ist_srcbsik
*                     FROM bkpf
                 WHERE bukrs = ist_srcbsik-bukrs
                 AND  gjahr = ist_srcbsik-gjahr
                 AND  belnr = ist_srcbsik-belnr
                 AND  budat = ist_srcbsik-budat
                 AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
    ENDIF.

    IF NOT ist_bkpf[] IS INITIAL.

      LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
        MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
        MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
        APPEND y_doc_nos .
      ENDLOOP.

      CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
        TABLES
          y_doc_nos = y_doc_nos
          f_doc_nos = f_doc_nos.
*           EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.

      LOOP AT ist_bkpf .
        READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
                                      belnr = ist_bkpf-belnr
                                      gjahr = ist_bkpf-gjahr.
        IF sy-subrc EQ 0 .
          ist_bkpf-usnam = y_doc_nos-usrel .
          MODIFY ist_bkpf TRANSPORTING usnam .
        ENDIF .
      ENDLOOP.


      LOOP AT ist_srcbsik.
        READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsik-bukrs
                                 belnr = ist_srcbsik-belnr
                                 gjahr = ist_srcbsik-gjahr .
        IF sy-subrc = 0.
          ist_srcbsik-usnam = ist_bkpf-usnam.
          MODIFY ist_srcbsik  TRANSPORTING usnam .
        ENDIF.
      ENDLOOP.

      IF NOT s_usnam IS  INITIAL.
        DELETE ist_srcbsik WHERE  NOT usnam  IN s_usnam.
      ENDIF.

    ENDIF.

  ENDIF.

  ist_bsiks[] = ist_srcbsik[].


  REFRESH ist_srcbsik.
  CLEAR ist_srcbsik.


  LOOP AT ist_bsiks .
    IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F'  OR ist_bsiks-umskz = 'H' or ist_bsiks-umskz = 'K' or
    ist_bsiks-umskz = ':' OR                                " +002
    ist_bsiks-umskz  IS INITIAL.
      ist_srcbsik = ist_bsiks.
      APPEND ist_srcbsik.
      CLEAR ist_srcbsik.
    ENDIF.
  ENDLOOP.



  CHECK  NOT ist_srcbsik[] IS INITIAL.

  LOOP AT ist_srcbsik.
    IF ist_srcbsik-shkzg = 'S'.
      ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
      ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
    ELSEIF ist_srcbsik-shkzg = 'H'.
      ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
      ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
    ENDIF.
    MODIFY ist_srcbsik .
  ENDLOOP.

  ist_bsiks[] = ist_srcbsik[].

  SORT ist_srcbsik BY lifnr bschl belnr budat.

ENDFORM.                    " get_docs
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0446   text
*----------------------------------------------------------------------*
FORM authority_check USING    p_actvt.
  AUTHORITY-CHECK OBJECT 'ZFIBLOCKR'
             ID 'ACTVT' FIELD p_actvt.
  IF sy-subrc <> 0.
    MESSAGE  e077(s#) WITH 'ZFIBLOCKR' .
  ENDIF.

ENDFORM.                    " authority_check
*&---------------------------------------------------------------------*
*&      Form  authority_check_x
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0461   text
*----------------------------------------------------------------------*
FORM authority_check_x USING    value(p_0461).
  AUTHORITY-CHECK OBJECT 'ZFIBLOCKX'
             ID 'ACTVT' FIELD p_0461.
  IF sy-subrc <> 0.
    MESSAGE  e077(s#) WITH 'ZFIBLOCKX'.
  ENDIF.
ENDFORM.                    " authority_check_x
*----------Start of <RD1K960891>

*&---------------------------------------------------------------------*
*&      Form  get_docs_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_docs_cust.
  SELECT bukrs kunnr umskz gjahr belnr buzei budat bschl zlsch
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*     zlspr shkzg gsber dmbtr wrbtr kidno APPENDING
*  begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
*     zlspr shkzg gsber dmbtr wrbtr kidno rebzg APPENDING
     zlspr shkzg gsber dmbtr wrbtr waers kidno rebzg APPENDING
* end
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
    CORRESPONDING FIELDS OF TABLE
                  ist_srcbsid  FROM bsid
                  WHERE
                  bukrs  =  p_bukrs
                  AND kunnr  IN s_kunnr
                  AND gjahr IN s_year
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*                  AND gsber IN s_gsber
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
* begin RD1K975843 CAB_ALOK      CR 30005441
                 AND BELNR in S_BELNR
* end RD1K975843 CAB_ALOK      CR 30005441
                  AND budat IN  s_budat.  "#EC CI_NOORDER



  IF p_x2sp = 'X'.
    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_x.
  ELSEIF p_sp2x = 'X'.
    DELETE  ist_srcbsid WHERE NOT  zlspr IS INITIAL.
*-----+003
  ELSEIF p_sp2r = 'X'.
    DELETE  ist_srcbsid WHERE NOT  zlspr IS INITIAL.
  ELSEIF p_x2s = 'X'.
    DELETE  ist_srcbsid WHERE ( zlspr <> g_zlspr_x AND zlspr  <>
g_zlspr_sp ).
* Begin of RD1K971966 CAB_ALOK CR30004183
*  ELSEIF p_s2x = 'X'.
*    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_s.
* End of RD1K971966 CAB_ALOK CR30004183
*  ELSEIF p_sp2s = 'X'.
*    DELETE  ist_srcbsid WHERE NOT  zlspr IS initial.
  ENDIF.
*---+003

*  *Start of addition Prabu K on 03.07.2009
  DATA wa_bkpf TYPE bkpf.
  LOOP AT ist_srcbsid INTO wa_srcbsid.

    SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcbsid-belnr
       AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
    IF sy-subrc NE 0.
      DELETE TABLE ist_srcbsid FROM wa_srcbsid.
    ELSE.
      wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
      MODIFY ist_srcbsid FROM wa_srcbsid.
    ENDIF.

  ENDLOOP.
*  End  of addition Prabu K on 03.07.2009
  IF NOT s_usnam   IS INITIAL.
    IF NOT ist_srcbsid[] IS INITIAL.
      SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
                        INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
                         FROM  bkpf
                        FOR ALL ENTRIES IN ist_srcbsid
*                     FROM bkpf
                 WHERE bukrs = ist_srcbsid-bukrs
                 AND  gjahr = ist_srcbsid-gjahr
                 AND  belnr = ist_srcbsid-belnr
                 AND  budat = ist_srcbsid-budat
                 AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
    ENDIF.

    IF NOT ist_bkpf[] IS INITIAL.

      LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
        MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
        MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
        APPEND y_doc_nos .
      ENDLOOP.

      CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
        TABLES
          y_doc_nos = y_doc_nos
          f_doc_nos = f_doc_nos.
*           EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.

      LOOP AT ist_bkpf .
        READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
                                      belnr = ist_bkpf-belnr
                                      gjahr = ist_bkpf-gjahr.
        IF sy-subrc EQ 0 .
          ist_bkpf-usnam = y_doc_nos-usrel .
          MODIFY ist_bkpf TRANSPORTING usnam .
        ENDIF .
      ENDLOOP.


      LOOP AT ist_srcbsid.
        READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsid-bukrs
                                 belnr = ist_srcbsid-belnr
                                 gjahr = ist_srcbsid-gjahr .
        IF sy-subrc = 0.
          ist_srcbsid-usnam = ist_bkpf-usnam.
          MODIFY ist_srcbsid  TRANSPORTING usnam .
        ENDIF.
      ENDLOOP.

      IF NOT s_usnam IS  INITIAL.
        DELETE ist_srcbsid WHERE  NOT usnam  IN s_usnam.
      ENDIF.

    ENDIF.

  ENDIF.

  ist_bsids[] = ist_srcbsid[].


  REFRESH ist_srcbsid.
  CLEAR ist_srcbsid.


  LOOP AT ist_bsids .
*{001
*    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'.
    IF ( ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'  OR ist_bsids-umskz = 'O') OR
*Start of changes by SOGET - 003
*( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
       ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ) or ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'Q' )
* Begin of <RD1K973788>  CAB_ALOK CR 30004826
* OR   ist_bsids-kunnr BETWEEN 'DS000000001' and 'DS999999999' "Commented, as told by Mr. Kalia
* End of <RD1K973788>  CAB_ALOK CR 30004826
      .
*End of changes by SOGET - 003
*}001
      ist_srcbsid = ist_bsids.
      APPEND ist_srcbsid.
      CLEAR ist_srcbsid.
    ENDIF.
  ENDLOOP.



  CHECK  NOT ist_srcbsid[] IS INITIAL.

  LOOP AT ist_srcbsid.
    IF ist_srcbsid-shkzg = 'S'.
      ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
      ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
    ELSEIF ist_srcbsid-shkzg = 'H'.
      ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
      ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
    ENDIF.
    MODIFY ist_srcbsid .
  ENDLOOP.

  ist_bsids[] = ist_srcbsid[].

  SORT ist_srcbsid BY kunnr bschl belnr budat.


ENDFORM.                    " get_docs_cust
*&---------------------------------------------------------------------*
*&      Form  display_docs_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_docs_cust.
  PERFORM init_fieldcat_cust.
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*  make fieldcat for inactive items
  PERFORM init_fieldcat_inactiv_cust.
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
  PERFORM eventtab_build_cust TABLES gt_events.
*  PERFORM comment_build USING gt_list_top_of_page[].
  PERFORM  sort_build_cust .
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*    PERFORM  print_alv_cust.
*  display multiple list ALV
  PERFORM print_multi_alv_cust.
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778



ENDFORM.                    " display_docs_cust
*&---------------------------------------------------------------------*
*&      Form  init_fieldcat_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat_cust.
  w_repid  = sy-repid.

  mpos = 0.
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'SELCBOX'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Select'.
  ist_fieldcat-lowercase  = 'Y'.
  ist_fieldcat-checkbox = 'X'.
  ist_fieldcat-input = 'X'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KUNNR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'CustomerNumber'.
  ist_fieldcat-seltext_m  = 'Cstmr No.'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BELNR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Doc.No.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*    mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'GSBER'.
*  ist_fieldcat-tabname = 'IST_SRCBSID'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'Business Area'.
*  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778

*---+001
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KIDNO'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*    ist_fieldcat-seltext_m  = 'Payment Reference'.
  ist_fieldcat-seltext_m  = 'Pymt Ref'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*-------+001
*---+002

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*    ist_fieldcat-seltext_m  = 'Invoice Reference'.
  ist_fieldcat-seltext_m  = 'Inv Ref'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  *---testing purpose
*    mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'SHKZG'.
*  ist_fieldcat-tabname = 'IST_SRCBSID'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'INdicator'.
**  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
**-------+002
*    mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'GJAHR'.
*  ist_fieldcat-tabname = 'IST_SRCBSID'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'Year'.
*  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUZEI'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Item.no.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BSCHL'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Posting Key.'.
  ist_fieldcat-seltext_m  = 'PK'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUDAT'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Posting Date'.
  ist_fieldcat-seltext_m  = 'Post Dt'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*    mpos = mpos + 1.
*  ist_fieldcat-fieldname = 'DMBTR'.
*  ist_fieldcat-tabname = 'IST_SRCBSID'.
*  ist_fieldcat-ddictxt = 'M'.
*  ist_fieldcat-col_pos =  mpos.
*  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
*  ist_fieldcat-lowercase  = 'Y'.
*  APPEND ist_fieldcat TO ist_fcat.
*  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WRBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat-seltext_m  = 'Amt In Doc Cur'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WAERS'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Curr'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
* end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSCH'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'PaymntMethod'.
  ist_fieldcat-seltext_m  = 'PM'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSPR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'PaymntBlock'.
  ist_fieldcat-seltext_m  = 'PB'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*  *Start of addition Prabu K on 06.07.2009
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-seltext_m  = 'Loc'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* End of addition Prabu K on 06.07.2009

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*    IF NOT s_usnam IS INITIAL.
*    mpos = mpos + 1.
*    ist_fieldcat-fieldname = 'USNAM'.
*    ist_fieldcat-tabname = 'IST_SRCBSID'.
*    ist_fieldcat-ddictxt = 'M'.
*    ist_fieldcat-col_pos =  mpos.
*    ist_fieldcat-seltext_m  = 'Created By'.
*    ist_fieldcat-lowercase  = 'Y'.
*    APPEND ist_fieldcat TO ist_fcat.
*    CLEAR ist_fieldcat.
*  ENDIF.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778


ENDFORM.                    " init_fieldcat_cust
*&---------------------------------------------------------------------*
*&      Form  eventtab_build_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build_cust TABLES   p_gt_events.
  DATA : ls_event TYPE slis_alv_event.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events.
  READ TABLE gt_events WITH KEY name =  slis_ev_user_command
                            INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'MAKEC_COMMAND' TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.
  CLEAR ls_event.
*begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events_inactiv.
  CLEAR ls_event.
*end  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778

ENDFORM.                    " eventtab_build_cust
*&---------------------------------------------------------------------*
*&      Form  print_alv_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Begin  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
*FORM print_alv_cust.
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*    EXPORTING
*      i_callback_program       = w_repid
*      i_callback_pf_status_set = 'ALV_PFSTS'
*      i_callback_user_command  = 'MAKEC_COMMAND'
*      is_layout                = is_layout
*      it_fieldcat              = ist_fcat[]
*      it_sort                  = lt_sorttab
*      it_events                = gt_events
*      i_save                   = 'A'
*    TABLES
*      t_outtab                 = ist_srcbsid.
*  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*
*ENDFORM.                    " print_alv
**---------------------------------------------------------------------*
**       FORM alv_pfst                                                 *
**---------------------------------------------------------------------*
**       ........                                                      *
**---------------------------------------------------------------------*
**  -->  RT_EXTAB                                                      *
**---------------------------------------------------------------------*
*FORM alv_pfsts USING rt_extab TYPE slis_t_extab.
*  SET PF-STATUS 'S100'.
*ENDFORM.                    "alv_pfsts
*end  of <RD1K967585> CAB_ALOK 07.12.2009 CR30002778

*---------------------------------------------------------------------*
*       FORM makec_command                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  R_UCOMM                                                       *
*  -->  RS_SELFIELD                                                   *
*---------------------------------------------------------------------*
FORM makec_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
*-----------------------------------------------------*
*-----------------------------------------------------*
  DATA : index_aux LIKE sy-tabix.
  index_aux = rs_selfield-tabindex.
  CASE r_ucomm.

    WHEN 'REL'.
      DELETE ist_srcbsid WHERE  selcbox <> 'X'.

      PERFORM   get_upd_bsid.
      PERFORM   get_upd_bsegc.
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      PERFORM update_zfi_rem_pyblck_l .           "update logs
*End of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      LEAVE SCREEN.
    WHEN 'ALL'.
      PERFORM  select_allc.
    WHEN 'SAL'.
      PERFORM  deselect_allc.

    WHEN '&F03' OR 'BACK' .
      LEAVE  PROGRAM.
*Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
    WHEN 'REP'.
      PERFORM display_inactive_alv_cust.
*End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778

  ENDCASE.

ENDFORM.                    "makec_command
*---------------------------------------------------------------------*
*&      Form  select_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_allc.
  LOOP AT ist_srcbsid.
    ist_srcbsid-selcbox = 'X'.
    MODIFY ist_srcbsid.
  ENDLOOP.

ENDFORM.                    " select_all
*&---------------------------------------------------------------------*
*&      Form  deselect_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_allc.
  LOOP AT ist_srcbsid.
    ist_srcbsid-selcbox = ' '.
    MODIFY ist_srcbsid.
  ENDLOOP.
ENDFORM.                    " deselect_all
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  get_upd_BSID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upd_bsid.

  DATA : l_tabix  TYPE sy-tabix.

  CHECK NOT ist_srcbsid[] IS INITIAL.

  SELECT * INTO TABLE ist_bsid   FROM bsid
    FOR ALL ENTRIES  IN  ist_srcbsid
    WHERE   kunnr = ist_srcbsid-kunnr
          AND  bukrs  =  p_bukrs
           AND gjahr = ist_srcbsid-gjahr
           AND belnr = ist_srcbsid-belnr
           AND buzei = ist_srcbsid-buzei.
*------------X  to blank
  IF NOT ist_bsid IS INITIAL.
    IF p_x2sp = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_x.
          wa_bsid-zlspr =  space.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

*---------------blank to X
    IF p_sp2x = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_sp.
          wa_bsid-zlspr =  'X'.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr
      .
        ENDIF.
      ENDLOOP.

"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
*---------+003
*------------------Blank to R
    IF p_sp2r = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_sp.
          wa_bsid-zlspr =  g_zlspr_r.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
*------------Blank to S
*  IF p_sp2s = 'X'.
*      LOOP AT ist_BSID INTO wa_BSID.
*        l_tabix =   sy-tabix .
*        IF wa_BSID-zlspr =  g_zlspr_sp.
*          wa_BSID-zlspr =  g_zlspr_s.
*       MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr
*.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  BSID FROM TABLE ist_BSID.
*
*      COMMIT WORK.
*    ENDIF.

*----------------X to S



    IF p_x2s = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_x  OR wa_bsid-zlspr =  g_zlspr_sp.
          wa_bsid-zlspr =  g_zlspr_s.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.

*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

* Begin of RD1K971966 CAB_ALOK CR30004183
**-----------S to X
*     IF p_s2x = 'X'.
*      LOOP AT ist_bsid INTO wa_bsid.
*        l_tabix =   sy-tabix .
*        IF wa_bsid-zlspr =  g_zlspr_s.
*          wa_bsid-zlspr =  g_zlspr_x.
*          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bsid FROM TABLE ist_bsid.
*
*      COMMIT WORK.
*    ENDIF.
* end of RD1K971966 CAB_ALOK CR30004183

*-------+003
  ENDIF.
*  LEAVE SCREEN.
ENDFORM.                    " get_upd_BSID
*
*&---------------------------------------------------------------------*
*&      Form  get_upd_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_upd_bsegc.
  DATA : l_tabix  TYPE sy-tabix.

  CHECK NOT ist_srcbsid[] IS INITIAL.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT * INTO TABLE ist_bseg   FROM bseg
    FOR ALL ENTRIES  IN  ist_srcbsid
    WHERE
           bukrs  =  p_bukrs
     AND   belnr = ist_srcbsid-belnr
     AND   gjahr = ist_srcbsid-gjahr
     AND   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  IF NOT ist_bseg IS INITIAL.
*---------------  X to Blank
    IF p_x2sp = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_x.
          wa_bseg-zlspr =   g_zlspr_sp.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*------------space to X
    IF p_sp2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_sp.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*----+003
*------Blank to R


    IF p_sp2r = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_sp.
          wa_bseg-zlspr =  g_zlspr_r.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY  bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      COMMIT WORK.
    ENDIF.

**------Blank to S
*
*
*    IF p_sp2s = 'X'.
*      LOOP AT ist_bseg INTO wa_bseg.
*        l_tabix =   sy-tabix .
*        IF wa_bseg-zlspr =  g_zlspr_sp.
*          wa_bseg-zlspr =  g_zlspr_s.
*       MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr
*.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bseg FROM TABLE ist_bseg.
*
*      COMMIT WORK.
*    ENDIF.


*-------X  to S  and  Blank TO S
    IF p_x2s = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_x  OR wa_bsid-zlspr =  g_zlspr_sp.
          wa_bseg-zlspr =  g_zlspr_s.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*      MODIFY  bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      COMMIT WORK.
    ENDIF.

* Begin of RD1K971966 CAB_ALOK CR30004183
**------------------------S To X
*    IF p_s2x = 'X'.
*      LOOP AT ist_bseg INTO wa_bseg.
*        l_tabix =   sy-tabix .
*        IF wa_bseg-zlspr =  g_zlspr_s.
*          wa_bseg-zlspr =  g_zlspr_x.
*          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
*      ENDLOOP.
*
*      MODIFY  bseg FROM TABLE ist_bseg.
*
*      COMMIT WORK.
*    ENDIF.
* end of RD1K971966 CAB_ALOK CR30004183

*------+003
  ENDIF.



ENDFORM.                    " print_alv_cust
*&---------------------------------------------------------------------*
*&      Form  sort_build_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_build_cust.
  w_repid = sy-repid.
  is_layout-key_hotspot = 'X'.
  is_layout-colwidth_optimize = 'X'.
*begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
  is_layout_inactiv-key_hotspot = 'X'.
  is_layout_inactiv-colwidth_optimize = 'X'.

*  ls_sorttab-fieldname = 'KIDNO'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
  ls_sorttab-fieldname = 'KUNNR'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ls_sorttab-fieldname = 'BSCHL'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*  ls_sorttab-fieldname = 'BELNR'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*  ls_sorttab-fieldname = 'BUDAT'.
*  ls_sorttab-up = 'X'.
*  APPEND ls_sorttab TO lt_sorttab.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778

ENDFORM.                    " sort_build_cust
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DOCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_docs .
  DATA : ist_kid LIKE  ist_srcbsik OCCURS 0.
  DATA : wa_kid LIKE  ist_srcbsik.
  DATA : g_actflag TYPE c.
  DATA :l_dmbtr TYPE bseg-dmbtr.
  DATA : l_lifnr TYPE bsik-lifnr,
         l_kidno TYPE bsik-kidno.
  DATA :l_tabix TYPE sy-tabix.

*Begin of <RD1K975843> CAB_ALOK CR 30005441
  data: WA_ZFI_C_N_B_CC1    TYPE  ZFI_C_N_B_CC1,
        WA_ZFI_C_B_BLOCKPM1 TYPE  ZFI_C_B_BLOCKPM1,
        WA_ZFI_C_N_B_CC2    TYPE  ZFI_C_N_B_CC2,
        WA_ZFI_C_B_BLOCKPM2 TYPE  ZFI_C_B_BLOCKPM2.
  if ist_srcbsik is not INITIAL.
*End of <RD1K975843> CAB_ALOK CR 30005441

    IF p_x2sp = 'X'.

*Begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*** Validate ist_srcbsik for different conditions and move inactive items into ist_srcbsik_inactiv

** add serial no. to ist_srcbsik
      DATA srno TYPE i. "serial no.
      srno = 0.
      LOOP AT ist_srcbsik INTO wa_srcbsik.
        srno = srno + 1.
        wa_srcbsik-serial_no = srno.
        MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING serial_no.
      ENDLOOP.
** save original ist_srcbsik
*ist_srcbsik_orig = ist_srcbsik
      ist_srcbsik_orig[] = ist_srcbsik[].
*** Check each line of ist_srcbsik:
** if Vendor is blocked or deleted or line posting key 26 put the reason and make the line item inactive
*End of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
      SORT ist_srcbsik  BY lifnr kidno.
      TYPES :BEGIN OF ty_vend,
               lifnr TYPE lfb1-lifnr,
               bukrs TYPE lfb1-bukrs,
               sperr TYPE lfb1-sperr,
               zahls TYPE lfb1-zahls,
               loevm TYPE lfb1-loevm,
*Begin of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
               bschl TYPE bsik-bschl,
               rebzg TYPE bsik-rebzg,
*End of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
*Begin of <RD1K975843> CAB_ALOK CR 30005441
               ZWELS type lfb1-zwels,  "payment method
*End of <RD1K975843> CAB_ALOK CR 30005441
             END OF ty_vend.

      DATA :ist_vend TYPE TABLE OF ty_vend.
      DATA :wa_vend TYPE ty_vend.
*DATA :l_tabix TYPE sy-tabix.
** 1. For a given vendor, posting blocked or marked deleted for given company code?
      SELECT lifnr bukrs sperr zahls loevm
        FROM lfb1
        INTO CORRESPONDING FIELDS OF TABLE ist_vend
        FOR ALL ENTRIES IN ist_srcbsik
        WHERE lifnr = ist_srcbsik-lifnr
        AND bukrs = ist_srcbsik-bukrs.    " p_bukrs.

      CLEAR: wa_srcbsik.
      LOOP AT ist_srcbsik INTO wa_srcbsik.
        l_tabix = sy-tabix.
*Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
*      READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
        READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
                                                   bukrs = wa_srcbsik-bukrs  .
*end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
        IF sy-subrc = 0.
          IF wa_vend-sperr = 'X'.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Posting blocked for company code'.
          ELSEIF wa_vend-zahls = 'X'.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Blocked for Payment'.
          ELSEIF wa_vend-loevm = 'X'.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Marked for Deletion-company code level'.
          ENDIF.
          MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
        ENDIF.
        CLEAR: wa_srcbsik.
      ENDLOOP.
*Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
** 2. For a given vendor, posting blocked or deleted for all company codes?
      REFRESH ist_vend.
      SELECT lifnr loevm sperr INTO CORRESPONDING FIELDS OF TABLE ist_vend
        FROM lfa1
        FOR ALL ENTRIES IN ist_srcbsik
        WHERE lifnr = ist_srcbsik-lifnr.  "#EC CI_NOORDER
      CLEAR: wa_srcbsik.
      LOOP AT ist_srcbsik INTO wa_srcbsik.
        l_tabix = sy-tabix.
        READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
        IF sy-subrc = 0.
          IF wa_vend-sperr = 'X'.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Central Posting block'.
          ELSEIF wa_vend-loevm = 'X'.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Central Deletion flag'.
          ENDIF.
          MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
        ENDIF.
        CLEAR: wa_srcbsik.
      ENDLOOP.
*end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778

** 3. Validation for posting key '26'
*begin of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
*     LOOP AT ist_srcbsik INTO wa_srcbsik.
*      l_tabix = sy-tabix.
**     IF sy-subrc = 0.
**     IF wa_srcbsik-rebzg IS INITIAL.
*      IF wa_srcbsik-bschl = '26' AND wa_srcbsik-rebzg IS INITIAL.
*        wa_srcbsik-inactiv = 'X'.
*        wa_srcbsik-reason = 'Inv Ref not upd'.
*        MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
*      ENDIF.
*    ENDLOOP.

*	If vendor has any open item (BSIK) with Posting key(BSCHL) 26
*    and blank value in Inv reference(REBZG). All line items of this vendor in ist_srcbsik should be inactive with reason.
*  READ TABLE ist_srcbsik INTO wa_srcbsik  WITH KEY bschl = '26'.
      REFRESH ist_vend.
*begin of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
*    SELECT lifnr BSCHL REBZG INTO CORRESPONDING FIELDS OF TABLE ist_vend
      SELECT lifnr bukrs bschl rebzg INTO CORRESPONDING FIELDS OF TABLE ist_vend
*end of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
        FROM bsik
        FOR ALL ENTRIES IN ist_srcbsik
        WHERE lifnr = ist_srcbsik-lifnr
        AND  bschl = '26'
        AND  rebzg = ''.
      CLEAR: wa_srcbsik.
      LOOP AT ist_srcbsik INTO wa_srcbsik.
        l_tabix = sy-tabix.
*begin of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
*     READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
        READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr bukrs = wa_srcbsik-bukrs.
*end of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739

        IF sy-subrc = 0.
          wa_srcbsik-inactiv = 'X'.
          wa_srcbsik-reason = 'Inv Ref not upd'.
          MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
        ENDIF.
        CLEAR: wa_srcbsik.
      ENDLOOP.
*end of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
*4a, 5a moved down.
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*Move inactive lines to ist_srcbsik_inactiv
      ist_srcbsik_inactiv[] = ist_srcbsik[].
      DELETE ist_srcbsik_inactiv WHERE inactiv <> 'X'. "ist_srcbsik_inactiv contains inactive items
      DELETE ist_srcbsik WHERE inactiv = 'X'.  "ist_srcbsik contains active items

** 5. Validation on linked documents: Match Inv. Ref with Doc No.
* Loop at lines of ist_srcbsik that hav some Inv. Ref.(rebzg )
* Search this Inv Ref in Doc no. (belnr) of other Credit line items ( Credit indicator: shkzg  = 'H')
* if matchig doc is found then
*    temporarily update Pay Ref (kidno) of current line item with the Pay ref of matching Doc (this
*                 will be needed later while sub-totaling on the basis of lifnr+kidno )
*  else
*   make the current line inactive.
      LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
        READ TABLE ist_srcbsik_orig
                   INTO wa_srcbsik_orig
                    WITH KEY lifnr = wa_srcbsik-lifnr
                             belnr  = wa_srcbsik-rebzg
                             shkzg  = 'H' .
        IF sy-subrc = 0.
          wa_srcbsik-kidno = wa_srcbsik_orig-kidno.
          MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING kidno.
        ELSE.
          wa_srcbsik-inactiv = 'X'.
          MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv.
        ENDIF.
      ENDLOOP.

*{30007486
      LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
        READ TABLE ist_srcbsik_orig
                   INTO wa_srcbsik_orig
                    WITH KEY lifnr = wa_srcbsik-lifnr
                             belnr  = wa_srcbsik-rebzg
                             shkzg  = 'H' .
        IF sy-subrc = 0.
          if wa_srcbsik_orig-bschl <> '39'. "31
            if wa_srcbsik_orig-bschl = '31'.
              if ( wa_srcbsik-rebzz <> wa_srcbsik_orig-buzei ).
                wa_srcbsik-inactiv = 'X'.
                wa_srcbsik-reason = 'Incorrect Line Item Reference'.
                MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
                READ TABLE ist_srcbsik
                           INTO wa_srcbsik_l
                            WITH KEY lifnr = wa_srcbsik-lifnr
                                     belnr  = wa_srcbsik-belnr
                                     shkzg  = 'S' .
                wa_srcbsik_l-inactiv = 'X'.
                wa_srcbsik_l-reason = 'Incorrect Line Item Reference'.
                MODIFY ist_srcbsik FROM wa_srcbsik_l TRANSPORTING inactiv reason.
              endif.
            else. "39 and not F

            endif.
          endif.
        endif.
      ENDLOOP.
*}
* Again move inactive lines to ist_srcbsik_inactiv
      LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
        APPEND wa_srcbsik TO ist_srcbsik_inactiv.
      ENDLOOP.
      DELETE ist_srcbsik WHERE inactiv = 'X'.


** calculate sub total group by vendor, pay ref (i.e. lifnr, kidno)
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
      SORT ist_srcbsik  BY lifnr kidno rebzg.
*read table ist_srcbsik  index 1 into wa_srcbsik.
*if sy-subrc = 0.
*  l_lifnr = wa_srcbsik-lifnr.
*  l_kidno = wa_srcbsik-kidno.
*endif.
      LOOP AT ist_srcbsik INTO wa_srcbsik.
        READ TABLE ist_kid INTO wa_kid
        WITH KEY lifnr = wa_srcbsik-lifnr
              kidno = wa_srcbsik-kidno.
        IF sy-subrc = 0.
          l_dmbtr = l_dmbtr + wa_srcbsik-dmbtr .  "update sub total
          wa_kid-dmbtr = l_dmbtr.
          MODIFY ist_kid FROM wa_kid INDEX sy-tabix "wa_kid-dmbtr holds subtotal for {vendor, pay ref i.e. kidno} tupple.
          TRANSPORTING dmbtr.
        ELSE.
          CLEAR l_dmbtr.
          l_dmbtr = wa_srcbsik-dmbtr.
          APPEND wa_srcbsik TO ist_kid.
        ENDIF.
        CLEAR wa_srcbsik.
      ENDLOOP.

*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
** assign a sub-group no. to each {vendor, pay ref} tupple of ist_kid, which will be subsequently
* moved to {vendor, pay ref} tupple of ist_srcbsik ('ll be used for grouping of data when changed Pay Ref
* have been restored back.
      DATA l_subgrp TYPE i.
      l_subgrp = 0.
      SORT ist_kid BY lifnr kidno rebzg.
      LOOP AT ist_kid INTO wa_kid.
        l_subgrp = l_subgrp + 1.
        wa_kid-subgrp = l_subgrp.
        MODIFY ist_kid FROM wa_kid TRANSPORTING subgrp.
      ENDLOOP.
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778


*Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
*loop at ist_kid into wa_kid.
*  read table ist_srcbsik  into  wa_srcbsik
*with key lifnr = wa_kid-lifnr   " Vendor
*          kidno = wa_kid-kidno.   "pay ref.
*if sy-subrc = 0.
*  clear wa_srcbsik.
*  wa_srcbsik-activ = 'X'.
*  wa_srcbsik-lifnr = wa_kid-lifnr.
*  wa_srcbsik-kidno = wa_kid-kidno.
*  wa_srcbsik-reason = 'Subtotal'.
*  wa_srcbsik-dmbtr =   wa_kid-dmbtr.
*  append wA_srcbsik to ist_srcbsik.  "add sub total line item to ist_srcbsik
*endif.
*endloop.

** update subtotal for all {vendor, pay ref i.e. kidno} tupple in SubTot column of ist_srcbsik,
* note: {vendor, pay ref i.e. kidno} tupple is non-unique in ist_srcbsik
* while it's unique in ist_kid.
      LOOP AT ist_srcbsik INTO wa_srcbsik.
        READ TABLE ist_kid INTO wa_kid
           WITH KEY lifnr = wa_srcbsik-lifnr
                    kidno = wa_srcbsik-kidno.
        IF sy-subrc = 0.
          wa_srcbsik-subtot = wa_kid-dmbtr.
          wa_srcbsik-subgrp = wa_kid-subgrp.
          IF wa_srcbsik-subtot => 0.   "if subtotal is +ve or zero then this sub-group will be inactive
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Net receivable'.
          ENDIF.
          MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING subtot inactiv subgrp reason.
        ENDIF.
        CLEAR: wa_srcbsik, wa_kid.
      ENDLOOP.

* Restore Pay Ref that were temporarily changed.
      SORT ist_srcbsik  BY lifnr kidno rebzg.  " before restoring kidno, sort tables in proper order for future use.
      SORT ist_srcbsik_inactiv  BY lifnr kidno rebzg.
      LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
        READ TABLE ist_srcbsik_orig INTO wa_srcbsik_orig
            WITH KEY serial_no = wa_srcbsik-serial_no.
        wa_srcbsik-kidno = wa_srcbsik_orig-kidno.
        MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING kidno.
      ENDLOOP.
*end of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778

*Begin of <RD1K975843> CAB_ALOK CR 30005441
** 6. Warning for Due Date in future.
* In case due date (ZFBDT) is greater than today's date by more than 7 days, give caution in main list.
      LOOP AT ist_srcbsik INTO wa_srcbsik .
        clear t_days_diff.
        t_days_diff = wa_srcbsik-zfbdt - sy-datum .
        if t_days_diff > 7.
          wa_srcbsik-reason = 'Due Date in future'.
          MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING reason.
        endif.
      ENDLOOP.

** 7. Validation on linked documents: Pymt Method in linked docs should be same
      DATA : ist_srcbsik_tmp       LIKE STANDARD TABLE OF ist_srcbsik,
             wa_srcbsik_tmp        LIKE line OF ist_srcbsik,
             zlsch_inconsistent(1) .

      ist_srcbsik_tmp[] = ist_srcbsik[].
      sort ist_srcbsik_tmp by subgrp.
      delete ADJACENT DUPLICATES FROM ist_srcbsik_tmp comparing subgrp.

      clear wa_srcbsik_tmp.
      loop at ist_srcbsik_tmp into wa_srcbsik_tmp .
        loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp.
          if wa_srcbsik_tmp-zlsch <> wa_srcbsik-zlsch.
            zlsch_inconsistent = 'X'. "at-least one mismatch of ZLSCH found, set Flag.
          endif.
        endloop.
        if zlsch_inconsistent = 'X'.
          loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Inconsistent PM in Docs'.
            MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv reason.
          endloop.
        endif.
        clear: zlsch_inconsistent, wa_srcbsik_tmp.
      endloop.


*Begin of <RD1K975843> CAB_ALOK CR 30005441
** 4a.  In case P_BUKRS in table 'ZFI_C_N_B_CC1' (ONGC comp codes) and line-ZLSCH  in table 'ZFI_C_B_BLOCKPM1'
*  check line-ZLSCH same as LFB1-ZWELS where LFB1-LIFNR = S_LIFNR-LOW and LFB1-BUKRS = P_BUKRS.

      clear: WA_ZFI_C_N_B_CC1, WA_ZFI_C_B_BLOCKPM1.

      select single * from ZFI_C_N_B_CC1
        into WA_ZFI_C_N_B_CC1
          where BUKRS = P_BUKRS.

      if sy-subrc = 0. "comp. code found in table ZFI_C_N_B_CC1

        REFRESH ist_vend.
        SELECT lifnr bukrs zwels  INTO CORRESPONDING FIELDS OF TABLE ist_vend
          FROM lfb1
            FOR ALL ENTRIES IN ist_srcbsik
             WHERE lifnr = ist_srcbsik-lifnr
             AND bukrs = p_bukrs.  "#EC CI_NOORDER
        CLEAR: wa_srcbsik.

        LOOP AT ist_srcbsik INTO wa_srcbsik.
          l_tabix = sy-tabix.

          select single * from ZFI_C_B_BLOCKPM1
             into WA_ZFI_C_B_BLOCKPM1
               where ZLSCH = wa_srcbsik-zlsch.

          if sy-subrc = 0. " paymt method zlsch found in table ZFI_C_B_BLOCKPM1
            READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
                                                        bukrs = wa_srcbsik-bukrs  .

            If  wa_srcbsik-zlsch <> wa_vend-zwels.
              wa_srcbsik-inactiv = 'X'.
              wa_srcbsik-reason = 'Diff Pymt Method in vendor master'. " 'Pymt Method Mismatch'.
              MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
            Endif.
          endif." /sy-subrc = 0. " paymt method zlsch

          CLEAR: wa_srcbsik.
        Endloop.

      endif. " /sy-subrc = 0. "comp. code

** 4b. In case P_BUKRS in table 'ZFI_C_N_B_CC2'(OVL comp codes) and line-ZLSCH  in table 'ZFI_C_B_BLOCKPM2',
*  check line-ZLSCH same as LFB1-ZWELS where LFB1-LIFNR = S_LIFNR-LOW and LFB1-BUKRS = P_BUKRS.
      clear: WA_ZFI_C_N_B_CC2, WA_ZFI_C_B_BLOCKPM2.

      select single * from ZFI_C_N_B_CC2
        into WA_ZFI_C_N_B_CC2
          where BUKRS = P_BUKRS.

      if sy-subrc = 0. "comp. code found in table ZFI_C_N_B_CC2

        REFRESH ist_vend.
        SELECT lifnr bukrs zwels  INTO CORRESPONDING FIELDS OF TABLE ist_vend
          FROM lfb1
            FOR ALL ENTRIES IN ist_srcbsik
             WHERE lifnr = ist_srcbsik-lifnr
             AND bukrs = p_bukrs.  "#EC CI_NOORDER
        CLEAR: wa_srcbsik.

        LOOP AT ist_srcbsik INTO wa_srcbsik.
          l_tabix = sy-tabix.

          select single * from ZFI_C_B_BLOCKPM2
             into WA_ZFI_C_B_BLOCKPM2
               where ZLSCH = wa_srcbsik-zlsch.

          if sy-subrc = 0. " paymt method zlsch found in table ZFI_C_B_BLOCKPM2
            READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
                                                        bukrs = wa_srcbsik-bukrs  .

            If  wa_srcbsik-zlsch <> wa_vend-zwels.
              wa_srcbsik-inactiv = 'X'.
              wa_srcbsik-reason = 'Diff Pymt Method in vendor master'.    " 'Pymt Method Mismatch'.
              MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
            Endif.
          endif." /sy-subrc = 0. " paymt method zlsch

          CLEAR: wa_srcbsik.
        Endloop.

      endif. " /sy-subrc = 0. "comp. code

*End of <RD1K975843> CAB_ALOK CR 30005441


** 8. Validation on linked documents:
* Send whole set of linked docs to exception, if
*     a) due date in Rec doc > curr date
*     OR b) due date in Rec doc > liab doc
* above conditions modified:
*     a1) RD > CD > LD
*     OR b1) RD > LD > CD , where CD - Current system date, RD - Due date in Recovery document,
*                              LD - Due date in Liability document

      data: due_date_flag(1) .
      refresh ist_srcbsik_tmp.
      ist_srcbsik_tmp[] = ist_srcbsik[].
      sort ist_srcbsik_tmp by subgrp.
      delete  ist_srcbsik_tmp where SHKZG <> 'H'.  " store only Liab. docs.
*    delete ADJACENT DUPLICATES FROM ist_srcbsik_tmp comparing subgrp.
      clear wa_srcbsik_tmp.
      loop at ist_srcbsik_tmp into wa_srcbsik_tmp .   " Liab docs
        loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp and SHKZG = 'S'.  "Recov. Docs of the same sub-grp as Liab doc

*       if ( wa_srcbsik-zfbdt > sy-datum ) or ( wa_srcbsik-zfbdt > wa_srcbsik_tmp-zfbdt ) .
          if ( ( wa_srcbsik-zfbdt > sy-datum ) and ( sy-datum > wa_srcbsik_tmp-zfbdt ) )  " modified conditions
            or ( ( wa_srcbsik-zfbdt > wa_srcbsik_tmp-zfbdt ) and ( wa_srcbsik_tmp-zfbdt > sy-datum ) ).
            due_date_flag = 'X'. "at-least one due date valiadation failed, set Flag.
          endif.
        endloop.
        if due_date_flag = 'X'.
          loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp.
            wa_srcbsik-inactiv = 'X'.
            wa_srcbsik-reason = 'Due date in future'.
            MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv reason.
          endloop.
        endif.
        clear: due_date_flag, wa_srcbsik_tmp.
      endloop.
*End of <RD1K975843> CAB_ALOK CR 30005441

* move inactive lines to ist_srcbsik_inactiv
      LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
        APPEND wa_srcbsik TO ist_srcbsik_inactiv.
      ENDLOOP.
      DELETE ist_srcbsik WHERE inactiv = 'X'.

    ENDIF.                                                  " p_x2sp
  endif. " ist_srcbsik
ENDFORM.                    " VALIDATE_DOCS
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DOCS_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_docs_cust .
*BEGIN OF <rd1k967585> cab_alok 26.11.2009 cr30002778
  DATA : ist_kid LIKE  ist_srcbsid OCCURS 0.
* end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
  DATA : wa_kid LIKE ist_srcbsid.
  DATA : g_actflag TYPE c.
  DATA :l_dmbtr TYPE bseg-dmbtr.
*BEGIN OF <rd1k967585> cab_alok 26.11.2009 cr30002778
  DATA :l_tabix TYPE sy-tabix.
* end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
  IF p_x2sp = 'X'.
** BEGIN OF <rd1k967585> cab_alok 04.12.2009 cr30002778

*  ENDIF.
**----custor blocked ????
*  TYPES :BEGIN OF ty_cust,
*         kunnr TYPE knb1-kunnr ,
*         bukrs TYPE knb1-bukrs,
*         sperr TYPE knb1-sperr,
*         zahls TYPE knb1-zahls,
*         loevm TYPE knb1-loevm,
*         END OF ty_cust.
*
*  DATA :ist_cust TYPE TABLE OF ty_cust.
*  DATA :wa_cust TYPE ty_cust.
*  DATA :l_tabix TYPE sy-tabix.
*
*  SELECT kunnr bukrs sperr zahls loevm  INTO TABLE ist_cust
*    FROM knb1
*    FOR ALL ENTRIES IN ist_srcbsid
*    WHERE kunnr = ist_srcbsid-kunnr
*    AND bukrs = p_bukrs.
*
*  LOOP AT ist_srcbsid INTO wa_srcbsid.
*    l_tabix = sy-tabix.
*    READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr.
*    IF sy-subrc = 0.
*      IF wa_cust-sperr = 'X'.
*        wa_srcbsid-inactiv = 'X'.
*        wa_srcbsid-reason = 'Posting block for compnay code'.
*      ELSEIF wa_cust-zahls = 'X'.
*        wa_srcbsid-inactiv = 'X'.
*        wa_srcbsid-reason = 'Blocked for Payment'.
*      ELSEIF wa_cust-loevm = 'X'.
*        wa_srcbsid-inactiv = 'X'.
*        wa_srcbsid-reason = 'Marked for Deletion'.
*      ENDIF.
*      MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING
*            inactiv reason.
*    ENDIF.
*
*  ENDLOOP.
* =============
*** Validate ist_srcbsid for different conditions and move inactive items into ist_srcbsid_inactiv

** add serial no. to ist_srcbsid
    DATA srno TYPE i. "serial no.
    srno = 0.
    LOOP AT ist_srcbsid INTO wa_srcbsid.
      srno = srno + 1.
      wa_srcbsid-serial_no = srno.
      MODIFY ist_srcbsid FROM wa_srcbsid TRANSPORTING serial_no.
    ENDLOOP.
** save original ist_srcbsid
*ist_srcbsid_orig = ist_srcbsid
    ist_srcbsid_orig[] = ist_srcbsid[].
*** Check each line of ist_srcbsid:
** if customer is blocked or deleted, put the reason and make the line item inactive

    SORT ist_srcbsid  BY kunnr kidno.
    TYPES :BEGIN OF ty_cust,
*         kunnr TYPE kna1-kunnr ,  "char 10
             kunnr TYPE vcnum-ccnum,                          "char 25
             bukrs TYPE knb1-bukrs,
             sperr TYPE knb1-sperr,
             zahls TYPE knb1-zahls,
             loevm TYPE knb1-loevm,
             ktokd TYPE kna1-ktokd,     " account grp
           END OF ty_cust.

    DATA : ist_cust TYPE TABLE OF ty_cust.
    DATA : wa_cust TYPE ty_cust.

    TYPES :BEGIN OF ty_imprest,
             cardno TYPE zfiimprest-cardno,
             ackon  TYPE zfiimprest-ackon,
           END OF ty_imprest.

    DATA : ist_imprest TYPE TABLE OF ty_imprest.
    DATA : wa_imprest TYPE ty_imprest.

    TYPES :BEGIN OF ty_vcnum,
             ccnum TYPE vcnum-ccnum ,   "card no.,  char(25)
             datbi TYPE vcnum-datbi ,   " Exp. date
           END OF ty_vcnum.

    DATA : ist_vcnum TYPE TABLE OF ty_vcnum.
    DATA : wa_vcnum TYPE ty_vcnum.

    DATA : tmp_kunnr TYPE vcnum-ccnum.   "card no.,  char(25), temp holding.

** 1. For a given customer, posting blocked or marked deleted for given company code?
    SELECT kunnr bukrs sperr zahls loevm  INTO TABLE ist_cust
      FROM knb1
      FOR ALL ENTRIES IN ist_srcbsid
      WHERE kunnr = ist_srcbsid-kunnr
      AND bukrs = p_bukrs.
*{ Begin of CR 30007632
    data : ist_zfiimprest   type standard table of zfiimprest,
           ist_zfiimprest_l type standard table of zfiimprest,
           wa_zfiimprest    type zfiimprest.
    clear :ist_zfiimprest.
    refresh :ist_zfiimprest.
    select * from zfiimprest
      into corresponding fields of table ist_zfiimprest
      FOR ALL ENTRIES IN ist_srcbsid
          WHERE cardno = ist_srcbsid-kunnr.  "#EC CI_NOORDER


*}End of CR 30007632
    CLEAR: wa_srcbsid.
    LOOP AT ist_srcbsid INTO wa_srcbsid.
      l_tabix = sy-tabix.
*{ Begin of CR 30007632
      if wa_srcbsid-SHKZG = 'H'.
        if not ist_zfiimprest[] is initial.
          read table ist_zfiimprest into wa_zfiimprest index 1.  "#EC CI_NOORDER
          if wa_zfiimprest-reqstat = 'RET'.
            wa_srcbsid-inactiv = 'X'.
            wa_srcbsid-reason = 'Imprest card with RET status'.
          endif.
        endif.
      endif.
*}End of CR 30007632
      data : l_stat(12) type c.
      clear l_stat.
      if not ist_zfiimprest[] is initial.
        loop at ist_zfiimprest into wa_zfiimprest where cardno = wa_srcbsid-kunnr.
          append wa_zfiimprest to ist_zfiimprest_l.
        endloop.
        if wa_srcbsid-shkzg = 'H'.
          if not ist_zfiimprest_l[] is initial.
*            sort ist_zfiimprest_l by reqno descending.
            sort ist_zfiimprest_l by ACKON descending.
            read table ist_zfiimprest_l into wa_zfiimprest index 1.
*{Begin of CR 30014106
            if wa_zfiimprest-REQSTAT = 'ACK'.

            else.
              wa_srcbsid-inactiv = 'X'.
              concatenate 'Card no' wa_srcbsid-kunnr 'is not acknowledged by the employee in webice' into wa_srcbsid-reason.
            endif.
*}End of CR 30014106
            if wa_zfiimprest-REQSTAT = 'RET' or wa_zfiimprest-REQSTAT = 'SUR'.
              wa_srcbsid-inactiv = 'X'.
              wa_srcbsid-reason = 'PREPAID CARD'.
              if wa_zfiimprest-REQSTAT = 'RET'.
                l_stat = 'Returned'.
              elseif wa_zfiimprest-REQSTAT = 'SUR'.
                l_stat = 'Surrendered'.
              endif.
*{Begin of CR 30014106
*              concatenate wa_srcbsid-reason text-012 l_stat into wa_srcbsid-reason separated by space.
                            wa_srcbsid-reason = 'Recent Prepaid Card'.
              concatenate wa_srcbsid-reason text-014 into wa_srcbsid-reason separated by space.
*}End of CR 30014106
            endif.
          endif.
        endif.
      endif.
      READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr
                                                 bukrs = wa_srcbsid-bukrs  .
      IF sy-subrc = 0.
        IF wa_cust-sperr = 'X'.
          wa_srcbsid-inactiv = 'X'.
          wa_srcbsid-reason = 'Posting blocked for company code'.
        ELSEIF wa_cust-zahls = 'X'.
          wa_srcbsid-inactiv = 'X'.
          wa_srcbsid-reason = 'Blocked for Payment'.
        ELSEIF wa_cust-loevm = 'X'.
          wa_srcbsid-inactiv = 'X'.
          wa_srcbsid-reason = 'Marked for Deletion-company code level'.
        ENDIF.
        MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
      ENDIF.
      CLEAR: wa_srcbsid.
    ENDLOOP.

** 2. For a given customer, posting blocked or deleted for all company codes?
    REFRESH ist_cust.
    SELECT kunnr loevm sperr INTO CORRESPONDING FIELDS OF TABLE ist_cust
      FROM kna1
      FOR ALL ENTRIES IN ist_srcbsid
      WHERE kunnr = ist_srcbsid-kunnr.  "#EC CI_NOORDER
    CLEAR: wa_srcbsid.
    LOOP AT ist_srcbsid INTO wa_srcbsid.
      l_tabix = sy-tabix.
      READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr.
      IF sy-subrc = 0.
        IF wa_cust-sperr = 'X'.
          wa_srcbsid-inactiv = 'X'.
          wa_srcbsid-reason = 'Central Posting blocked'.
        ELSEIF wa_cust-loevm = 'X'.
          wa_srcbsid-inactiv = 'X'.
          wa_srcbsid-reason = 'Central Deletion Flag'.
        ENDIF.
        MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
      ENDIF.
      CLEAR: wa_srcbsid.
    ENDLOOP.

** 3. card customer? old logic: found in ZFIIMPREST table? if date ZFIIMPREST-ACKON = 00000000 => not acknowledged? => exception
**  Revised logic for card customer
*a. get Customer number with account group as IMPR
*b. Concatenate 421687 to the customer number to get the card number
*c. Search this card number in table VCNUM for record where Exp date is not blank and is greater than system date
*d. All such sucessful lines shud be put in active list else in exception list
******** BOOK MARK
    SELECT kunnr ktokd INTO CORRESPONDING FIELDS OF TABLE ist_cust " select all card customers of ist_srcbsid
          FROM kna1                                                 " into ist_cust. (condition: corresponding  a/c grp KNA1-ktokd shud be 'IMPR'
          FOR ALL ENTRIES IN ist_srcbsid
          WHERE kunnr = ist_srcbsid-kunnr
                AND ktokd = 'IMPR'.

*SELECT cardno ackon INTO CORRESPONDING FIELDS OF TABLE ist_imprest "  for all card customers (ist_cust)
*      FROM zfiimprest                                                 " select data (Card No. i.e. kunnr & ACK Date) from ZFIIMPREST into ist_imprest.
*      FOR ALL ENTRIES IN ist_cust
*      WHERE cardno = ist_cust-kunnr.
***            and ackon <> ''.

    LOOP AT ist_cust INTO wa_cust.
      l_tabix = sy-tabix.
      CONCATENATE '421687' wa_cust-kunnr INTO wa_cust-kunnr.
      MODIFY ist_cust FROM wa_cust INDEX l_tabix TRANSPORTING kunnr.
    ENDLOOP.

    SELECT ccnum datbi INTO CORRESPONDING FIELDS OF TABLE ist_vcnum "  for all card customers (ist_cust)
          FROM vcnum
          FOR ALL ENTRIES IN ist_cust
          WHERE ccnum = ist_cust-kunnr.

*SORT ist_imprest BY cardno ASCENDING.
*   DELETE ADJACENT DUPLICATES FROM ist_imprest COMPARING cardno.

*    CLEAR: wa_srcbsid.
*    LOOP AT ist_srcbsid INTO wa_srcbsid.
*      l_tabix = sy-tabix.
*      READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr .
*       IF sy-subrc = 0. " => kunnr is a card-customer. Now check whether it exists in ZFIIMPREST or not
*         READ TABLE ist_imprest into wa_imprest with key cardno = wa_srcbsid-kunnr.
*           if sy-subrc = 0. " => cardno found in ZFIIMPREST, now we need to check its ACKON
*              if wa_imprest-ackon = 0.    "if ACKON date = 00000000, corresponding ist_srcbsid line shud be inactive
*                  wa_srcbsid-inactiv = 'X'.
*                  wa_srcbsid-reason = 'Card customer, no ACK'.
*              endif.
*           else.  "cardno not found in ZFIIMPREST, corresponding ist_srcbsid line shud be inactive.
*             wa_srcbsid-inactiv = 'X'.
*             wa_srcbsid-reason = 'Card customer, not in ZFIIMPREST'.
*           endif.
*           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
*       endif.
*
*    ENDLOOP.

    CLEAR: wa_srcbsid.
    LOOP AT ist_srcbsid INTO wa_srcbsid.
      l_tabix = sy-tabix.
      CONCATENATE '421687' wa_srcbsid-kunnr INTO tmp_kunnr.
      READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = tmp_kunnr .
      IF sy-subrc = 0. " => kunnr is a card-customer. Now check whether it exists in ZFIIMPREST or not
        READ TABLE ist_vcnum INTO wa_vcnum WITH KEY ccnum = tmp_kunnr.
        IF sy-subrc = 0. " => cardno found in VCNUM, now we need to check its Expiry Date (DATBI)
          IF wa_vcnum-datbi < sy-datum.    "if EXP date < current date, corresponding ist_srcbsid line shud be inactive
            wa_srcbsid-inactiv = 'X'.
            wa_srcbsid-reason = 'Card customer, curr date>Exp date '.
          ENDIF.
        ELSE.  "cardno not found in VCNUM, corresponding ist_srcbsid line shud be inactive.
          wa_srcbsid-inactiv = 'X'.
          wa_srcbsid-reason = 'Card customer, not in VCNUM'.
        ENDIF.
        MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
      ENDIF.

    ENDLOOP.

*begin of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
*Move inactive lines to ist_srcbsid_inactiv
    ist_srcbsid_inactiv[] = ist_srcbsid[].
    DELETE ist_srcbsid_inactiv WHERE inactiv <> 'X'. "ist_srcbsid_inactiv contains inactive items
    DELETE ist_srcbsid WHERE inactiv = 'X'.  "ist_srcbsid contains active items
*end of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778

  ENDIF. "p_x2sp = 'X
** end OF <rd1k967585> cab_alok 04.12.2009 cr30002778
ENDFORM.                    " VALIDATE_DOCS_CUST
*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT_INACTIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
FORM init_fieldcat_inactiv .
  w_repid  = sy-repid.
  mpos = 0.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'SELCBOX'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Inactiv'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  ist_fieldcat_inactiv-checkbox = 'X'.
*  ist_fieldcat_inactiv-input = 'X'.  " no input allowed.
*  ist_fieldcat_inactiv-edit = 'X'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'LIFNR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'VendorNumber'.
  ist_fieldcat_inactiv-seltext_m  = 'Vendor No.'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BELNR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Doc.No.'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'GSBER'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'Business Area'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'KIDNO'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'Payment Reference'.
  ist_fieldcat_inactiv-seltext_m  = 'Pymt Ref'.
*end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'REASON'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Reason'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'REBZG'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*    ist_fieldcat_inactiv-seltext_m  = 'Invoice Reference'.
  ist_fieldcat_inactiv-seltext_m  = 'Inv Ref'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'SHKZG'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'Indicator'.
**  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.
*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'GJAHR'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'Year'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BUZEI'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Item.no.'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BSCHL'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'Posting Key.'.
  ist_fieldcat_inactiv-seltext_m  = 'PK'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BUDAT'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'Posting Date'.
  ist_fieldcat_inactiv-seltext_m  = 'Post Dt'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

* begin RD1K975843 CAB_ALOK CR 30005441
  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'ZFBDT'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Due Dt.'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.
* end RD1K975843 CAB_ALOK CR 30005441

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'DMBTR'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'AmtInLclCurncy'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'SUBTOT'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'SubTotal'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'WRBTR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat_inactiv-seltext_m  = 'Amt In Doc Cur'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

* begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'WAERS'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Curr'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.
* end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'ZLSCH'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'PaymntMethod'.
  ist_fieldcat_inactiv-seltext_m  = 'PM'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'ZLSPR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'PaymntBlock'.
  ist_fieldcat_inactiv-seltext_m  = 'PB'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'XREF1_HD'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
*  ist_fieldcat_inactiv-seltext_m  = 'Location'.
  ist_fieldcat_inactiv-seltext_m  = 'Loc'.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
* IF NOT s_usnam IS INITIAL.
*    mpos = mpos + 1.
*    ist_fieldcat_inactiv-fieldname = 'USNAM'.
*    ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
*    ist_fieldcat_inactiv-ddictxt = 'M'.
*    ist_fieldcat_inactiv-col_pos =  mpos.
*    ist_fieldcat_inactiv-seltext_m  = 'Created By'.
*    ist_fieldcat_inactiv-lowercase  = 'Y'.
*    APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*    CLEAR ist_fieldcat_inactiv.
*  ENDIF.
*end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778



ENDFORM.                    " INIT_FIELDCAT_INACTIV
*end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INACTIVE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
FORM display_inactive_alv .    "inactive ALV of Vendors
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = w_repid
*     i_callback_pf_status_set = 'ALV_PFST'
*     i_callback_user_command  = 'MAKE_COMMAND'
      is_layout          = is_layout_inactiv
      it_fieldcat        = ist_fcat_inactiv
      it_sort            = lt_sorttab
      it_events          = gt_events_inactiv
      i_save             = 'A'
    TABLES
      t_outtab           = ist_srcbsik_inactiv
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " DISPLAY_INACTIVE_ALV
*End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT_INACTIV_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
FORM init_fieldcat_inactiv_cust .

  w_repid  = sy-repid.
  mpos = 0.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'SELCBOX'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Select'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  ist_fieldcat_inactiv-checkbox = 'X'.
*  ist_fieldcat_inactiv-input = 'X'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'KUNNR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Cstmr No.'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BELNR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Doc.No.'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'GSBER'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'Business Area'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'KIDNO'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Pymt Ref'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'REASON'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Reason'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'REBZG'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Inv Ref'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'SHKZG'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'INdicator'.
**  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.
*
*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'GJAHR'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'Year'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BUZEI'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Item.no.'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BSCHL'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'PK'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'BUDAT'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Post Dt'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*  mpos = mpos + 1.
*  ist_fieldcat_inactiv-fieldname = 'DMBTR'.
*  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
*  ist_fieldcat_inactiv-ddictxt = 'M'.
*  ist_fieldcat_inactiv-col_pos =  mpos.
*  ist_fieldcat_inactiv-seltext_m  = 'AmtInLclCurncy'.
*  ist_fieldcat_inactiv-lowercase  = 'Y'.
*  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'WRBTR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Amt In Doc Cur'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'WAERS'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Curr'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.
*end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'ZLSCH'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'PM'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'ZLSPR'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'PB'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

  mpos = mpos + 1.
  ist_fieldcat_inactiv-fieldname = 'XREF1_HD'.
  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
  ist_fieldcat_inactiv-ddictxt = 'M'.
  ist_fieldcat_inactiv-col_pos =  mpos.
  ist_fieldcat_inactiv-seltext_m  = 'Loc'.
  ist_fieldcat_inactiv-lowercase  = 'Y'.
  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
  CLEAR ist_fieldcat_inactiv.

*  IF NOT s_usnam IS INITIAL.
*    mpos = mpos + 1.
*    ist_fieldcat_inactiv-fieldname = 'USNAM'.
*    ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
*    ist_fieldcat_inactiv-ddictxt = 'M'.
*    ist_fieldcat_inactiv-col_pos =  mpos.
*    ist_fieldcat_inactiv-seltext_m  = 'Created By'.
*    ist_fieldcat_inactiv-lowercase  = 'Y'.
*    APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
*    CLEAR ist_fieldcat_inactiv.
*  ENDIF.

ENDFORM.                    " INIT_FIELDCAT_INACTIV_CUST
*end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
*&---------------------------------------------------------------------*
*&      Form  PRINT_MULTI_ALV_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Begin of <RD1K967585> CAB_ALOK 07.12.2009 CR30002778
FORM print_multi_alv_cust .

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = w_repid
      i_callback_pf_status_set = 'ALV_PFST'
      i_callback_user_command  = 'MAKEC_COMMAND'
      is_layout                = is_layout
      it_fieldcat              = ist_fcat[]
*     it_sort                  =            " data of ist_srcbsik already arranged in reqd grouping
      it_events                = gt_events
      i_save                   = 'A'
    TABLES
      t_outtab                 = ist_srcbsid
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " PRINT_MULTI_ALV_CUST
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INACTIVE_ALV_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_inactive_alv_cust .
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = w_repid
*     i_callback_pf_status_set = 'ALV_PFST'
*     i_callback_user_command  = 'MAKE_COMMAND'
      is_layout          = is_layout_inactiv
      it_fieldcat        = ist_fcat_inactiv
      it_sort            = lt_sorttab
      it_events          = gt_events_inactiv
      i_save             = 'A'
    TABLES
      t_outtab           = ist_srcbsid_inactiv
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " DISPLAY_INACTIVE_ALV_CUST

*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZFI_REM_PYBLCK_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zfi_rem_pyblck_l .
* update Logs to table ZFI_REM_PYBLCK_L
  DATA: ist_zfi_rem_pyblck_l TYPE TABLE OF zfi_rem_pyblck_l,
        wa_zfi_rem_pyblck_l  TYPE zfi_rem_pyblck_l.
  DATA: count TYPE zfi_rem_pyblck_l-srno.

*begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778

  IF p_x2sp = 'X'.
    pmtblock_to = ' '.
  ELSEIF p_sp2x = 'X'.
    pmtblock_to = 'X'.
  ELSEIF p_sp2r = 'X'.
    pmtblock_to = 'R'.
  ELSEIF p_x2s = 'X'.
    pmtblock_to = 'S'.
* Begin of RD1K971966 CAB_ALOK CR30004183
*  ELSEIF p_s2x = 'X'.
*    pmtblock_to = 'X'.
* end of RD1K971966 CAB_ALOK CR30004183
  ENDIF.

*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778

  SELECT MAX( srno ) FROM zfi_rem_pyblck_l INTO count.
  IF NOT ist_srcbsik IS INITIAL.

    LOOP AT ist_srcbsik INTO wa_srcbsik.
      count = count + 1.

      wa_zfi_rem_pyblck_l-srno = count.
      wa_zfi_rem_pyblck_l-bukrs = wa_srcbsik-bukrs.
      wa_zfi_rem_pyblck_l-lifnr = wa_srcbsik-lifnr.
*wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
      wa_zfi_rem_pyblck_l-belnr = wa_srcbsik-belnr.
      wa_zfi_rem_pyblck_l-kidno = wa_srcbsik-kidno.
      wa_zfi_rem_pyblck_l-rebzg = wa_srcbsik-rebzg.
      wa_zfi_rem_pyblck_l-shkzg = wa_srcbsik-shkzg.
      wa_zfi_rem_pyblck_l-gjahr = wa_srcbsik-gjahr.
      wa_zfi_rem_pyblck_l-buzei = wa_srcbsik-buzei.
      wa_zfi_rem_pyblck_l-bschl = wa_srcbsik-bschl.
      wa_zfi_rem_pyblck_l-budat = wa_srcbsik-budat.
      wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsik-dmbtr .
      wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsik-wrbtr .
      wa_zfi_rem_pyblck_l-zlsch = wa_srcbsik-zlsch.
      wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsik-zlspr.
      wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
      wa_zfi_rem_pyblck_l-location = wa_srcbsik-xref1_hd.
      wa_zfi_rem_pyblck_l-uname = sy-uname.
      wa_zfi_rem_pyblck_l-usdate = sy-datum.
      wa_zfi_rem_pyblck_l-ustime = sy-uzeit.

      INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
    ENDLOOP.
    COMMIT WORK.
    REFRESH ist_srcbsik.
  ENDIF.

  IF NOT ist_srcbsid IS INITIAL.

    LOOP AT ist_srcbsid INTO wa_srcbsid.
      count = count + 1.

      wa_zfi_rem_pyblck_l-srno = count.
      wa_zfi_rem_pyblck_l-bukrs = wa_srcbsid-bukrs.
*   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
      wa_zfi_rem_pyblck_l-kunnr = wa_srcbsid-kunnr.
      wa_zfi_rem_pyblck_l-belnr = wa_srcbsid-belnr.
      wa_zfi_rem_pyblck_l-kidno = wa_srcbsid-kidno.
      wa_zfi_rem_pyblck_l-rebzg = wa_srcbsid-rebzg.
      wa_zfi_rem_pyblck_l-shkzg = wa_srcbsid-shkzg.
      wa_zfi_rem_pyblck_l-gjahr = wa_srcbsid-gjahr.
      wa_zfi_rem_pyblck_l-buzei = wa_srcbsid-buzei.
      wa_zfi_rem_pyblck_l-bschl = wa_srcbsid-bschl.
      wa_zfi_rem_pyblck_l-budat = wa_srcbsid-budat.
      wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsid-dmbtr .
      wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsid-wrbtr .
      wa_zfi_rem_pyblck_l-zlsch = wa_srcbsid-zlsch.
      wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsid-zlspr.
      wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
      wa_zfi_rem_pyblck_l-location = wa_srcbsid-xref1_hd.
      wa_zfi_rem_pyblck_l-uname = sy-uname.
      wa_zfi_rem_pyblck_l-usdate = sy-datum.
      wa_zfi_rem_pyblck_l-ustime = sy-uzeit.

      INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
    ENDLOOP.
    COMMIT WORK.
    REFRESH ist_srcbsid.
  ENDIF.
ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
*end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778

*Begin of <RD1K975843> CAB_ALOK CR 30005441
FORM VALIDATE_LIAB_DOC_CREDIT_MEMO .
** In case credit memo exists against a PO, system should permit removal
*  of block from liability document only if both liability doc and credit
*   memo are selected for block removal.
  Tables: setleaf.
  data: T_AWKEY type BKPF-AWKEY,
        T_BELNR type RSEG-BELNR,
        T_GJAHR type RSEG-GJAHR,
        T_EBELN type RSEG-EBELN.

  types: begin of TY_EKBE1.
          include STRUCTURE EKBE.
  types:  AWKEY1 type BKPF-AWKEY,
          end of TY_EKBE1.

  data: IST_EKBE1 type STANDARD TABLE OF TY_EKBE1,
        WA_EKBE1  type TY_EKBE1,
        IST_BKPF1 type STANDARD TABLE OF BKPF,
        IST_BSIK1 type STANDARD TABLE OF BSIK,
        WA_BSIK1  type BSIK.
  DATA: ist_srcbsik_tmp LIKE STANDARD TABLE OF ist_srcbsik,
        wa_srcbsik_tmp  LIKE line of ist_srcbsik.
  data: del_flag(1),
        srcbsik_tabix type sy-tabix.

  refresh: IST_MSG. "for storing msgs.
  clear: wa_srcbsik, WA_MSG.
* currently ist_srcbsik contains only selected lines ( selcbox : 'X')
  Sort ist_srcbsik by LIFNR BUKRS BELNR.

  loop at ist_srcbsik into wa_srcbsik where SHKZG = 'H'.
    clear:  T_AWKEY, T_BELNR, T_GJAHR, T_EBELN.
    srcbsik_tabix = sy-tabix.
*get Reference Key(BKPF-AWKEY) from BKPF table for current line of ist_srcbsik,
    SELECT SINGLE AWKEY
      from BKPF
        into T_AWKEY
         where BUKRS = wa_srcbsik-BUKRS
           and BELNR = wa_srcbsik-BELNR
           and GJAHR = wa_srcbsik-GJAHR.

    IF T_AWKEY+0(1) = '5'.

      T_BELNR = T_AWKEY+0(10).  " Doc No.
      T_GJAHR = T_AWKEY+10(4).  " Year
*Get Purchase doc No
      select single EBELN
        from RSEG
          into T_EBELN
            where BELNR = T_BELNR
               and GJAHR = T_GJAHR.  "#EC CI_NOORDER
      if T_EBELN is not initial.
*if this PO is not maintained in set "PO_Cr_memo" pass this value into Table EKBE
        select single * from SETLEAF
          where SETCLASS = '0000'
            and SETNAME  = 'PO_CR_MEMO'
            and VALFROM  = T_EBELN.
        if sy-subrc <> 0.
* then check PO history in EKBE
*   get  BELNR + GJAHR  = AWKEY1
          select * from EKBE
             into CORRESPONDING FIELDS OF TABLE IST_EKBE1
               where EBELN = T_EBELN
                 and ( BEWTP = 'N' or BEWTP = 'P' or BEWTP = 'Q' or BEWTP = 'R' )
                 and SHKZG = 'H'.

          if IST_EKBE1 is not initial.
            loop at IST_EKBE1 into WA_EKBE1.
              CONCATENATE WA_EKBE1-BELNR WA_EKBE1-GJAHR into WA_EKBE1-AWKEY1.
              modify IST_EKBE1 from WA_EKBE1 .
            endloop.

*          search Document Header BKPF for above AWKEYs, get Credit memos(BELNR,BUKRS,LIFNR).
            select * from BKPF
              into CORRESPONDING FIELDS OF TABLE IST_BKPF1   " BELNR
                FOR ALL ENTRIES IN IST_EKBE1
                  WHERE AWKEY = IST_EKBE1-AWKEY1
                    and BUKRS = P_BUKRS
                    and GJAHR = IST_EKBE1-GJAHR
                    and STGRD = ''  "leave reversed doc
                    and BSTAT = '' .  "#EC CI_NOORDER


*          Check if open line items exist for above Credit Memos ( in same company code, same vendor) with payment block ='X'
            if IST_BKPF1 is not initial.
              select * from BSIK
                into CORRESPONDING FIELDS OF TABLE IST_BSIK1   " GJAHR
                  FOR ALL ENTRIES IN IST_BKPF1
                   WHERE LIFNR = WA_SRCBSIK-LIFNR
                     and BUKRS = IST_BKPF1-BUKRS
                     and BELNR = IST_BKPF1-BELNR
                     and ZLSPR = 'X'.  "#EC CI_NOORDER
              if IST_BSIK1 is not initial. "open credit memo exists
*               now check whether these Credit memo have been selected on ALV screen (i.e.exist in current IST_SRCBSIK)
                loop at IST_BSIK1 into WA_BSIK1.
                  read TABLE ist_srcbsik INTO wa_srcbsik_tmp
                    WITH KEY LIFNR = WA_BSIK1-LIFNR
                             BUKRS = WA_BSIK1-BUKRS
                             BELNR = WA_BSIK1-BELNR
                          BINARY SEARCH.
                  if sy-subrc = 0. " credit-memo found in selected ALV lines, store for later deletion(if related Liab. doc. is being deleted) .
                    wa_srcbsik_tmp-inactiv = 'X'.
                    append wa_srcbsik_tmp to ist_srcbsik_tmp.

                  else." credit-memo not found in selected ALV lines, store these LIV DOC - open Credit memo line items to Warning MSGs.
                    clear wa_msg.
                    concatenate wa_srcbsik-LIFNR ' ' wa_srcbsik-BUKRS wa_srcbsik-GJAHR ' ' wa_srcbsik-BELNR
                                into wa_msg-LIV_DOC RESPECTING BLANKS.
                    concatenate WA_BSIK1-LIFNR ' ' WA_BSIK1-BUKRS WA_BSIK1-BELNR
                                into wa_msg-CREDIT_MEMO RESPECTING BLANKS.
                    append wa_msg to ist_msg.
                    del_flag = 'X'. "atleast one credit-memo not found in selected ALV lines
                  endif.
                endloop. "/at IST_BSIK1

                if del_flag = 'X'.
                  "delete current Liability Doc from ist_srcbsik(current line of loop at ist_srcbsik ).
                  delete ist_srcbsik index srcbsik_tabix.
                  clear del_flag.
                  "also mark related credit memos for deletion in ist_srcbsik
                  loop at ist_srcbsik_tmp into wa_srcbsik_tmp.
                    modify ist_srcbsik from wa_srcbsik_tmp TRANSPORTING inactiv
                               where LIFNR = wa_srcbsik_tmp-LIFNR
                                 and BUKRS = wa_srcbsik_tmp-BUKRS
                                 and BELNR = wa_srcbsik_tmp-BELNR.
                  endloop.
                  refresh  ist_srcbsik_tmp.
                  clear wa_srcbsik_tmp.
                endif.  "/del_flag
              endif.                                        "/IST_BSIK1
            endif.                                          "/IST_BKPF1
          endif.                                            "/IST_EKBE1
        endif. "/sy-subrc
      endif. "/T_EBELN
    ENDIF. "/T_AWKEY
  endloop. "/ist_srcbsik
* finally delete invalid credit memos from ist_srcbsik.
  DELETE ist_srcbsik WHERE inactiv = 'X'.
ENDFORM.                    " VALIDATE_LIAB_DOC_CREDIT_MEMO

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_MESSAGES .
  if ist_msg is not initial.
    write:/ 'Following LIV docs were excluded from processing as related Credit memo(s) were not selected:'.
    write:/.
    write:/ '--------- LIV document -------       ------ Credit memo ------'.
*          0000107291 MUM 2011 7111000010     0000107291 MUM 7111000007

    loop at ist_msg into wa_msg.
      write:/ wa_msg-LIV_DOC, '     ', wa_msg-CREDIT_MEMO.
    endloop.
  endif.
  refresh ist_msg.
  clear wa_msg.
ENDFORM.                    " DISPLAY_MESSAGES
*end of <RD1K975843> CAB_ALOK CR 30005441
*&---------------------------------------------------------------------*
*&      Form  GET_BUDGET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_SRCBSIK_L_BUKRS  text
*      -->P_WA_SRCBSIK_L_FISTL  text
*      -->P_WA_SRCBSIK_L_FIPOS  text
*      -->P_WA_SRCBSIK_L_GJAHR  text
*      <--P_G_BUDGET  text
*----------------------------------------------------------------------*
FORM GET_BUDGET  USING    P_BUKRS
                          P_FISTL
                          P_FIPOS
                          P_GJAHR
                 CHANGING P_BUDGET.

  DATA : ist_abaplist TYPE STANDARD TABLE OF abaplist.

  DATA: BEGIN OF ist_ascitab OCCURS 1,
          line(1000),
        END OF ist_ascitab.

  DATA : wa_ascitab LIKE ist_ascitab.

  DATA : l_menge TYPE eban-menge.

  DATA : l_pr_concur(20),
         l_avl_budgt(30),
         l_dis_budgt(30),
         l_ass_budgt(30).


  DATA : wa_xbseg TYPE bseg.

  DATA : l_eindt   TYPE sy-datum, "eket-eindt,
         l_year_po TYPE bkpf-gjahr,
         l_year_fi TYPE bkpf-gjahr.

  DATA : l_fikrs     TYPE fkrs-fikrs,
         l_budget    TYPE fmit-hsl16,
         l_budget_d  TYPE fmit-hsl16,
         l_budget_as TYPE fmit-hsl16,
         l_budget_av TYPE fmit-hsl16.

  DATA : l_fistl TYPE fistl,    "ekpo-fistl
         l_fipos TYPE fm_fipex. "ekpo-fipos.

  DATA : l_bukrs      TYPE t001-bukrs,
         l_budat      TYPE sy-datum,
         ist_fmavc001 TYPE TABLE OF fmavc001,
         wa_fmavc001  TYPE fmavc001.

  DATA : l_dmbtr TYPE bseg-dmbtr.
* SELECT MAX( gjahr ) FROM fmioi INTO l_year_po
*        WHERE refbn = bseg-ebeln AND
*              rfpos = bseg-ebelp AND
*              cfstat IN ('00','32').
*  CALL FUNCTION 'FI_PERIOD_DETERMINE'
*      EXPORTING
*        i_budat     = bkpf-budat
*        i_periv     = 'V3'
*      IMPORTING
*        e_gjahr     = l_year_fi
*      EXCEPTIONS
*        fiscal_year = 1.
*
*    IF sy-subrc <> 0.
**       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*
*    IF l_year_po NE l_year_fi.
*            IF NOT bseg-fistl IS INITIAL AND NOT bseg-fipos IS INITIAL.
*        MOVE bkpf-bukrs TO l_bukrs.
*        MOVE bseg-fistl TO l_fistl.
*        MOVE bseg-fipos TO l_fipos.
*        MOVE bkpf-budat TO l_budat.
*
*CALL FUNCTION 'FM_BUDGET_READ_BBP'
*          EXPORTING
*            i_bukrs       = l_bukrs
*            i_date        = l_budat
*            i_funds_ctr   = l_fistl
*            i_commt_item  = l_fipos
*          TABLES
*            t_bp_obj      = ist_fmavc001
*          EXCEPTIONS
*            error_occured = 1
*            OTHERS        = 2.
*
*        IF sy-subrc <> 0.
**            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*

*        IF NOT ist_fmavc001[] IS INITIAL.
*
*          READ TABLE ist_fmavc001 INTO wa_fmavc001 INDEX 1.
* l_dmbtr =  ( wa_fmavc001-distributable -
*                       wa_fmavc001-assigned ) / 100.
*
*                  ENDIF.
  SUBMIT  zfifm_annual_budget
                 EXPORTING LIST TO MEMORY AND RETURN
                      WITH s_fikrs = P_BUKRS
                      WITH s_fictr = P_FISTL
                      WITH s_fipos = P_FIPOS
                      WITH s_gjahr = P_GJAHR.

  CALL FUNCTION 'LIST_FROM_MEMORY'
    TABLES
      listobject = ist_abaplist
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'LIST_TO_ASCI'
    TABLES
      listobject = ist_abaplist
      listasci   = ist_ascitab.

  LOOP AT ist_ascitab INTO wa_ascitab.
    WRITE :/ wa_ascitab-line.
  ENDLOOP.

  IF NOT ist_ascitab[] IS INITIAL.
    READ TABLE ist_ascitab INTO wa_ascitab INDEX 10.
*    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
*{Begin of CR 30007900
    clear :ist_budget,
           wa_budget,
           l_dis_budgt,
           g_BUDGET_c,
           l_budget.
    refresh ist_budget.

    SPLIT wa_ascitab AT '|' INTO TABLE ist_budget.
*}end of CR 30007900
    IF sy-subrc = 0.
*{Begin of CR 30007900
*      l_pr_concur = wa_ascitab+141(20).
*      l_avl_budgt = wa_ascitab+162(14).

*      READ TABLE ist_budget INTO wa_budget INDEX 11.
      READ TABLE ist_budget INTO wa_budget INDEX 7.
      if sy-subrc = 0.
        l_dis_budgt = wa_budget-row.
        condense l_dis_budgt.
      endif.
*}end of CR 30007900
*      WRITE :/ 'PRs Concurred by Finance :', l_pr_concur.
*      WRITE :/ 'Available budget         :', l_avl_budgt.


      clear : l_ass_budgt.
      READ TABLE ist_budget INTO wa_budget INDEX 8.
      if sy-subrc = 0.
        l_ass_budgt = wa_budget-row.
        condense l_ass_budgt.
      endif.

      clear : g_BUDGET_d.
      g_BUDGET_d = l_dis_budgt.
      condense g_BUDGET_d.
      perform convert_c_to_num using g_BUDGET_d changing l_budget_d.

*    l_avl_budgt = l_dis_budgt - l_ass_budgt.

      clear : g_BUDGET_as.
      g_BUDGET_as = l_ass_budgt.
      condense g_BUDGET_as.
      perform convert_c_to_num using g_BUDGET_as changing l_budget_as.

    ENDIF.
  endif.
  l_budget_av = l_budget_d - l_budget_as.

  l_budget = l_budget_av.
  P_BUDGET = l_budget.
ENDFORM.                    " GET_BUDGET
*&---------------------------------------------------------------------*
*&      Form  CONVERT_C_TO_NUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_BUDGET_C  text
*      <--P_L_BUDGET_D  text
*----------------------------------------------------------------------*
FORM CONVERT_C_TO_NUM  USING    P_G_BUDGET_C
                       CHANGING P_L_BUDGET_D.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      CHR             = p_g_BUDGET_c
    IMPORTING
      NUM             = p_l_budget_d
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      CONVT_NO_NUMBER = 1
      CONVT_OVERFLOW  = 2
      OTHERS          = 3
* End of Changes on 20-Jun-2013
    .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " CONVERT_C_TO_NUM

*-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
  DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
  REFRESH lt_acchg. CLEAR ls_acchg.
  ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
  APPEND ls_acchg TO lt_acchg.
  CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
       i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
ENDFORM.
