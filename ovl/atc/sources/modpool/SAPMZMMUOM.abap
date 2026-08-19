*--- MAIN PROGRAM: SAPMZMMUOM ---*


*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMUOM                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
***********************************************************************
* Program    : SAPMZMMUOM                                             *
* Title      : Material UOM Extension requests                        *
* Functional Specification No.: FS-MM-MAT-005                         *
* Author     : GR Mansuri                    Date : 06-OCT-2005       *
* Login Id   : CAB_MANSURI                                            *
* Desciption : To provide user a facility to convert UOM         .    *
* Transaction Code :                                                 *
***********************************************************************
************************************************************************
* Date        Transport     USERID       Description
* 13/09/2008  <RD1K960036>  SAB_PUNIT    1) Change in include
*                                           MZMMUOMF01
************************************************************************
INCLUDE MZMMUOMTOP.
*INCLUDE mzmmmertop .
INCLUDE MZMMUOMO01.
*INCLUDE mzmmmero01 .
INCLUDE MZMMUOMI01.
*INCLUDE mzmmmeri01 .
INCLUDE MZMMUOMF01.
*INCLUDE mzmmmerf01 .
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

*--- INCLUDE: MZMMUOMF01 ---*
***INCLUDE MZMMMERF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID     Description
* 13/09/2008  <RD1K960036>  SAB_PUNIT  1) Replaced obsolete FM 'UPLOAD'
************************************************************************
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
       perform fcode_move_row using    p_tc_name
                                         p_table_name
                                         p_mark_name.

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

     when 'SASCEND'.
       perform fcode_sort_as using p_tc_name
                                   p_table_name
                                   l_ok.
       clear p_ok.

     when 'SDESCEND'.
       perform fcode_sort_ds using p_tc_name
                                   p_table_name
                                   l_ok.
       clear p_ok.

     when 'FILTER'.
       perform fcode_filter_tc using p_tc_name
                                     p_table_name
                                     l_ok.
       clear p_ok.
     when 'IMPORT'.
       perform fcode_import_tc using p_tc_name
                                     p_table_name
                                     l_ok.
       clear p_ok.

*     WHEN 'CHECK'.
*       PERFORM fcode_check_tc USING p_tc_name
*                                    p_table_name
*                                    l_ok.
*       CLEAR p_ok.

     when 'COPY'.                      "copy row
       perform fcode_copy_row using      p_tc_name
                                         p_table_name
                                         p_mark_name.
       clear p_ok.


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
*   DATA l_actual           TYPE i.
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
*   DESCRIBE TABLE <table> LINES l_actual.
   get cursor line l_selline.
   if sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line
     if l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     else.
       <tc>-top_line = 1.
     endif.
   else.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   endif.

*&SPWIZARD: set new cursor line
   l_line = l_selline - <tc>-top_line + 1.
* insert initial line

*   l_selline = l_actual + 1.
   insert initial line into <table> index l_selline.
*   <tc>-lines = <tc>-lines + 1.
   <tc>-lines = 999.

* set cursor
   set cursor line l_line.
*   SET CURSOR LINE l_selline.
 endform.                              " FCODE_INSERT_ROW
*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 form fcode_move_row
               using    p_tc_name           type dynfnam
                        p_table_name
                        p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_table_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <table>      type standard table.
   field-symbols <wa>.
   field-symbols <mark_field>.

   data: l_wa type t_tc_81.
   clear : ist_del.                                         "+rk001
   refresh ist_del.                                         "+rk001
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
       read table <table> index syst-tabix into l_wa.    "#EC CI_FLDEXT_OK[2215424]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
       move-corresponding l_wa to ist_del.
       move wa_zmm_uom_d-docno  to ist_del-docno.
       append ist_del.

     endif.
     clear ist_del.                                         "+rk002
   endloop.

 endform.                              " FCODE_DELETE_ROW

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

   data: l_wa type t_tc_81.

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
*         <tc>-lines = <tc>-lines - 1.
         <tc>-lines = 999.
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


* is no line filled?
*
   if <tc>-lines = 0.
*   yes, ...
*
     l_tc_new_top_line = 1.
   else.
*   no, ...
*
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
*&      Form  GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_document_number .

   if g_ok_80 eq 'CREATE'.
     select max( docno ) into wa_zmm_uom_h-docno from zmm_uom_h .
     add 1 to wa_zmm_uom_h-docno.
*     CALL FUNCTION 'NUMBER_GET_NEXT'
*          EXPORTING
*               nr_range_nr             = '01'
*               object                  = 'ZMM_MUOM'
*               quantity                = '1'
*               toyear                  = '2005'
*          IMPORTING
*               number                  = number
*               returncode              = rc
*          EXCEPTIONS
*               interval_not_found      = 1
*               number_range_not_intern = 2
*               object_not_found        = 3
*               quantity_is_0           = 4
*               quantity_is_not_1       = 5
*               interval_overflow       = 6
*               buffer_overflow         = 7
*               OTHERS                  = 8.
*     IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*     ENDIF.
   endif.
 endform.                    " GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form assign_sy_values.
*   CLEAR zmm_uom_h.
   move sy-datum to wa_zmm_uom_h-ersda .
   move sy-datum to wa_zmm_uom_h-reqdt.

   move sy-uname to wa_zmm_uom_h-ernam .

   select  single a~bukrs  into wa_zmm_uom_h-bukrs
       from ( ( pa0001 as a inner join pa9930 as c
             on a~pernr = c~pernr ) inner join zdesignation_rev as d
                on c~designo = d~desig_code and
                    c~r_p_cd  = d~r_p_cd and
                    c~version = d~version )
                 where a~pernr = sy-uname.


 endform.                    " ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*&      Form  FCODE_SORT_as
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_sort_as using    p_tc_name
                             p_table_name
                             p_ok.

   data l_table_name  like feld-name.
   data cols          like line of tc_81-cols.

   field-symbols <table>      type standard table.

   concatenate p_table_name '[]' into l_table_name. "table body

   assign (l_table_name) to <table>.                "not headerline

   read table tc_81-cols into cols with key selected = 'X'.
   if sy-subrc = 0.
     sort <table> by (cols-screen-name+9) ascending .
     cols-selected = ' '.
     modify tc_81-cols from cols index sy-tabix.
   endif.


 endform.                    " FCODE_SORT_TC
