REPORT zfi_chng_pyblck .

*-----  PROGRAM FOR Changing payment blocks 'X'  ****
***********************************************************************
* Program    :                                                        *
*                                                                     *
*                                                                     *
* Author     : S.R.Sudha                     Date : 14.03.2008
*
*                                                                     *
* Login Id   : CAB_SUDHA                                              *
*                                                                      *
* Description: For Changing payment blocks in documents for vendor as *
*               per i/p 'X' 'A'
*
*                                                                     *
* Tran.Code  : ZFIBLOCKA
*
***********************************************************************
*Change History
*Date        ChID     Login        Description
*22.04.2008  +002     CAB_SUDHA    JV Cash call Sp gl added
*                                   Payment method added
*
*19.08.2008  +003     CAB_SUDHA     eq. of new     *  payment blocks
*R- rejection, S- stale cheque , D - old lineitems
*
***********************************************************************
*  Date        Transport     USERID       Description                  *
* 24/11/2008   <RD1K960611>  CAB_SUDHA    Form call eventtab_build,
*                                         comment_build  sts  changed
*                                         After removing []
************************************************************************
*  Date      Transport  USERID      Description
** 19/12/2008 RD1K960891 CAB_SUDHA   Payment block for customers
* 25.02.09   cab_rama               FS-FI-AP-083_01 30000782    001
* 15.12.2009 RD1K967585 CAB_ALOK    CR30002778,Creation of activity logs
*                                   Addition of INV REF in Report,
*
* 26.03.2010            SAB_SUMAN   30003849      003
* 17.05.2010 RD1K971966 CAB_ALOK    CR 30004183: Addition of
*                                   'Payment block from S to X'
* 14.06.2011            CAB_SUDHIR  Message e410(ZFI) added
************************************************************************
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                 Chng ID       *
*                                                                     *
* 09.07.2014  CAB_SPYADAV   Changes as per CR No.        010          *
*                           30011027                                  *
*18.12.2015 CAB_RAMA(ANAMIKA) Warning message        <RD1K999458>     *
*                            as per CR 30013754                                                  *
*05.05.2016 CAB_RAMA(ANAMIKA) Changes as per         < RD1K9A00LE>    *
*                             CR 30014262                             *
***********************************************************************

TYPE-POOLS : slis.

TABLES : bsik , t001 , bkpf, bsid, zhr_institute.

DATA : ist_bsik  TYPE TABLE OF bsik.
DATA : ist_bseg TYPE TABLE OF  bseg.
DATA : wa_bsik  TYPE bsik.
DATA : wa_bseg TYPE  bseg.

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
       lifnr LIKE bsik-lifnr ,
       umskz LIKE bsik-umskz,
       bukrs LIKE bsik-bukrs ,
       gjahr LIKE bsik-gjahr,
       belnr  LIKE bsik-belnr,
       buzei  LIKE bsik-buzei,
       budat  LIKE bsik-budat,
       bschl LIKE bsik-bschl,
       zlsch LIKE bsik-zlsch,                               "+002
       zlspr LIKE  bsik-zlspr,
       shkzg LIKE bsik-shkzg,
       gsber LIKE bsik-gsber,
       dmbtr LIKE bsik-dmbtr,
       wrbtr LIKE bsik-wrbtr,
*Begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
       rebzg LIKE bsik-rebzg,        " Invoice Ref.
*end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
       usnam  LIKE bkpf-usnam,
       xref1_hd LIKE bkpf-xref1_hd,
*Begin of <RD1K981426> CAB_rama CR30007673
       kidno LIKE  bsik-kidno.
*end of <RD1K981426> CAB_rama CR30007673
DATA:  END OF ist_srcbsik .

DATA : wa_srcbsik LIKE ist_srcbsik.
DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .


"""""""Added by Anamika on 18/12/2015 for RD1K999458""""
DATA : ist_srcbsik_copy LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : wa_srcbsik_copy LIKE ist_srcbsik.
"""""""Added by Anamika on 18/12/2015 for RD1K999458""""

"""""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
DATA : ist_ZFI_PAYREF_CC  TYPE TABLE OF ZFI_PAYREF_CC.
"""""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""


*-----------Start of <RD1K960891>
DATA : BEGIN OF ist_srcbsid OCCURS 0 ,
       selcbox(1) TYPE c,
       kunnr LIKE bsid-kunnr ,
       umskz LIKE bsid-umskz,
       bukrs LIKE bsid-bukrs ,
       gjahr LIKE bsid-gjahr,
       belnr  LIKE bsid-belnr,
       buzei  LIKE bsid-buzei,
       budat  LIKE bsid-budat,
       bschl LIKE bsid-bschl,
       zlsch LIKE bsid-zlsch,                               "+002
       zlspr LIKE  bsid-zlspr,
       shkzg LIKE bsid-shkzg,
       gsber LIKE  bsid-gsber,
       dmbtr LIKE bsid-dmbtr,
       wrbtr LIKE bsid-wrbtr,
       kidno LIKE  bsid-kidno,                              "+001
*Begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
       rebzg LIKE bsid-rebzg,        " Invoice Ref.
*end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
       usnam  LIKE bkpf-usnam,
   xref1_hd LIKE bkpf-xref1_hd.
*       include structure  bsis.
DATA:  END OF ist_srcbsid .

DATA : wa_srcbsid LIKE ist_srcbsid.
DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
DATA : ist_bsid  TYPE TABLE OF bsid.
DATA : wa_bsid  TYPE bsid.
*-----------End of <RD1K960891>

DATA : w_repid TYPE sy-repid.

DATA:  is_layout  TYPE  slis_layout_alv,
       ist_fieldcat TYPE  slis_fieldcat_alv  , "line.
       ist_fcat TYPE  TABLE OF slis_fieldcat_alv,
        lt_sorttab TYPE slis_t_sortinfo_alv,
       ls_sorttab TYPE slis_sortinfo_alv. " sort structure for ALV



DATA  : mpos TYPE i .
DATA : gt_list_top_of_page TYPE slis_t_listheader,
       gt_list_end_of_list TYPE slis_t_listheader,
       gt_events   TYPE slis_t_event.
*begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
DATA : pmtblock_to TYPE bsik-zlspr.
*end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : ist_srcbsik_l2 LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : wa_srcbsik_l LIKE ist_srcbsik.
DATA : l_err.
CONSTANTS: g_setclass LIKE setleaf-setclass VALUE '0000',
           g_setname  LIKE setleaf-setname VALUE 'PCS_VENDOR'.


*Begin RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
TYPES: BEGIN OF TY_TAB,
         LIFNR TYPE LFB1-LIFNR,
       END  OF TY_TAB.
data: IST_TAB TYPE TABLE OF TY_TAB.
*End RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820

*-------selection-screen---------------------*

SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.

SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,  "<RD1K960891>
                 s_emp FOR bsik-lifnr ,  "<RD1K981426>
                 s_kunnr FOR bsid-kunnr ,  "<RD1K960891>
                 s_year  FOR bsik-gjahr OBLIGATORY,
                 s_gsber FOR bsik-gsber,
                 s_budat FOR bsik-budat,
                 s_usnam FOR bkpf-usnam,
*    start of addition prabu k on 06.07.2009
                 s_xref1 FOR bkpf-xref1_hd.


*  End of addition Prabu K on 06.07.2009

PARAMETERS :  p_bukrs LIKE bsik-bukrs OBLIGATORY .
SELECT-OPTIONS : s_docno FOR bsik-belnr.

SELECTION-SCREEN : END OF BLOCK blk1.
SELECTION-SCREEN : BEGIN OF BLOCK  blk2  WITH FRAME .
SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(70) text-002 FOR FIELD p_x2a .
PARAMETERS : p_x2a RADIOBUTTON GROUP rad1  .
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(70) text-003 FOR FIELD p_a2x.
PARAMETERS :  p_a2x RADIOBUTTON GROUP rad1   .
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF  LINE .
*-------+003
SELECTION-SCREEN COMMENT 2(70) text-004 FOR FIELD p_r2x.
PARAMETERS :  p_r2x RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF LINE.
* Begin of RD1K971966 CAB_ALOK CR30004183
SELECTION-SCREEN BEGIN OF  LINE .
SELECTION-SCREEN COMMENT 2(70) text-007 FOR FIELD p_s2x.
PARAMETERS:   p_s2x  RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF LINE.
* End of RD1K971966 CAB_ALOK CR30004183
SELECTION-SCREEN : END OF BLOCK blk2.

*------+003

*------------end selection screen--------------*

CONSTANTS  : g_zlspr_x   LIKE bseg-zlspr  VALUE 'X',
             g_zlspr_a   LIKE bseg-zlspr VALUE 'A',
             g_zlspr_r  LIKE bseg-zlspr  VALUE 'R',
* Begin of RD1K971966 CAB_ALOK CR30004183
             g_zlspr_s   LIKE bseg-zlspr  VALUE 'S'.
* End of RD1K971966 CAB_ALOK CR30004183

*---------------------events -----------------------*
RANGES: r_vendor FOR lfa1-lifnr.
r_vendor-low = '0007000000'.

r_vendor-high = '0007999999'.

r_vendor-option = 'BT'.

r_vendor-sign = 'I'.

