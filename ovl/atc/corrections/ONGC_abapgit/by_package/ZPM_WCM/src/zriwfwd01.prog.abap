************************************************************************
* Programm RIWFWD01
*-----------------------------------------------------------------------
* Purpose: Implementation of object type WCD
************************************************************************
* includes
INCLUDE <object>.
* elementary types

* structures types

* tables types
TYPES: apprtab_type TYPE swc_object OCCURS 0.

* constants

* type pools
TYPE-POOLS: wctp1.
TYPE-POOLS: wctp2.
TYPE-POOLS: wctp3.
TYPE-POOLS: wctp4.
TYPE-POOLS: wctpf.
TYPE-POOLS: wctpc.

* tables
TABLES: wcahe.

* object data
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  begin of private,
    exit  TYPE wctp4_exit_type,
    subrc TYPE sysubrc,
  end of private,
  BEGIN OF KEY,
      NUMBER LIKE WCAHE-WCNR,
  END OF KEY,
      AGENTCREATEDBY TYPE WFSYST-AGENT,
      _WCAHE LIKE WCAHE.
END_DATA OBJECT. " Do not change.. DATA is generated

*

begin_method agentget changing container.
************************************************************************
*  METHOD  AgentGet
*-----------------------------------------------------------------------
*  Purpose: a) Add users which have already given approvals for
*              the object to E_AGENTTAB
*           b) Add workflow initiator to E_AGENTTAB
*-----------------------------------------------------------------------
*  CONTAINER 'I_WF_Initiator'  -->  I_WF_INITIATOR
*  CONTAINER 'E_Agenttab'      <--  E_AGENTTAB
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters
DATA: i_wf_initiator TYPE swp_agent.

* export parameters
DATA: e_agenttab     TYPE wctp4_agenttab_type.

* data declaration
DATA: l_permittab    TYPE wctpc_permittab_type.
DATA: l_permitwa     TYPE wctpc_permitwa_type.
DATA: l_agentwa      TYPE wctp4_agentwa_type.
DATA: l_iwerk        TYPE wctp1_iwerk_type.
DATA: l_objtyp       TYPE wctp1_objtyp_type.
DATA: l_objnr        TYPE wctp1_objnr_type.


* main part ------------------------------------------------------------

* initialize export parameters
REFRESH: e_agenttab.

* get object attributes
swc_get_property self wctp4_attr-planningplant l_iwerk.
swc_get_property self wctp4_attr-type          l_objtyp.
swc_get_property self wctp4_attr-objectnumber  l_objnr.

* get import parameters
swc_get_element container 'I_WF_Initiator' i_wf_initiator.

* append WF initiator to E_AGENTTAB
APPEND i_wf_initiator TO e_agenttab.

* determine assigned permits
CALL FUNCTION 'WCFG_INFO_GET'
  EXPORTING
    i_iwerk     = l_iwerk
    i_objart    = wctp1_objart-wcd
    i_objtyp    = l_objtyp
    i_objnr     = l_objnr
  IMPORTING
    e_permittab = l_permittab
  EXCEPTIONS
    error       = 1
    OTHERS      = 2.
* check, if exception occured
object-private-subrc = sy-subrc.
CALL FUNCTION 'WCFF_EXCEPTION_CONVERT'
  EXPORTING
    i_subrc = object-private-subrc
    i_fb    = 'WCFG_INFO_GET'
  IMPORTING
    e_exit  = object-private-exit
  EXCEPTIONS
    error   = 1
    OTHERS  = 2.
IF NOT ( object-private-exit IS INITIAL ).
* => exception occured
  exit_return
    object-private-exit-code
    object-private-exit-msgv1
    object-private-exit-msgv2
    object-private-exit-msgv3
    object-private-exit-msgv4.
ELSE.
* => no exception occured
ENDIF.

* permits are assigned?
IF NOT ( l_permittab IS INITIAL ).
* => YES, permits are assigned
*   delete permits which AREN'T issued
  DELETE l_permittab
         WHERE NOT ( k_genehm EQ wctp1_marked ).
*   update E_AGENTTAB
  LOOP AT l_permittab INTO l_permitwa.
    CONCATENATE wctp4_us l_permitwa-genname INTO l_agentwa.
    APPEND l_agentwa TO e_agenttab.
  ENDLOOP.

  IF NOT ( e_agenttab IS INITIAL ).
