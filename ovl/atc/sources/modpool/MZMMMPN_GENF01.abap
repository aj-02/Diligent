*--- MAIN PROGRAM: MZMMMPN_GENF01 ---*
***INCLUDE MZMMMPN_GENF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date         Transport    USERID       Description
* 17/11/2008    RD1K960036   SAB_SUMODH
*
* Submit RMDATIND is Replaced by ZRMDATIND
* 05/12/2008    RD1K960611   SAB_PUNIT    Rectified the view selection
*                                         in the BDC
************************************************************************
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

   SEARCH P_OK FOR P_TC_NAME.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
   L_OK = P_OK+L_OFFSET.
   CASE L_OK.
     WHEN 'INSR'.                      "insert row
       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
       CLEAR P_OK.

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

     WHEN 'ASC'.
       IF NOT IST_LOG[] IS INITIAL.
         SORT IST_LOG BY DOCNO MSGTY.
       ENDIF.
     WHEN 'DSC'.
       IF NOT IST_LOG[] IS INITIAL.
         SORT IST_LOG DESCENDING BY DOCNO MSGTY.
       ENDIF.

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

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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
*&      Form  GET_DATA_LSMW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_DATA_LSMW.

* Initializations
   PERFORM INITIALIZATIONS.

* Create initial structures with nodata characters
   PERFORM CREATE_INITIAL_STRUCTURES.

* Execute data conversion.
   PERFORM EXECUTE_DATA_CONVERSION.

* Close files
   PERFORM CLOSE_FILES.

 ENDFORM.                    " GET_DATA_LSMW
*&---------------------------------------------------------------------*
*&      Form  lock_output_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOCK_OUTPUT_FILE.

   CALL FUNCTION '/SAPDMC/LSM_FILE_ENQUEUE'
     EXPORTING
       FILENAME    = G_DSN_OUT
     IMPORTING
       RETURN_CODE = G_RETURN
       LOCKUSER    = G_LOCKUSER.
   IF G_RETURN <> '0'.
     PERFORM ISSUE_MESSAGE
             USING 'A' '/SAPDMC/LSMW' '086' G_DSN_OUT G_LOCKUSER.
   ENDIF.

 ENDFORM.                    " lock_output_file
*&---------------------------------------------------------------------*
*&      Form  open_output_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM OPEN_OUTPUT_FILE.

   CALL FUNCTION '/SAPDMC/LSM_SAVE_FILE_USE'
     EXPORTING
       FILENAME = G_DSN_OUT
       PROJECT  = G_PROJECT
       SUBPROJ  = G_SUBPROJ
       OBJECT   = G_OBJECT
       FILETYPE = '3'
       ACTION   = 'OW'
       BATCH    = SY-BATCH.
*             fromdx   = p_fromdx.

*  IF p_trfcpt = no.
   OPEN DATASET G_DSN_OUT FOR OUTPUT IN TEXT MODE.
   IF SY-SUBRC <> 0.
     PERFORM ISSUE_MESSAGE
                     USING 'E' '/SAPDMC/LSMW' '804' G_DSN_OUT ' '.
   ENDIF.
*  ENDIF.

 ENDFORM.                    " open_output_file
*&---------------------------------------------------------------------*
*&      Form  issue_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0602   text
*      -->P_0603   text
*      -->P_0604   text
*      -->P_G_DSN_OUT  text
*      -->P_G_LOCKUSER  text
*----------------------------------------------------------------------*
 FORM ISSUE_MESSAGE USING    MSGTY MSGID MSGNO MSGV1 MSGV2.

   IF NOT MSGV2 IS INITIAL.
     MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO WITH MSGV1 MSGV2.
   ELSEIF NOT MSGV1 IS INITIAL.
     MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO WITH MSGV1.
   ELSE.
     MESSAGE ID MSGID TYPE MSGTY NUMBER MSGNO.
   ENDIF.

 ENDFORM.                    " issue_message
*&---------------------------------------------------------------------*
*&      Form  initializations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INITIALIZATIONS.
   G_USERID = SY-UNAME.
   G_GROUPNAME = G_OBJECT.
   G_NODATA = '/'.

   CONCATENATE G_PROJECT '_' G_SUBPROJ '_' G_OBJECT '.lsmw.conv' INTO
   G_DSN_OUT.

* Lock files
   PERFORM LOCK_OUTPUT_FILE.

* Open output file
   PERFORM OPEN_OUTPUT_FILE.

 ENDFORM.                    " initializations
*&---------------------------------------------------------------------*
*&      Form  create_initial_structures
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CREATE_INITIAL_STRUCTURES.

   PERFORM INITIALIZE_WITH_NODATA USING
           'BGR00' INIT_BGR00.

   PERFORM INITIALIZE_WITH_NODATA USING
           'BMM00' INIT_BMM00.

   PERFORM INITIALIZE_WITH_NODATA USING
           'BMMH1' INIT_BMMH1.

 ENDFORM.                    " create_initial_structures
*&---------------------------------------------------------------------*
*&      Form  initialize_with_nodata
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0721   text
*      -->P_INIT_BGR00  text
*----------------------------------------------------------------------*
 FORM INITIALIZE_WITH_NODATA USING  P_TABNAME P_TAB.