APPEND r_vendor.
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
  DATA: lv_area TYPE STANDARD TABLE OF ty_t526 ,
          wa_area LIKE LINE OF lv_area.

  DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009 ,
          wa_t5009 LIKE LINE OF  it_t5009.

  DATA: it_final TYPE STANDARD TABLE OF ty_final ,
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
  DATA: lv_area TYPE STANDARD TABLE OF ty_t526 ,
          wa_area LIKE LINE OF lv_area.

  DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009 ,
          wa_t5009 LIKE LINE OF  it_t5009.

  DATA: it_final TYPE STANDARD TABLE OF ty_final ,
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
    MESSAGE e010(fi).
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
*-----------Start of <RD1K960891>
  IF s_lifnr IS INITIAL AND s_kunnr IS INITIAL AND s_emp IS INITIAL.
    MESSAGE   e322(zfi).
  ENDIF.
  IF  NOT  s_lifnr IS INITIAL  AND  NOT s_kunnr IS INITIAL .
    MESSAGE   e322(zfi).
  ENDIF.

*remove before TP
*  IF NOT sy-uname = 'CAB_ALOK' .
  IF NOT s_lifnr IS INITIAL.
    DATA : ist_zhr_institute TYPE STANDARD TABLE OF zhr_institute,
           wa_zhr_institute TYPE zhr_institute,
           ist_setleaf  LIKE setleaf OCCURS 0 WITH HEADER LINE,
           l_e TYPE c .

    l_e = 'X'.
    REFRESH : ist_setleaf,ist_zhr_institute.
    CLEAR : ist_setleaf,ist_zhr_institute.
    SELECT * FROM zhr_institute
      INTO CORRESPONDING FIELDS OF TABLE ist_zhr_institute.  "#EC CI_NOORDER

    SELECT * FROM setleaf
    INTO CORRESPONDING FIELDS OF TABLE ist_setleaf
    WHERE setclass = g_setclass
      AND setname = g_setname.

    AUTHORITY-CHECK OBJECT 'ZFIBLKVEND'
               ID 'ACTVT' FIELD '02'.
    IF  sy-subrc <> 0.
* Begin of <RD1K976747> on 14062011
      LOOP AT s_lifnr.
        IF NOT s_lifnr-low IS INITIAL.
          LOOP AT ist_zhr_institute INTO wa_zhr_institute
            WHERE lifnr = s_lifnr-low.
            CLEAR l_e.
          ENDLOOP.
          READ TABLE ist_setleaf WITH KEY setclass = g_setclass
                                          setname  = g_setname
                                          valfrom  = s_lifnr-low.
          IF sy-subrc EQ 0.
            CLEAR l_e.
          ENDIF.
        ENDIF.
        IF NOT s_lifnr-high IS INITIAL.
          LOOP AT ist_zhr_institute INTO wa_zhr_institute
            WHERE lifnr = s_lifnr-high.
            CLEAR l_e.
          ENDLOOP.
          READ TABLE ist_setleaf WITH KEY setclass = g_setclass
                                          setname  = g_setname
                                          valfrom  = s_lifnr-high.
          IF sy-subrc EQ 0.
            CLEAR l_e.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF l_e = 'X'.
        MESSAGE e410(zfi) WITH text-005.
      ENDIF.
*        MESSAGE e323(zfi) WITH text-005.
* End of <RD1K976747>
    ENDIF.


    LOOP AT s_lifnr.
      IF NOT s_lifnr-low IS INITIAL.
        IF s_lifnr-low IN r_vendor.
          MESSAGE e425(zfi) WITH text-009.
        ENDIF.
      ENDIF.
      IF NOT s_lifnr-high IS INITIAL.
        IF s_lifnr-high IN r_vendor.
          MESSAGE e425(zfi) WITH text-009.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSEIF NOT s_kunnr IS INITIAL.
    AUTHORITY-CHECK OBJECT 'ZFIBLKCUST'
               ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
* Begin of <RD1K976747> on 14062011
      MESSAGE e410(zfi) WITH text-006.
*        MESSAGE e323(zfi) WITH text-006.
* End of <RD1K976747>
    ENDIF.
  ELSEIF NOT s_emp IS INITIAL.
    PERFORM authority_check USING 'ZFIBLKVEMP' 'VEMP' .

    IF NOT s_emp IS INITIAL.
      LOOP AT s_emp.
        IF NOT s_emp-low IS INITIAL.
          IF s_emp-low NOT IN r_vendor.
            MESSAGE e425(zfi) WITH text-011.
          ENDIF.
        ENDIF.
        IF NOT s_emp-high IS INITIAL.
          IF s_emp-high NOT IN r_vendor.
            MESSAGE e425(zfi) WITH text-011.
          ENDIF.
        ENDIF.
        IF s_lifnr IS INITIAL.
          s_lifnr-sign = s_emp-sign.
          s_lifnr-option = s_emp-option.
          s_lifnr-low = s_emp-low.
          s_lifnr-high = s_emp-high.
        ENDIF.
*          append s_lifnr.
*        endif.
      ENDLOOP.
      s_lifnr[] = s_emp[].
    ENDIF.
  ENDIF.
*  ENDIF.


  IF NOT s_lifnr  IS INITIAL.
