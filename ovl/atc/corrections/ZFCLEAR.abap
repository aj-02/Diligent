    REPORT zfclear  MESSAGE-ID fb LINE-SIZE 132.
    TABLES: bsis, bsas, bseg, bkpf, t001, bsik, bsak, bsid, bsad.
    DATA: expert.
    SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
      PARAMETERS: p_bukrs LIKE bseg-bukrs MEMORY ID buk,
                  p_belnr LIKE bseg-belnr MEMORY ID bln,
                  p_gjahr LIKE bseg-gjahr MEMORY ID gjr,
*                p_buzei LIKE bseg-buzei OBLIGATORY.
                  p_buzei LIKE bseg-buzei.
      SELECTION-SCREEN SKIP.
      PARAMETERS: p_augbl LIKE bseg-augbl,
                  p_augdt LIKE bseg-augdt.
      SELECTION-SCREEN SKIP.
    SELECTION-SCREEN END OF BLOCK 001.

    SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME.
      PARAMETERS: p_echtl AS CHECKBOX MODIF ID inc.
    SELECTION-SCREEN END OF BLOCK 002.

    START-OF-SELECTION.
*     * konsistente Ausgleichsinformation ?
      IF ( p_augbl IS INITIAL AND NOT p_augdt IS INITIAL ) OR


         ( NOT p_augbl IS INITIAL AND p_augdt IS INITIAL ).
        MESSAGE e000 WITH 'p_augbl and p_augdt must be both init or both set'.
      ENDIF.

*     * gibts den buchungskreis
      SELECT SINGLE * FROM  t001 WHERE  bukrs  = p_bukrs.
      IF sy-subrc <> 0.
        MESSAGE e000 WITH 'Companycode' p_bukrs 'does not exist'.
      ENDIF.

*     * gibts den Kopf zu der zu ändernden bseg-zeile
      SELECT SINGLE * FROM  bkpf
             WHERE  bukrs  = t001-bukrs
             AND    belnr  = p_belnr
             AND    gjahr  = p_gjahr.
      IF sy-subrc <> 0.
        MESSAGE e000 WITH p_bukrs p_belnr p_gjahr 'no header'.
      ENDIF.

*     * gibts die zu ändernde Belegzeile
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT SINGLE * FROM  bseg
             WHERE  bukrs  = bkpf-bukrs
             AND    belnr  = bkpf-belnr
             AND    gjahr  = bkpf-gjahr
             AND    buzei  = p_buzei.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF sy-subrc <> 0.
        MESSAGE e000 WITH p_belnr p_buzei 'no such line'.
      ENDIF.
*     * Koart 'M' kann nicht ausgeglichen werden
      IF bseg-koart = 'M' AND NOT p_augbl IS INITIAL.
        MESSAGE e000 WITH 'Material accounts cannot be cleared'.
      ENDIF.
*     * Keine OPVW der Zeile der Anlagenzeile ?
      IF bseg-koart = 'A' AND NOT p_augbl IS INITIAL AND NOT bseg-xhres = 'X'.
        MESSAGE e000 WITH 'Line item not OI managed, clearing not possible'.
      ENDIF.

*     * Keine OPVW der Zeile der Sachkontenzeile ?
      IF bseg-koart = 'S' AND NOT p_augbl IS INITIAL AND NOT bseg-xopvw = 'X'.
        MESSAGE e000 WITH 'Line item not OI managed, clearing not possible'.
      ENDIF.




**----------------------------------------------------------------------
*
*     *       ab hier ist die Belegselektion abgeschlossen
*     *
*
**----------------------------------------------------------------------
*

      WRITE: / bseg-bukrs COLOR COL_KEY,
               bseg-belnr COLOR COL_KEY,
               bseg-gjahr COLOR COL_KEY,
               bseg-buzei COLOR COL_KEY,
               bseg-bschl COLOR COL_NORMAL,
               bseg-koart COLOR COL_NORMAL,
               bseg-shkzg COLOR COL_NORMAL,
               bseg-dmbtr COLOR COL_NORMAL.  "#EC CI_FLDEXT_OK[2610650]
      WRITE :/3(13) 'before update' COLOR COL_NORMAL,
               bseg-augdt COLOR COL_POSITIVE,
               bseg-augbl COLOR COL_POSITIVE.
