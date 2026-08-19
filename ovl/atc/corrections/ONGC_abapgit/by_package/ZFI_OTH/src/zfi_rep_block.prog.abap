report zfi_rep_block .

*-----  PROGRAM FOR Removing payment blocks 'X'  ****
***********************************************************************
* Program    :  zfi_rep_block
*                                                                     *
*                                                                     *
* Author     : S.R.Sudha                     Date : 16.0 .2008
*
*                                                                     *
* Login Id   : CAB_SUDHA                                              *
*                                                                      *
* Description:Only for coreteam   purposes  for changing any payemnt *
*                 methods  when the need  arises
*  FS-no     : FS-FI-GL-41
*                                                                     *
* Tran.Code  : ZFIBLOCK
*
*                                                                     *
*----------------------------------------------------------------------*
***********************************************************************
*Change History
*Date        ChID     Login        Description
*22.04.2008  +002     CAB_SUDHA    JV Cahs call Sp gl added-
*                                   Payment method added
*18.12.08         CAB_SUDHA    JV Cahs call Sp gl added-
*                                   Payment method added

***********************************************************************

************************************************************************
*  Date         Transport       USERID          Description
* 03/09/2008  <RD1K960036>    CAB_DAVINDER   1)Replacement of USING
*                                              Keyword with TABLES in
*                                              Form name eventtab_build
*                                              & comment_build.
*                                            2)Raising of Exception
*                                              'PROGRAM_ERROR' & its
*                                              handling in function
*                                              'REUSE_ALV_LIST_DISPLAY'.
************************************************************************
*  Date         Transport   USERID          Description
* 19/12/2008  <RD1K960891> CAB_SUDHA Payment block for customers
* 25.02.09    cab_rama        FS-FI-AP-083_01 30000782    001
* 10.12.2009    RD1K967585  CAB_ALOK     CR30002778
*                                        Addition of INV REF in Report,
*                                        Creation of activity logs in separate Z table.
*26.03.2010   SAB_SUMAN                 CR 30003849      003
************************************************************************

type-pools : slis.

tables : bsik, t001, bkpf , bsid .


data : ist_bsik  type table of bsik.
data : ist_bseg type table of  bseg.
data : wa_bsik  type bsik.
data : wa_bseg type  bseg.

data : y_doc_nos like zfi_docnos occurs 0 with header line .
data : f_doc_nos like zfi_docnos occurs 0 with header line .

data: begin of ist_bkpf occurs 0,
      blart like bkpf-blart,
      belnr like bkpf-belnr,
      bldat like bkpf-bldat,
      budat like bkpf-budat,
      waers like bkpf-waers,
      usnam like bkpf-usnam,
      ppnam like bkpf-ppnam,
      gjahr like bkpf-gjahr, "Added PN
      bukrs like bkpf-bukrs,"Added PN
      xref  like bkpf-xref1_hd,
      end of ist_bkpf.

data : begin of ist_srcbsik occurs 0 ,
       selcbox(1) type c,
       lifnr like bsik-lifnr ,
       umskz like bsik-umskz,
       bukrs like bsik-bukrs ,
       gjahr like bsik-gjahr,
       belnr  like bsik-belnr,
       buzei  like bsik-buzei,
       budat  like bsik-budat,
       bschl like bsik-bschl,
       zlsch like bsik-zlsch,                               "+002
       zlspr like  bsik-zlspr,
       shkzg like bsik-shkzg,
       gsber like  bsik-gsber,
       dmbtr like bsik-dmbtr,
       wrbtr like bsik-wrbtr,
       kidno like  bsik-kidno,                              "+001
*Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       rebzg LIKE bsik-rebzg,        " Invoice Ref.
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       usnam  like bkpf-usnam,
  xref1_hd like bkpf-xref1_hd.
*       include structure  bsis.
data:  end of ist_srcbsik .