*Begin RD1K998216       CAB_ALOK     Change in ZFIBLOCKA for APP Block Vendor-CR 30013154
if p_a2x = 'X'.
    PERFORM VALIDATE_VENDOR.
endif.
*End RD1K998216       CAB_ALOK     Change in ZFIBLOCKA for APP Block Vendor-CR 30013154

*Begin RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
*    PERFORM   get_rel_docs.
*    PERFORM display_docs.
    IF IST_TAB[] is INITIAL.
      PERFORM   get_rel_docs.
      PERFORM display_docs.
    ENDIF.
*End RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820


  ELSEIF  NOT s_kunnr IS INITIAL.
    PERFORM   get_rel_docs_cust.
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
  PERFORM eventtab_build TABLES gt_events.
  PERFORM comment_build TABLES gt_list_top_of_page.
  PERFORM  sort_build .
  PERFORM  print_alv.

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
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Select'.
  ist_fieldcat-lowercase  = 'Y'.
  ist_fieldcat-checkbox = 'X'.
  ist_fieldcat-input = 'X'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'LIFNR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'VendorNumber '.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BELNR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Doc.No.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUZEI'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Item.no.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'GSBER'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Business Area'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*BEGIN of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Invoice Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778

*BEGIN of <RD1K967585> CAB_RAMA 09.08.2012 CR30007559
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KIDNO'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Payment Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_RAMA 09.08.2012 CR30007559

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BSCHL'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Key.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.




  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUDAT'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Date'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'DMBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WRBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSCH'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymntMethod'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSPR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymntBlock'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*  *Start of addition Prabu K on 06.07.2009
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

* End of addition Prabu K on 06.07.2009

  IF NOT s_usnam[] IS INITIAL.
    mpos = mpos + 1.
    ist_fieldcat-fieldname = 'USNAM'.
    ist_fieldcat-tabname = 'IST_SRCBSIK'.
    ist_fieldcat-ddictxt = 'M'.
    ist_fieldcat-col_pos =  mpos.
    ist_fieldcat-seltext_m  = 'Created By'.
    ist_fieldcat-lowercase  = 'Y'.
    APPEND ist_fieldcat TO ist_fcat.
    CLEAR ist_fieldcat.
  ENDIF.


ENDFORM.                    " init_fieldcat
*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
*Begin of <RD1K960611>
*FORM eventtab_build USING    p_gt_events[].
FORM eventtab_build TABLES  p_gt_events.
*End of <RD1K960611>

  DATA : ls_event TYPE slis_alv_event.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events.
  READ TABLE gt_events WITH KEY name =  slis_ev_user_command
                            INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'MAKE_COMMAND' TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.
  CLEAR ls_event.


ENDFORM.                    " eventtab_build
*&---------------------------------------------------------------------*
*&      Form  comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
*Begin of <RD1K960611>
*FORM comment_build USING    p_gt_list_top_of_page[].
FORM comment_build TABLES  p_gt_list_top_of_page.
*End of <RD1K960611>

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
  ls_sorttab-fieldname = 'LIFNR'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
  ls_sorttab-fieldname = 'BSCHL'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
  ls_sorttab-fieldname = 'BELNR'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
  ls_sorttab-fieldname = 'BUDAT'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.



ENDFORM.                    " sort_build
*&---------------------------------------------------------------------*
*&      Form  print_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_alv.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = w_repid
      i_callback_pf_status_set = 'ALV_PFST'
      i_callback_user_command  = 'MAKE_COMMAND'
      is_layout                = is_layout
      it_fieldcat              = ist_fcat[]
      it_sort                  = lt_sorttab
      it_events                = gt_events
      i_save                   = 'A'
    TABLES
      t_outtab                 = ist_srcbsik
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " print_alv
*---------------------------------------------------------------------*
*       FORM alv_pfst                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
FORM alv_pfst USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'S100'.
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
  DATA : l_found(1). "+010

  index_aux = rs_selfield-tabindex.

  CASE r_ucomm.

    WHEN 'REL'.
*+010 : Start

      IF p_a2x = 'X'.

        LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X'.

          IF wa_srcbsik-kidno = text-013. "PERIOD END LIABILITY

            l_found = 'X'.

            EXIT.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF l_found IS INITIAL.
