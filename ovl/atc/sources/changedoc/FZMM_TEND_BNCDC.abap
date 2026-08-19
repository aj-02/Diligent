*--- MAIN PROGRAM: FZMM_TEND_BNCDC ---*
FORM CD_CALL_ZMM_TEND_BN.
  IF   ( UPD_ZMM_PUR_TENDER_D NE SPACE )
    OR ( UPD_ICDTXT_ZMM_TEND_BN NE SPACE )
  .
    CALL FUNCTION 'ZMM_TEND_BN_WRITE_DOCUMENT' IN UPDATE TASK
        EXPORTING
          OBJECTID                = OBJECTID
          TCODE                   = TCODE
          UTIME                   = UTIME
          UDATE                   = UDATE
          USERNAME                = USERNAME
          PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
          OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
          PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
          NO_CHANGE_POINTERS      = CDOC_NO_CHANGE_POINTERS
* workarea_old of ZMM_PUR_TENDER_D
          O_ZMM_PUR_TENDER_D
                      = *ZMM_PUR_TENDER_D
* workarea_new of ZMM_PUR_TENDER_D
          N_ZMM_PUR_TENDER_D
                      = ZMM_PUR_TENDER_D
* updateflag of ZMM_PUR_TENDER_D
          UPD_ZMM_PUR_TENDER_D
                      = UPD_ZMM_PUR_TENDER_D
          UPD_ICDTXT_ZMM_TEND_BN
                      = UPD_ICDTXT_ZMM_TEND_BN
        TABLES
          ICDTXT_ZMM_TEND_BN
                      = ICDTXT_ZMM_TEND_BN
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
