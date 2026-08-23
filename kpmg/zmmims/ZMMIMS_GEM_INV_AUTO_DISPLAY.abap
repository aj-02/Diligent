*&---------------------------------------------------------------------*
*& Program : SAPMZMMIMS   (T-Code ZMMIMS)
*& Subject : GeM Invoice No. is determined from the Purchase Order and
*&           filled automatically - no F4 required - and is saved to
*&           ZMM_IMS-GEM_INVOICE_NO when the document is created.
*& Marker  : +019
*&---------------------------------------------------------------------*
*& HOW IT WORKS
*&   FORM get_gem_invoice_no reads the GeM invoice belonging to the PO
*&   (ZGEM_BILL -> EKKO-ZGEMPO) and moves it into WA_ZMM_IMS-GEM_INVOICE_NO.
*&   Because the screen field is bound to that work area, the number is
*&   shown on the screen at once, and because FORM save_data_ims does
*&   MODIFY zmm_ims FROM wa_zmm_ims (MZMMIMSF01 line 1113) the number is
*&   written to the database together with the rest of the document.
*&
*&   Call points:
*&     A) MODULE valid_input_200      - Create : as soon as the PO is entered
*&     B) FORM   save_data_ims        - Create : safety net just before the
*&                                      MODIFY, so the value can never be
*&                                      missing on the database
*&     C) FORM   check_validation_150 - Change / Display : fills the field
*&                                      for documents that were created
*&                                      before this correction
*&
*& DESIGN DECISIONS
*&   1. The field is filled only when it is still INITIAL. A value already
*&      stored on the record, or typed / chosen by the user, is never
*&      overwritten. Calling the FORM more than once is therefore harmless.
*&   2. Only GeM invoices that also exist in ZGEM_BILLDET are proposed.
*&      MODULE check_geminv (MZMMIMSI01 line 1902) validates the field
*&      against ZGEM_BILLDET with a type 'E' message; proposing a number
*&      that is not in that table would make the document unsaveable.
*&   3. If the PO carries more than one GeM invoice the first one (sorted
*&      ascending) is filled and an information message is issued. The user
*&      can still overwrite it with F4.
*&   4. The document type / processing state restrictions of the existing
*&      F4 (BSART IN 'MMGM','MMGS', PROCSTAT = '05') are reproduced so both
*&      places behave identically. If nothing is proposed, check
*&      EKKO-BSART and EKKO-PROCSTAT of the PO in SE16 first - comment out
*&      the lines marked (*) to switch the restriction off.
*&---------------------------------------------------------------------*


*&=====================================================================*
*& PART 1 : NEW FORM
*& Include MZMMIMSF01 - append at the END of the include, after the
*&                      ENDFORM of FORM upd_ims_db_table (line 3433)
*&=====================================================================*

*&---------------------------------------------------------------------*
*&      Form  get_gem_invoice_no                                   "+019
*&---------------------------------------------------------------------*
*& Determines the GeM Invoice No. of the Purchase Order and moves it
*& into WA_ZMM_IMS-GEM_INVOICE_NO. Only fills an empty field.
*&---------------------------------------------------------------------*
FORM get_gem_invoice_no.                                    "+019

  DATA : lr_bsart  TYPE RANGE OF ekko-bsart,                "+019
         ls_bsart  LIKE LINE OF lr_bsart,                   "+019
         lr_procst TYPE RANGE OF ekko-procstat,             "+019
         ls_procst LIKE LINE OF lr_procst.                  "+019

* No PO, or the field is already filled - nothing to do
  IF wa_zmm_ims-ebeln          IS INITIAL OR                "+019
     wa_zmm_ims-gem_invoice_no IS NOT INITIAL.              "+019
    RETURN.                                                 "+019
  ENDIF.                                                    "+019

* Document type restriction   (*) comment out to deactivate
  CLEAR ls_bsart.                                           "+019
  ls_bsart-sign = 'I'. ls_bsart-option = 'EQ'.              "+019
  ls_bsart-low  = 'MMGM'. APPEND ls_bsart TO lr_bsart.      "+019
  ls_bsart-low  = 'MMGS'. APPEND ls_bsart TO lr_bsart.      "+019

