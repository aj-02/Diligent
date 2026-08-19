*--- MAIN PROGRAM: SAPMZMMCODUNBLOCK ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMCODUNBLOCK                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
*  Date            Transport      USERID        Description
* 29/09/2008      <RD1K960036>    SAB_SUMODH
*
*
*  1) Change in INCLUDE MZMMCODUNBLOCKF01.
*  2) Change in INCLUDE MZMMCODUNBLOCKI01
************************************************************************


INCLUDE MZMMCODUNBLOCKTOP .

* Includes inserted by Screen Painter Wizard. DO NOT CHANGE THIS LINE!
INCLUDE MZMMCODUNBLOCKO01 .
INCLUDE MZMMCODUNBLOCKI01 .
INCLUDE MZMMCODUNBLOCKF01 .

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

*--- INCLUDE: MZMMCODUNBLOCKF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete F.M POPUP_TO_CONFRIM_STEP replaced with POPUP_TO_CONFRIM.
*
************************************************************************

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

     WHEN 'DELE'.                      "delete row
       CASE zmm_matblockhd_st-mtart.
         WHEN 'ZSTO'.
           PERFORM add_delitem110.
         WHEN 'ZSPR'.
           PERFORM add_delitem120.
         WHEN 'ZCAP'.
           PERFORM add_delitem130.
       ENDCASE.
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

     WHEN 'SPELL'.
       CASE zmm_matblockhd_st-mtart.
         WHEN 'ZSTO' .
           PERFORM spell_check_110.
         WHEN 'ZSPR'.
           PERFORM spell_check_120.
         WHEN 'ZCAP'.
           PERFORM spell_check_130.
       ENDCASE.

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

     IF <mark_field> = 'X'.
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
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO    = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
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
*&      Form  fill_sttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM fill_sttab.
   REFRESH it_tab1.
   IF g_mode =  'CRE' OR
      g_mode =  'CHA' OR
      g_mode =  'REL'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'DEL' OR
          g_mode = 'DIS'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'BLK'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSE.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.

 ENDFORM.                    " fill_sttab
*&---------------------------------------------------------------------*
*&      Form  fill_mattyp_itemdt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM fill_mattyp_itemdt.
   DATA l_matblockhd LIKE zmm_matblock_hd.

   IF g_mode = 'CRE'.
     PERFORM set_dynnr USING zmm_matblockhd_st-mtart.
   ELSE.
     SELECT SINGLE * INTO l_matblockhd FROM zmm_matblock_hd
            WHERE reqno = zmm_matblockhd_st-reqno.
     IF sy-subrc = 0.
       PERFORM set_dynnr USING l_matblockhd-mtart.
     ELSE.
*       message e003(zmm_oth) with zmm_matblockhd_st-reqno.
     ENDIF.
**
*     IF l_cdhd-mtart = 'ZSTO'.
*       Select single * from zmm_cditem
*          where reqno = zmm_cdhd_st-reqno
*          and   oth1  = 'X'.
*       IF sy-subrc = 0.
*         g_techapr_visible = 'Y'.
*       ENDIF.
*     ENDIF.
   ENDIF.

 ENDFORM.                    " fill_mattyp_itemdt
*&---------------------------------------------------------------------*
*&      Form  set_dynnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MATBLOCKHD_ST_MTART  text
*----------------------------------------------------------------------*
 FORM set_dynnr USING  p_mtart.
   CASE p_mtart.
     WHEN 'ZSTO'.
       dynnr = '0110'.
     WHEN 'ZSPR'.
       dynnr = '0120'.
     WHEN 'ZCAP'.
       dynnr = '0130'.
     WHEN 'ZDIS'.
       dynnr = '0140'.
   ENDCASE.

 ENDFORM.                    " set_dynnr
*&---------------------------------------------------------------------*
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM save_request.
   IF g_mode = 'CRE' OR g_mode = 'CHA'.
     CASE zmm_matblockhd_st-mtart.
       WHEN 'ZSTO'.
         IF NOT g_tc110_itab[] IS INITIAL.
           READ TABLE g_tc110_itab WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
       WHEN 'ZSPR'.
         IF NOT g_tc120_itab[] IS INITIAL.
           READ TABLE g_tc120_itab WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
       WHEN 'ZCAP'.
         IF NOT g_tc130_itab[] IS INITIAL.
           READ TABLE g_tc130_itab WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
     ENDCASE.
   ENDIF.
   IF g_mode = 'CRE'.
     zmm_matblockhd_st-reqno = g_reqno.
     PERFORM insert_into_tab.
     MESSAGE i005(zmm_oth) WITH g_reqno.
     PERFORM clear_var.
     CLEAR okcode_100.
   ELSEIF g_mode = 'CHA'.
     g_request_no = zmm_matblockhd_st-reqno .
     PERFORM prepare_update.
     COMMIT WORK.
     MESSAGE i006(zmm_oth) WITH g_request_no.
     PERFORM clear_var.
     CLEAR okcode_100.
   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
     CLEAR okcode_100.
   ELSEIF g_mode = 'REL'.
     IF zmm_matblockhd_st-rel_flag = ''.
       CLEAR okcode_100.
       MESSAGE i024(zmm_oth) WITH 'Release'.
     ELSE.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
       IF g_rel = 'Y'.
         PERFORM update_rel.
         PERFORM send_mail_to_cdcell.
         PERFORM clear_var.
         CLEAR okcode_100.
       ELSE.
         CLEAR okcode_100.
         EXIT.
       ENDIF.
     ENDIF.
   ELSEIF g_mode = 'BLK'.
     PERFORM update_cdcell.
     IF zmm_matblockhd_st-reqcl = 'IR'.
       PERFORM send_mail_to_reqn.
     ENDIF.
     PERFORM clear_var.
     CLEAR okcode_100.
     LEAVE PROGRAM.
   ENDIF.

 ENDFORM.                    " Save_request
*&---------------------------------------------------------------------*
*&      Form  gen_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM gen_request.
   CALL FUNCTION 'NUMBER_GET_NEXT'
     EXPORTING
       nr_range_nr = '01'
       object      = 'ZMMCDUNBLK'
     IMPORTING
       number      = g_reqno.
   IF sy-subrc <> 0.
   ENDIF.

 ENDFORM.                    " gen_request
*&---------------------------------------------------------------------*
*&      Form  Insert_into_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM insert_into_tab.

   DATA: l_blkhd LIKE zmm_matblock_hd.
   CLEAR : l_blkhd.
****Header Part*********
   IF g_mode = 'CRE'.
     MOVE sy-datum TO zmm_matblockhd_st-reqdate.
     MOVE sy-uname TO zmm_matblockhd_st-reqcpf.
     MOVE 'N' TO zmm_matblockhd_st-reqcl.
     MOVE-CORRESPONDING zmm_matblockhd_st TO l_blkhd.
     INSERT INTO zmm_matblock_hd VALUES l_blkhd.
*     if sy-subrc = 0.
*       message i001(zmm_oth) with ZMM_MATBLOCKHD_ST-reqno.
*     endif.
   ELSEIF g_mode = 'CHA'.
     MOVE-CORRESPONDING zmm_matblockhd_st TO l_blkhd.
     MODIFY zmm_matblock_hd FROM l_blkhd.
   ENDIF.
****Detail Part************
*   Refresh ist_zmm_cditem.
   CASE zmm_matblockhd_st-mtart.
     WHEN 'ZSTO'.
       LOOP AT g_tc110_itab INTO g_tc110_wa.
         MOVE-CORRESPONDING g_tc110_wa TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
       ENDLOOP.
     WHEN 'ZSPR'.
       LOOP AT g_tc120_itab INTO g_tc120_wa.
         MOVE-CORRESPONDING g_tc120_wa TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
       ENDLOOP.
     WHEN 'ZCAP'.
       LOOP AT g_tc130_itab INTO g_tc130_wa.
         MOVE-CORRESPONDING g_tc130_wa TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
       ENDLOOP.
   ENDCASE.
   IF g_mode = 'CRE'.
     INSERT zmm_matblock_dt FROM TABLE itab_matblock_dt.
   ELSE.
     MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   ENDIF.
******Header(Correspondence)********************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) .
     PERFORM save_cors_text.
   ENDIF.

 ENDFORM.                    " Insert_into_tab
*&---------------------------------------------------------------------*
*&      Form  prepare_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM prepare_update.
   DATA : l_del110 TYPE ty_tc110,
          l_del120 TYPE ty_tc120,
          l_del130 TYPE ty_tc130.
   CLEAR g_item.
   SELECT SINGLE * INTO g_item FROM zmm_matblock_dt
          WHERE reqno = zmm_matblockhd_st-reqno.
**
   CASE zmm_matblockhd_st-mtart.
     WHEN 'ZSTO'.
       IF NOT g_itab_del110[] IS INITIAL.
         LOOP AT g_itab_del110 INTO l_del110.
           DELETE FROM zmm_matblock_dt
             WHERE reqno = zmm_matblockhd_st-reqno
             AND   srno  = l_del110-srno.
         ENDLOOP.
       ENDIF.
     WHEN 'ZSPR'.
       IF NOT g_itab_del120[] IS INITIAL.
         LOOP AT g_itab_del120 INTO l_del120.
           DELETE FROM zmm_matblock_dt
             WHERE reqno = zmm_matblockhd_st-reqno
             AND   srno  = l_del120-srno.
         ENDLOOP.
       ENDIF.
     WHEN 'ZCAP'.
       IF NOT g_itab_del130[] IS INITIAL.
         LOOP AT g_itab_del130 INTO l_del130.
           DELETE FROM zmm_matblock_dt
             WHERE reqno = zmm_matblockhd_st-reqno
             AND   srno  = l_del130-srno.
         ENDLOOP.
       ENDIF.
   ENDCASE.
**
   PERFORM insert_into_tab.

 ENDFORM.                    " prepare_update
*&---------------------------------------------------------------------*
*&      Form  get_correspondense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_correspondense.
   DATA : l_cors LIKE thead-tdname.

   IF g_mode <> 'CRE'.
     CONCATENATE 'CORS' zmm_matblockhd_st-reqno INTO l_cors.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         client                  = sy-mandt
         id                      = 'BLCK'
         language                = sy-langu
         name                    = l_cors
         object                  = 'ZMMCD'
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
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       g_cors = ''.
     ELSE.
       g_cors = 'X'.
     ENDIF.
   ENDIF.

 ENDFORM.                    " get_correspondense
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
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

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
   REFRESH: tlinetab1,g_linefrto_itab.
*
   IF g_mode <> 'CRE'.
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
**Setting of first line..
   CALL METHOD gv_text_editor1->set_first_visible_line
     EXPORTING
       line = '1'.
********************************************************************


   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

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
   l_theader-tdobject   = 'ZMMCD'.
   l_theader-tdid       = 'BLCK'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_matblockhd_st-reqno INTO l_theader-tdname.
   APPEND LINES OF tlinetab2 TO tlinetab1.
*********************************************
   IF NOT tlinetab1[] IS INITIAL.
     CLEAR g_cores_sender.
     CONCATENATE sy-datum+6(2) '/'
                 sy-datum+4(2) '/'
                 sy-datum+0(4) INTO l_datech.
     CONCATENATE '**Reply' l_datech sy-uname INTO g_cores_sender
      SEPARATED BY '          '.
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
*&      Form  update_rel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_rel.
   UPDATE zmm_matblock_hd
   SET   rel_flag = 'X'
   WHERE reqno    = zmm_matblockhd_st-reqno.
***If the req status id is 'IR', should be updated to 'IC'
***At the time of releasing the request.
   IF zmm_matblockhd_st-reqcl = 'IR'.
     UPDATE zmm_matblock_hd
     SET   reqcl    = 'IC'
     WHERE reqno    = zmm_matblockhd_st-reqno.
   ENDIF.
***
   PERFORM save_cors_text.
   MESSAGE i019(zmm_oth) WITH zmm_matblockhd_st-reqno.
 ENDFORM.                    " update_rel
*&---------------------------------------------------------------------*
*&      Form  update_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_approval.
   UPDATE zmm_matblock_hd
    SET   apr_flag = 'X'
    WHERE reqno    = zmm_matblockhd_st-reqno.
   PERFORM save_cors_text.
   MESSAGE i019(zmm_oth) WITH zmm_matblockhd_st-reqno.
 ENDFORM.                    " update_approval
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM clear_var.
   IF NOT gv_text_editor1 IS INITIAL.
     PERFORM destroy_ctrl.
   ENDIF.
   CLEAR zmm_matblockhd_st.
   CLEAR g_mode.
   REFRESH g_tc110_itab[].
   REFRESH CONTROL 'TCT110' FROM SCREEN '0110'.

   REFRESH g_tc120_itab[].
   REFRESH CONTROL 'TCT120' FROM SCREEN '0120'.

   REFRESH g_tc130_itab[].
   REFRESH CONTROL 'TCT130' FROM SCREEN '0130'.

   IF g_lock = 'Y'.
     PERFORM unlock_req.
     CLEAR g_lock.
   ENDIF.
   CLEAR: g_tc110_wa,g_tc120_wa,g_tc130_wa.
   CLEAR: g_hd_copied,g_tct130_copied,g_tct110_copied,g_tct120_copied.
   CLEAR  g_cors.
   REFRESH: tlinetab1,tlinetab2,lines_cors.
   REFRESH: lt_text_table1,lt_text_table2.
   REFRESH : itab_matblock_dt.

*****
*   dynnr = '0110'.

 ENDFORM.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_sto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_nextsrno_sto.
   DATA : g_110itab TYPE TABLE OF ty_tc110.
   DATA : l_110itab TYPE ty_tc110.
   CLEAR  l_110itab.
   REFRESH g_110itab.

   APPEND LINES OF g_tc110_itab TO g_110itab.
   SORT g_110itab BY srno DESCENDING.
   READ TABLE g_110itab INTO l_110itab INDEX 1.
   l_srno = l_110itab-srno + 1.
 ENDFORM.                    " get_nextsrno_sto
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_spr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_nextsrno_spr.
   DATA : g_120itab TYPE TABLE OF ty_tc120.
   DATA : l_120itab TYPE ty_tc120.
   CLEAR  l_120itab.
   REFRESH g_120itab.

   APPEND LINES OF g_tc120_itab TO g_120itab.
   SORT g_120itab BY srno DESCENDING.
   READ TABLE g_120itab INTO l_120itab INDEX 1.
   l_srno = l_120itab-srno + 1.

 ENDFORM.                    " get_nextsrno_spr
*&---------------------------------------------------------------------*
*&      Form  check_splchar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC120_WA_splchar  text
*----------------------------------------------------------------------*
 FORM check_splchar USING p_splchar.

   g_iputdata   = p_splchar.
   g_iputstring = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.

   CALL FUNCTION 'ZREM_SPLCHAR'
     EXPORTING
       iput    = g_iputdata
       istring = g_iputstring
     IMPORTING
       oput    = g_oputdata.

 ENDFORM.                    " check_splchar
*&---------------------------------------------------------------------*
*&      Form  prepare_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM prepare_delete.

   PERFORM confirm_del.

   IF g_choice = 'J'.

     DELETE FROM zmm_matblock_hd
     WHERE reqno = zmm_matblockhd_st-reqno.
     IF sy-subrc <> 0.
       MESSAGE e007(zmm_oth) WITH zmm_matblockhd_st-reqno.
     ENDIF.
*
     SELECT tdobject tdname tdid FROM stxl
      INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
      WHERE tdid = 'BLCK'.
     IF sy-subrc = 0.
       DELETE ist_textid_items
          WHERE tdname+4(10) <> zmm_matblockhd_st-reqno.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ENDIF.

     DELETE FROM zmm_matblock_dt
     WHERE reqno = zmm_matblockhd_st-reqno.
     IF sy-subrc = 0.
       MESSAGE i004(zmm_oth) WITH zmm_matblockhd_st-reqno.
     ENDIF.
     CLEAR g_choice.
   ENDIF.

 ENDFORM.                    " prepare_delete
*&---------------------------------------------------------------------*
*&      Form  confirm_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_del.
   CLEAR g_choice.
   " Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*     EXPORTING
*    textline1 = 'Data will be lost,No recovery possible,Are you sure ?'
*      titel       = 'BACK'
*      start_column     = 25
*      start_row        = 6
*      cancel_display   = ''
*     IMPORTING
*       answer          = g_choice.

   DATA : l_var(1) TYPE c.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar              = 'BACK'
       text_question         = 'Data will be lost,No recovery possible,Are you sure ?'
       display_cancel_button = ' '
       start_column          = 25
       start_row             = 6
     IMPORTING
       answer                = l_var
     EXCEPTIONS
       text_not_found        = 1
       OTHERS                = 2.

   IF sy-subrc = 0.
     CASE l_answer.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.

   " End of <RD1K960036>.
 ENDFORM.                    " confirm_del
*&---------------------------------------------------------------------*
*&      Form  delete_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delete_text.
   CALL FUNCTION 'DELETE_TEXT'
     EXPORTING
       client          = sy-mandt
       id              = wa_textid-tdid
       language        = sy-langu
       name            = wa_textid-tdname
       object          = wa_textid-tdobject
       savemode_direct = 'X'
     EXCEPTIONS
       not_found       = 1
       OTHERS          = 2.

   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " delete_text
*&---------------------------------------------------------------------*
*&      Form  spell_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC110_WA_MATDESC  text
*----------------------------------------------------------------------*
 FORM spell_check USING p_matdesc.
   DATA : ist_descline LIKE tline OCCURS 0 WITH HEADER LINE.
   REFRESH : ist_descline[].
   CLEAR g_errflag.

**
   ist_descline-tdformat = '**'.
   ist_descline-tdline   = p_matdesc.
   APPEND ist_descline.
**
   CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
     EXPORTING
       sprache = 'EN'
     IMPORTING
       errflag = g_errflag
     TABLES
       iline   = ist_descline.

 ENDFORM.                    " spell_check
