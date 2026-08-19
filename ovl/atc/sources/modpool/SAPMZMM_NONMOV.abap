*--- MAIN PROGRAM: SAPMZMM_NONMOV ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMM_NONMOV                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
* Title      : Program for MM Non-moving material workflow             *
* Author     : Alok Kumar Singh                   Date : 03.12.2013    *
* Login Id   : CAB_ALOK                                                *
* CR no: 30008546                                                      *
* Description :
* Transaction Codes : ZMMNMREQ,ZMMNMWF2,ZMMNMWF3,ZMMNMWF4               *
*                                                                       *
********************************************************************** *
********************************************************************** *
* CHANGE HISTORY                                                       *
*Date       Transport   USERID     Description                  *
*
********************************************************************** *
*                                                                     *
*                                                                     *


INCLUDE MZMM_NONMOVTOP.
INCLUDE MZMM_NONMOVO01.
INCLUDE MZMM_NONMOVI01.
INCLUDE MZMM_NONMOVF01.

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

*--- INCLUDE: %_CICON ---*
TYPE-POOL ICON.
INCLUDE >ICON<.
*
*                     DEFINITION OF ICONS
*
*Icon_Length                           ID
*      Name                                     Quickinfo
ICON_2 ICON_DUMMY                     '@00@'."  PlaceholderIcon
ICON_2 ICON_CHECKED                   '@01@'."  Checked; OK
ICON_2 ICON_INCOMPLETE                '@02@'."  Incomplete
ICON_2 ICON_FAILURE                   '@03@'."  Failed
ICON_2 ICON_POSITIVE                  '@04@'."  Positive
ICON_2 ICON_NEGATIVE                  '@05@'."  Negative
ICON_2 ICON_LOCKED                    '@06@'."  Locked
ICON_2 ICON_UNLOCKED                  '@07@'."  Free; unlock
ICON_4 ICON_GREEN_LIGHT               '@08@'."  Green light; positive
ICON_4 ICON_YELLOW_LIGHT              '@09@'."  Yellow light; neutral
ICON_4 ICON_RED_LIGHT                 '@0A@'."  Red light; negative
ICON_2 ICON_TOTAL_LEFT                '@0B@'."  Extreme left; first ...
ICON_2 ICON_TOTAL_RIGHT               '@0C@'."  Extreme right; last ...
ICON_2 ICON_COLUMN_LEFT               '@0D@'."  Column left; previous ..
ICON_2 ICON_COLUMN_RIGHT              '@0E@'."  Column right; next ...
ICON_2 ICON_PAGE_RIGHT                '@0F@'."  Page right
ICON_2 ICON_PAGE_LEFT                 '@0G@'."  Page left
ICON_2 ICON_PREVIOUS_VALUE            '@0H@'."  Previous value; next ent
ICON_2 ICON_NEXT_VALUE                '@0I@'."  Next value; previous ent
ICON_2 ICON_ANNOTATION                '@0J@'."  Note; remark
ICON_2 ICON_CREATE_NOTE               '@0K@'."  Create note
ICON_2 ICON_DISPLAY_NOTE              '@0L@'."  Display note
ICON_2 ICON_CALCULATION               '@0M@'."  Costing
ICON_2 ICON_GRAPHICS                  '@0N@'."  Graphics
ICON_2 ICON_CREATE_TEXT               '@0O@'."  Create text
ICON_2 ICON_DISPLAY_TEXT              '@0P@'."  Display text
ICON_2 ICON_CHANGE_TEXT               '@0Q@'."  Text
ICON_2 ICON_VARIANTS                  '@0R@'."  Variants
ICON_2 ICON_INFORMATION               '@0S@'."  Information
ICON_2 ICON_ADDRESS                   '@0T@'."  Address
ICON_2 ICON_VIEWER_OPTICAL_ARCHIVE    '@0U@'."  Optical archive viewer
ICON_2 ICON_OKAY                      '@0V@'."  OK; Continue; Choose <va
ICON_2 ICON_CANCEL                    '@0W@'."  Cancel
ICON_2 ICON_PRINT                     '@0X@'."  Print
ICON_2 ICON_CREATE                    '@0Y@'."  Create
ICON_2 ICON_CHANGE                    '@0Z@'."  Change
ICON_2 ICON_DISPLAY                   '@10@'."  Display
ICON_2 ICON_DELETE                    '@11@'."  Delete
ICON_2 ICON_TEST                      '@12@'."  Test
ICON_2 ICON_SEARCH                    '@13@'."  Find
ICON_2 ICON_COPY_OBJECT               '@14@'."  Copy <object>
ICON_2 ICON_EXECUTE_OBJECT            '@15@'."  Execute <object>
ICON_2 ICON_SELECT_DETAIL             '@16@'."  Choose detail; detail sc
ICON_2 ICON_INSERT_ROW                '@17@'."  Insert line
ICON_2 ICON_DELETE_ROW                '@18@'."  Delete line
ICON_4 ICON_MESSAGE_INFORMATION       '@19@'."  Information message
ICON_4 ICON_MESSAGE_WARNING           '@1A@'."  Warning
ICON_4 ICON_MESSAGE_ERROR             '@1B@'."  Error message
ICON_4 ICON_MESSAGE_QUESTION          '@1C@'."  Question
ICON_4 ICON_MESSAGE_CRITICAL          '@1D@'."  Critical message
ICON_2 ICON_DISPLAY_MORE              '@1E@'."  Display/change more
ICON_2 ICON_ENTER_MORE                '@1F@'."  Create more
ICON_2 ICON_EQUAL                     '@1G@'."  Equal
ICON_2 ICON_NOT_EQUAL                 '@1H@'."  Not equal
ICON_2 ICON_GREATER                   '@1I@'."  Greater
ICON_2 ICON_LESS                      '@1J@'."  Less
ICON_2 ICON_GREATER_EQUAL             '@1K@'."  Greater/equal
ICON_2 ICON_LESS_EQUAL                '@1L@'."  Less than/equal
ICON_2 ICON_INTERVAL_INCLUDE          '@1M@'."  Include range
ICON_2 ICON_INTERVAL_EXCLUDE          '@1N@'."  Exclude range
ICON_2 ICON_PATTERN_INCLUDE           '@1O@'."  Include pattern
ICON_2 ICON_PATTERN_EXCLUDE           '@1P@'."  Exclude pattern
ICON_2 ICON_PHONE                     '@1Q@'."  Telephone number
ICON_2 ICON_FAX                       '@1R@'."  Fax number
ICON_2 ICON_MAIL                      '@1S@'."  Send message; mail
ICON_2 ICON_TIME                      '@1T@'."  Time
ICON_2 ICON_DATE                      '@1U@'."  Date
ICON_2 ICON_ALARM                     '@1V@'."  Alarm
ICON_2 ICON_PROSHARE                  '@1W@'."  Per share
ICON_2 ICON_VIDEO                     '@1X@'."  Video
ICON_2 ICON_VOICE_INPUT               '@1Y@'."  Language input
ICON_2 ICON_VOICE_OUTPUT              '@1Z@'."  Language output
ICON_2 ICON_EQUAL_GREEN               '@20@'."  Select: Equal
ICON_2 ICON_NOT_EQUAL_GREEN           '@21@'."  Select: Not equal
ICON_2 ICON_GREATER_GREEN             '@22@'."  Select: Greater than
ICON_2 ICON_LESS_GREEN                '@23@'."  Select: Less than
ICON_2 ICON_GREATER_EQUAL_GREEN       '@24@'."  Select: Greater than or
ICON_2 ICON_LESS_EQUAL_GREEN          '@25@'."  Select: Less than or equ
ICON_2 ICON_INTERVAL_INCLUDE_GREEN    '@26@'."  Select: Include range
ICON_2 ICON_INTERVAL_EXCLUDE_GREEN    '@27@'."  Select: Exclude range
ICON_2 ICON_PATTERN_INCLUDE_GREEN     '@28@'."  Select: Include pattern
ICON_2 ICON_PATTERN_EXCLUDE_GREEN     '@29@'."  Select: Exclude pattern
ICON_2 ICON_EQUAL_RED                 '@2A@'."  Do not select: Equal
ICON_2 ICON_NOT_EQUAL_RED             '@2B@'."  Do not select: Not equal
ICON_2 ICON_GREATER_RED               '@2C@'."  Do not select: Greater t
ICON_2 ICON_LESS_RED                  '@2D@'."  Do not select: Less than
ICON_2 ICON_GREATER_EQUAL_RED         '@2E@'."  Do not select: Greater/e
ICON_2 ICON_LESS_EQUAL_RED            '@2F@'."  Do not select: Less than
ICON_2 ICON_INTERVAL_INCLUDE_RED      '@2G@'."  Do not select: Include r
ICON_2 ICON_INTERVAL_EXCLUDE_RED      '@2H@'."  Do not select: Exclude r
ICON_2 ICON_PATTERN_INCLUDE_RED       '@2I@'."  Do not select: Include p
ICON_2 ICON_PATTERN_EXCLUDE_RED       '@2J@'."  Do not select: Exclude p
ICON_2 ICON_SYSTEM_OKAY               '@2K@'."  OK
ICON_2 ICON_SYSTEM_SAVE               '@2L@'."  Save
ICON_2 ICON_SYSTEM_BACK               '@2M@'."  Back
ICON_2 ICON_SYSTEM_END                '@2N@'."  Exit
ICON_2 ICON_SYSTEM_CANCEL             '@2O@'."  Cancel
ICON_2 ICON_SYSTEM_PRINT              '@2P@'."  Print
ICON_2 ICON_OTHER_OBJECT              '@2Q@'."  Other <object>
ICON_2 ICON_PREVIOUS_OBJECT           '@2R@'."  Previous screen
ICON_2 ICON_NEXT_OBJECT               '@2S@'."  Next screen
ICON_2 ICON_SYSTEM_CUT                '@2T@'."  Cut
ICON_2 ICON_SYSTEM_COPY               '@2U@'."  Copy
ICON_2 ICON_SYSTEM_PASTE              '@2V@'."  Paste
ICON_2 ICON_SYSTEM_UNDO               '@2W@'."  Undo
ICON_2 ICON_SYSTEM_MARK               '@2X@'."  Select mode; select
ICON_2 ICON_FIRST_PAGE                '@2Y@'."  First page
ICON_2 ICON_PREVIOUS_PAGE             '@2Z@'."  Prev. page
ICON_2 ICON_NEXT_PAGE                 '@30@'."  Next page
ICON_2 ICON_LAST_PAGE                 '@31@'."  Last page
ICON_2 ICON_SYSTEM_MODUS_CREATE       '@32@'."  Create session
ICON_2 ICON_SYSTEM_MODUS_DELETE       '@33@'."  Delete session
ICON_2 ICON_SYSTEM_USERMENU           '@34@'."  Session Manager
ICON_2 ICON_SYSTEM_HELP               '@35@'."  Help
ICON_2 ICON_TABLE_SETTINGS            '@36@'."  Report-report call
ICON_2 ICON_REPLACE                   '@37@'."  Replace
ICON_2 ICON_CHECK                     '@38@'."  Check
ICON_2 ICON_GENERATE                  '@39@'."  Generate
ICON_2 ICON_REFERENCE_LIST            '@3A@'."  Where-used list
ICON_2 ICON_STACK                     '@3B@'."  Stack
ICON_2 ICON_ACTIVATE                  '@3C@'."  Activate
ICON_2 ICON_ICON_LIST                 '@3D@'."  Icon list; key
ICON_2 ICON_SORT_UP                   '@3E@'."  Sort in ascending order
ICON_2 ICON_SORT_DOWN                 '@3F@'."  Sort in descending order
ICON_2 ICON_LAYOUT_CONTROL            '@3G@'."  Page view
ICON_2 ICON_CONVERT                   '@3H@'."  Convert
ICON_2 ICON_TOGGLE_DISPLAY_CHANGE     '@3I@'."  Display <-> Change
ICON_2 ICON_SET_STATE                 '@3J@'."  Set status
ICON_2 ICON_PREVIOUS_NODE             '@3K@'."  Previous node
ICON_2 ICON_NEXT_NODE                 '@3L@'."  Next node
ICON_2 ICON_TREE                      '@3M@'."  Hierarchy
ICON_2 ICON_INSERT_RELATION           '@3N@'."  Insert dependency
ICON_2 ICON_FINAL_DATE                '@3O@'."  End date
ICON_2 ICON_HEADER                    '@3P@'."  Header; basic data
ICON_2 ICON_OVERVIEW                  '@3Q@'."  Overview; overview; list
ICON_2 ICON_DETAIL                    '@3R@'."  Detail view
ICON_2 ICON_EXPAND                    '@3S@'."  Expand; enlarge
ICON_2 ICON_COLLAPSE                  '@3T@'."  Compress; reduce
ICON_2 ICON_BREAKPOINT                '@3U@'."  Breakpoint
ICON_2 ICON_FOREIGN_KEY               '@3V@'."  Foreign key
ICON_2 ICON_LIST                      '@3W@'."  List
ICON_2 ICON_CLOSE                     '@3X@'."  Close
ICON_2 ICON_POSITION                  '@3Y@'."  Position; other entry
ICON_2 ICON_SUM                       '@3Z@'."  Sum
ICON_2 ICON_MOVE                      '@40@'."  Move
ICON_2 ICON_RETRIEVE                  '@41@'."  Restore
ICON_2 ICON_REFRESH                   '@42@'."  Refresh
ICON_2 ICON_SKIP                      '@43@'."  Skip
ICON_2 ICON_SYSTEM_SETTINGS           '@44@'."  User settings
ICON_2 ICON_TOOLS                     '@45@'."  Tools
ICON_2 ICON_COMPARE                   '@46@'."  Compare
ICON_2 ICON_SHORT_MESSAGE             '@47@'."  Short message
ICON_2 ICON_IMPORT                    '@48@'."  Import
ICON_2 ICON_EXPORT                    '@49@'."  Export
ICON_2 ICON_TRANSPORT                 '@4A@'."  Transport
ICON_2 ICON_SELECT_ALL                '@4B@'."  Select all
ICON_2 ICON_SELECT_BLOCK              '@4C@'."  Select block
ICON_2 ICON_DESELECT_ALL              '@4D@'."  Deselect all
ICON_2 ICON_SEARCH_NEXT               '@4E@'."  Continue search
ICON_2 ICON_RENAME                    '@4F@'."  Rename
ICON_2 ICON_FILTER                    '@4G@'."  Filter
ICON_2 ICON_NEXT_HIERARCHY_LEVEL      '@4H@'."  Next hierarchy level
ICON_2 ICON_PREVIOUS_HIERARCHY_LEVEL  '@4I@'."  Previous hierarchy level
ICON_2 ICON_SYSTEM_POSSIBLE_ENTRIES   '@4J@'."  Possible entries
ICON_2 ICON_INTENSIFY                 '@4K@'."  Emphasize
ICON_2 ICON_PERSONAL_HELP             '@4L@'."  Individual help
ICON_2 ICON_VARIABLE                  '@4M@'."  Variable
ICON_2 ICON_SYSTEM_LOCAL_CUT          '@4N@'."  Cut (local)
ICON_2 ICON_SYSTEM_LOCAL_COPY         '@4O@'."  Copy (local)
ICON_2 ICON_SYSTEM_LOCAL_PASTE        '@4P@'."  Paste (local)
ICON_2 ICON_SYSTEM_LOCAL_MARK         '@4Q@'."  Selection mode (local)
ICON_2 ICON_SYSTEM_REDO               '@4R@'."  Repeat
ICON_2 ICON_BUSINAV_PROCESS           '@4S@'."  Process
ICON_2 ICON_BUSINAV_PROCESSMATRIX     '@4T@'."  Proc. sel. matrix
ICON_2 ICON_BUSINAV_SYSORGI           '@4U@'."  System chart
ICON_2 ICON_BUSINAV_SZENARIO          '@4V@'."  Scenario
ICON_2 ICON_BUSINAV_OBJECTS           '@4W@'."  Business objects
ICON_2 ICON_BUSINAV_INFODIAG          '@4X@'."  Info flow diagram
ICON_2 ICON_BUSINAV_ENTITY            '@4Y@'."  Entity type
ICON_2 ICON_BUSINAV_PROC_EXIST        '@4Z@'."  Process exists
ICON_2 ICON_BUSINAV_COMMDIAG          '@50@'."  Communication diagram
ICON_2 ICON_BUSINAV_DATAMODEL         '@51@'."  Data model
ICON_2 ICON_ALIGN                     '@52@'."  Align
ICON_2 ICON_CUT_RELATION              '@53@'."  Cancel link
ICON_2 ICON_FIX_COLUMN                '@54@'."  Fix columns
ICON_2 ICON_RELEASE_COLUMN            '@55@'."  Cancel column fix
ICON_2 ICON_NET_GRAPHIC               '@56@'."  Network graphics
ICON_2 ICON_PLANNING_TABLE            '@57@'."  Bar chart graphic; plan.
ICON_2 ICON_PERIOD                    '@58@'."  Period screen; time brea
ICON_2 ICON_ZOOM_IN                   '@59@'."  Maximize objects
ICON_2 ICON_ZOOM_OUT                  '@5A@'."  Minimize objects
ICON_2 ICON_LED_GREEN                 '@5B@'."  Go
ICON_2 ICON_LED_RED                   '@5C@'."  Stop
ICON_2 ICON_LED_YELLOW                '@5D@'."  Stop
ICON_2 ICON_SYSTEM_EXTENDED_HELP      '@5E@'."  Stop
ICON_2 ICON_SPACE                     '@5F@'."  Stop
ICON_2 ICON_BUSINAV_VALUE_CHAIN       '@5G@'."  Stop
ICON_2 ICON_WORKFLOW_ACTIVITY         '@5H@'."  Stop
ICON_2 ICON_WORKFLOW_CONDITION        '@5I@'."  Stop
ICON_2 ICON_WORKFLOW_DECISION         '@5J@'."  Stop
ICON_2 ICON_WORKFLOW_CONT_OPERATION   '@5K@'."  Stop
ICON_2 ICON_WORKFLOW_EXTERNAL_EVENT   '@5L@'."  Stop
ICON_2 ICON_WORKFLOW_INTERNAL_EVENT   '@5M@'."  Stop
ICON_2 ICON_WORKFLOW_MULT_CONDITION   '@5N@'."  Stop
ICON_2 ICON_WORKFLOW_FORK             '@5O@'."  Stop
ICON_2 ICON_WORKFLOW_EVENT_PRODUCER   '@5P@'."  Stop
ICON_2 ICON_WORKFLOW_FLOW_OF_CONTROL  '@5Q@'."  Stop
ICON_2 ICON_WORKFLOW_INDEFINITE_STEP  '@5R@'."  Stop
ICON_2 ICON_WORKFLOW_UNTIL            '@5S@'."  Stop
ICON_2 ICON_WORKFLOW_WAIT_FOR_EVENTS  '@5T@'."  Stop
ICON_2 ICON_WORKFLOW_WHILE            '@5U@'."  Stop
ICON_2 ICON_INTERMEDIATE_SUM          '@5V@'."  Stop
ICON_2 ICON_EMPLOYEE                  '@5W@'."  Stop
ICON_2 ICON_TIME_ZONE                 '@5X@'."  Stop
ICON_2 ICON_RELEASE                   '@5Y@'."  Stop
ICON_2 ICON_QUALIFY                   '@5Z@'."  Stop
ICON_2 ICON_ISO_CODE                  '@60@'."  Stop
ICON_2 ICON_MODIFY                    '@61@'."  Stop
ICON_2 ICON_GET_AREA                  '@62@'."  Stop
ICON_2 ICON_INTERFACE                 '@63@'."  Stop
ICON_2 ICON_ROUTING_OPERATION         '@64@'."  Stop
ICON_2 ICON_ROUTING_REF_OPERATION     '@65@'."  Stop
ICON_2 ICON_ROUTING_TASK              '@66@'."  Stop
ICON_2 ICON_ROUTING_TODO              '@67@'."  Stop
ICON_2 ICON_EXPAND_ALL                '@68@'."  Stop
ICON_2 ICON_COLLAPSE_ALL              '@69@'."  Stop
ICON_2 ICON_SYSTEM_SAP_MENU           '@6A@'."  Stop
ICON_2 ICON_SYSTEM_COMP_MENU          '@6B@'."  Stop
ICON_2 ICON_SYSTEM_USER_MENU          '@6C@'."  Stop
ICON_2 ICON_SYSTEM_FAVORITES          '@6D@'."  Stop
ICON_2 ICON_BIW_INFO_SOURCE           '@6E@'."  Stop
ICON_2 ICON_BIW_APPLICATION           '@6F@'."  Stop
ICON_2 ICON_BIW_INFO_AREA             '@6G@'."  Stop
ICON_2 ICON_BIW_INFO_CUBE             '@6H@'."  Stop
ICON_2 ICON_BIW_RULES_INA             '@6I@'."  Stop
ICON_2 ICON_BIW_SOURCE_SYS_GEN        '@6J@'."  Stop
ICON_2 ICON_BIW_SOURCE_SYS_R3         '@6K@'."  Stop
ICON_2 ICON_BIW_SOURCE_SYS_EXT        '@6L@'."  Stop
ICON_2 ICON_BIW_SOURCE_SYS_FILE       '@6M@'."  Stop
ICON_2 ICON_BIW_INFO_CATALOG          '@6N@'."  Stop
ICON_2 ICON_BIW_INFO_OBJECT           '@6O@'."  Stop
ICON_2 ICON_BIW_MONITOR               '@6P@'."  Stop
ICON_2 ICON_BIW_SCHEDULER             '@6Q@'."  Stop
ICON_2 ICON_BIW_FORMULA               '@6R@'."  Stop
ICON_2 ICON_BIW_REF_STRUCTURE         '@6S@'."  Stop
ICON_2 ICON_BIW_REPORT                '@6T@'."  Stop
ICON_2 ICON_BIW_REPORT_VIEW           '@6U@'."  Stop
ICON_2 ICON_MASTER_DATA_ACT           '@6V@'."  Stop
ICON_2 ICON_MASTER_DATA_INA           '@6W@'."  Stop
ICON_2 ICON_TEXT_ACT                  '@6X@'."  Stop
ICON_2 ICON_TEXT_INA                  '@6Y@'."  Stop
ICON_2 ICON_HIERARCHY_ACT             '@6Z@'."  Stop
ICON_2 ICON_HIERARCHY_INA             '@70@'."  Stop
ICON_2 ICON_MOVING_DATA_ACT           '@71@'."  Stop
ICON_2 ICON_MOVING_DATA_INA           '@72@'."  Stop
ICON_2 ICON_DEBUGGER_STEP_INTO        '@73@'."  Stop
ICON_2 ICON_DEBUGGER_STEP_OVER        '@74@'."  Stop
ICON_2 ICON_DEBUGGER_STEP_OUT         '@75@'."  Stop
ICON_2 ICON_DEBUGGER_CONTINUE         '@76@'."  Stop
ICON_2 ICON_PARAMETER                 '@77@'."  Stop
ICON_2 ICON_PARAMETER_IMPORT          '@78@'."  Stop
ICON_2 ICON_PARAMETER_EXPORT          '@79@'."  Stop
ICON_2 ICON_PARAMETER_CHANGING        '@7A@'."  Stop
ICON_2 ICON_PARAMETER_RESULT          '@7B@'."  Stop
ICON_2 ICON_OO_CLASS                  '@7C@'."  Stop
ICON_2 ICON_OO_INTERFACE              '@7D@'."  Stop
ICON_2 ICON_OO_ATTRIBUTE              '@7E@'."  Stop
ICON_2 ICON_OO_CLASS_ATTRIBUTE        '@7F@'."  Stop
ICON_2 ICON_OO_INST_ATTRIBUTE         '@7G@'."  Stop
ICON_2 ICON_OO_METHOD                 '@7H@'."  Stop
ICON_2 ICON_OO_CLASS_METHOD           '@7I@'."  Stop
ICON_2 ICON_OO_INST_METHOD            '@7J@'."  Stop
ICON_2 ICON_OO_EVENT                  '@7K@'."  Stop
ICON_2 ICON_OO_CONSTANT               '@7L@'."  Stop
ICON_2 ICON_OO_OVERWRITE              '@7M@'."  Stop
ICON_2 ICON_OO_CONNECTION             '@7N@'."  Stop
ICON_2 ICON_OO_INHERITANCE            '@7O@'."  Stop
ICON_2 ICON_OO_INTERFACE_IC           '@7P@'."  Stop
ICON_2 ICON_WS_TRUCK                  '@7Q@'."  Stop
ICON_2 ICON_WS_RAIL                   '@7R@'."  Stop
ICON_2 ICON_WS_SHIP                   '@7S@'."  Stop
ICON_2 ICON_WS_PLANE                  '@7T@'."  Stop
ICON_2 ICON_WS_POST                   '@7U@'."  Stop
ICON_2 ICON_WS_TRANSFER               '@7V@'."  Stop
ICON_2 ICON_WS_DOUANE                 '@7W@'."  Stop
ICON_2 ICON_SELECTION                 '@7X@'."  Stop
ICON_2 ICON_SYSTEM_STOP_RECORDING     '@7Y@'."  Stop
ICON_2 ICON_FENCING                   '@7Z@'."  Stop
ICON_2 ICON_BIW_RULES_ACT             '@80@'."  Stop
ICON_2 ICON_CHARACTERISTICS_ACT       '@81@'."  Stop
ICON_2 ICON_CHARACTERISTICS_INA       '@82@'."  Stop
ICON_2 ICON_KEYFIGURE_ACT             '@83@'."  Stop
ICON_2 ICON_KEYFIGURE_INA             '@84@'."  Stop
ICON_2 ICON_BIW_INFO_OBJECT_UNITS_ACT '@85@'."  Stop
ICON_2 ICON_BIW_INFO_OBJECT_UNITS_INA '@86@'."  Stop
ICON_2 ICON_WORKFLOW_INT_EVENT_DATE   '@87@'."  Stop
ICON_2 ICON_BIW_INFO_OBJECT_CATALOGUE '@88@'."  Stop
ICON_2 ICON_SET_A                     '@89@'."  Stop
ICON_2 ICON_SET_B                     '@8A@'."  Stop
ICON_2 ICON_SET_SUM                   '@8B@'."  Stop
ICON_2 ICON_SET_INTERSECTION          '@8C@'."  Stop
ICON_2 ICON_SET_A_MINUS_B             '@8D@'."  Stop
ICON_2 ICON_SET_B_MINUS_A             '@8E@'."  Stop
ICON_2 ICON_SET_COPY_IN_A             '@8F@'."  Stop
ICON_2 ICON_SET_COPY_IN_B             '@8G@'."  Stop
ICON_2 ICON_DANGEROUS_GOODS           '@8H@'."  Stop
ICON_2 ICON_DEACTIVATE                '@8I@'."  Stop
ICON_2 ICON_DESELECT_BLOCK            '@8J@'."  Stop
ICON_2 ICON_INVERT_COLUMN             '@8K@'."  Stop
ICON_2 ICON_INVERT_LINE               '@8L@'."  Stop
ICON_2 ICON_FOREIGN_TRADE             '@8M@'."  Stop
ICON_2 ICON_MESSAGE_CRITICAL_SMALL    '@8N@'."  Stop
ICON_2 ICON_MESSAGE_ERROR_SMALL       '@8O@'."  Stop
ICON_2 ICON_MESSAGE_INFORMATION_SMALL '@8P@'."  Stop
ICON_2 ICON_MESSAGE_QUESTION_SMALL    '@8Q@'."  Stop
ICON_2 ICON_MESSAGE_WARNING_SMALL     '@8R@'."  Stop
ICON_2 ICON_URL                       '@8S@'."  Stop
ICON_2 ICON_SYSTEM_SHORTCUT           '@8T@'."  Stop
ICON_2 ICON_PLANNING_IN               '@8U@'."  Stop
ICON_2 ICON_PLANNING_OUT              '@8V@'."  Stop
ICON_2 ICON_SUBMIT                    '@8W@'."  Stop
ICON_2 ICON_ALLOW                     '@8X@'."  Stop
ICON_2 ICON_REJECT                    '@8Y@'."  Stop
ICON_2 ICON_SIMULATE                  '@8Z@'."  Stop
ICON_2 ICON_TE_RECEIPTS               '@90@'."  Stop
ICON_2 ICON_TE_STOPOVER               '@91@'."  Stop
ICON_2 ICON_TE_KM_DIVISION            '@92@'."  Stop
ICON_2 ICON_TE_ADVANCE_PAYMENT        '@93@'."  Stop
ICON_2 ICON_TE_DEDUCTION              '@94@'."  Stop
ICON_2 ICON_TE_COSTS_ASSIGN           '@95@'."  Stop
ICON_2 ICON_HISTORY                   '@96@'."  Stop
ICON_2 ICON_MODIFICATION_CREATE       '@97@'."  Stop
ICON_2 ICON_MODIFICATION_OVERVIEW     '@98@'."  Stop
ICON_2 ICON_MODIFICATION_ORIGINAL     '@99@'."  Stop
ICON_2 ICON_MODIFICATION_RESET        '@9A@'."  Stop
ICON_2 ICON_ACTIVE_INACTIVE           '@9B@'."  Stop
ICON_2 ICON_BEN_OFFER                 '@9C@'."  Stop
ICON_2 ICON_BEN_OFFER_DEFAULT         '@9D@'."  Stop
ICON_2 ICON_BEN_OFFER_EVENT           '@9E@'."  Stop
ICON_2 ICON_BEN_OFFER_OPEN            '@9F@'."  Stop
ICON_2 ICON_BEN_WAIVE_COVERAGE        '@9G@'."  Stop
ICON_2 ICON_DEPENDENTS                '@9H@'."  Stop
ICON_2 ICON_BEN_CURRENT_BENEFITS      '@9I@'."  Stop
ICON_2 ICON_BEN_TERMINATION           '@9J@'."  Stop
ICON_2 ICON_WS_TRANSPORT              '@9K@'."  Stop
ICON_2 ICON_ODS_ACT                   '@9L@'."  Stop
ICON_2 ICON_ODS_INA                   '@9M@'."  Stop
ICON_2 ICON_BIW_INFO_PACKAGE          '@9N@'."  Stop
ICON_2 ICON_ACTION_FAULT              '@9O@'."  Stop
ICON_2 ICON_ACTION_SUCCESS            '@9P@'."  Stop
ICON_2 ICON_DIMENSION                 '@9Q@'."  Stop
ICON_2 ICON_TIME_INA                  '@9R@'."  Stop
ICON_2 ICON_ARROW_LEFT                '@9S@'."  Stop
ICON_2 ICON_ARROW_RIGHT               '@9T@'."  Stop
ICON_2 ICON_ABAP                      '@9U@'."  Stop
ICON_2 ICON_ABAP_LOCAL                '@9V@'."  Stop
ICON_2 ICON_TRANSFER_STRUCTURE        '@9W@'."  Stop
ICON_2 ICON_OPERATION                 '@9X@'."  Stop
ICON_2 ICON_ACTIVITY                  '@9Y@'."  Stop
ICON_2 ICON_ORDER                     '@9Z@'."  Stop
ICON_2 ICON_CUSTOMER                  '@A0@'."  Stop
ICON_2 ICON_WAREHOUSE                 '@A1@'."  Stop
ICON_2 ICON_DISPO_LEVEL               '@A2@'."  Stop
ICON_2 ICON_DISTRIBUTION              '@A3@'."  Stop
ICON_2 ICON_CUSTOMER_WAREHOUSE        '@A4@'."  Stop
ICON_2 ICON_TRANSPORT_POINT           '@A5@'."  Stop
ICON_2 ICON_MATERIAL                  '@A6@'."  Stop
ICON_2 ICON_MODEL                     '@A7@'."  Stop
ICON_2 ICON_PLANT                     '@A8@'."  Stop
ICON_2 ICON_PRODUCT_GROUP             '@A9@'."  Stop
ICON_2 ICON_RELATIONSHIP              '@AA@'."  Stop
ICON_2 ICON_RESOURCE                  '@AB@'."  Stop
ICON_2 ICON_STORE_LOCATION            '@AC@'."  Stop
ICON_2 ICON_SUPPLIER                  '@AD@'."  Stop
ICON_2 ICON_TRANSPORTATION_MODE       '@AE@'."  Stop
ICON_2 ICON_LOCATION                  '@AF@'."  Stop
ICON_2 ICON_ALERT                     '@AG@'."  Stop
ICON_2 ICON_WARNING                   '@AH@'."  Stop
ICON_2 ICON_HINT                      '@AI@'."  Stop
ICON_2 ICON_WORKING_PLAN              '@AJ@'."  Stop
ICON_2 ICON_MAINTENANCE_PLAN          '@AK@'."  Stop
ICON_2 ICON_REPORT                    '@AL@'."  Stop
ICON_2 ICON_WORKPLACE                 '@AM@'."  Stop
ICON_2 ICON_EQUIPMENT                 '@AN@'."  Stop
ICON_2 ICON_TECHNICAL_PLACE           '@AO@'."  Stop
ICON_2 ICON_BOM                       '@AP@'."  Stop
ICON_2 ICON_BOM_ITEM                  '@AQ@'."  Stop
ICON_2 ICON_DOCUMENT                  '@AR@'."  Stop
ICON_2 ICON_DOCUMENT_REVISION         '@AS@'."  Stop
ICON_2 ICON_MATERIAL_REVISION         '@AT@'."  Stop
ICON_2 ICON_CHANGE_NUMBER             '@AU@'."  Stop
ICON_2 ICON_FLIGHT                    '@AV@'."  Stop
ICON_2 ICON_CAR                       '@AW@'."  Stop
ICON_2 ICON_HOTEL                     '@AX@'."  Stop
ICON_2 ICON_RAILWAY                   '@AY@'."  Stop
ICON_2 ICON_MONEY                     '@AZ@'."  Stop
ICON_2 ICON_QUESTION                  '@B0@'."  Stop
ICON_2 ICON_BOOKING_OK                '@B1@'."  Stop
ICON_2 ICON_BOOKING_STOP              '@B2@'."  Stop
ICON_2 ICON_STATUS_OPEN               '@B3@'."  Stop
ICON_2 ICON_STATUS_BOOKED             '@B4@'."  Stop
ICON_2 ICON_STATUS_PARTLY_BOOKED      '@B5@'."  Stop
ICON_2 ICON_STATUS_REVERSE            '@B6@'."  Stop
ICON_2 ICON_PREFERENCE                '@B7@'."  Stop
ICON_2 ICON_NEXT_STEP                 '@B8@'."  Stop
ICON_2 ICON_PREVIOUS_STEP             '@B9@'."  Stop
ICON_2 ICON_STORNO                    '@BA@'."  Stop
ICON_2 ICON_INTERCHANGE               '@BB@'."  Stop
ICON_2 ICON_CASHING_UP                '@BC@'."  Stop
ICON_2 ICON_WORKLOAD                  '@BD@'."  Stop
ICON_2 ICON_PROPOSITION               '@BE@'."  Stop
ICON_2 ICON_PRESENCE                  '@BF@'."  Stop
ICON_2 ICON_ABSENCE                   '@BG@'."  Stop
ICON_2 ICON_TIME_CONTROL              '@BH@'."  Stop
ICON_2 ICON_POSITION_HR               '@BI@'."  Stop
ICON_2 ICON_PARAMETER_TABLE           '@BJ@'."  Stop
ICON_2 ICON_TASK                      '@BK@'."  Stop
ICON_2 ICON_COST_CENTER               '@BL@'."  Stop
ICON_2 ICON_MANAGER                   '@BM@'."  Stop
ICON_2 ICON_ORG_UNIT                  '@BN@'."  Stop
ICON_2 ICON_QUERY                     '@BO@'."  Stop
ICON_2 ICON_WORKFLOW_INBOX            '@BP@'."  Stop
ICON_2 ICON_FAST_ENTRY                '@BQ@'."  Stop
ICON_2 ICON_LIFE_EVENTS               '@BR@'."  Stop
ICON_2 ICON_WORK_CENTER               '@BS@'."  Stop
ICON_2 ICON_GRADUATE                  '@BT@'."  Stop
ICON_2 ICON_EXTRA                     '@BU@'."  Stop
ICON_2 ICON_CONVERT_ALL               '@BV@'."  Stop
ICON_2 ICON_RELATION                  '@BW@'."  Stop
ICON_2 ICON_CONFIGURATION             '@BX@'."  Stop
ICON_2 ICON_WIZARD                    '@BY@'."  Stop
ICON_2 ICON_LED_INACTIVE              '@BZ@'."  Stop
ICON_2 ICON_STORE                     '@C0@'."  Stop
ICON_2 ICON_LINK                      '@C1@'."  Stop
ICON_2 ICON_LATE_STORE                '@C2@'."  Stop
ICON_2 ICON_LATE_LINK                 '@C3@'."  Stop
ICON_2 ICON_EARLY_STORE               '@C4@'."  Stop
ICON_2 ICON_EARLY_LINK                '@C5@'."  Stop
ICON_2 ICON_OO_CLASS_EVENT            '@C6@'."  Stop
ICON_2 ICON_OO_INST_EVENT             '@C7@'."  Stop
ICON_2 ICON_OO_ALIAS                  '@C8@'."  Stop
ICON_2 ICON_OO_OBJECT                 '@C9@'."  Stop
ICON_2 ICON_JOB                       '@CA@'."  Stop
ICON_2 ICON_DELIVERY_DATE             '@CB@'."  Stop
ICON_2 ICON_DELIVERY_COMPLETE         '@CC@'."  Stop
ICON_2 ICON_DELIVERY_PROPOSAL         '@CD@'."  Stop
ICON_2 ICON_PDIR_BACK_SWITCH          '@CE@'."  Stop
ICON_2 ICON_PDIR_BACK                 '@CF@'."  Stop
ICON_2 ICON_PDIR_FOREWARD             '@CG@'."  Stop
ICON_2 ICON_PDIR_FOREWARD_SWITCH      '@CH@'."  Stop
ICON_2 ICON_FINITE                    '@CI@'."  Stop
ICON_2 ICON_NONWORK                   '@CJ@'."  Stop
ICON_2 ICON_PM_FREE                   '@CK@'."  Stop
ICON_2 ICON_PM_INSERT                 '@CL@'."  Stop
ICON_2 ICON_PM_PRESS                  '@CM@'."  Stop
ICON_2 ICON_PM_ORDER                  '@CN@'."  Stop
ICON_2 ICON_DANGEROUS_GOOD_CHECK      '@CO@'."  Stop
ICON_2 ICON_WORKFLOW_DOC_CREATE       '@CP@'."  Stop
ICON_2 ICON_WF_LINK                   '@CQ@'."  Stop
ICON_2 ICON_WF_UNLINK                 '@CR@'."  Stop
ICON_2 ICON_WF_WORKITEM_READY         '@CS@'."  Stop
ICON_2 ICON_WF_WORKITEM_RESERVED      '@CT@'."  Stop
ICON_2 ICON_WF_WORKITEM_STARTED       '@CU@'."  Stop
ICON_2 ICON_WF_WORKITEM_COMMITTED     '@CV@'."  Stop
ICON_2 ICON_WF_WORKITEM_WAITING       '@CW@'."  Stop
ICON_2 ICON_WF_WORKITEM_COMPLETED     '@CX@'."  Stop
ICON_2 ICON_WF_WORKITEM_ERROR         '@CY@'."  Stop
ICON_2 ICON_WF_WORKITEM_CANCEL        '@CZ@'."  Stop
ICON_2 ICON_WF_RESERVE_WORKITEM       '@D0@'."  Stop
ICON_2 ICON_WF_REPLACE_WORKITEM       '@D1@'."  Stop
ICON_2 ICON_PROFIT_CENTER             '@D2@'."  Stop
ICON_2 ICON_WF_RULE_SYSTEM            '@D3@'."  Stop
ICON_2 ICON_WF_PARAMETER              '@D4@'."  Stop
ICON_2 ICON_JAPAN                     '@D5@'."  Stop
ICON_2 ICON_SLS                       '@D6@'."  Stop
ICON_2 ICON_CUSTOMS                   '@D7@'."  Stop
ICON_2 ICON_LEGAL_REG                 '@D8@'."  Stop
ICON_2 ICON_COMPANY_CODE              '@D9@'."  Stop
ICON_2 ICON_UNIT_COSTING              '@DA@'."  Stop
ICON_2 ICON_BASE_PLANNING_OBJECT      '@DB@'."  Stop
ICON_2 ICON_ACTIVITY_TYPE             '@DC@'."  Stop
ICON_2 ICON_RENTAL_AGREEMENT          '@DD@'."  Stop
ICON_2 ICON_REAL_ESTATE_OBJECT        '@DE@'."  Stop
ICON_2 ICON_COMPLETE                  '@DF@'."  Stop
ICON_2 ICON_PARTNER                   '@DG@'."  Stop
ICON_2 ICON_PROTOCOL                  '@DH@'."  Stop
ICON_2 ICON_MAINTENANCE_OBJECT_LIST   '@DI@'."  Stop
ICON_2 ICON_XXL                       '@DJ@'."  Stop
ICON_2 ICON_WORD_PROCESSING           '@DK@'."  Stop
ICON_2 ICON_ABC                       '@DL@'."  Stop
ICON_2 ICON_ALV_VARIANT_CHOOSE        '@DM@'."  Stop
ICON_2 ICON_ALV_VARIANT_SAVE          '@DN@'."  Stop
ICON_2 ICON_EXCLUDED_CORRESPONDENCE   '@DO@'."  Stop
ICON_2 ICON_INCREASE_DECIMAL          '@DP@'."  Stop
ICON_2 ICON_DECREASE_DECIMAL          '@DQ@'."  Stop
ICON_2 ICON_ERROR_PROTOCOL            '@DR@'."  Stop
ICON_2 ICON_PARTNER_SALES_ACTIVITY    '@DS@'."  Stop
ICON_2 ICON_PHONE_CALL_IN             '@DT@'."  Stop
ICON_2 ICON_NAFTA                     '@DU@'."  Stop
ICON_2 ICON_EU                        '@DV@'."  Stop
ICON_2 ICON_PHONE_CALL_OUT            '@DW@'."  Stop
ICON_2 ICON_CONTROLLING_AREA          '@DX@'."  Stop
ICON_2 ICON_DISTRIBUTION_LIST         '@DY@'."  Stop
ICON_2 ICON_MAIL_SAP_UNREAD           '@DZ@'."  Stop
ICON_2 ICON_MAIL_SAP_READ             '@E0@'."  Stop
ICON_2 ICON_ENVELOPE_OPEN             '@E1@'."  Stop
ICON_2 ICON_ENVELOPE_CLOSED           '@E2@'."  Stop
ICON_2 ICON_OFFICE_DOCUMENT           '@E3@'."  Stop
ICON_4 ICON_INCLUDE_IN_SELECTION      '@E4@'."  Stop
ICON_2 ICON_WF_WORKITEM_OL            '@E5@'."  Stop
ICON_2 ICON_NEW_HANDLING_UNIT         '@E6@'."  Stop
ICON_2 ICON_NEW_HANDLING_IF_FULL      '@E7@'."  Stop
ICON_2 ICON_PACKING                   '@E8@'."  Stop
ICON_2 ICON_UNPACK                    '@E9@'."  Stop
ICON_2 ICON_EMPTY_HANDLING_UNIT       '@EA@'."  Stop
ICON_4 ICON_LIGHT_OUT                 '@EB@'."  Stop
ICON_2 ICON_PS_PROJECT_DEFINITION     '@EC@'."  Stop
ICON_2 ICON_PS_WBS_ELEMENT            '@ED@'."  Stop
ICON_2 ICON_PS_NETWORK_HEADER         '@EE@'."  Stop
ICON_2 ICON_PS_NETWORK_ACTIVITY       '@EF@'."  Stop
ICON_2 ICON_PS_ACTIVITY_ELEMENT       '@EG@'."  Stop
ICON_2 ICON_PS_RELATIONSHIP           '@EH@'."  Stop
ICON_2 ICON_STATUS                    '@EI@'."  Stop
ICON_2 ICON_BATCH                     '@EJ@'."  Stop
ICON_2 ICON_ADMINISTRATIVE_DATA       '@EK@'."  Stop
ICON_2 ICON_STOCK                     '@EL@'."  Stop
ICON_2 ICON_ACCOUNT_ASSIGNMENT        '@EM@'."  Stop
ICON_2 ICON_LOT_ORIGIN                '@EN@'."  Stop
ICON_2 ICON_INSPECTION_LOT            '@EO@'."  Stop
ICON_2 ICON_SHOW_EXTERNAL_JOBS        '@EP@'."  Stop
ICON_2 ICON_SPOOL_REQUEST             '@EQ@'."  Stop
ICON_2 ICON_OUTPUT_REQUEST            '@ER@'."  Stop
ICON_2 ICON_DELETE_FAVORITES          '@ES@'."  Stop
ICON_2 ICON_SHOW_EVENTS               '@ET@'."  Stop
ICON_2 ICON_SPOOL_STATUS              '@EU@'."  Stop
ICON_2 ICON_INSERT_FAVORITES          '@EV@'."  Stop
ICON_2 ICON_PRINT_WITH_PARAMETERS     '@EW@'."  Stop
ICON_2 ICON_USED_RELATION             '@EX@'."  Stop
ICON_2 ICON_MAPPED_RELATION           '@EY@'."  Stop
ICON_2 ICON_CREATE_COPY               '@EZ@'."  Stop
ICON_2 ICON_FLUSH                     '@F0@'."  Stop
ICON_2 ICON_DEFECT                    '@F1@'."  Stop
ICON_2 ICON_BW_GIS                    '@F2@'."  Stop
ICON_2 ICON_BW_INFO_CUBE_SAP          '@F3@'."  Stop
ICON_2 ICON_BW_INFO_CUBE_INA          '@F4@'."  Stop
ICON_2 ICON_BW_INFO_OBJECT_CATALOGUE  '@F5@'."  Stop
ICON_2 ICON_BW_SUGGEST_VALUE          '@F6@'."  Stop
ICON_2 ICON_DOC_POSITION_PROPOSAL     '@F7@'."  Stop
ICON_2 ICON_CUSTOMER_MASTER_DATA_LIST '@F8@'."  Stop
ICON_2 ICON_STATUS_OVERVIEW           '@F9@'."  Stop
ICON_2 ICON_DOC_HEADER_DETAIL         '@FA@'."  Stop
ICON_2 ICON_DOC_ITEM_DETAIL           '@FB@'."  Stop
ICON_2 ICON_AVAILABILITY_CHECK        '@FC@'."  Stop
ICON_2 ICON_PRICE                     '@FD@'."  Stop
ICON_2 ICON_SCHEDULE_LINE             '@FE@'."  Stop
ICON_2 ICON_AVAILABILITY_DISPLAY      '@FF@'."  Stop
ICON_2 ICON_STATISTICS                '@FG@'."  Stop
ICON_2 ICON_CLAIM                     '@FH@'."  Stop
ICON_2 ICON_PLANNING_SITUATION        '@FI@'."  Stop
ICON_2 ICON_CHANGE_ORDER              '@FJ@'."  Stop
ICON_2 ICON_PRODUCT_REQUIREMENTS      '@FK@'."  Stop
ICON_2 ICON_PRODUCT_RECEIPTS          '@FL@'."  Stop
ICON_2 ICON_ATTACHMENT                '@FM@'."  Stop
ICON_2 ICON_CLOSED_FOLDER             '@FN@'."  Stop
ICON_2 ICON_OPEN_FOLDER               '@FO@'."  Stop
ICON_2 ICON_OBJECT_FOLDER             '@FP@'."  Stop
ICON_2 ICON_OUTBOX                    '@FQ@'."  Stop
ICON_2 ICON_RESUBMISSION              '@FR@'."  Stop
ICON_2 ICON_PRIVATE_FILES             '@FS@'."  Stop
ICON_2 ICON_PUBLIC_FILES              '@FT@'."  Stop
ICON_2 ICON_SUBSCRIPTION              '@FU@'."  Stop
ICON_2 ICON_AVERAGE                   '@FV@'."  Stop
ICON_2 ICON_BOLD                      '@FW@'."  Stop
ICON_2 ICON_ITALIC                    '@FX@'."  Stop
ICON_2 ICON_UNDERLINE                 '@FY@'."  Stop
ICON_2 ICON_ALIGN_LEFT                '@FZ@'."  Stop
ICON_2 ICON_ALIGN_RIGHT               '@G0@'."  Stop
ICON_2 ICON_ALIGN_CENTER              '@G1@'."  Stop
ICON_2 ICON_JUSTIFIED                 '@G2@'."  Stop
ICON_2 ICON_COLOR                     '@G3@'."  Stop
ICON_2 ICON_DELETE_ALL_ATTRIBUTES     '@G4@'."  Stop
ICON_2 ICON_IDOC                      '@G5@'."  Stop
ICON_2 ICON_HOST                      '@G6@'."  Stop
ICON_2 ICON_SYM_SPOOL_SERVER          '@G7@'."  Stop
ICON_2 ICON_SYM_REAL_SERVER           '@G8@'."  Stop
ICON_2 ICON_SYM_LOG_SERVER            '@G9@'."  Stop
ICON_2 ICON_SYM_ALT_SERVER            '@GA@'."  Stop
ICON_2 ICON_CONNECT                   '@GB@'."  Stop
ICON_2 ICON_DISCONNECT                '@GC@'."  Stop
ICON_2 ICON_FILTER_UNDO               '@GD@'."  Stop
ICON_2 ICON_SET_SUM_UNDO              '@GE@'."  Stop
ICON_2 ICON_INTENSIFY_UNDO            '@GF@'."  Stop
ICON_2 ICON_SORT_UNDO                 '@GG@'."  Stop
ICON_2 ICON_BW_DATA_MARTS             '@GH@'."  Stop
ICON_4 ICON_REMOVE_FROM_SELECTION     '@GI@'."  Stop
ICON_2 ICON_BW_CHARACTERISTICS_SAP    '@GJ@'."  Stop
ICON_2 ICON_BW_KEYFIGURE_SAP          '@GK@'."  Stop
ICON_2 ICON_BW_INFO_OBJECT_UNITS_SAP  '@GL@'."  Stop
ICON_2 ICON_BW_TIME_SAP               '@GM@'."  Stop
ICON_2 ICON_BW_RULES_SAP              '@GN@'."  Stop
ICON_2 ICON_BW_REPORT_SAP             '@GO@'."  Stop
ICON_2 ICON_BW_VARIABLE_SAP           '@GP@'."  Stop
ICON_2 ICON_BW_REF_STRUCTURE_SAP      '@GQ@'."  Stop
ICON_2 ICON_BW_SELECTION_SAP          '@GR@'."  Stop
ICON_2 ICON_INSPECTION_METHOD         '@GS@'."  Stop
ICON_2 ICON_CATALOG                   '@GT@'."  Stop
ICON_2 ICON_INSERT_MULTIPLE_LINES     '@GU@'."  Stop
ICON_2 ICON_INSPECTION_CHARACTERISTIC '@GV@'."  Stop
ICON_2 ICON_PHYSICAL_SAMPLE           '@GW@'."  Stop
ICON_2 ICON_BW_FORMULA_SAP            '@GX@'."  Stop
ICON_2 ICON_BW_INFO_CATALOGUE_SAP     '@GY@'."  Stop
ICON_2 ICON_BUDGET_STRUCTURE_ELEMENT  '@GZ@'."  Stop
ICON_2 ICON_FINANCING                 '@H0@'."  Stop
ICON_2 ICON_RECLASSIFICATION_RULE     '@H1@'."  Stop
ICON_2 ICON_RECLASSIFICATION          '@H2@'."  Stop
ICON_2 ICON_REMOVE                    '@H3@'."  Stop
ICON_2 ICON_SPECIAL_PURPOSE           '@H4@'."  Stop
ICON_2 ICON_DEPUTY                    '@H5@'."  Stop
ICON_2 ICON_BUDGET_UPDATE             '@H6@'."  Stop
ICON_2 ICON_BUDGET_TRANSFER           '@H7@'."  Stop
ICON_2 ICON_BW_SEGMENT_ACT            '@H8@'."  Stop
ICON_2 ICON_BW_SEGMENT_INA            '@H9@'."  Stop
ICON_2 ICON_BW_SEGMENT_SAP            '@HA@'."  Stop
ICON_2 ICON_MASS_CHANGE               '@HB@'."  Stop
ICON_2 ICON_INTENSIFY_CRITICAL        '@HC@'."  Stop
ICON_2 ICON_INTENSIFY_UNCRITICAL      '@HD@'."  Stop
ICON_2 ICON_CHOOSE_COLUMNS            '@HE@'."  Stop
ICON_2 ICON_TOTAL_UP                  '@HF@'."  Stop
ICON_2 ICON_TOTAL_DOWN                '@HG@'."  Stop
ICON_2 ICON_PAGE_UP                   '@HH@'."  Stop
ICON_2 ICON_PAGE_DOWN                 '@HI@'."  Stop
ICON_2 ICON_READ_FILE                 '@HJ@'."  Stop
ICON_2 ICON_WRITE_FILE                '@HK@'."  Stop
ICON_2 ICON_EDIT_FILE                 '@HL@'."  Stop
ICON_2 ICON_PS_MILESTONE              '@HM@'."  Stop
ICON_2 ICON_PS_PROJECT_TEXT           '@HN@'."  Stop
ICON_2 ICON_ELEMENT                   '@HO@'."  Stop
ICON_2 ICON_STRUCTURE                 '@HP@'."  Stop
ICON_2 ICON_WS_WHSE_STOCK             '@HQ@'."  Stop
ICON_2 ICON_ROUTING                   '@HR@'."  Stop
ICON_2 ICON_MATERIAL_ROUTING_ALLOC    '@HS@'."  Stop
ICON_2 ICON_ROUTING_SUB_OPERATION     '@HT@'."  Stop
ICON_2 ICON_ROUTING_REF_SUB_OPERATION '@HU@'."  Stop
ICON_2 ICON_ROUTING_SEQUENCE          '@HV@'."  Stop
ICON_2 ICON_BOM_SUB_ITEM              '@HW@'."  Stop
ICON_2 ICON_EFFECTIVITY_PERIOD        '@HX@'."  Stop
ICON_2 ICON_KEY_DATE                  '@HY@'."  Stop
ICON_2 ICON_SELECTION_PERIOD          '@HZ@'."  Stop
ICON_2 ICON_EFF                       '@I0@'."  Stop
ICON_2 ICON_SUPPLY_AREA               '@I1@'."  Stop
ICON_2 ICON_REPORT_CALL               '@I2@'."  Stop
ICON_2 ICON_ASSIGN                    '@I3@'."  Stop
ICON_2 ICON_UNASSIGN                  '@I4@'."  Stop
ICON_2 ICON_SYSTEM_START_RECORDING    '@I5@'."  Stop
ICON_2 ICON_SYSTEM_PLAY               '@I6@'."  Stop
ICON_2 ICON_TRANSLATION               '@I7@'."  Stop
ICON_2 ICON_TRANSLATION_SHOW          '@I8@'."  Stop
ICON_2 ICON_CHANGE_PASSWORD           '@I9@'."  Stop
ICON_2 ICON_DISTRIBUTE                '@IA@'."  Stop
ICON_2 ICON_SYSTEMS                   '@IB@'."  Stop
ICON_2 ICON_ACTIVITY_GROUP            '@IC@'."  Stop
ICON_2 ICON_USERGROUP                 '@ID@'."  Stop
ICON_2 ICON_UNLINK                    '@IE@'."  Stop
ICON_2 ICON_CONTENT_OBJECT            '@IF@'."  Stop
ICON_2 ICON_OBJECT_LIST               '@IG@'."  Stop
ICON_2 ICON_FOLDER                    '@IH@'."  Stop
ICON_2 ICON_DIFFERENCE                '@II@'."  Stop
ICON_2 ICON_DIFFERENCE_BACK           '@IJ@'."  Stop
ICON_2 ICON_SYSTEM_DESELECT           '@IK@'."  Stop
ICON_2 ICON_ADOPT                     '@IL@'."  Stop
ICON_2 ICON_TERMINOLOGY               '@IM@'."  Stop
ICON_2 ICON_TRIANGULAR_RELATIONSHIP   '@IN@'."  Stop
ICON_2 ICON_AEW_PROJECT               '@IO@'."  Stop
ICON_2 ICON_SICKNESS                  '@IP@'."  Stop
ICON_2 ICON_HOLIDAY                   '@IQ@'."  Stop
ICON_2 ICON_ROLE                      '@IR@'."  Stop
ICON_2 ICON_PERSONNEL_ADMINISTRATION  '@IS@'."  Stop
ICON_2 ICON_PDF                       '@IT@'."  Stop
ICON_2 ICON_BMP                       '@IU@'."  Stop
ICON_2 ICON_FAX_DOC                   '@IV@'."  Stop
ICON_2 ICON_GIF                       '@IW@'."  Stop
ICON_2 ICON_HLP                       '@IX@'."  Stop
ICON_2 ICON_HTT                       '@IY@'."  Stop
ICON_2 ICON_ITS                       '@IZ@'."  Stop
ICON_2 ICON_JPG                       '@J0@'."  Stop
ICON_2 ICON_MSG                       '@J1@'."  Stop
ICON_2 ICON_XLS                       '@J2@'."  Stop
ICON_2 ICON_XLV                       '@J3@'."  Stop
ICON_2 ICON_HTM                       '@J4@'."  Stop
ICON_2 ICON_PPT                       '@J5@'."  Stop
ICON_2 ICON_DOT                       '@J6@'."  Stop
ICON_2 ICON_DOC                       '@J7@'."  Stop
ICON_2 ICON_EML                       '@J8@'."  Stop
ICON_2 ICON_RTF                       '@J9@'."  Stop
ICON_2 ICON_TIF                       '@JA@'."  Stop
ICON_2 ICON_WRI                       '@JB@'."  Stop
ICON_2 ICON_LWP                       '@JC@'."  Stop
ICON_2 ICON_LOTUS                     '@JD@'."  Stop
ICON_2 ICON_VSD                       '@JE@'."  Stop
ICON_2 ICON_DEFAULT_WINDOWS           '@JF@'."  Stop
ICON_2 ICON_DISPLAY_TREE              '@JG@'."  Stop
ICON_2 ICON_EXTENDED_SEARCH           '@JH@'."  Stop
ICON_2 ICON_CLOSE_OBJECT              '@JI@'."  Stop
ICON_2 ICON_OPEN                      '@JJ@'."  Stop
ICON_2 ICON_POLICY                    '@JK@'."  Stop
ICON_2 ICON_PAYMENT                   '@JL@'."  Stop
ICON_2 ICON_CATASTROPHE               '@JM@'."  Stop
ICON_2 ICON_AGGREGATE                 '@JN@'."  Stop
ICON_2 ICON_SUBCLAIM_PERSONAL_INJURY  '@JO@'."  Stop
ICON_2 ICON_SUB_INTELLECTUAL_PROPERTY '@JP@'."  Stop
ICON_2 ICON_SUBCLAIM_VEHICLE          '@JQ@'."  Stop
ICON_2 ICON_SUB_PERSONAL_PROPERTY     '@JR@'."  Stop
ICON_2 ICON_SUBCLAIM_BUILDING         '@JS@'."  Stop
ICON_2 ICON_SUB_BODILY_INJURY_TREAT   '@JT@'."  Stop
ICON_2 ICON_SUBCLAIM_BODILY_INJURY    '@JU@'."  Stop
ICON_2 ICON_SUB_ENVRONMENTAL_SITE     '@JV@'."  Stop
ICON_2 ICON_SUB_FINANCIAL_IMPAIRMENT  '@JW@'."  Stop
ICON_2 ICON_BW_PROCESS                '@JX@'."  Stop
ICON_2 ICON_BW_SIMULATE               '@JY@'."  Stop
ICON_2 ICON_BW_PROCESS_CANCEL         '@JZ@'."  Stop
ICON_2 ICON_BW_SIMULATE_CANCEL        '@K0@'."  Stop
ICON_2 ICON_DATA_AREA_EXPAND          '@K1@'."  Stop
ICON_2 ICON_DATA_AREA_COLLAPSE        '@K2@'."  Stop
ICON_2 ICON_SCRAP                     '@K3@'."  Stop
ICON_2 ICON_IMPORT_ALL_REQUESTS       '@K4@'."  Stop
ICON_2 ICON_IMPORT_TRANSPORT_REQUEST  '@K5@'."  Stop
ICON_2 ICON_TOGGLE_DISPLAY            '@K6@'."  Stop
ICON_2 ICON_TOGGLE_FUNCTION           '@K7@'."  Stop
ICON_2 ICON_PERSONAL_SETTINGS         '@K8@'."  Stop
ICON_2 ICON_PROJECT                   '@K9@'."  Stop
ICON_2 ICON_INCLUDE_OBJECTS           '@KA@'."  Stop
ICON_2 ICON_TRANSFER                  '@KB@'."  Stop
ICON_2 ICON_DISTRIBUTE_CONFIGURATION  '@KC@'."  Stop
ICON_2 ICON_ADJUST_CONFIGURATION      '@KD@'."  Stop
ICON_2 ICON_STANDARD_CONFIGURATION    '@KE@'."  Stop
ICON_2 ICON_MODIFIED_OBJECT           '@KF@'."  Stop
ICON_2 ICON_SELECT_WITH_CONDITION     '@KG@'."  Stop
ICON_2 ICON_ADDRESS_LIST              '@KH@'."  Stop
ICON_2 ICON_APPOINTMENT_COMPARISON    '@KI@'."  Stop
ICON_2 ICON_BUSINESS_PARTNER_MASTER_D '@KJ@'."  Stop
ICON_2 ICON_INCOMPLETION_LOG          '@KK@'."  Stop
ICON_2 ICON_MESSAGE                   '@KL@'."  Stop
ICON_2 ICON_TELEPHONE_CALL            '@KM@'."  Stop
ICON_2 ICON_VISIT                     '@KN@'."  Stop
ICON_2 ICON_LETTER                    '@KO@'."  Stop
ICON_2 ICON_OPERATOR                  '@KP@'."  Stop
ICON_2 ICON_SYSTEM_ADMINISTRATOR      '@KQ@'."  Stop
ICON_2 ICON_SAP                       '@KR@'."  Stop
ICON_2 ICON_PUBLIC                    '@KS@'."  Stop
ICON_2 ICON_SUMMARIZE                 '@KT@'."  Stop
ICON_2 ICON_SUMMARIZE_UNDO            '@KU@'."  Stop
ICON_2 ICON_SUM_RED                   '@KV@'."  Stop
ICON_2 ICON_UNSPECIFIED_ONE           '@KW@'."  Stop
ICON_2 ICON_UNSPECIFIED_TWO           '@KX@'."  Stop
ICON_2 ICON_UNSPECIFIED_THREE         '@KY@'."  Stop
ICON_2 ICON_UNSPECIFIED_FOUR          '@KZ@'."  Stop
ICON_2 ICON_UNSPECIFIED_FIVE          '@L0@'."  Stop
ICON_2 ICON_HR_MANAGER                '@L1@'."  Stop
ICON_2 ICON_TBH                       '@L2@'."  Stop
ICON_2 ICON_TBH_HOLD                  '@L3@'."  Stop
ICON_2 ICON_NEW_EMPLOYEE              '@L4@'."  Stop
ICON_2 ICON_INCOMING_EMPLOYEE         '@L5@'."  Stop
ICON_2 ICON_OUTGOING_EMPLOYEE         '@L6@'."  Stop
ICON_2 ICON_OBSOLETE_POSITION         '@L7@'."  Stop
ICON_2 ICON_TERMINATED_POSITION       '@L8@'."  Stop
ICON_2 ICON_SHARED_POSITION           '@L9@'."  Stop
ICON_2 ICON_OBSOLETE_SHARED_POSITION  '@LA@'."  Stop
ICON_2 ICON_TERMINATED_SHARED_POSITIO '@LB@'."  Stop
ICON_2 ICON_HR_POSITION               '@LC@'."  Stop
ICON_2 ICON_CREATE_POSITION           '@LD@'."  Stop
ICON_2 ICON_HR_ORG_UNIT               '@LE@'."  Stop
ICON_2 ICON_TERMINATED_ORG_UNIT       '@LF@'."  Stop
ICON_2 ICON_NEW_ORG_UNIT              '@LG@'."  Stop
ICON_2 ICON_OUTGOING_ORG_UNIT         '@LH@'."  Stop
ICON_2 ICON_INCOMING_ORG_UNIT         '@LI@'."  Stop
ICON_2 ICON_NEW_TASK                  '@LJ@'."  Stop
ICON_2 ICON_TERMINATED_TASK           '@LK@'."  Stop
ICON_2 ICON_OUTGOING_TASK             '@LL@'."  Stop
ICON_2 ICON_INCOMING_TASK             '@LM@'."  Stop
ICON_2 ICON_OUTGOING_JOB              '@LN@'."  Stop
ICON_2 ICON_INCOMING_JOB              '@LO@'."  Stop
ICON_2 ICON_NEW_JOB                   '@LP@'."  Stop
ICON_2 ICON_TERMINATED_JOB            '@LQ@'."  Stop
ICON_2 ICON_INCOMING_OBJECT           '@LR@'."  Stop
ICON_2 ICON_OUTGOING_OBJECT           '@LS@'."  Stop
ICON_2 ICON_WS_START_WHSE_PROC_BACKGR '@LT@'."  Stop
ICON_2 ICON_WS_START_WHSE_PROC_FOREGR '@LU@'."  Stop
ICON_2 ICON_WS_CONFIRM_WHSE_PROC_BACK '@LV@'."  Stop
ICON_2 ICON_WS_CONFIRM_WHSE_PROC_FORE '@LW@'."  Stop
ICON_2 ICON_HOLD                      '@LX@'."  Stop
ICON_2 ICON_HOLD_UNDO                 '@LY@'."  Stop
ICON_2 ICON_ALV_VARIANTS              '@LZ@'."  Stop
ICON_2 ICON_TE_FLAT_RATE              '@M0@'."  Stop
ICON_2 ICON_BIW_SOURCE_SYS_OWN        '@M1@'."  Stop
ICON_2 ICON_WORKFLOW_JOIN             '@M2@'."  Stop
ICON_2 ICON_WORKFLOW_PROCESS          '@M3@'."  Stop
ICON_2 ICON_BACKGROUND_JOB            '@M4@'."  Stop
ICON_2 ICON_JOB_DETAIL                '@M5@'."  Stop
ICON_2 ICON_SYSTEMTYPE                '@M6@'."  Stop
ICON_2 ICON_COMPOSITE_ACTIVITYGROUP   '@M7@'."  Stop
ICON_2 ICON_TREND_DOWN                '@M8@'."  Stop
ICON_2 ICON_TREND_DECREASING          '@M9@'."  Stop
ICON_2 ICON_TREND_UNCHANGED           '@MA@'."  Stop
ICON_2 ICON_TREND_RISING              '@MB@'."  Stop
ICON_2 ICON_TREND_UP                  '@MC@'."  Stop
ICON_2 ICON_STATUS_ALERT              '@MD@'."  Stop
ICON_2 ICON_STATUS_OK                 '@ME@'."  Stop
ICON_2 ICON_STATUS_BEST               '@MF@'."  Stop
ICON_2 ICON_NO_STATUS                 '@MG@'."  Stop
ICON_2 ICON_DRAW_SELECT               '@MH@'."  Stop
ICON_2 ICON_DRAW_FREEHAND             '@MI@'."  Stop
ICON_2 ICON_DRAW_ARROW                '@MJ@'."  Stop
ICON_2 ICON_DRAW_LINE                 '@MK@'."  Stop
ICON_2 ICON_DRAW_POLYLINE             '@ML@'."  Stop
ICON_2 ICON_DRAW_ELLIPSE              '@MM@'."  Stop
ICON_2 ICON_DRAW_POLYGON              '@MN@'."  Stop
ICON_2 ICON_DRAW_RECTANGLE            '@MO@'."  Stop
ICON_2 ICON_DRAW_ANGULAR              '@MP@'."  Stop
ICON_2 ICON_DRAW_LINEAR               '@MQ@'."  Stop
ICON_2 ICON_DRAW_RADIAL               '@MR@'."  Stop
ICON_2 ICON_BW_EXCEPTION_MONITOR      '@MS@'."  Stop
ICON_2 ICON_BOOKMARK                  '@MT@'."  Stop
ICON_2 ICON_TRANSFER_STRUCTURE_INA    '@MU@'."  Stop
ICON_2 ICON_EXCEPTION                 '@MV@'."  Stop
ICON_2 ICON_RANKING                   '@MW@'."  Stop
ICON_2 ICON_PPE_BHNODE                '@MX@'."  Stop
ICON_2 ICON_PPE_AENODE                '@MY@'."  Stop
ICON_2 ICON_PPE_ANODE                 '@MZ@'."  Stop
ICON_2 ICON_PPE_CVNODE                '@N0@'."  Stop
ICON_2 ICON_PPE_SNODE                 '@N1@'."  Stop
ICON_2 ICON_PPE_ENODE                 '@N2@'."  Stop
ICON_2 ICON_PPE_APNODE                '@N3@'."  Stop
ICON_2 ICON_PPE_VNODE                 '@N4@'."  Stop
ICON_2 ICON_PPE_MODNODE               '@N5@'."  Stop
ICON_2 ICON_PPE_AANODE                '@N6@'."  Stop
ICON_2 ICON_PPE_AAEXPNODE             '@N7@'."  Stop
ICON_2 ICON_PPE_OPNODE                '@N8@'."  Stop
ICON_2 ICON_PPE_ACTNODE               '@N9@'."  Stop
ICON_2 ICON_PPE_VACTNODE              '@NA@'."  Stop
ICON_2 ICON_PPE_VANODE                '@NB@'."  Stop
ICON_2 ICON_PPE_LSEG                  '@NC@'."  Stop
ICON_2 ICON_PPE_PLINE                 '@ND@'."  Stop
ICON_2 ICON_PPE_BPNODE                '@NE@'."  Stop
ICON_2 ICON_GIS_BAR                   '@NF@'."  Stop
ICON_2 ICON_GIS_COLOR_SHADING         '@NG@'."  Stop
ICON_2 ICON_GIS_DEMOTE                '@NH@'."  Stop
ICON_2 ICON_GIS_DOT_DENSITY           '@NI@'."  Stop
ICON_2 ICON_GIS_LAYER_PROPERTIES      '@NJ@'."  Stop
ICON_2 ICON_GIS_PAN                   '@NK@'."  Stop
ICON_2 ICON_GIS_PIE                   '@NL@'."  Stop
ICON_2 ICON_GIS_PROMOTE               '@NM@'."  Stop
ICON_2 ICON_GIS_SPATIAL_SELECT        '@NN@'."  Stop
ICON_2 ICON_GIS_SYMBOL                '@NO@'."  Stop
ICON_2 ICON_CALL_ANSWER               '@NP@'."  Stop
ICON_2 ICON_CALL_ALTERNATE            '@NQ@'."  Stop
ICON_2 ICON_CALL_HOLD                 '@NR@'."  Stop
ICON_2 ICON_CALL_DEFLECT              '@NS@'."  Stop
ICON_2 ICON_CALL_CONSULT              '@NT@'."  Stop
ICON_2 ICON_CALL_CONFERENCE           '@NU@'."  Stop
ICON_2 ICON_CALL_BLIND_TRANSFER       '@NV@'."  Stop
ICON_2 ICON_CALL_RECONNECT            '@NW@'."  Stop
ICON_2 ICON_CALL_RETRIEVE             '@NX@'."  Stop
ICON_2 ICON_CALL_WARM_TRANSFER        '@NY@'."  Stop
ICON_2 ICON_CREATE_CALLBACK           '@NZ@'."  Stop
ICON_2 ICON_PROCESS_CALLBACK          '@O0@'."  Stop
ICON_2 ICON_BW_RA_SETTING_ACTIVE      '@O1@'."  Stop
ICON_2 ICON_BW_RA_SETTING_INACTIVE    '@O2@'."  Stop
ICON_2 ICON_SNC_INFO                  '@O3@'."  Stop
ICON_2 ICON_DELIVERY                  '@O4@'."  Stop
ICON_2 ICON_PPE_ASSY_POS              '@O5@'."  Stop
ICON_2 ICON_PPE_ASSY_HEAD             '@O6@'."  Stop
ICON_2 ICON_PPE_PARTOF_ALT_ACT        '@O7@'."  Stop
ICON_2 ICON_BINARY_DOCUMENT           '@O8@'."  Stop
ICON_2 ICON_ANY_DOCUMENT              '@O9@'."  Stop
ICON_2 ICON_OTF_DOCUMENT              '@OA@'."  Stop
ICON_2 ICON_TEXT_FIELD                '@OB@'."  Stop
ICON_2 ICON_FIELD_WITH_TEXT           '@OC@'."  Stop
ICON_2 ICON_SIMPLE_FIELD              '@OD@'."  Stop
ICON_2 ICON_TRANSPORT_PROPOSAL        '@OE@'."  Stop
ICON_2 ICON_HELPASSISTENT_ON          '@OF@'."  Stop
ICON_2 ICON_HELPASSISTENT_OFF         '@OG@'."  Stop
ICON_2 ICON_DIALGHELP                 '@OH@'."  Stop
ICON_2 ICON_DIALOGHELPACTIV           '@OI@'."  Stop
ICON_2 ICON_STATUS_CRITICAL           '@OJ@'."  Stop
ICON_2 ICON_SYSTEM_SERVICE_FILLED     '@OK@'."  Stop
ICON_2 ICON_SYSTEM_SERVICE_OFF        '@OL@'."  Stop
ICON_2 ICON_SYSTEM_SERVICE_EMPTY      '@OM@'."  Stop
ICON_2 ICON_CONSUMPTION_ALTERNATIVE   '@ON@'."  Stop
ICON_2 ICON_PROCUREMENT_ALTERNATIVE   '@OO@'."  Stop
ICON_2 ICON_PROCUREMENT_PROCESS       '@OP@'."  Stop
ICON_2 ICON_WORKFLOW                  '@OQ@'."  Stop
ICON_2 ICON_DOCUMENT_MODEL_SPACE      '@OR@'."  Stop
ICON_2 ICON_RELATION_CLASS            '@OS@'."  Stop
ICON_2 ICON_IO_ATTRIBUTE              '@OT@'."  Stop
ICON_2 ICON_VIRTUAL_RELATION_CLASS    '@OU@'."  Stop
ICON_2 ICON_CLASS_CONNECTION_SPACE    '@OV@'."  Stop
ICON_2 ICON_IO_PREDEFINED_VALUE       '@OW@'."  Stop
ICON_2 ICON_CONTEXT_CLASS             '@OX@'."  Stop
ICON_2 ICON_LOIO_CLASS                '@OY@'."  Stop
ICON_2 ICON_VIRTUAL_LOIO_CLASS        '@OZ@'."  Stop
ICON_2 ICON_PHIO_CLASS                '@P0@'."  Stop
ICON_2 ICON_VIRTUAL_PHIO_CLASS        '@P1@'."  Stop
ICON_2 ICON_PARAGRAPH                 '@P2@'."  Stop
ICON_2 ICON_MC_CONTENTINDICATOR       '@P3@'."  Stop
ICON_2 ICON_BSC_CONTENTINDICATOR      '@P4@'."  Stop
ICON_2 ICON_RATING_MINUSMINUS         '@P5@'."  Stop
ICON_2 ICON_RATING_MINUS              '@P6@'."  Stop
ICON_2 ICON_RATING_NEUTRAL            '@P7@'."  Stop
ICON_2 ICON_RATING_POSITIVE           '@P8@'."  Stop
ICON_2 ICON_RATING_POSITIVEPOSITIVE   '@P9@'."  Stop
ICON_2 ICON_WORKFLOW_WEB_ACTIVITY     '@PA@'."  Stop
ICON_2 ICON_DELIVERY_NO_CONFIRMATION  '@PB@'."  Stop
ICON_2 ICON_SNAP_TO_GRID              '@PC@'."  Stop
ICON_2 ICON_GRID                      '@PD@'."  Stop
ICON_2 ICON_MAIN_GRID                 '@PE@'."  Stop
ICON_2 ICON_TARGET_GROUP              '@PF@'."  Stop
ICON_2 ICON_DELIVERY_INBOUND          '@PG@'."  Stop
ICON_2 ICON_PPE_LBAL                  '@PH@'."  Stop
ICON_2 ICON_PPE_ENTOBJ                '@PI@'."  Stop
ICON_2 ICON_PAW_TEST                  '@PJ@'."  Stop
ICON_2 ICON_PAW_SUBTEST               '@PK@'."  Stop
ICON_2 ICON_PAW_PU                    '@PL@'."  Stop
ICON_2 ICON_PAW_ITEM                  '@PM@'."  Stop
ICON_2 ICON_BUSINESS_AREA             '@PN@'."  Stop
ICON_2 ICON_DATABASE_TABLE            '@PO@'."  Stop
ICON_2 ICON_DATABASE_TABLE_INA        '@PP@'."  Stop
ICON_2 ICON_CONNECTION_OBJECT         '@PQ@'."  Stop
ICON_2 ICON_CONTRACT_ACCOUNT          '@PR@'."  Stop
ICON_2 ICON_REGISTER                  '@PS@'."  Stop
ICON_2 ICON_INSTALLATION              '@PT@'."  Stop
ICON_2 ICON_BORDER_TOP                '@PU@'."  Stop
ICON_2 ICON_BORDER_RIGHT              '@PV@'."  Stop
ICON_2 ICON_BORDER_OUTSIDE            '@PW@'."  Stop
ICON_2 ICON_BORDER_LEFT               '@PX@'."  Stop
ICON_2 ICON_BORDER_BOTTOM             '@PY@'."  Stop
ICON_2 ICON_BORDER_INSIDE             '@PZ@'."  Stop
ICON_2 ICON_DELETE_TEMPLATE           '@Q0@'."  Stop
ICON_2 ICON_SAVE_AS_TEMPLATE          '@Q1@'."  Stop
ICON_2 ICON_PATIENT_SMARTCARD         '@Q2@'."  Stop
ICON_2 ICON_INITIAL                   '@Q3@'."  Stop
ICON_2 ICON_GENERAL_RECIPE            '@Q4@'."  Stop
ICON_2 ICON_WORKFLOW_ADHOC_ANCHOR     '@Q5@'."  Stop
ICON_2 ICON_PRICE_ANALYSIS            '@Q6@'."  Stop
ICON_2 ICON_COST_COMPONENTS           '@Q7@'."  Stop
ICON_2 ICON_VAL_QUANTITY_STRUCTURE    '@Q8@'."  Stop
ICON_2 ICON_REVALUATED_CONS_ALTERNAT  '@Q9@'."  Stop
ICON_2 ICON_PACKAGE_QUERY             '@QA@'."  Stop
ICON_2 ICON_PACKAGE_DYNAMIC           '@QB@'."  Stop
ICON_2 ICON_PACKAGE_STANDARD          '@QC@'."  Stop
ICON_2 ICON_PACKAGE_APPLICATION       '@QD@'."  Stop
ICON_2 ICON_LINKED_DOCUMENT           '@QE@'."  Stop
ICON_2 ICON_CLOSED_LINKED_FOLDER      '@QF@'."  Stop
ICON_2 ICON_OPEN_LINKED_FOLDER        '@QG@'."  Stop
ICON_2 ICON_REPORT_TEMPLATE           '@QH@'."  Stop
ICON_2 ICON_INFOSET_ACT               '@QI@'."  Stop
ICON_2 ICON_INFOSET_INA               '@QJ@'."  Stop
ICON_2 ICON_CHARACTERISTICS_FML       '@QK@'."  Stop
ICON_2 ICON_CHARACTERISTICS_HIER      '@QL@'."  Stop
ICON_2 ICON_HIERARCHY_RED             '@QM@'."  Stop
ICON_2 ICON_HIERARCHY_VAR_GREEN       '@QN@'."  Stop
ICON_2 ICON_HIERARCHY_VAR_RED         '@QO@'."  Stop
ICON_2 ICON_KEYFIGURE_FML             '@QP@'."  Stop
ICON_2 ICON_VAR_EQUAL_GREEN           '@QQ@'."  Stop
ICON_2 ICON_VAR_EQUAL_RED             '@QR@'."  Stop
ICON_2 ICON_VAR_GR_EQUAL_GREEN        '@QS@'."  Stop
ICON_2 ICON_VAR_GREATER_GREEN         '@QT@'."  Stop
ICON_2 ICON_VAR_LESS_EQUAL_GREEN      '@QU@'."  Stop
ICON_2 ICON_VAR_LESS_GREEN            '@QV@'."  Stop
ICON_2 ICON_VAR_INT_INCLUDE_GREEN     '@QW@'."  Stop
ICON_2 ICON_VAR_INT_INCLUDE_RED       '@QX@'."  Stop
ICON_2 ICON_MULTI_DATA_PROVIDER       '@QY@'."  Stop
ICON_2 ICON_MULTI_DATA_PROVIDER_INA   '@QZ@'."  Stop
ICON_2 ICON_BW_SOURCE_SYS_DB          '@R0@'."  Stop
ICON_2 ICON_BW_SOURCE_SYS_WEB         '@R1@'."  Stop
ICON_2 ICON_BW_DATASOURCE             '@R2@'."  Stop
ICON_2 ICON_BW_WEB_REPORT             '@R3@'."  Stop
ICON_2 ICON_XML_DOC                   '@R4@'."  Stop
ICON_2 ICON_DROPDOWNLIST              '@R5@'."  Stop
ICON_2 ICON_RADIOBUTTON               '@R6@'."  Stop
ICON_2 ICON_CHECKBOX                  '@R7@'."  Stop
ICON_2 ICON_GEO_CHARACTERISTIC        '@R8@'."  Stop
ICON_2 ICON_GEO_CHARACTERISTIC_INA    '@R9@'."  Stop
ICON_2 ICON_MANIKIN_FEMALE            '@RA@'."  Stop
ICON_2 ICON_MANIKIN_MALE              '@RB@'."  Stop
ICON_2 ICON_MANIKIN_UNKNOWN_GENDER    '@RC@'."  Stop
ICON_2 ICON_SYMBOL_FEMALE             '@RD@'."  Stop
ICON_2 ICON_SYMBOL_MALE               '@RE@'."  Stop
ICON_2 ICON_DECEASED_PATIENT          '@RF@'."  Stop
ICON_2 ICON_WD_APPL_COMPONENT         '@RG@'."  Stop
ICON_2 ICON_WD_TAG_LIBRARY            '@RH@'."  Stop
ICON_2 ICON_WD_TAB_LIBRARY_REF        '@RI@'."  Stop
ICON_2 ICON_WD_WEB_PROJECT            '@RJ@'."  Stop
ICON_2 ICON_WD_WEB_APPL_PROJECT       '@RK@'."  Stop
ICON_2 ICON_WD_INBOUND_PLUG           '@RL@'."  Stop
ICON_2 ICON_WD_OUTBOUND_PLUG          '@RM@'."  Stop
ICON_2 ICON_WD_VIEW                   '@RN@'."  Stop
ICON_2 ICON_WD_VIEWS                  '@RO@'."  Stop
ICON_2 ICON_WD_INTERFACE_VIEW         '@RP@'."  Stop
ICON_2 ICON_WD_INTERFACE_VIEWS        '@RQ@'."  Stop
ICON_2 ICON_WD_VIEW_AREA              '@RR@'."  Stop
ICON_2 ICON_WD_VIEW_SET_T_LAYOUT      '@RS@'."  Stop
ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_REV  '@RT@'."  Stop
ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_270  '@RU@'."  Stop
ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_90   '@RV@'."  Stop
ICON_2 ICON_WD_VIEW_SET_TAB_LAYOUT    '@RW@'."  Stop
ICON_2 ICON_WD_VIEW_SET_GRID          '@RX@'."  Stop
ICON_2 ICON_WD_VIEW_CONTAINER         '@RY@'."  Stop
ICON_2 ICON_WD_WINDOWS_COLLECTION     '@RZ@'."  Stop
ICON_2 ICON_WD_WINDOW                 '@S0@'."  Stop
ICON_2 ICON_WD_BUILD_ALL              '@S1@'."  Stop
ICON_2 ICON_WD_BUILD_INCREMENTAL      '@S2@'."  Stop
ICON_2 ICON_WD_COMPONENTS             '@S3@'."  Stop
ICON_2 ICON_WD_COMPONENT              '@S4@'."  Stop
ICON_2 ICON_WD_COMPONENT_INTERFACE    '@S5@'."  Stop
ICON_2 ICON_WD_APPLICATION            '@S6@'."  Stop
ICON_2 ICON_WD_APPLICATIONS           '@S7@'."  Stop
ICON_2 ICON_WD_CONTEXT                '@S8@'."  Stop
ICON_2 ICON_WD_VALUE_NODE             '@S9@'."  Stop
ICON_2 ICON_WD_VALUE_ATTR             '@SA@'."  Stop
ICON_2 ICON_WD_MAPPED_VALUE_NODE      '@SB@'."  Stop
ICON_2 ICON_WD_MAPPED_VALUE_ATTR      '@SC@'."  Stop
ICON_2 ICON_WD_MODEL_NODE             '@SD@'."  Stop
ICON_2 ICON_WD_MODEL_ATTRIBUTE        '@SE@'."  Stop
ICON_2 ICON_WD_MAPPED_MODEL_NODE      '@SF@'."  Stop
ICON_2 ICON_WD_MAPPED_MODEL_ATTR      '@SG@'."  Stop
ICON_2 ICON_WD_RECURSION_NODE         '@SH@'."  Stop
ICON_2 ICON_WD_IMAGE                  '@SI@'."  Stop
ICON_2 ICON_WD_CAPTION                '@SJ@'."  Stop
ICON_2 ICON_WD_BUSINESS_GRAPHICS      '@SK@'."  Stop
ICON_2 ICON_WD_LABEL                  '@SL@'."  Stop
ICON_2 ICON_WD_INPUT_FIELD            '@SM@'."  Stop
ICON_2 ICON_WD_NUMERIC_VALUE          '@SN@'."  Stop
ICON_2 ICON_WD_TIME_VALUE             '@SO@'."  Stop
ICON_2 ICON_WD_CHECK_BOX_INDEXED      '@SP@'."  Stop
ICON_2 ICON_WD_CHECK_BOX_GROUP        '@SQ@'."  Stop
ICON_2 ICON_WD_RADIO_BUTTON_EMPTY     '@SR@'."  Stop
ICON_2 ICON_WD_RADIO_BUTTON_INDEX     '@SS@'."  Stop
ICON_2 ICON_WD_RADIO_BUTTON_KEY       '@ST@'."  Stop
ICON_2 ICON_WD_DROPDOWN_INDEX         '@SU@'."  Stop
ICON_2 ICON_WD_DROPDOWN_KEY           '@SV@'."  Stop
ICON_2 ICON_WD_LINK_TO_ACTION         '@SW@'."  Stop
ICON_2 ICON_WD_LINK_TO_URL            '@SX@'."  Stop
ICON_2 ICON_WD_TOOLBAR_BUTTON         '@SY@'."  Stop
ICON_2 ICON_WD_TOOLBAR_DROPDOWN_IDX   '@SZ@'."  Stop
ICON_2 ICON_WD_TOOLBAR_DROPDOWN_KEY   '@T0@'."  Stop
ICON_2 ICON_WD_TOOLBAR_INPUT_FIELD    '@T1@'."  Stop
ICON_2 ICON_WD_TOOLBAR_SEPARATOR      '@T2@'."  Stop
ICON_2 ICON_WD_TOOLBAR_CAPTION        '@T3@'."  Stop
ICON_2 ICON_WD_TABLE                  '@T4@'."  Stop
ICON_2 ICON_WD_TABLE_COLUMN           '@T5@'."  Stop
ICON_2 ICON_WD_TREE                   '@T6@'."  Stop
ICON_2 ICON_WD_TREE_NODE              '@T7@'."  Stop
ICON_2 ICON_WD_TREE_ITEM              '@T8@'."  Stop
ICON_2 ICON_WD_IFRAME                 '@T9@'."  Stop
ICON_2 ICON_WD_CHECK_BOX              '@TA@'."  Stop
ICON_2 ICON_WD_RADIO_BUTTON           '@TB@'."  Stop
ICON_2 ICON_WD_BUTTON                 '@TC@'."  Stop
ICON_2 ICON_WD_TEXT_VIEW              '@TD@'."  Stop
ICON_2 ICON_WD_TEXT_EDIT              '@TE@'."  Stop
ICON_2 ICON_WD_TOOLBAR                '@TF@'."  Stop
ICON_2 ICON_WD_TABSTRIP               '@TG@'."  Stop
ICON_2 ICON_WD_TAB                    '@TH@'."  Stop
ICON_2 ICON_WD_GROUP                  '@TI@'."  Stop
ICON_2 ICON_WD_TRAY                   '@TJ@'."  Stop
ICON_2 ICON_WD_TRANSPARENT_CONTAINER  '@TK@'."  Stop
ICON_2 ICON_WD_SCROLL_CONTAINER       '@TL@'."  Stop
ICON_2 ICON_WD_NAVIGATION_LINK        '@TM@'."  Stop
ICON_2 ICON_WD_NAVLINK_BIDIRECTIONAL  '@TN@'."  Stop
ICON_2 ICON_WD_NAVLINK_OUT            '@TO@'."  Stop
ICON_2 ICON_WD_NAVLINK_IN             '@TP@'."  Stop
ICON_2 ICON_WD_CONTROLLER             '@TQ@'."  Stop
ICON_2 ICON_CONTEXT_MENU              '@TR@'."  Stop
ICON_2 ICON_ERASE                     '@TS@'."  Stop
ICON_2 ICON_RETAIL_PRODUCT            '@TT@'."  Stop
ICON_2 ICON_RETAIL_STORE              '@TU@'."  Stop
ICON_2 ICON_HANDLING_UNIT             '@TV@'."  Stop
ICON_2 ICON_BW_DM                     '@TW@'."  Stop
ICON_2 ICON_BW_APD_VISUALIZATION      '@TX@'."  Stop
ICON_2 ICON_BW_APD_TARGET             '@TY@'."  Stop
ICON_2 ICON_BW_APD_TRANSFORMATION     '@TZ@'."  Stop
ICON_2 ICON_BW_APD_SOURCE             '@U0@'."  Stop
ICON_2 ICON_BW_APD_COLUMN_TO_ROW      '@U1@'."  Stop
ICON_2 ICON_BW_APD_ROW_TO_COLUMN      '@U2@'."  Stop
ICON_2 ICON_BW_APD_DB                 '@U3@'."  Stop
ICON_2 ICON_BW_APD                    '@U4@'."  Stop
ICON_2 ICON_BW_DM_3RD                 '@U5@'."  Stop
ICON_2 ICON_BW_DM_WST                 '@U6@'."  Stop
ICON_2 ICON_BW_APD_REGRESSION         '@U7@'."  Stop
ICON_2 ICON_BW_DM_CLUS                '@U8@'."  Stop
ICON_2 ICON_BW_DM_AA                  '@U9@'."  Stop
ICON_2 ICON_BW_DM_DT                  '@UA@'."  Stop
ICON_2 ICON_BW_CONVERT_UNIT           '@UB@'."  Stop
ICON_2 ICON_BW_PLANNING_LAYER         '@UC@'."  Stop
ICON_2 ICON_BW_PLANNING_LAYER_INA     '@UD@'."  Stop
ICON_2 ICON_BW_OPEN_HUB_DESTINATION   '@UE@'."  Stop
ICON_2 ICON_BW_ROTATE_RIGHT           '@UF@'."  Stop
ICON_2 ICON_BW_ROTATE_LEFT            '@UG@'."  Stop
ICON_2 ICON_VIEW_FORM                 '@UH@'."  Stop
ICON_2 ICON_VIEW_LIST                 '@UI@'."  Stop
ICON_2 ICON_MEDIUM                    '@UJ@'."  Stop
ICON_2 ICON_VIEW_MAXIMIZE             '@UK@'."  Stop
ICON_2 ICON_VIEW_EXPAND_VERTICAL      '@UL@'."  Stop
ICON_2 ICON_VIEW_EXPAND_HORIZONTAL    '@UM@'."  Stop
ICON_2 ICON_VIEW_REFRESH              '@UN@'."  Stop
ICON_2 ICON_VIEW_CREATE               '@UO@'."  Stop
ICON_2 ICON_VIEW_CLOSE                '@UP@'."  Stop
ICON_2 ICON_VIEW_SWITCH               '@UQ@'."  Stop
ICON_2 ICON_BREAKPOINT_DISABLE        '@UR@'."  Stop
ICON_2 ICON_WD_CUSTOM_CONTROLLER      '@US@'."  Stop
ICON_2 ICON_WD_CUSTOM_CONTROLLERS     '@UT@'."  Stop
ICON_2 ICON_WD_INPUT_MODEL_ATT        '@UU@'."  Stop
ICON_2 ICON_WD_INPUT_MODEL_NODE       '@UV@'."  Stop
ICON_2 ICON_WD_INPUT_VAL_ATT          '@UW@'."  Stop
ICON_2 ICON_WD_INPUT_VAL_NODE         '@UX@'."  Stop
ICON_2 ICON_WD_MAPPED_INPUT_MODEL_ATT '@UY@'."  Stop
ICON_2 ICON_WD_MAPPED_INPUT_MODEL_NOD '@UZ@'."  Stop
ICON_2 ICON_WD_MAPPED_INPUT_VAL_ATT   '@V0@'."  Stop
ICON_2 ICON_WD_MAPPED_INPUT_VAL_NODE  '@V1@'."  Stop
ICON_2 ICON_WD_COMPONENT_CTRL         '@V2@'."  Stop
ICON_2 ICON_WD_COMPONENT_CTRL_USAGE   '@V3@'."  Stop
ICON_2 ICON_WD_COMPONENT_IF_CTRL      '@V4@'."  Stop
ICON_2 ICON_COMPONENT_IF_DEF          '@V5@'."  Stop
ICON_2 ICON_COMPONENT_IF_DEFS         '@V6@'."  Stop
ICON_2 ICON_WD_COMPONENT_USAGE        '@V7@'."  Stop
ICON_2 ICON_WD_COMPONENT_USAGES       '@V8@'."  Stop
ICON_2 ICON_WEBBREAKPOINT             '@V9@'."  Stop
ICON_2 ICON_WEBBREAKPOINT_DISABLED    '@VA@'."  Stop
ICON_2 ICON_USER_BREAKPOINT           '@VB@'."  Stop
ICON_2 ICON_USER_BREAKPOINT_DISABLED  '@VC@'."  Stop
ICON_2 ICON_CLIENT_BREAKPOINT         '@VD@'."  Stop
ICON_2 ICON_CLIENT_BREAKPOINT_DIS     '@VE@'."  Stop
ICON_2 ICON_ES_REPOSITORY             '@VF@'."  Stop
ICON_2 ICON_RED_DASH                  '@VG@'."  Stop
ICON_2 ICON_RED_SLASH                 '@VH@'."  Stop
ICON_2 ICON_RED_XCIRCLE               '@VI@'."  Stop
ICON_2 ICON_VALUE_HELP                '@VJ@'."  Stop
ICON_2 ICON_BW_DTP_ACTIVE             '@VK@'."  Stop
ICON_2 ICON_BW_DTP_INACTIVE           '@VL@'."  Stop
ICON_2 ICON_BW_OPEN_HUB_INACTIVE      '@VM@'."  Stop
ICON_2 ICON_OO_INTERFACE_MSGTP        '@VN@'."  Stop
ICON_2 ICON_OO_INTERFACE_FAULT_MSGTP  '@VO@'."  Stop
ICON_2 ICON_SEGMENTED_DATA_ACT        '@VP@'."  Stop
ICON_2 ICON_SEGMENTED_DATA_INA        '@VQ@'."  Stop
ICON_2 ICON_BIW_VIRTUAL_INFO_PROVIDER '@VR@'."  Stop
ICON_2 ICON_BIW_VIRTUAL_INFO_PROV_INA '@VS@'."  Stop
ICON_2 ICON_ALL_GREEN                 '@VT@'."  Stop
ICON_2 ICON_BW_SOURCE_SYS_UDC         '@VU@'."  Stop
ICON_2 ICON_AGENT                     '@VV@'."  Stop
ICON_2 ICON_BIW_INFO_SOURCE_INA       '@VW@'."  BW Info Source Inactive
ICON_2 ICON_CHECKED_OUT               '@VX@'."  Checked Out
ICON_2 ICON_CHECKIN_REQUESTED         '@VY@'."  Request Check In
ICON_2 ICON_CHECKOUT_REQUESTED        '@VZ@'."  Request Check Out
ICON_2 ICON_MESSAGE_TYPE              '@W0@'."  Message
ICON_2 ICON_MESSAGE_FAULTY            '@W1@'."  Error Message
ICON_2 ICON_BUSINAV_OBJECTS_UPTODATE  '@W2@'."  Business Object (Current
ICON_2 ICON_BUSINAV_OBJECTS_OUTDATE   '@W3@'."  Business Object (Old)
ICON_2 ICON_BUSINAV_OBJECTS_ORPHAN    '@W4@'."  Business Object (Orphane
ICON_2 ICON_CLOSED_FOLDER_UPTODATE    '@W5@'."  Folder (Current)
ICON_2 ICON_CLOSED_FOLDER_OUTDATE     '@W6@'."  Folder (Old)
ICON_2 ICON_CLOSED_FOLDER_ORPHANED    '@W7@'."  Folder (Orphaned)
ICON_2 ICON_MESSAGE_UPTODATE          '@W8@'."  Message (Current)
ICON_2 ICON_MESSAGE_OUTOFDATE         '@W9@'."  Message (Old)
ICON_2 ICON_MESSAGE_ORPHANED          '@WA@'."  Message (Orphaned)
ICON_2 ICON_MESSAGE_FAULTY_UPTODATE   '@WB@'."  Error Message (Current)
ICON_2 ICON_MESSAGE_FAULTY_OUTDATE    '@WC@'."  Error Message (Old)
ICON_2 ICON_MESSAGE_FAULTY_ORPHAN     '@WD@'."  Error Message (Orphaned)
ICON_2 ICON_OO_INTERFACE_UPTODATE     '@WE@'."  Object Interface (Curren
ICON_2 ICON_OO_INTERFACE_OUTDATE      '@WF@'."  Object Interface (Old)
ICON_2 ICON_OO_INTERFACE_ORPHAN       '@WG@'."  Object Interface (Orphan
ICON_2 ICON_DATATYPES_UPTODATE        '@WH@'."  Data Types (Current)
ICON_2 ICON_DATATYPES_OUTDATE         '@WI@'."  Data Types (Old)
ICON_2 ICON_DATATYPES_ORPHAN          '@WJ@'."  Data Types (Orphaned)
ICON_2 ICON_DATATYPES_ENH_UPTODATE    '@WK@'."  Data Type Enhancement (C
ICON_2 ICON_DATATYPES_ENH_OUTDATE     '@WL@'."  Data Type Enhancement (O
ICON_2 ICON_DATATYPES_ENH_ORPHAN      '@WM@'."  Data Type Enhancement (O
ICON_2 ICON_AGENT_UPTODATE            '@WN@'."  Agent (Current)
ICON_2 ICON_AGENT_OUTDATE             '@WO@'."  Agent (Old)
ICON_2 ICON_AGENT_ORPHAN              '@WP@'."  Agent (Orphaned)
ICON_2 ICON_ENHANCED_BO               '@WQ@'."  Enhanced Business Object
ICON_2 ICON_ENHANCED_BO_UPTODATE      '@WR@'."  Enh. Business Object (Cu
ICON_2 ICON_ENHANCED_BO_OUTDATE       '@WS@'."  Enhance. Business Object
ICON_2 ICON_ENHANCED_BO_ORPHAN        '@WT@'."  En. Business Object (Orp
ICON_2 ICON_STORES                    '@WU@'."  Subsidiaries
ICON_2 ICON_WAREHOUSES                '@WV@'."  Multiple Central Warehou
ICON_2 ICON_CONDITION_BREAKPOINT      '@WW@'."  Multiple Central Warehou
ICON_2 ICON_CONDITION_BREAKPOINT_DIS  '@WX@'."  Multiple Central Warehou
ICON_2 ICON_JOB_FAMILY                '@WY@'."  Multiple Central Warehou
ICON_2 ICON_INTELLECTUAL_PROPERTY     '@WZ@'."  Multiple Central Warehou
ICON_2 ICON_PROPRIETARY               '@X0@'."  Multiple Central Warehou
ICON_2 ICON_INSTALL_PACKAGE           '@X1@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON                 '@X2@'."  Multiple Central Warehou
ICON_2 ICON_SAP_SHORTCUT              '@X3@'."  Multiple Central Warehou
ICON_2 ICON_SAP_GUI_SESSION           '@X4@'."  Multiple Central Warehou
ICON_2 ICON_SAP_SERVER                '@X5@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_SERVER_SSO      '@X6@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_USERDEFINED     '@X7@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_USERDEFINED_SSO '@X8@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP           '@X9@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP_SSO       '@XA@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP_USER      '@XB@'."  Multiple Central Warehou
ICON_2 ICON_SETTINGS                  '@XC@'."  Multiple Central Warehou
ICON_2 ICON_VIEW_TABLE                '@XD@'."  Multiple Central Warehou
ICON_2 ICON_VIEW_HIER_LIST            '@XE@'."  Multiple Central Warehou
ICON_2 ICON_VIEW_TREE                 '@XF@'."  Multiple Central Warehou
ICON_2 ICON_VIEW_THUMBNAILS           '@XG@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP_CERT      '@XH@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP_CERT_SSO  '@XI@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP_CERT_USER '@XJ@'."  Multiple Central Warehou
ICON_2 ICON_LOGON_GROUP_CERT_SSO_USR  '@XK@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_SRV_CERT        '@XL@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_SRV_CERT_SSO    '@XM@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_SRV_CERT_USER   '@XN@'."  Multiple Central Warehou
ICON_2 ICON_LOGON_SRV_CERT_SSO_USER   '@XO@'."  Multiple Central Warehou
ICON_2 ICON_MASS_CHANGE_DONE          '@XP@'."  Multiple Central Warehou
ICON_2 ICON_REMOVE_ROW                '@XQ@'."  Multiple Central Warehou
ICON_2 ICON_ADD_ROW                   '@XR@'."  Multiple Central Warehou
ICON_2 ICON_SAP_LOGON_GROUP_SSO_USR   '@XS@'."  Multiple Central Warehou
ICON_2 ICON_APPLE_KEYNOTE             '@XT@'."  Multiple Central Warehou
ICON_2 ICON_APPLE_NUMBERS             '@XU@'."  Multiple Central Warehou
ICON_2 ICON_APPLE_PAGES               '@XV@'."  Multiple Central Warehou
ICON_2 ICON_GOS_SERVICES              '@XW@'."  Multiple Central Warehou
ICON_2 ICON_GOS_SERVICES_ATTACHMENT   '@XX@'."  Multiple Central Warehou
ICON_2 ICON_GOS_SERVICES_RELATIONS    '@XY@'."  Multiple Central Warehou
ICON_2 ICON_GOS_SERVICES_ATT_REL      '@XZ@'."  Multiple Central Warehou
ICON_2 ICON_REBATE                    '@Y0@'."  Multiple Central Warehou
ICON_2 ICON_CHARGE                    '@Y1@'."  Multiple Central Warehou
ICON_2 ICON_START_VIEWER              '@Y2@'."  Multiple Central Warehou
ICON_2 ICON_CLOUD                     '@Y3@'."  Multiple Central Warehou
ICON_2 ICON_CLOUD_DOWNLOAD            '@Y4@'."  Multiple Central Warehou
ICON_2 ICON_CLOUD_UPLOAD              '@Y5@'."  Multiple Central Warehou
ICON_2 ICON_SHOPPINGCART              '@Y6@'."  Multiple Central Warehou
ICON_2 ICON_ADD_SHOPPINGCART          '@Y7@'."  Multiple Central Warehou
ICON_2 ICON_REMOVE_SHOPPINGCART       '@Y8@'."  Multiple Central Warehou
ICON_2 ICON_DELETE_SHOPPINGCART       '@Y9@'."  Multiple Central Warehou
ICON_2 ICON_ALV_COLLAPSE              '@YA@'."  Multiple Central Warehou
ICON_2 ICON_ALV_EXPAND                '@YB@'."  Multiple Central Warehou

