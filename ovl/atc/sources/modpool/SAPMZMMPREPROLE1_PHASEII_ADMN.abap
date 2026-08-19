*--- MAIN PROGRAM: SAPMZMMPREPROLE1_PHASEII_ADMN ---*
*&--------------------------------------------------------------------*
*& Module pool       SAPMZMMPREPROLE                                  *
*&--------------------------------------------------------------------*
*                                                                     *
* Title      : End User Authorisation                                 *
*                                                                     *
* FS No.     : FS-MM-AUTH-004 +++ Delta FS of other modules           *
*                                                                     *
* Author     : Ajit Singh             Date : 20/04/2007               *
*                                                                     *
* Login Id   : CAB_AJIT                                               *
*                                                                     *
* Description: End User Authorisation _ Administration Program        *
*                                                                     *
* Tran. Code : ZICE_ARMS_ADMN                                         *
*                                                                     *
***********************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*1) Changes in INCLUDE MZMMPREPROLE1_PHASEII_ADMNF01.

************************************************************************
INCLUDE MZMMPREPROLE1_PHASEII_ADMNTOP.
*INCLUDE MZMMPREPROLE1_PHASEIITOP.

INCLUDE MZMMPREPROLE1_PHASEII_ADMNO01.
*INCLUDE MZMMPREPROLE1_PHASEIIO01.
                   .
INCLUDE MZMMPREPROLE1_PHASEII_ADMNI01.
*INCLUDE MZMMPREPROLE1_PHASEIII01.
                    .
INCLUDE MZMMPREPROLE1_PHASEII_ADMNF01.
*INCLUDE MZMMPREPROLE1_PHASEIIF01.

AT USER-COMMAND.

case sy-ucomm.

    when 'SEL' .
      perform pick.
      leave list-processing.

    when 'SELALL' .
      perform tick_all.

    when 'DESELALL' .
      perform notick_all.

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

*--- INCLUDE: MZMMPREPROLE1_PHASEII_ADMNF01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.

************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 1240.
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

    data : l_get3(1) TYPE c.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
       TITLEBAR                    = 'BACK'
        TEXT_QUESTION               = 'Data will be lost, Want to quit? '
       DISPLAY_CANCEL_BUTTON       = ' '
       START_COLUMN                = 25
       START_ROW                   = 6
     IMPORTING
       ANSWER                      = l_get3
     EXCEPTIONS
       TEXT_NOT_FOUND              = 1
       OTHERS                      = 2
              .
    IF SY-SUBRC = 0.
       CASE l_get3.
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

  if sy-tcode = 'ZIC_ARMS_CONNECT'.
       old_ok_code = 'DISPLAY'.
       get parameter id 'ZREQNO' field zic_prep_rolereq-docno.
  endif.

  refresh it_tab.
  clear wa_tab.

  if old_ok_code =  'CREATE' or
        old_ok_code = 'CROSSCO' or
        old_ok_code = 'CRCROLES' or
        old_ok_code =  'CHANGE' or
        old_ok_code =  'RELEASE' or
        old_ok_code =  'APPROVE' or
        old_ok_code = 'DISPLAY'  or
        old_ok_code = 'DELETE'.

    move 'CREATE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'CHANGE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'DELETE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'DISPLAY' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'RELEASE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'APPROVE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'SUIM' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'CROSSCO' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'CRCROLES' to wa_tab-fcode.
    append wa_tab to it_tab.
*     move 'ATTACH' to wa_tab-fcode.
*     append wa_tab to it_tab.

  else.

    move 'CHECK' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'LIST' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'SAV' to wa_tab-fcode.
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

  CALL FUNCTION 'ENQUEUE_EZ_IC_PREPHDR'
       EXPORTING
            MODE_ZMM_CDHD  = 'E'
            MANDT          = SY-MANDT
            DOCNO          = zic_prep_rolereq-docno
       EXCEPTIONS
            FOREIGN_LOCK   = 1
            SYSTEM_FAILURE = 2
            OTHERS         = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    MOVE 'Y' to g_lock.
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

  DATA : l_cors like THEAD-TDNAME.

  IF old_ok_code <> 'CREATE' or
     old_ok_code <> 'CROSSCO'.

    refresh lines_cors.

    move zic_prep_rolereq-docno to l_cors.

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
      zic_prep_rolereq-long_text_fl = ''.
    Else.
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
      g_ins_flag = 'X'.

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
  g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

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

***
   data : l_i like sy-index.
     l_i = 36.
    IF <MARK_FIELD> = 'X' and <WA>+l_i(1) = ''.
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
***********************************************************************
  g_tc_lines = <TC>-LINES.
***********************************************************************

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

  if ZIC_PREP_ROLEREQ-CCODE is initial.
    set cursor field 'ZIC_PREP_ROLEREQ-CCODE'.
    message i082(zhelp).
    leave to screen 0.
  endif.
  refresh : it_cond.
  concatenate 'FICTR'  'LIKE'  into g_line separated by
  space.
  concatenate g_line+0(10) '''' ZIC_PREP_ROLEREQ-CCODE '%' ''''  into
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
    if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc or
       wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc2 or
       wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc3 or
       wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc4.
       wa_m_fistb-g_mark = 'X'.
    endif.

   if old_ok_code = 'DISPLAY' or old_ok_code = 'APPROVE'.
      if wa_m_fistb-g_mark = 'X'.
        write: / wa_m_fistb-fictr, wa_m_fistb-bezeich.
      endif.
    else.
      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
            wa_m_fistb-bezeich.
    endif.

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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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

  data l_blank value ''.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc.
             ZIC_PREP_ROLEREQ-fundc = 'X'.
           endif.

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc2.
            clear ZIC_PREP_ROLEREQ-fundc2.
           endif.

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc3.
             clear ZIC_PREP_ROLEREQ-fundc3.
           endif.

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc4.
            clear ZIC_PREP_ROLEREQ-fundc4.
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

      ZIC_PREP_ROLEREQ-FUNDC = wa_m_fistb-FICTR.

    else.

      clear ZIC_PREP_ROLEREQ-FUNDC .

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

  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CRCROLES'.

    perform gen_no.

  endif.

  if old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.

    g_release = ZIC_PREP_ROLEREQ-req_cr_fl.
    g_approve = ZIC_PREP_ROLEREQ-req_app_fl.
    g_approve0 = ZIC_PREP_ROLEREQ-req_app0_fl.
    g_approve1 = ZIC_PREP_ROLEREQ-req_app1_fl.


    select single * from ZIC_PREP_ROLEREQ
                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

    if ZIC_PREP_ROLEREQ-req_cr_fl is initial.
      ZIC_PREP_ROLEREQ-req_cr_fl = g_release.
    endif.
    if ZIC_PREP_ROLEREQ-req_app_fl is initial.
      ZIC_PREP_ROLEREQ-req_app_fl = g_approve.
    endif.
    if ZIC_PREP_ROLEREQ-req_app1_fl is initial.
      ZIC_PREP_ROLEREQ-req_app1_fl = g_approve1.
    endif.

    if ZIC_PREP_ROLEREQ-req_app0_fl is initial.
      ZIC_PREP_ROLEREQ-req_app0_fl = g_approve0.
    endif.


    clear : g_release, g_approve, g_approve0, g_approve1.

    if g_release = 'X' and ( g_approve <> 'X' and
                             g_approve0 <> 'X' and
                             g_approve1 <> 'X' ).

      g_app_rel = 'X'.

    endif.

  endif.

  if old_ok_code = 'RELEASE' and g_lines_rl = 0.
    message i089(zhelp).
  else.
    perform insert_header.
  endif.

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

  ZIC_PREP_ROLEREQ-mandt = sy-mandt.
  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CRCROLES'.
    ZIC_PREP_ROLEREQ-docno = ZDOCNUMB.
  endif.

****************************************
  select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
      a~persk a~sbmod  c~designo c~r_p_cd c~version
    d~sdesig_text as designation d~adesig_text as adesignation
    d~DISC_CD as DISC_CD
      into corresponding fields of table ist_data
       from ( ( pa0001 as a inner join pa9930 as c
       on a~pernr = c~pernr ) inner join zdesignation_rev as d
          on c~designo = d~desig_code and
              c~r_p_cd  = d~r_p_cd and
              c~version = d~version )
           where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                 a~sprps = ' ' and
                 a~endda = '99991231' and
                 c~sprps = ' ' and
                 c~endda = '99991231' .

  if sy-subrc = 0.
    read table ist_data index 1. "#EC CI_NOORDER

    ZIC_PREP_ROLEREQ-PERSA = ist_data-werks .

  endif.
****************************************


  if ZIC_PREP_ROLEREQ-USERIDCR is initial.

    ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.
    ZIC_PREP_ROLEREQ-CR_DATE  = sy-datum.

    clear zusrmst.

    select single * from usr02 where bname =
                               ZIC_PREP_ROLEREQ-useridcr.

    if sy-subrc ne 0.

    else.
*
      clear ist_data.
      refresh ist_data.

      select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
           a~persk a~sbmod  c~designo c~r_p_cd c~version
         d~sdesig_text as designation d~adesig_text as adesignation
           into corresponding fields of table ist_data
      from ( ( pa0001 as a inner join pa9930 as c
            on a~pernr = c~pernr ) inner join zdesignation_rev as d
               on c~designo = d~desig_code and
                   c~r_p_cd  = d~r_p_cd and
                   c~version = d~version )
                where a~pernr = ZIC_PREP_ROLEREQ-USERIDCR and
                      a~sprps = ' ' and
                      a~endda = '99991231' and
                      c~sprps = ' ' and
                      c~endda = '99991231' .

      if sy-subrc = 0.
        read table ist_data index 1. "#EC CI_NOORDER
        ZIC_PREP_ROLEREQ-NAMECR = ist_data-name.
        ZIC_PREP_ROLEREQ-DESIGCR = ist_data-designation.
      endif.

    endif.

    clear : ist_data.
    refresh : ist_data.

  endif.


  if ZIC_PREP_ROLEREQ-USERIDAP is initial.

    if old_ok_code = 'APPROVE' and
          ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
      ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZIC_PREP_ROLEREQ-APP_DATE  = sy-datum.

      if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      endif.

      clear zusrmst.

      select single * from usr02 where bname =
                            ZIC_PREP_ROLEREQ-useridap.

      if sy-subrc ne 0.

      else.

        clear ist_data.
        refresh ist_data.

        select a~pernr a~begda a~endda a~ename as name a~bukrs
                a~werks a~persk a~sbmod  c~designo c~r_p_cd
                c~version d~sdesig_text as designation
                 d~adesig_text as adesignation
             into corresponding fields of table ist_data
             from ( ( pa0001 as a inner join pa9930 as c
       on a~pernr = c~pernr ) inner join zdesignation_rev as d
       on c~designo = d~desig_code and
           c~r_p_cd  = d~r_p_cd and
           c~version = d~version )
        where a~pernr = ZIC_PREP_ROLEREQ-USERIDAP and
              a~sprps = ' ' and
              a~endda = '99991231' and
              c~sprps = ' ' and
              c~endda = '99991231' .

*
        if sy-subrc = 0.
          read table ist_data index 1.  "#EC CI_NOORDER
          ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZIC_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
                 not ZIC_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
            where persa = ist_data-werks.
            if ZIC_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                where userid = ZIC_PREP_ROLEREQ-USERIDAP.
              if sy-subrc = 0.
              else.
                if g_ccode_crossco = t500p-bukrs.
                else.
                  message e112(zhelp).
                endif.
              endif.
            endif.
          endif.
        else.
          message e110(zhelp).
        endif.

      endif.
*    endif.

  elseif old_ok_code = 'APPROVE' and
          ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
*                and
*                      ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZIC_PREP_ROLEREQ-APP_DATE = sy-datum.

      if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      endif.


      select single * from usr02 where bname =
                              ZIC_PREP_ROLEREQ-useridap.
      if sy-subrc ne 0.
*              message e043(zhelp).
      else.

        clear ist_data.
        refresh ist_data.

        select a~pernr a~begda a~endda a~ename as name a~bukrs
                a~werks a~persk a~sbmod  c~designo c~r_p_cd
                c~version d~sdesig_text as designation
                 d~adesig_text as adesignation
                 into corresponding fields of table ist_data
                 from ( ( pa0001 as a inner join pa9930 as c
           on a~pernr = c~pernr ) inner join zdesignation_rev as d
           on c~designo = d~desig_code and
               c~r_p_cd  = d~r_p_cd and
               c~version = d~version )
            where a~pernr = ZIC_PREP_ROLEREQ-USERIDAP and
                  a~sprps = ' ' and
                  a~endda = '99991231' and
                  c~sprps = ' ' and
                  c~endda = '99991231' .

        if sy-subrc = 0.
          read table ist_data index 1. "#EC CI_NOORDER
          ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZIC_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
             not ZIC_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
                where persa = ist_data-werks.
            if ZIC_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                   where userid = ZIC_PREP_ROLEREQ-USERIDAP.
              if sy-subrc = 0.
              else.
                message e112(zhelp).
              endif.
            endif.
          endif.
        else.
          message e110(zhelp).
        endif.
      endif.
**13.02.06

    elseif old_ok_code = 'APPROVE' and
*
                   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

        ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
        ZIC_PREP_ROLEREQ-APP_DATE = sy-datum.

        if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
           ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
        else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
        endif.


        select single * from usr02 where bname =
                                ZIC_PREP_ROLEREQ-useridap.
        if sy-subrc ne 0.
*              message e043(zhelp).
        else.

          clear ist_data.
          refresh ist_data.

          select a~pernr a~begda a~endda a~ename as name a~bukrs
                  a~werks a~persk a~sbmod  c~designo c~r_p_cd
                  c~version d~sdesig_text as designation
                   d~adesig_text as adesignation
                   into corresponding fields of table ist_data
                   from ( ( pa0001 as a inner join pa9930 as c
             on a~pernr = c~pernr ) inner join zdesignation_rev as d
             on c~designo = d~desig_code and
                 c~r_p_cd  = d~r_p_cd and
                 c~version = d~version )
              where a~pernr = ZIC_PREP_ROLEREQ-USERIDAP and
                    a~sprps = ' ' and
                    a~endda = '99991231' and
                    c~sprps = ' ' and
                    c~endda = '99991231' .
*
          if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
            ZIC_PREP_ROLEREQ-DESIGAP = ist_data-designation.
            if ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
               not ZIC_PREP_ROLEREQ-PERSA is initial.
              select single * from t500p
                  where persa = ist_data-werks.
              if ZIC_PREP_ROLEREQ-ccode = t500p-bukrs.
              else.
                select single * from zmm_prep_ex_app
                     where userid = ZIC_PREP_ROLEREQ-USERIDAP.
                if sy-subrc = 0.
                else.
* Check for L1 inserted  05/03/2007
                  if g_user = 'L1'.
                  else.
                    message e112(zhelp).
                  endif.
                endif.
              endif.
            endif.
          else.
            message e110(zhelp).
          endif.
        endif.
      endif.
**13.02.06
    endif.
*endif.
**12.06.06 vivek begin

if not ZIC_PREP_ROLEREQ-USERIDAP is initial and
     old_ok_code = 'APPROVE' and
              ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' or
                   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
                   ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X' ).

**
      select a~pernr a~begda a~endda a~ename as name a~bukrs
                a~werks a~persk a~sbmod  c~designo c~r_p_cd
                c~version d~sdesig_text as designation
                 d~adesig_text as adesignation
             into corresponding fields of table ist_data
             from ( ( pa0001 as a inner join pa9930 as c
       on a~pernr = c~pernr ) inner join zdesignation_rev as d
       on c~designo = d~desig_code and
           c~r_p_cd  = d~r_p_cd and
           c~version = d~version )
        where a~pernr = sy-uname and
              a~sprps = ' ' and
              a~endda = '99991231' and
              c~sprps = ' ' and
              c~endda = '99991231' .

*
        if sy-subrc = 0.
          read table ist_data index 1. "#EC CI_NOORDER
          ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
        endif.

**

     if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
     else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
     endif.
**12.06.06 vivek end
endif.
*****************************
  data l_fundc_no like sy-index.
  clear l_fundc_no.
  loop at it_m_fistb into wa_m_fistb.
    if wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      case l_fundc_no.
        when 2.
          ZIC_PREP_ROLEREQ-fundc2 = wa_m_fistb-fictr.
        when 3.
          ZIC_PREP_ROLEREQ-fundc3 = wa_m_fistb-fictr.
        when 4.
          ZIC_PREP_ROLEREQ-fundc4 = wa_m_fistb-fictr.
        when 5.
          message i078(zhelp).
          okcode_100 = 'MULTI'.
          g_fundc_err_flag = 'X'.
      endcase.
    endif.
  endloop.
*****************************

** CAB_AJIT 20/04/2007

*if ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' or
*   ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X' or
*   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' .
*else.
*    clear ZIC_PREP_ROLEREQ-NAMEAPP.
*    clear ZIC_PREP_ROLEREQ-USERIDAP.
*    clear ZIC_PREP_ROLEREQ-APP_DATE.
*endif.

****

*****
  if g_fundc_err_flag <> 'X'.

    if old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'.
      g_comm_fl = 'X'.
      if g_lines_2 <> 0.
        clear ZIC_PREP_ROLEREQ-comm_fl.
        clear g_lines_2.
** Status New changed to IF
        ZIC_PREP_ROLEREQ-status = 'IF'.
      endif.
    endif.

*Begin of <RD1K963151>.
data : new_status  like  ZIC_PREP_ROLEREQ-status.
      move ZIC_PREP_ROLEREQ-status to new_status.
*End of <RD1K963151>.
   if old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-comm_fl = 'X'.

** Status New changed to IR
      ZIC_PREP_ROLEREQ-status = 'IR'.
      clear ZIC_PREP_ROLEREQ-comm_fl.
    endif.

*Begin of <RD1K963151>.
   if old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-comm_fl = ' ' and  SY-UCOMM = 'SAV'.
   ZIC_PREP_ROLEREQ-status = new_status.
   CLEAR new_status.
   endif.
*End of <RD1K963151>.
    if old_ok_code = 'CROSSCO'.
      ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    endif.

    if old_ok_code = 'CRCROLES'.
      ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    endif.

    if ZIC_PREP_ROLEREQ-CCODE is initial.
      message e142(zhelp).
    endif.

    if G_MULT_MODULE_FL = 'X' and old_ok_code = 'CHANGE'.
       ZIC_PREP_ROLEREQ-MULTIMODULE_FL = 'X'.
    endif.



    modify ZIC_PREP_ROLEREQ from ZIC_PREP_ROLEREQ.


    if sy-subrc = 0.

      if g_app_rel = 'X'.

        clear g_app_rel.

      elseif
      ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X' )
      or ( old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-comm_fl = 'X' ).

      else.

        g_approver_level = 'L3'.

** Module wise check & insertion

    if g_reset_fl <> 'X'.

      case moduleid.

       when 'MM'.

        Perform insert_items.

       when 'PM'.

        Perform insert_items_pm.

       when 'PS'.

        Perform insert_items_ps.

       when 'PP'.

        Perform insert_items_pp.

       when 'SD'.

        Perform insert_items_sd.

       when 'QM'.

        Perform insert_items_qm.

      endcase.

   endif.

      endif.

   if g_reset_fl <> 'X'.
      Perform items_approval_check.
   endif.

****Saving the long text.                              *****

      IF ( old_ok_code = 'CREATE' ) or
      ( old_ok_code = 'CROSSCO' ) or ( OLD_OK_CODE = 'CHANGE' )
          or ( OLD_OK_CODE = 'CRCROLES' )
          or ( OLD_OK_CODE = 'RELEASE' )
          or ( OLD_OK_CODE = 'APPROVE' ).

        perform save_cors_text.
      elseif g_comm_fl = 'X'.
        perform save_cors_text.
        clear g_comm_fl.
      ENDIF.

**** Check if moduleid has changed
**13/04/07
   if module_changed_flag = 'X' and ( old_ok_code = 'CHANGE' or
      old_ok_code = 'APPROVE' ).
      moduleid = new_moduleid.
      clear new_moduleid.
      clear module_changed_flag.
      if old_ok_code <> 'APPROVE'.
        old_ok_code = 'CHANGE'.
      endif.
      perform clear_for_newmodule.
   else.
      perform clear.
   endif.