*+010 : End
*Begin of <RD1K981426> CAB_RAMA CR 30007673
        IF ist_srcbsik_l[] IS INITIAL OR l_err = 'X'.
          ist_srcbsik_l[] = ist_srcbsik[].
        ENDIF.

        IF ( p_a2x = 'X' OR p_r2x = 'X' OR p_s2x = 'X' ).
          LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X' AND kidno <> 'PERIOD END LIABILITY'.
            IF  ( wa_srcbsik-bschl = '31' OR wa_srcbsik-bschl = '34' OR wa_srcbsik-bschl = '36'
              OR wa_srcbsik-bschl = '39' OR wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').

              """""""Added by Anamika on 18/12/2015 for RD1K999458""""
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
              LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy where belnr in s_docno .

            IF sy-subrc eq 0.

      delete ist_srcbsik_copy where BELNR = wa_srcbsik_copy-BELNR.
                                       ENDIF.
endloop.
"""""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""

              if s_docno IS not INITIAL.


                if ist_srcbsik_copy[] IS not INITIAL.
                  l_err = 'X'.
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

              """""""Added by Anamika on 18/12/2015 for RD1K999458""""

              LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
                WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
                OR bschl = '21'  OR bschl = '26' )
                AND kidno = wa_srcbsik-kidno
                AND kidno <> 'PERIOD END LIABILITY'
                AND lifnr = wa_srcbsik-lifnr.
                l_err = 'X'.
                MESSAGE e100(zfi) WITH text-010.

              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF ( p_a2x = 'X' OR p_r2x = 'X' OR p_s2x = 'X' ).
          LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X' ."AND KIDNO <> 'PERIOD END LIABILITY'.
            IF  ( wa_srcbsik-bschl = '31' OR wa_srcbsik-bschl = '34' OR wa_srcbsik-bschl = '36'
              OR wa_srcbsik-bschl = '39' OR wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
              LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
                WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
                OR bschl = '21'  OR bschl = '26' )
                AND belnr = wa_srcbsik-rebzg
*              AND KIDNO <> 'PERIOD END LIABILITY'
                AND lifnr = wa_srcbsik-lifnr.
                l_err = 'X'.
                MESSAGE e100(zfi) WITH text-012.
              ENDLOOP.

              LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
                       WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
                       OR bschl = '21'  OR bschl = '26' )
                       AND rebzg = wa_srcbsik-belnr
*                     AND KIDNO <> 'PERIOD END LIABILITY'
                       AND lifnr = wa_srcbsik-lifnr.
                l_err = 'X'.
                MESSAGE e100(zfi) WITH text-012.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDIF.
*END of <RD1K981426> CAB_RAMA CR 30007673
        DELETE ist_srcbsik WHERE  selcbox <> 'X'.
        PERFORM   get_upd_bsik.
        PERFORM   get_upd_bseg.
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
        PERFORM   update_zfi_rem_pyblck_l.    "update logs
*end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
        LEAVE SCREEN.

*+010 : Start
      ELSE.

        MESSAGE i526(zfi).

      ENDIF.
*+010 : End
    WHEN 'ALL'.
      PERFORM  select_all.
    WHEN 'SAL'.
      PERFORM  deselect_all.
    WHEN '&F03' OR 'BACK' .
      LEAVE  PROGRAM.

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

  IF NOT ist_bsik IS INITIAL.
    IF p_x2a = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_x.
          wa_bsik-zlspr =  g_zlspr_a.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*      MODIFY  bsik FROM TABLE ist_bsik.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
    IF p_a2x = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_a.
          wa_bsik-zlspr =  g_zlspr_x.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Beginof change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

*--+003
    IF p_r2x = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_r.
          wa_bsik-zlspr =  g_zlspr_x.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
*---+003
* Begin of RD1K971966 CAB_ALOK CR30004183
    IF p_s2x = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_s.
          wa_bsik-zlspr =  g_zlspr_x.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.
*
*      COMMIT WORK.
 "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
* End of RD1K971966 CAB_ALOK CR30004183

  ENDIF.
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
     AND   gjahr =  ist_srcbsik-gjahr
     AND   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  CLEAR l_tabix.
  IF NOT ist_bseg IS INITIAL.
    IF p_x2a = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_x.
          wa_bseg-zlspr =  g_zlspr_a.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
    CLEAR l_tabix.
    IF p_a2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_a.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*----+003
    IF p_r2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_r.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*-------+003

* Begin of RD1K971966 CAB_ALOK CR30004183
    IF p_s2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_s.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY  bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      COMMIT WORK.
    ENDIF.
* End of RD1K971966 CAB_ALOK CR30004183


  ENDIF.


ENDFORM.                    " get_upd_bseg
*&---------------------------------------------------------------------*
*&      Form  get_rel_docs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rel_docs.
  SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
*begin of <RD1K967585> CAB_rama  CR30007673
**begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
**   zlsch zlspr shkzg gsber dmbtr wrbtr  APPENDING
*   zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg APPENDING   "#### waers kidno
    zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg kidno APPENDING   "#### waers kidno
**end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
*end of <RD1K967585> CAB_rama  CR30007673
  CORRESPONDING FIELDS OF TABLE
                 ist_srcbsik  FROM bsik
                 WHERE
                      bukrs  =  p_bukrs
                AND lifnr  IN s_lifnr
                AND gjahr IN s_year
                AND belnr IN s_docno " RD1K982186 CR 30007748
                AND gsber IN s_gsber        "#### extra cond.
                AND budat IN  s_budat.

  """""""Added by Anamika on 18/12/2015 for RD1K999458""""
  clear : ist_srcbsik_copy,wa_srcbsik_copy .
  refresh : ist_srcbsik_copy[].

  if s_DOCNO IS not INITIAL.
    read TABLE ist_srcbsik into wa_srcbsik_copy index 1.  "#EC CI_NOORDER

    SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
    zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg kidno APPENDING
  CORRESPONDING FIELDS OF TABLE
                 ist_srcbsik_copy  FROM bsik
                 WHERE
                      bukrs  =  p_bukrs
                AND lifnr  IN s_lifnr
                AND  ZLSPR IN ('A','R')
                AND BSCHL IN ('21','26')
                AND SHKZG = 'S'
                AND KIDNO ne 'PERIOD END LIABILITY '
                AND KIDNO EQ wa_srcbsik_copy-KIDNO.
    SORT ist_srcbsik BY lifnr bschl belnr budat .
    SORT ist_srcbsik_copy.
    DELETE ADJACENT DUPLICATES  FROM ist_srcbsik_copy.  "#EC CI_NOORDER
  ENDIF.
  """""""Added by Anamika on 18/12/2015 for RD1K999458""""

  IF p_x2a = 'X'.
    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_x.
  ELSEIF p_a2x = 'X'.
    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_a.
*----+003
  ELSEIF p_r2x = 'X'.
    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_r.
* Begin of RD1K971966 CAB_ALOK CR30004183
  ELSEIF p_s2x = 'X'.
    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_s.
* end of RD1K971966 CAB_ALOK CR30004183
  ENDIF.
*-----+003

*  Start of addition Prabu K on 03.07.2009
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
*  End  of addition Prabu K on 03.07.2009
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
          f_doc_nos = f_doc_nos
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

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

      IF NOT s_usnam[] IS  INITIAL.
        DELETE ist_srcbsik WHERE  NOT usnam  IN s_usnam.
      ENDIF.

    ENDIF.

  ENDIF.

  ist_bsiks[] = ist_srcbsik[].


  REFRESH ist_srcbsik.
  CLEAR ist_srcbsik.


  LOOP AT ist_bsiks .
    IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F' or  ist_bsiks-umskz = 'K' OR ist_bsiks-umskz = 'H'
    OR ist_bsiks-umskz = ':'                                "+001
    OR ist_bsiks-umskz  IS INITIAL.
      ist_srcbsik = ist_bsiks.
      APPEND ist_srcbsik.
      CLEAR ist_srcbsik.
    ENDIF.
  ENDLOOP.


  SORT ist_srcbsik BY lifnr bschl belnr budat .

  DELETE ADJACENT DUPLICATES  FROM ist_srcbsik.

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

ENDFORM.                    " get_rel_docs
*-----------start of <RD1K960891>
*&---------------------------------------------------------------------*
*&      Form  get_rel_docs_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rel_docs_cust.
  SELECT bukrs kunnr umskz gjahr belnr buzei budat bschl
*begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
*   zlsch zlspr shkzg gsber dmbtr wrbtr APPENDING
    zlsch zlspr shkzg gsber dmbtr wrbtr rebzg APPENDING
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
    CORRESPONDING FIELDS OF TABLE
                   ist_srcbsid  FROM bsid
                   WHERE
                        bukrs  =  p_bukrs
                  AND kunnr  IN s_kunnr
                  AND gjahr IN s_year
                AND belnr IN s_docno " RD1K982186 CR 30007748
                  AND gsber IN s_gsber
                  AND budat IN  s_budat.  "#EC CI_NOORDER


  IF p_x2a = 'X'.
    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_x.
  ELSEIF p_a2x = 'X'.
    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_a.
*----+003
  ELSEIF p_r2x = 'X'.
    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_r.

* Begin of RD1K971966 CAB_ALOK CR30004183
  ELSEIF p_s2x = 'X'.
    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_s.
* End of RD1K971966 CAB_ALOK CR30004183

  ENDIF.
*-----+003

*  Start of addition Prabu K on 03.07.2009
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
          f_doc_nos = f_doc_nos
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

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

      IF NOT s_usnam[] IS  INITIAL.
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
    IF ( ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H' OR ist_bsids-umskz = 'O' ) OR
*Start of changes by SOGET - 003
*( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
       ( ist_bsids-umskz = ' ' AND ist_bsids-zlsch = 'P' ) OR ( ist_bsids-umskz = ' ' AND ist_bsids-zlsch = 'Q' ).
*End of changes by SOGET - 003
*}001
      ist_srcbsid = ist_bsids.
      APPEND ist_srcbsid.
      CLEAR ist_srcbsid.
    ENDIF.

  ENDLOOP.

  SORT ist_srcbsid BY kunnr bschl belnr budat .

  DELETE ADJACENT DUPLICATES  FROM ist_srcbsid.

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
ENDFORM.                    " get_rel_docs_cust
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
  PERFORM eventtab_build_cust TABLES gt_events.
  PERFORM  sort_build_cust .
  PERFORM  print_alv_cust.

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
  ist_fieldcat-seltext_m  = 'CustomerNumber '.
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
  ist_fieldcat-fieldname = 'GSBER'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Business Area'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Invoice Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BSCHL'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Key.'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUDAT'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Date'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'DMBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WRBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSCH'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymntMethod'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSPR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymntBlock'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

*Start of addition Prabu K on 06.07.2009
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
* End  of addition Prabu K on 06.07.2009

  IF NOT s_usnam[] IS INITIAL.
    mpos = mpos + 1.
    ist_fieldcat-fieldname = 'USNAM'.
    ist_fieldcat-tabname = 'IST_SRCBSID'.
    ist_fieldcat-ddictxt = 'M'.
    ist_fieldcat-col_pos =  mpos.
    ist_fieldcat-seltext_m  = 'Created By'.
    ist_fieldcat-lowercase  = 'Y'.
    APPEND ist_fieldcat TO ist_fcat.
    CLEAR ist_fieldcat.
  ENDIF.

ENDFORM.                    " init_fieldcat_cust
*&---------------------------------------------------------------------*
*&      Form  eventtab_build_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build_cust TABLES  p_gt_events.
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


ENDFORM.                    " eventtab_build_cust
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
  ls_sorttab-fieldname = 'KUNNR'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
  ls_sorttab-fieldname = 'BSCHL'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
  ls_sorttab-fieldname = 'BELNR'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.
  ls_sorttab-fieldname = 'BUDAT'.
  ls_sorttab-up = 'X'.
  APPEND ls_sorttab TO lt_sorttab.

ENDFORM.                    " sort_build_cust
*&---------------------------------------------------------------------*
*&      Form  print_alv_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_alv_cust.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = w_repid
      i_callback_pf_status_set = 'ALV_PFSTS'
      i_callback_user_command  = 'MAKEC_COMMAND'
      is_layout                = is_layout
      it_fieldcat              = ist_fcat[]
      it_sort                  = lt_sorttab
      it_events                = gt_events
      i_save                   = 'A'
    TABLES
      t_outtab                 = ist_srcbsid
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " print_alv_cust
*---------------------------------------------------------------------*
*       FORM alv_pfst                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
FORM alv_pfsts USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'S100'.
ENDFORM.                    "alv_pfsts

*---------------------------------------------------------------------*
*       FORM make_command                                             *
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
*Begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
      PERFORM   update_zfi_rem_pyblck_l.    "update logs
*end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
      LEAVE SCREEN.
    WHEN 'ALL'.
      PERFORM  select_allc.
    WHEN 'SAL'.
      PERFORM  deselect_allc.
    WHEN '&F03' OR 'BACK' .
      LEAVE  PROGRAM.

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
*&      Form  get_upd_bsid
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

  IF NOT ist_bsid IS INITIAL.
    IF p_x2a = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_x.
          wa_bsid-zlspr =  g_zlspr_a.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsid FROM TABLE ist_bsid.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
    IF p_a2x = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_a.
          wa_bsid-zlspr =  g_zlspr_x.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsid FROM TABLE ist_bsid.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.

*--+003
    IF p_r2x = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_r.
          wa_bsid-zlspr =  g_zlspr_x.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsid FROM TABLE ist_bsid.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
*---+003

* Begin of RD1K971966 CAB_ALOK CR30004183
    IF p_s2x = 'X'.
      LOOP AT ist_bsid INTO wa_bsid.
        l_tabix =   sy-tabix .
        IF wa_bsid-zlspr =  g_zlspr_s.
          wa_bsid-zlspr =  g_zlspr_x.
          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsid FROM TABLE ist_bsid.
*
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
* End of RD1K971966 CAB_ALOK CR30004183

  ENDIF.
ENDFORM.                    " get_upd_bsid
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
     AND   gjahr =  ist_srcbsid-gjahr
     AND   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  CLEAR l_tabix.
  IF NOT ist_bseg IS INITIAL.
    IF p_x2a = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_x.
          wa_bseg-zlspr =  g_zlspr_a.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
    CLEAR l_tabix.
    IF p_a2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_a.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*----+003
    IF p_r2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_r.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

    ENDIF.
*-------+003

* Begin of RD1K971966 CAB_ALOK CR30004183
    IF p_s2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_s.
          wa_bseg-zlspr =  g_zlspr_x.
          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
*      MODIFY  bseg FROM TABLE ist_bseg.
      LOOP AT ist_bseg INTO wa_bseg.
        PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
      ENDLOOP.
      COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

      COMMIT WORK.
    ENDIF.
* End of RD1K971966 CAB_ALOK CR30004183

  ENDIF.
ENDFORM.                    " get_upd_bsegc
*-----------End of <RD1K960891>

*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZFI_REM_PYBLCK_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
* update Logs to table ZFI_REM_PYBLCK_L

FORM update_zfi_rem_pyblck_l .
  DATA: ist_zfi_rem_pyblck_l TYPE TABLE OF zfi_rem_pyblck_l,
        wa_zfi_rem_pyblck_l TYPE zfi_rem_pyblck_l.
  DATA: count TYPE zfi_rem_pyblck_l-srno.

  IF p_x2a = 'X'.
    pmtblock_to = 'A'.
  ELSEIF p_a2x  = 'X'.
    pmtblock_to = 'X'.
  ELSEIF p_r2x = 'X'.
    pmtblock_to = 'X'.
* Begin of RD1K971966 CAB_ALOK CR30004183
  ELSEIF p_s2x = 'X'.
    pmtblock_to = 'X'.
* End of RD1K971966 CAB_ALOK CR30004183
  ENDIF.

  SELECT MAX( srno ) FROM zfi_rem_pyblck_l INTO count.
  IF NOT ist_srcbsik IS INITIAL.

    LOOP AT ist_srcbsik INTO wa_srcbsik.
      count = count + 1.

      wa_zfi_rem_pyblck_l-srno = count.
      wa_zfi_rem_pyblck_l-bukrs = wa_srcbsik-bukrs.
      wa_zfi_rem_pyblck_l-lifnr = wa_srcbsik-lifnr.
*wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
      wa_zfi_rem_pyblck_l-belnr = wa_srcbsik-belnr.
*   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsik-KIDNO.
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
*   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsid-KIDNO.
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
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1057   text
*      -->P_1058   text
*----------------------------------------------------------------------*
FORM authority_check USING p_object p_ktokk.
  AUTHORITY-CHECK OBJECT p_object
         ID 'KTOKK' FIELD p_ktokk.
  IF sy-subrc NE 0.
    MESSAGE e018(s#).
  ENDIF.

ENDFORM.            " AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_VENDOR .

*Begin RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820

  data: WA_LFB1 TYPE LFB1.

*  SELECT single * from LFB1
*    into WA_LFB1
*      WHERE LIFNR IN S_LIFNR
*            AND BUKRS = P_BUKRS
*            AND ZAHLS = 'X'.
*
*  IF WA_LFB1 IS NOT INITIAL.
*   MESSAGE E552(ZFI) with WA_LFB1-LIFNR.
*
*  ENDIF.

BREAK CAB_ALOK.

  data: IST_LFB1 TYPE TABLE OF LFB1.
  data: WA_TAB TYPE TY_TAB  .

  clear  WA_LFB1.

  SELECT * from LFB1
    into CORRESPONDING FIELDS OF TABLE IST_LFB1
      WHERE LIFNR IN S_LIFNR
            AND BUKRS = P_BUKRS
            AND ZAHLS = 'X'.

if IST_LFB1[] is NOT INITIAL.

REFRESH  IST_TAB.
 LOOP at IST_LFB1 INTO WA_LFB1.
   WA_TAB-LIFNR =  WA_LFB1-LIFNR.
   APPEND WA_TAB to  IST_TAB.

 ENDLOOP.

CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
  EXPORTING
    ENDPOS_COL         = 0
    ENDPOS_ROW         = 0
    STARTPOS_COL       = 0
    STARTPOS_ROW       = 0
    TITLETEXT          = 'Following Vendors are Blocked for APP'
* IMPORTING
*   CHOISE             =
  TABLES
    VALUETAB           = IST_TAB
 EXCEPTIONS
   BREAK_OFF          = 1
   OTHERS             = 2
          .
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.

ENDIF.


*End RD1K999618 CAB_ALOK  Change in ZFIBLOCKA for APP Block Vendor-CR 30013820




ENDFORM.                    " VALIDATE_VENDOR

*-- S/4 helper FORM: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
  DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
  REFRESH lt_acchg. CLEAR ls_acchg.
  ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
  APPEND ls_acchg TO lt_acchg.
*BOC By SAP_ABAP on 24/08/26
* CX_SY_DYN_CALL_PARAM_MISSING: TABLES param name was misspelled
* (T_ACCHG), so FI_DOCUMENT_CHANGE never received the mandatory
* T_ACCCHG table and dumped instead of clearing the block.
*  CALL FUNCTION 'FI_DOCUMENT_CHANGE'
*    EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr i_buzei = p_buzei
*    TABLES    t_acchg = lt_acchg
*    EXCEPTIONS OTHERS = 0.
  CALL FUNCTION 'FI_DOCUMENT_CHANGE'
    EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr i_buzei = p_buzei
    TABLES    t_accchg = lt_acchg
    EXCEPTIONS OTHERS = 0.
*EOC By SAP_ABAP on 24/08/26
ENDFORM.
