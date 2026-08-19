*--- MAIN PROGRAM: SAPMZMMTMS ---*
***********************************************************************
* Program    : SAPMZMMTMS                                             *
*                                                                     *
* Title      : Tender Monitoring System(TMS)                          *
*                                                                     *
* Functional Specification No.: CR No. 30006227                       *
*                                                                     *
* Author     : S P YADAV                   Date : 10-Apr-2012         *
*                                                                     *
* Login Id   : CAB_SPYADAV                                            *
*                                                                     *
* Desciption : Purpose of the Tender Monitoring System(TMS) is to     *
*              monitor of tenders in ONGC                             *
*                                                                     *
* Transaction Code : ZMMTMS                                           *
*                                                                     *
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
***********************************************************************
*                                                                     *
* Mod Date    Changed by    Description                 Chng ID       *
*                                                                     *
* 18.12.2012  CAB_SPYADAV   Changes as per CR No.        001          *
*                           30008343                                  *
*                                                                     *
* 08.02.2013  CAB_SPYADAV   Changes as per CR No.        002          *
*                           30008447                                  *
*                                                                     *
* 10.05.2013  CAB_DHIRAJ    Changes as per CR No.        003          *
*                           30009068                                  *
*                                                                     *
* 23.09.2013  CAB_SPYADAV   Changes as per CR No.        004          *
*                           30009253                                  *
*                                                                     *
*                                                                     *
* 23.10.2013  CAB_SPYADAV   Changes as per CR No.        005          *
*                           30009906                                  *
*                                                                     *
* 31.01.2014  CAB_SPYADAV   Changes as per CR No.        006          *
*                           30010328                                  *
*                                                                     *
* 29.04.2014  CAB_SPYADAV   Changes as per CR No.        007          *
*                           30010728                                  *
*                                                                     *
* 27.09.2014  CAB_SPYADAV   Changes as per CR No.        008          *
*                           30011617                                  *
*                           1) Logic to various date for              *
*                              Single tender/Board                    *
*                              purchase                               *
*                           2) NIT date validation                    *
*                           3) Set PR profile to blank                *
*                              for the tender with                    *
*                              Document type 'ET*' &                  *
*                              having a opening Price                 *
*                              Bid(actual) date.                      *
*                            4)Start & last date of                   *
*                              tender should not be                   *
*                              mandatory for open tender              *
*                              in create mode                         *
*                                                                     *
* 07.10.2014  CAB_SPYADAV   Changes as per CR No.        009          *
*                           30011821                                  *
*                           1) In case Document type L                *
*                              and value of cases lies                *
*                              between Rs 5 Lac to Rs.                *
*                              25 Lac , than                          *
*                              Opening of price bids =                *
*                              Technical Bid Opening Date             *
*                                                                     *
*                           2) In case BEC approved by the EPC        *
*                              than CPA field should be not           *
*                              editable                               *
*                                                                     *
*10.11.2014  CAB_LIPSY     Changes as per CR No.                      *
*                          30011862  "RD1K994950                      *
*01.04.2015  CAB_SPYADAV  Changes as per CR No.30012147 <RD1K995870>  *
*                        (lipsy)
*11.05.2015  CAB_SPYADAV  Changes as per CR No.30012727 <RD1K997136>  *
*                        (lipsy)
*25.05.2015  CAB_SPYADAV  Changes as per CR No.30012811(lipsy)        *
*                         <RD1K997320>
*10.07.2015  CAB_SPYADAV  Changes as per CR No.30012989(lipsy)        *
*                         <RD1K997763>
***********************************************************************
PROGRAM sapmzmmtms .

*--- MODULE for Data Declaration---------------------------------------*
INCLUDE mzmmtmstop.

*--- PAI-MODULE for User-screens --------------------------------------*
INCLUDE mzmmtmsi01.

*--- PBO-MODULE for User-screens --------------------------------------*
INCLUDE mzmmtmso01.

*--- MODULE for Subroutines -------------------------------------------*
INCLUDE mzmmtmsf01.

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

*--- INCLUDE: %_CESP1 ---*
************************************************************************
* Name     : ESP1
* Issue    : DD-Mon-YY - [ Name ] - TechniDATA GmbH/Markdorf
*
* Purpose  : Common type definitions for EH&S .........
*
* Changes  :
* [ Date  ] - [ Name    ] - [ Action                              ]
* 13.10.98    C5000678      Insert Types for Searchmode
* 13.10.98    C5000678      Insert Types for Daterange
* 13.10.98    C5000678      Insert Types for Val.Table incl. Daterange
* 20.01.99    msa            Insert types for Ltxt-Key-search
* 18.03.02    C5027806      Added Download, Upload, and Control to
*                           ESP1_C_ACTVT
* 13.03.2003  C5023441      added READ to ESP1_C_ACTVT
* 19.12.2005  C5035418      Added SEND to ESP1_C_ACTVT
************************************************************************

TYPE-POOL ESP1 .

* general boolean type (compare include file CBUI09)
*TYPES: ESP1_BOOLEAN(1) TYPE C.
*TYPES: ESP1_BOOLEAN LIKE BOOLE-BOOLE.
TYPES: ESP1_BOOLEAN LIKE BAPISTDTYP-BOOLEAN.
CONSTANTS: ESP1_FALSE TYPE ESP1_BOOLEAN VALUE ' ',
           ESP1_TRUE  TYPE ESP1_BOOLEAN VALUE 'X'.


* type of ok-code field
TYPES: ESP1_OKCODE_TYPE LIKE SY-UCOMM.


* types for f4-help-request
TYPES: BEGIN OF ESP1_F4_LENGTH_TYPE,
         DATA_LEN       TYPE I,
         VISIBLE_LEN    TYPE I,
         ORIENTATION    TYPE C,        " 'l'eft or 'r'ight
         HEADING(30)    TYPE C,
         TAB_FIELD_NAME LIKE DD03L-FIELDNAME, " for sorting
         COLUMN_START   TYPE I,
         COLUMN_END     TYPE I,
       END OF ESP1_F4_LENGTH_TYPE.

TYPES: ESP1_F4_LENGTH_TAB_TYPE TYPE ESP1_F4_LENGTH_TYPE
                               OCCURS 5.


* types for authority check
* activity
TYPES: ESP1_ACTVT_TYPE  LIKE TACTT-ACTVT.

CONSTANTS: BEGIN OF ESP1_C_ACTVT,
    INITIAL TYPE ESP1_ACTVT_TYPE VALUE IS INITIAL,
    SHOW    TYPE ESP1_ACTVT_TYPE VALUE '03',
    CHANGE  TYPE ESP1_ACTVT_TYPE VALUE '02',
    CREATE  TYPE ESP1_ACTVT_TYPE VALUE '01',
    LOCK    TYPE ESP1_ACTVT_TYPE VALUE '05',
    DELETE  TYPE ESP1_ACTVT_TYPE VALUE '06',
    MAINT   TYPE ESP1_ACTVT_TYPE VALUE '23',
    SEND    TYPE ESP1_ACTVT_TYPE VALUE '59',
    IMPORT  TYPE ESP1_ACTVT_TYPE VALUE '60',
    EXPORT  TYPE ESP1_ACTVT_TYPE VALUE '61',
    SCHED   TYPE ESP1_ACTVT_TYPE VALUE '81',
    REACT   TYPE ESP1_ACTVT_TYPE VALUE '91',
    ALE     TYPE ESP1_ACTVT_TYPE VALUE 'A9',
    CONTROL TYPE ESP1_ACTVT_TYPE VALUE '16',
    DWNLOAD TYPE ESP1_ACTVT_TYPE VALUE 'DL',
    UPLOAD  TYPE ESP1_ACTVT_TYPE VALUE 'UL',
    READ    TYPE ESP1_ACTVT_TYPE VALUE '33',
  END OF ESP1_C_ACTVT.

* constants for the EH&S-activity
CONSTANTS: BEGIN OF ESP1_ACTYPE,
    INITIAL LIKE RCGDIALCTR-ACTYPE VALUE IS INITIAL, " (initial)
    CREATE  LIKE RCGDIALCTR-ACTYPE VALUE 'C',        " create
    CHANGE  LIKE RCGDIALCTR-ACTYPE VALUE 'E',        " change
    SHOW    LIKE RCGDIALCTR-ACTYPE VALUE 'D',        " show
    INFO    LIKE RCGDIALCTR-ACTYPE VALUE 'I',        " info system
    SEND    LIKE RCGDIALCTR-ACTYPE VALUE 'S',        " send
  END OF ESP1_ACTYPE.

* type for the lock-object-prefix-name
TYPES: ESP1_LOCK_OBJECT_PREFIX(4) TYPE C.

* type for the language (Because the type LIKE SY-LANGU
* does not provide a F4-help!)
*TYPES: ESP1_SPRAS LIKE T002T-SPRAS.
TYPES: ESP1_SPRAS LIKE ESTRI-LANGU.

* name-types for dynamic performs and calls
* (Rem.: Many useful fields and types for R/3-objects can be found
*  in the development classes SABP ('ABAP/4 Runtime Environment')
*  and SEU ('ABAP/4 Development Workbench'), or in all development
*  classes, whose names match with 'SE*'.)
TYPES: ESP1_FORM_NAME       TYPE EX_CPU_VAL, "see 40 in 487994
*       ESP1_FORM_NAME       LIKE RS38T-FORM_NAME,
       ESP1_PROG_NAME       LIKE RS38M-PROGRAMM,
       ESP1_FUNC_NAME       LIKE TFDIR-FUNCNAME,
       ESP1_LOCK_OBJ        LIKE RSRD1-ENQU_VAL,
       ESP1_TAB_NAME        LIKE DD02L-TABNAME,
       ESP1_FIELD_NAME      LIKE DD03L-FIELDNAME,
       ESP1_DYNP_NUM        LIKE D020S-DNUM,
       ESP1_TAB_PAR_NAME    LIKE RS38L_PARA-TABLES,
       ESP1_PROG_FIELD_NAME LIKE RFIELDLIST-NAME,
       ESP1_CUA_STATE_NAME  LIKE RSEU1-STATUS,
       ESP1_CUA_TITLE_NAME  LIKE RSEU1-TIT_CODE,
       ESP1_TEXT_ELEMENT    LIKE RS38M-ITEX,
       ESP1_STRING          LIKE ESTPP-PHRTEXT.

* structure for internal tables with field information /fieldnames)
TYPES: BEGIN OF ESP1_FIELDNAME_WA_TYPE,
         FIELDNAME TYPE ESP1_FIELD_NAME,
       END OF ESP1_FIELDNAME_WA_TYPE.

TYPES: ESP1_FIELDNAME_TAB_TYPE TYPE ESP1_FIELDNAME_WA_TYPE OCCURS 0.

* type for the position of a window
TYPES: ESP1_WINDOW_POSITION LIKE SY-WINX1.

* type for a table containing tablenames, fieldnames and values
TYPES: BEGIN OF ESP1_TABNAME_WA_TYPE,
         TABNAME   LIKE DD02L-TABNAME,
         FIELDNAME LIKE DD03L-FIELDNAME,
         VALUE     LIKE CVDDP-VALUE,
       END OF ESP1_TABNAME_WA_TYPE.
TYPES: ESP1_TABNAME_TAB_TYPE TYPE ESP1_TABNAME_WA_TYPE OCCURS 10.

* types for dynamic where-condition-tables
*TYPES: ESP1_CONDLINE_TYPE LIKE ABAPSOURCE. (= better alternative?)
TYPES: BEGIN OF ESP1_CONDLINE_TYPE,
         LINE(72) TYPE C,
       END OF ESP1_CONDLINE_TYPE.
TYPES: ESP1_CONDTAB_TYPE TYPE ESP1_CONDLINE_TYPE OCCURS 50.

* constant for the date with the initial value
* Begin Correction 19.07.2004 0753891 *******************
SET EXTENDED CHECK ON.
CONSTANTS: ESP1_INITIAL_DATE LIKE SY-DATUM VALUE IS INITIAL.
SET EXTENDED CHECK OFF.
* End Correction 19.07.2004 0753891 *********************

* constant for the record-number with the initial value
CONSTANTS: ESP1_INITIAL_RECN LIKE RCGUKEY-RECN VALUE IS INITIAL.

* type definitions for general set/get parameter archive library ------
TYPES: BEGIN OF ESP1_SGP_TCODE_WA_TYPE,
    TCODE LIKE SY-TCODE,
  END OF ESP1_SGP_TCODE_WA_TYPE.
TYPES: ESP1_SGP_TCODE_TAB_TYPE TYPE ESP1_SGP_TCODE_WA_TYPE OCCURS 20.

* value for dummy entry (to indicate empty set/get parameter)
CONSTANTS:
  BEGIN OF ESP1_SGP_INITIAL,
    TABLENAME  LIKE TCGSGP-TABLENAME  VALUE '(TABLE)',
    FIELDNAME  LIKE TCGSGP-FIELDNAME  VALUE '(FIELD)',
    VALUE      LIKE TCGSGP-VALUE      VALUE '(EMPTY)',
  END OF ESP1_SGP_INITIAL.

* types for messages
TYPES: BEGIN OF ESP1_MESSAGE_WA_TYPE,
         MSGID  LIKE SY-MSGID,
         MSGTY  LIKE SY-MSGTY,
         MSGNO  LIKE SY-MSGNO,
         MSGV1  LIKE SY-MSGV1,
         MSGV2  LIKE SY-MSGV2,
         MSGV3  LIKE SY-MSGV3,
         MSGV4  LIKE SY-MSGV4,
         LINENO LIKE MESG-ZEILE,
       END OF ESP1_MESSAGE_WA_TYPE.
TYPES: ESP1_MESSAGE_TAB_TYPE TYPE ESP1_MESSAGE_WA_TYPE OCCURS 20.

* type to maintain table-indexes
TYPES: BEGIN OF ESP1_TABIX_WA_TYPE,
         TABIX LIKE SY-TABIX,
       END OF ESP1_TABIX_WA_TYPE.
TYPES: ESP1_TABIX_HTAB_TYPE TYPE HASHED TABLE OF ESP1_TABIX_WA_TYPE
                            WITH UNIQUE KEY TABIX
                            INITIAL SIZE 100.

* type for modes, especially for the valuation check function
TYPES: ESP1_MODE_TYPE     TYPE C.

*
TYPES ESP1_STRING132_TYPE(132) TYPE C.

TYPES ESP1_STRING132_TAB_TYPE TYPE ESP1_STRING132_TYPE OCCURS 10.

TYPES: BEGIN OF ESP1_SUBST_PARAM_DESC_WA,
         NAME(30)  TYPE C,
         VALUE     TYPE ESP1_STRING,
       END OF ESP1_SUBST_PARAM_DESC_WA,
       ESP1_SUBST_PARAM_DESC_TAB_TYPE TYPE ESP1_SUBST_PARAM_DESC_WA
                                 OCCURS 10.

TYPES: BEGIN OF ESP1_SUBST_PARAM_WA,
         FIELD1 TYPE ESP1_STRING132_TYPE,
         FIELD2 TYPE ESP1_STRING132_TYPE,
         FIELD3 TYPE ESP1_STRING132_TYPE,
         FIELD4 TYPE ESP1_STRING132_TYPE,
         FIELD5 TYPE ESP1_STRING132_TYPE,
       END OF ESP1_SUBST_PARAM_WA,
       ESP1_SUBST_PARAM_TAB_TYPE TYPE ESP1_SUBST_PARAM_WA OCCURS 10.


* ehs version info type -----------------------------------------------
TYPES: ESP1_EHS_VERSION_INFO_TYPE(5) TYPE C.
* note: modifications also must be updated in the wwi-setup
* and in interface-classes.
CONSTANTS: BEGIN OF ESP1_C_EHS_VERSION,
    ALASKA     TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.2b',
    DELAWARE   TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.5a',
    FINLAND    TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.5b',
    FLORIDA    TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.7a',
    GREENLAND  TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.7b',
    CALIFORNIA TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '3.1',
    ICELAND    TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '3.2',
    HAWAII     TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2004',
    ARCTIC     TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2005',
    MADAGASCAR TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2006',
  END OF ESP1_C_EHS_VERSION.


* ehs application identification --------------------------------------

* type and constants for the ranges of applications of the EH&S-system
TYPES: ESP1_APPL_RANGE_TYPE(30) TYPE C.
CONSTANTS: BEGIN OF ESP1_C_APPL_RANGE,
*            the whole EH&S
             GENERAL       TYPE ESP1_APPL_RANGE_TYPE
                           VALUE 'GENERAL',                 "#EC NOTEXT
*            specification-management
             SUBSTANCE     TYPE ESP1_APPL_RANGE_TYPE
                           VALUE 'SUBSTANCE',               "#EC NOTEXT
*            import/export
             DATA_TRANSFER TYPE ESP1_APPL_RANGE_TYPE
                           VALUE 'DATA_TRANSFER',           "#EC NOTEXT
*            (obsolet) classification-key
             CLASSIF_KEY   TYPE ESP1_APPL_RANGE_TYPE
                           VALUE 'CLASSIF_KEY',             "#EC NOTEXT
*            <next application range>
*            ...           TYPE ESP1_APPL_RANGE_TYPE
*                          VALUE '...',           "#EC NOTEXT
           END OF ESP1_C_APPL_RANGE.


* type of/constants for application in TCG03 (buffer meta dictionary)
TYPES:
  ESP1_APPLICATION_TYPE TYPE TCG03-APPL.

CONSTANTS:
  BEGIN OF ESP1_C_APPLICATION_TYPE,
    SUBSTANCE  TYPE ESP1_APPLICATION_TYPE  VALUE 'STST',    "#EC NOTEXT
    PHRASE     TYPE ESP1_APPLICATION_TYPE  VALUE 'PHRS',    "#EC NOTEXT
    REPORT     TYPE ESP1_APPLICATION_TYPE  VALUE 'BERW',    "#EC NOTEXT
    IMPEXP     TYPE ESP1_APPLICATION_TYPE  VALUE 'IMEX',    "#EC NOTEXT
    IHYGIENE   TYPE ESP1_APPLICATION_TYPE  VALUE 'IHS',     "#EC NOTEXT
    APPL_SCOPE TYPE ESP1_APPLICATION_TYPE  VALUE 'ASCP',    "#EC NOTEXT
  END OF ESP1_C_APPLICATION_TYPE.


*** Search including usage check                 " <<< C5000678 25.11.98

* fields necessary for usage check
TYPES: BEGIN OF ESP1_ESTVA_UC_TYPE,
         RECN     LIKE ESTVA-RECN,
         RECNROOT LIKE ESTVA-RECNROOT,
       END   OF ESP1_ESTVA_UC_TYPE.

* table for usage check
TYPES: ESP1_ESTVA_UC_TAB_TYPE TYPE ESP1_ESTVA_UC_TYPE OCCURS 10.

* fields necessary for usage check
TYPES: BEGIN OF ESP1_ESTVA_FRTO_UC_TYPE,
         RECN     LIKE ESTVA-RECN,
         RECNROOT LIKE ESTVA-RECNROOT.
        INCLUDE STRUCTURE RCGDATERANGE.
TYPES: END OF ESP1_ESTVA_FRTO_UC_TYPE.

* table for usage check
TYPES: ESP1_ESTVA_FRTO_UC_TAB_TYPE
                          TYPE ESP1_ESTVA_FRTO_UC_TYPE OCCURS 10.


*** Searchmode                                   " <<< C5000678 13.10.98

* Searchmode for time interval search ('Historic Data')
TYPES: ESP1_SEARCHMODE_TYPE LIKE RCGSELSCR-SEARCHMODE.

* Searchmode: Legal Values
CONSTANTS: BEGIN OF ESP1_SEARCHMODE,
             INITIAL TYPE ESP1_SEARCHMODE_TYPE VALUE ' ',
             WEAK    TYPE ESP1_SEARCHMODE_TYPE VALUE 'w',
             MEDIUM  TYPE ESP1_SEARCHMODE_TYPE VALUE 'm',
             STRONG  TYPE ESP1_SEARCHMODE_TYPE VALUE 's',
           END OF ESP1_SEARCHMODE.

* Searchmode: Shortcut for initial value
CONSTANTS: ESP1_SRCHMD_INIT TYPE ESP1_SEARCHMODE_TYPE
             VALUE ESP1_SEARCHMODE-INITIAL.

*** Flat Tables including daterange for SELECTs ---------------------- *

*** Daterange                                    " <<< C5000678 13.10.98

* Type "Daterange"
TYPES: BEGIN OF ESP1_DATERANGE_TYPE.
        INCLUDE STRUCTURE RCGDATERANGE.
TYPES: END   OF ESP1_DATERANGE_TYPE.

* Internal Table "Daterange"
TYPES: ESP1_DATERANGE_TAB_TYPE TYPE ESP1_DATERANGE_TYPE OCCURS 10.


* Time Interval Search: Basics (Ltxt-Key)              <<< msa 20.01.99
TYPES: BEGIN OF ESP1_FRTO_LTXTKEY_TYPE.
        INCLUDE STRUCTURE RCGLTXTKEY.
        INCLUDE STRUCTURE RCGDATERANGE.
TYPES: END OF ESP1_FRTO_LTXTKEY_TYPE.

* Internal Table for Searching a Time Interval: Basics (Ltxt-Key)
TYPES: ESP1_FRTO_LTXTKEY_TAB_TYPE TYPE ESP1_FRTO_LTXTKEY_TYPE OCCURS 10.


* 3-dimensional tables including daterange for resulting hit tables -- *
* Note: these tables employ the infix 'frto' ------------------------- *

*** Material                                     " <<< C5000678 19.11.98

* Time Interval Search: Material
TYPES: BEGIN OF ESP1_FRTO_MAT_TYPE,
         RECNROOT  LIKE  ESTRH-RECN,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
         MATNR     LIKE  MARA-MATNR,
         MAKTX     LIKE  MAKT-MAKTX,
       END OF ESP1_FRTO_MAT_TYPE.

* Internal Table for Searching a Time Interval: Material
TYPES: ESP1_FRTO_MAT_TAB_TYPE TYPE ESP1_FRTO_MAT_TYPE OCCURS 10.


*** Status

* Time Interval Search: Status
TYPES: BEGIN OF ESP1_FRTO_STAT_TYPE,
*         RECNROOT  LIKE  ESTST-RECN,
         RECNROOT  LIKE  EHSBT_APPL_SCOPE-RECN,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
*         VACLID    LIKE  ESTST-VACLID,
         VACLID    LIKE  EHSBT_APPL_SCOPE-VACLID,
*         RVLID     LIKE  ESTST-RVLID,
         RVLID     LIKE  EHSBT_APPL_SCOPE-RVLID,
       END OF ESP1_FRTO_STAT_TYPE.

* Internal Table for Searching a Time Interval: Status
TYPES: ESP1_FRTO_STAT_TAB_TYPE TYPE ESP1_FRTO_STAT_TYPE OCCURS 10.

*** Ident
* Time Interval Search: Ident
TYPES: BEGIN OF ESP1_FRTO_IDENT_TYPE,
         RECN      LIKE  ESTRH-RECN,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
         AUTHGRP   LIKE  RCGIDENT-AUTHGRP,
         POS       LIKE  RCGIDENT-POS,
         COUNTER   LIKE  RCGIDENT-COUNTER,
         LANGU     LIKE  RCGIDENT-LANGU,
         IDTYPE    LIKE  RCGIDENT-IDTYPE,
         IDCAT     LIKE  RCGIDENT-IDCAT,
         IDENT     LIKE  RCGIDENT-IDENT,
         MATINFO   LIKE  RCGIDENT-MATINFO,
* Begin Correction 15.07.2004 0753891 *******************
         RI_RECN   LIKE  RCGIDENT-RI_RECN,
* End Correction 15.07.2004 0753891 *********************
       END OF ESP1_FRTO_IDENT_TYPE.

* Internal Table for Searching a Time Interval: Ident
TYPES: ESP1_FRTO_IDENT_TAB_TYPE TYPE ESP1_FRTO_IDENT_TYPE OCCURS 10.

*** HEAD
* Time Interval Search: Head (authgrp)
TYPES: BEGIN OF ESP1_FRTO_AUTHGRP_TYPE,
         RECN      LIKE ESTRH-RECN,
         AUTHGRP   LIKE ESTRH-AUTHGRP,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
       END OF ESP1_FRTO_AUTHGRP_TYPE.

* Internal Table for Searching a Time Interval: Head (authgrp)
TYPES: ESP1_FRTO_AUTHGRP_TAB_TYPE TYPE ESP1_FRTO_AUTHGRP_TYPE OCCURS 10.


*** Basic Form - used for Substance List / Extended Search / Result Tabl

* Time Interval Search: Basic Form (Recn & daterange)
TYPES: BEGIN OF ESP1_FRTO_RECN_TYPE,
         RECN      LIKE  ESTRH-RECN,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
       END OF ESP1_FRTO_RECN_TYPE.

* Internal Table for Searching a Time Interval: Basic Form
TYPES: ESP1_FRTO_RECN_TAB_TYPE TYPE ESP1_FRTO_RECN_TYPE OCCURS 1.


* Time Interval Search:  Referencing subs (Recn & recnref & daterange)
TYPES: BEGIN OF ESP1_FRTO_RECNREF_TYPE,
         RECNREF   LIKE  ESTRR-RECNREF,
         RECNROOT  LIKE  ESTRR-RECNROOT,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
       END OF ESP1_FRTO_RECNREF_TYPE.

* Internal Table for Searching a Time Interval: Referencing subs
TYPES: ESP1_FRTO_RECNREF_TAB_TYPE TYPE ESP1_FRTO_RECNREF_TYPE OCCURS 1.


*<<< msa
* Time Interval Search: extended search functions (user exits)
*                       Basic Form (Recn & HitInfo & daterange)
*types: begin of esp1_frto_hitinfo_type.
*         include  structure  rcghitinfo.
*types:   frto_tab type       esp1_daterange_tab_type.
*types: end of esp1_frto_hitinfo_type.
*
* Internal Table for Searching a Time Interval: Basic Form
*types: esp1_frto_hitinfo_tab_type type esp1_frto_hitinfo_type occurs 1.


*** Valuation                                    " <<< C5000678 13.10.98

* Time Interval Search: Valuation
TYPES: BEGIN OF ESP1_FRTO_ESTVA_TYPE,
         RECN      LIKE  ESTRH-RECN,
         FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
         RECNROOT  LIKE  ESTVA-RECNROOT,
         RECNTVH   LIKE  ESTVA-RECNTVH,
         ORD       LIKE  ESTVA-ORD,
         COMPREL   LIKE  ESTVA-COMPREL,
       END   OF ESP1_FRTO_ESTVA_TYPE.

* Internal Table for Searching a Time Interval: Valuation
TYPES: ESP1_FRTO_ESTVA_TAB_TYPE TYPE ESP1_FRTO_ESTVA_TYPE OCCURS 10.


* Internal table for searching a time interval: Valuation
*
TYPES: BEGIN OF ESP1_FRTO_ESTCAT_TYPE,
         RECN      LIKE      ESTRH-RECN,
         FRTO_TAB  TYPE      ESP1_DATERANGE_TAB_TYPE,
         ESTCAT    LIKE      TCG11-ESTCAT,
       END OF ESP1_FRTO_ESTCAT_TYPE.
TYPES: ESP1_FRTO_ESTCAT_TAB_TYPE TYPE ESP1_FRTO_ESTCAT_TYPE OCCURS 10.

* Time Interval Search:  Referencing subs (Recn & recnref & daterange)
TYPES: BEGIN OF ESP1_FRTO_INDIRECT_TYPE,
         RECN      LIKE      ESTRH-RECNROOT,
         FRTO_TAB  TYPE      ESP1_DATERANGE_TAB_TYPE,
         RECNREF   LIKE      ESTRR-RECNREF,
         ESTCAT     LIKE TCG11-ESTCAT,
*          include  type      esprh_usage_info_type,
       END OF ESP1_FRTO_INDIRECT_TYPE.
TYPES: ESP1_FRTO_INDIRECT_TAB_TYPE
                   TYPE ESP1_FRTO_INDIRECT_TYPE OCCURS 10.


* one line of the where-used list
TYPES: BEGIN OF ESP1_FRTO_USAGE_TYPE,
*        record-no. of the used substance
         RECN      LIKE ESTRH-RECN,
*        record-no. of the using substance
         RECN_USER LIKE ESTRH-RECN,
         FRTO_TAB  TYPE      ESP1_DATERANGE_TAB_TYPE,
*        additional informations about the usage
* include  type      esprh_usage_info_type.
*        component category
         COMPCAT    LIKE ESTVP-COMPCAT,
*        precision and value of lower limit of component concentration
         PRECL      LIKE ESTVP-PRECL,
         COMPLOW    LIKE ESTVP-COMPLOW,
*        precision and value of upper limit of component concentration
         PRECU      LIKE ESTVP-PRECU,
         COMPUPP    LIKE ESTVP-COMPUPP,
*        (average) value of component concentration
         COMPAVG    LIKE ESTVP-COMPAVG,
*        exponent / unit of above values
         COMPEXP    LIKE ESTVP-COMPEXP,
       END OF ESP1_FRTO_USAGE_TYPE.

* the where-used list
TYPES: ESP1_FRTO_USAGE_TAB_TYPE TYPE ESP1_FRTO_USAGE_TYPE OCCURS 100.

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

*--- INCLUDE: IF_MESSAGE====================IT ---*

*--- INCLUDE: IF_T100_MESSAGE===============IT ---*

*--- INCLUDE: MZMMTMSF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMPURTDRNUMGENF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_validation_150
*&---------------------------------------------------------------------*
* To validate tender number
*----------------------------------------------------------------------*
*      -->P_SUBMI  Tender Number
*----------------------------------------------------------------------*
FORM check_validation_150 USING p_submi.

  CLEAR : g_pr_rcpt_dt.                              "+007

  IF NOT p_submi IS INITIAL.

    SELECT SINGLE * FROM zmm_pur_tender_d
             INTO zmm_pur_tender_d_st
               WHERE submi = p_submi.

    IF sy-subrc NE 0.
      MESSAGE e019(06) WITH zmm_pur_tender_d_st-submi.
    ENDIF.

    SELECT SINGLE * FROM  zmm_tms INTO wa_zmm_tms
           WHERE submi = p_submi.

    IF sy-subrc = 0.

*+002 : Start
      IF g_ok_code = 'APRV' AND wa_zmm_tms-rel_stat = 'X'.
        MESSAGE e963(zmm) WITH zmm_pur_tender_d_st-submi.
      ENDIF.
*+002 : End

      """"""""""""""""""""""""
      "added by lipsy on 31.03.2015 for release status changes RD1K995870