****
*   if module_changed_flag = 'X' and old_ok_code = 'APPROVE'.
*      moduleid = new_moduleid.
*      clear new_moduleid.
*      clear module_changed_flag.
*      old_ok_code = 'CHANGE'.
*      perform clear_for_newmodule.
*   else.
*      perform clear.
*   endif.
****
      perform unlock_record.
      if g_reset_fl = 'X'.
        clear g_reset_fl.
        clear set_disc_mm_flag.
        clear set_disc_fi_flag.
        clear g_hd_copied.
**13/04/07
        if old_ok_code = 'APPROVE'.
        else.
          old_ok_code = 'CHANGE'.
        endif.
        ZIC_PREP_ROLEREQ-docno = g_docno.
      endif.

*      ZIC_PREP_ROLEREQ-crc_fl = g_crc_fl.
*      clear g_crc_fl.
      call screen 100.

    endif.

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

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab.

  sort g_TABLCTRL110_itab
  by role_name plant grp  sloc receipt_loc approver.

  delete adjacent duplicates from g_TABLCTRL110_itab
    comparing role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

  loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa.

    move-corresponding g_TABLCTRL110_wa to wa_itemtab.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

    Perform check_items_save.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

***added g_reset_fl to check resetting & no rollback
  if g_lines_rl = 0 .
    rollback work.
    if old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                  moduleid = moduleid.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid..
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

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
     old_ok_code = 'CROSSCO' or
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
*                 DEFAULTOPTION = 'N'
*         IMPORTING
*              ANSWER         = l_choice1.

DATA : l_get4(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'EXIT '
    TEXT_QUESTION               = 'Data will be lost, Want to quit? '
   DEFAULT_BUTTON              = '2'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = l_get4
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE l_get4.
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
      call screen 100.
    else.
    ENDIF.

  else.

    perform clear.
    perform unlock_record.
    call screen 100.

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

  CALL FUNCTION 'DEQUEUE_EZ_IC_PREPHDR'
       EXPORTING
            MODE_ZIC_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = ZIC_PREP_ROLEREQ-docno.

  clear g_lock.

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
  refresh : g_TABLCTRL110_itab[].
  clear   : g_TABLCTRL110_itab.
  refresh : g_TABLCTRL111_itab[].
  clear   : g_TABLCTRL111_itab.
  refresh : g_TABLCTRL112_itab[].
  clear   : g_TABLCTRL112_itab.
  clear   : sy-ucomm.
  clear   : g_curr_line.
  clear set_disc_mm_flag.
  clear set_disc_fi_flag.
  clear   : zic_prep_rolerei, ZIC_PREP_ROLEREQ.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].
  clear   : t500p-name1.
  clear   : CRC_CHECK_FL.
  clear   : help_list_flag.
  refresh : it_m_fistb.
  clear   : moduleid.

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

  if ( old_ok_code = 'CREATE' )
   or ( old_ok_code = 'CROSSCO' )
   or ( old_ok_code = 'CRCROLES' )
   or ( old_ok_code = 'CHANGE' )
   or ( old_ok_code = 'RELEASE' )
   or ( OLD_OK_CODE = 'APPROVE' )
  or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'
       and  ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

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
  If old_ok_code <> 'CREATE' or
     old_ok_code = 'CROSSCO' .
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

  if ( old_ok_code = 'CREATE' )
   or ( old_ok_code = 'CROSSCO' )
   or ( old_ok_code = 'CRCROLES' )
   or ( old_ok_code = 'CHANGE' )
   or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'
       and  ZIC_PREP_ROLEREQ-STATUS <> 'C').
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
  move ZIC_PREP_ROLEREQ-docno to l_theader-tdname.
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
  endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L4'.

  if sy-subrc = 0.
    g_user = 'L3'.
    zic_prep_rolereq-radio_fl = 'X'.
    g_l4 = 'X'.
    check 1 = 2.
  Endif.

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

  if old_ok_code = 'APPROVE'.

     select single * from zic_prep_rolerei where moduleid = 'MM'
        and docno = zic_prep_rolereq-docno.

     if sy-subrc = 0.
        modulemm_fl = 'X'.
     endif.

     if g_user = 'L1' or
        g_user = 'IM' or
        ( g_user = 'L3' and g_l4 <> 'X' ).
     elseif modulemm_fl <> 'X' and g_l4 = 'X'.
     else.
          message i131(zhelp).
          clear old_ok_code.
          call screen 100.
     endif.

     if g_user = 'L1' and
        ( ZIC_PREP_ROLEREQ-req_app0_fl = 'X' or
          ZIC_PREP_ROLEREQ-req_app_fl = 'X' ).
        message i132(zhelp).
        clear old_ok_code.
        call screen 100.
     endif.

  endif.

*  if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.
*
*    if  ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.
*    else.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*              TEXTLINE1  = 'Not authorised to use this document- not
*yours '.
**                     message i046(zhelp).
*      perform clear.
*      call screen 100.
*    endif.
*
*  endif.

*  if old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-REQ_CR_FL = 'X'.
*
*    if ZIC_PREP_ROLEREQ-status = 'IF' or
*          ZIC_PREP_ROLEREQ-status = 'PC' or
*          ZIC_PREP_ROLEREQ-status = 'C'.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TEXTLINE1 = 'Request under process / completed can''t
*change/reset'.
*
**                message e065(zhelp).
*      perform clear.
*      call screen 100.
*
*    else.
*      g_reset_fl = ZIC_PREP_ROLEREQ-REQ_CR_FL.
*      g_docno = ZIC_PREP_ROLEREQ-docno.
*      perform verify.
*  endif.
*  endif.

  if old_ok_code = 'APPROVE' and
                    ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    if g_user = 'IM' or g_user = 'L1'.
    else.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'This requires approval of I/C MM'.

*               message e048(zhelp).
      perform clear.
      call screen 100.
    endif.
  endif.

  if old_ok_code = 'RELEASE' and ZIC_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
         EXPORTING
              TEXTLINE1 = 'Request already released by creator'.

*          message e053(zhelp).
    perform clear.
    call screen 100.

  endif.

  if old_ok_code = 'APPROVE'.

    if g_user = 'L1' and ZIC_PREP_ROLEREQ-REQ_APP1_FL = ' ' and
       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.

*                   message e051(zhelp).
      perform clear.
      call screen 100.

    endif.

    if ( g_user = 'IM' or g_user = 'L3' ) and
                          ZIC_PREP_ROLEREQ-REQ_APP_FL = ' ' and
       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.
*                   message e051(zhelp)..
      perform clear.
      call screen 100.

    endif.

      if  ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
          ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request already approved'.

      perform clear.
      call screen 100.

    endif.

  endif.

*  if ( ZIC_PREP_ROLEREQ-status = 'IF' or
*      ZIC_PREP_ROLEREQ-status  = 'C' )
*      and old_ok_code <> 'DISPLAY'.
*    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*       EXPORTING
*              TEXTLINE1   = 'Request can not  be  changed, Can only be
*displayed'.
*
**              message e079(zhelp).
**               perform clear.
*    old_ok_code = 'DISPLAY'.
*    call screen 100.
*
*  endif.

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

  data : l_docno like zmm_prep_rolereq-docno.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZIC_PREP_ROLEREQ-FUNDC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  if sy-subrc <> 0.
     message i166(zhelp).
     g_error_fundc = 'X'.
     call screen 100.
  endif.

  if old_ok_code = 'CHANGE' or
     old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.

     select single docno from zic_prep_rolereq
                     into l_docno where docno = zic_prep_rolereq-docno.

     if sy-subrc <> 0.
       message i167(zhelp).
       g_error_fundc = 'X'.
       call screen 100.
     endif.

  endif.

  if g_val_err = 'X'.
     clear g_val_err.
     message i118(zhelp).
     call screen 100.
  endif.

  if zic_prep_rolerei-rej_fl = ''.

    if old_ok_code = 'APPROVE' and
                      ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
      if g_user = 'IM' or g_user = 'L1'.
      else.
        message e048(zhelp).
      endif.
    endif.

  endif.

 perform check_tel.

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

    data : l_choice.

" Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Are you sure, you want to delete the Document? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.

data : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = ' '
    TEXT_QUESTION               = 'Are you sure, you want to delete the Document? '
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = l_get5
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE l_get5.
         WHEN '1'.
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
If l_choice = 'J'.
      clear l_choice.

**************************************

  ZIC_PREP_ROLEREQ-mandt = sy-mandt.

  delete ZIC_PREP_ROLEREQ from ZIC_PREP_ROLEREQ.

  if sy-subrc = 0.

    Perform delete_items.


    if ZIC_PREP_ROLEREQ-long_text_fl <> ''.
      perform delete_cors_text.
    endif.

    perform clear.
    perform unlock_record.
    call screen 100.

  else.

    message i057(zhelp) with ZIC_PREP_ROLEREQ-docno.

  endif.

else.

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

  delete zic_prep_rolerei from table ist_itemtab.

  if sy-subrc = 0.
    message i120(zhelp) with ZIC_PREP_ROLEREQ-docno.
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

  l_name = ZIC_PREP_ROLEREQ-docno.

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
*      EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be cancelled? '
*           TITEL          = 'RESET'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
data : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'RESET'
    TEXT_QUESTION               = 'Request already released Flags will be cancelled? '
   DEFAULT_BUTTON              = '2'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = l_get5
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
.

IF SY-SUBRC = 0.
       CASE l_get5.
         WHEN '1'.
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

  If l_choice = 'J'.

    clear ZIC_PREP_ROLEREQ-req_cr_fl.
    clear ZIC_PREP_ROLEREQ-req_app_fl.
    clear ZIC_PREP_ROLEREQ-req_app0_fl.
    clear ZIC_PREP_ROLEREQ-req_app1_fl.
    ZIC_PREP_ROLEREQ-status = 'IC'.
    perform save_request.
**20/03/2006
    g_app_rel = 'X'.
    clear l_choice.

  else.

    perform clear.
    perform unlock_record.
    call screen 100.

  endif.

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
  if old_ok_code <> 'DISPLAY' .

   if old_ok_code = 'CRCROLES' or ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.

     if zmm_prep_rolecrc+0(1) = 'C'.

       if zmm_prep_rolecrc-plant = 'X' and
           wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-p_grp = 'X' and
           wa_itemtab-grp is initial.
          g_field = 'ZIC_PREP_ROLEREI-P_GRP'.
          rollback work.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-app_level = 'X' and
          wa_itemtab-approver is initial.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
