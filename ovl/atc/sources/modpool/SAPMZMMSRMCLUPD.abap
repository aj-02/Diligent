*--- MAIN PROGRAM: SAPMZMMSRMCLUPD ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMSRMCLUPD                                   *
*&                                                                     *
*&**********************************************************************
* Program    :  SAPMZMMSRMCLUPD (MODULE POOL)                          *

* Title      :  SRM Class Updation                                     *
*                                                                      *
*                                                                      *
* FS No.     :  FS-MM-MAT-10
*                                                                      *
*                                                                      *
* Author     :  SHIBU S                Date :  31.10.2005              *
*                                                                      *
* Login Id   :  CAB_SHIBU                                              *
*                                                                      *
*                                                                      *
* Description:  This program cab be  used to  update SRM Class in      *
*                Material Master .                                     *
*                                                                      *
* Tran. Code :  ZMMSRM                                                 *
*                                                                      *
************************************************************************
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Change in include
*                                           MZMMSRMCLUPDF01 and
*                                           MZMMSRMCLUPDTOP
************************************************************************

  include mzmmsrmclupdtop                         .

  include mzmmsrmclupdi01                         .
  include mzmmsrmclupdf01                         .
  include mzmmsrmclupdo01                         .
  include <icon>.

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

*--- INCLUDE: MZMMSRMCLUPDF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMSRMCLUPDF01                                            *
*----------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Replaced obsolte FM
*                                           'UPLOAD'
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  GET_USR_DATE
*&---------------------------------------------------------------------*
*       Show User name and PassWord
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_usr_date.
  if ok_code_90 = 'CREA'.
    move sy-uname to g_uname .
    write sy-datum to g_sydate dd/mm/yyyy.
  endif.
endform.                    " GET_USR_DATE
*&---------------------------------------------------------------------*
*&      Form  check_table_initial
*&---------------------------------------------------------------------*
*       Check whether the table ist_tc100 is initial or not
* If initial then add slno .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_table_initial.


endform.                    " check_table_initial

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
form user_ok_tc using    p_tc_name type dynfnam
                         p_table_name
                         p_mark_name
                changing p_ok      like sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  data: l_ok              type sy-ucomm,
        l_offset          type i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  search p_ok for p_tc_name.
  if sy-subrc <> 0.
    exit.
  endif.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
* execute general and TC specific operations                           *
  case l_ok.
    when 'INSR'.                      "insert row
      perform fcode_insert_row using    p_tc_name
                                        p_table_name.
      clear p_ok.

    when 'DELE'.                      "delete row
      perform fcode_delete_row using    p_tc_name
                                        p_table_name
                                        p_mark_name.
      clear p_ok.

    when 'P--' or                     "top of list
         'P-'  or                     "previous page
         'P+'  or                     "next page
         'P++'.                       "bottom of list
      perform compute_scrolling_in_tc using p_tc_name
                                            l_ok.
      clear p_ok.
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
    when 'MARK'.                      "mark all filled lines
      perform fcode_tc_mark_lines using p_tc_name
                                        p_table_name
                                        p_mark_name   .
      clear p_ok.

    when 'DMRK'.                      "demark all filled lines
      perform fcode_tc_demark_lines using p_tc_name
                                          p_table_name
                                          p_mark_name .
      clear p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  endcase.

endform.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
form fcode_insert_row
              using    p_tc_name           type dynfnam
                       p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  data l_lines_name       like feld-name.
  data l_selline          like sy-stepl.
  data l_lastline         type i.
  data l_line             type i.
  data l_table_name       like feld-name.
  field-symbols <tc>                 type cxtab_control.
  field-symbols <table>              type standard table.
  field-symbols <lines>              type i.
*-END OF LOCAL DATA----------------------------------------------------*

  assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

* get looplines of TableControl
  concatenate 'G_' p_tc_name '_LINES' into l_lines_name.
  assign (l_lines_name) to <lines>.

* get current line
  get cursor line l_selline.
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
  insert initial line into <table> index l_selline.
  <tc>-lines = <tc>-lines + 1.
* set cursor
  set cursor line l_line.

endform.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
form fcode_delete_row
              using    p_tc_name           type dynfnam
                       p_table_name
                       p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  data l_table_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <table>      type standard table.
  field-symbols <wa>.
  field-symbols <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

* delete marked lines                                                  *
  describe table <table> lines <tc>-lines.

  loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
    assign component p_mark_name of structure <wa> to <mark_field>.

    if <mark_field> = 'X'.
      delete <table> index syst-tabix.
      if sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      endif.
    endif.
  endloop.

endform.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
form compute_scrolling_in_tc using    p_tc_name
                                      p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  data l_tc_new_top_line     type i.
  data l_tc_name             like feld-name.
  data l_tc_lines_name       like feld-name.
  data l_tc_field_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <lines>      type i.
*-END OF LOCAL DATA----------------------------------------------------*

  assign (p_tc_name) to <tc>.
* get looplines of TableControl
  concatenate 'G_' p_tc_name '_LINES' into l_tc_lines_name.
  assign (l_tc_lines_name) to <lines>.


* is no line filled?                                                   *
  if <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  else.
*   no, ...                                                            *
    call function 'SCROLLING_IN_TABLE'
         exporting
              entry_act             = <tc>-top_line
              entry_from            = 1
              entry_to              = <tc>-lines
              last_page_full        = 'X'
              loops                 = <lines>
              ok_code               = p_ok
              overlapping           = 'X'
         importing
              entry_new             = l_tc_new_top_line
         exceptions
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              others                = 0.
  endif.