data : wa_srcbsik like ist_srcbsik.
data : ist_bsiks like ist_srcbsik occurs 0 with header line.
*-----Start <RD1K960891>
data : begin of ist_srcbsid occurs 0 ,
       selcbox(1) type c,
       kunnr like bsid-kunnr ,
       umskz like bsid-umskz,
       bukrs like bsid-bukrs ,
       gjahr like bsid-gjahr,
       belnr  like bsid-belnr,
       buzei  like bsid-buzei,
       budat  like bsid-budat,
       bschl like bsid-bschl,
       zlsch like bsid-zlsch,
       zlspr like  bsid-zlspr,
       shkzg like bsid-shkzg,
       gsber like  bsid-gsber,
       dmbtr like bsid-dmbtr,
       wrbtr like bsid-wrbtr,
       kidno like  bsid-kidno,
       usnam  like bkpf-usnam,
*Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
       rebzg LIKE bsid-rebzg,        " Invoice Ref.
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
  xref1_hd like bkpf-xref1_hd.
data:  end of ist_srcbsid .

data : wa_srcbsid like ist_srcbsid.
data : ist_bsids like ist_srcbsid occurs 0 with header line.
data : ist_bsid  type table of bsid.
data : wa_bsid  type bsid.
*-----End of <RD1K960891>

data : w_repid type sy-repid.

data:  is_layout  type  slis_layout_alv,
       ist_fieldcat type  slis_fieldcat_alv  , "line.
       ist_fcat type  table of slis_fieldcat_alv,
        lt_sorttab type slis_t_sortinfo_alv,
       ls_sorttab type slis_sortinfo_alv. " sort structure for ALV

data  : mpos type i .
data : gt_list_top_of_page type slis_t_listheader,
       gt_list_end_of_list type slis_t_listheader,
       gt_events   type slis_t_event.


selection-screen : begin of block  blk1  with frame title  text-001.

select-options : s_lifnr for bsik-lifnr ,      "+<RD1K960891>
                 s_kunnr for bsid-kunnr ,      "+<RD1K960891>
                 s_year  for bsik-gjahr obligatory,
                 s_gsber for bsik-gsber,
                 s_budat for bsik-budat,
*   Start of addition Prabu K on 06.07.2009
                 s_xref1 for bkpf-xref1_hd.
*  End of addition Prabu K on 06.07.2009

parameters : p_bukrs like bsik-bukrs obligatory .

skip  2.

selection-screen : end of block blk1.

parameters : p_zlsprf   like bseg-zlspr,   " obligatory,     cfi_kasHYAP RD1K993183
             p_zlsprt   like bseg-zlspr.   " obligatory .    cfi_kasHYAP RD1K993183

* *Start of addition Prabu K on 07.07.2009
at selection-screen on value-request for s_xref1-low.
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
    exporting
      retfield        = 'SACHX'
      dynpprog        = 'ZFI_REM_PYBLCK'
      dynpnr          = sy-dynnr
      dynprofield     = 'S_XREF1-LOW'
      value_org       = 'S'
    tables
      value_tab       = it_final
    exceptions
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
    exporting
      retfield        = 'SACHX'
      dynpprog        = 'ZFI_REM_PYBLCK'
      dynpnr          = sy-dynnr
      dynprofield     = 'S_XREF1-HIGH'
      value_org       = 'S'
    tables
      value_tab       = it_final
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

  if sy-subrc <> 0.
*
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  endif.

* End of addition Prabu K on 06.07.2009

at selection-screen on p_bukrs .
  select single * from t001  where bukrs = p_bukrs.
  if sy-subrc <> 0.
    message e010(fi).
  endif.
*----start of <RD1K960891>
  authority-check object 'F_BKPF_BUK'
              id 'ACTVT' field '02'
              id 'BUKRS' field p_bukrs.

  if sy-subrc <> 0.
    message  e091(8b) with p_bukrs.
  endif.

*---End of  <RD1K960891>

*------------------------------------------------------*
start-of-selection.
*------------------------------------------------------*
*----start of <RD1K960891>
  if s_lifnr is initial and s_kunnr is initial.
    message   e322(zfi).
  endif.
  if  not  s_lifnr is initial  and  not s_kunnr is initial .
    message   e322(zfi).
  endif.

  if not s_lifnr  is initial.
    perform get_docs.
    perform display_docs.
  elseif  not s_kunnr is initial.
    perform get_docs_cust.
    perform display_docs_cust.
  endif.
