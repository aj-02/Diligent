*--- MAIN PROGRAM: SAPMZMMPREPROLE3_PHASEII ---*
*&--------------------------------------------------------------------*
*& Module pool       SAPMZMMPREPROLE                                  *
*&--------------------------------------------------------------------*
*                                                                     *
* Title      : End User Authorisation                                 *
*                                                                     *
* FS No.     : FS-MM-AUTH-004 +++ Delta FS of other modules           *
*                                                                     *
* Author     : Ajit Singh             Date : 02/08/2006               *
*                                                                     *
* Login Id   : CAB_AJIT                                               *
*                                                                     *
* Description: End User Authorisation                                 *
*                                                                     *
* Tran. Code : ZIC_AUTH / ZIC_AUTH_REP                                *
*                                                                     *
***********************************************************************
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Change in include
*                                           MZMMPREPROLE3_PHASEIITOP.
*                                           MZMMPREPROLE3_PHASEIIF01.
* 18/12/2008  <<RD1K960611> SAB_PUNIT    1) Change in include
*                                           MZMMPREPROLE3_PHASEIIF01.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 79.

* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company              *
*                                           roles during approval )    *
*&                                                                     *
*&                                                                     *
************************************************************************

INCLUDE MZMMPREPROLE3_PHASEIITOP.

INCLUDE MZMMPREPROLE3_PHASEIIO01.
                   .
INCLUDE MZMMPREPROLE3_PHASEIII01.
                    .
INCLUDE MZMMPREPROLE3_PHASEIIF01.


AT USER-COMMAND.

case sy-ucomm.

    when 'SEL' .
      perform pick.
      leave list-processing.

    when 'SELALL' .
      perform tick_all.

    when 'DESELALL' .
      perform notick_all.

    when 'REQ1'.

      refresh : ist_seltab.
      clear   : seltab.
      data : l_ans.

      seltab-selname = 'P_REM1'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
      concatenate zic_prep_rolereq-docno ' - ARMS'
      ' - ' moduleid ' Module' into seltab-low.
      append seltab to ist_seltab.

      seltab-selname = 'P_REM2'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
      seltab-low     = moduleid.
      append seltab to ist_seltab.

      clear zrolereqno.

      set parameter id 'ZROLEREQNO' field ZROLEREQNO.

*Begin of <RD1K963151>.
      CLEAR zuserid.
      MOVE ZIC_PREP_ROLEREQ-USERIDCR TO ZUSERID.
      export ZUSERID to MEMORY id 'ID'.
      clear zapprover.
      move ZIC_PREP_ROLEREQ-USERIDAP to ZAPPROVER.
      EXPORT ZAPPROVER TO MEMORY ID 'ID1'.

*End of <RD1K963151>.

      submit ZHELPROLE1A_1 WITH SELECTION-TABLE ist_seltab and return.

      get parameter id 'ZROLEREQNO' field ZROLEREQNO.

      if not ZROLEREQNO is initial and ZROLEREQNO <> '00000000'.
        submit ZBC_ROLE_REP01_RFC and return.

        g_role_flag = 'X'.
        zic_prep_rolereq-status = 'IR'.
        perform save_request.
        if zic_prep_rolereq-status = 'IF' or
         zic_prep_rolereq-status = 'N'.
        else.
          perform send_sapmail.
        endif.
        perform clear.
        refresh object_content.
      endif.

      call transaction 'ZIC_AUTH_CORETEAM' and skip first screen.

  endcase.

*--- INCLUDE: %_CCNDD ---*
TYPE-POOL CNDD .
* Flavor is just a string. It could be any string that identifies
* a data object type. The flvor may be seen as something similar
* to a class name resp. mime type

TYPES :  CNDD_FLAVOR(40) TYPE C.
TYPES :  CNDD_FLAVORS TYPE CNDD_FLAVOR OCCURS 0.

* simple Propertybag type. A propertybag consist of a table that
* associates name to values.

TYPES :  CNDD_PROPNAME(40) TYPE C.        " Name of Property
TYPES :  CNDD_PROPREMOTEVALUE TYPE SWC_VALUE.  " Value of Remote
                                                " Automation PROPERTY
TYPES :  CNDD_PROPVALUE TYPE STRING.      " Value of property
TYPES :  BEGIN OF CNDD_PROP,
            PROPNAME  TYPE CNDD_PROPNAME,    " Property Name
            PROPVALUE TYPE CNDD_PROPVALUE,  " Property Value
         END OF CNDD_PROP.
* This structure is for transferring property bag through automation
* be carefull, the value is only 80 chars !
TYPES :  BEGIN OF CNDD_REMOTEPROP,
            PROPNAME  TYPE CNDD_PROPNAME,    " Property Name
            PROPVALUE TYPE CNDD_PROPREMOTEVALUE,  " Property Value
         END OF CNDD_REMOTEPROP.

TYPES : CNDD_REMOTEPROPS TYPE CNDD_REMOTEPROP OCCURS 0.
                                                " Table of Properties
TYPES : CNDD_HASHEDPROPS TYPE HASHED TABLE OF CNDD_PROP
                                 WITH UNIQUE KEY PROPNAME.
TYPES : CNDD_PROPS TYPE CNDD_HASHEDPROPS.

*--- INCLUDE: %_CCNTL ---*
TYPE-POOL CNTL .

* WARNING: Never(!) include references to Control framework here,
* i.e. CL_GUI_CFW, CL_GUI_OBJECT or classes using one of these

TYPES CNTL_TYPE(4).
*ypes cntl_clsid(30).                  "// see TOLE-APP ??  GL 3.8.97
TYPES CNTL_CLSID LIKE CNTLSTRLIS-NAME. "// 70 (see editor-line)
TYPES CNTL_METRIC(4).
TYPES CNTL_OBJ_TYPE(10).
TYPES: BEGIN OF CNTL_EVENT,
         EVENTID TYPE I,
         IS_SHELLEVENT TYPE C,
         IS_SYSTEMEVENT TYPE C,
         SHELLID        TYPE I,
       END OF CNTL_EVENT.

TYPES CNTL_EVENTS TYPE TABLE OF CNTL_EVENT.

TYPES: BEGIN OF CNTL_SIMPLE_EVENT,
         EVENTID TYPE I,
         APPL_EVENT TYPE C,
       END OF CNTL_SIMPLE_EVENT.

TYPES: CNTL_SIMPLE_EVENTS TYPE TABLE OF CNTL_SIMPLE_EVENT.

* Control-Types
CONSTANTS: CNTL_TYPE_TABCONTROL   TYPE CNTL_TYPE VALUE 'TABC'.
CONSTANTS: CNTL_TYPE_INTERACT     TYPE CNTL_TYPE VALUE 'IACT'.
CONSTANTS: CNTL_TYPE_TREE         TYPE CNTL_TYPE VALUE 'TREE'.
CONSTANTS: CNTL_TYPE_COMBOBOX     TYPE CNTL_TYPE VALUE 'COBX'.
CONSTANTS: CNTL_TYPE_RTF_EDIT     TYPE CNTL_TYPE VALUE 'RTFE'.
CONSTANTS: CNTL_TYPE_SOUND        TYPE CNTL_TYPE VALUE 'SOUN'.
CONSTANTS: CNTL_TYPE_BUSG         TYPE CNTL_TYPE VALUE 'BUSG'.
CONSTANTS: CNTL_TYPE_PORT         TYPE CNTL_TYPE VALUE 'PORT'.
CONSTANTS: CNTL_TYPE_OCX          TYPE CNTL_OBJ_TYPE VALUE 'OCX'.
CONSTANTS: CNTL_TYPE_NO_OCX       TYPE CNTL_OBJ_TYPE VALUE 'NO_OC'.

* Lifetime
CONSTANTS: CNTL_LIFETIME_DEFAULT     TYPE I VALUE 0.
CONSTANTS: CNTL_LIFETIME_DYNPRO      TYPE I VALUE 1.
CONSTANTS: CNTL_LIFETIME_IMODE       TYPE I VALUE 2.
CONSTANTS: CNTL_LIFETIME_TRANSACTION TYPE I VALUE 3.
CONSTANTS: CNTL_LIFETIME_SESSION     TYPE I VALUE 4.
* Other Constants
CONSTANTS: CNTL_METRIC_DYNPRO TYPE CNTL_METRIC VALUE 'DYNP'.

* Handle-Definition
TYPES: BEGIN OF CNTL_HANDLE,
         OBJ LIKE OBJ_RECORD,
         SHELLID TYPE I,
         PARENTID TYPE I,
         C_TYPE TYPE CNTL_TYPE,
         CLSID  TYPE CNTL_CLSID,
         ORIGIN LIKE SY-REPID,
         HANDLE_TYPE TYPE CNTL_OBJ_TYPE, "// 'OCX', 'NO_OCX'
         LIFETIME TYPE I,
         PROGRAM LIKE SY-REPID,
         DYNNR LIKE SY-DYNNR,
         IMODE TYPE I,
         DYNPRO_POS TYPE I,            " KS: Vorlaeufig
         GUID TYPE I,
       END OF CNTL_HANDLE.

* For interface definitions
TYPES: CNTL_HANDLE_TAB TYPE TABLE OF CNTL_HANDLE.

* constants: handle_type_ocx like cntl_handle-handle_type value 'OCX',
*       handle_type_no_ocx like cntl_handle-handle_type value 'NO_OCX'.

* Font-Properties
TYPES: BEGIN OF CNTL_FONT,
         INIT(1) TYPE C,
         F_TYPE  TYPE I,
         BOLD    TYPE I,
         ITALIC  TYPE I,
         SIZE    TYPE I,
       END OF CNTL_FONT.

* Default Constant for Font-Properties
CONSTANTS: BEGIN OF CNTL_FONT_DEFAULTS,
             INIT(1) TYPE C VALUE ' ',
             F_TYPE  TYPE I VALUE '-1',
             BOLD    TYPE I VALUE '-1',
             ITALIC  TYPE I VALUE '-1',
             SIZE    TYPE I VALUE '-1',
           END OF CNTL_FONT_DEFAULTS.


* Types and Constants for ComboBox-Control
CONSTANTS: CNTL_CB_ITEM_MAX_LENGTH TYPE I VALUE 80.

TYPES: CNTL_ITEM(CNTL_CB_ITEM_MAX_LENGTH).
TYPES: CNTL_ITEM_TAB TYPE CNTL_ITEM OCCURS 0.

* Types for CL_GUI_RESSOURCES                 (BRP, 2/99)
TYPES: BEGIN OF CNTL_COL_VALUE,
           ID        TYPE I,
           STATE     TYPE I,
           VALUE     TYPE I,
       END OF CNTL_COL_VALUE.
TYPES: CNTL_COL_VALUE_TAB TYPE CNTL_COL_VALUE OCCURS 0.
* Eventparameter im DIAG r.h 03.05.99
TYPES: BEGIN OF CNTL_EVENT_PARAM,
         PID TYPE I,                   "Index of Event
         VALUE TYPE STRING,            "Value of Parameter
       END OF CNTL_EVENT_PARAM.
TYPES: CNTL_EVENT_PARAM_TAB TYPE SORTED TABLE OF CNTL_EVENT_PARAM
                                 WITH UNIQUE KEY PID.

* Struktur für Metrik-Umrechnungsfaktoren
TYPES: begin of cntl_m_factors,
         x type i,
         y type i,
       end   of cntl_m_factors,
       begin of cntl_metric_factors,
         version type i,
         char          type cntl_m_factors,
         char_complete type cntl_m_factors,
         dm            type cntl_m_factors,
         screen        type cntl_m_factors,
       end   of  cntl_metric_factors.
* Typ für Frontend-Farben
TYPES: begin of cntl_1_color,
         index type i,          " redundant
         rgb   type i,          " the value
       end   of cntl_1_color,
       cntl_colors type standard table of cntl_1_color.
* Typ für List-Dimension
types: begin of cntl_list_dim,
         x type i,
         y type i,
       end   of cntl_list_dim.

* Structure for CL_GUI_DYNPRO_COMPANION (which is free of framework
* references)
types: cntl_dynpro_companions
       type standard table of ref to cl_gui_dynpro_companion.

*--- INCLUDE: CL_GUI_DYNPRO_COMPANION=======CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_GUI_DYNPRO_COMPANION and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: %_CCNTO ---*
TYPE-POOL CNTO .

*CLASS CL_GUI_CONTROL DEFINITION DEFERRED PUBLIC.
TYPES CNTO_CONTROL_LIST TYPE REF TO CL_GUI_CONTROL OCCURS 0.

* Type for lifetime description of a control
types: begin of cnto_lifetime_info,
    LIFETIME TYPE I,
    DYNPRO_PROGRAM TYPE SYREPID,
    DYNPRO_NR TYPE SYDYNNR,
    STACKLEVEL TYPE I,
    IS_CONTAINER,
    INVISIBLE,
    TOP_PARENTID TYPE I,
       end of cnto_lifetime_info.

*--- INCLUDE: CL_GUI_CONTROL================CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_GUI_CONTROL and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: %_CCXTAB ---*
TYPE-POOL CXTAB .

TYPES:
       CXTAB_COLUMN type scxtab_column,
       CXTAB_CONTROL type scxtab_control,
       CXTAB_TABSTRIP type scxtab_tabstrip.

*--- INCLUDE: %_COLE2 ---*
TYPE-POOL OLE2 .


TYPES:
  OLE2_OBJECT LIKE   OBJ_RECORD.
*    Object handle initialization
CONSTANTS:
  OLE2_OBJECT_HEADER TYPE OLE2_OBJECT-HEADER VALUE 'OBJH',
  OLE2_OBJECT_TYPE   TYPE OLE2_OBJECT-TYPE   VALUE 'OLE2',
  OLE2_OBJECT_HANDLE TYPE OLE2_OBJECT-HANDLE VALUE -1,
  BEGIN OF OLE2_OBJECT_INITIAL,
    HEADER   TYPE OLE2_OBJECT-HEADER    VALUE OLE2_OBJECT_HEADER,
    TYPE     TYPE OLE2_OBJECT-TYPE      VALUE OLE2_OBJECT_TYPE,
    HANDLE   TYPE OLE2_OBJECT-HANDLE    VALUE OLE2_OBJECT_HANDLE,
    CB_INDEX TYPE OLE2_OBJECT-CB_INDEX  VALUE SPACE,
    CLSID    TYPE OLE2_OBJECT-CLSID     VALUE SPACE,
  END OF OLE2_OBJECT_INITIAL.

CONSTANTS: OLE2_%_POINTER POINTER.
TYPES: BEGIN OF OLE2_PCB,
       PCBID TYPE I,
       DATACB LIKE OLE2_%_POINTER,
       END OF OLE2_PCB.

TYPES BEGIN OF OLE2_METH_PARMS.
  INCLUDE STRUCTURE SWCONT.
  TYPES POINTER TYPE OLE2_PCB.
TYPES END OF   OLE2_METH_PARMS.

TYPES:
  OLE2_METH_PARMS_TAB TYPE OLE2_METH_PARMS OCCURS 0,
*    Method Parameter Table: contains the methoid parameter
*      types and values exporting and importing parameters.
  OLE2_LCID TYPE I,
*    Locale Id: determines the language and other settings
*      (like value formats) of the automation server.
*      For more information see: Include OLE2LCID
  OLE2_TYPE TYPE I.
*    OLE Variant Type: determines the "variant type" for the
*      parameters of Automation Controller requests.
*      For more information see: Include OLE2TYPE

TYPES: OLE2_PARAMETER LIKE SWCBCONT-VALUE.

*--- INCLUDE: %_CTXTED ---*
TYPE-POOL TXTED.

TYPES:
**** The string type defined here is only necessary due to
****  strong typ definition demanded by recent ABAP OO Implementation
****  within the public section.
****  Generic string types are refused already by the syntax check
****  (which is also the case for tables!!!)
* string for searching and replacing
      TXTED_STRING(256).

*--- INCLUDE: CL_CTMENU=====================CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_CTMENU and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_DRAGDROP===================CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_DRAGDROP and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_DRAGDROPOBJECT=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_DRAGDROPOBJECT and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_GUI_CONTAINER==============CU ---*
class CL_GUI_CONTAINER definition
  public
  inheriting from CL_GUI_CONTROL
  create public .

*"* public components of class CL_GUI_CONTAINER
*"* do not include other source files here!!!
public section.

  class-data DEFAULT_SCREEN type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN0 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN1 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN2 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN3 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN4 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN5 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN6 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN7 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN8 type ref to CL_GUI_CONTAINER read-only .
  class-data SCREEN9 type ref to CL_GUI_CONTAINER read-only .
  class-data DESKTOP type ref to CL_GUI_CONTAINER read-only .
  type-pools CNTO .
  data CHILDREN type CNTO_CONTROL_LIST read-only .
  constants CONTAINER_TYPE_SIMPLE type I value 1. "#EC NOTEXT
  constants CONTAINER_TYPE_CUSTOM type I value 2. "#EC NOTEXT
  constants CONTAINER_TYPE_DOCKING type I value 3. "#EC NOTEXT
  constants CONTAINER_TYPE_EASY_SPLITTER type I value 4. "#EC NOTEXT
  constants CONTAINER_TYPE_SPLITTER type I value 5. "#EC NOTEXT
  constants CONTAINER_TYPE_DIALOGBOX type I value 6. "#EC NOTEXT

  methods GET_CONTAINER_TYPE
    returning
      value(CONTAINER_TYPE) type I .
  class-methods CLASS_CONSTRUCTOR .
  class-methods RESIZE .
  methods GET_INNER_WIDTH
    exporting
      !INNER_WIDTH type I
    exceptions
      CNTL_ERROR .
  methods LINK
    importing
      value(REPID) type SYREPID optional
      value(DYNNR) type SYDYNNR optional
      value(CONTAINER) type C optional
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK .
  methods CONSTRUCTOR
    importing
      value(CLSID) type C
      value(PARENT) type ref to CL_GUI_CONTAINER optional
      value(STYLE) type I optional
      value(DYNNR) type SYDYNNR optional
      value(REPID) type SYREPID optional
      value(CONTAINER_NAME) type C optional
      value(LIFETIME) type I default lifetime_default
      value(AUTOALIGN) type C optional
      value(NO_AUTODEF_PROGID_DYNNR) type C optional
      value(NAME) type STRING optional
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR
      CREATE_ERROR
      LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK
      LIFETIME_DYNPRO_ILLEGAL_PARENT .
  methods GET_LINK_INFO
    returning
      value(LINK_INFO) type CFW_LINK .
  methods GET_INNER_HEIGHT
    exporting
      !INNER_HEIGHT type I
    exceptions
      CNTL_ERROR .
  methods SET_MODE_FOR_ALL
    importing
      value(MODE) type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .

  methods FINALIZE
    redefinition .
  methods FREE
    redefinition .

*--- INCLUDE: CL_GUI_CONTROL================CU ---*
class CL_GUI_CONTROL definition
  public
  inheriting from CL_GUI_OBJECT
  create public .

*"* public components of class CL_GUI_CONTROL
*"* do not include other source files here!!!
*"* protected components of class CL_GUI_CONTROL
*"* do not include other source files here!!!
public section.

  constants ADUST_DESIGN_FALSE type I value 0. "#EC NOTEXT
  constants ADUST_DESIGN_TRUE type I value 1. "#EC NOTEXT
  constants ALIGN_AT_BOTTOM type I value 8. "#EC NOTEXT
  constants ALIGN_AT_LEFT type I value 1. "#EC NOTEXT
  constants ALIGN_AT_RIGHT type I value 2. "#EC NOTEXT
  constants ALIGN_AT_TOP type I value 4. "#EC NOTEXT
  constants LIFETIME_DEFAULT type I value 0. "#EC NOTEXT
  constants LIFETIME_DYNPRO type I value 1. "#EC NOTEXT
  constants LIFETIME_IMODE type I value 2. "#EC NOTEXT
  constants METRIC_DEFAULT type I value 0. "#EC NOTEXT
  constants METRIC_MM type I value 2. "#EC NOTEXT
  constants METRIC_PIXEL type I value 1. "#EC NOTEXT
  constants MODE_DESIGN type I value 1. "#EC NOTEXT
  constants MODE_RUN type I value 0. "#EC NOTEXT
  constants PROPERTY_METRIC type I value 410. "#EC NOTEXT
  constants STATE_ALIVE type I value 0. "#EC NOTEXT
  constants STATE_ALIVE_ON_OTHER_SCREEN type I value 1. "#EC NOTEXT
  constants STATE_DEAD type I value -1. "#EC NOTEXT
  constants VISIBLE_FALSE type CHAR1 value '0'. "#EC NOTEXT
  constants VISIBLE_TRUE type CHAR1 value '1'. "#EC NOTEXT
  constants WS_BORDER type I value 8388608. "#EC NOTEXT
  constants WS_CHILD type I value 1073741824. "#EC NOTEXT
  constants WS_CLIPCHILDREN type I value 33554432. "#EC NOTEXT
  constants WS_CLIPSIBLINGS type I value 67108864. "#EC NOTEXT
  constants WS_MAXIMIZEBOX type I value  65536. "#EC NOTEXT
  constants WS_MINIMIZEBOX type I value  131072. "#EC NOTEXT
  constants WS_SYSMENU type I value 524288. "#EC NOTEXT
  constants WS_THICKFRAME type I value  262144. "#EC NOTEXT
  constants WS_VISIBLE type I value 268435456. "#EC NOTEXT
  class-data CUR_EVENT type ref to CL_GUI_EVENT .
  class-data PROPERTY_TABSTOP type I read-only value 240. "#EC NOTEXT
  data LIFETIME type I read-only value cntl_lifetime_imode. "#EC NOTEXT
  data PARENT type ref to CL_GUI_CONTAINER read-only .

  events RIGHT_CLICK .
  events LEFT_CLICK_DESIGN .
  events MOVE_CONTROL .
  events SIZE_CONTROL .
  events LEFT_CLICK_RUN .

  class-methods GET_FOCUS
    exporting
      !CONTROL type ref to CL_GUI_CONTROL
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  class-methods SET_FOCUS
    importing
      !CONTROL type ref to CL_GUI_CONTROL
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_NAME
    importing
      value(NAME) type STRING
    exceptions
      CNTL_ERROR
      PARENT_NO_NAME
      ILLEGAL_NAME .
  methods GET_NAME
    returning
      value(NAME) type STRING .
  methods GET_ENABLE
    exporting
      !ENABLE type C
    exceptions
      CNTL_ERROR .
  methods SET_ENABLE
    importing
      !ENABLE type C
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods CONSTRUCTOR
    importing
      value(CLSID) type C optional
      value(LIFETIME) type I default lifetime_default
      value(SHELLSTYLE) type I optional
      value(PARENT) type ref to CL_GUI_OBJECT optional
      value(AUTOALIGN) type C default 'x'
      value(LICENSEKEY) type C optional
      value(NAME) type STRING optional
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR
      CREATE_ERROR
      LIFETIME_ERROR
      PARENT_IS_SPLITTER .
  methods DISPATCH
    importing
      value(CARGO) type SYUCOMM
      value(EVENTID) type I
      value(IS_SHELLEVENT) type CHAR1
      value(IS_SYSTEMDISPATCH) type CHAR1 optional
    exceptions
      CNTL_ERROR .
  methods FINALIZE .
  methods GET_ADJUST_DESIGN
    exporting
      !ADJUST_DESIGN type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods GET_GRID_HANDLE
    exporting
      !GRID_HANDLE type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods GET_GRID_STEP
    exporting
      !GRID_STEP type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods GET_HEIGHT
    exporting
      !HEIGHT type I
    exceptions
      CNTL_ERROR .
  methods GET_LEFT
    exporting
      !LEFT type I
    exceptions
      CNTL_ERROR .
  methods GET_METRIC
    exporting
      !METRIC type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods GET_MODE
    exporting
      !MODE type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods GET_REGISTERED_EVENTS
    exporting
      !EVENTS type CNTL_SIMPLE_EVENTS
    exceptions
      CNTL_ERROR .
  methods GET_TOP
    exporting
      !TOP type I
    exceptions
      CNTL_ERROR .
  methods GET_VISIBLE
    exporting
      !VISIBLE type C
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods GET_WIDTH
    exporting
      !WIDTH type I
    exceptions
      CNTL_ERROR .
  methods IS_ALIVE
    returning
      value(STATE) type I .
  methods REG_EVENT_LEFT_CLICK_DESIGN
    importing
      !REGISTER type I default 1
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REG_EVENT_LEFT_CLICK_RUN_MODE
    importing
      !REGISTER type I default 1
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REG_EVENT_MOVE_CONTROL
    importing
      !REGISTER type I default 1
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REG_EVENT_RIGHT_CLICK
    importing
      !REGISTER type I default 1
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REG_EVENT_SIZE_CONTROL
    importing
      !REGISTER type I default 1
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods SET_ADJUST_DESIGN
    importing
      value(ADJUST_DESIGN) type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_ALIGNMENT
    importing
      !ALIGNMENT type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_GRID_HANDLE
    importing
      value(GRID_HANDLE) type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_GRID_STEP
    importing
      value(GRID_STEP) type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_HEIGHT
    importing
      !HEIGHT type I
    exceptions
      CNTL_ERROR .
  methods SET_LEFT
    importing
      !LEFT type I
    exceptions
      CNTL_ERROR .
  methods SET_METRIC
    importing
      value(METRIC) type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_MODE
    importing
      value(MODE) type I
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_POSITION
    importing
      value(HEIGHT) type I optional
      value(LEFT) type I optional
      value(TOP) type I optional
      value(WIDTH) type I optional
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_REGISTERED_EVENTS
    importing
      !EVENTS type CNTL_SIMPLE_EVENTS
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR
      ILLEGAL_EVENT_COMBINATION .
  methods SET_TOP
    importing
      !TOP type I
    exceptions
      CNTL_ERROR .
  methods SET_VISIBLE
    importing
      value(VISIBLE) type C
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  methods SET_WIDTH
    importing
      !WIDTH type I
    exceptions
      CNTL_ERROR .
  methods GET_PATH
    returning
      value(PATH) type STRING .
  methods GET_ACCDESCRIPTION
    exporting
      !ACCDESCRIPTION type STRING
    exceptions
      CNTL_ERROR .
  methods SET_ACCDESCRIPTION
    importing
      !ACCDESCRIPTION type STRING
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .

  methods FREE
    redefinition .

*--- INCLUDE: CL_GUI_CUSTOM_CONTAINER=======CU ---*
class CL_GUI_CUSTOM_CONTAINER definition
  public
  inheriting from CL_GUI_CONTAINER
  create public .

*"* public components of class CL_GUI_CUSTOM_CONTAINER
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      value(PARENT) type ref to CL_GUI_CONTAINER optional
      value(CONTAINER_NAME) type C
      value(STYLE) type I optional
      value(LIFETIME) type I default LIFETIME_DEFAULT
      value(REPID) type SYREPID optional
      value(DYNNR) type SYDYNNR optional
      value(NO_AUTODEF_PROGID_DYNNR) type C optional
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR
      CREATE_ERROR
      LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK .

  methods GET_HEIGHT
    redefinition .
  methods GET_WIDTH
    redefinition .
  methods LINK
    redefinition .
  methods SET_NAME
    redefinition .

*--- INCLUDE: CL_GUI_EASY_SPLITTER_CONTAINERCU ---*
class CL_GUI_EASY_SPLITTER_CONTAINER definition
  public
  inheriting from CL_GUI_CONTAINER
  create public .

*"* public components of class CL_GUI_EASY_SPLITTER_CONTAINER
*"* do not include other source files here!!!
public section.

  class-data ORIENTATION_HORIZONTAL type I value 1 read-only .
  class-data ORIENTATION_VERTICAL type I value 0 read-only .
  data TOP_LEFT_CONTAINER type ref to CL_GUI_CONTAINER read-only .
  data BOTTOM_RIGHT_CONTAINER type ref to CL_GUI_CONTAINER read-only .
  data PANE_ORIENTATION type I read-only .

  methods GET_SASH_POSITION
    exporting
      !SASH_POSITION type I
    exceptions
      CNTL_SYSTEM_ERROR
      CNTL_ERROR .
  methods SET_SASH_POSITION
    importing
      value(SASH_POSITION) type I .
  type-pools CNTL .
  methods CONSTRUCTOR
    importing
      value(LINK_DYNNR) type SY-DYNNR optional
      value(LINK_REPID) type SY-REPID optional
      value(METRIC) type CNTL_METRIC default CNTL_METRIC_DYNPRO
      value(PARENT) type ref to CL_GUI_CONTAINER optional
      value(ORIENTATION) type I default 0
      value(SASH_POSITION) type I default 50
      value(WITH_BORDER) type I default 1
      value(NAME) type STRING optional
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .

*--- INCLUDE: CL_GUI_EVENT==================CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_GUI_EVENT and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_GUI_OBJECT=================CU ---*
class CL_GUI_OBJECT definition
  public
  create public .

*"* public components of class CL_GUI_OBJECT
*"* do not include other source files here!!!
public section.

  interfaces IF_CACHED_PROP .

  class-data ACTIVEX type CHAR01 read-only .
  class-data CATT_ACTIV type CHAR01 read-only .
  class-data GUI_IS_RUNNING type CHAR01 read-only .
  type-pools OLE2 .
  class-data H_GUI type OLE2_OBJECT read-only .
  class-data IS_INIT type CHAR1 read-only .
  class-data JAVABEAN type CHAR01 read-only .
  class-data WWW_ACTIVE type CHAR01 read-only .

  class-methods CLASS_CONSTRUCTOR .
  methods IS_VALID
    exporting
      value(RESULT) type I .
  methods CONSTRUCTOR
    importing
      value(CLSID) type C optional
      value(LIFETIME) type I optional
    exceptions
      CREATE_ERROR
      LIFETIME_ERROR .
  methods FREE
    exceptions
      CNTL_ERROR
      CNTL_SYSTEM_ERROR .
  type-pools CNTL .

*--- INCLUDE: CL_GUI_TEXTEDIT===============CU ---*
class CL_GUI_TEXTEDIT definition
  public
  inheriting from CL_GUI_CONTROL
  create public .

*"* public components of class CL_GUI_TEXTEDIT
*"* do not include other source files here!!!
public section.

  interfaces IF_DRAGDROP .

  type-pools TXTED .
  constants ABAP_COMMENTLINE_IDENTIFIER type TXTED_STRING value '*'. "#EC NOTEXT
  constants BOOL_INITIAL type I value -1. "#EC NOTEXT
  constants DROPFILE_EVENT_MULTIPLE type I value 2. "#EC NOTEXT
  constants DROPFILE_EVENT_OFF type I value 0. "#EC NOTEXT
  constants DROPFILE_EVENT_SINGLE type I value 1. "#EC NOTEXT
  constants EVENT_CONTEXT_MENU type I value 5. "#EC NOTEXT
  constants EVENT_CONTEXT_MENU_SELECTED type I value 6. "#EC NOTEXT
  constants EVENT_DOUBLE_CLICK type I value -601. "#EC NOTEXT
  constants EVENT_F1 type I value 3. "#EC NOTEXT
  constants EVENT_F4 type I value 4. "#EC NOTEXT
  constants EVENT_MULTIPLEFILESDROPPED type I value 2. "#EC NOTEXT
  constants EVENT_SINGLEFILEDROPPED type I value 1. "#EC NOTEXT
  constants FALSE type I value 0. "#EC NOTEXT
  constants STRING_LENGTH type I value 256. "#EC NOTEXT
  constants TEXT_ABAP type I value 1. "#EC NOTEXT
  constants TEXT_STANDARD type I value 0. "#EC NOTEXT
  constants TRUE type I value 1. "#EC NOTEXT
  constants WORDWRAP_AT_FIXED_POSITION type I value 2. "#EC NOTEXT
  constants WORDWRAP_AT_WINDOWBORDER type I value 1. "#EC NOTEXT
  constants WORDWRAP_OFF type I value 0. "#EC NOTEXT
  data M_AUTOREDRAW_REFCOUNTER type I value 0 read-only .
  data M_AUTO_INDENT type I value FALSE read-only .
  data M_COMMENTS_STRING type TXTED_STRING read-only .
  data M_FILEDROP_MODE type I value DROPFILE_EVENT_OFF read-only .
  data M_HIGHLIGHT_BREAKPOINTS_MODE type I value FALSE read-only .
  data M_HIGHLIGHT_COMMENTS_MODE type I value FALSE read-only .
  data M_LOCAL_CONTEXTMENU_MODE type I value TRUE read-only .
  data M_READONLY_MODE type I value FALSE read-only .
  data M_SPACES_ON_INDENT type I value 2 read-only .
  data M_STATUSBAR_MODE type I value TRUE read-only .
  data M_STATUS_TEXT type TXTED_STRING value '' read-only .
  data M_TOOLBAR_MODE type I value TRUE read-only .
  data M_WORDBREAK_PROCEDURE type I value TEXT_STANDARD read-only .
  data M_WORDWRAP_MODE type I value WORDWRAP_AT_WINDOWBORDER read-only .
  data M_WORDWRAP_POSITION type I read-only .
  data M_WORDWRAP_TO_LINEBREAK_MODE type I value FALSE read-only .
  data M_NAVIGATE_ON_DBLCLICK type I value FALSE read-only .
  data M_FONT_FIXED type I value FALSE read-only .

  events ON_DROP
    exporting
      value(INDEX) type I
      value(LINE) type I
      value(POS) type I
      value(DRAGDROP_OBJECT) type ref to CL_DRAGDROPOBJECT .
  events DBLCLICK .
  events FILEDROP .
  events F1 .
  events F4 .
  events CONTEXT_MENU
    exporting
      value(MENU) type ref to CL_CTMENU .
  events CONTEXT_MENU_SELECTED
    exporting
      value(FCODE) type C .
  type-pools CNDD .
  events ON_GET_FLAVOR
    exporting
      value(INDEX) type I
      value(LINE) type I
      value(POS) type I
      value(DRAGDROP_OBJECT) type ref to CL_DRAGDROPOBJECT
      value(FLAVORS) type CNDD_FLAVORS .
  events ON_DRAG
    exporting
      value(FROM_INDEX) type I
      value(FROM_LINE) type I
      value(FROM_POS) type I
      value(DRAGDROP_OBJECT) type ref to CL_DRAGDROPOBJECT
      value(TO_INDEX) type I
      value(TO_LINE) type I
      value(TO_POS) type I .
  events ON_DROP_COMPLETE
    exporting
      value(FROM_INDEX) type I
      value(FROM_LINE) type I
      value(FROM_POS) type I
      value(DRAGDROP_OBJECT) type ref to CL_DRAGDROPOBJECT
      value(TO_INDEX) type I
      value(TO_LINE) type I
      value(TO_POS) type I .

  class-methods CLASS_CONSTRUCTOR .
  methods AUTO_REDRAW
    importing
      !ENABLE_REDRAW type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods COMMENT_LINES
    importing
      !FROM_LINE type I
      !TO_LINE type I optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods COMMENT_SELECTION
    importing
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods CONSTRUCTOR
    importing
      !MAX_NUMBER_CHARS type I optional
      value(STYLE) type I default 0
      !WORDWRAP_MODE type I default WORDWRAP_AT_WINDOWBORDER
      !WORDWRAP_POSITION type I default -1
      !WORDWRAP_TO_LINEBREAK_MODE type I default FALSE
      !FILEDROP_MODE type I default DROPFILE_EVENT_OFF
      value(PARENT) type ref to CL_GUI_CONTAINER
      value(LIFETIME) type I optional
      value(NAME) type STRING optional
    exceptions
      ERROR_CNTL_CREATE
      ERROR_CNTL_INIT
      ERROR_CNTL_LINK
      ERROR_DP_CREATE
      GUI_TYPE_NOT_SUPPORTED .
  methods DELETE_TEXT
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods EMPTY_UNDO_BUFFER
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods FIND_AND_REPLACE
    importing
      !CASE_SENSITIVE_MODE type I default FALSE
      !REPLACE_STRING type C
      !SEARCH_STRING type C
      !WHOLE_WORD_MODE type I default FALSE
    changing
      !STRING_FOUND type I optional
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods FIND_AND_SELECT_TEXT
    importing
      !CASE_SENSITIVE_MODE type I default FALSE
      !SEARCH_STRING type C
      !WHOLE_WORD_MODE type I default FALSE
    changing
      !STRING_FOUND type I optional
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods GET_FIRST_VISIBLE_LINE
    exporting
      !LINE type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_LAST_VISIBLE_LINE
    exporting
      !LINE type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_LINE_COUNT
    exporting
      !LINES type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_LINE_TEXT
    importing
      !LINE_NUMBER type I
    exporting
      !TEXT type C
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_PATH_OF_DROPPED_FILES
    exporting
      !TABLE type STANDARD TABLE
    exceptions
      ERROR_DP .
  methods GET_SELECTED_TEXTSTREAM
    exporting
      !SELECTED_TEXT type STRING
    exceptions
      ERROR_CNTL_CALL_METHOD
      NOT_SUPPORTED_BY_GUI .
  methods GET_SELECTED_TEXT_AS_R3TABLE
    exporting
      !TABLE type STANDARD TABLE
    exceptions
      ERROR_DP
      POTENTIAL_DATA_LOSS .
  methods GET_SELECTED_TEXT_AS_STREAM
    exporting
      !SELECTED_TEXT type STANDARD TABLE
    exceptions
      ERROR_DP .
  methods GET_SELECTION_INDEXES
    exporting
      !FROM_INDEX type I
      !TO_INDEX type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_SELECTION_POS
    exporting
      !FROM_LINE type I
      !FROM_POS type I
      !TO_LINE type I
      !TO_POS type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_TEXTMODIFIED_STATUS
    exporting
      !STATUS type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_TEXTSTREAM
    importing
      !ONLY_WHEN_MODIFIED type I default FALSE
    exporting
      !TEXT type STRING
      !IS_MODIFIED type I
    exceptions
      ERROR_CNTL_CALL_METHOD
      NOT_SUPPORTED_BY_GUI .
  methods GET_TEXT_AS_R3TABLE
    importing
      !ONLY_WHEN_MODIFIED type I default FALSE
    exporting
      !TABLE type STANDARD TABLE
      !IS_MODIFIED type I
    exceptions
      ERROR_DP
      ERROR_CNTL_CALL_METHOD
      ERROR_DP_CREATE
      POTENTIAL_DATA_LOSS .
  methods GET_TEXT_AS_STREAM
    importing
      !ONLY_WHEN_MODIFIED type I default FALSE
    exporting
      !TEXT type STANDARD TABLE
      !IS_MODIFIED type I
    exceptions
      ERROR_DP
      ERROR_CNTL_CALL_METHOD .
  methods GET_UNPROTECTED_PARTS_COUNT
    exporting
      !PARTS type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_UNPROTECTED_PART_INDEXES
    importing
      !PART type I
    exporting
      !FROM_INDEX type I
      !TO_INDEX type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GET_UNPROTECTED_PART_POS
    importing
      !PART type I
    exporting
      !FROM_LINE type I
      !FROM_POS type I
      !TO_LINE type I
      !TO_POS type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods GO_TO_LINE
    importing
      !LINE type I default 1
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods HIGHLIGHT_BREAKPOINT_LINE
    importing
      !LINE type I
      !HIGHLIGHT_MODE type I default TRUE
    exceptions
      HAS_NO_EFFECT
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods HIGHLIGHT_LINES
    importing
      !FROM_LINE type I
      !HIGHLIGHT_MODE type I default TRUE
      !TO_LINE type I optional
    exceptions
      HAS_NO_EFFECT
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods HIGHLIGHT_SELECTION
    importing
      !HIGHLIGHT_MODE type I default TRUE
    exceptions
      HAS_NO_EFFECT
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods INDENT_LINES
    importing
      !FROM_LINE type I
      !TO_LINE type I optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods INDENT_SELECTION
    importing
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods IS_PART_OF_PROTECTED_INDEXES
    importing
      !FROM_INDEX type I
      !TO_INDEX type I
    exporting
      !PROTECTED type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods IS_PART_OF_PROTECTED_POS
    importing
      !FROM_LINE type I
      !FROM_POS type I default 0
      !TO_LINE type I optional
      !TO_POS type I default 0
    exporting
      !PROTECTED type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods MAKE_SELECTION_VISIBLE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods OPEN_LOCAL_FILE
    importing
      !FILE_NAME type C optional
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods PROTECT_LINES
    importing
      !FROM_LINE type I
      !PROTECT_MODE type I default TRUE
      !TO_LINE type I optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods PROTECT_SELECTION
    importing
      !PROTECT_MODE type I default TRUE
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  type-pools CNTL .
  methods REGISTER_EVENT_CONTEXT_MENU
    importing
      !REGISTER type I default TRUE
      !APPL_EVENT type CNTL_SIMPLE_EVENT-APPL_EVENT default SPACE
      !LOCAL_ENTRIES type I default TRUE
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REGISTER_EVENT_DBLCLICK
    importing
      !REGISTER type I default TRUE
      !APPL_EVENT type CNTL_SIMPLE_EVENT-APPL_EVENT default SPACE
      !NAVIGATE_ON_DBLCLICK type I default FALSE
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REGISTER_EVENT_F1
    importing
      !REGISTER type I default TRUE
      !APPL_EVENT type CNTL_SIMPLE_EVENT-APPL_EVENT default SPACE
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REGISTER_EVENT_F4
    importing
      !REGISTER type I default TRUE
      !APPL_EVENT type CNTL_SIMPLE_EVENT-APPL_EVENT default SPACE
    exceptions
      ERROR_REGIST_EVENT
      ERROR_UNREGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REGISTER_EVENT_FILEDROP
    importing
      !REGISTER type I default TRUE
      !APPL_EVENT type CNTL_SIMPLE_EVENT-APPL_EVENT default SPACE
    exceptions
      ERROR_UNREGIST_EVENT
      ERROR_REGIST_EVENT
      CNTL_ERROR
      EVENT_ALREADY_REGISTERED
      EVENT_NOT_REGISTERED .
  methods REPLACE_ALL
    importing
      !CASE_SENSITIVE_MODE type I default FALSE
      !REPLACE_STRING type C
      !SEARCH_STRING type C
      !WHOLE_WORD_MODE type I default FALSE
    changing
      !COUNTER type I optional
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SAVE_AS_LOCAL_FILE
    importing
      !FILE_NAME type C optional
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SELECT_LINES
    importing
      !FROM_LINE type I default 1
      !TO_LINE type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_AUTOINDENT_MODE
    importing
      !AUTO_INDENT type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_COMMENTS_STRING
    importing
      !COMMENTS_STRING type C default ABAP_COMMENTLINE_IDENTIFIER
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_DRAGDROP
    importing
      !DRAGDROP type ref to CL_DRAGDROP .
  methods SET_FILEDROP_MODE
    importing
      !FILEDROP_MODE type I default DROPFILE_EVENT_OFF
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_FIRST_VISIBLE_LINE
    importing
      !LINE type I default 1
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_FONT_FIXED
    importing
      !MODE type I default TRUE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_HIGHLIGHT_BREAKPOINTS_MODE
    importing
      !HIGHLIGHT_BREAKPOINTS_MODE type I default TRUE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_HIGHLIGHT_COMMENTS_MODE
    importing
      !HIGHLIGHT_COMMENTS_MODE type I default TRUE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_LAST_VISIBLE_LINE
    importing
      !LINE type I default 10000000
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_LOCAL_CONTEXTMENU_MODE
    importing
      !VISIBLE type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_NAVIGATE_ON_DBLCLICK
    importing
      !NAVIGATE_ON_DBLCLICK_MODE type I default TRUE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_READONLY_MODE
    importing
      !READONLY_MODE type I default TRUE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_SELECTED_TEXT_AS_R3TABLE
    importing
      !TABLE type STANDARD TABLE optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_DP
      ERROR_DP_CREATE .
  methods SET_SELECTED_TEXT_AS_STREAM
    importing
      !SELECTED_TEXT type STANDARD TABLE optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_DP
      ERROR_DP_CREATE .
  methods SET_SELECTION_INDEXES
    importing
      !FROM_INDEX type I
      !TO_INDEX type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_SELECTION_POS
    importing
      !FROM_LINE type I
      !FROM_POS type I default 0
      !TO_LINE type I optional
      !TO_POS type I default 0
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_SELECTION_POS_IN_LINE
    importing
      !LINE type I
      !POS type I default 0
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_SPACES_ON_INDENT
    importing
      !NUMBER_OF_SPACES type I default 2
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_STATUSBAR_MODE
    importing
      !STATUSBAR_MODE type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_STATUS_TEXT
    importing
      !STATUS_TEXT type C
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_TEXTMODIFIED_STATUS
    importing
      !STATUS type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_TEXTSTREAM
    importing
      !TEXT type STRING optional
    exceptions
      ERROR_CNTL_CALL_METHOD
      NOT_SUPPORTED_BY_GUI .
  methods SET_TEXT_AS_R3TABLE
    importing
      !TABLE type STANDARD TABLE optional
    exceptions
      ERROR_DP
      ERROR_DP_CREATE .
  methods SET_TEXT_AS_STREAM
    importing
      !TEXT type STANDARD TABLE optional
    exceptions
      ERROR_DP
      ERROR_DP_CREATE .
  methods SET_TOOLBAR_MODE
    importing
      !TOOLBAR_MODE type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD
      INVALID_PARAMETER .
  methods SET_WORDBREAK_PROCEDURE
    importing
      !TEXT_TYPE type I
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_WORDWRAP_BEHAVIOR
    importing
      !WORDWRAP_MODE type I default -1
      !WORDWRAP_POSITION type I default -1
      !WORDWRAP_TO_LINEBREAK_MODE type I default BOOL_INITIAL
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods UNCOMMENT_LINES
    importing
      !FROM_LINE type I
      !TO_LINE type I optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods UNCOMMENT_SELECTION
    importing
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods UNINDENT_LINES
    importing
      !FROM_LINE type I
      !TO_LINE type I optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods UNINDENT_SELECTION
    importing
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD .
  methods SET_SELECTED_TEXTSTREAM
    importing
      !SELECTED_TEXT type STRING optional
      !ENABLE_EDITING_PROTECTED_TEXT type I default FALSE
    exceptions
      ERROR_CNTL_CALL_METHOD
      NOT_SUPPORTED_BY_GUI .

  methods DISPATCH
    redefinition .
  methods FREE
    redefinition .
  methods SET_REGISTERED_EVENTS
    redefinition .
  type-pools CNDP .
  type-pools OLE2 .
  type-pools SFES .

