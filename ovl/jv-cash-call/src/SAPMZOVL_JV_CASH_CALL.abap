*--- MAIN PROGRAM: SAPMZOVL_JV_CASH_CALL ---*
*&---------------------------------------------------------------------*
*& Modulpool  SAPMZOVL_JV_PRG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE sapmzovl_jv_cc_top.
INCLUDE sapmzovl_jv_cc_sub.
INCLUDE sapmzovl_jv_cc_pbo.
INCLUDE sapmzovl_jv_cc_pai.

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

*--- INCLUDE: BCSEV=========================TT ---*

*--- INCLUDE: CL_ABAP_CHAR_UTILITIES========CU ---*
"! Some elementary utilities for processing of characters
class CL_ABAP_CHAR_UTILITIES definition
  public
  final
  create private .

*"* public components of class CL_ABAP_CHAR_UTILITIES
*"* do not include other source files here!!!
public section.

  types:
    TY_NUMBER_FORMAT type n length 4 .

  "! You can write this byte sequence into a type X or XSTRING container to indicate that
  "! the byte order in the container is little-endian.
  constants BYTE_ORDER_MARK_LITTLE type ABAP_BYTE_ORDER_MARK value 'FFFE' ##NO_TEXT.
  "! You can write this byte sequence into a type X or XSTRING container to indicate that
  "! the byte order in the container is big-endian.
  constants BYTE_ORDER_MARK_BIG type ABAP_BYTE_ORDER_MARK value 'FEFF' ##NO_TEXT.
  "! You can write this byte sequence into a type X or XSTRING container to indicate that
  "! the encoding in the container is UTF-8.
  constants BYTE_ORDER_MARK_UTF8 type ABAP_BYTE_ORDER_UTF8 value 'EFBBBF' ##NO_TEXT.
  "! CHARSIZE is the factor by which you have to multiply the declared length of a type C field
  "! to obtain the size of the field in bytes. In the current release, CHARSIZE is always 2.
  constants CHARSIZE type I value %_CHARSIZE ##NO_TEXT.
  "! The current byte order ('B' for big-endian or 'L' for little-endian, depending on the
  "! operating system of the application server).
  constants ENDIAN type ABAP_ENDIAN value %_ENDIAN ##NO_TEXT.
  "! MINCHAR and MAXCHAR can be used in binary comparisons, e.g., IF with the operators
  "! <, >, <=, >=, BETWEEN and the statement SORT without AS TEXT. Do not try to convert
  "! MINCHAR or MAXCHAR to upper case and do not use operations that implicitly convert to
  "! upper case, such as SEARCH, CS, NS, CP, or NP. Do not use MINCHAR and MAXCHAR in
  "! code page conversions. Some software components and UI technologies treat MINCHAR as
  "! the end of a text field.
  constants MINCHAR type ABAP_CHAR1 value %_MINCHAR ##NO_TEXT.
  "! See MINCHAR.
  constants MAXCHAR type ABAP_CHAR1 value %_MAXCHAR ##NO_TEXT.
  "! Tab character in the system character set. Most UI technologies do not display this character properly.
  constants HORIZONTAL_TAB type ABAP_CHAR1 value %_HORIZONTAL_TAB ##NO_TEXT.
  "! Vertical tab stop character in the system character set. Most UI technologies do not display this character properly.
  constants VERTICAL_TAB type ABAP_CHAR1 value %_VERTICAL_TAB ##NO_TEXT.
  "! This character serves as an end of line character in the system character set.
  "! Most UI technologies do not display this character properly.
  constants NEWLINE type ABAP_CHAR1 value %_NEWLINE ##NO_TEXT.
  "! This attribute contains a CR/LF pair (Carriage Return/Line Feed) in the system character set.
  "! Most UI technologies do not display this character properly.
  constants CR_LF type ABAP_CR_LF value %_CR_LF ##NO_TEXT.
  "! Form feed character in the system character set. Most UI technologies do not display this character properly.
  constants FORM_FEED type ABAP_CHAR1 value %_FORMFEED ##NO_TEXT.
  "! Backspace character in system character set. Most UI technologies do not display this character properly.
  constants BACKSPACE type ABAP_CHAR1 value %_BACKSPACE ##NO_TEXT.

  "! For given endian ('L' or 'B'), get the number format.
  class-methods ENDIAN_TO_NUMBER_FORMAT
    importing
      !ENDIAN type ABAP_ENDIAN
    returning
      value(NUMBER_FORMAT) type TY_NUMBER_FORMAT .

  "! For given number format, get the endian ('L' or 'B').
  class-methods NUMBER_FORMAT_TO_ENDIAN
    importing
      !NUMBER_FORMAT type TY_NUMBER_FORMAT
    returning
      value(ENDIAN) type ABAP_ENDIAN .

  "! Returns a string that contains the white-space characters most commonly used.
  "! (Some less commonly used space characters are not returned by this method.)
  class-methods GET_SIMPLE_SPACES_FOR_CUR_CP
    returning
      value(S_STR) type STRING .

  "! Returns ABAP_TRUE if the parameter VAL starts with the second half of a UTF-16 surrogate pair,
  "! i.e., with a 16-bit unit in the range DC00 .. DFFF (hexadecimal).
  "! Note: The built-in function charlen returns 2 if its parameter starts with a complete UTF-16 surrogate pair.
  "! (A UTF-16 surrogate pair consists of two 16-bit units, i.e. 4 bytes, that form one UTF-16 character.
  "! Most characters need only 2 bytes.)
  class-methods STARTS_WITH_BROKEN_SURROGATE
    importing
      !VAL type CSEQUENCE
    returning
      value(RET) type ABAP_BOOL .

  "! Returns ABAP_TRUE if the parameter VAL ends with the first half of a UTF-16 surrogate pair,
  "! i.e., with a 16-bit unit in the range D800 .. DBFF (hexadecimal).
  class-methods ENDS_WITH_BROKEN_SURROGATE
    importing
      !VAL type CSEQUENCE
    returning
      value(RET) type ABAP_BOOL .

*--- INCLUDE: CL_BCOM_MIME==================CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_BCOM_MIME and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_BCOM_MIME_SINGLEPART=======CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_BCOM_MIME_SINGLEPART and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_BCS========================CU ---*
class CL_BCS definition
  public
  final
  create private .

public section.

  data SEND_REQUEST type ref to CL_SEND_REQUEST_BCS read-only .
  constants CP_PRIORITY_LOW type SO_SND_PRI value '9' ##NO_TEXT.
  constants CP_PRIORITY_NORMAL type SO_SND_PRI value '5' ##NO_TEXT.
  constants GC_OK type BCS_STATUS value 'I' ##NO_TEXT.
  constants GC_ERROR type BCS_STATUS value 'E' ##NO_TEXT.
  constants GC_TRANSIT type BCS_STATUS value 'T' ##NO_TEXT.
  constants GC_WAIT type BCS_STATUS value 'W' ##NO_TEXT.
  constants GC_FUTURE type BCS_STATUS value 'F' ##NO_TEXT.
  constants GC_RETRY type BCS_STATUS value 'R' ##NO_TEXT.
  constants GC_INCONS type BCS_STATUS value 'X' ##NO_TEXT.
  constants GC_DIRECT type BCS_STATUS value 'D' ##NO_TEXT.
  constants GC_UNKNOWN type BCS_STATUS value ' ' ##NO_TEXT.
  constants GC_DELETED type BCS_STATUS value 'M' ##NO_TEXT.
  constants GC_ERR_INTERN type BCS_STATUS value 'A' ##NO_TEXT.
  constants GC_ERR_CONNECT type BCS_STATUS value 'B' ##NO_TEXT.
  constants GC_ERR_EXTERN type BCS_STATUS value 'C' ##NO_TEXT.
  constants GC_MSGTY_ERROR type SYMSGTY value 'E' ##NO_TEXT.
  constants GC_MSGTY_INFO type SYMSGTY value 'I' ##NO_TEXT.
  constants GC_MSGTY_SUCCESS type SYMSGTY value 'S' ##NO_TEXT.

  methods ADD_RECIPIENT
    importing
      !I_RECIPIENT type ref to IF_RECIPIENT_BCS
      !I_EXPRESS type OS_BOOLEAN optional
      !I_COPY type OS_BOOLEAN optional
      !I_BLIND_COPY type OS_BOOLEAN optional
      !I_NO_FORWARD type OS_BOOLEAN optional
    raising
      CX_SEND_REQ_BCS .
  methods ASYNCHRONOUS
    returning
      value(RESULT) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods CHANGED_BY
    returning
      value(RESULT) type SO_CHO_NAM
    raising
      CX_SEND_REQ_BCS .
  methods CHANGE_DATE
    returning
      value(RESULT) type SO_DAT_CH
    raising
      CX_SEND_REQ_BCS .
  methods CHANGE_TIME
    returning
      value(RESULT) type SO_TIM_CH
    raising
      CX_SEND_REQ_BCS .
  methods CONSTRUCTOR
    importing
      value(I_SEND_REQUEST) type ref to CL_SEND_REQUEST_BCS
    raising
      CX_SEND_REQ_BCS .
  methods CREATE_LINK_TO_APP
    importing
      value(I_APP_INSTANCE) type SIBFLPOR
    raising
      CX_SEND_REQ_BCS .
  methods CREATE_LINK
    importing
      value(I_APPL_OBJECT) type BORIDENT
    raising
      CX_SEND_REQ_BCS .
  class-methods CREATE_PERSISTENT
    returning
      value(RESULT) type ref to CL_BCS
    raising
      CX_SEND_REQ_BCS .
  methods CREATION_DATE
    returning
      value(RESULT) type SO_DAT_CR
    raising
      CX_SEND_REQ_BCS .
  methods CREATION_TIME
    returning
      value(RESULT) type SO_TIM_CR
    raising
      CX_SEND_REQ_BCS .
  methods DELETE .
  methods DEQUEUE
    raising
      CX_SEND_REQ_BCS .
  methods DOCUMENT
    returning
      value(RESULT) type ref to IF_DOCUMENT_BCS
    raising
      CX_SEND_REQ_BCS .
  methods EDIT
    importing
      value(I_STARTING_AT_X) type SY-TABIX optional
      value(I_STARTING_AT_Y) type SY-TABIX optional
      value(I_ENDING_AT_X) type SY-TABIX optional
      value(I_ENDING_AT_Y) type SY-TABIX optional
      value(I_HIDE_NOTE) type OS_BOOLEAN optional
      value(I_EDIT_SUBJECT) type OS_BOOLEAN optional
      value(I_PROCESS_BY_BADI) type BCSY_FCODE optional
      value(I_BADI_FLTVAL) type BCSD_ATFLT optional
    raising
      CX_SEND_REQ_BCS
      CX_BCS .
  methods ENCRYPT
    returning
      value(RESULT) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods ENQUEUE
    raising
      CX_SEND_REQ_BCS .
  methods FORWARD
    returning
      value(RESULT) type ref to CL_BCS
    raising
      CX_SEND_REQ_BCS
      CX_DOCUMENT_BCS .
  class-methods GET_INSTANCE_BY_OID
    importing
      value(I_OID) type SYSUUID_X
    returning
      value(RESULT) type ref to CL_BCS
    raising
      CX_SEND_REQ_BCS .
  methods IS_EDITABLE
    returning
      value(RESULT) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods NOTE
    returning
      value(RESULT) type BCSY_TEXT
    raising
      CX_SEND_REQ_BCS .
  methods OID
    returning
      value(RESULT) type SYSUUID_X
    raising
      CX_SEND_REQ_BCS .
  methods ORIGINATOR
    returning
      value(RESULT) type ref to CL_SEND_REQUEST_BCS
    raising
      CX_SEND_REQ_BCS .
  methods PRIORITY
    returning
      value(RESULT) type SO_SND_PRI
    raising
      CX_SEND_REQ_BCS .
  methods RECIPIENTS
    returning
      value(RESULT) type BCSY_RE
    raising
      CX_SEND_REQ_BCS .
  methods REPLY
    returning
      value(RESULT) type ref to CL_BCS
    raising
      CX_SEND_REQ_BCS
      CX_DOCUMENT_BCS .
  methods REPLY_TO
    returning
      value(RESULT) type ref to IF_RECIPIENT_BCS
    raising
      CX_SEND_REQ_BCS .
  methods SEND
    importing
      !I_WITH_ERROR_SCREEN type OS_BOOLEAN default SPACE
    returning
      value(RESULT) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods SEND_WITHOUT_DIALOG
    exporting
      value(E_RECIPIENTS_WITH_ERROR) type BCSY_RE
      value(E_ORIG_RECS_WITH_ERROR) type BCSY_ERCP
      value(E_SENT_TO_ALL) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods SENDER
    returning
      value(RESULT) type ref to IF_SENDER_BCS
    raising
      CX_SEND_REQ_BCS .
  methods SET_ASYNCHRONOUS
    importing
      !I_ASYNCHRONOUS type OS_BOOLEAN .
  methods SET_DOCUMENT
    importing
      !I_DOCUMENT type ref to IF_DOCUMENT_BCS
    raising
      CX_SEND_REQ_BCS .
  methods SET_ENCRYPT
    importing
      !I_ENCRYPT type BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods SET_EXPIRES_ON
    importing
      value(I_EXPIRES_ON) type BCS_XPIRE .
  methods SET_NOTE
    importing
      !I_NOTE type BCSY_TEXT
    raising
      CX_SEND_REQ_BCS .
  methods SET_OWNER_APP
    importing
      value(I_OWNER_APP) type BCS_APPL .
  methods SET_PRIORITY
    importing
      !I_PRIORITY type SO_SND_PRI
    raising
      CX_SEND_REQ_BCS .
  methods SET_REPLY_TO
    importing
      !I_REPLY_TO type ref to IF_RECIPIENT_BCS
    raising
      CX_SEND_REQ_BCS .
  methods SET_SENDER
    importing
      !I_SENDER type ref to IF_SENDER_BCS
    raising
      CX_SEND_REQ_BCS .
  methods SET_SIGN
    importing
      !I_SIGN type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods SET_SIGNATURE_WORKFLOW
    importing
      !I_SIGNATURE_WORKFLOW type GUID_32
    raising
      CX_SEND_REQ_BCS .
  methods SET_STATUS_ATTRIBUTES
    importing
      value(I_REQUESTED_STATUS) type BCS_RQST
      value(I_STATUS_MAIL) type BCS_STML default 'E'
    raising
      CX_SEND_REQ_BCS .
  methods SET_STATUS_RECIPIENT
    importing
      value(I_STATUS_RECIPIENT) type ref to IF_RECIPIENT_BCS
    raising
      CX_SEND_REQ_BCS .
  methods SET_TRACE
    importing
      !I_TRACE type ref to CL_TRACE_BCS .
  class-methods SHORT_MESSAGE
    importing
      value(I_SUBJECT) type SOOD-OBJDES
      value(I_TEXT) type BCSY_TEXT optional
      value(I_RECIPIENTS) type BCSY_RE3 optional
      value(I_SENDER) type ref to IF_SENDER_BCS optional
      value(I_REPLYTO) type ref to IF_RECIPIENT_BCS optional
      value(I_TEXT_FLOATING) type OS_BOOLEAN optional
      value(I_ATTACHMENTS) type BCSY_IFDOC optional
      value(I_APPL_OBJECT) type BORIDENT optional
      value(I_STARTING_AT_X) type SY-TABIX optional
      value(I_STARTING_AT_Y) type SY-TABIX optional
      value(I_ENDING_AT_Y) type SY-TABIX optional
      value(I_ENDING_AT_X) type SY-TABIX optional
      value(I_ENCRYPT) type BCSD_ENCR optional
      value(I_SIGN) type BCSD_SIGN optional
      value(IV_VSI_PROFILE) type VSCAN_PROFILE optional
      value(IV_REQUESTED_STATUS) type BCS_RQST optional
      value(IV_STATUS_MAIL) type BCS_STML optional
    returning
      value(RESULT) type ref to CL_BCS
    raising
      CX_SEND_REQ_BCS
      CX_BCS .
  methods SIGN
    returning
      value(RESULT) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods SIGNATURE_WORKFLOW
    returning
      value(RESULT) type GUID_32 .
  methods STATE
    returning
      value(RESULT) type SR_STATE .
  methods STATUS_RECIPIENT
    returning
      value(RESULT) type ref to IF_RECIPIENT_BCS .
  methods SET_SEND_IMMEDIATELY
    importing
      value(I_SEND_IMMEDIATELY) type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  methods SET_KEEP_MIME
    importing
      !I_KEEP_MIME type OS_BOOLEAN
    raising
      CX_SEND_REQ_BCS .
  class-methods RELEASE_LINKS_TO_APP
    importing
      value(IT_APP_KEY_BOR) type TRL_BORID optional
      value(IT_APP_KEY_CLASS) type SIBFLPORT optional .
  class-methods USER_SECURITY_DEFAULTS
    exporting
      !EP_ENCRYPT type BCSD_ENCR
      !EP_SIGN type BCSD_SIGN .
  methods SET_MESSAGE_SUBJECT
    importing
      value(IP_SUBJECT) type STRING
    raising
      CX_SEND_REQ_BCS .
  methods SET_DISCLOSURE
    importing
      value(I_DISCLOSURE) type BCS_DISCL .
  methods GET_SR_STATUS
    exporting
      !EV_STATUS type C
      !EV_TEXT type NATXT .

*--- INCLUDE: CL_BINARY_RELATION============CU ---*
class CL_BINARY_RELATION definition
  public
  final
  create public .

public section.
*"* public components of class CL_BINARY_RELATION
*"* do not include other source files here!!!

  interfaces IF_LINK_SERVICE .
  interfaces IF_LINK_SERVICE_EVENTS .

  data GP_NO_BUFFER type FLAG value SPACE. "#EC NOTEXT .
  data GT_ROLE_OPTIONS type OBL_T_ROLT .
  data GT_RELATION_OPTIONS type OBL_T_RELT .

  class-events LINK_CREATED
    exporting
      value(EI_LINK) type ref to IF_BINREL_CL .
  class-events LINK_DELETED
    exporting
      value(EI_LINK) type ref to IF_BINREL_CL .

  methods CHECK_AVAILABLE
    importing
      !IO_BITEM type ref to CL_BROWSER_ITEM
    returning
      value(RP_RESULT) type FLAG .
  class-methods CHECK_OBJECT_IN_ROLE
    importing
      !IS_OBJECT type SIBFLPORB
      !IP_LOGSYS type LOGSYS optional
      !IP_ROLETYPE type OBLROLTYPE
      !IP_RELATION type OBLRELTYPE optional
      !IP_NO_BUFFER type FLAG default SPACE
    returning
      value(RS_ROLE) type OBL_S_ROLE
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods CREATE_LINK
    importing
      !IS_OBJECT_A type SIBFLPORB
      !IP_LOGSYS_A type LOGSYS optional
      !IS_OBJECT_B type SIBFLPORB
      !IP_LOGSYS_B type LOGSYS optional
      !IP_RELTYPE type OBLRELTYPE
      !IP_PROPNAM type OBLPROP optional
      !I_PROPERTY type ANY optional
    exporting
      !EP_LINK_ID type OBLGUID16
      !EO_PROPERTY type ref to OBJECT
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_MODEL_ERROR
      CX_OBL_INTERNAL_ERROR .
  class-methods DELETE_LINK
    importing
      !IS_OBJECT_A type SIBFLPORB
      !IP_LOGSYS_A type LOGSYS optional
      !IS_OBJECT_B type SIBFLPORB
      !IP_LOGSYS_B type LOGSYS optional
      !IP_RELTYPE type OBLRELTYPE
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods DELETE_PROPERTY
    importing
      !IP_LINK_ID type OBLGUID16
      !IP_RELATION type OBLRELTYPE
      !IP_PROPNAME type OBLPROP
    raising
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods GET_PROPERTY
    importing
      !IP_LINK_ID type OBLGUID16
      !IP_RELATION type OBLRELTYPE
      !IP_PROPNAME type OBLPROP
    exporting
      !E_PROPERTY type ANY
    raising
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods READ_LINKS
    importing
      !IS_OBJECT type SIBFLPORB
      !IP_LOGSYS type LOGSYS optional
      !IT_ROLE_OPTIONS type OBL_T_ROLT optional
      !IT_RELATION_OPTIONS type OBL_T_RELT optional
      !IP_NO_BUFFER type FLAG default SPACE
    exporting
      !ET_LINKS type OBL_T_LINK
      !ET_ROLES type OBL_T_ROLE
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods READ_LINKS_OF_BINREL
    importing
      !IS_OBJECT type SIBFLPORB
      !IP_LOGSYS type LOGSYS optional
      !IP_RELATION type OBLRELTYPE
      !IP_ROLE type OBLROLTYPE optional
      !IP_PROPNAM type OBLPROP optional
      !IP_NO_BUFFER type FLAG default SPACE
    exporting
      !ET_LINKS type OBL_T_LINK
      !ET_ROLES type OBL_T_ROLE
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods READ_LINKS_OF_BINRELS
    importing
      !IS_OBJECT type SIBFLPORB
      !IP_LOGSYS type LOGSYS optional
      !IT_RELATION_OPTIONS type OBL_T_RELT
      !IP_ROLE type OBLROLTYPE optional
      !IP_PROPNAM type OBLPROP optional
      !IP_NO_BUFFER type FLAG default SPACE
    exporting
      !ET_LINKS type OBL_T_LINK
      !ET_ROLES type OBL_T_ROLE
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods READ_NETWORK
    importing
      !IS_OBJECT type SIBFLPORB
      !IP_LOGSYS type LOGSYS optional
      !IT_ROLE_OPTIONS type OBL_T_ROLT optional
      !IT_RELATION_OPTIONS type OBL_T_RELT optional
      !IP_MAX_DEPTH type I default 5
      !IP_NO_BUFFER type FLAG default SPACE
    exporting
      !ET_LINKS type OBL_T_LINK
      !ET_ROLES type OBL_T_ROLE
    raising
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  class-methods SET_PROPERTY
    importing
      !IP_LINK_ID type OBLGUID16
      !IP_RELATION type OBLRELTYPE
      !IP_PROPNAME type OBLPROP
      !I_PROPERTY type ANY
    returning
      value(RO_PROPERTY) type ref to OBJECT
    raising
      CX_OBL_INTERNAL_ERROR
      CX_OBL_MODEL_ERROR .
  methods CONSTRUCTOR
    importing
      !IT_ROLE_OPTIONS type OBL_T_ROLT optional
      !IT_RELATION_OPTIONS type OBL_T_RELT optional
      !IP_BROWSER type FLAG default 'X' .
  class-methods REFRESH_LINKS .
  class-methods READ_LINKS_OF_OBJECTS
    importing
      !IT_OBJECTS type SIBFLPORBT
      !IP_LOGSYS type LOGSYS optional
      !IT_ROLE_OPTIONS type OBL_T_ROLT optional
      !IT_RELATION_OPTIONS type OBL_T_RELT optional
      !IP_NO_BUFFER type FLAG default SPACE
    exporting
      !ET_LINKS_A type OBL_T_LINK
      !ET_LINKS_B type OBL_T_LINK
    raising
      CX_OBL_MODEL_ERROR
      CX_OBL_PARAMETER_ERROR
      CX_OBL_INTERNAL_ERROR .
  type-pools SOBL .
  class CL_OBL_INTERFACE_FACTORY definition load .
  class CL_OBL_MODEL_FACTORY definition load .

