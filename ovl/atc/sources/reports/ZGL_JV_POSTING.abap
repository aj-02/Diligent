*&---------------------------------------------------------------------*
*& Program  : ZGL_JV_POSTING
*& Description : Fetch Profit Center from JVTO1 and Post GL Document
*&               (Similar to F-02 / FB01) using BAPI_ACC_DOCUMENT_POST
*&---------------------------------------------------------------------*

REPORT zgl_jv_posting.

*---------------------------------------------------------------------*
* SELECTION SCREEN
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    p_bukrs TYPE bukrs OBLIGATORY,          " Company Code
    p_gjahr TYPE gjahr OBLIGATORY,          " Fiscal Year
    p_jv    TYPE string OBLIGATORY.         " JV Number
SELECTION-SCREEN END OF BLOCK b1.

*---------------------------------------------------------------------*
* TYPE DECLARATIONS
*---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_jvto1,
    jv_number  TYPE string,
    prctr      TYPE prctr,       " Profit Center
    hkont      TYPE hkont,       " GL Account
    amount     TYPE wrbtr,       " Amount
    currency   TYPE waers,       " Currency
    bschl      TYPE bschl,       " Posting Key
    kostl      TYPE kostl,       " Cost Center (optional)
  END OF ty_jvto1.

*---------------------------------------------------------------------*
* DATA DECLARATIONS
*---------------------------------------------------------------------*
DATA:
  ls_jvto1          TYPE ty_jvto1,
  lt_jvto1          TYPE TABLE OF ty_jvto1,

  " BAPI Header
  ls_doc_header     TYPE bapiache09,

  " BAPI Line Items (GL)
  lt_accountgl      TYPE TABLE OF bapiacgl09,
  ls_accountgl      TYPE bapiacgl09,

  " BAPI Currency/Amount
  lt_currencyamount TYPE TABLE OF bapiaccr09,
  ls_currencyamount TYPE bapiaccr09,

  " BAPI Return
  lt_return         TYPE TABLE OF bapiret2,
  ls_return         TYPE bapiret2,

  " BAPI Object Key (returned document)
  lv_obj_key        TYPE bapibus1002_key-obj_key,

  lv_line_no        TYPE int4.

*---------------------------------------------------------------------*
* START OF SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.

  " Step 1: Fetch data from JVTO1 based on JV, Company Code, Fiscal Year
  PERFORM fetch_jvto1_data.

  " Step 2: Check if data was found
  IF lt_jvto1 IS INITIAL.
    MESSAGE 'No records found in JVTO1 for the given inputs.' TYPE 'E'.
    RETURN.
  ENDIF.

  " Step 3: Prepare BAPI Header
  PERFORM prepare_bapi_header.

  " Step 4: Prepare BAPI Line Items
  PERFORM prepare_bapi_line_items.

  " Step 5: Call BAPI to Post Document
  PERFORM post_gl_document.

*---------------------------------------------------------------------*
* FORM: FETCH_JVTO1_DATA
*---------------------------------------------------------------------*
FORM fetch_jvto1_data.

  " NOTE: Replace JVTO1 with the actual table/view name in your system.
  " Adjust field names to match your JVTO1 structure.
  SELECT jv_number
         prctr
         hkont
         amount
         currency
         bschl
         kostl
    FROM jvto1                          "#EC CI_NOWHERE
    INTO TABLE lt_jvto1
    WHERE jv_number = p_jv
      AND bukrs     = p_bukrs
      AND gjahr     = p_gjahr.

  IF sy-subrc <> 0.
    MESSAGE |No data found in JVTO1 for JV: { p_jv }, Company Code: { p_bukrs }, Fiscal Year: { p_gjahr }| TYPE 'W'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: PREPARE_BAPI_HEADER
*---------------------------------------------------------------------*
FORM prepare_bapi_header.

  CLEAR ls_doc_header.

  ls_doc_header-bus_act     = 'RFBU'.        " FI Posting
  ls_doc_header-username    = sy-uname.
  ls_doc_header-header_txt  = |JV Posting: { p_jv }|.
  ls_doc_header-comp_code   = p_bukrs.
  ls_doc_header-doc_date    = sy-datum.
  ls_doc_header-pstng_date  = sy-datum.
  ls_doc_header-fisc_year   = p_gjahr.
  ls_doc_header-doc_type    = 'SA'.          " GL Document Type (same as F-02/FB01)
  ls_doc_header-ref_doc_no  = p_jv.          " JV as Reference

ENDFORM.

*---------------------------------------------------------------------*
* FORM: PREPARE_BAPI_LINE_ITEMS
*---------------------------------------------------------------------*
FORM prepare_bapi_line_items.

  CLEAR: lt_accountgl, lt_currencyamount.
  lv_line_no = 0.

  LOOP AT lt_jvto1 INTO ls_jvto1.

    lv_line_no = lv_line_no + 1.

    " --- GL Account Line Item ---
    CLEAR ls_accountgl.
    ls_accountgl-itemno_acc  = lv_line_no.
    ls_accountgl-gl_account  = ls_jvto1-hkont.
    ls_accountgl-comp_code   = p_bukrs.
    ls_accountgl-pstng_date  = sy-datum.
    ls_accountgl-doc_type    = 'SA'.
    ls_accountgl-profit_ctr  = ls_jvto1-prctr.     " Profit Center from JVTO1
    ls_accountgl-costcenter  = ls_jvto1-kostl.     " Cost Center (if applicable)
    ls_accountgl-item_text   = |JV: { p_jv }|.
    APPEND ls_accountgl TO lt_accountgl.

    " --- Currency / Amount ---
    CLEAR ls_currencyamount.
    ls_currencyamount-itemno_acc  = lv_line_no.
    ls_currencyamount-currency    = ls_jvto1-currency.
    ls_currencyamount-amt_doccur  = ls_jvto1-amount.

    " Determine debit/credit based on posting key
    IF ls_jvto1-bschl = '40'.             " Debit posting key
      ls_currencyamount-dc_ind = 'S'.     " Debit
    ELSE.                                  " Credit posting key (50, etc.)
      ls_currencyamount-dc_ind = 'H'.     " Credit
    ENDIF.

    APPEND ls_currencyamount TO lt_currencyamount.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: POST_GL_DOCUMENT
*---------------------------------------------------------------------*
FORM post_gl_document.

  CLEAR: lt_return, lv_obj_key.

  " Call BAPI to post document
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = ls_doc_header
    IMPORTING
      obj_key           = lv_obj_key
    TABLES
      accountgl         = lt_accountgl
      currencyamount    = lt_currencyamount
      return            = lt_return.

  " Check for errors in return table
  READ TABLE lt_return INTO ls_return
    WITH KEY type = 'E'.

  IF sy-subrc = 0.
    " Errors found — rollback
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE |Document posting failed: { ls_return-message }| TYPE 'E'.
  ELSE.
    " Success — commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    MESSAGE |Document posted successfully. Document No: { lv_obj_key }| TYPE 'S'.
  ENDIF.

  " Display all return messages
  LOOP AT lt_return INTO ls_return.
    WRITE: / ls_return-type, ls_return-message.
  ENDLOOP.

ENDFORM.