*   => delete duplicates
    SORT e_agenttab.
    DELETE ADJACENT DUPLICATES FROM e_agenttab.
*     export E_AGENTTAB
    swc_set_table container 'E_Agenttab' e_agenttab.
  ELSE.
*   => bug
    exit_return 1002 'E_AGENTTAB' space space space.
*       no entry in table &
  ENDIF.
ELSE.
* => NO, permits ARENT assigned
  exit_return 1001 text-002 space space space.
*       no approval is assigned to object
ENDIF.
end_method.

begin_method apprcheck changing container.
************************************************************************
*  METHOD  ApprCheck
*-----------------------------------------------------------------------
*  Purpose: Check wether a specific approval has already been given for
*           the object
*-----------------------------------------------------------------------
*  CONTAINER 'I_Permit'  -->  I_PERMIT
*  CONTAINER RESULT      <--  E_RESULT
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters
DATA: i_permit    TYPE pmsog.

* export parameters
DATA: e_result    TYPE k_genehm.

* data declaration
DATA: l_permittab TYPE wctpc_permittab_type.
DATA: l_permitwa  TYPE wctpc_permitwa_type.
DATA: l_iwerk     TYPE wctp1_iwerk_type.
DATA: l_objtyp    TYPE wctp1_objtyp_type.
DATA: l_objnr     TYPE wctp1_objnr_type.

* main part ------------------------------------------------------------

* initialize export parameters
CLEAR: e_result.

* get import parameters
swc_get_element container wctp4_cont-i_permit i_permit.
IF  ( i_permit IS INITIAL ).
* => bug
  exit_return 1000 text-001 wctp4_cont-i_permit space space.
*     import parameter I_PERMIT is initial
ENDIF.

* get object attributes
swc_get_property self wctp4_attr-planningplant l_iwerk.
swc_get_property self wctp4_attr-type          l_objtyp.
swc_get_property self wctp4_attr-objectnumber  l_objnr.

* determine assigned permits
CALL FUNCTION 'WCFG_INFO_GET'
  EXPORTING
    i_iwerk     = l_iwerk
    i_objart    = wctp1_objart-wcd
    i_objtyp    = l_objtyp
    i_objnr     = l_objnr
  IMPORTING
    e_permittab = l_permittab
  EXCEPTIONS
    error       = 1
    OTHERS      = 2.
* check, if exception occured
object-private-subrc = sy-subrc.
CALL FUNCTION 'WCFF_EXCEPTION_CONVERT'
  EXPORTING
    i_subrc = object-private-subrc
    i_fb    = 'WCFG_INFO_GET'
  IMPORTING
    e_exit  = object-private-exit
  EXCEPTIONS
    error   = 1
    OTHERS  = 2.
IF NOT ( object-private-exit IS INITIAL ).
* => exception occured => exit
  exit_return
      object-private-exit-code
      object-private-exit-msgv1
      object-private-exit-msgv2
      object-private-exit-msgv3
      object-private-exit-msgv4.
ELSE.
* => no exception occured => nothing to do
ENDIF.

* permits are assigned?
IF NOT ( l_permittab IS INITIAL ).
* => YES, permits are assigned
*   check, whether specific permit does exist
  READ TABLE l_permittab INTO l_permitwa WITH KEY
       pmsog = i_permit.
  IF ( sy-subrc NE 0 ).
*   => NO, specific permit DOESN'T exist
    exit_return 1001 space i_permit text-003 space.
*       Approval & is not assigned to object
  ELSE.
*   => YES, specific permit does exist (=> nothing to do)
  ENDIF.
ELSE.
* => NO, permits AREN'T assigned
  exit_return 1001 text-002 space space space.
*     No approval is assigned to object
ENDIF.

* set export parameters
e_result = l_permitwa-k_genehm.
swc_set_element container result e_result.
end_method.

begin_method apprget changing container.
************************************************************************
*  Method ApprGet
*-----------------------------------------------------------------------
*  Purpose: Determines next required approvals with agents for object
*-----------------------------------------------------------------------
*  CONTAINER 'E_Apprtab'    <--  E_APPRTAB
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters

* export parameters
DATA: e_apprtab   TYPE apprtab_type.

* data declaration
DATA: l_permittab TYPE wctpc_permittab_type.
DATA: l_iwerk     TYPE wctp1_iwerk_type.
DATA: l_objtyp    TYPE wctp1_objtyp_type.
DATA: l_objnr     TYPE wctp1_objnr_type.

