*--- MAIN PROGRAM: SAPMZMMMER ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMMER                                        *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
***********************************************************************
* Program    : SAPMZMMMER                                             *
* Title      : Material Extension requests                            *
* Functional Specification No.: FS-MM-MAT-003                         *
* Author     : Nandini Bakre                 Date : 19-MAY-2005       *
* Login Id   : CAB_NANDINIB                                           *
* Desciption : To generate the daily Production report at BPA/BPB.    *
* Plant specific fields from the system as well as ZTables are to be  *
* Grouped together to form the report                                 *
* Transaction Code :  --                                              *
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description             Chng ID           *
* 15/06/2005  Biswajeet Basumatary                  cab_basu          *
* 02/09/2005  Cab_kartik    Bug fix                 rk001(RD1K928632) *
* 05/09/2005  cab_kartik    Bug fix                 rk002(RD1K928686) *
* 08/09/2005  cab_kartik                            rk003(RD1K928792) *
* 20/10/2005  cab_kartik    matcode validation      rk004(RD1K929720) *
* 01/12/2005  cab_kartik    new number range        rk005(RD1K930835) *
* 15/12/2005  cab_kartik    Valuation Types Addn    rk006(RD1K931258) *
* 28/02/2006  cab_kartik    Plant 12f3 valuation    rk007(RD1K933529) *
*                           *-LSTK-LF not tobe                        *
*                           used                                      *
***********************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Change in INCLUDE MZMMMERF01
*
************************************************************************


INCLUDE mzmmmertop .
INCLUDE mzmmmero01 .
INCLUDE mzmmmeri01 .
INCLUDE mzmmmerf01 .
INCLUDE <icon>.

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

*--- INCLUDE: CL_FML_SDM_BADI_AMDP_TF=======CU ---*
CLASS cl_fml_sdm_badi_amdp_tf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb .

    CLASS-METHODS fetch_sdm_phase
        FOR TABLE FUNCTION p_fml_sdm_phase_badi_amdp_tf.


*--- INCLUDE: CL_GUI_DYNPRO_COMPANION=======CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_GUI_DYNPRO_COMPANION and it's users.
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

*--- INCLUDE: IF_AMDP_MARKER_HDB============IU ---*
"! Marker interface for AMDP classes. A class that implements at least one
"! AMDP method has to include this interface.
interface IF_AMDP_MARKER_HDB
  public.

  constants:
    version type I value 1. "#EC NOTEXT
  class-data:
    _activate type i read-only.

endinterface.

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

*--- INCLUDE: IF_MESSAGE====================IT ---*

*--- INCLUDE: IF_T100_MESSAGE===============IT ---*

*--- INCLUDE: MZMMMERF01 ---*
***INCLUDE MZMMMERF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM UPLOAD Replaced with GUI_UPLOAD.
*
*
************************************************************************
" Begin of <RD1K960036>.
CONSTANTS: g_c_asc TYPE char10 VALUE 'ASC'.
" End of <RD1K960036>.

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
      PERFORM fcode_move_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.

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

    WHEN 'SASCEND'.
      PERFORM fcode_sort_as USING p_tc_name
                                  p_table_name
                                  l_ok.
      CLEAR p_ok.

    WHEN 'SDESCEND'.
      PERFORM fcode_sort_ds USING p_tc_name
                                  p_table_name
                                  l_ok.
      CLEAR p_ok.

    WHEN 'FILTER'.
      PERFORM fcode_filter_tc USING p_tc_name
                                    p_table_name
                                    l_ok.
      CLEAR p_ok.
    WHEN 'IMPORT'.
      PERFORM fcode_import_tc USING p_tc_name
                                    p_table_name
                                    l_ok.
      CLEAR p_ok.

    WHEN 'CHECK'.
      PERFORM fcode_check_tc USING p_tc_name
                                   p_table_name
                                   l_ok.
      CLEAR p_ok.

    WHEN 'COPY'.                      "copy row
      PERFORM fcode_copy_row USING      p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.


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
*   DATA l_actual           TYPE i.
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
*   DESCRIBE TABLE <table> LINES l_actual.
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.

*&SPWIZARD: set new cursor line
  l_line = l_selline - <tc>-top_line + 1.
* insert initial line

*   l_selline = l_actual + 1.
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
*   <tc>-lines = <tc>-lines + 1.
  <tc>-lines = 999.

* set cursor
  SET CURSOR LINE l_line.
*   SET CURSOR LINE l_selline.
ENDFORM.                              " FCODE_INSERT_ROW
*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_move_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.

  DATA: l_wa TYPE t_tc_81.
  CLEAR : ist_del.                                          "+rk001
  REFRESH ist_del.                                          "+rk001
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

      READ TABLE <table> INDEX syst-tabix INTO l_wa. "#EC CI_FLDEXT_OK[2215424]
      MOVE-CORRESPONDING l_wa TO ist_del.
      MOVE zmm_mems-docno  TO ist_del-docno.
      APPEND ist_del.

    ENDIF.
    CLEAR ist_del.                                          "+rk002
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

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

  DATA: l_wa TYPE t_tc_81.

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
*         <tc>-lines = <tc>-lines - 1.
        <tc>-lines = 999.
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


* is no line filled?
*
  IF <tc>-lines = 0.
*   yes, ...
*
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...
*
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
*&      Form  GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_document_number .

  IF g_ok_80 EQ 'CREATE'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZMM_ME1'   "'ZMM_ME'
        quantity                = '1'
*       toyear                  = '2005'
      IMPORTING
        number                  = number
        returncode              = rc
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM assign_sy_values.
  CLEAR zmm_mems.
  MOVE sy-datum TO zmm_mems-ersda .
  MOVE sy-uname TO zmm_mems-ernam .
ENDFORM.                    " ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*&      Form  FCODE_SORT_as
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_sort_as USING    p_tc_name
                            p_table_name
                            p_ok.

  DATA l_table_name  LIKE feld-name.
  DATA cols          LIKE LINE OF tc_81-cols.

  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body

  ASSIGN (l_table_name) TO <table>.                "not headerline

  READ TABLE tc_81-cols INTO cols WITH KEY selected = 'X'.
  IF sy-subrc = 0.
    SORT <table> BY (cols-screen-name+9) ASCENDING .
    cols-selected = ' '.
    MODIFY tc_81-cols FROM cols INDEX sy-tabix.
  ENDIF.


ENDFORM.                    " FCODE_SORT_TC
*&---------------------------------------------------------------------
*
*&      Form  FCODE_SORT_ds
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_sort_ds USING    p_tc_name
                            p_table_name
                            p_ok.

  DATA l_table_name  LIKE feld-name.
  DATA cols          LIKE LINE OF tc_81-cols.

  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body

  ASSIGN (l_table_name) TO <table>.                "not headerline

  READ TABLE tc_81-cols INTO cols WITH KEY selected = 'X'.
  IF sy-subrc = 0.
    SORT <table> BY (cols-screen-name+9) DESCENDING .
    cols-selected = ' '.
    MODIFY tc_81-cols FROM cols INDEX sy-tabix.
  ENDIF.


ENDFORM.                    " FCODE_SORT_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_filter_tc USING    p_tc_name
                              p_table_name
                              p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_filt_no_change.
  DATA l_table_name          LIKE feld-name.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
*-END OF LOCAL DATA----------------------------------------------------*
* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

ENDFORM.                    " FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*&      Form  FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_import_tc USING    p_tc_name
                              p_table_name
                              p_ok.

  DATA: l_filename LIKE rlgrap-filename.
  DATA: l_tc_81_itab TYPE t_tc_81 OCCURS 0.
  DATA: wa_tc_81_itab TYPE t_tc_81.

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
*             data_tab                = l_tc_81_itab
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



  DATA : i_file_table TYPE  TABLE OF file_table,
         l_filetable  TYPE  file_table,
         l_rc         TYPE  i,
         l_p_def_file TYPE  string,
         l_p_file     TYPE  string,
         l_usr_act    TYPE  i.

  l_p_def_file = l_filename.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     WINDOW_TITLE            =
*     DEFAULT_EXTENSION       =
      default_filename        = l_p_def_file
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      file_table              = i_file_table
      rc                      = l_rc
      user_action             = l_usr_act
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0 AND
     l_usr_act <>
     cl_gui_frontend_services=>action_cancel.

    LOOP AT i_file_table  INTO l_filetable.
      l_p_file = l_filetable.
      EXIT.
    ENDLOOP.

    CALL FUNCTION 'GUI_UPLOAD'   "#EC CI_FLDEXT_OK[2215424]
      EXPORTING
        filename                = l_p_file
        filetype                = g_c_asc
        has_field_separator     = 'X'
      TABLES
        data_tab                = l_tc_81_itab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
  DATA line TYPE p.
  DATA line1 TYPE p.
  DATA line2 TYPE p.
  DESCRIBE TABLE l_tc_81_itab LINES line.
  DESCRIBE TABLE g_tc_81_itab LINES line1.
  line2 = line + line1.
  IF line2 > 100.
    MESSAGE e867.
    EXIT.
  ELSE.
    " End of <RD1K960036>.

*-----start of add by rk004 --------------------------*
*matcode validation durin text file data upload
    IF NOT l_tc_81_itab[] IS INITIAL.
      LOOP AT l_tc_81_itab[] INTO wa_tc_81_itab.
        PERFORM validate_matnr USING wa_tc_81_itab-matnr
*{   INSERT         OCPK900065                                        1
**********************************************************************
wa_tc_81_itab-steuc
**********************************************************************
*}   INSERT
                               CHANGING wa_tc_81_itab-remrk.
        IF NOT wa_tc_81_itab-remrk IS INITIAL.
          MODIFY l_tc_81_itab[] FROM wa_tc_81_itab.
        ENDIF.
      ENDLOOP.
    ENDIF.
*-----end of add by rk004 --------------------------*

    IF sy-subrc EQ 0.
      IF g_tc_81_itab[] IS INITIAL.
        g_tc_81_itab[] = l_tc_81_itab[].
      ELSE.
        APPEND LINES OF l_tc_81_itab TO g_tc_81_itab.
        REFRESH l_tc_81_itab.
      ENDIF.
    ENDIF.

    REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
    tc_81-lines = 100.
  ENDIF.

ENDFORM.                    " FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*&      Form  SAVE_9081
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_9081.
*   IF g_button_check NE 'X'.
*     MESSAGE e748.
*     EXIT.
*   ENDIF.

  IF g_tc_81_itab IS INITIAL.
    CLEAR sy-ucomm.
    MESSAGE e354.
  ENDIF.

  PERFORM check_material.
  PERFORM extend_material.
*{   INSERT         OCPK900065                                        1
  LOOP AT g_tc_81_itab INTO G_TC_81_wa.

  ENDLOOP.
*}   INSERT
  IF g_mm01_ist[] IS NOT INITIAL.
    PERFORM get_document_number.

    PERFORM delete_data_base ON COMMIT .
    PERFORM commit_rollback.
    PERFORM update_workareas.
    PERFORM modify_data_base ON COMMIT .
    PERFORM commit_rollback.
    IF sy-subrc EQ 0.
      PERFORM extend.
    ENDIF.
    PERFORM user_message.
  ENDIF.
*  PERFORM DISPLAY_MESG.
ENDFORM.                                                    " SAVE_9081
*&---------------------------------------------------------------------*
*&      Form  modify_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_data_base.

  MODIFY zmm_mems FROM zmm_mems.
  MODIFY zmm_mecs FROM TABLE ist_zmm_mecs.

ENDFORM.                    " modify_data_base
*&---------------------------------------------------------------------*
*&      Form  commit_rollback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM commit_rollback.

  CASE sy-subrc.
    WHEN 0 .
      COMMIT WORK.
    WHEN OTHERS .
      ROLLBACK WORK .
      MESSAGE e671(zps).
  ENDCASE .

ENDFORM.                    " commit_rollback
*&---------------------------------------------------------------------*
*&      Form  user_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_message.
  DATA: var(140) TYPE c.
  CASE g_ok_80.
    WHEN 'CREATE'.

      CONCATENATE 'for the request number' number INTO  var SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = TEXT-020
          textline2 = var.
      LEAVE TO SCREEN 9080.
*      MESSAGE S351 WITH NUMBER.
*{   INSERT         OCPK900065                                        1
    WHEN 'UPDATE'.

      CONCATENATE 'for the request number' number INTO  var SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = TEXT-020
          textline2 = var.
      LEAVE TO SCREEN 9080.
*}   INSERT

    WHEN 'CHANGE'.
      CONCATENATE 'for the request number' zmm_mems-docno INTO  var SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = TEXT-020
          textline2 = var.
      LEAVE TO SCREEN 9080.
  ENDCASE.

ENDFORM.                    " user_message
*&---------------------------------------------------------------------*
*&      Form  update_workareas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_workareas.
  CLEAR ist_zmm_mecs.                                       "+RK002
  IF g_ok_80 EQ 'CREATE'.
    zmm_mems-docno = number.
    zmm_mems-sflag = 'N'.
  ENDIF.

  LOOP AT g_tc_81_itab INTO g_tc_81_wa.

    MOVE-CORRESPONDING g_tc_81_wa TO wa_zmm_mecs.

    IF g_ok_80 EQ 'CREATE'.
      MOVE number TO wa_zmm_mecs-docno.
      MOVE sy-datum TO wa_zmm_mecs-ersda.
      MOVE sy-uname TO wa_zmm_mecs-ernam.
      MOVE 'N'      TO wa_zmm_mecs-sflag.
    ELSEIF g_ok_80 EQ 'CHANGE'.
      MOVE zmm_mems-docno TO wa_zmm_mecs-docno.
      MOVE sy-datum TO wa_zmm_mecs-ersda.
      MOVE sy-uname TO wa_zmm_mecs-ernam.
      MOVE sy-datum TO wa_zmm_mecs-laeda.
      MOVE sy-uname TO wa_zmm_mecs-aenam.
      MOVE 'N'      TO wa_zmm_mecs-sflag.
    ENDIF.

    APPEND wa_zmm_mecs TO ist_zmm_mecs.

  ENDLOOP.

  SORT ist_zmm_mecs BY docno matnr werks bwtar.

  DELETE ADJACENT DUPLICATES FROM ist_zmm_mecs.


ENDFORM.                    " update_workareas
*&---------------------------------------------------------------------*
*&      Form  FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_check_tc USING    p_tc_name
                             p_table_name
                             p_ok.

  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>         TYPE t_tc_81.

  DATA: l_mecs      TYPE zmm_mecs.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

*  DATA: l_remrk(60) TYPE c.
  DATA: l_remrk(61) TYPE c.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
  DATA: l_matnr     LIKE mara-matnr.
  DATA: l_value(2)  TYPE  c.
  DATA: l_trip(3)   TYPE  c.
  DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
  DATA: l_tabix     LIKE sy-tabix.
  DATA: l_msgt      TYPE LINE OF zmm_msgt.
  DATA: l_mstae     TYPE mara-mstae.
  DATA: l_agr_users TYPE agr_users.
  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: l_bwtar TYPE bwtar_d.
  DATA: l_views(1) TYPE n.                                  "+rk003

  CLEAR l_views.
  DATA: ans.
*-END OF LOCAL DATA----------------------------------------------------*
  ASSIGN (p_tc_name) TO <tc>.
* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  LOOP AT <table> ASSIGNING <wa>.

    IF <wa>-matnr EQ space.
      EXIT.
    ENDIF.

    l_tabix = sy-tabix.

    IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.

      IF NOT <wa>-werks IS INITIAL.
        CALL FUNCTION 'GET_PLANT_DETAILS'
          EXPORTING
            i_werks         = <wa>-werks
          IMPORTING
            e_t001w         = t001w
          EXCEPTIONS
            not_found       = 1
            parameter_error = 2
            OTHERS          = 3.

        IF sy-subrc EQ 0.

          IF NOT <wa>-bwtar IS INITIAL.

            l_bwtar = <wa>-bwtar.

            IF l_bwtar EQ 'BATCH_MNGD'.
              CLEAR l_bwtar.
            ENDIF.

            IF NOT <wa>-matnr IS INITIAL.
              "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

              DATA: lv_matnr TYPE bapimatdet-material.
              lv_matnr = <wa>-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*              CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
              CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
                EXPORTING
