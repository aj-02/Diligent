*--- MAIN PROGRAM: SAPMZMMEMD_ARCH ---*
*&---------------------------------------------------------------------
*& Module pool       SAPMZMMEMD                                        *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&
***********************************************************************
* Program    :  SAPMZMMEMD (MODULE POOL)                               *
*                                                                      *
*                                                                      *
* Title      :  Tracking of Tender Fee/EMD/SD                          *
*                                                                      *
*                                                                      *
* FS No.     :  FS-MM-PUR-002
*                                                                      *
*                                                                      *
* Author     :  SHIBU S                Date :  13.01.2004              *
*                                                                      *
* Login Id   :  CAB_SHIBU                                              *
*                                                                      *
*                                                                      *
* Description:  This program will be used for Receipt/Refund/Forfeit of
*                all Tender Fee/EMD/SD . Different actions based on
**               different instrument is incorporated.                 *
*
*                                                                      *
* Tran. Code :  ZMMEMD                                                 *
*                                                                      *
*                                                                      *
************************************************************************
* CHANGE HISTORY                                                       *
*                                                                      *
* Mod Date    Changed by    Description                 Chng ID        *
*                                                                      *
* 24.09.2004    SHIBU S      Addln Repot Added           +001          *
* 29.09.2004    SHIBU S      SRM Changes                 +002          *
* 02.02.2005    SHIBU S      Req.for return/invoke       +003          *
* 09.03.2005    SHIBU S      Payment Gateway Interface   +004          *
************************************************************************

************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Changes in Include MZMMEMDF01.
*
*
************************************************************************

************************************************************************
* CHANGE HISTORY                                                       *
*                                                                      *
* Mod Date    Changed by    Description                     Chng ID    *
*                                                                      *
* 13.03.2009    CAB_SPYADAV  Subroutine check_ebid_vednor     005      *
*                            commented for processing                  *
*                            & fetching data from SRM                  *
*                            4.0 using Z-program                       *
*                            ZMM_SRM_AUTO_PAYMENT_UPDATE               *
* 20.10.2010    CAB_SUDHIR   Cr No. 30004898                           *
*                                                                      *
* 18.02.2014    CAB_SPYADAV  Changes as per CR No.            007      *
*                            30010246                                  *
*                                                                      *
************************************************************************


*&---------------------------------------------------------------------*

*------------ TOP INCLUDE  -------------------------------------------*
INCLUDE MZMMEMD_ARCHTOP_ARCH.
* include mzmmemdtop                              .
*------------ TOP INCLUDE  -------------------------------------------*

*------------ PBO OF ALL THE SCREEN ----------------------------------*
INCLUDE MZMMEMD_ARCHO01_ARCH.
* include mzmmemdo01                              .
*---------------------------------------------------------------------*

*------------ PAI OF ALL THE SCREEN ----------------------------------*
INCLUDE MZMMEMD_ARCHI01_ARCH.
* include mzmmemdi01                              .
*---------------------------------------------------------------------*

*------------ SUBROTINE ---------- ----------------------------------*
INCLUDE MZMMEMD_ARCHF01_ARCH.
* include mzmmemdf01                              .
*---------------------------------------------------------------------*

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

*--- INCLUDE: IF_MESSAGE====================IT ---*

*--- INCLUDE: IF_T100_MESSAGE===============IT ---*

*--- INCLUDE: MZMMEMD_ARCHF01_ARCH ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMEMDF01                                                 *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With POPUP_TO_CONFIRM.
************************************************************************
*           Modification Log
************************************************************************
*  Date            Transport      USERID        Description
* 08/04/2009      <RD1K963111>    SAB_SARVANAN  Added radio button for EMD
*
* 1) Replaced Function Module K_KKB_POPUP_RADIO2 with K_KKB_POPUP_RADIO3
*    to give third radio button for EMD
* 12/06/2009      <RD1K964254>    SAB_SARVANAN  Added FM(ZMM_EMD_GET_STATUS_DETAILS)
*                                               to update & find the Header Status
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  clear_screen_0105
*&---------------------------------------------------------------------*
*      Clear Data from screen 105.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_screen_0105.
  REFRESH : ist_emddtl,
            ist_emddtl01,
            ist_emdhdr  ,
            ist_emddtl_t01.
  CLEAR : ok_code, prev_okcode , g_okhdr, g_reset, g_hstatus.
  CLEAR:
         zmm_emdhdr-trans    ,
         zmm_emdhdr-ebeln    ,
         zmm_emdhdr-ekgrp    ,
         zmm_emdhdr-currency ,
         zmm_emdhdr-amount   ,
         zmm_emdhdr-place    ,
         zmm_emdhdr-co_code  ,
         zmm_emdhdr-docno    ,
         zmm_emdhdr-ebidno   ,
         zmm_emdhdr-vendorno .

  CLEAR g_locname.
  CLEAR   ist_emddtl.
  CLEAR   wa_tc105  .
  CLEAR   wa_emddtl .
  CLEAR   wa_emddtl01.
  CLEAR : g_vcode  ,
          g_tendno ,
          g_ekgrp  ,
          g_vname  ,
          g_ans    ,
          g_sc_ans ,
          g_ttype   .
  CLEAR   g_amount .
  CLEAR   g_locname.
  CLEAR:   g_idocno .

  CLEAR:   g_mmret ,
          g_firet .

  CLEAR : zmm_emdhdr,
          wa_emdhdr.                          "+007
ENDFORM.                    " clear_screen_0105
*&---------------------------------------------------------------------*
*&      Form  GET_VENDORNO_TENDERNO
*&---------------------------------------------------------------------*
*       Get Vendorno and Tender no from table EKKO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_vendorno_tenderno.
  DATA: wa_ekpa  TYPE ekpa,
        l_lifnr  TYPE ekpa-lifn2 .
  CLEAR:  wa_ekpa,l_lifnr.


*+004
* Partner Fuction 'OA' is represented by 'BA' in table EKPA Hence
*checcking for partner fuction 'BA' in below Query
  IF  prev_okcode NE 'ECREA'.
    SELECT * FROM EKPA INTO WA_EKPA UP TO 1 ROWS
 WHERE EBELN = ZMM_EMDHDR-EBELN AND PARVW = 'BA'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc = 0.

      l_lifnr = wa_ekpa-lifn2 .

    ENDIF.
  ENDIF.

*+004
  IF NOT zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE * FROM ekko INTO wa_ekko
    WHERE ebeln = zmm_emdhdr-ebeln   .
********************************** Data From Open Text Server*******************************
    IF sy-subrc <> 0.
      PERFORM mm_ekko_arch.
      READ TABLE it_ekko_arch INTO wa_ekko_arch INDEX 1.
      IF sy-subrc EQ 0.
        wa_ekko-submi = wa_ekko_arch-submi.
        wa_ekko-lifnr = wa_ekko_arch-lifnr.
        wa_ekko-ekgrp = wa_ekko_arch-ekgrp.
      ENDIF.
      IF it_ekko_arch IS NOT INITIAL.
        MESSAGE 'PO is Already Archived' TYPE 'S'.
      ENDIF.
    ENDIF.
********************************** Data From Open Text Server*******************************

    IF sy-subrc NE 0.
      MESSAGE e275(zmm).
    ELSE.

*&--> Check whether COLLECTIVE no and VENDOR CODE exist in RFQ for TFS
      IF zmm_emdhdr-trans = 'TFS'.
        IF wa_ekko-submi IS INITIAL .
          MESSAGE e402(zmm) .
        ELSEIF wa_ekko-lifnr IS INITIAL.
          MESSAGE e403(zmm) .
        ENDIF.
*&--<
*&--> Check whether   VENDOR CODE exist in PO for EMD/SD

      ELSEIF zmm_emdhdr-trans = 'EMD' OR zmm_emdhdr-trans = 'SDT' .
        IF wa_ekko-lifnr IS INITIAL.
          MESSAGE e403(zmm) .
        ENDIF.
      ENDIF.
*&--<

*+004
      IF NOT l_lifnr IS INITIAL.
        wa_ekko-lifnr = l_lifnr .
      ENDIF.
*+004
      MOVE:
            wa_ekko-submi    TO zmm_emdhdr-tenderno,
            wa_ekko-lifnr    TO zmm_emdhdr-vendorno,
            wa_ekko-ekgrp    TO zmm_emdhdr-ekgrp   .
      MOVE:
            wa_ekko-lifnr    TO g_vcode   ,
            wa_ekko-submi    TO g_tendno  ,
            wa_ekko-ekgrp    TO g_ekgrp .

*&--> Get Vendor name from table LFB1.
      SELECT SINGLE * FROM lfa1 INTO wa_lfa1
            WHERE lifnr = wa_ekko-lifnr.
      MOVE wa_lfa1-name1  TO g_vname .
*&--<
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_VENDORNO_TENDERNO
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBELN
*&---------------------------------------------------------------------*
*       Check EBELN
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_ebeln.
  DATA: l_ebeln LIKE ekko-ebeln,
        l_bstyp LIKE ekko-bstyp.

*&--> Check for PO Document no if Tender fee select doc.with BSTYP =
*'A' Otherwise select doc. with  BSTYP = 'F'

  IF NOT zmm_emdhdr-trans IS INITIAL AND
    NOT zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE ebeln bstyp FROM ekko INTO (l_ebeln,l_bstyp)
           WHERE  ebeln = zmm_emdhdr-ebeln .

    IF sy-subrc NE 0.
      MESSAGE e468(zmm).
    ELSE.
      PERFORM check_document_type USING zmm_emdhdr-trans l_bstyp  .
    ENDIF.
  ENDIF.