*----End of <RD1K960891>

*&---------------------------------------------------------------------*
*&      Form  display_docs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_docs.
  perform init_fieldcat.

* Begin of <RD1K960036>
*  PERFORM eventtab_build USING gt_events[].
  perform eventtab_build tables gt_events.
* End of <RD1K960036>

* Begin of <RD1K960036>
*  PERFORM comment_build USING gt_list_top_of_page[].
  perform comment_build tables gt_list_top_of_page.
* End of <RD1K960036>

  perform  sort_build .
  perform  print_alv.

endform.                    " display_docs
*&---------------------------------------------------------------------*
*&      Form  init_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form init_fieldcat.
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

  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'LIFNR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'VendorNumber'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.




  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BELNR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Doc.No.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'GSBER'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Business Area'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

*---+001
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KIDNO'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Payment Reference'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

*-------+001
*BEGIN of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
 mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Invoice Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'GJAHR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Year'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.




  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUZEI'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Item.no.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BSCHL'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Key.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUDAT'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Date'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'DMBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WRBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSCH'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymentMethod.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSPR'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymntBlock'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

*  Start of addition Prabu K on 06.07.2009
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSIK'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

* End of addition Prabu K on 06.07.2009



endform.                    " init_fieldcat
*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
*Begin of <RD1K960036>
*FORM eventtab_build USING    p_gt_events[].
form eventtab_build tables   p_gt_events.
*End of <RD1K960036>

  data : ls_event type slis_alv_event.
  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type = 0
    importing
      et_events   = gt_events.
  read table gt_events with key name =  slis_ev_user_command
                            into ls_event.
  if sy-subrc = 0.
    move 'MAKE_COMMAND' to ls_event-form.
    append ls_event to gt_events.
  endif.
  clear ls_event.


endform.                    " eventtab_build
*&---------------------------------------------------------------------*
*&      Form  comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
* Begin of <RD1K960036>
*FORM comment_build USING    p_gt_list_top_of_page[].
form comment_build tables    p_gt_list_top_of_page.
* End of <RD1K960036>
endform.                    " comment_build
*&---------------------------------------------------------------------*
*&      Form  sort_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sort_build.

  w_repid = sy-repid.
  is_layout-key_hotspot = 'X'.
  is_layout-colwidth_optimize = 'X'.

  ls_sorttab-fieldname = 'KIDNO'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.

  ls_sorttab-fieldname = 'LIFNR'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.
  ls_sorttab-fieldname = 'BSCHL'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.
  ls_sorttab-fieldname = 'BELNR'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.
  ls_sorttab-fieldname = 'BUDAT'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.




endform.                    " sort_build
*&---------------------------------------------------------------------*
*&      Form  print_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form print_alv.

  call function 'REUSE_ALV_LIST_DISPLAY'
       exporting
            i_callback_program       = w_repid
            i_callback_pf_status_set = 'ALV_PFST'
            i_callback_user_command  = 'MAKE_COMMAND'
            is_layout                = is_layout
            it_fieldcat              = ist_fcat[]
            it_sort                  = lt_sorttab
            it_events                = gt_events
            i_save                   = 'A'
       tables
            t_outtab                 = ist_srcbsik
* Begin of <RD1K960036>
*  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
       exceptions
            program_error            = 1.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
* End of <RD1K960036>


endform.                    " print_alv
*---------------------------------------------------------------------*
*       FORM alv_pfst                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
form alv_pfst using rt_extab type slis_t_extab.
  set pf-status 'S100'.
endform.                    "alv_pfst

*---------------------------------------------------------------------*
*       FORM make_command                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  R_UCOMM                                                       *
*  -->  RS_SELFIELD                                                   *
*---------------------------------------------------------------------*
form make_command using r_ucomm like sy-ucomm
                        rs_selfield type slis_selfield.