*                 material              = <wa>-matnr
                  material              = lv_matnr
                  plant                 = <wa>-werks
                  valuationarea         = t001w-bwkey
                  valuationtype         = l_bwtar
                IMPORTING
                  material_general_data = general_data
                  return                = return
                  materialplantdata     = plantdata
                  materialvaluationdata = valuationdata.
              "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
              IF return-type EQ 'S'.

                DATA : plants TYPE TABLE OF marc_werk WITH HEADER LINE.
                DATA : l_strlen TYPE i.

                REFRESH plants.
                CLEAR l_strlen.

                CALL FUNCTION 'MATERIAL_READ_PLANTS'
                  EXPORTING
                    matnr  = <wa>-matnr
                  TABLES
                    plants = plants.

                READ TABLE plants  WITH KEY werks = <wa>-werks.
                l_strlen = strlen( plants-pstat ).
*--------start of changes by rk003------------------------------------*

                SELECT SINGLE * FROM t320 WHERE
                                werks EQ <wa>-werks.
                IF sy-subrc IS INITIAL.
                  l_views = 7.
                ELSE.
                  l_views = 6.
                ENDIF.

*--------end of changes by rk003------------------------------------*

*                 IF l_strlen GE 6.        "-rk002
                IF l_strlen = l_views.                      "+RK003
                  <wa>-remrk = TEXT-010.  "Already extended
                  EXIT.
                ENDIF.
              ELSEIF return-type EQ 'E' AND return-code EQ 'M3305'.
                <wa>-remrk = return-message_v1.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR l_bwtar.
        ENDIF.
      ENDIF.



      CLEAR l_matnr.
      SELECT SINGLE matnr mstae  INTO (l_matnr, l_mstae)
                          FROM mara
                          WHERE matnr = <wa>-matnr.
      IF sy-subrc NE 0.
        CONCATENATE 'Material'
                     <wa>-matnr
                    'does not exist - check your entry'
                    INTO l_remrk SEPARATED BY space.
        MOVE l_remrk TO <wa>-remrk.
        CLEAR l_remrk.
      ELSEIF sy-subrc EQ 0.
        IF NOT ( l_mstae IS INITIAL ).
          SELECT SINGLE * FROM t141t WHERE mmsta = l_mstae
                                       AND spras = 'E'.
          <wa>-remrk = t141t-mtstb.
        ENDIF.
      ENDIF.
      CLEAR t001w.
      SELECT SINGLE * FROM t001w WHERE werks = <wa>-werks.
      IF sy-subrc NE 0.
        CONCATENATE 'Plant'
                    <wa>-werks
                    'does not exist - check your entry'
                    INTO l_remrk SEPARATED BY space.
        MOVE l_remrk TO <wa>-remrk.
        CLEAR l_remrk.
*       ELSE.
*         SELECT SINGLE * FROM t001k WHERE bwkey = <wa>-werks
*                                      AND bukrs = zmm_mems-bukrs.
*         IF sy-subrc NE 0.
*           CONCATENATE 'Plant'
*                       <wa>-werks
*                     'does not belong to Company code' zmm_mems-bukrs
*                       INTO l_remrk SEPARATED BY space.
*           MOVE l_remrk TO <wa>-remrk.
*           CLEAR l_remrk.
*         ENDIF.
      ENDIF.

*       CLEAR l_agr_users.
*       SELECT SINGLE * FROM agr_users
*                    INTO l_agr_users
*                    WHERE agr_name = 'D:MM_MAT_IND_APPROVE_02'
*                      AND uname    = <wa>-bname.
*
*       IF sy-subrc NE 0.
*         CONCATENATE 'User'
*                     <wa>-bname
*                   'does not have MRP role'
*                     INTO l_remrk SEPARATED BY space.
*         MOVE l_remrk TO <wa>-remrk.
*         CLEAR l_remrk.
*       ENDIF.

      CLEAR l_value.
      l_value = <wa>-matnr+0(2).
      IF l_value NE '0C'.
        CLEAR t149d.
        SELECT SINGLE * FROM t149d WHERE bwtar = <wa>-bwtar.
        IF sy-subrc NE 0.
          CONCATENATE 'Valuation type'
                       <wa>-bwtar
                      'does not exist - check your entry'
                      INTO l_remrk SEPARATED BY space.
          MOVE l_remrk TO <wa>-remrk.
          CLEAR l_remrk.
        ENDIF.

        CLEAR l_trip.
*         l_trip = <wa>-bwtar+0(3).                        "-rk006
        l_trip = <wa>-bwtar+0(2).                           "+rk006
        IF l_value GE '01' AND l_value LE '16'.
*           IF l_trip NE 'STI'.                             "-RK006
          IF l_trip NE 'ST'.                                "+RK006
*             <wa>-remrk = text-012.                        "-RK006
            <wa>-remrk = TEXT-019.                          "+RK006
          ENDIF.
        ELSEIF l_value GE '21' AND l_value LE '42'.
*           IF l_trip NE 'SPI'.                             "-RK006
          IF l_trip NE 'SP'.                                "+RK006
*             <wa>-remrk = text-013.                        "-RK006
            <wa>-remrk = TEXT-018.                          "+RK006
          ENDIF.
        ENDIF.
      ELSE.
        IF l_value EQ '0C'.
          IF <wa>-bwtar NE 'BATCH_MNGD'."'Batch Managed'.
            <wa>-remrk = TEXT-011.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY <table> FROM <wa> INDEX l_tabix.
  ENDLOOP.

  DATA : answer.
  REFRESH temp.
  CLEAR temp.

  LOOP AT <table> ASSIGNING <wa>.
    temp-remrk = <wa>-remrk.
    APPEND temp.
    CLEAR temp.
  ENDLOOP.

  DELETE temp WHERE remrk EQ space.

  IF temp[] IS INITIAL.


    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-021
        titel         = 'Information'
        start_column  = 25
        start_row     = 6
      IMPORTING
        answer        = ans.
    CASE ans.
      WHEN 'J'.
        PERFORM save_9081.
      WHEN 'N'.
* do nothing
    ENDCASE.

  ELSE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = 'Information'
        textline1 = TEXT-016.
*     IF sy-subrc EQ 0.
*       CLEAR fcode.
*     ENDIF.

  ENDIF.

ENDFORM.                    " FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*&      Form  validate_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_records.

  DATA: l_mecs      TYPE zmm_mecs.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
*  DATA: l_remrk(60) TYPE c.
  DATA: l_remrk(61) TYPE c.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
  DATA: l_matnr     LIKE mara-matnr.
  DATA: l_value(2)  TYPE  c.
  DATA: l_trip(3)   TYPE  c.
  DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
  DATA: l_mstae     TYPE mara-mstae.
  DATA: l_agr_users TYPE agr_users.
  DATA: zseqwrk TYPE TABLE OF zseqwrk WITH HEADER LINE.
  DATA: l_bwtar TYPE bwtar_d.
  DATA: t001w    LIKE  t001w.
  DATA: plants TYPE marc_werk OCCURS 0 WITH HEADER LINE.
  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: l_views(1) TYPE n.                                  "+rk003

  CLEAR l_views.
  IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.

*------------------------------------------------------*
*rk004- only if the material is valid for extn, perform
* other validations

    PERFORM validate_matnr USING zmm_mecs-matnr
*{   INSERT         OCPK900065                                        1
zmm_mecs-steuc
*}   INSERT
                       CHANGING zmm_mecs-remrk.

    IF NOT zmm_mecs-remrk IS INITIAL.
      EXIT.
    ENDIF.
*end of code add by rk004
*------------------------------------------------------*
    IF g_ok_80 EQ 'CREATE'.
      SELECT * FROM zmm_mecs INTO l_mecs UP TO 1 ROWS
 WHERE matnr = zmm_mecs-matnr AND werks = zmm_mecs-werks AND bwtar = zmm_mecs-bwtar
 ORDER BY PRIMARY KEY .
      ENDSELECT.
      IF sy-subrc EQ 0.
        IF l_mecs-sflag EQ 'C'.
          zmm_mecs-remrk = TEXT-010.  "Already extended
          EXIT.
*         ELSEIF l_mecs-sflag EQ 'N'.   "-RK002
        ELSEIF l_mecs-sflag EQ 'N' OR l_mecs-sflag EQ 'P'.  "+RK002
          CONCATENATE 'Material is already included in request no '
                       l_mecs-docno  INTO l_remrk SEPARATED BY space.
          MOVE l_remrk TO zmm_mecs-remrk.
          CLEAR l_remrk.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT zmm_mecs-werks IS INITIAL.

      CALL FUNCTION 'GET_PLANT_DETAILS'
        EXPORTING
          i_werks         = zmm_mecs-werks
        IMPORTING
          e_t001w         = t001w
        EXCEPTIONS
          not_found       = 1
          parameter_error = 2
          OTHERS          = 3.

      IF sy-subrc EQ 0.

        IF NOT zmm_mecs-bwtar IS INITIAL.

          l_bwtar = zmm_mecs-bwtar.

          IF l_bwtar EQ 'BATCH_MNGD'.
            CLEAR l_bwtar.
          ENDIF.

          IF NOT zmm_mecs-matnr IS INITIAL.
            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

            DATA: lv_matnr TYPE bapimatdet-material.
            lv_matnr = zmm_mecs-matnr.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
              EXPORTING
*               material              = zmm_mecs-matnr
                material              = lv_matnr
                plant                 = zmm_mecs-werks
                valuationarea         = t001w-bwkey
                valuationtype         = l_bwtar
              IMPORTING
                material_general_data = general_data
                return                = return
                materialplantdata     = plantdata
                materialvaluationdata = valuationdata.
            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
            IF return-type EQ 'S'.

              CALL FUNCTION 'MATERIAL_READ_PLANTS'
                EXPORTING
                  matnr  = zmm_mecs-matnr
                TABLES
                  plants = plants.

              READ TABLE plants WITH KEY werks =  zmm_mecs-werks.

              IF sy-subrc EQ 0.
                DATA : l_strlen TYPE i.
                l_strlen = strlen( plants-pstat ).
*--------start of changes by rk003------------------------------------*

                SELECT SINGLE * FROM t320 WHERE
                                werks EQ zmm_mecs-werks.
                IF sy-subrc IS INITIAL.
                  l_views = 7.
                ELSE.
                  l_views = 6.
                ENDIF.

*--------end of changes by rk003------------------------------------*

*                 IF l_strlen GE 6.                   "-RK001
                IF l_strlen = l_views.                      "+RK003
                  zmm_mecs-remrk = TEXT-010.  "Alreadyextended
                  EXIT.
                ENDIF.
              ENDIF.
            ELSEIF return-type EQ 'E' AND return-code EQ 'M3305'.
              zmm_mecs-remrk = return-message.
              EXIT.
            ENDIF.

          ENDIF.
          CLEAR l_bwtar.
        ENDIF.

      ENDIF.

    ENDIF.


    CLEAR l_matnr.
    SELECT SINGLE matnr mstae  INTO (l_matnr, l_mstae)
                        FROM mara
                        WHERE matnr = zmm_mecs-matnr.
    IF sy-subrc NE 0.
      CONCATENATE 'Material'
                   zmm_mecs-matnr
                  'does not exist - check your entry'
                  INTO l_remrk SEPARATED BY space.
      MOVE l_remrk TO zmm_mecs-remrk.
      CLEAR l_remrk.
      EXIT.
    ELSEIF sy-subrc EQ 0.
      IF NOT ( l_mstae IS INITIAL ).
        SELECT SINGLE * FROM t141t WHERE mmsta = l_mstae
                                     AND spras = 'E'.
        zmm_mecs-remrk = t141t-mtstb.
        EXIT.
      ENDIF.
    ENDIF.

    CLEAR t001w.
    SELECT SINGLE * FROM t001w INTO t001w WHERE werks = zmm_mecs-werks.

    IF sy-subrc NE 0.
      CONCATENATE 'Plant'
                  zmm_mecs-werks
                  'does not exist - check your entry'
                  INTO l_remrk SEPARATED BY space.
      IF zmm_mecs-remrk IS INITIAL.                         "+rk004
        MOVE l_remrk TO zmm_mecs-remrk.
      ENDIF.                                                "+rk004
      CLEAR l_remrk.
      EXIT.
    ENDIF.

    CLEAR l_value.
    l_value = zmm_mecs-matnr+0(2).
    IF l_value NE '0C'.
      CLEAR t149d.
      SELECT SINGLE * FROM t149d WHERE bwtar = zmm_mecs-bwtar.
      IF sy-subrc NE 0.
        CONCATENATE 'Valuation type'
                     zmm_mecs-bwtar
                    'does not exist - check your entry'
                    INTO l_remrk SEPARATED BY space.
        IF zmm_mecs-remrk IS INITIAL.                       "+rk004
          MOVE l_remrk TO zmm_mecs-remrk.
        ENDIF.                                              "+rk004
        CLEAR l_remrk.
        EXIT.
      ENDIF.

      CLEAR l_trip.
*       l_trip = zmm_mecs-bwtar+0(3).                       "-rk006
      l_trip = zmm_mecs-bwtar+0(2).                         "+rk006
      IF l_value GE '01' AND l_value LE '16'.
*{-RK006
*         IF l_trip NE 'STI'.
*           zmm_mecs-remrk = text-012.
*           EXIT.
*         ENDIF.
*       ELSEIF l_value GE '21' AND l_value LE '42'.
*         IF l_trip NE 'SPI'.
*           zmm_mecs-remrk = text-013.
*           EXIT.
*         ENDIF.
*       ENDIF.
*}-RK006
*{+RK006
        IF l_trip NE 'ST'.
          zmm_mecs-remrk = TEXT-019.
          EXIT.
        ENDIF.
      ELSEIF l_value GE '21' AND l_value LE '42'.
        IF l_trip NE 'SP'.
          zmm_mecs-remrk = TEXT-018.
          EXIT.
        ENDIF.
      ENDIF.
*}+RK006
    ELSE.
      IF l_value EQ '0C'.
        IF zmm_mecs-bwtar NE 'BATCH_MNGD'."'Batch Managed'.
          zmm_mecs-remrk = TEXT-011.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF sy-subrc EQ 0.
    CLEAR zmm_mecs-remrk.
  ENDIF.

ENDFORM.                    " validate_records
*&---------------------------------------------------------------------*
*&      Form  GET_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_itab_data.

  DATA: l_itab TYPE TABLE OF zmm_mecs WITH HEADER LINE..

*   CLEAR ZMM_MEMS.
  SELECT SINGLE * FROM zmm_mems WHERE docno = g_docno.

  IF g_ok_82 EQ 'CHANGE'.

    IF zmm_mems-sflag EQ 'C'.

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Error'
          textline1 = 'Request cannot be changed at this stage'
          textline2 = 'The request has been completed'.

      SET SCREEN 9080.

    ELSEIF zmm_mems-sflag EQ 'P'.

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Error'
          textline1 = 'Request cannot be changed at this stage.'
          textline2 = 'The request is under process.'.

      SET SCREEN 9080.


    ELSE.

      CLEAR : l_itab.
      SELECT * FROM zmm_mecs INTO CORRESPONDING FIELDS OF TABLE
               l_itab  WHERE docno = g_docno.

      LOOP AT l_itab.
        MOVE-CORRESPONDING l_itab TO g_tc_81_wa.
        APPEND g_tc_81_wa TO g_tc_81_itab.
      ENDLOOP.

      SET SCREEN 9081.

    ENDIF.

  ELSE.

    CLEAR : l_itab.
    SELECT * FROM zmm_mecs INTO CORRESPONDING FIELDS OF TABLE
             l_itab  WHERE docno = g_docno.

    LOOP AT l_itab.
      MOVE-CORRESPONDING l_itab TO g_tc_81_wa.
      APPEND g_tc_81_wa TO g_tc_81_itab.
    ENDLOOP.

    SET SCREEN 9081.

  ENDIF.


ENDFORM.                    " GET_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_user.

  DATA: l_mems TYPE zmm_mems.

  IF NOT ( zmm_mems-docno IS INITIAL ).

    SELECT SINGLE * FROM zmm_mems INTO l_mems
                    WHERE docno = zmm_mems-docno.

    IF sy-uname <> l_mems-ernam.
      IF g_ok_80 EQ 'CHANGE'.
        MESSAGE s353.
        LEAVE TO SCREEN 9080.
      ELSEIF g_ok_80 EQ 'DELETE'.
        MESSAGE s358.
        LEAVE TO SCREEN 9080.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_USER