* Initialize every field with nodata
   FIELD-SYMBOLS:
     <F>.

   DATA:
     L_STRING(50),
     LT_DFIES LIKE DFIES OCCURS 50 WITH HEADER LINE.

   DATA:
     L_LEN_TRGSTR TYPE I.

   CALL FUNCTION '/SAPDMC/LSM_TARGET_FIELDS_GET'
     EXPORTING
       PROJECT                = G_PROJECT
       SUBPROJ                = G_SUBPROJ
       OBJECT                 = G_OBJECT
       SEGMENT                = P_TABNAME
       WITH_DATAELEMENTS      = ' '
     TABLES
       T_DFIES                = LT_DFIES
     EXCEPTIONS
       NO_SUCH_OBJECT         = 1
       NO_SUCH_SEGMENT        = 2
       NO_TARGET_FIELDS_FOUND = 3
       OTHERS                 = 4.

   LOOP AT LT_DFIES.
     L_LEN_TRGSTR = STRLEN( P_TABNAME ).
     IF L_LEN_TRGSTR <= 25.
       CONCATENATE 'init_' P_TABNAME '-' LT_DFIES-FIELDNAME
                   INTO L_STRING.
     ELSE.
       CONCATENATE 'in_' P_TABNAME '-' LT_DFIES-FIELDNAME
                   INTO L_STRING.
     ENDIF.
     ASSIGN (L_STRING) TO <F>.
     IF LT_DFIES-DATATYPE = 'FLTP' OR LT_DFIES-DATATYPE = 'QUAN'.
*      <F> = 0.
     ELSE.
       <F> = G_NODATA.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " initialize_with_nodata
*&---------------------------------------------------------------------*
*&      Form  execute_data_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXECUTE_DATA_CONVERSION.

   PERFORM CONVERT_TRANSACTION.
*   perform clear_source_tables.

 ENDFORM.                    " execute_data_conversion
*&---------------------------------------------------------------------*
*&      Form  close_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLOSE_FILES.

   CALL FUNCTION '/SAPDMC/LSM_SAVE_FILE_USE'
        EXPORTING
             FILENAME       = G_DSN_OUT
             PROJECT        = G_PROJECT
             SUBPROJ        = G_SUBPROJ
             OBJECT         = G_OBJECT
             FILETYPE       = '3'
             ACTION         = 'CL'
             BATCH          = SY-BATCH
*            fromdx         = p_fromdx
             T_TRANSACTIONS = G_CNT_TRANSACTIONS_TRANSFERRED
             T_RECORDS      = G_CNT_RECORDS_TRANSFERRED.

* Unlock files
*  IF p_fromdx NE 'X' AND sy-batch NE 'X'.
   CALL FUNCTION '/SAPDMC/LSM_FILE_DEQUEUE'
     EXPORTING
       FILENAME = G_DSN_OUT.
*  ENDIF.

*  IF p_trfcpt = no.
   CLOSE DATASET G_DSN_OUT.
*  ENDIF.

 ENDFORM.                    " close_files
*&---------------------------------------------------------------------*
*&      Form  convert_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONVERT_TRANSACTION.
   DATA WA_MARA LIKE MARA.
   DATA L_TABIX LIKE SY-TABIX.
   DATA L_COUNT(3) TYPE N.
   DATA:
     BEGIN OF GT_BUFFER1 OCCURS 0,
       RECORD TYPE TUMLS_SEGMENT,
       DATA(7960) TYPE C,
     END OF GT_BUFFER1.

   CLEAR :G_TC_DETAILS_WA, WA_MPN.

   LOOP AT G_TC_DETAILS_ITAB INTO G_TC_DETAILS_WA WHERE FLAG = 'X'.
     AT NEW MATNR.
       SELECT SINGLE * FROM MARA INTO WA_MARA WHERE
                                MATNR = G_TC_DETAILS_WA-MATNR.
       IF SY-SUBRC IS INITIAL AND WA_MARA-MPROF <> '0002'.
         PERFORM UPDATE_MARA USING WA_MARA. "upd mprof in mara
       ENDIF.
     ENDAT.
     PERFORM LOCK_RECORD.
     PERFORM CONVERT_0001.                                  " BGR00
     PERFORM CONVERT_0002.                                  " BMM00
     PERFORM CONVERT_0003.                                  " BMMH1
     CLEAR G_TC_DETAILS_WA.
   ENDLOOP.

*{+rk001 remove duplicates
   IF NOT GT_BUFFER[] IS INITIAL.
     GT_BUFFER1[] = GT_BUFFER[].
     SORT GT_BUFFER1.
     DELETE ADJACENT DUPLICATES FROM GT_BUFFER1.
     DESCRIBE TABLE GT_BUFFER1 LINES L_COUNT.
     CLEAR GT_BUFFER[].

     LOOP AT GT_BUFFER1.
       L_TABIX = SY-TABIX.
       APPEND GT_BUFFER1 TO GT_BUFFER.
       IF L_TABIX GE '3' AND L_TABIX LT L_COUNT.
         READ TABLE GT_BUFFER1 INDEX 1.
         IF SY-SUBRC = 0.
           APPEND GT_BUFFER1 TO GT_BUFFER.
         ENDIF.
         READ TABLE GT_BUFFER1 INDEX 2.
         IF SY-SUBRC = 0.
           APPEND GT_BUFFER1 TO GT_BUFFER.
         ENDIF.
       ELSE.
         CONTINUE.
       ENDIF.
     ENDLOOP.

   ENDIF.

   CLEAR GT_BUFFER1. REFRESH GT_BUFFER1.
*}+rk001
*write to file
   PERFORM TRANSFER_TRANSACTION.

 ENDFORM.                    " convert_transaction
