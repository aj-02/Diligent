*&---------------------------------------------------------------------*
*& Report  ZPME_SFORM_REPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zpme_sform_report.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
TABLES: ehs_perprosc, ehs_perprscd, ehs_pernr,  "#EC CI_USAGE_OK[2217206]
        ehs00fbpersdat,t7ehs00_protexam,t7ehs00_examlab,t7ehs00_examphy,T7EHS00_srv_exa.  "#EC CI_USAGE_OK[2217206]
TYPES: t_ehs_pernr TYPE STANDARD TABLE OF ehs_pernr,  "#EC CI_USAGE_OK[2217206]
       t_perprscd  TYPE STANDARD TABLE OF ehs_perprscd,  "#EC CI_USAGE_OK[2217206]
       t_prott     TYPE STANDARD TABLE OF t7ehs00_prott.  "#EC CI_USAGE_OK[2217206]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
TYPES: BEGIN OF ty_perprosc_t,
        pernr        TYPE ehs_pernr-pernr,  "#EC CI_USAGE_OK[2217206]
        sname        TYPE ehs_pernr-sname,  "#EC CI_USAGE_OK[2217206]
        gbdat        TYPE ehs_pernr-gbdat,  "#EC CI_USAGE_OK[2217206]
        perid        TYPE ehs_pernr-perid,  "#EC CI_USAGE_OK[2217206]
        person_flag  TYPE ehs_pernr-person_flag,  "#EC CI_USAGE_OK[2217206]
        pgroup       LIKE ehs_perprosc-pgroup,  "#EC CI_USAGE_OK[2217206]
        pnumber      LIKE ehs_perprosc-pnumber,  "#EC CI_USAGE_OK[2217206]
        pname(50),
        prot_type     TYPE ehs_perprosc-prot_type,  "#EC CI_USAGE_OK[2217206]
        prot_frtypnam TYPE t7ehs00_freqtypt-prot_frtypnam,  "#EC CI_USAGE_OK[2217206]
        last_sched    TYPE ehs_perprosc-last_sched,  "#EC CI_USAGE_OK[2217206]
        next_sched    TYPE ehs_perprosc-next_sched,  "#EC CI_USAGE_OK[2217206]
        status_prot   TYPE ehs_perprosc-status_prot,  "#EC CI_USAGE_OK[2217206]
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*         status_protnam TYPE ehs00_stat_prott,
        status_protnam TYPE CHAR20,
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
        byhand_flag  LIKE ehs_perprosc-byhand_flag,  "#EC CI_USAGE_OK[2217206]
        byhand_txt(20),
        begda        LIKE ehs_perprscd-begda,  "#EC CI_USAGE_OK[2217206]
        endda        LIKE ehs_perprscd-endda,  "#EC CI_USAGE_OK[2217206]
        uname        LIKE ehs_perprosc-uname,  "#EC CI_USAGE_OK[2217206]
        aedtm        LIKE ehs_perprosc-aedtm,  "#EC CI_USAGE_OK[2217206]
        person_id    LIKE ehs_pernr-person_id,  "#EC CI_USAGE_OK[2217206]
        nachn        LIKE ehs_pernr-nachn,  "#EC CI_USAGE_OK[2217206]
        vorna        LIKE ehs_pernr-vorna,  "#EC CI_USAGE_OK[2217206]
        werks        TYPE persa,  " Personnel Area
        name1        TYPE pbtxt,  " Personnel Area Text
        orgeh        TYPE orgeh,  " Organizational Unit
        orgtx        TYPE orgtx,  " Short Text of Organizational Unit
        grade        TYPE zdesignation_rev-grade,
        desig_text   TYPE zdesignation_rev-desig_text,

    END OF ty_perprosc_t.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

DATA:  o_perprosc  TYPE STANDARD TABLE OF ty_perprosc_t,
       o_perprscd  TYPE t_perprscd,
              i_ehspernr  TYPE t_ehs_pernr.
DATA:  wa_perprosc    TYPE ty_perprosc_t.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
DATA:  wa_perprscd TYPE ehs_perprscd.  "#EC CI_USAGE_OK[2217206]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