*&---------------------------------------------------------------------*
*&      Form  get_commitment_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_commitment_number.

  DATA: l_valclass  TYPE zmm_valclass.
  DATA: l_konts     TYPE t030-konts.
  DATA: l_fipos     TYPE skb1-fipos.


  CLEAR l_valclass.
  CLEAR zmm_mecs-fipos.

  SELECT * FROM zmm_valclass
 INTO l_valclass UP TO 1 ROWS WHERE matnr_from LE zmm_mecs-matnr AND matnr_to GE zmm_mecs-matnr AND val_type EQ space
 ORDER BY PRIMARY KEY .
  ENDSELECT.

  IF sy-subrc EQ 0.
    CLEAR l_konts.
    SELECT konts INTO l_konts
 FROM t030 UP TO 1 ROWS WHERE ktosl = 'BSX' AND bwmod = 'ONGC' AND bklas = l_valclass-val_class
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc EQ 0.
      CLEAR l_fipos.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

*      SELECT SINGLE fipos INTO l_fipos
*      FROM skb1 WHERE saknr = l_konts
*                  AND bukrs = zmm_mems-bukrs.
      SELECT SINGLE CommitmentItem AS fipos
  FROM I_GLAccountInCompanyCode
  INTO @l_fipos
  WHERE GLAccount   = @l_konts
    AND CompanyCode = @zmm_mems-bukrs.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
      IF sy-subrc EQ 0.
        MOVE l_fipos TO zmm_mecs-fipos.
        CLEAR l_fipos.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_commitment_number
*&---------------------------------------------------------------------*
*&      Form  GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_delete_itab_data.

  DATA: l_delete TYPE TABLE OF zmm_mecs WITH HEADER LINE.
  DATA: l_ans.

  SELECT SINGLE * FROM zmm_mems WHERE docno = g_docno.

  IF zmm_mems-sflag EQ 'C'.

    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = 'Error'
        textline1 = 'Request cannot be deleted.'
        textline2 = 'The request has been completed'.

    SET SCREEN 9080.

  ELSEIF zmm_mems-sflag EQ 'P'.

    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = 'Error'
        textline1 = 'Request cannot be deleted at this stage.'
        textline2 = 'The request is under process.'.

    SET SCREEN 9080.

  ELSE.

    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        defaultoption = 'Y'
        textline1     = 'Delete the Document'
        textline2     = 'You will lose the Document data'
        titel         = 'Confirmation'
        start_column  = 25
        start_row     = 6
      IMPORTING
        answer        = l_ans.

    IF l_ans EQ 'J'.

      CLEAR : l_delete.

      SELECT * FROM zmm_mecs INTO CORRESPONDING FIELDS OF TABLE
            l_delete  WHERE docno = g_docno.

      IF sy-subrc EQ 0.

        READ TABLE l_delete WITH KEY sflag = 'P'.

        IF sy-subrc NE 0.

          DELETE FROM zmm_mems WHERE docno = g_docno.

          DELETE zmm_mecs FROM TABLE l_delete.

          IF sy-subrc EQ 0.
            MESSAGE s356(zmm).
          ENDIF.
        ELSE.
          MESSAGE s357(zmm).
        ENDIF.

      ENDIF.

    ELSEIF l_ans EQ 'N'.

*     EXIT.

    ENDIF.

    SET SCREEN 9080.

  ENDIF.



ENDFORM.                    " GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  fcode_copy_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
FORM fcode_copy_row USING    p_tc_name
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

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      CLEAR <mark_field>.
      APPEND  <wa> TO <table>. "INDEX syst-tabix.
      CLEAR <mark_field>.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " fcode_copy_row
*&---------------------------------------------------------------------*
*&      Form  confirm_user_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_user_action.

  DATA : ans.

  IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.
    IF NOT ( g_tc_81_itab IS INITIAL ).
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmation '
          diagnose_object       = ' '
          text_question         = 'Do you really want to exit?'
          text_button_1         = 'Yes'
          icon_button_1         = ' '
          text_button_2         = 'No'
          icon_button_2         = ' '
          default_button        = '1'
          display_cancel_button = 'X'
          userdefined_f1_help   = ' '
          start_column          = 25
          start_row             = 6
          popup_type            = 'ICON_MESSAGE_QUESTION'
        IMPORTING
          answer                = ans
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CASE ans.
        WHEN '1'.
          LEAVE TO SCREEN 9080.
      ENDCASE.
    ELSE.
      LEAVE TO SCREEN 9080.
    ENDIF.
  ELSE.
    LEAVE TO SCREEN 9080.
  ENDIF.
ENDFORM.                    " confirm_user_action
*&---------------------------------------------------------------------*
*&      Form  pfstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pfstatus.

  CASE g_ok_80.

    WHEN 'DELETE'.
      CLEAR tab.
      MOVE 'CHANGE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPLAY' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
    WHEN 'CHANGE'.
      CLEAR tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPLAY' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
    WHEN 'DISPLAY'.
      CLEAR tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHANGE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
  ENDCASE.

  SET PF-STATUS 'ZMM03' EXCLUDING tab.

ENDFORM.                    " pfstatus
*&---------------------------------------------------------------------*
*&      Form  delete_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_data_base.
  DELETE zmm_mecs  FROM TABLE ist_del.
ENDFORM.                    " delete_data_base
*&---------------------------------------------------------------------*
*&      Form  get_matnr_desc
*&---------------------------------------------------------------------*
*       FETCH MATERIAL DESC ROUTINE
*----------------------------------------------------------------------*
*      -->P_ZMM_MECS_MATNR  text
*----------------------------------------------------------------------*
FORM get_matnr_desc USING p_matnr.
  CLEAR :wa_makt.

  IF NOT p_matnr IS INITIAL.

    CALL FUNCTION 'MAKT_SINGLE_READ'
      EXPORTING
        matnr      = p_matnr
        spras      = 'E'
      IMPORTING
        wmakt      = wa_makt
      EXCEPTIONS
        wrong_call = 1
        not_found  = 2
        OTHERS     = 3.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_matnr_desc
*&---------------------------------------------------------------------*
*&      Form  validate_matnr
*&---------------------------------------------------------------------*
*       validation of matcode
*----------------------------------------------------------------------*
*      -->P_ZMM_MECS_MATNR  text
*----------------------------------------------------------------------*
FORM validate_matnr USING  matnr
*{   INSERT         OCPK900065                                        1
steuc
*}   INSERT
                    CHANGING remrk.

  CALL FUNCTION 'MARA_READ'
    EXPORTING
      i_matnr  = matnr
    EXCEPTIONS
      no_entry = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    msg_log-msgno = sy-msgno.
    msg_log-msgty = sy-msgty.
    msg_log-msgid = sy-msgid.

    CALL FUNCTION 'MESSAGE_TEXTS_READ'
      EXPORTING
        msg_log_imp  = msg_log
      IMPORTING
        msg_text_exp = msg_text
      EXCEPTIONS
        OTHERS       = 1.

    MOVE msg_text-msgtx TO remrk.
  ELSE.
    CLEAR remrk.
  ENDIF.

*----start of addition rk004 -------*
  IF NOT matnr+0(2) IN r_mat_grp.                           "+rk004
    IF remrk IS INITIAL.
      MOVE TEXT-017 TO remrk.
    ENDIF.
  ELSE.
    CLEAR remrk.
  ENDIF.
*----end of addition rk004 -------*
*{   INSERT         OCPK900065                                        2
**********************************************************************
  DATA: BEGIN OF wa_t604f,
          land1 TYPE land1,
          steuc TYPE steuc,
        END OF wa_t604f.

  SELECT land1 steuc FROM t604f INTO wa_t604f WHERE land1 = 'IN' AND steuc = steuc.
  ENDSELECT.

  IF wa_t604f IS INITIAL.

    MESSAGE ID '00' TYPE 'E' NUMBER '058' WITH steuc '' '' 'T604F'.

  ENDIF.
**********************************************************************
*}   INSERT

ENDFORM.                    " validate_matnr
*&---------------------------------------------------------------------*
*&      Form  get_valid_cocodes
*&---------------------------------------------------------------------*
*       Valid company codes routine
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_valid_cocodes.

  SELECT bukrs butxt FROM t001 INTO TABLE ist_t001 WHERE
                          land1 = 'IN' AND spras = 'E' AND
                          ktopl = 'ONGC' AND bukrs <> 'RNT' .

  DELETE ist_t001 WHERE bukrs = 'JVA'.

ENDFORM.                    " get_valid_cocodes
*&---------------------------------------------------------------------*
*&      Form  EXTEND_MATERIAL
*&---------------------------------------------------------------------*
* Extend Material For Plant
*----------------------------------------------------------------------*
FORM extend_material .
  DATA: zmm_me01_wa       TYPE   zmm_me01.
  DATA: zmm_me02_wa       TYPE   zmm_me02.
  DATA: l_valclass        TYPE   zmm_valclass.
  DATA: t001w         LIKE t001w.
  DATA: l_views(1) TYPE n.

  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: plants TYPE STANDARD TABLE OF marc_werk.
  FIELD-SYMBOLS: <plants> TYPE marc_werk.
  TYPES: BEGIN OF ty_mm01_del,
           matnr LIKE rmmg1-matnr,             "Material Code
           bwtar LIKE rmmg1-bwtar,
         END OF ty_mm01_del.
  DATA: lt_mm01_del TYPE STANDARD TABLE OF ty_mm01_del,
        ls_mm01_del TYPE ty_mm01_del.

  CLEAR g_tc_81_wa.

  REFRESH g_mm01_ist.
  LOOP AT g_tc_81_itab INTO g_tc_81_wa WHERE flag NE 'X'.
    CLEAR:  return, g_mm01_wa, general_data, t001w, g_exist, ls_headdata.
    CALL FUNCTION 'GET_PLANT_DETAILS'
      EXPORTING
        i_werks         = g_tc_81_wa-werks
      IMPORTING
        e_t001w         = t001w
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        OTHERS          = 3.

    IF sy-subrc EQ 0.
      IF g_tc_81_wa-bwtar EQ 'BATCH_MNGD'.
        CLEAR g_tc_81_wa-bwtar.
      ENDIF.
      "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026


      DATA: lv_matnr TYPE bapimatdet-material.
      lv_matnr = g_tc_81_wa-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
        EXPORTING
*         material              = g_tc_81_wa-matnr
          material              = lv_matnr
          plant                 = g_tc_81_wa-werks
          valuationarea         = t001w-bwkey
          valuationtype         = g_tc_81_wa-bwtar
        IMPORTING
          material_general_data = general_data
          return                = return
          materialplantdata     = plantdata
          materialvaluationdata = valuationdata.
      "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
      CASE return-type.
        WHEN 'W'.
          IF return-code EQ 'MM363' OR return-code EQ 'MM361'.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.

          ENDIF.
        WHEN 'E'.
          IF return-code EQ 'M3192'.
            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
            CLEAR:lv_matnr.
            lv_matnr = g_tc_81_wa-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
              EXPORTING
*               MATERIAL              = G_TC_81_WA-MATNR
                material              = lv_matnr
              IMPORTING
                material_general_data = general_data
                return                = return.
            g_all = space.
            g_only_second = space.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.
            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026

          ELSEIF return-code EQ 'M3305'.
*             wa_msg-docno = g_tc_81_wa-docno.            "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-msgv1 = return-message_v1.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.

          ENDIF.

        WHEN 'S'.

          CALL FUNCTION 'MATERIAL_READ_PLANTS'
            EXPORTING
              matnr  = g_tc_81_wa-matnr
            TABLES
              plants = plants.

          READ TABLE plants ASSIGNING <plants> WITH KEY werks = g_tc_81_wa-werks.

          DATA : l_strlen TYPE i.

          l_strlen = strlen( <plants>-pstat ).
*--------start of changes by rk004------------------------------------*

*           IF l_strlen < 6.                               "-rk004
          CLEAR t320.                                       "+rk001
          CLEAR l_views.
          SELECT * FROM t320 UP TO 1 ROWS
 WHERE werks EQ g_tc_81_wa-werks
 ORDER BY PRIMARY KEY .
          ENDSELECT.
          IF sy-subrc IS INITIAL.
            l_views = 7.
          ELSE.
            l_views = 6.
          ENDIF.

          IF l_strlen < l_views.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.
          ENDIF.
      ENDCASE.


      IF ls_headdata IS INITIAL.
        ls_headdata-sales_view = 'X'.
        ls_headdata-purchase_view = 'X'.
        ls_headdata-mrp_view = 'X'.
        ls_headdata-storage_view = 'X'.
        ls_headdata-warehouse_view = 'X'.
        ls_headdata-account_view = 'X'.
        ls_headdata-quality_view = 'X'.
        APPEND ls_headdata TO lt_headdata.

      ENDIF.

      CLEAR g_mm01_wa.
*      G_MM01_WA-DOCNO = G_TC_81_WA-DOCNO.
      g_mm01_wa-matnr = g_tc_81_wa-matnr.  " Material
*{   INSERT         OCPK900065                                        1
      g_mm01_wa-steuc = g_tc_81_wa-steuc.
      g_mm01_wa-taxim = g_tc_81_wa-taxim.
*}   INSERT
      g_mm01_wa-werks = g_tc_81_wa-werks.  " Plant
*----------------------------------------------------------------------*
* Find Sales Organization
*----------------------------------------------------------------------*


      IF t001w-vkorg NE space.
        g_mm01_wa-vkorg = t001w-vkorg.  " Sales org
      ELSE.
        CLEAR zmm_me01_wa.
        SELECT SINGLE * FROM zmm_me01 INTO zmm_me01_wa
                        WHERE werks EQ g_tc_81_wa-werks.
        IF sy-subrc EQ 0.
          IF zmm_me01_wa-vkorg NE space.
            g_mm01_wa-vkorg = zmm_me01_wa-vkorg.  " Sales Org
          ELSE.
*            WA_MSG-DOCNO = NUMBER.
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Sales Org does not exit for plant'
                         g_tc_81_wa-werks INTO wa_msg-msgv1
                         SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.

            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.
        ELSE.
*          WA_MSG-DOCNO = G_TC_81_WA-DOCNO.
          wa_msg-matnr = g_tc_81_wa-matnr.
          wa_msg-msgtyp = 'E'.
          wa_msg-bwtar = g_tc_81_wa-bwtar.
          wa_msg-werks = g_tc_81_wa-werks.
          CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                      'does not exist in table ZMM_ME01'
                      INTO wa_msg-msgv1
                      SEPARATED BY space.
          APPEND wa_msg TO ist_msg.
          CLEAR ls_mm01_del.
          ls_mm01_del-matnr = g_tc_81_wa-matnr.
          ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
          APPEND ls_mm01_del TO lt_mm01_del.
        ENDIF.
      ENDIF.

