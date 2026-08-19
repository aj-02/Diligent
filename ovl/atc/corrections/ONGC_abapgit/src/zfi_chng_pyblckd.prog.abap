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
*               per i/p 'A'
*
*                                                                     *
* Tran.Code  : ZFIBLOCKA
*
***********************************************************************
***********************************************************************
*  Date        Transport     USERID       Description                  *
* 24/11/2008   <RD1K960611>  CAB_SUDHA    Form call eventtab_build,
*                                         comment_build  sts  changed
*                                         After removing []
* 11.12.2009    RD1K967585  CAB_ALOK     CR30002778
*                                         Addition of INV REF in Report,
*                                         Creation of activity logs
***********************************************************************

TYPE-POOLS : slis.

TABLES : bsik , t001 , bkpf, bsid.


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
       zlsch like bsik-zlsch,                               "+002
       zlspr LIKE  bsik-zlspr,
       shkzg LIKE bsik-shkzg,
       gsber LIKE bsik-gsber,
       dmbtr LIKE bsik-dmbtr,
       wrbtr LIKE bsik-wrbtr,
*Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       rebzg LIKE bsik-rebzg,        " Invoice Ref.
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       usnam  LIKE bkpf-usnam,
    xref1_hd like bkpf-xref1_hd,
*Begin of <RD1K981735> CAB_RAMA CR 30007748
kidno LIKE  bsik-kidno.     " Payment Ref.
*End of <RD1K981735> CAB_RAMA CR 30007748
DATA:  END OF ist_srcbsik .

DATA : wa_srcbsik LIKE ist_srcbsik.
DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .

*------Start of  <RD1K960891>
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
*Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       rebzg LIKE bsid-rebzg,        " Invoice Ref.
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       usnam  LIKE bkpf-usnam,
    xref1_hd like bkpf-xref1_hd.
*       include structure  bsis.
DATA:  END OF ist_srcbsid .

DATA : wa_srcbsid LIKE ist_srcbsid.
DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
DATA : ist_bsid  TYPE TABLE OF bsid.
DATA : wa_bsid  TYPE bsid.
*----End of <RD1K960891>

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
*begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
data : PMTBLOCK_TO type bsik-zlspr.
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
*-------selection-screen---------------------*
*Begin of <RD1K981735> CAB_RAMA CR 30007748
DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
DATA : wa_srcbsik_l LIKE ist_srcbsik.
data : l_err.
*End of <RD1K981735> CAB_RAMA CR 30007748
SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.

SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,   "<RD1K960891>
                 s_kunnr FOR bsid-kunnr ,   "<RD1K960891>
                 s_year  FOR bsik-gjahr OBLIGATORY,
                 s_gsber FOR bsik-gsber,
                 s_budat FOR bsik-budat,
                 s_usnam FOR bkpf-usnam,
*  Start of addition Prabu K on 06.07.2009
                 s_xref1 for bkpf-xref1_hd.

*  End of addition Prabu K on 06.07.2009
PARAMETERS :  p_bukrs LIKE bsik-bukrs OBLIGATORY .
SELECT-OPTIONS : S_DOCNO FOR BSIK-BELNR.

SELECTION-SCREEN : END OF BLOCK blk1.
SELECTION-SCREEN : BEGIN OF BLOCK  blk2  WITH FRAME .
selection-screen begin of  line .
SELECTION-SCREEN COMMENT 2(40) text-002 FOR FIELD p_any2D .
PARAMETERS : p_any2D RADIOBUTTON GROUP rad1  .
selection-screen end of line.
selection-screen begin of  line .
SELECTION-SCREEN COMMENT 2(40) text-003 FOR FIELD p_d2x.
PARAMETERS :  p_d2x RADIOBUTTON GROUP rad1   .
selection-screen end of line.
*selection-screen begin of  line .
**-------+003
*SELECTION-SCREEN COMMENT 2(70) text-004 FOR FIELD p_r2x.
*PARAMETERS :  p_r2x RADIOBUTTON GROUP rad1.
*selection-screen end of line.
*SELECTION-SCREEN : END OF BLOCK blk2.
**------+003
SELECTION-SCREEN : END OF BLOCK blk2.

*------------end selection screen--------------*