*-----------------------------------------------------*
*-----------------------------------------------------*
  data : index_aux like sy-tabix.
  index_aux = rs_selfield-tabindex.
  case r_ucomm.

    when 'REL'.
      delete ist_srcbsik where  selcbox <> 'X'.

      perform   get_upd_bsik.
      perform   get_upd_bseg.
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
*end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      leave screen.
    when 'ALL'.
      perform  select_all.
    when 'SAL'.
      perform  deselect_all.

    when '&F03' or 'BACK' .
      leave  program.

  endcase.

endform.                    "make_command
*---------------------------------------------------------------------*
*&      Form  select_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form select_all.
  loop at ist_srcbsik.
    ist_srcbsik-selcbox = 'X'.
    modify ist_srcbsik.
  endloop.

endform.                    " select_all
*&---------------------------------------------------------------------*
*&      Form  deselect_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form deselect_all.
  loop at ist_srcbsik.
    ist_srcbsik-selcbox = ' '.
    modify ist_srcbsik.
  endloop.
endform.                    " deselect_all
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  get_upd_bsik
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_upd_bsik.

  data : l_tabix  type sy-tabix.

  check not ist_srcbsik[] is initial.

  select * into table ist_bsik   from bsik
    for all entries  in  ist_srcbsik
    where   lifnr = ist_srcbsik-lifnr
          and  bukrs  =  p_bukrs
           and gjahr = ist_srcbsik-gjahr
           and belnr = ist_srcbsik-belnr
           and buzei = ist_srcbsik-buzei.

  if not ist_bsik is initial.
    loop at ist_bsik into wa_bsik.
      l_tabix =   sy-tabix .
      if wa_bsik-zlspr =  p_zlsprf.
        wa_bsik-zlspr =  p_zlsprt.
        modify ist_bsik  from  wa_bsik index l_tabix  transporting zlspr.
      endif.
    endloop.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
*    modify  bsik from table ist_bsik.
*
*    commit work.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
  endif.

*  LEAVE SCREEN.
endform.                    " get_upd_bsik
*
*&---------------------------------------------------------------------*
*&      Form  get_upd_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_upd_bseg.
  data : l_tabix  type sy-tabix.

  check not ist_srcbsik[] is initial.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  select * into table ist_bseg   from bseg
    for all entries  in  ist_srcbsik
    where
           bukrs  =  p_bukrs
     and   belnr = ist_srcbsik-belnr
     and   gjahr = ist_srcbsik-gjahr
     and   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  if not ist_bseg is initial.

    loop at ist_bseg into wa_bseg.
      l_tabix =   sy-tabix .
      if wa_bseg-zlspr =  p_zlsprf.
        wa_bseg-zlspr =   p_zlsprt.
        modify ist_bseg  from  wa_bseg index l_tabix  transporting zlspr.
      endif.
    endloop.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*    modify bseg from table ist_bseg.
    LOOP AT ist_bseg INTO wa_bseg.
      PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
    ENDLOOP.
    COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC



  endif.


endform.                    " get_upd_bseg
*&---------------------------------------------------------------------*
*&      Form  get_docs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_docs.
  select bukrs lifnr umskz gjahr belnr buzei budat bschl
*begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
*  zlsch zlspr shkzg gsber dmbtr wrbtr kidno appending
   zlsch zlspr shkzg gsber dmbtr wrbtr kidno rebzg appending
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
  corresponding fields of table
                ist_srcbsik  from bsik
                where
                bukrs  =  p_bukrs
                and lifnr  in s_lifnr
                and gjahr in s_year
                and gsber in s_gsber
                and budat in  s_budat.  "#EC CI_NOORDER




  delete  ist_srcbsik where zlspr <> p_zlsprf.


*Start of addition Prabu K on 03.07.2009
  data wa_bkpf type bkpf.
  loop at ist_srcbsik into wa_srcbsik.

    select single * from bkpf into wa_bkpf where bukrs = wa_srcbsik-bukrs and belnr = wa_srcbsik-belnr
       and xref1_hd in s_xref1.  "#EC CI_NOORDER
    if sy-subrc ne 0.
      delete table ist_srcbsik from wa_srcbsik.
    else.
      wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
      modify ist_srcbsik from wa_srcbsik.
    endif.

  endloop.