*--- INCLUDE: CL_SIMPLEPROPBAG==============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_SIMPLEPROPBAG and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: IF_CACHED_PROP================IU ---*
*" components of interface IF_CACHED_PROP
interface IF_CACHED_PROP
  public .


*" methods
methods:
  GET_NEXT_PROP
      exporting
        PROPNAME type STRING
        PROPVALUE type STRING
      exceptions
        NO_MORE_PROPS ,
  SEEK_FIRST_PROP
      exceptions
        ERROR_SEEK_FIRST ,
  SET_PROP
      importing
        PROPNAME type STRING
        PROPVALUE type STRING
      exceptions
        PROP_NOT_FOUND
        INVALID_NAME
        ERROR_SET_PROPERTY .
endinterface.

*--- INCLUDE: IF_DRAGDROP===================IU ---*

*" type-pools
TYPE-POOLS:
  CNDD .
*" components of interface IF_DRAGDROP
INTERFACE IF_DRAGDROP PUBLIC.


*" methods
METHODS:
  ONGETFLAVOR
      IMPORTING
        FLAVORS TYPE CNDD_FLAVORS
        PROPERTIES TYPE REF TO CL_SIMPLEPROPBAG
        DRAGDROPOBJECT TYPE REF TO CL_DRAGDROPOBJECT OPTIONAL ,
  ONDRAG
      IMPORTING
        PROPERTIES TYPE REF TO CL_SIMPLEPROPBAG
        DRAGDROPOBJECT TYPE REF TO CL_DRAGDROPOBJECT ,
  ONDROP
      IMPORTING
        PROPERTIES TYPE REF TO CL_SIMPLEPROPBAG
        DRAGDROPOBJECT TYPE REF TO CL_DRAGDROPOBJECT ,
  ONDROPCOMPLETE
      IMPORTING
        PROPERTIES TYPE REF TO CL_SIMPLEPROPBAG
        DRAGDROPOBJECT TYPE REF TO CL_DRAGDROPOBJECT .
ENDINTERFACE.

*--- INCLUDE: MZMMPREPROLE3_PHASEIIF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEF01                                            *
*----------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID     Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT  1) Replaced obsolete FM
*                                         "POPUP_TO_CONFIRM_STEP" and
*                                         "WS_DOWNLOAD"
*                                      2) Removed erros for literal
*                                         exceeding more than one line.
* 18/12/2008 <RD1K960611>   SAB_PUNIT  1) Wrong variable was used the
*                                         previous change.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 2156.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/05/2009      <RD1K964305>    SAB_SUMODH
*
*1)Change in Line 3554.
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company              *
*                                           roles during approval)     *
*&                                                                     *
*&                                                                     *
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  bac_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bac_confirm.

  DATA l_choice.
  CLEAR l_choice.
  IF g_mode <> 'DIS'.
* begin of <RD1K960036>
* FM 'POPUP_TO_CONFIRM_STEP' is obsolete.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'BACK'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.
*
*    If l_choice = 'J'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'BACK'
*       DIAGNOSE_OBJECT       = ' '
        text_question         = 'Data will be lost, Want to quit? '
        text_button_1         = 'Yes'(003)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'No'(002)
*       ICON_BUTTON_2         = ' '
*       DEFAULT_BUTTON        = '1'
        display_cancel_button = space
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = l_choice
*     TABLES
*       PARAMETER             =
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    IF l_choice EQ '1'.
* end of <RD1K960036>
*       perform clear_var.
      CLEAR l_choice.
    ENDIF.
  ELSE.
*     perform clear_var.
  ENDIF.

ENDFORM.                    " bac_confirm
*&---------------------------------------------------------------------*
*&      Form  fill_sttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sttab.

  IF   old_ok_code = 'DISPLAY' .
    MOVE 'ROLE_DEL' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'ROLE_CR' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
  ENDIF.
  IF   old_ok_code = 'DELETE' .
    MOVE 'ROLE_CR' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
  ENDIF.


ENDFORM.                    " fill_sttab
*&---------------------------------------------------------------------*
*&      Form  lock_reqhd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_reqhd.

  CALL FUNCTION 'ENQUEUE_EZ_IC_PREPHDR'
    EXPORTING
      mode_zic_prep_rolereq = 'E'
      mandt                 = sy-mandt
      docno                 = zic_prep_rolereq-docno
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc <> 0.
    CLEAR g_lock.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    MOVE 'Y' TO g_lock.
  ENDIF.

ENDFORM.                    " lock_reqhd
*&---------------------------------------------------------------------*
*&      Form  get_correspondence
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_correspondence.

  DATA : l_cors LIKE thead-tdname.

  IF old_ok_code <> 'CREATE' OR
     old_ok_code <> 'CROSSCO'.

    REFRESH lines_cors.

    MOVE zic_prep_rolereq-docno TO l_cors.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = '0001'
        language                = sy-langu
        name                    = l_cors
        object                  = 'ZHELP'
      TABLES
        lines                   = lines_cors
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.

    IF sy-subrc <> 0.
      read_flag = ''.
      zic_prep_rolereq-long_text_fl = ''.
    ELSE.
      read_flag = 'X'.
      zic_prep_rolereq-long_text_fl = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_correspondense

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
* execute general and TC specific operations                           *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.
      g_ins_flag = 'X'.

    WHEN 'DELE'.                      "delete row

      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

* get current line
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line                           *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.
* insert initial line
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
* set cursor
  SET CURSOR LINE l_line.

  g_i = l_line.
  g_field = 'zic_prep_rolerei-ROLE_NAME'.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X' AND <wa>+90(1) = ''.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.
***********************************************************************
  g_tc_lines = <tc>-lines.
***********************************************************************

* is no line filled?                                                   *
  IF <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*     set actual column                                                *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  HELP_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM help_list.

  IF zic_prep_rolereq-ccode IS INITIAL.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-CCODE'.
    MESSAGE i082(zhelp).
    LEAVE TO SCREEN 0.
  ENDIF.
  REFRESH : it_cond.
  CONCATENATE 'FICTR'  'LIKE'  INTO g_line SEPARATED BY
  space.
  CONCATENATE g_line+0(10) '''' zic_prep_rolereq-ccode '%' ''''  INTO
              g_line.
  APPEND g_line TO it_cond.
  IF help_list_flag <> 'X' .
    SELECT * FROM m_fistb INTO CORRESPONDING FIELDS OF TABLE it_m_fistb
                  WHERE (it_cond).
    SORT IT_M_FISTB BY BEZEICH SPRAS1 BOSSID FIKRS FICTR. help_list_flag = 'X'.
    REFRESH it_cond.
  ENDIF.
  LOOP AT it_m_fistb INTO wa_m_fistb.
*
    IF wa_m_fistb-fictr = zic_prep_rolereq-fundc OR
       wa_m_fistb-fictr = zic_prep_rolereq-fundc2 OR
       wa_m_fistb-fictr = zic_prep_rolereq-fundc3 OR
       wa_m_fistb-fictr = zic_prep_rolereq-fundc4.
      wa_m_fistb-g_mark = 'X'.
    ENDIF.

    IF old_ok_code = 'DISPLAY' OR old_ok_code = 'APPROVE'.
      IF wa_m_fistb-g_mark = 'X'.
        WRITE: / wa_m_fistb-fictr, wa_m_fistb-bezeich.
      ENDIF.
    ELSE.
      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
            wa_m_fistb-bezeich.
    ENDIF.

    HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*    CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr.
  ENDLOOP.
  lines = sy-linno .

ENDFORM.                    " HELP_LIST
*&---------------------------------------------------------------------*
*&      Form  tick_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tick_all.

  sy-lsind = 0.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'SELALL' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'DESELALL' TO wa_tab.
  APPEND wa_tab TO tab.

  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
           COLOR COL_HEADING.
  ULINE.


  IF flag_s_fundc = 'X'.
*    refresh : s_fundc.
    LOOP AT it_m_fistb INTO wa_m_fistb.
*
      wa_m_fistb-g_mark = 'X'.
      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      MODIFY  it_m_fistb FROM wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    lines = sy-linno .

  ENDIF.


ENDFORM.                    " tick_all
*&---------------------------------------------------------------------*
*&      Form  notick_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM notick_all.

  sy-lsind = 0.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'SELALL' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'DESELALL' TO wa_tab.
  APPEND wa_tab TO tab.

  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
         COLOR COL_HEADING.
  ULINE.


  IF flag_s_fundc = 'X'.
*    refresh : s_fundc.
    LOOP AT it_m_fistb INTO wa_m_fistb.
*
      wa_m_fistb-g_mark = ''.
      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      MODIFY  it_m_fistb FROM wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    lines = sy-linno .

  ENDIF.

ENDFORM.                    " notick_all
*&---------------------------------------------------------------------*
*&      Form  pick
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pick.

  sy-lsind = 0.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'SELALL' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'DESELALL' TO wa_tab.
  APPEND wa_tab TO tab.

  DATA l_blank VALUE ''.

  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
         COLOR COL_HEADING.
  ULINE.


  IF flag_s_fundc = 'X'.
*    refresh : s_fundc.
    LOOP AT it_m_fistb INTO wa_m_fistb.

      lines_index = sy-tabix + 4.

      READ LINE lines_index FIELD VALUE wa_m_fistb-g_mark.

      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.

      IF wa_m_fistb-g_mark <> 'X'.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc.
          zic_prep_rolereq-fundc = 'X'.
        ENDIF.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc2.
          CLEAR zic_prep_rolereq-fundc2.
        ENDIF.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc3.
          CLEAR zic_prep_rolereq-fundc3.
        ENDIF.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc4.
          CLEAR zic_prep_rolereq-fundc4.
        ENDIF.

      ENDIF.

      MODIFY  it_m_fistb FROM wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    help_list_flag = 'X'.

    lines = sy-linno .

    READ TABLE it_m_fistb INTO wa_m_fistb WITH KEY g_mark = 'X'.

    IF sy-subrc = 0.

      zic_prep_rolereq-fundc = wa_m_fistb-fictr.

    ELSE.

      CLEAR zic_prep_rolereq-fundc .

    ENDIF.

  ENDIF.

ENDFORM.                    " pick
*&---------------------------------------------------------------------*
*&      Form  check_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items.

  PERFORM validations1.

ENDFORM.                    " check_items
*&---------------------------------------------------------------------*
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_request.

  IF old_ok_code = 'CREATE'.

    PERFORM gen_no.

  ENDIF.

  PERFORM insert_header.


ENDFORM.                    " Save_request
*&---------------------------------------------------------------------*
*&      Form  gen_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gen_no.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZDOCNUMB'
    IMPORTING
      number      = zdocnumb.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " gen_no
*&---------------------------------------------------------------------*
*&      Form  insert_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_header.

  zic_prep_rolereq-mandt = sy-mandt.
  IF old_ok_code = 'CREATE'.
    zic_prep_rolereq-docno = zdocnumb.
  ENDIF.


  IF zic_prep_rolereq-useridcr IS INITIAL.

    zic_prep_rolereq-useridcr = sy-uname.
    zic_prep_rolereq-cr_date  = sy-datum.

    IF sy-tcode <> 'ZIC_AUTH_CORETEAM'.

      CLEAR zusrmst.

      SELECT SINGLE * FROM zusrmst WHERE cpfno =
                                 zic_prep_rolereq-useridcr.

      IF sy-subrc NE 0.

      ELSE.
*
        CONCATENATE zusrmst-first_name zusrmst-last_name INTO
          zusrmst-last_name.
        zic_prep_rolereq-namecr = zusrmst-last_name.

      ENDIF.

    ENDIF.

  ENDIF.

  IF zic_prep_rolereq-useridap IS INITIAL.

    IF old_ok_code = 'APPROVE' AND
          ( zic_prep_rolereq-req_app_fl = 'X' ).
      zic_prep_rolereq-useridap = sy-uname.
      zic_prep_rolereq-app_date  = sy-datum.

      CLEAR zusrmst.

      SELECT SINGLE * FROM zusrmst WHERE cpfno =
                            zic_prep_rolereq-useridap.

      IF sy-subrc NE 0.

      ELSE.

        CONCATENATE zusrmst-first_name zusrmst-last_name INTO
         zusrmst-last_name.
        zic_prep_rolereq-nameapp = zusrmst-last_name.
      ENDIF.

    ENDIF.

  ELSE.

    IF old_ok_code = 'APPROVE' AND
          zic_prep_rolereq-req_app0_fl = 'X'
                AND zic_prep_rolereq-req_app1_fl = 'X'.

      zic_prep_rolereq-useridap = sy-uname.
      zic_prep_rolereq-app_date = sy-datum.

      SELECT SINGLE * FROM zusrmst WHERE cpfno =
                              zic_prep_rolereq-useridap.
      IF sy-subrc NE 0.
        MESSAGE e043(zhelp).
      ELSE.

        CONCATENATE zusrmst-first_name zusrmst-last_name INTO
        zusrmst-last_name.
        zic_prep_rolereq-nameapp = zusrmst-last_name.
      ENDIF.
    ENDIF.
  ENDIF.

*****************************
  DATA l_fundc_no LIKE sy-index.
  CLEAR l_fundc_no.
  LOOP AT it_m_fistb INTO wa_m_fistb.
    IF wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      CASE l_fundc_no.
        WHEN 2.
          zic_prep_rolereq-fundc2 = wa_m_fistb-fictr.
        WHEN 3.
          zic_prep_rolereq-fundc3 = wa_m_fistb-fictr.
        WHEN 4.
          zic_prep_rolereq-fundc4 = wa_m_fistb-fictr.
        WHEN 5.
          MESSAGE i078(zhelp).
          okcode_100 = 'MULTI'.
          g_fundc_err_flag = 'X'.
      ENDCASE.
    ENDIF.
  ENDLOOP.
*****************************
  IF zic_prep_rolereq-status <> 'C'.

    zic_prep_rolereq-status = 'IF'.

  ENDIF.

*****
  IF g_fundc_err_flag <> 'X'.

    IF corr_code = 'CORR' AND sy-tcode = 'ZIC_AUTH_CORETEAM'.
      CLEAR : corr_code.
**
      IF g_mult_module_fl = 'X'.
        PERFORM confirm_message.
      ELSE.
        gl_ans = 'J'.
      ENDIF.
      IF gl_ans = 'J'.
        CLEAR gl_ans.
        PERFORM confirm_process.
* begin of <RD1K960036>
* Handled differnt response from obsolete FM and its
* replacement
*      if status_process = 'J'.
        IF status_process = '1'.
* end of <RD1K960036>
          CLEAR status_process.
          status_process_flag = 'X'.
        ELSE.
          IF zic_prep_rolereq-comm_fl = 'X'.
            zic_prep_rolereq-status = 'IR'.
          ELSE.
            PERFORM confirm_status.
* begin of <RD1K960036>
* Handles different responces for obsolete FM
* POPUP_TO_CONFIRM_STEP and its replacement.
*            if status_choice = 'J'.
            IF status_choice = '1'.
* end of <RD1K960036>
              CLEAR status_choice.
              zic_prep_rolereq-status = 'IC'.
            ELSE.
              zic_prep_rolereq-comm_fl = 'X'.
              zic_prep_rolereq-status = 'IR'.
            ENDIF.
          ENDIF.
          PERFORM send_sapmail.
          REFRESH object_content.
          CLEAR corr_code.
        ENDIF.
      ENDIF.
**
    ELSE.
    ENDIF.


*************************************************************

** Module wise check & insertion

    CASE moduleid.

      WHEN 'MM'.

        PERFORM insert_items.

      WHEN 'PM'.

        PERFORM insert_items_pm.

      WHEN 'PS'.

        PERFORM insert_items_ps.

      WHEN 'PP'.

        PERFORM insert_items_pp.

      WHEN 'SD'.

        PERFORM insert_items_sd.

      WHEN 'QM'.

        PERFORM insert_items_qm.

      WHEN 'HSE'.

        PERFORM insert_items_hs.

      WHEN 'OLM'.

        PERFORM insert_items_olm.

        """""""""""
      WHEN 'SRM'.
        PERFORM insert_items_srm.
        """""""""""

    ENDCASE.

    IF sy-tcode <> 'ZIC_AUTH_CORETEAM'.

      PERFORM items_approval_check.

    ENDIF.

***********************

    IF sy-subrc = 0 AND ( zic_prep_rolereq-status <> 'IC'
                        AND zic_prep_rolereq-status <> 'IR' ).

      SELECT * FROM zic_prep_rolerei INTO TABLE ist_itemtab
              WHERE docno = zic_prep_rolereq-docno.

      LOOP AT ist_itemtab INTO wa_itemtab.
        IF wa_itemtab-rej_fl = ''.
          IF wa_itemtab-status = '' AND
              wa_itemtab-role_request = ''.
            g_request_close_flag_p  = 'X'.
          ELSEIF wa_itemtab-status = 'H'.
            g_request_close_flag_h = 'X'.
          ELSEIF  wa_itemtab-role_request <> ''.
            g_request_close_flag_r = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF ( g_request_close_flag_p  = 'X' OR
         g_request_close_flag_h  = 'X' ) AND
         g_request_close_flag_r = 'X'.
        zic_prep_rolereq-status = 'PC'.
      ELSEIF g_request_close_flag_p  <> 'X' AND
         g_request_close_flag_h  = 'X' AND
         g_request_close_flag_r = 'X'.
        zic_prep_rolereq-status = 'PC'.
      ELSEIF g_request_close_flag_p  = '' AND
         g_request_close_flag_h  = '' AND
         g_request_close_flag_r = 'X'.
        zic_prep_rolereq-status = 'C'.
      ELSEIF g_request_close_flag_p  = 'X' AND
         g_request_close_flag_h  <> 'X' AND
         g_request_close_flag_r <> 'X'.
        zic_prep_rolereq-status = 'IF'.
      ELSEIF  g_request_close_flag_p = '' AND
               g_request_close_flag_h = '' AND
                 g_request_close_flag_r <> ''.
        zic_prep_rolereq-status = 'C'.
      ENDIF.

    ENDIF.

*    if status_process_flag = 'X' and ZIC_PREP_ROLEREQ-status <> 'C'.
*          ZIC_PREP_ROLEREQ-status = 'IR'.
*    endif.

    MODIFY zic_prep_rolereq FROM zic_prep_rolereq.

    CLEAR : g_request_close_flag_p, g_request_close_flag_h,
            g_request_close_flag_r.


****Saving the long text.                              *****

    IF ( old_ok_code = 'CREATE' ) OR
       ( old_ok_code = 'CHANGE' ) OR
       ( old_ok_code = 'RELEASE' ) OR
       ( old_ok_code = 'APPROVE' ).

      PERFORM save_cors_text.

    ENDIF.

    IF g_role_flag = 'X'.
      CLEAR g_role_flag.
      PERFORM unlock_record.

    ELSE.

      IF l_old_ok_code = 'X'.
        SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
        LEAVE PROGRAM.
      ELSE.
        PERFORM clear.
        PERFORM unlock_record.
        CALL SCREEN 100.
      ENDIF.

    ENDIF.

  ELSE.

    CLEAR g_fundc_err_flag.
    CALL SCREEN 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    CLEAR okcode_100.

  ENDIF.

ENDFORM.                    " insert_header
*&---------------------------------------------------------------------*
*&      Form  insert_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl110_itab
  BY role_name plant grp  sloc receipt_loc approver.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl110_itab
    COMPARING role_name plant grp  sloc receipt_loc approver rej_fl.

  LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.

    MOVE-CORRESPONDING g_tablctrl110_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
        wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

    IF old_ok_code = 'CREATE'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_items_save.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM zic_prep_rolerei WHERE docno = zic_prep_rolereq-docno
       AND moduleid = moduleid..

    MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    IF sy-subrc = 0 AND g_role_flag <> 'X'.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
    ENDIF.

**      if sy-subrc = 0.
**** Messages to be checked modulewise in sub
**        perform clear1.
**        if old_ok_code = 'CROSSCO' or
**              ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
**
**              if old_ok_code = 'RELEASE' or
**                  old_ok_code = 'CROSSCO' or
**                  old_ok_code = 'CHANGE'.
**                  perform popup_release_message.
**               endif.
**
**               if old_ok_code = 'APPROVE' or
**                  ZIC_PREP_ROLEREQ-status = 'IF'.
**                  perform popup_approve_message.
**               endif.
**
**               perform pop_up_crossco_message.          .
***          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
**               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**
**          else.
**            if old_ok_code = 'CRCROLES' or
**              ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
**               if old_ok_code = 'RELEASE' or
**                  old_ok_code = 'CRCROLES' or
**                  old_ok_code = 'CHANGE'.
**                  perform popup_release_message.
**               endif.
**               if old_ok_code = 'APPROVE' or
**                  ZIC_PREP_ROLEREQ-status = 'IF'.
**                  perform popup_approve_message.
**               endif.
**               perform pop_up_crc_message.
***              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
**               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**               g_crc_fl = 'X'.
**            else.
**              if old_ok_code = 'RELEASE'.
**                perform popup_release_message.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              elseif old_ok_code = 'APPROVE'.
**.               perform popup_approve_message.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              elseif old_ok_code = 'CREATE' or old_ok_code =
**'CHANGE'
    .
*.
**                perform popup_release_message1.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              elseif ZIC_PREP_ROLEREQ-status = 'IF'.
**                perform popup_approve_message.
**              else.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              endif.
**            endif.
**        endif.
**      endif.

  ENDIF.

ENDFORM.                    " insert_items
*&---------------------------------------------------------------------*
*&      Form  exit_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_confirm.

  DATA l_choice1.
  CLEAR l_choice1.

  IF old_ok_code = 'CREATE' OR
     old_ok_code = 'CROSSCO' OR
     old_ok_code = 'CHANGE' OR
     old_ok_code = 'DELETE' OR
     old_ok_code = 'RELEASE' OR
     old_ok_code = 'APPROVE'.
* begin of <RD1K960036>
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'EXIT'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
**                 DEFAULTOPTION = 'N'
*         IMPORTING
*              ANSWER         = l_choice1.
*
*    If l_choice1 = 'J'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'EXIT'
*       DIAGNOSE_OBJECT       = ' '
        text_question         = 'Data will be lost, Want to quit? '
        text_button_1         = 'Yes'(003)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'No'(002)
*       ICON_BUTTON_2         = ' '
        default_button        = '2'
        display_cancel_button = space
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = l_choice1
*     TABLES
*       PARAMETER             =
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    IF l_choice1 EQ '1'.
* end of <RD1K960036>
      CLEAR l_choice1.
      PERFORM clear.
      PERFORM unlock_record.
      CALL SCREEN 100.
    ELSE.
    ENDIF.

  ELSE.

    PERFORM clear.
    PERFORM unlock_record.
    CALL SCREEN 100.

  ENDIF.


ENDFORM.                    " exit_confirm
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_var.

  PERFORM clear.

ENDFORM.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  unlock_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_req.



ENDFORM.                    " unlock_req
*&---------------------------------------------------------------------*
*&      Form  unlock_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_record.

  CALL FUNCTION 'DEQUEUE_EZ_IC_PREPHDR'
    EXPORTING
      mode_zic_prep_rolereq = 'E'
      mandt                 = sy-mandt
      docno                 = zic_prep_rolereq-docno.

  CLEAR g_lock.

ENDFORM.                    " unlock_record
*&---------------------------------------------------------------------*
*&      Form  clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear.

  PERFORM destroy_ctrl.

  CLEAR   : old_ok_code, okcode_100, err_flg.
  REFRESH : g_tablctrl110_itab[].
  CLEAR   : g_tablctrl110_itab.
  REFRESH : g_tablctrl111_itab[].
  CLEAR   : g_tablctrl111_itab.
  CLEAR   : sy-ucomm.
  CLEAR   : g_curr_line.
  CLEAR set_disc_mm_flag.
  CLEAR   : zic_prep_rolerei, zic_prep_rolereq.
  CLEAR   : it_tab.
  REFRESH : tlinetab1[],tlinetab2[].
  CLEAR   : t500p-name1.
  CLEAR   : crc_check_fl.
  CLEAR   : help_list_flag.
  REFRESH : it_m_fistb.
  CLEAR   : moduleid.
  REFRESH : it_module1.
  CLEAR   : status_process_flag.

  """""""""
  REFRESH : g_tablctrl118_itab[].
  CLEAR   : g_tablctrl118_itab.

  """""""""

ENDFORM.                    " clear
*&---------------------------------------------------------------------*
*&      Form  text_control_eingabebereit1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM text_control_eingabebereit1.

  CALL METHOD gv_text_editor1->set_readonly_mode
    EXPORTING
      readonly_mode          = gv_text_editor1->true
    EXCEPTIONS
      error_cntl_call_method = 1
      invalid_parameter      = 2
      OTHERS                 = 3.

  IF ( old_ok_code = 'CREATE' )
   OR ( old_ok_code = 'CROSSCO' )
   OR ( old_ok_code = 'CRCROLES' )
   OR ( old_ok_code = 'CHANGE' )
   OR ( old_ok_code = 'RELEASE' )
   OR ( old_ok_code = 'APPROVE' )
  OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-status = 'IR' )
 .

    CALL METHOD gv_text_editor2->set_readonly_mode
      EXPORTING
        readonly_mode          = gv_text_editor2->false
      EXCEPTIONS
        error_cntl_call_method = 1
        invalid_parameter      = 2
        OTHERS                 = 3.

  ENDIF.

ENDFORM.                    " text_control_eingabebereit1
*&---------------------------------------------------------------------*
*&      Form  text_control_set_text_table1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM text_control_set_text_table1.

  REFRESH: tlinetab1, g_linefrto_itab.
  IF old_ok_code <> 'CREATE' OR
     old_ok_code = 'CROSSCO' .
    APPEND LINES OF lines_cors TO tlinetab1[].
  ENDIF.
*
  LOOP AT tlinetab1[] INTO g_line132.
    IF ( g_line132+0(7) = '* Reply' ) OR
       ( g_line132+0(7) = '**Reply' ).
      g_linefrto-line_fr = sy-tabix.
      g_linefrto-line_to = sy-tabix.
      APPEND g_linefrto TO g_linefrto_itab.
      CLEAR: g_linefrto.
    ENDIF.
  ENDLOOP.
*
  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    TABLES
      itf_text    = tlinetab1[]
      text_stream = lt_text_table1.

  CALL METHOD gv_text_editor1->set_text_as_stream
    EXPORTING
      text            = lt_text_table1
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.
********************highlight**************************************
  CLEAR g_linefrto.
  LOOP AT g_linefrto_itab INTO g_linefrto.
    CALL METHOD gv_text_editor1->highlight_lines
      EXPORTING
        from_line      = g_linefrto-line_fr
        to_line        = g_linefrto-line_to
        highlight_mode = 1.
  ENDLOOP.
********************************************************************

  IF ( old_ok_code = 'CREATE' )
   OR ( old_ok_code = 'CROSSCO' )
   OR ( old_ok_code = 'CRCROLES' )
   OR ( old_ok_code = 'CHANGE' )
   OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-status = 'IR' )
 .
    CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
      TABLES
        itf_text    = tlinetab2
        text_stream = lt_text_table2.

    CALL METHOD gv_text_editor2->set_text_as_stream
      EXPORTING
        text            = lt_text_table2
      EXCEPTIONS
        error_dp        = 1
        error_dp_create = 2
        OTHERS          = 3.
  ENDIF.

ENDFORM.                    " text_control_set_text_table1
*&---------------------------------------------------------------------*
*&      Form  save_cors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_cors_text.

  DATA: l_theader LIKE thead.
  DATA: l_datech(10) TYPE c.
***********Assignments***********************
  CLEAR l_theader.
  l_theader-tdobject   = 'ZHELP'.
  l_theader-tdid       = '0001'.
  l_theader-tdspras    =  sy-langu.
  l_theader-tdlinesize =  72.
  MOVE zic_prep_rolereq-docno TO l_theader-tdname.
  APPEND LINES OF tlinetab2 TO tlinetab1.
*********************************************
  IF NOT tlinetab1[] IS INITIAL.
    CLEAR g_cores_sender.
    CONCATENATE sy-datum+6(2) '/'
                sy-datum+4(2) '/'
                sy-datum+0(4) INTO l_datech.
** select module
    SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**
    CONCATENATE '**Reply' l_datech sy-uname zauth_user-primary_module
    ' Module' INTO g_cores_sender  SEPARATED BY '    '.
    IF NOT tlinetab2[] IS INITIAL.
      APPEND g_cores_sender TO tlinetab1.
    ENDIF.
    CLEAR g_cores_sender.
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        client          = sy-mandt
        header          = l_theader
        savemode_direct = 'X'
      TABLES
        lines           = tlinetab1
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " save_cors_text
*&---------------------------------------------------------------------*
*&      Form  get_user
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user.

  CLEAR g_user.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'L1'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'DI'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'CS'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'MD'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'IM'.

  IF sy-subrc = 0.
    g_user = 'IM'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'FRGCO' FIELD : 'L2'.
  IF sy-subrc = 0.
    g_user = 'L3'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L3'.
  IF sy-subrc = 0.
    g_user = 'L3'.
    CHECK 1 = 2.
  ENDIF.

*   g_user_found = 'X'.
*
ENDFORM.                    " find_user
*&---------------------------------------------------------------------*
*&      Form  validations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations.

  IF sy-tcode <> 'ZIC_AUTH_CORETEAM'.

    IF old_ok_code <> 'DISPLAY' AND old_ok_code <> 'APPROVE'.

      IF  zic_prep_rolereq-useridcr = sy-uname.
      ELSE.
        MESSAGE e046(zhelp).
      ENDIF.

    ENDIF.

    IF old_ok_code = 'CHANGE' AND zic_prep_rolereq-req_cr_fl = 'X'.
      PERFORM verify.
    ENDIF.

  ELSE.

    IF ( old_ok_code = 'CHANGE' OR old_ok_code = 'DELETE' ) AND
                            ( zic_prep_rolereq-status = 'IC'
                            OR
                              zic_prep_rolereq-status = 'IR' ).

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*         TEXTLINE1 = 'Can''t change / delete this document it is
*with creator'.
          textline1 = 'Can''t change / delete this document it is'
                      & 'with creator'.
* end of <RD1K960036>
      SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
      old_ok_code = 'DISPLAY'.
      CALL SCREEN 100.

    ENDIF.

    IF zic_prep_rolereq-status  = 'C'
       AND old_ok_code <> 'DISPLAY'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*         TEXTLINE1 = 'Request can not be changed Can only be disp
*layed'.
          textline1 = 'Request can not be changed Can only be'
                      & 'displayed'.
* end of <RD1K960036>

      SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
      old_ok_code = 'DISPLAY'.
*
    ENDIF.


  ENDIF.

  IF old_ok_code = 'APPROVE' AND
                    zic_prep_rolereq-disc_mm_flag = 'X'.
    IF g_user = 'IM' OR g_user = 'L1'.
    ELSE.
      MESSAGE e048(zhelp).
    ENDIF.
  ENDIF.

  IF old_ok_code = 'RELEASE' AND zic_prep_rolereq-req_cr_fl = 'X'.
    MESSAGE e053(zhelp).
  ENDIF.

  IF old_ok_code = 'APPROVE'.

    IF g_user = 'L1' AND zic_prep_rolereq-req_app1_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      MESSAGE e051(zhelp).
    ENDIF.

    IF ( g_user = 'IM' ) AND
                          zic_prep_rolereq-req_app0_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      MESSAGE e051(zhelp)..
    ENDIF.

    IF ( g_user = 'L3' ) AND
                          zic_prep_rolereq-req_app_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      MESSAGE e051(zhelp)..
    ENDIF.

    IF g_user = 'L1' AND zic_prep_rolereq-req_app1_fl = 'X'.
      MESSAGE e049(zhelp).
    ENDIF.

    IF ( g_user = 'IM' ) AND
                          zic_prep_rolereq-req_app0_fl = 'X'.
      MESSAGE e050(zhelp)..
    ENDIF.

    IF ( g_user = 'L3' ) AND
                          zic_prep_rolereq-req_app_fl = 'X'.
      MESSAGE e050(zhelp)..
    ENDIF.

  ENDIF.

  IF old_ok_code <> 'DISPLAY' AND
       ( zic_prep_rolereq-req_app_fl <> 'X' AND
       zic_prep_rolereq-req_app0_fl <> 'X' AND
       zic_prep_rolereq-req_app1_fl <> 'X' ).
    MESSAGE i080(zhelp).
    g_reset_change = 'X'.
    SET PARAMETER ID 'ZOLDCODE' FIELD ''.
    old_ok_code = 'DISPLAY'.
    PERFORM change_status.
  ENDIF.

ENDFORM.                    " validations
*&---------------------------------------------------------------------*
*&      Form  validations1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations1.

  IF g_val_err = 'X'.
    CLEAR g_val_err.
    MESSAGE i118(zhelp).
    CALL SCREEN 100.
  ENDIF.

  IF zic_prep_rolerei-rej_fl = ''.

    IF old_ok_code = 'APPROVE' AND
                      zic_prep_rolereq-disc_mm_flag = 'X'.
      IF g_user = 'IM' OR g_user = 'L1'.
      ELSE.
        MESSAGE e048(zhelp).
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM check_tel.