*--- INCLUDE: CL_BROWSER_ITEM===============CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_BROWSER_ITEM and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_CAM_ADDRESS_BCS============CU ---*
class CL_CAM_ADDRESS_BCS definition
  public
  final
  create public

  global friends CB_CAM_ADDRESS_BCS .

*"* public components of class CL_CAM_ADDRESS_BCS
*"* do not include other source files here!!!
public section.

  interfaces IF_COPY_BCS .
  interfaces IF_DELETE_BCS .
  interfaces IF_OS_STATE .
  interfaces IF_RECIPIENT_BCS .
  interfaces IF_RECIPIENT_DIALOG_BCS .
  interfaces IF_SENDER_BCS .

  constants C_ADDRESS_TYPE_X400 type SX_ADDRTYP value 'X40'. "#EC NOTEXT
  constants C_ADDRESS_TYPE_SMTP type SX_ADDRTYP value 'INT'. "#EC NOTEXT
  constants C_ADDRESS_TYPE_RML type SX_ADDRTYP value 'RML'. "#EC NOTEXT
  constants C_ADDRESS_TYPE_PRINT type SX_ADDRTYP value 'PRT'. "#EC NOTEXT
  constants C_ADDRESS_TYPE_PAGER type SX_ADDRTYP value 'PAG'. "#EC NOTEXT
  constants C_ADDRESS_TYPE_FAX type SX_ADDRTYP value 'FAX'. "#EC NOTEXT

  methods SET_PERSNUMBER
    importing
      !I_PERSNUMBER type AD_PERSNUM
    raising
      CX_OS_OBJECT_NOT_FOUND .
  type-pools SO .
  methods SET_CONSNUMBER
    importing
      !I_CONSNUMBER type SO_LFD_NR
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_COMMTYPE
    importing
      !I_COMMTYPE type SO_COMTYPE
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_ADDRNUMBER
    importing
      !I_ADDRNUMBER type AD_ADDRNUM
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_ADDRESS_NAME
    returning
      value(RESULT) type STRING
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_ADDRESS_STRING
    returning
      value(RESULT) type STRING
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_ADDRESS_TYPE
    returning
      value(RESULT) type SX_ADDRTYP
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_ADDRESS_NAME
    importing
      !I_ADDRESS_NAME type STRING
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_ADDRESS_STRING
    importing
      !I_ADDRESS_STRING type STRING
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_ADDRESS_TYPE
    importing
      !I_ADDRESS_TYPE type SX_ADDRTYP
    raising
      CX_OS_OBJECT_NOT_FOUND .
  class-methods CREATE_INTERNET_ADDRESS
    importing
      !I_ADDRESS_STRING type ADR6-SMTP_ADDR
      value(I_ADDRESS_NAME) type ADR6-SMTP_ADDR optional
      !I_INCL_SAPUSER type OS_BOOLEAN optional
    returning
      value(RESULT) type ref to CL_CAM_ADDRESS_BCS
    raising
      CX_ADDRESS_BCS .
  class-methods CREATE_RML_ADDRESS
    importing
      !I_SYST type AD_SYMBDST
      !I_CLIENT type AD_UMAND
      !I_USERNAME type AD_UNAME
    returning
      value(RESULT) type ref to CL_CAM_ADDRESS_BCS
    raising
      CX_ADDRESS_BCS .
  class-methods CREATE_FAX_ADDRESS
    importing
      !I_COUNTRY type AD_COMCTRY
      !I_NUMBER type AD_FXNMBR
    returning
      value(RESULT) type ref to CL_CAM_ADDRESS_BCS
    raising
      CX_ADDRESS_BCS .
  class-methods CREATE_SMS_ADDRESS
    importing
      value(I_SERVICE) type AD_PAGSERV optional
      value(I_NUMBER) type AD_PAGNMBR
    returning
      value(RESULT) type ref to CL_CAM_ADDRESS_BCS
    raising
      CX_ADDRESS_BCS .
  methods GET_ADDRNUMBER
    returning
      value(RESULT) type AD_ADDRNUM
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_COMMTYPE
    returning
      value(RESULT) type SO_COMTYPE
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_CONSNUMBER
    returning
      value(RESULT) type SO_LFD_NR
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_PERSNUMBER
    returning
      value(RESULT) type AD_PERSNUM
    raising
      CX_OS_OBJECT_NOT_FOUND .
  class-methods CREATE
    importing
      !I_ADDRNUMBER type AD_ADDRNUM
      !I_COMMTYPE type SO_COMTYPE optional
      !I_CONSNUMBER type SO_LFD_NR optional
      !I_PERSNUMBER type AD_PERSNUM
      !I_CAM_TYPE type AD_ADRTYPE optional
    returning
      value(RESULT) type ref to CL_CAM_ADDRESS_BCS
    raising
      CX_ADDRESS_BCS .
  methods GETU_SO_KEY
    returning
      value(RESULT) type AD_SO_KEY
    raising
      CX_ADDRESS_BCS .
  class-methods CREATE_USER_HOME_ADDRESS
    importing
      value(I_USER) type UNAME
      value(I_COMMTYPE) type SO_COMTYPE optional
    returning
      value(RESULT) type ref to CL_CAM_ADDRESS_BCS
    raising
      CX_ADDRESS_BCS .
  type-pools SZADR .
  class CL_OS_SYSTEM definition load .

*--- INCLUDE: CL_CTMENU=====================CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_CTMENU and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_DOCUMENT_BCS===============CU ---*
class CL_DOCUMENT_BCS definition
  public
  final
  create public

  global friends CB_DOCUMENT_BCS
                 CL_BCS
                 CL_BCS_PPF
                 CL_COVER_DOCUMENT_BCS
                 CL_COVER_DOC_PERSONALIZE_BCS
                 CL_DOCUMENT_MANAGER_BCS_PPF
                 CL_PDF_FORM_BCS
                 CL_SMARTFORM_BCS .

public section.
  type-pools BCSEV .
  class CA_DOCUMENT_BCS definition load .

  interfaces IF_COPY_BCS .
  interfaces IF_DELETE_BCS .
  interfaces IF_DOCUMENT_BCS .
  interfaces IF_DOCUMENT_DISPLAY_BCS .
  interfaces IF_OS_STATE .
  interfaces IF_PERSONALIZE_BCS .

  constants CP_SUBJECT_SIGN type STRING value '$&BCS_SUBJECT=' ##NO_TEXT.
  constants CP_CID type STRING value '&BCS_CID=' ##NO_TEXT.

  methods GETU_OBJHEAD
    importing
      !IM_PART type INT4
    returning
      value(RT_HEADER) type SOLI_TAB .
  class-methods CREATE_DOCUMENT
    importing
      value(I_TYPE) type SO_OBJ_TP
      value(I_SUBJECT) type SO_OBJ_DES
      value(I_LENGTH) type SO_OBJ_LEN optional
      value(I_LANGUAGE) type SO_OBJ_LA default SPACE
      value(I_IMPORTANCE) type BCS_DOCIMP optional
      value(I_SENSITIVITY) type SO_OBJ_SNS optional
      !I_TEXT type SOLI_TAB optional
      !I_HEX type SOLIX_TAB optional
      !I_HEADER type SOLI_TAB optional
      value(I_SENDER) type ref to CL_CAM_ADDRESS_BCS optional
      value(IV_VSI_PROFILE) type VSCAN_PROFILE optional
      value(IV_VSI_SCAN_OFF) type ABAP_BOOL optional
    returning
      value(RESULT) type ref to CL_DOCUMENT_BCS
    raising
      CX_DOCUMENT_BCS .
  class-methods CREATE_FROM_MIME
    importing
      value(IO_MIME) type ref to CL_BCOM_MIME
      value(IP_TYPE) type MIME_TYPE
      value(IP_SUBJECT) type SO_OBJ_DES
      value(IO_SENDER) type ref to CL_CAM_ADDRESS_BCS optional
      value(IP_IMPORTANCE) type BCS_DOCIMP optional
      value(IP_SENSITIVITY) type SO_OBJ_SNS optional
    exporting
      !ET_DOCTYPES type BCSY_SODOC
      value(EP_DOC) type ref to CL_DOCUMENT_BCS
    raising
      CX_DOCUMENT_BCS
      CX_BCOM_MIME .
  class-methods CREATE_FROM_MULTIRELATED
    importing
      value(I_SUBJECT) type SO_OBJ_DES
      value(I_LANGUAGE) type SO_OBJ_LA default SPACE
      value(I_IMPORTANCE) type BCS_DOCIMP optional
      value(I_SENSITIVITY) type SO_OBJ_SNS optional
      !I_MULTIREL_SERVICE type ref to CL_GBT_MULTIRELATED_SERVICE
      value(IV_VSI_PROFILE) type VSCAN_PROFILE optional
      value(IV_VSI_SCAN_OFF) type ABAP_BOOL optional
    returning
      value(RESULT) type ref to CL_DOCUMENT_BCS
    raising
      CX_DOCUMENT_BCS
      CX_BCOM_MIME
      CX_GBT_MIME .
  class-methods CREATE_FROM_TEXT
    importing
      !I_TEXT type BCSY_TEXT
      value(I_DOCUMENTTYPE) type SOOD-OBJTP default 'RAW'
      value(I_SUBJECT) type SOOD-OBJDES default SPACE
      value(I_IMPORTANCE) type SOOD-OBJPRI default '0'
      value(I_SENSITIVITY) type SOOD-OBJSNS default 'F'
    returning
      value(RESULT) type ref to CL_DOCUMENT_BCS
    raising
      CX_DOCUMENT_BCS .
  class-methods GETU_INSTANCE_BY_KEY
    importing
      !I_SOOD_KEY type SOODK
      value(I_NO_ENQUEUE) type OS_BOOLEAN optional
    returning
      value(RESULT) type ref to CL_DOCUMENT_BCS
    raising
      CX_DOCUMENT_BCS .
  methods ADD_ATTACHMENT
    importing
      value(I_ATTACHMENT_TYPE) type SOODK-OBJTP
      value(I_ATTACHMENT_SUBJECT) type SOOD-OBJDES
      value(I_ATTACHMENT_SIZE) type SOOD-OBJLEN optional
      value(I_ATTACHMENT_LANGUAGE) type SOOD-OBJLA default SPACE
      value(I_ATT_CONTENT_TEXT) type SOLI_TAB optional
      value(I_ATT_CONTENT_HEX) type SOLIX_TAB optional
      value(I_ATTACHMENT_HEADER) type SOLI_TAB optional
      value(IV_VSI_PROFILE) type VSCAN_PROFILE optional
      value(IV_VSI_SCAN_OFF) type ABAP_BOOL optional
      value(I_ATTACHMENT_FILENAME) type BCS_ATTACHMENT_NAME optional
    raising
      CX_DOCUMENT_BCS .
  methods GETU_FILENAME
    returning
      value(RV_FILENAME) type STRING .
  methods ADD_DOCUMENT_AS_ATTACHMENT
    importing
      !IM_DOCUMENT type ref to IF_DOCUMENT_BCS
    raising
      CX_DOCUMENT_BCS .
  methods GET_DOCNO
    returning
      value(RESULT) type SO_OBJ_NO
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_DOCTP
    returning
      value(RESULT) type SO_OBJ_TP
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_DOCYR
    returning
      value(RESULT) type SO_OBJ_YR
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_IMPORTANCE
    returning
      value(RESULT) type SO_OBJ_PRI
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_SENSITIVITY
    returning
      value(RESULT) type SO_OBJ_SNS
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET_SUBJECT
    returning
      value(RESULT) type SO_OBJ_DES
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_IMPORTANCE
    importing
      !I_IMPORTANCE type SO_OBJ_PRI
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_SENSITIVITY
    importing
      !I_SENSITIVITY type SO_OBJ_SNS
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods SET_SUBJECT
    importing
      !I_SUBJECT type SO_OBJ_DES
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GETU_SUBJECT_LONG
    returning
      value(RP_SUBJECT_LONG) type STRING .
  class-methods XSTRING_TO_SOLIX
    importing
      !IP_XSTRING type XSTRING
    returning
      value(RT_SOLIX) type SOLIX_TAB .
  class-methods STRING_TO_SOLI
    importing
      !IP_STRING type STRING
    returning
      value(RT_SOLI) type SOLI_TAB .

*--- INCLUDE: CL_DRAGDROP===================CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_DRAGDROP and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_DRAGDROPOBJECT=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_DRAGDROPOBJECT and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_GBT_MULTIRELATED_SERVICE===CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_GBT_MULTIRELATED_SERVICE and it's users.
*"* touched if any type reference has been changed

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

*--- INCLUDE: CL_MESSAGE_HELPER=============CU ---*
"! Utility Class for Statement MESSAGE
class cl_message_helper definition
  public
  final
  create private .

  public section.

    "! Transfer structure for parameters in OTR texts (type String)
    types otr_parameter type sbtfr_param.

    "! Table with assignment of parameter and value (type String)
    types otr_parameters type standard table of otr_parameter with default key.

    "! Transfer structure for parameters in OTR texts (type String)
    types otr_char_parameter type sotr_param.

    "! Table with assignment of parameter and value (type String)
    types otr_char_parameters type standard table of otr_char_parameter with default key.

    "! OTR Id
    types otr_id type sotr_conc.

    "! The message object used by MESSAGE
    class-data message_object type ref to if_message .

    "! Gets the top T100 exception from PREVIOUS chain
    "! @parameter EXCEPTION | Top object of scanned exception objects
    "! @parameter RESULT | Top exception object with non-empty T100 text
    class-methods get_latest_t100_exception
      importing
        !exception    type ref to cx_root
      returning
        value(result) type ref to if_t100_message .


    "! Returns Long Text for Parameter(s)
    "! @parameter TEXT | Message
    "! @parameter PRESERVE_NEWLINES | Preserves new line in message
    "! @parameter T100_PREPEND_SHORT | True if the short text is comes first in T100 texts
    "! @parameter RESULT | Text
    class-methods get_longtext_for_message
      importing
        value(text)               type ref to if_message
        value(preserve_newlines)  type abap_bool optional
        value(t100_prepend_short) type abap_bool default abap_true
      returning
        value(result)             type string .


    "! Returns Short Text for Parameter(s)
    "! @parameter TEXT | Message containing text
    "! @parameter RESULT | result string
    class-methods get_text_for_message
      importing
        value(text)   type ref to if_message
      returning
        value(result) type string .

    "! Sets MESSAGE variables, if TEXT is of type CLIKE
    "! @parameter TEXT | text
    class-methods set_msg_vars_for_clike
      importing
        value(text) type clike .

    "! Sets MESSAGE Variables, REF TO IF_T100_MESSAGE
    "! @parameter TEXT | Message object
    "! @raising CX_SY_MESSAGE_ILLEGAL_TEXT | Invalid MESSAGE Text Parameter
    class-methods set_msg_vars_for_if_t100_msg
      importing
        value(text) type ref to if_t100_message
      raising
        cx_sy_message_illegal_text .

    "! Sets MESSAGE Variables, if Text Is of Type ANY
    "! @parameter TEXT | Message
    "! @parameter STRING | Result
    "! @raising CX_SY_MESSAGE_ILLEGAL_TEXT | Invalid MESSAGE Text Parameter
    class-methods set_msg_vars_for_any
      importing
        !text         type any
      exporting
        value(string) type string
      raising
        cx_sy_message_illegal_text .

    "! Sets MESSAGE Variables, REF TO IF_MESSAGE
    "! @parameter TEXT | Message object
    "! @parameter STRING | String for transfer to MESSAGE
    "! @raising CX_SY_MESSAGE_ILLEGAL_TEXT | Invalid MESSAGE Text Parameter
    class-methods set_msg_vars_for_if_msg
      importing
        value(text)   type ref to if_message
      exporting
        value(string) type string
      raising
        cx_sy_message_illegal_text .

    "! Sets Appropriate Key for MESSAGE
    "! @parameter MSG | Message object
    "! @parameter T100KEY | T100 key with mapping of parameters to attribute names
    "! @parameter TEXTID | Key for logical object in OTR
    class-methods check_msg_kind
      importing
        value(msg)     type ref to if_message
      exporting
        value(t100key) type scx_t100key
        value(textid)  type otr_id.

    "! Returns Text Parameter
    "! @parameter OBJ | Object, the attributes are read from
    "! @parameter PARAMS | Table with assignment of parameters and values
    class-methods get_text_params
      importing
        value(obj) type ref to object
      exporting
        !params    type otr_char_parameters.

    "! Returns OTR Short Text Without Parameter Setting
    "! @parameter TEXTID | Key for logical object in OTR
    "! @parameter RESULT | Short text
    class-methods get_otr_text_raw
      importing
        !textid type otr_id
      exporting
        !result type string .

    "! Returns T100 short text
    "! @parameter OBJ | Object
    "! @parameter T100KEY | T100 key with mapping of parameters to attribute names
    "! @parameter RESULT | Short text
    class-methods get_t100_text_for
      importing
        value(obj) type ref to object
        !t100key   type scx_t100key
      exporting
        !result    type string .

    "! Gets T100 message
    "! @parameter OBJ | Message object
    "! @parameter RESULT | T100 message
    class-methods get_t100_for_object
      importing
        !obj          type ref to if_t100_message
      returning
        value(result) type symsg .

    "! Replaces text parameter
    "! @parameter OBJ | Object
    "! @parameter RESULT | Text
    class-methods replace_text_params
      importing
        value(obj) type ref to object
      changing
        !result    type string .

    "! Replaces new lines with blank characters
    "! @parameter MESSAGE | Text
    class-methods strip_newlines_from
      changing
        !message type string .

    "! Return text parameters
    "! @parameter OBJ | Object
    "! @parameter PARAMS | Table with assignment of parameter and value
    class-methods get_text_sparams
      importing
        value(obj) type ref to object
      exporting
        !params    type otr_parameters.


*--- INCLUDE: CL_PERSONALIZE_DATA_BCS=======CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_PERSONALIZE_DATA_BCS and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_SAPUSER_BCS================CU ---*
class CL_SAPUSER_BCS definition
  public
  final
  create public

  global friends CB_SAPUSER_BCS .

*"* public components of class CL_SAPUSER_BCS
*"* do not include other source files here!!!
public section.

  interfaces IF_DELETE_BCS .
  interfaces IF_OS_STATE .
  interfaces IF_RECIPIENT_BCS .
  interfaces IF_RECIPIENT_DIALOG_BCS .
  interfaces IF_SENDER_BCS .

  class-methods CREATE
    importing
      value(I_USER) type UNAME
    returning
      value(RESULT) type ref to CL_SAPUSER_BCS
    raising
      CX_ADDRESS_BCS .
  methods GET_SAPUSER
    returning
      value(RESULT) type UNAME
    raising
      CX_OS_OBJECT_NOT_FOUND .
  class-methods GETU_PERSISTENT
    importing
      value(I_USER) type UNAME
    returning
      value(RESULT) type ref to CL_SAPUSER_BCS
    raising
      CX_ADDRESS_BCS .
  class CL_OS_SYSTEM definition load .

*--- INCLUDE: CL_SEND_REQUEST_BCS===========CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_SEND_REQUEST_BCS and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_SIMPLEPROPBAG==============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_SIMPLEPROPBAG and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_SX_MIME_SINGLEPART=========CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_SX_MIME_SINGLEPART and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_TRACE_BCS==================CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_TRACE_BCS and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CX_ADDRESS_BCS================CU ---*
class CX_ADDRESS_BCS definition
  public
  inheriting from CX_BCS
  final
  create public .

public section.

*"* public components of class CX_ADDRESS_BCS
*"* do not include other source files here!!!
  constants NO_DEFAULT_COMM type SOTR_CONC value '001CC411E33E1DEDBB92D73ED0C58CA9' ##NO_TEXT.
  constants NO_USER_ADDRESS type SOTR_CONC value '001CC411E33E1DEDBB92D73ED0C5ACA9' ##NO_TEXT.
  constants ADDR_INV_BADI_TXT type SOTR_CONC value '005056AC62941EDA85B8D4D1060AC24F' ##NO_TEXT.
  constants NOT_FOUND type BCS_CXERR value 'NF_ADR' ##NO_TEXT.
  constants CANNOT_RESOLVE type BCS_CXERR value 'NO_RES_ADR' ##NO_TEXT.
  constants ADDR_INV_BADI type BCS_CXERR value 'BADI_INV_ADR' ##NO_TEXT.
  data USERID type SYUNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !ERROR_TYPE type BCS_CXERR optional
      !MSGID type SYMSGID optional
      !MSGNO type SYMSGNO optional
      !MSGTY type SYMSGTY optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional
      !OBJECT type STRING optional
      !ERROR_TEXT type STRING optional
      !USERID type SYUNAME optional .

*--- INCLUDE: CX_BCOM_MIME==================CU ---*
class CX_BCOM_MIME definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  constants ENCODING_B64 type SOTR_CONC value 'E95FBFFCE0C9D411AE8000A0C9EAAA94'. "#EC NOTEXT
  constants CX_BCOM_MIME type SOTR_CONC value '1FD5A9499AC7D411955F0060B03C6B76'. "#EC NOTEXT
  constants CODEPAGE_NOT_FOUND type SOTR_CONC value '0D816D7658C9D411AE8000A0C9EAAA94'. "#EC NOTEXT
  constants CODEPAGE_NO_ASCII type SOTR_CONC value '0F816D7658C9D411AE8000A0C9EAAA94'. "#EC NOTEXT
  constants CODEPAGE_NO_MIXED type SOTR_CONC value 'DE49EF6B95C9D411AE8000A0C9EAAA94'. "#EC NOTEXT
  constants CODEPAGE_NO_MIME type SOTR_CONC value 'AC5EBFFCE0C9D411AE8000A0C9EAAA94'. "#EC NOTEXT
  constants UNICODE type SOTR_CONC value '58BE28FFDBC7D411AE8000A0C9EAAA94'. "#EC NOTEXT
  constants FORMAT_CONVERSION type SOTR_CONC value '6FD9B76FF9C9D411B9E6009027C3EFAF'. "#EC NOTEXT
  constants CODEPAGE_NO_SAP type SOTR_CONC value '26DAB76FF9C9D411B9E6009027C3EFAF'. "#EC NOTEXT
  constants FROM_HEADER_INITIAL type SOTR_CONC value 'D8406770A6CAD411B9E6009027C3EFAF'. "#EC NOTEXT
  constants DEFAULT_INTERNET_DOMAIN type SOTR_CONC value '8A3EE09AF9C9D411B9E6009027C3EFAF'. "#EC NOTEXT
  constants MESSAGE_NO_MDN type SOTR_CONC value 'E6B957B457E8D41195600060B03C6B76'. "#EC NOTEXT
  constants SECURITY_NOT_AVAILABLE type SOTR_CONC value '9EBA06E53676824F8676032F3C13A23E'. "#EC NOTEXT
  constants DECRYPTION_FAILED type SOTR_CONC value '00505695007C1EE0AFD26D13CA2A1A34'. "#EC NOTEXT
  constants VERIFICATION_FAILED type SOTR_CONC value '00505695007C1EE0AFD26D13CA2A3A34'. "#EC NOTEXT
  constants SMIME_ERROR type SOTR_CONC value '00505695007C1EE0AFD272F913399A39'. "#EC NOTEXT
  constants PGP_NOT_SUPPORTED type SOTR_CONC value '0050569D554F1EE0B7D84D0446960AA3'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_BCS========================CU ---*
