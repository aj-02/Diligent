************************************************************************
* Programm ZRIWFWA01
*-----------------------------------------------------------------------
* Purpose: Implementation of object type ZWCA
************************************************************************
*
* type-pools

* elementary types

* structures types

* tables types

* constants

* includes
INCLUDE <object>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      NUMBER LIKE WCAAP-WAPINR,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

*-----------------------------------------------*
*  Method Issue : Issue Approvals
*-----------------------------------------------*
begin_method issue changing container.
*Data Declaration.
DATA: flag            TYPE wcagns-geniakt,
      custom_approval TYPE wcagns-geniakt,
      wapinr          TYPE wcewapinr,
      user_approve    TYPE wfsyst-initiator,
      approval        TYPE pmsog,
      lt_approve_tab  TYPE TABLE OF wcagns,
      lt_approve_std  TYPE TABLE OF wcagns,
      wa_approve_tab  TYPE  wcagns,
      wa_approve_std  TYPE wcagns,
      lv_objnr        TYPE j_objnr,
      lv_counter      TYPE i_count,
      lt_counters     TYPE TABLE OF i_count,

      lv_counters     TYPE i_count,
* Begin of <> 03022016
      app_cycle    TYPE zwcm_wcagns-app_cycle,
      lv_app_cycle TYPE zwcm_wcagns-app_cycle,              "22022016
      wcagns       TYPE zwcm_wcagns,
      lt_approve_tab1  TYPE TABLE OF zwcm_wcagns,
      wa_approve_tab1  TYPE zwcm_wcagns,
      wa_hierarchy    TYPE zwcm_hierarchy,
      it_hierarchy    TYPE table of zwcm_hierarchy,
      wa_hierarchy1   TYPE zwcm_hierarchy,
      wa_wcaapwa   TYPE wctp1_wcaapwa_type,
      l_processtyp type zwcm_config-PROCESSTYP,
      ZACTIVITY      type table of  ZWCM_ASACTIVITY,        "19022016
      wa_activity    type zwcm_asactivity,                  "19022016
      l_lineas  type i,                                     "19022016
      it_wcagns type table of wcagns,                       "23022016
      wa_wcagns type          wcagns,                       "23022016
"24022016
      l_genbdate type zwcm_wcagns-genbdate,
      l_genvtime type zwcm_wcagns-genvtime,
      l_genbtime type zwcm_wcagns-genbtime.
"24022016
* End of <> 03022016
TYPES: BEGIN OF lt_counters2,                               "04022016
        counters  TYPE  i_count,
        app_cycle  TYPE zwcm_wcagns-app_cycle,
      END OF lt_counters2.
data : lt_counters1       TYPE TABLE OF lt_counters2,
       wa_counters1       type lt_counters2.

*Getting APPROVE_TAB data in container element.
swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'USER_APPROVE' user_approve.
swc_get_element container 'APPROVAL' approval.
swc_get_table container   'ACTIVITIES' zactivity.             "19022016
"24022016
swc_get_element container 'GENBDATE' L_GENBDATE.
swc_get_element container 'GENVTIME' L_GENVTIME.
swc_get_element container 'GENBTIME' L_GENBTIME.
"24022016


IF wapinr IS NOT INITIAL.

* Get Object Number from WCM Application Data
  SELECT SINGLE objnr
       FROM wcaap
       INTO lv_objnr
       WHERE wapinr = wapinr.

* Check Application Exist or Not
  IF sy-subrc EQ 0.
* Get  Counter for differentiation from WCM Approvals
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*    SELECT SINGLE counter
*      FROM wcagn
*      INTO lv_counter
*      WHERE objnr EQ lv_objnr AND
*            pmsog EQ approval.
 SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
* Begin of <> on 23022016
** Get  Counters for differentiation from WCM Approval Segment
*    SELECT counters FROM wcagns
*           INTO TABLE lt_counters
*           WHERE objnr EQ lv_objnr AND
*                 counter EQ lv_counter.
*
** Sort Counters internal table in Descending to get highest counter value.
*    SORT lt_counters DESCENDING.
*    READ TABLE lt_counters INTO lv_counters INDEX 1.
*
** Create Work Area for Approval
*    IF lv_counters IS NOT INITIAL.
*      wa_approve_tab-counters =  lv_counters + 1.
*    ELSE.
*      wa_approve_tab-counters = 1.
*    ENDIF.
** Get  Counters for differentiation from WCM Approval Segment
    select * from wcagns into corresponding fields of table it_wcagns where objnr eq lv_objnr and counter eq lv_counter.
** Sort Counters internal table in Descending to get highest counter value.
    sort it_wcagns descending by counters.
    read table it_wcagns into wa_wcagns index 1.
    if wa_wcagns-counters is not initial.
      wa_approve_tab-counters = wa_wcagns-counters + 1.
    else.
      wa_approve_tab-counters = 1.
    endif.
* End of <> on 23022016
    wa_approve_tab-objnr    = lv_objnr.
    wa_approve_tab-counter  = lv_counter.
    wa_approve_tab-genname  = user_approve.
    wa_approve_tab-gendatum = sy-datum.
    wa_approve_tab-gentime  = sy-uzeit.

* Appending Work Area to Internal Table for DB Update.
    APPEND wa_approve_tab TO lt_approve_tab.
    CLEAR wa_approve_tab.

  ENDIF.
ENDIF.
"23022016
if wa_wcagns-counters > 1.
  if wa_wcagns-geniakt = 'X'.
* Issuing Approvals by Updating Table WCAGNS .
    CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
      EXPORTING
        i_instab = lt_approve_tab
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.
    COMMIT WORK AND WAIT.
  endif.
else.
"23022016
* Issuing Approvals by Updating Table WCAGNS .
  CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
    EXPORTING
      i_instab = lt_approve_tab
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  COMMIT WORK AND WAIT.
endif.

* When update is successful mark flagf as X.
IF sy-subrc EQ 0.
  clear : lv_counter, lv_counters.                                                          "08022016  23022016
* Updating ZWCM_WCANGS in case of Process type 'DC' 08022016
  CALL FUNCTION 'WCFA_READ_SINGLE'
    EXPORTING
      i_wapinr  = wapinr
    IMPORTING
      e_wcaapwa = wa_wcaapwa
    EXCEPTIONS
      error     = 1
      OTHERS    = 2.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*  select single processtyp into l_processtyp from zwcm_config where plant = wa_wcaapwa-iwerk.
 SELECT PROCESSTYP FROM ZWCM_CONFIG   UP TO 1 ROWS INTO L_PROCESSTYP
WHERE PLANT = WA_WCAAPWA-IWERK  ORDER BY  PLANT PLANT_SECTION APPROVAL
USAG .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
  if sy-subrc = 0 and l_processtyp = 'DC'.

* 08022016
* 04022016

* Get  Counter for differentiation from WCM Approvals
    IF wcagns-counter IS NOT INITIAL.
      lv_counter = wcagns-counter.
    ELSE.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*      SELECT SINGLE counter
*        FROM wcagn
*        INTO lv_counter
*        WHERE objnr EQ lv_objnr AND
*              pmsog EQ approval.
 SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
    ENDIF.

* Get  Counters for differentiation from WCM Approval Segment
    SELECT counters app_cycle FROM zwcm_wcagns
           INTO TABLE lt_counters1
           WHERE objnr EQ lv_objnr AND
                 counter EQ lv_counter.

* Sort Counters internal table in Descending to get highest counter value.
    SORT lt_counters1 DESCENDING .
    READ TABLE lt_counters1 INTO wa_counters1 INDEX 1.
* End of <> on 04022016
* Begin of <> on 22022016
    select max( app_cycle ) into lv_app_cycle from zwcm_wcagns where objnr = lv_objnr. "23022016

    if wa_counters1-APP_CYCLE <> lv_app_cycle or lv_app_cycle is initial. "23022016
* End of <> on 22022016
* Begin of <> on 03022016 by Sudhir Sharma

* Check Application Exist or Not
*      IF lv_app_cycle < 2. "is initial or wa_counters1-app_cycle = 1 .  "22022016  wa_counters1-app_cycle 23022016
      if lv_app_cycle is initial.
        wa_approve_tab1-app_cycle = 1 .
        lv_app_cycle              = 1.
      else.
        wa_approve_tab1-app_cycle = lv_app_cycle .
      endif.

* Get  Counter for differentiation from WCM Approvals
      SELECT SINGLE * FROM zwcm_hierarchy
       INTO wa_hierarchy
       WHERE iwerk = wa_wcaapwa-iwerk AND
             objart  = 'WA' AND
             pmsog = approval.

* Create Work Area for Approval
      IF wa_counters1-COUNTERS IS NOT INITIAL.    " 23022016 lv_counters
        wa_approve_tab1-counters =  wa_counters1-COUNTERS + 1.
      ELSE.
        wa_approve_tab1-counters = 1.
      ENDIF.
      wa_approve_tab1-objnr    = lv_objnr.
      wa_approve_tab1-counter  = lv_counter.
