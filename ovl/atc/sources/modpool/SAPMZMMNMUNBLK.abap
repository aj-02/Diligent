*--- MAIN PROGRAM: SAPMZMMNMUNBLK ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMNMUNBLK                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 29/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Changes in INCLUDE MZMMNMUNBLKF01 .
*
************************************************************************


INCLUDE MZMMNMUNBLKTOP   .                                      "

* Includes inserted by Screen Painter Wizard. DO NOT CHANGE THIS LINE!
INCLUDE MZMMNMUNBLKO01 .
INCLUDE MZMMNMUNBLKI01 .
INCLUDE MZMMNMUNBLKF01 .

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

*--- INCLUDE: %_CSFES ---*
TYPE-POOL SFES .

*--table structure definition for mapping xml content after parsing

  TYPES SFES_OBJ_TYPE(32) TYPE C.
  TYPES:
    begin of sfes_features_record_type,
      component(30) type c,
      featurename(30) type c,
      value(30) type c,
  end of sfes_features_record_type.
  TYPES sfes_features_tab_type type table of sfes_features_record_type with non-unique key component.


CONSTANTS:
  SFES_OBJ_ACTIVEX
    TYPE SFES_OBJ_TYPE
    VALUE 'ACTX',
  SFES_OBJ_JAVABEANS
    TYPE SFES_OBJ_TYPE
    VALUE 'JBEAN',
  SFES_OBJ_OLE
    TYPE SFES_OBJ_TYPE
    VALUE 'OLE',
  SFES_OBJ_SAP
    TYPE SFES_OBJ_TYPE
    VALUE 'SAP',
  SFES_OBJ_HTML
    TYPE SFES_OBJ_TYPE
    VALUE 'HTML'.

* Constants for GUI_GET_DESKTOP_INFO
CONSTANTS:
  SFES_INFO_SAPDIR
    TYPE I
    VALUE -1,
  SFES_INFO_SAPSYSDIR
    TYPE I
    VALUE -2,
  SFES_INFO_COMPUTER_NAME
    TYPE I
    VALUE 1,
  SFES_INFO_WINDOWS_DIRECTORY
    TYPE I
    VALUE 2,
  SFES_INFO_SYSTEM_DIRECTORY
    TYPE I
    VALUE 3,
  SFES_INFO_TEMP_DIRECTORY
    TYPE I
    VALUE 4,
  SFES_INFO_USER_NAME
    TYPE I
    VALUE 5,
  SFES_INFO_WINDOWS_PLATFORM
    TYPE I
    VALUE 6,
  SFES_INFO_WINDOWS_BUILDNO
    TYPE I
    VALUE 7,
  SFES_INFO_WINDOWS_VERSION
    TYPE I
    VALUE 8,
  SFES_INFO_PROGRAM_NAME
    TYPE I
    VALUE 9,
  SFES_INFO_PROGRAM_PATH
    TYPE I
    VALUE 10,
  SFES_INFO_CURRENT_DIRECTORY
    TYPE I
    VALUE 11,
  SFES_INFO_DESKTOP_DIRECTORY
    TYPE I
    VALUE 12.

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

*--- INCLUDE: CL_GUI_FRONTEND_SERVICES======CU ---*
class CL_GUI_FRONTEND_SERVICES definition
  public
  inheriting from CL_GUI_OBJECT
  final
  create public .