* get actual tc and column                                             *
  get cursor field l_tc_field_name
             area  l_tc_name.

  if syst-subrc = 0.
    if l_tc_name = p_tc_name.
*     set actual column                                                *
      set cursor field l_tc_field_name line 1.
    endif.
  endif.

* set the new top line                                                 *
  <tc>-top_line = l_tc_new_top_line.


endform.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
form fcode_tc_mark_lines using p_tc_name
                               p_table_name
                               p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  data l_table_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <table>      type standard table.
  field-symbols <wa>.
  field-symbols <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

* mark all filled lines                                                *
  loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
    assign component p_mark_name of structure <wa> to <mark_field>.

    <mark_field> = 'X'.
  endloop.
endform.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
form fcode_tc_demark_lines using p_tc_name
                                 p_table_name
                                 p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  data l_table_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <table>      type standard table.
  field-symbols <wa>.
  field-symbols <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

* demark all filled lines                                              *
  loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
    assign component p_mark_name of structure <wa> to <mark_field>.

    <mark_field> = space.
  endloop.
endform.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  create_icon
*&---------------------------------------------------------------------*
*       Create Icon
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_icon.

*  CALL FUNCTION 'ICON_CREATE'
*    EXPORTING
*      name                        = 'ICON_LED_RED'
**   TEXT                        = ' '
**   INFO                        = ' '
**   ADD_STDINF                  = 'X'
*   IMPORTING
*     result                      = icon
** EXCEPTIONS
**   ICON_NOT_FOUND              = 1
**   OUTPUTFIELD_TOO_SHORT       = 2
**   OTHERS                      = 3
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


endform.                    " create_icon
*&---------------------------------------------------------------------*
*&      Form  get_maktx
*&---------------------------------------------------------------------*
*      Get Material Description
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_maktx.

  loop at ist_tc100 into wa_100.
    if not wa_100-matnr is initial.
      select single maktx from makt into wa_100-maktx where
        matnr = wa_100-matnr and
        spras = 'EN'.
      modify ist_tc100 from wa_100 index sy-tabix.
    endif.

  endloop.

endform.                    " get_maktx
*&---------------------------------------------------------------------*
*&      Form  append_lines
*&---------------------------------------------------------------------*
*      Append Lines to internal Table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form append_lines.
  data: l_lines type n .
  data: l_do type n.
  describe table ist_tc100 lines l_lines.
  l_do = 1000 - l_lines.

  do l_do times.
    move space to wa_100. "#EC CI_FLDEXT_OK[2215424]
    append wa_100 to ist_tc100.
  enddo.
endform.                    " append_lines
*&---------------------------------------------------------------------*
*&      Form  get_request_no
*&---------------------------------------------------------------------*
*       Get Request number
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_request_no.

  call function 'NUMBER_GET_NEXT'
    exporting
      nr_range_nr                   = '01'
      object                        = 'ZMM_SRMUPD'
      quantity                      = '1'
    importing
     number                        = g_reqno.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " get_request_no
*&---------------------------------------------------------------------*
*&      Form  check_srm_class
*&---------------------------------------------------------------------*
*       Check SRM Class
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_srm_class.
  data: l_atwrt like ausp-atwrt.
  data: l_err(70) .
  data: l_objek like ausp-objek,
        l_atinn like ausp-atinn.
  clear: l_atwrt,
         l_err .

  if ok_code_90 = 'CREA'.
    l_objek = wa_tc100-matnr .
    call function 'CONVERSION_EXIT_ATINN_INPUT'
         exporting
              input  = 'MAT_TYPE'
         importing
              output = l_atinn.

    SELECT ATWRT FROM AUSP INTO L_ATWRT UP TO 1 ROWS
 WHERE OBJEK = L_OBJEK AND ATINN = L_ATINN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if l_atwrt = 'A' or
       l_atwrt = 'B' or
       l_atwrt = 'C'.

** Modify Internal Table
      wa_tc100-dclass = l_atwrt.
      modify ist_tc100 from wa_tc100 transporting dclass where
                          matnr = wa_tc100-matnr .
DATA lv_err TYPE string.

lv_err = |{ text-001 } - "{ l_atwrt }" - Assigned to this Material|.
l_err  = lv_err.
*     concatenate text-001 '-"' l_atwrt '"-' 'Assigned to this Material'
*                        into l_err.
      wa_tc100-errtext = l_err.

      call function 'ICON_CREATE'
        exporting
          name                        = 'ICON_LED_YELLOW'
*   TEXT                        = ' '
*   INFO                        = ' '
*   ADD_STDINF                  = 'X'
       importing
         result                      = icon  .
* EXCEPTIONS
*   ICON_NOT_FOUND              = 1
*   OUTPUTFIELD_TOO_SHORT       = 2
*   OTHERS                      = 3

    else.
      wa_tc100-errtext = space .
    endif.
  endif.
