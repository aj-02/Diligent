*--- MAIN PROGRAM: SAPMZMMPREPROLE1_PHASEII ---*
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
* Tran. Code : ZICE_ARMS
*              ZIC_ARMS_CONNECT                                       *
*                                                                     *
***********************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
*  1) Changes in INCLUDE MZMMPREPROLE1_PHASEIIF01
* 10.09.2012      <RD1K981840>    CAB_PAREEK
*  1) Changed the type declaration of var. cpf_lfb1
*  2) CR No. 30010832  CAB_SUDHIR
*  3) CR No. 30012322  RD1K996279 CAB_SUDHIR

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

* 24.02.2015   <RD1K996042>  CAB_SPYADAV    CR 30012295(LIPSY)         *
*                                          (Simultaneous assignment of *
*                                           MM  and OLM roles          *
*                                          during approval)            *
*&                                                                     *
*&                                                                     *

* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company ,multi module
*                                           roles,during approval      *
"                                          ,SRM Module introductin)    *
*&                                                                     *
*&                                                                     *
*27.05.2015  CAB_SPYADAV  Changes as per CR No.30012757(lipsy) <RD1K997318>
*28.12.2015  CAB_SPYADAV  Changes as per CR No.30013609(lipsy) <RD1K999362>
""""""""""""""""""""""""""""""""""""""""""""""""""""""

************************************************************************


INCLUDE MZMMPREPROLE1_PHASEIITOP.

INCLUDE MZMMPREPROLE1_PHASEIIO01.

INCLUDE MZMMPREPROLE1_PHASEIII01.

INCLUDE MZMMPREPROLE1_PHASEIIF01.



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

*--- INCLUDE: %_CSLIS ---*
type-pool slis .

types: slis_list_type(1) type n,
       slis_char_1(1) type c,
       slis_text40(40) type c.

types: slis_tabname(30) type c,
       slis_fieldname(30) type c,
       slis_sel_tab_field(60) type c,
       slis_formname(30) type c,
       slis_entry(60) type c,
       slis_edit_mask(60) type c,
       slis_coldesc(4) type c.

*Accessibility
types: slis_qinfo_alv type alv_s_qinf,
       slis_t_qinfo_alv type slis_qinfo_alv occurs 0.

*types: begin of slis_filtered_entries,
*         index type i,
*       end of slis_filtered_entries.
types: slis_t_filtered_entries type i occurs 0.

*--- Structure for additional fieldcat
types: begin of slis_add_fieldcat,
         fieldname type slis_fieldname,
         web_field type slis_fieldname,
         href_hndl type i,
       end of slis_add_fieldcat.
types: slis_t_add_fieldcat type slis_add_fieldcat occurs 0.

*--- Structure for reprep-initialization
types: begin of slis_reprep_id,
         tool(2) type c,
         appl(4) type c,
         subc(2) type c,
         onam(54) type c,
       end of slis_reprep_id.

types: begin of slis_reprep_communication,
         stop(1) type c,
       end of slis_reprep_communication.

*** Structure for colors
types: begin of slis_color,
         col type i,
         int type i,
         inv type i,
       end of slis_color.

types: begin of slis_coltypes,
         heacolfir      type slis_color, " heading_cols_first
         heacolnex      type slis_color, " heading_cols_nex
         hearowfir      type slis_color, " heading_rows_first
         hearownex      type slis_color, " heading_rows_next
         lisbodfir      type slis_color, " list_body_first
         lisbodnex      type slis_color, " list_body_next
         lisbod         type slis_color, " list_body
         higcolkey      type slis_color, " highlight_col_key
         higcol         type slis_color, " highlight_col
         higrow         type slis_color, " highlight_row
         higsum         type slis_color, " highlight_sum
         higsumhig      type slis_color, " highlight_sum_high
         higsumlow      type slis_color, " highlight_sum_low
         higins         type slis_color, " highlight_inserted
         higpos         type slis_color, " highlight_positive
         higneg         type slis_color, " highlight_negative
         hig            type slis_color, " highlight
         heahie         type slis_color, " heading_hier
         lisbodhie      type slis_color, " list_body_hierinfo
       end of slis_coltypes.

*** Fieldcat
types: begin of slis_fieldcat_main0,
         row_pos        like sy-curow, " output in row
         col_pos        like sy-cucol, " position of the column
         fieldname      type slis_fieldname,
         tabname        type slis_tabname,
         currency(5)    type c,
         cfieldname     type slis_fieldname, " field with currency unit
         ctabname       type slis_tabname,   " and table
         ifieldname     type slis_fieldname, " initial column
         quantity(3)    type c,
         qfieldname     type slis_fieldname, " field with quantity unit
         qtabname       type slis_tabname,   " and table
         round          type i,        " round in write statement
         exponent(3)       type c,     " exponent for floats
         key(1)         type c,        " column with key-color
         icon(1)        type c,        " as icon
         symbol(1)      type c,        " as symbol
         checkbox(1)    type c,        " as checkbox
         just(1)        type c,        " (R)ight (L)eft (C)ent.
         lzero(1)       type c,        " leading zero
         no_sign(1)     type c,        " write no-sign
         no_zero(1)     type c,        " write no-zero
         no_convext(1)  type c,
         edit_mask      type slis_edit_mask,                "
         emphasize(4)   type c,        " emphasize
         fix_column(1)   type c,       " Spalte fixieren
         do_sum(1)      type c,        " sum up
         no_out(1)      type c,        " (O)blig.(X)no out
         tech(1)        type c,        " technical field
         outputlen      like dd03p-outputlen,
         offset         type dd03p-outputlen,     " offset
         seltext_l      like dd03p-scrtext_l, " long key word
         seltext_m      like dd03p-scrtext_m, " middle key word
         seltext_s      like dd03p-scrtext_s, " short key word
         ddictxt(1)     type c,        " (S)hort (M)iddle (L)ong
         rollname       like dd03p-rollname,
         datatype       like dd03p-datatype,
         inttype        like dd03p-inttype,
         intlen         like dd03p-intlen,
         lowercase      like dd03p-lowercase,
         decfloat_style type outputstyle,          " B20K8A2GF0
         parameter0     type char30,
         parameter1     type char30,
         parameter2     type char30,
         parameter3     type char30,
         parameter4     type char30,
         parameter5     type int4,
         parameter6     type int4,
         parameter7     type int4,
         parameter8     type int4,
         parameter9     type int4,
       end of slis_fieldcat_main0.

types: begin of slis_fieldcat_main1,
         ref_fieldname  like dd03p-fieldname,
         ref_tabname    like dd03p-tabname,
         roundfieldname type slis_fieldname,
         roundtabname   type slis_tabname,
         decimalsfieldname type slis_fieldname,
         decimalstabname   type slis_tabname,
         decimals_out(6)   type c,     " decimals in write statement
         text_fieldname type slis_fieldname,
         reptext_ddic   like dd03p-reptext,   " heading (ddic)
         ddic_outputlen like dd03p-outputlen,
       end of slis_fieldcat_main1.

types: begin of slis_fieldcat_main.
include type slis_fieldcat_main0.
include type slis_fieldcat_main1.
types: end of slis_fieldcat_main.

types: begin of slis_fieldcat_alv_spec,
         key_sel(1)     type c,        " field not obligatory
         no_sum(1)      type c,        " do not sum up
         sp_group(4)    type c,        " group specification
         reprep(1)      type c,        " selection for rep/rep
         input(1)       type c,        " input
         edit(1)        type c,        " internal use only
         hotspot(1)     type c,        " hotspot
       end of slis_fieldcat_alv_spec.

types: begin of slis_fieldcat_alv.
include type slis_fieldcat_main.
include type slis_fieldcat_alv_spec.
types: end of slis_fieldcat_alv.

types: begin of slis_fieldcat_alv1.
include type slis_fieldcat_main1.
types: end of slis_fieldcat_alv1.

types: slis_t_fieldcat_alv type slis_fieldcat_alv occurs 1.

* Events for Callback
types: begin of slis_event_exit.
types:   ucomm like sy-ucomm,
         before(1) type c,
         after(1) type c,
       end of slis_event_exit.
types: slis_t_event_exit type slis_event_exit occurs 1.

* Callback Interface structure for non display subtotals text
types: begin of slis_subtot_text,
         criteria type slis_fieldname,
         keyword  like dd03p-reptext,
         criteria_text(255) type c,
         max_len  like dd03p-outputlen,
         display_text_for_subtotal(255) type c,
       end of slis_subtot_text.

*** Layout
types: begin of slis_print_alv0,
         print(1) type c,              " print to spool
         prnt_title(1) type c,         " moment to print the title
       end of slis_print_alv0.

types: begin of slis_print_alv1,
         no_print_selinfos(1) type c,  " display no selection infos
         no_coverpage(1) type c,                            "
         no_new_page(1) type c,                             "
         reserve_lines type i,         " lines reserved for end of page
         no_print_listinfos(1) type c, " display no listinfos
         no_change_print_params(1) type c,  " don't change linesize
         no_print_hierseq_item(1) type c,  "don't expand item
         print_ctrl type ALV_S_Pctl,
       end of slis_print_alv1.

types: begin of slis_print_alv.
include type alv_s_prnt.
include type slis_print_alv1.
types: end of slis_print_alv.

types: begin of slis_layout_main,
         dummy,
       end of slis_layout_main.

types: begin of slis_layout_alv_spec0,
         no_colhead(1) type c,         " no headings
         no_hotspot(1) type c,         " headings not as hotspot
         zebra(1) type c,              " striped pattern
         no_vline(1) type c,           " columns separated by space
         no_hline(1) type c,        "rows separated by space B20K8A0N5D
         cell_merge(1) type c,         " not suppress field replication
         edit(1) type c,               " for grid only
         edit_mode(1) type c,          " for grid only
         numc_sum(1)     type c,       " totals for NUMC-Fields possib.
         no_input(1) type c,           " only display fields
         f2code like sy-ucomm,                              "
         reprep(1) type c,             " report report interface active
         no_keyfix(1) type c,          " do not fix keycolumns
         expand_all(1) type c,         " Expand all positions
         no_author(1) type c,          " No standard authority check
*        PF-status
         def_status(1) type c,         " default status  space or 'A'
         item_text(20) type c,         " Text for item button
         countfname type lvc_fname,
       end of slis_layout_alv_spec0.

types: begin of slis_layout_alv_spec1,
*        Display options
         colwidth_optimize(1) type c,
         no_min_linesize(1) type c,    " line size = width of the list
         min_linesize like sy-linsz,   " if initial min_linesize = 80
         max_linesize like sy-linsz,   " Default 250
         window_titlebar like sy-title,
         no_uline_hs(1) type c,
*        Exceptions
         lights_fieldname type slis_fieldname," fieldname for exception
         lights_tabname type slis_tabname, " fieldname for exception
         lights_rollname like dfies-rollname," rollname f. exceptiondocu
         lights_condense(1) type c,    " fieldname for exception
*        Sums
         no_sumchoice(1) type c,       " no choice for summing up
         no_totalline(1) type c,       " no total line
         no_subchoice(1) type c,       " no choice for subtotals
         no_subtotals(1) type c,       " no subtotals possible
         no_unit_splitting type c,     " no sep. tot.lines by inh.units
         totals_before_items type c,   " diplay totals before the items
         totals_only(1) type c,        " show only totals
         totals_text(60) type c,       " text for 1st col. in total line
         subtotals_text(60) type c,    " text for 1st col. in subtotals
*        Interaction
         box_fieldname type slis_fieldname, " fieldname for checkbox
         box_tabname type slis_tabname," tabname for checkbox
         box_rollname like dd03p-rollname," rollname for checkbox
         expand_fieldname type slis_fieldname, " fieldname flag 'expand'
         hotspot_fieldname type slis_fieldname, " fieldname flag hotspot
         confirmation_prompt,          " confirm. prompt when leaving
         key_hotspot(1) type c,        " keys as hotspot " K_KEYHOT
         flexible_key(1) type c,       " key columns movable,...
         group_buttons(1) type c,      " buttons for COL1 - COL5
         get_selinfos(1) type c,       " read selection screen
         group_change_edit(1) type c,  " Settings by user for new group
         no_scrolling(1) type c,       " no scrolling
*        Detailed screen
         detail_popup(1) type c,       " show detail in popup
         detail_initial_lines(1) type c, " show also initial lines
         detail_titlebar like sy-title," Titlebar for detail
*        Display variants
         header_text(20) type c,       " Text for header button
         default_item(1) type c,       " Items as default
*        colour
         info_fieldname type slis_fieldname, " infofield for listoutput
         coltab_fieldname type slis_fieldname, " colors
*        others
         list_append(1) type c,       " no call screen
         xifunckey type aqs_xikey,    " eXtended interaction(SAPQuery)
         xidirect type flag,          " eXtended INTeraction(SAPQuery)
         dtc_layout type dtc_s_layo,  "Layout for configure the Tabstip
         allow_switch_to_list(1) type c, "ACC: Switch from FullGrid to List
       end of slis_layout_alv_spec1.

types: begin of slis_layout_alv_spec.
include type slis_layout_alv_spec0.
include type slis_layout_alv_spec1.
types: end of slis_layout_alv_spec.

types: begin of slis_layout_alv.
include type slis_layout_main.
include type slis_layout_alv_spec.
types: end of slis_layout_alv.

types: begin of slis_layout_alv1.
include type slis_layout_main.
include type slis_layout_alv_spec1.
types: end of slis_layout_alv1.

*--- Structure for the excluding table (function codes)
types: begin of slis_extab,
         fcode like rsmpe-func,
       end of slis_extab.
*--- Lineinfo before output
types: begin of slis_lineinfo,
         tabname type slis_tabname,
         tabindex like sy-tabix,
         subtot(1) type c,
         subtot_level(2) type n,
         endsum(1) type c,
         sumindex like sy-tabix,
         linsz like sy-linsz,
         linno like sy-linno,
       end of slis_lineinfo.
*--- Structure for scrolling in list
types: begin of slis_list_scroll,
         lsind like sy-lsind,
         cpage like sy-cpage,
         staro like sy-staro,
         staco like sy-staco,
         cursor_line like sy-curow,
         cursor_offset like sy-cucol,
       end of slis_list_scroll.
* information cursor position ALV
types: begin of slis_selfield,
         tabname type slis_tabname,
         tabindex like sy-tabix,
         sumindex like sy-tabix,
         endsum(1) type c,
         sel_tab_field type slis_sel_tab_field,
         value type slis_entry,
         before_action(1) type c,
         after_action(1) type c,
         refresh(1) type c,
         ignore_multi(1) type c, " ignore selection by checkboxes (F2)
         col_stable(1) type c,
         row_stable(1) type c,
*        colwidth_optimize(1) type c,
         exit(1) type c,
         fieldname type slis_fieldname,
         grouplevel type i,
         collect_from type i,
         collect_to type i,
       end of slis_selfield.

*--- excluding table
types: slis_t_extab type slis_extab occurs 1.
* special groups for column selection
types: begin of slis_sp_group_alv,
         sp_group(4) type c,
         text(40) type c,
       end of slis_sp_group_alv.
types: slis_t_sp_group_alv type slis_sp_group_alv occurs 1.

* information for sort and subtotals
types: begin of slis_sortinfo_alv,
*        spos(2) type n,
         spos like alvdynp-sortpos,
         fieldname type slis_fieldname,
         tabname type slis_fieldname,
*        up(1) type c,
*        down(1) type c,
*        group(2) type c,
*        subtot(1) type c,
         up like alvdynp-sortup,
         down like alvdynp-sortdown,
         group like alvdynp-grouplevel,
         subtot like alvdynp-subtotals,
         comp(1) type c,
         expa(1) type c,
         obligatory(1) type c,
       end of slis_sortinfo_alv.
types: slis_t_sortinfo_alv type slis_sortinfo_alv occurs 1.
* information for selections
types: begin of slis_seldis1_alv,
         field like dfies-fieldname,
         table like dfies-tabname,
         stext(40),
         valuf(80),
         valut(80),
         sign0(1),
         optio(2),
         ltext(40),
         stype(1),
         length type p,
         no_text(1),
         inttype like dfies-inttype,
         fieldname type slis_fieldname,
         tabname type slis_tabname,
         org_selname type rsscr_name,  "introduced this FO 09.01.00
       end of slis_seldis1_alv.

types: slis_seldis_alv type slis_seldis1_alv occurs 1.

* filter
types: begin of slis_filter_alv0,
         fieldname type slis_fieldname,
         tabname type slis_tabname,
         seltext(40),
         valuf(80),
         valut(80),
         valuf_int(80),
         valut_int(80),
         sign0(1),
         sign_icon(4),
         optio(2),
         stype(1),
         decimals like dfies-decimals,
         intlen like dfies-intlen,
         convexit like dfies-convexit,
         edit_mask type slis_edit_mask,
         lowercase like dfies-lowercase,
         inttype like dfies-inttype,
         datatype like dfies-datatype,
         exception(1) type c,
         no_sign(1) type c,
         or(1) type c,
         order type order,
         cqvalue(5) type c,
       end of slis_filter_alv0.

types: begin of slis_filter_alv1,
         ref_fieldname like dfies-fieldname,
         ref_tabname like dfies-tabname,
         ddic_outputlen like dfies-outputlen,
       end of slis_filter_alv1.

types: begin of slis_filter_alv.
include type slis_filter_alv0.
include type slis_filter_alv1.
types: end of slis_filter_alv.
types: slis_t_filter_alv type slis_filter_alv occurs 1.

* delete or add an entry in the select-option info
types: begin of slis_selentry_hide_alv,
         mode(1) type c,               "(D)elete (A)dd
         selname like rsparams-selname.
include type slis_seldis1_alv.
types  end of slis_selentry_hide_alv.
types: slis_t_selentry_hide_alv type slis_selentry_hide_alv occurs 1.

* delete or add an entry in the select-option info
types: begin of slis_sel_hide_alv,
         mode(1) type c,               "(R)eplace or (C)hange
         t_entries type slis_t_selentry_hide_alv,
       end of slis_sel_hide_alv.
* Header table for top of page
types: begin of slis_listheader,
         typ(1) type c,   " H = Header, S = Selection, A = Action
         key(20) type c,
         info type slis_entry,
       end of slis_listheader.
types: slis_t_listheader type slis_listheader occurs 1.
*--- Structure for specific color settings
types: begin of slis_specialcol_alv,
         fieldname type slis_fieldname,
         color     type slis_color,
         nokeycol(1) type c,
       end of slis_specialcol_alv.
types: slis_t_specialcol_alv type slis_specialcol_alv occurs 1.
*--- Structure for event handling
types: begin of slis_alv_event,
        name(30),
        form(30),
      end of slis_alv_event.
types: slis_t_event type slis_alv_event occurs 0.
*--- Structure for key information
types: begin of slis_keyinfo_alv,
         header01 type slis_fieldname,
         item01 type slis_fieldname,
         header02 type slis_fieldname,
         item02 type slis_fieldname,
         header03 type slis_fieldname,
         item03 type slis_fieldname,
         header04 type slis_fieldname,
         item04 type slis_fieldname,
         header05 type slis_fieldname,
         item05 type slis_fieldname,
       end of slis_keyinfo_alv.
*--- Structure for callback CALLER_EXIT and REUSE_ALV_POPUP_TO_SELECT
types: begin of slis_data_caller_exit,
        dummy like sy-repid,
        without_load_variant(1),
        callback_header_transport type slis_formname,
        columnopt(1),
      end of slis_data_caller_exit.

types: begin of slis_status,
         callback_program like sy-repid,
         callback_pf_status_set type slis_formname,
         callback_user_command  type slis_formname,
         counter_of_lists_added type i,
         actual_list_to_display type i,
         flg_to_be_refreshed,
         it_excluding type slis_t_extab,
         print type slis_print_alv,
         flg_checkboxes_active,
         flg_overview_active,
         flg_intcheck(1) type c,
       end of slis_status.
* Exporting structure
types: begin of slis_exit_by_user,
         back(1) type c,
         exit(1) type c,
         cancel(1) type c,
       end of slis_exit_by_user.

constants:
* Events
slis_ev_item_data_expand   type slis_formname value 'ITEM_DATA_EXPAND',
slis_ev_reprep_sel_modify  type slis_formname value 'REPREP_SEL_MODIFY',
slis_ev_caller_exit_at_start type slis_formname value 'CALLER_EXIT',
slis_ev_user_command       type slis_formname value 'USER_COMMAND',
slis_ev_top_of_page        type slis_formname value 'TOP_OF_PAGE',
slis_ev_data_changed       type slis_formname value 'DATA_CHANGED',
slis_ev_top_of_coverpage   type slis_formname value 'TOP_OF_COVERPAGE',
slis_ev_end_of_coverpage   type slis_formname value 'END_OF_COVERPAGE',
slis_ev_foreign_top_of_page type slis_formname
                                       value 'FOREIGN_TOP_OF_PAGE',
slis_ev_foreign_end_of_page type slis_formname
                                       value 'FOREIGN_END_OF_PAGE',
slis_ev_pf_status_set      type slis_formname value 'PF_STATUS_SET',
slis_ev_list_modify        type slis_formname value 'LIST_MODIFY',
slis_ev_top_of_list        type slis_formname value 'TOP_OF_LIST',
slis_ev_end_of_page        type slis_formname value 'END_OF_PAGE',
slis_ev_end_of_list        type slis_formname value 'END_OF_LIST',
slis_ev_after_line_output  type slis_formname value 'AFTER_LINE_OUTPUT',
slis_ev_before_line_output type slis_formname value
                                                   'BEFORE_LINE_OUTPUT',
slis_ev_subtotal_text      type slis_formname value 'SUBTOTAL_TEXT',
slis_ev_grouplevel_change  type slis_formname value 'GROUPLEVEL_CHANGE',
slis_ev_context_menu       type slis_formname value 'CONTEXT_MENU',

slis_ev_print_top_of_list  type slis_formname value 'PRINT_TOP_OF_LIST',
slis_ev_print_end_of_list  type slis_formname value 'PRINT_END_OF_LIST'.

*lowercase for DDIC_SCAN
types: slis_fieldinfo type fieldinfo.
types: begin of slis_fieldinfo2.
types: lowercase type c.
       include type slis_fieldinfo.
types: end of slis_fieldinfo2.
types: slis_t_fieldinfo2 type standard table of slis_fieldinfo2.

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

*--- INCLUDE: CL_GOS_MANAGER================CU ---*
class CL_GOS_MANAGER definition
  public
  inheriting from CL_GOS_VIEW_MANAGER
  final
  create public .

*"* public components of class CL_GOS_MANAGER
*"* do not include other source files here!!!
public section.

  constants CP_MODE_PUBLICATION type SGS_VMODE value 0. "#EC NOTEXT   "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      !IO_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IS_BC_OBJECT type SIBFLPOR optional
      !IS_OBJECT type BORIDENT optional
      !IT_SERVICE_SELECTION type TGOS_SELS optional
      !IO_CALLBACK type ref to IF_GOS_CALLBACK optional
      !IP_START_DIRECT type SGS_FLAG default space
      !IP_NO_INSTANCE type SGS_FLAG default space
      !IP_NO_COMMIT type SGS_CMODE default 'X'
      !IP_MODE type SGS_RWMOD default 'E'
      !IP_VSI_PROFILE type VSCAN_PROFILE optional
    exceptions
      OBJECT_INVALID
      CALLBACK_INVALID .
  methods UNPUBLISH .
  methods SET_ID_OF_PUBLISHED_OBJECT
    importing
      !IS_BC_OBJECT type SIBFLPOR optional
      !IS_OBJECT type BORIDENT optional
    exceptions
      NO_PUBLICATION .
  methods GET_ICON_NAME
    returning
      value(RV_ICON_NAME) type ICONNAME .
  methods UPDATE_ICON
    returning
      value(RV_UPDATE) type FLAG .

*--- INCLUDE: CL_GOS_TOOLBOX_MODEL==========CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_GOS_TOOLBOX_MODEL and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_GOS_TOOLBOX_VIEW===========CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_GOS_TOOLBOX_VIEW and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_GOS_VIEW_MANAGER===========CU ---*
class CL_GOS_VIEW_MANAGER definition
  public
  create public .

public section.

*"* public components of class CL_GOS_VIEW_MANAGER
*"* do not include other source files here!!!
  events OBJECT_CREATED
    exporting
      value(ES_LPOR) type SIBFLPORB .
  events GOS_MENU_SELECTED
    exporting
      value(IP_FCODE) type UI_FUNC
      value(IO_MENU) type ref to CL_CTMENU .
  events MODE_CHANGED
    exporting
      value(EP_MODE) type SGS_RWMOD .

  methods START_SERVICE_DIRECT
    importing
      !IP_SERVICE type SGS_SRVNAM
      !IS_BC_OBJECT type SIBFLPOR optional
      !IS_OBJECT type BORIDENT optional
      !IO_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IP_CHECK_AVAILABLE type SGS_FLAG optional
      !IP_NO_CHECK type SGS_FLAG optional
    exporting
      !EP_AVAILABLE type C
    exceptions
      NO_OBJECT
      OBJECT_INVALID
      EXECUTION_FAILED .
  methods GET_CONTEXT_MENU
    importing
      !IS_BC_OBJECT type SIBFLPOR optional
      !IS_OBJECT type BORIDENT optional
    exporting
      !EO_MENU type ref to CL_CTMENU .
  methods CONSTRUCTOR
    importing
      !IT_SELECTED_SERVICE type TGOS_SELS optional
    exceptions
      OBJECT_INVALID .
  methods DISPATCH_MENU_COMMAND
    importing
      !IP_FCODE type UI_FUNC
      !IO_MENU type ref to CL_CTMENU optional
    exceptions
      NO_MENU_OPENED .
  methods DISPLAY_TOOLBOX
    importing
      !IO_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IS_BC_OBJECT type SIBFLPOR optional
      !IS_OBJECT type BORIDENT optional
      !IP_SERVICE type SGS_SRVNAM optional
      !IP_PROCESS_DYNPRO type SYUCOMM optional .
  methods PUBLICATION_CHANGED .
  methods SET_RW_MODE
  final
    importing
      !IP_MODE type SGS_RWMOD .

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


*--- INCLUDE: CL_SIMPLEPROPBAG==============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_SIMPLEPROPBAG and it's users.
*" touched if any type reference has been changed

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

*--- INCLUDE: IF_GOS_CALLBACK===============IT ---*

*--- INCLUDE: IF_MESSAGE====================IT ---*

*--- INCLUDE: IF_T100_MESSAGE===============IT ---*

*--- INCLUDE: MZMMPREPROLE1_PHASEIIF01 ---*
*  ************************************************************************
*  Date            Transport      USERID        Description
* 12/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced by POPUP_TO_CONFIRM.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
* CR No. 30012322  RD1K996279 CAB_SUDHIR
*
*1)Change in Line 558.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* 24.02.2015   <RD1K996042>  CAB_SPYADAV    CR 30012295(LIPSY)         *
*                                          (Simultaneous assignment of *
*                                           MM  and OLM roles          *
*                                          during approval)            *
*&                                                                     *
*&                                                                     *
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company ,multi module
*                                           roles,during approval      *
"                                          ,SRM Module introductin)    *
*&                                                                     *
*&                                                                     *

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
FORM BAC_CONFIRM.

  DATA L_CHOICE.
  CLEAR L_CHOICE.
  IF G_MODE <> 'DIS'.

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
    DATA : L_GET1(1) TYPE C.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'BACK '
        TEXT_QUESTION         = 'Data will be lost, Want to quit? '
        DISPLAY_CANCEL_BUTTON = ' '
        START_COLUMN          = 25
        START_ROW             = 6
      IMPORTING
        ANSWER                = L_GET1
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1
        OTHERS                = 2.

    IF SY-SUBRC = 0.
      CASE L_GET1.
        WHEN '1'.
          MOVE 'J' TO L_CHOICE.
        WHEN '2'.
          MOVE 'N' TO L_CHOICE.
      ENDCASE.
    ENDIF.
    " End of <RD1K960036>.

    IF L_CHOICE = 'J'.
*       perform clear_var.
      CLEAR L_CHOICE.
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
FORM FILL_STTAB.

  IF SY-TCODE = 'ZIC_ARMS_CONNECT'.
    OLD_OK_CODE = 'DISPLAY'.
    GET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
  ENDIF.

  REFRESH IT_TAB.
  CLEAR WA_TAB.

  IF OLD_OK_CODE =  'CREATE' OR
        OLD_OK_CODE = 'CROSSCO' OR
        OLD_OK_CODE = 'CRCROLES' OR
        OLD_OK_CODE =  'CHANGE' OR
        OLD_OK_CODE =  'RELEASE' OR
        OLD_OK_CODE =  'APPROVE' OR
        OLD_OK_CODE = 'DISPLAY'  OR
        OLD_OK_CODE = 'DELETE'.

    MOVE 'CREATE' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'CHANGE' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'DELETE' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'DISPLAY' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'RELEASE' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'APPROVE' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'SUIM' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'ROLE_DEL' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'CROSSCO' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'CRCROLES' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
*     move 'ATTACH' to wa_tab-fcode.
*     append wa_tab to it_tab.

  ELSE.

    MOVE 'CHECK' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'ATTACH' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'LIST' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'SAV' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.

*    MOVE 'CRCROLES' TO wa_tab-fcode.
*    APPEND wa_tab TO it_tab.
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
FORM LOCK_REQHD.

  CALL FUNCTION 'ENQUEUE_EZ_IC_PREPHDR'
    EXPORTING
*     MODE_ZMM_CDHD         = 'E'
      MODE_ZIC_PREP_ROLEREQ = 'E'
      MANDT                 = SY-MANDT
      DOCNO                 = ZIC_PREP_ROLEREQ-DOCNO
    EXCEPTIONS
      FOREIGN_LOCK          = 1
      SYSTEM_FAILURE        = 2
      OTHERS                = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    MOVE 'Y' TO G_LOCK.
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
FORM GET_CORRESPONDENCE.

  DATA : L_CORS LIKE THEAD-TDNAME.

  IF OLD_OK_CODE <> 'CREATE' OR
     OLD_OK_CODE <> 'CROSSCO'.

    REFRESH LINES_CORS.

    MOVE ZIC_PREP_ROLEREQ-DOCNO TO L_CORS.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = '0001'
        LANGUAGE                = SY-LANGU
        NAME                    = L_CORS
        OBJECT                  = 'ZHELP'
      TABLES
        LINES                   = LINES_CORS
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
      READ_FLAG = ''.
      ZIC_PREP_ROLEREQ-LONG_TEXT_FL = ''.
    ELSE.
      READ_FLAG = 'X'.
      ZIC_PREP_ROLEREQ-LONG_TEXT_FL = 'X'.
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
  DATA: L_OK     TYPE SY-UCOMM,
        L_OFFSET TYPE I.
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
      G_INS_FLAG = 'X'.

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
FORM FCODE_INSERT_ROW
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
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line and new cursor line                           *
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
* insert initial line
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
* set cursor
  SET CURSOR LINE L_LINE.

  G_I = L_LINE.
  G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_DELETE_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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
    DATA : L_I LIKE SY-INDEX.
    L_I = 36.
    IF <MARK_FIELD> = 'X' AND <WA>+L_I(1) = ''.
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

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <LINES>      TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
* get looplines of TableControl
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.
***********************************************************************
  G_TC_LINES = <TC>-LINES.
***********************************************************************

* is no line filled?                                                   *
  IF <TC>-LINES = 0.
*   yes, ...                                                           *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        ENTRY_ACT      = <TC>-TOP_LINE
        ENTRY_FROM     = 1
        ENTRY_TO       = <TC>-LINES
        LAST_PAGE_FULL = 'X'
        LOOPS          = <LINES>
        OK_CODE        = P_OK
        OVERLAPPING    = 'X'
      IMPORTING
        ENTRY_NEW      = L_TC_NEW_TOP_LINE
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
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

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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

  IF ZIC_PREP_ROLEREQ-CCODE IS INITIAL.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-CCODE'.
    MESSAGE I082(ZHELP).
    LEAVE TO SCREEN 0.
  ENDIF.
  REFRESH : IT_COND.
  CONCATENATE 'FICTR'  'LIKE'  INTO G_LINE SEPARATED BY
  SPACE.
  CONCATENATE G_LINE+0(10) '''' ZIC_PREP_ROLEREQ-CCODE '%' ''''  INTO
              G_LINE.
  APPEND G_LINE TO IT_COND.
  IF HELP_LIST_FLAG <> 'X' .
    SELECT * FROM M_FISTB INTO CORRESPONDING FIELDS OF TABLE IT_M_FISTB
                  WHERE (IT_COND).

*Begin of <RD1K963151>.
    IT_M_FISTB1[] = IT_M_FISTB[].
    CLEAR IT_M_FISTB[].

    SELECT FIKRS HIVARNT FISTL HIROOT_ST PARENT_ST  NEXT_ST CHILD_ST HILEVEL FROM
           FMHISV INTO TABLE IT_FMHISV FOR ALL ENTRIES IN IT_M_FISTB1 WHERE
           FISTL = IT_M_FISTB1-FICTR.

    DELETE IT_FMHISV WHERE PARENT_ST = SPACE OR PARENT_ST = 'ONGC'
    OR  PARENT_ST = 'OVL' OR PARENT_ST = 'OBV'.

    LOOP AT IT_M_FISTB1 INTO WA_FISTB1.
      READ TABLE IT_FMHISV WITH KEY FISTL = WA_FISTB1-FICTR.
      IF SY-SUBRC = 0 .
        MOVE WA_FISTB1-FICTR TO WA_FISTB-FICTR.
        MOVE WA_FISTB1-BEZEICH TO WA_FISTB-BEZEICH.
        APPEND WA_FISTB TO IT_M_FISTB.
      ENDIF.
    ENDLOOP.
*End of <RD1K963151>.

    HELP_LIST_FLAG = 'X'.
    REFRESH IT_COND.
  ENDIF.
  LOOP AT IT_M_FISTB INTO WA_M_FISTB.
*
    IF WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC OR
       WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC2 OR
       WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC3 OR
       WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC4.
      WA_M_FISTB-G_MARK = 'X'.
    ENDIF.

    IF OLD_OK_CODE = 'DISPLAY' OR OLD_OK_CODE = 'APPROVE'.
      IF WA_M_FISTB-G_MARK = 'X'.
        WRITE: / WA_M_FISTB-FICTR, WA_M_FISTB-BEZEICH.
      ENDIF.
    ELSE.
      WRITE: / WA_M_FISTB-G_MARK AS CHECKBOX, WA_M_FISTB-FICTR,
            WA_M_FISTB-BEZEICH.
    ENDIF.

    HIDE : WA_M_FISTB-G_MARK, WA_M_FISTB-FICTR.
*    CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr.
  ENDLOOP.
  LINES = SY-LINNO .

ENDFORM.                    " HELP_LIST
*&---------------------------------------------------------------------*
*&      Form  tick_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TICK_ALL.

  SY-LSIND = 0.

  MOVE 'REQ1' TO WA_TAB.
  APPEND WA_TAB TO TAB.
  MOVE 'SELALL' TO WA_TAB.
  APPEND WA_TAB TO TAB.
  MOVE 'DESELALL' TO WA_TAB.
  APPEND WA_TAB TO TAB.

  SET PF-STATUS 'STATUS_120' EXCLUDING TAB.
  CLEAR : WA_TAB.
  REFRESH : TAB.
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
           COLOR COL_HEADING.
  ULINE.


  IF FLAG_S_FUNDC = 'X'.
*    refresh : s_fundc.
    LOOP AT IT_M_FISTB INTO WA_M_FISTB.
*
      WA_M_FISTB-G_MARK = 'X'.
      WRITE: / WA_M_FISTB-G_MARK AS CHECKBOX, WA_M_FISTB-FICTR,
               WA_M_FISTB-BEZEICH.
      MODIFY  IT_M_FISTB FROM WA_M_FISTB.
      HIDE : WA_M_FISTB-G_MARK, WA_M_FISTB-FICTR, WA_M_FISTB-BEZEICH.
      CLEAR : WA_M_FISTB-G_MARK, WA_M_FISTB-FICTR, WA_M_FISTB-BEZEICH.
    ENDLOOP.

    LINES = SY-LINNO .

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
FORM NOTICK_ALL.

  SY-LSIND = 0.

  MOVE 'REQ1' TO WA_TAB.
  APPEND WA_TAB TO TAB.
  MOVE 'SELALL' TO WA_TAB.
  APPEND WA_TAB TO TAB.
  MOVE 'DESELALL' TO WA_TAB.
  APPEND WA_TAB TO TAB.

  SET PF-STATUS 'STATUS_120' EXCLUDING TAB.
  CLEAR : WA_TAB.
  REFRESH : TAB.
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
         COLOR COL_HEADING.
  ULINE.


  IF FLAG_S_FUNDC = 'X'.
*    refresh : s_fundc.
    LOOP AT IT_M_FISTB INTO WA_M_FISTB.
*
      WA_M_FISTB-G_MARK = ''.
      WRITE: / WA_M_FISTB-G_MARK AS CHECKBOX, WA_M_FISTB-FICTR,
               WA_M_FISTB-BEZEICH.
      MODIFY  IT_M_FISTB FROM WA_M_FISTB.
      HIDE : WA_M_FISTB-G_MARK, WA_M_FISTB-FICTR, WA_M_FISTB-BEZEICH.
      CLEAR : WA_M_FISTB-G_MARK, WA_M_FISTB-FICTR, WA_M_FISTB-BEZEICH.
    ENDLOOP.

    LINES = SY-LINNO .

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
FORM PICK.

  SY-LSIND = 0.

  MOVE 'REQ1' TO WA_TAB.
  APPEND WA_TAB TO TAB.
  MOVE 'SELALL' TO WA_TAB.
  APPEND WA_TAB TO TAB.
  MOVE 'DESELALL' TO WA_TAB.
  APPEND WA_TAB TO TAB.

  DATA L_BLANK VALUE ''.

  SET PF-STATUS 'STATUS_120' EXCLUDING TAB.
  CLEAR : WA_TAB.
  REFRESH : TAB.
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
         COLOR COL_HEADING.
  ULINE.


  IF FLAG_S_FUNDC = 'X'.
*    refresh : s_fundc.
    LOOP AT IT_M_FISTB INTO WA_M_FISTB.

      LINES_INDEX = SY-TABIX + 4.

      READ LINE LINES_INDEX FIELD VALUE WA_M_FISTB-G_MARK.

      WRITE: / WA_M_FISTB-G_MARK AS CHECKBOX, WA_M_FISTB-FICTR,
               WA_M_FISTB-BEZEICH.

      IF WA_M_FISTB-G_MARK <> 'X'.

        IF WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC.
          ZIC_PREP_ROLEREQ-FUNDC = 'X'.
        ENDIF.

        IF WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC2.
          CLEAR ZIC_PREP_ROLEREQ-FUNDC2.
        ENDIF.

        IF WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC3.
          CLEAR ZIC_PREP_ROLEREQ-FUNDC3.
        ENDIF.

        IF WA_M_FISTB-FICTR = ZIC_PREP_ROLEREQ-FUNDC4.
          CLEAR ZIC_PREP_ROLEREQ-FUNDC4.
        ENDIF.

      ENDIF.

      MODIFY  IT_M_FISTB FROM WA_M_FISTB.
      HIDE : WA_M_FISTB-G_MARK, WA_M_FISTB-FICTR.
*      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    HELP_LIST_FLAG = 'X'.

    LINES = SY-LINNO .

    READ TABLE IT_M_FISTB INTO WA_M_FISTB WITH KEY G_MARK = 'X'.

    IF SY-SUBRC = 0.

      ZIC_PREP_ROLEREQ-FUNDC = WA_M_FISTB-FICTR.

    ELSE.

      CLEAR ZIC_PREP_ROLEREQ-FUNDC .

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
FORM CHECK_ITEMS.

  PERFORM VALIDATIONS1.

ENDFORM.                    " check_items
*&---------------------------------------------------------------------*
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_REQUEST.

  IF OLD_OK_CODE = 'CREATE' OR
     OLD_OK_CODE = 'CROSSCO' OR
     OLD_OK_CODE = 'CRCROLES'.

    PERFORM GEN_NO.

  ENDIF.

  IF OLD_OK_CODE = 'RELEASE' OR
     OLD_OK_CODE = 'APPROVE'.

    G_RELEASE = ZIC_PREP_ROLEREQ-REQ_CR_FL.
    G_APPROVE = ZIC_PREP_ROLEREQ-REQ_APP_FL.
    G_APPROVE0 = ZIC_PREP_ROLEREQ-REQ_APP0_FL.
    G_APPROVE1 = ZIC_PREP_ROLEREQ-REQ_APP1_FL.


    SELECT SINGLE * FROM ZIC_PREP_ROLEREQ
                    WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    IF ZIC_PREP_ROLEREQ-REQ_CR_FL IS INITIAL.
      ZIC_PREP_ROLEREQ-REQ_CR_FL = G_RELEASE.
    ENDIF.
    IF ZIC_PREP_ROLEREQ-REQ_APP_FL IS INITIAL.
      ZIC_PREP_ROLEREQ-REQ_APP_FL = G_APPROVE.
    ENDIF.
    IF ZIC_PREP_ROLEREQ-REQ_APP1_FL IS INITIAL.
      ZIC_PREP_ROLEREQ-REQ_APP1_FL = G_APPROVE1.
    ENDIF.

    IF ZIC_PREP_ROLEREQ-REQ_APP0_FL IS INITIAL.
      ZIC_PREP_ROLEREQ-REQ_APP0_FL = G_APPROVE0.
    ENDIF.


    CLEAR : G_RELEASE, G_APPROVE, G_APPROVE0, G_APPROVE1.

    IF G_RELEASE = 'X' AND ( G_APPROVE <> 'X' AND
                             G_APPROVE0 <> 'X' AND
                             G_APPROVE1 <> 'X' ).

      G_APP_REL = 'X'.

    ENDIF.

  ENDIF.

  IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
    MESSAGE I089(ZHELP).
  ELSE.
    PERFORM INSERT_HEADER.
  ENDIF.

ENDFORM.                    " Save_request
*&---------------------------------------------------------------------*
*&      Form  gen_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GEN_NO.

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
FORM INSERT_HEADER.

  ZIC_PREP_ROLEREQ-MANDT = SY-MANDT.
  IF OLD_OK_CODE = 'CREATE' OR
     OLD_OK_CODE = 'CROSSCO' OR
     OLD_OK_CODE = 'CRCROLES'.
    ZIC_PREP_ROLEREQ-DOCNO = ZDOCNUMB.
  ENDIF.

****************************************

**---------- Changes Start date 24.06.2016 11:43:05-------------------
**  SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
**      A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
**    D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
**    D~DISC_CD AS DISC_CD
**      INTO CORRESPONDING FIELDS OF TABLE IST_DATA
**       FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
**       ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
**          ON C~DESIGNO = D~DESIG_CODE AND
**              C~R_P_CD  = D~R_P_CD AND
**              C~VERSION = D~VERSION )
**           WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
**                 A~SPRPS = ' ' AND
**                 A~ENDDA = '99991231' AND
**                 C~SPRPS = ' ' AND
**                 C~ENDDA = '99991231' .


  SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
      A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
    D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
    D~DISC_CD AS DISC_CD
      INTO CORRESPONDING FIELDS OF TABLE IST_DATA
       FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
       ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
          ON C~DESIGNO = D~DESIG_CODE AND
              C~R_P_CD  = D~R_P_CD AND
              C~VERSION = D~VERSION )
           WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                 A~SPRPS = ' ' AND
                 A~ENDDA = '99991231' AND
                 C~SPRPS = ' ' AND
                 C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:43:05-----------------


  IF SY-SUBRC = 0.
    READ TABLE IST_DATA INDEX 1. "#EC CI_NOORDER

    ZIC_PREP_ROLEREQ-PERSA = IST_DATA-WERKS .

  ENDIF.
****************************************


  IF ZIC_PREP_ROLEREQ-USERIDCR IS INITIAL.

    ZIC_PREP_ROLEREQ-USERIDCR = SY-UNAME.
    ZIC_PREP_ROLEREQ-CR_DATE  = SY-DATUM.

    CLEAR ZUSRMST.

    SELECT SINGLE * FROM USR02 WHERE BNAME =
                               ZIC_PREP_ROLEREQ-USERIDCR.

    IF SY-SUBRC NE 0.

    ELSE.
*
      CLEAR IST_DATA.
      REFRESH IST_DATA.
**---------- Changes Start date 24.06.2016 11:44:38-------------------
**  SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
**           A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
**         D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
**           INTO CORRESPONDING FIELDS OF TABLE IST_DATA
**      FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
**            ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
**               ON C~DESIGNO = D~DESIG_CODE AND
**                   C~R_P_CD  = D~R_P_CD AND
**                   C~VERSION = D~VERSION )
**                WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDCR AND
**                      A~SPRPS = ' ' AND
**                      A~ENDDA = '99991231' AND
**                      C~SPRPS = ' ' AND
**                      C~ENDDA = '99991231' .


      SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
           A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
         D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
           INTO CORRESPONDING FIELDS OF TABLE IST_DATA
      FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
            ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
               ON C~DESIGNO = D~DESIG_CODE AND
                   C~R_P_CD  = D~R_P_CD AND
                   C~VERSION = D~VERSION )
                WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDCR AND
                      A~SPRPS = ' ' AND
                      A~ENDDA = '99991231' AND
                      C~SPRPS = ' ' AND
                      C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:44:38-----------------


      IF SY-SUBRC = 0.
        READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
        ZIC_PREP_ROLEREQ-NAMECR = IST_DATA-NAME.
        ZIC_PREP_ROLEREQ-DESIGCR = IST_DATA-DESIGNATION.
      ENDIF.

    ENDIF.

    CLEAR : IST_DATA.
    REFRESH : IST_DATA.

  ENDIF.


  IF ZIC_PREP_ROLEREQ-USERIDAP IS INITIAL.

    IF OLD_OK_CODE = 'APPROVE' AND
          ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
      ZIC_PREP_ROLEREQ-USERIDAP = SY-UNAME.
      ZIC_PREP_ROLEREQ-APP_DATE  = SY-DATUM.

      IF ZIC_PREP_ROLEREQ-STATUS = 'IC' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
        ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      ELSE.
        ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      ENDIF.

      CLEAR ZUSRMST.

      SELECT SINGLE * FROM USR02 WHERE BNAME =
                            ZIC_PREP_ROLEREQ-USERIDAP.

      IF SY-SUBRC NE 0.

      ELSE.

        CLEAR IST_DATA.
        REFRESH IST_DATA.

**---------- Changes Start date 24.06.2016 11:45:22-------------------
*        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
*                A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
*                C~VERSION D~SDESIG_TEXT AS DESIGNATION
*                 D~ADESIG_TEXT AS ADESIGNATION
*             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*             FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*       ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*       ON C~DESIGNO = D~DESIG_CODE AND
*           C~R_P_CD  = D~R_P_CD AND
*           C~VERSION = D~VERSION )
*        WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDAP AND
*              A~SPRPS = ' ' AND
*              A~ENDDA = '99991231' AND
*              C~SPRPS = ' ' AND
*              C~ENDDA = '99991231' .
*--------Commented & Added by Manisha Dt:09.02.2018-------------------*

*        SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs
*                a~werks a~persk a~sbmod  c~designo c~r_p_cd
*                c~version d~sdesig_text AS designation
*                 d~adesig_text AS adesignation
*             INTO CORRESPONDING FIELDS OF TABLE ist_data
*             FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
*       ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
*       ON c~designo = d~desig_code AND
*           c~r_p_cd  = d~r_p_cd AND
*           c~version = d~version )
*        WHERE a~pernr = zic_prep_rolereq-useridap AND
*              a~sprps = ' ' AND
*              a~endda = '99991231' AND
*              c~sprps = ' ' AND
*              c~endda = '99991231' .
        SELECT * FROM ZMM_VMS_CR_NEW INTO WA_ZMM_VMS_CR_NEW UP TO 1 ROWS WHERE CORE_USER_ID = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF SY-SUBRC = 0.
          SELECT SINGLE * FROM ZPA0001 INTO WA_PA0001 WHERE PERNR =  WA_ZMM_VMS_CR_NEW-CPF_NO AND
                                                           SPRPS  = ' '                       AND
                                                           ENDDA  >= '99991231' AND          "L_DATE
                                                           BEGDA <= SY-DATUM.


**---------- Changee  Ending Date 24.06.2016 11:45:22-----------------


*
          IF SY-SUBRC = 0.
*-------- Commented by Manisha bh.Dt:09.02.2018 ------------*
*            READ TABLE IST_DATA INDEX 1.
*            ZIC_PREP_ROLEREQ-NAMEAPP = IST_DATA-NAME.
*            ZIC_PREP_ROLEREQ-DESIGAP = IST_DATA-DESIGNATION.
*            IF ZIC_PREP_ROLEREQ-PERSA <> IST_DATA-WERKS AND
*                   NOT ZIC_PREP_ROLEREQ-PERSA IS INITIAL.
*              SELECT SINGLE * FROM T500P
*              WHERE PERSA = IST_DATA-WERKS.
*              IF ZIC_PREP_ROLEREQ-CCODE = T500P-BUKRS.
*              ELSE.
*                SELECT SINGLE * FROM ZMM_PREP_EX_APP
*                  WHERE USERID = ZIC_PREP_ROLEREQ-USERIDAP.
*                IF SY-SUBRC = 0.
*                ELSE.
*                  IF G_CCODE_CROSSCO = T500P-BUKRS.
*                  ELSE.
*                    MESSAGE E112(ZHELP).
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*-------------------------------------------------------------*
          ELSE.
            MESSAGE E110(ZHELP).
          ENDIF.
        ENDIF.
      ENDIF.
*    endif.

    ELSEIF OLD_OK_CODE = 'APPROVE' AND
            ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
*                and
*                      ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZIC_PREP_ROLEREQ-USERIDAP = SY-UNAME.
      ZIC_PREP_ROLEREQ-APP_DATE = SY-DATUM.

      IF ZIC_PREP_ROLEREQ-STATUS = 'IC' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
        ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      ELSE.
        ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      ENDIF.


      SELECT SINGLE * FROM USR02 WHERE BNAME =
                              ZIC_PREP_ROLEREQ-USERIDAP.
      IF SY-SUBRC NE 0.
*              message e043(zhelp).
      ELSE.

        CLEAR IST_DATA.
        REFRESH IST_DATA.

**---------- Changes Start date 24.06.2016 11:45:58-------------------
*        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
*                A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
*                C~VERSION D~SDESIG_TEXT AS DESIGNATION
*                 D~ADESIG_TEXT AS ADESIGNATION
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*                 FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*           ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*           ON C~DESIGNO = D~DESIG_CODE AND
*               C~R_P_CD  = D~R_P_CD AND
*               C~VERSION = D~VERSION )
*            WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDAP AND
*                  A~SPRPS = ' ' AND
*                  A~ENDDA = '99991231' AND
*                  C~SPRPS = ' ' AND
*                  C~ENDDA = '99991231' .

*--------Commented & Added by Manisha Dt:09.02.2018-------------------*
*        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
*      A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
*      C~VERSION D~SDESIG_TEXT AS DESIGNATION
*       D~ADESIG_TEXT AS ADESIGNATION
*       INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*       FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
* ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
* ON C~DESIGNO = D~DESIG_CODE AND
*     C~R_P_CD  = D~R_P_CD AND
*     C~VERSION = D~VERSION )
*  WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDAP AND
*        A~SPRPS = ' ' AND
*        A~ENDDA = '99991231' AND
*        C~SPRPS = ' ' AND
*        C~ENDDA = '99991231' .
        SELECT * FROM ZMM_VMS_CR_NEW INTO WA_ZMM_VMS_CR_NEW UP TO 1 ROWS WHERE CORE_USER_ID = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF SY-SUBRC = 0.
          SELECT SINGLE * FROM ZPA0001 INTO WA_PA0001 WHERE PERNR =  WA_ZMM_VMS_CR_NEW-CPF_NO AND
                                                           SPRPS  = ' '                       AND
                                                           ENDDA  >= '99991231' AND          "L_DATE
                                                           BEGDA <= SY-DATUM.

**---------- Changee  Ending Date 24.06.2016 11:45:58-----------------

          IF SY-SUBRC = 0.
*-------- Commented by Manisha bh.Dt:09.02.2018 ------------*
*          READ TABLE IST_DATA INDEX 1.
*          ZIC_PREP_ROLEREQ-NAMEAPP = IST_DATA-NAME.
*          ZIC_PREP_ROLEREQ-DESIGAP = IST_DATA-DESIGNATION.
*          IF ZIC_PREP_ROLEREQ-PERSA <> IST_DATA-WERKS AND
*             NOT ZIC_PREP_ROLEREQ-PERSA IS INITIAL.
*            SELECT SINGLE * FROM T500P
*                WHERE PERSA = IST_DATA-WERKS.
*            IF ZIC_PREP_ROLEREQ-CCODE = T500P-BUKRS.
*            ELSE.
*              SELECT SINGLE * FROM ZMM_PREP_EX_APP
*                   WHERE USERID = ZIC_PREP_ROLEREQ-USERIDAP.
*              IF SY-SUBRC = 0.
*              ELSE.
*
***code added by CAB_AMITMOZA  <RD1K983325>   CR: 30007580  dt: 09.04.2013.
*                IF ( ZIC_PREP_ROLEREQ-CCODE = 'SBW' AND T500P-BUKRS = 'SBS') OR
*                  ( ZIC_PREP_ROLEREQ-CCODE = 'BDW' AND T500P-BUKRS = 'BDA').
*                ELSE.
***code end by CAB_AMITMOZA  <RD1K983325>
*                  MESSAGE E112(ZHELP).
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*-------------------------------------------------------------*
          ELSE.
            MESSAGE E110(ZHELP).
          ENDIF.
        ENDIF.
      ENDIF.
**13.02.06

    ELSEIF OLD_OK_CODE = 'APPROVE' AND
*
                   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZIC_PREP_ROLEREQ-USERIDAP = SY-UNAME.
      ZIC_PREP_ROLEREQ-APP_DATE = SY-DATUM.

      IF ZIC_PREP_ROLEREQ-STATUS = 'IC' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
        ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      ELSE.
        ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      ENDIF.


      SELECT SINGLE * FROM USR02 WHERE BNAME =
                              ZIC_PREP_ROLEREQ-USERIDAP.
      IF SY-SUBRC NE 0.
*              message e043(zhelp).
      ELSE.

        CLEAR IST_DATA.
        REFRESH IST_DATA.
**---------- Changes Start date 24.06.2016 11:47:43-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
*                A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
*                C~VERSION D~SDESIG_TEXT AS DESIGNATION
*                 D~ADESIG_TEXT AS ADESIGNATION
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*                 FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*           ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*           ON C~DESIGNO = D~DESIG_CODE AND
*               C~R_P_CD  = D~R_P_CD AND
*               C~VERSION = D~VERSION )
*            WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDAP AND
*                  A~SPRPS = ' ' AND
*                  A~ENDDA = '99991231' AND
*                  C~SPRPS = ' ' AND
*                  C~ENDDA = '99991231' .
*--------Commented & Added by Manisha Dt:09.02.2018-------------------*
*        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
*                   A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
*                   C~VERSION D~SDESIG_TEXT AS DESIGNATION
*                    D~ADESIG_TEXT AS ADESIGNATION
*                    INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*                    FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
*              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*              ON C~DESIGNO = D~DESIG_CODE AND
*                  C~R_P_CD  = D~R_P_CD AND
*                  C~VERSION = D~VERSION )
*               WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERIDAP AND
*                     A~SPRPS = ' ' AND
*                     A~ENDDA = '99991231' AND
*                     C~SPRPS = ' ' AND
*                     C~ENDDA = '99991231' .
        SELECT * FROM ZMM_VMS_CR_NEW INTO WA_ZMM_VMS_CR_NEW UP TO 1 ROWS WHERE CORE_USER_ID = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF SY-SUBRC = 0.
          SELECT SINGLE * FROM ZPA0001 INTO WA_PA0001 WHERE PERNR =  WA_ZMM_VMS_CR_NEW-CPF_NO AND
                                                           SPRPS  = ' '                       AND
                                                           ENDDA  >= '99991231' AND          "L_DATE
                                                           BEGDA <= SY-DATUM.

**---------- Changee  Ending Date 24.06.2016 11:47:43-----------------


*
          IF SY-SUBRC = 0.
*-------- Commented by Manisha bh.Dt:09.02.2018 ------------*
*          READ TABLE IST_DATA INDEX 1.
*          ZIC_PREP_ROLEREQ-NAMEAPP = IST_DATA-NAME.
*          ZIC_PREP_ROLEREQ-DESIGAP = IST_DATA-DESIGNATION.
*          IF ZIC_PREP_ROLEREQ-PERSA <> IST_DATA-WERKS AND
*             NOT ZIC_PREP_ROLEREQ-PERSA IS INITIAL.
*            SELECT SINGLE * FROM T500P
*                WHERE PERSA = IST_DATA-WERKS.
*            IF ZIC_PREP_ROLEREQ-CCODE = T500P-BUKRS.
*            ELSE.
*              SELECT SINGLE * FROM ZMM_PREP_EX_APP
*                   WHERE USERID = ZIC_PREP_ROLEREQ-USERIDAP.
*              IF SY-SUBRC = 0.
*              ELSE.
** Check for L1 inserted  05/03/2007
*                IF G_USER = 'L1'.
*                ELSE.
*                  MESSAGE E112(ZHELP).
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*-------------------------------------------------------------*
          ELSE.
            MESSAGE E110(ZHELP).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
**13.02.06
  ENDIF.
*endif.
**12.06.06 vivek begin

  IF NOT ZIC_PREP_ROLEREQ-USERIDAP IS INITIAL AND
       OLD_OK_CODE = 'APPROVE' AND
                ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' OR
                     ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' OR
                     ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X' ).

**
**---------- Changes Start date 24.06.2016 11:48:11-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
*              A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
*              C~VERSION D~SDESIG_TEXT AS DESIGNATION
*               D~ADESIG_TEXT AS ADESIGNATION
*           INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*           FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*     ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*     ON C~DESIGNO = D~DESIG_CODE AND
*         C~R_P_CD  = D~R_P_CD AND
*         C~VERSION = D~VERSION )
*      WHERE A~PERNR = SY-UNAME AND
*            A~SPRPS = ' ' AND
*            A~ENDDA = '99991231' AND
*            C~SPRPS = ' ' AND
*            C~ENDDA = '99991231' .

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS
              A~WERKS A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD
              C~VERSION D~SDESIG_TEXT AS DESIGNATION
               D~ADESIG_TEXT AS ADESIGNATION
           INTO CORRESPONDING FIELDS OF TABLE IST_DATA
           FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
     ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
     ON C~DESIGNO = D~DESIG_CODE AND
         C~R_P_CD  = D~R_P_CD AND
         C~VERSION = D~VERSION )
      WHERE A~PERNR = SY-UNAME AND
            A~SPRPS = ' ' AND
            A~ENDDA = '99991231' AND
            C~SPRPS = ' ' AND
            C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:48:11-----------------


*
    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
      ZIC_PREP_ROLEREQ-NAMEAPP = IST_DATA-NAME.
      ZIC_PREP_ROLEREQ-USERIDAP = SY-UNAME.
    ENDIF.

**

    IF ZIC_PREP_ROLEREQ-STATUS = 'IC' OR
        ZIC_PREP_ROLEREQ-STATUS = 'IR'.
      ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
    ELSE.
      ZIC_PREP_ROLEREQ-STATUS   = 'N'.
    ENDIF.
**12.06.06 vivek end
  ENDIF.
*****************************
  DATA L_FUNDC_NO LIKE SY-INDEX.
  CLEAR L_FUNDC_NO.
  LOOP AT IT_M_FISTB INTO WA_M_FISTB.
    IF WA_M_FISTB-G_MARK = 'X'.
      L_FUNDC_NO = L_FUNDC_NO + 1.
      CASE L_FUNDC_NO.
*Begin of <RD1K963151>.
        WHEN 2.
          ZIC_PREP_ROLEREQ-FUNDC2 = WA_M_FISTB-FICTR.
        WHEN 3.
          ZIC_PREP_ROLEREQ-FUNDC3 = WA_M_FISTB-FICTR.
        WHEN 4.
          ZIC_PREP_ROLEREQ-FUNDC4 = WA_M_FISTB-FICTR.
*        when 2.
*          ZIC_PREP_ROLEREQ-fundc2 = wa_m_fistb-fistl.
*        when 3.
*          ZIC_PREP_ROLEREQ-fundc3 = wa_m_fistb-fistl.
*        when 4.
*          ZIC_PREP_ROLEREQ-fundc4 = wa_m_fistb-fistl.
*End of <RD1K963151>.
        WHEN 5.
          MESSAGE I078(ZHELP).
          OKCODE_100 = 'MULTI'.
          G_FUNDC_ERR_FLAG = 'X'.
      ENDCASE.
    ENDIF.
  ENDLOOP.
*****************************

*****
  IF G_FUNDC_ERR_FLAG <> 'X'.

    IF OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-COMM_FL = 'X'.
      G_COMM_FL = 'X'.
      IF G_LINES_2 <> 0.
        CLEAR ZIC_PREP_ROLEREQ-COMM_FL.
        CLEAR G_LINES_2.
** Status New changed to IF
        ZIC_PREP_ROLEREQ-STATUS = 'IF'.
      ENDIF.
    ENDIF.

    IF OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREQ-COMM_FL = 'X'.
** Status New changed to IR
      ZIC_PREP_ROLEREQ-STATUS = 'IR'.
      CLEAR ZIC_PREP_ROLEREQ-COMM_FL.
    ENDIF.

    IF OLD_OK_CODE = 'CROSSCO'.
      ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    ENDIF.

    IF OLD_OK_CODE = 'CRCROLES'.
      ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    ENDIF.

    IF ZIC_PREP_ROLEREQ-CCODE IS INITIAL.
      MESSAGE E142(ZHELP).
    ENDIF.

    IF G_MULT_MODULE_FL = 'X' AND OLD_OK_CODE = 'CHANGE'.
      ZIC_PREP_ROLEREQ-MULTIMODULE_FL = 'X'.
    ENDIF.

    MODIFY ZIC_PREP_ROLEREQ FROM ZIC_PREP_ROLEREQ.

    IF SY-SUBRC = 0.

      IF G_APP_REL = 'X'.

        CLEAR G_APP_REL.

      ELSEIF
      ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-COMM_FL = 'X' )
      OR ( OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREQ-COMM_FL = 'X' ).

      ELSE.

        G_APPROVER_LEVEL = 'L3'.

** Module wise check & insertion

        IF G_RESET_FL <> 'X'.

          CASE MODULEID.

            WHEN 'MM'.

              PERFORM INSERT_ITEMS.

            WHEN 'PM'.

              PERFORM INSERT_ITEMS_PM.

            WHEN 'PS'.

              PERFORM INSERT_ITEMS_PS.

            WHEN 'PP'.

              PERFORM INSERT_ITEMS_PP.

            WHEN 'SD'.

              PERFORM INSERT_ITEMS_SD.

            WHEN 'QM'.

              PERFORM INSERT_ITEMS_QM.

            WHEN 'HSE'.

              PERFORM INSERT_ITEMS_HS.

            WHEN 'OLM'.

              PERFORM INSERT_ITEMS_OLM.

              """"""""""""""""""""""""""""""""""""""
              "added by lipsy for srm module introduction ON 3.3.2015 RD1K996555
            WHEN 'SRM'.
              PERFORM INSERT_ITEMS_SRM.
              "end of addition by lipsy  for srm module introduction ON 3.3.2015 RD1K996555
              """""""""""""""""""""""""""""""""""""""""""

          ENDCASE.

        ENDIF.

      ENDIF.

      IF G_RESET_FL <> 'X'.
        PERFORM ITEMS_APPROVAL_CHECK.
      ENDIF.

****Saving the long text.                              *****


      """""""""""""""""""""
      """"addition  by lipsy on 24.02.2015 for leaving program after release RD1K996042

      CLEAR:V_RELEASE.

      IF OLD_OK_CODE = 'RELEASE'.

        V_RELEASE = 'X'.

      ENDIF.

      "end of addition  by lipsy on 24.02.2015 for leaving program after release  RD1K996042
      """""""""""""""""""""""


      IF ( OLD_OK_CODE = 'CREATE' ) OR
      ( OLD_OK_CODE = 'CROSSCO' ) OR ( OLD_OK_CODE = 'CHANGE' )
          OR ( OLD_OK_CODE = 'CRCROLES' )
          OR ( OLD_OK_CODE = 'RELEASE' )
          OR ( OLD_OK_CODE = 'APPROVE' ).

        PERFORM SAVE_CORS_TEXT.
      ELSEIF G_COMM_FL = 'X'.
        PERFORM SAVE_CORS_TEXT.
        CLEAR G_COMM_FL.
      ENDIF.

**** Check if moduleid has changed
**13/04/07
      IF MODULE_CHANGED_FLAG = 'X' AND ( OLD_OK_CODE = 'CHANGE' OR
         OLD_OK_CODE = 'APPROVE' ).
        MODULEID = NEW_MODULEID.
        CLEAR NEW_MODULEID.
        CLEAR MODULE_CHANGED_FLAG.
        IF OLD_OK_CODE <> 'APPROVE'.
          OLD_OK_CODE = 'CHANGE'.
        ENDIF.
        PERFORM CLEAR_FOR_NEWMODULE.
      ELSE.
        PERFORM CLEAR.
      ENDIF.
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
      PERFORM UNLOCK_RECORD.
      IF G_RESET_FL = 'X'.
        CLEAR G_RESET_FL.
        CLEAR SET_DISC_MM_FLAG.
        CLEAR SET_DISC_FI_FLAG.
        CLEAR G_HD_COPIED.
**13/04/07
        IF OLD_OK_CODE = 'APPROVE'.
        ELSE.
          OLD_OK_CODE = 'CHANGE'.
        ENDIF.
        ZIC_PREP_ROLEREQ-DOCNO = G_DOCNO.
      ENDIF.

*      ZIC_PREP_ROLEREQ-crc_fl = g_crc_fl.
*      clear g_crc_fl.
      """"""""""""""""""""""""""""""
      """""addition  by lipsy on 24.02.2015 for leaving program after release RD1K996042
      IF  V_RELEASE = 'X'.
        LEAVE PROGRAM.
      ELSE.
        ""end of addition  by lipsy on 24.02.2015 for leaving program after release  RD1K996042
        """""""""""""""""""""""""""""""""""
        CALL SCREEN 100.
        """"""""""""""""""""""""""""""""""""
        """""addition  by lipsy on 24.02.2015 for leaving program after release RD1K996042
      ENDIF.
      ""end of addition  by lipsy on 24.02.2015 for leaving program after release  RD1K996042
      """"""""""""""""""""""""""""""""""""""

    ENDIF.

*****
  ELSE.

    CLEAR G_FUNDC_ERR_FLAG.
    CALL SCREEN 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    CLEAR OKCODE_100.

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
FORM INSERT_ITEMS.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  SORT G_TABLCTRL110_ITAB
  BY ROLE_NAME PLANT GRP  SLOC RECEIPT_LOC APPROVER.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL110_ITAB
    COMPARING ROLE_NAME PLANT GRP  SLOC RECEIPT_LOC APPROVER REJ_FL
    ROLE_TYPE_EX CRC_POS.

  LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.

    MOVE-CORRESPONDING G_TABLCTRL110_WA TO WA_ITEMTAB.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_ITEMS_SAVE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

***added g_reset_fl to check resetting & no rollback
  IF G_LINES_RL = 0 .
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                  moduleid = moduleid.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID..
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM EXIT_CONFIRM.

  DATA L_CHOICE1.
  CLEAR L_CHOICE1.

  IF OLD_OK_CODE = 'CREATE' OR
     OLD_OK_CODE = 'CROSSCO' OR
     OLD_OK_CODE = 'CHANGE' OR
     OLD_OK_CODE = 'DELETE' OR
     OLD_OK_CODE = 'RELEASE' OR
     OLD_OK_CODE = 'APPROVE'.

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

    DATA : L_GET2(1) TYPE C.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'EXIT '
        TEXT_QUESTION         = 'Data will be lost, Want to quit? '
        DEFAULT_BUTTON        = '2'
        DISPLAY_CANCEL_BUTTON = ' '
        START_COLUMN          = 25
        START_ROW             = 6
      IMPORTING
        ANSWER                = L_GET2
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1
        OTHERS                = 2.
    IF SY-SUBRC = 0.
      CASE L_GET2.
        WHEN '1'.
          MOVE 'J' TO L_CHOICE1.
        WHEN '2'.
          MOVE 'N' TO L_CHOICE1.
      ENDCASE.
    ENDIF.
    " End of <RD1K960036>.

    IF L_CHOICE1 = 'J'.
      CLEAR L_CHOICE1.
      PERFORM CLEAR.
      PERFORM UNLOCK_RECORD.
      CALL SCREEN 100.
    ELSE.
    ENDIF.

  ELSE.

    PERFORM CLEAR.
    PERFORM UNLOCK_RECORD.
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
FORM CLEAR_VAR.

  PERFORM CLEAR.

ENDFORM.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  unlock_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNLOCK_REQ.



ENDFORM.                    " unlock_req
*&---------------------------------------------------------------------*
*&      Form  unlock_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNLOCK_RECORD.

  CALL FUNCTION 'DEQUEUE_EZ_IC_PREPHDR'
    EXPORTING
      MODE_ZIC_PREP_ROLEREQ = 'E'
      MANDT                 = SY-MANDT
      DOCNO                 = ZIC_PREP_ROLEREQ-DOCNO.

  CLEAR G_LOCK.

ENDFORM.                    " unlock_record
*&---------------------------------------------------------------------*
*&      Form  clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR.

  PERFORM DESTROY_CTRL.

  OKCODE_100_P = OKCODE_100. " + BY BIPIN TO VALIDATE POP UP MESSAGE

  CLEAR   : OLD_OK_CODE, OKCODE_100, ERR_FLG.
  REFRESH : G_TABLCTRL110_ITAB[].
  CLEAR   : G_TABLCTRL110_ITAB.
  REFRESH : G_TABLCTRL111_ITAB[].
  CLEAR   : G_TABLCTRL111_ITAB.
  REFRESH : G_TABLCTRL112_ITAB[].
  CLEAR   : G_TABLCTRL112_ITAB.
  REFRESH : G_TABLCTRL113_ITAB[].
  CLEAR   : G_TABLCTRL113_ITAB.
  REFRESH : G_TABLCTRL114_ITAB[].
  CLEAR   : G_TABLCTRL114_ITAB.
  REFRESH : G_TABLCTRL115_ITAB[].
  CLEAR   : G_TABLCTRL115_ITAB.
  CLEAR   : SY-UCOMM.
  CLEAR   : G_CURR_LINE.
  CLEAR SET_DISC_MM_FLAG.
  CLEAR SET_DISC_FI_FLAG.
  CLEAR   : ZIC_PREP_ROLEREI, ZIC_PREP_ROLEREQ.
  CLEAR   : IT_TAB.
  REFRESH : TLINETAB1[],TLINETAB2[].
  CLEAR   : T500P-NAME1.
  CLEAR   : CRC_CHECK_FL.
  CLEAR   : HELP_LIST_FLAG.
  REFRESH : IT_M_FISTB.
  CLEAR   : MODULEID.

  """""""""""""""""""""""""
  "added by lipsy for clear on 20.03.2015 RD1K996555
  REFRESH : G_TABLCTRL118_ITAB[].
  CLEAR   : G_TABLCTRL118_ITAB.

  "end of addition by lipsy  for clear on 20.03.2015 RD1K996555
  """""""""""""""""


ENDFORM.                    " clear
*&---------------------------------------------------------------------*
*&      Form  text_control_eingabebereit1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_EINGABEBEREIT1.

  CALL METHOD GV_TEXT_EDITOR1->SET_READONLY_MODE
    EXPORTING
      READONLY_MODE          = GV_TEXT_EDITOR1->TRUE
    EXCEPTIONS
      ERROR_CNTL_CALL_METHOD = 1
      INVALID_PARAMETER      = 2
      OTHERS                 = 3.

  IF ( OLD_OK_CODE = 'CREATE' )
   OR ( OLD_OK_CODE = 'CROSSCO' )
   OR ( OLD_OK_CODE = 'CRCROLES' )
   OR ( OLD_OK_CODE = 'CHANGE' )
   OR ( OLD_OK_CODE = 'RELEASE' )
   OR ( OLD_OK_CODE = 'APPROVE' )
  OR ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-COMM_FL = 'X'
       AND  ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

    CALL METHOD GV_TEXT_EDITOR2->SET_READONLY_MODE
      EXPORTING
        READONLY_MODE          = GV_TEXT_EDITOR2->FALSE
      EXCEPTIONS
        ERROR_CNTL_CALL_METHOD = 1
        INVALID_PARAMETER      = 2
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
FORM TEXT_CONTROL_SET_TEXT_TABLE1.

  REFRESH: TLINETAB1, G_LINEFRTO_ITAB.
  IF OLD_OK_CODE <> 'CREATE' OR
     OLD_OK_CODE = 'CROSSCO' .
    APPEND LINES OF LINES_CORS TO TLINETAB1[].
  ENDIF.
*
  LOOP AT TLINETAB1[] INTO G_LINE132.
    IF ( G_LINE132+0(7) = '* Reply' ) OR
       ( G_LINE132+0(7) = '**Reply' ).
      G_LINEFRTO-LINE_FR = SY-TABIX.
      G_LINEFRTO-LINE_TO = SY-TABIX.
      APPEND G_LINEFRTO TO G_LINEFRTO_ITAB.
      CLEAR: G_LINEFRTO.
    ENDIF.
  ENDLOOP.
*
  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    TABLES
      ITF_TEXT    = TLINETAB1[]
      TEXT_STREAM = LT_TEXT_TABLE1.

  CALL METHOD GV_TEXT_EDITOR1->SET_TEXT_AS_STREAM
    EXPORTING
      TEXT            = LT_TEXT_TABLE1
    EXCEPTIONS
      ERROR_DP        = 1
      ERROR_DP_CREATE = 2
      OTHERS          = 3.
********************highlight**************************************
  CLEAR G_LINEFRTO.
  LOOP AT G_LINEFRTO_ITAB INTO G_LINEFRTO.
    CALL METHOD GV_TEXT_EDITOR1->HIGHLIGHT_LINES
      EXPORTING
        FROM_LINE      = G_LINEFRTO-LINE_FR
        TO_LINE        = G_LINEFRTO-LINE_TO
        HIGHLIGHT_MODE = 1.
  ENDLOOP.
********************************************************************

  IF ( OLD_OK_CODE = 'CREATE' )
   OR ( OLD_OK_CODE = 'CROSSCO' )
   OR ( OLD_OK_CODE = 'CRCROLES' )
   OR ( OLD_OK_CODE = 'CHANGE' )
   OR ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-COMM_FL = 'X'
       AND  ZIC_PREP_ROLEREQ-STATUS <> 'C').
    CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
      TABLES
        ITF_TEXT    = TLINETAB2
        TEXT_STREAM = LT_TEXT_TABLE2.

    CALL METHOD GV_TEXT_EDITOR2->SET_TEXT_AS_STREAM
      EXPORTING
        TEXT            = LT_TEXT_TABLE2
      EXCEPTIONS
        ERROR_DP        = 1
        ERROR_DP_CREATE = 2
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
FORM SAVE_CORS_TEXT.

  DATA: L_THEADER LIKE THEAD.
  DATA: L_DATECH(10) TYPE C.
***********Assignments***********************
  CLEAR L_THEADER.
  L_THEADER-TDOBJECT   = 'ZHELP'.
  L_THEADER-TDID       = '0001'.
  L_THEADER-TDSPRAS    =  SY-LANGU.
  L_THEADER-TDLINESIZE =  72.
  MOVE ZIC_PREP_ROLEREQ-DOCNO TO L_THEADER-TDNAME.
  APPEND LINES OF TLINETAB2 TO TLINETAB1.
*********************************************
  IF NOT TLINETAB1[] IS INITIAL.
    CLEAR G_CORES_SENDER.
    CONCATENATE SY-DATUM+6(2) '/'
                SY-DATUM+4(2) '/'
                SY-DATUM+0(4) INTO L_DATECH.
    CONCATENATE '**Reply' L_DATECH SY-UNAME INTO G_CORES_SENDER
     SEPARATED BY '          '.
    IF NOT TLINETAB2[] IS INITIAL.
      APPEND G_CORES_SENDER TO TLINETAB1.
    ENDIF.
    CLEAR G_CORES_SENDER.
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        CLIENT          = SY-MANDT
        HEADER          = L_THEADER
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
FORM GET_USER.

  CLEAR G_USER.

  """""""""""""""
  ""added by lipsy for l2 approver on 20.03.2015 RD1K996555
  CLEAR: G_USER_L2 .
  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
  """"""""

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'L1'.

  IF SY-SUBRC = 0.
    G_USER = 'L1'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'DI'.

  IF SY-SUBRC = 0.
    G_USER = 'L1'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'CS'.

  IF SY-SUBRC = 0.
    G_USER = 'L1'.
    CHECK 1 = 2.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'MD'.

  IF SY-SUBRC = 0.
    G_USER = 'L1'.
    CHECK 1 = 2.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'IM'.              "#EC *

  IF SY-SUBRC = 0.
    G_USER = 'IM'.
    CHECK 1 = 2.
  ENDIF.

  """"""""

  """""""""

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'FRGCO' FIELD : 'L2'.
  IF SY-SUBRC = 0.
    G_USER = 'L3'.
    """"""""""""
    ""added by lipsy for l2 approver on 20.03.2015 RD1K996555
    G_USER_L2 = 'L2'.
    "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
    """"""""""

    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L3'.
  IF SY-SUBRC = 0.
    G_USER = 'L3'.

    """""""""""
    "add by lipsy on 7.12.2015
    G_USER_L2 = 'L3'.
    "eadd by lipsy on 7.12.2015
    """"""""""""
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L4'.

  IF SY-SUBRC = 0.
    G_USER = 'L3'.
    ZIC_PREP_ROLEREQ-RADIO_FL = 'X'.
    G_L4 = 'X'.
    CHECK 1 = 2.
  ENDIF.

ENDFORM.                    " find_user
*&---------------------------------------------------------------------*
*&      Form  validations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATIONS.

  IF OLD_OK_CODE = 'APPROVE' AND MODULEID <> 'FI'.

    SELECT * FROM ZIC_PREP_ROLEREI UP TO 1 ROWS
 WHERE MODULEID = 'MM'
 AND DOCNO = ZIC_PREP_ROLEREQ-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF SY-SUBRC = 0.
      MODULEMM_FL = 'X'.
    ENDIF.

    IF G_USER = 'L1' OR
       G_USER = 'IM' OR
       ( G_USER = 'L3' AND G_L4 <> 'X' ).
    ELSEIF MODULEMM_FL <> 'X' AND G_L4 = 'X'.
    ELSE.
      MESSAGE I131(ZHELP).
      CLEAR OLD_OK_CODE.
      CALL SCREEN 100.
    ENDIF.

    IF G_USER = 'L1' AND
       ( ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X' OR
         ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
      MESSAGE I132(ZHELP).
      CLEAR OLD_OK_CODE.
      CALL SCREEN 100.
    ENDIF.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' AND OLD_OK_CODE <> 'APPROVE'.

    IF  ZIC_PREP_ROLEREQ-USERIDCR = SY-UNAME.
    ELSE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = 'Not authorised to use this document- not yours '.
*                     message i046(zhelp).
      PERFORM CLEAR.
      CALL SCREEN 100.
    ENDIF.

  ENDIF.

  IF OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREQ-REQ_CR_FL = 'X'.

    IF ZIC_PREP_ROLEREQ-STATUS = 'IF' OR
          ZIC_PREP_ROLEREQ-STATUS = 'PC' OR
          ZIC_PREP_ROLEREQ-STATUS = 'C'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = 'Request under process / completed can''t change/reset'.

*                message e065(zhelp).
      PERFORM CLEAR.
      CALL SCREEN 100.

    ELSE.
      G_RESET_FL = ZIC_PREP_ROLEREQ-REQ_CR_FL.
      G_DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      PERFORM VERIFY.
    ENDIF.
  ENDIF.

  IF OLD_OK_CODE = 'APPROVE' AND
                    ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

    """"""""""""""""""""""""""""""""""

    "comment by lipsy on 24.03.2015 RD1K996555
*    IF G_USER = 'IM' OR G_USER = 'L1'.
    "end of comment by lipsy on 24.03.2015 RD1K996555
    """"""""""""""""""""""""""""""""""

    """""""""""
    "added by lipsy  for approver on  24.03.2015 RD1K996555
    IF G_USER = 'IM' OR G_USER = 'L1' OR ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
      "end of addition by lipsy  for approver on  24.03.2015 RD1K996555
      """""""""""""""

    ELSE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = 'This requires approval of I/C MM'.

*               message e048(zhelp).
      PERFORM CLEAR.
      CALL SCREEN 100.
    ENDIF.
  ENDIF.

  """""""""""""""""""""""""""
  "added by lipsy  for approver on  20.03.2015 RD1K996555
  IF MODULEID = 'SRM'.
    IF OLD_OK_CODE = 'APPROVE' AND
                      ZIC_PREP_ROLEREQ-DISC_MM_FLAG NE 'X'.
      IF G_USER = 'L2' OR G_USER = 'L1' OR G_USER_L2 = 'L2'

        """""""""""""""""""""""""""""""""""
        "ADDED BY LIPSY ON 7.12.2015 RD1K999362
        OR  G_USER_L2 = 'L3'
        "END OF ADDITION  BY LIPSY ON 7.12.2015 RD1K999362
        """"""""""""""""""""""""""""""""""""""""
        .
      ELSE.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            """""""""""""""""""""""""""""""""""
            "COMMENT BY LIPSY ON 7.12.2015 RD1K999362
*           TEXTLINE1 = 'This requires approval of at least L2'.
            "END OF COMMENT BY LIPSY 7.12.2015 RD1K999362
            """""""""""""""""""""""""""""""""""""""
            """""""""""""""""""""""""""""""""""
            "ADDED BY LIPSY 7.12.2015 RD1K999362
            TEXTLINE1 = 'This requires approval of at least L3'.
        "END OF ADDITION  BY LIPSY 7.12.2015 RD1K999362
        """""""""""""""""""""""""""""""""""""""

*               message e048(zhelp).
        PERFORM CLEAR.
        CALL SCREEN 100.
      ENDIF.
    ENDIF.
  ENDIF.

* IF OLD_OK_CODE = 'APPROVE'.
*   if G_USER ne 'L1'.
*IF MODULEID = 'SRM' or  MODULEID = 'MM' or MODULEID = 'OLM'.
*
*  if ZIC_PREP_ROLEREQ-USERID = sy-uname.
*
*
*    endif.
*
*  endif.
*  ENDIF.
*ENDIF.
  "end of addition by lipsy  for approver on  20.03.2015 RD1K996555
  """"""""""""""""""""""""""""""""""

  IF OLD_OK_CODE = 'RELEASE' AND ZIC_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Request already released by creator'.

*          message e053(zhelp).
    PERFORM CLEAR.
    CALL SCREEN 100.

  ENDIF.

  IF OLD_OK_CODE = 'APPROVE'.

    IF G_USER = 'L1' AND ZIC_PREP_ROLEREQ-REQ_APP1_FL = ' ' AND
       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = 'Request not released by creator'.

*                   message e051(zhelp).
      PERFORM CLEAR.
      CALL SCREEN 100.

    ENDIF.

    IF ( G_USER = 'IM' OR G_USER = 'L3' ) AND
                          ZIC_PREP_ROLEREQ-REQ_APP_FL = ' ' AND
       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = 'Request not released by creator'.
*                   message e051(zhelp)..
      PERFORM CLEAR.
      CALL SCREEN 100.

    ENDIF.

    IF  ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' OR
        ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          TEXTLINE1 = 'Request already approved'.

      PERFORM CLEAR.
      CALL SCREEN 100.

    ENDIF.

  ENDIF.

  IF ( ZIC_PREP_ROLEREQ-STATUS = 'IF' OR
      ZIC_PREP_ROLEREQ-STATUS  = 'C' )
      AND OLD_OK_CODE <> 'DISPLAY'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        TEXTLINE1 = 'Request can not  be  changed, Can only be displayed'.

*              message e079(zhelp).
*               perform clear.
    OLD_OK_CODE = 'DISPLAY'.
    CALL SCREEN 100.

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
FORM VALIDATIONS1.

  DATA : L_DOCNO LIKE ZMM_PREP_ROLEREQ-DOCNO.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZIC_PREP_ROLEREQ-FUNDC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF SY-SUBRC <> 0.
    MESSAGE I166(ZHELP).
    G_ERROR_FUNDC = 'X'.
    CALL SCREEN 100.
  ENDIF.

  IF OLD_OK_CODE = 'CHANGE' OR
     OLD_OK_CODE = 'RELEASE' OR
     OLD_OK_CODE = 'APPROVE'.

    SELECT SINGLE DOCNO FROM ZIC_PREP_ROLEREQ
                    INTO L_DOCNO WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    IF SY-SUBRC <> 0.
      MESSAGE I167(ZHELP).
      G_ERROR_FUNDC = 'X'.
      CALL SCREEN 100.
    ENDIF.

  ENDIF.

  IF G_VAL_ERR = 'X'.
    CLEAR G_VAL_ERR.
    MESSAGE I118(ZHELP).
    CALL SCREEN 100.
  ENDIF.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF OLD_OK_CODE = 'APPROVE' AND
                      ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
      IF G_USER = 'IM' OR G_USER = 'L1'.
      ELSE.
        MESSAGE E048(ZHELP).
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM CHECK_TEL.

ENDFORM.                    " validations1


*---------------------------------------------------------------------*
*       FORM destroy_ctrl                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM DESTROY_CTRL.

  IF NOT FLAG2 IS INITIAL.
    CLEAR : FLAG2, FLAG1.
    CALL METHOD GV_TEXT_EDITOR1->FREE.
    CALL METHOD GV_TEXT_EDITOR2->FREE.
  ENDIF.

  IF NOT FLAG1 IS INITIAL.
    CLEAR FLAG1.
    CALL METHOD GV_TEXT_EDITOR1->FREE.
  ENDIF.

  CLEAR:GV_TEXT_EDITOR1,GV_TEXT_EDITOR2.

  PERFORM UNLOCK_RECORD.

ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  delete_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_REQUEST.

  DATA : L_CHOICE.
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

  DATA : L_GET3(1) TYPE C.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION         = 'Are you sure, you want to delete the Document? '
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = L_GET3
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC = 0.
    CASE L_GET3.
      WHEN '1'.
        MOVE 'J' TO L_CHOICE.
      WHEN '2'.
        MOVE 'N' TO L_CHOICE.
    ENDCASE.
  ENDIF.
  " End of <RD1K960036>.

  IF L_CHOICE = 'J'.
    CLEAR L_CHOICE.

**************************************

    ZIC_PREP_ROLEREQ-MANDT = SY-MANDT.

    DELETE ZIC_PREP_ROLEREQ FROM ZIC_PREP_ROLEREQ.

    IF SY-SUBRC = 0.

      PERFORM DELETE_ITEMS.


      IF ZIC_PREP_ROLEREQ-LONG_TEXT_FL <> ''.
        PERFORM DELETE_CORS_TEXT.
      ENDIF.

      PERFORM CLEAR.
      PERFORM UNLOCK_RECORD.
      CALL SCREEN 100.

    ELSE.

      MESSAGE I057(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.

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
FORM DELETE_ITEMS.

  LOOP AT G_TABCTRL100_ITAB INTO G_TABCTRL100_WA.

    MOVE-CORRESPONDING G_TABCTRL100_WA TO WA_ITEMTAB.
    WA_ITEMTAB-MANDT = SY-MANDT.
    APPEND WA_ITEMTAB TO IST_ITEMTAB.

  ENDLOOP.

  DELETE ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

  IF SY-SUBRC = 0.
    MESSAGE I120(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
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
FORM DELETE_CORS_TEXT.

  DATA : L_NAME LIKE THEAD-TDNAME.

  L_NAME = ZIC_PREP_ROLEREQ-DOCNO.

  CALL FUNCTION 'DELETE_TEXT'
    EXPORTING
      CLIENT    = SY-MANDT
      ID        = '0001'
      LANGUAGE  = SY-LANGU
      NAME      = L_NAME
      OBJECT    = 'ZHELP'
*     SAVEMODE_DIRECT = ' '
*     TEXTMEMORY_ONLY = ' '
*     LOCAL_CAT = ' '
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
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
FORM VERIFY.

  DATA L_CHOICE.
  CLEAR L_CHOICE.
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

  DATA : L_GET5(1) TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'RESET '
      TEXT_QUESTION         = 'Request already released Flags will be cancelled? '
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = L_GET5
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC = 0.
    CASE L_GET5.
      WHEN '1'.
        MOVE 'J' TO L_CHOICE.
      WHEN '2'.
        MOVE 'N' TO L_CHOICE.
    ENDCASE.
  ENDIF.
  " End of <RD1K960036>.

  IF L_CHOICE = 'J'.

    CLEAR ZIC_PREP_ROLEREQ-REQ_CR_FL.
    CLEAR ZIC_PREP_ROLEREQ-REQ_APP_FL.
    CLEAR ZIC_PREP_ROLEREQ-REQ_APP0_FL.
    CLEAR ZIC_PREP_ROLEREQ-REQ_APP1_FL.
    ZIC_PREP_ROLEREQ-STATUS = 'IC'.
    PERFORM SAVE_REQUEST.
**20/03/2006
    G_APP_REL = 'X'.
    CLEAR L_CHOICE.

  ELSE.

    PERFORM CLEAR.
    PERFORM UNLOCK_RECORD.
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
FORM CHECK_ITEMS_SAVE.
  IF OLD_OK_CODE <> 'DISPLAY' .

    IF OLD_OK_CODE = 'CRCROLES' OR ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0.

        IF ZMM_PREP_ROLECRC+0(1) = 'C'
*Begin of <RD1K962817>.
           OR ZMM_PREP_ROLECRC+0(1) = 'N'.
*End of <RD1K962817>.

          IF ZMM_PREP_ROLECRC-PLANT = 'X' AND
              WA_ITEMTAB-PLANT IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
            ROLLBACK WORK.
            MESSAGE I084(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.

          IF ZMM_PREP_ROLECRC-P_GRP = 'X' AND
             WA_ITEMTAB-GRP IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-P_GRP'.
            ROLLBACK WORK.
            MESSAGE I085(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.

          IF ZMM_PREP_ROLECRC-APP_LEVEL = 'X' AND
            WA_ITEMTAB-APPROVER IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-APPROVER'.
            ROLLBACK WORK.
            MESSAGE I096(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.
**
        ELSE.
*          G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.     "" commented by hiren
*          ROLLBACK WORK.
*          MESSAGE I197(ZHELP).
*          CLEAR OKCODE_100.
*          CALL SCREEN 100.
        ENDIF.

      ENDIF.

    ELSE.

      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                                                  WA_ITEMTAB-ROLE_NAME.
      IF SY-SUBRC = 0.

        IF ZMM_PREP_ROLEDES-PLANT = 'X' AND
                       ( OLD_OK_CODE = 'APPROVE' OR
                      OLD_OK_CODE = 'RELEASE' OR
                      OLD_OK_CODE = 'CHANGE' OR
                      OLD_OK_CODE = 'CREATE' OR
                      OLD_OK_CODE = 'CROSSCO' ) AND
                      NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

          IF WA_ITEMTAB-PLANT IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
            ROLLBACK WORK.
            MESSAGE I084(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF ZMM_PREP_ROLEDES-P_GRP = 'X' AND
                       ( OLD_OK_CODE = 'APPROVE' OR
                      OLD_OK_CODE = 'RELEASE' OR
                      OLD_OK_CODE = 'CHANGE'  OR
                      OLD_OK_CODE = 'CREATE'  OR
                      OLD_OK_CODE = 'CROSSCO' ) AND
                      NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

          IF WA_ITEMTAB-GRP IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
            ROLLBACK WORK.
            MESSAGE I085(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF ZMM_PREP_ROLEDES-S_LOC = 'X' AND
                       ( OLD_OK_CODE = 'APPROVE' OR
                      OLD_OK_CODE = 'RELEASE' OR
                      OLD_OK_CODE = 'CHANGE' OR
                      OLD_OK_CODE = 'CREATE' OR
                      OLD_OK_CODE = 'CROSSCO' ) AND
                      NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

          IF WA_ITEMTAB-SLOC IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
            ROLLBACK WORK.
            MESSAGE I090(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF ZMM_PREP_ROLEDES-R_LOC = 'X' AND
                       ( OLD_OK_CODE = 'APPROVE' OR
                      OLD_OK_CODE = 'RELEASE' OR
                      OLD_OK_CODE = 'CHANGE' OR
                      OLD_OK_CODE = 'CREATE' OR
                      OLD_OK_CODE = 'CROSSCO' ) AND
                      NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

          IF WA_ITEMTAB-RECEIPT_LOC IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
            ROLLBACK WORK.
            MESSAGE I095(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF ZMM_PREP_ROLEDES-APP_LEVEL = 'X' AND
                       ( OLD_OK_CODE = 'APPROVE' OR
                      OLD_OK_CODE = 'RELEASE' OR
                      OLD_OK_CODE = 'CHANGE' OR
                      OLD_OK_CODE = 'CREATE' OR
                      OLD_OK_CODE = 'CROSSCO' ) AND
                      NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

          IF WA_ITEMTAB-APPROVER IS INITIAL.
            G_FIELD = 'ZIC_PREP_ROLEREI-APPROVER'.
            ROLLBACK WORK.
            MESSAGE I096(ZHELP) WITH G_I.
            CLEAR OKCODE_100.
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
  PERFORM VALIDATE_LINEITEM_DATAX.
ENDFORM.                    " check_items_save
*&---------------------------------------------------------------------*
*&      Form  verify1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VERIFY1.

  DATA : L_CHOICE.
  CLEAR L_CHOICE.
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

  DATA : L_GET6(1) TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Do you want to cancel release? '
      TEXT_QUESTION         = 'If u cancel release, u can change data else go in display mode'
                              & ' & just do correspondence without cancelling release.'
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = L_GET6
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC = 0.
    CASE L_GET6.
      WHEN '1'.
        MOVE 'J' TO L_CHOICE.
      WHEN '2'.
        MOVE 'N' TO L_CHOICE.
    ENDCASE.
  ENDIF.
  " End of <RD1K960036>.

  IF L_CHOICE = 'J'.

    OLD_OK_CODE = 'CHANGE'.
    CLEAR L_CHOICE.

  ELSE.

    OLD_OK_CODE = 'DISPLAY'.
    CLEAR L_CHOICE.

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
FORM CHECK_TEL.

  IF    ( ( OLD_OK_CODE = 'DISPLAY' OR OLD_OK_CODE = 'CHANGE' OR
         OLD_OK_CODE = 'DELETE'
         OR OLD_OK_CODE = 'RELEASE' OR OLD_OK_CODE = 'APPROVE' )
         AND G_HD_COPIED = 'X' )
         OR ( OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' ).
    DATA : TEL_LEN TYPE I.
    TEL_LEN = STRLEN( ZIC_PREP_ROLEREQ-TELNO ).
    IF  ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
      MESSAGE I097(ZHELP).
      CALL SCREEN 100.
    ELSE.
      IF TEL_LEN < 7.
        MESSAGE I098(ZHELP).
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
FORM VALIDATE_LINEITEM_DATAX.
*--------Added by Manisha bh.Dt:09.02.2018--------*
  TYPES : BEGIN OF TY_BUKRS,
            WERKS LIKE ZD_T001W_BUKRS-WERKS,
            NAME1 LIKE ZD_T001W_BUKRS-NAME1,
          END OF TY_BUKRS.

  DATA   : L_ZAREA LIKE ZMM_CONSM-ZAREA.
  DATA   : WA_T001L LIKE T001L.
  DATA   : IT_T001L TYPE TABLE OF T001L WITH HEADER LINE.

  DATA   : IT_BUKRS TYPE TABLE OF TY_BUKRS WITH HEADER LINE. "Added by Manisha bh.Dt:09.02.2018

  DATA : IT_RECPT TYPE STANDARD TABLE OF ZMM_LOCATION.
  DATA : WA_RECPT LIKE ZMM_LOCATION.
*-----------------------------------------------------------*
  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

* Begin of <RD1K981840>
*concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.
    CPF_LFB1 = ZIC_PREP_ROLEREQ-USERID.
* End of <RD1K981840>

**---------- Changes Start date 24.06.2016 11:49:02-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:49:02-----------------


    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER

***START OF COMMENT <RD1K983325>   CR: 30007580  dt: 05.04.2013.
*      G_CCODE = ist_data-bukrs.
***end OF COMMENT <RD1K983325>.

**code added by CAB_AMITMOZA  <RD1K983325>   CR: 30007580  dt: 05.04.2013.
      G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.
**code end by CAB_AMITMOZA  <RD1K983325>

    ENDIF.

  ELSE.

    G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.

    IF OLD_OK_CODE = 'CRCROLES' OR ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

*** 15/05/2007
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC <> 0.
        ROLLBACK WORK.
        MESSAGE E200(ZHELP).
      ELSE.
*** 31/05/2007
        IF NOT ZMM_PREP_CRCDESG-ROLE_POS IS INITIAL.
          SELECT SINGLE * FROM AGR_USERS WHERE
                   UNAME = ZIC_PREP_ROLEREQ-USERID AND
                   AGR_NAME = ZMM_PREP_CRCDESG-ROLE_POS.
          IF SY-SUBRC = 0.
            ROLLBACK WORK.
            PERFORM MESSAGE1.
            LEAVE PROGRAM.
          ELSE.
            ROLLBACK WORK.
            PERFORM MESSAGE2.
            LEAVE PROGRAM.
          ENDIF.
        ENDIF.
      ENDIF.
***
      SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                      G_TABLCTRL110_WA-ROLE_NAME.

      IF SY-SUBRC <> 0.
        ROLLBACK WORK.
        MESSAGE E117(ZHELP).
      ENDIF.

    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                      G_TABLCTRL110_WA-ROLE_NAME.
      IF SY-SUBRC <> 0.
        ROLLBACK WORK.
        MESSAGE E118(ZHELP).
      ENDIF.

    ENDIF.

**********************************************************

    IF OLD_OK_CODE <> 'DISPLAY'.

      IF OLD_OK_CODE = 'CRCROLES'.

      ELSE.

        IF ZMM_PREP_ROLEDES-MM_DISC_FLAG = 'X'.

          IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
          ELSE.
            ROLLBACK WORK.
            MESSAGE E081(ZHELP) WITH G_TABLCTRL110_WA-ROLE_NAME.
          ENDIF.

        ENDIF.

      ENDIF.

*  endif.

      IF NOT G_TABLCTRL110_WA-PLANT IS INITIAL.

        SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                   TABLE IT_BUKRS  WHERE BUKRS = ZIC_PREP_ROLEREQ-CCODE
                                      AND WERKS = G_TABLCTRL110_WA-PLANT.
        IF SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE E068(ZHELP) WITH G_TABLCTRL110_WA-ROLE_NAME.

        ENDIF.

      ENDIF.


************finding group*******************

      REFRESH : IT_COND, IT_T024, IT_T024_1.
*  clear   : it_cond, it_t024, it_t024_1.
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
      """""""""""""""""""""""""""""
      """"""""""""""""""""""""""""""""""""
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
      IF  NOT G_TABLCTRL110_WA-GRP IS INITIAL.

        LOOP AT IT_T024 INTO WA_T024.

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
          ROLLBACK WORK.
          MESSAGE I069(ZHELP).
          CALL SCREEN 100.

        ENDIF.

      ENDIF.

***************************

      CLEAR : L_ZAREA, WA_T001L.
      REFRESH IT_T001L.

      IF ( G_TABLCTRL110_WA-ROLE_NAME = 'M13' OR
         G_TABLCTRL110_WA-ROLE_NAME = 'M14' OR
          G_TABLCTRL110_WA-ROLE_NAME = 'M16' OR
          G_TABLCTRL110_WA-ROLE_NAME = 'M18' OR
          G_TABLCTRL110_WA-ROLE_NAME = 'M19' ) AND
          NOT G_TABLCTRL110_WA-PLANT IS INITIAL.

        SELECT * FROM T001L INTO CORRESPONDING FIELDS OF
                     TABLE IT_T001L  WHERE WERKS = G_TABLCTRL110_WA-PLANT.

        IF  SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE E074(ZHELP).

        ENDIF.

      ENDIF.

      IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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

      IF  NOT G_TABLCTRL110_WA-SLOC IS INITIAL.

        LOOP AT IT_T001L INTO WA_T001L.

          IF G_TABLCTRL110_WA-SLOC = WA_T001L-LGORT.
            LOC_FLAG = 'X'.
          ENDIF.

        ENDLOOP.

        IF LOC_FLAG = 'X'.
          CLEAR LOC_FLAG.
        ELSE.
** cab_ajit 07.02.2006
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
          ROLLBACK WORK.
          MESSAGE E073(ZHELP).

        ENDIF.

      ENDIF.


***************************

      CLEAR WA_RECPT.
      REFRESH IT_RECPT.

      IF ( G_TABLCTRL110_WA-ROLE_NAME = 'M12' OR
         G_TABLCTRL110_WA-ROLE_NAME = 'M17' ) AND
         NOT G_TABLCTRL110_WA-RECEIPT_LOC IS INITIAL.

        SELECT * FROM ZMM_LOCATION INTO TABLE IT_RECPT.

        IF G_TABLCTRL110_WA-ROLE_NAME = 'M12'.

          LOOP AT IT_RECPT INTO WA_RECPT.

            IF WA_RECPT-LOCCG <> 'RL'.
              DELETE IT_RECPT.
            ENDIF.

          ENDLOOP.

        ENDIF.


        IF G_TABLCTRL110_WA-ROLE_NAME = 'M17'.

          LOOP AT IT_RECPT INTO WA_RECPT.

            IF WA_RECPT-LOCCG <> 'CF'.
              DELETE IT_RECPT.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

      IF  NOT G_TABLCTRL110_WA-RECEIPT_LOC IS INITIAL.

        LOOP AT IT_RECPT INTO WA_RECPT.

          IF G_TABLCTRL110_WA-RECEIPT_LOC = WA_RECPT-LOCCD.
            LOC_FLAG = 'X'.
          ENDIF.

        ENDLOOP.

        IF LOC_FLAG = 'X'.
          CLEAR LOC_FLAG.
        ELSE.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          ROLLBACK WORK.
          MESSAGE E075(ZHELP).

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
FORM ATTACH_FILES.
  DATA LS_SODOCCHGI1 TYPE SODOCCHGI1.
  CLEAR G_ATT_FILES_WA.
  REFRESH G_ATT_FILES.

  G_ATT_FILES_WA-LOGSYS = ZIC_PREP_ROLEREQ-DOCNO+2(10).
  G_ATT_FILES_WA-OBJTYPE = 'ATT'.
  G_ATT_FILES_WA-OBJKEY = '01'.

  APPEND G_ATT_FILES_WA TO G_ATT_FILES.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
    EXPORTING
      ATTACHMENT_DATA     = LS_SODOCCHGI1
      ATTACHMENT_TYPE     = 'DOC'
    TABLES
      APPLICATION_OBJECTS = G_ATT_FILES.


ENDFORM.                    " attach_files
*&---------------------------------------------------------------------*
*&      Form  list_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_FILES.

  G_ATT_FILES_WA-LOGSYS = ZIC_PREP_ROLEREQ-DOCNO+2(10).
  G_ATT_FILES_WA-OBJTYPE = 'ATT'.
  G_ATT_FILES_WA-OBJKEY = '01'.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      APPLICATION_OBJECT = G_ATT_FILES_WA
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
FORM POP_UP_MESSAGE.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL     = 'Choosing Location '
      TEXTLINE1 = 'It is understood that user has joined at new location & HR Data'
      TEXTLINE2 = 'is updated. Please choose appropriate current location?'
*     START_COLUMN = 25
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
FORM ITEMS_APPROVAL_CHECK.
  SELECT * FROM ZIC_PREP_ROLEREI INTO TABLE IST_ITEMTAB
  WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
  LOOP AT IST_ITEMTAB INTO WA_ITEMTAB.
    IF WA_ITEMTAB-REJ_FL IS INITIAL.
** Header level changes for integration
      PERFORM VALIDATE_ROLE_APPROVAL_LEVEL.
    ENDIF.
  ENDLOOP.
  CLEAR IST_ITEMTAB.
  REFRESH IST_ITEMTAB[].
  CLEAR WA_ITEMTAB.
**      if sy-subrc = 0.
** Messages to be checked modulewise in sub
  PERFORM CLEAR1.

  """"""""""""""""""""""""""""""
*  BREAK-POINT.
  """"""""""""""""""""""""""""""""""
  IF OLD_OK_CODE = 'CROSSCO' OR
        ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.

    IF OLD_OK_CODE = 'RELEASE' OR
        OLD_OK_CODE = 'CROSSCO' OR
        OLD_OK_CODE = 'CHANGE'.
** code added by CAB_AMITMOZA   CR:30007580    01.03.2013
      SELECT * FROM ZIC_PREP_ROLEREI UP TO 1 ROWS

 WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF ZIC_PREP_ROLEREI-MODULEID = 'OLM'.
        PERFORM POPUP_RELEASE_MESSAGE3.
      ELSE.
** code END by CAB_AMITMOZA   CR:30007580
        PERFORM POPUP_RELEASE_MESSAGE.
      ENDIF.
    ENDIF.

    IF OLD_OK_CODE = 'APPROVE' OR
       ZIC_PREP_ROLEREQ-STATUS = 'IF'.

      """"""""""""""""""
      "added by lipsy  for cross company  on 9.03.2015 RD1K996555
      IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
        IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' .

        ELSE.
          "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555
          """"""""""""""""""""""
**********************************************@
          PERFORM POPUP_APPROVE_MESSAGE.
**********************************************@
          """"""""""""""""""""""""""""""""
          "added by lipsy  for cross company  on 9.03.2015 RD1K996555
        ENDIF.
      ENDIF.
      "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555

      """""""""""""""""""""""""""
    ENDIF.

    """""""""""""""""""""""""
    "added by lipsy  for cross company  on 9.03.2015 RD1K996555
    IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
      IF   OLD_OK_CODE = 'APPROVE' AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' .

      ELSE.
        "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555

        """"""""""""""""""""""""""""""""""
        PERFORM POP_UP_CROSSCO_MESSAGE.

        """""""""""""""""""""""""""""""""""""
        "added by lipsy  for cross company  on 9.03.2015 RD1K996555
      ENDIF.
    ENDIF.
    ""end of addition by lipsy  for cross company on 9.03.2015 RD1K996555

    """"""""""""""""""""""""""""""""""""""

    .
*          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
    SET PARAMETER ID 'ZREQNO'
       FIELD ZIC_PREP_ROLEREQ-DOCNO.

    """""""""""""""""""""""""""
    "added by lipsy  for cross company  on 9.03.2015 RD1K996555
    IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
      IF OLD_OK_CODE = 'APPROVE' AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' .

      ELSE.
        ""end of addition by lipsy  for cross company on 9.03.2015 RD1K996555

        """""""""""""""""""""""""""""""""""
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.





        """"""""""""""""""""""""""""""
        """""added by lipsy  for cross company  on 9.03.2015  RD1K996555
        """""""""""""""""""""
      ENDIF.
    ENDIF.
    IF OLD_OK_CODE = 'APPROVE' AND   ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' .
      IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
        """"""""""""
        PERFORM CREATE_ROLES.
      ENDIF.
    ENDIF.
    """""end of addition by lipsy  for cross company on 9.03.2015 RD1K996555
    """""""""""""""""""""""""""""""""
**********************************************    code added by Bipin shukla : on 22/12/2013 sab_bipin
    IF OLD_OK_CODE = 'CROSSCO' OR OLD_OK_CODE = 'CHANGE'.
      CLEAR : IT_TVARV.
      SELECT * FROM TVARVC INTO CORRESPONDING FIELDS OF TABLE IT_TVARV
      WHERE NAME = 'ZGRC_CALL'.
      IF IT_TVARV[] IS NOT INITIAL.
        READ TABLE IT_TVARV INTO WA_TVARV WITH KEY NAME = 'ZGRC_CALL'.
      ENDIF.

      IF WA_TVARV-LOW IS NOT INITIAL.
        LV_GRCCALL = WA_TVARV-LOW.
      ENDIF.

      IF SYST-SYSID = 'RD1'.

        LV5_RFC = 'GRDCLNT500'.

      ELSEIF SYST-SYSID = 'RQ1'.

        LV5_RFC = 'GRDCLNT500'.

      ELSEIF SYST-SYSID = 'RP1'.

        LV5_RFC = 'GRPCLNT500'.
      ENDIF.

      CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
        EXPORTING
          RFCDESTINATION = LV5_RFC "'GRDCLNT500'
        IMPORTING
          RFC_SUBRC      = LV_SUBRC.

      IF  LV_GRCCALL = 'X' AND LV_SUBRC = '0'.
*        MESSAGE I232(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
        CLEAR TXT1.
        CONCATENATE 'Risk Analysis in Progress for Doc.' ZIC_PREP_ROLEREQ-DOCNO INTO TXT1 SEPARATED BY SPACE.
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            TITEL = 'Information'
            TXT1  = TXT1
            TXT2  = 'To view the report, Pls press ENTER'
*           TXT3  = ' '
*           TXT4  = ' '
          .

        REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
        EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
        PERFORM GRC_RISK_ANALYSIS.
        IMPORT GT_RDESC FROM MEMORY ID 'IM_GT_RDESC'.
        CALL TRANSACTION 'ZGRC_RESULT'.
        CLEAR REQNUM_EX.
      ENDIF.
    ENDIF.
**********************************************    code added by Bipin shukla : on 22/12/2013 sab_bipin

  ELSE.
    IF OLD_OK_CODE = 'CRCROLES' OR
      ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
      IF OLD_OK_CODE = 'RELEASE' OR
         OLD_OK_CODE = 'CRCROLES' OR
         OLD_OK_CODE = 'CHANGE'.
** code added by CAB_AMITMOZA   CR:30007580    01.03.2013
        SELECT * FROM ZIC_PREP_ROLEREI UP TO 1 ROWS

 WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF ZIC_PREP_ROLEREI-MODULEID = 'OLM'.
          PERFORM POPUP_RELEASE_MESSAGE3.
        ELSE.
** code END by CAB_AMITMOZA   CR:30007580


**          PERFORM POPUP_RELEASE_MESSAGE.  " commented by ss on 14.9.21
**             Added by ss on 14.9.21

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      TITEL     = 'Approval Requirement'
      TEXTLINE1 = 'Kindly get the request approved by competent authority: L1'.
**   EOC by ss on 14.9.21

        ENDIF.
      ENDIF.
      IF OLD_OK_CODE = 'APPROVE' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IF'.
        PERFORM POPUP_APPROVE_MESSAGE.
      ENDIF.
*      PERFORM POP_UP_CRC_MESSAGE.   " Commented by ss on 14.9.21


******************************      Added by ss on 14.9.21
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL     = 'CRC Authorizations '
      TEXTLINE1 = 'Please attach the scanned copy with the request and '
      TEXTLINE2 = ' send email to SAP Core Team. '
*     START_COLUMN = 25
*     START_ROW = 6
    .

**************************      ,  EOC by ss on 14.9.21

*              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
      MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      G_CRC_FL = 'X'.
***************************************************cab_dns********************************
      SET PARAMETER ID 'ZREQNO'
     FIELD ZIC_PREP_ROLEREQ-DOCNO.
*    MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
**********************************************    code added by Bipin shukla : on 22/12/2013 sab_bipin
      IF OLD_OK_CODE = 'CRCROLES' OR OLD_OK_CODE = 'CHANGE'.
        CLEAR : IT_TVARV.
        SELECT * FROM TVARVC INTO CORRESPONDING FIELDS OF TABLE IT_TVARV
        WHERE NAME = 'ZGRC_CALL'.
        IF IT_TVARV[] IS NOT INITIAL.
          READ TABLE IT_TVARV INTO WA_TVARV WITH KEY NAME = 'ZGRC_CALL'.
        ENDIF.

        IF WA_TVARV-LOW IS NOT INITIAL.
          LV_GRCCALL = WA_TVARV-LOW.
        ENDIF.

        IF SYST-SYSID = 'RD1'.

          LV5_RFC = 'GRDCLNT500'.

        ELSEIF SYST-SYSID = 'RQ1'.

          LV5_RFC = 'GRDCLNT500'.

        ELSEIF SYST-SYSID = 'RP1'.

          LV5_RFC = 'GRPCLNT500'.
        ENDIF.

        CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
          EXPORTING
            RFCDESTINATION = LV5_RFC "'GRDCLNT500'
          IMPORTING
            RFC_SUBRC      = LV_SUBRC.

        IF  LV_GRCCALL = 'X' AND LV_SUBRC = '0'.
*        MESSAGE I232(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
          CLEAR TXT1.
          CONCATENATE 'Risk Analysis in Progress for Doc.' ZIC_PREP_ROLEREQ-DOCNO INTO TXT1 SEPARATED BY SPACE.
          CALL FUNCTION 'POPUP_TO_INFORM'
            EXPORTING
              TITEL = 'Information'
              TXT1  = TXT1
              TXT2  = 'To view the report, Pls press ENTER'
*             TXT3  = ' '
*             TXT4  = ' '
            .

          REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
          EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
          PERFORM GRC_RISK_ANALYSIS.
          IMPORT GT_RDESC FROM MEMORY ID 'IM_GT_RDESC'.
          CALL TRANSACTION 'ZGRC_RESULT'.
          CLEAR REQNUM_EX.
        ENDIF.
      ENDIF.
**********************************************    code added by Bipin shukla : on 22/12/2013 sab_bipin

***************************************************cab_dns********************************

    ELSE.
      IF OLD_OK_CODE = 'RELEASE'.
** code added by CAB_AMITMOZA   CR:30007580    01.03.2013
        SELECT * FROM ZIC_PREP_ROLEREI UP TO 1 ROWS

 WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF ZIC_PREP_ROLEREI-MODULEID = 'OLM'.
          PERFORM POPUP_RELEASE_MESSAGE3.
        ELSE.
** code END by CAB_AMITMOZA   CR:30007580
          PERFORM POPUP_RELEASE_MESSAGE.
        ENDIF.
        SET PARAMETER ID 'ZREQNO'
          FIELD ZIC_PREP_ROLEREQ-DOCNO.
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ELSEIF OLD_OK_CODE = 'APPROVE'.
** 13/04/07
        IF MODULE_CHANGED_FLAG <> 'X'.

          """""""""""""""""""""""""
          "added by lipsy on 23.02.2015 for getting  requests assigned simultaneously after approval
          "with less message RD1K996042


          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*commented by lipsy on 4.03.2015 for getting  requests assigned simultaneously after approval
          "with less message RD1K996555

*         IF  zic_prep_rolerei-moduleid = 'MM' or zic_prep_rolerei-moduleid = 'OLM'.

*end of comment by lipsy on 4.03.2015 for getting  requests assigned simultaneously after approval
          "with less message RD1K996555
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """"""""""""""""""""""""""""""""""""""""
*added by lipsy on 4.03.2015 for getting  requests assigned simultaneously after approval
          "with less message RD1K996555

          IF  ZIC_PREP_ROLEREI-MODULEID = 'MM' OR ZIC_PREP_ROLEREI-MODULEID = 'OLM' OR ZIC_PREP_ROLEREI-MODULEID = 'SRM'.

*end of addition by lipsy on 4.03.2015 for getting  requests assigned simultaneously after approval
            "with less message RD1K996555
            """"""""""""""""""""""""
          ELSE.
            "end of addition by lipsy on 23.02.2015 for getting  requests assigned simultaneously after approval
            "with less message RD1K996042
            """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
            """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
            "commented by lipsy on 23.02.2015 for getting  requests assigned simultaneously after approval
            "with less message RD1K996042
*          .
            "end of comment by lipsy on 23.02.2015 for getting  requests assigned simultaneously after approval
            "with less message RD1K996042
            """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
********************************************************@
*            PERFORM POPUP_APPROVE_MESSAGE.
********************************************************@
            """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
            "added by lipsy on 23.02.2015 for getting  requests assigned simultaneously after approval
            "with less message RD1K996042
          ENDIF.
          "end of addition by lipsy on 23.02.2015 for getting  requests assigned simultaneously after approval
          "with less message RD1K996042
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          "Added by lipsy on 13.02.2015 for getting  requests assigned simultaneously after approval
                                                            "RD1K996042
          IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
            """"""""""""

            """"""""""""""""
            PERFORM CREATE_ROLES.
          ELSEIF ZIC_PREP_ROLEREI-MODULEID = 'OLM'.
            PERFORM CREATE_ROLES_OLM.
            """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
            "added by lipsy on 4.03.2015 for getting  requests assigned simultaneously after approval
            "for srm RD1K996555
          ELSEIF ZIC_PREP_ROLEREI-MODULEID = 'SRM'.
            PERFORM CREATE_ROLES_SRM.

            "end of addition by lipsy on 4.03.2015 for getting  requests assigned simultaneously after approval
            "for srm RD1K996555
            """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
************************************************@
          ELSE.
            PERFORM CREATE_ROLES.
************************************************@
          ENDIF.
          "end of Addition by lipsy on 13.02.2015 for getting  requests assigned simultaneously after approval
                                                            "RD1K996042
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


****************************************** changes done by bipin shukla to sent mail

          IMPORT CRT_NAME FROM MEMORY ID 'CRT_NAME_RJ'.
          CLEAR : WA_URINFO , WA_UNAME , WA_APPINFO.

*          **---------- Changes Start date 24.06.2016 12:04:39-------------------
* SELECT SINGLE PERNR FROM PA0105 INTO WA_URINFO-PERNR WHERE USRID = CRT_NAME
*          AND USRTY = '0001'. "AND ENDDA = '31.12.9999'.

          SELECT PERNR FROM ZPA0105 INTO WA_URINFO-PERNR UP TO 1 ROWS WHERE USRID = CRT_NAME
 AND USRTY = '0001'
 ORDER BY PRIMARY KEY .
 ENDSELECT. "AND ENDDA = '31.12.9999'.
*          *---------- Changee  Ending Date 24.06.2016 12:04:39-----------------

*if WA_URINFO-PERNR is not INITIAL.
          IF SY-SUBRC EQ 0.

**---------- Changes Start date 24.06.2016 12:04:18-------------------
            SELECT USRID_LONG FROM ZPA0105 INTO WA_URINFO-USRID_LONG UP TO 1 ROWS WHERE PERNR = WA_URINFO-PERNR
 AND USRTY = '0010'
 ORDER BY PRIMARY KEY .
 ENDSELECT. " AND ENDDA = '31.12.9999'.
**---------- Changee  Ending Date 24.06.2016 12:04:18-----------------

          ENDIF.

          IF WA_URINFO-PERNR IS NOT INITIAL.

**---------- Changes Start date 24.06.2016 12:03:59-------------------
*      SELECT SINGLE *   FROM PA0002 INTO CORRESPONDING FIELDS OF WA_UNAME
*                  WHERE PERNR = WA_URINFO-PERNR.

            SELECT SINGLE *   FROM ZPA0002 INTO CORRESPONDING FIELDS OF WA_UNAME
                   WHERE PERNR = WA_URINFO-PERNR.
**---------- Changee  Ending Date 24.06.2016 12:03:59-----------------

          ENDIF.

**********************************************Get approver user name

**---------- Changes Start date 24.06.2016 12:05:27-------------------
*       SELECT SINGLE PERNR FROM PA0105 INTO WA_APPINFO-PERNR WHERE USRID = SY-UNAME
*          AND USRTY = '0001'. "AND ENDDA = '31.12.9999'.
*          IF SY-SUBCS EQ 0.
*            SELECT SINGLE *   FROM PA0002 INTO CORRESPONDING FIELDS OF WA_APPNAME
*                  WHERE PERNR = WA_APPINFO-PERNR.
*          ENDIF.

          SELECT PERNR FROM ZPA0105 INTO WA_APPINFO-PERNR UP TO 1 ROWS WHERE USRID = SY-UNAME
 AND USRTY = '0001'
 ORDER BY PRIMARY KEY .
 ENDSELECT. "AND ENDDA = '31.12.9999'.
          IF SY-SUBCS EQ 0.
            SELECT * FROM ZPA0002 INTO CORRESPONDING FIELDS OF WA_APPNAME UP TO 1 ROWS
 WHERE PERNR = WA_APPINFO-PERNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          ENDIF.
**---------- Changee  Ending Date 24.06.2016 12:05:27-----------------


          CONCATENATE WA_APPNAME-NACHN WA_APPNAME-VORNA INTO LV_APPNAME SEPARATED BY SPACE.
**********************************************Get approver user name


          CONCATENATE 'Approval of Role Request No.' ZIC_PREP_ROLEREQ-DOCNO
        INTO DOCDATA-OBJ_DESCR SEPARATED BY SPACE.

          WA_OBJHEAD = 'Dear Sir/Madam,'.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.
          CLEAR WA_OBJHEAD.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.

          CONCATENATE 'Your Role Request No.' ZIC_PREP_ROLEREQ-DOCNO 'has been approved and sent to ICE Core Team for assignment'
          INTO  WA_OBJHEAD SEPARATED BY SPACE.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.
          CLEAR WA_OBJHEAD.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.

          WA_OBJHEAD = 'Please check your request for details'.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.
          CLEAR WA_OBJHEAD.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.

          CLEAR WA_OBJHEAD.

          APPEND WA_OBJHEAD TO GT_OBJHEAD.

          WA_OBJHEAD = 'Regards'.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.
          CLEAR WA_OBJHEAD.
          WA_OBJHEAD = LV_APPNAME.
          APPEND WA_OBJHEAD TO GT_OBJHEAD.
          CLEAR WA_OBJHEAD.




*      WA_RECLIST-RECEIVER  = 'bipin@sapcnorth.in'.
          WA_RECLIST-RECEIVER  = WA_URINFO-USRID_LONG.
          WA_RECLIST-REC_TYPE = 'U'.
          APPEND WA_RECLIST TO GT_RECLIST.
          WA_RECLIST-RECEIVER  = CRT_NAME.
          WA_RECLIST-REC_TYPE = 'B'.
          APPEND WA_RECLIST TO GT_RECLIST.

*** Creation of the entry for the document
          DESCRIBE TABLE GT_OBJHEAD LINES LV_TAB_LINES.
          CLEAR OBJPACK-TRANSF_BIN.
          OBJPACK-HEAD_START = 1.
          OBJPACK-HEAD_NUM = 0.
          OBJPACK-BODY_START = 1.
          OBJPACK-BODY_NUM = LV_TAB_LINES.
          OBJPACK-DOC_TYPE = 'RAW'.
          APPEND OBJPACK." TO LT_OBJPACK.
          CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
            EXPORTING
              DOCUMENT_DATA              = DOCDATA
              PUT_IN_OUTBOX              = 'X'
              COMMIT_WORK                = 'X'
            TABLES
              PACKING_LIST               = OBJPACK[]
*             OBJECT_HEADER              =
*             CONTENTS_BIN               =
              CONTENTS_TXT               = GT_OBJHEAD[]
*             CONTENTS_HEX               =
*             OBJECT_PARA                =
*             OBJECT_PARB                =
              RECEIVERS                  = GT_RECLIST[]
            EXCEPTIONS
              TOO_MANY_RECEIVERS         = 1
              DOCUMENT_NOT_SENT          = 2
              DOCUMENT_TYPE_NOT_EXIST    = 3
              OPERATION_NO_AUTHORIZATION = 4
              PARAMETER_ERROR            = 5
              X_ERROR                    = 6
              ENQUEUE_ERROR              = 7
              OTHERS                     = 8.
          IF SY-SUBRC EQ 0.
* Implement suitable error handling here
            MESSAGE 'Mail successfully sent to creator !!' TYPE 'S'.
          ENDIF.


****************************************** changes done by bipin shukla to sent mail
          MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
        ENDIF.
        SET PARAMETER ID 'ZREQNO'
          FIELD ZIC_PREP_ROLEREQ-DOCNO.
*                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
      ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE =
'CHANGE'.
** 13/04/07
        IF MODULE_CHANGED_FLAG <> 'X'.
** code added by CAB_AMITMOZA   CR:30007580    01.03.2013
          IF ZIC_PREP_ROLEREI-MODULEID = 'OLM'.
            PERFORM POPUP_RELEASE_MESSAGE2.
          ELSE.
** code end by CAB_AMITMOZA   CR:30007580
            PERFORM POPUP_RELEASE_MESSAGE1.
          ENDIF.
          MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
        ENDIF.
        SET PARAMETER ID 'ZREQNO'
          FIELD ZIC_PREP_ROLEREQ-DOCNO.
****************** code added by Bipin : 20/09/2013
********************************* start of chages by bipin : for risk analysis : 02/09/2013
        CLEAR : IT_TVARV.
        SELECT * FROM TVARVC INTO CORRESPONDING FIELDS OF TABLE IT_TVARV
        WHERE NAME = 'ZGRC_CALL'.
        IF IT_TVARV[] IS NOT INITIAL.
          READ TABLE IT_TVARV INTO WA_TVARV WITH KEY NAME = 'ZGRC_CALL'.
        ENDIF.
        IF WA_TVARV-LOW IS NOT INITIAL.
          LV_GRCCALL = WA_TVARV-LOW.
        ENDIF.

        IF SYST-SYSID = 'OCD'.

          LV6_RFC = 'GRDCLNT500'.

        ELSEIF SYST-SYSID = 'OCQ'.

          LV6_RFC = 'GRDCLNT500'.

        ELSEIF SYST-SYSID = 'OCP'.

          LV6_RFC = 'GRPCLNT500'.
        ENDIF.

        CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
          EXPORTING
            RFCDESTINATION = LV6_RFC "'GRDCLNT500'
*           RFCDESTINATION = 'GRPCLNT500TEST'    changes on 02.08.2014  CAB_DNS
          IMPORTING
*           MSGV1          =
*           MSGV2          =
            RFC_SUBRC      = LV_SUBRC.

*        DATA : LV_RFC TYPE BOOLEAN.
*
*        CALL FUNCTION 'CHECK_RFC_DESTINATION'
*          EXPORTING
*            I_DESTINATION                    = 'GRDCLNT500'
*         IMPORTING
*           E_USER_PASSWORD_INCOMPLETE       =  LV_RFC
        .

        IF  LV_GRCCALL = 'X' AND LV_SUBRC = '0'.
*        IF  LV_GRCCALL = 'X' AND LV_RFC IS NOT INITIAL.
*          MESSAGE I232(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
          CLEAR TXT1.
          CONCATENATE 'Risk Analysis in Progress for Doc.' ZIC_PREP_ROLEREQ-DOCNO INTO TXT1 SEPARATED BY SPACE.
          CALL FUNCTION 'POPUP_TO_INFORM'
            EXPORTING
              TITEL = 'Information'
              TXT1  = TXT1
              TXT2  = 'To view the report, Pls press ENTER'.

          REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
          EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
          PERFORM GRC_RISK_ANALYSIS.
          IMPORT GT_RDESC FROM MEMORY ID 'IM_GT_RDESC'.
*          IF GT_RDESC IS NOT INITIAL.
          CALL TRANSACTION 'ZGRC_RESULT'.
*          ELSE.
*          MESSAGE 'No risk found!!' TYPE 'I'.
*          ENDIF.
*          CLEAR GT_RDESC.
          CLEAR REQNUM_EX.
        ENDIF.
****************************** end of chages by bipin : for risk analysis : 02/09/2013
******************* code added by Bipin : 20/09/2013

*                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
      ELSEIF ZIC_PREP_ROLEREQ-STATUS = 'IF'.
        PERFORM POPUP_APPROVE_MESSAGE.
      ELSE.
        SET PARAMETER ID 'ZREQNO'
          FIELD ZIC_PREP_ROLEREQ-DOCNO.
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
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
FORM POP_UP_CRC_MESSAGE.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL     = 'CRC Authorizations '
      TEXTLINE1 = 'Please attach the scanned order copy with the request or '
      TEXTLINE2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN = 25
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
FORM POP_UP_CROSSCO_MESSAGE.
*Begin of <RD1K963151>.
*CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*  EXPORTING
*   TITEL              = 'Cross Company Authorisations '
*   TEXTLINE1          = 'Please attach the scanned order copy with the request or '
*   TEXTLINE2          = 'Please send order copy by fax to Head-ICE '
**   START_COLUMN       = 25
**   START_ROW          = 6
  .
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL     = 'Cross Company Authorisations '
      TEXTLINE1 = 'Please attach the scanned order copy with the request. '.
*End of <RD1K963151>.
ENDFORM.                    " pop_up_crossco_message
*&---------------------------------------------------------------------*
*&      Form  validate_role_approval_level
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_ROLE_APPROVAL_LEVEL.

** Check approval module wise & line item wise

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP
       WHERE ROLE_TYPE = WA_ITEMTAB-ROLE_NAME.

  IF SY-SUBRC = 0.

    IF ZMM_PREP_ROLEGRP-APPROVER1 = 'L3' AND
                 G_APPROVER_LEVEL = 'L3'.

    ELSEIF ZMM_PREP_ROLEGRP-APPROVER1 = 'IM' AND
                 G_APPROVER_LEVEL = 'L3'.
      G_APPROVER_LEVEL = 'IM'.
    ELSEIF  ZMM_PREP_ROLEGRP-APPROVER1 = 'L1' AND
                 ( G_APPROVER_LEVEL = 'L3' OR
                   G_APPROVER_LEVEL = 'IM' ).
      G_APPROVER_LEVEL = 'L1'.
    ENDIF.

**** CAB_AJIT Approval check added on 11/12/2006
    IF OLD_OK_CODE = 'APPROVE'.
      IF WA_ITEMTAB-REJ_FL = '' AND ZIC_PREP_ROLEREQ-CRC_FL <> 'X'.

        IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
          IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
             OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
             OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER
         """""""""""""""""""""""""""
           "added by lipsy for l2 approver on 20.03.2015 RD1K996555
            OR ( MODULEID = 'SRM' AND ZMM_PREP_ROLEGRP-APPROVER1 = G_USER_L2 )
             "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
          """""""""""""""""""""""""
            .
          ELSE.

            IF OKCODE_100 = 'SAV'.
              IF ERR_FLG <> 'X'.
                ERR_FLG = 'X'.
                CLEAR : SY-UCOMM, OKCODE_100.
              ENDIF.
              ROLLBACK WORK.
              MESSAGE I047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
              CLEAR OKCODE_100.
              CALL SCREEN 100.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.
***

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
FORM POPUP_RELEASE_MESSAGE.

  IF G_APPROVER_LEVEL = 'IM'.
    G_APPROVER_LEVEL = 'I/C MM'.
  ENDIF.

  """"""""""""""""""
  "added by lipsy for l2 approver on 20.03.2015 RD1K996555
  IF MODULEID = 'SRM' AND ZIC_PREP_ROLEREQ-DISC_MM_FLAG NE 'X'.

    """""""""""""""""""""""""""""
    "COMMENTED BY LIPSY ON 7.12.2015 RD1K999362
*  G_APPROVER_LEVEL = 'L2'.
    "END OF COMMENT BY LIPSY ON 7.12.2015 RD1K999362
    "ADDED BY LIPSY ON 7.12.2015  RD1K999362
    G_APPROVER_LEVEL = 'L3'.
    "END OF ADDITION BY LIPSY ON 7.12.2015 RD1K999362

  ENDIF.

  IF ( MODULEID = 'SRM' OR  MODULEID = 'MM' ) AND ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    G_APPROVER_LEVEL = 'I/C MM'.
  ENDIF.

  IF ( MODULEID = 'MM' ) AND ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X' AND  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    G_APPROVER_LEVEL = 'L3'.
  ENDIF.

  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
  """"""""""""""



  CONCATENATE 'Kindly get the request approved by competent authority: '
  G_APPROVER_LEVEL ' or above' INTO G_APPROVE_TEXT.


  """"""""""""""""""""""""""""""
  "added by lipsy for l2 approver on 20.03.2015 RD1K996555



*  IF  moduleid = 'SRM' OR  moduleid = 'MM' OR   moduleid = 'OLM'.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      TITEL     = 'Approval Requirement'
      TEXTLINE1 = G_APPROVE_TEXT
*     TEXTLINE2 = 'Request for authorization will be routed to ICE core team only '
*     TEXTLINE3 = 'after requisite approval '
*     START_COLUMN = 15
*     START_ROW = 6
    .

*  ELSE.
  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555


  """"""""""""""""""""""""""""""""""""""""

*    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
*      EXPORTING
*        titel     = 'Approval Requirement'
*        textline1 = g_approve_text
*        textline2 = 'Request for authorization will be routed to OVL core team only '
*        textline3 = 'after requisite approval '
**       START_COLUMN = 15
**       START_ROW = 6
*      .
*
*    """"""""""""""""""""""""""""""""""
*    "added by lipsy for l2 approver on 20.03.2015 RD1K996555
*
*  ENDIF.

  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
  """"""""""""""""""""""""""""""""""""""""""""""""
  CLEAR : G_APPROVER_LEVEL, G_APPROVE_TEXT.
ENDFORM.                    " popup_release_message
*&---------------------------------------------------------------------*
*&      Form  popup_approve_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_APPROVE_MESSAGE.
*  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
*    EXPORTING
*      titel     = 'Request Processing'
*      textline1 = 'The request will now be processed by OVL core  team & '
*      textline2 = 'user will get updated message once the request is processed '
**     START_COLUMN = 15
**     START_ROW = 6
*    .
ENDFORM.                    " popup_approve_message
*&---------------------------------------------------------------------*
*&      Form  verify2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VERIFY2.
  IF ZIC_PREP_ROLEREQ-STATUS <> 'C'.
**
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
      EXPORTING
        TITEL     = 'Request Status IR'
        TEXTLINE1 = 'Please go to display mode & reply the query of the OVL core team in '
        TEXTLINE2 = 'correspondence  &  save the request.  No re-release or approval reqd.'
        TEXTLINE3 = 'The request will go directly to ICE core team  for further processing.'.
    OLD_OK_CODE = 'DISPLAY'.
**
  ELSE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
      EXPORTING
        TITEL     = 'Request Status C'
        TEXTLINE1 = 'Request is closed, you can not change anything now'
        TEXTLINE2 = 'No more processing of the request can be done'.
    OLD_OK_CODE = 'DISPLAY'.
**
  ENDIF.
ENDFORM.                                                    " verify2
*&---------------------------------------------------------------------*
*&      Form  popup_release_message1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_RELEASE_MESSAGE1.
  IF G_APPROVER_LEVEL = 'IM'.
    G_APPROVER_LEVEL = 'I/C MM'.
  ENDIF.

  """"""
  "added by lipsy for l2 approver on 20.03.2015 RD1K996555
  IF MODULEID = 'SRM' AND ZIC_PREP_ROLEREQ-DISC_MM_FLAG NE 'X'.
    """""""""""""""""
    "COMMENTED BY LIPSY ON 7.12.2015 RD1K999362

*  G_APPROVER_LEVEL = 'L2'.

    "END OF COMMENT BY LIPSY ON 7.12.2015 RD1K999362


    "ADDED BY LIPSY ON 7.12.2015 RD1K999362
    G_APPROVER_LEVEL = 'L3'.
    "END OF ADDITION BY LIPSY ON 7.12.2015 RD1K999362

  ENDIF.

  IF ( MODULEID = 'SRM' OR  MODULEID = 'MM' ) AND ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    G_APPROVER_LEVEL = 'I/C MM'.
  ENDIF.

  IF ( MODULEID = 'MM' ) AND ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X' AND  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    G_APPROVER_LEVEL = 'L3'.
  ENDIF.

  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
  """""""""

*  CONCATENATE g_approver_level ' or above. Request  for  authorization will be routed to OVL core' INTO g_approve_text.


  """""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy for l2 approver on 20.03.2015 RD1K996555
*  IF  moduleid = 'SRM' OR  moduleid = 'MM' OR   moduleid = 'OLM'.
  CLEAR : G_APPROVE_TEXT.
  CONCATENATE G_APPROVER_LEVEL ' or above.' INTO G_APPROVE_TEXT.
*  ENDIF.



*  IF  moduleid = 'SRM' OR  moduleid = 'MM' OR   moduleid = 'OLM'.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      TITEL     = 'Approval Requirement'
      TEXTLINE1 = 'Kindly self release the  request  &  get it approved by competent authority:'
      TEXTLINE2 = G_APPROVE_TEXT
*     TEXTLINE3 = 'team only after requisite approval '
*     START_COLUMN = 15
*     START_ROW = 6
    .
*  ELSE.
  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
  """"""""""""""""""""""""""""""""""""""""""""""""""""

*    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
*      EXPORTING
*        titel     = 'Approval Requirement'
*        textline1 = 'Kindly self release the  request  &  get it approved by competent authority:'
*        textline2 = g_approve_text
*        textline3 = 'team only after requisite approval '
**       START_COLUMN = 15
**       START_ROW = 6
*      .
*
*    """"""""""""""""""""""""""""""""""
*    "added by lipsy for l2 approver on 20.03.2015 RD1K996555
*
*  ENDIF.

  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
  """"""""""""""""""""""""""""""""""""""""""""""""


  CLEAR : G_APPROVER_LEVEL, G_APPROVE_TEXT.
ENDFORM.                    " popup_release_message1
*&---------------------------------------------------------------------*
*&      Form  clear1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR1.

  CLEAR   : HELP_LIST_FLAG.
  REFRESH : IT_M_FISTB.
  CLEAR   : DYNNR.

ENDFORM.                                                    " clear1
*&---------------------------------------------------------------------*
*&      Form  insert_items_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_PM.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  SORT G_TABLCTRL111_ITAB
  BY ROLE_NAME PLANT SHOP_NO.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL111_ITAB
    COMPARING ROLE_NAME PLANT REJ_FL SHOP_NO.

  LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.

    MOVE-CORRESPONDING G_TABLCTRL111_WA TO WA_ITEMTAB.

*    Perform check_items_save.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_MODULE_WISE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM CHECK_ITEMS_SAVE_PM.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                                                WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC = 0.

      IF ZPM_PREP_ROLEDES-PLANT = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-PLANT IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE I084(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPM_PREP_ROLEDES-SHOP_NO = 'X' AND
                      ( OLD_OK_CODE = 'APPROVE' OR
                     OLD_OK_CODE = 'RELEASE' OR
                     OLD_OK_CODE = 'CHANGE' OR
                     OLD_OK_CODE = 'CREATE' OR
                     OLD_OK_CODE = 'CROSSCO' ) AND
                     NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-SHOP_NO IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          ROLLBACK WORK.
          MESSAGE I095(ZHELP) WITH G_I.
          CLEAR : OKCODE_100, SY-UCOMM.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ( ZIC_PREP_ROLEREQ-CCODE <> 'BDW' AND
         ZIC_PREP_ROLEREQ-CCODE <> 'SBW' ).

        IF  ( ZPM_PREP_ROLEDES-ROLE_TYPE = 'PM14' OR
            ZPM_PREP_ROLEDES-ROLE_TYPE = 'PM15' OR
            ZPM_PREP_ROLEDES-ROLE_TYPE = 'PM16' ).
          G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          ROLLBACK WORK.
          MESSAGE I164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
          ZIC_PREP_ROLEREQ-CCODE .
          CLEAR : OKCODE_100, SY-UCOMM.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF WA_ITEMTAB-ROLE_NAME = 'PM8'.
        IF WA_ITEMTAB-PLANT CS 'E1' OR
            WA_ITEMTAB-PLANT CS 'E2' OR
            WA_ITEMTAB-PLANT CS 'C1'.
        ELSE.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE I202(ZHELP) WITH WA_ITEMTAB-PLANT
          ZPM_PREP_ROLEDES-ROLE_TYPE.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.


    ENDIF.

  ENDIF.
*
**
  PERFORM VALIDATE_LINEITEM_DATAX11.

ENDFORM.                    " check_items_save_pm
*&---------------------------------------------------------------------*
*&      Form  check_module_wise
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MODULE_WISE.

  CASE MODULEID.

    WHEN 'MM'.

      PERFORM CHECK_ITEMS_SAVE.

    WHEN 'PM'.

      PERFORM CHECK_ITEMS_SAVE_PM.

    WHEN 'PS'.

      PERFORM CHECK_ITEMS_SAVE_PS.

    WHEN 'PP'.

      PERFORM CHECK_ITEMS_SAVE_PP.

    WHEN 'SD'.

      PERFORM CHECK_ITEMS_SAVE_SD.

    WHEN 'QM'.

      PERFORM CHECK_ITEMS_SAVE_QM.

    WHEN 'HSE'.

      PERFORM CHECK_ITEMS_SAVE_HS.


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
FORM VALIDATE_LINEITEM_DATAX11.

  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

* Begin of <RD1K981840>
*concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.
    CPF_LFB1 = ZIC_PREP_ROLEREQ-USERID.
* End of <RD1K981840>

**---------- Changes Start date 24.06.2016 12:01:35-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
              D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
              D~DISC_CD AS DISC_CD
                INTO CORRESPONDING FIELDS OF TABLE IST_DATA
           FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                 ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                    ON C~DESIGNO = D~DESIG_CODE AND
                        C~R_P_CD  = D~R_P_CD AND
                        C~VERSION = D~VERSION )
                     WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                           A~SPRPS = ' ' AND
                           A~ENDDA = '99991231' AND
                           C~SPRPS = ' ' AND
                           C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 12:01:35-----------------

    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1. "#EC CI_NOORDER
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.

**********************************************************

    IF OLD_OK_CODE <> 'DISPLAY'.

      IF NOT G_TABLCTRL111_WA-PLANT IS INITIAL.

        SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                   TABLE IT_BUKRS  WHERE BUKRS = ZIC_PREP_ROLEREQ-CCODE
                                      AND WERKS = G_TABLCTRL111_WA-PLANT.
        IF SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE E068(ZHELP) WITH G_TABLCTRL111_WA-ROLE_NAME.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax11
*&---------------------------------------------------------------------*
*&      Form  crc_module_checking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CRC_MODULE_CHECKING.
  IF OLD_OK_CODE = 'CRCROLES' OR ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    MODULEID = 'MM'.
  ENDIF.
ENDFORM.                    " crc_module_checking
*&---------------------------------------------------------------------*
*&      Form  check_module_status_mm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MODULE_STATUS_MM.
  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    MM_NOT_OK = 'X'.
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
FORM CHECK_MODULE_STATUS_PM.
  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    PM_NOT_OK = 'X'.
  ENDIF.
ENDFORM.                    " check_module_status_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_app
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_APP.
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

  DATA : L_GET7(1) TYPE C.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION         = 'Are you sure, you want to approve the Document? '
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = L_GET7
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC = 0.
    CASE L_GET7.
      WHEN '1'.
        MOVE 'J' TO G_CHOICE_APP.
      WHEN '2'.
        MOVE 'N' TO G_CHOICE_APP.
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
FORM INSERT_ITEMS_PS.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB, I.

  SORT G_TABLCTRL112_ITAB
  BY ROLE_NAME SERVICE PROJECT LOCATION ASSET BASIN.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL112_ITAB
    COMPARING ROLE_NAME REJ_FL SERVICE PROJECT LOCATION
    ASSET BASIN.

  LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.

    MOVE-CORRESPONDING G_TABLCTRL112_WA TO WA_ITEMTAB.

*    Perform check_items_save.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_MODULE_WISE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM CHECK_ITEMS_SAVE_PS.

  IF NOT ZIC_PREP_ROLEREI-SERVICE IS INITIAL AND
        ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    MESSAGE E185(ZHELP).
  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                                                WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC = 0.

      IF ZPS_PREP_ROLEDES-SERVICE = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-SERVICE IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.
          ROLLBACK WORK.
          MESSAGE I174(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPS_PREP_ROLEDES-PROJECT = 'X' AND
                      ( OLD_OK_CODE = 'APPROVE' OR
                     OLD_OK_CODE = 'RELEASE' OR
                     OLD_OK_CODE = 'CHANGE' OR
                     OLD_OK_CODE = 'CREATE' OR
                     OLD_OK_CODE = 'CROSSCO' ) AND
                     NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-PROJECT IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-PROJECT'.
          ROLLBACK WORK.
          MESSAGE I175(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPS_PREP_ROLEDES-LOCATION = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-LOCATION IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-LOCATION'.
          ROLLBACK WORK.
          MESSAGE I176(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPS_PREP_ROLEDES-ASSET = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-ASSET IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
          ROLLBACK WORK.
          MESSAGE I177(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPS_PREP_ROLEDES-BASIN = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-BASIN IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-BASIN'.
          ROLLBACK WORK.
          MESSAGE I178(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

*****
    ENDIF.

  ENDIF.
*
**
  PERFORM VALIDATE_LINEITEM_DATAX12.

ENDFORM.                    " check_items_save_ps
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_LINEITEM_DATAX12.

  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.


*concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.
    CPF_LFB1 = ZIC_PREP_ROLEREQ-USERID.

**---------- Changes Start date 24.06.2016 12:01:02-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

**---------- Changee  Ending Date 24.06.2016 12:01:02-----------------
    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.

**********************************************************

    IF OLD_OK_CODE <> 'DISPLAY'.

      IF NOT G_TABLCTRL112_WA-SERVICE IS INITIAL.

        SELECT SINGLE * FROM ZPS_PREP_SERVICE
                WHERE SERVICE = G_TABLCTRL112_WA-SERVICE.

        IF SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.
          ROLLBACK WORK.
          MESSAGE E179(ZHELP) WITH G_TABLCTRL112_WA-ROLE_NAME.

        ENDIF.

      ENDIF.

      IF NOT G_TABLCTRL112_WA-PROJECT IS INITIAL.

        SELECT SINGLE * FROM ZPS_PREP_PROJECT
             WHERE SERVICE = G_TABLCTRL112_WA-SERVICE AND
             PROJECT = G_TABLCTRL112_WA-PROJECT.

        IF SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-PROJECT'.
          ROLLBACK WORK.
          MESSAGE E180(ZHELP) WITH G_TABLCTRL112_WA-ROLE_NAME.

        ENDIF.

      ENDIF.

      IF NOT G_TABLCTRL112_WA-LOCATION IS INITIAL.

        SELECT SINGLE * FROM ZPS_PREP_LOCA
             WHERE CCODE = ZIC_PREP_ROLEREQ-CCODE AND
                   LOCATION = G_TABLCTRL112_WA-LOCATION AND
                   SERVICE = G_TABLCTRL112_WA-SERVICE.

        IF SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-LOCATION'.
          ROLLBACK WORK.
          G_I = G_CURR_LINE.
          MESSAGE E181(ZHELP) WITH G_TABLCTRL112_WA-ROLE_NAME.
        ENDIF.

      ENDIF.

      IF NOT G_TABLCTRL112_WA-BASIN IS INITIAL.

        IF G_TABLCTRL112_WA-BASIN <> ZIC_PREP_ROLEREQ-CCODE AND
               G_TABLCTRL112_WA-BASIN <> 'ALL'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-BASIN'.
          ROLLBACK WORK.
          MESSAGE E181(ZHELP) WITH G_TABLCTRL112_WA-ROLE_NAME.

        ENDIF.

      ENDIF.


      IF NOT G_TABLCTRL112_WA-ASSET IS INITIAL.

        IF ZIC_PREP_ROLEREQ-CCODE = 'MUM'.

          IF G_TABLCTRL112_WA-ASSET <> 'ALL'.
            SELECT SINGLE * FROM ZPS_PREP_ASST_EX
                   WHERE CCODE = ZIC_PREP_ROLEREQ-CCODE AND
                     ASSET = G_TABLCTRL112_WA-ASSET.
          ENDIF.
          IF SY-SUBRC <> 0 AND ZPS_PREP_ASST_EX-ASSET <> 'ALL'.
            G_E_FL = 'X'.
            G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
            ROLLBACK WORK.
            MESSAGE E182(ZHELP) WITH G_TABLCTRL112_WA-ROLE_NAME.

          ENDIF.

        ELSE.

          IF G_TABLCTRL112_WA-ASSET <> ZIC_PREP_ROLEREQ-CCODE AND
              G_TABLCTRL112_WA-ASSET <> 'ALL'.
            G_E_FL = 'X'.
            G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
            ROLLBACK WORK.
            MESSAGE E182(ZHELP) WITH G_TABLCTRL112_WA-ROLE_NAME.

          ENDIF.
        ENDIF.
      ENDIF.
************
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
FORM CHECK_MODULE_STATUS_PS.
  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    PS_NOT_OK = 'X'.
  ENDIF.
ENDFORM.                    " check_module_status_ps
*&---------------------------------------------------------------------*
*&      Form  clear_for_newmodule
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_FOR_NEWMODULE.

  PERFORM DESTROY_CTRL.

  CLEAR   : OKCODE_100, ERR_FLG.
  REFRESH : G_TABLCTRL110_ITAB[].
  CLEAR   : G_TABLCTRL110_ITAB.
  REFRESH : G_TABLCTRL111_ITAB[].
  CLEAR   : G_TABLCTRL111_ITAB.
  REFRESH : G_TABLCTRL112_ITAB[].
  CLEAR   : G_TABLCTRL112_ITAB.
  CLEAR   : SY-UCOMM.
  CLEAR   : G_CURR_LINE.
  CLEAR SET_DISC_MM_FLAG.
  CLEAR SET_DISC_FI_FLAG.
  CLEAR   : ZIC_PREP_ROLEREI.
  CLEAR   : IT_TAB.
  REFRESH : TLINETAB1[],TLINETAB2[].
  CLEAR   : T500P-NAME1.
  CLEAR   : CRC_CHECK_FL.
  CLEAR   : HELP_LIST_FLAG.
  REFRESH : IT_M_FISTB.
  CLEAR   : G_HD_COPIED.


  """""""""""""""""""
  "added by lipsy for clear on 20.03.2015 RD1K996555
  REFRESH : G_TABLCTRL118_ITAB[].
  CLEAR   : G_TABLCTRL118_ITAB.

  "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555

  """"""""""""""""""

ENDFORM.                    " clear_for_newmodule
*&---------------------------------------------------------------------*
*&      Form  insert_items_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_PP.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB, I.

  SORT G_TABLCTRL113_ITAB
  BY ROLE_NAME PLANT SLOC RES CTF_SLOC.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL113_ITAB
    COMPARING ROLE_NAME REJ_FL PLANT SLOC RES
    CTF_SLOC.

  LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.

    MOVE-CORRESPONDING G_TABLCTRL113_WA TO WA_ITEMTAB.

*    Perform check_items_save.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_MODULE_WISE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM CHECK_ITEMS_SAVE_PP.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                                                WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC = 0.

      IF ZPP_PREP_ROLEDES-PLANT = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-PLANT IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE I074(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPP_PREP_ROLEDES-SLOC = 'X' AND
                      ( OLD_OK_CODE = 'APPROVE' OR
                     OLD_OK_CODE = 'RELEASE' OR
                     OLD_OK_CODE = 'CHANGE' OR
                     OLD_OK_CODE = 'CREATE' OR
                     OLD_OK_CODE = 'CROSSCO' ) AND
                     NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-SLOC IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
          ROLLBACK WORK.
          MESSAGE I090(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPP_PREP_ROLEDES-RES = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-RES IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-RES'.
          ROLLBACK WORK.
          MESSAGE I184(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZPP_PREP_ROLEDES-CTF_SLOC = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-CTF_SLOC IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
          ROLLBACK WORK.
          MESSAGE I090(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

*****
    ENDIF.

  ENDIF.
*
**
  PERFORM VALIDATE_LINEITEM_DATAX13.


ENDFORM.                    " check_items_save_pp
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MODULE_STATUS_PP.

  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    PP_NOT_OK = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_SD.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB, I.

  SORT G_TABLCTRL114_ITAB
  BY ROLE_NAME SALE_ORG DIV PLANT SHIP_POINT.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL114_ITAB
    COMPARING ROLE_NAME REJ_FL SALE_ORG DIV PLANT SHIP_POINT.

  LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.

    CLEAR WA_ITEMTAB.

    MOVE-CORRESPONDING G_TABLCTRL114_WA TO WA_ITEMTAB.

*    Perform check_items_save.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_MODULE_WISE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM CHECK_ITEMS_SAVE_SD.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                                                WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC = 0.

      IF ZSD_PREP_ROLEDES-PLANT = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-PLANT IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE I074(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZSD_PREP_ROLEDES-SALE_ORG = 'X' AND
                      ( OLD_OK_CODE = 'APPROVE' OR
                     OLD_OK_CODE = 'RELEASE' OR
                     OLD_OK_CODE = 'CHANGE' OR
                     OLD_OK_CODE = 'CREATE' OR
                     OLD_OK_CODE = 'CROSSCO' ) AND
                     NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-SALE_ORG IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          ROLLBACK WORK.
          MESSAGE I190(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZSD_PREP_ROLEDES-DIV = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-DIV IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-DIV'.
          ROLLBACK WORK.
          MESSAGE I194(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ZSD_PREP_ROLEDES-SHIP_POINT = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-SHIP_POINT IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          ROLLBACK WORK.
          MESSAGE I191(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

*****
    ENDIF.

  ENDIF.
*
**
  PERFORM VALIDATE_LINEITEM_DATAX14.


ENDFORM.                    " check_items_save_sd
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax13
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_LINEITEM_DATAX13.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.
**---------- Changes Start date 24.06.2016 12:00:31-------------------


*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .
*


    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 12:00:31-----------------

    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.

**********************************************************

    IF OLD_OK_CODE <> 'DISPLAY'.


      IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

        SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                      TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                         AND WERKS = ZIC_PREP_ROLEREI-PLANT.
        IF SY-SUBRC = 0.

          SELECT SINGLE * FROM ZHELP_PPROLES1 INTO CORRESPONDING FIELDS OF
                               ZHELP_PPROLES1 WHERE
                               ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME AND
                               PLANT     = ZIC_PREP_ROLEREI-PLANT.

          IF SY-SUBRC <> 0.

            SELECT SINGLE * FROM ZPP_PREP_GENERIC INTO CORRESPONDING FIELDS OF
                                 ZPP_PREP_GENERIC WHERE
                                 ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME AND
                                 PLANT     = ZIC_PREP_ROLEREI-PLANT.

            IF SY-SUBRC <> 0.
              G_E_FL = 'X'.
              G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
              G_I = G_CURR_LINE_113.
              ROLLBACK WORK.
              MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
            ENDIF.

          ENDIF.

        ELSE.
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
          G_I = G_CURR_LINE_113.
          ROLLBACK WORK.
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
          G_I = G_CURR_LINE_113.
          ROLLBACK WORK.
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
          ROLLBACK WORK.
          MESSAGE E073(ZHELP) WITH ZIC_PREP_ROLEREI-CTF_SLOC.

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
FORM CHECK_MODULE_STATUS_SD.

  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    SD_NOT_OK = 'X'.
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
FORM VALIDATE_LINEITEM_DATAX14.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

**---------- Changes Start date 24.06.2016 11:59:59-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .
*

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:59:59-----------------

    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.

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
        ELSEIF ZIC_PREP_ROLEREQ-CCODE = 'MUM' AND
* 18092015
              ( ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' OR ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPSP') AND
*                ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' AND
* 18092015
                ZIC_PREP_ROLEREI-SALE_ORG <> 'HZRS'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          G_I = G_CURR_LINE_114.
          MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
        ELSE.
          IF ZIC_PREP_ROLEREQ-CCODE = 'MUM' AND
*          ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPOP' AND
            ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPOP' AND
            ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPSP' AND       "18092015
          ZIC_PREP_ROLEREI-SALE_ORG = 'HZRS'.
            G_E_FL = 'X'.
            G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            G_I = G_CURR_LINE_114.
            MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
          ENDIF.
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

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax14
*&---------------------------------------------------------------------*
*&      Form  insert_items_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_QM.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB, I.

  SORT G_TABLCTRL115_ITAB
  BY ROLE_NAME PLANT ASSET_QM.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL115_ITAB
    COMPARING ROLE_NAME REJ_FL PLANT ASSET_QM.

  LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.

    MOVE-CORRESPONDING G_TABLCTRL115_WA TO WA_ITEMTAB.

*    Perform check_items_save.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_MODULE_WISE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM CHECK_ITEMS_SAVE_QM.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZQM_PREP_ROLEDES WHERE ROLE_TYPE =
                                                WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC = 0.

      IF ZQM_PREP_ROLEDES-PLANT = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE' OR
                    OLD_OK_CODE = 'CREATE' OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-PLANT IS INITIAL AND
              ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE I084(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.
*
**
  PERFORM VALIDATE_LINEITEM_DATAX15.

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
    EXPORTING
      CLIENT   = SY-MANDT
      GROUP    = SY-UNAME
      USER     = SY-UNAME
      KEEP     = ''
      HOLDDATE = SY-DATUM.

ENDFORM.                    "OPEN_GROUP

*----------------------------------------------------------------------*
*   end batchinput session                                             *
*   (call transaction using...: error session)                         *
*----------------------------------------------------------------------*
FORM CLOSE_GROUP.
  CALL FUNCTION 'BDC_CLOSE_GROUP'.
ENDFORM.                    "CLOSE_GROUP
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
ENDFORM.                    "BDC_FIELD
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO
**********************************************************************
*&---------------------------------------------------------------------*
*&      Form  call_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_FI.

  SET PARAMETER ID 'ZOLDCODE_FI' FIELD OLD_OK_CODE.

  SET PARAMETER ID 'ZMODULEID_FI' FIELD 'FI'.

  SET PARAMETER ID 'ZUSERID_FI' FIELD ZIC_PREP_ROLEREQ-USERID.

  SET PARAMETER ID 'ZRSN_CODE_FI' FIELD ZIC_PREP_ROLEREQ-RSN_CODE.

  SET PARAMETER ID 'ZTELNO_FI' FIELD ZIC_PREP_ROLEREQ-TELNO.

  SET PARAMETER ID 'ZDOCNO_FI' FIELD ZIC_PREP_ROLEREQ-DOCNO.

  DYNNR = '0101'.
*****************************************@
  IF OLD_OK_CODE = 'APPROVE'.

    CLEAR OLD_OK_CODE.
*    PERFORM clear.
    SET PARAMETER ID 'ZOLDCODE_FI' FIELD 'APPROVE'.
    SET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
    LEAVE TO TRANSACTION 'ZIC_AUTH_FI_REP' .

  ELSE.

    CLEAR OLD_OK_CODE.
    PERFORM CLEAR.

    CALL TRANSACTION 'ZIC_AUTH_FI' .
  ENDIF.

ENDFORM. "call_fi
*&---------------------------------------------------------------------*
*&      Form  check_module_status_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MODULE_STATUS_QM.
  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    QM_NOT_OK = 'X'.
  ENDIF.
ENDFORM.                    " check_module_status_qm
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax15
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_LINEITEM_DATAX15.

  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

*concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.
    CPF_LFB1 = ZIC_PREP_ROLEREQ-USERID.

**---------- Changes Start date 24.06.2016 11:59:30-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
              D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
              D~DISC_CD AS DISC_CD
                INTO CORRESPONDING FIELDS OF TABLE IST_DATA
           FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                 ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                    ON C~DESIGNO = D~DESIG_CODE AND
                        C~R_P_CD  = D~R_P_CD AND
                        C~VERSION = D~VERSION )
                     WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                           A~SPRPS = ' ' AND
                           A~ENDDA = '99991231' AND
                           C~SPRPS = ' ' AND
                           C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:59:30-----------------

    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.

**********************************************************

    IF OLD_OK_CODE <> 'DISPLAY'.

      IF NOT G_TABLCTRL115_WA-PLANT IS INITIAL.

        SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                   TABLE IT_BUKRS  WHERE BUKRS = ZIC_PREP_ROLEREQ-CCODE
                                      AND WERKS = G_TABLCTRL115_WA-PLANT.
        IF SY-SUBRC <> 0.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE E068(ZHELP) WITH G_TABLCTRL115_WA-ROLE_NAME.
        ENDIF.

      ENDIF.

      IF NOT ZIC_PREP_ROLEREI-ASSET_QM IS INITIAL.

        IF ZIC_PREP_ROLEREQ-CCODE = 'MUM' OR ZIC_PREP_ROLEREQ-CCODE = 'KKL'.

          SELECT SINGLE * FROM ZQM_PREP_ASSET INTO ZQM_PREP_ASSET WHERE
                          CCODE =  ZIC_PREP_ROLEREQ-CCODE AND
                          ASSET =  ZIC_PREP_ROLEREI-ASSET_QM.
          IF SY-SUBRC <> 0.
            G_E_FL = 'X'.
            G_FIELD = 'ZIC_PREP_ROLEREI-ASSET_QM'.
            G_I = G_CURR_LINE.
            MESSAGE E172(ZHELP) WITH ZIC_PREP_ROLEREI-ASSET_QM.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax15
*&---------------------------------------------------------------------*
*&      Form  confirm_more
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_MORE.
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
  DATA : L_GET8(1) TYPE C.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'ATTACH MORE '
      TEXT_QUESTION         = 'Do you want to attach more files?'
      DEFAULT_BUTTON        = ' '
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = L_GET8
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC = 0.
    CASE L_GET8.
      WHEN '1'.
        MOVE 'J' TO G_CHOICE_MORE.
      WHEN '2'.
        MOVE 'N' TO G_CHOICE_MORE.
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
FORM CHECK_MODULE_FI.

  IF ( OLD_OK_CODE = 'CHANGE' OR
  OLD_OK_CODE = 'DISPLAY' ) AND MODULEID = 'FI'.
    SELECT SINGLE * FROM ZIC_PREP_ROLEREI INTO
                    CORRESPONDING FIELDS OF WA_MODULE1 WHERE
                    DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
                    MODULEID = 'FI'.
    IF SY-SUBRC <> 0 AND ZIC_PREP_ROLEREQ-DELIMIT <> 'X'.
      IF OLD_OK_CODE = 'CHANGE'.
        MESSAGE E196(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ELSE.
        MESSAGE E198(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_module_fi
*&---------------------------------------------------------------------*
*&      Form  confirm_rel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_REL.
  " Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Roles created for all modules will be released?? '
*              TEXTLINE2      = 'Are you sure, you want to release the Document? '
*
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = g_choice_rel.

  DATA : L_GET9(1) TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION         = 'Roles created for all modules will be released?? '
                              & 'Are you sure, you want to release the Document? '
      DISPLAY_CANCEL_BUTTON = ' '
      START_COLUMN          = 25
      START_ROW             = 6
    IMPORTING
      ANSWER                = L_GET9
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC = 0.
    CASE L_GET9.
      WHEN '1'.
        MOVE 'J' TO G_CHOICE_REL.
      WHEN '2'.
        MOVE 'N' TO G_CHOICE_REL.
    ENDCASE.
  ENDIF.
  " End of <RD1K960036>.

ENDFORM.                    " confirm_rel
*&---------------------------------------------------------------------*
*&      Form  list_help_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_HELP_FILES.

  CLEAR G_ATT_FILES_WA.

  G_ATT_FILES_WA-LOGSYS = 'ARMSHELP'.
  G_ATT_FILES_WA-OBJTYPE = 'HLP'.
  G_ATT_FILES_WA-OBJKEY = '01'.

  REFRESH EXCLUDE_TAB[].

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
      APPLICATION_OBJECT = G_ATT_FILES_WA
*     FUNCTION           = ' '
    TABLES
      FUNC_EXCLUDE       = EXCLUDE_TAB.

ENDFORM.                    " list_help_files
*&---------------------------------------------------------------------*
*&      Form  check_module_status_hse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MODULE_STATUS_HSE.

  IF WA_ITEM-REJ_FL = '' AND WA_ITEM-ROLE_REQUEST <> ''.
  ELSEIF WA_ITEM-REJ_FL <> '' AND WA_ITEM-ROLE_REQUEST = ''.
  ELSE.
    HS_NOT_OK = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_hse
*&---------------------------------------------------------------------*
*&      Form  insert_items_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_HS.

  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  SORT G_TABLCTRL116_ITAB
  BY ROLE_NAME.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL116_ITAB
    COMPARING ROLE_NAME REJ_FL.

  LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA.

    MOVE-CORRESPONDING G_TABLCTRL116_WA TO WA_ITEMTAB.

*    Perform check_items_save.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    PERFORM CHECK_MODULE_WISE.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

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
FORM CHECK_ITEMS_SAVE_HS.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                                                WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC <> 0.

      MESSAGE E102(ZHELP) WITH ZHS_PREP_ROLEDES-ROLE_TYPE.

    ENDIF.

  ENDIF.
*
**
  PERFORM VALIDATE_LINEITEM_DATAX16.

ENDFORM.                    " check_items_save_hs
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax16
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_LINEITEM_DATAX16.

  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

*concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.
    CPF_LFB1 = ZIC_PREP_ROLEREQ-USERID.

**---------- Changes Start date 24.06.2016 11:59:02-------------------

*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:59:02-----------------

    IF SY-SUBRC = 0.
      READ TABLE IST_DATA INDEX 1.  "#EC CI_NOORDER
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA.

**********************************************************

    IF OLD_OK_CODE <> 'DISPLAY'.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax16
*&---------------------------------------------------------------------*
*&      Form  message1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MESSAGE1.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL     = 'CRC Authorisations '
      TEXTLINE1 = 'The desired roles for the position are already available with you.'
      TEXTLINE2 = 'In case of any new roles please create normal request.'.
ENDFORM.                                                    " message1
*&---------------------------------------------------------------------*
*&      Form  message2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MESSAGE2.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL     = 'CRC Authorisations '
      TEXTLINE1 = 'Your position has not been updated.Please get your position updated by'
      TEXTLINE2 = 'local HR so that the requisite roles with position will be available  to you.'.

ENDFORM.                                                    " message2


*&---------------------------------------------------------------------*
*&      Form  call_hr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_HR.

* SET PARAMETER ID 'ZOLDCODE_FI' field old_ok_code.

  SET PARAMETER ID 'ZMODULEID_HR' FIELD 'HR'.

  SET PARAMETER ID 'ZUSERID_HR' FIELD ZIC_PREP_ROLEREQ-USERID.

  SET PARAMETER ID 'ZRSN_CODE_HR' FIELD ZIC_PREP_ROLEREQ-RSN_CODE.

  SET PARAMETER ID 'ZTELNO_HR' FIELD ZIC_PREP_ROLEREQ-TELNO.

* SET PARAMETER ID 'ZDOCNO_FI' field ZIC_PREP_ROLEREQ-DOCNO.

  DYNNR = '0101'.

  CLEAR OLD_OK_CODE.

  PERFORM CLEAR.

  CALL TRANSACTION 'ZHRARMS' .

  LEAVE PROGRAM.

ENDFORM. "call_hr
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_OLM .
  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  SORT G_TC_117_ITAB
  BY ROLE_NAME.

  DELETE ADJACENT DUPLICATES FROM G_TC_117_ITAB
    COMPARING ROLE_NAME.

  LOOP AT G_TC_117_ITAB INTO G_TC_117_WA.

    MOVE-CORRESPONDING G_TC_117_WA TO WA_ITEMTAB.

    IF OLD_OK_CODE = 'CREATE' OR
      OLD_OK_CODE = 'CROSSCO' OR
      OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.
  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID.
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.
    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_OLM
*&---------------------------------------------------------------------*
*&      Form  POPUP_RELEASE_MESSAGE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_RELEASE_MESSAGE2 .
  IF G_APPROVER_LEVEL = 'IM'.
    G_APPROVER_LEVEL = 'I/C MM'.
  ENDIF.

  """""""""""""""
  "comment by lipsy on 24.03.2015 RD1K996555
*  CONCATENATE G_APPROVER_LEVEL ' or L4. Request  for  authorization will be routed to ICE core' INTO G_APPROVE_TEXT.

  "end of comment by lipsy on 24.03.2015 RD1K996555
  """"""""""""""


  """""""""""""""
  "added by lipsy on 24.03.2015 RD1K996555

  CONCATENATE G_APPROVER_LEVEL ' or L4.' INTO G_APPROVE_TEXT.

  "end of addition by lipsy on 24.03.2015 RD1K996555
  """"""""""""""

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      TITEL     = 'Approval Requirement'
      TEXTLINE1 = 'Kindly self release the  request  &  get it approved by competent authority:'
      TEXTLINE2 = G_APPROVE_TEXT
      """""""""""""""""""""""""""""
      "comment by lipsy on 24.03.2015 RD1K996555
*     TEXTLINE3 = 'team only after requisite approval '
      "end of comment by lipsy on 24.03.2015 RD1K996555
      """"""""""""""""""""""""""""""""""""""""""
*     START_COLUMN = 15
*     START_ROW = 6
    .
  CLEAR : G_APPROVER_LEVEL, G_APPROVE_TEXT.
ENDFORM.                    " POPUP_RELEASE_MESSAGE2
*&---------------------------------------------------------------------*
*&      Form  POPUP_RELEASE_MESSAGE3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_RELEASE_MESSAGE3 .
  IF G_APPROVER_LEVEL = 'IM'.
    G_APPROVER_LEVEL = 'I/C MM'.
  ENDIF.


  CONCATENATE 'Kindly get the request approved by competent authority: '
  G_APPROVER_LEVEL ' or L4' INTO G_APPROVE_TEXT.


  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      TITEL     = 'Approval Requirement'
      TEXTLINE1 = G_APPROVE_TEXT
      """"""""""""""""""""""""""""""""""""""
      "commented by lipsy on 24.03.2015 RD1K996555
*     TEXTLINE2 = 'Request for authorization will be routed to ICE core team only '
*     TEXTLINE3 = 'after requisite approval '
      "end of comment by lipsy on 24.03.2015 RD1K996555
      """""""""""""""""""""""""""""""""""""""""""""""
*     START_COLUMN = 15
*     START_ROW = 6
    .
  CLEAR : G_APPROVER_LEVEL, G_APPROVE_TEXT.
ENDFORM.                    " POPUP_RELEASE_MESSAGE3
*&---------------------------------------------------------------------*
*&      Form  GRC_RISK_ANALYSIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GRC_RISK_ANALYSIS .

  IF OLD_OK_CODE = 'APPROVE'.
    CHECK_OKCODE = 'A'.
  ELSEIF OLD_OK_CODE = 'CREATE'.
    CHECK_OKCODE = 'C'.
  ELSEIF OLD_OK_CODE = 'CHANGE'.
    CHECK_OKCODE = 'M'.
  ENDIF.
  CLEAR GT_BUK_ROLE.
  CLEAR GT_FINAL_TB.
  CLEAR GT_VIOL_DTL.
  CLEAR GT_BUCKET.
  CLEAR GT_BUCKET1.
  CLEAR GT_EROLES.
  CLEAR GT_EROLES1.
  CLEAR GT_USERINFO.
  CLEAR GT_OUTPUT.
  CLEAR GT_VIOLDTL.
  CLEAR : GT_RDESC, GT_CRMODULE.
  IMPORT  REQNUM_EX FROM MEMORY ID 'REQNUM_IM'.
******************* DELETING PRIVIOUS RISK ANALYSIS**************************

  DELETE FROM ZGRC_SOD_RESULT WHERE DOCNO = REQNUM_EX.
  DELETE FROM ZGRC_VIOL_DTL WHERE DOCNO = REQNUM_EX.
  COMMIT WORK AND WAIT.
******************* DELETING PRIVIOUS RISK ANALYSIS**************************

  IF MODULEID = 'MM'.
    LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.

      MOVE-CORRESPONDING G_TABLCTRL110_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.
  ELSEIF MODULEID = 'SD'.
    LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.

      MOVE-CORRESPONDING G_TABLCTRL114_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.
  ELSEIF MODULEID = 'PP'.
    LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.

      MOVE-CORRESPONDING G_TABLCTRL113_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.

  ELSEIF MODULEID = 'PM'.
    LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.

      MOVE-CORRESPONDING G_TABLCTRL111_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.

  ELSEIF MODULEID = 'PS'.
    LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.

      MOVE-CORRESPONDING G_TABLCTRL112_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.

  ELSEIF MODULEID = 'HSE'.
    LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA.

      MOVE-CORRESPONDING G_TABLCTRL116_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.


  ELSEIF MODULEID = 'QM'.
    LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.

      MOVE-CORRESPONDING G_TABLCTRL115_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.

  ELSEIF MODULEID = 'OLM'.
    LOOP AT G_TC_117_ITAB INTO G_TC_117_WA .

      MOVE-CORRESPONDING G_TC_117_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""
    "added by lipsy  for srm module introduction ON 3.03.2015 RD1K996555
  ELSEIF MODULEID = 'SRM'.
    LOOP AT G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA.

      MOVE-CORRESPONDING G_TABLCTRL118_WA TO WA_BUCKET.
      WA_BUCKET-DOCNO = REQNUM_EX.
      APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
    ENDLOOP.

    "end of addition by lipsy  for srm module introduction ON 3.03.2015 RD1K996555
    """""""""""""""""""""""""""""""""""""""""""""""""


  ENDIF.


  DELETE GT_BUCKET WHERE REJ_FL = 'H'.

  SELECT * FROM ZIC_PREP_ROLEREI INTO CORRESPONDING FIELDS OF TABLE GT_CRMODULE WHERE
    DOCNO = REQNUM_EX AND MODULEID NE  MODULEID.

  IF SY-SUBRC EQ 0.

    LOOP AT GT_CRMODULE INTO WA_CRMODULE .
      MOVE-CORRESPONDING WA_CRMODULE TO WA_BUCKET.
      APPEND  WA_BUCKET TO GT_BUCKET.
    ENDLOOP.
    CLEAR WA_CRMODULE.

  ENDIF.

  LOOP AT GT_BUCKET INTO WA_BUCKET.

    MOVE-CORRESPONDING WA_BUCKET TO WA_BUCKET1.
    APPEND  WA_BUCKET1 TO GT_BUCKET1.



    CALL FUNCTION 'ZGRC_DEV_FM'
      EXPORTING
        T_TBTC    = GT_BUCKET1
        REQ_NUM   = WA_BUCKET-DOCNO
      IMPORTING
        IT_ROLES2 = GT_EROLES.

*CLEAR WA_BUCKET1.
    LOOP AT  GT_EROLES INTO WA_EROLES.

      MOVE-CORRESPONDING WA_EROLES TO WA_EROLES1.
      APPEND WA_EROLES1 TO  GT_EROLES1.

    ENDLOOP.
  ENDLOOP.

  LOOP AT GT_BUCKET1 INTO WA_BUCKET1.
    WA_BUK_ROLE-DOCNO	=	WA_BUCKET1-DOCNO.
    WA_BUK_ROLE-MODULEID  = WA_BUCKET1-MODULEID.
    WA_BUK_ROLE-SRNO  = WA_BUCKET1-SRNO.
    WA_BUK_ROLE-ROLE_NAME	=	WA_BUCKET1-ROLE_NAME.
    WA_BUK_ROLE-PLANT = WA_BUCKET1-PLANT .
    WA_BUK_ROLE-GRP = WA_BUCKET1-GRP .
    WA_BUK_ROLE-SLOC  = WA_BUCKET1-SLOC  .
    WA_BUK_ROLE-RECEIPT_LOC = WA_BUCKET1-RECEIPT_LOC .
    WA_BUK_ROLE-APPROVER  = WA_BUCKET1-APPROVER  .
    WA_BUK_ROLE-STATUS  = WA_BUCKET1-STATUS  .
    WA_BUK_ROLE-ROLE_REQUEST  = WA_BUCKET1-ROLE_REQUEST.
    WA_BUK_ROLE-REJ_FL  = WA_BUCKET1-REJ_FL  .
    WA_BUK_ROLE-REJ_ID  = WA_BUCKET1-REJ_ID  .
    WA_BUK_ROLE-REJ_DATE  = WA_BUCKET1-REJ_DATE  .
    WA_BUK_ROLE-REJ_FL_SAVE = WA_BUCKET1-REJ_FL_SAVE .
    WA_BUK_ROLE-SHOP_NO = WA_BUCKET1-SHOP_NO .
    WA_BUK_ROLE-ROLE_DESC = WA_BUCKET1-ROLE_DESC .
    WA_BUK_ROLE-FLAG  = WA_BUCKET1-FLAG  .
    WA_BUK_ROLE-GL_ACCOUNT  = WA_BUCKET1-GL_ACCOUNT  .
    WA_BUK_ROLE-BUSSINESS_AREA  = WA_BUCKET1-BUSSINESS_AREA  .
    WA_BUK_ROLE-FUND_CTR_GP = WA_BUCKET1-FUND_CTR_GP .
    WA_BUK_ROLE-JVA_GRP = WA_BUCKET1-JVA_GRP .
    WA_BUK_ROLE-SUB_MODULE  = WA_BUCKET1-SUB_MODULE.
    WA_BUK_ROLE-ROLE_SENSITIVITY  = WA_BUCKET1-ROLE_SENSITIVITY  .
    WA_BUK_ROLE-FR_DATE_AUTH  = WA_BUCKET1-FR_DATE_AUTH  .
    WA_BUK_ROLE-TO_DATE_AUTH  = WA_BUCKET1-TO_DATE_AUTH.
    WA_BUK_ROLE-ROLE_TYPE_EX  = WA_BUCKET-ROLE_TYPE_EX  .
    WA_BUK_ROLE-SALE_ORG  = WA_BUCKET1-SALE_ORG  .
    WA_BUK_ROLE-DIV = WA_BUCKET1-DIV .
    WA_BUK_ROLE-SHIP_POINT  = WA_BUCKET1-SHIP_POINT  .
    WA_BUK_ROLE-ASSET = WA_BUCKET1-ASSET .
    WA_BUK_ROLE-BASIN = WA_BUCKET1-BASIN .
    WA_BUK_ROLE-PROJECT = WA_BUCKET1-PROJECT .
    WA_BUK_ROLE-LOCATION  = WA_BUCKET1-LOCATION  .
    WA_BUK_ROLE-ASSET_QM  = WA_BUCKET1-ASSET_QM  .
    WA_BUK_ROLE-RES = WA_BUCKET1-RES .
    WA_BUK_ROLE-CTF_SLOC  = WA_BUCKET1-CTF_SLOC  .

    LOOP AT GT_EROLES INTO WA_EROLES WHERE ROLE_TYPE = WA_BUK_ROLE-ROLE_NAME .

      WA_BUK_ROLE-USERID  = WA_EROLES-USERID  .
      WA_BUK_ROLE-ROLE_TYPE	=	WA_EROLES-ROLE_TYPE	.
      WA_BUK_ROLE-ROLE_NAME_FINAL	=	WA_EROLES-ROLE_NAME	.
      WA_BUK_ROLE-FR_DATE_AUTH_FINAL  = WA_EROLES-FR_DATE_AUTH  .
      WA_BUK_ROLE-TO_DATE_AUTH_FINAL  = WA_EROLES-TO_DATE_AUTH  .

      IF  WA_BUK_ROLE-ROLE_NAME_FINAL = 'M:COMMON_USER_TOOLS'.
        WA_BUK_ROLE-ROLE_NAME = ''.
        WA_BUK_ROLE-ROLE_TYPE = ''.
      ENDIF.


      APPEND WA_BUK_ROLE TO GT_BUK_ROLE.



    ENDLOOP.

    CLEAR  WA_BUK_ROLE.
  ENDLOOP.
  SORT GT_BUK_ROLE BY ROLE_NAME_FINAL.
  DELETE ADJACENT DUPLICATES FROM GT_BUK_ROLE COMPARING ROLE_NAME_FINAL.

  SORT GT_EROLES1 BY ROLE_NAME.
  DELETE ADJACENT DUPLICATES FROM GT_EROLES1 COMPARING ROLE_NAME.

*  IF GT_BUCKET1 IS NOT INITIAL.
  SELECT USERID DESIGNATION PERSA RSN_CODE TELNO CCODE FUNDC1 PERSK REASONFORAUTH
  COSTC DESIG_LEVEL NAME NAME1 RSN_TEXT1
  FROM ZIC_PREP_ROLEREQ
  INTO CORRESPONDING FIELDS OF TABLE GT_USERINFO
  WHERE DOCNO = WA_BUCKET-DOCNO.
*  ENDIF.

  IF GT_BUCKET1 IS INITIAL.
    MESSAGE 'All Role are rejected by HOF !!' TYPE 'I'.
    RETURN.
  ENDIF .


  IF SYST-SYSID = 'OCD'.

    LV_RFC = 'GRDCLNT500'.

  ELSEIF SYST-SYSID = 'OCQ'.

    LV_RFC = 'GRDCLNT500'.

  ELSEIF SYST-SYSID = 'OCP'.

    LV_RFC = 'GRPCLNT500'.
  ENDIF.

  CALL FUNCTION 'ZGRC_RFC_FM' DESTINATION LV_RFC "'GRDCLNT500'
*  CALL FUNCTION 'ZGRC_RFC_FM' DESTINATION 'GRPCLNT500TEST'        changes on 02.08.2014  CAB_DNS
    EXPORTING
      IT_ROLES2       = GT_EROLES1
      IP_BUCKET       = GT_BUCKET1
      IP_USERINFO     = GT_USERINFO
      IP_COKCODE      = CHECK_OKCODE
    IMPORTING
      ET_FINAL        = GT_OUTPUT
      GT_RISK_DESC    = GT_RDESC    " PERMISSION LEVEL RISK
      LT_ACT_VIOL_DET = GT_VIOLDTL
      GT_COMPLETE     = GT_CP_RISK  " COMPLETE RISK ( UNION OF GT_RDESC AND  GT_ACTION_RISK)
      GT_ACC_RISK     = GT_ACTION_RISK. " ACCTION LEVEL RISK

*   IF GT_RDESC IS INITIAL.

  EXPORT GT_RDESC TO MEMORY ID 'IM_GT_RDESC'.
*     ENDIF.


  CHECK SY-SUBRC EQ 0.
  DESCRIBE TABLE GT_VIOLDTL LINES LV_LINES.
*   LV_LINES = SY-DBCNT.
  CLEAR: GD_PERCENT.


  READ TABLE GT_BUK_ROLE INTO WA_BUK_ROLE INDEX 1.  "#EC CI_NOORDER
  IF SY-SUBRC = 0.
    LV_DOCNO = WA_BUK_ROLE-DOCNO.
  ENDIF.

  LOOP AT GT_RDESC INTO WA_RDESC. "WHERE COMPROLE EQ WA_FINAL_TB-ROLE_NAME_FINAL OR ROLE EQ WA_FINAL_TB-ROLE_NAME_FINAL .

    WA_FINAL_TB-XCONNECTOR  = WA_RDESC-XCONNECTOR  .
    WA_FINAL_TB-OBJECTID  = WA_RDESC-OBJECTID  .
    WA_FINAL_TB-RISKID  = WA_RDESC-RISKID  .
    WA_FINAL_TB-ACTRULEID = WA_RDESC-ACTRULEID  .
    WA_FINAL_TB-CONNECTOR = WA_RDESC-CONNECTOR  .
    WA_FINAL_TB-FUNCTID = WA_RDESC-FUNCTID  .
    WA_FINAL_TB-ACTION  = WA_RDESC-ACTION  .
    WA_FINAL_TB-RESOURCEID  = WA_RDESC-RESOURCEID  .
    WA_FINAL_TB-RESOURCEEXTN  = WA_RDESC-RESOURCEEXTN  .
    WA_FINAL_TB-FROMVAL = WA_RDESC-FROMVAL  .
    WA_FINAL_TB-TOVAL = WA_RDESC-TOVAL  .
    WA_FINAL_TB-ROLE  = WA_RDESC-ROLE  .
    WA_FINAL_TB-COMPROLE  = WA_RDESC-COMPROLE  .
    WA_FINAL_TB-ACCONTROLID = WA_RDESC-ACCONTROLID  .
    WA_FINAL_TB-MONITOR = WA_RDESC-MONITOR  .
    WA_FINAL_TB-ORGRULEID = WA_RDESC-ORGRULEID  .
    WA_FINAL_TB-PRMSOURCE = WA_RDESC-PRMSOURCE  .
    WA_FINAL_TB-RISKTYPE  = WA_RDESC-RISKTYPE  .
    WA_FINAL_TB-OBJECTTYPE  = WA_RDESC-OBJECTTYPE  .
    WA_FINAL_TB-VALIDFROM = WA_RDESC-VALIDFROM  .
    WA_FINAL_TB-VALIDTO = WA_RDESC-VALIDTO  .
    WA_FINAL_TB-ACTIVE  = WA_RDESC-ACTIVE  .
    WA_FINAL_TB-LASTEXECUTEDON  = WA_RDESC-LASTEXECUTEDON  .
    WA_FINAL_TB-TERMINALNAME  = WA_RDESC-TERMINALNAME  .
    WA_FINAL_TB-EXECUTIONCOUNT  = WA_RDESC-EXECUTIONCOUNT  .
    WA_FINAL_TB-LANG  = WA_RDESC-LANG  .
    WA_FINAL_TB-DESCN  = WA_RDESC-DESCN  .
    WA_FINAL_TB-DT_DESC  = WA_RDESC-DT_DESC  .
    WA_FINAL_TB-GRC_RQNO  = WA_RDESC-GRC_RQNO  .


*  V_SNUM = LV_SNUM = LV_SNUM + 1.
    V_SNUM = V_SNUM + 1.
    WA_FINAL_TB-SERIALNO = V_SNUM.

*  start of role
    READ TABLE GT_BUK_ROLE INTO WA_BUK_ROLE WITH KEY ROLE_NAME_FINAL = WA_RDESC-COMPROLE.
    IF SY-SUBRC NE 0.
      READ TABLE GT_BUK_ROLE INTO WA_BUK_ROLE WITH KEY ROLE_NAME_FINAL = WA_RDESC-ROLE.
    ENDIF.
    WA_FINAL_TB-DOCNO =     LV_DOCNO. "WA_BUK_ROLE-DOCNO.
    WA_FINAL_TB-MODULEID = 	 WA_BUK_ROLE-MODULEID.
    WA_FINAL_TB-SRNO  =	 WA_BUK_ROLE-SRNO.
    WA_FINAL_TB-ROLE_NAME =     WA_BUK_ROLE-ROLE_NAME.
    WA_FINAL_TB-PLANT =	 WA_BUK_ROLE-PLANT .
    WA_FINAL_TB-GRP =	 WA_BUK_ROLE-GRP .
    WA_FINAL_TB-SLOC  =	 WA_BUK_ROLE-SLOC  .
    WA_FINAL_TB-RECEIPT_LOC =	 WA_BUK_ROLE-RECEIPT_LOC .
    WA_FINAL_TB-APPROVER  =	 WA_BUK_ROLE-APPROVER  .
    WA_FINAL_TB-STATUS = WA_BUK_ROLE-STATUS  .
    WA_FINAL_TB-ROLE_REQUEST =   WA_BUK_ROLE-ROLE_REQUEST.
    WA_FINAL_TB-REJ_FL = 	 WA_BUK_ROLE-REJ_FL  .
    WA_FINAL_TB-REJ_ID = 	 WA_BUK_ROLE-REJ_ID  .
    WA_FINAL_TB-REJ_DATE = 	 WA_BUK_ROLE-REJ_DATE  .
    WA_FINAL_TB-REJ_FL_SAVE =	 WA_BUK_ROLE-REJ_FL_SAVE .
    WA_FINAL_TB-SHOP_NO =	 WA_BUK_ROLE-SHOP_NO .
    WA_FINAL_TB-ROLE_DESC =	 WA_BUK_ROLE-ROLE_DESC .
    WA_FINAL_TB-FLAG = 	 WA_BUK_ROLE-FLAG  .
    WA_FINAL_TB-GL_ACCOUNT =     WA_BUK_ROLE-GL_ACCOUNT  .
    WA_FINAL_TB-BUSSINESS_AREA =     WA_BUK_ROLE-BUSSINESS_AREA  .
    WA_FINAL_TB-FUND_CTR_GP =	 WA_BUK_ROLE-FUND_CTR_GP .
    WA_FINAL_TB-JVA_GRP =	 WA_BUK_ROLE-JVA_GRP .
    WA_FINAL_TB-SUB_MODULE  =	 WA_BUK_ROLE-SUB_MODULE.
    WA_FINAL_TB-ROLE_SENSITIVITY  =	 WA_BUK_ROLE-ROLE_SENSITIVITY  .
    WA_FINAL_TB-FR_DATE_AUTH  =	 WA_BUK_ROLE-FR_DATE_AUTH  .
    WA_FINAL_TB-TO_DATE_AUTH = 	 WA_BUK_ROLE-TO_DATE_AUTH.
    WA_FINAL_TB-ROLE_TYPE_EX  =	 WA_BUCKET-ROLE_TYPE_EX  .
    WA_FINAL_TB-SALE_ORG = 	 WA_BUK_ROLE-SALE_ORG  .
    WA_FINAL_TB-DIV =	 WA_BUK_ROLE-DIV .
    WA_FINAL_TB-SHIP_POINT =     WA_BUK_ROLE-SHIP_POINT  .
    WA_FINAL_TB-ASSET =    WA_BUK_ROLE-ASSET .
    WA_FINAL_TB-BASIN =	 WA_BUK_ROLE-BASIN .
    WA_FINAL_TB-PROJECT =	 WA_BUK_ROLE-PROJECT .
    WA_FINAL_TB-LOCATION = 	 WA_BUK_ROLE-LOCATION  .
    WA_FINAL_TB-ASSET_QM  =	 WA_BUK_ROLE-ASSET_QM  .
    WA_FINAL_TB-RES =	 WA_BUK_ROLE-RES .
    WA_FINAL_TB-CTF_SLOC  =	 WA_BUK_ROLE-CTF_SLOC  .
    WA_FINAL_TB-USERID  = WA_BUK_ROLE-USERID  .
    WA_FINAL_TB-ROLE_TYPE	=	WA_BUK_ROLE-ROLE_TYPE	.
    WA_FINAL_TB-ROLE_NAME_FINAL	=	WA_BUK_ROLE-ROLE_NAME_FINAL	.
    WA_FINAL_TB-FR_DATE_AUTH_FINAL  = WA_BUK_ROLE-FR_DATE_AUTH_FINAL  .
    WA_FINAL_TB-TO_DATE_AUTH_FINAL  = WA_BUK_ROLE-TO_DATE_AUTH_FINAL  .

*  end of role

    APPEND WA_FINAL_TB TO GT_FINAL_TB.
    CLEAR :WA_FINAL_TB,GS_OUTPUT_TEMP,WA_BUK_ROLE.


  ENDLOOP.




  CLEAR: LV_DOCNO.
  IF GT_FINAL_TB[] IS INITIAL.
*  V_SNUM = LV_SNUM = LV_SNUM + 1.
    V_SNUM = V_SNUM + 1.
    WA_FINAL_TB-SERIALNO = V_SNUM.
    WA_FINAL_TB-DOCNO = REQNUM_EX.
    APPEND WA_FINAL_TB TO GT_FINAL_TB.
    CLEAR: WA_FINAL_TB.
  ENDIF.

*SELECT SINGLE MAX( SERIALNO ) FROM ZGRC_VIOL_DTL INTO LV_SNUM1.


  LOOP AT GT_ACTION_RISK INTO WA_ACTION_RISK.

    LV_INDX1 = SY-TABIX.


    V_SNUM1 = V_SNUM1 + 1.
    WA_VIOL_DTL-DOCNO =     REQNUM_EX.
    WA_VIOL_DTL-SERIALNO = V_SNUM1.

    WA_VIOL_DTL-XCONNECTOR  = WA_ACTION_RISK-XCONNECTOR  .
    WA_VIOL_DTL-OBJECTID  = WA_ACTION_RISK-OBJECTID  .
    WA_VIOL_DTL-RISKID  = WA_ACTION_RISK-RISKID  .
    WA_VIOL_DTL-ACTRULEID = WA_ACTION_RISK-ACTRULEID  .
    WA_VIOL_DTL-CONNECTOR = WA_ACTION_RISK-CONNECTOR  .
    WA_VIOL_DTL-FUNCTID = WA_ACTION_RISK-FUNCTID  .
    WA_VIOL_DTL-ACTION  = WA_ACTION_RISK-ACTION  .
    WA_VIOL_DTL-RESOURCEID  = WA_ACTION_RISK-RESOURCEID  .
    WA_VIOL_DTL-RESOURCEEXTN  = WA_ACTION_RISK-RESOURCEEXTN  .
    WA_VIOL_DTL-FROMVAL = WA_ACTION_RISK-FROMVAL  .
    WA_VIOL_DTL-TOVAL = WA_ACTION_RISK-TOVAL  .
    WA_VIOL_DTL-ROLE  = WA_ACTION_RISK-ROLE  .
    WA_VIOL_DTL-COMPROLE  = WA_ACTION_RISK-COMPROLE  .
    WA_VIOL_DTL-ACCONTROLID = WA_ACTION_RISK-ACCONTROLID  .
    WA_VIOL_DTL-MONITOR = WA_ACTION_RISK-MONITOR  .
    WA_VIOL_DTL-ORGRULEID = WA_ACTION_RISK-ORGRULEID  .
    WA_VIOL_DTL-PRMSOURCE = WA_ACTION_RISK-PRMSOURCE  .
    WA_VIOL_DTL-RISKTYPE  = WA_ACTION_RISK-RISKTYPE  .
    WA_VIOL_DTL-OBJECTTYPE  = WA_ACTION_RISK-OBJECTTYPE  .
    WA_VIOL_DTL-VALIDFROM = WA_ACTION_RISK-VALIDFROM  .
    WA_VIOL_DTL-VALIDTO = WA_ACTION_RISK-VALIDTO  .
    WA_VIOL_DTL-ACTIVE  = WA_ACTION_RISK-ACTIVE  .
    WA_VIOL_DTL-LASTEXECUTEDON  = WA_ACTION_RISK-LASTEXECUTEDON  .
    WA_VIOL_DTL-TERMINALNAME  = WA_ACTION_RISK-TERMINALNAME  .
    WA_VIOL_DTL-EXECUTIONCOUNT  = WA_ACTION_RISK-EXECUTIONCOUNT  .


*    READ TABLE GT_FINAL_RISK  INTO WA_FINAL_RISK WITH KEY RISKID = WA_FINAL-RISKID.

*    READ TABLE GT_FINAL_TB INTO WA_FINAL_TB WITH KEY RISKID = WA_VIOLDTL-RISKID.

    PERFORM PROGRESS_BAR USING 'Please wait Risk analysis is in process..'(004)
                               LV_INDX1
                               LV_LINES.

    WA_VIOL_DTL-DESCN = WA_ACTION_RISK-DESCN.
    WA_VIOL_DTL-DT_DESC = WA_ACTION_RISK-DT_DESC.
    WA_VIOL_DTL-GRC_RQNO = WA_ACTION_RISK-GRC_RQNO.

    APPEND WA_VIOL_DTL TO GT_VIOL_DTL.
    CLEAR: WA_VIOL_DTL.
    CLEAR WA_ACTION_RISK.
    CLEAR WA_FINAL_TB.
  ENDLOOP.

  IF GT_VIOL_DTL[] IS INITIAL.
    V_SNUM1 = V_SNUM1 + 1.
    WA_VIOL_DTL-SERIALNO = V_SNUM1.
    WA_VIOL_DTL-DOCNO = REQNUM_EX.
    APPEND WA_VIOL_DTL TO GT_VIOL_DTL.
    CLEAR: WA_VIOL_DTL.
  ENDIF.

*************** Progress indicator
*DATA: LV_LINES TYPE I.




*  LOOP AT GT_FINAL_TB INTO WA_FINAL_TB.

*    ENDLOOP.

*************** Progress indicator





  MODIFY  ZGRC_SOD_RESULT FROM  TABLE GT_FINAL_TB .
  MODIFY  ZGRC_VIOL_DTL FROM  TABLE GT_VIOL_DTL .
  COMMIT WORK AND WAIT.

*  REQNUM_ALV = ZIC_PREP_ROLEREQ-DOCNO.
*
*  IMPORT  REQNUM_ALV FROM MEMORY ID 'REQNUM_IP'.
*  CALL TRANSACTION 'ZGRC_RESULT'.


ENDFORM.                    " GRC_RISK_ANALYSIS
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_BAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2086   text
*      -->P_LV_INDX1  text
*      -->P_LV_LINES  text
*----------------------------------------------------------------------*
FORM PROGRESS_BAR  USING    VALUE(P_2086)
                            P_LV_INDX1
                            P_LV_LINES.
  DATA: W_TEXT(40),
        W_PERCENTAGE      TYPE P,
        W_PERCENT_CHAR(3).

  W_PERCENTAGE = ( P_LV_INDX1 / P_LV_LINES ) * 100.
  W_PERCENT_CHAR = W_PERCENTAGE.
  SHIFT W_PERCENT_CHAR LEFT DELETING LEADING ' '.
  CONCATENATE P_2086 W_PERCENT_CHAR '% Complete'(006) INTO W_TEXT SEPARATED BY SPACE.

*  IF W_PERCENTAGE GT GD_PERCENT OR P_LV_INDX1 EQ 1.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = W_PERCENTAGE
      TEXT       = W_TEXT.
  GD_PERCENT = W_PERCENTAGE.
*  ENDIF.                " PROGRESS_BAR

ENDFORM.                    " PROGRESS_BAR
" DISPLAY_INFO
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM DISPLAY_INFO .
*
*  DATA : L_ANS TYPE C.
*
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*     TITLEBAR                    = 'ZICE_ARMS USER GUIDE-NEW'
**   DIAGNOSE_OBJECT             = ' '
*      TEXT_QUESTION               = 'The process for ZICE_ARMS has been changed to include an alert &'
*      &' approval process for possible Segregation of Duties Risk in roles of the user.'
*      &' Documentation on the revised process is available in User Guide Section as " ZICE_ARMS USER GUIDE-NEW. " '
*
*      TEXT_BUTTON_1               = 'YES'(098)
**   ICON_BUTTON_1               = ' '
*     TEXT_BUTTON_2               = 'NO'(099)
**   ICON_BUTTON_2               = ' '
**   DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = ' '
**   USERDEFINED_F1_HELP         = ' '
*     START_COLUMN                = 25
*     START_ROW                   = 6
**   POPUP_TYPE                  =
**   IV_QUICKINFO_BUTTON_1       = ' '
**   IV_QUICKINFO_BUTTON_2       = ' '
*   IMPORTING
*     ANSWER                      = L_ANS
** TABLES
**   PARAMETER                   =
*   EXCEPTIONS
*     TEXT_NOT_FOUND              = 1
*     OTHERS                      = 2
*            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  CASE L_ANS.
*    WHEN '2'.
*      exit.
*    WHEN OTHERS.
*  ENDCASE.
*
*
*
*ENDFORM.                    " DISPLAY_INFO
*&---------------------------------------------------------------------*
*&      Form  LIST_HELP_FILES_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_HELP_FILES_NEW .
  OBJ-OBJTYPE = OBJTYPE.
  OBJ-OBJKEY =  'ASY'.
*  G_TCODE = SY-TCODE.
*  uname = sy-uname.

  G_TCODE1 = 'DISPLAY'.

  EXPORT : G_TCODE1 FROM G_TCODE1 TO MEMORY ID 'G_TCODE1'.
  CALL METHOD MANAGER->START_SERVICE_DIRECT
    EXPORTING
      IP_SERVICE       = 'VIEW_ATTA'
      IS_OBJECT        = OBJ
    EXCEPTIONS
      NO_OBJECT        = 1
      OBJECT_INVALID   = 2
      EXECUTION_FAILED = 3
      OTHERS           = 4.
ENDFORM.                    " LIST_HELP_FILES_NEW
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ROLES .
  CLEAR IT_ROLES0.
  CLEAR IT_ROLES1.

******************************************@
  CASE MODULEID.
    WHEN 'MM'.
      SELECT * FROM ZHELP_MMROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.
    WHEN 'PM'.
      SELECT * FROM ZHELP_PMROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.
    WHEN 'PS'.
      SELECT * FROM ZHELP_PSROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.
    WHEN 'PP'.
      SELECT * FROM ZHELP_PPROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.
    WHEN 'SD'.
      SELECT * FROM ZHELP_SDROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.
    WHEN 'QM'.
      SELECT * FROM ZHELP_QMROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.
    WHEN 'HSE'.
      SELECT * FROM ZHELP_HSROLES INTO CORRESPONDING FIELDS OF TABLE IT_ROLES.

  ENDCASE.
******************************************@

  LOOP AT IT_ROLES INTO WA_ROLES.

    PERFORM CHECK_MUM.
    APPEND WA_ROLES TO IT_ROLES0.

  ENDLOOP.

  CLEAR WA_ROLES.
  LOOP AT IT_ROLES0 INTO WA_ROLES.

    IF NOT WA_ROLES-ROLE_TYPE IS INITIAL.

*      LOOP AT g_tablctrl110_itab INTO wa_item_req.
*        MOVE-CORRESPONDING wa_item_req TO wa_itemtab_sl.
*        APPEND wa_itemtab_sl TO ist_itemtab.
*      ENDLOOP.

********************************************@
      IF MODULEID = 'MM'.

        LOOP AT G_TABLCTRL110_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ELSEIF MODULEID = 'SD'.

        LOOP AT G_TABLCTRL114_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ELSEIF MODULEID = 'PP'.

        LOOP AT G_TABLCTRL113_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ELSEIF MODULEID = 'PM'.

        LOOP AT G_TABLCTRL111_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ELSEIF MODULEID = 'PS'.

        LOOP AT G_TABLCTRL112_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ELSEIF MODULEID = 'HSE'.

        LOOP AT G_TABLCTRL116_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ELSEIF MODULEID = 'QM'.

        LOOP AT G_TABLCTRL115_ITAB INTO WA_ITEM_REQ.
          MOVE-CORRESPONDING WA_ITEM_REQ TO WA_ITEMTAB_SL.
          APPEND WA_ITEMTAB_SL TO IST_ITEMTAB.
        ENDLOOP.

      ENDIF.

********************************************@


      LOOP AT IST_ITEMTAB INTO  WA_ITEMTAB_SL.
        IF WA_ROLES-ROLE_TYPE =  WA_ITEMTAB_SL-ROLE_NAME AND
                                 WA_ITEMTAB_SL-REJ_FL = '' AND
                                 WA_ITEMTAB_SL-STATUS = '' AND
                                WA_ITEMTAB_SL-ROLE_REQUEST = ''.
          PERFORM INSERT_DATA.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT IST_ITEMTAB INTO WA_ITEMTAB_SL.
*Begin of <RD1K964305>.
*    IF WA_ROLESZ-ROLE_NAME+0(1) = 'C' AND
    IF ( WA_ITEMTAB_SL-ROLE_NAME+0(1) = 'C' OR WA_ITEMTAB_SL-ROLE_NAME+0(1) = 'N' )  AND
*End of <RD1K964305>.
                         WA_ITEMTAB_SL-REJ_FL = '' AND
                         WA_ITEMTAB_SL-STATUS = '' AND
                         WA_ITEMTAB_SL-ROLE_REQUEST = ''.


      CASE MODULEID.
        WHEN 'MM'.
          PERFORM INSERT_DATA_ADDL.
        WHEN 'PM'.
          PERFORM INSERT_DATA_PM.
        WHEN 'PS'.
          PERFORM INSERT_DATA_PS.
        WHEN 'PP'.
          PERFORM INSERT_DATA_PP.
        WHEN 'SD'.
          PERFORM INSERT_DATA_SD.
        WHEN 'QM'.
          PERFORM INSERT_DATA_QM.
        WHEN 'HSE'.
          PERFORM INSERT_DATA_HS.

      ENDCASE.
    ENDIF.
  ENDLOOP.

  SORT IT_ROLES1.

**** Deleting tempelate as it gets added in logic

  LOOP AT IT_ROLES1 INTO WA_ROLE_DEL_DATA.

    IF WA_ROLE_DEL_DATA-ROLE_NAME = 'D:MM_SRV_IND_APPROVE_XX'
     OR WA_ROLE_DEL_DATA-ROLE_NAME = 'D:MM_PUR_PO_APPROVE_XX'.
      DELETE IT_ROLES1.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM IT_ROLES1.

  LOOP AT IT_ROLES1 INTO WA_ROLES1.

    WRITE ZIC_PREP_ROLEREQ-FR_DATE_AUTH TO WA_DAT1 DD/MM/YYYY.

    WRITE ZIC_PREP_ROLEREQ-TO_DATE_AUTH TO WA_DAT2 DD/MM/YYYY.

    WA_ROLES1-FR_DATE_AUTH = WA_DAT1.
    WA_ROLES1-TO_DATE_AUTH = WA_DAT2.
    MODIFY IT_ROLES1 FROM WA_ROLES1.
    CLEAR WA_ROLES1.
  ENDLOOP.


  PERFORM COPY_VALUES.

  PERFORM INSERT_RECORD.

  REFRESH IT_AGR.
  IF ZIC_PREP_ROLEREQ-RSN_CODE = '02' AND ZIC_PREP_ROLEREQ-OFF_ORDER_NO IS INITIAL.
    SET PARAMETER ID 'RCODE' FIELD ZIC_PREP_ROLEREQ-RSN_CODE.
    PERFORM DELIMIT_ROLES.
  ENDIF.

  PERFORM SAVE_REQUEST_ASSIGN.

  GL_ANS = GL_ANS_SAVE.
  CLEAR GL_ANS_SAVE.

  PERFORM FINAL_PROCESS.
  CLEAR : FLAG, FLAG1.

ENDFORM.                    " CREATE_ROLES
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ROLES_OLM .
  CLEAR IT_ROLES0.
  CLEAR IT_ROLES1.

  REFRESH: IT_ROLES_OLM[].

  SELECT * FROM ZHELP_OLMROLES INTO CORRESPONDING FIELDS OF TABLE
   IT_ROLES_OLM.

  LOOP AT IT_ROLES_OLM INTO WA_ROLES_OLM.
    APPEND WA_ROLES_OLM TO IT_ROLES0.
  ENDLOOP.

  CLEAR WA_ROLES_OLM.
  LOOP AT IT_ROLES0 INTO WA_ROLES_OLM.

    IF NOT WA_ROLES_OLM-ROLE_TYPE IS INITIAL.

      LOOP AT  G_TC_117_ITAB INTO WA_ROLESZ_OLM.
        IF WA_ROLES_OLM-ROLE_TYPE = WA_ROLESZ_OLM-ROLE_NAME .
          WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
          WA_ROLES1-ROLE_NAME = WA_ROLES_OLM-ROLE_NAME.
          APPEND WA_ROLES1 TO IT_ROLES1.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT IT_ROLES1.

  DELETE ADJACENT DUPLICATES FROM IT_ROLES1.

  LOOP AT IT_ROLES1 INTO WA_ROLES1.

    WRITE ZIC_PREP_ROLEREQ-FR_DATE_AUTH TO WA_DAT1 DD/MM/YYYY.

    WRITE ZIC_PREP_ROLEREQ-TO_DATE_AUTH TO WA_DAT2 DD/MM/YYYY.

    WA_ROLES1-FR_DATE_AUTH = WA_DAT1.
    WA_ROLES1-TO_DATE_AUTH = WA_DAT2.
    MODIFY IT_ROLES1 FROM WA_ROLES1.
    CLEAR WA_ROLES1.
  ENDLOOP.

  PERFORM COPY_VALUES.


  PERFORM INSERT_RECORD.
  PERFORM SAVE_REQUEST_ASSIGN.
  GL_ANS = GL_ANS_SAVE.
  CLEAR GL_ANS_SAVE.

  PERFORM FINAL_PROCESS.


ENDFORM.                    " CREATE_ROLES_OLM
*&---------------------------------------------------------------------*
*&      Form  CHECK_MUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MUM .
  IF ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
    SEARCH WA_ROLES-ROLE_NAME FOR 'D:FM_LOGS_FFFFFFFF'.
    IF SY-SUBRC = 0.
      WA_ROLES-ROLE_NAME = 'FM_LOGS_FFFFFFFF'.
    ENDIF.
    SEARCH WA_ROLES-ROLE_NAME FOR 'FI_AP_LOGS_DISP_CCC'.
    IF SY-SUBRC = 0.
      WA_ROLES-ROLE_NAME = 'FI_AP_LOGS_DISP_CCC_AL'.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_MUM
*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA .
  SEARCH WA_ROLES-ROLE_NAME FOR 'INPP'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'INPP' WITH  WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME FOR 'SSPP'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
    REPLACE 'SSPP' WITH  WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME FOR 'PLANT'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
*Begin of <RD1K963151>.
    IF WA_ROLES-ROLE_TYPE = 'M15' OR WA_ROLES-ROLE_TYPE = 'M20'.
      WA_ROLES1-ROLE_NAME = 'MM_INV_CCC_PLANT_PPPP'.
      REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                 WA_ROLES1-ROLE_NAME.
      REPLACE 'PPPP' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.

      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*End of <RD1K963151>.
      REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
      REPLACE 'PPPP' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.

    ENDIF.
  ENDIF.
  SEARCH WA_ROLES-ROLE_NAME FOR 'POPP'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'POPP' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.

  ENDIF.

*
  SEARCH WA_ROLES-ROLE_NAME FOR 'IGG'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
*Begin of <RD1K963151>.
    DATA : L_BUKRS1 TYPE BUKRS.
**---------- Changes Start date 24.06.2016 11:58:29-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*               A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*             D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*             D~DISC_CD AS DISC_CD
*               INTO CORRESPONDING FIELDS OF TABLE IST_DATA1
*          FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                   ON C~DESIGNO = D~DESIG_CODE AND
*                       C~R_P_CD  = D~R_P_CD AND
*                       C~VERSION = D~VERSION )
*                    WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                          A~SPRPS = ' ' AND
*                          A~ENDDA = '99991231' AND
*                          C~SPRPS = ' ' AND
*                          C~ENDDA = '99991231' .


    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
               A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
             D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
             D~DISC_CD AS DISC_CD
               INTO CORRESPONDING FIELDS OF TABLE IST_DATA1
          FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
                ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                   ON C~DESIGNO = D~DESIG_CODE AND
                       C~R_P_CD  = D~R_P_CD AND
                       C~VERSION = D~VERSION )
                    WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                          A~SPRPS = ' ' AND
                          A~ENDDA = '99991231' AND
                          C~SPRPS = ' ' AND
                          C~ENDDA = '99991231' .

**---------- Changee  Ending Date 24.06.2016 11:58:29-----------------
    IF SY-SUBRC = 0.
      READ TABLE IST_DATA1 INDEX 1.  "#EC CI_NOORDER
      L_BUKRS1 = IST_DATA1-BUKRS.
    ENDIF.


*End of <RD1K963151>.
*Begin  of <RD1K963151>.

    """"""""""""""""""""""""""""""
    "added by lipsy  for cross company on 9.03.2015 RD1K996555
    IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
      IF OLD_OK_CODE = 'APPROVE' AND   ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' .
        REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                        WA_ROLES1-ROLE_NAME.
      ELSE.
        "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555
        """""""""""""""""""""""""""""""
        REPLACE 'CCC' WITH L_BUKRS1+0(3) INTO WA_ROLES1-ROLE_NAME.
*    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
*                                  WA_ROLES1-ROLE_NAME.
*End of <RD1K963151>.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "added by lipsy  for cross company on 9.03.2015 RD1K996555
      ENDIF.
    ENDIF.
    "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    REPLACE 'IGG' WITH WA_ITEMTAB_SL-GRP INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.

  ENDIF.

*
  SEARCH WA_ROLES-ROLE_NAME FOR 'SGG'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                        WA_ROLES1-ROLE_NAME.
    REPLACE 'SGG' WITH WA_ITEMTAB_SL-GRP INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.

  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME FOR 'PGG'.
  IF SY-SUBRC = 0.

    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
*Begin of <RD1K963151>.
    DATA : L_BUKRS TYPE BUKRS.
**---------- Changes Start date 24.06.2016 11:57:56-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*               A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*             D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*             D~DISC_CD AS DISC_CD
*               INTO CORRESPONDING FIELDS OF TABLE IST_DATA2
*          FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                   ON C~DESIGNO = D~DESIG_CODE AND
*                       C~R_P_CD  = D~R_P_CD AND
*                       C~VERSION = D~VERSION )
*                    WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
*                          A~SPRPS = ' ' AND
*                          A~ENDDA = '99991231' AND
*                          C~SPRPS = ' ' AND
*                          C~ENDDA = '99991231' .

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
              A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
            D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
            D~DISC_CD AS DISC_CD
              INTO CORRESPONDING FIELDS OF TABLE IST_DATA2
         FROM ( ( ZPA0001 AS A INNER JOIN ZPA9930 AS C
               ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                  ON C~DESIGNO = D~DESIG_CODE AND
                      C~R_P_CD  = D~R_P_CD AND
                      C~VERSION = D~VERSION )
                   WHERE A~PERNR = ZIC_PREP_ROLEREQ-USERID AND
                         A~SPRPS = ' ' AND
                         A~ENDDA = '99991231' AND
                         C~SPRPS = ' ' AND
                         C~ENDDA = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:57:56-----------------

    IF SY-SUBRC = 0.
      READ TABLE IST_DATA2 INDEX 1.  "#EC CI_NOORDER
      L_BUKRS = IST_DATA2-BUKRS.
    ENDIF.
***CODE ADDED BY CAB_AMITMOZA <RD1K983325>   CR: 30007580  dt: 05.04.2013.
    IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
      REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                 WA_ROLES1-ROLE_NAME.
    ELSE.
**CODE END BY CAB_AMITMOZA <RD1K983325>
*End of <RD1K963151>.
*Begin  of <RD1K963151>.
*     REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
*                                    wa_roles1-role_name.
      REPLACE 'CCC' WITH L_BUKRS+0(3) INTO WA_ROLES1-ROLE_NAME.
*End of <RD1K963151>.
    ENDIF.
    REPLACE 'PGG' WITH WA_ITEMTAB_SL-GRP INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME FOR 'CCC'.
  IF SY-SUBRC = 0.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    IF FLAG <> 'X'.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                    WA_ROLES1-ROLE_NAME.
*      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
    FLAG = 'X'.
    IF WA_ROLES-ROLE_TYPE = 'M12' OR WA_ROLES-ROLE_TYPE = 'M17'.
      REPLACE 'RR' WITH WA_ITEMTAB_SL-RECEIPT_LOC+0(2) INTO
                                              WA_ROLES1-ROLE_NAME.


    ENDIF.

    APPEND WA_ROLES1 TO IT_ROLES1.

    SELECT SINGLE * FROM ZHELP_MMROLES_RC WHERE
                        RECEIPT_LOC = WA_ITEMTAB_SL-RECEIPT_LOC AND
                        CCODE = ZIC_PREP_ROLEREQ-CCODE.
    IF SY-SUBRC = 0.
      WA_ROLES1-ROLE_NAME = ZHELP_MMROLES_RC-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.



  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME FOR 'FM_LOGS'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
*BEGIN OF  <RD1K963151>.
    IF ZIC_PREP_ROLEREQ-CCODE = 'OVL'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = 'D:FM_LOGS_OVL_ALL'.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*END OF <RD1K963151>.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      IF ZIC_PREP_ROLEREQ-FUNDC1 <> '' AND
            ZIC_PREP_ROLEREQ-FUNDC_FL = 'X'.
        REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC1 INTO
                           WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.
      IF ZIC_PREP_ROLEREQ-FUNDC <> ''.
        WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
        REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC INTO
                           WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.
      IF ZIC_PREP_ROLEREQ-FUNDC2 <> ''.
        WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
        REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC2 INTO
                           WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.
      IF ZIC_PREP_ROLEREQ-FUNDC3 <> ''.
        WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
        REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC3 INTO
                           WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.
      IF ZIC_PREP_ROLEREQ-FUNDC4 <> ''.
        WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
        REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC4 INTO
                           WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.

    ENDIF.
  ENDIF.
  SEARCH WA_ROLES-ROLE_NAME FOR 'MM_SRV_SES_ACCEPT'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'YY' WITH WA_ITEMTAB_SL-APPROVER INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME FOR 'MM_PUR_PO_APPROVE_ZZ'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'ZZ' WITH WA_ITEMTAB_SL-APPROVER INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  IF FLAG <> 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
*Begin of <RD1K963151>.
    IF ZIC_PREP_ROLEREQ-CCODE = 'OVL'  AND WA_ROLES1-ROLE_NAME = 'D:MM_DISPLAY_ALL'.
      WA_ROLES1-ROLE_NAME = 'D:MM_OVL_DISPLAY_ALL'.
    ELSEIF ZIC_PREP_ROLEREQ-CCODE = 'OVL'  AND WA_ROLES1-ROLE_NAME = 'D:MM_DISPLAY_PM_PS_LIS_CIN'.
      WA_ROLES1-ROLE_NAME = 'D:MM_OVL_DISPLAY_PM_PS_LIS_CIN'.
    ENDIF.
*End of <RD1K963151>.
    APPEND WA_ROLES1 TO IT_ROLES1.

  ENDIF.

  CLEAR FLAG.

  IF WA_ROLES-ROLE_TYPE = 'M13'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.

**code added by CAB_AMITMOZA  RD1K983325   CR:30007580
      SELECT * FROM ZMM_PREP_ROLE_SL WHERE
                WERKS = WA_ITEMTAB_SL-PLANT AND
                LGORT = WA_ITEMTAB_SL-SLOC.
**code end RD1K983325

***comment start by CAB_AMITMOZA  RD1K983325   CR:30007580
*      SELECT SINGLE * FROM zmm_prep_role_sl WHERE
*                werks = wa_rolesz-plant AND
*                lgort = wa_rolesz-sloc.
***comment end RD1K983325

        WA_ROLES1-ROLE_NAME = ZMM_PREP_ROLE_SL-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDSELECT.
    ENDIF.
  ENDIF.

  IF WA_ROLES-ROLE_TYPE = 'M14'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ITEMTAB_SL-PLANT AND LGORT = WA_ITEMTAB_SL-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = ZMM_PREP_ROLE_SL-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.
  ENDIF.

  IF WA_ROLES-ROLE_TYPE = 'M16'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ITEMTAB_SL-PLANT AND LGORT = WA_ITEMTAB_SL-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = ZMM_PREP_ROLE_SL-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.
  ENDIF.

  IF WA_ROLES-ROLE_TYPE = 'M11S' OR
     WA_ROLES-ROLE_TYPE = 'M11M' OR
     WA_ROLES-ROLE_TYPE = 'M3'   OR
     WA_ROLES-ROLE_TYPE = 'M3A'  OR
     WA_ROLES-ROLE_TYPE = 'M3B'  .

    SEARCH WA_ROLES-ROLE_NAME FOR 'XX'.
    IF SY-SUBRC = 0.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'XX' WITH WA_ITEMTAB_SL-APPROVER INTO
                                    WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.
  ENDIF.

**11/05/2007
  CLEAR FLAG.
ENDFORM.                    " INSERT_DATA
*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA_ADDL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_ADDL .
  CLEAR WA_ROLES1.
  DATA : CONDITION(3) TYPE C.
*Begin of <RD1K962817>.
  CLEAR : LV_MIN_DESIG,
           LV_CURR_ROLE.
*End of <RD1K962817>.
  REFRESH IT_ROLES1_ADDL.
  SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE
 ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND ROLE_TYPE_EX = WA_ITEMTAB_SL-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF SY-SUBRC = 0.
*Begin of <RD1K962817>.
    LV_MIN_DESIG = ZMM_PREP_CRCDESG-MIN_DESIGNATION.
    LV_CURR_ROLE = ZIC_PREP_ROLEREQ-PERSK.
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
    IF ZMM_PREP_CRCDESG-CRC_LEVEL_ADDL <> SPACE.
*      wa_rolesz-approver = zmm_prep_crcdesg-crc_level_addl.
      IF LV_CURR_ROLE = LV_MIN_DESIG  OR LV_MIN_DESIG = SPACE.
      ELSE.
        IF LV_CURR_ROLE LE LV_MIN_DESIG OR LV_MIN_DESIG = SPACE.
*          CASE wa_rolesz-approver.
*            WHEN 'L2'.
*              wa_rolesz-approver = 'L3'.
*            WHEN 'L1'.
*              wa_rolesz-approver = 'L2'.
*            WHEN 'L3'.
*              wa_rolesz-approver = 'L4'.
*          ENDCASE.
          SELECT SINGLE * FROM ZMM_PREP_CRCIMII WHERE
          CRC_LEVEL_ADDL = ZMM_PREP_CRCDESG-CRC_LEVEL_ADDL AND
          CRC_LEVEL      = ZMM_PREP_CRCDESG-CRC_LEVEL   AND
          MIN_DESIGNATION = ZIC_PREP_ROLEREQ-PERSK.
          IF SY-SUBRC = 0 .
            MOVE ZMM_PREP_CRCIMII-PO_LEVEL TO ZMM_PREP_CRCDESG-CRC_LEVEL.
            MOVE ZMM_PREP_CRCIMII-SRV_LEVL TO ZMM_PREP_CRCDESG-CRC_LEVEL_ADDL.
          ELSE .
            MESSAGE E803(ZMM) WITH 'No Entries Found in The Table ZMM_PREP_CRCIMII'.
          ENDIF.
        ENDIF.
      ENDIF.
      MOVE ZMM_PREP_CRCDESG-CRC_LEVEL_ADDL TO WA_ITEMTAB_SL-APPROVER.

    ELSE.    "zmm_prep_crcdesg-crc_level_addl IS INITIAL.  LV_CURR_ROLE LE LV_MIN_DESIG.
      WA_ITEMTAB_SL-APPROVER = ZMM_PREP_CRCDESG-CRC_LEVEL.
      IF LV_CURR_ROLE = LV_MIN_DESIG OR LV_MIN_DESIG = SPACE..
      ELSE.
        IF LV_CURR_ROLE LE LV_MIN_DESIG OR LV_MIN_DESIG = SPACE.
          MESSAGE 'You do not meet the minimum designation criteria. Pls. contact SAP team with a copy of order for further action.' TYPE 'E'.
*          CASE WA_ITEMTAB_SL-APPROVER.
*            WHEN 'L2'.
*              WA_ITEMTAB_SL-APPROVER = 'L3'.
*            WHEN 'L1'.
*              WA_ITEMTAB_SL-APPROVER = 'L2'.
*            WHEN 'L3'.
*              WA_ITEMTAB_SL-APPROVER = 'L4'.
*          ENDCASE.
        ENDIF.
      ENDIF.
      MOVE WA_ITEMTAB_SL-APPROVER TO ZMM_PREP_CRCDESG-CRC_LEVEL.
    ENDIF.
*End of < RD1K963297>.
    IF ZMM_PREP_CRCDESG-CRC_LEVEL = 'L1'.
      SELECT * FROM ZHELP_MMROLES INTO CORRESPONDING FIELDS OF TABLE
             IT_ROLES1_ADDL WHERE ROLE_TYPE = 'M3'.
    ELSEIF  ZMM_PREP_CRCDESG-CRC_LEVEL = 'L2' OR
            ZMM_PREP_CRCDESG-CRC_LEVEL = 'L3' OR
            ZMM_PREP_CRCDESG-CRC_LEVEL = 'IM' OR
*Begin of <RD1K963297>.
           ZMM_PREP_CRCDESG-CRC_LEVEL = 'SM'.
*End of <RD1K963297>.
      SELECT * FROM ZHELP_MMROLES INTO CORRESPONDING FIELDS OF TABLE
             IT_ROLES1_ADDL WHERE ROLE_TYPE = 'M3A'.
    ELSEIF ZMM_PREP_CRCDESG-CRC_LEVEL = 'L4' OR
            ZMM_PREP_CRCDESG-CRC_LEVEL = 'E5' OR
            ZMM_PREP_CRCDESG-CRC_LEVEL = 'E6' OR
            ZMM_PREP_CRCDESG-CRC_LEVEL = 'E7'.
      SELECT * FROM ZHELP_MMROLES INTO CORRESPONDING FIELDS OF TABLE
             IT_ROLES1_ADDL WHERE ROLE_TYPE = 'M3B'.
    ELSEIF ( ZMM_PREP_CRCDESG-CRC_LEVEL = 'SM' AND
            ZMM_PREP_CRCDESG-CRC_LEVEL_ADDL = 'SM' ).

      SELECT * FROM ZHELP_MMROLES INTO CORRESPONDING FIELDS OF TABLE
            IT_ROLES1_ADDL WHERE ROLE_TYPE = 'M11M'.
    ENDIF.
    CLEAR FLAG.
    LOOP AT IT_ROLES1_ADDL INTO WA_ROLES1.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ROLES1-ROLE_NAME.
      SEARCH WA_ROLES1-ROLE_NAME FOR 'XX'.
      IF SY-SUBRC = 0.
        FLAG = 'X'.
        REPLACE 'XX' WITH WA_ITEMTAB_SL-APPROVER INTO
                                     WA_ITEMTAB_SL-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.
      SEARCH WA_ROLES1-ROLE_NAME FOR 'QQ'.
      IF SY-SUBRC = 0.
        FLAG = 'X'.
        REPLACE 'QQ' WITH ZMM_PREP_CRCDESG-CRC_LEVEL INTO
                                      WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.
      SEARCH WA_ROLES1-ROLE_NAME FOR 'PLANT'.
      IF SY-SUBRC = 0.
        FLAG = 'X'.
        REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                              WA_ROLES1-ROLE_NAME.
        REPLACE 'PPPP' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.

      SEARCH WA_ROLES1-ROLE_NAME FOR 'FM_LOGS'.
      IF SY-SUBRC = 0.
        FLAG = 'X'.
*BEGIN OF  <RD1K963151>.
        IF ZIC_PREP_ROLEREQ-CCODE = 'OVL'.

          WA_ROLES1-ROLE_NAME = 'D:FM_LOGS_OVL_ALL'.
          APPEND WA_ROLES1 TO IT_ROLES1.
        ELSE.
*END OF <RD1K963151>.
          IF ZIC_PREP_ROLEREQ-FUNDC1 <> '' .
            REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC1 INTO
                               WA_ROLES1-ROLE_NAME.
            APPEND WA_ROLES1 TO IT_ROLES1.
          ENDIF.
          IF ZIC_PREP_ROLEREQ-FUNDC <> ''.
            REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC INTO
                               WA_ROLES1-ROLE_NAME.
            APPEND WA_ROLES1 TO IT_ROLES1.
          ENDIF.
          IF ZIC_PREP_ROLEREQ-FUNDC2 <> ''.
            REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC2 INTO
                               WA_ROLES1-ROLE_NAME.
            APPEND WA_ROLES1 TO IT_ROLES1.
          ENDIF.
          IF ZIC_PREP_ROLEREQ-FUNDC3 <> ''.
            REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC3 INTO
                               WA_ROLES1-ROLE_NAME.
            APPEND WA_ROLES1 TO IT_ROLES1.
          ENDIF.
          IF ZIC_PREP_ROLEREQ-FUNDC4 <> ''.
            REPLACE 'FFFFFFFF' WITH ZIC_PREP_ROLEREQ-FUNDC4 INTO
                               WA_ROLES1-ROLE_NAME.
            APPEND WA_ROLES1 TO IT_ROLES1.
          ENDIF.
        ENDIF.
      ENDIF.

      SEARCH WA_ROLES1-ROLE_NAME FOR 'CCC_YY'.
      IF SY-SUBRC = 0.
        FLAG = 'X'.
        REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                      WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.

      SEARCH WA_ROLES1-ROLE_NAME FOR 'PGG'.
      IF SY-SUBRC = 0.
        FLAG = 'X'.
        REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                      WA_ROLES1-ROLE_NAME.
        REPLACE 'PGG' WITH WA_ITEMTAB_SL-GRP INTO WA_ROLES1-ROLE_NAME.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ENDIF.

      IF FLAG <> 'X'.
        APPEND WA_ROLES1 TO IT_ROLES1.
      ELSE.
        CLEAR FLAG.
      ENDIF.
    ENDLOOP.
*Begin of <RD1K963151>.
    IF ZIC_PREP_ROLEREQ-CCODE = 'OVL'.
      CLEAR WA_ROLES1.
      LOOP AT IT_ROLES1 INTO WA_ROLES1.
        IF WA_ROLES1-ROLE_NAME = 'D:MM_DISPLAY_ALL'.
          WA_ROLES1-ROLE_NAME = 'D:MM_OVL_DISPLAY_ALL'.
        ENDIF.
        IF WA_ROLES1-ROLE_NAME = 'D:MM_DISPLAY_PM_PS_LIS_CIN'.
          WA_ROLES1-ROLE_NAME = 'D:MM_OVL_DISPLAY_PM_PS_LIS_CIN'.
        ENDIF.
        MODIFY IT_ROLES1 FROM WA_ROLES1.
      ENDLOOP.
    ENDIF.
*End of <RD1K963151>.
  ENDIF.
ENDFORM.                    " INSERT_DATA_ADDL
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE .
  IF NOT P1_FILE IS INITIAL.

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

    DATA L_FILE TYPE STRING.

    L_FILE = P1_FILE.


    """"""""""""""""""""""""""""""""""""""""""""""""""
    "comment for testing

*types: t_line type c length 100.
*data: lt_tab type table of t_line.
*append 'test' to lt_tab.


*
*call method cl_gui_frontend_services=>gui_download
*  exporting
*    filename = l_file "'C:\temp\file.txt'
*  changing
*    data_tab = it_roles1. "lt_tab[].



    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        FILENAME                = L_FILE
        FILETYPE                = 'DAT'
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
        DATA_TAB                = IT_ROLES1
*       FIELDNAMES              =
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
* end of <RD1K960036>
    IF SY-SUBRC <> 0.

      MESSAGE I061(ZHELP) WITH TEXT-053.

      EXIT.

    ENDIF.
    "end of comment for testing
    """"""""""

  ENDIF.
ENDFORM.                    " DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_STEP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_STEP .
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
      TITLEBAR       = 'Confirm'
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION  = 'Role request being created' &
                       'Continue ??? '
      TEXT_BUTTON_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      TEXT_BUTTON_2  = 'No'(002)
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
      ANSWER         = GL_ANS
*    TABLES
*     PARAMETER      =
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF GL_ANS EQ '1'.
    CLEAR GL_ANS.
    MOVE 'J' TO GL_ANS.
  ELSEIF GL_ANS EQ '2'.
    CLEAR GL_ANS.
    MOVE 'N' TO GL_ANS.
  ELSE.
    CLEAR GL_ANS.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " CONFIRM_STEP
*&---------------------------------------------------------------------*
*&      Form  INSERT_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_RECORD .
  G_ROLE_FLAG = 'X'.
ENDFORM.                    " INSERT_RECORD
*&---------------------------------------------------------------------*
*&      Form  COPY_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COPY_VALUES .
  IF NOT ZROLEREQNO IS INITIAL.
    ZIC_PREP_ROLEREQ-REQ_NO = ZROLEREQNO.
  ENDIF.
ENDFORM.                    " COPY_VALUES
*&---------------------------------------------------------------------*
*&      Form  SAVE_REQUEST_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_REQUEST_ASSIGN .
  IF OLD_OK_CODE = 'CREATE'.

    PERFORM GEN_NO.

  ENDIF.

  PERFORM INSERT_HEADER_ASSIGN.

ENDFORM.                    " SAVE_REQUEST_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  INSERT_HEADER_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_HEADER_ASSIGN .
  ZIC_PREP_ROLEREQ-MANDT = SY-MANDT.
  IF OLD_OK_CODE = 'CREATE'.
    ZIC_PREP_ROLEREQ-DOCNO = ZDOCNUMB.
  ENDIF.


  IF ZIC_PREP_ROLEREQ-USERIDCR IS INITIAL.

    ZIC_PREP_ROLEREQ-USERIDCR = SY-UNAME.
    ZIC_PREP_ROLEREQ-CR_DATE  = SY-DATUM.

    IF SY-TCODE <> 'ZIC_AUTH_CORETEAM'.

      CLEAR ZUSRMST.

      SELECT SINGLE * FROM ZUSRMST WHERE CPFNO =
                                 ZIC_PREP_ROLEREQ-USERIDCR.

      IF SY-SUBRC NE 0.

      ELSE.
*
        CONCATENATE ZUSRMST-FIRST_NAME ZUSRMST-LAST_NAME INTO
          ZUSRMST-LAST_NAME.
        ZIC_PREP_ROLEREQ-NAMECR = ZUSRMST-LAST_NAME.

      ENDIF.

    ENDIF.

  ENDIF.

  IF ZIC_PREP_ROLEREQ-USERIDAP IS INITIAL.

    IF OLD_OK_CODE = 'APPROVE' AND
          ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
      ZIC_PREP_ROLEREQ-USERIDAP = SY-UNAME.
      ZIC_PREP_ROLEREQ-APP_DATE  = SY-DATUM.

      CLEAR ZUSRMST.

      SELECT SINGLE * FROM ZUSRMST WHERE CPFNO =
                            ZIC_PREP_ROLEREQ-USERIDAP.

      IF SY-SUBRC NE 0.

      ELSE.

        CONCATENATE ZUSRMST-FIRST_NAME ZUSRMST-LAST_NAME INTO
         ZUSRMST-LAST_NAME.
        ZIC_PREP_ROLEREQ-NAMEAPP = ZUSRMST-LAST_NAME.
      ENDIF.

    ENDIF.

  ELSE.

    IF OLD_OK_CODE = 'APPROVE' AND
          ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X'
                AND ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZIC_PREP_ROLEREQ-USERIDAP = SY-UNAME.
      ZIC_PREP_ROLEREQ-APP_DATE = SY-DATUM.

      SELECT SINGLE * FROM ZUSRMST WHERE CPFNO =
                              ZIC_PREP_ROLEREQ-USERIDAP.
      IF SY-SUBRC NE 0.
        MESSAGE E043(ZHELP).
      ELSE.

        CONCATENATE ZUSRMST-FIRST_NAME ZUSRMST-LAST_NAME INTO
        ZUSRMST-LAST_NAME.
        ZIC_PREP_ROLEREQ-NAMEAPP = ZUSRMST-LAST_NAME.
      ENDIF.
    ENDIF.
  ENDIF.

*****************************
  DATA L_FUNDC_NO LIKE SY-INDEX.
  CLEAR L_FUNDC_NO.

*****************************
  IF ZIC_PREP_ROLEREQ-STATUS <> 'C'.

    ZIC_PREP_ROLEREQ-STATUS = 'IF'.

  ENDIF.

*****
  IF G_FUNDC_ERR_FLAG <> 'X'.

*************************************************************

** Module wise check & insertion

    CASE MODULEID.

*      WHEN 'MM'.
*
*        PERFORM insert_items_assign.

      WHEN 'OLM'.

        PERFORM INSERT_ITEMS_OLM_ASSIGN.

*****************************************@
      WHEN OTHERS.
        PERFORM INSERT_ITEMS_ASSIGN.
*****************************************@

    ENDCASE.

    IF SY-TCODE <> 'ZIC_AUTH_CORETEAM'.

      PERFORM ITEMS_APPROVAL_CHECK_ASSIGN.

    ENDIF.

***********************

    IF SY-SUBRC = 0 AND ( ZIC_PREP_ROLEREQ-STATUS <> 'IC'
                        AND ZIC_PREP_ROLEREQ-STATUS <> 'IR' ).

      SELECT * FROM ZIC_PREP_ROLEREI INTO TABLE IST_ITEMTAB
              WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

      LOOP AT IST_ITEMTAB INTO WA_ITEMTAB.
        IF WA_ITEMTAB-REJ_FL = ''.
          IF WA_ITEMTAB-STATUS = '' AND
              WA_ITEMTAB-ROLE_REQUEST = ''.
            G_REQUEST_CLOSE_FLAG_P  = 'X'.
          ELSEIF WA_ITEMTAB-STATUS = 'H'.
            G_REQUEST_CLOSE_FLAG_H = 'X'.
          ELSEIF  WA_ITEMTAB-ROLE_REQUEST <> ''.
            G_REQUEST_CLOSE_FLAG_R = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF ( G_REQUEST_CLOSE_FLAG_P  = 'X' OR
         G_REQUEST_CLOSE_FLAG_H  = 'X' ) AND
         G_REQUEST_CLOSE_FLAG_R = 'X'.
        ZIC_PREP_ROLEREQ-STATUS = 'PC'.
      ELSEIF G_REQUEST_CLOSE_FLAG_P  <> 'X' AND
         G_REQUEST_CLOSE_FLAG_H  = 'X' AND
         G_REQUEST_CLOSE_FLAG_R = 'X'.
        ZIC_PREP_ROLEREQ-STATUS = 'PC'.
      ELSEIF G_REQUEST_CLOSE_FLAG_P  = '' AND
         G_REQUEST_CLOSE_FLAG_H  = '' AND
         G_REQUEST_CLOSE_FLAG_R = 'X'.
        ZIC_PREP_ROLEREQ-STATUS = 'C'.
      ELSEIF G_REQUEST_CLOSE_FLAG_P  = 'X' AND
         G_REQUEST_CLOSE_FLAG_H  <> 'X' AND
         G_REQUEST_CLOSE_FLAG_R <> 'X'.
        ZIC_PREP_ROLEREQ-STATUS = 'IF'.
      ELSEIF  G_REQUEST_CLOSE_FLAG_P = '' AND
               G_REQUEST_CLOSE_FLAG_H = '' AND
                 G_REQUEST_CLOSE_FLAG_R <> ''.
        ZIC_PREP_ROLEREQ-STATUS = 'C'.
      ENDIF.

    ENDIF.



    MODIFY ZIC_PREP_ROLEREQ FROM ZIC_PREP_ROLEREQ.

    CLEAR : G_REQUEST_CLOSE_FLAG_P, G_REQUEST_CLOSE_FLAG_H,
            G_REQUEST_CLOSE_FLAG_R.


****Saving the long text.                              *****

    IF ( OLD_OK_CODE = 'CREATE' ) OR
       ( OLD_OK_CODE = 'CHANGE' ) OR
       ( OLD_OK_CODE = 'RELEASE' ) OR
       ( OLD_OK_CODE = 'APPROVE' ).

      PERFORM SAVE_CORS_TEXT.
      PERFORM UNLOCK_RECORD.
    ENDIF.

    IF G_ROLE_FLAG = 'X'.
      CLEAR G_ROLE_FLAG.


    ELSE.

      IF L_OLD_OK_CODE = 'X'.
        SET PARAMETER ID 'ZOLDCODE' FIELD L_INITIAL.
        LEAVE PROGRAM.
      ELSE.
        PERFORM CLEAR_ASSIGN.

      ENDIF.

    ENDIF.
  ELSE.
  ENDIF.
ENDFORM.                    " INSERT_HEADER_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_MESSAGE_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_MESSAGE_ASSIGN .
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
      TITLEBAR       = 'Confirm'
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION  = 'This is a multiple module request.' &
                       ' If u continue with correspondence,' &
                       ' other modules will not be able to' &
                       ' process their part of the request,OK'
      TEXT_BUTTON_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      TEXT_BUTTON_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
      DEFAULT_BUTTON = '2'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER         = GL_ANS
*   TABLES
*     PARAMETER      =
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF GL_ANS EQ '1'.
    CLEAR GL_ANS.
    MOVE 'Y' TO GL_ANS.
  ELSEIF GL_ANS EQ '2'.
    CLEAR GL_ANS.
    MOVE 'N' TO GL_ANS.
  ELSE.
    CLEAR GL_ANS.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " CONFIRM_MESSAGE_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_PROCESS_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_PROCESS_ASSIGN .
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
      TEXT_QUESTION         = 'Do you want to process request after'
                              & ' saving?'
      TEXT_BUTTON_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      TEXT_BUTTON_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = SPACE
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      ANSWER                = STATUS_PROCESS
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " CONFIRM_PROCESS_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_STATUS_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_STATUS_ASSIGN .
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
      TEXT_QUESTION         = 'Do you want to change status to IC? '
      TEXT_BUTTON_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      TEXT_BUTTON_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = SPACE
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
      ANSWER                = STATUS_CHOICE
* End of <RD1K960611>
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* end of <RD1K960036>
ENDFORM.                    " CONFIRM_STATUS_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  SEND_SAPMAIL_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_SAPMAIL_ASSIGN .
*--- Send mail to user


  DOCUMENT_DATA-OBJ_LANGU  = SY-LANGU.
  DOCUMENT_DATA-OBJ_NAME   = 'OVL Core Team'.
  DOCUMENT_DATA-OBJ_DESCR  = 'Mail from OVL Core Team'.
  SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  CONCATENATE DOCUMENT_DATA-OBJ_DESCR '---' ZAUTH_USER-PRIMARY_MODULE
  '-' 'Module' INTO DOCUMENT_DATA-OBJ_DESCR.
  DOCUMENT_DATA-PRIORITY   = '3'.

* Remove prefix 'US' from receiver
  REFRESH RECEIVERS.

  CLEAR WA_RECEIVERS.
  WA_RECEIVERS-RECEIVER = ZIC_PREP_ROLEREQ-USERIDCR.
  WA_RECEIVERS-REC_TYPE = 'B'.
  WA_RECEIVERS-EXPRESS  = 'X'.
  APPEND WA_RECEIVERS TO RECEIVERS.

  CLEAR WA_RECEIVERS.

  MOVE SPACE TO OBJECT_CONTENT-LINE.
  APPEND OBJECT_CONTENT.

  CONCATENATE  'Subject: '  'Creation of Roles for userid '
ZIC_PREP_ROLEREQ-USERID INTO  OBJECT_CONTENT-LINE
SEPARATED BY SPACE.
  APPEND OBJECT_CONTENT.

  MOVE SPACE TO OBJECT_CONTENT-LINE.
  APPEND OBJECT_CONTENT.
  IF ZIC_PREP_ROLEREQ-STATUS = 'C'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      concatenate 'Please  check  your role request  which  has  been
*assigned  &  completed - ' zic_prep_rolereq-docno into

    CONCATENATE 'Please  check  your role request  which  has'
     'been assigned  &  completed - ' ZIC_PREP_ROLEREQ-DOCNO INTO
* end of <RD1K960036>
OBJECT_CONTENT-LINE
SEPARATED BY SPACE.
    APPEND OBJECT_CONTENT.
  ELSE.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      concatenate 'Please check your role request which has been updated
* - ' zic_prep_rolereq-docno into  object_content-line
*    CONCATENATE 'Please check your role request which has been' &
*     ' updated - ' zic_prep_rolereq-docno INTO  object_content-line
** end of <RD1K960036>
*SEPARATED BY space.
*    APPEND object_content.
  ENDIF.
********************************************************************
  """"""""""""""""""""""
  IF ZIC_PREP_ROLEREQ-STATUS = 'IF'.
    IF V_MESSAGE_AS = 'X'.
      CONCATENATE 'All Required roles are already assigned in previous requests.- ' ZIC_PREP_ROLEREQ-DOCNO INTO
OBJECT_CONTENT-LINE
SEPARATED BY SPACE.
    ENDIF.
    APPEND OBJECT_CONTENT.
  ENDIF.
  """""""""""""""""""""""""""""



  IF ZIC_PREP_ROLEREQ-STATUS = 'IC'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Please go through correspondence in the request. The request
* needs to be changed, re-released & re-approved by competent authority.
*Once the request is approved, the request will flow to ICE core team.'
    MOVE 'Please go through correspondence in the request. The' &
         ' request needs to be changed, re-released & re-approved' &
         ' by competent authority. Once the request is approved, the' &
         ' request will flow to OVL core team.'
* end of <RD1K960036>
TO OBJECT_CONTENT-LINE.
    APPEND OBJECT_CONTENT.
  ENDIF.
  IF ZIC_PREP_ROLEREQ-STATUS = 'IR'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Please go through the correspondence in the request & reply
*to the query raised by ICE core team. You need to save the request after
* giving reply in correspondence(In display mode only). Once the request
*is saved, the request will flow to ICE core team.'
    MOVE 'Please go through the correspondence in the request &' &
         ' reply to the query raised by OVL core team. You need to' &
         ' save the request after giving reply in correspondence' &
         '(In display mode only). Once the request is saved, the' &
         ' request will flow to OVL core team.'
* end of <RD1K960036>
TO OBJECT_CONTENT-LINE.
    APPEND OBJECT_CONTENT.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     Move 'No re-release or approvals are required in this case & user
*will not be able to open the request in change mode.'
    MOVE 'No re-release or approvals are required in this case &' &
         ' user will not be able to open the request in change mode.'
* end of <RD1K960036>
TO OBJECT_CONTENT-LINE.
    APPEND OBJECT_CONTENT.
  ENDIF.
  IF ZIC_PREP_ROLEREQ-STATUS = 'PC'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Your request is still under process with ICE core team. Only
* partial roles have been assigned. You will get the next message'
    MOVE 'Your request is still under process with OVL core team.' &
         ' Only partial roles have been assigned. You will get the' &
         ' next message'
* end of <RD1K960036>
TO OBJECT_CONTENT-LINE.
    APPEND OBJECT_CONTENT.
    MOVE 'for completion or return of request soon.' TO
OBJECT_CONTENT-LINE.
    APPEND OBJECT_CONTENT.
  ENDIF.
********************************************************************
  MOVE SPACE TO OBJECT_CONTENT-LINE.
  APPEND OBJECT_CONTENT.

  OBJECT_CONTENT-LINE = 'OVL Core Team'.
  APPEND OBJECT_CONTENT.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = DOCUMENT_DATA
      DOCUMENT_TYPE              = 'RAW'
      PUT_IN_OUTBOX              = 'X'
    IMPORTING
      SENT_TO_ALL                = SENT_TO_ALL
    TABLES
      OBJECT_HEADER              = OBJHEAD
      OBJECT_CONTENT             = OBJECT_CONTENT
      RECEIVERS                  = RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 01
      DOCUMENT_NOT_SENT          = 02
      DOCUMENT_TYPE_NOT_EXIST    = 03
      OPERATION_NO_AUTHORIZATION = 04
      PARAMETER_ERROR            = 05
      X_ERROR                    = 06
      ENQUEUE_ERROR              = 07.

  CASE SY-SUBRC.
    WHEN 0.

*      MESSAGE i060(zhelp) WITH zic_prep_rolereq-useridcr.
    WHEN '01'.
      RAISE TOO_MANY_RECEIVERS.
    WHEN '02'.
      RAISE DOCUMENT_NOT_SENT.
    WHEN '03'.
      RAISE DOCUMENT_TYPE_NOT_EXIST.
    WHEN '04'.
      RAISE OPERATION_NO_AUTHORIZATION.
    WHEN '05'.
      RAISE PARAMETER_ERROR.
    WHEN '06'.
      RAISE X_ERROR.
    WHEN '07'.
      RAISE ENQUEUE_ERROR.
  ENDCASE.

********************************************
********************************************
ENDFORM.                    " SEND_SAPMAIL_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_ASSIGN .
  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  CASE MODULEID.
    WHEN 'PM'.

      PERFORM INSERT_ITEMS_PM.

    WHEN 'PS'.

      PERFORM INSERT_ITEMS_PS.

    WHEN 'PP'.

      PERFORM INSERT_ITEMS_PP.

    WHEN 'SD'.

      PERFORM INSERT_ITEMS_SD.

    WHEN 'QM'.

      PERFORM INSERT_ITEMS_QM.

    WHEN 'HSE'.

      PERFORM INSERT_ITEMS_HS.

    WHEN 'MM'.
      SORT G_TABLCTRL110_ITAB
      BY ROLE_NAME PLANT GRP  SLOC RECEIPT_LOC APPROVER.

      DELETE ADJACENT DUPLICATES FROM G_TABLCTRL110_ITAB
        COMPARING ROLE_NAME PLANT GRP  SLOC RECEIPT_LOC APPROVER REJ_FL.

      LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.

        MOVE-CORRESPONDING G_TABLCTRL110_WA TO WA_ITEMTAB.

        IF G_ROLE_FLAG = 'X' AND WA_ITEMTAB-REJ_FL = '' AND
            WA_ITEMTAB-STATUS = '' AND WA_ITEMTAB-ROLE_REQUEST = ''.
          WA_ITEMTAB-ROLE_REQUEST = ZROLEREQNO.
        ENDIF.

        IF OLD_OK_CODE = 'CREATE'.
          WA_ITEMTAB-DOCNO = ZDOCNUMB.
        ENDIF.

        WA_ITEMTAB-MANDT = SY-MANDT.
        IF WA_ITEMTAB-REJ_FL <> ''.
          WA_ITEMTAB-REJ_FL_SAVE = 'X'.
        ENDIF.
        IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
          I = I + 1.
          WA_ITEMTAB-SRNO = I .
          APPEND WA_ITEMTAB TO IST_ITEMTAB.
        ENDIF.

        G_I = I.

*    PERFORM check_items_save_assign.

      ENDLOOP.

      DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

      IF G_LINES_RL = 0.
        IF OLD_OK_CODE = 'CHANGE'.
          IF SY-SUBRC = 0.
            SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
            MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
          ENDIF.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ELSE.

        DELETE FROM ZIC_PREP_ROLEREI WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
           AND MODULEID = MODULEID..

        MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

        IF SY-SUBRC = 0 AND G_ROLE_FLAG <> 'X'.
          MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
        ENDIF.

      ENDIF.

  ENDCASE.
ENDFORM.                    " INSERT_ITEMS_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  CHECK_ITEMS_SAVE_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ITEMS_SAVE_ASSIGN .
  IF OLD_OK_CODE <> 'DISPLAY' .

*    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.
*
*      SELECT SINGLE * FROM zmm_prep_rolecrc WHERE role_type =
*                                                  wa_itemtab-role_name.
*      IF sy-subrc = 0.
*
*        IF zmm_prep_rolecrc-plant = 'X' AND
*            wa_itemtab-plant IS INITIAL.
*          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
*          ROLLBACK WORK.
*          MESSAGE i084(zhelp) WITH g_i.
*          CLEAR okcode_100.
*          CALL SCREEN 100.
*        ENDIF.
*
*        IF zmm_prep_rolecrc-p_grp = 'X' AND
*           wa_itemtab-grp IS INITIAL.
*          g_field = 'ZIC_PREP_ROLEREI-P_GRP'.
*          ROLLBACK WORK.
*          MESSAGE i085(zhelp) WITH g_i.
*          CLEAR okcode_100.
*          CALL SCREEN 100.
*        ENDIF.
*
*        IF zmm_prep_rolecrc-app_level = 'X' AND
*          wa_itemtab-approver IS INITIAL.
*          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
*          ROLLBACK WORK.
*          MESSAGE i096(zhelp) WITH g_i.
*          CLEAR okcode_100.
*          CALL SCREEN 100.
*        ENDIF.
*
*      ENDIF.
*
*    ELSE.
*
*      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
*                                                  wa_itemtab-role_name.
*      IF sy-subrc = 0.
*
*        IF zmm_prep_roledes-plant = 'X' AND
*                       ( old_ok_code = 'APPROVE' OR
*                      old_ok_code = 'RELEASE' OR
*                      old_ok_code = 'CHANGE' OR
*                      old_ok_code = 'CREATE' OR
*                      old_ok_code = 'CROSSCO' ) AND
*                      NOT wa_itemtab-role_name IS INITIAL.
*
*          IF wa_itemtab-plant IS INITIAL.
*            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
*            ROLLBACK WORK.
*            MESSAGE i084(zhelp) WITH g_i.
*            CLEAR okcode_100.
*            CALL SCREEN 100.
*          ENDIF.
*        ENDIF.
*
*        IF zmm_prep_roledes-p_grp = 'X' AND
*                       ( old_ok_code = 'APPROVE' OR
*                      old_ok_code = 'RELEASE' OR
*                      old_ok_code = 'CHANGE'  OR
*                      old_ok_code = 'CREATE'  OR
*                      old_ok_code = 'CROSSCO' ) AND
*                      NOT wa_itemtab-role_name IS INITIAL.
*
*          IF wa_itemtab-grp IS INITIAL.
*            g_field = 'ZIC_PREP_ROLEREI-GRP'.
*            ROLLBACK WORK.
*            MESSAGE i085(zhelp) WITH g_i.
*            CLEAR okcode_100.
*            CALL SCREEN 100.
*          ENDIF.
*        ENDIF.
*
*        IF zmm_prep_roledes-s_loc = 'X' AND
*                       ( old_ok_code = 'APPROVE' OR
*                      old_ok_code = 'RELEASE' OR
*                      old_ok_code = 'CHANGE' OR
*                      old_ok_code = 'CREATE' OR
*                      old_ok_code = 'CROSSCO' ) AND
*                      NOT wa_itemtab-role_name IS INITIAL.
*
*          IF wa_itemtab-sloc IS INITIAL.
*            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
*            ROLLBACK WORK.
*            MESSAGE i090(zhelp) WITH g_i.
*            CLEAR okcode_100.
*            CALL SCREEN 100.
*          ENDIF.
*        ENDIF.
*
*        IF zmm_prep_roledes-r_loc = 'X' AND
*                       ( old_ok_code = 'APPROVE' OR
*                      old_ok_code = 'RELEASE' OR
*                      old_ok_code = 'CHANGE' OR
*                      old_ok_code = 'CREATE' OR
*                      old_ok_code = 'CROSSCO' ) AND
*                      NOT wa_itemtab-role_name IS INITIAL.
*
*          IF wa_itemtab-receipt_loc IS INITIAL.
*            g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
*            ROLLBACK WORK.
*            MESSAGE i095(zhelp) WITH g_i.
*            CLEAR okcode_100.
*            CALL SCREEN 100.
*          ENDIF.
*        ENDIF.
*
*        IF zmm_prep_roledes-app_level = 'X' AND
*                       ( old_ok_code = 'APPROVE' OR
*                      old_ok_code = 'RELEASE' OR
*                      old_ok_code = 'CHANGE' OR
*                      old_ok_code = 'CREATE' OR
*                      old_ok_code = 'CROSSCO' ) AND
*                      NOT wa_itemtab-role_name IS INITIAL.
*
*          IF wa_itemtab-approver IS INITIAL.
*            g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
*            ROLLBACK WORK.
*            MESSAGE i096(zhelp) WITH g_i.
*            CLEAR okcode_100.
*            CALL SCREEN 100.
*          ENDIF.
*        ENDIF.
*
*      ENDIF.
*
*    ENDIF.

  ENDIF.
**  if wa_itemtab-rej_fl is initial.
**** Header level changes for integration
**    perform validate_role_approval_level.
**  endif.
** Line item changes for integration call diffrent subs ( def 110 )
*Begin of <RD1K963151>.
*  IF old_ok_code = 'CHANGE' AND sy-ucomm NE 'REQ1'.
**End of <RD1K963151>.
*    PERFORM validate_lineitem_datax.
**Begin of <RD1K963151>.
*  ENDIF.
ENDFORM.                    " CHECK_ITEMS_SAVE_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  ITEMS_APPROVAL_CHECK_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ITEMS_APPROVAL_CHECK_ASSIGN .
  SELECT * FROM ZIC_PREP_ROLEREI INTO TABLE IST_ITEMTAB
  WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
  LOOP AT IST_ITEMTAB INTO WA_ITEMTAB.
    IF WA_ITEMTAB-REJ_FL IS INITIAL.
** Header level changes for integration
      PERFORM VALIDATE_ROLE_APPROVAL_AS.
    ENDIF.
  ENDLOOP.
  CLEAR IST_ITEMTAB.
  REFRESH IST_ITEMTAB[].
  CLEAR WA_ITEMTAB.
**      if sy-subrc = 0.
** Messages to be checked modulewise in sub
  PERFORM CLEAR1.
  IF OLD_OK_CODE = 'CROSSCO' OR
        ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.

    IF OLD_OK_CODE = 'RELEASE' OR
        OLD_OK_CODE = 'CROSSCO' OR
        OLD_OK_CODE = 'CHANGE'.
      PERFORM POPUP_RELEASE_MESSAGE.
    ENDIF.

    IF OLD_OK_CODE = 'APPROVE' OR
       ZIC_PREP_ROLEREQ-STATUS = 'IF'.
*      PERFORM popup_approve_message.
    ENDIF.

    """""""""""""""""""""""""""""""""""""
    " added by lipsy  for cross company on 9.03.2015 RD1K996555
    IF  ZIC_PREP_ROLEREI-MODULEID = 'MM'.
      IF OLD_OK_CODE = 'APPROVE' AND   ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' .

      ELSE.
        "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555
        """"""""""""""""""""""""""""""""""

        PERFORM POP_UP_CROSSCO_MESSAGE.          .
*          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.


        """"""""""""""""""""""""""""""
        "added by lipsy  for cross company on 9.03.2015 RD1K996555

      ENDIF.

    ENDIF.
    "end of addition by lipsy  for cross company on 9.03.2015 RD1K996555
    """"""""""""""""""""""""""""""""""""
  ELSE.
    IF OLD_OK_CODE = 'CRCROLES' OR
      ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
      IF OLD_OK_CODE = 'RELEASE' OR
         OLD_OK_CODE = 'CRCROLES' OR
         OLD_OK_CODE = 'CHANGE'.
        PERFORM POPUP_RELEASE_MESSAGE.
      ENDIF.
      IF OLD_OK_CODE = 'APPROVE' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IF'.
*        PERFORM popup_approve_message.
      ENDIF.
      PERFORM POP_UP_CRC_MESSAGE.
*              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
      MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      G_CRC_FL = 'X'.
    ELSE.
      IF OLD_OK_CODE = 'RELEASE'.
        PERFORM POPUP_RELEASE_MESSAGE.
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ELSEIF OLD_OK_CODE = 'APPROVE'.
*        .               PERFORM popup_approve_message.
*        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE =
'CHANGE'.
        PERFORM POPUP_RELEASE_MESSAGE1.
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ELSEIF ZIC_PREP_ROLEREQ-STATUS = 'IF'.
        PERFORM POPUP_APPROVE_MESSAGE.
      ELSE.
        MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ENDIF.
  ENDIF.
**      endif.
ENDFORM.                    " ITEMS_APPROVAL_CHECK_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_ROLE_APPROVAL_AS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_ROLE_APPROVAL_AS .

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP
       WHERE ROLE_TYPE = WA_ITEMTAB-ROLE_NAME.

  IF SY-SUBRC = 0.

    IF ZMM_PREP_ROLEGRP-APPROVER1 = 'L3' AND
                 G_APPROVER_LEVEL = 'L3'.

    ELSEIF ZMM_PREP_ROLEGRP-APPROVER1 = 'IM' AND
                 G_APPROVER_LEVEL = 'L3'.
      G_APPROVER_LEVEL = 'IM'.
    ELSEIF  ZMM_PREP_ROLEGRP-APPROVER1 = 'L1' AND
                 ( G_APPROVER_LEVEL = 'L3' OR
                   G_APPROVER_LEVEL = 'IM' ).
      G_APPROVER_LEVEL = 'L1'.
    ENDIF.

  ENDIF.
ENDFORM.                    " VALIDATE_ROLE_APPROVAL_AS
*&---------------------------------------------------------------------*
*&      Form  LIST_PROCESSING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_PROCESSING .
  IF GL_ANS = 'J'.
    SUPPRESS DIALOG.
    LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 100.
    PERFORM WRITE_LIST.
    G_LIST_PROC_FLAG = 'X'.
    CLEAR GL_ANS.
  ENDIF.
ENDFORM.                    " LIST_PROCESSING
*&---------------------------------------------------------------------*
*&      Form  WRITE_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_LIST .
  SET PF-STATUS 'STATUS_130' EXCLUDING 'SEL'.

  READ TABLE IT_ROLES1 INTO WA_ROLES1 INDEX 1.  "#EC CI_NOORDER
  G_USERID = WA_ROLES1-USERID.
  L_COLOR = 5.
  LOOP AT IT_ROLES1 INTO WA_ROLES1.
    IF G_USERID = WA_ROLES1-USERID.
      WRITE : / WA_ROLES1-USERID COLOR 1,WA_ROLES1-ROLE_NAME COLOR 2.
    ELSE.
      WRITE : / WA_ROLES1-USERID COLOR 3,WA_ROLES1-ROLE_NAME COLOR 3.
    ENDIF.
    G_USERID = WA_ROLES1-USERID.
  ENDLOOP.
ENDFORM.                    " WRITE_LIST
*&---------------------------------------------------------------------*
*&      Form  FINAL_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FINAL_PROCESS .

  SET PARAMETER ID 'ZROLEREQNO' FIELD ZROLEREQNO.

  CLEAR:V_MODULEID.

  V_MODULEID  = MODULEID.

  EXPORT V_MODULEID TO MEMORY ID 'ID3'.

  CLEAR V_REMARKS_HEAD.
  CONCATENATE ZIC_PREP_ROLEREQ-DOCNO ' - ARMS'
       ' - ' MODULEID ' Module' INTO V_REMARKS_HEAD.
  EXPORT V_REMARKS_HEAD TO MEMORY ID 'ID2'.
  CLEAR ZUSERID.
  MOVE ZIC_PREP_ROLEREQ-USERIDCR TO ZUSERID.
  EXPORT ZUSERID TO MEMORY ID 'ID'.
  CLEAR ZAPPROVER.
  MOVE ZIC_PREP_ROLEREQ-USERIDAP TO ZAPPROVER.
  EXPORT ZAPPROVER TO MEMORY ID 'ID1'.

  CLEAR:V_MESSAGE_AS.
  PERFORM ROLE_HELP.
  GET PARAMETER ID 'ZROLEREQNO' FIELD ZROLEREQNO.

  IF NOT ZROLEREQNO IS INITIAL AND ZROLEREQNO <> '00000000'.

    SUBMIT ZBC_ROLE_REP01_RFC AND RETURN.

    MESSAGE I056(ZBC) WITH ZIC_PREP_ROLEREQ-DOCNO.

    G_ROLE_FLAG = 'X'.
    ZIC_PREP_ROLEREQ-STATUS = 'IR'.

    PERFORM SAVE_REQUEST_ASSIGN.
    IF ZIC_PREP_ROLEREQ-STATUS = 'IF' OR
     ZIC_PREP_ROLEREQ-STATUS = 'N'.
    ELSE.
      PERFORM SEND_SAPMAIL_ASSIGN .

    ENDIF.
    PERFORM CLEAR_ASSIGN.
    REFRESH OBJECT_CONTENT.
  ENDIF.
  IF V_MESSAGE_AS = 'X'.
    PERFORM SAVE_REQUEST_ASSIGN.
    PERFORM SEND_SAPMAIL_ASSIGN .

    V_MESSAGE_UNAS = 'All roles already assigned or do not exist.'.

    MESSAGE I735(ZMM) WITH V_MESSAGE_UNAS.
  ELSE.
  ENDIF.

  LEAVE PROGRAM.

ENDFORM.                    " FINAL_PROCESS
*&---------------------------------------------------------------------*
*&      Form  ROLE_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ROLE_HELP .
  DATA: UPL_COUNT TYPE I.
  DATA: XFLAG(1).
  DATA: XXCPF_NO LIKE ZAUTH_ITEM-CPF_NO.
  DATA: XXROLE LIKE ZAUTH_ITEM-ROLE.


  DATA: XXFROM_DAT LIKE ZAUTH_ITEM-FROM_DAT .
  DATA: XXTO_DAT LIKE ZAUTH_ITEM-TO_DAT .
  DATA: L_AGR_USERS LIKE TABLE OF AGR_USERS WITH HEADER LINE .


  DATA : DATEO(10), DATE LIKE SY-DATUM.
  DATA : ZUSERID LIKE ZAUTH_HEAD-REQUESTED_BY.
  DATA : ZAPPROVER LIKE ZAUTH_HEAD-APPROVED_BY.
  DATA:V_REMARKS_HEAD TYPE ZAUTH_HEAD-REMARKS,
       V_MODULEID(3).

  ZAUTH_HEAD-AUTH_REQ_DATE = SY-DATUM.

  IMPORT  V_MODULEID TO  V_MODULEID FROM MEMORY ID 'ID3'.
  ZAUTH_HEAD-PRIMOD = V_MODULEID.

  IMPORT V_REMARKS_HEAD TO V_REMARKS_HEAD FROM MEMORY ID 'ID2'.


  ZAUTH_HEAD-REMARKS  = V_REMARKS_HEAD.

  IMPORT ZUSERID TO ZUSERID FROM MEMORY ID 'ID'.
  ZAUTH_HEAD-REQUESTED_BY  = ZUSERID.

  IMPORT ZAPPROVER TO ZAPPROVER FROM MEMORY ID 'ID1'.
  ZAUTH_HEAD-APPROVED_BY = ZAPPROVER.


  CLEAR UPL_TAB. REFRESH UPL_TAB.
  CLEAR UPL_TABX. REFRESH UPL_TABX.




  CLEAR:WA_ROLES1.
  LOOP AT IT_ROLES1 INTO WA_ROLES1.
    UPL_TABX-CPF_NO = WA_ROLES1-USERID.
    UPL_TABX-ROLE = WA_ROLES1-ROLE_NAME.
    UPL_TABX-FROM_DAT = WA_ROLES1-FR_DATE_AUTH.
    UPL_TABX-TO_DAT  = WA_ROLES1-TO_DATE_AUTH.
    APPEND  UPL_TABX.
  ENDLOOP.

  LOOP AT UPL_TABX.

    UPL_TAB-CPF_NO = UPL_TABX-CPF_NO.
    UPL_TAB-ROLE   = UPL_TABX-ROLE.

*******************************************************
    DATEO = UPL_TABX-FROM_DAT.
    CONCATENATE DATEO+6(4) DATEO+3(2) DATEO+0(2) INTO DATE.
***************************************************
    UPL_TAB-FROM_DAT   = DATE.

    CLEAR : DATEO, DATE.

    DATEO = UPL_TABX-TO_DAT.
    CONCATENATE DATEO+6(4) DATEO+3(2) DATEO+0(2) INTO DATE.

    UPL_TAB-TO_DAT   = DATE.

    CLEAR : DATEO, DATE.


***************************************************

    APPEND UPL_TAB.

  ENDLOOP.
***********************
  REFRESH UPL_TABX.
  CLEAR   UPL_TABX.
***********************
  IF SY-SUBRC EQ 0.
    XXCPF_NO = 'XX'.
    XXROLE   = 'XX'.
*******************************************************
    LOOP AT UPL_TAB.
      TRANSLATE UPL_TAB TO UPPER CASE.
      MODIFY UPL_TAB.
    ENDLOOP.
***********************************************************************
    LOOP AT UPL_TAB.
      IF UPL_TAB-CPF_NO EQ SPACE AND
         UPL_TAB-ROLE EQ SPACE.
        DELETE UPL_TAB.
        CONTINUE.
      ENDIF.
      IF UPL_TAB-CPF_NO EQ SPACE.
        UPL_TAB-CPF_NO = XXCPF_NO.
      ENDIF.
      IF UPL_TAB-ROLE EQ SPACE.
        UPL_TAB-ROLE  = XXROLE.
      ENDIF.

      IF UPL_TAB-FROM_DAT EQ '00000000' .
        UPL_TAB-FROM_DAT = SY-DATUM .
      ENDIF .
      IF UPL_TAB-TO_DAT EQ '00000000' .
        UPL_TAB-TO_DAT = '99991231' .
      ENDIF .


      MODIFY UPL_TAB.
      XXCPF_NO = UPL_TAB-CPF_NO.
      XXROLE   = UPL_TAB-ROLE.
    ENDLOOP.
    SORT UPL_TAB.
    DELETE ADJACENT DUPLICATES FROM UPL_TAB.

    LOOP AT UPL_TAB.
      XFLAG = 'N'.
      UPL_TABX-CPF_NO = UPL_TAB-CPF_NO.
      UPL_TABX-ROLE   = UPL_TAB-ROLE.

      UPL_TABX-FROM_DAT = UPL_TAB-FROM_DAT.
      UPL_TABX-TO_DAT   = UPL_TAB-TO_DAT.


      SELECT SINGLE * FROM USR02 WHERE
           BNAME = UPL_TAB-CPF_NO.
      IF SY-SUBRC NE 0.
        UPL_TABX-USER_NA = 'X'.
      ENDIF.

      SELECT SINGLE * FROM AGR_DEFINE WHERE
         AGR_NAME = UPL_TAB-ROLE.
      IF SY-SUBRC NE 0.
        UPL_TABX-ROLE_NA = 'X'.
      ENDIF.


      IF UPL_TABX-USER_NA = 'X'.
        DELETE UPL_TAB.

        CLEAR UPL_TABX.
        CONTINUE.
      ELSE .

        SELECT AGR_NAME UNAME FROM_DAT TO_DAT INTO CORRESPONDING FIELDS
        OF TABLE L_AGR_USERS FROM AGR_USERS
        WHERE AGR_NAME = UPL_TABX-ROLE AND UNAME = UPL_TABX-CPF_NO .

        IF SY-SUBRC  EQ 0 .
          SORT L_AGR_USERS BY TO_DAT ASCENDING .
          CLEAR L_AGR_USERS .
          LOOP AT L_AGR_USERS .
            IF L_AGR_USERS-FROM_DAT <= UPL_TABX-FROM_DAT AND
               L_AGR_USERS-TO_DAT >= UPL_TABX-TO_DAT .
              XFLAG = 'X'.
              EXIT.
            ELSE .
              IF L_AGR_USERS-FROM_DAT <= UPL_TABX-FROM_DAT AND
                 L_AGR_USERS-TO_DAT >= UPL_TABX-FROM_DAT .
                UPL_TAB-FROM_DAT = L_AGR_USERS-TO_DAT .
                MODIFY UPL_TAB .
              ENDIF .
              IF L_AGR_USERS-FROM_DAT <= UPL_TABX-TO_DAT AND
                 L_AGR_USERS-TO_DAT >= UPL_TABX-TO_DAT .
                UPL_TAB-TO_DAT = L_AGR_USERS-FROM_DAT .
                MODIFY UPL_TAB .
              ENDIF .
            ENDIF .
          ENDLOOP .
        ENDIF .
**
        CLEAR UPL_TABX.
      ENDIF.
      IF XFLAG = 'X'.
        DELETE UPL_TAB.
      ENDIF.
      CLEAR UPL_TABX.

    ENDLOOP.
  ENDIF.
  LOOP AT UPL_TAB.
    MOVE-CORRESPONDING UPL_TAB TO G_ROLE_ITAB.
    G_ROLE_ITAB-ITEM_NO = ZITEM_NO.
    APPEND G_ROLE_ITAB.
    ZITEM_NO = ZITEM_NO + 1.
  ENDLOOP.


***************************************************************
***************************************************************

  """""""""""""""""""""""""""
  """"""""for text
  LOOP AT G_ROLE_ITAB.

    SELECT SINGLE * FROM USR21 WHERE BNAME = G_ROLE_ITAB-CPF_NO.
    SELECT NAME_TEXT INTO G_ROLE_ITAB-USER_NAME
 FROM ADRP UP TO 1 ROWS WHERE PERSNUMBER = USR21-PERSNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    SELECT TEXT INTO G_ROLE_ITAB-TEXT
 FROM AGR_TEXTS UP TO 1 ROWS WHERE AGR_NAME = G_ROLE_ITAB-ROLE AND SPRAS = 'EN'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF SY-SUBRC = 0.
    ELSE.
      DELETE G_ROLE_ITAB WHERE ROLE = G_ROLE_ITAB-ROLE.
    ENDIF.
    MODIFY G_ROLE_ITAB.
  ENDLOOP.
  """""""""""""""""""""""""""""
  """"""""""""""""""""""""

  """"""""""""""""


  IF  G_ROLE_ITAB[]  IS  NOT INITIAL.
***********************************************************************
    IF ZAUTH_HEAD-AUTH_REQ_NO IS INITIAL.


      PERFORM GET_NEXT_NUMBER_ASN.

      ZAUTH_HEAD-AUTH_REQ_NO = ZGET_NUMBER.

    ENDIF.
    MODIFY ZAUTH_HEAD.


    SET PARAMETER ID 'ZROLEREQNO' FIELD ZGET_NUMBER.

******************************************************************

    ZAUTH_ITEM-AUTH_REQ_NO = ZAUTH_HEAD-AUTH_REQ_NO.
    ZITEM_NO = 1.
    DELETE FROM ZAUTH_ITEM
       WHERE AUTH_REQ_NO = ZAUTH_HEAD-AUTH_REQ_NO.

***************************Added by Abhishek - Delimit existing roles.
    IF IT_AGR IS NOT INITIAL.

      CLEAR S_ITAB.
      LOOP AT G_ROLE_ITAB.
        MOVE-CORRESPONDING G_ROLE_ITAB TO S_ITAB.
      ENDLOOP.

      LOOP AT IT_AGR INTO WA_AGR WHERE AGR_NAME NE 'M:COMMON_USER_TOOLS'.
        S_ITAB-ITEM_NO = S_ITAB-ITEM_NO + 1.
        G_ROLE_ITAB-ITEM_NO = S_ITAB-ITEM_NO.
        G_ROLE_ITAB-CPF_NO = S_ITAB-CPF_NO.
        G_ROLE_ITAB-ROLE = WA_AGR-AGR_NAME.
        G_ROLE_ITAB-TEXT = WA_AGR-AGR_TEXT.
        G_ROLE_ITAB-USER_NAME = S_ITAB-USER_NAME.
        G_ROLE_ITAB-FROM_DAT = WA_AGR-FROM_DAT.
        G_ROLE_ITAB-TO_DAT = SY-DATUM.
        APPEND G_ROLE_ITAB.
      ENDLOOP.

    ENDIF.
****************************************************End of addition by Abhishek

    LOOP AT G_ROLE_ITAB.
      IF G_ROLE_ITAB-CPF_NO NE SPACE AND
         G_ROLE_ITAB-ROLE NE SPACE .

        ZAUTH_ITEM-FROM_DAT = G_ROLE_ITAB-FROM_DAT .
        ZAUTH_ITEM-TO_DAT = G_ROLE_ITAB-TO_DAT .
************************************************************************
        ZAUTH_ITEM-CPF_NO = G_ROLE_ITAB-CPF_NO.
        ZAUTH_ITEM-ROLE = G_ROLE_ITAB-ROLE.
        ZAUTH_ITEM-ITEM_NO = ZITEM_NO.
        ZITEM_NO = ZITEM_NO + 1.
        MODIFY ZAUTH_ITEM.
      ENDIF.
    ENDLOOP.
    ZAUTH_EXCP-AUTH_REQ_NO = ZAUTH_HEAD-AUTH_REQ_NO.

    LOOP AT UPL_TABX.
      ZAUTH_EXCP-CPF_NO = UPL_TABX-CPF_NO.
      ZAUTH_EXCP-ROLE   = UPL_TABX-ROLE.
      ZAUTH_EXCP-REMARKS = UPL_TABX-REMARKS.
      ZAUTH_EXCP-ROLE_NA = UPL_TABX-ROLE_NA.
      ZAUTH_EXCP-USER_NA = UPL_TABX-USER_NA.
      MODIFY ZAUTH_EXCP.
    ENDLOOP.

  ELSE.
    V_MESSAGE_AS = 'X'.
  ENDIF.
************************************************************************
ENDFORM.                    " ROLE_HELP
*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_NUMBER_ASN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_NEXT_NUMBER_ASN .
  DATA: RC         LIKE INRI-RETURNCODE.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR = '01'
      OBJECT      = 'ZROLEREQ'
      QUANTITY    = '1'
*     SUBOBJECT   = ' '
*     TOYEAR      = '0000'
*     IGNORE_BUFFER                 = ' '
    IMPORTING
      NUMBER      = ZGET_NUMBER
*     QUANTITY    =
      RETURNCODE  = RC
* EXCEPTIONS
*     INTERVAL_NOT_FOUND            = 1
*     NUMBER_RANGE_NOT_INTERN       = 2
*     OBJECT_NOT_FOUND              = 3
*     QUANTITY_IS_0                 = 4
*     QUANTITY_IS_NOT_1             = 5
*     INTERVAL_OVERFLOW             = 6
*     BUFFER_OVERFLOW               = 7
*     OTHERS      = 8
    .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " GET_NEXT_NUMBER_ASN
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_OLM_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_OLM_ASSIGN .
  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  SORT G_TC_117_ITAB
  BY ROLE_NAME.

  DELETE ADJACENT DUPLICATES FROM G_TC_117_ITAB
    COMPARING ROLE_NAME.

  LOOP AT G_TC_117_ITAB INTO G_TC_117_WA .

    MOVE-CORRESPONDING G_TC_117_WA TO WA_ITEMTAB.

    IF G_ROLE_FLAG = 'X' AND WA_ITEMTAB-REJ_FL = '' AND
         WA_ITEMTAB-STATUS = '' AND WA_ITEMTAB-ROLE_REQUEST = ''.
      WA_ITEMTAB-ROLE_REQUEST = ZROLEREQNO.
    ENDIF.

    IF OLD_OK_CODE = 'CREATE'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

*    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

  IF G_LINES_RL = 0.
    IF OLD_OK_CODE = 'CHANGE'.
      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM ZIC_PREP_ROLEREI WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
        AND MODULEID = MODULEID.

    MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.

    IF SY-SUBRC = 0 AND G_ROLE_FLAG <> 'X'.
      MESSAGE I045(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_OLM_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  CLEAR_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_ASSIGN .
  PERFORM DESTROY_CTRL.

  OKCODE_100_P = OKCODE_100. " + BY BIPIN TO VALIDATE POP UP MESSAGE

  CLEAR   : OLD_OK_CODE, OKCODE_100, ERR_FLG.
  REFRESH : G_TABLCTRL110_ITAB[].
  CLEAR   : G_TABLCTRL110_ITAB.
  REFRESH : G_TABLCTRL111_ITAB[].
  CLEAR   : G_TABLCTRL111_ITAB.
  REFRESH : G_TABLCTRL112_ITAB[].
  CLEAR   : G_TABLCTRL112_ITAB.
  REFRESH : G_TABLCTRL113_ITAB[].
  CLEAR   : G_TABLCTRL113_ITAB.
  REFRESH : G_TABLCTRL114_ITAB[].
  CLEAR   : G_TABLCTRL114_ITAB.
  REFRESH : G_TABLCTRL115_ITAB[].
  CLEAR   : G_TABLCTRL115_ITAB.
  CLEAR   : SY-UCOMM.
  CLEAR   : G_CURR_LINE.
  CLEAR SET_DISC_MM_FLAG.
  CLEAR SET_DISC_FI_FLAG.
  CLEAR   : ZIC_PREP_ROLEREI.
  CLEAR   : IT_TAB.
  REFRESH : TLINETAB1[],TLINETAB2[].
  CLEAR   : T500P-NAME1.
  CLEAR   : CRC_CHECK_FL.
  CLEAR   : HELP_LIST_FLAG.
  REFRESH : IT_M_FISTB.
  CLEAR   : MODULEID.
ENDFORM.                    " CLEAR_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ITEMS_SRM .
  DATA : I LIKE SY-INDEX .
  CLEAR : WA_ITEMTAB, IST_ITEMTAB.

  SORT G_TABLCTRL118_ITAB
  BY ROLE_NAME PLANT GRP  SLOC RECEIPT_LOC APPROVER.

  DELETE ADJACENT DUPLICATES FROM G_TABLCTRL118_ITAB
    COMPARING ROLE_NAME PLANT GRP  SLOC RECEIPT_LOC APPROVER REJ_FL
    ROLE_TYPE_EX CRC_POS.

  LOOP AT G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA.

    MOVE-CORRESPONDING G_TABLCTRL118_WA TO WA_ITEMTAB.

    IF OLD_OK_CODE = 'CREATE' OR
       OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.
      WA_ITEMTAB-DOCNO = ZDOCNUMB.
    ENDIF.

    WA_ITEMTAB-MANDT = SY-MANDT.
    IF WA_ITEMTAB-REJ_FL <> ''.
      WA_ITEMTAB-REJ_FL_SAVE = 'X'.
    ENDIF.
    IF NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.
      I = I + 1.
      WA_ITEMTAB-SRNO = I .
      APPEND WA_ITEMTAB TO IST_ITEMTAB.
    ENDIF.

    G_I = I.

    SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                                                     WA_ITEMTAB-ROLE_NAME.
    IF SY-SUBRC = 0.



      IF ZSR_PREP_ROLEDES-P_GRP = 'X' AND
                     ( OLD_OK_CODE = 'APPROVE' OR
                    OLD_OK_CODE = 'RELEASE' OR
                    OLD_OK_CODE = 'CHANGE'  OR
                    OLD_OK_CODE = 'CREATE'  OR
                    OLD_OK_CODE = 'CROSSCO' ) AND
                    NOT WA_ITEMTAB-ROLE_NAME IS INITIAL.

        IF WA_ITEMTAB-GRP IS INITIAL.
          G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
          ROLLBACK WORK.
          MESSAGE I085(ZHELP) WITH G_I.
          CLEAR OKCODE_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR:COUNT_GRP,G_WA_PGRP.

    LOOP AT G_TABLCTRL118_ITAB INTO G_WA_PGRP WHERE  GRP = WA_ITEMTAB-GRP  .
      IF G_WA_PGRP-GRP  IS NOT INITIAL.
        COUNT_GRP = COUNT_GRP + 1.
      ENDIF.
    ENDLOOP.
    IF  COUNT_GRP > '1'.
      MESSAGE I092(ZHELP) .
      CLEAR OKCODE_100.
      CALL SCREEN 100.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE IST_ITEMTAB LINES G_LINES_RL.

***added g_reset_fl to check resetting & no rollback
  IF G_LINES_RL = 0 .
    ROLLBACK WORK.
    IF OLD_OK_CODE = 'CHANGE'.

      IF SY-SUBRC = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE I099(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
      ENDIF.
    ELSEIF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' .
      MESSAGE I103(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
      ROLLBACK WORK.
      MESSAGE I089(ZHELP).
    ELSE.

      IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO'
.
      ELSEIF OLD_OK_CODE <> 'DISPLAY'.
        DELETE FROM ZIC_PREP_ROLEREI WHERE
        DOCNO = ZIC_PREP_ROLEREQ-DOCNO AND
        MODULEID = MODULEID..
      ENDIF.

      MODIFY ZIC_PREP_ROLEREI FROM TABLE IST_ITEMTAB.


    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_SRM
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ROLES_SRM .
  CLEAR:L_LOGSYS.



  SELECT SINGLE LOGSYS FROM ZMM_LOGSYS INTO L_LOGSYS
  WHERE  APPL = 'SRM'.

  """"""calling srm

  IF NOT L_LOGSYS  IS INITIAL.

    LOOP AT   G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA.

      WA_ROLES_SRMP-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES_SRMP-ROLE_NAME = G_TABLCTRL118_WA-ROLE_NAME.
      WA_ROLES_SRMP-CCODE = ZIC_PREP_ROLEREQ-CCODE.
      WA_ROLES_SRMP-FROM_DAT = SY-DATUM.
      WA_ROLES_SRMP-TO_DAT   = '99991231'.
      WA_ROLES_SRMP-GRP =  G_TABLCTRL118_WA-GRP.
      APPEND  WA_ROLES_SRMP TO IT_ROLES_SRMP.

    ENDLOOP.




    P_UNAME = ZIC_PREP_ROLEREQ-USERID.

    SELECT SINGLE * FROM ZBCUSRMST  INTO CORRESPONDING FIELDS OF WA_ZBCUSRMST
      WHERE CPFNO = ZIC_PREP_ROLEREQ-USERID.

    P_FNAME        = WA_ZBCUSRMST-FIRST_NAME.
    P_LNAME        = WA_ZBCUSRMST-LAST_NAME.
    P_CCODE =    ZIC_PREP_ROLEREQ-CCODE.






    CALL FUNCTION 'ZSRM_ROLE_ASSIGN_ARMS' DESTINATION L_LOGSYS
      EXPORTING
        P_UNAME       = P_UNAME
        P_FNAME       = P_FNAME
        P_LNAME       = P_LNAME
        P_CCODE       = P_CCODE
      TABLES
        IT_ROLES_SRMP = IT_ROLES_SRMP
        ITAB_RETURN   = ITAB_RETURN.

    IF ITAB_RETURN[] IS NOT INITIAL.

      V_SRM_ST = 'C'.

      LOOP AT ITAB_RETURN INTO WA_RETURN.

        IF   WA_RETURN-STATUS NE  'C'.
          V_SRM_ST = 'IF'.
        ELSE.

        ENDIF.
      ENDLOOP.

      IF  V_SRM_ST = 'C'.
        ZIC_PREP_ROLEREQ-STATUS = 'C'.

      ELSE.
        ZIC_PREP_ROLEREQ-STATUS = 'IF'.
        PERFORM SEND_SAPMAIL_SRMASSIGN .
      ENDIF.


      V_ROLEREQ-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      P_UNAME_SMS = P_UNAME.
      G_USERID_N = ''.
      MODIFY ZIC_PREP_ROLEREQ FROM ZIC_PREP_ROLEREQ.
      IF SY-SUBRC = 0.
        IF  ZIC_PREP_ROLEREQ-STATUS = 'C'.

          CALL FUNCTION 'ZMM_SEND_SMS'
            EXPORTING
              CPFNO_S     = G_USERID_N
              CPFNO_R     = P_UNAME_SMS
              FROM_DAT    = SY-DATUM
              TO_DAT      = '99991231'
              AUTH_REQ_NO = V_ROLEREQ-DOCNO
            IMPORTING
              FLAG_MSG    = L_FLAG_MSG.

          PERFORM SEND_SAPMAIL_SRMASSIGN .

        ENDIF.
      ENDIF.


    ELSE.
      IF  V_SRM_ST = ''.
        ZIC_PREP_ROLEREQ-STATUS = 'N'.
        MODIFY ZIC_PREP_ROLEREQ FROM ZIC_PREP_ROLEREQ.
      ENDIF.

    ENDIF.

    PERFORM UNLOCK_RECORD.

    CLEAR:V_MESSAGE_SRM.
    IF ZIC_PREP_ROLEREQ-STATUS = 'C'.

      CONCATENATE 'Roles assigned for request No .' ZIC_PREP_ROLEREQ-DOCNO INTO
      V_MESSAGE_SRM SEPARATED BY SPACE.

      MESSAGE I735(ZMM) WITH V_MESSAGE_SRM.

    ELSE.

      CONCATENATE 'Roles not  assigned for request No .' ZIC_PREP_ROLEREQ-DOCNO INTO
   V_MESSAGE_SRM SEPARATED BY SPACE.

      MESSAGE I735(ZMM) WITH V_MESSAGE_SRM.
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
FORM SEND_SAPMAIL_SRMASSIGN .
  DOCUMENT_DATA-OBJ_LANGU  = SY-LANGU.
  DOCUMENT_DATA-OBJ_NAME   = 'ICE Core Team'.
  DOCUMENT_DATA-OBJ_DESCR  = 'Mail from ICE Core Team'.

  CONCATENATE DOCUMENT_DATA-OBJ_DESCR '---' MODULEID
  '-' 'Module' INTO DOCUMENT_DATA-OBJ_DESCR.
  DOCUMENT_DATA-PRIORITY   = '3'.

* Remove prefix 'US' from receiver
  REFRESH RECEIVERS.

  CLEAR WA_RECEIVERS.
  WA_RECEIVERS-RECEIVER = ZIC_PREP_ROLEREQ-USERIDCR.
  WA_RECEIVERS-REC_TYPE = 'B'.
  WA_RECEIVERS-EXPRESS  = 'X'.
  APPEND WA_RECEIVERS TO RECEIVERS.

  CLEAR WA_RECEIVERS.

  MOVE SPACE TO OBJECT_CONTENT-LINE.
  APPEND OBJECT_CONTENT.

  CONCATENATE  'Subject: '  'Creation of Roles for userid '
ZIC_PREP_ROLEREQ-USERID INTO  OBJECT_CONTENT-LINE
SEPARATED BY SPACE.
  APPEND OBJECT_CONTENT.

  MOVE SPACE TO OBJECT_CONTENT-LINE.
  APPEND OBJECT_CONTENT.
  IF ZIC_PREP_ROLEREQ-STATUS = 'C'.


    CONCATENATE 'Please  check  your role request  which  has'
     'been assigned  &  completed - ' ZIC_PREP_ROLEREQ-DOCNO INTO
OBJECT_CONTENT-LINE
SEPARATED BY SPACE.
    APPEND OBJECT_CONTENT.
  ELSE.

  ENDIF.
********************************************************************
  """"""""""""""""""""""
  IF ZIC_PREP_ROLEREQ-STATUS = 'IF'.

    CONCATENATE ' Roles are not assigned for Request no.- ' ZIC_PREP_ROLEREQ-DOCNO INTO
OBJECT_CONTENT-LINE
SEPARATED BY SPACE.

    APPEND OBJECT_CONTENT.
  ENDIF.
  """""""""""""""""""""""""""""
********************************************************************
  MOVE SPACE TO OBJECT_CONTENT-LINE.
  APPEND OBJECT_CONTENT.

  OBJECT_CONTENT-LINE = 'ICE Core Team'.
  APPEND OBJECT_CONTENT.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = DOCUMENT_DATA
      DOCUMENT_TYPE              = 'RAW'
      PUT_IN_OUTBOX              = 'X'
    IMPORTING
      SENT_TO_ALL                = SENT_TO_ALL
    TABLES
      OBJECT_HEADER              = OBJHEAD
      OBJECT_CONTENT             = OBJECT_CONTENT
      RECEIVERS                  = RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 01
      DOCUMENT_NOT_SENT          = 02
      DOCUMENT_TYPE_NOT_EXIST    = 03
      OPERATION_NO_AUTHORIZATION = 04
      PARAMETER_ERROR            = 05
      X_ERROR                    = 06
      ENQUEUE_ERROR              = 07.

  CASE SY-SUBRC.
    WHEN 0.

*      MESSAGE i060(zhelp) WITH zic_prep_rolereq-useridcr.
    WHEN '01'.
      RAISE TOO_MANY_RECEIVERS.
    WHEN '02'.
      RAISE DOCUMENT_NOT_SENT.
    WHEN '03'.
      RAISE DOCUMENT_TYPE_NOT_EXIST.
    WHEN '04'.
      RAISE OPERATION_NO_AUTHORIZATION.
    WHEN '05'.
      RAISE PARAMETER_ERROR.
    WHEN '06'.
      RAISE X_ERROR.
    WHEN '07'.
      RAISE ENQUEUE_ERROR.
  ENDCASE.

ENDFORM.                    " SEND_SAPMAIL_SRMASSIGN
*&---------------------------------------------------------------------*
*&      Form  insert_data_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_HS.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'CCC'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  IF FLAG <> 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  CLEAR FLAG.

*
ENDFORM.                    " insert_data_hs
*&---------------------------------------------------------------------*
*&      Form  insert_data_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_PM.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'XXXX'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'YYY' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'XXXX' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  IF FLAG <> 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  CLEAR FLAG.

*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  insert_data_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_PP.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'XXXX'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'XXXX'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'XXXX' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'YYYY'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'YYYY'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'YYYY' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'AAAA'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
         ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
         PLANT     = WA_ITEMTAB_SL-PLANT    AND
         PLANT_GEN = 'AAAA'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'AAAA' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'BBBB'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'BBBB'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'BBBB' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'CCCC'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'CCCC'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'CCCC' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'DDDD'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'DDDD'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'DDDD' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'EEEE'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'EEEE'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'EEEE' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'FFFF'.
  IF SY-SUBRC = 0.

    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'FFFF'.
    IF SY-SUBRC = 0.
*      wa_flag = 'X'.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      REPLACE 'FFFF' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ELSE.
*      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.

*  IF wa_flag <> 'X' AND wa_flag1 <> 'X'.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'ZZZZ'.
  IF SY-SUBRC <> 0.
*      CLEAR :wa_flag, wa_flag1.
    SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
         ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
         PLANT     = WA_ITEMTAB_SL-PLANT.
    IF SY-SUBRC = 0.
      WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
      WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.
  ELSE.
  ENDIF.
*  ENDIF.

  IF WA_ITEMTAB_SL-ROLE_NAME = 'PP3'.

    SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'ZZZZ'.
    IF SY-SUBRC = 0.
      SELECT SINGLE * FROM ZPP_PREP_GENERIC WHERE
           ROLE_TYPE = WA_ITEMTAB_SL-ROLE_NAME AND
           PLANT     = WA_ITEMTAB_SL-PLANT    AND
           PLANT_GEN = 'AAAA'.
      IF SY-SUBRC = 0.
        WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
        WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
        REPLACE 'ZZZZ' WITH WA_ITEMTAB_SL-PLANT INTO WA_ROLES1-ROLE_NAME.
*        SELECT SINGLE * FROM zpp_prep_res WHERE
*             role_type = wa_itemtab_sl-role_name AND
*             plant     = wa_itemtab_sl-plant     AND
*             res       = wa_itemtab_sl-res.
*        CONCATENATE wa_roles1-role_name zpp_prep_res-res_code INTO
*        wa_roles1-role_name.
*        APPEND wa_roles1 TO it_roles1.
      ENDIF.
    ENDIF.

  ENDIF.

*  CLEAR : wa_flag, wa_flag1.

ENDFORM.                    " insert_data_pp
FORM INSERT_DATA1_PP.

*  IF wa_rolesz_pp-role_name = 'PP1' OR
*     wa_rolesz_pp-role_name = 'PP2' OR
*     wa_rolesz_pp-role_name = 'PP10'.
*    SELECT * FROM  zhelp_pproles1 INTO TABLE it_roles1_pp_tmp WHERE
*    role_type = wa_rolesz_pp-role_name AND
*    plant = wa_rolesz_pp-plant.
*    IF sy-subrc = 0.
*      LOOP AT it_roles1_pp_tmp INTO wa_roles1_pp.
*        wa_roles1-userid = zic_prep_rolereq-userid.
*        wa_roles1-role_name = wa_roles1_pp-role_name.
*        APPEND wa_roles1 TO it_roles1.
*      ENDLOOP.
*    ENDIF.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  insert_data_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_QM.
  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'XXXX'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    IF WA_ITEMTAB_SL-ROLE_NAME = 'Q1'.
      SELECT SINGLE * FROM ZQM_PREP_LOC WHERE
             PLANT = WA_ITEMTAB_SL-PLANT.
      IF SY-SUBRC = 0.
        REPLACE 'XXXX' WITH ZQM_PREP_LOC-LOC INTO
                                 WA_ROLES1-ROLE_NAME.
      ELSE.
        REPLACE 'XXXX' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                 WA_ROLES1-ROLE_NAME.
      ENDIF.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'YYYY'.

  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    IF WA_ITEMTAB_SL-ROLE_NAME = 'Q2'.
*      IF  wa_itemtab_sl-asset_qm <> ''.
*        REPLACE 'YYYY' WITH wa_itemtab_sl-asset_qm INTO
*                                    wa_roles1-role_name.
*      ELSE.
      REPLACE 'YYYY' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
*      ENDIF.
      APPEND WA_ROLES1 TO IT_ROLES1.
    ENDIF.
  ENDIF.

  IF WA_ITEMTAB_SL-ROLE_NAME = 'Q3'.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  IF FLAG <> 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  CLEAR FLAG.

ENDFORM.                    " insert_data_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_SD.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'XXXX'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'XXXX' WITH WA_ITEMTAB_SL-SALE_ORG INTO
                             WA_ROLES1-ROLE_NAME.
    REPLACE 'ZZ' WITH WA_ITEMTAB_SL-DIV INTO
                             WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'YYYY'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    IF WA_ITEMTAB_SL-ROLE_NAME = 'S2'.
      IF WA_ITEMTAB_SL-DIV = 'GA' AND
         ( WA_ITEMTAB_SL-SHIP_POINT = 'GAIL' OR
           WA_ITEMTAB_SL-SHIP_POINT = 'HBJ' ).
        REPLACE 'YYYY' WITH WA_ITEMTAB_SL-SALE_ORG INTO
                                   WA_ROLES1-ROLE_NAME.
      ELSE.
        REPLACE 'YYYY' WITH WA_ITEMTAB_SL-SHIP_POINT INTO
                                    WA_ROLES1-ROLE_NAME.
      ENDIF.
    ENDIF.
    REPLACE 'ZZ' WITH WA_ITEMTAB_SL-DIV INTO
                                WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'PPPP'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'PPPP' WITH WA_ITEMTAB_SL-PLANT INTO
                                  WA_ROLES1-ROLE_NAME.
    IF WA_ITEMTAB_SL-ROLE_NAME = 'S7A'.
      REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
    ENDIF.
*    SELECT SINGLE * FROM zsd_prep_level WHERE plant = wa_itemtab_sl-plant
*.
*    IF sy-subrc = 0 AND wa_itemtab_sl-role_name = 'S7'.
*      REPLACE 'LL' WITH zsd_prep_level-level_ex INTO
*                                wa_roles1-role_name.
*    ELSE.
    REPLACE 'ZZ' WITH WA_ITEMTAB_SL-DIV INTO
                              WA_ROLES1-ROLE_NAME.
*    ENDIF.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  IF WA_ITEMTAB_SL-ROLE_NAME = 'SXX'.
*    SELECT SINGLE * FROM zsd_prep_area WHERE
*                  sale_org = wa_itemtab_sl-sale_org.
*    IF sy-subrc = 0.
*      flag = 'X'.
*      wa_roles1-userid = zic_prep_rolereq-userid.
*      wa_roles1-role_name = wa_itemtab_sl-role_name.
*      REPLACE 'AAA' WITH zsd_prep_area-area INTO
*                                wa_roles1-role_name.
*      APPEND wa_roles1 TO it_roles1.
*    ENDIF.
  ENDIF.

  IF FLAG <> 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  CLEAR FLAG.

ENDFORM.                    " insert_data_sd
*&---------------------------------------------------------------------*
*&      Form  insert_data_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_DATA_PS.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'CCC'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
                               WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'AAA'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'AAA' WITH WA_ITEMTAB_SL-ASSET INTO
                                WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'BBB'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'BBB' WITH WA_ITEMTAB_SL-BASIN INTO
                                WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'XXYY'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'XX' WITH WA_ITEMTAB_SL-PROJECT INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'YY' WITH WA_ITEMTAB_SL-LOCATION INTO
                                WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  SEARCH WA_ITEMTAB_SL-ROLE_NAME FOR 'ZZZ'.
  IF SY-SUBRC = 0.
    FLAG = 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    REPLACE 'ZZZ' WITH 'ALL' INTO
                                WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  IF FLAG <> 'X'.
    WA_ROLES1-USERID = ZIC_PREP_ROLEREQ-USERID.
    WA_ROLES1-ROLE_NAME = WA_ITEMTAB_SL-ROLE_NAME.
    APPEND WA_ROLES1 TO IT_ROLES1.
  ENDIF.

  CLEAR FLAG.

ENDFORM.                    " insert_data_ps
*&---------------------------------------------------------------------*
*&      Form  DELIMIT_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELIMIT_ROLES .

  DATA: TMP_AGR TYPE STANDARD TABLE OF BAPIAGR,
        IT_RETN TYPE STANDARD TABLE OF BAPIRET2.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      USERNAME       = ZIC_PREP_ROLEREQ-USERID
      CACHE_RESULTS  = ''
    TABLES
*     PARAMETER      =
*     PROFILES       =
      ACTIVITYGROUPS = IT_AGR
      RETURN         = IT_RETN.

*  IF tmp_agr IS NOT INITIAL.
*    LOOP AT tmp_agr INTO wa_agr WHERE agr_name NE 'M:COMMON_USER_TOOLS'.
*      wa_agr-to_dat = sy-datum.
*      APPEND wa_agr TO it_agr.
*    ENDLOOP.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_RSN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_RSN INPUT.
  IF OLD_OK_CODE = 'CRCROLES' AND ZIC_PREP_ROLEREQ-RSN_CODE = '02'.
    MESSAGE 'Change of Assignment Reason not allowed for CRC roles' TYPE 'E'.
  ENDIF.
ENDMODULE.

*--- INCLUDE: MZMMPREPROLE1_PHASEIII01 ---*
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
* CR No. 30012322  RD1K996279 CAB_SUDHIR
*
*1)Change in Line 630.
* 23/09/2014     <RD1K994398>     CAB_LIPSY    Changes made as per     *
*                                              CR 30011628
*                                              (BUKRS added in zmm_location,
*                                              MESSAGE zhelp 091)
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company ,multi module
*                                           roles,during approval      *
"                                          ,SRM Module introductin)    *
*&                                                                     *
*&                                                                     *
************************************************************************
MODULE user_command_0100 INPUT.

  okcode = sy-ucomm.

  CASE okcode.

    WHEN 'BAC' OR 'CAN'.

      PERFORM bac_confirm.
*      refresh control 'TABCTRL100' from screen '0100'.
      CLEAR okcode.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      g_mode = 'CRE'.
      CLEAR okcode.

    WHEN 'CHANGE'.

      g_mode = 'CHA'.
      CLEAR okcode.

    WHEN 'DISPLAY'.

      g_mode = 'DIS'.
      CLEAR okcode.

    WHEN 'DELETE'.

      g_mode = 'DEL'.
      CLEAR okcode.

    WHEN 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
      .
*        Perform Save_request.

      CLEAR okcode.

    WHEN 'RELEASE'.

      g_mode = 'REL'.
      CLEAR okcode.

    WHEN 'APPROVE'.

      g_mode = 'APR'.
      CLEAR okcode.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: modify table
MODULE tabctrl100_modify INPUT.

  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tabctrl100_wa.

*  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

  SELECT SINGLE * FROM zmm_prep_rolegrp WHERE role_type =
                  zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

*  endif.

  IF zic_prep_rolerei-rej_fl = ''.

    IF sy-subrc = 0 AND old_ok_code = 'APPROVE'.
      IF zmm_prep_rolegrp-approver1 = g_user
         OR zmm_prep_rolegrp-approver2 = g_user
         OR zmm_prep_rolegrp-approver3 = g_user
     """""""""""""""
       "added by lipsy for l2 approver on 20.03.2015 RD1K996555
            OR ( moduleid = 'SRM' AND zmm_prep_rolegrp-approver1 = g_user_l2 )
      "end of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
     """""""""
        .
      ELSE.

        IF okcode_100 = 'SAV'.
          IF err_flg <> 'X'.
            err_flg = 'X'.
            CLEAR : sy-ucomm, okcode_100.
          ENDIF.
          MESSAGE e047(zhelp) WITH zmm_prep_rolegrp-role_type.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT g_tabctrl100_wa-role_name IS INITIAL.
**
    IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_tabctrl100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
      IF sy-subrc = 0.
*        g_srno = g_srno + 1.
        g_tabctrl100_wa-role_desc = zmm_prep_roledes-brief_desc.
*        g_TABCTRL100_wa-srno = g_srno.
      ENDIF.

    ENDIF.
**
  ENDIF.
  MODIFY g_tabctrl100_itab
    FROM g_tabctrl100_wa
    INDEX tabctrl100-current_line.

  IF sy-subrc <> 0.
    APPEND g_tabctrl100_wa TO g_tabctrl100_itab.
  ENDIF.

  IF g_tabctrl100_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tabctrl100_wa-flag.
    APPEND g_tabctrl100_wa TO g_tabctrl100_itab.
  ENDIF.

ENDMODULE.                    "TABCTRL100_modify INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
MODULE tabctrl100_mark INPUT.
  IF tabctrl100-line_sel_mode = 1 AND
     g_tabctrl100_wa-flag = 'X'.
    LOOP AT g_tabctrl100_itab INTO g_tabctrl100_wa
      WHERE flag = 'X'.
      g_tabctrl100_wa-flag = ''.
      MODIFY g_tabctrl100_itab
        FROM g_tabctrl100_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tabctrl100_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tabctrl100_itab
    FROM g_tabctrl100_wa
    INDEX tabctrl100-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABCTRL100_mark INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
MODULE tabctrl100_user_command INPUT.
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
MODULE pov_plant INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA  :  ist_return_tab LIKE STANDARD TABLE OF ddshretval
                                               WITH  HEADER LINE.
*  TYPES :
*    BEGIN OF ty_bukrs,
*      werks LIKE zd_t001w_bukrs-werks,
*      name1 LIKE zd_t001w_bukrs-name1,
*    END OF ty_bukrs.
*
*  DATA   : it_bukrs TYPE TABLE OF ty_bukrs WITH HEADER LINE.

  SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
             TABLE it_bukrs ."""""" WHERE bukrs =  zic_prep_rolereq-ccode.    """ Commented By Suresh 23.01.2017

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-PLANT'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_bukrs
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_bukrs,ist_return_tab.
  FREE : it_bukrs,ist_return_tab.

ENDMODULE.                 " POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_grp INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

*    CONCATENATE '000'  zic_prep_rolereq-userid INTO cpf_lfb1.
    cpf_lfb1 = zic_prep_rolereq-userid.

**---------- Changes Start date 24.06.2016 11:57:21-------------------
*SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                   a~persk a~sbmod  c~designo c~r_p_cd c~version
                 d~sdesig_text AS designation d~adesig_text AS adesignation
                 d~disc_cd AS disc_cd
                   INTO CORRESPONDING FIELDS OF TABLE ist_data
              FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                    ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                       ON c~designo = d~desig_code AND
                           c~r_p_cd  = d~r_p_cd AND
                           c~version = d~version )
                        WHERE a~pernr =  zic_prep_rolereq-userid AND
                              a~sprps = ' ' AND
                              a~endda = '99991231' AND
                              c~sprps = ' ' AND
                              c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:57:21-----------------


    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER

***START OF COMMENT <RD1K983325>   CR: 30007580  dt: 05.04.2013.
*      g_ccode = ist_data-bukrs.
***end OF COMMENT <RD1K983325>.

**code added by CAB_AMITMOZA  <RD1K983325>   CR: 30007580  dt: 05.04.2013.
      g_ccode =  zic_prep_rolereq-ccode.
**code end by CAB_AMITMOZA  <RD1K983325>

    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-GRP' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  DATA : l_ekgrp LIKE t024-ekgrp.
  DATA : loop_step LIKE sy-stepl.
  DATA : l_role_name LIKE zic_prep_rolerei-role_name.

  DATA l_disc_mm_flag LIKE zic_prep_rolereq-disc_mm_flag.

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
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

  IF l_role_name = 'M6' OR  l_role_name = 'M7' OR
     l_role_name = 'M8'.
    CONCATENATE '%' g_ccode '%' INTO g_line1.
    SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.

  ELSE.
    IF zic_prep_rolereq-disc_mm_flag <> 'X'.
*      concatenate '%' G_CCODE '-' 'IND' '%'
*      into g_line1.
      CONCATENATE '%' g_ccode '%' 'IND' '%'
      INTO g_line1.
      SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
    ELSE.
*      concatenate  '%' G_CCODE '-' 'MM' '%'
*      into g_line1.
      CONCATENATE  '%' g_ccode '%' 'MM' '%'
      INTO g_line1.
      SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
    ENDIF.
  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T024'.
  g_field_wa-fieldname = 'EKGRP'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T024'.
  g_field_wa-fieldname = 'EKNAM'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-GRP'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t024
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t024,ist_return_tab, g_field_tab.
  FREE : it_t024,ist_return_tab, g_field_tab.
  CLEAR g_field_wa.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  TYPES : BEGIN OF z_role_des,
            role_type    LIKE zmm_prep_roledes-role_type,
            brief_desc   LIKE zmm_prep_roledes-brief_desc,
            detail_desc1 LIKE zmm_prep_roledes-detail_desc1,
            detail_desc2 LIKE zmm_prep_roledes-detail_desc2,
            sort_field   LIKE zmm_prep_roledes-brief_desc,
            mm_disc_flag LIKE zmm_prep_roledes-mm_disc_flag,
          END OF z_role_des.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_role TYPE TABLE OF z_role_des WITH HEADER LINE.

  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.

    SELECT * FROM zmm_prep_rolecrc INTO CORRESPONDING FIELDS OF
               TABLE it_role WHERE status = 'active'.

  ELSE.

    SELECT * FROM zmm_prep_roledes INTO CORRESPONDING FIELDS OF
               TABLE it_role.

  ENDIF.
  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
*Begin of <RD1K962817>.
*  g_field_wa-tabname = 'ZMM_PREP_ROLEDES'.
*  g_field_wa-fieldname = 'DETAIL_DESC2'.
*  APPEND g_field_wa TO g_field_tab.
*End of <RD1K962817>.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data INPUT.

  IF old_ok_code = 'DISPLAY' OR old_ok_code = 'CHANGE' OR
        old_ok_code = 'DELETE' OR old_ok_code = 'CREATE' OR
        old_ok_code = 'CROSSCO' OR ( old_ok_code = 'CRCROLES' )
        OR old_ok_code = 'RELEASE' OR ( old_ok_code = 'APPROVE' ).

    IF NOT  zic_prep_rolereq-userid IS INITIAL.
******* Start of Changes :  Changes done by Bipin shukla (SAB_BIPIN ) on 27/11/2013

      """"""""""""""""""""""""""""

      "comment by lipsy on 24.03.2015 RD1K996555
*      IF OLD_OK_CODE = 'CREATE'.
      "end of comment by lipsy on 24.03.2015 RD1K996555
      """"""""""""""""""""""""""""""""

      """""""""""""""""""""""""""""""""""
      "added by lipsy  for approver on  24.03.2015 RD1K996555
      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'.
        "end of addition by lipsy  for approver on  24.03.2015 RD1K996555
        """""""""""""""""""""""""""""""""



        CLEAR gt_role_usr[].

        SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE gt_role_usr
          WHERE agr_name = 'M:COMMON_USER_TOOLS' AND
                uname = zic_prep_rolereq-userid.

        IF gt_role_usr[] IS INITIAL.
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          "commented by lipsy on 17.09.2014 for using message class zhelp  RD1K994398

*          MESSAGE 'User is  currently  not an SAP user. Kindly contact  ICE Team' TYPE 'E'.
          "end of  comment by lipsy on 17.09.2014 for using message class zhelp  RD1K994398

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """"""""""""""""""""""""""""""""""""""""""""""""""
          "added by lipsy  for srm module introduction ON 12.03.2015 RD1K996555
          IF  moduleid = 'SRM'.

          ELSE.
            "end of addition by lipsy  for srm module introduction ON 12.03.2015 RD1K996555
            """"""""""""""""""""""""""""""""""""""""""""""""

            "added by lipsy on 17.09.2014 for using message class zhelp  RD1K994398

            MESSAGE e091(zhelp) WITH zic_prep_rolereq-userid.

            "end of  addition by lipsy on 17.09.2014 for using message class zhelp  RD1K994398


            """"""""""""""""""""""""""""""""""""
            "added by lipsy  for srm module introduction ON 12.03.2015 RD1K996555

          ENDIF.
          "end of addition by lipsy  for srm module introduction ON 12.03.2015 RD1K996555
          """"""""""""""""""""""""""""""""""""""""

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.

      ENDIF.

******* End of changes : Changes done by Bipin shukla (SAB_BIPIN ) on 27/11/2013
***CODE ADDED BY CAB_AMITMOZA  CR:30007580  WR:RD1K983325
      SELECT * FROM  zpa9205 APPENDING
      CORRESPONDING FIELDS OF TABLE it_9205
      WHERE pernr = zic_prep_rolereq-userid AND
            subty = '01' AND
            endda = '99991231' .
*      clear ZIC_PREP_ROLEREQ-TELNO.
      IF sy-subrc = 0.          "" It means PHONE NO. OF REQUIRED T&S EXECUTIVE HAS BEEN FOUND
        SORT  it_9205 BY begda DESCENDING  .
        READ TABLE it_9205 INTO wa_9205 INDEX 1  .  "#EC CI_NOORDER
        CONCATENATE '91' wa_9205-zphone+1(10) INTO  zic_prep_rolereq-telno .
*else.
*  LOOP AT SCREEN.
*
*  if screen-name = 'ZIC_PREP_ROLEREQ-TELNO ' .
*  screen-group1 = 'GP1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.

      ENDIF.

***CODE END BY CAB_AMITMOZA  CR:30007580
**COMMENT DONE BY CAB_AMITMOZA  CR:30007580  WR:RD1K983325
*      PERFORM check_tel.
**COMMENT END BY CAB_AMITMOZA  CR:30007580

    ENDIF.

    IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.

      IF  zic_prep_rolereq-persa IS INITIAL AND
          zic_prep_rolereq-rsn_code = '01'.
        PERFORM pop_up_message.
      ENDIF.

      IF  zic_prep_rolereq-userid IS INITIAL.
        MESSAGE e035(zhelp).
      ENDIF.

      IF  zic_prep_rolereq-userid <> old_userid AND
        old_userid <> ''.
        CLEAR  zic_prep_rolereq-disc_mm_flag.
        CLEAR  zic_prep_rolereq-ccode.
        CLEAR  zic_prep_rolereq-fundc1.
        CLEAR  zic_prep_rolereq-fundc.
        CLEAR  zic_prep_rolereq-s_desc.
        CLEAR  zic_prep_rolereq-rsn_code.
        CLEAR  zic_prep_rolereq-rsn_text1.
        CLEAR  zic_prep_rolereq-reason1.
        CLEAR  zic_prep_rolereq-telno.
        CLEAR  zic_prep_rolereq-name.
        CLEAR  zic_prep_rolereq-designation.
        CLEAR set_disc_mm_flag.
        CLEAR set_disc_fi_flag.
        CLEAR help_list_flag.
        REFRESH it_m_fistb.
        CLEAR wa_m_fistb.
      ENDIF.

*        select single * from zusrmst where cpfno =
*                                    ZIC_PREP_ROLEREQ-userid.

      SELECT SINGLE * FROM usr02 WHERE bname =
                                  zic_prep_rolereq-userid.

      IF sy-subrc NE 0.
        MESSAGE e043(zhelp).
      ELSE.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-name = zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-designation = zusrmst-designation.

*Begin of <RD1K964434>.
        DATA : l_date TYPE datum.
        MOVE sy-datum TO l_date.
*End of <RD1K964434>.

**---------- Changes Start date 24.06.2016 11:56:49-------------------
*        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*           D~DISC_CD AS DISC_CD
*             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                 ON C~DESIGNO = D~DESIG_CODE AND
*                     C~R_P_CD  = D~R_P_CD AND
*                     C~VERSION = D~VERSION )
*                  WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                        A~SPRPS = ' ' AND
**Begin of <RD1K964434>.
**                        a~endda = '99991231' AND
*                         A~ENDDA GE L_DATE AND
**End of <RD1K964434>.
*                         C~SPRPS = ' ' AND
**Begin of <RD1K964434>.
**                        c~endda = '99991231' .
*                         C~ENDDA GE L_DATE .

        SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text AS designation d~adesig_text AS adesignation
           d~disc_cd AS disc_cd
             INTO CORRESPONDING FIELDS OF TABLE ist_data
        FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
              ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                 ON c~designo = d~desig_code AND
                     c~r_p_cd  = d~r_p_cd AND
                     c~version = d~version )
                  WHERE a~pernr =  zic_prep_rolereq-userid AND
                        a~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                         a~endda GE l_date AND
*End of <RD1K964434>.
                         c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                         c~endda GE l_date .
**---------- Changee  Ending Date 24.06.2016 11:56:49-----------------
*End of <RD1K964434>.

*Begin of <RD1K964434>.
        DATA : l_count TYPE i.
        DESCRIBE TABLE ist_data[] LINES l_count.
*End of <RD1K964434>.

        IF sy-subrc = 0.
          READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
          zic_prep_rolereq-name = ist_data-name.
          zic_prep_rolereq-designation = ist_data-designation.
*Begin of <RD1K962817>.
          zic_prep_rolereq-persk = ist_data-persk.
*End of <RD1K962817>.
          IF ist_data-disc_cd = '36' AND set_disc_mm_flag <> 'X'.
            zic_prep_rolereq-disc_mm_flag = 'X'.
            set_disc_mm_flag = 'X'.
          ENDIF.
          IF ist_data-disc_cd = '13' AND set_disc_fi_flag <> 'X'.
            zic_prep_rolereq-disc_fi_flag = 'X'.
            set_disc_fi_flag = 'X'.
          ENDIF.
***************************************************31.05.2006
          IF old_ok_code = 'CREATE' OR old_ok_code = 'CRCROLES'.
            zic_prep_rolereq-ccode = ist_data-bukrs.
          ELSE.
            g_ccode_crossco        = ist_data-bukrs.
          ENDIF.
          IF old_ok_code = 'APPROVE'.
            g_ccode_crossco        = ist_data-bukrs.
          ENDIF.
***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*             ZIC_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

          IF old_ok_code = 'CREATE'.
            IF  zic_prep_rolereq-persa <> ist_data-werks AND
               NOT  zic_prep_rolereq-persa IS INITIAL.
              MESSAGE e108(zhelp).
            ENDIF.
          ENDIF.

        ENDIF.

*Begin of <RD1K962817>.
*if zic_prep_rolereq-persk < 'E4'.
*  MESSAGE i803(zmm) with text-003.
*  LEAVE PROGRAM.
*  endif.
*End of <RD1K962817>.
        CLEAR : ist_data.
        REFRESH : ist_data.

** Change company code, fund centre, costcentre logic 02.02.2006

* Begin of <RD1K981840>
*        CONCATENATE '000'  zic_prep_rolereq-userid INTO cpf_lfb1.
        cpf_lfb1 = zic_prep_rolereq-userid.
* End of <RD1K981840>

*          select single * from lfb1 where lifnr = cpf_lfb1.

* Select Company-KBU01, Cost Centre-kst01
* from pa0027  .
        CLEAR wa_pa0027.

**---------- Changes Start date 24.06.2016 12:12:14-------------------

*        SELECT SINGLE *
*           FROM PA0027
*           INTO WA_PA0027
*           WHERE PERNR = CPF_LFB1 AND
*                 ENDDA = '99991231' AND
*                 SPRPS = ' ' . " SPRPS - Lock Indicator 'X'

        SELECT *
 FROM ZPA0027 INTO WA_PA0027 UP TO 1 ROWS WHERE PERNR = CPF_LFB1 AND ENDDA = '99991231' AND SPRPS = ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT. " SPRPS - Lock Indicator 'X'
**---------- Changee  Ending Date 24.06.2016 12:12:14-----------------

        IF sy-subrc = 0.
*Begin of <RD1K963151>.
*          IF old_ok_code <> 'CROSSCO'.
*End of <RD1K963151>.
          CONCATENATE  '''' '%' wa_pa0027-kst01
                       '''' INTO  g_line1.
          CONCATENATE  'OBJNR'  'LIKE' g_line1 INTO g_line1
          SEPARATED BY space.
          REFRESH :  it_cond.
          APPEND g_line1 TO it_cond.
          SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE (IT_COND)
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*Begin of <RD1K963151>.
*          ENDIF.
*End of <RD1K963151>.
          IF sy-subrc = 0.
*Begin of <RD1K963151>.
* IF old_ok_code = 'CREATE' OR old_ok_code = 'CRCROLES' .
            IF old_ok_code = 'CREATE' OR old_ok_code = 'CRCROLES' OR old_ok_code = 'CROSSCO'.
*End of <RD1K963151>.
              zic_prep_rolereq-fundc1 = fmzuob-fistl.
              zic_prep_rolereq-fundc_fl = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
              zic_prep_rolereq-costc = wa_pa0027-kst01.
            ELSE.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
              zic_prep_rolereq-costc = wa_pa0027-kst01.
            ENDIF.

            SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZIC_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

            IF sy-subrc =  0.
              zic_prep_rolereq-s_desc = cskt-ltext.
            ENDIF.

            REFRESH it_cond[].
            CLEAR it_cond.
          ELSE.
          ENDIF.
        ENDIF.

      ENDIF.

    ELSE.

***************************************************

      IF  zic_prep_rolereq-docno IS INITIAL.
        MESSAGE e041(zhelp).
      ENDIF.

    ENDIF.

**********************************************************nn

    SELECT SINGLE * FROM usr02 WHERE bname =
                                   zic_prep_rolereq-userid.

    IF sy-subrc NE 0.
    ELSE.
**   **---------- Changes Start date 24.06.2016 11:56:05-------------------

*   SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*           A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*         D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*         D~DISC_CD AS DISC_CD
*           INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*      FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*            ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*               ON C~DESIGNO = D~DESIG_CODE AND
*                   C~R_P_CD  = D~R_P_CD AND
*                   C~VERSION = D~VERSION )
*                WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                      A~SPRPS = ' ' AND
*                      A~ENDDA = '99991231' AND
*                      C~SPRPS = ' ' AND
*                      C~ENDDA = '99991231' .


      SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
              a~persk a~sbmod  c~designo c~r_p_cd c~version
            d~sdesig_text AS designation d~adesig_text AS adesignation
            d~disc_cd AS disc_cd
              INTO CORRESPONDING FIELDS OF TABLE ist_data
         FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
               ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                  ON c~designo = d~desig_code AND
                      c~r_p_cd  = d~r_p_cd AND
                      c~version = d~version )
                   WHERE a~pernr =  zic_prep_rolereq-userid AND
                         a~sprps = ' ' AND
                         a~endda = '99991231' AND
                         c~sprps = ' ' AND
                         c~endda = '99991231' .
***   *---------- Changee  Ending Date 24.06.2016 11:56:05-----------------

      IF sy-subrc = 0 AND zic_prep_rolereq-crossco_fl = 'X'.
        READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
        IF old_ok_code = 'APPROVE'.
          g_ccode_crossco        = ist_data-bukrs.
        ENDIF.
      ENDIF.
    ENDIF.
********************************************************nn
  ENDIF.


ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

  IF moduleid = 'FI' .
    PERFORM call_fi.
  ENDIF.

  """""""""""
  " addition by lipsy  for srm module introduction on 17.03.2015 RD1K996555
  IF moduleid = 'SRM' .
    CLEAR:sy-ucomm.
  ENDIF.
  "end of addition by lipsy  for srm module introduction on 17.03.2015 RD1K996555
  """"""""""""""
* Start of Changes by CAB_DAV to Integrate ZHRARMS with ZICE_ARMS
* Date : 22-04-2008.

  IF moduleid = 'HR' .
    AUTHORITY-CHECK OBJECT 'ZHR_ARMS'
                     ID 'ZTCODE' FIELD 'ZHRARMS'.
    IF sy-subrc = 0.
      PERFORM call_hr.
    ELSE.
      MESSAGE e231(zhelp).
    ENDIF.

  ENDIF.

* End of Changes by CAB_DAV to Integrate ZHRARMS with ZICE_ARMS.

  CASE okcode_100.

    WHEN 'BAC' OR 'CAN'.
      PERFORM exit_confirm.
    WHEN 'EXT'.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      old_ok_code = okcode_100.
      moduleid = 'MM'.

    WHEN 'CHANGE'.

      old_ok_code = okcode_100.

    WHEN 'RELEASE'.

      old_ok_code = okcode_100.


    WHEN 'APPROVE'.

      old_ok_code = okcode_100.

    WHEN 'COPY'.


    WHEN 'DISPLAY'.

      old_ok_code = okcode_100.

    WHEN 'ROLE_DEL'.

      old_ok_code = okcode_100.

    WHEN 'SAV'.
*Begin of <RD1K962817>.
      DATA : lv_ol    TYPE char2,
             lv_ne    TYPE char2,
             l_ans(1) TYPE c.

******** Start of Changes :  Changes done by Bipin shukla (SAB_BIPIN ) on 27/11/2013
*
*      IF OLD_OK_CODE = 'CREATE'.
*
*        CLEAR GT_ROLE_USR[].
*
*        SELECT * FROM AGR_USERS INTO CORRESPONDING FIELDS OF TABLE GT_ROLE_USR
*          WHERE AGR_NAME = 'M:COMMON_USER_TOOLS' AND
*                UNAME = ZIC_PREP_ROLEREQ-USERID.
*
*        IF GT_ROLE_USR[] IS INITIAL.
*
*          MESSAGE 'You are not authorized to created the request for the user.' TYPE 'E'.
*
*        ENDIF.
*
*      ENDIF.
*
******** End of changes : Changes done by Bipin shukla (SAB_BIPIN ) on 27/11/2013

       perform check_plant_grp.

      READ TABLE ist_return_tab3 WITH KEY fieldname = 'MIN_DESIGNATION'.
      lv_ne = ist_return_tab3-fieldvalue.
      lv_ol = zic_prep_rolereq-persk.

      IF lv_ne > lv_ol.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            text_question         = text-002
            text_button_1         = 'Agree'
            text_button_2         = 'Cancel'
            default_button        = ' '
            start_column          = 25
            start_row             = 6
            display_cancel_button = ' '
          IMPORTING
            answer                = l_ans
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.

        IF l_ans = 1.
*          IF LV_NE < LV_OL.
*End of <RD1K962817>.

          IF old_ok_code = 'DELETE'.

            IF  zic_prep_rolereq-useridcr = sy-uname.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

              IF  zic_prep_rolereq-status = ''.
                PERFORM delete_request.
              ELSE.
                MESSAGE e138(zhelp).
              ENDIF.
            ELSE.
              MESSAGE e056(zhelp).
            ENDIF.
          ELSE.
*        describe table g_TABLCTRL110_itab lines g_lines_rl.
*        if g_lines_rl = 0.
*           clear okcode_100.
*           message i140(zhelp).
*        else.
*** cab_ajit 24/04/2007
            IF old_ok_code = 'RELEASE' AND
                   zic_prep_rolereq-req_cr_fl = 'X'.
              PERFORM confirm_rel.
              IF g_choice_rel <> 'J'.
                CLEAR g_choice_rel.
                PERFORM clear.
                CLEAR old_ok_code.
                dynnr = '0101'.
                CALL SCREEN 100.
              ENDIF.
            ENDIF.
***
            IF old_ok_code = 'RELEASE' AND
                   zic_prep_rolereq-req_cr_fl <> 'X'.
              MESSAGE i083(zhelp).

            ELSEIF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
              MESSAGE i089(zhelp).

            ELSEIF old_ok_code = 'APPROVE' AND
                   (  zic_prep_rolereq-req_app_fl <> 'X' AND
                   zic_prep_rolereq-req_app0_fl <> 'X' AND
                   zic_prep_rolereq-req_app1_fl <> 'X' ).
**13/04/07
              IF module_changed_flag <> 'X'.
                MESSAGE i087(zhelp).
              ELSE.
                PERFORM save_request.
              ENDIF.
            ELSEIF old_ok_code = 'APPROVE' AND  g_mult_module_fl = 'X'.
              SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                     FIELD zic_prep_rolereq-docno.
              CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.
              PERFORM confirm_app.
              IF g_choice_app = 'J'.
                CLEAR g_choice_app.
                IF moduleid <> 'MM'.
                  g_approver_level = 'L3'.
                ENDIF.
                PERFORM save_request.
              ENDIF.
            ELSE.
*          Perform check_items.
              IF moduleid <> 'MM'.
                g_approver_level = 'L3'.
              ENDIF.
              PERFORM save_request.
            ENDIF.
**       endif.
          ENDIF.
*          ENDIF.
*Begin of <RD1K962817>.

        ENDIF.
      ELSE.
        IF old_ok_code = 'DELETE'.

          IF  zic_prep_rolereq-useridcr = sy-uname.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

            IF  zic_prep_rolereq-status = ''.
              PERFORM delete_request.
            ELSE.
              MESSAGE e138(zhelp).
            ENDIF.
          ELSE.
            MESSAGE e056(zhelp).
          ENDIF.
        ELSE.
*        describe table g_TABLCTRL110_itab lines g_lines_rl.
*        if g_lines_rl = 0.
*           clear okcode_100.
*           message i140(zhelp).
*        else.
*** cab_ajit 24/04/2007
********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT

          SELECT * FROM zgrc_sod_result INTO CORRESPONDING FIELDS OF TABLE gt_risk WHERE docno = zic_prep_rolereq-docno.

          IF gt_risk[] IS NOT INITIAL..
            DESCRIBE TABLE gt_risk LINES lv_rcount.
          ENDIF.

          SELECT * FROM zgrc_log INTO CORRESPONDING FIELDS OF TABLE gt_log WHERE docno = zic_prep_rolereq-docno.
          IF gt_log[] IS NOT INITIAL.
            READ TABLE gt_log INTO wa_log WITH KEY docno = zic_prep_rolereq-docno.
          ENDIF.

          IMPORT gt_text FROM MEMORY ID 'TABLE1'.
          IMPORT zice_ex FROM MEMORY ID 'ZICE_IM'.
*          DESCRIBE TABLE GT_RISK LINES LV_RCOUNT.
********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT
*          IF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL NE 0 . "AND GT_TEXT IS  NOT INITIAL.
*            FREE MEMORY ID 'TABLE1'."+ by vikas
*            FREE MEMORY ID 'ZICE_IM'.
**          ENDIF.
*          IF OLD_OK_CODE = 'RELEASE' AND
*            GT_RISK IS NOT INITIAL AND GT_TEXT IS INITIAL AND ZICE_EX NOT BETWEEN '1' AND '4'.
*            MESSAGE S233(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
*            ENDIF.
*          IF OLD_OK_CODE = 'RELEASE'.
*            DESCRIBE TABLE GT_RISK LINES LV_RISK.
*            IF LV_RISK EQ 1.
*              ZICE_EX = '1'.
*            ENDIF.
*          ENDIF.

*          ELSEIF OLD_OK_CODE = 'RELEASE' AND
*            GT_RISK IS NOT INITIAL AND GT_TEXT IS INITIAL AND ZICE_EX NOT BETWEEN '1' AND '4'.
*            MESSAGE S233(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.

          IF old_ok_code = 'RELEASE' AND
                   zic_prep_rolereq-req_cr_fl = 'X'.

            PERFORM confirm_rel.

            IF g_choice_rel <> 'J'.
              CLEAR g_choice_rel.
              PERFORM clear.
              CLEAR old_ok_code.
              dynnr = '0101'.
              CALL SCREEN 100.
*              ENDIF.
            ENDIF.
          ENDIF.
***
**************************************** Code for risk analysis before approve  : added by Bipin
*          IF OLD_OK_CODE = 'APPROVE' AND GT_TEXT IS INITIAL AND ZICE_EX NOT BETWEEN '1' AND '4'.
          IF old_ok_code = 'APPROVE' AND wa_log-app_fl_app NE 'A'.

            """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
            "added by lipsy on 27.05.2015  RD1K997318

            IF moduleid = 'MM' OR moduleid = 'SRM'.

              IF zic_prep_rolereq-useridcr = sy-uname.


                CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
                  EXPORTING
                    titel     = 'Approval Requirement'
                    textline1 = 'Approver cannot be same as creator'.



                LEAVE PROGRAM.

              ENDIF.


            ENDIF.


            "end of addition by lipsy on 27.05.2015  RD1K997318
            """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
******************************** CHECKING REJECTIONG LINE ITEM IN BUCKET
            CLEAR gt_bucket.
            IF moduleid = 'MM'.
              LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.

                MOVE-CORRESPONDING g_tablctrl110_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.
            ELSEIF moduleid = 'SD'.
              LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.

                MOVE-CORRESPONDING g_tablctrl114_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.
            ELSEIF moduleid = 'PP'.
              LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.

                MOVE-CORRESPONDING g_tablctrl113_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.

            ELSEIF moduleid = 'PM'.
              LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

                MOVE-CORRESPONDING g_tablctrl111_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.

            ELSEIF moduleid = 'PS'.
              LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.

                MOVE-CORRESPONDING g_tablctrl112_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.

            ELSEIF moduleid = 'HSE'.
              LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.

                MOVE-CORRESPONDING g_tablctrl116_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.


            ELSEIF moduleid = 'QM'.
              LOOP AT g_tablctrl115_itab INTO g_tablctrl115_wa.

                MOVE-CORRESPONDING g_tablctrl115_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.

            ELSEIF moduleid = 'OLM'.
              LOOP AT g_tc_117_itab INTO g_tc_117_wa .

                MOVE-CORRESPONDING g_tc_117_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.

              """"""""""""""""""""""""""""""""""""""""""
              "addition by lipsy  for srm module introduction   on  3.03.2015 RD1K996555
            ELSEIF moduleid = 'SRM'.
              LOOP AT g_tablctrl118_itab INTO g_tablctrl118_wa.

                MOVE-CORRESPONDING g_tablctrl118_wa TO wa_bucket.
                wa_bucket-docno = reqnum_ex.
                APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
              ENDLOOP.

              "end of addition by lipsy  for srm module introduction   on  3.03.2015 RD1K996555

              """"""""""""""""""""""""""""""""""
            ENDIF.

            DELETE gt_bucket WHERE rej_fl = 'H'.
            DELETE gt_bucket WHERE rej_fl = 'B'.
            DELETE gt_bucket WHERE rej_fl = 'F'.
            DELETE gt_bucket WHERE rej_fl = 'I'.
            DELETE gt_bucket WHERE rej_fl = 'R'.
******************************** CHECKING REJECTIONG LINE ITEM IN BUCKET
*            IF GT_TEXT IS NOT INITIAL AND OLD_OK_CODE = 'APPROVE'. " BIPIN

            IF gt_bucket IS NOT INITIAL.
              IF lv_rcount GT 1.
                CLEAR : it_tvarv.
                SELECT * FROM tvarvc INTO CORRESPONDING FIELDS OF TABLE it_tvarv
                WHERE name = 'ZGRC_CALL'.
                IF it_tvarv[] IS NOT INITIAL.
                  READ TABLE it_tvarv INTO wa_tvarv WITH KEY name = 'ZGRC_CALL'.
                ENDIF.

                IF wa_tvarv-low IS NOT INITIAL.
                  lv_grccall = wa_tvarv-low.
                ENDIF.

                IF syst-sysid = 'RD1'.

                  lv7_rfc = 'GRDCLNT500'.

                ELSEIF syst-sysid = 'RQ1'.

                  lv7_rfc = 'GRDCLNT500'.

                ELSEIF syst-sysid = 'RP1'.

                  lv7_rfc = 'GRPCLNT500'.
                ENDIF.

                CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
                  EXPORTING
                    rfcdestination = lv7_rfc "'GRDCLNT500'
                  IMPORTING
                    rfc_subrc      = lv_subrc.

                IF  lv_grccall = 'X' AND lv_subrc = '0'.
*                  MESSAGE I232(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
                  CLEAR txt1.
                  CONCATENATE 'Risk Analysis in Progress for Doc.' zic_prep_rolereq-docno INTO txt1 SEPARATED BY space.
                  CALL FUNCTION 'POPUP_TO_INFORM'
                    EXPORTING
                      titel = 'Information'
                      txt1  = txt1
                      txt2  = 'To view the report, Pls press ENTER'.

                  reqnum_ex = zic_prep_rolereq-docno.
                  EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.

                  PERFORM grc_risk_analysis.
                  IMPORT gt_rdesc FROM MEMORY ID 'IM_GT_RDESC'.

                  IF gt_rdesc IS NOT INITIAL.
                    CALL TRANSACTION 'ZGRC_RESULT'.
                  ELSE.
                    MESSAGE 'No risk found.' TYPE 'I'.
                  ENDIF.
                  IMPORT oc_9001_rj FROM MEMORY ID 'OC_9001_IM'.
                  IF oc_9001_rj = 'REJECT'.
                    LEAVE PROGRAM.
                  ENDIF.

                  CLEAR reqnum_ex.
                  CLEAR oc_9001_rj.
                ENDIF.
              ENDIF.
            ELSE.
*              MESSAGE 'All role Rejected.' TYPE 'I'.

            ENDIF.
          ENDIF.

**************************************** Code for risk analysis before approve
          IF old_ok_code = 'RELEASE'.
            CLEAR gt_log.
            CLEAR wa_log.
*********************************CHECK GRC SYSTEM IS UP OR NOT
            CLEAR : it_tvarv.
            SELECT * FROM tvarvc INTO CORRESPONDING FIELDS OF TABLE it_tvarv
WHERE name = 'ZGRC_CALL'.
            IF it_tvarv[] IS NOT INITIAL.
              READ TABLE it_tvarv INTO wa_tvarv WITH KEY name = 'ZGRC_CALL'.
            ENDIF.
            IF wa_tvarv-low IS NOT INITIAL.
              lv_grccall = wa_tvarv-low.
            ENDIF.

            IF syst-sysid = 'RD1'.

              lv8_rfc = 'GRDCLNT500'.

            ELSEIF syst-sysid = 'RQ1'.

              lv8_rfc = 'GRDCLNT500'.

            ELSEIF syst-sysid = 'RP1'.

              lv8_rfc = 'GRPCLNT500'.
            ENDIF.

            CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
              EXPORTING
                rfcdestination = lv8_rfc "'GRDCLNT500'
              IMPORTING
                rfc_subrc      = lv_subrc.

*********************************CHECK GRC SYSTEM IS UP OR NOT

            SELECT * FROM zgrc_log INTO CORRESPONDING FIELDS OF TABLE gt_log WHERE docno = zic_prep_rolereq-docno
AND okcode IN ('CHANGE','CREATE','CROSSCO').
            IF gt_log[] IS NOT INITIAL.
              READ TABLE gt_log INTO wa_log WITH KEY docno = zic_prep_rolereq-docno.
            ENDIF.
            DESCRIBE TABLE gt_risk LINES lv_risk.
            IF lv_risk EQ 1.
              zice_ex = '1'.
            ENDIF.
          ENDIF.




          IF old_ok_code = 'RELEASE' AND
                 zic_prep_rolereq-req_cr_fl <> 'X'.
            MESSAGE i083(zhelp).



*          ELSEIF OLD_OK_CODE = 'RELEASE' AND
*     GT_RISK IS NOT INITIAL AND GT_TEXT IS INITIAL AND ZICE_EX NOT BETWEEN '1' AND '4'.
*            MESSAGE S233(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT

          ELSEIF old_ok_code = 'RELEASE' AND wa_log-app_fl NE 'A' AND lv_risk GT 1 AND lv_grccall = 'X' AND lv_subrc = '0'.

*                 GT_RISK IS NOT INITIAL AND GT_TEXT IS INITIAL AND ZICE_EX NOT BETWEEN '1' AND '4'.

            MESSAGE e234(zhelp) WITH zic_prep_rolereq-docno.

********************** CHANGES BY BIPIN : TO CHECK RISK AND COMMENT

          ELSEIF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
            MESSAGE i089(zhelp).

          ELSEIF old_ok_code = 'APPROVE' AND
                 (  zic_prep_rolereq-req_app_fl <> 'X' AND
                 zic_prep_rolereq-req_app0_fl <> 'X' AND
                 zic_prep_rolereq-req_app1_fl <> 'X' ).
**13/04/07
            IF module_changed_flag <> 'X'.
              MESSAGE i087(zhelp).
            ELSE.
              PERFORM save_request.
            ENDIF.
          ELSEIF old_ok_code = 'APPROVE' AND  g_mult_module_fl = 'X'.
            SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                   FIELD zic_prep_rolereq-docno.
            CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.
            PERFORM confirm_app.
            IF g_choice_app = 'J'.
              CLEAR g_choice_app.
              IF moduleid <> 'MM'.
                g_approver_level = 'L3'.
              ENDIF.
              PERFORM save_request.
            ENDIF.
          ELSE.
*          Perform check_items.
            IF moduleid <> 'MM'.
              g_approver_level = 'L3'.
            ENDIF.
*************************************** added by Bipin to check okcode value for save request
            IF old_ok_code = 'RELEASE' AND g_lines_rl NE 0 . "AND GT_TEXT IS  NOT INITIAL.
              FREE MEMORY ID 'TABLE1'."+ by vikas
              FREE MEMORY ID 'ZICE_IM'.
              CLEAR gt_text.
              CLEAR zice_ex.

            ENDIF.

            IMPORT oc_9001_rj FROM MEMORY ID 'OC_9001_IM'.
            IMPORT oc_9002_rj FROM MEMORY ID 'OC_9002_IM'.
            IMPORT oc_9003_rj FROM MEMORY ID 'OC_9003_IM'.
            IMPORT lv_expo FROM MEMORY ID 'LV_IMP'.

            IF oc_9001_rj = 'SUBMIT' OR oc_9002_rj = 'SUBMIT' OR oc_9003_rj = 'SUBMIT'
             OR old_ok_code = 'CHANGE' OR old_ok_code = 'CREATE' OR lv_rcount EQ '1' OR lv_rcount EQ '0'..
              CLEAR lv_expo.
            ENDIF.
            CLEAR oc_9001_rj.
*************************************** added by Bipin to check okcode value for save request
*            PERFORM SAVE_REQUEST.
            IF lv_expo = ''. " ADDED BY BIPIN
              PERFORM save_request.
            ENDIF.
            CLEAR lv_expo.     " ADDED BY BIPIN
          ENDIF.
**       endif.
        ENDIF.
*          ENDIF.
*Begin of <RD1K962817>.

      ENDIF.
  ENDCASE.

  CASE okcode_100.
*End of <RD1K962817>.
    WHEN 'MULTI'.

*      clear help_list_flag.

      CALL SCREEN 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      CLEAR okcode_100.


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
      IF old_ok_code = 'CREATE' OR
          old_ok_code = 'CROSSCO' OR
          old_ok_code = 'CRCROLES'.
        MESSAGE i137(zhelp).
      ELSE.
        PERFORM attach_files.
        IF old_ok_code = 'DISPLAY' AND
           zic_prep_rolereq-status = 'IR'.
          attach_fl = 'X'.
          PERFORM confirm_more.

          IF g_choice_more = 'J'.
            CLEAR g_choice_more.
          ELSE.
            PERFORM save_request.
          ENDIF.
        ENDIF.
      ENDIF.

*       old_ok_code = okcode_100.

    WHEN 'LIST'.

      PERFORM list_files.

*       old_ok_code = okcode_100.

    WHEN 'CORR'.

      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
      CLEAR okcode_100.

    WHEN 'CROSSCO'.

      old_ok_code = okcode_100.
      moduleid = 'MM'.

    WHEN 'CRCROLES'.

      old_ok_code = okcode_100.

    WHEN 'SUMMARY'.

      SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                  FIELD zic_prep_rolereq-docno.
*      call transaction 'ZIC_DETAILS' .

      CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.

    WHEN 'GUIDE'.
* End of <> on 24032014
*      PERFORM LIST_HELP_FILES.
      PERFORM list_help_files_new.
* End of <> on 27032014
    WHEN OTHERS.

      CLEAR okcode_100.

  ENDCASE.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0120 INPUT.


ENDMODULE.                 " USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_ok_code INPUT.


********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.
  okcode_rj = old_ok_code.
  crt_name = zic_prep_rolereq-useridcr.
  tcode_rj = sy-tcode.

  EXPORT okcode_rj TO MEMORY ID 'OKCODE_RJ'.
  EXPORT crt_name TO MEMORY ID 'CRT_NAME_RJ'.
  EXPORT tcode_rj TO MEMORY ID 'TCODE_IM'.
********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.

  IF sy-ucomm = 'DBLCLK'.
    CLEAR sy-ucomm.
  ENDIF.
  okcode_100 = sy-ucomm.

  CLEAR :  err_flg.
  CASE okcode.

    WHEN 'GRC_RISK'.

      CLEAR gt_bucket_ex.
      reqnum_ex = zic_prep_rolereq-docno.
      IF moduleid = 'MM'.
        LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.

          MOVE-CORRESPONDING g_tablctrl110_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.
      ELSEIF moduleid = 'SD'.
        LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.

          MOVE-CORRESPONDING g_tablctrl114_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.
      ELSEIF moduleid = 'PP'.
        LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.

          MOVE-CORRESPONDING g_tablctrl113_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF moduleid = 'PM'.
        LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

          MOVE-CORRESPONDING g_tablctrl111_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF moduleid = 'PS'.
        LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.

          MOVE-CORRESPONDING g_tablctrl112_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF moduleid = 'HSE'.
        LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.

          MOVE-CORRESPONDING g_tablctrl116_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.


      ELSEIF moduleid = 'QM'.
        LOOP AT g_tablctrl115_itab INTO g_tablctrl115_wa.

          MOVE-CORRESPONDING g_tablctrl115_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF moduleid = 'OLM'.
        LOOP AT g_tc_117_itab INTO g_tc_117_wa .

          MOVE-CORRESPONDING g_tc_117_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.

        """""""""""""""""""""""""""""""""""""""""""""""""""""
        "addition by lipsy  for srm module introduction on 3.03.2015 RD1K996555
      ELSEIF moduleid = 'SRM'.
        LOOP AT g_tablctrl118_itab INTO g_tablctrl118_wa.

          MOVE-CORRESPONDING g_tablctrl118_wa TO wa_bucket_ex.
          wa_bucket-docno = reqnum_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.
*    CLEAR WA_BUCKET.
        ENDLOOP.

        "end of addition by lipsy  for srm module introduction on 3.03.2015 RD1K996555

        """"""""""""""""""""""""""""""""""""""""""""""""

      ENDIF.


      SELECT * FROM zic_prep_rolerei INTO CORRESPONDING FIELDS OF TABLE gt_crmodule_ex
        WHERE docno = reqnum_ex AND moduleid NE moduleid.

      IF sy-subrc EQ 0.

        LOOP AT gt_crmodule_ex INTO wa_crmodule_ex.

          MOVE-CORRESPONDING wa_crmodule_ex TO wa_bucket_ex.
          APPEND wa_bucket_ex TO gt_bucket_ex.

        ENDLOOP.
        CLEAR : wa_crmodule_ex , gt_crmodule_ex.

      ENDIF.

*      LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.
*
*        MOVE-CORRESPONDING G_TABLCTRL111_WA TO WA_BUCKET_EX.
*        APPEND WA_BUCKET_EX TO GT_BUCKET_EX.
*        CLEAR WA_BUCKET_EX.
*
*      ENDLOOP.

      EXPORT gt_bucket_ex TO MEMORY ID 'TABLE_IM'.
      CLEAR : it_tvarv.
      SELECT * FROM tvarvc INTO CORRESPONDING FIELDS OF TABLE it_tvarv
      WHERE name = 'ZGRC_CALL'.
      IF it_tvarv[] IS NOT INITIAL.
        READ TABLE it_tvarv INTO wa_tvarv WITH KEY name = 'ZGRC_CALL'.
      ENDIF.
      IF wa_tvarv-low IS NOT INITIAL.
        lv_grccall = wa_tvarv-low.
      ENDIF.

      IF syst-sysid = 'RD1'.

        lv9_rfc = 'GRDCLNT500'.

      ELSEIF syst-sysid = 'RQ1'.

        lv9_rfc = 'GRDCLNT500'.

      ELSEIF syst-sysid = 'RP1'.

        lv9_rfc = 'GRPCLNT500'.
      ENDIF.

      CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
        EXPORTING
          rfcdestination = lv9_rfc                   "'GRDCLNT500'
*         RFCDESTINATION = 'GRPCLNT500TEST'         changes on 02.08.2014  CAB_DNS
        IMPORTING
*         MSGV1          =
*         MSGV2          =
          rfc_subrc      = lv_subrc.
      IF  lv_grccall = 'X' AND lv_subrc = '0'.


        EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
        okcode_ex = old_ok_code.
        EXPORT okcode_ex TO MEMORY ID 'OKCODE_IM'.
*        CALL TRANSACTION 'ZGRC_RISK_RESULT'. " + COMMENT BY VIKAS
        CALL TRANSACTION 'ZGRC_RISK_RESULT'. " + aDDED BY VIKAS

        IMPORT oc_9001_rj FROM MEMORY ID 'OC_9001_IM'.
        IF oc_9001_rj = 'REJECT'.
          LEAVE PROGRAM.
        ENDIF.

        IF old_ok_code EQ 'CREATE' OR old_ok_code EQ 'CHANGE'.
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
      CLEAR reqnum_ex.
      CLEAR: okcode.
      CLEAR okcode_ex.

    WHEN 'GRC_RAL'.
      reqnum_ex = zic_prep_rolereq-docno.
      EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
      okcode_ex = old_ok_code.
      EXPORT okcode_ex TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_SEC_RESULT'.

      CLEAR reqnum_ex.
      CLEAR okcode_ex.

    WHEN  'GRC_RPL'.
      reqnum_ex = zic_prep_rolereq-docno.
      EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
      okcode_ex = old_ok_code.
      EXPORT okcode_ex TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_VIOL'.

      CLEAR reqnum_ex.
      CLEAR okcode_ex.

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
MODULE clear_data INPUT.
*Begin of <RD1K963151>.
  DATA: new_value TYPE i.
*End of <RD1K963151>.
  IF NOT  zic_prep_rolereq-docno IS INITIAL.

*  data : l_docno like  ZIC_PREP_ROLEREQ-docno.

    l_docno =  zic_prep_rolereq-docno.

*Begin of <RD1K963151>.
    LOOP AT SCREEN.
      IF screen-group3 = 'GP3'.
        screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'.
        screen-active = 0.
        screen-required = 0.
        screen-input = 0.
        screen-output = 0 .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*End of <RD1K963151>.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = l_docno
      IMPORTING
        output = l_docno.

    zic_prep_rolereq-docno = l_docno.

  ENDIF.

  IF old_doc_no <>  zic_prep_rolereq-docno.
    CLEAR g_hd_copied.
    CLEAR g_mult_module_fl.
    PERFORM destroy_ctrl.
  ENDIF.

  IF NOT moduleid IS INITIAL AND old_moduleid <> moduleid.
    g_tablctrl110_copied = ''.
    g_tablctrl111_copied = ''.
    g_tablctrl112_copied = ''.
    g_tablctrl113_copied = ''.
    g_tablctrl114_copied = ''.
    g_tablctrl115_copied = ''.

    """""""""""""""""""""""""""""""""""""""
    "addition by lipsy  for srm module introduction on 3.03.2015 RD1K996555
    g_tablctrl118_copied = ''.

    "end of addition by lipsy  for srm module introduction on 3.03.2015 RD1K996555

    """"""""""""""""""""""""""""""""""""""""""""
  ENDIF.

ENDMODULE.                 " clear_data  INPUT
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
  IF ( old_ok_code = 'CREATE' )
  OR ( old_ok_code = 'CROSSCO' )
  OR ( old_ok_code = 'CRCROLES' )
  OR ( old_ok_code = 'CHANGE' )
  OR ( old_ok_code = 'RELEASE' )
  OR ( old_ok_code = 'APPROVE' )
   OR ( old_ok_code = 'DISPLAY' AND  zic_prep_rolereq-comm_fl = 'X'
        AND  zic_prep_rolereq-status <> 'C' ).

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
    DESCRIBE TABLE tlinetab2 LINES g_lines_2.
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
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_sloc INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SLOC' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : l_plant LIKE zic_prep_rolerei-plant.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_plant.


  DATA   : it_t001l TYPE TABLE OF t001l WITH HEADER LINE.
  DATA   : it_excp_sl TYPE TABLE OF zmm_prep_sl_excp WITH HEADER LINE.
  DATA   : wa_t001l LIKE t001l.
  DATA   : l_zarea LIKE zmm_consm-zarea.

  SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
             TABLE it_t001l WHERE werks = l_plant.

  IF  zic_prep_rolereq-disc_mm_flag = 'X'.

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

  SELECT * FROM zmm_prep_sl_excp INTO TABLE it_excp_sl.

************************************

  LOOP AT it_excp_sl.

    READ TABLE it_t001l WITH KEY werks = it_excp_sl-werks
    lgort = it_excp_sl-lgort.

    IF sy-subrc = 0.

      DELETE it_t001l WHERE werks = it_excp_sl-werks
      AND lgort = it_excp_sl-lgort.

    ENDIF.

  ENDLOOP.

************************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGORT'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGOBE'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SLOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t001l
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t001l,ist_return_tab,g_field_tab..
  FREE  : it_t001l,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_approver INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : it_approver LIKE TABLE OF zmm_prep_approve.
  DATA : wa_approver LIKE zmm_prep_approve.

  DATA : it_approver1 LIKE TABLE OF zmm_prep_app_crc.
  DATA : wa_approver1 LIKE zmm_prep_app_crc.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.

    SELECT * FROM zmm_prep_app_crc INTO TABLE it_approver1.

  ELSE.

    SELECT * FROM zmm_prep_approve INTO TABLE it_approver.

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
  IF l_role_name = 'M11S'.                                  "22.05.06

    LOOP AT it_approver INTO wa_approver.

      CASE  zic_prep_rolereq-disc_mm_flag.

        WHEN 'X'.
          IF wa_approver-mm_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
        WHEN OTHERS.
          IF wa_approver-m11s_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.

  IF l_role_name = 'M11M'.

    LOOP AT it_approver INTO wa_approver.

      CASE  zic_prep_rolereq-disc_mm_flag.

        WHEN 'X'.
          IF wa_approver-mm_flag <> 'X'
             OR wa_approver-m11m_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
        WHEN OTHERS.
          IF wa_approver-mm_flag = 'X'
             OR wa_approver-m11m_flag <> 'X'.
            DELETE it_approver.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.
**************************************************22.05.06

  IF l_role_name = 'M8'.

    LOOP AT it_approver INTO wa_approver.

      IF wa_approver-m8_flag <> 'X'.
        DELETE it_approver.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'..

    IF l_role_name = 'M3'.

      LOOP AT it_approver1 INTO wa_approver1.

        IF wa_approver1-m3_flag <> 'X'.
          DELETE it_approver1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M3A'.                                 "22.05.06

      LOOP AT it_approver1 INTO wa_approver1.

        IF wa_approver1-m3a_flag <> 'X'.
          DELETE it_approver1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M3B'.

      LOOP AT it_approver1 INTO wa_approver1.

        IF wa_approver1-m3b_flag <> 'X'.
          DELETE it_approver1.
        ENDIF.

      ENDLOOP.

    ENDIF.                                                  " 22.05.06


    IF l_role_name = 'M11S'.

      LOOP AT it_approver1 INTO wa_approver1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
        CASE  zic_prep_rolereq-disc_mm_flag.

          WHEN 'X'.
            IF wa_approver1-mm_flag <> 'X'
               OR wa_approver1-m11s_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
          WHEN OTHERS.
            IF wa_approver1-mm_flag = 'X'
               OR wa_approver1-m11s_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M11M'.

      LOOP AT it_approver1 INTO wa_approver1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

        CASE  zic_prep_rolereq-disc_mm_flag.

          WHEN 'X'.
            IF wa_approver1-mm_flag <> 'X'
               OR wa_approver1-m11m_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
          WHEN OTHERS.
            IF wa_approver1-mm_flag = 'X'
               OR wa_approver1-m11m_flag <> 'X'.
              DELETE it_approver1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    it_approver[] = it_approver1[].

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
  g_field_wa-fieldname = 'APP_LEVEL'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
  g_field_wa-fieldname = 'L_DESC'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'APP_LEVEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-APPROVER'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_approver
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_approver,ist_return_tab, it_approver1,g_field_tab.
  FREE  : it_approver,ist_return_tab, it_approver1,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_receipt_loc INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC' AND screen-input =
0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA : it_recpt LIKE TABLE OF zmm_location.
  DATA : it_recpt TYPE STANDARD TABLE OF zmm_location.
  DATA : wa_recpt LIKE zmm_location.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

  SELECT * FROM zmm_location INTO TABLE it_recpt.
*WHERE bukrs = zic_prep_rolereq-ccode.      " Commented By Anjali Vala

  """""""""""""""""""""""""""""""""""""""""""""""""""""
  "commented by lipsy on 23.09.2014 for selecting for corresponding
  "company code RD1K994398
*    .
  """"end of comment by lipsy on 23.09.2014 for selecting for corresponding
  "company code RD1K994398
  """""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 23.09.2014 for selecting for corresponding
  "company code RD1K994398





  """"end of addition by lipsy on 23.09.2014 for selecting for corresponding
  "company code RD1K994398

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""


  IF l_role_name = 'M12'.

    LOOP AT it_recpt INTO wa_recpt.

      IF wa_recpt-loccg <> 'RL'.
        DELETE it_recpt.
      ENDIF.

    ENDLOOP.

  ENDIF.


  IF l_role_name = 'M17'.

    LOOP AT it_recpt INTO wa_recpt.

      IF wa_recpt-loccg <> 'CF'.
        DELETE it_recpt.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_LOCATION'.
  g_field_wa-fieldname = 'LOCCD'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_LOCATION'.
  g_field_wa-fieldname = 'LOCCG'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_LOCATION'.
  g_field_wa-fieldname = 'LOCDS'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LOCCD'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_recpt
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_recpt,ist_return_tab,g_field_tab.
  FREE  : it_recpt,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  IF sy-ucomm = 'EXT' .
    LEAVE PROGRAM.
  ENDIF.
*  IF  SY-UCOMM = 'BAC' AND OLD_OK_CODE = ' '.
*    LEAVE TO SCREEN 0.
*  ENDIF.



ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.

  old_doc_no =  zic_prep_rolereq-docno.
  old_userid =  zic_prep_rolereq-userid.
  old_disc_mm_flag =  zic_prep_rolereq-disc_mm_flag.
  old_moduleid = moduleid.


  IF LV_new > LV_Old.
   MESSAGE 'You do not meet the minimum designation criteria. Pls. contact SAP team with a copy of order for further action.' TYPE 'I'.
   LEAVE TO SCREEN sy-DYNNR.
  ENDIF.
ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

**---------- Changes Start date 24.06.2016 11:55:29-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .
*

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:55:29-----------------

    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER

***START OF COMMENT <RD1K983325>   CR: 30007580  dt: 05.04.2013.
*      g_ccode = ist_data-bukrs.
***end OF COMMENT <RD1K983325>.

**code added by CAB_AMITMOZA  <RD1K983325>   CR: 30007580  dt: 05.04.2013.
      g_ccode =  zic_prep_rolereq-ccode.
**code end by CAB_AMITMOZA  <RD1K983325>

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

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X'.

*  clear g_e_fl.

    IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.

*** 15/05/2007
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc <> 0.
        g_field = 'CRC_POS'.
        MESSAGE i200(zhelp).
      ELSE.
*** 31/05/2007
        IF NOT zmm_prep_crcdesg-role_pos IS INITIAL.
          SELECT SINGLE * FROM agr_users WHERE
                   uname = zic_prep_rolereq-userid AND
                   agr_name = zmm_prep_crcdesg-role_pos.
          IF sy-subrc = 0.
            PERFORM message1.
          ELSE.
            PERFORM message2.
          ENDIF.
        ENDIF.
      ENDIF.
***

      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc <> 0.
        g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MESSAGE i117(zhelp).
*      ELSEIF zic_prep_rolerei-role_name+0(1) <> 'C' AND zic_prep_rolerei-role_name+0(1) <> 'N'.
*        g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
*        MESSAGE i117(zhelp).
      ENDIF.

    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                      zic_prep_rolerei-role_name.
      IF sy-subrc <> 0.
        g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MESSAGE i118(zhelp).
      ENDIF.

    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
    CLEAR  zic_prep_rolerei-receipt_loc.
    CLEAR  zic_prep_rolerei-sloc.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR  zic_prep_rolerei-grp.
    CLEAR  zic_prep_rolerei-approver.

    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
    CLEAR  zic_prep_rolerei-receipt_loc.
    CLEAR  zic_prep_rolerei-sloc.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR  zic_prep_rolerei-grp.
    CLEAR  zic_prep_rolerei-approver.
  ENDIF.


  IF g_field IS INITIAL.
    g_field = 'ZIC_PREP_ROLEREI-PLANT'.
  ENDIF.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZIC_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZIC_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

    IF old_ok_code = 'CRCROLES'.

    ELSE.

      IF zmm_prep_roledes-mm_disc_flag = 'X'.

        IF  zic_prep_rolereq-disc_mm_flag = 'X'.
        ELSE.
          IF zic_prep_rolerei-role_name <> ''.
            MESSAGE e081(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

*  endif.

    IF NOT zic_prep_rolerei-plant IS INITIAL.

      SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                 TABLE it_bukrs  WHERE """bukrs =  zic_prep_rolereq-ccode  ""--->Commented By Suresh 24.01.2016
                                    "AND werks = zic_prep_rolerei-plant.   ""---Commented By Suresh 24.01.2016
                                    werks = zic_prep_rolerei-plant.        ""--->Code added By Suresh 24.01.2016
*--->Started-Comment By Suresh 24.01.2016
****      IF sy-subrc <> 0.
****        g_e_fl = 'X'.
****        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
****        g_i = g_curr_line.
****        MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
****
****      ENDIF.
*--->Ended-Comment By Suresh 24.01.2016
    ENDIF.

************finding group*******************

    REFRESH : it_cond, it_t024, it_t024_1.
    CLEAR   : wa_t024.
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

    ""
    ""
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
    IF  NOT zic_prep_rolerei-grp IS INITIAL.

      LOOP AT it_t024 INTO wa_t024.

        IF zic_prep_rolerei-grp = wa_t024-ekgrp.
          grp_flag = 'X'.
        ENDIF.

      ENDLOOP.

      IF grp_flag = 'X'.
        CLEAR grp_flag.
      ELSE.
        g_e_fl = 'X'.
        g_read_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-GRP'.
        MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl110_wa.
        MODIFY g_tablctrl110_itab
                  FROM g_tablctrl110_wa
                    INDEX tablctrl110-current_line.
        g_i = tablctrl110-current_line.
        MESSAGE i069(zhelp).
        CALL SCREEN 100.

      ENDIF.


      """"""""""""""
      REFRESH: itab_agr_users[].
      CLEAR:v_grp_comp.

      IF zic_prep_rolerei-grp IS NOT INITIAL.
        CONCATENATE '%' zic_prep_rolerei-grp  '%' INTO v_grp_comp.

        SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE
            itab_agr_users
            WHERE uname = zic_prep_rolereq-userid
          AND agr_name LIKE v_grp_comp
          AND to_dat = '99991231'.

        IF sy-subrc = 0.
          MESSAGE 'Purchase group already Assigned' TYPE 'I'.
        ENDIF.
      ENDIF.

      """"""""""""

    ENDIF.

***************************

    CLEAR : l_zarea, wa_t001l.
    REFRESH it_t001l.

    IF ( zic_prep_rolerei-role_name = 'M13' OR
       zic_prep_rolerei-role_name = 'M14' OR
        zic_prep_rolerei-role_name = 'M16' OR
        zic_prep_rolerei-role_name = 'M18' OR
        zic_prep_rolerei-role_name = 'M19' ) AND
        NOT zic_prep_rolerei-plant IS INITIAL.

      SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
                   TABLE it_t001l  WHERE werks = zic_prep_rolerei-plant.

      IF  sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
        MESSAGE e074(zhelp).

      ENDIF.

    ENDIF.

    IF  zic_prep_rolereq-disc_mm_flag = 'X'.

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

    IF  NOT zic_prep_rolerei-sloc IS INITIAL.

      LOOP AT it_t001l INTO wa_t001l.

        IF zic_prep_rolerei-sloc = wa_t001l-lgort.
          loc_flag = 'X'.
        ENDIF.

      ENDLOOP.

      IF loc_flag = 'X'.
        CLEAR loc_flag.
      ELSE.
** cab_ajit 07.02.2006
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-SLOC'.
        MESSAGE e073(zhelp).

      ENDIF.

    ENDIF.


***************************

    CLEAR wa_recpt.
    REFRESH it_recpt.

    IF ( zic_prep_rolerei-role_name = 'M12' OR
       zic_prep_rolerei-role_name = 'M17' ) AND
       NOT zic_prep_rolerei-receipt_loc IS INITIAL.

      SELECT * FROM zmm_location INTO TABLE it_recpt.

      IF zic_prep_rolerei-role_name = 'M12'.

        LOOP AT it_recpt INTO wa_recpt.

          IF wa_recpt-loccg <> 'RL'.
            DELETE it_recpt.
          ENDIF.

        ENDLOOP.

      ENDIF.


      IF zic_prep_rolerei-role_name = 'M17'.

        LOOP AT it_recpt INTO wa_recpt.

          IF wa_recpt-loccg <> 'CF'.
            DELETE it_recpt.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDIF.

    IF  NOT zic_prep_rolerei-receipt_loc IS INITIAL.

      LOOP AT it_recpt INTO wa_recpt.

        IF zic_prep_rolerei-receipt_loc = wa_recpt-loccd.
          loc_flag = 'X'.
        ENDIF.

      ENDLOOP.

      IF loc_flag = 'X'.
        CLEAR loc_flag.
      ELSE.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
        MESSAGE e075(zhelp).

      ENDIF.

    ENDIF.


*****************************
*****************************22.05.06

    IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.

      SELECT * FROM zmm_prep_app_crc INTO TABLE it_approver1.

    ELSE.

      SELECT * FROM zmm_prep_approve INTO TABLE it_approver.

    ENDIF.

    IF l_role_name = 'M11S'.                                "22.05.06

      LOOP AT it_approver INTO wa_approver.

        CASE  zic_prep_rolereq-disc_mm_flag.

          WHEN 'X'.
            IF wa_approver-mm_flag <> 'X'.
              DELETE it_approver.
            ENDIF.
          WHEN OTHERS.
            IF wa_approver-m11s_flag <> 'X'.
              DELETE it_approver.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF l_role_name = 'M11M'.

      LOOP AT it_approver INTO wa_approver.

        CASE  zic_prep_rolereq-disc_mm_flag.

          WHEN 'X'.
            IF wa_approver-mm_flag <> 'X'
               OR wa_approver-m11m_flag <> 'X'.
              DELETE it_approver.
            ENDIF.
          WHEN OTHERS.
            IF wa_approver-mm_flag = 'X'
               OR wa_approver-m11m_flag <> 'X'.
              DELETE it_approver.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.
**************************************************22.05.06

    IF l_role_name = 'M8'.
      LOOP AT it_approver INTO wa_approver.

        IF wa_approver-m8_flag <> 'X'.
          DELETE it_approver.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'..

      IF l_role_name = 'M3'.

        LOOP AT it_approver1 INTO wa_approver1.

          IF wa_approver1-m3_flag <> 'X'.
            DELETE it_approver1.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF l_role_name = 'M3A'.                               "22.05.06

        LOOP AT it_approver1 INTO wa_approver1.

          IF wa_approver1-m3a_flag <> 'X'.
            DELETE it_approver1.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF l_role_name = 'M3B'.

        LOOP AT it_approver1 INTO wa_approver1.

          IF wa_approver1-m3b_flag <> 'X'.
            DELETE it_approver1.
          ENDIF.

        ENDLOOP.

      ENDIF.                                                " 22.05.06


      IF l_role_name = 'M11S'.

        LOOP AT it_approver1 INTO wa_approver1.

          CASE  zic_prep_rolereq-disc_mm_flag.

            WHEN 'X'.
              IF wa_approver1-mm_flag <> 'X'
                 OR wa_approver1-m11s_flag <> 'X'.
                DELETE it_approver1.
              ENDIF.
            WHEN OTHERS.
              IF wa_approver1-mm_flag = 'X'
                 OR wa_approver1-m11s_flag <> 'X'.
                DELETE it_approver1.
              ENDIF.
          ENDCASE.

        ENDLOOP.

      ENDIF.

      IF l_role_name = 'M11M'.

        LOOP AT it_approver1 INTO wa_approver1.

          CASE  zic_prep_rolereq-disc_mm_flag.

            WHEN 'X'.
              IF wa_approver1-mm_flag <> 'X'
                 OR wa_approver1-m11m_flag <> 'X'.
                DELETE it_approver1.
              ENDIF.
            WHEN OTHERS.
              IF wa_approver1-mm_flag = 'X'
                 OR wa_approver1-m11m_flag <> 'X'.
                DELETE it_approver1.
              ENDIF.
          ENDCASE.

        ENDLOOP.

      ENDIF.

      it_approver[] = it_approver1[].

    ENDIF.
*********************************************22.05.06

    IF  NOT zic_prep_rolerei-approver IS INITIAL.

      LOOP AT it_approver INTO wa_approver.

        IF zic_prep_rolerei-approver = wa_approver-app_level.
          approver_flag = 'X'.
        ENDIF.

      ENDLOOP.

      IF approver_flag = 'X'.
        CLEAR approver_flag.
      ELSE.
        g_e_fl = 'X'.
        g_read_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
        MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl110_wa.
        MODIFY g_tablctrl110_itab
                  FROM g_tablctrl110_wa
                    INDEX tablctrl110-current_line.
        g_i = tablctrl110-current_line.
        MESSAGE e135(zhelp).
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
MODULE record_rej_id_data INPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> 'CHANGE'.
**13/04/07
    IF zic_prep_rolerei-rej_id IS INITIAL.
      zic_prep_rolerei-rej_id = sy-uname.
      zic_prep_rolerei-rej_date = sy-datum.
    ENDIF.

    IF NOT zic_prep_rolerei-rej_fl IS INITIAL AND
       zic_prep_rolerei-rej_fl_save IS INITIAL.

      SELECT SINGLE * FROM  zmm_prep_rej_lis  WHERE
        rej_code = zic_prep_rolerei-rej_fl .
      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        MESSAGE e111(zhelp).
      ELSE.
*        IF g_user = 'L1' AND zic_prep_rolerei-rej_fl <> 'R'.
*          g_e_fl = 'X'.
*          MESSAGE e111(zhelp).
        IF g_user = 'L3' AND zic_prep_rolerei-rej_fl <> 'B'.
          g_e_fl = 'X'.
          MESSAGE e111(zhelp).
*        ELSEIF g_user = 'IM' AND zic_prep_rolerei-rej_fl <> 'I'.
*          g_e_fl = 'X'.
*          MESSAGE e111(zhelp).
        ENDIF.
      ENDIF.
    ENDIF.
**
  ENDIF.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.

  DATA : tel_len TYPE i.
  tel_len = strlen(  zic_prep_rolereq-telno ).
  IF   zic_prep_rolereq-telno CN ' 0123456789-'.
    MESSAGE e097(zhelp).
  ELSE.
    IF tel_len < 7.
      MESSAGE e098(zhelp).
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data1 INPUT.

  IF old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  ELSE.

    SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                   zic_prep_rolerei-role_name.

  ENDIF.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_read  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_read INPUT.
  CLEAR g_read_fl.
ENDMODULE.                 " clear_read  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno INPUT.
  CLEAR g_srno.
  LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.
    g_srno = g_srno + 1.
    g_tablctrl110_wa-srno = g_srno.
    MODIFY g_tablctrl110_itab FROM g_tablctrl110_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl110_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl110_itab  LINES tablctrl110-lines.
  CLEAR g_srno.

ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup INPUT.
  IF NOT g_tabctrl100_itab[] IS INITIAL .

    DELETE ADJACENT DUPLICATES FROM g_tabctrl100_itab
    COMPARING role_name plant grp sloc receipt_loc approver.

  ENDIF.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
  g_role_name_prev = zic_prep_rolerei-role_name.
ENDMODULE.                 " init_data  INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: modify table
MODULE tablctrl110_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl110_wa.

  SELECT SINGLE * FROM zmm_prep_rolegrp WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  IF zic_prep_rolerei-rej_fl = ''.

    IF sy-subrc = 0 AND old_ok_code = 'APPROVE'.
      IF zmm_prep_rolegrp-approver1 = g_user
         OR zmm_prep_rolegrp-approver2 = g_user
         OR zmm_prep_rolegrp-approver3 = g_user

      """""""""""""""""""""""""""
        "added by lipsy for l2 approver on 20.03.2015 RD1K996555
            OR ( moduleid = 'SRM' AND zmm_prep_rolegrp-approver1 = g_user_l2 )
             "End of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
       """"""""""""""""""""""""
        .
      ELSE.

        IF okcode_100 = 'SAV'.
          IF err_flg <> 'X'.
            err_flg = 'X'.
            CLEAR : sy-ucomm, okcode_100.
          ENDIF.
          MESSAGE e047(zhelp) WITH zmm_prep_rolegrp-role_type.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT g_tablctrl110_wa-role_name IS INITIAL.
    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.
        g_tabctrl100_wa-role_desc = zmm_prep_rolecrc-brief_desc.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
      IF sy-subrc = 0.
        g_tablctrl110_wa-role_desc = zmm_prep_roledes-brief_desc.
*Begin  of <RD1K962817>.
        IF g_tablctrl110_wa-role_name = 'M8'.
          g_tablctrl110_wa-approver = zic_prep_rolereq-persk.
        ENDIF.
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
  ENDIF.

  MODIFY g_tablctrl110_itab
     FROM g_tablctrl110_wa
     INDEX tablctrl110-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl110_wa TO g_tablctrl110_itab.
  ENDIF.

  IF g_tablctrl110_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl110_wa-flag.
    APPEND g_tablctrl110_wa TO g_tablctrl110_itab.
  ENDIF.

ENDMODULE.                    "TABLCTRL110_modify INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: mark table
MODULE tablctrl110_mark INPUT.
  IF tablctrl110-line_sel_mode = 1 AND
     g_tablctrl110_wa-flag = 'X'.
    LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa
      WHERE flag = 'X'.
      g_tablctrl110_wa-flag = ''.
      MODIFY g_tablctrl110_itab
        FROM g_tablctrl110_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl110_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl110_itab
    FROM g_tablctrl110_wa
    INDEX tablctrl110-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL110_mark INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: process user command
MODULE tablctrl110_user_command INPUT.
  """""""""
  """""""""""""""
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL110'
                              'G_TABLCTRL110_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL110_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_110 INPUT.

  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl110-top_line + g_cursor_line - 1.
  g_curr_line_110 = g_curr_line.

ENDMODULE.                 " get_cursor_line_110  INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: modify table
MODULE tablctrl111_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl111_wa.

  SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  g_tablctrl111_wa-role_desc = zpm_prep_roledes-brief_desc.

  MODIFY g_tablctrl111_itab
    FROM g_tablctrl111_wa
    INDEX tablctrl111-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl111_wa TO g_tablctrl111_itab.
  ENDIF.

  IF g_tablctrl111_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl111_wa-flag.
    APPEND g_tablctrl111_wa TO g_tablctrl111_itab.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_modify INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: mark table
MODULE tablctrl111_mark INPUT.
  IF tablctrl111-line_sel_mode = 1 AND
     g_tablctrl111_wa-flag = 'X'.
    LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa
      WHERE flag = 'X'.
      g_tablctrl111_wa-flag = ''.
      MODIFY g_tablctrl111_itab
        FROM g_tablctrl111_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl111_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl111_itab
    FROM g_tablctrl111_wa
    INDEX tablctrl111-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL111_mark INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: process user command
MODULE tablctrl111_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL111'
                              'G_TABLCTRL111_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL111_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_111 INPUT.

  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl111-top_line + g_cursor_line - 1.
  g_curr_line_111 = g_curr_line.

ENDMODULE.                 " get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11 INPUT.

  SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data11a INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.


**---------- Changes Start date 24.06.2016 11:54:33-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:54:33-----------------


    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X'.

    SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE i118(zhelp).
    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
    CLEAR  zic_prep_rolerei-shop_no.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
    CLEAR  zic_prep_rolerei-shop_no.
    CLEAR  zic_prep_rolerei-plant.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-PLANT'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.


    IF NOT zic_prep_rolerei-plant IS INITIAL.

      SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                 TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                    AND werks = zic_prep_rolerei-plant.
      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
        g_i = g_curr_line.
        MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-role_name IS INITIAL.

      SELECT * FROM zpm_prep_roledes INTO CORRESPONDING FIELDS OF
                  TABLE it_role.

      IF zic_prep_rolereq-ccode = 'BDW' OR
         zic_prep_rolereq-ccode = 'SBW'.
      ELSE.
        DELETE it_role WHERE role_type = 'PM14' OR
        role_type = 'PM15' OR role_type = 'PM16'.
      ENDIF.

      LOOP AT it_role .
        IF it_role-role_type = zic_prep_rolerei-role_name.
          check_role_flag = 'X'.
        ENDIF.
      ENDLOOP.

      IF check_role_flag = 'X'.
        CLEAR check_role_flag.
      ELSE.
        MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
        zic_prep_rolereq-ccode .
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.                 " validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno11 INPUT.

  CLEAR g_srno.
  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.
    g_srno = g_srno + 1.
    g_tablctrl111_wa-srno = g_srno.
    MODIFY g_tablctrl111_itab FROM g_tablctrl111_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl111_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl111_itab  LINES tablctrl111-lines.
  CLEAR g_srno.

ENDMODULE.                 " change_srno11  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_pm INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
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

  SELECT * FROM zpm_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role.

  SORT it_role ASCENDING BY sort_field.

  IF zic_prep_rolereq-ccode = 'BDW' OR
     zic_prep_rolereq-ccode = 'SBW'.
  ELSE.
    DELETE it_role WHERE role_type = 'PM14' OR
    role_type = 'PM15' OR role_type = 'PM16'.
  ENDIF.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_shop_no INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SHOP_NO' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
  TYPES :
    BEGIN OF ty_shop,
      werks LIKE t357-werks,
      beber LIKE t357-beber,
      fing  LIKE t357-fing,
    END OF ty_shop.

  DATA   : it_shop TYPE TABLE OF ty_shop WITH HEADER LINE.

  SELECT * FROM t357 INTO CORRESPONDING FIELDS OF
             TABLE it_shop  WHERE werks =  '53C1' OR
                                  werks =  '24C1'.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BEBER'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SHOP_NO'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_shop
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_bukrs,ist_return_tab.
  FREE : it_bukrs,ist_return_tab.

ENDMODULE.                 " POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_MODULEID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_moduleid INPUT.

  DATA : it_module LIKE TABLE OF zic_modules.
  DATA : wa_module LIKE zic_modules.

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

  l_docno = zic_prep_rolereq-docno.

* clear l_dynnr.

  IF old_ok_code = 'CREATE'  OR
     old_ok_code = 'CROSSCO'  OR
     old_ok_code = 'CRCROLES' OR
     old_ok_code = 'CHANGE'.

    SELECT  moduleid FROM zice_prep_module INTO CORRESPONDING FIELDS
     OF TABLE it_module.

  ELSE.

    SELECT DISTINCT moduleid FROM zic_prep_rolerei INTO
      CORRESPONDING FIELDS OF TABLE it_module WHERE docno = l_docno.

  ENDIF.

  LOOP AT it_module INTO wa_module.
    SELECT SINGLE * FROM zice_prep_module WHERE moduleid =
    wa_module-moduleid.
    wa_module-z_desc = zice_prep_module-z_desc.
    MODIFY it_module FROM wa_module.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MODULEID'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'MODULEID'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_module
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_module,ist_return_tab.
  FREE  : it_module,ist_return_tab.

ENDMODULE.                 " POV_MODULEID  INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: modify table
MODULE tablctrl112_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl112_wa.
  SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
*       g_val_err = 'X'.
*       message i102(zhelp) with zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  g_tablctrl112_wa-role_desc = zps_prep_roledes-brief_desc.

  MODIFY g_tablctrl112_itab
   FROM g_tablctrl112_wa
   INDEX tablctrl112-current_line.
  IF sy-subrc <> 0.
    APPEND g_tablctrl112_wa TO g_tablctrl112_itab.
  ENDIF.

  IF g_tablctrl112_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl112_wa-flag.
    APPEND g_tablctrl112_wa TO g_tablctrl112_itab.
  ENDIF.

ENDMODULE.                    "TABLCTRL112_modify INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: mark table
MODULE tablctrl112_mark INPUT.
  IF tablctrl112-line_sel_mode = 1 AND
     g_tablctrl112_wa-flag = 'X'.
    LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa
      WHERE flag = 'X'.
      g_tablctrl112_wa-flag = ''.
      MODIFY g_tablctrl112_itab
        FROM g_tablctrl112_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl112_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl112_itab
    FROM g_tablctrl112_wa
    INDEX tablctrl112-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL112_mark INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: process user command
MODULE tablctrl112_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL112'
                              'G_TABLCTRL112_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL112_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_112 INPUT.
  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl112-top_line + g_cursor_line - 1.
  g_curr_line_112 = g_curr_line.

ENDMODULE.                 " get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data12 INPUT.

  IF NOT zic_prep_rolerei-role_name IS INITIAL.

    SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

    IF g_role_name_prev <> zic_prep_rolerei-role_name AND
                NOT g_role_name_prev IS INITIAL.
      g_role_name_flag = 'X'.
    ENDIF.
    g_read_fl = 'X'.

  ENDIF.
ENDMODULE.                 " validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data12a INPUT.
  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

**---------- Changes Start date 24.06.2016 11:54:00-------------------
*  SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                   a~persk a~sbmod  c~designo c~r_p_cd c~version
                 d~sdesig_text AS designation d~adesig_text AS adesignation
                 d~disc_cd AS disc_cd
                   INTO CORRESPONDING FIELDS OF TABLE ist_data
              FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                    ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                       ON c~designo = d~desig_code AND
                           c~r_p_cd  = d~r_p_cd AND
                           c~version = d~version )
                        WHERE a~pernr =  zic_prep_rolereq-userid AND
                              a~sprps = ' ' AND
                              a~endda = '99991231' AND
                              c~sprps = ' ' AND
                              c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:54:00-----------------


    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X' AND NOT zic_prep_rolerei-role_name IS INITIAL
     AND NOT zic_prep_rolerei-service IS INITIAL.

    SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE i118(zhelp).
    ELSE.
      g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
*  clear  ZIC_PREP_ROLEREI-SERVICE.
    CLEAR  zic_prep_rolerei-project.
    CLEAR  zic_prep_rolerei-location.
*  clear  ZIC_PREP_ROLEREI-REGION.
    CLEAR  zic_prep_rolerei-asset.
    CLEAR  zic_prep_rolerei-basin.
    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
*      clear  ZIC_PREP_ROLEREI-SERVICE.
    CLEAR  zic_prep_rolerei-project.
    CLEAR  zic_prep_rolerei-location.
*      clear  ZIC_PREP_ROLEREI-REGION.
    CLEAR  zic_prep_rolerei-asset.
    CLEAR  zic_prep_rolerei-basin.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-SERVICE'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.


    IF NOT zic_prep_rolerei-service IS INITIAL.

      SELECT * FROM zps_prep_service INTO CORRESPONDING FIELDS OF
                 TABLE it_service WHERE
                 service = zic_prep_rolerei-service.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
        g_i = g_curr_line_112.
        MESSAGE e169(zhelp) WITH zic_prep_rolerei-role_name.
      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-project IS INITIAL.

      SELECT * FROM zps_prep_project INTO CORRESPONDING FIELDS OF
                 TABLE it_project WHERE
                 service = zic_prep_rolerei-service AND
                 project = zic_prep_rolerei-project.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
        g_i = g_curr_line.
        MESSAGE e170(zhelp) WITH zic_prep_rolerei-project.
      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-location IS INITIAL.

      SELECT * FROM zps_prep_loca INTO CORRESPONDING FIELDS OF
             TABLE it_loca WHERE ccode = zic_prep_rolereq-ccode
             AND location = zic_prep_rolerei-location AND
             service = zic_prep_rolerei-service.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
        g_i = g_curr_line.
        MESSAGE e171(zhelp) WITH zic_prep_rolerei-location.
      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-asset IS INITIAL.

      IF zic_prep_rolereq-ccode = 'MUM'.
        SELECT * FROM zps_prep_asst_ex INTO CORRESPONDING FIELDS OF
              TABLE it_asset WHERE ccode = 'MUM' AND
                    asset = zic_prep_rolerei-asset.

        IF sy-subrc <> 0 AND zic_prep_rolerei-asset <> 'ALL'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-ASSET'.
          g_i = g_curr_line.
          MESSAGE e172(zhelp) WITH zic_prep_rolerei-asset.
        ENDIF.

      ELSE.
        IF zic_prep_rolerei-asset <> zic_prep_rolereq-ccode AND
           zic_prep_rolerei-asset <> 'ALL'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-ASSET'.
          g_i = g_curr_line.
          MESSAGE e172(zhelp) WITH zic_prep_rolerei-asset.
        ENDIF.
      ENDIF.
    ENDIF.


    IF NOT zic_prep_rolerei-basin IS INITIAL.

      IF zic_prep_rolerei-basin <> zic_prep_rolereq-ccode AND
          zic_prep_rolerei-basin <> 'ALL'.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-BASIN'.
        g_i = g_curr_line.
        MESSAGE e173(zhelp) WITH zic_prep_rolerei-basin.
      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-role_name IS INITIAL AND
           NOT zic_prep_rolerei-service IS INITIAL.

      IF zic_prep_rolerei-service <> 'P1' AND zic_prep_rolerei-service <> 'P2' AND zic_prep_rolerei-service <> 'P3' OR zic_prep_rolerei-service <> 'PS'.
        SELECT SINGLE * FROM zps_prep_serv_rl WHERE
                       service = zic_prep_rolerei-service AND
                       role_type = zic_prep_rolerei-role_name.

        IF sy-subrc <> 0.
          MESSAGE e201(zhelp) WITH zic_prep_rolerei-role_name.
        ENDIF.
      ENDIF.


*     select * from zps_prep_roledes into corresponding fields of
*                 table it_role.
*
*     loop at it_role .
*        if it_role-role_type = zic_prep_rolerei-role_name.
*           check_role_flag = 'X'.
*        endif.
*     endloop.
*
*     if check_role_flag = 'X'.
*        clear check_role_flag.
*     else.
*        message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
*        ZIC_PREP_ROLEREQ-ccode .
*     endif.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno12 INPUT.
  CLEAR g_srno.
  LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.
    g_srno = g_srno + 1.
    g_tablctrl112_wa-srno = g_srno.
    MODIFY g_tablctrl112_itab FROM g_tablctrl112_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl112_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl112_itab  LINES tablctrl112-lines.
  CLEAR g_srno.
ENDMODULE.                 " change_srno12  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_ps INPUT.

  DATA : l_service LIKE zic_prep_rolerei-service.
  DATA : g_fldval TYPE zps_prep_roledes-role_type.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  DATA: BEGIN OF seltab OCCURS 0,
          sign(1),
          option(2),
          low       LIKE zic_prep_rolerei-role_name,
          high      LIKE zic_prep_rolerei-role_name,
        END OF seltab.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SERVICE'
      index = loop_step
      repid = sy-cprog
      dynnr = '0112'
    IMPORTING
      value = l_service.

  IF l_service = 'P1' OR l_service = 'P2' OR l_service = 'P3' OR l_service = 'PS'.

    IF l_service = 'P1'.
      CONCATENATE  'BU' '%' INTO g_fldval.   " PRA Module changes
    ELSEIF l_service = 'P2'.
      CONCATENATE  'APP' '%' INTO g_fldval.   " PRA Module changes
    ELSEIF l_service = 'P3'.
      CONCATENATE  'CP' '%' INTO g_fldval.   " PRA Module changes
    ELSEIF l_service = 'PS'.
      CONCATENATE  'PS' '%' INTO g_fldval.   " PRA Module changes
    ENDIF.
    SELECT * FROM zps_prep_roledes INTO CORRESPONDING FIELDS OF
                TABLE it_role WHERE role_type LIKE g_fldval.

  ELSE.
    SELECT * FROM zps_prep_serv_rl INTO CORRESPONDING FIELDS OF
          TABLE it_role WHERE service = l_service.

    LOOP AT it_role.

      seltab-sign   = 'I'.
      seltab-option = 'EQ'.
      seltab-low    = it_role-role_type.
      APPEND seltab.

    ENDLOOP.

    SELECT * FROM zps_prep_roledes INTO CORRESPONDING FIELDS OF
                TABLE it_role WHERE role_type IN seltab.
  ENDIF.


  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab, seltab.
  FREE  : it_role,ist_return_tab, g_field_tab, seltab.
  CLEAR : g_field_wa.



ENDMODULE.                 " POV_ROLE_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  dummy  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dummy INPUT.
  PERFORM check_module_fi.
  IF NOT old_moduleid IS INITIAL AND old_moduleid <> moduleid AND
*    old_ok_code = 'CHANGE'.
**13/04/07
     ( old_ok_code = 'CHANGE' OR old_ok_code = 'APPROVE' ).
    okcode_100 = 'SAV'.
    new_moduleid = moduleid.
    moduleid = old_moduleid.
    module_changed_flag = 'X'.
    CLEAR old_moduleid.
  ENDIF.
ENDMODULE.                 " dummy  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SERVIVES_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_servises_ps INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SERVICE' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_service type table of zps_prep_service with header line.

  SELECT * FROM zps_prep_service INTO CORRESPONDING FIELDS OF
             TABLE it_service.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SERVICE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SERVICE'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_service
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_service,ist_return_tab.
  FREE : it_service,ist_return_tab.

ENDMODULE.                 " POV_SERVIVES_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PROJECTS_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_projects_ps INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-PROJECT' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

*  data : loop_step like sy-stepl.
*  Data : l_service like ZIC_PREP_ROLEREI-SERVICE.
*
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SERVICE'
      index = loop_step
      repid = sy-cprog
      dynnr = '0112'
    IMPORTING
      value = l_service.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_project type table of zps_prep_project with header line.

  SELECT * FROM zps_prep_project INTO CORRESPONDING FIELDS OF
             TABLE it_project WHERE service = l_service.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PROJECT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-PROJECT'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_project
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_project,ist_return_tab.
  FREE : it_project,ist_return_tab.

ENDMODULE.                 " POV_PROJECTS_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ASSET_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_asset_ps INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ASSET' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SERVICE'
      index = loop_step
      repid = sy-cprog
      dynnr = '0112'
    IMPORTING
      value = l_service.

*  types :
*        begin of asset_ty,
*              ccode type ZIC_PREP_ROLEREQ-CCODE,
*              asset type ZIC_PREP_ROLEREI-BASIN,
*              a_desc type Zchar80,
*        end of asset_ty.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_asset type table of asset_ty with header line.

  IF zic_prep_rolereq-ccode = 'MUM'.
    SELECT * FROM zps_prep_asst_ex INTO CORRESPONDING FIELDS OF TABLE
              it_asset.
  ELSE.
    MOVE zic_prep_rolereq-ccode TO it_asset-asset.
    MOVE zic_prep_rolereq-ccode TO it_asset-ccode.
    APPEND it_asset.
  ENDIF.
  MOVE 'ALL'                  TO it_asset-asset.
  MOVE 'ALL'                  TO it_asset-ccode.
  MOVE 'ALL'                  TO it_asset-a_desc.

  IF l_service <> 'WS'.
    APPEND it_asset.
  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ASSET'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ASSET'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_asset
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_asset,ist_return_tab.
  FREE  : it_asset,ist_return_tab.
  CLEAR : it_asset.

ENDMODULE.                 " POV_ASSET_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_BASIN_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_basin_ps INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-BASIN' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

*  types :
*        begin of basin_ty,
*              ccode type ZIC_PREP_ROLEREQ-CCODE,
*              basin type ZIC_PREP_ROLEREI-BASIN,
*              b_desc type Zchar80,
*        end of basin_ty.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_basin type table of basin_ty with header line.

  MOVE zic_prep_rolereq-ccode TO it_basin-basin.
  MOVE zic_prep_rolereq-ccode TO it_basin-ccode.
  SELECT SINGLE * FROM t001 WHERE bukrs = zic_prep_rolereq-ccode.
  MOVE t001-butxt TO it_basin-b_desc.
  APPEND it_basin.
  MOVE 'ALL'                  TO it_basin-basin.
  MOVE 'ALL'                  TO it_basin-ccode.
  MOVE 'ALL'                  TO it_basin-b_desc.
  APPEND it_basin.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BASIN'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-BASIN'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_basin
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_basin,ist_return_tab.
  FREE : it_basin,ist_return_tab.

ENDMODULE.                 " POV_BASIN_PS  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_LOCATION_PS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_location_ps INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-LOCATION' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SERVICE'
      index = loop_step
      repid = sy-cprog
      dynnr = '0112'
    IMPORTING
      value = l_service.

*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
*  DATA   : it_location type table of zps_prep_loc with header line.

  SELECT * FROM zps_prep_loca INTO CORRESPONDING FIELDS OF
             TABLE it_loca WHERE service = l_service AND
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

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LOCATION'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-LOCATION'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_loca
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_loca,ist_return_tab.
  FREE : it_loca,ist_return_tab.

ENDMODULE.                 " POV_LOCATION_PS  INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: modify table
MODULE tablctrl113_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl113_wa.

  SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  g_tablctrl113_wa-role_desc = zpp_prep_roledes-brief_desc.

  MODIFY g_tablctrl113_itab
  FROM g_tablctrl113_wa
  INDEX tablctrl113-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl113_wa TO g_tablctrl113_itab.
  ENDIF.

  IF g_tablctrl113_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl113_wa-flag.
    APPEND g_tablctrl113_wa TO g_tablctrl113_itab.
  ENDIF.

ENDMODULE.                    "TABLCTRL113_modify INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: mark table
MODULE tablctrl113_mark INPUT.
  IF tablctrl113-line_sel_mode = 1 AND
     g_tablctrl113_wa-flag = 'X'.
    LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa
      WHERE flag = 'X'.
      g_tablctrl113_wa-flag = ''.
      MODIFY g_tablctrl113_itab
        FROM g_tablctrl113_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl113_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl113_itab
    FROM g_tablctrl113_wa
    INDEX tablctrl113-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL113_mark INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: process user command
MODULE tablctrl113_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL113'
                              'G_TABLCTRL113_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL113_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_113 INPUT.

  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl113-top_line + g_cursor_line - 1.
  g_curr_line_113 = g_curr_line.

ENDMODULE.                 " get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data13 INPUT.

  SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                  zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data13a INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

**---------- Changes Start date 24.06.2016 11:52:12-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .
*

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:52:12-----------------


    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X'.

    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE i118(zhelp).
    ELSE.
      g_field = 'ZIC_PREP_ROLEREI-PLANT'.
    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR  zic_prep_rolerei-sloc.
    CLEAR  zic_prep_rolerei-res.
    CLEAR  zic_prep_rolerei-ctf_sloc.
    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR  zic_prep_rolerei-sloc.
    CLEAR  zic_prep_rolerei-res.
    CLEAR  zic_prep_rolerei-ctf_sloc.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-PLANT'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.


    IF NOT zic_prep_rolerei-plant IS INITIAL.

      SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                     TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                        AND werks = zic_prep_rolerei-plant.
      IF sy-subrc = 0.

        SELECT SINGLE * FROM zhelp_pproles1 INTO CORRESPONDING FIELDS OF
                             zhelp_pproles1 WHERE
                             role_type = zic_prep_rolerei-role_name AND
                             plant     = zic_prep_rolerei-plant.

        IF sy-subrc <> 0.

          SELECT SINGLE * FROM zpp_prep_generic INTO CORRESPONDING FIELDS OF
                               zpp_prep_generic WHERE
                               role_type = zic_prep_rolerei-role_name AND
                               plant     = zic_prep_rolerei-plant.
          IF sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            MESSAGE e195(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.

        ENDIF.
      ELSE.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
        g_i = g_curr_line_113.
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
        g_i = g_curr_line.
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
        g_i = g_curr_line.
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
        MESSAGE e073(zhelp) WITH zic_prep_rolerei-ctf_sloc.

      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-role_name IS INITIAL.

      SELECT * FROM zpp_prep_roledes INTO CORRESPONDING FIELDS OF
                  TABLE it_role.

      LOOP AT it_role .
        IF it_role-role_type = zic_prep_rolerei-role_name.
          check_role_flag = 'X'.
        ENDIF.
      ENDLOOP.

      IF check_role_flag = 'X'.
        CLEAR check_role_flag.
      ELSE.
        MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
        zic_prep_rolereq-ccode .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno13 INPUT.

  CLEAR g_srno.
  LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.
    g_srno = g_srno + 1.
    g_tablctrl113_wa-srno = g_srno.
    MODIFY g_tablctrl113_itab FROM g_tablctrl113_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl113_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl113_itab  LINES tablctrl113-lines.
  CLEAR g_srno.

ENDMODULE.                 " change_srno13  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_pp INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  SELECT * FROM zpp_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role.

  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZPP_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_plant_pp INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
             TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-PLANT'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_bukrs
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_bukrs,ist_return_tab.
  FREE : it_bukrs,ist_return_tab.

ENDMODULE.                 " POV_PLANT_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_sloc_pp INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SLOC' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0113'
    IMPORTING
      value = l_plant.

  SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
             TABLE it_t001l  WHERE werks = l_plant.

************************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGORT'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGOBE'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SLOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t001l
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t001l,ist_return_tab,g_field_tab..
  FREE  : it_t001l,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.


ENDMODULE.                 " POV_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RES_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_res_pp INPUT.

  DATA : l_role_type LIKE zic_prep_rolerei-role_name .

  LOOP AT SCREEN.
    IF screen-name = 'ZIC_PREP_ROLEREI-RES' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0113'
    IMPORTING
      value = l_role_type.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0113'
    IMPORTING
      value = l_plant.

  SELECT * FROM zpp_prep_res INTO CORRESPONDING FIELDS OF
             TABLE it_res  WHERE role_type = l_role_type AND
             plant = l_plant..

************************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'RES'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-RES'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_res
*     FIELD_TAB       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_res,ist_return_tab,g_field_tab..
  FREE  : it_res,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_RES_PP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CTF_SLOC_PP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_ctf_sloc_pp INPUT.

  DATA : l_sloc LIKE zic_prep_rolerei-sloc .

  LOOP AT SCREEN.
    IF screen-name = 'ZIC_PREP_ROLEREI-CTF_SLOC' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0113'
    IMPORTING
      value = l_role_type.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0113'
    IMPORTING
      value = l_plant.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SLOC'
      index = loop_step
      repid = sy-cprog
      dynnr = '0113'
    IMPORTING
      value = l_sloc.

***********************************

  SELECT SINGLE * FROM zpp_prep_droleex WHERE role_type = l_role_type
         AND plant = l_plant AND sloc = l_sloc.

  IF sy-subrc = 0.

    CONCATENATE 'LGORT'  'LIKE'  INTO g_line SEPARATED BY
    space.
    CONCATENATE g_line+0(10) '''' '%Z%' ''''  INTO
                g_line.
    APPEND g_line TO it_cond.

    SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
               TABLE it_t001l  WHERE werks = l_plant AND
               (it_cond).
  ENDIF.
***********************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGORT'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGOBE'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SLOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t001l
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t001l,ist_return_tab,g_field_tab..
  FREE  : it_t001l,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_CTF_SLOC_PP  INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: modify table
MODULE tablctrl114_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl114_wa.

  SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  g_tablctrl114_wa-role_desc = zpp_prep_roledes-brief_desc.

  MODIFY g_tablctrl114_itab
    FROM g_tablctrl114_wa
    INDEX tablctrl114-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl114_wa TO g_tablctrl114_itab.
  ENDIF.

  IF g_tablctrl114_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl114_wa-flag.
    APPEND g_tablctrl114_wa TO g_tablctrl114_itab.
  ENDIF.

ENDMODULE.                    "TABLCTRL114_modify INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: mark table
MODULE tablctrl114_mark INPUT.
  IF tablctrl114-line_sel_mode = 1 AND
     g_tablctrl114_wa-flag = 'X'.
    LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa
      WHERE flag = 'X'.
      g_tablctrl114_wa-flag = ''.
      MODIFY g_tablctrl114_itab
        FROM g_tablctrl114_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl114_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl114_itab
    FROM g_tablctrl114_wa
    INDEX tablctrl114-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL114_mark INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: process user command
MODULE tablctrl114_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL114'
                              'G_TABLCTRL114_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL114_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_114 INPUT.

  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl114-top_line + g_cursor_line - 1.
  g_curr_line_114 = g_curr_line.

ENDMODULE.                 " get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data14 INPUT.

  SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data14a INPUT.
  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

**---------- Changes Start date 24.06.2016 11:51:22-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                a~persk a~sbmod  c~designo c~r_p_cd c~version
              d~sdesig_text AS designation d~adesig_text AS adesignation
              d~disc_cd AS disc_cd
                INTO CORRESPONDING FIELDS OF TABLE ist_data
           FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                 ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                    ON c~designo = d~desig_code AND
                        c~r_p_cd  = d~r_p_cd AND
                        c~version = d~version )
                     WHERE a~pernr =  zic_prep_rolereq-userid AND
                           a~sprps = ' ' AND
                           a~endda = '99991231' AND
                           c~sprps = ' ' AND
                           c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:51:22-----------------


    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X'.

    SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name AND
                    disc_fi_fl = zic_prep_rolereq-disc_fi_flag.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      IF zic_prep_rolereq-disc_fi_flag = 'X' AND
      zic_prep_rolerei-role_name = 'SXX'.
      ELSE.
        MESSAGE i118(zhelp).
      ENDIF.
    ELSE.
      g_field = 'ZIC_PREP_ROLEREI-PLANT'.
    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
    CLEAR  zic_prep_rolerei-sale_org.
    CLEAR  zic_prep_rolerei-div.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR  zic_prep_rolerei-ship_point.
    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
    CLEAR  zic_prep_rolerei-sale_org.
    CLEAR  zic_prep_rolerei-div.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR  zic_prep_rolerei-ship_point.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-PLANT'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

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
***
      ELSEIF zic_prep_rolereq-ccode = 'MUM' AND
             ( zic_prep_rolereq-fundc1 = 'MUMPHPOP' OR
             zic_prep_rolereq-fundc1 = 'MUMPHPSP' )  AND    "18092015
              zic_prep_rolerei-sale_org <> 'HZRS'.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
        g_i = g_curr_line_114.
        MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
      ELSE.
        IF zic_prep_rolereq-ccode = 'MUM' AND
        zic_prep_rolereq-fundc1 <> 'MUMPHPOP' AND
          zic_prep_rolereq-fundc1 <> 'MUMPHPSP' AND         "18092015
        zic_prep_rolerei-sale_org = 'HZRS'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          g_i = g_curr_line_114.
          MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
        ENDIF.
***
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

    IF NOT zic_prep_rolerei-role_name IS INITIAL.

*      SELECT * FROM ZSD_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
*               TABLE IT_ROLE WHERE
*                  DISC_FI_FL = ZIC_PREP_ROLEREQ-DISC_FI_FLAG.
*      LOOP AT IT_ROLE .
*        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
*          CHECK_ROLE_FLAG = 'X'.
*        ENDIF.
*      ENDLOOP.
*
*      IF ZIC_PREP_ROLEREQ-DISC_FI_FLAG = 'X' AND
*      ZIC_PREP_ROLEREI-ROLE_NAME = 'SXX'.
*        CHECK_ROLE_FLAG = 'X'.
*      ENDIF.
*
*      IF CHECK_ROLE_FLAG = 'X'.
*        CLEAR CHECK_ROLE_FLAG.
*      ELSE.
*        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
*        ZIC_PREP_ROLEREQ-CCODE .
*      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno14 INPUT.

  CLEAR g_srno.
  LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.
    g_srno = g_srno + 1.
    g_tablctrl114_wa-srno = g_srno.
    MODIFY g_tablctrl114_itab FROM g_tablctrl114_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl114_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl114_itab  LINES tablctrl114-lines.
  CLEAR g_srno.

ENDMODULE.                 " change_srno14  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_sd INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  SELECT * FROM zsd_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role.

  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZSD_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_plant_sd INPUT.

  DATA : l_vkorg LIKE tvkwz-vkorg.
  DATA : l_div LIKE zic_prep_rolerei-div.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SALE_ORG'
      index = loop_step
      repid = sy-cprog
      dynnr = '0114'
    IMPORTING
      value = l_vkorg.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'DIV'
      index = loop_step
      repid = sy-cprog
      dynnr = '0114'
    IMPORTING
      value = l_div.

  DATA : it_tvkwz LIKE TABLE OF tvkwz WITH HEADER LINE.

*  select * from zd_t001w_bukrs into corresponding fields of
*             table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE.

  SELECT * FROM TVTA INTO CORRESPONDING FIELDS OF TVTA UP TO 1 ROWS
 WHERE VKORG = L_VKORG AND SPART = L_DIV
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT * FROM tvkwz INTO CORRESPONDING FIELDS OF
             TABLE it_tvkwz  WHERE vkorg =  l_vkorg
             AND vtweg = tvta-vtweg.
    sort it_tvkwz by werks.
  DELETE ADJACENT DUPLICATES FROM it_tvkwz COMPARING werks.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'TVKWZ'.
  g_field_wa-fieldname = 'VKORG'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'TVKWZ'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-PLANT'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_tvkwz
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_tvkwz,ist_return_tab,g_field_tab.
  FREE : it_tvkwz,ist_return_tab,g_field_tab.

ENDMODULE.                 " POV_PLANT_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SALE_ORG_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_sale_org_sd INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SALE_ORG' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0114'
    IMPORTING
      value = l_role_type.

  SELECT * FROM tvko CLIENT SPECIFIED INTO CORRESPONDING FIELDS OF
             TABLE it_tvko  WHERE mandt = sy-mandt AND
             bukrs =  zic_prep_rolereq-ccode.

  IF zic_prep_rolereq-ccode = 'MUM'.
    LOOP AT it_tvko.
      IF zic_prep_rolereq-fundc1 = 'MUMPHPOP' OR zic_prep_rolereq-fundc1 = 'MUMPHPSP'.   "18092015 OR ADDED
        IF it_tvko-vkorg = 'HZRS'.
        ELSE.
          DELETE it_tvko.
        ENDIF.
      ELSE.
        IF it_tvko-vkorg = 'HZRS'.
          DELETE it_tvko.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF l_role_type = 'SXX'.
    it_tvko-vkorg = 'ALL'.
    it_tvko-bukrs = 'ALL'.
    APPEND it_tvko.
  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'TVKO'.
  g_field_wa-fieldname = 'VKORG'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'TVKO'.
  g_field_wa-fieldname = 'BUKRS'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKORG'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SALE_ORG'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_tvko
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_tvko,ist_return_tab,g_field_tab.
  FREE : it_tvko,ist_return_tab,g_field_tab.


ENDMODULE.                 " POV_SALE_ORG_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_DIV_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_div_sd INPUT.

*  data : l_vkorg like tvkos-vkorg.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-DIV' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'SALE_ORG'
      index = loop_step
      repid = sy-cprog
      dynnr = '0114'
    IMPORTING
      value = l_vkorg.


  SELECT * FROM tvkos CLIENT SPECIFIED INTO CORRESPONDING FIELDS OF
             TABLE it_tvkos  WHERE mandt = sy-mandt AND
             vkorg =  l_vkorg.

*  delete adjacent  duplicates from it_tvkos comparing werks.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'TVKOS'.
  g_field_wa-fieldname = 'VKORG'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'TVKOS'.
  g_field_wa-fieldname = 'SPART'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SPART'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-DIV'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_tvkos
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_tvkos,ist_return_tab,g_field_tab.
  FREE : it_tvkos,ist_return_tab,g_field_tab.

ENDMODULE.                 " POV_DIV_SD  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHIP_POINT_SD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ship_point_sd INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SHIP_POINT' AND screen-input =
0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0114'
    IMPORTING
      value = l_plant.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'DIV'
      index = loop_step
      repid = sy-cprog
      dynnr = '0114'
    IMPORTING
      value = l_div.

*  select * from tvswz into corresponding fields of
*             table it_tvswz  where werks = l_plant.

  SELECT SINGLE * FROM zsd_prep_ldggrp INTO CORRESPONDING FIELDS OF
            zsd_prep_ldggrp  WHERE div = l_div.

  SELECT * FROM tvstz INTO CORRESPONDING FIELDS OF TABLE it_tvstz
           WHERE ladgr = zsd_prep_ldggrp-ladgr AND
           werks = l_plant.

************************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'TVSTZ'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'TVSTZ'.
  g_field_wa-fieldname = 'VSTEL'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VSTEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SLOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_tvstz
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_tvstz,ist_return_tab,g_field_tab..
  FREE  : it_tvstz,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " SHIP_POINT_SD  INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: modify table
MODULE tablctrl115_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl115_wa.
  SELECT SINGLE * FROM zqm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  g_tablctrl115_wa-role_desc = zqm_prep_roledes-brief_desc.
  MODIFY g_tablctrl115_itab
    FROM g_tablctrl115_wa
    INDEX tablctrl115-current_line.
  IF sy-subrc <> 0.
    APPEND g_tablctrl115_wa TO g_tablctrl115_itab.
  ENDIF.

  IF g_tablctrl115_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl115_wa-flag.
    APPEND g_tablctrl115_wa TO g_tablctrl115_itab.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_modify INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: mark table
MODULE tablctrl115_mark INPUT.
  IF tablctrl115-line_sel_mode = 1 AND
     g_tablctrl115_wa-flag = 'X'.
    LOOP AT g_tablctrl115_itab INTO g_tablctrl115_wa
      WHERE flag = 'X'.
      g_tablctrl115_wa-flag = ''.
      MODIFY g_tablctrl115_itab
        FROM g_tablctrl115_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl115_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl115_itab
    FROM g_tablctrl115_wa
    INDEX tablctrl115-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL115_mark INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: process user command
MODULE tablctrl115_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL115'
                              'G_TABLCTRL115_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL115_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_qm INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


  SELECT * FROM zqm_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role.

  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZQM_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_plant_qm INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT * FROM zqm_prep_loc INTO CORRESPONDING FIELDS OF
             TABLE it_plant.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PLANT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-PLANT'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_plant
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_plant,ist_return_tab.
  FREE : it_plant,ist_return_tab.

ENDMODULE.                 " POV_PLANT_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_115 INPUT.

  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl115-top_line + g_cursor_line - 1.
  g_curr_line_115 = g_curr_line.

ENDMODULE.                 " get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data15 INPUT.
  SELECT SINGLE * FROM zqm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.
ENDMODULE.                 " validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno15 INPUT.
  CLEAR g_srno.
  LOOP AT g_tablctrl115_itab INTO g_tablctrl115_wa.
    g_srno = g_srno + 1.
    g_tablctrl115_wa-srno = g_srno.
    MODIFY g_tablctrl115_itab FROM g_tablctrl115_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl115_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl115_itab  LINES tablctrl115-lines.
  CLEAR g_srno.
ENDMODULE.                 " change_srno15  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ASSET_QM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_asset_qm INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ASSET_QM' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT * FROM zqm_prep_asset INTO CORRESPONDING FIELDS OF TABLE
            it_asset WHERE ccode = zic_prep_rolereq-ccode.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ASSET'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ASSET_QM'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_asset
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_asset,ist_return_tab.
  FREE  : it_asset,ist_return_tab.
  CLEAR : it_asset.

ENDMODULE.                 " POV_ASSET_QM  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_module_fi  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_module_fi INPUT.
  IF ( old_ok_code = 'CHANGE' OR
  old_ok_code = 'DISPLAY' ) AND moduleid = 'FI'.
    SELECT SINGLE * FROM zic_prep_rolerei INTO
                    CORRESPONDING FIELDS OF wa_module1 WHERE
                    docno = zic_prep_rolereq-docno AND
                    moduleid = 'FI'.
    IF sy-subrc <> 0.
      IF old_ok_code = 'CHANGE'.
        MESSAGE e196(zhelp) WITH zic_prep_rolereq-docno.
      ELSE.
        MESSAGE e198(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_module_fi  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data15a INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.


**---------- Changes Start date 24.06.2016 11:50:45-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .
*

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                a~persk a~sbmod  c~designo c~r_p_cd c~version
              d~sdesig_text AS designation d~adesig_text AS adesignation
              d~disc_cd AS disc_cd
                INTO CORRESPONDING FIELDS OF TABLE ist_data
           FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                 ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                    ON c~designo = d~desig_code AND
                        c~r_p_cd  = d~r_p_cd AND
                        c~version = d~version )
                     WHERE a~pernr =  zic_prep_rolereq-userid AND
                           a~sprps = ' ' AND
                           a~endda = '99991231' AND
                           c~sprps = ' ' AND
                           c~endda = '99991231' .
**---------- Changee  Ending Date 24.06.2016 11:50:45-----------------


    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X'.

    SELECT SINGLE * FROM zqm_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE i118(zhelp).
    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
    CLEAR  zic_prep_rolerei-asset_qm.
    CLEAR  zic_prep_rolerei-plant.
    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
    CLEAR  zic_prep_rolerei-asset_qm.
    CLEAR  zic_prep_rolerei-plant.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-PLANT'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.


    IF NOT zic_prep_rolerei-plant IS INITIAL.

      SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                 TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                    AND werks = zic_prep_rolerei-plant.
      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
        g_i = g_curr_line.
        MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-asset_qm IS INITIAL.

      IF zic_prep_rolereq-ccode = 'MUM' OR zic_prep_rolereq-ccode = 'KKL'.

        SELECT SINGLE * FROM zqm_prep_asset INTO zqm_prep_asset WHERE
                        ccode =  zic_prep_rolereq-ccode AND
                        asset =  zic_prep_rolerei-asset_qm.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-ASSET_QM'.
          g_i = g_curr_line.
          MESSAGE e172(zhelp) WITH zic_prep_rolerei-asset_qm.
        ENDIF.

      ENDIF.

    ENDIF.

    IF NOT zic_prep_rolerei-role_name IS INITIAL.

      SELECT * FROM zqm_prep_roledes INTO CORRESPONDING FIELDS OF
                  TABLE it_role.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        g_i = g_curr_line.
        MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.

      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fundc_data INPUT.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZIC_PREP_ROLEREQ-FUNDC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc <> 0.
    MESSAGE i166(zhelp).
    g_field =  'ZIC_PREP_ROLEREQ-FUNDC'.
  ENDIF.

ENDMODULE.                 " validate_fundc_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CRC_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_crc_pos INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'CRC_POS' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

*  data : loop_step like sy-stepl.
*  Data : l_role_type like ZIC_PREP_ROLEREI-ROLE_NAME.
  DATA : ist_return_tab1 LIKE STANDARD TABLE OF dselc WITH HEADER LINE.
  DATA : ist_return_tab2 LIKE STANDARD TABLE OF dynpread WITH HEADER
         LINE.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_type.

  SELECT * FROM zmm_prep_crcdesg INTO CORRESPONDING FIELDS OF
             TABLE it_pos WHERE role_type = l_role_type AND status = 'active'.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
  g_field_wa-fieldname = 'CRC_POS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
  g_field_wa-fieldname = 'CRC_ORDER_AUTH'.
  APPEND g_field_wa TO g_field_tab.
*Begin of <RD1K962817>.
*  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
*  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
*  APPEND G_FIELD_WA TO G_FIELD_TAB.
*  g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
*  g_field_wa-fieldname = 'ROLE_TYPE_EX'.
*  APPEND g_field_wa TO g_field_tab.

  g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
  g_field_wa-fieldname = 'MIN_DESIGNATION'.
  APPEND g_field_wa TO g_field_tab.

  g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.

  g_field_wa-tabname = 'ZMM_PREP_CRCDESG'.
  g_field_wa-fieldname = 'ROLE_TYPE_EX'.
  APPEND g_field_wa TO g_field_tab.

*Begin of <RD1K962817>.
  ist_return_tab1-fldname = 'ROLE_TYPE_EX'.
  ist_return_tab1-dyfldname = 'ZIC_PREP_ROLEREI-ROLE_TYPE_EX'.
  APPEND ist_return_tab1 TO ist_return_tab1.
*End of <RD1K962817>.
  ist_return_tab1-fldname = 'ROLE_TYPE'.
  ist_return_tab1-dyfldname = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  APPEND ist_return_tab1 TO ist_return_tab1.
*Begin of <RD1K962817>.
  ist_return_tab1-fldname = 'MIN_DESIGNATION'.
  ist_return_tab1-dyfldname = 'ZMM_PREP_CRCDESG-MIN_DESIGNATION'.
  APPEND ist_return_tab1 TO ist_return_tab1.
*End of <RD1K962817>.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CRC_POS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'CRC_POS'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_pos
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_return_tab1
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*Begin of <RD1K963151>.
  IF ist_return_tab[] IS NOT INITIAL.
*End of <RD1K963151>.
    READ TABLE ist_return_tab WITH KEY fieldname = 'CRC_POS'.
    ist_return_tab2-fieldname = ist_return_tab-fieldname.
    ist_return_tab2-fieldvalue = ist_return_tab-fieldval.
    ist_return_tab2-stepl = loop_step.
    APPEND ist_return_tab2 TO ist_return_tab2.
    READ TABLE ist_return_tab WITH KEY fieldname = 'ROLE_TYPE_EX'.
    CONCATENATE 'ZIC_PREP_ROLEREI-' ist_return_tab-fieldname INTO
    ist_return_tab-fieldname.
    ist_return_tab2-fieldname = ist_return_tab-fieldname.
    ist_return_tab2-fieldvalue = ist_return_tab-fieldval.
    ist_return_tab2-stepl = loop_step.
    APPEND ist_return_tab2 TO ist_return_tab2.

*Begin of <RD1K962817>.
    READ TABLE ist_return_tab WITH KEY fieldname = 'MIN_DESIGNATION'.
    ist_return_tab2-fieldname = ist_return_tab-fieldname.
    ist_return_tab2-fieldvalue = ist_return_tab-fieldval.
    ist_return_tab2-stepl = loop_step.
    APPEND ist_return_tab2 TO ist_return_tab2.

    READ TABLE ist_return_tab2 WITH KEY fieldname = 'MIN_DESIGNATION'.
*    DATA : lv_old      TYPE char2,
*           lv_new      TYPE char2,
*           l_answer(1) TYPE c.

    lv_new = ist_return_tab2-fieldvalue.
    lv_old = zic_prep_rolereq-persk.

*Begin of <RD1K962817>.
    IF lv_new = ' '.

    ELSEIF  zic_prep_rolereq-persk < 'E4'.
      MESSAGE i048(zmmaa). "with text-003.
      LEAVE PROGRAM.
    ENDIF.
*  if zic_prep_rolereq-persk < lv_new.
*  MESSAGE i803(zmm) with text-003.
*  LEAVE PROGRAM.
*  endif.
*End of <RD1K962817>.
* Begin of <RD1K963735> on 05/05/2009.
    DATA lv_text TYPE string.
    CONCATENATE 'You will be given Authorisation for Administrative Approval'
                             '& Expenditure Sanction One CRC Level Below as per the BDP 2009' INTO lv_text SEPARATED BY space.
    IF lv_new > lv_old.

       MESSAGE 'You do not meet the minimum designation criteria. Pls. contact SAP team with a copy of order for further action.' TYPE 'I'.

*      CALL FUNCTION 'POPUP_TO_CONFIRM'
*        EXPORTING
*          text_question         = lv_text
*          text_button_1         = 'Agree'
*          text_button_2         = 'Cancel'
*          default_button        = ' '
*          start_column          = 25
*          start_row             = 6
*          display_cancel_button = ' '
*        IMPORTING
*          answer                = l_answer
*        EXCEPTIONS
*          text_not_found        = 1
*          OTHERS                = 2.
*      CASE l_answer.
*        WHEN 1.
**End of <RD1K962817>.
** Begin of <RD1K963735> on 05/05/2009.
*          CALL FUNCTION 'DYNP_VALUES_UPDATE'
*            EXPORTING
*              dyname               = sy-cprog
*              dynumb               = sy-dynnr
*            TABLES
*              dynpfields           = ist_return_tab2
*            EXCEPTIONS
*              invalid_abapworkarea = 1
*              invalid_dynprofield  = 2
*              invalid_dynproname   = 3
*              invalid_dynpronummer = 4
*              invalid_request      = 5
*              no_fielddescription  = 6
*              undefind_error       = 7
*              OTHERS               = 8.
*          IF sy-subrc <> 0.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDIF.
*        WHEN 2.
**Begin of <RD1K963151>.
*          CLEAR : ist_return_tab2[],
*                  ist_return_tab1[],
*                  ist_return_tab[].
*          FREE : ist_return_tab2[],
*                  ist_return_tab1[],
*                  ist_return_tab[].
*
*          CALL FUNCTION 'DYNP_VALUES_UPDATE'
*            EXPORTING
*              dyname               = sy-cprog
*              dynumb               = sy-dynnr
*            TABLES
*              dynpfields           = ist_return_tab2
*            EXCEPTIONS
*              invalid_abapworkarea = 1
*              invalid_dynprofield  = 2
*              invalid_dynproname   = 3
*              invalid_dynpronummer = 4
*              invalid_request      = 5
*              no_fielddescription  = 6
*              undefind_error       = 7
*              OTHERS               = 8.
*          IF sy-subrc <> 0.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDIF.
**End of <RD1K963151>.
*      ENDCASE.
    ENDIF.
    CLEAR dis_flag.
  ENDIF.

  ist_return_tab3[] = ist_return_tab2[].
  REFRESH:it_pos,g_field_tab,ist_return_tab,ist_return_tab1,ist_return_tab2.
  FREE  : it_pos,g_field_tab,ist_return_tab,ist_return_tab1,ist_return_tab2.

ENDMODULE.                 " POV_CRC_POS  INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: modify table
MODULE tablctrl116_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl116_wa.

  SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  g_tablctrl116_wa-role_desc = zhs_prep_roledes-brief_desc.

  MODIFY g_tablctrl116_itab
    FROM g_tablctrl116_wa
    INDEX tablctrl116-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl116_wa TO g_tablctrl116_itab.
  ENDIF.

  IF g_tablctrl116_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl116_wa-flag.
    APPEND g_tablctrl116_wa TO g_tablctrl116_itab.
  ENDIF.

ENDMODULE.                    "TABLCTRL116_modify INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: mark table
MODULE tablctrl116_mark INPUT.
  IF tablctrl116-line_sel_mode = 1 AND
     g_tablctrl116_wa-flag = 'X'.
    LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa
      WHERE flag = 'X'.
      g_tablctrl116_wa-flag = ''.
      MODIFY g_tablctrl116_itab
        FROM g_tablctrl116_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl116_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl116_itab
    FROM g_tablctrl116_wa
    INDEX tablctrl116-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TABLCTRL116_mark INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: process user command
MODULE tablctrl116_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL116'
                              'G_TABLCTRL116_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TABLCTRL116_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_116  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_116 INPUT.

  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl116-top_line + g_cursor_line - 1.
  g_curr_line_116 = g_curr_line.

ENDMODULE.                 " get_cursor_line_116  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data16  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data16 INPUT.

  SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data16  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data16a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data16a INPUT.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

**---------- Changes Start date 24.06.2016 11:50:05-------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*               D~DISC_CD AS DISC_CD
*                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                     ON C~DESIGNO = D~DESIG_CODE AND
*                         C~R_P_CD  = D~R_P_CD AND
*                         C~VERSION = D~VERSION )
*                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
*                            A~SPRPS = ' ' AND
*                            A~ENDDA = '99991231' AND
*                            C~SPRPS = ' ' AND
*                            C~ENDDA = '99991231' .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

**---------- Changee  Ending Date 24.06.2016 11:50:05-----------------

    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  IF g_read_fl <> 'X'.

    SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE e118(zhelp).
    ENDIF.

  ELSEIF g_e_fl = 'X'.
    CLEAR g_e_fl.
  ELSE.
    CLEAR g_read_fl.

  ENDIF.

  IF g_role_name_flag = 'X'.
    CLEAR g_role_name_flag.
  ENDIF.


  g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

  g_i = g_curr_line.

  l_role_name = zic_prep_rolerei-role_name.

**********************************************************

  IF old_ok_code <> 'DISPLAY'.

    IF NOT zic_prep_rolerei-role_name IS INITIAL.

      SELECT SINGLE * FROM zhs_prep_roledes WHERE
          role_type = zic_prep_rolerei-role_name.

      IF sy-subrc <> 0.
        CLEAR :okcode_100,sy-ucomm.
        MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
        zic_prep_rolereq-ccode .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data16a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno16  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno16 INPUT.

  CLEAR g_srno.
  LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.
    g_srno = g_srno + 1.
    g_tablctrl116_wa-srno = g_srno.
    MODIFY g_tablctrl116_itab FROM g_tablctrl116_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl116_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl116_itab  LINES tablctrl116-lines.
  CLEAR g_srno.

ENDMODULE.                 " change_srno16  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_HSE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_hse INPUT.

  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT * FROM zhs_prep_roledes INTO CORRESPONDING FIELDS OF
               TABLE it_role.

  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZHS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZHS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZHS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZHS_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.

ENDMODULE.                 " POV_ROLE_HSE  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_117'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc_117_modify INPUT.
*  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TC_117_WA.
*  MODIFY G_TC_117_ITAB
*    FROM G_TC_117_WA
*    INDEX TC_117-CURRENT_LINE.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tc_117_wa.

  SELECT SINGLE * FROM zmm_prep_rolegrp WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.
  IF NOT g_tc_117_wa-role_name IS INITIAL.
    SELECT SINGLE * FROM zol_prep_roledes WHERE role_type =
                    zic_prep_rolerei-role_name.
    IF sy-subrc = 0.

      g_tc_117_wa-role_desc = zol_prep_roledes-brief_desc.
    ENDIF.
  ENDIF.
  MODIFY g_tc_117_itab
    FROM g_tc_117_wa
    INDEX tc_117-current_line.

  IF sy-subrc <> 0.
    APPEND g_tc_117_wa TO g_tc_117_itab.
  ENDIF.

  IF g_tc_117_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tc_117_wa-flag.
    APPEND g_tc_117_wa TO g_tc_117_itab.
  ENDIF.
ENDMODULE.                    "TC_117_MODIFY INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_117'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_117_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_117'
                              'G_TC_117_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC_117_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_LINE_117  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_117 INPUT.
  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tc_117-top_line + g_cursor_line - 1.
  g_curr_line_117 = g_curr_line.
ENDMODULE.                 " GET_CURSOR_LINE_117  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA17  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data17 INPUT.

  SELECT SINGLE * FROM zol_prep_roledes WHERE role_type =
                   zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.

ENDMODULE.                 " VALIDATE_LINEITEM_DATA17  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE117  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role117 INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.

*  TYPES : BEGIN OF z_role_des1,
*            role_type LIKE zmm_prep_roledes-role_type,
*            brief_desc LIKE zmm_prep_roledes-brief_desc,
*            detail_desc1 LIKE zmm_prep_roledes-detail_desc1,
*            detail_desc2 LIKE zmm_prep_roledes-detail_desc2,
*            sort_field LIKE zmm_prep_roledes-brief_desc,
*            mm_disc_flag LIKE zmm_prep_roledes-mm_disc_flag,
*          END OF z_role_des1.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
*  DATA   : it_role1 TYPE TABLE OF z_role_des1 WITH HEADER LINE.

  SELECT * FROM zol_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role.
  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZOL_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZOL_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZOL_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZOL_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC2'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.
ENDMODULE.                 " POV_ROLE117  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC117  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_sloc117 INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-SLOC' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA : l_plant LIKE zic_prep_rolerei-plant.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'PLANT'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_plant.


*  DATA   : it_t001l TYPE TABLE OF t001l WITH HEADER LINE.
*  DATA   : it_excp_sl TYPE TABLE OF zmm_prep_sl_excp WITH HEADER LINE.
*  DATA   : wa_t001l LIKE t001l.
*  DATA   : l_zarea LIKE zmm_consm-zarea.

  SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
             TABLE it_t001l  WHERE werks = l_plant.

  IF  zic_prep_rolereq-disc_mm_flag = 'X'.

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
**COMMENT START BY CAB_AMITMOZA
*  SELECT * FROM zmm_prep_sl_excp INTO TABLE it_excp_sl.
*
*************************************
*
*  LOOP AT it_excp_sl.
*
*    READ TABLE it_t001l WITH KEY werks = it_excp_sl-werks
*    lgort = it_excp_sl-lgort.
*
*    IF sy-subrc = 0.
*
*      DELETE it_t001l WHERE werks = it_excp_sl-werks
*      AND lgort = it_excp_sl-lgort.
*
*    ENDIF.
*
*  ENDLOOP.
**COMMENT END BY CAB_AMITMOZA
************************************
  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'WERKS'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGORT'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T001L'.
  g_field_wa-fieldname = 'LGOBE'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-SLOC'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t001l
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t001l,ist_return_tab,g_field_tab..
  FREE  : it_t001l,ist_return_tab,g_field_tab.
  CLEAR : g_field_wa.
ENDMODULE.                 " POV_SLOC117  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER117  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_approver117 INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER' AND screen-input = 0.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA : it_approver LIKE TABLE OF zmm_prep_approve.
*  DATA : wa_approver LIKE zmm_prep_approve.

*  DATA : it_approver1 LIKE TABLE OF zmm_prep_app_crc.
*  DATA : wa_approver1 LIKE zmm_prep_app_crc.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0110'
    IMPORTING
      value = l_role_name.

*  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'.
*
*    SELECT * FROM zmm_prep_app_crc INTO TABLE it_approver1.
*
*  ELSE.

  SELECT * FROM zmm_prep_approve INTO TABLE it_approver.

*  ENDIF.


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
*  IF l_role_name = 'M11S'.                                  "22.05.06
*
*    LOOP AT it_approver INTO wa_approver.
*
*      CASE  zic_prep_rolereq-disc_mm_flag.
*
*        WHEN 'X'.
*          IF wa_approver-mm_flag <> 'X'.
*            DELETE it_approver.
*          ENDIF.
*        WHEN OTHERS.
*          IF wa_approver-m11s_flag <> 'X'.
*            DELETE it_approver.
*          ENDIF.
*      ENDCASE.
*
*    ENDLOOP.
*
*  ENDIF.
*
*  IF l_role_name = 'M11M'.
*
*    LOOP AT it_approver INTO wa_approver.
*
*      CASE  zic_prep_rolereq-disc_mm_flag.
*
*        WHEN 'X'.
*          IF wa_approver-mm_flag <> 'X'
*             OR wa_approver-m11m_flag <> 'X'.
*            DELETE it_approver.
*          ENDIF.
*        WHEN OTHERS.
*          IF wa_approver-mm_flag = 'X'
*             OR wa_approver-m11m_flag <> 'X'.
*            DELETE it_approver.
*          ENDIF.
*      ENDCASE.
*
*    ENDLOOP.
*
*  ENDIF.
***************************************************22.05.06
*
*  IF l_role_name = 'M8'.
*
*    LOOP AT it_approver INTO wa_approver.
*
*      IF wa_approver-m8_flag <> 'X'.
*        DELETE it_approver.
*      ENDIF.
*
*    ENDLOOP.
*
*  ENDIF.

*  IF old_ok_code = 'CRCROLES' OR  zic_prep_rolereq-crc_fl = 'X'..
*
*    IF l_role_name = 'M3'.
*
*      LOOP AT it_approver1 INTO wa_approver1.
*
*        IF wa_approver1-m3_flag <> 'X'.
*          DELETE it_approver1.
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.
*
*    IF l_role_name = 'M3A'.                                 "22.05.06
*
*      LOOP AT it_approver1 INTO wa_approver1.
*
*        IF wa_approver1-m3a_flag <> 'X'.
*          DELETE it_approver1.
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.
*
*    IF l_role_name = 'M3B'.
*
*      LOOP AT it_approver1 INTO wa_approver1.
*
*        IF wa_approver1-m3b_flag <> 'X'.
*          DELETE it_approver1.
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.                                                  " 22.05.06
*
*
*    IF l_role_name = 'M11S'.
*
*      LOOP AT it_approver1 INTO wa_approver1.
*
**                    if wa_approver1-M11S_FLAG <> 'X'.
**                        delete it_approver1.
**                    endif.
*        CASE  zic_prep_rolereq-disc_mm_flag.
*
*          WHEN 'X'.
*            IF wa_approver1-mm_flag <> 'X'
*               OR wa_approver1-m11s_flag <> 'X'.
*              DELETE it_approver1.
*            ENDIF.
*          WHEN OTHERS.
*            IF wa_approver1-mm_flag = 'X'
*               OR wa_approver1-m11s_flag <> 'X'.
*              DELETE it_approver1.
*            ENDIF.
*        ENDCASE.
*
*      ENDLOOP.
*
*    ENDIF.
*
*    IF l_role_name = 'M11M'.
*
*      LOOP AT it_approver1 INTO wa_approver1.
*
**                    if wa_approver1-M11M_FLAG <> 'X'.
**                        delete it_approver1.
**                     endif.
*
*        CASE  zic_prep_rolereq-disc_mm_flag.
*
*          WHEN 'X'.
*            IF wa_approver1-mm_flag <> 'X'
*               OR wa_approver1-m11m_flag <> 'X'.
*              DELETE it_approver1.
*            ENDIF.
*          WHEN OTHERS.
*            IF wa_approver1-mm_flag = 'X'
*               OR wa_approver1-m11m_flag <> 'X'.
*              DELETE it_approver1.
*            ENDIF.
*        ENDCASE.
*
*      ENDLOOP.
*
*    ENDIF.
*
*    it_approver[] = it_approver1[].
*
*  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
  g_field_wa-fieldname = 'APP_LEVEL'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
  g_field_wa-fieldname = 'L_DESC'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'APP_LEVEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-APPROVER'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_approver
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_approver,ist_return_tab, it_approver1,g_field_tab.
  FREE  : it_approver,ist_return_tab, it_approver1,g_field_tab.
  CLEAR : g_field_wa.
ENDMODULE.                 " POV_APPROVER117  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SRNO_117  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno_117 INPUT.
  CLEAR g_srno.
  LOOP AT g_tc_117_itab INTO g_tc_117_wa.
    g_srno = g_srno + 1.
    g_tc_117_wa-srno = g_srno.
    MODIFY g_tc_117_itab FROM g_tc_117_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tc_117_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tc_117_itab  LINES tc_117-lines.
  CLEAR g_srno.
ENDMODULE.                 " CHANGE_SRNO_117  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_117_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_117_mark INPUT.
  IF tc_117-line_sel_mode = 1 AND
       g_tc_117_wa-flag = 'X'.
    LOOP AT g_tc_117_itab INTO g_tc_117_wa
      WHERE flag = 'X'.
      g_tc_117_wa-flag = ''.
      MODIFY g_tc_117_itab
        FROM g_tc_117_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_117_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tc_117_itab
    FROM g_tc_117_wa
    INDEX tc_117-current_line
    TRANSPORTING flag.
ENDMODULE.                 " TC_117_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA117  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data117 INPUT.
  IF g_read_fl <> 'X'.
    SELECT SINGLE * FROM zol_prep_roledes WHERE role_type =
                          zic_prep_rolerei-role_name.
    IF sy-subrc <> 0.
      g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE i118(zhelp).
    ENDIF.
  ENDIF.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.

    SELECT * FROM zol_prep_roledes INTO CORRESPONDING FIELDS OF
                TABLE it_role.
    LOOP AT it_role .
      IF it_role-role_type = zic_prep_rolerei-role_name.
        check_role_flag = 'X'.
      ENDIF.
    ENDLOOP.
    IF check_role_flag = 'X'.
      CLEAR check_role_flag.
    ELSE.
      MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
      zic_prep_rolereq-ccode .
    ENDIF.

  ENDIF.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA117  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_SRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_role_srm INPUT.
  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND screen-input = 0
.
      dis_flag = 'X'.
    ENDIF.

  ENDLOOP.



  SELECT * FROM zsr_prep_roledes INTO CORRESPONDING FIELDS OF
             TABLE it_role.

  SORT it_role ASCENDING BY sort_field.

  IF old_ok_code <> 'DISPLAY'.

    CLEAR zic_prep_rolerei-role_name.

  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'ZSR_PREP_ROLEDES'.
  g_field_wa-fieldname = 'ROLE_TYPE'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZSR_PREP_ROLEDES'.
  g_field_wa-fieldname = 'BRIEF_DESC'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'ZSR_PREP_ROLEDES'.
  g_field_wa-fieldname = 'DETAIL_DESC1'.
  APPEND g_field_wa TO g_field_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ROLE_TYPE'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_role
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_role,ist_return_tab, g_field_tab.
  FREE  : it_role,ist_return_tab, g_field_tab.
  CLEAR : g_field_wa.
ENDMODULE.                 " POV_ROLE_SRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_LINE_118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_line_118 INPUT.
  GET CURSOR LINE g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = tablctrl118-top_line + g_cursor_line - 1.
  g_curr_line_118 = g_curr_line.

ENDMODULE.                 " GET_CURSOR_LINE_118  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data118 INPUT.

  SELECT SINGLE * FROM zsr_prep_roledes WHERE role_type =
                 zic_prep_rolerei-role_name.

  IF g_role_name_prev <> zic_prep_rolerei-role_name AND
              NOT g_role_name_prev IS INITIAL.
    g_role_name_flag = 'X'.
  ENDIF.
  g_read_fl = 'X'.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA118  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_modify INPUT.
  MOVE moduleid TO zic_prep_rolerei-moduleid.
  IF zic_prep_rolerei-rej_fl IS INITIAL.
    CLEAR : zic_prep_rolerei-rej_id, zic_prep_rolerei-rej_date.
  ENDIF.
  MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl118_wa.

  SELECT SINGLE * FROM zmm_prep_rolegrp WHERE role_type =
                    zic_prep_rolerei-role_name.

  IF sy-subrc <> 0 .
    g_val_err = 'X'.
    MESSAGE i102(zhelp) WITH zic_prep_rolerei-role_name .
    g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  IF zic_prep_rolerei-rej_fl = ''.

    IF sy-subrc = 0 AND old_ok_code = 'APPROVE'.
      IF zmm_prep_rolegrp-approver1 = g_user
         OR zmm_prep_rolegrp-approver2 = g_user
         OR zmm_prep_rolegrp-approver3 = g_user
   """"""""""""""""""""""""
      "added by lipsy for l2 approver on 20.03.2015 RD1K996555
            OR ( moduleid = 'SRM' AND zmm_prep_rolegrp-approver1 = g_user_l2 )
       "End of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
    """"""""""""""""""""
        .
      ELSE.

        IF okcode_100 = 'SAV'.
          IF err_flg <> 'X'.
            err_flg = 'X'.
            CLEAR : sy-ucomm, okcode_100.
          ENDIF.
          MESSAGE e047(zhelp) WITH zmm_prep_rolegrp-role_type.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT g_tablctrl118_wa-role_name IS INITIAL.

    SELECT SINGLE * FROM zsr_prep_roledes WHERE role_type =
                  zic_prep_rolerei-role_name.
    IF sy-subrc = 0.
      g_tablctrl118_wa-role_desc = zsr_prep_roledes-brief_desc.
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

  MODIFY g_tablctrl118_itab
     FROM g_tablctrl118_wa
     INDEX tablctrl118-current_line.

  IF sy-subrc <> 0.
    APPEND g_tablctrl118_wa TO g_tablctrl118_itab.
  ENDIF.

  IF g_tablctrl118_wa-flag = 'X' AND okcode_100 = 'COPY'.
    CLEAR g_tablctrl118_wa-flag.
    APPEND g_tablctrl118_wa TO g_tablctrl118_itab.
  ENDIF.
ENDMODULE.                 " TABLCTRL118_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_mark INPUT.
  IF tablctrl118-line_sel_mode = 1 AND
       g_tablctrl118_wa-flag = 'X'.
    LOOP AT g_tablctrl118_itab INTO g_tablctrl118_wa
      WHERE flag = 'X'.
      g_tablctrl118_wa-flag = ''.
      MODIFY g_tablctrl118_itab
        FROM g_tablctrl118_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tablctrl118_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tablctrl118_itab
    FROM g_tablctrl118_wa
    INDEX tablctrl118-current_line.
ENDMODULE.                 " TABLCTRL118_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SRNO_118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno_118 INPUT.
  CLEAR g_srno.
  LOOP AT g_tablctrl118_itab INTO g_tablctrl118_wa.
    g_srno = g_srno + 1.
    g_tablctrl118_wa-srno = g_srno.
    MODIFY g_tablctrl118_itab FROM g_tablctrl118_wa.
  ENDLOOP.
  DESCRIBE TABLE g_tablctrl118_itab  LINES g_lines_rl.
  DESCRIBE TABLE g_tablctrl118_itab  LINES tablctrl118-lines.
  CLEAR g_srno.

ENDMODULE.                 " CHANGE_SRNO_118  INPUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLCTRL118'
                              'G_TABLCTRL118_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                 " TABLCTRL118_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP_SRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_grp_srm INPUT.


  g_ccode =  zic_prep_rolereq-ccode.


  LOOP AT SCREEN.

    IF screen-name = 'ZIC_PREP_ROLEREI-GRP' AND screen-input = 0
.
      dis_flag = 'X'.
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
      povstepl        = loop_step
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      struc = 'ZIC_PREP_ROLEREI'
      field = 'ROLE_NAME'
      index = loop_step
      repid = sy-cprog
      dynnr = '0118'
    IMPORTING
      value = l_role_name.

  IF l_role_name = 'S1' OR  l_role_name = 'S2' .
    CONCATENATE '%' g_ccode '%' INTO g_line1.
    SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.

  ELSE.
    IF zic_prep_rolereq-disc_mm_flag <> 'X'.
*      concatenate '%' G_CCODE '-' 'IND' '%'
*      into g_line1.
      CONCATENATE '%' g_ccode '%' 'IND' '%'
      INTO g_line1.
      SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
    ELSE.
*      concatenate  '%' G_CCODE '-' 'MM' '%'
*      into g_line1.
      CONCATENATE  '%' g_ccode '%' 'MM' '%'
      INTO g_line1.
      SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
    ENDIF.
  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  ENDIF.

  g_field_wa-tabname = 'T024'.
  g_field_wa-fieldname = 'EKGRP'.
  APPEND g_field_wa TO g_field_tab.
  g_field_wa-tabname = 'T024'.
  g_field_wa-fieldname = 'EKNAM'.
  APPEND g_field_wa TO g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZIC_PREP_ROLEREI-GRP'
      value_org       = 'S'
      display         = dis_flag
    TABLES
      value_tab       = it_t024
      field_tab       = g_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR dis_flag.

  ENDIF.

  REFRESH:it_t024,ist_return_tab, g_field_tab.
  FREE : it_t024,ist_return_tab, g_field_tab.
  CLEAR g_field_wa.
ENDMODULE.                 " POV_GRP_SRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA1181  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data1181 INPUT.

*BREAK-POINT.
  CLEAR:g_line_srm.
  CONCATENATE  '%' zic_prep_rolereq-ccode '%' '%'
  INTO g_line_srm.

  SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line_srm.


**

  IF  NOT zic_prep_rolerei-grp IS INITIAL.

    LOOP AT it_t024 INTO wa_t024.

      IF zic_prep_rolerei-grp = wa_t024-ekgrp.
        grp_flag_srm = 'X'.
      ENDIF.

    ENDLOOP.

    IF grp_flag_srm = 'X'.
      CLEAR grp_flag_srm.
    ELSE.
*        G_E_FL = 'X'.
*        G_READ_FL = 'X'.
*        G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
      MOVE-CORRESPONDING zic_prep_rolerei TO g_tablctrl118_wa.
      MODIFY g_tablctrl118_itab
                FROM g_tablctrl118_wa
                  INDEX tablctrl118-current_line.
*        G_I = TABLCTRL110-CURRENT_LINE.
      MESSAGE i069(zhelp).
      CALL SCREEN 100.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA1181  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_approver INPUT.
  IF moduleid = 'MM'.
    IF zic_prep_rolerei-approver+0(1) = 'E'.
      v_app =  zic_prep_rolerei-approver+1(1) .

      IF v_app > zic_prep_rolereq-persk+1(1).

        MESSAGE e163(zmm_oth).
      ENDIF.

    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDATE_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SRMGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_srmgrp INPUT.
  CLEAR:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.





    p_uname = zic_prep_rolereq-userid.
    p_grp = zic_prep_rolerei-grp.
    p_role = zic_prep_rolerei-role_name.

    TRANSLATE p_grp TO UPPER CASE.
    TRANSLATE p_role TO UPPER CASE.

    IF p_grp  IS NOT INITIAL.
      CALL FUNCTION 'ZSRM_ROLE_ASSIGN_CHECK' DESTINATION l_logsys
        EXPORTING
          p_uname = p_uname
          p_grp   = p_grp
          p_role  = p_role
        IMPORTING
          v_exist = v_exist.

      IF v_exist = 'Y'.

        MESSAGE e164(zmm_oth) WITH zic_prep_rolerei-grp.

      ENDIF.

      IF v_exist = 'N'.

        MESSAGE e169(zmm_oth) WITH zic_prep_rolerei-grp.

      ENDIF.


    ENDIF.

  ENDIF.



  CLEAR:count_grp,g_wa_pgrp.

  LOOP AT g_tablctrl118_itab INTO g_wa_pgrp WHERE  grp = zic_prep_rolerei-grp  .
    IF g_wa_pgrp-grp  IS NOT INITIAL.
      count_grp = count_grp + 1.
    ENDIF.
  ENDLOOP.
  IF  count_grp > '1'.
    MESSAGE e092(zhelp).
  ENDIF.

ENDMODULE.                 " VALIDATE_SRMGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SRMROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_srmrole INPUT.
  CLEAR:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.





    p_uname = zic_prep_rolereq-userid.
    p_role = zic_prep_rolerei-role_name.
    p_grp = zic_prep_rolerei-grp.

    TRANSLATE p_grp TO UPPER CASE.
    TRANSLATE p_role TO UPPER CASE.

    IF  p_role = 'S3'.
      CALL FUNCTION 'ZSRM_ROLE_ASSIGN_CHECK' DESTINATION l_logsys
        EXPORTING
          p_uname = p_uname
          p_grp   = p_grp
          p_role  = p_role
        IMPORTING
          v_exist = v_exist.

      IF v_exist = 'P'.

        MESSAGE e165(zmm_oth) WITH zic_prep_rolerei-role_name.

      ENDIF.


    ENDIF.

  ENDIF.
  IF zic_prep_rolereq-disc_mm_flag = 'X'.
    IF  p_role = 'S2'.
      MESSAGE e167(zmm_oth) WITH zic_prep_rolerei-role_name.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_SRMROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_PGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_pgrp INPUT.


*  SELECT SINGLE * from zmm_prep_rolecrc INTO @data(ls_rolec)
*    WHERE ROLE_TYPE = @ZIC_PREP_ROLEREI-role_name.
*
*    IF ZIC_PREP_ROLEREI-plant is INITIAL.
*     MESSAGE 'Please enter plant' TYPE 'W'.
*
*    ENDIF.
*
*     IF ZIC_PREP_ROLEREI-grp is INITIAL.
*     MESSAGE 'Please enter purchasing group' TYPE 'W'.
*
*    ENDIF.
*refresh: itab_agr_users[].
*clear:v_grp_comp.
*
*if ZIC_PREP_ROLEREI-GRP is not initial.
*CONCATENATE '%' ZIC_PREP_ROLEREI-GRP  '%' into v_grp_comp.
*
*select * FROM AGR_USERS into CORRESPONDING FIELDS OF TABLE
*    itab_agr_users
*    where uname = ZIC_PREP_ROLEREQ-USERID
*  and AGR_NAME like v_grp_comp
*  and to_dat = '99991231'.
*
*  if sy-subrc = 0.
*
*    MESSAGE 'Purchase group already Assigned' TYPE 'W'.
*
*    endif.

*endif.

ENDMODULE.                 " VALIDATE_PGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PLANT_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CHECK_PLANT_GRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_plant_grp .
  if OLD_OK_CODE = 'CRCROLES' and moduleid = 'MM'.
    IF ZIC_PREP_ROLEREI-plant is INITIAL.
     MESSAGE 'Please enter plant' TYPE 'I'.
     leave TO SCREEN sy-dynnr.
    ENDIF.

     IF ZIC_PREP_ROLEREI-grp is INITIAL.
     MESSAGE 'Please enter purchasing group' TYPE 'I'.
     leave TO SCREEN sy-dynnr.
    ENDIF.
    endif.
ENDFORM.

*--- INCLUDE: MZMMPREPROLE1_PHASEIIO01 ---*
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
* 02/04/2009      < RD1K962817>    SAB_SUMODH
*
*1)Change at Line 1471.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
* CR No. 30012322  RD1K996279 CAB_SUDHIR
*
*1)Change in Line 309.
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company ,multi module
*                                           roles,during approval      *
"                                          ,SRM Module introductin)    *
*&                                                                     *
*&                                                                     *
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""
************************************************************************
MODULE status_0100 OUTPUT.


  PERFORM fill_sttab.

  SET PF-STATUS 'OPTNS' EXCLUDING it_tab.

  CASE old_ok_code.
    WHEN 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Request'.
    WHEN 'CROSSCO'.
      SET TITLEBAR 'PREP_TITLE' WITH
      ': Cross Company '.
    WHEN 'CRCROLES'.
      SET TITLEBAR 'PREP_TITLE' WITH ': CRC '.
    WHEN 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Change Request'.
    WHEN 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Display Request'.
*      SET PF-STATUS 'OPTNSX' excluding it_tab.
    WHEN 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Delete Request'.
    WHEN 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Release Request'.
    WHEN 'APPROVE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Approve Request'.

    WHEN OTHERS.
      SET TITLEBAR 'PREP_TITLE' WITH ''.
  ENDCASE.

******************************** code added by Bipin  : 20/09/2013
  DATA lv_docno TYPE zchar12.
*  BREAK-POINT.
  IF zic_prep_rolereq-docno IS INITIAL.
    GET PARAMETER ID 'ZREQNO' FIELD zic_prep_rolereq-docno.
    lv_docno = zic_prep_rolereq-docno.
    DELETE gt_icon1 WHERE docno NE zic_prep_rolereq-docno.
    IF zic_prep_rolereq-docno IS  NOT INITIAL.
      CLEAR zic_prep_rolereq-docno.
    ENDIF.
  ELSE.
    lv_docno = zic_prep_rolereq-docno.
  ENDIF.
  SELECT * FROM zgrc_sod_result INTO CORRESPONDING FIELDS OF TABLE gt_icon WHERE docno = lv_docno.
  IF sy-subrc EQ 0.
    gt_icon1[] = gt_icon[].
  ENDIF.

  DESCRIBE TABLE gt_icon1 LINES lv_count.
  IF sy-tcode EQ 'ZICE_ARMS' ." OR SY-TCODE EQ 'ZIC_AUTH_FI_REP'.
    IF lv_count EQ 1.
      gicon = '@08@'. "GREEN
      risk_desc = 'No Risk'.
    ELSEIF lv_count GT 1.
      gicon = '@0A@'. "RED
      risk_desc = 'Risk found'.
    ELSEIF lv_count EQ 0.
      gicon = '@09@'. " YELLOW
      risk_desc = 'Risk analysis in progress'.
    ENDIF.
  ENDIF.

******************************** code added by Bipin  : 20/09/2013

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.

  IF NOT zic_prep_rolereq-docno IS INITIAL.

    DATA : l_docno LIKE zic_prep_rolereq-docno.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = l_docno
      IMPORTING
        output = l_docno.

    zic_prep_rolereq-docno = l_docno.

  ENDIF.

  IF  g_hd_copied <> 'X'.
*
    IF old_ok_code IS INITIAL AND okcode_100 IS INITIAL.

    ELSE.

      IF ( old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' ) AND
                                       okcode_100 IS INITIAL.

      ELSE.

        IF ( old_ok_code = 'CHANGE' ) OR ( old_ok_code = 'DELETE' )
            OR ( old_ok_code = 'RELEASE' )
            OR ( old_ok_code = 'APPROVE' ).
          IF NOT zic_prep_rolereq-docno IS INITIAL.
            """"""""
            """""""""""
            PERFORM lock_reqhd.
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

        IF NOT zic_prep_rolereq-docno IS INITIAL.

          SELECT SINGLE * FROM zic_prep_rolereq
                     WHERE docno = zic_prep_rolereq-docno.

          IF sy-subrc = 0 .

            IF g_l4 = 'X' AND old_ok_code = 'APPROVE'.
              zic_prep_rolereq-radio_fl = 'X'.
            ENDIF.

*           select single moduleid from zic_prep_rolerei into
*           moduleid where DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

            SELECT DISTINCT moduleid FROM zic_prep_rolerei INTO
            CORRESPONDING FIELDS OF TABLE it_module1 WHERE docno =
            zic_prep_rolereq-docno.
****
            SORT IT_MODULE1 BY MODULEID. READ TABLE it_module1 INDEX 1 INTO wa_module1.
            IF moduleid IS INITIAL.
              moduleid = wa_module1-moduleid.
**** 13/04/07
              old_moduleid = moduleid.
            ENDIF.
****
            DATA : l_module_lines LIKE sy-index.

            DESCRIBE TABLE it_module1 LINES l_module_lines.

            IF l_module_lines > 1.
              g_mult_module_fl = 'X'.
            ENDIF.

            g_hd_copied = 'X'.
** check line items modulewise/initialise
            g_tablctrl110_copied = ''.
            g_tablctrl111_copied = ''.
            g_tablctrl112_copied = ''.
            g_tablctrl113_copied = ''.
            g_tablctrl114_copied = ''.
            g_tablctrl115_copied = ''.
            g_tablctrl116_copied = ''.

            """"""""""""""""""""""
            """"""""""""""""""""""""
            ""added by lipsy on 20.03.2015 RD1K996555
            g_tc_117_copied = ''.
            g_tablctrl118_copied = ''.

            "
            ""End of addition by lipsy on 20.03.2015 RD1K996555

            """""""""""""""""""

**

            IF zic_prep_rolereq-comm_fl = 'X' AND old_ok_code = 'CHANGE'
.
              PERFORM verify2.
            ENDIF.

            PERFORM validations.

          ELSE.
            MESSAGE i101(zhelp) WITH zic_prep_rolereq-docno.
          ENDIF.

        ENDIF.

      ENDIF.

      SELECT SINGLE * FROM t500p
                 WHERE persa = zic_prep_rolereq-persa.

      IF sy-subrc = 0.

        zic_prep_rolereq-name1 = t500p-name1.

      ENDIF.


    ENDIF.

  ENDIF.

  SELECT SINGLE * FROM zmm_prep_rsn
             WHERE reason = zic_prep_rolereq-rsn_code.

  IF sy-subrc = 0.

    zic_prep_rolereq-rsn_text1 = zmm_prep_rsn-description.

  ENDIF.

  SELECT SINGLE * FROM zmm_prep_status
             WHERE status_code = zic_prep_rolereq-status .

  IF sy-subrc = 0.

    status_desc = zmm_prep_status-status_desc.

  ENDIF.


  IF zic_prep_rolereq-fundc <> '' AND zic_prep_rolereq-reason1 = ''.

    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-REASON1'.
    MESSAGE i100(zhelp).
  ENDIF.

  PERFORM crc_module_checking.

  PERFORM get_correspondence.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

  CASE old_ok_code.

    WHEN ''.

      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.

*        ************************* START OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION
        IF screen-name = 'GRC_RISK'. "AND SY-TCODE EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'SEC_LEVEL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'GICON' ."AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RAL'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'RISK_DESC'." AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

************************* END OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION

      ENDLOOP.

    WHEN 'CREATE' OR 'ROLE_DEL'.

      LOOP AT SCREEN.

************************* START OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION
        IF screen-name = 'GRC_RISK'. "AND SY-TCODE EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'SEC_LEVEL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'GICON'." AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RAL'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'RISK_DESC'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

************************* END OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION

        IF screen-group1 = 'GP1'.
          IF moduleid <> 'MM' AND screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          IF zic_prep_rolereq-rsn_code = '01'.
            screen-input = 1.
*             perform pop_up_message.
          ELSE.
            CLEAR : zic_prep_rolereq-persa, zic_prep_rolereq-name1.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID' AND moduleid <> ''
            AND zic_prep_rolereq-userid <> ''.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID' AND old_ok_code = 'ROLE_DEL'.
          moduleid = 'FI'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT zic_prep_rolereq-fundc IS INITIAL.
            screen-input = 1.
            screen-required = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'CHANGE'.
      LOOP AT SCREEN.

************************* START OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION



        IF  screen-name = 'GRC_RAL'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.


************************* END OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION

        IF screen-group1 = 'GP1'.
          IF moduleid <> 'MM' AND screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          IF moduleid <> 'MM' AND screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.
*Begin of <RD1K963151>.
        IF zic_prep_rolereq-docno IS NOT INITIAL.
          IF screen-group2 = 'GP2'.
            screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
*End of <RD1K963151>.
        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-USERID' AND
            zic_prep_rolereq-userid <> ''.
          screen-input = 0.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' .
          IF zic_prep_rolereq-crc_fl = 'X'.
            screen-active = 1.
          ELSE.
            screen-active = 0.
          ENDIF.
          screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT zic_prep_rolereq-fundc IS INITIAL.
            screen-input = 1.
            screen-required = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'RELEASE'.

      LOOP AT SCREEN.

************************* START OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION
        IF screen-name = 'GRC_RISK'. "AND SY-TCODE EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'SEC_LEVEL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'GICON'." AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RAL'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'RISK_DESC'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

************************* END OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION

        IF screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REQ_CR_FL'.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl <> 'X'.
          screen-active = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT zic_prep_rolereq-fundc IS INITIAL.
            screen-input = 1.
            screen-required = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'APPROVE'.

      LOOP AT SCREEN.

        IF screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

*       if screen-name = 'TABCTRL100_DELETE' or
*           screen-name = 'TABCTRL100_INSERT' or
*           screen-name = 'COPY'.
*              screen-input = 0.
*              modify screen.
*       endif.

        IF g_user = 'L1' AND screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP1_FL'.
** CODE ADDED BY CAB_AMITMOZA  CR: 30007580   01.03.2013
          SELECT * FROM ZIC_PREP_ROLEREI UP TO 1 ROWS

 WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          IF zic_prep_rolerei-moduleid = 'OLM'.
            screen-input = 0.
          ELSE.
** CODE END BY CAB_AMITMOZA  CR: 30007580
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.
** CODE ADDED BY CAB_AMITMOZA  CR: 30007580   01.03.2013
        IF g_user = 'L1' AND screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP_FL'.
          SELECT * FROM ZIC_PREP_ROLEREI UP TO 1 ROWS

 WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          IF zic_prep_rolerei-moduleid = 'OLM'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.
** CODE END BY CAB_AMITMOZA  CR: 30007580
        IF ( g_user = 'IM' ) AND
            screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP0_FL'.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.
        IF ( g_user = 'L3' ) AND
            screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP_FL'.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl <> 'X'.
          screen-active = 0.
          screen-invisible = 1.
          MODIFY SCREEN.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC' OR
           screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'CROSSCO'.

      LOOP AT SCREEN.

        IF screen-group1 = 'GP1' OR
            screen-group4 = 'GP4'.
          screen-input = 1.
          IF screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
            screen-required = 0.
          ELSE.
            screen-required = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          IF zic_prep_rolereq-rsn_code = '01'.
            screen-input = 1.
          ELSE.
            CLEAR : zic_prep_rolereq-persa, zic_prep_rolereq-name1.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' .
          screen-active = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID' AND moduleid <> ''
            AND zic_prep_rolereq-userid <> ''.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-CCODE' AND
           NOT zic_prep_rolereq-ccode IS INITIAL .
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           screen-name = 'IN'.
          screen-active = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT zic_prep_rolereq-fundc IS INITIAL.
            screen-input = 1.
            screen-required = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'DISPLAY'.

      LOOP AT SCREEN.



        IF screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'       OR
*          screen-name = 'MODULEID'    or
           screen-name = 'DETAILS'     OR
           screen-name = 'CORR' OR screen-name = 'STAT' OR
           screen-name = 'M'    OR screen-name = 'TABCTRL100_PREVIOUS'
                                OR screen-name = 'TABCTRL100_NEXT'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.
*Begin of <RD1K963151>.
        IF zic_prep_rolereq-docno IS NOT INITIAL.
          IF screen-group2 = 'GP2'.
            screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
*End of <RD1K963151>.

      ENDLOOP.

    WHEN 'DELETE'.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREQ-DOCNO' OR screen-name = 'CORR'
                                                  OR screen-name = 'STAT'
 .
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'CRCROLES'.

      LOOP AT SCREEN.

        IF screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          IF zic_prep_rolereq-rsn_code = '01'.
            screen-input = 1.
          ELSE.
            CLEAR : zic_prep_rolereq-persa, zic_prep_rolereq-name1.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-FR_DATE_AUTH' OR
              screen-name = 'ZIC_PREP_ROLEREQ-TO_DATE_AUTH' ).
          screen-input = 1.
          screen-invisible = 0.
          screen-required = 0.
        ELSE.
          IF ( screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_NO' OR
              screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_DATE' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 1.
          ENDIF.

        ENDIF.

        IF ( screen-name = 'OONO' OR screen-name = 'DT1'  OR
             screen-name = 'DT2' OR screen-name = 'DT3' ).
          screen-invisible = 0.
          screen-active = 1.
        ENDIF.

        MODIFY SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT zic_prep_rolereq-fundc IS INITIAL.
            screen-input = 1.
            screen-required = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

*added on 05/03/2007
        IF screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

  ENDCASE.

  IF old_ok_code = 'DISPLAY'.

    LOOP AT SCREEN.

      IF screen-name = 'GRC_RISK'. "AND SY-TCODE EQ 'ZIC_AUTH_FI'.
        screen-invisible = 0.
        screen-active = 1.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
      IF  screen-name = 'GRC_RAL'. " AND SY-TCODE EQ 'ZIC_AUTH_FI' .
        screen-invisible = 0.
        screen-active = 1.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
      IF  screen-name = 'GRC_RPL'. "AND SY-TCODE EQ 'ZIC_AUTH_FI' .
        screen-invisible = 0.
        screen-active = 1.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tabctrl100_init OUTPUT.

  PERFORM get_user.

**   if g_hd_copied is initial.
**    refresh control 'TABCTRL100' from screen '0100'.
  DATA l_fis_initial.
  SET PARAMETER ID 'FIS' FIELD l_fis_initial.
  SET PARAMETER ID 'BUK' FIELD l_fis_initial.
**  endif.

ENDMODULE.                    "TABCTRL100_init OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tabctrl100_move OUTPUT.
  MOVE-CORRESPONDING g_tabctrl100_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.

    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0 .
        MOVE zmm_prep_rolecrc-brief_desc TO role_desc.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                  zic_prep_rolerei-role_name.
      IF sy-subrc = 0 .
        MOVE zmm_prep_roledes-brief_desc TO role_desc.
      ENDIF.
    ENDIF.

  ENDIF.
ENDMODULE.                    "TABCTRL100_move OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tabctrl100_get_lines OUTPUT.
  g_tabctrl100_lines = sy-loopc.
ENDMODULE.                    "TABCTRL100_get_lines OUTPUT
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
  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
          COLOR COL_HEADING.
  ULINE.
  IF flag_s_fundc = 'X'.
    PERFORM help_list.
  ENDIF.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_120 OUTPUT.
  SET PF-STATUS 'STATUS_120'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tabctrl100_attrib OUTPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    IF old_ok_code <> 'CRCROLES'.
      IF old_ok_code = 'CREATE'.
      ELSEIF zic_prep_rolereq-crc_fl = 'X'.
        crc_check_fl = 'X'.
      ENDIF.
    ELSE.
      crc_check_fl = 'X'.
    ENDIF.

    IF crc_check_fl <> 'X' .

      CLEAR crc_check_fl.

      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                                                g_tabctrl100_wa-role_name.

      IF sy-subrc = 0.

        LOOP AT SCREEN.

          IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

            IF old_ok_code <> 'APPROVE'.
              screen-input = 1.
            ELSE.
              screen-input = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
            old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            IF zmm_prep_roledes-plant = 'X' AND
                          old_ok_code <> 'APPROVE'.
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-GRP'.

            IF zmm_prep_roledes-p_grp = 'X' AND
                          old_ok_code <> 'APPROVE'.
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

            IF zmm_prep_roledes-app_level = 'X' AND
                        old_ok_code <> 'APPROVE'.
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.


          IF screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

            IF zmm_prep_roledes-s_loc = 'X' AND
                      old_ok_code <> 'APPROVE'.
              .
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

            IF zmm_prep_roledes-r_loc = 'X' AND
                      old_ok_code <> 'APPROVE'.
              .
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

        ENDLOOP.

      ELSE.

        LOOP AT SCREEN.

          IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                         NOT old_ok_code IS INITIAL AND
                         old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
            IF NOT zic_prep_rolerei-role_name IS INITIAL .
              MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
            ENDIF.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ELSE.

      IF zic_prep_rolereq-crc_fl = 'X' OR old_ok_code = 'CRCROLES'.

        SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        IF sy-subrc = 0.

          LOOP AT SCREEN.

            IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

              IF old_ok_code <> 'APPROVE'.
                screen-input = 1.
              ELSE.
                screen-input = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.


            IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .


              IF zmm_prep_rolecrc-plant = 'X' AND
                                   old_ok_code <> 'APPROVE'.
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-GRP' .


              IF zmm_prep_rolecrc-p_grp = 'X' AND
                                   old_ok_code <> 'APPROVE'.
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.


            IF screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

              IF zmm_prep_rolecrc-s_loc = 'X' AND
                        old_ok_code <> 'APPROVE'.
                .
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

              IF zmm_prep_rolecrc-r_loc = 'X' AND
                        old_ok_code <> 'APPROVE'.
                .
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.

          ENDLOOP.

        ELSE.

          LOOP AT SCREEN.

            IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                               NOT old_ok_code IS INITIAL.
              screen-input = 1.
              MODIFY SCREEN.

              IF NOT zic_prep_rolerei-role_name IS INITIAL.
                MESSAGE i116(zhelp) WITH zic_prep_rolerei-role_name.
              ENDIF.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.

      screen-input = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.

  PERFORM get_correspondence.

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

  IF ( old_ok_code = 'CREATE' )
  OR ( old_ok_code = 'CROSSCO' )
  OR ( old_ok_code = 'CRCROLES' )
  OR ( old_ok_code = 'CHANGE' )
  OR ( old_ok_code = 'RELEASE' )
  OR ( old_ok_code = 'APPROVE' )
  OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X' AND
       zic_prep_rolereq-status <> 'C' ).

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
    flag1 = 'X'.
  ENDIF.
  IF ( old_ok_code = 'CREATE' )
      OR ( old_ok_code = 'CROSSCO' )
      OR ( old_ok_code = 'CRCROLES' )
      OR ( old_ok_code = 'CHANGE' )
      OR ( old_ok_code = 'RELEASE' )
      OR ( old_ok_code = 'APPROVE' )
       OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X'
            AND zic_prep_rolereq-status <> 'C').

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
      flag2 = 'X'.
    ENDIF.
  ENDIF.

  PERFORM text_control_eingabebereit1.
  PERFORM text_control_set_text_table1.

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

  IF NOT g_tabctrl100_itab[] IS INITIAL .

    SORT g_tabctrl100_itab
    BY role_name plant grp sloc receipt_loc approver.
    DELETE ADJACENT DUPLICATES FROM g_tabctrl100_itab
    COMPARING role_name plant grp sloc receipt_loc approver.

  ENDIF.

  DESCRIBE TABLE g_tabctrl100_itab LINES tabctrl100-lines.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_110 OUTPUT.

  DESCRIBE TABLE g_tablctrl110_itab LINES tablctrl110-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_110
.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

  IF zic_prep_rolereq-crossco_fl = 'X'.
    g_text = ' : Cross Company Authorisation'.
    SET TITLEBAR 'PREP_TITLE' WITH g_text.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ENDIF.
  IF old_ok_code = 'CREATE' AND ( okcode_100 = '' OR
      okcode_100 = 'CREATE' ) .
    MOVE 'ATTACH' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'LIST' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ENDIF.
  IF old_ok_code = 'CHANGE' AND ( okcode_100 = '' OR
      okcode_100 = 'CHANGE' OR okcode_100 = 'LIST' ) .
    IF zic_prep_rolereq-crc_fl = 'X' OR
       zic_prep_rolereq-crossco_fl = 'X'.
    ELSE.
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
    ENDIF.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ENDIF.

  IF old_ok_code = 'DELETE' AND ( okcode_100 = '' OR
      okcode_100 = 'DELETE' OR okcode_100 = 'LIST' ) .
    MOVE 'ATTACH' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ENDIF.

  IF old_ok_code = 'DISPLAY'
     AND zic_prep_rolereq-comm_fl = 'X'.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ELSE.

    IF old_ok_code = 'DISPLAY' AND ( okcode_100 = '' OR
        okcode_100 = 'DISPLAY' OR okcode_100 = 'LIST' ) .
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ENDIF.

  ENDIF.

  IF old_ok_code = 'APPROVE' AND ( okcode_100 = '' OR
      okcode_100 = 'APPROVE' OR okcode_100 = 'LIST' ) .
    MOVE 'ATTACH' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ENDIF.

  IF zic_prep_rolereq-crc_fl = 'X'.
    g_text = ' : CRC Authorisation'.
    SET TITLEBAR 'PREP_TITLE' WITH g_text.
  ENDIF.
* Begin of <> 25032014
**** Get Users maintained in SET 'ZICE_ARMS_CREATE_GUIDE'.
  CALL FUNCTION 'G_SET_GET_ALL_VALUES'
    EXPORTING
      client        = sy-mandt
      setnr         = 'ZICE_ARMS_CREATE_GUIDE'
      table         = 'AGR_USERS'
      class         = '0000'
      fieldname     = 'UNAME'
    TABLES
      set_values    = lt_set_values
    EXCEPTIONS
      set_not_found = 1
      OTHERS        = 2.

* End of <> 25032014
ENDMODULE.                 " set_title  OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl110_init OUTPUT.
  IF g_tablctrl110_copied IS INITIAL AND old_ok_code <> 'CREATE'.

    REFRESH g_tablctrl110_itab[].
    CLEAR   g_tablctrl110_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
*Begin of <RD1K963151>.
    IF zic_prep_rolereq-docno IS NOT INITIAL.
*End of <RD1K963151>.
      SELECT * FROM zic_prep_rolerei
         INTO CORRESPONDING FIELDS
         OF TABLE g_tablctrl110_itab WHERE moduleid = 'MM' AND
                  docno = zic_prep_rolereq-docno ORDER BY PRIMARY KEY.
*Begin of <RD1K963151>.
    ENDIF.
*End of <RD1K963151>.
    g_tablctrl110_copied = 'X'.
    READ TABLE g_tablctrl110_itab INTO g_tablctrl110_wa INDEX 1.
    IF sy-subrc = 0.
      moduleid = g_tablctrl110_wa-moduleid.
    ENDIF.
    REFRESH CONTROL 'TABLCTRL110' FROM SCREEN '0110'.
  ENDIF.
ENDMODULE.                    "TABLCTRL110_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl110_move OUTPUT.

  MOVE-CORRESPONDING g_tablctrl110_wa TO zic_prep_rolerei.

  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.

    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0 .
        MOVE zmm_prep_rolecrc-brief_desc TO role_desc.
      ENDIF.
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0 AND zic_prep_rolerei-plant <> ''.
        MOVE zmm_prep_crcdesg-crc_pos TO crc_pos.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                  zic_prep_rolerei-role_name.
      IF sy-subrc = 0 .
        MOVE zmm_prep_roledes-brief_desc TO role_desc.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                    "TABLCTRL110_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl110_get_lines OUTPUT.
  g_tablctrl110_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL110_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_dynnr OUTPUT.
  IF dynnr IS INITIAL.
    dynnr = '101'.
  ENDIF.
  CASE moduleid.

    WHEN 'MM'.
      dynnr = '0110'.
    WHEN 'PM'.
      dynnr = '0111'.
    WHEN 'PS'.
      dynnr = '0112'.
    WHEN 'PP'.
      dynnr = '0113'.
    WHEN 'SD'.
      dynnr = '0114'.
    WHEN 'QM'.
      dynnr = '0115'.
    WHEN 'HSE'.
      dynnr = '0116'.
    WHEN 'OLM'.
      dynnr = '0117'.

      """"""""""""""""""""""""""""
      "addition by lipsy  for srm module introduction on 2.03.2015 RD1K996555
    WHEN 'SRM'.
      dynnr = '0118'.
      "end of addition by lipsy  for srm module introduction   on  3.03.2015 RD1K996555
      """""""""""""""""""""""""""""
  ENDCASE.
ENDMODULE.                 " set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_col_attrib OUTPUT.

  LOOP AT tablctrl110-cols INTO cols WHERE index GT 11.
    cols-invisible = '1'.
    MODIFY tablctrl110-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

  LOOP AT tablctrl110-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY tablctrl110-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

ENDMODULE.                 " scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_110 OUTPUT.

  IF NOT g_tablctrl110_itab[] IS INITIAL .

    SORT g_tablctrl110_itab
    BY role_name plant grp sloc receipt_loc approver.
    DELETE ADJACENT DUPLICATES FROM g_tablctrl110_itab
    COMPARING role_name plant grp sloc receipt_loc approver.

  ENDIF.

  DESCRIBE TABLE g_tablctrl110_itab LINES tablctrl110-lines.

ENDMODULE.                 " delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl110_attrib OUTPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    IF old_ok_code <> 'CRCROLES'.
      IF old_ok_code = 'CREATE'.
      ELSEIF zic_prep_rolereq-crc_fl = 'X'.
        crc_check_fl = 'X'.
      ENDIF.
    ELSE.
      crc_check_fl = 'X'.
    ENDIF.

    IF crc_check_fl <> 'X' .

      CLEAR crc_check_fl.

      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                                                g_tablctrl110_wa-role_name
  .

      IF sy-subrc = 0.

        LOOP AT SCREEN.

          IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

            IF old_ok_code <> 'APPROVE'.
              screen-input = 1.
            ELSE.
              screen-input = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
            old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            IF zmm_prep_roledes-plant = 'X' AND
                          old_ok_code <> 'APPROVE'.
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-GRP'.

            IF zmm_prep_roledes-p_grp = 'X' AND
                          old_ok_code <> 'APPROVE'.
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

            IF zmm_prep_roledes-app_level = 'X' AND
                        old_ok_code <> 'APPROVE'.
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

*Begin of <RD1K962817>.
          IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.
            IF g_tablctrl110_wa-role_name = 'M8'.
              IF zmm_prep_roledes-app_level = 'X' AND
                          old_ok_code <> 'APPROVE'.

                screen-input = 0.

                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.
          ENDIF.
*End of <RD1K962817>.
          IF screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

            IF zmm_prep_roledes-s_loc = 'X' AND
                      old_ok_code <> 'APPROVE'.
              .
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.

          IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

            IF zmm_prep_roledes-r_loc = 'X' AND
                      old_ok_code <> 'APPROVE'.
              .
              screen-input = 1.
              MODIFY SCREEN.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

        ENDLOOP.

      ELSE.

        LOOP AT SCREEN.

          IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                         NOT old_ok_code IS INITIAL AND
                         old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
            IF NOT zic_prep_rolerei-role_name IS INITIAL .
              MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
            ENDIF.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ELSE.

      IF zic_prep_rolereq-crc_fl = 'X' OR old_ok_code = 'CRCROLES'.

        SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABLCTRL110_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        IF sy-subrc = 0.

          LOOP AT SCREEN.

            IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

              IF old_ok_code <> 'APPROVE'.
                screen-input = 1.
              ELSE.
                screen-input = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.


            IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .


              IF zmm_prep_rolecrc-plant = 'X' AND
                                   old_ok_code <> 'APPROVE'.
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-GRP' .


              IF zmm_prep_rolecrc-p_grp = 'X' AND
                                   old_ok_code <> 'APPROVE'.
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.


            IF screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

              IF zmm_prep_rolecrc-s_loc = 'X' AND
                        old_ok_code <> 'APPROVE'.
                .
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

              IF zmm_prep_rolecrc-r_loc = 'X' AND
                        old_ok_code <> 'APPROVE'.
                .
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.
**
            IF screen-name = 'CRC_POS' AND
                  ( zic_prep_rolerei-role_name <> 'M3B' AND
                    zic_prep_rolerei-role_name <> 'M11S' AND
                    zic_prep_rolerei-role_name <> 'M11M' ).
              IF old_ok_code <> 'APPROVE'.
                screen-required = 1.
                screen-input = 1.
                MODIFY SCREEN.
              ELSE.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.

            ENDIF.

            IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER' AND
                   ( zic_prep_rolerei-role_name = 'M3B' OR
                    zic_prep_rolerei-role_name = 'M11S' OR
                    zic_prep_rolerei-role_name = 'M11M' ).
              .          screen-input = 1.
            ELSEIF screen-name = 'ZIC_PREP_ROLEREI-APPROVER' AND
                   ( zic_prep_rolerei-role_name <> 'M3B' AND
                    zic_prep_rolerei-role_name <> 'M11S' AND
                    zic_prep_rolerei-role_name <> 'M11M' ).
              screen-input = 0.
            ENDIF.

            MODIFY SCREEN.

**

          ENDLOOP.

        ELSE.

          LOOP AT SCREEN.

            IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                               NOT old_ok_code IS INITIAL.
              screen-input = 1.
              MODIFY SCREEN.

              IF NOT zic_prep_rolerei-role_name IS INITIAL.
                MESSAGE i116(zhelp) WITH zic_prep_rolerei-role_name.
              ENDIF.
            ELSE.
              screen-input = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.

      screen-input = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl111_init OUTPUT.
  IF g_tablctrl111_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl111_itab[].
    CLEAR   g_tablctrl111_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl111_itab WHERE moduleid = 'PM' AND
                docno = zic_prep_rolereq-docno.
    g_tablctrl111_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL111' FROM SCREEN '0111'.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl111_move OUTPUT.

  MOVE-CORRESPONDING g_tablctrl111_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zpm_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl111_get_lines OUTPUT.
  g_tablctrl111_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL111_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_111 OUTPUT.
  IF NOT g_tablctrl111_itab[] IS INITIAL .

    SORT g_tablctrl111_itab
    BY role_name plant shop_no.
    DELETE ADJACENT DUPLICATES FROM g_tablctrl111_itab
    COMPARING role_name plant shop_no.

  ENDIF.

  DESCRIBE TABLE g_tablctrl111_itab LINES tablctrl111-lines.

ENDMODULE.                 " delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl111_attrib OUTPUT.
  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                                              g_tablctrl111_wa-role_name
.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

          IF zpm_prep_roledes-plant = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-SHOP_NO' .

          IF zpm_prep_roledes-shop_no = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.


      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_111 OUTPUT.

  DESCRIBE TABLE g_tablctrl111_itab LINES tablctrl111-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_111
.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_col_attrib OUTPUT.

  LOOP AT tablctrl111-cols INTO cols WHERE index GT 8.
    cols-invisible = '1'.
    MODIFY tablctrl111-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

ENDMODULE.                 " scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE select_data OUTPUT.

  g_release = zic_prep_rolereq-req_cr_fl.
  g_approve = zic_prep_rolereq-req_app_fl.
  g_approve0 = zic_prep_rolereq-req_app0_fl.
  g_approve1 = zic_prep_rolereq-req_app1_fl.

  SELECT SINGLE * FROM zic_prep_rolereq
                  WHERE docno = zic_prep_rolereq-docno.

  IF zic_prep_rolereq-req_cr_fl IS INITIAL.
    zic_prep_rolereq-req_cr_fl = g_release.
  ENDIF.
  IF zic_prep_rolereq-req_app_fl IS INITIAL.
    zic_prep_rolereq-req_app_fl = g_approve.
  ENDIF.
  IF zic_prep_rolereq-req_app1_fl IS INITIAL.
    zic_prep_rolereq-req_app1_fl = g_approve1.
  ENDIF.

  IF zic_prep_rolereq-req_app0_fl IS INITIAL.
    zic_prep_rolereq-req_app0_fl = g_approve0.
  ENDIF.


  CLEAR : g_release, g_approve, g_approve0, g_approve1.

*  select single * from zic_prep_rolereq
*  where docno = zic_prep_rolereq-docno.

  SELECT * FROM zic_prep_rolerei INTO TABLE ist_item
  WHERE docno = zic_prep_rolereq-docno.

ENDMODULE.                 " SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list1 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  DATA : l_desc(30).

  SORT ist_item DESCENDING.

  LOOP AT ist_item INTO wa_item.
    CASE wa_item-moduleid.
      WHEN 'MM'.
        PERFORM check_module_status_mm.
      WHEN 'PM'.
        PERFORM check_module_status_pm.
      WHEN 'PS'.
        PERFORM check_module_status_ps.
      WHEN 'PP'.
        PERFORM check_module_status_pp.
      WHEN 'SD'.
        PERFORM check_module_status_sd.
      WHEN 'QM'.
        PERFORM check_module_status_qm.
      WHEN 'HSE'.
        PERFORM check_module_status_hse.
    ENDCASE.
  ENDLOOP.

  LOOP AT ist_item INTO wa_item.

    CASE wa_item-moduleid .

      WHEN 'MM'.

        AT NEW moduleid.

          WRITE :/.

          IF mm_not_ok = 'X'.
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

        IF zic_prep_rolereq-crc_fl = 'X'.

          SELECT BRIEF_DESC FROM ZMM_PREP_ROLECRC INTO L_DESC UP TO 1 ROWS
 WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        ELSE.

          SELECT SINGLE brief_desc FROM zmm_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        ENDIF.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                 AT 48 wa_item-plant,
                 AT 53 wa_item-grp,
                 AT 59 wa_item-sloc,
                 AT 64 wa_item-receipt_loc,
                 AT 73 wa_item-approver.

      WHEN 'PM'.

        AT NEW moduleid.

          WRITE /.

          IF pm_not_ok = 'X'.
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

        SELECT SINGLE brief_desc FROM zpm_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                 AT 48 wa_item-plant,
                 AT 54 wa_item-shop_no.

**
      WHEN 'PS'.

        AT NEW moduleid.

          WRITE /.

          IF ps_not_ok = 'X'.
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

        SELECT SINGLE brief_desc FROM zps_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                 AT 48 wa_item-service,
                 AT 56 wa_item-project,
                 AT 64 wa_item-location,
                 AT 73 wa_item-asset,
                 AT 79 wa_item-basin.

***

      WHEN 'PP'.

        AT NEW moduleid.

          WRITE /.

          IF pp_not_ok = 'X'.
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

        SELECT SINGLE brief_desc FROM zpp_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                 AT 48 wa_item-plant,
                 AT 56 wa_item-sloc,
                 AT 64 wa_item-res,
                 AT 73 wa_item-ctf_sloc.

      WHEN 'SD'.

        AT NEW moduleid.

          WRITE /.

          IF sd_not_ok = 'X'.
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

        SELECT SINGLE brief_desc FROM zsd_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                 AT 48 wa_item-sale_org,
                 AT 56 wa_item-div,
                 AT 64 wa_item-plant,
                 AT 73 wa_item-ship_point.

      WHEN 'QM'.

        AT NEW moduleid.

          WRITE /.

          IF qm_not_ok = 'X'.
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

        SELECT SINGLE brief_desc FROM zqm_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc,
                 AT 48 wa_item-plant,
                 AT 56 wa_item-asset_qm.

      WHEN 'HSE'.

        AT NEW moduleid.

          WRITE /.

          IF hs_not_ok = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'HSE Module', 'Role', 'Description'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE brief_desc FROM zhs_prep_roledes INTO l_desc
              WHERE role_type = wa_item-role_name.

        WRITE: / wa_item-moduleid, AT 12 wa_item-role_name, AT 17 l_desc.

    ENDCASE.

*
    HIDE : wa_item-moduleid, wa_item-role_name, wa_item-plant,
             wa_item-grp, wa_item-sloc, wa_item-receipt_loc,
             wa_item-approver, wa_item-service, wa_item-project,
             wa_item-location,wa_item-region,wa_item-asset,
             wa_item-basin,wa_item-res, wa_item-ctf_sloc,
             wa_item-sale_org,wa_item-div,wa_item-plant,
             wa_item-ship_point,wa_item-asset_qm.


  ENDLOOP.

ENDMODULE.                 " value_list1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL111_DELETE' OR
             screen-name = 'TABLCTRL111_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_attrib OUTPUT.

  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL110_DELETE' OR
             screen-name = 'TABLCTRL110_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " scr110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl112_init OUTPUT.
  IF g_tablctrl112_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl112_itab[].
    CLEAR   g_tablctrl112_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL112_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl112_itab WHERE moduleid = 'PS' AND
                docno = zic_prep_rolereq-docno.
    g_tablctrl112_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL112' FROM SCREEN '0112'.
  ENDIF.
ENDMODULE.                    "TABLCTRL112_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl112_move OUTPUT.

  MOVE-CORRESPONDING g_tablctrl112_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zps_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.

ENDMODULE.                    "TABLCTRL112_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl112_get_lines OUTPUT.
  g_tablctrl112_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL112_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr112_col_attrib OUTPUT.
  LOOP AT tablctrl112-cols INTO cols WHERE index GT 11.
    cols-invisible = '1'.
    MODIFY tablctrl112-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDMODULE.                 " scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr112_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL112_DELETE' OR
             screen-name = 'TABLCTRL112_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl112_attrib OUTPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> '' AND
      NOT g_tablctrl112_wa-role_name IS INITIAL.

    SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                      g_tablctrl112_wa-role_name.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-SERVICE' .

*            if zps_prep_roledes-service = 'X' and
          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-PROJECT' .

          IF zps_prep_roledes-project = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-LOCATION' .

          IF zps_prep_roledes-location = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

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

        IF screen-name = 'ZIC_PREP_ROLEREI-ASSET' .

          IF zps_prep_roledes-asset = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-BASIN' .

          IF zps_prep_roledes-basin = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.

  IF old_ok_code = 'DISPLAY'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_112 OUTPUT.

  DESCRIBE TABLE g_tablctrl112_itab LINES tablctrl112-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_112
.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor_112  OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl113_init OUTPUT.
  IF g_tablctrl113_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl113_itab[].
    CLEAR   g_tablctrl113_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL113_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl113_itab WHERE moduleid = 'PP' AND
       docno = zic_prep_rolereq-docno.
    g_tablctrl113_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL113' FROM SCREEN '0113'.
  ENDIF.
ENDMODULE.                    "TABLCTRL113_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl113_move OUTPUT.
  MOVE-CORRESPONDING g_tablctrl113_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zpp_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL113_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl113_get_lines OUTPUT.
  g_tablctrl113_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL113_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl113_attrib OUTPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                                              g_tablctrl113_wa-role_name
.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

          IF zpp_prep_roledes-plant = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-SLOC' .

          IF zpp_prep_roledes-sloc = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-RES'.

          SELECT * FROM zpp_prep_res INTO CORRESPONDING FIELDS OF
          TABLE it_res  WHERE role_type = zic_prep_rolerei-role_name
          AND plant = zic_prep_rolerei-plant.

          IF sy-subrc = 0  AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-CTF_SLOC' .

          SELECT SINGLE * FROM zpp_prep_droleex WHERE
              role_type = zic_prep_rolerei-role_name AND
              plant = zic_prep_rolerei-plant AND
              sloc = zic_prep_rolerei-sloc.

          IF sy-subrc = 0 AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_113 OUTPUT.

  DESCRIBE TABLE g_tablctrl113_itab LINES tablctrl113-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_113.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr113_col_attrib OUTPUT.
  LOOP AT tablctrl113-cols INTO cols WHERE index GT 9.
    cols-invisible = '1'.
    MODIFY tablctrl113-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDMODULE.                 " scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr113_attrib OUTPUT.

  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL113_DELETE' OR
             screen-name = 'TABLCTRL113_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " scr113_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl114_init OUTPUT.
  IF g_tablctrl114_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl114_itab[].
    CLEAR   g_tablctrl114_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL114_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl114_itab WHERE moduleid = 'SD' AND
       docno = zic_prep_rolereq-docno.
    g_tablctrl114_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL114' FROM SCREEN '0114'.
  ENDIF.
ENDMODULE.                    "TABLCTRL114_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl114_move OUTPUT.
**13/04/07
  CLEAR zic_prep_rolerei-rej_fl_save.
  MOVE-CORRESPONDING g_tablctrl114_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zsd_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL114_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl114_get_lines OUTPUT.
  g_tablctrl114_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL114_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr114_col_attrib OUTPUT.

  LOOP AT tablctrl114-cols INTO cols WHERE index GT 9.
    cols-invisible = '1'.
    MODIFY tablctrl114-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

ENDMODULE.                 " scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr114_attrib OUTPUT.

  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL114_DELETE' OR
             screen-name = 'TABLCTRL114_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
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
MODULE tablctrl114_attrib OUTPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                                              g_tablctrl114_wa-role_name
.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

          IF zsd_prep_roledes-plant = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-SALE_ORG' .

          IF zsd_prep_roledes-sale_org = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-DIV'.

          IF zsd_prep_roledes-div = 'X'  AND
                       old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-SHIP_POINT' .

          IF zsd_prep_roledes-ship_point = 'X'  AND
                       old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_114  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_114 OUTPUT.

  DESCRIBE TABLE g_tablctrl114_itab LINES tablctrl114-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_114.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor_114  OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl115_init OUTPUT.
  IF g_tablctrl115_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl115_itab[].
    CLEAR   g_tablctrl115_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL115_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl115_itab WHERE
       moduleid = 'QM' AND
       docno = zic_prep_rolereq-docno.
    g_tablctrl115_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL115' FROM SCREEN '0115'.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl115_move OUTPUT.
  MOVE-CORRESPONDING g_tablctrl115_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zqm_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zqm_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl115_get_lines OUTPUT.
  g_tablctrl115_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL115_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr115_col_attrib OUTPUT.
  LOOP AT tablctrl115-cols INTO cols WHERE index GT 7.
    cols-invisible = '1'.
    MODIFY tablctrl115-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDMODULE.                 " scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr115_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL115_DELETE' OR
             screen-name = 'TABLCTRL115_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl115_attrib OUTPUT.

  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    SELECT SINGLE * FROM zqm_prep_roledes WHERE role_type =
                                              g_tablctrl115_wa-role_name
.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

          IF zic_prep_rolereq-ccode = 'MUM' AND
             zic_prep_rolerei-role_name = 'Q1' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-ASSET_QM' .

          SELECT SINGLE * FROM zqm_prep_asset WHERE ccode =
                                                zic_prep_rolereq-ccode.

          IF sy-subrc = 0 AND
             zic_prep_rolerei-role_name = 'Q2' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " TABLCTRL115_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl116_init OUTPUT.
  IF g_tablctrl116_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl116_itab[].
    CLEAR   g_tablctrl116_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL116_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl116_itab WHERE moduleid = 'HSE' AND
                docno = zic_prep_rolereq-docno.
    g_tablctrl116_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL116' FROM SCREEN '0116'.
  ENDIF.
ENDMODULE.                    "TABLCTRL116_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl116_move OUTPUT.
  MOVE-CORRESPONDING g_tablctrl116_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zhs_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL116_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl116_get_lines OUTPUT.
  g_tablctrl116_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL116_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr116_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr116_col_attrib OUTPUT.

  LOOP AT tablctrl116-cols INTO cols WHERE index GT 6.
    cols-invisible = '1'.
    MODIFY tablctrl116-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

ENDMODULE.                 " scr116_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr116_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL116_DELETE' OR
             screen-name = 'TABLCTRL116_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl116_attrib OUTPUT.
  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.

    SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                                              g_tablctrl116_wa-role_name
.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " TABLCTRL116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_116  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_116 OUTPUT.

  DESCRIBE TABLE g_tablctrl116_itab LINES tablctrl116-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_111
.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor_116  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_117'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE tc_117_init OUTPUT.
  IF g_tc_117_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZIC_PREP_ROLEREI'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC_117_itab'
*Begin of <RD1K983325>.

    REFRESH g_tc_117_itab[].
    CLEAR   g_tc_117_itab.
    IF zic_prep_rolereq-docno IS NOT INITIAL.
*End of <RD1K983325>.
      SELECT * FROM zic_prep_rolerei
         INTO CORRESPONDING FIELDS
         OF TABLE g_tc_117_itab WHERE moduleid = 'OLM' AND
                  docno = zic_prep_rolereq-docno ORDER BY PRIMARY KEY.
*Begin of <RD1K983325>.
    ENDIF.
*End of <RD1K983325>.
    g_tc_117_copied = 'X'.
    READ TABLE g_tc_117_itab INTO g_tc_117_wa INDEX 1.
    IF sy-subrc = 0.
      moduleid = g_tc_117_wa-moduleid.
    ENDIF.
    REFRESH CONTROL 'TC_117' FROM SCREEN '0117'.
  ENDIF.
ENDMODULE.                    "TC_117_INIT OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_117'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE tc_117_move OUTPUT.
  MOVE-CORRESPONDING g_tc_117_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                 zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zfi_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TC_117_MOVE OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_117'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_117_get_lines OUTPUT.
  g_tc_117_lines = sy-loopc.
ENDMODULE.                    "TC_117_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR117_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr117_col_attrib OUTPUT.
  LOOP AT tc_117-cols INTO cols WHERE index GT 11.
    cols-invisible = '1'.
    MODIFY tc_117-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

  LOOP AT tc_117-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY tc_117-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDMODULE.                 " SCR117_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr117_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TC_117_DELETE' OR
             screen-name = 'TC_117_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF old_ok_code = 'DISPLAY'.
      IF screen-name = 'TC_117_DELETE' OR
             screen-name = 'TC_117_INSERT' OR
             screen-name = 'COPY'.
*        OR
*        SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' OR
*         SCREEN-NAME = 'ZMM_PREP_ROLEREI-ROLE_NAME'.
        screen-input = 0.
        MODIFY SCREEN.

      ENDIF.

      IF  screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' .
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*    modify screen.
  ENDLOOP.
ENDMODULE.                 " SCR117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_117_attrib OUTPUT.

ENDMODULE.                 " TC_117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_117  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_117 OUTPUT.
  DESCRIBE TABLE g_tc_117_itab LINES tc_117-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_117
.
  ENDIF.

  CLEAR sy-ucomm.
ENDMODULE.                 " SET_CURSOR_117  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pop_message OUTPUT.

  DATA : gv_auth TYPE c.

  IMPORT gv_auth TO gv_auth FROM MEMORY  ID 'AUTH'.

  IF gv_auth <> 'X'.
    MESSAGE 'Please Use TRANSACTION ZOVL_ARMS.' TYPE 'E'.
  ENDIF.

  IF sy-tcode = 'ZICE_ARMS'.
*    BREAK-POINT.

    lv_msg_var = lv_msg_var + 1.

  ENDIF.

*  IF SY-TCODE = 'ZICE_ARMS' AND OLD_OK_CODE = ' ' AND SY-UCOMM = ' '.
  IF lv_msg_var = '1'.
    IF  okcode_100_p NE 'BAC'.
      DATA : l_ans1 TYPE c.
      CLEAR : wa_call.
      SELECT * FROM TVARVC INTO CORRESPONDING FIELDS OF WA_CALL UP TO 1 ROWS
 WHERE NAME = 'ZGRC_CALL'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF wa_call-low EQ 'X'.

*        CALL FUNCTION 'POPUP_TO_INFORM'
*          EXPORTING
*            titel = 'ZOVL_ARMS USER GUIDE-NEW'
*            txt1  = 'The process for ZOVL_ARMS has been changed to include an alert & approval'
*            txt2  = 'process for possible Segregation of Duties Risk in roles of the user.'
*            txt3  = 'Documentation on the revised process is available in Process Guide Section as'
*            txt4  = ' " ZOVL_ARMS USER GUIDE-NEW. " '.



      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_100 OUTPUT.
  IF manager IS INITIAL.
    obj-objtype = objtype.
    obj-objkey = 'ASY'.
    CREATE OBJECT manager
      EXPORTING
        ip_no_commit = 'R'
      EXCEPTIONS
        OTHERS       = 1.
  ENDIF.
ENDMODULE.                 " INIT_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_init OUTPUT.
  IF g_tablctrl118_copied IS INITIAL AND old_ok_code <> 'CREATE'.

    REFRESH g_tablctrl118_itab[].
    CLEAR   g_tablctrl118_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
*Begin of <RD1K963151>.
    IF zic_prep_rolereq-docno IS NOT INITIAL.
*End of <RD1K963151>.
      SELECT * FROM zic_prep_rolerei
         INTO CORRESPONDING FIELDS
         OF TABLE g_tablctrl118_itab WHERE moduleid = 'SRM' AND
                  docno = zic_prep_rolereq-docno ORDER BY PRIMARY KEY.
*Begin of <RD1K963151>.
    ENDIF.
*End of <RD1K963151>.
    g_tablctrl118_copied = 'X'.
    READ TABLE g_tablctrl118_itab INTO g_tablctrl118_wa INDEX 1.
    IF sy-subrc = 0.
      moduleid = g_tablctrl118_wa-moduleid.
    ENDIF.
    REFRESH CONTROL 'TABLCTRL118' FROM SCREEN '0118'.
  ENDIF.
ENDMODULE.                 " TABLCTRL118_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR118_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr118_col_attrib OUTPUT.
  LOOP AT tablctrl118-cols INTO cols WHERE index GT 11.
    cols-invisible = '1'.
    MODIFY tablctrl118-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

  LOOP AT tablctrl118-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY tablctrl118-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDMODULE.                 " SCR118_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr118_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL118_DELETE' OR
             screen-name = 'TABLCTRL118_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " SCR118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_move OUTPUT.
  MOVE-CORRESPONDING g_tablctrl118_wa TO zic_prep_rolerei.

  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.


    SELECT SINGLE * FROM zsr_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zsr_prep_roledes-brief_desc TO role_desc.
    ENDIF.


  ENDIF.
ENDMODULE.                 " TABLCTRL118_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_get_lines OUTPUT.
  g_tablctrl118_lines = sy-loopc.
ENDMODULE.                 " TABLCTRL118_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl118_attrib OUTPUT.
  IF old_ok_code <> 'DISPLAY' AND old_ok_code <> ''.


    SELECT SINGLE * FROM zsr_prep_roledes WHERE role_type =
                                              g_tablctrl118_wa-role_name.

    IF sy-subrc = 0.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

          IF zsr_prep_roledes-plant = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-GRP'.

          IF zsr_prep_roledes-p_grp = 'X' AND
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

          IF zsr_prep_roledes-app_level = 'X' AND
                      old_ok_code <> 'APPROVE'.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
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
        IF screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

          IF zsr_prep_roledes-s_loc = 'X' AND
                    old_ok_code <> 'APPROVE'.
            .
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

          IF zsr_prep_roledes-r_loc = 'X' AND
                    old_ok_code <> 'APPROVE'.
            .
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                       NOT old_ok_code IS INITIAL AND
                       old_ok_code <> 'APPROVE'.
          screen-input = 1.
          MODIFY SCREEN.
          IF NOT zic_prep_rolerei-role_name IS INITIAL .
            MESSAGE i115(zhelp) WITH zic_prep_rolerei-role_name.
          ENDIF.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ENDIF.

*    ELSE.



*    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

  LOOP AT SCREEN.

    IF zic_prep_rolerei-rej_fl <> ''.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " TABLCTRL118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_118  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_118 OUTPUT.
  DESCRIBE TABLE g_tablctrl118_itab LINES tablctrl118-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_118
.
  ENDIF.
  CLEAR sy-ucomm.

ENDMODULE.                 " SET_CURSOR_118  OUTPUT

*--- INCLUDE: MZMMPREPROLE1_PHASEIITOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 68.
*  3) CR No. 30012322  RD1K996279 CAB_SUDHIR

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* 24.02.2015   <RD1K996042>  CAB_SPYADAV    CR 30012295(LIPSY)         *
*                                          (Simultaneous assignment of *
*                                           MM  and OLM roles          *
*                                          during approval)            *
*&                                                                     *
*&                                                                     *
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company ,multi module
*                                           roles,during approval      *
"                                          ,SRM Module introductin)    *
*&                                                                     *
*&                                                                     *
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


************************************************************************

PROGRAM  sapmzmmpreprole               .

TABLES : zic_prep_rolereq, zic_prep_rolerei, zmm_prep_roledes, zusrmst,
         lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
         zmm_prep_rej_lis, zmm_prep_ex_app, soodk, sood5, zmm_prep_rolecrc,
         zmm_prep_sl_excp, zpm_prep_roledes, v_t357, zice_prep_module,
         zmm_prep_status,zps_prep_roledes,zps_prep_service,zps_prep_project,
         zps_prep_asst_ex,zps_prep_loc,t001,zpp_prep_roledes,zpp_prep_droleex,
         zsd_prep_roledes,zqm_prep_roledes, zpp_prep_generic,zhelp_pproles1,
         zqm_prep_loc, zqm_prep_asset, tvta, zsd_prep_ldggrp,zmm_prep_crcdesg,
         zps_prep_loca, zps_prep_serv_rl,zhs_prep_roledes, agr_users,fmhisv , pa9205,
         zol_prep_roledes, zol_prep_rolerei,
         zfi_prep_roledes, ""ZFI_PREP_ROLEREI,
         """""""""""""""""""""""""""""""""""""""""""""
         "commented by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042
*.
         "end of comment by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042
         """""""""""""""""""""""""""""""""
         """""""""""""""""""""""""""""""""""""
         "added by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042
         zhelp_mmroles_rc,zmm_prep_role_sl,zmm_prep_crcimii,zauth_user,zauth_head,agr_define, zauth_excp,
         zauth_item,usr21,
         "end of addition by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042

         """""""""""""""""""""""""""""""""""""""""""""""""

         """""""""""""""""""""""""""""""""""""""""""""""""""""""""
         "addition by lipsy  for srm module introduction on 20.02.2015 RD1K996555
         zsr_prep_roledes.
"end of addition by lipsy  for srm module introduction on 20.02.2015 RD1K996555


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

TYPE-POOLS cxtab .


TYPES: BEGIN OF tab_type,
         fcode LIKE rsmpe-func,
       END OF tab_type.

TYPES : BEGIN OF ty_t024,
          ekgrp LIKE t024-ekgrp,
          eknam LIKE t024-eknam,
        END OF ty_t024.

TYPES: BEGIN OF ty_m_fistb.
TYPES: g_mark.
        INCLUDE STRUCTURE m_fistb.
TYPES: END OF ty_m_fistb.

TYPES : BEGIN OF ty_data,
          pernr        LIKE pa0027-pernr,
          begda        LIKE pa0001-begda,
          endda        LIKE pa0001-endda,
          name         LIKE pa0001-ename,
          bukrs        LIKE pa0001-bukrs,
          werks        LIKE pa0001-werks,
          persk        LIKE pa0001-persk,
          kbu01        LIKE pa0027-kbu01,
          kgb01        LIKE pa0027-kgb01,
          kst01        LIKE pa0027-kst01,
          designo      LIKE pa9930-designo,
          r_p_cd       LIKE pa9930-r_p_cd,
          version      LIKE pa9930-version,
          designation  LIKE zdesignation_rev-sdesig_text,
          adesignation LIKE zdesignation_rev-adesig_text,
          disc_cd      LIKE zdesignation_rev-disc_cd,
          sbmod        TYPE pa0001-sbmod,
        END OF ty_data.

DATA: it_tab    TYPE STANDARD TABLE OF tab_type WITH
      NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      wa_tab    TYPE tab_type,
      wa_pa0027 TYPE pa0027.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data WITH HEADER LINE.
DATA : it_m_fistb  TYPE STANDARD TABLE OF ty_m_fistb,
*Begin of <RD1K963151>.
       wa_fistb    TYPE  ty_m_fistb,
       it_m_fistb1 TYPE STANDARD TABLE OF ty_m_fistb WITH HEADER LINE,
       wa_fistb1   TYPE  ty_m_fistb.
*End of <RD1K963151>.

DATA : txt1(80).
****************************************************************
TYPES:
  BEGIN OF ty_view_apx,
    selc(1) TYPE c.
        INCLUDE STRUCTURE bcos_appx.
TYPES: END OF ty_view_apx.

CONSTANTS: cs_x(1) VALUE 'X'.

DATA : g_apx_exist(1).

DATA: BEGIN OF gs_win_head.
        INCLUDE STRUCTURE soxwd.
DATA: END OF gs_win_head.

DATA : gt_cont       LIKE soli OCCURS 0 WITH HEADER LINE,
       gv_filetype   LIKE rlgrap-filetype,
       gv_filename   TYPE string,
       g_apx_cnt     LIKE bcos_appx-appxno,
       g_apx_ptr     LIKE bcos_appx-firstl,
       g_apx_bin_ptr LIKE bcos_appx-firstl,
       gt_ac_cont    LIKE soli OCCURS 0 WITH HEADER LINE,
       gt_ac_contx   LIKE solix OCCURS 0 WITH HEADER LINE,
       gt_view_apx   TYPE ty_view_apx OCCURS 0 WITH HEADER LINE,
       gt_ac_apx     LIKE bcos_appx OCCURS 5 WITH HEADER LINE,
       gt_contx      LIKE solix OCCURS 0 WITH HEADER LINE.
****************************************************************
DATA g_object_id         LIKE soodk.
DATA g_attachments  LIKE sood5 OCCURS 0 WITH HEADER LINE.
DATA g_attachments_read TYPE c.
DATA on  TYPE c VALUE 'X'.
****************************************************************

DATA : tab TYPE STANDARD TABLE OF tab_type WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

DATA  dynnr LIKE sy-dynnr.

DATA : lv_old      TYPE char2,
       lv_new      TYPE char2,
       l_answer(1) TYPE c.

DATA  g_mode.
DATA  okcode LIKE sy-ucomm.
DATA  g_lock.
DATA  g_hd_copied.
DATA  g_cors.
DATA  g_char(120).
DATA  g_line1(120).
* Begin of <RD1K981840>
*DATA : cpf_lfb1(08) type c.
DATA : cpf_lfb1 TYPE persno.
* End of <RD1K981840>
*&spwizard: type for the data of tablecontrol 'TABCTRL100'
TYPES: BEGIN OF t_tabctrl100,
         docno        LIKE zic_prep_rolerei-docno,
         role_request LIKE zic_prep_rolerei-role_request,
         role_name    LIKE zic_prep_rolerei-role_name,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         sloc         LIKE zic_prep_rolerei-sloc,
         flag,       "flag for mark column
         srno         LIKE zic_prep_rolerei-srno,
         approver     LIKE zic_prep_rolerei-approver,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         status       LIKE zic_prep_rolerei-status,
       END OF t_tabctrl100.

DATA: ist_itemtab TYPE STANDARD TABLE OF zic_prep_rolerei.
DATA: wa_itemtab LIKE zic_prep_rolerei.

***********************************************************************
DATA : ist_colsscreen TYPE TABLE OF cxtab_column-screen.
DATA : ist_column TYPE STANDARD TABLE OF cxtab_column WITH NON-UNIQUE
DEFAULT KEY.
***********************************************************************

*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*

DATA: gv_splitter  TYPE REF TO cl_gui_easy_splitter_container, "#EC NEEDED
      gv_splitter1 TYPE REF TO cl_gui_easy_splitter_container,
      gv_splitter2 TYPE REF TO cl_gui_easy_splitter_container.

DATA: gv_custom_container TYPE REF TO cl_gui_custom_container.

DATA: gv_text_editor  TYPE REF TO cl_gui_textedit,          "#EC NEEDED
      gv_text_editor1 TYPE REF TO cl_gui_textedit,
      gv_text_editor2 TYPE REF TO cl_gui_textedit.

DATA : display_flag LIKE  lv70t-xflag VALUE space.

DATA: BEGIN OF tlinetab OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA: END OF tlinetab.
DATA: BEGIN OF tlinetab1 OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF tlinetab1.
DATA: BEGIN OF tlinetab2 OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF tlinetab2.

CONSTANTS: gc_text_line_length TYPE i VALUE 132.

TYPES: text_table_type(gc_text_line_length) TYPE c OCCURS 0.

DATA: lt_text_table  TYPE text_table_type,
      lt_text_table1 TYPE text_table_type,
      lt_text_table2 TYPE text_table_type.


DATA: gv_xthead_updkz TYPE i.

DATA: BEGIN OF tinlinetab OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA: END OF tinlinetab.

DATA: ls_thead LIKE thead OCCURS 0 WITH HEADER LINE.

DATA: l_thead LIKE ls_thead OCCURS 0 WITH HEADER LINE.

DATA  g_tdname(12).

DATA: BEGIN OF lines20 OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF lines20.

DATA: g2_lines LIKE tline.

DATA: BEGIN OF lines_cors OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF lines_cors.

DATA: BEGIN OF g_lines OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF g_lines.

***************************************************************

*&spwizard: internal table for tablecontrol 'TABCTRL100'
DATA:     g_tabctrl100_itab TYPE t_tabctrl100 OCCURS 0,
          g_tabctrl100_wa   TYPE t_tabctrl100. "work area
DATA:     g_tabctrl100_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABCTRL100' itself
CONTROLS: tabctrl100 TYPE TABLEVIEW USING SCREEN 0100.
DATA cols LIKE LINE OF tabctrl100-cols.

*&spwizard: lines of tablecontrol 'TABCTRL100'
DATA:BEGIN OF g_linefrto ,
       line_fr TYPE i,
       line_to TYPE i,
     END OF g_linefrto.
DATA: g_linefrto_itab LIKE TABLE OF g_linefrto.
DATA : g_tabctrl100_lines  LIKE sy-loopc.
DATA : it_cond LIKE TABLE OF g_char.
DATA : g_select(2).
DATA : g_select_flag.
DATA : it_t024 TYPE STANDARD TABLE OF t024.
DATA : wa_t024 LIKE LINE OF it_t024.
DATA : it_t024_1 TYPE STANDARD TABLE OF t024.
DATA : role_desc(40).
DATA : okcode_100 LIKE sy-ucomm.
DATA : okcode_100_p LIKE sy-ucomm. " + BY BIPIN TO VALIDATE POP UP MESSAGE
DATA : g_line(120).
DATA : help_list_flag.
DATA : wa_m_fistb TYPE ty_m_fistb.
DATA : lines LIKE sy-index.
DATA : flag_s_fundc VALUE 'X'.
DATA : lines_index LIKE sy-index.
DATA : zdocnumb(12).
DATA : insert_items.
DATA : old_ok_code LIKE sy-ucomm.
DATA : g_srno LIKE sy-index.
DATA : old_doc_no LIKE zic_prep_rolereq-docno.
DATA : g_line132(132) TYPE c.
DATA : g_cores_sender LIKE tline-tdline.
DATA : g_user(2).
DATA : g_user_found.
DATA : err_flg.
DATA : tab1_lines LIKE sy-index.
DATA : tab2_lines LIKE sy-index.
DATA : flag1, flag2.
DATA  read_flag.
DATA  g_ins_flag.
DATA  g_cursor_line LIKE sy-stepl.
DATA  g_curr_line LIKE sy-stepl.
DATA  g_current_line LIKE sy-stepl.
DATA  g_curr_line_100 LIKE sy-stepl.
DATA  g_curr_line_110 LIKE sy-stepl.
DATA  g_curr_line_117 LIKE sy-stepl.
DATA  grp_flag.
DATA  plant_flag.
DATA  loc_flag.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  g_reset_fl.
DATA  g_docno LIKE zic_prep_rolereq-docno.
DATA  g_app_rel.
DATA  g_release LIKE zic_prep_rolereq-req_cr_fl.
DATA  g_approve LIKE zic_prep_rolereq-req_app_fl.
DATA  g_approve1 LIKE zic_prep_rolereq-req_app1_fl.
DATA  g_i LIKE sy-index.
DATA  g_tc_lines LIKE sy-index.
DATA  g_comm_fl.
DATA  g_read_fl.
DATA  g_lines_rl LIKE sy-index.
DATA  g_field(40).
DATA  g_e_fl.
DATA  g_role_name_prev LIKE zic_prep_rolerei-role_name.
DATA  g_role_name_flag.
DATA  g_persa LIKE pa0001-werks.
DATA  g_approve0 LIKE zic_prep_rolereq-req_app1_fl.
DATA  old_disc_mm_flag.
DATA  set_disc_mm_flag.
DATA  crc_check_fl.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files LIKE TABLE OF swotobjid.
DATA g_att_files_wa LIKE swotobjid.
DATA : exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
*************************
DATA  old_userid LIKE zic_prep_rolereq-userid.
DATA  g_val_err.
DATA  g_lines_2 LIKE sy-index.
DATA  old_ok_code_crc LIKE old_ok_code.
DATA  g_crc_fl.
DATA  g_ccode LIKE zic_prep_rolereq-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(80).

****************************
DATA : g_field_tab LIKE TABLE OF dfies.
DATA : g_field_wa  LIKE dfies.
DATA  approver_flag.
DATA  g_ccode_crossco LIKE zic_prep_rolereq-ccode.
DATA : crc_pos(132).

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
TYPES: BEGIN OF t_tablctrl110,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex LIKE zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
         agr_name(30),
       END OF t_tablctrl110.

*&spwizard: internal table for tablecontrol 'TABLCTRL110'
DATA:     g_tablctrl110_itab TYPE t_tablctrl110 OCCURS 0,
          g_tablctrl110_wa   TYPE t_tablctrl110. "work area
DATA:     g_tablctrl110_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
CONTROLS: tablctrl110 TYPE TABLEVIEW USING SCREEN 0110.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
DATA:     g_tablctrl110_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.
DATA:     moduleid(3).
DATA:     new_moduleid(3).
DATA      old_moduleid(3).

*&spwizard: type for the data of tablecontrol 'TABLCTRL111'
TYPES: BEGIN OF t_tablctrl111,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         flag,       "flag for mark column
       END OF t_tablctrl111.

*&spwizard: internal table for tablecontrol 'TABLCTRL111'
DATA:     g_tablctrl111_itab TYPE t_tablctrl111 OCCURS 0,
          g_tablctrl111_wa   TYPE t_tablctrl111. "work area
DATA:     g_tablctrl111_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL111' itself
CONTROLS: tablctrl111 TYPE TABLEVIEW USING SCREEN 0111.

*&spwizard: lines of tablecontrol 'TABLCTRL111'
DATA:     g_tablctrl111_lines  LIKE sy-loopc.
DATA      g_curr_line_111 LIKE sy-stepl.
DATA  check_role_flag.
DATA   : ist_item LIKE TABLE OF zic_prep_rolerei.
DATA   : wa_item LIKE LINE OF ist_item.
DATA  g_l4.
DATA  modulemm_fl.
DATA  moduleid_save LIKE zic_prep_rolerei-moduleid.
DATA  g_mult_module_fl.
DATA : status_desc LIKE zmm_prep_status-status_desc.
DATA : it_module1 LIKE TABLE OF zic_modules.
DATA : wa_module1 LIKE LINE OF it_module1.
DATA  mm_not_ok.
DATA  pm_not_ok.
DATA  ps_not_ok.
DATA  hs_not_ok.
DATA  g_choice_app.

*&spwizard: type for the data of tablecontrol 'TABLCTRL112'
TYPES: BEGIN OF t_tablctrl112,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         service      LIKE zic_prep_rolerei-service,
         project      LIKE zic_prep_rolerei-project,
         location     LIKE zic_prep_rolerei-location,
*         REGION like ZIC_PREP_ROLEREI-REGION,
         asset        LIKE zic_prep_rolerei-asset,
         basin        LIKE zic_prep_rolerei-basin,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
       END OF t_tablctrl112.

*&spwizard: internal table for tablecontrol 'TABLCTRL112'
DATA:     g_tablctrl112_itab TYPE t_tablctrl112 OCCURS 0,
          g_tablctrl112_wa   TYPE t_tablctrl112. "work area
DATA:     g_tablctrl112_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL112' itself
CONTROLS: tablctrl112 TYPE TABLEVIEW USING SCREEN 0112.

*&spwizard: lines of tablecontrol 'TABLCTRL112'
DATA:     g_tablctrl112_lines  LIKE sy-loopc.
DATA  module_changed_flag.
** POV & checks
TYPES :
  BEGIN OF asset_ty,
    ccode  TYPE zic_prep_rolereq-ccode,
    asset  TYPE zqm_prep_asset-asset,
    a_desc TYPE zchar80,
  END OF asset_ty.

TYPES :
  BEGIN OF basin_ty,
    ccode  TYPE zic_prep_rolereq-ccode,
    basin  TYPE zic_prep_rolerei-basin,
    b_desc TYPE zchar80,
  END OF basin_ty.

DATA : it_basin TYPE TABLE OF basin_ty WITH HEADER LINE.
DATA : it_asset TYPE TABLE OF asset_ty WITH HEADER LINE.
DATA : it_location TYPE TABLE OF zps_prep_loc WITH HEADER LINE.
DATA : it_loca     TYPE TABLE OF zps_prep_loc WITH HEADER LINE.
DATA : it_project TYPE TABLE OF zps_prep_project WITH HEADER LINE.
DATA : it_service TYPE TABLE OF zps_prep_service WITH HEADER LINE.
DATA : it_plant LIKE TABLE OF zqm_prep_loc WITH HEADER LINE.
DATA  g_curr_line_112 LIKE sy-stepl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
TYPES: BEGIN OF t_tablctrl113,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         sloc         LIKE zic_prep_rolerei-sloc,
         res          LIKE zic_prep_rolerei-res,
         ctf_sloc     LIKE zic_prep_rolerei-ctf_sloc,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
       END OF t_tablctrl113.

*&spwizard: internal table for tablecontrol 'TABLCTRL113'
DATA:     g_tablctrl113_itab TYPE t_tablctrl113 OCCURS 0,
          g_tablctrl113_wa   TYPE t_tablctrl113. "work area
DATA:     g_tablctrl113_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL113' itself
CONTROLS: tablctrl113 TYPE TABLEVIEW USING SCREEN 0113.

*&spwizard: lines of tablecontrol 'TABLCTRL113'
DATA:     g_tablctrl113_lines  LIKE sy-loopc.
DATA  g_curr_line_113 LIKE sy-stepl.

*****************
TYPES :
  BEGIN OF res_ty,
    res LIKE zpp_prep_res-res,
  END OF res_ty.
DATA : it_res TYPE TABLE OF res_ty WITH HEADER LINE.
*****************
DATA  pp_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL114'
TYPES: BEGIN OF t_tablctrl114,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         sale_org     LIKE zic_prep_rolerei-sale_org,
         div          LIKE zic_prep_rolerei-div,
         ship_point   LIKE zic_prep_rolerei-ship_point,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
       END OF t_tablctrl114.

*&spwizard: internal table for tablecontrol 'TABLCTRL114'
DATA:     g_tablctrl114_itab TYPE t_tablctrl114 OCCURS 0,
          g_tablctrl114_wa   TYPE t_tablctrl114. "work area
DATA:     g_tablctrl114_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL114' itself
CONTROLS: tablctrl114 TYPE TABLEVIEW USING SCREEN 0114.

DATA   : it_tvswz LIKE TABLE OF tvswz WITH HEADER LINE.
DATA   : it_tvko LIKE TABLE OF tvko WITH HEADER LINE.
DATA   : it_tvkos LIKE TABLE OF tvkos WITH HEADER LINE.
DATA   : it_tvstz LIKE TABLE OF tvstz WITH HEADER LINE.

*&spwizard: lines of tablecontrol 'TABLCTRL114'
DATA:     g_tablctrl114_lines  LIKE sy-loopc.
DATA  g_curr_line_114 LIKE sy-stepl.
DATA  sd_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL115'
TYPES: BEGIN OF t_tablctrl115,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         asset_qm     LIKE zic_prep_rolerei-asset_qm,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
       END OF t_tablctrl115.

*&spwizard: internal table for tablecontrol 'TABLCTRL115'
DATA:     g_tablctrl115_itab TYPE t_tablctrl115 OCCURS 0,
          g_tablctrl115_wa   TYPE t_tablctrl115. "work area
DATA:     g_tablctrl115_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL115' itself
CONTROLS: tablctrl115 TYPE TABLEVIEW USING SCREEN 0115.

*&spwizard: lines of tablecontrol 'TABLCTRL115'
DATA:     g_tablctrl115_lines  LIKE sy-loopc.
DATA      g_curr_line_115 LIKE sy-stepl.
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
**
DATA : ist_seltab1 LIKE TABLE OF rsparams.
DATA : seltab1 LIKE rsparams.
DATA  qm_not_ok.
DATA  g_error_fundc.
DATA  set_disc_fi_flag.
***********************************************************
DATA  it_pos LIKE STANDARD TABLE OF zmm_prep_crcdesg WITH HEADER LINE.
DATA  attach_fl.
DATA  g_choice_more.
DATA  g_choice_rel.

*&spwizard: type for the data of tablecontrol 'TABLCTRL116'
TYPES: BEGIN OF t_tablctrl116,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         flag,       "flag for mark column
       END OF t_tablctrl116.

*&spwizard: internal table for tablecontrol 'TABLCTRL116'
DATA:     g_tablctrl116_itab TYPE t_tablctrl116 OCCURS 0,
          g_tablctrl116_wa   TYPE t_tablctrl116. "work area
DATA:     g_tablctrl116_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL116' itself
CONTROLS: tablctrl116 TYPE TABLEVIEW USING SCREEN 0116.

*&spwizard: lines of tablecontrol 'TABLCTRL116'
DATA:     g_tablctrl116_lines  LIKE sy-loopc.
DATA  g_curr_line_116 LIKE sy-stepl.

DATA : ist_return_tab3 LIKE STANDARD TABLE OF dynpread WITH HEADER LINE.

*Begin of <RD1K963151>
TYPES : BEGIN OF str_fmhisv,
          fikrs     TYPE 	fikrs,
          hivarnt   TYPE  fm_hivarnt,
          fistl     TYPE  fistl,
          hiroot_st TYPE  fm_fictr_t,
          parent_st TYPE  fm_fictr_p,
          next_st   TYPE fm_fictr_n,
          child_st  TYPE  fm_fictr_c,
          hilevel	  TYPE fm_hilevel,
        END OF str_fmhisv.

DATA :it_fmhisv TYPE TABLE OF str_fmhisv WITH HEADER LINE,
      wa_fmhisv TYPE str_fmhisv.
*End of <RD1K963151>.

DATA   :it_9205 TYPE  STANDARD TABLE OF  pa9205,
        wa_9205 TYPE pa9205.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC_117'
TYPES: BEGIN OF t_tc_117,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex LIKE zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
         agr_name(30),
       END OF t_tc_117.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC_117'
DATA:     g_tc_117_itab TYPE t_tc_117 OCCURS 0,
          g_tc_117_wa   TYPE t_tc_117. "work area
DATA:     g_tc_117_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_117' ITSELF
CONTROLS: tc_117 TYPE TABLEVIEW USING SCREEN 0117.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_117'
DATA:     g_tc_117_lines  LIKE sy-loopc.

********************** data declaration by bipin ****************************************
DATA :  reqnum_ex  TYPE zic_prep_rolereq-docno,
        oc_9001_rj TYPE sy-ucomm,
        oc_9002_rj TYPE sy-ucomm,
        oc_9003_rj TYPE sy-ucomm,
        crt_name   TYPE zic_prep_rolereq-useridcr,
        tcode_rj   TYPE sy-tcode,
        okcode_rj  TYPE sy-ucomm.



DATA : it_tvarv TYPE TABLE OF tvarvc,
       wa_tvarv TYPE tvarvc.

DATA : lv_grccall TYPE c.
DATA : lv_subrc TYPE sy-subrc.


DATA : lv_counter TYPE i VALUE 0.

DATA : wa_grcdata TYPE zic_prep_rolereq.
TYPE-POOLS icon.
DATA gicon(4) TYPE c.

DATA : risk_desc TYPE string.

DATA : gt_icon TYPE TABLE OF zgrc_sod_result,
       wa_icon TYPE zgrc_sod_result.

DATA : gt_icon1 TYPE TABLE OF zgrc_sod_result,
       wa_icon1 TYPE zgrc_sod_result.

DATA : lv_count TYPE i.


DATA : lv_lines TYPE sy-dbcnt.
DATA : gd_percent TYPE i.
DATA : lv_indx1 TYPE sy-tabix.

DATA : check_okcode TYPE c.

*************************Data declaration for FORM GRC_RISK_ANALYSIS. start ***********

DATA : gt_bucket      TYPE TABLE OF zic_prep_rolerei,
       wa_bucket      TYPE zic_prep_rolerei,
       gt_crmodule    TYPE TABLE OF zic_prep_rolerei,
       wa_crmodule    TYPE zic_prep_rolerei,
       gt_bucket1     TYPE zgrc_fi_ttyp,
       wa_bucket1     TYPE zgrc_fi_tabc,
       gt_eroles      TYPE ztb_final1,
       wa_eroles      TYPE ztb_final,
       gt_eroles1     TYPE ztb_final1,
       wa_eroles1     TYPE ztb_final,
       gt_output      TYPE grac_t_sod_prm_viol_det,
       wa_output      TYPE grac_s_sod_prm_viol_det,
       gt_rdesc       TYPE zecc_risk_desc_tt,
       wa_rdesc       TYPE zecc_risk_desc,
       gt_violdtl     TYPE grac_t_sod_prm_viol_det,
       wa_violdtl     TYPE grac_s_sod_prm_viol_det,
       gt_cp_risk     TYPE zecc_risk_desc_tt,
       gt_action_risk TYPE zecc_risk_desc_tt,
       wa_action_risk TYPE zecc_risk_desc,
       wa_cp_risk     TYPE zecc_risk_desc,
       gt_viol_dtl    TYPE TABLE OF zgrc_viol_dtl,
       wa_viol_dtl    TYPE zgrc_viol_dtl.


DATA : gt_bucket_ex   TYPE TABLE OF zic_prep_rolerei,
       wa_bucket_ex   TYPE zic_prep_rolerei,
       gt_crmodule_ex TYPE TABLE OF zic_prep_rolerei,
       wa_crmodule_ex TYPE zic_prep_rolerei.

DATA : okcode_ex TYPE sy-ucomm.



TYPES : BEGIN OF ty_userinfo,
          userid        TYPE  xubname,
          designation   TYPE  ad_dprtmnt,
          persa         TYPE  persa,
          rsn_code      TYPE  zrsn_code,
          telno         TYPE  zchar40,
          ccode         TYPE  bukrs,
          fundc1        TYPE  fm_fictr,
          persk         TYPE  persk,
          reasonforauth TYPE zchar40,
          costc         TYPE kostl,
          desig_level   TYPE zchar02,
          name          TYPE name_last,
          name1         TYPE pbtxt,
          rsn_text1     TYPE char40,
        END OF ty_userinfo.

TYPES : BEGIN OF ty_buk_role,
          docno              TYPE  zchar12,
          moduleid           TYPE  z_module,
          srno               TYPE  zsrno,
          role_name          TYPE  zchar04,
          plant              TYPE  zchar04,
          grp                TYPE  zchar03,
          sloc               TYPE  zchar04,
          receipt_loc        TYPE  zchar04,
          approver           TYPE  zchar02,
          status             TYPE  zchar01,
          role_request       TYPE  zchar12_req,
          rej_fl             TYPE  zchar01,
          rej_id             TYPE  xubname,
          rej_date           TYPE  zrefdate,
          rej_fl_save        TYPE  zchar01,
          shop_no            TYPE  zchar03,
          role_desc          TYPE  zchar40,
          flag               TYPE  char1,
          gl_account         TYPE  saknr,
          bussiness_area     TYPE  gsber,
          fund_ctr_gp        TYPE  fistl,
          jva_grp            TYPE  bukrs,
          sub_module         TYPE  zchar04,
          role_sensitivity   TYPE  zchar01,
          fr_date_auth       TYPE  zrefdate,
          to_date_auth       TYPE  zchar04,
          role_type_ex       TYPE  zchar02,
          sale_org           TYPE  vkorg,
          div                TYPE  spart,
          ship_point         TYPE  vstel,
          asset              TYPE  zchar03_a,
          basin              TYPE  zchar03_b,
          project            TYPE  zchar02_p,
          location           TYPE  zchar02_l,
          asset_qm           TYPE  zchar04,
          res                TYPE  arbpl,
          ctf_sloc           TYPE  zchar04,
          userid             TYPE  syuname,
          role_type          TYPE  zchar04,
          role_name_final    TYPE  role_name,
          fr_date_auth_final TYPE  char10,
          to_date_auth_final TYPE char10,
        END OF ty_buk_role.


DATA : gt_userinfo    TYPE TABLE OF ty_userinfo,
       wa_userinfo    TYPE ty_userinfo,
       gt_buk_role    TYPE TABLE OF ty_buk_role,
       wa_buk_role    TYPE ty_buk_role,
       gt_final_tb    TYPE TABLE OF zgrc_sod_result,
       wa_final_tb    TYPE zgrc_sod_result,
       gt_output_temp TYPE STANDARD TABLE OF zgrc_sod_result,
       gs_output_temp TYPE zgrc_sod_result.

FIELD-SYMBOLS: <fs_final> TYPE zgrc_sod_result.
DATA :gt_item_fieldcat    TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_list_top_of_page TYPE slis_t_listheader,
      gt_events           TYPE slis_t_event,
      fs_eventcat         LIKE LINE OF gt_events,
      gt_layout           TYPE slis_layout_alv.

DATA : v_snum TYPE n LENGTH 10.
DATA : lv_snum TYPE n LENGTH 10,
*      LV_DOCNO TYPE ZGRC_SOD_RESULT-DOCNO,
       lv_ind  TYPE i.

DATA : v_snum1 TYPE n LENGTH 10.
DATA : lv_snum1 TYPE n LENGTH 10.

DATA : gt_risk TYPE TABLE OF zgrc_sod_result,
       wa_risk TYPE zgrc_sod_result.

DATA : gt_log TYPE TABLE OF zgrc_log,
       wa_log TYPE zgrc_log.

DATA : gt_text TYPE TABLE OF lvc_txt132,
       gw_text TYPE  lvc_txt132.


DATA : zice_ex TYPE zice_arms_comment,
       lv_expo TYPE c.

DATA : lv_risk   TYPE i,
       lv_rcount TYPE i.


************************data declaration to sent mail at first level approvel : by Bipin Shukla
DATA: docdata      TYPE sodocchgi1,
      objpack      TYPE TABLE OF sopcklsti1 WITH HEADER LINE,
      objpack_line LIKE LINE OF objpack,
      gt_objhead   TYPE TABLE OF solisti1,
      wa_objhead   TYPE solisti1,
      objbin       TYPE TABLE OF solisti1,
      gt_reclist   TYPE TABLE OF somlreci1,
      lv_tab_lines TYPE sy-tabix,
      wa_reclist   TYPE somlreci1.


DATA : gt_urinfo TYPE TABLE OF pa0105,
       wa_urinfo TYPE pa0105.

DATA : gt_uname TYPE TABLE OF pa0002,
       wa_uname TYPE pa0002.

DATA : lv_urname TYPE pad_nachn.

DATA : gt_appinfo TYPE TABLE OF pa0105,
       wa_appinfo TYPE pa0105.

DATA : gt_appname TYPE TABLE OF pa0002,
       wa_appname TYPE pa0002.

DATA : lv_appname TYPE pad_nachn.


DATA : gt_role_usr TYPE TABLE OF agr_users,
       wa_role_usr TYPE          agr_users.

DATA  : lv_rfc     TYPE rfcdest,
        lv_msg_var TYPE i.

DATA: it_call TYPE TABLE OF tvarvc,
      wa_call TYPE tvarvc.

DATA  : lv5_rfc TYPE rfcdest.
DATA  : lv6_rfc TYPE rfcdest.
DATA  : lv7_rfc TYPE rfcdest.
DATA  : lv8_rfc TYPE rfcdest.
DATA  : lv9_rfc TYPE rfcdest.



************************data declaration to sent mail at first level approvel : by Bipin Shukla

*  DATA : lv_lines TYPE I.
*DATA : LV_LINES1 TYPE SY-DBCNT.
*DATA : GD_PERCENT TYPE I.
*DATA : LV_INDX1 TYPE SY-TABIX.
*
*DATA : CHECK_OKCODE TYPE C.

*************************Data declaration for FORM GRC_RISK_ANALYSIS. end *************

********************** data declaration by bipin *************************************************
* Begin of <> on 24032014
CONSTANTS: objtype TYPE borident-objtype VALUE 'ZGOS'.
TYPES: BEGIN OF exclude_type,
         fcode LIKE rsmpe-func,
       END OF exclude_type.
DATA: manager    TYPE REF TO cl_gos_manager,
      obj        TYPE borident,
      exclude_wa TYPE exclude_type.
DATA: lt_set_values TYPE TABLE OF rgsb4,
      g_tcode1(8),
      g_tcode       TYPE sy-ucomm,
      uname         TYPE sy-uname.
* End of <>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""added by lipsy on 13.02.2015 for simultaneous assignment of roles with approval RD1K996042
*--------Purpose: Sending mail to user
DATA : object_content LIKE solisti1  OCCURS 0 WITH HEADER LINE.
DATA : BEGIN OF objhead OCCURS 5.
        INCLUDE STRUCTURE solisti1.
DATA : END OF objhead.

DATA : BEGIN OF document_data.
        INCLUDE STRUCTURE sodocchgi1.
DATA : END OF document_data.
DATA : receivers TYPE TABLE OF   somlreci1  .
DATA : wa_receivers TYPE somlreci1.
DATA : sent_to_all   LIKE  sonv-flag.


TYPES : BEGIN OF ty_data_assn,
          pernr        LIKE pa0027-pernr,
          begda        LIKE pa0001-begda,
          endda        LIKE pa0001-endda,
          name         LIKE pa0001-ename,
          bukrs        LIKE pa0001-bukrs,
          werks        LIKE pa0001-werks,
          persk        LIKE pa0001-persk,
          kbu01        LIKE pa0027-kbu01,
          kgb01        LIKE pa0027-kgb01,
          kst01        LIKE pa0027-kst01,
          designo      LIKE pa9930-designo,
          r_p_cd       LIKE pa9930-r_p_cd,
          version      LIKE pa9930-version,
          designation  LIKE zdesignation_rev-sdesig_text,
          adesignation LIKE zdesignation_rev-adesig_text,
          disc_cd      LIKE zdesignation_rev-disc_cd,
          sbmod        TYPE pa0001-sbmod,
        END OF ty_data_assn.

TYPES : BEGIN OF in_roles,
          role_type(04),
          role_name        LIKE vagratts-agr_name,
          fr_date_auth(10),
          to_date_auth(10),
        END OF in_roles,

        BEGIN OF out_roles,
          userid           LIKE sy-uname,
          role_name        LIKE vagratts-agr_name,
          fr_date_auth(10),
          to_date_auth(10),
        END OF out_roles.

TYPES : BEGIN OF del_roles,
          userid    LIKE sy-uname,
          role_name LIKE vagratts-agr_name,
        END OF del_roles.

DATA : it_roles       TYPE STANDARD TABLE OF in_roles,
       it_roles0      TYPE STANDARD TABLE OF in_roles,
       it_roles1      TYPE STANDARD TABLE OF out_roles,
       it_roles1_addl TYPE STANDARD TABLE OF out_roles,
       it_roles_olm   TYPE STANDARD TABLE OF in_roles.


DATA :  ist_data2 TYPE STANDARD  TABLE OF ty_data_assn WITH HEADER LINE,
        ist_data1 TYPE STANDARD  TABLE OF ty_data_assn WITH HEADER LINE.

DATA : wa_roles     TYPE in_roles,
       wa_roles_olm LIKE LINE OF it_roles_olm.
DATA: wa_itemtab_sl    LIKE zic_prep_rolerei,
      wa_item_req      LIKE LINE OF g_tablctrl110_itab,
      wa_role_del_data TYPE del_roles.
DATA : wa_roles1 TYPE out_roles.
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA : lv_min_desig TYPE zmin_desig,
       lv_curr_role TYPE persk.
DATA : p1_file LIKE rlgrap-filename VALUE 'C:\role_upload.txt'.
DATA  gl_ans.
DATA  g_role_flag.
DATA  zrolereqno LIKE zmm_prep_rolereq-docno.
DATA  corr_code LIKE sy-ucomm.
DATA  status_process.
DATA  status_process_flag.
DATA  status_choice.
DATA  : flag.
DATA  gl_ans_save.
DATA  g_request_close_flag_p.
DATA  g_request_close_flag_h.
DATA  g_request_close_flag_r.
DATA  l_old_ok_code.
DATA  l_initial.
DATA  g_list_proc_flag.
DATA : g_userid LIKE wa_roles1-userid,
       l_color  TYPE i.

DATA : ist_seltab LIKE TABLE OF rsparams.
DATA : seltab2 LIKE rsparams.
DATA  zuserid LIKE zic_prep_rolereq-useridcr.
DATA  zapprover LIKE zic_prep_rolereq-useridap.
DATA : p_rem1(40),
       p_rem2(10).
DATA l_options TYPE ctu_params.
DATA: BEGIN OF upl_tab OCCURS 0,
        cpf_no   TYPE zauth_item-cpf_no,
        role     TYPE zauth_item-role,
******************************************
        from_dat LIKE usagr-from_dat,
        to_dat   LIKE usagr-to_dat,

********************************************
      END OF upl_tab.
DATA: BEGIN OF upl_tabx OCCURS 0,
        cpf_no       TYPE zauth_item-cpf_no,
        role         TYPE zauth_item-role,
*****************************************************************
        from_dat(10),
        to_dat(10) ,
*****************************************************************
        role_na(1),
        user_na(1),
        remarks(50),
      END OF upl_tabx.
DATA  zfilename LIKE rscat-evfile.
DATA  zfilename1 LIKE rlgrap-filename.
TYPES: BEGIN OF t_role,
         item_no   LIKE zauth_item-item_no,
         cpf_no    LIKE zauth_item-cpf_no,
         role      LIKE zauth_item-role,
         text      LIKE agr_texts-text,
         from_dat  LIKE usagr-from_dat,
         to_dat    LIKE usagr-to_dat,
*****************************************************************
         user_name LIKE adrp-name_text,
         flag,       "flag for mark column
       END OF t_role.

* INTERNAL TABLE FOR TABLECONTROL 'ROLE'
DATA:     g_role_itab   TYPE t_role OCCURS 0 WITH HEADER LINE.
DATA: s_itab type t_role.
DATA:  zitem_no LIKE zauth_item-item_no.
DATA: zget_number(8) TYPE n.
DATA: l_agr_users1 LIKE TABLE OF agr_users WITH HEADER LINE .
DATA:v_remarks_head TYPE zauth_head-remarks.
DATA:  wa_rolesz_olm  TYPE  t_tc_117,
       v_moduleid(3),
       v_message_as   TYPE c,
       v_message_unas TYPE  char120.

DATA: v_release TYPE c.
"""""end of addition  by lipsy on 13.02.2015 for simultaneous assignment of roles with approval RD1K996042
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"addition by lipsy  for srm module introduction on 2.03.2015 RD1K996555
TYPES: BEGIN OF t_tablctrl118,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex LIKE zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
         agr_name(30),
       END OF t_tablctrl118.

DATA:     g_tablctrl118_itab TYPE t_tablctrl118 OCCURS 0,
          g_wa_pgrp          TYPE t_tablctrl118, "work area
          g_tablctrl118_wa   TYPE t_tablctrl118. "work area
DATA:     g_tablctrl118_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
CONTROLS: tablctrl118 TYPE TABLEVIEW USING SCREEN 0118.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
DATA:     g_tablctrl118_lines  LIKE sy-loopc.
DATA  g_curr_line_118 LIKE sy-stepl.


DATA:it_roles_srm TYPE STANDARD TABLE OF in_roles,
     wa_roles_srm LIKE LINE OF it_roles_srm.
DATA: l_logsys(32),
p_uname TYPE xubname.

TYPES :BEGIN OF ty_srmp,
         mandt     TYPE mandt,
         userid    LIKE zic_prep_rolereq-userid,
         role_name LIKE zic_prep_rolerei-role_name,
         ccode     LIKE zic_prep_rolereq-ccode,
         grp       LIKE zic_prep_rolerei-grp,
         from_dat  TYPE sy-datum,
         to_dat    TYPE sy-datum,
       END OF ty_srmp.


TYPES:BEGIN OF ty_return,
        mandt     TYPE mandt,
        uname     TYPE persno,
        grp       TYPE zic_prep_rolerei-grp,
        role_name TYPE zic_prep_rolerei-role_name,
        status    TYPE char2,
      END OF ty_return.

DATA:it_roles_srmp TYPE TABLE OF ty_srmp,
     wa_roles_srmp LIKE LINE OF it_roles_srmp,
     wa_zbcusrmst  TYPE zbcusrmst,
     p_fname       TYPE zbcusrmst-first_name,
     p_lname       TYPE zbcusrmst-last_name,
     p_ccode       TYPE bukrs.
DATA:g_line_srm(120).
DATA:grp_flag_srm.

DATA:itab_return     TYPE TABLE OF ty_return,
     wa_return       LIKE LINE OF  itab_return,
     v_srm_st        TYPE c,
     l_flag_msg      TYPE c,
     v_app           TYPE c,
     p_grp           TYPE zchar03,
     p_role          TYPE zic_prep_rolerei-role_name,
     v_exist         TYPE char1,
     v_rolereq-docno TYPE  zauth_head-auth_req_no,
     p_uname_sms     TYPE persno,
     g_userid_n      TYPE persno,
     v_message_srm   TYPE char120,
     count_grp(4)    TYPE n,
     g_user_l2(2).
"end of addition by lipsy  for srm module introduction on 2.03.2015 RD1K996555
""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 22.05.2015 RD1K997318
DATA:itab_agr_users TYPE TABLE OF agr_users,
     v_grp_comp     TYPE char5.
"end of addition by lipsy on 22.05.2015 RD1K997318
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*------------Added by Manisha bh.Dt:09.02.2018--------*
DATA : wa_zmm_vms_cr_new TYPE zmm_vms_cr_new,
       wa_pa0001         TYPE pa0001.
*-----------------------------------------------------*
TYPES :
  BEGIN OF ty_bukrs,
    werks LIKE zd_t001w_bukrs-werks,
    name1 LIKE zd_t001w_bukrs-name1,
  END OF ty_bukrs.

DATA   : it_bukrs TYPE TABLE OF ty_bukrs WITH HEADER LINE.

DATA: it_agr TYPE STANDARD TABLE OF bapiagr,
      wa_agr TYPE bapiagr.

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