* main part ------------------------------------------------------------

* initialize export parameters
REFRESH: e_apprtab.

* get object attributes
swc_get_property self wctp4_attr-planningplant l_iwerk.
swc_get_property self wctp4_attr-type          l_objtyp.
swc_get_property self wctp4_attr-objectnumber  l_objnr.

CALL FUNCTION 'WCFF_NEXT_APPR_GET'
  EXPORTING
    i_iwerk     = l_iwerk
    i_objart    = wctp1_objart-wcd
    i_objtyp    = l_objtyp
    i_objnr     = l_objnr
  IMPORTING
    e_permittab = l_permittab
  EXCEPTIONS
    error       = 1
    OTHERS      = 2.
* check, if exception occured
object-private-subrc = sy-subrc.
CALL FUNCTION 'WCFF_EXCEPTION_CONVERT'
  EXPORTING
    i_subrc = object-private-subrc
    i_fb    = 'WCFF_NEXT_APPR_GET'
  IMPORTING
    e_exit  = object-private-exit
  EXCEPTIONS
    error   = 1
    OTHERS  = 2.
IF NOT ( object-private-exit IS INITIAL ).
* => exception occured
  exit_return
      object-private-exit-code
      object-private-exit-msgv1
      object-private-exit-msgv2
      object-private-exit-msgv3
      object-private-exit-msgv4.
ELSE.
* => nothing to do
ENDIF.

IF NOT ( l_permittab IS INITIAL ).
* => there are missing approvals
*   create table with object references
  PERFORM lwcfff01_apprtab_create IN PROGRAM saplwcff
    USING
      l_permittab
    CHANGING
      e_apprtab
      object-private-subrc.
  IF NOT ( object-private-subrc EQ wctp4_subrc-ok ).
*   => bug
    exit_return 1002 'LWCFFF01_APPRTAB_CREATE' space space space.
*       error during execution of FB LWCFFF01_APPRTAB_CREATE
  ELSE.
*   => export table of approvals
    swc_set_table container 'E_Apprtab' e_apprtab.
  ENDIF.
ELSE.
* => no missing approvals
  exit_return 1000 space space space space.
*     No required approvals found
ENDIF.
end_method.

begin_method display changing container.
************************************************************************
*  METHOD  Display
*-----------------------------------------------------------------------
*  Purpose: Display object
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters

* export parameters

* data declaration
DATA: l_iwerk  TYPE wctp1_iwerk_type.
DATA: l_objtyp TYPE wctp1_objtyp_type.

* main part ------------------------------------------------------------

* get object attributes
swc_get_property self wctp4_attr-planningplant l_iwerk.
swc_get_property self wctp4_attr-type          l_objtyp.

* display WCD
CALL FUNCTION 'WCFW_OBJ_DIALOG'
     EXPORTING
*           I_TCODE        =
          i_aktyp        = wctp1_aktyp_a
          i_iwerk        = l_iwerk
          i_objart       = wctp1_objart-wcd
          i_objtyp       = l_objtyp
          i_objkey       = object-key-number
*           I_CP           =
*           I_FIRST_FCODE  =
*           I_SECOND_FCODE =
*           I_THIRD_FCODE  =
*      IMPORTING
*           E_FCODE        =
*           E_UPDATE       =
     EXCEPTIONS
         error           = 1
         OTHERS          = 2.
* check, if exception occured
object-private-subrc = sy-subrc.
CALL FUNCTION 'WCFF_EXCEPTION_CONVERT'
  EXPORTING
    i_subrc = object-private-subrc
    i_fb    = 'WCFW_OBJ_DIALOG'
  IMPORTING
    e_exit  = object-private-exit
  EXCEPTIONS
    error   = 1
    OTHERS  = 2.
IF NOT ( object-private-exit IS INITIAL ).
* => exception occured => exit
  exit_return
      object-private-exit-code
      object-private-exit-msgv1
      object-private-exit-msgv2
      object-private-exit-msgv3
      object-private-exit-msgv4.
ELSE.
* => no exception occured => nothing to do
ENDIF.
end_method.

begin_method edit changing container.
************************************************************************
*  METHOD  Edit
*-----------------------------------------------------------------------
*  Purpose: Edit object
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters

* export parameters

* data declaration
DATA: l_iwerk  TYPE wctp1_iwerk_type.
DATA: l_objtyp TYPE wctp1_objtyp_type.