*&---------------------------------------------------------------------
*
*&      Form  FCODE_SORT_ds
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_sort_ds using    p_tc_name
                             p_table_name
                             p_ok.

   data l_table_name  like feld-name.
   data cols          like line of tc_81-cols.

   field-symbols <table>      type standard table.

   concatenate p_table_name '[]' into l_table_name. "table body

   assign (l_table_name) to <table>.                "not headerline

   read table tc_81-cols into cols with key selected = 'X'.
   if sy-subrc = 0.
     sort <table> by (cols-screen-name+9) descending .
     cols-selected = ' '.
     modify tc_81-cols from cols index sy-tabix.
   endif.


 endform.                    " FCODE_SORT_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_filter_tc using    p_tc_name
                               p_table_name
                               p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_filt_no_change.
   data l_table_name          like feld-name.
   field-symbols <table>      type standard table.
*-END OF LOCAL DATA----------------------------------------------------*
* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

 endform.                    " FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*&      Form  FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_import_tc using    p_tc_name
                               p_table_name
                               p_ok.

   data: l_filename like rlgrap-filename.
   data: l_tc_81_itab type t_tc_81 occurs 0.
* begin of <RD1K960036>
* Replaced obsolete FM 'UPLOAD'
  DATA : L_T_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
         L_FILETABLE  TYPE  FILE_TABLE,
         l_RC         TYPE  I,
         l_P_DEF_FILE TYPE  STRING,
         l_P_FILE     TYPE  STRING,
         l_usr_act    TYPE  I.

*   call function 'UPLOAD'
*        exporting
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
*        tables
*             data_tab                = l_tc_81_itab
*        exceptions
*             conversion_error        = 1
*             invalid_table_width     = 2
*             invalid_type            = 3
*             no_batch                = 4
*             unknown_error           = 5
*             gui_refuse_filetransfer = 6
*             others                  = 7.

     l_P_DEF_FILE = l_filename.

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
          FILE_TABLE              = l_t_FILE_TABLE
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


     LOOP AT L_t_FILE_TABLE  INTO l_FILETABLE.
        l_P_FILE = l_FILETABLE.
        EXIT.
      ENDLOOP.


    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME                      = l_P_FILE
        FILETYPE                      = 'ASC'
        HAS_FIELD_SEPARATOR           = 'X'
      TABLES
        DATA_TAB                      = l_tc_81_itab    "#EC CI_FLDEXT_OK[2215424]
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
   if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   endif.

   if sy-subrc eq 0.
     if g_tc_81_itab[] is initial.
       g_tc_81_itab[] = l_tc_81_itab[].
     else.
       append lines of l_tc_81_itab to g_tc_81_itab.
       refresh l_tc_81_itab.
     endif.
   endif.

   refresh control 'TC_81' from screen '9081'.
   tc_81-lines = 999.


 endform.                    " FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*&      Form  SAVE_9081
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form save_9081.
   data: l_ans.
   if g_tc_81_itab is initial.
     clear sy-ucomm.
     message e354.
   endif.

   if g_ok_80 = 'DELETE'.

     call function 'POPUP_CONTINUE_YES_NO'
          exporting
               defaultoption = 'Y'
               textline1     = 'Delete the Document'
               textline2     = 'You will lose the Document data'
               titel         = 'Confirmation'
               start_column  = 25
               start_row     = 6
          importing
               answer        = l_ans.

     if l_ans eq 'J'.

       delete from zmm_uom_h where docno = g_docno.
       delete zmm_uom_d from table l_itab.
       leave to screen 9080.
     endif.

   else.

     perform get_document_number.

     perform delete_data_base on commit .
     perform commit_rollback.
     perform update_workareas.
     perform modify_data_base on commit .
     perform commit_rollback.
     perform user_message.
   endif.
 endform.                                                   " SAVE_9081
*&---------------------------------------------------------------------*
*&      Form  modify_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form modify_data_base.

   modify zmm_uom_h from wa_zmm_uom_h.
   modify zmm_uom_d from table ist_zmm_uom_d.
   loop at ist_zmm_uom_d into wa_zmm_uom_d.
    If wa_zmm_uom_d-UOM_STR1 = 'NON CONVERTIBLE UOM'.
    else.
     update mara set  vabme = '1'
        where matnr = wa_zmm_uom_d-matnr.
    endif.
   endloop.

 endform.                    " modify_data_base
*&---------------------------------------------------------------------*
*&      Form  commit_rollback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form commit_rollback.

   case sy-subrc.
     when 0 .
       commit work.
     when others .
       rollback work .
       message e671(zps).
   endcase .

 endform.                    " commit_rollback
*&---------------------------------------------------------------------*
*&      Form  user_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form user_message.

   case g_ok_80.
     when 'CREATE'.
       message i359 with wa_zmm_uom_h-docno.
       leave to screen 9080.
     when 'CHANGE'.
       message i352 with wa_zmm_uom_h-docno.
       leave to screen 9080.
   endcase.

 endform.                    " user_message
*&---------------------------------------------------------------------*
*&      Form  update_workareas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form update_workareas.
   clear ist_zmm_uom_d.
   if g_ok_80 eq 'CREATE'.
     wa_zmm_uom_d-docno = wa_zmm_uom_h-docno.
*     zmm_uom_d-sflag = 'N'.
   endif.

   loop at g_tc_81_itab into g_tc_81_wa.

     move-corresponding g_tc_81_wa to wa_zmm_uom_d.

     if g_ok_80 eq 'CREATE'.
       move sy-uname to wa_zmm_uom_h-userid.
       move sy-datum to wa_zmm_uom_d-ersda.
       move sy-uname to wa_zmm_uom_d-ernam.