**
      else.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       rollback work.
       message i197(zhelp).
       clear okcode_100.
       call screen 100.
      endif.

    endif.

   else.

    select single * from zmm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zmm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-p_grp = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE'  or
                    old_ok_code = 'CREATE'  or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-grp is initial.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          rollback work.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-s_loc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sloc is initial.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          rollback work.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-r_loc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-receipt_loc is initial.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          rollback work.
          message i095(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-app_level = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-approver is initial.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

    endif.

   endif.

  endif.
**  if wa_itemtab-rej_fl is initial.
**** Header level changes for integration
**    perform validate_role_approval_level.
**  endif.
** Line item changes for integration call diffrent subs ( def 110 )
  perform validate_lineitem_datax.
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

  data : l_choice.
  clear l_choice.

" Begin of <RD1K960036>.

*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'If u cancel release, u can change data else go in display mode'
*               TEXTLINE2      = '& just do correspondence without cancelling release'
*           TITEL          = 'Do you want to cancel release?'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.

data : l_get6(1)  TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Do you want to cancel release? '
    TEXT_QUESTION               = 'If u cancel release, u can change data else go in display mode & just do correspondence without cancelling release'
   DEFAULT_BUTTON              = '2'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = l_get6
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE l_get6.
         WHEN '1'.
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
  If l_choice = 'J'.

    old_ok_code = 'CHANGE'.
    clear l_choice.

  else.

    old_ok_code = 'DISPLAY'.
    clear l_choice.

  endif.

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

  if    ( ( old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
         old_ok_code = 'DELETE'
         or old_ok_code = 'RELEASE' or OLD_OK_CODE = 'APPROVE' )
         and g_hd_copied = 'X' )
         or ( old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' ).
    data : tel_len type i.
    tel_len = strlen( ZIC_PREP_ROLEREQ-TELNO ).
    if  ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
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
*&      Form  validate_lineitem_datax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax.

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa.

  if old_ok_code = 'CRCROLES' or ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    select single * from zmm_prep_rolecrc where role_type =
                    g_TABLCTRL110_wa-role_name.

    if sy-subrc <> 0.
       rollback work.
       message e117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    g_TABLCTRL110_wa-role_name.
    if sy-subrc <> 0.
       rollback work.
       message e118(zhelp).
    endif.

  endif.

**********************************************************

if old_ok_code <> 'DISPLAY'.

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if ZIC_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           rollback work.
           message e081(zhelp) with g_TABLCTRL110_wa-role_name.
         endif.

   endif.

 endif.

*  endif.

  if not g_TABLCTRL110_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZIC_PREP_ROLEREQ-CCODE
                                    and werks = g_TABLCTRL110_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABLCTRL110_wa-role_name.

      endif.

   endif.


************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
*  clear   : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
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
 if g_TABLCTRL110_wa-role_name = 'M6' or
     g_TABLCTRL110_wa-role_name = 'M7' or
     g_TABLCTRL110_wa-role_name = 'M8'.
    concatenate '%' G_CCODE '%' into g_line1.
    select * from t024 into table it_t024 where TELFX like g_line1.
  else.
    if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      concatenate '%' G_CCODE '%' 'IND' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    else.
      concatenate  '%' G_CCODE '%' 'MM' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    endif.
   endif.

**
   if  not g_TABLCTRL110_wa-GRP is initial.

       loop at it_t024 into wa_t024.

           if g_TABLCTRL110_wa-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          rollback work.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( g_TABLCTRL110_wa-role_name = 'M13' or
   g_TABLCTRL110_wa-role_name = 'M14' or
    g_TABLCTRL110_wa-role_name = 'M16' or
    g_TABLCTRL110_wa-role_name = 'M18' or
    g_TABLCTRL110_wa-role_name = 'M19' ) and
    not g_TABLCTRL110_wa-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = g_TABLCTRL110_wa-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
       rollback work.
       message e074(zhelp).

    endif.

endif.

   if ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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

    if  not g_TABLCTRL110_wa-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if g_TABLCTRL110_wa-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          rollback work.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( g_TABLCTRL110_wa-role_name = 'M12' or
       g_TABLCTRL110_wa-role_name = 'M17' ) and
       not g_TABLCTRL110_wa-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if g_TABLCTRL110_wa-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if g_TABLCTRL110_wa-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not g_TABLCTRL110_wa-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if g_TABLCTRL110_wa-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
           rollback work.
           message e075(zhelp).

       endif.

    endif.


*****************************

endif.

endloop.

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

clear g_att_files_wa.
refresh g_att_files.

g_att_files_wa-LOGSYS = ZIC_PREP_ROLEREQ-DOCNO+2(10).
g_att_files_wa-objtype = 'ATT'.
g_att_files_wa-objkey = '01'.

append g_att_files_wa to g_att_files.

CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
  EXPORTING
    ATTACHMENT_DATA           = ''
    ATTACHMENT_TYPE           = 'DOC'
  TABLES
    APPLICATION_OBJECTS       = g_att_files
          .


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

g_att_files_wa-LOGSYS = ZIC_PREP_ROLEREQ-DOCNO+2(10).
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
   TITEL              = 'Choosing Location '
   TEXTLINE1          = 'It is understood that user has joined at new location & HR Data'
   TEXTLINE2          = 'is updated. Please choose appropriate current location?'
*   START_COLUMN       = 25
*   START_ROW          = 6
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
  select * from ZIC_PREP_ROLEREI into table ist_itemtab
  where docno = zic_prep_rolereq-docno.
  loop at ist_itemtab into wa_itemtab.
  if wa_itemtab-rej_fl is initial.
** Header level changes for integration
    perform validate_role_approval_level.
  endif.
  endloop.
  clear ist_itemtab.
  refresh ist_itemtab[].
  clear wa_itemtab.
**      if sy-subrc = 0.
** Messages to be checked modulewise in sub
        perform clear1.
        if old_ok_code = 'CROSSCO' or
              ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.

              if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CROSSCO' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.

               if old_ok_code = 'APPROVE' or
                  ZIC_PREP_ROLEREQ-status = 'IF'.
                  perform popup_approve_message.
               endif.

               perform pop_up_crossco_message.          .
*          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
               set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.

          else.
            if old_ok_code = 'CRCROLES' or
              ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
               if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CRCROLES' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.
               if old_ok_code = 'APPROVE' or
                  ZIC_PREP_ROLEREQ-status = 'IF'.
                    perform popup_approve_message.
               endif.
               perform pop_up_crc_message.
*              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
               g_crc_fl = 'X'.
            else.
              if old_ok_code = 'RELEASE'.
                perform popup_release_message.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'APPROVE'.
** 13/04/07
                if module_changed_flag <> 'X'.
.                 perform popup_approve_message.
                  message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
                endif.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
*                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'CREATE' or old_ok_code =
'CHANGE'.
** 13/04/07
                if module_changed_flag <> 'X'.
                  perform popup_release_message1.
                  message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
                endif.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
*                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              elseif ZIC_PREP_ROLEREQ-status = 'IF'.
                perform popup_approve_message.
              else.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              endif.
            endif.
        endif.
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
   TITEL              = 'CRC Authorizations '
   TEXTLINE1          = 'Please attach the scanned order copy with the request or '
   TEXTLINE2          = 'Please send order copy by fax to Head-ICE '
*   START_COLUMN       = 25
*   START_ROW          = 6
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
   TITEL              = 'Cross Company Authorisations '
   TEXTLINE1          = 'Please attach the scanned order copy with the request or '
   TEXTLINE2          = 'Please send order copy by fax to Head-ICE '
*   START_COLUMN       = 25
*   START_ROW          = 6
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

** Check approval module wise & line item wise

  select single * from ZMM_PREP_ROLEGRP
       where role_type = wa_itemtab-role_name.

if sy-subrc = 0.

  if ZMM_PREP_ROLEGRP-approver1 = 'L3' and
               g_approver_level = 'L3'.

  elseif ZMM_PREP_ROLEGRP-approver1 = 'IM' and
               g_approver_level = 'L3'.
               g_approver_level = 'IM'.
  elseif  ZMM_PREP_ROLEGRP-approver1 = 'L1' and
               ( g_approver_level = 'L3' or
                 g_approver_level = 'IM' ).
                 g_approver_level = 'L1'.
  endif.

endif.

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

  if g_approver_level = 'IM'.
     g_approver_level = 'I/C MM'.
  endif.

  concatenate 'Kindly get the request approved by competent authority: '
  g_approver_level ' or above' into g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Approval Requirement'
     TEXTLINE1          =  g_approve_text
     TEXTLINE2          = 'Request for authorization will be routed to ICE core team only '
     TEXTLINE3          = 'after requisite approval '
*     START_COLUMN       = 15
*     START_ROW          = 6
            .
  clear : g_approver_level, g_approve_text.
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
     TITEL              = 'Request Processing'
     TEXTLINE1          = 'The request will now be processed by ICE core  team & '
     TEXTLINE2          = 'user will get updated message once the request is processed '
*     START_COLUMN       = 15
*     START_ROW          = 6
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
if zic_prep_rolereq-status <> 'C'.
**
CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Request Status IR'
     TEXTLINE1          =  'Please go to display mode & reply the query of the ICE core team in '
     TEXTLINE2          = 'correspondence  &  save the request.  No re-release or approval reqd.'
     TEXTLINE3          = 'The request will go directly to ICE core team for further processing.'.
old_ok_code = 'DISPLAY'.
**
else.
CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Request Status C'
     TEXTLINE1          =  'Request is closed, you can not change anything now'
     TEXTLINE2          =  'No more processing of the request can be done'.
old_ok_code = 'DISPLAY'.
**
endif.
ENDFORM.                    " verify2
*&---------------------------------------------------------------------*
*&      Form  popup_release_message1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_release_message1.
if g_approver_level = 'IM'.
     g_approver_level = 'I/C MM'.
  endif.

  concatenate g_approver_level ' or above. Request  for  authorization will be routed to ICE core' into g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Approval Requirement'
     TEXTLINE1          =  'Kindly self release the  request  &  get it approved by competent authority:'
     TEXTLINE2          = g_approve_text
     TEXTLINE3          = 'team only after requisite approval '
*     START_COLUMN       = 15
*     START_ROW          = 6
            .
  clear : g_approver_level, g_approve_text.
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

  clear   : help_list_flag.
  refresh : it_m_fistb.
  clear   : dynnr.

ENDFORM.                    " clear1
*&---------------------------------------------------------------------*
*&      Form  insert_items_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pm.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab.

  sort g_TABLCTRL111_itab
  by role_name plant shop_no.

  delete adjacent duplicates from g_TABLCTRL111_itab
    comparing role_name plant rej_fl shop_no.

  loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa.

    move-corresponding g_TABLCTRL111_wa to wa_itemtab.

*    Perform check_items_save.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

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
**              elseif old_ok_code = 'CREATE' or old_ok_code = 'CHANGE'.
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

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zpm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zpm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zpm_prep_roledes-shop_no = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-shop_no is initial.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          rollback work.
          message i095(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if ( zic_prep_rolereq-ccode = 'BDW' or
        zic_prep_rolereq-ccode = 'SBW' ).

        if  ( zpm_prep_roledes-role_type = 'PM14' or
            zpm_prep_roledes-role_type = 'PM15' or
            zpm_prep_roledes-role_type = 'PM16' ).

        else.
          message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
          ZIC_PREP_ROLEREQ-ccode .
        endif.
     endif.

   endif.

 endif.
*
**
  perform validate_lineitem_datax11.

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

  case moduleid.

     when 'MM'.

      Perform check_items_save.

     when 'PM'.

      Perform check_items_save_pm.

     when 'PS'.

      Perform check_items_save_ps.

     when 'PP'.

      Perform check_items_save_pp.

     when 'SD'.

      Perform check_items_save_sd.

     when 'QM'.

      Perform check_items_save_qm.

    endcase.

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

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not g_TABLCTRL111_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZIC_PREP_ROLEREQ-CCODE
                                    and werks = g_TABLCTRL111_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABLCTRL111_wa-role_name.

      endif.

   endif.

endif.

endloop.

ENDFORM.                    " validate_lineitem_datax11
*&---------------------------------------------------------------------*
*&      Form  crc_module_checking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM crc_module_checking.
  if old_ok_code = 'CRCROLES' or zic_prep_rolereq-CRC_FL = 'X'.
     moduleid = 'MM'.
  endif.
ENDFORM.                    " crc_module_checking
*&---------------------------------------------------------------------*
*&      Form  check_module_status_mm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_mm.
  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     mm_not_ok = 'X'.
  endif.
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
  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     pm_not_ok = 'X'.
  endif.
ENDFORM.                    " check_module_status_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_app
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_app.

" Begin of <RD1K960036>.

*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Are you sure, you want to approve the Document? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = g_choice_app.

data : l_get(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    TEXT_QUESTION               = 'Are you sure, you want to approve the Document? '
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
       CASE L_get.
         WHEN '1'.
           MOVE 'J' TO g_choice_app.
           WHEN '2'.
             MOVE 'N' TO g_choice_app.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

ENDFORM.                    " confirm_app
*&---------------------------------------------------------------------*
*&      Form  insert_items_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_ps.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL112_itab
  by role_name service project location asset basin.

  delete adjacent duplicates from g_TABLCTRL112_itab
    comparing role_name rej_fl service project location
    asset basin.

  loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa.

    move-corresponding g_TABLCTRL112_wa to wa_itemtab.

*    Perform check_items_save.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

  if not ZIC_PREP_ROLEREI-SERVICE is initial and
        ZIC_PREP_ROLEREI-ROLE_NAME is initial.
  message e185(zhelp).
  endif.

  if old_ok_code <> 'DISPLAY' .

    select single * from zps_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zps_prep_roledes-service = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-service is initial.
          g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
          rollback work.
          message i174(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zps_prep_roledes-project = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-project is initial.
          g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
          rollback work.
          message i175(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zps_prep_roledes-location = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-location is initial.
          g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
          rollback work.
          message i176(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zps_prep_roledes-asset = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-asset is initial.
          g_field = 'ZIC_PREP_ROLEREI-ASSET'.
          rollback work.
          message i177(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zps_prep_roledes-basin = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-basin is initial.
          g_field = 'ZIC_PREP_ROLEREI-BASIN'.
          rollback work.
          message i178(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

*****
   endif.

 endif.
*
**
  perform validate_lineitem_datax12.

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

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not g_TABLCTRL112_wa-service is initial.

       select single * from zps_prep_service
               where service = g_TABLCTRL112_wa-service.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
            rollback work.
            message e179(zhelp) with g_TABLCTRL112_wa-role_name.

      endif.

   endif.

   if not g_TABLCTRL112_wa-project is initial.

       select single * from zps_prep_project
            where service = g_TABLCTRL112_wa-service and
            project = g_TABLCTRL112_wa-project.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
            rollback work.
            message e180(zhelp) with g_TABLCTRL112_wa-role_name.

      endif.

   endif.

   if not g_TABLCTRL112_wa-location is initial.

       select single * from zps_prep_loca
            where ccode = ZIC_PREP_ROLEREQ-CCODE and
                  location = g_TABLCTRL112_wa-location and
                  service = g_TABLCTRL112_wa-service.

       if sy-subrc <> 0.
             g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
            rollback work.
            g_i = g_curr_line.
            message e181(zhelp) with g_TABLCTRL112_wa-role_name.
      endif.

    endif.

    if not g_TABLCTRL112_wa-basin is initial.

     if g_TABLCTRL112_wa-basin <> ZIC_PREP_ROLEREQ-CCODE and
            g_TABLCTRL112_wa-basin <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-BASIN'.
            rollback work.
            message e181(zhelp) with g_TABLCTRL112_wa-role_name.

      endif.

    endif.


      if not g_TABLCTRL112_wa-asset is initial.

       if ZIC_PREP_ROLEREQ-CCODE = 'MUM'.

         if g_TABLCTRL112_wa-asset <> 'ALL'.
           select single * from zps_prep_asst_ex
                  where ccode = ZIC_PREP_ROLEREQ-CCODE and
                    asset = g_TABLCTRL112_wa-asset.
         endif.
         if sy-subrc <> 0 and zps_prep_asst_ex-asset <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET'.
            rollback work.
            message e182(zhelp) with g_TABLCTRL112_wa-role_name.

        endif.

       else.

        if g_TABLCTRL112_wa-asset <> ZIC_PREP_ROLEREQ-CCODE and
            g_TABLCTRL112_wa-asset <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET'.
            rollback work.
            message e182(zhelp) with g_TABLCTRL112_wa-role_name.

        endif.
       endif.
      endif.
************
endif.

endloop.

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
 if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     ps_not_ok = 'X'.
  endif.
ENDFORM.                    " check_module_status_ps
*&---------------------------------------------------------------------*
*&      Form  clear_for_newmodule
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_for_newmodule.

  perform destroy_ctrl.

  clear   : okcode_100, err_flg.
  refresh : g_TABLCTRL110_itab[].
  clear   : g_TABLCTRL110_itab.
  refresh : g_TABLCTRL111_itab[].
  clear   : g_TABLCTRL111_itab.
  refresh : g_TABLCTRL112_itab[].
  clear   : g_TABLCTRL112_itab.
  clear   : sy-ucomm.
  clear   : g_curr_line.
  clear set_disc_mm_flag.
  clear set_disc_fi_flag.
  clear   : zic_prep_rolerei.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].
  clear   : t500p-name1.
  clear   : CRC_CHECK_FL.
  clear   : help_list_flag.
  refresh : it_m_fistb.
  clear   : g_hd_copied.

ENDFORM.                    " clear_for_newmodule
*&---------------------------------------------------------------------*
*&      Form  insert_items_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pp.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL113_itab
  by role_name plant sloc res ctf_sloc.

  delete adjacent duplicates from g_TABLCTRL113_itab
    comparing role_name rej_fl plant sloc res
    ctf_sloc.

  loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa.

    move-corresponding g_TABLCTRL113_wa to wa_itemtab.

*    Perform check_items_save.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zpp_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zpp_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i074(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zpp_prep_roledes-sloc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sloc is initial.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          rollback work.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zpp_prep_roledes-res = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-res is initial.
          g_field = 'ZIC_PREP_ROLEREI-RES'.
          rollback work.
          message i184(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zpp_prep_roledes-ctf_sloc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-ctf_sloc is initial.
          g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
          rollback work.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

*****
   endif.

 endif.
*
**
  perform validate_lineitem_datax13.


ENDFORM.                    " check_items_save_pp
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_pp.

  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     pp_not_ok = 'X'.
  endif.

ENDFORM.                    " check_module_status_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_sd.

DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL114_itab
  by role_name sale_org div plant ship_point.

  delete adjacent duplicates from g_TABLCTRL114_itab
    comparing role_name rej_fl sale_org div plant ship_point.

  loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa.

    clear wa_itemtab.

    move-corresponding g_TABLCTRL114_wa to wa_itemtab.

*    Perform check_items_save.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zsd_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zsd_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i074(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zsd_prep_roledes-sale_org = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sale_org is initial.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          rollback work.
          message i190(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zsd_prep_roledes-div = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-div is initial.
          g_field = 'ZIC_PREP_ROLEREI-DIV'.
          rollback work.
          message i194(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zsd_prep_roledes-ship_point = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-ship_point is initial.
          g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          rollback work.
          message i191(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

*****
   endif.

 endif.
*
**
  perform validate_lineitem_datax14.


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

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

   select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
   if sy-subrc = 0.

   select single * from zhelp_pproles1 into corresponding fields of
                        zhelp_pproles1 where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.

   if sy-subrc <> 0.

   select single * from ZPP_PREP_GENERIC into corresponding fields of
                        ZPP_PREP_GENERIC where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            rollback work.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   else.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
   endif.

   endif.

   if not ZIC_PREP_ROLEREI-SLOC is initial.

    select single * from t001l into corresponding fields of
             it_t001l  where werks = ZIC_PREP_ROLEREI-PLANT
             and lgort = ZIC_PREP_ROLEREI-SLOC.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
            g_i = g_curr_line_113.
            rollback work.
            message e073(zhelp) with ZIC_PREP_ROLEREI-sloc.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-RES is initial.

    select single * from zpp_prep_res into corresponding fields of
             it_res  where role_type = ZIC_PREP_ROLEREI-ROLE_NAME
             and
             plant = ZIC_PREP_ROLEREI-PLANT
             and
             res = ZIC_PREP_ROLEREI-RES.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-RES'.
            g_i = g_curr_line_113.
            rollback work.
            message e183(zhelp) with ZIC_PREP_ROLEREI-res.

      endif.

   endif.


    if not ZIC_PREP_ROLEREI-ctf_sloc is initial.

       select single * from ZPP_PREP_DROLEEX where role_type =
         ZIC_PREP_ROLEREI-ROLE_NAME
         and plant = ZIC_PREP_ROLEREI-PLANT
         and sloc = ZIC_PREP_ROLEREI-SLOC
         and ctf_sloc = ZIC_PREP_ROLEREI-CTF_SLOC.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
            g_i = g_curr_line.
            rollback work.
            message e073(zhelp) with ZIC_PREP_ROLEREI-ctf_sloc.

      endif.

    endif.
****
endif.

endloop.

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

  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     sd_not_ok = 'X'.
  endif.

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

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not ZIC_PREP_ROLEREI-PLANT is initial.

  select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_114.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-SALE_ORG is initial.

    select single * from tvko client specified into corresponding fields
             of it_tvko  where mandt = sy-mandt and
             bukrs =  zic_prep_rolereq-ccode and
             vkorg = ZIC_PREP_ROLEREI-SALE_ORG.

      if sy-subrc <> 0 and ZIC_PREP_ROLEREI-SALE_ORG <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            g_i = g_curr_line_114.
            message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
      else.
           if zic_prep_rolereq-ccode = 'MUM' and
              ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' and
              ZIC_PREP_ROLEREI-SALE_ORG <> 'MUMPHPOP'.
              g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
              g_i = g_curr_line_114.
              message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
           endif.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-DIV is initial.

    select single * from tvkos client specified into corresponding
             fields of it_tvkos  where mandt = sy-mandt and
             vkorg =  ZIC_PREP_ROLEREI-SALE_ORG and
             spart =  ZIC_PREP_ROLEREI-DIV.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-DIV'.
            g_i = g_curr_line_114.
            message e187(zhelp) with ZIC_PREP_ROLEREI-DIV.

      endif.

   endif.


   if not ZIC_PREP_ROLEREI-SHIP_POINT is initial.

       select single * from tvswz into corresponding fields of
             it_tvswz  where werks = ZIC_PREP_ROLEREI-PLANT and
             vstel = ZIC_PREP_ROLEREI-SHIP_POINT.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
            g_i = g_curr_line.
            message e188(zhelp) with ZIC_PREP_ROLEREI-SHIP_POINT.

      endif.

    endif.

endif.

endloop.

ENDFORM.                    " validate_lineitem_datax14
*&---------------------------------------------------------------------*
*&      Form  insert_items_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_qm.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL115_itab
  by role_name plant asset_qm.

  delete adjacent duplicates from g_TABLCTRL115_itab
    comparing role_name rej_fl plant asset_qm.

  loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa.

    move-corresponding g_TABLCTRL115_wa to wa_itemtab.

*    Perform check_items_save.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zqm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zqm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial and
              zic_prep_rolereq-ccode = 'MUM'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

   endif.

 endif.
*
**
  perform validate_lineitem_datax15.

ENDFORM.                    " check_items_save_qm
**********************************************************************
*DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*       messages of call transaction

*----------------------------------------------------------------------*
*   at selection screen                                                *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   create batchinput session                                          *
*   (not for call transaction using...)                                *
*----------------------------------------------------------------------*
FORM OPEN_GROUP.
    CALL FUNCTION 'BDC_OPEN_GROUP'
         EXPORTING  CLIENT   = SY-MANDT
                    GROUP    = sy-uname
                    USER     = sy-uname
                    KEEP     = ''
                    HOLDDATE = sy-datum.

ENDFORM.

*----------------------------------------------------------------------*
*   end batchinput session                                             *
*   (call transaction using...: error session)                         *
*----------------------------------------------------------------------*
FORM CLOSE_GROUP.
    CALL FUNCTION 'BDC_CLOSE_GROUP'.
ENDFORM.
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL <> '/'.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.
**********************************************************************
*&---------------------------------------------------------------------*
*&      Form  call_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_fi.

 SET PARAMETER ID 'ZOLDCODE_FI' field old_ok_code.

 SET PARAMETER ID 'ZMODULEID_FI' field 'FI'.

 SET PARAMETER ID 'ZUSERID_FI' field ZIC_PREP_ROLEREQ-USERID.

 SET PARAMETER ID 'ZRSN_CODE_FI' field ZIC_PREP_ROLEREQ-RSN_CODE.

 SET PARAMETER ID 'ZTELNO_FI' field ZIC_PREP_ROLEREQ-TELNO.

 SET PARAMETER ID 'ZDOCNO_FI' field ZIC_PREP_ROLEREQ-DOCNO.

 dynnr = '0101'.

 clear old_ok_code.

 perform clear.

  CALL TRANSACTION 'ZIC_AUTH_FI' .

  endform. "call_fi
*&---------------------------------------------------------------------*
*&      Form  check_module_status_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_qm.
 if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     qm_not_ok = 'X'.
  endif.
ENDFORM.                    " check_module_status_qm
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax15
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax15.

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not g_TABLCTRL115_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZIC_PREP_ROLEREQ-CCODE
                                    and werks = g_TABLCTRL115_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABLCTRL115_wa-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ASSET_QM is initial.

    if ZIC_PREP_ROLEREQ-CCODE = 'MUM' or ZIC_PREP_ROLEREQ-CCODE = 'KKL'.

      select single * from ZQM_PREP_ASSET into zqm_prep_asset where
                      ccode =  ZIC_PREP_ROLEREQ-CCODE and
                      asset =  ZIC_PREP_ROLEREI-ASSET_QM.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET_QM'.
            g_i = g_curr_line.
           message e172(zhelp) with ZIC_PREP_ROLEREI-asset_qm.
      endif.

    endif.

   endif.

endif.

endloop.

ENDFORM.                    " validate_lineitem_datax15
*&---------------------------------------------------------------------*
*&      Form  confirm_more
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_more.
" Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to attach more files?'
*              DEFAULTOPTION  = ''
*              TITEL          = 'ATTACH MORE'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = g_choice_more.
  data : l_get1(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'ATTACH MORE '
      TEXT_QUESTION               = 'Do you want to attach more files?'
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = l_get1
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
       .
IF SY-SUBRC = 0.
       CASE l_get1.
         WHEN '1'.
           MOVE 'J' TO g_choice_more.
           WHEN '2'.
             MOVE 'N' TO g_choice_more.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
ENDFORM.                    " confirm_more
*&---------------------------------------------------------------------*
*&      Form  check_module_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_fi.

  if ( old_ok_code = 'CHANGE' or
  old_ok_code = 'DISPLAY' ) and moduleid = 'FI'.
     select single * from zic_prep_rolerei into
                     corresponding fields of wa_module1 where
                     docno = zic_prep_rolereq-docno and
                     moduleid = 'FI'.
     if sy-subrc <> 0.
        if old_ok_code = 'CHANGE'.
          message e196(zhelp) with zic_prep_rolereq-docno.
        else.
          message e198(zhelp) with zic_prep_rolereq-docno.
        endif.
     endif.
  endif.

ENDFORM.                    " check_module_fi
*&---------------------------------------------------------------------*
*&      Form  check_auth
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_auth.

AUTHORITY-CHECK OBJECT 'ZARMSADM'
                     ID 'ACTVT' FIELD : '01'.

  if sy-subrc <> 0.
    message e199(zhelp).
  endif.

ENDFORM.                    " check_auth

*--- INCLUDE: MZMMPREPROLE1_PHASEII_ADMNI01 ---*
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
*1)Change in Line 697.
************************************************************************
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

  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABCTRL100_wa.

*  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

    select single * from zmm_prep_rolegrp where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with ZIC_PREP_ROLEREI-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

*  endif.

  if ZIC_PREP_ROLEREI-rej_fl = ''.

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
**
   if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_TABCTRL100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      endif.
   else.
      select single * from zmm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_TABCTRL100_wa-role_desc = zmm_prep_roledes-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      endif.

   endif.
**
  endif.
  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line.

  if sy-subrc <> 0.
    append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

  if G_TABCTRL100_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABCTRL100_WA-FLAG.
            append g_TABCTRL100_wa to g_TABCTRL100_itab.
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
**  OKCODE = sy-ucomm.
**  perform user_ok_tc using    'TABCTRL100'
**                              'G_TABCTRL100_ITAB'
**                              'FLAG'
**                     changing OKCODE.
**  sy-ucomm = OKCODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.
  TYPES :
           BEGIN of ty_bukrs,
             werks like zd_t001w_bukrs-werks,
             name1 like zd_t001w_bukrs-name1,
           END of ty_bukrs.

  DATA   : it_bukrs type table of ty_bukrs with header line.

  select * from zd_t001w_bukrs into corresponding fields of
             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
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

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000'  ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-GRP' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

endloop.

  DATA : l_ekgrp like t024-ekgrp.
  data : loop_step like sy-stepl.
  Data : l_role_name like ZIC_PREP_ROLEREI-ROLE_NAME.

  Data l_disc_mm_flag like ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_role_name.

  if l_role_name = 'M6' or  l_role_name = 'M7' or
     l_role_name = 'M8'.
    concatenate '%' G_CCODE '%' into g_line1.
    select * from t024 into table it_t024 where TELFX like g_line1.

  else.
    if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      concatenate '%' G_CCODE '%' 'IND' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    else.
      concatenate  '%' G_CCODE '%' 'MM' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    endif.
   endif.

 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T024'.
 g_field_wa-fieldname = 'EKGRP'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T024'.
 g_field_wa-fieldname = 'EKNAM'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'EKGRP'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-GRP'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t024
            FIELD_TAB       = g_field_tab
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

  REFRESH:it_t024,IST_RETURN_TAB, g_field_tab.
  FREE : it_t024,IST_RETURN_TAB, g_field_tab.
  Clear g_field_wa.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.

  TYPES : Begin of z_role_des,
            role_type like zmm_prep_roledes-role_type,
            brief_desc like zmm_prep_roledes-brief_desc,
            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
            sort_field like zmm_prep_roledes-brief_desc,
            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
          end of z_role_des.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_role type table of z_role_des with header line.

  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    select * from zmm_prep_rolecrc into corresponding fields of
               table it_role.

  else.

    select * from zmm_prep_roledes into corresponding fields of
               table it_role.

  endif.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data INPUT.

 if old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
       old_ok_code = 'DELETE' or old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or ( OLD_OK_CODE = 'CRCROLES' )
       or old_ok_code = 'RELEASE' or ( OLD_OK_CODE = 'APPROVE' ).

     if not  ZIC_PREP_ROLEREQ-userid is initial.
        perform check_tel.
     endif.

     if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' or
        OLD_OK_CODE = 'CRCROLES'.

        if  ZIC_PREP_ROLEREQ-PERSA is initial and
            ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             perform pop_up_message.
        endif.

        if  ZIC_PREP_ROLEREQ-userid is initial.
          message e035(zhelp).
        endif.

        if  ZIC_PREP_ROLEREQ-userid <> old_userid and
          old_userid <> ''.
          clear  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
          clear  ZIC_PREP_ROLEREQ-CCODE.
          clear  ZIC_PREP_ROLEREQ-FUNDC1.
          clear  ZIC_PREP_ROLEREQ-FUNDC.
          clear  ZIC_PREP_ROLEREQ-S_DESC.
          clear  ZIC_PREP_ROLEREQ-RSN_CODE.
          clear  ZIC_PREP_ROLEREQ-RSN_TEXT1.
          clear  ZIC_PREP_ROLEREQ-REASON1.
          clear  ZIC_PREP_ROLEREQ-TELNO.
          clear  ZIC_PREP_ROLEREQ-NAME.
          clear  ZIC_PREP_ROLEREQ-DESIGNATION.
          clear set_disc_mm_flag.
          clear set_disc_fi_flag.
          clear help_list_flag.
          refresh it_m_fistb.
          clear wa_m_fistb.
        endif.

*        select single * from zusrmst where cpfno =
*                                    ZIC_PREP_ROLEREQ-userid.

        select single * from usr02 where bname =
                                    ZIC_PREP_ROLEREQ-userid.

        if sy-subrc ne 0.
          message e043(zhelp).
        else.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-name = zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-designation = zusrmst-designation.

        select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
             ZIC_PREP_ROLEREQ-NAME = ist_data-name.
             ZIC_PREP_ROLEREQ-DESIGNATION = ist_data-designation.
            if ist_data-disc_cd = '36' and set_disc_mm_flag <> 'X'.
                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
                set_disc_mm_flag = 'X'.
            endif.
            if ist_data-disc_cd = '13' and set_disc_fi_flag <> 'X'.
                ZIC_PREP_ROLEREQ-DISC_fi_FLAG = 'X'.
                set_disc_fi_flag = 'X'.
            endif.
***************************************************31.05.2006
             if old_ok_code = 'CREATE' or old_ok_code = 'CRCROLES'.
               ZIC_PREP_ROLEREQ-CCODE = ist_data-bukrs.
             else.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.
             if old_ok_code = 'APPROVE'.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.
***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*             ZIC_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

            if old_ok_code = 'CREATE'.
                if  ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
                   not  ZIC_PREP_ROLEREQ-PERSA is initial.
                   message e108(zhelp).
                endif.
            endif.

        endif.

       clear : ist_data.
       refresh : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006


          concatenate '000'  ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

*          select single * from lfb1 where lifnr = cpf_lfb1.

* Select Company-KBU01, Cost Centre-kst01
* from pa0027  .
    clear wa_pa0027.

    SELECT *
 FROM PA0027 INTO WA_PA0027 UP TO 1 ROWS WHERE PERNR = CPF_LFB1 AND ENDDA = '99991231' AND SPRPS = ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT. " SPRPS - Lock Indicator 'X'

          if sy-subrc = 0.
            if old_ok_code <> 'CROSSCO'.
              concatenate  '''' '%' wa_pa0027-kst01
                           '''' into  g_line1.
              concatenate  'OBJNR'  'LIKE' g_line1 into g_line1
              separated by space.
              refresh :  it_cond.
              append g_line1 to it_cond.
              SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE (IT_COND)
 ORDER BY PRIMARY KEY .
 ENDSELECT.
            endif.
            if sy-subrc = 0.
             if old_ok_code = 'CREATE' or old_ok_code = 'CRCROLES'.
               ZIC_PREP_ROLEREQ-FUNDC1 = fmzuob-fistl.
               ZIC_PREP_ROLEREQ-FUNDC_FL = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
               ZIC_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             else.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
               ZIC_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             endif.

                SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZIC_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc =  0.
                    ZIC_PREP_ROLEREQ-S_DESC = CSKT-LTEXT.
              endif.

              refresh it_cond[].
              clear it_cond.
            else.
            endif.
          endif.

        endif.

     else.

***************************************************

           if  ZIC_PREP_ROLEREQ-docno is initial.
                  message e041(zhelp).
           endif.

     endif.

**********************************************************nn

     select single * from usr02 where bname =
                                    ZIC_PREP_ROLEREQ-userid.

        if sy-subrc ne 0.
        else.
        select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0 and ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
            read table ist_data index 1. "#EC CI_NOORDER
             if old_ok_code = 'APPROVE'.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.
          endif.
        endif.
********************************************************nn
endif.

*Begin of <RD1K963151>.
if ZIC_PREP_ROLEREQ-USERIDCR is not  INITIAL.
      select single * from usr21 where bname = ZIC_PREP_ROLEREQ-USERIDCR.
      if sy-subrc ne 0.
        MESSAGE e803(zmm) with 'User Not Found'.
        endif.
select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data1
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERIDCR and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .
if sy-subrc = 0.
  READ TABLE ist_data1 index 1. "#EC CI_NOORDER
  ZIC_PREP_ROLEREQ-NAMECR = ist_data1-name.
  if sy-subrc = 0 .
    clear ist_data1[].
    endif.
  endif.
  endif.

  if ZIC_PREP_ROLEREQ-USERIDAP is not INITIAL.
    select single * from usr21 where bname = ZIC_PREP_ROLEREQ-USERIDAP.
      if sy-subrc ne 0.
        MESSAGE e803(zmm) with 'User Not Found'.
        endif.
  select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data2
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERIDAP and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .
    if sy-subrc = 0 .
      READ TABLE ist_data2 index 1. "#EC CI_NOORDER
      ZIC_PREP_ROLEREQ-NAMEAPP = ist_data2-name.
      if sy-subrc = 0.
        clear ist_data2[].
        endif.
      endif.
  endif.
*End of <RD1K963151>.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

if moduleid = 'FI' .
   perform call_fi.
endif.

case okcode_100.

    When 'BAC' OR 'CAN'.
      perform exit_confirm.
    When 'EXT'.
      leave program.

    When 'CREATE'.

      old_ok_code = okcode_100.
      moduleid = 'MM'.

    When 'CHANGE'.

     old_ok_code = okcode_100.

    When 'RELEASE'.

     old_ok_code = okcode_100.


    When 'APPROVE'.

     old_ok_code = okcode_100.

    When 'COPY'.


    When 'DISPLAY'.

      old_ok_code = okcode_100.

    When 'ROLE_DEL'.

      old_ok_code = okcode_100.

    WHEN 'SAV'.

      if old_ok_code = 'DELETE'.

          if  ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            if  ZIC_PREP_ROLEREQ-STATUS = ''.
              Perform delete_request.
            else.
              message e138(ZHELP).
            endif.
          else.
            message e056(ZHELP).
          endif.
      else.
*        describe table g_TABLCTRL110_itab lines g_lines_rl.
*        if g_lines_rl = 0.
*           clear okcode_100.
*           message i140(zhelp).
*        else.
        if old_ok_code = 'RELEASE' and
               ZIC_PREP_ROLEREQ-req_cr_fl <> 'X'.
              message i083(zhelp).

        elseif old_ok_code = 'RELEASE' and g_lines_rl = 0.
              message i089(zhelp).

        elseif old_ok_code = 'APPROVE' and
               (  ZIC_PREP_ROLEREQ-req_app_fl <> 'X' and
               ZIC_PREP_ROLEREQ-req_app0_fl <> 'X' and
               ZIC_PREP_ROLEREQ-req_app1_fl <> 'X' ).
**13/04/07
               if module_changed_flag <> 'X'.
                  message i087(zhelp).
               else.
                  Perform Save_request.
               endif.
        elseif old_ok_code = 'APPROVE' and  g_mult_module_fl = 'X'.
           set parameter id 'ZROLEREQNOFORDETAILS'
                  field zic_prep_rolereq-docno.
           call screen 200 starting at 10 15  ending at 90 25.
           perform confirm_app.
           if g_choice_app = 'J'.
              clear g_choice_app.
              if moduleid <> 'MM'.
               g_approver_level = 'L3'.
              endif.
              Perform Save_request.
           endif.
        else.
*          Perform check_items.
          if moduleid <> 'MM'.
           g_approver_level = 'L3'.
          endif.
          Perform Save_request.
        endif.
**       endif.
      endif.

    When 'MULTI'.

*      clear help_list_flag.

      call screen 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      clear okcode_100.


    WHEN 'DELETE'.

       old_ok_code = okcode_100.

    WHEN 'ATTACH'.

*       if old_ok_code = 'CREATE' or
*          old_ok_code = 'CROSSCO' or
*          old_ok_code = 'CRCROLES'.
*          message i137(zhelp).
*       else.
*          perform attach_files.
*       endif.
      if old_ok_code = 'CREATE' or
          old_ok_code = 'CROSSCO' or
          old_ok_code = 'CRCROLES'.
          message i137(zhelp).
       else.
          perform attach_files.
          if old_ok_code = 'DISPLAY' and
             ZIC_PREP_ROLEREQ-status = 'IR'.
             attach_fl = 'X'.
             Perform confirm_more.

            If g_choice_more = 'J'.
              clear g_choice_more.
            else.
              Perform Save_request.
            endif.
          endif.
       endif.

*       old_ok_code = okcode_100.

    WHEN 'LIST'.

       perform list_files.

*       old_ok_code = okcode_100.

    WHEN 'CORR'.

        Call Screen 105 starting at 85 05 ending at 148 24.
        clear okcode_100.

    WHEN 'CROSSCO'.

       old_ok_code = okcode_100.
       moduleid = 'MM'.

    WHEN 'CRCROLES'.

       old_ok_code = okcode_100.

    WHEN 'SUMMARY'.

      set parameter id 'ZROLEREQNOFORDETAILS'
                  field zic_prep_rolereq-docno.
*      call transaction 'ZIC_DETAILS' .

      call screen 200 starting at 10 15  ending at 90 25.

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
     clear sy-ucomm.
  endif.
  okcode_100 = sy-ucomm.

  clear :  err_flg.

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
MODULE clear_data INPUT.

if not  ZIC_PREP_ROLEREQ-docno is initial.

*  data : l_docno like  ZIC_PREP_ROLEREQ-docno.

l_docno =  ZIC_PREP_ROLEREQ-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

   ZIC_PREP_ROLEREQ-docno = l_docno.

endif.

if old_doc_no <>  ZIC_PREP_ROLEREQ-docno.
                    clear g_hd_copied.
                    clear g_mult_module_fl.
                 perform destroy_ctrl.
endif.

if not moduleid is initial and old_moduleid <> moduleid.
            g_TABLCTRL110_copied = ''.
            g_TABLCTRL111_copied = ''.
            g_TABLCTRL112_copied = ''.
            g_TABLCTRL113_copied = ''.
            g_TABLCTRL114_copied = ''.
            g_TABLCTRL115_copied = ''.
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
  if ( old_ok_code = 'CREATE' )
  or ( old_ok_code = 'CROSSCO' )
  or ( old_ok_code = 'CRCROLES' )
  or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' )
   or ( old_ok_code = 'DISPLAY' and  ZIC_PREP_ROLEREQ-comm_fl = 'X'
        and  ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

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
    DESCRIBE TABLE TLINETAB2 LINES g_lines_2.
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

      if screen-name = 'ZIC_PREP_ROLEREI-SLOC' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  Data : l_plant like ZIC_PREP_ROLEREI-PLANT.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_plant.


  DATA   : it_t001l type table of t001l with header line.
  DATA   : it_excp_sl type table of zmm_prep_sl_excp with header line.
  DATA   : wa_t001l like t001l.
  DATA   : l_zarea like zmm_consm-zarea.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

   if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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

    select * from zmm_prep_sl_excp into table it_excp_sl.

************************************

    loop at it_excp_sl.

       read table it_t001l with key werks = it_excp_sl-werks
       lgort = it_excp_sl-lgort.

       if sy-subrc = 0.

          delete it_t001l where werks = it_excp_sl-werks
          and lgort = it_excp_sl-lgort.

       endif.

    endloop.

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'WERKS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGORT'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGOBE'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t001l
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_t001l,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_t001l,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_APPROVER INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-APPROVER' and screen-input = 0.
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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
       IMPORTING
            VALUE = l_role_name.

     if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.


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
           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

         if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

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
                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-APPROVER'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_approver
            FIELD_TAB       = g_field_tab
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

  REFRESH:it_approver,IST_RETURN_TAB, it_approver1,g_field_tab.
  FREE  : it_approver,IST_RETURN_TAB, it_approver1,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RECEIPT_LOC INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC' and screen-input =
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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
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

   g_field_wa-tabname = 'ZMM_LOCATION'.
   g_field_wa-fieldname = 'LOCCD'.
   append g_field_wa to g_field_tab.
   g_field_wa-tabname = 'ZMM_LOCATION'.
   g_field_wa-fieldname = 'LOCCG'.
   append g_field_wa to g_field_tab.
   g_field_wa-tabname = 'ZMM_LOCATION'.
   g_field_wa-fieldname = 'LOCDS'.
   append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LOCCD'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_recpt
            FIELD_TAB       = g_field_tab
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

  REFRESH:it_recpt,IST_RETURN_TAB,g_field_tab.
  FREE  : it_recpt,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

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

old_doc_no =  ZIC_PREP_ROLEREQ-docno.
old_userid =  ZIC_PREP_ROLEREQ-userid.
old_disc_mm_flag =  ZIC_PREP_ROLEREQ-disc_mm_flag.
old_moduleid = moduleid.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

*  clear g_e_fl.

  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i117(zhelp).
    elseif ZIC_PREP_ROLEREI-ROLE_NAME+0(1) <> 'C'.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

  endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-RECEIPT_LOC.
  clear  ZIC_PREP_ROLEREI-SLOC.
  clear  ZIC_PREP_ROLEREI-plant.
  clear  ZIC_PREP_ROLEREI-grp.
  clear  ZIC_PREP_ROLEREI-approver.

  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZIC_PREP_ROLEREI-RECEIPT_LOC.
      clear  ZIC_PREP_ROLEREI-SLOC.
      clear  ZIC_PREP_ROLEREI-plant.
      clear  ZIC_PREP_ROLEREI-grp.
      clear  ZIC_PREP_ROLEREI-approver.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZIC_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZIC_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if  ZIC_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           if ZIC_PREP_ROLEREI-role_name <> ''.
             message e081(zhelp) with ZIC_PREP_ROLEREI-role_name.
           endif.
         endif.

   endif.

 endif.

*  endif.

  if not ZIC_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
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
 if g_TABLCTRL110_wa-role_name = 'M6' or
     g_TABLCTRL110_wa-role_name = 'M7' or
     g_TABLCTRL110_wa-role_name = 'M8'.
    concatenate '%' G_CCODE '%' into g_line1.
    select * from t024 into table it_t024 where TELFX like g_line1.
  else.
    if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      concatenate '%' G_CCODE '%' 'IND' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    else.
      concatenate  '%' G_CCODE '%' 'MM' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    endif.
   endif.
**
   if  not ZIC_PREP_ROLEREI-GRP is initial.

       loop at it_t024 into wa_t024.

           if ZIC_PREP_ROLEREI-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL110_wa.
          modify g_TABLCTRL110_itab
                    from g_TABLCTRL110_wa
                      index TABLCTRL110-current_line.
          g_i = TABLCTRL110-current_line.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( ZIC_PREP_ROLEREI-role_name = 'M13' or
   ZIC_PREP_ROLEREI-role_name = 'M14' or
    ZIC_PREP_ROLEREI-role_name = 'M16' or
    ZIC_PREP_ROLEREI-role_name = 'M18' or
    ZIC_PREP_ROLEREI-role_name = 'M19' ) and
    not ZIC_PREP_ROLEREI-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = ZIC_PREP_ROLEREI-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
       message e074(zhelp).

    endif.

endif.

   if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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

    if  not ZIC_PREP_ROLEREI-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if ZIC_PREP_ROLEREI-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( ZIC_PREP_ROLEREI-role_name = 'M12' or
       ZIC_PREP_ROLEREI-role_name = 'M17' ) and
       not ZIC_PREP_ROLEREI-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if ZIC_PREP_ROLEREI-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if ZIC_PREP_ROLEREI-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not ZIC_PREP_ROLEREI-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if ZIC_PREP_ROLEREI-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          message e075(zhelp).

       endif.

    endif.


*****************************
*****************************22.05.06

if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.

           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

         if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

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

                 case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

                case  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

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

if  not ZIC_PREP_ROLEREI-APPROVER is initial.

       loop at it_approver into wa_approver.

           if ZIC_PREP_ROLEREI-APPROVER = wa_approver-app_level.
              approver_flag = 'X'.
           endif.

       endloop.

       if approver_flag = 'X'.
          clear approver_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL110_wa.
          modify g_TABLCTRL110_itab
                    from g_TABLCTRL110_wa
                      index TABLCTRL110-current_line.
          g_i = TABLCTRL110-current_line.
          message e135(zhelp).
          call screen 100.

       endif.

   endif.


endif.

ENDMODULE.                 " validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE record_rej_id_data INPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> 'CHANGE'.
**13/04/07
if ZIC_PREP_ROLEREI-rej_id is initial.
  ZIC_PREP_ROLEREI-rej_id = sy-uname.
  ZIC_PREP_ROLEREI-rej_date = sy-datum.
endif.

if not ZIC_PREP_ROLEREI-rej_fl is initial and
   ZIC_PREP_ROLEREI-rej_fl_save is initial.

    select single * from  ZMM_PREP_REJ_LIS  where
      rej_code = ZIC_PREP_ROLEREI-rej_fl .
    if sy-subrc <> 0.
      g_e_fl = 'X'.
      message e111(zhelp).
    else.
      if g_user = 'L1' and ZIC_PREP_ROLEREI-rej_fl <> 'R'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'L3' and ZIC_PREP_ROLEREI-rej_fl <> 'B'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'IM' and ZIC_PREP_ROLEREI-rej_fl <> 'I'.
        g_e_fl = 'X'.
        message e111(zhelp).
      endif.
    endif.
endif.
**
endif.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.

data : tel_len type i.
  tel_len = strlen(  ZIC_PREP_ROLEREQ-TELNO ).
  if   ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
    message e097(zhelp).
  Else.
    if tel_len < 7.
      message e098(zhelp).
    Endif.
  Endif.

ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data1 INPUT.

if old_ok_code = 'CRCROLES'.

   SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
else.

   select single * from zmm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

endif.

if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
            not g_role_name_prev is initial.
    g_role_name_flag = 'X'.
endif.
g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_read  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_read INPUT.
clear g_read_fl.
ENDMODULE.                 " clear_read  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno INPUT.
clear g_srno.
loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL110_wa-srno = g_srno.
      modify g_TABLCTRL110_itab from g_TABLCTRL110_wa.
endloop.
describe table g_TABLCTRL110_itab  lines g_lines_rl.
describe table g_TABLCTRL110_itab  lines TABLCTRL110-lines.
clear g_srno.

ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup INPUT.
if not g_TABCTRL100_itab[] is initial .

  delete adjacent duplicates from g_TABCTRL100_itab
  comparing role_name plant grp sloc receipt_loc approver.

endif.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
g_role_name_prev = ZIC_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: modify table
module TABLCTRL110_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL110_wa.

  select single * from zmm_prep_rolegrp where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

  if ZIC_PREP_ROLEREI-rej_fl = ''.

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

  if not g_TABLCTRL110_wa-role_name is initial.
   if old_ok_code = 'CRCROLES' or zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        g_TABCTRL100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
      endif.
   else.
      select single * from zmm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0.
        g_TABLCTRL110_wa-role_desc = zmm_prep_roledes-brief_desc.
      endif.
   endif.
  endif.

 modify g_TABLCTRL110_itab
    from g_TABLCTRL110_wa
    index TABLCTRL110-current_line.

  if sy-subrc <> 0.
    append g_TABLCTRL110_wa to g_TABLCTRL110_itab.
  endif.

  if G_TABLCTRL110_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL110_WA-FLAG.
            append g_TABLCTRL110_wa to g_TABLCTRL110_itab.
  endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: mark table
module TABLCTRL110_mark input.
  if TABLCTRL110-line_sel_mode = 1 and
     g_TABLCTRL110_wa-flag = 'X'.
     loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa
       where flag = 'X'.
       g_TABLCTRL110_wa-flag = ''.
       modify g_TABLCTRL110_itab
         from g_TABLCTRL110_wa
         transporting flag.
     endloop.
     g_TABLCTRL110_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL110_itab
    from g_TABLCTRL110_wa
    index TABLCTRL110-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: process user command
module TABLCTRL110_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL110'
                              'G_TABLCTRL110_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_110 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL110-top_line + g_cursor_line - 1.
  g_curr_line_110 = g_curr_line.

ENDMODULE.                 " get_cursor_line_110  INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: modify table
module TABLCTRL111_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL111_wa.

  select single * from zpm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL111_wa-role_desc = zpm_prep_roledes-brief_desc.

    modify g_TABLCTRL111_itab
      from g_TABLCTRL111_wa
      index TABLCTRL111-current_line.

  if sy-subrc <> 0.
    append g_TABLCTRL111_wa to g_TABLCTRL111_itab.
  endif.

  if G_TABLCTRL111_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL111_WA-FLAG.
            append g_TABLCTRL111_wa to g_TABLCTRL111_itab.
  endif.
endmodule.

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: mark table
module TABLCTRL111_mark input.
  if TABLCTRL111-line_sel_mode = 1 and
     g_TABLCTRL111_wa-flag = 'X'.
     loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa
       where flag = 'X'.
       g_TABLCTRL111_wa-flag = ''.
       modify g_TABLCTRL111_itab
         from g_TABLCTRL111_wa
         transporting flag.
     endloop.
     g_TABLCTRL111_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL111_itab
    from g_TABLCTRL111_wa
    index TABLCTRL111-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: process user command
module TABLCTRL111_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL111'
                              'G_TABLCTRL111_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_111 INPUT.

 get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL111-top_line + g_cursor_line - 1.
  g_curr_line_111 = g_curr_line.

ENDMODULE.                 " get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11 INPUT.

select single * from zpm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
            not g_role_name_prev is initial.
    g_role_name_flag = 'X'.
endif.
g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11a INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zpm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-SHOP_NO.
  clear  ZIC_PREP_ROLEREI-plant.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZIC_PREP_ROLEREI-SHOP_NO.
     clear  ZIC_PREP_ROLEREI-plant.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

     select * from zpm_prep_roledes into corresponding fields of
                 table it_role.

     if zic_prep_rolereq-ccode = 'BDW' or
        zic_prep_rolereq-ccode = 'SBW'.
     else.
        delete it_role where role_type = 'PM14' or
        role_type = 'PM15' or role_type = 'PM16'.
     endif.

     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.
ENDMODULE.                 " validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno11 INPUT.

clear g_srno.
loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL111_wa-srno = g_srno.
      modify g_TABLCTRL111_itab from g_TABLCTRL111_wa.
endloop.
describe table g_TABLCTRL111_itab  lines g_lines_rl.
describe table g_TABLCTRL111_itab  lines TABLCTRL111-lines.
clear g_srno.

ENDMODULE.                 " change_srno11  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PM INPUT.
loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.

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

    select * from zpm_prep_roledes into corresponding fields of
               table it_role.

   sort it_role ascending by sort_field.

   if zic_prep_rolereq-ccode = 'BDW' or
      zic_prep_rolereq-ccode = 'SBW'.
   else.
      delete it_role where role_type = 'PM14' or
      role_type = 'PM15' or role_type = 'PM16'.
   endif.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SHOP_NO INPUT.
  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SHOP_NO' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
  TYPES :
           BEGIN of ty_shop,
             werks like t357-werks,
             beber like t357-beber,
             fing  like t357-fing,
           END of ty_shop.

  DATA   : it_shop type table of ty_shop with header line.

  select * from T357 into corresponding fields of
             table it_shop  where werks =  '53C1' or
                                  werks =  '24C1'.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'BEBER'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SHOP_NO'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_SHOP
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

ENDMODULE.                 " POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_MODULEID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_MODULEID INPUT.

  data : it_module like table of ZIC_MODULES.
  data : wa_module like ZIC_MODULES.

**  data : l_docno like zic_prep_rolereq-DOCNO.
*  data : l_dynnr like sy-dynnr.
*
*  if sy-dynnr <> '0100'.
*     l_dynnr = '0100'.
*  else.
*     l_dynnr = sy-dynnr.
*  endif.

*  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
*       EXPORTING
*            STRUC = 'ZIC_PREP_ROLEREQ'
*            FIELD = 'DOCNO'
*            REPID = SY-CPROG
*            DYNNR = '0100'
*       IMPORTING
*            VALUE = l_docno.

l_docno = ZIC_PREP_ROLEREQ-DOCNO.

* clear l_dynnr.

    if old_ok_code = 'CREATE'  or
       old_ok_code = 'CROSSCO'  or
       old_ok_code = 'CRCROLES' or
       old_ok_code = 'CHANGE'.

       select  moduleid from zice_prep_module into corresponding fields
        of table it_module.

     else.

        select distinct moduleid from zic_prep_rolerei into
          corresponding fields of table it_module where DOCNO = l_docno.

     endif.

     loop at it_module into wa_module.
        select single * from zice_prep_module where moduleid =
        wa_module-moduleid.
        wa_module-z_desc = zice_prep_module-z_desc.
        modify it_module from wa_module.
      endloop.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'MODULEID'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'MODULEID'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_module
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

  REFRESH:it_module,IST_RETURN_TAB.
  FREE  : it_module,IST_RETURN_TAB.

ENDMODULE.                 " POV_MODULEID  INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: modify table
module TABLCTRL112_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL112_wa.
  select single * from zps_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
*       g_val_err = 'X'.
*       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL112_wa-role_desc = zps_prep_roledes-brief_desc.

   modify g_TABLCTRL112_itab
    from g_TABLCTRL112_wa
    index TABLCTRL112-current_line.
    if sy-subrc <> 0.
      append g_TABLCTRL112_wa to g_TABLCTRL112_itab.
    endif.

    if G_TABLCTRL112_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL112_WA-FLAG.
            append g_TABLCTRL112_wa to g_TABLCTRL112_itab.
    endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: mark table
module TABLCTRL112_mark input.
  if TABLCTRL112-line_sel_mode = 1 and
     g_TABLCTRL112_wa-flag = 'X'.
     loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa
       where flag = 'X'.
       g_TABLCTRL112_wa-flag = ''.
       modify g_TABLCTRL112_itab
         from g_TABLCTRL112_wa
         transporting flag.
     endloop.
     g_TABLCTRL112_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL112_itab
    from g_TABLCTRL112_wa
    index TABLCTRL112-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: process user command
module TABLCTRL112_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL112'
                              'G_TABLCTRL112_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_112 INPUT.
 get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL112-top_line + g_cursor_line - 1.
  g_curr_line_112 = g_curr_line.

ENDMODULE.                 " get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data12 INPUT.

if not ZIC_PREP_ROLEREI-role_name is initial.

  select single * from zps_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

  if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
              not g_role_name_prev is initial.
      g_role_name_flag = 'X'.
  endif.
  g_read_fl = 'X'.

 endif.
ENDMODULE.                 " validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data12a INPUT.
if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X' and not ZIC_PREP_ROLEREI-ROLE_NAME is initial
   and not ZIC_PREP_ROLEREI-SERVICE is initial.

    select single * from zps_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    else.
       g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
*  clear  ZIC_PREP_ROLEREI-SERVICE.
  clear  ZIC_PREP_ROLEREI-PROJECT.
  clear  ZIC_PREP_ROLEREI-LOCATION.
*  clear  ZIC_PREP_ROLEREI-REGION.
  clear  ZIC_PREP_ROLEREI-ASSET.
  clear  ZIC_PREP_ROLEREI-BASIN.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
      clear g_role_name_flag.
*      clear  ZIC_PREP_ROLEREI-SERVICE.
      clear  ZIC_PREP_ROLEREI-PROJECT.
      clear  ZIC_PREP_ROLEREI-LOCATION.
*      clear  ZIC_PREP_ROLEREI-REGION.
      clear  ZIC_PREP_ROLEREI-ASSET.
      clear  ZIC_PREP_ROLEREI-BASIN.
endif.


g_field = 'ZIC_PREP_ROLEREI-SERVICE'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-SERVICE is initial.

      select * from zps_prep_service into corresponding fields of
                 table it_service where
                 service = ZIC_PREP_ROLEREI-SERVICE.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
            g_i = g_curr_line_112.
            message e169(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-PROJECT is initial.

      select * from zps_prep_project into corresponding fields of
                 table it_project where
                 service = ZIC_PREP_ROLEREI-service and
                 project = ZIC_PREP_ROLEREI-PROJECT.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
            g_i = g_curr_line.
            message e170(zhelp) with ZIC_PREP_ROLEREI-project.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-LOCATION is initial.

      select * from zps_prep_loca into corresponding fields of
             table it_loca where ccode = zic_prep_rolereq-ccode
             and location = ZIC_PREP_ROLEREI-LOCATION and
             service = zic_prep_rolerei-service.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
            g_i = g_curr_line.
            message e171(zhelp) with ZIC_PREP_ROLEREI-location.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ASSET is initial.

      if ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
         select * from zps_prep_asst_ex into corresponding fields of
               table it_asset where ccode = 'MUM' and
                     asset = ZIC_PREP_ROLEREI-ASSET.

         if sy-subrc <> 0 and ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
              g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-ASSET'.
              g_i = g_curr_line.
              message e172(zhelp) with ZIC_PREP_ROLEREI-asset.
          endif.

      else.
          if ZIC_PREP_ROLEREI-ASSET <> ZIC_PREP_ROLEREQ-CCODE and
             ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
             g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-ASSET'.
              g_i = g_curr_line.
              message e172(zhelp) with ZIC_PREP_ROLEREI-asset.
          endif.
      endif.
   endif.


   if not ZIC_PREP_ROLEREI-BASIN is initial.

       if ZIC_PREP_ROLEREI-BASIN <> ZIC_PREP_ROLEREQ-CCODE and
           ZIC_PREP_ROLEREI-BASIN <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-BASIN'.
            g_i = g_curr_line.
            message e173(zhelp) with ZIC_PREP_ROLEREI-basin.
       endif.

    endif.

   if not ZIC_PREP_ROLEREI-role_name is initial and
          not zic_prep_rolerei-service is initial.

     select * from zps_prep_roledes into corresponding fields of
                 table it_role.

     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno12 INPUT.
clear g_srno.
loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL112_wa-srno = g_srno.
      modify g_TABLCTRL112_itab from g_TABLCTRL112_wa.
endloop.
describe table g_TABLCTRL112_itab  lines g_lines_rl.
describe table g_TABLCTRL112_itab  lines TABLCTRL112-lines.
clear g_srno.
ENDMODULE.                 " change_srno12  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PS INPUT.

  data : l_service like ZIC_PREP_ROLEREI-SERVICE.

  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.

  DATA: BEGIN OF seltab OCCURS 0,
         SIGN(1),
         OPTION(2),
         LOW  LIKE ZIC_PREP_ROLEREI-ROLE_NAME,
         HIGH LIKE ZIC_PREP_ROLEREI-ROLE_NAME,
      END OF seltab.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.


   select * from zps_prep_serv_rl into corresponding fields of
            table it_role where service = l_service.

   loop at it_role.

     seltab-sign   = 'I'.
     seltab-OPTION = 'EQ'.
     seltab-low    = IT_ROLE-ROLE_TYPE.
     append seltab.

   endloop.

   select * from zps_prep_roledes into corresponding fields of
               table it_role where role_type in seltab.

   sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab, seltab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab, seltab.
  Clear : g_field_wa.



ENDMODULE.                 " POV_ROLE_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  dummy  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dummy INPUT.
 perform check_module_fi.
 if not old_moduleid is initial and old_moduleid <> moduleid and
*    old_ok_code = 'CHANGE'.
**13/04/07
    ( old_ok_code = 'CHANGE' or old_ok_code = 'APPROVE' ).
    okcode_100 = 'SAV'.
    new_moduleid = moduleid.
    moduleid = old_moduleid.
    module_changed_flag = 'X'.
    clear old_moduleid.
 endif.
ENDMODULE.                 " dummy  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SERVIVES_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SERVISES_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SERVICE' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_service type table of zps_prep_service with header line.

  select * from zps_prep_service into corresponding fields of
             table it_service.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'SERVICE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SERVICE'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_SERVICE
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

  REFRESH:IT_SERVICE,IST_RETURN_TAB.
  FREE : IT_SERVICE,IST_RETURN_TAB.

ENDMODULE.                 " POV_SERVIVES_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PROJECTS_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PROJECTS_PS INPUT.

 loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PROJECT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  data : loop_step like sy-stepl.
*  Data : l_service like ZIC_PREP_ROLEREI-SERVICE.
*
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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_project type table of zps_prep_project with header line.

  select * from zps_prep_project into corresponding fields of
             table it_project where service = l_service.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'PROJECT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PROJECT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_PROJECT
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

  REFRESH:IT_PROJECT,IST_RETURN_TAB.
  FREE : IT_PROJECT,IST_RETURN_TAB.

ENDMODULE.                 " POV_PROJECTS_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ASSET_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ASSET_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ASSET' and screen-input = 0.
        dis_flag = 'X'.
      endif.

endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.

*  types :
*        begin of asset_ty,
*              ccode type ZIC_PREP_ROLEREQ-CCODE,
*              asset type ZIC_PREP_ROLEREI-BASIN,
*              a_desc type Zchar80,
*        end of asset_ty.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_asset type table of asset_ty with header line.

  if ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
     select * from zps_prep_asst_ex into corresponding fields of table
               it_asset.
  else.
      move ZIC_PREP_ROLEREQ-CCODE to it_asset-asset.
      move ZIC_PREP_ROLEREQ-CCODE to it_asset-ccode.
      append it_asset.
  endif.
  move 'ALL'                  to it_asset-asset.
  move 'ALL'                  to it_asset-ccode.
  move 'ALL'                  to it_asset-a_desc.

  if l_service <> 'WS'.
    append it_asset.
  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ASSET'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ASSET'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_ASSET
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

  REFRESH:IT_ASSET,IST_RETURN_TAB.
  FREE  : IT_ASSET,IST_RETURN_TAB.
  CLEAR : IT_ASSET.

ENDMODULE.                 " POV_ASSET_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_BASIN_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_BASIN_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-BASIN' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

*  types :
*        begin of basin_ty,
*              ccode type ZIC_PREP_ROLEREQ-CCODE,
*              basin type ZIC_PREP_ROLEREI-BASIN,
*              b_desc type Zchar80,
*        end of basin_ty.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_basin type table of basin_ty with header line.

  move ZIC_PREP_ROLEREQ-CCODE to it_basin-basin.
  move ZIC_PREP_ROLEREQ-CCODE to it_basin-ccode.
  select single * from t001 where bukrs = ZIC_PREP_ROLEREQ-CCODE.
  move t001-BUTXT to it_basin-b_desc.
  append it_basin.
  move 'ALL'                  to it_basin-basin.
  move 'ALL'                  to it_basin-ccode.
  move 'ALL'                  to it_basin-b_desc.
  append it_basin.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'BASIN'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-BASIN'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_BASIN
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

  REFRESH:IT_BASIN,IST_RETURN_TAB.
  FREE : IT_BASIN,IST_RETURN_TAB.

ENDMODULE.                 " POV_BASIN_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_LOCATION_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_LOCATION_PS INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-LOCATION' and screen-input = 0.
        dis_flag = 'X'.
      endif.

endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SERVICE'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0112'
       IMPORTING
            VALUE = l_service.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_location type table of zps_prep_loc with header line.

  select * from zps_prep_loca into corresponding fields of
             table it_loca where service = l_service and
             ccode = zic_prep_rolereq-ccode.

*  if l_service = 'RD' and zic_prep_rolereq-ccode = 'AMD'.
*     clear it_location.
*     refresh it_location[].
*     it_location-ccode = zic_prep_rolereq-ccode.
*     it_location-location = 'IR'.
*     it_location-l_desc = 'INSTITUTE OF RESERVOIR STUDIES'.
*     append it_location.
*  else.
*  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LOCATION'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-LOCATION'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_LOCA
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

  REFRESH:IT_LOCA,IST_RETURN_TAB.
  FREE : IT_LOCA,IST_RETURN_TAB.

ENDMODULE.                 " POV_LOCATION_PS  INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: modify table
module TABLCTRL113_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL113_wa.

  select single * from zpp_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL113_wa-role_desc = zpp_prep_roledes-brief_desc.

    modify g_TABLCTRL113_itab
    from g_TABLCTRL113_wa
    index TABLCTRL113-current_line.

    if sy-subrc <> 0.
      append g_TABLCTRL113_wa to g_TABLCTRL113_itab.
    endif.

    if G_TABLCTRL113_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL113_WA-FLAG.
            append g_TABLCTRL113_wa to g_TABLCTRL113_itab.
    endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: mark table
module TABLCTRL113_mark input.
  if TABLCTRL113-line_sel_mode = 1 and
     g_TABLCTRL113_wa-flag = 'X'.
     loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa
       where flag = 'X'.
       g_TABLCTRL113_wa-flag = ''.
       modify g_TABLCTRL113_itab
         from g_TABLCTRL113_wa
         transporting flag.
     endloop.
     g_TABLCTRL113_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL113_itab
    from g_TABLCTRL113_wa
    index TABLCTRL113-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: process user command
module TABLCTRL113_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL113'
                              'G_TABLCTRL113_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_113 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL113-top_line + g_cursor_line - 1.
  g_curr_line_113 = g_curr_line.

ENDMODULE.                 " get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data13 INPUT.

  select single * from zpp_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

  if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
              not g_role_name_prev is initial.
      g_role_name_flag = 'X'.
  endif.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data13a INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zpp_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    else.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-PLANT.
  clear  ZIC_PREP_ROLEREI-SLOC.
  clear  ZIC_PREP_ROLEREI-RES.
  clear  ZIC_PREP_ROLEREI-CTF_SLOC.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
      clear g_role_name_flag.
      clear  ZIC_PREP_ROLEREI-PLANT.
      clear  ZIC_PREP_ROLEREI-SLOC.
      clear  ZIC_PREP_ROLEREI-RES.
      clear  ZIC_PREP_ROLEREI-CTF_SLOC.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

  select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
   if sy-subrc = 0.

   select single * from zhelp_pproles1 into corresponding fields of
                        zhelp_pproles1 where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.

   if sy-subrc <> 0.

   select single * from ZPP_PREP_GENERIC into corresponding fields of
                        ZPP_PREP_GENERIC where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            message e195(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.
   else.
             g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.


   endif.

   endif.

   if not ZIC_PREP_ROLEREI-SLOC is initial.

    select single * from t001l into corresponding fields of
             it_t001l  where werks = ZIC_PREP_ROLEREI-PLANT
             and lgort = ZIC_PREP_ROLEREI-SLOC.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
            g_i = g_curr_line.
            message e073(zhelp) with ZIC_PREP_ROLEREI-sloc.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-RES is initial.

      select single * from zpp_prep_res into corresponding fields of
             it_res  where role_type = ZIC_PREP_ROLEREI-ROLE_NAME
             and
             plant = ZIC_PREP_ROLEREI-PLANT
             and
             res = ZIC_PREP_ROLEREI-RES.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-RES'.
            g_i = g_curr_line.
            message e183(zhelp) with ZIC_PREP_ROLEREI-res.

      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ctf_sloc is initial.

     select single * from ZPP_PREP_DROLEEX where role_type =
         ZIC_PREP_ROLEREI-ROLE_NAME
         and plant = ZIC_PREP_ROLEREI-PLANT
         and sloc = ZIC_PREP_ROLEREI-SLOC
         and ctf_sloc = ZIC_PREP_ROLEREI-CTF_SLOC.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
            g_i = g_curr_line.
            message e073(zhelp) with ZIC_PREP_ROLEREI-ctf_sloc.

      endif.

    endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

     select * from zpp_prep_roledes into corresponding fields of
                 table it_role.

     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno13 INPUT.

clear g_srno.
loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL113_wa-srno = g_srno.
      modify g_TABLCTRL113_itab from g_TABLCTRL113_wa.
endloop.
describe table g_TABLCTRL113_itab  lines g_lines_rl.
describe table g_TABLCTRL113_itab  lines TABLCTRL113-lines.
clear g_srno.

ENDMODULE.                 " change_srno13  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PP INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


    select * from zpp_prep_roledes into corresponding fields of
               table it_role.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT_PP INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

  select * from zd_t001w_bukrs into corresponding fields of
             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
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

ENDMODULE.                 " POV_PLANT_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC_PP INPUT.
loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SLOC' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_plant.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'WERKS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGORT'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGOBE'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t001l
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_t001l,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_t001l,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.


ENDMODULE.                 " POV_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RES_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RES_PP INPUT.

data : l_role_type like ZIC_PREP_ROLEREI-ROLE_NAME .

 loop at screen.
  if screen-name = 'ZIC_PREP_ROLEREI-RES' and screen-input = 0.
        dis_flag = 'X'.
  endif.
 endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_role_type.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_plant.

  select * from zpp_prep_res into corresponding fields of
             table it_res  where role_type = l_role_type and
             plant = l_plant..

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'RES'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-RES'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_res
*            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_RES,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_RES,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_RES_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CTF_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CTF_SLOC_PP INPUT.

 data : l_sloc like ZIC_PREP_ROLEREI-SLOC .

 loop at screen.
  if screen-name = 'ZIC_PREP_ROLEREI-CTF_SLOC' and screen-input = 0.
        dis_flag = 'X'.
  endif.
 endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_role_type.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_plant.

   CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SLOC'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0113'
       IMPORTING
            VALUE = l_sloc.

***********************************

  select single * from ZPP_PREP_DROLEEX where role_type = l_role_type
         and plant = l_plant and sloc = l_sloc.

  if sy-subrc = 0.

    concatenate 'LGORT'  'LIKE'  into g_line separated by
    space.
    concatenate g_line+0(10) '''' '%Z%' ''''  into
                g_line.
    append g_line to it_cond.

    select * from t001l into corresponding fields of
               table it_t001l  where werks = l_plant and
               (it_cond).
  endif.
***********************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'WERKS'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGORT'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'T001L'.
 g_field_wa-fieldname = 'LGOBE'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_t001l
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_T001L,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_T001L,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_CTF_SLOC_PP  INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: modify table
module TABLCTRL114_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL114_wa.

  select single * from zsd_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL114_wa-role_desc = zpp_prep_roledes-brief_desc.

  modify g_TABLCTRL114_itab
    from g_TABLCTRL114_wa
    index TABLCTRL114-current_line.

    if sy-subrc <> 0.
      append g_TABLCTRL114_wa to g_TABLCTRL114_itab.
    endif.

    if G_TABLCTRL114_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL114_WA-FLAG.
            append g_TABLCTRL114_wa to g_TABLCTRL114_itab.
    endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: mark table
module TABLCTRL114_mark input.
  if TABLCTRL114-line_sel_mode = 1 and
     g_TABLCTRL114_wa-flag = 'X'.
     loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa
       where flag = 'X'.
       g_TABLCTRL114_wa-flag = ''.
       modify g_TABLCTRL114_itab
         from g_TABLCTRL114_wa
         transporting flag.
     endloop.
     g_TABLCTRL114_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL114_itab
    from g_TABLCTRL114_wa
    index TABLCTRL114-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: process user command
module TABLCTRL114_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL114'
                              'G_TABLCTRL114_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_114 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL114-top_line + g_cursor_line - 1.
  g_curr_line_114 = g_curr_line.

ENDMODULE.                 " get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data14 INPUT.

select single * from zsd_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

  if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
              not g_role_name_prev is initial.
      g_role_name_flag = 'X'.
  endif.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data14a INPUT.
if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zsd_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name and
                    disc_fi_fl = ZIC_PREP_ROLEREQ-disc_fi_flag.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       if ZIC_PREP_ROLEREQ-disc_fi_flag = 'X' and
       ZIC_PREP_ROLEREI-role_name = 'SXX'.
       else.
         message i118(zhelp).
       endif.
    else.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-SALE_ORG.
  clear  ZIC_PREP_ROLEREI-DIV.
  clear  ZIC_PREP_ROLEREI-PLANT.
  clear  ZIC_PREP_ROLEREI-SHIP_POINT.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
      clear g_role_name_flag.
      clear  ZIC_PREP_ROLEREI-SALE_ORG.
      clear  ZIC_PREP_ROLEREI-DIV.
      clear  ZIC_PREP_ROLEREI-PLANT.
      clear  ZIC_PREP_ROLEREI-SHIP_POINT.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

  select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_114.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-SALE_ORG is initial.

    select single * from tvko client specified into corresponding fields
             of it_tvko  where mandt = sy-mandt and
             bukrs =  zic_prep_rolereq-ccode and
             vkorg = ZIC_PREP_ROLEREI-SALE_ORG.

      if sy-subrc <> 0 and ZIC_PREP_ROLEREI-SALE_ORG <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            g_i = g_curr_line_114.
            message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
***
      else.
           if zic_prep_rolereq-ccode = 'MUM' and
              ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' and
              ZIC_PREP_ROLEREI-SALE_ORG <> 'MUMPHPOP'.
              g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
              g_i = g_curr_line_114.
              message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
           endif.
***
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-DIV is initial.

    select single * from tvkos client specified into corresponding
             fields of it_tvkos  where mandt = sy-mandt and
             vkorg =  ZIC_PREP_ROLEREI-SALE_ORG and
             spart =  ZIC_PREP_ROLEREI-DIV.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-DIV'.
            g_i = g_curr_line_114.
            message e187(zhelp) with ZIC_PREP_ROLEREI-DIV.

      endif.

   endif.


   if not ZIC_PREP_ROLEREI-SHIP_POINT is initial.

       select single * from tvswz into corresponding fields of
             it_tvswz  where werks = ZIC_PREP_ROLEREI-PLANT and
             vstel = ZIC_PREP_ROLEREI-SHIP_POINT.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
            g_i = g_curr_line.
            message e188(zhelp) with ZIC_PREP_ROLEREI-SHIP_POINT.

      endif.

    endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

        select * from zsd_prep_roledes into corresponding fields of
                 table it_role where
                    disc_fi_fl = ZIC_PREP_ROLEREQ-disc_fi_flag.
     loop at it_role .
        if it_role-role_type = zic_prep_rolerei-role_name.
           check_role_flag = 'X'.
        endif.
     endloop.

     if ZIC_PREP_ROLEREQ-disc_fi_flag = 'X' and
     ZIC_PREP_ROLEREI-role_name = 'SXX'.
       check_role_flag = 'X'.
     endif.

     if check_role_flag = 'X'.
        clear check_role_flag.
     else.
        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
        ZIC_PREP_ROLEREQ-ccode .
     endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno14 INPUT.

clear g_srno.
loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL114_wa-srno = g_srno.
      modify g_TABLCTRL114_itab from g_TABLCTRL114_wa.
endloop.
describe table g_TABLCTRL114_itab  lines g_lines_rl.
describe table g_TABLCTRL114_itab  lines TABLCTRL114-lines.
clear g_srno.

ENDMODULE.                 " change_srno14  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_SD INPUT.
loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


    select * from zsd_prep_roledes into corresponding fields of
               table it_role.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT_SD INPUT.

data : l_vkorg like tvkwz-vkorg.
data : l_div like ZIC_PREP_ROLEREI-DIV.

  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SALE_ORG'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_vkorg.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'DIV'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_div.

  data : it_tvkwz like table of tvkwz with header line.

*  select * from zd_t001w_bukrs into corresponding fields of
*             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

  SELECT * FROM TVTA INTO CORRESPONDING FIELDS OF TVTA UP TO 1 ROWS
 WHERE VKORG = L_VKORG AND SPART = L_DIV
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  select * from tvkwz into corresponding fields of
             table it_tvkwz  where vkorg =  l_vkorg
             and vtweg = tvta-vtweg.
    sort it_tvkwz by werks.
  delete adjacent duplicates from it_tvkwz comparing werks.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  g_field_wa-tabname = 'TVKWZ'.
  g_field_wa-fieldname = 'VKORG'.
  append g_field_wa to g_field_tab.
  g_field_wa-tabname = 'TVKWZ'.
  g_field_wa-fieldname = 'WERKS'.
  append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_TVKWZ
            FIELD_TAB       = G_FIELD_TAB
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

  REFRESH:IT_TVKWZ,IST_RETURN_TAB,G_FIELD_TAB.
  FREE : IT_TVKWZ,IST_RETURN_TAB,G_FIELD_TAB.

ENDMODULE.                 " POV_PLANT_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SALE_ORG_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SALE_ORG_SD INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SALE_ORG' and screen-input = 0.
        dis_flag = 'X'.
      endif.

 endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_role_type.

  select * from tvko client specified into corresponding fields of
             table it_tvko  where mandt = sy-mandt and
             bukrs =  zic_prep_rolereq-ccode.

  if zic_prep_rolereq-ccode = 'MUM'.
      loop at it_tvko.
      if ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP'.
         if it_tvko-vkorg = 'HZRS'.
         else.
          delete it_tvko.
         endif.
      else.
        if it_tvko-vkorg = 'HZRS'.
              delete it_tvko.
        endif.
      endif.
      endloop.
  endif.
  if l_role_type = 'SXX'.
    it_tvko-vkorg = 'ALL'.
    it_tvko-bukrs = 'ALL'.
    append it_tvko.
  endif.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'TVKO'.
 g_field_wa-fieldname = 'VKORG'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'TVKO'.
 g_field_wa-fieldname = 'BUKRS'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'VKORG'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SALE_ORG'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_TVKO
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_TVKO,IST_RETURN_TAB,G_FIELD_TAB.
  FREE : IT_TVKO,IST_RETURN_TAB,G_FIELD_TAB.


ENDMODULE.                 " POV_SALE_ORG_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_DIV_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_DIV_SD INPUT.

*  data : l_vkorg like tvkos-vkorg.

  loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-DIV' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'SALE_ORG'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_vkorg.


  select * from tvkos client specified into corresponding fields of
             table it_tvkos  where mandt = sy-mandt and
             vkorg =  l_vkorg.

*  delete adjacent  duplicates from it_tvkos comparing werks.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  g_field_wa-tabname = 'TVKOS'.
  g_field_wa-fieldname = 'VKORG'.
  append g_field_wa to g_field_tab.
  g_field_wa-tabname = 'TVKOS'.
  g_field_wa-fieldname = 'SPART'.
  append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'SPART'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-DIV'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_TVKOS
            FIELD_TAB       = G_FIELD_TAB
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

  REFRESH:IT_TVKOS,IST_RETURN_TAB,G_FIELD_TAB.
  FREE : IT_TVKOS,IST_RETURN_TAB,G_FIELD_TAB.

ENDMODULE.                 " POV_DIV_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHIP_POINT_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHIP_POINT_SD INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-SHIP_POINT' and screen-input =
0.
        dis_flag = 'X'.
      endif.

  endloop.

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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_plant.

 CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'DIV'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0114'
       IMPORTING
            VALUE = l_div.

*  select * from tvswz into corresponding fields of
*             table it_tvswz  where werks = l_plant.

   select single * from ZSD_PREP_LDGGRP into corresponding fields of
             ZSD_PREP_LDGGRP  where div = l_div.

   select * from tvstz into corresponding fields of table it_tvstz
            where ladgr = zsd_prep_ldggrp-ladgr and
            werks = l_plant.

************************************
 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
 endif.

  g_field_wa-tabname = 'TVSTZ'.
  g_field_wa-fieldname = 'WERKS'.
  append g_field_wa to g_field_tab.
  g_field_wa-tabname = 'TVSTZ'.
  g_field_wa-fieldname = 'VSTEL'.
  append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'VSTEL'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = it_tvstz
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_tvstz,IST_RETURN_TAB,g_field_tab..
  FREE  : IT_tvstz,IST_RETURN_TAB,g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " SHIP_POINT_SD  INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: modify table
module TABLCTRL115_modify input.
  move moduleid to ZIC_PREP_ROLEREI-MODULEID.
  if ZIC_PREP_ROLEREI-rej_fl is initial.
     clear : ZIC_PREP_ROLEREI-rej_id, ZIC_PREP_ROLEREI-rej_date.
  endif.
  move-corresponding ZIC_PREP_ROLEREI to g_TABLCTRL115_wa.
  select single * from zqm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zic_prep_rolerei-role_name .
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
    endif.

    g_TABLCTRL115_wa-role_desc = zqm_prep_roledes-brief_desc.
  modify g_TABLCTRL115_itab
    from g_TABLCTRL115_wa
    index TABLCTRL115-current_line.
  if sy-subrc <> 0.
      append g_TABLCTRL115_wa to g_TABLCTRL115_itab.
  endif.

    if G_TABLCTRL115_WA-FLAG = 'X' and okcode_100 = 'COPY'.
     clear G_TABLCTRL115_WA-FLAG.
            append g_TABLCTRL115_wa to g_TABLCTRL115_itab.
    endif.
endmodule.

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: mark table
module TABLCTRL115_mark input.
  if TABLCTRL115-line_sel_mode = 1 and
     g_TABLCTRL115_wa-flag = 'X'.
     loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa
       where flag = 'X'.
       g_TABLCTRL115_wa-flag = ''.
       modify g_TABLCTRL115_itab
         from g_TABLCTRL115_wa
         transporting flag.
     endloop.
     g_TABLCTRL115_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL115_itab
    from g_TABLCTRL115_wa
    index TABLCTRL115-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: process user command
module TABLCTRL115_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TABLCTRL115'
                              'G_TABLCTRL115_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_QM INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


    select * from zqm_prep_roledes into corresponding fields of
               table it_role.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

  clear ZIC_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'ROLE_TYPE'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'BRIEF_DESC'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC1'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
 g_field_wa-fieldname = 'DETAIL_DESC2'.
 append g_field_wa to g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            FIELD_TAB       = g_field_tab
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

  REFRESH:IT_ROLE,IST_RETURN_TAB, g_field_tab.
  FREE  : IT_ROLE,IST_RETURN_TAB, g_field_tab.
  Clear : g_field_wa.

ENDMODULE.                 " POV_ROLE_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT_QM INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-PLANT' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

  select * from zqm_prep_loc into corresponding fields of
             table it_plant.

   if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'PLANT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_PLANT
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

  REFRESH:IT_PLANT,IST_RETURN_TAB.
  FREE : IT_PLANT,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_115 INPUT.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL115-top_line + g_cursor_line - 1.
  g_curr_line_115 = g_curr_line.

ENDMODULE.                 " get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data15 INPUT.
select single * from zqm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.

if g_role_name_prev <> ZIC_PREP_ROLEREI-role_name and
            not g_role_name_prev is initial.
    g_role_name_flag = 'X'.
endif.
g_read_fl = 'X'.
ENDMODULE.                 " validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno15 INPUT.
clear g_srno.
loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa.
      g_srno = g_srno + 1.
      g_TABLCTRL115_wa-srno = g_srno.
      modify g_TABLCTRL115_itab from g_TABLCTRL115_wa.
endloop.
describe table g_TABLCTRL115_itab  lines g_lines_rl.
describe table g_TABLCTRL115_itab  lines TABLCTRL115-lines.
clear g_srno.
ENDMODULE.                 " change_srno15  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ASSET_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ASSET_QM INPUT.

loop at screen.

      if screen-name = 'ZIC_PREP_ROLEREI-ASSET_QM' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.

     select * from zqm_prep_asset into corresponding fields of table
               it_asset where ccode = ZIC_PREP_ROLEREQ-CCODE.

  if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ASSET'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ASSET_QM'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag

       TABLES
            VALUE_TAB       = IT_ASSET
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

  REFRESH:IT_ASSET,IST_RETURN_TAB.
  FREE  : IT_ASSET,IST_RETURN_TAB.
  CLEAR : IT_ASSET.

ENDMODULE.                 " POV_ASSET_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_module_fi  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_module_fi INPUT.
  if ( old_ok_code = 'CHANGE' or
  old_ok_code = 'DISPLAY' ) and moduleid = 'FI'.
     select single * from zic_prep_rolerei into
                     corresponding fields of wa_module1 where
                     docno = zic_prep_rolereq-docno and
                     moduleid = 'FI'.
     if sy-subrc <> 0.
        if old_ok_code = 'CHANGE'.
          message e196(zhelp) with zic_prep_rolereq-docno.
        else.
          message e198(zhelp) with zic_prep_rolereq-docno.
        endif.
     endif.
  endif.
ENDMODULE.                 " check_module_fi  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data15a INPUT.

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

    select single * from zqm_prep_roledes where role_type =
                    ZIC_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

elseif g_e_fl = 'X'.
       clear g_e_fl.
  else.
  clear  ZIC_PREP_ROLEREI-ASSET_QM.
  clear  ZIC_PREP_ROLEREI-plant.
  clear g_read_fl.

endif.

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZIC_PREP_ROLEREI-ASSET_QM.
     clear  ZIC_PREP_ROLEREI-plant.
endif.


g_field = 'ZIC_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZIC_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ASSET_QM is initial.

    if ZIC_PREP_ROLEREQ-CCODE = 'MUM' or ZIC_PREP_ROLEREQ-CCODE = 'KKL'.

      select single * from ZQM_PREP_ASSET into zqm_prep_asset where
                      ccode =  ZIC_PREP_ROLEREQ-CCODE and
                      asset =  ZIC_PREP_ROLEREI-ASSET_QM.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET_QM'.
            g_i = g_curr_line.
           message e172(zhelp) with ZIC_PREP_ROLEREI-asset_qm.
      endif.

    endif.

   endif.

   if not ZIC_PREP_ROLEREI-role_name is initial.

     select * from zqm_prep_roledes into corresponding fields of
                 table it_role.

     if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
            g_i = g_curr_line.
           message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.

      endif.

   endif.

endif.

ENDMODULE.                 " validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fundc_data INPUT.

 select single * from fmzuob where fistl = ZIC_PREP_ROLEREQ-fundc.
  if sy-subrc <> 0.
     message i166(zhelp).
     g_field =  'ZIC_PREP_ROLEREQ-FUNDC'.
  endif.

ENDMODULE.                 " validate_fundc_data  INPUT
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
*  Data : l_role_type like ZIC_PREP_ROLEREI-ROLE_NAME.
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
            STRUC = 'ZIC_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0110'
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
 ist_return_tab1-dyfldname = 'ZIC_PREP_ROLEREI-ROLE_TYPE_EX'.
 append ist_return_tab1 to ist_return_tab1.
* g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
 ist_return_tab1-fldname = 'ROLE_TYPE'.
 ist_return_tab1-dyfldname = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
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
    concatenate 'ZIC_PREP_ROLEREI-' IST_RETURN_TAB-fieldname into
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
  FREE  : IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1.

ENDMODULE.                 " POV_CRC_POS  INPUT

*--- INCLUDE: MZMMPREPROLE1_PHASEII_ADMNO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 345.
************************************************************************
MODULE STATUS_0100 OUTPUT.

Perform fill_sttab.

  SET PF-STATUS 'OPTNS' excluding it_tab.

 case old_ok_code.
    when 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' with ': Create Request'.
    when 'CROSSCO'.
      SET TITLEBAR 'PREP_TITLE' with
      ': Cross Company '.
    when 'CRCROLES'.
      SET TITLEBAR 'PREP_TITLE' with ': CRC '.
    when 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' with ': Change Request'.
    when 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' with ': Display Request'.
*      SET PF-STATUS 'OPTNSX' excluding it_tab.
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

if not ZIC_PREP_ROLEREQ-docno is initial.

  data : l_docno like ZIC_PREP_ROLEREQ-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

  ZIC_PREP_ROLEREQ-docno = l_docno.

endif.

if  g_hd_copied <> 'X'.
*
if old_ok_code is initial and okcode_100 is initial.

   else.

   if ( old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' ) and
                                    okcode_100 is initial.

    else.

      if ( old_ok_code = 'CHANGE' ) OR ( old_ok_code = 'DELETE' )
          or ( old_ok_code = 'RELEASE' )
          or ( OLD_OK_CODE = 'APPROVE' ).
        if not ZIC_PREP_ROLEREQ-docno is initial.
          perform lock_reqhd.
        endif.
      endif.

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

      if not ZIC_PREP_ROLEREQ-docno is initial.

        select single * from ZIC_PREP_ROLEREQ
                   where DOCNO = ZIC_PREP_ROLEREQ-docno.

        if sy-subrc = 0 .

            if g_l4 = 'X' and old_ok_code = 'APPROVE'.
               ZIC_PREP_ROLEREQ-RADIO_FL = 'X'.
            endif.

*           select single moduleid from zic_prep_rolerei into
*           moduleid where DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

           select distinct moduleid from zic_prep_rolerei into
           corresponding fields of table it_module1 where DOCNO =
           ZIC_PREP_ROLEREQ-DOCNO.
****
           SORT IT_MODULE1 BY MODULEID. read table it_module1 index 1 into wa_module1.
           if moduleid is initial.
             moduleid = wa_module1-moduleid.
**** 13/04/07
             old_moduleid = moduleid.
           endif.
****
           data : l_module_lines like sy-index.

           describe table it_module1 lines l_module_lines.

           if l_module_lines > 1.
              g_mult_module_fl = 'X'.
           endif.

            g_hd_copied = 'X'.
** check line items modulewise/initialise
            g_TABLCTRL110_copied = ''.
            g_TABLCTRL111_copied = ''.
            g_TABLCTRL112_copied = ''.
            g_TABLCTRL113_copied = ''.
            g_TABLCTRL114_copied = ''.
            g_TABLCTRL115_copied = ''.

**
*
*            if ZIC_PREP_ROLEREQ-comm_fl = 'X' and old_ok_code =
*'CHANGE'
*.
*              perform verify2.
*            endif.

            perform validations.

        else.
           message i101(zhelp) with ZIC_PREP_ROLEREQ-docno.
        endif.

       endif.

      endif.

      select single * from T500P
                 where PERSA = ZIC_PREP_ROLEREQ-PERSA.

      if sy-subrc = 0.

          ZIC_PREP_ROLEREQ-NAME1 = T500P-NAME1.

      endif.


   endif.

endif.

      select single * from ZMM_PREP_RSN
                 where REASON = ZIC_PREP_ROLEREQ-RSN_CODE.

      if sy-subrc = 0.

          ZIC_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

      endif.

      select single * from ZMM_PREP_STATUS
                 where STATUS_CODE = ZIC_PREP_ROLEREQ-STATUS .

      if sy-subrc = 0.

          STATUS_DESC = ZMM_PREP_STATUS-STATUS_DESC.

      endif.


    if ZIC_PREP_ROLEREQ-fundc <> '' and ZIC_PREP_ROLEREQ-REASON1 = ''.

       set cursor field 'ZIC_PREP_ROLEREQ-REASON1'.
        message i100(zhelp).
    endif.

    perform crc_module_checking.

    perform get_correspondence.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

CASE old_ok_code.

  when ''.

     loop at screen.
          screen-input = 0.
          modify screen.
      endloop.

  when 'CREATE' or 'ROLE_DEL'.

     loop at screen.

       if screen-group1 = 'GP1'.
         if moduleid <> 'MM' and screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
         else.
          screen-input = 1.
          screen-required = 1.
         endif.
          modify screen.
       endif.

       if screen-group2 = 'GP2'.
            screen-required = 0.
           modify screen.
       endif.

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
           if ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
*             perform pop_up_message.
           else.
            clear : ZIC_PREP_ROLEREQ-PERSA, ZIC_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'MODULEID' and moduleid <> ''
           and ZIC_PREP_ROLEREQ-USERID <> ''.
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'MODULEID' and old_ok_code = 'ROLE_DEL'.
           MODULEID = 'FI'.
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.

    endloop.

    when 'CHANGE'.

     loop at screen.

       if screen-group1 = 'GP1'.
         if moduleid <> 'MM' and screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
         else.
          screen-input = 1.
          screen-required = 0.
         endif.
          modify screen.
       endif.

       if screen-group2 = 'GP2'.
         if moduleid <> 'MM' and screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
         else.
          screen-input = 1.
          screen-required = 0.
         endif.
          modify screen.
       endif.

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-USERID' and
           ZIC_PREP_ROLEREQ-USERID <> ''.
           screen-input = 0.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-group3 = 'GPC' .
           if ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
             screen-active = 1.
           else.
             screen-active = 0.
           endif.
           screen-invisible = 0.
           modify screen.
       endif.

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
            screen-input = 0.
            modify screen.
       endif.

      if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.

*Begin of <RD1K963151>.
if screen-name = 'ZIC_PREP_ROLEREQ-USERIDCR' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    endif.


IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-CR_DATE' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    ENDIF.

IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-USERIDAP' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    ENDIF.


IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-APP_DATE' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    ENDIF.
*End of <RD1K963151>.
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

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-REQ_CR_FL'.
            screen-input = 1.
            modify screen.
       endif.

       if screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

        if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
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

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-input = 0.
              modify screen.
       endif.

*       if screen-name = 'TABCTRL100_DELETE' or
*           screen-name = 'TABCTRL100_INSERT' or
*           screen-name = 'COPY'.
*              screen-input = 0.
*              modify screen.
*       endif.

       if g_user = 'L1' and screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP1_FL'
.
              screen-input = 1.
              modify screen.
       endif.

       if ( g_user = 'IM' ) and
           screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP0_FL'.
              screen-input = 1.
              modify screen.
       endif.
       if ( g_user = 'L3' ) and
           screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP_FL'.
              screen-input = 1.
              modify screen.
       endif.

       if screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.

       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-FUNDC' or
          screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          screen-input = 0.
          modify screen.
       endif.

     endloop.

    when 'CROSSCO'.

     loop at screen.

       if screen-group1 = 'GP1' or
           screen-group4 = 'GP4'.
           screen-input = 1.
           if screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-required = 0.
           else.
              screen-required = 1.
           endif.
           modify screen.
       endif.

       if screen-group2 = 'GP2'.
            screen-required = 0.
           modify screen.
       endif.

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
           if ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZIC_PREP_ROLEREQ-PERSA, ZIC_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC' .
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'MODULEID' and moduleid <> ''
           and ZIC_PREP_ROLEREQ-USERID <> ''.
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-CCODE' and
          not ZIC_PREP_ROLEREQ-CCODE is initial .
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-FUNDC_FL' or
          screen-name = 'IN'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

        if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.

    endloop.

    when 'DISPLAY'.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'       or
*          screen-name = 'MODULEID'    or
          screen-name = 'DETAILS'     or
          screen-name = 'CORR' or screen-name = 'STAT' or
          screen-name = 'M'    or screen-name = 'TABCTRL100_PREVIOUS'
                               or screen-name = 'TABCTRL100_NEXT'.
           screen-input = 1.
           screen-required = 1.
           modify screen.
       else.
           screen-input = 0.
           modify screen.
       endif.

        if screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       endif.

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.


    endloop.

    when 'DELETE'.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                 or screen-name = 'STAT'
.
           screen-input = 1.
           screen-required = 1.
           modify screen.
       else.
           screen-input = 0.
           modify screen.
       endif.

        if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.

    endloop.

    when 'CRCROLES'.

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

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
           if ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZIC_PREP_ROLEREQ-PERSA, ZIC_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'MODULEID'.
           screen-input = 0.
           modify screen.
       endif.

          if ( screen-name = 'ZIC_PREP_ROLEREQ-FR_DATE_AUTH' or
                screen-name = 'ZIC_PREP_ROLEREQ-TO_DATE_AUTH' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 0.
          else.
            if ( screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_NO' or
                screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_DATE' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 1.
            endif.

           endif.

           if ( screen-name = 'OONO' or screen-name = 'DT1'  or
                screen-name = 'DT2' or screen-name = 'DT3' ).
                screen-invisible = 0.
                screen-active = 1.
           endif.

            modify screen.

        if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.

*added on 05/03/2007
        if screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-input = 1.
              modify screen.
        endif.

    endloop.

ENDCASE.
ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL100_init output.

  perform check_auth.

  perform get_user.

**   if g_hd_copied is initial.
**    refresh control 'TABCTRL100' from screen '0100'.
    data l_fis_initial.
    set parameter id 'FIS' field l_fis_initial.
    set parameter id 'BUK' field l_fis_initial.
**  endif.

endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: move itab to dynpro
module TABCTRL100_move output.
  move-corresponding g_TABCTRL100_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    if old_ok_code = 'CRCROLES' or ZIC_PREP_ROLEREQ-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 .
         move zmm_prep_rolecrc-brief_desc to role_desc.
     endif.
    else.
      select single * from zmm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zmm_prep_roledes-brief_desc to role_desc.
     endif.
    endif.

  endif.
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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
          COLOR COL_HEADING.
  ULINE.
  if flag_s_fundc = 'X'.
    PERFORM HELP_LIST.
  endif.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_120 OUTPUT.
   SET PF-STATUS 'STATUS_120'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

  if old_ok_code <> 'CRCROLES'.
      if old_ok_code = 'CREATE'.
      elseif ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
         CRC_CHECK_FL = 'X'.
      endif.
  else.
      CRC_CHECK_FL = 'X'.
  endif.

   if CRC_CHECK_FL <> 'X' .

      clear CRC_CHECK_FL.

    select single * from zmm_prep_roledes where role_type =
                                              g_TABCTRL100_wa-role_name.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zmm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP'.

            if zmm_prep_roledes-P_GRP = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
             else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

              if zmm_prep_roledes-APP_LEVEL = 'X' and
                          old_ok_code <> 'APPROVE'.
                  screen-input = 1.
                  modify screen.
              else.
                  screen-input = 0.
                  modify screen.
              endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

                if zmm_prep_roledes-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_roledes-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

       endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

  if ZIC_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc = 0.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .


           if zmm_prep_rolecrc-plant = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP' .


           if zmm_prep_rolecrc-P_GRP = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

                if zmm_prep_rolecrc-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

     endloop.

     else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                            not old_ok_code is initial.
            screen-input = 1.
            modify screen.

            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial.
              message i116(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
           else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

  endif.

endif.

else.

         loop at screen.

              screen-input = 0.
              modify screen.
*
         endloop.
*

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

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

perform get_correspondence.

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

  if ( old_ok_code = 'CREATE' )
  or ( old_ok_code = 'CROSSCO' )
  or ( old_ok_code = 'CRCROLES' )
  or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' )
  or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X' and
       ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

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
  if ( old_ok_code = 'CREATE' )
      or ( old_ok_code = 'CROSSCO' )
      or ( old_ok_code = 'CRCROLES' )
      or ( old_ok_code = 'CHANGE' )
      or ( old_ok_code = 'RELEASE' )
      or ( OLD_OK_CODE = 'APPROVE' )
       or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'
            and ZIC_PREP_ROLEREQ-STATUS <> 'C').

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
MODULE delete_dup OUTPUT.

*if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

if not g_TABCTRL100_itab[] is initial .

  sort g_TABCTRL100_itab
  by role_name plant grp sloc receipt_loc approver.
  delete adjacent duplicates from g_TABCTRL100_itab
  comparing role_name plant grp sloc receipt_loc approver.

endif.

describe table g_TABCTRL100_itab lines TABCTRL100-lines.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_110 OUTPUT.

describe table g_TABLCTRL110_itab lines TABLCTRL110-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_110
.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
   g_text = ' : Cross Company Authorisation'.
   SET TITLEBAR 'PREP_TITLE' with g_text.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.
if old_ok_code = 'CREATE' and ( okcode_100 = '' or
    okcode_100 = 'CREATE' ) .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'LIST' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.
if old_ok_code = 'CHANGE' and ( okcode_100 = '' or
    okcode_100 = 'CHANGE' or okcode_100 = 'LIST' ) .
    if ZIC_PREP_ROLEREQ-CRC_FL = 'X' or
       ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    else.
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    endif.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DELETE' and ( okcode_100 = '' or
    okcode_100 = 'DELETE' or okcode_100 = 'LIST' ) .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DISPLAY'
   and ZIC_PREP_ROLEREQ-comm_fl = 'X'.
   SET PF-STATUS 'OPTNS' excluding it_tab.
else.

  if old_ok_code = 'DISPLAY' and ( okcode_100 = '' or
      okcode_100 = 'DISPLAY' or okcode_100 = 'LIST' ) .
      move 'ATTACH' to wa_tab-fcode.
      append wa_tab to it_tab.
      SET PF-STATUS 'OPTNS' excluding it_tab.
  endif.

endif.

if old_ok_code = 'APPROVE' and ( okcode_100 = '' or
    okcode_100 = 'APPROVE' or okcode_100 = 'LIST' ) .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    g_text = ' : CRC Authorisation'.
    SET TITLEBAR 'PREP_TITLE' with g_text.
endif.

ENDMODULE.                 " set_title  OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL110_init output.
  if g_TABLCTRL110_copied is initial and old_ok_code <> 'CREATE'.

    refresh g_TABLCTRL110_itab[].
    clear   g_TABLCTRL110_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL110_itab where moduleid = 'MM' and
                docno = zic_prep_rolereq-docno ORDER BY PRIMARY KEY.
    g_TABLCTRL110_copied = 'X'.
    read table g_tablctrl110_itab into g_tablctrl110_wa index 1.
    if sy-subrc = 0.
       MODULEID = g_tablctrl110_wa-moduleid.
    endif.
    refresh control 'TABLCTRL110' from screen '0110'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL110_move output.

  move-corresponding g_TABLCTRL110_wa to ZIC_PREP_ROLEREI.

  if not ZIC_PREP_ROLEREI-role_name is initial.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    if old_ok_code = 'CRCROLES' or zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 .
         move zmm_prep_rolecrc-brief_desc to role_desc.
     endif.
     SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 and ZIC_PREP_ROLEREI-PLANT <> ''.
         move zmm_prep_crcdesg-crc_pos to crc_pos.
     endif.
    else.
      select single * from zmm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zmm_prep_roledes-brief_desc to role_desc.
     endif.
    endif.

  endif.

endmodule.

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL110_get_lines output.
  g_TABLCTRL110_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_dynnr OUTPUT.
if dynnr is initial.
   dynnr = '101'.
endif.
case moduleid.

  when 'MM'.
    dynnr = '0110'.
  when 'PM'.
    dynnr = '0111'.
  when 'PS'.
    dynnr = '0112'.
  when 'PP'.
    dynnr = '0113'.
  when 'SD'.
    dynnr = '0114'.
  when 'QM'.
    dynnr = '0115'.

endcase.
ENDMODULE.                 " set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_col_attrib OUTPUT.

LOOP AT TABLCTRL110-cols INTO cols WHERE index GT 11.
      cols-invisible = '1'.
      MODIFY TABLCTRL110-cols FROM cols INDEX sy-tabix.
ENDLOOP.

LOOP AT TABLCTRL110-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY TABLCTRL110-cols FROM cols INDEX sy-tabix.
ENDLOOP.

ENDMODULE.                 " scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_110 OUTPUT.

if not g_TABLCTRL110_itab[] is initial .

  sort g_TABLCTRL110_itab
  by role_name plant grp sloc receipt_loc approver.
  delete adjacent duplicates from g_TABLCTRL110_itab
  comparing role_name plant grp sloc receipt_loc approver.

endif.

describe table g_TABLCTRL110_itab lines TABLCTRL110-lines.

ENDMODULE.                 " delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL110_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

  if old_ok_code <> 'CRCROLES'.
      if old_ok_code = 'CREATE'.
      elseif ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
         CRC_CHECK_FL = 'X'.
      endif.
  else.
      CRC_CHECK_FL = 'X'.
  endif.

   if CRC_CHECK_FL <> 'X' .

      clear CRC_CHECK_FL.

    select single * from zmm_prep_roledes where role_type =
                                              g_TABLCTRL110_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zmm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP'.

            if zmm_prep_roledes-P_GRP = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
             else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

              if zmm_prep_roledes-APP_LEVEL = 'X' and
                          old_ok_code <> 'APPROVE'.
                  screen-input = 1.
                  modify screen.
              else.
                  screen-input = 0.
                  modify screen.
              endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

                if zmm_prep_roledes-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_roledes-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

       endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

  if ZIC_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABLCTRL110_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc = 0.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .


           if zmm_prep_rolecrc-plant = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP' .


           if zmm_prep_rolecrc-P_GRP = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

                if zmm_prep_rolecrc-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.
**
        if screen-name = 'CRC_POS' and
              ( ZIC_PREP_ROLEREI-role_name <> 'M3B' and
                ZIC_PREP_ROLEREI-role_name <> 'M11S' and
                ZIC_PREP_ROLEREI-role_name <> 'M11M' ).
                if old_ok_code <> 'APPROVE'.
                    screen-required = 1.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-APPROVER' and
               ( ZIC_PREP_ROLEREI-role_name = 'M3B' or
                ZIC_PREP_ROLEREI-role_name = 'M11S' or
                ZIC_PREP_ROLEREI-role_name = 'M11M' ).
.          screen-input = 1.
        elseif screen-name = 'ZIC_PREP_ROLEREI-APPROVER' and
               ( ZIC_PREP_ROLEREI-role_name <> 'M3B' and
                ZIC_PREP_ROLEREI-role_name <> 'M11S' and
                ZIC_PREP_ROLEREI-role_name <> 'M11M' ).
           screen-input = 0.
        endif.

        modify screen.

**

     endloop.

     else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                            not old_ok_code is initial.
            screen-input = 1.
            modify screen.

            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial.
              message i116(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
           else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

  endif.

endif.

else.

         loop at screen.

              screen-input = 0.
              modify screen.
*
         endloop.
*

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

ENDMODULE.                 " TABLCTRL110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL111_init output.
  if g_TABLCTRL111_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL111_itab[].
    clear   g_TABLCTRL111_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL111_itab where moduleid = 'PM' and
                docno = zic_prep_rolereq-docno.
    g_TABLCTRL111_copied = 'X'.
    refresh control 'TABLCTRL111' from screen '0111'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL111_move output.

move-corresponding g_TABLCTRL111_wa to ZIC_PREP_ROLEREI.
if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zpm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zpm_prep_roledes-brief_desc to role_desc.
     endif.
endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL111_get_lines output.
  g_TABLCTRL111_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_111 OUTPUT.
if not g_TABLCTRL111_itab[] is initial .

  sort g_TABLCTRL111_itab
  by role_name plant shop_no.
  delete adjacent duplicates from g_TABLCTRL111_itab
  comparing role_name plant shop_no.

endif.

describe table g_TABLCTRL111_itab lines TABLCTRL111-lines.

ENDMODULE.                 " delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL111_attrib OUTPUT.
  if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zpm_prep_roledes where role_type =
                                              g_TABLCTRL111_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zpm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SHOP_NO' .

            if zpm_prep_roledes-shop_no = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.


     endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

ENDMODULE.                 " TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_111 OUTPUT.

describe table g_TABLCTRL111_itab lines TABLCTRL111-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_111
.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_col_attrib OUTPUT.

LOOP AT TABLCTRL111-cols INTO cols WHERE index GT 8.
      cols-invisible = '1'.
      MODIFY TABLCTRL111-cols FROM cols INDEX sy-tabix.
ENDLOOP.

ENDMODULE.                 " scr111_col_attrib  OUTPUT
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

    g_release = ZIC_PREP_ROLEREQ-req_cr_fl.
    g_approve = ZIC_PREP_ROLEREQ-req_app_fl.
    g_approve0 = ZIC_PREP_ROLEREQ-req_app0_fl.
    g_approve1 = ZIC_PREP_ROLEREQ-req_app1_fl.

    select single * from ZIC_PREP_ROLEREQ
                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

    if ZIC_PREP_ROLEREQ-req_cr_fl is initial.
      ZIC_PREP_ROLEREQ-req_cr_fl = g_release.
    endif.
    if ZIC_PREP_ROLEREQ-req_app_fl is initial.
      ZIC_PREP_ROLEREQ-req_app_fl = g_approve.
    endif.
    if ZIC_PREP_ROLEREQ-req_app1_fl is initial.
      ZIC_PREP_ROLEREQ-req_app1_fl = g_approve1.
    endif.

    if ZIC_PREP_ROLEREQ-req_app0_fl is initial.
      ZIC_PREP_ROLEREQ-req_app0_fl = g_approve0.
    endif.


    clear : g_release, g_approve, g_approve0, g_approve1.

*  select single * from zic_prep_rolereq
*  where docno = zic_prep_rolereq-docno.

  select * from zic_prep_rolerei into table ist_item
  where docno = zic_prep_rolereq-docno.

ENDMODULE.                 " SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list1 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  data : l_desc(30).

  sort ist_item descending.

  loop at ist_item into wa_item.
   case wa_item-moduleid.
    when 'MM'.
        perform check_module_status_mm.
    when 'PM'.
          perform check_module_status_pm.
    when 'PS'.
          perform check_module_status_ps.
    when 'PP'.
          perform check_module_status_pp.
    when 'SD'.
          perform check_module_status_sd.
    when 'QM'.
          perform check_module_status_qm.
   endcase.
  endloop.

  loop at ist_item into wa_item.

  case wa_item-moduleid .

  when 'MM'.

    at new moduleid.

    write :/.

    if mm_not_ok = 'X'.
     format intensified on color 6.
    else.
     format intensified on color 5.
    endif.

    write: / 'MM Module', 'Role', 'Description',
           at 48  'Plant',
           at 53  'PurGp',
           at 59  'Sloc',
           at 64  'RecptLoc',
           at 73  'User level' .

     format intensified off color off.

*     uline.

     endat.

     if ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT BRIEF_DESC FROM ZMM_PREP_ROLECRC INTO L_DESC UP TO 1 ROWS
 WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     else.

      select single brief_desc from zmm_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    endif.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 53 wa_item-grp,
             at 59 wa_item-sloc,
             at 64 wa_item-receipt_loc,
             at 73 wa_item-approver.

  when 'PM'.

    at new moduleid.

        WRITE /.

     if pm_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'PM Module', 'Role', 'Description',
           at 48  'Plant',
           at 54  'ShopNo'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zpm_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 54 wa_item-shop_no.

**
  when 'PS'.

    at new moduleid.

        WRITE /.

     if ps_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'PS Module', 'Role', 'Description',
           at 48  'Service',
           at 56  'Project',
           at 64  'Location',
           at 73  'Asset',
           at 79  'Basin'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zps_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-service,
             at 56 wa_item-project,
             at 64 wa_item-location,
             at 73 wa_item-asset,
             at 79 wa_item-basin.

***

 when 'PP'.

    at new moduleid.

        WRITE /.

     if pp_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'PP Module', 'Role', 'Description',
           at 48  'Plant',
           at 56  'Sloc',
           at 64  'Resource',
           at 73  'CTF_sloc'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zpp_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 56 wa_item-sloc,
             at 64 wa_item-res,
             at 73 wa_item-CTF_sloc.

  when 'SD'.

    at new moduleid.

        WRITE /.

     if sd_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'SD Module', 'Role', 'Description',
           at 48  'S_Org',
           at 56  'Div',
           at 64  'Plant',
           at 73  'ShPt'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zsd_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-sale_org,
             at 56 wa_item-div,
             at 64 wa_item-plant,
             at 73 wa_item-ship_point.

    when 'QM'.

    at new moduleid.

        WRITE /.

     if qm_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'QM Module', 'Role', 'Description',
           at 48  'Plant',
           at 56  'Asset'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zqm_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 56 wa_item-asset_qm.

  endcase.

*
    HIDE : wa_item-moduleid, wa_item-role_name, wa_item-plant,
             wa_item-grp, wa_item-sloc, wa_item-receipt_loc,
             wa_item-approver, wa_item-service, wa_item-project,
             wa_item-location,wa_item-region,wa_item-asset,
             wa_item-basin,wa_item-res, wa_item-CTF_sloc,
             wa_item-sale_org,wa_item-div,wa_item-plant,
             wa_item-ship_point,wa_item-asset_qm.

  endloop.

ENDMODULE.                 " value_list1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_attrib OUTPUT.
loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL111_DELETE' or
           screen-name = 'TABLCTRL111_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.
ENDMODULE.                 " scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_attrib OUTPUT.

 loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL110_DELETE' or
           screen-name = 'TABLCTRL110_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.

ENDMODULE.                 " scr110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL112_init output.
  if g_TABLCTRL112_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL112_itab[].
    clear   g_TABLCTRL112_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL112_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL112_itab where moduleid = 'PS' and
                docno = zic_prep_rolereq-docno.
    g_TABLCTRL112_copied = 'X'.
    refresh control 'TABLCTRL112' from screen '0112'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL112_move output.

  move-corresponding g_TABLCTRL112_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zps_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zps_prep_roledes-brief_desc to role_desc.
     endif.
endif.

endmodule.

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL112_get_lines output.
  g_TABLCTRL112_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr112_col_attrib OUTPUT.
LOOP AT TABLCTRL112-cols INTO cols WHERE index GT 11.
      cols-invisible = '1'.
      MODIFY TABLCTRL112-cols FROM cols INDEX sy-tabix.
ENDLOOP.
ENDMODULE.                 " scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr112_attrib OUTPUT.
loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL112_DELETE' or
           screen-name = 'TABLCTRL112_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.
ENDMODULE.                 " scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL112_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> '' and
    not g_TABLCTRL112_wa-role_name is initial.

    select single * from zps_prep_roledes where role_type =
                      g_TABLCTRL112_wa-role_name.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SERVICE' .

*            if zps_prep_roledes-service = 'X' and
             if old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PROJECT' .

            if zps_prep_roledes-project = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-LOCATION' .

            if zps_prep_roledes-location = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

*        if screen-name = 'ZIC_PREP_ROLEREI-REGION' .
*
*            if zps_prep_roledes-region = 'X' and
*                          old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*                modify screen.
*            else.
*                screen-input = 0.
*                modify screen.
*            endif.
*
*        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-ASSET' .

            if zps_prep_roledes-asset = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-BASIN' .

            if zps_prep_roledes-basin = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

     endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.
     endif.
endif.

if old_ok_code = 'DISPLAY'.

       loop at screen.
          screen-input = 0.
          modify screen.
        endloop.

 endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

ENDMODULE.                 " TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_112 OUTPUT.

describe table g_TABLCTRL112_itab lines TABLCTRL112-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_112
.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_112  OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL113_init output.
  if g_TABLCTRL113_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL113_itab[].
    clear   g_TABLCTRL113_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL113_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL113_itab where moduleid = 'PP' and
       docno = zic_prep_rolereq-docno.
    g_TABLCTRL113_copied = 'X'.
    refresh control 'TABLCTRL113' from screen '0113'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL113_move output.
  move-corresponding g_TABLCTRL113_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zpp_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zpp_prep_roledes-brief_desc to role_desc.
     endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL113_get_lines output.
  g_TABLCTRL113_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL113_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zpp_prep_roledes where role_type =
                                              g_TABLCTRL113_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zpp_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SLOC' .

            if zpp_prep_roledes-sloc = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RES'.

             select * from zpp_prep_res into corresponding fields of
             table it_res  where role_type = ZIC_PREP_ROLEREI-ROLE_NAME
             and plant = ZIC_PREP_ROLEREI-PLANT.

            if sy-subrc = 0  and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-CTF_SLOC' .

         select single * from ZPP_PREP_DROLEEX where
             role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
             plant = ZIC_PREP_ROLEREI-PLANT and
             sloc = ZIC_PREP_ROLEREI-SLOC.

            if sy-subrc = 0 and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

      endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

ENDMODULE.                 " TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_113 OUTPUT.

describe table g_TABLCTRL113_itab lines TABLCTRL113-lines.

if not g_field is initial.
     set cursor field g_field line g_i.
     clear g_field.
else.
     set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_113.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr113_col_attrib OUTPUT.
LOOP AT TABLCTRL113-cols INTO cols WHERE index GT 9.
      cols-invisible = '1'.
      MODIFY TABLCTRL113-cols FROM cols INDEX sy-tabix.
ENDLOOP.
ENDMODULE.                 " scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr113_attrib OUTPUT.

loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL113_DELETE' or
           screen-name = 'TABLCTRL113_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.

ENDMODULE.                 " scr113_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL114_init output.
  if g_TABLCTRL114_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL114_itab[].
    clear   g_TABLCTRL114_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL114_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL114_itab where moduleid = 'SD' and
       docno = zic_prep_rolereq-docno.
    g_TABLCTRL114_copied = 'X'.
    refresh control 'TABLCTRL114' from screen '0114'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL114_move output.
**13/04/07
  clear ZIC_PREP_ROLEREI-REJ_FL_SAVE.
  move-corresponding g_TABLCTRL114_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zsd_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zsd_prep_roledes-brief_desc to role_desc.
     endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL114_get_lines output.
  g_TABLCTRL114_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr114_col_attrib OUTPUT.

LOOP AT TABLCTRL114-cols INTO cols WHERE index GT 9.
      cols-invisible = '1'.
      MODIFY TABLCTRL114-cols FROM cols INDEX sy-tabix.
ENDLOOP.

ENDMODULE.                 " scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr114_attrib OUTPUT.

loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL114_DELETE' or
           screen-name = 'TABLCTRL114_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.

ENDMODULE.                 " scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL114_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zsd_prep_roledes where role_type =
                                              g_TABLCTRL114_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zsd_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SALE_ORG' .

            if zsd_prep_roledes-sale_org = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-DIV'.

             if zsd_prep_roledes-div = 'X'  and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SHIP_POINT' .

             if zsd_prep_roledes-ship_point = 'X'  and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

      endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

ENDMODULE.                 " TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_114  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_114 OUTPUT.

describe table g_TABLCTRL114_itab lines TABLCTRL114-lines.

if not g_field is initial.
     set cursor field g_field line g_i.
     clear g_field.
else.
     set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_114.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_114  OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL115_init output.
  if g_TABLCTRL115_copied is initial and old_ok_code <> 'CREATE'.
  refresh g_TABLCTRL115_itab[].
    clear   g_TABLCTRL115_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL115_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL115_itab where
       moduleid = 'QM' and
       docno = zic_prep_rolereq-docno.
    g_TABLCTRL115_copied = 'X'.
    refresh control 'TABLCTRL115' from screen '0115'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL115_move output.
  move-corresponding g_TABLCTRL115_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zqm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zqm_prep_roledes-brief_desc to role_desc.
     endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL115_get_lines output.
  g_TABLCTRL115_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr115_col_attrib OUTPUT.
LOOP AT TABLCTRL115-cols INTO cols WHERE index GT 7.
      cols-invisible = '1'.
      MODIFY TABLCTRL115-cols FROM cols INDEX sy-tabix.
ENDLOOP.
ENDMODULE.                 " scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr115_attrib OUTPUT.
loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL115_DELETE' or
           screen-name = 'TABLCTRL115_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.
ENDMODULE.                 " scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL115_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zqm_prep_roledes where role_type =
                                              g_TABLCTRL115_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if ZIC_PREP_ROLEREQ-CCODE = 'MUM' and
               ZIC_PREP_ROLEREI-ROLE_NAME = 'Q1' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-ASSET_QM' .

        select single * from zqm_prep_asset where ccode =
                                              ZIC_PREP_ROLEREQ-ccode.

            if sy-subrc = 0 and
               ZIC_PREP_ROLEREI-ROLE_NAME = 'Q2' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

       endloop.

    else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.
ENDMODULE.                 " TABLCTRL115_attrib  OUTPUT

*--- INCLUDE: MZMMPREPROLE1_PHASEII_ADMNTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 67.
************************************************************************

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZIC_PREP_ROLEREQ, ZIC_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
ZMM_PREP_REJ_LIS, ZMM_PREP_EX_APP, soodk, sood5, ZMM_PREP_ROLECRC,
zmm_prep_sl_excp, zpm_prep_roledes, v_t357, zice_prep_module,
ZMM_PREP_STATUS,zps_prep_roledes,zps_prep_service,zps_prep_project,
zps_prep_asst_ex,zps_prep_loc,t001,zpp_prep_roledes,ZPP_PREP_DROLEEX,
zsd_prep_roledes,zqm_prep_roledes, ZPP_PREP_GENERIC,zhelp_pproles1,
zqm_prep_loc, zqm_prep_asset, tvta, ZSD_PREP_LDGGRP,zmm_prep_crcdesg,
zps_prep_loca,usr21,ADRP.

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

DATA : ist_data TYPE STANDARD  TABLE OF ty_data with header line.
*Begin of <RD1K963151>.
DATA : ist_data1 TYPE STANDARD  TABLE OF ty_data with header line.
DATA : ist_data2 TYPE STANDARD  TABLE OF ty_data with header line.
*Begin of <RD1K963151>.
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
DATA : cpf_lfb1(08) type c.

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
DATA  g_ins_flag.
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
DATA : crc_pos(132).

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
types: begin of t_TABLCTRL110,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
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

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
controls: TABLCTRL110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
data:     moduleid(3).
data:     new_moduleid(3).
DATA      old_moduleid(3).

*&spwizard: type for the data of tablecontrol 'TABLCTRL111'
types: begin of t_TABLCTRL111,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         SHOP_NO like ZIC_PREP_ROLEREI-SHOP_NO,
         role_desc like zmm_prep_roledes-brief_desc,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         flag,       "flag for mark column
       end of t_TABLCTRL111.

*&spwizard: internal table for tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_itab   type t_TABLCTRL111 occurs 0,
          g_TABLCTRL111_wa     type t_TABLCTRL111. "work area
data:     g_TABLCTRL111_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL111' itself
controls: TABLCTRL111 type tableview using screen 0111.

*&spwizard: lines of tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_lines  like sy-loopc.
DATA      g_curr_line_111 like sy-stepl.
DATA  check_role_flag.
DATA   : ist_item like table of zic_prep_rolerei.
DATA   : wa_item like line of ist_item.
DATA  g_l4.
DATA  modulemm_fl.
DATA  moduleid_save like zic_prep_rolerei-moduleid.
DATA  g_mult_module_fl.
DATA : STATUS_DESC like ZMM_PREP_STATUS-STATUS_DESC.
data : it_module1 like table of zic_modules.
DATA : wa_module1 like line of it_module1.
DATA  mm_not_ok.
DATA  pm_not_ok.
DATA  ps_not_ok.
DATA  g_choice_app.

*&spwizard: type for the data of tablecontrol 'TABLCTRL112'
types: begin of t_TABLCTRL112,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         SERVICE like ZIC_PREP_ROLEREI-SERVICE,
         PROJECT like ZIC_PREP_ROLEREI-PROJECT,
         LOCATION like ZIC_PREP_ROLEREI-LOCATION,
*         REGION like ZIC_PREP_ROLEREI-REGION,
         ASSET like ZIC_PREP_ROLEREI-ASSET,
         BASIN like ZIC_PREP_ROLEREI-BASIN,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         role_desc like zmm_prep_roledes-brief_desc,
       end of t_TABLCTRL112.

*&spwizard: internal table for tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_itab   type t_TABLCTRL112 occurs 0,
          g_TABLCTRL112_wa     type t_TABLCTRL112. "work area
data:     g_TABLCTRL112_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL112' itself
controls: TABLCTRL112 type tableview using screen 0112.

*&spwizard: lines of tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_lines  like sy-loopc.
DATA  module_changed_flag.
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
  DATA : it_location type table of zps_prep_loc with header line.
  DATA : it_loca     type table of zps_prep_loc with header line.
  DATA : it_project type table of zps_prep_project with header line.
  DATA : it_service type table of zps_prep_service with header line.
  DATA : it_plant like table of zqm_prep_loc with header line.
DATA  g_curr_line_112 like sy-stepl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
types: begin of t_TABLCTRL113,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RES like ZIC_PREP_ROLEREI-RES,
         CTF_SLOC like ZIC_PREP_ROLEREI-CTF_SLOC,
         ROLE_DESC like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
       end of t_TABLCTRL113.

*&spwizard: internal table for tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_itab   type t_TABLCTRL113 occurs 0,
          g_TABLCTRL113_wa     type t_TABLCTRL113. "work area
data:     g_TABLCTRL113_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL113' itself
controls: TABLCTRL113 type tableview using screen 0113.

*&spwizard: lines of tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_lines  like sy-loopc.
DATA  g_curr_line_113 like sy-stepl.

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
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         SALE_ORG like ZIC_PREP_ROLEREI-SALE_ORG,
         DIV like ZIC_PREP_ROLEREI-DIV,
         SHIP_POINT like ZIC_PREP_ROLEREI-SHIP_POINT,
         ROLE_DESC like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
       end of t_TABLCTRL114.

*&spwizard: internal table for tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_itab   type t_TABLCTRL114 occurs 0,
          g_TABLCTRL114_wa     type t_TABLCTRL114. "work area
data:     g_TABLCTRL114_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL114' itself
controls: TABLCTRL114 type tableview using screen 0114.

DATA   : it_tvswz like table of tvswz with header line.
DATA   : it_tvko like table of tvko with header line.
DATA   : it_tvkos like table of tvkos with header line.
DATA   : it_tvstz like table of tvstz with header line.

*&spwizard: lines of tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_lines  like sy-loopc.
DATA  g_curr_line_114 like sy-stepl.
DATA  sd_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL115'
types: begin of t_TABLCTRL115,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         ASSET_QM like ZIC_PREP_ROLEREI-ASSET_QM,
         ROLE_DESC like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
       end of t_TABLCTRL115.

*&spwizard: internal table for tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_itab   type t_TABLCTRL115 occurs 0,
          g_TABLCTRL115_wa     type t_TABLCTRL115. "work area
data:     g_TABLCTRL115_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL115' itself
controls: TABLCTRL115 type tableview using screen 0115.

*&spwizard: lines of tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_lines  like sy-loopc.
DATA      g_curr_line_115 like sy-stepl.
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
**
DATA : ist_seltab1 like table of rsparams.
DATA : seltab1 like rsparams.
DATA  qm_not_ok.
DATA  g_error_fundc.
DATA  set_disc_fi_flag.
***********************************************************
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.
DATA  attach_fl.
DATA  g_choice_more.

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