*&--<
ENDFORM.                    " CHECK_EBELN
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCUMENT_TYPE
*&---------------------------------------------------------------------*
*       Check Document Type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_document_type USING p_trans p_bstyp.
  IF p_trans = 'TFS' OR p_trans = 'EMD'.
    IF p_bstyp NE 'A'.
      MESSAGE e400(zmm) WITH p_trans..
    ENDIF.
  ELSEIF  p_trans = 'SDT'.
    IF p_bstyp = 'F' OR p_bstyp = 'K' . "PO / Contract no
    ELSE.
      MESSAGE e401(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_DOCUMENT_TYPE
*&---------------------------------------------------------------------*
*&      Form  insert_record
*&---------------------------------------------------------------------*
*      Insert Record in Table Control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_record.
  DATA: l_next_line  TYPE i,
        l_lines      TYPE i  .
  CLEAR : l_next_line ,l_lines .
*& find total no of rec. in table control .
  DESCRIBE TABLE ist_emddtl LINES l_lines.
  l_next_line = l_lines + 1.
  IF NOT l_next_line IS INITIAL.
    INSERT INITIAL LINE INTO ist_emddtl  INDEX  l_next_line .
    READ TABLE ist_emddtl INTO wa_emddtl INDEX  l_next_line .
* Begin of <RD1K963111>
    wa_emddtl-rscode = wa_tc105-rscode.
* End of <RD1K963111>
    wa_emddtl-item_no = l_lines + 1.
    MODIFY ist_emddtl FROM wa_emddtl     INDEX  l_next_line .
    tc_105-lines = l_lines + 1 .
  ENDIF.
  SET CURSOR FIELD 'WA_TC105-INST_TYPE' LINE  tc_105-lines .
  CLEAR ok_code.
ENDFORM.                    " insert_record
*&---------------------------------------------------------------------*
*&      Form  delete_record
*&---------------------------------------------------------------------*
*      Delete Record from Table Control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_record.
  DATA:  l_curr_line ,
         l_next_line ,
         l_tabix LIKE sy-tabix .
  DATA l_lines TYPE i .
  CLEAR : l_curr_line,
          l_next_line,
          l_tabix    .
  REFRESH ist_del_emddtl .
  DESCRIBE TABLE ist_emddtl LINES g_line .
*  IF g_line = 1.
*    MESSAGE e414(zmm).
*  ENDIF.
** Changes 1.11.04

  LOOP AT ist_emddtl INTO wa_emddtl  WHERE sel = 'X'.
    l_lines = l_lines + 1.
  ENDLOOP.

  IF l_lines = 1 AND g_line = 1.
    LOOP AT ist_emddtl INTO wa_emddtl  WHERE sel = 'X'.
      wa_emddtl-sel = space.
      MODIFY ist_emddtl FROM wa_emddtl .
    ENDLOOP.

    MESSAGE e414(zmm).
  ENDIF.

  IF g_line = l_lines.
    LOOP AT ist_emddtl INTO wa_emddtl  WHERE sel = 'X'.
      wa_emddtl-sel = space.
      MODIFY ist_emddtl FROM wa_emddtl .
    ENDLOOP.
    MESSAGE e508(zmm).
  ENDIF.
*** end of change -----------------------------------------

  LOOP AT ist_emddtl INTO wa_emddtl
  WHERE sel = 'X' .
    APPEND wa_emddtl TO ist_del_emddtl.
  ENDLOOP.

  IF  NOT ist_emddtl IS INITIAL.
*&--< if user has selected multiple lines.
    LOOP AT ist_del_emddtl  INTO wa_emddtl.
      DELETE ist_emddtl  WHERE item_no = wa_emddtl-item_no.
      IF g_line > 1.
        tc_105-lines = tc_105-lines - 1.
      ELSE.
        CLEAR ist_emddtl .
        CLEAR wa_emddtl .
        wa_emddtl-item_no = '01'.
        APPEND wa_emddtl TO ist_emddtl .
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--< Reassign Item no
  LOOP AT ist_emddtl INTO wa_emddtl.
    wa_emddtl-item_no = sy-tabix .
    MODIFY ist_emddtl FROM wa_emddtl.
  ENDLOOP.
*&--<
  PERFORM calc_total_amount .
  CLEAR ok_code .
ENDFORM.                    " delete_record
*&---------------------------------------------------------------------*
*&      Form  fill_ist_emddtl
*&---------------------------------------------------------------------*
*       Append Item-no initaily into internal table ist_emddtl
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_ist_emddtl.
  REFRESH ist_emddtl.
  CLEAR ist_emddtl.
  CLEAR wa_emddtl.
  IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.         "+002
    wa_emddtl-item_no = '01'.
    APPEND wa_emddtl TO ist_emddtl.
  ENDIF.
ENDFORM.                    " fill_ist_emddtl
*&---------------------------------------------------------------------*
*&      Form  MODIFY_ISTTAB
*&---------------------------------------------------------------------*
*       Modify Internal table ist_tab.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_isttab.
  REFRESH ist_tab .
  CLEAR ist_tab   .
  CLEAR wa_tab    .

  IF ( prev_okcode = 'CREA' OR prev_okcode = 'ECREA' ) AND g_okhdr = 'X'.
    "+002
    MOVE 'DELT'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'    TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab     .
    MOVE 'HEAD'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'DOCU'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'IDTL'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'.
    MOVE 'SAVE'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE  'RESET'  TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'REST'.
    REFRESH ist_tab .
    MOVE 'SAVE'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'DELT'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.

  IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA' OR       "+002
     prev_okcode = 'CHAN' OR
    prev_okcode = 'DISP'.
    MOVE  'RESET'  TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'DELT'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'DELE' .
    MOVE 'RESET'   TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'DELE' AND ok_code = 'DELT'.
    MOVE 'DELE'    TO  wa_tab-fcode  .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'CHAN'.
    IF g_reset  = 0.
      MOVE 'RESET'   TO  wa_tab-fcode .
      APPEND wa_tab  TO  ist_tab      .
      MOVE 'DELT'    TO  wa_tab-fcode .
      APPEND wa_tab  TO  ist_tab      .
    ENDIF.
  ENDIF.
  IF  zmm_emdhdr-ebeln IS INITIAL.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'    TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'ME43'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ELSE.
  ENDIF.
  IF prev_okcode = 'REST'.
    MOVE 'SAVE'   TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'DELT'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.

  IF ( zmm_emdhdr-trans = 'TFS' OR  zmm_emdhdr-trans = 'EMD' ) AND NOT
zmm_emdhdr-ebeln IS INITIAL .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'   TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab    .
  ELSEIF (  zmm_emdhdr-trans = 'SDT' )
  AND NOT zmm_emdhdr-ebeln IS INITIAL.
    MOVE 'ME43'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
ENDFORM.                    " MODIFY_ISTTAB
*&---------------------------------------------------------------------*
*&      Form  APPEND_ISTTAB_100
*&---------------------------------------------------------------------*
*      Append Function codes into table ist_tab.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_100.
*&--> To Enable/Disable Icons in Application Tool bar

  REFRESH ist_tab .
  CLEAR wa_tab    .

  IF ok_code = 'CHAN' OR
     ok_code = 'DISP' OR
     ok_code = 'DELE' OR
     ok_code = 'REST' OR
     ok_code = 'BGLC' OR
     ok_code = 'AMEND'  .
    MOVE 'CHAN' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'CREA' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'ECREA' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DISP' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DELE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'REF' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'REST' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'RELS' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'BGLC' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'AMEND' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DELP' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
  ENDIF.
ENDFORM.                    " APPEND_ISTTAB_100
*&---------------------------------------------------------------------*
*&      Form  save_data
*&---------------------------------------------------------------------*
*       Save Header  Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data.
  CLEAR wa_emdhdr.
  CLEAR g_save_h .
  CLEAR g_save_i .
  DATA: l_bstyp LIKE ekko-bstyp.
  IF g_sc_ans = '1'  OR prev_okcode = 'CREA'.
*&--> Check Key Fields before Save.
    PERFORM check_key.
    wa_emdhdr-crby = sy-uname .
    wa_emdhdr-cron = sy-datum .
* Begin of <RD1K963113>
    IF prev_okcode = 'CHAN'.
      wa_emdhdr-chby = sy-uname .
      wa_emdhdr-chon = sy-datum .
    ENDIF.
* End of <RD1K963113>
*&--> Update Document Category and Status at Header Level.
    IF prev_okcode =  'CREA' OR  prev_okcode = 'CHAN'.
      IF zmm_emdhdr-trans = 'TFS'  OR zmm_emdhdr-trans = 'EMD' .
        MOVE  'A' TO  wa_emdhdr-bstyp  .
      ELSEIF   zmm_emdhdr-trans = 'SDT' .
        CLEAR l_bstyp .

        SELECT SINGLE bstyp FROM ekko INTO l_bstyp
          WHERE ebeln = zmm_emdhdr-ebeln.
        MOVE  l_bstyp TO wa_emdhdr-bstyp .

*+007 : Start
        MOVE zmm_emdhdr-loa_no         TO wa_emdhdr-loa_no.
        MOVE zmm_emdhdr-loa_dt         TO wa_emdhdr-loa_dt.
        MOVE zmm_emdhdr-sd_pbg_dt      TO wa_emdhdr-sd_pbg_dt.
        MOVE zmm_emdhdr-sd_pbg_rcpt_dt TO wa_emdhdr-sd_pbg_rcpt_dt.
        MOVE zmm_emdhdr-apprv_chk      TO wa_emdhdr-apprv_chk.

        IF zmm_emdhdr-apprv_chk = 'Y'.
          MOVE zmm_emdhdr-apprv_by       TO wa_emdhdr-apprv_by.
          MOVE zmm_emdhdr-apprv_on       TO wa_emdhdr-apprv_on.
          MOVE zmm_emdhdr-remarks        TO wa_emdhdr-remarks.
        ENDIF.

        IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
           NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

          IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'N'.

            MOVE '0'  TO  wa_emdhdr-status .

          ENDIF.

        ENDIF.
*+007 : End

      ENDIF.
    ENDIF.
*&--<
    IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.       "+002

*+007 : Start
      IF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'SDT'.

        IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
           NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

          IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'N'.

            MOVE '0'  TO  wa_emdhdr-status .

          ELSE.

            MOVE 'N'  TO  wa_emdhdr-status .

          ENDIF.

        ELSE.

          MOVE 'N'  TO  wa_emdhdr-status .

        ENDIF.

      ELSE.

*+007 : End

        MOVE 'N'  TO  wa_emdhdr-status .

      ENDIF.                                        "+007

    ELSEIF prev_okcode = 'CHAN'.
**---------- Update  Header Level Status -----------------------*

*+007 : Start
      IF zmm_emdhdr-trans = 'SDT'.

        IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
           NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

          IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'N'.

            MOVE '0'  TO  wa_emdhdr-status .

          ELSE.

            PERFORM update_header_status .
            MOVE g_h_status  TO  wa_emdhdr-status .
            CLEAR g_h_status.

          ENDIF.

        ELSE.

          PERFORM update_header_status .
          MOVE g_h_status  TO  wa_emdhdr-status .
          CLEAR g_h_status.

        ENDIF.

      ELSE.
*+007 : End
        PERFORM update_header_status .
        MOVE g_h_status  TO  wa_emdhdr-status .
        CLEAR g_h_status.
      ENDIF. "+007

    ENDIF.
    MOVE zmm_emdhdr-co_code  TO  wa_emdhdr-co_code  .
    MOVE zmm_emdhdr-currency TO  wa_emdhdr-currency .
    MOVE zmm_emdhdr-place    TO  wa_emdhdr-place    .
    IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.       "+002
      MOVE g_docno             TO  wa_emdhdr-docno    .
    ELSEIF prev_okcode = 'CHAN'.
      MOVE g_idocno             TO  wa_emdhdr-docno    .
    ENDIF.
    MOVE g_amount            TO  wa_emdhdr-amount   .
    MOVE zmm_emdhdr-trans    TO  wa_emdhdr-trans    .
    MOVE zmm_emdhdr-ebeln    TO  wa_emdhdr-ebeln    .
    MOVE g_ekgrp             TO  wa_emdhdr-ekgrp    .
***SRM Changes  +002
    IF zmm_emdhdr-vendorno IS INITIAL.
      MOVE g_vcode            TO  wa_emdhdr-vendorno .
    ELSE.
      MOVE zmm_emdhdr-vendorno  TO  wa_emdhdr-vendorno .
      g_vcode =  zmm_emdhdr-vendorno .
    ENDIF.
***End of SRM Change
    MOVE g_tendno            TO  wa_emdhdr-tenderno .
    MOVE zmm_emdhdr-ebidno   TO  wa_emdhdr-ebidno .         "+002

    IF prev_okcode = 'CREA'.
      MOVE g_docno             TO  wa_emdhdr-docno    .
    ELSEIF prev_okcode = 'CHAN'.
      MOVE g_idocno             TO  wa_emdhdr-docno    .
* Begin of <RD1K963113>
      wa_emdhdr-chby = sy-uname .
      wa_emdhdr-chon = sy-datum .
* End of <RD1K963113>
    ENDIF.
*-------------------------------------------------------------*
** SRM Changes
    IF prev_okcode = 'ECREA' OR g_ttype = 'SRM'.
      MOVE 'SRM' TO wa_emdhdr-trtyp.
    ELSEIF prev_okcode = 'CREA' OR g_ttype = 'R3'.
      MOVE 'R3' TO wa_emdhdr-trtyp.
    ENDIF.
*-------------------------------------------------------------*

    MODIFY  zmm_emdhdr FROM wa_emdhdr.
    PERFORM pass_to_srm.
    IF sy-subrc = 0.
      g_save_h = 0.
    ELSE.
      g_save_h = 1.
    ENDIF.
    IF prev_okcode = 'CHAN'.
      wa_emdhdr-docno = g_idocno.
      SORT ist_del_emddtl BY item_no .
    ENDIF.
    REFRESH: ist_del_emddtl .
    IF NOT ist_emddtl01 IS INITIAL.
      MODIFY zmm_emddtl FROM TABLE ist_emddtl01.
      IF sy-subrc = 0.
        g_save_i = 0.
      ELSE.
        g_save_i = 1.
      ENDIF.
    ELSE.
      g_save_i = 1.
    ENDIF.
  ENDIF.


ENDFORM.                    " save_data
*&---------------------------------------------------------------------*
*&      Form  insert_itemdtl
*&---------------------------------------------------------------------*
*    Insert Item Data into Internal Table ist_emddtl01
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_itemdtl.
  REFRESH ist_emddtl01.
  CLEAR  wa_emddtl01  .
  CLEAR  g_amount .
  DATA : l_bstyp .
  "commented by lipsy on 09.08.2012 for addition of etender
                                                            "RD1K981279
*  IF prev_okcode =  'CREA' OR  prev_okcode = 'CHAN'.
                                                            "RD1K981279
  "end of comment by lipsy on 09.08.2012 for addition of etender
  ""added by lipsy on 09.08.2012 for addition of etender
                                                            "RD1K981279
  IF prev_okcode =  'CREA' OR  prev_okcode = 'CHAN' OR prev_okcode =  'ECREA'.
                                                            "RD1K981279
    "end of addition  by lipsy on 09.08.2012 for addition of etender
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD' .
      MOVE  'A' TO  wa_emdhdr-bstyp  .
    ELSEIF  zmm_emdhdr-trans = 'SDT' .
      SELECT SINGLE bstyp FROM ekko INTO l_bstyp
       WHERE ebeln = zmm_emdhdr-ebeln.
      MOVE l_bstyp  TO wa_emdhdr-bstyp .
    ENDIF.
  ENDIF.
  IF prev_okcode =  'CREA' .
    MOVE 'N'  TO  wa_emdhdr-status .
  ENDIF.
  LOOP AT ist_emddtl INTO wa_emddtl .
    g_amount  = g_amount + wa_emddtl-amount    .
    MOVE-CORRESPONDING wa_emddtl TO    wa_emddtl01           .
    IF wa_emddtl-status IS INITIAL.
      MOVE 'N'                  TO    wa_emddtl01-status    .
    ELSE.
      MOVE wa_emddtl-status     TO   wa_emddtl01-status  .
    ENDIF.
    MOVE g_docno                 TO    wa_emddtl01-docno     .
    MOVE zmm_emdhdr-trans        TO    wa_emddtl01-trans     .
    MOVE zmm_emdhdr-ebeln        TO    wa_emddtl01-ebeln     .
    MOVE zmm_emdhdr-vendorno     TO    wa_emddtl01-vendno    .
    MOVE zmm_emdhdr-tenderno     TO    wa_emddtl01-tendno    .
    MOVE wa_emdhdr-bstyp         TO    wa_emddtl01-bstyp      .
    MOVE space                   TO    wa_emddtl01-fi_parkno  .
    MOVE zmm_emdhdr-currency     TO    wa_emddtl01-currency   .
    MOVE zmm_emdhdr-ebidno       TO    wa_emddtl01-ebidno . "+002
* Begin of <RD1K973923> on 20102010
    MOVE zmm_emdhdr-co_code      TO    wa_emddtl01-co_code .
* End of <RD1K973923>
    wa_emddtl01-crby = sy-uname .
    wa_emddtl01-cron = sy-datum .
*-------------------------------------------------------------*
** SRM Changes +001
    IF prev_okcode = 'ECREA' OR g_ttype = 'SRM'.
      MOVE 'SRM' TO wa_emddtl01-trtyp.
    ELSEIF prev_okcode = 'CREA'.
      MOVE 'R3' TO wa_emddtl01-trtyp.
    ENDIF.
*-------------------------------------------------------------*
    IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.
      MOVE g_docno               TO    wa_emddtl01-docno   .
    ELSEIF prev_okcode = 'CHAN'.
      MOVE g_idocno              TO    wa_emddtl01-docno  .
    ENDIF.
    IF prev_okcode = 'CHAN'.
      wa_emddtl01-chby = sy-uname.
      wa_emddtl01-chon = sy-datum.
      wa_emddtl01-docno = g_idocno.
    ENDIF.
    APPEND  wa_emddtl01 TO ist_emddtl01 .
  ENDLOOP.
ENDFORM.                    " insert_itemdtl
*&---------------------------------------------------------------------*
*&      Form  calc_total_amount
*&---------------------------------------------------------------------*
*      Claculate  Total Amount at Header Level

*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM calc_total_amount.
  CLEAR wa_emddtl.
  CLEAR g_amount .
  LOOP AT ist_emddtl INTO wa_emddtl.
    g_amount =  g_amount +  wa_emddtl-amount .
  ENDLOOP.
  MOVE g_amount TO zmm_emdhdr-amount  .
  MOVE g_amount TO wa_emdhdr-amount   .
  MOVE zmm_emdhdr-place TO wa_emdhdr-place .
ENDFORM.                    " calc_total_amount
*&---------------------------------------------------------------------*
*&      Form  GET_DONONO
*&---------------------------------------------------------------------*
*      Get Document no using number range Obj. ZMM_EMDDOC.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_docno.
  CLEAR g_docno .

  IF g_okhdr IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZMM_EMDDOC'
        quantity                = '1'
        toyear                  = sy-datum+0(4)
      IMPORTING
        number                  = g_docno
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
ENDFORM.                    " GET_DOCNO
*&---------------------------------------------------------------------*
*&      Form  POPUP_CONFIRM
*&---------------------------------------------------------------------*
*    Popup Message When 'SAVE' or 'CHANGE'.
*----------------------------------------------------------------------*
*      -->P_TEXT_005  text
*      -->P_TEXT_004  text
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM popup_confirm USING    p_text_01
                            p_text_02 .

  CLEAR g_ans.
  " Begin of <RD1K960036>.
*  call function 'POPUP_TO_CONFIRM_STEP'
*       exporting
*            defaultoption = 'Y'
*            textline1     = p_text_02
*            titel         = p_text_01
*            start_column  = 20
*            start_row     = 6
*       importing
*            answer        = g_ans.
  DATA : l_answer(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = p_text_01
      text_question  = p_text_02
      default_button = '1'
      start_column   = 20
      start_row      = 6
    IMPORTING
      answer         = l_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    CASE l_answer.
      WHEN '1'.
        MOVE 'J' TO g_ans.
      WHEN '2'.
        MOVE 'N' TO g_ans.
    ENDCASE.
  ENDIF.
  " End of <RD1K960036>.
ENDFORM.                    " POPUP_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       Get Data for Display,Change & Delete
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  REFRESH  ist_emddtl    .
  CLEAR :  ist_emddtl    ,
           wa_emdhdr     ,
           wa_emddtl01   ,
           g_status      ,
           g_reset       ,
           g_dansw       ,
           g_reset       .
  IF NOT zmm_emdhdr-docno IS INITIAL.
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = G_IDOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
*&--> Display Status using variable g_status.
      IF wa_emdhdr-status = 'N'.
        g_status  = 'Created'.
      ELSEIF wa_emdhdr-status = 'D'.
        IF prev_okcode = 'DELE'.
          MESSAGE e425(zmm).
        ELSE.
          g_status  = 'Deleted'.
        ENDIF.
      ELSE.
        g_reset   = 0.
      ENDIF.
*&--<
      IF wa_emdhdr-status = 'D'.
        MESSAGE w416(zmm) WITH  wa_emdhdr-docno.
        g_reset = 1.
      ENDIF.
*&-----> Get Place NAme from table zmm_location
      SELECT SINGLE locds FROM zmm_location INTO g_locname
             WHERE loccd  = wa_emdhdr-place .
*&-------> Get Item Details  based on Docno and transaction.
      MOVE-CORRESPONDING wa_emdhdr TO zmm_emdhdr .
      SELECT * FROM zmm_emddtl INTO TABLE ist_emddtl01
               WHERE docno = wa_emdhdr-docno  AND
                     trans = wa_emdhdr-trans  ORDER BY PRIMARY KEY.
      IF sy-subrc = 0.
*&--> Append EMD Item data into table control internal table ist_emddtl.
        LOOP AT ist_emddtl01 INTO wa_emddtl01.
          MOVE-CORRESPONDING wa_emddtl01 TO wa_emddtl.
          APPEND wa_emddtl TO ist_emddtl.
        ENDLOOP.
*&--<
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
    ELSE.
      MESSAGE e411(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  save_change_popup
*&---------------------------------------------------------------------*
*     Popup message when Changes made
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_change_popup USING p_quest.
  DATA lv_doc_info TYPE zmm_emdhdr.
  DATA lv_popup_text TYPE string.

"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*  lv_doc_info = p_quest.
     lv_doc_info = p_quest.     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
  CLEAR g_sc_ans.

  IF lv_doc_info-trans = 'TFS'.
lv_popup_text = `You are going to Exempt Tender Fee for Vendor` && ` ` && lv_doc_info-vendorno && ` ` && g_vname && ` ` && `for        E-Tender` && ` ` && lv_doc_info-ebidno && `.` && ` ` &&
                `Tender Fees Once Waived Cannot be, Reverted back !.` && ` ` && `Are you Sure to Exempt ?.`.
  ELSE.
    lv_popup_text = text-084.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-050
      text_question  = lv_popup_text
      text_button_1  = 'Yes'
      icon_button_1  = ' '
      text_button_2  = 'No'
      default_button = '1'
      start_column   = 25
      start_row      = 6
    IMPORTING
      answer         = g_sc_ans.
ENDFORM.                    " save_change_popup
*&---------------------------------------------------------------------*
*&      Form  CHECK_KEY
*&---------------------------------------------------------------------*
*       Check Key Fields before Save.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_key.
  IF prev_okcode = 'CREA'.
    IF zmm_emdhdr-ebeln    IS  INITIAL   OR
       zmm_emdhdr-trans    IS  INITIAL   OR
       zmm_emdhdr-co_code  IS  INITIAL   OR
       zmm_emdhdr-currency IS  INITIAL.
      MESSAGE e476(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_KEY
*&---------------------------------------------------------------------*
*&      Form  mark_for_delete
*&---------------------------------------------------------------------*
*     Mark for Deletion if the Status of the Document is 'N'.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_for_delete.

  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = G_IDOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0 AND                                 " Tender Document
     wa_emdhdr-ebidno IS INITIAL AND
     wa_emdhdr-tenderno IS NOT INITIAL.

    IF wa_emdhdr-status = 'N'.
      UPDATE zmm_emdhdr
      SET status = 'D'
      WHERE docno = wa_emdhdr-docno  AND
            trans = wa_emdhdr-trans  .

      IF sy-subrc = 0.
        UPDATE zmm_emddtl
           SET status = 'D'
           WHERE docno = wa_emdhdr-docno  AND
            trans = wa_emdhdr-trans  .
        IF sy-subrc = 0.
          PERFORM clear_screen_0105.
          MESSAGE i415(zmm) WITH g_idocno.
          LEAVE TO  SCREEN '0100'.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e479(zmm).
    ENDIF.
  ENDIF.

*ELSEIF SY-SUBRC = 0 AND                           " ETender Document
*       WA_EMDHDR-EBIDNO IS NOT INITIAL AND
*       WA_EMDHDR-TENDERNO IS INITIAL.
** Start of Change - By Manikandan
*  SELECT SINGLE LOGSYS FROM ZMM_LOGSYS INTO L_LOGSYS
*                WHERE  APPL = 'SRM'.
*
*  IF L_LOGSYS IS NOT INITIAL AND
*     WA_EMDHDR-EBIDNO IS NOT INITIAL AND
*     WA_EMDHDR-VENDORNO IS NOT INITIAL.
*
*    CALL FUNCTION 'Z_UPDATE_TDPD_INDI' DESTINATION L_LOGSYS
*      EXPORTING
*        IV_BID_NO            = WA_EMDHDR-EBIDNO               "'char10
*        IV_VENDOR_NO         = WA_EMDHDR-VENDORNO             "'char10
*      IMPORTING
*        EV_SUCCESS           = LV_SRM_UPDATE_STATUS
*      EXCEPTIONS
*        TENDER_NOT_PUBLISHED = 1
*        TF_DEADLINE_REACHED  = 2
*        OTHERS               = 3.
*  ENDIF.
*
*  IF LV_SRM_UPDATE_STATUS EQ ABAP_TRUE. " Update in SRM TDPD Table is success, so can update ECC Tables now.
*    IF WA_EMDHDR-STATUS = 'N'.
*      UPDATE ZMM_EMDHDR
*      SET STATUS = 'D'
*      WHERE DOCNO = WA_EMDHDR-DOCNO  AND
*            TRANS = WA_EMDHDR-TRANS  .
*      IF SY-SUBRC = 0.
*        UPDATE ZMM_EMDDTL
*           SET STATUS = 'D'
*           WHERE DOCNO = WA_EMDHDR-DOCNO  AND
*            TRANS = WA_EMDHDR-TRANS  .
*        IF SY-SUBRC = 0.
*          PERFORM CLEAR_SCREEN_0105.
*          MESSAGE I415(ZMM) WITH G_IDOCNO.
*          LEAVE TO  SCREEN '0100'.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      MESSAGE E479(ZMM).
*    ENDIF.
*  ELSEIF LV_SRM_UPDATE_STATUS EQ 'E'. " Response Already Created by the Vendor for the ETender Document
*    MESSAGE E009(ZMM_EMD) WITH G_IDOCNO.
*  ELSEIF LV_SRM_UPDATE_STATUS NE ABAP_TRUE. "Please Check the Status on both ECC & SRM System
*    PERFORM CLEAR_SCREEN_0105.
*    MESSAGE I010(ZMM_EMD) WITH G_IDOCNO.
*    LEAVE TO  SCREEN '0100'.
*  ENDIF.
** End of Change   - By Manikandan
*ENDIF.
ENDFORM.                    " mark_for_delete
*&---------------------------------------------------------------------*
*&      Form  popup_for_delete
*&---------------------------------------------------------------------*
*     Popup Message for Delete Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_for_delete.
  CLEAR g_dansw.
  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = text-007
      titel         = text-008
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = g_dansw.
ENDFORM.                    " popup_for_delete
*&---------------------------------------------------------------------*
*&      Form  check_rfq
*&---------------------------------------------------------------------*
*       Check RFQ number and Currency.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfq.
  CLEAR wa_emdhdr .
  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE EBELN = ZMM_EMDHDR-EBELN AND CURRENCY = ZMM_EMDHDR-CURRENCY
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0.
    MESSAGE w419(zmm) WITH wa_emdhdr-ebeln wa_emdhdr-currency.
  ENDIF.
ENDFORM.                    " check_rfq
*&---------------------------------------------------------------------*
*&      Form  check_loc
*&---------------------------------------------------------------------*
*       Check Location
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_loc.
  DATA wa_loc  LIKE zmm_location.
*-------- Check location code in table zmm_location.
  SELECT SINGLE * FROM zmm_location INTO wa_loc
            WHERE loccd = zmm_emdhdr-place  AND
                  loccg = 'TF' .   "Tender Fee

  IF sy-subrc NE 0.
    MESSAGE e420(zmm).
  ENDIF.
ENDFORM.                    " check_loc
*&---------------------------------------------------------------------*
*&      Form  CHECK_VALID_INSTNO
*&---------------------------------------------------------------------*
*       Check for the Valid Instrument no
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_valid_instno USING p_ebeln p_instno.

  SELECT * FROM ZMM_EMDDTL UP TO 1 ROWS

 WHERE EBELN = P_EBELN AND INSTNO = P_INSTNO AND INST_TYPE = WA_TC105-INST_TYPE AND STATUS NE 'D'
 ORDER BY PRIMARY KEY .
 ENDSELECT.                  "+007

  IF sy-subrc = 0.
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD'.
      MESSAGE e421(zmm) WITH p_ebeln zmm_emddtl-docno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      MESSAGE e422(zmm) WITH p_ebeln zmm_emddtl-docno .
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_VALID_INSTNO
*&---------------------------------------------------------------------*
*&      Form  CHECK_INST_TYPE
*&---------------------------------------------------------------------*
*      Check Instrurment Type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_inst_type USING p_inst_type.
* +004 Payment Gateway SRM Changes.
  IF prev_okcode NE 'ECREA' AND  p_inst_type = 'OP' .
*Begin of <RD1K963111>
    CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
    MESSAGE e589(zmm).
  ENDIF.

  IF prev_okcode = 'ECREA' AND p_inst_type = 'OP'.
    IF zmm_emdhdr-trans NE 'TFS'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e590(zmm).
    ENDIF.
  ENDIF.
*--+004
*&--> Instrument IP is not allowed for EMD AND SD

  IF zmm_emdhdr-trans = 'EMD' OR zmm_emdhdr-trans = 'SDT'.
    IF p_inst_type = 'IP'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e423(zmm) WITH zmm_emdhdr-trans .
    ENDIF.
  ENDIF.
*---- Instrument type BG/LC is not allowed in case of Tender Fee
  IF zmm_emdhdr-trans = 'TFS'.
    IF p_inst_type = 'BG' OR
       p_inst_type = 'LC'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e550(zmm).
    ENDIF.
  ENDIF.

  IF zmm_emdhdr-trans =  'EMD' OR
     zmm_emdhdr-trans = 'TFS'.
    IF p_inst_type = 'IV'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e481(zmm).
    ENDIF.
  ENDIF.
*Begin of <RD1K963111>
  IF prev_okcode = 'ECREA' AND wa_tc105-inst_type = 'IP'.
    CLEAR wa_tc105-inst_type.
    MESSAGE e865(zmm).
  ENDIF.
*&--<
  DATA lv_index TYPE i.
  DATA lv_ins_type TYPE zmm_emddtl-inst_type.
  DATA lv_mesg TYPE string.
  DESCRIBE TABLE ist_emddtl LINES lv_index.
  IF lv_index > 1.
    READ TABLE ist_emddtl INTO wa_emddtl INDEX 1.
    lv_ins_type = wa_emddtl-inst_type.
    IF lv_ins_type NE wa_tc105-inst_type.
      IF lv_ins_type = 'CC'.
        IF wa_tc105-inst_type EQ 'CC' OR wa_tc105-inst_type EQ 'BC' OR wa_tc105-inst_type EQ 'DD'.
        ELSE.
          MESSAGE i426(zmm).
        ENDIF.
      ELSEIF lv_ins_type = 'BC'.
        IF wa_tc105-inst_type EQ 'BC' OR wa_tc105-inst_type EQ 'CC' OR wa_tc105-inst_type EQ 'DD'.
        ELSE.
          MESSAGE i426(zmm).
        ENDIF.

      ELSEIF lv_ins_type = 'DD'.
        IF wa_tc105-inst_type EQ 'DD' OR wa_tc105-inst_type EQ 'BC' OR wa_tc105-inst_type EQ 'CC'.
        ELSE.
          MESSAGE i426(zmm).
        ENDIF.

      ELSEIF lv_ins_type = 'IP' AND lv_ins_type NE wa_tc105-inst_type.
        MESSAGE i426(zmm).

      ELSEIF lv_ins_type = 'BG' AND lv_ins_type NE wa_tc105-inst_type.
        MESSAGE i426(zmm).

      ELSEIF lv_ins_type = 'LC' AND lv_ins_type NE wa_tc105-inst_type.
        MESSAGE i426(zmm).

      ENDIF.
    ENDIF.
  ENDIF.
*End of <RD1K963111>
* End of modification by SAB_SARVANAN on 09/04/2009 - RD1K963111
ENDFORM.                    " CHECK_INST_TYPE
*&---------------------------------------------------------------------*
*&      Form  popup_for_reset
*&---------------------------------------------------------------------*
*       Popup for Reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_for_reset.
  CLEAR g_ransw.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = text-011
      titel         = text-027
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = g_ransw.
ENDFORM.                    " popup_for_reset
*&---------------------------------------------------------------------*
*&      Form  RESET_DOCU
*&---------------------------------------------------------------------*
*       Update Status /Reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_docu.
  DATA: l_ok_h,
        l_ok_i .
  UPDATE zmm_emdhdr
     SET status  = 'N'
     WHERE docno = g_idocno .

  IF  sy-subrc = 0.
    l_ok_h  = 0.
  ELSE.
    l_ok_h  = 1.
  ENDIF.
*----------------------------------------------------------------------*
*  Reset Item Document status   and Fiparkno and date                  *
*----------------------------------------------------------------------*
  UPDATE zmm_emddtl
       SET status  = 'N'
           fi_parkno = space
           fi_parkdt = space
       WHERE docno = g_idocno .

  IF sy-subrc = 0.
    l_ok_i = 0.
  ELSE.
    l_ok_i = 1.
  ENDIF.

  IF l_ok_h = 0 AND l_ok_i = 0.
    g_reset  = 0.
    MESSAGE  i424(zmm) .
    PERFORM clear_screen_0105.
    LEAVE TO SCREEN '0100'.
  ENDIF.
ENDFORM.                    " RESET_DOCU
*&---------------------------------------------------------------------*
*&      Form  copy_line
*&---------------------------------------------------------------------*
*     Copy Line Item Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_line.
  REFRESH : ist_emddtl_t01 .
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    MOVE space  TO wa_emddtl-sel .
    APPEND  wa_emddtl  TO ist_emddtl_t01 .
    wa_emddtl-sel = space.
    MODIFY ist_emddtl FROM wa_emddtl.
  ENDLOOP.
  CLEAR ok_code.
ENDFORM.                    " copy_line
*&---------------------------------------------------------------------*
*&      Form  PASTE_LINE
*&---------------------------------------------------------------------*
*       Paste Selected Line Item.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM paste_line.

  DATA: l_line LIKE zmm_emddtl-item_no.
  DESCRIBE TABLE ist_emddtl LINES l_line .
  LOOP AT ist_emddtl_t01 INTO wa_emddtl  .
    l_line = l_line + 1.
    MOVE l_line  TO  wa_emddtl-item_no.
    MOVE 'N' TO wa_emddtl-status .
    MOVE space TO wa_emddtl-sel   .
    APPEND  wa_emddtl  TO ist_emddtl  .
  ENDLOOP.

  DESCRIBE TABLE ist_emddtl LINES l_line .
  tc_105-lines = l_line .
  REFRESH ist_emddtl_t01.
  CLEAR ok_code.
ENDFORM.                    " PASTE_LINE
*&---------------------------------------------------------------------*
*&      Form  check_valid_instno_CHNG
*&---------------------------------------------------------------------*
*      Check Valid Instrument in Change Mode
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDHDR_EBELN  text
*      -->P_WA_TC105_INSTNO  text
*----------------------------------------------------------------------*
FORM check_valid_instno_chng USING    p_ebeln
                                      p_instno.

  SELECT * FROM ZMM_EMDDTL UP TO 1 ROWS

 WHERE EBELN = P_EBELN AND INSTNO = P_INSTNO AND DOCNO <> G_IDOCNO AND STATUS NE 'D'
 ORDER BY PRIMARY KEY .
 ENDSELECT.                      "+007

  IF sy-subrc = 0.
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD'.
      MESSAGE e421(zmm) WITH p_ebeln zmm_emddtl-docno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      MESSAGE e422(zmm) WITH p_ebeln zmm_emddtl-docno.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_valid_instno_CHNG
*&---------------------------------------------------------------------*
*&      Form  check_inst_group
*&---------------------------------------------------------------------*
*    Check Instrurment Group
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_inst_group.
  DATA: ist_emddtl_temp LIKE TABLE OF wa_emddtl.
*&--> Check Whether Instrument Type entered is from same Group or not
*&--> G1- DD,BC,CC G2-LC , G3-BG , G4-IP

**** check for Instrument type. This logic is laid for the reason
***** that no
***** (1) If Instrument type is DD then only BC and CC is permitted
***** (2) If Instrument is BG then only BG is permitted.
****  (3) IF Instrument is IV then only IV is permitted.

** New Logic for Instrument Group added on 09.03.05 *********


** End of Addition ******************************************

  DATA: ist_instgrp TYPE TABLE OF zmm_emddtl-inst_type.
  DATA:  wa_instgrp TYPE zmm_emddtl-inst_type.
  DATA: l_inst(20).
  DATA: l_fd  .
  REFRESH ist_instgrp.
  LOOP AT ist_emddtl INTO wa_emddtl.
    wa_instgrp  = wa_emddtl-inst_type.
    APPEND wa_instgrp  TO ist_instgrp.
  ENDLOOP.
  SORT ist_instgrp .
  DELETE ADJACENT DUPLICATES FROM ist_instgrp .
  LOOP AT ist_instgrp INTO wa_instgrp .
    CONCATENATE  l_inst
   wa_instgrp  INTO l_inst .
  ENDLOOP.

  IF NOT l_inst IS INITIAL.

    IF l_inst  = 'BCCCDD'  OR
       l_inst  = 'BCCC'    OR
       l_inst  = 'CCDD'    OR
       l_inst  = 'CCBC'    OR
       l_inst  = 'BCDD'    OR
       l_inst  = 'DD'      OR
       l_inst  = 'CC'      OR
       l_inst  = 'BC'      OR
       l_inst  = 'BG'      OR
       l_inst  = 'IP'      OR
       l_inst  = 'IV'      OR
       l_inst   = 'LC' .
      l_fd = 'X'.
      g_error = 1 .
    ELSE.
      g_error = 0.
      MESSAGE i426(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_inst_group
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_110
*&---------------------------------------------------------------------*
*       Save Data in screen 110. REFUND/FORFEIT/EMD-SD CONVERSION
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data_110.
  g_save_h = 1.
  g_save_i = 1.

*  data l_status .
  DATA: l_tot_item LIKE sy-tabix.
  DATA: ist_emdref_tmp TYPE TABLE OF  zmm_emdref.
* Begin of <RD1K963111>
  DATA: its_emddtl TYPE TABLE OF zmm_emddtl,
        wa_emddtl_01 TYPE zmm_emddtl.
* End of <RD1K963111>
  IF sy-subrc = 0.
    g_save_h = 0.
  ELSE.
    g_save_h = 1.
  ENDIF.
*&--<
  l_tot_item  = 1.
  MOVE-CORRESPONDING zmm_emdref TO wa_emdref   .
  IF g_docstat = 'C'.
    zmm_emdhdr-trans = 'SDT'.
  ENDIF.
  MOVE zmm_emdhdr-docno  TO wa_emdref-refdoc   .
  MOVE zmm_emdhdr-trans  TO wa_emdref-trans    .
  IF  g_docstat =  'C'.
    MOVE zmm_emdref-ebeln  TO wa_emdref-ebeln    .
  ELSE.
    MOVE zmm_emdhdr-ebeln  TO wa_emdref-ebeln    .
  ENDIF.
  IF NOT  g_ebeln IS INITIAL .
    MOVE g_ebeln  TO wa_emdref-ebeln    .
  ENDIF.
* Begin of <RD1K963111>
  SELECT * FROM zmm_emddtl INTO TABLE its_emddtl WHERE docno = zmm_emdhdr-docno AND ebeln = wa_emdref-ebeln.
  LOOP AT its_emddtl INTO wa_emddtl_01.
    IF g_docstat = 'R'.
      wa_emddtl_01-refdt = sy-datum.
    ELSEIF g_docstat = 'C'.
      wa_emddtl_01-candt = sy-datum.
    ELSEIF g_docstat = 'F'.
      wa_emddtl_01-fofdt = sy-datum.
    ENDIF.
    MODIFY zmm_emddtl FROM wa_emddtl_01.
  ENDLOOP.
* End of <RD1K963111>
  MOVE zmm_emdhdr-docno  TO wa_emdref-refdoc   .
  MOVE g_docstat         TO wa_emdref-status   .
  MOVE sy-uname          TO wa_emdref-rfccrby  .
  MOVE sy-datum          TO wa_emdref-rfccron  .
  MOVE g_docno           TO wa_emdref-docno    .
  MOVE l_tot_item        TO wa_emdref-itemno   .
  MOVE space             TO wa_emdref-fi_parkno .
  MOVE zmm_emdhdr-currency TO wa_emdref-currency.
  MODIFY zmm_emdref FROM wa_emdref.
* Begin of <RD1K963111>
  zmm_emdhdr-ref_doc = g_docno.
  MODIFY zmm_emdhdr.
* End of <RD1K963111>
  IF sy-subrc NE 0.
    g_save_h = 1.
    MESSAGE e427(zmm).
  ELSE.
    g_save_h = 0.
  ENDIF.
ENDFORM.                    " SAVE_DATA_110
*&---------------------------------------------------------------------*
*&      Form  CLEAR_GLOBAL_110
*&---------------------------------------------------------------------*
*      Clear Global Variable
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_110.
  CLEAR:
         wa_emdhdr.
  CLEAR: zmm_emdhdr ,
         zmm_emdref .
  CLEAR : g_status,
          g_lines .

  CLEAR g_locname.

  CLEAR ist_tab .
  g_ref = 1.
  CLEAR:
         g_ans,
         g_sc_ans ,
         g_rfc    ,
         g_rfc_chk.
  CLEAR: g_save_h ,
         g_save_i .
  CLEAR: g_doccat .
  CLEAR: g_balamt .
  CLEAR: g_tot_ref.
  g_okhdr = 1.
  CLEAR g_docno .
ENDFORM.                    " CLEAR_GLOBAL_110
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCNO
*&---------------------------------------------------------------------*
*       Validate input Docno
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_docno.
  DATA :  wa_emdhdr_tmp  LIKE zmm_emdhdr,
          wa_emdref_t01  LIKE zmm_emdref.
  CLEAR g_ref.
  CLEAR wa_emdhdr .

  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR_T02 UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc NE 0.
    SELECT * FROM ZMM_EMDREF
 INTO WA_EMDREF_T01 UP TO 1 ROWS WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc NE 0.
      g_ref =  1.
      MESSAGE e411(zmm).
    ELSE.

      SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR_TMP UP TO 1 ROWS
 WHERE DOCNO = WA_EMDREF_T01-REFDOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      MOVE wa_emdref_t01-amount TO wa_emdhdr_tmp-amount.
      MOVE  wa_emdref_t01-trans TO wa_emdhdr_tmp-trans .
      MOVE  zmm_emdhdr-docno           TO wa_emdhdr_tmp-docno.
      MOVE-CORRESPONDING wa_emdhdr_tmp TO zmm_emdhdr.
      g_ref = 0.
    ENDIF.
  ELSE.
    g_ref = 0.
    IF wa_emdhdr_t02-status = 'O'.
      MESSAGE e230(zmm).
    ENDIF.
    MOVE wa_emdhdr_t02-currency       TO zmm_emdref-currency .
  ENDIF.

  IF zmm_emdhdr-trans = 'TFS' AND zmm_emdref-rscode = '120' AND sy-dynnr = '0110'.
    zmm_emdref-amount = zmm_emdhdr-amount.
  ENDIF.


ENDFORM.                    " CHECK_DOCNO
*&---------------------------------------------------------------------*
*&      Form  popup_conf_110
*&---------------------------------------------------------------------*
*   Popup Confirmation before Refund/Forfeit/EMD-SD Conversion
*----------------------------------------------------------------------*
*      -->P_G_TITLE  text
*      -->P_G_TEXT  text
*----------------------------------------------------------------------*
FORM popup_conf_110 USING     p_titel p_text.
  CLEAR g_rfc.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = p_text
      titel         = p_titel
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = g_rfc.
ENDFORM.                    " popup_conf_110
*&---------------------------------------------------------------------*
*&      Form  append_isttab_110
*&---------------------------------------------------------------------*
*     Append Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_110.
  IF g_ref = 1.
    REFRESH ist_tab  .
    MOVE 'SAVE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'HEAD' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
  ELSEIF g_ref = 0.
    REFRESH ist_tab  .
    MOVE 'CHNG'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'CRET'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'DISP'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'DELE'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'UNDEL'  TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'SUBFI'  TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
  ENDIF.

  IF ok_code = 'CRET' AND g_ref = 0.
    REFRESH: ist_tab.
    MOVE 'CHNG'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'CRET'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DISP'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DELE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'UNDEL'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SUBFI'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
  ELSEIF ok_code = 'CRET' AND g_ref = 1.
    REFRESH: ist_tab.
    MOVE 'CHNG'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'CRET'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DISP'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DELE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SAVE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'UNDEL'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SUBFI'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
  ELSEIF ok_code = 'CHNG'.
    REFRESH ist_tab .
    MOVE 'CRET' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
  ENDIF.

  IF zmm_emdhdr-docno IS INITIAL AND g_doccat IS INITIAL.
    MOVE 'SAVE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'HEAD'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
  ENDIF.
*&--<
ENDFORM.                    " append_isttab_110
*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_NAME
*&---------------------------------------------------------------------*
*       Get Vendor name
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_vendor_name.
  CLEAR wa_lfa1.

  SELECT SINGLE * FROM lfa1 INTO wa_lfa1
             WHERE lifnr = zmm_emdhdr-vendorno.

  IF sy-subrc = 0.
    MOVE wa_lfa1-name1 TO g_vname.
  ENDIF.
ENDFORM.                    " GET_VENDOR_NAME
*&---------------------------------------------------------------------*
*&      Form  get_RFC_DOCNO
*&---------------------------------------------------------------------*
*      Get Document no for REFUND/FORFEIT/EMD-SD CONVERTION
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rfc_docno USING p_nr.

  CLEAR g_docno.
  IF g_okhdr IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = p_nr
        object                  = 'ZMM_EMDDOC'
        quantity                = '1'
        toyear                  = sy-datum+0(4)
      IMPORTING
        number                  = g_docno
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
ENDFORM.                    " get_RFC_DOCNO
*&---------------------------------------------------------------------*
*&      Form  set_values
*&---------------------------------------------------------------------*
*      Populate Values in List Box
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_values.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_task_cd
      values = g_task_list.

ENDFORM.                    " set_values
*&---------------------------------------------------------------------*
*&      Form  append_isttab_115
*&---------------------------------------------------------------------*
*       Append F-code into internal table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_115.

  REFRESH  ist_tab   .
  IF prev_okcode = 'CRET' OR
     prev_okcode = 'CHNG' OR
     prev_okcode = 'DISP' OR
     prev_okcode = 'DELE' OR
     prev_okcode = 'UNDEL'.
    REFRESH  ist_tab .
    MOVE 'CRET'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'CHNG'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DISP'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DELE'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'HEAD'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'RESET'  TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'    TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab    .
    MOVE 'ME43'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab    .
    MOVE 'ENMT'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE' .
    REFRESH  ist_tab .
    MOVE 'SAVE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'HEAD' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'RFCD' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'ME43'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'      TO  wa_tab-fcode .
    MOVE 'ME23N'      TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab.
    MOVE 'ENMT'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
    MOVE 'RESET'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
  IF prev_okcode = 'UNDEL'.
    DELETE  ist_tab WHERE fcode = 'RESET'.
  ENDIF.
  IF g_rfc_chk = 1.
    REFRESH  ist_tab .
    MOVE 'DELE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SAVE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'HEAD'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'RFCD'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'RESET'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'ME43'    TO   wa_tab-fcode .
    APPEND wa_tab  TO   ist_tab.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO   wa_tab-fcode .
    MOVE 'ME23N'    TO   wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO   ist_tab.
    MOVE 'ENMT'    TO   wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ELSEIF ( g_rfc_chk = 0 ) AND
    prev_okcode = 'DISP' OR    prev_okcode = 'UNDEL'.
    MOVE 'SAVE'   TO    wa_tab-fcode.
    APPEND wa_tab TO    ist_tab  .
    MOVE 'DELE'   TO    wa_tab-fcode.
    APPEND wa_tab TO    ist_tab  .
  ENDIF.

  IF g_rfc_chk = 0   AND
       prev_okcode = 'DELE'.
    REFRESH  ist_tab .
    MOVE 'SAVE'    TO  wa_tab-fcode.
    APPEND wa_tab  TO  ist_tab  .
    MOVE 'RESET'   TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
  IF ( zmm_emdhdr-trans = 'TFS' OR  zmm_emdhdr-trans = 'EMD' ) AND NOT
zmm_emdhdr-ebeln IS INITIAL .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'   TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab    .
  ELSEIF (  zmm_emdhdr-trans = 'SDT' )
  AND NOT zmm_emdhdr-ebeln IS INITIAL.
    MOVE 'ME43'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
ENDFORM.                    " append_isttab_115
*&---------------------------------------------------------------------*
*&      Form  change_docu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_docu.
  DATA : ist_cdpos TYPE TABLE OF cdpos WITH HEADER LINE .
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0105.
  SELECT * INTO TABLE ist_cdpos FROM cdpos WHERE objectid =
   wa_emdhdr-docno .
ENDFORM.                    " change_docu
*&---------------------------------------------------------------------*
*&      Form  save_chg_docu
*&---------------------------------------------------------------------*
*       Subroutine being used for saving change document iinformation
*       in CDPOS and CDHDR
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_chg_docu.

  DATA  : l_objectid LIKE cdhdr-objectid .
  DATA  : old_emdhdr LIKE zmm_emdhdr .
  DATA  : BEGIN OF l_place OCCURS 0 .
          INCLUDE STRUCTURE cdtxt.
  DATA  : END OF l_place .

  old_emdhdr = wa_emdhdr .
  wa_emdhdr-place = zmm_emdhdr-place .

  l_objectid = wa_emdhdr-docno .

  CALL FUNCTION 'ZPLACE_WRITE_DOCUMENT'
    EXPORTING
      objectid       = l_objectid
      tcode          = sy-tcode
      utime          = sy-uzeit
      udate          = sy-datum
      username       = sy-uname
      n_zmm_emdhdr   = wa_emdhdr
      o_zmm_emdhdr   = old_emdhdr
      upd_zmm_emdhdr = 'U'
    TABLES
      icdtxt_zplace  = l_place.
ENDFORM.                    " save_chg_docu
*&---------------------------------------------------------------------*
*&      Form  check_docno_rfc
*&---------------------------------------------------------------------*
*      Get Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_docno_rfc.

  CLEAR g_rfc_chk.
  CLEAR wa_emdhdr .
  CLEAR g_docno .
  DATA: l_tendno  LIKE zmm_emddtl-tendno,
        l_vendno  LIKE zmm_emddtl-vendno,
        l_ekgrp   LIKE zmm_emdhdr-ekgrp.

  SELECT * FROM ZMM_EMDREF UP TO 1 ROWS

 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.
*&----->  Raise Error Message if Document is deleted.

    IF  ( zmm_emdref-status = 'D' ) AND ( prev_okcode = 'CHNG' OR
        prev_okcode = 'DELE' ).
      g_rfc_chk = '1'.

      MESSAGE e425(zmm).
    ELSE.
      g_rfc_chk = 0.
    ENDIF.
*-----------------------------------------------------------*
* Check whether Document Submitted to FI . If the raise error.
*-----------------------------------------------------------*
    IF prev_okcode  NE 'DISP'.
      IF zmm_emdref-status = 'S' .
        g_rfc_chk = '1'.
        MESSAGE e488(zmm).
      ENDIF.
    ENDIF.
*----- If Document status is 'C' Don;t allow to Reset.*------
    IF ok_code = 'UNDEL'.
      IF zmm_emdref-status = 'R' OR
         zmm_emdref-status = 'F' OR
         zmm_emdref-status = 'C'.
        g_rfc_chk = '1'.
        MESSAGE e483(zmm).
      ENDIF.
    ENDIF.
*-----------------------------------------------------------*
    IF ok_code = 'UNDEL'.
      PERFORM check_doc_status  USING zmm_emdref-docno.
    ENDIF.
*&------<
    g_amt = zmm_emdref-amount .
    g_docno = zmm_emdref-docno.

    g_rfc_chk = 0.
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR_T02 UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-REFDOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_emdhdr_t02 TO zmm_emdhdr .
*      MOVE zmm_emdhdr-balamt TO g_balamt .
*----------------------------------------------------------------*
* if Ref. document is not in header then go for ZMM_EMDREF TABLE
*  COMPARE docno with refdoc no in same table and status = 'C'.
*  This is for getting Receipt total amount of Converted Document.
*----------------------------------------------------------------*
    ELSE.

      SELECT * FROM ZMM_EMDREF INTO CORRESPONDING
 FIELDS OF WA_EMDHDR_T02 UP TO 1 ROWS WHERE DOCNO = ZMM_EMDREF-REFDOC AND RFCSTAT = 'C'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      MOVE-CORRESPONDING wa_emdhdr_t02 TO zmm_emdhdr .
      PERFORM get_tendno_vendno USING wa_emdhdr_t02-ebeln
    CHANGING l_tendno l_vendno l_ekgrp  .

      MOVE l_tendno TO zmm_emdhdr-tenderno.
      MOVE l_vendno TO zmm_emdhdr-vendorno.
      MOVE l_ekgrp    TO zmm_emdhdr-ekgrp .
    ENDIF.
  ELSE.
    g_rfc_chk = 1.
    MESSAGE e411(zmm).
  ENDIF.
  MOVE zmm_emdhdr-currency   TO zmm_emdref-currency .
ENDFORM.                    " check_docno_rfc
*&---------------------------------------------------------------------*
*&      Form  save_data_115
*&---------------------------------------------------------------------*
*      Save Modified Data of Screen - 0115
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data_115.
  CLEAR: g_save_h    ,
         g_save_i    .
  CLEAR wa_emdref_t01.
  MOVE-CORRESPONDING zmm_emdref TO wa_emdref .
  wa_emdref-rfcchby = sy-uname .
  wa_emdref-rfcchon = sy-datum .
  MOVE wa_emdhdr_t02-ebeln TO wa_emdref-ebeln .
  MODIFY zmm_emdref FROM wa_emdref.
  IF sy-subrc = 0.
    g_save_i = 0.
  ELSE.
    g_save_i = 1.
  ENDIF.
ENDFORM.                    " save_data_115
*&---------------------------------------------------------------------*
*&      Form  check_rfc_amount
*&---------------------------------------------------------------------*
*       Check Amount Entered for Refund/Forfeit/EMD-SD Conv.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfc_amount.

  DATA: l_tamt LIKE zmm_emdhdr-amount .
  DATA: l_act_bal LIKE zmm_emdhdr-amount .
*&---> Check Refund Amount
  PERFORM get_total_ref  .
*&---<
  CLEAR : g_balamt.
  g_balamt = zmm_emdhdr-amount  -  g_tot_ref .

  l_act_bal = zmm_emdhdr-amount -  g_tot_ref .

  IF prev_okcode = 'CREA'.
    g_amt = 0.
  ENDIF.
*----------------------------------------------*
  IF g_rfc  = 0  AND g_amt NE zmm_emdref-amount .

*&----> If Amount Entered is less than Doc. amount Add diff. amt to
* Balance amount .
    IF zmm_emdref-amount < g_amt .
      g_balamt =  g_amt -  zmm_emdref-amount + g_balamt.
    ELSEIF  zmm_emdref-amount > g_amt.
      l_tamt = zmm_emdref-amount - g_amt .
      IF   l_tamt > l_act_bal.
        MESSAGE e429(zmm).
      ELSE.
        g_balamt = g_balamt - ( zmm_emdref-amount - g_amt ) .
      ENDIF.
    ELSE.
      g_balamt    =  g_balamt   - zmm_emdref-amount.
    ENDIF.
  ENDIF.                                                    "20.02.2004
*&--<
ENDFORM.                    " check_rfc_amount
*&---------------------------------------------------------------------*
*&      Form  get_total_balamt
*&---------------------------------------------------------------------*
*      Get Total Balance Amount from Refund Table ZMM_EMDREF
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_total_ref .
  g_tot_ref  =  0.
  CLEAR g_tot_ref .
  SELECT * FROM zmm_emdref INTO TABLE ist_emdref
             WHERE     refdoc  = zmm_emdhdr-docno AND
                      status IN ('R','F','C','I','S').

  IF sy-subrc = 0.
    LOOP AT ist_emdref INTO wa_emdref.
      g_tot_ref = g_tot_ref + wa_emdref-amount.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " get_total_balamt
*&---------------------------------------------------------------------*
*&      Form  disp_head
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_head USING l_docno
                     l_cron
                     l_trans .

  CLEAR g_status.

  CALL FUNCTION 'Z_MM_EMD_DISPLAY_HEADER'
    EXPORTING
      docu_no            = l_docno
      docu_type          = l_trans
      docu_date          = l_cron
    IMPORTING
      created_by         = g_crea_by
      created_on         = g_crea_on
      changed_by         = g_chan_by
      changed_on         = g_chan_on
      status             = g_stat
    EXCEPTIONS
      document_not_found = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  PERFORM get_head_status USING g_stat.
  CALL SCREEN 0125 STARTING AT 10 5  ENDING AT 60 12 .
ENDFORM.                    " disp_head
*&---------------------------------------------------------------------*
*&      Form  delete_rfc_doc
*&---------------------------------------------------------------------*
*       Delete RFC Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_rfc_doc.

*&---> Mark for deletion Set Status Flag = 'S'.

  UPDATE zmm_emdref
         SET status  = 'D'
         rfcchby = sy-uname
         rfcchon = sy-datum
         WHERE docno = g_docno    AND
               status NE 'D'.
  IF sy-subrc = 0.
    PERFORM clear_global_115.
    MESSAGE i415(zmm) WITH g_docno.

  ENDIF.
*&---<
ENDFORM.                    " delete_rfc_doc

*&---------------------------------------------------------------------*
*&      Form  clear_global_115
*&---------------------------------------------------------------------*
*       Clear Global Varibales in screen 115
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_115.
  CLEAR g_locname.

  CLEAR : zmm_emdhdr,
          zmm_emdref .
  CLEAR: ok_code ,
         prev_okcode .
ENDFORM.                    " clear_global_115
*&---------------------------------------------------------------------*
*&      Form  clear_global_100
*&---------------------------------------------------------------------*
*     Clear Global variable used in screen 0105.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_100.

  CLEAR: zmm_emdhdr,
         zmm_emddtl.
  CLEAR g_locname.

  REFRESH : ist_emddtl,
            ist_emddtl01,
            ist_emddtl_t01,
            ist_del_emddtl.
ENDFORM.                    " clear_global_100
*&---------------------------------------------------------------------*
*&      Form  check_instno
*&---------------------------------------------------------------------*
*      Check Instrument no
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_instno.
  CLEAR wa_emddtl.
  DATA: l_prev_instno    TYPE   zmm_emddtl-instno ,
        l_prev_inst_type TYPE   zmm_emddtl-inst_type.
  DATA: ist_emddtl_srt  LIKE TABLE OF wa_emddtl.

  g_error = 0.
  REFRESH ist_emddtl_srt .
  LOOP AT ist_emddtl INTO wa_emddtl.
    APPEND wa_emddtl TO ist_emddtl_srt.
  ENDLOOP.
  SORT  ist_emddtl_srt BY inst_type instno.
*&---> Check Whether same instrument no entered in Same Document
* If entered raise Message
  LOOP AT ist_emddtl_srt INTO wa_emddtl.
    IF sy-tabix = 1.
      l_prev_instno = wa_emddtl-instno.
      l_prev_inst_type = wa_emddtl-inst_type.
    ENDIF.

    IF sy-tabix > 1.
      IF  wa_emddtl-instno   = l_prev_instno AND
          wa_emddtl-inst_type = l_prev_inst_type .
        g_error = 1.
        MESSAGE i430(zmm) .
        EXIT.
      ELSE.
        g_error = 0.
        l_prev_instno = wa_emddtl-instno .
        l_prev_inst_type =   wa_emddtl-inst_type .
      ENDIF.
    ENDIF.
  ENDLOOP.
  CLEAR wa_emddtl.
  REFRESH ist_emddtl_srt .
ENDFORM.                    " check_instno
*&---------------------------------------------------------------------*
*&      Form  GET_HEADER
*&---------------------------------------------------------------------*
*       Get Header Information for RFC
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header.

  MOVE zmm_emdref-rfccron TO zmm_emdhdr-cron.
  MOVE zmm_emdref-rfccrby TO zmm_emdhdr-crby.
  MOVE zmm_emdref-rfcchon TO wa_emdref-rfcchon .
  MOVE zmm_emdref-rfcchby TO wa_emdref-rfcchby.
  IF  zmm_emdref-status = 'R'.
    MOVE text-015 TO g_status.
  ELSEIF zmm_emdref-status = 'F'.
    MOVE text-016 TO g_status.
  ELSEIF zmm_emdref-status = 'C'.
    MOVE text-017 TO g_status.
  ENDIF.
  CALL SCREEN 0125 STARTING AT 10 5  ENDING AT 60 12 .
ENDFORM.                    " GET_HEADER
*&---------------------------------------------------------------------*
*&      Form  GET_RFC_DATA
*&---------------------------------------------------------------------*
*      Get Refund/Forfeit/EMD-SD Converted Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rfc_data.

  CLEAR wa_emdref_01..
  REFRESH ist_emdref_01.

  SELECT * FROM zmm_emdref INTO TABLE ist_emdref
           WHERE refdoc   = zmm_emdhdr-docno  AND
                 status  IN ('R','F','C','I','S').

  CLEAR wa_emdref_01.
  IF sy-subrc = 0.
    LOOP AT ist_emdref INTO wa_emdref.

      MOVE-CORRESPONDING wa_emdref TO wa_emdref_01.
      MOVE zmm_emdhdr-currency   TO wa_emdref_01-currency .
      APPEND  wa_emdref_01 TO ist_emdref_01.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " GET_RFC_DATA
*&---------------------------------------------------------------------*
*&      Form  check_pono
*&---------------------------------------------------------------------*
*   Check PO no Incase of EMD-SD Conversion
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_pono.
  DATA: l_ebeln LIKE ekko-ebeln,
        l_bstyp LIKE ekko-bstyp.

*&--> Check for PO Document no if Tender fee select doc.with BSTYP =
*'A' Otherwise select doc. with  BSTYP = 'F'

  IF NOT zmm_emdhdr-trans IS INITIAL AND
    NOT zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE ebeln bstyp FROM ekko INTO (l_ebeln,l_bstyp)
           WHERE  ebeln = zmm_emdref-ebeln .
    IF sy-subrc NE 0.
      MESSAGE e275(zmm).
    ELSE.
      PERFORM check_document_type USING 'SDT'  l_bstyp  .
    ENDIF.
  ENDIF.
ENDFORM.                    " check_pono
*&---------------------------------------------------------------------*
*&      Form  check_company_code
*&---------------------------------------------------------------------*
*      Validate Company Code.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_company_code.

  SELECT SINGLE  * FROM t001
        WHERE  bukrs = zmm_emdhdr-co_code.
  IF sy-subrc NE 0.
    MESSAGE e431(zmm).
  ENDIF.
ENDFORM.                    " check_company_code
*&---------------------------------------------------------------------*
*&      Form  CLEAR_GLOBAL_135
*&---------------------------------------------------------------------*
*     Clear Global variables
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_135.

  CLEAR: zmm_emdhdr,
         zmm_emddtl,
         wa_emdhdr,
         wa_emddtl,
         zmm_emdhdr.

  REFRESH: ist_emddtl01,
           ist_emddtl.

  CLEAR :  ist_emddtl01,
           ist_emddtl.
  CLEAR g_idocno.
ENDFORM.                    " CLEAR_GLOBAL_135
*&---------------------------------------------------------------------*
*&      Form  update_for_bankconf
*&---------------------------------------------------------------------*
*     Update Line  Item Data Status .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_for_bankconf.

*&-----> Send for Bank Confirmation

  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE check = 'X'.

    UPDATE zmm_emddtl
           SET status = 'B'
     WHERE docno      = wa_emddtl-docno AND
           trans      = wa_emddtl-trans AND
           item_no    = wa_emddtl-item_no AND
           status    NE 'B'.
  ENDLOOP.
ENDFORM.                    " update_for_bankconf
*&---------------------------------------------------------------------*
*&      Form  check_item_select
*&---------------------------------------------------------------------*
*      Check Any Item selected or not
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_item_select.
  DATA: l_cnt LIKE sy-tabix.
  CLEAR g_ans.
  l_cnt = 0.
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE check = 'X'.
    IF wa_emddtl-check  = 'X' .
      l_cnt      = 1.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF l_cnt NE 1.

    g_ans  = 'K'.
    MESSAGE i433(zmm).
  ELSE.
    g_ans  = '0'.
  ENDIF.
ENDFORM.                    " check_item_select
*&---------------------------------------------------------------------*
*&      Form  append_isttab_135
*&---------------------------------------------------------------------*
*      Append F-code to ist_tab.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_135.
  DATA: wa_dtl  LIKE wa_emddtl.
  REFRESH ist_tab .
  DATA: l_found LIKE sy-tabix.
  DATA l_lines LIKE sy-tabix .
  DATA : l_bstyp TYPE zmm_emdhdr-bstyp.

  SELECT SINGLE  bstyp FROM ekko INTO l_bstyp
           WHERE  ebeln = zmm_emdhdr-ebeln .

  IF l_bstyp = 'F' OR l_bstyp = 'K'.
    MOVE 'ME43'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
  ELSEIF l_bstyp = 'A'.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'        TO  wa_tab-fcode .
    MOVE 'ME23N'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
  ENDIF.

  MOVE 'SAVE'        TO  wa_tab-fcode .
  APPEND wa_tab      TO  ist_tab      .
  IF prev_okcode = 'RESET'  .
    MOVE 'BCONF'     TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
    MOVE 'SAVE'      TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .

  ELSEIF prev_okcode =   'BCONF'.
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
    MOVE 'SAVE'      TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
  ENDIF.

*---- If instrument type is 'LC' Disable icon "SND TO BNK" & "POST CNF".
  IF set_okcode = 'BGLC'.
    IF NOT ist_emddtl IS INITIAL.
      READ TABLE ist_emddtl INTO wa_dtl  INDEX 1.
    ENDIF.
    IF wa_dtl-inst_type = 'LC'.
      MOVE 'BCONF'     TO  wa_tab-fcode .
      APPEND wa_tab    TO  ist_tab      .
      MOVE 'SAVE'      TO  wa_tab-fcode .
      APPEND wa_tab    TO  ist_tab      .
      MOVE 'PCONF'      TO  wa_tab-fcode .
      APPEND wa_tab    TO  ist_tab      .
    ENDIF.
  ENDIF.
*&---------<
  IF g_ans = 'N'.
    MOVE 'SAVE'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
  ENDIF.
  LOOP AT ist_emddtl INTO wa_emddtl WHERE status = 'B'.
    l_found = l_found + 1 .
  ENDLOOP.
  DESCRIBE TABLE ist_emddtl LINES l_lines.
  IF l_lines = l_found.
    MOVE 'SAVE'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
    MOVE 'BCONF'     TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
  ENDIF.
ENDFORM.                    " append_isttab_135
*&---------------------------------------------------------------------*
*&      Form  reset_bank_conf_doc
*&---------------------------------------------------------------------*
*       Reset Document.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_bank_conf_doc USING p_docno p_itemno p_reset_status.

  UPDATE zmm_emddtl
          SET status  = p_reset_status
          WHERE docno = p_docno AND
          trans       = zmm_emdhdr-trans AND
          item_no     = p_itemno.

*& --->> +003
* If document is reset , then update status of request for Return/Invoke
*  if sy-subrc = 0.
*    update zmm_emddtl
*          set ri_stat   = space
*              ri_crby   = sy-uname
*              ri_cron   = sy-datum
*              ri_reqno  =  space
*   where docno          = p_docno and
*          trans         =  zmm_emdhdr-trans   and
*          item_no       =  p_itemno  .
*  endif.
*& ----<< +003
ENDFORM.                    " reset_bank_conf_doc
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_ITEM
*&---------------------------------------------------------------------*
*       Check Whether any line item selected or not
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item.
  DATA l_found .
  l_found = 1.
  g_error = 0.
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    IF  wa_emddtl-status = 'A' OR
        wa_emddtl-status = 'Y'.
      MESSAGE i440(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status = 'V'.
      MESSAGE i443(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status = 'E'.
      g_ans = 1.
      g_error = 1.
      MESSAGE i452(zmm).
    ELSEIF  wa_emddtl-status = 'S'.
      MESSAGE i446(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF  wa_emddtl-status = 'P'.
      MESSAGE i495(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status NE 'B'.
      MESSAGE i497(zmm).
      g_ans = 1.
      g_error = 1.

    ENDIF.
  ENDLOOP.
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i436(zmm).
  ENDIF.
ENDFORM.                    " CHECK_SEL_ITEM
*&---------------------------------------------------------------------*
*&      Form  check_sel_reset_item
*&---------------------------------------------------------------------*
*     Check Whether Any line item selected for Reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_reset_item.

  DATA l_found .
  l_found = 1.
  g_error = 0.
  CLEAR g_status .
  CLEAR g_itemno.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    g_itemno = wa_emddtl-item_no.

    IF wa_emddtl-status = 'N'.
      g_ans = 1.
      g_error = 1.
      MESSAGE i568(zmm).
    ENDIF.
*+004
    IF NOT wa_emddtl-ri_reqno IS INITIAL.
      IF wa_emddtl-ri_reqno+14(1) = 'R'.
        IF NOT ( wa_emddtl-status = 'E' OR wa_emddtl-status = 'V' ).
          g_ans = 1.
          g_error = 1.
          MESSAGE i511(zmm).
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
*+004
    CASE wa_emddtl-inst_type.

      WHEN 'BG'.

        IF  wa_emddtl-status = 'D' .
          g_reset_status   = 'N' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'B' .   " send to bank
          g_reset_status   = 'N' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'A' OR wa_emddtl-status = 'Y'.
          g_reset_status   = 'B' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'S' .   "Submit to FI
          g_reset_status      = 'A' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'P' .   "Accepted by FI
          g_reset_status     = 'S' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'V' .    "Invoke
          g_reset_status     = 'P' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'E' .   "Return.
          g_reset_status     = 'B' .
          EXIT.
        ENDIF.
      WHEN 'LC'.
        IF  wa_emddtl-status = 'S' .   "Submit to FI
          g_reset_status      = 'N' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'P' .   "Accepted by FI
          g_reset_status     = 'S' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'V' OR
                wa_emddtl-status = 'E' .   "Invoke/Return.
          g_reset_status     = 'P' .
          EXIT.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i438(zmm).
  ENDIF.
ENDFORM.                    " check_sel_reset_item
*&---------------------------------------------------------------------*
*&      Form  update_post_conf
*&---------------------------------------------------------------------*
*       Update Status when Post Confirmation
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_post_conf USING p_ad.
  DATA l_status .
  IF p_ad = 1.
    l_status = 'A'.  "Accepted By the bank
  ELSEIF p_ad = 2.
    l_status = 'Y'.  "Denied  By the  Bnak
  ELSE.
  ENDIF.
*&----> Flag 'A' is set for post Confirmation accepted
*----  other wise 'Y' for deny
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE status = 'B' AND
           sel = 'X'.

    UPDATE zmm_emddtl
           SET status = l_status
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status     = 'B'.
  ENDLOOP.
ENDFORM.                    " update_post_conf
*&---------------------------------------------------------------------*
*&      Form  get_item_details
*&---------------------------------------------------------------------*
*      Get Item Details
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_item_details.
  DATA l_found .
  CLEAR g_status.
  CLEAR g_reqno .
  CLEAR g_reqtext .
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 'X'.
    CASE wa_emddtl-status .
      WHEN 'N'.
        g_status        = text-040.  "Receipt
      WHEN 'B'.
        g_status        = text-036.  "Send for Bank Confirmation' .
      WHEN 'A'.
        g_status        = text-037 . "'Acceped By Bank'.
      WHEN  'Y'.
        g_status        = text-038 . " 'Denied  By Bank'.
      WHEN  'V'.
        g_status       =  text-039 . "'Invoked'.
      WHEN 'S'.
        g_status       =  text-043 .
      WHEN 'I'.
        g_status       =  text-054 .
      WHEN 'D'.
        g_status       =  text-047 .
      WHEN 'E'.
        g_status       =  text-058 .
      WHEN 'P'.
        g_status      = text-061.
    ENDCASE.
*+003
    IF wa_emddtl-ri_stat = '1'.
      g_reqtext   = text-058.
    ELSEIF wa_emddtl-ri_stat = '2'.
      g_reqtext   = text-078.
    ELSEIF wa_emddtl-ri_stat = '3'.
      g_reqtext  = text-080.
    ELSE.
      g_reqtext = 'Nill'.
    ENDIF.
  ENDLOOP.

  IF NOT wa_emddtl-ri_reqno IS INITIAL. "AND wa_emddtl-ri_stat NE '3' .
    g_reqno = wa_emddtl-ri_reqno.
  ELSE.
    g_reqno = 'Nill'.
  ENDIF.
*+003

  MOVE wa_emddtl-amount  TO zmm_emddtl-amount.
  IF l_found = 'X'.
    CALL SCREEN 0140 STARTING AT 10 5  ENDING AT 65 15 .
  ELSE.
    MESSAGE i442(zmm).
  ENDIF.
ENDFORM.                    " get_item_details
*&---------------------------------------------------------------------*
*&      Form  get_bglc_data
*&---------------------------------------------------------------------*
*   Get BG/LC Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bglc_data.
  REFRESH  ist_emddtl    .
  CLEAR:   ist_emddtl    ,
           wa_emdhdr     ,
           wa_emddtl01   ,
           g_status      ,
           g_reset       ,
           g_dansw       ,
           g_reset       .


  IF NOT zmm_emdhdr-docno IS INITIAL.
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = G_IDOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
*&--> Display Status using variable g_status.
      IF wa_emdhdr-status = 'N'.
        g_status  = 'Created'.
      ELSEIF wa_emdhdr-status = 'D'.
        IF prev_okcode = 'DELE'.
          MESSAGE e425(zmm).
        ELSE.
          g_status  = 'Deleted'.
        ENDIF.
      ELSE.
        g_reset   = 0.
      ENDIF.
*&--<
      IF wa_emdhdr-status = 'D'.
        MESSAGE w416(zmm) WITH  wa_emdhdr-docno.
*       perform popup_for_reset  .
        g_reset = 1.
      ENDIF.

*&-----> Get Place NAme from table zmm_emdloc  .

      SELECT SINGLE locname FROM zmm_emdloc INTO g_locname
             WHERE locid = wa_emdhdr-place .
*&-----<
      MOVE-CORRESPONDING wa_emdhdr TO zmm_emdhdr .
      SELECT * FROM zmm_emddtl INTO TABLE ist_emddtl01
               WHERE docno = wa_emdhdr-docno  AND
                     trans = wa_emdhdr-trans  AND
                     inst_type IN ('BG','LC') ORDER BY PRIMARY KEY.
      IF sy-subrc = 0.
*&--> Append EMD Item data into table control internal table ist_emddtl.
*Start of addition by SAB_SARVANAN on 12/06/2009
        CLEAR wa_emddtl.
*End of addition by SAB_SARVANAN on 12/06/2009
        LOOP AT ist_emddtl01 INTO wa_emddtl01.
          MOVE-CORRESPONDING wa_emddtl01 TO wa_emddtl.
          APPEND wa_emddtl TO ist_emddtl.
*Start of addition by SAB_SARVANAN on 12/06/2009
          CLEAR wa_emddtl01.
          CLEAR wa_emddtl.
*End of addition by SAB_SARVANAN on 12/06/2009
        ENDLOOP.
*&--<
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
    ELSE.
      MESSAGE e411(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " get_bglc_data
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_ITEM_INNOKE
*&---------------------------------------------------------------------*
*      Check Selected Items before Invoke
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_invoke.
  DATA l_found .
  l_found = 1.
  g_error = 0.

*&---> Check whether any line Item  selected or Not

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i445(zmm).
  ENDIF.

*+003
  IF zmm_emdhdr-trans = 'SDT'.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF wa_emddtl-ri_stat  = '1'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i579(zmm).
        EXIT.
      ELSEIF  wa_emddtl-ri_stat = '1' AND
          wa_emddtl-status = 'S' .
        g_ans = 1.
        g_error = 1.
        MESSAGE  i575(zmm).
        EXIT.
      ELSEIF wa_emddtl-ri_stat NE '2'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i577(zmm).
        EXIT.
      ENDIF.

      IF  wa_emddtl-status = 'V'.
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status =   'Y'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i498(zmm).
      ELSEIF wa_emddtl-status NE 'P'.
        MESSAGE i496(zmm).
        g_ans = 1.
        g_error = 1.
      ENDIF.
    ENDLOOP.
*+003

  ELSE.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
* +003
      IF wa_emddtl-ri_stat = '1' .
        g_ans = 1.
        g_error = 1.
        MESSAGE  i586(zmm).
        EXIT.
      ELSEIF wa_emddtl-ri_stat NE '2' AND wa_emddtl-status NE 'E'.
        g_ans = 1.
        g_error = 1.
        MESSAGE  i585(zmm).
        EXIT.
      ENDIF.


* +003
      IF  wa_emddtl-status = 'V'.
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status =   'Y'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i498(zmm).
      ELSEIF wa_emddtl-status NE 'P'.
        MESSAGE i496(zmm).
        g_ans = 1.
        g_error = 1.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CHECK_SEL_ITEM_INNOKE
*&---------------------------------------------------------------------*
*&      Form  invoke_docu
*&---------------------------------------------------------------------*
*       Invoke Document after Confirmation
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM invoke_docu.
*&----> Flag 'S' is set for post Confirmation
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE  sel = 'X'.

    UPDATE zmm_emddtl
           SET status = 'V' ridate = sy-datum riuname = sy-uname
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status     = 'P'.
  ENDLOOP.
ENDFORM.                    " invoke_docu
*&---------------------------------------------------------------------*
*&      Form  set_lock
*&---------------------------------------------------------------------*
*      Set Lock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_lock.
  IF zmm_emdhdr-trans IS INITIAL.
    zmm_emdhdr-trans = wa_emdhdr-trans .
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZMM_ZMMEMDHDR'
    EXPORTING
      mode_zmm_emdhdr = 'E'
      mandt           = sy-mandt
      trans           = zmm_emdhdr-trans
      docno           = g_idocno
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " set_lock
*&---------------------------------------------------------------------*
*&      Form  release_lock
*&---------------------------------------------------------------------*
*       Release Lock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.
  CALL FUNCTION 'DEQUEUE_EZMM_ZMMEMDHDR'
    EXPORTING
      mode_zmm_emdhdr = 'E'
      mandt           = sy-mandt
      trans           = zmm_emdhdr-trans
      docno           = zmm_emdhdr-docno.

ENDFORM.                    " release_lock

*&---------------------------------------------------------------------*
*&      Form  RELEASE_LOCK_REF
*&---------------------------------------------------------------------*
*       Release Lock - REFUND/FORFEIT/EMD-SD CONVERT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock_ref.

  CALL FUNCTION 'DEQUEUE_EZMM_ZMMEMDREF'
    EXPORTING
      mode_zmm_emdref = 'E'
      mandt           = sy-mandt
      docno           = zmm_emdref-docno.
ENDFORM.                    " RELEASE_LOCK_REF
*&---------------------------------------------------------------------*
*&      Form  popup_deny_accept
*&---------------------------------------------------------------------*
*       Popup for Bank Accept/Deny if 'Post Confirmation'
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_deny_accept.
  CLEAR g_ans_ad  .
  CALL FUNCTION 'POPUP_TO_DECIDE'
    EXPORTING
      textline1    = text-035
      text_option1 = text-032
      text_option2 = text-033
      titel        = text-034
      start_column = 25
      start_row    = 6
    IMPORTING
      answer       = g_ans_ad.

*CALL FUNCTION 'POPUP_TO_CONFIRM'
*  EXPORTING
*   TITLEBAR                    = text-034
*    TEXT_QUESTION               = text-035
*   TEXT_BUTTON_1               =  'Accepted by Bank'(032)"text-032
*   TEXT_BUTTON_2               = 'Denied by Bank'(033)"text-033
*   START_COLUMN                = 25
*   START_ROW                   = 6
* IMPORTING
*   ANSWER                      = g_ans_ad
* EXCEPTIONS
*   TEXT_NOT_FOUND              = 1
*   OTHERS                      = 2.
ENDFORM.                    " popup_deny_accept
*&---------------------------------------------------------------------*
*&      Form  check_sel_item_sndfi
*&---------------------------------------------------------------------*
*      Check Selected Line Item for Sending to FI
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_sndfi.
  DATA l_found .
  l_found = 1.
  g_error = 0.
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i448(zmm).
  ENDIF.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.

    CASE wa_emddtl-inst_type .

      WHEN 'BG'.
        IF  wa_emddtl-status = 'S'.
          MESSAGE i446(zmm).
          g_ans = 1.
          g_error = 1.
        ELSEIF wa_emddtl-status = 'V'.
          MESSAGE i443(zmm).
          g_ans = 1.
          g_error = 1.
        ELSEIF wa_emddtl-status = 'E'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i452(zmm).
        ELSEIF wa_emddtl-status = 'P'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i495(zmm).
        ELSEIF wa_emddtl-status =  'Y'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i498(zmm).
        ELSEIF wa_emddtl-status NE  'A'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i447(zmm).
        ENDIF.
      WHEN  'LC'.
        IF wa_emddtl-status = 'S'.
          MESSAGE i446(zmm).
          g_ans = 1.
          g_error = 1.
        ELSEIF wa_emddtl-status = 'P'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i495(zmm).
        ELSEIF wa_emddtl-status = 'V'.
          MESSAGE i443(zmm).
          g_ans = 1.
          g_error = 1.
        ELSE.
          g_ans = '0' .
          g_error = 0.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " check_sel_item_sndfi
*&---------------------------------------------------------------------*
*&      Form  update_status_subfi
*&---------------------------------------------------------------------*
*      Update Document Status after sending to FI
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_status_subfi.

*&-----> Update Status Flag with 'S'   "send to FI
  LOOP AT  ist_emddtl  INTO wa_emddtl  WHERE
            sel = 'X'.
*where status = 'A'
    UPDATE zmm_emddtl
           SET status = 'S'
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no .
  ENDLOOP.
ENDFORM.                    " update_status_subfi
*&---------------------------------------------------------------------*
*&      Form  check_sel_item_RETN
*&---------------------------------------------------------------------*
*       Check selected items before Return
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_retn   .

  DATA l_found .
  l_found = 1.
  g_error = 0.
*&---> Check whether any line Item  selected or Not
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i451(zmm).
  ENDIF.

*&-->+003
  IF zmm_emdhdr-trans = 'SDT'.

    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-ri_stat = '1' AND
           wa_emddtl-status = 'S' .
        g_ans = 1.
        g_error = 1.
        MESSAGE  e575(zmm).
        EXIT.
      ELSEIF wa_emddtl-ri_stat  = '2'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e578(zmm).
      ENDIF.

      IF  wa_emddtl-status = 'E'.
        MESSAGE e452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE e443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'N'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e497(zmm).
      ELSEIF wa_emddtl-status = 'B'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e447(zmm).

      ELSEIF  wa_emddtl-status = 'Y'   AND g_mmret NE 'X' .
*+004
        AUTHORITY-CHECK OBJECT 'ZMMBGLC'
             ID 'ACTVT' FIELD  '16'   .
        IF sy-subrc = 0 .
          g_ans = 1.
          g_error = 1.
          MESSAGE e515(zmm).
        ELSE.
          g_ans = 1.
          g_error = 1.
          MESSAGE e505(zmm).
        ENDIF.
      ELSEIF wa_emddtl-ri_stat NE '1' AND g_mmret NE 'X'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e576(zmm).
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.

      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'N'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i497(zmm).
      ELSEIF wa_emddtl-status = 'B'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i447(zmm).
      ELSEIF  wa_emddtl-status = 'Y'   AND g_mmret NE 'X' .
*+004
        AUTHORITY-CHECK OBJECT 'ZMMBGLC'
             ID 'ACTVT' FIELD  '16'   .
        IF sy-subrc = 0 .
          MESSAGE e515(zmm).
        ELSE.
          MESSAGE e505(zmm).
        ENDIF.
      ELSEIF wa_emddtl-status = 'A'  AND g_mmret NE 'X' .
*+004
        AUTHORITY-CHECK OBJECT 'ZMMBGLC'
             ID 'ACTVT' FIELD  '16'   .
        IF sy-subrc = 0 .
          MESSAGE e516(zmm).
        ELSE.
          MESSAGE e505(zmm).
        ENDIF.
*+004
*-004
*        g_ans = 1.
*        g_error = 1.
*        message i498(zmm).
*
      ENDIF.
* +003
      IF wa_emddtl-ri_stat = '2'.
        g_ans = 1.
        g_error = 1.
        MESSAGE  e587(zmm).
      ELSEIF  ( wa_emddtl-ri_stat = space OR wa_emddtl-ri_stat = '3' ) AND
                               g_mmret NE 'X'  .
        g_ans = 1.
        g_error = 1.
        MESSAGE  e588(zmm).
      ENDIF.

*
*      if  wa_emddtl-ri_reqno+14(1) ne  'R' AND g_MMRET NE 'X' .
*        g_ans = 1.
*        g_error = 1.
*        message  i588(zmm).
*      endif.
* +003


*+004
*      if p_stat ne 'X'.
*        if wa_emddtl-status = 'S'.
*          g_ans = 1.
*          g_error = 1.
*          message i496(zmm).
*        elseif wa_emddtl-status = 'A'.
*          g_ans = 1.
*          g_error = 1.
*          message i450(zmm).
*        endif.
*+004
*     endif.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " check_sel_item_RETN
*&---------------------------------------------------------------------*
*&      Form  retrun_docu
*&---------------------------------------------------------------------*
*     Update status of return Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM retrun_docu.

*&----> Flag 'E' is set for post Confirmation
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE sel = 'X' .
    UPDATE zmm_emddtl
           SET status = 'E' ridate = sy-datum riuname = sy-uname
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status    IN ('P','Y','A').
  ENDLOOP.
ENDFORM.                    " retrun_docu
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_S145
*&---------------------------------------------------------------------*
*     Save Data of screen 145
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_data_s145.

  CLEAR   : ist_dtl, ist_scrdtl .
  REFRESH : ist_scrdtl .
  REFRESH  ist_emddtl01.
  CLEAR:   wa_emddtl,
           wa_emddtl01.
  CLEAR    g_amount.
  LOOP AT ist_emddtl INTO wa_emddtl .
    g_amount  = g_amount + wa_emddtl-amount    .

    MOVE-CORRESPONDING wa_emddtl  TO    wa_emddtl01           .
    MOVE wa_emddtl-status         TO    wa_emddtl01-status    .
    MOVE g_docno                  TO    wa_emddtl01-docno     .
    MOVE zmm_emdhdr-trans         TO    wa_emddtl01-trans     .
    MOVE zmm_emdhdr-ebeln         TO    wa_emddtl01-ebeln     .
    MOVE zmm_emdhdr-vendorno      TO    wa_emddtl01-vendno    .
    MOVE zmm_emdhdr-tenderno      TO    wa_emddtl01-tendno    .
    MOVE wa_emdhdr-bstyp          TO    wa_emddtl01-bstyp      .
    MOVE space                    TO   wa_emddtl01-fi_parkno  .
    wa_emddtl01-crby = sy-uname .
    wa_emddtl01-cron = sy-datum .
    MOVE g_idocno             TO  wa_emddtl01-docno  .
    APPEND  wa_emddtl01 TO ist_emddtl01 .
  ENDLOOP.
  IF NOT g_amount IS INITIAL.
    UPDATE zmm_emdhdr
         SET amount  = g_amount
         WHERE trans = zmm_emdhdr-trans  AND
               docno = g_idocno.
    IF sy-subrc = 0.
      g_save_h = 0.
    ELSE.
      g_save_h = 1.
    ENDIF.
  ENDIF.

  IF NOT ist_emddtl01 IS INITIAL.

    MODIFY zmm_emddtl FROM TABLE ist_emddtl01.
    IF sy-subrc = 0.
      g_save_i = 0.
    ELSE.
      g_save_i = 1.
    ENDIF.
  ENDIF.
* Update CDPOS and CDHDR table - Change document for fields
* RSCODE, AMOUNT and INST_VDT (table ZMM_EMDDTL).

  ist_scrdtl[] = ist_emddtl[] ." screen fields
  LOOP AT ist_scrdtl .

    READ TABLE ist_dtl WITH KEY docno   = ist_scrdtl-docno
                                item_no = ist_scrdtl-item_no.

    IF ist_dtl-rscode <> ist_scrdtl-rscode .
      PERFORM chg_docu_rscode .
    ENDIF .
    READ TABLE ist_dtl WITH KEY docno = ist_scrdtl-docno
                                item_no = ist_scrdtl-item_no.

    IF ist_dtl-amount <> ist_scrdtl-amount .
      PERFORM chg_docu_amount .
    ENDIF .
    READ TABLE ist_dtl WITH KEY docno = ist_scrdtl-docno
                              item_no = ist_scrdtl-item_no.

    IF ist_dtl-inst_vdt <> ist_scrdtl-inst_vdt .
      PERFORM chg_docu_validity .
    ENDIF .
  ENDLOOP .
ENDFORM.                    " MODIFY_DATA_S145
*&---------------------------------------------------------------------*
*&      Form  CHECK_BGLC_DOC
*&---------------------------------------------------------------------*
*       Cehck BG/LC Document
*---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bglc_doc.

  SELECT SINGLE  * FROM zmm_emddtl
         WHERE docno  = zmm_emdhdr-docno AND
                 inst_type IN ('BG','LC').

  IF sy-subrc = 0.
  ELSE.
    MESSAGE e461(zmm).
  ENDIF.
ENDFORM.                    " CHECK_BGLC_DOC
*&---------------------------------------------------------------------*
*&      Form  check_valid_docno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_valid_docno.
  DATA: l_inst_type LIKE zmm_emddtl-inst_type .
  CLEAR wa_emdhdr.
  CLEAR g_ebeln  .

  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.
    CLEAR g_ebeln  .
*---------------------------------------------------------------------*
*  If instrument BG/LC exist in Doc. then don't allow for*
*  Refund/forfeit/Conversion.
    SELECT INST_TYPE FROM ZMM_EMDDTL INTO L_INST_TYPE UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc = 0.
      IF l_inst_type = 'BG' OR l_inst_type = 'LC'.
        MESSAGE e560(zmm).
      ENDIF.
    ENDIF.
*---------------------------------------------------------------------*
*&-- Check whether transaction is Tender Fee.
*& If tender fee no Forfeit Allowed.
    IF g_doccat = text-016 AND wa_emdhdr-trans = 'TFS'.
      MESSAGE e555(zmm).
    ENDIF.

    IF g_doccat = 'EMD-SD CNV' AND wa_emdhdr-trans = 'TFS'.
      MESSAGE e558(zmm).
    ENDIF.

    IF g_doccat = 'EMD-SD CNV' AND wa_emdhdr-trans = 'SDT'.
      MESSAGE e559(zmm).
    ENDIF.
    MOVE wa_emdhdr TO zmm_emdhdr.
*Deleted
    IF wa_emdhdr-status = 'D'.
      MESSAGE e425(zmm).
* Partially Parked
    ELSEIF  wa_emdhdr-status = 'K'.
      MESSAGE e462(zmm).
*   Fully Parked
    ELSEIF wa_emdhdr-status = 'U'.
    ELSEIF wa_emdhdr-status = 'N'.
      MESSAGE e478(zmm).
    ENDIF.
  ELSE.
    SELECT * FROM ZMM_EMDREF INTO WA_EMDREF UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      CLEAR g_ebeln .
*------ For EMD- SD converted documents further conversion is not *  *
* possible.

      IF wa_emdref-rfcstat = 'C' AND  g_doccat = 'EMD-SD CNV' .
        MESSAGE e564(zmm).
      ENDIF.

*--------<
*-------> Raise error if document status is 'R' OR 'F' in create mode.
      IF ok_code = 'CRET'.
        IF  wa_emdref-rfcstat NE  'C'.
          MESSAGE e565(zmm).
        ENDIF.
      ENDIF.
*-------<

      IF wa_emdref-status = 'D'.
        MESSAGE e425(zmm).
      ELSEIF  wa_emdref-status NE 'S'.
        MESSAGE e450(zmm).
      ENDIF.
*---- IF valid docno then select header details from table zmm_emdhdr
* based on refdocno.
      SELECT SINGLE * FROM zmm_emdhdr INTO wa_emdhdr
           WHERE docno  = wa_emdref-refdoc .

      MOVE wa_emdref-amount TO zmm_emdhdr-amount.
      MOVE wa_emdref-currency TO zmm_emdref-currency.
      MOVE wa_emdref-ebeln TO g_ebeln  .
    ELSE.
      MESSAGE e411(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_valid_docno

*&---------------------------------------------------------------------*
*&      Form  check_reason_code
*&---------------------------------------------------------------------*
*       Check Reason code.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_reason_code USING p_rscode.

*----------------------------------------------------------------------*
  SELECT SINGLE * FROM zmm_emdrscode
    WHERE rscode =  p_rscode.
  IF sy-subrc NE 0.
    MESSAGE e467(zmm).
  ENDIF.
*----------------------------------------------------------------------*
  IF zmm_emdhdr-trans = 'TFS'.
    IF wa_tc105-rscode < 100 OR wa_tc105-rscode > 199 .
      MESSAGE e464(zmm).
    ENDIF.
  ELSEIF  zmm_emdhdr-trans = 'EMD' .
    IF wa_tc105-rscode < 200 OR wa_tc105-rscode > 299  .
      MESSAGE e465(zmm).
    ENDIF.
  ELSEIF zmm_emdhdr-trans = 'SDT'.
    IF wa_tc105-rscode <  300  OR wa_tc105-rscode >  399   .
      MESSAGE e466(zmm).
    ENDIF.
*-------  < Check Reason code > ---------------------------------------*
  ENDIF.
ENDFORM.                    " check_reason_code
*&---------------------------------------------------------------------*
*&      Form  rest_rfc_doc
*&---------------------------------------------------------------------*
*      Reset Refund/Forfeit/EMD-SD Convert Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rest_rfc_doc USING p_docno.

  DATA: l_rfc_stat.

  SELECT RFCSTAT INTO L_RFC_STAT
 FROM ZMM_EMDREF UP TO 1 ROWS WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  UPDATE zmm_emdref
      SET status = l_rfc_stat
       rfcchby = sy-uname
       rfcchon = sy-datum
      WHERE docno = p_docno  .
  IF sy-subrc = 0.
    MESSAGE s471(zmm).
  ENDIF.
ENDFORM.                    " rest_rfc_doc
*&---------------------------------------------------------------------*
*&      Form  CLEAR_TABLE
*&---------------------------------------------------------------------*
*   Clear Internal Table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_table.
  REFRESH: ist_emddtl01,
           ist_emddtl   .
ENDFORM.                    " CLEAR_TABLE
*&---------------------------------------------------------------------*
*&      Form  DEL_LINE_ITEM
*&---------------------------------------------------------------------*
*      Delete Line Item from table ZMM_EMDDTL USING Internal table
*      ist_del_emddtl.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_line_item.

  LOOP AT ist_del_emddtl INTO wa_emddtl.
    DELETE  FROM zmm_emddtl
            WHERE item_no = wa_emddtl-item_no AND
                  trans   = wa_emddtl-trans   AND
                  docno   = wa_emddtl-docno   .

  ENDLOOP.
*&--------------------------------------------------------------*
*  Delete all Line item for the corresponding Docno and Item no
*  from table zmm_emddtl.

  DELETE FROM zmm_emddtl WHERE  trans   = wa_emddtl-trans   AND
                    docno   = wa_emddtl-docno   .


  REFRESH ist_del_emddtl .
  CLEAR wa_emddtl.
ENDFORM.                    " DEL_LINE_ITEM
*&---------------------------------------------------------------------*
*&      Form  check_rfc_amount_receipt
*&---------------------------------------------------------------------*
*       Check Balance amount at the time of creation. Refund/Forfeit/
*        EMD-SD Convert
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfc_amount_receipt.

*&---> Check Refund Amount
  PERFORM get_total_ref  .
*&---<
  IF   g_tot_ref IS INITIAL.
    g_balamt = zmm_emdhdr-amount .
  ELSE.
    g_balamt = zmm_emdhdr-amount - g_tot_ref.
  ENDIF.

  IF zmm_emdref-amount <  g_balamt AND NOT zmm_emdref-amount IS INITIAL.
    g_balamt  =  g_balamt - zmm_emdref-amount   .
  ELSEIF  zmm_emdref-amount > g_balamt .
    MESSAGE e429(zmm) WITH g_doccat .
  ELSEIF   zmm_emdref-amount IS INITIAL.
    g_balamt  = zmm_emdhdr-amount - g_tot_ref.
  ELSEIF zmm_emdref-amount =  g_balamt AND NOT zmm_emdref-amount IS
     INITIAL.
    g_balamt  =  g_balamt - zmm_emdref-amount   .
  ENDIF.

ENDFORM.                    " check_rfc_amount_receipt
*&---------------------------------------------------------------------*
*&      Form  get_head_status
*&---------------------------------------------------------------------*
*      Get Header Status using g_status
*----------------------------------------------------------------------*
*      -->P_G_STAT  text
*----------------------------------------------------------------------*
FORM get_head_status USING    p_stat.

  CLEAR :
          g_status  ,
          g_hstatus .
  IF  p_stat    = 'N'.
    g_status    = text-040.
    g_hstatus   = text-040.
  ELSEIF p_stat = 'U'.
    g_status    = text-049.
    g_hstatus   = text-049.
  ELSEIF p_stat = 'D'.
    g_status    = text-047.
    g_hstatus   = text-047.
  ELSEIF p_stat = 'K'.
    g_status    = text-055.
    g_hstatus   = text-055.
  ELSEIF p_stat = 'X'.
    g_status    = text-057.
    g_hstatus   = text-057.
  ELSEIF p_stat = 'J'.
    g_status    = text-062.
    g_hstatus   = text-062.
  ELSEIF p_stat = 'Q'.
    g_status    = text-063.
    g_hstatus   = text-063.
  ELSEIF p_stat = 'O'.
    g_status    = text-065.
    g_hstatus   = text-065.
  ELSEIF p_stat = 'T'.
    g_status    = text-066.
    g_hstatus   = text-066.
  ELSEIF p_stat = 'X'.
    g_status    = text-067.
    g_hstatus   = text-067.
* Begin of <RD1K963111>
  ELSEIF p_stat = 'R'.
    g_status    = text-015.
    g_hstatus   = text-015.
  ELSEIF p_stat = 'I'.
    g_status    = text-054.
    g_hstatus   = text-054.
  ELSEIF p_stat = 'G'.
    g_status    = text-083.
    g_hstatus   = text-083.
* End of <RD1K963111>
*+007 : Status
  ELSEIF p_stat = '0'.

    PERFORM get_status USING    p_stat
                       CHANGING g_status.

    MOVE g_status TO g_hstatus.
*+007 : End

  ENDIF.
ENDFORM.                    " get_head_status
*&---------------------------------------------------------------------*
*&      Form  get_item_status
*&---------------------------------------------------------------------*
*      Get Item status.
*----------------------------------------------------------------------*
*      -->P_WA_EMDDTL_STATUS  text
*----------------------------------------------------------------------*
FORM get_item_status USING    p_status.

  CLEAR g_status.
  CASE p_status .
    WHEN 'N'.
      g_status        = text-040.  "Receipt
    WHEN 'B'.
      g_status        = text-036.  "Send for Bank Confirmation' .
    WHEN 'A'.
      g_status        = text-037 . "'Acceped By Bank'.
    WHEN  'Y'.
      g_status        = text-038 . " 'Denied  By Bank'.
    WHEN  'V'.
      g_status       =  text-039 . "'Invoked'.
    WHEN 'S'.
      g_status       =  text-043 .  "Submitted to FI
    WHEN 'I'.
      g_status       =  text-054 .  "Parked to FI
    WHEN 'D'.
      g_status       =  text-047 .   "Deleted
    WHEN 'R'.
      g_status       =  text-015.    "Refund
    WHEN 'F'.
      g_status       =  text-016.    "Forfeit
    WHEN 'C'.
      g_status       =  text-017.    "Convert
    WHEN 'P'.
      g_status      =  text-061.    "Accepted by FI
    WHEN 'E'.
      g_status      =  text-058.    "Return BG/LC Document.
  ENDCASE.

ENDFORM.                    " get_item_status
*&---------------------------------------------------------------------*
*&      Form  get_ref_doc_stat
*&---------------------------------------------------------------------*
*      Get Refund/Forfeit/EMd-Sd Conv. Doc. Status
*----------------------------------------------------------------------*
*      -->P_G_DOCNO  text
*----------------------------------------------------------------------*
FORM get_ref_doc_stat USING    p_docno.
  DATA:l_stat.
  SELECT STATUS FROM ZMM_EMDREF INTO L_STAT UP TO 1 ROWS
 WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.
    PERFORM get_item_status USING l_stat.
  ENDIF.
ENDFORM.                    " get_ref_doc_stat

*&---------------------------------------------------------------------*
*&      Form  check_doc_status
*&---------------------------------------------------------------------*
*       Check Document Status before reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_doc_status USING p_docno.

  DATA: wa_emdref_temp LIKE zmm_emdref.
  SELECT * FROM ZMM_EMDREF INTO WA_EMDREF_TEMP UP TO 1 ROWS
 WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0.
    IF wa_emdref_temp-status = 'N'.
      MESSAGE e472(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_doc_status
*&---------------------------------------------------------------------*
*&      Form  check_header_docu
*&---------------------------------------------------------------------*
*      Check Document before deletion.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_header_docu.
  PERFORM get_total_ref .
  IF  g_tot_ref NE 0.
    IF  g_tot_ref NE zmm_emdhdr-amount.
      MESSAGE e480(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_header_docu
*&---------------------------------------------------------------------*
*&      Form  update_head_status_105
*&---------------------------------------------------------------------*
*       Update header stsatus
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_head_status_105.
  DATA: l_prev_stat.
  DATA: l_found .
  LOOP AT ist_emddtl INTO wa_emddtl.
    IF sy-tabix = 1.
      l_prev_stat = wa_emddtl-status.
    ENDIF.
    IF wa_emddtl-status NE l_prev_stat.
      l_found = 'X'.
    ELSE.
      l_found = space.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " update_head_status_105
*&---------------------------------------------------------------------*
*&      Form  UPDATE_HEADER_STATUS
*&---------------------------------------------------------------------*
*     Update Status at Header Level.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_header_status  .
*using p_docno.
  DATA: wa_emddtl_tmp LIKE wa_emddtl.
  DATA: l_h_stat.
  DATA: l_found .
  CLEAR g_h_status.
*----------------------------------------------------------------------*
* Before Save Update Header Status based on the the document status at
* Item level.
* Eg. If All line items are parked then update Header status as Fully *
* parked.
*----------------------------------------------------------------------*

  LOOP AT ist_emddtl INTO wa_emddtl_tmp.
    IF sy-tabix = 1.
      l_h_stat = wa_emddtl_tmp-status.
    ENDIF.

    IF l_h_stat NE wa_emddtl_tmp-status.
      l_found = 'X'.
      EXIT.
    ELSE.
      l_found = '0'.
    ENDIF.
  ENDLOOP.

  IF l_found NE 'X'.
    IF l_h_stat = 'I'.
      g_h_status = 'U'.
    ELSEIF l_h_stat = 'N'.
      g_h_status = 'N'.
    ENDIF.
  ELSE.
  ENDIF.
ENDFORM.                    " UPDATE_HEADER_STATUS
*&---------------------------------------------------------------------*
*&      Form  check_rfc_docu_status
*&---------------------------------------------------------------------*
*      Check Refund/Forfeit/Convert Document Status
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfc_docu_status.
*--------- Check ZMM_EMDREF ----------------------------*
  SELECT * FROM ZMM_EMDREF INTO WA_EMDREF UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF prev_okcode = 'DELE'.
    IF wa_emdref-status = 'R' OR
       wa_emdref-status =  'F'.
    ELSE.
      IF wa_emdref-status = 'D'.
        MESSAGE e425(zmm).
      ELSEIF wa_emdref-status = 'I'.
        MESSAGE e482(zmm)   .
      ENDIF.
    ENDIF.
  ELSEIF prev_okcode = 'UNDEL'.
    IF wa_emdref-status =  'R' OR
     wa_emdref-status   =  'F' OR
     wa_emdref-status   = 'I'.
      MESSAGE e483(zmm).
    ELSE.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_rfc_docu_status
*&---------------------------------------------------------------------*
*&      Form  CHECK_AMOUNT_BF_RESET
*&---------------------------------------------------------------------*
*      Check Balance amount before Reset.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_amount_bf_reset.
  PERFORM get_total_rfc_amt  .
ENDFORM.                    " CHECK_AMOUNT_BF_RESET
*&---------------------------------------------------------------------*
*&      Form  get_total_rfc_amt
*&---------------------------------------------------------------------*
*    This subroutine is being used for  getting tot Refund/Forfeit/
*    EMD-SD Conv. at the time of RESET
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_total_rfc_amt .
  DATA: wa_emdref_temp  LIKE zmm_emdref.
  DATA: wa_emdref_t001  LIKE zmm_emdref.
  DATA: l_h_amt LIKE    zmm_emdhdr-amount.
  DATA: l_bal_amt       LIKE zmm_emdhdr-amount .
  CLEAR l_h_amt .
  CLEAR : wa_emdref_temp ,
          wa_emdref_t001 .
*---------------------------------------------------------------------*
*  Get Ref docno.
  SELECT * FROM ZMM_EMDREF INTO WA_EMDREF_TEMP UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

* Check total amount at header level.
  IF sy-subrc = 0.
    SELECT AMOUNT INTO L_H_AMT FROM ZMM_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = WA_EMDREF_TEMP-REFDOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*-- Check in case of converted Document. search in table ZMM_EMDREF.
    IF  sy-subrc NE 0.
      SELECT * FROM ZMM_EMDREF INTO WA_EMDREF_T001 UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.

        SELECT AMOUNT INTO L_H_AMT FROM ZMM_EMDREF UP TO 1 ROWS
 WHERE DOCNO = WA_EMDREF_T001-REFDOC AND RFCSTAT = 'C'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      ENDIF.
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*
  g_tot_ref  =  0.
  CLEAR g_tot_ref .

  SELECT * FROM zmm_emdref INTO TABLE ist_emdref
             WHERE     refdoc  = wa_emdref_temp-refdoc AND
                       status IN ('R','F','C','I','S').

  IF sy-subrc = 0.
    LOOP AT ist_emdref INTO wa_emdref.
      g_tot_ref = g_tot_ref + wa_emdref-amount.
    ENDLOOP.
  ENDIF.
*----------------------------------------------------------------------*
* Check whether the RFC amount is greater than or equal to Header amt
* then don't allow to RESET Document .

  l_bal_amt  =  l_h_amt - g_tot_ref .

  IF NOT g_tot_ref IS  INITIAL.
    IF  wa_emdref_temp-amount  > l_bal_amt.
      MESSAGE e484(zmm) WITH  wa_emdref_temp-amount  .
    ENDIF.
  ENDIF.
ENDFORM.                    " get_total_rfc_amt
*&---------------------------------------------------------------------*
*&      Form  check_EMDCONV_DOC
*&---------------------------------------------------------------------*
*     Check whether any document exist correspoding to EMD-SD COnv.
*     Document or not  . If it is there then Don't allow to edit/Delete
*     main receipt Document (EMD-SD CONVERTED Document.)
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDREF_DOCNO  text
*----------------------------------------------------------------------*
FORM check_emdconv_doc USING    p_docno.
  DATA: wa_ref LIKE zmm_emdref.
  SELECT SINGLE * FROM zmm_emdref INTO wa_ref
        WHERE refdoc = p_docno  AND
              status IN ('R','I').

  IF sy-subrc = 0.
    MESSAGE e489(zmm).
  ENDIF.
ENDFORM.                    " check_EMDCONV_DOC

*&---------------------------------------------------------------------*
*&      Form  check_comp_code
*&---------------------------------------------------------------------*
*      Check Whether Vendor exist in entered company code or not
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDHDR_CO_CODE  text
*----------------------------------------------------------------------*
FORM check_comp_code USING    p_vcode p_co_code.
  DATA: ist_bukrs LIKE TABLE OF lfb1-bukrs.
  SELECT bukrs  FROM lfb1 INTO TABLE ist_bukrs
     WHERE lifnr = p_vcode        AND
           bukrs = p_co_code      AND
           loevm = space.
  IF sy-subrc NE 0.
    MESSAGE e491(zmm) WITH p_vcode p_co_code .
  ENDIF.
ENDFORM.                    " check_comp_code
*&---------------------------------------------------------------------*
*&      Form  CHECK_VENDOR_PO
*&---------------------------------------------------------------------*
*     Check Vendor no in PO no which is entered.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_vendor_po USING  p_docno.
*p_ebeln
  DATA: wa_hdr_t001  LIKE zmm_emdhdr.
  DATA: l_lifnr LIKE ekko-lifnr.


  SELECT * FROM ZMM_EMDHDR INTO WA_HDR_T001 UP TO 1 ROWS
 WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.

    SELECT SINGLE lifnr FROM ekko INTO l_lifnr
           WHERE  ebeln = zmm_emdref-ebeln.

    IF wa_hdr_t001-vendorno NE  l_lifnr.
      MESSAGE e492(zmm) WITH  wa_hdr_t001-vendorno .
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_VENDOR_PO
*&---------------------------------------------------------------------*
*&      Form  cehck_sel_item_accept
*&---------------------------------------------------------------------*
*       Check selected item before Accept by Finance
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cehck_sel_item_accept.
  DATA l_found .
  l_found = 1.
  g_error = 0.

*&---> Check whether any line Item  selected or Not

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i493(zmm).
  ENDIF.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    IF  wa_emddtl-status = 'E'.
      MESSAGE i452(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status = 'V' .
      MESSAGE i443(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF  wa_emddtl-status = 'P'.
      MESSAGE i495(zmm).
      g_ans = 1.
      g_error = 1.

    ELSEIF wa_emddtl-status NE 'S' .
      MESSAGE i450(zmm).
      g_ans   = 1.
      g_error = 1.
    ELSE.
      g_ans   = 0.
      g_error = 0.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " cehck_sel_item_accept
*&---------------------------------------------------------------------*
*&      Form  accept_docu
*&---------------------------------------------------------------------*
*    Accept Document by
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM accept_docu.

*&----> Flag 'P' is set FOR Accept by FI.
*------- Before this updation the status of the line item must be 'S' ie
* Submitted by FI.

  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE sel = 'X' .

    UPDATE zmm_emddtl
           SET status = 'P'
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status     = 'S'.
  ENDLOOP.

  IF sy-subrc = 0.
    MESSAGE s494(zmm).
  ENDIF.
ENDFORM.                    " accept_docu
*&---------------------------------------------------------------------*
*&      Form  disp_chg_hstry
*&---------------------------------------------------------------------*
*       Sub routine being used to display change history for the fields
*       RSCODE, AMOUNT, INST_VDT.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_chg_hstry.
  DATA :   i_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE  .
  DATA : ist_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE .
  DATA : l_objid LIKE cdhdr-objectid .
  DATA : BEGIN  OF ist_editpos OCCURS 0 .
          INCLUDE STRUCTURE cdshw .
  DATA :  user LIKE sy-uname ,
          date LIKE sy-datum ,
  END OF ist_editpos .
  DATA :   i_editpos TYPE TABLE OF cdshw WITH HEADER LINE .
  DATA : wa_header LIKE cdhdr .
  l_objid = wa_emddtl-docno .

  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZRSCODE'
      objectid                   = l_objid
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.
    CLEAR : i_cdhdr .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      REFRESH i_editpos .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.
      IF sy-subrc =  0.
        LOOP AT i_editpos WHERE fname = 'RSCODE' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP .
  ENDIF .
  REFRESH i_cdhdr .
  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZAMOUNT'
      objectid                   = l_objid
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.

    CLEAR : i_cdhdr, i_editpos  .
    REFRESH : i_editpos .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.
      IF sy-subrc =  0.
        LOOP AT i_editpos WHERE fname = 'AMOUNT' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP .
  ENDIF .

  REFRESH i_cdhdr .
  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZVALIDITY'
      objectid                   = l_objid
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.

    CLEAR : i_cdhdr, i_editpos  .
    REFRESH i_editpos .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.
      IF sy-subrc =  0.
        LOOP AT i_editpos WHERE fname = 'INST_VDT' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP .
  ENDIF .

  WRITE : /5 'Document No. ' , 20 'Field Name', 35 'Old Value',
           50 'New value' , 75 'changed by' , 90 ' changed on' .

  WRITE : /5 sy-uline(95).
  LOOP AT ist_editpos .

    WRITE :/5 wa_emddtl-docno(10), 20 ist_editpos-fname(15) ,
           35 ist_editpos-f_old(10) , 50 ist_editpos-f_new(10) ,
           75 ist_editpos-user(12) , 90 ist_editpos-date  .

  ENDLOOP .

  CLEAR ist_editpos .
  REFRESH ist_editpos .
  CLEAR ok_code .
ENDFORM.                    " disp_chg_hstry
*&---------------------------------------------------------------------*
*&      Form  chg_docu_rscode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chg_docu_rscode.
  DATA : l_objid LIKE cdhdr-objectid .
  l_objid = wa_emddtl-docno .
  ist_nemddtl-docno = ist_scrdtl-docno .
  ist_nemddtl-trans = ist_scrdtl-trans .
  ist_nemddtl-item_no = ist_scrdtl-item_no .
  ist_nemddtl-ebeln = ist_scrdtl-ebeln .
  ist_nemddtl-status = ist_scrdtl-status .
  ist_nemddtl-rscode = ist_scrdtl-rscode .
  ist_nemddtl-amount = ist_scrdtl-amount .
  ist_nemddtl-currency = ist_scrdtl-currency .

  ist_oemddtl-docno = ist_scrdtl-docno .
  ist_oemddtl-trans = ist_scrdtl-trans .
  ist_oemddtl-item_no = ist_scrdtl-item_no .
  ist_oemddtl-ebeln = ist_scrdtl-ebeln .
  ist_oemddtl-status = ist_scrdtl-status .
  ist_oemddtl-rscode = ist_dtl-rscode .
  ist_oemddtl-amount = ist_scrdtl-amount .
  ist_oemddtl-currency = ist_scrdtl-currency .

  CALL FUNCTION 'ZRSCODE_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_emddtl            = ist_nemddtl
      o_zmm_emddtl            = ist_oemddtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zrscode          = ist_chngind.
ENDFORM.                    " chg_docu_rscode
*&---------------------------------------------------------------------*
*&      Form  chg_docu_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chg_docu_amount.
  DATA : l_objid LIKE cdhdr-objectid .
  l_objid = wa_emddtl-docno .

  ist_nemddtl-docno = ist_scrdtl-docno .
  ist_nemddtl-trans = ist_scrdtl-trans .
  ist_nemddtl-item_no = ist_scrdtl-item_no .
  ist_nemddtl-ebeln = ist_scrdtl-ebeln .
  ist_nemddtl-status = ist_scrdtl-status .
  ist_nemddtl-rscode = ist_scrdtl-rscode .
  ist_nemddtl-amount = ist_scrdtl-amount .
  ist_nemddtl-currency = ist_scrdtl-currency .

  ist_oemddtl-docno = ist_scrdtl-docno .
  ist_oemddtl-trans = ist_scrdtl-trans .
  ist_oemddtl-item_no = ist_scrdtl-item_no .
  ist_oemddtl-ebeln = ist_scrdtl-ebeln .
  ist_oemddtl-status = ist_scrdtl-status .
  ist_oemddtl-rscode = ist_scrdtl-rscode .
  ist_oemddtl-amount = ist_dtl-amount .
  ist_oemddtl-currency = ist_scrdtl-currency .

  CALL FUNCTION 'ZAMOUNT_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_emddtl            = ist_nemddtl
      o_zmm_emddtl            = ist_oemddtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zamount          = ist_chngind.

ENDFORM.                    " chg_docu_amount
*&---------------------------------------------------------------------*
*&      Form  chg_docu_validity
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chg_docu_validity.
  DATA : l_objid LIKE cdhdr-objectid .
  l_objid = wa_emddtl-docno .

  ist_nemddtl-docno = ist_scrdtl-docno .
  ist_nemddtl-trans = ist_scrdtl-trans .
  ist_nemddtl-item_no = ist_scrdtl-item_no .
  ist_nemddtl-ebeln = ist_scrdtl-ebeln .
  ist_nemddtl-status = ist_scrdtl-status .
  ist_nemddtl-rscode = ist_scrdtl-rscode .
  ist_nemddtl-amount = ist_scrdtl-amount .
  ist_nemddtl-inst_vdt = ist_scrdtl-inst_vdt .
  ist_nemddtl-currency = ist_scrdtl-currency .

  ist_oemddtl-docno = ist_scrdtl-docno .
  ist_oemddtl-trans = ist_scrdtl-trans .
  ist_oemddtl-item_no = ist_scrdtl-item_no .
  ist_oemddtl-ebeln = ist_scrdtl-ebeln .
  ist_oemddtl-status = ist_scrdtl-status .
  ist_oemddtl-rscode = ist_scrdtl-rscode .
  ist_oemddtl-amount = ist_scrdtl-amount .
  ist_oemddtl-inst_vdt = ist_dtl-inst_vdt .
  ist_oemddtl-currency = ist_scrdtl-currency .

  CALL FUNCTION 'ZVALIDITY_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_emddtl            = ist_nemddtl
      o_zmm_emddtl            = ist_oemddtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zvalidity        = ist_chngind.

ENDFORM.                    " chg_docu_validity
*&---------------------------------------------------------------------*
*&      Form  update_header_status_bglc
*&---------------------------------------------------------------------*
*     This subroutine is to Update Header level status for BG/LC
*     Line Items.
*----------------------------------------------------------------------*
*      -->P_G_IDOCNO  text
*      -->P_2616   text
*----------------------------------------------------------------------*
FORM update_header_status_bglc USING    p_docno
                                        p_stat .

  UPDATE zmm_emdhdr
        SET status = p_stat
    WHERE docno    = p_docno.
ENDFORM.                    " update_header_status_bglc
*&---------------------------------------------------------------------*
*&      Form  update_header_status_bglc_main
*&---------------------------------------------------------------------*
*       Update header status.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_header_status_bglc_main.

  PERFORM get_bglc_data.

  DATA: wa_dtl_t001 TYPE zmm_emd_status.
  DATA: l_stat,
        l_found.
*---------------------------------------------------------------------------*
* Start of modification by SAB_SARVANAN on 12/06/2009 - RD1K964254
*BREAK-POINT.
*if prev_okcode = 'RESET'.
*  loop at ist_emddtl into wa_dtl_t001.
*    if sy-tabix = 1.
*      l_stat    =  wa_dtl_t001-status.
*    endif.
*
*    if l_stat   ne  wa_dtl_t001-status.
*      l_found   =  'X'.
*      exit.
*    else.
*      l_found   =  '0'.
*    endif.
*  endloop.

*  if l_found = '0' and not l_stat is initial.
*    if l_stat ='N'.
*      perform update_header_status_bglc using g_idocno 'N'.
*    elseif l_stat = 'P'.
*      perform update_header_status_bglc using g_idocno 'J'.
*    endif.
*
*  elseif l_found = 'X'.
*    perform update_header_status_bglc using g_idocno 'Q'.
*  endif.

*  else.

  CALL FUNCTION 'ZMM_EMD_GET_STATUS_DETAILS'
    EXPORTING
      docno     = g_idocno
    IMPORTING
      output    = l_stat
    TABLES
      input_tab = ist_emddtl.

  PERFORM update_header_status_bglc USING g_idocno l_stat.

*    endif.
* End of modification by SAB_SARVANAN on 12/06/2009 - RD1K964254
ENDFORM.                    " update_header_status_bglc_main
*&---------------------------------------------------------------------*
*&      Form  check_reason_code_rfc
*&---------------------------------------------------------------------*
*      Check reason code at the time of Refund/forfeit/Convert.
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDREF_RSCODE  text
*----------------------------------------------------------------------*
FORM check_reason_code_rfc USING   p_rscode.
*----------------------------------------------------------------------*
  SELECT SINGLE * FROM zmm_emdrscode
    WHERE rscode =  p_rscode.
  IF sy-subrc NE 0.
    MESSAGE e467(zmm).
  ENDIF.
*----------------------------------------------------------------------*
  IF zmm_emdhdr-trans = 'TFS'.
    IF p_rscode < 100 OR p_rscode > 199  .
      MESSAGE e464(zmm).
    ENDIF.
  ELSEIF  zmm_emdhdr-trans = 'EMD' .
    IF p_rscode < 200 OR p_rscode > 299  .
      MESSAGE e465(zmm).
    ENDIF.
  ELSEIF zmm_emdhdr-trans = 'SDT'.
    IF p_rscode < 300 OR p_rscode > 399  .
      MESSAGE e466(zmm).
    ENDIF.
*-------  < Check Reason code > ---------------------------------------*
  ENDIF.
ENDFORM.                    " check_reason_code_rfc
*&---------------------------------------------------------------------*
*&      Form  CHECK_BGLC
*&---------------------------------------------------------------------*
*       Check BG/LC Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bglc.
  IF prev_okcode = 'BGLC' OR prev_okcode = 'AMEND' .

    IF NOT zmm_emdhdr-docno  IS INITIAL.

      SELECT SINGLE * FROM zmm_emdhdr INTO wa_emdhdr
                 WHERE docno = zmm_emdhdr-docno.
      IF sy-subrc = 0.

        PERFORM check_bglc_doc.
      ELSE.
        MESSAGE e411(zmm).

      ENDIF.
    ENDIF.
  ELSE.
    IF NOT zmm_emdhdr-docno  IS INITIAL.
      SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF  sy-subrc = 0.
        IF prev_okcode = 'AMEND'.
          IF wa_emdhdr-trans = 'TFS'.
            MESSAGE e460(zmm).
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_BGLC
*&---------------------------------------------------------------------*
*&      Form  get_tendno_vendno
*&---------------------------------------------------------------------*
*      Get tenderno and vendor no.
*----------------------------------------------------------------------*
*      -->P_WA_EMDHDR_T02_EBELN  text
*      <--P_L_TENDNO  text
*      <--P_L_VENDNO  text
*      <--P_L_EKGRP  text
*----------------------------------------------------------------------*
FORM get_tendno_vendno USING    p_ebeln
                       CHANGING p_tendno
                                p_vendno
                                p_ekgrp.

  SELECT SINGLE submi lifnr ekgrp FROM ekko INTO (p_tendno,
                            p_vendno,
                            p_ekgrp)
WHERE ebeln = p_ebeln   .
ENDFORM.                    " get_tendno_vendno
*&---------------------------------------------------------------------*
*&      Form  check_reason_code_amend
*&---------------------------------------------------------------------*
*  Check reason code at the time of amendment.
*----------------------------------------------------------------------*
*      -->P_WA_TC145_RSCODE  text
*----------------------------------------------------------------------*
FORM check_reason_code_amend USING   p_rscode .

*----------------------------------------------------------------------*
  SELECT SINGLE * FROM zmm_emdrscode
    WHERE rscode =  p_rscode.
  IF sy-subrc NE 0.
    MESSAGE e467(zmm).
  ENDIF.
*----------------------------------------------------------------------*
  IF zmm_emdhdr-trans = 'TFS'.
    IF  p_rscode < 100 OR  p_rscode > 199  .
      MESSAGE e464(zmm).
    ENDIF.
  ELSEIF  zmm_emdhdr-trans = 'EMD' .
    IF p_rscode < 200 OR   p_rscode > 299  .
      MESSAGE e465(zmm).
    ENDIF.
  ELSEIF zmm_emdhdr-trans = 'SDT'.
    IF   p_rscode < 300 OR   p_rscode > 399  .
      MESSAGE e466(zmm).
    ENDIF.
*-------  < Check Reason code > ---------------------------------------*
  ENDIF.
ENDFORM.                    " check_reason_code_amend
*&---------------------------------------------------------------------*
*&      Form  status_message
*&---------------------------------------------------------------------*
*       Dynamic message after Reset document.
*----------------------------------------------------------------------*
*      -->P_G_RESET_STATUS  text
*----------------------------------------------------------------------*
FORM status_message USING    p_status.
  DATA: l_msg(40).
  IF p_status = 'N'.
    l_msg = text-040.
  ELSEIF p_status = 'B'.
    l_msg  = text-024.
  ELSEIF p_status = 'S'.
    l_msg  = text-048.
  ELSEIF p_status = 'P'.
    l_msg  = text-059.
  ELSEIF p_status = 'A'.
    l_msg  = text-064.
  ENDIF.
  MESSAGE s434(zmm) WITH l_msg.
ENDFORM.                    " status_message
*&---------------------------------------------------------------------*
*&      Form  SET_LOC_RFC
*&---------------------------------------------------------------------*
*   Set lock at the time of Refund/Forfeit/Conv. Change/Display/Delete
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDREF_DOCNO  text
*----------------------------------------------------------------------*
FORM set_loc_rfc USING    p_docno.
  CALL FUNCTION 'ENQUEUE_EZMM_ZMMEMDREF'
    EXPORTING
      mode_zmm_emdref = 'E'
      mandt           = sy-mandt
      docno           = p_docno
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SET_LOC_RFC
*&---------------------------------------------------------------------*
*&      Form  relase_lock_rfc
*&---------------------------------------------------------------------*
*       Release Lock in Refund/Forfiet/Convert
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock_rfc  USING p_docno .

  CALL FUNCTION 'DEQUEUE_EZMM_ZMMEMDREF'
    EXPORTING
      mode_zmm_emdref = 'E'
      mandt           = sy-mandt
      docno           = p_docno.

ENDFORM.                    " relase_lock_rfc
*&---------------------------------------------------------------------*
*&      Form  check_auth
*&---------------------------------------------------------------------*
*  Authority check at the time of Invoke/Return/Accept by FI
*----------------------------------------------------------------------*
*      -->P_1988   text
*----------------------------------------------------------------------*
FORM check_auth .
  DATA: wa_dtl TYPE zmm_emd_status.

  READ TABLE ist_emddtl INTO wa_dtl WITH KEY docno = zmm_emdhdr-docno
                                             sel   = 'X'.

  AUTHORITY-CHECK OBJECT 'ZMMBGLC'
         ID 'ACTVT' FIELD  '16'   .

  IF sy-subrc NE 0 .
*   if wa_dtl-ri_stat ne '3'.
    MESSAGE  e505(zmm).
*    endif.
  ENDIF.
ENDFORM.                    " check_auth
*&---------------------------------------------------------------------*
*&      Form  CHECK_VENDOR
*&---------------------------------------------------------------------*
*       Check Vendor no based on screen i/p. This is only Applicable
*  for SRM Tednders
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_vendor USING p_lifnr.
  DATA l_lifnr LIKE lfb1-lifnr .
  SELECT SINGLE lifnr FROM lfb1 INTO l_lifnr
         WHERE lifnr = p_lifnr .
  IF sy-subrc NE 0.
    MESSAGE e572(zmm).
  ELSE.
** Get Vendor name from table LFA1
    SELECT SINGLE name1 FROM lfa1 INTO g_vname
              WHERE lifnr = p_lifnr.
  ENDIF.
ENDFORM.                    " CHECK_VENDOR
*&---------------------------------------------------------------------*
*&      Form  get_trasn_type
*&---------------------------------------------------------------------*
*     Get Transaction Type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_trasn_type  .

  SELECT TRTYP FROM ZMM_EMDHDR INTO G_TTYPE UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0 AND g_ttype IS INITIAL .
    MOVE 'R3' TO  g_ttype.
  ENDIF.
ENDFORM.                    " get_trasn_type
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBIDNO
*&---------------------------------------------------------------------*
*       Validate Input EBID No using RFC Call to SRM SERVER
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_ebidno.
  DATA: ist_crmd(2000) OCCURS 0.
  DATA: l_logsys(32).
*----------------------------------------------------------------------*
* Get Logical system name from table ZMM_LOGSYS
*----------------------------------------------------------------------*

  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
                WHERE  appl = 'SRM'.

*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Call RFC in SRM server to get Bid Invitation No.
*----------------------------------------------------------------------*
  IF NOT l_logsys IS INITIAL.
    CALL FUNCTION 'Z_GET_CRMD_ORDERADM_H' DESTINATION l_logsys
      EXPORTING
        obj_type = 'BUS2200'
        ebidno   = zmm_emdhdr-ebidno
      TABLES
        ist_crmd = ist_crmd.
    IF  ist_crmd[] IS INITIAL.
      MESSAGE e573(zmm).
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*

ENDFORM.                    " CHECK_EBIDNO
*&---------------------------------------------------------------------*
*&      Form  GET_OPTIONS
*&---------------------------------------------------------------------*
*       Get Option from user input
*  Whether Exempted from Tender Fee or normal Tender Fee
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_options CHANGING p_result.
* Start of addition by Saravanan M on 08/04/2009
  CALL FUNCTION 'K_KKB_POPUP_RADIO3'
    EXPORTING
      i_title   = text-071
      i_text1   = text-069
      i_text2   = text-070
      i_text3   = text-081
      i_default = 1
    IMPORTING
      i_result  = p_result
    EXCEPTIONS
      cancel    = 1
      OTHERS    = 2.
*  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
* End of addition by Saravanan M on 08/04/2009
* Start of comment by Saravanan M on 08/04/2009
*  call function 'K_KKB_POPUP_RADIO2'
*    exporting
*      i_title   = text-071
*      i_text1   = text-069
*      i_text2   = text-070
*      i_default = 1
*    importing
*      i_result  = p_result
*    exceptions
*      cancel    = 1
*      others    = 2.
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
* End of comment by Saravanan M on 08/04/2009
ENDFORM.                    " GET_OPTIONS
*&---------------------------------------------------------------------*
*&      Form  SAVE_SRM_HEADER_DOC
*&---------------------------------------------------------------------*
*   Incase of Tender Fee Exempted Vendors  Save only Header Doc.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_srm_header_doc.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr .
  MOVE g_docno TO wa_emdhdr-docno .
  MOVE 'SRM' TO  wa_emdhdr-trtyp .
  MOVE sy-uname TO wa_emdhdr-crby.
  MOVE sy-datum TO wa_emdhdr-cron .
*  MODIFY zmm_emdhdr FROM wa_emdhdr .
  IF wa_emdhdr-vendorno IS NOT INITIAL AND
     wa_emdhdr-ebidno IS NOT INITIAL.
    PERFORM send_to_srm.
* Update the ECC table for Tender Fee Exemption based on the SRM TFee Update FM return Parameter
    IF lv_srm_update_status EQ abap_true. " LV_SRM_UPDATE_STATUS, Indicates whether it updates the SRM TDPD Table successfully or not.
      MODIFY zmm_emdhdr FROM wa_emdhdr . " Modify ZMM_EMDHDR ECC Table only after SRM TDPD Table Successful Updation.
      MESSAGE s410(zmm) WITH g_docno .
    ENDIF.
    PERFORM clear_screen_160.
    LEAVE TO SCREEN '0100'.
  ELSE.
    MESSAGE e270(zmm).
  ENDIF.

ENDFORM.                    " SAVE_SRM_HEADER_DOC
*&---------------------------------------------------------------------*
*&      Form  get_document_cat
*&---------------------------------------------------------------------*
*      Get Document Category.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_document_cat USING p_docno CHANGING p_srm_tfs.
  DATA: l_docno LIKE zmm_emdhdr-docno .

  SELECT SINGLE *  FROM zmm_emdhdr INTO zmm_emdhdr
    WHERE  docno = p_docno AND
           trtyp = 'SRM'.
  IF sy-subrc = 0.
    SELECT SINGLE  docno INTO l_docno FROM zmm_emddtl
     WHERE docno = p_docno .
    IF sy-subrc NE  0.
      p_srm_tfs = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_document_cat
*&---------------------------------------------------------------------*
*&      Form  clear_screen_160
*&---------------------------------------------------------------------*
*      Clear Screen 160.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_screen_160.
  CLEAR: zmm_emdhdr,
         g_vname   ,
         g_hstatus ,
         g_locname ,
         g_docno   ,
         g_idocno  .
  CLEAR : ok_code, prev_okcode , g_okhdr, g_reset, g_hstatus.

ENDFORM.                    " clear_screen_160
*&---------------------------------------------------------------------*
*&      Form  APPEND_ITAB_S160
*&---------------------------------------------------------------------*
*      Append OKCODE to ist_tab
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab_s160.

  REFRESH ist_tab .
  CLEAR ist_tab   .
  CLEAR wa_tab    .

  IF ( prev_okcode = 'DISP' )  .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'DELE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ELSEIF ( prev_okcode = 'DELE' )  .
    REFRESH ist_tab .
    CLEAR ist_tab   .
    CLEAR wa_tab    .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ELSEIF ( prev_okcode = 'CHAN' OR prev_okcode = 'ECREA' )  .
    REFRESH ist_tab .
    CLEAR ist_tab   .
    CLEAR wa_tab    .
    MOVE 'DELE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ELSEIF ( prev_okcode = 'REST' )  .
    REFRESH ist_tab .
    CLEAR ist_tab   .
    CLEAR wa_tab    .
    MOVE 'DELE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ENDIF.


ENDFORM.                    " APPEND_ITAB_S160
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGES
*&---------------------------------------------------------------------*
*       Save Changes for SRM Screen 160.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_changes.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr .
  MOVE g_idocno TO wa_emdhdr-docno .
  MOVE 'SRM'    TO  wa_emdhdr-trtyp .
  MOVE sy-uname TO wa_emdhdr-chby  .
  MOVE sy-datum TO wa_emdhdr-chon .
  MODIFY zmm_emdhdr FROM wa_emdhdr .
  IF sy-subrc = 0.
    MESSAGE i412(zmm) WITH g_idocno .
    PERFORM release_lock .
    PERFORM clear_screen_160 .
    LEAVE TO SCREEN '0100'.
  ELSE.
    MESSAGE e270(zmm).
  ENDIF.
ENDFORM.                    " SAVE_CHANGES
*&---------------------------------------------------------------------*
*&      Form  MARK_FOR_DELE_EDOC
*&---------------------------------------------------------------------*
*       Make Document Mark for Deletion : Only for SRM Trender Fee
*       exempted vendors
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_for_dele_edoc.
  CLEAR wa_emdhdr.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr.
* Start of Change - By Manikandan
  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
                WHERE  appl = 'SRM'.

  IF l_logsys IS NOT INITIAL AND
     wa_emdhdr-ebidno IS NOT INITIAL AND
     wa_emdhdr-vendorno IS NOT INITIAL.

    CALL FUNCTION 'Z_UPDATE_TDPD_INDI' DESTINATION l_logsys
      EXPORTING
        iv_bid_no            = wa_emdhdr-ebidno               "'char10
        iv_vendor_no         = wa_emdhdr-vendorno             "'char10
      IMPORTING
        ev_success           = lv_srm_update_status
      EXCEPTIONS
        tender_not_published = 1
        tf_deadline_reached  = 2
        OTHERS               = 3.
  ENDIF.

  IF lv_srm_update_status EQ abap_true. " Update in SRM TDPD Table is success, so can update ECC Tables now.
    MOVE 'D'  TO wa_emdhdr-status.
    MODIFY zmm_emdhdr FROM wa_emdhdr .
    IF sy-subrc = 0.
      MESSAGE i415(zmm) WITH g_idocno.
      PERFORM release_lock .
      PERFORM clear_screen_160.
      LEAVE TO SCREEN '0100'.
    ENDIF.
  ELSEIF lv_srm_update_status EQ 'E'. " Response Already Created by the Vendor for the ETender Document
    MESSAGE e009(zmm_emd) WITH g_idocno.
    PERFORM release_lock .
    PERFORM clear_screen_160.
  ELSEIF lv_srm_update_status NE abap_true. "Please Check the Status on both ECC & SRM System
    MESSAGE i010(zmm_emd) WITH g_idocno.
    PERFORM release_lock .
    PERFORM clear_screen_160.
    LEAVE TO SCREEN '0100'.
  ENDIF.
* End of Change   - By Manikandan
ENDFORM.                    " MARK_FOR_DELE_EDOC
*&---------------------------------------------------------------------*
*&      Form  RESET_EDOC
*&---------------------------------------------------------------------*
*      Reset Deleted E-Tender Fee Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_edoc.
  CLEAR wa_emdhdr.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr.
  MOVE 'N'  TO wa_emdhdr-status.
  MODIFY zmm_emdhdr FROM wa_emdhdr .
  IF sy-subrc = 0.
    MESSAGE i424(zmm) .
    PERFORM release_lock .
    PERFORM clear_screen_160.
    LEAVE TO SCREEN '0100'.
  ENDIF.
ENDFORM.                    " RESET_EDOC
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_ITEM_RQRI
*&---------------------------------------------------------------------*
*  Check whether the selected document is send to FI/Accepted by FI
*  If no Raise Error Message
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_rqri.

  DATA l_found .
  DATA : wa_dtl TYPE zmm_emd_status,
       wa_emddtl01  LIKE wa_emddtl..

  l_found = 1.
  g_error = 0.
*&---> Check whether any line Item  selected or Not
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i451(zmm).
  ENDIF.
  CLEAR wa_emddtl.

  IF zmm_emdhdr-trans = 'SDT' OR zmm_emdhdr-trans = 'EMD'.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF NOT ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        MESSAGE i510(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ENDIF.

      IF  wa_emddtl-ri_stat = '1' AND
        ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        g_ans = 1.
        g_error = 1.
        MESSAGE i574(zmm) WITH 'Return'.
      ELSEIF  wa_emddtl-ri_stat = '2' AND
     ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        g_ans = 1.
        g_error = 1.
        MESSAGE i574(zmm) WITH 'Invoke'.
      ENDIF.
    ENDLOOP.
*  ELSEIF zmm_emdhdr-trans = 'EMD'.                          "+003
*    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
*      IF  wa_emddtl-status = 'E'.
*        MESSAGE i452(zmm).
*        g_ans = 1.
*        g_error = 1.
*        EXIT.
*      ELSEIF wa_emddtl-status = 'V' .
*        MESSAGE i443(zmm).
*        g_ans = 1.
*        g_error = 1.
*        EXIT.
*      ELSEIF wa_emddtl-status NE 'P'.
*        MESSAGE i584(zmm).
*        g_ans = 1.
*        g_error = 1.
*        EXIT.
*      ENDIF.
*  ENDLOOP.

  ENDIF.
ENDFORM.                    " CHECK_SEL_ITEM_RQRI
*&---------------------------------------------------------------------*
*&      Form  popup_req_ret_invk
*&---------------------------------------------------------------------*
*       Popup message showing request for Return or Invoke
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_req_ret_invk.
  CLEAR g_ans_ad.

  CALL FUNCTION 'POPUP_TO_DECIDE'
    EXPORTING
      textline1    = text-075
      text_option1 = text-076
      text_option2 = text-077
      titel        = text-075
      start_column = 25
      start_row    = 6
    IMPORTING
      answer       = g_ans_ad.

ENDFORM.                    " popup_req_ret_invk
*&---------------------------------------------------------------------*
*&      Form  update_req_ret_inv
*&---------------------------------------------------------------------*
*     Update Document status for Request for Return/Invoke
*----------------------------------------------------------------------*
*      -->P_G_ANS_AD  text
*----------------------------------------------------------------------*
FORM update_req_ret_inv USING    p_ad  .
  DATA: l_status,
        l_text(15).
  CLEAR: l_text , l_status, g_reqno..
  DATA l_reqno  TYPE zmm_emddtl-ri_reqno.
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
  DATA lv_status.
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
  IF p_ad = 1.
    l_text = 'Return'.
    l_status = '1'.  "Request for Return
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
    lv_status = 'G'.
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
    CONCATENATE g_idocno  wa_emddtl-item_no  'RR' INTO l_reqno .
  ELSEIF p_ad = 2.
    l_text = 'Invoke'.
    l_status = '2'.  "Request for Invoke
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
    lv_status = 'H'.
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
    CONCATENATE g_idocno  wa_emddtl-item_no 'IR' INTO l_reqno .
  ENDIF.
* Begin of <RD1K963111>
  zmm_emddtl-ri_crby = sy-uname.
  zmm_emddtl-ri_cron = sy-datum.
* End of <RD1K963111>
  IF zmm_emdhdr-trans = 'SDT'.
    LOOP AT  ist_emddtl  INTO wa_emddtl  WHERE sel = 'X'.

      UPDATE zmm_emddtl
             SET ri_stat   = l_status
** Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
*                 status    = lv_status
** End of addition by Saravanan M on 10/06/2009 - RD1K964254
                 ri_crby   = sy-uname
                 ri_cron   = sy-datum
                  ri_reqno =  l_reqno
      WHERE docno          = wa_emdhdr-docno   AND
             trans         = wa_emdhdr-trans   AND
             item_no       = wa_emddtl-item_no  .

      IF sy-subrc = 0.
        MESSAGE s582(zmm) WITH l_text.
      ENDIF.
    ENDLOOP.

  ELSEIF zmm_emdhdr-trans = 'EMD' AND p_ad = '1'.
    "+003
*    loop at ist_emddtl into wa_emddtl where sel = 'X'.
*      if  wa_emddtl-status = 'E'.
*        message i452(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
*      elseif wa_emddtl-status = 'V' .
*        message i443(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
*      elseif wa_emddtl-status ne 'P'.
*        message i584(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
*      else.
*        g_ans = 0.
*        g_error = 0.
*      endif.
*    endloop.
*
    IF g_ans = '0' AND g_error = '0'.
      UPDATE zmm_emddtl
           SET ri_stat   = l_status
** Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
*                 status    = lv_status
** End of addition by Saravanan M on 10/06/2009 - RD1K964254
               ri_crby   = sy-uname
               ri_cron   = sy-datum
                ri_reqno =  l_reqno
    WHERE docno          = wa_emdhdr-docno   AND
           trans         = wa_emdhdr-trans   AND
           item_no       = wa_emddtl-item_no  .

      IF sy-subrc = 0.
        MESSAGE s582(zmm) WITH l_text.
      ENDIF.
    ENDIF.

  ELSEIF  zmm_emdhdr-trans = 'EMD' AND p_ad = '2'.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF NOT ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        MESSAGE i510(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
*        message i584(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
      ELSE.
        g_ans = 0.
        g_error = 0.
      ENDIF.
    ENDLOOP.

    IF g_ans = '0' AND g_error = '0'.
      UPDATE zmm_emddtl
           SET ri_stat   = l_status
** Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
*                 status    = lv_status
** End of addition by Saravanan M on 10/06/2009 - RD1K964254
               ri_crby   = sy-uname
               ri_cron   = sy-datum
                ri_reqno =  l_reqno
    WHERE docno          = wa_emdhdr-docno   AND
           trans         = wa_emdhdr-trans   AND
           item_no       = wa_emddtl-item_no  .

      IF sy-subrc = 0.
        MESSAGE s582(zmm) WITH l_text.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " update_req_ret_inv
*&---------------------------------------------------------------------*
*&      Form  MODIFY_TABLE_EMDDTL
*&---------------------------------------------------------------------*
*  Modify Internal table ist_emddtl for updating Requst for return/
*  Invoke field value
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_table_emddtl.


  DATA: ist_dtl TYPE TABLE OF zmm_emd_status WITH HEADER LINE.
  DATA : wa_dtl TYPE zmm_emd_status.
  SELECT * FROM zmm_emddtl INTO CORRESPONDING FIELDS OF TABLE ist_dtl
                   WHERE docno = g_idocno .

  IF sy-subrc  = 0.

    LOOP AT ist_dtl INTO wa_dtl.
      MODIFY ist_emddtl FROM wa_dtl TRANSPORTING
                        ri_stat ri_reqno status
                        WHERE docno = wa_dtl-docno AND
                        item_no = wa_dtl-item_no .
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MODIFY_TABLE_EMDDTL
*&---------------------------------------------------------------------*
*&      Form  check_Req_status
*&---------------------------------------------------------------------*
*       Check request for Return/Invoke exists.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_req_status.
  DATA l_found .
  l_found = 1.
  g_error = 0.

*&---> Check whether any line Item  selected or Not
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i580(zmm).
  ENDIF.

  IF g_ans = 0.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF NOT ( wa_emddtl-ri_stat = '1'
              OR wa_emddtl-ri_stat = '2' ) .
        g_ans = '1' .
        g_error = '1'.
        MESSAGE i581(zmm).
      ENDIF.

*+003
      IF NOT wa_emddtl-ri_reqno IS INITIAL AND
          wa_emddtl-ri_stat NE '3' .
        IF wa_emddtl-status = 'E'.
          g_ans = '1'.
          g_error = '1'.
          MESSAGE i591(zmm) WITH 'Return'.
        ELSEIF wa_emddtl-status = 'V'.
          g_ans = '1'.
          g_error = '1'.
          MESSAGE i592(zmm) WITH 'Invoke'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " check_Req_status
*&---------------------------------------------------------------------*
*&      Form  update_req_status
*&---------------------------------------------------------------------*
*       Update RI_STATUS , RI_REQNO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_req_status.

  LOOP AT  ist_emddtl  INTO wa_emddtl  WHERE sel = 'X'.
    UPDATE zmm_emddtl
           SET ri_stat   = '3'
               ri_reqno  = g_reqno
     WHERE docno          = wa_emdhdr-docno   AND
           trans         = wa_emdhdr-trans    AND
           item_no       = wa_emddtl-item_no  .

    IF sy-subrc = 0.
      MESSAGE s583(zmm) .
    ENDIF.

  ENDLOOP.
  CLEAR g_reqno.
ENDFORM.                    " update_req_status
*&---------------------------------------------------------------------*
*&      Form  change_doc_reqno
*&---------------------------------------------------------------------*
*      Maintain Change document on field ZRI_REQNO .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_doc_reqno.

  DATA: wa_ndtl TYPE zmm_emddtl ,
        wa_odtl TYPE zmm_emddtl ,
        wa_dtl  TYPE zmm_emd_status ,
        wa_tdtl TYPE zmm_emd_status ,
        l_objid TYPE cdhdr-objectid.
  DATA: l_obj(13).
  DATA : ist_cdtxt    TYPE TABLE OF cdtxt WITH HEADER LINE .

  READ TABLE ist_emddtl INTO wa_dtl WITH KEY docno = g_idocno sel = 'X'.

  MOVE-CORRESPONDING wa_dtl TO wa_ndtl.
  wa_ndtl-ri_reqno  = g_reqno.
  IF sy-subrc = 0.
    SELECT * FROM ZMM_EMDDTL INTO CORRESPONDING FIELDS OF WA_ODTL UP TO 1 ROWS
 WHERE DOCNO = WA_NDTL-DOCNO AND ITEM_NO = WA_NDTL-ITEM_NO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  ENDIF.
  l_objid = g_idocno .
  CALL FUNCTION 'ZRI_REQNO_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
*     OBJECT_CHANGE_INDICATOR = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZRI_REQNO    = ' '
      n_zmm_emddtl            = wa_ndtl
      o_zmm_emddtl            = wa_odtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zri_reqno        = ist_cdtxt.


ENDFORM.                    " change_doc_reqno
*&---------------------------------------------------------------------*
*&      Form  display_chng_ri_history
*&---------------------------------------------------------------------*
*      Change History display for Return/Invoke Document.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_chng_ri_history.

  DATA :   i_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE   ,
           i_editpos TYPE TABLE OF cdshw WITH HEADER LINE ,
           ist_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE ,
           l_objid LIKE cdhdr-objectid ,
           l_obj(13).

  DATA : wa_header LIKE cdhdr ,
         wa_dtl TYPE zmm_emd_status.
  DATA : BEGIN  OF ist_editpos OCCURS 0 .
          INCLUDE STRUCTURE cdshw .
  DATA :  user LIKE sy-uname ,
          date LIKE sy-datum ,
          time LIKE sy-uzeit ,
  END OF ist_editpos .

  l_objid =  g_idocno.

  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZRI_REQNO'
      objectid                   = l_objid
      username                   = space
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.

    CLEAR : i_cdhdr .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      REFRESH i_editpos .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.

      IF sy-subrc = 0.
        LOOP AT i_editpos WHERE fname = 'RI_REQNO' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          ist_editpos-time = wa_header-utime .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

  WRITE : /5 'Document No. ' , 20 'Item no' ,
          25 'Request Number' , 45 'changed by' , 60 ' Date' ,
          75 ' Time'.

  WRITE : /5 sy-uline(95).
  LOOP AT ist_editpos .

    WRITE :/5 wa_emddtl-docno(10),
            20 ist_editpos-f_new+10(3) ,
            25 ist_editpos-f_new(16) ,
            45 ist_editpos-user(12)  ,
            60 ist_editpos-date(8)   ,
            75 ist_editpos-time(6).

  ENDLOOP.
ENDFORM.                    " display_chng_ri_history
*&---------------------------------------------------------------------*
*&      Form  check_inst_group_etend
*&---------------------------------------------------------------------*
*      Check Instrument Group Incase of e-Tenders
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_inst_group_etend.
*+004

  DATA: ist_emddtl_temp LIKE TABLE OF wa_emddtl.
*&--> Check Whether Instrument Type entered is from same Group or not
*&--> G1- DD,BC,CC G2-LC , G3-BG , G4-IP G5-IV G6-OP

**** check for Instrument type. This logic is laid for the reason
***** that no
***** (1) If Instrument type is DD then only BC and CC is permitted
***** (2) If Instrument is BG then only BG is permitted.
****  (3) IF Instrument is IV then only IV is permitted.

  DATA: ist_instgrp TYPE TABLE OF zmm_emddtl-inst_type.
  DATA:  wa_instgrp TYPE zmm_emddtl-inst_type.
  DATA: l_inst(20).
  DATA: l_fd  .
  REFRESH ist_instgrp.
  LOOP AT ist_emddtl INTO wa_emddtl.
    wa_instgrp  = wa_emddtl-inst_type.
    APPEND wa_instgrp  TO ist_instgrp.
  ENDLOOP.
  SORT ist_instgrp .
  DELETE ADJACENT DUPLICATES FROM ist_instgrp .
  LOOP AT ist_instgrp INTO wa_instgrp .
    CONCATENATE  l_inst
   wa_instgrp  INTO l_inst .
  ENDLOOP.

  IF NOT l_inst IS INITIAL.

    IF l_inst  = 'BCCCDD'  OR
       l_inst  = 'BCCC'    OR
       l_inst  = 'CCDD'    OR
       l_inst  = 'CCBC'    OR
       l_inst  = 'BCDD'    OR
       l_inst  = 'DD'      OR
       l_inst  = 'CC'      OR
       l_inst  = 'BC'      OR
       l_inst  = 'BG'      OR
       l_inst  = 'IP'      OR
       l_inst  = 'IV'      OR
       l_inst  = 'LC'     OR
       l_inst  = 'OP'.
      l_fd = 'X'.
      g_error = 1 .
    ELSE.
      g_error = 0.
      MESSAGE i426(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_inst_group_etend
*&---------------------------------------------------------------------*
*&      Form  get_reqno
*&---------------------------------------------------------------------*
*       Get Request no.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_reqno.

  DATA: wa_dtl TYPE zmm_emddtl.
  CLEAR: wa_dtl,g_reqno.
* Start of change by SAB_SARVANAN 0n 12/06/2009
  SELECT * FROM ZMM_EMDDTL INTO WA_DTL UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO AND RI_REQNO NE ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT.
* End of change by SAB_SARVANAN 0n 12/06/2009
  IF sy-subrc = 0.
    IF NOT wa_dtl-ri_reqno IS INITIAL.
      IF  wa_dtl-ri_reqno+13(1) = 'R'.
        CONCATENATE g_idocno  wa_emddtl-item_no  'RC' INTO g_reqno .
      ELSEIF  wa_dtl-ri_reqno+13(1) = 'I'.
        CONCATENATE g_idocno  wa_emddtl-item_no  'IC' INTO g_reqno .
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_reqno
*&---------------------------------------------------------------------*
*&      Form  get_reqno_save
*&---------------------------------------------------------------------*
*       Get Request no at the time of creating request .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_reqno_save USING p_ad.
  DATA: l_status,
        l_text(15).
  CLEAR: l_text , l_status, g_reqno..
  DATA l_reqno  TYPE zmm_emddtl-ri_reqno.
  IF p_ad = 1.
    l_text = 'Return'.
    l_status = '1'.  "Request for Return
    CONCATENATE g_idocno  wa_emddtl-item_no  'RR' INTO g_reqno .
  ELSEIF p_ad = 2.
    l_text = 'Invoke'.
    l_status = '2'.  "Request for Invoke
    CONCATENATE g_idocno  wa_emddtl-item_no 'IR' INTO g_reqno .
  ENDIF.
ENDFORM.                    " get_reqno_save
*&---------------------------------------------------------------------*
*&      Form  get_bstyp
*&---------------------------------------------------------------------*
*       Get Document type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bstyp.
  IF NOT  zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE  bstyp FROM ekko INTO g_bstyp
              WHERE  ebeln = zmm_emdhdr-ebeln .
  ENDIF.
ENDFORM.                    " get_bstyp
*&---------------------------------------------------------------------*
*&      Form  check_auth_RETURN
*&---------------------------------------------------------------------*
*       Authority Check at the time of EMD/SD BG Return
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDHDR_TRANS  text
*----------------------------------------------------------------------*
FORM check_auth_return USING    p_trans   .
  CLEAR : g_firet,g_mmret .
  DATA: wa_dtl TYPE zmm_emd_status.
  DATA: l_msg(30).

  READ TABLE ist_emddtl INTO wa_dtl WITH KEY docno = zmm_emdhdr-docno
                                         sel = 'X'.
* IF status = 'Accepted by Bank or Denied by Bank , then allow Retur
* of BG of EMD Document. This Authorisation is with 'MM' under having
*Activity '02'.
  IF ( wa_dtl-status = 'A'  OR wa_dtl-status = 'Y' ) AND
       wa_dtl-trans = 'EMD' .
    AUTHORITY-CHECK OBJECT 'ZMMBGLC'
           ID 'ACTVT' FIELD  '02'   .
    IF sy-subrc = 0 .
      g_mmret = 'X'.
    ENDIF.

*  ELSEIF wa_dtl-ri_stat = space OR wa_dtl-ri_stat = '3'  .
*    MESSAGE i588(zmm).
*    g_mmret = space .
*    MESSAGE e505(zmm).

  ELSEIF wa_dtl-status  = 'E'.
    g_ans = 1.
    g_error = 1.
    MESSAGE e452(zmm).
  ELSEIF wa_dtl-status = 'V' .
    MESSAGE e443(zmm).
    g_ans = 1.
    g_error = 1.
  ELSEIF wa_dtl-status = 'N'.
    g_ans = 1.
    g_error = 1.
    MESSAGE e497(zmm).
  ELSEIF wa_dtl-status = 'B'.
    g_ans = 1.
    g_error = 1.
    MESSAGE e447(zmm).
  ELSEIF wa_dtl-status = 'S' OR wa_dtl-status = 'P' OR
      wa_dtl-ri_stat = '1'.
    IF wa_dtl-status = 'S'.
      l_msg = 'Submitetd to FI'.
    ELSEIF  wa_dtl-status = 'P'.
      l_msg = 'Accepted by FI'.
    ELSEIF  wa_dtl-ri_stat = '1'.
      l_msg = 'Request for Return'.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'ZMMBGLC'
    ID 'ACTVT' FIELD  '16'   .
    IF sy-subrc = 0.
      g_firet = 'X'.
    ELSE.
      g_firet = space .
      g_ans = 1.
      g_error = 1.
      MESSAGE i513(zmm) WITH l_msg .
      MESSAGE e514(zmm) WITH l_msg .
    ENDIF.

  ELSEIF wa_dtl-status = 'Y'  AND
         wa_dtl-trans = 'SDT'.
    AUTHORITY-CHECK OBJECT 'ZMMBGLC'
    ID 'ACTVT' FIELD  '02'   .
    IF sy-subrc = 0 .
      g_mmret = 'X'.
    ELSE.
      PERFORM check_fi_athority.
    ENDIF.

  ELSE.
    g_mmret = space .
    MESSAGE e505(zmm).
  ENDIF.


* If Status is "Submitted to FI" or "Accepted by FI"  or ri_status =
*'1' or '2' then allow only FI person to Do Return.
*
* if wa_dtl-status = 'Y'  and
*         wa_dtl-trans = 'SDT'.
*    authority-check object 'ZMMBGLC'
*    id 'ACTVT' field  '02'   .
*    if sy-subrc = 0 .
*      g_mmret = 'X'.
*    else.
*      perform check_fi_athority.
*    endif.
*endif.


  IF wa_dtl-ri_reqno+14(1) = 'R' AND wa_dtl-status = 'P'.
*    authority-check object 'ZMMBGLC'
*            id 'ACTVT' field  '16'   .
    IF sy-subrc NE 0 .
      MESSAGE e512(zmm).
    ELSE.
      g_firet = 'X'.
    ENDIF.
  ENDIF.


*     if p_stat ne 'X'.
*        if wa_emddtl-status = 'S'.
*          g_ans = 1.
*          g_error = 1.
*          message i496(zmm).
*        elseif wa_emddtl-status = 'A'.
*          g_ans = 1.
*          g_error = 1.
*          message i450(zmm).
*        endif.


* if wa_dtl-inst_type = 'BG' and ( p_trans = 'EMD' or p_trans = 'SDT' )
*.
*    authority-check object 'ZMMBGLC'
*           id 'ACTVT' field  '16'   .
**
*    if sy-subrc ne 0 .
*      if wa_dtl-ri_stat ne '3' and wa_dtl-ri_reqno ne space.
*        if not ( wa_dtl-status = 'A' or wa_dtl-status = 'Y' ) .
*          message  e505(zmm).
*          elseif ( wa_dtl-status = 'A' ).
*             l_stat = space .
*           else.
*             l_stat = 'X'.
*        endif.
*      endif.
*    endif.
*  endif.
ENDFORM.                    " check_auth_RETURN
*&---------------------------------------------------------------------*
*&      Form  check_fI_athority
*&---------------------------------------------------------------------*
*       Check FI Authorization
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_fi_athority.
  AUTHORITY-CHECK OBJECT 'ZMMBGLC'
         ID 'ACTVT' FIELD  '16'   .
  IF sy-subrc = 0 .
    g_firet = 'X'.
  ELSE.
    MESSAGE e505(zmm).
  ENDIF.

ENDFORM.                    " check_fI_athority
*&---------------------------------------------------------------------*
*&      Form  CHECK_STATUS_BEFORE_UPDATE
*&---------------------------------------------------------------------*
*       cHECK Document Status before Request status Update
* Applicable for EMD BG/Lc .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_status_before_update USING p_ad .

  IF zmm_emdhdr-trans = 'EMD' AND p_ad = '1'.
    "+003
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status NE 'P'.
        MESSAGE i584(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSE.
        g_ans = 0.
        g_error = 0.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CHECK_STATUS_BEFORE_UPDATE
*&---------------------------------------------------------------------*
*&      Form  SEND_TO_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_to_srm .
  DATA l_logsys(32) TYPE c.
  IF zallow = 'Y'.
    SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
              WHERE  appl = 'SRM'.
    IF NOT l_logsys IS INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zmm_emdhdr-vendorno
        IMPORTING
          output = zmm_emdhdr-vendorno.

      CALL FUNCTION 'Z_UPDATE_TF_ERP' DESTINATION l_logsys
        EXPORTING
          iv_bid_no            = zmm_emdhdr-ebidno               "'char10
          iv_changed_by        = sy-uname
          iv_vendor_no         = zmm_emdhdr-vendorno             "'char10
          iv_amount            = zmm_emdhdr-amount
          iv_currency          = zmm_emdhdr-currency
          iv_payment_date      = sy-datum
          iv_payment_time      = sy-uzeit
        IMPORTING
          ev_success           = lv_srm_update_status
        EXCEPTIONS
          tender_not_published = 1
          tf_deadline_reached  = 2
          OTHERS               = 3.
    ENDIF.
  ENDIF.
ENDFORM.                    " SEND_TO_SRM
*&---------------------------------------------------------------------*
*&      Form  PASS_TO_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pass_to_srm .
  DATA l_logsys(32) TYPE c.
* Checking the valid E-bid & Vendor
  IF zallow = 'Y' AND prev_okcode = 'ECREA' AND zmm_emdhdr-trans = 'TFS'.
* Fetching the Logical system name from the table ZMM_LOGSYS
    SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
              WHERE  appl = 'SRM'.
* Checking value is initial
    IF NOT l_logsys IS INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zmm_emdhdr-vendorno
        IMPORTING
          output = zmm_emdhdr-vendorno.
* Function Module from SRM to pass the value
      CALL FUNCTION 'Z_UPDATE_TF_ERP' DESTINATION l_logsys
        EXPORTING
          iv_bid_no       = zmm_emdhdr-ebidno               "'char10
          iv_changed_by   = sy-uname
          iv_vendor_no    = zmm_emdhdr-vendorno             "'char10
          iv_amount       = zmm_emdhdr-amount
          iv_currency     = zmm_emdhdr-currency
          iv_payment_date = sy-datum
          iv_payment_time = sy-uzeit.
* IMPORTING
*   EV_SUCCESS                 =
* EXCEPTIONS
*   TENDER_NOT_PUBLISHED       = 1
*   TF_DEADLINE_REACHED        = 2
*   OTHERS                     = 3
    ENDIF.
  ENDIF.
ENDFORM.                    " PASS_TO_SRM

*&---------------------------------------------------------------------*
*&      Module  CHECK_APRV_STATUS  INPUT
*&---------------------------------------------------------------------*
* To check SD/PBG approval status
*----------------------------------------------------------------------*
MODULE check_aprv_status INPUT.

  IF zmm_emdhdr-trans = 'SDT'.

*Future date validation : LOA
    IF NOT zmm_emdhdr-loa_dt IS INITIAL.

      IF zmm_emdhdr-loa_dt GT sy-datum.

        SET CURSOR FIELD 'ZMM_EMDHDR-LOA_DT'.
        MESSAGE e981(zmm) WITH text-085.

      ENDIF.

    ENDIF.

* SD / PBG submission date > LOA date
    IF NOT zmm_emdhdr-loa_dt    IS INITIAL AND
       NOT zmm_emdhdr-sd_pbg_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-loa_dt.
        MESSAGE e979(zmm).
      ENDIF.

    ENDIF.

* Actual date of rcpt > LOA date
    IF NOT zmm_emdhdr-loa_dt    IS INITIAL AND
       NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_rcpt_dt LT zmm_emdhdr-loa_dt.
        MESSAGE e980(zmm).
      ENDIF.

    ENDIF.

*Future date validation : Actual date of receipt
    IF NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_rcpt_dt GT sy-datum.

        SET CURSOR FIELD 'ZMM_EMDHDR-SD_PBG_RCPT_DT'.
        MESSAGE e981(zmm) WITH text-086.

      ENDIF.

    ENDIF.

*Future date validation : Date of approval
    IF NOT zmm_emdhdr-apprv_on IS INITIAL.

      IF zmm_emdhdr-apprv_on GT sy-datum.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_ON'.
        MESSAGE e981(zmm) WITH text-087.

      ENDIF.

    ENDIF.

    IF prev_okcode = 'CHAN'.
      MOVE zmm_emdhdr-loa_no         TO wa_emdhdr-loa_no.
      MOVE zmm_emdhdr-loa_dt         TO wa_emdhdr-loa_dt.
      MOVE zmm_emdhdr-sd_pbg_dt      TO wa_emdhdr-sd_pbg_dt.
      MOVE zmm_emdhdr-sd_pbg_rcpt_dt TO wa_emdhdr-sd_pbg_rcpt_dt.
      MOVE zmm_emdhdr-apprv_chk      TO wa_emdhdr-apprv_chk.
      MOVE zmm_emdhdr-apprv_by       TO wa_emdhdr-apprv_by.
      MOVE zmm_emdhdr-apprv_on       TO wa_emdhdr-apprv_on.
      MOVE zmm_emdhdr-remarks        TO wa_emdhdr-remarks.
    ENDIF.

    IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
       NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt.

        PERFORM check_aprv_status USING g_pmc
                                        zmm_emdhdr-sd_pbg_dt
                                        zmm_emdhdr-sd_pbg_rcpt_dt
                                        zmm_emdhdr-apprv_chk
                                        zmm_emdhdr-apprv_by
                                        zmm_emdhdr-apprv_on
                                        zmm_emdhdr-remarks.

      ELSEIF zmm_emdhdr-sd_pbg_dt GE zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'Y'.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_CHK'.
        MESSAGE e011(zmm_emd).

      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CHECK_APRV_STATUS  INPUT

*&---------------------------------------------------------------------*
*&      Form  CHECK_APRV_STATUS
*&---------------------------------------------------------------------*
* To validate SD/PBG approval details
*----------------------------------------------------------------------*
*      -->P_PMC        PMC Flag('X' -Do validation/ ' ' - No Validation)
*      -->P_SD_PBG_DT  SD/PBG Submission deadline
*      -->P_RCPT_DT    Actual date of Receipt of SD/PBG
*      -->P_APPRV_CHK  Approved by competent authority Y / N
*      -->P_APPRV_BY   Approver
*      -->P_APPRV_ON   Approval date
*      -->P_REMARKS    Reason for Delay
*----------------------------------------------------------------------*
FORM check_aprv_status  USING    p_pmc
                                 p_sd_pbg_dt
                                 p_rcpt_dt
                                 p_apprv_chk
                                 p_apprv_by
                                 p_apprv_on
                                 p_remarks.
  DATA : l_days TYPE sy-tabix.

  l_days = p_rcpt_dt - p_sd_pbg_dt.

  IF l_days GT 0.

    IF p_apprv_chk IS INITIAL.

      SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_CHK'.
      MESSAGE e975(zmm).

    ENDIF.

    IF p_apprv_chk = 'Y' AND p_pmc = 'X'.

*Approver
      IF p_apprv_by IS INITIAL.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_BY'.
        MESSAGE e976(zmm).

      ELSE.

        IF l_days LE 28.
          PERFORM chk_authority USING zmm_emdhdr-apprv_by
                                      'L1'.
        ELSE.
          PERFORM chk_authority USING zmm_emdhdr-apprv_by
                                      'DI'.
        ENDIF.

      ENDIF.

*Approval date
      IF p_apprv_on IS INITIAL.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_ON'.
        MESSAGE e977(zmm).

      ENDIF.
*Reason for Delay
      IF p_remarks IS INITIAL.

        SET CURSOR FIELD 'ZMM_EMDHDR-REMARKS'.
        MESSAGE e978(zmm).

      ENDIF.

      zmm_emdhdr-status = 'N'.

    ELSE.

      zmm_emdhdr-status = '0'.

    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_APRV_STATUS

*&---------------------------------------------------------------------*
*&      Form  CHK_AUTHORITY
*&---------------------------------------------------------------------*
* To check User authorization
*----------------------------------------------------------------------*
*      -->P_USER   User ID
*      -->P_AUTH   L1/DI
*----------------------------------------------------------------------*
FORM chk_authority  USING   p_user
                            p_auth.

  AUTHORITY-CHECK OBJECT 'M_BANF_FRG' FOR USER p_user
           ID 'FRGCD' FIELD p_auth.

  IF sy-subrc NE 0.
    SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_BY'.
    MESSAGE e976(zmm) WITH p_auth.
  ENDIF.

ENDFORM.                    " CHK_AUTHORITY

*&---------------------------------------------------------------------*
*&      Form  GET_STATUS
*&---------------------------------------------------------------------*
* Get Status text
*----------------------------------------------------------------------*
*      -->P_STAT    Status value
*      -->P_STATUS  Status text
*----------------------------------------------------------------------*
FORM get_status  USING    p_stat
                          p_status.

  DATA : l_domname  TYPE  dd07v-domname,
         l_domvalue TYPE  dd07v-domvalue_l,
         l_langu    TYPE  sy-langu,
         l_status   TYPE  dd07v-ddtext.

  l_domname  = 'ZCFLAG'.
  l_domvalue = p_stat.
  l_langu    = 'EN'.

  CALL FUNCTION 'GET_TEXT_DOMVALUE'
    EXPORTING
      domname         = l_domname
      domvalue        = l_domvalue
      langu           = l_langu
   IMPORTING
     txt             = l_status
* EXCEPTIONS
*   NOT_FOUND       = 1
*   OTHERS          = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  MOVE l_status TO p_status.

ENDFORM.                    " GET_STATUS

*&---------------------------------------------------------------------*
*&      Form  GET_LOV_APPROVE_BY
*&---------------------------------------------------------------------*
* Serach help on Approved by Competent Authority
*----------------------------------------------------------------------*
FORM get_lov_approve_by .

  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
                                         WITH  HEADER LINE.

  DATA : ist_field_tab LIKE STANDARD TABLE OF dfies
                                           WITH  HEADER LINE.
  DATA : BEGIN OF wa_object,
             apprv_by  TYPE agr_users-uname,
             ename     TYPE pa0001-ename,
           END OF wa_object.

  DATA : ist_object_f4 LIKE STANDARD TABLE OF wa_object
                            INITIAL SIZE 100.
  DATA : BEGIN OF wa_users,
               uname  TYPE pa0001-uname,
             END OF wa_users.

  DATA : ist_users LIKE TABLE OF wa_users.

  DATA : l_agr_name_1 TYPE agr_users-agr_name VALUE '%SRV%IND%1%',
         l_agr_name_2 TYPE agr_users-agr_name VALUE '%SRV%IND%DI'.

  DATA : l_pernr  TYPE pa0001-pernr.

  REFRESH : ist_object_f4,
            ist_return_tab,
            ist_users.

  SELECT uname FROM agr_users INTO TABLE ist_users
          WHERE agr_name LIKE l_agr_name_1 OR
                agr_name LIKE l_agr_name_2.

  SORT ist_users BY uname.

  DELETE ADJACENT DUPLICATES FROM ist_users COMPARING uname.

  LOOP AT ist_users INTO wa_users.

    CLEAR wa_object.

    MOVE wa_users-uname TO wa_object-apprv_by.
    MOVE wa_users-uname TO l_pernr.

    SELECT ENAME FROM PA0001 INTO WA_OBJECT-ENAME UP TO 1 ROWS
 WHERE PERNR = L_PERNR AND ENDDA GE SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc EQ 0.
      APPEND wa_object TO ist_object_f4.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'APPRV_BY'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_EMDHDR-APPRV_BY'
      value_org       = 'S'
*     callback_form   = 'F4CALLBACK'
    TABLES
      value_tab       = ist_object_f4
      field_tab       = ist_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  zmm_emdhdr-apprv_by =  ist_return_tab-fieldval.

ENDFORM.                    " GET_LOV_APPROVE_BY
*&---------------------------------------------------------------------*
*&      Form  MM_EKKO_ARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mm_ekko_arch .

  RANGES  : r_ebeln FOR ekko-ebeln.
  REFRESH :g_t_frange ,g_t_all_fields ,g_t_aind_str1_ais,l_t_as_key, it_ekko_arch.
  CLEAR :g_s_aind_str1_ais,g_s_all_fields,g_s_frange,g_s_as_key, it_ekko_arch.

  SELECT aind_str1~archindex aind_str1~itype aind_str1~skey
    INTO TABLE g_t_aind_str1_ais
    FROM aind_str1 JOIN aind_str2 ON aind_str1~archindex = aind_str2~archindex
    WHERE itype  = 'I'
      AND object = 'MM_EKKO'
      AND active = 'X'.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*  READ TABLE g_t_aind_str1_ais INTO g_s_aind_str1_ais  INDEX 2.
      READ TABLE g_t_aind_str1_ais INTO g_s_aind_str1_ais  INDEX 2.   "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
  IF sy-subrc NE 0.
    MESSAGE 'No Active Info Structure Found !' TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'AS_API_INFOSTRUC_FIND'
    EXPORTING
      i_fieldcat         = g_s_aind_str1_ais-skey
    IMPORTING
      e_all_fields       = g_t_all_fields
    EXCEPTIONS
      no_infostruc_found = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. MESSAGE 'No Info Structure Found !'           TYPE 'E'.
      WHEN 2. MESSAGE 'Info Structure Find - Error Other !' TYPE 'E'.
    ENDCASE.
  ENDIF.
  SORT g_t_all_fields.

  " Purchasing Document  zmm_emdhdr-ebeln
  IF zmm_emdhdr-ebeln IS NOT INITIAL.
    READ TABLE g_t_all_fields INTO g_s_all_fields WITH KEY fieldname = 'EBELN' BINARY SEARCH.
    IF sy-subrc EQ 0.
      REFRESH  g_s_frange-selopt_t.
      MOVE 'EBELN' TO g_s_frange-fieldname.
      r_ebeln-sign = 'I'.
      r_ebeln-option = 'EQ'.
      r_ebeln-high = zmm_emdhdr-ebeln.
      r_ebeln-low = zmm_emdhdr-ebeln.
      MOVE-CORRESPONDING r_ebeln TO g_s_selopt.
      APPEND  g_s_selopt  TO  g_s_frange-selopt_t.
      APPEND  g_s_frange   TO  g_t_frange.
      CLEAR g_s_frange.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'AS_API_READ'
    EXPORTING
      i_fieldcat                = g_s_aind_str1_ais-skey
      i_selections              = g_t_frange
    IMPORTING
      e_result                  = l_t_as_key[]
    EXCEPTIONS
      parameters_invalid        = 1
      no_infostruc_found        = 2
      field_missing_in_fieldcat = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. MESSAGE 'Paramaters Invalid !'             TYPE 'E'.
      WHEN 2. MESSAGE 'No Info Structure Found !'        TYPE 'E'.
      WHEN 3. MESSAGE 'Field Missing in Field Catelog !' TYPE 'E'.
      WHEN 4. MESSAGE 'Archive Read Error'               TYPE 'E'.
    ENDCASE.
  ENDIF.

  SORT l_t_as_key BY archivekey archiveofs .
  DELETE ADJACENT DUPLICATES FROM l_t_as_key COMPARING ALL FIELDS.

  LOOP AT l_t_as_key INTO g_s_as_key.
* read information from archive
    CALL FUNCTION 'ARCHIVE_READ_OBJECT'
      EXPORTING
        object         = 'MM_EKKO'
        archivkey      = g_s_as_key-archivekey
        offset         = g_s_as_key-archiveofs
      IMPORTING
        archive_handle = l_handle
      EXCEPTIONS
        OTHERS         = 1.

    IF sy-subrc <> 0.
      MESSAGE 'No Suitable Data Found in Archive !' TYPE 'E'.
    ELSE.
      CALL FUNCTION 'ARCHIVE_GET_TABLE'                     "#EC *
        EXPORTING
          archive_handle          = l_handle
          record_structure        = 'EKKO'
          all_records_of_object   = 'X'
          automatic_conversion    = 'X'
        TABLES
          table                   = ct_ekko
        EXCEPTIONS
          end_of_object           = 1
          internal_error          = 2
          wrong_access_to_archive = 3
          OTHERS                  = 4.

      APPEND LINES OF ct_ekko TO it_ekko_arch.

      REFRESH:  ct_ekko .
      CLEAR  :  ct_ekko .
    ENDIF.
  ENDLOOP.
  " MM_EKKO_RET

ENDFORM.                    " MM_EKKO_ARCH

*--- INCLUDE: MZMMEMD_ARCHI01_ARCH ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMEMDI01                                                 *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*               Modification Log
*----------------------------------------------------------------------*
*  Date          Transport Request     User ID              Description
* 08/04/2009       RD1K963111          SAB_SARVANAN
* Description : Added EMD Radio Button in the pop-up and written the logic
*               for the same
* 28.01.2014  Sudhir Sharma   CR 30010442
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*      User command of Screen - 100
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
*  data: l_result .
  DATA: l_srm_tfs    .
  g_error = 1.
  g_okhdr = 'X'.
  CLEAR l_result.
  ok_code = sy-ucomm .
  PERFORM clear_table.
  CLEAR g_hstatus .
  CASE ok_code.
    WHEN 'CREA'.
      prev_okcode = ok_code      .
      CLEAR ok_code .
      g_action     = 'Create'     .
      PERFORM fill_ist_emddtl     .
      CALL SCREEN '0105'.
    WHEN 'ECREA'.
      prev_okcode = ok_code      .
      CLEAR ok_code .
      g_action     = 'Create'     .
      PERFORM fill_ist_emddtl     .
*&-- SRM Changes 1.11.04
      PERFORM get_options CHANGING l_result.
      IF l_result = '1'.
        CALL SCREEN '0155'.
      ELSEIF l_result = 2.
        CALL SCREEN '0160'.
      ELSEIF l_result = 3.
* Start of Comment by Saravanan M on 08/04/2009
*        leave to screen '0100'.
* End of Comment by Saravanan M on 08/04/2009
        CALL SCREEN '0155'.
      ELSE.
        LEAVE TO SCREEN '0100'.
      ENDIF.
*&-- End OF Change --------
    WHEN  'CHAN'                  .
      CLEAR zmm_emdhdr-docno .                              "15.03.04
      g_action     = 'Change'     .
      prev_okcode  = ok_code      .

    WHEN   'DISP'       .
      CLEAR zmm_emdhdr-docno .                              "15.03.04
      g_action = 'Display'        .
      prev_okcode = ok_code       .
    WHEN  'DELE'.
      CLEAR zmm_emdhdr-docno .                              "15.03.04
      g_action     = 'Delete'.
      prev_okcode  =  ok_code .
    WHEN 'REST'.
      g_action     = 'Reset'.
      prev_okcode  =  ok_code .
      CLEAR zmm_emdhdr-docno.
    WHEN 'BGLC'.
      set_okcode = 'BGLC'.
      prev_okcode  = ok_code.
      IF zmm_emdhdr-docno IS INITIAL.
        LEAVE TO SCREEN '0100'.
      ENDIF.
      CLEAR zmm_emdhdr-docno.
    WHEN 'REF'.
      g_ref =  1.
      PERFORM clear_global_100.
      CALL SCREEN '0110'.
    WHEN 'AMEND'.
      prev_okcode = ok_code .
*&------> Park Document ----------------------------------------*
    WHEN 'RELS'.
      CALL TRANSACTION 'ZMMFIPARKDOC'.
*&------<-------------------------------------------------------*
    WHEN 'BGCNF'.
      CALL TRANSACTION 'ZMMBGCNF' .
    WHEN 'BGAMD'.
      CALL TRANSACTION 'ZMMBGAMD' .
    WHEN 'RFCR'.
      CALL TRANSACTION 'ZMMRFC' .
    WHEN 'HDRR'.
      CALL TRANSACTION 'ZMMHDRRFC'.
    WHEN 'DTLR'.
      CALL TRANSACTION 'ZMMDTLRFC'.
    WHEN 'DELP'.
      CALL TRANSACTION 'ZMMDELDOC'.
    WHEN 'INVK'.
      CALL TRANSACTION 'ZMMBGIV'.
    WHEN 'RCPT'.
      CALL TRANSACTION 'ZMMRCPT'.
    WHEN  'BGRET'.
      CALL TRANSACTION 'ZMMBGRET'.
    WHEN 'CRF'.
      CALL TRANSACTION 'ZMMCRF'.
    WHEN 'BGREQ'.
      CALL TRANSACTION 'ZMMBGREQ'.
  ENDCASE.
  IF prev_okcode = 'DISP' OR
     prev_okcode = 'CHAN' OR
     prev_okcode = 'DELE' OR
     prev_okcode = 'REST' OR
     prev_okcode = 'BGLC' OR
     prev_okcode = 'AMEND'.
    IF NOT zmm_emdhdr-docno IS INITIAL.
      g_idocno = zmm_emdhdr-docno .
*---------------------------------------------------------------*
*SRM Changes 1.11.04.
* Check Document Before any Actions; If document doesn't contain
* any line item. then call screen 160 .
      CLEAR l_srm_tfs .
      PERFORM get_document_cat USING zmm_emdhdr-docno CHANGING l_srm_tfs.
      IF  l_srm_tfs = 'X'.
        IF   prev_okcode = 'CHAN' OR
             prev_okcode = 'DELE' OR
             prev_okcode = 'REST'.
          PERFORM set_lock        .
        ENDIF.
        CALL SCREEN '0160'.
      ENDIF.
*-----End of Changes -------------------------------------------*

* Get Header/Item Data
      IF prev_okcode NE 'BGLC'.
        IF   l_srm_tfs NE 'X'.
          PERFORM get_data.
        ENDIF.
      ENDIF.
*---------------------------------------------------------------*
      CLEAR g_okhdr .
**&--> Refresh Table Control Data
      IF prev_okcode = 'AMEND'.
        REFRESH CONTROL 'TC_145' FROM SCREEN '0145'.
      ELSEIF prev_okcode NE 'BGLC'.
        REFRESH CONTROL 'TC_105' FROM SCREEN '0105'.
      ELSEIF prev_okcode = 'BGLC' AND zmm_emdhdr-docno IS INITIAL.
        REFRESH CONTROL 'TC_135' FROM SCREEN '0135'.
      ENDIF.
**&--<
      IF prev_okcode = 'BGLC'.
        IF NOT zmm_emdhdr-docno IS INITIAL.
          PERFORM set_lock    .
        ENDIF.
        PERFORM get_bglc_data.
        REFRESH CONTROL 'TC_135' FROM SCREEN '0135'.
        CALL SCREEN '0135'.
      ELSEIF prev_okcode NE 'AMEND'.
*&-----> SET    Lock  -------------------------------------------*
        IF prev_okcode = 'CHAN' OR
           prev_okcode = 'DELE' OR
           prev_okcode = 'REST'.
          PERFORM set_lock        .
        ENDIF.
*&----------------------------------------------------------------*
* SRM Changes.
* Check whether i/p doc is SRM or R3. If R3 then call screen 0105.
* Otherwise call screen 155.
        CLEAR g_ttype .
        PERFORM get_trasn_type .
        IF g_ttype = 'R3'  .
          CALL SCREEN '0105'.
        ELSEIF g_ttype = 'SRM'.
          CALL SCREEN '0155'.
        ENDIF.
*&----------------------------------------------------------------*
      ENDIF.
      IF prev_okcode = 'AMEND'.
        PERFORM set_lock    .
        PERFORM get_data.
        PERFORM get_vendorno_tenderno.
        CALL SCREEN '0145'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0105  INPUT
*&---------------------------------------------------------------------*
*       Exit command BACK,EXIT,CANCEL for screen 105
*----------------------------------------------------------------------*
MODULE   exit_command_0105 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code  .
    WHEN  'BACK' OR 'EXIT' OR 'CANCEL'.
*&--> If no Value Entered at Header Level Then Leave Screen to 100
      IF g_okhdr = 'X'.
        PERFORM clear_screen_0105.
        LEAVE TO SCREEN '0100'.
      ENDIF.
*&--<
      IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN' OR
         prev_okcode = 'ECREA'.                             "+002
        PERFORM popup_confirm USING text-005 text-004 .
        IF g_ans = 'J'.
          PERFORM release_lock.
          PERFORM clear_screen_0105.
          LEAVE TO SCREEN '0100'.
        ENDIF.
      ENDIF.
      IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'
           OR prev_okcode = 'REST'.
        PERFORM release_lock.
        PERFORM clear_screen_0105.
        LEAVE TO SCREEN '0100'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       User Commands for the screen 105
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  IF zmm_emdhdr-trans = 'SDT'.
    g_rfqpo      = 'PO No.'.
  ELSE.
    g_rfqpo      = 'RFQ No'.
  ENDIF.
  ok_code = sy-ucomm .
  CASE ok_code .
    WHEN 'SAVE'.
      IF g_error = 1.
*&----> Check Instrument no Before SAVE.
        PERFORM check_instno .
*&----<
        IF prev_okcode = 'CREA'.                            "+002
          PERFORM check_key.
        ENDIF.
*&--> Get Document no .
        IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.
          PERFORM get_docno   .
        ENDIF.
*&--<
*&--> Popup message when Save Changes "Change Mode"
        IF prev_okcode = 'CHAN' AND g_error = 0 .
          PERFORM save_change_popup USING text-006.
        ENDIF.
*&--<
*&--> Popup message when Save Changes "Change Mode"
        IF ( prev_okcode = 'CREA' OR prev_okcode = 'ECREA' )
             AND g_error = 0 .
          PERFORM save_change_popup USING text-050.
        ENDIF.
*&-----<
        IF g_sc_ans = '1' AND
          ( prev_okcode = 'CREA' OR
            prev_okcode = 'ECREA' OR
            prev_okcode = 'CHAN' ).
          IF g_error = 0.
            PERFORM insert_itemdtl               .
            IF prev_okcode = 'CHAN' AND NOT  ist_del_emddtl IS INITIAL.
              PERFORM del_line_item ON COMMIT.
              IF sy-subrc = 0.
                COMMIT WORK.
              ENDIF.
            ENDIF.
            PERFORM save_data ON COMMIT .
**** start of change on 30/1/2004 for saving change documents
**** CDPOS & CDHDR.
            IF zmm_emdhdr-place <> wa_emdhdr-place .
              PERFORM save_chg_docu ON COMMIT .
            ENDIF .
**** end of change on 30/1/2004
            IF g_save_h = 0 AND g_save_i = 0.
              COMMIT WORK.
              IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'. "+002
                PERFORM clear_screen_0105 .
                CLEAR g_ans .
                MESSAGE s410(zmm) WITH g_docno .
                CLEAR g_docno .                             "+004
*---- set parameter for TFS/EMD/SD Document   ----------------------*
*                set parameter id 'ZMMTESDOC' field g_docno.
*-------------------------------------------------------------------*
              ELSEIF prev_okcode = 'CHAN'    .
                PERFORM clear_screen_0105 .
                MESSAGE i412(zmm).
                CLEAR g_sc_ans .
              ENDIF.
              PERFORM clear_screen_0105 .
              LEAVE TO SCREEN '0100'.
            ELSE.
              PERFORM clear_screen_0105 .
              ROLLBACK WORK.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'COPY'.
      PERFORM copy_line    .
    WHEN 'PASTE'.
      PERFORM paste_line   .
    WHEN 'INS'.
      PERFORM insert_record.
    WHEN 'DEL'.
      PERFORM delete_record.
    WHEN 'DELT'.
      PERFORM check_header_docu.
      PERFORM popup_for_delete.
      IF g_dansw = 'J'.
        PERFORM mark_for_delete.
      ENDIF.
    WHEN 'RESET'.
      PERFORM popup_for_reset .
      IF g_ransw = 'J'.
        PERFORM reset_docu.
      ENDIF.
    WHEN 'DOCU' .
      PERFORM change_docu .
    WHEN 'IDTL'.
      PERFORM get_item_details.
    WHEN 'HEAD' .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
    WHEN 'ME43'.
      SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
      CLEAR ok_code .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    WHEN 'ME23'.
     WHEN 'ME23N'.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*+004
      CLEAR g_bstyp .
      PERFORM get_bstyp.
      IF g_bstyp = 'F'.
        SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF g_bstyp = 'K'.
        SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
      ENDIF.
      CLEAR ok_code .
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0100  INPUT
*&---------------------------------------------------------------------*
*       Exit command BACK,EXIT,CANCEL FOR SCREEN 100
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
*    when 'BACK' or 'EXIT'  or 'CANCEL' .
    WHEN 'EXIT'  OR 'CANCEL' .
      PERFORM release_lock.
      LEAVE PROGRAM.
    WHEN 'BACK'.
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
      LEAVE PROGRAM.
*      clear zmm_emdhdr-docno.
*      loop at screen.
*        if screen-group1    = '001'.
*          screen-invisible = '1'  .
*          screen-active    = '0'    .
*          screen-input     = '0'.
*          modify screen.
*        endif.
*      endloop.*
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
  ENDCASE.
ENDMODULE.                 " exit_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc105  INPUT
*&---------------------------------------------------------------------*
*      ModifyInternal table Data from Table Control                    *
*----------------------------------------------------------------------*
MODULE modify_tc105 INPUT.
* Begin of <RD1K963111>
  IF prev_okcode = 'ECREA' AND zmm_emdhdr-trans = 'TFS'.
    wa_tc105-rscode = '100'.
  ELSEIF prev_okcode = 'ECREA' AND zmm_emdhdr-trans = 'EMD'.
    wa_tc105-rscode = '200'.
  ELSEIF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'EMD'.
    wa_tc105-rscode = '200'.
  ELSEIF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'TFS'.
    wa_tc105-rscode = '100'.
  ELSEIF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'SDT'.
    wa_tc105-rscode = '340'.
  ENDIF.
* End of <RD1K963111>
  MOVE-CORRESPONDING wa_tc105 TO wa_emddtl.
  MODIFY ist_emddtl FROM wa_emddtl INDEX tc_105-current_line.
ENDMODULE.                 " modify_tc105  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_instrument  INPUT
*&---------------------------------------------------------------------*
*       Check Instrurment Type,No,Date
*----------------------------------------------------------------------*
MODULE check_instrument INPUT.
  CHECK NOT g_tfxm = 'X'.
  DATA: l_vdate LIKE sy-datum.
  CLEAR l_vdate .
*----- insterted on 24.02.2004 -------------------------*
  IF sy-dynnr = '0105'.                                     "+002
    IF g_okhdr = 'X'.
      REFRESH CONTROL 'TC_105' FROM SCREEN '0105' .
    ENDIF.
  ELSEIF sy-dynnr = '0155'.
    IF g_okhdr = 'X'.
      REFRESH CONTROL 'TC_105' FROM SCREEN '0155' .
    ENDIF.
  ENDIF.
*-------------------------------------------------------*
  IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'
     OR prev_okcode = 'CHAN'.
    IF g_okhdr NE 'X'.
      IF wa_tc105-inst_type IS INITIAL.
        MESSAGE e404(zmm).
      ELSE.
        PERFORM check_inst_type USING wa_tc105-inst_type .
*&--->  Check Instrument
        IF zmm_emdhdr-trans = 'EMD'.
          IF wa_tc105-inst_type = 'BG'.
            wa_tc105-rscode = '200'.
          ENDIF.
        ENDIF.
      ENDIF.
      IF wa_tc105-instno IS INITIAL.
        MESSAGE e405(zmm).
      ELSEIF prev_okcode = 'CREA' .
        PERFORM check_valid_instno USING zmm_emdhdr-ebeln wa_tc105-instno.
      ELSEIF prev_okcode = 'CHAN'.
        PERFORM check_valid_instno_chng USING zmm_emdhdr-ebeln
        wa_tc105-instno.
      ENDIF.
      IF  wa_tc105-instdt IS INITIAL .
        MESSAGE e406(zmm).
      ELSE.
        IF NOT ( wa_tc105-inst_type = 'IP' ) .
          IF  wa_tc105-inst_vdt IS INITIAL.
*-- If Validity Date is initial Add 180 days to Inst.date
            l_vdate =  wa_tc105-instdt + 180 .
            MOVE l_vdate TO wa_tc105-inst_vdt .
          ELSE.
            IF wa_tc105-instdt NE l_vdate .
*-- If Validty date is entered by user then take input value as Vall.*
*date
            ELSE.
              l_vdate =  wa_tc105-instdt + 180 .
              MOVE l_vdate TO wa_tc105-inst_vdt .
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*----WHEN create/change  mode check validity date.
* Begin of <RD1K973923> on 201010
*      if not (  wa_tc105-inst_type = 'IV' ) .
      IF NOT (  wa_tc105-inst_type = 'IV' OR wa_tc105-inst_type = 'OP' ) .
* End of <RD1K973923>
        IF wa_tc105-inst_vdt <= sy-datum.
* Begin of <RD1K963111
          MESSAGE e866(zmm_emd).
* End of <RD1K963111
        ENDIF.
*----- end of check V.date-----------------------
*      IF wa_tc105-inst_type NE 'IP'.
        IF wa_tc105-inst_vdt IS INITIAL .
          MESSAGE e407(zmm).
        ENDIF.
        IF  wa_tc105-instdt > sy-datum .
          MESSAGE e469(zmm).
        ENDIF.
        IF wa_tc105-inst_vdt <  wa_tc105-instdt .
          MESSAGE e408(zmm).
        ENDIF.
      ENDIF.
      IF wa_tc105-amount IS INITIAL..
        MESSAGE e409(zmm).
      ENDIF.
*--------------------------------------------------------------------*
*     Check Reason code
*--------------------------------------------------------------------*
      IF wa_tc105-rscode IS INITIAL.
        MESSAGE e463(zmm).
      ELSE.
        PERFORM check_reason_code USING wa_tc105-rscode.
      ENDIF.
*--------------------------------------------------------------------*
*     End of Check Reason code
*--------------------------------------------------------------------*
      IF NOT ( wa_tc105-inst_type = 'IP' OR
               wa_tc105-inst_type = 'IV' ).
        IF wa_tc105-bank IS INITIAL  .
          MESSAGE e417(zmm).
        ENDIF.
        IF wa_tc105-branch  IS INITIAL AND ( wa_tc105-inst_type NE 'IP' OR
                                             wa_tc105-inst_type NE 'IV' ) .
          MESSAGE e418(zmm).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_instrument  INPUT
*&---------------------------------------------------------------------*
*&      Module  EMDHDR_AMOUNT  INPUT
*&---------------------------------------------------------------------*
*       Calculte Total Amount in EMD Header
*----------------------------------------------------------------------*
MODULE emdhdr_amount_instno INPUT.
  PERFORM check_instno .
  PERFORM calc_total_amount .
ENDMODULE.                 " EMDHDR_AMOUNT  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0110  INPUT
*&---------------------------------------------------------------------*
*       EXIT COMMANDS
*----------------------------------------------------------------------*
MODULE exit_command_0110 INPUT.
  CLEAR g_ans.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL'.
      IF zmm_emdhdr-docno IS INITIAL AND g_doccat IS INITIAL.
        LEAVE TO SCREEN '0100'.
      ENDIF.
      IF g_ref = 0.
        PERFORM popup_confirm USING text-005 text-004 .
        IF g_ans = 'J'.
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0110'.
        ENDIF.
      ELSE.
        PERFORM clear_global_110.
        LEAVE TO SCREEN '0110'.
      ENDIF.
    WHEN  'EXIT' .
      IF g_ref = 0.
        PERFORM popup_confirm USING text-005 text-004 .
        IF g_ans = 'J'.
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0100'.
        ENDIF.
      ELSE.
        PERFORM clear_global_110.
        LEAVE TO SCREEN '0100'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0110  INPUT
*&---------------------------------------------------------------------*
*       User Commands in Screen - 0110
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.
  DATA: l_nr LIKE inri-nrrangenr.
  CLEAR wa_emdhdr_t02 .
  DATA: lv_code LIKE sy-ucomm.
  ok_code = sy-ucomm.
* Begin of <RD1K963111>
  IF NOT sy-ucomm IS INITIAL.
    lv_code = sy-ucomm.
  ENDIF.

  IF g_doccat = 'REFUND' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'TFS'.
    zmm_emdref-rscode = '120'.
  ELSEIF g_doccat = 'REFUND' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'EMD'.
    zmm_emdref-rscode = '220'.
  ELSEIF g_doccat = 'REFUND' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'SDT'.
    zmm_emdref-rscode = '350'.
  ELSEIF g_doccat = 'FORFEIT' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'EMD'.
    zmm_emdref-rscode = '230'.
  ELSEIF g_doccat = 'FORFEIT' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'SDT'.
    zmm_emdref-rscode = '360'.
  ELSEIF g_doccat = 'EMD-SD CNV' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'EMD'.
    zmm_emdref-rscode = '210'.
  ENDIF.

  IF zmm_emdhdr-trans = 'TFS' AND zmm_emdref-rscode = '120' AND sy-dynnr = '0110'.
    g_balamt = '0.00'.
  ENDIF.

* End of <RD1K963111>
  IF NOT zmm_emdhdr-docno IS INITIAL AND g_ref = 1.         "07.02.04
    PERFORM check_docno.
    PERFORM get_vendor_name.
  ENDIF.
  IF g_ref = 0.
  ENDIF.
  CASE ok_code.
    WHEN 'SAVE'.
      CLEAR l_nr.
      IF g_doccat   = text-015.   "Refund
        l_nr = '02'.
        MOVE:  'R' TO g_docstat  ,
               'R' TO zmm_emdref-rfcstat.

        g_titel     = text-015 .
        g_text      = text-012 .
      ELSEIF g_doccat = text-016. "Forfeit
        l_nr = '03'.
        MOVE: 'F'  TO  g_docstat  ,
              'F'  TO zmm_emdref-rfcstat.

        g_titel     = text-016.
        g_text      = text-013 .
      ELSEIF g_doccat  = text-018. "EMD-SD Conversion
        l_nr = '04'.
        MOVE : 'C' TO  g_docstat  ,
               'C' TO  zmm_emdref-rfcstat.

        zmm_emdref-trans = 'SDT'.
        g_titel     = text-017.
        g_text      = text-014 .
      ENDIF.
      PERFORM popup_conf_110 USING g_titel g_text.
      IF g_rfc = 'J'.
        CLEAR g_okhdr .
        PERFORM get_rfc_docno USING l_nr.
        PERFORM save_data_110 ON COMMIT.
        IF g_save_h = 0 AND g_save_i = 0.
          COMMIT WORK.
          MESSAGE s428(zmm) WITH g_titel g_docno  .
          PERFORM clear_global_110.
          CLEAR g_docno.
        ENDIF.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    WHEN 'CHNG' OR 'DISP' OR 'DELE' OR 'UNDEL'.
      PERFORM clear_global_110.
      prev_okcode = ok_code .
      g_rfc_chk = 1.
      CALL SCREEN '0150'.
    WHEN 'HEAD' .
      MOVE  wa_emdhdr_t02-docno  TO  wa_emdhdr-docno.
      MOVE  wa_emdhdr_t02-cron   TO  wa_emdhdr-cron .
      MOVE  wa_emdhdr_t02-trans  TO  wa_emdhdr-trans .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
    WHEN 'SUBFI'.
      CALL TRANSACTION 'ZMMRFCSUB'.
    WHEN 'RFCR'.
      CALL TRANSACTION 'ZMMRFC' .
  ENDCASE.
ENDMODULE.                 " user_command_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0115  INPUT
*&---------------------------------------------------------------------*
*     Exit Command - screen 115
*----------------------------------------------------------------------*
MODULE exit_command_0115 INPUT.
  CLEAR g_ans.
  ok_code = sy-ucomm.
  REFRESH ist_emdref_01.
  REFRESH CONTROL 'TC_120' FROM SCREEN '0120'.
  ts_115-activetab = 'RFCHD' .
  g_dynnr = '0130'.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      IF prev_okcode = 'CRET' OR prev_okcode = 'CHNG' OR
        prev_okcode  = 'UNDEL'.
        IF g_rfc_chk = 0.
          PERFORM popup_confirm USING text-005 text-004 .
          IF g_ans = 'J'.
            PERFORM release_lock_rfc USING zmm_emdref-docno .
            PERFORM clear_global_110.
            LEAVE TO SCREEN '0110'.
          ENDIF.
        ELSE.
          PERFORM release_lock_rfc USING zmm_emdref-docno .
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0110'.
        ENDIF.
      ELSE.
        PERFORM release_lock_ref .
        PERFORM clear_global_110.
        LEAVE TO  SCREEN '0110'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0115  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0115  INPUT
*&---------------------------------------------------------------------*
*       User Commands Screen - 0115
*----------------------------------------------------------------------*
MODULE user_command_0115 INPUT.
  IF  zmm_emdref-docno IS INITIAL.
    REFRESH CONTROL 'TC_120' FROM SCREEN '0120'.
  ENDIF.
  ok_code = sy-ucomm .
  CASE ok_code .
    WHEN 'SAVE'.
      PERFORM save_change_popup USING text-006.
      IF g_sc_ans = '1'.
        PERFORM save_data_115 ON COMMIT.
        IF  g_save_i = 0.
          COMMIT WORK.
          MESSAGE i412(zmm).
          PERFORM clear_global_115.
          LEAVE TO SCREEN '0110'.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
    WHEN 'DELE'.
      PERFORM popup_confirm USING text-022 text-023 .
      IF g_ans = 'J'.
        PERFORM delete_rfc_doc.
        PERFORM clear_global_115.
        LEAVE TO SCREEN '0110'.
      ENDIF.
*----------- Reset RFC Document
    WHEN 'RESET'.
      PERFORM popup_confirm USING text-051 text-053 .
      IF g_ans = 'J'.
        PERFORM rest_rfc_doc USING zmm_emdref-docno.
        PERFORM clear_global_115.
        LEAVE TO SCREEN '0110'.
      ENDIF.
    WHEN 'HEAD' .
      PERFORM get_header.
    WHEN  'RFCHD'.
      ts_115-activetab = ok_code .
      g_dynnr = '0130'.
    WHEN  'RFC'.
      ts_115-activetab = ok_code .
      g_dynnr = '0120'.
*&---> Get Refund/Forfeit/EMD-SD Converted Data
      PERFORM get_rfc_data.
*&---<
    WHEN 'ME43'.
      SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
      CLEAR ok_code .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    WHEN 'ME23'.
     WHEN 'ME23N'.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*+004
      CLEAR g_bstyp .
      PERFORM get_bstyp.
      IF g_bstyp = 'F'.
        SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF g_bstyp = 'K'.
        SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
      ENDIF.
      CLEAR ok_code .
    WHEN  'ENMT' .
      IF zmm_emdhdr-trans = 'TFS' OR
         zmm_emdhdr-trans = 'EMD'.
        SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
        CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
        CLEAR ok_code .
      ELSE.
        CLEAR g_bstyp .
        PERFORM get_bstyp.
        IF g_bstyp = 'F'.
          SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ELSEIF g_bstyp = 'K'.
          SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
        ENDIF.
        CLEAR ok_code .
      ENDIF.
  ENDCASE.
ENDMODULE.                 " user_command_0115  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0125  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0125 INPUT.
  CASE sy-ucomm  .
    WHEN 'BACK' OR '%EX' OR 'RW' .
      LEAVE  SCREEN  .
  ENDCASE .
ENDMODULE.                 " USER_COMMAND_0125  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tc120 INPUT.
  CLEAR g_lines.
  MOVE-CORRESPONDING wa_emdref_01 TO wa_emdref_02  .
  MODIFY ist_emdref_01 FROM wa_emdref_02   INDEX tc_120-current_line.
ENDMODULE.                 " modify_tc120  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_120  INPUT
*&---------------------------------------------------------------------*
*      Exit Command for Screen 120.
*----------------------------------------------------------------------*
MODULE exit_command_120 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM clear_global_110.
      LEAVE TO SCREEN '0100'.
  ENDCASE.
ENDMODULE.                 " EXIT_COMMAND_120  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PONO  INPUT
*&---------------------------------------------------------------------*
*      Check PO no
*----------------------------------------------------------------------*
MODULE check_docno_pono INPUT.
*&----> Check PO no
*&---> EMD-SD CNV text-018
  IF g_doccat  = 'EMD-SD CNV' AND NOT zmm_emdref-ebeln IS INITIAL.
    PERFORM check_pono.
    PERFORM check_vendor_po USING  zmm_emdhdr-docno.
  ENDIF.
*&-----<
  IF NOT zmm_emdhdr-docno IS INITIAL.
    PERFORM check_valid_docno.
  ENDIF.
  PERFORM get_total_ref  .
*---------------------------------------------------------------*
*Check whether RFC AMOUNT is equal to Receipt Amount.
* If then raise error message.
  IF NOT zmm_emdhdr-docno IS INITIAL.
    IF g_tot_ref = zmm_emdhdr-amount.
      MESSAGE e474(zmm).
    ENDIF.
  ENDIF.
*----------------------------------------------*
ENDMODULE.                 " CHECK_PONO  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_header  INPUT
*&---------------------------------------------------------------------*
*       Check Header Data  of screen 105
*----------------------------------------------------------------------*
MODULE check_header INPUT.

  IF   zmm_emdhdr-trans    IS INITIAL    OR
       zmm_emdhdr-ebeln    IS INITIAL    OR
       zmm_emdhdr-currency IS INITIAL    OR
       zmm_emdhdr-co_code  IS INITIAL .
    g_okhdr = 'X'.
  ELSE.
    CLEAR g_okhdr .
  ENDIF.

*---------------------------------------------------------------------*
* SRM Changes +002  29.09.2004
  IF prev_okcode = 'ECREA' OR g_ttype = 'SRM'.
    IF   zmm_emdhdr-trans    IS INITIAL    OR
         zmm_emdhdr-currency IS INITIAL    OR
         zmm_emdhdr-co_code  IS INITIAL    OR
         zmm_emdhdr-vendorno IS INITIAL    OR
         zmm_emdhdr-ebidno   IS INITIAL.
      g_okhdr = 'X'.
    ELSE.
      CLEAR g_okhdr .
    ENDIF.
** For SRM Bid Only Trasaction type TFS and EMD is Allowed.
** Otherwise raise error message
    IF NOT ( zmm_emdhdr-trans = 'TFS' OR
             zmm_emdhdr-trans =  'EMD' ).
      MESSAGE e507(zmm).
    ENDIF.
  ENDIF.
*&--->
  IF prev_okcode = 'ECREA' OR prev_okcode = 'CHAN'.
    IF NOT zmm_emdhdr-vendorno IS INITIAL.
      PERFORM check_vendor USING zmm_emdhdr-vendorno .
    ENDIF.
    IF NOT zmm_emdhdr-ebidno IS INITIAL.
      PERFORM check_ebidno .
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------*

*&------> Check INR incase of intrument 'IP'.
  IF wa_tc105-inst_type = 'IP' AND
    zmm_emdhdr-currency NE 'INR'.
    MESSAGE e554(zmm).
  ENDIF.
* Begin of <RD1K963111>
* To validate the Vendor & E-Bid No passing to SRM system
  IF zmm_emdhdr-trans = 'TFS' AND ( prev_okcode = 'ECREA' OR prev_okcode = 'CHAN' ).
    IF NOT zmm_emdhdr-vendorno IS INITIAL AND NOT zmm_emdhdr-ebidno IS INITIAL.
      PERFORM check_ebid_vednor.
    ENDIF.
  ENDIF.
* Begin of <RD1K963111>
*&------<
*&--> Check Document no When Create Mode
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN'.
    PERFORM check_ebeln.
  ENDIF.
*&--<
*&--> Get Vendor code and Tender no
  PERFORM get_vendorno_tenderno.
*&--<
*&--> Check Location
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN'
     OR prev_okcode = 'ECREA'.
    IF zmm_emdhdr-trans = 'TFS'.
      IF NOT zmm_emdhdr-place IS INITIAL.
        PERFORM check_loc.
      ENDIF.
    ENDIF.
  ENDIF.
*&--<
*&--> Check  TFS doc. same RFQ and Currency Exist or not.
  IF prev_okcode = 'CREA' AND wa_tc105-inst_type IS INITIAL.
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD'
       OR  zmm_emdhdr-trans = 'SDT'.
      PERFORM check_rfq .
    ENDIF.
  ENDIF.
*&--<
*&----->  Check Company code.
  IF NOT zmm_emdhdr-co_code IS INITIAL.
    PERFORM check_company_code .
  ENDIF.
*------<
*&---> Check whether Vendor code exist in Entered Company code or not
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN'.
    IF NOT g_vcode IS INITIAL AND NOT zmm_emdhdr-co_code IS INITIAL.
      PERFORM check_comp_code USING g_vcode zmm_emdhdr-co_code .
    ENDIF.
  ENDIF.
*&-----<
ENDMODULE.                 " check_header  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_docno  INPUT
*&---------------------------------------------------------------------*
*       Check Docuement no
*----------------------------------------------------------------------*
MODULE check_docno INPUT.

*-----------------------------------------------------------------*
** Check Document *---* If Document is Converted from EMD TO SD
*  Don't allow to  Edit.
*-----------------------------------------------------------------*
*&--> Get Header Data
  IF NOT zmm_emdref-docno IS INITIAL AND g_rfc_chk = 1.
    PERFORM check_docno_rfc.
    PERFORM get_vendor_name.
  ENDIF.
*&--<
*----------------------------------------------------------------*
*  Check whether any document exist in system                    *
*  corresponding to  EMD-SD Converted document  . If then
*  Don't allow for Delete                                       *
*----------------------------------------------------------------*
  IF prev_okcode NE 'DISP'.
    PERFORM  check_emdconv_doc USING zmm_emdref-docno.
  ENDIF.
*----------------------------------------------------------------*
*------- Check Document Status *---------------------------------*
  PERFORM check_rfc_docu_status.
*-----------------------------------------------------------------*
*------   Check Balace amount when 'RESET'    --------------------*
  IF prev_okcode = 'UNDEL'.
    PERFORM check_amount_bf_reset.
  ENDIF.
*-----------------------------------------------------------------*
  PERFORM check_rfc_amount  .
*&-->  Check Amount
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHNG' OR
     prev_okcode = 'DISP' OR prev_okcode = 'UNDEL' .
  ENDIF.
*&--<
ENDMODULE.                 " check_docno  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_135  INPUT
*&---------------------------------------------------------------------*
*      Exit command of screen 135
*----------------------------------------------------------------------*
MODULE exit_command_135 INPUT.
  ok_code =  sy-ucomm.
  CASE ok_code .
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL' .
      REFRESH CONTROL 'TC_135' FROM SCREEN '0135'.
      PERFORM release_lock.
      PERFORM clear_screen_0105.
      CLEAR ok_code .
      CLEAR prev_okcode .
      LEAVE TO SCREEN '0100'.
  ENDCASE.
ENDMODULE.                 " exit_command_135  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_135  INPUT
*&---------------------------------------------------------------------*
*      User command of screen - 135
*----------------------------------------------------------------------*
MODULE user_command_135 INPUT.
  DATA: l_no(2).

  CLEAR: g_firet, g_mmret.

  PERFORM modify_table_emddtl .
  CLEAR g_status.
  CASE ok_code.
*&-----> Header Detail
    WHEN 'HEAD' .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
      prev_okcode = ok_code .
      CLEAR ok_code.
*&-----> Send to Bank for Confirmation
    WHEN 'BCONF'.
      PERFORM check_item_select  .
      IF g_ans = '0'.
        PERFORM popup_confirm USING    text-024 text-025.
      ENDIF.
      IF g_ans = 'J'.
        PERFORM update_for_bankconf .
        PERFORM update_header_status_bglc_main.
        MESSAGE s435(zmm).
        PERFORM clear_global_135.                           "-004
        LEAVE TO SCREEN '0100'.                             "-004
      ENDIF.
      prev_okcode = ok_code .
      CLEAR ok_code.
*&-----> Reset Document
    WHEN 'RESET'.
      prev_okcode = ok_code .
      CLEAR ok_code.
      PERFORM check_sel_reset_item .
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-026 text-027.
        IF g_ans = 'J'.
          PERFORM reset_bank_conf_doc USING g_idocno g_itemno
          g_reset_status  .
          PERFORM update_header_status_bglc_main.
          PERFORM status_message USING g_reset_status.
*          perform release_lock.  -004
*          perform clear_global_135. -004
*          leave to screen '0100'.  -004
        ENDIF.
      ENDIF.
*&------> Post Confirmation
    WHEN 'PCONF'.
      PERFORM check_sel_item .
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-028 text-029.
        IF g_ans = 'J'.
*-----------------------------------------------------------*
* Popup for Bank Deny/Confirm                               *
          PERFORM popup_deny_accept.
          IF g_ans_ad = '1' OR g_ans_ad = '2'.
            PERFORM update_post_conf USING g_ans_ad.
            PERFORM update_header_status_bglc_main.
            MESSAGE s439(zmm).
*           perform release_lock.      -004
*            perform clear_global_135. -004
*            leave to screen '0100'.   -004
          ENDIF.
        ENDIF.
      ENDIF.
*&-------> Send Document to FI
    WHEN 'SNDFI'.
      PERFORM check_sel_item_sndfi .
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-041 text-042.
        IF g_ans = 'J'.
          PERFORM update_status_subfi.
          PERFORM update_header_status_bglc_main.
          MESSAGE s449(zmm).
*          perform release_lock.
*          perform clear_global_135. -004
*          leave to screen '0100'.   -004
        ENDIF.
      ENDIF.
*&-----> Document Amend
    WHEN 'AMEND'.
      IF NOT zmm_emdhdr-docno IS INITIAL.
        CALL SCREEN '0145'.
      ENDIF.
*&-------> Item Details
    WHEN 'IDTL'.
      PERFORM get_item_details.
*&------->  Invoke
    WHEN 'INVOK'.
* Authorization Check  for INVOKING BG/ LC
      PERFORM  check_auth .
      PERFORM check_sel_item_invoke.
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-030 text-031.
        IF g_ans = 'J'.
          PERFORM invoke_docu.
          MESSAGE s454(zmm).
*          perform release_lock.     -004
*          perform clear_global_135. -004
*          leave to screen '0100'.   -004
        ENDIF.
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009

*&------>  Return BG/LC Document
    WHEN 'RETN'.

* Authorization Check for RETURN of BG/ LC
      IF zmm_emdhdr-trans = 'SDT' OR zmm_emdhdr-trans = 'EMD'.
        PERFORM  check_auth_return USING zmm_emdhdr-trans   .
      ENDIF.
*      PERFORM modify_table_emddtl .
      PERFORM check_sel_item_retn .

      IF zmm_emdhdr-trans = 'EMD'.
        IF g_ans = '0' AND g_error = 0 AND
        ( g_mmret = 'X' OR g_firet = 'X' ).
          PERFORM popup_confirm USING    text-044 text-045.
        ENDIF.
      ELSEIF zmm_emdhdr-trans = 'SDT'.
        IF g_ans = '0' AND g_error = 0 .
          PERFORM popup_confirm USING    text-044 text-045.
        ENDIF.
      ENDIF.
      IF g_ans = 'J'.
        PERFORM retrun_docu.
        MESSAGE s453(zmm).
*        perform release_lock.     -004
*        perform clear_global_135. -004
*        leave to screen '0100'.   -004
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009
*&-------<
*------------------------------------------------------------*
*  Document Accept by FI
* Before document accept in FI the status of the document must be
* 'S'- ie Submitted to FI.
    WHEN 'ACCFI'.
* Authorization Check  for ACCEPTED BY FI
      PERFORM  check_auth .
      PERFORM cehck_sel_item_accept.
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-059 text-060.
        IF g_ans = 'J'.
          PERFORM accept_docu.
          PERFORM update_header_status_bglc_main.
*          perform release_lock.      -004
*          perform clear_global_135.  -004
*          leave to screen '0100'.    -004
        ENDIF.
      ENDIF.
*------------------------------------------------------------*
*-----start of addition 02.02.05   +003 --------------------*
    WHEN 'RQIR'.
*      PERFORM modify_table_emddtl .
      PERFORM check_sel_item_rqri.
      IF g_ans = '0' AND g_error = '0'.
        PERFORM popup_req_ret_invk.
        IF g_ans_ad = '1' OR g_ans_ad = '2'.
*          perform get_reqslno changing l_no .
          PERFORM get_reqno_save  USING g_ans_ad.
          PERFORM check_status_before_update USING g_ans_ad.
          IF g_error = '0' AND g_ans = '0'.
            PERFORM change_doc_reqno .
          ENDIF.
          PERFORM update_req_ret_inv USING g_ans_ad .
        ENDIF.
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009
    WHEN 'RSTIR'.
      PERFORM check_req_status.
      IF g_ans = '0' AND g_error = '0'.
        PERFORM popup_confirm USING    text-044 text-079.
        IF g_ans = 'J'.
* Change Document for Reqno starts here
          PERFORM get_reqno .
          PERFORM change_doc_reqno .
          PERFORM update_req_status.
        ENDIF.
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009
    WHEN 'CGHIS'.
      LEAVE TO LIST-PROCESSING  AND RETURN TO SCREEN 0135 .
      PERFORM display_chng_ri_history.
    WHEN 'BGREQ'.
      CALL TRANSACTION 'ZMMBGREQ'.
*------------------------------------------------------------*

    WHEN 'ME43'.
      SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
      CLEAR ok_code .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    WHEN 'ME23'.
      WHEN 'ME23N'.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      CLEAR g_bstyp .
      PERFORM get_bstyp.
      IF g_bstyp = 'F'.
        SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF g_bstyp = 'K'.
        SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME33K'      AND SKIP FIRST SCREEN.
      ENDIF.
      CLEAR ok_code .
    WHEN 'BGCNF'.
      CALL TRANSACTION 'ZMMBGCNF' .
    WHEN 'BGAMD'.
      CALL TRANSACTION 'ZMMBGAMD' .
    WHEN 'INVK'.
      CALL TRANSACTION 'ZMMBGIV'.
    WHEN  'BGRET'.
      CALL TRANSACTION 'ZMMBGRET'.
  ENDCASE.
  prev_okcode = ok_code .
  CLEAR ok_code .
ENDMODULE.                 " user_command_135  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc135  INPUT
*&---------------------------------------------------------------------*
*       move table control data into internal table
*----------------------------------------------------------------------*
MODULE modify_tc135 INPUT.
  MOVE-CORRESPONDING wa_tc135 TO wa_emddtl  .
  MODIFY ist_emddtl FROM wa_emddtl   INDEX tc_135-current_line.
ENDMODULE.                 " modify_tc135  INPUT
*&---------------------------------------------------------------------*
*&      Module  ext_140  INPUT
*&---------------------------------------------------------------------*
*      Exit Command of Screen 140
*----------------------------------------------------------------------*
MODULE ext_140 INPUT.
  CASE sy-ucomm  .
    WHEN 'BACK' OR '%EX' OR 'RW' .
      CLEAR: g_status, g_reqtext.
      LEAVE  SCREEN  .
  ENDCASE .
ENDMODULE.                 " ext_140  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0145  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0145 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM popup_confirm USING text-005 text-004 .
      IF g_ans = 'J'.
        PERFORM release_lock.
        PERFORM clear_screen_0105.
        SET SCREEN  '0100'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0145  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0145  INPUT
*&---------------------------------------------------------------------*
*      User Command of screen 0145.
*----------------------------------------------------------------------*
MODULE user_command_0145 INPUT.
  CASE ok_code .
    WHEN  'SAVE'.
      PERFORM save_change_popup USING text-006.
      IF g_sc_ans = '1' .
* Select record for the given document no. from DB table
        SELECT * INTO TABLE ist_dtl FROM zmm_emddtl WHERE
                                   docno = wa_emddtl-docno  .

        PERFORM modify_data_s145  ON COMMIT  .
        IF g_save_h = 0 AND g_save_i = 0.
          COMMIT WORK.
          MESSAGE s455(zmm).
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0100' .
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
*&-------> Item Details
    WHEN 'IDTL'.
      PERFORM get_item_details.
    WHEN 'HEAD' .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
    WHEN  'ENMT' .

      IF zmm_emdhdr-trans = 'TFS' OR
         zmm_emdhdr-trans = 'EMD'.
        SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
        CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
        CLEAR ok_code .
      ELSE.

        CLEAR g_bstyp .
        PERFORM get_bstyp.
        IF g_bstyp = 'F'.
          SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ELSEIF g_bstyp = 'K'.
          SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
        ENDIF.
        CLEAR ok_code .
      ENDIF.
    WHEN 'HSTRY' .
      LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0145 .
      PERFORM disp_chg_hstry .
* End of logic for changed document .
  ENDCASE.
ENDMODULE.                 " user_command_0145  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_instrument_S140  INPUT
*&---------------------------------------------------------------------*
*    Check Instrument details in screen 140
*----------------------------------------------------------------------*
MODULE check_instrument_s145 INPUT.
  IF wa_tc145-inst_vdt IS INITIAL .
    MESSAGE e407(zmm).
  ENDIF.
  IF wa_tc145-inst_vdt <  wa_tc145-instdt .
    MESSAGE e408(zmm).
  ENDIF.
  IF wa_tc145-amount IS INITIAL..
    MESSAGE e409(zmm).
  ENDIF.
  IF wa_tc145-rscode IS INITIAL.
    MESSAGE e456(zmm).
  ELSE.
    PERFORM check_reason_code_amend USING wa_tc145-rscode.
  ENDIF.
ENDMODULE.                 " check_instrument_S140  INPUT
*&---------------------------------------------------------------------*
*&      Module  emdhdr_amount_s145  INPUT
*&---------------------------------------------------------------------*
*       Check Header Amount
*----------------------------------------------------------------------*
MODULE emdhdr_amount_s145 INPUT.
  PERFORM calc_total_amount .
ENDMODULE.                 " emdhdr_amount_s145  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_docno_s100  INPUT
*&---------------------------------------------------------------------*
*      Check Document No entered in screen 100.
*----------------------------------------------------------------------*
MODULE check_docno_s100 INPUT.
  DATA l_msg_text(20).
  DATA l_inst_type LIKE zmm_emddtl-inst_type .
  CLEAR wa_emdhdr .
  IF   ok_code   = 'CHAN'.
    l_msg_text   = 'Change'.
  ELSEIF ok_code = 'DELE'.
    l_msg_text   = 'Delete'.
  ELSEIF ok_code = 'REST'.
    l_msg_text   = 'Reset'.
  ENDIF.

  IF ok_code  = 'CHAN' OR
     ok_code  = 'DELE' OR
     ok_code  = 'BGLC' OR
     ok_code  = 'AMEND' .
    PERFORM check_bglc .
    IF NOT zmm_emdhdr-docno  IS INITIAL.
      SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.
*-----------------------------------------------------------------*
*  For BG/LC header level Doc. complete validation is not applicable.
        SELECT INST_TYPE FROM ZMM_EMDDTL INTO L_INST_TYPE UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*-----------------------------------------------------------------*
*---> Check If the Document is Parked/Deleted.
        IF wa_emdhdr-status = 'D'.
          MESSAGE e425(zmm).
        ELSEIF wa_emdhdr-status = 'U'.
          MESSAGE e470(zmm) WITH   l_msg_text .
*-- BG/LC doc. accepted by FI
        ELSEIF  wa_emdhdr-status = 'J' .
          IF ( l_inst_type = 'BG' OR  l_inst_type = 'LC' ) .
          ELSE.
            MESSAGE e499(zmm) .
          ENDIF.
*--- partially parked.
        ELSEIF   wa_emdhdr-status = 'K' .
          IF prev_okcode = 'CHAN' OR
             prev_okcode = 'BGLC'.
          ELSE.
            MESSAGE e556(zmm).
          ENDIF.
*----- BG/LC Inprocess
        ELSEIF   wa_emdhdr-status = 'Q' .
          IF  ( l_inst_type NE 'BG' OR  l_inst_type NE 'LC' ) .
          ELSE.
            MESSAGE e557(zmm).
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
*------< End of check --------------------------------------*
    ENDIF.
  ENDIF.
  IF NOT zmm_emdhdr-docno  IS INITIAL AND NOT ok_code = 'BACK' .
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc NE 0.                                       "+002
      MESSAGE e411(zmm).
    ENDIF.                                                  "+002
  ENDIF.
  IF ok_code = 'REST'.
    IF NOT zmm_emdhdr-docno IS INITIAL.
      IF wa_emdhdr-status = 'N'.
        l_msg_text = text-040.
        MESSAGE e472(zmm).
      ELSEIF wa_emdhdr-status NE  'D'.
        MESSAGE e561(zmm).
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT zmm_emdhdr-docno IS INITIAL.
    IF prev_okcode = 'AMEND'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_docno_s100  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc145  INPUT
*&---------------------------------------------------------------------*
*      Modify table control Data
*----------------------------------------------------------------------*
MODULE modify_tc145 INPUT.
  MOVE-CORRESPONDING wa_tc145 TO wa_emddtl  .
  MODIFY ist_emddtl FROM wa_emddtl      INDEX tc_145-current_line.
ENDMODULE.                 " modify_tc145  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_COMBI_INST_TYPE  INPUT
*&---------------------------------------------------------------------*
*      Check Instrument Group
*----------------------------------------------------------------------*
MODULE check_combi_inst_type INPUT.
  PERFORM check_inst_group.
ENDMODULE.                 " CHECK_COMBI_INST_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_balance_amt  INPUT
*&---------------------------------------------------------------------*
*      Check Balace amt
*----------------------------------------------------------------------*
MODULE chk_balance_amt .
  PERFORM check_rfc_amount  .
ENDMODULE.                 " chk_balance_amt  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_balance_amt_receipt  INPUT
*&---------------------------------------------------------------------*
*     Check Balace amount.
*----------------------------------------------------------------------*
MODULE chk_balance_amt_receipt INPUT.
  IF NOT zmm_emdhdr-docno IS INITIAL.
    PERFORM check_rfc_amount_receipt  .
  ENDIF.
ENDMODULE.                 " chk_balance_amt_receipt  INPUT
*&---------------------------------------------------------------------*
*&      Module  update_status  INPUT
*&---------------------------------------------------------------------*
*    Update Header Status.
*----------------------------------------------------------------------*
MODULE update_status INPUT.
*&----> If all line item are PARKED/REFUND/FORFEIT/EMD-SD CONV..
** the update header level status.
  PERFORM update_head_status_105.
ENDMODULE.                 " update_status  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       User Command of screen 150.
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.
  IF ok_code = 'CHNG'   OR
     ok_code = 'DELE'   OR
     ok_code =  'UNDEL' .
    IF NOT zmm_emdref-docno IS INITIAL.
      PERFORM set_loc_rfc USING zmm_emdref-docno.
    ENDIF.
  ENDIF.
  IF g_rfc_chk = 0.
    CALL SCREEN '115'.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_150  INPUT
*&---------------------------------------------------------------------*
*       Exit Command of screen 150.
*----------------------------------------------------------------------*
MODULE exit_150 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM release_lock_rfc USING  zmm_emdref-docno.
      PERFORM clear_global_115.
      LEAVE TO SCREEN '0110'.
  ENDCASE.
ENDMODULE.                 " exit_150  INPUT
*&---------------------------------------------------------------------*
*&       UPDATE_HEADER_STATUS_BGLC  INPUT
*&---------------------------------------------------------------------*
*     Update Header Status based on BG/LC Doc. Actions.
*   Eg. If all documents ar accepted by FI the Update Header status with
*   Complete.
*----------------------------------------------------------------------*
MODULE update_header_status_bglc INPUT.
  DATA: wa_dtl_t001 TYPE zmm_emd_status.
  DATA: l_stat,
        l_found.
  LOOP AT ist_emddtl INTO wa_dtl_t001.
    IF sy-tabix = 1.
      l_stat    =  wa_dtl_t001-status.
    ENDIF.
    IF l_stat   NE  wa_dtl_t001-status.
      l_found   =  'X'.
      EXIT.
    ELSE.
      l_found   =  '0'.
    ENDIF.
  ENDLOOP.
  IF l_found = '0' AND NOT l_stat IS INITIAL.
    IF l_stat ='N'.
      PERFORM update_header_status_bglc USING g_idocno 'N'.
    ELSEIF l_stat = 'P'.
      PERFORM update_header_status_bglc USING g_idocno 'J'.
    ENDIF.
  ELSEIF l_found = 'X'.
    PERFORM update_header_status_bglc USING g_idocno 'Q'.
  ENDIF.
ENDMODULE.                 " UPDATE_HEADER_STATUS_BGLC  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_rscode  INPUT
*&---------------------------------------------------------------------*
*    Check reason code.
*----------------------------------------------------------------------*
MODULE check_rscode INPUT.
  IF NOT zmm_emdref-rscode IS INITIAL.
    PERFORM check_reason_code_rfc USING zmm_emdref-rscode.
  ENDIF.
ENDMODULE.                 " check_rscode  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0160  INPUT
*&---------------------------------------------------------------------*
*       Exit Command for Screen 160
*----------------------------------------------------------------------*
MODULE exit_command_0160 INPUT.

  IF sy-ucomm = 'BACK' OR sy-ucomm = 'EXIT' OR sy-ucomm = 'CANCEL'.
    IF prev_okcode = 'CHAN'.
      PERFORM popup_confirm USING text-005 text-004 .
      IF g_ans = 'J'.
        PERFORM release_lock .
        PERFORM clear_screen_160.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    ELSE.
      PERFORM release_lock .
      PERFORM clear_screen_160.
      LEAVE TO SCREEN '0100'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " exit_command_0160  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0160  INPUT
*&---------------------------------------------------------------------*
*      User Command for screen 160
*----------------------------------------------------------------------*
MODULE user_command_0160 INPUT.
  CASE ok_code .
    WHEN 'SAVE'.
      IF prev_okcode = 'ECREA'.
        PERFORM save_change_popup USING zmm_emdhdr. "TEXT-050.
        IF  g_sc_ans = '1'.
          PERFORM get_docno   .
          PERFORM save_srm_header_doc .
        ENDIF.
      ELSEIF prev_okcode = 'CHAN'.
        PERFORM save_change_popup USING text-006.
        IF g_sc_ans = '1'.
          PERFORM save_changes.
        ENDIF.
      ENDIF.
    WHEN 'DELE'.
      CLEAR g_dansw .
      PERFORM popup_for_delete.
      IF g_dansw = 'J'.
        PERFORM mark_for_dele_edoc   .
      ENDIF.
    WHEN 'RESET'.
      CLEAR g_dansw .
      PERFORM popup_for_reset .
      IF g_ransw = 'J'.
        PERFORM reset_edoc  .
      ENDIF.
  ENDCASE.
ENDMODULE.                 " user_command_0160  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_combi_inst_type_etend  INPUT
*&---------------------------------------------------------------------*
*     Check Instrument Type incase of E-Tenders
*----------------------------------------------------------------------*
MODULE check_combi_inst_type_etend INPUT.
*+004
  PERFORM check_inst_group_etend.

ENDMODULE.                 " check_combi_inst_type_etend  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBID_VEDNOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_ebid_vednor .
  DATA: l_logsys(32).
  DATA lv_logsys TYPE string.
  DATA lv_rfcsi_export LIKE  rfcsi.

  TYPES: BEGIN OF ls_srmpay,
         mandt TYPE mandt,
         ebidno(10) TYPE c,
         vendorno(10) TYPE c,
         epgtxnid(15) TYPE c,
         paytyp,
         usr(12) TYPE c,
         amount TYPE wert8,   "ZMM_EMDDTL-AMOUNT,  28012014 BY SUDHIR SHARMA
         currency TYPE waers,
         paydate TYPE datum,
         remakrs(60) TYPE c,
         c_date(8) TYPE c,
         c_time(6),
         timestamp TYPE timestamp,
         END OF ls_srmpay.

  DATA: ist_srmpay TYPE TABLE OF ls_srmpay,
        wa_srmpay TYPE ls_srmpay.

  DATA: lv_remarks(60) TYPE c.

  IMPORT ist_srmpay FROM MEMORY ID 'TENDER_FEE'.
  CLEAR wa_srmpay.
  READ TABLE ist_srmpay INTO wa_srmpay WITH KEY ebidno = zmm_emdhdr-ebidno
                                                vendorno = zmm_emdhdr-vendorno.
  lv_remarks = 'Online payment. Transaction Successful'.
  IF wa_srmpay-epgtxnid IS INITIAL AND wa_srmpay-remakrs <> lv_remarks.
* Get Logical system name from table ZMM_LOGSYS
    SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
                  WHERE  appl = 'SRM'.
    IF NOT l_logsys IS INITIAL.
      lv_logsys =  l_logsys.
* Function module to check the RFC Connection
      CALL FUNCTION 'ZRFC_GET_SYSTEM_INFO'
        EXPORTING
          destination  = lv_logsys
        IMPORTING
          rfcsi_export = lv_rfcsi_export.

      IF lv_rfcsi_export IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = zmm_emdhdr-vendorno
          IMPORTING
            output = zmm_emdhdr-vendorno.

        CALL FUNCTION 'Z_CHECK_BIDDER_REGISTERED' DESTINATION l_logsys
          EXPORTING
            iv_bid_no    = zmm_emdhdr-ebidno                "char10
            iv_vendor_no = zmm_emdhdr-vendorno              "char10
          IMPORTING
            allow        = zallow.                          "char1

        IF zallow = 'C'.
*          if sy-uname(3) <> 'CMM'.
*         Vendor should be registered for the document before running this report
          MESSAGE e001(zmm_emd) WITH zmm_emdhdr-vendorno zmm_emdhdr-ebidno.
*          endif.
        ELSEIF zallow = 'A'.
          MESSAGE e003(zmm_emd) WITH zmm_emdhdr-ebidno.
        ELSEIF zallow = 'B'.
          IF sy-uname(3) <> 'CMM'.
            MESSAGE e004(zmm_emd) WITH zmm_emdhdr-ebidno.
          ENDIF.
        ELSEIF zallow = 'D'.
          IF sy-uname(3) <> 'CMM'.
            MESSAGE e004(zmm_emd) WITH zmm_emdhdr-ebidno.
          ENDIF.
        ENDIF.

      ELSE.
        MESSAGE e002(zmm_emd).
      ENDIF.
    ENDIF.
  ENDIF.
* Begin of <RD1K973923> on 20102010
  SELECT VENDORNO EBIDNO TRTYP TRANS FROM ZMM_EMDHDR INTO
 ( ZMM_EMDHDR-VENDORNO , ZMM_EMDHDR-EBIDNO , ZMM_EMDHDR-TRTYP , ZMM_EMDHDR-TRANS ) UP TO 1 ROWS WHERE VENDORNO = ZMM_EMDHDR-VENDORNO AND EBIDNO = ZMM_EMDHDR-EBIDNO AND TRTYP = 'SRM' AND TRANS = ZMM_EMDHDR-TRANS AND STATUS NE 'D'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  select single vendorno ebidno trtyp from zmm_emdhdr into
*      (zmm_emdhdr-vendorno, zmm_emdhdr-ebidno, zmm_emdhdr-trtyp) where vendorno = zmm_emdhdr-vendorno
*                                                and ebidno = zmm_emdhdr-ebidno
*                                                and trtyp = 'SRM'.
* End of <RD1K973923>
  IF sy-subrc = 0.
    MESSAGE e006(zmm_emd) WITH zmm_emdhdr-vendorno zmm_emdhdr-ebidno.
  ENDIF.

ENDFORM.                    " CHECK_EBID_VEDNOR
*&---------------------------------------------------------------------*
*&      Module  GET_LOV_APPRV_BY  INPUT
*&---------------------------------------------------------------------*
* Serach help on Approved by Competent Authority
*----------------------------------------------------------------------*
MODULE get_lov_apprv_by INPUT.
  PERFORM get_lov_approve_by.
ENDMODULE.                 " GET_LOV_APPRV_BY  INPUT

*--- INCLUDE: MZMMEMD_ARCHO01_ARCH ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMEMDO01                                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Set Status of screen 100.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  PERFORM   append_isttab_100.
  SET PF-STATUS 'S100' EXCLUDING ist_tab.
  SET TITLEBAR 'T100_01'.
  IF sy-ucomm = 'BACK'.
    PERFORM release_lock.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*       Set Screen element Attributes of Screen 100.
*----------------------------------------------------------------------*
MODULE set_screen_100 OUTPUT.

*&--> disable document field.
  LOOP AT SCREEN.
    IF screen-group1 = '001'.
      screen-active  = '0' .
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  IF ok_code = 'CHAN' OR ok_code = 'DISP' OR ok_code   = 'DELE' OR
     ok_code = 'REST' OR ok_code = 'BGLC' OR ok_code   = 'AMEND'.
    LOOP AT SCREEN.
      IF screen-group1    = '001'.
        screen-invisible = '0'  .
        screen-active    = '1'    .
        screen-input     = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
ENDMODULE.                 " set_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0105  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen element in Screen - 0105.
*----------------------------------------------------------------------*
MODULE set_screen_0105 OUTPUT.
*&--> Make  Table Control invisible in screen 105 IF Header data not *&
* entered.

  IF g_okhdr = 'X' OR g_tfxm = 'X'.
    tc_105-invisible = 0.
    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS' OR screen-name = 'INSERT' OR
         screen-name = 'DELET' OR screen-name = 'COPY' OR
         screen-name = 'PASTE'.
        IF screen-group1 = 'I01'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    CLEAR tc_105-invisible .

    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS'.
        IF screen-group1 = 'I01'.
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*&----------------------------------------------------------&*
* SRM Changes +002
*&----------------------------------------------------------&*

  IF sy-ucomm = 'TFEXM' AND g_okhdr NE 'X' AND g_tfxm NE 'X'.
    CLEAR tc_105-invisible .
    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS'.
        IF screen-group1 = 'I01'.
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*&-- End of Change
*&----------------------------------------------------------&*


*&--< Make Input Field disable When Action is Display or
*   Delete or Reset
*&-->
  IF prev_okcode = 'DISP' OR g_reset = 1 OR
    prev_okcode  = 'DELE' OR ok_code = 'DELT'
    OR prev_okcode = 'REST'.
    CLEAR tc_105-invisible .

    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02' OR tc_col-screen-group2 = 'C02'.
        tc_col-screen-input = 0.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
  IF  g_reset = '1'.                                        "27.01.04
    CLEAR tc_105-invisible .
    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02'.
        tc_col-screen-input = 0.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.

    LOOP AT SCREEN.
      IF screen-name = 'ZMM_EMDHDR-CURRENCY'.
        CLEAR screen-input .
        CLEAR screen-active .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&-->  Disable input fields if trans is initial.

  LOOP AT SCREEN.
    IF  zmm_emdhdr-trans IS INITIAL .
      IF screen-group2 = 'G02'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE .
      IF screen-group2 = 'G02'.
        screen-input  = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
*&--<

*&--<  Make  Insert and Delete button invisible if prev_okcode = 'DEL'.
*  OR Reset
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'
    OR prev_okcode = 'REST'  .
    LOOP AT SCREEN.
      IF screen-group2 = 'I02'.
        screen-invisible = 1.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.

*&--<  Make  Insert and Delete button Enable  if prev_okcode = 'CHAN'.
  IF prev_okcode = 'CHAN' AND  g_reset = 0.
    LOOP AT SCREEN.
      IF screen-group2 = 'I02'.
        screen-active = 1 .
        screen-input  = 1 .
        screen-invisible = 0.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--< Enable Field Created by&Created on active when disp,change,delete.
  IF prev_okcode = 'CHAN' OR
     prev_okcode = 'DISP' OR
     prev_okcode = 'DELE' .
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF  prev_okcode = 'CREA'.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&--> Enable filed zmm_emdhdr-place only when trans = 'TFS'.
  IF zmm_emdhdr-trans = 'TFS' .
    LOOP AT SCREEN .
      IF screen-name = 'PLACE' OR screen-name = 'ZMM_EMDHDR-PLACE' .
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN .
      IF screen-name = 'PLACE' OR screen-name = 'ZMM_EMDHDR-PLACE' .
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

*&----------------------------------------------------------------*&
* SRM Changes +002 1.11.2004
*This is applicable only to Tender Fee. Few vendors are exempted from
*Tender Fee. However, these vendors also should obtain a transaction
*number from tender fee application.

    CLEAR g_tfxm .
    LOOP AT SCREEN.
      IF screen-group4   = 'GTF'.
*         screen-invisible = 0.
        screen-active   = 0 .
        screen-input   = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*&-------------------------------------------------------------*&
  ENDIF.
*&--<
*+007 : Start
  IF zmm_emdhdr-trans = 'SDT' AND
     ( prev_okcode = 'CREA' OR prev_okcode = 'CHAN' ).

    LOOP AT SCREEN.
      IF screen-group1 = 'SDT'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    IF zmm_emdhdr-apprv_chk = 'Y' AND prev_okcode = 'CHAN'.

      LOOP AT SCREEN.
        IF screen-group2 = 'SDT'.
          screen-input    = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ENDIF.

    IF prev_okcode = 'CREA'     OR
       ( prev_okcode = 'CHAN' AND
         ( zmm_emdhdr-status = 'N' OR zmm_emdhdr-status = '0' ) ).

      IF zmm_emdhdr-apprv_chk = 'N' OR
         zmm_emdhdr-apprv_chk IS INITIAL.

        LOOP AT SCREEN.
          IF screen-group3 = 'SDT'.
            screen-input     = '0'.
            screen-invisible = '1'.
            MODIFY SCREEN.
            CLEAR g_pmc.
          ENDIF.
        ENDLOOP.

      ELSEIF zmm_emdhdr-apprv_chk = 'Y'.

        LOOP AT SCREEN.
          IF screen-group3 = 'SDT'.
            screen-input     = '1'.
            screen-invisible = '0'.
            MODIFY SCREEN.
            g_pmc = 'X'.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ELSE.

      LOOP AT SCREEN.
        IF screen-group4 = 'SDT'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ENDIF.
*    ELSEIF zmm_emdhdr-apprv_chk = 'Y'.
*
*      LOOP AT SCREEN.
*        IF screen-group2 = 'SDT'.
*          screen-input    = '1'.
*          screen-required = '1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.
*
*    ENDIF.

  ELSEIF zmm_emdhdr-trans = 'SDT' AND
         prev_okcode = 'DISP'.

    LOOP AT SCREEN.
      IF screen-group1 = 'SDT'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSE.

    LOOP AT SCREEN.
      IF screen-group1 = 'SDT'.
        screen-input     = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.
*+007 : End

ENDMODULE.                 " set_screen_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*     PF Status of Screen 0105
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  PERFORM modify_isttab.
  SET PF-STATUS 'S105' EXCLUDING ist_tab .
  IF prev_okcode = 'CREA'.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T105_01' WITH g_action  text-001  .
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T105_01' WITH  g_action text-002   .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T105_01' WITH  g_action text-003  .
    ENDIF.
  ELSE.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T105' WITH g_action  text-001 text-010 g_idocno.
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T105' WITH  g_action text-002 text-010 g_idocno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T105' WITH  g_action text-003 text-010 g_idocno.
    ENDIF.
  ENDIF.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc105_move_data  OUTPUT
*&---------------------------------------------------------------------*
*      Move Data from Work area to Table Control
*----------------------------------------------------------------------*
MODULE tc105_move_data OUTPUT.
  wa_emddtl-currency = zmm_emdhdr-currency .
  PERFORM get_item_status USING wa_emddtl-status .
  MOVE g_status TO  wa_emddtl-stat_desc.
  MOVE-CORRESPONDING wa_emddtl TO wa_tc105 .
  CLEAR g_status.
  LOOP AT SCREEN.
*&------> If the document status is N then only activate entire row
    IF prev_okcode = 'CHAN'  .
      IF  wa_emddtl-status NE 'N' AND  wa_emddtl-status NE space.
        IF screen-name NE 'WA_TC105-SEL' .
          screen-input = 0.
        ELSE.
          screen-input = 1.
        ENDIF.
      ELSE.
        screen-input = 1.
      ENDIF.
      IF    screen-name = 'WA_TC105-SEL' AND
          wa_tc105-status NE 'N'.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
*&------<
    IF screen-name = 'WA_TC105-STATUS'.
      screen-invisible = 1.
      MODIFY SCREEN.
    ELSE.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*-------- Disable field BANK,BRANCH,ADDR1,ADDR2 when instrument is IV.
  LOOP AT SCREEN.
    IF wa_tc105-inst_type = 'IV'.
      IF screen-group1 = 'IV1'  .
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Start of addition by Saravanan M on 08/04/2009
  IF l_result = '1' AND prev_okcode = 'ECREA'.
    zmm_emdhdr-trans = 'TFS'.
  ELSEIF l_result = '3' AND prev_okcode = 'ECREA'.
    zmm_emdhdr-trans = 'EMD'.
  ENDIF.
* End of addition by Saravanan M on 08/04/2009
ENDMODULE.                 " tc105_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_HEADER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*      Get Header Data
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.
  DESCRIBE TABLE ist_emddtl LINES tc_105-lines.

*---SRM CHANGES   +002
*--- Assign transaction as 'TFS' incase of E-Tender Receipt creation
*  if prev_okcode = 'ECREA'.
*    zmm_emdhdr-trans = 'TFS'.
*    loop at screen.
*      if screen-group2 = 'G02'.
*        screen-input  = 1.
*        modify screen.
*      endif.
*    endloop.
*  endif.
*----END OF CHANGES

  IF zmm_emdhdr-trans IS INITIAL.
    g_rfqpo      = 'RFQ/PO No'.
  ENDIF.
  IF zmm_emdhdr-trans = 'SDT'.
    g_rfqpo      = 'PO No.'.
  ELSE.
    g_rfqpo      = 'RFQ No'.
  ENDIF.
*---- get location name.
  SELECT SINGLE locds FROM zmm_location INTO g_locname
              WHERE loccd  = wa_emdhdr-place .

*&--> Get Header Data from subroutine get_data in PAI screen 100.
*&--< For Display,Change,Delete
  IF prev_okcode  = 'DISP' OR prev_okcode = 'CHAN' OR
     prev_okcode  = 'DELE' OR prev_okcode = 'REST'.
    MOVE zmm_emdhdr-currency TO wa_emdhdr-currency.
    MOVE zmm_emdhdr-place   TO  wa_emdhdr-place   .
    wa_emdhdr-trans = zmm_emdhdr-trans.
    wa_emdhdr-ebeln = zmm_emdhdr-ebeln .
*---SRM Changes
    IF g_ttype = 'R3' OR g_ttype IS INITIAL.
      MOVE-CORRESPONDING wa_emdhdr TO zmm_emdhdr    .
    ENDIF.
    IF g_ttype = 'SRM'.
      PERFORM get_vendor_name .
    ENDIF.
*-------End of SRM Changes -----------------------------------*
    PERFORM get_vendorno_tenderno.
*&----> Get Status descr of Header.

* Begin of <RD1K963111>
    DATA lv_status TYPE zmm_emdref-status.
    DATA lv_index TYPE i.
    DATA g_hstatus_text TYPE text.
    DATA lv_lines TYPE i.
    DATA lv_status1 TYPE zmm_emddtl-status.
    DATA lv_status2 TYPE zmm_emddtl-status.
    DATA ref_status  TYPE text.
    DATA g_hstatus_doc TYPE zdoc_no.
    DATA ref_value TYPE zdoc_no.
    DATA g_hdate(10) TYPE c.
    DATA ref_date(10) TYPE c.

    CLEAR ref_value.
    CLEAR g_hstatus_doc.
    CLEAR ref_status.
    CLEAR lv_status2.
    CLEAR lv_status1.
    CLEAR lv_lines.
    CLEAR g_hstatus_text.
    CLEAR lv_index.
    CLEAR lv_status.
    CLEAR g_hdate.
    CLEAR ref_date.

    SELECT  * FROM zmm_emdref INTO TABLE lt_emdref
                 WHERE refdoc = zmm_emdhdr-docno ORDER BY PRIMARY KEY.

    DESCRIBE TABLE lt_emdref LINES lv_index.
    IF lv_index = 1.
      CLEAR wa_emdref.
      READ TABLE lt_emdref INTO wa_emdref INDEX 1.
      IF wa_emdref-rfcstat = 'R'.
        g_hstatus_text = 'Refund'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'F'.
        g_hstatus_text = 'Forfeiture'.
        wa_emdhdr-status = wa_emdref-status.
        g_hstatus_doc = wa_emdref-docno.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'C'.
        g_hstatus_text = 'SD Conversion'.
        wa_emdhdr-status = wa_emdref-status.
        g_hstatus_doc = wa_emdref-docno.
        g_hdate = wa_emdref-rfccron.
      ENDIF.

    ELSEIF lv_index > 1.
      CLEAR wa_emdref.
      READ TABLE lt_emdref INTO wa_emdref INDEX 1.
*      loop at lt_emdref into wa_emdref.
      IF wa_emdref-rfcstat = 'R'.
        g_hstatus_text = 'Refund'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'F'.
        g_hstatus_text = 'Forfeiture'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'C'.
        g_hstatus_text = 'SD Conversion'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ENDIF.
*      endloop.
      CLEAR wa_emdref.
      READ TABLE lt_emdref INTO wa_emdref INDEX 2.
      IF wa_emdref-rfcstat = 'R'.
        ref_status = 'Refund'.
        ref_value = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        ref_date = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'F'.
        ref_status = 'Forfeiture'.
        ref_value = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        ref_date = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'C'.
        ref_status = 'SD Conversion'.
        ref_value = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        ref_date = wa_emdref-rfccron.
      ENDIF.

    ELSEIF lv_index = 0.
      SELECT * FROM zmm_emddtl INTO TABLE lt_emddtl WHERE docno = zmm_emdhdr-docno ORDER BY PRIMARY KEY.
      DESCRIBE TABLE lt_emddtl LINES lv_lines.
      IF lv_lines > 1.
        READ TABLE lt_emddtl INTO wa_emddtl1 INDEX 1.
        lv_status1 = wa_emddtl1-status.
        CLEAR wa_emddtl1.
        LOOP AT lt_emddtl INTO wa_emddtl1 WHERE status = lv_status1.
          lv_status2 = wa_emddtl1-status.
          IF lv_status1 = lv_status2.
            CLEAR lv_status2.
            CONTINUE.
          ELSEIF lv_status1 <> lv_status2.
            CLEAR lv_status1.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_status2 IS NOT INITIAL.
          IF wa_emddtl-status = 'R'.
            ref_status = 'Refund'.
            wa_emdhdr-status = wa_emddtl1-status.
          ELSEIF wa_emddtl-status = 'F'.
            ref_status = 'Forfeiture'.
            wa_emdhdr-status = wa_emddtl1-status.
          ELSEIF wa_emddtl-status = 'C'.
            ref_status = 'SD Conversion'.
            wa_emdhdr-status = wa_emddtl1-status.
          ENDIF.
        ELSEIF lv_status2 IS INITIAL.
          CLEAR ref_status.
          CASE wa_emdhdr-status..
            WHEN 'N'.
              ref_status        = text-040.  "Receipt
            WHEN 'B'.
              ref_status        = text-036.  "Send for Bank Confirmation' .
            WHEN 'A'.
              ref_status        = text-037 . "'Acceped By Bank'.
            WHEN  'Y'.
              ref_status        = text-038 . " 'Denied  By Bank'.
            WHEN  'V'.
              ref_status       =  text-039 . "'Invoked'.
            WHEN 'S'.
              ref_status       =  text-043 .  "Submitted to FI
            WHEN 'I'.
              ref_status       =  text-054 .  "Parked to FI
            WHEN 'D'.
              ref_status       =  text-047 .   "Deleted
            WHEN 'R'.
              ref_status      =  text-015.    "Refund
            WHEN 'F'.
              ref_status       =  text-016.    "Forfeit
            WHEN 'C'.
              ref_status       =  text-017.    "Convert
            WHEN 'P'.
              ref_status      =  text-061.    "Accepted by FI
            WHEN 'E'.
              ref_status      =  text-058.    "Return BG/LC Document.
            WHEN 'U'.
              ref_status      = text-049. " Fully parked
            WHEN 'K'.
              ref_status     = text-055.
          ENDCASE.
        ENDIF.
      ELSEIF lv_lines = 1.
        CLEAR wa_emddtl1.
        READ TABLE lt_emddtl INTO wa_emddtl1 INDEX 1.
*        ref_status = wa_emddtl-status.
        CLEAR ref_status.
        CASE wa_emddtl1-status.
          WHEN 'N'.
            ref_status        = text-040.  "Receipt
          WHEN 'B'.
            ref_status        = text-036.  "Send for Bank Confirmation' .
          WHEN 'A'.
            ref_status        = text-037 . "'Acceped By Bank'.
          WHEN  'Y'.
            ref_status        = text-038 . " 'Denied  By Bank'.
          WHEN  'V'.
            ref_status       =  text-039 . "'Invoked'.
          WHEN 'S'.
            ref_status       =  text-043 .  "Submitted to FI
          WHEN 'I'.
            ref_status       =  text-054 .  "Parked to FI
            ref_value = wa_emddtl1-fi_parkno.
            ref_date  = wa_emddtl1-fi_parkdt.
          WHEN 'D'.
            ref_status       =  text-047 .   "Deleted
          WHEN 'R'.
            ref_status      =  text-015.    "Refund
          WHEN 'F'.
            ref_status       =  text-016.    "Forfeit
          WHEN 'C'.
            ref_status       =  text-017.    "Convert
          WHEN 'P'.
            ref_status      =  text-061.    "Accepted by FI
          WHEN 'E'.
            ref_status      =  text-058.    "Return BG/LC Document.
          WHEN 'U'.
            ref_status      = text-049. " Fully parked
          WHEN 'K'.
            ref_status     = text-055.
        ENDCASE.
      ENDIF.
    ENDIF.

    IF ref_date IS NOT INITIAL.
      CONCATENATE ref_date+6(2) '/' ref_date+4(2) '/' ref_date+0(4) INTO ref_date.
    ENDIF.
    IF g_hdate IS NOT INITIAL.
      CONCATENATE g_hdate+6(2) '/' g_hdate+4(2) '/' g_hdate+0(4) INTO g_hdate.
    ENDIF.
*g_hdate
* End of <RD1K963111>

    PERFORM get_head_status USING wa_emdhdr-status.
*&-----<
    LOOP AT SCREEN.
      IF screen-group2 = 'G02' OR screen-group2 = 'DT2'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02'.
        tc_col-screen-input = 0.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&-->  Make Item Detail Frame Enable when Display/Change or Delete
  IF prev_okcode  = 'DISP' OR prev_okcode = 'CHAN' OR
      prev_okcode  = 'DELE'.
    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS'.
        IF screen-group1 = 'I01'.
          screen-active  = 1.
          screen-invisible   = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&--> Make Fields CURRENCY AND PLACE enable AT Header Level IF
*& WHEN 'CHANGE' MODE .
  IF prev_okcode = 'CHAN' AND g_reset NE 1.
    CLEAR tc_105-invisible .
    LOOP AT SCREEN.
      IF screen-group3 = 'G03'.
        screen-input   = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02'.
        tc_col-screen-input = 1.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*----------------------------------------------------------------*
*  IF Status at header level is Full Refund/Forfeit/EMD-SD Conv ..
* the don't allow for change in Change Mode.
  IF prev_okcode = 'CHAN' .
    IF wa_emdhdr-status = 'K' OR
       wa_emdhdr-status = 'Q' OR
       wa_emdhdr-status = space.    "Document Completed.
      LOOP AT SCREEN.
        IF screen-group3 = 'G03'.
          screen-input   = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

*  Changes by SAB_RAHUL on 15.04.2006
  IF prev_okcode = 'CHAN' .
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_EMDHDR-TRANS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*  End Changes by SAB_RAHUL RD1K935395

* Start of Addition by SAB_SARVANAN on 18/06/2009
  DATA g_header_text TYPE string.
  CLEAR g_header_text.
  CASE wa_emdhdr-status.
    WHEN 'A'.
      g_header_text = 'Accepted by Bank'.
    WHEN 'B'.
      g_header_text = 'Send to Bank For Confirmation (BG/LC)'.
    WHEN 'C'.
      g_header_text = 'EMD to SD Conversion'.
    WHEN 'D'.
      g_header_text = 'Delete'.
    WHEN 'E'.
      g_header_text = 'Return (BG/LC)'.
    WHEN 'F'.
      g_header_text = 'Forfeiture'.
    WHEN 'G'.
      g_header_text = 'Request for BG/LC Return'.
    WHEN 'H'.
      g_header_text = 'Request for BG/LC Invoke'.
    WHEN 'I'.
      g_header_text = 'Document parked in FI'.
    WHEN 'J'.
      g_header_text = 'Document completed'.
    WHEN 'K'.
      g_header_text = 'Partially  Parked'.
    WHEN 'L'.
      g_header_text = 'Partial Refund'.
    WHEN 'M'.
      g_header_text = 'Partial Forfeit'.
    WHEN 'N'.
      g_header_text = 'Receipt/Deposit'.
    WHEN 'O'.
      g_header_text = 'Full Refund'.
    WHEN 'P'.
      g_header_text = 'Accepted by FI BG/LC'.
    WHEN 'Q'.
      g_header_text = 'Document in process'.
    WHEN 'R'.
      g_header_text = 'Refund'.
    WHEN 'S'.
      g_header_text = 'Submitted to FI (BG/LC)'.
    WHEN 'T'.
      g_header_text = 'Fully Forfeit'.
    WHEN 'U'.
      g_header_text = 'Fully Parked'.
    WHEN 'V'.
      g_header_text = 'Invoke'.
    WHEN 'W'.
      g_header_text = 'Request for BG/LC  Return & Invoke'.
    WHEN 'X'.
      g_header_text = 'Fully Converted to SD'.
    WHEN 'Y'.
      g_header_text = 'Deny by Bank'.
    WHEN 'Z'.
      g_header_text = 'Partial Return / Invoke (BG/LC)'.
  ENDCASE.
* End of Addition by SAB_SARVANAN on 18/06/2009
ENDMODULE.                 " GET_HEADER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0106  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  PERFORM   append_isttab_110.
  SET PF-STATUS 'S110' EXCLUDING ist_tab.
  SET TITLEBAR 'T110_01' WITH text-019 zmm_emdhdr-docno.
  IF g_doccat =  text-015.
    SET TITLEBAR 'T110_01' WITH text-015 zmm_emdhdr-docno.
  ELSEIF g_doccat = text-016.
    SET TITLEBAR 'T110_01' WITH text-016 zmm_emdhdr-docno.
  ELSEIF g_doccat =  text-018.
    SET TITLEBAR 'T110_01' WITH text-017 zmm_emdhdr-docno.
  ENDIF.
ENDMODULE.                 " status_0106  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0110  OUTPUT
*&---------------------------------------------------------------------*
*       Set Screen - 0110.
*----------------------------------------------------------------------*
MODULE set_screen_0110 OUTPUT.
*&-----> iF INPUT is valid  Document the set amount field Active
  IF zmm_emdhdr-docno IS INITIAL AND g_doccat IS INITIAL   .
    LOOP AT SCREEN.
      IF screen-group1 = 'G01' OR  screen-group2 = 'G02' OR
         screen-group1 = 'D01'.
        screen-invisible   = 1.
        screen-active     = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01' OR  screen-group2 = 'G02' OR
         screen-group1 = 'D01'.
        screen-invisible   = 0.
        screen-active     = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF ok_code NE 'CRET'.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-invisible = 1.
        screen-active   = 0 .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-invisible = 0.
        screen-active   = 1 .
        screen-input    = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF g_ref =  1.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01'.
        screen-invisible = 1.
        screen-active   = 0 .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&-------<
  IF g_ref = 0 AND g_doccat = text-018.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-invisible = 0.
        screen-active   = 1 .
        screen-input    = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-invisible = 1.
        screen-active   = 0 .
        screen-input   = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&-------<

* Start of Addition by SAB_SARVANAN on 18/06/2009
  IF zmm_emdhdr-trans = 'TFS' AND sy-dynnr = '0110' AND zmm_emdref-rscode = 120.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_EMDREF-AMOUNT'.
        screen-active   = 1.
        screen-input   = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
* End of addition by SAB_SARVANAN on 18/06/2009
ENDMODULE.                 " set_screen_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  lov_values  OUTPUT
*&---------------------------------------------------------------------*
*       List of Values in List Box
*----------------------------------------------------------------------*
MODULE lov_values OUTPUT.
  REFRESH : g_task_list.
  g_task_cd = 'G_DOCCAT'.
  g_task_value = text-015.
  APPEND g_task_value TO g_task_list.
  CLEAR g_task_value.
  g_task_value = text-016 .
  APPEND g_task_value TO g_task_list.
  CLEAR g_task_value.
  g_task_value = text-018 .
  APPEND g_task_value TO g_task_list.
  CLEAR g_task_value.
  PERFORM set_values.
  CLEAR g_task_value.
ENDMODULE.                 " lov_values  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0115  OUTPUT
*&---------------------------------------------------------------------*
*       Status of screen 0115.
*----------------------------------------------------------------------*
MODULE status_0115 OUTPUT.
  DATA: l_stext(30).
  PERFORM   append_isttab_115.
  IF zmm_emdref-rfcstat = 'N'.
    l_stext = text-040.
  ELSEIF zmm_emdref-rfcstat = 'R'.
    l_stext = text-015.
  ELSEIF zmm_emdref-rfcstat = 'F'.
    l_stext = text-016.
  ELSEIF zmm_emdref-rfcstat = 'C'.
    l_stext = text-017.
  ENDIF.
  g_docno = zmm_emdref-docno .
  SET PF-STATUS 'S115' EXCLUDING ist_tab.
  SET TITLEBAR 'T115_01' WITH text-020.
  IF  prev_okcode = 'CHNG'.
    SET TITLEBAR 'T110_01' WITH text-020 g_docno l_stext.
  ELSEIF prev_okcode = 'DISP'.
    SET TITLEBAR 'T110_01' WITH text-021  g_docno l_stext.
  ELSEIF prev_okcode  = 'DELE'.
    SET TITLEBAR 'T110_01' WITH text-022  g_docno l_stext.
  ELSEIF prev_okcode = 'UNDEL'.
    SET TITLEBAR 'T110_01' WITH text-053 g_docno l_stext .
  ENDIF.
ENDMODULE.                 " status_0115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0115  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen Attributes depending upon action
*----------------------------------------------------------------------*
MODULE set_screen_0115 OUTPUT.
*&---> Make All fields in Display mode When 'Disp' option selected.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE' OR
     prev_okcode = 'UNDEL  '.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-input     = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF g_rfc_chk = 1.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-active    = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF g_rfc_chk = 0.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-active    = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&----<
  PERFORM get_ref_doc_stat USING g_docno .
* Begin of <RD1K963111> on 05/05/2009 - Solman Call No : 30000998
  IF zmm_emdref-rscode IS NOT INITIAL.
    DATA lv_text TYPE zrcdesc.
    SELECT * FROM ZMM_EMDRSCODE UP TO 1 ROWS

 WHERE RSCODE = ZMM_EMDREF-RSCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    lv_text = zmm_emdrscode-descr.
  ENDIF.
* End of <RD1K963111> on 05/05/2009 - Solman Call No : 30000998
ENDMODULE.                 " set_screen_0115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_data OUTPUT.
  IF sy-dynnr = '0105'.
    zmm_emdhdr-cron = g_crea_on .
    zmm_emdhdr-crby = g_crea_by .
    zmm_emdref-rfcchby = g_chan_by .
    zmm_emdref-rfcchon = g_chan_on .
    g_status = g_stat .
  ENDIF.
ENDMODULE.                 " DISPLAY_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0125  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0125 OUTPUT.
  SET PF-STATUS 'S0125'.
ENDMODULE.                 " STATUS_0125  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc115_move_data  OUTPUT
*&---------------------------------------------------------------------*
*      Move Data
*----------------------------------------------------------------------*
MODULE tc120_move_data OUTPUT.
  PERFORM get_item_status USING wa_emdref_02-status .
  MOVE g_status TO  wa_emdref_02-stat_desc.
  g_lines = g_lines + 1.
  IF NOT   wa_emdref_02-refdoc IS INITIAL.
    wa_emdref_02-itemno = g_lines   .
  ENDIF.
  IF  wa_emdref_02-docno IS INITIAL.
    CLEAR  wa_emdref_02.
  ENDIF.
  MOVE-CORRESPONDING wa_emdref_02 TO wa_emdref_01.
  CLEAR g_status.
ENDMODULE.                 " tc115_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
*       PF STATUS OF  SCREEN 120.
*----------------------------------------------------------------------*
MODULE status_0120 OUTPUT.
  MOVE 'SAVE' TO wa_tab-fcode.
  APPEND wa_tab   TO ist_tab .
  SET PF-STATUS 'S120'  EXCLUDING ist_tab.
  SET TITLEBAR 'T120'.
ENDMODULE.                 " STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_0115_TS  OUTPUT
*&---------------------------------------------------------------------*
*      DISABLE TAB STRIP CONTROL INITIALLY
*----------------------------------------------------------------------*
MODULE set_screen_0115_ts OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'SUB_RFC'.
      screen-invisible  = 1.
      screen-active = 0.
      ts_115-invisible = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " SET_SCREEN_0115_TS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_135  OUTPUT
*&---------------------------------------------------------------------*
*      Status of Screen
*----------------------------------------------------------------------*
MODULE status_135 OUTPUT.
  PERFORM  append_isttab_135.
  SET PF-STATUS 'S135' EXCLUDING ist_tab.
  SET TITLEBAR  'T135' WITH g_idocno.
ENDMODULE.                 " status_135  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_135  OUTPUT
*&---------------------------------------------------------------------*
*       Set Screen Attributes OF screen 135
*----------------------------------------------------------------------*
MODULE set_screen_135 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group2 = 'G02' OR screen-group2 = 'DT2'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " set_screen_135  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_HEADER_INFO  OUTPUT
*&---------------------------------------------------------------------*
*      Get Header Information on screen 0135.
*----------------------------------------------------------------------*
MODULE get_header_info OUTPUT.
  PERFORM get_vendorno_tenderno.
ENDMODULE.                 " GET_HEADER_INFO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc135_move_data  OUTPUT
*&---------------------------------------------------------------------*
*      Move data into Table control
*----------------------------------------------------------------------*
MODULE tc135_move_data OUTPUT.
  wa_emddtl-currency = zmm_emdhdr-currency .
*&------> If Status is B disable Sel Check box in disable mode.
*-------> Already send for Bank Confirmation
  LOOP AT SCREEN.
    IF screen-name = 'WA_TC135-CHECK'.
      IF wa_emddtl-status    =  'B' OR
         wa_emddtl-status    =  'A' OR
         wa_emddtl-status    =  'V' OR
         wa_emddtl-status    =  'Y' OR
         wa_emddtl-status    =  'S' OR
         wa_emddtl-status    =  'E' OR
         wa_emddtl-status    =  'P' OR
         wa_emddtl-inst_type = 'LC'.
        IF wa_emddtl-check NE 'X' OR wa_emddtl-check = space  .
          screen-input = '0'.
        ENDIF.
      ELSE.
        screen-input = '1' .
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'WA_TC135-STATUS'.
      screen-invisible  = 1.
      MODIFY SCREEN.
    ENDIF.
*+004
*    IF screen-name = 'WA_TC135-CHECK'.
*      IF wa_emddtl-status    =  'B' .
*        screen-input = '0'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDIF.
*+004

  ENDLOOP.
*&------<
  MOVE-CORRESPONDING wa_emddtl TO wa_tc135 .
ENDMODULE.                 " tc135_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_140  OUTPUT
*&---------------------------------------------------------------------*
*       GUI status of Dialog screen 140
*----------------------------------------------------------------------*
MODULE status_140 OUTPUT.
  SET PF-STATUS 'S140'.
  SET TITLEBAR  'T140'.
ENDMODULE.                 " status_140  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0145  OUTPUT
*&---------------------------------------------------------------------*
*       Status of screen 145
*----------------------------------------------------------------------*
MODULE status_0145 OUTPUT.
  SET PF-STATUS 'S145'.
  SET TITLEBAR  'T145' WITH zmm_emdhdr-docno.
ENDMODULE.                 " status_0145  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc105_move_data_S145  OUTPUT
*&---------------------------------------------------------------------*
*      move Internal table data into table control
*----------------------------------------------------------------------*
MODULE tc145_move_data_s145 OUTPUT.
  wa_emddtl-currency = zmm_emdhdr-currency .
  MOVE-CORRESPONDING wa_emddtl TO wa_tc145 .
*&-----> Make field STATUS Invisible
  LOOP AT SCREEN.
    IF screen-name  = 'WA_TC145-STATUS' .
      screen-invisible = 1.
    ELSE.
      screen-invisible = 0.
    ENDIF.
    IF NOT ( wa_tc145-status = 'P' OR wa_tc145-status = 'A' )
       AND  screen-name  NE 'WA_TC145-STATUS' .
      screen-input = 0.
    ELSE.
      screen-input = 1.
    ENDIF.
    MODIFY SCREEN.
    IF screen-name = 'WA_TC145-SEL'.
      screen-input = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " tc105_move_data_S145  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BALANCE_AMT  OUTPUT
*&---------------------------------------------------------------------*
*      Check Balance Amount.
*----------------------------------------------------------------------*
MODULE check_balance_amt OUTPUT.
  PERFORM check_rfc_amount  .
ENDMODULE.                 " CHECK_BALANCE_AMT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0150 OUTPUT.
  SET PF-STATUS 'S150' EXCLUDING ist_tab.
  SET TITLEBAR 'T150'.
ENDMODULE.                 " STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_parameter  OUTPUT
*&---------------------------------------------------------------------*
*      Get parameter for TFS/EMD/SD Documents.
*----------------------------------------------------------------------*
MODULE get_parameter OUTPUT.
  IF zmm_emdhdr-docno IS INITIAL.
    GET PARAMETER ID 'ZMMTESDOC' FIELD  zmm_emdhdr-docno.
  ENDIF.
  UNPACK zmm_emdhdr-docno TO zmm_emdhdr-docno.
ENDMODULE.                 " get_parameter  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0155  OUTPUT
*&---------------------------------------------------------------------*
*       PF Status of Screen 155
*----------------------------------------------------------------------*
MODULE status_0155 OUTPUT.
  PERFORM modify_isttab.
  SET PF-STATUS 'S155' EXCLUDING ist_tab.
* set titlebar 'T155'.

  IF prev_okcode = 'CREA'.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T155_01' WITH g_action  text-001  .
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T155_01' WITH  g_action text-002   .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T155_01' WITH  g_action text-003  .
    ENDIF.
  ELSE.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T155' WITH g_action  text-068 text-010 g_idocno.
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T155' WITH  g_action text-002 text-010 g_idocno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T155' WITH  g_action text-003 text-010 g_idocno.
    ENDIF.
  ENDIF.
ENDMODULE.                 " status_0155  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_SRM  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen Attributes for SRM Screen 0155.
*----------------------------------------------------------------------*
MODULE set_screen_srm OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 =  'SR1' .
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " SET_SCREEN_SRM  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0160  OUTPUT
*&---------------------------------------------------------------------*
*      PF Status of Screen 0160
*----------------------------------------------------------------------*
MODULE status_0160 OUTPUT.
  PERFORM append_itab_s160.
  SET PF-STATUS 'S160' EXCLUDING ist_tab .
  IF prev_okcode = 'ECREA'.
    SET TITLEBAR 'T160_A' WITH text-073.
  ELSEIF prev_okcode = 'CHAN'.
    SET TITLEBAR 'T160' WITH text-020 text-074 g_idocno.
  ELSEIF prev_okcode = 'DISP'.
    SET TITLEBAR 'T160' WITH text-021 text-074 g_idocno.
  ELSEIF prev_okcode = 'DELE'.
    SET TITLEBAR 'T160' WITH text-022 text-074 g_idocno.
  ELSEIF prev_okcode = 'REST'.
    SET TITLEBAR 'T160' WITH text-026 text-074 g_idocno.
  ENDIF.
ENDMODULE.                 " status_0160  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0160  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen Attributes
*----------------------------------------------------------------------*
MODULE set_screen_0160 OUTPUT.
  zmm_emdhdr-trans = 'TFS'.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01'.
        screen-input = 1.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " set_screen_0160  OUTPUT

*--- INCLUDE: MZMMEMD_ARCHTOP_ARCH ---*
*&---------------------------------------------------------------------*
*& Include MZMMEMDTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
PROGRAM sapmzmmemd  .
TABLES: zmm_emdhdr    ,
        zmm_emddtl    ,
        zmm_emdref    ,
        zmm_emdrscode ,
        cdpos ,
        cdhdr ,
        t001  , "Company Codes
        lfb1  .
CONTROLS : tc_105  TYPE TABLEVIEW USING SCREEN '0105',
           tc_120  TYPE TABLEVIEW USING SCREEN '0120',
           tc_135  TYPE TABLEVIEW USING SCREEN '0135',
           tc_145  TYPE TABLEVIEW USING SCREEN '0145',
           tc_155  TYPE TABLEVIEW USING SCREEN '0155'.
CONTROLS : ts_115  TYPE TABSTRIP .
DATA: ok_code      LIKE sy-ucomm ,
      prev_okcode  LIKE sy-ucomm ,
      set_okcode   LIKE sy-ucomm ,
      tc_col       LIKE LINE OF tc_105-cols  .
*&-------------------------------------------------------------------
*  Type Pool
*&-------------------------------------------------------------------
TYPE-POOLS vrm.
TYPES: BEGIN OF tab_type,
        fcode LIKE rsmpe-func,
      END OF tab_type.
*&-------------------------------------------------------------------

TYPES : BEGIN OF ty_ekko ,
        ebeln     LIKE ekko-ebeln ,
        ekgrp     LIKE ekko-ekgrp ,
        submi     LIKE ekko-submi ,
        lifnr     LIKE ekko-lifnr ,
       END OF    ty_ekko.
TYPES: BEGIN OF  ty_tabtype,
          fcode LIKE rsmpe-func,
       END OF    ty_tabtype.

*types: begin of ty_emddtl,
*       trans     type zmm_emdhdr-trans    ,
*       status    type zmm_emddtl-status   ,
*       ri_stat   type zmm_emddtl-ri_stat  ,                 "+003
*       ri_reqno  type zmm_emddtl-ri_reqno ,                 "+003
*       stat_desc(30)                      ,
*       docno     type zmm_emddtl-docno    ,
*       ebeln     type zmm_emddtl-ebeln    ,
*       item_no   type zmm_emddtl-item_no  ,
*       inst_type type zmm_emddtl-inst_type,
*       instno    type zmm_emddtl-instno   ,
*       instdt    type zmm_emddtl-instdt   ,
*       inst_vdt  type zmm_emddtl-inst_vdt ,
*       bank      type zmm_emddtl-bank     ,
*       branch    type zmm_emddtl-branch   ,
*       amount    type zmm_emddtl-amount   ,
*       currency  type zmm_emddtl-currency ,
*       addr1     type zmm_emddtl-addr1    ,
*       addr2     type zmm_emddtl-addr2    ,
*       rscode    type zmm_emddtl-rscode   ,
*       remark    type zmm_emddtl-remark   ,
*       sel                                ,
*       check                              ,
*      end of  ty_emddtl.

DATA : ty_emddtl TYPE zmm_emd_status.

TYPES:  BEGIN OF ty_emdref,
  itemno   TYPE zmm_emdref-itemno   ,
  trans    TYPE zmm_emdref-trans    ,
  refdoc   TYPE zmm_emdref-refdoc   ,
  docno    TYPE zmm_emdref-docno    ,
  ebeln    TYPE zmm_emdref-ebeln    ,
  status   TYPE zmm_emdref-status   ,
  stat_desc(30)                     ,
  amount   TYPE zmm_emdref-amount   ,
  currency TYPE zmm_emdref-currency ,
  rscode   TYPE zmm_emdref-rscode   ,
  remark   TYPE zmm_emdref-remark   ,
END OF ty_emdref.

DATA: g_task_cd    TYPE vrm_id,
      g_task_list  TYPE vrm_values,
      g_task_value LIKE LINE OF g_task_list.
*&-------------------------------------------------------------------
*                 GLOBAL Variable Declaration                         *
*&--------------------------------------------------------------------&*
DATA:  g_action(40)      ,
       g_vcode  LIKE ekko-submi ,
       g_tendno LIKE ekko-lifnr ,
       g_vname  LIKE lfa1-name1 ,
       g_ekgrp  LIKE ekko-ekgrp .

DATA: g_okhdr  ,           "To check Header Info. Entered
      g_line  TYPE i,
      g_save_h      ,        "To Check Header Data insert
      g_save_i      ,        "To Check Item   Data insert
      g_amount TYPE zmm_emdhdr-amount  ,
      g_balamt TYPE zmm_emdhdr-amount  .

DATA: g_docno TYPE xblnr  , "Document no at Header Level
      g_idocno  TYPE zmm_emdhdr-docno ,
      g_ans ,
      g_titel(30)        ,
      g_sc_ans           ,  "For Save Changes
      g_dansw            ,  "For Delete Doc.
      g_status(50)       ,  "To display Doc. Status in Screen 105.
      g_hstatus(50)      , "To display Doc. Status in Screen 105.
      g_reset            ,  "Flag for Reset Document Status
      g_error            ,
      g_reset_status     .
DATA: g_ransw     ,
      g_ref       ,
      g_rfqpo(20) ,
      g_text(35)  .

DATA: g_rfc ,      " Flag for Popup conf. Screen '0110'.
      g_doccat(11) ,
      g_rfc_chk        ."Flag for Refund/Forfeit/EMD-SD Conv.
DATA: g_tot_ref TYPE zmm_emdref-amount. "Total refund amount in refund
"table
DATA : g_crea_by    LIKE  sy-uname ,
       g_crea_on    LIKE  sy-datum ,
       g_chan_by    LIKE  sy-uname ,
       g_chan_on    LIKE  sy-datum ,
       g_stat       LIKE  zmm_emdhdr-status ,
       g_h_status   LIKE  zmm_emdhdr-status .
DATA:  g_amt        TYPE zmm_emdhdr-amount ,
       g_lines      TYPE sy-tabix  ,
       g_dynnr      LIKE sy-dynnr VALUE '0130',
       g_docstat ,     "Global Document status
       g_locname     LIKE  zmm_emdloc-locname ,
       g_ans_ad                               ,
       g_itemno      LIKE zmm_emddtl-item_no  ,
       g_ebeln       LIKE ekko-ebeln   ,
       g_tfxm                          .
*&--------------------------------------------------------------------&*
*                 Work Area Declaration                                *
*&--------------------------------------------------------------------&*
DATA: wa_tab  TYPE ty_tabtype,
      wa_ekko TYPE ekko      ,
      wa_lfa1 TYPE lfa1.

DATA : wa_emdhdr      TYPE zmm_emdhdr ,
       wa_emddtl      TYPE  zmm_emd_status ,
       wa_emddtl01    TYPE zmm_emddtl.

DATA: wa_tc105        TYPE  zmm_emd_status ,
      wa_tc135        TYPE  zmm_emd_status ,
      wa_tc145        TYPE  zmm_emd_status ,
      wa_tc155        TYPE  zmm_emd_status.

DATA: wa_emdref       TYPE  zmm_emdref,
      wa_emdref_01    TYPE  ty_emdref ,
      wa_emdref_02    TYPE  ty_emdref .

* Begin of <RD1K963111>
DATA: lt_emdref TYPE TABLE OF zmm_emdref.
DATA: lt_emddtl TYPE TABLE OF zmm_emddtl,
      wa_emddtl1 TYPE zmm_emddtl.
* End of <RD1K963111>

DATA: wa_emdhdr_t02   LIKE zmm_emdhdr  ,
      wa_emdref_t01   TYPE  ty_emdref .

*&--------------------------------------------------------------------&*
*                Internal Table Declration                             *
*&--------------------------------------------------------------------&*

DATA:  ist_ekko TYPE TABLE OF ty_ekko ,
       ist_ret_tab        TYPE TABLE  OF ddshretval WITH HEADER LINE,
       ist_field_tab      TYPE TABLE OF dfies WITH  HEADER LINE     ,
       ist_tab TYPE STANDARD TABLE OF ty_tabtype WITH HEADER LINE ,
       ist_tabnew TYPE STANDARD TABLE OF ty_tabtype WITH HEADER LINE . .

DATA: ist_emddtl     LIKE TABLE OF   wa_emddtl  ,
      ist_emddtl01   LIKE TABLE OF   zmm_emddtl ,
      ist_emdhdr     TYPE TABLE OF   zmm_emdhdr ,
      ist_del_emddtl LIKE TABLE OF  wa_emddtl ,
      ist_dtl TYPE STANDARD TABLE OF zmm_emddtl WITH HEADER LINE .

DATA: ist_emddtl_t01 TYPE TABLE OF  zmm_emd_status  ,
      ist_emdref     TYPE TABLE OF  zmm_emdref  .

DATA: ist_emdref_01  LIKE TABLE OF   wa_emdref_01 .
DATA  ist_dd07v      TYPE TABLE OF dd07v         .

* Internal table for change history
DATA :   ist_scrdtl TYPE TABLE OF  zmm_emd_status WITH HEADER LINE ,
         ist_chngind TYPE TABLE OF cdtxt WITH HEADER LINE ,
         ist_nemddtl LIKE zmm_emddtl ,
         ist_oemddtl LIKE zmm_emddtl .
RANGES : r_insttype FOR zmm_emddtl-inst_type .
*&--------------------------------------------------------------------&*
*SRM Changes Addtional Variables.
DATA  g_ttype(3).
*&--------------------------------------------------------------------&*
DATA  g_reqtext(20).
DATA  g_reqno TYPE zmm_emddtl-ri_reqno.
DATA  g_bstyp TYPE zmm_emdhdr-bstyp .
DATA  g_firet.
DATA  g_mmret.
DATA: l_result.

*** SRM E-Bid & Vendor validation
* Begin of <RD1K963111>
DATA zallow TYPE c.
* End of <RD1K963111>

* Changing the Bidder Tender Fee Exemption Program - Manikandan.
DATA lv_srm_update_status TYPE char1.

* Changing the Document Deletion for Tender & ETenders - Manikandan
DATA l_logsys(32) TYPE c.

DATA : g_pmc(1).                                      "+007

********************************Archived Retrival Declarations**********************************
 TYPES : BEGIN OF stype_aind_str1,
         archindex           LIKE  aind_str1-archindex,
         itype               LIKE  aind_str1-itype,
         skey                LIKE  aind_str1-skey,
       END OF stype_aind_str1,
       stab_aind_str1        TYPE STANDARD TABLE OF stype_aind_str1 WITH DEFAULT KEY.

DATA : g_s_aind_str1_ais     TYPE  stype_aind_str1,
       g_t_aind_str1_ais     TYPE  stab_aind_str1.

TYPES: BEGIN OF stype_fields,
        fieldname            TYPE  aind_str3-fieldname,
      END OF   stype_fields,
      stab_fields            TYPE STANDARD TABLE OF stype_fields WITH DEFAULT KEY.

DATA : g_s_all_fields        TYPE  stype_fields,
       g_t_all_fields        TYPE  stab_fields.
TYPES : BEGIN OF ty_frange,
          fieldname          TYPE  fieldname,
          selopt_t           TYPE STANDARD TABLE OF rsdsselopt WITH DEFAULT KEY,
        END OF ty_frange.

DATA : g_s_selopt            TYPE  rsdsselopt,
       g_s_frange            TYPE  ty_frange,
       g_t_frange            TYPE  TABLE OF  ty_frange.
TYPES: BEGIN OF stype_as_key,
         archivekey          LIKE  arcid_vbrk-archivekey,
         archiveofs          LIKE  arcid_vbrk-offst,
       END OF stype_as_key,
       stab_as_key           TYPE STANDARD TABLE OF stype_as_key WITH DEFAULT KEY.
DATA : l_t_as_key            TYPE  stab_as_key,
       g_s_as_key            TYPE  stype_as_key .

DATA:  l_handle              LIKE sy-tabix.
DATA:  ct_ekko               TYPE STANDARD TABLE OF ekko.
DATA : it_ekko_arch          TYPE TABLE OF ekko ,
       wa_ekko_arch          like LINE OF it_ekko_arch ,
       g_lifnr_arch          type ekko-lifnr ,
       g_aedat_arch          type ekko-aedat ,
       g_reswk_arch          type ekko-reswk.
* data : p_arch.
********************************Archived Retrival Declarations**********************************
