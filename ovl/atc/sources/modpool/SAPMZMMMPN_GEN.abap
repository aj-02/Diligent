*--- MAIN PROGRAM: SAPMZMMMPN_GEN ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMMPN_GEN                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date         Transport    USERID       Description
* 17/11/2008    RD1K960036   SAB_SUMODH
*
* Change in INCLUDE MZMMMPN_GENF01 .
* 05/12/2008    RD1K960611   SAB_PUNIT    Change in include
*                                         MZMMMPN_GENF01.
************************************************************************

INCLUDE MZMMMPN_GENTOP .
INCLUDE MZMMMPN_GENO01 .
INCLUDE MZMMMPN_GENI01 .
INCLUDE MZMMMPN_GENF01 .

*&---------------------------------------------------------------------*
*& Starting of Selection Screen                                        *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS p_newr RADIOBUTTON GROUP radi .
*PARAMETERS p_pend RADIOBUTTON GROUP radi .
PARAMETERS p_comp RADIOBUTTON GROUP radi .
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
SELECT-OPTIONS s_reqn FOR zmm_mpn-docno MATCHCODE OBJECT zmm_shlp_doknr.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
SELECT-OPTIONS s_date FOR sy-datum.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
SELECT-OPTIONS s_bukrs FOR zmm_mpn-bukrs.
SELECTION-SCREEN END OF BLOCK b4.
INITIALIZATION.

  SET TITLEBAR 'REP01'.

start-of-selection.

  IF p_newr = 'X'.
   g_req_type = 'N'.
   select * from zmm_mpn into corresponding fields of table
                               g_TC_REQUEST_itab
                                                  where docno in s_reqn
                                                  and ersda in s_date
                                                  and bukrs in s_bukrs
                                                  and sflag = 'N'.
  ELSEIF p_comp = 'X'.
  g_req_type = 'C'.
   select * from zmm_mpn into corresponding fields of table
                               g_TC_REQUEST_itab
                                                  where docno in s_reqn
                                                  and ersda in s_date
                                                  and bukrs in s_bukrs
                                                  and sflag = 'C'.
  ENDIF.
  IF NOT g_TC_REQUEST_itab[] IS INITIAL.
     SORT g_TC_REQUEST_itab.
     Delete adjacent duplicates from g_TC_REQUEST_itab.
  ENDIF.

  call screen '9000'.
