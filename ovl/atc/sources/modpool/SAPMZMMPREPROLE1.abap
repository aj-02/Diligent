*--- MAIN PROGRAM: SAPMZMMPREPROLE1 ---*
*&--------------------------------------------------------------------*
*& Module pool       SAPMZMMPREPROLE                                  *
*&--------------------------------------------------------------------*
*                                                                     *
* Title      : End User Authorisation                                  *
*                                                                     *
* FS No.     : FS-MM-AUTH-004                                         *
*                                                                     *
* Author     : Ajit Singh             Date : 30/11/2005               *
*                                                                     *
* Login Id   : CAB_AJIT                                               *
*                                                                     *
* Description: End User Authorisation                                 *
*                                                                     *
* Tran. Code :                                                        *
*                                                                     *
***********************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Changes  in  INCLUDE MZMMPREPROLE1F01
************************************************************************



INCLUDE MZMMPREPROLE1TOP.
*INCLUDE MZMMPREPROLETOP                         .

INCLUDE MZMMPREPROLE1O01.
*INCLUDE MZMMPREPROLEO01                         .
INCLUDE MZMMPREPROLE1I01.
*INCLUDE MZMMPREPROLEI01                         .
INCLUDE MZMMPREPROLE1F01.
*INCLUDE MZMMPREPROLEF01                         .

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

*--- INCLUDE: MZMMPREPROLE1F01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced by POPUP_TO_CONFIRM.
*
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

    DATA : l_get1(1) TYPE c.
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

  if sy-tcode = 'ZMM_ARMS_CONNECT'.
       old_ok_code = 'DISPLAY'.
       get parameter id 'ZREQNO' field zmm_prep_rolereq-docno.
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

  CALL FUNCTION 'ENQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_CDHD  = 'E'
            MANDT          = SY-MANDT
            DOCNO          = zmm_prep_rolereq-docno
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

  data l_blank value ''.

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

      clear ZMM_PREP_ROLEREQ-FUNDC .

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

    g_release = ZMM_PREP_ROLEREQ-req_cr_fl.
    g_approve = ZMM_PREP_ROLEREQ-req_app_fl.
    g_approve0 = ZMM_PREP_ROLEREQ-req_app0_fl.
    g_approve1 = ZMM_PREP_ROLEREQ-req_app1_fl.


    select single * from ZMM_PREP_ROLEREQ
                    where DOCNO = ZMM_PREP_ROLEREQ-docno.

    if ZMM_PREP_ROLEREQ-req_cr_fl is initial.
      ZMM_PREP_ROLEREQ-req_cr_fl = g_release.
    endif.
    if ZMM_PREP_ROLEREQ-req_app_fl is initial.
      ZMM_PREP_ROLEREQ-req_app_fl = g_approve.
    endif.
    if ZMM_PREP_ROLEREQ-req_app1_fl is initial.
      ZMM_PREP_ROLEREQ-req_app1_fl = g_approve1.
    endif.

    if ZMM_PREP_ROLEREQ-req_app0_fl is initial.
      ZMM_PREP_ROLEREQ-req_app0_fl = g_approve0.
    endif.

    clear : g_release, g_approve, g_approve0, g_approve1.

    if g_release = 'X' and ( g_approve <> 'X' and
                             g_approve0 <> 'X' and
                             g_approve1 <> 'X' ).

      g_app_rel = 'X'.

    endif.

  endif.

*describe table ist_itemtab lines g_lines_rl.

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

  ZMM_PREP_ROLEREQ-mandt = sy-mandt.
  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CRCROLES'.
    ZMM_PREP_ROLEREQ-docno = ZDOCNUMB.
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
           where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                 a~sprps = ' ' and
                 a~endda = '99991231' and
                 c~sprps = ' ' and
                 c~endda = '99991231' .

  if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*            ZMM_PREP_ROLEREQ-NAME = ist_data-name.
*            ZMM_PREP_ROLEREQ-DESIGNATION = ist_data-designation.

    ZMM_PREP_ROLEREQ-PERSA = ist_data-werks .
*            select single * from t500p
*                           where persa = ist_data-werks.
*                     if old_ok_code <> 'CROSSCO'.
*                           ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
*                     endif.

  endif.
****************************************


  if ZMM_PREP_ROLEREQ-USERIDCR is initial.

    ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
    ZMM_PREP_ROLEREQ-CR_DATE  = sy-datum.

*      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
*      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

    clear zusrmst.


*       select single * from zusrmst where cpfno =
*                                   ZMM_PREP_ROLEREQ-useridcr.
    select single * from usr02 where bname =
                               ZMM_PREP_ROLEREQ-useridcr.


    if sy-subrc ne 0.

    else.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*          ZMM_PREP_ROLEREQ-NAMECR = zusrmst-last_name.