* Processing state restriction (*) comment out to deactivate
  CLEAR ls_procst.                                          "+019
  ls_procst-sign = 'I'. ls_procst-option = 'EQ'.            "+019
  ls_procst-low  = '05'. APPEND ls_procst TO lr_procst.     "+019

* GeM invoice(s) of this PO. ZGEM_BILLDET is joined so that only numbers
* which pass MODULE check_geminv can be proposed.
  SELECT DISTINCT i~gem_invoice_no                          "+019
    FROM zgem_bill AS i                                     "+019
    INNER JOIN ekko AS e                                    "+019
      ON i~order_id       EQ e~zgempo                       "+019
    INNER JOIN zgem_billdet AS d                            "+019
      ON d~gem_invoice_no EQ i~gem_invoice_no               "+019
    INTO TABLE @DATA(lt_gem)                                "+019
    WHERE e~ebeln    EQ @wa_zmm_ims-ebeln                   "+019
      AND e~bsart    IN @lr_bsart                           "+019
      AND e~procstat IN @lr_procst.                         "+019

  IF sy-subrc NE 0.                                         "+019
    RETURN.               " no GeM invoice for this PO      "+019
  ENDIF.                                                    "+019

  SORT lt_gem BY gem_invoice_no.                                    "+019
  DELETE ADJACENT DUPLICATES FROM lt_gem COMPARING gem_invoice_no.  "+019

  READ TABLE lt_gem INTO DATA(ls_gem) INDEX 1.              "+019
  IF sy-subrc EQ 0.                                         "+019
    wa_zmm_ims-gem_invoice_no = ls_gem-gem_invoice_no.      "+019
  ENDIF.                                                    "+019

* Inform the user when the proposal was not unambiguous
  IF lines( lt_gem ) GT 1.                                  "+019
    MESSAGE 'More than one GeM invoice exists for this PO - first one proposed'  "+019
            TYPE 'S'.                                       "+019
  ENDIF.                                                    "+019

ENDFORM.                    " get_gem_invoice_no            "+019


*&=====================================================================*
*& PART 2 : CREATE - fill the field when the PO is entered
*& Include MZMMIMSI01 - MODULE valid_input_200 (line 568)
*& Insert after the "+006 - End" line (line 641), before the "+010" block
*&=====================================================================*

*  *+006 - PO Created by with name
*    IF NOT wa_zmm_ims-ebeln IS INITIAL.
*      SELECT SINGLE ernam FROM ekko INTO g_ernam
*            WHERE ebeln = wa_zmm_ims-ebeln.
*      IF sy-subrc = 0.
*        PERFORM get_uname USING    g_ernam
*                          CHANGING g_poernam.
*      ENDIF.
*    ENDIF.
*  *+006 - End

*+019 - Start : propose the GeM Invoice No. of the PO - no F4 needed
   PERFORM get_gem_invoice_no.                              "+019
*+019 - End

*  *+010 - Validation with exiting IMS Tracking by comparing PO


*&=====================================================================*
*& PART 3 : CREATE - guarantee the value reaches the database
*& Include MZMMIMSF01 - FORM save_data_ims (line 1094)
*& Insert as the first statements of the FORM, before the MOVEs
*&=====================================================================*

*FORM save_data_ims.

*+019 - Start : make sure the GeM Invoice No. is on the record before MODIFY
   PERFORM get_gem_invoice_no.                              "+019
*+019 - End

*  MOVE sy-uname TO wa_zmm_ims-created_by.
*  MOVE g_tstamp TO wa_zmm_ims-timestamp.
*  ...
*  MODIFY zmm_ims FROM wa_zmm_ims.


*&=====================================================================*
*& PART 4 : CHANGE / DISPLAY - documents created before this correction
*& Include MZMMIMSF01 - FORM check_validation_150 (line 503)
*& Insert before the closing ENDIF of the FORM (line 613)
*&=====================================================================*

*    """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,
*    """""currency history  RD1K999364
*    """"""""""""""""""""""""""""""""

*+019 - Start : fill the field for records saved without a GeM Invoice No.
     PERFORM get_gem_invoice_no.                            "+019
*+019 - End

*  ENDIF.
*
*ENDFORM.                    " check_validation_150