class CX_BCS definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.
*"* public components of class CX_BCS
*"* do not include other source files here!!!

  constants OTHERS type SOTR_CONC value '001CC411E33E1DEDBB91AC75F68A6CA9'. "#EC NOTEXT
  constants OS_ERROR type SOTR_CONC value '001CC411E33E1DEDBB91AC75F68A8CA9'. "#EC NOTEXT
  data ERROR_TYPE type BCS_CXERR .
  constants INTERNAL_ERROR type BCS_CXERR value 'INTERR_BCS'. "#EC NOTEXT
  constants OS_EXCEPTION type BCS_CXERR value 'OSERR_BCS'. "#EC NOTEXT
  constants X_ERROR type BCS_CXERR value 'XERR_BCS'. "#EC NOTEXT
  constants PARAMETER_ERROR type BCS_CXERR value 'PARERR_BCS'. "#EC NOTEXT
  constants INVALID_VALUE type BCS_CXERR value 'VERR_BCS'. "#EC NOTEXT
  constants CREATION_FAILED type BCS_CXERR value 'CERR_BCS'. "#EC NOTEXT
  constants NO_AUTHORIZATION type BCS_CXERR value 'NA_BCS'. "#EC NOTEXT
  constants LOCKED type BCS_CXERR value 'LOCKED_BCS'. "#EC NOTEXT
  constants CAST_ERROR type BCS_CXERR value 'CASTERR_BCS'. "#EC NOTEXT
  data MSGID type SYMSGID .
  data MSGNO type SYMSGNO .
  data MSGTY type SYMSGTY .
  data MSGV1 type SYMSGV .
  data MSGV2 type SYMSGV .
  data MSGV3 type SYMSGV .
  data MSGV4 type SYMSGV .
  data OBJECT type STRING .
  data ERROR_TEXT type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !ERROR_TYPE type BCS_CXERR optional
      !MSGID type SYMSGID optional
      !MSGNO type SYMSGNO optional
      !MSGTY type SYMSGTY optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional
      !OBJECT type STRING optional
      !ERROR_TEXT type STRING optional .

*--- INCLUDE: CX_DOCUMENT_BCS===============CU ---*
class CX_DOCUMENT_BCS definition
  public
  inheriting from CX_BCS
  create public .

public section.

*"* public components of class CX_DOCUMENT_BCS
*"* do not include other source files here!!!
  constants OBJECT_NOT_EXISTS type BCS_CXERR value 'ONE_DOC'. "#EC NOTEXT
  constants KPRO_ERROR type BCS_CXERR value 'KPRO_DOC'. "#EC NOTEXT
  constants MIME_NOT_AVAILABLE type BCS_CXERR value 'MNA_DOC'. "#EC NOTEXT
  data MT_VSI_ERROR type VSCAN_BAPIRET2_T .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !ERROR_TYPE type BCS_CXERR optional
      !MSGID type SYMSGID optional
      !MSGNO type SYMSGNO optional
      !MSGTY type SYMSGTY optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional
      !OBJECT type STRING optional
      !ERROR_TEXT type STRING optional
      !MT_VSI_ERROR type VSCAN_BAPIRET2_T optional .

*--- INCLUDE: CX_DYNAMIC_CHECK==============CU ---*
class CX_DYNAMIC_CHECK definition
  public
  inheriting from CX_ROOT
  abstract
  create public .

*"* public components of class CX_DYNAMIC_CHECK
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_GBT_MIME===================CU ---*
class CX_GBT_MIME definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class CX_GBT_MIME
*"* do not include other source files here!!!
public section.

  constants CX_GBT_MIME type SOTR_CONC
 value 'FFB297958BBD60469084A5B2A3431AA1' .
  constants NO_MAIN_PART type SOTR_CONC
 value '19A52DCEA7FAE847B5B80D1DCEE5E307' .
  constants NO_MULTI_RELATED type SOTR_CONC
 value '657CF27553E73341BA420180F8195120' .
  constants NO_SUPPORTED_MAIN_PART type SOTR_CONC
 value '562726BFED79764A9EFE812FF8C049EE' .
  constants NO_BODY_PARTS type SOTR_CONC
 value 'CFDEC5D02B10E04DBF5E86D6A09264F9' .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_OBL========================CU ---*
class CX_OBL definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

*"* public components of class CX_OBL
*"* do not include other source files here!!!
public section.

  constants CX_OBL type SOTR_CONC
 value '50CEB8A7A3DCD411955F0060B03C6B76' .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_OBL_INTERNAL_ERROR=========CU ---*
class CX_OBL_INTERNAL_ERROR definition
  public
  inheriting from CX_OBL
  create public .

*"* public components of class CX_OBL_INTERNAL_ERROR
*"* do not include other source files here!!!
public section.

  constants CX_OBL_INTERNAL_ERROR type SOTR_CONC
 value '902CA3DE7085D411B9E3009027C3EFAF' .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_OBL_MODEL_ERROR============CU ---*
class CX_OBL_MODEL_ERROR definition
  public
  inheriting from CX_OBL
  create public .

*"* public components of class CX_OBL_MODEL_ERROR
*"* do not include other source files here!!!
public section.

  constants CX_OBL_MODEL_ERROR type SOTR_CONC
 value 'AB124E0BAB8FD411B9E4009027C3EFAF' .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_OBL_PARAMETER_ERROR========CU ---*
class CX_OBL_PARAMETER_ERROR definition
  public
  inheriting from CX_OBL_INTERNAL_ERROR
  create public .

*"* public components of class CX_OBL_PARAMETER_ERROR
*"* do not include other source files here!!!
public section.

  constants CX_OBL_PARAMETER_ERROR type SOTR_CONC
 value 'CF78D9E7AA8FD411B9E4009027C3EFAF' .
  constants INVALID_OBJECT type SOTR_CONC
 value 'D178D9E7AA8FD411B9E4009027C3EFAF' .
  constants RELATION_MISSING type SOTR_CONC
 value 'D74978B68EA5D411B9E4009027C3EFAF' .
  data METHOD type SEOMTDNAME .
  data CLASSNAME type SEOCLSNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      value(METHOD) type SEOMTDNAME optional
      value(CLASSNAME) type SEOCLSNAME optional .

*--- INCLUDE: CX_OS_ERROR===================CU ---*
class CX_OS_ERROR definition
  public
  inheriting from CX_DYNAMIC_CHECK
  create public .

*"* public components of class CX_OS_ERROR
*"* do not include other source files here!!!
public section.

  constants CX_OS_ERROR type SOTR_CONC
 value 'E2101C1B3FE6D41181DD00A0C99E0BAF' .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_OS_OBJECT==================CU ---*
class CX_OS_OBJECT definition
  public
  inheriting from CX_OS_ERROR
  create public .

*"* public components of class CX_OS_OBJECT
*"* do not include other source files here!!!
public section.

  constants CX_OS_OBJECT type SOTR_CONC
 value 'C855C904F67CD41181DA00A0C99E0BAF' .
  data OBJECT type ref to OBJECT .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      value(OBJECT) type ref to OBJECT optional .

*--- INCLUDE: CX_OS_OBJECT_NOT_FOUND========CU ---*
class CX_OS_OBJECT_NOT_FOUND definition
  public
  inheriting from CX_OS_OBJECT
  final
  create public .

public section.
*"* public components of class CX_OS_OBJECT_NOT_FOUND
*"* do not include other source files here!!!

  constants TM_CLASS_NOT_SUBCLASS type SOTR_CONC value 'BD240E131BF5D411918000A0C9C67802'. "#EC NOTEXT
  constants DELETED type SOTR_CONC value 'DDEBB0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants CX_OS_OBJECT_NOT_FOUND type SOTR_CONC value '9EC4F849E49AD41181DA00A0C99E0BAF'. "#EC NOTEXT
  constants BY_REF type SOTR_CONC value 'AEA5E78D90E7D41181DD00A0C99E0BAF'. "#EC NOTEXT
  constants BY_OID type SOTR_CONC value '24C5F849E49AD41181DA00A0C99E0BAF'. "#EC NOTEXT
  constants BY_BKEY type SOTR_CONC value '07C5F849E49AD41181DA00A0C99E0BAF'. "#EC NOTEXT
  constants DELETED_BY_BKEY type SOTR_CONC value '4EE8B0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants DELETED_BY_OID type SOTR_CONC value '55E8B0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants IS_TRANSIENT_BY_BKEY type SOTR_CONC value '62E8B0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants IS_TRANSIENT_BY_OID type SOTR_CONC value '69E8B0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants IS_PERSISTENT_BY_BKEY type SOTR_CONC value '6FE8B0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants TRANSIENT_BY_BKEY type SOTR_CONC value '25E9B0143DE9D411918000A0C9C67802'. "#EC NOTEXT
  constants TM_CLASS_NOT_FOUND type SOTR_CONC value 'A2260E131BF5D411918000A0C9C67802'. "#EC NOTEXT
  constants TM_CLASS_NOT_SUBCLASS_BY_OID type SOTR_CONC value '236DF0010C692D479D101DCBED840CCA'. "#EC NOTEXT
  constants TM_CLASS_AGENT_MISMATCH type SOTR_CONC value 'F1FC2242A2E37306E10000000A114E9C'. "#EC NOTEXT
  constants INVALID_OID type SOTR_CONC value '07FD2242A2E37306E10000000A114E9C'. "#EC NOTEXT
  data BKEY type STRING .
  data OID type OS_GUID .
  data CLASS type OS_GUID .
  constants CHANGED_BY_OID type SOTR_CONC value '001A4BD2B24A02DCA9F781836143814C'. "#EC NOTEXT
  constants CHANGED_BY_BKEY type SOTR_CONC value '001A4BD2B24A02DCA9F7817C510D014B'. "#EC NOTEXT
  data TABLE type TABNAME .
  data CLASSNAME type SEOCLSNAME .
  data CLASSGUID type OS_GUID .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      value(OBJECT) type ref to OBJECT optional
      !BKEY type STRING optional
      !OID type OS_GUID optional
      !CLASS type OS_GUID optional
      !TABLE type TABNAME optional
      !CLASSNAME type SEOCLSNAME optional
      !CLASSGUID type OS_GUID optional .

*--- INCLUDE: CX_ROOT=======================CU ---*
class cx_root definition
  public
  abstract
  create public.

  public section.
    interfaces if_message.
    interfaces if_serializable_object.

    aliases get_longtext
      for if_message~get_longtext.
    aliases get_text
      for if_message~get_text.

    constants cx_root type sotr_conc value '16AA9A3937A9BB56E10000000A11447B'. "#EC NOTEXT
    data textid type sotr_conc read-only.
    data previous type ref to cx_root read-only.
    data kernel_errid type s380errid read-only.
    data is_resumable type abap_bool read-only.

    methods constructor
      importing
        !textid like textid optional
        !previous like previous optional.

    methods get_source_position
      exporting
        !program_name type syrepid
        !include_name type syrepid
        !source_line type i.


*--- INCLUDE: CX_SEND_REQ_BCS===============CU ---*
class CX_SEND_REQ_BCS definition
  public
  inheriting from CX_BCS
  create public .

public section.

*"* public components of class CX_SEND_REQ_BCS
*"* do not include other source files here!!!
  constants GC_ENCRYPT_UNAVAILABLE type SOTR_CONC value '6F43E7903B2B804C81C4CE825C952110' ##NO_TEXT.
  constants GC_SIGN_UNAVAILABLE type SOTR_CONC value '4473C13EA9152D43B5A875CF5D0208CF' ##NO_TEXT.
  constants ERROR_CURRENT_USER type SOTR_CONC value '001CC411E33E1DEDBB92DD7B9FBB0CA9' ##NO_TEXT.
  constants CX_SEND_REQ_BCS type SOTR_CONC value '001A4BD2B24A02DCB68E1398B3FF9EE8' ##NO_TEXT.
  constants DOC_NOT_EXISTS type SOTR_CONC value '001CC411E33E1DEDBB92DD7B9FBB4CA9' ##NO_TEXT.
  constants RECIPIENTS_NOT_EXIST type SOTR_CONC value '001CC411E33E1DEDBB92DD7B9FBB6CA9' ##NO_TEXT.
  constants SR_NOT_RELEASED type SOTR_CONC value '001CC411E33E1DEDBB92DD7B9FBB2CA9' ##NO_TEXT.
  constants BADI_ERROR type SOTR_CONC value '005056AC15431ED48E830A6A8F01CA97' ##NO_TEXT.
  constants ALLREADY_RELEASED type BCS_CXERR value 'ARERR_SREQ' ##NO_TEXT.
  constants RECIPIENT_EXISTS type BCS_CXERR value 'REX_SREQ' ##NO_TEXT.
  constants DOCUMENT_NOT_EXISTS type BCS_CXERR value 'DNX_SREQ' ##NO_TEXT.
  constants DOCUMENT_NOT_SENT type BCS_CXERR value 'DNS_SREQ' ##NO_TEXT.
  constants NOT_SUBMITED type BCS_CXERR value 'NS_SREQ' ##NO_TEXT.
  constants FOREIGN_LOCK type BCS_CXERR value 'FL_SREQ' ##NO_TEXT.
  constants TOO_MANY_RECEIVERS type BCS_CXERR value 'TMR_SREQ' ##NO_TEXT.
  constants NO_INSTANCE type BCS_CXERR value 'NI_SREQ' ##NO_TEXT.
  constants CANCELLED type BCS_CXERR value 'CANC_SREQ' ##NO_TEXT.
  constants NOT_RELEASED type BCS_CXERR value 'NOTREL_BCS' ##NO_TEXT.
  constants MIME_PROBLEMS type BCS_CXERR value 'MIME_BCS' ##NO_TEXT.
  constants NO_RECIPIENTS type BCS_CXERR value 'NO_REC_BCS' ##NO_TEXT.
  constants SENDER_PROBLEMS type BCS_CXERR value 'SENDER_BCS' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !ERROR_TYPE type BCS_CXERR optional
      !MSGID type SYMSGID optional
      !MSGNO type SYMSGNO optional
      !MSGTY type SYMSGTY optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional
      !OBJECT type STRING optional
      !ERROR_TEXT type STRING optional .

*--- INCLUDE: CX_STATIC_CHECK===============CU ---*
class CX_STATIC_CHECK definition
  public
  inheriting from CX_ROOT
  abstract
  create public .

*"* public components of class CX_STATIC_CHECK
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: CX_SY_MESSAGE_ILLEGAL_TEXT====CU ---*
class CX_SY_MESSAGE_ILLEGAL_TEXT definition
  public
  inheriting from CX_DYNAMIC_CHECK
  final
  create public .

*"* public components of class CX_SY_MESSAGE_ILLEGAL_TEXT
*"* do not include other source files here!!!
public section.

  constants CX_SY_MESSAGE_ILLEGAL_TEXT type SOTR_CONC
 value '6F0F313FD90DB647E10000000A114BF5'. "#EC NOTEXT
  constants ILLEGAL_TYPE type SOTR_CONC
 value '870F313FD90DB647E10000000A114BF5'. "#EC NOTEXT
  constants INITIAL_REF type SOTR_CONC
 value 'BA0E313FD90DB747E10000000A114BF5'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

*--- INCLUDE: IF_BINREL_CL==================IT ---*

*--- INCLUDE: IF_BROWSER_LINK===============IT ---*

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

*--- INCLUDE: IF_COPY_BCS===================IU ---*
*"* components of interface IF_COPY_BCS
interface IF_COPY_BCS
  public .


  methods COPY
    returning
      value(RESULT) type ref to OBJECT
    raising
      CX_BCS .
endinterface.

*--- INCLUDE: IF_DELETE_BCS=================IU ---*
*"* components of interface IF_DELETE_BCS
interface IF_DELETE_BCS
  public .


  class-methods MASS_DELETE
    importing
      !I_DEL_INSTANCES type BCSY_GUID
    exporting
      !E_NOT_DELETED type BCSY_GUID .
  methods DELETE
    raising
      CX_BCS .
endinterface.

*--- INCLUDE: IF_DOCUMENT_BCS===============IU ---*
*"* components of interface IF_DOCUMENT_BCS
interface IF_DOCUMENT_BCS
  public .


  interfaces IF_DELETE_BCS .

  methods GET_SUBJECT
    returning
      value(RE_SUBJECT) type CHAR50 .
  methods GET_BODY_PART_COUNT
    returning
      value(RE_COUNT) type INT4 .
  type-pools ABAP .
  methods GET_BODY_PART_CONTENT
    importing
      !IM_PART type INT4
      !IV_PREFER_TEXT type ABAP_BOOL optional
    returning
      value(RE_CONTENT) type BCSS_DBPC
    raising
      CX_DOCUMENT_BCS .
  methods AS_MIME_DOCUMENT
    importing
      !IM_MIME_GENERATOR type ref to CL_SX_MIME_SINGLEPART
    returning
      value(RE_MIME) type MIME_DATA
    raising
      CX_DOCUMENT_BCS .
  methods GET_SENSITIVITY
    returning
      value(RE_SENSITIVITY) type SO_OBJ_SNS .
  methods GET_IMPORTANCE
    returning
      value(RE_IMPORTANCE) type SO_OBJ_PRI .
  methods GET_BODY_PART_ATTRIBUTES
    importing
      !IM_PART type INT4
    returning
      value(RE_ATTRIBUTES) type BCSS_DBPA
    raising
      CX_DOCUMENT_BCS .
endinterface.

*--- INCLUDE: IF_DOCUMENT_DISPLAY_BCS=======IU ---*
*"* components of interface IF_DOCUMENT_DISPLAY_BCS
interface IF_DOCUMENT_DISPLAY_BCS
  public .


  constants C_SUPPORTED type OS_BOOLEAN value 'X' .
  constants C_NOT_SUPPORTED type OS_BOOLEAN value SPACE .

  methods DISPLAY_INPLACE
    importing
      value(I_SEND_REQUEST) type ref to CL_BCS
      value(I_CONTAINER) type ref to CL_GUI_CUSTOM_CONTAINER .
  methods DISPLAY_OUTPLACE
    importing
      value(I_SEND_REQUEST) type ref to CL_BCS .
  methods INPLACE_IS_SUPPORTED
    returning
      value(RESULT) type OS_BOOLEAN .
  methods OUTPLACE_IS_SUPPORTED
    returning
      value(RESULT) type OS_BOOLEAN .
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

*--- INCLUDE: IF_IXML_DOCUMENT==============IT ---*

*--- INCLUDE: IF_LINK_SERVICE===============IU ---*
*"* components of interface IF_LINK_SERVICE
interface IF_LINK_SERVICE
  public .


  constants GC_DELETE_LINK type CHAR1 value 'D'. "#EC NOTEXT
  constants GC_UPDATE_LINK type CHAR1 value 'U'. "#EC NOTEXT
  constants GC_CREATE_LINK type CHAR1 value  'A'. "#EC NOTEXT

  methods GET_ITEM_LINKS
    importing
      value(IO_BITEM) type ref to CL_BROWSER_ITEM
      !IP_LOAD_RESTRICTION type I optional
    exporting
      !ET_LINKS type BITEM_LINKS_T
      !ET_PARTNER type BITEM_T
      !EP_NUM_OF_LINKS type I .
endinterface.

*--- INCLUDE: IF_LINK_SERVICE_EVENTS========IU ---*
*"* components of interface IF_LINK_SERVICE_EVENTS
interface IF_LINK_SERVICE_EVENTS
  public .


  events EVENT_LINK_ADD
    exporting
      value(EO_BLINK) type ref to IF_BROWSER_LINK .
  events EVENT_LINK_UPDATE
    exporting
      value(EO_BLINK) type ref to IF_BROWSER_LINK .
  events EVENT_LINK_DELETE
    exporting
      value(EO_BLINK) type ref to IF_BROWSER_LINK .
endinterface.

*--- INCLUDE: IF_MESSAGE====================IU ---*
*"* components of interface IF_MESSAGE
interface IF_MESSAGE
  public .


  methods GET_TEXT
    returning
      value(RESULT) type STRING .
  methods GET_LONGTEXT
    importing
      value(PRESERVE_NEWLINES) type ABAP_BOOL optional
    returning
      value(RESULT) type STRING .
endinterface.

*--- INCLUDE: IF_OS_EXCEPTION_INFO==========IT ---*

*--- INCLUDE: IF_OS_STATE===================IU ---*
*"* components of interface IF_OS_STATE
interface IF_OS_STATE
  public .


  events CHANGED .
  events WRITE_ACCESS .
  events READ_ACCESS .

  methods HANDLE_EXCEPTION
    importing
      !I_EXCEPTION type ref to IF_OS_EXCEPTION_INFO optional
      !I_EX_OS type ref to CX_OS_OBJECT_NOT_FOUND optional
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods GET
    returning
      value(RESULT) type ref to OBJECT .
  methods INIT .
  methods SET
    importing
      !I_STATE type ref to OBJECT .
  methods INVALIDATE .
endinterface.

*--- INCLUDE: IF_PERSONALIZE_BCS============IU ---*
*"* components of interface IF_PERSONALIZE_BCS
interface IF_PERSONALIZE_BCS
  public .


  constants C_NO_PERSONALIZATION type CHAR1 value '0'. "#EC NOTEXT
  constants C_FULL_PERSONALIZATION type CHAR1 value '5'. "#EC NOTEXT
  constants C_OBJECT_PERSONALIZATION type CHAR1 value '2'. "#EC NOTEXT

  methods GET_PERSONALIZE_MODE
    returning
      value(RESULT) type CHAR1 .
  methods PERSONALIZE
    importing
      !PERSONALIZE_DATA type ref to CL_PERSONALIZE_DATA_BCS optional
      !APPL type ref to OBJECT
      !APPLICATION_LOG type BALLOGHNDL
      !ARCHIVE_MODE type PPFDBCSARC
      !ARCHIVE_PARAMETER type ARC_PARAMS optional
      !SPOOLDATA type PPFSIBCSTP optional
      !COMMTYPE type BCSDCOMTYP
      !PREVIEW type CHAR1
      !TECHNICAL_RECIPIENT type SWOTOBJID optional
      !NO_ATTACHMENTS type CHAR1 optional
    exporting
      value(DOCUMENT) type ref to IF_DOCUMENT_BCS
      !STATUS type PPFDTSTAT
    changing
      !ARCHIVE_INDEX type TSFDARA optional .