*  End  of addition Prabu K on 03.07.2009
  ist_bsiks[] = ist_srcbsik[].


  refresh ist_srcbsik.
  clear ist_srcbsik.


  loop at ist_bsiks .
    if ist_bsiks-umskz = 'P' or ist_bsiks-umskz = 'F'
    or ist_bsiks-umskz = ':'    or                          "+002
    ist_bsiks-umskz  is initial.
      ist_srcbsik = ist_bsiks.
      append ist_srcbsik.
      clear ist_srcbsik.
    endif.
  endloop.



  check  not ist_srcbsik[] is initial.

  loop at ist_srcbsik.
    if ist_srcbsik-shkzg = 'S'.
      ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
      ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
    elseif ist_srcbsik-shkzg = 'H'.
      ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
      ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
    endif.
    modify ist_srcbsik .
  endloop.

  ist_bsiks[] = ist_srcbsik[].

  sort ist_srcbsik by lifnr bschl belnr budat.

endform.                    " get_docs
*-----------------------start of <RD1K960891>
*&---------------------------------------------------------------------*
*&      Form  get_docs_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_docs_cust.
  select bukrs kunnr umskz gjahr belnr buzei budat bschl
*begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
*  zlsch zlspr shkzg gsber dmbtr wrbtr kidno appending
   zlsch zlspr shkzg gsber dmbtr wrbtr kidno rebzg appending
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
   corresponding fields of table
                  ist_srcbsid  from bsid
                  where
                  bukrs  =  p_bukrs
                  and kunnr  in s_kunnr
                  and gjahr in s_year
                  and gsber in s_gsber
                  and budat in  s_budat.  "#EC CI_NOORDER



  delete  ist_srcbsid where zlspr <> p_zlsprf.

*Start of addition Prabu K on 03.07.2009
  data wa_bkpf type bkpf.
  loop at ist_srcbsid into wa_srcbsid.

    select single * from bkpf into wa_bkpf where bukrs = wa_srcbsid-bukrs and belnr = wa_srcbsid-belnr
       and xref1_hd in s_xref1.  "#EC CI_NOORDER
    if sy-subrc ne 0.
      delete table ist_srcbsid from wa_srcbsid.
    else.
      wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
      modify ist_srcbsid from wa_srcbsid.
    endif.

  endloop.
*  End  of addition Prabu K on 03.07.2009
  ist_bsids[] = ist_srcbsid[].


  refresh ist_srcbsid.
  clear ist_srcbsid.


  loop at ist_bsids .
*{001
*    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'.
    if ( ist_bsids-umskz = 'K' or ist_bsids-umskz = 'H' or ist_bsids-umskz = 'O') or
*Start of changes by SOGET - 003
*( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
       ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ) or ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'Q' ).
*End of changes by SOGET - 003
*}001
      ist_srcbsid = ist_bsids.
      append ist_srcbsid.
      clear ist_srcbsid.
    endif.
  endloop.



  check  not ist_srcbsid[] is initial.

  loop at ist_srcbsid.
    if ist_srcbsid-shkzg = 'S'.
      ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
      ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
    elseif ist_srcbsid-shkzg = 'H'.
      ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
      ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
    endif.
    modify ist_srcbsid .
  endloop.

  ist_bsids[] = ist_srcbsid[].

  sort ist_srcbsid by kunnr bschl belnr budat.


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
  perform init_fieldcat_cust.
  perform eventtab_build_cust using gt_events[].
  perform  sort_build_cust .
  perform  print_alv_cust.

endform.                    " display_docs_cust
*&---------------------------------------------------------------------*
*&      Form  eventtab_build_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
form eventtab_build_cust using    p_gt_events.
  data : ls_event type slis_alv_event.
  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type = 0
    importing
      et_events   = gt_events.
  read table gt_events with key name =  slis_ev_user_command
                            into ls_event.
  if sy-subrc = 0.
    move 'MAKEC_COMMAND' to ls_event-form.
    append ls_event to gt_events.
  endif.
  clear ls_event.