* main part ------------------------------------------------------------

* get object attributes
swc_get_property self wctp4_attr-planningplant l_iwerk.
swc_get_property self wctp4_attr-type          l_objtyp.

* change WCD
CALL FUNCTION 'WCFW_OBJ_DIALOG'
     EXPORTING
*           I_TCODE        =
          i_aktyp        = wctp1_aktyp_v
          i_iwerk        = l_iwerk
          i_objart       = wctp1_objart-wcd
          i_objtyp       = l_objtyp
          i_objkey       = object-key-number
*           I_CP           =
*           I_FIRST_FCODE  =
*           I_SECOND_FCODE =
*           I_THIRD_FCODE  =
*      IMPORTING
*           E_FCODE        =
*           E_UPDATE       =
     EXCEPTIONS
         error           = 1
         OTHERS          = 2.
* check, if exception occured
object-private-subrc = sy-subrc.
CALL FUNCTION 'WCFF_EXCEPTION_CONVERT'
  EXPORTING
    i_subrc = object-private-subrc
    i_fb    = 'WCFW_OBJ_DIALOG'
  IMPORTING
    e_exit  = object-private-exit
  EXCEPTIONS
    error   = 1
    OTHERS  = 2.
IF NOT ( object-private-exit IS INITIAL ).
* => exception occured => exit
  exit_return
      object-private-exit-code
      object-private-exit-msgv1
      object-private-exit-msgv2
      object-private-exit-msgv3
      object-private-exit-msgv4.
ELSE.
* => no exception occured => nothing to do
ENDIF.
end_method.

begin_method editasynchron changing container.
************************************************************************
*  METHOD  EditAsynchron
*-----------------------------------------------------------------------
*  Purpose: Edit object. Method must be terminated asynchron by a
*           terminating event.
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters

* export parameters

* data declaration
DATA: l_iwerk  TYPE wctp1_iwerk_type.
DATA: l_objtyp TYPE wctp1_objtyp_type.

* main part ------------------------------------------------------------

* get object attributes
swc_get_property self wctp4_attr-planningplant l_iwerk.
swc_get_property self wctp4_attr-type          l_objtyp.

* change WCD
CALL FUNCTION 'WCFW_OBJ_DIALOG'
     EXPORTING
*           I_TCODE        =
          i_aktyp        = wctp1_aktyp_v
          i_iwerk        = l_iwerk
          i_objart       = wctp1_objart-wcd
          i_objtyp       = l_objtyp
          i_objkey       = object-key-number
*           I_CP           =
*           I_FIRST_FCODE  =
*           I_SECOND_FCODE =
*           I_THIRD_FCODE  =
*      IMPORTING
*           E_FCODE        =
*           E_UPDATE       =
     EXCEPTIONS
         error           = 1
         OTHERS          = 2.
* check, if exception occured
object-private-subrc = sy-subrc.
CALL FUNCTION 'WCFF_EXCEPTION_CONVERT'
  EXPORTING
    i_subrc = object-private-subrc
    i_fb    = 'WCFW_OBJ_DIALOG'
  IMPORTING
    e_exit  = object-private-exit
  EXCEPTIONS
    error   = 1
    OTHERS  = 2.
IF NOT ( object-private-exit IS INITIAL ).
* => exception occured => exit
  exit_return
      object-private-exit-code
      object-private-exit-msgv1
      object-private-exit-msgv2
      object-private-exit-msgv3
      object-private-exit-msgv4.
ELSE.
* => no exception occured => nothing to do
ENDIF.
end_method.

begin_method existencecheck changing container.
************************************************************************
*  METHOD  ExistenceCheck
*-----------------------------------------------------------------------
*  Purpose: Check whether object exists. If not, raise message and
*           return exception.
************************************************************************

* local data -----------------------------------------------------------

* constants

* import parameters

* export parameters

* data declaration

* main part ------------------------------------------------------------

SELECT SINGLE * FROM wcahe
       WHERE ( wcnr EQ object-key-number ).
IF ( sy-subrc NE 0 ).
* => exception: object doesn't exist
  exit_return 0001 space space space space.
ENDIF.
end_method.

get_property agentcreatedby changing container.
************************************************************************
*  PROPERTY  AgentCreatedBy
*-----------------------------------------------------------------------
*  Purpose: Provide contents  for object attribute AgentCreatedBy
************************************************************************

* local data -----------------------------------------------------------

* constants