endinterface.

*--- INCLUDE: IF_RECIPIENT_BCS==============IU ---*
*"* components of interface IF_RECIPIENT_BCS
interface IF_RECIPIENT_BCS
  public .


  interfaces IF_DELETE_BCS .

  methods RESOLVE
    exporting
      !E_ADDRESSES type BCSY_RESV
    raising
      CX_ADDRESS_BCS .
endinterface.

*--- INCLUDE: IF_RECIPIENT_DIALOG_BCS=======IU ---*
*"* components of interface IF_RECIPIENT_DIALOG_BCS
interface IF_RECIPIENT_DIALOG_BCS
  public .


  interfaces IF_RECIPIENT_BCS .

  aliases RESOLVE
    for IF_RECIPIENT_BCS~RESOLVE .

  type-pools SO .
  class-methods GET_GROUP_TYPE
    returning
      value(RESULT) type SO_OBJ_TP .
  class-methods GET_SORT_GROUP
    returning
      value(RESULT) type SO_SORTCLA .
  class-methods NEW
    returning
      value(RECIPIENT) type ref to IF_RECIPIENT_DIALOG_BCS .
  class-methods CHECK_RECIPIENT_NAME
    importing
      value(RECIPIENT_NAME) type SO_NAME default '*'
    returning
      value(RECIPIENT) type ref to IF_RECIPIENT_DIALOG_BCS .
  class-methods CHECK_SEND_AUTHORITY
    importing
      value(USER) type SYUNAME default SY-UNAME
    returning
      value(RETURN) type SYSUBRC .
  class-methods GET_REF_BY_OID
    importing
      !OID type OS_GUID
    returning
      value(RESULT) type ref to IF_RECIPIENT_DIALOG_BCS .
  class-methods GET_RECIPIENT_TYPE_NAME
    importing
      value(LANGU) type SYLANGU default SY-LANGU
    returning
      value(NAME) type SO_ESC_DES
    exceptions
      LANGUAGE_NO_SUPPORT .
  methods COMPARE
    importing
      !OTHER_RECIPIENT type ref to IF_RECIPIENT_DIALOG_BCS
    returning
      value(RESULT) type SYSUBRC .
  methods GET_RECIPIENT_NAME
    importing
      value(LANGU) type SYLANGU default SY-LANGU
    returning
      value(RECIPIENT_NAME) type SO_NAME .
  methods CHECK_RECIPIENT_AUTHORITY
    importing
      !USER type SYUNAME default SY-UNAME
    returning
      value(RETURN) type SYSUBRC .
  methods GET_RECIPIENT_SORTFIELD
    returning
      value(RECIPIENT_SORTFIELD) type SO_SORTNAM .
  methods GET_DEFAULT_ATTRIBUTES
    returning
      value(DEFAULT_ATTRIBUTES) type SOOS2 .
  methods GET_GROUP_NAME
    returning
      value(GROUP_NAME) type SO_DLI_NAM .
  methods DISPLAY .
  methods EDIT .
  methods GET_OID_BY_REF
    returning
      value(OID) type OS_GUID .
  methods GET_ADDRESS_DATA
    returning
      value(RESULT) type SOCV_DATA .
  methods IS_PERSONALIZABLE
    returning
      value(RESULT) type SO_FLAG .
  methods GET_RECIPIENT_TYPE_NAME_DETAIL
    importing
      value(LANGU) type SYLANGU default SY-LANGU
    returning
      value(NAME) type SO_ESC_DES
    exceptions
      LANGUAGE_NO_SUPPORT .
endinterface.

*--- INCLUDE: IF_SENDER_BCS=================IU ---*
*"* components of interface IF_SENDER_BCS
interface IF_SENDER_BCS
  public .


  interfaces IF_DELETE_BCS .

  methods ADDRESS_TYPE
    returning
      value(RESULT) type SX_ADDRTYP .
  methods ADDRESS_STRING
    returning
      value(RESULT) type STRING .
  methods ADDRESS_NAME
    returning
      value(RESULT) type STRING .
endinterface.

*--- INCLUDE: IF_SERIALIZABLE_OBJECT========IU ---*
*"* components of interface IF_SERIALIZABLE_OBJECT
interface IF_SERIALIZABLE_OBJECT
  public .

endinterface.

*--- INCLUDE: IF_T100_MESSAGE===============IT ---*

*--- INCLUDE: SAPMZOVL_JV_CC_PAI ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
*  PERFORM sub_exit.
*  PERFORM sub_btn_press.

  IF  lt_month[] IS INITIAL.
    SELECT * FROM t247 INTO TABLE lt_month
    WHERE spras = sy-langu.
  ENDIF.
  READ TABLE lt_month INTO ls_month WITH KEY mnr = gwa_jv_cc-opp_month+0(2).
  IF sy-subrc = 0.
    month = ls_month-ktx.
  ENDIF.


  IF ok_code = 'CHNG'.
    lfct_9000 = ok_code.
  ENDIF.

  IF ok_code = 'DELE'.
    lfct_9000 = ok_code.

    gwa_jv_cc-deleted_on = sy-datum.
    gwa_jv_cc-del_ind = 'X'.
    MODIFY zjv_cash_call FROM gwa_jv_cc .""TRANSPORTING del_ind deleted_on.

    gwa_clog-ccreqno  = gwa_jv_cc-ccreqno.
    gwa_clog-mandt    = sy-mandt.
    gwa_clog-ent_date = sy-datum.
    gwa_clog-ent_time = sy-uzeit.
    gwa_clog-username = gwa_jv_cc-prj_cord.
    IF gwa_jv_cc-prj_cord IS NOT INITIAL.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*      SELECT SINGLE name_last FROM user_addr INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord.
      SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord ORDER BY name_last. ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
    ENDIF.
    gwa_clog-name_text = gv_name1.
    MODIFY zjv_cc_comm_log FROM gwa_clog.
    PERFORM del_mail.
    CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3, gv_name4, gv_name5, gwa_clog.
    LEAVE TO TRANSACTION 'ZJVCC'.
  ENDIF.
  IF ts_9020-activetab NE 'TS_9020_DISP'.
    IF lfct_9000 IS INITIAL AND gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM ZJV_CASH_CALL INTO GWA_JV_CC UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0 AND r1 = 'X' AND sy-uname = gwa_jv_cc-prj_cord.
      ELSE.
        MESSAGE 'Ýou are not authorized for this option' TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ELSE.
    IF ok_code = ' ' AND lfct_9000 NE 'CHNG'.
      SELECT * FROM ZJV_CASH_CALL INTO GWA_JV_CC UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    ENDIF.
  ENDIF.

*************************************************************************
   CLEAR CHA_WF.
  IF ok_code = '/CHA_PM'.
     CHA_WF = '/CHA_PM'.
  ELSEIF ok_code = '/CHA_PF'.
     CHA_WF = '/CHA_PF'.
  ELSEIF ok_code = '/CHA_PFO'.
     CHA_WF = '/CHA_PFO'.
  ELSEIF ok_code = '/CHA_RP'.
     CHA_WF = '/CHA_RP'.
  ENDIF.
************************************

  IF ok_code = '/UP_WF'.
    SELECT PRJ_MAN FROM ZJV_CASH_CALL INTO @DATA(UP_PM) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND PRJ_CORD = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-prj_man = UP_PM.

      ELSE.
        UPDATE zjv_cash_call SET PRJ_MAN = gwa_jv_cc-prj_man
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND PRJ_CORD = sy-uname.
      ENDIF.
  ENDIF.
*************************************************************************

  CLEAR: ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_VNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_vname INPUT.
  TYPES : BEGIN OF ty_vname,
            vname TYPE t8jv-vname,
            vtext TYPE t8jvt-vtext,
          END OF ty_vname.

  DATA: lt_read1 TYPE STANDARD TABLE OF dynpread,
        ls_read1 TYPE dynpread.
  DATA : lit_vname  TYPE TABLE OF ty_vname,
         lit_vname1 TYPE TABLE OF ty_vname,
         lit_t8j9a  TYPE TABLE OF t8j9a.

  DATA : lwa_vname TYPE ty_vname,
         lwa_t8j9a TYPE t8j9a.

  DATA : lv_bukrs1 TYPE bukrs.
  REFRESH: lit_vname[], lit_vname1[].
  ls_read1-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read1 TO lt_read1.
  CLEAR : ls_read1.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read1
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR: ls_read1.
  READ TABLE lt_read1 INTO ls_read1 WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs1 = ls_read1-fieldvalue.
  ENDIF.

*  SELECT DISTINCT vname FROM t8jv
*     INTO CORRESPONDING FIELDS OF TABLE lit_vname WHERE
*    bukrs = lv_bukrs1.
*  IF sy-subrc EQ 0.
*    SORT lit_vname.
*  ENDIF.
  .
*  IF sy-subrc EQ 0.

  SELECT v~vname t~vtext FROM t8jv AS v INNER JOIN t8jvt AS t ON v~bukrs = t~bukrs
    AND v~vname = t~vname
   INTO CORRESPONDING FIELDS OF TABLE lit_vname WHERE
    v~bukrs = lv_bukrs1
    AND v~vtype EQ '2'.
  IF sy-subrc EQ 0.
    SORT lit_vname.
    DELETE ADJACENT DUPLICATES FROM lit_vname COMPARING vname.
  ENDIF.
*  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-VNAME'
      value_org       = 'S'
    TABLES
      value_tab       = lit_vname
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.

MODULE mod_approver INPUT.
  TYPES: BEGIN OF ty_user,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user.
  DATA: lit_user   TYPE STANDARD TABLE OF ty_user,
        lit_return TYPE STANDARD TABLE OF ddshretval,
        lwa_return TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-FC_APPROVER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user
      return_tab      = lit_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return INTO lwa_return.
*      gv_fc_approver = lwa_return-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver1 INPUT.
  TYPES: BEGIN OF ty_user1,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user1.
  DATA: lit_user1   TYPE STANDARD TABLE OF ty_user1,
        lit_return1 TYPE STANDARD TABLE OF ddshretval,
        lwa_return1 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user1.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-RP_APPROVER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user1
      return_tab      = lit_return1
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return1 INTO lwa_return1.
*      gv_rp_approver = lwa_return1-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver2 INPUT.
  TYPES: BEGIN OF ty_user2,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user2.
  DATA: lit_user2   TYPE STANDARD TABLE OF ty_user2,
        lit_return2 TYPE STANDARD TABLE OF ddshretval,
        lwa_return2 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user2.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-PRJ_MAN'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user2
      return_tab      = lit_return2
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return2 INTO lwa_return2.
*      gv_jv_acc = lwa_return2-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver3 INPUT.
  TYPES: BEGIN OF ty_user3,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user3.
  DATA: lit_user3   TYPE STANDARD TABLE OF ty_user3,
        lit_return3 TYPE STANDARD TABLE OF ddshretval,
        lwa_return3 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user3.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-CB_ACC1'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user3
      return_tab      = lit_return3
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return3 INTO lwa_return3.
*      gv_cb_acc = lwa_return3-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver4 INPUT.
  TYPES: BEGIN OF ty_user4,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user4.
  DATA: lit_user4   TYPE STANDARD TABLE OF ty_user4,
        lit_return4 TYPE STANDARD TABLE OF ddshretval,
        lwa_return4 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user4.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-PF_OFFICER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user4
      return_tab      = lit_return4
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return4 INTO lwa_return4.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver5 INPUT.
  TYPES: BEGIN OF ty_user5,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user5.
  DATA: lit_user5   TYPE STANDARD TABLE OF ty_user5,
        lit_return5 TYPE STANDARD TABLE OF ddshretval,
        lwa_return5 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user5.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-TREASURY1'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user5
      return_tab      = lit_return5
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return5 INTO lwa_return5.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_WAERS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_waers INPUT.
  TYPES : BEGIN OF ty_t8jc2,
            fundcur TYPE jv_fundcur,
          END OF ty_t8jc2.

  DATA: lt_read3 TYPE STANDARD TABLE OF dynpread,
        ls_read3 TYPE dynpread.
  DATA : lit_fundcur TYPE TABLE OF ty_t8jc2,
         lit_t8jg    TYPE TABLE OF t8jg.

  DATA : lwa_t8jg  TYPE t8jg.

  DATA : lv_bukrs3 TYPE bukrs,
         lv_vname3 TYPE jv_name,
         lv_egrup3 TYPE jv_egroup.

  ls_read3-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read3 TO lt_read3.
  CLEAR : ls_read3.

  ls_read3-fieldname = 'GWA_JV_CC-VNAME'.
  APPEND ls_read3 TO lt_read3.
  CLEAR : ls_read3.

*  ls_read3-fieldname = 'GWA_JV_CC-BUKRS'.
*  APPEND ls_read3 TO lt_read3.
*  CLEAR : ls_read3.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read3
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR: ls_read3.
  READ TABLE lt_read3 INTO ls_read3 WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs3 = ls_read3-fieldvalue.
  ENDIF.

  CLEAR: ls_read3.
  READ TABLE lt_read3 INTO ls_read3 WITH KEY fieldname = 'GWA_JV_CC-VNAME'.
  IF sy-subrc = 0.
    lv_vname3 = ls_read3-fieldvalue.
  ENDIF.

  CLEAR: ls_read3.

  SELECT DISTINCT fundcur FROM t8jc2
     INTO TABLE lit_fundcur WHERE
    bukrs = lv_bukrs3 AND
    vname = lv_vname3."" AND
*    egrup = lv_egrup3.
  IF sy-subrc EQ 0.
    SORT lit_fundcur.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FUNDCUR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-WAERS'
      value_org       = 'S'
    TABLES
      value_tab       = lit_fundcur
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_PARTNER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_prctr INPUT.
  TYPES : BEGIN OF ty_cepc,
            prctr TYPE prctr,
            ktext TYPE ktext,
          END OF ty_cepc.

  DATA: lt_read TYPE STANDARD TABLE OF dynpread,
        ls_read TYPE dynpread.
  DATA : it_prctr TYPE TABLE OF ty_cepc.
  DATA : lv_bukrs TYPE bukrs,
         lv_vname TYPE jv_name.

  ls_read-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read TO lt_read.
  CLEAR : ls_read.

  ls_read-fieldname = 'GWA_JV_CC-VNAME'.
  APPEND ls_read TO lt_read.
  CLEAR : ls_read.

*  ls_read-fieldname = 'GV_ETYPE'.
*  APPEND ls_read TO lt_read.
*  CLEAR : ls_read.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR: ls_read.
  READ TABLE lt_read INTO ls_read WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs = ls_read-fieldvalue.
  ENDIF.

  READ TABLE lt_read INTO ls_read WITH KEY fieldname = 'GWA_JV_CC-VNAME'.
  IF sy-subrc EQ 0.
    lv_vname = ls_read-fieldvalue.
  ENDIF.

  CLEAR: ls_read.

  SELECT c~prctr t~ktext FROM cepc AS c INNER JOIN cepct AS t ON
    c~prctr EQ t~prctr
    AND c~kokrs EQ t~kokrs
    INTO TABLE it_prctr
    WHERE c~kokrs = 'OVL'.
*    AND vname = lv_vname.

  SORT it_prctr.
  DELETE ADJACENT DUPLICATES FROM it_prctr COMPARING prctr.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PRCTR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-PRCTR'
      value_org       = 'S'
    TABLES
      value_tab       = it_prctr
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_EGRUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_egrup INPUT.
  TYPES : BEGIN OF ty_t8jg,
            egrup TYPE jv_egroup,
          END OF ty_t8jg.

  DATA: lt_read2 TYPE STANDARD TABLE OF dynpread,
        ls_read2 TYPE dynpread.
  DATA : it_egrup TYPE TABLE OF ty_t8jg.

  DATA : lv_bukrs2 TYPE bukrs,
         lv_vname2 TYPE jv_name.

  ls_read2-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read2 TO lt_read2.
  CLEAR : ls_read2.

  ls_read2-fieldname = 'GWA_JV_CC-VNAME'.
  APPEND ls_read2 TO lt_read2.
  CLEAR : ls_read2.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read2
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR: ls_read2.
  READ TABLE lt_read2 INTO ls_read2 WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs2 = ls_read2-fieldvalue.
  ENDIF.

  READ TABLE lt_read2 INTO ls_read2 WITH KEY fieldname = 'GWA_JV_CC-VNAME'.
  IF sy-subrc EQ 0.
    lv_vname2 = ls_read2-fieldvalue.
  ENDIF.

  SELECT DISTINCT egrup FROM t8jg INTO TABLE it_egrup WHERE
    bukrs = lv_bukrs2 AND
    vname = lv_vname2.
  IF sy-subrc EQ 0.
    SORT : it_egrup[].
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EGRUP'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-EGRUP'
      value_org       = 'S'
    TABLES
      value_tab       = it_egrup
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9010 INPUT.
*  CLEAR ok_code.
  IF r1 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Project Coordinator'.
    flag_disp = 'X'.
    CALL SCREEN 9020.
  ELSEIF r2 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Project Manager'.
    CALL SCREEN 9030.
  ELSEIF r3 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Incharge Project Finance'.
    CALL SCREEN 9030.
  ELSEIF r4 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Project FI Officer / Junior Accounting Pool'.
    CALL SCREEN 9030.
  ELSEIF r5 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Regional President'.
    CALL SCREEN 9030.
  ELSEIF r6 = 'X'.
    CALL TRANSACTION 'ZJVCCREP'.
  ELSEIF r7 = 'X'.   "added by ss on 16.4.21
    CALL SCREEN 9040.
**    BOC by ss on 23.8.21
  ELSEIF r8 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Reviewer'.
    CALL SCREEN 9030.
**    EOC by ss on 23.8.21
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ex INPUT.
  IF ok_code = 'BACK' OR ok_code = 'CANC' OR ok_code = 'EXIT'.
    IF sy-dynnr = '9030' OR sy-dynnr = '9020'
          OR sy-dynnr = '9040'.   "added by ss on 16.4.21
      CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3,
             gv_name4, gv_name5, gv_name6, gwa_clog, flag_data,
      wa_bank , zfi_bank_payee-bankn.

      LEAVE TO SCREEN 9010.
    ELSE.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
  CLEAR ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'TS_9020'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
MODULE ts_9020_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_ts_9020-tab1.
      g_ts_9020-pressed_tab = c_ts_9020-tab1.
    WHEN c_ts_9020-tab2.
      g_ts_9020-pressed_tab = c_ts_9020-tab2.
    WHEN c_ts_9020-tab3.
      g_ts_9020-pressed_tab = c_ts_9020-tab3.
    WHEN c_ts_9020-tab4.
      g_ts_9020-pressed_tab = c_ts_9020-tab4.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9020 INPUT.
  DATA: v_gjahr TYPE gjahr,
        num(5)  TYPE c  VALUE '00000'.
*        num1(5) TYPE c.
  IF  lt_month[] IS INITIAL.
    SELECT * FROM t247 INTO TABLE lt_month
    WHERE spras = sy-langu.
  ENDIF.
  READ TABLE lt_month INTO ls_month WITH KEY mnr = gwa_jv_cc-opp_month+0(2).
  IF sy-subrc = 0.
    month = ls_month-ktx.
  ENDIF.

  IF ok_code = 'SAVE'.
**BOC by ss on 20.9.21**
    IF gwa_jv_cc-partn IS NOT INITIAL.
      SELECT SINGLE * FROM lfb1 INTO @DATA(ls_tab) WHERE lifnr EQ @gwa_jv_cc-partn AND bukrs EQ @gwa_jv_cc-bukrs.
      IF sy-subrc NE 0.
        MESSAGE 'The mentioned partner is not created as Vendor.' TYPE 'E'.
      ENDIF.
    ENDIF.
**  EOC by ss on 20.9.21**



    IF  ts_9020-activetab = c_ts_9020-tab1.
      CALL FUNCTION 'GET_CURRENT_YEAR'
        EXPORTING
          bukrs = gwa_jv_cc-bukrs
          date  = sy-datum
        IMPORTING
*         CURRM =
          curry = gwa_jv_cc-gjahr
*         PREVM =
*         PREVY =
        .

      SELECT ccreqno FROM zjv_cash_call INTO TABLE @DATA(it_ccreq) WHERE gjahr = @gwa_jv_cc-gjahr
*                                                                   AND BUKRS = @GWA_JV_CC-BUKRS   " Commented by ss on 5.8.21
                                                                   AND vname = @gwa_jv_cc-vname
        ORDER BY ccreqno DESCENDING.

      IF it_ccreq IS NOT INITIAL.
*        SORT it_ccreq DESCENDING.

        READ TABLE it_ccreq INTO DATA(wa_ccreq) INDEX 1.
        num = wa_ccreq-ccreqno+10(5).
        num = num + 1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = num
          IMPORTING
            output = num.

      ELSE.
        num = '00001'.
      ENDIF.
*       num1 = num.
      CONCATENATE gwa_jv_cc-vname gwa_jv_cc-gjahr num INTO gwa_jv_cc-ccreqno.
      gwa_jv_cc-status_fc = gwa_jv_cc-status_pfo = gwa_jv_cc-status_pm = gwa_jv_cc-status_rp = 'PENDING'.
      gwa_jv_cc-status_rev = 'PENDING'.  " added by ss on 24.8.21
      gwa_jv_cc-created_on = sy-datum.
      gwa_jv_cc-mandt = sy-mandt.

      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_cord.
      gwa_clog-name_text = gv_name1.
      MODIFY  zjv_cc_comm_log FROM gwa_clog.

      PERFORM crea_mail USING gwa_jv_cc-prj_man gv_name1 gwa_jv_cc-ccreqno.
      PERFORM trea_mail USING gv_name5 gwa_jv_cc-ccreqno.
      CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3, gv_name4, gv_name5, gwa_clog, gv_name6 .
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF ts_9020-activetab = c_ts_9020-tab3 AND lfct_9000 = 'CHNG'.

      gwa_jv_cc-status_fc = gwa_jv_cc-status_pfo = gwa_jv_cc-status_pm = gwa_jv_cc-status_rp = 'PENDING'.
      gwa_jv_cc-status_rev = 'PENDING'.  " added by ss on 24.8.21
      gwa_jv_cc-changed_on = sy-datum.

      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_cord.
      gwa_clog-name_text = gv_name1.
      GWA_CLOG-BNK_DTLS  = GWA_CLOG-BNK_DTLS.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

