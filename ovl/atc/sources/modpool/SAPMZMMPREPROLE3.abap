*--- MAIN PROGRAM: SAPMZMMPREPROLE3 ---*

*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMPREPROLE                                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*                                                                     *
* Title      : End User Authorisation - Request management             *
*                                                                     *
* FS No.     : FS-MM-AUTH-004                                         *
*                                                                     *
* Author     : Ajit Singh             Date : 30/11/2005               *
*                                                                     *
* Login Id   : CAB_AJIT                                               *
*                                                                     *
* Description: End User Authorisation - Request management             *
*                                                                     *
* Tran. Code :                                                        *
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*1) Change in INCLUDE MZMMPREPROLE3F01.
*2) Change in INCLUDE MZMMPREPROLE3TOP.
************************************************************************

INCLUDE MZMMPREPROLE3TOP.

INCLUDE MZMMPREPROLE3O01.
.
INCLUDE MZMMPREPROLE3I01.
.
INCLUDE MZMMPREPROLE3F01.
.

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
      concatenate zmm_prep_rolereq-docno ' -ARMS-MM-' into seltab-low.
      append seltab to ist_seltab.

      clear zrolereqno.

      set parameter id 'ZROLEREQNO' field ZROLEREQNO.

      submit ZHELPROLE1A WITH SELECTION-TABLE ist_seltab and return.

      get parameter id 'ZROLEREQNO' field ZROLEREQNO.

      if not ZROLEREQNO is initial and ZROLEREQNO <> '00000000'.
        submit ZBC_ROLE_REP01_RFC and return.

        g_role_flag = 'X'.
        zmm_prep_rolereq-status = 'IC'.
        perform save_request.
        if zmm_prep_rolereq-status = 'IF' or
         zmm_prep_rolereq-status = 'N'.
        else.
          perform send_sapmail.
        endif.
        perform clear.
        refresh object_content.
      endif.

      call transaction 'ZMM_AUTH_CORETEAM' and skip first screen.



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

*--- INCLUDE: MZMMPREPROLE3F01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM Ws_Download Replaced With 'GUI_DOWNLOAD'.
*2) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.

************************************************************************

*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEF01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  bac_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bac_confirm.

  Data l_choice.
  clear l_choice.
  IF g_mode <> 'DIS'.
" Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'BACK'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.

    DATA : l_get(1) TYPE C.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
       TITLEBAR                    = 'BACK '
        TEXT_QUESTION               = 'Data will be lost, Want to quit? '
       DISPLAY_CANCEL_BUTTON       = ' '
       START_COLUMN                = 25
       START_ROW                   = 6
     IMPORTING
       ANSWER                      = l_get
     EXCEPTIONS
       TEXT_NOT_FOUND              = 1
       OTHERS                      = 2
              .
   IF SY-SUBRC = 0.
       CASE l_get.
         WHEN '1'.
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.

" End of <RD1K960036>.

    If l_choice = 'J'.
*       perform clear_var.
      clear l_choice.
    endif.
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
  if   old_ok_code = 'DISPLAY' .
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_CR' to wa_tab-fcode.
    append wa_tab to it_tab.
  endif.
  if   old_ok_code = 'DELETE' .
    move 'ROLE_CR' to wa_tab-fcode.
    append wa_tab to it_tab.
  endif.
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

  data : l_docno like zmm_prep_rolereq-docno.

  CALL FUNCTION 'ENQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = zmm_prep_rolereq-docno
       EXCEPTIONS
            FOREIGN_LOCK          = 1
            SYSTEM_FAILURE        = 2
            OTHERS                = 3.

  IF SY-SUBRC <> 0.
    clear g_lock.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    MOVE 'Y' to g_lock.
  ENDIF.

ENDFORM.                    " lock_reqhd
*&---------------------------------------------------------------------*
*&      Form  get_correspondense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_correspondense.

  DATA : l_cors like THEAD-TDNAME.

  IF old_ok_code <> 'CREATE' or
      old_ok_code <> 'CROSSCO'.

    refresh lines_cors.

    move zmm_prep_rolereq-docno to l_cors.

    CALL FUNCTION 'READ_TEXT'
         EXPORTING
              CLIENT                  = SY-MANDT
              ID                      = '0001'
              LANGUAGE                = SY-LANGU
              NAME                    = l_cors
              OBJECT                  = 'ZHELP'
         TABLES
              LINES                   = lines_cors
         EXCEPTIONS
              ID                      = 1
              LANGUAGE                = 2
              NAME                    = 3
              NOT_FOUND               = 4
              OBJECT                  = 5
              REFERENCE_CHECK         = 6
              WRONG_ACCESS_TO_ARCHIVE = 7
              OTHERS                  = 8.

    IF SY-SUBRC <> 0.
      read_flag = ''.
      zmm_prep_rolereq-long_text_fl = ''.
    Else.
      read_flag = 'X'.
      zmm_prep_rolereq-long_text_fl = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_correspondense

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
* execute general and TC specific operations                           *
  CASE L_OK.
    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
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
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

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
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* get looplines of TableControl
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

* get current line
  GET CURSOR LINE L_SELLINE.
  if sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line                           *
    if l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    else.
      <tc>-top_line = 1.
    endif.
  else.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  endif.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.
* insert initial line
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
* set cursor
  SET CURSOR LINE L_LINE.

  g_i = L_LINE.
  g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* delete marked lines                                                  *
  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    IF <MARK_FIELD> = 'X' and <WA>+90(1) = ''.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
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
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                      P_OK.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <LINES>      TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
* get looplines of TableControl
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


* is no line filled?                                                   *
  IF <TC>-LINES = 0.
*   yes, ...                                                           *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              ENTRY_ACT             = <TC>-TOP_LINE
              ENTRY_FROM            = 1
              ENTRY_TO              = <TC>-LINES
              LAST_PAGE_FULL        = 'X'
              LOOPS                 = <LINES>
              OK_CODE               = P_OK
              OVERLAPPING           = 'X'
         IMPORTING
              ENTRY_NEW             = L_TC_NEW_TOP_LINE
         EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              OTHERS                = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
*     set actual column                                                *
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
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
FORM HELP_LIST.

  if ZMM_PREP_ROLEREQ-CCODE is initial.
    set cursor field 'ZMM_PREP_ROLEREQ-CCODE'.
    message i082(zhelp).
    leave to screen 0.
  endif.
  refresh : it_cond.
  concatenate 'FICTR'  'LIKE'  into g_line separated by
  space.
  concatenate g_line+0(10) '''' ZMM_PREP_ROLEREQ-CCODE '%' ''''  into
              g_line.
  append g_line to it_cond.
  if help_list_flag <> 'X' .
    select * from m_fistb into corresponding fields of table it_m_fistb
                  where (it_cond).
    SORT IT_M_FISTB BY BEZEICH SPRAS1 BOSSID FIKRS FICTR. help_list_flag = 'X'.
    refresh it_cond.
  endif.
  loop at it_m_fistb into wa_m_fistb.
*
    if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc or
       wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc2 or
       wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc3 or
       wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc4.
      wa_m_fistb-g_mark = 'X'.
    endif.

    write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
          wa_m_fistb-bezeich.
    HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*    CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr.
  endloop.
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

  MOVE 'REQ1' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'SELALL' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'DESELALL' to WA_TAB.
  APPEND WA_TAB to TAB.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
           COLOR COL_HEADING.
  ULINE.


  if flag_s_fundc = 'X'.
*    refresh : s_fundc.
    loop at it_m_fistb into wa_m_fistb.
*
      wa_m_fistb-g_mark = 'X'.
      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      modify  it_m_fistb from wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    endloop.

    lines = sy-linno .

  endif.


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

  MOVE 'REQ1' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'SELALL' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'DESELALL' to WA_TAB.
  APPEND WA_TAB to TAB.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
         COLOR COL_HEADING.
  ULINE.


  if flag_s_fundc = 'X'.
*    refresh : s_fundc.
    loop at it_m_fistb into wa_m_fistb.
*
      wa_m_fistb-g_mark = ''.
      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      modify  it_m_fistb from wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    endloop.

    lines = sy-linno .

  endif.

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

  MOVE 'REQ1' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'SELALL' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'DESELALL' to WA_TAB.
  APPEND WA_TAB to TAB.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
         COLOR COL_HEADING.
  ULINE.


  if flag_s_fundc = 'X'.
*    refresh : s_fundc.
    loop at it_m_fistb into wa_m_fistb.

      lines_index = sy-tabix + 4.

      READ LINE lines_index FIELD VALUE wa_m_fistb-g_mark.

      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.


      if wa_m_fistb-g_mark <> 'X'.

        if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc.
          ZMM_PREP_ROLEREQ-fundc = 'X'.
        endif.

        if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc2.
          clear ZMM_PREP_ROLEREQ-fundc2.
        endif.

        if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc3.
          clear ZMM_PREP_ROLEREQ-fundc3.
        endif.

        if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc4.
          clear ZMM_PREP_ROLEREQ-fundc4.
        endif.

      endif.

      modify  it_m_fistb from wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    endloop.

    help_list_flag = 'X'.

    lines = sy-linno .

    read table it_m_fistb into wa_m_fistb with key g_mark = 'X'.

    if sy-subrc = 0.

      ZMM_PREP_ROLEREQ-FUNDC = wa_m_fistb-FICTR.

    else.

      clear ZMM_PREP_ROLEREQ-FUNDC.

    endif.

  endif.



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

  perform validations1.

ENDFORM.                    " check_items
*&---------------------------------------------------------------------*
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM Save_request.

  if old_ok_code = 'CREATE'.

    perform gen_no.

  endif.

  perform insert_header.

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
            NR_RANGE_NR = '01'
            OBJECT      = 'ZDOCNUMB'
       IMPORTING
            NUMBER      = ZDOCNUMB.
  IF SY-SUBRC <> 0.
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

  ZMM_PREP_ROLEREQ-mandt = sy-mandt.
  if old_ok_code = 'CREATE'.
    ZMM_PREP_ROLEREQ-docno = ZDOCNUMB.
  endif.

  if ZMM_PREP_ROLEREQ-USERIDCR is initial.

    ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
    ZMM_PREP_ROLEREQ-CR_DATE  = sy-datum.

*      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
*      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.
    if sy-tcode <> 'ZPREPTEST3'.

      clear zusrmst.

      select single * from zusrmst where cpfno =
                                  ZMM_PREP_ROLEREQ-useridcr.
      if sy-subrc ne 0.

      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-NAMECR = zusrmst-last_name.
      endif.

    endif.

*
*        select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
*             a~persk a~sbmod  c~designo c~r_p_cd c~version
*           d~sdesig_text as designation d~adesig_text as adesignation
*             into corresponding fields of table ist_data
*        from ( ( pa0001 as a inner join pa9930 as c
*              on a~pernr = c~pernr ) inner join zdesignation_rev as d
*                 on c~designo = d~desig_code and
*                     c~r_p_cd  = d~r_p_cd and
*                     c~version = d~version )
*                  where a~pernr = ZMM_PREP_ROLEREQ-USERIDCR and
*                        a~sprps = ' ' and
*                        a~endda = '99991231' and
*                        c~sprps = ' ' and
*                        c~endda = '99991231' .
*
*        if sy-subrc = 0.
*            read table ist_data index 1.
*            ZMM_PREP_ROLEREQ-NAMECR = ist_data-name.
*            ZMM_PREP_ROLEREQ-DESIGCR = ist_data-designation.
*        endif.

  endif.

*       clear : ist_data.
*       refresh : ist_data.


  if ZMM_PREP_ROLEREQ-USERIDAP is initial.

    if old_ok_code = 'APPROVE' and ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

      clear zusrmst.

      select single * from zusrmst where cpfno =
                            ZMM_PREP_ROLEREQ-useridap.
      if sy-subrc ne 0.

      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-NAMEAPP = zusrmst-last_name.
      endif.
    endif.

  else.

    if old_ok_code = 'APPROVE' and
          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' and
                ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

      select single * from zusrmst where cpfno =
                              ZMM_PREP_ROLEREQ-userid.
      if sy-subrc ne 0.
        message e043(zhelp).
      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-NAMEAPP = zusrmst-last_name.
      endif.

    endif.

  endif.

*****************************
  data l_fundc_no like sy-index.
  clear l_fundc_no.
  loop at it_m_fistb into wa_m_fistb.
    if wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      case l_fundc_no.
        when 2.
          ZMM_PREP_ROLEREQ-fundc2 = wa_m_fistb-fictr.
        when 3.
          ZMM_PREP_ROLEREQ-fundc3 = wa_m_fistb-fictr.
        when 4.
          ZMM_PREP_ROLEREQ-fundc4 = wa_m_fistb-fictr.
        when 5.
          message i078(zhelp).
          okcode_100 = 'MULTI'.
          g_fundc_err_flag = 'X'.
      endcase.
    endif.
  endloop.
*****************************

  if ZMM_PREP_ROLEREQ-status <> 'C'.

    ZMM_PREP_ROLEREQ-status = 'IF'.

  endif.