ENDFORM.                    " validations1


*---------------------------------------------------------------------*
*       FORM destroy_ctrl                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM destroy_ctrl.

  IF NOT flag2 IS INITIAL.
    CLEAR : flag2, flag1.
    CALL METHOD gv_text_editor1->free.
    CALL METHOD gv_text_editor2->free.
  ENDIF.

  IF NOT flag1 IS INITIAL.
    CLEAR flag1.
    CALL METHOD gv_text_editor1->free.
  ENDIF.

  CLEAR:gv_text_editor1,gv_text_editor2.

  PERFORM unlock_record.

ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  delete_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_request.

  DATA : l_choice.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Are you sure, you want to delete the
*Document? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.
*
*If l_choice = 'J'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Are you sure, you want to '
                              & 'delete the Document?'
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = l_choice
*    TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF l_choice = '1'.
* end of <RD1K960036>
    CLEAR l_choice.

**************************************

    zic_prep_rolereq-mandt = sy-mandt.

    DELETE zic_prep_rolereq FROM zic_prep_rolereq.

    IF sy-subrc = 0.

      PERFORM delete_items.


      IF zic_prep_rolereq-long_text_fl <> ''.
        PERFORM delete_cors_text.
      ENDIF.

      PERFORM clear.
      PERFORM unlock_record.
      CALL SCREEN 100.

    ELSE.

      MESSAGE i057(zhelp) WITH zic_prep_rolereq-docno.

    ENDIF.

  ELSE.

  ENDIF.

ENDFORM.                    " delete_request
*&---------------------------------------------------------------------*
*&      Form  delete_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_items.

  LOOP AT g_tabctrl100_itab INTO g_tabctrl100_wa.

    MOVE-CORRESPONDING g_tabctrl100_wa TO wa_itemtab.
    wa_itemtab-mandt = sy-mandt.
    APPEND wa_itemtab TO ist_itemtab.

  ENDLOOP.

  DELETE zic_prep_rolerei FROM TABLE ist_itemtab.

  IF sy-subrc = 0.
    MESSAGE i120(zhelp) WITH zic_prep_rolereq-docno.
  ENDIF.

ENDFORM.                    " delete_items
*&---------------------------------------------------------------------*
*&      Form  delete_cors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_cors_text.

  DATA : l_name LIKE thead-tdname.

  l_name = zic_prep_rolereq-docno.

  CALL FUNCTION 'DELETE_TEXT'
    EXPORTING
      client    = sy-mandt
      id        = '0001'
      language  = sy-langu
      name      = l_name
      object    = 'ZHELP'
*     SAVEMODE_DIRECT       = ' '
*     TEXTMEMORY_ONLY       = ' '
*     LOCAL_CAT = ' '
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " delete_cors_text
*&---------------------------------------------------------------------*
*&      Form  verify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify.

  DATA l_choice.
  CLEAR l_choice.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be
*cancelled? '
*           TITEL          = 'RESET'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
*
*  If l_choice = 'J'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'RESET'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Request already released'
                              & ' Flags will be cancelled?'
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'NO'(002)
*     ICON_BUTTON_2         = ' '
      default_button        = '2'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = l_choice
*      TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF l_choice = '1'.
* end of <RD1K960036>
    CLEAR zic_prep_rolereq-req_cr_fl.
    CLEAR zic_prep_rolereq-req_app_fl.
    CLEAR zic_prep_rolereq-req_app0_fl.
    CLEAR zic_prep_rolereq-req_app1_fl.
    zic_prep_rolereq-status = 'IC'.
    PERFORM save_request.
**20/03/2006
    g_app_rel = 'X'.
    CLEAR l_choice.

  ELSE.

    PERFORM clear.
    PERFORM unlock_record.
    CALL SCREEN 100.

  ENDIF.