*      SELECT * FROM zjv_cc_comm_log INTO @DATA(UPD_BNK) WHERE ccreqno
       UPDATE zjv_cc_comm_log SET BNK_DTLS  = GWA_CLOG-BNK_DTLS WHERE ccreqno = gwa_jv_cc-ccreqno.

      PERFORM chng_mail USING gwa_jv_cc-prj_man gv_name1 gwa_jv_cc-ccreqno.
      PERFORM chng_mail_pm USING gwa_jv_cc-prj_man gv_name1 gwa_jv_cc-ccreqno.
*      CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3, gv_name4, gv_name5.
      CLEAR: lfct_9000.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSE.

      MESSAGE 'Not allowed in display mode' TYPE 'E'.
    ENDIF.
  ENDIF.

  DATA ls_sodocchgi1 TYPE sodocchgi1.
  DATA  g_att_files LIKE TABLE OF swotobjid.
*  DATA g_att_files_wa LIKE swotobjid.
  DATA FILE_DETAILS TYPE  SOOD5.
  DATA  g_att_files2 LIKE TABLE OF swotobjid.
  CLEAR g_att_files_wa.
  REFRESH g_att_files.

  IF ok_code = 'ATTACH'.
    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      APPEND g_att_files_wa TO g_att_files.

                               .
      CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
        EXPORTING
          attachment_data     = ls_sodocchgi1
          attachment_type     = 'DOC'
        TABLES
          application_objects = g_att_files.


    ENDIF.
  ENDIF.

  IF ok_code = 'LOG'.


    CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.
*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.


    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM zjv_cc_comm_log INTO TABLE git_clog WHERE ccreqno = gwa_jv_cc-ccreqno.
**************************************************************************************************************************
      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*       g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
        g_att_files_wa-objtype = 'ATT'.
        g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

        APPEND g_att_files_wa TO g_att_files2.

         IF g_att_files2 IS NOT INITIAL.
               PERFORM GET_FILE .
         ENDIF.
**************************************************************************************************************************

      IF gwa_jv_cc-vtype = '1'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COMM'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF gwa_jv_cc-vtype = '2'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSE.
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.

      CALL FUNCTION v_fm
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          wa_req             = gwa_jv_cc
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
        TABLES
          it_log             = git_clog
          file_details1      = file_details1
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      CLEAR : gt_otf.

      IF gt_otf_hr IS NOT INITIAL.
        CALL FUNCTION 'HR_IT_DISPLAY_WITH_PDF'
* EXPORTING
*   IV_PDF          =
          TABLES
            otf_table = gt_otf_hr-otfdata[].
      ENDIF.

    ENDIF.
  ENDIF.


  IF ok_code = 'LIST'.
    CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
    g_att_files_wa-objtype = 'ATT'.
    g_att_files_wa-objkey = gwa_jv_cc-ccreqno.


                                                   .
    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa.


  ENDIF.

  CLEAR: ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9030  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9030 INPUT.

  IF  lt_month[] IS INITIAL.
    SELECT * FROM t247 INTO TABLE lt_month
    WHERE spras = sy-langu.
  ENDIF.
  READ TABLE lt_month INTO ls_month WITH KEY mnr = gwa_jv_cc-opp_month+0(2).
  IF sy-subrc = 0.
    month = ls_month-ktx.
  ENDIF.

  IF ok_code = 'APPR'.
    IF r2 = 'X'.

      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      MOVE: g_att_files_wa-objkey  TO ls_object-instid,
            g_att_files_wa-objtype TO ls_object-typeid,
            g_att_files_wa-logsys  TO ls_logsys,
            ls_catid_bo        TO ls_object-catid.

      TRY.

          CALL METHOD cl_binary_relation=>read_links_of_binrel
            EXPORTING
              is_object   = ls_object
              ip_logsys   = ls_logsys
              ip_relation = ls_relation
*             ip_role     = ls_role
*             ip_propnam  =
*             ip_no_buffer = SPACE
            IMPORTING
              et_links    = lt_links
*             et_roles    =
            .
        CATCH cx_obl_parameter_error .
        CATCH cx_obl_internal_error .
        CATCH cx_obl_model_error .
      ENDTRY.

      IF lt_links[] IS INITIAL.
        MESSAGE 'Attachment Missing' TYPE 'E'.
      ENDIF.

*  ENDIF.
      gwa_jv_cc-status_pm = 'APPROVED'.
      gwa_jv_cc-status_rev = 'APPROVED'.   " ( added by ss on 24.8.21) - NOTE
      MODIFY zjv_cash_call FROM gwa_jv_cc .""TRANSPORTING status_pm.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_man.
      gwa_clog-name_text = gv_name2.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail USING gwa_jv_cc-fc_approver gv_name2 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

*****      BOC  by ss on 18.6.21
    ELSEIF r3 = 'X'.    " Incharge project finance
      gwa_jv_cc-status_fc = gwa_jv_cc-status_pfo = 'APPROVED'.
*      IF gv_name6 is INITIAL.
*          GWA_JV_CC-STATUS_REV = ''.
*      ENDIF.

      MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_fc status_pfo.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-fc_approver.
      gwa_clog-name_text = gv_name3.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM appr_mail_fc USING gwa_jv_cc-rp_approver gv_name3 gwa_jv_cc-ccreqno.
*      PERFORM TREA_MAIL USING GV_NAME5 GWA_JV_CC-CCREQNO.
      LEAVE TO TRANSACTION 'ZJVCC'.


    ELSEIF r5 = 'X'.

      PERFORM post_doc.
      IF gwa_jv_cc-belnr IS NOT INITIAL.
*        PERFORM APPR_MAIL_RP USING GV_NAME5 GWA_JV_CC-CCREQNO.
*        PERFORM CNB_MAIL USING GV_NAME5 GWA_JV_CC-CCREQNO.

        gwa_jv_cc-status_rp = 'APPROVED'.

        MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_rp.

        gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
        gwa_clog-mandt = sy-mandt.
        gwa_clog-ent_date = sy-datum.
        gwa_clog-ent_time = sy-uzeit.
        gwa_clog-username = gwa_jv_cc-rp_approver.
        gwa_clog-name_text = gv_name5.
        MODIFY zjv_cc_comm_log FROM gwa_clog.

        PERFORM appr_mail_rp USING gv_name5 gwa_jv_cc-ccreqno.
        PERFORM cnb_mail USING gv_name5 gwa_jv_cc-ccreqno.

      ENDIF.
      LEAVE TO TRANSACTION 'ZJVCC'.

*          BOC by ss on 24.8.21
    ELSEIF r8 = 'X'.

      gwa_jv_cc-status_rev = 'APPROVED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username =  gwa_jv_cc-reviewer.
      gwa_clog-name_text = gv_name6.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM appr_mail_rev USING gwa_jv_cc-fc_approver
                                  gv_name3
                                  gwa_jv_cc-ccreqno.
*      PERFORM TREA_MAIL USING GV_NAME6 GWA_JV_CC-CCREQNO.
      LEAVE TO TRANSACTION 'ZJVCC'.
*      EOC by ss on 24.8.21

    ENDIF.
  ENDIF.

  IF ok_code = 'REJT'.
    IF r2 = 'X'.
      gwa_jv_cc-status_pm = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc .""TRANSPORTING status_pm.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_man.
      gwa_clog-name_text = gv_name2.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name2 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF r3 = 'X'.
      gwa_jv_cc-status_fc = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_fc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-fc_approver.
      gwa_clog-name_text = gv_name3.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name3 gwa_jv_cc-ccreqno.
*    ELSEIF r4 = 'X'.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF r5 = 'X'.
      gwa_jv_cc-status_rp = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_rp.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-rp_approver.
      gwa_clog-name_text = gv_name5.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name5 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

**      Added by ss on 24.8.21
    ELSEIF r8 = 'X'.
      gwa_jv_cc-status_rev = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc.
      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-reviewer.
      gwa_clog-name_text = gv_name6.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name6 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.
**      EOC by ss on 24.8.2021
    ENDIF.
  ENDIF.

  IF ok_code = 'FPFO'.
    IF r3 = 'X'.

******       Added by ss on 18.6.21
      gwa_jv_cc-status_pfo = 'FORWARD'.   "When PFO SUBMIT the req.
      MODIFY zjv_cash_call FROM gwa_jv_cc .
**********      End by ss on 18.6.21

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-fc_approver.
      gwa_clog-name_text = gv_name3.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail1 USING gwa_jv_cc-pf_officer gv_name3 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF r4 = 'X'.

******       Added by ss on 18.6.21
      gwa_jv_cc-status_pfo = 'APPROVED'.   "When PFO SUBMIT the req.
      gwa_jv_cc-status_fc = 'PENDING'.   "When PFO SUBMIT the req.
      MODIFY zjv_cash_call FROM gwa_jv_cc .
**********      End by ss on 18.6.21


      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-pf_officer.
      gwa_clog-name_text = gv_name4.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail2 USING gwa_jv_cc-fc_approver gv_name4 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

**   Added by ss on 24.8.21
    ELSEIF r2 = 'X'.


      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2)
      gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.

      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      MOVE: g_att_files_wa-objkey  TO ls_object-instid,
            g_att_files_wa-objtype TO ls_object-typeid,
            g_att_files_wa-logsys  TO ls_logsys,
            ls_catid_bo        TO ls_object-catid.

      TRY.

          CALL METHOD cl_binary_relation=>read_links_of_binrel
            EXPORTING
              is_object   = ls_object
              ip_logsys   = ls_logsys
              ip_relation = ls_relation
*             ip_role     = ls_role
*             ip_propnam  =
*             ip_no_buffer = SPACE
            IMPORTING
              et_links    = lt_links
*             et_roles    =
            .
        CATCH cx_obl_parameter_error .
        CATCH cx_obl_internal_error .
        CATCH cx_obl_model_error .
      ENDTRY.

      IF lt_links[] IS INITIAL.
        MESSAGE 'Attachment Missing' TYPE 'E'.
      ENDIF.



      gwa_jv_cc-status_pm = 'FORWARD'.
      gwa_jv_cc-status_fc = 'PENDING'.
      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-reviewer.
      gwa_clog-name_text = gv_name2.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail_rev USING gwa_jv_cc-reviewer gv_name6 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

    ENDIF.


  ENDIF.


  IF ok_code = 'ATTACH'.
    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      APPEND g_att_files_wa TO g_att_files.

      CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
        EXPORTING
          attachment_data     = ls_sodocchgi1
          attachment_type     = 'DOC'
        TABLES
          application_objects = g_att_files.

    ENDIF.
  ENDIF.

  IF ok_code = 'LOG'.
    DATA : v_fm1 TYPE rs38l_fnam.
*
*    DATA: is_control_param  TYPE ssfctrlop,
*          is_composer_param TYPE ssfcompop,
*          is_job_info       TYPE ssfcrescl,
*          v_objectid        TYPE cdhdr-objectid.
*
*    DATA: iwa_ssfcrescl TYPE ssfcrescl,
*          iw_spoolids   TYPE rspoid,
*          iw_ssfctrlop  TYPE ssfctrlop,
*          lwa_ssfcompop TYPE ssfcompop,
**     gt_otf       TYPE ssfcrescl,
*          lwa_line      TYPE itcoo,
*          it_otf_hr     TYPE ssfcrescl,
*          it_otf        TYPE ssfcrescl.


*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.

    CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.


    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM zjv_cc_comm_log INTO TABLE git_clog WHERE ccreqno = gwa_jv_cc-ccreqno.

************************************************************************************************************************
        CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*       g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
        g_att_files_wa-objtype = 'ATT'.
        g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

        APPEND g_att_files_wa TO g_att_files2.

         IF g_att_files2 IS NOT INITIAL.
               PERFORM GET_FILE .
         ENDIF.
************************************************************************************************************************

      IF gwa_jv_cc-vtype = '1'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COMM'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm1
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF gwa_jv_cc-vtype = '2'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm1
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

      CALL FUNCTION v_fm1
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          wa_req             = gwa_jv_cc
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
        TABLES
          it_log             = git_clog
          file_details1      = file_details1
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      CLEAR : gt_otf.

      IF gt_otf_hr IS NOT INITIAL.
        CALL FUNCTION 'HR_IT_DISPLAY_WITH_PDF'
* EXPORTING
*   IV_PDF          =
          TABLES
            otf_table = gt_otf_hr-otfdata[].
      ENDIF.

    ENDIF.
  ENDIF.

  IF ok_code IS INITIAL AND gwa_jv_cc-ccreqno IS NOT INITIAL.
    SELECT * FROM ZJV_CASH_CALL INTO GWA_JV_CC UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      IF r2 = 'X' AND sy-uname = gwa_jv_cc-prj_man.
        flag_data = 'X'.

      ELSEIF r3 = 'X' AND sy-uname = gwa_jv_cc-fc_approver.
        flag_data = 'X'.

      ELSEIF r4 = 'X' AND sy-uname = gwa_jv_cc-pf_officer.
        flag_data = 'X'.

      ELSEIF r5 = 'X' AND sy-uname = gwa_jv_cc-rp_approver.
        flag_data = 'X'.
**               Added by ss on 24.8.21
      ELSEIF r8 = 'X' AND sy-uname = gwa_jv_cc-reviewer.
        flag_data = 'X'.

      ELSE.
*        MESSAGE 'You are not authorized for this option' TYPE 'I' DISPLAY LIKE 'E'.
*        LEAVE TO SCREEN 9010.
      ENDIF.

    ENDIF.
  ENDIF.

  IF ok_code = 'LIST'.
    CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
    g_att_files_wa-objtype = 'ATT'.
    g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa.

  ENDIF.
*******************************************************************
   CLEAR CHA_WF.
  IF ok_code = '/CHA_PM'.
     CHA_WF = '/CHA_PM'.
  ELSEIF ok_code = '/CHA_PF'.
     CHA_WF = '/CHA_PF'.
  ELSEIF ok_code = '/CHA_PFO'.
     CHA_WF = '/CHA_PFO'.
  ELSEIF ok_code = '/CHA_RP'.
     CHA_WF = '/CHA_RP'.
  ENDIF.

************************************

  IF ok_code = '/UP_WF'.
    IF save_wf = 'UP_PF'.
      SELECT FC_APPROVER FROM ZJV_CASH_CALL INTO @DATA(UP_PF) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND PRJ_MAN = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-fc_approver = UP_PF.

      ELSE.
        UPDATE zjv_cash_call SET fc_approver = gwa_jv_cc-fc_approver
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND PRJ_MAN = sy-uname.
      ENDIF.

    ELSEIF save_wf = 'UP_PFO'.
      SELECT PF_OFFICER FROM ZJV_CASH_CALL INTO @DATA(UP_PFO) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND FC_APPROVER = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-pf_officer = UP_PFO.

      ELSE.
        UPDATE zjv_cash_call SET pf_officer = gwa_jv_cc-pf_officer
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND fc_approver = sy-uname.
      ENDIF.

    ELSEIF save_wf = 'UP_RP'.
      SELECT RP_APPROVER FROM ZJV_CASH_CALL INTO @DATA(UP_RP) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND PF_OFFICER = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-rp_approver = UP_RP.

      ELSE.
        UPDATE zjv_cash_call SET rp_approver = gwa_jv_cc-rp_approver
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND pf_officer = sy-uname.
      ENDIF.

   ENDIF.
  ENDIF.
*************************************************************************

  CLEAR ok_code.

ENDMODULE.


MODULE mod_attach INPUT.
  DATA: p_filename TYPE ibipparms-path.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'GV_ATTACH'
    IMPORTING
      file_name     = p_filename.
  IF p_filename IS NOT INITIAL.
*    gv_attach = p_filename.
  ENDIF.
***-  Begin of change ABAPUSER01 Dated 2/19/2019
***- Declaration of a table with Solix type 255 character length
*  DATA LT_MAILHEX TYPE TABLE OF SOLIX.
***- Calling function module to upload GUI in an internal table
*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename                      = GV_ATTACH
*     FILETYPE                      = 'BIN'
*    tables
*      data_tab                      = LT_MAILHEX
*   EXCEPTIONS
*     FILE_OPEN_ERROR               = 1
*     FILE_READ_ERROR               = 2
*     NO_BATCH                      = 3
*     GUI_REFUSE_FILETRANSFER       = 4
*     INVALID_TYPE                  = 5
*     NO_AUTHORITY                  = 6
*     UNKNOWN_ERROR                 = 7
*     BAD_DATA_FORMAT               = 8
*     HEADER_NOT_ALLOWED            = 9
*     SEPARATOR_NOT_ALLOWED         = 10
*     HEADER_TOO_LONG               = 11
*     UNKNOWN_DP_ERROR              = 12
*     ACCESS_DENIED                 = 13
*     DP_OUT_OF_MEMORY              = 14
*     DISK_FULL                     = 15
*     DP_TIMEOUT                    = 16
*     OTHERS                        = 17.
***- If no file uploaded in system then triggering-error message            .
*  IF sy-subrc is not INITIAL .
*  MESSAGE i999(zz) WITH 'Error in reading file for upload'(002).
** Implement suitable error handling here
*  ENDIF.
***-End of change ABAPUSER01 Dated 2/19/2019
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_REQNO_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_reqno_9000 INPUT.
  TYPES: BEGIN OF ty_reqno,
           ccreqno TYPE zccreqno,
           bukrs   TYPE bukrs,
         END OF ty_reqno.
  DATA: it_reqno TYPE STANDARD TABLE OF ty_reqno,
        it_ret   TYPE STANDARD TABLE OF ddshretval,
        wa_ret   TYPE ddshretval.
  SELECT ccreqno bukrs FROM zjv_cash_call
    INTO TABLE it_reqno.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CCREQNO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-CCREQNO'
      value_org       = 'S'
    TABLES
      value_tab       = it_reqno
      return_tab      = it_ret
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT it_ret INTO wa_ret.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_REQNO_9030  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_reqno_9030 INPUT.
  TYPES: BEGIN OF ty_ccreqno,
           ccreqno TYPE zccreqno,
           status  TYPE zccstatus,
         END OF ty_ccreqno.
  DATA: it_ccreqno TYPE STANDARD TABLE OF ty_ccreqno,
        it_retn    TYPE STANDARD TABLE OF ddshretval,
        wa_retn    TYPE ddshretval.

  IF r2 = 'X'.
    SELECT ccreqno status_pm FROM zjv_cash_call
      INTO TABLE it_ccreqno WHERE status_pm = 'PENDING'.

  ELSEIF r3 = 'X'.
    SELECT ccreqno status_fc FROM zjv_cash_call
      INTO TABLE it_ccreqno WHERE status_fc = 'PENDING'.

  ELSEIF r4 = 'X'.
    SELECT ccreqno status_pfo FROM zjv_cash_call
      INTO TABLE it_ccreqno WHERE status_pfo = 'FORWARD'.

  ELSEIF r5 = 'X'.
    SELECT ccreqno status_rp FROM zjv_cash_call
  INTO TABLE it_ccreqno WHERE status_rp = 'PENDING'.

**      BOC by ss on 25.8.21
**      F4 data fetch for Reviewer
  ELSEIF r8 = 'X'.
    SELECT ccreqno status_rev FROM zjv_cash_call
    INTO TABLE it_ccreqno WHERE status_rev = 'PENDING'.
**   EOC by ss on 25.8.21
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CCREQNO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-CCREQNO'
      value_org       = 'S'
    TABLES
      value_tab       = it_ccreqno
      return_tab      = it_retn
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT it_retn INTO wa_retn.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VAL_VNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE val_vname INPUT.
  IF gwa_jv_cc-bukrs IS NOT INITIAL AND gwa_jv_cc-vname IS NOT INITIAL.
    SELECT SINGLE vname FROM t8jv
     INTO @DATA(v_vname) WHERE
      vname = @gwa_jv_cc-vname AND
      bukrs = @gwa_jv_cc-bukrs .
*      AND operator NE 'JV-OVL'.
    IF sy-subrc NE 0.
      MESSAGE 'Invalid entry, please enter correct data' TYPE 'E'.
    ENDIF.

    SELECT SINGLE vtype FROM t8jv
       INTO gwa_jv_cc-vtype WHERE
      vname = gwa_jv_cc-vname AND
      bukrs = gwa_jv_cc-bukrs.
*      AND operator NE 'JV-OVL'.

    IF gwa_jv_cc-vtype EQ '2'.
      SELECT SINGLE operator FROM t8jv
       INTO gwa_jv_cc-partn WHERE
      vname = gwa_jv_cc-vname AND
      bukrs = gwa_jv_cc-bukrs AND
      vtype = gwa_jv_cc-vtype.

    ELSE.
      gwa_jv_cc-partn = 'JV-OVL'.
*      operator NE 'JV-OVL',.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_data INPUT.

  SELECT SINGLE bname FROM usr01
    INTO @DATA(v_bname) WHERE bname = @gwa_jv_cc-prj_cord.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-prj_cord.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-prj_man.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-prj_man.
*   call SCREEN 9000.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-fc_approver.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-fc_approver.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-rp_approver.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-rp_approver.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-treasury1.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-treasury1.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.
  IF  gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-treasury2.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-treasury2.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.
  IF  gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-treasury3.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc) WITH gwa_jv_cc-treasury3.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-cb_acc1.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc) WITH gwa_jv_cc-cb_acc1.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.
  IF  gwa_jv_cc-cb_acc2 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-cb_acc2.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-cb_acc2.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.
  IF  gwa_jv_cc-cb_acc3 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-cb_acc3.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc) WITH gwa_jv_cc-cb_acc3.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.

  SELECT SINGLE bname FROM usr01
INTO v_bname WHERE bname = gwa_jv_cc-pf_officer.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-pf_officer.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  IF gwa_jv_cc-recoff = '2' AND gwa_clog-nrcomm IS INITIAL.
    MESSAGE e002(zfi_cc).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  DEL_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHNG_MAIL_PM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_JV_CC_PRJ_MAN  text
*      -->P_GV_NAME1  text
*      -->P_GWA_JV_CC_CCREQNO  text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9050 INPUT.
  IF ok_code = 'SAVE'.

*    TABLES: ZFI_BANK_DETAILS.
***    wa_bank- = I_PAYEE
*
*    DATA: BNUM(7) TYPE C.
*
*    SELECT MAX( BANKL ) FROM ZFI_BANK_DETAILS INTO @DATA(GS_BANK).
*
*    IF GS_BANK IS NOT INITIAL.
**    wa_bank-bankl = gs_bank.
*      BNUM = GS_BANK+3(7) + 1.
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT  = BNUM
*        IMPORTING
*          OUTPUT = BNUM.
*
*      CONCATENATE 'BEN' BNUM INTO WA_BANK-BANKL.
**    wa_bank-bankl = wa_bank-bankl+3(7) + 1.
*    ELSE.
*      WA_BANK-BANKL = 'BEN0000001'.
*    ENDIF.
*        ORDER BY CCREQNO DESCENDING.
    SELECT SINGLE * FROM zfi_bank_details INTO @DATA(gs_bank)
      WHERE bankn = @wa_bank-bankn.

    IF sy-subrc EQ 0.
      MESSAGE 'Bank account already exits' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.