public section.

  constants HKEY_CLASSES_ROOT type I value 0 ##NO_TEXT.
  constants HKEY_CURRENT_USER type I value 1 ##NO_TEXT.
  constants HKEY_LOCAL_MACHINE type I value 2 ##NO_TEXT.
  constants HKEY_USERS type I value 3 ##NO_TEXT.
  constants PLATFORM_UNKNOWN type I value -1 ##NO_TEXT.
  constants PLATFORM_WINDOWS95 type I value 1 ##NO_TEXT.
  constants PLATFORM_WINDOWS98 type I value 2 ##NO_TEXT.
  constants PLATFORM_NT351 type I value 3 ##NO_TEXT.
  constants PLATFORM_NT40 type I value 4 ##NO_TEXT.
  constants PLATFORM_NT50 type I value 5 ##NO_TEXT.
  constants PLATFORM_MAC type I value 6 ##NO_TEXT.
  constants PLATFORM_OS2 type I value 7 ##NO_TEXT.
  constants PLATFORM_LINUX type I value 8 ##NO_TEXT.
  constants PLATFORM_HPUX type I value 9 ##NO_TEXT.
  constants PLATFORM_TRU64 type I value 10 ##NO_TEXT.
  constants PLATFORM_AIX type I value 11 ##NO_TEXT.
  constants PLATFORM_SOLARIS type I value 12 ##NO_TEXT.
  constants PLATFORM_MACOSX type I value 13 ##NO_TEXT.
  constants ACTION_OK type I value 0 ##NO_TEXT.
  constants ACTION_CANCEL type I value 9 ##NO_TEXT.
  class-data FILETYPE_ALL type STRING read-only .
  class-data FILETYPE_TEXT type STRING read-only .
  class-data FILETYPE_XML type STRING read-only .
  class-data FILETYPE_HTML type STRING read-only .
  class-data FILETYPE_EXCEL type STRING read-only .
  class-data FILETYPE_RTF type STRING read-only .
  class-data FILETYPE_WORD type STRING read-only .
  class-data FILETYPE_POWERPOINT type STRING read-only .
  constants PLATFORM_WINDOWSXP type I value 14 ##NO_TEXT.
  constants ACTION_APPEND type I value 1 ##NO_TEXT.
  constants ACTION_REPLACE type I value 2 ##NO_TEXT.
  class-data GUIDELINE_CLASSIC type I value 1 ##NO_TEXT.
  class-data GUIDELINE_FIORI_2 type I value 2 ##NO_TEXT.

  class-methods GET_FEATURES_TAB
    returning
      value(FEATURES_TAB) type SFES_FEATURES_TAB_TYPE
    exceptions
      UNKNOWN_ERROR .
  class-methods CHECK_GUI_SUPPORT
    importing
      !COMPONENT type STRING optional
      !FEATURE_NAME type STRING optional
    returning
      value(RESULT) type ABAP_BOOL
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI
      UNKNOWN_ERROR .
  class-methods CHECK_OPEN_NEW_WINDOW
    returning
      value(RESULT) type ABAP_BOOL .
  class-methods CLASS_CONSTRUCTOR .
  class-methods CLIPBOARD_EXPORT
    importing
      !NO_AUTH_CHECK type CHAR01 default SPACE
    exporting
      !DATA type STANDARD TABLE
    changing
      !RC type I
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      NO_AUTHORITY .
  class-methods CLIPBOARD_IMPORT
    importing
      !USE_DATA_LINE_SIZE type ABAP_BOOL optional
    exporting
      !DATA type STANDARD TABLE
      !LENGTH type I
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  methods CONSTRUCTOR
    exceptions
      NOT_SUPPORTED_BY_GUI
      CNTL_ERROR .
  class-methods DIRECTORY_BROWSE
    importing
      value(WINDOW_TITLE) type STRING optional
      value(INITIAL_FOLDER) type STRING optional
    changing
      !SELECTED_FOLDER type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods DIRECTORY_CREATE
    importing
      value(DIRECTORY) type STRING
    changing
      !RC type I
    exceptions
      DIRECTORY_CREATE_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      DIRECTORY_ACCESS_DENIED
      DIRECTORY_ALREADY_EXISTS
      PATH_NOT_FOUND
      UNKNOWN_ERROR
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER .
  class-methods DIRECTORY_DELETE
    importing
      value(DIRECTORY) type STRING
    changing
      !RC type I
    exceptions
      DIRECTORY_DELETE_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      PATH_NOT_FOUND
      DIRECTORY_ACCESS_DENIED
      UNKNOWN_ERROR
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER .
  class-methods DIRECTORY_EXIST
    importing
      !DIRECTORY type STRING
    returning
      value(RESULT) type ABAP_BOOL
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI .
  class-methods DIRECTORY_GET_CURRENT
    changing
      !CURRENT_DIRECTORY type STRING
    exceptions
      DIRECTORY_GET_CURRENT_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods DIRECTORY_LIST_FILES
    importing
      value(DIRECTORY) type STRING
      value(FILTER) type STRING default '*.*'
      value(FILES_ONLY) type ABAP_BOOL optional
      value(DIRECTORIES_ONLY) type ABAP_BOOL optional
    changing
      !FILE_TABLE type STANDARD TABLE
      !COUNT type I
    exceptions
      CNTL_ERROR
      DIRECTORY_LIST_FILES_FAILED
      WRONG_PARAMETER
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods DIRECTORY_LIST_FILES_EXT
    importing
      value(DIRECTORY) type STRING
      value(FILTER) type STRING default '*.*'
      value(FILES_ONLY) type ABAP_BOOL optional
      value(DIRECTORIES_ONLY) type ABAP_BOOL optional
    changing
      !FILE_TABLE type STANDARD TABLE
      !COUNT type I
    exceptions
      CNTL_ERROR
      DIRECTORY_LIST_FILES_FAILED
      WRONG_PARAMETER
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods DIRECTORY_SET_CURRENT
    importing
      value(CURRENT_DIRECTORY) type STRING
    changing
      !RC type I
    exceptions
      DIRECTORY_SET_CURRENT_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods DISABLEHISTORYFORFIELD
    importing
      value(FIELDNAME) type STRING
      value(BDISABLED) type ABAP_BOOL
    changing
      value(RC) type I
    exceptions
      FIELD_NOT_FOUND
      DISABLEHISTORYFORFIELD_FAILED
      CNTL_ERROR
      UNABLE_TO_DISABLE_FIELD
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods ENVIRONMENT_GET_VARIABLE
    importing
      value(VARIABLE) type STRING
    changing
      !VALUE type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods ENVIRONMENT_SET_VARIABLE
    importing
      value(VARIABLE) type STRING
      value(VALUE) type STRING
    changing
      !RC type I
    exceptions
      ENVIRONMENT_SET_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER .
  class-methods EXECUTE
    importing
      value(DOCUMENT) type STRING optional
      value(APPLICATION) type STRING optional
      value(PARAMETER) type STRING optional
      value(DEFAULT_DIRECTORY) type STRING optional
      value(MAXIMIZED) type STRING optional
      value(MINIMIZED) type STRING optional
      value(SYNCHRONOUS) type STRING optional
      value(OPERATION) type STRING default 'OPEN'
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      BAD_PARAMETER
      FILE_NOT_FOUND
      PATH_NOT_FOUND
      FILE_EXTENSION_UNKNOWN
      ERROR_EXECUTE_FAILED
      SYNCHRONOUS_FAILED
      NOT_SUPPORTED_BY_GUI .
  class-methods FILE_COPY
    importing
      value(SOURCE) type STRING
      value(DESTINATION) type STRING
      value(OVERWRITE) type ABAP_BOOL default SPACE
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      WRONG_PARAMETER
      DISK_FULL
      ACCESS_DENIED
      FILE_NOT_FOUND
      DESTINATION_EXISTS
      UNKNOWN_ERROR
      PATH_NOT_FOUND
      DISK_WRITE_PROTECT
      DRIVE_NOT_READY
      NOT_SUPPORTED_BY_GUI .
  class-methods FILE_DELETE
    importing
      value(FILENAME) type STRING
    changing
      !RC type I
    exceptions
      FILE_DELETE_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      FILE_NOT_FOUND
      ACCESS_DENIED
      UNKNOWN_ERROR
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER .
  class-methods FILE_EXIST
    importing
      value(FILE) type STRING
    returning
      value(RESULT) type ABAP_BOOL
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI .
  class-methods FILE_GET_ATTRIBUTES
    importing
      !FILENAME type STRING
    exporting
      !READONLY type ABAP_BOOL
      !NORMAL type ABAP_BOOL
      !HIDDEN type ABAP_BOOL
      !ARCHIVE type ABAP_BOOL
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER
      FILE_GET_ATTRIBUTES_FAILED .
  class-methods FILE_GET_SIZE
    importing
      value(FILE_NAME) type STRING
    exporting
      !FILE_SIZE type I
    exceptions
      FILE_GET_SIZE_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      INVALID_DEFAULT_FILE_NAME .
  class-methods FILE_GET_SIZE_LONG
    importing
      value(FILE_NAME) type STRING
    exporting
      !FILE_SIZE type INT8
    exceptions
      FILE_GET_SIZE_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      INVALID_DEFAULT_FILE_NAME .
  class-methods FILE_GET_VERSION
    importing
      value(FILENAME) type STRING
    changing
      !VERSION type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER .
  class-methods FILE_OPEN_DIALOG
    importing
      value(WINDOW_TITLE) type STRING optional
      value(DEFAULT_EXTENSION) type STRING optional
      value(DEFAULT_FILENAME) type STRING optional
      value(FILE_FILTER) type STRING optional
      value(WITH_ENCODING) type ABAP_BOOL optional
      value(INITIAL_DIRECTORY) type STRING optional
      value(MULTISELECTION) type ABAP_BOOL optional
    changing
      !FILE_TABLE type FILETABLE
      !RC type I
      !USER_ACTION type I optional
      !FILE_ENCODING type ABAP_ENCODING optional
    exceptions
      FILE_OPEN_DIALOG_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods FILE_SAVE_DIALOG
    importing
      value(WINDOW_TITLE) type STRING optional
      value(DEFAULT_EXTENSION) type STRING optional
      value(DEFAULT_FILE_NAME) type STRING optional
      !WITH_ENCODING type ABAP_BOOL optional
      value(FILE_FILTER) type STRING optional
      value(INITIAL_DIRECTORY) type STRING optional
      !PROMPT_ON_OVERWRITE type ABAP_BOOL default 'X'
    changing
      !FILENAME type STRING
      !PATH type STRING
      !FULLPATH type STRING
      !USER_ACTION type I optional
      !FILE_ENCODING type ABAP_ENCODING optional
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      INVALID_DEFAULT_FILE_NAME .
  class-methods FILE_SET_ATTRIBUTES
    importing
      !FILENAME type STRING
      !READONLY type ABAP_BOOL optional
      !NORMAL type ABAP_BOOL optional
      !HIDDEN type ABAP_BOOL optional
      !ARCHIVE type ABAP_BOOL optional
    exporting
      !RC type I
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      WRONG_PARAMETER .
  class-methods GET_COMPUTER_NAME
    changing
      !COMPUTER_NAME type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_DESKTOP_DIRECTORY
    changing
      !DESKTOP_DIRECTORY type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_DRIVE_FREE_SPACE_MEGABYTE
    importing
      value(DRIVE) type STRING default 'C:\'
    changing
      !FREE_SPACE type STRING
    exceptions
      CNTL_ERROR
      GET_FREE_SPACE_FAILED
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_DRIVE_TYPE
    importing
      value(DRIVE) type STRING
    changing
      !DRIVE_TYPE type STRING
    exceptions
      CNTL_ERROR
      BAD_PARAMETER
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_FILE_SEPARATOR
    changing
      value(FILE_SEPARATOR) type C
    exceptions
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI
      CNTL_ERROR .
  class-methods GET_FREE_SPACE_FOR_DRIVE
    importing
      value(DRIVE) type STRING
    changing
      !FREE_SPACE type I
    exceptions
      CNTL_ERROR
      GET_FREE_SPACE_FAILED
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_FREE_SPACE_FOR_DRIVE_LONG
    importing
      value(DRIVE) type STRING
    changing
      !FREE_SPACE type INT8
    exceptions
      CNTL_ERROR
      GET_FREE_SPACE_FAILED
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_GUI_PROPERTIES
    changing
      !STREAM type STRING
    exceptions
      CNTL_ERROR
      GET_GUI_PROPERTIES_FAILED
      ERROR_NO_GUI
      WRONG_PARAMETER
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_GUI_VERSION
    changing
      !VERSION_TABLE type FILETABLE
      !RC type I
    exceptions
      GET_GUI_VERSION_FAILED
      CANT_WRITE_VERSION_TABLE
      GUI_NO_VERSION
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_IP_ADDRESS
    returning
      value(IP_ADDRESS) type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_LF_FOR_DESTINATION_GUI
    changing
      !LINEFEED type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_PLATFORM
    returning
      value(PLATFORM) type I
    exceptions
      ERROR_NO_GUI
      CNTL_ERROR
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_SAPGUI_DIRECTORY
    changing
      !SAPGUI_DIRECTORY type STRING
    exceptions
      CNTL_ERROR
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI .
  class-methods GET_SAPGUI_WORKDIR
    changing
      !SAPWORKDIR type STRING
    exceptions
      GET_SAPWORKDIR_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_SAPLOGON_ENCODING
    changing
      !FILE_ENCODING type ABAP_ENCODING
      !RC type I
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      CANNOT_INITIALIZE_GLOBALSTATE .
  class-methods GET_SYSTEM_DIRECTORY
    changing
      !SYSTEM_DIRECTORY type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_TEMP_DIRECTORY
    changing
      !TEMP_DIR type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_UPLOAD_DOWNLOAD_PATH
    changing
      value(UPLOAD_PATH) type STRING
      value(DOWNLOAD_PATH) type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI
      GUI_UPLOAD_DOWNLOAD_PATH
      UPLOAD_DOWNLOAD_PATH_FAILED .
  class-methods GET_USER_NAME
    changing
      !USER_NAME type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_WINDOWS_DIRECTORY
    changing
      !WINDOWS_DIRECTORY type STRING
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GUI_DOWNLOAD
    importing
      !BIN_FILESIZE type I optional
      !FILENAME type STRING
      !FILETYPE type CHAR10 default 'ASC'
      !APPEND type CHAR01 default SPACE
      !WRITE_FIELD_SEPARATOR type CHAR01 default SPACE
      !HEADER type XSTRING default '00'
      !TRUNC_TRAILING_BLANKS type CHAR01 default SPACE
      !WRITE_LF type CHAR01 default 'X'
      !COL_SELECT type CHAR01 default SPACE
      !COL_SELECT_MASK type CHAR255 default SPACE
      !DAT_MODE type CHAR01 default SPACE
      !CONFIRM_OVERWRITE type CHAR01 default SPACE
      !NO_AUTH_CHECK type CHAR01 default SPACE
      !CODEPAGE type ABAP_ENCODING default SPACE
      !IGNORE_CERR type ABAP_BOOL default ABAP_TRUE
      !REPLACEMENT type ABAP_REPL default '#'
      !WRITE_BOM type ABAP_BOOL default SPACE
      !TRUNC_TRAILING_BLANKS_EOL type CHAR01 default 'X'
      !WK1_N_FORMAT type C default SPACE
      !WK1_N_SIZE type C default SPACE
      !WK1_T_FORMAT type C default SPACE
      !WK1_T_SIZE type C default SPACE
      !SHOW_TRANSFER_STATUS type CHAR01 default 'X'
      !FIELDNAMES type STANDARD TABLE optional
      !WRITE_LF_AFTER_LAST_LINE type ABAP_BOOL default 'X'
      !VIRUS_SCAN_PROFILE type VSCAN_PROFILE default '/SCET/GUI_DOWNLOAD'
    exporting
      value(FILELENGTH) type I
    changing
      !DATA_TAB type STANDARD TABLE
    exceptions
      FILE_WRITE_ERROR
      NO_BATCH
      GUI_REFUSE_FILETRANSFER
      INVALID_TYPE
      NO_AUTHORITY
      UNKNOWN_ERROR
      HEADER_NOT_ALLOWED
      SEPARATOR_NOT_ALLOWED
      FILESIZE_NOT_ALLOWED
      HEADER_TOO_LONG
      DP_ERROR_CREATE
      DP_ERROR_SEND
      DP_ERROR_WRITE
      UNKNOWN_DP_ERROR
      ACCESS_DENIED
      DP_OUT_OF_MEMORY
      DISK_FULL
      DP_TIMEOUT
      FILE_NOT_FOUND
      DATAPROVIDER_EXCEPTION
      CONTROL_FLUSH_ERROR
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI .
  class-methods GUI_UPLOAD
    importing
      !FILENAME type STRING default SPACE
      !FILETYPE type CHAR10 default 'ASC'
      !HAS_FIELD_SEPARATOR type CHAR01 default SPACE
      !HEADER_LENGTH type I default 0
      !READ_BY_LINE type CHAR01 default 'X'
      !DAT_MODE type CHAR01 default SPACE
      !CODEPAGE type ABAP_ENCODING default SPACE
      !IGNORE_CERR type ABAP_BOOL default ABAP_TRUE
      !REPLACEMENT type ABAP_REPL default '#'
      !VIRUS_SCAN_PROFILE type VSCAN_PROFILE optional
    exporting
      value(FILELENGTH) type I
      value(HEADER) type XSTRING
    changing
      !DATA_TAB type STANDARD TABLE
      !ISSCANPERFORMED type CHAR01 default SPACE
    exceptions
      FILE_OPEN_ERROR
      FILE_READ_ERROR
      NO_BATCH
      GUI_REFUSE_FILETRANSFER
      INVALID_TYPE
      NO_AUTHORITY
      UNKNOWN_ERROR
      BAD_DATA_FORMAT
      HEADER_NOT_ALLOWED
      SEPARATOR_NOT_ALLOWED
      HEADER_TOO_LONG
      UNKNOWN_DP_ERROR
      ACCESS_DENIED
      DP_OUT_OF_MEMORY
      DISK_FULL
      DP_TIMEOUT
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI .
  class-methods IS_TERMINAL_SERVER
    returning
      value(RESULT) type ABAP_BOOL
    exceptions
      CNTL_ERROR
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI .
  class-methods REGISTRY_DELETE_KEY
    importing
      value(ROOT) type I
      value(KEY) type STRING
    exporting
      !RC type I
    exceptions
      CNTL_ERROR
      REGISTRY_DELETE_KEY_FAILED
      BAD_PARAMETER
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods REGISTRY_DELETE_VALUE
    importing
      value(ROOT) type I
      value(KEY) type STRING
      value(VALUE) type STRING
    exporting
      !RC type I
    exceptions
      CNTL_ERROR
      REGISTRY_DELETE_VALUE_FAILED
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods REGISTRY_GET_DWORD_VALUE
    importing
      value(ROOT) type I
      value(KEY) type STRING
      value(VALUE) type STRING optional
    exporting
      !REG_VALUE type I
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods REGISTRY_GET_VALUE
    importing
      value(ROOT) type I
      value(KEY) type STRING
      value(VALUE) type STRING optional
      !NO_FLUSH type C optional
    exporting
      !REG_VALUE type STRING
    exceptions
      GET_REGVALUE_FAILED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods REGISTRY_SET_DWORD_VALUE
    importing
      !ROOT type I
      !KEY type STRING
      !VALUE type STRING optional
      !DWORD_VALUE type I
    exporting
      !RC type I
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods REGISTRY_SET_VALUE
    importing
      value(ROOT) type I
      value(KEY) type STRING
      value(VALUE_NAME) type STRING optional
      value(VALUE) type STRING
    exporting
      !RC type I
    exceptions
      REGISTRY_ERROR
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods GET_SCREENSHOT
    exporting
      value(MIME_TYPE_STR) type STRING
      value(IMAGE) type XSTRING
    exceptions
      ACCESS_DENIED
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods RAISE_SCRIPTING_EVENT
    importing
      value(PARAMS) type STRING
    exceptions
      REGISTRY_ERROR
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods IS_SCRIPTING_ACTIVE
    returning
      value(RESULT) type I
    exceptions
      CNTL_ERROR
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI .
  class-methods SHOW_DOCUMENT
    importing
      !DOCUMENT_NAME type STRING
      !MIME_TYPE type STRING
      !DATA_LENGTH type I
      !KEEP_FILE type XFLAG optional
    exporting
      !TEMP_FILE_PATH type STRING
    changing
      !DOCUMENT_DATA type STANDARD TABLE
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      BAD_PARAMETER
      ERROR_WRITING_DATA
      ERROR_STARTING_VIEWER
      UNKNOWN_MIME_TYPE
      NOT_SUPPORTED_BY_GUI
      ACCESS_DENIED
      NO_AUTHORITY .
  class-methods TYPEAHEAD_EXPORT
    importing
      !DATA type STANDARD TABLE
    exceptions
      CNTL_ERROR
      ERROR_NO_GUI
      NOT_SUPPORTED_BY_GUI .
  class-methods CHECK_UI_GUIDELINE
    importing
      !GUIDELINE type I
    returning
      value(RESULT) type ABAP_BOOL .

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