*      IF g_ok_code = 'CHNG'.
*        IF wa_zmm_tms-rel_stat = 'X'.
*          CALL FUNCTION 'POPUP_TO_CONFIRM'
*            EXPORTING
*              titlebar       = 'Derelease tender?'
*              text_question  = 'Tender is already released. Do you want to continue?'
**             text_question  = 'Tender is already released. It will be dereleased. Do you want to continue?'
**             TEXT_QUESTION  = 'Do you want to save the data entered ?
*              text_button_1  = 'Yes'
*              text_button_2  = 'No'
**             display_cancel_button = g_disp
*              default_button = '1'
*            IMPORTING
*              answer         = g_ans.
*
*          IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*          ENDIF.
*          IF g_ans = '1'.
*
*            """"""""""""""""""""""""""""""""
*            "commented by lipsy on 8.05.2015 for changing release status on save RD1K997136
**    update zmm_tms set
**    rel_stat = ''
**    where submi = zmm_pur_tender_d_st-submi.
*            "end of comment by lipsy on 8.05.2015 for changing release status on save RD1K997136
*            """"""""""""""""""""""""""""""""""""""""""""""""""""""""
*          ELSE.
*            LEAVE TO SCREEN 0.
*          ENDIF.
**         MESSAGE e963(zmm_oth) WITH zmm_pur_tender_d_st-submi.
*        ENDIF.
*      ENDIF.
      "End of addition by lipsy on 31.03.2015 for release status changes RD1K995870
      """""""""""""""""""""""""""""""""""""""""

      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_general.

*+007 : Start
      IF g_ok_code = 'CHNG'.
        MOVE zmm_tms_general-pr_rcpt_dt TO g_pr_rcpt_dt.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """""""""""""added by lipsy on 26.02.2015 for tracking tc member changes  RD1K995870
        IF g_ok_code = 'CHNG' .
          CLEAR: wa_zmm_tms_tco.
          MOVE-CORRESPONDING wa_zmm_tms TO wa_zmm_tms_tco.


          """"""""""""""""""""""
          "added by lipsy on 9.05.2015 for for tracking pr changes  RD1K997136
          MOVE-CORRESPONDING zmm_pur_tender_d_st TO wa_tender_old.

          "end of addition by lipsy on 9.05.2015 for tracking pr changes  RD1K997136
          """"""""""""""""""
        ENDIF.
        """"""""end of addition by lipsy on 26.02.2015 for tracking tc member changes  RD1K995870
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDIF.


      """""""""""""""""""
      """""""""""""added by lipsy on 26.02.2015 for tracking release status changes  RD1K995870
      IF  g_ok_code = 'APRV' OR g_ok_code = 'CHNG' .
        v_rel_old = wa_zmm_tms-rel_stat.
        SELECT SINGLE rel_stat FROM zmm_tms INTO v_rel_new WHERE submi = zmm_pur_tender_d_st-submi.
      ENDIF.
      """"""""end of addition by lipsy on 26.02.2015 for tracking release status changes  RD1K995870

      """""""""""""""""""""""""
*+007 : End

*Methodology
      IF wa_zmm_tms-mthlogy = 'R'.
        g_reg = 'X'.
        CLEAR g_spfc.
      ELSEIF wa_zmm_tms-mthlogy = 'M'.
        g_spfc = 'X'.
        CLEAR g_reg.
      ENDIF.

      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_tc.
      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_tb.
      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_pb.
      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_epc.

      MOVE zmm_tms_general-epc_typ TO zmm_tms_pb-epc_typ_pb. "+007

      PERFORM get_name_desgn USING zmm_tms_tc.

    ENDIF.
    IF zmm_tms_pb-pr_bid_op_sch_dt IS INITIAL.

      IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.                "+004

        SELECT * FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE ist_ekpo
          WHERE banfn = zmm_pur_tender_d_st-banfn
          AND loekz = ''.

        IF NOT ist_ekpo[] IS INITIAL.
          SORT ist_ekpo ASCENDING BY aedat.
          READ TABLE ist_ekpo INTO wa_ekpo INDEX 1.
          IF NOT wa_ekpo-anfnr IS INITIAL.
            SELECT SINGLE * FROM ekko INTO CORRESPONDING FIELDS OF wa_ekko
              WHERE ebeln = wa_ekpo-anfnr.
            IF sy-subrc = 0.
              zmm_tms_pb-pr_bid_op_sch_dt =  wa_ekko-zzpb_op_dt.
              zmm_tms_tb-tend_op_sch_dt  = wa_ekko-zztb_op_dt.
              zmm_tms_tc-pbc_dt  = wa_ekko-zzpre_bid_dt .
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.                                                      "+004
    ENDIF.
    g_rel_stat = wa_zmm_tms-rel_stat.
  ENDIF.

  g_option = 'X'.     "?????

ENDFORM.                    " check_validation_150

*&---------------------------------------------------------------------*
*&      Form  get_name_desgn
*&---------------------------------------------------------------------*
* To get name & desgination of tender committee / indentor etc.
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC  Tender Committee
*----------------------------------------------------------------------*
FORM get_name_desgn USING p_zmm_tms_tc STRUCTURE zmm_tms_tc.

*Get CPA Name & Desgination
  IF NOT p_zmm_tms_tc-cpa IS INITIAL.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "commented by lipsy on 18.05.2015 for cpa filled with epc RD1K997136

*    PERFORM get_name_design USING p_zmm_tms_tc-cpa
*                            CHANGING wa_cpa_dtl-ename
*                                     wa_cpa_dtl-desig_text.

    "end of  commented by lipsy on 18.05.2015 for cpa filled with epc RD1K997136
    """""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""""""
    "added by lipsy on 18.05.2015 for cpa filled with epc RD1K997136

    PERFORM get_name_design_cpa USING p_zmm_tms_tc-cpa
                            CHANGING wa_cpa_dtl-ename
                                     wa_cpa_dtl-desig_text.
    "eadded by lipsy on 18.05.2015 for cpa filled with epc RD1K997136
    """"""""""""""""""""""""""""""""""""""""""
  ELSE.

    CLEAR : wa_cpa_dtl.

  ENDIF.

*Get Indentor Name & Desgination
  IF NOT p_zmm_tms_tc-indentor IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-indentor
                            CHANGING wa_indentor_dtl-ename
                                     wa_indentor_dtl-desig_text.
  ELSE.

    CLEAR : wa_indentor_dtl.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """ADDED BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950
*Get IC MM Name & Desgination
  IF NOT p_zmm_tms_tc-ic_mm IS INITIAL.
    SHIFT p_zmm_tms_tc-ic_mm RIGHT DELETING TRAILING space.
    OVERLAY p_zmm_tms_tc-ic_mm  WITH '0000000000'.
    PERFORM get_name_design USING    p_zmm_tms_tc-ic_mm
                            CHANGING wa_icmm_dtl-ename
                                     wa_icmm_dtl-desig_text.
  ELSE.

    CLEAR : wa_icmm_dtl.

  ENDIF.





*Get L1 Name & Desgination
  IF NOT p_zmm_tms_tc-l1 IS INITIAL.
    SHIFT p_zmm_tms_tc-l1 RIGHT DELETING TRAILING space.
    OVERLAY p_zmm_tms_tc-l1  WITH '0000000000'.
    PERFORM get_name_design USING    p_zmm_tms_tc-l1
                            CHANGING wa_l1_dtl-ename
                                     wa_l1_dtl-desig_text.
  ELSE.

    CLEAR : wa_l1_dtl.

  ENDIF.

  "END OF ADDITION BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950



  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member1 IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member1
                            CHANGING wa_tc_mem1-ename
                                     wa_tc_mem1-desig_text.
  ELSE.

    CLEAR : wa_tc_mem1.

  ENDIF.

*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member2 IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member2
                            CHANGING wa_tc_mem2-ename
                                     wa_tc_mem2-desig_text.
  ELSE.

    CLEAR : wa_tc_mem2.

  ENDIF.

*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member3 IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member3
                            CHANGING wa_tc_mem3-ename
                                     wa_tc_mem3-desig_text.
  ELSE.

    CLEAR : wa_tc_mem3.

  ENDIF.

*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member4 IS INITIAL.

    PERFORM get_name_design USING p_zmm_tms_tc-tc_member4
                            CHANGING wa_tc_mem4-ename
                                     wa_tc_mem4-desig_text.
  ELSE.

    CLEAR : wa_tc_mem4.

  ENDIF.

*18.10.2012 : Start
*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member5 IS INITIAL.

    PERFORM get_name_design USING p_zmm_tms_tc-tc_member5
                            CHANGING wa_tc_mem5-ename
                                     wa_tc_mem5-desig_text.
  ELSE.

    CLEAR : wa_tc_mem5.

  ENDIF.

*Get Substitute TC member Name & Desgination 1
  IF NOT p_zmm_tms_tc-tc_member1_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member1_s
                            CHANGING wa_tc_mem1_s-ename
                                     wa_tc_mem1_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem1_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 2
  IF NOT p_zmm_tms_tc-tc_member2_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member2_s
                            CHANGING wa_tc_mem2_s-ename
                                     wa_tc_mem2_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem2_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 3
  IF NOT p_zmm_tms_tc-tc_member3_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member3_s
                            CHANGING wa_tc_mem3_s-ename
                                     wa_tc_mem3_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem3_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 4
  IF NOT p_zmm_tms_tc-tc_member4_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member4_s
                            CHANGING wa_tc_mem4_s-ename
                                     wa_tc_mem4_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem4_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 5
  IF NOT p_zmm_tms_tc-tc_member5_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member5_s
                            CHANGING wa_tc_mem5_s-ename
                                     wa_tc_mem5_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem5_s.

  ENDIF.
*18.10.2012 : End
ENDFORM.                    "check_validation_150

*&---------------------------------------------------------------------*
*&      Form  get_name_design
*&---------------------------------------------------------------------*
* To get name & desgination
*----------------------------------------------------------------------*
*      -->P_PERNR   CPF No.
*      <--P_ENAME   Employee name
*      <--P_design  Employee desgination
*----------------------------------------------------------------------*
FORM get_name_design USING    p_pernr
                     CHANGING p_ename
                              p_design.

  DATA : l_designo TYPE pa9930-designo,
         l_r_p_cd  TYPE pa9930-r_p_cd,
         l_version TYPE pa9930-version.


**---------- Changes Start date 27.06.2016 16:48:19-------------------
*  SELECT SINGLE ename FROM pa0001 INTO p_ename
*         WHERE pernr = p_pernr AND
*               endda = '99991231'.


  SELECT ENAME FROM ZPA0001 INTO P_ENAME UP TO 1 ROWS
 WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**---------- Changes  Ending Date 27.06.2016 16:48:19-----------------


  IF sy-subrc NE 0.
***    start of change 20.06.2016
**    IF P_PERNR+0(1) <> 'C'.
**
**      MESSAGE E035(ZMMPURTDR).
**    ENDIF.
***    End of change 20.06.2016
  ENDIF.


**----------Start of change 27.06.2016 16:55:33 -------------------
*  SELECT SINGLE DESIGNO R_P_CD VERSION FROM PA9930
*         INTO (L_DESIGNO,L_R_P_CD,L_VERSION)
*            WHERE PERNR = P_PERNR AND
*                  ENDDA = '99991231'.

  SELECT DESIGNO R_P_CD VERSION FROM ZPA9930
 INTO ( L_DESIGNO , L_R_P_CD , L_VERSION ) UP TO 1 ROWS WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**----------End  of change 27.06.2016 16:55:33 -----------------
  IF sy-subrc = 0.

    SELECT SINGLE desig_text FROM zdesignation_rev
         INTO p_design
            WHERE desig_code = l_designo AND
                  r_p_cd     = l_r_p_cd AND
                  version    = l_version.
  ENDIF.

ENDFORM.                    "get_name_design

*&---------------------------------------------------------------------
*
*&      Form  lock_record
*&---------------------------------------------------------------------*
*  To lock the records in case of Updation
*----------------------------------------------------------------------*
*  -->  p_submi   Tender number
*----------------------------------------------------------------------*
FORM lock_record USING p_submi.

  CALL FUNCTION 'ENQUEUE_EZ_SUBMI'
    EXPORTING
      mode_zmm_pur_tender_d = 'E'
      mandt                 = sy-mandt
      submi                 = p_submi
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " lock_record

*&---------------------------------------------------------------------*
*&      Form  unlock_record
*&---------------------------------------------------------------------*
*       To release to Locked record(s).
*----------------------------------------------------------------------*
*  -->  p_submi   Tender number
*----------------------------------------------------------------------*
FORM unlock_record USING p_submi.

  CALL FUNCTION 'DEQUEUE_EZ_SUBMI'
    EXPORTING
      mode_zmm_pur_tender_d = 'E'
      mandt                 = sy-mandt
      submi                 = p_submi.

ENDFORM.                    " unlock_record


*&---------------------------------------------------------------------*
*&      Form  confirm_input
*&---------------------------------------------------------------------*
*  In case of cancel or exit ,Display warning message.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_input.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Alert '
      text_question         = g_txt
*     TEXT_QUESTION         = 'Do you want to save the data entered ?
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      display_cancel_button = g_disp
      default_button        = '1'
    IMPORTING
      answer                = g_ans.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " confirm_input

*&---------------------------------------------------------------------*
*&      Form  save_data
*&---------------------------------------------------------------------*
*   To insert new data into master and details tables.
*----------------------------------------------------------------------*
FORM save_data.

  CLEAR : g_ret_1,
         g_ret_2.

*-----Validation on Start Date of selling tender &
*                   Last Date of selling tender.
  PERFORM validate_date_req.
*-----Converts the date and time fields into time stamp format
  PERFORM oif_conv_date_time_ts.
*-----Save the Data in DB Table
  PERFORM prepare_saving ON COMMIT.

*Added by CAB_SPYADAV : Start
  PERFORM save_data_tms ON COMMIT.

  IF g_ret_1 = 0 AND g_ret_2 = 0.
*Added by CAB_SPYADAV : End

*   IF   g_chg_flg = 'X' OR g_chg_spfc = 'X'.                    "-001
    IF   g_chg_flg = 'X' OR g_chg_spfc = 'X' OR g_chg_epc = 'X'. "+001
      PERFORM save_editor_data.
    ENDIF.

    COMMIT WORK.

    "comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870
*    PERFORM upd_purq_profile.                               "+008
    "end of comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870

    MESSAGE i037(zmmpurtdr).                                "+001
**----------Start of change 29.06.2016 15:18:06 REKHA  -------------------
**    MESSAGE i039(zmmpurtdr). " Due to automatic release .
**----------End  of change 29.06.2016 15:18:06 REKHA  -----------------

    IF NOT zmm_pur_tender_d_st-submi IS INITIAL.
      CONCATENATE tstct-ttext+15(6) 'd' INTO l_ttext.
      MESSAGE i023(zmmpurtdr) WITH zmm_pur_tender_d_st-submi l_ttext.
      PERFORM clear_para.
    ENDIF.

*Added by CAB_SPYADAV : Start
  ELSE.
    ROLLBACK WORK.
*    PERFORM clear_para.
    MESSAGE e033(zpm).
  ENDIF.
*Added by CAB_SPYADAV : End

ENDFORM.                    "save_data

*&---------------------------------------------------------------------*
*&      Form  generate_tender_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_tender_number.

  DATA : l_number(3) TYPE n,
         lsubmi      LIKE zmm_pur_tender_d_st-srno.

  SELECT SINGLE * FROM zmm_pur_trtyp WHERE bsart EQ
                                           zmm_pur_tender_d_st-bsart.

  SELECT MAX( srno )  INTO lsubmi FROM zmm_pur_tender_d
                       WHERE ekgrp     EQ zmm_pur_tender_d_st-ekgrp
                       AND   dlg_offic EQ zmm_pur_tender_d_st-dlg_offic
                       AND   mjahr     EQ zmm_pur_tender_d_st-mjahr.

  IF sy-subrc NE 0.
    l_number = '001'.
  ELSEIF sy-subrc EQ 0.
    l_number = lsubmi + 1.
  ENDIF.

  zmm_pur_tender_d_st-srno = l_number.

  CONCATENATE zmm_pur_tender_d_st-ekgrp
              zmm_pur_tender_d_st-dlg_offic
              zmm_pur_trtyp-bstyp
              zmm_pur_tender_d_st-mjahr+2(2)
              l_number INTO zmm_pur_tender_d_st-submi.


ENDFORM.                    " generate_tender_number
*&---------------------------------------------------------------------*
*&      Form  CLEAR_PARA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_para.

  CLEAR : g_action,
          zmm_pur_tender_d_st,
          g_sav_ok_100,
          g_ok_100,
          g_option.

  LEAVE TO TRANSACTION sy-tcode.

ENDFORM.                    " CLEAR_PARA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_SAVING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_saving.

  DATA l_ok(1).

*Commented by CAB_SPYADAV : Start
*  CASE sy-tcode.
**---Create
*    WHEN 'ZMMTDR1'.
*Commented by CAB_SPYADAV : End
*Generate the tender number
  l1_date = sy-datum + 7.
  l_ok = 'X'.

  IF zmm_pur_tender_d_st-tdrdt >= sy-datum AND
      zmm_pur_tender_d_st-tdrdt <= l1_date.
  ELSE.



    CLEAR l_ok.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """commentED BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
*    CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*      EXPORTING
*        popup_title  = 'Invalid Tender Date'
*        is_error     = 'X'
*        message_text = 'Tender Date should not be greater than 7 Days from Todays Date'.

    """end of comment BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """addED BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950


    MESSAGE e157(zmm_oth).

    """end of addition BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  ENDIF.

  IF NOT zmm_pur_tender_d_st-st_sel_dt IS INITIAL.
    IF zmm_pur_tender_d_st-tdrdt > zmm_pur_tender_d_st-st_sel_dt.
      CLEAR l_ok.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*        EXPORTING
*          popup_title  = 'Invalid Tender Start Date'
*          is_error     = 'X'
*          message_text = 'Tender sale Start Date should be greater than or equal to Tender Date'.
      MESSAGE: 'Tender sale Start Date should be greater than or equal to Tender Date' type 'W'.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
    ENDIF.
  ENDIF.

  IF l_ok = 'X'.
    PERFORM generate_tender_number.
    zmm_pur_tender_d_st-ernam = sy-uname.
    zmm_pur_tender_d_st-erfdt = sy-datum.
    zmm_pur_tender_d_st-bstyp = zmm_pur_trtyp-bstyp.
    INSERT zmm_pur_tender_d FROM zmm_pur_tender_d_st.

*Added by CAB_SPYADAV : Start
    IF sy-subrc = 0.

      g_ret_1 = 0.

    ELSE.

      g_ret_1 = 4.

    ENDIF.
*Added by CAB_SPYADAV : End
  ENDIF.

*Commented by CAB_SPYADAV : Start
**---Change
*    WHEN 'ZMMTDR2'.
*      UPDATE zmm_pur_tender_d SET:
*                              tdrtxt    = zmm_pur_tender_d_st-tdrtxt
*                              st_sel_dt = zmm_pur_tender_d_st-st_sel_dt
*                              lt_sel_dt = zmm_pur_tender_d_st-lt_sel_dt
*                              tdrsts    = zmm_pur_tender_d_st-tdrsts
*                              tdrsigner = zmm_pur_tender_d_st-tdrsigner
*                              banfn     = zmm_pur_tender_d_st-banfn
*                              workdesc  = zmm_pur_tender_d_st-workdesc
*                              nitdate   = zmm_pur_tender_d_st-nitdate
*                              aeusn     = sy-uname
*                              aedtm     = sy-datum
*                              timestamp = zmm_pur_tender_d_st-timestamp
*             WHERE submi = zmm_pur_tender_d_st-submi.
*  ENDCASE.
*Commented by CAB_SPYADAV : End

ENDFORM.                    " PREPARE_SAVING

*&---------------------------------------------------------------------*
*&      Form  save_data_tms
*&---------------------------------------------------------------------*
* Insert TMS data in TMS table - ZMM_TMS
*----------------------------------------------------------------------*
FORM save_data_tms.

  CLEAR : wa_zmm_tms.

  MOVE zmm_pur_tender_d_st-submi TO wa_zmm_tms-submi.

  MOVE-CORRESPONDING zmm_tms_general TO wa_zmm_tms.

*Methodology
  IF g_reg = 'X'.
    wa_zmm_tms-mthlogy = 'R'.
  ELSEIF g_spfc = 'X'.
    wa_zmm_tms-mthlogy = 'M'.
  ENDIF.

  MOVE-CORRESPONDING zmm_tms_tc      TO wa_zmm_tms.
  MOVE-CORRESPONDING zmm_tms_tb      TO wa_zmm_tms.
  MOVE-CORRESPONDING zmm_tms_pb      TO wa_zmm_tms.

*EPC tab should get disabled if EPC case is chosen as 'N'.
  IF zmm_tms_general-epc_typ NE 'N'. "Non-EPC
    MOVE-CORRESPONDING zmm_tms_epc     TO wa_zmm_tms.
  ENDIF.

**----------Start of change 27.06.2016 17:22:03 -------------------
  wa_zmm_tms-rel_stat = 'X' .