*&---------------------------------------------------------------------*
*&      Form  convert_0001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONVERT_0001.

   CHECK G_SKIP_TRANSACTION = NO.

   G_SKIP_RECORD = NO.

   G_RECORD = 'BGR00'.

* --- __BEGIN_OF_RECORD__
   BGR00 = INIT_BGR00.

* --- BGR00-STYPE
   BGR00-STYPE = '0'.

* --- BGR00-GROUP
   BGR00-GROUP = G_GROUPNAME.

* --- BGR00-MANDT
   BGR00-MANDT = SY-MANDT.

* --- BGR00-USNAM
   BGR00-USNAM = G_USERID.

* --- BGR00-START
   BGR00-START = ''.

* --- BGR00-XKEEP
   BGR00-XKEEP = ''.

* --- BGR00-NODATA
   BGR00-NODATA = '/'.

* --- __END_OF_RECORD__

   PERFORM TRANSFER_RECORD.

 ENDFORM.                    " convert_0001
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TRANSFER_RECORD.

   FIELD-SYMBOLS:
     <L_RECORD>.

   ASSIGN (G_RECORD) TO <L_RECORD>.

   GT_BUFFER-RECORD = G_RECORD.
   GT_BUFFER-DATA = <L_RECORD>.
   APPEND GT_BUFFER.

 ENDFORM.                    " TRANSFER_RECORD
*&---------------------------------------------------------------------*
*&      Form  convert_0002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONVERT_0002.

   CHECK G_SKIP_TRANSACTION = NO.

   G_SKIP_RECORD = NO.

   G_RECORD = 'BMM00'.

* --- __BEGIN_OF_RECORD__
   BMM00 = INIT_BMM00.

* --- BMM00-STYPE
   BMM00-STYPE = '1'.

* --- BMM00-TCODE
   BMM00-TCODE = 'MM01'.

* --- BMM00-MATNR
   BMM00-MATNR = ''.

* --- BMM00-MBRSH
   BMM00-MBRSH = 'O'.

* --- BMM00-MTART
   BMM00-MTART = 'ZMPN'.

* --- BMM00-XEIE1
   BMM00-XEIE1 = 'X'.

* --- BMM00-XEIE2
   BMM00-XEIE2 = 'X'.

* --- __END_OF_RECORD__
   PERFORM TRANSFER_RECORD.

   G_SKIP_RECORD = NO.

 ENDFORM.                    " convert_0002
*&---------------------------------------------------------------------*
*&      Form  convert_0003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONVERT_0003.

   DATA: LV_MARA TYPE MARA.

   CHECK G_SKIP_TRANSACTION = NO.

   G_SKIP_RECORD = NO.

   G_RECORD = 'BMMH1'.

* --- __BEGIN_OF_RECORD__
   BMMH1 = INIT_BMMH1.

* --- BMMH1-STYPE
   BMMH1-STYPE = '2'.

* --- BMMH1-MAKTX
* Target field: BMMH1-MAKTX Material description
*   TABLES MAKT.
   SELECT SINGLE * FROM MAKT WHERE MATNR = G_TC_DETAILS_WA-MATNR.
   BMMH1-MAKTX = MAKT-MAKTX.

   SELECT SINGLE * FROM MARA INTO LV_MARA WHERE MATNR = G_TC_DETAILS_WA-MATNR.
   IF SY-SUBRC EQ 0.
     BMMH1-ZZOEM_NAME      = LV_MARA-ZZOEM_NAME.
     BMMH1-ZZCAP_CODE      = LV_MARA-ZZCAP_CODE.
     BMMH1-ZZCAP_NAME      = LV_MARA-ZZCAP_NAME.
     BMMH1-ZZMODELNO       = LV_MARA-ZZMODELNO.
     BMMH1-ZZMODELEXTN     = LV_MARA-ZZMODELEXTN.
     BMMH1-ZZREF_BOOK      = LV_MARA-ZZREF_BOOK.
     BMMH1-ZZREF_BOOK_DESC = LV_MARA-ZZREF_BOOK_DESC.
     BMMH1-ZZCSADES        = LV_MARA-ZZCSADES.
     BMMH1-ZZSANO          = LV_MARA-ZZSANO.
   ENDIF.
* --- BMMH1-MATKL
   BMMH1-MATKL = G_TC_DETAILS_WA-MATNR+0(2).

* --- BMMH1-BMATN
   BMMH1-BMATN = G_TC_DETAILS_WA-MATNR.

* --- BMMH1-MFRNR
   BMMH1-MFRNR = G_TC_DETAILS_WA-MFRNR.

* --- BMMH1-MFRPN
   BMMH1-MFRPN = G_TC_DETAILS_WA-MFRPN.

* --- __END_OF_RECORD__
   PERFORM TRANSFER_RECORD.

   G_SKIP_RECORD = NO.

 ENDFORM.                    " convert_0003
