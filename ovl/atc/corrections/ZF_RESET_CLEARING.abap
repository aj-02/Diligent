REPORT zf_reset_clearing MESSAGE-ID fb LINE-SIZE 132.

TABLES: bseg, bkpf, t001, bsis, bsas, bsik, bsak, bsid, bsad.

TYPES: BEGIN OF ty_bseg,
          bukrs     LIKE bseg-bukrs,
          belnr     LIKE bseg-belnr,
          gjahr     LIKE bseg-gjahr,
          buzei     LIKE bseg-buzei,
          augbl     LIKE bseg-augbl,
          augdt     LIKE bseg-augdt,
          augbl_new LIKE bseg-augbl,
          augdt_new LIKE bseg-augdt,
          xarch     LIKE bsis-xarch,
          del_indx  TYPE char10,
          ins_indx  TYPE char10,
       END OF   ty_bseg.
DATA i_bseg TYPE ty_bseg OCCURS 0.
FIELD-SYMBOLS: <fs_bseg> TYPE ty_bseg.

TYPES: BEGIN OF ty_indx,
          indx    TYPE char4,
       END OF   ty_indx.
DATA w_indx TYPE ty_indx.
DATA t_del_indx TYPE ty_indx OCCURS 0.
DATA t_ins_indx TYPE ty_indx OCCURS 0.

DATA save_subrc LIKE sy-subrc.
DATA index_r TYPE i VALUE 0.
DATA index_u TYPE i VALUE 0.
DATA index_c TYPE i VALUE 0.


* User Selektion ----------------------------------------------------- *

PARAMETERS:      x_bukrs LIKE bseg-bukrs  MEMORY ID buk OBLIGATORY.
SELECT-OPTIONS:  x_belnr FOR bseg-belnr   MEMORY ID bln.
SELECT-OPTIONS:  x_gjahr FOR bseg-gjahr   MEMORY ID gjr.
SELECT-OPTIONS:  x_augbl FOR bseg-augbl   MEMORY ID abl.
SELECT-OPTIONS:  x_augdt FOR bseg-augdt   MEMORY ID adt.
PARAMETERS:      x_konto LIKE bseg-hkont  MEMORY ID kto OBLIGATORY.
PARAMETERS:      x_koart LIKE bseg-koart  MEMORY ID krt OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS:     update AS CHECKBOX.

* Initialization ----------------------------------------------------- *
INITIALIZATION.


* Start-of-Selection ------------------------------------------------- *
START-OF-SELECTION.


* Definition: Datenauswahl ------------------------------------------- *
  DEFINE select_clearing.
    select * from &1 into corresponding fields of table i_bseg
                                   where bukrs  = x_bukrs
                                     and belnr in x_belnr
                                     and gjahr in x_gjahr
                                     and    &2  = x_konto
                                     and augbl in x_augbl
                                     and augdt in x_augdt.

    describe table i_bseg lines index_r.
  END-OF-DEFINITION.


* -------------------------------------------------------------------- *
*                    Beginn des Hauptprogramms                         *
* -------------------------------------------------------------------- *
  SELECT SINGLE * FROM  t001 WHERE  bukrs  = x_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e000 WITH 'Company code' x_bukrs 'does not exist'.
  ENDIF.

  IF x_koart = 'D'.
    select_clearing bsad kunnr.  "#EC CI_FLDEXT_OK
  ENDIF.

  IF x_koart = 'K'.
    select_clearing bsak lifnr.  "#EC CI_FLDEXT_OK
  ENDIF.

  IF x_koart CA 'MSA'.
    select_clearing bsas hkont.  "#EC CI_FLDEXT_OK
  ENDIF.


  LOOP AT i_bseg ASSIGNING <fs_bseg>.
* Beleg archiviert ? ------------------------------------------------- *
    CHECK <fs_bseg>-xarch = space.