endform.                    " eventtab_build_cust
*&---------------------------------------------------------------------*
*&      Form  sort_build_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sort_build_cust.

  w_repid = sy-repid.
  is_layout-key_hotspot = 'X'.
  is_layout-colwidth_optimize = 'X'.

  ls_sorttab-fieldname = 'KIDNO'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.

  ls_sorttab-fieldname = 'KUNNR'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.
  ls_sorttab-fieldname = 'BSCHL'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.
  ls_sorttab-fieldname = 'BELNR'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.
  ls_sorttab-fieldname = 'BUDAT'.
  ls_sorttab-up = 'X'.
  append ls_sorttab to lt_sorttab.

endform.                    " sort_build_cust
*&---------------------------------------------------------------------*
*&      Form  print_alv_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form print_alv_cust.
  call function 'REUSE_ALV_LIST_DISPLAY'
    exporting
      i_callback_program       = w_repid
      i_callback_pf_status_set = 'ALV_PFSTS'
      i_callback_user_command  = 'MAKEC_COMMAND'
      is_layout                = is_layout
      it_fieldcat              = ist_fcat[]
      it_sort                  = lt_sorttab
      it_events                = gt_events
      i_save                   = 'A'
    tables
      t_outtab                 = ist_srcbsid
* Begin of Changes on 20-Jun-2013
       EXCEPTIONS
            PROGRAM_ERROR = 1
            OTHERS        = 2.
* End of Changes on 20-Jun-2013
  if sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " print_alv_cust
*---------------------------------------------------------------------*
*       FORM alv_pfst                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
form alv_pfsts using rt_extab type slis_t_extab.
  set pf-status 'S100'.
endform.                    "alv_pfsts

*---------------------------------------------------------------------*
*       FORM make_command                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  R_UCOMM                                                       *
*  -->  RS_SELFIELD                                                   *
*---------------------------------------------------------------------*
form makec_command using r_ucomm like sy-ucomm
                        rs_selfield type slis_selfield.
*-----------------------------------------------------*
*-----------------------------------------------------*
  data : index_aux like sy-tabix.
  index_aux = rs_selfield-tabindex.
  case r_ucomm.

    when 'REL'.
      delete ist_srcbsid where  selcbox <> 'X'.

      perform   get_upd_bsid.
      perform   get_upd_bseg_c.
*Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
*end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
      leave screen.
    when 'ALL'.
      perform  select_allc.
    when 'SAL'.
      perform  deselect_allc.

    when '&F03' or 'BACK' .
      leave  program.

  endcase.

endform.                    "makec_command
*---------------------------------------------------------------------*
*&      Form  select_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form select_allc.
  loop at ist_srcbsid.
    ist_srcbsid-selcbox = 'X'.
    modify ist_srcbsid.
  endloop.

endform.                    " select_all
*&---------------------------------------------------------------------*
*&      Form  deselect_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form deselect_allc.
  loop at ist_srcbsid.
    ist_srcbsid-selcbox = ' '.
    modify ist_srcbsid.
  endloop.
endform.                    " deselect_all
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  get_upd_bsid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_upd_bsid.

  data : l_tabix  type sy-tabix.

  check not ist_srcbsid[] is initial.

  select * into table ist_bsid   from bsid
    for all entries  in  ist_srcbsid
    where   kunnr = ist_srcbsid-kunnr
          and  bukrs  =  p_bukrs
           and gjahr = ist_srcbsid-gjahr
           and belnr = ist_srcbsid-belnr
           and buzei = ist_srcbsid-buzei.

  if not ist_bsid is initial.
    loop at ist_bsid into wa_bsid.
      l_tabix =   sy-tabix .
      if wa_bsid-zlspr =  p_zlsprf.
        wa_bsid-zlspr =  p_zlsprt.
        modify ist_bsid  from  wa_bsid index l_tabix  transporting zlspr.
      endif.
    endloop.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*    modify  bsid from table ist_bsid.
*
*    commit work.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
  endif.