*&---------------------------------------------------------------------*
*&      Form  transfer_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TRANSFER_TRANSACTION.

   FIELD-SYMBOLS:
     <BUFFER>.

   LOOP AT GT_BUFFER.
     ASSIGN (GT_BUFFER-RECORD) TO <BUFFER>.
     MOVE GT_BUFFER-DATA TO <BUFFER>.
     TRANSFER <BUFFER> TO G_DSN_OUT.
     ADD 1 TO G_CNT_RECORDS_TRANSFERRED.
   ENDLOOP.

   CLEAR:
   GT_BUFFER[].

 ENDFORM.                    " transfer_transaction
*&---------------------------------------------------------------------*
*&      Form  clear_source_tables
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLEAR_SOURCE_TABLES.
   CLEAR : G_TC_DETAILS_ITAB, G_TC_DETAILS_WA.
 ENDFORM.                    " clear_source_tables
*&---------------------------------------------------------------------*
*&      Form  SCH_LSMW
*&---------------------------------------------------------------------*
*       Schedule LSMW
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SCH_LSMW.
   CALL FUNCTION 'JOB_OPEN'
     EXPORTING
       DELANFREP        = ' '
       JOBGROUP         = ' '
       JOBNAME          = G_JOBNAME
     IMPORTING
       JOBCOUNT         = G_JOBCOUNT
     EXCEPTIONS
       CANT_CREATE_JOB  = 01
       INVALID_JOB_DATA = 02
       JOBNAME_MISSING  = 03.
   IF SY-SUBRC <> 0.
*-----HANDLING EXCEPTION --------------------------*
     CASE SY-SUBRC.
       WHEN '01'.
         MESSAGE E026(BT).
       WHEN '02'.
         MESSAGE E155(BT) WITH 'INVALID DATA'.
       WHEN '03'.
         MESSAGE E093(BT).
     ENDCASE.
   ENDIF.

 ENDFORM.                    " SCH_LSMW
*&---------------------------------------------------------------------*
*&      Form  INSERT_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INSERT_PROCESS.

*Begin of <RD1K960036>.
*   SUBMIT rmdatind
*                   WITH %%%_r_p = 'X'
*                   WITH %%%_phy = g_dsn_out
*                   WITH level = '2'
*                   WITH erf_meld = 'X'
*                   WITH sperr = 'E'
*                   WITH prf_kz = ' '
*                   WITH flag_m = 'X'
*                   AND RETURN EXPORTING LIST TO MEMORY.
*                   USER SY-UNAME
*                   VIA JOB G_JOBNAME
*                   NUMBER G_JOBCOUNT
*                   .

   SUBMIT ZRMDATIND
                   WITH %%%_R_P = 'X'
                   WITH %%%_PHY = G_DSN_OUT
                   WITH LEVEL = '2'
                   WITH ERF_MELD = 'X'
                   WITH SPERR = 'E'
                   WITH PRF_KZ = ' '
                   WITH FLAG_M = 'X'
                   AND RETURN EXPORTING LIST TO MEMORY.
*                   USER SY-UNAME
*                   VIA JOB G_JOBNAME
*                   NUMBER G_JOBCOUNT
*End of <RD1K960036>.
   IF SY-SUBRC > 0.
     "error processing
   ELSE.
     PERFORM GET_OUTPUT_LIST.
     PERFORM UPDATE_MATERIAL.
   ENDIF.

 ENDFORM.                    " INSERT_PROCESS
*&---------------------------------------------------------------------*
*&      Form  CLOSE_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLOSE_JOB.

   WA_STARTTIME-SDLSTRTDT = SY-DATUM.
   WA_STARTTIME-SDLSTRTTM = SY-UZEIT + 1.
   CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
*             event_id             = wa_starttime-eventid
*             event_param          = wa_starttime-eventparm
*             event_periodic       = wa_starttime-periodic
             JOBCOUNT             = G_JOBCOUNT
             JOBNAME              = G_JOBNAME
*             laststrtdt           = wa_starttime-laststrtdt
*             laststrttm           = wa_starttime-laststrttm
*             prddays              = 1
*             prdhours             = 0
*             prdmins              = 0
*             prdmonths            = 0
*             prdweeks             = 0
*             sdlstrtdt            = wa_starttime-sdlstrtdt
*             sdlstrttm            = wa_starttime-sdlstrttm
             STRTIMMED            =  'X'
*             targetsystem         = g_host
*             DIRECT_START         = 'X'
        EXCEPTIONS
             CANT_START_IMMEDIATE = 01
             INVALID_STARTDATE    = 02
             JOBNAME_MISSING      = 03
             JOB_CLOSE_FAILED     = 04
             JOB_NOSTEPS          = 05
             JOB_NOTEX            = 06
             LOCK_FAILED          = 07
             OTHERS               = 99.
   IF SY-SUBRC EQ 0.
     "error processing
   ENDIF.


 ENDFORM.                    " CLOSE_JOB