*       MOVE 'N'      TO wa_zmm_mecs-sflag.
     elseif g_ok_80 eq 'CHANGE'.
       move g_docno to wa_zmm_uom_d-docno.
       move sy-datum to wa_zmm_uom_d-ersda.
       move sy-uname to wa_zmm_uom_d-ernam.
       move sy-datum to wa_zmm_uom_d-laeda.
       move sy-uname to wa_zmm_uom_d-aenam.
*       MOVE 'N'      TO wa_zmm_mecs-sflag.
     endif.

     append wa_zmm_uom_d to ist_zmm_uom_d.

   endloop.

   sort ist_zmm_uom_d by docno matnr  .

*   DELETE ADJACENT DUPLICATES FROM ist_zmm_uom_d.


 endform.                    " update_workareas
*&---------------------------------------------------------------------*
*&      Form  FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
* FORM fcode_check_tc USING    p_tc_name
*                              p_table_name
*                              p_ok.
*
*   DATA l_table_name       LIKE feld-name.
*
*   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
*   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
*   FIELD-SYMBOLS <wa>         TYPE t_tc_81.
*
*   DATA: l_mecs      TYPE zmm_mecs.
*   DATA: l_remrk(60) TYPE c.
*   DATA: l_matnr     LIKE mara-matnr.
*   DATA: l_value(2)  TYPE  c.
*   DATA: l_trip(3)   TYPE  c.
*   DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
*   DATA: l_tabix     LIKE sy-tabix.
*   DATA: l_msgt      TYPE LINE OF zmm_msgt.
*   DATA: l_mstae     TYPE mara-mstae.
*   DATA: l_agr_users TYPE agr_users.
*   DATA: general_data LIKE bapimatdoa.
*   DATA: return LIKE bapireturn.
*   DATA: plantdata LIKE bapimatdoc.
*   DATA: valuationdata LIKE bapimatdobew.
*   DATA: l_bwtar TYPE bwtar_d.
*   DATA: l_views(1) type n.                                 "+rk003
*
*   CLEAR l_views.
*   DATA: ans.
**-END OF LOCAL
*DATA----------------------------------------------------*
*   ASSIGN (p_tc_name) TO <tc>.
** get the table, which belongs to the tc
**
*   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
*   ASSIGN (l_table_name) TO <table>.                "not headerline
*
*   LOOP AT <table> ASSIGNING <wa>.
*
*     IF <wa>-matnr EQ space.
*       EXIT.
*     ENDIF.
*
*     l_tabix = sy-tabix.
*
*     IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.
*
*       IF NOT <wa>-werks IS INITIAL.
*         CALL FUNCTION 'GET_PLANT_DETAILS'
*              EXPORTING
*                   i_werks         = <wa>-werks
*              IMPORTING
*                   e_t001w         = t001w
*              EXCEPTIONS
*                   not_found       = 1
*                   parameter_error = 2
*                   OTHERS          = 3.
*
*         IF sy-subrc EQ 0.
*
*           IF NOT <wa>-bwtar IS INITIAL.
*
*             l_bwtar = <wa>-bwtar.
*
*             IF l_bwtar EQ 'BATCH_MNGD'.
*               CLEAR l_bwtar.
*             ENDIF.
*
*             IF NOT <wa>-matnr IS INITIAL.
*               CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
*                    EXPORTING
*                         material              = <wa>-matnr
*                         plant                 = <wa>-werks
*                         valuationarea         = t001w-bwkey
*                         valuationtype         = l_bwtar
*                    IMPORTING
*                         material_general_data = general_data
*                         return                = return
*                         materialplantdata     = plantdata
*                         materialvaluationdata = valuationdata.
*
*               IF return-type EQ 'S'.
*
*                 DATA : plants TYPE TABLE OF marc_werk WITH HEADER LINE
*.
*                 DATA : l_strlen TYPE i.
*
*                 REFRESH plants.
*                 CLEAR l_strlen.
*
*                 CALL FUNCTION 'MATERIAL_READ_PLANTS'
*                      EXPORTING
*                           matnr  = <wa>-matnr
*                      TABLES
*                           plants = plants.
*
*                 READ TABLE plants  WITH KEY werks = <wa>-werks.
*                 l_strlen = strlen( plants-pstat ).
**--------start of changes by rk003------------------------------------*
*
*                 SELECT SINGLE * FROM t320 WHERE
*                                 werks EQ <wa>-werks.
*                 if sy-subrc is initial.
*                   l_views = 7.
*                 else.
*                   l_views = 6.
*                 endif.
*
**--------end of changes by rk003------------------------------------*
*
**                 IF l_strlen GE 6.        "-rk002
*                 IF l_strlen = l_views.                     "+RK003
*                   <wa>-remrk = text-010.  "Already extended
*                   EXIT.
*                 ENDIF.
*               ELSEIF return-type EQ 'E' AND return-code EQ 'M3305'.
*                 <wa>-remrk = return-message_v1.
*                 EXIT.
*               ENDIF.
*             ENDIF.
*           ENDIF.
*           CLEAR l_bwtar.
*         ENDIF.
*       ENDIF.
*
*
*
*       CLEAR l_matnr.
*       SELECT SINGLE matnr mstae  INTO (l_matnr, l_mstae)
*                           FROM mara
*                           WHERE matnr = <wa>-matnr.
*       IF sy-subrc NE 0.
*         CONCATENATE 'Material'
*                      <wa>-matnr
*                     'does not exist - check your entry'
*                     INTO l_remrk SEPARATED BY space.
*         MOVE l_remrk TO <wa>-remrk.
*         CLEAR l_remrk.
*       ELSEIF sy-subrc EQ 0.
*         IF NOT ( l_mstae IS INITIAL ).
*           SELECT SINGLE * FROM t141t WHERE mmsta = l_mstae
*                                        AND spras = 'E'.
*           <wa>-remrk = t141t-mtstb.
*         ENDIF.
*       ENDIF.
*       CLEAR t001w.
*       SELECT SINGLE * FROM t001w WHERE werks = <wa>-werks.
*       IF sy-subrc NE 0.
*         CONCATENATE 'Plant'
*                     <wa>-werks
*                     'does not exist - check your entry'
*                     INTO l_remrk SEPARATED BY space.
*         MOVE l_remrk TO <wa>-remrk.
*         CLEAR l_remrk.
**       ELSE.
**         SELECT SINGLE * FROM t001k WHERE bwkey = <wa>-werks
**                                      AND bukrs = zmm_mems-bukrs.
**         IF sy-subrc NE 0.
**           CONCATENATE 'Plant'
**                       <wa>-werks
**                     'does not belong to Company code' zmm_mems-bukrs
**                       INTO l_remrk SEPARATED BY space.
**           MOVE l_remrk TO <wa>-remrk.
**           CLEAR l_remrk.
**         ENDIF.
*       ENDIF.
*
**       CLEAR l_agr_users.
**       SELECT SINGLE * FROM agr_users
**                    INTO l_agr_users
**                    WHERE agr_name = 'D:MM_MAT_IND_APPROVE_02'
**                      AND uname    = <wa>-bname.
**
**       IF sy-subrc NE 0.
**         CONCATENATE 'User'
**                     <wa>-bname
**                   'does not have MRP role'
**                     INTO l_remrk SEPARATED BY space.
**         MOVE l_remrk TO <wa>-remrk.
**         CLEAR l_remrk.
**       ENDIF.
*
*       CLEAR l_value.
*       l_value = <wa>-matnr+0(2).
*       IF l_value NE '0C'.
*         CLEAR t149d.
*         SELECT SINGLE * FROM t149d WHERE bwtar = <wa>-bwtar.
*         IF sy-subrc NE 0.
*           CONCATENATE 'Valuation type'
*                        <wa>-bwtar
*                       'does not exist - check your entry'
*                       INTO l_remrk SEPARATED BY space.
*           MOVE l_remrk TO <wa>-remrk.
*           CLEAR l_remrk.
*         ENDIF.
*
*         CLEAR l_trip.
*         l_trip = <wa>-bwtar+0(3).
*         IF l_value GE '01' AND l_value LE '16'.
*           IF l_trip NE 'STI'.
*             <wa>-remrk = text-012.
*           ENDIF.
*         ELSEIF l_value GE '21' AND l_value LE '42'.
*           IF l_trip NE 'SPI'.
*             <wa>-remrk = text-013.
*           ENDIF.
*         ENDIF.
*       ELSE.
*         IF l_value EQ '0C'.
*           IF <wa>-bwtar NE 'BATCH_MNGD'."'Batch Managed'.
*             <wa>-remrk = text-011.
*           ENDIF.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*     MODIFY <table> FROM <wa> INDEX l_tabix.
*   ENDLOOP.
*
*   DATA : answer.
*   REFRESH temp.
*   CLEAR temp.
*
*   LOOP AT <table> ASSIGNING <wa>.
*     temp-remrk = <wa>-remrk.
*     APPEND temp.
*     CLEAR temp.
*   ENDLOOP.
*
*   DELETE temp WHERE remrk EQ space.
*
*   IF temp[] IS INITIAL.
*
*
*     CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
*          EXPORTING
*               defaultoption = 'Y'
*               textline1     = 'Do you want to save the request?'
*               titel         = 'Information'
*               start_column  = 25
*               start_row     = 6
*          IMPORTING
*               answer        = ans.
*     CASE ans.
*       WHEN 'J'.
*         PERFORM save_9081.
*       WHEN 'N'.
** do nothing
*     ENDCASE.
*
*   ELSE.
*     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*               titel     = 'Information'
*               textline1 = text-016.
**     IF sy-subrc EQ 0.
**       CLEAR fcode.
**     ENDIF.
*
*   ENDIF.
*
* ENDFORM.                    " FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*&      Form  validate_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form validate_records.

