*--- MAIN PROGRAM: SAPMZMMCONVINSSPRSNVS ---*
***********************************************************************
* Program    : SAPMZMMCONVINSSPRSNVS                                  *
*                                                                     *
* Title      : Conversion of Insurance Spares to Non valuated stock   *
*                                                                     *
* Functional Specification No.: FS-MM-INV-030                         *
*                                                                     *
* Author     : S P YADAV                   Date : 15-Dec-2005         *
*                                                                     *
* Login Id   : CAB_SPYADAV                                            *
*                                                                     *
* Desciption : Due to non-avialability of SAP transaction to          *
*              Convert Insurance Spares to Non valuated stock,        *
*              this module is developed                               *
*                                                                     *
* Transaction Code : ZMMCONV                                          *
*                                                                     *
*                                                                     *
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                 Chng ID       *
*                                                                     *
*                                                                     *
***********************************************************************

*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMCONVINSSPRSNVS                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM SAPMZMMCONVINSSPRSNVS .

INCLUDE MZMMCONVINSSPRSNVSTOP.
*--- MODULE for Data Declaration---------------------------------------*

INCLUDE MZMMCONVINSSPRSNVSO01.
*--- PBO-MODULE for User-screens --------------------------------------*

INCLUDE MZMMCONVINSSPRSNVSI01.
*--- PAI-MODULE for User-screens --------------------------------------*

INCLUDE MZMMCONVINSSPRSNVSF01.
*--- MODULE for Subroutines -------------------------------------------*

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

*--- INCLUDE: CL_FML_SDM_BADI_AMDP_TF=======CU ---*
CLASS cl_fml_sdm_badi_amdp_tf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb .

    CLASS-METHODS fetch_sdm_phase
        FOR TABLE FUNCTION p_fml_sdm_phase_badi_amdp_tf.


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

*--- INCLUDE: MZMMCONVINSSPRSNVSF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMCONVINSSPRSNVSF01                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  upd_resvitem_tbl
*&---------------------------------------------------------------------*
* To udate internal table ist_resvitem
*----------------------------------------------------------------------*
FORM upd_resvitem_tbl.
  DATA : ist_resvitem_t LIKE TABLE OF wa_resvitem.

  REFRESH :   ist_resvitem_b.

*  ist_resvitem_b[] = ist_resvitem[].

  LOOP AT ist_resvitem INTO wa_resvitem.

    SELECT maktx FROM makt INTO wa_resvitem-maktx UP TO 1 ROWS
 WHERE matnr = wa_resvitem-matnr
 ORDER BY PRIMARY KEY .
    ENDSELECT.

*    wa_resvitem-ps_psp_pnr = rkpf-ps_psp_pnr.

    wa_resvitem-bdmng = wa_resvitem-bdmng - wa_resvitem-enmng.

    wa_resvitem-lgort = wa_resvdtl-lgort.

    APPEND wa_resvitem TO ist_resvitem_b.

    APPEND wa_resvitem TO ist_resvitem_t.

    wa_resvitem-umlgo = wa_resvdtl-umlgo.

    CONCATENATE wa_resvitem-charg+0(2) TEXT-001 INTO wa_resvitem-charg_r.

    CONCATENATE TEXT-004 wa_resvitem-bwart+1(2) INTO wa_resvitem-bwart.

    CLEAR : wa_resvitem-lgort,
            wa_resvitem-charg.

    APPEND wa_resvitem TO ist_resvitem_t.
  ENDLOOP.

  ist_resvitem[]   = ist_resvitem_t[].
ENDFORM.                    " upd_resvitem_tbl

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
      text_question         = TEXT-006
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      display_cancel_button = ''
      default_button        = '1'
    IMPORTING
      answer                = g_ans.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " confirm_input