***  Added by ss on 23.9.2021
*    SELECT max( sno ) from ZFI_BANK_DETAILS INTO lv_no.
*
*    lv_no = lv_no + 1.
*    wa_bank-sno = lv_no.
*    CLEAR lv_no.
***  EOC by ss on 23.9.2021

    INSERT zfi_bank_details FROM wa_bank.
    IF sy-subrc = 0.
      MESSAGE 'Beneficiary added successfully' TYPE 'I'.
    ENDIF.
    CLEAR: wa_bank.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9040 INPUT.

*CLEAR: ZFI_BANK_PAYEE-BANKN, WA_BANK, GWA_JV_CC-VALUE_DATE.

  ok_code = sy-ucomm.
  IF ok_code = 'UPDTBANK'.
    CALL SCREEN 9050.

  ELSEIF ok_code = 'DELETE'.
    CALL SCREEN 9060.

  ELSEIF ok_code = 'SAVE'.
    SELECT * FROM ZJV_CASH_CALL INTO @DATA(GS_CC) UP TO 1 ROWS
 WHERE CCREQNO EQ @GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF gs_cc-status_rp NE 'APPROVED'.
      MESSAGE 'Cash Call Request not approved by RP' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

    IF gwa_jv_cc-ccreqno IS NOT INITIAL AND zfi_bank_payee-bankn IS NOT INITIAL
      AND wa_bank-bankn IS NOT INITIAL AND gwa_jv_cc-value_date IS NOT INITIAL .



*      SELECT SINGLE refno FROM zjv_cash_call
*                          INTO @DATA(lv_num)
*                          WHERE ccreqno EQ @gwa_jv_cc-ccreqno.
*
*      IF lv_num IS INITIAL.
*
***   BOC by ss on 23.9.2021
*        CALL FUNCTION 'NUMBER_GET_NEXT'
*          EXPORTING
*            nr_range_nr = g_nrrangenr
*            object      = g_nrobj1
*          IMPORTING
*            number      = l_docno.
*
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        gwa_jv_cc-refno1 = l_docno.
*
*        UPDATE zjv_cash_call SET pbankn = zfi_bank_payee-bankn
*                                 bbankn = wa_bank-bankn
*                                 value_date = gwa_jv_cc-value_date
*                                 refno =  gwa_jv_cc-refno1
*                           WHERE ccreqno = gwa_jv_cc-ccreqno.
*      ELSE.
***    EOC by ss on 23.9.2021

        UPDATE zjv_cash_call SET pbankn = zfi_bank_payee-bankn
                                   bbankn = wa_bank-bankn
                                   value_date = gwa_jv_cc-value_date
                             WHERE ccreqno = gwa_jv_cc-ccreqno.
*      ENDIF.
      IF sy-subrc = 0.
        MESSAGE 'Record update successfully' TYPE 'I'.
        LEAVE TO TRANSACTION 'ZJVCC'.
      ENDIF.
    ELSE.

      MESSAGE 'Fill in all the required fields' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

  ELSEIF ok_code = 'FORMS'.
    DATA : v_msg TYPE string.
    CLEAR : gs_cc.
    SELECT * FROM ZJV_CASH_CALL INTO GS_CC UP TO 1 ROWS
 WHERE CCREQNO EQ GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.


    IF gs_cc-bbankn IS INITIAL OR gs_cc-pbankn IS INITIAL .
      MESSAGE 'Please link Cash call Request with Bank account' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

** added by ss on 16.7.21
    IF gs_cc-value_date IS INITIAL.
      MESSAGE 'Kindly enter the value date' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.
**   EOC by ss on 16.7.21

    IF gs_cc-status_rp NE 'APPROVED'.
      MESSAGE 'Cash Call Request not approved by RP' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

**    BOC on 13.5
    SELECT SINGLE * FROM zfi_bank_payee INTO @DATA(wa_payee)
                          WHERE bankn EQ @gs_cc-pbankn.

    IF wa_payee-currency NE gs_cc-waers.

*if GS_CC-WAERS is INITIAL.




      SELECTION-SCREEN BEGIN OF SCREEN 600 TITLE act AS WINDOW.
      PARAMETERS: lv_dmbtr TYPE dmbtr.
      SELECTION-SCREEN END OF SCREEN 600.


      CONCATENATE 'Amount in' wa_payee-currency INTO act SEPARATED BY space.

      IF gs_cc-dmbtr IS NOT INITIAL.
        lv_dmbtr = gs_cc-dmbtr.
      ENDIF.

*INITIALIZATION.
*    %_lv_dmbtr_%_app_%-text = 'Carrier ID'.

      CALL SELECTION-SCREEN '0600' STARTING AT 10 10.

      IF lv_dmbtr IS INITIAL.
        CONCATENATE 'Enter Amount in' wa_payee-currency INTO v_msg SEPARATED BY space.
        MESSAGE v_msg TYPE 'E'.
      ENDIF.

      UPDATE zjv_cash_call SET dmbtr = lv_dmbtr
                           WHERE ccreqno
                           EQ gwa_jv_cc-ccreqno.

      CLEAR: lv_dmbtr, v_msg.

*ENDIF.
    ENDIF.
**  EOC on 13.5

    CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.
*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZCC_AUTHORITY_LETTER'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = v_fm
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION v_fm
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        control_parameters = lw_ssfctrlop
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
        output_options     = wa_ssfcompop
        user_settings      = ' '
        ccreqno            = gwa_jv_cc-ccreqno
      IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
        job_output_info    = gt_otf
*       JOB_OUTPUT_OPTIONS =
*        TABLES
*       IT_LOG             = GIT_CLOG
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].
    CLEAR gt_otf.


    IF wa_payee-country EQ 'IN' AND  wa_bank-bank_country NE 'IN'.   "added 12.5
*    IF GS_CC-PBANKN NE '10604101'.               " commented on 12.5
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZCC_FORM_A2'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          fm_name            = v_fm
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


      CALL FUNCTION v_fm
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          ccreqno            = gwa_jv_cc-ccreqno
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
*        TABLES
*         IT_LOG             = GIT_CLOG
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      CLEAR : gt_otf.
    ENDIF.

*IF   WA_BANK-BANK_COUNTRY EQ 'IN'.  " added by ss on 16.7.2021
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZCC_FEMA_FORM'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = v_fm
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION v_fm
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        control_parameters = lw_ssfctrlop
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
        output_options     = wa_ssfcompop
        user_settings      = ' '
*       CCREQNO            = GWA_JV_CC-CCREQNO
      IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
        job_output_info    = gt_otf
*       JOB_OUTPUT_OPTIONS =
*        TABLES
*       IT_LOG             = GIT_CLOG
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

    CLEAR : gt_otf.

*endif.   " added by ss on 16.7.21

    IF gt_otf_hr IS NOT INITIAL.
      CALL FUNCTION 'HR_IT_DISPLAY_WITH_PDF'
* EXPORTING
*   IV_PDF          =
        TABLES
          otf_table = gt_otf_hr-otfdata[].
    ENDIF.
  ENDIF.
*  ENDIF.

  CLEAR: ok_code.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_REQNO_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_reqno_9040 INPUT.
  TYPES: BEGIN OF ty_req,
           ccreqno   TYPE zjv_cash_call-ccreqno,
           status_rp TYPE zjv_cash_call-status_pm,
         END OF ty_req.

  DATA: it_tab TYPE STANDARD TABLE OF ty_req.
*        IT_RETN    TYPE STANDARD TABLE OF DDSHRETVAL,
*        WA_RETN    TYPE DDSHRETVAL.


  SELECT ccreqno status_rp FROM zjv_cash_call INTO TABLE it_tab
    WHERE status_rp = 'APPROVED'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'CCREQNO'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'GWA_JV_CC-CCREQNO'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*     IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_tab
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_BANKL_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_bankl_9040 INPUT.
  TYPES: BEGIN OF ty_req1,
*           BANKL TYPE ZFI_BANK_DETAILS-BANKL,
           bankn        TYPE zfi_bank_details-bankn,
           name1        TYPE zfi_bank_details-name1,
           banka        TYPE zfi_bank_details-banka,
           bank_addr    TYPE zfi_bank_details-bank_addr,
           bank_country TYPE zfi_bank_details-bank_country,  " added on 12.5
         END OF ty_req1.


  DATA: it_tab1 TYPE STANDARD TABLE OF ty_req1.
*        IT_RETN    TYPE STANDARD TABLE OF DDSHRETVAL,
*        WA_RETN    TYPE DDSHRETVAL.


  SELECT * FROM zfi_bank_details INTO CORRESPONDING FIELDS OF TABLE it_tab1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'BANKN'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'WA_BANK-BANKN'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*     IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_tab1
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_BANK_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bank_data INPUT.
  DATA: v_bankn TYPE bankn.

** BOC on 6.5.21 by ss
  IF gwa_jv_cc-ccreqno IS NOT INITIAL.
    SELECT * FROM ZJV_CASH_CALL INTO @DATA(WA_TAB) UP TO 1 ROWS
 WHERE CCREQNO EQ @GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc EQ 0 AND wa_tab-pbankn IS NOT INITIAL
                     AND wa_tab-bbankn IS NOT INITIAL .
      zfi_bank_payee-bankn = wa_tab-pbankn.
      wa_bank-bankn        = wa_tab-bbankn.
      gwa_jv_cc-value_date = wa_tab-value_date.

*      SHIFT wa_tab-refno LEFT DELETING LEADING '0'. "added by ss on 23.9.2021
*      gwa_jv_cc-refno1      = wa_tab-refno.  "added by ss on 23.9.2021

    ENDIF.
    CLEAR wa_tab.
  ENDIF.
**  EOC on 6.5.21.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_9050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  IF ok_code = 'BACK'.
    CLEAR wa_bank.
    CALL SCREEN 9040.

  ELSEIF ok_code = 'CANC'.
    LEAVE TO TRANSACTION 'ZJVCC'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9060  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9060 INPUT.
  IF ok_code = 'DELETE'.
    DELETE FROM zfi_bank_details WHERE bankn = wa_bank-bankn.
    IF sy-subrc = 0.

      MESSAGE 'The record is deleted' TYPE 'I'.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_BANKN_PAYEE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_bankn_payee INPUT.
  TYPES: BEGIN OF ty_payee,
           bankn    TYPE zfi_bank_payee-bankn,
           name1    TYPE zfi_bank_payee-name1,
           street   TYPE zfi_bank_payee-street,
           city1    TYPE zfi_bank_payee-city1,
           country  TYPE zfi_bank_payee-country,  " added on 12.5
           currency TYPE zfi_bank_payee-currency,
         END OF ty_payee.



  DATA: it_payee TYPE STANDARD TABLE OF ty_payee.
*        IT_RETN    TYPE STANDARD TABLE OF DDSHRETVAL,
*        WA_RETN    TYPE DDSHRETVAL.


  SELECT * FROM zfi_bank_payee INTO CORRESPONDING FIELDS OF TABLE it_payee.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'BANKN'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'ZFI_BANK_PAYEE-BANKN'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*     IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_payee
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  COUNTRY_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*


MODULE country_code INPUT.
  SELECT land1, landx FROM t005t INTO TABLE @DATA(it_ccode).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'LAND1'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'WA_BANK-BANK_ADDR_ALPHA2'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*        IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_ccode
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*        EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_PAYEE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_payee_data INPUT.
  v_bankn = wa_bank-bankn.
  CLEAR wa_bank.
  IF v_bankn IS NOT INITIAL.
    SELECT SINGLE * FROM zfi_bank_details INTO wa_bank WHERE bankn =
v_bankn.
  ENDIF.
  CLEAR v_bankn.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DATE_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE date_validate INPUT.


  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date = gwa_jv_cc-value_date.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_APPROVER6  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_approver6 INPUT.

*  TYPES: BEGIN OF TY_USER,
*           BNAME     TYPE BNAME,
*           NAME_LAST TYPE NAME_TEXT,
*         END OF TY_USER.
  DATA: lit_user6   TYPE STANDARD TABLE OF ty_user,
        lit_return6 TYPE STANDARD TABLE OF ddshretval.
*        LWA_RETURN TYPE DDSHRETVAL.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user6.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-REVIEWER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user6
      return_tab      = lit_return6
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return6 INTO lwa_return.
*      gv_fc_approver = lwa_return-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.

ENDMODULE.

*--- INCLUDE: SAPMZOVL_JV_CC_PBO ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
*  SET PF-STATUS 'ZPF_STATUS'.
*  SET TITLEBAR 'ZTITLE'.

  IF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group3 = 'DIS'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS NOT INITIAL AND lfct_9000 IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group3 = 'DIS'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.

      IF screen-group2 = 'DIS' AND gwa_jv_cc-del_ind NE 'X' AND ( gwa_jv_cc-status_pm  = 'REJECTED'
                                                            OR    gwa_jv_cc-status_fc  = 'REJECTED'
                                                            OR    gwa_jv_cc-status_pfo = 'REJECTED'
                                                            OR    gwa_jv_cc-status_rp  = 'REJECTED'
                                                            OR    gwa_jv_cc-status_rev = 'REJECTED' ).  " added by ss on 24.8.21
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF lfct_9000 NE 'DELE'.
    LOOP AT SCREEN.
      IF screen-group1 = 'CHA'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

    gwa_jv_cc-prj_cord = sy-uname.
  ENDIF.

  IF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS NOT INITIAL AND lfct_9000 IS INITIAL.
    LOOP AT SCREEN.
    IF screen-group4 = 'NA1' AND ( gwa_jv_cc-status_pm  EQ 'REJECTED' OR  gwa_jv_cc-status_pm  EQ 'PENDING'
                             OR    gwa_jv_cc-status_fc  EQ 'PENDING'
                             OR    gwa_jv_cc-status_pfo EQ 'PENDING'
                             OR    gwa_jv_cc-status_rp  EQ 'PENDING'
                             OR    gwa_jv_cc-status_rev EQ 'PENDING' ).
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*****************************************************************************************

  IF r1 = 'X'.
    IF gwa_jv_cc-prj_cord = sy-uname.
       LOOP AT SCREEN.
       IF screen-name = 'CHA1' .
           screen-input = 1.
         MODIFY SCREEN.
       ENDIF.
       ENDLOOP.
    ELSE.
      LOOP AT SCREEN.
      IF screen-name = 'CHA1' .
          screen-input = 1.
          screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

************************************

IF CHA_WF IS NOT INITIAL.

  IF CHA_WF = '/CHA_PM'.
      LOOP AT SCREEN.
       IF ( screen-name = 'GWA_JV_CC-PRJ_MAN' OR screen-name = 'UP_WFBT ' ).
        screen-input = 1.
       MODIFY SCREEN.
       ENDIF.
      ENDLOOP.
  ENDIF.
ENDIF.
******************************************************************************************

  IF gwa_jv_cc-vname IS NOT INITIAL.
    SELECT SINGLE vtext FROM t8jvt INTO gv_vtext WHERE vname = gwa_jv_cc-vname
                                                 AND bukrs = gwa_jv_cc-bukrs
                                                 AND spras = 'E'.
  ENDIF.

  IF gwa_jv_cc-prj_cord IS NOT INITIAL.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*    SELECT SINGLE name_last FROM user_addr INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord ORDER BY name_last. ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
  ENDIF.

  IF gwa_jv_cc-prj_man IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name2 WHERE bname = gwa_jv_cc-prj_man.
  ENDIF.

  IF gwa_jv_cc-fc_approver IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name3 WHERE bname = gwa_jv_cc-fc_approver.
  ENDIF.

  IF gwa_jv_cc-pf_officer IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name4 WHERE bname = gwa_jv_cc-pf_officer.
  ENDIF.

  IF gwa_jv_cc-rp_approver IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name5 WHERE bname = gwa_jv_cc-rp_approver.
  ENDIF.


  IF gwa_jv_cc-ccreqno IS NOT INITIAL.  " Added by ss on 6.8.2021
    SELECT NRCOMM FROM ZJV_CC_COMM_LOG
 INTO GWA_CLOG-NRCOMM UP TO 1 ROWS WHERE CCREQNO EQ GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

   IF gwa_clog-bnk_dtls IS INITIAL.
    SELECT BNK_DTLS FROM ZJV_CC_COMM_LOG
 INTO GWA_CLOG-BNK_DTLS UP TO 1 ROWS WHERE CCREQNO EQ GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
   ENDIF.
  ENDIF.

**  BOC by ss on 24.8.21 for displaying username data for Reviewer
  IF gwa_jv_cc-reviewer IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr
                            INTO gv_name6
                            WHERE bname = gwa_jv_cc-reviewer.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_FILL_PROJECT_CORDINATOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_fill_project_cordinator OUTPUT.
*  gv_prj_cord = sy-uname.

  CREATE OBJECT editor_container
    EXPORTING
      container_name              = 'TEXTEDITOR'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.

  CREATE OBJECT text_editor
    EXPORTING
      parent                     = editor_container
      wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
      wordwrap_position          = line_length
      wordwrap_to_linebreak_mode = cl_gui_textedit=>true.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9010 OUTPUT.
  SET PF-STATUS 'ZSTATUS'.
  SET TITLEBAR 'ZTITLE'.
*  CALL SCREEN 9010.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TS 'TS_9020'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE ts_9020_active_tab_set OUTPUT.
  IF flag_disp = 'X'.
    CLEAR flag_disp.
    ts_9020-activetab = g_ts_9020-pressed_tab = c_ts_9020-tab3.
  ELSE.
    ts_9020-activetab = g_ts_9020-pressed_tab.
  ENDIF.
  CASE g_ts_9020-pressed_tab.
    WHEN c_ts_9020-tab1.
      IF gwa_jv_cc-ccreqno IS NOT INITIAL.
        CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2,
                 gv_name3, gv_name4, gv_name5,gv_name6, gwa_clog.
      ENDIF.
      g_ts_9020-subscreen = '9000'.
    WHEN c_ts_9020-tab2.
      g_ts_9020-subscreen = '9000'.
    WHEN c_ts_9020-tab3.
      g_ts_9020-subscreen = '9000'.
    WHEN c_ts_9020-tab4.
      g_ts_9020-subscreen = '9000'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9020 OUTPUT.

  SET PF-STATUS 'ZPFS_SAVE'.
*  SET TITLEBAR 'ZTITLE'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9030  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9030 OUTPUT.
  SET PF-STATUS 'ZPF_STATUS'.
*  SET TITLEBAR 'ZTITLE'.

  CLEAR: appr, fwd.
  IF gwa_jv_cc-ccreqno IS NOT INITIAL AND flag_data = 'X'.
    IF gwa_jv_cc-created_on IS NOT INITIAL
           AND gwa_jv_cc-del_ind IS INITIAL.

**  For Projet Manager
      IF r2 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
*            appr = 'Forward    '. " commented by ss on 24.8.21
            appr = 'Fwd to IPF'. " added by ss on 24.8.21
          ENDIF.
**       Added by ss on 24.8.21 for adding the
**          forward to Reviewer  button text
          IF screen-name = 'FWD' .
            fwd = 'Fwd to Reviewer'.
          ENDIF.
**         BOC by ss on 24.8.21
          IF  ( screen-name = 'APPR' or screen-name = 'REJ')
            and gwa_jv_cc-status_pm = 'PENDING' and GWA_JV_CC-REVIEWER is INITIAL..
            screen-input = 1.
          ELSEIF ( screen-name = 'REJ' or screen-name = 'FWD' )
            AND gwa_jv_cc-status_pm = 'PENDING' and GWA_JV_CC-REVIEWER is NOT INITIAL.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
**   EOC by ss
**        For Incharge Project Finance
      ELSEIF r3 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Concurr    '.
          ENDIF.
          IF screen-name = 'FWD'.
            fwd = 'Fwd to PFO '.
          ENDIF.
**          Commented by ss on 6.9.21
*          IF screen-group4 = 'APP' AND gwa_jv_cc-status_fc = 'PENDING'
*            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD').
***            Added by ss on 25.8.21
*            IF GWA_JV_CC-REVIEWER is INITIAL.
*                screen-input = 1.
*            ELSE.
*              IF gwa_jv_cc-status_rev = 'APPROVED'.
*                screen-input = 1.
*               else.
*                 screen-input = 0.
*              ENDIF.
*            ENDIF.
***            EOC by ss.
**            screen-input = 1.  "commented by ss on 25.8.21
*          ELSE.
*            screen-input = 0.
*          ENDIF.
**End of Comments by ss on 9.9.21