* bugfix for wrong usage of ICON_BW_SUGGEST_VALUE
ICON_2 ICON_SUGGEST_VALUE             '@F6@'."  Stop

*--- INCLUDE: >ICON< ---*
***INCLUDE >ICON< .
*** INCLUDE for INCLUDE <ICON>, Definition of Icons                  ***

* Icon length 2
DEFINE ICON_2.
CONSTANTS:   &1 TYPE ICON_L2 VALUE  &2.
END-OF-DEFINITION.

* Icon length 4
DEFINE ICON_4.
CONSTANTS:   &1 TYPE ICON_L4 VALUE  &2.
END-OF-DEFINITION.


DEFINE ICON_PREPARE_FOR_MODIFY.
* trunkate ICON_ID, e.g.  '@3M@' --> '3M'
  TRANSLATE &1 USING '@ '.
  CONDENSE  &1 NO-GAPS.
END-OF-DEFINITION.






*--- INCLUDE: %_CIHTTP ---*
TYPE-POOL ihttp .


*------------------------------------------------------------------
* table of registered handler class instances
*------------------------------------------------------------------
TYPES:
        BEGIN OF ihttp_ext_instance,
          extension  TYPE seoclsname,
          refpointer TYPE REF TO if_http_extension,
          url        TYPE string,
        END   OF ihttp_ext_instance.