* Belegzeile selektieren --------------------------------------------- *
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT SINGLE * FROM  bseg
           WHERE  bukrs  = <fs_bseg>-bukrs
           AND    belnr  = <fs_bseg>-belnr
           AND    gjahr  = <fs_bseg>-gjahr
           AND    buzei  = <fs_bseg>-buzei.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

    save_subrc = sy-subrc.

    IF save_subrc <> 0.
      WRITE:/ 'No bseg for', <fs_bseg>-bukrs, <fs_bseg>-belnr,
                             <fs_bseg>-gjahr, <fs_bseg>-buzei.
      WRITE:/ 'Index data not changed'.
    ENDIF.

    CHECK save_subrc = 0.

* Update durchführen ------------------------------------------------- *
    IF update = 'X'.
      DATA save_bkpf LIKE bkpf.
      DATA lin TYPE i.
      REFRESH t_del_indx.
      REFRESH t_ins_indx.

* Alten Index löschen ------------------------------------------------ *
      PERFORM delete_old_index CHANGING save_bkpf t_del_indx.
      DESCRIBE TABLE t_del_indx LINES lin.
      CASE lin.
        WHEN 0.
*       no index data deleted
        WHEN 1.
          READ TABLE t_del_indx INDEX 1 INTO w_indx.
          WRITE w_indx TO <fs_bseg>-del_indx(5).
        WHEN 2.
          READ TABLE t_del_indx INDEX 1 INTO w_indx.
          WRITE w_indx TO <fs_bseg>-del_indx(5).
          READ TABLE t_del_indx INDEX 2 INTO w_indx.
          WRITE w_indx TO <fs_bseg>-del_indx+5(5).
        WHEN OTHERS.
          <fs_bseg>-del_indx = '??????????'.
      ENDCASE.

* BSEG korrigieren --------------------------------------------------- *
      CLEAR bseg-augbl.
      CLEAR bseg-augdt.
      CLEAR bseg-augcp.
      CLEAR <fs_bseg>-augbl_new.
      CLEAR <fs_bseg>-augdt_new.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG clearing reset via standard posting interface (programmatic FBRA); direct UPDATE not allowed.
*      UPDATE bseg SET augdt = <fs_bseg>-augdt_new
*                      augbl = <fs_bseg>-augbl_new
*                      augcp = '00000000'
*                  WHERE  bukrs  = <fs_bseg>-bukrs
*                    AND  belnr  = <fs_bseg>-belnr
*                    AND  gjahr  = <fs_bseg>-gjahr
*                    AND  buzei  = <fs_bseg>-buzei.
      IF <fs_bseg>-augbl IS NOT INITIAL.
        CALL FUNCTION 'POSTING_INTERFACE_START' EXPORTING i_client = sy-mandt i_function = 'C'
             i_mode = 'N' i_update = 'S' i_user = sy-uname EXCEPTIONS OTHERS = 0.
        CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR' EXPORTING i_bukrs = <fs_bseg>-bukrs
             i_augbl = <fs_bseg>-augbl i_gjahr = <fs_bseg>-gjahr i_tcode = 'FBRA' EXCEPTIONS OTHERS = 0.
        CALL FUNCTION 'POSTING_INTERFACE_END' EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
      ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

* Neuen Index erzeugen ----------------------------------------------- *
      PERFORM make_new_index USING save_bkpf t_ins_indx.
      DESCRIBE TABLE t_ins_indx LINES lin.
      CASE lin.
        WHEN 0.
*       no index data created
        WHEN 1.
          READ TABLE t_ins_indx INDEX 1 INTO w_indx.
          WRITE w_indx TO <fs_bseg>-ins_indx(5).
        WHEN 2.
          READ TABLE t_ins_indx INDEX 1 INTO w_indx.
          WRITE w_indx TO <fs_bseg>-ins_indx(5).
          READ TABLE t_ins_indx INDEX 2 INTO w_indx.
          WRITE w_indx TO <fs_bseg>-ins_indx+5(5).
        WHEN OTHERS.
          <fs_bseg>-ins_indx = '??????????'.
      ENDCASE.


      ADD 1 TO index_u.
      ADD 1 TO index_c.

      IF index_c >= 1000.
        COMMIT WORK.
        index_c = 0.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF index_c <> 0.
    COMMIT WORK.
  ENDIF.


