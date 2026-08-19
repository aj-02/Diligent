*--- MAIN PROGRAM: FZMM_TC_INCLUDECDC ---*
FORM CD_CALL_ZMM_TC.
  IF   ( UPD_ZMM_TMS NE SPACE )
    OR ( UPD_ICDTXT_ZMM_TC NE SPACE )
  .
    CALL FUNCTION 'ZMM_TC_WRITE_DOCUMENT' IN UPDATE TASK
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
          UPD_ICDTXT_ZMM_TC
                      = UPD_ICDTXT_ZMM_TC
        TABLES
          ICDTXT_ZMM_TC
                      = ICDTXT_ZMM_TC
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