TYPES:
       ihttp_ext_instances TYPE STANDARD TABLE OF ihttp_ext_instance
                             WITH KEY url.

" http client instances
TYPES:
        BEGIN OF ihttp_client_instance,
          name            TYPE string,
          client          TYPE REF TO cl_abap_weak_reference,
          state           TYPE i,
          path_translated TYPE string, "established for MI application view and debugger (in CL_MI_SEMANTIC_TREE_ICF)
        END   OF ihttp_client_instance.

TYPES:
        ihttp_client_instances TYPE STANDARD TABLE OF
                                  ihttp_client_instance WITH KEY name.

* --
* administration of server objects in case of
* local calls (CREATE_INTERNAL) and in HTTP_DISPATCH_REQUEST
* --
TYPES: BEGIN OF ihttp_local_server_instance,
         client_name   TYPE string,
         server        TYPE REF TO if_http_server,
       END OF ihttp_local_server_instance.

TYPES:
        ihttp_local_server_instances TYPE STANDARD TABLE OF
                      ihttp_local_server_instance WITH KEY client_name.

*
* -- ICF recorder exchange (upload/download) types
*
TYPES:
        BEGIN OF ihttp_recorder_action,
          client       TYPE symandt,
          user         TYPE syuname,
          action       TYPE i,
          time_stamp   TYPE timestampl,
        END OF ihttp_recorder_action.

TYPES: ihttp_recorder_actions
          TYPE STANDARD TABLE OF ihttp_recorder_action.

TYPES:
        BEGIN OF ihttp_recorder_attribute,
           type      TYPE i,
           version   TYPE i,
           entry     TYPE xstring,
        END OF ihttp_recorder_attribute.

TYPES: ihttp_recorder_attributes
           TYPE TABLE OF ihttp_recorder_attribute WITH KEY type.

* -- for recorder logon procedure (based on user/password or rfc ticket)
TYPES:
        BEGIN OF ihttp_recorder_logon,
          version        TYPE i,
          logon_client   TYPE symandt,
          logon_username TYPE syuname,
          logon_password TYPE string,
          logon_language TYPE sylangu,
          logon_ticket   TYPE xstring,
        END OF ihttp_recorder_logon.

CONSTANTS:
        ihttp_recorder_x_entry_size  TYPE i VALUE 500.

TYPES:
        BEGIN OF ihttp_recorder_x,
            entry(ihttp_recorder_x_entry_size)   TYPE x,
        END   OF ihttp_recorder_x,

        ihttp_recorder_x_version(1)              TYPE x.

* -- ICF Recorder runtime info
TYPES:
        BEGIN OF ihttp_recorder_field,
          range  TYPE i,
          index  TYPE i,
          name   TYPE string,
          value  TYPE string,
        END OF ihttp_recorder_field.

TYPES: ihttp_recorder_fields
            TYPE TABLE OF ihttp_recorder_field WITH KEY range.

TYPES:
* for CL_HTTP_RESPONSE (SET_COMPRESSION)
        BEGIN OF ihttp_icfparameter,
           compression_supported TYPE i,
           protocol        TYPE string,
           accept_encoding TYPE string,
        END OF ihttp_icfparameter.

* -- cache for ICF runtime
TYPES:
        BEGIN OF ihttp_rmemory_icfhandlst,
          icfhandlst               TYPE icfhandlst,
          header_fields            TYPE tihttpnvp,
          script_name              TYPE string,
          path_info                TYPE string,
        END OF ihttp_rmemory_icfhandlst,

        BEGIN OF ihttp_runtime_memory,
          version  TYPE i,
          host     TYPE i,
          path     TYPE string,
          servtbl  TYPE TABLE OF ihttp_rmemory_icfhandlst
                                  WITH KEY script_name,
          actlogin TYPE icflogin,
          urlsuffix TYPE string,
        END OF ihttp_runtime_memory.

* send last page IF_HTTP_SERVER
TYPES:
       BEGIN OF ihttp_service_page,
         kind       TYPE c,
         header     TYPE sotr_conc,
         body       TYPE sotr_conc,
         redirect   TYPE string,
         redirect_code TYPE i,
       END OF ihttp_service_page.
*
* mapping of options/extensions for ICF service from application aoutput
* string into generic service string "container"
*
TYPES:
        BEGIN OF ihttp_icfservice_extension,
          kind       TYPE i,
          version    TYPE i,
          content    TYPE string,
        END OF ihttp_icfservice_extension.
TYPES:
        ihttp_icfservice_extensions TYPE STANDARD TABLE OF
                  ihttp_icfservice_extension WITH KEY kind.
*
* mapping of authentication code to the name of the authentication method
*
TYPES:
        BEGIN OF ihttp_authmethod_identifier,
          code TYPE i,
          name TYPE string,
        END OF ihttp_authmethod_identifier.
TYPES:
        ihttp_authmethod_mapping TYPE TABLE OF ihttp_authmethod_identifier
          WITH KEY code.

*------------------------------------------------------------------
* constants
*------------------------------------------------------------------

* ICF virtual host number
CONSTANTS:
  ihttp_vhost_default             TYPE i VALUE 0.

* authorization types
CONSTANTS:
  ihttp_auth_type_basic_auth      TYPE i VALUE 1.

* authorization types
CONSTANTS:
  ihttp_user_agent_unknown       TYPE i VALUE -1, " ?
  ihttp_user_agent_null          TYPE i VALUE 0,  " ?
  ihttp_user_agent_nn            TYPE i VALUE 1,  " netscape navigator
  ihttp_user_agent_ie            TYPE i VALUE 2,  " ms internet explorer
  ihttp_user_agent_sapwebapp     TYPE i VALUE 3,
  ihttp_user_agent_opera         TYPE i VALUE 4,
  ihttp_user_agent_mozilla       TYPE i VALUE 5,
  ihttp_user_agent_mz            TYPE i VALUE 5,
  ihttp_user_agent_safari        TYPE i VALUE 6.

* cache invalidation modes
CONSTANTS:
  ihttp_inv_literal              TYPE i VALUE 0,
  ihttp_inv_wildcard             TYPE i VALUE 1,
  ihttp_inv_etag                 TYPE i VALUE 2.


* cache invalidation scope
CONSTANTS:
  ihttp_inv_local                TYPE i VALUE 0,
  ihttp_inv_global               TYPE i VALUE 1.

* use virtual host index fron request to determine the cache
CONSTANTS:
  ihttp_vhost_fromreq            TYPE i value -1.

* encoding types (cl_http_utility=>string_to_fields etc.)
CONSTANTS:
  ihttp_enc_none                 TYPE i VALUE 0,
  ihttp_enc_base64               TYPE i VALUE 1,
  ihttp_enc_url64                TYPE i VALUE 5.


*
* system-call IDs: keep in sync with krn/ict/ictxxabap.c !!!
*
CONSTANTS:
  ihttp_scid_get_status               TYPE i VALUE  1,
  ihttp_scid_set_status               TYPE i VALUE  2,
  ihttp_scid_add_multipart            TYPE i VALUE  3,
  ihttp_scid_append_cdata             TYPE i VALUE  4,
  ihttp_scid_append_data              TYPE i VALUE  5,
  ihttp_scid_get_cdata                TYPE i VALUE  6,
  ihttp_scid_get_cookie               TYPE i VALUE  7,
  ihttp_scid_get_data                 TYPE i VALUE  8,
  ihttp_scid_get_form_field           TYPE i VALUE  9,
  ihttp_scid_get_form_fields          TYPE i VALUE 10,
  ihttp_scid_get_header_field         TYPE i VALUE 11,
  ihttp_scid_get_header_fields        TYPE i VALUE 12,
  ihttp_scid_get_multipart            TYPE i VALUE 13,
  ihttp_scid_instantiate              TYPE i VALUE 14,
  ihttp_scid_num_multiparts           TYPE i VALUE 15,
  ihttp_scid_serialize                TYPE i VALUE 16,
  ihttp_scid_set_cdata                TYPE i VALUE 17,
  ihttp_scid_add_cookie               TYPE i VALUE 18,
  ihttp_scid_set_data                 TYPE i VALUE 19,
  ihttp_scid_add_form_field           TYPE i VALUE 20,
  ihttp_scid_add_form_fields          TYPE i VALUE 21,
  ihttp_scid_add_header_field         TYPE i VALUE 22,
  ihttp_scid_add_header_fields        TYPE i VALUE 23,
  ihttp_scid_create_message           TYPE i VALUE 24,
  ihttp_scid_delete_message           TYPE i VALUE 25,
  ihttp_scid_remove_header_field      TYPE i VALUE 26,
  ihttp_scid_remove_cookie            TYPE i VALUE 27,
  ihttp_scid_get_message_data         TYPE i VALUE 28,
  ihttp_scid_get_cookie_field         TYPE i VALUE 30,
  ihttp_scid_add_cookie_field         TYPE i VALUE 31,
  ihttp_scid_remove_form_field        TYPE i VALUE 32,
  ihttp_scid_get_authorization        TYPE i VALUE 33,
  ihttp_scid_url_escape               TYPE i VALUE 34,
  ihttp_scid_url_unescape             TYPE i VALUE 35,
  ihttp_scid_html_escape              TYPE i VALUE 36,
  ihttp_scid_base64_escape            TYPE i VALUE 37,
  ihttp_scid_base64_unescape          TYPE i VALUE 38,
  ihttp_scid_set_authorization        TYPE i VALUE 39,
  ihttp_scid_str_to_field_list        TYPE i VALUE 40,
  ihttp_scid_field_list_to_str        TYPE i VALUE 41,
  ihttp_scid_get_user_agent           TYPE i VALUE 46,
  ihttp_scid_get_cookies              TYPE i VALUE 48,
  ihttp_scid_get_uri_parameter        TYPE i VALUE 49,
  ihttp_scid_append_cdata2            TYPE i VALUE 50,
  ihttp_scid_get_form_field_cs        TYPE i VALUE 51,
  ihttp_scid_get_form_fields_cs       TYPE i VALUE 53,
  ihttp_scid_compress_data            TYPE i VALUE 54,
  ihttp_scid_compress_supported       TYPE i VALUE 56,
  ihttp_scid_get_proto_version        TYPE i VALUE 57,
  ihttp_scid_del_hfield_secure        TYPE i VALUE 60,
  ihttp_scid_del_cookie_secure        TYPE i VALUE 61,
  ihttp_scid_del_ffield_secure        TYPE i VALUE 62,
  ihttp_scid_suppr_content_type       TYPE i VALUE 63,
  ihttp_scid_call_is_implemented      TYPE i VALUE 64,
  ihttp_scid_copy_message             TYPE i VALUE 65,
  ihttp_scid_get_request_method       TYPE i VALUE 66,
  ihttp_scid_get_message_length       TYPE i VALUE 67,
  ihttp_scid_get_content_type         TYPE i VALUE 68,
  ihttp_scid_set_proto_version        TYPE i VALUE 69,
  ihttp_scid_set_request_method       TYPE i VALUE 70,
  ihttp_scid_set_content_type         TYPE i VALUE 72,
  ihttp_scid_get_serialized_leng      TYPE i VALUE 73,
  ihttp_scid_http_redirect            TYPE i VALUE 74,
  ihttp_scid_get_data2                TYPE i VALUE 76,
  ihttp_scid_get_data_length          TYPE i VALUE 77,
  ihttp_scid_url_escape_2             TYPE i VALUE 78,
  ihttp_scid_url_unescape_2           TYPE i VALUE 79,
  ihttp_scid_html_escape2             TYPE i VALUE 80,
  ihttp_scid_crc32_checksum           TYPE i VALUE 81,
  ihttp_scid_set_request_message      TYPE i VALUE 82,
  ihttp_scid_jscript_escape           TYPE i VALUE 83,
  ihttp_scid_url_normalize            TYPE i VALUE 84,
  ihttp_scid_check_uri                TYPE i VALUE 85,
  ihttp_scid_base64_escape_x          TYPE i VALUE 86,
  ihttp_scid_base64_unescape_x        TYPE i VALUE 87,
  ihttp_scid_get_form_field_2         TYPE i VALUE 90,
  ihttp_scid_get_form_fields_2        TYPE i VALUE 91,
  ihttp_scid_suppr_content_len        TYPE i VALUE 92,
  ihttp_scid_url_path_escape          TYPE i VALUE 93,
  ihttp_scid_xmlhtml_escape_xss       TYPE i VALUE 94,
  ihttp_scid_jscript_escape_xss       TYPE i VALUE 95,
  ihttp_scid_url_escape_xss           TYPE i VALUE 96,
  ihttp_scid_css_escape_xss           TYPE i VALUE 97,
  ihttp_scid_instname_encode          TYPE i VALUE 98,
  ihttp_scid_serialize_with_opt       TYPE i VALUE 99,
  ihttp_scid_str_to_cookie_hash       TYPE i VALUE 100,
  ihttp_scid_suppr_charset            TYPE i VALUE 101,
  ihttp_scid_suppr_f_fields_body      TYPE i VALUE 102,
  ihttp_scid_preserve_mp_boundry      TYPE i VALUE 103,
  ihttp_scid_get_serversentevent      TYPE i VALUE 104.