*&---------------------------------------------------------------------*
*&      Form  GET_OUTPUT_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_OUTPUT_LIST.

   CALL FUNCTION 'LIST_FROM_MEMORY'
     TABLES
       LISTOBJECT = IST_LIST
     EXCEPTIONS
       NOT_FOUND  = 1
       OTHERS     = 2.

   CALL FUNCTION 'LIST_TO_ASCI'
     TABLES
       LISTASCI   = IST_LSMW_LOG
       LISTOBJECT = IST_LIST.

   IF NOT IST_LSMW_LOG[] IS INITIAL.
     LOOP AT IST_LSMW_LOG INTO WA_LSMW_LOG.
       IF WA_LSMW_LOG+0(1) = ' ' AND ( WA_LSMW_LOG+4(1) = 'S' OR
          WA_LSMW_LOG+4(1) = 'E' OR WA_LSMW_LOG+4(1) = 'W' ).
         WA_MERRDAT-MSGTY = WA_LSMW_LOG+4(1).
         WA_MERRDAT-MSGID = WA_LSMW_LOG+6(2).
         WA_MERRDAT-MSGNO = WA_LSMW_LOG+26(3).
         WA_MERRDAT-MSGV1 = WA_LSMW_LOG+31(50).
         WA_MERRDAT-MSGV2 = WA_LSMW_LOG+81(50).
         WA_MERRDAT-MATNR = WA_MERRDAT-MSGV1+9(9).
         APPEND WA_MERRDAT TO IST_MERRDAT.
         CLEAR :WA_MERRDAT, WA_LSMW_LOG.
       ENDIF.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " GET_OUTPUT_LIST
*&---------------------------------------------------------------------*
*&      Form  POPULATE_LOG
*&---------------------------------------------------------------------*
*       POPULATE DI PROGRAM LOG INTO SCREEN INTERNAL TABLE IST_LOG
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM POPULATE_LOG.
   DATA L_LOG(3) TYPE N.
   DATA L_DATA(3) TYPE N.
   DATA L_MATNR TYPE MARA-MATNR. "03062011

   IF NOT IST_MERRDAT[] IS INITIAL.
     DESCRIBE TABLE IST_MERRDAT LINES L_LOG.
     L_DATA = 0.
*     do l_log times.
*       clear : g_TC_DETAILS_wa, wa_merrdat,wa_log.
*       l_data = l_data + 1.
*       read table g_TC_DETAILS_itab into g_TC_DETAILS_wa
*                                    index l_data.
*       if sy-subrc = 0.
*         MOVE-CORRESPONDING g_TC_DETAILS_wa TO wa_log.
*         read table ist_merrdat into wa_merrdat index l_data.
*         if sy-subrc = 0.
*           wa_log-MSGNO = wa_merrdat-MSGNO.
*           wa_log-MSGTY = wa_merrdat-MSGTY.
*           concatenate wa_merrdat-MSGV1 wa_merrdat-MSGV2 into
*                                            wa_log-MSGV1.
*           append wa_log to ist_log.
*           if wa_log-MSGTY = 'S' and wa_log-MSGNO = '800'.
*             PERFORM UPDATE_TABLE.
*           endif.
*         endif.
*       endif.
*     enddo.
     CLEAR : G_TC_DETAILS_WA, WA_MERRDAT,WA_LOG.
     LOOP AT G_TC_DETAILS_ITAB INTO G_TC_DETAILS_WA WHERE FLAG = 'X'.
* Begin of <> on 03062011 BY SUDHIR SHARMA
       select SINGLE matnr into l_matnr from mara where BMATN = G_TC_DETAILS_WA-MATNR
                                             AND MFRNR = G_TC_DETAILS_WA-MFRNR
                                             AND MFRPN = G_TC_DETAILS_WA-MFRPN.
       if sy-subrc = 0.
          update zmm_mpn set mpnco = l_matnr
                             SFLAG = 'C'
                             where DOCNO = G_TC_DETAILS_WA-DOCNO
                                AND MATNR = G_TC_DETAILS_WA-MATNR
                                AND MFRNR = G_TC_DETAILS_WA-MFRNR
                                AND MFRPN = G_TC_DETAILS_WA-MFRPN.


       endif.
       L_DATA = L_DATA + 1.
       MOVE-CORRESPONDING G_TC_DETAILS_WA TO WA_LOG.
       READ TABLE IST_MERRDAT INTO WA_MERRDAT INDEX L_DATA.
       IF SY-SUBRC = 0.
         WA_LOG-MSGNO = WA_MERRDAT-MSGNO.
         WA_LOG-MSGTY = WA_MERRDAT-MSGTY.
         CONCATENATE l_matnr WA_MERRDAT-MSGV2 INTO        "WA_MERRDAT-MSGV1
                                      WA_LOG-MSGV1.
         APPEND WA_LOG TO IST_LOG.
*         IF WA_LOG-MSGTY = 'S' AND WA_LOG-MSGNO = '800'.
*           PERFORM UPDATE_TABLE.
*         ENDIF.
       ENDIF.
* End of <> on 03062011
     ENDLOOP.
     G_TS_REQUEST-PRESSED_TAB = 'TS_REQUEST_FC2'.
   ENDIF.

 ENDFORM.                    " POPULATE_LOG
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM UPDATE_TABLE.