*&---------------------------------------------------------------------*
*&      Form  trans_spares_mvstk
*&---------------------------------------------------------------------*
* To convert insurance spares to non valuated stock
*----------------------------------------------------------------------*
FORM trans_spares_mvstk.
  DATA : ist_goodsmvt_item  TYPE TABLE OF bapi2017_gm_item_create.

  DATA : wa_goodsmvt_header TYPE    bapi2017_gm_head_01,
         wa_goodsmvt_code   TYPE    bapi2017_gm_code,
         wa_goodsmvt_item   TYPE    bapi2017_gm_item_create.

  DATA : ist_return TYPE TABLE OF bapiret2,
         wa_return  TYPE bapiret2.

  DATA : l_rsnum TYPE resb-rsnum.

  DATA : l_ps_psp_pnr LIKE wa_goodsmvt_item-wbs_elem,
         l_asset_no   LIKE wa_goodsmvt_item-asset_no,
         l_asset_sub  LIKE wa_goodsmvt_item-sub_number.

  DATA : ist_mesg   TYPE esp1_message_tab_type WITH HEADER LINE.

  DATA : l_no1 TYPE sy-tabix,
         l_no2 TYPE sy-tabix.

  CLEAR : g_mat_doc_no,
          l_ps_psp_pnr,
          l_asset_no,
          l_rsnum.

  CLEAR : rkpf.

* - populate header
  wa_goodsmvt_header-pstng_date = gohead-budat.
  wa_goodsmvt_header-doc_date   = gohead-bldat.
  wa_goodsmvt_header-header_txt = TEXT-005.

* - populate code
  wa_goodsmvt_code-gm_code = '03'.

* - populate line items
  WRITE : wa_resvdtl-rsnum TO l_rsnum NO-ZERO.
  CONDENSE l_rsnum.

  SELECT SINGLE ps_psp_pnr anln1 anln2 FROM rkpf
             INTO (rkpf-ps_psp_pnr,rkpf-anln1,rkpf-anln2)
                    WHERE rsnum = wa_resvdtl-rsnum.

  MOVE rkpf-anln1 TO l_asset_no.
  MOVE rkpf-anln2 TO l_asset_sub.

  CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
    EXPORTING
      input  = rkpf-ps_psp_pnr
    IMPORTING
      output = l_ps_psp_pnr.

  LOOP AT ist_resvitem INTO wa_resvitem
                        WHERE chk = 'X'.

* Movement Type X21 or X41 etc
    IF wa_resvitem-charg_r IS INITIAL.
      wa_goodsmvt_item-material  = wa_resvitem-matnr.
      wa_goodsmvt_item-plant     = wa_resvitem-werks.
      wa_goodsmvt_item-stge_loc  = wa_resvitem-lgort.
      wa_goodsmvt_item-batch     = wa_resvitem-charg.
      wa_goodsmvt_item-move_type = wa_resvitem-bwart.
      wa_goodsmvt_item-wbs_elem  = l_ps_psp_pnr.
      wa_goodsmvt_item-asset_no  = l_asset_no.
      wa_goodsmvt_item-sub_number = l_asset_sub.
      wa_goodsmvt_item-entry_qnt = wa_resvitem-bdmng.
      wa_goodsmvt_item-entry_uom = wa_resvitem-meins.
      CONCATENATE TEXT-008 l_rsnum INTO
          wa_goodsmvt_item-item_text.

      APPEND wa_goodsmvt_item TO ist_goodsmvt_item.
    ELSE.
* Movement Type Y21 or Y41 etc
      wa_goodsmvt_item-material   = wa_resvitem-matnr.
      wa_goodsmvt_item-plant      = wa_resvitem-werks.
      wa_goodsmvt_item-stge_loc   = wa_resvitem-umlgo.
      wa_goodsmvt_item-batch      = wa_resvitem-charg_r.
      wa_goodsmvt_item-move_type  = wa_resvitem-bwart.
      wa_goodsmvt_item-wbs_elem   = l_ps_psp_pnr.
      wa_goodsmvt_item-asset_no   = l_asset_no.
      wa_goodsmvt_item-sub_number = l_asset_sub.
      wa_goodsmvt_item-entry_qnt  = wa_resvitem-bdmng.
      wa_goodsmvt_item-entry_uom  = wa_resvitem-meins.

      CONCATENATE TEXT-008 l_rsnum INTO
          wa_goodsmvt_item-item_text.

      APPEND wa_goodsmvt_item TO ist_goodsmvt_item.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE ist_resvitem  LINES l_no1.
  DESCRIBE TABLE ist_goodsmvt_item LINES l_no2.