*
* return code for non-existing (ICT_ENOTIMPL) syscalls
*
CONSTANTS:
  ihttp_syscall_not_implemented       TYPE i VALUE 4.

* option for IF_HTTP_UTILITY~ESCAPE_HTML parameter KEEP_NUM_CHAR_REF
* if set, HTML numeric character references are not escaped.
* if HTML_ESCAPE_ATTRIBUTE the character = is also escaped.
* The option JSCRIPT_ESCAPE_IN_HTML is for IF_HTTP_UTILITY~ESCAPE_JAVASCRIPT
CONSTANTS:
  ihttp_keep_num_char_ref             TYPE i VALUE 1,
  ihttp_html_escape_attribute         TYPE i VALUE 2,
  ihttp_jscript_escape_in_html        TYPE i VALUE 4.

* options for serialize (not exposed to application)
* see krn/ict/ictxxabap.c for details
CONSTANTS:
  ihttp_serialize_tilde_fld           TYPE i VALUE 1,
  ihttp_serialize_hide_sensitive      TYPE i VALUE 2,
  ihttp_serialize_header_only         TYPE i VALUE 4.

* -- icf recorder constants

CONSTANTS: ihttp_c_timezone_utc         TYPE tznzone VALUE IS INITIAL.

CONSTANTS:
  ihttp_start_modify_record             TYPE i VALUE 1, " enqueue step
  ihttp_cont_modify_record              TYPE i VALUE 2, " continue modi.
  ihttp_canc_modify_record              TYPE i VALUE 3, " cancel modi.
  ihttp_end_modify_record               TYPE i VALUE 4, " dequeue step
  ihttp_show_record                     TYPE i VALUE 5,
  ihttp_show_failed_logon_record        TYPE i VALUE 6,
  ihttp_delete_record                   TYPE i VALUE 7,
  ihttp_execute_record_request          TYPE i VALUE 8,
  ihttp_execute_record_request_o        TYPE i VALUE 9, "origin exec.
  ihttp_execute_record_request_l        TYPE i VALUE 10,"local exec.
  ihttp_download_record                 TYPE i VALUE 11,
  ihttp_upload_record                   TYPE i VALUE 12,
  ihttp_activate_protocol_action        TYPE i VALUE 13,
  ihttp_copy_record                     TYPE i VALUE 14,
  ihttp_delete_recorder_client          TYPE i VALUE 15,
  ihttp_start_admin_record              TYPE i VALUE 16, " enqueue step
  ihttp_cont_admin_record               TYPE i VALUE 17, " continue modi
  ihttp_canc_admin_record               TYPE i VALUE 18, " cancel modi.
  ihttp_end_admin_record                TYPE i VALUE 19, " dequeue step
  ihttp_show_protocol_record            TYPE i VALUE 20. " dequeue step


CONSTANTS:
   ihttp_recorder_attrib_version     TYPE  i VALUE 1,
   ihttp_recorder_attrib_action      TYPE  i VALUE 2,
   ihttp_recorder_attrib_logon       TYPE  i VALUE 3,
   ihttp_recorder_attrib_fields      TYPE  i VALUE 4.

* -- recorder level for ICF server
CONSTANTS:
   ihttp_record_playback              TYPE  i VALUE -100,
   ihttp_record_failed_auth           TYPE  i VALUE 1,
   ihttp_record_request_status        TYPE  i VALUE 2,
   ihttp_record_request               TYPE  i VALUE 3,
   ihttp_record_response_status       TYPE  i VALUE 4,
   ihttp_record_response              TYPE  i VALUE 5,
   ihttp_record_last_possibility      TYPE  i VALUE 6,
   ihttp_record_with_cookie           TYPE  i VALUE 100.

* -- recorder level for ICF client
CONSTANTS:
   ihttp_record_crequest_status       TYPE  i VALUE 1,
   ihttp_record_crequest              TYPE  i VALUE 2,
   ihttp_record_cresponse_status      TYPE  i VALUE 3,
   ihttp_record_cresponse             TYPE  i VALUE 4,
   ihttp_record_clast_possibility     TYPE  i VALUE 5.

*constants:
*   ihttp_record_accept_cookie_id      type  i value -100,
*   ihttp_record_send_cookie_id        type  i value -200.

CONSTANTS:
* LOGON
   ihttp_recorder_status_logon      TYPE  icfstatus VALUE '1',
* DOWNLOAD
   ihttp_recorder_status_download   TYPE  icfstatus VALUE '2',
* UPLOAD
   ihttp_recorder_status_upload     TYPE  icfstatus VALUE '4',
* COPY
   ihttp_recorder_status_copy       TYPE  icfstatus VALUE '10'.

CONSTANTS:
   ihttp_recorder_client_oblig   TYPE  icfrecoder_lmethod VALUE '1',
   ihttp_recorder_client_hfield  TYPE  icfrecoder_lmethod VALUE '2',
   ihttp_recorder_client_ffield  TYPE  icfrecoder_lmethod VALUE '3',
   ihttp_recorder_client_context TYPE  icfrecoder_lmethod VALUE '4',
   ihttp_recorder_client_service TYPE  icfrecoder_lmethod VALUE '5',
   ihttp_recorder_client_server  TYPE  icfrecoder_lmethod VALUE '6'.

CONSTANTS:
   ihttp_recorder_langu_oblig   TYPE  icfrecoder_lmethod VALUE '1',
   ihttp_recorder_langu_hfield  TYPE  icfrecoder_lmethod VALUE '2',
   ihttp_recorder_langu_ffield  TYPE  icfrecoder_lmethod VALUE '3',
   ihttp_recorder_langu_context TYPE  icfrecoder_lmethod VALUE '4',
   ihttp_recorder_langu_service TYPE  icfrecoder_lmethod VALUE '5',
   ihttp_recorder_langu_server  TYPE  icfrecoder_lmethod VALUE '6',
   ihttp_recorder_langu_accept  TYPE  icfrecoder_lmethod VALUE '7',
   ihttp_recorder_langu_slogin  TYPE  icfrecoder_lmethod VALUE '8'.


CONSTANTS:
   ihttp_recorder_user_oblig   TYPE  c VALUE '1',
   ihttp_recorder_user_hfield  TYPE  c VALUE '2',
   ihttp_recorder_user_ffield  TYPE  c VALUE '3',
   ihttp_recorder_user_service TYPE  c VALUE '4',
   ihttp_recorder_user_bauth   TYPE  c VALUE '5',
   ihttp_recorder_auser_hfield TYPE  c VALUE '6',
   ihttp_recorder_auser_ffield TYPE  c VALUE '7',
   ihttp_recorder_auser_bauth  TYPE  c VALUE '8'.

CONSTANTS:
   ihttp_recorder_passwd_oblig   TYPE  c VALUE '1',
   ihttp_recorder_passwd_hfield  TYPE  c VALUE '2',
   ihttp_recorder_passwd_ffield  TYPE  c VALUE '3',
   ihttp_recorder_passwd_service TYPE  c VALUE '4',
   ihttp_recorder_passwd_bauth   TYPE  c VALUE '5'.

CONSTANTS:
   ihttp_recorder_bauth_ticket  TYPE c VALUE '1',
   ihttp_recorder_sso_ticket    TYPE c VALUE '2',
   ihttp_recorder_ssorej_ticket TYPE c VALUE '3',
   ihttp_recorder_r3auth_ticket TYPE c VALUE '4',
   ihttp_recorder_x509_ticket   TYPE c VALUE '5',
   ihttp_recorder_saml_ticket   TYPE c VALUE '6',
   ihttp_recorder_oauth2_ticket TYPE c VALUE '7',
   ihttp_recorder_spnego_ticket TYPE c VALUE '8'.

CONSTANTS:
   ihttp_recorder_break_token   TYPE icfchar4 VALUE '=',
   ihttp_recorder_tickets_token TYPE icfchar4 VALUE '-T:',
   ihttp_recorder_auth_token    TYPE icfchar4 VALUE '-a:',
   ihttp_recorder_user_token    TYPE icfchar4 VALUE '-u:',
   ihttp_recorder_users_token   TYPE icfchar4 VALUE '-U:',
   ihttp_recorder_passwds_token TYPE icfchar4 VALUE '-P:',
   ihttp_recorder_client_token  TYPE icfchar4 VALUE '-c:',
   ihttp_recorder_clients_token TYPE icfchar4 VALUE '-C:',
   ihttp_recorder_langu_token   TYPE icfchar4 VALUE '-l:',
   ihttp_recorder_langus_token  TYPE icfchar4 VALUE '-L:',
   ihttp_recorder_subrc_token   TYPE icfchar4 VALUE '-r:',
   ihttp_recorder_saprc_token   TYPE icfchar4 VALUE '-R:'.

CONSTANTS:
* -- E: for upload/download messages
   ihttp_recorder_ext_message_e  TYPE icfexternal_message VALUE 'E'.

CONSTANTS:
   ihttp_recorder_message_type_i  TYPE icfmsgtype VALUE 'I',
   ihttp_recorder_exp_mstype      TYPE icfmsgtype VALUE 'A'.

CONSTANTS:
   ihttp_recorder_exp_mandt TYPE symandt         VALUE '000',
   ihttp_recorder_exp_msgid TYPE icfrecoder_uuid VALUE 'FFFF',
   ihttp_icf_admin_msgid    TYPE icfrecoder_uuid VALUE 'AAAA'.

CONSTANTS:
  ihttp_recorder_role_sextern     TYPE char2 VALUE 'SE',
  ihttp_recorder_role_slocal      TYPE char2 VALUE 'SL',
  ihttp_recorder_role_cextern     TYPE char2 VALUE 'CE',
  ihttp_recorder_role_clocal      TYPE char2 VALUE 'CL'.

CONSTANTS:
   ihttp_recorder_exp_date_basis TYPE sydatum VALUE '20010101',
   ihttp_recorder_def_exp_day    TYPE i VALUE 30, "-> ~ 1 Month
   ihttp_recorder_def_exp_time   TYPE syuzeit VALUE '000000'.

CONSTANTS:
   ihttp_recorder_protocol_http  TYPE c       VALUE '1',
   ihttp_recorder_protocol_https TYPE c       VALUE '2'.

* -- Taskhandler performance (perfinterval)
CONSTANTS: ihttp_opcode_open_interval     TYPE x VALUE 17,
           ihttp_opcode_close_interval    TYPE x VALUE 18.


*
* Header, Form and Cookie Fields used in ICF
*
CONSTANTS:
  ihttp_c_sap_recorder     TYPE string VALUE 'sap-recorder',
  ihttp_c_sap_recorder_sid TYPE string VALUE 'sap-recorder_sid',
  ihttp_c_sap_recorder_aut TYPE string VALUE 'sap-rauth'.

*
* Maximum number of recorder entries per user account
* Maximum number of failed logon entries per client
*
CONSTANTS:
  ihttp_recorder_max_usr_entries  TYPE i VALUE 100,
  ihttp_recorder_max_log_entries  TYPE i VALUE 500.

* icf service extension kindes
CONSTANTS:
  ihttp_icfservice_extension_its  TYPE i VALUE 1,
  ihttp_icfservice_extension_bsp  TYPE i VALUE 2,
  ihttp_icfservice_extension_sam  TYPE i VALUE 3. "saml logon procedure


CONSTANTS:
  ihttp_icfservice_action_pack    TYPE i VALUE 1,
  ihttp_icfservice_action_unpack  TYPE i VALUE 2.

CONSTANTS:
  ihttp_recorder_field_range_loc   TYPE i VALUE 1, "locale information
  ihttp_recorder_field_range_exe   TYPE i VALUE 2, "execute_request
  ihttp_recorder_field_range_cck   TYPE i VALUE 3, "client cookie
  ihttp_recorder_field_range_clo   TYPE i VALUE 4, "client logon popup
  ihttp_recorder_field_range_cre   TYPE i VALUE 5, "client redirect
  ihttp_recorder_field_range_col   TYPE i VALUE 6, "client obj. length
  ihttp_recorder_field_range_sol   TYPE i VALUE 7. "server obj. length

CONSTANTS:
  ihttp_recorder_field_name_ext   TYPE char32 VALUE 'IF_HTTP_EXTENSION',
  ihttp_recorder_field_name_ccoo  TYPE char32
                                  VALUE 'PROPERTYTYPE_ACCEPT_COOKIE'.

*
* /system-call IDs: keep in sync with krn/ict/ictxxabap.c !!!
*

*--- INCLUDE: CL_ABAP_WEAK_REFERENCE========CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_WEAK_REFERENCE and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: IF_HTTP_EXTENSION=============IT ---*

*--- INCLUDE: IF_HTTP_SERVER================IT ---*

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

*--- INCLUDE: %_CVRM ---*
TYPE-POOL VRM .

TYPES:
*-- Single Value in Value Set
       BEGIN OF VRM_VALUE,
         KEY(40) TYPE C,
         TEXT(80) TYPE C,
       END OF VRM_VALUE,
*-- Table of Values
       VRM_VALUES TYPE VRM_VALUE OCCURS 0,
*-- Id of Value Set
       VRM_ID TYPE VRM_VALUE-TEXT,
*-- table of Ids of Value Set
       VRM_IDS TYPE VRM_ID OCCURS 0,
*-- QueueRow
       BEGIN OF VRM_QUEUEROW,
         TAG,
         VALUE TYPE VRM_VALUE,
       END   OF VRM_QUEUEROW,
*-- Queue
       VRM_QUEUE TYPE VRM_QUEUEROW OCCURS 0.

CONSTANTS:
  VRM_TYPE(20)                          VALUE 'application',
  VRM_SUBTYPE(20)                       VALUE 'x-sapvaluesets',
  VRM_QUEUE_TAG_HEADER                  VALUE 'T',
  VRM_QUEUE_TAG_SUBHEADER               VALUE 'X',
  VRM_QUEUE_TAG_ENTRY                   VALUE ' ',
  VRM_QUEUE_KEY_TYPE TYPE VRM_VALUE-KEY VALUE 'TYPE',
  VRM_QUEUE_KEY_NAME TYPE VRM_VALUE-KEY VALUE 'NAME'.

*--- INCLUDE: CL_COMMUNICATION_TARGET_ROOT==CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_COMMUNICATION_TARGET_ROOT and it's users.
*"* touched if any type reference has been changed

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

*--- INCLUDE: CL_HTTP_CLIENT================CU ---*
class CL_HTTP_CLIENT definition
  public
  create private

  global friends CL_APC_WSP_CLIENT
                 CL_APC_WS_CLIENT
                 CL_HTTP_REQUEST
                 CL_HTTP_RESPONSE
                 CL_WEB_HTTP_RESPONSE
                 CL_ICM_CONNECTION_TEST
                 CL_ICM_TESTING .

public section.
*"* public components of class CL_HTTP_CLIENT
*"* do not include other source files here!!!
  type-pools ABAP .

  interfaces IF_HTTP_CLIENT .

  aliases REQUEST
    for IF_HTTP_CLIENT~REQUEST .
  aliases RESPONSE
    for IF_HTTP_CLIENT~RESPONSE .
  aliases CREATE_ABS_URL
    for IF_HTTP_CLIENT~CREATE_ABS_URL .
  aliases CREATE_REL_URL
    for IF_HTTP_CLIENT~CREATE_REL_URL .
  aliases ESCAPE_URL
    for IF_HTTP_CLIENT~ESCAPE_URL .

  constants SCHEMETYPE_HTTPS type I value 2 ##NO_TEXT.
  constants SCHEMETYPE_HTTP type I value 1 ##NO_TEXT.
  constants CO_REDIRECT_TRIAL type I value 5 ##NO_TEXT.
  constants CO_AUTHENTICATE_TRIAL type I value 3 ##NO_TEXT.
  class-data C_COMPRESSION_SUPPORTED type I read-only .
  constants HTTP_NO_OPEN_CONNECTION_ERROR type SYSUBRC value 1002 ##NO_TEXT.
  constants HTTP_PROCESSING_FAILED_ERROR type SYSUBRC value 1003 ##NO_TEXT.
  constants HTTP_INVALID_STATE_ERROR type SYSUBRC value 1001 ##NO_TEXT.
  data M_PATH_PREFIX type STRING read-only .
  data M_USE_SCC type SAP_BOOL read-only value ABAP_FALSE ##NO_TEXT.
  class-data M_CONNECTION type SYSUUID_C read-only .
  data M_COUNTER type I read-only .

  class-methods GET_CLIENT_KERNEL_VERSION
    returning
      value(VERSION) type I .
  class-methods CLASS_CONSTRUCTOR .
  class-methods _APPEND_XSTRING_TO_STRING
    importing
      !SOURCE type XSTRING
    changing
      !DEST type STRING .
  class-methods _APPEND_STRING_TO_XSTRING
    importing
      !SOURCE type STRING
    changing
      !DEST type XSTRING .
  methods CONSTRUCTOR
    exceptions
      CREATE_MESSAGE_FAILED .
  class-methods CREATE_BY_CLOUD_DESTINATION
    importing
      !I_NAME type CHAR38
      !I_COMM_ARR_UUID type UUID optional
      !I_SERVICE_INSTANCE_NAME type SVC_INSTANCE_NAME optional
    returning
      value(CLIENT) type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      DESTINATION_NOT_FOUND
      DESTINATION_NO_AUTHORITY
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR .
  class-methods CREATE_BY_DESTINATION
    importing
      !DESTINATION type C
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      DESTINATION_NOT_FOUND
      DESTINATION_NO_AUTHORITY
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR
      OA2C_SET_TOKEN_ERROR
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_CONFIG
      OA2C_INVALID_PARAMETERS
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT
      OA2C_SECSTORE_ADM .
  class-methods CREATE_INTERNAL
    importing
      !VIRTUAL_HOST type I default IHTTP_VHOST_DEFAULT
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR .
  class-methods CREATE_BY_URL
    importing
      !URL type STRING
      !PROXY_HOST type STRING optional
      !PROXY_SERVICE type STRING optional
      !SSL_ID type SSFAPPLSSL optional
      !SAP_USERNAME type SYUNAME optional
      !SAP_CLIENT type SYMANDT optional
      !PROXY_USER type STRING optional
      !PROXY_PASSWD type STRING optional
      !DO_NOT_USE_CLIENT_CERT type ABAP_BOOL default ABAP_FALSE
      !USE_SCC type ABAP_BOOL default ABAP_FALSE
      !SCC_LOCATION_ID type STRING optional
      !OAUTH_PROFILE type OA2C_PROFILE optional
      !OAUTH_CONFIG type OA2C_CONFIGURATION optional
      !SSL_HOSTNAME type STRING optional
      !SSL_CIPHER_SUITES type STRING optional
      !SSL_SNI_DISABLED type ABAP_BOOL default ABAP_FALSE
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR
      PSE_NOT_FOUND
      PSE_NOT_DISTRIB
      PSE_ERRORS
      OA2C_SET_TOKEN_ERROR
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_CONFIG
      OA2C_INVALID_PARAMETERS
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT .
  class-methods CREATE
    importing
      !HOST type STRING
      value(SERVICE) type STRING optional
      !PROXY_HOST type STRING optional
      !PROXY_SERVICE type STRING optional
      !SCHEME type I default SCHEMETYPE_HTTP
      !SSL_ID type SSFAPPLSSL optional
      !SAP_USERNAME type SYUNAME optional
      !SAP_CLIENT type SYMANDT optional
      !DO_NOT_USE_CLIENT_CERT type ABAP_BOOL default ABAP_FALSE
      !SSL_HOSTNAME type STRING optional
      !SSL_CIPHER_SUITES type STRING optional
      !SSL_SNI_DISABLED type ABAP_BOOL default ABAP_FALSE
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR .
  methods DESTRUCTOR .
  class-methods GET_LAST_ERROR
    exporting
      !CODE type SYSUBRC
      !MESSAGE type STRING .
  methods SEND_AND_CLOSE
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED
      HTTP_IS_NOT_SUPPORTED .
  class-methods SET_OAUTH_TOKEN
    importing
      !I_OAUTH_PROFILE type OA2C_PROFILE
      !I_OAUTH_CONFIG type OA2C_CONFIGURATION optional
      !IO_HTTP_CLIENT type ref to IF_HTTP_CLIENT
      !I_PARAM_KIND type STRING optional
      !I_FORCE_OAUTH2_REQUEST type ABAP_BOOL default ABAP_FALSE
    exceptions
      OA2C_SET_TOKEN_ERROR
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_CONFIG
      OA2C_INVALID_PARAMETERS
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT
      OA2C_SECSTORE_ADM .
  methods SET_OAUTH2C_INFO
    importing
      !IO_OA2C_CLIENT type ref to CL_OA2C_CLIENT
    returning
      value(R_RETURNCODE) type I .
  methods SET_OAUTH2C_INFO_EXT
    importing
      !IO_OA2C_CLIENT type ref to CL_OA2C_CLIENT
    returning
      value(R_RETURNCODE) type I .
  class-methods CREATE_BY_COM_TARGET
    importing
      !COMMUNICATION_TARGET type ref to CL_COMMUNICATION_TARGET_ROOT
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      INTERNAL_ERROR
      COM_TAR_NOT_FOUND
      COM_TAR_INVALID
      COM_TAR_READ_ERROR
      APPL_DEST_NOT_FOUND
      APPL_DEST_INACTIVE
      APPL_DEST_INVALID
      NO_DEFAULT_APPL_DEST_EXISTS
      DESTINATION_READ_ERROR
      INVALID_PROXY_PORT
      READING_SCCPROXY_FAILED
      PLUGIN_NOT_ACTIVE
      INVALID_PORT
      ERROR_CREATING_TICKET
      NO_AUTHORITY_FOR_SSLID_SPKI
      PSEFILE_NOT_FOUND
      OA2C_INVALID_CONFIG
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT
      OA2C_INVALID_PARAMETERS
      OA2C_SET_TOKEN_ERROR
      OA2C_SECSTORE_ADM .

*--- INCLUDE: CL_OA2C_CLIENT================CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_OA2C_CLIENT and it's users.
*"* touched if any type reference has been changed

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

*--- INCLUDE: IF_HTTP_CLIENT================IU ---*
*"* components of interface IF_HTTP_CLIENT
interface IF_HTTP_CLIENT
  public .


  constants VERSION type STRING value '1.0' ##NO_TEXT.
  data REQUEST type ref to IF_HTTP_REQUEST .
  data RESPONSE type ref to IF_HTTP_RESPONSE .
  data PROPERTYTYPE_LOGON_POPUP type I .
  constants CO_DISABLED type I value 0 ##NO_TEXT.
  constants CO_EVENT type I value 3 ##NO_TEXT.
  constants CO_PROMPT type I value 2 ##NO_TEXT.
  constants CO_ENABLED type I value 1 ##NO_TEXT.
  data PROPERTYTYPE_REDIRECT type I .
  data PROPERTYTYPE_APPLY_SPROXY type I .
  data PROPERTYTYPE_ACCEPT_COOKIE type I .
  data PROPERTYTYPE_SEND_W3C_TRACE type I .
  data PROPERTYTYPE_SEND_SAP_PASSPORT type I .
  constants CO_TIMEOUT_DEFAULT type I value 0 ##NO_TEXT.
  constants CO_TIMEOUT_INFINITE type I value -1 ##NO_TEXT.
  constants CO_COMPRESS_BASED_ON_MIME_TYPE type I value 2 ##NO_TEXT.
  constants CO_COMPRESS_IN_ALL_CASES type I value 1 ##NO_TEXT.
  constants CO_COMPRESS_NONE type I value 0 ##NO_TEXT.
  data PROPERTYTYPE_ACCEPT_COMPRESS type I .
  data PATH_PREFIX type STRING read-only .
  data OAUTH_LAST_ERR_TXT type STRING .

  events EVENTKIND_HANDLE_COOKIE
    exporting
      value(CLIENT) type ref to IF_HTTP_CLIENT optional
      value(COOKIES) type TIHTTPCKI optional .

  class-methods ESCAPE_HTML
    importing
      !UNESCAPED type STRING
    returning
      value(ESCAPED) type STRING .
  class-methods ESCAPE_URL
    importing
      !UNESCAPED type STRING
    returning
      value(ESCAPED) type STRING .
  class-methods UNESCAPE_URL
    importing
      !ESCAPED type STRING
    returning
      value(UNESCAPED) type STRING .
  class-methods LISTEN
    returning
      value(CLIENT) type ref to IF_HTTP_CLIENT
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_NO_OPEN_CONNECTION .
  methods AUTHENTICATE
    importing
      !PROXY_AUTHENTICATION type C default ' '
      !CLIENT type SYMANDT optional
      !USERNAME type STRING
      !PASSWORD type ICF_PASSWORD
      !LANGUAGE type SYLANGU optional .
  methods APPEND_FIELD_URL
    importing
      !NAME type STRING
      !VALUE type STRING
    changing
      !URL type STRING .
  methods CREATE_ABS_URL
    importing
      !PROTOCOL type STRING default ''
      !HOST type STRING default ''
      !PORT type STRING default ''
      !PATH type STRING default ''
      !QUERYSTRING type STRING default ''
      !STATEFUL type I default -1
    returning
      value(URL) type STRING .
  methods CREATE_REL_URL
    importing
      !PATH type STRING default ''
      !QUERYSTRING type STRING default ''
      !STATEFUL type I default -1
    returning
      value(URL) type STRING .
  methods CLOSE
    exceptions
      HTTP_INVALID_STATE .
  methods RECEIVE
    exporting
      !SSE_ENABLED type ABAP_BOOL
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED .
  methods RECEIVE_SSE_MSG default fail
    exporting
      !SSE_MSG type STRING
      !FINAL_MSG type ABAP_BOOL
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED .
  methods RECEIVE_SSE_BATCH default fail
    exporting
      !SSE_BATCH type STRING_TABLE
      !FINAL_BATCH type ABAP_BOOL
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED .
  methods GET_LAST_ERROR
    exporting
      !CODE type SYSUBRC
      !MESSAGE type STRING
      !MESSAGE_CLASS type ARBGB
      !MESSAGE_NUMBER type MSGNR .
  methods SEND
    importing
      !REQUEST_SSE type ABAP_BOOL default ABAP_FALSE
      !TIMEOUT type I default CO_TIMEOUT_DEFAULT
    preferred parameter TIMEOUT
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED
      HTTP_INVALID_TIMEOUT .
  methods REFRESH_COOKIE
    exceptions
      HTTP_ACTION_FAILED
      HTTP_PROCESSING_FAILED .
  methods REFRESH_REQUEST
    exceptions
      HTTP_ACTION_FAILED .
  methods REFRESH_RESPONSE
    exceptions
      HTTP_ACTION_FAILED .
  methods SET_COMPRESSION
    importing
      !OPTIONS type I default CO_COMPRESS_BASED_ON_MIME_TYPE
    exceptions
      COMPRESSION_NOT_POSSIBLE .
  methods SEND_SAP_LOGON_TICKET .
  methods SEND_SAP_ASSERTION_TICKET
    importing
      !CLIENT type SYMANDT
      !SYSTEM_ID type SYSYSID
    exceptions
      ARGUMENT_NOT_FOUND .
  methods IS_SCC_IN_USE default ignore
    returning
      value(IS_SCC_IN_USE) type ABAP_BOOLEAN .
  methods ENABLE_PATH_PREFIX .
endinterface.

*--- INCLUDE: IF_HTTP_ENTITY================IU ---*
*"* components of interface IF_HTTP_ENTITY
interface IF_HTTP_ENTITY
  public .


  constants CO_ENCODING_RAW type I value 0 ##NO_TEXT.
  constants CO_ENCODING_URL type I value 1 ##NO_TEXT.
  constants CO_ENCODING_HTML type I value 2 ##NO_TEXT.
  constants CO_ENCODING_WML type I value 3 ##NO_TEXT.
  constants CO_COMPRESS_NONE type I value 0 ##NO_TEXT.
  constants CO_COMPRESS_BASED_ON_MIME_TYPE type I value 2 ##NO_TEXT.
  constants CO_COMPRESS_IN_ALL_CASES type I value 1 ##NO_TEXT.
  constants CO_COMPRESS_DISABLED type I value 4 ##NO_TEXT.
  constants CO_PROTOCOL_VERSION_1_0 type I value 1000 ##NO_TEXT.
  constants CO_PROTOCOL_VERSION_1_1 type I value 1001 ##NO_TEXT.
  constants CO_REQUEST_METHOD_GET type STRING value 'GET' ##NO_TEXT.
  constants CO_REQUEST_METHOD_POST type STRING value 'POST' ##NO_TEXT.
  constants CO_COOKIE_ENCODING_RAW type I value 1 ##NO_TEXT.
  constants CO_COOKIE_ENCODING_URL_ENCODED type I value 0 ##NO_TEXT.
  constants CO_FORMFIELD_ENCODING_RAW type I value 1 ##NO_TEXT.
  constants CO_FORMFIELD_ENCODING_ENCODED type I value 2 ##NO_TEXT.
  constants CO_QUERY_STRING type I value 0 ##NO_TEXT.
  constants CO_BODY type I value 1 ##NO_TEXT.
  constants CO_QUERY_STRING_BEFORE_BODY type I value 2 ##NO_TEXT.
  constants CO_BODY_BEFORE_QUERY_STRING type I value 3 ##NO_TEXT.
  constants CO_CONTENT_CHECK_ALWAYS type HTTP_CONTENT_CHECK value 'A' ##NO_TEXT.
  constants CO_CONTENT_CHECK_NEVER type HTTP_CONTENT_CHECK value 'N' ##NO_TEXT.
  constants CO_CONTENT_CHECK_PROFILE type HTTP_CONTENT_CHECK value ' ' ##NO_TEXT.
  data FORMFIELD_ENCODING type I read-only .
  constants CO_DETAIL_INFO_LOGON_REQUIRED type STRING value 'ICFLOGONREQUIRED' ##NO_TEXT.
  constants CO_DETAIL_INFO_HOST_NOT_FOUND type STRING value 'ICFVIRTUALHOSTNOTFOUND' ##NO_TEXT.
  constants CO_DETAIL_INFO_TENANT_MAINT type STRING value 'ICMERUNLEVELINTERNAL' ##NO_TEXT.

  methods ADD_COOKIE_FIELD
    importing
      !COOKIE_NAME type STRING
      !COOKIE_PATH type STRING optional
      !FIELD_NAME type STRING
      !FIELD_VALUE type STRING
      !BASE64 type I default 1 .
  methods ADD_MULTIPART
    importing
      !SUPPRESS_CONTENT_LENGTH type ABAP_BOOL default ABAP_FALSE
    returning
      value(ENTITY) type ref to IF_HTTP_ENTITY .
  methods APPEND_CDATA
    importing
      !DATA type STRING
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods APPEND_CDATA2
    importing
      !DATA type STRING
      !ENCODING type I default CO_ENCODING_RAW
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods APPEND_DATA
    importing
      !DATA type XSTRING
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods DELETE_COOKIE_SECURE
    importing
      !NAME type STRING
      !PATH type STRING default `` .
  methods DELETE_COOKIE
    importing
      !NAME type STRING
      !PATH type STRING default `` .
  methods DELETE_FORM_FIELD_SECURE
    importing
      !NAME type STRING .
  methods DELETE_FORM_FIELD
    importing
      !NAME type STRING .
  methods DELETE_HEADER_FIELD_SECURE
    importing
      !NAME type STRING .
  methods DELETE_HEADER_FIELD
    importing
      !NAME type STRING .
  methods FROM_XSTRING
    importing
      !DATA type XSTRING .
  methods GET_CDATA
    returning
      value(DATA) type STRING .
  methods GET_COOKIE
    importing
      !NAME type STRING
      !PATH type STRING default ``
      !COOKIE_ENCODING type I default 0
    exporting
      !VALUE type STRING
      !DOMAIN type STRING
      !EXPIRES type STRING
      !SECURE type I .
  methods GET_COOKIES
    importing
      !COOKIE_ENCODING type I default 0
    changing
      !COOKIES type TIHTTPCKI .
  methods GET_COOKIE_FIELD
    importing
      !COOKIE_NAME type STRING
      !COOKIE_PATH type STRING optional
      !FIELD_NAME type STRING
      !BASE64 type I default 1
    returning
      value(FIELD_VALUE) type STRING .
  methods GET_DATA
    importing
      !OFFSET type I default 0
      !LENGTH type I default -1
      value(VIRUS_SCAN_PROFILE) type VSCAN_PROFILE default '/SIHTTP/HTTP_UPLOAD'
      !VSCAN_SCAN_ALWAYS type HTTP_CONTENT_CHECK default IF_HTTP_ENTITY=>CO_CONTENT_CHECK_PROFILE
    returning
      value(DATA) type XSTRING .
  methods GET_FORM_FIELD_CS
    importing
      !NAME type STRING
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    returning
      value(VALUE) type STRING .
  methods GET_FORM_FIELD
    importing
      !NAME type STRING
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    returning
      value(VALUE) type STRING .
  methods GET_FORM_FIELDS_CS
    importing
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    changing
      !FIELDS type TIHTTPNVP .
  methods GET_FORM_FIELDS
    importing
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    changing
      !FIELDS type TIHTTPNVP .
  methods GET_HEADER_FIELD
    importing
      !NAME type STRING
    returning
      value(VALUE) type STRING .
  methods GET_HEADER_FIELDS
    changing
      !FIELDS type TIHTTPNVP .
  methods GET_LAST_ERROR
    returning
      value(RC) type I .
  methods GET_MULTIPART
    importing
      !INDEX type I
    returning
      value(ENTITY) type ref to IF_HTTP_ENTITY .
  methods NUM_MULTIPARTS
    returning
      value(NUM) type I .
  methods SET_CDATA
    importing
      !DATA type STRING
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods SET_COOKIE
    importing
      !NAME type STRING
      !PATH type STRING default ``
      !VALUE type STRING
      !DOMAIN type STRING default ``
      !EXPIRES type STRING default ``
      !SECURE type I default 0
      !COOKIE_ENCODING type I default 0 .
  methods SET_DATA
    importing
      !DATA type XSTRING
      !OFFSET type I default 0
      !LENGTH type I default -1
      !VSCAN_SCAN_ALWAYS type HTTP_CONTENT_CHECK default IF_HTTP_ENTITY=>CO_CONTENT_CHECK_PROFILE
      value(VIRUS_SCAN_PROFILE) type VSCAN_PROFILE default '/SIHTTP/HTTP_DOWNLOAD' .
  methods SET_FORM_FIELD
    importing
      !NAME type STRING
      !VALUE type STRING .
  methods SET_FORM_FIELDS
    importing
      !FIELDS type TIHTTPNVP
      !MULTIVALUE type INT4 default 0 .
  methods SET_HEADER_FIELD
    importing
      !NAME type STRING
      !VALUE type STRING .
  methods SET_HEADER_FIELDS
    importing
      !FIELDS type TIHTTPNVP .
  methods TO_XSTRING
    returning
      value(DATA) type XSTRING .
  methods SET_COMPRESSION
    importing
      !DISABLE_EXTENDED_CHECKS type ABAP_BOOL default ABAP_FALSE
      !OPTIONS type I default CO_COMPRESS_BASED_ON_MIME_TYPE
    preferred parameter OPTIONS .
  methods SET_CONTENT_TYPE
    importing
      !CONTENT_TYPE type STRING .
  methods GET_CONTENT_TYPE
    returning
      value(CONTENT_TYPE) type STRING .
  methods GET_VERSION
    returning
      value(VERSION) type I .
  methods GET_SERIALIZED_MESSAGE_LENGTH
    exporting
      value(BODY_LENGTH) type I
      value(HEADER_LENGTH) type I .
  methods SET_FORMFIELD_ENCODING
    importing
      !FORMFIELD_ENCODING type I .
  methods SUPPRESS_CONTENT_TYPE
    importing
      !SUPPRESS type ABAP_BOOL default ABAP_TRUE .
  methods SUPPRESS_CHARSET default fail
    importing
      !SUPPRESS type ABAP_BOOL default ABAP_TRUE .
  methods GET_DATA_LENGTH
    exporting
      value(DATA_LENGTH) type I .
  methods PRESERVE_MULTIPART_BOUNDARY default fail
    importing
      !PRESERVE type ABAP_BOOL default ABAP_TRUE .
endinterface.

*--- INCLUDE: IF_HTTP_REQUEST===============IT ---*