ENDFORM.                    " verify
*&---------------------------------------------------------------------*
*&      Form  check_items_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save.
  IF old_ok_code <> 'DISPLAY' .

    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.

      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.

        IF zmm_prep_rolecrc-plant = 'X' AND
            wa_itemtab-plant IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE i084(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.

        IF zmm_prep_rolecrc-p_grp = 'X' AND
           wa_itemtab-grp IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-P_GRP'.
          ROLLBACK WORK.
          MESSAGE i085(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.

        IF zmm_prep_rolecrc-app_level = 'X' AND
          wa_itemtab-approver IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          ROLLBACK WORK.
          MESSAGE i096(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.

      ENDIF.

    ELSE.

      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                                                  wa_itemtab-role_name.
      IF sy-subrc = 0.

        IF zmm_prep_roledes-plant = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-plant IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            ROLLBACK WORK.
            MESSAGE i084(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-p_grp = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE'  OR
                      old_ok_code = 'CREATE'  OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-grp IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-GRP'.
            ROLLBACK WORK.
            MESSAGE i085(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-s_loc = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-sloc IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
            ROLLBACK WORK.
            MESSAGE i090(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-r_loc = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-receipt_loc IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
            ROLLBACK WORK.
            MESSAGE i095(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-app_level = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-approver IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
            ROLLBACK WORK.
            MESSAGE i096(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.
**  if wa_itemtab-rej_fl is initial.
**** Header level changes for integration
**    perform validate_role_approval_level.
**  endif.
** Line item changes for integration call diffrent subs ( def 110 )
*Begin of <RD1K963151>.
  IF old_ok_code = 'CHANGE' AND sy-ucomm NE 'REQ1'.
*End of <RD1K963151>.
    PERFORM validate_lineitem_datax.
*Begin of <RD1K963151>.
  ENDIF.
*End of <RD1K963151>.
ENDFORM.                    " check_items_save
*&---------------------------------------------------------------------*
*&      Form  verify1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify1.

  DATA : l_choice.
  CLEAR l_choice.

* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'If u cancel release, u can change data
*else go in display mode'
*               TEXTLINE2      = '& just do correspondence without
*cancelling release'
*           TITEL          = 'Do you want to cancel release?'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
*  If l_choice = 'J'.
  DATA l_question TYPE string.

  MOVE 'If u cancel release, u can change data else go in'
       & ' display mode & just do correspondence '
       & ' without cancelling release'
       TO l_question.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Do you want to cancel release?'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = l_question
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
      default_button        = '2'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = l_choice
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF l_choice EQ '1'.
* end of <RD1K960036>

    old_ok_code = 'CHANGE'.
    CLEAR l_choice.

  ELSE.

    old_ok_code = 'DISPLAY'.
    CLEAR l_choice.

  ENDIF.

ENDFORM.                                                    " verify1
*&---------------------------------------------------------------------*
*&      Form  check_tel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_tel.

  IF    ( ( old_ok_code = 'DISPLAY' OR old_ok_code = 'CHANGE' OR
         old_ok_code = 'DELETE'
         OR old_ok_code = 'RELEASE' OR old_ok_code = 'APPROVE' )
         AND g_hd_copied = 'X' )
         OR ( old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' ).
    DATA : tel_len TYPE i.
    tel_len = strlen( zic_prep_rolereq-telno ).
    IF  zic_prep_rolereq-telno CN ' 0123456789-'.
      MESSAGE i097(zhelp).
      CALL SCREEN 100.
    ELSE.
      IF tel_len < 7.
        MESSAGE i098(zhelp).
        CALL SCREEN 100.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_tel
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax.

  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr = zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC

***START OF COMMENT <RD1K983325>   CR: 30007580  dt: 05.04.2013.
*      g_ccode = ist_data-bukrs.
***end OF COMMENT <RD1K983325>.

**code added by CAB_AMITMOZA  <RD1K983325>   CR: 30007580  dt: 05.04.2013.
      g_ccode =  zic_prep_rolereq-ccode.
**code end by CAB_AMITMOZA  <RD1K983325>

    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.

    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.

      SELECT SINGLE * FROM zmm_prep_rolecrc WHERE role_type =
                      g_tablctrl110_wa-role_name.

      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE e117(zhelp).
      ENDIF.

    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                      g_tablctrl110_wa-role_name.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE e118(zhelp).
      ENDIF.

    ENDIF.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF old_ok_code = 'CRCROLES'.

      ELSE.

        IF zmm_prep_roledes-mm_disc_flag = 'X'.

          IF zic_prep_rolereq-disc_mm_flag = 'X'.
          ELSE.
            ROLLBACK WORK.
            MESSAGE e081(zhelp) WITH g_tablctrl110_wa-role_name.
          ENDIF.

        ENDIF.

      ENDIF.

*  endif.

      IF NOT g_tablctrl110_wa-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                   TABLE it_bukrs  WHERE bukrs = zic_prep_rolereq-ccode
                                      AND werks = g_tablctrl110_wa-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH g_tablctrl110_wa-role_name.

        ENDIF.

      ENDIF.


************finding group*******************

      REFRESH : it_cond, it_t024, it_t024_1.
*  clear   : it_cond, it_t024, it_t024_1.
*  clear   : wa_t024.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.
*
*
* if  g_TABLCTRL110_wa-role_name = 'M6' or
*     g_TABLCTRL110_wa-role_name = 'M7' or
*     g_TABLCTRL110_wa-role_name = 'M8'.
*
* else.
*
*      if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*            loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) between '0' and 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*
*      else.
*
*          loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) < '0'  or
*              l_ekgrp+1(1) > 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*      endif.
*
* endif.
*
**
      IF g_tablctrl110_wa-role_name = 'M6' OR
          g_tablctrl110_wa-role_name = 'M7' OR
          g_tablctrl110_wa-role_name = 'M8'.
        CONCATENATE '%' g_ccode '%' INTO g_line1.
        SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
      ELSE.
        IF zic_prep_rolereq-disc_mm_flag <> 'X'.
          CONCATENATE '%' g_ccode '%' 'IND' '%'
          INTO g_line1.
          SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
        ELSE.
          CONCATENATE  '%' g_ccode '%' 'MM' '%'
          INTO g_line1.
          SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
        ENDIF.
      ENDIF.
**
      IF  NOT g_tablctrl110_wa-grp IS INITIAL.

        LOOP AT it_t024 INTO wa_t024.

          IF g_tablctrl110_wa-grp = wa_t024-ekgrp.
            grp_flag = 'X'.
          ENDIF.

        ENDLOOP.

        IF grp_flag = 'X'.
          CLEAR grp_flag.
        ELSE.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          ROLLBACK WORK.
          MESSAGE i069(zhelp).
          CALL SCREEN 100.

        ENDIF.

      ENDIF.

***************************

      CLEAR : l_zarea, wa_t001l.
      REFRESH it_t001l.

      IF ( g_tablctrl110_wa-role_name = 'M13' OR
         g_tablctrl110_wa-role_name = 'M14' OR
          g_tablctrl110_wa-role_name = 'M16' OR
          g_tablctrl110_wa-role_name = 'M18' OR
          g_tablctrl110_wa-role_name = 'M19' ) AND
          NOT g_tablctrl110_wa-plant IS INITIAL.

        SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
                     TABLE it_t001l  WHERE werks = g_tablctrl110_wa-plant.

        IF  sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE e074(zhelp).

        ENDIF.

      ENDIF.

      IF zic_prep_rolereq-disc_mm_flag = 'X'.

        LOOP AT it_t001l INTO wa_t001l.

          SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

          IF sy-subrc = 0.

            IF l_zarea+0(1) <> 'M'.
              DELETE it_t001l.
            ENDIF.

          ELSE.

            DELETE it_t001l.

          ENDIF.

        ENDLOOP.

      ELSE.

        LOOP AT it_t001l INTO wa_t001l.

          SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

          IF sy-subrc = 0.

            IF l_zarea+0(1) = 'M'.
              DELETE it_t001l.
            ENDIF.

          ELSE.

            DELETE it_t001l.

          ENDIF.

        ENDLOOP.

      ENDIF.

      IF  NOT g_tablctrl110_wa-sloc IS INITIAL.

        LOOP AT it_t001l INTO wa_t001l.

          IF g_tablctrl110_wa-sloc = wa_t001l-lgort.
            loc_flag = 'X'.
          ENDIF.

        ENDLOOP.

        IF loc_flag = 'X'.
          CLEAR loc_flag.
        ELSE.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          ROLLBACK WORK.
          MESSAGE e073(zhelp).

        ENDIF.

      ENDIF.


***************************

      CLEAR wa_recpt.
      REFRESH it_recpt.

      IF ( g_tablctrl110_wa-role_name = 'M12' OR
         g_tablctrl110_wa-role_name = 'M17' ) AND
         NOT g_tablctrl110_wa-receipt_loc IS INITIAL.

        SELECT * FROM zmm_location INTO TABLE it_recpt.

        IF g_tablctrl110_wa-role_name = 'M12'.

          LOOP AT it_recpt INTO wa_recpt.

            IF wa_recpt-loccg <> 'RL'.
              DELETE it_recpt.
            ENDIF.

          ENDLOOP.

        ENDIF.


        IF g_tablctrl110_wa-role_name = 'M17'.

          LOOP AT it_recpt INTO wa_recpt.

            IF wa_recpt-loccg <> 'CF'.
              DELETE it_recpt.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

      IF  NOT g_tablctrl110_wa-receipt_loc IS INITIAL.

        LOOP AT it_recpt INTO wa_recpt.

          IF g_tablctrl110_wa-receipt_loc = wa_recpt-loccd.
            loc_flag = 'X'.
          ENDIF.

        ENDLOOP.

        IF loc_flag = 'X'.
          CLEAR loc_flag.
        ELSE.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          ROLLBACK WORK.
          MESSAGE e075(zhelp).

        ENDIF.

      ENDIF.


*****************************

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax
*&---------------------------------------------------------------------*
*&      Form  attach_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_files.

  CLEAR g_att_files_wa.
  REFRESH g_att_files.

  g_att_files_wa-logsys = zic_prep_rolereq-docno+2(10).
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  APPEND g_att_files_wa TO g_att_files.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
    EXPORTING
      attachment_data     = ''
      attachment_type     = 'DOC'
    TABLES
      application_objects = g_att_files.


ENDFORM.                    " attach_files
*&---------------------------------------------------------------------*
*&      Form  list_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files.

  g_att_files_wa-logsys = zic_prep_rolereq-docno+2(10).
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = g_att_files_wa
*     FUNCTION           = ' '
* TABLES
*     FUNC_EXCLUDE       =
    .

ENDFORM.                    " list_files
*&---------------------------------------------------------------------*
*&      Form  pop_up_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = 'Choosing Location '
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'It is understood that user has joined at new
*location & HR Data'
*     TEXTLINE2 = 'is updated. Please choose appropriate current
*location?'
      textline1 = 'It is understood that user has joined' &
                  ' at new location & HR Data'
      textline2 = 'is updated. Please choose appropriate' &
                  ' current location?'
* end of <RD1K960036>
*     START_COLUMN       = 25
*     START_ROW = 6
    .

ENDFORM.                    " pop_up_message
*&---------------------------------------------------------------------*
*&      Form  items_approval_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM items_approval_check.
  SELECT * FROM zic_prep_rolerei INTO TABLE ist_itemtab
  WHERE docno = zic_prep_rolereq-docno.
  LOOP AT ist_itemtab INTO wa_itemtab.
    IF wa_itemtab-rej_fl IS INITIAL.
** Header level changes for integration
      PERFORM validate_role_approval_level.
    ENDIF.
  ENDLOOP.
  CLEAR ist_itemtab.
  REFRESH ist_itemtab[].
  CLEAR wa_itemtab.
**      if sy-subrc = 0.
** Messages to be checked modulewise in sub
  PERFORM clear1.
  IF old_ok_code = 'CROSSCO' OR
        zic_prep_rolereq-crossco_fl = 'X'.

    IF old_ok_code = 'RELEASE' OR
        old_ok_code = 'CROSSCO' OR
        old_ok_code = 'CHANGE'.
      PERFORM popup_release_message.
    ENDIF.

    IF old_ok_code = 'APPROVE' OR
       zic_prep_rolereq-status = 'IF'.
      PERFORM popup_approve_message.
    ENDIF.

    PERFORM pop_up_crossco_message.          .
*          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
    MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.

  ELSE.
    IF old_ok_code = 'CRCROLES' OR
      zic_prep_rolereq-crc_fl = 'X'.
      IF old_ok_code = 'RELEASE' OR
         old_ok_code = 'CRCROLES' OR
         old_ok_code = 'CHANGE'.
        PERFORM popup_release_message.
      ENDIF.
      IF old_ok_code = 'APPROVE' OR
         zic_prep_rolereq-status = 'IF'.
        PERFORM popup_approve_message.
      ENDIF.
      PERFORM pop_up_crc_message.
*              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      g_crc_fl = 'X'.
    ELSE.
      IF old_ok_code = 'RELEASE'.
        PERFORM popup_release_message.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF old_ok_code = 'APPROVE'.
        .               PERFORM popup_approve_message.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF old_ok_code = 'CREATE' OR old_ok_code =
'CHANGE'.
        PERFORM popup_release_message1.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF zic_prep_rolereq-status = 'IF'.
        PERFORM popup_approve_message.
      ELSE.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ENDIF.
  ENDIF.
**      endif.
ENDFORM.                    " items_approval_check
*&---------------------------------------------------------------------*
*&      Form  pop_up_crc_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_crc_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = 'CRC Authorizations '
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Please attach the scanned order copy with the
*request or '
      textline1 = 'Please attach the scanned order copy with' &
                  ' the request or '
* end of <RD1K960036>
      textline2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN       = 25
*     START_ROW = 6
    .

ENDFORM.                    " pop_up_crc_message
*&---------------------------------------------------------------------*
*&      Form  pop_up_crossco_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_crossco_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = 'Cross Company Authorisations '
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Please attach the scanned order copy with the
*request or '
      textline1 = 'Please attach the scanned order copy' &
                  ' with the request or '
* end of <RD1K960036>
      textline2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN       = 25
*     START_ROW = 6
    .

ENDFORM.                    " pop_up_crossco_message
*&---------------------------------------------------------------------*
*&      Form  validate_role_approval_level
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_role_approval_level.

  SELECT SINGLE * FROM zmm_prep_rolegrp
       WHERE role_type = wa_itemtab-role_name.

  IF sy-subrc = 0.

    IF zmm_prep_rolegrp-approver1 = 'L3' AND
                 g_approver_level = 'L3'.

    ELSEIF zmm_prep_rolegrp-approver1 = 'IM' AND
                 g_approver_level = 'L3'.
      g_approver_level = 'IM'.
    ELSEIF  zmm_prep_rolegrp-approver1 = 'L1' AND
                 ( g_approver_level = 'L3' OR
                   g_approver_level = 'IM' ).
      g_approver_level = 'L1'.
    ENDIF.

  ENDIF.

ENDFORM.                    " validate_role_approval_level
*&---------------------------------------------------------------------*
*&      Form  popup_release_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_release_message.

  IF g_approver_level = 'IM'.
    g_approver_level = 'I/C MM'.
  ENDIF.

  CONCATENATE 'Kindly get the request approved by competent authority: '
  g_approver_level ' or above' INTO g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Approval Requirement'
      textline1 = g_approve_text
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE2 = 'Request for authorization will be routed to
*ICE core team only '
      textline2 = 'Request for authorization will be' &
                  ' routed to ICE core team only '
* end of <RD1K960036>
      textline3 = 'after requisite approval '
*     START_COLUMN       = 15
*     START_ROW = 6
    .
  CLEAR : g_approver_level, g_approve_text.
ENDFORM.                    " popup_release_message
*&---------------------------------------------------------------------*
*&      Form  popup_approve_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_approve_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Request Processing'
      textline1 = g_approve_text
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE2 = 'The request will now be processed by ICE core
* team & '
*     TEXTLINE3 = 'user will get updated message once the
*request is processed '
      textline2 = 'The request will now be processed by'
                  & ' ICE core team & '
      textline3 = 'user will get updated message once' &
                  ' the request is processed '
* end of <RD1K960036>
*     START_COLUMN       = 15
*     START_ROW = 6
    .
ENDFORM.                    " popup_approve_message
*&---------------------------------------------------------------------*
*&      Form  verify2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify2.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Request Status IR'
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Please go to display mode & reply the query
*of the ICE core team in '
*     TEXTLINE2 = 'correspondence  &  save the request.  No re-
*release or approval reqd.'
*     TEXTLINE3 = 'The request will go directly to ICE core team
* for further processing.'.
      textline1 = 'Please go to display mode & reply the' &
                  ' query of the ICE core team in '
      textline2 = 'correspondence  &  save the request.  No' &
                  ' re-release or approval reqd.'
      textline3 = 'The request will go directly to ICE core' &
                  ' team for further processing.'.
* end of <RD1K960036>

  old_ok_code = 'DISPLAY'.
ENDFORM.                                                    " verify2
*&---------------------------------------------------------------------*
*&      Form  popup_release_message1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_release_message1.
  IF g_approver_level = 'IM'.
    g_approver_level = 'I/C MM'.
  ENDIF.

* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*  concatenate g_approver_level ' or above. Request  for  authorization
*will be routed to ICE core' into g_approve_text.
  CONCATENATE g_approver_level
             ' or above. Request  for  authorization will be'
             ' routed to ICE core'
    INTO g_approve_text
    SEPARATED BY space.
* end of <RD1K960036>
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Approval Requirement'
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Kindly self release the  request  &  get it
*approved by competent authority:'
      textline1 = 'Kindly self release the  request  &' &
                  ' get it approved by competent authority:'
* end of <RD1K960036>
      textline2 = g_approve_text
      textline3 = 'team only after requisite approval '
*     START_COLUMN       = 15
*     START_ROW = 6
    .
  CLEAR : g_approver_level, g_approve_text.
ENDFORM.                    " popup_release_message1
*&---------------------------------------------------------------------*
*&      Form  clear1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear1.

  CLEAR   : help_list_flag.
  REFRESH : it_m_fistb.
  CLEAR   : dynnr.

ENDFORM.                                                    " clear1
*&---------------------------------------------------------------------*
*&      Form  insert_items_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pm.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl111_itab
  BY role_name plant shop_no.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl111_itab
    COMPARING role_name plant rej_fl shop_no.

  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

    MOVE-CORRESPONDING g_tablctrl111_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
         wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

    IF old_ok_code = 'CREATE'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM zic_prep_rolerei WHERE docno = zic_prep_rolereq-docno
        AND moduleid = moduleid.

    MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    IF sy-subrc = 0 AND g_role_flag <> 'X'.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_pm
***&--------------------------------------------------------------------
*-
***
***&      Form  check_items_save_pm
***&--------------------------------------------------------------------
*-
***
***       text
***---------------------------------------------------------------------
*-
***
***  -->  p1        text
***  <--  p2        text
***---------------------------------------------------------------------
*-
***
FORM check_items_save_pm.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zpm_prep_roledes-plant = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-plant IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE i084(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zpm_prep_roledes-shop_no = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-shop_no IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          ROLLBACK WORK.
          MESSAGE i095(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ( zic_prep_rolereq-ccode <> 'BDW' AND
         zic_prep_rolereq-ccode <> 'SBW' ).

        IF  ( zpm_prep_roledes-role_type = 'PM14' OR
            zpm_prep_roledes-role_type = 'PM15' OR
            zpm_prep_roledes-role_type = 'PM16' ).
          MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
          zic_prep_rolereq-ccode .
        ENDIF.
      ENDIF.

      IF wa_itemtab-role_name = 'PM8'.
        IF wa_itemtab-plant CS 'E1' OR
            wa_itemtab-plant CS 'E2' OR
            wa_itemtab-plant CS 'C1'.
        ELSE.
          MESSAGE e202(zhelp) WITH wa_itemtab-plant
          zpm_prep_roledes-role_type.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax11.

ENDFORM.                    " check_items_save_pm
*&---------------------------------------------------------------------*
*&      Form  check_module_wise
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_wise.

  CASE moduleid.

    WHEN 'MM'.

      PERFORM check_items_save.

    WHEN 'PM'.

      PERFORM check_items_save_pm.

    WHEN 'PS'.

      PERFORM check_items_save_ps.

    WHEN 'PP'.

      PERFORM check_items_save_pp.

    WHEN 'SD'.

      PERFORM check_items_save_sd.

    WHEN 'QM'.

      PERFORM check_items_save_qm.

    WHEN 'HSE'.

      PERFORM check_items_save_hs.

    WHEN 'OLM'.

      PERFORM check_items_save_olm.

  ENDCASE.
ENDFORM.                    " check_module_wise
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax11.

  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr = zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF NOT g_tablctrl111_wa-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                   TABLE it_bukrs  WHERE bukrs = zic_prep_rolereq-ccode
                                      AND werks = g_tablctrl111_wa-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH g_tablctrl111_wa-role_name.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax11
*&---------------------------------------------------------------------*
*&      Form  check_list_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_list_processing.
  IF g_list_proc_flag = 'X'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " check_list_processing
*&---------------------------------------------------------------------*
*&      Form  upload1_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload1_file.
  SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE it_roles.
  SELECT * FROM zhelp_pmroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_pm.
  SELECT * FROM zhelp_psroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_ps.
  SELECT * FROM zhelp_pproles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_pp.
  SELECT * FROM zhelp_pproles1 INTO CORRESPONDING FIELDS OF TABLE
  it_roles1_pp.
  SELECT * FROM zhelp_sdroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_sd.
  SELECT * FROM zhelp_qmroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_qm.
  SELECT * FROM zhelp_hsroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_hs.
  SELECT * FROM zhelp_olmroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_olm.

ENDFORM.                    " upload1_file
*&---------------------------------------------------------------------*
*&      Form  auth_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check.
  READ TABLE it_module1 INTO wa_module1 INDEX 1.
  SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE
 BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF wa_module1-moduleid = 'PS'.
    moduleid = wa_module1-moduleid.
  ELSE.
    moduleid = zauth_user-primary_module.
  ENDIF.

  IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
   moduleid = wa_module1-moduleid.
  ENDIF.


  IF moduleid = 'MM'.

    SELECT SINGLE * FROM zmm_prep_usrcont WHERE
                bname = sy-uname.
    IF sy-subrc <> 0.
      MESSAGE i104(zhelp).
      old_ok_code = 'DISPLAY'.
    ELSE.
      PERFORM auth_check1.
*   old_ok_code = 'CHANGE'.
    ENDIF.
***
  ELSE.
    IF zauth_user-approve_flag <> 'X'.
      MESSAGE i104(zhelp).
      old_ok_code = 'DISPLAY'.
    ENDIF.
***
  ENDIF.

ENDFORM.                    " auth_check
*&---------------------------------------------------------------------*
*&      Form  auth_check1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check1.
  IF zic_prep_rolereq-crc_fl = 'X' AND
     zmm_prep_usrcont-crc_app = 'X'.
*     old_ok_code = 'CHANGE'.
  ELSEIF
     zic_prep_rolereq-crossco_fl = 'X' AND
     zmm_prep_usrcont-crossco_app = 'X'.
*     old_ok_code = 'CHANGE'.
  ELSE.
    IF  zmm_prep_usrcont-gen_app = 'X' AND
        zic_prep_rolereq-crc_fl <> 'X' AND
          zic_prep_rolereq-crossco_fl <> 'X' .
*         old_ok_code = 'CHANGE'.
    ELSE.
      MESSAGE i104(zhelp).
      old_ok_code = 'DISPLAY'.
    ENDIF.
  ENDIF.

ENDFORM.                    " auth_check1
*&---------------------------------------------------------------------*
*&      Form  change_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_status.

  PERFORM fill_sttab.

  IF old_ok_code = 'CREATE' OR old_ok_code = 'CHANGE' OR
      old_ok_code = 'DISPLAY' OR old_ok_code = 'DELETE'.

    SET PF-STATUS 'OPTNS1' EXCLUDING it_tab.

  ELSE.

    SET PF-STATUS 'OPTNS'.

  ENDIF.

  CASE sy-ucomm.
    WHEN 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Request'.
    WHEN 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Change Request'.
    WHEN 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Display Request'.
    WHEN 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Delete Request'.
    WHEN 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Release Request'.

    WHEN OTHERS.
      SET TITLEBAR 'PREP_TITLE' WITH ''.
  ENDCASE.

ENDFORM.                    " change_status
*&---------------------------------------------------------------------*
*&      Form  create_roles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles INTO wa_roles.

    PERFORM check_mum.
    APPEND wa_roles TO it_roles0.

  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles.

    IF NOT wa_roles-role_type IS INITIAL.

      LOOP AT g_tablctrl110_itab INTO wa_rolesz.
        IF wa_roles-role_type = wa_rolesz-role_name AND
                                wa_rolesz-rej_fl = '' AND
                                wa_rolesz-status = '' AND
                                wa_rolesz-role_request = ''.
          PERFORM insert_data.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT g_tablctrl110_itab INTO wa_rolesz.
*Begin of <RD1K964305>.
*    IF WA_ROLESZ-ROLE_NAME+0(1) = 'C' AND
*    IF ( wa_rolesz-role_name+0(1) = 'C' OR wa_rolesz-role_name+0(1) = 'N' )  AND
*End of <RD1K964305>.
                    if   wa_rolesz-rej_fl = '' AND
                         wa_rolesz-status = '' AND
                         wa_rolesz-role_request = ''.
      PERFORM insert_data_addl.
    ENDIF.
  ENDLOOP.

  SORT it_roles1.

**** Deleting tempelate as it gets added in logic

  LOOP AT it_roles1 INTO wa_role_del_data.

    IF wa_role_del_data-role_name = 'D:MM_SRV_IND_APPROVE_XX'
     OR wa_role_del_data-role_name = 'D:MM_PUR_PO_APPROVE_XX'.
      DELETE it_roles1.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.

***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.

*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles
*&---------------------------------------------------------------------*
*&      Form  confirm_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_mail.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            TEXTLINE1 = text-008
*            TITEL     = text-009
*       IMPORTING
*            ANSWER    = g_ans_mail.

*  If g_ans_mail = 'J'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-009
*     DIAGNOSE_OBJECT             = ' '
      text_question  = text-008
      text_button_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = g_ans_mail
*    TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF g_ans_mail EQ '1'.
* end of <RD1K960036>
    PERFORM send_sapmail.
  ENDIF.

  CLEAR object_content.
  REFRESH object_content.

ENDFORM.                    " confirm_mail
*&---------------------------------------------------------------------*
*&      Form  SEND_SAPMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sapmail.

*--- Send mail to user

*
  document_data-obj_langu  = sy-langu.
  document_data-obj_name   = 'ICE Core Team'.
  document_data-obj_descr  = 'Mail from ICE Core Team'.
  SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  CONCATENATE document_data-obj_descr '---' zauth_user-primary_module
  '-' 'Module' INTO document_data-obj_descr.
  document_data-priority   = '3'.

* Remove prefix 'US' from receiver
  REFRESH receivers.

  CLEAR wa_receivers.
  wa_receivers-receiver = zic_prep_rolereq-useridcr.
  wa_receivers-rec_type = 'B'.
  wa_receivers-express  = 'X'.
  APPEND wa_receivers TO receivers.

  CLEAR wa_receivers.

  MOVE space TO object_content-line.
  APPEND object_content.

  CONCATENATE  'Subject: '  'Creation of Roles for userid '
zic_prep_rolereq-userid INTO  object_content-line
SEPARATED BY space.
  APPEND object_content.

  MOVE space TO object_content-line.
  APPEND object_content.
  IF zic_prep_rolereq-status = 'C'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      concatenate 'Please  check  your role request  which  has  been
*assigned  &  completed - ' zic_prep_rolereq-docno into
    CONCATENATE 'Please  check  your role request  which  has'
     'been assigned  &  completed - ' zic_prep_rolereq-docno INTO
* end of <RD1K960036>
object_content-line
SEPARATED BY space.
    APPEND object_content.
  ELSE.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      concatenate 'Please check your role request which has been updated
* - ' zic_prep_rolereq-docno into  object_content-line
    CONCATENATE 'Please check your role request which has been' &
     ' updated - ' zic_prep_rolereq-docno INTO  object_content-line
* end of <RD1K960036>
SEPARATED BY space.
    APPEND object_content.
  ENDIF.
********************************************************************
  IF zic_prep_rolereq-status = 'IC'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Please go through correspondence in the request. The request
* needs to be changed, re-released & re-approved by competent authority.
*Once the request is approved, the request will flow to ICE core team.'
    MOVE 'Please go through correspondence in the request. The' &
         ' request needs to be changed, re-released & re-approved' &
         ' by competent authority. Once the request is approved, the' &
         ' request will flow to ICE core team.'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
  ENDIF.
  IF zic_prep_rolereq-status = 'IR'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Please go through the correspondence in the request & reply
*to the query raised by ICE core team. You need to save the request after
* giving reply in correspondence(In display mode only). Once the request
*is saved, the request will flow to ICE core team.'
    MOVE 'Please go through the correspondence in the request &' &
         ' reply to the query raised by ICE core team. You need to' &
         ' save the request after giving reply in correspondence' &
         '(In display mode only). Once the request is saved, the' &
         ' request will flow to ICE core team.'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     Move 'No re-release or approvals are required in this case & user
*will not be able to open the request in change mode.'
    MOVE 'No re-release or approvals are required in this case &' &
         ' user will not be able to open the request in change mode.'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
  ENDIF.
  IF zic_prep_rolereq-status = 'PC'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Your request is still under process with ICE core team. Only
* partial roles have been assigned. You will get the next message'
    MOVE 'Your request is still under process with ICE core team.' &
         ' Only partial roles have been assigned. You will get the' &
         ' next message'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
    MOVE 'for completion or return of request soon.' TO
object_content-line.
    APPEND object_content.
  ENDIF.
********************************************************************
  MOVE space TO object_content-line.
  APPEND object_content.

  object_content-line = 'ICE Core Team'.
  APPEND object_content.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = document_data
      document_type              = 'RAW'
      put_in_outbox              = 'X'
    IMPORTING
      sent_to_all                = sent_to_all
    TABLES
      object_header              = objhead
      object_content             = object_content
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 01
      document_not_sent          = 02
      document_type_not_exist    = 03
      operation_no_authorization = 04
      parameter_error            = 05
      x_error                    = 06
      enqueue_error              = 07.

  CASE sy-subrc.
    WHEN 0.

      MESSAGE i060(zhelp) WITH zic_prep_rolereq-useridcr.
    WHEN '01'.
      RAISE too_many_receivers.
    WHEN '02'.
      RAISE document_not_sent.
    WHEN '03'.
      RAISE document_type_not_exist.
    WHEN '04'.
      RAISE operation_no_authorization.
    WHEN '05'.
      RAISE parameter_error.
    WHEN '06'.
      RAISE x_error.
    WHEN '07'.
      RAISE enqueue_error.
  ENDCASE.

********************************************
********************************************

ENDFORM.                    " SEND_SAPMAIL
*&---------------------------------------------------------------------*
*&      Form  hide
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hide.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.

ENDFORM.                    " hide
*&---------------------------------------------------------------------*
*&      Form  help_suim
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM help_suim.
  SELECT * FROM agr_users INTO TABLE it_agr_users
                  WHERE uname = zic_prep_rolereq-userid .

  REFRESH it_role_del_data.

  SORT it_agr_users DESCENDING BY from_dat to_dat.

  LOOP AT it_agr_users INTO wa_agr_users.
*
    IF wa_agr_users-from_dat <= sy-datum.
      WRITE: / wa_agr_users-agr_name,
             wa_agr_users-from_dat,
             wa_agr_users-to_dat.
      wa_role_del_data-userid = wa_agr_users-uname.
      wa_role_del_data-role_name = wa_agr_users-agr_name.
      APPEND wa_role_del_data TO it_role_del_data.
      HIDE :  wa_agr_users-agr_name,
              wa_agr_users-from_dat,
              wa_agr_users-to_dat.
      CLEAR :  wa_agr_users-agr_name,
               wa_agr_users-from_dat,
               wa_agr_users-to_dat.
      .
    ENDIF.
  ENDLOOP.
  lines = sy-linno .
  it_roles[] = it_role_del_data[].

  DESCRIBE TABLE it_role_del_data LINES g_lines1.

  IF g_lines1 > 0.
* begin of <RD1K960036>
* FM 'WS_DOWNLOAD' is obsolete
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**     BIN_FILESIZE                  = ' '
**     CODEPAGE                      = ' '
*       FILENAME                      = 'C:\role_upload.txt'
*       FILETYPE                      = 'DAT'
**     MODE                          = ' '
**     WK1_N_FORMAT                  = ' '
**     WK1_N_SIZE                    = ' '
**     WK1_T_FORMAT                  = ' '
**     WK1_T_SIZE                    = ' '
**     COL_SELECT                    = ' '
**     COL_SELECTMASK                = ' '
**     NO_AUTH_CHECK                 = ' '
**   IMPORTING
**     FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = it_role_del_data
**     FIELDNAMES                    =
*     EXCEPTIONS
*       FILE_OPEN_ERROR               = 1
*       FILE_WRITE_ERROR              = 2
*       INVALID_FILESIZE              = 3
*       INVALID_TYPE                  = 4
*       NO_BATCH                      = 5
*       UNKNOWN_ERROR                 = 6
*       INVALID_TABLE_WIDTH           = 7
*       GUI_REFUSE_FILETRANSFER       = 8
*       CUSTOMER_ERROR                = 9
*       OTHERS                        = 10
*              .

    DATA l_file TYPE string VALUE 'C:\role_upload.txt'.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        filename                = l_file
        filetype                = 'DAT'
*       APPEND                  = ' '
*       WRITE_FIELD_SEPARATOR   = ' '
*       HEADER                  = '00'
*       TRUNC_TRAILING_BLANKS   = ' '
*       WRITE_LF                = 'X'
*       COL_SELECT              = ' '
*       COL_SELECT_MASK         = ' '
*       DAT_MODE                = ' '
*       CONFIRM_OVERWRITE       = ' '
*       NO_AUTH_CHECK           = ' '
*       CODEPAGE                = ' '
*       IGNORE_CERR             = ABAP_TRUE
*       REPLACEMENT             = '#'
*       WRITE_BOM               = ' '
*       TRUNC_TRAILING_BLANKS_EOL       = 'X'
*       WK1_N_FORMAT            = ' '
*       WK1_N_SIZE              = ' '
*       WK1_T_FORMAT            = ' '
*       WK1_T_SIZE              = ' '
*       WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*       SHOW_TRANSFER_STATUS    = ABAP_TRUE
*   IMPORTING
*       FILELENGTH              =
      TABLES
        data_tab                = it_role_del_data
*       FIELDNAMES              =
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
* end of <RD1K960036>
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.

    CLEAR disp_flag.
    MESSAGE i059(zhelp).
    CLEAR old_ok_code.

  ENDIF.

ENDFORM.                    " help_suim
*&---------------------------------------------------------------------*
*&      Form  check_mum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_mum.

*     To be checked with Mehta & MVS Sharma ???
  IF zic_prep_rolereq-ccode = 'MUM'.
    SEARCH wa_roles-role_name FOR 'D:FM_LOGS_FFFFFFFF'.
    IF sy-subrc = 0.
      wa_roles-role_name = 'FM_LOGS_FFFFFFFF'.
    ENDIF.
    SEARCH wa_roles-role_name FOR 'FI_AP_LOGS_DISP_CCC'.
    IF sy-subrc = 0.
      wa_roles-role_name = 'FI_AP_LOGS_DISP_CCC_AL'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_mum
*&---------------------------------------------------------------------*
*&      Form  insert_data_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_pm.

  SEARCH wa_roles_pm-role_name FOR 'XXXX'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_pm-role_name.
    REPLACE 'YYY' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    REPLACE 'XXXX' WITH wa_rolesz_pm-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_pm-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

*
ENDFORM.                    " insert_data_pm
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_file.

  IF NOT p1_file IS INITIAL.

* Download the file on presentation server
* begin of <RD1K960036>
* Replaced obsolete FM 'WS_DOWNLOAD'
*    CALL FUNCTION 'WS_DOWNLOAD'
*         EXPORTING
*              filename                = p1_file
*              filetype                = 'DAT'
*         TABLES
*              data_tab                = it_roles1
*         EXCEPTIONS
*              file_open_error         = 1
*              file_write_error        = 2
*              invalid_filesize        = 3
*              invalid_type            = 4
*              no_batch                = 5
*              unknown_error           = 6
*              invalid_table_width     = 7
*              gui_refuse_filetransfer = 8
*              customer_error          = 9
*              OTHERS                  = 10.

    DATA l_file TYPE string.

    l_file = p1_file.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        filename                = l_file
        filetype                = 'DAT'
*       APPEND                  = ' '
*       WRITE_FIELD_SEPARATOR   = ' '
*       HEADER                  = '00'
*       TRUNC_TRAILING_BLANKS   = ' '
*       WRITE_LF                = 'X'
*       COL_SELECT              = ' '
*       COL_SELECT_MASK         = ' '
*       DAT_MODE                = ' '
*       CONFIRM_OVERWRITE       = ' '
*       NO_AUTH_CHECK           = ' '
*       CODEPAGE                = ' '
*       IGNORE_CERR             = ABAP_TRUE
*       REPLACEMENT             = '#'
*       WRITE_BOM               = ' '
*       TRUNC_TRAILING_BLANKS_EOL       = 'X'
*       WK1_N_FORMAT            = ' '
*       WK1_N_SIZE              = ' '
*       WK1_T_FORMAT            = ' '
*       WK1_T_SIZE              = ' '
*       WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*       SHOW_TRANSFER_STATUS    = ABAP_TRUE
*     IMPORTING
*       FILELENGTH              =
      TABLES
        data_tab                = it_roles1
*       FIELDNAMES              =
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
* end of <RD1K960036>
    IF sy-subrc <> 0.

      MESSAGE i061(zhelp) WITH text-053.

      EXIT.

    ENDIF.

  ENDIF.

ENDFORM.                    " DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  copy_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_values.

  IF NOT zrolereqno IS INITIAL.
    zic_prep_rolereq-req_no = zrolereqno.
  ENDIF.

ENDFORM.                    " copy_values
*&---------------------------------------------------------------------*
*&      Form  confirm_step
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_step.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'Y'
*            TEXTLINE1     = 'Role request being created'
*            TEXTLINE2     = 'Continue ??? '
*            TITEL         = 'Confirm'
*       IMPORTING
*            ANSWER        = gl_ans.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirm'
*     DIAGNOSE_OBJECT             = ' '
      text_question  = 'Role request being created' &
                       'Continue ??? '
      text_button_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = gl_ans
*    TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF gl_ans EQ '1'.
    CLEAR gl_ans.
    MOVE 'J' TO gl_ans.
  ELSEIF gl_ans EQ '2'.
    CLEAR gl_ans.
    MOVE 'N' TO gl_ans.
  ELSE.
    CLEAR gl_ans.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " confirm_step
*&---------------------------------------------------------------------*
*&      Form  insert_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_record.
  g_role_flag = 'X'.
ENDFORM.                    " insert_record
*&---------------------------------------------------------------------*
*&      Form  list_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_processing.

  IF gl_ans = 'J'.
    SUPPRESS DIALOG.
    LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 100.
    PERFORM write_list.
    g_list_proc_flag = 'X'.
    CLEAR gl_ans.
  ENDIF.

ENDFORM.                    " list_processing
*&---------------------------------------------------------------------*
*&      Form  write_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_list.

  SET PF-STATUS 'STATUS_130' EXCLUDING 'SEL'.

  READ TABLE it_roles1 INTO wa_roles1 INDEX 1.
  g_userid = wa_roles1-userid.
  l_color = 5.
  LOOP AT it_roles1 INTO wa_roles1.
    IF g_userid = wa_roles1-userid.
      WRITE : / wa_roles1-userid COLOR 1,wa_roles1-role_name COLOR 2.
    ELSE.
      WRITE : / wa_roles1-userid COLOR 3,wa_roles1-role_name COLOR 3.
    ENDIF.
    g_userid = wa_roles1-userid.
  ENDLOOP.

ENDFORM.                    " write_list
*&---------------------------------------------------------------------*
*&      Form  create_roles_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_pm.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_pm INTO wa_roles_pm.
    APPEND wa_roles_pm TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles_pm.

    IF NOT wa_roles_pm-role_type IS INITIAL.

      LOOP AT g_tablctrl111_itab INTO wa_rolesz_pm.
        IF wa_roles_pm-role_type = wa_rolesz_pm-role_name AND
                                wa_rolesz_pm-rej_fl = '' AND
                                wa_rolesz_pm-status = '' AND
                                wa_rolesz_pm-role_request = ''.
          PERFORM insert_data_pm.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  perform display_role_pm.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.

***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.

*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles_pm
*&---------------------------------------------------------------------*
*&      Form  insert_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data.

  SEARCH wa_roles-role_name FOR 'INPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    REPLACE 'INPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.
*
  SEARCH wa_roles-role_name FOR 'SSPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                  wa_roles1-role_name.
    REPLACE 'SSPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

  SEARCH wa_roles-role_name FOR 'PLANT'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    IF wa_roles-role_type = 'M15' OR wa_roles-role_type = 'M20'.
      wa_roles1-role_name = 'MM_INV_CCC_PLANT_PPPP'.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles1-role_name.
      REPLACE 'PPPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.

      APPEND wa_roles1 TO it_roles1.
    ELSE.
*End of <RD1K963151>.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                  wa_roles1-role_name.
      REPLACE 'PPPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.

    ENDIF.
  ENDIF.
  SEARCH wa_roles-role_name FOR 'POPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    REPLACE 'POPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

*
  SEARCH wa_roles-role_name FOR 'IGG'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    DATA : l_bukrs1 TYPE bukrs.
    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
               a~persk a~sbmod  c~designo c~r_p_cd c~version
             d~sdesig_text AS designation d~adesig_text AS adesignation
             d~disc_cd AS disc_cd
               INTO CORRESPONDING FIELDS OF TABLE ist_data1
          FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                   ON c~designo = d~desig_code AND
                       c~r_p_cd  = d~r_p_cd AND
                       c~version = d~version )
                    WHERE a~pernr = zic_prep_rolereq-userid AND
                          a~sprps = ' ' AND
                          a~endda = '99991231' AND
                          c~sprps = ' ' AND
                          c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      l_bukrs1 = ist_data1-bukrs.
    ENDIF.


*End of <RD1K963151>.
*Begin  of <RD1K963151>.
    """""""""""""""""""
    "added by lipsy on 9.03.2015 for cross-company RD1K996555
    IF  zic_prep_rolerei-moduleid = 'MM'.
      IF old_ok_code = 'APPROVE' AND   zic_prep_rolereq-crossco_fl = 'X' .
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                        wa_roles1-role_name.
      ELSE.
        "end of addition by lipsy on 9.03.2015  for cross-company RD1K996555

        """"""""""""""""""""

        REPLACE 'CCC' WITH l_bukrs1+0(3) INTO wa_roles1-role_name.
*    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
*                                  WA_ROLES1-ROLE_NAME.
*End of <RD1K963151>.

        """""""""""""""""""""""""""""""
        "added  by lipsy on 9.03.2015 for cross-company RD1K996555
      ENDIF.
    ENDIF.
    "end of addition  by lipsy on 9.03.2015 for cross-company RD1K996555
    """""""""""""""""""""""

    REPLACE 'IGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

*
  SEARCH wa_roles-role_name FOR 'SGG'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                        wa_roles1-role_name.
    REPLACE 'SGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.
*
  SEARCH wa_roles-role_name FOR 'PGG'.
  IF sy-subrc = 0.

    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    DATA : l_bukrs TYPE bukrs.
    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
               a~persk a~sbmod  c~designo c~r_p_cd c~version
             d~sdesig_text AS designation d~adesig_text AS adesignation
             d~disc_cd AS disc_cd
               INTO CORRESPONDING FIELDS OF TABLE ist_data
          FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                   ON c~designo = d~desig_code AND
                       c~r_p_cd  = d~r_p_cd AND
                       c~version = d~version )
                    WHERE a~pernr = zic_prep_rolereq-userid AND
                          a~sprps = ' ' AND
                          a~endda = '99991231' AND
                          c~sprps = ' ' AND
                          c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      l_bukrs = ist_data-bukrs.
    ENDIF.
***CODE ADDED BY CAB_AMITMOZA <RD1K983325>   CR: 30007580  dt: 05.04.2013.
    IF zic_prep_rolereq-crossco_fl = 'X'.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles1-role_name.
    ELSE.
**CODE END BY CAB_AMITMOZA <RD1K983325>
*End of <RD1K963151>.
*Begin  of <RD1K963151>.
*     REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
*                                    wa_roles1-role_name.
      REPLACE 'CCC' WITH l_bukrs+0(3) INTO wa_roles1-role_name.
*End of <RD1K963151>.
    ENDIF.
    REPLACE 'PGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

  SEARCH wa_roles-role_name FOR 'CCC'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    IF flag <> 'X'.
      wa_roles1-role_name = wa_roles-role_name.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                    wa_roles1-role_name.
*      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
    flag = 'X'.
    IF wa_roles-role_type = 'M12' OR wa_roles-role_type = 'M17'.
      REPLACE 'RR' WITH wa_rolesz-receipt_loc+0(2) INTO
                                              wa_roles1-role_name.


    ENDIF.

    APPEND wa_roles1 TO it_roles1.

    SELECT SINGLE * FROM zhelp_mmroles_rc WHERE
                        receipt_loc = wa_rolesz-receipt_loc AND
                        ccode = zic_prep_rolereq-ccode.
    IF sy-subrc = 0.
      wa_roles1-role_name = zhelp_mmroles_rc-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.



  ENDIF.

  SEARCH wa_roles-role_name FOR 'FM_LOGS'.
  IF sy-subrc = 0.
    flag = 'X'.
*BEGIN OF  <RD1K963151>.
    IF zic_prep_rolereq-ccode = 'OVL'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = 'D:FM_LOGS_OVL_ALL'.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
*END OF <RD1K963151>.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles-role_name.
      IF zic_prep_rolereq-fundc1 <> '' AND
            zic_prep_rolereq-fundc_fl = 'X'.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc1 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc2 <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc2 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc3 <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc3 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc4 <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc4 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

    ENDIF.
  ENDIF.
  SEARCH wa_roles-role_name FOR 'MM_SRV_SES_ACCEPT'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'YY' WITH wa_rolesz-approver INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.
*
  SEARCH wa_roles-role_name FOR 'MM_PUR_PO_APPROVE_ZZ'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'ZZ' WITH wa_rolesz-approver INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    IF zic_prep_rolereq-ccode = 'OVL'  AND wa_roles1-role_name = 'D:MM_DISPLAY_ALL'.
      wa_roles1-role_name = 'D:MM_OVL_DISPLAY_ALL'.
    ELSEIF zic_prep_rolereq-ccode = 'OVL'  AND wa_roles1-role_name = 'D:MM_DISPLAY_PM_PS_LIS_CIN'.
      wa_roles1-role_name = 'D:MM_OVL_DISPLAY_PM_PS_LIS_CIN'.
    ENDIF.
*End of <RD1K963151>.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

  CLEAR flag.

  IF wa_roles-role_type = 'M13'.
    IF flag1 <> 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.

**code added by CAB_AMITMOZA  RD1K983325   CR:30007580
      SELECT * FROM zmm_prep_role_sl WHERE
                werks = wa_rolesz-plant AND
                lgort = wa_rolesz-sloc.
**code end RD1K983325

***comment start by CAB_AMITMOZA  RD1K983325   CR:30007580
*      SELECT SINGLE * FROM zmm_prep_role_sl WHERE
*                werks = wa_rolesz-plant AND
*                lgort = wa_rolesz-sloc.
***comment end RD1K983325

        wa_roles1-role_name = zmm_prep_role_sl-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDSELECT.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M14'.
    IF flag1 <> 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      wa_roles1-role_name = zmm_prep_role_sl-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M16'.
    IF flag1 <> 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      wa_roles1-role_name = zmm_prep_role_sl-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M11S' OR
     wa_roles-role_type = 'M11M' OR
     wa_roles-role_type = 'M3'   OR
     wa_roles-role_type = 'M3A'  OR
     wa_roles-role_type = 'M3B'  .

    SEARCH wa_roles-role_name FOR 'XX'.
    IF sy-subrc = 0.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles-role_name.
      REPLACE 'XX' WITH wa_rolesz-approver INTO
                                    wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

**11/05/2007
  CLEAR flag.

ENDFORM.                    " insert_data
*&---------------------------------------------------------------------*
*&      Form  display_role_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_role_pm.
  wa_roles1-userid = zic_prep_rolereq-userid.
  wa_roles1-role_name = 'D:PM_DISPLAY'.
  APPEND wa_roles1 TO it_roles1.
ENDFORM.                    " display_role_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_status.
* begin of <RD1K960036>
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to change status to IC? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = status_choice.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Do you want to change status to IC? '
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
* Begin of <RD1K960611>
*   Worng variable was used in the previous change
*     ANSWER                = status_process
      answer                = status_choice
* End of <RD1K960611>
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* end of <RD1K960036>

ENDFORM.                    " confirm_status
*&---------------------------------------------------------------------*
*&      Form  confirm_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_process.
* begin of <RD1K960036>
* FM 'POPUP_TO_CONFIRM_STEP' is obsolete
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to process request after sav
*ing? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = status_process.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Do you want to process request after'
                              & ' saving?'
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = status_process
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " confirm_process

*&---------------------------------------------------------------------*
*&      Form  check_module_status_mm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_mm.
  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    mm_not_ok = 'X'.
  ENDIF.
ENDFORM.                    " check_module_status_mm
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_pm.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    pm_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_message.
* begin of <RD1K960036>
* FM 'POPUP_TO_CONFIRM_STEP' is obsolete.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'N'
*            TEXTLINE1     = 'This is a multiple module request. If u con
*tinue with correspondence,'
*            TEXTLINE2     = 'other modules will not be able to process t
*heir part of the request,OK'
*            TITEL         = 'Confirm'
*       IMPORTING
*            ANSWER        = gl_ans.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirm'
*     DIAGNOSE_OBJECT             = ' '
      text_question  = 'This is a multiple module request.' &
                       ' If u continue with correspondence,' &
                       ' other modules will not be able to' &
                       ' process their part of the request,OK'
      text_button_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
      default_button = '2'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = gl_ans
*   TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF gl_ans EQ '1'.
    CLEAR gl_ans.
    MOVE 'Y' TO gl_ans.
  ELSEIF gl_ans EQ '2'.
    CLEAR gl_ans.
    MOVE 'N' TO gl_ans.
  ELSE.
    CLEAR gl_ans.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " confirm_message
*&---------------------------------------------------------------------*
*&      Form  create_roles_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_ps.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_ps INTO wa_roles_ps.
    APPEND wa_roles_ps TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_ps.

    IF NOT wa_roles_ps-role_type IS INITIAL.

      LOOP AT g_tablctrl112_itab INTO wa_rolesz_ps.
        IF wa_roles_ps-role_type = wa_rolesz_ps-role_name AND
                                wa_rolesz_ps-rej_fl = '' AND
                                wa_rolesz_ps-status = '' AND
                                wa_rolesz_ps-role_request = ''.
          PERFORM insert_data_ps.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
*
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.
*
**
*  clear : flag, flag1.

ENDFORM.                    " create_roles_ps
*&---------------------------------------------------------------------*
*&      Form  insert_data_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_ps.

  SEARCH wa_roles_ps-role_name FOR 'CCC'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'AAA'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'AAA' WITH wa_rolesz_ps-asset INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'BBB'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'BBB' WITH wa_rolesz_ps-basin INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'XXYY'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'XX' WITH wa_rolesz_ps-project INTO
                                wa_roles1-role_name.
    REPLACE 'YY' WITH wa_rolesz_ps-location INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'ZZZ'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'ZZZ' WITH 'ALL' INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

ENDFORM.                    " insert_data_ps
*&---------------------------------------------------------------------*
*&      Form  insert_items_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_ps.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl112_itab
  BY role_name service project location asset basin.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl112_itab
    COMPARING role_name rej_fl service project location
    asset basin.

  LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.

    MOVE-CORRESPONDING g_tablctrl112_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
        wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

    IF old_ok_code = 'CREATE'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_ps
*&---------------------------------------------------------------------*
*&      Form  check_items_save_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_ps.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zps_prep_roledes-service = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-service IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
          ROLLBACK WORK.
          MESSAGE i084(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zps_prep_roledes-project = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-project IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
          ROLLBACK WORK.
          MESSAGE i095(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax12.

ENDFORM.                    " check_items_save_ps
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax12.
  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr = zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF NOT g_tablctrl112_wa-service IS INITIAL.
**?
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH g_tablctrl112_wa-role_name.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax12
*&---------------------------------------------------------------------*
*&      Form  check_module_status_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_ps.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    ps_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_ps
*&---------------------------------------------------------------------*
*&      Form  create_roles_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_pp.
  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_pp INTO wa_roles_pp.
    APPEND wa_roles_pp TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_pp.

    IF NOT wa_roles_pp-role_type IS INITIAL.

      LOOP AT g_tablctrl113_itab INTO wa_rolesz_pp.
        IF wa_roles_pp-role_type = wa_rolesz_pp-role_name AND
                                wa_rolesz_pp-rej_fl = '' AND
                                wa_rolesz_pp-status = '' AND
                                wa_rolesz_pp-role_request = ''.
          PERFORM insert_data_pp.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT it_roles1_pp INTO wa_roles1_pp.

    IF NOT wa_roles_pp-role_type IS INITIAL.

      LOOP AT g_tablctrl113_itab INTO wa_rolesz_pp.
        IF wa_roles1_pp-role_type = wa_rolesz_pp-role_name AND
               wa_roles1_pp-plant = wa_rolesz_pp-plant    AND
                                wa_rolesz_pp-rej_fl = '' AND
                                wa_rolesz_pp-status = '' AND
                                wa_rolesz_pp-role_request = ''.
          PERFORM insert_data1_pp.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT g_tablctrl113_itab INTO wa_rolesz_pp.
    IF  wa_rolesz_pp-rej_fl = '' AND
        wa_rolesz_pp-status = '' AND
        wa_rolesz_pp-role_request = ''.
      PERFORM insert_data3_pp.
    ENDIF.
  ENDLOOP.

*  PERFORM insert_data2_pp.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  PERFORM modify_data4_pp.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
*
  PERFORM list_processing.
*
ENDFORM.                    " create_roles_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_pp.

  SEARCH wa_roles_pp-role_name FOR 'XXXX'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'XXXX'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'XXXX' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'YYYY'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'YYYY'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'YYYY' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'AAAA'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
         role_type = wa_rolesz_pp-role_name AND
         plant     = wa_rolesz_pp-plant    AND
         plant_gen = 'AAAA'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'AAAA' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'BBBB'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'BBBB'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'BBBB' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'CCCC'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'CCCC'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'CCCC' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'DDDD'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'DDDD'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'DDDD' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'EEEE'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'EEEE'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'EEEE' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'FFFF'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'FFFF'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'FFFF' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.

  IF wa_flag <> 'X' AND wa_flag1 <> 'X'.
    SEARCH wa_roles_pp-role_name FOR 'ZZZZ'.
    IF sy-subrc <> 0.
      CLEAR :wa_flag, wa_flag1.
      SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant.
      IF sy-subrc = 0.
        wa_roles1-userid = zic_prep_rolereq-userid.
        wa_roles1-role_name = wa_roles_pp-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
    ELSE.
    ENDIF.
  ENDIF.

  IF wa_rolesz_pp-role_name = 'PP3'.

    SEARCH wa_roles_pp-role_name FOR 'ZZZZ'.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'AAAA'.
      IF sy-subrc = 0.
        wa_roles1-userid = zic_prep_rolereq-userid.
        wa_roles1-role_name = wa_roles_pp-role_name.
        REPLACE 'ZZZZ' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
        SELECT * FROM ZPP_PREP_RES UP TO 1 ROWS
 WHERE
 ROLE_TYPE = WA_ROLESZ_PP-ROLE_NAME AND PLANT = WA_ROLESZ_PP-PLANT AND RES = WA_ROLESZ_PP-RES
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        CONCATENATE wa_roles1-role_name zpp_prep_res-res_code INTO
        wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
    ENDIF.

  ENDIF.

  CLEAR : wa_flag, wa_flag1.

ENDFORM.                    " insert_data_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pp.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl113_itab
  BY role_name plant sloc res ctf_sloc.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl113_itab
    COMPARING role_name rej_fl plant sloc res
    ctf_sloc.

  LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.

    MOVE-CORRESPONDING g_tablctrl113_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
       wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_pp
*&---------------------------------------------------------------------*
*&      Form  check_items_save_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_pp.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

*      if zpp_prep_roledes-plant = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-plant is initial.
*          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
*          rollback work.
*          message i074(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*     if zpp_prep_roledes-sloc = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-sloc is initial.
*          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
*          rollback work.
*          message i090(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zpp_prep_roledes-res = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-res is initial.
*          g_field = 'ZIC_PREP_ROLEREI-RES'.
*          rollback work.
*          message i184(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zpp_prep_roledes-ctf_sloc = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-ctf_sloc is initial.
*          g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
*          rollback work.
*          message i090(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
******
    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax13.

ENDFORM.                    " check_items_save_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data1_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data1_pp.

  IF wa_rolesz_pp-role_name = 'PP1' OR
     wa_rolesz_pp-role_name = 'PP2' OR
     wa_rolesz_pp-role_name = 'PP10'.
    SELECT * FROM  zhelp_pproles1 INTO TABLE it_roles1_pp_tmp WHERE
    role_type = wa_rolesz_pp-role_name AND
    plant = wa_rolesz_pp-plant.
    IF sy-subrc = 0.
      LOOP AT it_roles1_pp_tmp INTO wa_roles1_pp.
        wa_roles1-userid = zic_prep_rolereq-userid.
        wa_roles1-role_name = wa_roles1_pp-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                    " insert_data1_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data2_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data2_pp.

*  if not wa_flag is initial.
*    WA_ROLES1-USERID = zic_prep_rolereq-userid.
*    WA_ROLES1-ROLE_NAME = 'PP_DIS_PROFILES_ALL'.
*    APPEND WA_ROLES1 to IT_ROLES1.
*    clear wa_flag.
*  endif.

ENDFORM.                    " insert_data2_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data3_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data3_pp.

  IF wa_rolesz_pp-role_name = 'PP4' OR
      wa_rolesz_pp-role_name = 'PP8'.
    SELECT SINGLE * FROM  zpp_prep_droleex INTO wa_roles2_pp WHERE
    role_type = wa_rolesz_pp-role_name AND
    plant = wa_rolesz_pp-plant         AND
    sloc  = wa_rolesz_pp-sloc          AND
    ctf_sloc = wa_rolesz_pp-ctf_sloc.
    IF sy-subrc = 0.
      SELECT * FROM zpp_prep_drole INTO TABLE it_roles3_pp WHERE
          plant = wa_rolesz_pp-plant AND
          sloc  = wa_rolesz_pp-sloc  AND
          ctf_sloc = wa_rolesz_pp-ctf_sloc.
    ELSE.
      SELECT * FROM zpp_prep_drole INTO TABLE it_roles3_pp WHERE
          plant = wa_rolesz_pp-plant AND
          sloc  = wa_rolesz_pp-sloc  AND
          ctf_sloc = ''.
    ENDIF.
  ENDIF.

  LOOP AT it_roles3_pp INTO wa_roles3_pp.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles3_pp-drole.
    APPEND wa_roles1 TO it_roles1.
  ENDLOOP.
ENDFORM.                    " insert_data3_pp
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_pp.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    pp_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_pp
*&---------------------------------------------------------------------*
*&      Form  create_roles_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_sd.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_sd INTO wa_roles_sd.
    APPEND wa_roles_sd TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_sd.

    IF NOT wa_roles_sd-role_type IS INITIAL.

      LOOP AT g_tablctrl114_itab INTO wa_rolesz_sd.
        IF wa_roles_sd-role_type = wa_rolesz_sd-role_name AND
                                wa_rolesz_sd-rej_fl = '' AND
                                wa_rolesz_sd-status = '' AND
                                wa_rolesz_sd-role_request = ''.
          PERFORM insert_data_sd.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
*
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.
*
ENDFORM.                    " create_roles_sd
*&---------------------------------------------------------------------*
*&      Form  insert_items_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_sd.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl114_itab
  BY role_name sale_org div plant ship_point.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl114_itab
    COMPARING role_name rej_fl sale_org div plant ship_point.

  LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.

    MOVE-CORRESPONDING g_tablctrl114_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
       wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_sd
*&---------------------------------------------------------------------*
*&      Form  check_items_save_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_sd.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zsd_prep_roledes-plant = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-plant IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE i074(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zsd_prep_roledes-sale_org = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-sale_org IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          ROLLBACK WORK.
          MESSAGE i190(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zsd_prep_roledes-div = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-div IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-DIV'.
          ROLLBACK WORK.
          MESSAGE i194(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zsd_prep_roledes-ship_point = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-ship_point IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          ROLLBACK WORK.
          MESSAGE i191(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

*****
    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax14.

ENDFORM.                    " check_items_save_sd
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax13
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax13.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.


      IF NOT zic_prep_rolerei-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                   TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                      AND werks = zic_prep_rolerei-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          g_i = g_curr_line_113.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-sloc IS INITIAL.

        SELECT SINGLE * FROM t001l INTO CORRESPONDING FIELDS OF
                 it_t001l  WHERE werks = zic_prep_rolerei-plant
                 AND lgort = zic_prep_rolerei-sloc.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          g_i = g_curr_line_113.
          ROLLBACK WORK.
          MESSAGE e073(zhelp) WITH zic_prep_rolerei-sloc.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-res IS INITIAL.

        SELECT SINGLE * FROM zpp_prep_res INTO CORRESPONDING FIELDS OF
                 it_res  WHERE role_type = zic_prep_rolerei-role_name
                 AND
                 plant = zic_prep_rolerei-plant
                 AND
                 res = zic_prep_rolerei-res.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-RES'.
          g_i = g_curr_line_113.
          ROLLBACK WORK.
          MESSAGE e183(zhelp) WITH zic_prep_rolerei-res.

        ENDIF.

      ENDIF.


      IF NOT zic_prep_rolerei-ctf_sloc IS INITIAL.

        SELECT SINGLE * FROM zpp_prep_droleex WHERE role_type =
          zic_prep_rolerei-role_name
          AND plant = zic_prep_rolerei-plant
          AND sloc = zic_prep_rolerei-sloc
          AND ctf_sloc = zic_prep_rolerei-ctf_sloc.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
          g_i = g_curr_line.
          ROLLBACK WORK.
          MESSAGE e073(zhelp) WITH zic_prep_rolerei-ctf_sloc.

        ENDIF.

      ENDIF.
****
    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax13
*&---------------------------------------------------------------------*
*&      Form  check_module_status_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_sd.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    sd_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_sd
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax14
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax14.
  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF NOT zic_prep_rolerei-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                       TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                          AND werks = zic_prep_rolerei-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          g_i = g_curr_line_114.
          MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-sale_org IS INITIAL.

        SELECT SINGLE * FROM tvko CLIENT SPECIFIED INTO CORRESPONDING FIELDS
                 OF it_tvko  WHERE mandt = sy-mandt AND
                 bukrs =  zic_prep_rolereq-ccode AND
                 vkorg = zic_prep_rolerei-sale_org.

        IF sy-subrc <> 0 AND zic_prep_rolerei-sale_org <> 'ALL'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          g_i = g_curr_line_114.
          MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
        ELSEIF zic_prep_rolereq-ccode = 'MUM' AND
                zic_prep_rolereq-fundc1 = 'MUMPHPOP' AND
          zic_prep_rolereq-fundc1 <> 'MUMPHPSP' AND         "12102015
                zic_prep_rolerei-sale_org <> 'HZRS'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          g_i = g_curr_line_114.
          MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
        ELSE.
          IF zic_prep_rolereq-ccode = 'MUM' AND
          zic_prep_rolereq-fundc1 <> 'MUMPHPOP' AND
              zic_prep_rolereq-fundc1 <> 'MUMPHPSP' AND     "12102015
          zic_prep_rolerei-sale_org = 'HZRS'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            g_i = g_curr_line_114.
            MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
          ENDIF.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-div IS INITIAL.

        SELECT SINGLE * FROM tvkos CLIENT SPECIFIED INTO CORRESPONDING
                 FIELDS OF it_tvkos  WHERE mandt = sy-mandt AND
                 vkorg =  zic_prep_rolerei-sale_org AND
                 spart =  zic_prep_rolerei-div.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-DIV'.
          g_i = g_curr_line_114.
          MESSAGE e187(zhelp) WITH zic_prep_rolerei-div.

        ENDIF.

      ENDIF.


      IF NOT zic_prep_rolerei-ship_point IS INITIAL.

        SELECT SINGLE * FROM tvswz INTO CORRESPONDING FIELDS OF
              it_tvswz  WHERE werks = zic_prep_rolerei-plant AND
              vstel = zic_prep_rolerei-ship_point.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          g_i = g_curr_line.
          MESSAGE e188(zhelp) WITH zic_prep_rolerei-ship_point.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax14
*&---------------------------------------------------------------------*
*&      Form  insert_data_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_sd.

  SEARCH wa_roles_sd-role_name FOR 'XXXX'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    REPLACE 'XXXX' WITH wa_rolesz_sd-sale_org INTO
                             wa_roles1-role_name.
    REPLACE 'ZZ' WITH wa_rolesz_sd-div INTO
                             wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_sd-role_name FOR 'YYYY'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    IF wa_rolesz_sd-role_name = 'S2'.
      IF wa_rolesz_sd-div = 'GA' AND
         ( wa_rolesz_sd-ship_point = 'GAIL' OR
           wa_rolesz_sd-ship_point = 'HBJ' ).
        REPLACE 'YYYY' WITH wa_rolesz_sd-sale_org INTO
                                   wa_roles1-role_name.
      ELSE.
        REPLACE 'YYYY' WITH wa_rolesz_sd-ship_point INTO
                                    wa_roles1-role_name.
      ENDIF.
    ENDIF.
    REPLACE 'ZZ' WITH wa_rolesz_sd-div INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_sd-role_name FOR 'PPPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    REPLACE 'PPPP' WITH wa_rolesz_sd-plant INTO
                                  wa_roles1-role_name.
    IF wa_rolesz_sd-role_name = 'S7A'.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                  wa_roles1-role_name.
    ENDIF.
    SELECT SINGLE * FROM zsd_prep_level WHERE plant = wa_rolesz_sd-plant
.
    IF sy-subrc = 0 AND wa_rolesz_sd-role_name = 'S7'.
      REPLACE 'LL' WITH zsd_prep_level-level_ex INTO
                                wa_roles1-role_name.
    ELSE.
      REPLACE 'ZZ' WITH wa_rolesz_sd-div INTO
                                wa_roles1-role_name.
    ENDIF.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF wa_rolesz_sd-role_name = 'SXX'.
    SELECT SINGLE * FROM zsd_prep_area WHERE
                  sale_org = wa_rolesz_sd-sale_org.
    IF sy-subrc = 0.
      flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_sd-role_name.
      REPLACE 'AAA' WITH zsd_prep_area-area INTO
                                wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

ENDFORM.                    " insert_data_sd
*&---------------------------------------------------------------------*
*&      Form  modify_data4_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_data4_pp.
  LOOP AT it_roles1 INTO wa_roles1_pp.
    SEARCH wa_roles1_pp-role_name FOR 'PP_DIS_PROFILES'.
    IF sy-subrc = 0.
      IF wa_roles1_pp-role_name+17(3) <> 'ALL'.
        check_plant_fl = 'X'.
        EXIT.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF check_plant_fl = 'X'.
    CLEAR check_plant_fl.
    DELETE it_roles1 WHERE role_name =  'PP_DIS_PROFILES_ALL'.
  ENDIF.
ENDFORM.                    " modify_data4_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_qm.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl115_itab
  BY role_name plant asset_qm.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl115_itab
    COMPARING role_name rej_fl plant asset_qm.

  LOOP AT g_tablctrl115_itab INTO g_tablctrl115_wa.

    MOVE-CORRESPONDING g_tablctrl115_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
         wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_qm
*&---------------------------------------------------------------------*
*&      Form  check_items_save_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_qm.

ENDFORM.                    " check_items_save_qm
*&---------------------------------------------------------------------*
*&      Form  create_roles_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_qm.
  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_qm INTO wa_roles_qm.
    APPEND wa_roles_qm TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_qm.

    IF NOT wa_roles_qm-role_type IS INITIAL.

      LOOP AT g_tablctrl115_itab INTO wa_rolesz_qm.
        IF wa_roles_qm-role_type = wa_rolesz_qm-role_name AND
                                wa_rolesz_qm-rej_fl = '' AND
                                wa_rolesz_qm-status = '' AND
                                wa_rolesz_qm-role_request = ''.
          PERFORM insert_data_qm.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.

  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
*
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.
*
ENDFORM.                    " create_roles_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_qm.
  SEARCH wa_roles_qm-role_name FOR 'XXXX'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    IF wa_rolesz_qm-role_name = 'Q1'.
      SELECT SINGLE * FROM zqm_prep_loc WHERE
             plant = wa_rolesz_qm-plant.
      IF sy-subrc = 0.
        REPLACE 'XXXX' WITH zqm_prep_loc-loc INTO
                                 wa_roles1-role_name.
      ELSE.
        REPLACE 'XXXX' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles1-role_name.
      ENDIF.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  SEARCH wa_roles_qm-role_name FOR 'YYYY'.

  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    IF wa_rolesz_qm-role_name = 'Q2'.
      IF  wa_rolesz_qm-asset_qm <> ''.
        REPLACE 'YYYY' WITH wa_rolesz_qm-asset_qm INTO
                                    wa_roles1-role_name.
      ELSE.
        REPLACE 'YYYY' WITH zic_prep_rolereq-ccode+0(3) INTO
                                    wa_roles1-role_name.
      ENDIF.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF wa_rolesz_qm-role_name = 'Q3'.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

ENDFORM.                    " insert_data_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data1_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data1_sd.

  IF wa_rolesz_sd-role_name = 'SXX'.
    SELECT SINGLE * FROM zsd_prep_area WHERE
                  sale_org = wa_rolesz_sd-sale_org.
    IF sy-subrc = 0.
      wa_roles1-userid = zic_prep_rolereq-userid.
      CONCATENATE 'SD_XX_DI_' zsd_prep_area-area INTO
      wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

ENDFORM.                    " insert_data1_sd
*&---------------------------------------------------------------------*
*&      Form  check_module_status_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_qm.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    qm_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data_addl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_addl.
  CLEAR wa_roles1.
  DATA : condition(3) TYPE c.
*Begin of <RD1K962817>.
  CLEAR : lv_min_desig,
           lv_curr_role.
*End of <RD1K962817>.
  REFRESH it_roles1_addl.
  SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE
 ROLE_TYPE = WA_ROLESZ-ROLE_NAME AND ROLE_TYPE_EX = WA_ROLESZ-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0.
*Begin of <RD1K962817>.
    lv_min_desig = zmm_prep_crcdesg-min_designation.
    lv_curr_role = zic_prep_rolereq-persk.
*End of <RD1K962817>.

*Begin of< RD1K963297>.
*    IF zmm_prep_crcdesg-crc_level_addl <> space.
*      wa_rolesz-approver = zmm_prep_crcdesg-crc_level_addl.
*      IF lv_curr_role = lv_min_desig.
*      ELSE.
*        IF lv_curr_role LE lv_min_desig OR lv_min_desig = space.
*          CASE wa_rolesz-approver.
*            WHEN 'L2'.
*              wa_rolesz-approver = 'L3'.
*            WHEN 'L1'.
*              wa_rolesz-approver = 'L2'.
*            WHEN 'L3'.
*              wa_rolesz-approver = 'L4'.
*          ENDCASE.
*
*        ENDIF.
*      ENDIF.
*      MOVE wa_rolesz-approver TO zmm_prep_crcdesg-crc_level_addl.
    IF zmm_prep_crcdesg-crc_level_addl <> space.
*      wa_rolesz-approver = zmm_prep_crcdesg-crc_level_addl.
      IF lv_curr_role = lv_min_desig  OR lv_min_desig = space.
      ELSE.
        IF lv_curr_role LE lv_min_desig OR lv_min_desig = space.
*          CASE wa_rolesz-approver.
*            WHEN 'L2'.
*              wa_rolesz-approver = 'L3'.
*            WHEN 'L1'.
*              wa_rolesz-approver = 'L2'.
*            WHEN 'L3'.
*              wa_rolesz-approver = 'L4'.
*          ENDCASE.
          SELECT SINGLE * FROM zmm_prep_crcimii WHERE
          crc_level_addl = zmm_prep_crcdesg-crc_level_addl AND
          crc_level      = zmm_prep_crcdesg-crc_level   AND
          min_designation = zic_prep_rolereq-persk.
          IF sy-subrc = 0 .
            MOVE zmm_prep_crcimii-po_level TO zmm_prep_crcdesg-crc_level.
            MOVE zmm_prep_crcimii-srv_levl TO zmm_prep_crcdesg-crc_level_addl.
          ELSE .
            MESSAGE e803(zmm) WITH 'No Entries Found in The Table ZMM_PREP_CRCIMII'.
          ENDIF.
        ENDIF.
      ENDIF.
      MOVE zmm_prep_crcdesg-crc_level_addl TO wa_rolesz-approver.

    ELSE.    "zmm_prep_crcdesg-crc_level_addl IS INITIAL.  LV_CURR_ROLE LE LV_MIN_DESIG.
      wa_rolesz-approver = zmm_prep_crcdesg-crc_level.
      IF lv_curr_role = lv_min_desig OR lv_min_desig = space..
      ELSE.
        IF lv_curr_role LE lv_min_desig OR lv_min_desig = space.
          CASE wa_rolesz-approver.
            WHEN 'L2'.
              wa_rolesz-approver = 'L3'.
            WHEN 'L1'.
              wa_rolesz-approver = 'L2'.
            WHEN 'L3'.
              wa_rolesz-approver = 'L4'.
          ENDCASE.
        ENDIF.
      ENDIF.
      MOVE wa_rolesz-approver TO zmm_prep_crcdesg-crc_level.
    ENDIF.
*End of < RD1K963297>.
*    IF zmm_prep_crcdesg-crc_level = 'L1'.
*      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
*             it_roles1_addl WHERE role_type = 'M3'.
*    ELSEIF  zmm_prep_crcdesg-crc_level = 'L2' OR
*            zmm_prep_crcdesg-crc_level = 'L3' OR
*            zmm_prep_crcdesg-crc_level = 'IM' OR
**Begin of <RD1K963297>.
*           zmm_prep_crcdesg-crc_level = 'SM'.
**End of <RD1K963297>.
*      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
*             it_roles1_addl WHERE role_type = 'M3A'.
*    ELSEIF zmm_prep_crcdesg-crc_level = 'L4' OR
*            zmm_prep_crcdesg-crc_level = 'E5' OR
*            zmm_prep_crcdesg-crc_level = 'E6' OR
*            zmm_prep_crcdesg-crc_level = 'E7'.
*      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
*             it_roles1_addl WHERE role_type = 'M3B'.
   SELECT * FROM ZMM_PREP_CRCROLE INTO @DATA(WA_MROLE) UP TO 1 ROWS
 WHERE CRC_LEVEL = @ZMM_PREP_CRCDESG-CRC_LEVEL
 ORDER BY PRIMARY KEY .
 ENDSELECT.
     IF sy-subrc = 0.
       SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
             it_roles1_addl WHERE role_type = wa_mrole-MAPPED_ROLE.
     ENDIF.

    IF ( zmm_prep_crcdesg-crc_level = 'SM' AND
            zmm_prep_crcdesg-crc_level_addl = 'SM' ).

      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
            it_roles1_addl WHERE role_type = 'M11M'.
    ENDIF.
    CLEAR flag.
    LOOP AT it_roles1_addl INTO wa_roles1.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles1-role_name.
      SEARCH wa_roles1-role_name FOR 'XX'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'XX' WITH wa_rolesz-approver INTO
                                      wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      SEARCH wa_roles1-role_name FOR 'QQ'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'QQ' WITH zmm_prep_crcdesg-crc_level INTO
                                      wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      SEARCH wa_roles1-role_name FOR 'PLANT'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                              wa_roles1-role_name.
        REPLACE 'PPPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

      SEARCH wa_roles1-role_name FOR 'FM_LOGS'.
      IF sy-subrc = 0.
        flag = 'X'.
*BEGIN OF  <RD1K963151>.
        IF zic_prep_rolereq-ccode = 'OVL'.

          wa_roles1-role_name = 'D:FM_LOGS_OVL_ALL'.
          APPEND wa_roles1 TO it_roles1.
        ELSE.
*END OF <RD1K963151>.
          IF zic_prep_rolereq-fundc1 <> '' .
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc1 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc2 <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc2 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc3 <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc3 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc4 <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc4 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
        ENDIF.
      ENDIF.

      SEARCH wa_roles1-role_name FOR 'CCC_YY'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                      wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

      SEARCH wa_roles1-role_name FOR 'PGG'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                      wa_roles1-role_name.
        REPLACE 'PGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

      IF flag <> 'X'.
        APPEND wa_roles1 TO it_roles1.
      ELSE.
        CLEAR flag.
      ENDIF.
    ENDLOOP.
*Begin of <RD1K963151>.
    IF zic_prep_rolereq-ccode = 'OVL'.
      CLEAR wa_roles1.
      LOOP AT it_roles1 INTO wa_roles1.
        IF wa_roles1-role_name = 'D:MM_DISPLAY_ALL'.
          wa_roles1-role_name = 'D:MM_OVL_DISPLAY_ALL'.
        ENDIF.
        IF wa_roles1-role_name = 'D:MM_DISPLAY_PM_PS_LIS_CIN'.
          wa_roles1-role_name = 'D:MM_OVL_DISPLAY_PM_PS_LIS_CIN'.
        ENDIF.
        MODIFY it_roles1 FROM wa_roles1.
      ENDLOOP.
    ENDIF.
*End of <RD1K963151>.
  ENDIF.
ENDFORM.                    " insert_data_addl
*&---------------------------------------------------------------------*
*&      Form  insert_items_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_hs.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl116_itab
  BY role_name.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl116_itab
    COMPARING role_name rej_fl.

  LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.

    MOVE-CORRESPONDING g_tablctrl116_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
        wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.


*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    ENDIF.

  ENDIF.


ENDFORM.                    " insert_items_hs
*&---------------------------------------------------------------------*
*&      Form  check_items_save_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_hs.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc <> 0.

      MESSAGE e102(zhelp) WITH zhs_prep_roledes-role_type.

    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax16.

ENDFORM.                    " check_items_save_hs
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax16
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax16.

  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr = zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax16
*&---------------------------------------------------------------------*
*&      Form  check_module_status_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_hse.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    hs_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_hs
*&---------------------------------------------------------------------*
*&      Form  create_roles_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_hs.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_hs INTO wa_roles_hs.
    APPEND wa_roles_hs TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles_hs.

    IF NOT wa_roles_hs-role_type IS INITIAL.

      LOOP AT g_tablctrl116_itab INTO wa_rolesz_hs.
        IF wa_roles_hs-role_type = wa_rolesz_hs-role_name AND
                                wa_rolesz_hs-rej_fl = '' AND
                                wa_rolesz_hs-status = '' AND
                                wa_rolesz_hs-role_request = ''.
          PERFORM insert_data_hs.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.

***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.

*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles_hs
*&---------------------------------------------------------------------*
*&      Form  insert_data_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_hs.

  SEARCH wa_roles_hs-role_name FOR 'CCC'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_hs-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_hs-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

*
ENDFORM.                    " insert_data_hs
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_olm .
  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_olm INTO wa_roles_olm.
    APPEND wa_roles_olm TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles_olm.

    IF NOT wa_roles_olm-role_type IS INITIAL.

      LOOP AT g_tablctrl117_itab INTO wa_rolesz_olm.
        IF wa_roles_olm-role_type = wa_rolesz_olm-role_name .
          "      AND
          "  wa_rolesz_olm-rej_fl = '' AND
          "   wa_rolesz_olm-status = '' AND
          "  wa_rolesz_olm-role_request = ''.
*          PERFORM insert_data_olm.
          wa_roles1-userid = zic_prep_rolereq-userid.
          wa_roles1-role_name = wa_roles_olm-role_name.
          APPEND wa_roles1 TO it_roles1.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***

  PERFORM list_processing.

*
*  CLEAR : flag, flag1.

ENDFORM.                    " CREATE_ROLES_OLM
*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_olm .

* SEARCH wa_roles_olm-role_name FOR 'CCC'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.

*  SEARCH wa_roles_olm-role_name FOR 'AAA'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'AAA' WITH wa_rolesz_olm-asset INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.

*  SEARCH wa_roles_olm-role_name FOR 'BBB'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'BBB' WITH wa_rolesz_olm-basin INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.
*
*  SEARCH wa_roles_olm-role_name FOR 'XXYY'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'XX' WITH wa_rolesz_olm-project INTO
*                                wa_roles1-role_name.
*    REPLACE 'YY' WITH wa_rolesz_olm-location INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.
*
*  SEARCH wa_roles_olm-role_name FOR 'ZZZ'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'ZZZ' WITH 'ALL' INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.

*  IF flag <> 'X'.
  wa_roles1-userid = zic_prep_rolereq-userid.
  wa_roles1-role_name = wa_roles_olm-role_name.
  APPEND wa_roles1 TO it_roles1.
*  ENDIF.

  CLEAR flag.
ENDFORM.                    " INSERT_DATA_OLM
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_olm .
  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl117_itab
  BY role_name.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl117_itab
    COMPARING role_name.

  LOOP AT g_tablctrl117_itab INTO g_tablctrl117_wa.

    MOVE-CORRESPONDING g_tablctrl117_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
         wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

    IF old_ok_code = 'CREATE'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM zic_prep_rolerei WHERE docno = zic_prep_rolereq-docno
        AND moduleid = moduleid.

    MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    IF sy-subrc = 0 AND g_role_flag <> 'X'.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_OLM
*&---------------------------------------------------------------------*
*&      Form  CHECK_ITEMS_SAVE_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_olm .
  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.
    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax17.
ENDFORM.                    " CHECK_ITEMS_SAVE_OLM
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_LINEITEM_DATAX17
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax17 .
  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.
ENDFORM.                    " VALIDATE_LINEITEM_DATAX17
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_srm .
  CLEAR:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.

    LOOP AT   g_tablctrl118_itab INTO g_tablctrl118_wa.

      wa_roles_srmp-userid = zic_prep_rolereq-userid.
      wa_roles_srmp-role_name = g_tablctrl118_wa-role_name.
      wa_roles_srmp-ccode = zic_prep_rolereq-ccode.
      wa_roles_srmp-from_dat = sy-datum.
      wa_roles_srmp-to_dat   = '99991231'.
      wa_roles_srmp-grp =  g_tablctrl118_wa-grp.
      APPEND  wa_roles_srmp TO it_roles_srmp.

    ENDLOOP.




    p_uname = zic_prep_rolereq-userid.

    SELECT SINGLE * FROM zbcusrmst  INTO CORRESPONDING FIELDS OF wa_zbcusrmst
      WHERE cpfno = zic_prep_rolereq-userid.

    p_fname        = wa_zbcusrmst-first_name.
    p_lname        = wa_zbcusrmst-last_name.
    p_ccode =    zic_prep_rolereq-ccode.


    CALL FUNCTION 'ZSRM_ROLE_ASSIGN_ARMS' DESTINATION l_logsys
      EXPORTING
        p_uname       = p_uname
        p_fname       = p_fname
        p_lname       = p_lname
        p_ccode       = p_ccode
      TABLES
        it_roles_srmp = it_roles_srmp
        itab_return   = itab_return.

    IF itab_return[] IS NOT INITIAL.

      v_srm_st = 'C'.

      LOOP AT itab_return INTO wa_return.

        IF   wa_return-status NE  'C'.
          v_srm_st = 'IF'.
        ELSE.

        ENDIF.
      ENDLOOP.

      IF  v_srm_st = 'C'.
        zic_prep_rolereq-status = 'C'.

      ELSE.
        zic_prep_rolereq-status = 'IF'.
        PERFORM send_sapmail_srmassign .
      ENDIF.


      v_rolereq-docno = zic_prep_rolereq-docno.
      p_uname_sms = p_uname.
      g_userid_n = ''.
      MODIFY zic_prep_rolereq FROM zic_prep_rolereq.
      IF sy-subrc = 0.
        IF  zic_prep_rolereq-status = 'C'.

          CALL FUNCTION 'ZMM_SEND_SMS'
            EXPORTING
              cpfno_s     = g_userid_n
              cpfno_r     = p_uname_sms
              from_dat    = sy-datum
              to_dat      = '99991231'
              auth_req_no = v_rolereq-docno
            IMPORTING
              flag_msg    = l_flag_msg.

          PERFORM send_sapmail_srmassign .

        ENDIF.
      ENDIF.


    ELSE.
      IF  v_srm_st = ''.
        zic_prep_rolereq-status = 'N'.
        MODIFY zic_prep_rolereq FROM zic_prep_rolereq.
      ENDIF.

    ENDIF.

    PERFORM unlock_record.

    CLEAR:v_message_srm.
    IF zic_prep_rolereq-status = 'C'.

      CONCATENATE 'Roles assigned for request No .' zic_prep_rolereq-docno INTO
      v_message_srm SEPARATED BY space.

      MESSAGE i735(zmm) WITH v_message_srm.

    ELSE.

      CONCATENATE 'Roles not  assigned for request No .' zic_prep_rolereq-docno INTO
   v_message_srm SEPARATED BY space.

      MESSAGE i735(zmm) WITH v_message_srm.
    ENDIF.

    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " CREATE_ROLES_SRM
*&---------------------------------------------------------------------*
*&      Form  SEND_SAPMAIL_SRMASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sapmail_srmassign .
  document_data-obj_langu  = sy-langu.
  document_data-obj_name   = 'ICE Core Team'.
  document_data-obj_descr  = 'Mail from ICE Core Team'.

  CONCATENATE document_data-obj_descr '---' moduleid
  '-' 'Module' INTO document_data-obj_descr.
  document_data-priority   = '3'.

* Remove prefix 'US' from receiver
  REFRESH receivers.

  CLEAR wa_receivers.
  wa_receivers-receiver = zic_prep_rolereq-useridcr.
  wa_receivers-rec_type = 'B'.
  wa_receivers-express  = 'X'.
  APPEND wa_receivers TO receivers.

  CLEAR wa_receivers.

  MOVE space TO object_content-line.
  APPEND object_content.

  CONCATENATE  'Subject: '  'Creation of Roles for userid '
zic_prep_rolereq-userid INTO  object_content-line
SEPARATED BY space.
  APPEND object_content.

  MOVE space TO object_content-line.
  APPEND object_content.
  IF zic_prep_rolereq-status = 'C'.


    CONCATENATE 'Please  check  your role request  which  has'
     'been assigned  &  completed - ' zic_prep_rolereq-docno INTO
object_content-line
SEPARATED BY space.
    APPEND object_content.
  ELSE.

  ENDIF.
********************************************************************
  """"""""""""""""""""""
  IF zic_prep_rolereq-status = 'IF'.

    CONCATENATE ' Roles are not assigned for Request no.- ' zic_prep_rolereq-docno INTO
object_content-line
SEPARATED BY space.

    APPEND object_content.
  ENDIF.
  """""""""""""""""""""""""""""
********************************************************************
  MOVE space TO object_content-line.
  APPEND object_content.

  object_content-line = 'ICE Core Team'.
  APPEND object_content.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = document_data
      document_type              = 'RAW'
      put_in_outbox              = 'X'
    IMPORTING
      sent_to_all                = sent_to_all
    TABLES
      object_header              = objhead
      object_content             = object_content
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 01
      document_not_sent          = 02
      document_type_not_exist    = 03
      operation_no_authorization = 04
      parameter_error            = 05
      x_error                    = 06
      enqueue_error              = 07.

  CASE sy-subrc.
    WHEN 0.

*      MESSAGE i060(zhelp) WITH zic_prep_rolereq-useridcr.
    WHEN '01'.
      RAISE too_many_receivers.
    WHEN '02'.
      RAISE document_not_sent.
    WHEN '03'.
      RAISE document_type_not_exist.
    WHEN '04'.
      RAISE operation_no_authorization.
    WHEN '05'.
      RAISE parameter_error.
    WHEN '06'.
      RAISE x_error.
    WHEN '07'.
      RAISE enqueue_error.
  ENDCASE.
ENDFORM.                    " SEND_SAPMAIL_SRMASSIGN
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_srm .
  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl118_itab
  BY role_name plant grp  sloc receipt_loc approver.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl118_itab
    COMPARING role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

  LOOP AT g_tablctrl118_itab INTO g_tablctrl118_wa.

    MOVE-CORRESPONDING g_tablctrl118_wa TO wa_itemtab.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    SELECT SINGLE * FROM zsr_prep_roledes WHERE role_type =
                                                     wa_itemtab-role_name.
    IF sy-subrc = 0.



      IF zsr_prep_roledes-p_grp = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE'  OR
                    old_ok_code = 'CREATE'  OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-grp IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          ROLLBACK WORK.
          MESSAGE i085(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR:count_grp,g_wa_pgrp.

    LOOP AT g_tablctrl118_itab INTO g_wa_pgrp WHERE  grp = wa_itemtab-grp  .
      IF g_wa_pgrp-grp  IS NOT INITIAL.
        count_grp = count_grp + 1.
      ENDIF.
    ENDLOOP.
    IF  count_grp > '1'.
      MESSAGE i092(zhelp) .
      CLEAR okcode_100.
      CALL SCREEN 100.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

***added g_reset_fl to check resetting & no rollback
  IF g_lines_rl = 0 .
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.

      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid..
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.


    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_SRM

*--- INCLUDE: MZMMPREPROLE3_PHASEIII01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 1020.
************************************************************************
MODULE USER_COMMAND_0100 INPUT.

  OKCODE = SY-UCOMM.

  CASE OKCODE.

    WHEN 'BAC' OR 'CAN'.

      PERFORM BAC_CONFIRM.
*      refresh control 'TABCTRL100' from screen '0100'.
      CLEAR OKCODE.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      G_MODE = 'CRE'.
      CLEAR OKCODE.

    WHEN 'CHANGE'.

      G_MODE = 'CHA'.
      CLEAR OKCODE.

    WHEN 'DISPLAY'.

      G_MODE = 'DIS'.
      CLEAR OKCODE.

    WHEN 'DELETE'.

      G_MODE = 'DEL'.
      CLEAR OKCODE.

    WHEN 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
      .
*        Perform Save_request.

      CLEAR OKCODE.

    WHEN 'RELEASE'.

      G_MODE = 'REL'.
      CLEAR OKCODE.

    WHEN 'APPROVE'.

      G_MODE = 'APR'.
      CLEAR OKCODE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: modify table
MODULE TABCTRL100_MODIFY INPUT.

  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABCTRL100_WA.

*  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

*  endif.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
      IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER.
      ELSE.

        IF OKCODE_100 = 'SAV'.
          IF ERR_FLG <> 'X'.
            ERR_FLG = 'X'.
            CLEAR : SY-UCOMM, OKCODE_100.
          ENDIF.
          MESSAGE E047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT G_TABCTRL100_WA-ROLE_NAME IS INITIAL.
**
    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0.
*        g_srno = g_srno + 1.
        G_TABCTRL100_WA-ROLE_DESC = ZMM_PREP_ROLECRC-BRIEF_DESC.
*        g_TABCTRL100_wa-srno = g_srno.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC = 0.
*        g_srno = g_srno + 1.
        G_TABCTRL100_WA-ROLE_DESC = ZMM_PREP_ROLEDES-BRIEF_DESC.
*        g_TABCTRL100_wa-srno = g_srno.
      ENDIF.

    ENDIF.
**
  ENDIF.
  MODIFY G_TABCTRL100_ITAB
    FROM G_TABCTRL100_WA
    INDEX TABCTRL100-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABCTRL100_WA TO G_TABCTRL100_ITAB.
  ENDIF.

  IF G_TABCTRL100_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABCTRL100_WA-FLAG.
    APPEND G_TABCTRL100_WA TO G_TABCTRL100_ITAB.
  ENDIF.

ENDMODULE.                    "TABCTRL100_modify INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
MODULE TABCTRL100_MARK INPUT.
  IF TABCTRL100-LINE_SEL_MODE = 1 AND
     G_TABCTRL100_WA-FLAG = 'X'.
    LOOP AT G_TABCTRL100_ITAB INTO G_TABCTRL100_WA
      WHERE FLAG = 'X'.
      G_TABCTRL100_WA-FLAG = ''.
      MODIFY G_TABCTRL100_ITAB
        FROM G_TABCTRL100_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABCTRL100_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABCTRL100_ITAB
    FROM G_TABCTRL100_WA
    INDEX TABCTRL100-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABCTRL100_mark INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
MODULE TABCTRL100_USER_COMMAND INPUT.
**  OKCODE = sy-ucomm.
**  perform user_ok_tc using    'TABCTRL100'
**                              'G_TABCTRL100_ITAB'
**                              'FLAG'
**                     changing OKCODE.
**  sy-ucomm = OKCODE.
ENDMODULE.                    "TABCTRL100_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.
  TYPES :
           BEGIN OF TY_BUKRS,
             WERKS LIKE ZD_T001W_BUKRS-WERKS,
             NAME1 LIKE ZD_T001W_BUKRS-NAME1,
           END OF TY_BUKRS.

  DATA   : IT_BUKRS TYPE TABLE OF TY_BUKRS WITH HEADER LINE.

  SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
             TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WERKS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_BUKRS
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_GRP INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    CONCATENATE '000'  ZIC_PREP_ROLEREQ-USERID INTO CPF_LFB1.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : L_EKGRP LIKE T024-EKGRP.
*  refresh : it_cond.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.

*if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*  concatenate '''' '%' ZIC_PREP_ROLEREQ-CCODE '-' 'IND' ''''
*  into g_line1.
*  select * from t024 into table it_t024 where TELFX like g_line1.
*else.
*endif.

  DATA : LOOP_STEP LIKE SY-STEPL.
  DATA : L_ROLE_NAME LIKE ZIC_PREP_ROLEREI-ROLE_NAME.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0110'
    IMPORTING
      VALUE = L_ROLE_NAME.

  IF L_ROLE_NAME = 'M6' OR  L_ROLE_NAME = 'M7' OR
      L_ROLE_NAME = 'M8'.
    CONCATENATE '%' G_CCODE '%' INTO G_LINE1.
    SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
  ELSE.
    IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      CONCATENATE '%' G_CCODE '%' 'IND' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ELSE.
      CONCATENATE  '%' G_CCODE '%' 'MM' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ENDIF.
  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKGRP'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKNAM'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'EKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-GRP'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_T024
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  FREE : IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR G_FIELD_WA.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

  TYPES : BEGIN OF Z_ROLE_DES,
            ROLE_TYPE LIKE ZMM_PREP_ROLEDES-ROLE_TYPE,
            BRIEF_DESC LIKE ZMM_PREP_ROLEDES-BRIEF_DESC,
            DETAIL_DESC1 LIKE ZMM_PREP_ROLEDES-DETAIL_DESC1,
            DETAIL_DESC2 LIKE ZMM_PREP_ROLEDES-DETAIL_DESC2,
            SORT_FIELD LIKE ZMM_PREP_ROLEDES-BRIEF_DESC,
            MM_DISC_FLAG LIKE ZMM_PREP_ROLEDES-MM_DISC_FLAG,
          END OF Z_ROLE_DES.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : IT_ROLE TYPE TABLE OF Z_ROLE_DES WITH HEADER LINE.

  IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC INTO CORRESPONDING FIELDS OF
               TABLE IT_ROLE.

  ELSE.

    SELECT * FROM ZMM_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
               TABLE IT_ROLE.

  ENDIF.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_HEADER_DATA INPUT.

  IF OLD_OK_CODE = 'DISPLAY' OR OLD_OK_CODE = 'CHANGE' OR
        OLD_OK_CODE = 'DELETE' OR OLD_OK_CODE = 'CREATE' OR
        OLD_OK_CODE = 'CROSSCO' OR ( OLD_OK_CODE = 'CRCROLES' )
        OR OLD_OK_CODE = 'RELEASE' OR ( OLD_OK_CODE = 'APPROVE' ).

    IF NOT  ZIC_PREP_ROLEREQ-USERID IS INITIAL.
      PERFORM CHECK_TEL.
    ENDIF.

    IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.

      IF  ZIC_PREP_ROLEREQ-PERSA IS INITIAL AND
          ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
        PERFORM POP_UP_MESSAGE.
      ENDIF.

      IF  ZIC_PREP_ROLEREQ-USERID IS INITIAL.
        MESSAGE E035(ZHELP).
      ENDIF.

      IF  ZIC_PREP_ROLEREQ-USERID <> OLD_USERID AND
        OLD_USERID <> ''.
        CLEAR  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
        CLEAR  ZIC_PREP_ROLEREQ-CCODE.
        CLEAR  ZIC_PREP_ROLEREQ-FUNDC1.
        CLEAR  ZIC_PREP_ROLEREQ-FUNDC.
        CLEAR  ZIC_PREP_ROLEREQ-S_DESC.
        CLEAR  ZIC_PREP_ROLEREQ-RSN_CODE.
        CLEAR  ZIC_PREP_ROLEREQ-RSN_TEXT1.
        CLEAR  ZIC_PREP_ROLEREQ-REASON1.
        CLEAR  ZIC_PREP_ROLEREQ-TELNO.
        CLEAR  ZIC_PREP_ROLEREQ-NAME.
        CLEAR  ZIC_PREP_ROLEREQ-DESIGNATION.
        CLEAR SET_DISC_MM_FLAG.
        CLEAR HELP_LIST_FLAG.
        REFRESH IT_M_FISTB.
        CLEAR WA_M_FISTB.
      ENDIF.

*        select single * from zusrmst where cpfno =
*                                    ZIC_PREP_ROLEREQ-userid.

      SELECT SINGLE * FROM USR02 WHERE BNAME =
                                  ZIC_PREP_ROLEREQ-USERID.

      IF SY-SUBRC NE 0.
        MESSAGE E043(ZHELP).
      ELSE.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-name = zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-designation = zusrmst-designation.

        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
           D~DISC_CD AS DISC_CD
             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                 ON C~DESIGNO = D~DESIG_CODE AND
                     C~R_P_CD  = D~R_P_CD AND
                     C~VERSION = D~VERSION )
                  WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                        A~SPRPS = ' ' AND
                        A~ENDDA = '99991231' AND
                        C~SPRPS = ' ' AND
                        C~ENDDA = '99991231' .

        IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
          ZIC_PREP_ROLEREQ-NAME = IST_DATA-NAME.
          ZIC_PREP_ROLEREQ-DESIGNATION = IST_DATA-DESIGNATION.
          IF IST_DATA-DISC_CD = '36' AND SET_DISC_MM_FLAG <> 'X'.
            ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
            SET_DISC_MM_FLAG = 'X'.
          ENDIF.
***************************************************31.05.2006
          IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CRCROLES'.
            ZIC_PREP_ROLEREQ-CCODE = IST_DATA-BUKRS.
          ELSE.
            G_CCODE_CROSSCO        = IST_DATA-BUKRS.
          ENDIF.

***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*             ZIC_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

          IF OLD_OK_CODE = 'CREATE'.
            IF  ZIC_PREP_ROLEREQ-PERSA <> IST_DATA-WERKS AND
               NOT  ZIC_PREP_ROLEREQ-PERSA IS INITIAL.
              MESSAGE E108(ZHELP).
            ENDIF.
          ENDIF.

        ENDIF.

        CLEAR : IST_DATA.
        REFRESH : IST_DATA.

** Change company code, fund centre, costcentre logic 02.02.2006


        CONCATENATE '000'  ZIC_PREP_ROLEREQ-USERID INTO CPF_LFB1.

*          select single * from lfb1 where lifnr = cpf_lfb1.

* Select Company-KBU01, Cost Centre-kst01
* from pa0027  .
        CLEAR WA_PA0027.

        SELECT *
 FROM PA0027 INTO WA_PA0027 UP TO 1 ROWS WHERE PERNR = CPF_LFB1 AND ENDDA = '99991231' AND SPRPS = ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT. " SPRPS - Lock Indicator 'X'

        IF SY-SUBRC = 0.
          IF OLD_OK_CODE <> 'CROSSCO'.
            CONCATENATE  '''' '%' WA_PA0027-KST01
                         '''' INTO  G_LINE1.
            CONCATENATE  'OBJNR'  'LIKE' G_LINE1 INTO G_LINE1
            SEPARATED BY SPACE.
            REFRESH :  IT_COND.
            APPEND G_LINE1 TO IT_COND.
            SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE (IT_COND)
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          ENDIF.
          IF SY-SUBRC = 0.
            IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CRCROLES'.
              ZIC_PREP_ROLEREQ-FUNDC1 = FMZUOB-FISTL.
              ZIC_PREP_ROLEREQ-FUNDC_FL = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
              ZIC_PREP_ROLEREQ-COSTC = WA_PA0027-KST01.
            ELSE.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
              ZIC_PREP_ROLEREQ-COSTC = WA_PA0027-KST01.
            ENDIF.

            SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZIC_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

            IF SY-SUBRC =  0.
              ZIC_PREP_ROLEREQ-S_DESC = CSKT-LTEXT.
            ENDIF.

            REFRESH IT_COND[].
            CLEAR IT_COND.
          ELSE.
          ENDIF.
        ENDIF.

      ENDIF.

    ELSE.

***************************************************

***************************************************

      IF  ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.
        MESSAGE E041(ZHELP).
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_100 INPUT.

  IF OKCODE_DBLCLK = 'DBLCLK'.

    CALL TRANSACTION 'ZROLE_REQ2_COPY' AND SKIP FIRST SCREEN.

    CLEAR OKCODE_DBLCLK.

  ENDIF.


  CASE OKCODE_100.

    WHEN 'BAC' OR 'CAN'.
      PERFORM EXIT_CONFIRM.
    WHEN 'EXT'.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'CHANGE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'RELEASE'.

      OLD_OK_CODE = OKCODE_100.


    WHEN 'APPROVE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'COPY'.


    WHEN 'DISPLAY'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'ROLE_CR'.

      IF ZIC_PREP_ROLEREQ-STATUS = 'C'.
        MESSAGE E086(ZHELP).
      ELSE.
        CASE MODULEID.
          WHEN 'MM'.
            PERFORM CREATE_ROLES.
          WHEN 'PM'.
            PERFORM CREATE_ROLES_PM.
          WHEN 'PS'.
            PERFORM CREATE_ROLES_PS.
          WHEN 'PP'.
            PERFORM CREATE_ROLES_PP.
          WHEN 'SD'.
            PERFORM CREATE_ROLES_SD.
          WHEN 'QM'.
            PERFORM CREATE_ROLES_QM.
          WHEN 'HSE'.
            PERFORM CREATE_ROLES_HS.
          WHEN 'OLM'.
            PERFORM CREATE_ROLES_OLM.

            """""""""""""
          WHEN 'SRM'.
            PERFORM CREATE_ROLES_SRM.
            """""""""""""
        ENDCASE.
      ENDIF.

    WHEN 'SAV'.

      IF OLD_OK_CODE = 'DELETE'.

        IF  ZIC_PREP_ROLEREQ-USERIDCR = SY-UNAME.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

          IF  ZIC_PREP_ROLEREQ-STATUS = ''.
            PERFORM DELETE_REQUEST.
          ELSE.
            MESSAGE E138(ZHELP).
          ENDIF.
        ELSE.
          MESSAGE E056(ZHELP).
        ENDIF.
      ELSE.
        IF OLD_OK_CODE = 'RELEASE' AND
               ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
          MESSAGE I083(ZHELP).

        ELSEIF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
          MESSAGE I089(ZHELP).

        ELSEIF OLD_OK_CODE = 'APPROVE' AND
              (  ZIC_PREP_ROLEREQ-REQ_APP_FL <> 'X' AND
               ZIC_PREP_ROLEREQ-REQ_APP0_FL <> 'X' AND
               ZIC_PREP_ROLEREQ-REQ_APP1_FL <> 'X' ).
          MESSAGE I087(ZHELP).
        ELSE.
**          Perform check_items.
          IF MODULEID <> 'MM'.
            G_APPROVER_LEVEL = 'L3'.
          ENDIF.
          PERFORM SAVE_REQUEST.
        ENDIF.
**       endif.
      ENDIF.

    WHEN 'MULTI'.

*      clear help_list_flag.

      CALL SCREEN 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      CLEAR OKCODE_100.


    WHEN 'DELETE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'SUIM'.

      REFRESH : IST_SELTAB.
      CLEAR   : SELTAB.

      SELTAB-SELNAME = 'P_REM'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
      SELTAB-LOW   = ZIC_PREP_ROLEREQ-USERID.
      APPEND SELTAB TO IST_SELTAB.

      SUBMIT ZMMPREPROLE_ROLE_CREATE_REP WITH SELECTION-TABLE IST_SELTAB
      AND RETURN.

    WHEN 'DELETED_RL'.

      REFRESH : IST_SELTAB.
      CLEAR   : SELTAB.

      SELTAB-SELNAME = 'P_REM_X'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
      SELTAB-LOW   = ZIC_PREP_ROLEREQ-USERID.
      APPEND SELTAB TO IST_SELTAB.

      SUBMIT ZMMPREPROLE_DEL_REP WITH SELECTION-TABLE IST_SELTAB
      AND RETURN.

*      CALL SCREEN 120.
*      if okcode_100 = 'BAC'.
*        clear old_ok_code.
*      endif.

    WHEN 'LIST'.

      PERFORM LIST_FILES.
      IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'.
        OLD_OK_CODE = 'DISPLAY'.
      ELSE.
        OLD_OK_CODE = 'CHANGE'.
      ENDIF.
      G_RESET_CHANGE = 'X'.


    WHEN 'ATTACH'.

      PERFORM ATTACH_FILES.
      IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'.
        OLD_OK_CODE = 'DISPLAY'.
      ELSE.
        OLD_OK_CODE = 'CHANGE'.
      ENDIF.
      G_RESET_CHANGE = 'X'.

    WHEN 'CORR'.

      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
      IF G_CLINES <> 0.
        CORR_CODE = OKCODE_100.
      ENDIF.

      CLEAR OKCODE_100.
      G_RESET_CHANGE = 'X'.

    WHEN 'ROLE_DEL'.

      REFRESH : IST_SELTAB.
      CLEAR   : SELTAB.

      SELTAB-SELNAME = 'P_REM'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
      CONCATENATE ZIC_PREP_ROLEREQ-DOCNO ' -ARMS-' MODULEID '-' INTO
SELTAB-LOW.
*          seltab-low   = p_docno.
      APPEND SELTAB TO IST_SELTAB.

      SELTAB-SELNAME = 'P_REM1'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
*          concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
      SELTAB-LOW   = ZIC_PREP_ROLEREQ-USERID.
      APPEND SELTAB TO IST_SELTAB.

      IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'..
        MESSAGE E121(ZHELP).

      ELSE.

        SUBMIT ZHELPROLE3 WITH SELECTION-TABLE IST_SELTAB AND RETURN.

        GET PARAMETER ID 'ZROLEREQNO' FIELD ZROLEREQNO.

        GET PARAMETER ID 'EXIT_VALUE' FIELD G_EXIT_VALUE.

        IF NOT ZROLEREQNO IS INITIAL AND ZROLEREQNO <> '00000000' AND
          G_EXIT_VALUE <> 'X'.
          SUBMIT ZBC_ROLE_REP01_RFC_DEL AND RETURN.
*
          SET PARAMETER ID 'ZROLEREQNO' FIELD ''.
          CLEAR ZROLEREQNO.
*            perform send_sapmail.
        ELSE.
          SET PARAMETER ID 'EXIT_VALUE' FIELD ''.
          CLEAR G_EXIT_VALUE.
        ENDIF.

      ENDIF.

      CLEAR SY-UCOMM.

    WHEN 'MAIL'.

      PERFORM CONFIRM_MAIL.

    WHEN 'SUMMARY'.

      SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                  FIELD ZIC_PREP_ROLEREQ-DOCNO.

      CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.


    WHEN 'POSTING'.

      SET PARAMETER ID 'XUS'
                  FIELD ZIC_PREP_ROLEREQ-USERID.

*Begin of <RD1K963151>.
*      CALL TRANSACTION 'ZMMUSERDATA_MULT' AND SKIP FIRST SCREEN.
      CALL TRANSACTION  'ZMMUSERDATA' AND SKIP FIRST SCREEN.
*End of <<RD1K963151>.

    WHEN 'STAT_MOD'.

      SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                  FIELD ZIC_PREP_ROLEREQ-DOCNO.

      CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.

    WHEN OTHERS.

      CLEAR OKCODE_100.


  ENDCASE.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.


ENDMODULE.                 " USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_OK_CODE INPUT.


*  ********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.
  OKCODE_RJ = OLD_OK_CODE.
  CRT_NAME = ZIC_PREP_ROLEREQ-USERIDCR.
  TCODE_RJ = SY-TCODE.

  EXPORT OKCODE_RJ TO MEMORY ID 'OKCODE_RJ'.
  EXPORT CRT_NAME TO MEMORY ID 'CRT_NAME_RJ'.
  EXPORT TCODE_RJ TO MEMORY ID 'TCODE_IM'.
********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.

  IF SY-UCOMM = 'DBLCLK'.
    OKCODE_DBLCLK = SY-UCOMM.
    CLEAR SY-UCOMM.
  ENDIF.
  OKCODE_100 = SY-UCOMM.

  CLEAR :  ERR_FLG.

  CASE OKCODE.
    WHEN 'GRC_RISK'.

      CLEAR GT_BUCKET_EX.

      IF MODULEID = 'MM'.
        LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.

          MOVE-CORRESPONDING G_TABLCTRL110_WA TO WA_BUCKET_EX.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET_EX TO GT_BUCKET_EX.
*    CLEAR WA_BUCKET.
        ENDLOOP.
      ELSEIF MODULEID = 'SD'.
        LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.

          MOVE-CORRESPONDING G_TABLCTRL114_WA TO WA_BUCKET_EX.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET_EX TO GT_BUCKET_EX.
*    CLEAR WA_BUCKET.
        ENDLOOP.
      ELSEIF MODULEID = 'PP'.
        LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.

          MOVE-CORRESPONDING G_TABLCTRL113_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF MODULEID = 'PM'.
        LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.

          MOVE-CORRESPONDING G_TABLCTRL111_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF MODULEID = 'PS'.
        LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.

          MOVE-CORRESPONDING G_TABLCTRL112_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF MODULEID = 'HSE'.
        LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA.

          MOVE-CORRESPONDING G_TABLCTRL116_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.


      ELSEIF MODULEID = 'QM'.
        LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.

          MOVE-CORRESPONDING G_TABLCTRL115_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ENDIF.

      EXPORT GT_BUCKET_EX TO MEMORY ID 'TABLE_IM'.

      SELECT * FROM TVARVC INTO CORRESPONDING FIELDS OF TABLE IT_TVARV
      WHERE NAME = 'ZGRC_CALL'.
      READ TABLE IT_TVARV INTO WA_TVARV WITH KEY NAME = 'ZGRC_CALL'.
      LV_GRCCALL = WA_TVARV-LOW.

      LV_GRCCALL = WA_TVARV-LOW.
      CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
        EXPORTING
          RFCDESTINATION = 'GRDCLNT500'
        IMPORTING
*         MSGV1          =
*         MSGV2          =
          RFC_SUBRC      = LV_SUBRC.
      IF  LV_GRCCALL = 'X' AND LV_SUBRC = '0'.

        REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
        EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
        OKCODE_EX = OLD_OK_CODE.
        EXPORT OKCODE_EX TO MEMORY ID 'OKCODE_IM'.
*        CALL TRANSACTION 'ZGRC_RISK_RESULT'. " + COMMENT BY VIKAS
        CALL TRANSACTION 'ZGRC_RISK_RESULT'. " + aDDED BY VIKAS

        IMPORT OC_9001_RJ FROM MEMORY ID 'OC_9001_IM'.
        IF OC_9001_RJ = 'REJECT'.
          LEAVE PROGRAM.
        ENDIF.

        IF OLD_OK_CODE EQ 'CREATE' OR OLD_OK_CODE EQ 'CHANGE'.
*          LEAVE PROGRAM."-BY VIKAS
          RETURN."+ by Vikas
*          LEAVE TO SCREEN 0.
*          SET SCREEN
        ENDIF.

*        IMPORT LV_EXPO FROM MEMORY ID 'LV_IMP'.
*********************************End of changes : Changes by Bipin Shukla on 24 july 2013
*        IF LV_EXPO = ''. " ADDED BY BIPIN
*          PERFORM SAVE_REQUEST.
*        ENDIF.       " ADDED BY BIPIN

      ENDIF.
*      CLEAR REQNUM_EX.
*      CLEAR: OKCODE.
*      CLEAR OKCODE_EX.
    WHEN 'GRC_RAL1'.
      REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
      EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
      OKCODE_EX = OLD_OK_CODE.
      EXPORT OKCODE_EX TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_SEC_RESULT'.

      CLEAR REQNUM_EX.
      CLEAR OKCODE_EX.

    WHEN  'GRC_RPL1'.
      REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
      EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
      OKCODE_EX = OLD_OK_CODE.
      EXPORT OKCODE_EX TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_VIOL'.

      CLEAR REQNUM_EX.
      CLEAR OKCODE_EX.

    WHEN OTHERS.
  ENDCASE.

**  get cursor line g_cursor_line.
**  g_curr_line = g_cursor_line.
**  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
**  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_DATA INPUT.

  IF NOT  ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.

*    DATA : l_docno LIKE  zic_prep_rolereq-docno.

    CLEAR L_DOCNO.

    L_DOCNO =  ZIC_PREP_ROLEREQ-DOCNO.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = L_DOCNO
      IMPORTING
        OUTPUT = L_DOCNO.

    ZIC_PREP_ROLEREQ-DOCNO = L_DOCNO.

  ENDIF.
*Begin of <RD1K963151>.
  PERFORM LOCK_REQHD.
*End of <RD1K963151>.
  IF OLD_DOC_NO <>  ZIC_PREP_ROLEREQ-DOCNO.
    CLEAR G_HD_COPIED.
    PERFORM DESTROY_CTRL.
  ENDIF.

  IF NOT MODULEID IS INITIAL AND OLD_MODULEID <> MODULEID.
    G_TABLCTRL110_COPIED = ''.
    G_TABLCTRL111_COPIED = ''.

    """""""""""""""""
    G_TABLCTRL118_COPIED = ''.

    """""""""""""
  ENDIF.

ENDMODULE.                 " clear_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.

  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT                   = LT_TEXT_TABLE1
      IS_MODIFIED            = GV_XTHEAD_UPDKZ
    EXCEPTIONS
      ERROR_DP               = 1
      ERROR_CNTL_CALL_METHOD = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = LT_TEXT_TABLE1
      ITF_TEXT    = TLINETAB1.
*
  IF ( OLD_OK_CODE = 'CREATE' )
  OR ( OLD_OK_CODE = 'CROSSCO' )
  OR ( OLD_OK_CODE = 'CRCROLES' )
  OR ( OLD_OK_CODE = 'CHANGE' )
  OR ( OLD_OK_CODE = 'RELEASE' )
  OR ( OLD_OK_CODE = 'APPROVE' )
   OR ( OLD_OK_CODE = 'DISPLAY' AND  ZIC_PREP_ROLEREQ-STATUS = 'IR' )
  .

    CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
      IMPORTING
        TEXT                   = LT_TEXT_TABLE2
        IS_MODIFIED            = GV_XTHEAD_UPDKZ
      EXCEPTIONS
        ERROR_DP               = 1
        ERROR_CNTL_CALL_METHOD = 2
        OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      TABLES
        TEXT_STREAM = LT_TEXT_TABLE2
        ITF_TEXT    = TLINETAB2.
  ENDIF..

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0105 INPUT.

  DATA: OKCODE105 LIKE SY-UCOMM.

  OKCODE105 = SY-UCOMM.

  CASE OKCODE105.
    WHEN 'OK'.
      DESCRIBE TABLE TLINETAB2 LINES G_CLINES.
      CLEAR OKCODE105.
    WHEN 'CANCEL'.
      REFRESH TLINETAB2[].
      CLEAR OKCODE105.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : L_PLANT LIKE ZIC_PREP_ROLEREI-PLANT.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'PLANT'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_PLANT.


  DATA   : IT_T001L TYPE TABLE OF T001L WITH HEADER LINE.
  DATA   : IT_EXCP_SL TYPE TABLE OF ZMM_PREP_SL_EXCP WITH HEADER LINE.
  DATA   : WA_T001L LIKE T001L.
  DATA   : L_ZAREA LIKE ZMM_CONSM-ZAREA.

  SELECT * FROM T001L INTO CORRESPONDING FIELDS OF
             TABLE IT_T001L  WHERE WERKS = L_PLANT.

  IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

    LOOP AT IT_T001L INTO WA_T001L.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF SY-SUBRC = 0.

        IF L_ZAREA+0(1) <> 'M'.
          DELETE IT_T001L.
        ENDIF.

      ELSE.

        DELETE IT_T001L.

      ENDIF.

    ENDLOOP.

  ELSE.

    LOOP AT IT_T001L INTO WA_T001L.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF SY-SUBRC = 0.

        IF L_ZAREA+0(1) = 'M'.
          DELETE IT_T001L.
        ENDIF.

      ELSE.

        DELETE IT_T001L.

      ENDIF.

    ENDLOOP.

  ENDIF.

  SELECT * FROM ZMM_PREP_SL_EXCP INTO TABLE IT_EXCP_SL.

************************************

  LOOP AT IT_EXCP_SL.

    READ TABLE IT_T001L WITH KEY WERKS = IT_EXCP_SL-WERKS
    LGORT = IT_EXCP_SL-LGORT.

    IF SY-SUBRC = 0.

      DELETE IT_T001L WHERE WERKS = IT_EXCP_SL-WERKS
      AND LGORT = IT_EXCP_SL-LGORT.

    ENDIF.

  ENDLOOP.

************************************
  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'T001L'.
  G_FIELD_WA-FIELDNAME = 'WERKS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T001L'.
  G_FIELD_WA-FIELDNAME = 'LGORT'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T001L'.
  G_FIELD_WA-FIELDNAME = 'LGOBE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LGORT'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_T001L
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_T001L,IST_RETURN_TAB,G_FIELD_TAB..
  FREE  : IT_T001L,IST_RETURN_TAB,G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_APPROVER INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : IT_APPROVER LIKE TABLE OF ZMM_PREP_APPROVE.
  DATA : WA_APPROVER LIKE ZMM_PREP_APPROVE.

  DATA : IT_APPROVER1 LIKE TABLE OF ZMM_PREP_APP_CRC.
  DATA : WA_APPROVER1 LIKE ZMM_PREP_APP_CRC.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_ROLE_NAME.

  IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_APP_CRC INTO TABLE IT_APPROVER1.

  ELSE.

    SELECT * FROM ZMM_PREP_APPROVE INTO TABLE IT_APPROVER.

  ENDIF.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*
*
*              if l_role_name = 'M11'.
*
*                  loop at it_approver into wa_approver.
*
*                    if wa_approver-M11_FLAG <> 'X'.
*                      delete it_approver.
*                    endif.
*
*                  endloop.
*
*              endif.
*
*      endif.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*         if l_role_name = 'M11'.
*
*            loop at it_approver into wa_approver.
*
*                if wa_approver-M11_FLAG <> 'X'.
*                    delete it_approver.
*                 endif.
*
*            endloop.
*
*         endif.
*
*      endif.
*******************************************************
  IF L_ROLE_NAME = 'M11S'.                                  "22.05.06

    LOOP AT IT_APPROVER INTO WA_APPROVER.

      CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

        WHEN 'X'.
          IF WA_APPROVER-MM_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
        WHEN OTHERS.
          IF WA_APPROVER-M11S_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.

  IF L_ROLE_NAME = 'M11M'.

    LOOP AT IT_APPROVER INTO WA_APPROVER.

      CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

        WHEN 'X'.
          IF WA_APPROVER-MM_FLAG <> 'X'
             OR WA_APPROVER-M11M_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
        WHEN OTHERS.
          IF WA_APPROVER-MM_FLAG = 'X'
             OR WA_APPROVER-M11M_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.
**************************************************22.05.06

  IF L_ROLE_NAME = 'M8'.

    LOOP AT IT_APPROVER INTO WA_APPROVER.

      IF WA_APPROVER-M8_FLAG <> 'X'.
        DELETE IT_APPROVER.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

    IF L_ROLE_NAME = 'M3'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

        IF WA_APPROVER1-M3_FLAG <> 'X'.
          DELETE IT_APPROVER1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M3A'.                                 "22.05.06

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

        IF WA_APPROVER1-M3A_FLAG <> 'X'.
          DELETE IT_APPROVER1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M3B'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

        IF WA_APPROVER1-M3B_FLAG <> 'X'.
          DELETE IT_APPROVER1.
        ENDIF.

      ENDLOOP.

    ENDIF.                                                  " 22.05.06


    IF L_ROLE_NAME = 'M11S'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER1-MM_FLAG <> 'X'
               OR WA_APPROVER1-M11S_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER1-MM_FLAG = 'X'
               OR WA_APPROVER1-M11S_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M11M'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER1-MM_FLAG <> 'X'
               OR WA_APPROVER1-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER1-MM_FLAG = 'X'
               OR WA_APPROVER1-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IT_APPROVER[] = IT_APPROVER1[].

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_PREP_APPROVE'.
  G_FIELD_WA-FIELDNAME = 'APP_LEVEL'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_APPROVE'.
  G_FIELD_WA-FIELDNAME = 'L_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'APP_LEVEL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-APPROVER'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_APPROVER
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_APPROVER,IST_RETURN_TAB, IT_APPROVER1,G_FIELD_TAB.
  FREE  : IT_APPROVER,IST_RETURN_TAB, IT_APPROVER1,G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RECEIPT_LOC INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC' AND SCREEN-INPUT =
0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : IT_RECPT LIKE TABLE OF ZMM_LOCATION.
  DATA : WA_RECPT LIKE ZMM_LOCATION.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_ROLE_NAME.

  SELECT * FROM ZMM_LOCATION INTO TABLE IT_RECPT.


  IF L_ROLE_NAME = 'M12'.

    LOOP AT IT_RECPT INTO WA_RECPT.

      IF WA_RECPT-LOCCG <> 'RL'.
        DELETE IT_RECPT.
      ENDIF.

    ENDLOOP.

  ENDIF.


  IF L_ROLE_NAME = 'M17'.

    LOOP AT IT_RECPT INTO WA_RECPT.

      IF WA_RECPT-LOCCG <> 'CF'.
        DELETE IT_RECPT.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_LOCATION'.
  G_FIELD_WA-FIELDNAME = 'LOCCD'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_LOCATION'.
  G_FIELD_WA-FIELDNAME = 'LOCCG'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_LOCATION'.
  G_FIELD_WA-FIELDNAME = 'LOCDS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LOCCD'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_RECPT
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_RECPT,IST_RETURN_TAB,G_FIELD_TAB.
  FREE  : IT_RECPT,IST_RETURN_TAB,G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  IF SY-UCOMM = 'EXT'.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATA INPUT.

  OLD_DOC_NO =  ZIC_PREP_ROLEREQ-DOCNO.
  OLD_USERID =  ZIC_PREP_ROLEREQ-USERID.
  OLD_DISC_MM_FLAG =  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
  OLD_MODULEID = MODULEID.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

*  clear g_e_fl.

    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                      ZIC_PREP_ROLEREI-ROLE_NAME.

      IF SY-SUBRC <> 0.
        G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MESSAGE I117(ZHELP).
      ENDIF.

    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                      ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC <> 0.
        G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MESSAGE I118(ZHELP).
      ENDIF.

    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-RECEIPT_LOC.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-GRP.
    CLEAR  ZIC_PREP_ROLEREI-APPROVER.

    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-RECEIPT_LOC.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-GRP.
    CLEAR  ZIC_PREP_ROLEREI-APPROVER.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZIC_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZIC_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

    IF OLD_OK_CODE = 'CRCROLES'.

    ELSE.

      IF ZMM_PREP_ROLEDES-MM_DISC_FLAG = 'X'.

        IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
        ELSE.
          IF ZIC_PREP_ROLEREI-ROLE_NAME <> ''.
            MESSAGE E081(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

*  endif.

    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                 TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                    AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.

      ENDIF.

    ENDIF.

************finding group*******************

    REFRESH : IT_COND, IT_T024, IT_T024_1.
    CLEAR   : WA_T024.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.
*
*
* if l_role_name = 'M6' or  l_role_name = 'M7' or
*     l_role_name = 'M8'.
*
* else.
*
*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*            loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) between '0' and 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*
*      else.
*
*          loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) < '0'  or
*              l_ekgrp+1(1) > 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*      endif.
*
* endif.
*
**
    IF G_TABLCTRL110_WA-ROLE_NAME = 'M6' OR
        G_TABLCTRL110_WA-ROLE_NAME = 'M7' OR
        G_TABLCTRL110_WA-ROLE_NAME = 'M8'.
      CONCATENATE '%' G_CCODE '%' INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ELSE.
      IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
        CONCATENATE '%' G_CCODE '%' 'IND' '%'
        INTO G_LINE1.
        SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
      ELSE.
        CONCATENATE  '%' G_CCODE '%' 'MM' '%'
        INTO G_LINE1.
        SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
      ENDIF.
    ENDIF.
**
    IF  NOT ZIC_PREP_ROLEREI-GRP IS INITIAL.

      LOOP AT IT_T024 INTO WA_T024.

*           if ZIC_PREP_ROLEREI-GRP = wa_t024-ekgrp.
*              grp_flag = 'X'.
*           endif.

        IF G_TABLCTRL110_WA-GRP = WA_T024-EKGRP.
          GRP_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF GRP_FLAG = 'X'.
        CLEAR GRP_FLAG.
      ELSE.
        G_E_FL = 'X'.
        G_READ_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
        MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABCTRL100_WA.
        MODIFY G_TABCTRL100_ITAB
                  FROM G_TABCTRL100_WA
                    INDEX TABCTRL100-CURRENT_LINE.
        G_I = TABCTRL100-CURRENT_LINE.
        MESSAGE I069(ZHELP).
        CALL SCREEN 100.

      ENDIF.

    ENDIF.

***************************

    CLEAR : L_ZAREA, WA_T001L.
    REFRESH IT_T001L.

    IF ( ZIC_PREP_ROLEREI-ROLE_NAME = 'M13' OR
       ZIC_PREP_ROLEREI-ROLE_NAME = 'M14' OR
        ZIC_PREP_ROLEREI-ROLE_NAME = 'M16' OR
        ZIC_PREP_ROLEREI-ROLE_NAME = 'M18' OR
        ZIC_PREP_ROLEREI-ROLE_NAME = 'M19' ) AND
        NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM T001L INTO CORRESPONDING FIELDS OF
                   TABLE IT_T001L  WHERE WERKS = ZIC_PREP_ROLEREI-PLANT.

      IF  SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        MESSAGE E074(ZHELP).

      ENDIF.

    ENDIF.

    IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

      LOOP AT IT_T001L INTO WA_T001L.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        IF SY-SUBRC = 0.

          IF L_ZAREA+0(1) <> 'M'.
            DELETE IT_T001L.
          ENDIF.

        ELSE.

          DELETE IT_T001L.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT IT_T001L INTO WA_T001L.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        IF SY-SUBRC = 0.

          IF L_ZAREA+0(1) = 'M'.
            DELETE IT_T001L.
          ENDIF.

        ELSE.

          DELETE IT_T001L.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF  NOT ZIC_PREP_ROLEREI-SLOC IS INITIAL.

      LOOP AT IT_T001L INTO WA_T001L.

        IF ZIC_PREP_ROLEREI-SLOC = WA_T001L-LGORT.
          LOC_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF LOC_FLAG = 'X'.
        CLEAR LOC_FLAG.
      ELSE.
** cab_ajit 07.02.2006
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
        MESSAGE E073(ZHELP).

      ENDIF.

    ENDIF.


***************************

    CLEAR WA_RECPT.
    REFRESH IT_RECPT.

    IF ( ZIC_PREP_ROLEREI-ROLE_NAME = 'M12' OR
       ZIC_PREP_ROLEREI-ROLE_NAME = 'M17' ) AND
       NOT ZIC_PREP_ROLEREI-RECEIPT_LOC IS INITIAL.

      SELECT * FROM ZMM_LOCATION INTO TABLE IT_RECPT.

      IF ZIC_PREP_ROLEREI-ROLE_NAME = 'M12'.

        LOOP AT IT_RECPT INTO WA_RECPT.

          IF WA_RECPT-LOCCG <> 'RL'.
            DELETE IT_RECPT.
          ENDIF.

        ENDLOOP.

      ENDIF.


      IF ZIC_PREP_ROLEREI-ROLE_NAME = 'M17'.

        LOOP AT IT_RECPT INTO WA_RECPT.

          IF WA_RECPT-LOCCG <> 'CF'.
            DELETE IT_RECPT.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDIF.

    IF  NOT ZIC_PREP_ROLEREI-RECEIPT_LOC IS INITIAL.

      LOOP AT IT_RECPT INTO WA_RECPT.

        IF ZIC_PREP_ROLEREI-RECEIPT_LOC = WA_RECPT-LOCCD.
          LOC_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF LOC_FLAG = 'X'.
        CLEAR LOC_FLAG.
      ELSE.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
        MESSAGE E075(ZHELP).

      ENDIF.

    ENDIF.


*****************************
*****************************22.05.06

    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT * FROM ZMM_PREP_APP_CRC INTO TABLE IT_APPROVER1.

    ELSE.

      SELECT * FROM ZMM_PREP_APPROVE INTO TABLE IT_APPROVER.

    ENDIF.

    IF L_ROLE_NAME = 'M11S'.                                "22.05.06

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER-MM_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER-M11S_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M11M'.

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER-MM_FLAG <> 'X'
               OR WA_APPROVER-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER-MM_FLAG = 'X'
               OR WA_APPROVER-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.
**************************************************22.05.06

    IF L_ROLE_NAME = 'M8'.

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        IF WA_APPROVER-M8_FLAG <> 'X'.
          DELETE IT_APPROVER.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

      IF L_ROLE_NAME = 'M3'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          IF WA_APPROVER1-M3_FLAG <> 'X'.
            DELETE IT_APPROVER1.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF L_ROLE_NAME = 'M3A'.                               "22.05.06

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          IF WA_APPROVER1-M3A_FLAG <> 'X'.
            DELETE IT_APPROVER1.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF L_ROLE_NAME = 'M3B'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          IF WA_APPROVER1-M3B_FLAG <> 'X'.
            DELETE IT_APPROVER1.
          ENDIF.

        ENDLOOP.

      ENDIF.                                                " 22.05.06


      IF L_ROLE_NAME = 'M11S'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

            WHEN 'X'.
              IF WA_APPROVER1-MM_FLAG <> 'X'
                 OR WA_APPROVER1-M11S_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
            WHEN OTHERS.
              IF WA_APPROVER1-MM_FLAG = 'X'
                 OR WA_APPROVER1-M11S_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
          ENDCASE.

        ENDLOOP.

      ENDIF.

      IF L_ROLE_NAME = 'M11M'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

            WHEN 'X'.
              IF WA_APPROVER1-MM_FLAG <> 'X'
                 OR WA_APPROVER1-M11M_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
            WHEN OTHERS.
              IF WA_APPROVER1-MM_FLAG = 'X'
                 OR WA_APPROVER1-M11M_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
          ENDCASE.

        ENDLOOP.

      ENDIF.

      IT_APPROVER[] = IT_APPROVER1[].

    ENDIF.
*********************************************22.05.06

    IF  NOT ZIC_PREP_ROLEREI-APPROVER IS INITIAL.

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        IF ZIC_PREP_ROLEREI-APPROVER = WA_APPROVER-APP_LEVEL.
          APPROVER_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF APPROVER_FLAG = 'X'.
        CLEAR APPROVER_FLAG.
      ELSE.
        G_E_FL = 'X'.
        G_READ_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-APPROVER'.
        MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABCTRL100_WA.
        MODIFY G_TABCTRL100_ITAB
                  FROM G_TABCTRL100_WA
                    INDEX TABCTRL100-CURRENT_LINE.
        G_I = TABCTRL100-CURRENT_LINE.
        MESSAGE E135(ZHELP).
        CALL SCREEN 100.

      ENDIF.

    ENDIF.


  ENDIF.

ENDMODULE.                 " validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE RECORD_REJ_ID_DATA INPUT.

*if old_ok_code <> 'DISPLAY' and old_ok_code <> 'CHANGE'.
**
  IF ZIC_PREP_ROLEREI-REJ_ID IS INITIAL.
    ZIC_PREP_ROLEREI-REJ_ID = SY-UNAME.
    ZIC_PREP_ROLEREI-REJ_DATE = SY-DATUM.
  ENDIF.

  IF NOT ZIC_PREP_ROLEREI-REJ_FL IS INITIAL AND
     ZIC_PREP_ROLEREI-REJ_FL_SAVE IS INITIAL.

    SELECT SINGLE * FROM  ZMM_PREP_REJ_LIS  WHERE
      REJ_CODE = ZIC_PREP_ROLEREI-REJ_FL .
    IF SY-SUBRC <> 0.
      G_E_FL = 'X'.
      MESSAGE E111(ZHELP).
    ELSE.
      IF SY-UNAME+0(1) = 'C' AND
                    ZIC_PREP_ROLEREI-REJ_FL = 'F' OR
****
                    ZIC_PREP_ROLEREI-REJ_FL = 'A'.
      ELSE.
        G_E_FL = 'X'.
        MESSAGE E111(ZHELP).

*      if g_user = 'L1' and ZIC_PREP_ROLEREI-rej_fl <> 'R'.
*        g_e_fl = 'X'.
*        message e111(zhelp).
*      elseif g_user = 'L3' and ZIC_PREP_ROLEREI-rej_fl <> 'B'.
*        g_e_fl = 'X'.
*        message e111(zhelp).
*      elseif g_user = 'IM' and ZIC_PREP_ROLEREI-rej_fl <> 'I'.
*        g_e_fl = 'X'.
*        message e111(zhelp).
*      endif.
      ENDIF.
    ENDIF.
  ENDIF.
**
*endif.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.

  DATA : TEL_LEN TYPE I.
  TEL_LEN = STRLEN(  ZIC_PREP_ROLEREQ-TELNO ).
  IF   ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
    MESSAGE E097(ZHELP).
  ELSE.
    IF TEL_LEN < 7.
      MESSAGE E098(ZHELP).
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA1 INPUT.

  IF OLD_OK_CODE = 'CRCROLES'.

    SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                   ZIC_PREP_ROLEREI-ROLE_NAME.
  ELSE.

    SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                   ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_read  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_READ INPUT.
  CLEAR G_READ_FL.
ENDMODULE.                 " clear_read  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL110_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL110_ITAB FROM G_TABLCTRL110_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL110_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL110_ITAB  LINES TABLCTRL110-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP INPUT.
  IF NOT G_TABCTRL100_ITAB[] IS INITIAL .

    DELETE ADJACENT DUPLICATES FROM G_TABCTRL100_ITAB
    COMPARING ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.

  ENDIF.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_DATA INPUT.
  G_ROLE_NAME_PREV = ZIC_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL110_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL110_WA.

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
      IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER.
      ELSE.

        IF OKCODE_100 = 'SAV'.
          IF ERR_FLG <> 'X'.
            ERR_FLG = 'X'.
            CLEAR : SY-UCOMM, OKCODE_100.
          ENDIF.
          MESSAGE E047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT G_TABLCTRL110_WA-ROLE_NAME IS INITIAL.
    SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0.
      G_TABLCTRL110_WA-ROLE_DESC = ZMM_PREP_ROLEDES-BRIEF_DESC.
    ENDIF.
  ENDIF.

  MODIFY G_TABLCTRL110_ITAB
     FROM G_TABLCTRL110_WA
     INDEX TABLCTRL110-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL110_WA TO G_TABLCTRL110_ITAB.
  ENDIF.

  IF G_CURR_LINE_110 = SY-STEPL AND OKCODE_100 = 'COPY'.
    APPEND G_TABLCTRL110_WA TO G_TABLCTRL110_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
  G_CURR_LINE_110 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_110 = SY-STEPL AND OKCODE_100 = 'TABLCTRL110_DELE' AND
        G_TABLCTRL110_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.

ENDMODULE.                    "TABLCTRL110_modify INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL110_MARK INPUT.
  IF TABLCTRL110-LINE_SEL_MODE = 1 AND
     G_TABLCTRL110_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL110_WA-FLAG = ''.
      MODIFY G_TABLCTRL110_ITAB
        FROM G_TABLCTRL110_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL110_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL110_ITAB
    FROM G_TABLCTRL110_WA
    INDEX TABLCTRL110-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL110_mark INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL110_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL110'
                              'G_TABLCTRL110_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL110_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_110 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL110-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_110 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_110  INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL111_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL111_WA.

  SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL111_WA-ROLE_DESC = ZPM_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL111_ITAB
    FROM G_TABLCTRL111_WA
    INDEX TABLCTRL111-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL111_WA TO G_TABLCTRL111_ITAB.
  ENDIF.

  IF G_TABLCTRL111_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL111_WA-FLAG.
    APPEND G_TABLCTRL111_WA TO G_TABLCTRL111_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_111 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_111 = SY-STEPL AND OKCODE_100 = 'TABLCTRL111_DELE' AND
        G_TABLCTRL111_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.

ENDMODULE.                    "TABLCTRL111_modify INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL111_MARK INPUT.
  IF TABLCTRL111-LINE_SEL_MODE = 1 AND
     G_TABLCTRL111_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL111_WA-FLAG = ''.
      MODIFY G_TABLCTRL111_ITAB
        FROM G_TABLCTRL111_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL111_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL111_ITAB
    FROM G_TABLCTRL111_WA
    INDEX TABLCTRL111-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL111_mark INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL111_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL111'
                              'G_TABLCTRL111_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL111_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_111 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL111-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_111 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA11 INPUT.

  SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA11A INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                 TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                    AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZPM_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      IF ZIC_PREP_ROLEREQ-CCODE = 'BDW' OR
         ZIC_PREP_ROLEREQ-CCODE = 'SBW'.
      ELSE.
        DELETE IT_ROLE WHERE ROLE_TYPE = 'PM14' OR
        ROLE_TYPE = 'PM15' OR ROLE_TYPE = 'PM16'.
      ENDIF.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.                 " validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO11 INPUT.

  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL111_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL111_ITAB FROM G_TABLCTRL111_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL111_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL111_ITAB  LINES TABLCTRL111-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno11  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PM INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

*  TYPES : Begin of z_role_des,
*            role_type like zmm_prep_roledes-role_type,
*            brief_desc like zmm_prep_roledes-brief_desc,
*            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
*            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
*            sort_field like zmm_prep_roledes-brief_desc,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
*          end of z_role_des.

*  DATA   : it_role type table of z_role_des with header line.
*

  SELECT * FROM ZPM_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
             TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF ZIC_PREP_ROLEREQ-CCODE = 'BDW' OR
     ZIC_PREP_ROLEREQ-CCODE = 'SBW'.
  ELSE.
    DELETE IT_ROLE WHERE ROLE_TYPE = 'PM14' OR
    ROLE_TYPE = 'PM15' OR ROLE_TYPE = 'PM16'.
  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SHOP_NO INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHOP_NO' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
  TYPES :
           BEGIN OF TY_SHOP,
             WERKS LIKE T357-WERKS,
             BEBER LIKE T357-BEBER,
             FING  LIKE T357-FING,
           END OF TY_SHOP.

  DATA   : IT_SHOP TYPE TABLE OF TY_SHOP WITH HEADER LINE.

  SELECT * FROM T357 INTO CORRESPONDING FIELDS OF
             TABLE IT_SHOP  WHERE WERKS =  '53C1' OR
                                  WERKS =  '24C1'.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BEBER'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SHOP_NO'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_SHOP
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_MODULEID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_MODULEID INPUT.
  DATA : IT_MODULE LIKE TABLE OF ZIC_MODULES.
  DATA : WA_MODULE LIKE ZIC_MODULES.

*  data : l_docno like zic_prep_rolereq-DOCNO.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREQ'
      FIELD = 'DOCNO'
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_DOCNO.


  IF OLD_OK_CODE <> 'CREATE' .

    SELECT DISTINCT MODULEID FROM ZIC_PREP_ROLEREI INTO CORRESPONDING
    FIELDS OF TABLE IT_MODULE WHERE DOCNO = L_DOCNO.

  ELSE.

    SELECT  MODULEID FROM ZICE_PREP_MODULE INTO CORRESPONDING FIELDS
    OF TABLE IT_MODULE.
  ENDIF.

  LOOP AT IT_MODULE INTO WA_MODULE.
    SELECT SINGLE * FROM ZICE_PREP_MODULE WHERE MODULEID =
    WA_MODULE-MODULEID.
    WA_MODULE-Z_DESC = ZICE_PREP_MODULE-Z_DESC.
    MODIFY IT_MODULE FROM WA_MODULE.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MODULEID'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'MODULEID'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_MODULE
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_MODULE,IST_RETURN_TAB.
  FREE  : IT_MODULE,IST_RETURN_TAB.

ENDMODULE.                 " POV_MODULEID  INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL112_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL112_WA.
  SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL112_WA-ROLE_DESC = ZPM_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL112_ITAB
   FROM G_TABLCTRL112_WA
   INDEX TABLCTRL112-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL112_WA TO G_TABLCTRL112_ITAB.
  ENDIF.

  IF G_TABLCTRL112_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL111_WA-FLAG.
    APPEND G_TABLCTRL112_WA TO G_TABLCTRL112_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
  G_CURR_LINE_112 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_112 = SY-STEPL AND OKCODE_100 = 'TABLCTRL112_DELE' AND
        G_TABLCTRL112_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.

ENDMODULE.                    "TABLCTRL112_modify INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL112_MARK INPUT.
  IF TABLCTRL112-LINE_SEL_MODE = 1 AND
     G_TABLCTRL112_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL112_WA-FLAG = ''.
      MODIFY G_TABLCTRL112_ITAB
        FROM G_TABLCTRL112_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL112_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL112_ITAB
    FROM G_TABLCTRL112_WA
    INDEX TABLCTRL112-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL112_mark INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL112_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL112'
                              'G_TABLCTRL112_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL112_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_112 INPUT.
  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL112-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_112 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA12 INPUT.
  SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA12A INPUT.
  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ELSE.
      G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SERVICE.
    CLEAR  ZIC_PREP_ROLEREI-PROJECT.
    CLEAR  ZIC_PREP_ROLEREI-LOCATION.
*  clear  ZIC_PREP_ROLEREI-REGION.
    CLEAR  ZIC_PREP_ROLEREI-ASSET.
    CLEAR  ZIC_PREP_ROLEREI-BASIN.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SERVICE.
    CLEAR  ZIC_PREP_ROLEREI-PROJECT.
    CLEAR  ZIC_PREP_ROLEREI-LOCATION.
*      clear  ZIC_PREP_ROLEREI-REGION.
    CLEAR  ZIC_PREP_ROLEREI-ASSET.
    CLEAR  ZIC_PREP_ROLEREI-BASIN.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-SERVICE IS INITIAL.

      SELECT * FROM ZPS_PREP_SERVICE INTO CORRESPONDING FIELDS OF
                 TABLE IT_SERVICE WHERE
                 SERVICE = ZIC_PREP_ROLEREI-SERVICE.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.
        G_I = G_CURR_LINE_112.
        MESSAGE E169(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-PROJECT IS INITIAL.

      SELECT * FROM ZPS_PREP_PROJECT INTO CORRESPONDING FIELDS OF
                 TABLE IT_PROJECT WHERE
                 SERVICE = ZIC_PREP_ROLEREI-SERVICE AND
                 PROJECT = ZIC_PREP_ROLEREI-PROJECT.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PROJECT'.
        G_I = G_CURR_LINE.
        MESSAGE E170(ZHELP) WITH ZIC_PREP_ROLEREI-PROJECT.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-LOCATION IS INITIAL.

      SELECT * FROM ZPS_PREP_LOCA INTO CORRESPONDING FIELDS OF
             TABLE IT_LOCA WHERE CCODE = ZIC_PREP_ROLEREQ-CCODE
             AND LOCATION = ZIC_PREP_ROLEREI-LOCATION AND
             SERVICE = ZIC_PREP_ROLEREI-SERVICE.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-LOCATION'.
        G_I = G_CURR_LINE.
        MESSAGE E171(ZHELP) WITH ZIC_PREP_ROLEREI-LOCATION.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ASSET IS INITIAL.

      IF ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
        SELECT * FROM ZPS_PREP_ASST_EX INTO CORRESPONDING FIELDS OF
              TABLE IT_ASSET WHERE CCODE = 'MUM' AND
                    ASSET = ZIC_PREP_ROLEREI-ASSET.

        IF SY-SUBRC <> 0 AND ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
          G_I = G_CURR_LINE.
          MESSAGE E172(ZHELP) WITH ZIC_PREP_ROLEREI-ASSET.
        ENDIF.

      ELSE.
        IF ZIC_PREP_ROLEREI-ASSET <> ZIC_PREP_ROLEREQ-CCODE AND
           ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
          G_I = G_CURR_LINE.
          MESSAGE E172(ZHELP) WITH ZIC_PREP_ROLEREI-ASSET.
        ENDIF.
      ENDIF.
    ENDIF.


    IF NOT ZIC_PREP_ROLEREI-BASIN IS INITIAL.

      IF ZIC_PREP_ROLEREI-BASIN <> ZIC_PREP_ROLEREQ-CCODE AND
          ZIC_PREP_ROLEREI-BASIN <> 'ALL'.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-BASIN'.
        G_I = G_CURR_LINE.
        MESSAGE E173(ZHELP) WITH ZIC_PREP_ROLEREI-BASIN.
      ENDIF.

    ENDIF.



    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZPS_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO12 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL112_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL112_ITAB FROM G_TABLCTRL112_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL112_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL112_ITAB  LINES TABLCTRL112-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " change_srno12  INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL113_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL113_WA.

  SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL113_WA-ROLE_DESC = ZPP_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL113_ITAB
  FROM G_TABLCTRL113_WA
  INDEX TABLCTRL113-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL113_WA TO G_TABLCTRL113_ITAB.
  ENDIF.

  IF G_TABLCTRL113_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL113_WA-FLAG.
    APPEND G_TABLCTRL113_WA TO G_TABLCTRL113_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
   G_CURR_LINE_113 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

ENDMODULE.                    "TABLCTRL113_modify INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL113_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL113'
                              'G_TABLCTRL113_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL113_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_113 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL113-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_113 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA13 INPUT.
  SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA13A INPUT.
  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ELSE.
      G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-RES.
    CLEAR  ZIC_PREP_ROLEREI-CTF_SLOC.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-RES.
    CLEAR  ZIC_PREP_ROLEREI-CTF_SLOC.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                     TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                        AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE_113.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-SLOC IS INITIAL.

      SELECT SINGLE * FROM T001L INTO CORRESPONDING FIELDS OF
               IT_T001L  WHERE WERKS = ZIC_PREP_ROLEREI-PLANT
               AND LGORT = ZIC_PREP_ROLEREI-SLOC.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
        G_I = G_CURR_LINE.
        MESSAGE E073(ZHELP) WITH ZIC_PREP_ROLEREI-SLOC.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-RES IS INITIAL.

      SELECT SINGLE * FROM ZPP_PREP_RES INTO CORRESPONDING FIELDS OF
             IT_RES  WHERE ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME
             AND
             PLANT = ZIC_PREP_ROLEREI-PLANT
             AND
             RES = ZIC_PREP_ROLEREI-RES.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-RES'.
        G_I = G_CURR_LINE.
        MESSAGE E183(ZHELP) WITH ZIC_PREP_ROLEREI-RES.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-CTF_SLOC IS INITIAL.

      SELECT SINGLE * FROM ZPP_PREP_DROLEEX WHERE ROLE_TYPE =
          ZIC_PREP_ROLEREI-ROLE_NAME
          AND PLANT = ZIC_PREP_ROLEREI-PLANT
          AND SLOC = ZIC_PREP_ROLEREI-SLOC
          AND CTF_SLOC = ZIC_PREP_ROLEREI-CTF_SLOC.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
        G_I = G_CURR_LINE.
        MESSAGE E073(ZHELP) WITH ZIC_PREP_ROLEREI-CTF_SLOC.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZPP_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO13 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL113_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL113_ITAB FROM G_TABLCTRL113_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL113_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL113_ITAB  LINES TABLCTRL113-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno13  INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL114_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL114_WA.

  SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL114_WA-ROLE_DESC = ZPP_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL114_ITAB
    FROM G_TABLCTRL114_WA
    INDEX TABLCTRL114-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL114_WA TO G_TABLCTRL114_ITAB.
  ENDIF.

  IF G_TABLCTRL114_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL114_WA-FLAG.
    APPEND G_TABLCTRL114_WA TO G_TABLCTRL114_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_114 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

ENDMODULE.                    "TABLCTRL114_modify INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL114_MARK INPUT.
  IF TABLCTRL114-LINE_SEL_MODE = 1 AND
     G_TABLCTRL114_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL114_WA-FLAG = ''.
      MODIFY G_TABLCTRL114_ITAB
        FROM G_TABLCTRL114_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL114_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL114_ITAB
    FROM G_TABLCTRL114_WA
    INDEX TABLCTRL114-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL114_mark INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL114_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL114'
                              'G_TABLCTRL114_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL114_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_114 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL114-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_114 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA14 INPUT.

ENDMODULE.                 " validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA14A INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ELSE.
      G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SALE_ORG.
    CLEAR  ZIC_PREP_ROLEREI-DIV.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SHIP_POINT.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SALE_ORG.
    CLEAR  ZIC_PREP_ROLEREI-DIV.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SHIP_POINT.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                     TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                        AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE_114.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-SALE_ORG IS INITIAL.

      SELECT SINGLE * FROM TVKO CLIENT SPECIFIED INTO CORRESPONDING FIELDS
               OF IT_TVKO  WHERE MANDT = SY-MANDT AND
               BUKRS =  ZIC_PREP_ROLEREQ-CCODE AND
               VKORG = ZIC_PREP_ROLEREI-SALE_ORG.

      IF SY-SUBRC <> 0 AND ZIC_PREP_ROLEREI-SALE_ORG <> 'ALL'.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
        G_I = G_CURR_LINE_114.
        MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
***
      ELSEIF ZIC_PREP_ROLEREQ-CCODE = 'MUM' AND
              ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' AND
          ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPSP' AND         "12102015
              ZIC_PREP_ROLEREI-SALE_ORG <> 'HZRS'.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
        G_I = G_CURR_LINE_114.
        MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
      ELSE.
        IF ZIC_PREP_ROLEREQ-CCODE = 'MUM' AND
        ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPOP' AND
            ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPSP' AND       "12102015
        ZIC_PREP_ROLEREI-SALE_ORG = 'HZRS'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          G_I = G_CURR_LINE_114.
          MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
        ENDIF.
***
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-DIV IS INITIAL.

      SELECT SINGLE * FROM TVKOS CLIENT SPECIFIED INTO CORRESPONDING
               FIELDS OF IT_TVKOS  WHERE MANDT = SY-MANDT AND
               VKORG =  ZIC_PREP_ROLEREI-SALE_ORG AND
               SPART =  ZIC_PREP_ROLEREI-DIV.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-DIV'.
        G_I = G_CURR_LINE_114.
        MESSAGE E187(ZHELP) WITH ZIC_PREP_ROLEREI-DIV.

      ENDIF.

    ENDIF.


    IF NOT ZIC_PREP_ROLEREI-SHIP_POINT IS INITIAL.

      SELECT SINGLE * FROM TVSWZ INTO CORRESPONDING FIELDS OF
            IT_TVSWZ  WHERE WERKS = ZIC_PREP_ROLEREI-PLANT AND
            VSTEL = ZIC_PREP_ROLEREI-SHIP_POINT.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
        G_I = G_CURR_LINE.
        MESSAGE E188(ZHELP) WITH ZIC_PREP_ROLEREI-SHIP_POINT.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZSD_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO14 INPUT.

  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL114_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL114_ITAB FROM G_TABLCTRL114_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL114_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL114_ITAB  LINES TABLCTRL114-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno14  INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL115_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL115_WA.
  SELECT SINGLE * FROM ZQM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL115_WA-ROLE_DESC = ZQM_PREP_ROLEDES-BRIEF_DESC.
  MODIFY G_TABLCTRL115_ITAB
    FROM G_TABLCTRL115_WA
    INDEX TABLCTRL115-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL115_WA TO G_TABLCTRL115_ITAB.
  ENDIF.

  IF G_TABLCTRL115_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL115_WA-FLAG.
    APPEND G_TABLCTRL115_WA TO G_TABLCTRL115_ITAB.
  ENDIF.
  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_115 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_modify INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL115_MARK INPUT.
  IF TABLCTRL115-LINE_SEL_MODE = 1 AND
     G_TABLCTRL115_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL115_WA-FLAG = ''.
      MODIFY G_TABLCTRL115_ITAB
        FROM G_TABLCTRL115_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL115_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL115_ITAB
    FROM G_TABLCTRL115_WA
    INDEX TABLCTRL115-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL115_mark INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL115_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL115'
                              'G_TABLCTRL115_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL115_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_115 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL115-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_115 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA15 INPUT.

ENDMODULE.                 " validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA15A INPUT.

ENDMODULE.                 " validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO15 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL115_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL115_ITAB FROM G_TABLCTRL115_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL115_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL115_ITAB  LINES TABLCTRL115-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " change_srno15  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CRC_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CRC_POS INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'CRC_POS' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

*  data : loop_step like sy-stepl.
  DATA : L_ROLE_TYPE LIKE ZIC_PREP_ROLEREI-ROLE_NAME.
  DATA : IST_RETURN_TAB1 LIKE STANDARD TABLE OF DSELC WITH HEADER LINE.
  DATA : IST_RETURN_TAB2 LIKE STANDARD TABLE OF DYNPREAD WITH HEADER
         LINE.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0110'
    IMPORTING
      VALUE = L_ROLE_TYPE.

  SELECT * FROM ZMM_PREP_CRCDESG INTO CORRESPONDING FIELDS OF
             TABLE IT_POS WHERE ROLE_TYPE = L_ROLE_TYPE
*Begin of <RD1K962817>.
     AND STATUS  = 'active'.
*End of <RD1K962817>.
  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'CRC_POS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'CRC_ORDER_AUTH'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE_EX'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
*Begin of <RD1K962817>.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_POS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_DESCRIPTION'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'MIN_DESIGNATION'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
*End of <RD1K962817>.

  IST_RETURN_TAB1-FLDNAME = 'ROLE_TYPE_EX'.
  IST_RETURN_TAB1-DYFLDNAME = 'ZIC_PREP_ROLEREI-ROLE_TYPE_EX'.
  APPEND IST_RETURN_TAB1 TO IST_RETURN_TAB1.

  IST_RETURN_TAB1-FLDNAME = 'ROLE_TYPE'.
  IST_RETURN_TAB1-DYFLDNAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  APPEND IST_RETURN_TAB1 TO IST_RETURN_TAB1.

*Begin of <RD1K962817>.
  IST_RETURN_TAB1-FLDNAME = 'MIN_DESIGNATION'.
  IST_RETURN_TAB1-DYFLDNAME = 'ZMM_PREP_CRCDESG-MIN_DESIGNATION'.
  APPEND IST_RETURN_TAB1 TO IST_RETURN_TAB1.
*End of <RD1K962817>.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'CRC_POS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'CRC_POS'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_POS
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_RETURN_TAB1
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE IST_RETURN_TAB WITH KEY FIELDNAME = 'CRC_POS'.
    IST_RETURN_TAB2-FIELDNAME = IST_RETURN_TAB-FIELDNAME.
    IST_RETURN_TAB2-FIELDVALUE = IST_RETURN_TAB-FIELDVAL.
    IST_RETURN_TAB2-STEPL = LOOP_STEP.
    APPEND IST_RETURN_TAB2 TO IST_RETURN_TAB2.
    READ TABLE IST_RETURN_TAB WITH KEY FIELDNAME = 'ROLE_TYPE_EX'.
    CONCATENATE 'ZIC_PREP_ROLEREI-' IST_RETURN_TAB-FIELDNAME INTO
    IST_RETURN_TAB-FIELDNAME.
    IST_RETURN_TAB2-FIELDNAME = IST_RETURN_TAB-FIELDNAME.
    IST_RETURN_TAB2-FIELDVALUE = IST_RETURN_TAB-FIELDVAL.
    IST_RETURN_TAB2-STEPL = LOOP_STEP.
    APPEND IST_RETURN_TAB2 TO IST_RETURN_TAB2.


    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = IST_RETURN_TAB2
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLEAR DIS_FLAG.

  ENDIF.

*Begin of <RD1K962817>.
  IST_RETURN_TAB3[] = IST_RETURN_TAB2[].
*  REFRESH:it_pos,g_field_tab,ist_return_tab,ist_return_tab1.
  REFRESH:IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1,IST_RETURN_TAB2.
*End of <RD1K962817>.
  FREE  : IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1.

ENDMODULE.                 " POV_CRC_POS  INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL116_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL116_WA.

  SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL116_WA-ROLE_DESC = ZHS_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL116_ITAB
    FROM G_TABLCTRL116_WA
    INDEX TABLCTRL116-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL116_WA TO G_TABLCTRL116_ITAB.
  ENDIF.

  IF G_TABLCTRL116_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL116_WA-FLAG.
    APPEND G_TABLCTRL116_WA TO G_TABLCTRL116_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_116 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

ENDMODULE.                    "TABLCTRL116_modify INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL116_MARK INPUT.
  IF TABLCTRL116-LINE_SEL_MODE = 1 AND
     G_TABLCTRL116_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL116_WA-FLAG = ''.
      MODIFY G_TABLCTRL116_ITAB
        FROM G_TABLCTRL116_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL116_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL116_ITAB
    FROM G_TABLCTRL116_WA
    INDEX TABLCTRL116-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL116_mark INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL116_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL116'
                              'G_TABLCTRL116_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL116_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_HSE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_HSE INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT * FROM ZHS_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
               TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_ROLE_HSE  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_116  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_116 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL116-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_116 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_116  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA17  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA17 INPUT.
  SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                   ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA17  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA17A  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA17A INPUT.
  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


*    IF NOT zic_prep_rolerei-plant IS INITIAL.
*
*      SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
*                 TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
*                                    AND werks = zic_prep_rolerei-plant.
*      IF sy-subrc <> 0.
*        g_e_fl = 'X'.
*        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
*        g_i = g_curr_line.
*        MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
*
*      ENDIF.
*
*    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZOL_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

*      IF zic_prep_rolereq-ccode = 'BDW' OR
*         zic_prep_rolereq-ccode = 'SBW'.
*      ELSE.
*        DELETE it_role WHERE role_type = 'PM14' OR
*        role_type = 'PM15' OR role_type = 'PM16'.
*      ENDIF.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA17A  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL117_WA.

  SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL117_WA-ROLE_DESC = ZOL_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL117_ITAB
    FROM G_TABLCTRL117_WA
    INDEX TABLCTRL117-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL117_WA TO G_TABLCTRL117_ITAB.
  ENDIF.

  IF G_TABLCTRL117_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL117_WA-FLAG.
    APPEND G_TABLCTRL117_WA TO G_TABLCTRL117_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_117 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_117 = SY-STEPL AND OKCODE_100 = 'TABLCTRL117_DELE' AND
        G_TABLCTRL117_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.
ENDMODULE.                 " TABLCTRL117_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_MARK INPUT.
  IF TABLCTRL117-LINE_SEL_MODE = 1 AND
       G_TABLCTRL117_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL117_ITAB INTO G_TABLCTRL117_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL117_WA-FLAG = ''.
      MODIFY G_TABLCTRL117_ITAB
        FROM G_TABLCTRL117_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL117_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL117_ITAB
    FROM G_TABLCTRL117_WA
    INDEX TABLCTRL117-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                 " TABLCTRL117_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SRNO17  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO17 INPUT.

  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL117_ITAB INTO G_TABLCTRL117_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL117_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL117_ITAB FROM G_TABLCTRL117_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL117_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL117_ITAB  LINES TABLCTRL117-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " CHANGE_SRNO17  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL117'
                              'G_TABLCTRL117_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                 " TABLCTRL117_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_OLM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_OLM INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

*  TYPES : Begin of z_role_des,
*            role_type like zmm_prep_roledes-role_type,
*            brief_desc like zmm_prep_roledes-brief_desc,
*            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
*            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
*            sort_field like zmm_prep_roledes-brief_desc,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
*          end of z_role_des.

*  DATA   : it_role type table of z_role_des with header line.
*

  SELECT * FROM ZOL_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
             TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

*  IF zic_prep_rolereq-ccode = 'BDW' OR
*     zic_prep_rolereq-ccode = 'SBW'.
*  ELSE.
*    DELETE it_role WHERE role_type = 'PM14' OR
*    role_type = 'PM15' OR role_type = 'PM16'.
*  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.
ENDMODULE.                 " POV_ROLE_OLM  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_LINE_118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_118 INPUT.
  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL118-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_118 = G_CURR_LINE.

ENDMODULE.                 " GET_CURSOR_LINE_118  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATASRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA118 INPUT.
  SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.
ENDMODULE.                 " VALIDATE_LINEITEM_DATASRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SRMROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_SRMROLE INPUT.
  clear:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.





    p_uname = ZIC_PREP_ROLEREQ-USERID.
    p_role = ZIC_PREP_ROLEREI-role_name.
    p_grp = ZIC_PREP_ROLEREI-GRP.

    TRANSLATE p_grp TO UPPER CASE.
    TRANSLATE P_role TO UPPER CASE.

    if  p_role = 'S3'.
      CALL FUNCTION 'ZSRM_ROLE_ASSIGN_CHECK' DESTINATION l_logsys
        EXPORTING
          p_uname = p_uname
          p_grp   = p_grp
          p_role  = p_role
        IMPORTING
          v_exist = v_exist.

      IF v_exist = 'P'.

        MESSAGE e165(zmm_oth) WITH ZIC_PREP_ROLEREI-ROLE_NAME.

      endif.


    endif.

  ENDIF.
  IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    IF  p_role = 'S2'.
      MESSAGE e167(zmm_oth) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDATE_SRMROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SRMGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_SRMGRP INPUT.
  clear:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.





    p_uname = ZIC_PREP_ROLEREQ-USERID.
    p_grp = ZIC_PREP_ROLEREI-GRP.
    p_role = ZIC_PREP_ROLEREI-role_name.

    TRANSLATE p_grp TO UPPER CASE.
    TRANSLATE P_role TO UPPER CASE.

    if p_grp  is not INITIAL.
      CALL FUNCTION 'ZSRM_ROLE_ASSIGN_CHECK' DESTINATION l_logsys
        EXPORTING
          p_uname = p_uname
          p_grp   = p_grp
          p_role  = p_role
        IMPORTING
          v_exist = v_exist.

      IF v_exist = 'Y'.

        MESSAGE e164(zmm_oth) WITH ZIC_PREP_ROLEREI-GRP.

      endif.

      IF v_exist = 'N'.

        MESSAGE e169(zmm_oth) WITH ZIC_PREP_ROLEREI-GRP.

      endif.


    endif.

  endif.



  CLEAR:COUNT_GRP,G_WA_PGRP.

  LOOP AT G_TABLCTRL118_ITAB INTO G_WA_PGRP WHERE  GRP = ZIC_PREP_ROLEREI-GRP  .
    if G_WA_PGRP-GRP  is not initial.
      COUNT_GRP = COUNT_GRP + 1.
    ENDIF.
  ENDLOOP.
  IF  COUNT_GRP > '1'.
    MESSAGE e092(ZHELP).
  ENDIF.
ENDMODULE.                 " VALIDATE_SRMGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA1118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA1118 INPUT.
  clear:G_LINE_srm.
  CONCATENATE  '%' ZIC_PREP_ROLEREQ-CCODE '%' '%'
  INTO G_LINE_srm.

  SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE_srm.


**

  IF  NOT ZIC_PREP_ROLEREI-GRP IS INITIAL.

    LOOP AT IT_T024 INTO WA_T024.

      IF ZIC_PREP_ROLEREI-GRP = WA_T024-EKGRP.
        GRP_FLAG_srm = 'X'.
      ENDIF.

    ENDLOOP.

    IF GRP_FLAG_srm = 'X'.
      CLEAR GRP_FLAG_srm.
    ELSE.
*        G_E_FL = 'X'.
*        G_READ_FL = 'X'.
*        G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
      MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL118_WA.
      MODIFY G_TABLCTRL118_ITAB
                FROM G_TABLCTRL118_WA
                  INDEX TABLCTRL118-CURRENT_LINE.
*        G_I = TABLCTRL110-CURRENT_LINE.
      MESSAGE I069(ZHELP).
      CALL SCREEN 100.
    ENDIF.
  endif.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA1118  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL118_WA.

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
      IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER
   """"""""""""""""""""""""
      "added by lipsy for l2 approver on 20.03.2015 RD1K996555
            OR ( MODULEID = 'SRM' AND ZMM_PREP_ROLEGRP-APPROVER1 = G_USER_L2 )
       "End of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
    """"""""""""""""""""
        .
      ELSE.

        IF OKCODE_100 = 'SAV'.
          IF ERR_FLG <> 'X'.
            ERR_FLG = 'X'.
            CLEAR : SY-UCOMM, OKCODE_100.
          ENDIF.
          MESSAGE E047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT G_TABLCTRL118_WA-ROLE_NAME IS INITIAL.

    SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0.
      G_TABLCTRL118_WA-ROLE_DESC = ZSR_PREP_ROLEDES-BRIEF_DESC.
*Begin  of <RD1K962817>.
*        IF G_TABLCTRL118_WA-ROLE_NAME = 'M8'.
*          G_TABLCTRL118_WA-APPROVER = ZIC_PREP_ROLEREQ-PERSK.
*        ENDIF.
*End of <RD1K962817>.
*        if  not g_tablctrl110_wa-APPROVER is  INITIAL and ZIC_PREP_ROLEREI-ROLE_NAME = 'M8'.
*          loop AT SCREEN.
*            if screen-group2 = 'MOD'.
**              screen-active = 1.
**              screen-output =  1.
*              screen-input = 0.
**              screen-intensified = 0.
*              MODIFY SCREEN .
*              ENDIF.
*              endloop.
*endif.

    ENDIF.

  ENDIF.

  MODIFY G_TABLCTRL118_ITAB
     FROM G_TABLCTRL118_WA
     INDEX TABLCTRL118-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL118_WA TO G_TABLCTRL118_ITAB.
  ENDIF.

  IF G_TABLCTRL118_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL118_WA-FLAG.
    APPEND G_TABLCTRL118_WA TO G_TABLCTRL118_ITAB.
  ENDIF.
ENDMODULE.                 " TABLCTRL118_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_MARK INPUT.
  IF TABLCTRL118-LINE_SEL_MODE = 1 AND
       G_TABLCTRL118_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL118_WA-FLAG = ''.
      MODIFY G_TABLCTRL118_ITAB
        FROM G_TABLCTRL118_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL118_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL118_ITAB
    FROM G_TABLCTRL118_WA
    INDEX TABLCTRL118-CURRENT_LINE.
ENDMODULE.                 " TABLCTRL118_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SRNO_118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO_118 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL118_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL118_ITAB FROM G_TABLCTRL118_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL118_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL118_ITAB  LINES TABLCTRL118-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " CHANGE_SRNO_118  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL118'
                              'G_TABLCTRL118_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                 " TABLCTRL118_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_SRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_SRM INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.



  SELECT * FROM ZSR_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
             TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZSR_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZSR_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZSR_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.
ENDMODULE.                 " POV_ROLE_SRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP_SRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_GRP_SRM INPUT.
  G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.


  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

**  DATA : L_EKGRP LIKE T024-EKGRP.
*  DATA : LOOP_STEP LIKE SY-STEPL.
*  DATA : L_ROLE_NAME LIKE ZIC_PREP_ROLEREI-ROLE_NAME.
*
*  DATA L_DISC_MM_FLAG LIKE ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

*  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
*       EXPORTING
*            STRUC = 'ZIC_PREP_ROLEREQ'
*            FIELD = 'DISC_MM_FLAG'
*            REPID = SY-CPROG
*            DYNNR = '0100'
*       IMPORTING
*            VALUE = l_disc_mm_flag.
*
*  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = l_disc_mm_flag.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0118'
    IMPORTING
      VALUE = L_ROLE_NAME.

  IF L_ROLE_NAME = 'S1' OR  L_ROLE_NAME = 'S2' .
    CONCATENATE '%' G_CCODE '%' INTO G_LINE1.
    SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.

  ELSE.
    IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*      concatenate '%' G_CCODE '-' 'IND' '%'
*      into g_line1.
      CONCATENATE '%' G_CCODE '%' 'IND' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ELSE.
*      concatenate  '%' G_CCODE '-' 'MM' '%'
*      into g_line1.
      CONCATENATE  '%' G_CCODE '%' 'MM' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ENDIF.
  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKGRP'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKNAM'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'EKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-GRP'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_T024
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  FREE : IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR G_FIELD_WA.
ENDMODULE.                 " POV_GRP_SRM  INPUT

*--- INCLUDE: MZMMPREPROLE3_PHASEIIO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  PERFORM FILL_STTAB.

  IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CHANGE' OR
      OLD_OK_CODE = 'DISPLAY' OR OLD_OK_CODE = 'DELETE' OR
      SY-TCODE = 'ZIC_AUTH_CORETEAM'.

    SET PF-STATUS 'OPTNS1' EXCLUDING IT_TAB.

  ELSE.

    SET PF-STATUS 'OPTNS'.

  ENDIF.

  CASE SY-UCOMM.
    WHEN 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Request'.
    WHEN 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Change Request'.
    WHEN 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Display Request'.
    WHEN 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Delete Request'.
    WHEN 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Release Request'.
    WHEN 'APPROVE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Approve Request'.

    WHEN OTHERS.
      SET TITLEBAR 'PREP_TITLE' WITH ''.
  ENDCASE.

  DATA LV_DOCNO TYPE ZCHAR12.

  IF ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.
    GET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
    LV_DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    DELETE GT_ICON1 WHERE DOCNO NE ZIC_PREP_ROLEREQ-DOCNO.
    IF ZIC_PREP_ROLEREQ-DOCNO IS  NOT INITIAL.
      CLEAR ZIC_PREP_ROLEREQ-DOCNO.
    ENDIF.
  ELSE.
    LV_DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
  ENDIF.
  SELECT * FROM ZGRC_SOD_RESULT INTO CORRESPONDING FIELDS OF TABLE GT_ICON WHERE DOCNO = LV_DOCNO.
  GT_ICON1[] = GT_ICON[].
  DESCRIBE TABLE GT_ICON1 LINES LV_COUNT.
  IF SY-TCODE EQ 'ZIC_AUTH_CORETEAM' ." OR SY-TCODE EQ 'ZIC_AUTH_FI_REP'.
    IF LV_COUNT EQ 1.
      GICON = '@08@'. "GREEN
      RISK_DESC = 'No Risk'.
    ELSEIF LV_COUNT GT 1.
      GICON = '@0A@'. "RED
      RISK_DESC = 'Risk found'.
    ELSEIF LV_COUNT EQ 0.
      GICON = '@09@'. " YELLOW
      RISK_DESC = 'Risk Anlys in progress'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_HEADER_DATA OUTPUT.

  IF NOT ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.

    DATA : L_DOCNO LIKE ZIC_PREP_ROLEREQ-DOCNO.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ZIC_PREP_ROLEREQ-DOCNO
      IMPORTING
        OUTPUT = L_DOCNO.

    ZIC_PREP_ROLEREQ-DOCNO = L_DOCNO.

  ENDIF.

  IF  G_HD_COPIED <> 'X'.
*
    IF OLD_OK_CODE IS INITIAL AND OKCODE_100 IS INITIAL.

    ELSE.

      IF OLD_OK_CODE = 'CREATE'  AND OKCODE_100 IS INITIAL.

      ELSE.

        IF ( OLD_OK_CODE = 'CHANGE' ) OR ( OLD_OK_CODE = 'DELETE' )
            OR ( OLD_OK_CODE = 'RELEASE' )
            OR ( OLD_OK_CODE = 'APPROVE' ).
          IF NOT ZIC_PREP_ROLEREQ-DOCNO IS INITIAL AND G_LOCK <> 'Y'.
            PERFORM LOCK_REQHD.
          ENDIF.
        ENDIF.

**      if sy-subrc = 0 and not ZIC_PREP_ROLEREQ-docno is initial.

*        g_hd_copied = 'X'.

**        clear g_TABCTRL100_itab.
**        refresh g_TABCTRL100_itab.

**        select * from ZIC_PREP_ROLEREI into corresponding
**                  fields of table g_TABCTRL100_itab
**                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

**************************
**       clear g_srno.
**************************

**      endif.

        IF NOT ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.

          SELECT SINGLE * FROM ZIC_PREP_ROLEREQ
                     WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

**
          ZIC_PREP_ROLEREQ-COMM_FL = 'X'.

          IF SY-SUBRC = 0 .

*           select single moduleid from zic_prep_rolerei into
*           moduleid where DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

            SELECT DISTINCT MODULEID FROM ZIC_PREP_ROLEREI INTO
            CORRESPONDING FIELDS OF TABLE IT_MODULE1 WHERE DOCNO =
            ZIC_PREP_ROLEREQ-DOCNO.

            SORT IT_MODULE1 BY MODULEID. IF SY-SUBRC <> 0.

              SELECT DISTINCT MODULEID FROM ZIC_PREP_DELROLE INTO
              CORRESPONDING FIELDS OF TABLE IT_MODULE1 WHERE DOCNO =
              ZIC_PREP_ROLEREQ-DOCNO.

            SORT IT_MODULE1 BY MODULEID. ENDIF.

            DATA : L_MODULE_LINES LIKE SY-INDEX.

            DESCRIBE TABLE IT_MODULE1 LINES L_MODULE_LINES.

            READ TABLE IT_MODULE1 INTO WA_MODULE1 WITH KEY
                 MODULEID = 'FI'.
            IF SY-SUBRC = 0 AND WA_MODULE1-MODULEID = 'FI'.
              SET PARAMETER ID 'ZOLDCODE_FI' FIELD 'ASSIGN'.
              SET PARAMETER ID 'ZMODULEID_FI' FIELD 'FI'.
              SET PARAMETER ID 'ZUSERID_FI' FIELD ZIC_PREP_ROLEREQ-USERID.
              LEAVE TO TRANSACTION 'ZIC_AUTH_FI_REP' .
            ENDIF.

            IF L_MODULE_LINES > 1.
              G_MULT_MODULE_FL = 'X'.
            ENDIF.


            G_HD_COPIED = 'X'.
** check line items modulewise/initialise
            G_TABLCTRL110_COPIED = ''.
            G_TABLCTRL111_COPIED = ''.
            G_TABLCTRL112_COPIED = ''.
            G_TABLCTRL113_COPIED = ''.
            G_TABLCTRL114_COPIED = ''.
            G_TABLCTRL115_COPIED = ''.
            G_TABLCTRL116_COPIED = ''.
""""""
    G_TABLCTRL117_COPIED = ''.
   G_TABLCTRL118_COPIED = ''.
 """"""""
**

            IF ZIC_PREP_ROLEREQ-COMM_FL = 'X' AND OLD_OK_CODE = 'CHANGE'
            AND SY-TCODE <> 'ZIC_AUTH_CORETEAM'.

              PERFORM VERIFY2.

            ENDIF.

            PERFORM VALIDATIONS.

          ELSE.
            MESSAGE I101(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
          ENDIF.

        ENDIF.

      ENDIF.

      SELECT SINGLE * FROM T500P
                 WHERE PERSA = ZIC_PREP_ROLEREQ-PERSA.

      IF SY-SUBRC = 0.

        ZIC_PREP_ROLEREQ-NAME1 = T500P-NAME1.

      ENDIF.


    ENDIF.

  ENDIF.

  SELECT SINGLE * FROM ZMM_PREP_RSN
             WHERE REASON = ZIC_PREP_ROLEREQ-RSN_CODE.

  IF SY-SUBRC = 0.

    ZIC_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

  ENDIF.

  SELECT SINGLE * FROM ZMM_PREP_STATUS
             WHERE STATUS_CODE = ZIC_PREP_ROLEREQ-STATUS .

  IF SY-SUBRC = 0.

    STATUS_DESC = ZMM_PREP_STATUS-STATUS_DESC.

  ENDIF.


  IF ZIC_PREP_ROLEREQ-FUNDC <> '' AND ZIC_PREP_ROLEREQ-REASON1 = ''.

    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-REASON1'.
    MESSAGE I100(ZHELP).
  ENDIF.

  PERFORM GET_CORRESPONDENCE.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR100_ATTR OUTPUT.

  CASE OLD_OK_CODE.

    WHEN ''.

      LOOP AT SCREEN.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 'CREATE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.


      ENDLOOP.

    WHEN 'CHANGE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          IF MODULEID <> 'MM' AND SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC'.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          IF MODULEID <> 'MM' AND SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC'.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP3 = 'GPC' .
          IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
            SCREEN-ACTIVE = 1.
          ELSE.
            SCREEN-ACTIVE = 0.
          ENDIF.
          SCREEN-INVISIBLE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-USERID' AND
           ZIC_PREP_ROLEREQ-USERID <> ''.
          SCREEN-INPUT = 0.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-NAME1' ).
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          SCREEN-ACTIVE = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL <> 'X'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT ZIC_PREP_ROLEREQ-FUNDC IS INITIAL.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 1.
          ELSE.
            SCREEN-INPUT = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'RELEASE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          SCREEN-INPUT = 0.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REQ_CR_FL'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'APPROVE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          SCREEN-INPUT = 0.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'TABCTRL100_DELETE'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF G_USER = 'L1' AND SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REQ_APP1_FL'
     .
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.
        IF ( G_USER = 'IM' OR G_USER = 'L3' ) AND
            SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REQ_APP_FL'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'DISPLAY'.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-DOCNO' OR SCREEN-NAME = 'CORR'
                                                 OR SCREEN-NAME = 'STAT'
                                                 OR SCREEN-NAME = 'M'
                                              OR SCREEN-NAME = 'MODULEID'
                                             OR SCREEN-NAME = 'DETAILS'
                                  OR SCREEN-NAME = 'TABCTRL100_PREVIOUS'
                                     OR SCREEN-NAME = 'TABCTRL100_NEXT'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP3 = 'GPC' AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
          SCREEN-ACTIVE = 1.
          SCREEN-INVISIBLE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          SCREEN-ACTIVE = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-USERID' OR
          SCREEN-NAME = 'ZIC_PREP_ROLEREQ-RSN_CODE' OR
          SCREEN-NAME = 'ZIC_PREP_ROLEREQ-TELNO' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'DELETE'.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-DOCNO' OR SCREEN-NAME = 'CORR'
                                                  OR SCREEN-NAME = 'STAT'
     .
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
          SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          SCREEN-ACTIVE = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.


  ENDCASE.

ENDMODULE.                 " TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZE OUTPUT.

  PERFORM GET_CORRESPONDENCE.

ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SPLITTER_CTRL_VORBEREITEN1 OUTPUT.

  IF GV_SPLITTER1 IS INITIAL.
    CREATE OBJECT GV_CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME = 'C_DIS'.

    CREATE OBJECT GV_SPLITTER1
      EXPORTING
        PARENT        = GV_CUSTOM_CONTAINER
        ORIENTATION   = 1
        SASH_POSITION = 1.
  ENDIF.

  IF ( OLD_OK_CODE = 'CREATE' )
  OR ( OLD_OK_CODE = 'CROSSCO' )
  OR ( OLD_OK_CODE = 'CRCROLES' )
  OR ( OLD_OK_CODE = 'CHANGE' )
  OR ( OLD_OK_CODE = 'RELEASE' )
  OR ( OLD_OK_CODE = 'APPROVE' )
  OR ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-STATUS = 'IR' )
  .

    IF GV_SPLITTER2 IS INITIAL.

      CREATE OBJECT GV_CUSTOM_CONTAINER
        EXPORTING
          CONTAINER_NAME = 'C_WRT'.


      CREATE OBJECT GV_SPLITTER2
        EXPORTING
          PARENT        = GV_CUSTOM_CONTAINER
          ORIENTATION   = 1
          SASH_POSITION = 1.

    ENDIF.
  ENDIF.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_VORBEREITEN1 OUTPUT.

  IF GV_TEXT_EDITOR1 IS INITIAL.
    CREATE OBJECT GV_TEXT_EDITOR1
      EXPORTING
        PARENT                     = GV_SPLITTER1->BOTTOM_RIGHT_CONTAINER
        WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
        WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>FALSE
      EXCEPTIONS
        ERROR_CNTL_CREATE          = 1
        ERROR_CNTL_INIT            = 2
        ERROR_CNTL_LINK            = 3
        ERROR_DP_CREATE            = 4
        GUI_TYPE_NOT_SUPPORTED     = 5.
    FLAG1 = 'X'.
  ENDIF.
  IF ( OLD_OK_CODE = 'CREATE' )
      OR ( OLD_OK_CODE = 'CROSSCO' )
      OR ( OLD_OK_CODE = 'CRCROLES' )
      OR ( OLD_OK_CODE = 'CHANGE' )
      OR ( OLD_OK_CODE = 'RELEASE' )
      OR ( OLD_OK_CODE = 'APPROVE' )
       OR ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-STATUS = 'IR' )
  .

    IF GV_TEXT_EDITOR2 IS INITIAL.
      CREATE OBJECT GV_TEXT_EDITOR2
        EXPORTING
          PARENT                     = GV_SPLITTER2->BOTTOM_RIGHT_CONTAINER
          WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
          WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>FALSE
        EXCEPTIONS
          ERROR_CNTL_CREATE          = 1
          ERROR_CNTL_INIT            = 2
          ERROR_CNTL_LINK            = 3
          ERROR_DP_CREATE            = 4
          GUI_TYPE_NOT_SUPPORTED     = 5.
      FLAG2 = 'X'.
    ENDIF.
  ENDIF.

  PERFORM TEXT_CONTROL_EINGABEBEREIT1.
  PERFORM TEXT_CONTROL_SET_TEXT_TABLE1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR100_COL_ATTRIB OUTPUT.

**LOOP AT TABCTRL100-cols INTO cols WHERE index GT 10.
**      cols-invisible = '1'.
**      MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
**ENDLOOP.
**
**LOOP AT TABCTRL100-cols INTO cols WHERE index = 11.
**    cols-invisible = '0'.
**    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
**ENDLOOP.

ENDMODULE.                 " scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP OUTPUT.

*if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

  IF NOT G_TABCTRL100_ITAB[] IS INITIAL .

    SORT G_TABCTRL100_ITAB
    BY ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.
    DELETE ADJACENT DUPLICATES FROM G_TABCTRL100_ITAB
    COMPARING ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.

  ENDIF.

  DESCRIBE TABLE G_TABCTRL100_ITAB LINES TABCTRL100-LINES.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_110 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL110_ITAB LINES TABLCTRL110-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TITLE OUTPUT.

  IF L_OLD_OK_CODE = 'X' AND G_RESET_CHANGE <> 'X'.
    PERFORM AUTH_CHECK.
  ELSE.
    CLEAR G_RESET_CHANGE.
  ENDIF.

  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    G_TEXT = ' : Cross Company'.
  ENDIF.
  IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    G_TEXT = ' : CRC'.
  ENDIF.

  IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
       ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**     or
**     zic_prep_rolereq-status = 'IR'..
    MOVE 'ROLE_DEL' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'ROLE_CR' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.

    SET PF-STATUS 'OPTNS1' EXCLUDING IT_TAB..
  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    MOVE 'ROLE_DEL' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'ROLE_CR' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    SET PF-STATUS 'OPTNS1' EXCLUDING IT_TAB.
  ENDIF.

  SET TITLEBAR 'PREP_TITLE' WITH G_TEXT.

ENDMODULE.                 " set_title  OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL110_INIT OUTPUT.
  IF G_TABLCTRL110_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.

    REFRESH G_TABLCTRL110_ITAB[].
    CLEAR   G_TABLCTRL110_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL110_ITAB WHERE MODULEID = 'MM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO ORDER BY PRIMARY KEY.
    G_TABLCTRL110_COPIED = 'X'.
    READ TABLE G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA INDEX 1.
    IF SY-SUBRC = 0.
      MODULEID = G_TABLCTRL110_WA-MODULEID.
    ENDIF.
    REFRESH CONTROL 'TABLCTRL110' FROM SCREEN '0110'.
  ENDIF.
ENDMODULE.                    "TABLCTRL110_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL110_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL110_WA TO ZIC_PREP_ROLEREI.

  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    IF OLD_OK_CODE = 'CRCROLES' OR ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0 .
        MOVE ZMM_PREP_ROLECRC-BRIEF_DESC TO ROLE_DESC.
      ENDIF.
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0 .
        MOVE ZMM_PREP_CRCDESG-CRC_POS TO CRC_POS.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC = 0 .
        MOVE ZMM_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                    "TABLCTRL110_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL110_GET_LINES OUTPUT.
  G_TABLCTRL110_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL110_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_DYNNR OUTPUT.
  IF DYNNR IS INITIAL.
    DYNNR = '101'.
  ENDIF.
  CASE MODULEID.

    WHEN 'MM'.
      DYNNR = '0110'.
    WHEN 'PM'.
      DYNNR = '0111'.
    WHEN 'PS'.
      DYNNR = '0112'.
    WHEN 'PP'.
      DYNNR = '0113'.
    WHEN 'SD'.
      DYNNR = '0114'.
    WHEN 'QM'.
      DYNNR = '0115'.
    WHEN 'HSE'.
      DYNNR = '0116'.
    WHEN 'OLM'.
      DYNNR = '0117'.

  """"""""""""""""""""""""
       WHEN 'SRM'.
      DYNNR = '0118'.
  """"""""""""""

  ENDCASE.
ENDMODULE.                 " set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR110_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL110-COLS INTO COLS WHERE INDEX GT 11.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL110-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

  LOOP AT TABLCTRL110-COLS INTO COLS WHERE INDEX = 12.
    COLS-INVISIBLE = '0'.
    MODIFY TABLCTRL110-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP_110 OUTPUT.

  IF NOT G_TABLCTRL110_ITAB[] IS INITIAL .

    SORT G_TABLCTRL110_ITAB
    BY ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.
    DELETE ADJACENT DUPLICATES FROM G_TABLCTRL110_ITAB
    COMPARING ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.

  ENDIF.

  DESCRIBE TABLE G_TABLCTRL110_ITAB LINES TABLCTRL110-LINES.

ENDMODULE.                 " delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL110_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL110_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

*        if sy-tcode = 'ZIC_AUTH_CORETEAM' and
*              screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
*              old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREI-REJ_FL = ''.
*          screen-input = 1.
*          modify screen.
*        endif.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.


        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      IF ZIC_PREP_ROLEREQ-CRC_FL = 'X' OR OLD_OK_CODE = 'CRCROLES'.

        SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                                                  G_TABLCTRL110_WA-ROLE_NAME
    .

        IF SY-SUBRC = 0.

          LOOP AT SCREEN.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ENDIF.


            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP' .

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC'.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDLOOP.

        ELSE.

          LOOP AT SCREEN.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                               NOT OLD_OK_CODE IS INITIAL.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.

              IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
                MESSAGE I116(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
              ENDIF.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

ENDMODULE.                 " TABLCTRL110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL111_INIT OUTPUT.
  IF G_TABLCTRL111_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL111_ITAB[].
    CLEAR   G_TABLCTRL111_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL111_ITAB WHERE MODULEID = 'PM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL111_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL111' FROM SCREEN '0111'.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL111_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TABLCTRL111_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZPM_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL111_GET_LINES OUTPUT.
  G_TABLCTRL111_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL111_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP_111 OUTPUT.
  IF NOT G_TABLCTRL111_ITAB[] IS INITIAL .

    SORT G_TABLCTRL111_ITAB
    BY ROLE_NAME PLANT SHOP_NO.
    DELETE ADJACENT DUPLICATES FROM G_TABLCTRL111_ITAB
    COMPARING ROLE_NAME PLANT REJ_FL SHOP_NO.

  ENDIF.

  DESCRIBE TABLE G_TABLCTRL111_ITAB LINES TABLCTRL111-LINES.

ENDMODULE.                 " delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL111_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL111_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHOP_NO' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_111 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL111_ITAB LINES TABLCTRL111-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR111_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL111-COLS INTO COLS WHERE INDEX GT 8.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL111-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_INIT OUTPUT.

  PERFORM CHECK_LIST_PROCESSING.

  PERFORM GET_USER.

  PERFORM UPLOAD1_FILE.

  IF G_HD_COPIED IS INITIAL.

    DATA L_FIS_INITIAL.
    SET PARAMETER ID 'FIS' FIELD L_FIS_INITIAL.
    SET PARAMETER ID 'BUK' FIELD L_FIS_INITIAL.
  ENDIF.

  GET PARAMETER ID 'ZOLDCODE' FIELD L_OLD_OK_CODE.

  IF L_OLD_OK_CODE = 'X'.
    GET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
    OLD_OK_CODE = 'CHANGE'.
  ENDIF.

ENDMODULE.                 " TABCTRL100_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_120 OUTPUT.

  PERFORM HIDE.
  SET PF-STATUS 'STATUS_120'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALUE_LIST OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  SET PF-STATUS 'STATUS_120' EXCLUDING TAB.
  CLEAR : WA_TAB.
  REFRESH : TAB.
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
          COLOR COL_HEADING.
  ULINE.
  IF FLAG_S_FUNDC = 'X' AND OKCODE_100 <> 'SUIM'.
    PERFORM HELP_LIST.
  ENDIF.

  IF OKCODE_100 = 'SUIM'.
    PERFORM HELP_SUIM.
  ENDIF.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELECT_DATA OUTPUT.
  SELECT SINGLE * FROM ZIC_PREP_ROLEREQ
  WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

  SELECT * FROM ZIC_PREP_ROLEREI INTO TABLE IST_ITEM
  WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

ENDMODULE.                 " SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALUE_LIST1 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  DATA : L_DESC(30).
  SORT IST_ITEM DESCENDING.

  LOOP AT IST_ITEM INTO WA_ITEM.
    CASE WA_ITEM-MODULEID.
      WHEN 'MM'.
        PERFORM CHECK_MODULE_STATUS_MM.
      WHEN 'PM'.
        PERFORM CHECK_MODULE_STATUS_PM.
      WHEN 'PS'.
        PERFORM CHECK_MODULE_STATUS_PS.
      WHEN 'PP'.
        PERFORM CHECK_MODULE_STATUS_PP.
      WHEN 'SD'.
        PERFORM CHECK_MODULE_STATUS_SD.
      WHEN 'QM'.
        PERFORM CHECK_MODULE_STATUS_QM.
      WHEN 'HSE'.
        PERFORM CHECK_MODULE_STATUS_HSE.
    ENDCASE.
  ENDLOOP.

  LOOP AT IST_ITEM INTO WA_ITEM.

    CASE WA_ITEM-MODULEID .

      WHEN 'MM'.

        AT NEW MODULEID.

          WRITE :/.

          IF MM_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.

          WRITE: / 'MM Module', 'Role', 'Description',
                 AT 48  'Plant',
                 AT 53  'PurGp',
                 AT 59  'Sloc',
                 AT 64  'RecptLoc',
                 AT 73  'User level' .

          FORMAT INTENSIFIED OFF COLOR OFF.

*     uline.

        ENDAT.

        IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

          SELECT BRIEF_DESC FROM ZMM_PREP_ROLECRC INTO L_DESC UP TO 1 ROWS
 WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        ELSE.

          SELECT SINGLE BRIEF_DESC FROM ZMM_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        ENDIF.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 53 WA_ITEM-GRP,
                 AT 59 WA_ITEM-SLOC,
                 AT 64 WA_ITEM-RECEIPT_LOC,
                 AT 73 WA_ITEM-APPROVER.

      WHEN 'PM'.

        AT NEW MODULEID.

          WRITE /.

          IF PM_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.

          WRITE: / 'PM Module', 'Role', 'Description',
             AT 48  'Plant',
             AT 54  'ShopNo'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZPM_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 54 WA_ITEM-SHOP_NO.
**
      WHEN 'PS'.

        AT NEW MODULEID.

          WRITE /.

          IF PS_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'PS Module', 'Role', 'Description',
             AT 48  'Service',
             AT 56  'Project',
             AT 64  'Location',
             AT 73  'Asset',
             AT 79  'Basin'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZPS_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-SERVICE,
                 AT 56 WA_ITEM-PROJECT,
                 AT 64 WA_ITEM-LOCATION,
                 AT 73 WA_ITEM-ASSET,
                 AT 79 WA_ITEM-BASIN.

***

      WHEN 'PP'.

        AT NEW MODULEID.

          WRITE /.

          IF PP_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'PP Module', 'Role', 'Description',
             AT 48  'Plant',
             AT 56  'Sloc',
             AT 64  'Resource',
             AT 73  'CTF_sloc'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZPP_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 56 WA_ITEM-SLOC,
                 AT 64 WA_ITEM-RES,
                 AT 73 WA_ITEM-CTF_SLOC.

      WHEN 'SD'.

        AT NEW MODULEID.

          WRITE /.

          IF SD_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'SD Module', 'Role', 'Description',
             AT 48  'S_Org',
             AT 56  'Div',
             AT 64  'Plant',
             AT 73  'ShPt'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZSD_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-SALE_ORG,
                 AT 56 WA_ITEM-DIV,
                 AT 64 WA_ITEM-PLANT,
                 AT 73 WA_ITEM-SHIP_POINT.

      WHEN 'QM'.

        AT NEW MODULEID.

          WRITE /.

          IF QM_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'QM Module', 'Role', 'Description',
             AT 48  'Plant',
             AT 56  'Asset'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZQM_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 56 WA_ITEM-ASSET_QM.

      WHEN 'HSE'.

        AT NEW MODULEID.

          WRITE /.

          IF HS_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'HSE Module', 'Role', 'Description'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZHS_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC.

    ENDCASE.

*
*
    HIDE : WA_ITEM-MODULEID, WA_ITEM-ROLE_NAME, WA_ITEM-PLANT,
             WA_ITEM-GRP, WA_ITEM-SLOC, WA_ITEM-RECEIPT_LOC,
             WA_ITEM-APPROVER, WA_ITEM-SERVICE, WA_ITEM-PROJECT,
             WA_ITEM-LOCATION,WA_ITEM-REGION,WA_ITEM-ASSET,
             WA_ITEM-BASIN,WA_ITEM-RES, WA_ITEM-CTF_SLOC,
             WA_ITEM-SALE_ORG,WA_ITEM-DIV,WA_ITEM-PLANT,
             WA_ITEM-SHIP_POINT.

  ENDLOOP.
**************************************
ENDMODULE.                 " value_list1  OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL112_INIT OUTPUT.
  IF G_TABLCTRL112_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL112_ITAB[].
    CLEAR   G_TABLCTRL112_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL112_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL112_ITAB WHERE
       MODULEID = 'PS' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL112_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL112' FROM SCREEN '0112'.
  ENDIF.
ENDMODULE.                    "TABLCTRL112_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL112_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL112_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZPS_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL112_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL112_GET_LINES OUTPUT.
  G_TABLCTRL112_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL112_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL112_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL112_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SERVICE' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PROJECT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-LOCATION' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ASSET' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-BASIN' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_112 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL112_ITAB LINES TABLCTRL112-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR112_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL112-COLS INTO COLS WHERE INDEX GT 11.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL112-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR112_ATTRIB OUTPUT.

  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL112_DELETE' OR
             SCREEN-NAME = 'TABLCTRL112_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " scr112_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL113_INIT OUTPUT.

  IF G_TABLCTRL113_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL113_ITAB[].
    CLEAR   G_TABLCTRL113_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL113_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL113_ITAB WHERE MODULEID = 'PP' AND
       DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL113_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL113' FROM SCREEN '0113'.
  ENDIF.
ENDMODULE.                    "TABLCTRL113_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL113_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL113_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZPP_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL113_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL113_GET_LINES OUTPUT.
  G_TABLCTRL113_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL113_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR113_COL_ATTRIB OUTPUT.
  LOOP AT TABLCTRL113-COLS INTO COLS WHERE INDEX GT 10.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL113-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR113_ATTRIB OUTPUT.
  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL113_DELETE' OR
             SCREEN-NAME = 'TABLCTRL113_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL113_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL113_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RES' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-CTF_SLOC' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_113 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL113_ITAB LINES TABLCTRL113-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_113.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_113  OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL114_INIT OUTPUT.
  IF G_TABLCTRL114_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL114_ITAB[].
    CLEAR   G_TABLCTRL114_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL114_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL114_ITAB WHERE MODULEID = 'SD' AND
       DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL114_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL114' FROM SCREEN '0114'.
  ENDIF.
ENDMODULE.                    "TABLCTRL114_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL114_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL114_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZSD_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL114_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL114_GET_LINES OUTPUT.
  G_TABLCTRL114_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL114_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR114_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL114-COLS INTO COLS WHERE INDEX GT 10.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL114-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.


ENDMODULE.                 " scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR114_ATTRIB OUTPUT.

  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL114_DELETE' OR
             SCREEN-NAME = 'TABLCTRL114_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL114_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.


  IF OLD_OK_CODE <> 'DISPLAY'.

    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL114_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
               SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
               AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
               AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
***

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SALE_ORG' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-DIV'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHIP_POINT' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_114  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_114 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL114_ITAB LINES TABLCTRL114-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_114.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_114  OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL115_INIT OUTPUT.
  IF G_TABLCTRL115_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL115_ITAB[].
    CLEAR   G_TABLCTRL115_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL115_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL115_ITAB WHERE
       MODULEID = 'QM' AND
       DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL115_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL115' FROM SCREEN '0115'.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL115_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL115_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZQM_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZQM_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL115_GET_LINES OUTPUT.
  G_TABLCTRL115_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL115_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR115_COL_ATTRIB OUTPUT.
  LOOP AT TABLCTRL115-COLS INTO COLS WHERE INDEX GT 8.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL115-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.
ENDMODULE.                 " scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR115_ATTRIB OUTPUT.
  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL115_DELETE' OR
             SCREEN-NAME = 'TABLCTRL115_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_115  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_115 OUTPUT.
  DESCRIBE TABLE G_TABLCTRL115_ITAB LINES TABLCTRL115-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_115.
  ENDIF.

  CLEAR SY-UCOMM.
ENDMODULE.                 " set_cursor_115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL115_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL115_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL116_INIT OUTPUT.
  IF G_TABLCTRL116_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL116_ITAB[].
    CLEAR   G_TABLCTRL116_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL116_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL116_ITAB WHERE MODULEID = 'HSE' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL116_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL116' FROM SCREEN '0116'.
  ENDIF.
ENDMODULE.                    "TABLCTRL116_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL116_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL116_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZHS_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL116_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL116_GET_LINES OUTPUT.
  G_TABLCTRL116_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL116_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL116_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY'.

    SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL116_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_116  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_116 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL116_ITAB LINES TABLCTRL116-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_111
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_116  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_116  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_116 OUTPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL116-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_116 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_116  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_DATA OUTPUT.
  G_ROLE_NAME_PREV = ZIC_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data16  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA16 OUTPUT.

  SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data16  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr116_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR116_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL116-COLS INTO COLS WHERE INDEX GT 6.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL116-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr116_col_attrib  OUTPUT
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_INIT OUTPUT.
  IF G_TABLCTRL117_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL117_ITAB[].
    CLEAR   G_TABLCTRL117_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL117_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL117_ITAB WHERE MODULEID = 'OLM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL117_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL117' FROM SCREEN '0117'.
  ENDIF.
ENDMODULE.                 " TABLCTRL117_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR117_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR117_COL_ATTRIB OUTPUT.
  LOOP AT TABLCTRL117-COLS INTO COLS WHERE INDEX GT 8.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL117-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " SCR117_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL117_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZOL_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TABLCTRL117_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_GET_LINES OUTPUT.
  G_TABLCTRL117_LINES = SY-LOOPC.
ENDMODULE.                 " TABLCTRL117_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_ATTRIB OUTPUT.
  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL117_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHOP_NO' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.
ENDMODULE.                 " TABLCTRL117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_117  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_117 OUTPUT.
  DESCRIBE TABLE G_TABLCTRL117_ITAB LINES TABLCTRL117-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.
ENDMODULE.                 " SET_CURSOR_117  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_INIT OUTPUT.
IF G_TABLCTRL118_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.

    REFRESH G_TABLCTRL118_ITAB[].
    CLEAR   G_TABLCTRL118_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL118_ITAB WHERE MODULEID = 'SRM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO ORDER BY PRIMARY KEY.
    G_TABLCTRL110_COPIED = 'X'.
    READ TABLE G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA INDEX 1.
    IF SY-SUBRC = 0.
      MODULEID = G_TABLCTRL118_WA-MODULEID.
    ENDIF.
    REFRESH CONTROL 'TABLCTRL118' FROM SCREEN '0118'.
  ENDIF.


ENDMODULE.                 " TABLCTRL118_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR118_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR118_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL118-COLS INTO COLS WHERE INDEX GT 11.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL118-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

  LOOP AT TABLCTRL118-COLS INTO COLS WHERE INDEX = 12.
    COLS-INVISIBLE = '0'.
    MODIFY TABLCTRL118-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.
ENDMODULE.                 " SCR118_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL118_WA TO ZIC_PREP_ROLEREI.

  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.


      SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC = 0 .
        MOVE ZSR_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
      ENDIF.


  ENDIF.
ENDMODULE.                 " TABLCTRL118_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_GET_LINES OUTPUT.
  G_TABLCTRL118_LINES = SY-LOOPC.
ENDMODULE.                 " TABLCTRL118_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_ATTRIB OUTPUT.
 IF OLD_OK_CODE <> 'DISPLAY' AND OLD_OK_CODE <> ''.


      SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                                                G_TABLCTRL118_WA-ROLE_NAME.

      IF SY-SUBRC = 0.

        LOOP AT SCREEN.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

            IF OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
            ELSE.
              SCREEN-INPUT = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
            OLD_OK_CODE = 'APPROVE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

            IF ZSR_PREP_ROLEDES-PLANT = 'X' AND
                          OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP'.

            IF ZSR_PREP_ROLEDES-P_GRP = 'X' AND
                          OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.

            IF ZSR_PREP_ROLEDES-APP_LEVEL = 'X' AND
                        OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

*Begin of <RD1K962817>.
*          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.
*            IF G_TABLCTRL118_WA-ROLE_NAME = 'M8'.
*              IF ZSR_PREP_ROLEDES-APP_LEVEL = 'X' AND
*                          OLD_OK_CODE <> 'APPROVE'.
*
*                SCREEN-INPUT = 0.
*
*                MODIFY SCREEN.
*              ELSE.
*                SCREEN-INPUT = 0.
*                MODIFY SCREEN.
*              ENDIF.
*
*            ENDIF.
*          ENDIF.
*End of <RD1K962817>.
          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC'.

            IF ZSR_PREP_ROLEDES-S_LOC = 'X' AND
                      OLD_OK_CODE <> 'APPROVE'.
              .
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

            IF ZSR_PREP_ROLEDES-R_LOC = 'X' AND
                      OLD_OK_CODE <> 'APPROVE'.
              .
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

        ENDLOOP.

      ELSE.

        LOOP AT SCREEN.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                         NOT OLD_OK_CODE IS INITIAL AND
                         OLD_OK_CODE <> 'APPROVE'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
            IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL .
              MESSAGE I115(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
            ENDIF.
          ELSE.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDLOOP.

      ENDIF.

*    ELSE.



*    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

  LOOP AT SCREEN.

    IF ZIC_PREP_ROLEREI-REJ_FL <> ''.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF OLD_OK_CODE = 'DELETE'.

    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " TABLCTRL118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_118  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_118 OUTPUT.
DESCRIBE TABLE G_TABLCTRL118_ITAB LINES TABLCTRL118-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_118
.
  ENDIF.

  CLEAR SY-UCOMM.
ENDMODULE.                 " SET_CURSOR_118  OUTPUT

*--- INCLUDE: MZMMPREPROLE3_PHASEIITOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Removed EPC Error: Length
*                                           specification for type I.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 334.
************************************************************************

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZIC_PREP_ROLEREQ, ZIC_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
zhelp_mmroles, zmm_prep_role_sl, zhelp_mmroles_rc,
ZMM_PREP_REJ_LIS, ZMM_PREP_EX_APP, soodk, sood5, ZMM_PREP_ROLECRC,
zmm_prep_sl_excp, zpm_prep_roledes, zps_prep_roledes, v_t357,
zmm_prep_usrcont, zauth_user,
zice_prep_module, ZMM_PREP_STATUS,t001,zpp_prep_roledes,
zpp_prep_generic,zsd_prep_roledes,ZPP_PREP_DROLEEX,
zsd_prep_level,zpp_prep_res,zsd_prep_area,zqm_prep_roledes,
zhelp_qmroles,zqm_prep_loc,zqm_prep_asset,zmm_prep_crcdesg,
zps_prep_loca,zhs_prep_roledes,ZMM_PREP_CRCIMII,zOL_prep_roledes

*.

"""""""
,ZSR_PREP_ROLEDES.
"""""""""

TYPE-POOLS CXTAB .


Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

TYPES : BEGIN OF ty_t024,
         ekgrp like t024-ekgrp,
         eknam like t024-eknam,
        END of ty_t024.

TYPES: BEGIN OF ty_m_fistb.
TYPES: g_mark.
        include structure m_fistb.
TYPES: END OF ty_m_fistb.

TYPES : begin of in_roles,
            Role_type(04),
            Role_name like vagratts-agr_name,
            fr_date_auth(10),
            to_date_auth(10),
        end of in_roles,

        begin of out_roles,
            Userid like sy-uname,
            Role_name like vagratts-agr_name,
            fr_date_auth(10),
            to_date_auth(10),
        end of out_roles,

        begin of userids,
            cpfno like sy-uname,
        end of userids.

types : begin of del_roles,
            Userid like sy-uname,
            Role_name like vagratts-agr_name,
        end of del_roles.


TYPES : BEGIN OF ty_data,
          pernr     LIKE pa0027-pernr,
          begda     LIKE pa0001-begda,
          endda     LIKE pa0001-endda,
          name      LIKE pa0001-ename,
          bukrs     LIKE pa0001-bukrs,
          werks     LIKE pa0001-werks,
          persk     LIKE pa0001-persk,
          kbu01     LIKE pa0027-kbu01,
          kgb01     LIKE pa0027-kgb01,
          kst01     LIKE pa0027-kst01,
          designo   LIKE pa9930-designo,
          r_p_cd    LIKE pa9930-r_p_cd,
          version   LIKE pa9930-version,
          designation LIKE zdesignation_rev-sdesig_text,
          adesignation LIKE zdesignation_rev-adesig_text,
          DISC_CD   LIKE zdesignation_rev-DISC_CD,
          sbmod     type pa0001-sbmod,
        END OF ty_data.

Data: it_tab type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type,
      wa_pa0027 type pa0027.

data : p1_file LIKE rlgrap-filename value 'C:\role_upload.txt'.

DATA : it_roles TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_pm TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_ps TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_pp TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_sd TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1_pp like standard table of zhelp_pproles1.
DATA : it_roles1_pp_tmp like standard table of zhelp_pproles1.
DATA : it_roles2_pp like standard table of zpp_prep_droleex.
DATA : it_roles3_pp like standard table of zpp_prep_drole.
DATA : it_roles_qm TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_hs TYPE STANDARD TABLE OF in_roles.
**Code added by CAB_AMITMOZA   CR:30007580 WR:RD1K983325  dt:18.03.2013
DATA : it_roles_olm TYPE STANDARD TABLE OF in_roles.
DATA  WA_ROLES_olm like line of it_roles_olm.
**Code end by CAB_AMITMOZA   CR:30007580 WR:RD1K983325
DATA : it_roles0 TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1 TYPE STANDARD TABLE OF out_roles.
DATA : it_roles1_addl TYPE STANDARD TABLE OF out_roles.
DATA : it_agr_users type standard table of agr_users .
DATA : it_role_del_data type table of del_roles.
DATA : wa_role_del_data type del_roles.
DATA : wa_agr_users like agr_users.
DATA : wa_roles TYPE in_roles.   " work area
DATA : wa_roles1_pp like zhelp_pproles1.
DATA : wa_roles2_pp like zpp_prep_droleex.
DATA : wa_roles3_pp like zpp_prep_drole.
DATA : WA_ROLES1 type out_roles.

DATA : ist_seltab like table of rsparams.
DATA : seltab like rsparams.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data with header line.
DATA : ist_data1 TYPE STANDARD  TABLE OF ty_data with header line.
DATA : it_m_fistb TYPE STANDARD TABLE OF ty_m_fistb.

****************************************************************
types:
begin of ty_view_apx,
        selc(1) type c.
        include structure bcos_appx.
types: end of ty_view_apx.

constants: cs_x(1) value 'X'.

data : g_apx_exist(1).

data: begin of gs_win_head.
        include structure soxwd.
data: end of gs_win_head.

DATA : gt_cont like soli occurs 0 with header line,
       gv_filetype like rlgrap-filetype,
       gv_filename type string,
       g_apx_cnt like bcos_appx-appxno,
       g_apx_ptr like bcos_appx-firstl,
       g_apx_bin_ptr like bcos_appx-firstl,
       gt_ac_cont like soli occurs 0 with header line,
       gt_ac_contx like solix occurs 0 with header line,
       gt_view_apx type ty_view_apx occurs 0 with header line,
       gt_ac_apx like bcos_appx occurs 5 with header line,
       gt_contx like solix occurs 0 with header line.
****************************************************************
data g_object_id         like soodk.
data g_attachments  like sood5 occurs 0 with header line.
data g_attachments_read type c.
data on  type c value 'X'.
****************************************************************

DATA : TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

DATA  dynnr like sy-dynnr.

DATA  g_mode.
DATA  okcode like sy-ucomm.
DATA  g_lock.
DATA  g_hd_copied.
DATA  g_cors.
DATA  g_char(120).
DATA  g_line1(120).
DATA : cpf_lfb1(10) type c.

*--------Purpose: Sending mail to user
data : object_content like solisti1  occurs 0 with header line.
data : begin of objhead occurs 5.
        include structure solisti1.
data : end of objhead.

data : begin of document_data.
        include structure sodocchgi1.
data : end of document_data.
data : receivers type table of   somlreci1  .
data : wa_receivers type somlreci1.
data : sent_to_all   like  sonv-flag.
DATA : g_flag.
*--------------------------------------


*&spwizard: type for the data of tablecontrol 'TABCTRL100'
types: begin of t_TABCTRL100,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         role_desc like zmm_prep_roledes-brief_desc,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-receipt_loc,
         SLOC like ZIC_PREP_ROLEREI-sloc,
         flag,       "flag for mark column
         srno like ZIC_PREP_ROLEREI-srno,
         approver like ZIC_PREP_ROLEREI-approver,
         rej_fl like ZIC_PREP_ROLEREI-rej_fl,
         rej_id like ZIC_PREP_ROLEREI-rej_id,
         rej_date like ZIC_PREP_ROLEREI-rej_date,
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
         status like ZIC_PREP_ROLEREI-status,
       end of t_TABCTRL100.

data: ist_itemtab type standard table of ZIC_PREP_ROLEREI.
data: wa_itemtab like ZIC_PREP_ROLEREI.

***********************************************************************
data : ist_colsscreen type table of cxtab_column-screen.
data : ist_column type standard table of cxtab_column with non-unique
default key.
***********************************************************************

*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*

DATA: GV_SPLITTER TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
      GV_SPLITTER1 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
      GV_SPLITTER2 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER.

DATA: GV_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

DATA: GV_TEXT_EDITOR TYPE REF TO CL_GUI_TEXTEDIT,
      GV_TEXT_EDITOR1 TYPE REF TO CL_GUI_TEXTEDIT,
      GV_TEXT_EDITOR2 TYPE REF TO CL_GUI_TEXTEDIT .

DATA : DISPLAY_FLAG LIKE  LV70T-XFLAG VALUE SPACE.

DATA: BEGIN OF TLINETAB OCCURS 10.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TLINETAB.
DATA: BEGIN OF TLINETAB1 OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TLINETAB1.
DATA: BEGIN OF TLINETAB2 OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TLINETAB2.

CONSTANTS: GC_TEXT_LINE_LENGTH TYPE I VALUE 132.

TYPES: TEXT_TABLE_TYPE(GC_TEXT_LINE_LENGTH) TYPE C OCCURS 0.

DATA: LT_TEXT_TABLE TYPE TEXT_TABLE_TYPE,
      LT_TEXT_TABLE1 TYPE TEXT_TABLE_TYPE,
      LT_TEXT_TABLE2 TYPE TEXT_TABLE_TYPE.


DATA: GV_XTHEAD_UPDKZ TYPE I.

DATA: BEGIN OF TINLINETAB OCCURS 10.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TINLINETAB.

DATA: LS_THEAD LIKE THEAD OCCURS 0 WITH HEADER LINE.

DATA: L_THEAD LIKE LS_THEAD OCCURS 0 WITH HEADER LINE.

DATA  G_TDNAME(12).

DATA: BEGIN OF LINES20 OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES20.

Data: g2_lines like tline.

DATA: BEGIN OF LINES_CORS OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES_CORS.

DATA: BEGIN OF g_LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF g_LINES.

***************************************************************

*&spwizard: internal table for tablecontrol 'TABCTRL100'
data:     g_TABCTRL100_itab   type t_TABCTRL100 occurs 0,
          g_TABCTRL100_wa     type t_TABCTRL100. "work area
data:     g_TABCTRL100_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABCTRL100' itself
controls: TABCTRL100 type tableview using screen 0100.
DATA cols LIKE LINE OF TABCTRL100-cols.

*&spwizard: lines of tablecontrol 'TABCTRL100'
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
      End of g_linefrto.
Data: g_linefrto_itab like table of g_linefrto.
data : g_TABCTRL100_lines  like sy-loopc.
DATA : it_cond like table of g_char.
DATA : g_select(2).
DATA : g_select_flag.
DATA : it_t024 TYPE STANDARD TABLE OF t024.
DATA : wa_t024 like line of it_t024.
DATA : it_t024_1 TYPE STANDARD TABLE OF t024.
DATA : role_desc(40).
DATA : okcode_100 like sy-ucomm.
DATA : g_line(120).
DATA : help_list_flag.
DATA : wa_m_fistb type ty_m_fistb.
DATA : lines like sy-index.
DATA : flag_s_fundc value 'X'.
DATA : lines_index like sy-index.
DATA : ZDOCNUMB(12).
DATA : insert_items.
DATA : old_ok_code like sy-ucomm.
DATA : g_srno like sy-index.
DATA : old_doc_no like ZIC_PREP_ROLEREQ-docno.
DATA : g_line132(132) type c.
Data : g_cores_sender like tline-tdline.
Data : g_user(2).
DATA : g_user_found.
DATA : err_flg.
DATA : tab1_lines like sy-index.
DATA : tab2_lines like sy-index.
DATA : flag1, flag2.
DATA  read_flag.
DATA  disp_flag.
DATA  g_ins_flag.
DATA : g_lines1 like sy-index.
DATA  ZROLEREQNO like ZMM_PREP_ROLEREq-docno.
*Begin of <RD1K963151>.
DATA  zuserid like ZIC_PREP_ROLEREQ-USERIDCR.
DATA  zapprover like ZIC_PREP_ROLEREQ-USERIDAP.
*End of <RD1K963151>.
DATA  g_ans_mail.
DATA  : Flag.
DATA  gl_ans.
DATA  g_userid like wa_roles1-userid..
* begin of <RD1K960036>
* Length specification is not allowed for type I
*DATA : flag_start, l_color(2) type I.
DATA : flag_start, l_color type I.
* end of <RD1K960036>
DATA  g_clines like sy-index..
DATA  corr_code like sy-ucomm.
DATA  g_role_flag.

DATA  g_cursor_line like sy-stepl.
DATA  g_curr_line like sy-stepl.
DATA  g_current_line like sy-stepl.
DATA  g_curr_line_100 like sy-stepl.
DATA  g_curr_line_110 like sy-stepl.
DATA  grp_flag.
DATA  plant_flag.
DATA  loc_flag.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  l_old_ok_code.
DATA  g_reset_change.
DATA  l_initial.
DATA  g_list_proc_flag.
DATA  g_ctrl_flag.

DATA  g_rej_fl.

DATA  g_reset_fl.
DATA  g_docno like ZIC_PREP_ROLEREQ-docno.
DATA  g_app_rel.
DATA  g_release like ZIC_PREP_ROLEREQ-req_cr_fl.
DATA  g_approve like ZIC_PREP_ROLEREQ-req_app_fl.
DATA  g_approve1 like ZIC_PREP_ROLEREQ-req_app1_fl.
DATA  g_i like sy-index.
DATA  g_tc_lines like sy-index.
DATA  g_comm_fl.
DATA  g_read_fl.
DATA  g_lines_rl like sy-index.
DATA  g_field(40).
DATA  g_e_fl.
DATA  i080.
DATA  g_status_update_flag.
DATA  g_status_update_rolereq.
DATA  g_request_close_flag.
DATA  g_request_close_flag_P.
DATA  g_request_close_flag_H.
DATA  g_request_close_flag_R.

DATA  g_role_name_prev like ZIC_PREP_ROLEREI-ROLE_NAME.
DATA  g_role_name_flag.
DATA  g_persa like pa0001-werks.
DATA  g_approve0 like ZIC_PREP_ROLEREQ-req_app1_fl.
DATA  old_disc_mm_flag.
DATA  set_disc_mm_flag.
DATA  CRC_CHECK_FL.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files like table of SWOTOBJID.
data g_att_files_wa like SWOTOBJID.
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA  g_exit_value.

DATA  old_userid like ZIC_PREP_ROLEREQ-userid.
DATA  g_val_err.
DATA  g_lines_2 like sy-index.
DATA  old_ok_code_crc like old_ok_code.
DATA  g_crc_fl.
DATA  G_CCODE like ZIC_PREP_ROLEREQ-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(80).

****************************
data : g_field_tab like table of dfies.
data : g_field_wa  like dfies.
DATA  approver_flag.
DATA  G_CCODE_CROSSCO like ZIC_PREP_ROLEREQ-CCODE.

DATA  okcode_dblclk like sy-ucomm.
DATA  g_curfield(60).
DATA  g_i80.
DATA : crc_pos(132).

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
types: begin of t_TABLCTRL110,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         shop_no like ZIC_PREP_ROLEREI-shop_no,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex like zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
       end of t_TABLCTRL110.

*&spwizard: internal table for tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL110_itab   type t_TABLCTRL110 occurs 0,
          g_TABLCTRL110_wa     type t_TABLCTRL110. "work area
data:     g_TABLCTRL110_copied.           "copy flag
DATA:     wa_rolesz type t_TABLCTRL110.

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
controls: TABLCTRL110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
data:     moduleid(3).
DATA      old_moduleid(3).

*&spwizard: type for the data of tablecontrol 'TABLCTRL111'
types: begin of t_TABLCTRL111,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         SHOP_NO like ZIC_PREP_ROLEREI-SHOP_NO,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
       end of t_TABLCTRL111.

*&spwizard: internal table for tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_itab   type t_TABLCTRL111 occurs 0,
          g_TABLCTRL111_wa     type t_TABLCTRL111. "work area
data:     g_TABLCTRL111_copied.           "copy flag
DATA:     wa_rolesz_pm type t_TABLCTRL111.

*&spwizard: declaration of tablecontrol 'TABLCTRL111' itself
controls: TABLCTRL111 type tableview using screen 0111.

*&spwizard: lines of tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_lines  like sy-loopc.
DATA      g_curr_line_111 like sy-stepl.
DATA  check_role_flag.
DATA  WA_ROLES_PM like line of it_roles_pm.
DATA  WA_ROLES_PS like line of it_roles_ps.
DATA  WA_ROLES_PP like line of it_roles_pp.
DATA  wa_roles_sd like line of it_roles_sd.
DATA  wa_roles_qm like line of it_roles_qm.
DATA  wa_roles_hs like line of it_roles_hs.

DATA  status_choice.
DATA   : ist_item like table of zic_prep_rolerei.
DATA   : wa_item like line of ist_item.
DATA  status_process.
DATA  g_mult_module_fl.
DATA : STATUS_DESC like ZMM_PREP_STATUS-STATUS_DESC.
data : it_module1 like table of zic_modules.
DATA : wa_module1 like line of it_module1.
DATA  mm_not_ok.
DATA  pm_not_ok.
DATA  ps_not_ok.
DATA  hs_not_ok.
*&spwizard: type for the data of tablecontrol 'TABLCTRL112'
types: begin of t_TABLCTRL112,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         SERVICE like ZIC_PREP_ROLEREI-SERVICE,
         PROJECT like ZIC_PREP_ROLEREI-PROJECT,
         LOCATION like ZIC_PREP_ROLEREI-LOCATION,
         ASSET like ZIC_PREP_ROLEREI-ASSET,
         BASIN like ZIC_PREP_ROLEREI-BASIN,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
       end of t_TABLCTRL112.

*&spwizard: internal table for tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_itab   type t_TABLCTRL112 occurs 0,
          g_TABLCTRL112_wa     type t_TABLCTRL112. "work area
data:     g_TABLCTRL112_copied.           "copy flag
DATA:     wa_rolesz_ps type t_TABLCTRL112.

*&spwizard: declaration of tablecontrol 'TABLCTRL112' itself
controls: TABLCTRL112 type tableview using screen 0112.

*&spwizard: lines of tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_lines  like sy-loopc.
DATA:     g_curr_line_112 like sy-loopc .
** POV & checks
types :
        begin of asset_ty,
              ccode type ZIC_PREP_ROLEREQ-CCODE,
              asset type ZQM_PREP_ASSET-ASSET,
              a_desc type Zchar80,
        end of asset_ty.

types :
        begin of basin_ty,
              ccode type ZIC_PREP_ROLEREQ-CCODE,
              basin type ZIC_PREP_ROLEREI-BASIN,
              b_desc type Zchar80,
        end of basin_ty.

  DATA : it_basin type table of basin_ty with header line.
  DATA : it_asset type table of asset_ty with header line.
  DATA : it_loca  type table of zps_prep_loc with header line.
  DATA : it_location type table of zps_prep_loc with header line.
  DATA : it_project type table of zps_prep_project with header line.
  DATA : it_service type table of zps_prep_service with header line.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
types: begin of t_TABLCTRL113,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         RES like ZIC_PREP_ROLEREI-RES,
         CTF_SLOC like ZIC_PREP_ROLEREI-CTF_SLOC,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
       end of t_TABLCTRL113.

*&spwizard: internal table for tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_itab   type t_TABLCTRL113 occurs 0,
          g_TABLCTRL113_wa     type t_TABLCTRL113. "work area
data:     g_TABLCTRL113_copied.           "copy flag
DATA:     wa_rolesz_pp type t_TABLCTRL113.

*&spwizard: declaration of tablecontrol 'TABLCTRL113' itself
controls: TABLCTRL113 type tableview using screen 0113.

*&spwizard: lines of tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_lines  like sy-loopc.
DATA  g_curr_line_113 like sy-loopc.
DATA  wa_flag.
DATA  wa_flag1.
*****************
types :
   begin of res_ty,
     res like zpp_prep_res-res,
   end of res_ty.
data : it_res type table of res_ty with header line.
*****************

DATA  pp_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL114'
types: begin of t_TABLCTRL114,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         SALE_ORG like ZIC_PREP_ROLEREI-SALE_ORG,
         DIV like ZIC_PREP_ROLEREI-DIV,
         SHIP_POINT like ZIC_PREP_ROLEREI-SHIP_POINT,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
       end of t_TABLCTRL114.

*&spwizard: internal table for tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_itab   type t_TABLCTRL114 occurs 0,
          g_TABLCTRL114_wa     type t_TABLCTRL114. "work area
data:     g_TABLCTRL114_copied.           "copy flag
DATA:     wa_rolesz_sd type t_TABLCTRL114.

*&spwizard: declaration of tablecontrol 'TABLCTRL114' itself
controls: TABLCTRL114 type tableview using screen 0114.

DATA   : it_tvswz like table of tvswz with header line.
DATA   : it_tvko like table of tvko with header line.
DATA   : it_tvkos like table of tvkos with header line.

*&spwizard: lines of tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_lines  like sy-loopc.
DATA:     g_curr_line_114 like sy-loopc.

DATA  sd_not_ok.
DATA  check_plant_fl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL115'
types: begin of t_TABLCTRL115,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         ASSET_QM like ZIC_PREP_ROLEREI-ASSET_QM,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
       end of t_TABLCTRL115.

*&spwizard: internal table for tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_itab   type t_TABLCTRL115 occurs 0,
          g_TABLCTRL115_wa     type t_TABLCTRL115. "work area
data:     g_TABLCTRL115_copied.           "copy flag
DATA:     wa_rolesz_qm type t_TABLCTRL115.

*&spwizard: declaration of tablecontrol 'TABLCTRL115' itself
controls: TABLCTRL115 type tableview using screen 0115.

*&spwizard: lines of tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_lines  like sy-loopc.
DATA  g_curr_line_115 like sy-index.
DATA  qm_not_ok.
***
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.
DATA  gl_ans_save.
DATA  status_process_flag.

*&spwizard: type for the data of tablecontrol 'TABLCTRL116'
types: begin of t_TABLCTRL116,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         role_desc like zmm_prep_roledes-brief_desc,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         flag,       "flag for mark column
       end of t_TABLCTRL116.

*&spwizard: internal table for tablecontrol 'TABLCTRL116'
data:     g_TABLCTRL116_itab   type t_TABLCTRL116 occurs 0,
          g_TABLCTRL116_wa     type t_TABLCTRL116. "work area
data:     g_TABLCTRL116_copied.           "copy flag
DATA:     wa_rolesz_hs type t_TABLCTRL116.

*&spwizard: declaration of tablecontrol 'TABLCTRL116' itself
controls: TABLCTRL116 type tableview using screen 0116.

*&spwizard: lines of tablecontrol 'TABLCTRL116'
data:     g_TABLCTRL116_lines  like sy-loopc.
DATA  g_curr_line_116 like sy-index.

*Begin of <RD1K962817>.
DATA : ist_return_tab3 LIKE STANDARD TABLE OF dynpread WITH HEADER LINE.

DATA : LV_MIN_DESIG TYPE ZMIN_DESIG,
       LV_CURR_ROLE TYPE PERSK.
*End of <RD1K962817>.


**Code added by CAB_AMITMOZA   CR:30007580  WR:RD1K983325 dt:18.03.2013
*&spwizard: type for the data of tablecontrol 'TABLCTRL117'
types: begin of t_TABLCTRL117,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
*           ROLE_NAME(04) ,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         role_desc like zmm_prep_roledes-brief_desc,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         flag,       "flag for mark column
       end of t_TABLCTRL117.

*&spwizard: internal table for tablecontrol 'TABLCTRL117'
data:     g_TABLCTRL117_itab   type t_TABLCTRL117 occurs 0,
          g_TABLCTRL117_wa     type t_TABLCTRL117. "work area
data:     g_TABLCTRL117_copied.           "copy flag
DATA:     wa_rolesz_OLM type t_TABLCTRL117.

*&spwizard: declaration of tablecontrol 'TABLCTRL117' itself
controls: TABLCTRL117 type tableview using screen 0117.

*&spwizard: lines of tablecontrol 'TABLCTRL117'
data:     g_TABLCTRL117_lines  like sy-loopc.
DATA  g_curr_line_117 like sy-index.

***************************************** Added by Bipin
DATA : GT_BUCKET_EX TYPE TABLE OF ZIC_PREP_ROLEREI,
       WA_BUCKET_EX TYPE ZIC_PREP_ROLEREI.

DATA :  REQNUM_EX  TYPE ZIC_PREP_ROLEREQ-DOCNO.


DATA : GT_BUCKET TYPE TABLE OF ZIC_PREP_ROLEREI,
       WA_BUCKET TYPE ZIC_PREP_ROLEREI.

DATA : IT_TVARV TYPE TABLE OF TVARVC,
       WA_TVARV TYPE TVARVC.

DATA : LV_GRCCALL TYPE C.
DATA : LV_SUBRC TYPE SY-SUBRC.

DATA : OKCODE_EX TYPE SY-UCOMM,
      OC_9001_RJ TYPE SY-UCOMM.

DATA : GT_ICON TYPE TABLE OF ZGRC_SOD_RESULT,
       WA_ICON TYPE ZGRC_SOD_RESULT.

DATA : GT_ICON1 TYPE TABLE OF ZGRC_SOD_RESULT,
       WA_ICON1 TYPE ZGRC_SOD_RESULT.

DATA : LV_COUNT TYPE I.

TYPE-POOLS ICON.
DATA GICON(4) TYPE C.

DATA : RISK_DESC TYPE STRING.

   DATA :     CRT_NAME TYPE ZIC_PREP_ROLEREQ-USERIDCR,
        TCODE_RJ TYPE SY-TCODE,
        OKCODE_RJ TYPE SY-UCOMM.


***************************************** Added by Bipin


**Code END by CAB_AMITMOZA   CR:30007580  WR:RD1K983325


""""""""""""""""""""
*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
types: begin of t_TABLCTRL118,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         shop_no like ZIC_PREP_ROLEREI-shop_no,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex like zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
       end of t_TABLCTRL118.

*&spwizard: internal table for tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL118_itab   type t_TABLCTRL118 occurs 0,
          g_wa_pgrp TYPE T_TABLCTRL118,"work area
          g_TABLCTRL118_wa     type t_TABLCTRL118. "work area
data:     g_TABLCTRL118_copied.           "copy flag
*DATA:     wa_rolesz type t_TABLCTRL110.

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
controls: TABLCTRL118 type tableview using screen 0118.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL118_lines  like sy-loopc.
DATA  g_curr_line_118 like sy-stepl.


data:it_roles_srm TYPE STANDARD TABLE OF in_roles,
      wa_roles_srm LIKE LINE OF it_roles_srm.
DATA: l_logsys(32),
p_uname type XUBNAME.

TYPES :BEGIN OF ty_srmp,
  mandt TYPE mandt,
  userid LIKE zic_prep_rolereq-userid,
  ROLE_NAME LIKE ZIC_PREP_ROLEREI-ROLE_NAME,
  CCODE LIKE ZIC_PREP_ROLEREQ-CCODE,
  GRP LIKE ZIC_PREP_ROLEREI-GRP,
  FROM_DAT TYPE sy-datum,
  TO_DAT   TYPE sy-datum,
  END OF ty_srmp.


  TYPES:BEGIN OF ty_return,
    MANDT TYPE mandt,
UNAME TYPE persno,
GRP TYPE ZIC_PREP_ROLEREI-GRP,
ROLE_NAME type ZIC_PREP_ROLEREI-ROLE_NAME,
STATUS TYPE char2,
END OF ty_return.

  data:it_roles_srmp TYPE TABLE OF ty_srmp,
      wa_roles_srmp LIKE LINE OF it_roles_srmp,
      WA_ZBCUSRMST TYPE ZBCUSRMST,
      p_fname TYPE ZBCUSRMST-FIRST_NAME,
      p_lname TYPE ZBCUSRMST-LAST_NAME,
      p_ccode TYPE bukrs.
data:g_line_srm(120).
data:grp_flag_srm.

data:itab_return TYPE TABLE OF ty_return,
     wa_return LIKE LINE OF  itab_return,
     v_srm_st TYPE C,
     l_flag_msg type c,
       V_APP TYPE c,
     p_grp  TYPE ZCHAR03,
     p_role TYPE ZIC_PREP_ROLEREI-ROLE_NAME,
     v_exist TYPE char1,
    v_rolereq-DOCNO type  ZAUTH_HEAD-AUTH_REQ_NO ,
    p_uname_sms TYPE persno,
    G_USERID_n TYPE persno,
    v_message_srm TYPE char120,
    count_grp(4) TYPE n,
    g_user_l2(2).

""""""""""""""""""""""""

*--- INCLUDE: OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF ---*
*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section


*--- INCLUDE: OSQL_DYNAMIC_EXTERNAL_ENTITIESCI ---*
  private section.
    class-data: s_dynamic_entities type dynamic_entities.

*--- INCLUDE: OSQL_DYNAMIC_EXTERNAL_ENTITIESCO ---*
  protected section.

*--- INCLUDE: OSQL_DYNAMIC_EXTERNAL_ENTITIESCU ---*
class osql_dynamic_external_entities definition
  public
  final
  create private .

  public section.
     types: begin of dynamic_entity,
               client type mandt,
               name type dd_cds_entity_name,
               logical_schema type dd_les_name,
               db_name type dbviewname,
               db_name_terminator type C length 1,
               db_name_len type i,
            end of dynamic_entity,
            dynamic_entities type standard table of dynamic_entity with empty key without further secondary keys.
    class-methods: check_and_create,
                   test.