endform.                    " check_srm_class
*&---------------------------------------------------------------------*
*&      Form  vlidate_srm_class
*&---------------------------------------------------------------------*
*       Validate SRM Class
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form vlidate_srm_class.
  data: l_atwrt like ausp-atwrt.
  data: l_err(70) .
  data: l_objek like ausp-objek,
        l_atinn like ausp-atinn.
  clear: l_atwrt,
         l_err .
  if ok_code_90 = 'CREA'.
    if not  wa_tc100-srmclass is initial.
      if not ( wa_tc100-srmclass = 'A' or
               wa_tc100-srmclass = 'B' or
               wa_tc100-srmclass = 'C' ) .
        message e216(zmm).

      else.

        l_objek = wa_tc100-matnr .
        call function 'CONVERSION_EXIT_ATINN_INPUT'
             exporting
                  input  = 'MAT_TYPE'
             importing
                  output = l_atinn.

        SELECT ATWRT FROM AUSP INTO L_ATWRT UP TO 1 ROWS
 WHERE OBJEK = L_OBJEK AND ATINN = L_ATINN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if l_atwrt = 'A' or
           l_atwrt = 'B' or
           l_atwrt = 'C'.

          if l_atwrt = wa_tc100-srmclass.
            CONDENSE l_atwrt.
            message e220(zmm) with l_atwrt. "#EC CI_FLDEXT_OK[2215424]
          endif.
        endif.
      endif.
*    elseif  wa_tc100-srmclass is initial and
*           not wa_tc100-matnr is initial.
*      set cursor field 'WA_TC100-SRMCLASS'.
*      message e219(zmm).
    endif.
  endif.
endform.                    " vlidate_srm_class
*&---------------------------------------------------------------------*
*&      Form  GET_IMPORT_FILE
*&---------------------------------------------------------------------*
*       Get Import File
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_import_file.
  data: l_fname like rlgrap-filename  .
* begin of <RD1K960036>
* Replaced obsolete FM 'UPLOAD'
  DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
         L_FILETABLE  TYPE  FILE_TABLE,
         l_RC         TYPE  I,
         l_P_DEF_FILE TYPE  STRING,
         l_P_FILE     TYPE  STRING,
         l_usr_act    TYPE  I.

*  call function 'UPLOAD'
*   exporting
**   CODEPAGE                      = ' '
*     filename                      = l_fname
*     filetype                      = 'DAT'
**   ITEM                          = ' '
**   FILEMASK_MASK                 = ' '
**   FILEMASK_TEXT                 = ' '
**   FILETYPE_NO_CHANGE            = ' '
**   FILEMASK_ALL                  = ' '
**   FILETYPE_NO_SHOW              = ' '
**   LINE_EXIT                     = ' '
**   USER_FORM                     = ' '
**   USER_PROG                     = ' '
**   SILENT                        = 'S'
** IMPORTING
**   FILESIZE                      =
**   CANCEL                        =
**   ACT_FILENAME                  =
**   ACT_FILETYPE                  =
*    tables
*      data_tab                      = ist_data
** EXCEPTIONS
**   CONVERSION_ERROR              = 1
**   INVALID_TABLE_WIDTH           = 2
**   INVALID_TYPE                  = 3
**   NO_BATCH                      = 4
**   UNKNOWN_ERROR                 = 5
**   GUI_REFUSE_FILETRANSFER       = 6
**   OTHERS                        = 7
*            .
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
  l_P_DEF_FILE = l_fname.

     CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
       EXPORTING
*         WINDOW_TITLE            =
*         DEFAULT_EXTENSION       =
          DEFAULT_FILENAME        = l_P_DEF_FILE
*         FILE_FILTER             =
*         WITH_ENCODING           =
*         INITIAL_DIRECTORY       =
*         MULTISELECTION          =
       CHANGING
          FILE_TABLE              = I_FILE_TABLE
          RC                      = l_RC
          USER_ACTION             = l_usr_act
*         FILE_ENCODING           =
       EXCEPTIONS
         FILE_OPEN_DIALOG_FAILED = 1
         CNTL_ERROR              = 2
         ERROR_NO_GUI            = 3
         NOT_SUPPORTED_BY_GUI    = 4
         others                  = 5      .

    IF sy-subrc = 0
      AND l_usr_act <>
      CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.


     LOOP AT I_FILE_TABLE  INTO l_FILETABLE.
        l_P_FILE = l_FILETABLE.
        EXIT.
      ENDLOOP.


  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = l_P_FILE
      FILETYPE                      = 'ASC'
      HAS_FIELD_SEPARATOR           = 'X'
    TABLES
      DATA_TAB                      = ist_data "#EC CI_FLDEXT_OK[2215424]
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
* end of <RD1K960036>
endform.                    " GET_IMPORT_FILE
*&---------------------------------------------------------------------*
*&      Form  load_data_in_tc
*&---------------------------------------------------------------------*
*      Load Uload data into table control.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form load_data_in_tc.
  if not ist_data[] is initial.
    refresh ist_tc100.
    refresh ist_tc100.

    loop at ist_data into wa_data.
      select single maktx from makt into wa_100-maktx
                 where matnr = wa_data-matnr and
                       spras = 'EN'.
      move-corresponding wa_data to wa_100.
      wa_100-slno = sy-tabix.
      append wa_100 to ist_tc100.
    endloop.
  endif.

endform.                    " load_data_in_tc
*&---------------------------------------------------------------------*
*&      Form  popup_confirm
*&---------------------------------------------------------------------*
*       Popup to Confirm before Save
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form popup_confirm.
  clear g_ans .

  call function 'POPUP_TO_CONFIRM'
       exporting
            titlebar      = text-002
            text_question = text-002
            text_button_1 = 'Yes'
            text_button_2 = 'No'
       importing
            answer        = g_ans.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " popup_confirm