*--- INCLUDE: IF_HTTP_RESPONSE==============IU ---*
*"* components of interface IF_HTTP_RESPONSE
interface IF_HTTP_RESPONSE
  public .


  interfaces IF_HTTP_ENTITY .

  aliases CO_COMPRESS_BASED_ON_MIME_TYPE
    for IF_HTTP_ENTITY~CO_COMPRESS_BASED_ON_MIME_TYPE .
  aliases CO_COMPRESS_DISABLED
    for IF_HTTP_ENTITY~CO_COMPRESS_DISABLED .
  aliases CO_COMPRESS_IN_ALL_CASES
    for IF_HTTP_ENTITY~CO_COMPRESS_IN_ALL_CASES .
  aliases CO_COMPRESS_NONE
    for IF_HTTP_ENTITY~CO_COMPRESS_NONE .
  aliases CO_ENCODING_HTML
    for IF_HTTP_ENTITY~CO_ENCODING_HTML .
  aliases CO_ENCODING_RAW
    for IF_HTTP_ENTITY~CO_ENCODING_RAW .
  aliases CO_ENCODING_URL
    for IF_HTTP_ENTITY~CO_ENCODING_URL .
  aliases CO_ENCODING_WML
    for IF_HTTP_ENTITY~CO_ENCODING_WML .
  aliases CO_FORMFIELD_ENCODING_ENCODED
    for IF_HTTP_ENTITY~CO_FORMFIELD_ENCODING_ENCODED .
  aliases CO_FORMFIELD_ENCODING_RAW
    for IF_HTTP_ENTITY~CO_FORMFIELD_ENCODING_RAW .
  aliases CO_PROTOCOL_VERSION_1_0
    for IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_0 .
  aliases CO_PROTOCOL_VERSION_1_1
    for IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_1 .
  aliases CO_REQUEST_METHOD_GET
    for IF_HTTP_ENTITY~CO_REQUEST_METHOD_GET .
  aliases CO_REQUEST_METHOD_POST
    for IF_HTTP_ENTITY~CO_REQUEST_METHOD_POST .
  aliases FORMFIELD_ENCODING
    for IF_HTTP_ENTITY~FORMFIELD_ENCODING .
  aliases ADD_COOKIE_FIELD
    for IF_HTTP_ENTITY~ADD_COOKIE_FIELD .
  aliases ADD_MULTIPART
    for IF_HTTP_ENTITY~ADD_MULTIPART .
  aliases APPEND_CDATA
    for IF_HTTP_ENTITY~APPEND_CDATA .
  aliases APPEND_CDATA2
    for IF_HTTP_ENTITY~APPEND_CDATA2 .
  aliases APPEND_DATA
    for IF_HTTP_ENTITY~APPEND_DATA .
  aliases DELETE_COOKIE
    for IF_HTTP_ENTITY~DELETE_COOKIE .
  aliases DELETE_COOKIE_SECURE
    for IF_HTTP_ENTITY~DELETE_COOKIE_SECURE .
  aliases DELETE_FORM_FIELD
    for IF_HTTP_ENTITY~DELETE_FORM_FIELD .
  aliases DELETE_FORM_FIELD_SECURE
    for IF_HTTP_ENTITY~DELETE_FORM_FIELD_SECURE .
  aliases DELETE_HEADER_FIELD
    for IF_HTTP_ENTITY~DELETE_HEADER_FIELD .
  aliases DELETE_HEADER_FIELD_SECURE
    for IF_HTTP_ENTITY~DELETE_HEADER_FIELD_SECURE .
  aliases FROM_XSTRING
    for IF_HTTP_ENTITY~FROM_XSTRING .
  aliases GET_CDATA
    for IF_HTTP_ENTITY~GET_CDATA .
  aliases GET_CONTENT_TYPE
    for IF_HTTP_ENTITY~GET_CONTENT_TYPE .
  aliases GET_COOKIE
    for IF_HTTP_ENTITY~GET_COOKIE .
  aliases GET_COOKIES
    for IF_HTTP_ENTITY~GET_COOKIES .
  aliases GET_COOKIE_FIELD
    for IF_HTTP_ENTITY~GET_COOKIE_FIELD .
  aliases GET_DATA
    for IF_HTTP_ENTITY~GET_DATA .
  aliases GET_FORM_FIELD
    for IF_HTTP_ENTITY~GET_FORM_FIELD .
  aliases GET_FORM_FIELDS
    for IF_HTTP_ENTITY~GET_FORM_FIELDS .
  aliases GET_FORM_FIELDS_CS
    for IF_HTTP_ENTITY~GET_FORM_FIELDS_CS .
  aliases GET_FORM_FIELD_CS
    for IF_HTTP_ENTITY~GET_FORM_FIELD_CS .
  aliases GET_HEADER_FIELD
    for IF_HTTP_ENTITY~GET_HEADER_FIELD .
  aliases GET_HEADER_FIELDS
    for IF_HTTP_ENTITY~GET_HEADER_FIELDS .
  aliases GET_LAST_ERROR
    for IF_HTTP_ENTITY~GET_LAST_ERROR .
  aliases GET_MULTIPART
    for IF_HTTP_ENTITY~GET_MULTIPART .
  aliases GET_SERIALIZED_MESSAGE_LENGTH
    for IF_HTTP_ENTITY~GET_SERIALIZED_MESSAGE_LENGTH .
  aliases GET_VERSION
    for IF_HTTP_ENTITY~GET_VERSION .
  aliases NUM_MULTIPARTS
    for IF_HTTP_ENTITY~NUM_MULTIPARTS .
  aliases SET_CDATA
    for IF_HTTP_ENTITY~SET_CDATA .
  aliases SET_COMPRESSION
    for IF_HTTP_ENTITY~SET_COMPRESSION .
  aliases SET_CONTENT_TYPE
    for IF_HTTP_ENTITY~SET_CONTENT_TYPE .
  aliases SET_COOKIE
    for IF_HTTP_ENTITY~SET_COOKIE .
  aliases SET_DATA
    for IF_HTTP_ENTITY~SET_DATA .
  aliases SET_FORMFIELD_ENCODING
    for IF_HTTP_ENTITY~SET_FORMFIELD_ENCODING .
  aliases SET_FORM_FIELD
    for IF_HTTP_ENTITY~SET_FORM_FIELD .
  aliases SET_FORM_FIELDS
    for IF_HTTP_ENTITY~SET_FORM_FIELDS .
  aliases SET_HEADER_FIELD
    for IF_HTTP_ENTITY~SET_HEADER_FIELD .
  aliases SET_HEADER_FIELDS
    for IF_HTTP_ENTITY~SET_HEADER_FIELDS .
  aliases SUPPRESS_CHARSET
    for IF_HTTP_ENTITY~SUPPRESS_CHARSET .
  aliases SUPPRESS_CONTENT_TYPE
    for IF_HTTP_ENTITY~SUPPRESS_CONTENT_TYPE .
  aliases TO_XSTRING
    for IF_HTTP_ENTITY~TO_XSTRING .

  methods DELETE_COOKIE_AT_CLIENT
    importing
      !NAME type STRING
      !PATH type STRING default ''
      !DOMAIN type STRING default '' .
  methods GET_STATUS
    exporting
      !CODE type I
      !REASON type STRING .
  methods REDIRECT
    importing
      !URL type STRING
      !PERMANENTLY type I default 0
      !EXPLANATION type STRING default ''
      !PROTOCOL_DEPENDENT type I default 0 .
  methods SERVER_CACHE_EXPIRE_ABS
    importing
      !EXPIRES_ABS_DATE type D optional
      !EXPIRES_ABS_TIME type T optional
      !ETAG type CHAR32 optional
      !BROWSER_DEPENDENT type BOOLEAN default ' '
      !NO_UFO_CACHE type BOOLEAN default ' ' .
  methods SERVER_CACHE_EXPIRE_DEFAULT
    importing
      !ETAG type CHAR32 optional
      !BROWSER_DEPENDENT type BOOLEAN default ' '
      !NO_UFO_CACHE type BOOLEAN default ' ' .
  methods SERVER_CACHE_EXPIRE_REL
    importing
      !EXPIRES_REL type I
      !ETAG type CHAR32 optional
      !BROWSER_DEPENDENT type BOOLEAN default ' '
      !NO_UFO_CACHE type BOOLEAN default ' ' .
  methods SET_STATUS
    importing
      !CODE type I
      !REASON type STRING
      !DETAILED_INFO type STRING optional .
  methods SERVER_CACHE_BROWSER_DEPENDENT
    importing
      !DEPENDENT type BOOLEAN default 'X' .
  methods GET_RAW_MESSAGE
    returning
      value(DATA) type XSTRING .
  methods COPY
    returning
      value(RESPONSE) type ref to IF_HTTP_RESPONSE .
endinterface.

*--- INCLUDE: MZMM_NONMOVF01 ---*
************************************************************************
*  Date            Transport      USERID        Description

************************************************************************

***INCLUDE MZMM_NONMOVF01 .
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
***     WHEN 'UPLOAD'.
***       PERFORM upload_from_textfile using p_tc_name
***                                          p_table_name
***                                          p_mark_name.
***
***       CLEAR P_OK.

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
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO           = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
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

   MOVE 'ZMMNMPRINT' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'HELP' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'ATTACH' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'DELATTACH' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'LIST' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'REPORT' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'UNBLOCK' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'CIRCULAR' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'RELEASE' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.

   IF g_mode =  'CHA'.
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
     MOVE 'SUBMIT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ELSEIF g_mode = 'DIS'.
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
     MOVE 'SUBMIT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

****   ELSEIF g_mode = 'REL'.
****     MOVE 'SAV' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'CREATE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'CHANGE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'DELETE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'DISPLAY' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'RELEASE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'APPROVE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'UNBLOCK' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'ATTACH' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'DELATTACH' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'REPORT' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'HELP' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.

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
     MOVE 'SUBMIT' TO wa_tab-fcode.
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
     MOVE 'SUBMIT' TO wa_tab-fcode.
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

   IF g_mode <> 'DIS'.

     DATA : l_get1(1) TYPE c.
     clear l_get1.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR              = 'BACK '
         TEXT_QUESTION         = 'Data will be lost, Want to quit? '
         DISPLAY_CANCEL_BUTTON = ' '
         START_COLUMN          = 25
         START_ROW             = 6
       IMPORTING
         ANSWER                = l_get1
       EXCEPTIONS
         TEXT_NOT_FOUND        = 1
         OTHERS                = 2.
     IF SY-SUBRC = 0.
       CASE l_get1.
         WHEN '1'.
           MOVE 'J' TO l_choice.
         WHEN '2'.
           MOVE 'N' TO l_choice.
       ENDCASE.
     ENDIF.

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
   CLEAR : NAME1.

   REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
   CLEAR: g_hd_copied,g_tct100_copied.
   CLEAR:  g_cors, g_errstat,G_ERRCD_M.

   REFRESH: tlinetab1,tlinetab2,lines_cors.
   REFRESH: lt_text_table1,lt_text_table2.

   clear: G_REQ_NO.
   FREE MEMORY ID 'ID_NMREQ'.
   clear FLAG_WF.
   FREE MEMORY ID 'ID_NMWF'.
*   FREE MEMORY ID 'ID_NMSTT'.
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
         id                      = 'MMNM'
         language                = sy-langu
         name                    = l_cors
         object                  = 'ZMMNM'
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
       readonly_mode          = gv_text_editor1->true
     EXCEPTIONS
       error_cntl_call_method = 1
       invalid_parameter      = 2
       OTHERS                 = 3.
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).

     CALL METHOD gv_text_editor2->set_readonly_mode
       EXPORTING
         readonly_mode          = gv_text_editor2->false
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

*     IF ( g_line132+0(2) = '* ' ) OR
*        ( g_line132+0(2) = '**' ).
     IF  g_line132+2(2) = '**'.
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
   IF ( g_mode = 'CRE' ) OR
      ( g_mode = 'CHA' ) OR
      ( sy-tcode = 'ZMMNMWF2' ) OR
      ( sy-tcode = 'ZMMNMWFL2' ) OR
      ( sy-tcode = 'ZMMNMWF3' ) OR
      ( sy-tcode = 'ZMMNMWF4' ).

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
   IF ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ) OR
      ( sy-tcode = 'ZMMNMWF2' ) OR
      ( sy-tcode = 'ZMMNMWFL2' ) OR
      ( sy-tcode = 'ZMMNMWF3' ) OR
      ( sy-tcode = 'ZMMNMWF4' ).

     CALL METHOD gv_text_editor1->free.
     CALL METHOD gv_text_editor2->free.
   ELSEIF ( g_mode = 'DIS' ) OR ( g_mode = 'DEL' ).
     CALL METHOD gv_text_editor1->free.
   ENDIF.
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
             WITH KEY MATCODE = ''.

       READ TABLE g_tct100_itab into l_tct100_wa
            WITH KEY srno = 0.
       IF sy-subrc = 0.
         MESSAGE w220(zmm_oth). "Pls press enter to populate detail data before saving.
         flag_dont_clear = 'X'.  "X : don't clear variables, take another loop thro' PBO
         EXIT.

       ENDIF.

       IF g_mode = 'CRE'.
         PERFORM gen_request.
         SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
       ENDIF.
     ELSE.
       MESSAGE i091(zmm_oth).
       flag_dont_clear = 'X'.  "X : don't clear variables, take another loop thro' PBO
       EXIT.
     ENDIF.
   ENDIF.
   IF g_mode = 'CRE'.
     zmm_nmblkcdhd_st-reqno = g_reqno.

     PERFORM insert_into_tab. " For Creator, Update Header & deatails


     MESSAGE i005(zmm_oth) WITH g_reqno.
     PERFORM clear_var.
     CLEAR ok_code100.

   ELSEIF g_mode = 'CHA'.
     g_request_no = zmm_nmblkcdhd_st-reqno .
     PERFORM remove_deleted_items.

** Release from creator
     if G_REL_FLAG = 'X'.  " SAVE with Release by ceator to L3l4

       perform validate_reqno.
       perform validate_before_rel_rej_rev.
       PERFORM insert_into_tab.  " For Creator, Update Header & deatails
       COMMIT WORK.
       perform submit_request.
       clear ok_code100.

     else .               " SAVE only by ceator
       PERFORM insert_into_tab.  " For Creator, Update Header & deatails
       COMMIT WORK.
       MESSAGE i006(zmm_oth) WITH g_request_no.
       PERFORM clear_var.
       CLEAR ok_code100.
     endif.

   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
     CLEAR ok_code100.

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
 form insert_into_tab.   " For Creator: Update Header & deatails
   DATA: l_blkhd LIKE zmm_nmblkcdhd.
   CLEAR : l_blkhd.
****Update Header *********
   IF g_mode = 'CRE'.

     zmm_nmblkcdhd_st-nm_status = 'NEW'.
     zmm_nmblkcdhd_st-DOC_DATE = sy-datum.

     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     INSERT  zmm_nmblkcdhd FROM l_blkhd.
   ELSEIF g_mode = 'CHA'.
     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     MODIFY zmm_nmblkcdhd FROM l_blkhd.
   ENDIF.

****Update Details ************
   refresh itab_nmblkcddt.
   clear g_tct100_wa.
   LOOP AT g_tct100_itab INTO g_tct100_wa.
     MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
     MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.

*
**row status: Creator- If this is a reverted request and being released by the creator,  Update ROW STATUS as per the decision.
* Also validate: creator can choose only 'REJECT', 'REPLY'."Already ACCEPTed row will be read only.
     if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL and G_REL_FLAG = 'X'.

       IF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECT'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
         wa_nmblkcddt-STATUS = 'REPLY'.
*  ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
*     wa_nmblkcddt-STATUS = 'QUERY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
            or wa_nmblkcddt-DECISION = 'QUERY' .
         MESSAGE E231(zmm_oth).
       ENDIF.

     endif.

     append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.

   IF g_mode = 'CRE'.
     INSERT zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
   ELSE.
     MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
   ENDIF.

***Note Sheet
   IF ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ).

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
 form remove_deleted_items.
   DATA : l_del100 TYPE t_tct100.
* CLEAR g_item.
*   SELECT SINGLE * INTO g_item FROM zmm_nmblkcddt
*          WHERE reqno = zmm_nmblkcdhd_st-reqno.
**
   IF g_itab_del100[] IS  NOT  INITIAL.
     LOOP AT g_itab_del100 INTO l_del100.
       DELETE FROM zmm_nmblkcddt
         WHERE reqno = zmm_nmblkcdhd_st-reqno
         AND   srno  = l_del100-srno.
     ENDLOOP.
   ENDIF.
**


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