*----------------------------------------------------------------------*
* Find Warehouse number                                                *
*----------------------------------------------------------------------*
      CLEAR t320.
      SELECT * FROM t320 UP TO 1 ROWS
 WHERE werks EQ g_tc_81_wa-werks
 ORDER BY PRIMARY KEY .
      ENDSELECT.

      IF sy-subrc EQ 0.

        """""""""""""""""""""""""""""""""""""""
        "added  by lipsy
        IF g_tc_81_wa-werks = '61H2' OR g_tc_81_wa-werks = '61A2' OR g_tc_81_wa-werks = '61E2' OR
          g_tc_81_wa-werks = '61B2' OR g_tc_81_wa-werks = '61D2' OR g_tc_81_wa-werks = '61L2' OR g_tc_81_wa-werks = '61W2'.

          t320-lgnum = 'BKO'.

        ENDIF.
        "eadd by lipsy
        """"""""""""""""""""""""""""""""""""""""""""

        g_mm01_wa-lgnum = t320-lgnum.
      ENDIF.
*----------------------------------------------------------------------*
* Get Profit center for plant
*----------------------------------------------------------------------*
      CLEAR zmm_me01_wa.
      SELECT SINGLE * FROM zmm_me01
                      INTO zmm_me01_wa
                      WHERE werks EQ g_tc_81_wa-werks.

      IF sy-subrc EQ 0.
        IF zmm_me01_wa-prctr NE space.
          g_mm01_wa-prctr = zmm_me01_wa-prctr.  " Profit Center
        ELSE.
          wa_msg-matnr = g_tc_81_wa-matnr.
          wa_msg-msgtyp = 'E'.
          wa_msg-bwtar = g_tc_81_wa-bwtar.
          wa_msg-werks = g_tc_81_wa-werks.
          CONCATENATE 'Profit Center does not exit for plant'
                       g_tc_81_wa-werks INTO wa_msg-msgv1
                       SEPARATED BY space.
          APPEND wa_msg TO ist_msg.
          CLEAR ls_mm01_del.
*           g_mm01_del-docno = g_tc_child_wa-docno.          "+rk003
          ls_mm01_del-matnr = g_tc_81_wa-matnr.
          ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
          APPEND ls_mm01_del TO lt_mm01_del.
        ENDIF.
      ELSE.
*        WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.                 "+rk003
        wa_msg-matnr = g_tc_81_wa-matnr.
        wa_msg-msgtyp = 'E'.
        wa_msg-bwtar = g_tc_81_wa-bwtar.
        wa_msg-werks = g_tc_81_wa-werks.
        CONCATENATE 'Entry for plant' g_tc_81_wa-werks
               'does not exist in table ZMM_ME01'  INTO wa_msg-msgv1
                    SEPARATED BY space.
        APPEND wa_msg TO ist_msg.
        CLEAR ls_mm01_del.
*        G_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.             "+rk003
        ls_mm01_del-matnr = g_tc_81_wa-matnr.
        ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
        APPEND ls_mm01_del TO lt_mm01_del.
      ENDIF.

      g_mm01_wa-prodh = general_data-prod_hier.  " Product hier
      g_mm01_wa-mtart = general_data-matl_type.  " Material type

*----------------------------------------------------------------------*
* Find MRP Controller
*----------------------------------------------------------------------*
      CLEAR zmm_me02_wa.
      SELECT * FROM zmm_me02
 INTO zmm_me02_wa UP TO 1 ROWS WHERE werks EQ g_tc_81_wa-werks AND mtart EQ general_data-matl_type
 ORDER BY PRIMARY KEY .
      ENDSELECT.
      IF sy-subrc EQ 0.
        g_mm01_wa-dispo = zmm_me02_wa-dispo.   " MRP Controller
      ELSE.
*         wa_msg-docno = g_tc_child_wa-docno.                "+rk003
        wa_msg-matnr = g_tc_81_wa-matnr.
        wa_msg-msgtyp = 'E'.
        wa_msg-bwtar = g_tc_81_wa-bwtar.
        wa_msg-werks = g_tc_81_wa-werks.
        CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                    'does not exist in table ZMM_ME02'
                    INTO wa_msg-msgv1 SEPARATED BY space.
        APPEND wa_msg TO ist_msg.
        CLEAR ls_mm01_del.
*        G_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.             "+rk003
        ls_mm01_del-matnr = g_tc_81_wa-matnr.
        ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
        APPEND ls_mm01_del TO lt_mm01_del.
      ENDIF.

*----------------------------------------------------------------------*
* Valuation Class
*----------------------------------------------------------------------*
      IF general_data-prod_hier EQ '0C'.
        g_mm01_wa-bwtty = 'X'.
        CLEAR l_valclass.
        SELECT * FROM zmm_valclass
 INTO l_valclass UP TO 1 ROWS WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ space
 ORDER BY PRIMARY KEY .
        ENDSELECT.

        IF sy-subrc EQ 0.
          g_mm01_wa-bklas = l_valclass-val_class.   " Valuation Class
        ELSE.
*          WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.               "+rk003
          wa_msg-matnr = g_tc_81_wa-matnr.
          wa_msg-msgtyp = 'E'.
          wa_msg-bwtar = g_tc_81_wa-bwtar.
          wa_msg-werks = g_tc_81_wa-werks.
          CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                      'does not exist in table ZMM_VALCLASS'
                      INTO wa_msg-msgv1 SEPARATED BY space.
          APPEND wa_msg TO ist_msg.
          CLEAR ls_mm01_del.
*          G_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.           "+rk003
          ls_mm01_del-matnr = g_tc_81_wa-matnr.
          ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
          APPEND ls_mm01_del TO lt_mm01_del.
        ENDIF.
        APPEND g_mm01_wa TO g_mm01_ist.
      ELSE.
        CASE general_data-prod_hier.


          WHEN '01' OR '02' OR '03' OR '04' OR '05' OR '06' OR '07' OR
               '08' OR '09' OR '10' OR '11' OR '12' OR '13' OR '14' OR
               '15' OR '16'.
            g_mm01_wa-bwtty = 'O'.

          WHEN '21' OR '22' OR '23' OR '24' OR '25' OR '26' OR '27' OR
               '28' OR '29' OR '30' OR '31' OR '32' OR '33' OR '34' OR
               '35' OR '36' OR '37' OR '38' OR '39' OR '40' OR '41' OR
               '42'.
            g_mm01_wa-bwtty = 'P'.
        ENDCASE.


        IF g_only_second NE 'X'.


          CLEAR l_valclass.
          SELECT * FROM zmm_valclass INTO l_valclass UP TO 1 ROWS
 WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ space
 ORDER BY PRIMARY KEY .
          ENDSELECT.

          IF sy-subrc EQ 0.
            g_mm01_wa-bklas = l_valclass-val_class.
          ELSE.
*             wa_msg-docno = g_tc_81_wa-docno.            "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                        'does not exist in table ZMM_VALCLASS'
                        INTO wa_msg-msgv1 SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.

          APPEND g_mm01_wa TO g_mm01_ist.  "First line
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
          CLEAR l_valclass.
          SELECT * FROM zmm_valclass INTO l_valclass UP TO 1 ROWS
 WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ g_tc_81_wa-bwtar
 ORDER BY PRIMARY KEY .
          ENDSELECT.

          IF sy-subrc EQ 0.
            g_mm01_wa-bklas = l_valclass-val_class.
          ELSE.
*          WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.               "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                        'does not exist in table ZMM_VALCLASS'
                        INTO wa_msg-msgv1 SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*          LS_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.           "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.

          g_mm01_wa-bwtar = g_tc_81_wa-bwtar.

          APPEND g_mm01_wa TO g_mm01_ist.  " Second Line
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
        ELSE.

          CLEAR l_valclass.

          SELECT * FROM zmm_valclass INTO l_valclass UP TO 1 ROWS
 WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ g_tc_81_wa-bwtar
 ORDER BY PRIMARY KEY .
          ENDSELECT.

          IF sy-subrc EQ 0.
            g_mm01_wa-bklas = l_valclass-val_class.
          ELSE.
*          WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.               "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                        'does not exist in table ZMM_VALCLASS'
                        INTO wa_msg-msgv1 SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*          LS_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.           "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.

          g_mm01_wa-bwtar = g_tc_81_wa-bwtar.
          APPEND g_mm01_wa TO g_mm01_ist.  " Only second line
        ENDIF.
      ENDIF.
      CLEAR: g_all, g_only_second, g_tc_81_wa, plants.
      REFRESH plants.
    ELSE.

    ENDIF.
  ENDLOOP.




*----------------------------------------------------------------------*
* Sort and delete the del in-table
*----------------------------------------------------------------------*
  SORT lt_mm01_del.
  DELETE ADJACENT DUPLICATES FROM lt_mm01_del.

  CLEAR ls_mm01_del.
  LOOP AT lt_mm01_del INTO ls_mm01_del.
    DELETE g_mm01_ist WHERE matnr EQ ls_mm01_del-matnr
                     AND bwtar EQ ls_mm01_del-bwtar.

    IF sy-subrc EQ 0.
*      WA_MSG-DOCNO = G_MM01_DEL-DOCNO.                      "+rk003
      wa_msg-matnr = ls_mm01_del-matnr.
      wa_msg-msgtyp = 'I'.
      wa_msg-bwtar = ls_mm01_del-bwtar.
      CONCATENATE 'Material' ls_mm01_del-matnr ',' ls_mm01_del-bwtar
                 'is deleted from the extension list.'
                  INTO wa_msg-msgv1 SEPARATED BY space.
      APPEND wa_msg TO ist_msg.
      " End of <RD1K960036>.
    ENDIF.
    CLEAR ls_mm01_del.

  ENDLOOP.

  SORT ist_msg.
  DELETE ADJACENT DUPLICATES FROM ist_msg.

ENDFORM.                    " EXTEND_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_material .
  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: plants TYPE TABLE OF marc_werk WITH HEADER LINE.
  DATA: l_views(1) TYPE n.
  DATA: l_mstae LIKE mara-mstae.
  DATA: l_mtstb LIKE t141t-mtstb.

  CLEAR ist_msg[].
  LOOP AT g_tc_81_itab INTO g_tc_81_wa.
    CLEAR :l_mstae, l_mtstb.
    SELECT SINGLE mstae FROM mara INTO l_mstae WHERE
                                      matnr = g_tc_81_wa-matnr.
    IF NOT l_mstae IS INITIAL.
      SELECT SINGLE mtstb FROM t141t INTO l_mtstb WHERE
                                     mmsta = l_mstae AND
                                     spras = 'E'.
*      MOVE NUMBER TO WA_MSG-DOCNO.
      MOVE g_tc_81_wa-matnr TO wa_msg-matnr.
      MOVE g_tc_81_wa-bwtar TO wa_msg-bwtar.
      MOVE 'E' TO wa_msg-msgtyp.
      MOVE g_tc_81_wa-werks TO wa_msg-werks.
      CONCATENATE 'Material' wa_msg-matnr 'BLOCKED,' l_mtstb INTO
                             wa_msg-msgv1 SEPARATED BY space.
      APPEND wa_msg TO ist_msg.
      CONTINUE.
    ENDIF.
    CALL FUNCTION 'GET_PLANT_DETAILS'
      EXPORTING
        i_werks         = g_tc_81_wa-werks
      IMPORTING
        e_t001w         = t001w
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        OTHERS          = 3.

    IF sy-subrc EQ 0.

      IF g_tc_81_wa-bwtar EQ 'BATCH_MNGD'.
        CLEAR g_tc_81_wa-bwtar.
      ENDIF.
      DATA: lv_matnr TYPE bapimatdet-material.
      lv_matnr = g_tc_81_wa-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
        EXPORTING
*         material              = g_tc_81_wa-matnr
          material              = lv_matnr
          plant                 = g_tc_81_wa-werks
          valuationarea         = t001w-bwkey
          valuationtype         = g_tc_81_wa-bwtar
        IMPORTING
          material_general_data = general_data
          return                = return
          materialplantdata     = plantdata
          materialvaluationdata = valuationdata.

      IF return-type EQ 'S'.

        CALL FUNCTION 'MATERIAL_READ_PLANTS'
          EXPORTING
            matnr  = g_tc_81_wa-matnr
          TABLES
            plants = plants.


        READ TABLE plants WITH KEY werks = g_tc_81_wa-werks
                                   matnr = g_tc_81_wa-matnr.

        IF sy-subrc EQ 0.
          DATA : l_strlen TYPE i.
          l_strlen = strlen( plants-pstat ).

          CLEAR t320.
          CLEAR l_views.
          SELECT SINGLE * FROM t320 WHERE werks EQ g_tc_81_wa-werks.
          IF sy-subrc IS INITIAL.
            l_views = 7.
          ELSE.
            l_views = 6.
          ENDIF.

          IF l_strlen = l_views.

*            MOVE NUMBER TO WA_MSG-DOCNO.
            MOVE g_tc_81_wa-matnr TO wa_msg-matnr.
            IF general_data-matl_type EQ 'ZCAP'.
              g_tc_81_wa-bwtar = 'BATCH_MNGD'.
            ENDIF.
            MOVE g_tc_81_wa-bwtar TO wa_msg-bwtar.
*             MOVE 'E'                 TO wa_msg-msgtyp.
            MOVE 'W'                 TO wa_msg-msgtyp.
            MOVE g_tc_81_wa-werks TO wa_msg-werks.
            CONCATENATE 'Valuation type' g_tc_81_wa-bwtar
                        'for material' g_tc_81_wa-matnr
                        'and plant' g_tc_81_wa-werks
                        'already maintained.' INTO wa_msg-msgv1
                         SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR wa_msg-msgv1.
          ENDIF.
          CLEAR l_strlen.
        ENDIF.
      ENDIF.

    ENDIF.
    CLEAR: t001w, g_tc_81_wa, general_data, return.
    CLEAR plants.
  ENDLOOP.

  IF ist_msg IS INITIAL.
    g_check_flag = 'X'.
  ELSE.
    LOOP AT ist_msg INTO wa_msg.
      IF wa_msg-msgtyp = 'E' OR wa_msg-msgtyp = 'W' .
        READ TABLE g_tc_81_itab INTO g_tc_81_wa WITH KEY
*                                          DOCNO = WA_MSG-DOCNO
                                          matnr = wa_msg-matnr
                                          werks = wa_msg-werks
                                          bwtar = wa_msg-bwtar.
        IF sy-subrc IS INITIAL.
*          DELETE G_TC_81_ITAB INDEX SY-TABIX.
          MOVE wa_msg-msgv1 TO g_tc_81_wa-remrk.
          MOVE 'X' TO g_tc_81_wa-flag.
        ENDIF.
      ENDIF.
    ENDLOOP.
    g_check_flag = 'X'.
  ENDIF.
ENDFORM.                    " CHECK_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  EXTEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM extend .
  DATA: ls_rmmg1              TYPE rmmg1,
        ls_mvke               TYPE mvke,
        ls_marc               TYPE marc,
*{   INSERT         OCPK900065                                        2
        ls_TAXCLASSIFICATIONS TYPE bapi_mlan,
*}   INSERT
        ls_mbew               TYPE mbew,
        return2               TYPE bapiret2.
  DATA: t_plant TYPE STANDARD TABLE OF marc_werk.
  DATA: lv_mtart TYPE mara-mtart,
        lv_bwtar TYPE rmmg1-bwtar.

  FIELD-SYMBOLS: <wa_plant> TYPE marc_werk.


*  DATA: T_RETURN TYPE STANDARD TABLE OF BAPIRET2.
  FIELD-SYMBOLS: <g_mm01_wa>   TYPE t_mm01,
                 <ls_headdata> TYPE bapimathead.

  DATA: g_mm01_tmp TYPE STANDARD TABLE OF t_mm01.
  FIELD-SYMBOLS <g_mm01_tmp> TYPE t_mm01.
  DATA lv_prevmatnr TYPE mara-matnr.

  DATA lv_head TYPE bapimathead.
  DATA: lv_syuname TYPE sy-uname.
  DATA: lv_str(50) TYPE c.
*  SORT G_MM01_IST BY MATNR.

*  LOOP AT G_MM01_IST ASSIGNING <G_MM01_WA>.
*    IF <G_MM01_WA>-BWTAR IS NOT INITIAL.
*       APPEND <G_MM01_WA> TO G_MM01_TMP.
*       DELETE TABLE G_MM01_IST FROM <G_MM01_WA>.
*     ENDIF.
*  ENDLOOP.
*APPEND LINES OF G_MM01_TMP TO G_MM01_IST.

*  LOOP AT G_MM01_TMP ASSIGNING <G_MM01_TMP>.
*    APPEND <G_MM01_TMP> TO G_MM01_IST.
*  ENDLOOP.

  lv_syuname = sy-uname.
  SORT lt_headdata BY material.

  SELECT SINGLE * FROM agr_users INTO w_agr_users WHERE uname = lv_syuname.
  w_agr_users-agr_name = 'D:MM_BAPI_MATEXTN_RUN'.
  w_agr_users-from_dat = sy-datum - 1.
  w_agr_users-to_dat = sy-datum + 1.
  PERFORM update_agrname ON COMMIT.
  PERFORM commit_rollback.

  sy-uname = 'ROLE_ASN_USR'.
****Start of changes for message 403030
*  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFS'
*      EXPORTING
*        ACTIVITY_GROUP             = 'D:MM_BAPI_MATEXTN_RUN'
*        DISPLAY_MESSAGES           = SPACE
*        AUTHORITY_CHECK            = SPACE
**        CHANGING
**          return_tab                 = it_return_tab
*      EXCEPTIONS
*        AUTHORITY_INCOMPLETE       = 1
*        AT_LEAST_ONE_USER_ENQUEUED = 2
*        NO_PROFILES_AVAILABLE      = 3
*        TOO_MANY_PROFILES_IN_USER  = 4
*        OTHERS                     = 5.
  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFC'
    EXPORTING
      activity_group                = 'D:MM_BAPI_MATEXTN_RUN'
      display_messages              = space
      collective_role               = Space
*     DB_UPDATE                     = 'X'
* IMPORTING
*     MESSAGES                      =
* TABLES
*     PROCESSED_SINGLE_ROLES        =
*     SGLS_IN_COLL                  =
* CHANGING
*     RETURN_TAB                    =
    EXCEPTIONS
      no_authority_for_user_compare = 1
      authority_incomplete          = 2
      child_agr_enqueued            = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

****End of changes for message 403030
  COMMIT WORK.
  sy-uname = lv_syuname.
  CLEAR: w_agr_users.

  """"""""""""""""""
  ""added by lipsy on 20.08.2015  RD1K998283

  IF zmm_mems-lgnum IS NOT INITIAL.
    REFRESH:G_MM01_sec[].
    CLEAR:G_MM01_sec[].
    G_MM01_sec[] = g_mm01_ist[].
    CLEAR g_mm01_wa.
    LOOP AT G_MM01_sec ASSIGNING <g_mm01_wa>.
      <g_mm01_wa>-lgnum = zmm_mems-lgnum.
      APPEND   <g_mm01_wa> TO G_MM01_ist.
      CLEAR g_mm01_wa.
    ENDLOOP.
    CLEAR g_mm01_wa.
  ENDIF.
  ""end of addition by lipsy on 20.08.2015  RD1K998283
  """"""""""""""""""""""

  LOOP AT g_mm01_ist ASSIGNING <g_mm01_wa>.
    ls_rmmg1-matnr = <g_mm01_wa>-matnr.
    ls_rmmg1-werks = <g_mm01_wa>-werks.
    ls_rmmg1-bwtar = <g_mm01_wa>-bwtar.
    ls_rmmg1-lgnum = <g_mm01_wa>-lgnum.
    ls_rmmg1-vkorg = <g_mm01_wa>-vkorg.
    ls_rmmg1-mtart = <g_mm01_wa>-mtart.
    ls_mvke-prodh  = <g_mm01_wa>-prodh.