*   DATA: l_mecs      TYPE zmm_uom_d.
*   DATA: l_remrk(60) TYPE c.
*   DATA: l_matnr     LIKE mara-matnr.
*   DATA: l_value(2)  TYPE  c.
*   DATA: l_trip(3)   TYPE  c.
*   DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
*   DATA: l_mstae     TYPE mara-mstae.
*   DATA: l_agr_users TYPE agr_users.
*   DATA: zseqwrk TYPE TABLE OF zseqwrk WITH HEADER LINE.
*   DATA: l_bwtar TYPE bwtar_d.
*   DATA: t001w   LIKE  t001w.
*   DATA: plants TYPE marc_werk OCCURS 0 WITH HEADER LINE.
*   DATA: general_data LIKE bapimatdoa.
*   DATA: return LIKE bapireturn.
*   DATA: plantdata LIKE bapimatdoc.
*   DATA: valuationdata LIKE bapimatdobew.
*   DATA: l_views(1) type n.                                 "+rk003
*
*   clear l_views.
*   IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.
*
*     IF g_ok_80 EQ 'CREATE'.
*       SELECT SINGLE * FROM zmm_uom_d INTO l_mecs
*                       WHERE matnr = wa_zmm_uom_d-matnr
*                         AND werks = wa_zmm_uom_d-werks.
**                         AND bwtar = zmm_mecs-bwtar.
*       IF sy-subrc EQ 0.
*         IF l_mecs-sflag EQ 'C'.
*           wa_zmm_uom_d-remrk = text-010.  "Already extended
*           EXIT.
**         ELSEIF l_mecs-sflag EQ 'N'.   "-RK002
*         ELSEIF l_mecs-sflag EQ 'N' OR l_mecs-sflag EQ 'P'.
*           CONCATENATE 'Material is already included in request no '
*                        l_mecs-docno  INTO l_remrk SEPARATED BY space.
*           MOVE l_remrk TO wa_zmm_uom_d-remrk.
*           CLEAR l_remrk.
*           EXIT.
**         ENDIF.
**       ENDIF.
**     ENDIF.

 endform.                    " validate_records
