*--- MAIN PROGRAM: FZPR_RCPT_DTCDC ---*
FORM CD_CALL_ZPR_RCPT_DT.
  IF   ( UPD_ZMM_TMS NE SPACE )
    OR ( UPD_ICDTXT_ZPR_RCPT_DT NE SPACE )
  .
    CALL FUNCTION 'ZPR_RCPT_DT_WRITE_DOCUMENT' IN UPDATE TASK
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
* workarea_old of ZMM_TMS
          O_ZMM_TMS
                      = *ZMM_TMS
* workarea_new of ZMM_TMS
          N_ZMM_TMS
                      = ZMM_TMS
* updateflag of ZMM_TMS
          UPD_ZMM_TMS
                      = UPD_ZMM_TMS
          UPD_ICDTXT_ZPR_RCPT_DT
                      = UPD_ICDTXT_ZPR_RCPT_DT
        TABLES
          ICDTXT_ZPR_RCPT_DT
                      = ICDTXT_ZPR_RCPT_DT
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