**----------End  of change 27.06.2016 17:22:03 -----------------



  MODIFY zmm_tms FROM wa_zmm_tms.

  IF sy-subrc = 0.
    g_ret_2 = 0.

    """""""""""""""""""""""""""""""""
    "added by lipsy on 9.05.2015  RD1K997136.

**----------Start of change 29.06.2016 15:06:24 REKHA  Commented to make automatic release  -------------------
**    UPDATE ZMM_TMS SET
**    REL_STAT = ''
**    WHERE SUBMI = ZMM_PUR_TENDER_D_ST-SUBMI.
**----------End  of change 29.06.2016 15:06:24 REKHA   -----------------


    "end of addition by lipsy on 9.05.2015 RD1K997136
    """""""""""""""""""""""""""""""""""""""""""
  ELSE.
    g_ret_2 = 4.
  ENDIF.

ENDFORM.                    "save_data_tms

*&---------------------------------------------------------------------*
*&      Form  update_data
*&---------------------------------------------------------------------*
*   To update existing records in detail tables
*          ZMM_PUR_TENDER_D
*          ZMM_TMS
*----------------------------------------------------------------------*
FORM update_data.

  CLEAR : g_ret_1,
          g_ret_2.

*-----Validation on Start Date of selling tender &
*                   Last Date of selling tender.
  PERFORM validate_date_req.
*-----Converts the date and time fields into time stamp format
  PERFORM oif_conv_date_time_ts.
*-----Save the Data in DB Table
  PERFORM save_data_tender ON COMMIT.

*Added by CAB_SPYADAV : Start
  PERFORM save_data_tms ON COMMIT.

  IF g_ret_1 = 0 AND g_ret_2 = 0.

*   IF   g_chg_flg = 'X' OR g_chg_spfc = 'X'.                    "-001
    IF   g_chg_flg = 'X' OR g_chg_spfc = 'X' OR g_chg_epc = 'X'. "+001
      PERFORM save_editor_data.
    ENDIF.

    PERFORM chng_doc_pr_rcpt_dt USING wa_zmm_tms-submi
                                      zmm_tms_general-pr_rcpt_dt
                                      g_pr_rcpt_dt.              "+007




    COMMIT WORK.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""added by lipsy on 26.02.2015 for tracking tc members changes RD1K995870
    CLEAR:wa_zmm_tms_tcn.
    MOVE-CORRESPONDING zmm_tms_tc  TO wa_zmm_tms_tcn.
*BREAK-POINT.
    PERFORM chng_doc_tc USING wa_zmm_tms-submi
                             wa_zmm_tms_tco
                             wa_zmm_tms_tcn.

    COMMIT WORK.


    """"""""""""""""""""""""""""""""""""""""""""
    "added by lipsy on 9.05.2015 for tracking pr changes  RD1K997136
    MOVE-CORRESPONDING zmm_pur_tender_d_st TO wa_tender_new.
    PERFORM chng_doc_tender_pr USING wa_zmm_tms-submi
                                     wa_tender_old
                                     wa_tender_new.
    COMMIT WORK.

    "end of addition by lipsy on 9.05.2015  for tracking pr changes   RD1K997136
    """"""""""""""""""""""""""""""""""""""""""""
    """""""""""""end of addition  by lipsy on 26.02.2015 for tracking tc members changes RD1K995870


    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870
*    PERFORM upd_purq_profile.                               "+008
    """""""end comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870
    MESSAGE i037(zmmpurtdr).                                "+001

* **----------Start of change 29.06.2016 15:09:18 REKHA for making release on create only  -------------------
*  MESSAGE I039(ZMMPURTDR).
* *----------End  of change 29.06.2016 15:09:18 REKHA  -----------------

    MESSAGE i947(zmm) WITH zmm_pur_tender_d_st-submi.
*   PERFORM clear_para.
  ELSE.
    ROLLBACK WORK.
*    PERFORM clear_para.
    MESSAGE e033(zpm).
  ENDIF.

  PERFORM unlock_record USING zmm_pur_tender_d_st-submi.

ENDFORM.                    "update_data

*&---------------------------------------------------------------------*
*&      Form  save_data_tender
*&---------------------------------------------------------------------*
* Modify tender data - ZMM_PUR_TENDER_D
*----------------------------------------------------------------------**----------------------------------------------------------------------*
FORM save_data_tender.

  MODIFY zmm_pur_tender_d FROM zmm_pur_tender_d_st.

  IF sy-subrc = 0.

    g_ret_1 = 0.

  ELSE.

    g_ret_1 = 4.

  ENDIF.

ENDFORM.                    "save_data_tender

*&---------------------------------------------------------------------*
*&      Form  oif_conv_date_time_ts
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM oif_conv_date_time_ts.
  DATA l_timestamp LIKE oifbbp1-ftmstm.

  CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
    EXPORTING
      i_datum           = sy-datum
      i_time            = sy-uzeit
    IMPORTING
      e_timestamp       = l_timestamp
    EXCEPTIONS
      date_not_received = 1
      time_not_received = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  zmm_pur_tender_d_st-timestamp = l_timestamp.

ENDFORM.                    " oif_conv_date_time_ts
*&---------------------------------------------------------------------*
*&      Form  validate_date_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_date_req.

  CHECK zmm_pur_tender_d_st-bsart+0(1) NE 'E'.

  IF zmm_pur_tender_d_st-tdrdt IS INITIAL.
    MESSAGE e027(zmmpurtdr).
  ENDIF.

  IF g_ok_code NE 'NEW'.                         "+008
    IF zmm_pur_tender_d_st-bsart+0(2) EQ 'MO'  OR
       zmm_pur_tender_d_st-bsart      EQ 'SGO' OR
       zmm_pur_tender_d_st-bsart EQ 'SOT'      OR
       zmm_pur_tender_d_st-bsart EQ 'MRCO'.

      """""""""""""""""""""""""""""""""""""""""""""""""
      "comment by lipsy  on 5.11.2014 FOR new validations in RD1K994950
*      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL OR
*         zmm_pur_tender_d_st-lt_sel_dt IS INITIAL.
*
*
*        PERFORM err_msg USING '008'.
*
*        endif.

      "end of comment by lipsy on 5.11.2014  FOR new validations in RD1K994950
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "add by lipsy on 5.11.2014 FOR new validations in RD1K994950

      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL
       AND  zmm_pur_tender_d_st-sch_st_sel_dt < sy-datum.
        PERFORM err_msg USING '008'.
      ENDIF.


      IF     zmm_pur_tender_d_st-lt_sel_dt IS INITIAL
       AND zmm_pur_tender_d_st-sch_lt_sel_dt < sy-datum.
        PERFORM err_msg USING '038'.

        "end of addition by lipsy on 5.11.2014 FOR new validations in RD1K994950
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      ENDIF.
    ENDIF.

    """"""""""""""
    "added by lipsy on 1.04.2015 ""RD1K995870
    IF  zmm_tms_pb-pr_bid_op_act_dt IS NOT INITIAL AND zmm_tms_tb-tend_op_act_dt IS NOT INITIAL.
      IF  zmm_tms_pb-pr_bid_op_act_dt LT zmm_tms_tb-tend_op_act_dt.
        PERFORM err_msg USING '040'.
      ENDIF.
    ENDIF.

    IF  zmm_tms_pb-pr_bid_op_act_dt IS NOT INITIAL AND zmm_tms_pb-loi_1_act_dt  IS NOT INITIAL.
      IF zmm_tms_pb-loi_1_act_dt LT zmm_tms_pb-pr_bid_op_act_dt.
        PERFORM err_msg USING '041'.
      ENDIF.
    ENDIF.
    "end of addition by lipsy on 1.04.2015 ""RD1K995870

    """""""""""""


  ENDIF.                                           "+008

*---Start NN 03.09.2003
  IF zmm_pur_tender_d_st-bsart = 'MLLM' OR
     zmm_pur_tender_d_st-bsart = 'MLLN' OR
     zmm_pur_tender_d_st-bsart = 'MLMM' OR
     zmm_pur_tender_d_st-bsart = 'MLMN' OR
     zmm_pur_tender_d_st-bsart = 'MRCM' OR
     zmm_pur_tender_d_st-bsart = 'MRCN' OR
     zmm_pur_tender_d_st-bsart = 'MSTA' OR
     zmm_pur_tender_d_st-bsart = 'SBP'  OR
     zmm_pur_tender_d_st-bsart = 'SGL'  OR
     zmm_pur_tender_d_st-bsart = 'SLT'  OR
     zmm_pur_tender_d_st-bsart = 'SST'.

    FIELD-SYMBOLS: <f1>.
    FIELD-SYMBOLS: <f2>.

    DATA : tabn(20)   TYPE c,
           fieldn(15) TYPE c,
           rc.
    tabn = 'ZMM_PUR_TENDER_D'.

    LOOP AT SCREEN.
      CHECK screen-group2 EQ 'DSP'.
      ASSIGN (screen-name) TO <f1>.
      IF NOT <f1> IS INITIAL.
        SEARCH screen-name FOR '-'.
        sy-fdpos = sy-fdpos + 1.
        ASSIGN screen-name+sy-fdpos(10) TO <f2>.
        MOVE <f2> TO fieldn.
        PERFORM get_ftext(rddfie00) USING tabn fieldn sy-langu
                                    CHANGING dfies rc.
        IF rc EQ 0.
          SET CURSOR FIELD fieldn LINE sy-stepl.
          MESSAGE e024(zmmpurtdr) WITH dfies-scrtext_m
                                       zmm_pur_tender_d_st-bsart.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*---End NN 03.09.2003
ENDFORM.                    " validate_date_req
*&---------------------------------------------------------------------*
*&      Form  err_msg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0264   text
*----------------------------------------------------------------------*
FORM err_msg USING    p_msgnr.

*+007 : Start
  DATA : l_dtyp TYPE t100c-msgts.

  IF g_ok_code = 'DISP'.
    l_dtyp = 'W'.
  ELSE.
    l_dtyp = 'E'.
  ENDIF.
*+007 : End

  CALL FUNCTION 'CUSTOMIZED_MESSAGE'
    EXPORTING
      i_arbgb = 'ZMMPURTDR'
*     i_dtype = 'E' "-007
      i_dtype = l_dtyp            "+007
      i_msgnr = p_msgnr.

ENDFORM.                    " err_msg
*&---------------------------------------------------------------------*
*&      Form  authority_check_tcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check_tcode.
  IF sy-tcode = 'ZMMTMSDISP'.
    g_tcode = 'ZMMTDR3'.
  ENDIF.
  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
    EXPORTING
*     tcode  = sy-tcode
      tcode  = g_tcode
    EXCEPTIONS
      ok     = 1
      not_ok = 2
      OTHERS = 3.
  IF sy-subrc <> 1.
*   MESSAGE e077(s#) WITH sy-tcode.
    MESSAGE e077(s#) WITH g_tcode.
  ENDIF.
ENDFORM.                    " authority_check_tcode
*&---------------------------------------------------------------------*
*&      Form  confirm_step
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_step.
  IF sy-tcode NE 'ZMMTDR3'.
    PERFORM  confirm_action  USING  text-200 text-201 g_action.
    IF g_action EQ '1'.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ELSE.
    IF sy-calld NE space.
      LEAVE.
    ELSE.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " confirm_step
*&---------------------------------------------------------------------*
*&      Form  confirm_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_200  text
*      -->P_TEXT_201  text
*      -->P_G_ACTION  text
*----------------------------------------------------------------------*
FORM confirm_action USING l_title  l_question l_action.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = l_title
      text_question         = l_question
      text_button_1         = 'Yes'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'No'
      icon_button_2         = 'ICON_REJECT'
      default_button        = '1'
      display_cancel_button = 'X'
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = g_action
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " confirm_action

*&---------------------------------------------------------------------*
*&      Form  set_editor
*&---------------------------------------------------------------------*
*      To invoke editor in change/display mode
*----------------------------------------------------------------------*
*      -->P_DMODE  Mode
*----------------------------------------------------------------------*
FORM set_editor  USING    p_dmode.
  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = g_dynnr
      controlname    = 'TMS_CUST_CTRL'
      max_cols       = 80
*     MAX_LINES      =
      show_tool      = ''
      show_status    = ''
*     STATUS_TEXT    = ''
      display_mode   = p_dmode
    TABLES
      lines          = ist_lines
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " set_editor

*&---------------------------------------------------------------------*
*&      Form  set_editor_spfc
*&---------------------------------------------------------------------*
*      To invoke editor in change/display mode
*----------------------------------------------------------------------*
*      -->P_DMODE  Mode
*----------------------------------------------------------------------*
FORM set_editor_spfc  USING    p_dmode.
  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = g_dynnr
      controlname    = 'TMS_CUST_CTRL_S'
      max_cols       = 80
*     MAX_LINES      =
      show_tool      = ''
      show_status    = ''
*     STATUS_TEXT    = ''
      display_mode   = p_dmode
    TABLES
      lines          = ist_lines_spfc
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " set_editor_spfc

*+001 : Start
*&---------------------------------------------------------------------*
*&      Form  set_editor_epc
*&---------------------------------------------------------------------*
*      To invoke editor in change/display mode
*----------------------------------------------------------------------*
*      -->P_DMODE  Mode
*----------------------------------------------------------------------*
FORM set_editor_epc  USING    p_dmode.

  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = g_dynnr
      controlname    = 'TMS_CUST_CTRL_E'
      max_cols       = 80
*     MAX_LINES      =
      show_tool      = ''
      show_status    = ''
*     STATUS_TEXT    = ''
      display_mode   = p_dmode
    TABLES
      lines          = ist_lines_epc
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " set_editor_epc
*+001 : End

*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR
*&---------------------------------------------------------------------*
*   To Get Editor Data
*----------------------------------------------------------------------*
*      -->P_CHNG - flag
*----------------------------------------------------------------------*
FORM get_editor  USING p_chng.

  DATA : l_chg(1).

  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'TMS_CUST_CTRL'
    IMPORTING
      changed        = l_chg
    TABLES
      lines          = ist_lines
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT p_chng IS INITIAL.
    g_chg_flg = l_chg.
  ENDIF.

ENDFORM.                    " GET_EDITOR

*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR_SPFC
*&---------------------------------------------------------------------*
*   To Get Editor Data
*----------------------------------------------------------------------*
*      -->P_CHNG - flag
*----------------------------------------------------------------------*
FORM get_editor_spfc  USING p_chng.

  DATA : l_chg(1).

  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'TMS_CUST_CTRL_S'
    IMPORTING
      changed        = l_chg
    TABLES
      lines          = ist_lines_spfc
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT p_chng IS INITIAL.
    g_chg_spfc = l_chg.
  ENDIF.

ENDFORM.                    " GET_EDITOR_SPFC

*+001 : Start
*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR_EPC
*&---------------------------------------------------------------------*
*   To Get Editor Data
*----------------------------------------------------------------------*
*      -->P_CHNG - flag
*----------------------------------------------------------------------*
FORM get_editor_epc  USING p_chng.

  DATA : l_chg(1).

  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'TMS_CUST_CTRL_E'
    IMPORTING
      changed        = l_chg
    TABLES
      lines          = ist_lines_epc
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT p_chng IS INITIAL.
    g_chg_epc = l_chg.
  ENDIF.

ENDFORM.                    " GET_EDITOR_EPC
*+001 : End

*&---------------------------------------------------------------------*
*&      Form  save_editor_data
*&---------------------------------------------------------------------*
*     To save editor Data
*----------------------------------------------------------------------*
FORM save_editor_data.

  REFRESH : ist_zmm_tmst.
  CLEAR   : wa_zmm_tmst.

  DELETE ist_lines WHERE vdata = ''.

  LOOP AT ist_lines.
    wa_zmm_tmst-submi    = zmm_pur_tender_d_st-submi.
    wa_zmm_tmst-tabseqnr = wa_zmm_tmst-tabseqnr + 1.
    wa_zmm_tmst-lttyp    = 'P'.
    MOVE ist_lines-vdata TO wa_zmm_tmst-tline.

    APPEND wa_zmm_tmst TO ist_zmm_tmst.
  ENDLOOP.

  SELECT SINGLE * FROM zmm_tmst
     WHERE submi = wa_zmm_tmst-submi AND
           lttyp = 'P'.

  IF sy-subrc = 0.                          " Update
    DELETE FROM zmm_tmst
             WHERE submi = wa_zmm_tmst-submi AND lttyp = 'P'.
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ELSE.                                     " Create
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ENDIF.

***********************************************************************
  REFRESH : ist_zmm_tmst.
  CLEAR   : wa_zmm_tmst.

  DELETE ist_lines_spfc WHERE vdata = ''.

  LOOP AT ist_lines_spfc.
    wa_zmm_tmst-submi    = zmm_pur_tender_d_st-submi.
    wa_zmm_tmst-tabseqnr = wa_zmm_tmst-tabseqnr + 1.
    wa_zmm_tmst-lttyp    = 'M'.
    MOVE ist_lines_spfc-vdata TO wa_zmm_tmst-tline.

    APPEND wa_zmm_tmst TO ist_zmm_tmst.
  ENDLOOP.

  SELECT SINGLE * FROM zmm_tmst
     WHERE submi = wa_zmm_tmst-submi AND
           lttyp = 'M'.

  IF sy-subrc = 0.                          " Update
    DELETE FROM zmm_tmst
             WHERE submi = wa_zmm_tmst-submi AND lttyp = 'M'.
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ELSE.                                     " Create
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ENDIF.

***********************************************************************
*+001 : Start : EPC long text
  REFRESH : ist_zmm_tmst.
  CLEAR   : wa_zmm_tmst.

  DELETE ist_lines_epc WHERE vdata = ''.

  LOOP AT ist_lines_epc.
    wa_zmm_tmst-submi    = zmm_pur_tender_d_st-submi.
    wa_zmm_tmst-tabseqnr = wa_zmm_tmst-tabseqnr + 1.
    wa_zmm_tmst-lttyp    = 'E'.
    MOVE ist_lines_epc-vdata TO wa_zmm_tmst-tline.

    APPEND wa_zmm_tmst TO ist_zmm_tmst.
  ENDLOOP.

  SELECT SINGLE * FROM zmm_tmst
     WHERE submi = wa_zmm_tmst-submi AND
           lttyp = 'E'.

  IF sy-subrc = 0.                          " Update
    DELETE FROM zmm_tmst
             WHERE submi = wa_zmm_tmst-submi AND lttyp = 'E'.
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ELSE.                                     " Create
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ENDIF.
*+001 : End

ENDFORM.                    " save_editor_data

*&---------------------------------------------------------------------*
*&      Form  get_editor_data
*&---------------------------------------------------------------------*
*   To fetch data from Transparent table ZMM_TMST - Editor
*----------------------------------------------------------------------*
*      -->P_SUBMI  Tender No.
*----------------------------------------------------------------------*
FORM get_editor_data USING p_submi.

  REFRESH : ist_lines,
            ist_lines_spfc.

  REFRESH : ist_lines_epc.                                  "+001

*TMS : Long text - Price Bid
  SELECT * FROM zmm_tmst INTO TABLE ist_zmm_tmst
     WHERE submi = p_submi.

  IF sy-subrc = 0.
    LOOP AT ist_zmm_tmst INTO wa_zmm_tmst
                              WHERE lttyp = 'P'.
      MOVE wa_zmm_tmst-tline TO ist_lines-vdata.
      APPEND ist_lines.
    ENDLOOP.
  ENDIF.

*TMS : Long text - General Methodology : Specfic
  LOOP AT ist_zmm_tmst INTO wa_zmm_tmst
                            WHERE lttyp = 'M'.
    MOVE wa_zmm_tmst-tline TO ist_lines_spfc-vdata.
    APPEND ist_lines_spfc.
  ENDLOOP.

*+001 : Start
*TMS : Long text - EPC
  LOOP AT ist_zmm_tmst INTO wa_zmm_tmst
                            WHERE lttyp = 'E'.
    MOVE wa_zmm_tmst-tline TO ist_lines_epc-vdata.
    APPEND ist_lines_epc.
  ENDLOOP.
*+001 : End

  REFRESH : ist_zmm_tmst.

  CLEAR   : wa_zmm_tmst.

ENDFORM.                    " get_editor_data

*&---------------------------------------------------------------------*
*&      Form  CHK_SCH_ACT_DATE
*&---------------------------------------------------------------------*
* To validate scheduled & actual date
*----------------------------------------------------------------------*
*      -->P_SCH_DT     Scheduled date
*      -->P_ACT_DT     Actual date
*      -->P_SCH_DT_FN  Scheduled date : Dynpro field name
*      -->P_ACT_DT_FN  Actual date : Dynpro field name
*----------------------------------------------------------------------*
FORM chk_sch_act_date  USING    p_sch_dt
                                p_act_dt
                                p_sch_dt_fn
                                p_act_dt_fn.

************************************************************************
*  IF NOT p_sch_dt IS INITIAL.
*
*    IF p_sch_dt GT sy-datum.
*
*      SET CURSOR FIELD p_sch_dt_fn.
*
*      MESSAGE e028(zmmpurtdr).
*
*    ENDIF.
*
*    IF NOT p_act_dt IS INITIAL.
*
*      IF p_act_dt LT p_sch_dt.
*
*        SET CURSOR FIELD p_act_dt_fn.
*
*        MESSAGE e030(zmmpurtdr).
*
*      ENDIF.
*
*    ENDIF.
*
*  ELSE.
*
*    IF NOT p_act_dt IS INITIAL.
*
*      SET CURSOR FIELD p_sch_dt_fn.
*
*      MESSAGE e029(zmmpurtdr).
*
*    ENDIF.
*
*  ENDIF.
***********************************************************************

***********************************************************************
  IF NOT p_act_dt IS INITIAL.

    IF p_act_dt GT sy-datum.

      SET CURSOR FIELD p_act_dt_fn.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
      IF g_ok_code = 'DISP'.

      ELSE.

        "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        MESSAGE e031(zmmpurtdr).


        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """ADDED BY LIPSY ON 30.10.2014  FOR removing error in display mode RD1K994950

      ENDIF.
      "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ENDIF.

    IF p_sch_dt IS INITIAL.

      SET CURSOR FIELD p_sch_dt_fn.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
      IF g_ok_code = 'DISP'.

      ELSE.

        "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        MESSAGE e029(zmmpurtdr).
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """ADDED BY LIPSY ON 30.10.2014  FOR removing error in display mode RD1K994950

      ENDIF.
      "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

  ENDIF.
***********************************************************************

ENDFORM.                    " CHK_SCH_ACT_DATE

*&---------------------------------------------------------------------*
*&      Form  attach_files
*&---------------------------------------------------------------------*
* To attach files in tender document
*----------------------------------------------------------------------*
FORM attach_files.

  REFRESH : ist_att_files.
  CLEAR   : wa_att_files.

  wa_att_files-logsys  = zmm_pur_tender_d_st-submi.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

  APPEND wa_att_files TO ist_att_files.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
    EXPORTING
      attachment_data     = ''
      attachment_type     = 'DOC'
    TABLES
      application_objects = ist_att_files.


ENDFORM.                    " attach_files

*&---------------------------------------------------------------------*
*&      Form  list_files
*&---------------------------------------------------------------------*
* To display list of files attached in the tender document
*----------------------------------------------------------------------*
FORM list_files.

  CLEAR   : wa_att_files.

  wa_att_files-logsys  = zmm_pur_tender_d_st-submi.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = wa_att_files.

ENDFORM.                    " list_files

*&---------------------------------------------------------------------*
*&      Form  disp_process_guide
*&---------------------------------------------------------------------*
* To display process guide - TMS
*----------------------------------------------------------------------*
FORM disp_process_guide USING p_logsys.

  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.

  CLEAR : wa_att_files.

  wa_att_files-logsys  = p_logsys.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

  REFRESH ist_exclude_tab[].
  MOVE 'ENTR' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CHNG' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CREA' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'DELE' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'IMPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'EXPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'OLNK' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'PRIN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'COPY' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'HGEN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'REFL' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'MOVE' TO ist_exclude_tab. APPEND ist_exclude_tab.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = wa_att_files
    TABLES
      func_exclude       = ist_exclude_tab.

ENDFORM.                    " disp_process_guide
*&---------------------------------------------------------------------*
*&      Form  READ_TEXT
*&---------------------------------------------------------------------*
*  To tender process / tender type text
*----------------------------------------------------------------------*
*      -->P_DNAME Domain name
*      -->P_PROC  Tender process / Type
*      <--P_text  text
*----------------------------------------------------------------------*
FORM read_text  USING    p_dname
                         p_proc
                CHANGING p_text.

  DATA : wa_dd07v TYPE dd07v,
         l_value  TYPE dd07l-domvalue_l.

  MOVE p_proc TO l_value.

  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
    EXPORTING
      domname  = p_dname
      value    = l_value
      langu    = sy-langu
    IMPORTING
      dd07v_wa = wa_dd07v.

  MOVE wa_dd07v-ddtext TO p_text.

ENDFORM.                    " READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  CHK_ACT_DATE
*&---------------------------------------------------------------------*
* To check actual date : EPC : Screen 0800
*----------------------------------------------------------------------*
FORM chk_act_date .

* Date of submission of EPC agenda for endorsement by Director
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_agnda_act_dt
                                 'ZMM_TMS_EPC-EPC_AGNDA_ACT_DT'.

* Date of Endorsement by Concerned Director
  PERFORM chk_epc_act_date USING zmm_tms_epc-dr_endors_act_dt
                                 'ZMM_TMS_EPC-DR_ENDORS_ACT_DT'.

* Date of submission of Agenda in EPC cell
  PERFORM chk_epc_act_date USING zmm_tms_epc-agnd_sub_act_dt
                                 'ZMM_TMS_EPC-AGND_SUB_ACT_DT'.
* Date of EPC meeting
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_meet_act_dt
                                 'ZMM_TMS_EPC-EPC_MEET_ACT_DT'.

* Date of receipt of summary minutes of EPC meeting
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_smr_act_dt
                                 'ZMM_TMS_EPC-EPC_SMR_ACT_DT'.

* Date of receipt of summary note from EPC
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_smrn_act_dt
                                 'ZMM_TMS_EPC-EPC_SMRN_ACT_DT'.
*+001 : Start
* Date of last EPC meeting
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_fmeet_act_dt
                                 'ZMM_TMS_EPC-EPC_FMEET_ACT_DT'.
*+001 : End
ENDFORM.                    " CHK_ACT_DATE

*&---------------------------------------------------------------------*
*&      Form  CHK_EPC_ACT_DATE
*&---------------------------------------------------------------------*
* To validate EPC actual date
*----------------------------------------------------------------------*
*      -->P_ACT_DT     Actual date
*      -->P_ACT_DT_FN  Actual date : Dynpro field name
*----------------------------------------------------------------------*
FORM chk_epc_act_date  USING    p_act_dt
                                p_act_dt_fn.
  IF NOT p_act_dt IS INITIAL.

    IF p_act_dt GT sy-datum.

      SET CURSOR FIELD p_act_dt_fn.

      MESSAGE e031(zmmpurtdr).

    ENDIF.

  ENDIF.

ENDFORM.                    " CHK_EPC_ACT_DATE

*&---------------------------------------------------------------------*
*&      Form  CHK_DUP_TC_MEM
*&---------------------------------------------------------------------*
* * To check duplicate TC Member (With other TC Member)
*----------------------------------------------------------------------*
*      -->P_TC_MEMBER1   TC Member
*      -->P_TC_MEMBER1_F TC_Member field
*      -->P_TC_MEMBER2  TC Member
*      -->P_TC_MEMBER2_F TC_Member field
*      -->P_TC_MEMBER3  TC Member
*      -->P_TC_MEMBER3_F TC_Member field
*      -->P_TC_MEMBER4  TC Member
*      -->P_TC_MEMBER4_F TC_Member field
*      -->P_TC_MEMBER5  TC Member
*      -->P_TC_MEMBER5_F TC_Member field
*----------------------------------------------------------------------*
FORM chk_dup_tc_mem  USING    p_tc_member1
                              p_tc_member1_f
                              p_tc_member2
                              p_tc_member2_f
                              p_tc_member3
                              p_tc_member3_f
                              p_tc_member4
                              p_tc_member4_f
                              p_tc_member5
                              p_tc_member5_f.

  IF NOT p_tc_member2 IS INITIAL AND
         p_tc_member1 = p_tc_member2.

    SET CURSOR FIELD p_tc_member2_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member3 IS INITIAL AND
         p_tc_member1 = p_tc_member3.

    SET CURSOR FIELD p_tc_member3_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member4 IS INITIAL AND
         p_tc_member1 = p_tc_member4.

    SET CURSOR FIELD p_tc_member4_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member5 IS INITIAL AND
         p_tc_member1 = p_tc_member5.

    SET CURSOR FIELD p_tc_member5_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

ENDFORM.                    " CHK_DUP_TC_MEM

*&---------------------------------------------------------------------*
*&      Form  CHK_DUP_SUB_TC_MEM
*&---------------------------------------------------------------------*
* To check duplicate substitute TC member (with TC member)
*----------------------------------------------------------------------*
*      -->P_TC_MEMBER_S   Substitute TC member
*      -->P_TC_MEMBER_SF  Substitute TC member field
*      -->P_TC_MEMBER2    TC member
*      -->P_TC_MEMBER3    TC member
*      -->P_TC_MEMBER4    TC member
*      -->P_TC_MEMBER5    TC member
*----------------------------------------------------------------------*
FORM chk_dup_sub_tc_mem  USING    p_tc_member_s
                                  p_tc_member_sf
                                  p_tc_member2
                                  p_tc_member3
                                  p_tc_member4
                                  p_tc_member5.

  IF NOT p_tc_member2 IS INITIAL AND
         p_tc_member_s = p_tc_member2.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member3 IS INITIAL AND
         p_tc_member_s = p_tc_member3.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member4 IS INITIAL AND
         p_tc_member_s = p_tc_member4.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member5 IS INITIAL AND
         p_tc_member_s = p_tc_member5.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

ENDFORM.                    " CHK_DUP_SUB_TC_MEM

*&---------------------------------------------------------------------*
*&      Form  CHK_AUTHORITY
*&---------------------------------------------------------------------*
* To check authorized user
*----------------------------------------------------------------------*
*      -->P_UNAME  User name
*      -->P_SYCOD  User action
*----------------------------------------------------------------------*
FORM chk_authority  USING    p_uname
                             p_sycod.

  DATA : l_agr_name TYPE agr_users-agr_name.
  IF p_uname+0(1) <> 'C'.
    IF ( p_sycod = 'DISP' OR p_sycod = 'REP' ).
      SELECT AGR_NAME FROM AGR_USERS INTO L_AGR_NAME UP TO 1 ROWS
 WHERE ( AGR_NAME = TEXT-017 ) AND UNAME = P_UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc NE 0 AND l_agr_name IS INITIAL.

        CASE p_sycod.
          WHEN 'NEW'.
            MESSAGE e043(zpm) WITH text-009.
          WHEN 'CHNG'.
            MESSAGE e043(zpm) WITH text-010.
          WHEN 'DISP'.
            MESSAGE e043(zpm) WITH text-011.
          WHEN 'APRV'.
            MESSAGE e043(zpm) WITH text-012.
        ENDCASE.

      ENDIF.
    ELSE.
      SELECT AGR_NAME FROM AGR_USERS INTO L_AGR_NAME UP TO 1 ROWS
 WHERE ( AGR_NAME = TEXT-007 OR AGR_NAME = TEXT-008 ) AND UNAME = P_UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc NE 0 AND l_agr_name IS INITIAL.

        CASE p_sycod.
          WHEN 'NEW'.
            MESSAGE e043(zpm) WITH text-009.
          WHEN 'CHNG'.
            MESSAGE e043(zpm) WITH text-010.
          WHEN 'DISP'.
            MESSAGE e043(zpm) WITH text-011.
          WHEN 'APRV'.
            MESSAGE e043(zpm) WITH text-012.
        ENDCASE.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHK_AUTHORITY
*&---------------------------------------------------------------------*
*&      Form  UPD_REL_STATUS
*&---------------------------------------------------------------------*
* To update TMS release status : DB table ZMM_TMS
*----------------------------------------------------------------------*
FORM upd_rel_status .

**----------Start of change 29.06.2016 14:55:25 -------------------
** PERFORM CHK_TMS_REQ_DATA.
**----------End  of change 29.06.2016 14:55:25 -----------------


  IF ist_mesg[] IS INITIAL.

    UPDATE zmm_tms
         SET rel_stat = 'X'
            WHERE submi = zmm_pur_tender_d_st-submi.

    IF sy-subrc EQ 0.

      COMMIT WORK.
      MESSAGE i962(zmm) WITH zmm_pur_tender_d_st-submi.

      """""""""""""""""""""""""""""""""""""""""""""""
      """""""""""""added by lipsy on 26.02.2015 for tracking tc members changes RD1K995870

      CLEAR:wa_zmm_tms_tcn.
      v_rel_new = 'X'.
      PERFORM chng_doc_tc USING wa_zmm_tms-submi
                               wa_zmm_tms_tco
                               wa_zmm_tms_tcn.

      COMMIT WORK.
      """""""""""""end of addition  by lipsy on 26.02.2015 for tracking tc members changes RD1K995870


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""


      PERFORM unlock_record USING zmm_pur_tender_d_st-submi.

    ELSE.
      ROLLBACK WORK.
      MESSAGE e033(zpm).
    ENDIF.

  ENDIF.

ENDFORM.                    " UPD_REL_STATUS

*&---------------------------------------------------------------------*
*&      Form  CHK_TMS_REQ_DATA
*&---------------------------------------------------------------------*
* To check all mandatory fields before releasing tender document
* - Tender Status
* - Opening of price bids
* - Technical Bid Opening
*----------------------------------------------------------------------*
FORM chk_tms_req_data .

  DATA : l_lineno LIKE mesg-zeile.

  REFRESH : ist_mesg.

*+006 : Start
  IF zmm_pur_tender_d_st-banfn IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '974'.
    ist_mesg-msgv1 = text-057.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.
*+006 : End

*+005 : Start
  IF zmm_tms_general-pr_rcpt_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '972'.
    ist_mesg-msgv1 = text-018.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.
*+005 : End

  IF zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '960'.
    ist_mesg-msgv1 = text-013.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 10.03.2015 for loi date  RD1K995870
  IF zmm_tms_pb-loi_1_act_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM_OTH'.
    ist_mesg-msgno = '162'.
    ist_mesg-msgv1 = text-061.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.



  "end of addition by lipsy on 10.03.2015 for loi date  RD1K995870
  """"""""""""""""""""""""""""""""""""""""""""""""""""



  IF zmm_tms_tb-tend_op_act_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '961'.
    ist_mesg-msgv1 = text-014.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.

*+007 : Start
*+009 : Start
  IF zmm_tms_general-epc_typ = 'E'. "BEC approved by the EPC
  ELSE.
*+009 : End
    IF zmm_tms_tc-cpa IS INITIAL.

      ist_mesg-msgty = 'E'.
      ist_mesg-msgid = 'ZMM'.
      ist_mesg-msgno = '981'.
      ist_mesg-msgv1 = text-058.

      l_lineno = l_lineno + 1.
      ist_mesg-lineno = l_lineno.

      APPEND ist_mesg.

    ENDIF.

  ENDIF.                                         "+009

  IF zmm_tms_tc-tc_stat = 'X' AND
     zmm_tms_tc-tc_member1 IS INITIAL AND
     zmm_tms_tc-tc_member2 IS INITIAL AND
     zmm_tms_tc-tc_member3 IS INITIAL.

    ist_mesg-msgty = 'E'.

    """""""""""""""""""""""""""""""""""
    "comment by lipsy on 10.03.2015 for loi date  RD1K995870
*    ist_mesg-msgid = 'ZMM'.

    """"""""""""""""""""""""""""""""""""
    "comment by lipsy on 10.03.2015 for loi date  RD1K995870