*&---------------------------------------------------------------------*
*&      Form  GET_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_itab_data.

*   DATA: l_itab TYPE TABLE OF zmm_uom_d WITH HEADER LINE..

*   CLEAR ZMM_MEMS.
*   SELECT SINGLE * FROM zmm_uom_h into wa_zmm_uom_h
*       WHERE docno = g_docno.
*
*   IF g_ok_80 EQ 'CHANGE'.
*
*     IF wa_zmm_uom_h-sflag EQ 'C'.
*
*       CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*            EXPORTING
*                 titel     = 'Error'
*                 textline1 = 'Request cannot be changed at this stage'
*                 textline2 = 'The request has been completed'.
*
*       SET SCREEN 9080.
*
*     ELSEIF wa_zmm_uom_h-sflag EQ 'P'.
*
*       CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*            EXPORTING
*                 titel     = 'Error'
*                 textline1 = 'Request cannot be changed at this stage.'
*                 textline2 = 'The request is under process.'.
*
*       SET SCREEN 9080.
*
*
*     ELSE.
*
*       CLEAR : l_itab.
*       SELECT * FROM zmm_uom_d INTO CORRESPONDING FIELDS OF TABLE
*                l_itab  WHERE docno = g_docno.
*
*       LOOP AT l_itab.
*         MOVE-CORRESPONDING l_itab TO g_tc_81_wa.
*         APPEND g_tc_81_wa TO g_tc_81_itab.
*       ENDLOOP.
*
*       SET SCREEN 9081.
*
*     ENDIF.
*
*   ELSE.

   clear : l_itab.
   select * from zmm_uom_d into corresponding fields of table
            l_itab  where docno = g_docno.

   loop at l_itab.
     move-corresponding l_itab to g_tc_81_wa.
     append g_tc_81_wa to g_tc_81_itab.
   endloop.

*     SET SCREEN 9081.

*   ENDIF.


 endform.                    " GET_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form check_user.

   data: l_uom_h type zmm_uom_h.

   if not ( wa_zmm_uom_h-docno is initial ).

     select single * from zmm_uom_h into l_uom_h
                where docno = wa_zmm_uom_h-docno.

     if sy-uname <> l_uom_h-ernam.
       if g_ok_80 eq 'CHANGE'.
         message s353.
         leave to screen 9080.
       elseif g_ok_80 eq 'DELETE'.
         message s358.
         leave to screen 9080.
       endif.
     endif.
   endif.
 endform.                    " CHECK_USER
*&---------------------------------------------------------------------*
*&      Form  get_commitment_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_commitment_number.

*   DATA: l_valclass  TYPE zmm_valclass.
*   DATA: l_konts     TYPE t030-konts.
*   DATA: l_fipos     TYPE skb1-fipos.
*
*
*   CLEAR l_valclass.
*   CLEAR zmm_mecs-fipos.
*
*   SELECT SINGLE * FROM zmm_valclass
*                   INTO l_valclass
*       WHERE matnr_from LE zmm_mecs-matnr AND
*             matnr_to   GE zmm_mecs-matnr AND
*             val_type   EQ space.
*
*   IF sy-subrc EQ 0.
*     CLEAR l_konts.
*     SELECT SINGLE konts INTO l_konts
*     FROM t030 WHERE ktosl = 'BSX'
*                 AND bwmod = 'ONGC'
*                 AND bklas  = l_valclass-val_class.
*     IF sy-subrc EQ 0.
*       CLEAR l_fipos.
*       SELECT SINGLE fipos INTO l_fipos
*       FROM skb1 WHERE saknr = l_konts
*                   AND bukrs = zmm_mems-bukrs.
*       IF sy-subrc EQ 0.
*         MOVE l_fipos TO zmm_mecs-fipos.
*         CLEAR l_fipos.
*       ENDIF.
*     ENDIF.
*   ENDIF.

 endform.                    " get_commitment_number
*&---------------------------------------------------------------------*
*&      Form  GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_delete_itab_data.

   data: l_delete type table of zmm_uom_d with header line.
   data: l_ans.

*   SELECT SINGLE * FROM zmm_uom_h into wa_zmm_uom_h
*   WHERE docno = g_docno.
*
*   IF wa_zmm_uom_h-sflag EQ 'C'.
*
*     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*               titel     = 'Error'
*               textline1 = 'Request cannot be deleted.'
*               textline2 = 'The request has been completed'.
*
*     SET SCREEN 9080.
*
*   ELSEIF wa_zmm_uom_h-sflag EQ 'P'.
*
*     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*               titel     = 'Error'
*               textline1 = 'Request cannot be deleted at this stage.'
*               textline2 = 'The request is under process.'.
*
*     SET SCREEN 9080.
*
*   ELSE.

*     CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
*          EXPORTING
*               defaultoption = 'Y'
*               textline1     = 'Delete the Document'
*               textline2     = 'You will lose the Document data'
*               titel         = 'Confirmation'
*               start_column  = 25
*               start_row     = 6
*          IMPORTING
*               answer        = l_ans.
*
*     IF l_ans EQ 'J'.

*       CLEAR : l_delete.
*
*       SELECT * FROM zmm_uom_d INTO CORRESPONDING FIELDS OF TABLE
*             l_delete  WHERE docno = g_docno.
*
*       IF sy-subrc EQ 0.
*
*         READ TABLE l_delete WITH KEY sflag = 'P'.
*
*         IF sy-subrc NE 0.
*
*           DELETE FROM zmm_uom_h WHERE docno = g_docno.
*
*           DELETE zmm_uom_d FROM TABLE l_delete.
*
*           IF sy-subrc EQ 0.
*             MESSAGE s356(zmm).
*           ENDIF.
*         ELSE.
*           MESSAGE s357(zmm).
*         ENDIF.
*
*       ENDIF.