*   update zmm_mpn set: sflag = 'C', mpnco = wa_log-MSGV1+9(9)
*                                 where MATNR = wa_log-matnr
*                                  and MFRNR = g_TC_DETAILS_wa-mfrnr
*                                  and MFRPN = g_TC_DETAILS_wa-mfrpn
*                                  and DOCNO = wa_log-docno.
*                                  and MPNCO = ' '.
   SELECT SINGLE * FROM ZMM_MPN WHERE DOCNO = WA_LOG-DOCNO
                                AND MATNR = WA_LOG-MATNR
                                AND MFRNR = G_TC_DETAILS_WA-MFRNR
                                AND MFRPN = G_TC_DETAILS_WA-MFRPN.
   IF SY-SUBRC = 0.
     ZMM_MPN-MPNCO = WA_LOG-MSGV1+9(9).
     ZMM_MPN-SFLAG = 'C'.
     IF NOT ZMM_MPN-MATNR IS INITIAL AND                    "+rk001
        NOT ZMM_MPN-MFRNR IS INITIAL AND                    "+rk001
        NOT ZMM_MPN-MFRPN IS INITIAL.                       "+rk001
       MODIFY ZMM_MPN.
       IF SY-SUBRC = 0.
         COMMIT WORK.
       ELSE.
         ROLLBACK WORK.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    " UPDATE_TABLE
*&---------------------------------------------------------------------*
*&      Form  lock_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOCK_RECORD.

   CALL FUNCTION 'ENQUEUE_EZMM_MPN'
     EXPORTING
       MODE_ZMM_MPN   = 'E'
       MANDT          = SY-MANDT
       DOCNO          = G_TC_DETAILS_WA-DOCNO
       MATNR          = G_TC_DETAILS_WA-MATNR
       MFRNR          = G_TC_DETAILS_WA-MFRNR
       MFRPN          = G_TC_DETAILS_WA-MFRPN
     EXCEPTIONS
       FOREIGN_LOCK   = 1
       SYSTEM_FAILURE = 2
       OTHERS         = 3.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " lock_record
*&---------------------------------------------------------------------*
*&      Form  unlock_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM UNLOCK_RECORDS.
   CLEAR G_TC_DETAILS_WA.

   LOOP AT G_TC_DETAILS_ITAB INTO G_TC_DETAILS_WA WHERE FLAG = 'X'.
     CALL FUNCTION 'DEQUEUE_EZMM_MPN'
       EXPORTING
         MODE_ZMM_MPN = 'E'
         MANDT        = SY-MANDT
         DOCNO        = G_TC_DETAILS_WA-DOCNO
         MATNR        = G_TC_DETAILS_WA-MATNR
         MFRNR        = G_TC_DETAILS_WA-MFRNR
         MFRPN        = G_TC_DETAILS_WA-MFRPN.

   ENDLOOP.
 ENDFORM.                    " unlock_records
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SEND_MAIL.

* Fill the document
   DESCRIBE TABLE IST_LOG LINES G_ENTRIES.
   IF G_ENTRIES > 0.
     SORT IST_LOG BY DOCNO.
     DELETE ADJACENT DUPLICATES FROM IST_LOG COMPARING MATNR.
     WA_DOC_CHNG-OBJ_NAME = WA_LOG-DOCNO.
     WA_DOC_CHNG-OBJ_DESCR = 'mpn code generation request status'.
     WA_DOC_CHNG-SENSITIVTY = 'B'.

     LOOP AT IST_LOG INTO WA_LOG.
       IF SY-TABIX = 1.
         WA_DOC_CHNG-OBJ_NAME = WA_LOG-DOCNO.
       ENDIF.
       IST_OBJCONT = WA_LOG-MSGV1.
       IF WA_LOG-MSGTY = 'S'.
         CONCATENATE IST_OBJCONT TEXT-100 WA_LOG-MATNR TEXT-101
         WA_LOG-DOCNO TEXT-102 INTO IST_OBJCONT SEPARATED BY SPACE.
       ELSE.
         CONCATENATE IST_OBJCONT TEXT-100 WA_LOG-MATNR TEXT-101
         WA_LOG-DOCNO TEXT-103 INTO IST_OBJCONT SEPARATED BY SPACE.
       ENDIF.
       APPEND IST_OBJCONT.
       AT NEW ERNAM.
* Fill the receiver list
         CLEAR IST_RECLIST.
         IST_RECLIST-RECEIVER = WA_LOG-ERNAM.
*         ist_reclist-rec_type = 'b'.
         IST_RECLIST-EXPRESS = 'X'.
         APPEND IST_RECLIST.
       ENDAT.
     ENDLOOP.
     WA_DOC_CHNG-DOC_SIZE = ( G_ENTRIES - 1 ) * 255 +
                            STRLEN( IST_OBJCONT ).
   ENDIF.

   IF NOT IST_RECLIST[] IS INITIAL.
     SORT IST_RECLIST.
     DELETE ADJACENT DUPLICATES FROM IST_RECLIST.
   ENDIF.

* Send the document
   CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
     EXPORTING
       DOCUMENT_TYPE              = 'RAW'
       DOCUMENT_DATA              = WA_DOC_CHNG
       PUT_IN_OUTBOX              = 'X'
     TABLES
       OBJECT_CONTENT             = IST_OBJCONT
       RECEIVERS                  = IST_RECLIST
     EXCEPTIONS
       TOO_MANY_RECEIVERS         = 1
       DOCUMENT_NOT_SENT          = 2
       OPERATION_NO_AUTHORIZATION = 4
       OTHERS                     = 99.


   CASE SY-SUBRC.
     WHEN 0.
       LOOP AT IST_RECLIST.
         IF IST_RECLIST-RECEIVER = SPACE.
           G_NAME = IST_RECLIST-REC_ID.
         ELSE.
           G_NAME = IST_RECLIST-RECEIVER.
         ENDIF.
         IF IST_RECLIST-RETRN_CODE = 0.
           WRITE: / G_NAME, ': succesfully sent'.
         ELSE.
           WRITE: / G_NAME, ': error occured'.
         ENDIF.
       ENDLOOP.
     WHEN 1.
       WRITE: / 'too many receivers specified !'.
     WHEN 2.
       WRITE: / 'no receiver got the document !'.
     WHEN 4.
       WRITE: / 'missing send authority !'.
     WHEN OTHERS.
       WRITE: / 'unexpected error occurred !'.
   ENDCASE.

   CLEAR : IST_RECLIST, IST_OBJCONT, WA_DOC_CHNG.
   REFRESH : IST_RECLIST, IST_OBJCONT.

 ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  update_mara