* OUTPUT ------------------------------------------------------------- *
  PERFORM write_output.

* -------------------------------------------------------------------- *
*                     Ende des Hauptprogramms                          *
* -------------------------------------------------------------------- *



* ---------------------------------------------------------------------*
* Definition: Setup der internen Tabelle der Indizes 'tab_indx'
* ---------------------------------------------------------------------*
  DEFINE setup_tab_indx.
    if &2 = 0.
      &3 = &1.
    else.
      &3 = 'error'.
    endif.
    &2 = 0.
  END-OF-DEFINITION.


* ---------------------------------------------------------------------*
* Definition: Eintrag in einer Indextabelle löschen
* ---------------------------------------------------------------------*
  DEFINE delete_any_old_index.
    select * from  &1
          where  bukrs  = bseg-bukrs
          and    &2     = bseg-&2
          and    gjahr  = bseg-gjahr
          and    belnr  = bseg-belnr
          and    buzei  = bseg-buzei.

      move-corresponding &1 to &3.
      delete &1.
      if sy-subrc <> 0.
        add sy-subrc to &4.
      endif.
    endselect.
  END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  DELETE_OLD_INDEX
*&---------------------------------------------------------------------*
FORM delete_old_index CHANGING p_bkpf   LIKE bkpf
                               tab_indx LIKE t_del_indx[].

  DATA w_indx TYPE ty_indx VALUE space.
  DATA loc_subrc LIKE sy-subrc VALUE '0'.

  REFRESH tab_indx.

  IF bseg-koart = 'D'.
*    delete_any_old_index bsad kunnr p_bkpf loc_subrc.
    setup_tab_indx 'BSAD' loc_subrc w_indx.
    APPEND w_indx TO tab_indx.
  ENDIF.

  IF bseg-koart = 'K'.
*    delete_any_old_index bsak lifnr p_bkpf loc_subrc.
    setup_tab_indx 'BSAK' loc_subrc w_indx.
    APPEND w_indx TO tab_indx.
  ENDIF.

  IF ( bseg-koart CA 'SM'  AND bseg-xkres = 'X' ) OR
       ( bseg-koart CA 'DKA' AND bseg-xhres = 'X' ).
*    delete_any_old_index bsas hkont p_bkpf loc_subrc.
    setup_tab_indx 'BSAS' loc_subrc w_indx.
    APPEND w_indx TO tab_indx.
  ENDIF.

ENDFORM.                    " DELETE_OLD_INDEX


* -------------------------------------------------------------------- *
* Definition: Neuer Eintrag in einer Indextabelle
* ---------------------------------------------------------------------*
DEFINE make_any_new_index.
  move-corresponding &2 to &1.
  move-corresponding bseg to &1.

  if &3 = 'R'. "<-- Abstimmkonto von DKA.
    &1-zuonr = bseg-hzuon.
  endif.
  insert &1.
  if sy-subrc <> 0.
    add sy-subrc to &4.
  endif.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  MAKE_NEW_INDEX
*&---------------------------------------------------------------------*
FORM make_new_index USING p_bkpf   LIKE bkpf
                          tab_indx LIKE t_ins_indx[].
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

  DATA w_indx TYPE ty_indx VALUE space.
  DATA loc_subrc LIKE sy-subrc VALUE '0'.

  REFRESH tab_indx.

  IF bseg-koart = 'D'.
    IF bseg-augbl IS INITIAL.
*      make_any_new_index bsid p_bkpf 'A' loc_subrc.
      setup_tab_indx 'BSID' loc_subrc w_indx.
      APPEND w_indx TO tab_indx.
      IF bseg-xhres = 'X'.