*&---------------------------------------------------------------------*
*&      Form  alert_before_exit
*&---------------------------------------------------------------------*
*       Message before Exit
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form alert_before_exit.
  if not ist_tc100 is initial.
    clear g_ans .

    call function 'POPUP_TO_CONFIRM'
         exporting
              titlebar      = text-003
              text_question = text-003
              text_button_1 = 'Yes'
              text_button_2 = 'No'
         importing
              answer        = g_ans.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  endif.

endform.                    " alert_before_exit
*&---------------------------------------------------------------------*
*&      Form  UPDATE_REQUEST
*&---------------------------------------------------------------------*
*      Update Request
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_request.
*  data: begin of wa_upd_tab       ,
*          mandt type mandt        ,
*          reqno(10)                ,
*          werks type t001w-werks  ,
*          matnr type  mara-matnr  ,
*          srmclass type zsrmclass ,
*          ersda    type ersda     ,
*          ernam    type ernam     ,
*          remrk(60)               ,
*         end of wa_upd_tab .
*  data: ist_upd_tab like    wa_upd_tab occurs 0 with header line.
*  refresh ist_upd_tab.
*  if not g_reqno is initial.
*    loop at ist_tc100 into wa_100.
*      move-corresponding wa_100 to wa_upd_tab .
*      wa_upd_tab-reqno = g_reqno   .
*      wa_upd_tab-mandt = sy-mandt  .
*      wa_upd_tab-ersda = sy-datum  .
*      wa_upd_tab-ernam = sy-uname  .
*      wa_upd_tab-remrk = g_remarks .
*      append wa_upd_tab to ist_upd_tab .
*    endloop.
*    modify  zmm_srm_mat_clas  from table ist_upd_tab .
*  endif.
endform.                    " UPDATE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  check_reqno
*&---------------------------------------------------------------------*
*       Vlidate request number
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_reqno.
  data: l_reqno like zmm_srm_mat_clas-reqno.
  if  not zmm_srm_mat_clas-reqno is initial.
    select single reqno from zmm_srm_mat_clas into l_reqno
      where reqno = zmm_srm_mat_clas-reqno.
    if sy-subrc ne 0.
      message e218(zmm).
    endif.
  elseif zmm_srm_mat_clas-reqno is initial and sy-ucomm = 'ENTER'.
    message e221(zmm).
  endif.
endform.                    " check_reqno
*&---------------------------------------------------------------------*
*&      Form  RUN_BDC_MM02
*&---------------------------------------------------------------------*
*    BDC -   Use Transaction MM02
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form run_bdc_mm02.

  delete  ist_tc100 where matnr = space.
  loop at ist_tc100 into wa_100.

    if wa_100-dclass ne space .
      perform run_bdc_mm02i using wa_100.

    else.
      perform bdc_dynpro      using 'SAPLMGMM' '0060'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMMG1-MATNR'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.
      perform bdc_field       using 'RMMG1-MATNR'
                                    "'140103185'.
                                    wa_100-matnr.
      perform bdc_dynpro      using 'SAPLMGMM' '0070'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'MSICHTAUSW-DYTXT(03)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.
      perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                                    'X'.
      perform bdc_field       using 'MSICHTAUSW-KZSEL(03)'
                                    'X'.
      perform bdc_dynpro      using 'SAPLMGMM' '4004'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ZU01'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'MAKT-MAKTX'.

      perform bdc_field       using 'MAKT-MAKTX'
                                    "'VENYL FLOORING CARPET'.
                                     wa_100-maktx.
*      perform bdc_field       using 'MARA-MEINS'
*                                    'FT2'.
*      perform bdc_field       using 'MARA-MATKL'
*                                    '14'.
*      perform bdc_field       using 'MARA-PRDHA'
*                                    '14'.
*      perform bdc_field       using 'MARA-GEWEI'
*                                    'KG'.
      perform bdc_dynpro      using 'SAPLMGMM' '4300'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ZU07'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMMG1-MATNR'.
      perform bdc_dynpro      using 'SAPLMGMM' '4300'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=MAIN'.
      perform bdc_field       using 'MAKT-MAKTX'
                                    "'VENYL FLOORING CARPET'.
                                     wa_100-maktx.
      perform bdc_dynpro      using 'SAPLMGMM' '4004'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=SP03'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'MAKT-MAKTX'.
      perform bdc_field       using 'MAKT-MAKTX'
                                    "'VENYL FLOORING CARPET'.
                                     wa_100-maktx.