*     SET SCREEN 9080.





 endform.                    " GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  fcode_copy_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
 form fcode_copy_row using    p_tc_name
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

* delete marked lines                                                  *
   describe table <table> lines <tc>-lines.

   loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
     assign component p_mark_name of structure <wa> to <mark_field>.

     if <mark_field> = 'X'.
       clear <mark_field>.
       append  <wa> to <table>. "INDEX syst-tabix.
       clear <mark_field>.
       if sy-subrc = 0.
         <tc>-lines = <tc>-lines + 1.
       endif.
     endif.
   endloop.
 endform.                    " fcode_copy_row
*&---------------------------------------------------------------------*
*&      Form  confirm_user_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form confirm_user_action.

   data : ans.

   if g_ok_80 eq 'CREATE' or g_ok_80 eq 'CHANGE'.
     if not ( g_tc_81_itab is initial ).
       call function 'POPUP_TO_CONFIRM'
            exporting
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
            importing
                 answer                = ans
            exceptions
                 text_not_found        = 1
                 others                = 2.
       if sy-subrc <> 0.
         message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       endif.

       case ans.
         when '1'.
           leave to screen 9080.
       endcase.
     else.
       leave to screen 9080.
     endif.
   else.
     leave to screen 9080.
   endif.
 endform.                    " confirm_user_action
*&---------------------------------------------------------------------*
*&      Form  pfstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form pfstatus.

*   CASE g_ok_80.
*
*     WHEN 'DELETE'.
*       CLEAR tab.
*       MOVE 'CHANGE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*       MOVE 'DISPLAY' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*     WHEN 'CHANGE'.
*       CLEAR tab.
*       MOVE 'DELETE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*       MOVE 'DISPLAY' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*     WHEN 'DISPLAY'.
*       CLEAR tab.
*       MOVE 'DELETE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*       MOVE 'CHANGE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*   ENDCASE.

   set pf-status 'ZMM03'  .

 endform.                    " pfstatus
*&---------------------------------------------------------------------*
*&      Form  delete_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form delete_data_base.
   delete zmm_uom_d  from table ist_del.
 endform.                    " delete_data_base
*&---------------------------------------------------------------------*
*&      Form  get_matnr_desc
*&---------------------------------------------------------------------*
*       FETCH MATERIAL DESC ROUTINE
*----------------------------------------------------------------------*
*      -->P_ZMM_MECS_MATNR  text
*----------------------------------------------------------------------*
 form get_matnr_desc using p_matnr.
   clear :wa_makt.

   if not p_matnr is initial.

     call function 'MAKT_SINGLE_READ'
          exporting
               matnr      = p_matnr
               spras      = 'E'
          importing
               wmakt      = wa_makt
          exceptions
               wrong_call = 1
               not_found  = 2
               others     = 3.
     if sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     endif.
   endif.
 endform.                    " get_matnr_desc
*&---------------------------------------------------------------------*
*&      Form  get_uom_conv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC_81_WA_MEINS  text
*----------------------------------------------------------------------*
 form get_uom_conv using    p_g_tc_81_wa_meins.
   types: begin of  ty_t006,
           msehi type t006-msehi,
           zaehl type t006-zaehl,
           nennr type t006-nennr,
           exp10 type t006-exp10,
           addko type t006-addko,
           mseh3 type t006a-mseh3,
          end   of  ty_t006.

   data: itab_uom  type table of ty_t006.

   data: wa_uom type  ty_t006.
   data: l_factor  type f.
   data: l_dimid type t006-dimid.
   data: l_mssie type t006d-mssie.

*break cab_mansuri.
   data: l_val1 type p decimals 4 value '10000'.
   data: l_val2 type p decimals 4 value '.0001'.
   data: l_zaehl type t006-zaehl.
   data: l_nennr type t006-nennr.
   data: wa_zaehl type t006-zaehl.
   data: wa_nennr type t006-nennr.
   data: wa_exp10 type t006-exp10.
   data: wa_addko type t006-addko.

   data: l_exp10 type t006-exp10.
   data: l_addko type t006-addko.

   data: l_conv_factor  type f ."p DECIMALS 4.
   data: l_len  type i.
   check not  p_g_tc_81_wa_meins is initial.

   refresh itab_uom.
*break cab_mansuri.

   select single dimid into l_dimid from t006 where
       msehi = p_g_tc_81_wa_meins.


   if sy-subrc = 0.

     select single mssie into l_mssie from t006d where
        dimid = l_dimid.
     if sy-subrc = 0.

       select  msehi zaehl nennr exp10 addko into
       corresponding fields of  table itab_uom
       from t006
       where  dimid =  l_dimid.

       read table itab_uom into wa_uom with key
       msehi = p_g_tc_81_wa_meins.
       wa_zaehl = wa_uom-zaehl.
       wa_nennr = wa_uom-nennr.
       wa_exp10 = wa_uom-exp10.
       wa_addko = wa_uom-addko.
*

       clear: wa_zmm_uom_d-uom_str1,wa_zmm_uom_d-uom_str2,l_len.
       delete itab_uom where msehi = p_g_tc_81_wa_meins.


       loop at itab_uom into wa_uom  .

         clear: l_zaehl, l_nennr,l_exp10, l_addko, l_conv_factor.

         select single  zaehl nennr exp10 addko  into
           (l_zaehl, l_nennr, l_exp10, l_addko)
           from t006
           where msehi = wa_uom-msehi and  dimid =  l_dimid.
         break cab_mansuri.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
*           select single mseh3 into wa_uom-mseh3 from t006a
*              where msehi = wa_uom-msehi.
          select mseh3 into wa_uom-mseh3 UP TO 1 ROWS from t006a
              where msehi = wa_uom-msehi ORDER BY PRIMARY KEY.
            ENDSELECT.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
           l_conv_factor =
           ( l_zaehl / l_nennr ) * 10 ** l_exp10  + l_addko.

           l_factor =
           ( ( wa_zaehl / wa_nennr ) * 10 ** wa_exp10 + wa_addko )
            / l_conv_factor  .