* data declaration
DATA: l_crname TYPE wcecrname.

* main part ------------------------------------------------------------

* get property CreatedBy
swc_get_property self wctp4_attr-createdby l_crname.
* add suffix
CONCATENATE wctp4_us l_crname INTO object-agentcreatedby.
* set attribute AgentCreatedBy
swc_set_element container
  wctp4_attr-agentcreatedby
  object-agentcreatedby.
end_property.

get_table_property wcahe.
************************************************************************
*  TABLE PROPERTY  WCAHE
*-----------------------------------------------------------------------
*  Purpose: Provide contents of table WCAHE for object attributes
************************************************************************

* local data -----------------------------------------------------------

* constants

* data declaration
DATA: l_subrc TYPE sysubrc.

* main part ------------------------------------------------------------

PERFORM select_table_wcahe
  CHANGING
    l_subrc.
IF ( l_subrc NE 0 ).
* => exception: object doesn't exist
  exit_object_not_found.
ENDIF.
end_property.

************************************************************************
*  FORM SELECT_TABLE_WCAHE
*-----------------------------------------------------------------------
*  Purpose: Provide contents of table WCAHE for object attributes
*       Use Form also for other(virtual) Properties to fill TABLES WCAHE
************************************************************************
FORM select_table_wcahe
  CHANGING
    value(e_subrc) TYPE sysubrc.

* local data -----------------------------------------------------------

* constants

* data declaration

* main part ------------------------------------------------------------

  IF ( ( object-_wcahe-mandt NE sy-mandt          ) OR
       ( object-_wcahe-wcnr  NE object-key-number ) ).
    SELECT SINGLE * FROM wcahe CLIENT SPECIFIED
           WHERE ( mandt EQ sy-mandt          )
           AND   ( wcnr  EQ object-key-number ).
    e_subrc         = sy-subrc.
    IF ( e_subrc EQ 0 ).
      object-_wcahe = wcahe.
    ENDIF.
  ELSE.
    e_subrc         = 0.
    wcahe           = object-_wcahe.
  ENDIF.
ENDFORM.                    "SELECT_TABLE_WCAHE

begin_method statcheck changing container.
************************************************************************
*  METHOD  StatCheck
*-----------------------------------------------------------------------
*  Purpose: Checks whether a specific status is set for the object.
*
*           Status is set | Result
*          ---------------+--------
*              yes        | true
*              no         | false
*
*-----------------------------------------------------------------------
*  CONTAINER 'I_Stat'  -->  I_STAT
*  CONTAINER RESULT    <--  E_RESULT
************************************************************************

* local data -----------------------------------------------------------

* constants
CONSTANTS: c_object_not_found  TYPE sysubrc VALUE 1.
CONSTANTS: c_status_not_active TYPE sysubrc VALUE 2.

* input parameters
DATA: i_stat   TYPE j_status.

* export parameters
DATA: e_result TYPE wceboolean.

* data declaration
DATA: l_objnr  TYPE wctp1_objnr_type.

* main part ------------------------------------------------------------

* initialize export parameters
e_result = wctp1_false.

* get import parameters
swc_get_element container wctp4_cont-i_stat i_stat.

* check import parameters
IF ( i_stat IS INITIAL ).
* => bug
  exit_return 1000 text-001 wctp4_cont-i_stat space space.
*     Import Parameter & ist initial
ELSE.
* => nothing to do
ENDIF.

* get attribute objnr
swc_get_property self wctp4_attr-objectnumber l_objnr.

* check if status is active
CALL FUNCTION 'STATUS_CHECK'
  EXPORTING
*   BYPASS_BUFFER     = SPACE
*   CLIENT            = SY-MANDT
    objnr             = l_objnr
    status            = i_stat
  EXCEPTIONS
    object_not_found  = 01
    status_not_active = 02
    OTHERS            = 03.
CASE sy-subrc.
  WHEN 0.
*   => status is active
    e_result = wctp1_true.
  WHEN c_object_not_found.
*   => bug
    exit_return 1001 'OBJECT_NOT_FOUND' 'STATUS_CHECK' space space.
*       Fehler & beim ausführen des FB &
  WHEN c_status_not_active.
*   => status is active
    e_result = wctp1_false.
  WHEN OTHERS.
*   => bug
    exit_return 1001 'STATUS_CHECK' space space space.
*       Fehler beim ausführen des FB &
ENDCASE.

* set result
swc_set_element container result e_result.
end_method.