*-------------------------------------------------------------------- *
*     *          neue Ausgleichsinformation in bseg stellen.
*     *
*     *
*-------------------------------------------------------------------- *

      WRITE :/3(13) 'after update' COLOR COL_NORMAL,
               p_augdt COLOR COL_POSITIVE,
               p_augbl COLOR COL_POSITIVE.
      SKIP.
      IF p_echtl = 'X'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG-AUGBL/AUGDT/AUGCP (clearing fields) may be changed only by SAP standard programs.
*      Direct UPDATE bseg is not allowed in S/4HANA - universal journal ACDOCA must stay in sync.
*      Reset clearing via the standard posting interface (programmatic FBRA). Old code retained:
        DATA: lv_augbl_old TYPE bseg-augbl.
        lv_augbl_old = bseg-augbl.            " current clearing document (capture before reset)
*        PERFORM delete_old_index.          "<-- Löschen des Index
*        bseg-augdt = p_augdt.
*        bseg-augcp = p_augdt.
*        bseg-augbl = p_augbl.
*        PERFORM make_new_index.            "<-- Neu erezugen
*        UPDATE bseg.                       "<-- Bseg updaten
        IF lv_augbl_old IS NOT INITIAL.
          CALL FUNCTION 'POSTING_INTERFACE_START'
            EXPORTING i_client = sy-mandt i_function = 'C' i_mode = 'N'
                      i_update = 'S' i_user = sy-uname
            EXCEPTIONS OTHERS = 0.
          CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR'
            EXPORTING i_bukrs = bseg-bukrs i_augbl = lv_augbl_old
                      i_gjahr = bseg-gjahr i_tcode = 'FBRA'
            EXCEPTIONS OTHERS = 0.
          CALL FUNCTION 'POSTING_INTERFACE_END'
            EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
        ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
      ENDIF.
*-------------------------------------------------------------------- *
*     *                     Ende des Hauptprogramms
*     *
*     *
*-------------------------------------------------------------------- *
*
*     *
*-------------------------------------------------------------------- *
*     *                Neuerzeugen einer Indextabelle
*     *
*     *
*-------------------------------------------------------------------- *
      DEFINE make_any_new_index.

        MOVE-CORRESPONDING bkpf TO &1.
        MOVE-CORRESPONDING bseg TO &1.

        IF &2 CA 'R'.                      "<-- Abstimmkonto von DKA.
          &1-zuonr = bseg-hzuon.
        ENDIF.

        INSERT &1.
        WRITE:/3 'Insert' COLOR COL_NORMAL,
                 '&1' COLOR COL_NORMAL,
                 'sy-subrc =' COLOR COL_NORMAL NO-GAP,
                 sy-subrc COLOR COL_NORMAL NO-GAP.
      END-OF-DEFINITION.
*     *
*-------------------------------------------------------------------- *
*     *               Löschen in einer Indextabelle Hauptbuch
*     *
*     *
*-------------------------------------------------------------------- *

      DEFINE delete_any_old_index_nb.
        DELETE FROM  &1
        WHERE  bukrs  = bseg-bukrs
        AND    &2     = bseg-&2
        AND    umsks  = bseg-umsks
        AND    umskz  = bseg-umskz
        AND    augbl  = bseg-augbl
        AND    augdt  = bseg-augdt
        AND    zuonr  = bseg-zuonr
        AND    gjahr  = bseg-gjahr
        AND    belnr  = bseg-belnr
        AND    buzei  = bseg-buzei.
        WRITE :/3 'Delete' COLOR COL_NORMAL,
                  '&1' COLOR COL_NORMAL,
                  'sy-subrc =' COLOR COL_NORMAL NO-GAP,

                  sy-subrc COLOR COL_NORMAL,
                  'sy-dbcnt =' COLOR COL_NORMAL NO-GAP,
                  sy-dbcnt COLOR COL_NORMAL.
      END-OF-DEFINITION.