CONSTANTS  : g_zlspr_x   LIKE bseg-zlspr  VALUE 'X',
             g_zlspr_d   LIKE bseg-zlspr VALUE 'D'.
*             g_zlspr_r  LIKE bseg-zlspr  VALUE 'R'.


*---------------------events -----------------------*

* *Start of addition Prabu K on 11.07.2009
AT SELECTION-SCREEN on VALUE-REQUEST FOR s_xref1-low.


  types : begin of ty_t526,
          sachx type sachx,
          werks type SBMOD,
          end of ty_t526.

  types: begin of ty_final,
         bukrs type bukrs,
         persa type persa,
         sachx type sachx,
         end of ty_final.
  types: begin of ty_t5009,
         persa type persa,
         bukrs type bukrs,
         end of ty_t5009.
  data: lv_area type standard table of ty_t526 ,
          wa_area LIKE LINE OF lv_area.

  data: it_t5009 type standard table of ty_t5009 ,
          wa_t5009 like line of  it_t5009.

  data: it_final type standard table of ty_final ,
          wa_final like line of  it_final.

  select sachx werks from t526 into corresponding fields of table lv_area.  "#EC CI_NOORDER

  sort lv_area by sachx.
  delete adjacent duplicates from lv_area
  comparing sachx.

*  select persa bukrs  from t500p into table it_t5009 for all entries
*                         in lv_area where persa = lv_area-sachx.

  select persa bukrs  from t500p into CORRESPONDING FIELDS OF TABLE it_t5009.

  sort it_t5009  by persa.
  delete adjacent duplicates from it_t5009
  comparing persa.

  loop at lv_area into wa_area.

    read table it_t5009 into wa_t5009 WITH KEY persa = wa_area-werks.
    wa_final-sachx = wa_area-sachx.
    wa_final-persa = wa_t5009-persa.
    wa_final-bukrs = wa_t5009-bukrs.
    append wa_final to it_final.
  endloop.
  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
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
      others          = 3.

  if sy-subrc <> 0.
*
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  endif.

at selection-screen on value-request for s_xref1-high.
  types : begin of ty_t526,
          sachx type sachx,
          werks type SBMOD,
          end of ty_t526.

  types: begin of ty_final,
         bukrs type bukrs,
         persa type persa,
         sachx type sachx,
         end of ty_final.
  types: begin of ty_t5009,
         persa type persa,
         bukrs type bukrs,
         end of ty_t5009.
  data: lv_area type standard table of ty_t526 ,
          wa_area LIKE LINE OF lv_area.

  data: it_t5009 type standard table of ty_t5009 ,
          wa_t5009 like line of  it_t5009.

  data: it_final type standard table of ty_final ,
          wa_final like line of  it_final.

  select sachx werks from t526 into corresponding fields of table lv_area.  "#EC CI_NOORDER

  sort lv_area by sachx.
  delete adjacent duplicates from lv_area
  comparing sachx.

*  select persa bukrs  from t500p into table it_t5009 for all entries
*                         in lv_area where persa = lv_area-sachx.

  select persa bukrs  from t500p into CORRESPONDING FIELDS OF TABLE it_t5009.

  sort it_t5009  by persa.
  delete adjacent duplicates from it_t5009
  comparing persa.

  loop at lv_area into wa_area.

    read table it_t5009 into wa_t5009 WITH KEY persa = wa_area-werks.
    wa_final-sachx = wa_area-sachx.
    wa_final-persa = wa_t5009-persa.
    wa_final-bukrs = wa_t5009-bukrs.
    append wa_final to it_final.
  endloop.
  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
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
      others          = 3.

  if sy-subrc <> 0.
*
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  endif.
* End of addition Prabu K on 11.07.2009

AT SELECTION-SCREEN ON p_bukrs .
  SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e010(fi).
  ENDIF.
*----Start of <RD1K960891>

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
               ID 'ACTVT' FIELD '02'
               ID 'BUKRS' FIELD p_bukrs.

  IF sy-subrc <> 0.
    MESSAGE  e091(8B) WITH p_bukrs.
  ENDIF.

*----End of <RD1K960891>