*.


         if l_factor > l_val1 .
         else.
           if l_factor < l_val2 and l_factor > 0.
           else.
             l_len = strlen(  wa_zmm_uom_d-uom_str1 )  .
             if l_len < 120.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
               concatenate wa_uom-mseh3  wa_zmm_uom_d-uom_str1  "#EC CI_NOORDER
               into wa_zmm_uom_d-uom_str1 separated by ',' .
             else.
               concatenate wa_uom-mseh3 wa_zmm_uom_d-uom_str2    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
               into wa_zmm_uom_d-uom_str2 separated by ',' .
             endif.
           endif.
         endif.
       endloop.
     endif.
   endif.
 endform.                    " get_uom_conv

*--- INCLUDE: MZMMUOMI01 ---*
***INCLUDE MZMMMERI01 .

*---------------------------------------------------------------------*
*       MODULE TC_81_modify INPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module tc_81_modify input.

*  PERFORM get_commitment_number.

*  PERFORM validate_records.

*  IF NOT ( zmm_mecs IS INITIAL ).
*    zmm_mecs-dismm = 'ND'.
*  ENDIF.

  move-corresponding wa_zmm_uom_d to g_tc_81_wa.


  modify g_tc_81_itab  from g_tc_81_wa  index tc_81-current_line.

  if sy-subrc ne 0.
    append g_tc_81_wa to g_tc_81_itab.
  endif.

  delete g_tc_81_itab  where matnr eq space.

endmodule.

*---------------------------------------------------------------------*
*       MODULE TC_81_mark INPUT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module tc_81_mark input.
  if tc_81-line_sel_mode = 1 and
     g_tc_81_wa-flag = 'X'.
    loop at g_tc_81_itab into g_tc_81_wa where flag = 'X'.
      g_tc_81_wa-flag = ''.
      modify g_tc_81_itab from g_tc_81_wa transporting flag.
    endloop.
    g_tc_81_wa-flag = 'X'.
  endif.
  modify g_tc_81_itab from g_tc_81_wa index tc_81-current_line
    transporting flag.
endmodule.

*---------------------------------------------------------------------*
*       MODULE TC_81_user_command INPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module tc_81_user_command input.
  ok_code = sy-ucomm.
  perform user_ok_tc using    'TC_81'
                              'G_TC_81_ITAB'
                              'FLAG'
                     changing ok_code.
  sy-ucomm = ok_code.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module exit input.

  refresh g_tc_81_itab.
  clear g_tc_81_wa.
  clear g_tc_81_copied.

  if sy-dynnr eq 9080.
    leave program.
  else.
    leave to  screen 9080.
  endif.
endmodule.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9081  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_9081 input.
  g_ok_81 = sy-ucomm.
  case g_ok_81.
    when 'SAVE'.
      perform save_9081.
    when 'BACK' or 'EXIT' or 'CANCEL'.
      perform confirm_user_action.
  endcase.


endmodule.                 " USER_COMMAND_9081  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9080  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_9080 input.
  g_ok_80 = sy-ucomm.
  case g_ok_80.
    when 'CREATE'.
      perform assign_sy_values.
      leave to screen 9081.
    when 'CHANGE'.
      leave to screen 9082.
    when 'DISPLAY'.
      leave to screen 9082.
    when 'DELETE'.
      leave to screen 9082.
    when 'BACK' or 'EXIT' or 'CANCEL'.
      leave program.
  endcase.
endmodule.                 " USER_COMMAND_9080  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9082  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_9082 input.

  g_ok_82 = sy-ucomm.

  move g_docno to wa_zmm_uom_h-docno.

  Select single * into wa_zmm_uom_h  from zmm_uom_h where
     docno = g_docno.

  If sy-subrc = 0.
    perform get_itab_data.
    call screen 9081.
  Else.

     message i360(ZMM) with g_docno.
       clear g_docno.
  endif.

*  case g_ok_82.
*    when 'CHANGE' or 'DISPLAY'.
*      perform get_itab_data.
**      fcode = 'SAVE'.
**      LEAVE SCREEN.
*       call screen 9081.
*    when 'DELETE'.
*      perform get_delete_itab_data.
**      LEAVE SCREEN.
*       call screen 9081.
*
*    when 'BACK' or 'EXIT' or 'CANCEL'.
**      SET SCREEN 9080.
**      LEAVE SCREEN.
*       leave to screen 9080.
*  endcase.


endmodule.                 " USER_COMMAND_9082  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_user input.
  if g_ok_80 eq 'CHANGE' or g_ok_80 eq  'DELETE'.
    perform check_user.
  endif.

endmodule.                 " check_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VALUE_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  check_matnr  INPUT
*&---------------------------------------------------------------------*
*       check material validity routine
*----------------------------------------------------------------------*
module check_matnr input.

check not wa_zmm_uom_d-matnr is initial.

  call function 'MARA_READ'
       exporting
            i_matnr  = wa_zmm_uom_d-matnr
       exceptions
            no_entry = 1
            others   = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  read table g_tc_81_itab into g_tc_81_wa
  with key matnr = wa_zmm_uom_d-matnr.
  if sy-subrc = 0.
     clear wa_zmm_uom_d-matnr.
     message e366(zmm).
  endif.

  Clear: wa_zmm_uom_d-meinh, wa_zmm_uom_d-umrez.
  Select single  MEINS into
    wa_zmm_uom_d-meins  from MARA
  where matnr = wa_zmm_uom_d-matnr.

*  if wa_zmm_uom_d-meins = 'NO'.
*     message e367(zmm) with wa_zmm_uom_d-matnr.
*  endif.


endmodule.                 " check_matnr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_plant input.
select single * from t001w where
    werks = wa_zmm_uom_h-werks.
if sy-subrc <> 0.
   message e020(zmm) with wa_zmm_uom_h-werks.