*    ist_mesg-msgno = '981'.
    "end of comment by lipsy on 10.03.2015  for loi date  RD1K995870
    """"""""""""""""""""""""""""""""""
    """"""
    """"""""""""""""""""""""""""""
*    "add by lipsy on 10.03.2015  for 3 tc members  RD1K995870
    ist_mesg-msgid = 'ZMM_OTH'.
    ist_mesg-msgno = '238'.
*    "end of addition by lipsy on 10.03.2015  for 3 tc members   RD1K995870

    """"""""""""""""""""""""""""""""""
    """"""""""
    """"""""""""""""""""""""""""""""""""""""

    ist_mesg-msgv1 = text-059.

    """""""""""""""""""""""""""""""""""



    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.

*+007 : End
  IF NOT ist_mesg[] IS INITIAL.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = ist_mesg.

  ENDIF.

ENDFORM.                    " CHK_TMS_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  FILL_SVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sval .
*+006 : Start
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
    CLEAR it_sval-field_attr.
  ELSE.
    it_sval-field_attr = '02'. "Display mode
  ENDIF.
*+006 " End

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN2'.
* it_sval-fieldtext  = 'PR2'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn2.  "+006
  it_sval-fieldtext  = 'Purchase Req.(2)'.          "+006
  it_sval-field_obl  = ''.

  APPEND it_sval.

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN3'.
* it_sval-fieldtext  = 'PR3'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn3.  "+006
  it_sval-fieldtext  = 'Purchase Req.(3)'.          "+006
  it_sval-field_obl  = ''.
  APPEND it_sval.

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN4'.
* it_sval-fieldtext  = 'PR4'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn4.  "+006
  it_sval-fieldtext  = 'Purchase Req.(4)'.          "+006
  it_sval-field_obl  = ''.
  APPEND it_sval.

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN5'.
* it_sval-fieldtext  = 'PR5'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn5.  "+006
  it_sval-fieldtext  = 'Purchase Req.(5)'.          "+006
  it_sval-field_obl  = ''.
  APPEND it_sval.
ENDFORM.                    " FILL_SVAL
*&---------------------------------------------------------------------*
*&      Form  READ_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1400   text
*      -->P_ZMM_PUR_TENDER_D_ST_BANFN  text
*      -->P_1402   text
*      <--P_ZMM_TMS_GENERAL_PR_FF_REL_DT  text
*----------------------------------------------------------------------*
FORM read_change_doc  USING  p_class
                             p_objectid
                             p_fname
                      CHANGING p_zdate.
*+007 : Start
  DATA : ist_cdhdr    TYPE TABLE OF cdhdr,
         ist_cdpos    TYPE TABLE OF cdpos,
         ist_cdpos_po TYPE TABLE OF cdpos,
         wa_cdpos     TYPE cdpos,
         wa_cdhdr     TYPE cdhdr.
*+007 : End

  CLEAR : ist_cdpos, wa_cdpos,ist_cdhdr,wa_cdhdr.
  REFRESH : ist_cdpos, ist_cdhdr.
  SELECT * FROM cdpos
    INTO CORRESPONDING FIELDS OF TABLE ist_cdpos
    WHERE   objectclas EQ p_class AND
                 objectid EQ p_objectid AND
                  fname EQ p_fname ORDER BY PRIMARY KEY.
  SORT ist_cdpos ASCENDING BY changenr.
  IF p_fname = 'FRGKE'.
    LOOP AT ist_cdpos INTO wa_cdpos
      WHERE value_new = 'S'.
      APPEND wa_cdpos TO ist_cdpos_po.
    ENDLOOP.
    ist_cdpos[] = ist_cdpos_po[].
    SORT ist_cdpos ASCENDING BY changenr.
  ENDIF.
  READ TABLE ist_cdpos INTO wa_cdpos INDEX 1.
  SELECT * FROM cdhdr
  INTO CORRESPONDING FIELDS OF TABLE ist_cdhdr
  WHERE   objectclas EQ  p_class AND
               objectid EQ p_objectid AND
                changenr EQ wa_cdpos-changenr.


  READ TABLE ist_cdhdr INTO wa_cdhdr INDEX 1.
  p_zdate = wa_cdhdr-udate.
ENDFORM.                    " READ_CHANGE_DOC

*&---------------------------------------------------------------------*
*&      Form  calc_various_dates
*&---------------------------------------------------------------------*
* To calculate various dates based on PR Receipt Date
*----------------------------------------------------------------------*
*      -->P_TEND_TYP   Tender Type
*      -->P_PR_RCPTDT  PR Receipt Date
*----------------------------------------------------------------------*
FORM calc_various_dates USING  p_tend_typ
                               p_pr_rcptdt.

  DATA : l_tval_stat(1).

  IF p_tend_typ = 'C'.             "Open Tender

*Approval of Dir/EPC required
*Approval of BEC &MQC
    IF zmm_tms_general-epc_typ = 'E'. "EPC

      zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 28. "33.

    ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

      zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 13.

    ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

      zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 18.

    ENDIF.

* Scheduled Tender date (NIT Date) i.e.
* NIT scheduled date field = zmm_pur_tender_d_st-sch_tdrdt
    zmm_pur_tender_d_st-sch_tdrdt = zmm_tms_tc-tc_aprv_sch_dt + 7.

*Scheduled tender sale opening
    zmm_pur_tender_d_st-sch_st_sel_dt = zmm_pur_tender_d_st-sch_tdrdt.

*Scheduled tender sale closing
    zmm_pur_tender_d_st-sch_lt_sel_dt
                                   = zmm_pur_tender_d_st-sch_tdrdt + 21.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
    PERFORM set_pre_bid_dt USING    zmm_tms_tc-pbc_stat
                                    zmm_pur_tender_d_st-sch_lt_sel_dt
                                    zmm_tms_general-lstk
                           CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                    zmm_tms_tc-pbc_sch_dt
                                    zmm_tms_tc-tc_met_pb_sch_dt
                                    zmm_tms_tc-reo_tsal_stat
                                    zmm_tms_tc-amd_issu_sch_dt
                                    zmm_tms_tc-reo_tsal_sch_dt
                                    zmm_tms_tc-rec_tsal_sch_dt
                                    zmm_tms_tc-subm_dl_sch_dt.

    IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
      zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
      zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt + 4.

*Scheduled CS vetting date
      zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 4.

*Scheduled bid forwarding to indentor
      zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt + 1.

*Scheduled date of receipt of technical comments
      zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt + 7.

*Scheduled TCs for techno-commerical bid evaluation
      zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 8.

*Scheduled date of approval of tc meeting for shortlisting of bids
      IF zmm_tms_tb-no_rnd_clrf = 0.

        zmm_tms_tb-sb_tc_apv_sch_dt = zmm_tms_tb-tbid_eval_sch_dt + 3.

      ELSE.

        zmm_tms_tb-sb_tc_apv_sch_dt = zmm_tms_tb-tbid_eval_sch_dt +
                              ( zmm_tms_tb-no_rnd_clrf * 20 ).

      ENDIF.

*Scheduled opening of price bids
      zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 5.

*Scheduled CS preparation date
      zmm_tms_pb-cs_prep_dt_sch = zmm_tms_pb-pr_bid_op_sch_dt + 3.

*Scheduled CS vetting date
      zmm_tms_pb-cs_vett_dt_sch = zmm_tms_pb-cs_prep_dt_sch + 4.

*Scheduled date of final TC (for award)
      zmm_tms_pb-tc_awrd_sch_dt = zmm_tms_pb-cs_vett_dt_sch + 5.

*Scheduled date of approval of award
      IF zmm_tms_pb-epc_typ_pb EQ zmm_tms_general-epc_typ.

        IF zmm_tms_general-epc_typ = 'E'. "EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

        ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

        ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

        ENDIF.

      ELSE.

        IF zmm_tms_pb-epc_typ_pb = 'E'. "EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

        ELSEIF zmm_tms_pb-epc_typ_pb = 'D'. "Director

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

        ELSEIF zmm_tms_pb-epc_typ_pb = 'N'. "Non-EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

        ENDIF.

      ENDIF.

*Scheduled date of first LOI
      IF NOT zmm_tms_pb-aprv_awrd_sch_dt IS INITIAL.

        zmm_tms_pb-loi_1_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 1.

*Scheduled date of EMD release of unsuccessful bidder(s)
        zmm_tms_pb-emd_rel_ub_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 7.

      ENDIF.

*Scheduled date of receipt of PBG
      IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

        zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

      ENDIF.

    ENDIF.

  ELSEIF p_tend_typ = 'L'.             "Limited Tender

*Tender Value Status
    IF zmm_pur_tender_d_st-tndr_val GT 2500000.

      l_tval_stat = 'A'.

    ELSEIF zmm_pur_tender_d_st-tndr_val BETWEEN 500000 AND 2500000.

      l_tval_stat = 'B'.

    ELSE.

      l_tval_stat = 'C'.

    ENDIF.

    CASE l_tval_stat.

      WHEN 'A'.           "Tender value more than 2500000
*Approval of Dir/EPC required
*Approval of BEC &MQC
        IF zmm_tms_general-epc_typ = 'E'. "EPC

          zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 28.

        ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

          zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 13.

        ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

          zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 18.

        ENDIF.

*Scheduled Tender date
        zmm_pur_tender_d_st-sch_tdrdt = zmm_tms_tc-tc_aprv_sch_dt + 7.

*Scheduled request for tender enquiries from bidders
        zmm_tms_tc-tnd_enq_sch_dt = zmm_pur_tender_d_st-sch_tdrdt + 10.

*Scheduled verification & issue of tender to bidders
        zmm_tms_tc-verf_iss_sch_dt = zmm_tms_tc-tnd_enq_sch_dt + 6.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
        PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                        zmm_pur_tender_d_st-tndr_val
                                        zmm_pur_tender_d_st-sch_tdrdt
                                        zmm_tms_tc-verf_iss_sch_dt
                                        zmm_tms_general-lstk
                               CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                        zmm_tms_tc-pbc_sch_dt
                                        zmm_tms_tc-amd_issu_sch_dt
                                        zmm_tms_tc-subm_dl_sch_dt.

        IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
          zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
          zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt + 4.

*Scheduled CS vetting date
          zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 4.

*Scheduled bid forwarding to indentor
          zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt + 1.

*Scheduled date of receipt of technical comments
          zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt + 7.

*Scheduled TCs for techno-commerical bid evaluation
          zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 8.

*Scheduled date of approval of tc meeting for shortlisting of bids
          IF zmm_tms_tb-no_rnd_clrf IS INITIAL.

            zmm_tms_tb-sb_tc_apv_sch_dt
                    = zmm_tms_tb-tbid_eval_sch_dt + 3.

          ELSE.

            zmm_tms_tb-sb_tc_apv_sch_dt
                      = zmm_tms_tb-tbid_eval_sch_dt +
                        ( zmm_tms_tb-no_rnd_clrf * 20 ).

          ENDIF.

*Scheduled opening of price bids
          zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 5.

*Scheduled CS preparation date
          zmm_tms_pb-cs_prep_dt_sch = zmm_tms_pb-pr_bid_op_sch_dt + 3.

*Scheduled CS vetting date
          zmm_tms_pb-cs_vett_dt_sch = zmm_tms_pb-cs_prep_dt_sch + 4.

*Scheduled date of final TC (for award)
          zmm_tms_pb-tc_awrd_sch_dt = zmm_tms_pb-cs_vett_dt_sch + 5.

*Scheduled date of approval of award
          IF zmm_tms_pb-epc_typ_pb EQ zmm_tms_general-epc_typ.

            IF zmm_tms_general-epc_typ = 'E'. "EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

            ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

            ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

            ENDIF.

          ELSE.

            IF zmm_tms_pb-epc_typ_pb = 'E'. "EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

            ELSEIF zmm_tms_pb-epc_typ_pb = 'D'. "Director

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

            ELSEIF zmm_tms_pb-epc_typ_pb = 'N'. "Non-EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

            ENDIF.

          ENDIF.

*Scheduled date of first LOI
          IF NOT zmm_tms_pb-aprv_awrd_sch_dt IS INITIAL.

            zmm_tms_pb-loi_1_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 1.

*Scheduled date of EMD release of unsuccessful bidder(s)
            zmm_tms_pb-emd_rel_ub_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 7.

          ENDIF.

*Scheduled date of receipt of PBG
          IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

            zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

          ENDIF.

        ENDIF.

      WHEN 'B'.   "Tender Value between 500000 and 2500000

*Approval of BEC &MQC
        zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 10.

*Scheduled Tender date
        zmm_pur_tender_d_st-sch_tdrdt = zmm_tms_tc-tc_aprv_sch_dt + 5.

*Scheduled request for tender enquiries from bidders
        zmm_tms_tc-tnd_enq_sch_dt = zmm_pur_tender_d_st-sch_tdrdt + 10.

*Scheduled verification & issue of tender to bidders
        zmm_tms_tc-verf_iss_sch_dt = zmm_tms_tc-tnd_enq_sch_dt + 6.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
        PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                        zmm_pur_tender_d_st-tndr_val
                                        zmm_pur_tender_d_st-sch_tdrdt
                                        zmm_tms_tc-verf_iss_sch_dt
                                        zmm_tms_general-lstk
                               CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                        zmm_tms_tc-pbc_sch_dt
                                        zmm_tms_tc-amd_issu_sch_dt
                                        zmm_tms_tc-subm_dl_sch_dt.

        IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
          zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
          zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt + 4.

*Scheduled CS vetting date
          zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 4.

*Scheduled bid forwarding to indentor
          zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt + 1.

*Scheduled date of receipt of technical comments
          zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt + 7.

*Scheduled TCs for techno-commerical bid evaluation
          zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 8.

*Scheduled date of approval of tc meeting for shortlisting of bids
          IF zmm_tms_tb-no_rnd_clrf IS INITIAL.

            zmm_tms_tb-sb_tc_apv_sch_dt
                      = zmm_tms_tb-tbid_eval_sch_dt + 2.

          ELSE.

            zmm_tms_tb-sb_tc_apv_sch_dt
                      = zmm_tms_tb-tbid_eval_sch_dt +
                        ( zmm_tms_tb-no_rnd_clrf * 20 ).
          ENDIF.

          CLEAR : "zmm_tms_pb-pr_bid_op_sch_dt,       "-009
                  zmm_tms_pb-cs_prep_dt_sch,
                  zmm_tms_pb-cs_vett_dt_sch,
                  zmm_tms_pb-tc_awrd_sch_dt,
                  zmm_tms_pb-aprv_awrd_sch_dt.

*+009 : Start
* Schedule Price bid opening date should be equal to schedule Technical
* Bid Opening date
          zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-tend_op_sch_dt.
*+009 : End

*Scheduled date of first LOI
          IF NOT zmm_tms_tb-sb_tc_apv_sch_dt IS INITIAL.

            zmm_tms_pb-loi_1_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 1.

          ENDIF.

*Scheduled date of receipt of PBG
          IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

            zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

          ENDIF.

        ENDIF.

      WHEN 'C'.   "Tender Value less than 500000

        CLEAR : zmm_tms_tc-tc_aprv_sch_dt,
                zmm_tms_tc-tnd_enq_sch_dt,
                zmm_tms_tc-verf_iss_sch_dt.

*Scheduled Tender date
        zmm_pur_tender_d_st-sch_tdrdt = p_pr_rcptdt.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
        PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                        zmm_pur_tender_d_st-tndr_val
                                        zmm_pur_tender_d_st-sch_tdrdt
                                        zmm_tms_tc-verf_iss_sch_dt
                                        zmm_tms_general-lstk
                               CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                        zmm_tms_tc-pbc_sch_dt
                                        zmm_tms_tc-amd_issu_sch_dt
                                        zmm_tms_tc-subm_dl_sch_dt.

        IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
          zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
          zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt. "+ 4.

*Scheduled CS vetting date
          zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 1. "4.

*Scheduled bid forwarding to indentor
          zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt. " + 1.

*Scheduled date of receipt of technical comments
          zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt. "+ 7.

*Scheduled TCs for techno-commerical bid evaluation
          zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 2. "8.


*Scheduled date of approval of tc meeting for shortlisting of bids
          zmm_tms_tb-sb_tc_apv_sch_dt
                                = zmm_tms_tb-tbid_eval_sch_dt + 2.

          CLEAR : "zmm_tms_pb-pr_bid_op_sch_dt,  "-008
                  zmm_tms_pb-cs_prep_dt_sch,
                  zmm_tms_pb-cs_vett_dt_sch,
                  zmm_tms_pb-tc_awrd_sch_dt,
                  zmm_tms_pb-aprv_awrd_sch_dt.

*+008 : Start
* Schedule Price bid opening date should be equal to schedule Technical
* Bid Opening date
          zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-tend_op_sch_dt.
*+008 : End

*Scheduled date of first LOI
          IF NOT zmm_tms_tb-sb_tc_apv_sch_dt IS INITIAL.

            zmm_tms_pb-loi_1_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 1.

          ENDIF.

*Scheduled date of receipt of PBG
          IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

            zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

          ENDIF.

        ENDIF.

    ENDCASE.

*+008 : Logic for Single tender/Board Purchase  : Start
* To get various dates based on PR Receipt Date
  ELSEIF p_tend_typ = 'S' OR             "Single Tender
         p_tend_typ = 'B'.               "Board Purchase

    CLEAR : zmm_tms_tc-tc_aprv_sch_dt,
            zmm_tms_tc-tnd_enq_sch_dt,
            zmm_tms_tc-verf_iss_sch_dt.

*Scheduled Tender date
    zmm_pur_tender_d_st-sch_tdrdt = p_pr_rcptdt.

* To calculate scheduled date : Submission deadline of tender
    zmm_tms_tc-subm_dl_sch_dt = zmm_pur_tender_d_st-sch_tdrdt + 21.

    IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
      zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
      zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt. "+ 4.

*Scheduled CS vetting date
      zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 1. "4.

*Scheduled bid forwarding to indentor
      zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt. " + 1.

*Scheduled date of receipt of technical comments
      zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt. "+ 7.

*Scheduled TCs for techno-commerical bid evaluation
      zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 2. "8.


*Scheduled date of approval of tc meeting for shortlisting of bids
      zmm_tms_tb-sb_tc_apv_sch_dt
                            = zmm_tms_tb-tbid_eval_sch_dt + 2.

      CLEAR : zmm_tms_pb-cs_prep_dt_sch,
              zmm_tms_pb-cs_vett_dt_sch,
              zmm_tms_pb-tc_awrd_sch_dt,
              zmm_tms_pb-aprv_awrd_sch_dt.

* Schedule Price bid opening date should be equal to schedule Technical
* Bid Opening date
      zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-tend_op_sch_dt.

*Scheduled date of first LOI
      IF NOT zmm_tms_tb-sb_tc_apv_sch_dt IS INITIAL.

        zmm_tms_pb-loi_1_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 1.

      ENDIF.

*Scheduled date of receipt of PBG
      IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

        zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    "calc_various_dates

*&---------------------------------------------------------------------*
*&      Form  CHK_REQUIRED_INPUT
*&---------------------------------------------------------------------*
* To validate If user enters PR number, then PR receipt date should
* be mandatory.
*----------------------------------------------------------------------*
*      <--P_CHK  Check Status
*----------------------------------------------------------------------*
FORM chk_required_input  CHANGING p_chk.
**----------Start of change 01.07.2016 11:11:01 REKHA  -------------------
*  IF NOT zmm_pur_tender_d_st-banfn  IS INITIAL AND
*         zmm_tms_general-pr_rcpt_dt IS INITIAL.


**Code commented to make  date as non mandatory
* p_chk = 'X'.
*
*    MESSAGE i127(zmm_oth).



*  ENDIF.
*  **----------End  of change 01.07.2016 11:11:01 REKHA  -----------------

**----------Start of change 06.07.2016 11:03:51 REKHA to make follwinf field mandatory   -------------------

  IF zmm_tms_tc-cpa IS INITIAL OR zmm_tms_tc-indentor IS INITIAL
  OR zmm_tms_tc-ic_mm IS INITIAL OR zmm_tms_tc-l1 IS INITIAL .
    p_chk = 'X'.
*
    MESSAGE i502(zmm_oth).
  ENDIF.
**----------End  of change 06.07.2016 11:03:51 REKHA  -----------------



ENDFORM.                    " CHK_REQUIRED_INPUT

*&---------------------------------------------------------------------*
*&      Form  SET_PRE_BID_DT
*&---------------------------------------------------------------------*
* To calculate scheduled date
*  - Receipt of querry from Bidders
*  - Scrutiny and PBC Date
*----------------------------------------------------------------------*
*      -->P_PBC_STAT         Pre bid conference status
*      -->P_ST_SCH_LT_SEL    Schedule last date of selling tender
*      -->P_LSTK             LSTK Project type
*      <--P_RCPT_BID_SCH_DT  Date of receipt of querry from Bidders
*      <--P_PBC_SCH_DT       Pre bid conference date
*      <--P_TC_MET_PB_SCH_DT Date of approval of TC meeting - Prebid ...
*      <--P_REO_TSAL_STAT    Reopening of sale required
*      <--P_AMD_ISSU_SCH_DT  Date of Issue of amendments after PBC
*      <--P_REO_TSAL_SCH_DT  Re-Opening of tender sale
*      <--P_REC_TSAL_SCH_DT  Re-Closing of tender sale
*      <-P_SUBM_DL_SCH_DT    Submission Deadline of Tender
*----------------------------------------------------------------------*
FORM set_pre_bid_dt  USING    p_pbc_stat
                              p_st_sch_lt_sel
                              p_lstk
                     CHANGING p_rcpt_bid_sch_dt
                              p_pbc_sch_dt
                              p_tc_met_pb_sch_dt
                              p_reo_tsal_stat
                              p_amd_issu_sch_dt
                              p_reo_tsal_sch_dt
                              p_rec_tsal_sch_dt
                              p_subm_dl_sch_dt.

  IF p_pbc_stat = 'Y' AND NOT p_st_sch_lt_sel IS INITIAL.

*Scheduled date of receipt of querry from Bidders
    p_rcpt_bid_sch_dt = p_st_sch_lt_sel + 7.

*Scheduled scrutiny and PBC Date
    p_pbc_sch_dt = p_rcpt_bid_sch_dt + 8.

*Scheduled date of approval of TC meeting - Prebid confer. Issue
    p_tc_met_pb_sch_dt = p_pbc_sch_dt + 8.

    IF p_reo_tsal_stat = 'Y'.
*Date of Issue of amendments after PBC
      p_amd_issu_sch_dt = p_pbc_sch_dt + 13.

*Re-Opening of tender sale
*     p_reo_tsal_sch_dt = p_amd_issu_sch_dt.
      p_reo_tsal_sch_dt = p_amd_issu_sch_dt + 7.

*Re-Closing of tender sale
*     p_rec_tsal_sch_dt = p_amd_issu_sch_dt + 15.
      p_rec_tsal_sch_dt = p_reo_tsal_sch_dt + 15.

    ELSE.
*Date of Issue of amendments after PBC
      p_amd_issu_sch_dt = p_pbc_sch_dt + 8.

      CLEAR : p_reo_tsal_sch_dt,
              p_rec_tsal_sch_dt.
    ENDIF.

  ELSE.

    CLEAR : p_rcpt_bid_sch_dt,
            p_pbc_sch_dt,
            p_tc_met_pb_sch_dt,
            p_amd_issu_sch_dt,
            p_reo_tsal_sch_dt,
            p_rec_tsal_sch_dt.

*    p_reo_tsal_stat = 'N'.

  ENDIF.

  IF NOT zmm_pur_tender_d_st-sch_lt_sel_dt IS INITIAL OR
     NOT p_amd_issu_sch_dt IS INITIAL OR
     NOT p_rec_tsal_sch_dt IS INITIAL.

    PERFORM calc_subm_deadline USING p_pbc_stat
                                     p_lstk
                                     p_reo_tsal_stat
                                     zmm_pur_tender_d_st-sch_lt_sel_dt
                                     p_amd_issu_sch_dt
                                     p_rec_tsal_sch_dt
                                 CHANGING p_subm_dl_sch_dt.
  ENDIF.

ENDFORM.                    " SET_PRE_BID_DT

*&---------------------------------------------------------------------*
*&      Form  CALC_SUBM_DEADLINE
*&---------------------------------------------------------------------*
* to calculate submission deadline
*----------------------------------------------------------------------*
*      -->P_PBC_STAT        Pre bid conference status
*      -->P_LSTK_STAT       LSTK
*      -->P_REO_TSAL_STAT   Reopening of sale required
*      -->P_ST_SCH_LT_SEL   Last date of selling tender
*      -->P_AMD_ISSU_SCH_DT Date of Issue of amendments after PBC
*      -->P_REC_TSAL_SCH_DT Re-Closing of tender sale
*      <--P_SUBM_DL_SCH_DT  Submission Deadline
*----------------------------------------------------------------------*
FORM calc_subm_deadline  USING    p_pbc_stat
                                  p_lstk
                                  p_reo_tsal_stat
                                  p_st_sch_lt_sel
                                  p_amd_issu_sch_dt
                                  p_rec_tsal_sch_dt
                         CHANGING p_subm_dl_sch_dt.

  CASE p_reo_tsal_stat. "Reopening of sale required

    WHEN 'N'.

      CASE p_lstk. "LSTK

        WHEN 'P'. "Process Platforms

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_amd_issu_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_amd_issu_sch_dt + 51.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 40.

              ENDIF.

          ENDCASE.

        WHEN 'O'. "Other LSTK Projects

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_amd_issu_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_amd_issu_sch_dt + 36.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 25.

              ENDIF.

          ENDCASE.

        WHEN 'N'. "No

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_amd_issu_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_amd_issu_sch_dt + 21.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 10.

              ENDIF.

          ENDCASE.

      ENDCASE.

    WHEN 'Y'.

      CASE p_lstk. "LSTK

        WHEN 'P'. "Process Platforms

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_rec_tsal_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_rec_tsal_sch_dt + 51.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 40.

              ENDIF.

          ENDCASE.

        WHEN 'O'. "Other LSTK Projects

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_rec_tsal_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_rec_tsal_sch_dt + 36.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 25.

              ENDIF.

          ENDCASE.

        WHEN 'N'. "No

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_rec_tsal_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_rec_tsal_sch_dt + 21.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 10.

              ENDIF.

          ENDCASE.

      ENDCASE.

  ENDCASE.

ENDFORM.                    " CALC_SUBM_DEADLINE

*&---------------------------------------------------------------------*
*&      Form  SET_PRE_BID_L_DT
*&---------------------------------------------------------------------*
* To calculate scheduled date
*  - Receipt of querry from Bidders
*  - Scrutiny and PBC Date
*  -
*  -
*----------------------------------------------------------------------*
*      -->P_PBC_STAT         Pre bid conference status
*      -->P_TNDR_VAL         Tender value
*      -->P_SCH_TDRDT        Schedule tender date
*      -->P_VERF_ISS_SCH_DT  Scheduled verification & issue of tender..
*      -->P_LSTK             LSTK Project type
*      <--P_RCPT_BID_SCH_DT  Date of receipt of querry from Bidders
*      <--P_PBC_SCH_DT       Pre bid conference date
*      <--P_AMD_ISSU_SCH_DT  Date of Issue of amendments after PBC
*      <-P_SUBM_DL_SCH_DT    Submission Deadline of Tender
*----------------------------------------------------------------------*
FORM set_pre_bid_l_dt  USING    p_pbc_stat
                                p_tndr_val
                                p_sch_tdrdt
                                p_verf_iss_sch_dt
                                p_lstk
                       CHANGING p_rcpt_bid_sch_dt
                                p_pbc_sch_dt
                                p_amd_issu_sch_dt
                                p_subm_dl_sch_dt.

  DATA : l_tval_stat(1),
         l_reo_tsal_stat(1) VALUE 'N',
         l_date             TYPE sy-datum.

*Tender Value Status
  IF p_tndr_val GT 2500000.

    l_tval_stat = 'A'.

  ELSEIF p_tndr_val BETWEEN 500000 AND 2500000.

    l_tval_stat = 'B'.

  ELSE.

    l_tval_stat = 'C'.

  ENDIF.

  IF p_pbc_stat = 'Y' AND NOT p_verf_iss_sch_dt IS INITIAL.

    IF l_tval_stat = 'A'.

*Scheduled date of receipt of querry from Bidders
      p_rcpt_bid_sch_dt = p_verf_iss_sch_dt + 7.

*Scheduled scrutiny and PBC Date
      p_pbc_sch_dt = p_rcpt_bid_sch_dt + 8.

*Date of Issue of amendments after PBC[Approval & Issue of PBC Minutes]
      p_amd_issu_sch_dt = p_pbc_sch_dt + 8.

    ELSE.

      CLEAR : p_rcpt_bid_sch_dt,
              p_pbc_sch_dt,
              p_amd_issu_sch_dt.

    ENDIF.

  ENDIF.

  IF l_tval_stat = 'A'.

    IF NOT p_verf_iss_sch_dt IS INITIAL OR
       NOT  p_amd_issu_sch_dt IS INITIAL.

      PERFORM calc_subm_deadline USING p_pbc_stat
                                       p_lstk
                                       l_reo_tsal_stat
                                       p_verf_iss_sch_dt
                                       p_amd_issu_sch_dt
                                       l_date
                                    CHANGING p_subm_dl_sch_dt.

    ENDIF.

  ELSEIF l_tval_stat = 'B'.

    p_subm_dl_sch_dt = p_verf_iss_sch_dt + 10.

  ELSEIF l_tval_stat = 'C'.

    p_subm_dl_sch_dt = p_sch_tdrdt + 21.

  ENDIF.

ENDFORM.                    " SET_PRE_BID_L_DT

*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_PR_RCPT_DT
*&---------------------------------------------------------------------*
* To maintain log : PR receipt date
*----------------------------------------------------------------------*
*      -->P_SUBMI            Tender No.
*      -->P_PR_RCPT_DT_N     PR Receipt Date(new)
*      -->P_PR_RCPT_DT_O     PR Receipt Date(old)
*----------------------------------------------------------------------*
FORM chng_doc_pr_rcpt_dt USING p_submi
                               p_pr_rcpt_dt_n
                               p_pr_rcpt_dt_o.

  DATA : wa_zmm_tms_o TYPE  zmm_tms,
         wa_zmm_tms_n TYPE  zmm_tms.

  DATA : ist_chngind TYPE TABLE OF cdtxt WITH HEADER LINE.

  DATA : l_objectid TYPE cdhdr-objectid.

  l_objectid = p_submi.

*  MOVE-CORRESPONDING zmm_tms TO wa_zmm_tms_n.
*  MOVE-CORRESPONDING zmm_tms TO wa_zmm_tms_o.

  wa_zmm_tms_n-pr_rcpt_dt = p_pr_rcpt_dt_n.

  wa_zmm_tms_o-pr_rcpt_dt = p_pr_rcpt_dt_o.

  CALL FUNCTION 'ZPR_RCPT_DT_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_tms               = wa_zmm_tms_n
      o_zmm_tms               = wa_zmm_tms_o
      upd_zmm_tms             = 'U'
    TABLES
      icdtxt_zpr_rcpt_dt      = ist_chngind.

ENDFORM.                    " CHNG_DOC_PR_RCPT_DT

*&---------------------------------------------------------------------*
*&      Form  GET_NO_RFQ_MAINT
*&---------------------------------------------------------------------*
* To get Nos. of RFQ maintained
*----------------------------------------------------------------------*
*      -->P_BANFN   PR No.
*      <--P_NO_REQ  No. of RFQ
*----------------------------------------------------------------------*
FORM get_no_rfq_maint  USING    p_banfn
                       CHANGING p_no_req.
  DATA : BEGIN OF wa_ebeln,
           banfn TYPE eban-banfn,
           ebeln TYPE ekko-ebeln,
         END OF wa_ebeln.

  DATA : ist_ebeln LIKE TABLE OF wa_ebeln.

  DATA : l_count TYPE sy-tabix.

  SELECT banfn ebeln FROM m_mekke
       INTO CORRESPONDING FIELDS OF TABLE ist_ebeln
          WHERE banfn =  p_banfn.

  IF NOT ist_ebeln[] IS INITIAL.

    SORT ist_ebeln BY ebeln.

    DELETE ADJACENT DUPLICATES FROM ist_ebeln  COMPARING ebeln.

    SELECT COUNT( * ) FROM ekko INTO l_count
         FOR ALL ENTRIES IN ist_ebeln
             WHERE ebeln = ist_ebeln-ebeln AND
                   statu = 'A'.

    IF sy-subrc = 0.
      p_no_req = l_count.
    ELSE.
      CLEAR p_no_req.
    ENDIF.

  ELSE.

    CLEAR p_no_req.

  ENDIF.

ENDFORM.                    " GET_NO_RFQ_MAINT

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_NITDATE
*&---------------------------------------------------------------------*
* To set I/O attribute of screen field NIIT Date in Create/Change mode
*----------------------------------------------------------------------*
FORM display_nitdate .
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
    IF NOT zmm_pur_tender_d_st-tndr_val IS INITIAL OR
      NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.
      IF zmm_pur_tender_d_st-tndr_val < 500000 OR
         zmm_pur_tender_d_st-tndr_proc = 10 OR
         zmm_pur_tender_d_st-tndr_proc = 11 OR
         zmm_pur_tender_d_st-tndr_proc = 12 OR
         zmm_pur_tender_d_st-tndr_proc = 13 OR
         zmm_pur_tender_d_st-tndr_proc = 14 OR
         zmm_pur_tender_d_st-tndr_proc = 15 OR
         zmm_pur_tender_d_st-tndr_proc =  7 OR
         zmm_pur_tender_d_st-tndr_proc =  8 OR
         zmm_pur_tender_d_st-tndr_proc =  9.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
            screen-input = 0.
            MODIFY SCREEN.
            CLEAR zmm_pur_tender_d_st-nitdate.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " DISPLAY_NITDATE

*&---------------------------------------------------------------------*
*&      Form  UPD_PURQ_PROFILE
*&---------------------------------------------------------------------*
* Update Procurement Profile of  Purchase Requistion
*----------------------------------------------------------------------*
FORM upd_purq_profile.

  DATA: BEGIN OF ist_eban OCCURS 0.
          INCLUDE STRUCTURE ueban.
  DATA:     upd(1) TYPE c,
            del(1) TYPE c,
            END OF ist_eban.

  DATA : ist_eban_f LIKE TABLE OF ist_eban WITH HEADER LINE.

  DATA: pe_t_xeban      LIKE ueban OCCURS 0 WITH HEADER LINE.

  DATA: pe_t_xebkn      LIKE uebkn OCCURS 0 WITH HEADER LINE.

  DATA: pe_t_yeban   LIKE ueban OCCURS 0 WITH HEADER LINE,
        pe_t_yeban_t LIKE ueban OCCURS 0 WITH HEADER LINE.

  DATA: pe_t_yebkn      LIKE uebkn OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF wa_banfn,
           banfn TYPE eban-banfn,
         END OF wa_banfn.

  DATA : ist_banfn   LIKE TABLE OF wa_banfn.

  IF zmm_pur_tender_d_st-bsart+0(2) = 'ET' AND
     NOT zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT zmm_pur_tender_d_st-banfn2 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn2 TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT zmm_pur_tender_d_st-banfn3 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn3 TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT zmm_pur_tender_d_st-banfn4 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn4 TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT ist_banfn[] IS INITIAL.

      LOOP AT ist_banfn INTO wa_banfn.

        REFRESH : ist_eban,
                  pe_t_yeban_t,
                  pe_t_xeban,
                  pe_t_xebkn,
                  pe_t_yeban,
                  pe_t_yebkn.

        CLEAR : ist_eban,
                pe_t_yeban_t,
                pe_t_xeban,
                pe_t_xebkn,
                pe_t_yeban,
                pe_t_yebkn.

        SELECT * FROM eban
           INTO CORRESPONDING FIELDS OF TABLE ist_eban
                 WHERE banfn = wa_banfn-banfn.

        SORT ist_eban BY banfn bnfpo.

        LOOP AT ist_eban.

          MOVE-CORRESPONDING ist_eban TO pe_t_yeban_t.

          APPEND pe_t_yeban_t.

        ENDLOOP.

        LOOP AT ist_eban.

          CLEAR : ist_eban-eprofile.

          ist_eban-kz = 'U'.

          MODIFY ist_eban INDEX sy-tabix TRANSPORTING eprofile kz.

        ENDLOOP.

        LOOP AT ist_eban.

          LOOP AT pe_t_yeban_t WHERE banfn = ist_eban-banfn AND
                                     bnfpo = ist_eban-bnfpo.

            MOVE-CORRESPONDING ist_eban TO pe_t_xeban.

            APPEND pe_t_xeban.

            MOVE-CORRESPONDING pe_t_yeban_t TO pe_t_yeban.

            APPEND pe_t_yeban.

          ENDLOOP.

        ENDLOOP.

        CALL FUNCTION 'Z_ME_CREATE_REQ'
          TABLES
            xeban = pe_t_xeban.

        CALL FUNCTION 'ME_UPDATE_REQUISITION'
          TABLES
            xeban = pe_t_xeban
            xebkn = pe_t_xebkn
            yeban = pe_t_yeban
            yebkn = pe_t_yebkn.

      ENDLOOP.

    ENDIF.

  ENDIF.

ENDFORM.                    "UPD_PURQ_PROFILE
*&---------------------------------------------------------------------*
*&      Form  CHECK_MM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC_TC_MEMBER1  text
*----------------------------------------------------------------------*
FORM check_mm  USING p_zmm_tms_tc_tc_member1.
*               CHANGING l_disc_cd type ty_data-disc_cd.
  CLEAR :  ist_data , wa_data.
  REFRESH : ist_data.

  MOVE sy-datum TO l_date.

  IF NOT  p_zmm_tms_tc_tc_member1 IS INITIAL.
**----------Start of change 27.06.2016 16:50:44 -------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*           D~DISC_CD AS DISC_CD
*             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                 ON C~DESIGNO = D~DESIG_CODE AND
*                     C~R_P_CD  = D~R_P_CD AND
*                     C~VERSION = D~VERSION )
*                  WHERE A~PERNR =  P_ZMM_TMS_TC_TC_MEMBER1 AND
*                        A~SPRPS = ' '     AND
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
                 WHERE a~pernr =  p_zmm_tms_tc_tc_member1 AND
                       a~sprps = ' '     AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                        a~endda GE l_date AND
*End of <RD1K964434>.
                        c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                        c~endda GE l_date .
**----------End  of change 27.06.2016 16:50:44 -----------------

    SORT ist_data BY endda DESCENDING.
    READ TABLE ist_data INTO wa_data INDEX 1.

    IF wa_data-disc_cd <> '36'.
      CLEAR p_zmm_tms_tc_tc_member1.
      MESSAGE e206(zmm_oth) WITH text-202.
    ENDIF.
*    l_disc_cd_1 = wa_DATA-DISC_CD.
*    if wa_DATA-DISC_CD = '36'.
*      l_mm = 'X'.
*    endif.
*    if wa_DATA-DISC_CD = '13'.
*      l_fi = 'X'.
*    endif.
  ENDIF.

ENDFORM.                    " CHECK_MM
*&---------------------------------------------------------------------*
*&      Form  CHECK_FI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC_TC_MEMBER2_S  text
*----------------------------------------------------------------------*
FORM check_fi  USING    p_zmm_tms_tc_tc_member2_s.
  CLEAR :  ist_data , wa_data.
  REFRESH : ist_data .

  MOVE sy-datum TO l_date.

  IF NOT p_zmm_tms_tc_tc_member2_s IS INITIAL.
**----------Start of change 27.06.2016 16:51:53 -------------------
**
**    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
**             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
**           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
**           D~DISC_CD AS DISC_CD
**             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
**        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
**              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
**                 ON C~DESIGNO = D~DESIG_CODE AND
**                     C~R_P_CD  = D~R_P_CD AND
**                     C~VERSION = D~VERSION )
**                  WHERE A~PERNR =  P_ZMM_TMS_TC_TC_MEMBER2_S AND
**                        A~SPRPS = ' '     AND
***Begin of <RD1K964434>.
***                        a~endda = '99991231' AND
**                         A~ENDDA GE L_DATE AND
***End of <RD1K964434>.
**                         C~SPRPS = ' ' AND
***Begin of <RD1K964434>.
***                        c~endda = '99991231' .
**                         C~ENDDA GE L_DATE .


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
              WHERE a~pernr =  p_zmm_tms_tc_tc_member2_s AND
                    a~sprps = ' '     AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                     a~endda GE l_date AND
*End of <RD1K964434>.
                     c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                     c~endda GE l_date .
**----------End  of change 27.06.2016 16:51:53 -----------------

    SORT ist_data BY endda DESCENDING.
    READ TABLE ist_data INTO wa_data INDEX 1.

    IF wa_data-disc_cd <> '13'.
      CLEAR p_zmm_tms_tc_tc_member2_s.
      MESSAGE e206(zmm_oth) WITH text-203.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_FI
*&---------------------------------------------------------------------*
*&      Form  CHECK_INDENTOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC_TC_MEMBER3_S  text
*----------------------------------------------------------------------*
FORM check_indentor  USING    p_zmm_tms_tc_tc_member3_s.
  CLEAR :  ist_data , wa_data.
  REFRESH : ist_data .

  MOVE sy-datum TO l_date.

  IF NOT p_zmm_tms_tc_tc_member3_s IS INITIAL.
**----------Start of change 27.06.2016 16:53:39 -------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*           D~DISC_CD AS DISC_CD
*             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                 ON C~DESIGNO = D~DESIG_CODE AND
*                     C~R_P_CD  = D~R_P_CD AND
*                     C~VERSION = D~VERSION )
*                  WHERE A~PERNR =  P_ZMM_TMS_TC_TC_MEMBER3_S AND
*                        A~SPRPS = ' '     AND
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
                 WHERE a~pernr =  p_zmm_tms_tc_tc_member3_s AND
                       a~sprps = ' '     AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                        a~endda GE l_date AND
*End of <RD1K964434>.
                        c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                        c~endda GE l_date .
**----------End  of change 27.06.2016 16:53:39 -----------------

    SORT ist_data BY endda DESCENDING.
    READ TABLE ist_data INTO wa_data INDEX 1.

    IF ( wa_data-disc_cd = '13' OR wa_data-disc_cd = '36' ).
      CLEAR p_zmm_tms_tc_tc_member3_s.
      MESSAGE e206(zmm_oth) WITH text-204.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_INDENTOR
*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_TMS  text
*----------------------------------------------------------------------*
FORM chng_doc_tc  USING    p_submi_tc  p_wa_zmm_tms_tco p_wa_zmm_tms_tcn.
  DATA : wa_zmm_tms_o_tc TYPE  zmm_tms,
         wa_zmm_tms_n_tc TYPE  zmm_tms.

  DATA : ist_chngind_tc TYPE TABLE OF cdtxt WITH HEADER LINE.
  DATA : l_objectid_tc TYPE cdhdr-objectid.


  l_objectid_tc =  p_submi_tc.

  MOVE-CORRESPONDING p_wa_zmm_tms_tcn TO  wa_zmm_tms_n_tc .
  wa_zmm_tms_n_tc-rel_stat = v_rel_new.

  MOVE-CORRESPONDING p_wa_zmm_tms_tco TO wa_zmm_tms_o_tc .
  wa_zmm_tms_o_tc-rel_stat = v_rel_old.


  CALL FUNCTION 'ZMM_TC_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid_tc
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
      object_change_indicator = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZMM_TC       = ' '
      n_zmm_tms               = wa_zmm_tms_n_tc
      o_zmm_tms               = wa_zmm_tms_o_tc
      upd_zmm_tms             = 'U'
    TABLES
      icdtxt_zmm_tc           = ist_chngind_tc.


ENDFORM.                    " CHNG_DOC_TC
*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_TENDER_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_TMS_SUBMI  text
*      -->P_WA_TENDER_OLD  text
*      -->P_WA_TENDER_NEW  text
*----------------------------------------------------------------------*
FORM chng_doc_tender_pr  USING    p_submi_pr
                                  p_wa_tender_old
                                  p_wa_tender_new.
  DATA : wa_tender_o TYPE  zmm_pur_tender_d,
         wa_tender_n TYPE  zmm_pur_tender_d.

  DATA : ist_chngind_pr TYPE TABLE OF cdtxt WITH HEADER LINE.
  DATA : l_objectid_pr TYPE cdhdr-objectid.


  l_objectid_pr =  p_submi_pr.

  MOVE-CORRESPONDING p_wa_tender_new TO  wa_tender_n .
  MOVE-CORRESPONDING p_wa_tender_old TO wa_tender_o.


  CALL FUNCTION 'ZMM_TEND_BN_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid_pr
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
      object_change_indicator = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZMM_TEND_BN  = ' '
      n_zmm_pur_tender_d      = wa_tender_n
      o_zmm_pur_tender_d      = wa_tender_o
      upd_zmm_pur_tender_d    = 'U'
    TABLES
      icdtxt_zmm_tend_bn      = ist_chngind_pr.
ENDFORM.                    " CHNG_DOC_TENDER_PR
*&---------------------------------------------------------------------*
*&      Form  GET_NAME_DESIGN_CPA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ZMM_TMS_TC_CPA  text
*      <--P_WA_CPA_DTL_ENAME  text
*      <--P_WA_CPA_DTL_DESIG_TEXT  text
*----------------------------------------------------------------------*
FORM get_name_design_cpa  USING    p_pernr
                          CHANGING p_ename
                                   p_design.


  DATA : l_designo TYPE pa9930-designo,
         l_r_p_cd  TYPE pa9930-r_p_cd,
         l_version TYPE pa9930-version.

**----------Start of change 27.06.2016 16:54:34 -------------------
*  SELECT SINGLE ENAME FROM PA0001 INTO P_ENAME
*         WHERE PERNR = P_PERNR AND
*               ENDDA = '99991231'.

  SELECT ENAME FROM ZPA0001 INTO P_ENAME UP TO 1 ROWS
 WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**----------End  of change 27.06.2016 16:54:34 -----------------

  IF sy-subrc NE 0.
    IF p_pernr+0(1) <> 'C'.
      """"""""""""""""""""""""""""""""""""""""""""""


      IF  zmm_tms_tc-cpa = 'EPC'.

        """""""""""""
        "commented by lipsy  22.05.2015 RD1K997320