*        make_any_new_index bsis p_bkpf 'R' loc_subrc.
        setup_tab_indx 'BSIS' loc_subrc w_indx.
        APPEND w_indx TO tab_indx.
      ENDIF.
    ELSE.
*      make_any_new_index bsad p_bkpf 'A' loc_subrc.
      setup_tab_indx 'BSAD' loc_subrc w_indx.
      APPEND w_indx TO tab_indx.
      IF bseg-xhres = 'X'.
*        make_any_new_index bsas p_bkpf 'R' loc_subrc.
        setup_tab_indx 'BSAS' loc_subrc w_indx.
        APPEND w_indx TO tab_indx.
      ENDIF.
    ENDIF.
  ENDIF.

  IF bseg-koart = 'K'.
    IF bseg-augbl IS INITIAL.
*      make_any_new_index bsik p_bkpf 'A' loc_subrc.
      setup_tab_indx 'BSIK' loc_subrc w_indx.
      APPEND w_indx TO tab_indx.
      IF bseg-xhres = 'X'.
*        make_any_new_index bsis p_bkpf 'R' loc_subrc.
        setup_tab_indx 'BSIS' loc_subrc w_indx.
        APPEND w_indx TO tab_indx.
      ENDIF.
    ELSE.
*      make_any_new_index bsak p_bkpf 'A' loc_subrc.
      setup_tab_indx 'BSAK' loc_subrc w_indx.
      APPEND w_indx TO tab_indx.
      IF bseg-xhres = 'X'.
*        make_any_new_index bsas p_bkpf 'R' loc_subrc.
        setup_tab_indx 'BSAS' loc_subrc w_indx.
        APPEND w_indx TO tab_indx.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ( bseg-koart CA 'SM' AND bseg-xkres = 'X' ).
    IF bseg-augbl IS INITIAL.
*      make_any_new_index bsis p_bkpf 'A' loc_subrc.
      setup_tab_indx 'BSIS' loc_subrc w_indx.
      APPEND w_indx TO tab_indx.
    ELSE.
*      make_any_new_index bsas p_bkpf 'A' loc_subrc.
      setup_tab_indx 'BSAS' loc_subrc w_indx.
      APPEND w_indx TO tab_indx.
    ENDIF.
  ENDIF.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
ENDFORM.                    " MAKE_NEW_INDEX


*&---------------------------------------------------------------------*
*&      Form WRITE_OUTPUT
*&---------------------------------------------------------------------*
FORM write_output.
  SKIP.

  FORMAT COLOR COL_HEADING.

  WRITE: /(5) 'BUKRS',  (5) 'GJAHR', (11) 'BELNR',      (5) 'BUZEI',
          (5) 'KOART', (11) 'ACCNT', (11) 'AUGDT_OLD', (11) 'AUGBL_OLD',
         (11) 'AUGDT_NEW', (11) 'AUGBL_NEW', (5) 'XARCH',
         (11) 'OLD_INDEX', (11) 'NEW_INDEX'.
  SKIP.

  FORMAT COLOR OFF.

  LOOP AT i_bseg ASSIGNING <fs_bseg>.
    WRITE: /(5) <fs_bseg>-bukrs,
            (5) <fs_bseg>-gjahr,
           (11) <fs_bseg>-belnr,
            (5) <fs_bseg>-buzei,
            (5) x_koart,
           (11) x_konto,
           (11) <fs_bseg>-augdt,
           (11) <fs_bseg>-augbl,
           (11) <fs_bseg>-augdt_new,
           (11) <fs_bseg>-augbl_new,
            (5) <fs_bseg>-xarch,
           (11) <fs_bseg>-del_indx,
           (11) <fs_bseg>-ins_indx.
  ENDLOOP.

  SKIP.
  FORMAT COLOR COL_KEY.
  WRITE : / index_r, 'Document lines found  '.
  WRITE : / index_u, 'Document lines updated'.
  FORMAT COLOR COL_NORMAL.

  SKIP.
ENDFORM.                    " WRITE_OUTPUT