begin_method generate_spool changing container.
DATA:
      wcnr TYPE wcswcdoc-wcnr,
      spool_req TYPE tsp01-rqident.



swc_get_element container 'WCNR' wcnr.
spool_req = 20655.
swc_set_element container 'SPOOL_REQ' spool_req.
end_method.

begin_method get_current_users changing container.
DATA:
      approver_number TYPE wcagns-counter,
      bname TYPE wfsyst-initiator OCCURS 0,
      approval TYPE wcagn-pmsog,
      next_approval TYPE wcagn-pmsog,
      wcnr TYPE wcswcdoc-wcnr,
            permit_txt TYPE wcspermit-gntxt,
      wapi_desc    TYPE wcaap-stxt,
        wa_bname TYPE wfsyst-initiator,

   wa_wcaapwa   TYPE wcahe,
   lv_permit TYPE pmsog,
        wa_wcsccobj  TYPE wcsccobj,
        wa_wcsloc    TYPE wcsloc,
        lt_custom TYPE TABLE OF zwcm_custom,
        wa_custom TYPE zwcm_custom,
      lt_permit TYPE wctpc_permittab_type,
*      approver_number TYPE wcagns-counter,
      lv_index  TYPE i,
      wa_permit TYPE wctpc_permitwa_type.
swc_get_element container 'APPROVAL' approval.
swc_get_element container 'WCNR' wcnr.
CONSTANTS lc_wcd TYPE string VALUE 'WCD'.
CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wcnr
    wcd_flag = 'X'
  IMPORTING
    t_permit = lt_permit.
IF approval IS NOT INITIAL.
  READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = approval.
  lv_permit = wa_permit-pmsog.
  CLEAR wa_permit.
ELSE.
  READ TABLE lt_permit INTO wa_permit INDEX 3." NEED TO CHANGE
  lv_permit = wa_permit-pmsog.
  CLEAR wa_permit.
ENDIF.
approval = lv_permit.
*CALL FUNCTION 'WCFA_READ_SINGLE'
*  EXPORTING
*    i_wapinr  = wcnr
*  IMPORTING
*    e_wcaapwa = wa_wcaapwa
*  EXCEPTIONS
*    error     = 1
*    OTHERS    = 2.
SELECT SINGLE * FROM wcahe
   INTO wa_wcaapwa
   WHERE wcnr = wcnr.

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
      WHERE doc_type = lc_wcd AND
            plant    = wa_wcaapwa-iwerk AND
            plant_section = wa_wcsloc-beber  AND
            approval = lv_permit AND
            usag     = wa_wcaapwa-wcuse AND " +for usage
            from_date LE sy-datum AND
            to_date GE sy-datum .
  IF sy-subrc NE 0.
    SELECT * FROM zwcm_custom
          INTO TABLE lt_custom
          WHERE doc_type = lc_wcd AND
                plant    = wa_wcaapwa-iwerk AND
                plant_section = '000'  AND
                approval = lv_permit AND
                usag     = wa_wcaapwa-wcuse AND " +for usage
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

DESCRIBE TABLE bname LINES approver_number.
CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wcnr
    wcd_flag = 'X'
  IMPORTING
    t_permit = lt_permit.

READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = approval.
IF sy-subrc EQ 0.
  permit_txt = wa_permit-gntxt.
ENDIF.
swc_set_element container 'APPROVER_NUMBER' approver_number.
swc_set_table container 'BNAME' bname.
swc_set_element container 'APPROVAL' approval.
swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_element container 'PERMIT_TXT' permit_txt.
swc_set_element container 'WAPI_DESC' wapi_desc.
end_method.

begin_method issue changing container.
DATA:
      approval TYPE wcagn-pmsog,
      wcnr TYPE wcahe-wcnr,
      flag TYPE wcagns-geniakt,
      user_approve TYPE wfsyst-initiator,
      lv_objnr        TYPE j_objnr,
      lt_counters     TYPE TABLE OF i_count,
      lv_counters     TYPE i_count,
      lt_approve_tab  TYPE TABLE OF wcagns,
      wa_approve_tab  TYPE wcagns,
      lv_counter      TYPE i_count.
swc_get_element container 'APPROVAL' approval.
swc_get_element container 'WCNR' wcnr.
swc_get_element container 'USER_APPROVE' user_approve.
IF wcnr IS NOT INITIAL.