*****
  if g_fundc_err_flag <> 'X'.

    if corr_code = 'CORR' and sy-tcode = 'ZMM_AUTH_CORETEAM'.
      clear : corr_code.
      perform confirm_process.
      if status_process = 'J'.
         clear status_process.
      else.
          if ZMM_PREP_ROLEREQ-comm_fl = 'X'.
            ZMM_PREP_ROLEREQ-STATUS = 'IR'.
          else.
            perform confirm_status.
            if status_choice = 'J'.
              clear status_choice.
              ZMM_PREP_ROLEREQ-status = 'IC'.
            else.
              ZMM_PREP_ROLEREQ-comm_fl = 'X'.
              ZMM_PREP_ROLEREQ-STATUS = 'IR'.
            endif.
           endif.
      perform send_sapmail.
      refresh object_content.
      clear corr_code.
    endif.
 endif.

*************************************************************

    if corr_code = 'CORR' and ZMM_PREP_ROLEREQ-comm_fl = ''.
      ZMM_PREP_ROLEREQ-status = 'IC'.
    endif.

    if corr_code = 'CORR' and ZMM_PREP_ROLEREQ-comm_fl = 'X'.
      ZMM_PREP_ROLEREQ-status = 'IR'.
    endif.

*     modify ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

    Perform insert_items.

*     if sy-subrc = 0 and ZMM_PREP_ROLEREQ-status <> 'C'.

    if sy-subrc = 0 and ( ZMM_PREP_ROLEREQ-status <> 'IC'
                          and ZMM_PREP_ROLEREQ-status <> 'IR' ).

      loop at ist_itemtab into wa_itemtab.
        if wa_itemtab-rej_fl = ''.
          if wa_itemtab-status = '' and
              wa_itemtab-role_request = ''.
            g_request_close_flag_P  = 'X'.
          elseif wa_itemtab-status = 'H'.
            g_request_close_flag_H = 'X'.
          elseif  wa_itemtab-role_request <> ''.
            g_request_close_flag_R = 'X'.
          endif.
        endif.
      endloop.

      if ( g_request_close_flag_P  = 'X' or
         g_request_close_flag_H  = 'X' ) and
         g_request_close_flag_R = 'X'.
        ZMM_PREP_ROLEREQ-status = 'PC'.
      elseif g_request_close_flag_P  <> 'X' and
         g_request_close_flag_H  = 'X' and
         g_request_close_flag_R = 'X'.
        ZMM_PREP_ROLEREQ-status = 'PC'.
      elseif g_request_close_flag_P  = '' and
         g_request_close_flag_H  = '' and
         g_request_close_flag_R = 'X'.
        ZMM_PREP_ROLEREQ-status = 'C'.
      elseif g_request_close_flag_P  = 'X' and
         g_request_close_flag_H  <> 'X' and
         g_request_close_flag_R <> 'X'.
        ZMM_PREP_ROLEREQ-status = 'IF'.
      elseif  g_request_close_flag_P = '' and
               g_request_close_flag_H = '' and
                 g_request_close_flag_R <> ''.
        ZMM_PREP_ROLEREQ-status = 'C'.
      endif.


    endif.

    modify ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

    clear : g_request_close_flag_P, g_request_close_flag_H,
            g_request_close_flag_R.

****Saving the long text.                              *****

    IF ( old_ok_code = 'CREATE' ) or ( OLD_OK_CODE = 'CHANGE' )
        or ( OLD_OK_CODE = 'RELEASE' )
        or ( OLD_OK_CODE = 'APPROVE' ).
      perform save_cors_text.
    ENDIF.

    if g_role_flag = 'X'.
      clear g_role_flag.
      perform unlock_record.

    else.
*           perform clear.
*           perform unlock_record.
*           call screen 100.
      if l_old_ok_code = 'X'.
        SET PARAMETER ID 'ZOLDCODE' field l_initial.
        leave program.
      else.
        perform clear.
        perform unlock_record.
        call screen 100.
      endif.

    endif.

*     endif.
*****
  else.

    clear g_fundc_err_flag.
    call screen 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    clear okcode_100.

  endif.

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

  DATA  : i like sy-index .
  Clear : wa_itemtab, ist_itemtab.

  sort g_TABCTRL100_itab
  by role_name plant grp  sloc receipt_loc approver.

  delete adjacent duplicates from g_TABCTRL100_itab
    comparing role_name plant grp  sloc receipt_loc approver.

  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

    move-corresponding g_TABCTRL100_wa to wa_itemtab.

    if g_role_flag = 'X' and wa_itemtab-rej_fl = '' and
        wa_itemtab-status = '' and wa_itemtab-role_request = ''.
      wa_itemtab-role_request = ZROLEREQNO.
    endif.

    if old_ok_code = 'CREATE'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.


    wa_itemtab-mandt = sy-mandt.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

    Perform check_items_save.

  endloop.

  if g_lines_rl = 0.
    if old_ok_code = 'CHANGE'.
      delete from ZMM_PREP_ROLEREQ
            where docno = ZMM_PREP_ROLEREQ-docno.
      delete from ZMM_PREP_ROLEREI
            where docno = ZMM_PREP_ROLEREQ-docno.
      if sy-subrc = 0.
        set cursor field 'ZMM_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZMM_PREP_ROLEREQ-docno.
      endif.
    else.
      rollback work.
    endif.
  else.

    delete from ZMM_PREP_ROLEREI where docno = wa_itemtab-docno.

    modify ZMM_PREP_ROLEREI from table ist_itemtab.

    if sy-subrc = 0 and g_role_flag <> 'X'.
      message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
    endif.

  endif.

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

  Data l_choice1.
  clear l_choice1.

  if old_ok_code = 'CREATE' or
     old_ok_code = 'CHANGE' or
     old_ok_code = 'DELETE' or
     old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.
" Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'EXIT'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice1.

DATA : L_GET1(1) TYPE C.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'EXIT '
    TEXT_QUESTION               = 'Data will be lost, Want to quit? '
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = L_GET1
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE L_GET1.
         WHEN '1'.
           MOVE 'J' TO l_choice1.
           WHEN '2'.
             MOVE 'N' TO l_choice1.
             ENDCASE.
             ENDIF.

" End of <RD1K960036>.
    If l_choice1 = 'J'.
      clear l_choice1.
      perform clear.
      perform unlock_record.
      if l_old_ok_code = 'X'.
*              data : l_initial.
        SET PARAMETER ID 'ZOLDCODE' field l_initial.
        leave program.
      else.
        call screen 100.
      endif.
    else.
    ENDIF.

  else.

    if l_old_ok_code = 'X' and old_ok_code = 'DISPLAY'.
      SET PARAMETER ID 'ZOLDCODE' field l_initial.
      leave program.
    else.

      if sy-tcode = 'ZPREPTEST3'.
        leave program.
      else.
        perform clear.
        perform unlock_record.
        call screen 100.
      endif.

    endif.

  endif.


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

  perform clear.

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

  data : l_del_docno like zmm_prep_rolereq-docno.

  CALL FUNCTION 'DEQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = zmm_prep_rolereq-docno.

  if sy-subrc = 0.
    clear g_lock.
  endif.

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

  perform destroy_ctrl.

  clear   : old_ok_code, okcode_100, err_flg.
  refresh : g_TABCTRL100_itab.
  clear   : g_TABCTRL100_itab.
  clear   : sy-ucomm.
  clear   : zmm_prep_rolerei, zmm_prep_rolereq.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].


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

  call method gv_text_editor1->set_readonly_mode
             exporting
                  readonly_mode = gv_text_editor1->true
             exceptions
                  error_cntl_call_method = 1
                  invalid_parameter      = 2
                  others                 = 3.

  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
 or ( old_ok_code = 'RELEASE' )
 or ( OLD_OK_CODE = 'APPROVE' ).

    call method gv_text_editor2->set_readonly_mode
         exporting
              readonly_mode = gv_text_editor2->false
         exceptions
              error_cntl_call_method = 1
              invalid_parameter      = 2
              others                 = 3.

  endif.

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

  Refresh: tlinetab1, g_linefrto_itab.
  If old_ok_code <> 'CREATE'.
    append lines of lines_cors to tlinetab1[].
  Endif.
*
  loop at tlinetab1[] into g_line132.
    if ( g_line132+0(7) = '* Reply' ) or
       ( g_line132+0(7) = '**Reply' ).
      g_linefrto-line_fr = sy-tabix.
      g_linefrto-line_to = sy-tabix.
      append g_linefrto to g_linefrto_itab.
      clear: g_linefrto.
    endif.
  endloop.
*
  call function 'CONVERT_ITF_TO_STREAM_TEXT'
       TABLES
            itf_text    = tlinetab1[]
            text_stream = lt_text_table1.

  call method gv_text_editor1->set_text_as_stream
       exporting
            text = lt_text_table1
       exceptions
            error_dp        = 1
            error_dp_create = 2
            others          = 3.
********************highlight**************************************
  clear g_linefrto.
  loop at g_linefrto_itab into g_linefrto.
    call method gv_text_editor1->HIGHLIGHT_LINES
       exporting
            FROM_LINE = g_linefrto-line_fr
            TO_LINE   = g_linefrto-line_to
            HIGHLIGHT_MODE = 1.
  endloop.
********************************************************************

  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' ).

    call function 'CONVERT_ITF_TO_STREAM_TEXT'
         TABLES
              itf_text    = tlinetab2
              text_stream = lt_text_table2.

    call method gv_text_editor2->set_text_as_stream
         exporting
              text = lt_text_table2
         exceptions
              error_dp        = 1
              error_dp_create = 2
              others          = 3.
  endif.

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

  Data: l_theader like thead.
  Data: l_datech(10) type c.
***********Assignments***********************
  Clear l_theader.
  l_theader-tdobject   = 'ZHELP'.
  l_theader-tdid       = '0001'.
  l_theader-tdspras    =  sy-langu.
  l_theader-tdlinesize =  72.
  move zmm_prep_rolereq-docno to l_theader-tdname.
  Append lines of TLINETAB2 to TLINETAB1.
*********************************************
  IF NOT TLINETAB1[] IS INITIAL.
    clear g_cores_sender.
    Concatenate sy-datum+6(2) '/'
                sy-datum+4(2) '/'
                sy-datum+0(4) into l_datech.
    Concatenate '**Reply' l_datech sy-uname into g_cores_sender
     separated by '          '.
    if NOT TLINETAB2[] IS INITIAL.
      append g_cores_sender to tlinetab1.
    endif.
    clear g_cores_sender.
    CALL FUNCTION 'SAVE_TEXT'
         EXPORTING
              CLIENT          = SY-MANDT
              HEADER          = l_theader
              SAVEMODE_DIRECT = 'X'
         TABLES
              LINES           = TLINETAB1
         EXCEPTIONS
              ID              = 1
              LANGUAGE        = 2
              NAME            = 3
              OBJECT          = 4
              OTHERS          = 5.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

  clear g_user.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'L1'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'DI'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'CS'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'MD'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'IM'.

  if sy-subrc = 0.
    g_user = 'IM'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'FRGCO' FIELD : 'L2'.
  if sy-subrc = 0.
    g_user = 'L3'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L3'.
  if sy-subrc = 0.
    g_user = 'L3'.
    check 1 = 2.
  Endif.

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

  if sy-tcode <> 'ZMM_AUTH_CORETEAM'.

    if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.

      if  ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
      else.
        message e046(zhelp).
      endif.

    endif.

    if old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.
      perform verify.
*          message e055(zhelp).
    endif.

  else.

    if ( old_ok_code = 'CHANGE' or old_ok_code = 'DELETE' ) and
                            ( ZMM_PREP_ROLEREQ-STATUS = 'IC' or
                              ZMM_PREP_ROLEREQ-STATUS = 'IR' ).
*           message e072(zhelp).

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
             EXPORTING
              TEXTLINE1   = 'Can''t cahnge / delete this document it is with creator'.

      SET PARAMETER ID 'ZOLDCODE' field l_initial.
      old_ok_code = 'DISPLAY'.
      call screen 100.

    endif.

    if ZMM_PREP_ROLEREQ-status  = 'C'
       and old_ok_code <> 'DISPLAY'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
         EXPORTING
              TEXTLINE1   = 'Request can not be changed Can only be displayed'.

*              message e079(zhelp).
*               perform clear.
      SET PARAMETER ID 'ZOLDCODE' field l_initial.
      old_ok_code = 'DISPLAY'.