*--- INCLUDE: MZMMNMUNBLKF01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 29/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced with POPUP_TO_CONFIRM.
* 2) Obsolete FM UPLOAD Replaced with GUI_UPLOAD.
************************************************************************

***INCLUDE MZMMNMUNBLKF01 .
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
       perform add_delitem100.
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
     WHEN 'UPLOAD'.
       PERFORM upload_from_textfile using p_tc_name
                                          p_table_name
                                          p_mark_name.
       CLEAR P_OK.
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

     IF <MARK_FIELD> = 'X'.
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
*&      Form  fill_sttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fill_sttab.
 REFRESH it_tab1.
   IF g_mode =  'CHA' OR
      g_mode =  'APR'.
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
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'DIS' OR
          g_mode = 'REL'.
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
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'CRE' OR
          g_mode = 'DEL'.
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
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'LIST' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
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
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSE.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'LIST' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.

endform.                    " fill_sttab
*&---------------------------------------------------------------------*
*&      Form  back_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form back_confirm.
DATA  l_choice.
CLEAR l_choice.
*   IF g_mode = 'BLK'.
*     PERFORM clear_var.
*     LEAVE PROGRAM.
*   ENDIF.
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
DATA : l_get1(1) TYPE c.
clear l_get1.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'BACK '
         TEXT_QUESTION               = 'Data will be lost, Want to quit? '
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
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

     IF l_choice = 'J'.
       IF NOT g_mode IS INITIAL.
         PERFORM clear_var.
         CLEAR l_choice.
       ELSE.
         CLEAR l_choice.
         LEAVE PROGRAM.
       ENDIF.
     ENDIF.
   ELSE.
     IF NOT g_mode IS INITIAL.
       PERFORM clear_var.
     ELSE.
       LEAVE PROGRAM.
     ENDIF.
   ENDIF.

endform.                    " back_confirm
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_var.
   IF NOT gv_text_editor1 IS INITIAL.
     PERFORM destroy_ctrl.
   ENDIF.
   CLEAR zmm_nmblkcdhd_st.
   CLEAR g_mode.
**CODE ADDED BY CAB_AMITMOZA
CLEAR : NAME1 , NAME2 , NAME3.
**CODE END BY CAB_AMITMOZA

*   REFRESH g_tc100_itab[].
   REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
*   if g_lock = 'Y'.
*     perform unlock_req.
*     clear g_lock.
*   endif.
*   CLEAR: g_tc110_wa,g_tc120_wa,g_tc130_wa.
   CLEAR: g_hd_copied,g_tct100_copied.
   CLEAR:  g_cors, g_errstat,G_ERRCD_M.

   REFRESH: tlinetab1,tlinetab2,lines_cors.
   REFRESH: lt_text_table1,lt_text_table2.

endform.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  get_correspondense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_correspondense.
 DATA : l_cors LIKE thead-tdname.

   IF g_mode <> 'CRE'.
     CONCATENATE 'CORS' zmm_nmblkcdhd_st-reqno INTO l_cors.

     CALL FUNCTION 'READ_TEXT'
          EXPORTING
               client                  = sy-mandt
               id                      = 'NMOV'
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
****Attachments.
     Select single * from srrelroles
             where logsys  = zmm_nmblkcdhd_st-reqno
             and   objtype = 'NMC'
             and   objkey  = '01'.
     if sy-subrc = 0.
       g_attach = 'X'.
     else.
       g_attach = ''.
     endif.
   ENDIF.

endform.                    " get_correspondense
*&---------------------------------------------------------------------*
*&      Form  text_control_eingabebereit1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form text_control_eingabebereit1.
  CALL METHOD gv_text_editor1->set_readonly_mode
            EXPORTING
                 readonly_mode = gv_text_editor1->true
            EXCEPTIONS
                 error_cntl_call_method = 1
                 invalid_parameter      = 2
                 OTHERS                 = 3.
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
      ( g_mode = 'APR' ).

     CALL METHOD gv_text_editor2->set_readonly_mode
          EXPORTING
               readonly_mode = gv_text_editor2->false
          EXCEPTIONS
               error_cntl_call_method = 1
               invalid_parameter      = 2
               OTHERS                 = 3.
   ENDIF.
endform.                    " text_control_eingabebereit1
*&---------------------------------------------------------------------*
*&      Form  text_control_set_text_table1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form text_control_set_text_table1.
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
             text = lt_text_table1
        EXCEPTIONS
             error_dp        = 1
             error_dp_create = 2
             OTHERS          = 3.
********************highlight**************************************
   CLEAR g_linefrto.
   LOOP AT g_linefrto_itab INTO g_linefrto.
     CALL METHOD gv_text_editor1->highlight_lines
        EXPORTING
             from_line = g_linefrto-line_fr
             to_line   = g_linefrto-line_to
             highlight_mode = 1.
   ENDLOOP.
********************************************************************
**Setting of first line..
   CALL METHOD gv_text_editor1->set_first_visible_line
        EXPORTING
               line = '1'.
********************************************************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
      ( g_mode = 'APR' ).

     CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          TABLES
               itf_text    = tlinetab2
               text_stream = lt_text_table2.

     CALL METHOD gv_text_editor2->set_text_as_stream
          EXPORTING
               text = lt_text_table2
          EXCEPTIONS
               error_dp        = 1
               error_dp_create = 2
               OTHERS          = 3.
   ENDIF.

endform.                    " text_control_set_text_table1
*&---------------------------------------------------------------------*
*&      Form  destroy_ctrl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form destroy_ctrl.
 CASE g_mode.
     WHEN 'CRE' OR 'CHA' OR 'REL' OR 'APR' OR 'BLK'.
       CALL METHOD gv_text_editor1->free.
       CALL METHOD gv_text_editor2->free.
     WHEN 'DIS' OR 'DEL'.
       CALL METHOD gv_text_editor1->free.
  ENDCASE.
   CLEAR:gv_text_editor1,gv_text_editor2.

endform.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_request.
   Data: l_tct100_wa type t_tct100.
   IF g_mode = 'CRE' OR g_mode = 'CHA'.
         IF NOT g_tct100_itab[] IS INITIAL.
           READ TABLE g_tct100_itab into l_tct100_wa
                WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           Perform check_errors changing g_errstat.
             if g_errstat = 'E'.
               CLEAR:g_errstat,ok_code100.
               EXIT.
             endif.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
   ENDIF.
   IF g_mode = 'CRE'.
     zmm_nmblkcdhd_st-reqno = g_reqno.
     PERFORM insert_into_tab.
     perform popup_message.
     MESSAGE i005(zmm_oth) WITH g_reqno.
     PERFORM clear_var.
     CLEAR ok_code100.
   ELSEIF g_mode = 'CHA'.
     g_request_no = zmm_nmblkcdhd_st-reqno .
     PERFORM prepare_update.
     COMMIT WORK.
     MESSAGE i006(zmm_oth) WITH g_request_no.
     PERFORM clear_var.
     CLEAR ok_code100.
   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
     CLEAR ok_code100.
   ELSEIF g_mode = 'REL'.
     IF zmm_nmblkcdhd_st-relflag = ''.
       CLEAR ok_code100.
       MESSAGE i024(zmm_oth) WITH 'Release'.
     ELSE.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
       IF g_rel = 'Y'.
         PERFORM update_rel.
*         PERFORM send_mail_to_cdcell.
         PERFORM clear_var.
         CLEAR ok_code100.
       ELSE.
         clear zmm_nmblkcdhd_st-relflag.
         CLEAR ok_code100.
         EXIT.
       ENDIF.
     ENDIF.
   ELSEIF g_mode = 'APR'.
     IF zmm_nmblkcdhd_st-appflag = ''.
       CLEAR ok_code100.
       MESSAGE i024(zmm_oth) WITH 'Approval'.
     ELSE.
       perform confirm_approval.
*       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
       IF g_app = 'J'.
         PERFORM update_apr.
         PERFORM send_mail_to_cdcell.
         PERFORM clear_var.
         CLEAR ok_code100.
       ELSE.
         clear zmm_nmblkcdhd_st-appflag.
         CLEAR ok_code100.
         EXIT.
       ENDIF.
     ENDIF.
   ELSEIF g_mode = 'BLK'.
     PERFORM update_cdcell.
     IF zmm_nmblkcdhd_st-status = 'IR'.
       PERFORM send_mail_to_reqn.
     ENDIF.
     PERFORM clear_var.
     CLEAR ok_code100.
     LEAVE PROGRAM.
   ENDIF.

endform.                    " save_request
*&---------------------------------------------------------------------*
*&      Form  insert_into_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form insert_into_tab.
 DATA: l_blkhd LIKE zmm_nmblkcdhd.
 CLEAR : l_blkhd.
****Header Part*********
   IF g_mode = 'CRE'.
     MOVE sy-datum TO zmm_nmblkcdhd_st-reqdate.
     MOVE sy-uname TO zmm_nmblkcdhd_st-reqcpf.
     MOVE 'N' TO zmm_nmblkcdhd_st-status.
     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     INSERT INTO zmm_nmblkcdhd VALUES l_blkhd.
   ELSEIF g_mode = 'CHA'.
     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     MODIFY zmm_nmblkcdhd FROM l_blkhd.
   ENDIF.
****Detail Part************
*   Refresh ist_zmm_cditem.
   LOOP AT g_tct100_itab INTO g_tct100_wa.
        MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
        MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
        append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.

   IF g_mode = 'CRE'.
     INSERT zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
   ELSE.
     MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
***If the req status id is 'IR', should be updated to 'IC'
    IF zmm_nmblkcdhd_st-status = 'IR'.
     IF g_result = '1'.
      UPDATE zmm_nmblkcdhd
      SET   status    = 'IC'
      WHERE reqno     = zmm_nmblkcdhd_st-reqno.
     ENDIf.
    ENDIF.

   ENDIF.
******Header(Correspondence)********************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'APR' ).
     PERFORM save_cors_text.
   ENDIF.

endform.                    " insert_into_tab
*&---------------------------------------------------------------------*
*&      Form  prepare_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form prepare_update.
 DATA : l_del100 TYPE t_tct100.
