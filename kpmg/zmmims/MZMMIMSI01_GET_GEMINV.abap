*&---------------------------------------------------------------------*
*& Program    : SAPMZMMIMS  (T-Code ZMMIMS)
*& Include    : MZMMIMSI01
*& Module     : GET_GEMINV  (F4 help for GeM Invoice No.)
*& Marker     : +019
*&---------------------------------------------------------------------*
*& Issue reported:
*&   1) In Change mode the GeM Invoice No. is not displayed.
*&   2) On F4 the search help returns "No values found" (msg DH801),
*&      yet a GeM Invoice No. still appears in the field afterwards.
*&
*& Root causes corrected in this module:
*&   a) DELETE ADJACENT DUPLICATES ran BEFORE the PO filter, so when one
*&      GeM invoice number existed against more than one PO the surviving
*&      row could carry a different EBELN and was then deleted - the
*&      correct invoice disappeared from the hit list.
*&   b) EBELN was not part of the WHERE clause: the complete ZGEM_BILL
*&      table was joined against EKKO/LFA1 and read into memory on every
*&      F4, only to be discarded afterwards.
*&   c) IST_RETURN_TAB is declared WITH HEADER LINE (MZMMIMSTOP line 28)
*&      and is shared by every search help of this program (plant,
*&      pur. group, currency, tracking no., indentor CPF). This module
*&      did not REFRESH it and assigned IST_RETURN_TAB-FIELDVAL
*&      unconditionally. When the popup found nothing - or the user
*&      cancelled - the field was filled with the value last picked in a
*&      DIFFERENT search help. That is the number appearing "automatically".
*&
*& Note on BSART / PROCSTAT:
*&   The original selection was restricted to
*&       EKKO-BSART IN ( 'MMGM' , 'MMGS' ) AND EKKO-PROCSTAT EQ '05'.
*&   These restrictions are retained below but isolated in a RANGE so they
*&   can be maintained / switched off in one place. Verify EKKO-BSART and
*&   EKKO-PROCSTAT of the affected PO (e.g. 4200000203) in SE16 before
*&   keeping them - they are a likely reason for an empty hit list.
*&   To drop the restriction, comment out the two APPENDs marked (*).
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  GET_GEMINV  INPUT
*&---------------------------------------------------------------------*
*       F4 help : GeM Invoice No. for the PO entered on the screen
*----------------------------------------------------------------------*
MODULE get_geminv INPUT.

*+019 - Start
  DATA : ls_ret_gem TYPE ddshretval.                        "+019
  DATA : lr_bsart   TYPE RANGE OF ekko-bsart,               "+019
         ls_bsart   LIKE LINE OF lr_bsart,                  "+019
         lr_procst  TYPE RANGE OF ekko-procstat,            "+019
         ls_procst  LIKE LINE OF lr_procst.                 "+019

* Search help table is shared program wide - clear header line AND body
* so that a cancelled / empty F4 cannot leave a foreign value behind.
  CLEAR   ist_return_tab.                                   "+019
  REFRESH ist_return_tab.                                   "+019

* Without a PO there is nothing to propose
  IF wa_zmm_ims-ebeln IS INITIAL.                           "+019
    MESSAGE 'Please enter the Purchase Order No. first'     "+019
            TYPE 'S' DISPLAY LIKE 'W'.                      "+019
    RETURN.                                                 "+019
  ENDIF.                                                    "+019

* Document type restriction  (*) comment out to deactivate
  CLEAR ls_bsart.                                           "+019
  ls_bsart-sign = 'I'. ls_bsart-option = 'EQ'.              "+019
  ls_bsart-low  = 'MMGM'. APPEND ls_bsart TO lr_bsart.      "+019
  ls_bsart-low  = 'MMGS'. APPEND ls_bsart TO lr_bsart.      "+019

* Processing state restriction  (*) comment out to deactivate
  CLEAR ls_procst.                                          "+019
  ls_procst-sign = 'I'. ls_procst-option = 'EQ'.            "+019
  ls_procst-low  = '05'. APPEND ls_procst TO lr_procst.     "+019

* Filter on the PO in the database, not afterwards in ABAP
  SELECT i~gem_invoice_no , i~order_id , e~ebeln , e~lifnr , l~name1
    FROM zgem_bill AS i
    INNER JOIN ekko AS e
      ON i~order_id EQ e~zgempo
    INNER JOIN lfa1 AS l
      ON e~lifnr    EQ l~lifnr
    INTO TABLE @DATA(it_geminv)
    WHERE e~ebeln    EQ @wa_zmm_ims-ebeln                   "+019
      AND e~bsart    IN @lr_bsart                           "+019
      AND e~procstat IN @lr_procst.                         "+019

* Duplicates are removed only AFTER the PO filter has been applied
  SORT it_geminv BY gem_invoice_no.                                    "+019
  DELETE ADJACENT DUPLICATES FROM it_geminv COMPARING gem_invoice_no.  "+019

  IF it_geminv IS INITIAL.                                  "+019
    MESSAGE 'No GeM invoice available for this Purchase Order'  "+019
            TYPE 'S' DISPLAY LIKE 'W'.                      "+019
    RETURN.               " field is left untouched         "+019
  ENDIF.                                                    "+019
*+019 - End

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'GEM_INVOICE_NO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS-GEM_INVOICE_NO'
      value_org       = 'S'
    TABLES
      value_tab       = it_geminv
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*+019 - Start
* Do NOT raise a hard message and do NOT touch the screen field when the
* popup returned nothing - the previous coding overwrote the field with
* the header line left over from another search help.
  IF sy-subrc <> 0.                                         "+019
    IF sy-subrc = 2.                                        "+019
      MESSAGE 'No GeM invoice available for this Purchase Order'  "+019
              TYPE 'S' DISPLAY LIKE 'W'.                    "+019
    ELSE.                                                   "+019
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno          "+019
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4      "+019
              DISPLAY LIKE 'W'.                             "+019
    ENDIF.                                                  "+019
    RETURN.                                                 "+019
  ENDIF.                                                    "+019

* Read the selected line explicitly instead of relying on the header line
  READ TABLE ist_return_tab INDEX 1 INTO ls_ret_gem.        "+019
  IF sy-subrc = 0.                                          "+019
    wa_zmm_ims-gem_invoice_no = ls_ret_gem-fieldval.        "+019
  ENDIF.                                                    "+019
*+019 - End

ENDMODULE.