*     *
*-------------------------------------------------------------------- *
*     *               Löschen in einer Indextabelle Nebenbuch
*     *
*     *
*-------------------------------------------------------------------- *

      DEFINE delete_any_old_index_sako.
        DELETE FROM  &1
        WHERE  bukrs  = bseg-bukrs
        AND    hkont  = bseg-hkont
        AND    augdt  = bseg-augdt
        AND    augbl  = bseg-augbl
        AND    zuonr  = bseg-&2
        AND    gjahr  = bseg-gjahr
        AND    belnr  = bseg-belnr
        AND    buzei  = bseg-buzei.
        WRITE :/3 'Delete' COLOR COL_NORMAL,
                  '&1' COLOR COL_NORMAL,
                  'sy-subrc =' COLOR COL_NORMAL NO-GAP,
                   sy-subrc COLOR COL_NORMAL,
                  'sy-dbcnt =' COLOR COL_NORMAL NO-GAP,
                  sy-dbcnt COLOR COL_NORMAL.
      END-OF-DEFINITION.

**&---------------------------------------------------------------------
*
*     *&      Form  DELETE_OLD_INDEX
*
**&---------------------------------------------------------------------
*
    FORM delete_old_index.
      IF ( bseg-koart CA 'SM' AND bseg-xkres = 'X' ) OR
         ( bseg-koart CA 'DKA' AND bseg-xhres = 'X' ).
        IF Bseg-koart CA 'DKA'.
*          delete_any_old_index_sako bsis hzuon.
*          delete_any_old_index_sako bsas hzuon.
        ELSE.
*          delete_any_old_index_sako bsis zuonr.
*          delete_any_old_index_sako bsas zuonr.
        ENDIF.
      ENDIF.
      IF bseg-koart = 'D'.
*        delete_any_old_index_nb bsid kunnr.
*        delete_any_old_index_nb bsad kunnr.
      ENDIF.
      IF bseg-koart = 'K'.
*        delete_any_old_index_nb bsik lifnr.
*        delete_any_old_index_nb bsak lifnr.
      ENDIF.
    ENDFORM.                               " DELETE_OLD_INDEX


*&---------------------------------------------------------------------*
*     *&      Form  MAKE_NEW_INDEX

*&---------------------------------------------------------------------*

    FORM make_new_index.


      DATA: tabs(4) TYPE c,
            tabd(4) TYPE c,
            tabk(4) TYPE c.

      IF   ( bseg-koart CA 'DKA' AND bseg-xhres = 'X' ).
        IF bseg-augbl IS INITIAL.
*          make_any_new_index bsis 'R'.     "R = Abstimmkonto
        ELSE.
*          make_any_new_index bsas 'R'.     "R = Abstimmkonto
        ENDIF.
      ENDIF.

      IF ( bseg-koart CA 'SM' AND bseg-xkres = 'X' ).
        IF bseg-augbl IS INITIAL.
*          make_any_new_index bsis 'N'.     "N = Normal
        ELSE.
*          make_any_new_index bsas 'N'.     "N = Normal
        ENDIF.
      ENDIF.
      IF bseg-koart CA 'D'.
        IF bseg-augbl IS INITIAL.
*          make_any_new_index bsid 'N'.     "N = Normal
        ELSE.
*          make_any_new_index bsad 'N'.     "N = Normal
        ENDIF.
      ENDIF.

      IF bseg-koart = 'K'.
        IF bseg-augbl = space.
*          make_any_new_index bsik 'N'.     "N = Normal
        ELSE.
*          make_any_new_index bsak 'N'.     "N = Normal
        ENDIF.

      ENDIF.
    ENDFORM.                               " MAKE_NEW_INDEX

    AT SELECTION-SCREEN.
      IF sy-ucomm EQ 'XXPM'. expert = 'X'. ENDIF.

    AT SELECTION-SCREEN OUTPUT.
      CLEAR p_echtl.
      LOOP AT SCREEN.
        IF screen-group1 = 'INC'.
          IF expert = 'X'.
            screen-invisible = 0.
          ELSE.
            screen-invisible = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

*     *>>>> END OF INSERTION <<<<<<