endif.
endmodule.                 " check_plant  INPUT

*--- INCLUDE: MZMMUOMO01 ---*
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
  tc_81-lines = 999.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_81_move OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_move OUTPUT.


  MOVE-CORRESPONDING g_tc_81_wa TO wa_zmm_uom_d.

**  IF g_ok_82 NE 'DISPLAY'.
**    IF NOT ( zmm_mecs-remrk IS INITIAL ).
**      CALL FUNCTION 'ICON_CREATE'
**           EXPORTING
**                name   = 'ICON_LED_RED'
**           IMPORTING
**                result = icon.
**    ENDIF.
**  ENDIF.

  MOVE g_lines TO tc_lines.

  IF NOT ( g_tc_81_wa IS INITIAL ).
    MOVE tc_81-current_line TO tc_81_line.
  ENDIF.

ENDMODULE.

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
  SET PF-STATUS 'ZMM02'  .
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9081  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9080 OUTPUT.
  SET PF-STATUS 'ZMM01' .
  SET TITLEBAR '001' WITH text-014 .
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

    WHEN 'DISPLAY' or 'DELETE'.

      LOOP AT tc_81-cols INTO htc_cols.
        htc_cols-screen-input = 0.
        MODIFY tc_81-cols FROM htc_cols.
      ENDLOOP.
      LOOP AT SCREEN.
        screen-input = 0.
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
ENDMODULE.                 " refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  srn_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE srn_81_attr OUTPUT.

  IF g_ok_80 EQ 'CHANGE'.
    LOOP AT SCREEN.
      IF screen-name = 'WA_ZMM_UOM_H-DOCNO' OR
         screen-name = 'WA_ZMM_UOM_H-ERSDA'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF g_ok_80 EQ 'CREATE'.
    LOOP AT SCREEN.
      IF screen-name = 'WA_ZMM_UOM_H-DOCNO' or
         screen-name = 'WA_ZMM_UOM_H-ERSDA' .
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF g_ok_80 EQ 'DISPLAY' or g_ok_80 EQ 'DELETE'.
    LOOP AT SCREEN.
      IF screen-group2 = 'VIW'.
        screen-invisible = 1.
      ELSE.
        screen-input = 0.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " srn_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  move_docno  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_docno OUTPUT.
  MOVE g_docno TO wa_zmm_uom_h-docno.
ENDMODULE.                 " move_docno  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_req_flds  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_req_flds OUTPUT.
Perform get_matnr_desc using g_tc_81_wa-matnr.

Check g_ok_80 = 'CREATE'.
Data: l_dimid type t006-dimid.
Clear l_dimid.

   SELECT SINGLE dimid INTO l_dimid FROM t006 WHERE
       msehi = g_tc_81_wa-meins.

If g_tc_81_wa-meins = 'NO' OR
   l_dimid = 'AAAADL'.
   wa_zmm_uom_d-uom_str1 = 'NON CONVERTIBLE UOM'.
Else.
Perform get_uom_conv   using g_tc_81_wa-meins.
Endif.
loop at screen.
 if screen-group2 EQ 'REQ' and wa_makt-maktx <> ' ' and
    screen-required = '0'.
  screen-required = '1'.
  modify screen.
  exit.
 endif.
endloop.

ENDMODULE.                 " set_req_flds  OUTPUT

*--- INCLUDE: MZMMUOMTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMUOMTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

program  sapmzmmuom message-id zmm.

tables:  mara, t001w, t006 .

types: begin of t_tc_81,
         matnr like ZMM_MECS-MATNR,
         maktx like makt-maktx,
         meins like mara-meins,
*         meinh LIKE SMEINH-MEINH,
*         umrez LIKE SMEINH-UMREZ,
         ersda like zmm_mecs-ersda,
         ernam like zmm_mecs-ernam,
         laeda like zmm_mecs-laeda,
         aenam like zmm_mecs-aenam,
         uom_str1  type zmm_uom_d-uom_str1 ,
         uom_str2  type zmm_uom_d-uom_str2 ,

*         fipos LIKE zmm_mecs-fipos,
          flag,
       end of t_tc_81.

controls: tc_81 type tableview using screen 9081.

data:     g_tc_81_itab   type t_tc_81 occurs 0,
          g_tc_81_wa     type t_tc_81.

data:     g_tc_81_copied.
data:     g_tc_81_lines    like sy-loopc.
data:     ok_code          like sy-ucomm.

data:     g_ok_80          like sy-ucomm.
data:     g_ok_81          like sy-ucomm.
data:     g_ok_82          like sy-ucomm.

data:     g_lines          like sy-loopc.
data:     g_docno          like zmm_uom_h-docno.
*DATA:     g_text1(132)  type C.
*DATA:     g_text2(132)  type C.
data: htc_cols type cxtab_column.

data: fcode like rsmpe-func.
data: tc_81_line(3) type c.
data: tc_lines like sy-loopc.

data: rc        like inri-returncode,
      number(7) type c.

data: ist_zmm_uom_d type table of zmm_uom_d.
data: wa_zmm_uom_d  type zmm_uom_d.
data: wa_zmm_uom_h  type zmm_uom_h.

data:  ct_sort	type	lvc_t_sort.
data:  it_fieldcat type	lvc_t_fcat.
data:  wa_it type lvc_s_fcat.

data:  it_selected_cols	type	lvc_t_col.
data:  is_layout	       type	lvc_s_layo.
data:  is_selfield	       type	lvc_s_self.
data:  it_groups	       type	lvc_t_sgrp.
data:  ct_filter	       type	lvc_t_filt.

types: begin of tab_type,
        fcode like rsmpe-func,
      end of tab_type.

data: icon  like icons-text.

data: tab type standard table of tab_type with
               non-unique default key initial size 10,
      wa_tab type tab_type.

data : ist_del type table of zmm_uom_d with header line.
data :  l_itab type table of zmm_uom_d with header line..
data : wa_makt like makt.