*  if not ist_goodsmvt_item[] is initial.
  IF l_no1 = l_no2.
    "Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE' "#EC CI_USAGE_OK[2438131]
      EXPORTING
        goodsmvt_header  = wa_goodsmvt_header
        goodsmvt_code    = wa_goodsmvt_code
      IMPORTING
        materialdocument = g_mat_doc_no
      TABLES
        goodsmvt_item    = ist_goodsmvt_item
        return           = ist_return.
    "Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC

    IF ist_return[] IS INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = wa_return.

      IF wa_return IS INITIAL.
        PERFORM upd_resveration_dtl USING wa_resvdtl-rsnum
                                           g_mat_doc_no.

        MESSAGE i395(zmm) WITH g_mat_doc_no.

        MESSAGE s379(zmm) WITH g_mat_doc_no.

        CLEAR : save_ok,
                g_ok_code.

        LEAVE TO SCREEN 100.
      ELSE.
        MESSAGE i396(zmm).
      ENDIF.
    ELSE.
      LOOP AT ist_return INTO wa_return.
        MOVE wa_return-type   TO ist_mesg-msgty.
        MOVE wa_return-id     TO ist_mesg-msgid.
        MOVE wa_return-number TO ist_mesg-msgno.

        APPEND ist_mesg.
      ENDLOOP.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          i_message_tab = ist_mesg.

*      message e378(zmm).
    ENDIF.
  ELSE.
    MESSAGE i376(zmm).
  ENDIF.
ENDFORM.                    " trans_spares_mvstk

*&---------------------------------------------------------------------*
*&      Form  chk_stk_val
*&---------------------------------------------------------------------*
* To check stock value of material - for plant & storage location
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_stk_val.
  DATA : l_chk(1).

  LOOP AT ist_resvitem_b INTO wa_resvitem_b.
    SELECT SINGLE * FROM mard
      WHERE matnr = wa_resvitem_b-matnr AND
            werks = wa_resvitem_b-werks AND
            lgort = wa_resvitem_b-lgort.

    IF wa_resvitem_b-bdmng > mard-labst.
      MESSAGE e181(m7) WITH sy-datum mard-labst ''.
    ENDIF.
  ENDLOOP.

  CLEAR : l_chk.

  LOOP AT ist_resvitem INTO wa_resvitem.
    IF wa_resvitem-chk <> 'X'.
      l_chk = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF l_chk = 'X'.
    MESSAGE i376(zmm).
  ELSE.
    MESSAGE s026(migo).
  ENDIF.

  CLEAR : wa_resvitem_b,
          wa_resvitem.
ENDFORM.                    " chk_stk_val

*&---------------------------------------------------------------------*
*&      Form  upd_resveration_dtl
*&---------------------------------------------------------------------*
* To Update (set) deletion flag ,final issue flag & Item text in the
* reservation document using BDC by calling tr. code MB22
*----------------------------------------------------------------------*
*      -->p_rsnum         Reservation No.
*      -->p_mat_doc_no    Material Document No.
*----------------------------------------------------------------------*
FORM upd_resveration_dtl USING    p_rsnum
                                  p_mat_doc_no.
  DATA : BEGIN OF wa_resb,
           rsnum TYPE resb-rsnum,
           rspos TYPE resb-rspos,
           lgort TYPE resb-lgort,
           charg TYPE resb-charg,
