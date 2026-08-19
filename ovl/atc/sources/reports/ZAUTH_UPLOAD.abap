*--- MAIN PROGRAM: ZAUTH_UPLOAD ---*
REPORT Zauth_UPLOAD  .
************************************************************************
* Date        Transport     USERID     Description
* 13/09/2008  <RD1K960036>  SAB_PUNIT  1) Replaced obsolete FM 'UPLOAD'
************************************************************************
tables: zauth_head.

TYPES: BEGIN OF TY_SCHD,
         reqno(8) TYPE c,
         DESC(80) TYPE C,
       END OF TY_SCHD.
 DATA: IST_SCHD TYPE TABLE OF TY_SCHD WITH HEADER LINE.

 DATA: WA  TYPE ty_schd.
 data: wa_h  type  zauth_head.
* begin of <RD1K960036>
DATA : G_T_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
       G_FILETABLE  TYPE  FILE_TABLE,
       G_RC         TYPE  I,
       G_P_FILE     TYPE  STRING,
       G_usr_act    TYPE  I.

* CALL FUNCTION 'UPLOAD'
**  EXPORTING
**    CODEPAGE                      = ' '
**    FILENAME                      = ' '
**    FILETYPE                      = ' '
**    ITEM                          = ' '
**    FILEMASK_MASK                 = ' '
**    FILEMASK_TEXT                 = ' '
**    FILETYPE_NO_CHANGE            = ' '
**    FILEMASK_ALL                  = ' '
**    FILETYPE_NO_SHOW              = ' '
**    LINE_EXIT                     = ' '
**    USER_FORM                     = ' '
**    USER_PROG                     = ' '
**    SILENT                        = 'S'
**  IMPORTING
**    FILESIZE                      =
**    CANCEL                        =
**    ACT_FILENAME                  =
**    ACT_FILETYPE                  =
*   TABLES
*     data_tab                      = IST_SCHD[]
**  EXCEPTIONS
**    CONVERSION_ERROR              = 1
**    INVALID_TABLE_WIDTH           = 2
**    INVALID_TYPE                  = 3
**    NO_BATCH                      = 4
**    UNKNOWN_ERROR                 = 5
**    GUI_REFUSE_FILETRANSFER       = 6
**    OTHERS                        = 7
*           .
* IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
* ENDIF.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    EXPORTING
*      WINDOW_TITLE            =
*      DEFAULT_EXTENSION       =
*      DEFAULT_FILENAME        =
*      FILE_FILTER             =
*      WITH_ENCODING           =
*      INITIAL_DIRECTORY       =
*      MULTISELECTION          =
    CHANGING
      FILE_TABLE              = G_T_FILE_TABLE
      RC                      = G_RC
      USER_ACTION             = G_USR_ACT
*      FILE_ENCODING           =
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      others                  = 5
          .
  IF SY-SUBRC = 0 AND
     g_usr_act <>  CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
     LOOP AT g_t_file_table INTO g_filetable.
       MOVE g_filetable TO g_p_file.
       exit.
     ENDLOOP.
     CALL FUNCTION 'GUI_UPLOAD'
       EXPORTING
         FILENAME                      = g_p_file
*        FILETYPE                      = 'ASC'
*        HAS_FIELD_SEPARATOR           = ' '
*        HEADER_LENGTH                 = 0
*        READ_BY_LINE                  = 'X'
*        DAT_MODE                      = ' '
*        CODEPAGE                      = ' '
*        IGNORE_CERR                   = ABAP_TRUE
*        REPLACEMENT                   = '#'
*        CHECK_BOM                     = ' '
*        VIRUS_SCAN_PROFILE            =
*        NO_AUTH_CHECK                 = ' '
*      IMPORTING
*        FILELENGTH                    =
*        HEADER                        =
       TABLES
         DATA_TAB                      = IST_SCHD[]
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

  ELSE.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* end of <RD1K960036>

 Loop at ist_schd  into wa.

     Update zauth_head set remarks = wa-desc
        where auth_req_no = wa-reqno.

 Endloop.

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

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL

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
