*&---------------------------------------------------------------------*
*& Table maintenance event 01 - Before saving the data in the database
*& Table   ZMM_PO_BUDGET
*& Form    ZMM_BUDGET_BEFORE_SAVE
*& WRICEF  050_BRD_FS - Budget control on indirect purchase
*& Author  Arnav Johri, 19.08.2026
*&
*& Enforces: everything may be entered when the record is created, but
*& once it exists only Additional Budget may be changed.
*&
*& Created through SE54 -> Environment -> Events -> new entry, event 01,
*& form routine ZMM_BUDGET_BEFORE_SAVE, then the coding icon on that row.
*&
*& sy-subrc <> 0 on return is what cancels the save. It is set BEFORE the
*& MESSAGE statement because a type E message returns to the screen
*& immediately and any statement after it would not run.
*&---------------------------------------------------------------------*
FORM zmm_budget_before_save.

  DATA: ls_new TYPE zmm_po_budget,
        ls_db  TYPE zmm_po_budget.

  LOOP AT total.

*   Only records the user actually created or changed
    CHECK <action> = 'N' OR <action> = 'U'.

    ls_new = <vim_total_struc>.

*   ------------------------------------------------------------------
*   Base budget is frozen once the record exists.
*   Only ADD_BUDGET may move afterwards.
*   ------------------------------------------------------------------
    IF <action> = 'U'.

      SELECT SINGLE * FROM zmm_po_budget INTO ls_db
        WHERE werks = ls_new-werks
          AND ekgrp = ls_new-ekgrp
          AND gjahr = ls_new-gjahr.

      IF sy-subrc = 0.
        IF ls_new-budget <> ls_db-budget
        OR ls_new-waers  <> ls_db-waers.
          sy-subrc = 4.
          MESSAGE e003(zmm_budget).
        ENDIF.
      ENDIF.

    ENDIF.

*   ------------------------------- basic validations ----------------
    IF ls_new-waers IS INITIAL.
      sy-subrc = 4.
      MESSAGE e005(zmm_budget).
    ENDIF.

    IF ls_new-budget <= 0.
      sy-subrc = 4.
      MESSAGE e006(zmm_budget).
    ENDIF.

    IF ls_new-add_budget < 0.
      sy-subrc = 4.
      MESSAGE e007(zmm_budget).
    ENDIF.

*   ------------------------------- audit stamps ---------------------
*   Table carries AENAM / AEDAT only, so both create and change stamp
*   the same two fields.
    ls_new-aenam = sy-uname.
    ls_new-aedat = sy-datum.

    <vim_total_struc> = ls_new.
    MODIFY total.

  ENDLOOP.

ENDFORM.