**  Added by ss on 9.9.2021
          IF screen-group4 = 'APP'.
           if  gwa_jv_cc-STATUS_REV is not INITIAL.

            IF ( gwa_jv_cc-status_rev = 'APPROVED' and
                 gwa_jv_cc-status_fc =  'PENDING'   and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.

            ELSEIF ( gwa_jv_cc-status_rev = 'APPROVED' and
                     gwa_jv_cc-status_fc =  'PENDING'   and
                     gwa_jv_cc-status_pfo = 'APPROVED' ).

              screen-input = 1.
           ELSE.
             screen-input = 0.
          ENDIF.

         else.

            IF ( gwa_jv_cc-status_rev is INITIAL  and
                 gwa_jv_cc-status_fc =  'PENDING' and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.

            ELSEIF ( gwa_jv_cc-status_rev is INITIAL  and
                     gwa_jv_cc-status_fc =  'PENDING'   and
                     gwa_jv_cc-status_pfo = 'APPROVED' ).

              screen-input = 1.
           ELSE.
             screen-input = 0.
          ENDIF.
      endif.
      MODIFY SCREEN.
  endif.

**          EOC  by  ss 9.9.21
**   Commented on 6.9.21
*          IF screen-group4 = 'PFO' AND gwa_jv_cc-status_fc = 'PENDING'
*            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD')
*            AND gwa_jv_cc-status_pfo = 'PENDING'.
***            Added by ss on 25.8.21
*            IF GWA_JV_CC-REVIEWER is INITIAL.
*                screen-input = 1.
*            ELSE.
*              IF gwa_jv_cc-status_rev = 'APPROVED'.
*                screen-input = 1.
*              else.
*                screen-input = 0.
*              ENDIF.
*            ENDIF.
*             ELSE.
**            screen-input = 0.
**          ENDIF.
***            EOC by ss.
**            screen-input = 1.
*          ENDIF.
**          End of comment
************BOC by ss *

          IF screen-group4 = 'PFO' .
               IF ( gwa_jv_cc-status_rev = 'APPROVED' and
                 gwa_jv_cc-status_fc =  'PENDING'   and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.

               ELSEIF (  gwa_jv_cc-status_rev IS INITIAL and
                 gwa_jv_cc-status_fc =  'PENDING'   and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.
                else.
                  screen-input = 0.
               ENDIF.
          ENDIF.
**********************  EOC by ss on 6.9.21
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.

*          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      ELSEIF r4 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Approve    '.
          ENDIF.
          IF screen-name = 'FWD'.
            fwd = 'Submit     '.
          ENDIF.
          IF screen-group4 = 'PFO' AND gwa_jv_cc-status_pfo = 'FORWARD'
            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD' ).
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      ELSEIF r5 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Approve    '.
          ENDIF.
          IF screen-group4 = 'APP' AND gwa_jv_cc-status_rp = 'PENDING' AND gwa_jv_cc-status_fc = 'APPROVED'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

**       Added by ss on 24.8.21
      ELSEIF r8 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Approve    '.
          ENDIF.
          IF screen-group4 = 'APP' AND gwa_jv_cc-status_rev = 'PENDING'
            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD' ).
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
**  EOC by ss
      ENDIF.

    ELSEIF gwa_jv_cc-created_on IS NOT INITIAL AND gwa_jv_cc-del_ind IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group3 = 'DIS'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        IF screen-name = 'GWA_CLOG-COMM_TXT'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
        IF screen-name = 'GWA_CLOG-BNK_DTLS'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group3 = 'DIS'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      IF screen-name = 'GWA_CLOG-COMM_TXT'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
       IF screen-name = 'GWA_CLOG-BNK_DTLS'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

* IF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS NOT INITIAL .
    LOOP AT SCREEN.
    IF screen-group4 = 'NA1' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
      IF gwa_jv_cc-status_pm NE 'PENDING' AND r2 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ELSEIF gwa_jv_cc-status_rev  NE 'PENDING' AND r8 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
*      ELSEIF gwa_jv_cc-status_fc  EQ 'PENDING' AND r3 = 'X'.
*        screen-input = 0.
*        MODIFY SCREEN.
      ELSEIF gwa_jv_cc-status_fc  NE 'PENDING' AND gwa_jv_cc-status_pfo NE 'PENDING' AND r3 = 'X'.
*         IF screen-group3 = 'NA2'.
           screen-input = 0.
           MODIFY SCREEN.
*         ENDIF.
      ELSEIF gwa_jv_cc-status_pfo EQ 'FORWARD' AND r3 = 'X'.
*         IF screen-group3 = 'NA2'.
           screen-input = 0.
           MODIFY SCREEN.
*         ENDIF.
      ELSEIF gwa_jv_cc-status_pfo EQ 'APPROVED' AND r4 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ELSEIF gwa_jv_cc-status_rp  NE 'PENDING' AND r5 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
     ENDIF.

     IF screen-group4 = 'NA1' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
       IF gwa_jv_cc-status_fc  EQ 'APPROVED' AND gwa_jv_cc-status_pfo EQ 'APPROVED' AND r3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
     ENDIF.
     ENDIF.

     IF screen-group3 = 'NA2' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
       IF gwa_jv_cc-status_fc  EQ 'PENDING' AND gwa_jv_cc-status_pfo EQ 'APPROVED' AND r3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
     ENDIF.
     ENDIF.

     IF screen-group3 = 'NA2' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
       IF gwa_jv_cc-status_fc  EQ 'PENDING' AND gwa_jv_cc-status_pfo EQ 'PENDING' AND r3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
     ENDIF.
     ENDIF.

*     IF screen-name = 'GWA_CLOG-COMM_TXT' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
*       IF gwa_jv_cc-status_fc  EQ 'PENDING' AND r3 = 'X'.
*        screen-input = 1.
*        MODIFY SCREEN.
*       ENDIF.
*     ENDIF.
*       IF gwa_jv_cc-status_fc  EQ 'APPROVED' AND gwa_jv_cc-status_pfo EQ 'APPROVED' AND r3 = 'X'.
*        screen-input = 0.
*        MODIFY SCREEN.
*       ENDIF.
*     ENDIF.

    ENDLOOP.
*  ENDIF.

****************************************************************************************
LOOP AT SCREEN.
  IF ( SCREEN-NAME = 'CHA2' or SCREEN-NAME = 'CHA3' or SCREEN-NAME = 'CHA4'  ).
     screen-input = 1.
     screen-invisible = 1.
     MODIFY SCREEN.
  ENDIF.
  IF SCREEN-NAME = 'UP_WFBT'.
     screen-input = 0.
     MODIFY SCREEN.
  ENDIF.
ENDLOOP.

IF r2 = 'X'.
   IF gwa_jv_cc-prj_man = sy-uname.
    LOOP AT SCREEN.
    IF  screen-name = 'CHA2' .
        screen-input = 1.
        screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
    ENDLOOP.
   ENDIF.

  ELSEIF r3 = 'X'.
   IF gwa_jv_cc-fc_approver = sy-uname.
*     IF gwa_jv_cc-status_pfo = 'FORWARD'.
*        LOOP AT SCREEN.
*        IF screen-name = 'CHA4' .
*         screen-input = 1.
*         screen-invisible = 0.
*         MODIFY SCREEN.
*        ENDIF.
*       ENDLOOP.
*     ELSE.
        LOOP AT SCREEN.
        IF  screen-name = 'CHA3' OR screen-name = 'CHA4'.
            screen-input = 1.
            screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.
        ENDLOOP.
*     ENDIF.
   ENDIF.

  ELSEIF r4 = 'X'.
   IF gwa_jv_cc-pf_officer = sy-uname.
    LOOP AT SCREEN.
    IF screen-name = 'CHA4' .
        screen-input = 1.
        screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
    ENDLOOP.
   ENDIF.

*  ELSEIF r5 = 'X'.
*   IF gwa_jv_cc-rp_approver = sy-uname.
*    LOOP AT SCREEN.
*    IF screen-name = 'CHA4'.
*        screen-input = 1.
*      MODIFY SCREEN.
*    ENDIF.
*    ENDLOOP.
*   ENDIF.
  ENDIF.

***************************************

IF CHA_WF IS NOT INITIAL.

  IF CHA_WF = '/CHA_PF'.
      LOOP AT SCREEN.
        IF ( screen-name = 'GWA_JV_CC-FC_APPROVER' OR screen-name = 'UP_WFBT ' ).
          screen-input = 1.
           screen-invisible = 0.
         MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
   SAVE_WF = 'UP_PF'.

  ELSEIF CHA_WF = '/CHA_PFO'.
      LOOP AT SCREEN.
       IF ( screen-name = 'GWA_JV_CC-PF_OFFICER' OR screen-name = 'UP_WFBT ' ).
          screen-input = 1.
           screen-invisible = 0.
         MODIFY SCREEN.
       ENDIF.
      ENDLOOP.
   SAVE_WF = 'UP_PFO'.

  ELSEIF CHA_WF = '/CHA_RP'.
      LOOP AT SCREEN.
        IF ( screen-name = 'GWA_JV_CC-RP_APPROVER' OR screen-name = 'UP_WFBT ' ).
          screen-input = 1.
          screen-invisible = 0.
         MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
     SAVE_WF = 'UP_RP'.
  ENDIF.
  CLEAR CHA_WF.

ENDIF.
**********************************************************************************************

  IF gwa_jv_cc-vname IS NOT INITIAL.
    SELECT SINGLE vtext FROM t8jvt INTO gv_vtext WHERE vname = gwa_jv_cc-vname
                                                   AND bukrs = gwa_jv_cc-bukrs
                                                   AND spras = 'E'.
  ENDIF.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
  IF gwa_jv_cc-prj_cord IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord ORDER BY name_last. ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-prj_man IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name2 WHERE bname = gwa_jv_cc-prj_man.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name2 WHERE bname = gwa_jv_cc-prj_man ORDER BY name_last.ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-fc_approver IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name3 WHERE bname = gwa_jv_cc-fc_approver.
        SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name3 WHERE bname = gwa_jv_cc-fc_approver ORDER BY name_last. ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-pf_officer IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name4 WHERE bname = gwa_jv_cc-pf_officer.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name4 WHERE bname = gwa_jv_cc-pf_officer ORDER BY name_last. ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-rp_approver IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name5 WHERE bname = gwa_jv_cc-rp_approver.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name5 WHERE bname = gwa_jv_cc-rp_approver ORDER BY name_last. ENDSELECT.
  ENDIF.

**  Added by ss on 24.8.21
  IF gwa_jv_cc-reviewer IS NOT INITIAL..
*    SELECT SINGLE name_last FROM user_addr INTO gv_name6 WHERE bname = gwa_jv_cc-REVIEWER.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name6 WHERE bname = gwa_jv_cc-REVIEWER ORDER BY name_last. ENDSELECT.
  ENDIF.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
**  Fetch data for Remark field
  SELECT NRCOMM FROM ZJV_CC_COMM_LOG INTO GWA_CLOG-NRCOMM UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT BNK_DTLS FROM ZJV_CC_COMM_LOG INTO GWA_CLOG-BNK_DTLS UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

**  EOC by ss on 24.8.21
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9040  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_9040 OUTPUT.

  SET PF-STATUS 'ZPF_BANKSTAT'.
  LOOP AT SCREEN.
    IF screen-group1 = 'GRP'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9050  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_9050 OUTPUT.
  IF ok_code EQ 'UPDTBANK'.  "added by ss on 4.5.21
    CLEAR: wa_bank, ok_code.
  ENDIF.
  SET PF-STATUS 'ZSTAT'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9060  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9060 OUTPUT.
  SET PF-STATUS 'ZSTAT_DEL'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.

*--- INCLUDE: SAPMZOVL_JV_CC_SUB ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SUB_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_exit .
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 9010.
    WHEN 'CANC'.
      LEAVE TO SCREEN 9010.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 9010.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REJ_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM rej_mail USING p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno .

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email       TYPE adr6-smtp_addr,
         bcs_exception TYPE REF TO cx_bcs.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.


  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been rejected for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).



    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
    CATCH cx_address_bcs.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
    CATCH cx_send_req_bcs INTO bcs_exception .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.



    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
    CATCH cx_send_req_bcs INTO bcs_exception .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
    CATCH cx_send_req_bcs INTO bcs_exception .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM fw_mail  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.


**  BOC by ss on 31.8.21

   IF gwa_jv_cc-FC_APPROVER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-FC_APPROVER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

**  EOC by ss on 31.8.21
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREA_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM crea_mail  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.
  DATA : message(100) TYPE c.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been created for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.

  REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

   SELECT SINGLE * FROM usr21 INTO v_user
    WHERE bname = GWA_JV_CC-PF_OFFICER.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.


**  BOC by ss on 31.8.21

  IF GWA_JV_CC-PRJ_MAN is not INITIAL.
  SELECT SINGLE * FROM usr21 INTO v_user   " for cc
    WHERE bname = GWA_JV_CC-PRJ_MAN.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

   IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

**  EOC by ss on 31.8.21
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
 CONCATENATE 'Request no' gwa_jv_cc-ccreqno 'created & mail sent successfully'
   INTO message SEPARATED BY space.


        MESSAGE message TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHNG_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM chng_mail  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

*  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
*    WHERE bname = @p_user.
*  SELECT SINGLE smtp_addr
*  FROM adr6
*  INTO p_email
*  WHERE persnumber = v_user-persnumber
*   AND  addrnumber = v_user-addrnumber.

 CONCATENATE 'Cash call request Changed:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been changed for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'The due date of payment is- ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please consider this as fund requirement intimation and arrange necessary funds.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @data(v_user)
    WHERE bname = @gwa_jv_cc-treasury1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury1.
  IF p_email IS NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
    TRY.
        lo_send_request->add_recipient(
            EXPORTING
            i_recipient = lo_recipient
            i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
    ENDTRY.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-treasury2.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury2.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

  CLEAR : p_email.

  IF gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-treasury3.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPR_MAIL_FC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER  text
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM appr_mail_fc  USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
   WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been concurred for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.


  CLEAR : p_email.

    IF gwa_jv_cc-RP_APPROVER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-RP_APPROVER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TREA_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM trea_mail  USING  p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been created for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'The due date of payment is- ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please consider this as fund requirement intimation and arrange necessary funds.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @gwa_jv_cc-treasury1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury1.
  IF p_email IS NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
    TRY.
        lo_send_request->add_recipient(
            EXPORTING
            i_recipient = lo_recipient
            i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
    ENDTRY.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-treasury2.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury2.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

  CLEAR : p_email.

  IF gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-treasury3.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
*        MESSAGE 'Mail Sent' TYPE 'S'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CNB_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM cnb_mail  USING  p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been approved by Competent Authority for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'Document no.' gwa_jv_cc-belnr 'posted for cash call due.The due date of payment is - ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please take necessary action for payment.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @data(v_user)
   WHERE bname = @gwa_jv_cc-cb_acc1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if p_email is NOT INITIAL.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-cb_acc1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  endif.

  CLEAR : p_email.
  IF gwa_jv_cc-cb_acc2 IS NOT INITIAL.
   SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-cb_acc2.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-cb_acc2.
    if p_email is NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
    TRY.
        lo_send_request->add_recipient(
        EXPORTING
        i_recipient = lo_recipient
        i_express = 'X'
        i_copy = abap_true ).
    ENDTRY.
    endif.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-cb_acc3 IS NOT INITIAL.
      SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-cb_acc3.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if p_email is NOT INITIAL.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-cb_acc3.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
    TRY.
        lo_send_request->add_recipient(
        EXPORTING
        i_recipient = lo_recipient
        i_express = 'X'
        i_copy = abap_true ).
    ENDTRY.
    ENDIF.
  ENDIF.

*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
*        MESSAGE 'Mail Sent' TYPE 'S'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPR_MAIL_RP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_REQNO  text
*----------------------------------------------------------------------*
FORM appr_mail_rp  USING  p_name TYPE ad_namtext p_reqno TYPE zccreqno.

  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = gwa_jv_cc-due_dt
    IMPORTING
      date_external            = due_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been approved by Competent Authority for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)
  'Document no.' gwa_jv_cc-belnr 'posted for cash call due.The due date of payment is - ' due_dt '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please take necessary action for payment/record keeping.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
 SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
   WHERE bname = @gwa_jv_cc-prj_cord.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-prj_cord.
    if p_email is NOT INITIAL.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  endif.



  CLEAR : p_email.
*  IF gwa_jv_cc-cb_acc3 IS NOT INITIAL.
*   SELECT SINGLE * FROM usr21 INTO v_user
*   WHERE bname = gwa_jv_cc-fc_approver.
*  SELECT SINGLE smtp_addr
*  FROM adr6
*  INTO p_email
*  WHERE persnumber = v_user-persnumber
*   AND  addrnumber = v_user-addrnumber.
**  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-prj_cord.
*    if p_email is NOT INITIAL.
**  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-pf_officer.
*  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*  TRY.
*      lo_send_request->add_recipient(
*      EXPORTING
*      i_recipient = lo_recipient
*      i_express = 'X'
*      i_copy = abap_true ).
*  ENDTRY.
*  ENDIF.


  CLEAR : p_email.
*  IF gwa_jv_cc-cb_acc3 IS NOT INITIAL.
   SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-pf_officer.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-prj_cord.
    if p_email is NOT INITIAL.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-fc_approver.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
  TRY.
      lo_send_request->add_recipient(
      EXPORTING
      i_recipient = lo_recipient
      i_express = 'X'
      i_copy = abap_true ).
  ENDTRY.
endif.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Data saved & mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POST_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_doc .


DATA g_date(10).
 DATA: l_mstring(480).
data: amt TYPE p.
data: lv_sgtxt(50), lv_type(21). " added on 12.10.21

** BOC by ss on 19.7.21
*Check for cashcall type
*i.e. 1-Project cashcall,
*2-Marine JIB cashcall,
*3-Abandonment cashcall

** Added by ss on 12.10.21
IF GWA_JV_CC-CCTYPE eq 1.
  lv_type = 'Project Cashcall'.
  ELSEIF GWA_JV_CC-CCTYPE eq 2.
    lv_type = 'Marine JIB Cashcall'.
  ELSEIF GWA_JV_CC-CCTYPE eq 3.
  lv_type = 'Abandonment Cashcall'.
ENDIF.
CONCATENATE GWA_JV_CC-VNAME  lv_type 'for'  GWA_JV_CC-OPP_MONTH
INTO LV_SGTXT SEPARATED BY space.

**  EOC by ss on 12.10.21


if  GWA_JV_CC-cctype eq '3'.
clear amt.
amt = GWA_JV_CC-WRBTR.
  clear g_date.
CONCATENATE GWA_JV_CC-due_dt+6(2) '.' GWA_JV_CC-due_dt+4(2) '.' GWA_JV_CC-due_dt+0(4)
INTO g_date.
*perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWUM'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BKPF-BLDAT'
                              g_date.  " Due date
perform bdc_field       using 'BKPF-BLART'
                              'JC'.
perform bdc_field       using 'BKPF-BUKRS'
                              GWA_JV_CC-BUKRS.
clear g_date.
CONCATENATE GWA_JV_CC-post_dt+6(2) '.' GWA_JV_CC-post_dt+4(2) '.' GWA_JV_CC-post_dt+0(4)
INTO g_date.
perform bdc_field       using 'BKPF-BUDAT'
                              g_date.
*perform bdc_field       using 'BKPF-MONAT'
*                              '10'.
perform bdc_field       using 'BKPF-WAERS'
                              GWA_JV_CC-waers.
perform bdc_field       using 'BKPF-XBLNR'
                              GWA_JV_CC-ccreqno.
perform bdc_field       using 'BKPF-BKTXT'
                              GWA_JV_CC-ccreqno.
*perform bdc_field       using 'FS006-DOCID'
*                              '*'.
perform bdc_field       using 'RF05A-NEWBS'
                              '40'.  "'2A'. " added by ss on 19.7.21
perform bdc_field       using 'RF05A-NEWKO'
                               '91916'.  "GWA_JV_CC-PARTN.
*perform bdc_field       using 'RF05A-NEWUM'
*                              '~'.
perform bdc_dynpro      using 'SAPMF05A' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWKO'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BSEG-WRBTR'
                              GWA_JV_CC-WRBTR.
perform bdc_field       using 'BSEG-ZFBDT'
                              g_date.   " Due date
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                             lv_sgtxt. " 'JV CC'.  " added on 12.10.21
perform bdc_field       using 'RF05A-NEWBS'
                              '50'.
perform bdc_field       using 'RF05A-NEWKO'
                              '91299'.
perform bdc_field       using 'DKACB-FMORE'
                              'X'.

perform bdc_dynpro      using 'SAPLKACB' '0002'.

perform bdc_field       using 'BDC_CURSOR'
                              'COBL-PRCTR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using 'COBL-GSBER'
                              'JV'.
perform bdc_field       using 'COBL-PRCTR'
                              GWA_JV_CC-PRCTR.

perform bdc_dynpro      using 'SAPMF05A' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'BSEG-WRBTR'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BSEG-WRBTR'
                              GWA_JV_CC-WRBTR.
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                              lv_sgtxt. "'JV CC'.   " 12.10.21
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.
perform bdc_field       using 'DKACB-FMORE'
                              'X'.
perform bdc_dynpro      using 'SAPLKACB' '0002'.

perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using 'COBL-GSBER'
                              'JV'.
perform bdc_field       using 'COBL-PRCTR'
                              GWA_JV_CC-PRCTR.

** EOC by ss on 19.7.2021
else.
clear amt.
amt = GWA_JV_CC-WRBTR.
  clear g_date.
CONCATENATE GWA_JV_CC-due_dt+6(2) '.' GWA_JV_CC-due_dt+4(2) '.' GWA_JV_CC-due_dt+0(4)
INTO g_date.
*perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWUM'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BKPF-BLDAT'
                              g_date.
perform bdc_field       using 'BKPF-BLART'
                              'JC'.
perform bdc_field       using 'BKPF-BUKRS'
                              GWA_JV_CC-BUKRS.

clear g_date.
CONCATENATE GWA_JV_CC-post_dt+6(2) '.' GWA_JV_CC-post_dt+4(2) '.' GWA_JV_CC-post_dt+0(4)
INTO g_date.
perform bdc_field       using 'BKPF-BUDAT'
                              g_date.
*perform bdc_field       using 'BKPF-MONAT'
*                              '10'.
perform bdc_field       using 'BKPF-WAERS'
                              GWA_JV_CC-waers.
perform bdc_field       using 'BKPF-XBLNR'
                              GWA_JV_CC-ccreqno.
perform bdc_field       using 'BKPF-BKTXT'
                              GWA_JV_CC-ccreqno.
perform bdc_field       using 'FS006-DOCID'
                              '*'.
perform bdc_field       using 'RF05A-NEWBS'
                               '2A'.
perform bdc_field       using 'RF05A-NEWKO'
                               GWA_JV_CC-PARTN.
perform bdc_field       using 'RF05A-NEWUM'
                              '~'.
perform bdc_dynpro      using 'SAPMF05A' '0304'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWUM'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
if GWA_JV_CC-waers ne 'COP'.
perform bdc_field       using 'BSEG-WRBTR'
                               GWA_JV_CC-WRBTR.
else.
perform bdc_field       using 'BSEG-WRBTR'
                               amt.
ENDIF.
perform bdc_field       using 'BSEG-GSBER'
                              'JV'.
perform bdc_field       using 'BSEG-ZFBDT'
                               g_date.
perform bdc_field       using 'BSEG-PRCTR'
                               GWA_JV_CC-PRCTR.
perform bdc_field       using 'BSEG-FIPOS'
                              'PAYABLE'.
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                               lv_sgtxt."GWA_JV_CC-ccreqno.  " added on 12.10.2021
perform bdc_field       using 'RF05A-NEWBS'
                               '3A'.
perform bdc_field       using 'RF05A-NEWKO'
                               GWA_JV_CC-PARTN.
perform bdc_field       using 'RF05A-NEWUM'
                              ':'.
perform bdc_dynpro      using 'SAPMF05A' '0304'.
perform bdc_field       using 'BDC_CURSOR'
                              'BSEG-SGTXT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=AB'.
if GWA_JV_CC-waers ne 'COP'.
perform bdc_field       using 'BSEG-WRBTR'
                               GWA_JV_CC-WRBTR.
else.
perform bdc_field       using 'BSEG-WRBTR'
                               amt.
ENDIF.
perform bdc_field       using 'BSEG-GSBER'
                              'JV'.
perform bdc_field       using 'BSEG-ZFBDT'
                               g_date.
perform bdc_field       using 'BSEG-PRCTR'
                              GWA_JV_CC-PRCTR.
perform bdc_field       using 'BSEG-FIPOS'
                              'PAYABLE'.
perform bdc_field       using 'BSEG-ZUONR'
                              'JV'.
perform bdc_field       using 'BSEG-SGTXT'
                              lv_sgtxt.  "'JV CC'." added on 12.10.21
perform bdc_dynpro      using 'SAPMF05A' '0700'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWBS'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.
*perform bdc_field       using 'BKPF-XBLNR'
*                              'CC'.
*perform bdc_field       using 'BKPF-BKTXT'
*                              'CC'.

endif. " Added by ss on 19.7.21

  DATA: l_mode(1).
  l_mode = 'E'.
DATA: ls_messtab TYPE bdcmsgcoll,
      ls_return  TYPE bapiret2.
 CALL TRANSACTION 'F-02' USING bdcdata
                   MODE   l_mode " 'A'  ""'E'  16052013  "'A'   "'N' "'E'   <RD1K975271> 01032011 28072012
                   UPDATE 'S'
                   MESSAGES INTO messtab.

 READ TABLE messtab WITH KEY MSGTYP = 'S'
                             MSGID  = 'F5'
                             MSGNR  = '312'.
 IF sy-subrc = 0.
  gwa_jv_cc-belnr = messtab-msgv1.

  else.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*   CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
*   TABLES
*   imt_bdcmsgcoll = messtab[]
*   ext_return  = bapiret2.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = ls_messtab-msgtyp
        cl     = ls_messtab-msgid
        number = ls_messtab-msgnr
        par1   = ls_messtab-msgv1
        par2   = ls_messtab-msgv2
        par3   = ls_messtab-msgv3
        par4   = ls_messtab-msgv4
      IMPORTING
        return = ls_return.
 APPEND ls_return TO bapiret2.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC

*Display messages from BAPIRET2
   CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
   TABLES
   it_return = bapiret2.

 ENDIF.
clear: bdcdata , messtab , bapiret2.
REFRESH: bdcdata,messtab , bapiret2.
ENDFORM.

FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                  " bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0831   text
*      -->P_0832   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
*  IF FVAL <> NODATA.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    SHIFT bdcdata-fval LEFT DELETING LEADING space.
    APPEND BDCDATA.
*  ENDIF.
ENDFORM.


FORM get_OTF_DATa TABLES i_objbin.
  DATA  g_att_files2 LIKE TABLE OF swotobjid.

  CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.
*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.

    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM zjv_cc_comm_log INTO TABLE git_clog WHERE ccreqno = gwa_jv_cc-ccreqno.

        CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*       g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
        g_att_files_wa-objtype = 'ATT'.
        g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

        APPEND g_att_files_wa TO g_att_files2.

         IF g_att_files2 IS NOT INITIAL.
               PERFORM GET_FILE .
         ENDIF.

      IF gwa_jv_cc-vtype = '1'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COMM'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF gwa_jv_cc-vtype = '2'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

      CALL FUNCTION v_fm
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          wa_req             = gwa_jv_cc
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
        TABLES
          it_log             = git_clog
          file_details1      = file_details1
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      ENDIF.
*      endif.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      li_otf[]  = gt_otf-otfdata[].
        CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
          max_linewidth         = 12376
*         ARCHIVE_INDEX         = ' '
*         copynumber            = copy
*         ASCII_BIDI_VIS2LOG    = ' '
*         PDF_DELETE_OTFTAB     = ' '
*         PDF_USERNAME          = ' '
        IMPORTING
          bin_filesize          = v_len_in
          bin_file              = v_bin_file
        TABLES
          otf                   = li_otf
          lines                 = li_pdf_tab
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          err_bad_otf           = 4
          OTHERS                = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = v_bin_file
*         APPEND_TO_TABLE       = ' '
*   IMPORTING
*         OUTPUT_LENGTH         =
        TABLES
          binary_tab = i_objbin[].

  endform.
*&---------------------------------------------------------------------*
*&      Form  DEL_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_MAIL .

    DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20,
    due_dt    TYPE char15.

  CONCATENATE 'Cash call request Deletion:' gwa_jv_cc-CCREQNO INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.

  lv_amt = gwa_jv_cc-wrbtr.


  CONCATENATE '<tr><p>Cash Call request' gwa_jv_cc-CCREQNO 'has been deleted.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Please cancel the fund requirement initiated earlier.' '<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).

    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @gwa_jv_cc-treasury1.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury1.
  IF p_email IS NOT INITIAL.
    lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
    TRY.
        lo_send_request->add_recipient(
            EXPORTING
            i_recipient = lo_recipient
            i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
    ENDTRY.
  ENDIF.

  CLEAR : p_email.
  IF gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
   WHERE bname = gwa_jv_cc-treasury2.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury2.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.

  CLEAR : p_email.

  IF gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-treasury3.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.



    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
*        MESSAGE 'Mail Sent' TYPE 'S'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.

ENDFORM.

form chng_mail_pm USING  p_user TYPE uname p_name TYPE ad_namtext p_reqno TYPE zccreqno..
  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.
  DATA : message(100) TYPE c.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request Changed:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been changed for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.

  REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
 CONCATENATE 'Request no' gwa_jv_cc-ccreqno ' changed & mail sent successfully'
   INTO message SEPARATED BY space.


        MESSAGE message TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
  ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPR_MAIL_REV
*&---------------------------------------------------------------------*
FORM appr_mail_rev  USING    p_user TYPE uname
                             p_name type ad_namtext
                             p_reqno type zccreqno.



  DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.
*
*  LV_DATA_STRING = I_RECORD.
*  LV_FILESIZE    = V_BIN_FILESIZE. " LV_LEN_IN.
*  CONDENSE LV_FILESIZE.
*
*  CLEAR : L_ATTSUBJECT.
*  L_ATTSUBJECT = 'Bank Signatory Details'.
*
*  TRY.
*      LO_DOCUMENT->ADD_ATTACHMENT( EXPORTING
*                                      I_ATTACHMENT_TYPE = 'PDF' "'XLS'
*                                      I_ATTACHMENT_SIZE   = LV_FILESIZE
*                                      I_ATTACHMENT_SUBJECT = L_ATTSUBJECT
*                                      I_ATT_CONTENT_TEXT  = I_RECORD[] ).
**                                      i_att_content_hex = lit_binary_content  ).
**          CATCH cx_document_bcs INTO lx_document_bcs.
*  ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-fc_approver IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-fc_approver.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.




*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL_REV
*&---------------------------------------------------------------------*

FORM fw_mail_rev  USING p_user TYPE uname
                        p_name TYPE ad_namtext
                        p_reqno TYPE zccreqno.
   DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.


  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-reviewer IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-reviewer.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.
  ENDIF.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.
*    ELSE.
*      p_email = wa_email-smtp_addr.
*      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
*      TRY.
*          lo_send_request->add_recipient(
*          EXPORTING
*          i_recipient = lo_recipient
*          i_express = 'X'
*          i_copy = abap_true ).
*      ENDTRY.
*    ENDIF.
*  ENDLOOP.
  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.











ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL1
*&---------------------------------------------------------------------*

FORM fw_mail1  USING  p_user TYPE uname
                      p_name TYPE ad_namtext
                      p_reqno TYPE zccreqno.

DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-PF_OFFICER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-PF_OFFICER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.

  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FW_MAIL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_JV_CC_FC_APPROVER  text
*      -->P_GV_NAME4  text
*      -->P_GWA_JV_CC_CCREQNO  text
*----------------------------------------------------------------------*
FORM  fw_mail2  USING  p_user TYPE uname
                      p_name TYPE ad_namtext
                      p_reqno TYPE zccreqno.

DATA : i_text          TYPE bcsy_text. "Table for body
  DATA : w_text          LIKE LINE OF i_text.
  DATA : i_receivers TYPE TABLE OF somlreci1 WITH HEADER LINE,
         i_record    LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object

  DATA : p_sub TYPE char50. "email subject
  DATA : lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA : lv_data_string TYPE string.
  DATA : lv_len_in    LIKE sood-objlen.
  DATA : lv_filesize TYPE so_obj_len.

  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
  DATA : l_attsubject TYPE sood-objdes.
  DATA : lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL. "sender
  DATA : lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL. "recipient
  DATA : p_email TYPE adr6-smtp_addr.

  DATA:
    t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE, "Header
    t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE, "Fields
    t_html    TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    t_html1   TYPE STANDARD TABLE OF w3html WITH HEADER LINE, "Html
    wa_header TYPE w3head,
    w_head    TYPE w3head,
    lv_amt    TYPE char20.

  SELECT SINGLE * FROM usr21 INTO @DATA(v_user)
    WHERE bname = @p_user.
  SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  CONCATENATE 'Cash call request approval:' p_reqno INTO p_sub SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).


  t_html-line = '<table>'.
  APPEND t_html.
  CLEAR t_html.
*t_html-line = '<thead>'.
* APPEND t_html.
* CLEAR t_html.
  t_html-line = '<tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<td></td></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Dear Sir/ Madam,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.

  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  lv_amt = gwa_jv_cc-wrbtr.
  CONCATENATE '<tr><p>Cash Call request' p_reqno 'has been forwarded for Joint Venture' gwa_jv_cc-vname 'of' gwa_jv_cc-waers lv_amt 'for the month of' month gwa_jv_cc-opp_month+2(4)'<p></tr>' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  CONCATENATE '<tr><p>Kindly take necessary action using tcode-ZJVCC<p></tr>' '' INTO t_html-line SEPARATED BY space.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>Regards,<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
*  t_html-line = '<tr><p>SAP Team - ONGC Videsh<p></tr>'.
*  APPEND t_html.
*  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><p>*This is a SAP-system generated e-mail for your information, please do not reply to this message.*<p></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr></tr>'.
  APPEND t_html.
  CLEAR t_html.
  t_html-line = '<tr><td></td></tr></table>'.
  APPEND t_html.
  CLEAR t_html.

  REFRESH i_text[].
  APPEND LINES OF t_html TO i_text.

  lo_document = cl_document_bcs=>create_document( "create document
  i_type = 'HTM' "Type of document HTM, TXT etc
  i_text =  i_text "email body internal table
  i_subject = p_sub ). "email subject here p_sub input parameter
* Pass the document to send request
  lo_send_request->set_document( lo_document ).


    REFRESH t_objbin[].
*
        PERFORM get_otf_data TABLES t_objbin[].

      sub = 'Comments'.
        TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type = 'PDF'
          i_attachment_subject = sub
*      i_attachment_size  =   lv_len
          i_att_content_hex =  t_objbin[] ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

  TRY.
      lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
  ENDTRY.
**Set recipient

*  LOOP AT it_email INTO DATA(wa_email).
*    p_email = wa_email-smtp_addr.
*    IF sy-tabix = 1.
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
  TRY.
      lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
  ENDTRY.
  CLEAR : p_email.

    IF gwa_jv_cc-FC_APPROVER IS NOT INITIAL.
    SELECT SINGLE * FROM usr21 INTO v_user
      WHERE bname = gwa_jv_cc-FC_APPROVER.
    SELECT SMTP_ADDR
 FROM ADR6 INTO P_EMAIL UP TO 1 ROWS WHERE PERSNUMBER = V_USER-PERSNUMBER AND ADDRNUMBER = V_USER-ADDRNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*    SELECT SINGLE smtp_addr FROM adr6 INTO p_email WHERE persnumber = gwa_jv_cc-treasury3.
    IF p_email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "cc
      TRY.
          lo_send_request->add_recipient(
          EXPORTING
          i_recipient = lo_recipient
          i_express = 'X'
          i_copy = abap_true ).
      ENDTRY.
    ENDIF.

  ENDIF.
  CLEAR : p_email.

  TRY.
      CALL METHOD lo_send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.  "p_send. "here selection screen input p_send
**Catch exception here
  ENDTRY.
  TRY.
** Send email
      lo_send_request->send(
      EXPORTING
      i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF sy-subrc = 0. "mail sent successfully
*        CLEAR : WA_FINAL.
        MESSAGE 'Mail sent successfully' TYPE 'I'.
      ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
  ENDTRY.

ENDFORM.

FORM GET_FILE.

   data neighbors   like neighbor occurs 0 with header line.
   DATA APPLICATION_OBJECT TYPE SWOTOBJID.

*DATA FILE_DETAILS1 LIKE sood5 occurs 0 WITH HEADER LINE.
data attachments like sood2 occurs 0 with header line.
data objhead     like soli  occurs 0 with header line.
data objcont     like soli  occurs 0 with header line.
data objpara     like selc  occurs 0 with header line.
data objparb     like soop1 occurs 0 with header line.
data exclude_tab like soxet occurs 0 with header line.
data sel_tab     like soxst occurs 0 with header line.
data fol_id      like soodk.
data obj_id      like soodk.
data obj_hd_dsp  like sood2.
data sel_count   like sy-tabix.
data next_func   like sy-ucomm.
data ok-code     like sy-ucomm.
data attach_size like sy-tabix.
data att_size_p  type p decimals 1.
data att_size_i  type i.
data page_rcode  like sonv-rcode.
data field_name(30).

data line_so910100 like sy-tabix value '6'.

* Data for note editor
  data objcont_save like soli  occurs 0 with header line.
  data objcont_help like soli  occurs 0 with header line.
* Table with content for editor call
  data: begin of content occurs 0,
           line(72),
        end of content.
  data objnam_save like sood2-objnam.
  data objdes_save like sood2-objdes.
  data f_update type c.
DATA APP_OBJECT    LIKE BORIDENT.
DATA FILTER        LIKE SOFOR.

constants:
      on  like sonv-flag value 'X',
      off like sonv-flag value ' '.

constants:
      ok  like sy-subrc value '00',
      cok like sy-subrc value '7000',  "return code = cancelled
      nok like sy-subrc value '9000',
      mok like sy-subrc value '8900'.

  MOVE-CORRESPONDING g_att_files_wa TO APPLICATION_OBJECT.
  MOVE-CORRESPONDING APPLICATION_OBJECT TO APP_OBJECT.
  CHECK NOT APP_OBJECT IS INITIAL.

  clear: neighbors, neighbors[].


 DATA: ls_object   TYPE SIBFLPORB,
       ls_logsys   TYPE LOGSYS.
*data attachments like sood5 occurs 0 with header line.

 DATA: lt_links    TYPE OBL_T_LINK.

 CONSTANTS: ls_relation TYPE OBLRELTYPE      VALUE 'ATTA',
            ls_catid_bo LIKE ls_object-catid VALUE 'BO'.
*            ls_role     TYPE OBLROLTYPE      VALUE 'APPLOBJ'.

 FIELD-SYMBOLS: <ls_links> TYPE OBL_S_LINK.

 MOVE: app_object-objkey  TO ls_object-instid,
       app_object-objtype TO ls_object-typeid,
       app_object-logsys  TO ls_logsys,
       ls_catid_bo        TO ls_object-catid.

 TRY.

   CALL METHOD cl_binary_relation=>read_links_of_binrel
     EXPORTING
       is_object    = ls_object
       ip_logsys    = ls_logsys
       ip_relation  = ls_relation
*       ip_role      = ls_role
*       ip_propnam   =
*       ip_no_buffer = SPACE
     IMPORTING
        et_links     = lt_links
*       et_roles     =
       .
    CATCH cx_obl_parameter_error .
    CATCH cx_obl_internal_error .
    CATCH cx_obl_model_error .
  ENDTRY.
  LOOP AT lt_links ASSIGNING <ls_links>.
    MOVE: <ls_links>-instid_b TO neighbors-objkey,
          <ls_links>-typeid_b TO neighbors-objtype.
    APPEND neighbors.
  ENDLOOP.

*}   INSERT
  CLEAR ATTACHMENTS. REFRESH ATTACHMENTS.

* LOOP AT RELATIONS.
  LOOP AT NEIGHBORS.
    MOVE ON TO FILTER-NOCONT.
*   MOVE RELATIONS-OBJKEY_B(17)    TO FOL_ID.
*   MOVE RELATIONS-OBJKEY_B+17(17) TO OBJ_ID.
    MOVE NEIGHBORS-OBJKEY(17)    TO FOL_ID.
    MOVE NEIGHBORS-OBJKEY+17(17) TO OBJ_ID.
    CALL FUNCTION 'SO_OBJECT_READ'
         EXPORTING
              FILTER            = FILTER
              FOLDER_ID         = FOL_ID
              OBJECT_ID         = OBJ_ID
              OWNER             = SY-UNAME
         IMPORTING
              OBJECT_HD_DISPLAY = OBJ_HD_DSP
         EXCEPTIONS
              OTHERS            = 1.
    IF SY-SUBRC EQ OK.
*   MOVE RELATIONS-OBJKEY_B(46)   TO ATTACHMENTS.
      MOVE NEIGHBORS-OBJKEY(46)     TO ATTACHMENTS.
      MOVE-CORRESPONDING OBJ_HD_DSP TO ATTACHMENTS.
      APPEND ATTACHMENTS.
    ENDIF.
  ENDLOOP.



  IF SY-SUBRC EQ 0.
    MOVE: ATTACHMENTS[] TO FILE_DETAILS1[].
  ELSE.

  ENDIF.

  LOOP AT FILE_DETAILS1 INTO DATA(WA_FILE_DETAILS).
*    wa_file_details-ownnam.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*    SELECT SINGLE NAME_LAST from USER_ADDR into @DATA(lv_fullname) where
*      BNAME eq @wa_file_details-ownnam.
    SELECT NAME_LAST from USER_ADDR UP TO 1 ROWS into @DATA(lv_fullname) where
      BNAME eq @wa_file_details-ownnam ORDER BY name_last. ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
      CLEAR wa_file_details-croadr.
      wa_file_details-croadr = lv_fullname.

    Modify file_details1 FROM wa_file_details TRANSPORTING CROADR WHERE ownnam = wa_file_details-ownnam.
    Clear : wa_file_details,lv_fullname.
  ENDLOOP.

 SORT FILE_DETAILS1 by CHDAT CHTIM ASCENDING.

ENDFORM.

*--- INCLUDE: SAPMZOVL_JV_CC_TOP ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_TOP
*&---------------------------------------------------------------------*
PROGRAM sapmzovl_jv_cash_call.

**&&-- Declaration of global varibles

**&&-- End of Declaration of global variables

**&&-- Declaration of global internal tables
TABLES: ZFI_BANK_PAYEE.
DATA : git_clog TYPE STANDARD TABLE OF zjv_cc_comm_log.
**&&-- End of Declaration of global internal tables

**&&-- Declaration of global workareas
DATA : gwa_jv_cc TYPE zjv_cash_call,
       gwa_clog  TYPE zjv_cc_comm_log.
**&&-- End of declaration of global workareas.

**&&-- Declaration for TextBox
DATA: line_length      TYPE i VALUE 175,
      editor_container TYPE REF TO cl_gui_custom_container,
      text_editor      TYPE REF TO cl_gui_textedit,
      text_tab_1       LIKE STANDARD TABLE OF line,
      text_tab         LIKE STANDARD TABLE OF tline.

DATA : wa_text_tab   TYPE tline,
       wa_text_tab_1 TYPE line.
**&&-- End of Declaration for Textbox

DATA: r1 TYPE c,
      r2 TYPE c,
      r3 TYPE c,
      r4 TYPE c,
      r5 TYPE c,
      r6 TYPE c,"" VALUE 'X',
      r7 TYPE c,     "added by ss on 16.4.21
      r8 TYPE c.    " added by ss on 23.8.21.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'TS_9020'
CONSTANTS: BEGIN OF c_ts_9020,
             tab1 LIKE sy-ucomm VALUE 'TS_9020_CREA',
             tab2 LIKE sy-ucomm VALUE 'TS_9020_CHNG',
             tab3 LIKE sy-ucomm VALUE 'TS_9020_DISP',
             tab4 LIKE sy-ucomm VALUE 'TS_9020_DELE',
           END OF c_ts_9020.
*&SPWIZARD: DATA FOR TABSTRIP 'TS_9020'
CONTROLS:  ts_9020 TYPE TABSTRIP.
DATA:      BEGIN OF g_ts_9020,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPMZOVL_JV_CASH_CALL',
             pressed_tab LIKE sy-ucomm VALUE c_ts_9020-tab1,
           END OF g_ts_9020.
DATA:      ok_code LIKE sy-ucomm.
DATA:  lfct_9000 LIKE sy-ucomm,
       flag_disp,
       flag_data.
DATA:  appr(11) TYPE c,
       fwd(16)  TYPE c.
DATA: gv_vtext TYPE ltext_8jv,
      gv_name1 TYPE ad_namtext,
      gv_name2 TYPE ad_namtext,
      gv_name3 TYPE ad_namtext,
      gv_name4 TYPE ad_namtext,
      gv_name5 TYPE ad_namtext,
      gv_name6 TYPE ad_namtext. " added by ss on 23.8.21 for reviewer

DATA: is_object       TYPE sibflporb,
      ep_save_request TYPE sgs_flag,
      it_objects      TYPE STANDARD TABLE OF sibflporb,
      lt_month        TYPE TABLE OF t247,
      ls_month        TYPE t247.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   messtab  LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        wa_t100  TYPE t100,
        bapiret2 TYPE STANDARD TABLE OF bapiret2,
        month(3) TYPE c.

DATA : v_fm TYPE rs38l_fnam.

DATA: ls_control_param  TYPE ssfctrlop,
      ls_composer_param TYPE ssfcompop,
      ls_job_info       TYPE ssfcrescl,
      lv_objectid       TYPE cdhdr-objectid.

DATA: ls_object   TYPE SIBFLPORB,
      ls_logsys   TYPE LOGSYS.
DATA: lt_links    TYPE OBL_T_LINK.
CONSTANTS: ls_relation TYPE OBLRELTYPE      VALUE 'ATTA',
            ls_catid_bo LIKE ls_object-catid VALUE 'BO'.

DATA: wa_ssfcrescl TYPE ssfcrescl,
      lw_spoolids  TYPE rspoid,
      lw_ssfctrlop TYPE ssfctrlop,
      wa_ssfcompop TYPE ssfcompop,
*     gt_otf       TYPE ssfcrescl,
      wa_line      TYPE itcoo,
      gt_otf_hr    TYPE ssfcrescl,
      gt_otf       TYPE ssfcrescl,

      li_otf       TYPE TABLE OF itcoo,
      li_otf1      TYPE TABLE OF itcoo,
      li_pdf_tab   TYPE TABLE OF tline,
      v_len_in     TYPE i,
      v_bin_file   TYPE xstring.

       DATA: t_objbin   LIKE solix   OCCURS 0 WITH HEADER LINE,
       sub             TYPE sood-objdes,
       lx_document_bcs TYPE REF TO cx_document_bcs VALUE IS INITIAL.

** Added by ss on 18.4.21
 DATA: wa_bank TYPE zfi_bank_details.

** Added by ss on 23.9.2021
* data: l_docno      TYPE zfivmsbank-reqno,
*       GWA_JV_CC-REFNO1  TYPE zjv_cash_call-refno,
* G_NRRANGENR  LIKE INRDP-NRRANGENR VALUE '01',
* G_NROBJ1     TYPE NROBJ           VALUE 'ZCC_BNKREF'.

data attachments like sood5 occurs 0 with header line.
DATA  g_att_files_WA LIKE swotobjid.
DATA FILE_DETAILS1 LIKE sood2 occurs 0 with header line.
*DATA FILE_DETAILS TYPE  SOOD5.
DATA CHA_WF(10) TYPE C.
DATA SAVE_WF(10) TYPE C.
