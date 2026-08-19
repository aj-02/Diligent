*--- MAIN PROGRAM: FZMM_OLMCDC ---*
FORM CD_CALL_ZMM_OLM.
  IF   ( UPD_ZOL_MFST_H NE SPACE )
    OR ( UPD_ICDTXT_ZMM_OLM NE SPACE )
  .
    CALL FUNCTION 'SWE_REQUESTER_TO_UPDATE'.
    CALL FUNCTION 'ZMM_OLM_WRITE_DOCUMENT' IN UPDATE TASK
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
* workarea_old of ZOL_MFST_H
          O_ZOL_MFST_H
                      = *ZOL_MFST_H
* workarea_new of ZOL_MFST_H
          N_ZOL_MFST_H
                      = ZOL_MFST_H
* updateflag of ZOL_MFST_H
          UPD_ZOL_MFST_H
                      = UPD_ZOL_MFST_H
          UPD_ICDTXT_ZMM_OLM
                      = UPD_ICDTXT_ZMM_OLM
        TABLES
          ICDTXT_ZMM_OLM
                      = ICDTXT_ZMM_OLM
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