*{   INSERT         OCPK900065                                        1
    ls_marc-steuc = <g_mm01_wa>-steuc.
    ls_TAXCLASSIFICATIONS-depcountry = 'IN'.
    ls_TAXCLASSIFICATIONS-tax_ind = <g_mm01_wa>-taxim.
*}   INSERT
    ls_marc-prctr  = <g_mm01_wa>-prctr.
    ls_marc-dispo  = <g_mm01_wa>-dispo.
    ls_mbew-bwtty  = <g_mm01_wa>-bwtty.
    ls_mbew-bklas  = <g_mm01_wa>-bklas.
*{   INSERT         OCDK902682                                        7

    IF fcode EQ 'UPD'.
      SELECT bklas
   INTO ls_mbew-bklas FROM mbew UP TO 1 ROWS WHERE matnr = ls_rmmg1-matnr
   ORDER BY PRIMARY KEY .
      ENDSELECT.
    ENDIF.
*}   INSERT

    READ TABLE lt_headdata ASSIGNING <ls_headdata>
    WITH KEY material  = <g_mm01_wa>-matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'ZMM_MATERIAL_EXTEND'
        EXPORTING
          ls_rmmg1              = ls_rmmg1
          ls_mathead            = <ls_headdata>
          ls_mvke               = ls_mvke
          ls_marc               = ls_marc
*{   INSERT         OCPK900065                                        3
          ls_TAXCLASSIFICATIONS = ls_taxclassifications
*}   INSERT
          ls_mbew               = ls_mbew
        IMPORTING
          return                = return2
        TABLES
          returnmessages        = returnmessages.
    ELSE.
      lv_head-material = <g_mm01_wa>-matnr.
      lv_head-matl_type = <g_mm01_wa>-mtart.
      lv_head-sales_view = 'X'.
      lv_head-purchase_view = 'X'.
      lv_head-mrp_view = 'X'.
      lv_head-storage_view = 'X'.
      lv_head-warehouse_view = 'X'.
      lv_head-account_view = 'X'.
      lv_head-quality_view = 'X'.

      CALL FUNCTION 'ZMM_MATERIAL_EXTEND'
        EXPORTING
          ls_rmmg1              = ls_rmmg1
          ls_mathead            = lv_head
          ls_mvke               = ls_mvke
*{   INSERT         OCPK900065                                        4
          ls_TAXCLASSIFICATIONS = ls_taxclassifications
*}   INSERT
          ls_marc               = ls_marc
          ls_mbew               = ls_mbew
        IMPORTING
          return                = return2
        TABLES
          returnmessages        = returnmessages.
    ENDIF.


*    LV_PREVMATNR = LS_RMMG1-MATNR.

    MOVE <g_mm01_wa>-bwtar TO lv_bwtar.
    SELECT SINGLE mtart FROM mara INTO (lv_mtart) WHERE matnr = <g_mm01_wa>-matnr.
    IF lv_mtart EQ 'ZCAP'.
      MOVE 'BATCH_MNGD' TO lv_bwtar.
    ENDIF.
    CASE return2-type.
      WHEN 'S'.
*{   INSERT         OCPK900065                                        5
        IF g_ok_80 EQ 'UPDATE'.
          CLEAR:  ls_zmm_mecs.
          SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                WHERE docno = number
                  AND matnr = <g_mm01_wa>-matnr
                  AND werks = <g_mm01_wa>-werks
                  AND bwtar = lv_bwtar.
          IF ls_zmm_mecs IS NOT INITIAL.
            ls_zmm_mecs-steuc =  ls_marc-steuc.
            ls_zmm_mecs-taxim = ls_TAXCLASSIFICATIONS-tax_ind.

            MODIFY zmm_mecs FROM ls_zmm_mecs.

            CONCATENATE 'Material' <g_mm01_wa>-matnr 'extended' INTO
           ls_zmm_mecs-remrk SEPARATED BY space.


            APPEND ls_zmm_mecs TO lt_zmm_mecs.

            MOVE number TO wa_msg-docno.
            MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
            MOVE <g_mm01_wa>-werks TO wa_msg-werks.
            MOVE lv_bwtar TO wa_msg-bwtar.
            MOVE return2-type TO wa_msg-msgtyp.
            MOVE ls_zmm_mecs-remrk TO wa_msg-msgv1.
          ENDIF.
*break-point.
*          READ TABLE    G_TC_81_ITAB INTO G_TC_81_wa with KEY MATNR =  WA_MSG-MATNR.
*          IF sy-subrc eq 0.
*              G_TC_81_wa-REMRK = WA_MSG-MSGV1.
*              modify G_TC_81_ITAB from G_TC_81_wa.
*          ENDIF.

        ELSE.



*}   INSERT
          IF lv_bwtar IS NOT INITIAL.
            SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                   WHERE docno = number
                     AND matnr = <g_mm01_wa>-matnr
                     AND werks = <g_mm01_wa>-werks
                     AND bwtar = lv_bwtar.
            CALL FUNCTION 'MATERIAL_READ_PLANTS'
              EXPORTING
                matnr  = <g_mm01_wa>-matnr
              TABLES
                plants = t_plant.

            READ TABLE t_plant ASSIGNING <wa_plant> WITH KEY matnr = <g_mm01_wa>-matnr
                                       werks = <g_mm01_wa>-werks.

            IF sy-subrc EQ 0.
              MOVE <wa_plant>-pstat TO ls_zmm_mecs-pstat.
            ENDIF.
            MOVE 'C' TO ls_zmm_mecs-sflag.
            CONCATENATE 'Material' <g_mm01_wa>-matnr 'extended' INTO
               ls_zmm_mecs-remrk SEPARATED BY space.
            APPEND ls_zmm_mecs TO lt_zmm_mecs.
            MOVE number TO wa_msg-docno.
            MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
            MOVE <g_mm01_wa>-werks TO wa_msg-werks.
            MOVE lv_bwtar TO wa_msg-bwtar.
            MOVE return2-type TO wa_msg-msgtyp.
            MOVE ls_zmm_mecs-remrk TO wa_msg-msgv1.

          ENDIF.
*{   INSERT         OCPK900065                                        6



        ENDIF.
*}   INSERT
      WHEN 'E'.
        IF lv_bwtar IS NOT INITIAL.
          SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                WHERE docno = number
                  AND matnr = <g_mm01_wa>-matnr
                  AND werks = <g_mm01_wa>-werks
                  AND bwtar = lv_bwtar.
          CONCATENATE '(' return2-message ')' INTO lv_str.
          CONCATENATE <g_mm01_wa>-matnr 'not extended' lv_str INTO ls_zmm_mecs-remrk SEPARATED BY space.  "#EC CI_FLDEXT_OK[2215424]
          CLEAR: lv_str.
          APPEND ls_zmm_mecs TO lt_zmm_mecs.
          MOVE number TO wa_msg-docno.
          MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
          MOVE <g_mm01_wa>-werks TO wa_msg-werks.
          MOVE lv_bwtar TO wa_msg-bwtar.
          MOVE return2-type TO wa_msg-msgtyp.
          MOVE return2-message TO wa_msg-msgv1.
        ENDIF.

      WHEN OTHERS.
        IF lv_bwtar IS NOT INITIAL.
          SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                   WHERE docno = number
                     AND matnr = <g_mm01_wa>-matnr
                     AND werks = <g_mm01_wa>-werks
                     AND bwtar = lv_bwtar.
          MOVE return2-message TO ls_zmm_mecs-remrk.
          APPEND ls_zmm_mecs TO lt_zmm_mecs.
          MOVE number TO wa_msg-docno.
          MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
          MOVE <g_mm01_wa>-werks TO wa_msg-werks.
          MOVE lv_bwtar TO wa_msg-bwtar.
          MOVE return2-type TO wa_msg-msgtyp.
          MOVE return2-message TO wa_msg-msgv1.
        ENDIF.
    ENDCASE.
    IF wa_msg IS NOT INITIAL.
      APPEND wa_msg TO ist_msg.
    ENDIF.

    IF returnmessages[] IS NOT INITIAL.
      READ TABLE returnmessages INTO wa_mesg INDEX 1.
      MOVE wa_mesg-type TO wa_msg-msgtyp.
      MOVE wa_mesg-message TO wa_msg-msgv1.
      APPEND wa_msg TO ist_msg.
    ENDIF.


    CLEAR: ls_zmm_mecs, ls_zmm_mems, wa_msg, lv_bwtar, lv_mtart, return2, wa_mesg, returnmessages[].
  ENDLOOP.

  SELECT SINGLE * FROM agr_users INTO w_agr_users WHERE agr_name = 'D:MM_BAPI_MATEXTN_RUN'
  AND uname = lv_syuname.
  PERFORM update_agr ON COMMIT.
  PERFORM commit_rollback.

  sy-uname = 'ROLE_ASN_USR'.
****Start of changes for message 403030
*  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFS'
*      EXPORTING
*        ACTIVITY_GROUP             = 'D:MM_BAPI_MATEXTN_RUN'
*        DISPLAY_MESSAGES           = SPACE
*        AUTHORITY_CHECK            = SPACE
**        CHANGING
**          return_tab                 = it_return_tab
*      EXCEPTIONS
*        AUTHORITY_INCOMPLETE       = 1
*        AT_LEAST_ONE_USER_ENQUEUED = 2
*        NO_PROFILES_AVAILABLE      = 3
*        TOO_MANY_PROFILES_IN_USER  = 4
*        OTHERS                     = 5.
  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFC'
    EXPORTING
      activity_group                = 'D:MM_BAPI_MATEXTN_RUN'
      display_messages              = space
      collective_role               = Space
*     DB_UPDATE                     = 'X'
* IMPORTING
*     MESSAGES                      =
* TABLES
*     PROCESSED_SINGLE_ROLES        =
*     SGLS_IN_COLL                  =
* CHANGING
*     RETURN_TAB                    =
    EXCEPTIONS
      no_authority_for_user_compare = 1
      authority_incomplete          = 2
      child_agr_enqueued            = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
****End of changes for message 403030

  COMMIT WORK.

  sy-uname = lv_syuname.

  SORT ist_msg BY matnr.
*  DELETE ADJACENT DUPLICATES FROM IST_MSG COMPARING MATNR.

  PERFORM update_zmm_mecs ON COMMIT.
  PERFORM commit_rollback.
  PERFORM update_zmm_mems ON COMMIT.
  PERFORM commit_rollback.

ENDFORM.                    " EXTEND
*&---------------------------------------------------------------------*
*&      Form  VIEW_TO_EXTEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC_81_WA_MATNR  text
*      -->P_G_TC_81_WA_WERKS  text
*----------------------------------------------------------------------*
FORM view_to_extend  USING    p_g_tc_81_wa_matnr
                              p_g_tc_81_wa_werks.
  DATA: l_pstat(7).
  DATA: plants TYPE STANDARD TABLE OF marc_werk.
  FIELD-SYMBOLS <plants> TYPE marc_werk.
*  DATA: LV_MTART TYPE MARA-MTART.
*   clear p_only_second.
  SELECT SINGLE mtart INTO (ls_headdata-matl_type) FROM mara WHERE matnr = p_g_tc_81_wa_matnr.
  ls_headdata-material = p_g_tc_81_wa_matnr.

  CALL FUNCTION 'MATERIAL_READ_PLANTS'
    EXPORTING
      matnr  = p_g_tc_81_wa_matnr
    TABLES
      plants = plants.

  READ TABLE plants ASSIGNING <plants> WITH KEY werks = p_g_tc_81_wa_werks.
  IF sy-subrc EQ 0.
*    IF <PLANTS>-WERKS  = '90R1'.
**    CLEAR L_PSTAT.
**      LS_HEADDATA-SALES_VIEW = 'X'.
*      LS_HEADDATA-PURCHASE_VIEW = 'X'.
*      LS_HEADDATA-MRP_VIEW = 'X'.
*      LS_HEADDATA-STORAGE_VIEW = 'X'.
**      LS_HEADDATA-WAREHOUSE_VIEW = 'X'.
*      LS_HEADDATA-ACCOUNT_VIEW = 'X'.
*      LS_HEADDATA-QUALITY_VIEW = 'X'.
*    ELSEIF  <PLANTS>-WERKS  NE '90R1'. .

    CASE <plants>-pstat.

      WHEN 'VEDLSQB'.
        ls_headdata-sales_view = 'X'.
        ls_headdata-purchase_view = 'X'.
        ls_headdata-mrp_view = 'X'.
        ls_headdata-storage_view = 'X'.
        ls_headdata-warehouse_view = 'X'.
        ls_headdata-account_view = 'X'.
        ls_headdata-quality_view = 'X'.
        g_only_second = 'X'.
      WHEN 'DELBSVQ'.
        ls_headdata-sales_view = 'X'.
        ls_headdata-purchase_view = 'X'.
        ls_headdata-mrp_view = 'X'.
        ls_headdata-storage_view = 'X'.
        ls_headdata-warehouse_view = 'X'.
        ls_headdata-account_view = 'X'.
        ls_headdata-quality_view = 'X'.
        g_only_second = 'X'.
      WHEN OTHERS.
        SEARCH <plants>-pstat FOR 'V'.
        IF sy-subrc EQ 0.
          ls_headdata-sales_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'E'.
        IF sy-subrc EQ 0.
          ls_headdata-purchase_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'D'.
        IF sy-subrc EQ 0.
          ls_headdata-mrp_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'L'.
        IF sy-subrc EQ 0.
          ls_headdata-storage_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'S'.
        IF sy-subrc EQ 0.
          ls_headdata-warehouse_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'B'.
        IF sy-subrc EQ 0.
          ls_headdata-account_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'Q'.
        IF sy-subrc EQ 0.
          ls_headdata-quality_view = 'X'.
        ENDIF.

    ENDCASE.
*      IF <PLANTS>-PSTAT NE 'VEDLSQB'.
**        DELBSVQ
*        SEARCH <PLANTS>-PSTAT FOR 'V'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-SALES_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'E'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-PURCHASE_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'D'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-MRP_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'L'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-STORAGE_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'S'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-WAREHOUSE_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'B'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-ACCOUNT_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'Q'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-QUALITY_VIEW = 'X'.
*        ENDIF.
*      ELSEIF <PLANTS>-PSTAT EQ 'VEDLSQB'.
*        LS_HEADDATA-SALES_VIEW = 'X'.
*        LS_HEADDATA-PURCHASE_VIEW = 'X'.
*        LS_HEADDATA-MRP_VIEW = 'X'.
*        LS_HEADDATA-STORAGE_VIEW = 'X'.
*        LS_HEADDATA-WAREHOUSE_VIEW = 'X'.
*        LS_HEADDATA-ACCOUNT_VIEW = 'X'.
*        LS_HEADDATA-QUALITY_VIEW = 'X'.
*        G_ONLY_SECOND = 'X'.
*      ENDIF.
*    ENDIF.
  ELSE.
    ls_headdata-sales_view = 'X'.
    ls_headdata-purchase_view = 'X'.
    ls_headdata-mrp_view = 'X'.
    ls_headdata-storage_view = 'X'.
    ls_headdata-warehouse_view = 'X'.
    ls_headdata-account_view = 'X'.
    ls_headdata-quality_view = 'X'.
  ENDIF.

  IF p_g_tc_81_wa_werks = '90R1'.
    ls_headdata-sales_view = ' '.
    ls_headdata-warehouse_view = ' '.
  ENDIF.
  APPEND ls_headdata TO lt_headdata.