* if zmm_tms_general-epc_typ = 'E' or zmm_tms_pb-epc_typ_pb = 'E'.
* else.
* message 'Please Enter valid CPF no' type 'E'.
* endif.

        "end of comment by lipsy  22.05.2015 RD1K997320
      ELSE.

        """"""""""""""""""""""""""""""""""""""
        "added by  lipsy on 22.05.2015 RD1K997320

        """""""""""""""""""""""""""""""""""""""""""""""
        "commented by lipsy on 27.05.2015 RD1K997318

*   if  p_pernr = '00000000'.
        "end of comment by lipsy on 27.05.2015 RD1K997318
        """"""""""""""""""""""""""""""""""""""""""

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "added by lipsy on 27.05.2015 RD1K997318

        IF  p_pernr+0(1) = '0'.
          "end of addition by lipsy on 27.05.2015 RD1K997318

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
        ELSE.

          "end of addition by lipsy on 22.05.2015 RD1K997320
          """""""""""""""""""""""""""""""""""""""""""""""""""""""
          MESSAGE e035(zmmpurtdr).

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          "added by  lipsy on 22.05.2015 RD1K997320

        ENDIF.
        "end of addition by lipsy on 22.05.2015 RD1K997320
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDIF.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""



  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""

**----------Start of change 27.06.2016 16:56:20 -------------------
*  SELECT SINGLE DESIGNO R_P_CD VERSION FROM PA9930
*         INTO (L_DESIGNO,L_R_P_CD,L_VERSION)
*            WHERE PERNR = P_PERNR AND
*                  ENDDA = '99991231'.

  SELECT DESIGNO R_P_CD VERSION FROM ZPA9930
 INTO ( L_DESIGNO , L_R_P_CD , L_VERSION ) UP TO 1 ROWS WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**----------End  of change 27.06.2016 16:56:20 -----------------
  IF sy-subrc = 0.

    SELECT SINGLE desig_text FROM zdesignation_rev
         INTO p_design
            WHERE desig_code = l_designo AND
                  r_p_cd     = l_r_p_cd AND
                  version    = l_version.
  ENDIF.
ENDFORM.                    " GET_NAME_DESIGN_CPA

*--- INCLUDE: MZMMTMSI01 ---*
*&---------------------------------------------------------------------*
*&      Module  CANCEL_0100  INPUT
*&---------------------------------------------------------------------*
*   To exit from program at any time
*----------------------------------------------------------------------*
MODULE cancel_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " CANCEL_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_GLOBAL_VAR  INPUT
*&---------------------------------------------------------------------*
* To initialize global variables
*----------------------------------------------------------------------*
MODULE init_global_var INPUT.

  CLEAR : zmm_pur_tender_d_st,
          wa_zmm_tms.

  CLEAR : zmm_tms,
          zmm_tms_general,
          zmm_tms_tc,
          zmm_tms_tb,
          zmm_tms_pb,
          zmm_tms_epc.

  CLEAR : wa_cpa_dtl,
          wa_indentor_dtl,
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
" RD1K994950
           wa_icmm_dtl,
           wa_l1_dtl,

"END OF ADDITION BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
" RD1K994950
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          wa_tc_mem1,
          wa_tc_mem2,
          wa_tc_mem3,
          wa_tc_mem4.

  CLEAR : ist_lines,
          ist_zmm_tmst,
          wa_zmm_tmst.

  CLEAR : g_option,
          g_dmode,
          g_chg_flg,
          g_dmode_spfc,
          g_chg_spfc.

*+001 : Start
  CLEAR : g_dmode_epc,
          g_chg_epc.
*+001 : End

  CLEAR : g_tndr_proc,
          g_tndr_typ.

  tms_ctrl-activetab = 'TDTL'.
  g_dynnr = '0300'.

*Set default vaule of Radio Button for TMS : General sub-screen
  g_reg = 'X'.
  CLEAR g_spfc.

*Set default value for shortlisted bidders for PBO
  g_pbo_bidrs = 'X'.

*18.10.2012 : Start
  g_loi_dt1 = text-002.
  g_loi_dt2 = text-003.
  g_loi_dt3 = text-004.
*18.10.2012 : End

*+007 : Start
*Pre bid conference status
  zmm_tms_tc-pbc_stat =  'N'.
*Reopening of sale required
  zmm_tms_tc-reo_tsal_stat = 'N'.
*+007 : End
ENDMODULE.                 " INIT_GLOBAL_VAR  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
* To call screen 200.
* Lock the record(s) in case of change/delete before calling screen 0200
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  g_ok_code = ok_code.
  CLEAR ok_code.

*+002 : Start
  PERFORM chk_authority USING sy-uname
                              g_ok_code.
*+002 : End

  CASE g_ok_code.

    WHEN 'NEW'.
      g_tcode = 'ZMMTDR1'.

      CALL SCREEN '0200'.

    WHEN 'CHNG'.

      g_tcode = 'ZMMTDR2'.

      CALL SCREEN '0150'.

    WHEN 'DISP'.

      g_tcode = 'ZMMTDR3'.

      g_dmode = 'X'.
      g_dmode_spfc = 'X'.

      g_dmode_epc = 'X'.                                    "+001

      CALL SCREEN '0150'.

*+002 : Start
    WHEN 'APRV'.

      g_tcode = 'ZMMTDR3'.

      g_dmode = 'X'.
      g_dmode_spfc = 'X'.

      g_dmode_epc = 'X'.

      CALL SCREEN '0150'.
*+002 : End

*Plan to Procure Reports - PRs ->RFQs -> PO/RC
    WHEN 'PTPR'.
      SUBMIT zmm_srv_ptp_new VIA SELECTION-SCREEN AND RETURN.

    WHEN 'HELP'.

      PERFORM disp_process_guide USING 'TMSHLP'.

    WHEN 'REP'.

      SUBMIT zmm_tms_status VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0150  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0150 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " CANCEL_0150  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_validation  INPUT
*&---------------------------------------------------------------------*
*    Checks for input field, if input field is null, display error
*    message - screen 0150
*----------------------------------------------------------------------*
MODULE check_validation INPUT.

  CASE g_ok_code.

    WHEN 'CHNG'.

      PERFORM check_validation_150 USING zmm_pur_tender_d_st-submi.

      PERFORM get_editor_data USING zmm_pur_tender_d_st-submi.

    WHEN 'DISP'.

      PERFORM check_validation_150 USING zmm_pur_tender_d_st-submi.

      PERFORM get_editor_data USING zmm_pur_tender_d_st-submi.

*+002 : Start
    WHEN 'APRV'.

      PERFORM check_validation_150 USING zmm_pur_tender_d_st-submi.

      PERFORM get_editor_data USING zmm_pur_tender_d_st-submi.
*+002 : End
  ENDCASE.

ENDMODULE.                 " check_validation  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
* To call screen 200.
* Lock the record(s) in case of change/delete before calling screen 0200
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.

  CASE g_ok_code.

*   WHEN 'CHNG'.                                            "-002
    WHEN 'CHNG' OR 'APRV'.                                  "+002

      IF NOT zmm_pur_tender_d_st-submi IS INITIAL.

        CALL METHOD cl_binary_relation=>refresh_links.

*Lock record
        PERFORM lock_record USING zmm_pur_tender_d_st-submi.

        CALL SCREEN '0200'.

      ENDIF.

    WHEN 'DISP'.

      CALL METHOD cl_binary_relation=>refresh_links.

      IF NOT zmm_pur_tender_d_st-submi IS INITIAL.

        CALL SCREEN '0200'.

      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0150  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0200  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0200 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE g_ok_code.
    WHEN 'NEW'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          CLEAR : g_ans,g_txt.

          g_txt  = text-001.
          g_disp = 'X'.

          PERFORM confirm_input.
          IF g_ans = '2'.
            CLEAR g_ans.
            CLEAR ok_code.
            CLEAR save_ok.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.
          ELSEIF g_ans = '1'.
            CLEAR g_ans.
            CLEAR ok_code.
            ok_code = 'SAVE'.
          ENDIF.
      ENDCASE.

    WHEN 'CHNG'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          CLEAR : g_ans,g_txt.

          g_txt = text-001.
          g_disp = 'X'.

          PERFORM confirm_input.
          IF g_ans = '2'.
            CLEAR g_ans.
            CLEAR ok_code.
            CLEAR save_ok.
            PERFORM unlock_record USING zmm_pur_tender_d_st-submi.
            LEAVE TO SCREEN 100.
          ELSEIF g_ans = '1'.
            CLEAR g_ans.
            CLEAR ok_code.
            ok_code = 'SAVE'.
            """""""""""""""""""""""""""""""""""""""""
            "added by lipsy on 8.05.2015 for changing release status on save RD1K997136
            UPDATE zmm_tms SET
            rel_stat = ''
            WHERE submi = zmm_pur_tender_d_st-submi.
            "end of addition by lipsy on 8.05.2015 for changing release status on save RD1K997136

            """"""""""""""""""""""""""""""""""""""""""""""""""""""


          ENDIF.

      ENDCASE.

*+002 : Start
    WHEN 'APRV'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          CLEAR ok_code.
          CLEAR save_ok.
          PERFORM unlock_record USING zmm_pur_tender_d_st-submi.
          LEAVE TO SCREEN 100.
      ENDCASE.
*+002 : End

    WHEN 'DISP'.                                            "-002
      IF sy-tcode = 'ZMMTMSDISP'.
*        LEAVE TO SCREEN 0.
        LEAVE PROGRAM.
      ENDIF.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          LEAVE TO SCREEN 100.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " CANCEL_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*  To perform operations like save/delete record etc by pressing the
*  respective button at application tool bar & Tabstrip.
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE g_ok_code.


    WHEN 'NEW'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.

*+007 : Start
          CLEAR : g_chk.

          PERFORM chk_required_input CHANGING g_chk.

          IF g_chk = 'X'.

**            tms_ctrl-activetab = 'TGEN'.
**            g_dynnr = '0400'.
**            CLEAR save_ok.
            tms_ctrl-activetab = 'TTC'.
            g_dynnr = '0500'.
            CLEAR save_ok.
          ELSE.
*+007 : End
            PERFORM save_data.
            CLEAR save_ok.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.
          ENDIF.                                 "+007

        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

*        WHEN 'MJOR'.
*          g_mjor = save_ok.
*          PERFORM major_highlight_text.
*          CLEAR save_ok.
*
*        WHEN 'DOPER'.
*          g_doper = save_ok.
*          PERFORM days_oper_text.
*          CLEAR save_ok.
      ENDCASE.

    WHEN 'CHNG'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM update_data.
          CLEAR save_ok.
          CLEAR g_ok_code.
          LEAVE TO SCREEN 100.

        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

        WHEN 'ATCH'.
          PERFORM attach_files.
          CLEAR save_ok.

*+007 : Display PR Receipt Date log :Start
        WHEN 'HIST'.
          SUBMIT zmm_tms_pr_rcpt_dt_log
                   WITH p_submi = zmm_pur_tender_d_st-submi
                   AND RETURN.

*+007 : End

*        WHEN 'DOPER'.
*          g_doper = save_ok.
*          PERFORM days_oper_text.
*          CLEAR save_ok.

      ENDCASE.

*+002 : Start
    WHEN 'APRV'.   " SY-UCOMM is removed  due to automatic relase
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM upd_rel_status.
          CLEAR save_ok.

          IF ist_mesg[] IS INITIAL.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.
          ENDIF.

        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

        WHEN 'ATCH'.
          PERFORM attach_files.
          CLEAR save_ok.

*+007 : Display PR Receipt Date log :Start
        WHEN 'HIST'.
          SUBMIT zmm_tms_pr_rcpt_dt_log
                   WITH p_submi = zmm_pur_tender_d_st-submi
                   AND RETURN.

*+007 : End

      ENDCASE.
*+002 : End

    WHEN 'DISP'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

        WHEN 'LIST'.
          PERFORM list_files.
          CLEAR save_ok.

*+007 : Display PR Receipt Date log :Start
        WHEN 'HIST'.
          SUBMIT zmm_tms_pr_rcpt_dt_log
                   WITH p_submi = zmm_pur_tender_d_st-submi
                   AND RETURN.

*+007 : End

*        WHEN 'DOPER'.
*          PERFORM days_oper_text.
*          CLEAR save_ok.

      ENDCASE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

*  g_sav_ok_100 = g_ok_100.
*  CLEAR g_ok_100.
*  DATA l_ttext(10).
*
*  CASE g_sav_ok_100.
*    WHEN 'BACK'.
*      PERFORM confirm_step.
*    WHEN 'CANC'.
*      PERFORM confirm_step.
*    WHEN 'BU'.
**-----Validation on Start Date of selling tender &
**                   Last Date of selling tender.
*      PERFORM validate_date_req.
**-----Converts the date and time fields into time stamp format
*      PERFORM oif_conv_date_time_ts.
**-----Save the Data in DB Table
*      PERFORM prepare_saving ON COMMIT.
*      COMMIT WORK.
*      IF NOT zmm_pur_tender_d_st-submi IS INITIAL.
*        CONCATENATE tstct-ttext+15(6) 'd' INTO l_ttext.
*        MESSAGE i023(zmmpurtdr) WITH zmm_pur_tender_d_st-submi l_ttext.
*        PERFORM clear_para.
*      ENDIF.
*
*  ENDCASE.

* IF sy-ucomm = 'MORE'.                          "-006
  IF g_ok_code_300 = 'MORE' AND
     NOT zmm_pur_tender_d_st-banfn IS INITIAL.   "+006

    REFRESH it_sval.
    CLEAR   it_sval.

    PERFORM fill_sval.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*       check_existence = 'X'
*       popup_title     = text-003 "-006
        popup_title     = text-019 "+006
      IMPORTING
        returncode      = wrk_retcode
      TABLES
        fields          = it_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

*+006 : Start
*    IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.

    LOOP AT it_sval.
*Purchase requisition 2
      IF it_sval-fieldname = 'BANFN2' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn2.

      ENDIF.

*Purchase requisition 3
      IF it_sval-fieldname = 'BANFN3' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn3.

      ENDIF.

*Purchase requisition 4
      IF it_sval-fieldname = 'BANFN4' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn4.

      ENDIF.

*Purchase requisition 5
      IF it_sval-fieldname = 'BANFN5' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn5.

      ENDIF.
    ENDLOOP.

*    ENDIF.
*+006 : End


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """ADDED BY LIPSY ON 4.11.2014  FOR  total pr value
                                                            "RD1K994950




    """"""""""get all prs
    REFRESH:ist_eban[].


    CLEAR: wa_eban.

*PR 1
    IF NOT  zmm_pur_tender_d_st-banfn IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.
*PR 2
    IF NOT  zmm_pur_tender_d_st-banfn2 IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn2 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

*PR 3
    IF NOT  zmm_pur_tender_d_st-banfn3 IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn3 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

*PR 4
    IF NOT  zmm_pur_tender_d_st-banfn4 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn4 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

*PR 5
    IF NOT  zmm_pur_tender_d_st-banfn5 IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn5 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

    CLEAR: wa_eban_all.


    SORT ist_eban BY banfn.
    DELETE ADJACENT DUPLICATES FROM ist_eban.



    """""""""get all items
    REFRESH: ist_eban_t[].
    IF ist_eban[] IS NOT INITIAL.
      SELECT banfn bnfpo statu txz01 menge preis waers werks badat FROM eban
        INTO CORRESPONDING FIELDS OF TABLE ist_eban_t
        FOR ALL ENTRIES IN  ist_eban[]
        WHERE banfn = ist_eban-banfn.
    ENDIF.

*     bsart ne 'SWO'   and
*               statu =  'N'     and
*               loekz ne 'X'     and
*               frgkz =  'B'     and
*               erdat ge l_erdat.


    CLEAR:wa_eban,l_fval .

    LOOP AT ist_eban INTO wa_eban.

      CLEAR : wa_eban_t,l_rate_type,l_from_curr,
      l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp,v_pr_val.

      LOOP AT ist_eban_t INTO wa_eban_t WHERE banfn = wa_eban-banfn.
        """"""""""""""""""""""""""""""
        "add by lipsy on 8.07.2015 RD1K997763
        IF wa_eban_t-loekz = ''.
          "end of addition by lipsy on 8.07.2015 RD1K997763
          """""""""""""""""""""""""""""
          IF wa_eban_t-waers NE 'INR'.

            CLEAR : wa_erate,
                    l_rval.

            MOVE 'M'             TO l_rate_type.
            MOVE wa_eban_t-waers TO l_from_curr.
            MOVE 'INR'           TO l_to_curr.
            MOVE wa_eban_t-badat TO l_trans_dt.

            CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
              EXPORTING
                rate_type  = l_rate_type
                from_curr  = l_from_curr
                to_currncy = l_to_curr
                date       = l_trans_dt
              IMPORTING
                exch_rate  = wa_erate.

            CALL FUNCTION 'ROUND'
              EXPORTING
                decimals      = 2
                input         = wa_erate-exch_rate
                sign          = '+'
              IMPORTING
                output        = l_rval
              EXCEPTIONS
                input_invalid = 1
                overflow      = 2
                type_invalid  = 3
                OTHERS        = 4.

            IF sy-subrc <> 0.
*            message id sy-msgid type 'I' number sy-msgno
*                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

            l_temp  =  wa_eban_t-preis * wa_eban_t-menge .
            l_rlwrt =  l_temp * l_rval.
            l_erate =  l_rlwrt.

            l_fval = l_fval + l_erate.

          ELSE.

            l_temp = wa_eban_t-preis * wa_eban_t-menge.

            l_fval = l_fval + l_temp.

          ENDIF.



          CLEAR : wa_eban_t,l_rate_type,l_from_curr,
        l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp.

          """""""""
          "add by lipsy on 8.07.2015 RD1K997763
        ENDIF.
        "end of addition by lipsy on 8.07.2015 RD1K997763
        """"""""""""
      ENDLOOP.


      CLEAR:wa_eban.
    ENDLOOP.

    MOVE l_fval TO v_pr_val.




    """end of ADDition BY LIPSY ON 27.10.2014  FOR  total pr value
                                                            "RD1K994950
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""









    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""






  ENDIF.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  PERFORM confirm_step.
  IF g_action EQ '1'.
    CALL FUNCTION 'DEQUEUE_EZ_SUBMI'
      EXPORTING
        mode_zmm_pur_tender_d = 'E'
        mandt                 = sy-mandt
        submi                 = zmm_pur_tender_d_st-submi.
  ENDIF.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_data INPUT.
*Get the Purchasing group Description

  CALL FUNCTION 'MEX_READ_T024'
    EXPORTING
      im_ekgrp  = zmm_pur_tender_d_st-ekgrp
    IMPORTING
      ex_t024   = t024
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*Get Document type Description
  SELECT SINGLE * FROM zmm_pur_trtyp WHERE
                           bsart = zmm_pur_tender_d_st-bsart.
  IF sy-subrc NE 0.
    MESSAGE e814(f5) WITH zmm_pur_tender_d_st-bsart.
  ENDIF.

  zmm_pur_tender_d_st-bstyp = zmm_pur_trtyp-bstyp.

  l1_date = sy-datum + 7.

  IF zmm_pur_tender_d_st-tdrdt >= sy-datum AND
      zmm_pur_tender_d_st-tdrdt <= l1_date.
  ELSE.

*   IF sy-tcode = 'ZMMTDR1'.
    IF g_tcode = 'ZMMTDR1'.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """commenteD BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
*      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*        EXPORTING
*          popup_title  = 'Invalid Tender Date'
*          is_error     = 'X'
*          message_text = 'Tender Date should not be greater than 7 Days from Todays Date'
**         START_COLUMN = 25
**         START_ROW    =                                                                                         6
*        .
      """end of comment BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """addED BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950



      MESSAGE e157(zmm_oth).

      """end of addition BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950



      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""





    ENDIF.

  ENDIF.

* IF sy-tcode = 'ZMMTDR1'.
  IF g_tcode = 'ZMMTDR1'.

    IF NOT zmm_pur_tender_d_st-st_sel_dt IS INITIAL.
      IF zmm_pur_tender_d_st-tdrdt > zmm_pur_tender_d_st-st_sel_dt.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*          EXPORTING
*            popup_title  = 'Invalid Tender Start Date'
*            is_error     = 'X'
*            message_text = 'Tender sale Start Date should be greater than or equal to Tender Date'.
**         START_COLUMN       = 25
**         START_ROW          = 6
        message: 'Tender sale Start Date should be greater than or equal to Tender Date' type 'W'.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026        .
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " validate_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_SUBMI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_submi INPUT.

* CHECK NOT sy-tcode = 'ZMMTDR1'.
  CHECK NOT g_tcode = 'ZMMTDR1'.
  CHECK g_option IS INITIAL.
  SELECT SINGLE * FROM zmm_pur_tender_d INTO zmm_pur_tender_d_st WHERE
                  submi = zmm_pur_tender_d_st-submi.
  IF sy-subrc NE 0.
    MESSAGE e019(06) WITH zmm_pur_tender_d_st-submi.
  ENDIF.
  g_option = 'X'.
*----------Lock and unlock functions
  CALL FUNCTION 'ENQUEUE_EZ_SUBMI'
    EXPORTING
      mode_zmm_pur_tender_d = 'E'
      mandt                 = sy-mandt
      submi                 = zmm_pur_tender_d_st-submi
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                 " READ_SUBMI  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lstdt  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lstdt INPUT.
*+008 : Start
  IF g_ok_code NE 'NEW'.

    IF zmm_pur_tender_d_st-bsart+0(2) EQ 'MO'  OR
       zmm_pur_tender_d_st-bsart      EQ 'SGO' OR
       zmm_pur_tender_d_st-bsart EQ 'SOT'      OR
       zmm_pur_tender_d_st-bsart EQ 'MRCO'.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""

      """""""""""""""""""""""""""""""""""""""""""""""""
      "comment by lipsy on 5.11.2014 FOR new validations in RD1K994950
