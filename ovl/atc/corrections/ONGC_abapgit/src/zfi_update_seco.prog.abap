REPORT zfi_update_seco .
*-----  PROGRAM FOR Updating section codes in  the wrong documents ****
***********************************************************************
* Program    :                                                        *
*                                                                     *
*                                                                     *
* Author     : S.R.Sudha                     Date : 8.11.2007
*
*                                                                     *
* Login Id   : CAB_SUDHA                                              *
*                                                                      *
* Description: ONE TIME EXERCISE FOR CHANGING SECCODE IN   A DOCUEMNT
*             CREATED FOR  passing the validation for section code
*             As per Mail from FI CORE Team .
*
*
*                                                                     *
*                                                                     *
***********************************************************************


TABLES : bsik.



DATA : ist_bsik LIKE bsik.
DATA : ist_bseg LIKE bseg.


PARAMETERS:  p_belnr  LIKE bsik-belnr,
             p_year   LIKE bsik-gjahr,
             p_bukrs LIKE bsik-bukrs ,
             p_lifnr LIKE bsik-lifnr ,
             p_buzei LIKE bsik-buzei,
             p_secco LIKE bsik-secco.

*------------------------------------------------------*
START-OF-SELECTION.
*------------------------------------------------------*
  SELECT SINGLE *   FROM bsik INTO  ist_bsik WHERE
               bukrs  =  p_bukrs
               AND lifnr  = p_lifnr
               AND gjahr = p_year
               AND belnr = p_belnr
               AND buzei =  p_buzei.

  ist_bsik-secco = p_secco.
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*  MODIFY  bsik FROM ist_bsik.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
  IF sy-subrc = 0.
    MESSAGE  i303(zfi).
  ENDIF.


*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT SINGLE *   FROM bseg INTO  ist_bseg WHERE
               bukrs  =  p_bukrs
               AND lifnr  = p_lifnr
               AND gjahr = p_year
               AND belnr = p_belnr
               AND buzei =  p_buzei.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  ist_bseg-secco = p_secco.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG SECCO via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*  MODIFY  bseg FROM ist_bseg.
  DATA: lt_acg TYPE STANDARD TABLE OF accchg, ls_acg TYPE accchg.
  REFRESH lt_acg. CLEAR ls_acg.
  ls_acg-fdname = 'SECCO'. ls_acg-newval = ist_bseg-secco.
  APPEND ls_acg TO lt_acg.
  CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = ist_bseg-bukrs i_belnr = ist_bseg-belnr
       i_gjahr = ist_bseg-gjahr i_buzei = ist_bseg-buzei TABLES t_acchg = lt_acg EXCEPTIONS OTHERS = 0.
  COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
  IF sy-subrc = 0.
    MESSAGE  i303(zfi).
  ENDIF.