*        endif.

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
                where a~pernr = ZMM_PREP_ROLEREQ-USERIDCR and
                      a~sprps = ' ' and
                      a~endda = '99991231' and
                      c~sprps = ' ' and
                      c~endda = '99991231' .

      if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
        ZMM_PREP_ROLEREQ-NAMECR = ist_data-name.
        ZMM_PREP_ROLEREQ-DESIGCR = ist_data-designation.
      endif.

    endif.

    clear : ist_data.
    refresh : ist_data.

  endif.


  if ZMM_PREP_ROLEREQ-USERIDAP is initial.

    if old_ok_code = 'APPROVE' and
          ( ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
*            or ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X'
*            or ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X' ).
      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

      if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
         ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
      endif.

      clear zusrmst.

*             select single * from zusrmst where cpfno =
*                                   ZMM_PREP_ROLEREQ-useridap.

      select single * from usr02 where bname =
                            ZMM_PREP_ROLEREQ-useridap.

      if sy-subrc ne 0.

      else.
*                concatenate zusrmst-first_name zusrmst-last_name into
*                zusrmst-last_name.
*                ZMM_PREP_ROLEREQ-NAMEAPP = zusrmst-last_name.

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
        where a~pernr = ZMM_PREP_ROLEREQ-USERIDAP and
              a~sprps = ' ' and
              a~endda = '99991231' and
              c~sprps = ' ' and
              c~endda = '99991231' .

*                 select single werks from pa0001 into g_persa
*                  where pernr = ZMM_PREP_ROLEREQ-USERIDAP.
*

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
          ZMM_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZMM_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
                 not ZMM_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
            where persa = ist_data-werks.
            if ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                where userid = ZMM_PREP_ROLEREQ-USERIDAP.
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
          ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
*                and
*                      ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE = sy-datum.

      if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
         ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
      endif.


      select single * from usr02 where bname =
                              ZMM_PREP_ROLEREQ-useridap.
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
            where a~pernr = ZMM_PREP_ROLEREQ-USERIDAP and
                  a~sprps = ' ' and
                  a~endda = '99991231' and
                  c~sprps = ' ' and
                  c~endda = '99991231' .
*
*                select single werks from pa0001 into g_persa
*                  where pernr = ZMM_PREP_ROLEREQ-USERIDAP.

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
          ZMM_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZMM_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
             not ZMM_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
                where persa = ist_data-werks.
            if ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                   where userid = ZMM_PREP_ROLEREQ-USERIDAP.
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
*                ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' and
                   ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

        ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
        ZMM_PREP_ROLEREQ-APP_DATE = sy-datum.

        if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
           ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
        else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
        endif.


        select single * from usr02 where bname =
                                ZMM_PREP_ROLEREQ-useridap.
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
              where a~pernr = ZMM_PREP_ROLEREQ-USERIDAP and
                    a~sprps = ' ' and
                    a~endda = '99991231' and
                    c~sprps = ' ' and
                    c~endda = '99991231' .
*
*                select single werks from pa0001 into g_persa
*                  where pernr = ZMM_PREP_ROLEREQ-USERIDAP.

          if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
            ZMM_PREP_ROLEREQ-NAMEAPP = ist_data-name.
            ZMM_PREP_ROLEREQ-DESIGAP = ist_data-designation.
            if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
               not ZMM_PREP_ROLEREQ-PERSA is initial.
              select single * from t500p
                  where persa = ist_data-werks.
              if ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
              else.
                select single * from zmm_prep_ex_app
                     where userid = ZMM_PREP_ROLEREQ-USERIDAP.
                if sy-subrc = 0.
                else.
* Check for L1 inserted  26/12/2006
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

if not ZMM_PREP_ROLEREQ-USERIDAP is initial and
     old_ok_code = 'APPROVE' and
              ( ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' or
                   ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
                   ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X' ).

** inserted to modify approval data
      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE = sy-datum.

     if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
         ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
     else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
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

*****
  if g_fundc_err_flag <> 'X'.

    if old_ok_code = 'DISPLAY' and ZMM_PREP_ROLEREQ-comm_fl = 'X'.
      g_comm_fl = 'X'.
      if g_lines_2 <> 0.
        clear ZMM_PREP_ROLEREQ-comm_fl.
        clear g_lines_2.
** Status New changed to IF
        ZMM_PREP_ROLEREQ-status = 'IF'.
      endif.
    endif.

    if old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-comm_fl = 'X'.
** Status New changed to IR
      ZMM_PREP_ROLEREQ-status = 'IR'.
      clear ZMM_PREP_ROLEREQ-comm_fl.
    endif.

    if old_ok_code = 'CROSSCO'.
      ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    endif.

    if old_ok_code = 'CRCROLES'.
      ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
    endif.

    if ZMM_PREP_ROLEREQ-CCODE is initial.
      message e142(zhelp).
    endif.

**** CAB_AJIT 19/10/2006
    if ( old_ok_code = 'DISPLAY' and attach_fl = 'X' and
         ZMM_PREP_ROLEREQ-status = 'IR' ).
         ZMM_PREP_ROLEREQ-status = 'IF'.
         status_ir_fl = 'X'.
    endif.

    modify ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

    if sy-subrc = 0.

      if g_app_rel = 'X'.

        clear g_app_rel.

      elseif
**** CAB_AJIT 19/10/2006
      ( old_ok_code = 'DISPLAY' and attach_fl = 'X' and
        status_ir_fl = 'X' ).
        clear : attach_fl, status_ir_fl.
        perform popup_approve_message.
      elseif
      ( old_ok_code = 'DISPLAY' and ZMM_PREP_ROLEREQ-comm_fl = 'X' )
      or ( old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-comm_fl = 'X' ).
**** CAB_AJIT 19/10/2006
        perform popup_approve_message.
      else.

        g_approver_level = 'L3'.

        Perform insert_items.

      endif.

*      Perform items_approval_check.
*
      set parameter id 'ZREQNO' field zmm_prep_rolereq-docno.

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

      perform clear.
      perform unlock_record.
      if g_reset_fl = 'X'.
        clear g_reset_fl.
        clear set_disc_mm_flag.
        clear g_hd_copied.
        old_ok_code = 'CHANGE'.
        ZMM_PREP_ROLEREQ-docno = g_docno.
      endif.
*      zmm_prep_rolereq-crc_fl = g_crc_fl.
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

  sort g_TABCTRL100_itab
  by role_name plant grp  sloc receipt_loc approver.

  delete adjacent duplicates from g_TABCTRL100_itab
    comparing role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

*    if old_ok_code = 'CREATE'.
*    elseif old_ok_code <> 'DISPLAY'.
*       delete from ZMM_PREP_ROLEREI where
*       docno = ZMM_PREP_ROLEREQ-docno.
*    endif.

  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

    move-corresponding g_TABCTRL100_wa to wa_itemtab.

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

    Perform check_items_save.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      delete from ZMM_PREP_ROLEREQ
            where docno = ZMM_PREP_ROLEREQ-docno.
      delete from ZMM_PREP_ROLEREI
            where docno = ZMM_PREP_ROLEREQ-docno.
      if sy-subrc = 0.
        set cursor field 'ZMM_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZMM_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZMM_PREP_ROLEREQ-docno.
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
        delete from ZMM_PREP_ROLEREI where
        docno = ZMM_PREP_ROLEREQ-docno.
      endif.

      modify ZMM_PREP_ROLEREI from table ist_itemtab.

      if sy-subrc = 0.
        perform clear1.
        if old_ok_code = 'CROSSCO' or
              ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.

              if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CROSSCO' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.

               if old_ok_code = 'APPROVE' or
                  ZMM_PREP_ROLEREQ-status = 'IF'.
                  perform popup_approve_message.
               endif.

               perform pop_up_crossco_message.          .
*          message i113(zhelp) with ZMM_PREP_ROLEREQ-docno.
               message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.

          else.
            if old_ok_code = 'CRCROLES' or
              ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
               if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CRCROLES' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.
               if old_ok_code = 'APPROVE' or
                  ZMM_PREP_ROLEREQ-status = 'IF'.
                  perform popup_approve_message.
               endif.
               perform pop_up_crc_message.
*              message i119(zhelp) with ZMM_PREP_ROLEREQ-docno.
               message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
               g_crc_fl = 'X'.
            else.
              if old_ok_code = 'RELEASE'.
                perform popup_release_message.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'APPROVE'.
.               perform popup_approve_message.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'CREATE' or old_ok_code = 'CHANGE'..
                perform popup_release_message1.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              elseif ZMM_PREP_ROLEREQ-status = 'IF'.
                perform popup_approve_message.
              else.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              endif.
            endif.
        endif.
      endif.

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
**                 DEFAULTOPTION = 'N'
*         IMPORTING
*              ANSWER         = l_choice1.

DATA : l_get2(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'EXIT '
    TEXT_QUESTION               = 'Data will be lost, Want to quit? '
   DEFAULT_BUTTON              = '2'
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

  CALL FUNCTION 'DEQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = zmm_prep_rolereq-docno.

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
  refresh : g_TABCTRL100_itab.
  clear   : g_TABCTRL100_itab.
  clear   : sy-ucomm.
  clear   : g_curr_line.
  clear set_disc_mm_flag.
  clear   : zmm_prep_rolerei, zmm_prep_rolereq.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].
  clear   : t500p-name1.
  clear   : CRC_CHECK_FL.
  clear   : help_list_flag.
  refresh : it_m_fistb.

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
  or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
 .

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
   or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
 .
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
                    ID 'FRGCO' FIELD : 'L2'. "#EC *

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

  if old_ok_code = 'APPROVE'.

     if g_user = 'L1' or
        g_user = 'IM' or
        g_user = 'L3'.
     else.
        message i131(zhelp).
        clear old_ok_code.
        call screen 100.
     endif.

     if g_user = 'L1' and
        ( zmm_prep_rolereq-req_app0_fl = 'X' or
          zmm_prep_rolereq-req_app_fl = 'X' ).
        message i132(zhelp).
        clear old_ok_code.
        call screen 100.
     endif.

  endif.

  if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.

    if  ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
    else.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
              TEXTLINE1  = 'Not authorised to use this document- not yours '.
*                     message i046(zhelp).
      perform clear.
      call screen 100.
    endif.

  endif.

  if old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.

    if zmm_prep_rolereq-status = 'IF' or
          zmm_prep_rolereq-status = 'PC' or
          zmm_prep_rolereq-status = 'C'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request under process / completed can''t change/reset'.

*                message e065(zhelp).
      perform clear.
      call screen 100.

    else.
      g_reset_fl = ZMM_PREP_ROLEREQ-REQ_CR_FL.
      g_docno = ZMM_PREP_ROLEREQ-docno.
      perform verify.
  endif.
  endif.

  if old_ok_code = 'APPROVE' and
                    ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
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

  if old_ok_code = 'RELEASE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
         EXPORTING
              TEXTLINE1 = 'Request already released by creator'.

*          message e053(zhelp).
    perform clear.
    call screen 100.

  endif.

  if old_ok_code = 'APPROVE'.

    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.

*                   message e051(zhelp).
      perform clear.
      call screen 100.

    endif.

    if ( g_user = 'IM' or g_user = 'L3' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.
*                   message e051(zhelp)..
      perform clear.
      call screen 100.

    endif.


*    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TEXTLINE1 = 'Request already approved'.
*
**                   message e049(zhelp).
*      perform clear.
*      call screen 100.
*
*    endif.
*
*    if ( g_user = 'IM' or g_user = 'L3' ) and
*                          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TEXTLINE1 = 'Request already approved by L3/IM'.
*
**                   message e050(zhelp)..

      if  ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request already approved'.

      perform clear.
      call screen 100.

    endif.

  endif.

  if ( ZMM_PREP_ROLEREQ-status = 'IF' or
      ZMM_PREP_ROLEREQ-status  = 'C' )
      and old_ok_code <> 'DISPLAY'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
       EXPORTING
              TEXTLINE1   = 'Request can not  be  changed, Can only be displayed'.

*              message e079(zhelp).
*               perform clear.
    old_ok_code = 'DISPLAY'.
    call screen 100.

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

  data : l_docno like zmm_prep_rolereq-docno.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZMM_PREP_ROLEREQ-FUNDC
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

     select single docno from zmm_prep_rolereq
                     into l_docno where docno = zmm_prep_rolereq-docno.

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

  if ZMM_PREP_ROLEREI-rej_fl = ''.


    if old_ok_code = 'APPROVE' and
                      ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
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

    DATA : l_get3(1) TYPE c.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
*       TITLEBAR                    = ' '
        TEXT_QUESTION               = 'Are you sure, you want to delete the Document? '
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
      clear l_choice.

**************************************

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

  delete ZMM_PREP_ROLEREI from table ist_itemtab.

  if sy-subrc = 0.
    message i120(zhelp) with ZMM_PREP_ROLEREQ-docno.
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
*      EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be cancelled? '
*           TITEL          = 'RESET'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
  DATA : l_get4(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'RESET '
      TEXT_QUESTION               = 'Request already released Flags will be cancelled? '
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
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

  If l_choice = 'J'.

    clear zmm_prep_rolereq-req_cr_fl.
    clear zmm_prep_rolereq-req_app_fl.
    clear zmm_prep_rolereq-req_app0_fl.
    clear zmm_prep_rolereq-req_app1_fl.
    zmm_prep_rolereq-status = 'IC'.
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

   if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.

       if zmm_prep_rolecrc-plant = 'X' and
           wa_itemtab-plant is initial.
          g_field = 'ZMM_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-p_grp = 'X' and
           wa_itemtab-grp is initial.
          g_field = 'ZMM_PREP_ROLEREI-P_GRP'.
          rollback work.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-app_level = 'X' and
          wa_itemtab-approver is initial.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
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
          g_field = 'ZMM_PREP_ROLEREI-PLANT'.
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
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
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
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
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
          g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
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
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

    endif.

   endif.

  endif.
  if wa_itemtab-rej_fl is initial.
    perform validate_role_approval_level.
  endif.
  perform validate_lineitem_datax.
  Perform items_approval_check.
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

DATA : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Do you want to cancel release?'
    TEXT_QUESTION               = 'If u cancel release, u can change data else go in display mode '
                                  &'& just do correspondence without cancelling release.'

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
" End of <RD1k960036>.

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
*&      Form  attach_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_file.

  data: "lv_cancelled like sonv-flag,   " Flag: Upload was cancelled
        l_action    type i,            " Benutzeraktion
        l_rc        type i,            " Anzahl gefundener Dateinamen
        l_filetab   type filetable,    " Tabelle mit Dateinamen
        l_filename  like gv_filename,
        l_filenam0  like gv_filename,
        l_mode(10),
        l_length type i,
        l_tab_len type i,
        l_asc_type(1).
*   Upload des Files
  clear: gt_cont[], gt_contx[], l_tab_len.
  if sy-saprl gt '4.6D'. "Methode hat sich veraendert
    clear l_filetab[].
    call method cl_gui_frontend_services=>file_open_dialog
*          exporting default_filename        = l_filename
*                    default_extension       = 'rtf'
*                    file_filter             = '*.rtf'       "#EC NOTEXT
*                    file_filter             = '(*.*)|*.*|'  "#EC NOTEXT
*                    initial_directory       = 'C:\TEMP'     "#EC NOTEXT
*                    multiselection          = abap_false
*                    window_title            = i_title
        changing   file_table              = l_filetab
                   rc                      = l_rc
                   user_action             = l_action
        exceptions file_open_dialog_failed = 1
                   cntl_error              = 2
                   error_no_gui            = 3
                   others                  = 4.

    if l_action = cl_gui_frontend_services=>action_cancel.
*   The user pressed the cancel button (in windows)
      message s076(zhelp).
      leave screen.
    endif.
  else.
    clear l_filetab[].
    call method cl_gui_frontend_services=>file_open_dialog
*          exporting default_filename        = l_filename
*                    default_extension       = 'rtf'
*                    file_filter             = '*.rtf'       "#EC NOTEXT
*                    file_filter             = '(*.*)|*.*|'  "#EC NOTEXT
*                    initial_directory       = 'C:\TEMP'     "#EC NOTEXT
*                    multiselection          = abap_false
*                    window_title            = i_title
        changing   file_table              = l_filetab
                   rc                      = l_rc
*                    user_action             = l_action
        exceptions file_open_dialog_failed = 1
                   cntl_error              = 2
*                    error_no_gui            = 3
                   others                  = 4.

*     if l_action = cl_gui_frontend_services=>action_cancel.
    if l_rc ne 0.
*   The user pressed the cancel button (in windows)
      message s076(zhelp).
      leave screen.
    endif.
  endif.
  if sy-subrc = 0 and l_rc > 0.       " Anzahl gefundener Dateinamen
    read table l_filetab index 1 into gv_filename.
    move gv_filename to l_filenam0.
    while l_filenam0 ca '\'.
      shift l_filenam0 up to '\'.
      shift l_filenam0.
    endwhile.
    move l_filenam0 to l_filename.
    if l_filename na '.'.
      clear l_filename.
    else.
      while l_filename ca '.'.
        shift l_filename up to '.'.
        shift l_filename.
      endwhile.
    endif.
    move l_filename to gv_filetype.
    translate l_filename to upper case.
    if l_filename eq 'TXT'
      or l_filename eq 'HTM'.
*      or l_filename eq 'HTM'
*      or l_filename eq 'RTF'.
      move 'ASC' to l_mode.
*      move gv_filename to gv_filn.
*      move l_mode to l_filetype.
      call function 'GUI_UPLOAD'
           EXPORTING
                filename   = gv_filename
                filetype   = l_mode
           IMPORTING
                filelength = l_length
           TABLES
                data_tab   = gt_cont
           EXCEPTIONS
                others     = 1.
      if sy-subrc ne 0.
        message s077(zhelp) with 'Upload'(006).
        leave screen.
      else.
        describe table gt_cont lines l_tab_len.
      endif.
    else.
      move 'BIN' to l_mode.
*      move gv_filename to gv_filn.
*      move l_mode to l_filetype.
      call function 'GUI_UPLOAD'
           EXPORTING
                filename   = gv_filename
                filetype   = l_mode
           IMPORTING
                filelength = l_length
           TABLES
                data_tab   = gt_contx
           EXCEPTIONS
                others     = 1.
      if sy-subrc ne 0.
        message s077(zhelp) with 'Upload'(006).
        leave screen.
      else.
        describe table gt_contx lines l_tab_len.
      endif.
    endif.
    if l_tab_len eq 0.
      message s106(zhelp).
      leave screen.
    endif.
  else.
    message s077(zhelp) with 'Upload'(006).
    leave screen.
  endif.
  gs_win_head-doc_length = l_length.
  move cs_x to g_apx_exist.
  add 1 to g_apx_cnt.
  get time stamp field gt_ac_apx-timestamp.
  gt_ac_apx-descr = l_filenam0.
  gt_ac_apx-appxno = g_apx_cnt.
  gt_ac_apx-filetyp = gv_filetype.
  translate gt_ac_apx-filetyp to upper case.
  gt_ac_apx-filenam = l_filenam0.
  gt_ac_apx-filelen = gs_win_head-doc_length.
  gt_ac_apx-last_usr = sy-uname.
  if l_mode = 'ASC'.
    gt_ac_apx-filefm_ul = 'ASC'.
    gt_ac_apx-firstl = g_apx_ptr.
    clear gt_cont.
    loop at gt_cont.
      move gt_cont to gt_ac_cont.
      append gt_ac_cont.
      add 1 to g_apx_ptr.
    endloop.
    gt_ac_apx-lastl = g_apx_ptr - 1.
  else.
    gt_ac_apx-filefm_ul = 'BIN'.
    gt_ac_apx-firstl = g_apx_bin_ptr.
    clear: gt_contx.
    loop at gt_contx.
      move gt_contx to gt_ac_contx.
      append gt_ac_contx.
      add 1 to g_apx_bin_ptr.
    endloop.
    gt_ac_apx-lastl = g_apx_bin_ptr - 1.
  endif.
  append gt_ac_apx.

  perform download_appendix.

endform.                    " load_appendix
*&---------------------------------------------------------------------*
*&      Form  delete_appendix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_appendix .
  clear gt_view_apx.
  loop at gt_view_apx where selc eq cs_x.
    read table gt_ac_apx with key appxno = gt_view_apx-appxno.
    if sy-subrc eq 0.
      delete gt_ac_apx index sy-tabix.
    endif.
  endloop.
endform.                    " delete_appendix
*&---------------------------------------------------------------------*
*&      Form  download_appendix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form download_appendix .
  clear gt_view_apx.
  loop at gt_view_apx where selc eq cs_x.
    read table gt_ac_apx with key appxno = gt_view_apx-appxno.
    if sy-subrc eq 0.
* move daten und Start download
      perform save_appendix using gt_ac_apx.
    endif.
  endloop.
ENDFORM.                    " attach_file
*&---------------------------------------------------------------------*
*&      Form  save_appendix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AC_APX  text
*----------------------------------------------------------------------*
FORM save_appendix USING    Ps_AC_APX structure bcos_appx.
  data: l_action    type i,            " Benutzeraktion
          l_filetype   type string,
          l_mode(10),
          l_filename  like gv_filename,
          l_path type string,
*        ll_filenam like RLGRAP-FILENAME,
*        ll_FILETYP LIKE  RLGRAP-FILETYPE,
          ll_len type i.
  "lv_cancelled like sonv-flag,   " Flag: Upload was cancelled
  "l_rc        type i,            " Anzahl gefundener Dateinamen
  "l_length type i.

* Schaufeln der Anhangsinformationen incl. Datei in ac-Tabellen
  if Ps_AC_APX-filefm_ul eq 'ASC'.
    clear: gt_cont, gt_cont[].
    loop at gt_ac_cont from Ps_AC_APX-firstl to Ps_AC_APX-lastl.
      move gt_ac_cont to gt_cont.
      append gt_cont.
    endloop.
  else.
    clear: gt_contx, gt_contx[].
    loop at gt_ac_contx from Ps_AC_APX-firstl to Ps_AC_APX-lastl.
      move gt_ac_contx to gt_contx.
      append gt_contx.
    endloop.
**cab_ajit
*** Macros for OBJCONT conversion
    field-symbols: <ptr_text> type soli, "#EC *
                    <ptr_x>      type any, "#EC *
                   <ptr_hex> type solix.

    data wa_soli type soli.
    data wa_solix type solix.

    define hex_to_cont.
*   &1 Table of structure SOLIX
*   &2 Table of structure SOLI
      refresh &2.
      loop at &1 into wa_solix.
        clear wa_soli.
        assign wa_soli to <ptr_hex> casting.
        move wa_solix to <ptr_hex>.
        append wa_soli to &2.
      endloop.
    end-of-definition.

**
    hex_to_cont gt_contx gt_cont.
  endif.
  l_filetype = Ps_AC_APX-filetyp.
  gv_filename = Ps_AC_APX-filenam.
*   Upload des Files
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
     EXPORTING
*        WINDOW_TITLE      =
         DEFAULT_EXTENSION = l_filetype
         DEFAULT_FILE_NAME = gv_filename
*        FILE_FILTER       =
*        INITIAL_DIRECTORY =
    CHANGING
         FILENAME          = gv_filename
         PATH              = l_path
         FULLPATH          = l_filename
         USER_ACTION       = l_action
    EXCEPTIONS
         CNTL_ERROR        = 1
         ERROR_NO_GUI      = 2
         others            = 3
          .
  IF SY-SUBRC <> 0.
    message s076(zhelp).
    leave screen.
  elseif l_action = cl_gui_frontend_services=>action_cancel.
*   The user pressed the cancel button (in windows)
    message s076(zhelp).
    leave screen.
  endif.
  if sy-subrc = 0.
    move Ps_AC_APX-filefm_ul to l_mode.
*    move l_filename to gv_filn.
*    move l_mode to gv_filetype.
    if l_mode eq 'ASC'.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
*       BIN_FILESIZE                  =
          FILENAME                      = l_filename
          FILETYPE                      = l_mode
*       APPEND                        = ' '
*       WRITE_FIELD_SEPARATOR         = ' '
*       HEADER                        = '00'
*       TRUNC_TRAILING_BLANKS         = ' '
*       WRITE_LF                      = 'X'
*       COL_SELECT                    = ' '
*       COL_SELECT_MASK               = ' '
*     IMPORTING
*       FILELENGTH                    =
        TABLES
*       DATA_TAB                      = gt_contx
          DATA_TAB                      = gt_cont
        EXCEPTIONS
          FILE_WRITE_ERROR              = 1
          NO_BATCH                      = 2
          GUI_REFUSE_FILETRANSFER       = 3
          INVALID_TYPE                  = 4
          NO_AUTHORITY                  = 5
          UNKNOWN_ERROR                 = 6
          HEADER_NOT_ALLOWED            = 7
          SEPARATOR_NOT_ALLOWED         = 8
          FILESIZE_NOT_ALLOWED          = 9
          HEADER_TOO_LONG               = 10
          DP_ERROR_CREATE               = 11
          DP_ERROR_SEND                 = 12
          DP_ERROR_WRITE                = 13
          UNKNOWN_DP_ERROR              = 14
          ACCESS_DENIED                 = 15
          DP_OUT_OF_MEMORY              = 16
          DISK_FULL                     = 17
          DP_TIMEOUT                    = 18
          FILE_NOT_FOUND                = 19
          DATAPROVIDER_EXCEPTION        = 20
          CONTROL_FLUSH_ERROR           = 21
          OTHERS                        = 22
                .
    else.
      ll_len = Ps_AC_APX-fILELEN.
*      move l_filename to gv_filn.
*      move l_mode to gv_filetype.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          BIN_FILESIZE                  = ll_len
          FILENAME                      = l_filename
          FILETYPE                      = l_mode
*       APPEND                        = ' '
*       WRITE_FIELD_SEPARATOR         = ' '
*       HEADER                        = '00'
*       TRUNC_TRAILING_BLANKS         = ' '
*       WRITE_LF                      = 'X'
*       COL_SELECT                    = ' '
*       COL_SELECT_MASK               = ' '
*     IMPORTING
*       FILELENGTH                    =
        TABLES
          DATA_TAB                      = gt_contx
*       DATA_TAB                      = gt_cont
        EXCEPTIONS
          FILE_WRITE_ERROR              = 1
          NO_BATCH                      = 2
          GUI_REFUSE_FILETRANSFER       = 3
          INVALID_TYPE                  = 4
          NO_AUTHORITY                  = 5
          UNKNOWN_ERROR                 = 6
          HEADER_NOT_ALLOWED            = 7
          SEPARATOR_NOT_ALLOWED         = 8
          FILESIZE_NOT_ALLOWED          = 9
          HEADER_TOO_LONG               = 10
          DP_ERROR_CREATE               = 11
          DP_ERROR_SEND                 = 12
          DP_ERROR_WRITE                = 13
          UNKNOWN_DP_ERROR              = 14
          ACCESS_DENIED                 = 15
          DP_OUT_OF_MEMORY              = 16
          DISK_FULL                     = 17
          DP_TIMEOUT                    = 18
          FILE_NOT_FOUND                = 19
          DATAPROVIDER_EXCEPTION        = 20
          CONTROL_FLUSH_ERROR           = 21
          OTHERS                        = 22
                .

    endif.
    IF SY-SUBRC <> 0.
      message s077(zhelp) with 'Download'(007).
      leave screen.
    ENDIF.
  ENDIF.

ENDFORM.                    " save_appendix

*---------------------------------------------------------------------*
*       FORM attachment_list_get                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form attachment_list_get.
  if g_attachments_read is initial.
*    if g_header_data-enccnt > 0.
*      clear g_attachments. clear g_attachments[].
    call function 'SO_ATTACHMENT_LIST_READ'
         EXPORTING
              object_id = g_object_id
         TABLES
              objects   = g_attachments
         EXCEPTIONS
              others    = 1.
    if sy-subrc = 0.
      g_attachments_read = on.
    endif.
  endif.
*  endif.

endform.                    " ATTACHMENT_LIST_GET
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax.

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
            G_CCODE = ist_data-bukrs.
        endif.


*  SELECT single *
*         FROM pa0027
*         INTO wa_pa0027
*         WHERE pernr = cpf_lfb1 AND
*               endda = '99991231' AND
*               sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*  G_CCODE = wa_pa0027-kbu01+0(3).

  else.

  G_CCODE = ZMM_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc <> 0.
       rollback work.
       message e117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    g_TABCTRL100_wa-role_name.
    if sy-subrc <> 0.
       rollback work.
       message e118(zhelp).
    endif.

  endif.

*elseif g_e_fl = 'X'.
*       clear g_e_fl.
*  else.
*  clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
*  clear  ZMM_PREP_ROLEREI-SLOC.
*  clear  ZMM_PREP_ROLEREI-plant.
*  clear  ZMM_PREP_ROLEREI-grp.
*  clear  ZMM_PREP_ROLEREI-approver.
*
*  clear g_read_fl.
*
*endif.

*if g_role_name_flag = 'X'.
*     clear g_role_name_flag.
*     clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
*      clear  ZMM_PREP_ROLEREI-SLOC.
*      clear  ZMM_PREP_ROLEREI-plant.
*      clear  ZMM_PREP_ROLEREI-grp.
*      clear  ZMM_PREP_ROLEREI-approver.
*endif.
*
*
*g_field = 'ZMM_PREP_ROLEREI-PLANT'.

*g_i = g_i + 1.
*
*l_role_name = ZMM_PREP_ROLEREI-role_name.
*
**********************************************************

if old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZMM_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZMM_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if ZMM_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           rollback work.
           message e081(zhelp) with g_TABCTRL100_wa-role_name.
         endif.

   endif.

 endif.

*  endif.

  if not g_TABCTRL100_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE
                                    and werks = g_TABCTRL100_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZMM_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABCTRL100_wa-role_name.

      endif.

   endif.


************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
*  clear   : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF G_CCODE = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'KKL'.
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
  if G_CCODE <> 'KKL'.
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


 if  g_TABCTRL100_wa-role_name = 'M6' or
     g_TABCTRL100_wa-role_name = 'M7' or
     g_TABCTRL100_wa-role_name = 'M8'.

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
   if  not g_TABCTRL100_wa-GRP is initial.

       loop at it_t024 into wa_t024.

           if g_TABCTRL100_wa-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
          rollback work.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( g_TABCTRL100_wa-role_name = 'M13' or
   g_TABCTRL100_wa-role_name = 'M14' or
    g_TABCTRL100_wa-role_name = 'M16' or
    g_TABCTRL100_wa-role_name = 'M18' or
    g_TABCTRL100_wa-role_name = 'M19' ) and
    not g_TABCTRL100_wa-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = g_TABCTRL100_wa-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZMM_PREP_ROLEREI-PLANT'.
       rollback work.
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

    if  not g_TABCTRL100_wa-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if g_TABCTRL100_wa-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
          rollback work.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( g_TABCTRL100_wa-role_name = 'M12' or
       g_TABCTRL100_wa-role_name = 'M17' ) and
       not g_TABCTRL100_wa-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if g_TABCTRL100_wa-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if g_TABCTRL100_wa-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not g_TABCTRL100_wa-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if g_TABCTRL100_wa-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
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

g_att_files_wa-LOGSYS = ZMM_PREP_ROLEREQ-DOCNO+2(10).
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
  loop at ist_itemtab into wa_itemtab.
*** CAB_AJIT Approval check added on 11/12/2006
if wa_itemtab-rej_fl = '' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.

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
            rollback work.
            message i047(zhelp) with zmm_prep_rolegrp-role_type.
            clear okcode_100.
            call screen 100.
          endif.
        endif.
      endif.

   endif.
***
  endloop.
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
     TEXTLINE2          = 'user will get updated message once the reques t is processed '
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
CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Request Status IR'
     TEXTLINE1          =  'Please go to display mode & reply the query of the ICE core team in '
     TEXTLINE2          = 'correspondence  &  save the request.  No re-release or approval reqd.'
     TEXTLINE3          = 'The request will go directly to ICE core team  for further processing.'.
old_ok_code = 'DISPLAY'.
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

ENDFORM.                    " clear1
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

  DATA : l_get6(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'ATTACH MORE'
      TEXT_QUESTION               = 'Do you want to attach more files?'
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
           MOVE 'J' TO g_choice_more.
           WHEN '2'.
             MOVE 'N' TO g_choice_more.
             ENDCASE.
             ENDIF.

" End of <RD1K960036>.
ENDFORM.                    " confirm_more

*--- INCLUDE: MZMMPREPROLE1I01 ---*
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

*  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

    select single * from zmm_prep_rolegrp where role_type =
                    ZMM_PREP_ROLEREI-role_name.

*    select single * from zmm_prep_crcdesg where role_type =
*                    ZMM_PREP_ROLEREI-role_name .

    if sy-subrc <> 0 .
       g_val_err = 'X'.
       message i102(zhelp) with zmm_prep_rolerei-role_name .
       g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
    endif.

*  endif.

  if ZMM_PREP_ROLEREI-rej_fl = '' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.

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
   if old_ok_code = 'CRCROLES' or zmm_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_TABCTRL100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      endif.
   else.
      select single * from zmm_prep_roledes where role_type =
                    ZMM_PREP_ROLEREI-role_name.
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
  OKCODE = sy-ucomm.
  perform user_ok_tc using    'TABCTRL100'
                              'G_TABCTRL100_ITAB'
                              'FLAG'
                     changing OKCODE.
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
  TYPES :
           BEGIN of ty_bukrs,
             werks like zd_t001w_bukrs-werks,
             name1 like zd_t001w_bukrs-name1,
           END of ty_bukrs.

  DATA   : it_bukrs type table of ty_bukrs with header line.

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

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
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

G_CCODE = ZMM_PREP_ROLEREQ-CCODE.

endif.

loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREI-GRP' and screen-input = 0
.
        dis_flag = 'X'.
      endif.

  endloop.


  DATA : l_ekgrp like t024-ekgrp.
  refresh : it_cond.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF G_CCODE = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'KKL'.
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
  if G_CCODE <> 'KKL'.
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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-GRP'
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

      if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
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

 if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

     g_field_wa-tabname = 'ZMM_PREP_ROLECRC'.
     g_field_wa-fieldname = 'ROLE_TYPE'.
     append g_field_wa to g_field_tab.
     g_field_wa-tabname = 'ZMM_PREP_ROLECRC'.
     g_field_wa-fieldname = 'BRIEF_DESC'.
     append g_field_wa to g_field_tab.
     g_field_wa-tabname = 'ZMM_PREP_ROLECRC'.
     g_field_wa-fieldname = 'DETAIL_DESC1'.
     append g_field_wa to g_field_tab.
 else.
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

     if not ZMM_PREP_ROLEREQ-userid is initial.
        perform check_tel.
     endif.

     if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' or
        OLD_OK_CODE = 'CRCROLES'.

        if ZMM_PREP_ROLEREQ-PERSA is initial and
           ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             perform pop_up_message.
        endif.

        if ZMM_PREP_ROLEREQ-userid is initial.
          message e035(zhelp).
        endif.

        if ZMM_PREP_ROLEREQ-userid <> old_userid and
          old_userid <> ''.
          clear ZMM_PREP_ROLEREQ-DISC_MM_FLAG.
          clear ZMM_PREP_ROLEREQ-CCODE.
          clear ZMM_PREP_ROLEREQ-FUNDC1.
          clear ZMM_PREP_ROLEREQ-FUNDC.
          clear ZMM_PREP_ROLEREQ-S_DESC.
          clear ZMM_PREP_ROLEREQ-RSN_CODE.
          clear ZMM_PREP_ROLEREQ-RSN_TEXT1.
          clear ZMM_PREP_ROLEREQ-REASON1.
          clear ZMM_PREP_ROLEREQ-TELNO.
          clear ZMM_PREP_ROLEREQ-NAME.
          clear ZMM_PREP_ROLEREQ-DESIGNATION.
          clear set_disc_mm_flag.
          clear help_list_flag.
          refresh it_m_fistb.
          clear wa_m_fistb.
        endif.

*        select single * from zusrmst where cpfno =
*                                   ZMM_PREP_ROLEREQ-userid.

        select single * from usr02 where bname =
                                   ZMM_PREP_ROLEREQ-userid.

        if sy-subrc ne 0.
          message e043(zhelp).
        else.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*          ZMM_PREP_ROLEREQ-name = zusrmst-last_name.
*          ZMM_PREP_ROLEREQ-designation = zusrmst-designation.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
            ZMM_PREP_ROLEREQ-NAME = ist_data-name.
            ZMM_PREP_ROLEREQ-DESIGNATION = ist_data-designation.
            if ist_data-disc_cd = '36' and set_disc_mm_flag <> 'X'.
                ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
                set_disc_mm_flag = 'X'.
            endif.
***************************************************31.05.2006
             if old_ok_code = 'CREATE' or old_ok_code = 'CRCROLES'.
              ZMM_PREP_ROLEREQ-CCODE = ist_data-bukrs.
             else.
              G_CCODE_CROSSCO        = ist_data-bukrs.
             endif.

***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*            ZMM_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

            if old_ok_code = 'CREATE'.
                if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
                   not ZMM_PREP_ROLEREQ-PERSA is initial.
                   message e108(zhelp).
                endif.
            endif.

        endif.

       clear : ist_data.
       refresh : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006


          concatenate '000' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.

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
              ZMM_PREP_ROLEREQ-FUNDC1 = fmzuob-fistl.
              ZMM_PREP_ROLEREQ-FUNDC_FL = 'X'.
*              ZMM_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
              ZMM_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             else.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
              ZMM_PREP_ROLEREQ-COSTC = wa_pa0027-kst01.
             endif.

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

***************************************************

***************************************************

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

    When 'COPY'.


    When 'DISPLAY'.

      old_ok_code = okcode_100.

*    When 'MULTI'.
*
*      call screen 120 STARTING AT 10 5
*                  ENDING   AT 90 15.
*      clear okcode_100.

    WHEN 'SAV'.

      if old_ok_code = 'DELETE'.

          if ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.

*            if ZMM_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            if ZMM_PREP_ROLEREQ-STATUS = ''.
              Perform delete_request.
            else.
              message e138(ZHELP).
            endif.
          else.
            message e056(ZHELP).
          endif.
      else.
        describe table g_TABCTRL100_itab lines g_lines_rl.
        if g_lines_rl = 0.
           clear okcode_100.
           message i140(zhelp).
        else.
        if old_ok_code = 'RELEASE' and
              ZMM_PREP_ROLEREQ-req_cr_fl <> 'X'.
              message i083(zhelp).

        elseif old_ok_code = 'RELEASE' and g_lines_rl = 0.
              message i089(zhelp).

        elseif old_ok_code = 'APPROVE' and
              ( ZMM_PREP_ROLEREQ-req_app_fl <> 'X' and
              ZMM_PREP_ROLEREQ-req_app0_fl <> 'X' and
              ZMM_PREP_ROLEREQ-req_app1_fl <> 'X' ).
              message i087(zhelp).
        else.
          Perform check_items.
*          Perform check_items_save.
          Perform Save_request.
        endif.
       endif.
      endif.

    When 'MULTI'.

*      clear help_list_flag.

      call screen 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      clear okcode_100.


    WHEN 'DELETE'.

       old_ok_code = okcode_100.

    WHEN 'ATTACH'.

       if old_ok_code = 'CREATE' or
          old_ok_code = 'CROSSCO' or
          old_ok_code = 'CRCROLES'.
          message i137(zhelp).
       else.
          perform attach_files.
          if old_ok_code = 'DISPLAY' and
             ZMM_PREP_ROLEREQ-status = 'IR'.
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

    WHEN 'CRCROLES'.

       old_ok_code = okcode_100.

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

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
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
                    clear g_hd_copied.
*           if old_doc_no <> '' and ZMM_PREP_ROLEREq-docno <> ''.
*                    clear wa_m_fistb.
*                    refresh it_m_fistb.
*           endif.
*                 perform clear.
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
  if ( old_ok_code = 'CREATE' )
  or ( old_ok_code = 'CROSSCO' )
  or ( old_ok_code = 'CRCROLES' )
  or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' )
   or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
  .

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
  DATA   : it_excp_sl type table of zmm_prep_sl_excp with header line.
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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-SLOC'
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
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'
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

old_doc_no = ZMM_PREP_ROLEREq-docno.
old_userid = ZMM_PREP_ROLEREq-userid.
old_disc_mm_flag = ZMM_PREP_ROLEREq-disc_mm_flag.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

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
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
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

G_CCODE = ZMM_PREP_ROLEREQ-CCODE.

endif.

if g_read_fl <> 'X'.

*  clear g_e_fl.

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc <> 0.
       g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
       message i117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    ZMM_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
       g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
       message i118(zhelp).
    endif.

  endif.

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

if g_role_name_flag = 'X'.
     clear g_role_name_flag.
     clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
      clear  ZMM_PREP_ROLEREI-SLOC.
      clear  ZMM_PREP_ROLEREI-plant.
      clear  ZMM_PREP_ROLEREI-grp.
      clear  ZMM_PREP_ROLEREI-approver.
endif.


g_field = 'ZMM_PREP_ROLEREI-PLANT'.

g_i = g_curr_line.

l_role_name = ZMM_PREP_ROLEREI-role_name.

**********************************************************

if old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZMM_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZMM_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if ZMM_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           if ZMM_PREP_ROLEREI-role_name <> ''.
             message e081(zhelp) with ZMM_PREP_ROLEREI-role_name.
           endif.
         endif.

   endif.

 endif.

*  endif.

  if not ZMM_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE
                                    and werks = ZMM_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZMM_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line.
           message e068(zhelp) with ZMM_PREP_ROLEREI-role_name.

      endif.

   endif.

************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF G_CCODE = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'KKL'.
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
  if G_CCODE <> 'KKL'.
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
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
          move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.
          modify g_TABCTRL100_itab
                    from g_TABCTRL100_wa
                      index TABCTRL100-current_line.
          g_i = TABCTRL100-current_line.
          message i069(zhelp).
          call screen 100.

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
       g_field = 'ZMM_PREP_ROLEREI-PLANT'.
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
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
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
           g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
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


endif.

ENDMODULE.                 " validate_lineitem_data  INPUT
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
      if g_user = 'L1' and ZMM_PREP_ROLEREI-rej_fl <> 'R'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'L3' and ZMM_PREP_ROLEREI-rej_fl <> 'B'.
        g_e_fl = 'X'.
        message e111(zhelp).
      elseif g_user = 'IM' and ZMM_PREP_ROLEREI-rej_fl <> 'I'.
        g_e_fl = 'X'.
        message e111(zhelp).
      endif.
    endif.
endif.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.

data : tel_len type i.
  tel_len = strlen( ZMM_PREP_ROLEREQ-TELNO ).
  if  ZMM_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
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
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
else.

   select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.

endif.

if g_role_name_prev <> ZMM_PREP_ROLEREI-role_name and
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
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup INPUT.
if not g_TABCTRL100_itab[] is initial .

  delete adjacent duplicates from g_TABCTRL100_itab
  comparing role_name plant grp sloc receipt_loc approver role_type_ex
  crc_pos.
endif.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
g_role_name_prev = ZMM_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fundc_data INPUT.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZMM_PREP_ROLEREQ-FUNDC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc <> 0.
     message i166(zhelp).
     g_field =  'ZMM_PREP_ROLEREQ-FUNDC'.
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

*--- INCLUDE: MZMMPREPROLE1O01 ---*
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

  l_docno = zmm_prep_rolereq-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

  zmm_prep_rolereq-docno = l_docno.

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
        if not zmm_prep_rolereq-docno is initial.
          perform lock_reqhd.
        endif.
      endif.

      if sy-subrc = 0 and not zmm_prep_rolereq-docno is initial.

*        g_hd_copied = 'X'.

        clear g_TABCTRL100_itab.
        refresh g_TABCTRL100_itab.

        select * from ZMM_PREP_ROLEREI into corresponding
                  fields of table g_TABCTRL100_itab
                    where DOCNO = ZMM_PREP_ROLEREQ-docno.

**************************
       clear g_srno.
**************************

      endif.

      if not ZMM_PREP_ROLEREQ-docno is initial.

        select single * from ZMM_PREP_ROLEREQ
                   where DOCNO = ZMM_PREP_ROLEREQ-docno.

        if sy-subrc = 0 .

            g_hd_copied = 'X'.

            if ZMM_PREP_ROLEREQ-comm_fl = 'X' and old_ok_code = 'CHANGE'
.
*                  perform verify1.
                  perform verify2.
            endif.

            perform validations.

        else.
           message i101(zhelp) with ZMM_PREP_ROLEREQ-docno.
        endif.

       endif.

      endif.

*      select single * from ZMM_PREP_RSN
*                 where REASON = ZMM_PREP_ROLEREQ-RSN_CODE.
*
*      if sy-subrc = 0.
*
*          ZMM_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.
*
*      endif.

       select single * from T500P
                 where PERSA = ZMM_PREP_ROLEREQ-PERSA.

      if sy-subrc = 0.

          ZMM_PREP_ROLEREQ-NAME1 = T500P-NAME1.

      endif.


   endif.

endif.

      select single * from ZMM_PREP_RSN
                 where REASON = ZMM_PREP_ROLEREQ-RSN_CODE.

      if sy-subrc = 0.

          ZMM_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

      endif.

    if ZMM_PREP_ROLEREQ-fundc <> '' and ZMM_PREP_ROLEREQ-REASON1 = ''.

       set cursor field 'ZMM_PREP_ROLEREQ-REASON1'.
        message i100(zhelp).
    endif.

    perform get_correspondense.

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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
           if ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
*             perform pop_up_message.
           else.
            clear : ZMM_PREP_ROLEREQ-PERSA, ZMM_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
            screen-input = 0.
            modify screen.
       endif.

       if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC' ) and
                   g_error_fundc = 'X'.
            screen-input = 1.
            clear g_error_fundc.
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

       if screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
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

       if screen-name = 'TABCTRL100_DELETE' or
           screen-name = 'TABCTRL100_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
       endif.

       if g_user = 'L1' and screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP1_FL'
.
              screen-input = 1.
              modify screen.
       endif.

       if ( g_user = 'IM' ) and
           screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP0_FL'.
              screen-input = 1.
              modify screen.
       endif.
       if ( g_user = 'L3' ) and
           screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP_FL'.
              screen-input = 1.
              modify screen.
       endif.

       if screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.

       endif.

       if screen-name = 'ZMM_PREP_ROLEREQ-FUNDC' or
          screen-name = 'ZMM_PREP_ROLEREQ-REASON1'.
          screen-input = 0.
          modify screen.
       endif.

    endloop.

    when 'CROSSCO'.

     loop at screen.

       if screen-group1 = 'GP1' or
           screen-group4 = 'GP4'.
           screen-input = 1.
           if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
           if ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZMM_PREP_ROLEREQ-PERSA, ZMM_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

        if screen-group3 = 'GPC' .
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'ZMM_PREP_ROLEREQ-CCODE' and
          not ZMM_PREP_ROLEREQ-CCODE is initial .
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
          screen-name = 'IN'.
           screen-active = 0.
           screen-invisible = 1.
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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
           if ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZMM_PREP_ROLEREQ-PERSA, ZMM_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.


          if ( screen-name = 'ZMM_PREP_ROLEREQ-FR_DATE_AUTH' or
                screen-name = 'ZMM_PREP_ROLEREQ-TO_DATE_AUTH' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 0.
          else.
            if ( screen-name = 'ZMM_PREP_ROLEREQ-OFF_ORDER_NO' or
                screen-name = 'ZMM_PREP_ROLEREQ-OFF_ORDER_DATE' ).
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

          if screen-name = 'ZMM_PREP_ROLEREQ-REASON1'.
         if not ZMM_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.
*added on 26/12/2006
        if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-input = 1.
              modify screen.
        endif.

    endloop.

ENDCASE.
ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL100_init output.

  perform get_user.

*  describe table g_TABCTRL100_itab lines TABCTRL100-lines.

*  if g_TABCTRL100_copied is initial.
   if g_hd_copied is initial.
*&spwizard: copy ddic-table 'ZMM_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABCTRL100_itab'
*    select * from ZMM_PREP_ROLEREI
*       into corresponding fields
*       of table g_TABCTRL100_itab.
*    g_TABCTRL100_copied = 'X'.
    refresh control 'TABCTRL100' from screen '0100'.
    data l_fis_initial.
    set parameter id 'FIS' field l_fis_initial.
    set parameter id 'BUK' field l_fis_initial.
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
      if sy-subrc = 0 .
         move zmm_prep_rolecrc-brief_desc to role_desc.
     endif.
     SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZMM_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 .
         move zmm_prep_crcdesg-crc_pos to crc_pos.
     endif.
    else.
      select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.
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
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
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
      elseif ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
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

        if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .

            if zmm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-GRP'.

            if zmm_prep_roledes-P_GRP = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
             else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-APPROVER'.

              if zmm_prep_roledes-APP_LEVEL = 'X' and
                          old_ok_code <> 'APPROVE'.
                  screen-input = 1.
                  modify screen.
              else.
                  screen-input = 0.
                  modify screen.
              endif.

        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

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

        if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

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

         if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZMM_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZMM_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

  if ZMM_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc = 0.

     loop at screen.

       if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
       endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .


           if zmm_prep_rolecrc-plant = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-required = 1.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-GRP' .


           if zmm_prep_rolecrc-P_GRP = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-required = 1.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

                if zmm_prep_rolecrc-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.                   screen-required = 1.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.                   screen-required = 1.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

        if screen-name = 'CRC_POS' and
              ( ZMM_PREP_ROLEREI-role_name <> 'M3B' and
                ZMM_PREP_ROLEREI-role_name <> 'M11S' and
                ZMM_PREP_ROLEREI-role_name <> 'M11M' ).
                if old_ok_code <> 'APPROVE'.
                    screen-required = 1.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and
               ( ZMM_PREP_ROLEREI-role_name = 'M3B' or
                ZMM_PREP_ROLEREI-role_name = 'M11S' or
                ZMM_PREP_ROLEREI-role_name = 'M11M' ).
.          screen-input = 1.
        elseif screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and
               ( ZMM_PREP_ROLEREI-role_name <> 'M3B' and
                ZMM_PREP_ROLEREI-role_name <> 'M11S' and
                ZMM_PREP_ROLEREI-role_name <> 'M11M' ).
           screen-input = 0.
        endif.

        modify screen.
*

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

if ZMM_PREP_ROLEREI-REJ_FL <> ''.
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

  if ( old_ok_code = 'CREATE' )
  or ( old_ok_code = 'CROSSCO' )
  or ( old_ok_code = 'CRCROLES' )
  or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' )
  or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
  .

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
       or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
  .

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

*if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

if not g_TABCTRL100_itab[] is initial .

  sort g_TABCTRL100_itab
  by role_name plant grp sloc receipt_loc approver.
  delete adjacent duplicates from g_TABCTRL100_itab
  comparing role_name plant grp sloc receipt_loc approver role_type_ex
  crc_pos.

endif.

describe table g_TABCTRL100_itab lines TABCTRL100-lines.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.

describe table g_TABCTRL100_itab lines TABCTRL100-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZMM_PREP_ROLEREI-ROLE_NAME' line g_curr_line.
endif.
clear sy-ucomm.
ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
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
    if ZMM_PREP_ROLEREQ-CRC_FL = 'X' or
       ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    else.
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    endif.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DELETE' and ( okcode_100 = '' or
    okcode_100 = 'DELETE' or okcode_100 = 'LIST') .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DISPLAY'
   and zmm_prep_rolereq-comm_fl = 'X'.
   SET PF-STATUS 'OPTNS' excluding it_tab.
else.

  if old_ok_code = 'DISPLAY' and ( okcode_100 = '' or
      okcode_100 = 'DISPLAY' or okcode_100 = 'LIST') .
      move 'ATTACH' to wa_tab-fcode.
      append wa_tab to it_tab.
      SET PF-STATUS 'OPTNS' excluding it_tab.
  endif.

endif.

if old_ok_code = 'APPROVE' and ( okcode_100 = '' or
    okcode_100 = 'APPROVE' or okcode_100 = 'LIST') .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
    g_text = ' : CRC Authorisation'.
    SET TITLEBAR 'PREP_TITLE' with g_text.
endif.

ENDMODULE.                 " set_title  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ICE_ARMS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ICE_ARMS OUTPUT.

if sy-tcode = 'ZMM_ARMS'.

CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
  EXPORTING
   TITEL              = 'ZMM_ARMS Transaction'
   TEXTLINE1          = 'This transaction has been discontinued'
   TEXTLINE2          = 'Please use ZICE_ARMS in place of ZMM_ARMS'
*   START_COLUMN       = 25
*   START_ROW          = 6
          .
endif.
LEAVE PROGRAM.
ENDMODULE.                 " ICE_ARMS  OUTPUT

*--- INCLUDE: MZMMPREPROLE1TOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZMM_PREP_ROLEREQ, ZMM_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
ZMM_PREP_REJ_LIS, ZMM_PREP_EX_APP, soodk, sood5, ZMM_PREP_ROLECRC,
zmm_prep_sl_excp,zmm_prep_crcdesg.

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
DATA : crc_pos(132).


*&spwizard: type for the data of tablecontrol 'TABCTRL100'
types: begin of t_TABCTRL100,
         DOCNO like ZMM_PREP_ROLEREI-DOCNO,
         ROLE_REQUEST like ZMM_PREP_ROLEREI-ROLE_REQUEST,
         ROLE_NAME like ZMM_PREP_ROLEREI-ROLE_NAME,
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
         crc_pos(132),
       end of t_TABCTRL100.

data: ist_itemtab type standard table of zmm_prep_rolerei.
data: wa_itemtab like zmm_prep_rolerei.

***********************************************************************
data : ist_colsscreen type table of cxtab_column-screen.
data : ist_column type standard table of cxtab_column with non-unique
default key.
***********************************************************************

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
DATA : old_doc_no like ZMM_PREP_ROLEREq-docno.
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
DATA  grp_flag.
DATA  plant_flag.
DATA  loc_flag.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  g_reset_fl.
DATA  g_docno like ZMM_PREP_ROLEREq-docno.
DATA  g_app_rel.
DATA  g_release like ZMM_PREP_ROLEREQ-req_cr_fl.
DATA  g_approve like ZMM_PREP_ROLEREQ-req_app_fl.
DATA  g_approve1 like ZMM_PREP_ROLEREQ-req_app1_fl.
DATA  g_i like sy-index.
DATA  g_tc_lines like sy-index.
DATA  g_comm_fl.
DATA  g_read_fl.
DATA  g_lines_rl like sy-index.
DATA  g_field(40).
DATA  g_e_fl.
DATA  g_role_name_prev like ZMM_PREP_ROLEREI-ROLE_NAME.
DATA  g_role_name_flag.
DATA  g_persa like pa0001-werks.
DATA  g_approve0 like ZMM_PREP_ROLEREQ-req_app1_fl.
DATA  old_disc_mm_flag.
DATA  set_disc_mm_flag.
DATA  CRC_CHECK_FL.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files like table of SWOTOBJID.
data g_att_files_wa like SWOTOBJID.
DATA  old_userid like ZMM_PREP_ROLEREq-userid.
DATA  g_val_err.
DATA  g_lines_2 like sy-index.
DATA  old_ok_code_crc like old_ok_code.
DATA  g_crc_fl.
DATA  G_CCODE like ZMM_PREP_ROLEREQ-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(80).

****************************
data : g_field_tab like table of dfies.
data : g_field_wa  like dfies.
DATA  approver_flag.
DATA  G_CCODE_CROSSCO like ZMM_PREP_ROLEREQ-CCODE.
DATA  g_error_fundc.
DATA  attach_fl.
DATA  status_ir_fl.
DATA  g_choice_more.
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