*      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL OR
*         zmm_pur_tender_d_st-lt_sel_dt IS INITIAL.
*
*        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-ST_SEL_DT'.
*
*        MESSAGE e008(zmmpurtdr).
*
*      ENDIF.

      "end of comment by lipsy on 5.11.2014 FOR new validations in RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "add by lipsy on 5.11.2014 FOR new validations in RD1K994950


      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL
      AND  zmm_pur_tender_d_st-sch_st_sel_dt < sy-datum.
        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-ST_SEL_DT'.
        PERFORM err_msg USING '008'.
      ENDIF.




      IF  zmm_pur_tender_d_st-lt_sel_dt IS INITIAL
     AND zmm_pur_tender_d_st-sch_lt_sel_dt < sy-datum.
        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-LT_SEL_DT'.
        PERFORM err_msg USING '038'.

      ENDIF.




      "end of addition by lipsy on 5.11.2014 FOR new validations in RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""""""""


    ENDIF.

  ENDIF.
*+008 : End

  CHECK NOT zmm_pur_tender_d_st-lt_sel_dt IS INITIAL.

  IF zmm_pur_tender_d_st-lt_sel_dt <= zmm_pur_tender_d_st-st_sel_dt.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
    IF g_ok_code = 'DISP'.

    ELSE.

      "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      MESSAGE e010(zmmpurtdr).
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
    ENDIF.

    "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDIF.

ENDMODULE.                 " validate_lstdt  INPUT
*&---------------------------------------------------------------------*
*&      Module  read_tdrsts  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_tdrsts INPUT.

  DATA l_value LIKE dd07l-domvalue_l.

  MOVE zmm_pur_tender_d_st-tdrsts TO l_value.

  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
    EXPORTING
      domname  = 'ZTDRSTS'
      value    = l_value
      langu    = sy-langu
    IMPORTING
      dd07v_wa = dd07v.

ENDMODULE.                 " read_tdrsts  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_EDITOR_DATA  INPUT
*&---------------------------------------------------------------------*
*  To Populate Editor Data into Internal table - IST_LINES
*----------------------------------------------------------------------*
MODULE get_editor_data INPUT.
  PERFORM get_editor USING 'X'.
ENDMODULE.                 " GET_EDITOR_DATA  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_EDITOR_DATA_SPFC  INPUT
*&---------------------------------------------------------------------*
*  To Populate Editor Data into Internal table - IST_LINES_SPFC
*----------------------------------------------------------------------*
MODULE get_editor_data_spfc INPUT.
  PERFORM get_editor_spfc USING 'X'.
ENDMODULE.                 " GET_EDITOR_DATA_SPFC  INPUT

*+001 : Start
*&---------------------------------------------------------------------*
*&      Module  GET_EDITOR_DATA_EPC  INPUT
*&---------------------------------------------------------------------*
*  To Populate Editor Data into Internal table - IST_LINES_EPC
*----------------------------------------------------------------------*
MODULE get_editor_data_epc INPUT.
  PERFORM get_editor_epc USING 'X'.
ENDMODULE.                 " GET_EDITOR_DATA_EPC  INPUT
*+001 : End

*&---------------------------------------------------------------------*
*&      Module  FILL_NAME_DESIGN_0500  INPUT
*&---------------------------------------------------------------------*
* To get name & desgination of tender committee / indentor etc.
*----------------------------------------------------------------------*
MODULE fill_name_design_0500 INPUT.

  PERFORM get_name_desgn USING zmm_tms_tc.

ENDMODULE.                 " FILL_NAME_DESIGN_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0500  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date
*----------------------------------------------------------------------*
MODULE chk_dates_0500 INPUT.

*Constitution of TC( Ist TC Notice)
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_form_sch_dt
                                 zmm_tms_tc-tc_form_act_dt
                                 'ZMM_TMS_TC-TC_FORM_SCH_DT'
                                 'ZMM_TMS_TC-TC_FORM_ACT_DT'.

*Date of TC meeting for BEC & Major Qualifying Criteria
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_met_sch_dt
                                 zmm_tms_tc-tc_met_act_dt
                                 'ZMM_TMS_TC-TC_MET_SCH_DT'
                                 'ZMM_TMS_TC-TC_MET_ACT_DT'.

*BEC formulation TC approval
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_aprv_sch_dt
                                 zmm_tms_tc-tc_aprv_act_dt
                                 'ZMM_TMS_TC-TC_APRV_SCH_DT'
                                 'ZMM_TMS_TC-TC_APRV_ACT_DT'.

*Date of approval of TC meeting - Prebid confer. issues
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_met_pb_sch_dt
                                 zmm_tms_tc-tc_met_pb_act_dt
                                 'ZMM_TMS_TC-TC_MET_PB_SCH_DT'
                                 'ZMM_TMS_TC-TC_MET_PB_ACT_DT'.

*Date of Issue of amendments after PBC
  PERFORM chk_sch_act_date USING zmm_tms_tc-amd_issu_sch_dt
                                 zmm_tms_tc-amd_issu_act_dt
                                 'ZMM_TMS_TC-AMD_ISSU_SCH_DT'
                                 'ZMM_TMS_TC-AMD_ISSU_ACT_DT'.

**Re-Opening of tender sale
*  PERFORM chk_sch_act_date USING zmm_tms_tc-reo_tsal_sch_dt
*                                 zmm_tms_tc-reo_tsal_act_dt
*                                 'ZMM_TMS_TC-REO_TSAL_SCH_DT'
*                                 'ZMM_TMS_TC-REO_TSAL_ACT_DT'.
**Re-Closing of tender sale
*  PERFORM chk_sch_act_date USING zmm_tms_tc-rec_tsal_sch_dt
*                                 zmm_tms_tc-rec_tsal_act_dt
*                                 'ZMM_TMS_TC-REC_TSAL_SCH_DT'
*                                 'ZMM_TMS_TC-REC_TSAL_ACT_DT'.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """ADDED BY LIPSY ON 4.11.2014  FOR  comparing tc meeting and tc approval date RD1K994950

  IF zmm_tms_tc-tc_met_sch_dt  GT  zmm_tms_tc-tc_aprv_sch_dt.

    MESSAGE e158(zmm_oth).

  ENDIF.

  """end of ADDition BY LIPSY ON 4.11.2014  FOR   comparing tc meeting and tc approval date RD1K994950
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDMODULE.                 " CHK_DATES_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0600  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date : Sub Screen 0600
*----------------------------------------------------------------------*
MODULE chk_dates_0600 INPUT.

* TBO
  PERFORM chk_sch_act_date USING zmm_tms_tb-tend_op_sch_dt
                                 zmm_tms_tb-tend_op_act_dt
                                 'ZMM_TMS_TB-TEND_OP_SCH_DT'
                                 'ZMM_TMS_TB-TEND_OP_ACT_DT'.

* CS preparation
  PERFORM chk_sch_act_date USING zmm_tms_tb-cs_prep_sch_dt
                                 zmm_tms_tb-cs_prep_act_dt
                                 'ZMM_TMS_TB-CS_PREP_SCH_DT'
                                 'ZMM_TMS_TB-CS_PREP_ACT_DT'.

* CS vetting
  PERFORM chk_sch_act_date USING zmm_tms_tb-cs_vet_sch_dt
                                 zmm_tms_tb-cs_vet_act_dt
                                 'ZMM_TMS_TB-CS_VET_SCH_DT'
                                 'ZMM_TMS_TB-CS_VET_ACT_DT'.

* Bid forwarding to indentor
  PERFORM chk_sch_act_date USING zmm_tms_tb-bid_fwd_sch_dt
                                 zmm_tms_tb-bid_fwd_act_dt
                                 'ZMM_TMS_TB-BID_FWD_SCH_DT'
                                 'ZMM_TMS_TB-BID_FWD_ACT_DT'.

* Date of receipt of technical comments
  PERFORM chk_sch_act_date USING zmm_tms_tb-tc_rcpt_sch_dt
                                 zmm_tms_tb-tc_rcpt_act_dt
                                 'ZMM_TMS_TB-TC_RCPT_SCH_DT'
                                 'ZMM_TMS_TB-TC_RCPT_ACT_DT'.

* TCs for techno-commercial bid evaluation
  PERFORM chk_sch_act_date USING zmm_tms_tb-tbid_eval_sch_dt
                                 zmm_tms_tb-tbid_eval_act_dt
                                 'ZMM_TMS_TB-TBID_EVAL_SCH_DT'
                                 'ZMM_TMS_TB-TBID_EVAL_ACT_DT'.
* Clarification sought-1st round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif1_sch_dt
                                 zmm_tms_tb-clarif1_act_dt
                                 'ZMM_TMS_TB-CLARIF1_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF1_ACT_DT'.

* Last date of clarification-1st round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif1_l_sch_dt
                                 zmm_tms_tb-clarif1_l_act_dt
                                 'ZMM_TMS_TB-CLARIF1_L_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF1_L_ACT_DT'.

* Clarification sought-last round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif2_sch_dt
                                 zmm_tms_tb-clarif2_act_dt
                                 'ZMM_TMS_TB-CLARIF2_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF2_ACT_DT'.

* Last date of clarification-last round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif2_l_sch_dt
                                 zmm_tms_tb-clarif2_l_act_dt
                                 'ZMM_TMS_TB-CLARIF2_L_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF2_L_ACT_DT'.

* Date of Vetting of unpriced commercial statement
  PERFORM chk_sch_act_date USING zmm_tms_tb-ucs_vett_sch_dt
                                 zmm_tms_tb-ucs_vett_act_dt
                                 'ZMM_TMS_TB-UCS_VETT_SCH_DT'
                                 'ZMM_TMS_TB-UCS_VETT_ACT_DT'.

* Date of receipt of Final tech comments
  PERFORM chk_sch_act_date USING zmm_tms_tb-ftc_rcpt_sch_dt
                                 zmm_tms_tb-ftc_rcpt_act_dt
                                 'ZMM_TMS_TB-FTC_RCPT_SCH_DT'
                                 'ZMM_TMS_TB-FTC_RCPT_ACT_DT'.

* Date of TC meeting for shortlisting of bids
  PERFORM chk_sch_act_date USING zmm_tms_tb-sb_tc_mt_sch_dt
                                 zmm_tms_tb-sb_tc_mt_act_dt
                                 'ZMM_TMS_TB-SB_TC_MT_SCH_DT'
                                 'ZMM_TMS_TB-SB_TC_MT_ACT_DT'.

* Date of approval of TC meeting for shortlisting of bids
  PERFORM chk_sch_act_date USING zmm_tms_tb-sb_tc_apv_sch_dt
                                 zmm_tms_tb-sb_tc_apv_act_dt
                                 'ZMM_TMS_TB-SB_TC_APV_SCH_DT'
                                 'ZMM_TMS_TB-SB_TC_APV_ACT_DT'.

ENDMODULE.                 " CHK_DATES_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0700  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date : Sub Screen 0700
*----------------------------------------------------------------------*
MODULE chk_dates_0700 INPUT.

* Opening of price bids
  PERFORM chk_sch_act_date USING zmm_tms_pb-pr_bid_op_sch_dt
                                 zmm_tms_pb-pr_bid_op_act_dt
                                 'ZMM_TMS_PB-PR_BID_OP_SCH_DT'
                                 'ZMM_TMS_PB-PR_BID_OP_ACT_DT'.
* First TC date
  PERFORM chk_sch_act_date USING zmm_tms_pb-tc1_sch_dt
                                 zmm_tms_pb-tc1_act_dt
                                 'ZMM_TMS_PB-TC1_SCH_DT'
                                 'ZMM_TMS_PB-TC1_ACT_DT'.

* Date of approval of first TC
  PERFORM chk_sch_act_date USING zmm_tms_pb-tc1_aprv_sch_dt
                                 zmm_tms_pb-tc1_aprv_act_dt
                                 'ZMM_TMS_PB-TC1_APRV_SCH_DT'
                                 'ZMM_TMS_PB-TC1_APRV_ACT_DT'.

* Date of Final TC for award
  PERFORM chk_sch_act_date USING zmm_tms_pb-tc_awrd_sch_dt
                                 zmm_tms_pb-tc_awrd_act_dt
                                 'ZMM_TMS_PB-TC_AWRD_SCH_DT'
                                 'ZMM_TMS_PB-TC_AWRD_ACT_DT'.

* Approval of Award
  PERFORM chk_sch_act_date USING zmm_tms_pb-aprv_awrd_sch_dt
                                 zmm_tms_pb-aprv_awrd_act_dt
                                 'ZMM_TMS_PB-APRV_AWRD_SCH_DT'
                                 'ZMM_TMS_PB-APRV_AWRD_ACT_DT'.
* Date of LOI - First
  PERFORM chk_sch_act_date USING zmm_tms_pb-loi_1_sch_dt
                                 zmm_tms_pb-loi_1_act_dt
                                 'ZMM_TMS_PB-LOI_1_SCH_DT'
                                 'ZMM_TMS_PB-LOI_1_ACT_DT'.

* Date of LOI - Second / Last
  PERFORM chk_sch_act_date USING zmm_tms_pb-loi_2_sch_dt
                                 zmm_tms_pb-loi_2_act_dt
                                 'ZMM_TMS_PB-LOI_2_SCH_DT'
                                 'ZMM_TMS_PB-LOI_2_ACT_DT'.

* Date of LOI - Third
  PERFORM chk_sch_act_date USING zmm_tms_pb-loi_3_sch_dt
                                 zmm_tms_pb-loi_3_act_dt
                                 'ZMM_TMS_PB-LOI_3_SCH_DT'
                                 'ZMM_TMS_PB-LOI_3_ACT_DT'.
* Date of issue of PO / Contract
  PERFORM chk_sch_act_date USING zmm_tms_pb-po_issue_sch_dt
                                 zmm_tms_pb-po_issue_act_dt
                                 'ZMM_TMS_PB-PO_ISSUE_SCH_DT'
                                 'ZMM_TMS_PB-PO_ISSUE_ACT_DT'.

ENDMODULE.                 " CHK_DATES_0700  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0800  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date : Sub Screen 0800
*----------------------------------------------------------------------*
MODULE chk_dates_0800 INPUT.

*18.10.2012 - Commented : Start
** Date of TC for EPC
*  PERFORM chk_sch_act_date USING zmm_tms_epc-tc_epc_sch_dt
*                                 zmm_tms_epc-tc_epc_act_dt
*                                 'ZMM_TMS_EPC-TC_EPC_SCH_DT'
*                                 'ZMM_TMS_EPC-TC_EPC_ACT_DT'.
*
** Date of endorsement of TC minutes for EPC
*  PERFORM chk_sch_act_date USING zmm_tms_epc-tc_endors_sch_dt
*                                 zmm_tms_epc-tc_endors_act_dt
*                                 'ZMM_TMS_EPC-TC_ENDORS_SCH_DT'
*                                 'ZMM_TMS_EPC-TC_ENDORS_ACT_DT'.
*
** Date of submission of Agenda brief to EPC
*  PERFORM chk_sch_act_date USING zmm_tms_epc-agnd_sub_sch_dt
*                                 zmm_tms_epc-agnd_sub_act_dt
*                                 'ZMM_TMS_EPC-AGND_SUB_SCH_DT'
*                                 'ZMM_TMS_EPC-AGND_SUB_ACT_DT'.
*
** Date of EPC meeting
*  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_meet_sch_dt
*                                 zmm_tms_epc-epc_meet_act_dt
*                                 'ZMM_TMS_EPC-EPC_MEET_SCH_DT'
*                                 'ZMM_TMS_EPC-EPC_MEET_ACT_DT'.
*
** Date of Endorsement by Concerned Director
*  PERFORM chk_sch_act_date USING zmm_tms_epc-dr_endors_sch_dt
*                                 zmm_tms_epc-dr_endors_act_dt
*                                 'ZMM_TMS_EPC-DR_ENDORS_SCH_DT'
*                                 'ZMM_TMS_EPC-DR_ENDORS_ACT_DT'.
*
** Date of receipt of summary minutes of EPC meeting
*  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_smr_sch_dt
*                                 zmm_tms_epc-epc_smr_act_dt
*                                 'ZMM_TMS_EPC-EPC_SMR_SCH_DT'
*                                 'ZMM_TMS_EPC-EPC_SMR_ACT_DT'.
*18.10.2012 : End

*18.10.2012 - Commented : Start
* Date of submission of EPC agenda for endorsement by Director
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_agnda_sch_dt
                                 zmm_tms_epc-epc_agnda_act_dt
                                 'ZMM_TMS_EPC-EPC_AGNDA_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_AGNDA_ACT_DT'.

* Date of Endorsement by Concerned Director
  PERFORM chk_sch_act_date USING zmm_tms_epc-dr_endors_sch_dt
                                 zmm_tms_epc-dr_endors_act_dt
                                 'ZMM_TMS_EPC-DR_ENDORS_SCH_DT'
                                 'ZMM_TMS_EPC-DR_ENDORS_ACT_DT'.

* Date of submission of Agenda in EPC cell
  PERFORM chk_sch_act_date USING zmm_tms_epc-agnd_sub_sch_dt
                                 zmm_tms_epc-agnd_sub_act_dt
                                 'ZMM_TMS_EPC-AGND_SUB_SCH_DT'
                                 'ZMM_TMS_EPC-AGND_SUB_ACT_DT'.
* Date of EPC meeting
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_meet_sch_dt
                                 zmm_tms_epc-epc_meet_act_dt
                                 'ZMM_TMS_EPC-EPC_MEET_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_MEET_ACT_DT'.

* Date of receipt of summary minutes of EPC meeting
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_smr_sch_dt
                                 zmm_tms_epc-epc_smr_act_dt
                                 'ZMM_TMS_EPC-EPC_SMR_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_SMR_ACT_DT'.

* Date of receipt of summary note from EPC
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_smrn_sch_dt
                                 zmm_tms_epc-epc_smrn_act_dt
                                 'ZMM_TMS_EPC-EPC_SMRN_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_SMRN_ACT_DT'.
*18.10.2012 : End
ENDMODULE.                 " CHK_DATES_0800  INPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TEXT  INPUT
*&---------------------------------------------------------------------*
* To read Tender Process/ Tender Type
*----------------------------------------------------------------------*
MODULE read_text INPUT.

  CLEAR : g_tndr_proc,
          g_tndr_typ.

  IF NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.

    SELECT SINGLE nat_proc_desc FROM znat_proc
          INTO g_tndr_proc
             WHERE zznat_proc = zmm_pur_tender_d_st-tndr_proc.

*    PERFORM read_text USING   'ZNATPROC'
*                               zmm_pur_tender_d_st-tndr_proc
*                      CHANGING g_tndr_proc.

  ENDIF.

  IF NOT zmm_pur_tender_d_st-tnndr_typ IS INITIAL.

    PERFORM read_text USING   'ZZTEN_TYP'
                               zmm_pur_tender_d_st-tnndr_typ
                      CHANGING g_tndr_typ.
  ENDIF.

ENDMODULE.                 " READ_TEXT  INPUT
*&---------------------------------------------------------------------*
*&      Module  CALC_PBO_BIDDERS  INPUT
*&---------------------------------------------------------------------*
* To derive shortlisted biider(s) for PBO
*----------------------------------------------------------------------*
MODULE calc_pbo_bidders INPUT.

  CASE g_ok_code.

    WHEN 'NEW' OR 'CHNG'.

* IF NOT zmm_tms_pb-no_sl_bidders IS INITIAL AND g_pbo_bidrs = 'X'.
*      IF g_pbo_bidrs = 'X'.

      zmm_tms_pb-no_sl_bidders = zmm_tms_tc-no_offer -
                                 zmm_tms_tb-no_bid_rej.

      IF zmm_tms_pb-no_sl_bidders LT 0.

        CLEAR : zmm_tms_pb-no_sl_bidders.

      ENDIF.

*      CLEAR g_pbo_bidrs.

*      ENDIF.

  ENDCASE.

ENDMODULE.                 " CALC_PBO_BIDDERS  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_ACT_DATES_0800  INPUT
*&---------------------------------------------------------------------*
* To check EPC dates
*----------------------------------------------------------------------*
MODULE chk_act_dates_0800 INPUT.

  PERFORM chk_act_date.

ENDMODULE.                 " CHK_ACT_DATES_0800  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHK_SUBS_TC_MEM  INPUT
*&---------------------------------------------------------------------*
* To check substitute TC Member
*----------------------------------------------------------------------*
MODULE chk_subs_tc_mem INPUT.

*TC Member 1
  IF NOT zmm_tms_tc-tc_ms1_chk IS INITIAL.

    IF zmm_tms_tc-tc_member1_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER1_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member1 IS INITIAL AND
             zmm_tms_tc-tc_member1 = zmm_tms_tc-tc_member1_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER1_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member1_s
                                       'ZMM_TMS_TC-TC_MEMBER1_S'
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member4
                                       zmm_tms_tc-tc_member5.

    ENDIF.

  ENDIF.

*TC Member 2
  IF NOT zmm_tms_tc-tc_ms2_chk IS INITIAL.

    IF zmm_tms_tc-tc_member2_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER2_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member2 IS INITIAL AND
             zmm_tms_tc-tc_member2 = zmm_tms_tc-tc_member2_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER2_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member2_s
                                       'ZMM_TMS_TC-TC_MEMBER2_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member4
                                       zmm_tms_tc-tc_member5.

    ENDIF.

  ENDIF.

*TC Member 3
  IF NOT zmm_tms_tc-tc_ms3_chk IS INITIAL.

    IF zmm_tms_tc-tc_member3_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER3_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member3 IS INITIAL AND
             zmm_tms_tc-tc_member3 = zmm_tms_tc-tc_member3_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER3_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member3_s
                                       'ZMM_TMS_TC-TC_MEMBER3_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member4
                                       zmm_tms_tc-tc_member5.
    ENDIF.

  ENDIF.

*TC Member 4
  IF NOT zmm_tms_tc-tc_ms4_chk IS INITIAL.

    IF zmm_tms_tc-tc_member4_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER4_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member4 IS INITIAL AND
             zmm_tms_tc-tc_member4 = zmm_tms_tc-tc_member4_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER4_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member4_s
                                       'ZMM_TMS_TC-TC_MEMBER4_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member5.

    ENDIF.

  ENDIF.

*TC Member 5
  IF NOT zmm_tms_tc-tc_ms5_chk IS INITIAL.

    IF zmm_tms_tc-tc_member5_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER5_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member5 IS INITIAL AND
             zmm_tms_tc-tc_member5 = zmm_tms_tc-tc_member5_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER5_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member5_s
                                       'ZMM_TMS_TC-TC_MEMBER5_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member4.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CHK_SUBS_TC_MEM  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DUP_TC_MEM_0500  INPUT
*&---------------------------------------------------------------------*
* To check duplicate TC Member
*----------------------------------------------------------------------*
MODULE chk_dup_tc_mem_0500 INPUT.
***********************************************************************
*                             TC Member                               *
***********************************************************************
  IF NOT zmm_tms_tc-tc_member1 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member1
                                 'ZMM_TMS_TC-TC_MEMBER1'
                                 zmm_tms_tc-tc_member2
                                 'ZMM_TMS_TC-TC_MEMBER2'
                                 zmm_tms_tc-tc_member3
                                 'ZMM_TMS_TC-TC_MEMBER3'
                                 zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member2 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member2
                                 'ZMM_TMS_TC-TC_MEMBER2'
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member3
                                 'ZMM_TMS_TC-TC_MEMBER3'
                                 zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member3 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member3
                                 'ZMM_TMS_TC-TC_MEMBER3'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member4 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

***********************************************************************
*                   Substitute TC Member                              *
***********************************************************************
  IF NOT zmm_tms_tc-tc_member1_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member1_s
                                 'ZMM_TMS_TC-TC_MEMBER1_S'
                                 zmm_tms_tc-tc_member2_s
                                 'ZMM_TMS_TC-TC_MEMBER2_S'
                                 zmm_tms_tc-tc_member3_s
                                 'ZMM_TMS_TC-TC_MEMBER3_S'
                                 zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member2_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member2_s
                                 'ZMM_TMS_TC-TC_MEMBER2_S'
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member3_s
                                 'ZMM_TMS_TC-TC_MEMBER3_S'
                                 zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member3_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member3_s
                                 'ZMM_TMS_TC-TC_MEMBER3_S'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member4_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

ENDMODULE.                 " CHK_DUP_TC_MEM_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALID_EMPID_0500  INPUT
*&---------------------------------------------------------------------*
* To check employee ID (CPF No.)
*----------------------------------------------------------------------*
MODULE valid_empid_0500 INPUT.

*  IF .
*
*  ENDIF.

  IF sy-ucomm = 'SAVE'.
    IF zmm_tms_tc-tc_stat = 'X' .
      IF zmm_tms_tc-tc_member1 IS INITIAL OR
       zmm_tms_tc-tc_member2 IS INITIAL.

        MESSAGE 'Please Enter TC Mamber' TYPE 'E'.
      ENDIF.


    ENDIF.
  ENDIF.


ENDMODULE.                 " VALID_EMPID_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_NO_BID_REJ  INPUT
*&---------------------------------------------------------------------*
* To check No. of bids rejected on commercial/technical grounds
* (Technical tab / Screen 0600)
*----------------------------------------------------------------------*
MODULE chk_no_bid_rej INPUT.

  IF zmm_tms_tb-no_bid_rej GT zmm_tms_tc-no_offer.

    MESSAGE e036(zmmpurtdr) WITH zmm_tms_tc-no_offer.

  ELSE.

    zmm_tms_pb-no_sl_bidders = zmm_tms_tc-no_offer -
                               zmm_tms_tb-no_bid_rej.

  ENDIF.

ENDMODULE.                 " CHK_NO_BID_REJ  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PR_MANDATORY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_pr_mandatory INPUT.

*+006 : Start
  CLEAR : g_ok_code_300.

  g_ok_code_300 = sy-ucomm.

  CLEAR sy-ucomm.

  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.

    IF zmm_pur_tender_d_st-banfn IS INITIAL AND
       g_ok_code_300 NE 'PCHK'.
*+006 : End
*   IF zmm_pur_tender_d_st-banfn IS INITIAL.            "-006
*     IF g_no_pr <> 'X'.                                "-006
      IF zmm_pur_tender_d_st-prchk NE 'X'.              "+006
        MESSAGE e321(zmm) WITH text-015 .
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_PR_MANDATORY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INITIAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_initial INPUT.
*  data : l_bstyp TYPE zmm_pur_trtyp-bstyp.
*  clear : l_bstyp.
*
*  select single BSTYP
*    into l_bstyp
*    from ZMM_PUR_TRTYP
*    where BSART = ZMM_PUR_TENDER_D_ST-BSART.
*  if sy-subrc = 0.
*    if l_bstyp = 'L'.
*    else.
*      MESSAGE e321(zmm) WITH text-016 .
*    endif.
*  endif.
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
*    IF zmm_pur_tender_d_st-bstyp = 'C'.
*      IF zmm_pur_tender_d_st-tndr_fee IS INITIAL.
*        MESSAGE e321(zmm) WITH text-016 .
*      ENDIF.
*    ENDIF.
*+006 : Start
    IF zmm_pur_tender_d_st-tndr_val LE 0.
      MESSAGE e321(zmm) WITH text-020.
    ENDIF.
*+006 : End
  ENDIF.
ENDMODULE.                 " CHECK_INITIAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_NAME_DESIG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_name_desig INPUT.
  IF NOT zmm_pur_tender_d_st-tdrsigner IS INITIAL.

    PERFORM get_name_design USING    zmm_pur_tender_d_st-tdrsigner
                            CHANGING wa_tdrsigner-ename
                                     wa_tdrsigner-desig_text.
  ELSE.

    CLEAR : wa_tdrsigner.

  ENDIF.
ENDMODULE.                 " FILL_NAME_DESIG  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DOPUB  INPUT            +003  CR 30009068.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_dopub INPUT.


ENDMODULE.                 " CHECK_DOPUB  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NITDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_nitdate INPUT.
  PERFORM display_nitdate.                       "+008
*-008 : Start
*  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
*    IF NOT zmm_pur_tender_d_st-tndr_val IS INITIAL OR
*      NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.
*      IF zmm_pur_tender_d_st-tndr_val < 500000 OR
*         zmm_pur_tender_d_st-tndr_proc = 10 OR
*         zmm_pur_tender_d_st-tndr_proc = 11 OR
*         zmm_pur_tender_d_st-tndr_proc = 12 OR
*         zmm_pur_tender_d_st-tndr_proc = 13 OR
*         zmm_pur_tender_d_st-tndr_proc = 14 OR
*         zmm_pur_tender_d_st-tndr_proc = 15 OR
*         zmm_pur_tender_d_st-tndr_proc =  7 OR
*         zmm_pur_tender_d_st-tndr_proc =  8 OR
*         zmm_pur_tender_d_st-tndr_proc =  9.
*        LOOP AT SCREEN.
*          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*            screen-input = 0.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*-008 : End
ENDMODULE.                 " DISPLAY_NITDATE  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALID_BANFN  INPUT
*&---------------------------------------------------------------------*
* To Validate purchase requisition : Screen 0300
*----------------------------------------------------------------------*
MODULE valid_banfn INPUT.

  CLEAR : g_loekz,
          g_frgkz.
  IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.

*+008 : PR does not exist message - Start
    CLEAR g_banfn.
    SELECT SINGLE banfn FROM eban INTO (g_banfn)
       WHERE banfn =  zmm_pur_tender_d_st-banfn.

    IF sy-subrc EQ 0.
*+008 : End

      SELECT SINGLE loekz frgkz FROM eban INTO (g_loekz,g_frgkz)
         WHERE banfn =  zmm_pur_tender_d_st-banfn
*+005 : Start
           AND loekz NE 'X'
           AND frgkz = 'B'.
*+005 : End

*-005 : Start
*    IF g_loekz = 'X'.
*
*      MESSAGE e970(zmm) WITH zmm_pur_tender_d_st-banfn.
*
*    ELSEIF g_frgkz NE 'B'.
*-005 : End

      IF sy-subrc NE 0.                                   "+005

        MESSAGE e971(zmm) WITH zmm_pur_tender_d_st-banfn.

      ENDIF.

*+008 : Start
    ELSE.
      MESSAGE e407(06).
    ENDIF.
*+008 : End

  ENDIF.


ENDMODULE.                 " VALID_BANFN  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_NIT_DATE  INPUT
*&---------------------------------------------------------------------*
* To make NIT date mandatory if tender value is more than 5 lakhs
*----------------------------------------------------------------------*
MODULE check_nit_date INPUT.

  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'. "+009

*    IF zmm_pur_tender_d_st-tndr_val GT 5000000 AND
    IF zmm_pur_tender_d_st-tndr_val GT 1000000 AND "added by cab_dns 04082015
       zmm_pur_tender_d_st-nitdate IS INITIAL.