*        erfmg  type resb-erfmg,
           bdter TYPE resb-bdter,
           kzear TYPE resb-kzear,
           xwaok TYPE resb-xwaok,
           xloek TYPE resb-xloek,
         END OF wa_resb.

  DATA : ist_resb LIKE TABLE OF wa_resb.

  DATA : l_sgtxt TYPE resb-sgtxt.

  DATA : l_date  TYPE resb-bdter.

  DATA : l_cnt   TYPE sy-tabix.

  SELECT rsnum rspos lgort charg bdter kzear xwaok xloek
      INTO TABLE ist_resb FROM resb
          WHERE rsnum = p_rsnum
            AND bwart = wa_resvdtl-bwart ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.

    READ TABLE ist_resb INTO wa_resb INDEX 1.

    DESCRIBE TABLE ist_resb LINES l_cnt.

    PERFORM bdc_dynpro      USING 'SAPMM07R' '0560'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RM07M-RSNUM'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RM07M-RSNUM'
                                   wa_resb-rsnum.
    PERFORM bdc_field       USING 'RM07M-RSPOS'
                                   ''.
    PERFORM bdc_field       USING 'XFULL'
                                  'X'.

    PERFORM bdc_dynpro      USING 'SAPMM07R' '0521'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RESB-ERFMG(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=PF02'.
    PERFORM bdc_field       USING 'DKACB-FMORE'
                                  'X'.
    CONCATENATE TEXT-007 p_mat_doc_no INTO l_sgtxt SEPARATED BY space.

    l_cnt = l_cnt - 1.

    LOOP AT ist_resb INTO wa_resb.

      IF sy-tabix <= l_cnt.

        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.

        IF wa_resvdtl-bwart = 'X21'.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'COBL-PS_POSID'.
        ELSE.
          PERFORM bdc_field       USING 'BDC_CURSOR'
                                        'COBL-ANLN1'.
        ENDIF.

        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTE'.
        PERFORM bdc_dynpro      USING 'SAPMM07R' '0510'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RESB-SGTXT'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=KPN'.
        IF wa_resb-xloek <> 'X'.

          PERFORM bdc_field       USING 'RESB-CHARG'
                                         wa_resb-charg.
*        perform bdc_field       using 'RESB-ERFMG'
*                                       wa_resb-erfmg.

          WRITE wa_resb-bdter   TO l_date DD/MM/YY .

          PERFORM bdc_field       USING 'RESB-BDTER'
                                        l_date.
          PERFORM bdc_field       USING 'RESB-KZEAR'
                                        'X'.
          PERFORM bdc_field       USING 'RESB-XWAOK'
                                         wa_resb-xwaok.
          PERFORM bdc_field       USING 'RESB-XLOEK'
                                        'X'.

          PERFORM bdc_field       USING 'RESB-SGTXT'
                                         l_sgtxt.
          PERFORM bdc_field       USING 'DKACB-FMORE'
                                       'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    l_cnt = l_cnt + 1.

    READ TABLE ist_resb INTO wa_resb INDEX l_cnt.

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.

    IF wa_resvdtl-bwart = 'X21'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-PS_POSID'.
    ELSE.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-ANLN1'.
    ENDIF.

    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTE'.
    PERFORM bdc_dynpro      USING 'SAPMM07R' '0510'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RESB-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BU'.
    IF wa_resb-xloek <> 'X'.

      PERFORM bdc_field       USING 'RESB-CHARG'
                                     wa_resb-charg.
*    perform bdc_field       using 'RESB-ERFMG'
*                                   wa_resb-erfmg.

      WRITE wa_resb-bdter   TO l_date DD/MM/YY .

      PERFORM bdc_field       USING 'RESB-BDTER'
                                     l_date.
      PERFORM bdc_field       USING 'RESB-KZEAR'
                                    'X'.
      PERFORM bdc_field       USING 'RESB-XWAOK'
                                     wa_resb-xwaok.
      PERFORM bdc_field       USING 'RESB-XLOEK'
                                    'X'.

      PERFORM bdc_field       USING 'RESB-SGTXT'
                                     l_sgtxt.
      PERFORM bdc_field       USING 'DKACB-FMORE'
                                     'X'.
    ENDIF.

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.

    IF wa_resvdtl-bwart = 'X21'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-PS_POSID'.
    ELSE.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-ANLN1'.
    ENDIF.

    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTE'.
    CALL TRANSACTION 'MB22' USING      ist_bdcdata
                                       MODE 'E'
                                       UPDATE 'S'
                             MESSAGES INTO ist_msg .
  ENDIF.

ENDFORM.                    " upd_resveration_dtl

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       BDC DYNPRO
*----------------------------------------------------------------------*
*      -->P_0487   text
*      -->P_0488   text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING l_program l_dynpro.
  CLEAR ist_bdcdata.
  ist_bdcdata-program  = l_program.
  ist_bdcdata-dynpro   = l_dynpro.
  ist_bdcdata-dynbegin = 'X'.
  APPEND ist_bdcdata.
ENDFORM.                    " bdc_dynpro

*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       BDC FIELD
*----------------------------------------------------------------------*
*      -->P_0501   text
*      -->P_0502   text
*----------------------------------------------------------------------*
FORM bdc_field USING l_fnam l_fval.

  CLEAR ist_bdcdata.
  ist_bdcdata-fnam = l_fnam.
  ist_bdcdata-fval = l_fval.
  APPEND ist_bdcdata.
ENDFORM.                    " bdc_field

*&---------------------------------------------------------------------*
*&      Form  select_all_entries
*&---------------------------------------------------------------------*
*   To select the row in table control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all_entries.
  LOOP AT ist_resvitem INTO wa_resvitem.
    wa_resvitem-chk = 'X'.
    MODIFY ist_resvitem FROM wa_resvitem INDEX sy-tabix.
  ENDLOOP.

  CLEAR :wa_resvitem.
ENDFORM.                    " select_all_entries
*&---------------------------------------------------------------------*
*&      Form  deselect_all_entries
*&---------------------------------------------------------------------*
*  To deselect the row in table control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_all_entries.
  LOOP AT ist_resvitem INTO wa_resvitem.
    wa_resvitem-chk = ' '.
    MODIFY ist_resvitem FROM wa_resvitem INDEX sy-tabix.
  ENDLOOP.

  CLEAR :wa_resvitem.
ENDFORM.                    " deselect_all_entries

*&---------------------------------------------------------------------*
*&      Form  get_resb_data
*&---------------------------------------------------------------------*
* To fetch reservation details
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_resb_data.
  REFRESH : ist_resvitem.
  CLEAR   : wa_resvitem.

  SELECT * FROM resb INTO TABLE ist_resb
  "corresponding fields of table ist_resvitem
                 WHERE rsnum = wa_resvdtl-rsnum ORDER BY PRIMARY KEY.  " and
*                       bwart = wa_resvdtl-bwart. " and
*                       lgort = wa_resvdtl-lgort and
*                        kzear <> 'X'            and
*                        xloek <> 'X'.


  IF sy-subrc <> 0.
    MESSAGE e667(zmm).
  ELSE.

    PERFORM chk_rsnum.

    READ TABLE ist_resb INDEX 1.

    IF ist_resb-kzear = 'X' AND
        ist_resb-xloek = 'X'.
      MESSAGE e377(zmm) WITH wa_resvdtl-rsnum.
    ELSE.
      LOOP AT ist_resb.
        MOVE-CORRESPONDING ist_resb TO wa_resvitem.
        APPEND wa_resvitem TO ist_resvitem.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_resb_data

*&---------------------------------------------------------------------*
*&      Form  chk_rsnum
*&---------------------------------------------------------------------*
* To Validate reservation number
*             - Validation for Valuation Type
*             - Validation on subasset number
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_rsnum.
  DATA : ist_mesg   TYPE esp1_message_tab_type WITH HEADER LINE.
  DATA : l_charg TYPE resb-charg.
  DATA : l_found(1),
         l_no TYPE sy-tabix.


*Validation on subasset number
  CLEAR : rkpf.

  SELECT SINGLE * FROM rkpf
    WHERE rsnum = wa_resvdtl-rsnum.

  MOVE rkpf-bwart TO wa_resvdtl-bwart.

  IF NOT ( wa_resvdtl-bwart = 'X21' OR
               wa_resvdtl-bwart = 'X41' ).
    MESSAGE e368(zmm).
  ENDIF.

  READ TABLE ist_resb INDEX 1.

  IF NOT ist_resb-lgort IS INITIAL.
    MOVE ist_resb-lgort TO wa_resvdtl-lgort.
  ENDIF.

  IF wa_resvdtl-bwart = 'X41'.
    IF  ( rkpf-anln2 IS INITIAL OR
          rkpf-anln2 = '0000' ).
      MESSAGE e393(zmm) WITH rkpf-anln1 wa_resvdtl-rsnum.
    ELSE.
      SELECT SINGLE * FROM anla
         WHERE anln1 = rkpf-anln1
           AND anln2 = rkpf-anln2
           AND ord43 = 'STDB'.                 "Asset standby

      IF sy-subrc <> 0.
        MESSAGE e394(zmm)." with rkpf-anln1.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : l_found,
          l_no.

*Validation for Valuation Type
  LOOP AT ist_resb.
    CLEAR : l_charg.

    CONCATENATE ist_resb-charg+0(2) TEXT-001 INTO l_charg.

    SELECT SINGLE * FROM mbew
        WHERE matnr = ist_resb-matnr
          AND bwkey = ist_resb-werks
          AND bwtar = l_charg.

    IF sy-subrc <> 0.
      l_found = '0'.
      l_no = l_no + 1.

      MOVE 'E'            TO ist_mesg-msgty.
      MOVE 'ZMM'          TO ist_mesg-msgid.
      MOVE '392'          TO ist_mesg-msgno.
      MOVE l_charg        TO ist_mesg-msgv1.
      MOVE ist_resb-matnr TO ist_mesg-msgv2.
      MOVE ist_resb-werks TO ist_mesg-msgv3.
      MOVE l_no           TO ist_mesg-lineno.

      APPEND ist_mesg.
    ENDIF.
  ENDLOOP.

  IF l_found = '0'.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = ist_mesg.

    READ TABLE ist_mesg INDEX 1.

    MESSAGE e392(zmm) WITH ist_mesg-msgv1 ist_mesg-msgv2 ist_mesg-msgv3.
  ENDIF.
ENDFORM.                    " chk_rsnum

*--- INCLUDE: MZMMCONVINSSPRSNVSI01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMCONVINSSPRSNVSI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  To navigate to screen 0200
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  g_ok_code = ok_code.
  clear ok_code.
  case g_ok_code.
    when 'EXEC'.
*     select * from resb into corresponding fields of table ist_resvitem
*                       where rsnum = wa_resvdtl-rsnum.

      perform upd_resvitem_tbl.

      call screen '0200'.
  endcase.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOV_RSNUM  INPUT
*&---------------------------------------------------------------------*
* To get serach help for reservation number
*----------------------------------------------------------------------*
MODULE GET_LOV_RSNUM INPUT.
  DATA : ist_return_tab      like standard table of ddshretval
                                         with  header line.

  DATA : ist_field_tab like standard table of dfies
                                         with  header line.

  DATA : ist_dynpfld_mapping like standard table of dselc
                                         with  header line.

  DATA : wa_object like wa_resvdtl.

  DATA : Begin of wa_rkpf,
          rsnum type rkpf-rsnum,
          bwart type rkpf-bwart,
         End of wa_rkpf.

  DATA : ist_rkpf like table of wa_rkpf.

  DATA : ist_object_f4 like standard table of wa_object initial size
100.

  DATA : l_object_id(10).
  DATA : l_index type sy-tabix.

  refresh : ist_object_f4,ist_return_tab.

  select rsnum bwart from rkpf into table ist_rkpf
    where bwart in ('X21','X41').

  if sy-subrc = 0.
    select rsnum lgort umlgo from resb
       into corresponding fields of table ist_object_f4
           for all entries in ist_rkpf
                where rsnum = ist_rkpf-rsnum.

    sort ist_object_f4 by rsnum lgort.

    delete adjacent duplicates from ist_object_f4.

    loop at ist_object_f4 into wa_object.

      l_index = sy-tabix.

      loop at ist_rkpf into wa_rkpf
                        where rsnum = wa_object-rsnum.

        move wa_rkpf-bwart to wa_object-bwart.
        modify ist_object_f4 from wa_object index l_index.
        exit.
      endloop.

    endloop.
  endif.

  sort ist_object_f4 by rsnum bwart lgort umlgo.

  delete adjacent duplicates from ist_object_f4.

  refresh : ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0001'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-RSNUM'.
  append ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0002'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-BWART'.
  append ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0003'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-LGORT'.
  append ist_dynpfld_mapping.

  ist_dynpfld_mapping-fldname   = 'F0004'.
  ist_dynpfld_mapping-dyfldname = 'WA_RESVDTL-UMLGO'.
  append ist_dynpfld_mapping.

  clear : ist_dynpfld_mapping.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            retfield        = 'RSNUM'
            dynpprog        = sy-repid
            dynpnr          = sy-dynnr
            dynprofield     = 'WA_RESVDTL-RSNUM'
            value_org       = 'S'
       TABLES
            value_tab       = ist_object_f4
            field_tab       = ist_field_tab
            return_tab      = ist_return_tab
            dynpfld_mapping = ist_dynpfld_mapping
       EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  WA_RESVDTL-RSNUM =  ist_return_tab-fieldval.

ENDMODULE.                 " GET_LOV_RSNUM  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0100  INPUT
*&---------------------------------------------------------------------*
*   To exit from program at any time
*----------------------------------------------------------------------*
MODULE CANCEL_0100 INPUT.
  save_ok = ok_code.
  clear ok_code.
  case save_ok.
    WHEN 'BACK' or 'CANCEL' OR 'EXIT'.
      leave program.
  endcase.
ENDMODULE.                 " CANCEL_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_validation  INPUT
*&---------------------------------------------------------------------*
*    Checks for input field, if required input field is null
*    display error message - screen 0100                               *
*----------------------------------------------------------------------*
MODULE check_validation INPUT.
  if wa_resvdtl-rsnum is initial.
    message e370(zmm).
  endif.

  perform get_resb_data.

  if wa_resvdtl-bwart is initial.
    message e371(zmm).
  endif.

  if wa_resvdtl-lgort is initial.
    message e372(zmm).
  endif.

  if wa_resvdtl-umlgo is initial.
    message e373(zmm).
  endif.
ENDMODULE.                 " check_validation  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0200  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE CANCEL_0200 INPUT.
  save_ok = ok_code.
  clear ok_code.

  case g_ok_code.
    when 'EXEC'.
      case save_ok.
        WHEN 'BACK' or 'CANCEL' OR 'EXIT'.
          clear : g_ans.

          perform confirm_input.
          if g_ans = '2'.
            clear g_ans.
            clear ok_code.
            clear save_ok.
            clear g_ok_code.
            leave to screen 100.
          elseif g_ans = '1'.
            clear g_ans.
            clear ok_code.
            ok_code = 'SAVE'.
          endif.
      endcase.
  endcase.
ENDMODULE.                 " CANCEL_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_GL  INPUT
*&---------------------------------------------------------------------*
* To Initialize variable which will be used in Main Screen
*----------------------------------------------------------------------*
MODULE INIT_DATA_GL INPUT.
  refresh : ist_resvitem.

  clear   : wa_resvitem,
            wa_resvitem_tc.

  REFRESH CONTROL 'RESV_CTRL' FROM SCREEN 0200.

  g_change = '1'.
ENDMODULE.                 " INIT_DATA_GL  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_table_control_0200  INPUT
*&---------------------------------------------------------------------*
*  Move table control table data into internal table ist_resvitem
*----------------------------------------------------------------------*
MODULE read_table_control_0200 INPUT.
  MOVE-CORRESPONDING wa_resvitem_tc TO wa_resvitem.

  MODIFY ist_resvitem FROM wa_resvitem INDEX
  resv_ctrl-current_line.
ENDMODULE.                 " read_table_control_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_validation_0200  INPUT
*&---------------------------------------------------------------------*
*    Checks for input field, if input field is invalid, display
*    error message - Screen 0200
*----------------------------------------------------------------------*
MODULE check_validation_0200 INPUT.
  if wa_resvitem_tc-bdmng is initial.
    message e375(zmm).
  endif.

  if wa_resvitem_tc-charg_r is initial.
    loop at ist_resvitem_b into wa_resvitem_b
                  where matnr = wa_resvitem_tc-matnr.
      if wa_resvitem_tc-bdmng > wa_resvitem_b-bdmng.
        message e374(zmm).
      endif.
    endloop.
  else.
    loop at ist_resvitem into wa_resvitem_b
                  where matnr   = wa_resvitem_tc-matnr
                    and charg_r = ''.

      wa_resvitem_tc-bdmng = wa_resvitem_b-bdmng.
      wa_resvitem_tc-chk   = wa_resvitem_b-chk.
    endloop.
  endif.
ENDMODULE.                 " check_validation_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
* To perform operations like convert insurance spares to non valuated
* stock etc by pressing the respective button at application tool bar &
* Tabstrip.
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE g_ok_code.
    WHEN 'EXEC'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM chk_stk_val.
          PERFORM trans_spares_mvstk.

        WHEN 'CHK'.
          PERFORM chk_stk_val.

        WHEN 'SELE'.
          PERFORM select_all_entries.

        WHEN 'DESE'.
          PERFORM deselect_all_entries.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT

*--- INCLUDE: MZMMCONVINSSPRSNVSO01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMCONVINSSPRSNVSO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0100.
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0200.
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'S200'.
  SET TITLEBAR 'T200'.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  init_screen_0200  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen 0200 : Item Details
*----------------------------------------------------------------------*
MODULE init_screen_0200 OUTPUT.
*  loop at resv_ctrl-cols into wa_resvitem_tctrl-cols.
*
*    if wa_resvitem_tctrl-cols-screen-name = 'WA_RESVITEM_TC-BDMNG'.
*      if not wa_resvitem-charg_r is initial.
*        wa_resvitem_tctrl-cols-screen-output = '1'.
*        wa_resvitem_tctrl-cols-screen-input  = '0'.
*
*        modify resv_ctrl-cols from wa_resvitem_tctrl-cols.
*"        index resv_ctrl-current_line.
*        exit.
**      else.
**        wa_resvitem_tctrl-cols-screen-output = '1'.
**        wa_resvitem_tctrl-cols-screen-input  = '0'.
**
**        modify resv_ctrl-cols from wa_resvitem_tctrl-cols.
*      endif.
*    endif.
*
*  endloop.
ENDMODULE.                 " init_screen_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_0200  OUTPUT
*&---------------------------------------------------------------------*
*   To move reservation detail record into table control
*----------------------------------------------------------------------*
MODULE FILL_TABLE_CONTROL_0200 OUTPUT.
  move-corresponding wa_resvitem to wa_resvitem_tc.
ENDMODULE.                 " FILL_TABLE_CONTROL_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  REFRESH_WA_0200  OUTPUT
*&---------------------------------------------------------------------*
* To refresh structure wa_resvitem
*----------------------------------------------------------------------*
MODULE REFRESH_WA_0200 OUTPUT.
  clear wa_resvitem.
ENDMODULE.                 " REFRESH_WA_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_0200  OUTPUT
*&---------------------------------------------------------------------*
* To initialize data for screen 0200
*----------------------------------------------------------------------*
MODULE INIT_DATA_0200 OUTPUT.
  if g_change = '1'.
    describe table ist_resvitem lines g_lines.
    resv_ctrl-lines = g_lines.
    g_change = '0'.
  endif.
ENDMODULE.                 " INIT_DATA_0250  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_0100  OUTPUT
*&---------------------------------------------------------------------*
* To initialize data for screen 0100
*----------------------------------------------------------------------*
MODULE INIT_DATA_0100 OUTPUT.
  gohead-bldat = sy-datum.
  gohead-budat = sy-datum.
ENDMODULE.                 " INIT_DATA_0100  OUTPUT

*--- INCLUDE: MZMMCONVINSSPRSNVSTOP ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMCONVINSSPRSNVSTOP                                      *
*----------------------------------------------------------------------*
TABLES : RKPF              ,
         RESB              ,
         MAKT              ,
         MARD              ,
         MBEW              ,
         ANLA              .

TABLES  : GOHEAD.

TYPE-POOLS: VRM            ,
            ESP1           .
CONTROLS : RESV_CTRL TYPE TABLEVIEW USING SCREEN 0200.

*Declartion of structure for storing Reservation header
DATA : Begin of wa_resvdtl,
         rsnum  type resb-rsnum,
         bwart  type resb-bwart,
         lgort  type resb-lgort,
         umlgo  type resb-umlgo,
       End of wa_resvdtl.

*Declartion of structure & internal table for storing reservation detail
DATA : Begin of wa_resvitem,
        matnr      type resb-matnr,
        maktx      type makt-maktx,
        bdmng      type resb-bdmng,
        enmng      type resb-enmng,
        meins      type resb-meins,
        werks      type resb-werks,
        ps_psp_pnr type rkpf-ps_psp_pnr,
        bwart      type resb-bwart,
        charg      type resb-charg,
        lgort      type resb-lgort,
        umlgo      type resb-umlgo,
        charg_r    type resb-charg,
        chk(1),
        selcol(1),
       End of wa_resvitem.

DATA : ist_resvitem   like table of wa_resvitem,
       wa_resvitem_tc like wa_resvitem.

DATA : ist_resvitem_b like table of wa_resvitem,
       wa_resvitem_b  like wa_resvitem.

DATA : ist_resb type table of resb with header line.

*Internal table for BDC - Tr. code MB22
DATA : ist_bdcdata like bdcdata occurs 0  with header line.

DATA : ist_msg type table of bdcmsgcoll.

*Declartion of structure - table control columns
DATA : wa_resvitem_tctrl-cols type cxtab_column.

*Declaration of List box - Movement type
DATA: g_task_cd       type vrm_id,
      ist_task_list   type vrm_values,
      wa_task_value   like line of ist_task_list.

DATA : g_mat_doc_no   type bapi2017_gm_head_ret-mat_doc.

DATA : ok_code     type sy-ucomm ,
       save_ok     type sy-ucomm ,
       g_ok_code   type sy-ucomm .

DATA : g_lines type sy-tabix.

DATA : g_change(1).

DATA : g_ans(1).