data : fm_name type rs38l_fnam.
data : output_options type ssfcompop,
       control type ssfctrlop.
data : it_prh type table of zpme_pa_prh,
       wa_prh like line of it_prh.
data : it_hpe type table of zpme_pa_hpe,
       wa_hpe like line of it_hpe.

data :  outop         TYPE ssfcompop,
        cparam        TYPE ssfctrlop.
data: st_control_parameters type ssfctrlop,
      st_output_options type ssfcompop,
      st_document_output_info type ssfcrespd,
      st_job_output_info type ssfcrescl,
      st_job_output_options type ssfcresop,
      v_e_devtype type rspoptype,
      v_language type sflangu value 'E'.
data : lt_otfdata type table of itcoo.

parameters : lv_para type char10.
parameters : lv_doc type char10.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
DATA lv_begda type T7EHS00_service-srv_opendate.  "#EC CI_USAGE_OK[2217206]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

*GET ehs_pernr.
*  APPEND ehs_pernr TO i_ehspernr.
*
*GET ehs_perprosc.
*  MOVE-CORRESPONDING ehs_perprosc TO wa_perprosc.
*  APPEND wa_perprosc TO o_perprosc.
*
*GET ehs_perprscd.
*  APPEND ehs_perprscd TO o_perprscd.
************************************
*  sort o_perprscd by begda descending.
*  READ TABLE o_perprscd INTO wa_perprscd index 1.
*  if sy-subrc = 0.
*    lv_begda = wa_perprscd-begda.
*  endif.
perform get_detail.

***********************************


CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = 'ZPME_SFORM_REPORT'
  IMPORTING
    fm_name            = fm_name
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    others             = 3.

if sy-subrc <> 0.
  message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.

outop-tdnoprev = 'X'.
outop-tdtitle = sy-title.
outop-tdnewid = 'X'.
outop-tdprinter = 'PDF1'.


cparam-no_dialog  = 'X' .
cparam-preview    = 'X'.
cparam-getotf     = 'X'.

*control-preview = 'X'.
*control-no_open = ' '.
*control-no_close = ' '.
*control-no_dialog = ''.
*control-getotf = ' '.
*control-device = 'PRINTER'.

*output_options-tddest = 'LOCL'.

call function fm_name
  exporting
             control_parameters = cparam
             output_options     = outop
**   ARCHIVE_INDEX              =
**   ARCHIVE_INDEX_TAB          =
**   ARCHIVE_PARAMETERS         =
*   control_parameters         = control
**   MAIL_APPL_OBJ              =
**   MAIL_RECIPIENT             =
**   MAIL_SENDER                =
*   output_options             = output_options
*   USER_SETTINGS              = 'X'
    lv_cpf_no                  = lv_para
    lv_doc                     = lv_doc
    lv_begda                   = lv_begda
 IMPORTING
    document_output_info = st_document_output_info
    job_output_info      = st_job_output_info
    job_output_options   = st_job_output_options
* Begin of Changes on 25-Jun-2013
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
* End of Changes on 25-Jun-2013
          .
if sy-subrc <> 0.
  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
endif.

refresh lt_otfdata.
lt_otfdata[] = st_job_output_info-otfdata[].

CALL FUNCTION 'FOPC_REPORT_SHOW_PDF'
  EXPORTING
    it_otfdata = lt_otfdata.