* CLEAR g_item.
*   SELECT SINGLE * INTO g_item FROM zmm_nmblkcddt
*          WHERE reqno = zmm_nmblkcdhd_st-reqno.
**
      IF NOT g_itab_del100[] IS INITIAL.
         LOOP AT g_itab_del100 INTO l_del100.
           DELETE FROM zmm_nmblkcddt
             WHERE reqno = zmm_nmblkcdhd_st-reqno
             AND   srno  = l_del100-srno.
         ENDLOOP.
       ENDIF.
**
   PERFORM insert_into_tab.

endform.                    " prepare_update
*&---------------------------------------------------------------------*
*&      Form  prepare_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form prepare_delete.

   PERFORM confirm_del.

   IF g_choice = 'J'.

     DELETE FROM zmm_nmblkcdhd
     WHERE reqno = zmm_nmblkcdhd_st-reqno.
     IF sy-subrc <> 0.
       MESSAGE e007(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
     ENDIF.
*
     SELECT tdobject tdname tdid FROM stxl
      INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
      WHERE tdid = 'NMOV'.
     IF sy-subrc = 0.
       DELETE ist_textid_items
          WHERE tdname+4(10) <> zmm_nmblkcdhd_st-reqno.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ENDIF.

     DELETE FROM zmm_nmblkcddt
     WHERE reqno = zmm_nmblkcdhd_st-reqno.
     IF sy-subrc = 0.
       MESSAGE i004(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
     ENDIF.
     CLEAR g_choice.
   ENDIF.

endform.                    " prepare_delete
*&---------------------------------------------------------------------*
*&      Form  update_rel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_rel.
 UPDATE zmm_nmblkcdhd
   SET   relflag = 'X'
         relby   = sy-uname
         reldate = sy-datum
   WHERE reqno    = zmm_nmblkcdhd_st-reqno.
***If the req status id is 'IR', should be updated to 'IC'
***At the time of releasing the request.
*   IF zmm_nmblkcdhd_st-status = 'IR'.
*     UPDATE zmm_nmblkcdhd
*     SET   status    = 'IC'
*     WHERE reqno     = zmm_nmblkcdhd_st-reqno.
*   ENDIF.
***
   PERFORM save_cors_text.
   MESSAGE i019(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.

endform.                    " update_rel
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form send_mail_to_cdcell.
   DATA: l_text  TYPE soli,
         l_name  LIKE sood1-objnam,
         l_title LIKE sood1-objdes,
         l_user  LIKE sy-uname.
   DATA  l_text_itab LIKE TABLE OF l_text.
**
   CLEAR : l_name,l_title,l_text,l_user.
   REFRESH l_text_itab.
**Assignments.....
   l_name   = zmm_nmblkcdhd_st-reqno.
   CONCATENATE 'Unblock MatCode Request for' zmm_nmblkcdhd_st-reqno
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
       mailname          = l_name
       mailtitel         = l_title
       user              = l_user
    TABLES
      text              =  l_text_itab.

   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

endform.                    " send_mail_to_cdcell
*&---------------------------------------------------------------------*
*&      Form  update_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_cdcell.
   DATA   : l_tc100 TYPE t_tct100.

   CLEAR  : l_tc100,zmm_nmblkcddt.
   REFRESH: itab_nmblkcddt.

***Header
   if ZMM_NMBLKCDHD_ST-status = 'IR'.
     Select single * from zmm_nmblkcdhd
            where reqno = zmm_NMBLKCDHD_st-reqno.
     if zmm_NMBLKCDHD-ir_date is initial.
        ZMM_NMBLKCDHD_ST-ir_date = sy-datum.
     endif.
   else.
      clear ZMM_NMBLKCDHD_ST-ir_date.
   endif.
   move-corresponding ZMM_NMBLKCDHD_ST to Zmm_NMBLKCDHD.
   modify ZMM_NMBLKCDHD from zmm_NMBLKCDHD.
***details
       LOOP AT g_tct100_itab INTO l_tc100.
         MOVE-CORRESPONDING l_tc100 TO wa_nmblkcddt.
         MOVE zmm_NMBLKCDHD_st-reqno TO wa_nmblkcddt-reqno.
         APPEND wa_nmblkcddt TO itab_nmblkcddt.
         CLEAR:wa_nmblkcddt,l_tc100.
       ENDLOOP.
       MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
       REFRESH itab_nmblkcddt.
***Correspondense.
   PERFORM save_cors_text.

endform.                    " update_cdcell
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_reqn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form send_mail_to_reqn.
   DATA:  r_text  TYPE soli,
          r_name  LIKE sood1-objnam,
          r_title LIKE sood1-objdes,
          r_user  TYPE sy-uname.
   DATA:  r_text_itab LIKE TABLE OF r_text.
**
   CLEAR : r_name,r_title,r_text.
   REFRESH r_text_itab.
**Assignments.....
   r_name   = zmm_nmblkcdhd_st-reqno.
   CONCATENATE 'Request' zmm_nmblkcdhd_st-reqno 'Status'
               INTO r_title SEPARATED BY space.
   IF zmm_nmblkcdhd_st-status = 'C'.
  r_text = 'Request has been updated.Please check the Request,Request'
&'status and correspondence within it.this is a system generated mail,'
&'please do not reply. - codification cell'.
     APPEND r_text TO r_text_itab.
**
   ELSEIF zmm_nmblkcdhd_st-status = 'IR'.
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
   SELECT SINGLE reqcpf INTO r_user FROM zmm_nmblkcdhd
          WHERE reqno = zmm_nmblkcdhd_st-reqno.
***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       mailname          = r_name
       mailtitel         = r_title
       user              = r_user
    TABLES
      text              =  r_text_itab
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

endform.                    " send_mail_to_reqn
*&---------------------------------------------------------------------*
*&      Form  save_cors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_cors_text.
   DATA: l_theader LIKE thead.
   DATA: l_datech(10) TYPE c.
***********Assignments***********************
   CLEAR l_theader.
   l_theader-tdobject   = 'ZMMCD'.
   l_theader-tdid       = 'NMOV'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_nmblkcdhd_st-reqno INTO l_theader-tdname.
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

endform.                    " save_cors_text
*&---------------------------------------------------------------------*
*&      Form  confirm_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_del.
 CLEAR g_choice.
" Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*     EXPORTING
*    textline1 = 'Data will be lost,No recovery possible,Are you sure ?'
*      titel            = 'DELETE'
*      start_column     = 25
*      start_row        = 6
*      cancel_display   = ''
*     IMPORTING
*       answer          = g_choice.
 DATA : l_get2(1) TYPE c.
 CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR                    = 'DELETE '
     TEXT_QUESTION               = 'Data will be lost,No recovery possible,Are you sure ?'
    DISPLAY_CANCEL_BUTTON       = ' '
    START_COLUMN                = 25
    START_ROW                   = 6
  IMPORTING
    ANSWER                      = l_get2
  EXCEPTIONS
    TEXT_NOT_FOUND              = 1
    OTHERS                      = 2
           .
 IF SY-SUBRC = 0.
       CASE l_get2.
         WHEN '1'.
           MOVE 'J' TO g_choice.
           WHEN '2'.
             MOVE 'N' TO g_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
endform.                    " confirm_del
*&---------------------------------------------------------------------*
*&      Form  delete_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_text.
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
endform.                    " delete_text
*&---------------------------------------------------------------------*
*&      Form  update_apr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_apr.
 UPDATE zmm_nmblkcdhd
   SET   appflag = 'X'
         APPBY   = sy-uname
         APPDATE = sy-datum
   WHERE reqno    = zmm_nmblkcdhd_st-reqno.
***If the req status id is 'IR', should be updated to 'IC'
***At the time of releasing the request.
   IF zmm_nmblkcdhd_st-status = 'IR'.
     UPDATE zmm_nmblkcdhd
     SET   status    = 'IC'
     WHERE reqno     = zmm_nmblkcdhd_st-reqno.
   ENDIF.
***
   PERFORM save_cors_text.
   MESSAGE i119(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.

endform.                    " update_apr
*&---------------------------------------------------------------------*
*&      Form  add_delitem100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_delitem100.
 DATA : l_tc100_wa TYPE t_tct100.
   LOOP AT g_tct100_itab INTO l_tc100_wa.
     IF l_tc100_wa-flag = 'X'.
       APPEND l_tc100_wa TO g_itab_del100.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc100_wa.
endform.                    " add_delitem100
*&---------------------------------------------------------------------*
*&      Form  gen_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form gen_request.
 CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
             nr_range_nr = '01'
             object      = 'ZMMNMUNBLK'
        IMPORTING
             number      = g_reqno.
   IF sy-subrc <> 0.
   ENDIF.
endform.                    " gen_request
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_nextsrno.
 DATA : g_100itab TYPE TABLE OF t_tct100.
 DATA : l_100itab TYPE t_tct100.
 CLEAR  l_100itab.
 REFRESH g_100itab.

   APPEND LINES OF g_tct100_itab TO g_100itab.
   SORT g_100itab BY srno DESCENDING.
   READ TABLE g_100itab INTO l_100itab INDEX 1.
   l_srno = l_100itab-srno + 1.

endform.                    " get_nextsrno
*&---------------------------------------------------------------------*
*&      Form  unblock_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form unblock_matcode.
 Data : l_unblk100 type t_tct100.
 Data : l_atwrt like ausp-atwrt,
        l_matnr like mara-matnr,
        l_atinn like ausp-atinn.
 Data : l_totlines type i,
        l_unblklines type i.
**
  CLEAR   wa_nmblkcddt.
  REFRESH itab_nmblkcddt[].
**
  clear g_mesg.
  READ TABLE g_tct100_itab into l_unblk100
       WITH KEY flag  = 'X'.
       IF sy-subrc <> 0.
         g_mesg = 'X'.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.
**
  PERFORM confirm_unblock.
  IF g_choice = 'J'.
***Updating classification view.
   LOOP AT g_tct100_itab into g_tct100_wa
        where flag  = 'X'
        and   errcd = ''.
    l_matnr = g_tct100_wa-matcode.
* Begin of <RD1K976495> on 03062011

     update mara set ZZMBPR = ''
                     ZZNMFLG = ''
                 where matnr = l_matnr.
     if sy-subrc = 0.

    endif.
* End of <RD1K976495> on 03062011
    SELECT * FROM KLAH UP TO 1 ROWS

 WHERE KLART = '001' AND CLASS = 'Z_ONGC_BLOCK'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
     DELETE FROM KSSK
            where objek = l_matnr
            AND   clint = klah-clint
            AND   klart = '001'.
    ENDIF.
**
    SELECT ATINN INTO L_ATINN
 FROM CABN UP TO 1 ROWS WHERE ATNAM = 'Z_ONGC_REASON'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    If sy-subrc = 0.
       Delete from AUSP
              WHERE  objek = l_matnr
              AND    atinn = l_atinn.
**
      g_tct100_wa-mstae = ''.
      modify g_tct100_itab from g_tct100_wa.
**
    Endif.
**  Updating internal comment in basic view..
    perform update_internal_comment using g_tct100_wa-matcode
                                          g_tct100_wa-res_nm.
    Clear: l_matnr,l_atinn.

   ENDLOOP.
**Updating database table
   LOOP AT g_tct100_itab INTO g_tct100_wa
                         where flag = 'X'
                         and   errcd = ''.
        MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
        MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
        move sy-uname to wa_nmblkcddt-unblkby.
        move sy-datum to wa_nmblkcddt-unblkdt.
        append wa_nmblkcddt to itab_nmblkcddt.
        clear:g_tct100_wa,wa_nmblkcddt.
   ENDLOOP.
   LOOP AT g_tct100_itab INTO g_tct100_wa
                         where errcd <> ''.
        MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
        MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
        append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.
   modify zmm_nmblkcddt from table itab_nmblkcddt.

***Setting the request status.
      IF zmm_nmblkcdhd_st-status = 'IR'.
        PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
      ELSE.
*        DESCRIBE TABLE g_tct100_itab LINES l_totlines.
        SELECT COUNT(*) INTO l_totlines
                        FROM zmm_nmblkcddt
                        WHERE reqno = zmm_nmblkcdhd_st-reqno.

        SELECT COUNT(*) INTO l_unblklines
                      FROM zmm_nmblkcddt
        WHERE reqno = zmm_nmblkcdhd_st-reqno
        AND   mstae = ''.

        IF l_unblklines < l_totlines.
          zmm_nmblkcdhd_st-status = 'IC'.
          PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
        ELSE.
          zmm_nmblkcdhd_st-status = 'C'.
           PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
        ENDIF.
      ENDIF.
      PERFORM save_cors_text.
  ELSE.
    g_mesg = 'X'.
  ENDIF.
  CLEAR g_choice.

* LOOP AT C_EBAN
*    SELECT * FROM kssk INTO TABLE tkssk
*              WHERE objek = c_eban-matnr
*              AND   klart = '001'.
*     IF sy-subrc = 0.  " kssk
*      LOOP AT tkssk.
*        SELECT SINGLE * FROM klah
*               WHERE klart  = '001'
*               AND   clint  = tkssk-clint
*               AND   class  = 'Z_ONGC_BLOCK'.
*        IF sy-subrc = 0.
*          SELECT SINGLE atinn INTO l_atinn
*                 FROM   cabn
*                 WHERE atnam = 'Z_ONGC_REASON'.
*          If sy-subrc = 0.
*             Select single atwrt into l_atwrt
*                    from ausp
*                    WHERE  objek = l_matnr
*                    AND    atinn = l_atinn.
*              IF sy-subrc = 0.
*                if l_atwrt = 'NM'.
*                 message e154(zmm_oth) with l_matnr.
*                endif.
*              ENDIF.
*              CLEAR: l_atinn,l_atwrt.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*     ENDIF.
*   ENDLOOP.

endform.                    " unblock_matcode
*&---------------------------------------------------------------------*
*&      Form  confirm_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_approval.
" Begin of <RD1K960036>.

* CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               textline1      = 'Want to Approve the request ? '
*               titel          = 'Approval'
*               start_column   = 25
*               start_row      = 6
*               cancel_display = ''
*          IMPORTING
*               answer         = g_app.
  DATA : l_get3(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'Approval '
      TEXT_QUESTION               = 'Want to Approve the request ? '
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
           MOVE 'J' TO g_app.
           WHEN '2'.
             MOVE 'N' TO g_app.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
endform.                    " confirm_approval
*&---------------------------------------------------------------------*
*&      Form  upload_from_textfile
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
form upload_from_textfile using  p_tc_name
                                 p_table_name
                                 p_mark_name.
 DATA: l_filename LIKE rlgrap-filename.
 DATA: l_tx100  TYPE t_tx100.
 DATA: wa_tx100 TYPE t_tx100.
 refresh : g_ex100_itab[].
" Begin of <RD1K960036>.
*   CALL FUNCTION 'UPLOAD'
*        EXPORTING
*             filename                = l_filename
*             filetype                = 'DAT'
*             item                    = ' '
*             filemask_mask           = ' '
*             filemask_text           = ' '
*             filetype_no_change      = ' '
*             filemask_all            = ' '
*             filetype_no_show        = ' '
*             line_exit               = ' '
*             user_form               = ' '
*             user_prog               = ' '
*             silent                  = 'S'
*        TABLES
*             data_tab                = g_tx100_itab
*        EXCEPTIONS
*             conversion_error        = 1
*             invalid_table_width     = 2
*             invalid_type            = 3
*             no_batch                = 4
*             unknown_error           = 5
*             gui_refuse_filetransfer = 6
*             OTHERS                  = 7.
*   IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*   ENDIF.



DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
       l_FILETABLE  TYPE  FILE_TABLE,
       l_RC         TYPE  I,
       l_P_DEF_FILE TYPE  STRING,
       l_P_FILE     TYPE  STRING,
       l_usr_act    TYPE  I.

 l_P_DEF_FILE = l_filename.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
  EXPORTING
*    WINDOW_TITLE            =
*    DEFAULT_EXTENSION       =
    DEFAULT_FILENAME        = l_P_DEF_FILE
*    FILE_FILTER             =
*    WITH_ENCODING           =
*    INITIAL_DIRECTORY       =
*    MULTISELECTION          =
  CHANGING
    FILE_TABLE              = I_FILE_TABLE
    RC                      = l_RC
    USER_ACTION             = l_usr_act
*    FILE_ENCODING           =
  EXCEPTIONS
    FILE_OPEN_DIALOG_FAILED = 1
    CNTL_ERROR              = 2
    ERROR_NO_GUI            = 3
    NOT_SUPPORTED_BY_GUI    = 4
    others                  = 5
        .
IF SY-SUBRC = 0 AND
   l_usr_act <>
   CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

    LOOP AT I_FILE_TABLE  INTO l_FILETABLE.
       l_P_FILE = l_FILETABLE.
        EXIT.
    ENDLOOP.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
       FILENAME                      = l_P_FILE
       FILETYPE                       = g_c_asc
       HAS_FIELD_SEPARATOR            = 'X'
      TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*        DATA_TAB                      = g_tx100_itab
        DATA_TAB                      = g_tx100_itab     "#EC CI_FLDEXT_OK[2215424]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
     EXCEPTIONS
       FILE_OPEN_ERROR               = 1
       FILE_READ_ERROR               = 2
       NO_BATCH                      = 3
       GUI_REFUSE_FILETRANSFER       = 4
       INVALID_TYPE                  = 5
       NO_AUTHORITY                  = 6
       UNKNOWN_ERROR                 = 7
       BAD_DATA_FORMAT               = 8
       HEADER_NOT_ALLOWED            = 9
       SEPARATOR_NOT_ALLOWED         = 10
       HEADER_TOO_LONG               = 11
       UNKNOWN_DP_ERROR              = 12
       ACCESS_DENIED                 = 13
       DP_OUT_OF_MEMORY              = 14
       DISK_FULL                     = 15
       DP_TIMEOUT                    = 16
       OTHERS                        = 17
              .
    IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

ENDIF.
" End of <RD1K960036>.

   sort g_tx100_itab ascending by matcode.
   delete adjacent duplicates from g_tx100_itab comparing matcode.
*   if g_mode = 'CRE'.
*     perform get_data_from_tx100.
*   endif.

*matcode validation durin text file data upload
*   IF NOT g_tx100_itab[] IS INITIAL.
*     LOOP AT g_tx100_itab[] INTO wa_tx100.
*       clear g_recstat.
*       PERFORM validate_matcode USING wa_tx100-matcode
*                                CHANGING g_recstat.
*       if g_recstat = 'E'.
*         append wa_tx100 to g_ex100_itab.
*         delete g_tx100_itab[] where matcode = wa_tx100-matcode.
*       endif.
*     ENDLOOP.
*   ENDIF.


endform.                    " upload_from_textfile
*&---------------------------------------------------------------------*
*&      Form  get_data_from_tx100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_data_from_tx100.
Data: l_tx100_wa type t_tx100,
      l_srno like zmm_nmblkcddt-srno.
***Setting serial number.
 if g_tctlines = 0.
   l_srno = 0.
  else.
   if g_mode = 'CHA'.
    Select max( srno ) into l_srno from zmm_nmblkcddt
           where reqno = zmm_nmblkcdhd_st-reqno.
   else.
     l_srno = g_tctlines.
   endif.
  endif.
***
 loop at g_tx100_itab into l_tx100_wa.
  l_srno = l_srno + 1.
  g_tct100_wa-srno    = l_srno.
  g_tct100_wa-matcode = l_tx100_wa-matcode.
  SELECT MAKTX INTO G_TCT100_WA-MATDESC FROM MAKT UP TO 1 ROWS
 WHERE MATNR = L_TX100_WA-MATCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  select single meins into g_tct100_wa-uom from mara
         where matnr = l_tx100_wa-matcode.
  g_tct100_wa-res_nm  = l_tx100_wa-res_nm.
***check for non moving items..
       clear g_recstat.
       PERFORM validate_matcode USING l_tx100_wa-matcode
                                CHANGING g_recstat.
       if g_recstat = 'E'.
        g_tct100_wa-errcd = 'M'.
        g_tct100_wa-flag  = 'X'.
       endif.
***
  append g_tct100_wa to g_tct100_itab .
  clear g_tct100_wa.
 endloop.
endform.                    " get_data_from_tx100
*&---------------------------------------------------------------------*
*&      Form  validate_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_TX100_MATCODE  text
*      <--P_G_RECSTAT  text
*----------------------------------------------------------------------*
form validate_matcode using    p_matcode
                      changing p_recstat.
 Data: l_objek like ausp-objek.
 Select single objek into l_objek from ausp
         where objek = p_matcode
         and   atinn = ( Select atinn from cabn
                                where atnam = 'Z_ONGC_REASON' )
         and   klart = '001'
         and   atwrt = 'NM'.
 if sy-subrc <> 0.
   p_recstat = 'E'.
 endif.
endform.                    " validate_matcode
*&---------------------------------------------------------------------*
*&      Form  check_errors
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_errors changing p_errstat.
Data : l_tct100 type t_tct100.
**
 read table g_tct100_itab into l_tct100
                          with key errcd = 'M'.
  if sy-subrc = 0.
    p_errstat = 'E'.
    message i121(zmm_oth) with l_tct100-srno.
  endif.

endform.                    " check_errors
*&---------------------------------------------------------------------*
*&      Form  attach_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form attach_file.

 clear g_att_files_wa.
 refresh g_att_files.
 IF g_mode = 'CHA'.
   g_att_files_wa-LOGSYS  = zmm_nmblkcdhd_st-reqno.
   g_att_files_wa-objtype = 'NMC'.   "'ATT'.
   g_att_files_wa-objkey  = '01'.

   append g_att_files_wa to g_att_files.

   CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
        EXPORTING
             ATTACHMENT_DATA           = ''
             ATTACHMENT_TYPE           = 'DOC'
         TABLES
             APPLICATION_OBJECTS       = g_att_files.
 Endif.

endform.                    " attach_file
*&---------------------------------------------------------------------*
*&      Form  list_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form list_file.
 g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
 g_att_files_wa-objtype = 'NMC'.
 g_att_files_wa-objkey = '01'.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa.
*   FUNCTION                 = ' '
* TABLES
*   FUNC_EXCLUDE             =  .


endform.                    " list_file
*&---------------------------------------------------------------------*
*&      Form  confirm_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_exit.
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
     DATA : l_get4(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'EXIT '
         TEXT_QUESTION               = 'Data will be lost, Want to quit? '
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

     IF l_choice1 = 'J'.
       CLEAR l_choice1.
       PERFORM clear_var.
       LEAVE PROGRAM.
     ENDIF.
   ELSE.
     PERFORM clear_var.
     LEAVE PROGRAM.
   ENDIF.

endform.                    " confirm_exit
*&---------------------------------------------------------------------*
*&      Form  confirm_unblock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_unblock.
  CLEAR g_choice.
" Begin of <RD1K960036>.

*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*             textline1      = 'Want to unblock selected Codes ?'
*             titel          = 'Unblock'
*             start_column   = 25
*             start_row      = 6
*             cancel_display = ''
*        IMPORTING
*             answer         = g_choice.
DATA : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Unblock'
    TEXT_QUESTION               = 'Want to unblock selected Codes ?'
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
           MOVE 'J' TO g_choice.
           WHEN '2'.
             MOVE 'N' TO g_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

endform.                    " confirm_unblock
*&---------------------------------------------------------------------*
*&      Form  popup_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form popup_message.
Data : wa_text like trtab.
Data : itab_text like trtab occurs 0.
refresh itab_text.
**
 wa_text =
 'Please ensure that approval of concerned Director for unblocking '.
  append wa_text to itab_text.
  clear wa_text.

 wa_text =
 'of Material codes has been attached in the change mode.'.
  append wa_text to itab_text.
  clear wa_text.

CALL FUNCTION 'LAW_SHOW_POPUP_WITH_TEXT'
  EXPORTING
    titelbar                     = 'NOTE'
    SHOW_CANCEL_BUTTON           = 'X'
    LINE_SIZE                    = 65
  tables
    list_tab                     =  itab_text.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

endform.                    " popup_message
*&---------------------------------------------------------------------*
*&      Form  set_reqcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MATBLOCKHD_ST_REQCL  text
*----------------------------------------------------------------------*
form set_reqcl using p_status.
     UPDATE zmm_nmblkcdhd
     SET status = p_status
     WHERE reqno = zmm_nmblkcdhd_st-reqno.

**
   IF zmm_nmblkcdhd_st-status = 'IR'.
     UPDATE zmm_nmblkcdhd
      SET ir_date = sy-datum
      WHERE reqno = zmm_nmblkcdhd_st-reqno.
   ENDIF.

endform.                    " set_reqcl
*&---------------------------------------------------------------------*
*&      Form  update_internal_comment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TCT100_WA_MATCODE  text
*      -->P_G_TCT100_WA_RESNM  text
*----------------------------------------------------------------------*
form update_internal_comment using    p_matcode
                                      p_res_nm.
 Data: wa_lines like tline,
       l_txt like tline-tdline,
       l_insert type c.
 Data : header like  thead,
        l_tdname like thead-tdname.
 Data : ist_nmlines like tline occurs 0 with header line.

****Update Internal Comments
        header-tdobject = 'MATERIAL'.
        header-tdid     = 'IVER'.
        header-tdname   =  p_matcode .
        header-tdspras  = 'EN'.
        header-tdform   = 'SYSTEM'.
        header-mandt    = sy-mandt .
        l_tdname        = p_matcode.
 refresh: ist_nmlines.

***Fetching the existing text against matcode.
        select single * from stxh
                 where tdobject = 'MATERIAL'
                 and   tdname   = l_tdname
                 and   tdid     = 'IVER'.
        if sy-subrc = 0.
          call function 'READ_TEXT'
               exporting
                    client   = sy-mandt
                    id       = 'IVER'
                    language = 'E'
                    name     = l_tdname
                    object   = 'MATERIAL'
               tables
                    lines    = ist_nmlines.
        endif.
***Appending the remark to existing text.
        IF NOT ist_nmlines[] IS INITIAL.
         wa_lines-tdformat = '*'.
         wa_lines-tdline = '               '.
         append wa_lines to ist_nmlines .
        ENDIF.
        concatenate sy-uname '-' sy-datum+6(2) '/'
                                 sy-datum+4(2) '/'
                                 sy-datum+0(4) '/' into l_txt .
        wa_lines-tdformat = '*'.
        wa_lines-tdline  =  l_txt .
        append wa_lines to ist_nmlines .
        wa_lines-tdline = p_res_nm.
        append wa_lines to ist_nmlines .
        clear l_txt.
        concatenate 'Request no-' zmm_nmblkcdhd_st-reqno into l_txt.
        wa_lines-tdline = l_txt.
        append wa_lines to ist_nmlines .
        wa_lines-tdline = '******************************************'.
        append wa_lines to ist_nmlines .

        if ist_nmlines[] is initial.
          l_insert = 'X'.
        else.
          l_insert =  space.
        endif.
***Saving the nonmoving text ( Remark)

        call function 'SAVE_TEXT'
             exporting
                  client          = sy-mandt
                  header          = header
                  insert          = l_insert
                  savemode_direct = 'X'
             tables
                  lines           = ist_nmlines.


endform.                    " update_internal_comment
*&---------------------------------------------------------------------*
*&      Form  del_attachment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form del_attachment.
  g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
  g_att_files_wa-objtype = 'NMC'.
  g_att_files_wa-objkey = '01'.

 CALL FUNCTION 'ZSO_DEL_ATTACHMENT'
   EXPORTING
    application_object       = g_att_files_wa.
*    FUNCTION                 = ' '.



endform.                    " del_attachment
*&---------------------------------------------------------------------*
*&      Form  guidelines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form guidelines.

 clear g_att_files_wa.
 g_att_files_wa-LOGSYS = 'UBNMCDHELP'.
 g_att_files_wa-objtype = 'NMC'.
 g_att_files_wa-objkey = '01'.



 refresh exclude_tab[].
 MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa
   TABLES
    FUNC_EXCLUDE             = EXCLUDE_TAB.

endform.                    " guidelines
*&---------------------------------------------------------------------*
*&      Form  circular
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form circular.
 clear g_att_files_wa.

 g_att_files_wa-LOGSYS = 'UBNMCDCIRC'.
 g_att_files_wa-objtype = 'NMC'.
 g_att_files_wa-objkey = '01'.

 refresh exclude_tab[].
 MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa
   TABLES
    FUNC_EXCLUDE             = EXCLUDE_TAB.

endform.                    " circular

*--- INCLUDE: MZMMNMUNBLKI01 ---*
***INCLUDE MZMMNMUNBLKI01 .
*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: modify table
MODULE tct100_modify INPUT.
  MOVE-CORRESPONDING zmm_nmblkcddt TO g_tct100_wa.
  MODIFY g_tct100_itab
    FROM g_tct100_wa
    INDEX tct100-current_line.
  IF sy-subrc <> 0.
    APPEND g_tct100_wa TO g_tct100_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: mark table
MODULE tct100_mark INPUT.
  IF tct100-line_sel_mode = 1 AND
     g_tct100_wa-flag = 'X'.
    LOOP AT g_tct100_itab INTO g_tct100_wa
      WHERE flag = 'X'.
      g_tct100_wa-flag = ''.
      MODIFY g_tct100_itab
        FROM g_tct100_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tct100_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tct100_itab
    FROM g_tct100_wa
    INDEX tct100-current_line
    TRANSPORTING flag.
ENDMODULE.

*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: process user command
MODULE tct100_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT100'.
*  OK_CODE = sy-ucomm.
    ok_code = ok_code100.
    PERFORM user_ok_tc USING    'TCT100'
                                'G_TCT100_ITAB'
                                'FLAG'
                       CHANGING ok_code.
    CLEAR:ok_code100,ok_code.
  ENDIF.
*  sy-ucomm = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code100.
    WHEN 'BAC' OR 'CAN'.
      PERFORM back_confirm.
      CLEAR ok_code100.
    WHEN 'CREATE'.
*    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*                  ID 'ACTVT' FIELD  '01'
*                  ID 'ACTVT' FIELD  '02'.
*
*    If sy-subrc <> 0.
*      message e124(zmm_oth).
*    Endif.

*Begin CR no: 30008546 MM Non-moving material workflow  CAB_ALOK
*perform DISABLE_CREATE. TYPE 'E'
           CLEAR ok_code100.
     MESSAGE e236(zmm_oth).
     exit.
*      g_mode = 'CRE'.
*      CLEAR ok_code100.
*End CR no: 30008546 MM Non-moving material workflow CAB_ALOK


    WHEN 'CHANGE'.
      g_mode = 'CHA'.
      CLEAR ok_code100.
    WHEN 'DISPLAY'.
      g_mode = 'DIS'.
      CLEAR ok_code100.
    WHEN 'DELETE'.
      g_mode = 'DEL'.
      CLEAR ok_code100.
    WHEN 'RELEASE'.
      g_mode = 'REL'.
      CLEAR ok_code100.
    WHEN 'APPROVE'.
      g_mode = 'APR'.
      CLEAR ok_code100.
    WHEN 'ATTACH'.
      PERFORM attach_file.
      CLEAR ok_code100.
    WHEN 'LIST'.
      PERFORM list_file.
      CLEAR ok_code100.
    WHEN 'DELATTACH'.
      PERFORM del_attachment.
      clear ok_code100.
    WHEN 'HELP'.
      PERFORM guidelines.
      CLEAR ok_code100.
    WHEN 'CIRCULAR'.
      PERFORM circular.
      CLEAR ok_code100.
    WHEN 'UNBLOCK'.
      PERFORM unblock_matcode.
      IF g_mesg <> 'X'.
        message i126(zmm_oth).
      ENDIF.
      IF zmm_nmblkcdhd_st-status = 'C'.
        PERFORM send_mail_to_reqn.
      ENDIF.
*      CLEAR okcode_100.
*      if g_choice = 'J'.
*       clear g_choice.
*       PERFORM clear_var.
*       leave program.
*      endif.
    WHEN 'SAV'.
      PERFORM save_request.
*      PERFORM clear_var.
*      CLEAR okcode_100.
    WHEN 'CORRES'.
      CLEAR ok_code100.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
    WHEN 'REPORT'.
      clear ok_code100.
      SUBMIT ZMM_MAT_NMCODES VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_uebernehmen1 INPUT.
  gv_xthead_updkz = 0.

  CALL METHOD gv_text_editor1->get_text_as_stream
       IMPORTING
            text       =  lt_text_table1
            is_modified = gv_xthead_updkz
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
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
     ( g_mode = 'APR' ).
    CALL METHOD gv_text_editor2->get_text_as_stream
         IMPORTING
              text       =  lt_text_table2
              is_modified = gv_xthead_updkz
         EXCEPTIONS
              error_dp               = 1
              error_cntl_call_method = 2
              OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
         TABLES
              text_stream = lt_text_table2
              itf_text    = tlinetab2.
  ENDIF.

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
  DATA : l_hd_reqno LIKE zmm_nmblkcdhd,
         l_result type c,
         l_ans TYPE c.
***Intializing**********
  CLEAR:  g_hd_copied,g_tct100_copied,g_result.
  REFRESH: tlinetab1,tlinetab2,lines_cors.
  REFRESH: lt_text_table1,lt_text_table2.

*************************
  IF g_mode = 'CHA'.

    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
           WHERE reqno = zmm_nmblkcdhd_st-reqno.
*** Check for deletion.
    IF l_hd_reqno-lvorm = 'X'.
      MESSAGE i087(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
      LEAVE TO SCREEN 100.
    ENDIF.
***To check for original creator........
    IF l_hd_reqno-reqcpf <> sy-uname.
      MESSAGE e096(zmm_oth) WITH l_hd_reqno-reqcpf.
    ENDIF.
*** To check for C/AC/IC request.
    IF l_hd_reqno-status = 'C' OR
       l_hd_reqno-status = 'AC'.
      MESSAGE e104(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
    ENDIF.
    IF l_hd_reqno-status = 'IC'.
      MESSAGE e112(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
    ENDIF.

***Check for Release reset
    IF l_hd_reqno-relflag = 'X' .
***Change option
     CALL FUNCTION 'K_KKB_POPUP_RADIO2'
        EXPORTING
          i_title         =  'Change Options'
          i_text1         =  'Attach Doc (No release reset)'
          i_text2         =  'Any Change (Release reset)'
          i_default       =  1
       IMPORTING
         I_RESULT        =   g_result
       EXCEPTIONS
           CANCEL        = 1
           OTHERS        = 2.
      IF sy-subrc <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF g_result = '2'.
        g_relflag = 'J'.
        zmm_nmblkcdhd_st-relflag = ''.
        zmm_nmblkcdhd_st-appflag = ''.
      ENDIF.
    ENDIF.
  ELSEIF g_mode = 'REL'.
    CLEAR l_hd_reqno.
    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
          WHERE reqno = zmm_nmblkcdhd_st-reqno.
    IF sy-subrc = 0.
      IF l_hd_reqno-reqcpf <> sy-uname.
        MESSAGE e107(zmm_oth) WITH l_hd_reqno-reqcpf.
      ENDIF.
      IF NOT l_hd_reqno-relflag IS INITIAL.
        MESSAGE e125(zmm_oth) WITH l_hd_reqno-reqno.
      ENDIF.
    ENDIF.

  ELSEIF g_mode = 'APR'.
****authority Check
    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                  ID 'FRGCO' FIELD 'L1'. "#EC *

    IF sy-subrc <> 0.
      MESSAGE e123(zmm_oth).
    ENDIF.
****checking the release of the request.
    CLEAR l_hd_reqno.
    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
          WHERE reqno = zmm_nmblkcdhd_st-reqno.
    IF sy-subrc = 0.
      IF l_hd_reqno-relflag = ''.
        MESSAGE i120(zmm_oth) WITH l_hd_reqno-reqno.
        PERFORM clear_var.
*        leave to screen 0.
      ENDIF.
      IF NOT l_hd_reqno-appflag IS INITIAL.
        MESSAGE e037(zmm_oth) WITH l_hd_reqno-reqno.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                 " check_reqno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_plant INPUT.
  DATA : l_werks LIKE t001w-werks.
  IF NOT zmm_nmblkcdhd_st-werks IS INITIAL.
    SELECT SINGLE werks INTO l_werks FROM t001w
           WHERE werks = zmm_nmblkcdhd_st-werks.
    IF sy-subrc <> 0.
      MESSAGE e033(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_tel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.
  DATA : tel_len TYPE i.
  tel_len = strlen( zmm_nmblkcdhd_st-tel ).
  IF  zmm_nmblkcdhd_st-tel CN ' 0123456789-'.
    MESSAGE e059(zmm_oth).
  ELSE.
    IF tel_len < 7.
      MESSAGE e060(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_tel  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_user INPUT.
  DATA: l_user LIKE soud3,
        l_userfld(40) type c.
  Clear: l_user, l_userfld.

  get cursor field l_userfld.

  case l_userfld.
    when 'ZMM_NMBLKCDHD_ST-REQCPF'.
      l_user = zmm_nmblkcdhd_st-reqcpf.
    when 'ZMM_NMBLKCDHD_ST-RELBY'.
      l_user = zmm_nmblkcdhd_st-relby.
    when 'ZMM_NMBLKCDHD_ST-APPBY'.
      l_user = zmm_nmblkcdhd_st-appby.
  endcase.
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

ENDMODULE.                 " show_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.
ENDMODULE.                 " USER_COMMAND_0103  INPUT

AT USER-COMMAND.
  DATA : l_okcode103 LIKE sy-ucomm.
  CLEAR l_okcode103.

  l_okcode103 = sy-ucomm.
  IF g_mode = 'REL'.
    CASE l_okcode103.
      WHEN 'AGREE'.
        g_rel = 'Y'.
        CLEAR l_okcode103.
        LEAVE TO SCREEN 0.
      WHEN 'DISAGREE'.
        g_rel = 'N'.
        CLEAR l_okcode103.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Module  get_details  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_details INPUT.
  DATA: l_objek LIKE ausp-objek,
        l100_blkdt LIKE zmm_nmblkcddt.

*  SELECT SINGLE objek INTO l_objek FROM ausp
*         WHERE objek = zmm_nmblkcddt-matcode
*         AND   atinn = ( SELECT atinn FROM cabn
*                                WHERE atnam = 'Z_ONGC_REASON' )
*         AND   klart = '001'
*         AND   atwrt = 'NM'.
SELECT SINGLE ZZMBPR FROM MARA INTO l_objek
  WHERE MATNR = zmm_nmblkcddt-matcode
  AND ZZMBPR = 'NM'.


  IF sy-subrc <> 0.
    MESSAGE e090(zmm_oth).
  ELSE.
    zmm_nmblkcddt-mstae = 'NM'.
  ENDIF.
  SELECT MAKTX INTO ZMM_NMBLKCDDT-MATDESC
 FROM MAKT UP TO 1 ROWS WHERE MATNR = ZMM_NMBLKCDDT-MATCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  SELECT SINGLE meins INTO
               zmm_nmblkcddt-uom
         FROM mara
         WHERE matnr = zmm_nmblkcddt-matcode.

***Checking for the same code in other request
  IF g_mode = 'CRE'.
    SELECT * INTO L100_BLKDT FROM ZMM_NMBLKCDDT UP TO 1 ROWS
 WHERE MATCODE = G_TCT100_WA-MATCODE AND UNBLKBY = ''
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tct100_wa-matcode l100_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO L100_BLKDT FROM ZMM_NMBLKCDDT UP TO 1 ROWS
 WHERE REQNO <> ZMM_NMBLKCDHD_ST-REQNO AND MATCODE = G_TCT100_WA-MATCODE AND UNBLKBY = ''
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tct100_wa-matcode l100_blkdt-reqno.
    ENDIF.
  ENDIF.


ENDMODULE.                 " get_details  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  PERFORM confirm_exit.
ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_code INPUT.
  DATA : l_matcode LIKE zmm_matblock_dt-matcode.

  l_matcode = zmm_nmblkcddt-matcode.
  SET PARAMETER ID 'MAT' FIELD l_matcode.
  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " show_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME1 INPUT.
CLEAR NAME1.
IF NOT ZMM_NMBLKCDHD_ST-REQCPF IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME1
  WHERE PERNR = ZMM_NMBLKCDHD_ST-REQCPF.
  ENDIF.
ENDMODULE.                 " SHOW_NAME1  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME2 INPUT.
CLEAR NAME2.
IF NOT ZMM_NMBLKCDHD_ST-RELBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME2
  WHERE PERNR = ZMM_NMBLKCDHD_ST-RELBY.
  ENDIF.
ENDMODULE.                 " SHOW_NAME2  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME3 INPUT.
CLEAR NAME3.
IF NOT ZMM_NMBLKCDHD_ST-APPBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME3
  WHERE PERNR = ZMM_NMBLKCDHD_ST-APPBY.
  ENDIF.
ENDMODULE.                 " SHOW_NAME3  INPUT

*--- INCLUDE: MZMMNMUNBLKO01 ---*
***INCLUDE MZMMNMUNBLKO01 .
*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tct100_init OUTPUT.
  IF g_tct100_copied IS INITIAL.
*&spwizard: copy ddic-table 'ZMM_NMBLKCDDT'
*&spwizard: into internal table 'g_TCT100_itab
   IF g_mode <> 'CRE'.
    SELECT * FROM zmm_nmblkcddt
       INTO CORRESPONDING FIELDS
       OF TABLE g_tct100_itab
    where reqno = zmm_nmblkcdhd_st-reqno.
   ENDIF.
    g_tct100_copied = 'X'.
    REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
  ENDIF.
*break cab_subodhk.
  if ( g_mode = 'CRE' or
       g_mode = 'CHA' ) and sy-ucomm = 'SEND'.
     if not g_tx100_itab[] is initial.
       describe table g_tx100_itab[] lines g_txlines.
     endif.
     describe table g_tct100_itab lines g_tctlines.
**Setting number of lines.
     if g_tctlines = 0.
       tct100-lines = g_txlines.
     else.
       tct100-lines = g_txlines + g_tctlines.
     endif.
***
     perform get_data_from_tx100.
     clear sy-ucomm.
  endif.
  sort g_tct100_itab ascending by matcode descending srno.
  delete adjacent duplicates from g_tct100_itab comparing matcode.
  sort g_tct100_itab ascending by srno.
ENDMODULE.

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tct100_move OUTPUT.
 DATA : l_srno TYPE i,
        l_labst LIKE mard-labst,
        l_spmon like s034-spmon,
        l_mm(2) type n,
        l_yy(4) type n.
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    IF NOT g_tct100_wa-matcode IS INITIAL.
      CLEAR: l_srno.
      IF g_tct100_wa-srno = 0.
        PERFORM get_nextsrno.
        MOVE l_srno TO g_tct100_wa-srno.
        MODIFY g_tct100_itab FROM g_tct100_wa
        INDEX tct100-current_line TRANSPORTING srno.
      ENDIF.
    ENDIF.
*  ENDIF.
***Plant Stock***********
  IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tct100_wa-plant_stk
      WHERE werks = zmm_nmblkcdhd_st-werks
      AND   matnr = g_tct100_wa-matcode.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING plant_stk.
  ENDIF.
***ONGC Stock***********
  IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( labst ) FROM mard INTO g_tct100_wa-ongc_stk
    WHERE matnr = g_tct100_wa-matcode.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING ongc_stk.
  ENDIF.
****Plant Consumption **********
  Clear: l_mm,l_yy.
  l_mm = sy-datum+4(2).
   if l_mm < '04'.
     l_yy = sy-datum+0(4) - 1.
    concatenate l_yy '04' into l_spmon.
   else.
    concatenate sy-datum+0(4) '04'  into l_spmon.
   endif.
   IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-cmgvbr
      WHERE werks = zmm_nmblkcdhd_st-werks
      AND   matnr = g_tct100_wa-matcode
      AND   spmon GE l_spmon.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING cmgvbr.
   ENDIF.
****ONGC Consumption *************
   IF NOT g_tct100_wa-matcode IS INITIAL.
    SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-ongc_cons
      WHERE matnr = g_tct100_wa-matcode
      and   spmon GE l_spmon.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING ongc_cons.
   ENDIF.
  ENDIF.               "CRE or CHA
  MOVE-CORRESPONDING g_tct100_wa TO zmm_nmblkcddt.
ENDMODULE.

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tct100_get_lines OUTPUT.
  g_tct100_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : l_mode(3) TYPE c,
         l_reqno(10) TYPE c.
*****To set the mode to 'BLK'.
  IMPORT wa_mode TO l_mode FROM MEMORY ID 'CODUNBLK'.
  IF sy-subrc = 0.
    g_mode = l_mode.
  ENDIF.
  FREE MEMORY ID 'CODUNBLK'.
*****
  PERFORM fill_sttab.
  SET PF-STATUS 'OPTNS' EXCLUDING it_tab1.
  CASE g_mode.
    WHEN 'CRE'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Create Request'.
    WHEN 'CHA'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Change Request'.
    WHEN 'DIS'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Display Request'.
    WHEN 'DEL'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Delete Request'.
    WHEN 'REL'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Release Request'.
    WHEN 'APR'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Approve Request'.
    WHEN OTHERS.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.
  ENDCASE.
***
  IF g_mode = 'BLK'.
    GET PARAMETER ID 'ZDNO' FIELD l_reqno.
    zmm_nmblkcdhd_st-reqno = l_reqno.
  ENDIF.

*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT
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
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
     ( g_mode = 'APR' ).

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
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
     ( g_mode = 'APR' ).

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
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS 'STAT105'.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr_attr_header  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr_attr_header OUTPUT.
  CASE g_mode.
    WHEN ''.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN 'CRE'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO'  OR
           screen-name = 'ZMM_NMBLKCDHD_ST-STATUS' OR
           screen-name = 'ZMM_NMBLKCDHD_ST-RELFLAG' OR
*code added by CAB_AMITMOZA  CR:30001048  WR:RD1K983014
           screen-name = 'ZMM_NMBLKCDHD_ST-TEL' OR
*code END by CAB_AMITMOZA  CR:30001048
           screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

*code added by CAB_AMITMOZA  CR:30001048  WR:RD1K983014
        SELECT * FROM  PA9205 APPENDING
      CORRESPONDING FIELDS OF TABLE IT_9205
      WHERE Pernr = SY-UNAME AND
            Subty = '01' AND
            Endda = '99991231' .
      clear ZMM_NMBLKCDHD_ST-TEL.
IF SY-SUBRC = 0.          "" It means PHONE NO. HAS BEEN FOUND

  SORT  IT_9205 By Begda DESCENDING  .

  READ TABLE It_9205 INTO Wa_9205 INDEX 1  .

  CONCATENATE '91' Wa_9205-ZPHONE+1(10) INTO  ZMM_NMBLKCDHD_ST-TEL .
  ENDIF.
*code END by CAB_AMITMOZA  CR:30001048
      ENDLOOP.
    WHEN 'CHA'.
      IF zmm_nmblkcdhd_st-reqno IS INITIAL.
        LOOP AT SCREEN.
          IF screen-name <> 'ZMM_NMBLKCDHD_ST-REQNO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
         IF g_result = '2'.
          IF SCREEN-GROUP1 = 'MOD' OR
             SCREEN-GROUP1 = 'PAG' OR
             SCREEN-GROUP1 = 'MAR' OR
             SCREEN-GROUP1 = 'LOD' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
             screen-name = 'PB_CORS' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-WERKS' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-ADDR1' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-TEL'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
         ELSE.
           screen-input = 0.
           MODIFY SCREEN.
         ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN 'REL'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
           screen-name = 'ZMM_NMBLKCDHD_ST-RELFLAG' OR
           screen-name = 'PB_CORS' OR
           screen-group1 = 'PAG'.
          screen-input = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'APR'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
           screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG' OR
           screen-name = 'PB_CORS' OR
           screen-group1 = 'PAG'.
          screen-input = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
           screen-name = 'PB_CORS' OR
           screen-group1 = 'PAG' OR
           screen-group1 = 'MAR'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
        IF g_mode = 'BLK'.
          IF screen-name = 'ZMM_NMBLKCDHD_ST-STATUS'.
            IF zmm_NMBLKCDHD_st-status = 'N' OR
               zmm_NMBLKCDHD_st-status = 'IC' OR
               zmm_NMBLKCDHD_st-status = 'IR'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
          IF screen-name = 'T_TX1' OR
             screen-name = 'T_TX2'.
             screen-invisible = '1'.
             modify screen.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " scr_attr_header  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_header_data output.
 IF NOT zmm_nmblkcdhd_st-reqno IS INITIAL.
*    IF g_hd_copied IS INITIAL.
      IF g_mode <> 'CRE' and g_hd_copied is initial.
        if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' )
                              OR ( g_mode = 'BLK' ).
*            perform lock_reqhd.
        endif.
        SELECT SINGLE * FROM zmm_nmblkcdhd
        INTO CORRESPONDING FIELDS OF zmm_nmblkcdhd_st
            WHERE reqno = zmm_nmblkcdhd_st-reqno.
***code added by CAB_AMITMOZA CR:30001048  WR:RD1K983014
         CLEAR : NAME1 , NAME2 , NAME3 .
IF NOT ZMM_NMBLKCDHD_ST-REQCPF IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME1
  WHERE PERNR = ZMM_NMBLKCDHD_ST-REQCPF.
  ENDIF.
  IF NOT ZMM_NMBLKCDHD_ST-RELBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME2
  WHERE PERNR = ZMM_NMBLKCDHD_ST-RELBY.
  ENDIF.
  IF NOT ZMM_NMBLKCDHD_ST-APPBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME3
  WHERE PERNR = ZMM_NMBLKCDHD_ST-APPBY.
  ENDIF.
**CODE END BY CAB_AMITMOZA CR:30001048  WR:RD1K983014

        IF g_relflag = 'J'.
          zmm_nmblkcdhd_st-relflag = ''.
          zmm_nmblkcdhd_st-appflag = ''.
          CLEAR g_relflag.
        ENDIF.
        g_hd_copied = 'X'.
      ENDIF.
*    ENDIF.
  ENDIF.
  PERFORM get_correspondense.

endmodule.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_0103 output.
*  SET PF-STATUS 'STAT_REL'.
*  SET TITLEBAR 'xxx'.

endmodule.                 " STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module write_certificate output.
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

endmodule.                 " write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT100_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TCT100_change_field_attr output.
CASE g_mode.
    WHEN 'CRE' OR 'CHA'.
      LOOP AT SCREEN.
        IF screen-name = 'ZMM_NMBLKCDDT-ERRCD'.
           screen-input  = '0'.
           MODIFY SCREEN.
        ENDIF.
        IF NOT zmm_nmblkcdhd_st-werks IS INITIAL AND
           NOT zmm_nmblkcdhd_st-tel IS INITIAL.
          IF NOT ZMM_NMBLKCDDT-matcode IS INITIAL.
            IF zmm_nmblkcdhd_st-status = 'IR'.
              IF ZMM_NMBLKCDDT-UNBLKBY <> ''.
                screen-input = '0'.
                MODIFY SCREEN.
                if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
                   screen-INTENSIFIED = '1'.
                   MODIFY SCREEN.
                endif.
              ENDIF.
              IF screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
                screen-input = '0'.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.
            if screen-name = 'G_TCT100_WA-FLAG'.
             screen-input     = '1'.
             MODIFY SCREEN.
            endif.
          ENDIF.
          IF ZMM_NMBLKCDDT-errcd = 'M'.
           if screen-name <> 'G_TCT100_WA-FLAG'.
             screen-input     = '0'.
             MODIFY SCREEN.
           endif.
          ENDIF.
        ELSE.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF g_result = '1'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'DIS' OR 'DEL' OR 'REL' OR 'APR'.
      LOOP AT SCREEN.
        screen-input = '0'.
        MODIFY SCREEN.
        IF G_TCT100_WA-unblkby <> ''.
          if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
            screen-INTENSIFIED = '1'.
            MODIFY SCREEN.
          endif.
        ENDIF.
      ENDLOOP.
    WHEN 'BLK'.
      LOOP AT SCREEN.
        IF G_TCT100_WA-UNBLKBY <> ''.
          screen-input = '0'.
          MODIFY SCREEN.
          if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
            screen-INTENSIFIED = '1'.
            MODIFY SCREEN.
          endif.
        ELSE.
          if screen-name = 'G_TCT100_WA-FLAG' OR
             screen-name = 'ZMM_NMBLKCDDT-ERRCD'.
             screen-input     = '1'.
             MODIFY SCREEN.
          else.
             screen-input     = '0'.
             MODIFY SCREEN.
          endif.
        ENDIF.
        IF zmm_nmblkcdhd_st-status = 'C' OR
           zmm_nmblkcdhd_st-status = 'AC'.
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

endmodule.                 " TCT100_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  display_message  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module display_message output.
Data:l_100msg type t_tct100.
IF G_ERRCD_M IS INITIAL.
 Read table g_tct100_itab into l_100msg with key errcd = 'M'.
 if sy-subrc = 0.
   G_ERRCD_M = 'X'.
   message i122(zmm_oth).
 endif.

ENDIF.
* clear g_errstat.

endmodule.                 " display_message  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISABLE_CREATE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISABLE_CREATE OUTPUT.

        LOOP AT SCREEN.
          IF screen-name = 'ZMM_NMBLKCDHD_ST-REQNO'  OR
             screen-name = 'ZMM_NMBLKCDHD_ST-STATUS' OR
             screen-name = 'G_REL_FLAG' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-TEL' OR
             screen-name = 'ZMM_NMBLKCDHD_ST-APPFLAG'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

ENDMODULE.                 " DISABLE_CREATE  OUTPUT

*--- INCLUDE: MZMMNMUNBLKTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMNMUNBLKTOP                                              *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMNMUNBLK.

Tables:ZMM_NMBLKCDHD_ST,ZMM_NMBLKCDHD,ZMM_NMBLKCDDT,
       STXH,AUSP,CABN,KLAH,KSSK,srrelroles,PA9205.
*************Types******************************************************
Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

Types: Begin of t_tx100,
         matcode like mara-matnr,
         res_nm like zmm_nmblkcddt-res_nm,
       End of t_tx100.
***&spwizard: data declaration for tablecontrol 'TCT100'
*&spwizard: definition of ddic-table
*tables:   ZMM_NMBLKCDDT.

*&spwizard: type for the data of tablecontrol 'TCT100'
types: begin of t_TCT100,
         SRNO like ZMM_NMBLKCDDT-SRNO,
         MATCODE like ZMM_NMBLKCDDT-MATCODE,
         mstae   like ZMM_NMBLKCDDT-mstae,
         ERRCD like ZMM_NMBLKCDDT-ERRCD,
         MATDESC like ZMM_NMBLKCDDT-MATDESC,
         PLANT_STK like ZMM_NMBLKCDDT-PLANT_STK,
         ONGC_STK like ZMM_NMBLKCDDT-ONGC_STK,
         UOM like ZMM_NMBLKCDDT-UOM,
         RES_NM like ZMM_NMBLKCDDT-RES_NM,
         CMGVBR like ZMM_NMBLKCDDT-CMGVBR,
         ongc_cons like ZMM_NMBLKCDDT-ongc_cons,
         UNBLKBY like ZMM_NMBLKCDDT-UNBLKBY,
         UNBLKDT like ZMM_NMBLKCDDT-UNBLKDT,
         flag,       "flag for mark column
       end of t_TCT100.

*&spwizard: internal table for tablecontrol 'TCT100'
data:     g_TCT100_itab   type t_TCT100 occurs 0,
          g_TCT100_wa     type t_TCT100. "work area
data:     g_TCT100_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT100' itself
controls: TCT100 type tableview using screen 0100.

*&spwizard: lines of tablecontrol 'TCT100'
data:     g_TCT100_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
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

**************Structure and Working Area *********************
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
End of g_linefrto.
Data : wa_nmblkcddt like zmm_nmblkcddt.
Data : g_cores_sender like tline-tdline.
DATA: ist_textid like thead,
      wa_textid  like thead,
      ist_textid_items like thead occurs 0.
Data: g_ex100_wa type t_tx100.
Data  g_att_files_wa like SWOTOBJID.
DATA  g_att_files like table of SWOTOBJID.

**************Internal Tables**********************************
Data: it_tab1 type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.
Data: g_linefrto_itab like table of g_linefrto.
Data: itab_nmblkcddt like table of zmm_nmblkcddt with header line.
Data: g_itab_del100  type t_tct100 OCCURS 0.
Data: g_tx100_itab type t_tx100 occurs 0,
      g_ex100_itab type t_tx100 occurs 0.
data : exclude_tab like soxet occurs 0 with header line.
**************Global data**************************************
Data : g_mode(3)  type c,
      ok_code100 like sy-ucomm.
Data : g_cors type c,
       g_choice type c,
       g_rel type c,
       g_app type c,
       g_line132(132) type c,
       g_hd_copied type c,
       g_relflag type c,
       G_REQNO(10) type c,
       g_request_no(10) type c.
data  g_txlines type i.
data:  g_recstat, g_errstat,G_ERRCD_M.
data  g_tctlines type i.
data  g_result.
data  g_mesg.
data  g_attach.

 CONSTANTS: g_c_asc TYPE char10 value 'ASC'.
**CODE ADDED BY CAB_AMITMOZA  CR:30001048  WR:RD1K983014
 DATA   :It_9205 TYPE  STANDARD TABLE OF  PA9205,
        Wa_9205 TYPE PA9205 .

 DATA : NAME1 TYPE EMNAM,
        NAME2 TYPE EMNAM,
        NAME3 TYPE EMNAM.
**CODE END BY CAB_AMITMOZA CR:30001048  WR:RD1K983014