*      wa_approve_tab1-app_cycle  = lv_app_cycle.     "wa_counters1-app_cycle.
*    wa_approve_tab1-completion_flag  = wcagns-completion_flag.
      wa_approve_tab1-hilvl            = wa_hierarchy-hilvl.
      wa_approve_tab1-genname  = user_approve.
      wa_approve_tab1-gendatum = sy-datum.
      wa_approve_tab1-gentime  = sy-uzeit.
      wa_approve_tab1-genbdate = L_GENBDATE.  "24022016 sy-datum
      wa_approve_tab1-genvtime = l_genvtime. " 24022016 sy-uzeit. "'07:00'.   "sy-uzeit.  " Time values pass here
      wa_approve_tab1-genbtime = l_genbtime.  " 24022016sy-uzeit. "'18:00'.
      wa_approve_tab1-pmsog    = approval.
      wa_approve_tab1-gntxt    = wa_hierarchy-gntxt.
* Begin of <> on Deciding Permit Status 04022016
      SELECT  * FROM zwcm_hierarchy INTO table it_hierarchy
      WHERE iwerk = wa_wcaapwa-iwerk AND  objart  = 'WA' AND category = wa_hierarchy-category.
      if sy-subrc = 0.
* Sort Counters internal table in Descending to get highest counter value.
        SORT  it_hierarchy DESCENDING by hilvl.
        READ TABLE  it_hierarchy INTO  wa_hierarchy1 INDEX 1.
        if wa_hierarchy-hilvl = wa_hierarchy1-hilvl.
          wa_approve_tab1-permitstat    =  'F'.
        else.
          wa_approve_tab1-permitstat    = wa_hierarchy1-category.
        endif.
      endif.
* End of <> on 04022016
* Appending Work Area to Internal Table for DB Update.
      APPEND wa_approve_tab1 TO lt_approve_tab1.
*      ENDIF.
    endif.
* Issuing Approvals by Updating Table WCAGNS .
    if not  lt_approve_tab1 is initial.
      CALL FUNCTION 'ZWCFG_WCAGNS_UPDATE'
        EXPORTING
          i_instab = lt_approve_tab1
        EXCEPTIONS
          error    = 1
          OTHERS   = 2.
      clear : lv_counter , wa_counters1, l_genbdate, l_genvtime, l_genbtime.                    "23022016
    endif.