*------------------------------------------------------*
START-OF-SELECTION.
*------------------------------------------------------*
*----Start of <RD1K960891>
  IF s_lifnr IS INITIAL AND s_kunnr IS INITIAL.
    MESSAGE   e322(zfi).
  ENDIF.
  IF  NOT  s_lifnr IS INITIAL  AND  NOT s_kunnr IS INITIAL .
    MESSAGE   e322(zfi).
  ENDIF.

  IF NOT s_lifnr  IS INITIAL.
    PERFORM   get_rel_docs.
    PERFORM   display_docs.
  ELSEIF  NOT s_kunnr IS INITIAL.
    PERFORM get_docs_cust.
    PERFORM display_docs_cust.
  ENDIF.

*----End of <RD1K960891>
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
  PERFORM eventtab_build USING gt_events[].
  PERFORM comment_build USING gt_list_top_of_page[].
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

*BEGIN of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Invoice Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KIDNO'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Payment Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778

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

  if not s_usnam[] is initial.
    mpos = mpos + 1.
    ist_fieldcat-fieldname = 'USNAM'.
    ist_fieldcat-tabname = 'IST_SRCBSIK'.
    ist_fieldcat-ddictxt = 'M'.
    ist_fieldcat-col_pos =  mpos.
    ist_fieldcat-seltext_m  = 'Created By'.
    ist_fieldcat-lowercase  = 'Y'.
    APPEND ist_fieldcat TO ist_fcat.
    CLEAR ist_fieldcat.
  endif.


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
FORM eventtab_build USING    p_gt_events.
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
FORM comment_build USING    p_gt_list_top_of_page.
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
      PROGRAM_ERROR = 1
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
  index_aux = rs_selfield-tabindex.
*  break cab_alok.

  CASE r_ucomm.
    WHEN 'REL'.
*      if ist_srcbsik_l[] is initial.
      if ist_srcbsik_l[] is initial or l_err = 'X'.
        ist_srcbsik_l[] = ist_srcbsik[].
      endif.

*      DELETE ist_srcbsik WHERE  selcbox <> 'X'.
*Begin of <RD1K981735> CAB_RAMA CR 30007748

      IF p_d2x = 'X'.
        loop at ist_srcbsik into wa_srcbsik where selcbox = 'X' AND KIDNO <> 'PERIOD END LIABILITY'.
          if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
            or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
            loop at ist_srcbsik_l into wa_srcbsik_l
              where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
              or bschl = '21'  or bschl = '26' )
              and kidno = wa_srcbsik-kidno
              AND KIDNO <> 'PERIOD END LIABILITY'
              and lifnr = wa_srcbsik-lifnr.
              l_err = 'X'.
              MESSAGE e100(zfi) WITH text-004.
            endloop.
          endif.
        endloop.
      ENDIF.
*{begin of CR 30007748

      IF p_d2x = 'X'.
        loop at ist_srcbsik into wa_srcbsik where selcbox = 'X' AND KIDNO <> 'PERIOD END LIABILITY'.
          if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
            or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
            loop at ist_srcbsik_l into wa_srcbsik_l
              where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
              or bschl = '21'  or bschl = '26' )
              and belnr = wa_srcbsik-rebzg
              AND KIDNO <> 'PERIOD END LIABILITY'
              and lifnr = wa_srcbsik-lifnr.
              l_err = 'X'.
              MESSAGE e100(zfi) WITH text-004.
            endloop.

*            loop at ist_srcbsik_l into wa_srcbsik_l
*              where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
*              or bschl = '21'  or bschl = '26' )
*              and rebzg = wa_srcbsik-belnr
**              AND KIDNO <> 'PERIOD END LIABILITY'
*              and lifnr = wa_srcbsik-lifnr.
*
*              MESSAGE e100(zfi) WITH text-004.
*            endloop.
          endif.
        endloop.
        loop at ist_srcbsik into wa_srcbsik where selcbox = 'X'.
          if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
            or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
            loop at ist_srcbsik_l into wa_srcbsik_l
                where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
                or bschl = '21'  or bschl = '26' )
                and rebzg = wa_srcbsik-belnr
*              AND KIDNO <> 'PERIOD END LIABILITY'
                and lifnr = wa_srcbsik-lifnr.
              l_err = 'X'.
              MESSAGE e100(zfi) WITH text-005.
            endloop.
            loop at ist_srcbsik_l into wa_srcbsik_l
                 where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
                 or bschl = '21'  or bschl = '26' )
                 and belnr = wa_srcbsik-rebzg