* deletion possible only when the request is NEW
* and sy-uname = requester.

     if zmm_nmblkcdhd_st-ID_CREATOR = sy-uname.
       if zmm_nmblkcdhd_st-NM_STATUS = 'NEW'.

         DELETE FROM zmm_nmblkcdhd
         WHERE reqno = zmm_nmblkcdhd_st-reqno.
         IF sy-subrc <> 0.
           MESSAGE e233(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
           EXIT.
         ENDIF.
*
         SELECT tdobject tdname tdid FROM stxl
          INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
          WHERE tdid = 'MMNM'.
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
         ELSE.
           MESSAGE e233(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
           EXIT.
         ENDIF.

        else.
          MESSAGE e235(zmm_oth).
       endif. "//zmm_nmblkcdhd_st-NM_STATUS = 'NEW'.
     else.
       MESSAGE e234(zmm_oth).
     endif. "// zmm_nmblkcdhd_st-ID_CREATOR = sy-uname.
     CLEAR g_choice.
   ENDIF.

 endform.                    " prepare_delete


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
   DATA: l_datech(20) TYPE c.
***********Assignments***********************
   CLEAR l_theader.
   l_theader-tdobject   = 'ZMMNM'.
   l_theader-tdid       = 'MMNM'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_nmblkcdhd_st-reqno INTO l_theader-tdname.

   IF tlinetab2[] IS NOT INITIAL.

* append date & time to previous communication
     CLEAR g_cores_sender.
     CONCATENATE sy-datum+6(2) '/'
                 sy-datum+4(2) '/'
                 sy-datum+0(4) '  '
                 sy-uzeit+0(2) ':'
                 sy-uzeit+2(2) ':'
                 sy-uzeit+4(2) INTO l_datech RESPECTING BLANKS.


     CONCATENATE '****' sy-uname l_datech INTO g_cores_sender
      SEPARATED BY '   '.

     APPEND g_cores_sender TO tlinetab1.
     CLEAR g_cores_sender.

* append current communication
     APPEND LINES OF tlinetab2 TO tlinetab1.

*append a blank line

     CONCATENATE '*    ' '  '  INTO g_cores_sender RESPECTING BLANKS.
     APPEND g_cores_sender TO tlinetab1.


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

** after saving, clear contents of tlinetab2
   clear tlinetab2.
   REFRESH tlinetab2.

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
   DATA : l_get2(1) TYPE c.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR              = 'DELETE '
       TEXT_QUESTION         = 'Data will be lost,No recovery possible,Are you sure ?'
       DISPLAY_CANCEL_BUTTON = ' '
       START_COLUMN          = 25
       START_ROW             = 6
     IMPORTING
       ANSWER                = l_get2
     EXCEPTIONS
       TEXT_NOT_FOUND        = 1
       OTHERS                = 2.
   IF SY-SUBRC = 0.
     CASE l_get2.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.

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

***********&---------------------------------------------------------------------*
***********&      Form  unblock_matcode
***********&---------------------------------------------------------------------*
***********       text
***********----------------------------------------------------------------------*
***********  -->  p1        text
***********  <--  p2        text
***********----------------------------------------------------------------------*
**************** form unblock_matcode.
****************   Data : l_unblk100 type t_tct100.
****************   Data : l_atwrt like ausp-atwrt,
****************          l_matnr like mara-matnr,
****************          l_atinn like ausp-atinn.
****************   Data : l_totlines type i,
****************          l_unblklines type i.
******************
****************   CLEAR   wa_nmblkcddt.
****************   REFRESH itab_nmblkcddt[].
******************
****************   clear g_mesg.
****************   READ TABLE g_tct100_itab into l_unblk100
****************        WITH KEY flag  = 'X'.
****************   IF sy-subrc <> 0.
****************     g_mesg = 'X'.
****************     MESSAGE i101(zmm_oth).
****************     EXIT.
****************   ENDIF.
******************
****************   PERFORM confirm_unblock.
****************   IF g_choice = 'J'.
*******************Updating classification view.
****************     LOOP AT g_tct100_itab into g_tct100_wa
****************          where flag  = 'X'
****************          and   errcd = ''.
****************       l_matnr = g_tct100_wa-matcode.
****************
****************
****************       update mara set ZZMBPR = ''
****************                       ZZNMFLG = ''
****************                   where matnr = l_matnr.
****************       if sy-subrc = 0.
****************
****************       endif.
****************
****************       SELECT SINGLE * FROM klah
****************                  WHERE klart  = '001'
****************                  AND   class  = 'Z_ONGC_BLOCK'.
****************       IF sy-subrc = 0.
****************         DELETE FROM KSSK
****************                where objek = l_matnr
****************                AND   clint = klah-clint
****************                AND   klart = '001'.
****************       ENDIF.
******************
****************       SELECT SINGLE atinn INTO l_atinn
****************                           FROM   cabn
****************                           WHERE  atnam = 'Z_ONGC_REASON'.
****************       If sy-subrc = 0.
****************         Delete from AUSP
****************                WHERE  objek = l_matnr
****************                AND    atinn = l_atinn.
******************
****************         g_tct100_wa-mstae = ''.
****************         modify g_tct100_itab from g_tct100_wa.
******************
****************       Endif.
******************  Updating internal comment in basic view..
****************       perform update_internal_comment using g_tct100_wa-matcode
****************                                             g_tct100_wa-res_nm.
****************       Clear: l_matnr,l_atinn.
****************
****************     ENDLOOP.
******************Updating database table
****************     LOOP AT g_tct100_itab INTO g_tct100_wa
****************                           where flag = 'X'
****************                           and   errcd = ''.
****************       MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
****************       MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
****************       move sy-uname to wa_nmblkcddt-unblkby.
****************       move sy-datum to wa_nmblkcddt-unblkdt.
****************       append wa_nmblkcddt to itab_nmblkcddt.
****************       clear:g_tct100_wa,wa_nmblkcddt.
****************     ENDLOOP.
****************     LOOP AT g_tct100_itab INTO g_tct100_wa
****************                           where errcd <> ''.
****************       MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
****************       MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
****************       append wa_nmblkcddt to itab_nmblkcddt.
****************     ENDLOOP.
****************     modify zmm_nmblkcddt from table itab_nmblkcddt.
****************
*******************Setting the request status.
****************     IF zmm_nmblkcdhd_st-status = 'IR'.
****************       PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
****************     ELSE.
*****************        DESCRIBE TABLE g_tct100_itab LINES l_totlines.
****************       SELECT COUNT(*) INTO l_totlines
****************                       FROM zmm_nmblkcddt
****************                       WHERE reqno = zmm_nmblkcdhd_st-reqno.
****************
****************       SELECT COUNT(*) INTO l_unblklines
****************                     FROM zmm_nmblkcddt
****************       WHERE reqno = zmm_nmblkcdhd_st-reqno
****************       AND   mstae = ''.
****************
****************       IF l_unblklines < l_totlines.
****************         zmm_nmblkcdhd_st-status = 'IC'.
****************         PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
****************       ELSE.
****************         zmm_nmblkcdhd_st-status = 'C'.
****************         PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
****************       ENDIF.
****************     ENDIF.
****************     PERFORM save_cors_text.
****************   ELSE.
****************     g_mesg = 'X'.
****************   ENDIF.
****************   CLEAR g_choice.
****************
***************** LOOP AT C_EBAN
*****************    SELECT * FROM kssk INTO TABLE tkssk
*****************              WHERE objek = c_eban-matnr
*****************              AND   klart = '001'.
*****************     IF sy-subrc = 0.  " kssk
*****************      LOOP AT tkssk.
*****************        SELECT SINGLE * FROM klah
*****************               WHERE klart  = '001'
*****************               AND   clint  = tkssk-clint
*****************               AND   class  = 'Z_ONGC_BLOCK'.
*****************        IF sy-subrc = 0.
*****************          SELECT SINGLE atinn INTO l_atinn
*****************                 FROM   cabn
*****************                 WHERE atnam = 'Z_ONGC_REASON'.
*****************          If sy-subrc = 0.
*****************             Select single atwrt into l_atwrt
*****************                    from ausp
*****************                    WHERE  objek = l_matnr
*****************                    AND    atinn = l_atinn.
*****************              IF sy-subrc = 0.
*****************                if l_atwrt = 'NM'.
*****************                 message e154(zmm_oth) with l_matnr.
*****************                endif.
*****************              ENDIF.
*****************              CLEAR: l_atinn,l_atwrt.
*****************          ENDIF.
*****************        ENDIF.
*****************      ENDLOOP.
*****************     ENDIF.
*****************   ENDLOOP.
****************
**************** endform.                    " unblock_matcode
*&---------------------------------------------------------------------*
*&      Form  confirm_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
************** form confirm_approval.
**************
**************   DATA : l_get3(1) TYPE c.
**************   CALL FUNCTION 'POPUP_TO_CONFIRM'
**************     EXPORTING
**************       TITLEBAR              = 'Approval '
**************       TEXT_QUESTION         = 'Want to Approve the request ? '
**************       DISPLAY_CANCEL_BUTTON = ' '
**************       START_COLUMN          = 25
**************       START_ROW             = 6
**************     IMPORTING
**************       ANSWER                = l_get3
**************     EXCEPTIONS
**************       TEXT_NOT_FOUND        = 1
**************       OTHERS                = 2.
**************   IF SY-SUBRC = 0.
**************     CASE l_get3.
**************       WHEN '1'.
**************         MOVE 'J' TO g_app.
**************       WHEN '2'.
**************         MOVE 'N' TO g_app.
**************     ENDCASE.
**************   ENDIF.
**************
************** endform.                    " confirm_approval




****&---------------------------------------------------------------------*
****&      Form  upload_from_textfile
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****      -->P_P_TC_NAME  text
****      -->P_P_TABLE_NAME  text
****      -->P_P_MARK_NAME  text
****----------------------------------------------------------------------*
*** form upload_from_textfile using  p_tc_name
***                                  p_table_name
***                                  p_mark_name.
***   DATA: l_filename LIKE rlgrap-filename.
***   DATA: l_tx100  TYPE t_tx100.
***   DATA: wa_tx100 TYPE t_tx100.
***   refresh : g_ex100_itab[].
***
***
***   DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
***          l_FILETABLE  TYPE  FILE_TABLE,
***          l_RC         TYPE  I,
***          l_P_DEF_FILE TYPE  STRING,
***          l_P_FILE     TYPE  STRING,
***          l_usr_act    TYPE  I.
***
***   l_P_DEF_FILE = l_filename.
***
***   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
***     EXPORTING
****      WINDOW_TITLE            =
****      DEFAULT_EXTENSION       =
***       DEFAULT_FILENAME        = l_P_DEF_FILE
****      FILE_FILTER             =
****      WITH_ENCODING           =
****      INITIAL_DIRECTORY       =
****      MULTISELECTION          =
***     CHANGING
***       FILE_TABLE              = I_FILE_TABLE
***       RC                      = l_RC
***       USER_ACTION             = l_usr_act
****      FILE_ENCODING           =
***     EXCEPTIONS
***       FILE_OPEN_DIALOG_FAILED = 1
***       CNTL_ERROR              = 2
***       ERROR_NO_GUI            = 3
***       NOT_SUPPORTED_BY_GUI    = 4
***       others                  = 5.
***   IF SY-SUBRC = 0 AND
***      l_usr_act <>
***      CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
***
***     LOOP AT I_FILE_TABLE  INTO l_FILETABLE.
***       l_P_FILE = l_FILETABLE.
***       EXIT.
***     ENDLOOP.
***
***     CALL FUNCTION 'GUI_UPLOAD'
***       EXPORTING
***         FILENAME                = l_P_FILE
***         FILETYPE                = g_c_asc
***         HAS_FIELD_SEPARATOR     = 'X'
***       TABLES
***         DATA_TAB                = g_tx100_itab
***       EXCEPTIONS
***         FILE_OPEN_ERROR         = 1
***         FILE_READ_ERROR         = 2
***         NO_BATCH                = 3
***         GUI_REFUSE_FILETRANSFER = 4
***         INVALID_TYPE            = 5
***         NO_AUTHORITY            = 6
***         UNKNOWN_ERROR           = 7
***         BAD_DATA_FORMAT         = 8
***         HEADER_NOT_ALLOWED      = 9
***         SEPARATOR_NOT_ALLOWED   = 10
***         HEADER_TOO_LONG         = 11
***         UNKNOWN_DP_ERROR        = 12
***         ACCESS_DENIED           = 13
***         DP_OUT_OF_MEMORY        = 14
***         DISK_FULL               = 15
***         DP_TIMEOUT              = 16
***         OTHERS                  = 17.
***     IF SY-SUBRC <> 0.
***       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
***     ENDIF.
***
***   ENDIF.
***
***   sort g_tx100_itab ascending by matcode.
***   delete adjacent duplicates from g_tx100_itab comparing matcode.
***
***data:  WA_TCT100 LIKE LINE OF g_TCT100_itab.
***   loop at g_tx100_itab[] INTO wa_tx100.
***    MOVE-CORRESPONDING wa_tx100 to  WA_TCT100.
***    APPEND  WA_TCT100 to g_TCT100_itab.
***    CLEAR WA_TCT100.
***   endloop.
***
***    CLEAR g_tx100_itab.
***    refresh g_tx100_itab[].
***
***
***
*** endform.                    " upload_from_textfile



******************&---------------------------------------------------------------------*
******************&      Form  get_data_from_tx100
******************&---------------------------------------------------------------------*
******************       text
******************----------------------------------------------------------------------*
******************  -->  p1        text
******************  <--  p2        text
******************----------------------------------------------------------------------*
****************** form get_data_from_tx100.
******************   Data: l_tx100_wa type t_tx100,
******************         l_srno like zmm_nmblkcddt-srno.
*********************Setting serial number.
******************   if g_tctlines = 0.
******************     l_srno = 0.
******************   else.
******************     if g_mode = 'CHA'.
******************       Select max( srno ) into l_srno from zmm_nmblkcddt
******************              where reqno = zmm_nmblkcdhd_st-reqno.
******************     else.
******************       l_srno = g_tctlines.
******************     endif.
******************   endif.
*********************
******************   loop at g_tx100_itab into l_tx100_wa.
******************     l_srno = l_srno + 1.
******************     g_tct100_wa-srno    = l_srno.
******************     g_tct100_wa-matcode = l_tx100_wa-matcode.
******************     select single maktx into g_tct100_wa-matdesc from makt
******************            where matnr = l_tx100_wa-matcode.
******************     select single meins into g_tct100_wa-uom from mara
******************            where matnr = l_tx100_wa-matcode.
******************     g_tct100_wa-res_nm  = l_tx100_wa-res_nm.
*********************check for non moving items..
******************     clear g_recstat.
******************     PERFORM validate_matcode USING l_tx100_wa-matcode
******************                              CHANGING g_recstat.
******************     if g_recstat = 'E'.
******************       g_tct100_wa-errcd = 'M'.
******************       g_tct100_wa-flag  = 'X'.
******************     endif.
*********************
******************     append g_tct100_wa to g_tct100_itab .
******************     clear g_tct100_wa.
******************   endloop.
****************** endform.                    " get_data_from_tx100


*******************&---------------------------------------------------------------------*
*******************&      Form  validate_matcode
*******************&---------------------------------------------------------------------*
*******************       text
*******************----------------------------------------------------------------------*
*******************      -->P_WA_TX100_MATCODE  text
*******************      <--P_G_RECSTAT  text
*******************----------------------------------------------------------------------*
****************** form validate_matcode using    p_matcode
******************                       changing p_recstat.
******************   Data: l_objek like ausp-objek.
******************   Select single objek into l_objek from ausp
******************           where objek = p_matcode
******************           and   atinn = ( Select atinn from cabn
******************                                  where atnam = 'Z_ONGC_REASON' )
******************           and   klart = '001'
******************           and   atwrt = 'NM'.
******************   if sy-subrc <> 0.
******************     p_recstat = 'E'.
******************   endif.
****************** endform.                    " validate_matcode
******************

********************&---------------------------------------------------------------------*
********************&      Form  check_errors
********************&---------------------------------------------------------------------*
********************       text
********************----------------------------------------------------------------------*
********************  -->  p1        text
********************  <--  p2        text
********************----------------------------------------------------------------------*
******************* form check_errors changing p_errstat.
*******************   Data : l_tct100 type t_tct100.
*********************
*******************   read table g_tct100_itab into l_tct100
*******************                            with key errcd = 'M'.
*******************   if sy-subrc = 0.
*******************     p_errstat = 'E'.
*******************     message i121(zmm_oth) with l_tct100-srno.
*******************   endif.
*******************
******************* endform.                    " check_errors


*&---------------------------------------------------------------------*
*&      Form  attach_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*** form attach_file.
***
***   clear g_att_files_wa.
***   refresh g_att_files.
***   IF g_mode = 'CHA'.
***     g_att_files_wa-LOGSYS  = zmm_nmblkcdhd_st-reqno.
***     g_att_files_wa-objtype = 'NMC'.   "'ATT'.
***     g_att_files_wa-objkey  = '01'.
***
***     append g_att_files_wa to g_att_files.
***
***     CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
***       EXPORTING
***         ATTACHMENT_DATA     = ''
***         ATTACHMENT_TYPE     = 'DOC'
***       TABLES
***         APPLICATION_OBJECTS = g_att_files.
***   Endif.
***
***
*** endform.                    " attach_file


*&---------------------------------------------------------------------*
*&      Form  list_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*** form list_file.
***   g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
***     EXPORTING
***       APPLICATION_OBJECT = g_att_files_wa.
****   FUNCTION                 = ' '
**** TABLES
****   FUNC_EXCLUDE             =  .
*** endform.                    " list_file



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

     DATA : l_get4(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR              = 'EXIT '
         TEXT_QUESTION         = 'Data will be lost, Want to quit? '
         DISPLAY_CANCEL_BUTTON = ' '
         START_COLUMN          = 25
         START_ROW             = 6
       IMPORTING
         ANSWER                = l_get4
       EXCEPTIONS
         TEXT_NOT_FOUND        = 1
         OTHERS                = 2.

     IF SY-SUBRC = 0.
       CASE l_get4.
         WHEN '1'.
           MOVE 'J' TO l_choice1.
         WHEN '2'.
           MOVE 'N' TO l_choice1.
       ENDCASE.
     ENDIF.

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


*************************&---------------------------------------------------------------------*
*************************&      Form  confirm_unblock
*************************&---------------------------------------------------------------------*
*************************       text
*************************----------------------------------------------------------------------*
*************************  -->  p1        text
*************************  <--  p2        text
*************************----------------------------------------------------------------------*
************************ form confirm_unblock.
************************   CLEAR g_choice.
************************
************************   DATA : l_get5(1) TYPE c.
************************   CALL FUNCTION 'POPUP_TO_CONFIRM'
************************     EXPORTING
************************       TITLEBAR              = 'Unblock'
************************       TEXT_QUESTION         = 'Want to unblock selected Codes ?'
************************       DISPLAY_CANCEL_BUTTON = ' '
************************       START_COLUMN          = 25
************************       START_ROW             = 6
************************     IMPORTING
************************       ANSWER                = l_get5
************************     EXCEPTIONS
************************       TEXT_NOT_FOUND        = 1
************************       OTHERS                = 2.
************************   IF SY-SUBRC = 0.
************************     CASE l_get5.
************************       WHEN '1'.
************************         MOVE 'J' TO g_choice.
************************       WHEN '2'.
************************         MOVE 'N' TO g_choice.
************************     ENDCASE.
************************   ENDIF.
************************
************************ endform.                    " confirm_unblock



*********************&---------------------------------------------------------------------*
*********************&      Form  popup_message
*********************&---------------------------------------------------------------------*
*********************       text
*********************----------------------------------------------------------------------*
*********************  -->  p1        text
*********************  <--  p2        text
*********************----------------------------------------------------------------------*
******************** form popup_message.
********************   Data : wa_text like trtab.
********************   Data : itab_text like trtab occurs 0.
********************   refresh itab_text.
**********************
********************   wa_text =
********************   'Please ensure that approval of concerned Director for unblocking '.
********************   append wa_text to itab_text.
********************   clear wa_text.
********************
********************   wa_text =
********************   'of Material codes has been attached in the change mode.'.
********************   append wa_text to itab_text.
********************   clear wa_text.
********************
********************   CALL FUNCTION 'LAW_SHOW_POPUP_WITH_TEXT'
********************     EXPORTING
********************       titelbar           = 'NOTE'
********************       SHOW_CANCEL_BUTTON = 'X'
********************       LINE_SIZE          = 65
********************     TABLES
********************       list_tab           = itab_text.
********************   IF sy-subrc <> 0.
********************* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*********************         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
********************   ENDIF.
********************
******************** endform.                    " popup_message



***********************&---------------------------------------------------------------------*
***********************&      Form  set_reqcl
***********************&---------------------------------------------------------------------*
***********************       text
***********************----------------------------------------------------------------------*
***********************      -->P_ZMM_MATBLOCKHD_ST_REQCL  text
***********************----------------------------------------------------------------------*
********************** form set_reqcl using p_status.
**********************   UPDATE zmm_nmblkcdhd
**********************   SET status = p_status
**********************   WHERE reqno = zmm_nmblkcdhd_st-reqno.
**********************
************************
**********************   IF zmm_nmblkcdhd_st-status = 'IR'.
**********************     UPDATE zmm_nmblkcdhd
**********************      SET ir_date = sy-datum
**********************      WHERE reqno = zmm_nmblkcdhd_st-reqno.
**********************   ENDIF.
**********************
********************** endform.                    " set_reqcl


********************&---------------------------------------------------------------------*
********************&      Form  update_internal_comment
********************&---------------------------------------------------------------------*
********************       text
********************----------------------------------------------------------------------*
********************      -->P_G_TCT100_WA_MATCODE  text
********************      -->P_G_TCT100_WA_RESNM  text
********************----------------------------------------------------------------------*
******************* form update_internal_comment using    p_matcode
*******************                                       p_res_nm.
*******************   Data: wa_lines like tline,
*******************         l_txt like tline-tdline,
*******************         l_insert type c.
*******************   Data : header like  thead,
*******************          l_tdname like thead-tdname.
*******************   Data : ist_nmlines like tline occurs 0 with header line.
*******************
***********************Update Internal Comments
*******************   header-tdobject = 'MATERIAL'.
*******************   header-tdid     = 'IVER'.
*******************   header-tdname   =  p_matcode .
*******************   header-tdspras  = 'EN'.
*******************   header-tdform   = 'SYSTEM'.
*******************   header-mandt    = sy-mandt .
*******************   l_tdname        = p_matcode.
*******************   refresh: ist_nmlines.
*******************
**********************Fetching the existing text against matcode.
*******************   select single * from stxh
*******************            where tdobject = 'MATERIAL'
*******************            and   tdname   = l_tdname
*******************            and   tdid     = 'IVER'.
*******************   if sy-subrc = 0.
*******************     CALL FUNCTION 'READ_TEXT'
*******************       EXPORTING
*******************         client   = sy-mandt
*******************         id       = 'IVER'
*******************         language = 'E'
*******************         name     = l_tdname
*******************         object   = 'MATERIAL'
*******************       TABLES
*******************         lines    = ist_nmlines.
*******************   endif.
**********************Appending the remark to existing text.
*******************   IF NOT ist_nmlines[] IS INITIAL.
*******************     wa_lines-tdformat = '*'.
*******************     wa_lines-tdline = '               '.
*******************     append wa_lines to ist_nmlines .
*******************   ENDIF.
*******************   concatenate sy-uname '-' sy-datum+6(2) '/'
*******************                            sy-datum+4(2) '/'
*******************                            sy-datum+0(4) '/' into l_txt .
*******************   wa_lines-tdformat = '*'.
*******************   wa_lines-tdline  =  l_txt .
*******************   append wa_lines to ist_nmlines .
*******************   wa_lines-tdline = p_res_nm.
*******************   append wa_lines to ist_nmlines .
*******************   clear l_txt.
*******************   concatenate 'Request no-' zmm_nmblkcdhd_st-reqno into l_txt.
*******************   wa_lines-tdline = l_txt.
*******************   append wa_lines to ist_nmlines .
*******************   wa_lines-tdline = '******************************************'.
*******************   append wa_lines to ist_nmlines .
*******************
*******************   if ist_nmlines[] is initial.
*******************     l_insert = 'X'.
*******************   else.
*******************     l_insert =  space.
*******************   endif.
**********************Saving the nonmoving text ( Remark)
*******************
*******************   CALL FUNCTION 'SAVE_TEXT'
*******************     EXPORTING
*******************       client          = sy-mandt
*******************       header          = header
*******************       insert          = l_insert
*******************       savemode_direct = 'X'
*******************     TABLES
*******************       lines           = ist_nmlines.
*******************
*******************
******************* endform.                    " update_internal_comment



****&---------------------------------------------------------------------*
****&      Form  del_attachment
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****  -->  p1        text
****  <--  p2        text
****----------------------------------------------------------------------*
*** form del_attachment.
***   g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***   CALL FUNCTION 'ZSO_DEL_ATTACHMENT'
***     EXPORTING
***       application_object = g_att_files_wa.
****    FUNCTION                 = ' '.
***
***
***
*** endform.                    " del_attachment


****&---------------------------------------------------------------------*
****&      Form  guidelines
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****  -->  p1        text
****  <--  p2        text
****----------------------------------------------------------------------*
*** form guidelines.
***
***   clear g_att_files_wa.
***   g_att_files_wa-LOGSYS = 'UBNMCDHELP'.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***
***
***   refresh exclude_tab[].
***   MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***
***   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
***     EXPORTING
***       APPLICATION_OBJECT = g_att_files_wa
***     TABLES
***       FUNC_EXCLUDE       = EXCLUDE_TAB.
***
*** endform.                    " guidelines


****&---------------------------------------------------------------------*
****&      Form  circular
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****  -->  p1        text
****  <--  p2        text
****----------------------------------------------------------------------*
*** form circular.
***   clear g_att_files_wa.
***
***   g_att_files_wa-LOGSYS = 'UBNMCDCIRC'.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***   refresh exclude_tab[].
***   MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***
***   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
***     EXPORTING
***       APPLICATION_OBJECT = g_att_files_wa
***     TABLES
***       FUNC_EXCLUDE       = EXCLUDE_TAB.
***
*** endform.                    " circular



*&---------------------------------------------------------------------*
*&      Form  EXTRACT_PLANTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXTRACT_PLANTS .
   REFRESH: ist_agr_users_plant, ist_plant.
   clear: wa_agr_users_plant, wa_plant.

   Data: L_ROLE_PLANT type agr_name.
   data: len type i,
         plant type WERKS_D.

   CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE_PLANT.

   len = strlen( L_ROLE_PLANT ).   " length including %
   len = len - 1.

   select * from agr_users
       into TABLE ist_agr_users_plant
         where uname = sy-uname
           and agr_name like L_ROLE_PLANT
           and from_dat <=   sy-datum
           and   to_dat >=  sy-datum.
   if  ist_agr_users_plant[] is initial.
     message id 'ZMSG' type 'E' number '000' with 'No MM INDENT PLANT authorization in' ZMM_NMBLKCDHD_ST-BUKRS 'comp code'.
   else .
     loop at ist_agr_users_plant INTO wa_agr_users_plant.
       wa_plant-plant = wa_agr_users_plant-agr_name+len(4).
       APPEND wa_plant to ist_plant.
     endloop.
   endif.


 ENDFORM.                    " EXTRACT_PLANTS
*&---------------------------------------------------------------------*
*&      Form  EXTRACT_PURCH_GRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXTRACT_PURCH_GRP .
   REFRESH: ist_agr_users_pgrp, ist_pgrp.
   clear: wa_agr_users_pgrp, wa_pgrp.

   Data: L_ROLE_PGRP type agr_name.   "purchase grp. MM_PUR_PO_MUM_PGRP_*
   data: len type i,
         pgrp type EKGRP.

   CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' '%' INTO L_ROLE_PGRP.

   len = strlen( L_ROLE_PGRP ).   " length including %
   len = len - 1.

   select * from agr_users
       into TABLE ist_agr_users_pgrp
         where uname = sy-uname
           and agr_name like L_ROLE_PGRP
           and from_dat <=   sy-datum
           and   to_dat >=  sy-datum.

   if  ist_agr_users_pgrp[] is initial.
     message id 'ZMSG' type 'W' number '000' with 'No Purchase Grp authorization in' ZMM_NMBLKCDHD_ST-BUKRS 'comp code'.
   else .
     loop at ist_agr_users_pgrp INTO wa_agr_users_pgrp.
       wa_pgrp-EKGRP = wa_agr_users_pgrp-agr_name+len(3).
       APPEND wa_pgrp to ist_pgrp.
     endloop.
   endif.

*  wa_pgrp-EKGRP = '1U1'. " TEMP
*  APPEND wa_pgrp to ist_pgrp.


 ENDFORM.                    " EXTRACT_PURCH_GRP

*&---------------------------------------------------------------------*
*&      Form  SUBMIT_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SUBMIT_REQUEST .
   CALL SCREEN 103 STARTING AT 10 2 ENDING AT 71 7.
   IF g_rel = 'Y'.
     PERFORM update_submit.
     PERFORM clear_var.
   ELSE.
     EXIT.
   ENDIF.


 ENDFORM.                    " SUBMIT_REQUEST

 form update_submit.
*update status & rel date
   UPDATE zmm_nmblkcdhd
     SET NM_STATUS    = 'IL3L4'
         DATE_CREATOR = sy-datum
     WHERE reqno    = zmm_nmblkcdhd_st-reqno.

   PERFORM save_cors_text.
   COMMIT WORK.
*    FM SWE_EVENT_CREATE

   data L_OBJKEY type SWEINSTCOU-OBJKEY.
   move zmm_nmblkcdhd_st-reqno to L_OBJKEY.

   CALL FUNCTION 'SWE_EVENT_CREATE'
     EXPORTING
       OBJTYPE                       = 'ZBUS_NM'
       OBJKEY                        = L_OBJKEY
       EVENT                         = 'RELEASE'
*   CREATOR                       = ' '
*   TAKE_WORKITEM_REQUESTER       = ' '
*   START_WITH_DELAY              = ' '
*   START_RECFB_SYNCHRON          = ' '
*   NO_COMMIT_FOR_QUEUE           = ' '
*   DEBUG_FLAG                    = ' '
*   NO_LOGGING                    = ' '
*   IDENT                         =
* IMPORTING
*   EVENT_ID                      =
*   RECEIVER_COUNT                =
* TABLES
*   EVENT_CONTAINER               =
* EXCEPTIONS
*   OBJTYPE_NOT_FOUND             = 1
*   OTHERS                        = 2
             .
   IF SY-SUBRC <> 0.
     MESSAGE i217(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. " Event creation error for req &.
   else.  " successful
     COMMIT WORK.
     MESSAGE i216(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.

*      mail and SMS to incharge                                           by                       mail/sms_to            other_text
     perform send_mail using ZMM_NMBLKCDHD_ST-REQNO 'released' ZMM_NMBLKCDHD_ST-ID_CREATOR ZMM_NMBLKCDHD_ST-ID_INCHARGE 'for your kind approval'. "'for your kind approval'.
     perform send_sms using ZMM_NMBLKCDHD_ST-REQNO 'released' ZMM_NMBLKCDHD_ST-ID_CREATOR ZMM_NMBLKCDHD_ST-ID_INCHARGE 'for your kind approval'. "'for your kind approval'.
   ENDIF.


 endform.                    " update_rel
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_REQNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VALIDATE_REQNO .

   data: zmm_nmblkcdhd_t type zmm_nmblkcdhd.


   SELECT SINGLE * FROM zmm_nmblkcdhd
     INTO  zmm_nmblkcdhd_t
       WHERE reqno = zmm_nmblkcdhd_st-reqno.

   IF sy-subrc = 0.

     IF zmm_nmblkcdhd_t-nm_status <> 'NEW'.
       MESSAGE e201(zmm_oth) WITH zmm_nmblkcdhd_t-nm_status. "Request is not with the creator(Current Status: &)
     ENDIF.

     IF zmm_nmblkcdhd_t-id_creator <> sy-uname.
       MESSAGE e107(zmm_oth) WITH zmm_nmblkcdhd_t-id_creator. "Request can only be released by the creator
     ENDIF.

   else.
     MESSAGE e202(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Invalid request no.

   ENDIF.


 ENDFORM.                    " VALIDATE_REQNO
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA .
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_DATA . " For L3L4, L2, L1, DIR
*update IDs if changed (ID_L1L2 ID_DIRECTOR) , correspondence
   data: WA_ZMM_NMBLKCDHD type ZMM_NMBLKCDHD.
   data: APPR_STATUS TYPE ZMM_NMBLKCDHD-NM_STATUS. " for WF
*SAVE HEADER DATA
   MOVE-CORRESPONDING ZMM_NMBLKCDHD_ST to WA_ZMM_NMBLKCDHD.
   Modify ZMM_NMBLKCDHD from WA_ZMM_NMBLKCDHD.
   clear WA_ZMM_NMBLKCDHD..

*SAVE deatail data
   PERFORM SAVE_DETAILS.

*save correspondence
   PERFORM save_cors_text.

   COMMIT WORK.

   APPR_STATUS = 'SAV'.  " for WF
   EXPORT APPR_STATUS to MEMORY ID 'ID_NMSTT'. " exported to WF

   MESSAGE i205(zmm_oth). "data saved

 ENDFORM.                    " SAVE_DATA .
*&---------------------------------------------------------------------*
*&      Form  REL_REJ_REV.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM REL_REJ_REV.

*update status, IDs changed (ID_L1L2 ID_DIRECTOR) , correspondence
   data: WA_ZMM_NMBLKCDHD type ZMM_NMBLKCDHD.
   data: msg(40).

   data: APPR_STATUS TYPE ZMM_NMBLKCDHD-NM_STATUS. " for WF

*Update HEADER DATA
   MOVE-CORRESPONDING ZMM_NMBLKCDHD_ST to WA_ZMM_NMBLKCDHD.

   CASE ok_code100.
     WHEN 'RELL3L4'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL2'.
       WA_ZMM_NMBLKCDHD-DATE_L3L4 = sy-datum.
       msg = 'Request released to L2 Level.'.
       APPR_STATUS = 'REL'.

*   Request ### to unblock NON MOVING materials is released by user id ####/Name |for your kind approval.

* SAP MAIL and SMS to CREATOR:                                    rel_by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L2: WA_ZMM_NMBLKCDHD-ID_L2
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_L2 ', for your kind approval'. " 'for your kind approval'
* mail to L2: 02.04.2014
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_L2 ', for your kind approval'. "'for your kind approval'.

     WHEN 'REJL3L4'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJL3L4'.
       WA_ZMM_NMBLKCDHD-DATE_L3L4 = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.
* SAP MAIL and SMS to CREATOR:                                    by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'

     WHEN 'REVL3L4'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'NEW'.
       WA_ZMM_NMBLKCDHD-DATE_L3L4 = sy-datum.
       msg = 'Request sent back to Requisitioner.'.
       APPR_STATUS = 'REV'.   " WF ends if REVERTED by L3L4
* SAP MAIL and SMS to CREATOR:                                    by                       mail/sms_to            other_text
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

     WHEN 'RELL2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL1'.
       WA_ZMM_NMBLKCDHD-DATE_L2 = sy-datum.
       msg = 'Request released to L1 Level.'.
       APPR_STATUS = 'REL'.

* SAP MAIL and SMS to CREATOR:                                    rel_by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L1: WA_ZMM_NMBLKCDHD-ID_L1
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_L1 ', for your kind approval'. " 'for your kind approval'

* mail to L1: 02.04.2014
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_L1 ', for your kind approval'. "'for your kind approval'.


     WHEN 'REJL2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJL2'.
       WA_ZMM_NMBLKCDHD-DATE_L2 = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'

     WHEN 'REVL2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL3L4'.
       WA_ZMM_NMBLKCDHD-DATE_L2 = sy-datum.
       msg = 'Request sent back to L3/L4 Level.'.
       APPR_STATUS = 'REV'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to INCHARGE: WA_ZMM_NMBLKCDHD-ID_INCHARGE
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_INCHARGE
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

* mail to I/c: 02.04.2014
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_INCHARGE
             '. Pls see comments, if any, in the note sheet and take appropriate action'. "'for your kind approval'.


     WHEN 'RELL1L2'.   " Now L1
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IDIR'.
       WA_ZMM_NMBLKCDHD-DATE_L1 = sy-datum.
       msg = 'Request released to the Director Level.'.
       APPR_STATUS = 'REL'.

* SAP MAIL and SMS to CREATOR:                                    rel_by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to Dir: WA_ZMM_NMBLKCDHD-ID_DIRECTOR
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_DIRECTOR ', for your kind approval'. " 'for your kind approval'

* SMS to Dir's PA : WA_ZMM_NMBLKCDHD-ID_DIRECTOR
       data: L_ID_DIRS_PA type sy-uname.
       clear L_ID_DIRS_PA.
       PERFORM get_dirs_pa USING WA_ZMM_NMBLKCDHD-ID_DIRECTOR CHANGING L_ID_DIRS_PA.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 L_ID_DIRS_PA ', for Director''s kind approval'. " 'for your kind approval'

* mail to Dir: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_DIRECTOR ', for your kind approval'. " 'for your kind approval'

* mail to Dir's PA: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 L_ID_DIRS_PA ', for Director''s kind approval'. " 'for your kind approval'


     WHEN 'REJL1L2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJL1'.
       WA_ZMM_NMBLKCDHD-DATE_L1 = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'

     WHEN 'REVL1L2'.

       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL2'.
       WA_ZMM_NMBLKCDHD-DATE_L1 = sy-datum.
       msg = 'Request sent back to L2 Level.'.
       APPR_STATUS = 'REV'.

* SAP MAIL and SMS to CREATOR:                                     rev by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L2: WA_ZMM_NMBLKCDHD-ID_L2
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_L2
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

* mail to L2: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_L2
              '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'


     WHEN 'APPRDIR'.
** remove NM flags : form unblock_matcode.
*    WA_ZMM_NMBLKCDHD-NM_STATUS = 'COMPLETE'. "status will be set to 'complete' in the WF
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'APPRDIR'.
       WA_ZMM_NMBLKCDHD-DATE_DIR = sy-datum.
       msg = 'Request approved.'.
       APPR_STATUS = 'REL'.

* SAP MAIL and SMS to CREATOR:                                     appr by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'approved' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR '. Non moving flag has been removed'. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'approved' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR '. Non moving flag has been removed'. " 'for your kind approval'


     WHEN 'REJDIR'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJDIR'.
       WA_ZMM_NMBLKCDHD-DATE_DIR = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'


     WHEN 'REVDIR'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL1'.
       WA_ZMM_NMBLKCDHD-DATE_DIR = sy-datum.
       msg = 'Request sent back to L1 Level.'.
       APPR_STATUS = 'REV'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L1: WA_ZMM_NMBLKCDHD-ID_L1
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_L1
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

* mail to L1: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_L1
             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'

   ENDCASE.

   Modify ZMM_NMBLKCDHD from WA_ZMM_NMBLKCDHD.
   clear WA_ZMM_NMBLKCDHD..

*SAVE deatail data
   PERFORM SAVE_DETAILS.
*save correspondence
   PERFORM save_cors_text.

   COMMIT WORK.


   EXPORT APPR_STATUS to MEMORY ID 'ID_NMSTT'. " exported to WF

   MESSAGE i206(zmm_oth) with msg. "Request released to L1/L2 Level

***  now SMS and SAP MAIL to CREATOR


 ENDFORM.                    " REL_REJ_REV.

*&---------------------------------------------------------------------*
*&      Form  ROLE_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ROLE_AUTH .
* role & data based AUTH check
   Data: L_ROLE type agr_name.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
   data: L_SUBRC(1).
   clear L_SUBRC.
*End RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

**IF  sy-uname+0(3) <> 'CMM' . " no role check

   if sy-tcode = 'ZMMNMREQ'    . " User is requisitioner

     IF g_mode = 'CRE' OR g_mode = 'CHA'.
*1. MM_INDENT_MUM_PLANT_*
*2. MM_PUR_PO_MUM_PGRP_*

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*       PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.
       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

       CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' '%' INTO L_ROLE.
       PERFORM AUTH_CHECK_COMP USING L_ROLE 'Purchase Group'.

     ENDIF.

   elseif sy-tcode = 'ZMMNMWF2'.  "User is Incharge (L3/L4)

*1. MM_INDENT_MUM_PLANT_%
*2. MM_PUR_PO_MUM_PGRP_%(purchase grp)
*3. D:MM_PUR_PO_APPROVE_L4 OR L3


*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*     PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.

       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' '%' INTO L_ROLE.
     PERFORM AUTH_CHECK_COMP USING L_ROLE 'Purchase Group'.

     PERFORM AUTH_CHECK_L3L4.

   elseif sy-tcode = 'ZMMNMWFL2'. " User is L2, addnl requirement
*1. MM_INDENT_MUM_PLANT_*
*2. D:MM_PUR_PO_APPROVE_L2

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*     PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.

       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     PERFORM AUTH_CHECK_L2.

   elseif sy-tcode = 'ZMMNMWF3'. " User is L1
*1. MM_INDENT_MUM_PLANT_*
*2. D:MM_PUR_PO_APPROVE_L1 or D:MM_PUR_PO_APPROVE_L2

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*     PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.
       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     PERFORM AUTH_CHECK_L1.

   elseif sy-tcode = 'ZMMNMWF4'. " User is a Dir
*1.     D:MM_SRV_IND_APPROVE_DI
     PERFORM AUTH_CHECK_DIR.
   endif.

**ENDIF.

 ENDFORM.                    " ROLE_AUTH
*&---------------------------------------------------------------------*
*&      Form  PLANT_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_ROLE_PLANT  text
*----------------------------------------------------------------------*
 FORM AUTH_CHECK_COMP  USING P_L_ROLE P_TEXT .
** Purch grp specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and agr_name like P_L_ROLE
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e214(zmm_oth) with P_TEXT  ZMM_NMBLKCDHD_ST-BUKRS.  "No & authorization in & Company Code
   endif.

 ENDFORM.                    " PLANT_AUTH

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
FORM AUTH_CHECK_COMP_INDENT  USING P_L_ROLE1 P_L_ROLE2 P_TEXT .
** INDENT company code specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name like P_L_ROLE1
             or agr_name = P_L_ROLE2 )
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.

   if  wa_agr_users is initial.
     message e214(zmm_oth) with P_TEXT  ZMM_NMBLKCDHD_ST-BUKRS.  "No & authorization in & Company Code
   endif.

 ENDFORM.                    " PLANT_AUTH
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853


*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L3L4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
 FORM AUTH_CHECK_L3L4.
** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name =  'D:MM_PUR_PO_APPROVE_L3'
               or agr_name =  'D:MM_PUR_PO_APPROVE_L4'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               or agr_name =  'D:MM_SRV_IND_APPROVE_L3'
               or agr_name =  'D:MM_SRV_IND_APPROVE_L4' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'L3/L4'   .    "No relevant & level authorization.
   endif.

 ENDFORM.                    " AUTH_CHECK_L3L4

*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L1L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
 FORM AUTH_CHECK_L2.
** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name =  'D:MM_PUR_PO_APPROVE_L2'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               or agr_name =  'D:MM_SRV_IND_APPROVE_L2' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'L2' .    "No & level authorization for approving the request.
   endif.

 ENDFORM.                    " AUTH_CHECK_LEVEL


*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L1L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
 FORM AUTH_CHECK_L1.
** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name =  'D:MM_PUR_PO_APPROVE_L1'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                or agr_name =  'D:MM_SRV_IND_APPROVE_L1' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'L1' .    "No & level authorization for approving the request.
   endif.

 ENDFORM.                    " AUTH_CHECK_LEVEL
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_DIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM AUTH_CHECK_DIR .

** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and  agr_name =  'D:MM_SRV_IND_APPROVE_DI'
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'Director' .    " No & level authorization for approving the request.
   endif.

 ENDFORM.                    " AUTH_CHECK_DIR
*&---------------------------------------------------------------------*
*&      Form  SAVE_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_DETAILS . "Save by L3L4, L2, L1, Dir
   clear g_tct100_wa.
   REFRESH itab_nmblkcddt.

   LOOP AT g_tct100_itab INTO g_tct100_wa.
     MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
* fill Req. No. in each row
     MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
* fill Status, Rej_by , Rej_date for rejected rows

** Row status : Above L3l4: Update each row's status into DB table only when
* the request is being RELEASED, REVERTED or REJECTED, but not when only SAVEd.
* Also validate rows on RELEASE, REVERT and APPR.
     IF ok_code100+0(3) = 'REL'.
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
         wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECTED'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
         wa_nmblkcddt-STATUS = 'REPLY'.
***  ELSEIF wa_nmblkcddt-DECISION = '' or wa_nmblkcddt-DECISION = 'QUERY'.

***       clear ok_code100.
***       MESSAGE E231(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'REJ'.
       " Whole Request rejected, no update of row status or validation needed

     ELSEIF ok_code100+0(3) = 'REV'.

       IF wa_nmblkcddt-DECISION = 'ACCEPT'.   " solving: reverted accept is editable.
         wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECTED'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
         wa_nmblkcddt-STATUS = 'QUERY'.

***  ELSEIF wa_nmblkcddt-DECISION = ''
***          or wa_nmblkcddt-DECISION = 'REPLY'.
***       clear ok_code100 .
***       MESSAGE E232(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'APP'.   "approval by DIR

       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
         wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECTED'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
**  ELSEIF wa_nmblkcddt-DECISION = ''
**            or wa_nmblkcddt-DECISION = 'QUERY'
**              or wa_nmblkcddt-DECISION = 'REPLY'..
**       clear ok_code100.
**       MESSAGE E230(zmm_oth).
       ENDIF.

     ENDIF.

     append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.

   MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
*     INSERT zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
 ENDFORM.                    " SAVE_DETAILS



*&---------------------------------------------------------------------*
*&      Form  VALIDATE_BEFORE_REL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VALIDATE_BEFORE_REL_REJ_REV .
*BREAK cab_alok.
   CASE ok_code100.
     WHEN 'SAV'. "Creator: Release by Creator
** Approval chain
       if G_REL_FLAG = 'X'.  " Release by Creator
         if ZMM_NMBLKCDHD_ST-ID_INCHARGE is INITIAL.
           CLEAR ok_code100.
           message e224(zmm_oth)  .
         endif.
       endif.

     WHEN 'RELL3L4'.
** Approval chain
       if ZMM_NMBLKCDHD_ST-ID_L2 is INITIAL
         or ZMM_NMBLKCDHD_ST-ID_L1 is INITIAL
           or ZMM_NMBLKCDHD_ST-ID_DIRECTOR is INITIAL .
         CLEAR ok_code100.
         message e223(zmm_oth)  .
       endif.

     WHEN 'RELL2'.
** Approval chain
       if ZMM_NMBLKCDHD_ST-ID_L1 is INITIAL
           or ZMM_NMBLKCDHD_ST-ID_DIRECTOR is INITIAL .
         CLEAR ok_code100.
         message e223(zmm_oth).
       endif.

     WHEN 'RELL1L2'.   "now for L1 only
** Approval chain
       if ZMM_NMBLKCDHD_ST-ID_DIRECTOR is INITIAL .
         CLEAR ok_code100.
         message e223(zmm_oth) .
       endif.

   ENDCASE.

* 11111
* row status: check accept  while release by creator
* delete duplicate validation code from  form insert_into_tab.  .
* reverted row can't be accpted by previous levels.

** Row status : validate each row for allowed status on Release by Creator,
**  and on rej/ rel/ rev by L3L4+

   clear g_tct100_wa.
   REFRESH itab_nmblkcddt.
   LOOP AT g_tct100_itab INTO g_tct100_wa.
     MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
* fill Req. No. in each row
     MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
*

**Row status: For L3L4+: validate rows on RELEASE, REVERT and APPR.
*   For Creator: validate rows on Release by Creator, If this is a
*    reverted request and being released by the creator, creator can choose
*   only 'REJECT', 'REPLY'. ( Already ACCEPTed row will be read only. If this is
*   a fresh request, decision column will not be available to him. )
*   Fill Status, Rej_by , Rej_date for rejected rows

     IF ok_code100 = 'SAV' AND  G_REL_FLAG = 'X'  " Release by Creator
        and ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL. "reverted request

       IF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECT'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
***     wa_nmblkcddt-STATUS = 'REPLY'.
*  ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
*     wa_nmblkcddt-STATUS = 'QUERY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
               or wa_nmblkcddt-DECISION = 'QUERY'.
*             or wa_nmblkcddt-DECISION = 'ACCEPT'.
         clear ok_code100.
         MESSAGE E231(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'REL'.    " Rel by L3L4+
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.     "check
***     wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECTED'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
***     wa_nmblkcddt-STATUS = 'REPLY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
                or wa_nmblkcddt-DECISION = 'QUERY'.

         clear ok_code100.
         MESSAGE E231(zmm_oth) with wa_nmblkcddt-srno.
       ENDIF.

     ELSEIF ok_code100+0(3) = 'REJ'.    " Rej by L3L4+
       " Whole Request rejected, no update of row status or validation needed

     ELSEIF ok_code100+0(3) = 'REV'.
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
*     wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECTED'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
***     wa_nmblkcddt-STATUS = 'QUERY'.
*  ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
*     wa_nmblkcddt-STATUS = 'REPLY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
               or wa_nmblkcddt-DECISION = 'REPLY'. .
         clear ok_code100 .
         MESSAGE E232(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'APP'.   "approval by DIR
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
***     wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECTED'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = ''
                or wa_nmblkcddt-DECISION = 'QUERY'
                  or wa_nmblkcddt-DECISION = 'REPLY'..
         clear ok_code100.
         MESSAGE E230(zmm_oth).
       ENDIF.

     ENDIF.

     append wa_nmblkcddt to itab_nmblkcddt.
     clear wa_nmblkcddt.
   ENDLOOP.

 ENDFORM.                    " VALIDATE_BEFORE_REL_REJ_REV .
*&---------------------------------------------------------------------*
*&      Form  FILL_ENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_INCHARGE  text
*----------------------------------------------------------------------*
* FORM FILL_ENAME  TABLES   P_IST_INCHARGE like IST_INCHARGE.
 FORM FILL_ENAME  TABLES   P_IST_APPROVER STRUCTURE WA_APPROVER ."OR like IST_INCHARGE. OR "type STANDARD TABLE ty_user.

*SELECT ENAME FROM PA0001 INTO CORRESPONDING FIELDS OF TABLE P_IST_INCHARGE
*  FOR ALL ENTRIES IN P_IST_INCHARGE
*  WHERE PERNR = P_IST_INCHARGE-UNAME.
   data: P_WA_APPROVER type ty_user.
   DATA: l_tabix      TYPE sy-tabix.
   data: L_ENAME type EMNAM.
   LOOP at P_IST_APPROVER into P_WA_APPROVER.
     l_tabix  = sy-tabix.
     SELECT ENAME
 FROM PA0001 INTO P_WA_APPROVER-ENAME UP TO 1 ROWS WHERE PERNR = P_WA_APPROVER-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     MODIFY P_IST_APPROVER index l_tabix  FROM P_WA_APPROVER TRANSPORTING ENAME.

   ENDLOOP.


 ENDFORM.                    " FILL_ENAME
*&---------------------------------------------------------------------*
*&      Form  CLEAR_OLD_VRM_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLEAR_OLD_APPR_CHAIN .
   if   FLAG_CLEAR_OLD_APPR_CHAIN = 'X'.
     clear ZMM_NMBLKCDHD_ST-ID_INCHARGE.
     clear ZMM_NMBLKCDHD_ST-ID_L2.
     clear ZMM_NMBLKCDHD_ST-ID_L1.
     clear ZMM_NMBLKCDHD_ST-ID_DIRECTOR.

     clear FLAG_CLEAR_OLD_APPR_CHAIN.
   endif.

 ENDFORM.                    " CLEAR_OLD_APPR_CHAIN
*&---------------------------------------------------------------------*
*&      Form  LOV_INCHARGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_INCHARGE .  "L3 / L4

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     clear: L_ROLE1A .
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     data: IST_INCHARGE type TABLE OF ty_user,
           WA_INCHARGE type ty_user.

    CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
    CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1A.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' ZMM_NMBLKCDHD_ST-EKGRP INTO L_ROLE2.


     select A~uname
       into CORRESPONDING FIELDS OF TABLE IST_INCHARGE
         from ( ( agr_users as A
                  INNER JOIN  agr_users as B on B~uname = A~uname )
                  INNER JOIN  agr_users as C on C~uname = B~uname )

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*         where A~agr_name = L_ROLE1
         where ( A~agr_name = L_ROLE1
                 or A~agr_name = L_ROLE1A )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and B~agr_name = L_ROLE2
               and ( C~agr_name = 'D:MM_PUR_PO_APPROVE_L3'
                     or C~agr_name = 'D:MM_PUR_PO_APPROVE_L4'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                     or C~agr_name = 'D:MM_SRV_IND_APPROVE_L3'
                     or C~agr_name = 'D:MM_SRV_IND_APPROVE_L4' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and A~from_dat <=   sy-datum
               and A~to_dat >=  sy-datum.

     SORT IST_INCHARGE ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_INCHARGE COMPARING UNAME.

     perform FILL_ENAME TABLES IST_INCHARGE.

***  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
***    exporting
***      retfield        = 'UNAME'
***      dynpprog        = sy-cprog
***      dynpnr          = sy-dynnr
***      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_INCHARGE'
***      value_org       = 'S'
***    tables
***      value_tab       = IST_INCHARGE
***      field_tab       = ist_field
***      return_tab      = ist_return_tab
***      dynpfld_mapping = ist_dynpfld_mapping
***    exceptions
***      parameter_error = 1
***      no_values_found = 2
***      others          = 3.
***  if sy-subrc <> 0.
***    message id sy-msgid type sy-msgty number sy-msgno
***            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
***  endif.
***
***  ZMM_NMBLKCDHD_ST-ID_INCHARGE = ist_return_tab-fieldval.


     refresh g_list[].
     CLEAR g_value.
     loop at IST_INCHARGE INTO WA_INCHARGE.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_INCHARGE-UNAME.
       concatenate WA_INCHARGE-UNAME '-' WA_INCHARGE-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_INCHARGE'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

   ENDIF.

 ENDFORM.                    " LOV_INCHARGE


*&---------------------------------------------------------------------*
*&      Form  LOV_L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_L2 .

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     clear: L_ROLE1A .
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     data: IST_L2 type TABLE OF ty_user,
           WA_L2 type ty_user.
    CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
    CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1A.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853


     select A~uname
       into CORRESPONDING FIELDS OF TABLE IST_L2
         from ( agr_users as A
                INNER JOIN  agr_users as B on B~uname = A~uname )
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*         where A~agr_name = L_ROLE1
         where ( A~agr_name = L_ROLE1
                 or A~agr_name = L_ROLE1A )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
            and ( B~agr_name = 'D:MM_PUR_PO_APPROVE_L2'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                  or B~agr_name = 'D:MM_SRV_IND_APPROVE_L2' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and A~from_dat <=   sy-datum
               and A~to_dat >=  sy-datum.


     SORT IST_L2 ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_L2 COMPARING UNAME.

     perform FILL_ENAME TABLES IST_L2.

*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      retfield        = 'uname'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L2'
*      value_org       = 'S'
*    tables
*      value_tab       = IST_L2
*      field_tab       = ist_field
*      return_tab      = ist_return_tab
*      dynpfld_mapping = ist_dynpfld_mapping
*    exceptions
*      parameter_error = 1
*      no_values_found = 2
*      others          = 3.
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  ZMM_NMBLKCDHD_ST-ID_L2 = ist_return_tab-fieldval.


     refresh g_list[].
     CLEAR g_value.
     loop at IST_L2 INTO WA_L2.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_L2-UNAME.
       concatenate WA_L2-UNAME '-' WA_L2-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_L2'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.


   ENDIF.

 ENDFORM.                    " LOV_L2

*&---------------------------------------------------------------------*
*&      Form  LOV_L1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_L1 .

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     clear: L_ROLE1A .
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     data: IST_L1 type TABLE OF ty_user,
           WA_L1 type ty_user.

     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
    CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1A.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     select A~uname
       into CORRESPONDING FIELDS OF TABLE IST_L1
         from ( agr_users as A
                INNER JOIN  agr_users as B on B~uname = A~uname )
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*         where A~agr_name = L_ROLE1
         where ( A~agr_name = L_ROLE1
                 or A~agr_name = L_ROLE1A )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and ( B~agr_name = 'D:MM_PUR_PO_APPROVE_L1'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                  or B~agr_name = 'D:MM_SRV_IND_APPROVE_L1' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 3001185
               and A~from_dat <=   sy-datum
               and A~to_dat >=  sy-datum.

     SORT IST_L1 ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_L1 COMPARING UNAME.

     perform FILL_ENAME TABLES IST_L1.

*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      retfield        = 'uname'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L1'
*      value_org       = 'S'
*    tables
*      value_tab       = IST_L1
*      field_tab       = ist_field
*      return_tab      = ist_return_tab
*      dynpfld_mapping = ist_dynpfld_mapping
*    exceptions
*      parameter_error = 1
*      no_values_found = 2
*      others          = 3.
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  ZMM_NMBLKCDHD_ST-ID_L1 = ist_return_tab-fieldval.

     refresh g_list[].
     CLEAR g_value.
     loop at IST_L1 INTO WA_L1.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_L1-UNAME.
       concatenate WA_L1-UNAME '-' WA_L1-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_L1'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

   ENDIF.

 ENDFORM.                    " LOV_L1

*&---------------------------------------------------------------------*
*&      Form  LOV_DIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_DIR .

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .

     data: IST_DIR type TABLE OF ty_user,
           WA_DIR type ty_user.

     select uname
       into CORRESPONDING FIELDS OF TABLE IST_DIR
         from agr_users
         where agr_name = 'D:MM_SRV_IND_APPROVE_DI'
               and from_dat <=   sy-datum
               and to_dat >=  sy-datum.

     SORT IST_DIR ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_DIR COMPARING UNAME.

     perform FILL_ENAME TABLES IST_DIR.

*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      retfield        = 'uname'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
*      value_org       = 'S'
*    tables
*      value_tab       = IST_DIR
*      field_tab       = ist_field
*      return_tab      = ist_return_tab
*      dynpfld_mapping = ist_dynpfld_mapping
*    exceptions
*      parameter_error = 1
*      no_values_found = 2
*      others          = 3.
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  ZMM_NMBLKCDHD_ST-ID_DIRECTOR = ist_return_tab-fieldval.

     refresh g_list[].
     CLEAR g_value.
     loop at IST_DIR INTO WA_DIR.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_DIR-UNAME.
       concatenate WA_DIR-UNAME '-' WA_DIR-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

   ENDIF.

 ENDFORM.                    " LOV_DIR
*&---------------------------------------------------------------------*
*&      Form  KEEP_IN_INBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM KEEP_IN_INBOX .
   data: APPR_STATUS TYPE ZMM_NMBLKCDHD-NM_STATUS. " for WF

   APPR_STATUS = 'KEEP'.
   EXPORT APPR_STATUS to MEMORY ID 'ID_NMSTT'. " exported to WF

   MESSAGE i225(zmm_oth). "Workitem sent back in the inbox.


 ENDFORM.                    " KEEP_IN_INBOX
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_ACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONFIRM_ACTION .
   data: question(400).


   CASE ok_code100.
     WHEN 'RELL3L4'.
       CONCATENATE  'Request will be released to L2 level.'
           '                                 Do you want to release?'
            into question respecting blanks.

     WHEN 'RELL2'.
       CONCATENATE  'Request will be released to L1 level.'
           '                                 Do you want to release?'
            into question respecting blanks.

     WHEN 'RELL1L2'.  " now L1
       CONCATENATE  'Request will be released to DI level.'
           '                                 Do you want to release?'
            into question respecting blanks.

     WHEN 'APPRDIR'.
       CONCATENATE  'Request for removal of Non-moving flag for materials will be approved.'
           '                                 Do you want to approve?'
            into question respecting blanks.

***

     WHEN 'REVL3L4'.
       CONCATENATE  'Request will be reverted back to the requisitioner.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.

     WHEN 'REVL2'.
       CONCATENATE  'Request will be reverted back to the L3/L4.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.

     WHEN 'REVL1L2'.       "Now L1
       CONCATENATE  'Request will be reverted back to the L2.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.

     WHEN 'REVDIR'.
       CONCATENATE  'Request will be reverted back to the L1.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.
***


     WHEN 'REJL3L4' or 'REJL2' or 'REJL1L2' or  'REJDIR'..
       CONCATENATE  'Request will be rejected completely and can not be activated again.'
           '                                 Do you want to reject?'
           into question respecting blanks.

   ENDCASE.




   clear ANS_CONFIRM_ACTION.

   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
      TITLEBAR                    = 'Confirm action'
*   DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION               = question
      TEXT_BUTTON_1               = 'Yes'   "(001)
*   ICON_BUTTON_1               = ' '
      TEXT_BUTTON_2               = 'No'   " (002)
*   ICON_BUTTON_2               = ' '
*   DEFAULT_BUTTON              = '1'
      DISPLAY_CANCEL_BUTTON       = ''
*   USERDEFINED_F1_HELP         = ' '
      START_COLUMN                = 25
      START_ROW                   = 6
*   POPUP_TYPE                  =
*   IV_QUICKINFO_BUTTON_1       = ' '
*   IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER                      = ANS_CONFIRM_ACTION " '1' / '2'
* TABLES
*   PARAMETER                   =
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2
             .

 ENDFORM.                    " CONFIRM_ACTION


*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
* To send mail to PO creater
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_IMS_STATUS  IMS Status
*----------------------------------------------------------------------*
 form send_mail  using  P_REQNO type ZMM_NMBLKCDHD-REQNO
                        P_STATUS type ztxt10
                        p_rel_by TYPE sy-uname
                        p_mail_to type sy-uname
                        p_addl_text type ztxt100.

*perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' ID_INCHARGE ID_CREATOR 'for your kind approval'.


   data: L_REL_BY_ENAME type EMNAM.
   data: L_MAIL_SUBJ(50).
   data : w_object_hd  type sodocchgi1.
   data : ist_receiver type somlreci1  occurs 0  with header line.
   data : ist_message type solisti1 occurs 0 with header line.
   data : l_send_to_all(1).

*get emp name
   SELECT ENAME
 FROM PA0001 INTO L_REL_BY_ENAME UP TO 1 ROWS WHERE PERNR = P_REL_BY
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*Mail header
   w_object_hd-obj_name   = 'MAIL_NON_MOV'.
   w_object_hd-obj_langu  = sy-langu .
   w_object_hd-obj_prio   = '1'.
   w_object_hd-no_change  = 'X'.
   w_object_hd-priority   = '1'.
   CONCATENATE 'Non-moving material: Req no. ' P_REQNO INTO L_MAIL_SUBJ RESPECTING BLANKS. "separated by space.
   w_object_hd-OBJ_DESCR  = L_MAIL_SUBJ.

*Receivers
   ist_receiver-receiver = p_mail_to.
   ist_receiver-rec_type = 'B'. "'B' : SAP user name, 'U' : Internet address
   ist_receiver-express  = 'X'.
*  ist_receiver-COPY  = 'X'.  " CC
*  ist_receiver-BLIND_COPY = 'X'.  "BCC
   append ist_receiver.

* Mail  content

   clear  ist_message.
   append ist_message. "blank line

   clear  ist_message.
   ist_message = 'Dear Ma''am/Sir'.
   append ist_message.

   clear  ist_message.
   append ist_message.

   clear  ist_message.
*Request ### to unblock NON MOVING materials is released by user id ####/Name for your kind approval.
   concatenate 'Request no. ' P_REQNO 'to unblock NON MOVING materials has been ' P_STATUS
               'by Mr./Ms.' L_REL_BY_ENAME ', ID:' p_rel_by  p_addl_text '.'
               into ist_message separated by space.
   append ist_message.

   clear  ist_message.
   ist_message = 'This is an automatically generated e-mail. Please do not respond to this mail.'.
   append ist_message.

   clear  ist_message.
   ist_message = 'Kindly check work item in Inbox -> Workflow.'.
   append ist_message.


   CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
     EXPORTING
       document_data              = w_object_hd
       document_type              = 'RAW'
     IMPORTING
       sent_to_all                = l_send_to_all
     TABLES
       object_content             = ist_message
       receivers                  = ist_receiver
     EXCEPTIONS
       too_many_receivers         = 1
       document_not_sent          = 2
       document_type_not_exist    = 3
       operation_no_authorization = 4
       parameter_error            = 5
       x_error                    = 6
       enqueue_error              = 7.

   if l_send_to_all <> 'X'.
     message i226(zmm_oth) with p_mail_to.
   endif.


 endform.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_NMBLKCDHD_REQNO  text
*      -->P_4647   text
*      -->P_WA_ZMM_NMBLKCDHD_ID_INCHARGE  text
*      -->P_WA_ZMM_NMBLKCDHD_ID_CREATOR  text
*      -->P_4650   text
*----------------------------------------------------------------------*
 FORM SEND_SMS  USING   P_REQNO type ZMM_NMBLKCDHD-REQNO
                        P_STATUS type ztxt10
                        p_rel_by TYPE sy-uname
                        p_sms_to type sy-uname   "user ID
                        p_addl_text type ztxt100.

   data: mob_no(12),
         Msg(255).
   DATA: wf_string TYPE string ,
         result    TYPE string ,
         l_result(50).
   DATA: result_tab TYPE TABLE OF string.
   DATA: http_client TYPE REF TO if_http_client .
   data: L_REL_BY_ENAME type EMNAM.

   data: L_REQNO TYPE ZMM_NMBLKCDHD-REQNO.
   L_REQNO  = P_REQNO .
   SHIFT L_REQNO LEFT DELETING LEADING '0'.

   clear: mob_no, Msg, wf_string, result, l_result.
   refresh result_tab .

*get emp name
   SELECT ENAME
 FROM PA0001 INTO L_REL_BY_ENAME UP TO 1 ROWS WHERE PERNR = P_REL_BY
 ORDER BY PRIMARY KEY .
 ENDSELECT.

* get mob_no for user ID p_sms_to
   PERFORM get_emp_mobile using p_sms_to CHANGING mob_no.



   if mob_no is not INITIAL.
*msg
*Request ### to unblock NON MOVING materials is released by user id ####/Name / for your kind approval.
     concatenate 'Request no. ' L_REQNO 'to unblock NON MOVING materials' P_STATUS
                 'by Mr./Ms.' L_REL_BY_ENAME ',ID:' p_rel_by  p_addl_text '.'
                 into MSG separated by space.

     CONCATENATE 'http://10.205.48.190:13013/cgi-bin/sendsms?'
                 'username=ongc&password=ongc12&from=ONGC-OL&to=' MOB_NO
                 '&text=' msg
                 '&remLen=160'
         INTO wf_string .

     CALL METHOD cl_http_client=>create_by_url
       EXPORTING
         url                = wf_string
       IMPORTING
         client             = http_client
       EXCEPTIONS
         argument_not_found = 1
         plugin_not_active  = 2
         internal_error     = 3
         OTHERS             = 4.


     CALL METHOD http_client->send
       EXCEPTIONS
         http_communication_failure = 1
         http_invalid_state         = 2.

     CALL METHOD http_client->receive
       EXCEPTIONS
         http_communication_failure = 1
         http_invalid_state         = 2
         http_processing_failed     = 3.
     CLEAR result .
     result = http_client->response->get_cdata( ).




* for debugging
*      move result to l_result .
*      CONCATENATE 'Message from SMS gateway:' l_result+2 INTO l_result.
*      MESSAGE i206(zmm_oth) WITH l_result. "0: Accepted for delivery
*      REFRESH result_tab .
*      SPLIT result AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .

     CALL METHOD http_client->close( ).


   endif.  "/  mob_no is not INITIAL.

 ENDFORM.                    " SEND_SMS

 FORM GET_EMP_MOBILE using p_sms_to TYPE sy-uname
                     CHANGING mob_no TYPE zmob_no.

*employee's Mobile Number: to be fetched from PA9205
   DATA: max_begda type PA9205-BEGDA,
         l_zphone TYPE PA9205-ZPHONE.

   DATA: l_sms_to  TYPE pernr_d.

   if p_sms_to+0(3) = 'CAB' or p_sms_to+0(3) = 'CMM'.  "Coreteam members
     select single pernr from ZMM_CORETEAM
       into l_sms_to
         where uname = p_sms_to.
     if sy-subrc <> 0.
       message id 'ZMSG' type 'E' number '000' with 'USER ID' p_sms_to text-001 .
     endif.

   else.  " cpf user
     l_sms_to = p_sms_to.

   endif.

   select max( begda )
     from PA9205
       into max_begda
         where PERNR = l_sms_to  "pernr ~ user id
           and SUBTY = '01'
           and ENDDA = '99991231'.

   SELECT ZPHONE
 FROM PA9205 INTO L_ZPHONE UP TO 1 ROWS WHERE PERNR = L_SMS_TO AND SUBTY = '01' AND ENDDA => '99991231' AND BEGDA = MAX_BEGDA
 ORDER BY PRIMARY KEY .
 ENDSELECT.

   SHIFT l_zphone LEFT DELETING LEADING '0'.
   if MOB_NO is NOT INITIAL.
     CONCATENATE '91' l_zphone INTO  MOB_NO.
   endif.

 ENDFORM.                    " GET_EMP_MOBILE
*&---------------------------------------------------------------------*
*&      Form  GET_DIRS_PA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_NMBLKCDHD_ID_DIRECTOR  text
*      <--P_L_ID_DIRS_PA  text
*----------------------------------------------------------------------*
 FORM GET_DIRS_PA  USING    P_ID_DIRECTOR type ZMM_NMBLKCDHD-ID_DIRECTOR
                   CHANGING P_ID_DIRS_PA type ZMMNM_DIR_PA-ID_PA.

   select single ID_PA
     from ZMMNM_DIR_PA
       INTO P_ID_DIRS_PA
         where ID_DIRECTOR = P_ID_DIRECTOR.

 ENDFORM.                    " GET_DIRS_PA
*&---------------------------------------------------------------------*
*&      Form  SHOW_PROCESS_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_PROCESS_HELP .
   clear g_att_files_wa.
   g_att_files_wa-LOGSYS = 'MMNM_PG'.
   g_att_files_wa-objtype = 'ATT'.
   g_att_files_wa-objkey = '01'.


*   refresh exclude_tab[].
*   MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.

   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
     EXPORTING
       APPLICATION_OBJECT = g_att_files_wa
     TABLES
       FUNC_EXCLUDE       = EXCLUDE_TAB.

 ENDFORM.                    " SHOW_PROCESS_HELP
*&---------------------------------------------------------------------*
*&      Form  SHOW_NAME_CREATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_NAME_CREATOR .

   CLEAR NAME1.

   IF zmm_nmblkcdhd_st-ID_CREATOR IS NOT INITIAL.

*if zmm_nmblkcdhd_st-ID_CREATOR = 'CAB_ALOK'.
*   zmm_nmblkcdhd_st-ID_CREATOR = '77783'.
*endif.

     SELECT SINGLE ENAME FROM PA0001 INTO NAME1
       WHERE PERNR = zmm_nmblkcdhd_st-ID_CREATOR . "G_USER_PERNR.

*if zmm_nmblkcdhd_st-ID_CREATOR = '77783'.
*   zmm_nmblkcdhd_st-ID_CREATOR = 'CAB_ALOK'.
*endif.

   ENDIF.

 ENDFORM.                    " SHOW_NAME_CREATOR
*&---------------------------------------------------------------------*
*&      Form  SHOW_NAME_INCHARGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_NAME_INCHARGE .


   IF g_mode = 'DIS'.

     data: L_ENAME TYPE PA0001-ENAME.
     refresh g_list_inc.
     CLEAR g_value_inc.

     if ZMM_NMBLKCDHD_ST-ID_INCHARGE is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_INCHARGE
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_INCHARGE.
       concatenate ZMM_NMBLKCDHD_ST-ID_INCHARGE '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_INCHARGE'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.


     if ZMM_NMBLKCDHD_ST-ID_L2 is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_L2
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_L2.
       concatenate ZMM_NMBLKCDHD_ST-ID_L2 '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_L2'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.

     if ZMM_NMBLKCDHD_ST-ID_L1 is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_L1
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_L1.
       concatenate ZMM_NMBLKCDHD_ST-ID_L1 '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_L1'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.


     if ZMM_NMBLKCDHD_ST-ID_DIRECTOR is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_DIRECTOR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_DIRECTOR.
       concatenate ZMM_NMBLKCDHD_ST-ID_DIRECTOR '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.


   ENDIF.
 ENDFORM.                    " SHOW_NAME_INCHARGE
*&---------------------------------------------------------------------*
*&      Form  SHOW_PLANT_STK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_PLANT_STK .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks.

   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = zmm_NMBLKCDHD_st-werks.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.

 ENDFORM.                    " SHOW_PLANT_STK
*&---------------------------------------------------------------------*
*&      Form  SHOW_ONGC_STK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_ONGC_STK .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks.

   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = ''.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.

 ENDFORM.                    " SHOW_ONGC_STK
*&---------------------------------------------------------------------*
*&      Form  SHOW_PLANT_CONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_PLANT_CONS .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks.

   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = zmm_NMBLKCDHD_st-werks.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MC.9' AND SKIP FIRST SCREEN.

 ENDFORM.                    " SHOW_PLANT_CONS
*&---------------------------------------------------------------------*
*&      Form  SHOW_ONGC_CONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_ONGC_CONS .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks,
          l_slv type SELVS.

*BREAK cab_alok.
   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = ''.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MC.9' AND SKIP FIRST SCREEN.
 ENDFORM.                    " SHOW_ONGC_CONS

*--- INCLUDE: MZMM_NONMOVI01 ---*
***INCLUDE MZMM_NONMOVI01 .
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
      g_mode = 'CRE'.
      CLEAR ok_code100.
    WHEN 'CHANGE'.
      g_mode = 'CHA'.
      CLEAR ok_code100.
    WHEN 'DISPLAY'.
      g_mode = 'DIS'.
      CLEAR ok_code100.
    WHEN 'DELETE'.
      g_mode = 'DEL'.
      CLEAR ok_code100.
****    WHEN 'RELEASE'.       " displays SUBMIT button in GUI Status. Discarded. SAVE & RELEASE Merged
****      g_mode = 'REL'.
****      CLEAR ok_code100.
    WHEN 'PROCGUIDE'.
      PERFORM SHOW_PROCESS_HELP.
      CLEAR ok_code100.
    WHEN 'SAV'.   " SAV/RELEASE for Creator
      PERFORM save_request.
      if flag_dont_clear = 'X'.
         flag_dont_clear = ''.  " restore the flag
      else.
        PERFORM clear_var.
      endif.
      CLEAR ok_code100.
    WHEN 'CORRES'.
      CLEAR ok_code100.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
    WHEN 'REPORT'.
      clear ok_code100.
      SUBMIT ZMM_MAT_NMCODES VIA SELECTION-SCREEN AND RETURN.

**" discarded:  WHEN 'SUBMIT'.   " by requisitioner to L3/L4  "  Save & Release screens now Merged.
**      clear ok_code100.
**      perform validate_reqno.
**      perform submit_request.

   WHEN 'SAVL3L4' OR 'SAVL2' OR 'SAVL1L2' OR 'SAVDIR'.
      perform SAVE_DATA.
      clear ok_code100.
*      PERFORM clear_var.
*      leave to SCREEN 0.

   WHEN 'RELL3L4' OR 'RELL2' OR 'RELL1L2'.       " 'RELL1L2': now for L1 only .
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
**** Row Status: clear STATUS_AT_REVERSAL to release control on query-reply communication.
**        if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ZMM_NMBLKCDHD_ST-NM_STATUS.
**           ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''.
**        endif.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'REJL3L4' OR  'REJL2' OR 'REJL1L2' OR 'REJDIR'.         "  'REJL1L2': now for L1 only .
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'REVL3L4' OR 'REVL2' OR 'REVL1L2' OR 'REVDIR'..           " 'REVL1L2' : now for L1 only .
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
**    Row Status: Save current status as STATUS_AT_REVERSAL to control
*        query-reply communication.
        if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''.
           ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ZMM_NMBLKCDHD_ST-NM_STATUS.
        endif.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'APPRDIR'.
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'KEEP'.
      PERFORM KEEP_IN_INBOX. "keep the workitem in the inbox, decide later
      PERFORM clear_var.
      leave to SCREEN 0.

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
  IF ( g_mode = 'CRE' ) OR
    ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).


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


*        if zmm_nmblkcdhd_st-ID_CREATOR is INITIAL.
        if l_hd_reqno-ID_CREATOR is INITIAL and l_hd_reqno-REQCPF is NOT INITIAL.
            MESSAGE e237(zmm_oth). "Pls input a request no. created thro' tcode ZMMNMREQ only.
        endif.


    IF l_hd_reqno-id_creator <> sy-uname.
      MESSAGE e096(zmm_oth) WITH l_hd_reqno-id_creator.
    ENDIF.

** Check: Only 'NEW' request can be changed
    IF l_hd_reqno-nm_status <> 'NEW'.

      MESSAGE e201(zmm_oth) WITH l_hd_reqno-nm_status. "Request is not with the creator(Current Status: &).
    ENDIF.



****  ELSEIF g_mode = 'REL'.
****    CLEAR l_hd_reqno.
****    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
****          WHERE reqno = zmm_nmblkcdhd_st-reqno.
****    IF sy-subrc = 0.
****
******* Check for deletion.
****    IF l_hd_reqno-lvorm = 'X'.
****      MESSAGE i087(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
****      LEAVE TO SCREEN 100.
****    ENDIF.
****
****    IF l_hd_reqno-id_creator <> sy-uname.
****      MESSAGE e096(zmm_oth) WITH l_hd_reqno-id_creator.
****    ENDIF.
****
****
****** Check: Only 'NEW' request can be changed
****    IF l_hd_reqno-nm_status <> 'NEW'.
****      MESSAGE e201(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
****    ENDIF.
****    ENDIF.

  ENDIF.

ENDMODULE.                 " check_reqno  INPUT


********************&---------------------------------------------------------------------*
********************&      Module  check_plant  INPUT
********************&---------------------------------------------------------------------*
********************       text
********************----------------------------------------------------------------------*
*******************MODULE check_plant INPUT.
*******************  DATA : l_werks LIKE t001w-werks.
*******************  IF NOT zmm_nmblkcdhd_st-werks IS INITIAL.
*******************    SELECT SINGLE werks INTO l_werks FROM t001w
*******************           WHERE werks = zmm_nmblkcdhd_st-werks.
*******************    IF sy-subrc <> 0.
*******************      MESSAGE e033(zmm_oth).
*******************    ENDIF.
*******************  ENDIF.
*******************ENDMODULE.                 " check_plant  INPUT


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


*****************************&---------------------------------------------------------------------*
*****************************&      Module  show_user  INPUT
*****************************&---------------------------------------------------------------------*
*****************************       text
*****************************----------------------------------------------------------------------*
****************************MODULE show_user INPUT.
****************************  DATA: l_user LIKE soud3,
****************************        l_userfld(40) type c.
****************************  Clear: l_user, l_userfld.
****************************
****************************  get cursor field l_userfld.
****************************
****************************  case l_userfld.
****************************    when 'ZMM_NMBLKCDHD_ST-REQCPF'.
****************************      l_user = zmm_nmblkcdhd_st-reqcpf.
****************************    when 'ZMM_NMBLKCDHD_ST-RELBY'.
****************************      l_user = zmm_nmblkcdhd_st-relby.
****************************    when 'ZMM_NMBLKCDHD_ST-APPBY'.
****************************      l_user = zmm_nmblkcdhd_st-appby.
****************************  endcase.
****************************  CALL FUNCTION 'SO_ADDRESS_SHOW'
****************************       EXPORTING
****************************            user                       = l_user
****************************       EXCEPTIONS
****************************            parameter_error            = 1
****************************            user_not_exist             = 2
****************************            x_error                    = 3
****************************            operation_no_authorization = 4
****************************            OTHERS                     = 5.
****************************
****************************  IF sy-subrc <> 0.
***************************** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*****************************         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
****************************  ENDIF.
****************************
****************************ENDMODULE.                 " show_user  INPUT


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
    MESSAGE e221(zmm_oth).
  ENDIF.
** mat description
  SELECT MAKTX
 FROM MAKT INTO ZMM_NMBLKCDDT-MATDESC UP TO 1 ROWS WHERE MATNR = ZMM_NMBLKCDDT-MATCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
** mat unit
  SELECT SINGLE meins
    FROM mara
      INTO zmm_nmblkcddt-uom
        WHERE matnr = zmm_nmblkcddt-matcode.

***Check for the same code in other requests (hold)


ENDMODULE.                 " get_details  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  if OK_CODE100 = 'CLK_WERKS' or OK_CODE100 = 'CLK_EKGRP' . " Plant or Purchase Grp has been changes
** Issue: when plant and purchase grp change, old values in appr chain (Drop-down)
** remains on the screen. clear it.
    FLAG_CLEAR_OLD_APPR_CHAIN = 'X'.
    clear OK_CODE100.
  elseif OK_CODE100 = 'CLK_DECISION'.
    FLAG_CLEAR_OLD_STATUS = 'X'.
    clear OK_CODE100.
  else.
    PERFORM confirm_exit.
  endif.
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
*&      Module  SHOW_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
***MODULE SHOW_NAME_CREATOR INPUT.
***
***PERFORM SHOW_NAME_CREATOR.
***
***
***ENDMODULE.                 " SHOW_NAME  INPUT


*&---------------------------------------------------------------------*
*&      Module  LOV_WERKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_PLANT INPUT.
refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'AGR_NAME'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_NMBLKCDHD_ST-WERKS'
      value_org       = 'S'
    tables
      value_tab       = ist_plant
      field_tab       = ist_field
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_dynpfld_mapping
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ZMM_NMBLKCDHD_ST-WERKS = ist_return_tab-fieldval.

ENDMODULE.                 " LOV_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_PGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_PGRP INPUT.
refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'EKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_NMBLKCDHD_ST-EKGRP'
      value_org       = 'S'
    tables
      value_tab       = ist_pgrp
      field_tab       = ist_field
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_dynpfld_mapping
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ZMM_NMBLKCDHD_ST-EKGRP = ist_return_tab-fieldval.
ENDMODULE.                 " LOV_PGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_ICON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ICON INPUT.

**    Row Status : set icon as per decision
*type-pools: icon.
*@0A@ - Red light
*@08@ - Green light
*@09@ - Yellow light
*ICON_GREEN_LIGHT/ICON_YELLOW_LIGHT/ICON_RED_LIGHT

  IF ZMM_NMBLKCDDT-DECISION = 'REJECT'.
    write ICON_RED_LIGHT as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = 'ACCEPT'..
    write ICON_GREEN_LIGHT as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = 'QUERY'.
    write ICON_YELLOW_LIGHT as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = 'REPLY'.
    write ICON_ENVELOPE_CLOSED as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = '' .
    write ICON_LED_INACTIVE as ICON to ZMM_NMBLKCDDT-ICON.
  ENDIF.


ENDMODULE.                 " SET_ICON  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_STATUS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS INPUT.
** moved: now at the time of saving of details
*  IF ZMM_NMBLKCDDT-DECISION = 'REJECT'.
*     ZMM_NMBLKCDDT-STATUS = 'REJECTED'.
*  ELSEIF ZMM_NMBLKCDDT-DECISION = 'ACCEPT'.
*     ZMM_NMBLKCDDT-STATUS = 'ACCEPTED'.
*  ELSEIF ZMM_NMBLKCDDT-DECISION = ''.
*     ZMM_NMBLKCDDT-STATUS = ''.
*  ENDIF.



ENDMODULE.                 " SET_STATUS  INPUT

*******&---------------------------------------------------------------------*
*******&      Module  LOV_L2  INPUT
*******&---------------------------------------------------------------------*
*******       text
*******----------------------------------------------------------------------*
******MODULE LOV_L2 INPUT.
******refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
******  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .
******
******clear: L_ROLE1 ,
******       L_ROLE2 ,
******       L_ROLE3 .
******
******data: IST_L2 type TABLE OF ty_user.
******
******CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
******
******   select A~uname
******     into CORRESPONDING FIELDS OF TABLE IST_L2
******       from ( agr_users as A
******              INNER JOIN  agr_users as B on B~uname = A~uname )
******       where A~agr_name = L_ROLE1
******             and B~agr_name = 'D:MM_PUR_PO_APPROVE_L2'
******             and A~from_dat <=   sy-datum
******             and A~to_dat >=  sy-datum.
******
******  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
******    exporting
******      retfield        = 'uname'
******      dynpprog        = sy-cprog
******      dynpnr          = sy-dynnr
******      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L2'
******      value_org       = 'S'
******    tables
******      value_tab       = IST_L2
******      field_tab       = ist_field
******      return_tab      = ist_return_tab
******      dynpfld_mapping = ist_dynpfld_mapping
******    exceptions
******      parameter_error = 1
******      no_values_found = 2
******      others          = 3.
******  if sy-subrc <> 0.
******    message id sy-msgid type sy-msgty number sy-msgno
******            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
******  endif.
******
******  ZMM_NMBLKCDHD_ST-ID_L2 = ist_return_tab-fieldval.
******
******
******
******ENDMODULE.                 " LOV_L2  INPUT
******
*******&---------------------------------------------------------------------*
*******&      Module  LOV_L1  INPUT
*******&---------------------------------------------------------------------*
*******       text
*******----------------------------------------------------------------------*
******MODULE LOV_L1 INPUT.
******refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
******  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .
******
******clear: L_ROLE1 ,
******       L_ROLE2 ,
******       L_ROLE3 .
******
******data: IST_L1 type TABLE OF ty_user.
******
******CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
******
******   select A~uname
******     into CORRESPONDING FIELDS OF TABLE IST_L1
******       from ( agr_users as A
******              INNER JOIN  agr_users as B on B~uname = A~uname )
******       where A~agr_name = L_ROLE1
******             and B~agr_name = 'D:MM_PUR_PO_APPROVE_L1'
******             and A~from_dat <=   sy-datum
******             and A~to_dat >=  sy-datum.
******
******  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
******    exporting
******      retfield        = 'uname'
******      dynpprog        = sy-cprog
******      dynpnr          = sy-dynnr
******      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L1'
******      value_org       = 'S'
******    tables
******      value_tab       = IST_L1
******      field_tab       = ist_field
******      return_tab      = ist_return_tab
******      dynpfld_mapping = ist_dynpfld_mapping
******    exceptions
******      parameter_error = 1
******      no_values_found = 2
******      others          = 3.
******  if sy-subrc <> 0.
******    message id sy-msgid type sy-msgty number sy-msgno
******            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
******  endif.
******
******  ZMM_NMBLKCDHD_ST-ID_L1 = ist_return_tab-fieldval.
******
******
******
******ENDMODULE.                 " LOV_L2  INPUT
******
*******&---------------------------------------------------------------------*
*******&      Module  LOV_DIR  INPUT
*******&---------------------------------------------------------------------*
*******       text
*******----------------------------------------------------------------------*
******MODULE LOV_DIR INPUT.
******refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
******  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .
******
******clear: L_ROLE1 ,
******       L_ROLE2 ,
******       L_ROLE3 .
******
******data: IST_DIR type TABLE OF ty_user.
******
*******CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*******   select A~uname
*******     into CORRESPONDING FIELDS OF TABLE IST_DIR
*******       from ( agr_users as A
*******              INNER JOIN  agr_users as B on B~uname = A~uname )
*******       where A~agr_name = L_ROLE1
*******             and B~agr_name = 'D:MM_SRV_IND_APPROVE_DI'
*******             and A~from_dat <=   sy-datum
*******             and A~to_dat >=  sy-datum.
******
******   select uname
******     into CORRESPONDING FIELDS OF TABLE IST_DIR
******       from agr_users
******       where agr_name = 'D:MM_SRV_IND_APPROVE_DI'
******             and from_dat <=   sy-datum
******             and to_dat >=  sy-datum.
******
******  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
******    exporting
******      retfield        = 'uname'
******      dynpprog        = sy-cprog
******      dynpnr          = sy-dynnr
******      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
******      value_org       = 'S'
******    tables
******      value_tab       = IST_DIR
******      field_tab       = ist_field
******      return_tab      = ist_return_tab
******      dynpfld_mapping = ist_dynpfld_mapping
******    exceptions
******      parameter_error = 1
******      no_values_found = 2
******      others          = 3.
******  if sy-subrc <> 0.
******    message id sy-msgid type sy-msgty number sy-msgno
******            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
******  endif.
******
******  ZMM_NMBLKCDHD_ST-ID_DIRECTOR = ist_return_tab-fieldval.
******
******
******
******ENDMODULE.                 " LOV_L2  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_RES_NM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_RES_NM INPUT.
refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

data: IST_ZMM_NM_REASONS type TABLE OF ZMM_NM_REASONS.

   select RES_NM
     into CORRESPONDING FIELDS OF TABLE IST_ZMM_NM_REASONS
       from ZMM_NM_REASONS.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'RES_NM'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_NMBLKCDDT-RES_NM'
      value_org       = 'S'
    tables
      value_tab       = IST_ZMM_NM_REASONS
      field_tab       = ist_field
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_dynpfld_mapping
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ZMM_NMBLKCDDT-RES_NM = ist_return_tab-fieldval.


ENDMODULE.                 " LOV_RES_NM  INPUT


*&---------------------------------------------------------------------*
*&      Module  LOV_INCHARGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_INCHARGE INPUT.

    PERFORM LOV_INCHARGE .

ENDMODULE.                 " LOV_INCHARGE  INPUT


MODULE LOV_L2 INPUT.

    PERFORM LOV_L2 .

ENDMODULE.                 " LOV_L2 INPUT

MODULE LOV_L1 INPUT.

    PERFORM LOV_L1 .

ENDMODULE.                 " LOV_L1  INPUT

MODULE LOV_DIR INPUT.

    PERFORM LOV_DIR .

ENDMODULE.                 " LOV_DIR  INPUT

*&---------------------------------------------------------------------*
*&      Module  CLEAR_OLD_VRM_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_OLD_APPR_CHAIN INPUT.

  PERFORM CLEAR_OLD_APPR_CHAIN.

ENDMODULE.                 " CLEAR_OLD_APPR_CHAIN  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_PLANT_STK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_PLANT_STK INPUT.
  PERFORM SHOW_PLANT_STK.

ENDMODULE.                 " SHOW_PLANT_STK  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_ONGC_STK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_ONGC_STK INPUT.
  PERFORM SHOW_ONGC_STK.

ENDMODULE.                 " SHOW_ONGC_STK  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_PLANT_CONS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_PLANT_CONS INPUT.
  PERFORM SHOW_PLANT_CONS.
ENDMODULE.                 " SHOW_PLANT_CONS  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_ONGC_CONS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_ONGC_CONS INPUT.
  PERFORM SHOW_ONGC_CONS.
ENDMODULE.                 " SHOW_ONGC_CONS  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_DECISION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_DECISION INPUT.
** make Lov as per the level and STATUS_AT_REVERSAL

 DATA: g_t_id TYPE vrm_id,
       g_t_list TYPE vrm_values,
       g_t_value LIKE LINE OF g_t_list.


 Types: begin of ty_decision ,
         Decision type ZNM_DECISION ,
         end of ty_decision .
 data: ist_decision type table of ty_decision,
       wa_decision type ty_decision.

 Refresh: ist_decision ,g_t_list.
 CLEAR: wa_decision, g_t_list.

 IF sy-tcode = 'ZMMNMREQ'.
   wa_decision-decision = 'REJECT'.
   append wa_decision to ist_decision.
   wa_decision-decision = 'REPLY'.
   append wa_decision to ist_decision.
  ELSEIF  sy-tcode = 'ZMMNMWF2'
       or sy-tcode = 'ZMMNMWF3'
          or sy-tcode = 'ZMMNMWFL2'.

    if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''. " fresh request
      wa_decision-decision = 'ACCEPT'.
      append wa_decision to ist_decision.
    else.                                        " reverted request
      wa_decision-decision = 'REPLY'.
      append wa_decision to ist_decision.
    endif.
      wa_decision-decision = 'REJECT'.
      append wa_decision to ist_decision.
      wa_decision-decision = 'QUERY'.
      append wa_decision to ist_decision.

  ELSEIF sy-tcode = 'ZMMNMWF4'.
    wa_decision-decision = 'ACCEPT'.
    append wa_decision to ist_decision.
    wa_decision-decision = 'REJECT'.
    append wa_decision to ist_decision.
    wa_decision-decision = 'QUERY'.
    append wa_decision to ist_decision.
  endif.

  Loop at ist_decision into wa_decision .
    CLEAR g_t_value.
    g_t_value-key  = wa_decision-decision.
    APPEND g_t_value TO g_t_list.
  Endloop.

  g_t_id = 'ZMM_NMBLKCDDT-DECISION'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_t_id
      values = g_t_list.

ENDMODULE.                 " LOV_DECISION  INPUT

*--- INCLUDE: MZMM_NONMOVO01 ---*
*** include MZMM_NONMOVO01
*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tct100_init OUTPUT.
  IF g_tct100_copied IS INITIAL.
*&spwizard: copy ddic-table 'ZMM_NMBLKCDDT'
*&spwizard: into internal table 'g_TCT100_itab

** get non-rejected rows from table for all modes except new request creation by user.
    IF g_mode <> 'CRE'.
      SELECT * FROM zmm_nmblkcddt
         INTO CORRESPONDING FIELDS
         OF TABLE g_tct100_itab
      where reqno = zmm_nmblkcdhd_st-reqno
        and ( status = 'ACCEPTED' or status = '' or status = 'REPLY' or status = 'QUERY' )  " ROW STATUS
        .
    ENDIF.
    g_tct100_copied = 'X'.
    REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
  ENDIF.


  sort g_tct100_itab ascending by matcode descending srno.
  delete adjacent duplicates from g_tct100_itab comparing matcode.
  sort g_tct100_itab ascending by srno.
ENDMODULE.

*&spwizard: output module for tc 'TCT100'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tct100_SRNO_STOCK_CONSMP OUTPUT.
** SR NO., Stock and Consumption figures
*  BREAK cab_alok.

  DATA : l_srno TYPE i,
         l_labst LIKE mard-labst,
         l_spmon like s034-spmon,
         l_mm(2) type n,
         l_yy(4) type n.
**1. Sr. No.
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


**2. Plant Stock
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( labst ) FROM mard INTO g_tct100_wa-plant_stk
        WHERE werks = zmm_nmblkcdhd_st-werks
          AND   matnr = g_tct100_wa-matcode.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING plant_stk.
    ENDIF.
**3. ONGC Stock
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( labst ) FROM mard INTO g_tct100_wa-ongc_stk
      WHERE matnr = g_tct100_wa-matcode.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING ongc_stk.
    ENDIF.
**4. Plant Consumption
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

**5. ONGC Consumption *************
    IF NOT g_tct100_wa-matcode IS INITIAL.
      SELECT SUM( cmgvbr ) FROM s034 INTO g_tct100_wa-ongc_cons
        WHERE matnr = g_tct100_wa-matcode
        and   spmon GE l_spmon.
      MODIFY g_tct100_itab FROM g_tct100_wa
      INDEX tct100-current_line TRANSPORTING ongc_cons.
    ENDIF.
  ENDIF.               "CRE or CHA

** Consumption figures: to be calculated dynamically
*get current financial year start and end dates
  data: G_FISCAL_YEAR(4),
        G_FISCAL_YEAR_NUMC  LIKE  T009B-BDATJ.
  DATA: G_first_day_fy TYPE sy-datum,
        G_last_day_fy TYPE sy-datum,
        G_DATE TYPE sy-datum.

  if ZMM_NMBLKCDHD_ST-NM_STATUS = ''. " document is being created
    G_DATE = sy-datum.
  else.                               " Existing document
    G_DATE = ZMM_NMBLKCDHD_ST-DOC_DATE.
  endif.

  CALL FUNCTION 'ZGM_GET_FISCAL_YEAR'
    EXPORTING
      I_DATE = G_DATE
      I_FYV  = 'V3'
    IMPORTING
      E_FY   = G_FISCAL_YEAR.

  move G_FISCAL_YEAR to G_FISCAL_YEAR_NUMC.

  CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
    EXPORTING
      i_gjahr        = G_FISCAL_YEAR_NUMC
      i_periv        = 'V3'
    IMPORTING
      e_first_day    = G_first_day_fy
      e_last_day     = G_last_day_fy
    EXCEPTIONS
      INPUT_FALSE    = 1
      T009_NOTFOUND  = 2
      T009B_NOTFOUND = 3
      OTHERS         = 4.


**6. Total Current financial year consumption at ONGC : CY_CONS_ONGC

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT SUM( MGVBR )
      FROM s033
      INTO g_tct100_wa-CY_CONS_ONGC
      WHERE matnr = g_tct100_wa-matcode
        and SPTAG BETWEEN G_first_day_fy AND  G_last_day_fy.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_ONGC.
  ENDIF.



*New Logic 19.05.2014 revised
*  IF  g_tct100_wa-matcode IS NOT INITIAL.
*    SELECT SUM( MENGE )
*      FROM MSEG
*      INTO g_tct100_wa-CY_CONS_ONGC
*      WHERE matnr = g_tct100_wa-matcode
*        and BWART in ('201' , '221' , '241' , '261')
*        and GJAHR = G_FISCAL_YEAR_NUMC.
*
*    MODIFY g_tct100_itab FROM g_tct100_wa
*    INDEX tct100-current_line TRANSPORTING CY_CONS_ONGC.
*  ENDIF.

**7. total Current financial year consumption at plant : CY_CONS_PLANT

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT SUM( MGVBR )
      FROM s033
        INTO g_tct100_wa-CY_CONS_PLANT
          WHERE SPTAG BETWEEN G_first_day_fy AND  G_last_day_fy
            and werks = ZMM_NMBLKCDHD_ST-WERKS
            and matnr = g_tct100_wa-matcode
                .
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.
  ENDIF.

*New Logic 19.05.2014 revised
*  IF  g_tct100_wa-matcode IS NOT INITIAL.
*    SELECT SUM( MENGE )
*      FROM MSEG
*      INTO g_tct100_wa-CY_CONS_PLANT
*      WHERE matnr = g_tct100_wa-matcode
*        and werks = ZMM_NMBLKCDHD_ST-WERKS
*        and BWART in ('201' , '221' , '241' , '261')
*        and GJAHR = G_FISCAL_YEAR_NUMC.
*
*    MODIFY g_tct100_itab FROM g_tct100_wa
*    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.
*  ENDIF.

**8. Last cons. date in CY across ONGC : CY_CONS_DATE_ONGC 19.05.2014
  data: L_MAX_MBLNR_ONGC TYPE  MSEG-MBLNR.

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT MAX( MBLNR )
      FROM MSEG
      INTO L_MAX_MBLNR_ONGC
      WHERE matnr = g_tct100_wa-matcode
        and BWART in ('201' , '221' , '241' , '261')
        and GJAHR = G_FISCAL_YEAR_NUMC.

    if L_MAX_MBLNR_ONGC is NOT INITIAL.
      SELECT BUDAT
 FROM MKPF INTO G_TCT100_WA-CY_CONS_DATE_ONGC UP TO 1 ROWS WHERE MBLNR = L_MAX_MBLNR_ONGC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.
    IF g_tct100_wa-CY_CONS_ONGC is INITIAL.
      CLEAR g_tct100_wa-CY_CONS_DATE_ONGC.
    ENDIF.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_DATE_ONGC.
  ENDIF.

**9. Last cons. date in CY in Plant : CY_CONS_DATE_PLANT 19.05.2014
  data: L_MAX_MBLNR_PLANT TYPE  MSEG-MBLNR.

  IF  g_tct100_wa-matcode IS NOT INITIAL.
    SELECT MAX( MBLNR )
      FROM MSEG
      INTO L_MAX_MBLNR_PLANT
      WHERE matnr = g_tct100_wa-matcode
        and werks = ZMM_NMBLKCDHD_ST-WERKS
        and BWART in ('201' , '221' , '241' , '261')
        and GJAHR = G_FISCAL_YEAR_NUMC.

    if L_MAX_MBLNR_PLANT is NOT INITIAL.
      SELECT BUDAT
 FROM MKPF INTO G_TCT100_WA-CY_CONS_DATE_PLANT UP TO 1 ROWS WHERE MBLNR = L_MAX_MBLNR_PLANT
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.
    IF g_tct100_wa-CY_CONS_PLANT is  INITIAL.
      CLEAR g_tct100_wa-CY_CONS_DATE_PLANT.
    ENDIF.

    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING CY_CONS_DATE_PLANT.
  ENDIF.

*======================================================================
**10. Last consumption (in Previous FY) across ONGC  :  LAST_CONS_ONGC
**11. last consumption date (in Previous FY) across ONGC  :  LAST_CONS_DATE_ONGC

** Commented 19.05.2014
**  IF  g_tct100_wa-matcode IS NOT INITIAL.
***   first find last consumption date (in Previous FY) at ONGC
**
**    SELECT max( LETZTVER )
**      FROM s032
**        INTO g_tct100_wa-LAST_CONS_DATE_ONGC
**          WHERE matnr = g_tct100_wa-matcode
**                and LETZTVER < G_first_day_fy.
**
***   now find Last consumption (in Previous FY) at ONGC
**
**    if g_tct100_wa-LAST_CONS_DATE_ONGC is NOT INITIAL.
**      SELECT single MGVBR
**        FROM s033
**          INTO g_tct100_wa-LAST_CONS_ONGC
**            WHERE SPTAG = g_tct100_wa-LAST_CONS_DATE_ONGC
**              and matnr = g_tct100_wa-matcode.
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.  ####
**  ENDIF.

** Commented 03.06.2014
***new logic: ONGC
***G_first_day_fy  20140401
**
**  data: G_first_Mon_fy TYPE S031-SPMON.
**  Data: G_MAX_SPMON type S031-SPMON.
**  data: G_MAX_SPMON_MONTH type FCMNR,
**        G_MAX_SPMON_YEAR type GJAHR.
**  Data: G_SPMON_BEGIN type DATUM.                           "20130601
**  Data: G_SPMON_END type DATUM.                             "20130601
**  data: G_MAX_SPTAG TYPE  DATUM.
**  data: G_SUM_MGVBR TYPE S033-MGVBR.
**
**  clear: G_first_Mon_fy, G_MAX_SPMON.
**  IF  g_tct100_wa-matcode IS NOT INITIAL.
**    G_first_Mon_fy = G_first_day_fy+0(6).
**
***S031
**    SELECT max( SPMON )
**      FROM S031
**        INTO G_MAX_SPMON                                    "201206
**          WHERE SPMON < G_first_Mon_fy
**            and matnr = g_tct100_wa-matcode
**            and MGVBR > 0.
**
**    CLEAR: G_MAX_SPMON_MONTH, G_MAX_SPMON_YEAR.
***I_MONTH  06
***I_YEAR    2013
**    G_MAX_SPMON_MONTH = G_MAX_SPMON+4(2).
**    G_MAX_SPMON_YEAR  = G_MAX_SPMON+0(4).
**
**    CLEAR: G_SPMON_BEGIN, G_SPMON_END.
**
**    CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
**      EXPORTING
**        I_MONTH     = G_MAX_SPMON_MONTH
**        I_YEAR      = G_MAX_SPMON_YEAR
***       I_DATE      =
**      IMPORTING
**        E_FIRST_DAY = G_SPMON_BEGIN
**        E_LAST_DAY  = G_SPMON_END
**      EXCEPTIONS
**        WRONG_DATE  = 1
**        OTHERS      = 2.
**    IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**    ENDIF.
**
***S033
**    clear: G_MAX_SPTAG.
**    SELECT max( SPTAG )
**      FROM S033
**        INTO G_MAX_SPTAG             "
**          WHERE matnr = g_tct100_wa-matcode
**            and SPTAG BETWEEN G_SPMON_BEGIN AND G_SPMON_END
**            and MGVBR > 0.
**
*** Last date of consumption(Prev. yrs): LAST_CONS_DATE_ONGC
**    g_tct100_wa-LAST_CONS_DATE_ONGC =  G_MAX_SPTAG.
**
*** LAST_CONS_ONGC
***Last consumption = sum(MGVBR) for Last date of consumption.
**    if g_tct100_wa-LAST_CONS_DATE_ONGC is NOT INITIAL.
**      clear: G_SUM_MGVBR.
**      SELECT SUM( MGVBR )
**        FROM S033
**          INTO G_SUM_MGVBR
**            WHERE matnr = g_tct100_wa-matcode
**              and SPTAG = g_tct100_wa-LAST_CONS_DATE_ONGC
**              and MGVBR > 0.
**      g_tct100_wa-LAST_CONS_ONGC = G_SUM_MGVBR  .
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**      INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_ONGC LAST_CONS_ONGC .
**  ENDIF.

** 03.06.2014
*------------------------------
***  data: L_MAX_MBLNR_ONGC_PY TYPE  MSEG-MBLNR.
***
***  IF  g_tct100_wa-matcode IS NOT INITIAL.
***    SELECT MAX( MBLNR )
***      FROM MSEG
***      INTO L_MAX_MBLNR_ONGC_PY
***      WHERE matnr = g_tct100_wa-matcode
***        and BWART  in ('201' , '221' , '241' , '261')
***        and GJAHR <> G_FISCAL_YEAR_NUMC.
***
***    if L_MAX_MBLNR_ONGC_PY is NOT INITIAL.
***      SELECT SINGLE MENGE              "Last consumption (in Previous FY) across ONGC
***        FROM MSEG
***          INTO g_tct100_wa-LAST_CONS_ONGC
***            WHERE MBLNR = L_MAX_MBLNR_ONGC_PY.
***
***      select single BUDAT              "last consumption date (in Previous FY) across ONGC
***        from MKPF
***          INTO g_tct100_wa-LAST_CONS_DATE_ONGC
***            WHERE MBLNR = L_MAX_MBLNR_ONGC_PY.
***    endif.
***
***    IF g_tct100_wa-LAST_CONS_ONGC is INITIAL.
***      CLEAR g_tct100_wa-LAST_CONS_DATE_ONGC.
***    ENDIF.
***    MODIFY g_tct100_itab FROM g_tct100_wa
***    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_ONGC LAST_CONS_ONGC .
***  ENDIF.
*------------------------------
** 06.06.2014
    DATA: L_MATNR_I TYPE WB2_V_MKPF_MSEG2-MATNR_I,
           L_MAX_BUDAT TYPE WB2_V_MKPF_MSEG2-BUDAT,
           L_MENGE_I TYPE WB2_V_MKPF_MSEG2-MENGE_I,
           L_MBLNR TYPE WB2_V_MKPF_MSEG2-MBLNR.
  IF  g_tct100_wa-matcode IS NOT INITIAL.

    select MAX( BUDAT )
      from WB2_V_MKPF_MSEG2
        into (L_MAX_BUDAT)
          where BWART_I  in ('201' , '221' , '241' , '261')
            and MATNR_I = g_tct100_wa-matcode
            and GJAHR_I <> G_FISCAL_YEAR_NUMC.

     g_tct100_wa-LAST_CONS_DATE_ONGC = L_MAX_BUDAT.

    if L_MAX_BUDAT is NOT INITIAL.
      SELECT MENGE_I
 FROM WB2_V_MKPF_MSEG2 INTO G_TCT100_WA-LAST_CONS_ONGC UP TO 1 ROWS WHERE BWART_I IN ( '201' , '221' , '241' , '261' ) AND MATNR_I = G_TCT100_WA-MATCODE AND GJAHR_I <> G_FISCAL_YEAR_NUMC AND BUDAT = L_MAX_BUDAT
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.

    IF g_tct100_wa-LAST_CONS_ONGC is INITIAL.
      CLEAR g_tct100_wa-LAST_CONS_DATE_ONGC.
    ENDIF.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_ONGC LAST_CONS_ONGC .


  ENDIF.
*======================================================================
**12. Last consumption at plant level (in Previous FY) : LAST_CONS_PLANT
**13. Last consumption date at Plant (in Previous FY) : LAST_CONS_DATE_PLANT

**  IF  g_tct100_wa-matcode IS NOT INITIAL.
***   first find last consumption date (in Previous FY) at Plant
**    SELECT max( LETZTVER )
**      FROM s032
**        INTO g_tct100_wa-LAST_CONS_DATE_PLANT
**          WHERE werks = ZMM_NMBLKCDHD_ST-WERKS
**                and matnr = g_tct100_wa-matcode
**                and LETZTVER < G_first_day_fy.
**
***   now find Last consumption (in Previous FY) at Plant
**    if g_tct100_wa-LAST_CONS_DATE_ONGC is NOT INITIAL.
**      SELECT single MGVBR
**        FROM s033
**          INTO g_tct100_wa-LAST_CONS_PLANT
**            WHERE SPTAG = g_tct100_wa-LAST_CONS_DATE_ONGC
**              and werks = ZMM_NMBLKCDHD_ST-WERKS
**              and matnr = g_tct100_wa-matcode.
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**    INDEX tct100-current_line TRANSPORTING CY_CONS_PLANT.
**  ENDIF.

** Commented 03.06.2014
**new Logic : Plant
**  clear: G_first_Mon_fy, G_MAX_SPMON.
**  IF  g_tct100_wa-matcode IS NOT INITIAL.
**    G_first_Mon_fy = G_first_day_fy+0(6).
**
***S031
**    SELECT max( SPMON )
**      FROM S031
**        INTO G_MAX_SPMON                                    "201206
**          WHERE SPMON < G_first_Mon_fy
**            and werks = ZMM_NMBLKCDHD_ST-WERKS
**            and  matnr = g_tct100_wa-matcode
**            and MGVBR > 0.
**
**    CLEAR: G_MAX_SPMON_MONTH, G_MAX_SPMON_YEAR.
***I_MONTH  06
***I_YEAR    2013
**    G_MAX_SPMON_MONTH = G_MAX_SPMON+4(2).
**    G_MAX_SPMON_YEAR  = G_MAX_SPMON+0(4).
**
**    CLEAR: G_SPMON_BEGIN, G_SPMON_END.
**
**    CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
**      EXPORTING
**        I_MONTH     = G_MAX_SPMON_MONTH
**        I_YEAR      = G_MAX_SPMON_YEAR
***       I_DATE      =
**      IMPORTING
**        E_FIRST_DAY = G_SPMON_BEGIN
**        E_LAST_DAY  = G_SPMON_END
**      EXCEPTIONS
**        WRONG_DATE  = 1
**        OTHERS      = 2.
**    IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**    ENDIF.
**
***S033
**    clear: G_MAX_SPTAG.
**    SELECT max( SPTAG )
**      FROM S033
**        INTO G_MAX_SPTAG             "
**          WHERE matnr = g_tct100_wa-matcode
**                and werks = ZMM_NMBLKCDHD_ST-WERKS
**                and SPTAG BETWEEN G_SPMON_BEGIN AND G_SPMON_END
**                and MGVBR > 0.
**
*** Last date of consumption(Prev. yrs): LAST_CONS_DATE_PLANT
**    g_tct100_wa-LAST_CONS_DATE_PLANT =  G_MAX_SPTAG.
**
*** LAST_CONS_PLANT
***Last consumption = sum(MGVBR) for Last date of consumption.
**    if g_tct100_wa-LAST_CONS_DATE_PLANT is NOT INITIAL.
**      clear: G_SUM_MGVBR.
**      SELECT SUM( MGVBR )
**        FROM S033
**          INTO G_SUM_MGVBR
**            WHERE matnr = g_tct100_wa-matcode
**                and werks = ZMM_NMBLKCDHD_ST-WERKS
**                and SPTAG = g_tct100_wa-LAST_CONS_DATE_PLANT
**                and MGVBR > 0.
**      g_tct100_wa-LAST_CONS_PLANT = G_SUM_MGVBR  .
**    endif.
**
**    MODIFY g_tct100_itab FROM g_tct100_wa
**      INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_PLANT LAST_CONS_PLANT .
**  ENDIF.

** 03.06.2014
***  data: L_MAX_MBLNR_PLANT_PY TYPE  MSEG-MBLNR.
***
***  IF  g_tct100_wa-matcode IS NOT INITIAL.
***    SELECT MAX( MBLNR )
***      FROM MSEG
***      INTO L_MAX_MBLNR_PLANT_PY
***      WHERE matnr = g_tct100_wa-matcode
***        AND WERKS = ZMM_NMBLKCDHD_ST-WERKS
***        and BWART in ('201' , '221' , '241' , '261')
***        and GJAHR <> G_FISCAL_YEAR_NUMC.
***
***    if L_MAX_MBLNR_PLANT_PY is NOT INITIAL.
***      SELECT SINGLE MENGE              "Last consumption (in Previous FY) at PLANT
***        FROM MSEG
***          INTO g_tct100_wa-LAST_CONS_PLANT
***            WHERE MBLNR = L_MAX_MBLNR_PLANT_PY.
***
***      select single BUDAT              "last consumption date (in Previous FY) at Plant
***        from MKPF
***          INTO g_tct100_wa-LAST_CONS_DATE_PLANT
***            WHERE MBLNR = L_MAX_MBLNR_PLANT_PY.
***    endif.
***
***    IF g_tct100_wa-LAST_CONS_PLANT is INITIAL.
***      CLEAR g_tct100_wa-LAST_CONS_DATE_PLANT.
***    ENDIF.
***    MODIFY g_tct100_itab FROM g_tct100_wa
***    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_PLANT LAST_CONS_PLANT .
***  ENDIF.
*--------
** 06.06.2014
  IF  g_tct100_wa-matcode IS NOT INITIAL.

CLEAR L_MAX_BUDAT.

select MAX( BUDAT )
      from WB2_V_MKPF_MSEG2
        into (L_MAX_BUDAT)
          where BWART_I  in ('201' , '221' , '241' , '261')
            and MATNR_I = g_tct100_wa-matcode
            and WERKS_I = ZMM_NMBLKCDHD_ST-WERKS
            and GJAHR_I <> G_FISCAL_YEAR_NUMC.

     g_tct100_wa-LAST_CONS_DATE_PLANT = L_MAX_BUDAT.

    if L_MAX_BUDAT is NOT INITIAL.
      SELECT MENGE_I
 FROM WB2_V_MKPF_MSEG2 INTO G_TCT100_WA-LAST_CONS_PLANT UP TO 1 ROWS WHERE BWART_I IN ( '201' , '221' , '241' , '261' ) AND MATNR_I = G_TCT100_WA-MATCODE AND WERKS_I = ZMM_NMBLKCDHD_ST-WERKS AND GJAHR_I <> G_FISCAL_YEAR_NUMC AND BUDAT = L_MAX_BUDAT
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    endif.

    IF g_tct100_wa-LAST_CONS_PLANT is INITIAL.
      CLEAR g_tct100_wa-LAST_CONS_DATE_PLANT.
    ENDIF.
    MODIFY g_tct100_itab FROM g_tct100_wa
    INDEX tct100-current_line TRANSPORTING LAST_CONS_DATE_PLANT LAST_CONS_PLANT .
  ENDIF.

*****

  MOVE-CORRESPONDING g_tct100_wa TO zmm_nmblkcddt.
ENDMODULE.   "// tct100_SRNO_STOCK_CONSMP

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


  PERFORM fill_sttab.

  SET PF-STATUS 'OPTNS' EXCLUDING it_tab1.
  CASE g_mode.
    WHEN 'CRE'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Create Request'.
    WHEN 'CHA'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Change/Release Request'.
    WHEN 'DIS'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Display Request'.
    WHEN 'DEL'.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Delete Request'.
****    WHEN 'REL'.
****      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ': Submit Request'.
    WHEN OTHERS.
      SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.
  ENDCASE.

  if sy-tcode = 'ZMMNMWF2'.
    SET PF-STATUS 'S_L3L4'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  elseif sy-tcode = 'ZMMNMWFL2'.
    SET PF-STATUS 'S_L2'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  elseif sy-tcode = 'ZMMNMWF3'.
    SET PF-STATUS 'S_L1L2'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  elseif sy-tcode = 'ZMMNMWF4'.
    SET PF-STATUS 'S_DIR'.
    SET TITLEBAR 'MATCOD_NMUNBLK_TTL' WITH ''.

  endif.


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
      EXPORTING
        container_name = 'C_DIS'.

    CREATE OBJECT gv_splitter1
      EXPORTING
        parent        = gv_custom_container
        orientation   = 1
        sash_position = 1.
  ENDIF.

  IF ( g_mode = 'CRE' ) OR
    ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).

    IF gv_splitter2 IS INITIAL.

      CREATE OBJECT gv_custom_container
        EXPORTING
          container_name = 'C_WRT'.


      CREATE OBJECT gv_splitter2
        EXPORTING
          parent        = gv_custom_container
          orientation   = 1
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
        parent                     = gv_splitter1->bottom_right_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
        wordwrap_to_linebreak_mode = cl_gui_textedit=>false
      EXCEPTIONS
        error_cntl_create          = 1
        error_cntl_init            = 2
        error_cntl_link            = 3
        error_dp_create            = 4
        gui_type_not_supported     = 5.
  ENDIF.
  IF ( g_mode = 'CRE' ) OR
    ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).

    IF gv_text_editor2 IS INITIAL.
      CREATE OBJECT gv_text_editor2
        EXPORTING
          parent                     = gv_splitter2->bottom_right_container
          wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
          wordwrap_to_linebreak_mode = cl_gui_textedit=>false
        EXCEPTIONS
          error_cntl_create          = 1
          error_cntl_init            = 2
          error_cntl_link            = 3
          error_dp_create            = 4
          gui_type_not_supported     = 5.
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

  LOOP AT SCREEN.
    if screen-name = 'G_REL_FLAG' .
      SCREEN-INVISIBLE = 1.  " 1:invisi , make Rel flag invisible for all, later make it visible for 'CHA' mode
      MODIFY SCREEN.
    endif.
  ENDLOOP.



  IF sy-tcode = 'ZMMNMREQ'.

***    TCT100-INVISIBLE = 0.   "make table control visible
***        LOOP AT SCREEN.     "make other sceen elements visible.
***          SCREEN-INVISIBLE = 0.
***          MODIFY SCREEN.
***        ENDLOOP.

    CASE g_mode.
      WHEN ''.

        LOOP AT SCREEN.
          screen-input = 0.       " make display only
          MODIFY SCREEN.
        ENDLOOP.

****    TCT100-INVISIBLE = 1.   "make table control invisible
****        LOOP AT SCREEN.     "make other sceen elements invisible.
****          SCREEN-INVISIBLE = 1.
****          MODIFY SCREEN.
****        ENDLOOP.


      WHEN 'CRE'.
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
            IF SCREEN-GROUP1 = 'CHA' OR     " Change
              screen-group1 = 'MAR' OR      "
              screen-group1 = 'MOD' OR
              screen-group1 = 'PAG' OR
               screen-name = 'ZMM_NMBLKCDHD_ST-REQNO' OR
               screen-name = 'G_REL_FLAG' OR
               screen-name = 'PB_CORS' OR
               screen-name = 'ZMM_NMBLKCDHD_ST-WERKS' OR
               screen-name = 'ZMM_NMBLKCDHD_ST-ADDR1' .
*              OR
*               screen-name = 'ZMM_NMBLKCDHD_ST-TEL'.
              screen-input = 1.      " make editable
              screen-INVISIBLE = 0.  "make G_REL_FLAG visible
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

* Row Status : If this is a reverted req, then disable 'INSERT' and 'DELETE'
            IF ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL.
              if screen-name = 'TCT100_INSERT' or screen-name = 'TCT100_DELETE'.
                screen-input = 0.       " make display only
                MODIFY SCREEN.
              endif.
            ENDIF.
          ENDLOOP.
        ENDIF.

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
        ENDLOOP.
    ENDCASE.

  ELSEIF sy-tcode = 'ZMMNMWF2'.     " for incharge - L3/L4

    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS' OR
             screen-group2 = 'INC' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWFL2'.    " for L2 auth
    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS' OR
             screen-group3 = 'L2' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF3'.    " for L1 auth
    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS' OR
             screen-group4 = 'L1' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF4'.   " for Dir

    LOOP AT SCREEN.
      IF  screen-group1 = 'PAG' OR
            screen-name = 'PB_CORS'.
*           OR screen-group4 = 'DIR' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.



  ENDIF.
ENDMODULE.                 " scr_attr_header  OUTPUT

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
  SET TITLEBAR '103'.
  SET PF-STATUS 'STAT_REL'.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*
  NEW-PAGE NO-TITLE.
  WRITE : / '              Confirmation to start Workflow                  '
                                                  COLOR 4.
  WRITE : / '--------------------------------------------------------------'.
  WRITE : / 'Please ensure that information provided in this  request is    '.
  WRITE : / 'correct and complete. Starting the workflow  will trigger a    '.
  WRITE : / 'flow of workitem through the Inboxes of the users maintained                                   '.
  WRITE : / 'in the approval chain of this request. '.
  WRITE : / '                                        '.

endmodule.                 " write_certificate  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT100_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TCT100_change_field_attr output.

**
** Row Status: Hide Decision Column for Creator when this is a fresh request(ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is INITIAL)
*  otherwise if it is a reverted request: Decision column is visible and make already accepted rows display only .
  IF sy-tcode = 'ZMMNMREQ' and ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is INITIAL.
    DATA col LIKE LINE OF TCT100-COLS .
    READ TABLE TCT100-COLS  INTO col index 3. " Decision is 3rd column of table control TCT100.
    col-INVISIBLE = 1.
    MODIFY  TCT100-COLS FROM col INDEX 3.
  ENDIF.

**Make MATCODE Intensified
  LOOP AT SCREEN.
    if screen-name = 'ZMM_NMBLKCDDT-MATCODE'.
      screen-INTENSIFIED = '1'.
      MODIFY SCREEN.
    endif.
  ENDLOOP.

  IF sy-tcode = 'ZMMNMREQ'.

    CASE g_mode.

      WHEN 'CRE' OR 'CHA'.
        LOOP AT SCREEN.
          IF   screen-group1 = 'CHA' or SCREEN-NAME	=	'G_TCT100_WA-FLAG'.
            screen-input = 1.   " make editable
          ELSE.
            screen-input = 0.   "make display only
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      WHEN  'DIS' OR 'DEL' or ''.
        LOOP AT SCREEN.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDLOOP.

    ENDCASE.

  ELSEIF sy-tcode = 'ZMMNMWF2'.     " for incharge - L3/L4

    LOOP AT SCREEN.
      IF   screen-group2 = 'INC' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWFL2'.    " for L2 auth
    LOOP AT SCREEN.
      IF   screen-group3 = 'L2' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF3'.    " for L1 auth
    LOOP AT SCREEN.
      IF   screen-group4 = 'L1' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF sy-tcode = 'ZMMNMWF4'.   " for Dir

    LOOP AT SCREEN.
      IF   screen-name = 'ZMM_NMBLKCDDT-DECISION' .
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

**ROW STATUS: If HEADER-STATUS_AT_REVERSAL is not initial then make rows, already having status 'ACCEPTED',
*  display only.
  IF ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL.

    LOOP AT SCREEN.
      if g_TCT100_wa-STATUS = 'ACCEPTED'.
        screen-input = 0.       " make whole row display only.
        MODIFY SCREEN.
      endif.
    ENDLOOP.

  ENDIF.

endmodule.                 " TCT100_change_field_attr  OUTPUT

*****************&---------------------------------------------------------------------*
*****************&      Module  display_message  OUTPUT
*****************&---------------------------------------------------------------------*
*****************       text
*****************----------------------------------------------------------------------*
****************module display_message output.
****************  Data:l_100msg type t_tct100.
****************  IF G_ERRCD_M IS INITIAL.
****************    Read table g_tct100_itab into l_100msg with key errcd = 'M'.
****************    if sy-subrc = 0.
****************      G_ERRCD_M = 'X'.
****************      message i122(zmm_oth).
****************    endif.
****************
****************  ENDIF.
***************** clear g_errstat.
****************
****************endmodule.                 " display_message  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_USER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_USER_DATA OUTPUT.

  IF sy-tcode = 'ZMMNMREQ' .      "for creator

*Set Company code          " , Location, Name
    CLEAR G_USER_BUKRS.
    SELECT BUKRS
 FROM PA0001 INTO G_USER_BUKRS UP TO 1 ROWS WHERE PERNR = G_USER_PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if G_USER_PERNR = 77783 and sy-sysid(2) = 'RD'.
      G_USER_BUKRS = 'MUM'.
    endif.

    if G_USER_BUKRS is initial.
      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Company code of' sy-uname text-012 .
    endif.

*Set Phone No.
    data: G_USER_PHONE LIKE ZMM_NMBLKCDHD_ST-TEL.

    SELECT * FROM  PA9205 APPENDING
      CORRESPONDING FIELDS OF TABLE IT_9205
      WHERE Pernr = G_USER_PERNR AND  " SY-UNAME
            Subty = '01' AND
            Endda = '99991231' .
    clear G_USER_PHONE.

    IF SY-SUBRC = 0.
      SORT  IT_9205 By Begda DESCENDING  .
      READ TABLE It_9205 INTO Wa_9205 INDEX 1  .
      CONCATENATE '91' Wa_9205-ZPHONE+1(10) INTO G_USER_PHONE .
    ENDIF.

*Set creator ID, COMP CODE, PHONE
    IF g_mode = 'CRE' .
      MOVE sy-uname TO zmm_nmblkcdhd_st-ID_CREATOR.
      ZMM_NMBLKCDHD_ST-BUKRS = G_USER_BUKRS.
      ZMM_NMBLKCDHD_ST-TEL = G_USER_PHONE.
    ELSEIF g_mode = 'CHA' .
      ZMM_NMBLKCDHD_ST-BUKRS = G_USER_BUKRS.
    ENDIF.

* Extract PLANT, PURCH GRP from roles
*    IF  sy-uname+0(3) <> 'CMM'.

    IF g_mode = 'CRE' OR g_mode = 'CHA'.
      perform EXTRACT_PLANTS.
      PERFORM EXTRACT_PURCH_GRP.
    ENDIF.

*    ENDIF.

*=====================================================
  ELSE.
    "Get user data for L3L4/L2/L1/DIR
  ENDIF.

ENDMODULE.                 " GET_USER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_REQ_NO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_REQ_DATA OUTPUT.

** get header data for Level L3, l2, L1, Dir

  DATA: G_REQ_NO type ZMM_NMBLKCDHD_ST-REQNO.
  data: FLAG_WF(1).

  IMPORT FLAG_WF FROM MEMORY ID 'ID_NMWF'. " imported from WF

  IF sy-tcode = 'ZMMNMWF2' or sy-tcode = 'ZMMNMWF3' or sy-tcode = 'ZMMNMWF4'
      or ( sy-tcode = 'ZMMNMREQ' and FLAG_WF = 'X' )
      or sy-tcode = 'ZMMNMWFL2'.     " added later for L2 level
* get Req. no.
    data: DOCUMENTNUMBER TYPE ZMM_NMBLKCDHD-REQNO.
    IMPORT DOCUMENTNUMBER FROM MEMORY ID 'ID_NMREQ'.
    G_REQ_NO = DOCUMENTNUMBER.
    clear DOCUMENTNUMBER.

*****************
**if G_REQ_NO is initial, Program has been started using tcodes (not from Workflow), so Req No is missing.
**POPUP to get Req No.
    data : ist_req like sval occurs 0 with header line.
    refresh IST_REQ.

    MOVE : 'ZMM_NMBLKCDHD'     TO   IST_REQ-TABNAME,
           'REQNO'         TO    IST_REQ-FIELDNAME.
    append IST_REQ.

    if G_REQ_NO is initial.
      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
*         NO_VALUE_CHECK        = ' '
          POPUP_TITLE           = 'Input Req  no.'
          START_COLUMN          = '5'
          START_ROW             = '5'
*       IMPORTING
*         RETURNCODE            =
        TABLES
          FIELDS                = IST_REQ
*       EXCEPTIONS
*         ERROR_IN_FIELDS       = 1
*         OTHERS                = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
      G_REQ_NO = IST_REQ-VALUE.

    endif.
*****************

*Get header data of the Req no.
*==============================
    if G_REQ_NO is NOT INITIAL and G_HD_COPIED is INITIAL.

      ZMM_NMBLKCDHD_ST-REQNO = G_REQ_NO.
      select SINGLE * from ZMM_NMBLKCDHD
        into CORRESPONDING FIELDS OF ZMM_NMBLKCDHD_ST
          WHERE REQNO = ZMM_NMBLKCDHD_ST-REQNO.

      if sy-subrc <> 0.
        MESSAGE e202(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Invalid request no.
      endif.

      G_HD_COPIED  = 'X'.
      PERFORM get_correspondense.

    endif.

  ELSEIF  sy-tcode = 'ZMMNMREQ' and FLAG_WF <> 'X' .  "transaction not triggered from WF

*Get header data of the Req no. for modes other than 'create'
*==============================
    IF zmm_nmblkcdhd_st-reqno IS NOT INITIAL.
      IF g_mode <> 'CRE' and g_hd_copied is initial.  "g_mode = 'CHA', 'DIS', 'DEL'

        SELECT SINGLE * FROM zmm_nmblkcdhd
        INTO CORRESPONDING FIELDS OF zmm_nmblkcdhd_st
            WHERE reqno = zmm_nmblkcdhd_st-reqno.
        if sy-subrc <> 0.
          MESSAGE e202(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Invalid request no.
        endif.

* commented on 17.04.2014
*        if zmm_nmblkcdhd_st-doc_date < '20131101'.
*          MESSAGE e227(zmm_oth) WITH '20131101'. "Pls select a request created after &.
*        endif.

        if zmm_nmblkcdhd_st-ID_CREATOR is INITIAL and zmm_nmblkcdhd_st-REQCPF is NOT INITIAL.
*  if l_hd_reqno-ID_CREATOR is INITIAL and l_hd_reqno-REQCPF is NOT INITIAL.
          MESSAGE e237(zmm_oth). "Pls input a request no. created thro' tcode ZMMNMREQ only.
        endif.

        G_HD_COPIED  = 'X'.
        PERFORM get_correspondense.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " GET_REQ_NO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_USER_PERNR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_USER_PERNR OUTPUT.

* get pernr
* if User is core team member
  DATA: WA_ZMM_CORETEAM type ZMM_CORETEAM.

  if sy-uname+0(3) = 'CAB' or sy-uname+0(3) = 'CMM'.
    select single pernr from ZMM_CORETEAM
      into G_USER_PERNR
        where uname = sy-uname.

    if sy-subrc <> 0.
      message id 'ZMSG' type 'E' number '000' with 'USER ID' sy-uname text-001 .
    endif.
  else.
* get pernr from communication data
    SELECT PERNR
 FROM PA0105 INTO G_USER_PERNR UP TO 1 ROWS WHERE USRID = SY-UNAME AND SUBTY = '0001' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc <> 0.
      message id 'ZMSG' type 'E' number '000' with 'USER ID' sy-uname text-002 .
    endif.
  endif.
ENDMODULE.                 " GET_USER_PERNR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_PBO OUTPUT.

  if sy-tcode = 'ZMMNMREQ'. " User is requisitioner
    if  G_MODE = 'CHA' AND G_REL_FLAG = 'X' .  " requisitioner ir trying to release
      if zmm_nmblkcdhd_st-reqno <> 0000000000.
        perform VALIDATE_REQNO.
      endif.
    endif.

  elseif sy-tcode = 'ZMMNMWF2'.  "User is Incharge (L3/L4)
    if ZMM_NMBLKCDHD_ST-NM_STATUS <> 'IL3L4'.
      MESSAGE e204(zmm_oth) WITH ' L3/L4 level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_INCHARGE.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  elseif sy-tcode = 'ZMMNMWFL2'. " User is L2
    if ZMM_NMBLKCDHD_ST-NM_STATUS <>  'IL2'. .
      MESSAGE e204(zmm_oth) WITH 'L2 level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_L2.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  elseif sy-tcode = 'ZMMNMWF3'. " User is L1
    if ZMM_NMBLKCDHD_ST-NM_STATUS <>  'IL1'.               " 'IL1L2'. .
      MESSAGE e204(zmm_oth) WITH ' L1 level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_L1.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  elseif sy-tcode = 'ZMMNMWF4'. " User is a Dir
    if ZMM_NMBLKCDHD_ST-NM_STATUS <>  'IDIR'. .
      MESSAGE e204(zmm_oth) WITH ' the Director level' sy-uname. "Request is not at & ( user & ).
    endif.

    if sy-uname <> ZMM_NMBLKCDHD_ST-ID_DIRECTOR.
      MESSAGE e203(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Request is not assigned to the logged-in user.
    endif.

  endif.
ENDMODULE.                 " VALIDATE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ROLE_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ROLE_AUTH OUTPUT.
  perform ROLE_AUTH.

ENDMODULE.                 " ROLE_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME_CREATOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME_CREATOR OUTPUT.
  PERFORM SHOW_NAME_CREATOR.

  PERFORM SHOW_NAME_INCHARGE.  "for display mode- LOV of concatenated names of L3/l2/l1/dir
ENDMODULE.                 " SHOW_NAME_CREATOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ROW_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ROW_CONTROL OUTPUT.
** Row Status: clear STATUS_AT_REVERSAL when the request is back at the level at
*   which reversal was initiated. This will enable editing of already accepted Rows.
  if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ZMM_NMBLKCDHD_ST-NM_STATUS.
    ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''.
  endif.

ENDMODULE.                 " ROW_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PRUNE_DETAIL_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRUNE_DETAIL_DATA OUTPUT.

** If some ZMM_NMBLKCDDT-DECISION which has flowed from previous level is not
* allowed in this level, clear it (only decision, not status).

  data: g_TCT100_wa1     type t_TCT100,
        l_tabix1 type sy-tabix.

  loop at g_tct100_itab into g_TCT100_wa1.
    l_tabix1 = sy-tabix.

    IF sy-tcode = 'ZMMNMREQ'. " decision col will appear only in case of reverted req,
      if g_TCT100_wa1-decision = 'ACCEPT'    " in reverted req, Accept will be grey.
        or g_TCT100_wa1-decision = 'REJECT'
         or g_TCT100_wa1-decision = 'REPLY'.
        " allowed
      else.
        clear g_TCT100_wa1-decision.
      endif.

    ELSEIF  sy-tcode = 'ZMMNMWF2'
          or sy-tcode = 'ZMMNMWF3'
             or sy-tcode = 'ZMMNMWFL2'.

      if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''. " fresh request
        if g_TCT100_wa1-decision = 'ACCEPT'
           or g_TCT100_wa1-decision = 'REJECT'
             or g_TCT100_wa1-decision = 'QUERY'.
          " allowed
        else.
          clear g_TCT100_wa1-decision.
        endif.

      else.     "reverted requests, all statuses allowed in PBO

      endif.

    ELSEIF sy-tcode = 'ZMMNMWF4'.

      if g_TCT100_wa1-decision = 'ACCEPT'
       or g_TCT100_wa1-decision = 'REJECT'
         or g_TCT100_wa1-decision = 'QUERY'.
        " allowed
      else.
        clear g_TCT100_wa1-decision.
      endif.

    ENDIF.
    MODIFY g_tct100_itab FROM g_TCT100_wa1 INDEX l_tabix1.
    clear g_TCT100_wa1.
  endloop.

ENDMODULE.                 " PRUNE_DETAIL_DATA  OUTPUT

*--- INCLUDE: MZMM_NONMOVTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMM_NONMOVTOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMM_NONMOV.
type-pools: icon.

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
         ICON like ZMM_NMBLKCDDT-ICON,
         STATUS like ZMM_NMBLKCDDT-STATUS,
         DECISION LIKE ZMM_NMBLKCDDT-DECISION,
         CY_CONS_ONGC	LIKE ZMM_NMBLKCDDT-CY_CONS_ONGC,
         CY_CONS_DATE_ONGC  LIKE ZMM_NMBLKCDDT-CY_CONS_DATE_ONGC,       "19.05.2014 Last cons. date in CY across ONGC
         CY_CONS_PLANT  LIKE ZMM_NMBLKCDDT-CY_CONS_PLANT,
         CY_CONS_DATE_PLANT  LIKE ZMM_NMBLKCDDT-CY_CONS_DATE_PLANT,      "19.05.2014 Last cons. date in CY in plant
         LAST_CONS_ONGC	LIKE ZMM_NMBLKCDDT-LAST_CONS_ONGC,
         LAST_CONS_DATE_ONGC  LIKE ZMM_NMBLKCDDT-LAST_CONS_DATE_ONGC,
         LAST_CONS_PLANT  LIKE ZMM_NMBLKCDDT-LAST_CONS_PLANT,
         LAST_CONS_DATE_PLANT	LIKE ZMM_NMBLKCDDT-LAST_CONS_DATE_PLANT,

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

********Data: g2_lines like tline.

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

 DATA   :It_9205 TYPE  STANDARD TABLE OF  PA9205,
        Wa_9205 TYPE PA9205 .

 DATA : NAME1 TYPE EMNAM,
        NAME2 TYPE EMNAM,
        NAME3 TYPE EMNAM.



DATA G_USER_BUKRS type bukrs.
data: g_user_pernr type pernr_d.
data: ist_agr_users_plant type TABLE OF agr_users,  " list of roles of type MM_INDENT_MUM_PLANT_*
      wa_agr_users_plant type agr_users.
types: begin of ty_plant,
       plant TYPE werks_d,
       end of ty_plant.
data: ist_plant type TABLE OF  ty_plant,  " list of PLANTs
      wa_plant type  ty_plant.

data: ist_agr_users_pgrp type TABLE OF agr_users,  " list of roles of type MM_PUR_PO_MUM_PGRP_*
      wa_agr_users_pgrp type agr_users.

types: begin of ty_pgrp,
       EKGRP TYPE EKGRP,
       end of ty_pgrp.
data: ist_pgrp type TABLE OF  ty_pgrp,  " list of PGRP
      wa_pgrp type  ty_pgrp.

DATA : IST_FIELD LIKE  DFIES OCCURS 1 WITH HEADER LINE.
DATA : IST_DYNPFLD_MAPPING LIKE STANDARD TABLE OF DSELC
                                       WITH  HEADER LINE.
DATA : IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                       WITH  HEADER LINE.
DATA FLAG_HDR_COPIED(1).
DATA G_REL_FLAG(1).
DATA flag_dont_clear(1).

TYPES: BEGIN OF ty_user,
         uname type XUBNAME,
         ename type EMNAM,
       END OF ty_user.

Data: L_ROLE1 type agr_name,
      L_ROLE2 type agr_name,
      L_ROLE3 type agr_name.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
Data: L_ROLE1A type agr_name.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

DATA : g_id TYPE vrm_id,
       g_list TYPE vrm_values,
       g_value  LIKE LINE OF g_list.

DATA : g_list_inc TYPE vrm_values,
       g_value_inc  LIKE LINE OF g_list.


Data: WA_APPROVER type ty_user. " for structure def in forms
DATA FLAG_CLEAR_OLD_APPR_CHAIN(1).
DATA FLAG_CLEAR_OLD_Status(1).
data: ANS_CONFIRM_ACTION(1).