*+008 : Start
      IF zmm_pur_tender_d_st-tndr_proc = 10 OR
         zmm_pur_tender_d_st-tndr_proc = 11 OR
         zmm_pur_tender_d_st-tndr_proc = 12 OR
         zmm_pur_tender_d_st-tndr_proc = 13 OR
         zmm_pur_tender_d_st-tndr_proc = 14 OR
         zmm_pur_tender_d_st-tndr_proc = 15 OR
         zmm_pur_tender_d_st-tndr_proc =  7 OR
         zmm_pur_tender_d_st-tndr_proc =  8 OR
         zmm_pur_tender_d_st-tndr_proc =  9.
      ELSE.
*+008 : End
        PERFORM display_nitdate.

        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-NITDATE'.

        MESSAGE e321(zmm) WITH text-021.

      ENDIF.                                       "+008

    ENDIF.

    IF NOT zmm_pur_tender_d_st-nitdate   IS INITIAL AND
       NOT zmm_pur_tender_d_st-st_sel_dt IS INITIAL.

      IF zmm_pur_tender_d_st-nitdate GT zmm_pur_tender_d_st-st_sel_dt.

        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-NITDATE'.

        MESSAGE e363(zmm).

      ENDIF.

    ENDIF.

  ENDIF.                                         "+009

ENDMODULE.                 " CHECK_NIT_DATE  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_PR_RCPT_DT  INPUT
*&---------------------------------------------------------------------*
* To check PR Receipt Date
*----------------------------------------------------------------------*
MODULE chk_pr_rcpt_dt INPUT.

  IF g_ok_code NE 'DISP'.


    IF NOT zmm_pur_tender_d_st-banfn  IS INITIAL AND
            zmm_tms_general-pr_rcpt_dt IS INITIAL.
**----------Start of change 30.06.2016 14:18:21 REKHA  -------------------
*      MESSAGE e127(zmm_oth).
**----------End  of change 30.06.2016 14:18:21 REKHA  -----------------


    ELSE.

      IF zmm_tms_general-pr_rcpt_dt GT sy-datum.

        MESSAGE e141(zmm_oth).

      ELSE.

* Set default value of EPC type under price bid tab as EPC type under
* General tab
        IF zmm_tms_pb-epc_typ_pb IS INITIAL.

          MOVE zmm_tms_general-epc_typ TO zmm_tms_pb-epc_typ_pb.

          PERFORM get_no_rfq_maint USING    zmm_pur_tender_d_st-banfn
                                   CHANGING zmm_tms_pb-no_req.

        ENDIF.

        PERFORM calc_various_dates USING  zmm_pur_tender_d_st-bstyp
                                          zmm_tms_general-pr_rcpt_dt.
      ENDIF.

    ENDIF.

    """""""""""""""""""""""""""""""""
    "added by lipsy on 11.05.2015 RD1K997136
    IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.

      IF zmm_tms_general-epc_typ = 'E' .

        """""""""""""""""""""""""""""""""""
        """"commented by lipsy on 25.05.2015 RD1K997320

*ZMM_TMS_PB-EPC_TYP_PB = 'E'.


        ""end of comment by lipsy on 25.05.2015 RD1K997320

        """""""""""""""""""""""""""""""""""""""""""""

        zmm_tms_tc-cpa = 'EPC'.

        """""""""""""""""""""""""""""""""""""""""
        """"added by lipsy on 25.05.2015 RD1K997320

        CLEAR:wa_cpa_dtl-ename,wa_cpa_dtl-desig_text.

      ELSE.
        IF zmm_tms_tc-cpa = 'EPC'.
          CLEAR:zmm_tms_tc-cpa.
        ENDIF.

        ""end of addition by lipsy on 25.05.2015 RD1K997320
        """""""""""""""""""""""""""""""""""""""""""

      ENDIF.


    ENDIF.

    "end of addition  by lipsy on 11.05.2015 RD1K997136
    """""""""""""""""""""""""""""""""""""

  ENDIF.

ENDMODULE.                 " CHK_PR_RCPT_DT  INPUT

*&---------------------------------------------------------------------*
*&      Module  SET_PRE_BID_DT_0500  INPUT
*&---------------------------------------------------------------------*
* To calculate scheduled date :
*  - Receipt of querry from Bidders
*  - Scrutiny and PBC Date
*----------------------------------------------------------------------*
MODULE set_pre_bid_dt_0500 INPUT.

  IF g_ok_code NE 'DISP'.

    IF zmm_pur_tender_d_st-bstyp = 'C'.

      PERFORM set_pre_bid_dt USING    zmm_tms_tc-pbc_stat
                                      zmm_pur_tender_d_st-sch_lt_sel_dt
                                      zmm_tms_general-lstk
                             CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                      zmm_tms_tc-pbc_sch_dt
                                      zmm_tms_tc-tc_met_pb_sch_dt
                                      zmm_tms_tc-reo_tsal_stat
                                      zmm_tms_tc-amd_issu_sch_dt
                                      zmm_tms_tc-reo_tsal_sch_dt
                                      zmm_tms_tc-rec_tsal_sch_dt
                                      zmm_tms_tc-subm_dl_sch_dt.

    ELSEIF zmm_pur_tender_d_st-bstyp = 'L'.

      PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                      zmm_pur_tender_d_st-tndr_val
                                      zmm_pur_tender_d_st-sch_tdrdt
                                      zmm_tms_tc-verf_iss_sch_dt
                                      zmm_tms_general-lstk
                             CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                      zmm_tms_tc-pbc_sch_dt
                                      zmm_tms_tc-amd_issu_sch_dt
                                      zmm_tms_tc-subm_dl_sch_dt.

    ENDIF.

  ENDIF.

ENDMODULE.                 " SET_PRE_BID_DT_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALID_EPC_TYP_PB  INPUT
*&---------------------------------------------------------------------*
* Validate EPC Type in Price Bid
*----------------------------------------------------------------------*
MODULE valid_epc_typ_pb INPUT.

  IF zmm_tms_general-epc_typ NE zmm_tms_pb-epc_typ_pb.

    IF zmm_tms_general-epc_typ = 'D' AND
       zmm_tms_pb-epc_typ_pb   = 'E'.

    ELSEIF zmm_tms_general-epc_typ = 'N' AND
         ( zmm_tms_pb-epc_typ_pb   = 'E' OR
           zmm_tms_pb-epc_typ_pb   = 'D' ).

    ELSE.

      MOVE zmm_tms_general-epc_typ TO zmm_tms_pb-epc_typ_pb.

    ENDIF.

  ENDIF.

ENDMODULE.                 " VALID_EPC_TYP_PB  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_ICMM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_icmm INPUT.



  IF  zmm_tms_tc-ic_mm IS NOT INITIAL.

    SHIFT zmm_tms_tc-ic_mm  LEFT DELETING LEADING '0'.





    REFRESH:itab_agr_users[].
    SELECT mandt uname agr_name from_dat to_dat
        FROM agr_users
        INTO CORRESPONDING FIELDS OF TABLE itab_agr_users
        WHERE uname = zmm_tms_tc-ic_mm
        AND agr_name IN ('D:MM_PUR_PO_APPROVE_IM','D:MM_SRV_IND_APPROVE_L2',
     'D:MM_SRV_IND_APPROVE_L3')
        AND to_dat >= sy-datum.
    IF sy-subrc = 0.
    ELSE.
      MESSAGE 'Please enter correct IC MM' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_ICMM  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_L1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_l1 INPUT.
  IF  zmm_tms_tc-l1 IS NOT INITIAL.

    SHIFT zmm_tms_tc-l1 LEFT DELETING LEADING '0'.



    REFRESH:itab_agr_users[].
    SELECT mandt uname agr_name from_dat to_dat
          FROM agr_users
          INTO CORRESPONDING FIELDS OF TABLE itab_agr_users
          WHERE uname =  zmm_tms_tc-l1
          AND agr_name IN
    ('D:MM_SRV_IND_APPROVE_L1' ,'D:MM_SRV_IND_APPROVE_1A','D:MM_SRV_IND_APPROVE_1B','D:MM_SRV_IND_APPROVE_1C'
     ,'D:MM_SRV_IND_APPROVE_1D','D:MM_SRV_IND_APPROVE_1E' )
     AND to_dat >= sy-datum.
    IF sy-subrc = 0.
    ELSE.
      MESSAGE 'Please enter correct L1' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_L1  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mm INPUT.
  IF NOT zmm_tms_tc-tc_member1_s IS INITIAL.
    PERFORM check_mm USING zmm_tms_tc-tc_member1_s.
*          CHANGING l_disc_cd_1s.
  ELSEIF NOT zmm_tms_tc-tc_member1 IS INITIAL.
    PERFORM check_mm USING zmm_tms_tc-tc_member1.
*          CHANGING l_disc_cd_1.
  ENDIF.
ENDMODULE.                 " CHECK_MM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_fi INPUT.
  IF NOT zmm_tms_tc-tc_member2_s IS INITIAL.
    PERFORM check_fi USING zmm_tms_tc-tc_member2_s.
  ELSEIF NOT zmm_tms_tc-tc_member2 IS INITIAL.
    PERFORM check_fi USING zmm_tms_tc-tc_member2.
  ENDIF.

ENDMODULE.                 " CHECK_FI  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDENTOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_indentor INPUT.

  IF NOT zmm_tms_tc-tc_member3_s IS INITIAL.
    PERFORM check_indentor USING zmm_tms_tc-tc_member3_s.
  ELSEIF NOT zmm_tms_tc-tc_member3 IS INITIAL.
    PERFORM check_indentor USING zmm_tms_tc-tc_member3.
  ENDIF.



ENDMODULE.                 " CHECK_INDENTOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_CPA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_cpa INPUT.
  DATA:p_ename_cpa TYPE pa0001-ename.

**----------Start of change 27.06.2016 16:51:26 -------------------
*SELECT SINGLE ename FROM pa0001 INTO p_ename_cpa
*         WHERE pernr = zmm_tms_tc-cpa  AND
*               endda = '99991231'.
*
  SELECT SINGLE ename FROM zpa0001 INTO p_ename_cpa
         WHERE pernr = zmm_tms_tc-cpa  AND
               endda = '99991231'.
**----------End  of change 27.06.2016 16:51:26 -----------------

  IF sy-subrc NE 0.

    IF  zmm_tms_tc-cpa = 'EPC'.

      IF zmm_tms_general-epc_typ = 'E' OR zmm_tms_pb-epc_typ_pb = 'E'.
      ELSE.
        IF g_ok_code = 'DISP'.
        ELSE.
          MESSAGE 'Please Enter valid CPF no' TYPE 'E'.
        ENDIF.
      ENDIF.

    ELSE.
      IF g_ok_code = 'DISP'.
      ELSE.
        MESSAGE 'Please Enter valid CPF no' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_CPA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TENDER_VAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tender_val INPUT.

  IF zmm_pur_tender_d_st-tndr_val LE 0.

    MESSAGE 'Tender value should be greater than Zero' TYPE 'W'.
  ENDIF.

ENDMODULE.                 " CHECK_TENDER_VAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TNDR_PROC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tndr_proc INPUT.

  IF zmm_pur_tender_d_st-bstyp = 'B' OR
     zmm_pur_tender_d_st-bstyp = 'L' OR
     zmm_pur_tender_d_st-bstyp = 'S'.

    zmm_pur_tender_d_st-tndr_proc = '17'.

  ELSEIF zmm_pur_tender_d_st-bstyp = 'C' .

    zmm_pur_tender_d_st-tndr_proc = '16'.

  ENDIF.


ENDMODULE.                 " FILL_TNDR_PROC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_APHA_NUMARIC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_apha_numaric INPUT.

  IF zmm_pur_tender_d_st-dlg_offic CA sy-abcde OR zmm_pur_tender_d_st-dlg_offic CA '0123456789'.
  ELSE.
    MESSAGE 'Dealing officer code can only be alpha numeric' TYPE 'E'.
  ENDIF.



ENDMODULE.                 " CHECK_APHA_NUMARIC  INPUT

*--- INCLUDE: MZMMTMSO01 ---*
*&---------------------------------------------------------------------*
*&      Module  POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
* To popup important information messages as user execute tr. code
* ZMMIMS.
*----------------------------------------------------------------------*
MODULE pop_message OUTPUT.

  IF g_exec = 'X'.

    CLEAR g_exec.
*
    CALL FUNCTION 'ZMM_POPUP_TMS_MESSAGE'
      EXPORTING
        arbgb             = 'ZMM'
        msgnr             = '861'
        msgty             = 'I'
      EXCEPTIONS
        user_cancel       = 1
        message_not_found = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDMODULE.                 " POP_MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0100.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR  'T100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0250  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0100.
*----------------------------------------------------------------------*
MODULE status_0150 OUTPUT.
  SET PF-STATUS 'S150'.
  SET TITLEBAR 'T150'.
ENDMODULE.                 " STATUS_0250  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*     To set the pf status & title for screen 0200.
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  CASE g_ok_code.

    WHEN 'NEW'.

      REFRESH ist_pf_status.

      MOVE 'ATCH' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'LIST' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
*     SET PF-STATUS 'S200'.
      SET TITLEBAR 'T200'.

    WHEN 'CHNG'.

      REFRESH ist_pf_status.
      MOVE 'LIST' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
*     SET PF-STATUS 'S200'.
      SET TITLEBAR 'T20C'.

    WHEN 'DISP'.
      REFRESH ist_pf_status.
      MOVE 'SAVE' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'ATCH' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
      SET TITLEBAR 'T20D'.

*+002 : Start
    WHEN 'APRV'.

      REFRESH ist_pf_status.
      MOVE 'LIST' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'ATCH' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
      SET TITLEBAR 'T20A'.
*+002 : End

  ENDCASE.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  REFRESH ist_tab.

  CASE sy-tcode.
    WHEN 'ZMMTDR3'.
*      GET PARAMETER ID 'SUB' FIELD zmm_pur_tender_d_st-submi.
      MOVE 'BU' TO wa_tab-fcode.
      APPEND wa_tab TO ist_tab.
      MOVE 'TDRGE' TO wa_tab-fcode.
      APPEND wa_tab TO ist_tab.
    WHEN 'ZMMTDR2'.
      MOVE 'TDRGE' TO wa_tab-fcode.
      APPEND wa_tab TO ist_tab.
      IF g_option IS INITIAL.
        MOVE 'BU' TO wa_tab-fcode.
        APPEND wa_tab TO ist_tab.
      ENDIF.
  ENDCASE.

  IF g_action = 'X'.
    MOVE 'TDRGE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab.
  ENDIF.

  SET PF-STATUS '100' EXCLUDING ist_tab.
  SET TITLEBAR '001' WITH tstct-ttext.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DEFA-DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE defa-data OUTPUT.
*Get the title with refrence to T.code
  CALL FUNCTION 'TSTCT_SINGLE_READ'
    EXPORTING
      sprache    = sy-langu
*     tcode      = sy-tcode
      tcode      = g_tcode
    IMPORTING
      wtstct     = tstct
    EXCEPTIONS
      wrong_call = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*-----Get Current Fiscal year
  IF NOT zmm_pur_tender_d_st-tdrsigner IS INITIAL.

    PERFORM get_name_design USING    zmm_pur_tender_d_st-tdrsigner
                            CHANGING wa_tdrsigner-ename
                                     wa_tdrsigner-desig_text.
  ELSE.

    CLEAR : wa_tdrsigner.

  ENDIF.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """ADDED BY LIPSY ON 27.10.2014  FOR  total pr value
                                                            "RD1K994950

  if g_ok_code_300 = 'MORE' ." TO RESTRICT ONLY AT THE MOMENT CASES OF PR ENTRY.
  ELSE.

    if zmm_pur_tender_d_st-submi is not initial.
      refresh:ist_eban_all[].
      select banfn banfn2 banfn3 banfn4 banfn5 from zmm_pur_tender_d  "+001
           into corresponding fields of table ist_eban_all
                where submi = zmm_pur_tender_d_st-submi.


      """"""""""get all prs
      refresh:ist_eban[].

      if not ist_eban_all[] is initial.
        clear:wa_eban_all,wa_eban.
        loop at ist_eban_all into wa_eban_all.

*PR 1
          if  wa_eban_all-banfn is not INITIAL.
            move  wa_eban_all-banfn to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.
*PR 2
          if not  wa_eban_all-banfn2 is initial.
            move  wa_eban_all-banfn2 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

*PR 3
          if not  wa_eban_all-banfn3 is initial.
            move  wa_eban_all-banfn3 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

*PR 4
          if not  wa_eban_all-banfn4 is initial.
            move  wa_eban_all-banfn4 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

*PR 5
          if not  wa_eban_all-banfn5 is initial.
            move  wa_eban_all-banfn5 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

          clear: wa_eban_all,wa_eban.
        endloop.

        sort ist_eban by banfn.
        delete adjacent duplicates from ist_eban.

      endif.

      """""""""get all items
      if ist_eban[] IS not INITIAL.
        select banfn bnfpo statu txz01 menge preis waers werks badat from eban
          into corresponding fields of table ist_eban_t
          FOR ALL ENTRIES IN  ist_eban[]
          where banfn = ist_eban-banfn.
      endif.

*     bsart ne 'SWO'   and
*               statu =  'N'     and
*               loekz ne 'X'     and
*               frgkz =  'B'     and
*               erdat ge l_erdat.


      clear:wa_eban.

      clear:l_fval.
      loop at ist_eban into wa_eban.

        clear : wa_eban_t,l_rate_type,l_from_curr,
        l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp,v_pr_val.

        loop at ist_eban_t into wa_eban_t where banfn = wa_eban-banfn.

"""""""""""""""""""
"add by lipsy on 8.07.2015 RD1K997763
if wa_eban_t-loekz = ''.
"end of addition by lipsy on 8.07.2015 RD1K997763
""""""""""""""""""
          if wa_eban_t-waers ne 'INR'.

            clear : wa_erate,
                    l_rval.

            move 'M'             to l_rate_type.
            move wa_eban_t-waers to l_from_curr.
            move 'INR'           to l_to_curr.
            move wa_eban_t-badat to l_trans_dt.

            CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
              EXPORTING
                rate_type  = l_rate_type
                from_curr  = l_from_curr
                to_currncy = l_to_curr
                date       = l_trans_dt
              IMPORTING
                exch_rate  = wa_erate.

            CALL FUNCTION 'ROUND'
              EXPORTING
                decimals      = 2
                input         = wa_erate-exch_rate
                sign          = '+'
              IMPORTING
                output        = l_rval
              EXCEPTIONS
                input_invalid = 1
                overflow      = 2
                type_invalid  = 3
                others        = 4.

            if sy-subrc <> 0.
*              message id sy-msgid type 'I' number sy-msgno
*                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.

            l_temp  =  wa_eban_t-preis * wa_eban_t-menge .
            l_rlwrt =  l_temp * l_rval.
            l_erate =  l_rlwrt.

            l_fval = l_fval + l_erate.

          else.

            l_temp = wa_eban_t-preis * wa_eban_t-menge.

            l_fval = l_fval + l_temp.

          endif.



          clear : wa_eban_t,l_rate_type,l_from_curr,
        l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp.

""""""""""
"add by lipsy on 8.07.2015 RD1K997763
endif.
"end of addition  by lipsy on 8.07.2015 RD1K997763
"""""""""""""
        endloop.


        clear:wa_eban.
      endloop.

      move l_fval to v_pr_val.

    endif.

  ENDIF.
  """end of ADDition BY LIPSY ON 27.10.2014  FOR  total pr value
                                                            "RD1K994950
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* CHECK sy-tcode = 'ZMMTDR1'.
  CHECK g_tcode = 'ZMMTDR1'.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = sy-datum
    IMPORTING
      e_gjahr        = zmm_pur_tender_d_st-mjahr
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Added by Kalpesh

  IF zmm_pur_tender_d_st-tdrdt IS INITIAL.

    zmm_pur_tender_d_st-tdrdt = sy-datum.

  ENDIF.

**

ENDMODULE.                 " DEFA-DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attr OUTPUT.

  LOOP AT SCREEN.
    IF zmm_pur_tender_d_st-bsart+0(1) = 'E'.
      IF screen-group3 = 'SRM'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*---Create Mode
*    IF sy-tcode = 'ZMMTDR1' OR
*       g_option = 'X'.

    IF g_tcode = 'ZMMTDR1' OR
       g_option = 'X'.

      IF screen-name = 'ZMM_PUR_TENDER_D_ST-SUBMI'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
*      IF zmm_pur_tender_d_st-bstyp = 'C'.
*        IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*          screen-input = '1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ELSE.
*        CLEAR zmm_pur_tender_d_st-nitdate.
*      ENDIF.
    ENDIF.
*---Change or Display Mode
*   IF sy-tcode NE 'ZMMTDR1'.
    IF g_tcode NE 'ZMMTDR1'.

      IF screen-name = 'ZMM_PUR_TENDER_D_ST-SUBMI'.
        screen-required = '1'.
        MODIFY SCREEN.
      ENDIF.
      IF screen-group1 = '110'.
        IF g_option IS INITIAL.
          screen-input = '0'.
          screen-invisible = '1'.
        ELSE.
          screen-input = '1'.
          screen-invisible = '0'.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*---Change Mode
*   IF sy-tcode EQ 'ZMMTDR2'.
    IF g_tcode EQ 'ZMMTDR2'.

      IF screen-group2 = '111'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
      IF zmm_pur_tender_d_st-tdrsts = 'C' OR
         zmm_pur_tender_d_st-tdrsts = 'X'.
        IF screen-group4 = '113'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

   """"""""""""""""""""""""""""""""
    "added by lipsy on 27.02.2015 RD1K995870

    if sy-uname+0(3) = 'CMM'.
 if zmm_pur_tender_d_st-tdrsts = 'X'.
if screen-name = 'ZMM_PUR_TENDER_D_ST-TNDR_FEE' or
screen-name = 'ZMM_PUR_TENDER_D_ST-TNDR_PROC' or
screen-name =  'ZMM_PUR_TENDER_D_ST-TNNDR_TYP' or
screen-name =  'ZMM_PUR_TENDER_D_ST-TNDR_VAL' .
screen-input = 1.
MODIFY SCREEN.
endif.
endif.
endif.

     "end of addition by lipsy on 27.02.2015 RD1K995870

   """""""""""""""""""""""""""""""""""""""""""
    ENDIF.

*---Display Mode
*   IF sy-tcode EQ 'ZMMTDR3'.

    IF g_tcode EQ 'ZMMTDR3' OR sy-ucomm = 'ZMMTMSDISP'.
      IF screen-group1 = '110'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.

*+007 : Start
      IF zmm_pur_tender_d_st-prchk EQ 'X'.
        IF screen-group2 = 'DIS'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF screen-group2 = 'DIS'.
          screen-input = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
*+007 : End

    ENDIF.

*+006 : Start
    IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
      IF zmm_pur_tender_d_st-prchk EQ 'X'.

        IF screen-group3 = 'PR'.
*        CLEAR zmm_pur_tender_d_st-banfn.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSEIF zmm_pur_tender_d_st-prchk IS INITIAL.

        IF screen-group3 = 'PR'.
          screen-input = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.
    ENDIF.
*+006 : End

  ENDLOOP.
* Begin of <RD1K985058> on 21052013 by Sudhir Sharma
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
    IF NOT zmm_pur_tender_d_st-tndr_val IS INITIAL OR
       NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.
      IF zmm_pur_tender_d_st-tndr_val < 500000 OR
         zmm_pur_tender_d_st-tndr_proc = 10 OR
         zmm_pur_tender_d_st-tndr_proc = 11 OR
         zmm_pur_tender_d_st-tndr_proc = 12 OR
         zmm_pur_tender_d_st-tndr_proc = 13 OR
         zmm_pur_tender_d_st-tndr_proc = 14 OR
         zmm_pur_tender_d_st-tndr_proc = 15 OR
         zmm_pur_tender_d_st-tndr_proc =  7 OR
         zmm_pur_tender_d_st-tndr_proc =  8 OR
         zmm_pur_tender_d_st-tndr_proc =  9.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
* End of <> on 21052013
*---Start NN 03.09.2003
* CHECK sy-tcode EQ 'ZMMTDR2'.
  CHECK g_tcode EQ 'ZMMTDR2'.

  IF zmm_pur_tender_d_st-bsart = 'MLLM' OR
     zmm_pur_tender_d_st-bsart = 'MLLN' OR
     zmm_pur_tender_d_st-bsart = 'MLMM' OR
     zmm_pur_tender_d_st-bsart = 'MLMN' OR
     zmm_pur_tender_d_st-bsart = 'MRCM' OR
     zmm_pur_tender_d_st-bsart = 'MRCN' OR
     zmm_pur_tender_d_st-bsart = 'MSTA' OR
     zmm_pur_tender_d_st-bsart = 'SBP'  OR
     zmm_pur_tender_d_st-bsart = 'SGL'  OR
     zmm_pur_tender_d_st-bsart = 'SLT'  OR
     zmm_pur_tender_d_st-bsart = 'SST'.
    LOOP AT SCREEN.
      IF screen-group2 = 'DSP'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.

*      IF zmm_pur_tender_d_st-bstyp = 'C'.
*        IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*          screen-input = '1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ELSE.
*        CLEAR zmm_pur_tender_d_st-nitdate.
*        IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*          screen-input = '0'.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDIF.

    ENDLOOP.
  ENDIF.
*---ENd NN 03.09.2003

ENDMODULE.                 " set_screen_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  check_authorisation  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_authorisation OUTPUT.
  PERFORM authority_check_tcode.
ENDMODULE.                 " check_authorisation  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_COMMON  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_screen_common OUTPUT.

  CASE g_ok_code.

    WHEN 'NEW' OR 'CHNG'.

      IF zmm_tms_general-epc_typ = 'N'.

        LOOP AT SCREEN.
          IF screen-group4 = 'EPC'.
            screen-input  = '0'.
            screen-output = '1'.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

        g_dmode_epc = 'X'.                                  "+001

      ELSE.                                                 "+001

        CLEAR : g_dmode_epc.                                "+001

      ENDIF.

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 22.10.2014 for making actual date of technical bid,price bid greyed RD1K994950

      LOOP AT SCREEN.


        if zmm_pur_tender_d_st-bsart+0(2) = 'ET'.
          if screen-name = 'ZMM_TMS_TB-TEND_OP_ACT_DT' or screen-name = 'ZMM_TMS_PB-PR_BID_OP_ACT_DT'.
            if sy-uname+0(3) = 'CMM' .
            else.
              screen-input = 0.
            endif.
            MODIFY SCREEN.
          endif.
        endif.

      ENDLOOP.


      "end of addition  by lipsy on 22.10.2014 for making actual date of technical bid,price bid greyed RD1K994950
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 11.05.2015 RD1K997136
if ZMM_TMS_GENERAL-EPC_TYP = 'E'.

  """""""""""""""""""""""""""""""""
  """"commented by lipsy on 25.05.2015 RD1K997320
  " or ZMM_TMS_PB-EPC_TYP_PB = 'E'.

  "end of comment by lipsy on 25.05.2015 RD1K997320

  """"""""""""""""""""""""""""""""""""""

ZMM_TMS_TC-CPA = 'EPC'.

""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""
""""added by lipsy on 25.05.2015 RD1K997320

clear:wa_cpa_dtl-ename,wa_cpa_dtl-desig_text.

else.
  if ZMM_TMS_TC-CPA = 'EPC'.
    clear:ZMM_TMS_TC-CPA.
    endif.