*                 call screen 100.

    endif.


  endif.

  if old_ok_code = 'APPROVE' and
                    ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    if g_user = 'IM' or g_user = 'L1'.
    else.
      message e048(zhelp).
    endif.
  endif.

  if old_ok_code = 'RELEASE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    message e053(zhelp).
  endif.

  if old_ok_code = 'APPROVE'.

    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      message e051(zhelp).
    endif.

    if ( g_user = 'IM' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP0_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      message e051(zhelp)..
    endif.

    if ( g_user = 'L3' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      message e051(zhelp)..
    endif.

    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.
      message e049(zhelp).
    endif.

    if ( g_user = 'IM' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
      message e050(zhelp)..
    endif.

    if ( g_user = 'L3' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      message e050(zhelp)..
    endif.

  endif.

  if old_ok_code <> 'DISPLAY' and
       ( ZMM_PREP_ROLEREQ-REQ_APP_FL <> 'X' and
       ZMM_PREP_ROLEREQ-REQ_APP0_FL <> 'X' and
       ZMM_PREP_ROLEREQ-REQ_APP1_FL <> 'X' ).
    message i080(zhelp).
    g_reset_change = 'X'.
    SET PARAMETER ID 'ZOLDCODE' FIELD ''.
    old_ok_code = 'DISPLAY'.
    perform change_status.
endif.

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

  if ZMM_PREP_ROLEREI-rej_fl = ''.


    if old_ok_code = 'APPROVE' and
                      ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
      if g_user = 'IM' or g_user = 'L1'.
      else.
        message e048(zhelp).
      endif.
    endif.

    if old_ok_code = 'APPROVE' and g_user = 'L1' and
                 ZMM_PREP_ROLEREQ-REQ_APP_FL <> 'X'.
      ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.

    endif.

  endif.

ENDFORM.                    " validations1


*---------------------------------------------------------------------*
*       FORM destroy_ctrl                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM destroy_ctrl.

  if not flag2 is initial.
    clear : flag2, flag1.
    call method gv_text_editor1->free.
    call method gv_text_editor2->free.
  endif.

  if not flag1 is initial.
    clear flag1.
    call method gv_text_editor1->free.
  endif.

  clear:gv_text_editor1,gv_text_editor2.

  perform unlock_record.

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

  ZMM_PREP_ROLEREQ-mandt = sy-mandt.

  delete ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

  if sy-subrc = 0.

    Perform delete_items.


    if zmm_prep_rolereq-long_text_fl <> ''.
      perform delete_cors_text.
    endif.

    perform clear.
    perform unlock_record.
    call screen 100.

  else.

    message i057(zhelp) with ZMM_PREP_ROLEREQ-docno.

  endif.


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

  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

    move-corresponding g_TABCTRL100_wa to wa_itemtab.
    wa_itemtab-mandt = sy-mandt.
    append wa_itemtab to ist_itemtab.

  endloop.

  delete ZMM_PREP_ROLEREI from table ist_itemtab.

  if sy-subrc = 0.
    message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
  endif.

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

  data : l_name like thead-tdname.

  l_name = zmm_prep_rolereq-docno.

  CALL FUNCTION 'DELETE_TEXT'
    EXPORTING
      CLIENT                = SY-MANDT
      ID                    = '0001'
      LANGUAGE              = sy-langu
      NAME                  = l_name
      OBJECT                = 'ZHELP'
*     SAVEMODE_DIRECT       = ' '
*     TEXTMEMORY_ONLY       = ' '
*     LOCAL_CAT             = ' '
   EXCEPTIONS
     NOT_FOUND             = 1
     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

  Data l_choice.
  clear l_choice.

" Begin of <RD1K960036>.

*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be reset? '
*            TITEL          = 'RESET'
*            START_COLUMN   = 25
*            START_ROW      = 6
*            CANCEL_DISPLAY = ''
*       IMPORTING
*            ANSWER         = l_choice.

DATA : L_GET5(1) TYPE C.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'RESET '
    TEXT_QUESTION               = 'Request already released Flags will be reset? '
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = L_GET5
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE L_GET5.
         WHEN '1'.
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
  If l_choice = 'J'.
    clear zmm_prep_rolereq-req_cr_fl.
    clear zmm_prep_rolereq-req_app_fl.
    clear zmm_prep_rolereq-req_app1_fl.
    perform save_request.
    clear l_choice.
  endif.

ENDFORM.                    " verify
*&---------------------------------------------------------------------*
*&      Form  upload1_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload1_file.

select * from zhelp_mmroles into corresponding fields of table it_roles.

ENDFORM.                    " upload1_file
*&---------------------------------------------------------------------*
*&      Form  help_suim
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM help_suim.

  select * from agr_users into table it_agr_users
                  where uname = zmm_prep_rolereq-userid .

  refresh it_role_del_data.

  sort it_agr_users descending by to_dat.

  loop at it_agr_users into wa_agr_users.
*
*    if wa_agr_users-from_dat <= sy-datum.
      write: / wa_agr_users-agr_name,
             wa_agr_users-from_dat,
             wa_agr_users-to_dat.
      wa_role_del_data-userid = wa_agr_users-uname.
      wa_role_del_data-role_name = wa_agr_users-agr_name.
      append wa_role_del_data to it_role_del_data.
      HIDE :  wa_agr_users-agr_name,
              wa_agr_users-from_dat,
              wa_agr_users-to_dat.
      CLEAR :  wa_agr_users-agr_name,
               wa_agr_users-from_dat,
               wa_agr_users-to_dat.
.
*    endif.
  endloop.
  lines = sy-linno .
  it_roles[] = it_role_del_data[].

  describe table it_role_del_data lines g_lines1.

  if g_lines1 > 0.
" Begin of <RD1K960036>.
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
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

" Begin of <RD1K960036>.
     CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = 'C:\role_upload.txt'
        FILETYPE                = 'DAT'
      TABLES
        DATA_TAB                = it_role_del_data
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.

          IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
   ENDIF.
" End of <RD1K960036>.


    clear disp_flag.
    message i059(zhelp).
    clear old_ok_code.




ENDFORM.                    " help_suim
*&---------------------------------------------------------------------*
*&      Form  hide
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hide.

  move 'REQ1' to wa_TAB.
  append wa_tab to tab.

ENDFORM.                    " hide
*&---------------------------------------------------------------------*
*&      Form  confirm_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_mail.
" Begin of <RD1K960036>.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            TEXTLINE1 = text-008
*            TITEL     = text-009
*       IMPORTING
*            ANSWER    = g_ans_mail.
  DATA : L_GET3(1) TYPE C.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = text-009
      TEXT_QUESTION               = text-008
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = L_GET3
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
            .
 IF SY-SUBRC = 0.
       CASE L_GET3.
         WHEN '1'.
           MOVE 'J' TO g_ans_mail.
           WHEN '2'.
             MOVE 'N' TO g_ans_mail.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

  If g_ans_mail = 'J'.
    perform SEND_SAPMAIL.
  endif.

  clear object_content.
  refresh object_content.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM SEND_SAPMAIL                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SEND_SAPMAIL.

*--- Send mail to user

*
  document_data-obj_langu  = sy-langu.
  document_data-obj_name   = 'ICE Core Team'.
  document_data-obj_descr  = 'Mail from ICE Core Team'.
  document_data-priority   = '3'.

* Remove prefix 'US' from receiver
  refresh receivers.

  clear wa_receivers.
  wa_receivers-receiver = zmm_prep_rolereq-useridcr.
  wa_receivers-rec_type = 'B'.
  wa_receivers-express  = 'X'.
  append wa_receivers to receivers.

  clear wa_receivers.

  move space to object_content-line.
  append object_content.

  concatenate  'Subject: '  'Creation of Roles for userid '
zmm_prep_rolereq-userid into  object_content-line
separated by space.
  append object_content.

  move space to object_content-line.
  append object_content.
  if ZMM_PREP_ROLEREQ-STATUS = 'C'.
      concatenate 'Please  check  your role request  which  has  been '
&'assigned  &  completed - ' zmm_prep_rolereq-docno into
object_content-line
separated by space.
    append object_content.
  else.
      concatenate 'Please check your role request which has been updated - ' zmm_prep_rolereq-docno into  object_content-line
separated by space.
    append object_content.
  endif.
********************************************************************
  if ZMM_PREP_ROLEREQ-STATUS = 'IC'.
      Move 'Please go through correspondence in the request. The request '
 &'needs to be changed, re-released & re-approved by competent authority.'
&'Once the request is approved, the request will flow to ICE core team.'
 to object_content-line.
    append object_content.
  endif.
  if ZMM_PREP_ROLEREQ-STATUS = 'IR'.
      Move 'Please go through the correspondence in the request & reply '
&'to the query raised by ICE core team. You need to save the request after'
 &'giving reply in correspondence(In display mode only). Once the request'
&'is saved, the request will flow to ICE core team.'
 to object_content-line.
    append object_content.
     Move 'No re-release or approvals are required in this case & user'
&'will not be able to open the request in change mode.'
to object_content-line.
    append object_content.
  endif.
  if ZMM_PREP_ROLEREQ-STATUS = 'PC'.
      Move 'Your request is still under process with ICE core team. Only'
 &'partial roles have been assigned. You will get the next message for'
&'completion or return of request soon.'
to object_content-line.
    append object_content.
  endif.
********************************************************************
  move space to object_content-line.
  append object_content.

  object_content-line = 'ICE Core Team'.
  append object_content.

  call function 'SO_NEW_DOCUMENT_SEND_API1'
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

  case sy-subrc.
    when 0.

      message i060(zhelp) with zmm_prep_rolereq-useridcr.
    when '01'.
      raise too_many_receivers.
    when '02'.
      raise document_not_sent.
    when '03'.
      raise document_type_not_exist.
    when '04'.
      raise operation_no_authorization.
    when '05'.
      raise parameter_error.
    when '06'.
      raise x_error.
    when '07'.
      raise enqueue_error.
  endcase.

********************************************
********************************************
ENDFORM.                    " send_sapmail
*&---------------------------------------------------------------------*
*&      Form  create_roles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles.

  clear it_roles0.
  clear it_roles1.

  LOOP AT it_roles into WA_ROLES.

    PERFORM check_mum.
    APPEND WA_ROLES to it_roles0.

  ENDLOOP.

  ClEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles.

    if not wa_roles-role_type is initial.

      loop at g_TABCTRL100_itab into wa_rolesz.
        if  wa_roles-role_type = wa_rolesz-role_name and
                                wa_rolesz-rej_fl = '' and
                                wa_rolesz-status = '' and
                                wa_rolesz-role_request = ''.
          PERFORM insert_data.
        endif.
      endloop.

    endif.

  ENDLOOP.

  loop at g_TABCTRL100_itab into wa_rolesz.
    if wa_rolesz-role_name+0(1) = 'C' and
                            wa_rolesz-rej_fl = '' and
                            wa_rolesz-status = '' and
                            wa_rolesz-role_request = ''.
      PERFORM insert_data_addl.
    endif.
  endloop.

  sort it_roles1.

**** Deleting tempelate as it gets added in logic

  loop at it_roles1 into wa_role_del_data.

    if wa_role_del_data-role_name = 'D:MM_SRV_IND_APPROVE_XX'
     or wa_role_del_data-role_name = 'D:MM_PUR_PO_APPROVE_XX'.
      DELETE it_roles1.
    endif.
  endloop.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  loop at it_roles1 into wa_roles1.

    WRITE zmm_prep_rolereq-fr_date_auth to wa_dat1 dd/mm/yyyy.

    WRITE zmm_prep_rolereq-to_date_auth to wa_dat2 dd/mm/yyyy.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    modify it_roles1 from wa_roles1.
    clear wa_roles1.
  endloop.

  PERFORM DOWNLOAD_FILE.

  Perform copy_values.

  Perform confirm_step.

  if gl_ans = 'J'.
    Perform insert_record.
    Perform save_request.
  endif.

  perform list_processing.

  perform alv_processing.

*
  clear : flag, flag1.

ENDFORM.                    " create_roles
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
  IF zmm_prep_rolereq-ccode = 'MUM'.
    SEARCH WA_ROLES-ROLE_NAME for 'D:FM_LOGS_FFFFFFFF'.
    IF SY-SUBRC = 0.
      WA_ROLES-ROLE_NAME = 'FM_LOGS_FFFFFFFF'.
    ENDIF.
    SEARCH WA_ROLES-ROLE_NAME for 'FI_AP_LOGS_DISP_CCC'.
    IF SY-SUBRC = 0.
      WA_ROLES-ROLE_NAME = 'FI_AP_LOGS_DISP_CCC_AL'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_mum
*&---------------------------------------------------------------------*
*&      Form  insert_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data.

  SEARCH WA_ROLES-ROLE_NAME for 'INPP'.
  IF SY-SUBRC = 0.
    flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'INPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  Endif.
*
  SEARCH WA_ROLES-ROLE_NAME for 'SSPP'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
    REPLACE 'SSPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'PLANT'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'PPPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'POPP'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'POPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

*
  SEARCH WA_ROLES-ROLE_NAME for 'IGG'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
    REPLACE 'IGG' with wa_rolesz-grp INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

*
  SEARCH WA_ROLES-ROLE_NAME for 'SGG'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                        WA_ROLES1-ROLE_NAME.
    REPLACE 'SGG' with wa_rolesz-grp INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME for 'PGG'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                    WA_ROLES1-ROLE_NAME.
    REPLACE 'PGG' with wa_rolesz-grp INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'CCC'.
  IF SY-SUBRC = 0.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    if flag <> 'X'.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                    WA_ROLES1-ROLE_NAME.
*      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    FLAG = 'X'.
    if wa_roles-role_type = 'M12' or wa_roles-role_type = 'M17'.
      REPLACE 'RR' with wa_rolesz-receipt_loc+0(2) INTO
                                              WA_ROLES1-ROLE_NAME.


    endif.

    APPEND WA_ROLES1 to IT_ROLES1.

    select single * from zhelp_mmroles_rc where
                        receipt_loc = wa_rolesz-receipt_loc and
                        ccode = ZMM_PREP_ROLEREQ-ccode.
    if sy-subrc = 0.
      wa_roles1-role_name = zhelp_mmroles_rc-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.



  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'FM_LOGS'.
  IF SY-SUBRC = 0.
    flag = 'X'.

    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    if zmm_prep_rolereq-fundc1 <> '' and
          zmm_prep_rolereq-fundc_fl = 'X'.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc1 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc2 <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc2 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc3 <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc3 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc4 <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc4 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'MM_SRV_SES_ACCEPT'.
  IF SY-SUBRC = 0.
    flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'YY' with wa_rolesz-approver INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME for 'MM_PUR_PO_APPROVE_ZZ'.
  IF SY-SUBRC = 0.
    flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'ZZ' with wa_rolesz-approver INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  ENDIF.

  IF flag <> 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  ENDIF.
  CLEAR flag.

  If wa_roles-role_type = 'M13'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = zmm_prep_role_sl-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

  If wa_roles-role_type = 'M14'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = zmm_prep_role_sl-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

  If wa_roles-role_type = 'M16'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = zmm_prep_role_sl-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M11S' or
     wa_roles-role_type = 'M11M' or
     wa_roles-role_type = 'M3'   or
     wa_roles-role_type = 'M3A'  or
     wa_roles-role_type = 'M3B'  .

    SEARCH WA_ROLES-ROLE_NAME for 'XX'.
    IF SY-SUBRC = 0.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'XX' with wa_rolesz-approver INTO
                                    WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

      if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

ENDFORM.                    " insert_data
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE.
  IF NOT p1_file IS INITIAL.

* Download the file on presentation server

" Begin of <RD1K960036>.
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
*
*    IF sy-subrc <> 0.
*
*      MESSAGE i061(Zhelp) WITH text-053.
*
*      EXIT.

      CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = p1_file
        FILETYPE                = 'DAT'
      TABLES
        DATA_TAB                = it_roles1
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.

          IF SY-SUBRC <> 0.
           MESSAGE i061(Zhelp) WITH text-053.
           EXIT.
   ENDIF.
" End of <RD1K960036>.


    ENDIF.

*  ENDIF.

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

  if not zrolereqno is initial.
    ZMM_PREP_ROLEREQ-req_no = zrolereqno.
  endif.

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
" Begin of <RD1K960036>.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'Y'
*            TEXTLINE1     = 'Role request being created'
*            TEXTLINE2     = 'Continue ??? '
*            TITEL         = 'Confirm'
*       IMPORTING
*            ANSWER        = gl_ans.

DATA : L_GET4(1) TYPE C.

CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Confirm '
    TEXT_QUESTION               = 'Role request being created Continue ???'
   DEFAULT_BUTTON              = '1'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = L_GET4
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE L_GET4.
         WHEN '1'.
           MOVE 'J' TO gl_ans.
           WHEN '2'.
             MOVE 'N' TO gl_ans.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

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
*  okcode_100 = 'SAV'.
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

  if gl_ans = 'J'.
    suppress dialog.
    leave to list-processing and return to screen 100.
    PERFORM write_list.
    g_list_proc_flag = 'X'.
    clear gl_ans.
  endif.

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

  set pf-status 'STATUS_130' excluding 'SEL'.

  read table it_roles1 into wa_roles1 index 1.
  g_userid = wa_roles1-userid.
  l_color = 5.
  Loop at it_roles1 into wa_roles1.
    if g_userid = wa_roles1-userid.
      Write : / wa_roles1-userid color 1,wa_roles1-role_name color 2.
    else.
      Write : / wa_roles1-userid color 3,wa_roles1-role_name color 3.
    Endif.
    g_userid = wa_roles1-userid.
  Endloop.

ENDFORM.                    " write_list
*&---------------------------------------------------------------------*
*&      Form  change_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_status.

  Perform fill_sttab.

  if old_ok_code = 'CREATE' or old_ok_code = 'CHANGE' or
      old_ok_code = 'DISPLAY' or old_ok_code = 'DELETE'.

    SET PF-STATUS 'OPTNS1' excluding it_tab.

  else.

    SET PF-STATUS 'OPTNS'.

  endif.

  case sy-ucomm.
    when 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' with ': Create Request'.
    when 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' with ': Change Request'.
    when 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' with ': Display Request'.
    when 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' with ': Delete Request'.
    when 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' with ': Release Request'.

    when others.
      SET TITLEBAR 'PREP_TITLE' with ''.
  endcase.

ENDFORM.                    " change_status
*&---------------------------------------------------------------------*
*&      Form  check_list_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_list_processing.

  if g_list_proc_flag = 'X'.
    leave program.
  endif.

ENDFORM.                    " check_list_processing
*&---------------------------------------------------------------------*
*&      Form  scr100_attr_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM scr100_attr_check.

  CASE old_ok_code.

    when ''.

      loop at screen.
        screen-input = 0.
        modify screen.
      endloop.

    when 'CREATE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 1.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-required = 0.
          modify screen.
        endif.


      endloop.

    when 'CHANGE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.


      endloop.

    when 'RELEASE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_PREP_ROLEREQ-REQ_CR_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'APPROVE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'TABCTRL100_DELETE'.
          screen-input = 0.
          modify screen.
        endif.

      if g_user = 'L1' and screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP1_FL'
   .
          screen-input = 1.
          modify screen.
        endif.
        if ( g_user = 'IM' or g_user = 'L3' ) and
            screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'DISPLAY'.

      loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
   .
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

      endloop.

    when 'DELETE'.

      loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
   .
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

      endloop.


  ENDCASE.


ENDFORM.                    " scr100_attr_check
*&---------------------------------------------------------------------*
*&      Form  check_items_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save.
  if old_ok_code <> 'DISPLAY' .

    select single * from zmm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zmm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE') and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZMM_PREP_ROLEREI-PLANT'.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-p_grp = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE'  or
                    old_ok_code = 'CREATE') and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-grp is initial.
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-s_loc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE') and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sloc is initial.
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-r_loc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-receipt_loc is initial.
          g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
          message i095(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-app_level = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE') and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-approver is initial.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.



    endif.
  endif.
ENDFORM.                    " check_items_save
*&---------------------------------------------------------------------*
*&      Form  check_tel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_tel.
  if ( old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
         old_ok_code = 'DELETE' or old_ok_code = 'CREATE'
         or old_ok_code = 'RELEASE' or OLD_OK_CODE = 'APPROVE' )
         and g_hd_copied = 'X'.
    data : tel_len type i.
    tel_len = strlen( ZMM_PREP_ROLEREQ-TELNO ).
    if  ZMM_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
      message i097(zhelp).
      call screen 100.
    Else.
      if tel_len < 7.
        message i098(zhelp).
        call screen 100.
      Endif.
    Endif.
  endif.
ENDFORM.                    " check_tel
*&---------------------------------------------------------------------*
*&      Form  status_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM status_update.
  loop at g_TABCTRL100_itab into wa_rolesz.

    if wa_rolesz-rej_fl = '' and
       wa_rolesz-status = '' and
       wa_rolesz-role_request = ''.
      g_status_update_flag = 'X'.
    else.
      if wa_rolesz-role_request <> ''.
        g_status_update_rolereq = 'X'.
      endif.
    endif.
  endloop.
ENDFORM.                    " status_update
*&---------------------------------------------------------------------*
*&      Form  list_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files.

  g_att_files_wa-LOGSYS = ZMM_PREP_ROLEREQ-DOCNO+2(10).
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      APPLICATION_OBJECT       = g_att_files_wa
*   FUNCTION                 = ' '
* TABLES
*   FUNC_EXCLUDE             =
  .
ENDFORM.                    " list_files
*&---------------------------------------------------------------------*
*&      Form  attach_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_files.

  clear g_att_files_wa.
  refresh g_att_files.

  g_att_files_wa-LOGSYS = ZMM_PREP_ROLEREQ-DOCNO+2(10).
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  append g_att_files_wa to g_att_files.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
       EXPORTING
            ATTACHMENT_DATA     = ''
            ATTACHMENT_TYPE     = 'DOC'
       TABLES
            APPLICATION_OBJECTS = g_att_files.
ENDFORM.                    " attach_files
*&---------------------------------------------------------------------*
*&      Form  auth_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check.
  select single * from zmm_prep_usrcont where
             bname = sy-uname.
  if sy-subrc <> 0.
    message i104(zhelp).
    old_ok_code = 'DISPLAY'.
  else.
    perform auth_check1.
*   old_ok_code = 'CHANGE'.
  endif.

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

  if zmm_prep_rolereq-crc_fl = 'X' and
     zmm_prep_usrcont-crc_app = 'X'.
*     old_ok_code = 'CHANGE'.
  elseif
     zmm_prep_rolereq-crossco_fl = 'X' and
     zmm_prep_usrcont-crossco_app = 'X'.
*     old_ok_code = 'CHANGE'.
  else.
    if  zmm_prep_usrcont-gen_app = 'X' and
        zmm_prep_rolereq-crc_fl <> 'X' and
          zmm_prep_rolereq-crossco_fl <> 'X' .
*         old_ok_code = 'CHANGE'.
    else.
      message i104(zhelp).
      old_ok_code = 'DISPLAY'.
    endif.
  endif.


ENDFORM.                    " auth_check1
*&---------------------------------------------------------------------*
*&      Form  confirm_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_process.
" Begin of <RD1K960036>.
* CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to process request after saving? '
*              TITEL          = ''
*              DEFAULTOPTION  = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = status_process.

  DATA : L_GET2(1) TYPE C.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION               = 'Do you want to process request after saving? '
     DEFAULT_BUTTON              = ' '
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = L_GET2
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
            .
  IF SY-SUBRC = 0.
       CASE L_GET2.
         WHEN '1'.
           MOVE 'J' TO status_process.
           WHEN '2'.
             MOVE 'N' TO status_process.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

ENDFORM.                    " confirm_process
*&---------------------------------------------------------------------*
*&      Form  confirm_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_status.
" Begin of <RD1K960036>.
*CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Press "Yes" if you want to change the status of request to "IC". '
*              TEXTLINE2      = 'Press "No" to change the status of request to "IR". '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = status_choice.

  data : l_answer(1) TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = ' '
      TEXT_QUESTION               = 'Press "Yes" if you want to change the status of request to "IC".'
                                    &' Press "No" to change the status of request to "IR".'
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = l_answer
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
            .

  IF SY-SUBRC = 0.
       CASE L_ANSWER.
         WHEN '1'.
           MOVE 'J' TO status_choice.
           WHEN '2'.
             MOVE 'N' TO status_choice.
             ENDCASE.
             ENDIF.
"End of <RD1K960036>.
ENDFORM.                    " confirm_status
*&---------------------------------------------------------------------*
*&      Form  alv_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_processing.

ENDFORM.                    " alv_processing
*&---------------------------------------------------------------------*
*&      Form  insert_data_addl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_addl.
      clear wa_roles1.
      refresh it_roles1_addl.
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE
 ROLE_TYPE = WA_ROLESZ-ROLE_NAME AND ROLE_TYPE_EX = WA_ROLESZ-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        if ZMM_PREP_CRCDESG-crc_level_addl <> ''.
          wa_rolesz-approver = ZMM_PREP_CRCDESG-crc_level_addl.
        else.
          wa_rolesz-approver = ZMM_PREP_CRCDESG-crc_level.
        endif.
      if ZMM_PREP_CRCDESG-crc_level = 'L1'.
        select * from zhelp_mmroles into corresponding fields of table
               it_roles1_addl where role_type = 'M3'.
      elseif  ZMM_PREP_CRCDESG-crc_level = 'L2' or
              ZMM_PREP_CRCDESG-crc_level = 'L3' or
              ZMM_PREP_CRCDESG-crc_level = 'IM'.
        select * from zhelp_mmroles into corresponding fields of table
               it_roles1_addl where role_type = 'M3A'.
      elseif ZMM_PREP_CRCDESG-crc_level = 'L4' or
              ZMM_PREP_CRCDESG-crc_level = 'E5' or
              ZMM_PREP_CRCDESG-crc_level = 'E6' or
              ZMM_PREP_CRCDESG-crc_level = 'E7'.
        select * from zhelp_mmroles into corresponding fields of table
               it_roles1_addl where role_type = 'M3B'.
      elseif ( ZMM_PREP_CRCDESG-crc_level = 'SM' and
              ZMM_PREP_CRCDESG-CRC_LEVEL_ADDL = 'SM' ).
         select * from zhelp_mmroles into corresponding fields of table
               it_roles1_addl where role_type = 'M11M'.
       endif.
      clear flag.
      loop at it_roles1_addl into wa_roles1.
        WA_ROLES1-USERID = zmm_prep_rolereq-userid.
        WA_ROLES1-ROLE_NAME = WA_ROLES1-ROLE_NAME.
        SEARCH WA_ROLES1-ROLE_NAME for 'XX'.
        if sy-subrc = 0.
          flag = 'X'.
          REPLACE 'XX' with wa_rolesz-approver INTO
                                        WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
        SEARCH WA_ROLES1-ROLE_NAME for 'QQ'.
        if sy-subrc = 0.
          flag = 'X'.
          REPLACE 'QQ' with ZMM_PREP_CRCDESG-crc_level INTO
                                        WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
        SEARCH WA_ROLES1-ROLE_NAME for 'PLANT'.
        if sy-subrc = 0.
          flag = 'X'.
          REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
          REPLACE 'PPPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.

        SEARCH WA_ROLES1-ROLE_NAME for 'FM_LOGS'.
        IF SY-SUBRC = 0.
        flag = 'X'.
        if zmm_prep_rolereq-fundc1 <> '' .
          REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc1 INTO
                             WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
        if zmm_prep_rolereq-fundc <> ''.
          REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc INTO
                             WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
        if zmm_prep_rolereq-fundc2 <> ''.
          REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc2 INTO
                             WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
        if zmm_prep_rolereq-fundc3 <> ''.
          REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc3 INTO
                             WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
        if zmm_prep_rolereq-fundc4 <> ''.
          REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc4 INTO
                             WA_ROLES1-ROLE_NAME.
          APPEND WA_ROLES1 to IT_ROLES1.
        endif.
      ENDIF.

      SEARCH WA_ROLES1-ROLE_NAME for 'CCC_YY'.
      IF SY-SUBRC = 0.
        flag = 'X'.
        REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                      WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 to IT_ROLES1.
      ENDIF.

      if flag <> 'X'.
        APPEND WA_ROLES1 to IT_ROLES1.
      else.
        clear flag.
      endif.
      endloop.
     endif.
ENDFORM.                    " insert_data_addl

*--- INCLUDE: MZMMPREPROLE3I01 ---*

*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  okcode = sy-ucomm.

  Case okcode.

    When 'BAC' OR 'CAN'.

      perform bac_confirm.
*      refresh control 'TABCTRL100' from screen '0100'.
      clear okcode.
      leave program.

    When 'CREATE'.

      g_mode = 'CRE'.
      clear okcode.

    When 'CHANGE'.

      g_mode = 'CHA'.
      clear okcode.

    When 'DISPLAY'.

      g_mode = 'DIS'.
      clear okcode.

    When 'DELETE'.

      g_mode = 'DEL'.
      clear okcode.

    when 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
      .
*        Perform Save_request.

      clear okcode.

    when 'RELEASE'.

      g_mode = 'REL'.
      clear okcode.

    when 'APPROVE'.

      g_mode = 'APR'.
      clear okcode.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: modify table
module TABCTRL100_modify input.

  if ZMM_PREP_ROLEREI-rej_fl is initial.
    clear : ZMM_PREP_ROLEREI-rej_id, ZMM_PREP_ROLEREI-rej_date.
  endif.

  move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.

  select single * from zmm_prep_rolegrp where role_type =
                  ZMM_PREP_ROLEREI-role_name.

  if ZMM_PREP_ROLEREI-rej_fl = ''.

    if sy-subrc = 0 and old_ok_code = 'APPROVE'.
      if zmm_prep_rolegrp-approver1 = g_user
         or zmm_prep_rolegrp-approver2 = g_user
         or zmm_prep_rolegrp-approver3 = g_user.
      else.

        if okcode_100 = 'SAV'.
          if err_flg <> 'X'.
            err_flg = 'X'.
            clear : sy-ucomm, okcode_100.
          endif.
          message e047(zhelp) with zmm_prep_rolegrp-role_type.
        endif.
      endif.
    endif.

  endif.

  if not g_TABCTRL100_wa-role_name is initial.
    select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.
    if sy-subrc = 0.
      g_TABCTRL100_wa-role_desc = zmm_prep_roledes-brief_desc.
    endif.
  endif.

  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line.

  if sy-subrc <> 0.
    append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

  if g_cursor_line = sy-stepl and okcode_100 = 'COPY'.
    append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

  if g_curfield = 'ZMM_PREP_ROLEREI-ROLE_REQUEST' and
  g_cursor_line = sy-stepl.
  set parameter id 'ZAUTHREQ' field ZMM_PREP_ROLEREI-ROLE_REQUEST.
  endif.

  if g_cursor_line = sy-stepl and okcode_100 = 'TABCTRL100_DELE' and
        g_TABCTRL100_wa-rej_fl <> ''.
    g_rej_fl = 'X'.
  endif.

endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
module TABCTRL100_mark input.
  if TABCTRL100-line_sel_mode = 1 and
     g_TABCTRL100_wa-flag = 'X'.
    loop at g_TABCTRL100_itab into g_TABCTRL100_wa
      where flag = 'X'.
      g_TABCTRL100_wa-flag = ''.
      modify g_TABCTRL100_itab
        from g_TABCTRL100_wa
        transporting flag.
    endloop.
    g_TABCTRL100_wa-flag = 'X'.
  endif.
  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
module TABCTRL100_user_command input.
  OKCODE = sy-ucomm.
  if g_rej_fl <> 'X'.
    perform user_ok_tc using    'TABCTRL100'
                                'G_TABCTRL100_ITAB'
                                'FLAG'
                       changing OKCODE.
  else.
    clear g_rej_fl.
  endif.
  sy-ucomm = OKCODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-PLANT' and screen-input = 0.
      dis_flag = 'X'.
    endif.

  endloop.


  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.

  DATA   : it_bukrs type table of zd_t001w_bukrs with header line.

  select * from zd_t001w_bukrs into corresponding fields of
             table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_BUKRS
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
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

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-GRP' and screen-input = 0.
      dis_flag = 'X'.
    endif.

  endloop.

  DATA : l_ekgrp like t024-ekgrp.
  refresh : it_cond.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF ZMM_PREP_ROLEREQ-CCODE = 'SBS' or ZMM_PREP_ROLEREQ-CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'JOR'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'BDA' or
     ZMM_PREP_ROLEREQ-CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'KKL'.
    g_select = 'M%'.
    g_select_flag = 'X'.

    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
    g_select = 'V%'.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024_1 where (it_cond).
    refresh it_cond.
    append lines of it_t024_1 to it_t024.
    refresh it_t024_1.

  ENDIF.
*
  if ZMM_PREP_ROLEREQ-CCODE <> 'KKL'.
    refresh it_cond.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
  endif.

  if g_select_flag <> 'X'.
    select * from t024 into table it_t024 where
            ( ekgrp not between 'A' and 'EZZ' ) and
            ( ekgrp not between 'K' and 'MZZ' ) and
            ( ekgrp not between 'G' and 'GZZ' ) and
            ( ekgrp not between 'R' and 'TZZ' ) and
            ( ekgrp not between 'V' and 'WZZ' ).
  endif.

  data : loop_step like sy-stepl.
  Data : l_role_name like ZMM_PREP_ROLEREI-ROLE_NAME.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

  if l_role_name = 'M6' or  l_role_name = 'M7' or
      l_role_name = 'M8'.

  else.

    if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

      loop at it_t024 into wa_t024.

        l_ekgrp = wa_t024-ekgrp.

        if l_ekgrp+1(1) between '0' and 'A'.
          delete it_t024.
        endif.

      endloop.


    else.

      loop at it_t024 into wa_t024.

        l_ekgrp = wa_t024-ekgrp.

        if l_ekgrp+1(1) < '0'  or
        l_ekgrp+1(1) > 'A'.
          delete it_t024.
        endif.

      endloop.

    endif.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'EKGRP'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-GRP'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_t024
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:it_t024,IST_RETURN_TAB.
  FREE : it_t024,IST_RETURN_TAB.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
      dis_flag = 'X'.
    endif.

  endloop.

  TYPES : Begin of z_role_des,
              role_type like zmm_prep_roledes-role_type,
              brief_desc like zmm_prep_roledes-brief_desc,
              sort_field like zmm_prep_roledes-brief_desc,
              mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
            end of z_role_des.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_role type table of z_role_des with header line.

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.


    select * from zmm_prep_rolecrc into corresponding fields of
                 table it_role.

  else.


    select * from zmm_prep_roledes into corresponding fields of
               table it_role.

  endif.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

    clear ZMM_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.
*  if old_ok_code = 'DISPLAY'.
*     clear ZMM_PREP_ROLEREI-ROLE_NAME.
*  Endif.
  REFRESH:IT_ROLE,IST_RETURN_TAB.
  FREE : IT_ROLE,IST_RETURN_TAB.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data INPUT.

  if old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
        old_ok_code = 'DELETE' or old_ok_code = 'CREATE'
        or old_ok_code = 'RELEASE' or ( OLD_OK_CODE = 'APPROVE' ).

    perform check_tel.

    if old_ok_code = 'CREATE'.

      if ZMM_PREP_ROLEREQ-userid is initial.
        message e035(zhelp).
      endif.

      select single * from zusrmst where cpfno =
                                 ZMM_PREP_ROLEREQ-userid.
      if sy-subrc ne 0.
        message e043(zhelp).
      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-name = zusrmst-last_name.
        ZMM_PREP_ROLEREQ-designation = zusrmst-designation.

        concatenate '000' '70' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.
        SELECT * FROM LFB1 UP TO 1 ROWS
 WHERE LIFNR = CPF_LFB1
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        if sy-subrc = 0.
          concatenate  '''' '%' lfb1-kverm '''' into  g_line1.
          concatenate  'OBJNR'  'LIKE' g_line1 into g_line1
          separated by space.
          refresh :  it_cond.
          append g_line1 to it_cond.
          SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE (IT_COND)
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          if sy-subrc = 0.
            ZMM_PREP_ROLEREQ-FUNDC1 = fmzuob-fistl.
            ZMM_PREP_ROLEREQ-COSTC = lfb1-kverm.
            ZMM_PREP_ROLEREQ-CCODE = lfb1-kverm+0(3).

            SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZMM_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

            if sy-subrc =  0.
              ZMM_PREP_ROLEREQ-S_DESC = CSKT-LTEXT.
            endif.

            refresh it_cond[].
            clear it_cond.
          else.
          endif.
        endif.

      endif.

    else.

      if ZMM_PREP_ROLEREQ-docno is initial.
        message e041(zhelp).
      endif.

    endif.


  endif.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

  if okcode_dblclk = 'DBLCLK'.

      call transaction 'ZROLE_REQ2_COPY' and skip first screen.

  endif.

  case okcode_100.

    When 'BAC' OR 'CAN'.
      perform exit_confirm.
    When 'EXT'.
      leave program.

    When 'CREATE'.

      old_ok_code = okcode_100.

    When 'CHANGE'.

      old_ok_code = okcode_100.

    When 'RELEASE'.

      old_ok_code = okcode_100.


    When 'APPROVE'.

      old_ok_code = okcode_100.

    when 'COPY'.


    When 'DISPLAY'.

      old_ok_code = okcode_100.

*    When 'MULTI'.
*
*      call screen 120 STARTING AT 10 5
*                  ENDING   AT 90 15.
*      clear okcode_100.
*

    when 'ROLE_CR'.

      if ZMM_PREP_ROLEREQ-STATUS = 'C'.
        message e086(zhelp).
      else.
*            perform status_update.
        perform create_roles.
      endif.

    WHEN 'SAV'.

      if old_ok_code = 'DELETE'.
        if ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
          Perform delete_request.
        else.
          message e056(ZHELP).
        endif.
      else.

        describe table g_TABCTRL100_itab lines g_lines_rl.
        if g_lines_rl = 0.
          clear okcode_100.
          message i103(zhelp).
        else.
          Perform check_items.
          Perform Save_request.
        endif.
      endif.

    When 'MULTI'.

      call screen 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      clear okcode_100.


    WHEN 'DELETE'.

      old_ok_code = okcode_100.

    WHEN 'SUIM'.

      refresh : ist_seltab.
      clear   : seltab.

      seltab-selname = 'P_REM'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
      seltab-low   = zmm_prep_rolereq-userid.
      append seltab to ist_seltab.

      submit ZMMPREPROLE_ROLE_CREATE_REP WITH SELECTION-TABLE ist_seltab
      and return.

*      CALL SCREEN 120.
*      if okcode_100 = 'BAC'.
*        clear old_ok_code.
*      endif.

    WHEN 'LIST'.

      perform list_files.
      if zmm_prep_rolereq-status = 'C' or
         zmm_prep_rolereq-status = 'IC' or
         zmm_prep_rolereq-status = 'IR'.
        old_ok_code = 'DISPLAY'.
      else.
        old_ok_code = 'CHANGE'.
      endif.

    WHEN 'ATTACH'.

      perform attach_files.
      if zmm_prep_rolereq-status = 'C' or
         zmm_prep_rolereq-status = 'IC' or
         zmm_prep_rolereq-status = 'IR'.
        old_ok_code = 'DISPLAY'.
      else.
        old_ok_code = 'CHANGE'.
      endif.
      g_reset_change = 'X'.

    WHEN 'CORR'.

      Call Screen 105 starting at 85 05 ending at 148 24.
      if g_clines <> 0.
        corr_code = okcode_100.
      endif.
      clear okcode_100.
      g_reset_change = 'X'.

    when 'ROLE_DEL'.

      refresh : ist_seltab.
      clear   : seltab.

      seltab-selname = 'P_REM'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
      concatenate zmm_prep_rolereq-docno ' -ARMS-MM-' into seltab-low.
*          seltab-low   = p_docno.
      append seltab to ist_seltab.

      seltab-selname = 'P_REM1'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
*          concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
      seltab-low   = zmm_prep_rolereq-userid.
      append seltab to ist_seltab.

      if zmm_prep_rolereq-status = 'C' or
         zmm_prep_rolereq-status = 'IC' or
         zmm_prep_rolereq-status = 'IR'..
        message e121(zhelp).

      else.

        submit ZHELPROLE3 WITH SELECTION-TABLE ist_seltab and return.

        get parameter id 'ZROLEREQNO' field ZROLEREQNO.

        get parameter id 'EXIT_VALUE' field g_exit_value.

        if not ZROLEREQNO is initial and ZROLEREQNO <> '00000000' and
          g_exit_value <> 'X'.
          submit ZBC_ROLE_REP01_RFC_DEL and return.
*
          set parameter id 'ZROLEREQNO' field ''.
          clear ZROLEREQNO.
*            perform send_sapmail.
        else.
          set parameter id 'EXIT_VALUE' field ''.
          clear g_exit_value.
        endif.

      endif.

    when 'MAIL'.

      perform confirm_mail.

    when 'SUMMARY'.

      call transaction 'ZMMAUTHSUMMARY' and skip first screen.

    when 'POSTING'.

      call transaction 'ZMMUSERDATA' and skip first screen.

    WHEN OTHERS.

      clear okcode_100.


  endcase.

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
MODULE move_ok_code INPUT.

  if sy-ucomm = 'DBLCLK'.
    okcode_dblclk = sy-ucomm.
    clear sy-ucomm.
  endif.
  okcode_100 = sy-ucomm.
  clear : g_srno, err_flg.

  get cursor field g_curfield.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_current_line  = g_cursor_line.
  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_data INPUT.

  if not zmm_prep_rolereq-docno is initial.

*  data : l_docno like zmm_prep_rolereq-docno.

    l_docno = zmm_prep_rolereq-docno.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

    zmm_prep_rolereq-docno = l_docno.

  endif.


  if old_doc_no <> ZMM_PREP_ROLEREq-docno.
    clear: g_hd_copied.
    perform destroy_ctrl.

  endif.

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
            TEXT       =  LT_TEXT_TABLE1
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE1
            ITF_TEXT    = TLINETAB1.
*
  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' ).

    CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
         IMPORTING
              TEXT       =  LT_TEXT_TABLE2
              IS_MODIFIED = GV_XTHEAD_UPDKZ
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

  Data: okcode105 like sy-ucomm.

  okcode105 = sy-ucomm.

  Case okcode105.
    When 'OK'.
      describe table tlinetab2 lines g_clines.
      clear okcode105.
    When 'CANCEL'.
      refresh tlinetab2[].
      clear okcode105.
  Endcase.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-SLOC' and screen-input = 0.
      dis_flag = 'X'.
    endif.

  endloop.

  Data : l_plant like ZMM_PREP_ROLEREI-PLANT.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_plant.

  DATA   : it_t001l type table of t001l with header line.
  DATA   : wa_t001l like t001l.
  DATA   : l_zarea like zmm_consm-zarea.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

  if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

    loop at it_t001l into wa_t001l.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      if sy-subrc = 0.

        if l_zarea+0(1) <> 'M'.
          delete it_t001l.
        endif.

      else.

        delete it_t001l.

      endif.

    endloop.

  else.

    loop at it_t001l into wa_t001l.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      if sy-subrc = 0.

        if l_zarea+0(1) = 'M'.
          delete it_t001l.
        endif.

      else.

        delete it_t001l.

      endif.

    endloop.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_t001l
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:IT_t001l,IST_RETURN_TAB.
  FREE : IT_t001l,IST_RETURN_TAB.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_APPROVER INPUT.

  loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  data : it_approver like table of zmm_prep_approve.
  data : wa_approver like zmm_prep_approve.

  data : it_approver1 like table of zmm_prep_app_CRC.
  data : wa_approver1 like zmm_prep_app_CRC.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

     if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.


*      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
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


*      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
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
           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-M11S_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.

             if l_role_name = 'M11M'.

                loop at it_approver into wa_approver.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'
                        or wa_approver-M11M_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-MM_FLAG = 'X'
                         or wa_approver-M11M_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.
**************************************************22.05.06

        if l_role_name = 'M8'.

            loop at it_approver into wa_approver.

                if wa_approver-M8_FLAG <> 'X'.
                    delete it_approver.
                 endif.

            endloop.

         endif.

         if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'..

             if l_role_name = 'M3'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

             if l_role_name = 'M3A'. "22.05.06

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3A_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

            if l_role_name = 'M3B'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3B_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

           endif.                       " 22.05.06


             if l_role_name = 'M11S'.

                loop at it_approver1 into wa_approver1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11S_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11S_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

            if l_role_name = 'M11M'.

                loop at it_approver1 into wa_approver1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11M_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11M_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

             it_approver[] = it_approver1[].

         endif.

 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
 g_field_wa-fieldname = 'APP_LEVEL'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
 g_field_wa-fieldname = 'L_DESC'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'APP_LEVEL'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-APPROVER'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_approver
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:it_approver,IST_RETURN_TAB.
  FREE : it_approver,IST_RETURN_TAB.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RECEIPT_LOC INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC' and screen-input =
0.
      dis_flag = 'X'.
    endif.

  endloop.

  data : it_recpt like table of zmm_location.
  data : wa_recpt like zmm_location.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

  select * from zmm_location into table it_recpt.


  if l_role_name = 'M12'.

    loop at it_recpt into wa_recpt.

      if wa_recpt-loccg <> 'RL'.
        delete it_recpt.
      endif.

    endloop.

  endif.


  if l_role_name = 'M17'.

    loop at it_recpt into wa_recpt.

      if wa_recpt-loccg <> 'CF'.
        delete it_recpt.
      endif.

    endloop.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LOCCD'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_recpt
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:it_recpt,IST_RETURN_TAB.
  FREE : it_recpt,IST_RETURN_TAB.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  if sy-ucomm = 'EXT'.
    leave program.
  endif.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.

  old_doc_no = ZMM_PREP_ROLEREq-docno.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fund_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fund_data INPUT.
  data l_fundc_no like sy-index.
  clear l_fundc_no.
  loop at it_m_fistb into wa_m_fistb.
    if wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      case l_fundc_no.
        when 2.
          ZMM_PREP_ROLEREQ-fundc2 = wa_m_fistb-fictr.
        when 3.
          ZMM_PREP_ROLEREQ-fundc3 = wa_m_fistb-fictr.
        when 4.
          ZMM_PREP_ROLEREQ-fundc4 = wa_m_fistb-fictr.
        when 5.
          message e078(zhelp).
      endcase.
    endif.
  endloop.

ENDMODULE.                 " validate_fund_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE record_rej_id_data INPUT.
  if ZMM_PREP_ROLEREI-rej_id is initial.
    ZMM_PREP_ROLEREI-rej_id = sy-uname.
    ZMM_PREP_ROLEREI-rej_date = sy-datum.
  endif.

  if not ZMM_PREP_ROLEREI-rej_fl is initial and
     ZMM_PREP_ROLEREI-rej_fl_save is initial.

    select single * from  ZMM_PREP_REJ_LIS  where
      rej_code = ZMM_PREP_ROLEREI-rej_fl .
    if sy-subrc <> 0.
      g_e_fl = 'X'.
      message e111(zhelp).
    else.
      if sy-uname+0(1) = 'C' and
                    ZMM_PREP_ROLEREI-rej_fl = 'F'.
      else.
        g_e_fl = 'X'.
        message e111(zhelp).
*        if g_user = 'L1' and ZMM_PREP_ROLEREI-rej_fl <> 'R'.
*        message e111(zhelp).
*        elseif g_user = 'L3' and ZMM_PREP_ROLEREI-rej_fl <> 'B'.
*        message e111(zhelp).
*        elseif g_user = 'IM' and ZMM_PREP_ROLEREI-rej_fl <> 'I'.
*        message e111(zhelp).
*        endif.
      endif.
    endif.
  endif.

ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

  if g_read_fl <> 'X'.

    select single * from zmm_prep_roledes where role_type =
                      ZMM_PREP_ROLEREI-role_name.


  elseif g_e_fl = 'X'.
    clear g_e_fl.

  else.

    clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
    clear  ZMM_PREP_ROLEREI-SLOC.
    clear  ZMM_PREP_ROLEREI-plant.
    clear  ZMM_PREP_ROLEREI-grp.
    clear  ZMM_PREP_ROLEREI-approver.

    clear g_read_fl.
  endif.

  l_role_name = ZMM_PREP_ROLEREI-role_name.

**********************************************************

  if old_ok_code <> 'DISPLAY'.

    select single * from zmm_prep_roledes  where
              role_type = ZMM_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
      message e067(zhelp) with ZMM_PREP_ROLEREI-role_name.
    else.
** put validation for MM discipline roles????
      if zmm_prep_roledes-mm_disc_flag = 'X'.

        if ZMM_PREP_ROLEREQ-disc_mm_flag = 'X'.
        else.
          message e081(zhelp) with ZMM_PREP_ROLEREI-role_name.
        endif.

      endif.

    endif.

    if not ZMM_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE
                                    and werks = ZMM_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
        g_e_fl = 'X'.
        message e068(zhelp) with ZMM_PREP_ROLEREI-role_name.
      endif.

    endif.


************finding group*******************

    refresh : it_cond, it_t024, it_t024_1.
    clear   : wa_t024.
    concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
    space.
    IF ZMM_PREP_ROLEREQ-CCODE = 'SBS' or ZMM_PREP_ROLEREQ-CCODE = 'SBW'.
      g_select = 'R%'.
      g_select_flag = 'X'.
    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'JOR'.
      g_select = 'L%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'ANK'.
      g_select = 'A%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'BDA' or
      ZMM_PREP_ROLEREQ-CCODE = 'BDW'.
      g_select = 'B%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'CBY'.
      g_select = 'C%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'AMD'.
      g_select = 'D%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'MHN'.
      g_select = 'E%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'JDH'.
      g_select = 'G%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'RJY'.
      g_select = 'K%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'SIL'.
      g_select = 'S%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'AGT'.
      g_select = 'T%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'MBP'.
      g_select = 'W%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'KKL'.
      g_select = 'M%'.
      g_select_flag = 'X'.

      concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
      append g_line1 to it_cond.
      select * from t024 into table it_t024 where (it_cond).
      refresh it_cond.
      g_select = 'V%'.
      concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
      append g_line1 to it_cond.
      select * from t024 into table it_t024_1 where (it_cond).
      refresh it_cond.
      append lines of it_t024_1 to it_t024.
      refresh it_t024_1.

    ENDIF.
*
    if ZMM_PREP_ROLEREQ-CCODE <> 'KKL'.
      refresh it_cond.
      concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
      append g_line1 to it_cond.
      select * from t024 into table it_t024 where (it_cond).
      refresh it_cond.
    endif.

    if g_select_flag <> 'X'.
      select * from t024 into table it_t024 where
              ( ekgrp not between 'A' and 'EZZ' ) and
              ( ekgrp not between 'K' and 'MZZ' ) and
              ( ekgrp not between 'G' and 'GZZ' ) and
              ( ekgrp not between 'R' and 'TZZ' ) and
              ( ekgrp not between 'V' and 'WZZ' ).
    endif.


    if l_role_name = 'M6' or  l_role_name = 'M7' or
        l_role_name = 'M8'.

    else.

      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

        loop at it_t024 into wa_t024.

          l_ekgrp = wa_t024-ekgrp.

          if l_ekgrp+1(1) between '0' and 'A'.
            delete it_t024.
          endif.

        endloop.


      else.

        loop at it_t024 into wa_t024.

          l_ekgrp = wa_t024-ekgrp.

          if l_ekgrp+1(1) < '0'  or
          l_ekgrp+1(1) > 'A'.
            delete it_t024.
          endif.

        endloop.

      endif.

    endif.


**
    if  not ZMM_PREP_ROLEREI-GRP is initial.

      loop at it_t024 into wa_t024.

        if ZMM_PREP_ROLEREI-GRP = wa_t024-ekgrp.
          grp_flag = 'X'.
        endif.

      endloop.

      if grp_flag = 'X'.
        clear grp_flag.
      else.
        g_e_fl = 'X'.
        message e069(zhelp).
      endif.

    endif.

***************************

    clear : l_zarea, wa_t001l.
    refresh it_t001l.

    if ( ZMM_PREP_ROLEREI-role_name = 'M13' or
       ZMM_PREP_ROLEREI-role_name = 'M14' or
        ZMM_PREP_ROLEREI-role_name = 'M16' or
        ZMM_PREP_ROLEREI-role_name = 'M18' or
        ZMM_PREP_ROLEREI-role_name = 'M19' ) and
        not ZMM_PREP_ROLEREI-PLANT is initial.

      select * from t001l into corresponding fields of
                   table it_t001l  where werks = ZMM_PREP_ROLEREI-PLANT.

      if  sy-subrc <> 0.
        g_e_fl = 'X'.
        message e074(zhelp).
      endif.

    endif.

    if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

      loop at it_t001l into wa_t001l.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.

          if l_zarea+0(1) <> 'M'.
            delete it_t001l.
          endif.

        else.

          delete it_t001l.

        endif.

      endloop.

    else.

      loop at it_t001l into wa_t001l.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.

          if l_zarea+0(1) = 'M'.
            delete it_t001l.
          endif.

        else.

          delete it_t001l.

        endif.

      endloop.

    endif.

    if  not ZMM_PREP_ROLEREI-SLOC is initial.

      loop at it_t001l into wa_t001l.

        if ZMM_PREP_ROLEREI-SLOC = wa_t001l-lgort.
          loc_flag = 'X'.
        endif.

      endloop.

      if loc_flag = 'X'.
        clear loc_flag.
      else.
        g_e_fl = 'X'.
        message e073(zhelp).
      endif.

    endif.


***************************

    clear wa_recpt.
    refresh it_recpt.

    if ( ZMM_PREP_ROLEREI-role_name = 'M12' or
       ZMM_PREP_ROLEREI-role_name = 'M17' ) and
       not ZMM_PREP_ROLEREI-receipt_loc is initial.

      select * from zmm_location into table it_recpt.

      if ZMM_PREP_ROLEREI-role_name = 'M12'.

        loop at it_recpt into wa_recpt.

          if wa_recpt-loccg <> 'RL'.
            delete it_recpt.
          endif.

        endloop.

      endif.


      if ZMM_PREP_ROLEREI-role_name = 'M17'.

        loop at it_recpt into wa_recpt.

          if wa_recpt-loccg <> 'CF'.
            delete it_recpt.
          endif.

        endloop.

      endif.

    endif.

    if  not ZMM_PREP_ROLEREI-RECEIPT_LOC is initial.

      loop at it_recpt into wa_recpt.

        if ZMM_PREP_ROLEREI-receipt_loc = wa_recpt-loccd.
          loc_flag = 'X'.
        endif.

      endloop.

      if loc_flag = 'X'.
        clear loc_flag.
      else.
        g_e_fl = 'X'.
        message e075(zhelp).
      endif.

    endif.
*****************************
*****************************22.05.06

if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.

           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-M11S_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.

             if l_role_name = 'M11M'.

                loop at it_approver into wa_approver.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'
                        or wa_approver-M11M_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-MM_FLAG = 'X'
                         or wa_approver-M11M_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.
**************************************************22.05.06

        if l_role_name = 'M8'.

            loop at it_approver into wa_approver.

                if wa_approver-M8_FLAG <> 'X'.
                    delete it_approver.
                 endif.

            endloop.

         endif.

         if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'..

             if l_role_name = 'M3'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

             if l_role_name = 'M3A'. "22.05.06

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3A_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

            if l_role_name = 'M3B'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3B_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

           endif.                       " 22.05.06


             if l_role_name = 'M11S'.

                loop at it_approver1 into wa_approver1.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11S_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11S_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

            if l_role_name = 'M11M'.

                loop at it_approver1 into wa_approver1.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11M_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11M_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

             it_approver[] = it_approver1[].

         endif.
*********************************************22.05.06

if  not ZMM_PREP_ROLEREI-APPROVER is initial.

       loop at it_approver into wa_approver.

           if ZMM_PREP_ROLEREI-APPROVER = wa_approver-app_level.
              approver_flag = 'X'.
           endif.

       endloop.

       if approver_flag = 'X'.
          clear approver_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.
          modify g_TABCTRL100_itab
                    from g_TABCTRL100_wa
                      index TABCTRL100-current_line.
          g_i = TABCTRL100-current_line.
          message e135(zhelp).
          call screen 100.

       endif.

   endif.

*****************************

  endif.

ENDMODULE.                 " validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data1 INPUT.

  select single * from zmm_prep_roledes where role_type =
                    ZMM_PREP_ROLEREI-role_name.

  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno INPUT.
  clear g_srno.
  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.
    g_srno = g_srno + 1.
    g_TABCTRL100_wa-srno = g_srno.
    modify g_TABCTRL100_itab from g_TABCTRL100_wa.
  endloop.
  describe table g_TABCTRL100_itab  lines g_lines_rl.
  describe table g_TABCTRL100_itab  lines TABCTRL100-lines.
  clear g_srno.
ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
g_role_name_prev = ZMM_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CRC_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CRC_POS INPUT.

loop at screen.

      if screen-name = 'CRC_POS' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  data : loop_step like sy-stepl.
  Data : l_role_type like ZMM_PREP_ROLEREI-ROLE_NAME.
  data : ist_return_tab1 like standard table of dselc with header line.
  data : ist_return_tab2 like standard table of DYNPREAD with header
         line.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_type.

  select * from zmm_prep_crcdesg into corresponding fields of
             table it_pos where role_type = l_role_type.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'CRC_POS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'CRC_ORDER_AUTH'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 g_field_wa-fieldname = 'ROLE_TYPE_EX'.
 append g_field_wa to g_field_tab.

* g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 ist_return_tab1-fldname = 'ROLE_TYPE_EX'.
 ist_return_tab1-dyfldname = 'ZMM_PREP_ROLEREI-ROLE_TYPE_EX'.
 append ist_return_tab1 to ist_return_tab1.
* g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 ist_return_tab1-fldname = 'ROLE_TYPE'.
 ist_return_tab1-dyfldname = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
 append ist_return_tab1 to ist_return_tab1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'CRC_POS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'CRC_POS'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

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
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
else.
    read table IST_RETURN_TAB with key fieldname = 'CRC_POS'.
    ist_return_tab2-fieldname = IST_RETURN_TAB-fieldname.
    ist_return_tab2-fieldvalue = IST_RETURN_TAB-fieldval.
    ist_return_tab2-stepl = loop_step.
    append ist_return_tab2 to ist_return_tab2.
    read table IST_RETURN_TAB with key fieldname = 'ROLE_TYPE_EX'.
    concatenate 'ZMM_PREP_ROLEREI-' IST_RETURN_TAB-fieldname into
    IST_RETURN_TAB-fieldname.
    ist_return_tab2-fieldname = IST_RETURN_TAB-fieldname.
    ist_return_tab2-fieldvalue = IST_RETURN_TAB-fieldval.
    ist_return_tab2-stepl = loop_step.
    append ist_return_tab2 to ist_return_tab2.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME                     = sy-cprog
        DYNUMB                     = sy-dynnr
      TABLES
        DYNPFIELDS                 = IST_RETURN_TAB2
     EXCEPTIONS
       INVALID_ABAPWORKAREA       = 1
       INVALID_DYNPROFIELD        = 2
       INVALID_DYNPRONAME         = 3
       INVALID_DYNPRONUMMER       = 4
       INVALID_REQUEST            = 5
       NO_FIELDDESCRIPTION        = 6
       UNDEFIND_ERROR             = 7
       OTHERS                     = 8
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    clear dis_flag.

  ENDIF.

  REFRESH:IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1.
  FREE  : IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1
.

ENDMODULE.                 " POV_CRC_POS  INPUT

*--- INCLUDE: MZMMPREPROLE3O01 ---*

*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  Perform fill_sttab.

  if old_ok_code = 'CREATE' or old_ok_code = 'CHANGE' or
      old_ok_code = 'DISPLAY' or old_ok_code = 'DELETE' or
      sy-tcode = 'ZMM_AUTH_CORETEAM'.

    SET PF-STATUS 'OPTNS1' excluding it_tab.

  else.

    SET PF-STATUS 'OPTNS'.

  endif.

  case sy-ucomm.
    when 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' with ': Create Request'.
    when 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' with ': Change Request'.
    when 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' with ': Display Request'.
    when 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' with ': Delete Request'.
    when 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' with ': Release Request'.
    when 'APPROVE'.
      SET TITLEBAR 'PREP_TITLE' with ': Approve Request'.

    when others.
      SET TITLEBAR 'PREP_TITLE' with ''.
  endcase.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.

  if not zmm_prep_rolereq-docno is initial.

    data : l_docno like zmm_prep_rolereq-docno.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = zmm_prep_rolereq-docno
         IMPORTING
              OUTPUT = l_docno.

    zmm_prep_rolereq-docno = l_docno.

  endif.

  if  g_hd_copied <> 'X'.
*
    if old_ok_code is initial and okcode_100 is initial.

    else.

      if old_ok_code = 'CREATE' and okcode_100 is initial.

      else.

        if ( old_ok_code = 'CHANGE' ) OR ( old_ok_code = 'DELETE' )
            or ( old_ok_code = 'RELEASE' )
            or ( OLD_OK_CODE = 'APPROVE' ).
          if not zmm_prep_rolereq-docno is initial and g_lock <> 'Y'.
            perform lock_reqhd.
          endif.
        endif.

        if sy-subrc = 0 and not zmm_prep_rolereq-docno is initial.

          g_hd_copied = 'X'.

          select * from ZMM_PREP_ROLEREI into corresponding
                   fields of table g_TABCTRL100_itab
                   where DOCNO = ZMM_PREP_ROLEREQ-docno and
                   ( ( role_name like 'M%' ) or ( role_name like 'C%' )
).
        endif.

        if not ZMM_PREP_ROLEREQ-docno is initial.

          select single * from ZMM_PREP_ROLEREQ
                     where DOCNO = ZMM_PREP_ROLEREQ-docno.

          if sy-subrc = 0 .

            perform validations.

          endif.

        endif.

      endif.

      select single * from ZMM_PREP_RSN
                 where REASON = ZMM_PREP_ROLEREQ-RSN_CODE.

      ZMM_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

    endif.

  endif.

  perform get_correspondense.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

*  if l_old_ok_code = 'X' and g_reset_change <> 'X'.
*    perform auth_check.
*  else.
*    clear g_reset_change.
*  endif.

  CASE old_ok_code.

    when ''.

      loop at screen.
        screen-input = 0.
        modify screen.
      endloop.

    when 'CREATE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 1.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-required = 0.
          modify screen.
        endif.


      endloop.

    when 'CHANGE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group3 = 'GPC' .
          if ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
            screen-active = 1.
          else.
            screen-active = 0.
          endif.
          screen-invisible = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-NAME1' ).
          screen-input = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
           screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          screen-active = 0.
          screen-invisible = 1.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
           screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL <> 'X'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-REASON1'.
          if not ZMM_PREP_ROLEREQ-FUNDC is initial.
            screen-input = 1.
            screen-required = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

      endloop.

    when 'RELEASE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_PREP_ROLEREQ-REQ_CR_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'APPROVE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'TABCTRL100_DELETE'.
          screen-input = 0.
          modify screen.
        endif.

      if g_user = 'L1' and screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP1_FL'
   .
          screen-input = 1.
          modify screen.
        endif.
        if ( g_user = 'IM' or g_user = 'L3' ) and
            screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'DISPLAY'.

      loop at screen.

       if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
                                                  or screen-name = 'M'
                                 or screen-name = 'TABCTRL100_PREVIOUS'
                                    or screen-name = 'TABCTRL100_NEXT'.
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

        if screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
           screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          screen-active = 0.
          screen-invisible = 1.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-USERID' or
          screen-name = 'ZMM_PREP_ROLEREQ-RSN_CODE' or
          screen-name = 'ZMM_PREP_ROLEREQ-TELNO' .
          screen-input = 0.
          modify screen.
        endif.

      endloop.

    when 'DELETE'.

      loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
   .
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
          screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          screen-active = 0.
          screen-invisible = 1.
          modify screen.
        endif.

      endloop.


  ENDCASE.
ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL100_init output.

  perform check_list_processing.

  perform get_user.

  PERFORM upload1_file.

  if g_hd_copied is initial.
*&spwizard: copy ddic-table 'ZMM_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABCTRL100_itab'
*    select * from ZMM_PREP_ROLEREI
*       into corresponding fields
*       of table g_TABCTRL100_itab.
*    g_TABCTRL100_copied = 'X'.
    data : l_fis_initial.
    set parameter id 'FIS' field l_fis_initial.
    refresh control 'TABCTRL100' from screen '0100'.
  endif.

  GET PARAMETER ID 'ZOLDCODE' field l_old_ok_code.

  if l_old_ok_code = 'X'.
    GET PARAMETER ID 'ZREQNO' field ZMM_PREP_ROLEREQ-DOCNO.
    old_ok_code = 'CHANGE'.
  endif.

endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: move itab to dynpro
module TABCTRL100_move output.
  move-corresponding g_TABCTRL100_wa to ZMM_PREP_ROLEREI.
  if not ZMM_PREP_ROLEREI-role_name is initial.
    ZMM_PREP_ROLEREI-DOCNO = ZMM_PREP_ROLEREQ-DOCNO.
    if old_ok_code = 'CRCROLES' or zmm_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        move zmm_prep_rolecrc-brief_desc to role_desc.
      endif.
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZMM_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        move zmm_prep_crcdesg-CRC_POS to CRC_POS.
      endif.
     else.
      select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zmm_prep_roledes-brief_desc to role_desc.
     endif.
    endif.
  endif.
*  move g_TABCTRL100_wa-role_desc to role_desc.
endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABCTRL100_get_lines output.
  g_TABCTRL100_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  value_list  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*  MOVE 'REQ1' to WA_TAB.
*  APPEND WA_TAB to TAB.
  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Current Roles of User:', ZMM_PREP_ROLEREQ-USERID
  COLOR COL_HEADING.
  ULINE.
  if flag_s_fundc = 'X' and okcode_100 <> 'SUIM'.
    PERFORM HELP_LIST.
  endif.

  if okcode_100 = 'SUIM'.
    perform help_suim.
  endif.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_120 OUTPUT.
  perform hide.
  SET PF-STATUS 'STATUS_120'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_attrib OUTPUT.

  if old_ok_code = 'DISPLAY'.

   loop at screen.

      screen-input = 0.
      modify screen.

    endloop.

  endif.

  if old_ok_code <> 'DISPLAY' .

    select single * from zmm_prep_roledes where role_type =
                                              g_TABCTRL100_wa-role_name.

    if sy-subrc = 0.

      loop at screen.

        if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

*          if old_ok_code <> 'APPROVE'.
*            screen-input = 1.
*          else.
            screen-input = 0.
*          endif.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if sy-tcode = 'ZMM_AUTH_CORETEAM' and
              screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
              old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREI-REJ_FL = ''.
          screen-input = 1.
          modify screen.
        endif.

        if sy-tcode = 'ZMM_AUTH_CORETEAM' and
              screen-name = 'ZMM_PREP_ROLEREI-STATUS'
              and ZMM_PREP_ROLEREQ-CRC_FL = 'X'
              and ZMM_PREP_ROLEREI-role_request = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-STATUS' and
           ZMM_PREP_ROLEREI-role_request <> ''.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
           ZMM_PREP_ROLEREI-role_request <> ''.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .

*          if zmm_prep_roledes-plant = 'X' and
*                        old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-GRP'.

*          if zmm_prep_roledes-P_GRP = 'X' and
*                        old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-APPROVER'.

*          if zmm_prep_roledes-APP_LEVEL = 'X' and
*                      old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

*          if zmm_prep_roledes-S_LOC = 'X' and
*                    old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

*          if zmm_prep_roledes-R_LOC = 'X' and
*                    old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.

      endloop.

    else.

**      loop at screen.
**
**        if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and
**                          not old_ok_code is initial .
**          screen-input = 1.
**          modify screen.
**        else.
**          screen-input = 0.
**          modify screen.
**        endif.

**      endloop.

      if ZMM_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

        SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.

          loop at screen.

            if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

*              if old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*              else.
                screen-input = 0.
*              endif.
              modify screen.
            endif.

            if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL'
              and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
              screen-input = 1.
              modify screen.
            endif.


            if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .


*              if zmm_prep_rolecrc-plant = 'X' and
*                                   old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.

            endif.

            if screen-name = 'ZMM_PREP_ROLEREI-GRP' .


*              if zmm_prep_rolecrc-P_GRP = 'X' and
*                                   old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.

            endif.

      if screen-name = 'ZMM_PREP_ROLEREI-APPROVER'.

*          if zmm_prep_roledes-APP_LEVEL = 'X' and
*                      old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.



            if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

*              if zmm_prep_rolecrc-S_LOC = 'X' and
*                        old_ok_code <> 'APPROVE'.
*                .
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.
            endif.

            if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

*              if zmm_prep_rolecrc-R_LOC = 'X' and
*                        old_ok_code <> 'APPROVE'.
*                .
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.

            endif.

          endloop.

        else.

          loop at screen.

            if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and
                               not old_ok_code is initial.
              screen-input = 1.
              modify screen.

              if not ZMM_PREP_ROLEREI-ROLE_NAME is initial.
                message i116(zhelp) with ZMM_PREP_ROLEREI-ROLE_NAME.
              endif.
            else.
              screen-input = 0.
              modify screen.
            endif.

          endloop.

        endif.

      endif.
**
    endif.

  else.
    loop at screen.

      screen-input = 0.
      modify screen.

    endloop.
*

  endif.
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

  perform get_correspondense.

ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SPLITTER_CTRL_VORBEREITEN1 OUTPUT.

  if gv_splitter1 is initial.
    create object gv_custom_container
                  exporting container_name = 'C_DIS'.

    create object gv_splitter1
           exporting
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.
  endif.

  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' ).

    if gv_splitter2 is initial.

      create object gv_custom_container
                    exporting container_name = 'C_WRT'.


      create object gv_splitter2
             exporting
                    parent = gv_custom_container
                    orientation = 1
                    sash_position = 1.

    endif.
  endif.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_VORBEREITEN1 OUTPUT.

  if gv_text_editor1 is initial.
    create object gv_text_editor1
       exporting
            parent = gv_splitter1->bottom_right_container
            wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
            wordwrap_to_linebreak_mode = cl_gui_textedit=>false
       exceptions
            error_cntl_create      = 1
            error_cntl_init        = 2
            error_cntl_link        = 3
            error_dp_create        = 4
            gui_type_not_supported = 5.
    flag1 = 'X'.
  endif.
  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
      or ( old_ok_code = 'RELEASE' )
      or ( OLD_OK_CODE = 'APPROVE' ).

    if gv_text_editor2 is initial.
      create object gv_text_editor2
         exporting
              parent = gv_splitter2->bottom_right_container
              wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
              wordwrap_to_linebreak_mode = cl_gui_textedit=>false
         exceptions
              error_cntl_create      = 1
              error_cntl_init        = 2
              error_cntl_link        = 3
              error_dp_create        = 4
              gui_type_not_supported = 5.
      flag2 = 'X'.
    endif.
  endif.

  perform text_control_eingabebereit1.
  perform text_control_set_text_table1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_col_attrib OUTPUT.

  LOOP AT TABCTRL100-cols INTO cols WHERE index GT 11.
    cols-invisible = '1'.
    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

  LOOP AT TABCTRL100-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
  ENDLOOP.


ENDMODULE.                 " scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup OUTPUT.

  if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

    sort g_TABCTRL100_itab
    by role_name plant grp sloc receipt_loc approver.

    delete adjacent duplicates from g_TABCTRL100_itab
    comparing role_name plant grp receipt_loc sloc approver.

  endif.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.
  describe table g_tabctrl100_itab lines tabctrl100-lines.
  if not g_field is initial.
    set cursor field g_field line g_i.
    clear g_field.
  endif.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

  if l_old_ok_code = 'X' and g_reset_change <> 'X'.
    perform auth_check.
  else.
    clear g_reset_change.
  endif.

  if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    g_text = ' : Cross Company'.
  endif.
  if ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
    g_text = ' : CRC'.
  endif.

  if ZMM_PREP_ROLEREQ-STATUS = 'C' or
     ZMM_PREP_ROLEREQ-STATUS = 'IC' or
     zmm_prep_rolereq-status = 'IR'..
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_CR' to wa_tab-fcode.
    append wa_tab to it_tab.

    set pf-status 'OPTNS1' excluding it_tab..
  endif.

  if old_ok_code = 'DISPLAY'.
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_CR' to wa_tab-fcode.
    append wa_tab to it_tab.
      SET PF-STATUS 'OPTNS1' excluding it_tab.
  endif.


  SET TITLEBAR 'PREP_TITLE' with g_text.

ENDMODULE.                 " set_title  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_0100_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_0100_AUTH OUTPUT.
  select single * from zmm_prep_usrcont where
             bname = sy-uname.
  if sy-subrc <> 0.
    message i104(zhelp).
    old_ok_code = 'DISPLAY'.
  endif.

ENDMODULE.                 " CHECK_0100_AUTH  OUTPUT

*--- INCLUDE: MZMMPREPROLE3TOP ---*
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*  1) Length Specification is Not Allowed for TYPE I. (Line 266)
************************************************************************
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZMM_PREP_ROLEREQ, ZMM_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, zhelp_mmroles,
zmm_prep_role_sl, zhelp_mmroles_rc,ZMM_PREP_REJ_LIS, zmm_prep_rolecrc,
zmm_prep_usrcont,zmm_prep_crcdesg.

Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

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
          sbmod     type pa0001-sbmod,
        END OF ty_data.

Data: it_tab type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.

data : p1_file LIKE rlgrap-filename value 'C:\role_upload.txt'.

DATA : it_roles TYPE STANDARD TABLE OF in_roles.
DATA : it_roles0 TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1 TYPE STANDARD TABLE OF out_roles.
DATA : it_roles1_addl TYPE STANDARD TABLE OF out_roles.
DATA : it_agr_users type standard table of agr_users .
DATA : it_role_del_data type table of del_roles.
DATA : wa_role_del_data type del_roles.
DATA : wa_agr_users like agr_users.
DATA : wa_roles TYPE in_roles.   " work area

DATA : WA_ROLES1 type out_roles.

DATA : ist_seltab like table of rsparams.
DATA : seltab like rsparams.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data with header line.
DATA : it_m_fistb TYPE STANDARD TABLE OF ty_m_fistb.

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

         ROLE_NAME like ZMM_PREP_ROLEREI-ROLE_NAME,
         DOCNO like ZMM_PREP_ROLEREI-DOCNO,
         ROLE_REQUEST like ZMM_PREP_ROLEREI-ROLE_REQUEST,

         PLANT like ZMM_PREP_ROLEREI-PLANT,
         GRP like ZMM_PREP_ROLEREI-GRP,
         role_desc like zmm_prep_roledes-brief_desc,
         RECEIPT_LOC like zmm_prep_ROLEREI-receipt_loc,
         SLOC like zmm_prep_ROLEREI-sloc,
         flag,       "flag for mark column
         srno like ZMM_PREP_ROLEREI-srno,
         approver like ZMM_PREP_ROLEREI-approver,
         rej_fl like ZMM_PREP_ROLEREI-rej_fl,
         rej_id like ZMM_PREP_ROLEREI-rej_id,
         rej_date like ZMM_PREP_ROLEREI-rej_date,
         rej_fl_save like ZMM_PREP_ROLEREI-rej_fl_save,
         status like ZMM_PREP_ROLEREI-status,
         role_type_ex like zmm_prep_rolerei-role_type_ex,

       end of t_TABCTRL100.

data:     ist_itemtab type standard table of zmm_prep_rolerei.
data:     wa_itemtab like zmm_prep_rolerei.
DATA:     wa_rolesz type t_TABCTRL100.

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
DATA : wa_t024 like t024.
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
DATA : old_doc_no like ZMM_PREP_ROLEREq-docno.
DATA : g_line132(132) type c.
Data : g_cores_sender like tline-tdline.
Data : g_user(2).
DATA : g_user_found.
DATA : err_flg.
DATA : tab1_lines like sy-index.
DATA : tab2_lines like sy-index.
DATA : flag1, flag2.
DATA : read_flag.
DATA : disp_flag.
DATA : g_lines1 like sy-index.
DATA  ZROLEREQNO like ZMM_PREP_ROLEREq-docno.
DATA  g_ans_mail.
DATA  : Flag.
DATA  gl_ans.
DATA  g_userid like wa_roles1-userid.
" Begin of <RD1K960036>.
*DATA : flag_start, l_color(2) type I.
DATA : flag_start, l_color type I.
" End of <RD1K960036>.
DATA  g_clines like sy-index..
DATA  corr_code like sy-ucomm.
DATA  g_role_flag.
DATA  g_cursor_line like sy-stepl.
DATA  g_curr_line like sy-stepl.
DATA  g_current_line like sy-stepl.
DATA  g_curr_line_100 like sy-stepl.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  l_old_ok_code.
DATA  g_reset_change.
DATA  l_initial.
DATA  g_list_proc_flag.
DATA  g_ctrl_flag.
DATA  grp_flag.
DATA  loc_flag.
DATA  g_rej_fl.
DATA  g_i like sy-index.
DATA  g_reset_fl.
DATA  g_docno like ZMM_PREP_ROLEREQ-docno..
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
DATA  g_text(40).
DATA  g_att_files like table of SWOTOBJID.
data g_att_files_wa like SWOTOBJID.
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA  g_exit_value.
***************************************
data : g_field_tab like table of dfies.
data : g_field_wa  like dfies.
DATA  approver_flag.
DATA  g_role_name_prev like ZMM_PREP_ROLEREI-ROLE_NAME.
DATA  okcode_dblclk like sy-ucomm.
DATA  g_curfield(60).
DATA  g_i80.
DATA  status_process.
DATA  status_choice.
DATA  CRC_POS(120) type c.
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.

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