*&---------------------------------------------------------------------*
*&      Form  add_delitem110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem110.
   DATA : l_tc110_wa TYPE ty_tc110.
   LOOP AT g_tc110_itab INTO l_tc110_wa.
     IF l_tc110_wa-mark = 'X'.
       APPEND l_tc110_wa TO g_itab_del110.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc110_wa.

 ENDFORM.                    " add_delitem110
*&---------------------------------------------------------------------*
*&      Form  add_delitem120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem120.
   DATA : l_tc120_wa TYPE ty_tc120.
   LOOP AT g_tc120_itab INTO l_tc120_wa.
     IF l_tc120_wa-mark = 'X'.
       APPEND l_tc120_wa TO g_itab_del120.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc120_wa.

 ENDFORM.                    " add_delitem120
*&---------------------------------------------------------------------*
*&      Form  back_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM back_confirm.
   DATA  l_choice.
   CLEAR l_choice.
   IF g_mode = 'BLK'.
     PERFORM clear_var.
     LEAVE PROGRAM.
   ENDIF.
   IF g_mode <> 'DIS'.
     " Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               textline1      = 'Data will be lost, Want to quit? '
*               titel          = 'BACK'
*               start_column   = 25
*               start_row      = 6
*               cancel_display = ''
*          IMPORTING
*               answer         = l_choice.

     DATA : l_var1(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'BACK '
         text_question         = 'Data will be lost, Want to quit?'
         display_cancel_button = ' '
       IMPORTING
         answer                = l_var1.
     IF sy-subrc = 0.
       CASE l_var1.
         WHEN '1'.
           MOVE 'J' TO l_choice.
         WHEN '2'.
           MOVE 'N' TO l_choice.
       ENDCASE.
     ENDIF.

     " End of <RD1K960036>.

     IF l_choice = 'J'.
       IF NOT g_mode IS INITIAL.
         PERFORM clear_var.
         dynnr = '0110'.
         CLEAR l_choice.
       ELSE.
         CLEAR l_choice.
         LEAVE PROGRAM.
       ENDIF.
     ENDIF.
   ELSE.
     IF NOT g_mode IS INITIAL.
       PERFORM clear_var.
       dynnr = '0110'.
     ELSE.
       LEAVE PROGRAM.
     ENDIF.
*     leave program.
   ENDIF.

 ENDFORM.                    " back_confirm
*&---------------------------------------------------------------------*
*&      Form  destroy_ctrl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM destroy_ctrl.
   CASE g_mode.
     WHEN 'CRE' OR 'CHA' OR 'REL' OR 'BLK'.
       CALL METHOD gv_text_editor1->free.
       CALL METHOD gv_text_editor2->free.
     WHEN 'DIS' OR 'DEL'.
       CALL METHOD gv_text_editor1->free.
   ENDCASE.
   CLEAR:gv_text_editor1,gv_text_editor2.

 ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  confirm_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_exit.
   DATA  l_choice1.
   CLEAR l_choice1.
   IF g_mode <> 'DIS'.

     " Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               textline1      = 'Data will be lost, Want to quit? '
*               titel          = 'EXIT'
*               start_column   = 25
*               start_row      = 6
*               cancel_display = ''
*          IMPORTING
*               answer         = l_choice1.
     DATA : l_get(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'EXIT '
         text_question         = 'Data will be lost, Want to quit?'
         display_cancel_button = ' '
         start_column          = 25
         start_row             = 6
       IMPORTING
         answer                = l_get
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.
     IF sy-subrc = 0.
       CASE l_get.
         WHEN '1'.
           MOVE 'J' TO l_choice1 .
         WHEN '2'.
           MOVE 'N' TO l_choice1 .
       ENDCASE.
     ENDIF.

     " End of <RD1K960036>.

     IF l_choice1 = 'J'.
       CLEAR l_choice1.
       PERFORM clear_var.
       LEAVE PROGRAM.
     ENDIF.
   ELSE.
     PERFORM clear_var.
     LEAVE PROGRAM.
   ENDIF.
 ENDFORM.                    " confirm_exit
*&---------------------------------------------------------------------*
*&      Form  spell_check_110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check_110.
   DATA:ist_line LIKE tline OCCURS 0 WITH HEADER LINE.
   DATA: l_tc110 TYPE ty_tc110.
**
   REFRESH ist_line.
**
   LOOP AT g_tc110_itab INTO l_tc110 WHERE errcd = 'S'.
     ist_line-tdline = l_tc110-matdesc.
     APPEND ist_line.
   ENDLOOP.

   IF g_mode = 'BLK'.
     CALL FUNCTION 'ZSPELL_CHECK_BLK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line.
   ELSE.
     CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line.
   ENDIF.
***To update the internal table, if new word inserted..

   LOOP AT g_tc110_itab INTO l_tc110.
     PERFORM spell_check USING l_tc110-matdesc.
     IF g_errflag = ''.
       l_tc110-errcd = ''.
       MODIFY g_tc110_itab FROM l_tc110.
     ENDIF.
     CLEAR g_errflag.
   ENDLOOP.
 ENDFORM.                    " spell_check_110
*&---------------------------------------------------------------------*
*&      Form  spell_check_120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check_120.
   DATA:ist_line120 LIKE tline OCCURS 0 WITH HEADER LINE.
   DATA: l_tc120 TYPE ty_tc120.
**
   REFRESH ist_line120.
**
   LOOP AT g_tc120_itab INTO l_tc120 WHERE errcd = 'S'.
     ist_line120-tdline = l_tc120-matdesc.
     APPEND ist_line120.
   ENDLOOP.

   IF g_mode = 'BLK'.
     CALL FUNCTION 'ZSPELL_CHECK_BLK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line120.
   ELSE.
     CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line120.
   ENDIF.

***To update the internal table, if new word inserted..
   LOOP AT g_tc120_itab INTO l_tc120.
     PERFORM spell_check USING l_tc120-matdesc.
     IF g_errflag = ''.
       l_tc120-errcd = ''.
       MODIFY g_tc120_itab FROM l_tc120.
     ENDIF.
     CLEAR g_errflag.
   ENDLOOP.


 ENDFORM.                    " spell_check_120
*&---------------------------------------------------------------------*
*&      Form  unblock_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_matcode.
   DATA : l_totlines   TYPE i,
          l_unblklines TYPE i.
****
   CASE zmm_matblockhd_st-mtart.

     WHEN 'ZSTO'.
       READ TABLE  g_tc110_itab WITH KEY mark  = 'X'.
       IF sy-subrc <> 0.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.

       READ TABLE  g_tc110_itab WITH KEY mark  = 'X'
                                         errcd = 'S'.
       IF sy-subrc = 0.
         MESSAGE e100(zmm_oth).
       ENDIF.

       PERFORM confirm_unblock.
       IF g_choice = 'J'.
         PERFORM unblock_110.
***Setting the request status.
         IF zmm_matblockhd_st-reqcl = 'IR'.
           PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
         ELSE.
*           DESCRIBE TABLE g_tc110_itab LINES l_totlines.
           SELECT COUNT(*) INTO l_totlines
                           FROM zmm_matblock_dt
                           WHERE reqno = zmm_matblockhd_st-reqno.

           SELECT COUNT(*) INTO l_unblklines
                         FROM zmm_matblock_dt
           WHERE reqno = zmm_matblockhd_st-reqno
           AND   mstae = ''.
           IF l_unblklines < l_totlines.
             zmm_matblockhd_st-reqcl = 'IC'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ELSE.
             zmm_matblockhd_st-reqcl = 'C'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ENDIF.
         ENDIF.
         PERFORM save_cors_text.
       ENDIF.
*       CLEAR g_choice.

     WHEN 'ZSPR'.
       READ TABLE  g_tc120_itab WITH KEY mark  = 'X'.
       IF sy-subrc <> 0.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.

       READ TABLE  g_tc120_itab WITH KEY mark  = 'X'
                                         errcd = 'S'.
       IF sy-subrc = 0.
         MESSAGE e100(zmm_oth).
       ENDIF.

       PERFORM confirm_unblock.
       IF g_choice = 'J'.
         PERFORM unblock_120.
*** Setting the request status.
         IF zmm_matblockhd_st-reqcl = 'IR'.
           PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
         ELSE.
*            DESCRIBE TABLE g_tc120_itab LINES l_totlines.
           SELECT COUNT(*) INTO l_totlines
                          FROM zmm_matblock_dt
                          WHERE reqno = zmm_matblockhd_st-reqno.
           SELECT COUNT(*) INTO l_unblklines
                           FROM zmm_matblock_dt
          WHERE reqno = zmm_matblockhd_st-reqno
          AND   mstae = ''.
           IF l_unblklines < l_totlines.
             zmm_matblockhd_st-reqcl = 'IC'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ELSE.
             zmm_matblockhd_st-reqcl = 'C'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ENDIF.
         ENDIF.
         PERFORM save_cors_text.
       ENDIF.
*       CLEAR g_choice.
     WHEN 'ZCAP'.
       READ TABLE  g_tc130_itab WITH KEY mark  = 'X'.
       IF sy-subrc <> 0.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.

       READ TABLE g_tc130_itab WITH KEY mark  = 'X'
                                        errcd = 'S'.
       IF sy-subrc = 0.
         MESSAGE e100(zmm_oth).
       ENDIF.

       PERFORM confirm_unblock.
       IF g_choice = 'J'.
         PERFORM unblock_130.
         IF zmm_matblockhd_st-reqcl = 'IR'.
           PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
         ELSE.
*** Setting the request status.
*           DESCRIBE TABLE g_tc130_itab LINES l_totlines.
           SELECT COUNT(*) INTO l_totlines
                           FROM zmm_matblock_dt
                           WHERE reqno = zmm_matblockhd_st-reqno.
           SELECT COUNT(*) INTO l_unblklines
                         FROM zmm_matblock_dt
           WHERE reqno = zmm_matblockhd_st-reqno
           AND   mstae = ''.
           IF l_unblklines < l_totlines.
             zmm_matblockhd_st-reqcl = 'IC'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ELSE.
             zmm_matblockhd_st-reqcl = 'C'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ENDIF.
         ENDIF.
         PERFORM save_cors_text.
       ENDIF.
*       CLEAR g_choice.
   ENDCASE.

 ENDFORM.                    " unblock_matcode
*&---------------------------------------------------------------------*
*&      Form  confirm_unblock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_unblock.

   CLEAR g_choice.
   " BEGIN OF <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*             textline1      = 'Want to unblock selected Codes ?'
*             titel          = 'Unblock'
*             start_column   = 25
*             start_row      = 6
*             cancel_display = ''
*        IMPORTING
*             answer         = g_choice.

   DATA : l_get1(1) TYPE c.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar              = 'Unblock '
       text_question         = 'Want to unblock selected Codes ?'
       display_cancel_button = ' '
     IMPORTING
       answer                = l_get1
     EXCEPTIONS
       text_not_found        = 1
       OTHERS                = 2.
   IF sy-subrc = 0.
     CASE l_get1.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.
   " End of <RD1K960036>.
 ENDFORM.                    " confirm_unblock
*&---------------------------------------------------------------------*
*&      Form  unblock_110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_110.
   DATA: l_tc110wa TYPE ty_tc110.
   CLEAR: l_tc110wa,wa_matblock_dt.
   REFRESH : itab_matblock_dt.

   LOOP AT g_tc110_itab INTO l_tc110wa WHERE mark = 'X'.
     IF l_tc110wa-errcd IS INITIAL.
***Updating MARA table.**********************
***flag
       UPDATE mara
       SET    mstae = ''
       WHERE  matnr = l_tc110wa-matcode.
***NORMT
       SELECT SINGLE * FROM mara WHERE
              matnr = l_tc110wa-matcode.
       IF NOT mara-normt IS INITIAL.
         g_normt = mara-normt+0(5).
         UPDATE mara
         SET    normt = g_normt
         WHERE  matnr = l_tc110wa-matcode.
       ENDIF.
***Updating MAKT table.*************************
       IF NOT l_tc110wa-matdesc IS INITIAL.
         g_desclen = strlen( l_tc110wa-matdesc ).
         IF g_desclen > 40.
           g_wrkst39 = l_tc110wa-matdesc+0(39).
           CONCATENATE g_wrkst39 '*' INTO g_wrkst39.
           g_wrkst = l_tc110wa-matdesc+39.
           UPDATE mara
            SET wrkst   = g_wrkst
            WHERE matnr = l_tc110wa-matcode.
           UPDATE makt
            SET    maktx = g_wrkst39
            WHERE  matnr = l_tc110wa-matcode.
         ELSE.
           UPDATE makt
           SET    maktx = l_tc110wa-matdesc
           WHERE  matnr = l_tc110wa-matcode.
         ENDIF.
         CLEAR: g_wrkst,g_wrkst39,g_desclen.
       ENDIF.
***Updating long text for Non Moving items.
*       IF l_tc110wa-mstae = 'NM'.
       PERFORM upd_lt_for_nm USING l_tc110wa-matcode
                                   l_tc110wa-res_nm.
*       ENDIF.
***Mofifying internal table.
       l_tc110wa-mstae = ''.
       l_tc110wa-unblkby = sy-uname.
       l_tc110wa-unblkdt = sy-datum.
       MODIFY TABLE g_tc110_itab FROM l_tc110wa.
***Modifying database table
       MOVE-CORRESPONDING l_tc110wa TO wa_matblock_dt.
       MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
       APPEND wa_matblock_dt TO itab_matblock_dt.
       CLEAR:wa_matblock_dt,l_tc110wa.
       MESSAGE i102(zmm_oth).
     ELSE.
       MESSAGE i110(zmm_oth) WITH l_tc110wa-errcd.
     ENDIF.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.
***Modifying those items which have been changed
***but not selected for unblocking.
   LOOP AT g_tc110_itab INTO l_tc110wa WHERE mark <> 'X'.
     l_tc110wa-unblkby = sy-uname.
     l_tc110wa-unblkdt = sy-datum.
*      MODIFY TABLE g_tc110_itab FROM l_tc110wa.
     MOVE-CORRESPONDING l_tc110wa TO wa_matblock_dt.
     MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
     APPEND wa_matblock_dt TO itab_matblock_dt.
     CLEAR:wa_matblock_dt,l_tc110wa.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.

 ENDFORM.                    " unblock_110
*&---------------------------------------------------------------------*
*&      Form  unblock_120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_120.
   DATA : l_tc120wa TYPE ty_tc120.
   DATA : l_atinn        LIKE cabn-atinn,
          l_name1        LIKE  lfa1-name1,
          l_maktx        LIKE makt-maktx,
          "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026


*          l_partno30(30) TYPE c,
          l_partno30(70) TYPE c,
*          l_partno(30)   TYPE c.
          l_partno(70)   TYPE c.
   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026

   DATA : l_ausp  LIKE ausp.
   CLEAR :l_tc120wa,wa_matblock_dt.
   REFRESH : itab_matblock_dt.
   LOOP AT g_tc120_itab INTO l_tc120wa WHERE mark = 'X'.
     IF l_tc120wa-errcd IS INITIAL.
***Updating MARA table.*************************
***flag
       UPDATE mara
       SET    mstae = ''
       WHERE  matnr = l_tc120wa-matcode.
***Part Number
       IF NOT l_tc120wa-npartno IS INITIAL.
         UPDATE mara
         SET    mfrpn = l_tc120wa-npartno
         WHERE  matnr = l_tc120wa-matcode.
       ENDIF.
***OEM ( Manufacturer)
       IF NOT l_tc120wa-noem IS INITIAL.
         UPDATE mara
         SET    mfrnr = l_tc120wa-noem
         WHERE  matnr = l_tc120wa-matcode.
       ENDIF.
***NORMT
       SELECT SINGLE * FROM mara WHERE
              matnr = l_tc120wa-matcode.
       IF NOT mara-normt IS INITIAL.
         g_normt = mara-normt+0(5).
         UPDATE mara
         SET    normt = g_normt
         WHERE  matnr = l_tc120wa-matcode.
       ENDIF.
***Updating MAKT table.*************************
       IF NOT l_tc120wa-matdesc IS INITIAL.
         g_desclen = strlen( l_tc120wa-matdesc ).
         IF g_desclen > 40.
           g_wrkst39 = l_tc120wa-matdesc+0(39).
           CONCATENATE g_wrkst39 '*' INTO g_wrkst39.
           g_wrkst = l_tc120wa-matdesc+39.
           UPDATE mara
            SET wrkst   = g_wrkst
            WHERE matnr = l_tc120wa-matcode.
           UPDATE makt
            SET    maktx = g_wrkst39
            WHERE  matnr = l_tc120wa-matcode.
         ELSE.
           UPDATE makt
           SET    maktx = l_tc120wa-matdesc
           WHERE  matnr = l_tc120wa-matcode.
         ENDIF.
         CLEAR: g_wrkst,g_wrkst39,g_desclen.
       ENDIF.
***Updating AUSP table.*************************
***Part Number
       CLEAR l_atinn.
       IF NOT l_tc120wa-npartno IS INITIAL.
         g_desclen = strlen( l_tc120wa-npartno ).
         IF g_desclen > 30.
           l_partno30 = l_tc120wa-npartno+0(30).
           l_partno   = l_tc120wa-npartno+30(10).
***Updating classification view with 30 char.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           UPDATE ausp
           SET    atwrt = l_partno30
           WHERE  objek = l_tc120wa-matcode  "#EC CI_FLDEXT_OK[2215424]
           AND    atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_partno30.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR: l_ausp,l_partno30.
           ENDIF.
***Updating classification view with remaining char.
           CLEAR l_atinn.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO_CONTINUED'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           UPDATE ausp
           SET    atwrt = l_partno
           WHERE  objek = l_tc120wa-matcode  "#EC CI_FLDEXT_OK[2215424]
           AND    atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_partno.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR: l_ausp,l_partno.
           ENDIF.
****
         ELSE.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           UPDATE ausp
           SET    atwrt = l_tc120wa-npartno
           WHERE  objek = l_tc120wa-matcode  "#EC CI_FLDEXT_OK[2215424]
           AND    atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_tc120wa-npartno.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR l_ausp.
           ENDIF.
         ENDIF.
       ELSE.      "oldpartno exist, but not in cls view
         CLEAR: l_atinn,l_ausp.
         IF NOT l_tc120wa-opartno IS INITIAL.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           SELECT SINGLE * FROM ausp
                 WHERE objek = l_tc120wa-matcode "#EC CI_FLDEXT_OK[2215424]
                 AND   atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_tc120wa-opartno.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR l_ausp.
           ENDIF.

         ENDIF.
       ENDIF.
***Manufacturer (OEM)
       CLEAR: l_atinn, l_name1.
       SELECT SINGLE name1 INTO l_name1 FROM lfa1
              WHERE lifnr = l_tc120wa-noem.
       IF sy-subrc <> 0.
         l_name1 = ''.
       ENDIF.
       IF NOT l_tc120wa-noem IS INITIAL.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_name1
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_name1.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
       ENDIF.
***Model Number
       CLEAR l_atinn.
       IF NOT l_tc120wa-nmdlno IS INITIAL.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MODELCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         lv_atwrt = l_tc120wa-nmdlno.
         UPDATE ausp
*         SET    atwrt = l_tc120wa-nmdlno
         SET    atwrt = lv_atwrt
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_tc120wa-nmdlno.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
       ENDIF.
***Capital Code
       CLEAR l_atinn.
       IF NOT l_tc120wa-ncapno IS INITIAL.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CAPCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_tc120wa-ncapno
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_tc120wa-ncapno.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
***Capital Description ( If new Capital Code is entered )
         CLEAR l_atinn.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CPCODE_DESC'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         SELECT maktx INTO l_maktx FROM makt UP TO 1 ROWS
 WHERE matnr = l_tc120wa-ncapno
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_maktx
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_maktx.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
       ENDIF.
***Updating long text for Non Moving items.
*       IF l_tc120wa-mstae = 'NM'.
       PERFORM upd_lt_for_nm USING l_tc120wa-matcode
                                   l_tc120wa-res_nm.
*       ENDIF.
***Mofifying internal table.
       l_tc120wa-mstae = ''.
       l_tc120wa-unblkby = sy-uname.
       l_tc120wa-unblkdt = sy-datum.
       MODIFY TABLE g_tc120_itab FROM l_tc120wa.
***Modifying database table..
       MOVE-CORRESPONDING l_tc120wa TO wa_matblock_dt.
       MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
       APPEND wa_matblock_dt TO itab_matblock_dt.
       CLEAR:wa_matblock_dt,l_tc120wa.
       MESSAGE i102(zmm_oth).
     ELSE.
       MESSAGE i110(zmm_oth) WITH l_tc120wa-errcd.
     ENDIF.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.
****Modifying those items which have been changed
****but not selected for unblocking.
   LOOP AT g_tc120_itab INTO l_tc120wa WHERE mark <> 'X'.
     l_tc120wa-unblkby = sy-uname.
     l_tc120wa-unblkdt = sy-datum.
*      MODIFY TABLE g_tc120_itab FROM l_tc120wa.
     MOVE-CORRESPONDING l_tc120wa TO wa_matblock_dt.
     MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
     APPEND wa_matblock_dt TO itab_matblock_dt.
     CLEAR:wa_matblock_dt,l_tc120wa.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.


 ENDFORM.                    " unblock_120
*&---------------------------------------------------------------------*
*&      Form  set_reqcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MATBLOCKHD_ST_REQCL  text
*----------------------------------------------------------------------*
 FORM set_reqcl USING p_reqcl.
   UPDATE zmm_matblock_hd
     SET reqcl = p_reqcl
     WHERE reqno = zmm_matblockhd_st-reqno.

**
   IF zmm_matblockhd_st-reqcl = 'IR'.
     UPDATE zmm_matblock_hd
      SET ir_date = sy-datum
      WHERE reqno = zmm_matblockhd_st-reqno.
   ENDIF.
 ENDFORM.                    " set_reqcl
*&---------------------------------------------------------------------*
*&      Form  update_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_cdcell.
   DATA   : l_tc110 TYPE ty_tc110,
            l_tc120 TYPE ty_tc120,
            l_tc130 TYPE ty_tc130.
   CLEAR  : l_tc110,l_tc120,l_tc130,wa_matblock_dt.
   REFRESH: itab_matblock_dt.

***Header
   IF zmm_matblockhd_st-reqcl = 'IR'.
     SELECT SINGLE * FROM zmm_matblock_hd
            WHERE reqno = zmm_MATBLOCKhd_st-reqno.
     IF zmm_MATBLOCK_hd-ir_date IS INITIAL.
       zmm_matblockhd_st-ir_date = sy-datum.
     ENDIF.
   ELSE.
     CLEAR zmm_matblockhd_st-ir_date.
   ENDIF.

   MOVE-CORRESPONDING zmm_matblockhd_st TO Zmm_MATBLOCK_hd.
   MODIFY zmm_matblock_hd FROM zmm_MATBLOCK_hd.
*   UPDATE zmm_matblock_hd
*   SET reqcl   = zmm_matblockhd_st-reqcl
*   WHERE reqno = zmm_matblockhd_st-reqno.
***details
   CASE zmm_matblockhd_st-mtart.
     WHEN 'ZSTO'.
       LOOP AT g_tc110_itab INTO l_tc110.
         MOVE-CORRESPONDING l_tc110 TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
         CLEAR:wa_matblock_dt,l_tc110.
       ENDLOOP.
       MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
       REFRESH itab_matblock_dt.
*
     WHEN 'ZSPR'.
       LOOP AT g_tc120_itab INTO l_tc120.
         MOVE-CORRESPONDING l_tc120 TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
         CLEAR:wa_matblock_dt,l_tc120.
       ENDLOOP.
       MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
       REFRESH itab_matblock_dt.
     WHEN 'ZCAP'.
       LOOP AT g_tc130_itab INTO l_tc130.
         MOVE-CORRESPONDING l_tc130 TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
         CLEAR:wa_matblock_dt,l_tc130.
       ENDLOOP.
       MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
       REFRESH itab_matblock_dt.
   ENDCASE.
***Correspondense.
   PERFORM save_cors_text.
 ENDFORM.                    " update_cdcell
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_cap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_nextsrno_cap.
   DATA : g_130itab TYPE TABLE OF ty_tc130.
   DATA : l_130itab TYPE ty_tc130.
   CLEAR  l_130itab.
   REFRESH g_130itab.

   APPEND LINES OF g_tc130_itab TO g_130itab.
   SORT g_130itab BY srno DESCENDING.
   READ TABLE g_130itab INTO l_130itab INDEX 1.
   l_srno = l_130itab-srno + 1.
 ENDFORM.                    " get_nextsrno_cap
*&---------------------------------------------------------------------*
*&      Form  add_delitem130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem130.
   DATA : l_tc130_wa TYPE ty_tc130.
   LOOP AT g_tc130_itab INTO l_tc130_wa.
     IF l_tc130_wa-mark = 'X'.
       APPEND l_tc130_wa TO g_itab_del130.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc130_wa.

 ENDFORM.                    " add_delitem130
*&---------------------------------------------------------------------*
*&      Form  spell_check_130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check_130.
   DATA: ist_line130 LIKE tline OCCURS 0 WITH HEADER LINE.
   DATA: l_tc130 TYPE ty_tc130.
**
   REFRESH ist_line130.
**
   LOOP AT g_tc130_itab INTO l_tc130 WHERE errcd = 'S'.
     ist_line130-tdline = l_tc130-matdesc.
     APPEND ist_line130.
   ENDLOOP.

   IF g_mode = 'BLK'.
     CALL FUNCTION 'ZSPELL_CHECK_BLK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line130.
   ELSE.
     CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line130.
   ENDIF.
***To update the internal table, if new word inserted..

   LOOP AT g_tc130_itab INTO l_tc130.
     PERFORM spell_check USING l_tc130-matdesc.
     IF g_errflag = ''.
       l_tc130-errcd = ''.
       MODIFY g_tc130_itab FROM l_tc130.
     ENDIF.
     CLEAR g_errflag.
   ENDLOOP.

 ENDFORM.                    " spell_check_130
*&---------------------------------------------------------------------*
*&      Form  unblock_130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_130.
   DATA: l_tc130wa  TYPE ty_tc130,
         l_atinn130 LIKE ausp-atinn,
         l_ausp130  LIKE ausp.
   DATA: l_matcost LIKE ausp-atflv,
         l_matlife LIKE ausp-atflv.
   CLEAR: l_tc130wa,wa_matblock_dt.
   REFRESH : itab_matblock_dt.

   LOOP AT g_tc130_itab INTO l_tc130wa WHERE mark = 'X'.
     IF l_tc130wa-errcd IS INITIAL.
***Updating MARA table.**********************
***flag
       UPDATE mara
       SET    mstae = ''
       WHERE  matnr = l_tc130wa-matcode.
***NORMT
       SELECT SINGLE * FROM mara WHERE
              matnr = l_tc130wa-matcode.
       IF NOT mara-normt IS INITIAL.
         g_normt = mara-normt+0(5).
         UPDATE mara
         SET    normt = g_normt
         WHERE  matnr = l_tc130wa-matcode.
       ENDIF.
***Updating MAKT table.*************************
       IF NOT l_tc130wa-matdesc IS INITIAL.
         g_desclen = strlen( l_tc130wa-matdesc ).
         IF g_desclen > 40.
           g_wrkst39 = l_tc130wa-matdesc+0(39).
           CONCATENATE g_wrkst39 '*' INTO g_wrkst39.
           g_wrkst = l_tc130wa-matdesc+39.
           UPDATE mara
            SET wrkst   = g_wrkst
            WHERE matnr = l_tc130wa-matcode.
           UPDATE makt
            SET    maktx = g_wrkst39
            WHERE  matnr = l_tc130wa-matcode.
         ELSE.
           UPDATE makt
           SET    maktx = l_tc130wa-matdesc
           WHERE  matnr = l_tc130wa-matcode.
         ENDIF.
         CLEAR: g_wrkst,g_wrkst39,g_desclen.
       ENDIF.
***Updating AUSP table
***Material Location
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matloc IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_PLACE_OF_USE_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         DATA: lv_atwrt TYPE ausp-atwrt.
         lv_atwrt = l_tc130wa-matloc.
         UPDATE ausp
*         SET    atwrt = l_tc130wa-matloc
         SET    atwrt = lv_atwrt
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atwrt  = l_tc130wa-matloc.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR l_ausp130.
         ENDIF.
       ENDIF.
       BREAK cab_subodhk.
***Material life
       CLEAR l_atinn130.
       IF NOT l_tc130wa-mat_life IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_LIFE_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atflv = l_tc130wa-mat_life
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atflv  = l_tc130wa-mat_life.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR: l_ausp130,l_matlife.
         ENDIF.
       ENDIF.

***Material Cost
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matcost IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_COST_OF_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atflv = l_tc130wa-matcost
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atflv  = l_tc130wa-matcost.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR:l_matcost, l_ausp130.
         ENDIF.
       ENDIF.
***Material Category
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matcatg IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_GROUP_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         lv_objek = l_tc130wa-matcode.
         lv_atwrt = l_tc130wa-matcatg.
         UPDATE ausp
*         SET    atwrt = l_tc130wa-matcatg
         SET    atwrt = lv_atwrt
*         WHERE  objek = l_tc130wa-matcode
         WHERE  objek =  lv_objek
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atwrt  = l_tc130wa-matcatg.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR l_ausp130.
         ENDIF.
       ENDIF.
***Material Group
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matgp IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_GROUP_OF_SPARES'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_tc130wa-matgp
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atwrt  = l_tc130wa-matgp.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR l_ausp130.
         ENDIF.
       ENDIF.
***Updating long text for Non Moving items.
*       IF l_tc130wa-mstae = 'NM'.
       PERFORM upd_lt_for_nm USING l_tc130wa-matcode
                                   l_tc130wa-res_nm.
*       ENDIF.
***Mofifying internal table.
       l_tc130wa-mstae = ''.
       l_tc130wa-unblkby = sy-uname.
       l_tc130wa-unblkdt = sy-datum.
       MODIFY TABLE g_tc130_itab FROM l_tc130wa.
***Modifying database table
       MOVE-CORRESPONDING l_tc130wa TO wa_matblock_dt.
       MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
       APPEND wa_matblock_dt TO itab_matblock_dt.
       CLEAR:wa_matblock_dt,l_tc130wa.
       MESSAGE i102(zmm_oth).
     ELSE.
       MESSAGE i110(zmm_oth) WITH l_tc130wa-errcd.
     ENDIF.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.
****Modifying those items which have been changed
****but not selected for unblocking.
   LOOP AT g_tc130_itab INTO l_tc130wa WHERE mark <> 'X'.
     l_tc130wa-unblkby = sy-uname.
     l_tc130wa-unblkdt = sy-datum.
     MOVE-CORRESPONDING l_tc130wa TO wa_matblock_dt.
     MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
     APPEND wa_matblock_dt TO itab_matblock_dt.
     CLEAR:wa_matblock_dt,l_tc130wa.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.

 ENDFORM.                    " unblock_130
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM send_mail_to_cdcell.
   DATA: l_text  TYPE soli,
         l_name  LIKE sood1-objnam,
         l_title LIKE sood1-objdes,
         l_user  LIKE sy-uname.
   DATA  l_text_itab LIKE TABLE OF l_text.
**
   CLEAR : l_name,l_title,l_text,l_user.
   REFRESH l_text_itab.
**Assignments.....
   l_name   = zmm_matblockhd_st-reqno.
   CONCATENATE 'Unblock MatCode Request for' zmm_matblockhd_st-reqno
               INTO l_title SEPARATED BY space.
   l_text =
   'Please check the Request and unblock the material codes.This is'
&'a system generated mail, please do not reply.'.
   APPEND l_text TO l_text_itab.

   l_user = 'CODIFICATION'.

***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       mailname  = l_name
       mailtitel = l_title
       user      = l_user
     TABLES
       text      = l_text_itab.

   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " send_mail_to_cdcell
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_reqn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM send_mail_to_reqn.
   DATA: r_text  TYPE soli,
         r_name  LIKE sood1-objnam,
         r_title LIKE sood1-objdes,
         r_user  TYPE sy-uname.
   DATA:  r_text_itab LIKE TABLE OF r_text.
**
   CLEAR : r_name,r_title,r_text.
   REFRESH r_text_itab.
**Assignments.....
   r_name   = zmm_matblockhd_st-reqno.
   CONCATENATE 'Request' zmm_matblockhd_st-reqno 'Status'
               INTO r_title SEPARATED BY space.
   IF zmm_matblockhd_st-reqcl = 'C'.
     r_text = 'Request has been updated.Please check the Request,Request'
   &'status and correspondence within it.this is a system generated mail,'
   &'please do not reply. - codification cell'.
     APPEND r_text TO r_text_itab.
**
   ELSEIF zmm_matblockhd_st-reqcl = 'IR'.
     r_text = 'Please go through the correspondence comments if any & the'
   &'request. after changes, the request should be re-released.'.
     APPEND r_text TO r_text_itab.
     CLEAR r_text.
     r_text = 'All the actions taken should be recorded only in'
   &'correspondence. no separate communication will be entertained. this is a'
    &'system generatedmail.please do not reply'.
     APPEND r_text TO r_text_itab.
   ENDIF..

*   append r_text to r_text_itab.
   SELECT SINGLE reqcpf INTO r_user FROM zmm_matblock_hd
          WHERE reqno = zmm_matblockhd_st-reqno.
***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       mailname  = r_name
       mailtitel = r_title
       user      = r_user
     TABLES
       text      = r_text_itab
     EXCEPTIONS
       error     = 1
       OTHERS    = 2.
   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " send_mail_to_reqn
*&---------------------------------------------------------------------*
*&      Form  UPD_LT_FOR_NM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_TC110WA_MATCODE  text
*      -->P_L_TC110WA_RES_NM  text
*----------------------------------------------------------------------*
 FORM upd_lt_for_nm USING  p_matcode
                           p_res_nm.
   DATA: wa_lines LIKE tline,
         l_txt    LIKE tline-tdline,
         l_insert TYPE c.
   DATA : header   LIKE  thead,
          l_tdname LIKE thead-tdname.
   DATA : ist_nmlines LIKE tline OCCURS 0 WITH HEADER LINE.

****Update Internal Comments
   header-tdobject = 'MATERIAL'.
   header-tdid     = 'IVER'.
   header-tdname   =  p_matcode .
   header-tdspras  = 'EN'.
   header-tdform   = 'SYSTEM'.
   header-mandt    = sy-mandt .
   l_tdname        = p_matcode.
   REFRESH: ist_nmlines.

***Fetching the existing text against matcode.
   SELECT SINGLE * FROM stxh
            WHERE tdobject = 'MATERIAL'
            AND   tdname   = l_tdname
            AND   tdid     = 'IVER'.
   IF sy-subrc = 0.
     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         client   = sy-mandt
         id       = 'IVER'
         language = 'E'
         name     = l_tdname
         object   = 'MATERIAL'
       TABLES
         lines    = ist_nmlines.
   ENDIF.
***Appending the remark to existing text.
   IF NOT ist_nmlines[] IS INITIAL.
     wa_lines-tdformat = '*'.
     wa_lines-tdline = '               '.
     APPEND wa_lines TO ist_nmlines .
   ENDIF.
   CONCATENATE sy-uname '-' sy-datum INTO l_txt .
   wa_lines-tdformat = '*'.
   wa_lines-tdline  =  l_txt .
   APPEND wa_lines TO ist_nmlines .
   wa_lines-tdline = p_res_nm.
   APPEND wa_lines TO ist_nmlines .
   CLEAR l_txt.
   CONCATENATE 'Request no-' zmm_matblockhd_st-reqno INTO l_txt.
   wa_lines-tdline = l_txt.
   APPEND wa_lines TO ist_nmlines .

   IF ist_nmlines[] IS INITIAL.
     l_insert = 'X'.
   ELSE.
     l_insert =  space.
   ENDIF.
***Saving the nonmoving text ( Remark)

   CALL FUNCTION 'SAVE_TEXT'
     EXPORTING
       client          = sy-mandt
       header          = header
       insert          = l_insert
       savemode_direct = 'X'
     TABLES
       lines           = ist_nmlines.


 ENDFORM.                    " UPD_LT_FOR_NM
*&---------------------------------------------------------------------*
*&      Form  lock_reqhd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM lock_reqhd.

   CALL FUNCTION 'ENQUEUE_EZ_MM_MATBLOCK'
     EXPORTING
       mode_zmm_cdhd  = 'E'
       mandt          = sy-mandt
       reqno          = zmm_matblockhd_st-reqno
     EXCEPTIONS
       foreign_lock   = 1
       system_failure = 2
       OTHERS         = 3.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ELSE.
     MOVE 'Y' TO g_lock.
   ENDIF.

 ENDFORM.                    " lock_reqhd
*&---------------------------------------------------------------------*
*&      Form  unlock_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unlock_req.
   CALL FUNCTION 'DEQUEUE_EZ_MM_MATBLOCK'
     EXPORTING
       mode_zmm_cdhd = 'E'
       mandt         = sy-mandt
       reqno         = zmm_matblockhd_st-reqno.

 ENDFORM.                    " unlock_req

*--- INCLUDE: MZMMCODUNBLOCKI01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 25/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete F.M POPUP_TO_CONFRIM_STEP replaced with POPUP_TO_CONFRIM.
************************************************************************


*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: modify table
MODULE tct110_modify INPUT.
  MODIFY g_tc110_itab
    FROM g_tc110_wa
    INDEX tct110-current_line.
  IF sy-subrc <> 0.
    APPEND g_tc110_wa TO g_tc110_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input modul for tc 'TCT110'. do not change this line!
*&spwizard: mark table
MODULE tct110_mark INPUT.
  DATA: g_tct110_wa2 LIKE LINE OF g_tc110_itab.
  IF tct110-line_sel_mode = 1.
    LOOP AT g_tc110_itab INTO g_tct110_wa2
      WHERE mark = 'X'.
      g_tct110_wa2-mark = ''.
      MODIFY g_tc110_itab
        FROM g_tct110_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY g_tc110_itab
    FROM g_tc110_wa
    INDEX tct110-current_line
    TRANSPORTING mark.
ENDMODULE.

*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: process user command
MODULE tct110_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT110'.
*  ok_code = sy-ucomm.
    ok_code = okcode_100.

    PERFORM user_ok_tc USING    'TCT110'
                                'G_TC110_ITAB'
                                'MARK'
                       CHANGING ok_code.
    CLEAR:okcode_100,ok_code.
  ENDIF.
*  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  PERFORM confirm_exit.

ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
*  GET CURSOR FIELD g_curfield.
***To populate the username in the Req Number search help.
  SET PARAMETER ID 'XUS' FIELD sy-uname.
***
  CASE zmm_matblockhd_st-mtart.
    WHEN 'ZCAP'.
      dynnr = '0130'.
    WHEN 'ZSPR'.
      dynnr = '0120'.
    WHEN 'ZSTO'.
      dynnr = '0110'.
    WHEN 'ZDIS'.
      dynnr = '0140'.
    WHEN OTHERS.
*        dynnr = '0101'.
      dynnr = '0110'.
  ENDCASE.

  CASE okcode_100.
    WHEN 'BAC' OR 'CAN'.
      PERFORM back_confirm.
      CLEAR okcode_100.
    WHEN 'CREATE'.
      g_mode = 'CRE'.
      CLEAR okcode_100.
    WHEN 'CHANGE'.
      g_mode = 'CHA'.
      CLEAR okcode_100.
    WHEN 'DISPLAY'.
      g_mode = 'DIS'.
      CLEAR okcode_100.
    WHEN 'DELETE'.
      g_mode = 'DEL'.
      CLEAR okcode_100.
    WHEN 'RELEASE'.
      g_mode = 'REL'.
      CLEAR okcode_100.
    WHEN 'UNBLOCK'.
      PERFORM unblock_matcode.
      IF zmm_matblockhd_st-reqcl = 'C'.
        PERFORM send_mail_to_reqn.
      ENDIF.
      CLEAR okcode_100.
      IF g_choice = 'J'.
        CLEAR g_choice.
        PERFORM clear_var.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'SAV'.
      PERFORM save_request.
*      PERFORM clear_var.
*      CLEAR okcode_100.
    WHEN 'CORRES'.
      CLEAR okcode_100.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
  ENDCASE.
**************************************************************
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: modify table
MODULE tct120_modify INPUT.
  MODIFY g_tc120_itab
    FROM g_tc120_wa
    INDEX tct120-current_line.
  IF sy-subrc <> 0.
    APPEND g_tc120_wa TO g_tc120_itab.
  ENDIF.

ENDMODULE.

*&spwizard: input modul for tc 'TCT120'. do not change this line!
*&spwizard: mark table
MODULE tct120_mark INPUT.
  DATA: g_tct120_wa2 LIKE LINE OF g_tc120_itab.
  IF tct120-line_sel_mode = 1.
    LOOP AT g_tc120_itab INTO g_tct120_wa2
      WHERE mark = 'X'.
      g_tct120_wa2-mark = ''.
      MODIFY g_tc120_itab
        FROM g_tct120_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY g_tc120_itab
    FROM g_tc120_wa
    INDEX tct120-current_line
    TRANSPORTING mark.
ENDMODULE.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: process user command
MODULE tct120_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT120'.
*  ok_code = sy-ucomm.
    ok_code = okcode_100.
    PERFORM user_ok_tc USING    'TCT120'
                                'G_TC120_ITAB'
                                'MARK'
                       CHANGING ok_code.
    CLEAR: ok_code,okcode_100.
  ENDIF.
*  sy-ucomm = ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_uebernehmen1 INPUT.
  gv_xthead_updkz = 0.

  CALL METHOD gv_text_editor1->get_text_as_stream
    IMPORTING
      text                   = lt_text_table1
      is_modified            = gv_xthead_updkz
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      text_stream = lt_text_table1
      itf_text    = tlinetab1.
*
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).
    CALL METHOD gv_text_editor2->get_text_as_stream
      IMPORTING
        text                   = lt_text_table2
        is_modified            = gv_xthead_updkz
      EXCEPTIONS
        error_dp               = 1
        error_cntl_call_method = 2
        OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      TABLES
        text_stream = lt_text_table2
        itf_text    = tlinetab2.
  ENDIF..

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  DATA: okcode105 LIKE sy-ucomm.

  okcode105 = sy-ucomm.

  CASE okcode105.
    WHEN 'OK'.
      CLEAR okcode105.
    WHEN 'CANCEL'.
      REFRESH tlinetab2[].
      CLEAR okcode105.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_reqno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_reqno INPUT.
  DATA : l_hd_reqno LIKE zmm_matblock_hd,
         l_ans      TYPE c.
***Intializing**********
  CLEAR g_hd_copied.
  CLEAR: g_tct110_copied,g_tct120_copied,g_tct130_copied.
  REFRESH: tlinetab1,tlinetab2,lines_cors.
  REFRESH: lt_text_table1,lt_text_table2.

*************************
  IF g_mode = 'CHA'.

    SELECT SINGLE * INTO l_hd_reqno FROM zmm_matblock_hd
           WHERE reqno = zmm_matblockhd_st-reqno.
*** Check for deletion.
    IF l_hd_reqno-lvorm = 'X'.
      MESSAGE i087(zmm_oth) WITH zmm_matblockhd_st-reqno.
      LEAVE TO SCREEN 100.
    ENDIF.
***To check for original creator........
    IF l_hd_reqno-reqcpf <> sy-uname.
      MESSAGE e096(zmm_oth) WITH l_hd_reqno-reqcpf.
    ENDIF.
*** To check for C/AC/IC request.
    IF l_hd_reqno-reqcl = 'C' OR
       l_hd_reqno-reqcl = 'AC'.
      MESSAGE e104(zmm_oth) WITH zmm_matblockhd_st-reqno.
    ENDIF.
    IF l_hd_reqno-reqcl = 'IC'.
      MESSAGE e112(zmm_oth) WITH zmm_matblockhd_st-reqno.
    ENDIF.
***Check for Release reset
    IF l_hd_reqno-rel_flag = 'X'.
      " Begin of <RD1K960036>.
*      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*           EXPORTING
*                defaultoption = 'N'
*                textline1     = 'Release will be reset. Proceed ?'
*                titel         = 'Release Reset'
*           IMPORTING
*                answer        = l_ans.

      DATA : l_answer(1) TYPE c.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Release Reset '
          text_question         = 'Release will be reset. Proceed ?'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = l_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF sy-subrc = 0.
        CASE l_answer.
          WHEN '1'.
            MOVE 'J' TO l_ans.
          WHEN '2'.
            MOVE 'N' TO l_ans.
        ENDCASE.
      ENDIF.

      " End of <RD1K960036>.

      IF l_ans = 'J'.
        g_relflag = 'J'.
        zmm_matblockhd_st-rel_flag = ''.
      ELSE.
        PERFORM clear_var.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDIF.
  ELSEIF g_mode = 'REL'.
    CLEAR l_hd_reqno.
    SELECT SINGLE * INTO l_hd_reqno FROM zmm_matblock_hd
          WHERE reqno = zmm_matblockhd_st-reqno.
    IF sy-subrc = 0.
      IF l_hd_reqno-reqcpf <> sy-uname.
        MESSAGE e107(zmm_oth) WITH l_hd_reqno-reqcpf.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_reqno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_spell  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_spell INPUT.
  PERFORM spell_check USING g_tc110_wa-matdesc.
  IF g_errflag = 'Y'.

    " Begin of <RD1K960036>.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        textline1 = 'There are spelling errors in description(s)'
*        textline2            = 'Proceed with errors? '
*        titel                = 'Spelling Errors'
**
*      IMPORTING
*         answer               = g_ans.
    DATA : l_answer1(1) TYPE c.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Spelling Errors '
        text_question         = 'There are spelling errors in description(s)'
                                & 'Proceed with errors? '
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
      IMPORTING
        answer                = l_answer1
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CASE l_answer1.
        WHEN '1'.
          MOVE 'J' TO g_ans.
        WHEN '2'.
          MOVE 'N' TO g_ans.
      ENDCASE.
    ENDIF.

    " End of <RD1K960036>.

    IF g_ans = 'J'.
      g_tc110_wa-errcd = 'S'.
    ELSE.
      GET CURSOR LINE g_cursor_line.
      g_curr_line = tct110-top_line + g_cursor_line - 1.
      SET CURSOR FIELD 'G_TC110_WA-MATDESC' LINE g_curr_line.
      MESSAGE e114(zmm_oth) WITH g_tc110_wa-matdesc.
    ENDIF.
    CLEAR g_errflag.
  ELSE.
    IF g_tc110_wa-errcd = 'S'.
      g_tc110_wa-errcd = ''.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_spell  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_tel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.
  DATA : tel_len TYPE i.
  tel_len = strlen( zmm_matblockhd_st-tel ).
  IF  zmm_matblockhd_st-tel CN ' 0123456789-'.
    MESSAGE e059(zmm_oth).
  ELSE.
    IF tel_len < 7.
      MESSAGE e060(zmm_oth).
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_tel  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_plant INPUT.
  DATA : l_werks LIKE t001w-werks.
  IF NOT zmm_matblockhd_st-werks IS INITIAL.
    SELECT SINGLE werks INTO l_werks FROM t001w
           WHERE werks = zmm_matblockhd_st-werks.
    IF sy-subrc <> 0.
      MESSAGE e033(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcode110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcode110 INPUT.
  DATA:l_tc110    TYPE ty_tc110,
       l110_blkdt LIKE zmm_matblock_dt.

  IF ( g_mode = 'CRE' OR
       g_mode = 'CHA' ) AND
       zmm_matblockhd_st-reqcl <> 'IR'.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc110_wa-matcode
           AND   mtart = zmm_matblockhd_st-mtart
           AND   mstae IN ('PC','TC').
    IF sy-subrc <> 0.
      MESSAGE e090(zmm_oth).
    ENDIF.
  ENDIF.
**
  IF g_mode = 'CRE'.
    SELECT * INTO l110_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE matcode = g_tc110_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc110_wa-matcode l110_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO l110_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE reqno <> zmm_matblockhd_st-reqno AND matcode = g_tc110_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc110_wa-matcode l110_blkdt-reqno.
    ENDIF.
  ENDIF.
**
*  IF sy-ucomm = 'DBLCLK'.
*    CLEAR: g_cfld,l_tc110,g_selline.
*    GET CURSOR LINE g_selline.
*    GET CURSOR FIELD g_cfld.
*    READ TABLE g_tc110_itab INTO l_tc110 INDEX g_selline.
*    IF g_cfld = 'G_TC110_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc110-matcode.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

ENDMODULE.                 " check_matcode110  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcode INPUT.
  DATA: l_blkdt LIKE zmm_matblock_dt.
  DATA: l_tc120 TYPE ty_tc120.
  IF ( g_mode = 'CRE' OR g_mode = 'CHA' )
     AND zmm_matblockhd_st-reqcl <> 'IR'.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc120_wa-matcode
           AND   mtart = zmm_matblockhd_st-mtart
           AND   mstae IN ('PC','TC').
    IF sy-subrc <> 0.
      MESSAGE e090(zmm_oth).
    ENDIF.
  ENDIF.
***
  IF g_mode = 'CRE'.
    SELECT * INTO l_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE matcode = g_tc120_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc120_wa-matcode l_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO l_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE reqno <> zmm_matblockhd_st-reqno AND matcode = g_tc120_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc120_wa-matcode l_blkdt-reqno.
    ENDIF.
  ENDIF.
***
*  IF sy-ucomm = 'DBLCLK'.
*    CLEAR: g_cfld,l_tc120,g_selline.
*    GET CURSOR LINE g_selline.
*    GET CURSOR FIELD g_cfld.
*    READ TABLE g_tc120_itab INTO l_tc120 INDEX g_selline.
*    IF g_cfld = 'G_TC120_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc120-matcode.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

* clear: g_cfld,l_tc130,g_selline.
*  GET CURSOR LINE g_selline.
*  get cursor field g_cfld.
*  read table g_tc130_itab into l_tc130 index g_selline.
*  IF g_cfld = 'G_TC130_WA-MATCODE'.
*    set parameter id 'MAT' field l_tc130-matcode.
*    call transaction 'MM03' and skip first screen.
*  ENDIF.
* clear sy-ucomm.


ENDMODULE.                 " check_matcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_partno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_partno INPUT.

  PERFORM check_splchar USING g_tc120_wa-npartno.
  IF NOT g_oputdata IS INITIAL.
    g_tc120_wa-npartno = g_oputdata .
  ENDIF.
**To clear new part number if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-npartno.
  ENDIF.
**

ENDMODULE.                 " check_partno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_mdlno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mdlno INPUT.

*  PERFORM check_splchar USING g_tc120_wa-nmdlno.
*  g_tc120_wa-nmdlno = g_oputdata .
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  DATA: lv_mdlno TYPE zmm_mdl-mdlno.
  lv_mdlno = g_tc120_wa-nmdlno.
*  IF NOT g_tc120_wa-nmdlno IS INITIAL.
  IF NOT lv_mdlno IS INITIAL.
    SELECT SINGLE * FROM zmm_mdl
*           WHERE mdlno = g_tc120_wa-nmdlno.
           WHERE mdlno = lv_mdlno.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF sy-subrc <> 0.
      MESSAGE e111(zmm_oth).
    ENDIF.
  ENDIF.
**To clear new model number if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-nmdlno.
  ENDIF.
**
ENDMODULE.                 " check_mdlno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_spell_spr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_spell_spr INPUT.
  PERFORM spell_check USING g_tc120_wa-matdesc.
  IF g_errflag = 'Y'.

    " Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        textline1 = 'There are spelling errors in description(s)'
*        textline2            = 'Proceed with errors? '
*        titel                = 'Spelling Errors'
**
*      IMPORTING
*         answer               = g_ans.
    DATA : l_answer2(1) TYPE c.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Spelling Errors '
        text_question         = 'There are spelling errors in description(s)'
                                & 'Proceed with errors?'
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
      IMPORTING
        answer                = l_answer2
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CASE l_answer2.
        WHEN '1'.
          MOVE 'J' TO g_ans.
        WHEN '2'.
          MOVE 'N' TO g_ans.
      ENDCASE.
    ENDIF.

    " End of <RD1K960036>.

    IF g_ans = 'J'.
      g_tc120_wa-errcd = 'S'.
    ELSE.
      GET CURSOR LINE g_cursor_line.
      g_curr_line = tct120-top_line + g_cursor_line - 1.
      SET CURSOR FIELD 'G_TC120_WA-MATDESC' LINE g_curr_line.
      MESSAGE e114(zmm_oth) WITH g_tc120_wa-matdesc.
    ENDIF.
    CLEAR g_errflag.
  ELSE.
    IF g_tc120_wa-errcd = 'S'.
      g_tc120_wa-errcd = ''.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_spell_spr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate INPUT.
  DATA: l_sto TYPE ty_tc110.
  CLEAR : g_clrndesc.

  READ TABLE g_tc110_itab INTO l_sto
                          WITH KEY matcode = g_tc110_wa-matcode.
  IF sy-subrc = 0.
    IF l_sto-srno <> g_tc110_wa-srno.
      MESSAGE e093(zmm_oth).
    ENDIF.
  ENDIF.
***
*  IF g_tc110_wa-omatdesc IS INITIAL.

  SELECT maktx INTO g_tc110_wa-omatdesc
 FROM makt UP TO 1 ROWS WHERE matnr = g_tc110_wa-matcode
 ORDER BY PRIMARY KEY .
  ENDSELECT.
*  ENDIF.
*  IF g_tc110_wa-ouom IS INITIAL OR
*     g_tc110_wa-mstae IS INITIAL.
  SELECT SINGLE meins mstae INTO
               (g_tc110_wa-ouom,g_tc110_wa-mstae)
         FROM mara
         WHERE matnr = g_tc110_wa-matcode.
*  ENDIF.
*******To clear the proposed material description if any,
  g_clrndesc = 'Y'.
***********************
ENDMODULE.                 " check_duplicate  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate_spr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate_spr INPUT.
  DATA : l_mara LIKE mara.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  DATA: lv_matnr TYPE mara-matnr,
        lv_objek TYPE ausp-objek.
  READ TABLE g_tc120_itab WITH KEY matcode = g_tc120_wa-matcode.
  IF sy-subrc = 0.
    MESSAGE e093(zmm_oth).
  ENDIF.
***
***Material Description
*  IF NOT g_tc120_wa-matcode IS INITIAL.
  lv_matnr = g_tc120_wa-matcode.
  lv_objek = g_tc120_wa-matcode.

  SELECT maktx INTO g_tc120_wa-omatdesc
 FROM makt UP TO 1 ROWS WHERE
*    matnr = g_tc120_wa-matcode
    matnr = lv_matnr
 ORDER BY PRIMARY KEY .
  ENDSELECT.
***UOM, OEM, Part Number
  SELECT SINGLE * INTO l_mara FROM mara
*         WHERE matnr = g_tc120_wa-matcode.
         WHERE matnr = lv_matnr.
  IF sy-subrc = 0.
    g_tc120_wa-mstae   = l_mara-mstae.
    g_tc120_wa-ouom    = l_mara-meins.
    g_tc120_wa-ooem    = l_mara-mfrnr.
    g_tc120_wa-opartno = l_mara-mfrpn.
***Model Number
    SELECT atinn FROM cabn INTO g_modelcode_no UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MODELCODE'
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc <> 0.
      g_modelcode_no = ''.
    ENDIF.

*    SELECT atwrt INTO g_tc120_wa-omdlno
    SELECT atwrt INTO @DATA(lv_omdlno)
 FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc120_wa-matcode
      objek = @lv_objek
      AND atinn = @g_modelcode_no
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    g_tc120_wa-omdlno = lv_omdlno+0(30) .  "#EC CI_FLDEXT_OK[2215424]
***Capital Code
    SELECT atinn FROM cabn INTO g_capcode_no UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CAPCODE'
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc <> 0.
      g_capcode_no = ''.
    ENDIF.
    SELECT atwrt INTO g_tc120_wa-ocapno
 FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc120_wa-matcode
      objek = lv_objek
      AND atinn = g_capcode_no
 ORDER BY PRIMARY KEY .
    ENDSELECT.
  ENDIF.
*  ENDIF.
  "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
*******To clear the proposed material description if any,
  g_clrndesc = 'Y'.
***********************


ENDMODULE.                 " check_duplicate_spr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_noem  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_noem INPUT.
  IF NOT g_tc120_wa-noem IS INITIAL.
    SELECT SINGLE * FROM lfa1
           WHERE lifnr = g_tc120_wa-noem.
    IF sy-subrc <> 0.
      MESSAGE e105(zmm_oth) WITH g_tc120_wa-noem.
    ENDIF.
  ENDIF.
**To clear new oem if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-noem.
  ENDIF.
**
ENDMODULE.                 " check_noem  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_ncapno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_ncapno INPUT.
  IF NOT g_tc120_wa-ncapno IS INITIAL.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc120_wa-ncapno.
    IF sy-subrc <> 0.
      MESSAGE e106(zmm_oth) WITH g_tc120_wa-ncapno.
    ENDIF.
  ENDIF.
**To clear new part number if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-ncapno.
  ENDIF.
  CLEAR g_clrndesc.
**
ENDMODULE.                 " check_ncapno  INPUT

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: modify table
MODULE tct130_modify INPUT.
  MODIFY g_tc130_itab
    FROM g_tc130_wa
    INDEX tct130-current_line.
  IF sy-subrc <> 0.
    APPEND g_tc130_wa TO g_tc130_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input modul for tc 'TCT130'. do not change this line!
*&spwizard: mark table
MODULE tct130_mark INPUT.
  DATA: g_tct130_wa2 LIKE LINE OF g_tc130_itab.
  IF tct130-line_sel_mode = 1.
    LOOP AT g_tc130_itab INTO g_tct130_wa2
      WHERE mark = 'X'.
      g_tct130_wa2-mark = ''.
      MODIFY g_tc130_itab
        FROM g_tct130_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY g_tc130_itab
    FROM g_tc130_wa
    INDEX tct130-current_line
    TRANSPORTING mark.
ENDMODULE.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: process user command
MODULE tct130_user_command INPUT.

  IF sy-ucomm+0(6) = 'TCT130'.
    ok_code = okcode_100.
    PERFORM user_ok_tc USING    'TCT130'
                                'G_TC130_ITAB'
                                'MARK'
                     CHANGING ok_code.
    CLEAR: ok_code,okcode_100.
  ENDIF.
*  sy-ucomm = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  check_matcode130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcode130 INPUT.
  DATA: l130_blkdt LIKE zmm_matblock_dt.
  DATA: l_tc130 TYPE ty_tc130.
  IF ( g_mode = 'CRE' OR g_mode = 'CHA' )
     AND zmm_matblockhd_st-reqcl <> 'IR'.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc130_wa-matcode
           AND   mtart = zmm_matblockhd_st-mtart
           AND   mstae IN ('PC','TC').
    IF sy-subrc <> 0.
      MESSAGE e090(zmm_oth).
    ENDIF.
  ENDIF.
***
  IF g_mode = 'CRE'.
    SELECT * INTO l130_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE matcode = g_tc130_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc130_wa-matcode l130_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO l130_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE reqno <> zmm_matblockhd_st-reqno AND matcode = g_tc130_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc130_wa-matcode l130_blkdt-reqno.
    ENDIF.
  ENDIF.

***
*  IF sy-ucomm = 'DBLCLK'.
*    CLEAR: g_cfld,l_tc130,g_selline.
*    GET CURSOR LINE g_selline.
*    GET CURSOR FIELD g_cfld.
*    READ TABLE g_tc130_itab INTO l_tc130 INDEX g_selline.
*    IF g_cfld = 'G_TC130_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc130-matcode.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

ENDMODULE.                 " check_matcode130  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate_cap  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate_cap INPUT.
  DATA : l130_mara LIKE mara.
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  READ TABLE g_tc130_itab WITH KEY matcode = g_tc130_wa-matcode.
  IF sy-subrc = 0.
    MESSAGE e093(zmm_oth).
  ENDIF.
***
***Material Description
*  IF NOT g_tc130_wa-matcode IS INITIAL.
  lv_matnr = g_tc130_wa-matcode.
  SELECT maktx INTO g_tc130_wa-omatdesc
 FROM makt UP TO 1 ROWS WHERE
*    matnr = g_tc130_wa-matcode
    matnr = lv_matnr
 ORDER BY PRIMARY KEY .
  ENDSELECT.
***UOM, OEM, Part Number
  SELECT SINGLE * INTO l130_mara FROM mara
*         WHERE matnr = g_tc130_wa-matcode.
         WHERE matnr = lv_matnr.
  IF sy-subrc = 0.
    g_tc130_wa-mstae  = l130_mara-mstae.
    g_tc130_wa-ouom   = l130_mara-meins.

***Material Location
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_PLACE_OF_USE_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.
    lv_objek = g_tc130_wa-matcode.
*    SELECT atwrt INTO g_tc130_wa-omatloc
    SELECT atwrt INTO @DATA(lv_omatloc)
FROM ausp UP TO 1 ROWS
*      WHERE objek = g_tc130_wa-matcode
      WHERE objek = @lv_objek
      AND atinn = @g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
    g_tc130_wa-omatloc = g_tc130_wa-omatloc+0(30).  "#EC CI_FLDEXT_OK[2215424]
***Material life
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_LIFE_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.

    SELECT atflv INTO g_tc130_wa-omat_life
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = lv_objek
      AND atinn = g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
***Material Cost
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_COST_OF_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.

    SELECT atflv INTO g_tc130_wa-omatcost
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = lv_objek
      AND atinn = g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
***Material Category
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_GROUP_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.

*    SELECT atwrt INTO g_tc130_wa-omatcatg
    SELECT atwrt INTO @DATA(lv_omatcatg)
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = @lv_objek
      AND atinn = @g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
g_tc130_wa-omatcatg = lv_omatcatg+0(30).   "#EC CI_FLDEXT_OK[2215424]
***Material Group
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_GROUP_OF_SPARES'
ORDER BY PRIMARY KEY .
    ENDSELECT.

    SELECT atwrt INTO g_tc130_wa-omatgp
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = lv_objek
      AND atinn = g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
  ENDIF.
  "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
***To clear the proposed material description if any,
  g_clrndesc = 'Y'.
***********************

ENDMODULE.                 " check_duplicate_cap  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.

ENDMODULE.                 " USER_COMMAND_0103  INPUT

AT USER-COMMAND.
  IF g_mode = 'REL'.
    CASE sy-ucomm.
      WHEN 'AGREE'.
        g_rel = 'Y'.
        CLEAR sy-ucomm.
        LEAVE TO SCREEN 0.
      WHEN 'DISAGREE'.
        g_rel = 'N'.
        CLEAR sy-ucomm.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Module  check_spell_cap  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_spell_cap INPUT.
  PERFORM spell_check USING g_tc130_wa-matdesc.
  IF g_errflag = 'Y'.

    " Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        textline1 = 'There are spelling errors in description(s)'
*        textline2            = 'Proceed with errors? '
*        titel                = 'Spelling Errors'
**
*      IMPORTING
*         answer               = g_ans.

    DATA : l_variable.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Spelling Errors '
        text_question         = 'There are spelling errors in description(s)'
                                & 'Proceed with errors?'
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
      IMPORTING
        answer                = l_variable
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CASE l_variable.
        WHEN '1'.
          MOVE 'J' TO g_ans.
        WHEN '2'.
          MOVE 'N' TO g_ans.
      ENDCASE.
    ENDIF.

    " End of <RD1K960036>.

    IF g_ans = 'J'.
      g_tc130_wa-errcd = 'S'.
    ELSE.
      GET CURSOR LINE g_cursor_line.
      g_curr_line = tct130-top_line + g_cursor_line - 1.
      SET CURSOR FIELD 'G_TC130_WA-MATDESC' LINE g_curr_line.
      MESSAGE e114(zmm_oth) WITH g_tc130_wa-matdesc.
    ENDIF.
    CLEAR g_errflag.
  ELSE.
    IF g_tc130_wa-errcd = 'S'.
      g_tc130_wa-errcd = ''.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_spell_cap  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_newdesc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_newdesc INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc110_wa-matdesc.
  ENDIF.
  CLEAR g_clrndesc.
ENDMODULE.                 " clear_newdesc  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_ndesc120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_ndesc120 INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-matdesc.
  ENDIF.
ENDMODULE.                 " clear_ndesc120  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_ndesc130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_ndesc130 INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matdesc.
  ENDIF.

ENDMODULE.                 " clear_ndesc130  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matloc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matloc INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matloc.
  ENDIF.
ENDMODULE.                 " check_matloc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matgp  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matgp INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matgp.
  ENDIF.

ENDMODULE.                 " check_matgp  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcost  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcost INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matcost.
  ENDIF.
ENDMODULE.                 " check_matcost  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matlife  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matlife INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-mat_life.
  ENDIF.
  CLEAR g_clrndesc.

****Life less than 100.
  IF g_tc130_wa-mat_life > 100.
    MESSAGE e115(zmm_oth).
  ENDIF.
ENDMODULE.                 " check_matlife  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_user INPUT.
  DATA l_user LIKE soud3.
* clear: g_fname.
**
* GET CURSOR FIELD g_fname.
*  CASE g_fname.
*    WHEN 'ZMM_MATBLOCKHD_ST-REQCPF'.
  l_user = zmm_matblockhd_st-reqcpf.
*  ENDCASE.
* IF sy-ucomm = 'DBLCLK'.
  CALL FUNCTION 'SO_ADDRESS_SHOW'
    EXPORTING
      user                       = l_user
    EXCEPTIONS
      parameter_error            = 1
      user_not_exist             = 2
      x_error                    = 3
      operation_no_authorization = 4
      OTHERS                     = 5.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*  clear sy-ucomm.
* Endif.
ENDMODULE.                 " show_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_code INPUT.
  DATA : l_matcode LIKE zmm_matblock_dt-matcode.
*IF sy-ucomm = 'DBLCLK'.
  CLEAR: g_cfld,l_tc110,g_selline.
*    GET CURSOR LINE g_selline.
  GET CURSOR FIELD g_cfld.

  CASE g_cfld.
    WHEN 'G_TC110_WA-MATCODE'.
      l_matcode = g_tc110_wa-matcode.
    WHEN 'G_TC120_WA-MATCODE'.
      l_matcode = g_tc120_wa-matcode.
    WHEN 'G_TC130_WA-MATCODE'.
      l_matcode = g_tc130_wa-matcode.
    WHEN 'G_TC120_WA-NCAPNO'.
      l_matcode = g_tc120_wa-ncapno.
    WHEN 'G_TC120_WA-OCAPNO'.
      l_matcode = g_tc120_wa-ocapno.
  ENDCASE.
*    READ TABLE g_tc110_itab INTO l_tc110 INDEX g_selline.
*    IF g_cfld = 'G_TC110_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc110-matcode.
  SET PARAMETER ID 'MAT' FIELD l_matcode.
  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

ENDMODULE.                 " show_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcatg  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcatg INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matcatg.
  ENDIF.

ENDMODULE.                 " check_matcatg  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcatg_val  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcatg_val INPUT.
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  DATA: lv_atwrt_1 TYPE zmmcdcap_usrgp_v-atwrt.
  lv_atwrt_1 = g_tc130_wa-matcatg.
  IF NOT g_tc130_wa-matcatg IS INITIAL.
    SELECT SINGLE * FROM zmmcdcap_usrgp_v
*           WHERE atwrt = g_tc130_wa-matcatg.
           WHERE atwrt = lv_atwrt_1.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF sy-subrc <> 0.
      MESSAGE e117(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_matcatg_val  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matlocval  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matlocval INPUT.
  IF NOT g_tc130_wa-matloc IS INITIAL.
    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

    DATA: lv_atwrt TYPE zmmcdcap_loc_v-atwrt.
    lv_atwrt = g_tc130_wa-matloc.
    SELECT SINGLE * FROM zmmcdcap_loc_v
*           WHERE atwrt = g_tc130_wa-matloc.
           WHERE atwrt = lv_atwrt.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF sy-subrc <> 0.
      MESSAGE e118(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_matlocval  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_oem  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_oem INPUT.
  DATA : l_oem LIKE zmm_matblock_dt-ooem.
  CLEAR: g_cfld,g_selline.

  GET CURSOR FIELD g_cfld.

  CASE g_cfld.
    WHEN 'G_TC120_WA-OOEM'.
      l_oem = g_tc120_wa-ooem.
    WHEN 'G_TC120_WA-NOEM'.
      l_oem = g_tc120_wa-noem..
  ENDCASE.
  "Begin of ATC Correction 29.04.2026
*      SET PARAMETER ID 'LIF' FIELD l_oem.
*      CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.

  SELECT partner FROM v_cvi_vend_link
INTO @DATA(lv_partner) UP TO 1 ROWS WHERE lifnr = @l_oem
ORDER BY PRIMARY KEY .
  ENDSELECT.

  DATA(request) = NEW cl_bupa_navigation_request( ).
  request->set_partner_number( lv_partner ).     " import your BP number here
  CALL METHOD request->set_bupa_activity
    EXPORTING
      iv_value = request->gc_activity_display.
  DATA(options) = NEW cl_bupa_dialog_joel_options( ).
  options->set_navigation_disabled( abap_true ).
  cl_bupa_dialog_joel=>start_with_navigation( iv_request = request
  iv_options = options ).
  "End of ATC Correction 29.04.2026

ENDMODULE.                 " show_oem  INPUT

*--- INCLUDE: MZMMCODUNBLOCKO01 ---*
*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tct110_change_tc_attr OUTPUT.
  LOOP AT tct110-cols INTO col110 WHERE index EQ 10.
      col110-invisible = '1'.
      MODIFY tct110-cols FROM col110 INDEX sy-tabix.
  ENDLOOP.

  DESCRIBE TABLE g_tc110_itab LINES tct110-lines.
ENDMODULE.

*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct110_get_lines OUTPUT.
  g_tct110_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : l_mode(3) TYPE c.
*****To set the mode to 'BLK'.
  IMPORT wa_mode TO l_mode FROM MEMORY ID 'CODUNBLK'.
  IF sy-subrc = 0.
    g_mode = l_mode.
  ENDIF.
  FREE MEMORY ID 'CODUNBLK'.
*  clear g_section.
*  IMPORT wa_section TO g_section FROM MEMORY ID 'CODUNBLK_SEC'.
*  FREE MEMORY ID 'CODUNBLK_SEC'.
*****
  PERFORM fill_sttab.
  SET PF-STATUS 'OPTNS' EXCLUDING it_tab1.
  CASE g_mode.
    WHEN 'CRE'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Create Request'.
    WHEN 'CHA'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Change Request'.
    WHEN 'DIS'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Display Request'.
    WHEN 'DEL'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Delete Request'.
    WHEN 'REL'.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ': Release Request'.
    WHEN OTHERS.
      SET TITLEBAR 'MATCOD_UNBLOCK_TTL' WITH ''.
  ENDCASE.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_MATTY_TCT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_matty_tct OUTPUT.
  DATA : l_reqno(10) TYPE c.
  IF g_mode = 'BLK'.
    GET PARAMETER ID 'ZDNO' FIELD l_reqno.
    zmm_matblockhd_st-reqno = l_reqno.
  ENDIF.
  PERFORM fill_mattyp_itemdt.
*  set parameter id 'ZMATGP' field ''.
*  set parameter id 'MTA' field ZMM_CDHD_ST-MTART.
  IF dynnr IS INITIAL.
*    dynnr = '0101'.
    dynnr = '0110'.
  ENDIF.

ENDMODULE.                 " GET_MATTY_TCT  OUTPUT

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tct120_change_tc_attr OUTPUT.
  LOOP AT tct120-cols INTO col120 WHERE index EQ 18.
      col120-invisible = '1'.
      MODIFY tct120-cols FROM col120 INDEX sy-tabix.
  ENDLOOP.
  DESCRIBE TABLE g_tc120_itab LINES tct120-lines.
ENDMODULE.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct120_get_lines OUTPUT.
  g_tct120_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SCR100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.
  CASE g_mode.
    WHEN ''.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'CRE'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO'  OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REQCPF' OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REQDATE' OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REQCL'  OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REL_FLAG'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'CHA'.
      IF zmm_matblockhd_st-reqno IS INITIAL.
        LOOP AT SCREEN.
          IF screen-name <> 'ZMM_MATBLOCKHD_ST-REQNO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO' OR
             screen-name = 'PB_CORS' OR
             screen-name = 'ZMM_MATBLOCKHD_ST-WERKS' OR
             screen-name = 'ZMM_MATBLOCKHD_ST-ADDR1' OR
             screen-name = 'ZMM_MATBLOCKHD_ST-TEL'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN 'REL'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO' OR
           screen-name = 'ZMM_MATBLOCKHD_ST-REL_FLAG' OR
           screen-name = 'PB_CORS'.
          screen-input = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_MATBLOCKHD_ST-REQNO' OR
           screen-name = 'PB_CORS'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
        IF g_mode = 'BLK'.
          IF screen-name = 'ZMM_MATBLOCKHD_ST-REQCL'.
            IF zmm_matblockhd_st-reqcl = 'N' OR
               zmm_matblockhd_st-reqcl = 'IC' OR
               zmm_matblockhd_st-reqcl = 'IR'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " SCR100_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct110_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct110_init OUTPUT.
  Data : l_matgp110(2) type c.
  IF g_tct110_copied IS INITIAL.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_matblock_dt
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc110_itab
        WHERE reqno = zmm_matblockhd_st-reqno.
    ENDIF.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if g_mode = 'BLK'.
      select single * from zmm_blkcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        select single * from zmm_blkcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          if g_section = 'I'.
            delete g_tc110_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc110_itab where mstae = 'NM'.
          endif.
          loop at g_tc110_itab into g_tc110_wa.
            l_matgp110 = g_tc110_wa-matcode+0(2).
            select single * from zmm_blkcodifier
                 where codifier = sy-uname
                 and   matgp    = l_matgp110.
            if sy-subrc <> 0.
              delete g_TC110_itab index sy-tabix.
            endif.
            clear l_matgp110.
          endloop.
        endif.
      else.
        if g_section = 'I'.
            delete g_tc110_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc110_itab where mstae = 'NM'.
        endif.
      endif.
    endif.
****
    g_tct110_copied = 'X'.
    REFRESH CONTROL 'TCT110' FROM SCREEN '0110'.
  ENDIF.
ENDMODULE.                 " tct110_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct120_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct120_init OUTPUT.
 Data : l_matgp120(2) type c.
  IF g_tct120_copied IS INITIAL.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_matblock_dt
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc120_itab
        WHERE reqno = zmm_matblockhd_st-reqno.
    ENDIF.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if g_mode = 'BLK'.
      select single * from zmm_blkcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        select single * from zmm_blkcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          if g_section = 'I'.
            delete g_tc120_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc120_itab where mstae = 'NM'.
          endif.
          loop at g_tc120_itab into g_tc120_wa.
            l_matgp120 = g_tc120_wa-matcode+0(2).
            select single * from zmm_blkcodifier
                 where codifier = sy-uname
                 and   matgp    = l_matgp120.
            if sy-subrc <> 0.
              delete g_TC120_itab index sy-tabix.
            endif.
            clear l_matgp120.
          endloop.
        endif.
      else.
         if g_section = 'I'.
            delete g_tc120_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc120_itab where mstae = 'NM'.
          endif.
      endif.
    endif.
****
    g_tct120_copied = 'X'.
    REFRESH CONTROL 'TCT120' FROM SCREEN '0120'.
  ENDIF.

ENDMODULE.                 " tct120_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct110_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct110_move OUTPUT.
  DATA : l_srno TYPE i,
         l_labst LIKE mard-labst.
*  MOVE-CORRESPONDING g_tc110_wa TO zmm_matblock_dt.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tc110_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tc110_wa-srno = 0.
        PERFORM get_nextsrno_sto.
        MOVE l_srno TO g_tc110_wa-srno.
        MODIFY g_tc110_itab FROM g_tc110_wa
        INDEX tct110-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
  ENDIF.
***Plant Stock***********
  IF NOT g_tc110_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc110_wa-p_stock
      WHERE werks = zmm_matblockhd_st-werks
      AND   matnr = g_tc110_wa-matcode.
    MODIFY g_tc110_itab FROM g_tc110_wa
    INDEX tct110-current_line TRANSPORTING p_stock.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tc110_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc110_wa-c_stock
    WHERE matnr = g_tc110_wa-matcode.

    MODIFY g_tc110_itab FROM g_tc110_wa
    INDEX tct110-current_line TRANSPORTING c_stock.
  ENDIF.


ENDMODULE.                 " tct110_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.
  IF NOT zmm_matblockhd_st-reqno IS INITIAL.
*    IF g_hd_copied IS INITIAL.
      IF g_mode <> 'CRE' and g_hd_copied is initial.
        if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' )
                              OR ( g_mode = 'BLK' ).
            perform lock_reqhd.
        endif.
        SELECT SINGLE * FROM zmm_matblock_hd
        INTO CORRESPONDING FIELDS OF zmm_matblockhd_st
            WHERE reqno = zmm_matblockhd_st-reqno.
        IF g_relflag = 'J'.
          zmm_matblockhd_st-rel_flag = ''.
          zmm_matblockhd_st-apr_flag = ''.
          CLEAR g_relflag.
        ENDIF.
        g_hd_copied = 'X'.
      ENDIF.
*    ENDIF.
  ENDIF.
  PERFORM get_correspondense.
  SET PARAMETER ID 'ZMAT_TY' FIELD zmm_matblockhd_st-mtart.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct110_change_field_attr OUTPUT.
  CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'G_TC110_WA-ERRCD'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_matblockhd_st-werks IS INITIAL AND
           NOT zmm_matblockhd_st-tel IS INITIAL.
          IF NOT g_tc110_wa-matcode IS INITIAL.
            IF g_tc110_wa-mstae <> 'NM'.
              IF screen-name    = 'G_TC110_WA-MATDESC'.
                screen-required = '1'.
                MODIFY SCREEN.
              ELSEIF screen-name    = 'G_TC110_WA-RES_NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ELSE.
              IF screen-group1 = 'NM'.
                screen-required = '1'.
                MODIFY SCREEN.
              ELSE.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
            IF zmm_matblockhd_st-reqcl = 'IR'.
              IF g_tc110_wa-mstae = ''.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
              IF screen-name    = 'G_TC110_WA-MATCODE'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'DIS' OR 'DEL' OR 'REL'.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'BLK'.
      LOOP AT SCREEN.
        IF g_tc110_wa-mstae = ''.
          screen-input = '0'.
          MODIFY SCREEN.
        ELSE.
          IF screen-name = 'G_TC110_WA-MARK'.
             screen-input = '1'.
             MODIFY SCREEN.
          ELSEIF screen-name = 'G_TC110_WA-MATDESC'.
            IF g_tc110_wa-mstae = 'NM'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC110_WA-ERRCD'.
            IF g_tc110_wa-errcd = 'S'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC110_WA-MATCODE'.
            IF NOT g_tc110_wa-matcode IS INITIAL.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC110_WA-RES_NM'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF zmm_matblockhd_st-reqcl = 'C' OR
           zmm_matblockhd_st-reqcl = 'AC'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN ''.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDMODULE.                 " tct110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct120_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct120_move OUTPUT.
*  DATA : l_mara LIKE mara.

****Serial Number.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tc120_wa-matcode IS INITIAL.
**********To get the maximum srno in the internal table***
      CLEAR: l_srno.
      IF g_tc120_wa-srno = 0.
        PERFORM get_nextsrno_spr.
        MOVE l_srno TO g_tc120_wa-srno.
        MODIFY g_tc120_itab FROM g_tc120_wa INDEX
             tct120-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
  ENDIF.

***Plant Stock***********
  IF NOT g_tc120_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc120_wa-p_stock
      WHERE werks = zmm_matblockhd_st-werks
      AND   matnr = g_tc120_wa-matcode.
    MODIFY g_tc120_itab FROM g_tc120_wa
    INDEX tct120-current_line TRANSPORTING p_stock.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tc120_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc120_wa-c_stock
    WHERE matnr = g_tc120_wa-matcode.

    MODIFY g_tc120_itab FROM g_tc120_wa
    INDEX tct120-current_line TRANSPORTING c_stock.
  ENDIF.


ENDMODULE.                 " tct120_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct120_change_field_attr OUTPUT.
  CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'G_TC120_WA-ERRCD'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_matblockhd_st-werks IS INITIAL AND
           NOT zmm_matblockhd_st-tel IS INITIAL.
          IF NOT g_tc120_wa-matcode IS INITIAL.
            IF g_tc120_wa-mstae <> 'NM'.
              IF screen-name    = 'G_TC120_WA-NPARTNO'.
                IF g_tc120_wa-opartno IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-NMDLNO'.
                IF g_tc120_wa-omdlno IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-NCAPNO'.
                IF g_tc120_wa-ocapno IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-NOEM'.
                IF g_tc120_wa-ooem IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC120_WA-RES_NM'.
                screen-input     = '0'.
                MODIFY SCREEN.
              ENDIF.
            ELSE.
              IF SCREEN-GROUP1 <> 'NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ELSE.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ENDIF.
          IF zmm_matblockhd_st-reqcl = 'IR'.
            IF g_tc120_wa-mstae = ''.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
            IF screen-name    = 'G_TC120_WA-MATCODE'.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ELSE.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  WHEN 'DIS' OR 'DEL' OR 'REL'.
    LOOP AT SCREEN.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDLOOP.
  WHEN 'BLK'.
    LOOP AT SCREEN.
      IF g_tc120_wa-mstae = ''.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
        IF screen-name = 'G_TC120_WA-MARK'.
           screen-input = '1'.
           MODIFY SCREEN.
        ELSEIF screen-name = 'G_TC120_WA-MATDESC'.
          IF g_tc120_wa-mstae = 'NM'.
            screen-input = '0'.
            MODIFY SCREEN.
          ELSE.
            screen-input = '1'.
            MODIFY SCREEN.
          ENDIF.
        ELSEIF screen-name = 'G_TC120_WA-ERRCD'.
          IF g_tc120_wa-errcd = 'S'.
            screen-input = '0'.
            MODIFY SCREEN.
          ELSE.
            screen-input = '1'.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
      IF zmm_matblockhd_st-reqcl = 'C' OR
         zmm_matblockhd_st-reqcl = 'AC'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
ENDCASE.
ENDMODULE.                 " tct120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.
  PERFORM get_correspondense.
ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE splitter_ctrl_vorbereiten1 OUTPUT.
  IF gv_splitter1 IS INITIAL.
    CREATE OBJECT gv_custom_container
                  EXPORTING container_name = 'C_DIS'.

    CREATE OBJECT gv_splitter1
           EXPORTING
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.
  ENDIF.

  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

    IF gv_splitter2 IS INITIAL.

      CREATE OBJECT gv_custom_container
                    EXPORTING container_name = 'C_WRT'.


      CREATE OBJECT gv_splitter2
             EXPORTING
                    parent = gv_custom_container
                    orientation = 1
                    sash_position = 1.

    ENDIF.
  ENDIF.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_vorbereiten1 OUTPUT.
  IF gv_text_editor1 IS INITIAL.
    CREATE OBJECT gv_text_editor1
       EXPORTING
            parent = gv_splitter1->bottom_right_container
            wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
            wordwrap_to_linebreak_mode = cl_gui_textedit=>false
       EXCEPTIONS
            error_cntl_create      = 1
            error_cntl_init        = 2
            error_cntl_link        = 3
            error_dp_create        = 4
            gui_type_not_supported = 5.
  ENDIF.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

    IF gv_text_editor2 IS INITIAL.
      CREATE OBJECT gv_text_editor2
         EXPORTING
              parent = gv_splitter2->bottom_right_container
              wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
              wordwrap_to_linebreak_mode = cl_gui_textedit=>false
         EXCEPTIONS
              error_cntl_create      = 1
              error_cntl_init        = 2
              error_cntl_link        = 3
              error_dp_create        = 4
              gui_type_not_supported = 5.
    ENDIF.
  ENDIF.

  PERFORM text_control_eingabebereit1.
  PERFORM text_control_set_text_table1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_attr_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_attr_120 OUTPUT.
  IF g_mode <> 'BLK'.
*    LOOP AT SCREEN.
*      IF screen-name = 'T_SPCHK'.
*        screen-invisible = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'TCT120_INSERT' OR
         screen-name = 'TCT120_DELETE'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " change_attr_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_attr_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_attr_110 OUTPUT.
  IF g_mode <> 'BLK'.
*    LOOP AT SCREEN.
*      IF screen-name = 'T_SPCH'.
*        screen-invisible = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'TCT110_INSERT' OR
         screen-name = 'TCT110_DELETE'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " change_attr_110  OUTPUT

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tct130_change_tc_attr OUTPUT.
  LOOP AT tct130-cols INTO col130 WHERE index EQ 20.
      col130-invisible = '1'.
      MODIFY tct130-cols FROM col130 INDEX sy-tabix.
  ENDLOOP.
  DESCRIBE TABLE g_tc130_itab LINES tct130-lines.
ENDMODULE.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct130_get_lines OUTPUT.
  g_tct130_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  tct130_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct130_init OUTPUT.
 Data  : l_matgp130(2) type c.
  IF g_tct130_copied IS INITIAL.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_matblock_dt
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc130_itab
        WHERE reqno = zmm_matblockhd_st-reqno.
    ENDIF.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if g_mode = 'BLK'.
      select single * from zmm_blkcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        select single * from zmm_blkcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          if g_section = 'I'.
            delete g_tc130_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc130_itab where mstae = 'NM'.
          endif.
          loop at g_tc130_itab into g_tc130_wa.
            l_matgp130 = g_tc130_wa-matcode+0(2).
            select single * from zmm_blkcodifier
                 where codifier = sy-uname
                 and   matgp    = l_matgp130.
            if sy-subrc <> 0.
              delete g_TC130_itab index sy-tabix.
            endif.
            clear l_matgp130.
          endloop.
        endif.
      else.
        if g_section = 'I'.
            delete g_tc130_itab where mstae <> 'NM'.
          elseif g_section = 'C'.
            delete g_tc130_itab where mstae = 'NM'.
        endif.
      endif.
    endif.
****
    g_tct130_copied = 'X'.
    REFRESH CONTROL 'TCT130' FROM SCREEN '0130'.
  ENDIF.

ENDMODULE.                 " tct130_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_attr_130  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_attr_130 OUTPUT.
  IF g_mode <> 'BLK'.
*    LOOP AT SCREEN.
*      IF screen-name = 'T_SPCHC'.
*        screen-invisible = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'TCT130_INSERT' OR
         screen-name = 'TCT130_DELETE'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " change_attr_130  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct130_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct130_move OUTPUT.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tc130_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tc130_wa-srno = 0.
        PERFORM get_nextsrno_cap.
        MOVE l_srno TO g_tc130_wa-srno.
        MODIFY g_tc130_itab FROM g_tc130_wa
        INDEX tct130-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
  ENDIF.

***Plant Stock***********
  IF NOT g_tc130_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc130_wa-p_stock
      WHERE werks = zmm_matblockhd_st-werks
      AND   matnr = g_tc130_wa-matcode.
    MODIFY g_tc130_itab FROM g_tc130_wa
    INDEX tct130-current_line TRANSPORTING p_stock.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tc130_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tc130_wa-c_stock
    WHERE matnr = g_tc130_wa-matcode.

    MODIFY g_tc130_itab FROM g_tc130_wa
    INDEX tct130-current_line TRANSPORTING c_stock.
  ENDIF.


ENDMODULE.                 " tct130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tct130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tct130_change_field_attr OUTPUT.
  CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'G_TC130_WA-ERRCD'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_matblockhd_st-werks IS INITIAL AND
           NOT zmm_matblockhd_st-tel IS INITIAL.
          IF NOT g_tc130_wa-matcode IS INITIAL.
            IF g_tc130_wa-mstae <> 'NM'.
              IF screen-name    = 'G_TC130_WA-MATDESC'.
                screen-required = '1'.
                MODIFY SCREEN.
              ELSEIF screen-name    = 'G_TC130_WA-MATCOST'.
                IF g_tc130_wa-omatcost IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MAT_LIFE'.
                IF g_tc130_wa-omat_life IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MATLOC'.
                IF g_tc130_wa-omatloc IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MATGP'.
*                IF g_tc130_wa-omatgp IS INITIAL.
                  screen-input      = '0'.
                  MODIFY SCREEN.
*                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-MATCATG'.
                IF g_tc130_wa-omatcatg IS INITIAL.
                  screen-required     = '1'.
                  MODIFY SCREEN.
                ENDIF.
              ELSEIF screen-name    = 'G_TC130_WA-RES_NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ELSE.
              IF SCREEN-GROUP1 <> 'NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ELSE.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
            IF zmm_matblockhd_st-reqcl = 'IR'.
              IF g_tc130_wa-mstae = ''.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
              IF screen-name    = 'G_TC130_WA-MATCODE'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'DIS' OR 'DEL' OR 'REL'.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'BLK'.
      LOOP AT SCREEN.
        IF g_tc130_wa-mstae = ''.
          screen-input = '0'.
          MODIFY SCREEN.
        ELSE.
          IF screen-name = 'G_TC130_WA-MARK'.
             screen-input = '1'.
             MODIFY SCREEN.
          ELSEIF screen-name = 'G_TC130_WA-MATDESC'.
            IF g_tc130_wa-mstae = 'NM'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC130_WA-ERRCD'.
            IF g_tc130_wa-errcd = 'S'.
              screen-input = '0'.
              MODIFY SCREEN.
            ELSE.
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name    = 'G_TC130_WA-MATGP'.
            IF g_tc130_wa-omatgp IS INITIAL.
              IF g_tc130_wa-mstae = 'NM'.
                screen-input = '0'.
                MODIFY SCREEN.
              ELSE.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
          ELSEIF screen-name = 'G_TC130_WA-MATCODE'.
            IF NOT g_tc130_wa-matcode IS INITIAL.
              screen-input = '0'.
              MODIFY SCREEN.
            ENDIF.
          ELSEIF screen-name = 'G_TC130_WA-RES_NM' OR
                 screen-name = 'G_TC130_WA-MATCOST' OR
                 screen-name = 'G_TC130_WA-MAT_LIFE' OR
                 screen-name = 'G_TC130_WA-MATLOC' OR
                 screen-name = 'G_TC130_WA-MATCATG'.
            screen-input = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF zmm_matblockhd_st-reqcl = 'C' OR
           zmm_matblockhd_st-reqcl = 'AC'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " tct130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS 'STAT_REL'.
ENDMODULE.                 " STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_CERTIFICATE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE write_certificate OUTPUT.
  SUPPRESS DIALOG.
  SET PF-STATUS 'STAT_REL'.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*
  NEW-PAGE NO-TITLE.
  CASE g_mode .
    WHEN 'REL'.
WRITE : / '                   Acknowledgement                         '
                                                COLOR 3.
WRITE : / '-----------------------------------------------------------'.
     WRITE : / 'This is to certify that information provided by me is '.
      WRITE : / 'accurate. Kindly unblock the material codes.'.

  ENDCASE.

ENDMODULE.                 " WRITE_CERTIFICATE  OUTPUT

*--- INCLUDE: MZMMCODUNBLOCKTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMCODUNBLOCKTOP                                           *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMCODUNBLOCK .
*************************Tables*************************************
Tables : zmm_matblock_hd, zmm_matblock_dt,ZMM_MATBLOCKHD_ST,
         mara, t141, cabn,lfa1,zmm_mdl,ausp,stxh,zmm_cdcodifier,
         zmm_blkcodifier,ZMMCDCAP_LOC_V,ZMMCDCAP_USRGP_V.

*************************Types*****************************************

types: begin of ty_tc110,
         srno       like zmm_matblock_dt-srno,
         matcode    like zmm_matblock_dt-matcode,
         errcd      like zmm_matblock_dt-errcd,
         omatdesc   like zmm_matblock_dt-matdesc,
         matdesc    like zmm_matblock_dt-matdesc,
         ouom       like mara-meins,
         p_stock    like mard-labst,
         c_stock    like mard-labst,
         unblkby    like zmm_matblock_dt-unblkby,
         unblkdt    like zmm_matblock_dt-unblkdt,
         mstae      like zmm_matblock_dt-mstae,
         res_nm     like zmm_matblock_dt-res_nm,
         mark,
       end of ty_tc110.
types: begin of ty_tc120,
         srno       like zmm_matblock_dt-srno,
         matcode    like zmm_matblock_dt-matcode,
         errcd      like zmm_matblock_dt-errcd,
         omatdesc   like zmm_matblock_dt-matdesc,
         matdesc    like zmm_matblock_dt-matdesc,
         ouom       like mara-meins,
         p_stock    like mard-umlme,
         c_stock    like mard-umlme,
         opartno    like zmm_matblock_dt-npartno,
         npartno    like zmm_matblock_dt-npartno,
         ooem       like zmm_matblock_dt-noem,
         noem       like zmm_matblock_dt-noem,
         omdlno     like zmm_matblock_dt-nmdlno,
         nmdlno     like zmm_matblock_dt-nmdlno,
         ocapno     like zmm_matblock_dt-ncapno,
         ncapno     like zmm_matblock_dt-ncapno,
         res_nm     like zmm_matblock_dt-res_nm,
         unblkby    like zmm_matblock_dt-unblkby,
         unblkdt    like zmm_matblock_dt-unblkdt,
         mstae      like zmm_matblock_dt-mstae,
         mark,
       end of ty_tc120.
types: begin of ty_tc130,
         srno       like zmm_matblock_dt-srno,
         matcode    like zmm_matblock_dt-matcode,
         errcd      like zmm_matblock_dt-errcd,
         omatdesc   like zmm_matblock_dt-matdesc,
         matdesc    like zmm_matblock_dt-matdesc,
         ouom       like mara-meins,
         p_stock    like mard-umlme,
         c_stock    like mard-umlme,
         omatcatg    like zmm_matblock_dt-omatcatg,
         matcatg    like zmm_matblock_dt-matcatg,
         omatloc     like zmm_matblock_dt-omatloc,
         matloc     like zmm_matblock_dt-matloc,
         omatgp      like zmm_matblock_dt-omatgp,
         matgp      like zmm_matblock_dt-matgp,
         omatcost    like zmm_matblock_dt-omatcost,
         matcost    like zmm_matblock_dt-matcost,
         omat_life   like zmm_matblock_dt-omat_life,
         mat_life   like zmm_matblock_dt-mat_life,
         res_nm     like zmm_matblock_dt-res_nm,
         unblkby    like zmm_matblock_dt-unblkby,
         unblkdt    like zmm_matblock_dt-unblkdt,
         mstae      like zmm_matblock_dt-mstae,
         mark,
       end of ty_tc130.


Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

***********Work Area***************************************************
Data : g_tc110_wa type ty_tc110,
       g_tc120_wa type ty_tc120,
       g_tc130_wa type ty_tc130.

***********Internal Tables*********************************************
Data: g_tc110_itab like table of g_tc110_wa with header line,
      g_tc120_itab like table of g_tc120_wa with header line,
      g_tc130_itab like table of g_tc130_wa with header line.
Data: g_itab_del110  type ty_tc110 OCCURS 0,
      g_itab_del120  type ty_tc120 OCCURS 0,
      g_itab_del130  type ty_tc130 OCCURS 0.

Data: it_tab1 type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.


*&spwizard: declaration of tablecontrol 'TCT110' itself
controls: TCT110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TCT110'
data:     g_TCT110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
************************************************************************
Data: g_mode(3)  type c,
      okcode_100 like sy-ucomm.
DATA  dynnr like sy-dynnr.
DATA  g_CURFIELD(40).

*&spwizard: declaration of tablecontrol 'TCT120' itself
controls: TCT120 type tableview using screen 0120.

*&spwizard: lines of tablecontrol 'TCT120'
data:     g_TCT120_lines  like sy-loopc.

*&spwizard: declaration of tablecontrol 'TCT130' itself
controls: TCT130 type tableview using screen 0130.

*&spwizard: lines of tablecontrol 'TCT130'
data:     g_TCT130_lines  like sy-loopc.
*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*
DATA: GV_SPLITTER TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER, "#EC NEEDED
      GV_SPLITTER1 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
      GV_SPLITTER2 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER.

DATA: GV_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

DATA: GV_TEXT_EDITOR TYPE REF TO CL_GUI_TEXTEDIT, "#EC NEEDED
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

DATA : L_THEAD LIKE LS_THEAD OCCURS 0 WITH HEADER LINE.

DATA  G_TDNAME(12).

DATA: BEGIN OF LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES.

Data: g2_lines like tline.

DATA: BEGIN OF LINES_CORS OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES_CORS.

DATA: BEGIN OF g_LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF g_LINES.
DATA:    col110 LIKE LINE OF TCT110-cols,
         col120 LIKE LINE OF TCT120-cols,
         col130 LIKE LINE OF TCT130-cols.

**********Data Declaration -General..***********************************
DATA: ist_textid like thead,
      wa_textid  like thead,
      ist_textid_items like thead occurs 0.

Data : g_item like zmm_matblock_dt,
       wa_matblock_dt like zmm_matblock_dt,
       itab_matblock_dt like table of zmm_matblock_dt with header line.
Data : g_hd_copied type c,
       g_tct110_copied type c,
       g_tct120_copied type c,
       g_tct130_copied type c.
data:  g_relflag type c,
       G_REQNO(10) type c,
       g_request_no(10) type c,
       g_cors,
       g_line132(132) type c.
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
      End of g_linefrto.
Data: g_linefrto_itab like table of g_linefrto.
Data : g_capcode_no   like ausp-atinn.
Data : g_modelcode_no like ausp-atinn.
Data : g_errflag type c,
       g_cursor_line like sy-stepl,
       g_curr_line like sy-stepl.
Data : g_cfld(40) type c.
Data : g_cores_sender like tline-tdline,
       g_iputdata like tline-tdline,
       g_oputdata like tline-tdline,
       g_iputstring like tline-tdline.
data:  g_choice,g_ans,
       g_selline like sy-stepl.
Data : g_desclen type i,
       g_wrkst(48) type c,
       g_wrkst39(40) type c.
data:  g_rel type c,
       g_clrndesc type c,
       g_lock type c,
       g_section type c.
data  g_normt(3) type c.
data  g_fname(30) type c.
Data  g_atinn130 LIKE cabn-atinn.

*--- INCLUDE: %_CABAP ---*
type-pool ABAP .


************************************************************************
* WARNING!!!!! DO NOT CHANGE ANY OF THE FOLLOWING TYPES! WARNING !!!!! *
* !!!!!!!! All types have to synchronized with ABAP kernel types !!!!! *
************************************************************************

************************************************************************
* NAMES WITH PREFIX "ABAP_" DECLARED IN THE DDIC
* MUST NOT BE REDEFINED HERE!
************************************************************************
* abap_encod
* abap_endia
* abap_repl

************************************************************************
**** GENERAL ***********************************************************
types:
  ABAP_BOOL type C length 1.
* constants for abap_bool
constants:
  ABAP_TRUE      type ABAP_BOOL value 'X',
  ABAP_FALSE     type ABAP_BOOL value ' ',
  ABAP_UNDEFINED type ABAP_BOOL value '-',
  ABAP_ON        type ABAP_BOOL value 'X',
  ABAP_OFF       type ABAP_BOOL value ' '.


************************************************************************
**** DESCRIBE   ********************************************************
constants:
  ABAP_MAX_ABS_TYPE_NAME_LN   type I value        200,
  ABAP_MAX_CLASS_NAME_LN      type I value         30,
  ABAP_MAX_INTF_NAME_LN       type I value         30,
  ABAP_MAX_COMP_NAME_LN       type I value         30,
  ABAP_MAX_KEY_NAME_LN        type I value        255,
  ABAP_MAX_CLASS_COMP_NAME_LN type I value         61,
  ABAP_MAX_EDIT_MASK_LN       type I value          7,
  ABAP_MAX_HELP_ID_LN         type I value         62,
  ABAP_MAX_DB_STRING_LN       type I value  536870912,
  ABAP_MAX_DB_RAWSTRING_LN    type I value 1073741824.



types:
* type kinds
  ABAP_TYPEKIND     type C length 1, " check CL_ABAP_TYPEDESCR for values
  ABAP_TYPECATEGORY type C length 1, " check CL_ABAP_TYPEDESCR for values
  ABAP_TYPEPROPKIND type C length 1,
  ABAP_STRUCTKIND   type C length 1,
  ABAP_TABLEKIND    type C length 1,
  ABAP_KEYDEFKIND   type C length 1,
  ABAP_CLASSKIND    type C length 1,
  ABAP_INTFKIND     type C length 1,
  ABAP_PARMKIND     type C length 1,
* misc
  ABAP_EDITMASK     type C length ABAP_MAX_EDIT_MASK_LN,
  ABAP_HELPID       type C length ABAP_MAX_HELP_ID_LN,
  ABAP_VISIBILITY   type C length 1,
* name types
  ABAP_TYPENAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_ABSTYPENAME  type C length ABAP_MAX_ABS_TYPE_NAME_LN,
  ABAP_COMPNAME     type C length ABAP_MAX_COMP_NAME_LN,
  ABAP_KEYNAME      type C length ABAP_MAX_KEY_NAME_LN,
  ABAP_KEYCOMPNAME  type          ABAP_KEYNAME,
  ABAP_CLASSNAME    type C length ABAP_MAX_CLASS_NAME_LN,
  ABAP_INTFNAME     type C length ABAP_MAX_INTF_NAME_LN,
  ABAP_ATTRNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_METHNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_EVNTNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_PARMNAME     type C length ABAP_MAX_COMP_NAME_LN,
  ABAP_EXCPNAME     type C length ABAP_MAX_COMP_NAME_LN,
* structure component description
  begin of ABAP_COMPDESCR,
    LENGTH    type I,
    DECIMALS  type I,
    TYPE_KIND type ABAP_TYPEKIND,
    NAME      type ABAP_COMPNAME,
  end of ABAP_COMPDESCR,
  ABAP_COMPDESCR_TAB type standard table of ABAP_COMPDESCR
                     with key NAME,
  begin of ABAP_COMPONENTDESCR,
    NAME       type STRING,
    TYPE       type ref to CL_ABAP_DATADESCR,
    AS_INCLUDE type ABAP_BOOL,
    SUFFIX     type STRING,
  end of ABAP_COMPONENTDESCR,
  ABAP_COMPONENT_TAB type standard table of ABAP_COMPONENTDESCR
                     with key NAME,
  begin of ABAP_SIMPLE_COMPONENTDESCR,
    NAME type STRING,
    TYPE type ref to CL_ABAP_DATADESCR,
  end of ABAP_SIMPLE_COMPONENTDESCR,
  ABAP_COMPONENT_SYMBOL_TAB type hashed table of ABAP_SIMPLE_COMPONENTDESCR
                            with unique key NAME,
  ABAP_COMPONENT_VIEW_TAB   type standard table of ABAP_SIMPLE_COMPONENTDESCR
                          with key NAME,
* key description of tables
  begin of ABAP_KEYDESCR,
    NAME type ABAP_KEYNAME,
  end of ABAP_KEYDESCR,
  ABAP_KEYDESCR_TAB type standard table of ABAP_KEYDESCR
                    with key NAME,
* description of all secondary keys and primary key of tables
  begin of ABAP_TABLE_KEYCOMPDESCR,
    NAME type ABAP_KEYCOMPNAME,
  end of ABAP_TABLE_KEYCOMPDESCR,
  begin of ABAP_TABLE_KEYDESCR,
    COMPONENTS  type standard table of ABAP_TABLE_KEYCOMPDESCR
                         with non-unique default key
                         initial size 4,
    NAME        type ABAP_COMPNAME,
    IS_PRIMARY  type ABAP_BOOL,
    ACCESS_KIND type ABAP_TABLEKIND,
    IS_UNIQUE   type ABAP_BOOL,
    KEY_KIND    type ABAP_KEYDEFKIND,
  end of ABAP_TABLE_KEYDESCR,
  ABAP_TABLE_KEYDESCR_TAB type standard table of ABAP_TABLE_KEYDESCR
                          with non-unique key NAME
                          initial size 2,
* map for mapping table key names to table key aliases
  begin of ABAP_KEY_ALIAS_PAIR,
    NAME  type ABAP_COMPNAME,
    ALIAS type ABAP_COMPNAME,
  end of ABAP_KEY_ALIAS_PAIR,
  ABAP_KEY_ALIAS_MAP type sorted table of ABAP_KEY_ALIAS_PAIR
                          with non-unique key NAME
                          with unique sorted key KEY_ALIAS components ALIAS
                          initial size 2,
* parameter description (methods and event)
  begin of ABAP_PARMDESCR,
    LENGTH      type I,
    DECIMALS    type I,
    TYPE_KIND   type ABAP_TYPEKIND,
    NAME        type ABAP_PARMNAME,
    PARM_KIND   type ABAP_PARMKIND,
    BY_VALUE    type ABAP_BOOL,
    IS_OPTIONAL type ABAP_BOOL,
  end of ABAP_PARMDESCR,
  ABAP_PARMDESCR_TAB type standard table of ABAP_PARMDESCR
                     with key NAME,
* exception description (method and event)
  begin of ABAP_EXCPDESCR,
    NAME         type ABAP_EXCPNAME,
    IS_RESUMABLE type ABAP_BOOL, "abap_false for old exceptions,
    "abap_true or abap_false for class based exceptions
  end of ABAP_EXCPDESCR,
  ABAP_EXCPDESCR_TAB type standard table of ABAP_EXCPDESCR
                     with key NAME,
* exposed and access friend description
  begin of ABAP_FRNDDESCR,
    NAME type ABAP_CLASSNAME,
  end of ABAP_FRNDDESCR,
  ABAP_FRNDDESCR_TAB type standard table of ABAP_FRNDDESCR
                     with key NAME,
* included interfaces / interface implementation description
  begin of ABAP_INTFDESCR,
    NAME         type ABAP_INTFNAME,
    IS_INHERITED type ABAP_BOOL,
  end of ABAP_INTFDESCR,
  ABAP_INTFDESCR_TAB type standard table of ABAP_INTFDESCR
                     with key NAME,
* type definition inside class / interface
  begin of ABAP_TYPEDEF,
    NAME         type ABAP_TYPENAME,
    ALIAS_FOR    type ABAP_TYPENAME,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
  end of ABAP_TYPEDEF,
  ABAP_TYPEDEF_TAB type standard table of ABAP_TYPEDEF
                     with key NAME,
* attribute description
  begin of ABAP_ATTRDESCR,
    LENGTH       type I,
    DECIMALS     type I,
    NAME         type ABAP_ATTRNAME,
    TYPE_KIND    type ABAP_TYPEKIND,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
    IS_CLASS     type ABAP_BOOL,
    IS_CONSTANT  type ABAP_BOOL,
    IS_VIRTUAL   type ABAP_BOOL,
    IS_READ_ONLY type ABAP_BOOL,
    ALIAS_FOR    type ABAP_ATTRNAME,
  end of ABAP_ATTRDESCR,
  ABAP_ATTRDESCR_TAB type standard table of ABAP_ATTRDESCR
                     with key NAME,
* method description
  begin of ABAP_METHDESCR,
    PARAMETERS       type ABAP_PARMDESCR_TAB,
    EXCEPTIONS       type ABAP_EXCPDESCR_TAB,
    NAME             type ABAP_METHNAME,
    FOR_EVENT        type ABAP_EVNTNAME,
    OF_CLASS         type ABAP_CLASSNAME,
    VISIBILITY       type ABAP_VISIBILITY,
    IS_INTERFACE     type ABAP_BOOL,
    IS_INHERITED     type ABAP_BOOL,
    IS_REDEFINED     type ABAP_BOOL,
    IS_ABSTRACT      type ABAP_BOOL,
    IS_FINAL         type ABAP_BOOL,
    IS_CLASS         type ABAP_BOOL,
    ALIAS_FOR        type ABAP_METHNAME,
    IS_RAISING_EXCPS type ABAP_BOOL, "abap_true if method declaration has a raising clause
    "abap_false otherwise
  end of ABAP_METHDESCR,
  ABAP_METHDESCR_TAB type standard table of ABAP_METHDESCR
                     with key NAME,
* event description
  begin of ABAP_EVNTDESCR,
    PARAMETERS   type ABAP_PARMDESCR_TAB,
    NAME         type ABAP_EVNTNAME,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
    IS_CLASS     type ABAP_BOOL,
    ALIAS_FOR    type ABAP_EVNTNAME,
  end of ABAP_EVNTDESCR,
  ABAP_EVNTDESCR_TAB type standard table of ABAP_EVNTDESCR
                     with key NAME,

* table for get_friend_types
  ABAP_FRNDTYPES_TAB type standard table of ref to CL_ABAP_TYPEDESCR
                     with key TABLE_LINE.


************************************************************************
************* DYNAMIC CALL FUNCTION ************************************
types:
* CALL FUNCTION ... PARAMETER-TABLE
  begin of ABAP_FUNC_PARMBIND,
    VALUE     type ref to DATA,
    TABLES_WA type ref to DATA,
    KIND      type I,
    NAME      type ABAP_PARMNAME,
  end of ABAP_FUNC_PARMBIND,
  ABAP_FUNC_PARMBIND_TAB type sorted table of ABAP_FUNC_PARMBIND
                         with unique key KIND NAME,
* CALL FUNCTION ... EXCEPTION-TABLE
  begin of ABAP_FUNC_EXCPBIND,
    MESSAGE type ref to DATA,
    VALUE   type I,
    NAME    type ABAP_EXCPNAME,
  end of ABAP_FUNC_EXCPBIND,
  ABAP_FUNC_EXCPBIND_TAB type hashed table of ABAP_FUNC_EXCPBIND
                         with unique key NAME.

constants:
  ABAP_FUNC_EXPORTING type ABAP_FUNC_PARMBIND-KIND value 10,
  ABAP_FUNC_IMPORTING type ABAP_FUNC_PARMBIND-KIND value 20,
  ABAP_FUNC_TABLES    type ABAP_FUNC_PARMBIND-KIND value 30,
  ABAP_FUNC_CHANGING  type ABAP_FUNC_PARMBIND-KIND value 40.

************************************************************************
************* DYNAMIC INVOKE *******************************************
types:
* PARAMETER-TABLE
  begin of ABAP_PARMBIND,
    NAME  type ABAP_PARMNAME,
    KIND  type ABAP_PARMKIND,
    VALUE type ref to DATA,
  end of ABAP_PARMBIND,
  ABAP_PARMBIND_TAB type hashed table of ABAP_PARMBIND
                    with unique key NAME,
* EXCEPTION-TABLE
  begin of ABAP_EXCPBIND,
    NAME  type ABAP_EXCPNAME,
    VALUE type I,
  end of ABAP_EXCPBIND,
  ABAP_EXCPBIND_TAB type hashed table of ABAP_EXCPBIND
                    with unique key NAME.


************************************************************************
**** Types for CL_ABAP_CHAR_UTILITIES **********************************
types:
  ABAP_CHAR1(1)           type C,
  ABAP_CR_LF(2)           type C,
  ABAP_BYTE_ORDER_MARK(2) type X,
  ABAP_BYTE_ORDER_UTF8(3) type X.


************************************************************************
**** CONVERSION ********************************************************
types:
  ABAP_ENCODING type ABAP_ENCOD,
  ABAP_ENDIAN   type ABAP_ENDIA.

************************************************************************
**** CALL TRANSFORMATION ***********************************************

* PARAMETER TABLE
types:
  ABAP_TRANS_PARMNAME  type STRING,
  ABAP_TRANS_PARMVALUE type STRING,
  ABAP_TRANS_PARMREF   type ref to DATA.

types:
  begin of ABAP_TRANS_PARMBIND,
    NAME  type ABAP_TRANS_PARMNAME,
    VALUE type ABAP_TRANS_PARMVALUE,
  end of ABAP_TRANS_PARMBIND,
  begin of ABAP_TRANS_PARM_OBJ_BIND,
    NAME  type ABAP_TRANS_PARMNAME,
    VALUE type ABAP_TRANS_PARMREF,
  end of ABAP_TRANS_PARM_OBJ_BIND.

types:
  ABAP_TRANS_PARMBIND_TAB
      type standard table of ABAP_TRANS_PARMBIND with key NAME,
  ABAP_TRANS_PARM_OBJ_BIND_TAB
      type sorted table of ABAP_TRANS_PARM_OBJ_BIND with unique key NAME.

* OBJECT TABLE
types:
  ABAP_TRANS_OBJNAME type STRING.

types:
  begin of ABAP_TRANS_OBJBIND,
    NAME  type ABAP_TRANS_OBJNAME,
    VALUE type ref to OBJECT,
  end of ABAP_TRANS_OBJBIND.

types:
  ABAP_TRANS_OBJBIND_TAB
      type standard table of ABAP_TRANS_OBJBIND with key NAME.

* SOURCE TABLE
types:
  ABAP_TRANS_SRCNAME type STRING.

types:
  begin of ABAP_TRANS_SRCBIND,
    NAME  type ABAP_TRANS_SRCNAME,
    VALUE type ref to DATA,
  end of ABAP_TRANS_SRCBIND.

types:
  ABAP_TRANS_SRCBIND_TAB
       type standard table of ABAP_TRANS_SRCBIND with key NAME,
  ABAP_TRANS_SRCBIND_TAB_SORTED
       type sorted table of ABAP_TRANS_SRCBIND with unique key NAME.

* RESULT TABLE
types:
  ABAP_TRANS_RESNAME type STRING.

types:
  begin of ABAP_TRANS_RESBIND,
    NAME  type ABAP_TRANS_RESNAME,
    VALUE type ref to DATA,
  end of ABAP_TRANS_RESBIND.

types:
  ABAP_TRANS_RESBIND_TAB
       type standard table of ABAP_TRANS_RESBIND with key NAME,
  ABAP_TRANS_RESBIND_TAB_SORTED
       type sorted table of ABAP_TRANS_RESBIND with unique key NAME.

*--- INCLUDE: CL_ABAP_DATADESCR=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_DATADESCR and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_ABAP_TYPEDESCR=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_TYPEDESCR and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_BUPA_DIALOG_JOEL===========CU ---*
class CL_BUPA_DIALOG_JOEL definition
  public
  abstract
  create public .

public section.

  class-data GV_DATA_CHANGED type BU_BOOLEAN read-only .
  class-data GV_PARTNER_HANDLE type BU_PARTNER read-only .
  class-data GT_CARRY_ON_MESSAGES type BU_DIALOG_MESSAGE_T .
  class-data GV_XOK_CODE type BUS_SCREEN-FUNCTION_CODE read-only .
  class-data GV_EXT_CALL_TYPE type BU_CALL_TYPE .
  class-data GT_PARTNER_ROLES type BUS_ROLES_T .

  class-methods START_FROM_TRANSACTION .
  class-methods START_WITH_NAVIGATION
    importing
      value(IV_REQUEST) type ref to CL_BUPA_NAVIGATION_REQUEST optional
      value(IV_OPTIONS) type ref to CL_BUPA_DIALOG_JOEL_OPTIONS optional
      !IV_IN_NEW_INTERNAL_MODE type BU_BOOLEAN optional
      !IV_IN_NEW_WINDOW type BU_BOOLEAN optional
    exceptions
      ALREADY_STARTED
      NOT_ALLOWED .

*--- INCLUDE: CL_BUPA_DIALOG_JOEL_OPTIONS===CU ---*
class CL_BUPA_DIALOG_JOEL_OPTIONS definition
  public
  final
  create public .

*"* public components of class CL_BUPA_DIALOG_JOEL_OPTIONS
*"* do not include other source files here!!!
public section.

  constants GC_X type BU_BOOLEAN value 'X'. "#EC NOTEXT
  data GS_OPTIONS type BUS_OPTIONS .
  data GS_OPTIONSX type BUS_OPTIONSX .

  methods EXPORT .
  class-methods IMPORT
    exporting
      !EV_INSTANCE type ref to CL_BUPA_DIALOG_JOEL_OPTIONS
    exceptions
      NO_INSTANCE_IN_MEMORY .
  methods SET_LOCATOR_ACTIVE_TAB
    importing
      !IV_VALUE type BUS_NAVIGATION-MAINTENANCE_ID .
  methods SET_LOCATOR_VISIBLE
    importing
      !IV_VALUE type BUS_NAVIGATION-MAINTENANCE_ID .
  methods SET_SAVE_MODE
    importing
      !IV_VALUE type BUS_OPTIONS-SAVE_MODE .
  methods SET_SAVE_ENABLED
    importing
      !IV_VALUE type BUS_OPTIONS-SAVE_MODE .
  methods SET_EXIT_TEXT
    importing
      !IV_VALUE type C .
  methods SET_NAVIGATION_DISABLED
    importing
      !IV_VALUE type BUS_OPTIONS-DISABLE_NAVIGATION .
  methods SET_ROLE_SWITCHING_DISABLED
    importing
      !IV_VALUE type BUS_OPTIONS-DISABLE_NAVIGATION .
  methods SET_ACTIVITY_SWITCHING_OFF
    importing
      !IV_VALUE type BUS_OPTIONS-DISABLE_NAVIGATION .
  methods SET_GROUP_SELECTION_ENABLED
    importing
      !IV_VALUE type BU_BOOLEAN .
  methods SET_DIALOG_MODE
    importing
      !IV_VALUE type BUS_OPTIONS-DIALOG_MODE .
  methods SET_EXTERNAL_CALL
    importing
      !IV_VALUE type BUS_OPTIONS-EXTERNAL_CALL .
  methods SET_CREATE_SAME_ROLE
    importing
      !IV_VALUE type BUS_OPTIONS-CREATE_SAME_ROLE .
  methods SET_BUPR_CREATE_NOT_ALLOWED
    importing
      !IV_VALUE type BUS_OPTIONS-BUPR_CREATE_NOT_ALLOWED .
  methods SET_NAVIGATE_ON_FIRST_TAB
    importing
      !IV_VALUE type BUS_OPTIONS-NAVIGATE_ON_FIRST_TAB .
  methods SET_SUB_HEADER_DISABLED
    importing
      !IV_VALUE type BUS_OPTIONS-DISABLE_SUBHEADER .
  methods SET_SAVE_TO_LEAVE
    importing
      !IV_VALUE type BUS_OPTIONS-SAVE_TO_LEAVE .
  methods SET_BUPR_MAINTENANCE
    importing
      !IV_VALUE type BUS_OPTIONS-BUPR_MAINTENANCE .
  methods SET_EXTERNAL_CALL_TYPE
    importing
      !IV_VALUE type BUS_OPTIONS-EXTERNAL_CALL_TYPE .

*--- INCLUDE: CL_BUPA_DIALOG_MESSAGE========CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_BUPA_DIALOG_MESSAGE and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_BUPA_NAVIGATION_REQUEST====CU ---*
class CL_BUPA_NAVIGATION_REQUEST definition
  public
  final
  create public .

*"* public components of class CL_BUPA_NAVIGATION_REQUEST
*"* do not include other source files here!!!
public section.

  constants GC_ACTIVITY_DISPLAY type BUS_DIALOG-ACTIVITY value '03'. "#EC NOTEXT
  constants GC_ACTIVITY_NONE type BUS_DIALOG-ACTIVITY value SPACE. "#EC NOTEXT
  constants GC_MAINTENANCE_ID_NOTHING type BUS_NAVIGATION-MAINTENANCE_ID value 'A'. "#EC NOTEXT
  constants GC_MAINTENANCE_ID_PARTNER type BUS_NAVIGATION-MAINTENANCE_ID value 'B'. "#EC NOTEXT
  constants GC_MAINTENANCE_ID_RELSHIPS type BUS_NAVIGATION-MAINTENANCE_ID value 'C'. "#EC NOTEXT
  constants GC_X type BU_BOOLEAN value 'X'. "#EC NOTEXT
  constants GC_ACTIVITY_CREATE type BUS_DIALOG-ACTIVITY value '01'. "#EC NOTEXT
  data GS_NAVIGATION type BUS_NAVIGATION .
  data GS_NAVIGATIONX type BUS_NAVIGATIONX .
  data GV_TITLE type BUS_SCREEN-TITLE .
  constants GC_ACTIVITY_CHANGE type BUS_DIALOG-ACTIVITY value '02'. "#EC NOTEXT
  constants GC_PARTNER_TYPE_PERSON type BUS_NAVIGATION-BUPA-CREATION_TYPE value '1'. "#EC NOTEXT
  constants GC_PARTNER_TYPE_ORGANIZATION type BUS_NAVIGATION-BUPA-CREATION_TYPE value '2'. "#EC NOTEXT
  constants GC_PARTNER_TYPE_GROUP type BUS_NAVIGATION-BUPA-CREATION_TYPE value '3'. "#EC NOTEXT
  constants GC_OVERVIEW_ID_ALV type BUS_NAVIGATION-BUPR-OVERVIEW_ID value 'A'. "#EC NOTEXT
  constants GC_OVERVIEW_ID_MAP type BUS_NAVIGATION-BUPR-OVERVIEW_ID value 'B'. "#EC NOTEXT
  constants GC_OVERVIEW_ID_NET type BUS_NAVIGATION-BUPR-OVERVIEW_ID value 'C'. "#EC NOTEXT
  constants GC_PARTNER_ROLE_GENERAL type BUS_NAVIGATION-BUPA-PARTNER_ROLE value '000000'. "#EC NOTEXT

  methods SET_BUPA_SUB_HEADER_TAB
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-SUB_HEADER_TAB .
  methods SET_BUPR_ACTIVE_TAB
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPR-ACTIVE_TAB .
  methods SET_BUPR_SELECT_RELATION
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPR-SELECT_RELATION .
  methods SET_BUPR_DIRECTED_TYPE
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPR-DIRECTED_TYPE .
  methods SET_BUPR_OVERVIEW_ID
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPR-OVERVIEW_ID .
  methods SET_MAINTENANCE_ID
    importing
      !IV_VALUE type BUS_NAVIGATION-MAINTENANCE_ID .
  methods SET_NAVIGATION
    importing
      !IS_NAVIGATION type BUS_NAVIGATION
      !IS_NAVIGATIONX type BUS_NAVIGATIONX .
  methods SET_PARTNER_NUMBER
    importing
      !IV_VALUE type BUS_PARTNER-NUMBER
    exporting
      !EV_RETURN type SY-SUBRC .
  methods SET_PARTNER_GUID
    importing
      !IV_VALUE type BUS_NAVIGATION-PARTNER_GUID .
  methods CONSTRUCTOR
    importing
      !IV_TITLE type C optional .
  methods SET_BUPA_ACTIVITY
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-ACTIVITY .
  methods SET_BUPA_CREATION_GROUP
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-CREATION_GROUP .
  methods SET_BUPA_PARTNER_ROLE_GROUP
    importing
      !IV_VALUE type BU_ROLE .
  methods SET_BUPA_PARTNER_ROLE
    importing
      !IV_VALUE type BUS_ROLES .
  methods SET_BUPA_PARTNER_ROLES
    importing
      !IT_VALUES type BUS_ROLES_T .
  methods SET_BUPA_PARTNER_CHNGBLE_ROLES
    importing
      !IT_VALUES type BUP_PARTNERROLES_T .
  methods SET_BUPA_PARTNER_ROLE_IF_EXIST
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-PARTNER_ROLE_IF_EXISTS .
  methods SET_BUPA_PARTNER_ROLE_VALIDITY
    importing
      !IV_VALUE type BUSROLEVALIDITY .
  methods SET_BUPA_SUB_HEADER_ID
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-SUB_HEADER_ID .
  methods EXPORT .
  class-methods IMPORT
    exporting
      !EV_INSTANCE type ref to CL_BUPA_NAVIGATION_REQUEST
    exceptions
      NO_INSTANCE_IN_MEMORY .
  methods SET_BUPA_CREATION_TYPE
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-CREATION_TYPE .
  methods SET_BUPA_CREATION_NUMBER
    importing
      !IV_VALUE type BUS_NAVIGATION-BUPA-CREATION_NUMBER .
  methods SET_BUPA_FIELD_VALUES
    importing
      !IT_VALUES type BUS_NAVIGATION-BUPA-FIELD_VALUES .
  methods SET_BUPA_TRANSACTION_TIME
    importing
      !IV_IS_PAST type BUS_TRANSACTION_TIME-IS_PAST default SPACE
      !IV_IS_PRESENT type BUS_TRANSACTION_TIME-IS_PRESENT default SPACE
      !IV_IS_FUTURE type BUS_TRANSACTION_TIME-IS_FUTURE default SPACE
      !IV_TIMESTAMP type BUS_TRANSACTION_TIME-TIMESTAMP optional
    exceptions
      PARAMETERS_NOT_VALID .
  methods SET_BUPA_PARTNER_TS
    importing
      !IV_VALID_DATES type BUS_TIMEDEPENDENCY optional .
  methods SET_BUPA_DEFAULT_DATE
    importing
      !IV_DEFAULT_DATE type BU_BP_DEFAULT_DATE .