""end of addition by lipsy on 25.05.2015 RD1K997320
"""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""

  endif.

"""""""""""""""""""""""""""""""""""""""""""""""""""
""""commented by lipsy on 25.05.2015 RD1K997320

*if ZMM_TMS_GENERAL-EPC_TYP = 'E' .
*
*  ZMM_TMS_PB-EPC_TYP_PB = 'E'.
*
*  endif.

  """""""""""""end of comment by lipsy on 25.05.2015 RD1K997320
  """"""""""""""""""""""""""""""""""""""""""""""""
"end of addition  by lipsy on 11.05.2015 RD1K997136

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


*   WHEN 'DISP'.                                            "-002
    WHEN 'DISP' OR 'APRV'.                                  "+002
      LOOP AT SCREEN.
        IF screen-group3 = '003'.
          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

  ENDCASE.


  """""""""""""""""
  """"""""added by lipsy on 15.05.2015 RD1K997136
  if ZMM_TMS_TC-CPA is not initial.

    call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input  = ZMM_TMS_TC-CPA
        importing
          output = ZMM_TMS_TC-CPA.

    endif.

  "end of addition by lipsy on 15.05.2015 RD1K997136
  """"""""""""""""""""""

ENDMODULE.                 " INIT_SCREEN_COMMON  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_0400  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen 0400
*----------------------------------------------------------------------*
MODULE init_screen_0400 OUTPUT.

  CASE g_ok_code.

    WHEN 'NEW' OR 'CHNG'.

      LOOP AT SCREEN.

        IF g_spfc = 'X'.

          CLEAR g_dmode_spfc.

          IF screen-group2 = 'MET'.
            screen-input   = '0'.
            screen-output  = '1'.
            MODIFY SCREEN.
          ENDIF.

        ELSE.

          g_dmode_spfc = 'X'.

          IF screen-group2 = 'MET'.
            screen-input   = '1'.
            screen-output  = '1'.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

*   WHEN 'DISP'.                                            "-002
    WHEN 'DISP' OR 'APRV'.                                  "+002
      LOOP AT SCREEN.
        IF screen-group2 = 'MET'.
          screen-input   = '0'.
          screen-output  = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " INIT_SCREEN_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_0500  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen 0500
*----------------------------------------------------------------------*
MODULE init_screen_0500 OUTPUT.

  """""""""""""""""""""""""
  "added by lipsy on 2.03.2015  for making tender commitee default RD1K995870

if  v_initial is INITIAL.
 ZMM_TMS_TC-TC_STAT = 'X'.
 v_initial = 'X'.
endif.

  "end of addition by lipsy on 2.03.2015  for making tender commitee default RD1K995870
  """"""""""""""""""""""""""

  LOOP AT SCREEN.

    IF zmm_tms_tc-tc_stat = 'X'.

      IF screen-group2 = 'CHK'.
        screen-input     = '1'.
        screen-invisible = '0'.
        MODIFY SCREEN.
      ENDIF.

*18.10.2012 : Start
***********************************************************************
* Set attribute of check box
***********************************************************************
      IF zmm_tms_tc-tc_member1 IS INITIAL.

        IF screen-group4 = 'CK1'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK1'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member2 IS INITIAL.

        IF screen-group4 = 'CK2'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK2'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member3 IS INITIAL.

        IF screen-group4 = 'CK3'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK3'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member4 IS INITIAL.

        IF screen-group4 = 'CK4'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK4'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member5 IS INITIAL.

        IF screen-group4 = 'CK5'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK5'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

***********************************************************************
* Set attribute of substitute tc member
***********************************************************************
      IF zmm_tms_tc-tc_ms1_chk = 'X'.

        IF screen-group4 = 'SB1'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB1'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member1_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms2_chk = 'X'.

        IF screen-group4 = 'SB2'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB2'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member2_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms3_chk = 'X'.

        IF screen-group4 = 'SB3'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB3'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member3_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms4_chk = 'X'.

        IF screen-group4 = 'SB4'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB4'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member4_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms5_chk = 'X'.

        IF screen-group4 = 'SB5'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB5'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member5_s.

        ENDIF.

      ENDIF.

***********************************************************************
* Set attribute of tc member
***********************************************************************
      IF zmm_tms_tc-tc_ms1_chk = 'X'.

        IF screen-group4 = 'TC1'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC1'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms2_chk = 'X'.

        IF screen-group4 = 'TC2'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC2'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms3_chk = 'X'.

        IF screen-group4 = 'TC3'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC3'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms4_chk = 'X'.

        IF screen-group4 = 'TC4'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC4'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms5_chk = 'X'.

        IF screen-group4 = 'TC5'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC5'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-pbc_stat = 'Y'.

        IF screen-group4 = 'PBC'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'PBC'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.
*+18.10.2012 : End

    ELSE.

      IF screen-group2 = 'CHK'.
        screen-input     = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.

*+18.10.2012 : Start
      IF zmm_tms_tc-pbc_stat = 'Y'.

        IF screen-group4 = 'PBC'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'PBC'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.
*+18.10.2012 : End

    ENDIF.

*+007 : Start
* Enable fields : 1. Request for tender enquiries from bidders
*                 2. Verification & issue of tender to bidders
* If tender is limited tender
    IF zmm_pur_tender_d_st-bstyp NE 'L'.

      IF screen-group4 = 'LTD'.
        screen-input = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

*+007 : End

*+009 : Start
    IF zmm_tms_general-epc_typ = 'E'.
      IF screen-group1 = 'CPA'.

  """"""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 15.05.2015 for making cpa open  RD1K997136

     if SCREEN-NAME = 'ZMM_TMS_TC-CPA'.
     ELSE.
  "end of addition by lipsy on 15.05.2015 for making cpa open  RD1K997136
  """""""""""""""""""""""""""""""""""""""""""""""""""""

        screen-input    = '0'.

 """""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 15.05.2015 for making cpa open  RD1K997136

    endif.

  "end of addition by lipsy on 15.05.2015 for making cpa open    RD1K997136

 """"""""""""""""""""""""""""""""""""""""""""""""


        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*+009 : End

  ENDLOOP.

ENDMODULE.                 " INIT_SCREEN_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_EDITOR  OUTPUT
*&---------------------------------------------------------------------*
*   To Set editor in change/display mode : Screen 0700
*----------------------------------------------------------------------*
MODULE set_editor OUTPUT.
  PERFORM set_editor USING g_dmode.
ENDMODULE.                 " SET_EDITOR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_EDITOR_SPFC  OUTPUT
*&---------------------------------------------------------------------*
*   To Set editor in change/display mode : Screen 0400
*----------------------------------------------------------------------*
MODULE set_editor_spfc OUTPUT.
  PERFORM set_editor_spfc USING g_dmode_spfc.
ENDMODULE.                 " SET_EDITOR_SPFC  OUTPUT

*+001 : Start
*&---------------------------------------------------------------------*
*&      Module  SET_EDITOR_EPC  OUTPUT
*&---------------------------------------------------------------------*
*   To Set editor in change/display mode : Screen 0800
*----------------------------------------------------------------------*
MODULE set_editor_epc OUTPUT.
  PERFORM set_editor_epc USING g_dmode_epc.
ENDMODULE.                 " SET_EDITOR_EPC  OUTPUT
*+001 : End

*&---------------------------------------------------------------------*
*&      Module  SET_LOI_FIELD  OUTPUT
*&---------------------------------------------------------------------*
* To set screen attribute of LOI fields
*----------------------------------------------------------------------*
MODULE set_loi_field OUTPUT.

  IF zmm_tms_pb-no_pos GT 3.

*    CLEAR : zmm_tms_pb-loi_1_sch_dt,
*            zmm_tms_pb-loi_1_act_dt,
*            zmm_tms_pb-loi_2_sch_dt,
*            zmm_tms_pb-loi_2_act_dt,
*            zmm_tms_pb-loi_3_sch_dt,
*            zmm_tms_pb-loi_3_act_dt.
    CLEAR : zmm_tms_pb-loi_2_sch_dt,
            zmm_tms_pb-loi_2_act_dt.

    CLEAR : g_loi_dt2,g_loi_dt3.

*    g_loi_dt2 = text-005.
    g_loi_dt3 = text-005.
    LOOP AT SCREEN.

*      IF screen-group4 = 'LOI'.
*
*        screen-input = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*
*      ENDIF.
      IF screen-group4 = '002'.

        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.

      ENDIF.
    ENDLOOP.

  ELSE.

*    CLEAR : zmm_tms_pb-loi_1_sch_dt,
*            zmm_tms_pb-loi_1_act_dt,
*            zmm_tms_pb-loi_2_sch_dt,
*            zmm_tms_pb-loi_2_act_dt.
    IF zmm_tms_pb-no_pos EQ 2.
      CLEAR : zmm_tms_pb-loi_3_sch_dt,
              zmm_tms_pb-loi_3_act_dt.
    ENDIF.
    IF zmm_tms_pb-no_pos EQ 1.
      CLEAR : zmm_tms_pb-loi_2_sch_dt,
              zmm_tms_pb-loi_2_act_dt.
      CLEAR : zmm_tms_pb-loi_3_sch_dt,
              zmm_tms_pb-loi_3_act_dt.
    ENDIF.
    g_loi_dt2 = text-003.
    g_loi_dt3 = text-004.

  ENDIF.

ENDMODULE.                 " SET_LOI_FIELD  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DEFAULT_PR_PO_REL_DT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE default_pr_po_rel_dt OUTPUT.

*In table CDPOS, Put  OBJECTCLAS- BANF OBJECTID- PR NumberFNAME- FRGKZ
*Execute.
*Take lowest CHANGENR and put it in table CDHDR in field CHANGENR.
*Also enter OBJECTCLAS- BANF, OBJECTID- PR Number and get UDATE.
*-007 : Start
*  DATA : ist_cdhdr TYPE TABLE OF cdhdr,
*         ist_cdpos TYPE TABLE OF cdpos,
*         ist_cdpos_po TYPE TABLE OF cdpos,
*         wa_cdpos TYPE cdpos,
*         wa_cdhdr TYPE cdhdr,
*         l_ebeln TYPE eban-ebeln.
*
*  CLEAR : ist_cdhdr ,ist_cdpos,l_ebeln.
*  REFRESH : ist_cdhdr ,ist_cdpos.
*-007 : End

*+007 : Start
  DATA : l_ebeln TYPE eban-ebeln.
*+007 : End

  PERFORM read_change_doc USING 'BANF'  zmm_pur_tender_d_st-banfn  'FRGKZ'
        CHANGING zmm_tms_general-pr_ff_rel_dt.

  SELECT EBELN FROM EBAN
 INTO L_EBELN UP TO 1 ROWS WHERE BANFN = ZMM_PUR_TENDER_D_ST-BANFN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT SINGLE SUBMI from ekko INTO @data(v_SUBMI)
    WHERE ebeln = @l_ebeln.

    IF v_SUBMI Ne zmm_pur_tender_d_st-submi .
    clear l_ebeln.
    ENDIF.


  PERFORM read_change_doc USING 'EINKBELEG'  l_ebeln  'FRGKE'
        CHANGING zmm_tms_general-po_ff_rel_dt.
*  DATA : BEGIN  OF ist_editpos OCCURS 0 .
*          INCLUDE STRUCTURE cdshw .
*  DATA :  user LIKE sy-uname ,
*          date LIKE sy-datum ,
*  END OF ist_editpos .
*  DATA :   i_editpos TYPE TABLE OF cdshw WITH HEADER LINE .
*  DATA : wa_header LIKE cdhdr .
*  objectclass = 'BANF'.
*  objectid = ZMM_PUR_TENDER_D_ST-BANFN.
*  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
*    EXPORTING
*      objectclass = objectclass
*      objectid    = objectid
*      username    = space
*    TABLES
*      i_cdhdr     = tcdhdr
*    EXCEPTIONS
*      OTHERS      = 1.
*
*  IF sy-subrc =  0.
*
*    SORT tcdhdr asCENDING BY changenr.
*    READ TABLE tcdhdr index 1.
**    LOOP AT  tcdhdr .
*    CLEAR : i_editpos, ist_editpos , wa_header .
*    REFRESH i_editpos .
*    CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
*      EXPORTING
*        changenumber            = tcdhdr-changenr
*      IMPORTING
*        header                  = wa_header
*      TABLES
*        editpos                 = i_editpos
*      EXCEPTIONS
*        no_position_found       = 1
*        wrong_access_to_archive = 2
*        OTHERS                  = 3.
*    IF sy-subrc =  0.
*      LOOP AT i_editpos WHERE fname = 'FRGKZ' .
**          MOVE-CORRESPONDING i_editpos TO ist_editpos.
**          ist_editpos-user = wa_header-username .
**          ist_editpos-date = wa_header-udate .
**          APPEND ist_editpos .
*        ZMM_TMS_GENERAL-PR_FF_REL_DT = ist_cdhdr-udate.
*      ENDLOOP.
*    ENDIF.
**    ENDLOOP .
*  endif.
*  SORT tcdhdr asCENDING BY changenr.
*  READ TABLE tcdhdr index 1.
*data : ist_cdpos TYPE STANDARD TABLE OF cdpos.
*
*    SELECT * FROM cdpos
*          INTO TABLE ist_cdpos
*          WHERE objectclas EQ 'BANF' AND
**                tabname EQ 'EKKO' AND
*                objectid EQ tcdhdr-objectid AND
*                changenr EQ tcdhdr-changenr AND
*                fname EQ ' FRGKZ'.

*  ZMM_TMS_GENERAL-PR_FF_REL_DT = tcdhdr-udate.
*  read table tcdhdr index 1.
*  CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
*    EXPORTING
*      changenumber = tcdhdr-changenr
*    TABLES
*      editpos      = lt_cdshw
*    EXCEPTIONS
*      OTHERS       = 1.
*
*  LOOP AT lt_cdshw.
*    IF lt_cdshw-fname EQ 'FRGKZ'.
*
*    endif.
*  endloop.
*  if not ZMM_PUR_TENDER_D_ST-SUBMI is initial.
**  ZMM_TMS_GENERAL-PO_FF_REL_DT
*    select single * from ekko
*    where submi = ZMM_PUR_TENDER_D_ST-SUBMI
*    and ebeln = '4010009865'.
*
*
*    DATA: BEGIN OF ICDHDR OCCURS 50.
*            INCLUDE STRUCTURE CDHDR.
*    DATA: END OF ICDHDR.
*
*    DATA: BEGIN OF ICDSHW OCCURS 50.
*            INCLUDE STRUCTURE CDSHW.
*    DATA: END OF ICDSHW.
*
*    DATA: BEGIN OF ITAB OCCURS 50,
*            BEGIN OF EKKEY,
*              EBELN LIKE EKET-EBELN,
*              EBELP LIKE EKET-EBELP,
*
*              ETENR LIKE EKET-ETENR,
*            END OF EKKEY,
*            CHANGENR LIKE CDHDR-CHANGENR,
*            UDATE    LIKE CDHDR-UDATE,
*            UTIME    LIKE CDHDR-UTIME,
*            USERNAME LIKE CDHDR-USERNAME,
*            CHNGIND  LIKE CDSHW-CHNGIND,
*            FTEXT    LIKE CDSHW-FTEXT,
*            OUTLEN   LIKE CDSHW-OUTLEN,
*            F_OLD    LIKE CDSHW-F_OLD,
*            F_NEW    LIKE CDSHW-F_NEW,
*          END OF ITAB.
*    CLEAR CDHDR.
*    CLEAR CDPOS.
*    CDHDR-OBJECTCLAS = 'EINKBELEG'.
*    CDHDR-OBJECTID   = EKKO-EBELN.
*
*    CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
*      EXPORTING
*        DATE_OF_CHANGE    = CDHDR-UDATE
*        OBJECTCLASS       = CDHDR-OBJECTCLAS
*        OBJECTID          = CDHDR-OBJECTID
*        TIME_OF_CHANGE    = CDHDR-UTIME
*        USERNAME          = CDHDR-USERNAME
*      TABLES
*        I_CDHDR           = ICDHDR
*      EXCEPTIONS
*        NO_POSITION_FOUND = 1
*        OTHERS            = 2.
*
*    CHECK SY-SUBRC EQ 0.
*    DELETE ICDHDR WHERE CHANGE_IND EQ 'I'.
*    CHECK NOT ICDHDR[] IS INITIAL.
*    LOOP AT ICDHDR.
**    CHECK ICDHDR-UDATE IN XUDATE.
**    CHECK ICDHDR-USERNAME IN XNAME.
*      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
*        EXPORTING
*          CHANGENUMBER      = ICDHDR-CHANGENR
*        IMPORTING
*          HEADER            = CDHDR
*        TABLES
*          EDITPOS           = ICDSHW
*        EXCEPTIONS
*          NO_POSITION_FOUND = 1
*          OTHERS            = 2.
*      CHECK SY-SUBRC EQ 0.
*      LOOP AT ICDSHW.
*        CHECK ICDSHW-TEXT_CASE EQ SPACE.
*        MOVE-CORRESPONDING ICDSHW TO ITAB.
*        MOVE-CORRESPONDING ICDHDR TO ITAB.
*        MOVE ICDSHW-TABKEY+3 TO ITAB-EKKEY.
*        APPEND ITAB.
*      ENDLOOP.
*    ENDLOOP.

*  endif.

ENDMODULE.                 " DEFAULT_PR_PO_REL_DT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_PID_0150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_pid_0150 OUTPUT.

  IF sy-tcode = 'ZMMTMSDISP' AND g_check = 'X'.

    g_ok_code = 'DISP'.

    CLEAR g_check.

    GET PARAMETER ID 'ZTMS' FIELD zmm_pur_tender_d_st-submi.
    g_dynnr = '0300'.
  ENDIF.
ENDMODULE.                 " GET_PID_0150  OUTPUT
**&---------------------------------------------------------------------*
**&      Module  CHECK_VAL_PROC  OUTPUT *Added by CAB_DHIRAJ : Start +003
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE CHECK_VAL_PROC OUTPUT.
*
*   CLEAR : g_tndr_proc,
*          g_tndr_val.
*g_tndr_proc = zmm_pur_tender_d_st-tndr_proc.
*g_tndr_val = zmm_pur_tender_d_st-tndr_val.
*IF NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL AND
*   NOT zmm_pur_tender_d_st-tndr_val IS INITIAL.
*
*    IF zmm_pur_tender_d_st-tndr_val gt 5000000  AND
*      ( zmm_pur_tender_d_st-tndr_proc eq '1' OR
*       zmm_pur_tender_d_st-tndr_proc eq '16' OR
*      zmm_pur_tender_d_st-tndr_proc eq '17' OR
*      zmm_pur_tender_d_st-tndr_proc eq '2' OR
*      zmm_pur_tender_d_st-tndr_proc eq '3' OR
*      zmm_pur_tender_d_st-tndr_proc eq '4' OR
*      zmm_pur_tender_d_st-tndr_proc eq '5' OR
*       zmm_pur_tender_d_st-tndr_proc eq '6' ).
*      LOOP AT SCREEN.
*      IF SCREEN-NAME = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*        SCREEN-REQUIRED = 1.
*        SCREEN-INPUT = 1.
**        SCREEN-ACTIVE = 1.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*     ELSE.
** DATA: ZMM_PUR_TENDER_D_ST-NITDATE.
*
*
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*        SCREEN-REQUIRED = 0.
*        SCREEN-INPUT = 0.
**        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*
*    ENDIF.
**ELSE.
**   LOOP AT SCREEN.
**      IF SCREEN-NAME = ZMM_PUR_TENDER_D_ST-NITDATE.
**        SCREEN-INPUT = 0.
**        MODIFY SCREEN.
**      ENDIF.
**    ENDLOOP.
**ENDIF.
*ENDIF.
*ENDMODULE.                 " CHECK_VAL_PROC  OUTPUT *Added by CAB_DHIRAJ : end +003

*&---------------------------------------------------------------------*
*&      Module  CALC_VARIOUS_DATES  OUTPUT
*&---------------------------------------------------------------------*
* To calculate various dates
*----------------------------------------------------------------------*
MODULE calc_various_dates OUTPUT.

  IF g_ok_code NE 'DISP'.

    IF NOT zmm_pur_tender_d_st-banfn IS INITIAL AND
           zmm_tms_general-pr_rcpt_dt IS INITIAL.

**----------Start of change 30.06.2016 14:21:44 REKHA  -------------------
**   MESSAGE i127(zmm_oth). " Commented
**----------End  of change 30.06.2016 14:21:44 REKHA  -----------------


    ELSE.

      IF NOT zmm_pur_tender_d_st-banfn IS INITIAL AND
         NOT zmm_tms_general-pr_rcpt_dt IS INITIAL.

        PERFORM calc_various_dates USING  zmm_pur_tender_d_st-bstyp
                                          zmm_tms_general-pr_rcpt_dt.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CALC_VARIOUS_DATES  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIB_0700  OUTPUT
*&---------------------------------------------------------------------*
* Set screen attribute : screen 0700
*----------------------------------------------------------------------*
MODULE set_screen_attrib_0700 OUTPUT.

  IF zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    LOOP AT SCREEN.

      IF screen-group1 = 'EPC'.
        if ( screen-name = 'ZMM_TMS_PB-PR_BID_OP_ACT_DT' and sy-uname+0(3) = 'CMM' ).
        else.
          screen-input = '0'.
        endif.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

  ELSE.

    LOOP AT SCREEN.

      IF screen-group1 = 'EPC'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIB_0700  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_DEFAULT_VAL_0700  OUTPUT
*&---------------------------------------------------------------------*
* To set default value of EPC Type for price bid
*   - EPC Type for Price Bid
*   - Nos. of RFQ maintained
*----------------------------------------------------------------------*
MODULE set_default_val_0700 OUTPUT.

  IF zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    zmm_tms_pb-epc_typ_pb = zmm_tms_general-epc_typ.

  ENDIF.

  IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.

    PERFORM get_no_rfq_maint USING    zmm_pur_tender_d_st-banfn
                             CHANGING zmm_tms_pb-no_req.

  ENDIF.

ENDMODULE.                 " SET_DEFAULT_VAL_0700  OUTPUT

*--- INCLUDE: MZMMTMSTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPURTDRNUMGENTOP                                         *
*&                                                                     *
*&---------------------------------------------------------------------*
TYPE-POOLS: esp1.                                           "+002

TABLES : zmm_pur_trtyp,
         zmm_pur_tender_d,
         zmm_pur_tender_d_st,
         tstct,
         t024,
         dd07v,
         dfies,
         cdhdr,
        cdpos,ekko.

*Start*****************************************************************

TABLES : zmm_tms,
         zmm_tms_general,
         zmm_tms_tc,
         zmm_tms_tb,
         zmm_tms_pb,
         zmm_tms_epc.

TABLES : zmm_tmst. "Text table - zmm_tmst

CONTROLS : tms_ctrl TYPE TABSTRIP.

CONTROLS : tms_ctrl_tndr TYPE TABLEVIEW USING SCREEN 0300.

CONTROLS : tms_ctrl_gen  TYPE TABLEVIEW USING SCREEN 0400.

CONTROLS : tms_ctrl_tc   TYPE TABLEVIEW USING SCREEN 0500.

CONTROLS : tms_ctrl_tb   TYPE TABLEVIEW USING SCREEN 0600.

CONTROLS : tms_ctrl_pb   TYPE TABLEVIEW USING SCREEN 0700.

CONTROLS : tms_ctrl_epc  TYPE TABLEVIEW USING SCREEN 0800.
*End*******************************************************************
*---------------------------------------------------------------------*
*                Types                                                *
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_tabtype,
        fcode LIKE rsmpe-func,
      END OF ty_tabtype.
TYPES: BEGIN OF ty_ekpo,
        ebeln TYPE ekpo-ebeln,
        aedat TYPE ekpo-aedat,
        banfn TYPE ekpo-banfn,
        anfnr TYPE ekpo-anfnr,
      END OF ty_ekpo.

""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 27.10.2014  FOR  CHECKING ROLES FOR IC MM/L2/L3 , L1
                                                            "RD1K994950
types:begin of ty_agr_users,
    mandt type mandt,
    uname type xubname,
    agr_name type agr_name,
    from_dat type agr_fdate,
    to_dat type agr_tdate,

end of ty_agr_users.

DATA:itab_agr_users type table of ty_agr_users.
"END OF ADDITION BY LIPSY ON 27.10.2014 FOR  CHECKING ROLES FOR IC MM/L2/L3 , L1
                                                            "RD1K994950
""""""""""""""""""""""""""""""""""""


DATA : g_ok_100     LIKE sy-ucomm,
       g_sav_ok_100 LIKE g_ok_100.
DATA : g_action,
       g_option.

DATA l1_date TYPE sy-datum.

DATA : ist_tab TYPE STANDARD TABLE OF ty_tabtype WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
       wa_tab TYPE ty_tabtype.

*Start*****************************************************************
DATA : wa_zmm_tms TYPE zmm_tms.

DATA : BEGIN OF wa_cpa_dtl,
         ename TYPE pa0001-ename,
         desig_text TYPE zdesignation_rev-desig_text,
       END OF wa_cpa_dtl.

DATA : wa_indentor_dtl LIKE wa_cpa_dtl,
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 27.10.2014  FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950
       wa_ICMM_dtl like wa_cpa_dtl,
       wa_L1_dtl   like wa_cpa_dtl,
"END OF ADDITION BY LIPSY ON 27.10.2014 FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
       wa_tc_mem1      LIKE wa_cpa_dtl,
       wa_tc_mem2      LIKE wa_cpa_dtl,
       wa_tc_mem3      LIKE wa_cpa_dtl,
       wa_tc_mem4      LIKE wa_cpa_dtl,
       wa_tc_mem5      LIKE wa_cpa_dtl,
       wa_tdrsigner    LIKE wa_cpa_dtl.

DATA : wa_tc_mem1_s    LIKE wa_cpa_dtl,
       wa_tc_mem2_s    LIKE wa_cpa_dtl,
       wa_tc_mem3_s    LIKE wa_cpa_dtl,
       wa_tc_mem4_s    LIKE wa_cpa_dtl,
       wa_tc_mem5_s    LIKE wa_cpa_dtl.

*Declartion of structure & internal table for storing pf-status
DATA : BEGIN OF wa_pf_status,
        fcode LIKE rsmpe-func,
      END OF wa_pf_status.

DATA : ist_pf_status LIKE STANDARD TABLE OF wa_pf_status WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

* Declartion of structure & internal table for storing Instructions for
* TMS : Price bid
DATA : ist_zmm_tmst TYPE TABLE OF zmm_tmst,
       wa_zmm_tmst  TYPE zmm_tmst.

* Declartion of structure & internal table for storing Instructions for
* General : Methodology - Specfic
DATA : ist_zmm_tmst_spfc TYPE TABLE OF zmm_tmst,
       wa_zmm_tmst_spfc  TYPE zmm_tmst.

*+001 : Start
* Declartion of structure & internal table for storing Instructions for
* TMS : EPC
DATA : ist_zmm_tmst_epc TYPE TABLE OF zmm_tmst,
       wa_zmm_tmst_epc  TYPE zmm_tmst.
*+001 : End

DATA : BEGIN OF ist_lines OCCURS 0,
       vdata LIKE pplog-vdata,
       opera(1),
      END OF ist_lines.

DATA : BEGIN OF ist_lines_spfc OCCURS 0,
       vdata LIKE pplog-vdata,
       opera(1),
      END OF ist_lines_spfc.

*+001 : Start
DATA : BEGIN OF ist_lines_epc OCCURS 0,
       vdata LIKE pplog-vdata,
       opera(1),
      END OF ist_lines_epc.
*+001 : End

*+002 : Start
DATA : ist_mesg   TYPE esp1_message_tab_type WITH HEADER LINE.
*+002 : End

* Structure : Attachment
DATA : ist_att_files TYPE TABLE OF swotobjid,
       wa_att_files  TYPE swotobjid.

DATA : g_dynnr TYPE sy-dynnr,
       g_tcode TYPE sy-tcode.

DATA : ok_code       TYPE sy-ucomm ,
       save_ok       TYPE sy-ucomm ,
       g_ok_code     TYPE sy-ucomm,
       g_ok_code_300 TYPE sy-ucomm.     "+006

DATA : g_exec(1) VALUE 'X'.

DATA : g_ans(1),
       g_txt(132),
       g_disp(1).

DATA : g_dmode(1),
       g_chg_flg(1),
       g_dmode_spfc(1),
       g_chg_spfc(1).

*+001 : Start
DATA : g_dmode_epc(1),
       g_chg_epc(1).
*+001 : End

DATA : g_ret_1 TYPE sy-subrc,
       g_ret_2 TYPE sy-subrc.

DATA : g_reg  TYPE c VALUE 'X',  "Methodology : Regular
       g_spfc TYPE c.            "Methodology : Specific

DATA : g_tndr_proc(40),
       g_tndr_typ(40).

DATA : g_pbo_bidrs(1). "shortlisted bidders for PBO
*End*******************************************************************

*18.10.2012 : Start
DATA : g_loi_dt1(20),
       g_loi_dt2(20),
       g_loi_dt3(20).

DATA : g_tm TYPE zmm_tms_tc-tc_member1.
*18.10.2012 : End
DATA : it_eban LIKE eban OCCURS 0 ,
       t_cdpos LIKE cdpos OCCURS 0 WITH HEADER LINE,
       tcdhdr  LIKE cdhdr OCCURS 0 WITH HEADER LINE,
       lt_cdshw LIKE cdshw OCCURS 0 WITH HEADER LINE.
DATA : objectid LIKE cdhdr-objectid,
       objectclass LIKE cdhdr-objectclas.

*DATA : g_no_pr TYPE c.                                  "-006
DATA  BEGIN OF it_sval OCCURS 0.
        INCLUDE STRUCTURE sval.
DATA  END   OF it_sval.
DATA :        wrk_retcode.
DATA l_ttext(10).
DATA : g_check(1) VALUE 'X'.
DATA :g_rel_stat TYPE zmm_tms-rel_stat.
DATA : ist_ekpo TYPE TABLE OF ty_ekpo,
       wa_ekpo  TYPE ty_ekpo,
       wa_ekko TYPE ekko.

*+004 : Start
DATA : g_loekz TYPE eban-loekz,
       g_frgkz TYPE eban-frgkz.
*+004 : End

DATA : g_banfn TYPE eban-banfn.                  "+008

DATA : g_chk(1).                                 "+007

DATA : g_pr_rcpt_dt TYPE zmm_tms-pr_rcpt_dt.     "+007



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 03.11.2014  FOR total pr value
                                                            "RD1K994950
data : v_pr_val type gswrt,
      ist_eban_all TYPE TABLE OF zmm_pur_tender_d,
      ist_eban type TABLE OF eban,
      ist_eban_t  type TABLE OF eban,
      wa_eban_all LIKE LINE OF  ist_eban_all,
      wa_eban LIKE LINE OF ist_eban,
      wa_eban_t LIKE LINE OF  ist_eban_t.


data : wa_erate  type bapi1093_0.


""""""""""""""""""""""""""""""""""
"comment by lipsy on 27.02.2015 for increasing field length RD1K995870
*data : l_fval type gswrt.             " Total Value of Item
"end of comment by lipsy on 27.02.2015 for increasing field length RD1K995870
""""""""""""""

data : l_rate_type   type bapi1093_1-rate_type, " Exchange Rate Type
       l_from_curr   type bapi1093_1-from_curr, " From Currency
       l_to_curr     type bapi1093_1-to_currncy," To Currency
       l_trans_dt    type bapi1093_2-trans_date," Date
       l_erate       type gswrt.                " Total Value of Item

data : l_rval type p decimals 2. " Rounded Value

data : l_temp  type currency1034,
       l_rlwrt type currency1034,
       v_mes_txt type  char120.






"""end of ADDition  BY LIPSY ON 03.11.2014  FOR  total pr value
                                                            "RD1K994950
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
TYPES : BEGIN OF TY_DATA,
          PERNR     LIKE PA0027-PERNR,
          BEGDA     LIKE PA0001-BEGDA,
          ENDDA     LIKE PA0001-ENDDA,
          NAME      LIKE PA0001-ENAME,
          BUKRS     LIKE PA0001-BUKRS,
          WERKS     LIKE PA0001-WERKS,
          PERSK     LIKE PA0001-PERSK,
          KBU01     LIKE PA0027-KBU01,
          KGB01     LIKE PA0027-KGB01,
          KST01     LIKE PA0027-KST01,
          DESIGNO   LIKE PA9930-DESIGNO,
          R_P_CD    LIKE PA9930-R_P_CD,
          VERSION   LIKE PA9930-VERSION,
          DESIGNATION LIKE ZDESIGNATION_REV-SDESIG_TEXT,
          ADESIGNATION LIKE ZDESIGNATION_REV-ADESIG_TEXT,
          DISC_CD   LIKE ZDESIGNATION_REV-DISC_CD,
          SBMOD     TYPE PA0001-SBMOD,
        END OF TY_DATA.

DATA : IST_DATA TYPE STANDARD  TABLE OF TY_DATA WITH HEADER LINE.
data : wa_data type ty_data.
DATA : L_DATE TYPE DATUM.
data : l_mm,l_fi,l_indentor.
data : l_disc_cd_1 type ty_data-disc_cd,
      l_disc_cd_2 type ty_data-disc_cd,
      l_disc_cd_3 type ty_data-disc_cd,
      l_disc_cd_4 type ty_data-disc_cd,
      l_disc_cd_5 type ty_data-disc_cd,
      l_disc_cd_1s type ty_data-disc_cd,
      l_disc_cd_2s type ty_data-disc_cd,
      l_disc_cd_3s type ty_data-disc_cd,
      l_disc_cd_4s type ty_data-disc_cd,
      l_disc_cd_5s type ty_data-disc_cd.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""added by lipsy on 26.02.2015 for change history of tc members RD1K995870

data:wa_zmm_tms_tco TYPE zmm_tms_tc,
     wa_zmm_tms_tcn TYPE zmm_tms_tc,
     V_REL_OLD TYPE C,
      V_REL_NEW  TYPE C,
     XZMM_TMS LIKE zmm_tms OCCURS 0 WITH HEADER LINE,
      yZMM_TMS LIKE  zmm_tms OCCURS 0 WITH HEADER LINE.

data : l_fval type currency1034.
data: v_initial TYPE c.



"""""""""""""""""end of addition  by lipsy on 26.02.2015 for change history of tc members RD1K995870


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""
"ADDED BY LIPSY ON 9.05.2015 RD1K997136

DATA:WA_TENDER_OLD TYPE ZMM_PUR_TENDER_D,
      WA_TENDER_NEW TYPE ZMM_PUR_TENDER_D.

"END OF ADDITION BY LIPSY ON 9.05.2015 RD1K997136
"""""""""""""""""""""""""""""""""""""