*      perform bdc_field       using 'MARA-MEINS'
*                                    'FT2'.
*      perform bdc_field       using 'MARA-MATKL'
*                                    '14'.
*      perform bdc_field       using 'MARA-PRDHA'
*                                    '14'.
*      perform bdc_field       using 'MARA-GEWEI'
*                                    'KG'.
      perform bdc_dynpro      using 'SAPLCLCA' '0602'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-KLART'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTE'.
      perform bdc_field       using 'RMCLF-KLART'
                                    '001'.
      perform bdc_dynpro      using 'SAPLCLFM' '0500'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-CLASS(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=EINT'.
      perform bdc_field       using 'RMCLF-PAGPOS'
                                    '1'.
      perform bdc_dynpro      using 'SAPLCLFM' '0500'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-CLASS(02)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'RMCLF-PAGPOS'
                                    '1'.
      perform bdc_field       using 'RMCLF-CLASS(02)'
                                    'ZSRM_CLASS'.
      perform bdc_dynpro      using 'SAPLCTMS' '0109'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RCTMS-MWERT(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BACK'.
      perform bdc_field       using 'RCTMS-MNAME(01)'
                                    'MAT_TYPE'.
      perform bdc_field       using 'RCTMS-MWERT(01)'
                                    " 'a'.
                                     wa_100-srmclass.
      perform bdc_dynpro      using 'SAPLCLFM' '0500'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-CLASS(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=SAVE'.
      perform bdc_field       using 'RMCLF-PAGPOS'
                                    '1'.
*perform bdc_transaction using 'MM02'.
      call transaction 'MM02' using bdcdata mode 'E'
          messages into ist_msg.

      perform update_mat_class using wa_100.
      refresh bdcdata.
      clear bdcdata .
    endif.
  endloop.
endform.                    " RUN_BDC_MM02

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
form bdc_dynpro using program dynpro.
  clear bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
endform.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
form bdc_transaction using l_tcode.

  call function 'BDC_INSERT'
       exporting
            tcode     = l_tcode
       tables
            dynprotab = bdcdata.

endform.                    " bdc_trans

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*

form bdc_field using l_fnam l_fval.
  clear bdcdata.
  bdcdata-fnam = l_fnam.
  bdcdata-fval = l_fval.
  append bdcdata.
endform.
*&---------------------------------------------------------------------*
*&      Form  run_bdc_mm02i
*&---------------------------------------------------------------------*
*       BDC MM02
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form run_bdc_mm02i using wa_100 like wa_tc100.

  perform bdc_dynpro      using 'SAPLMGMM' '0060'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMMG1-MATNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'RMMG1-MATNR'
                                "'060000025'.
                                 wa_100-matnr .
  perform bdc_dynpro      using 'SAPLMGMM' '0070'.
  perform bdc_field       using 'BDC_CURSOR'
                                'MSICHTAUSW-DYTXT(03)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                                'X'.
  perform bdc_field       using 'MSICHTAUSW-KZSEL(03)'
                                'X'.
  perform bdc_dynpro      using 'SAPLMGMM' '4004'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=SP03'.
  perform bdc_field       using 'BDC_CURSOR'
                                'MAKT-MAKTX'.
  perform bdc_field       using 'MAKT-MAKTX'
*                              'BULL LINE 1 1/8"X163FT 321111111111111'
*                            & '1*'.
                                  wa_100-maktx.
*  perform bdc_field       using 'MARA-MEINS'
*                                'NO'.
*  perform bdc_field       using 'MARA-MATKL'
*                                '06'.
*  perform bdc_field       using 'MARA-PRDHA'
*                                '06'.
  perform bdc_dynpro      using 'SAPLCLCA' '0602'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMCLF-KLART'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTE'.
  perform bdc_field       using 'RMCLF-KLART'
                                '001'.
  perform bdc_dynpro      using 'SAPLCLFM' '0500'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMCLF-CLASS(02)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'RMCLF-PAGPOS'
                                '1'.
  perform bdc_dynpro      using 'SAPLCTMS' '0109'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BACK'.
  perform bdc_field       using 'RCTMS-MNAME(01)'
                                'MAT_TYPE'.
  perform bdc_field       using 'RCTMS-MWERT(01)'
                                "'A'.
                                 wa_100-srmclass.
  perform bdc_dynpro      using 'SAPLCLFM' '0500'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=VOBI'.
  perform bdc_field       using 'RMCLF-PAGPOS'
                                '1'.
  perform bdc_dynpro      using 'SAPLMGMM' '4004'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ZU01'.
  perform bdc_field       using 'BDC_CURSOR'
                                'MAKT-MAKTX'.
  perform bdc_field       using 'MAKT-MAKTX'
*                              'BULL LINE 1 1/8"X163FT 321111111111111'
*                            & '1*'.
                                 wa_100-maktx.
*  perform bdc_field       using 'MARA-MEINS'
*                                'NO'.
*  perform bdc_field       using 'MARA-MATKL'
*                                '06'.
*  perform bdc_field       using 'MARA-PRDHA'
*                                '06'.
  perform bdc_dynpro      using 'SAPLMGMM' '4300'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ZU07'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMMG1-MATNR'.
  perform bdc_dynpro      using 'SAPLMGMM' '4300'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'MAKT-MAKTX'
*                              'BULL LINE 1 1/8"X163FT 321111111111111'
*                            & '1*'.
                                 wa_100-maktx.
*perform bdc_transaction using 'MM02'.
  call transaction 'MM02' using bdcdata mode 'E'
                    messages into ist_msg.
  perform update_mat_class using wa_100.
  refresh bdcdata.
  clear  bdcdata .

endform.                    " run_bdc_mm02i
*&---------------------------------------------------------------------*
*&      Form  clear_global
*&---------------------------------------------------------------------*
*       Clear  Global Variables
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_global.
  clear: ist_tc100,
         wa_100,
         wa_tc100.
  clear: g_werks ,
         g_remarks,
         g_reqno ,
         g_dup.
  clear: ok_code_90 ,
         ok_code    .

  clear : zmm_srm_mat_clas-reqno.
  refresh: ist_tc100 ,
           ist_disp.

endform.                    " clear_global
*&---------------------------------------------------------------------*
*&      Form  assign_srlno
*&---------------------------------------------------------------------*
*       Assign Serial no
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form assign_srlno.
  if not wa_tc100-matnr is initial.
    wa_tc100-slno = tc100-current_line .
  endif.
endform.                    " assign_srlno
*&---------------------------------------------------------------------*
*&      Form  update_mat_class
*&---------------------------------------------------------------------*
*       Update table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_mat_class using wa_tc100 like wa_100.
  data: l_txt(50).
  data: wa_srm_tab like zmm_srm_mat_clas.
  data: l_tdname like thead-tdname.
  data: l_insert.
  loop at ist_msg  .
    if ist_msg-msgtyp = 'S' and ist_msg-msgnr = '801'.

      move-corresponding wa_100 to wa_srm_tab .

      wa_srm_tab-reqno = g_reqno .
      wa_srm_tab-ersda = sy-datum .
      wa_srm_tab-ernam = sy-uname .
      wa_srm_tab-remrk = g_remarks.
      modify zmm_srm_mat_clas from wa_srm_tab .
      if sy-subrc = 0.
*Update Internal Comments
        header-tdobject = 'MATERIAL'.
        header-tdid     = 'IVER'.
        header-tdname   =  wa_100-matnr .
        header-tdspras  = 'EN'.
        header-tdform   = 'SYSTEM'.
        header-mandt    = sy-mandt .
        refresh ist_lines .
        l_tdname  = wa_100-matnr .

* Read Text

        refresh ist_lines.

        select single * from stxh
                 where tdobject = 'MATERIAL' and
                       tdname   = l_tdname and
                       tdid     = 'IVER'.
        if sy-subrc = 0.
          call function 'READ_TEXT'
               exporting
                    client   = sy-mandt
                    id       = 'IVER'
                    language = 'E'
                    name     = l_tdname
                    object   = 'MATERIAL'
               tables
                    lines    = ist_lines.

        endif.
        concatenate g_uname '-' g_sydate into l_txt .
        wa_lines-tdformat = '*'.
        wa_lines-tdline  =  l_txt .
        append wa_lines to ist_lines .
        wa_lines-tdformat = '*'.
        wa_lines-tdline = g_remarks.
        append wa_lines to ist_lines .
        wa_lines-tdformat = '*'.
        clear l_txt.
        concatenate 'Request no-' g_reqno into l_txt.
        wa_lines-tdline = l_txt.
        append wa_lines to ist_lines .

        if ist_lines[] is initial.
          l_insert = 'X'.
        else.
          l_insert =  space.
        endif.

        call function 'SAVE_TEXT'
             exporting
                  client          = sy-mandt
                  header          = header
                  insert          = l_insert
                  savemode_direct = 'X'
             tables
                  lines           = ist_lines.

        move-corresponding wa_srm_tab to wa_disp.
        append wa_disp to ist_disp.
      endif.
      exit.
    endif.
  endloop.
  clear ist_msg .
  refresh ist_msg.
  clear wa_100.
endform.                    " update_mat_class
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*      Get Data from table ZMM_SRM_MAT_CLAS
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_data.
  select * from zmm_srm_mat_clas into corresponding fields of table
    ist_mat_clas
      where reqno =  zmm_srm_mat_clas-reqno ORDER BY PRIMARY KEY.

  read table ist_mat_clas  into wa_mat_clas index 1.
  move wa_mat_clas-remrk to g_remarks   .
  move wa_mat_clas-reqno  to g_reqno    .
  refresh ist_tc100.
  move wa_mat_clas-ernam to g_uname .
  write wa_mat_clas-ersda to g_sydate dd/mm/yyyy.

  loop at ist_mat_clas into wa_mat_clas.
    move-corresponding wa_mat_clas to wa_tc100.
    append wa_tc100 to ist_tc100.

  endloop.
endform.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  display_data
*&---------------------------------------------------------------------*
*       Display Successful Documents.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_data.
  leave to list-processing and return to screen '90'.
  data: l_tabix(4).
  if not ist_disp[] is initial.
    write:/20 text-t01.

    write:/5 sy-vline no-gap, sy-uline(47) no-gap.

    write:/5 sy-vline,'Slno',10 sy-vline,
           11 'Material' ,25 sy-vline,
           26 'SRM Class' ,  40 sy-vline,
           41 'Reqest no', 52 sy-vline .

    write:/5 sy-uline(48).
    loop at ist_disp into wa_disp.

      l_tabix = sy-tabix .
      write:/5  sy-vline ,6 l_tabix  ,10 sy-vline,
             11  wa_disp-matnr   , 25 sy-vline,
             26 wa_disp-srmclass , 40 sy-vline,
             41 wa_disp-reqno ,    52 sy-vline .
      write:/5 sy-vline no-gap, sy-uline(47) no-gap.

    endloop.
    perform clear_global.
    leave to screen '90' .
  endif.
endform.                    " display_data
*&---------------------------------------------------------------------*
*&      Form  check_duplicate
*&---------------------------------------------------------------------*
*      Check Dulicate Material.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_duplicate.
  data: ist_tc100_cp like table of wa_tc100,
        wa_100_cp  like  wa_tc100.
  data: l_matnr type matnr .
  refresh ist_tc100_cp .
  data: l_indx type i.
  ist_tc100_cp[] = ist_tc100[].
  sort ist_tc100_cp by matnr .
  loop at ist_tc100_cp into wa_100_cp where matnr ne space.
    l_indx = l_indx + 1.
    if l_indx =  1.
      l_matnr = wa_100_cp-matnr .

    else.
      if l_matnr =   wa_100_cp-matnr .
        g_dup = 'X'.
        message i366(zmm).
        exit.
      else.
        l_matnr =  wa_100_cp-matnr .
        g_dup = space.
      endif.
    endif.
  endloop.

endform.                    " check_duplicate

*&---------------------------------------------------------------------*
*&      Form  SET_CURSOR_FIELD
*&---------------------------------------------------------------------*
*       SET CURSOR.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_cursor_field.
  data: ist_tmp like table of wa_tc100 ,
         wa_tmp like wa_tc100.
  data: l_line type i.
  field-symbols: <fs> type any .
  ist_tmp[] = ist_tc100[].

  clear l_line .
  loop at ist_tmp into wa_tmp.

    if wa_tmp-matnr ne  space.
      l_line = l_line + 1.
    endif.
  endloop.

  if not g_remarks is initial and ist_tc100[] is initial.
    l_line =  1.
    set cursor field 'WA_TC100-MATNR' line l_line .
  else.
    assign ('WA_TC100-MATNR') to <fs>.
    if <fs> ne space .
      set cursor field 'WA_TC100-SRMCLASS' line l_line .
    endif.
    if <fs> ne space and wa_tc100-srmclass ne space .
      l_line = l_line + 1.
      set cursor field 'WA_TC100-MATNR' line l_line .
    endif.
  endif.
endform.                    " SET_CURSOR_FIELD

*--- INCLUDE: MZMMSRMCLUPDI01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMSRMCLUPDI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FCODE_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Function Code Exit
*----------------------------------------------------------------------*
module fcode_exit input.
  case ok_code.
    when 'BACK' or 'EXIT' or 'CANCEL'.
      if ok_code_90 ne 'DISP'.
        perform alert_before_exit.
        if g_ans = '1' or ist_tc100[]  is initial.
          perform clear_global.
          leave to screen '90' .
        endif.
      else.
        perform clear_global.
        leave to screen '90' .
      endif.
  endcase.
endmodule.                 " FCODE_EXIT  INPUT

*&spwizard: input module for tc 'TC105'. do not change this line!
*&spwizard: modify table
module tc100_modify input.
  move-corresponding wa_tc100 to wa_100.
  wa_100-slno = tc100-current_line.
  wa_tc100-slno = tc100-current_line.
  modify ist_tc100
    from wa_100
     index tc100-current_line.
  if sy-subrc ne 0.
    append wa_100 to ist_tc100.
  endif.
endmodule.

*&spwizard: input modul for tc 'TC100'. do not change this line!
*&spwizard: mark table
module tc100_mark input.
  data: g_tc100_wa2 like line of ist_tc100.
  if tc100-line_sel_mode = 1.
    loop at ist_tc100 into g_tc100_wa2
      where smark = 'X'.
      g_tc100_wa2-smark = ''.
      modify ist_tc100
        from g_tc100_wa2
        transporting smark.
    endloop.
  endif.
  modify ist_tc100
    from wa_tc100
    index tc100-current_line
    transporting smark.
endmodule.

*&spwizard: input module for tc 'TC100'. do not change this line!
*&spwizard: process user command
module tc100_user_command input.
  ok_code = sy-ucomm.
  perform user_ok_tc using    'TC100'
                              'IST_TC100'
                              'SMARK'
                     changing ok_code.
  sy-ucomm = ok_code.
  case ok_code.
    when 'SAVE'.
      if g_dup ne 'X'.

        delete ist_tc100 where matnr =  space.
        if not ist_tc100[] is initial.
          perform popup_confirm.
        endif.
      endif.
*** Gererate  Request number
      if g_ans = '1'.
        perform get_request_no.
        perform run_bdc_mm02.
        perform update_request.
        perform display_data.
      endif.
    when 'IMPF'.
      perform get_import_file.
      perform load_data_in_tc.
  endcase.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  check_manr  INPUT
*&---------------------------------------------------------------------*
*       check Matereial Document no
*----------------------------------------------------------------------*
module check_matnr input.
  data: l_matnr like mara-matnr .
  if ok_code_90 = 'CREA' and ok_code ne  'TC100_DELE'.
    select single matnr from mara into l_matnr
      where matnr = wa_tc100-matnr .
    if sy-subrc ne 0.
      message e096(zmm) with  wa_tc100-matnr .
    endif.
  endif.
 endmodule.                 " check_manr  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0090  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0090 input.
  case ok_code_90  .
    when 'BACK' or 'EXIT' or 'CANCEL'.
      leave program.
    when 'CREA'  .
      refresh control 'TC100' from screen '100'.
      call screen '100'.
    when 'DISP'.
      call screen 105 starting at 10 5  ending at 45 8 .
  endcase.
endmodule.                 " USER_COMMAND_0090  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       User Commands
*----------------------------------------------------------------------*
module user_command_0105 input.
  case sy-ucomm  .
    when 'BACK' or '%EX' or 'RW' .
      set screen 0.
      perform clear_global.
      leave  screen  .
    when 'ENTER'.
      perform get_data.
      call screen '100'.
  endcase .
endmodule.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*   vALIDATE INPUT REQUEST NO
*----------------------------------------------------------------------*
module check_input input.
  perform check_reqno.
endmodule.                 " CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*&      Module  valid_input  INPUT
*&---------------------------------------------------------------------*
*       Check for Valid input Material code.
*----------------------------------------------------------------------*
module check_dup_matnr input.
  perform check_duplicate.
endmodule.                 " valid_input  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_set_cursor  INPUT
*&---------------------------------------------------------------------*
*       Get/Set Cursor Field
*----------------------------------------------------------------------*
module get_set_cursor input.
  perform set_cursor_field.
  perform vlidate_srm_class.
endmodule.                 " get_set_cursor  INPUT

*--- INCLUDE: MZMMSRMCLUPDO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMSRMCLUPDO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  set_status_100  OUTPUT
*&---------------------------------------------------------------------*
*       Set Pf Status
*----------------------------------------------------------------------*

MODULE set_status_100 OUTPUT.
  IF ok_code_90 = 'DISP' OR ist_tc100[] IS INITIAL.
    ist_tab-fcode = 'SAVE'.
    APPEND ist_tab .
  ELSE.
    REFRESH ist_tab.
    CLEAR ist_tab .
  ENDIF.

  SET PF-STATUS 'S100'  EXCLUDING ist_tab.
  IF ok_code_90 = 'CREA'.
    SET TITLEBAR 'T100' WITH text-t02.
  ELSEIF ok_code_90 = 'DISP'.
    SET TITLEBAR 'T100' WITH text-t03 zmm_srm_mat_clas-reqno.
  ENDIF.
  PERFORM get_usr_date.
  PERFORM check_table_initial.
ENDMODULE.                 " set_status_100  OUTPUT

*&spwizard: output module for tc 'TC100'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tc100_change_tc_attr OUTPUT.
  DESCRIBE TABLE ist_tc100 LINES tc100-lines.
  IF ok_code_90 = 'DISP'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01' .
        screen-input  = 0.
        MODIFY SCREEN.
      ELSEIF  screen-group1 = 'MOD' OR
              screen-group1 = 'PAG' OR
              screen-group1 = 'MAR' OR
              screen-group2 = 'G02'.
        screen-invisible = 1.
        MODIFY SCREEN.

      ENDIF.
    ENDLOOP.

    LOOP AT tc100-cols INTO cols.
      IF cols-screen-name  = 'WA_TC100-MATNR' OR
          cols-screen-name = 'WA_TC100-SRMCLASS'.
        cols-screen-input = 0.
        MODIFY tc100-cols FROM cols .
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.

*&spwizard: output module for tc 'TC100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tc100_get_lines OUTPUT.
  g_tc100_lines = sy-loopc  .
  PERFORM assign_srlno       .
  PERFORM check_srm_class .
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  GEN_SET  OUTPUT
*&---------------------------------------------------------------------*
*       General  Settings
*----------------------------------------------------------------------*
MODULE gen_set OUTPUT.
  DATA: l_tabix(5) TYPE n.
  CLEAR l_tabix.
  LOOP AT ist_tc100 INTO wa_100.
    IF NOT wa_100-matnr IS INITIAL.
      l_tabix = l_tabix + 1.
      wa_100-slno = l_tabix.
      MODIFY ist_tc100 FROM wa_100.
    ENDIF.
  ENDLOOP.
  PERFORM get_maktx.
  PERFORM append_lines.
ENDMODULE.                 " GEN_SET  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0090  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0090 OUTPUT.
  SET PF-STATUS 'S90'.
  SET TITLEBAR 'T90'.
ENDMODULE.                 " STATUS_0090  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       PF Status
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS 'S105'.
  SET TITLEBAR 'T105'.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       Set Cursor.
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.
  PERFORM set_cursor_field.
ENDMODULE.                 " SET_CURSOR  OUTPUT

*--- INCLUDE: MZMMSRMCLUPDTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMSRMCLUPDTOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Declared Screen fields in
*                                           programs to remove screen
*                                           inconsistency errors
************************************************************************
program  sapmzmmsrmclupd               .
tables: zmm_srm_mat_clas,stxh.

data: ok_code like sy-ucomm .
data: begin of wa_tc100 ,
        slno(5)   type n   ,
        werks     type t001w-werks,
        matnr     type mara-matnr ,
        maktx     type makt-maktx ,
        srmclass  type char70  ,
        errtext(60)               ,
        smark                     ,
        dclass                    ,
      end of wa_tc100.

data: ist_tc100 like table of wa_tc100     .
data: wa_100 like wa_tc100.
data: g_uname like sy-uname ,
      g_sydate(10).
data: g_remarks(60) .

*&spwizard: declaration of tablecontrol 'TC100' itself
controls: tc100 type tableview using screen 0100.
data: cols like line of tc100-cols.
*&spwizard: lines of tablecontrol 'TC100'
data:     g_tc100_lines  like sy-loopc.
data: icon  like icons-text.
data  g_reqno(10).
data: ok_code_90 like sy-ucomm.

data: begin of wa_disp,
      slno(4)         ,
      matnr(40)       ,
      srmclass        ,
      reqno(10)       ,
      end of wa_disp.


data: begin of wa_data  ,
      matnr     type mara-matnr ,
      srmclass  type zsrmclass  ,
      end of wa_data.

data:  ist_data like table of wa_data,
       ist_disp like table of wa_disp.
data   g_ans.
data:  g_werks type t001w-werks.
data:  bdcdata like bdcdata    occurs 0 with header line.
data:  messtab like bdcmsgcoll occurs 0 with header line.

types: begin of  ty_tabtype,
          fcode like rsmpe-func,
       end of    ty_tabtype.
data: ist_tab type standard table of ty_tabtype with header line .

data:  ist_msg   type  table of bdcmsgcoll with header line      .
data:  wa_msg type   bdcmsgcoll .
data:  ist_mat_clas  type table of zmm_srm_mat_clas.
data:  wa_mat_clas   type  zmm_srm_mat_clas .
data  ok_code_105 like sy-ucomm.
data: header like  thead .
data: ist_lines type table of  tline.
data: wa_lines type tline  .
data: g_dup.
data:  g_CURSORFIELD(20).
* begin of <RD1K960036>
DATA OK_CODE_1O5 LIKE sy-ucomm.
* end of <RD1K960036>