*  LEAVE SCREEN.
endform.                    " get_upd_bsid
*
*&---------------------------------------------------------------------*
*&      Form  get_upd_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_upd_bseg_c.
  data : l_tabix  type sy-tabix.

  check not ist_srcbsid[] is initial.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  select * into table ist_bseg   from bseg
    for all entries  in  ist_srcbsid
    where
           bukrs  =  p_bukrs
     and   belnr = ist_srcbsid-belnr
     and   gjahr = ist_srcbsid-gjahr
     and   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  if not ist_bseg is initial.

    loop at ist_bseg into wa_bseg.
      l_tabix =   sy-tabix .
      if wa_bseg-zlspr =  p_zlsprf.
        wa_bseg-zlspr =   p_zlsprt.
        modify ist_bseg  from  wa_bseg index l_tabix  transporting zlspr.
      endif.
    endloop.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*    modify bseg from table ist_bseg.
    LOOP AT ist_bseg INTO wa_bseg.
      PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
    ENDLOOP.
    COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC



  endif.


endform.                    " get_upd_bseg_c
*&---------------------------------------------------------------------*
*&      Form  init_fieldcat_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form init_fieldcat_cust.
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

  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KUNNR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'CustomerNumber'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.




  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BELNR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Doc.No.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'GSBER'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Business Area'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

*---+001
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'KIDNO'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Payment Reference'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

*-------+001
*begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'REBZG'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Invoice Reference'.
*  ist_fieldcat-lowercase  = 'Y'.
  APPEND ist_fieldcat TO ist_fcat.
  CLEAR ist_fieldcat.
*end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'GJAHR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Year'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.




  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUZEI'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Item.no.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BSCHL'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Key.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'BUDAT'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Posting Date'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'DMBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.



  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'WRBTR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSCH'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymentMethod.'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.


  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'ZLSPR'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'PaymntBlock'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.
*Start of addition Prabu K on 06.07.2009

  mpos = mpos + 1.
  ist_fieldcat-fieldname = 'XREF1_HD'.
  ist_fieldcat-tabname = 'IST_SRCBSID'.
  ist_fieldcat-ddictxt = 'M'.
  ist_fieldcat-col_pos =  mpos.
  ist_fieldcat-seltext_m  = 'Location'.
  ist_fieldcat-lowercase  = 'Y'.
  append ist_fieldcat to ist_fcat.
  clear ist_fieldcat.
*  End of addition Prabu K on 06.07.2009
endform.                    " init_fieldcat_cust
*-----end of +<RD1K960891>


*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZFI_REM_PYBLCK_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
FORM UPDATE_ZFI_REM_PYBLCK_L .
* update Logs to table ZFI_REM_PYBLCK_L
data: ist_ZFI_REM_PYBLCK_L type table of ZFI_REM_PYBLCK_L,
      wa_ZFI_REM_PYBLCK_L type ZFI_REM_PYBLCK_L.
data: count type ZFI_REM_PYBLCK_L-SRNO.



select max( SRNO ) from ZFI_REM_PYBLCK_L into count.
if not ist_srcbsik is initial.

 loop at ist_srcbsik into wa_srcbsik.
   count = count + 1.

   wa_ZFI_REM_PYBLCK_L-SRNO = count.
   wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsik-BUKRS.
   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsik-LIFNR.
*wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
   wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsik-BELNR.
   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsik-KIDNO.
   wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsik-REBZG.
   wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsik-SHKZG.
   wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsik-GJAHR.
   wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsik-BUZEI.
   wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsik-BSCHL.
   wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsik-BUDAT.
   wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsik-DMBTR .
   wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsik-WRBTR .
   wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsik-ZLSCH.
   wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = p_zlsprf.
   wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = p_zlsprt.
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
   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsid-KIDNO.
   wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsid-REBZG.
   wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsid-SHKZG.
   wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsid-GJAHR.
   wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsid-BUZEI.
   wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsid-BSCHL.
   wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsid-BUDAT.
   wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsid-DMBTR .
   wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsid-WRBTR .
   wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsid-ZLSCH.
   wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = p_zlsprf.
   wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = p_zlsprt.
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