*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_detail .
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  data : l_pernr type T7EHS00_MAPPERNR-intpernr.  "#EC CI_USAGE_OK[2217206]
  data :l_srv_signoffdate type T7EHS00_SERVICE-srv_signoffdate,  "#EC CI_USAGE_OK[2217206]
        l_srv_exam_date type T7EHS00_srv_exa-srv_exam_date,  "#EC CI_USAGE_OK[2217206]
        wa_pme_pa_det type zpme_pa_det.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  DATA : wa_T7EHS00_SRV_EXA TYPE T7EHS00_SRV_EXA,  "#EC CI_USAGE_OK[2217206]
        ist_T7EHS00_SRV_EXA TYPE STANDARD TABLE OF T7EHS00_SRV_EXA.  "#EC CI_USAGE_OK[2217206]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  data : wa_T7EHS00_PERPRscd type T7EHS00_PERPRscd.  "#EC CI_USAGE_OK[2217206]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  select * from zpme_pa_prh into table it_prh where cpf_no = lv_para and docu_no = lv_doc.

  clear : l_pernr.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT INTPERNR FROM T7EHS00_MAPPERNR  "#EC CI_USAGE_OK[2217206]
 INTO L_PERNR UP TO 1 ROWS WHERE PERSON_ID = LV_PARA
 ORDER BY PRIMARY KEY .
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
 ENDSELECT.

  if sy-subrc = 0.
    clear : wa_pme_pa_det.
    select single * from zpme_pa_det
      into wa_pme_pa_det
      where cpf_no = lv_para
      and docu_no = lv_doc.

    if sy-subrc = 0.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT SRV_EXAM_DATE
 INTO L_SRV_EXAM_DATE FROM T7EHS00_SRV_EXA UP TO 1 ROWS WHERE SRV_NUMBER = WA_PME_PA_DET-SRV_NUMBER  "#EC CI_USAGE_OK[2217206]
 ORDER BY PRIMARY KEY .
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
 ENDSELECT.
      if sy-subrc = 0.
        lv_begda = l_srv_exam_date.
      else.
        clear : l_srv_signoffdate.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        select single srv_signoffdate
          from T7EHS00_SERVICE  "#EC CI_USAGE_OK[2217206]
          into l_srv_signoffdate
          where srv_number = wa_pme_pa_det-srv_number
          and pernr = l_pernr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        if l_srv_signoffdate = '00000000'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          select single srv_opendate
              from T7EHS00_SERVICE  "#EC CI_USAGE_OK[2217206]
              into l_srv_signoffdate
              where srv_number = wa_pme_pa_det-srv_number
              and pernr = l_pernr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        endif.
        lv_begda = l_srv_signoffdate.
      endif.

      CLEAR:ist_T7EHS00_SRV_EXA,WA_T7EHS00_SRV_EXA.
      REFRESH ist_T7EHS00_SRV_EXA.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT * FROM T7EHS00_SRV_EXA  "#EC CI_USAGE_OK[2217206]
          INTO CORRESPONDING FIELDS OF TABLE ist_T7EHS00_SRV_EXA
          WHERE SRV_NUMBER = wa_pme_pa_det-srv_number.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF NOT ist_T7EHS00_SRV_EXA[] IS INITIAL.
        SORT ist_T7EHS00_SRV_EXA BY SRV_EXAM_DATE ASCENDING.
        READ TABLE ist_T7EHS00_SRV_EXA INTO wa_T7EHS00_SRV_EXA INDEX 1.
        lv_begda = wa_T7EHS00_SRV_EXA-SRV_EXAM_DATE.
      ENDIF.
*DATA :   ist_T7EHS00_PERPROSC TYPE STANDARD TABLE OF T7EHS00_PERPROSC  ,
*         WA_T7EHS00_PERPROSC
*SELECT * from T7EHS00_PERPROSC
*  into CORRESPONDING FIELDS OF TABLE ist_T7EHS00_PERPROSC
*  where pernr = l_pernr   .
*  SORT ist_T7EHS00_PERPROSC by number DESCENDING.
*  READ TABLE ist_T7EHS00_PERPROSC INTO WA_T7EHS00_PERPROSC INDEX 1.
*          lv_begda = WA_T7EHS00_PERPROSC-LAST_SCHED.
*    endif.
*    select single * from T7EHS00_PERPRscd
*      into wa_T7EHS00_PERPRscd
*      where pernr = l_pernr
*      and endda = '99991231'.
*    select single last_sched from T7EHS00_PERPRosc
*  into lv_begda
*  where pernr = l_pernr
*      and pgroup = wa_T7EHS00_PERPRscd-pgroup
*      and pnumber = wa_T7EHS00_PERPRscd-pnumber.
**      and endda = '99991231'.
    endif.
  ENDIF.
endform.                    " GET_DETAIL