ENDFORM.                    " VIEW_TO_EXTEND
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_MECS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_mecs .
  SORT lt_zmm_mecs BY docno matnr.
*  DELETE ADJACENT DUPLICATES FROM LT_ZMM_MECS COMPARING DOCNO MATNR.
  DELETE lt_zmm_mecs WHERE bwtar = ' '.
  IF lt_zmm_mecs[] IS NOT INITIAL.
    MODIFY zmm_mecs FROM TABLE lt_zmm_mecs.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_MECS
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_MEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_mems .
  DATA: lt_mecs TYPE STANDARD TABLE OF zmm_mecs.
  FIELD-SYMBOLS    <wa_mecs> TYPE zmm_mecs.
  DATA: flag(1) TYPE c.
  SELECT SINGLE * FROM zmm_mems INTO ls_zmm_mems
                 WHERE docno = number.
  IF sy-subrc EQ 0.
    SELECT * FROM zmm_mecs INTO TABLE lt_mecs WHERE docno = number.
    IF sy-subrc EQ 0.
      LOOP AT lt_mecs ASSIGNING <wa_mecs>.
        IF <wa_mecs>-sflag = 'N'.
          flag = 'X'.
        ENDIF.
      ENDLOOP.
      IF flag EQ 'X'.
        MOVE 'N' TO ls_zmm_mems-sflag.
      ELSE.
        MOVE 'C' TO ls_zmm_mems-sflag.
      ENDIF.

      MODIFY zmm_mems FROM ls_zmm_mems.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_MEMS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_mesg .
  PERFORM field_catalog.
  PERFORM show_list.

*  LEAVE TO LIST-PROCESSING.
*  LOOP AT IST_MSG INTO WA_MSG.
*    WRITE:/ WA_MSG.
*  ENDLOOP.

ENDFORM.                    " DISPLAY_MESG
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-fieldname = 'DOCNO'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-001.
  wa_fieldcat-key       = 'X'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-002.
  wa_fieldcat-key       = 'X'.
  wa_fieldcat-outputlen = 13.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-003.
  wa_fieldcat-key       = 'X'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-fieldname = 'MSGTYP'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-004.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-fieldname = 'BWTAR'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-005.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-fieldname = 'MSGV1'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-006.
  wa_fieldcat-outputlen = 75.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  SHOW_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_list .
  DATA ltmecs TYPE STANDARD TABLE OF zmm_mecs.
  FIELD-SYMBOLS <ltmecs> TYPE zmm_mecs.
  v_repid = sy-repid.

  DATA: ltmsg TYPE STANDARD TABLE OF t_msg,
        wamsg TYPE t_msg.
*  LOOP AT G_TC_81_ITAB INTO G_TC_81_WA.
*    READ TABLE IST_MSG INTO WA_MSG WITH KEY DOCNO = NUMBER
*                                            MATNR = G_TC_81_WA-MATNR.
*    IF SY-SUBRC EQ 0.
*     MOVE WA_MSG TO WAMSG.
*     APPEND WAMSG TO LTMSG.
*     ENDIF.
*     DELETE TABLE IST_MSG FROM WA_MSG.
*     CLEAR: WA_MSG, WAMSG.
*  ENDLOOP.
*
*  DELETE IST_MSG WHERE DOCNO NE ' '.
*  LOOP AT IST_MSG INTO WA_MSG.
*    APPEND WA_MSG TO LTMSG.
*  ENDLOOP.
*  CLEAR IST_MSG[].

  IF ist_msg IS INITIAL.
    SELECT * FROM zmm_mecs INTO TABLE ltmecs
      FOR ALL ENTRIES IN g_tc_81_itab
           WHERE matnr = g_tc_81_itab-matnr
             AND werks = g_tc_81_itab-werks
             AND bwtar = g_tc_81_itab-bwtar.
    LOOP AT ltmecs ASSIGNING <ltmecs>.
      MOVE <ltmecs>-docno TO wa_msg-docno.
      MOVE <ltmecs>-matnr TO wa_msg-matnr.
      MOVE <ltmecs>-werks TO wa_msg-werks.
      MOVE <ltmecs>-bwtar TO wa_msg-bwtar.
      MOVE <ltmecs>-remrk TO wa_msg-msgv1.
      APPEND wa_msg TO ist_msg.
      CLEAR wa_msg.
    ENDLOOP.
  ENDIF.
  LEAVE TO LIST-PROCESSING.

  DELETE ist_msg WHERE matnr = ' '.
  LOOP AT ltmsg INTO wamsg.
    APPEND wamsg TO ist_msg.
  ENDLOOP.

  SORT ist_msg BY matnr.
*  DELETE ADJACENT DUPLICATES FROM IST_MSG COMPARING MATNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = v_repid
      i_grid_title       = TEXT-007
      it_fieldcat        = id_fieldcat
    TABLES
      t_outtab           = ist_msg.

  CLEAR id_fieldcat[].
  CLEAR ist_msg[].
ENDFORM.                    " SHOW_LIST
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AGRNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_agrname .
  INSERT agr_users FROM w_agr_users.
ENDFORM.                    " UPDATE_AGRNAME
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_agr .
  DELETE agr_users FROM w_agr_users.
ENDFORM.                    " UPDATE_AGR

*--- INCLUDE: MZMMMERI01 ---*
***INCLUDE MZMMMERI01 .

*---------------------------------------------------------------------*
*       MODULE TC_81_modify INPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE TC_81_MODIFY INPUT.

  PERFORM GET_COMMITMENT_NUMBER.

  PERFORM VALIDATE_RECORDS.

  IF NOT ( ZMM_MECS IS INITIAL ).
    ZMM_MECS-DISMM = 'ND'.
  ENDIF.

  MOVE-CORRESPONDING ZMM_MECS TO G_TC_81_WA.

  MODIFY G_TC_81_ITAB  FROM G_TC_81_WA  INDEX TC_81-CURRENT_LINE.

  IF SY-SUBRC NE 0.
    APPEND G_TC_81_WA TO G_TC_81_ITAB.
  ENDIF.

  DELETE G_TC_81_ITAB  WHERE MATNR EQ SPACE.

ENDMODULE.                    "tc_81_modify INPUT

*---------------------------------------------------------------------*
*       MODULE TC_81_mark INPUT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE TC_81_MARK INPUT.
  IF TC_81-LINE_SEL_MODE = 1 AND
     G_TC_81_WA-FLAG = 'X'.
    LOOP AT G_TC_81_ITAB INTO G_TC_81_WA WHERE FLAG = 'X'.
      G_TC_81_WA-FLAG = ''.
      MODIFY G_TC_81_ITAB FROM G_TC_81_WA TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_81_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_81_ITAB FROM G_TC_81_WA INDEX TC_81-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "tc_81_mark INPUT

*---------------------------------------------------------------------*
*       MODULE TC_81_user_command INPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE TC_81_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_81'
                              'G_TC_81_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "tc_81_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  REFRESH G_TC_81_ITAB.
  CLEAR G_TC_81_WA.
  CLEAR G_TC_81_COPIED.

  IF SY-DYNNR EQ 9080.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO  SCREEN 9080.
  ENDIF.
ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9081  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9081 INPUT.
  G_OK_81 = SY-UCOMM.
  CASE G_OK_81.
    WHEN 'SAVE'.
      PERFORM SAVE_9081.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.
    WHEN 'LIST'.
     PERFORM DISPLAY_MESG.

  ENDCASE.


    ENDMODULE.                 " USER_COMMAND_9081  INPUT