*&---------------------------------------------------------------------*
*       use Call transaction MM02 to update MARA Table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM UPDATE_MARA USING WA_MARA STRUCTURE MARA.
* Begin of <RD1K960611>
* Modified the length, because it was not slection proper view if no. of
* views for Maerial Master is more than 10.
*   DATA : l_strlen TYPE n.
   DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
   DATA : L_STRLEN(2) TYPE N.
* End of <RD1K960611>

   CLEAR : IST_BDCDATA, MESSTAB.
   REFRESH : IST_BDCDATA, MESSTAB.

   L_STRLEN = STRLEN( WA_MARA-PSTAT ).

   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
   PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                 'RMMG1-MATNR'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '=ENTR'.
   PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
                                  WA_MARA-MATNR.
   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.

   IF L_STRLEN LT 6.
* Begin of <RD1K976493> on 03060211 by Sudhir Sharma
     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'MSICHTAUSW-DYTXT(04)'.
     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '=ENTR'.
     PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(04)'
                                   'X'.
*     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                   'MSICHTAUSW-DYTXT(06)'.
*     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                   '=ENTR'.
*     PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(06)'
*                                   'X'.
* End of <RD1K976493>
   ELSE.
     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                   'MSICHTAUSW-DYTXT(10)'.
     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '=ENTR'.
     PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(10)'
                                   'X'.
   ENDIF.
   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0080'.
   PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                 'RMMG1-WERKS'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '=ENTR'.
   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '/00'.
*perform bdc_field       using 'MARA-MEINS'
*                              'NO'.
*perform bdc_field       using 'MARA-MATKL'
*                              '21'.
   PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                 'MARA-MPROF'.
   PERFORM BDC_FIELD       USING 'MARA-MPROF'
                                 '0002'.
*perform bdc_field       using 'MARA-MFRPN'
*                              '157098'.
*perform bdc_field       using 'MARA-MFRNR'
*                              '300001'.
   PERFORM BDC_DYNPRO      USING 'SAPLSPO1' '0300'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '=YES'.
   CALL TRANSACTION 'MM02' USING IST_BDCDATA MODE 'N' UPDATE 'L' MESSAGES INTO MESSTAB.
*  saB_PUNIT
   IF SY-SUBRC <> 0.
     MESSAGE E330(ZMM) WITH TEXT-106.
     LEAVE PROGRAM.
   ENDIF.
 ENDFORM.                    " update_mara

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
 FORM BDC_DYNPRO USING PROGRAM DYNPRO.
   CLEAR IST_BDCDATA.
   IST_BDCDATA-PROGRAM  = PROGRAM.
   IST_BDCDATA-DYNPRO   = DYNPRO.
   IST_BDCDATA-DYNBEGIN = 'X'.
   APPEND IST_BDCDATA.
 ENDFORM.                    "bdc_dynpro

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
 FORM BDC_FIELD USING FNAM FVAL.
   CLEAR IST_BDCDATA.
   IST_BDCDATA-FNAM = FNAM.
   IST_BDCDATA-FVAL = FVAL.
   APPEND IST_BDCDATA.
 ENDFORM.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  check_orig_mpncode
*&---------------------------------------------------------------------*
* chk if mpn code has been created for org.vendor/partno if not generate
*----------------------------------------------------------------------*
* g_tc_details_itab - materials for which mpn code to be generated
* ist_bmatn - orig vendor/partno for the materials in g_tc_details_itab
*
*----------------------------------------------------------------------*
 FORM CHECK_ORIG_MPNCODE.
   DATA L_INDEX LIKE SY-TABIX.
   DATA L_TC_DETAILS_ITAB LIKE G_TC_DETAILS_ITAB WITH HEADER LINE.
   REFRESH L_TC_DETAILS_ITAB.

*----GET ORIG VEND/PARTNO OF ALL MATERIALS SELECTED ------*
   SELECT MATNR MFRNR MFRPN BMATN FROM MARA INTO TABLE IST_BMATN
                                 FOR ALL ENTRIES IN G_TC_DETAILS_ITAB
                                 WHERE MATNR =  G_TC_DETAILS_ITAB-MATNR
                                 AND MFRNR <> ' '
                                 AND MFRPN <> ' '
                                 AND BMATN = ' '.
   IF SY-SUBRC = 0.
     PERFORM GET_MATNR_MPNCODE.
     LOOP AT IST_BMATN INTO WA_BMATN.
       MOVE SY-TABIX TO L_INDEX.
       READ TABLE IST_MARA WITH KEY BMATN = WA_BMATN-MATNR
                                TRANSPORTING NO FIELDS.
       IF SY-SUBRC = 0.