* Get Object Number from WCM Application Data
  SELECT SINGLE objnr
       FROM wcahe
       INTO lv_objnr
       WHERE wcnr = wcnr.

* Check Application Exist or Not
  IF sy-subrc EQ 0.

* Get  Counter for differentiation from WCM Approvals
    SELECT SINGLE counter
      FROM wcagn
      INTO lv_counter
      WHERE objnr EQ lv_objnr AND
            pmsog EQ approval.

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
      wa_approve_tab-counters =  lv_counters + 1.
    ELSE.
      wa_approve_tab-counters = 1.
    ENDIF.
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

* Issuing Approvals by Updating Table WCAGNS .
CALL FUNCTION 'WCFG_WCAGNS_UPDATE'
  EXPORTING
    i_instab = lt_approve_tab
  EXCEPTIONS
    error    = 1
    OTHERS   = 2.

* When update is successful mark flagf as X.
IF sy-subrc EQ 0.
  flag = 'X'.
ENDIF.
COMMIT WORK AND WAIT.
swc_set_element container 'FLAG' flag.
end_method.

begin_method revoke changing container.
DATA:
      wcnr TYPE wcahe-wcnr,
      approval TYPE wcagn-pmsog,
      previous_approver TYPE wfsyst-initiator,
      previous_approval TYPE wcagn-pmsog,
      r_email_id TYPE pa0105-usrid_long,
      flag TYPE wcagns-geniakt,
      permit_txt TYPE wcspermit-gntxt,
            lt_approve_tab  TYPE TABLE OF wcagns,
      wa_approve_tab  TYPE wcagns,
      lv_objnr        TYPE j_objnr,
      lv_counter      TYPE i_count,
      lt_counters     TYPE TABLE OF i_count,
      lv_counters     TYPE i_count,
      lt_revoke_tab   TYPE TABLE OF wcagns,
      wa_revoke       TYPE wcagns,
      lt_permit       TYPE wctpc_permittab_type,
      wa_permit       TYPE wctpc_permitwa_type,
      lv_previous_permit TYPE pmsog,
        lv_index  TYPE i.
CONSTANTS: lc_check TYPE char1 VALUE 'X'.
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
swc_get_element container 'WCNR' wcnr.
swc_get_element container 'APPROVAL' approval.
IF wcnr IS NOT INITIAL.
  CALL FUNCTION 'ZWCA_GET_APPROVALS'
    EXPORTING
      wapinr   = wcnr
      wcd_flag = 'X'
    IMPORTING
      t_permit = lt_permit.

  LOOP AT lt_permit INTO wa_permit.
    IF wa_permit-pmsog = approval.
      lv_index = sy-tabix - 1.
    ENDIF.
  ENDLOOP.
  READ TABLE lt_permit INTO wa_permit INDEX lv_index.
  IF sy-subrc EQ 0.
    lv_previous_permit = wa_permit-pmsog.
    permit_txt   = wa_permit-gntxt.
  ENDIF.
* Get Object Number from WCM Application Data
  SELECT SINGLE objnr
       FROM wcahe
       INTO lv_objnr
       WHERE wcnr = wcnr.

* Check Application Exist or Not
  IF sy-subrc EQ 0.

* Get  Counter for differentiation from WCM Approvals
    SELECT SINGLE counter
      FROM wcagn
      INTO lv_counter
      WHERE objnr EQ lv_objnr AND
            pmsog EQ lv_previous_permit.

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

SELECT SINGLE pernr usrid usrid_long FROM pa0105
  INTO wa_emp_id
*    FOR ALL ENTRIES IN lt_user
  WHERE usrid = lv_user AND
        usrty = '0001'.

IF sy-subrc EQ 0.
  SELECT SINGLE usrid_long FROM pa0105
   INTO r_email_id
   WHERE pernr = wa_emp_id-pernr AND
         usrty = '0010'.
ENDIF.

swc_set_element container 'PREVIOUS_APPROVER' previous_approver.
swc_set_element container 'PREVIOUS_APPROVAL' previous_approval.
swc_set_element container 'R_EMAIL_ID' r_email_id.
swc_set_element container 'FLAG' flag.
swc_set_element container 'PERMIT_TXT' permit_txt.
end_method.