*              AND KIDNO <> 'PERIOD END LIABILITY'
                 and lifnr = wa_srcbsik-lifnr.
              l_err = 'X'.
              MESSAGE e100(zfi) WITH text-005.
            endloop.
          endif.
        endloop.
      ENDIF.
      DELETE ist_srcbsik WHERE  selcbox <> 'X'.

*{end of CR 30007748
*END of <RD1K981735> CAB_RAMA CR 30007748
      PERFORM   get_upd_bsik.
      PERFORM   get_upd_bseg.
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
*end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      LEAVE SCREEN.
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
    IF p_any2D = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
*        IF wa_bsik-zlspr =  g_zlspr_x.
        wa_bsik-zlspr =  g_zlspr_d.
        MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*      MODIFY  bsik FROM TABLE ist_bsik.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
    IF p_d2x = 'X'.
      LOOP AT ist_bsik INTO wa_bsik.
        l_tabix =   sy-tabix .
        IF wa_bsik-zlspr =  g_zlspr_d.
          wa_bsik-zlspr =  g_zlspr_x.
          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  bsik FROM TABLE ist_bsik.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.



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
    IF p_any2D = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
*        IF wa_bseg-zlspr =  g_zlspr_x.
        wa_bseg-zlspr =  g_zlspr_d.
        MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
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
    CLEAR l_tabix.
    IF p_d2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_d.
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
*Begin of <RD1K981735> CAB_RAMA CR 30007748
**begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
**   zlsch zlspr shkzg gsber dmbtr wrbtr  APPENDING
*   zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg APPENDING
**end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
    zlsch zlspr shkzg gsber dmbtr wrbtr rebzg kidno APPENDING
*End of <RD1K981735> CAB_RAMA CR 30007748
  CORRESPONDING FIELDS OF TABLE
                 ist_srcbsik  FROM bsik
                 WHERE
                      bukrs  =  p_bukrs
                AND lifnr  IN s_lifnr
                AND gjahr IN s_year
                AND BELNR IN S_DOCNO " RD1K982186 CR 30007748
                AND gsber IN s_gsber
                AND budat IN  s_budat.  "#EC CI_NOORDER


  IF p_d2x = 'X'.
    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_d.
  endif.
  IF p_any2d = 'X'.
    DELETE  ist_srcbsik WHERE zlspr = g_zlspr_d.
  endif.
*Start of addition Prabu K on 03.07.2009
  data wa_bkpf type bkpf.
  loop at ist_srcbsik into wa_srcbsik.

    select single * from bkpf into wa_bkpf where bukrs = wa_srcbsik-bukrs and belnr = wa_srcbsik-belnr
       and xref1_hd in s_xref1.  "#EC CI_NOORDER
    if sy-subrc ne 0.
      delete table ist_srcbsik from wa_srcbsik.
    else.
      wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
      modify IST_SRCBSIK from wa_srcbsik.
    endif.

  endloop.
*  End  of addition Prabu K on 03.07.2009
*----+003
*  elseif p_r2x = 'X'.
*     DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_r.
*  ENDIF.
*-----+003
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
    IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F'
    OR ist_bsiks-umskz = ':'
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
*----Start of <RD1K960891>
*&---------------------------------------------------------------------*
*&      Form  get_docs_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_docs_cust.
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
                AND BELNR IN S_DOCNO " RD1K982186 CR 30007748
                 AND gsber IN s_gsber
                 AND budat IN  s_budat.  "#EC CI_NOORDER


  IF p_d2x = 'X'.
    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_d.
  elseif p_any2D = 'X'.
    DELETE  ist_srcbsid WHERE zlspr = g_zlspr_d.
  endif.

*Start of addition Prabu K on 03.07.2009
  data wa_bkpf type bkpf.
  loop at ist_srcbsid into wa_srcbsid.

    select single * from bkpf into wa_bkpf where bukrs = wa_srcbsid-bukrs and belnr = wa_srcbsid-belnr
       and xref1_hd in s_xref1.  "#EC CI_NOORDER
    if sy-subrc ne 0.
      delete table ist_srcbsid from wa_srcbsid.
    else.
      wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
      modify IST_SRCBSId from wa_srcbsid.
    endif.

  endloop.
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
    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H' or ist_bsids-umskz = 'O'.
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

endform.                    " get_docs_cust
*&---------------------------------------------------------------------*
*&      Form  display_docs_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_docs_cust.
  PERFORM init_fieldcat_cust.
  PERFORM eventtab_build_cust tables gt_events.
  PERFORM  sort_build_cust .
  PERFORM  print_alv_cust.

endform.                    " display_docs_cust
*&---------------------------------------------------------------------*
*&      Form  init_fieldcat_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat_CUST.
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

*begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Invoice Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778

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

*  *Start of addition Prabu K on 06.07.2009
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
* End of addition Prabu K on 06.07.2009

  if not s_usnam[] is initial.
    mpos = mpos + 1.
    ist_fieldcat-fieldname = 'USNAM'.
    ist_fieldcat-tabname = 'IST_SRCBSID'.
    ist_fieldcat-ddictxt = 'M'.
    ist_fieldcat-col_pos =  mpos.
    ist_fieldcat-seltext_m  = 'Created By'.
    ist_fieldcat-lowercase  = 'Y'.
    APPEND ist_fieldcat TO ist_fcat.
    CLEAR ist_fieldcat.
  endif.


ENDFORM.                    " init_fieldcat
*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build_CUST tables   p_gt_events.
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


ENDFORM.                    " eventtab_build
*&---------------------------------------------------------------------*
*&      Form  sort_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_build_CUST.
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



ENDFORM.                    " sort_build
*&---------------------------------------------------------------------*
*&      Form  print_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_alv_CUST.
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
      t_outtab                 = ist_srcBSID
* Begin of Changes on 20-Jun-2013
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
* End of Changes on 20-Jun-2013
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " print_alv_CUST
*---------------------------------------------------------------------*
*       FORM alv_pfst                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
FORM alv_pfstS USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'S100'.
ENDFORM.                    "alv_pfstS

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
      DELETE ist_srcBSID WHERE  selcbox <> 'X'.
      PERFORM   get_upd_BSID.
      PERFORM   get_upd_bsegC.
*Begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
      PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
      LEAVE SCREEN.
    WHEN 'ALL'.
      PERFORM  select_allC.
    WHEN 'SAL'.
      PERFORM  deselect_allC.
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
FORM select_allC.
  LOOP AT ist_srcBSID.
    ist_srcBSID-selcbox = 'X'.
    MODIFY ist_srcBSID.
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
FORM deselect_allC.
  LOOP AT ist_srcBSID.
    ist_srcBSID-selcbox = ' '.
    MODIFY ist_srcBSID.
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
FORM get_upd_BSID.

  DATA : l_tabix  TYPE sy-tabix.

  CHECK NOT ist_srcBSID[] IS INITIAL.

  SELECT * INTO TABLE ist_BSID   FROM BSID
    FOR ALL ENTRIES  IN  ist_srcBSID
    WHERE   KUNNR = ist_srcBSID-KUNNR
          AND  bukrs  =  p_bukrs
           AND gjahr = ist_srcBSID-gjahr
           AND belnr = ist_srcBSID-belnr
           AND buzei = ist_srcBSID-buzei.

  IF NOT ist_BSID IS INITIAL.
    IF p_any2D = 'X'.
      LOOP AT ist_BSID INTO wa_BSID.
        l_tabix =   sy-tabix .
*        IF wa_BSID-zlspr =  g_zlspr_x.
        wa_BSID-zlspr =  g_zlspr_d.
        MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr.
*        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  BSID FROM TABLE ist_BSID.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.
    IF p_d2x = 'X'.
      LOOP AT ist_BSID INTO wa_BSID.
        l_tabix =   sy-tabix .
        IF wa_BSID-zlspr =  g_zlspr_d.
          wa_BSID-zlspr =  g_zlspr_x.
          MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr.
        ENDIF.
      ENDLOOP.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*      MODIFY  BSID FROM TABLE ist_BSID.
*      COMMIT WORK.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    ENDIF.



  ENDIF.
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
FORM get_upd_bsegC.
  DATA : l_tabix  TYPE sy-tabix.

  CHECK NOT ist_srcBSID[] IS INITIAL.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT * INTO TABLE ist_bseg   FROM bseg
    FOR ALL ENTRIES  IN  ist_srcBSID
    WHERE
           bukrs  =  p_bukrs
     AND   belnr = ist_srcBSID-belnr
     AND   gjahr =  ist_srcBSID-gjahr
     AND   buzei = ist_srcBSID-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  CLEAR l_tabix.
  IF NOT ist_bseg IS INITIAL.
    IF p_any2D = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        wa_bseg-zlspr =  g_zlspr_d.
        MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
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
    CLEAR l_tabix.
    IF p_d2x = 'X'.
      LOOP AT ist_bseg INTO wa_bseg.
        l_tabix =   sy-tabix .
        IF wa_bseg-zlspr =  g_zlspr_d.
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
  ENDIF.
endform.                    "get_upd_bsegC
*----End of <RD1K960891>

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
FORM UPDATE_ZFI_REM_PYBLCK_L .
  data: ist_ZFI_REM_PYBLCK_L type table of ZFI_REM_PYBLCK_L,
        wa_ZFI_REM_PYBLCK_L type ZFI_REM_PYBLCK_L.
  data: count type ZFI_REM_PYBLCK_L-SRNO.

  IF p_any2D = 'X'.
    PMTBLOCK_TO = 'D'.
  elseif p_d2x = 'X'.
    PMTBLOCK_TO = 'X'.
  endif.

  select max( SRNO ) from ZFI_REM_PYBLCK_L into count.
  if not ist_srcbsik is initial.

    loop at ist_srcbsik into wa_srcbsik.
      count = count + 1.

      wa_ZFI_REM_PYBLCK_L-SRNO = count.
      wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsik-BUKRS.
      wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsik-LIFNR.
*wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
      wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsik-BELNR.
*   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsik-KIDNO.
      wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsik-REBZG.
      wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsik-SHKZG.
      wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsik-GJAHR.
      wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsik-BUZEI.
      wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsik-BSCHL.
      wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsik-BUDAT.
      wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsik-DMBTR .
      wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsik-WRBTR .
      wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsik-ZLSCH.
      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = wa_srcbsik-ZLSPR.
      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = PMTBLOCK_TO.
      wa_ZFI_REM_PYBLCK_L-LOCATION = wa_srcbsik-XREF1_HD.
      wa_ZFI_REM_PYBLCK_L-UNAME = sy-UNAME.
      wa_ZFI_REM_PYBLCK_L-USDATE = sy-datum.
      wa_ZFI_REM_PYBLCK_L-USTIME = sy-uzeit.

      insert ZFI_REM_PYBLCK_L from wa_ZFI_REM_PYBLCK_L.
    endloop.

    commit work.
    refresh ist_srcbsik.
  endif.

  if not ist_srcbsid is initial.

    loop at ist_srcbsid into wa_srcbsid.
      count = count + 1.

      wa_ZFI_REM_PYBLCK_L-SRNO = count.
      wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsid-BUKRS.
*   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
      wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsid-KUNNR.
      wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsid-BELNR.
*   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsid-KIDNO.
      wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsid-REBZG.
      wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsid-SHKZG.
      wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsid-GJAHR.
      wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsid-BUZEI.
      wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsid-BSCHL.
      wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsid-BUDAT.
      wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsid-DMBTR .
      wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsid-WRBTR .
      wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsid-ZLSCH.
      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = wa_srcbsid-ZLSPR.
      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = PMTBLOCK_TO.
      wa_ZFI_REM_PYBLCK_L-LOCATION = wa_srcbsid-XREF1_HD.
      wa_ZFI_REM_PYBLCK_L-UNAME = sy-UNAME.
      wa_ZFI_REM_PYBLCK_L-USDATE = sy-datum.
      wa_ZFI_REM_PYBLCK_L-USTIME = sy-uzeit.

      insert ZFI_REM_PYBLCK_L from wa_ZFI_REM_PYBLCK_L.
    endloop.
    commit work.
    refresh ist_srcbsid.
  endif.
ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
*end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778

*-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
  DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
  REFRESH lt_acchg. CLEAR ls_acchg.
  ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
  APPEND ls_acchg TO lt_acchg.
  CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
       i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
ENDFORM.