*---delete matnr's which have mpn code for org vend/partno
         DELETE IST_BMATN INDEX L_INDEX.
       ENDIF.
     ENDLOOP.

     LOOP AT G_TC_DETAILS_ITAB INTO G_TC_DETAILS_WA.
       READ TABLE IST_BMATN INTO WA_BMATN WITH KEY
                                 MATNR = G_TC_DETAILS_WA-MATNR.
       IF SY-SUBRC IS INITIAL.
         MOVE-CORRESPONDING G_TC_DETAILS_WA TO L_TC_DETAILS_ITAB.
         L_TC_DETAILS_ITAB-MFRNR = WA_BMATN-MFRNR.
         L_TC_DETAILS_ITAB-MFRPN = WA_BMATN-MFRPN.
         APPEND L_TC_DETAILS_ITAB.
       ENDIF.
       APPEND G_TC_DETAILS_WA TO L_TC_DETAILS_ITAB.
     ENDLOOP.
   ENDIF.

   CLEAR L_TC_DETAILS_ITAB.
   G_TC_DETAILS_ITAB[] = L_TC_DETAILS_ITAB[].

 ENDFORM.                    " check_orig_mpncode
*&---------------------------------------------------------------------*
*&      Form  get_matnr_no_mpncode
*&---------------------------------------------------------------------*
*       get matnr with mpn code for its org vend/partno
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_MATNR_MPNCODE.

   SELECT BMATN FROM MARA INTO TABLE IST_MARA FOR ALL ENTRIES IN
                              G_TC_DETAILS_ITAB WHERE
                              BMATN =  G_TC_DETAILS_ITAB-MATNR.
   IF SY-SUBRC = 0.
     SORT IST_MARA.
     DELETE ADJACENT DUPLICATES FROM IST_MARA.
   ENDIF.
 ENDFORM.                    " get_matnr_no_mpncode
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM UPDATE_MATERIAL .
   DATA: LT_MAT TYPE STANDARD TABLE OF MERRDAT,
         LS_MARA1 TYPE MARA,
         LS_MARA2 TYPE MARA.
   FIELD-SYMBOLS: <FS_MAT> TYPE MERRDAT.

   LT_MAT[] = IST_MERRDAT[].

   IF LT_MAT[] IS NOT INITIAL.
     LOOP AT LT_MAT ASSIGNING <FS_MAT>.
       CLEAR: LS_MARA1, LS_MARA2.
       SELECT SINGLE * FROM MARA INTO LS_MARA1 WHERE MATNR = <FS_MAT>-MATNR.
       IF SY-SUBRC EQ 0 .
         SELECT SINGLE * FROM MARA INTO LS_MARA2 WHERE MATNR = LS_MARA1-BMATN.
         IF SY-SUBRC EQ 0 .
           PERFORM UPDATE USING LS_MARA1 LS_MARA2.
         ENDIF.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " UPDATE_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MARA2  text
*----------------------------------------------------------------------*
 FORM UPDATE  USING  P_LS_MARA1 TYPE MARA
                     P_LS_MARA2 TYPE MARA.
*perform open_group.
   DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

   CLEAR: IST_BDCDATA[], IST_BDCDATA, MESSTAB, MESSTAB[].


   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
   PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                 'RMMG1-MATNR'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '=AUSW'.
   PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
                                 P_LS_MARA1-MATNR.
   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.
   PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                 'MSICHTAUSW-DYTXT(01)'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '=ENTR'.
   PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(01)'
                                 'X'.
   PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '4000'.
   PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                 '=BU'.
*perform bdc_field       using 'MAKT-MAKTX'
*                              'CIRCUIT BREAKER SHUNT 480V,3P,100A FDC'.
*perform bdc_field       using 'MARA-MATKL'
*                              '28'.
*perform bdc_field       using 'MARA-BMATN'
*                              '280200142'.
*perform bdc_field       using 'MARA-MFRPN'
*                              'XS100NB'.
*perform bdc_field       using 'MARA-MFRNR'
*                              '400853'.
   PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                 'MARA-ZZCAP_CODE'.
   PERFORM BDC_FIELD       USING 'MARA-ZZCAP_CODE'
                                 P_LS_MARA2-ZZCAP_CODE.
   PERFORM BDC_FIELD       USING 'MARA-ZZMODELNO'
                                 P_LS_MARA2-ZZMODELNO.
   PERFORM BDC_FIELD       USING 'MARA-ZZMODELEXTN'
                                 P_LS_MARA2-ZZMODELEXTN.
   PERFORM BDC_FIELD       USING 'MARA-ZZREF_BOOK'
                                 P_LS_MARA2-ZZREF_BOOK.
   PERFORM BDC_FIELD       USING 'MARA-ZZREF_BOOK_DESC'
                                 P_LS_MARA2-ZZREF_BOOK_DESC.
   PERFORM BDC_FIELD       USING 'MARA-ZZSANO'
                                 P_LS_MARA2-ZZSANO.
   PERFORM BDC_FIELD       USING 'MARA-ZZCSADES'
                                 P_LS_MARA2-ZZCSADES.
   CALL TRANSACTION 'MM02' USING IST_BDCDATA MODE 'N' UPDATE 'L' MESSAGES INTO MESSTAB.

*perform close_group.
 ENDFORM.                    " UPDATE