begin_method call_form changing container.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
DATA:
      wcnr TYPE wcahe-wcnr,
      approval TYPE wcagn-pmsog,
      spool_req TYPE tsp01-rqident,
      user_sel TYPE wfsyst-initiator OCCURS 0,
      appr_status TYPE wcagns-geniakt,
      appr_number TYPE wcagns-counter,
      next_approval TYPE wcagn-pmsog,
      revoke_text TYPE rdgprint-stadd1 OCCURS 0,
      user_approve TYPE wfsyst-initiator,
      work_itemid TYPE swwwihead-wi_id,
      t_email_id TYPE pa0105-usrid_long OCCURS 0,
      permit_txt TYPE wcspermit-gntxt,
      wapi_desc    TYPE wcaap-stxt,
      sms_uname  TYPE suid_st_bname-bname,
      sms_number TYPE threic_contact-mobile,  "#EC CI_USAGE_OK[3224334]
      loop_flag    TYPE wcagn-kzltx,
      lt_permit       TYPE wctpc_permittab_type,
      wa_permit       TYPE wctpc_permitwa_type,
      lt_text     TYPE lvc_t_htline,
      wa_user  TYPE wfsyst-initiator.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
swc_get_element container 'WCNR' wcnr.
swc_get_element container 'APPROVAL' approval.
swc_get_element container 'SPOOL_REQ' spool_req.
swc_get_element container 'SMS_NUMBER' sms_number.
swc_get_element container 'SMS_UNAME' sms_uname.
swc_get_element container 'WORK_ITEMID' work_itemid.
swc_get_element container 'PERMIT_TXT' permit_txt.
swc_get_element container 'WAPI_DESC' wapi_desc.
swc_get_element container 'LOOP_FLAG' loop_flag.


CALL FUNCTION 'ZWCM_FORM'
  EXPORTING
    im_spool       = spool_req
    im_permit      = approval
    im_appl        = wcnr
    im_wcd_flag    = 'X'
    im_work_itemid = work_itemid
    im_custom_prev = loop_flag
  IMPORTING
    ex_appr_status = appr_status
    ex_user_aprove = user_approve
    et_user        = user_sel
    ex_next_permit = next_approval
    et_text        = lt_text
    et_email_id    = t_email_id
  CHANGING
    ch_sms_uname   = sms_uname
    ch_sms_number  = sms_number.
revoke_text = lt_text.

LOOP AT user_sel INTO wa_user.
  CONCATENATE 'US' wa_user INTO wa_user.
  MODIFY user_sel FROM wa_user INDEX sy-tabix.

ENDLOOP.


DESCRIBE TABLE user_sel LINES appr_number.
CALL FUNCTION 'ZWCA_GET_APPROVALS'
  EXPORTING
    wapinr   = wcnr
    wcd_flag = 'X'
  IMPORTING
    t_permit = lt_permit.

READ TABLE lt_permit INTO wa_permit WITH KEY pmsog = next_approval.
IF sy-subrc EQ 0.
  permit_txt = wa_permit-gntxt.
ENDIF.
swc_set_table container 'REVOKE_TEXT' revoke_text.
swc_set_element container 'APPR_NUMBER' appr_number.
swc_set_table container 'USER_SEL' user_sel.
swc_set_element container 'APPR_STATUS' appr_status.
swc_set_element container 'NEXT_APPROVAL' next_approval.
swc_set_element container 'USER_APPROVE' user_approve.
swc_set_table container 'T_EMAIL_ID' t_email_id.
swc_set_element container 'SMS_UNAME'    sms_uname.
swc_set_element container 'SMS_NUMBER'    sms_number.
swc_set_element container 'PERMIT_TXT' permit_txt.
end_method.

begin_method send_approval_mail changing container.
DATA:
      permit TYPE wcagn-pmsog,
      wcd_docnum TYPE wcahe-wcnr,
      email_id TYPE pa0105-usrid_long OCCURS 0,
      revoke_flag TYPE wcagns-geniakt,
      revoke_text TYPE rdgprint-stadd1 OCCURS 0.
swc_get_element container 'PERMIT' permit.
swc_get_element container 'WCD_DOCNUM' wcd_docnum.
swc_get_table container 'EMAIL_ID' email_id.
swc_get_element container 'REVOKE_FLAG' revoke_flag.
swc_get_table container 'REVOKE_TEXT' revoke_text.

CALL FUNCTION 'ZWCM_SEND_MAIL'
  EXPORTING
    im_permit      = permit
    im_appl        = wcd_docnum
    it_email_id    = email_id
    it_revoke_text = revoke_text
    im_revoke_flag = revoke_flag.
end_method.