*{   INSERT         OCPK900087                                        1
MODULE USER_COMMAND_9083 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.
    WHEN 'UPDATE'.
      PERFORM SAVE_9081.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.
    WHEN 'LIST'.
     PERFORM DISPLAY_MESG.
     when 'HSNUPD'.

FLG = 0.

       perform check_data.

       IF flg eq 0.

          clear: gv_req.
          select max( Req_no )
            INTO gv_req
            from zmm_hsn_upd.


            gv_req = gv_req + 1.

             clear:wa_zmm_hsn_upd.
            wa_zmm_hsn_upd-MANDT = sy-mandt.
            wa_zmm_hsn_upd-REQ_NO = gv_req.
            wa_zmm_hsn_upd-CREATED_BY = sy-uname.

            wa_zmm_hsn_upd-CREATED_ON = sy-datum.
            wa_zmm_hsn_upd-COMPANY_CODE = ZMM_MEMS-BUKRS.
            wa_zmm_hsn_upd-REQ_ST = 0.

                 insert INTO zmm_hsn_upd values wa_zmm_hsn_upd.


                 LOOP AT G_TC_81_ITAB INTO G_TC_81_WA.

                   clear: wa_zmm_hsn_upd_itm.

                   wa_zmm_hsn_upd_itm-MANDT = sy-mandt.

                   wa_zmm_hsn_upd_itm-REQ_NO = gv_req.
                   wa_zmm_hsn_upd_itm-MATNR = G_TC_81_WA-MATNR.
                   wa_zmm_hsn_upd_itm-WERKS = G_TC_81_WA-WERKS.
                   wa_zmm_hsn_upd_itm-TAXIM = G_TC_81_WA-TAXIM.
                   wa_zmm_hsn_upd_itm-STEUC = G_TC_81_WA-STEUC.

                   Insert into zmm_hsn_upd_itm values wa_zmm_hsn_upd_itm.


                 ENDLOOP.

                 clear: gv_msg.


                 CONCATENATE 'Request no.'  gv_req 'created' INTO gv_msg SEPARATED BY space.

                 message gv_msg TYPE 'I'.

                 clear: g_tc_81_itab,g_tc_81_wa.





       ENDIF.

*       LOOP AT G_TC_81_ITAB INTO G_TC_81_WA.
*
*         clear: wa_marc.
*         select single *
*           INTO  wa_marc
*           from marc
*           where matnr = G_TC_81_WA-MATNR and
*                  werks = g_tc_81_wa-WERKS.
*           IF wa_marc is NOT INITIAL.
*
*             wa_marc-STEUC = G_TC_81_WA-STEUC.
*
*           modify marc from wa_marc.
*           G_TC_81_WA-REMRK = 'HSN Updated'.
*
*           G_TC_81_WA-FLAG = '1'.
*
*           else.
*
*           G_TC_81_WA-REMRK = 'Material not found in plant'.
*
*           ENDIF.
*
*           modify g_tc_81_itab from g_tc_81_wa.
*
*
*       ENDLOOP.



  ENDCASE.


    ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9080  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9080 INPUT.
  G_OK_80 = SY-UCOMM.
  CASE G_OK_80.
    WHEN 'CREATE'.
      PERFORM ASSIGN_SY_VALUES.
      FCODE = 'SAVE'.
      LEAVE TO SCREEN 9081.
    WHEN 'CHANGE'.
      LEAVE TO SCREEN 9082.
    WHEN 'DISPLAY'.
      LEAVE TO SCREEN 9082.
    WHEN 'DELETE'.
      LEAVE TO SCREEN 9082.
*{   REPLACE        OCPK900087                                        1
*\    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
       WHEN 'UPDATE'.
          AUTHORITY-CHECK OBJECT 'ZMM_MATEXT'
          ID 'ACTVT' FIELD '02'.
         IF sy-subrc eq 0.
           PERFORM ASSIGN_SY_VALUES.
      FCODE = 'UPD'.

      LEAVE TO SCREEN 9084.


      else.
        MESSAGE 'You are not authorized' TYPE 'S'.

         ENDIF.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL' OR 'BCK'.
*}   REPLACE
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9080  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9082  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9082 INPUT.

  IF G_OK_80 = 'DISPLAY' AND ZMM_MEMS-DOCNO <> ' '.
    SY-UCOMM = 'DISPLAY'.
  ENDIF.

  G_OK_82 = SY-UCOMM.

  CASE G_OK_82.
    WHEN 'CHANGE' OR 'DISPLAY'.
      PERFORM GET_ITAB_DATA.
      FCODE = 'SAVE'.
      LEAVE SCREEN.
    WHEN 'DELETE'.
      PERFORM GET_DELETE_ITAB_DATA.
      LEAVE SCREEN.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 9080.
      LEAVE SCREEN.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_9082  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_USER INPUT.
  IF G_OK_80 EQ 'CHANGE' OR G_OK_80 EQ  'DELETE'.
    PERFORM CHECK_USER.
  ENDIF.
  G_DOCNO = ZMM_MEMS-DOCNO.
ENDMODULE.                 " check_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VALUE_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_VALUE_TYPE INPUT.

  DATA L_SELLINE  LIKE SY-STEPL.
  DATA: DYNPRO_VALUES TYPE TABLE OF DYNPREAD.
  DATA: FIELD_VALUE LIKE LINE OF DYNPRO_VALUES.
  DATA: L_VALUE(2) TYPE C.


  GET CURSOR LINE L_SELLINE.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'SAPMZMMMER'
        DYNUMB     = '9081'
        REQUEST    = 'A'
      TABLES
        DYNPFIELDS = DYNPRO_VALUES.

    DELETE DYNPRO_VALUES WHERE FIELDNAME NE 'ZMM_MECS-MATNR'.
    READ TABLE DYNPRO_VALUES INDEX L_SELLINE INTO FIELD_VALUE.

  ENDIF.

  L_VALUE = FIELD_VALUE-FIELDVALUE+0(2).

  REFRESH BWTAR.

  CASE L_VALUE.
    WHEN '01' OR '02' OR '03' OR '04' OR '05' OR '06' OR '07' OR '08' OR
            '09' OR '10' OR '11' OR '12' OR '13' OR '14' OR '15' OR '16'
                                         OR '17' OR '18' OR '19' OR '20'.
      SELECT DISTINCT BWTAR FROM T149D
                            INTO CORRESPONDING FIELDS OF TABLE BWTAR
*                            WHERE bwtar LIKE 'STI%'.          "-RK006
                            WHERE BWTAR LIKE 'ST%'.         "+RK006

    WHEN '21' OR '22' OR '23' OR '24' OR '25' OR '26' OR '27' OR '28' OR
         '29' OR '30' OR '31' OR '32' OR '33' OR '34' OR '35' OR '36' OR
                            '37' OR '38' OR '39' OR '40' OR '41' OR '42'.
      SELECT DISTINCT BWTAR FROM T149D
                            INTO CORRESPONDING FIELDS OF TABLE BWTAR
*                            WHERE bwtar LIKE 'SPI%' .          "-RK006
                            WHERE BWTAR LIKE 'SP%' .        "+RK006

    WHEN  '0C'.
      REFRESH BWTAR.
      CLEAR WA_BWTAR.
      WA_BWTAR-BWTAR = 'BATCH_MNGD'.
      APPEND WA_BWTAR TO BWTAR.
  ENDCASE.

*{+rk007
  DELETE BWTAR WHERE BWTAR = 'SP-LSTK-LF'.
  DELETE BWTAR WHERE BWTAR = 'ST-LSTK-LF'.
*}+rk007
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'BWTAR'
      DYNPPROG    = SY-REPID
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'ZMM_MECS-BWTAR'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = BWTAR.


ENDMODULE.                 " GET_VALUE_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matnr  INPUT
*&---------------------------------------------------------------------*
*       check material validity routine
*----------------------------------------------------------------------*
MODULE CHECK_MATNR INPUT.

*  perform validate_matnr using zmm_mecs-matnr
*                         changing zmm_mecs-remrk.           "+rk004

ENDMODULE.                 " check_matnr  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_ranges  INPUT
*&---------------------------------------------------------------------*
*       material number code check  rk004
*----------------------------------------------------------------------*
MODULE INIT_RANGES INPUT.

  R_MAT_GRP-SIGN = 'I'.
  R_MAT_GRP-OPTION = 'BT'.
  R_MAT_GRP-LOW = '01'.
  R_MAT_GRP-HIGH = '42'.
  APPEND R_MAT_GRP.

ENDMODULE.                 " init_ranges  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cocode  INPUT
*&---------------------------------------------------------------------*
*       valid company codes   rk004
*----------------------------------------------------------------------*
MODULE GET_COCODE INPUT.

  PERFORM GET_VALID_COCODES.

  IF NOT IST_T001[] IS INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'BUKRS'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = IST_T001
        RETURN_TAB      = IST_RETURN_TAB
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.



    ZMM_MEMS-BUKRS = IST_RETURN_TAB-FIELDVAL.


  ENDIF.
ENDMODULE.                 " get_cocode  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_cocode  INPUT
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
MODULE VALIDATE_COCODE INPUT.

  IF NOT ZMM_MEMS-BUKRS IS INITIAL.
    IF IST_T001[] IS INITIAL.
      PERFORM GET_VALID_COCODES.
    ENDIF.
    READ TABLE IST_T001 WITH KEY BUKRS = ZMM_MEMS-BUKRS.
    IF SY-SUBRC <> 0.
      MESSAGE E431(ZMM).
    ELSE.
      G_BUTXT = IST_T001-BUTXT.
    ENDIF.
  ENDIF.
ENDMODULE.                 " validate_cocode  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_werks  INPUT
*&---------------------------------------------------------------------*
*       Plant 12F3 is merged into 13F3
*----------------------------------------------------------------------*
MODULE CHECK_WERKS INPUT.

  IF ZMM_MECS-WERKS = '12F3'.
    MESSAGE E824(ZMM) WITH ZMM_MECS-WERKS '13F3'.
  ENDIF.

ENDMODULE.                 " check_werks  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_bwtar  INPUT
*&---------------------------------------------------------------------*
*       validate valuation type
*----------------------------------------------------------------------*
MODULE CHECK_BWTAR INPUT.

  IF ZMM_MECS-BWTAR = 'SP-LSTK-LF' OR
     ZMM_MECS-BWTAR = 'ST-LSTK-LF'.
    MESSAGE E199(ZMM) WITH TC_81-CURRENT_LINE.
  ENDIF.
ENDMODULE.                 " check_bwtar  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_WAREHOUSE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_warehouse INPUT.

refresh:Itab_T320[].

   SELECT lgnum FROM T320 INTO CORRESPONDING FIELDS OF TABLE
   Itab_T320 .

     sort  Itab_T320 by lgnum DESCENDING.
     DELETE ADJACENT DUPLICATES FROM Itab_T320 COMPARING lgnum.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'BUKRS'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = ITab_T320
        RETURN_TAB      = IST_RETURN_TAB
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    ZMM_MEMS-lgnum = IST_RETURN_TAB-FIELDVAL.

ENDMODULE.                 " GET_WAREHOUSE  INPUT
*{   INSERT         OCDK902852                                        1
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .


  flg = 0.


sort  G_TC_81_ITAB   by matnr werks.

delete ADJACENT DUPLICATES FROM  G_TC_81_ITAB  COMPARING matnr werks.

LOOP AT G_TC_81_ITAB INTO G_TC_81_WA.

CLEAR: gv_steuc.
SELEct single steuc
  INTO gv_steuc
  from t604f
  where steuc = G_TC_81_WA-STEUC.

  IF gv_steuc IS INITIAL.

    clear: gv_msg.
    flg = 1.

    CONCATENATE 'HSN Code' G_TC_81_WA-STEUC 'not present in T604F' INTO gv_msg SEPARATED BY space.

    MESSAGE gv_msg TYPE 'S'.
    exit.


  ENDIF.


  clear: gv_req1.
  SELECT REQ_NO
 INTO GV_REQ1 FROM ZMM_HSN_UPD_ITM UP TO 1 ROWS WHERE MATNR = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF gv_req1 IS   NOT INITIAL.

    clear: req_st.
      select single req_no
        INTO req_st
        from zmm_hsn_upd
        where req_no = gv_req1.

        IF req_st eq '0'.

          flg = 1.
          clear: gv_msg.
          CONCATENATE 'Request ' gv_req 'already present for mat'   g_tc_81_wa-matnr   into gv_msg SEPARATED BY space.
          message gv_msg TYPE 'I'.

          exit.

        ENDIF.

    ENDIF.

  CLEAR: gv_TAXIM.
SELEct single TAXIM
  INTO gv_TAXIM
  from TMKM1
  where TAXIM = G_TC_81_WA-TAXIM.

  IF gv_TAXIM IS INITIAL.

    clear: gv_msg.
    flg = 1.

    CONCATENATE 'Tax Ind ' G_TC_81_WA-TAXIM 'not present in TMKM1 ' INTO gv_msg SEPARATED BY space.

    MESSAGE gv_msg TYPE 'S'.
    exit.


  ENDIF.

  IF G_TC_81_WA-STEUC IS INITIAL.
      clear: gv_msg.
    flg = 1.

    CONCATENATE 'Please enter HSN code of ' G_TC_81_WA-MATNR  INTO gv_msg SEPARATED BY space.

    MESSAGE gv_msg TYPE 'S'.
    exit.

  ENDIF.

  IF G_TC_81_WA-TAXIM IS INITIAL.
      clear: gv_msg.
    flg = 1.

    CONCATENATE 'Please enter Tax Ind. of ' G_TC_81_WA-MATNR  INTO gv_msg SEPARATED BY space.

    MESSAGE gv_msg TYPE 'S'.
    exit.

  ENDIF.


ENDLOOP.






ENDFORM.
*}   INSERT

*{   INSERT         OCDK902852                                        2
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

clear: wa_zmm_hsn_upd,wa_zmm_hsn_upd_itm, it_zmm_hsn_upd_itm.


  select SINGLE *
    INTO wa_zmm_hsn_upd
    FROM zmm_hsn_upd
    where req_no = DOCNO_A.


   IF wa_zmm_hsn_upd IS INITIAL.

     message 'No records found' type 'S'.

   else.

      select *
        INTO CORRESPONDING FIELDS OF TABLE it_zmm_hsn_upd_itm

        from zmm_hsn_upd_itm
        where req_no = DOCNO_A.


        ZMM_MEMS-ERSDA = wa_zmm_hsn_upd-CREATED_on.
        ZMM_MEMS-ERNAM = wa_zmm_hsn_upd-CREATED_BY.

clear:  g_tc_81_itab.
        LOOP AT  it_zmm_hsn_upd_itm into wa_zmm_hsn_upd_itm.
              G_TC_81_WA-MATNR = wa_zmm_hsn_upd_itm-MATNR.
              G_TC_81_WA-werks = wa_zmm_hsn_upd_itm-werks.
              G_TC_81_WA-steuc = wa_zmm_hsn_upd_itm-steuc.
              G_TC_81_WA-taxim = wa_zmm_hsn_upd_itm-taxim.


                 append G_TC_81_WA to g_tc_81_itab.




        ENDLOOP.




   ENDIF.



ENDFORM.

FORM GET_DATAC .

clear: wa_zmm_hsn_upd,wa_zmm_hsn_upd_itm, it_zmm_hsn_upd_itm.


  select SINGLE *
    INTO wa_zmm_hsn_upd
    FROM zmm_hsn_upd
    where req_no = DOCNO_C.


   IF wa_zmm_hsn_upd IS INITIAL.

     message 'No records found' type 'S'.

   else.

      select *
        INTO CORRESPONDING FIELDS OF TABLE it_zmm_hsn_upd_itm

        from zmm_hsn_upd_itm
        where req_no = DOCNO_C.


        ZMM_MEMS-ERSDA = wa_zmm_hsn_upd-CREATED_on.
        ZMM_MEMS-ERNAM = wa_zmm_hsn_upd-CREATED_BY.

clear:  g_tc_81_itab.
        LOOP AT  it_zmm_hsn_upd_itm into wa_zmm_hsn_upd_itm.
              G_TC_81_WA-MATNR = wa_zmm_hsn_upd_itm-MATNR.
              G_TC_81_WA-werks = wa_zmm_hsn_upd_itm-werks.
              G_TC_81_WA-steuc = wa_zmm_hsn_upd_itm-steuc.
              G_TC_81_WA-taxim = wa_zmm_hsn_upd_itm-taxim.


                 append G_TC_81_WA to g_tc_81_itab.




        ENDLOOP.




   ENDIF.



ENDFORM.
*}   INSERT

*--- INCLUDE: MZMMMERO01 ---*
***INCLUDE MZMMMERO01 .

*---------------------------------------------------------------------*
*       MODULE TC_81_init OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.
*{   INSERT         OCPK900087                                        1
MODULE tc_83_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9083'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.
*}   INSERT
*{   INSERT         OCDK902852                                        2
MODULE tc_85_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9085'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.

MODULE status_9085 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014.
ENDMODULE.

MODULE tc_86_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9086'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.

MODULE status_9086 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014.
ENDMODULE.
*}   INSERT

*---------------------------------------------------------------------*
*       MODULE TC_81_move OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_move OUTPUT.

*{   INSERT         OCPK900087                                        1
IF g_tc_81_wa-MATNR is NOT INITIAL.

  clear: g_tc_81_wa-steuc.
  SELECT
 STEUC INTO G_TC_81_WA-STEUC FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     clear: g_tc_81_wa-taxim.
  SELECT
 TAXIM INTO G_TC_81_WA-TAXIM FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

ENDIF.
*}   INSERT

  MOVE-CORRESPONDING g_tc_81_wa TO zmm_mecs.

  IF g_ok_82 NE 'DISPLAY'.
    IF NOT ( zmm_mecs-remrk IS INITIAL ).
      CALL FUNCTION 'ICON_CREATE'
           EXPORTING
                name   = 'ICON_LED_RED'
           IMPORTING
                result = icon.
    ENDIF.
  ENDIF.

  MOVE g_lines TO tc_lines.

  IF NOT ( g_tc_81_wa IS INITIAL ).
    MOVE tc_81-current_line TO tc_81_line.
  ENDIF.

ENDMODULE.
*{   INSERT         OCPK900087                                        1
MODULE tc_83_move OUTPUT.

*{   INSERT         OCPK900087                                        1
IF g_tc_81_wa-MATNR is NOT INITIAL.

IF g_tc_81_wa-steuc IS INITIAL.
 SELECT
 STEUC INTO G_TC_81_WA-STEUC FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

ENDIF.


IF g_tc_81_wa-taxim IS INITIAL.
 SELECT
 TAXIM INTO G_TC_81_WA-TAXIM FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.
ENDIF.



ENDIF.
*}   INSERT

  MOVE-CORRESPONDING g_tc_81_wa TO zmm_mecs.

  IF g_ok_82 NE 'DISPLAY'.
    IF NOT ( zmm_mecs-remrk IS INITIAL ).
      CALL FUNCTION 'ICON_CREATE'
           EXPORTING
                name   = 'ICON_LED_RED'
           IMPORTING
                result = icon.
    ENDIF.
  ENDIF.

  MOVE g_lines TO tc_lines.

  IF NOT ( g_tc_81_wa IS INITIAL ).
    MOVE tc_81-current_line TO tc_81_line.
  ENDIF.

ENDMODULE.
*}   INSERT

*---------------------------------------------------------------------*
*       MODULE TC_81_get_lines OUTPUT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_get_lines OUTPUT.
  g_tc_81_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9081  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9081 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9081  OUTPUT
*{   INSERT         OCDK902852                                        1
MODULE status_9083 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014 .
ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9080 OUTPUT.
*{   INSERT         OCPK900087                                        1
 SET PF-STATUS 'ZMM01_1'.
*}   INSERT
*{   DELETE         OCPK900087                                        2
*\  SET PF-STATUS 'ZMM01' .
*}   DELETE
  SET TITLEBAR '001' WITH text-014 text-015.
ENDMODULE.                 " STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9082  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9082 OUTPUT.
  PERFORM pfstatus.
*  SET PF-STATUS 'ZMM03' .
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9082  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_81_attr OUTPUT.

  CASE g_ok_80.

    WHEN 'CREATE' OR 'CHANGE'.

      LOOP AT tc_81-cols INTO htc_cols.
        IF htc_cols-screen-group1 EQ 'INV'.
          htc_cols-invisible = 'X'.
        ELSEIF htc_cols-screen-group1 EQ 'CHN'.
          htc_cols-screen-input = 1.
          htc_cols-screen-active = 1.
        ENDIF.
        MODIFY tc_81-cols FROM htc_cols.

      ENDLOOP.

    WHEN 'DISPLAY'.

      LOOP AT tc_81-cols INTO htc_cols.
        htc_cols-screen-input = 0.
        MODIFY tc_81-cols FROM htc_cols.
      ENDLOOP.
      LOOP AT SCREEN.
        IF SCREEN-group3 = 'GR3'.
          SCREEN-INPUT = 1.
        ELSE.
        screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

  ENDCASE.

ENDMODULE.                 " tc_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_line_items  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_line_items OUTPUT.
  CLEAR g_lines.
  DESCRIBE TABLE g_tc_81_itab LINES g_lines.
ENDMODULE.                 " get_line_items  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE refresh_itabs OUTPUT.
  REFRESH g_tc_81_itab.
  CLEAR  g_docno .
  REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
  clear r_mat_grp.
  refresh r_mat_grp.
ENDMODULE.                 " refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  srn_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE srn_81_attr OUTPUT.

  IF g_ok_80 EQ 'CHANGE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-BUKRS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        2
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.

  IF g_ok_80 EQ 'CREATE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-DOCNO'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        1
        LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
  IF g_ok_80 EQ 'DISPLAY'.
    LOOP AT SCREEN.
      IF screen-group2 = 'VIW'.
        screen-invisible = 1.
      ELSEIF SCREEN-GROUP3 = 'GR3'.
        screen-input = 1.
       ELSE.
         SCREEN-INPUT = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
*{   INSERT         OCPK900087                                        3
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
*{   INSERT         OCPK900087                                        4
IF ZMM_MECS-MATNR is NOT INITIAL.

*  select SINGLE  steuc
*    INTO zmm_mecs-steuc
*    FROM



ENDIF.
*}   INSERT


ENDMODULE.                 " srn_81_attr  OUTPUT
*{   INSERT         OCPK900087                                        1
MODULE srn_83_attr OUTPUT.

  IF g_ok_80 EQ 'CHANGE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-BUKRS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        2
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.

  IF g_ok_80 EQ 'CREATE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-DOCNO'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        1
        LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
  IF g_ok_80 EQ 'DISPLAY'.
    LOOP AT SCREEN.
      IF screen-group2 = 'VIW'.
        screen-invisible = 1.
      ELSEIF SCREEN-GROUP3 = 'GR3'.
        screen-input = 1.
       ELSE.
         SCREEN-INPUT = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
*{   INSERT         OCPK900087                                        3
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
*{   INSERT         OCPK900087                                        4
IF ZMM_MECS-MATNR is NOT INITIAL.

*  select SINGLE  steuc
*    INTO zmm_mecs-steuc
*    FROM



ENDIF.
*}   INSERT


ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  move_docno  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_docno OUTPUT.
  MOVE g_docno TO zmm_mems-docno.
ENDMODULE.                 " move_docno  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_req_flds  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_req_flds OUTPUT.
Perform get_matnr_desc using g_tc_81_wa-matnr.
loop at screen.
 if screen-group2 EQ 'REQ' and wa_makt-maktx <> ' ' and
    screen-required = '0'.
  screen-required = '1'.
  modify screen.
  exit.
 endif.
endloop.

ENDMODULE.                 " set_req_flds  OUTPUT
*{   INSERT         OCDK902852                                        1
MODULE status_9084 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.

MODULE USER_COMMAND_9084 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.

    WHEN 'BTNC'.

      AUTHORITY-CHECK OBJECT 'ZMM_HSNURQ'
    ID 'ZHSNUPD' FIELD '01'.

      IF SY-SUBRC ne 0.

        MESSAGE 'You are not authorized' TYPE 'S'.

        else.
          LEAVE TO SCREEN 9083.

      ENDIF.



      WHEN 'BTNE'.
        AUTHORITY-CHECK OBJECT 'ZMM_HSNURQ'
    ID 'ZHSNUPD' FIELD '02'.

      IF SY-SUBRC NE 0.

        MESSAGE 'You are not authorized' TYPE 'S'.

        else.
          LEAVE TO SCREEN 9086.

      ENDIF.




    WHEN 'BTNA'.

      AUTHORITY-CHECK OBJECT 'ZMM_HSNURQ'
    ID 'ZHSNUPD' FIELD '03'.

      IF SY-SUBRC NE 0.

        MESSAGE 'You are not authorized' TYPE 'S'.

        else.
          LEAVE TO SCREEN 9085.

      ENDIF.




       WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.


  ENDCASE.


ENDMODULE.

MODULE USER_COMMAND_9085 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.



       WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.

      when 'APPGET'.

        perform get_data.

        when 'HSNUPD'.

       CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_A.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                        WA_ZMM_HSN_UPD-req_st = '1'.

                        WA_ZMM_HSN_UPD-RELEASED_BY = sy-uname.
                        WA_ZMM_HSN_UPD-RELEASED_ON = sy-datum.
               modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.


                  LOOP AT  G_TC_81_ITAB INTO G_TC_81_WA.
                        clear: wa_marc.

                        select SINGLE *
                          INTO wa_marc
                          from marc
                          where matnr = G_TC_81_WA-MATNR AND
                                werks = G_TC_81_WA-WERKS.

                          IF wa_marc IS NOT INITIAL.
                                    wa_marc-STEUC = G_TC_81_WA-STEUC.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
* S/4 (note 2206980): direct MARC update -> BAPI_MATERIAL_SAVEDATA (STEUC -> PLANTDATA-CTRL_CODE)
*                                    modify marc from wa_marc.
                            DATA: ls_head_m1 TYPE bapimathead, ls_marc_m1 TYPE bapi_marc,
                                  ls_marcx_m1 TYPE bapi_marcx, ls_ret_m1 TYPE bapiret2,
                                  lv_mtart_m1 TYPE mara-mtart, lv_mbrsh_m1 TYPE mara-mbrsh.
                            SELECT SINGLE mtart, mbrsh FROM mara INTO (@lv_mtart_m1, @lv_mbrsh_m1) WHERE matnr = @G_TC_81_WA-MATNR.
                            CLEAR: ls_head_m1, ls_marc_m1, ls_marcx_m1, ls_ret_m1.
                            ls_head_m1-material_long = G_TC_81_WA-MATNR.
                            ls_head_m1-ind_sector    = lv_mbrsh_m1.
                            ls_head_m1-matl_type     = lv_mtart_m1.
                            ls_marc_m1-plant     = G_TC_81_WA-WERKS.
                            ls_marc_m1-ctrl_code = G_TC_81_WA-STEUC.
                            ls_marcx_m1-plant     = G_TC_81_WA-WERKS.
                            ls_marcx_m1-ctrl_code = 'X'.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
                            CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'  "#EC CI_USAGE_OK[2438131]
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
                              EXPORTING headdata = ls_head_m1 plantdata = ls_marc_m1 plantdatax = ls_marcx_m1
                              IMPORTING return = ls_ret_m1.
                            IF ls_ret_m1-type CA 'EA'.
                              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                            ELSE.
                              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
                            ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC

                          ENDIF.



                          clear: wa_mlan, gv_COUNC.

                          select single  counc
                            INTO GV_COUNC
                            from t001w
                            where werks = G_TC_81_WA-WERKS .

                          select SINGLE *
                          INTO wa_mlan
                          from mlan
                          where matnr = G_TC_81_WA-MATNR AND
                                ALAND = gv_counc.

                          IF wa_mlan IS NOT INITIAL.
                                    wa_mlan-TAXIM = G_TC_81_WA-TAXIM.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
* S/4 (note 2206980): direct MLAN update -> BAPI_MATERIAL_SAVEDATA (TAXIM -> TAXCLASSIFICATIONS-TAX_IND, DEPCOUNTRY=ALAND)
*                                    modify mlan from wa_mlan.
                            DATA: ls_head_m2 TYPE bapimathead, ls_ret_m2 TYPE bapiret2,
                                  lt_tax_m2 TYPE STANDARD TABLE OF bapi_mlan, ls_tax_m2 TYPE bapi_mlan,
                                  lv_mtart_m2 TYPE mara-mtart, lv_mbrsh_m2 TYPE mara-mbrsh.
                            SELECT SINGLE mtart, mbrsh FROM mara INTO (@lv_mtart_m2, @lv_mbrsh_m2) WHERE matnr = @G_TC_81_WA-MATNR.
                            CLEAR: ls_head_m2, ls_ret_m2, ls_tax_m2. REFRESH lt_tax_m2.
                            ls_head_m2-material_long = G_TC_81_WA-MATNR.
                            ls_head_m2-ind_sector    = lv_mbrsh_m2.
                            ls_head_m2-matl_type     = lv_mtart_m2.
                            ls_tax_m2-depcountry = gv_counc.
                            ls_tax_m2-tax_ind    = G_TC_81_WA-TAXIM.
                            APPEND ls_tax_m2 TO lt_tax_m2.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
                            CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'  "#EC CI_USAGE_OK[2438131]
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
                              EXPORTING headdata = ls_head_m2
                              IMPORTING return = ls_ret_m2
                              TABLES taxclassifications = lt_tax_m2.
                            IF ls_ret_m2-type CA 'EA'.
                              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                            ELSE.
                              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
                            ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC

                          ENDIF.





                  ENDLOOP.

               MESSAGE 'Request has been approved' TYPE  'S'.

               CLEAR: DOCNO_A, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                  ENDIF.


           ENDIF.

        when 'HSNREJ'.


        CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_A.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                        WA_ZMM_HSN_UPD-req_st = '2'.

                         WA_ZMM_HSN_UPD-RELEASED_BY = sy-uname.
                        WA_ZMM_HSN_UPD-RELEASED_ON = sy-datum.
               modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.

               MESSAGE 'Request has been rejected' TYPE  'S'.

               CLEAR: DOCNO_A, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                  ENDIF.


           ENDIF.


  ENDCASE.


ENDMODULE.

MODULE USER_COMMAND_9086 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.



       WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.

      when 'CHGGET'.

        perform get_dataC.


        when 'HSNSAV'.

       CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_C.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                            FLG = 0.

                            perform check_data.



                            IF FLG EQ 0.

                              WA_ZMM_HSN_UPD-CHANGED_by = sy-uname.
                              WA_ZMM_HSN_UPD-CHANGED_ON = sy-datum.

                              modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.

                              clear: it_zmm_hsn_upd_itm, wa_zmm_hsn_upd_itm.

                              delete from  zmm_hsn_upd_itm where  req_no = docno_c.

                               sort g_tc_81_itab by matnr werks.
                                delete ADJACENT DUPLICATES FROM g_tc_81_itab.

                                 LOOP AT  G_TC_81_ITAB INTO G_TC_81_WA.

                        clear: wa_zmm_hsn_upd_itm.

                        wa_zmm_hsn_upd_itm-mandt = sy-mandt.
                        wa_zmm_hsn_upd_itm-req_no = docno_c.
                        wa_zmm_hsn_upd_itm-matnr = g_tc_81_wa-matnr.
                        wa_zmm_hsn_upd_itm-werks = g_tc_81_wa-werks.
                        wa_zmm_hsn_upd_itm-steuc = g_tc_81_wa-steuc.
                        wa_zmm_hsn_upd_itm-taxim = g_tc_81_wa-taxim.
                       insert into zmm_hsn_upd_itm values wa_zmm_hsn_upd_itm.

                  ENDLOOP.

               MESSAGE 'Request has been saved' TYPE  'S'.

               CLEAR: DOCNO_C, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                            ENDIF.


















                  ENDIF.


           ENDIF.

        when 'HSNREJ'.


        CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_A.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                        WA_ZMM_HSN_UPD-req_st = '2'.

                         WA_ZMM_HSN_UPD-RELEASED_BY = sy-uname.
                        WA_ZMM_HSN_UPD-RELEASED_ON = sy-datum.
               modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.

               MESSAGE 'Request has been rejected' TYPE  'S'.

               CLEAR: DOCNO_A, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                  ENDIF.


           ENDIF.


  ENDCASE.


ENDMODULE.
*}   INSERT

*--- INCLUDE: MZMMMERTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMMERTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMMER MESSAGE-ID ZMM.

TABLES: ZMM_MEMS, ZMM_MECS, MARA, T001W, T149D, T001K, T141T, FMFPO,
T320,MSG_LOG, MSG_TEXT.

TYPES: BEGIN OF T_TC_81,
         MATNR LIKE ZMM_MECS-MATNR,
         WERKS LIKE ZMM_MECS-WERKS,
         BWTAR LIKE ZMM_MECS-BWTAR,
         DISMM LIKE ZMM_MECS-DISMM,
         PSTAT LIKE ZMM_MECS-PSTAT,
         SFLAG LIKE ZMM_MECS-SFLAG,
         ERSDA LIKE ZMM_MECS-ERSDA,
         ERNAM LIKE ZMM_MECS-ERNAM,
         LAEDA LIKE ZMM_MECS-LAEDA,
         AENAM LIKE ZMM_MECS-AENAM,
         REMRK LIKE ZMM_MECS-REMRK,
         FIPOS LIKE ZMM_MECS-FIPOS,
         FLAG,
*{   INSERT         OCPK900065                                        1
*******************Modified for HSN***********************************
  STEUC LIKE ZMM_MECS-STEUC,
  TAXIM LIKE ZMM_MECS-TAXIM,
**********************************************************************
*}   INSERT
       END OF T_TC_81.

CONTROLS: TC_81 TYPE TABLEVIEW USING SCREEN 9081.

DATA:     G_TC_81_ITAB   TYPE T_TC_81 OCCURS 0,
          G_TC_81_WA     TYPE T_TC_81.

DATA:     G_TC_81_COPIED.
DATA:     G_TC_81_LINES    LIKE SY-LOOPC.
DATA:     OK_CODE          LIKE SY-UCOMM.

DATA:     G_OK_80          LIKE SY-UCOMM.
DATA:     G_OK_81          LIKE SY-UCOMM.
DATA:     G_OK_82          LIKE SY-UCOMM.

DATA:     G_LINES          LIKE SY-LOOPC.
DATA:     G_DOCNO          LIKE ZMM_MEMS-DOCNO.

DATA: HTC_COLS TYPE CXTAB_COLUMN.

DATA: FCODE LIKE RSMPE-FUNC.
DATA: TC_81_LINE(3) TYPE C.
DATA: TC_LINES LIKE SY-LOOPC.

DATA: RC        LIKE INRI-RETURNCODE,
      NUMBER(7) TYPE C.

DATA: IST_ZMM_MECS TYPE TABLE OF ZMM_MECS.
DATA: WA_ZMM_MECS TYPE ZMM_MECS.

DATA:  CT_SORT  TYPE  LVC_T_SORT.
DATA:  IT_FIELDCAT TYPE	LVC_T_FCAT.
DATA:  WA_IT TYPE LVC_S_FCAT.

DATA:  IT_SELECTED_COLS TYPE  LVC_T_COL.
DATA:  IS_LAYOUT         TYPE LVC_S_LAYO.
DATA:  IS_SELFIELD         TYPE LVC_S_SELF.
DATA:  IT_GROUPS         TYPE LVC_T_SGRP.
DATA:  CT_FILTER         TYPE LVC_T_FILT.

DATA: BEGIN OF TEMP OCCURS 0,
      REMRK TYPE ZMM_MEMS-REMRK,
      END OF TEMP.

TYPES: BEGIN OF T_BWTAR,
       BWTAR TYPE BWTAR_D,
       END OF T_BWTAR.

DATA: BWTAR TYPE TABLE OF T_BWTAR.
DATA: WA_BWTAR TYPE T_BWTAR.

TYPES: BEGIN OF TAB_TYPE,
        FCODE LIKE RSMPE-FUNC,
      END OF TAB_TYPE.

DATA: ICON  LIKE ICONS-TEXT.

DATA: TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      WA_TAB TYPE TAB_TYPE.

DATA : IST_DEL TYPE TABLE OF ZMM_MECS WITH HEADER LINE.

DATA : WA_MAKT LIKE MAKT.                                   "+rk002

*-------start of add by rk004 ----------------------------*
DATA : G_NUM(2).
DATA : G_BUTXT LIKE T001-BUTXT.
RANGES : R_MAT_GRP FOR G_NUM.

DATA IST_RETURN_TAB  LIKE STANDARD TABLE OF DDSHRETVAL WITH  HEADER
                                              LINE.
DATA  : BEGIN OF IST_T001 OCCURS 0 ,
          BUKRS LIKE T001-BUKRS,
          BUTXT LIKE T001-BUTXT,
        END OF IST_T001.
*-------end of add by rk004 ----------------------------*

TYPES:  BEGIN OF T_MSG,
         DOCNO LIKE ZMM_MEMS-DOCNO,
         MATNR  LIKE MARA-MATNR,
         WERKS  LIKE MARC-WERKS,
         MSGTYP LIKE BDCMSGCOLL-MSGTYP,
         BWTAR  LIKE RMMG1-BWTAR,
         MSGV1  LIKE BDCMSGCOLL-MSGV1,
       END OF T_MSG.
TYPES : BEGIN OF T_MM01,
          DOCNO LIKE ZMM_MEMS-DOCNO,                        "+rk003
          MATNR LIKE RMMG1-MATNR, "Material Code
          WERKS LIKE RMMG1-WERKS, "Plant
          BWTAR LIKE RMMG1-BWTAR, "Valuation Type
          LGNUM LIKE RMMG1-LGNUM, "Warehouse number
          VKORG LIKE RMMG1-VKORG, "Sales Org
          PRODH LIKE MVKE-PRODH,  "Product hierarchy
          MTART LIKE RMMG1-MTART, "Material type
          PRCTR LIKE MARC-PRCTR,  "Profit Center
          DISPO LIKE MARC-DISPO,  "MRP controller
          BWTTY LIKE MBEW-BWTTY,  "Valuation category
          BKLAS LIKE MBEW-BKLAS,  "Valuation Class
*{   INSERT         OCPK900065                                        2
STEUC LIKE zmm_mems-steuc,
  TAXIM TYPE mlan-TAXIM,
*}   INSERT
        END OF T_MM01.

DATA: G_MM01_IST TYPE STANDARD TABLE OF   T_MM01,
      G_MM01_WA TYPE T_MM01,
      IST_MSG TYPE STANDARD TABLE OF T_MSG,
      WA_MSG  TYPE T_MSG.
DATA:     G_CHECK_FLAG,
          G_EXTND_FLAG,
          G_REPRT_FLAG.
DATA: G_EXIST,  G_ALL, G_ONLY_SECOND, G_MAIL.

DATA: LS_HEADDATA   TYPE BAPIMATHEAD.
DATA: LT_HEADDATA   TYPE STANDARD TABLE OF BAPIMATHEAD.

DATA: LT_ZMM_MEMS TYPE STANDARD TABLE OF ZMM_MEMS,
      LS_ZMM_MEMS TYPE ZMM_MEMS,
      LT_ZMM_MECS TYPE STANDARD TABLE OF ZMM_MECS,
      LS_ZMM_MECS TYPE ZMM_MECS.

TYPE-POOLS: SLIS.
DATA: ID_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV.
DATA: WA_FIELDCAT   TYPE SLIS_FIELDCAT_ALV.
DATA V_REPID TYPE SY-REPID .

DATA: WA_MESG TYPE BAPI_MATRETURN2,
      RETURNMESSAGES TYPE STANDARD TABLE OF BAPI_MATRETURN2.

DATA: W_AGR_USERS TYPE AGR_USERS.

""
"added by lipsy on 20.08.2015  RD1K998283

types:begin of ty_lgnum,
  lgnum type lgnum,
  END OF ty_lgnum.

  data:ITab_T320 TYPE TABLE OF ty_lgnum,

  G_MM01_sec TYPE STANDARD TABLE OF   T_MM01.

"end of addition by lipsy on 20.08.2015  RD1K998283
""
*{   INSERT         OCDK902682                                        3
 data: gv_steuc TYPE t604f-steuc,
       gv_TAXIM TYPE TMKM1-TAXIM,
       gv_land1 TYPE t604f-land1,
       flg TYPE int4,
       req_st TYPE zmm_hsn_upd-req_st,
       gv_req1 TYPE zmm_hsn_upd-REQ_NO,
       DOCNO_A TYPE ZMM_HSN_UPD-REQ_NO,
       DOCNO_C TYPE ZMM_HSN_UPD-REQ_NO,
       gv_req TYPE zmm_hsn_upd-REQ_NO,
       wa_zmm_hsn_upd TYPE  zmm_hsn_upd,
       wa_zmm_hsn_upd_itm TYPE  zmm_hsn_upd_itm,
       it_zmm_hsn_upd_itm TYPE TABLE OF zmm_hsn_upd_itm,
       wa_marc TYPE marc,
       wa_mlan TYPE mlan,
       gv_COUNC TYPE t001w-COUNC,
       gv_msg type  char255.


*}   INSERT