* Begin of <> on 19022016`
    delete zactivity where objnr <> lv_objnr.               "21022016
    delete ADJACENT DUPLICATES FROM zactivity COMPARING ALL FIELDS.
    sort zactivity ASCENDING by actcount.
    DESCRIBE TABLE zactivity lines l_lineas.
    if l_lineas > 0.
      loop at zactivity into wa_activity where objnr = lv_objnr .
        wa_activity-app_cycle = wa_approve_tab1-app_cycle.
        wa_activity-counter   = wa_approve_tab1-counter.
        wa_activity-counters  = wa_approve_tab1-counters.
        modify zwcm_asactivity from wa_activity.
      endloop.
    endif.
    clear : l_processtyp, wa_approve_tab1, lv_app_cycle.                  " 22022016

* End of <> on 19022016
    refresh : zactivity, lt_approve_tab,  lt_approve_tab1 .                                     " 21022016 22022016
    COMMIT WORK AND WAIT.

  endif.
* End of <> on 03022016
  flag = 'X'.
ENDIF.

*Setting Flag data in container element.
swc_set_element container 'FLAG' flag.
swc_set_element container 'CUSTOM_APPROVAL' custom_approval.
"24022016
swc_set_table container   'ACTIVITIES' zactivity.
swc_set_element container 'GENBDATE' L_GENBDATE.
swc_set_element container 'GENVTIME' L_GENVTIME.
swc_set_element container 'GENBTIME' L_GENBTIME.
"24022016

end_method.
*-----------------------------------------------*
*  End of Method Issue : Issue Approvals
*-----------------------------------------------*

*-----------------------------------------------*
*  Method Revoke : Revoke Approvals
*-----------------------------------------------*
begin_method revoke changing container.

*Data Declaration.
DATA:
      flag TYPE wcagns-geniakt,
      wapinr          TYPE wcewapinr,
      approval        TYPE pmsog,
      lt_approve_tab  TYPE TABLE OF wcagns,
      wa_approve_tab  TYPE wcagns,
      previous_approver TYPE wfsyst-initiator,
      lv_objnr        TYPE j_objnr,
      lv_counter      TYPE i_count,
      lt_counters     TYPE TABLE OF i_count,
      lv_counters     TYPE i_count,
      lt_revoke_tab   TYPE wctp1_wcagnstab_type,
      lt_permit       TYPE wctpc_permittab_type,
      r_email_id      TYPE pa0105-usrid_long,
      previous_approval TYPE wcagn-pmsog,
      permit_txt      TYPE wcspermit-gntxt,
      wa_permit       TYPE wctpc_permitwa_type,
      lv_index  TYPE i,
*        lv_permit TYPE pmsog,
        lv_previous_permit TYPE pmsog,
      wa_revoke       TYPE wctp1_wcagnswa_type.
TYPES: BEGIN OF lty_user,
     user TYPE sysid,
    END OF lty_user,
BEGIN OF ty_email_data,
  pernr TYPE persno,
  usrid	TYPE sysid,
  usrid_long  TYPE comm_id_long,
END OF ty_email_data.
DATA: "{lt_emp_id TYPE TABLE OF ty_email_data,
      wa_emp_id TYPE ty_email_data,
      lt_user TYPE TABLE OF lty_user,
      lv_user TYPE lty_user.


CONSTANTS: lc_check TYPE char1 VALUE 'X'.
*Getting REVOKE TAB data in container element.
swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'APPROVAL' approval.

IF wapinr IS NOT INITIAL.
  CALL FUNCTION 'ZWCA_GET_APPROVALS'
    EXPORTING
      wapinr   = wapinr
    IMPORTING
      t_permit = lt_permit.
  LOOP AT lt_permit INTO wa_permit.
    IF wa_permit-pmsog = approval.
      lv_index = sy-tabix - 1.
      EXIT.
    ENDIF.
  ENDLOOP.
  READ TABLE lt_permit INTO wa_permit INDEX lv_index.
  IF sy-subrc EQ 0.

    lv_previous_permit = wa_permit-pmsog.
    permit_txt   = wa_permit-gntxt.
  ENDIF.
* Get Object Number from WCM Application Data
  SELECT SINGLE objnr
       FROM wcaap
       INTO lv_objnr
       WHERE wapinr = wapinr.

* Check Application Exist or Not
  IF sy-subrc EQ 0.

* Get  Counter for differentiation from WCM Approvals
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*    SELECT SINGLE counter
*      FROM wcagn
*      INTO lv_counter
*      WHERE objnr EQ lv_objnr AND
*            pmsog EQ lv_previous_permit.
 SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
EQ LV_OBJNR AND PMSOG EQ LV_PREVIOUS_PERMIT  ORDER BY  OBJNR COUNTER .
 ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC

* Get  Counters for differentiation from WCM Approval Segment
    SELECT * FROM wcagns
           INTO TABLE lt_revoke_tab
           WHERE objnr EQ lv_objnr AND
                 counter EQ lv_counter.

* Sort Counters internal table in Descending to get highest counter value.
    SORT lt_revoke_tab BY counters DESCENDING .
    READ TABLE lt_revoke_tab INTO wa_revoke INDEX 1.

    CLEAR lt_revoke_tab.
* Create Work Area for Approval
    wa_revoke-geniname = sy-uname.
    wa_revoke-genidate = sy-datum.
    wa_revoke-genitime = sy-uzeit.
    wa_revoke-geniakt  = lc_check.

* Appending Work Area to Internal Table for DB Update.
    APPEND wa_revoke TO lt_revoke_tab.
*    CLEAR wa_revoke.

  ENDIF.
ENDIF.

* Revoking Approval by Updating Table WCAGNS and marking flag GENIAKT as X.
CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
  EXPORTING
    i_updtab = lt_revoke_tab
  EXCEPTIONS
    error    = 1
    OTHERS   = 2.
* When update is successful mark flagf as X.
IF sy-subrc EQ 0.
  flag = 'X'.

  CONCATENATE 'US' wa_revoke-genname INTO previous_approver.
ENDIF.

previous_approval = lv_previous_permit.

** Start of Email Logic**
*LOOP AT gt_users INTO gw_users.
lv_user = wa_revoke-genname.
*  APPEND wa_user TO lt_user.
*ENDLOOP.
*gt_users-approver
*IF gt_users IS NOT INITIAL.

" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*SELECT SINGLE pernr usrid usrid_long FROM pa0105
*  INTO wa_emp_id
**    FOR ALL ENTRIES IN lt_user
*  WHERE usrid = lv_user AND
*        usrty = '0001'.
 SELECT PERNR USRID USRID_LONG FROM PA0105   UP TO 1 ROWS INTO
WA_EMP_ID WHERE USRID = LV_USER AND USRTY = '0001'  ORDER BY  PERNR
SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC

IF sy-subrc EQ 0.
  SELECT SINGLE usrid_long FROM pa0105
   INTO r_email_id
   WHERE pernr = wa_emp_id-pernr AND
         usrty = '0010'.
ENDIF.

*ENDIF.
** End of Email Logic**

*Setting Flag data in container element.
swc_set_element container 'FLAG' flag.
swc_set_element container 'PREVIOUS_APPROVER' previous_approver.
swc_set_element container 'R_EMAIL_ID' r_email_id.
swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
swc_set_element container 'PERMIT_TXT' permit_txt.

end_method.
*-----------------------------------------------*
*  End of Method Revoke : Revoke Approvals
*-----------------------------------------------*

*-----------------------------------------------*
*  Method generate_spool : Generate Spool
*-----------------------------------------------*
begin_method generate_spool changing container.
DATA:
* Interface Parameters
      wapinr       TYPE wcaap-wapinr,
      spool_req    TYPE tsp01-rqident,

*Local Internal Table
      lt_wcvltab   TYPE wctp1_wcvltab_type,
      lt_permit    TYPE wctpc_permittab_type,
      lt_wcagnstab_cop TYPE wctp1_wcagnstab_type,
      lt_wcagnstab TYPE   wctp1_wcagnstab_type  ,
      lt_wccp      TYPE TABLE OF wccp,
* Local Work Area
      wa_wcaapwa   TYPE wctp1_wcaapwa_type,
      wa_wcsccobj  TYPE wcsccobj,
      wa_wcswapi   TYPE wcswapi,
      wa_wcsheader TYPE wcsheader,
      wa_wcsadm    TYPE wcsadm,
      wa_wcsloc    TYPE wcsloc,
      wa_wcsresp   TYPE wcsresp,
      wa_wcsplan   TYPE wcsplan,
      wa_wcsprint  TYPE wcsprint,
      wa_sapscript TYPE wctpd_sapscript_type,
      wa_wcvlwa    TYPE wctp1_wcvlwa_type,
      wa_gnwa     TYPE wctp1_gnwa_type,
      wa_permit    TYPE wctpc_permitwa_type,
      wa_wccp_permit    TYPE wctpc_permitwa_type,
      wa_wcagnstab TYPE wctp1_wcagnswa_type,
      wa_wccp      TYPE wccp,
* Local Variables
      lv_objnr        TYPE j_objnr,
      lv_cnt       TYPE i,
      lv_form      TYPE wctpd_form_type,
      lv_tabix     TYPE i,
      lv_str       TYPE string.
* Field Sysmbol
FIELD-SYMBOLS: <fs_spool_id> TYPE itcpp.
swc_get_element container 'WAPINR' wapinr.


CALL FUNCTION 'WCFA_READ_SINGLE'
  EXPORTING
    i_wapinr  = wapinr
  IMPORTING
    e_wcaapwa = wa_wcaapwa
  EXCEPTIONS
    error     = 1
    OTHERS    = 2.
IF sy-subrc EQ 0.
  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcswapi.              "#EC ENHOK
  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsadm.               "#EC ENHOK
  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsheader.            "#EC ENHOK
  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsccobj.             "#EC ENHOK
  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsplan.

  CALL FUNCTION 'WCFC_WCVLTAB_GET'
    EXPORTING
      i_iwerk   = wa_wcaapwa-iwerk
      i_prttyp  = '1'
    IMPORTING
      e_wcvltab = lt_wcvltab
    EXCEPTIONS
      error     = 1
      OTHERS    = 2.
  IF sy-subrc EQ 0.
    READ TABLE lt_wcvltab INTO wa_wcvlwa WITH KEY
      prtformat = wctpd_prtformat-wapi.
    lv_form      = wctpd_form-wapi_header.
  ENDIF.
ENDIF.

CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wapinr
  IMPORTING
    t_permit = lt_permit.

wa_wcsprint-iwerk = '10P2'.
wa_wcsprint-prttyp = '1'.
wa_wcsprint-prtformat = 'WAPI'.
wa_wcsprint-repid     = 'WCMPRTA4'.
wa_wcsprint-form      = 'WCM_WAPI_A4'.
wa_wcsprint-tddest    = 'LOCL'.
wa_wcsprint-tdcopies  = 0.
wa_wcsprint-tddelete  = 'X'.
wa_wcsprint-tdnewid   = 'X'.
wa_wcsprint-tdlifetime = 0.
wa_wcsprint-prttl  = 0.
wa_wcsprint-stxt = 'Header data'.
* End of get permit

CALL FUNCTION 'WCFW_CCOBJ_INFO'
  EXPORTING
    i_authflg  = wctp1_unmarked
    i_aktyp    = 'V'             " need to check "inf-aktype
    i_iwerk    = wa_wcaapwa-iwerk
    i_tplnr    = wa_wcsccobj-tplnr
    i_equnr    = wa_wcsccobj-equnr
    i_lnkflg   = wa_wcsccobj-lnkflg
    i_train    = wa_wcsccobj-train
  IMPORTING
    e_wcsccobj = wa_wcsccobj
    e_wcsloc   = wa_wcsloc
  EXCEPTIONS
    error      = 1
    OTHERS     = 2.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION 'WCFW_WCSRESP_SET'
  EXPORTING
    i_iwerk   = wa_wcaapwa-iwerk
    i_ingrp   = wa_wcaapwa-ingrp
    i_wkcrtyp = wa_wcaapwa-wkcrtyp
    i_wkcrid  = wa_wcaapwa-wkcrid
    i_begru   = wa_wcaapwa-begru
  IMPORTING
    e_wcsresp = wa_wcsresp
  EXCEPTIONS
    error     = 1
    OTHERS    = 2.
*wa_wcsloc-swerk = '10P2'.

wa_wcsresp-ingrp = '112'.

wa_sapscript-open_form = 0.
wa_sapscript-write_form = 0.
wa_sapscript-close_form = 0.

EXPORT
 wcsprint FROM wa_wcsprint
TO MEMORY ID wctpc_memory_id-prtformat.

EXPORT
found     FROM wctp1_true
sapscript FROM wa_sapscript
TO MEMORY ID 'PRINT'.
EXPORT
  wcswapi   FROM wa_wcswapi
  wcsheader FROM wa_wcsheader
  wcsadm    FROM wa_wcsadm
  wcsccobj  FROM wa_wcsccobj
  wcsloc    FROM wa_wcsloc
  wcsresp   FROM wa_wcsresp
  wcsplan   FROM wa_wcsplan
  TO MEMORY ID 'PRT2'.
EXPORT permittab FROM lt_permit TO MEMORY ID wctpc_memory_id-prt_approval.
*  * call subroutine in print program
PERFORM (lv_form) IN PROGRAM (wa_wcvlwa-repid) IF FOUND.
lv_str = '(SAPLSTXC)ITCPP'.

ASSIGN (lv_str) TO <fs_spool_id>.
spool_req = <fs_spool_id>-tdspoolid.
swc_set_element container 'SPOOL_REQ' spool_req.
end_method.
*-----------------------------------------------*
* End Method generate_spool : Generate Spool
*-----------------------------------------------*

begin_method get_current_users changing container.
DATA:
      wapinr TYPE wcaap-wapinr,
      approval TYPE wcagn-pmsog,
      next_approval TYPE wcagn-pmsog,
      bname TYPE wfsyst-initiator OCCURS 0,
      wa_bname TYPE wfsyst-initiator,

   wa_wcaapwa   TYPE wctp1_wcaapwa_type,
   lv_permit TYPE pmsog,
        wa_wcsccobj  TYPE wcsccobj,
        wa_wcsloc    TYPE wcsloc,
        wapi_desc    TYPE wcaap-stxt,
permit_txt TYPE wcspermit-gntxt,
        lt_custom TYPE TABLE OF zwcm_custom,
        wa_custom TYPE zwcm_custom,
      lt_permit TYPE wctpc_permittab_type,
      approver_number TYPE wcagns-counter,
      lv_index  TYPE i,
      wa_permit TYPE wctpc_permitwa_type.

CONSTANTS lc_wca TYPE string VALUE 'WCA'.
swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'APPROVAL' approval.

CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wapinr
  IMPORTING
    t_permit = lt_permit.
IF approval IS NOT INITIAL.
  READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = approval.
  lv_permit = wa_permit-pmsog.
  CLEAR wa_permit.
ELSE.
  READ TABLE lt_permit INTO wa_permit INDEX 1.
  lv_permit = wa_permit-pmsog.
  CLEAR wa_permit.
ENDIF.
approval = lv_permit.
CALL FUNCTION 'WCFA_READ_SINGLE'
  EXPORTING
    i_wapinr  = wapinr
  IMPORTING
    e_wcaapwa = wa_wcaapwa
  EXCEPTIONS
    error     = 1
    OTHERS    = 2.


IF sy-subrc EQ 0.
  wapi_desc = wa_wcaapwa-stxt.

  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsccobj.             "#EC ENHOK
  CALL FUNCTION 'WCFW_CCOBJ_INFO'
    EXPORTING
      i_authflg  = wctp1_unmarked
      i_aktyp    = 'V'             " need to check "inf-aktype
      i_iwerk    = wa_wcaapwa-iwerk
      i_tplnr    = wa_wcsccobj-tplnr
      i_equnr    = wa_wcsccobj-equnr
      i_lnkflg   = wa_wcsccobj-lnkflg
      i_train    = wa_wcsccobj-train
    IMPORTING
      e_wcsccobj = wa_wcsccobj
      e_wcsloc   = wa_wcsloc
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  SELECT * FROM zwcm_custom
      INTO TABLE lt_custom
      WHERE doc_type = lc_wca AND
            plant    = wa_wcaapwa-iwerk AND
            plant_section = wa_wcsloc-beber AND
            approval = lv_permit AND
            usag     = wa_wcaapwa-wapiuse AND " +for usage
            from_date LE sy-datum AND
            to_date GE sy-datum .
  IF sy-subrc NE 0.
    SELECT * FROM zwcm_custom
    INTO TABLE lt_custom
    WHERE doc_type = lc_wca AND
          plant    = wa_wcaapwa-iwerk AND
          plant_section = '000'  AND
          approval = lv_permit AND
          usag     = wa_wcaapwa-wapiuse AND " +for usage
          from_date LE sy-datum AND
          to_date GE sy-datum .
  ENDIF.

  LOOP AT lt_custom INTO wa_custom.
    MOVE wa_custom-approver TO wa_bname.
    CONCATENATE 'US' wa_bname INTO wa_bname.
    APPEND wa_bname TO bname.
  ENDLOOP.
ENDIF.
LOOP AT lt_permit INTO wa_permit.
  IF lv_index IS NOT INITIAL AND
     lv_index EQ sy-tabix.

    next_approval = wa_permit-pmsog.

  ENDIF.
  IF lv_permit = wa_permit-pmsog.
    lv_index = sy-tabix + 1.
  ENDIF.
ENDLOOP.
READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = approval.
IF sy-subrc EQ 0.

  permit_txt = wa_permit-gntxt.
ENDIF.
DESCRIBE TABLE bname LINES approver_number.
swc_set_table container 'BNAME' bname.
swc_set_element container 'APPROVER_NUMBER' approver_number.
swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_element container 'APPROVAL' approval.
swc_set_element container 'PERMIT_TXT' permit_txt.
swc_set_element container 'WAPI_DESC' wapi_desc.

end_method.

begin_method call_form changing container.
DATA:
* Method Interface
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      wapinr        TYPE wcaap-wapinr,
      approval      TYPE wcagn-pmsog,
      spool_req     TYPE tsp01-rqident,
      next_approval TYPE wcagn-pmsog,
      previous_approval TYPE wcagn-pmsog,
      revoke_text   TYPE rdgprint-stadd1 OCCURS 0,
      user_sel      TYPE wfsyst-initiator OCCURS 0,
      t_email_id    TYPE pa0105-usrid_long OCCURS 0,
      user_approve  TYPE wfsyst-initiator,
      appr_number   TYPE wcagns-counter,
      appr_status   TYPE wcagns-geniakt,
      auto_pause   TYPE wcagns-geniakt,
      flag_loop     TYPE zwcm_custom-beg_loop_flag,
      wcd_docnum    TYPE zwcm_hierarchy-hilvl,
      completion_auth TYPE zwcm_hierarchy-completion_auth,
      renewal_auth TYPE zwcm_hierarchy-renewal_auth ,
      single_flag     TYPE zwcm_hierarchy-single_flag,
      work_itemid TYPE swwwihead-wi_id,
      sms_uname  TYPE suid_st_bname-bname,
      sms_number TYPE threic_contact-mobile,  "#EC CI_USAGE_OK[3224334]
      permit_txt TYPE wcspermit-gntxt,
      wapi_desc    TYPE wcaap-stxt,
* Local Internal Table
      lt_text           TYPE lvc_t_htline,
* Local Work Area
      wa_user_approve   TYPE wfsyst-initiator OCCURS 0,
      wa_user_sel       TYPE swp_initia OCCURS 0,
      wa_appr_status    TYPE  geniakt,
      wa_next_approval  TYPE  pmsog,
      wa_user           TYPE wfsyst-initiator,
* Local  Variables
      lt_permit       TYPE wctpc_permittab_type,
      lt_wcahe        TYPE TABLE OF wcahe,
      wa_wcahe        TYPE wcahe,
      lt_wcd          TYPE wctpc_wcmflgtab_type,
      wa_permit       TYPE wctpc_permitwa_type,
      lv_plant        TYPE iwerk,
      lv_user         TYPE sy-uname,
      lv_wcaap        TYPE wcaap,
      lx_flag         TYPE wcsstatflg,
      zactivity1 type table of zwcm_asactivity,             " 19022016
"24022016
      l_genbdate type zwcm_wcagns-genbdate,
      l_genvtime type zwcm_wcagns-genvtime,
      l_genbtime type zwcm_wcagns-genbtime.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
"24022016

swc_get_element container 'WAPINR'    wapinr.
swc_get_element container 'APPROVAL'  approval.
swc_get_element container 'SPOOL_REQ' spool_req.
swc_get_element container 'SMS_NUMBER' sms_number.
swc_get_element container 'WORK_ITEMID' work_itemid.
swc_get_element container 'SMS_UNAME' sms_uname.
swc_get_element container 'PERMIT_TXT' permit_txt.
swc_get_element container 'WAPI_DESC' wapi_desc.
swc_get_table container 'ACTIVITIES' zactivity1.            "19022016

* Calling Form
CALL FUNCTION 'ZWCM_FORM'
  EXPORTING
    im_spool           = spool_req
    im_permit          = approval
    im_appl            = wapinr
    im_work_itemid     = work_itemid
  IMPORTING
    ex_appr_status     = appr_status
    ex_user_aprove     = user_approve
    et_user            = user_sel
    ex_next_permit     = next_approval
    et_text            = lt_text
    et_email_id        = t_email_id
    ex_flag_loop       = flag_loop
    ex_wcd_docnum      = wcd_docnum
    ex_completion_auth = completion_auth
    ex_renewal_auth    = renewal_auth
    ex_single_flag     = single_flag
    ex_prev_permit     = previous_approval
    ex_auto_pause      = auto_pause
*   ex_sms_uname       = sms_uname
    EX_GENBDATE        = l_genbdate
    EX_GENVTIME        = l_genvtime
    EX_GENBTIME        = l_genbtime
   TABLEs
    ex_activity        = ZACTIVITY1
  CHANGING
    ch_sms_uname       = sms_uname
    ch_sms_number      = sms_number.


* Getting Revoke Text.
revoke_text = lt_text.

* Concatenating user name with US.
LOOP AT user_sel INTO wa_user.
  CONCATENATE 'US' wa_user INTO wa_user.
  MODIFY user_sel FROM wa_user INDEX sy-tabix.
ENDLOOP.

DESCRIBE TABLE user_sel LINES appr_number.

CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wapinr
  IMPORTING
    t_permit = lt_permit.

SELECT SINGLE * FROM wcaap
  INTO lv_wcaap
  WHERE wapinr = wapinr.

READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
IF sy-subrc EQ 0.
  permit_txt = wa_permit-gntxt.
  IF permit_txt IS INITIAL.

    SELECT SINGLE gntxt INTO permit_txt
      FROM zwcm_hierarchy
      WHERE iwerk = lv_wcaap-iwerk AND
            pmsog EQ approval AND
            objart EQ 'WA'.

*    permit_txt = 'Approval by Area Incharge'.

  ENDIF.
ENDIF.

IF  ( appr_number IS INITIAL OR
   appr_number EQ '000000' ) AND
    appr_status NE 'B' AND
    appr_status NE 'R'.

  lx_flag-clsd = 'X'.
  CALL FUNCTION 'WCFS_CLOSED'
    EXPORTING
      i_iwerk      = lv_wcaap-iwerk
      i_objart     = 'WA'
      i_objnr      = lv_wcaap-objnr
      i_wcsstatflg = lx_flag
      i_cp         = wctp1_exception-pass_over
    EXCEPTIONS
      error        = 1
      OTHERS       = 2.


  IF sy-subrc EQ 0.
    CALL FUNCTION 'WCFX_WCMFLGTAB_GET'
      EXPORTING
        i_objnr     = lv_wcaap-objnr
        i_direction = 'DN'
      IMPORTING
        e_wcmflgtab = lt_wcd
*       E_SIZE      =
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.
*      CLEAR lt_wca.
    IF lt_wcd IS NOT INITIAL.
      SELECT * FROM wcahe
        INTO TABLE lt_wcahe
        FOR ALL ENTRIES IN lt_wcd
        WHERE objnr = lt_wcd-objnr.
    ENDIF.
    LOOP AT lt_wcahe INTO wa_wcahe.
      CALL FUNCTION 'WCFS_CLOSED'
        EXPORTING
          i_iwerk      = lv_wcaap-iwerk
          i_objart     = 'WD'
          i_objnr      = wa_wcahe-objnr
          i_wcsstatflg = lx_flag
          i_cp         = wctp1_exception-pass_over
        EXCEPTIONS
          error        = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDLOOP.
  ENDIF.
ENDIF.
"19022016
swc_set_table container 'ACTIVITIES' zactivity1.
"24022016
swc_set_element container 'GENBDATE' L_GENBDATE.
swc_set_element container 'GENVTIME' L_GENVTIME.
swc_set_element container 'GENBTIME' L_GENBTIME.
"24022016
swc_set_element container 'APPR_STATUS'   appr_status.
swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
swc_set_element container 'USER_APPROVE'  user_approve.
swc_set_element container 'APPR_NUMBER'   appr_number.
*swc_set_element container 'APPR_NUMBER'   appr_number.   "commented on 12022016
swc_set_element container 'REVOKE_TEXT'   revoke_text.
swc_set_element container 'FLAG_LOOP'     flag_loop.
swc_set_element container 'WCD_DOCNUM'    wcd_docnum.
swc_set_element container 'SMS_UNAME'    sms_uname.
swc_set_element container 'AUTO_PAUSE'    auto_pause.
swc_set_element container 'SMS_NUMBER'    sms_number.
swc_set_element container 'RENEWAL_AUTH'    renewal_auth.
swc_set_element container 'COMPLETION_AUTH'    completion_auth.
swc_set_element container 'SINGLE_FLAG'    single_flag.
swc_set_table   container 'T_EMAIL_ID'    t_email_id.
swc_set_table   container 'USER_SEL'      user_sel.
swc_set_element container 'PERMIT_TXT' permit_txt.
end_method.

begin_method call_loop_form changing container.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
DATA:
      wapinr          TYPE wcaap-wapinr,
      approval        TYPE wcagn-pmsog,
      user_sel        TYPE wfsyst-initiator OCCURS 0,
      appr_status     TYPE wcagns-geniakt,
      appr_number     TYPE wcagns-counter,
      next_approval   TYPE wcagn-pmsog,
      previous_approval   TYPE wcagn-pmsog,
      ext_appr        TYPE zwcm_hierarchy-ext_appr,
      revoke_text     TYPE rdgprint-stadd1 OCCURS 0,
      wcd_docnum      TYPE zwcm_hierarchy-hilvl,
      user_approve    TYPE wfsyst-initiator,
      app_cycle       TYPE zwcm_wcagns-app_cycle,
      completion_auth TYPE zwcm_hierarchy-completion_auth,
      renewal_auth    TYPE zwcm_hierarchy-renewal_auth ,
      sms_uname       TYPE suid_st_bname-bname,
      single_flag     TYPE zwcm_hierarchy-single_flag,
      wcagns          TYPE zwcm_wcagns,
      sms_number      TYPE threic_contact-mobile,  "#EC CI_USAGE_OK[3224334]
      work_itemid     TYPE swwwihead-wi_id,
      permit_txt      TYPE wcspermit-gntxt,
      stop_auth       TYPE zwcm_hierarchy-stop_auth,
      wapi_desc       TYPE wcaap-stxt,
      t_email_id      TYPE pa0105-usrid_long OCCURS 0,
      lt_text         TYPE lvc_t_htline,
      wa_user         TYPE wfsyst-initiator,
      lt_permit       TYPE wctpc_permittab_type,
      lv_plant        TYPE iwerk,
      wa_permit       TYPE wctpc_permitwa_type,
      zactivity1 type table of zwcm_asactivity.             " 20022016
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---


swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'APPROVAL' approval.
swc_get_element container 'APP_CYCLE' app_cycle.
swc_get_element container 'COMPLETION_AUTH' completion_auth.
swc_get_element container 'RENEWAL_AUTH' renewal_auth.
swc_get_element container 'PREVIOUS_APPROVAL' previous_approval.
swc_get_element container 'WORK_ITEMID' work_itemid.
swc_get_element container 'SMS_UNAME' sms_uname.
swc_get_element container 'SMS_NUMBER' sms_number.
swc_get_element container 'WAPI_DESC' wapi_desc.
swc_get_element container 'STOP_AUTH' stop_auth.
swc_get_element container 'EXT_APPR' ext_appr.
swc_get_table container 'ACTIVITIES' zactivity1.            "20022016


CALL FUNCTION 'ZWCM_LOOP_FORM'
  EXPORTING
    im_permit          = approval
    im_appl            = wapinr
    im_app_cycle       = app_cycle
    im_prev_permit     = previous_approval
    im_work_itemid     = work_itemid
    im_ext_appr        = ext_appr
  IMPORTING
    ex_appr_status     = appr_status
    ex_user_aprove     = user_approve
    et_user            = user_sel
    ex_next_permit     = next_approval
    et_text            = lt_text
    et_email_id        = t_email_id
    ex_single_flag     = single_flag
    ex_wcd_docnum      = wcd_docnum
    ex_wcagns          = wcagns
  TABLES
    ex_activity        = ZACTIVITY1
  CHANGING
    ch_completion_auth = completion_auth
    ch_renewal_auth    = renewal_auth
    ch_sms_uname       = sms_uname
    ch_sms_number      = sms_number
    ch_stop_auth       = stop_auth.

* Getting Revke Text.
revoke_text = lt_text.

* Concatenating user name with US.
LOOP AT user_sel INTO wa_user.
  CONCATENATE 'US' wa_user INTO wa_user.
  MODIFY user_sel FROM wa_user INDEX sy-tabix.
ENDLOOP.

DESCRIBE TABLE user_sel LINES appr_number.

CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wapinr
  IMPORTING
    t_permit = lt_permit.

READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
IF sy-subrc EQ 0.
  permit_txt = wa_permit-gntxt.

ENDIF.
IF permit_txt IS INITIAL AND appr_number IS NOT INITIAL.

  SELECT SINGLE iwerk FROM wcaap
    INTO lv_plant
    WHERE wapinr = wapinr.

  SELECT SINGLE gntxt INTO permit_txt
    FROM zwcm_hierarchy
    WHERE iwerk = lv_plant AND
          pmsog EQ next_approval AND
          objart EQ 'WA'.
*  permit_txt = 'Approval by Area Incharge'.

ENDIF.

swc_set_table container 'ACTIVITIES' zactivity1.            "20022016

swc_set_table container 'USER_SEL' user_sel.
swc_set_element container 'APPR_STATUS' appr_status.
swc_set_element container 'APPR_NUMBER' appr_number.
swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_table container 'REVOKE_TEXT' revoke_text.
swc_set_element container 'USER_APPROVE' user_approve.
swc_set_element container 'COMPLETION_AUTH' completion_auth.
swc_set_element container 'RENEWAL_AUTH' renewal_auth.
swc_set_element container 'SINGLE_FLAG' single_flag.
swc_set_element container 'WCAGNS' wcagns.
swc_set_table container 'T_EMAIL_ID' t_email_id.
swc_set_element container 'SMS_UNAME'    sms_uname.
swc_set_element container 'WCD_DOCNUM'    wcd_docnum.
swc_set_element container 'PERMIT_TXT'    permit_txt.
swc_set_element container 'SMS_NUMBER'    sms_number.
swc_set_element container 'STOP_AUTH'    stop_auth.
end_method.

begin_method get_current_loop_users changing container.
DATA:
* Interface Parameters
      wapinr          TYPE wcaap-wapinr,
      next_approval   TYPE wcagn-pmsog,
      approval        TYPE wcagn-pmsog,
      bname           TYPE wfsyst-initiator OCCURS 0,
      approver_number TYPE wcagns-counter,
      completion_auth TYPE zwcm_hierarchy-completion_auth,
      renewal_auth TYPE zwcm_hierarchy-renewal_auth,
* Local Internal Tables
      lt_hierarchy    TYPE TABLE OF zwcm_hierarchy,
      lt_custom       TYPE TABLE OF zwcm_custom,
* Local work Area
      wa_wcaapwa      TYPE wctp1_wcaapwa_type,
      wa_wcsccobj     TYPE wcsccobj,
      wa_wcsloc       TYPE wcsloc,
      wa_custom       TYPE zwcm_custom,
      wa_bname        TYPE wfsyst-initiator,
      wa_hierarchy    TYPE zwcm_hierarchy,
* local Variales
      lv_index        TYPE int4,
      lv_permit       TYPE pmsog.
CONSTANTS lc_wca      TYPE string VALUE 'WCA'.

swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'APPROVAL' approval.

* Read Header Data
CALL FUNCTION 'WCFA_READ_SINGLE'
  EXPORTING
    i_wapinr  = wapinr
  IMPORTING
    e_wcaapwa = wa_wcaapwa
  EXCEPTIONS
    error     = 1
    OTHERS    = 2.


IF sy-subrc EQ 0.
  MOVE-CORRESPONDING wa_wcaapwa TO wa_wcsccobj.             "#EC ENHOK

* Read Location data
  CALL FUNCTION 'WCFW_CCOBJ_INFO'
    EXPORTING
      i_authflg  = wctp1_unmarked
      i_aktyp    = 'V'             " need to check "inf-aktype
      i_iwerk    = wa_wcaapwa-iwerk
      i_tplnr    = wa_wcsccobj-tplnr
      i_equnr    = wa_wcsccobj-equnr
      i_lnkflg   = wa_wcsccobj-lnkflg
      i_train    = wa_wcsccobj-train
    IMPORTING
      e_wcsccobj = wa_wcsccobj
      e_wcsloc   = wa_wcsloc
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

* Read hierarchy for custom loop
  SELECT * FROM zwcm_hierarchy
    INTO TABLE lt_hierarchy
    WHERE iwerk = wa_wcaapwa-iwerk AND
          objart = 'WA'.

  IF sy-subrc EQ 0.
    SORT lt_hierarchy BY hilvl.

* If approval is initial, intialize it with first permit.
    IF approval IS NOT INITIAL.
      READ TABLE lt_hierarchy INTO wa_hierarchy WITH KEY pmsog = approval.
      lv_permit = wa_hierarchy-pmsog.
    ELSE.
      READ TABLE lt_hierarchy INTO wa_hierarchy INDEX 1.
      lv_permit = wa_hierarchy-pmsog.
    ENDIF.

    approval = lv_permit.
* Getting check for completion authority
    completion_auth =  wa_hierarchy-completion_auth.
* Getting check for completion authority
    renewal_auth =  wa_hierarchy-renewal_auth.

* If Distribution List is initial, get the user list from custom table
    IF wa_hierarchy-dist_list IS INITIAL.
      SELECT * FROM zwcm_custom
       INTO TABLE lt_custom
       WHERE doc_type = lc_wca AND
             plant    = wa_wcaapwa-iwerk AND
             plant_section = wa_wcsloc-beber AND
             approval = lv_permit AND
             usag     = wa_wcaapwa-wapiuse AND " +for usage
            from_date LE sy-datum AND
            to_date GE sy-datum .
      IF sy-subrc NE 0.
        SELECT * FROM zwcm_custom
          INTO TABLE lt_custom
          WHERE doc_type = lc_wca AND
                 plant    = wa_wcaapwa-iwerk AND
                 plant_section = '000' AND
                 approval = lv_permit AND
                 usag     = wa_wcaapwa-wapiuse AND " +for usage
                from_date LE sy-datum AND
                to_date GE sy-datum .
      ENDIF.
      LOOP AT lt_custom INTO wa_custom.
        MOVE wa_custom-approver TO wa_bname.
        CONCATENATE 'US' wa_bname INTO wa_bname.
        APPEND wa_bname TO bname.
      ENDLOOP.
    ELSE.
*   Need to add logic to read users from distribution list.

    ENDIF.
  ENDIF.
ENDIF.

* Get Next Approval Level
LOOP AT lt_hierarchy INTO wa_hierarchy.
  IF lv_index IS NOT INITIAL AND
     lv_index EQ sy-tabix.

    next_approval = wa_hierarchy-pmsog.

  ENDIF.

  IF lv_permit = wa_hierarchy-pmsog.
    lv_index = sy-tabix + 1.
  ENDIF.
ENDLOOP.

DESCRIBE TABLE bname LINES approver_number.

swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_element container 'APPROVAL' approval.
swc_set_table container 'BNAME' bname.
swc_set_element container 'APPROVER_NUMBER' approver_number.
swc_set_element container 'COMPLETION_AUTH' completion_auth.
swc_set_element container 'RENEWAL_AUTH' renewal_auth.
end_method.

begin_method custom_issue changing container.
DATA:
      approval TYPE wcagn-pmsog,
      wapinr TYPE wcaap-wapinr,
      flag TYPE wcagns-geniakt,
      app_cycle  TYPE zwcm_wcagns-app_cycle,
      user_approve TYPE wfsyst-initiator,
      wcagns      TYPE zwcm_wcagns,
*      completion_auth TYPE zwcm_hierarchy-completion_auth,
      lt_approve_tab  TYPE TABLE OF zwcm_wcagns,
      lt_approve_std  TYPE TABLE OF wcagns,
      wa_approve_tab  TYPE zwcm_wcagns,
      wa_approve_std  TYPE wcagns,
      wa_hierarchy   TYPE zwcm_hierarchy,
      wa_wcaapwa   TYPE wctp1_wcaapwa_type,
      lv_objnr        TYPE j_objnr,
      lv_counter      TYPE i_count,
      lt_counters     TYPE TABLE OF i_count,
      lv_counters     TYPE i_count,
      lt_approve_tab1  TYPE TABLE OF zwcm_wcagns,           "11022016
      wa_approve_tab1  TYPE zwcm_wcagns,                    "11022016
      it_hierarchy    TYPE table of zwcm_hierarchy,         "11022016
      wa_hierarchy1   TYPE zwcm_hierarchy,                  "11022016
      l_processtyp    type zwcm_config-PROCESSTYP,          "11022016
      it_hierarchy1   TYPE table of zwcm_hierarchy,         "15022016
      first_permit           TYPE wcagn-pmsog,              "15022016
      zactivity       type table of zwcm_asactivity,        "18022016
      it_activity    type table of zwcm_asactivity,         "17022016
      wa_activity    type zwcm_asactivity,                  "17022016
      l_lineas       type i.                                "19022016


swc_get_element container 'APPROVAL' approval.
swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'USER_APPROVE' user_approve.
swc_get_element container 'WCAGNS' wcagns.
swc_get_element container 'APP_CYCLE' app_cycle.
swc_get_element container 'FIRST_PERMIT' first_permit.      " 15022016
swc_get_table container 'ACTIVITIES' zactivity.                            " 17022016 18022016

* Need to be implemented
IF wapinr IS NOT INITIAL.
* Get Object Number from WCM Application Data
  SELECT SINGLE objnr
       FROM wcaap
       INTO lv_objnr
       WHERE wapinr = wapinr.

* Check Application Exist or Not
  IF sy-subrc EQ 0.
    CALL FUNCTION 'WCFA_READ_SINGLE'
      EXPORTING
        i_wapinr  = wapinr
      IMPORTING
        e_wcaapwa = wa_wcaapwa
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.

* Get  Counter for differentiation from WCM Approvals
    SELECT SINGLE * FROM zwcm_hierarchy
     INTO wa_hierarchy
     WHERE iwerk = wa_wcaapwa-iwerk AND
           objart  = 'WA' AND
           pmsog = approval.

** Getting check for completion authority
*    completion_auth =  wa_hierarchy-completion_auth.

    SELECT SINGLE objnr
       FROM wcaap
       INTO lv_objnr
       WHERE wapinr = wapinr.

* Get  Counter for differentiation from WCM Approvals
    IF wcagns-counter IS NOT INITIAL.
      lv_counter = wcagns-counter.
    ELSE.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*      SELECT SINGLE counter
*        FROM wcagn
*        INTO lv_counter
*        WHERE objnr EQ lv_objnr AND
*              pmsog EQ approval.
 SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC

    ENDIF.

*    lv_counter = wa_hierarchy-hilvl / 10.

* Get  Counters for differentiation from WCM Approval Segment
    SELECT counters FROM zwcm_wcagns
           INTO TABLE lt_counters
           WHERE objnr EQ lv_objnr AND
                 counter EQ lv_counter.

* Sort Counters internal table in Descending to get highest counter value.
    SORT lt_counters DESCENDING.
    READ TABLE lt_counters INTO lv_counters INDEX 1.
* Create Work Area for Approval
    IF lv_counters IS NOT INITIAL.
      wa_approve_tab-counters =  lv_counters + 1.
    ELSE.
      wa_approve_tab-counters = 1.
    ENDIF.
    wa_approve_tab-objnr    = lv_objnr.
    wa_approve_tab-counter  = lv_counter.
    wa_approve_tab-app_cycle  = app_cycle.
    wa_approve_tab-completion_flag  = wcagns-completion_flag.
    wa_approve_tab-hilvl            = wcagns-hilvl.
    wa_approve_tab-genname  = user_approve.
    wa_approve_tab-gendatum = sy-datum.
    wa_approve_tab-gentime  = sy-uzeit.
    wa_approve_tab-genbdate = wcagns-genbdate.
    wa_approve_tab-genvtime = wcagns-genvtime.
    wa_approve_tab-genbtime = wcagns-genbtime.
    wa_approve_tab-pmsog    = wcagns-pmsog.
    wa_approve_tab-gntxt    = wcagns-gntxt.
* Begin of <> on Deciding Permit Status 11022016
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*    select single processtyp into l_processtyp from zwcm_config where plant = wa_wcaapwa-iwerk.
 SELECT PROCESSTYP FROM ZWCM_CONFIG   UP TO 1 ROWS INTO L_PROCESSTYP
WHERE PLANT = WA_WCAAPWA-IWERK  ORDER BY  PLANT PLANT_SECTION APPROVAL
USAG .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
    if sy-subrc = 0 and l_processtyp = 'DC'.
* 15022016
*      if first_permit is initial.
      SELECT  * FROM zwcm_hierarchy INTO table it_hierarchy1
      WHERE iwerk = wa_wcaapwa-iwerk AND  objart  = 'WA'.
      if sy-subrc = 0.
* Sort Counters internal table in Descending to get highest counter value.
        SORT  it_hierarchy1 ASCENDING by hilvl.
        READ TABLE  it_hierarchy1 INTO  wa_hierarchy1 INDEX 1.
        if first_permit <> wa_hierarchy1-pmsog.
          first_permit = wa_hierarchy1-pmsog.
        endif.
*          swc_set_element container 'FIRST_PERMIT' first_permit.
        refresh : it_hierarchy1.
        clear: wa_hierarchy1.
      endif.

* 15022016
      SELECT  * FROM zwcm_hierarchy INTO table it_hierarchy
      WHERE iwerk = wa_wcaapwa-iwerk AND  objart  = 'WA' AND category = wa_hierarchy-category.
      if sy-subrc = 0.
* Sort Counters internal table in Descending to get highest counter value.
        SORT  it_hierarchy DESCENDING by hilvl.
        READ TABLE  it_hierarchy INTO  wa_hierarchy1 INDEX 1.
        if wa_hierarchy-hilvl = wa_hierarchy1-hilvl.
          if wa_hierarchy1-category = 'I'.
            wa_approve_tab-permitstat    =  'F'.
          elseif wa_hierarchy1-category = 'C'.
            wa_approve_tab-permitstat    =  'X'.
          endif.
        else.
          wa_approve_tab-permitstat    = wa_hierarchy1-category.
        endif.
      endif.
    endif.
* End of <> on 11022016
* Appending Work Area to Internal Table for DB Update.
    APPEND wa_approve_tab TO lt_approve_tab.
*    CLEAR wa_approve_tab.

  ENDIF.
ENDIF.

* Issuing Approvals by Updating Table WCAGNS .
CALL FUNCTION 'ZWCFG_WCAGNS_UPDATE'
  EXPORTING
    i_instab = lt_approve_tab
  EXCEPTIONS
    error    = 1
    OTHERS   = 2.

* When update is successful mark flagf as X.
IF sy-subrc EQ 0.
  IF wa_hierarchy-std_map EQ 'X' AND app_cycle EQ 1.

    SELECT SINGLE objnr
       FROM wcaap
       INTO lv_objnr
       WHERE wapinr = wapinr.

* Check Application Exist or Not
    IF sy-subrc EQ 0.

* Get  Counter for differentiation from WCM Approvals
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*      SELECT SINGLE counter
*        FROM wcagn
*        INTO lv_counter
*        WHERE objnr EQ lv_objnr AND
*              pmsog EQ approval.
 SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR
EQ LV_OBJNR AND PMSOG EQ APPROVAL  ORDER BY  OBJNR COUNTER .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC

* Get  Counters for differentiation from WCM Approval Segment
      SELECT counters FROM wcagns
             INTO TABLE lt_counters
             WHERE objnr EQ lv_objnr AND
                   counter EQ lv_counter.

* Sort Counters internal table in Descending to get highest counter value.
      SORT lt_counters DESCENDING.
      READ TABLE lt_counters INTO lv_counters INDEX 1.

* Create Work Area for Approval
      IF lv_counters IS NOT INITIAL.
        wa_approve_std-counters =  lv_counters + 1.
      ELSE.
        wa_approve_std-counters = 1.
      ENDIF.

*      wa_approve_std-counters =  lv_counters.
      wa_approve_std-objnr    = wa_approve_tab-objnr.
      wa_approve_std-counter  =  lv_counter.
      wa_approve_std-genname  = wa_approve_tab-genname.
      wa_approve_std-gendatum = wa_approve_tab-gendatum.
      wa_approve_std-gentime  = wa_approve_tab-gentime.
      APPEND wa_approve_std TO lt_approve_std.
      CLEAR wa_approve_std.
* Issuing Approvals by Updating Table WCAGNS .
      CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
        EXPORTING
          i_instab = lt_approve_std
        EXCEPTIONS
          error    = 1
          OTHERS   = 2.

    ENDIF.
  ENDIF.
  flag = 'X'.
ENDIF.
* Begin of <> on 17022016
*   IMPORT : ZACTIVITY FROM MEMORY ID 'ZACTIVITY'.                             "18022016
if L_PROCESSTYP = 'DC'.
  delete zactivity where objnr <> lv_objnr.                 "21022016
  delete ADJACENT DUPLICATES FROM zactivity COMPARING ALL FIELDS.
  SORT zactivity ascending by actcount.
  DESCRIBE TABLE zactivity lines l_lineas.
  if l_lineas > 0.
    loop at zactivity into wa_activity where objnr = lv_objnr .
      wa_activity-APP_CYCLE = WA_APPROVE_TAB-APP_CYCLE.
      wa_activity-COUNTER   = WA_APPROVE_TAB-COUNTER.
      wa_activity-COUNTERS  = WA_APPROVE_TAB-COUNTERs.
      modify zwcm_asactivity from wa_activity.
    endloop.
  endif.
  clear : l_processtyp.
endif.
refresh zactivity.                                          " 21022016
* End of <> on 17022016
COMMIT WORK AND WAIT.
swc_set_element container 'FIRST_PERMIT' first_permit.      "15022016
swc_set_element container 'FLAG' flag.
*swc_set_element container 'COMPLETION_AUTH' completion_auth.
end_method.

begin_method custom_revoke changing container.
DATA:
      wapinr TYPE wcaap-wapinr,
      approval TYPE wcagn-pmsog,
      previous_approver TYPE wfsyst-initiator,
      previous_approval TYPE wcagn-pmsog,
      r_email_id TYPE pa0105-usrid_long,
      app_cycle  TYPE zwcm_wcagns-app_cycle,
      flag TYPE wcagns-geniakt,
      permit_txt  TYPE wcspermit-gntxt,
      lt_permit TYPE TABLE OF zwcm_hierarchy,
      lt_permit_std TYPE wctpc_permittab_type,
      wa_permit TYPE zwcm_hierarchy,
      wa_permit_std TYPE wctpc_permitwa_type,
      wa_wcaapwa   TYPE wctp1_wcaapwa_type,
      lt_approve_tab  TYPE TABLE OF zwcm_wcagns,
      wa_approve_tab  TYPE zwcm_wcagns,
      lv_objnr        TYPE j_objnr,
      lv_counter      TYPE i_count,
      lt_counters     TYPE TABLE OF i_count,
      lv_counters     TYPE i_count,
      lt_revoke_tab   TYPE ztt_wcagnstab_type,
*      lt_permit       TYPE wctpc_permittab_type,
*            wa_permit       TYPE wctpc_permitwa_type,
      lv_index  TYPE i,
*        lv_permit TYPE pmsog,
        lv_previous_permit TYPE pmsog,
      wa_revoke       TYPE zwcm_wcagns.
TYPES: BEGIN OF lty_user,
     user TYPE sysid,
    END OF lty_user,
BEGIN OF ty_email_data,
  pernr TYPE persno,
  usrid	TYPE sysid,
  usrid_long  TYPE comm_id_long,
END OF ty_email_data.
DATA: "{lt_emp_id TYPE TABLE OF ty_email_data,
      wa_emp_id TYPE ty_email_data,
      lt_user TYPE TABLE OF lty_user,
      lv_user TYPE lty_user.


CONSTANTS: lc_check TYPE char1 VALUE 'X'.




swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'APPROVAL' approval.
swc_get_element container 'APP_CYCLE' app_cycle.

*   Need to be implemented
IF wapinr IS NOT INITIAL.
  CALL FUNCTION 'WCFA_READ_SINGLE'
    EXPORTING
      i_wapinr  = wapinr
    IMPORTING
      e_wcaapwa = wa_wcaapwa
    EXCEPTIONS
      error     = 1
      OTHERS    = 2.

  SELECT * FROM zwcm_hierarchy
    INTO TABLE lt_permit
    WHERE iwerk = wa_wcaapwa-iwerk AND
          objart = 'WA'.
*          PMSOG  = approval.

  DELETE lt_permit WHERE stop_auth EQ 'X' OR ext_appr EQ 'X'.
  SORT lt_permit BY hilvl.
  LOOP AT lt_permit INTO wa_permit.
    IF wa_permit-pmsog = approval.
      lv_index = sy-tabix - 1.
    ENDIF.
  ENDLOOP.

  READ TABLE lt_permit INTO wa_permit INDEX lv_index.

  IF sy-subrc EQ 0.
    lv_previous_permit = wa_permit-pmsog.
    CALL FUNCTION 'ZWCA_GET_APPROVALS'
      EXPORTING
        wapinr   = wapinr
*       WCD_FLAG =
      IMPORTING
        t_permit = lt_permit_std.
    READ TABLE lt_permit_std INTO wa_permit_std WITH KEY pmsog = lv_previous_permit.
    IF sy-subrc EQ 0.
      permit_txt   = wa_permit_std-gntxt.
    ENDIF.

" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*    SELECT SINGLE counter FROM wcagn
*      INTO lv_counter
*      WHERE objnr = wa_wcaapwa-objnr AND
*      pmsog = lv_previous_permit."wa_permit-pmsog.
 SELECT COUNTER FROM WCAGN   UP TO 1 ROWS INTO LV_COUNTER WHERE OBJNR =
WA_WCAAPWA-OBJNR AND PMSOG = LV_PREVIOUS_PERMIT  ORDER BY  OBJNR
COUNTER .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC
*    lv_counter = wa_permit-hilvl / 10.

  ENDIF.
* Check Application Exist or Not
  IF sy-subrc EQ 0.

* Get Object Number from WCM Application Data
    SELECT SINGLE objnr
         FROM wcaap
         INTO lv_objnr
         WHERE wapinr = wapinr.

* Get  Counters for differentiation from WCM Approval Segment
    SELECT * FROM zwcm_wcagns
           INTO TABLE lt_revoke_tab
           WHERE objnr EQ lv_objnr AND
                 counter EQ lv_counter.

* Sort Counters internal table in Descending to get highest counter value.
    SORT lt_revoke_tab BY counters DESCENDING .
    READ TABLE lt_revoke_tab INTO wa_revoke INDEX 1.

    CLEAR lt_revoke_tab.
* Create Work Area for Approval
    wa_revoke-geniname = sy-uname.
    wa_revoke-genidate = sy-datum.
    wa_revoke-genitime = sy-uzeit.
    wa_revoke-geniakt  = lc_check.

* Appending Work Area to Internal Table for DB Update.
    APPEND wa_revoke TO lt_revoke_tab.
*    CLEAR wa_revoke.

  ENDIF.

ENDIF.
CALL FUNCTION 'ZWCFG_WCAGNS_UPDATE'
  EXPORTING
    i_updtab = lt_revoke_tab
  EXCEPTIONS
    error    = 1
    OTHERS   = 2.
* When update is successful mark flagf as X.
IF sy-subrc EQ 0.
  flag = 'X'.

  CONCATENATE 'US' wa_revoke-genname INTO previous_approver.
ENDIF.

previous_approval = lv_previous_permit.

** Start of Email Logic**
*LOOP AT gt_users INTO gw_users.
lv_user = wa_revoke-genname.
*  APPEND wa_user TO lt_user.
*ENDLOOP.
*gt_users-approver
*IF gt_users IS NOT INITIAL.

" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 09.06.2026  FOR ATC
*SELECT SINGLE pernr usrid usrid_long FROM pa0105
*  INTO wa_emp_id
**    FOR ALL ENTRIES IN lt_user
*  WHERE usrid = lv_user AND
*        usrty = '0001'.
 SELECT PERNR USRID USRID_LONG FROM PA0105   UP TO 1 ROWS INTO
WA_EMP_ID WHERE USRID = LV_USER AND USRTY = '0001'  ORDER BY  PERNR
SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 09.06.2026 FOR ATC

IF sy-subrc EQ 0.
  SELECT SINGLE usrid_long FROM pa0105
   INTO r_email_id
   WHERE pernr = wa_emp_id-pernr AND
         usrty = '0010'.
ENDIF.

*ENDIF.
** End of Email Logic**

swc_set_element container 'PREVIOUS_APPROVER' previous_approver.
swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
swc_set_element container 'R_EMAIL_ID' r_email_id.
swc_set_element container 'FLAG' flag.
swc_set_element container 'PERMIT_TXT' permit_txt.
end_method.

begin_method send_approval_mail changing container.
DATA:
      permit TYPE wcagn-pmsog,
      application TYPE wcaap-wapinr,
      email_id    TYPE pa0105-usrid_long OCCURS 0,
      revoke_text   TYPE rdgprint-stadd1 OCCURS 0,
      revoke_flag   TYPE wcagns-geniakt.

swc_get_element container 'PERMIT' permit.
swc_get_element container 'APPLICATION' application.
swc_get_table container 'EMAIL_ID' email_id.
swc_get_table container 'REVOKE_TEXT' revoke_text.
swc_get_element container 'REVOKE_FLAG' revoke_flag.

CALL FUNCTION 'ZWCM_SEND_MAIL'
  EXPORTING
    im_permit      = permit
    im_appl        = application
    it_email_id    = email_id
    it_revoke_text = revoke_text
    im_revoke_flag = revoke_flag.

end_method.


*DATA:
*      wapinr TYPE wcaap-wapinr,
*
**      appr_stat
*
*      flag_loop TYPE zwcm_custom-beg_loop_flag,
*      sms_uname TYPE suid_st_bname-bname,
*      sms_number TYPE threic_contact-mobile,
*      permit_tx
*      wa_permit   TYPE wctpc_permitwa_type.
*swc_get_element container 'APPROVAL' approval.
*swc_get_element container 'SMS_NUMBER' sms_number.
*
*CALL FUNCTION 'ZWCM_AUTO_APPROVAL'
*  EXPORTING
**   im_spool           =
*    im_permit          = approval
*    im_appl            = wapinr
**   IM_WCD_FLAG        =
**   IM_WORK_ITEMID     =
*  IMPORTING
*    ex_appr_status     = appr_status
**   EX_USER_APROVE     =
**   ET_USER            =
*    ex_next_permit     = next_approval
**   ET_TEXT            =
**   ET_EMAIL_ID        =
*    ex_flag_loop       = flag_loop
**   EX_WCD_DOCNUM      =
**   EX_COMPLETION_AUTH =
**   EX_RENEWAL_AUTH    =
**   EX_SINGLE_FLAG     =
**   EX_PREV_PERMIT     =
*  CHANGING
*    ch_sms_uname       = sms_uname
*    ch_sms_number      = sms_number.
*
*CALL FUNCTION 'ZWCA_GET_APPROVALS'
*  EXPORTING
*    wapinr   = wapinr
**   WCD_FLAG =
*  IMPORTING
*    t_permit = lt_permit.
*
*  READ TABLE lt_permit INTO wa_permit with key pmsog = next_approval.
*  IF sy-subrc eq 0.
*    permit_txt = wa_permit-
*
*  ENDIF.
*swc_set_element container 'APPR_STATUS' appr_status.
*swc_set_element container 'NEXT_APPROVAL' next_approval.
*swc_set_element container 'FLAG_LOOP' flag_loop.
*swc_set_element container 'SMS_UNAME' sms_uname.
*swc_set_element container 'SMS_NUMBER' sms_number.
*swc_set_element container 'PERMIT_TXT' permit_txt.
*end_method.
*BEGIN_DATA OBJECT. " Do not change.. DATA is generated
** only private members may be inserted into structure private
*DATA:
*" begin of private,
*"   to declare private attributes remove comments and
*"   insert private attributes here ...
*" end of private,
*  BEGIN OF KEY,
*      NUMBER LIKE WCAAP-WAPINR,
*  END OF KEY.
*END_DATA OBJECT. " Do not change.. DATA is generated
*BEGIN_DATA OBJECT. " Do not change.. DATA is generated
** only private members may be inserted into structure private
*DATA:
*" begin of private,
*"   to declare private attributes remove comments and
*"   insert private attributes here ...
*" end of private,
*  BEGIN OF KEY,
*      NUMBER LIKE WCAAP-WAPINR,
*  END OF KEY.
*END_DATA OBJECT. " Do not change.. DATA is generated

begin_method auto_approval changing container.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
DATA:
      wapinr TYPE wcaap-wapinr,
      approval TYPE wcagn-pmsog,
      appr_status TYPE wcagns-geniakt,
      next_approval TYPE wcagn-pmsog,
      flag_loop TYPE zwcm_custom-beg_loop_flag,
      previous_approval TYPE wcagn-pmsog,
      wcd_flag   TYPE wcagns-geniakt,
      sms_uname TYPE suid_st_bname-bname,
      sms_number TYPE threic_contact-mobile,  "#EC CI_USAGE_OK[3224334]
      permit_txt TYPE wcspermit-gntxt,
      lt_permit TYPE wctpc_permittab_type,
      wcd_docnum    TYPE zwcm_hierarchy-hilvl,
      wa_permit   TYPE wctpc_permitwa_type.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
swc_get_element container 'WAPINR' wapinr.
swc_get_element container 'APPROVAL' approval.
swc_get_element container 'SMS_NUMBER' sms_number.
swc_get_element container 'WCD_FLAG' wcd_flag.

CALL FUNCTION 'ZWCM_AUTO_APPROVAL'
  EXPORTING
*   im_spool           =
    im_permit          = approval
    im_appl            = wapinr
    im_wcd_flag        = wcd_flag
*   IM_WORK_ITEMID     =
  IMPORTING
    ex_appr_status     = appr_status
*   EX_USER_APROVE     =
*   ET_USER            =
    ex_next_permit     = next_approval
*   ET_TEXT            =
*   ET_EMAIL_ID        =
    ex_flag_loop       = flag_loop
    ex_wcd_docnum      = wcd_docnum
*   EX_COMPLETION_AUTH =
*   EX_RENEWAL_AUTH    =
*   EX_SINGLE_FLAG     =
    ex_prev_permit     = previous_approval
  CHANGING
    ch_sms_uname       = sms_uname
    ch_sms_number      = sms_number.

CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wapinr
    wcd_flag = wcd_flag
  IMPORTING
    t_permit = lt_permit.

READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
IF sy-subrc EQ 0.
  permit_txt = wa_permit-gntxt.

ENDIF.
swc_set_element container 'APPR_STATUS' appr_status.
swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_element container 'FLAG_LOOP' flag_loop.
swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
swc_set_element container 'SMS_UNAME' sms_uname.
swc_set_element container 'PERMIT_TXT' permit_txt.
swc_set_element container 'WCD_DOCNUM'    wcd_docnum.
end_method.

begin_method revoke_all_approvals changing container.
DATA:
      wapinr TYPE wcaap-wapinr,
      uname TYPE suid_st_bname-bname.
swc_get_element container 'wapinr' wapinr.
swc_get_element container 'uname' uname.

CALL FUNCTION 'ZWCM_WF_REVOKE_CLOSE'
  EXPORTING
    im_appl  = wapinr
    im_uname = uname.

end_method.
