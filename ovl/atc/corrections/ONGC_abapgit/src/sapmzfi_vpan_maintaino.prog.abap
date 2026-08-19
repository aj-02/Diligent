*&---------------------------------------------------------------------*
*&  Include           ZFI_UPDATE_j_1imovendO
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE tc931_init OUTPUT.

  IF  g_tc931_copied  IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'j_1imovend'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC931_itab'
    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

*    SELECT * FROM j_1imovend
*       INTO CORRESPONDING FIELDS
*       OF TABLE g_tc931_itab ORDER BY PRIMARY KEY.


    SELECT * FROM lfa1
       INTO CORRESPONDING FIELDS
       OF TABLE g_tc931_itab ORDER BY PRIMARY KEY.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF NOT  g_tc931_itab IS INITIAL.
      SELECT lifnr Name1 INTO  TABLE ist_lfa1  FROM lfa1
                   FOR ALL ENTRIES IN  g_tc931_itab
                    WHERE lifnr = g_tc931_itab-lifnr.
      LOOP AT g_tc931_itab INTO g_tc931_wa.
        READ TABLE ist_lfa1 INTO wa_lfa1 WITH KEY
                               lifnr = g_tc931_wa-lifnr.
        IF  sy-subrc = 0.
          g_tc931_wa-name1 = wa_lfa1-name1.
          MODIFY g_tc931_itab  FROM  g_tc931_wa TRANSPORTING
                    name1 .
        ENDIF.
      ENDLOOP.
    ENDIF.
    g_tc931_copied = 'X'.
    REFRESH CONTROL 'TC931' FROM SCREEN '0931'.
  ENDIF.
  "break cab_sudha.
  IF g_vflag = 'X'.
    CLEAR l_tabix.
    IF NOT g_lifnr IS INITIAL.
      READ TABLE g_tc931_itab INTO g_tc931_wa
         WITH KEY  lifnr = g_lifnr.
      IF sy-subrc = 0.
        l_tabix = sy-tabix.
      ENDIF.
    ELSEIF NOT  g_panno IS   INITIAL.
      READ TABLE g_tc931_itab INTO g_tc931_wa
     WITH KEY  j_1ipanno = g_panno.
      IF sy-subrc = 0.
        l_tabix = sy-tabix.
      ENDIF.
    ENDIF.
    tc931-top_line = l_tabix.
    SET CURSOR 1 1. " l_tabix.
    CLEAR g_vflag.
    CLEAR l_tabix.
  ENDIF.


ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE tc931_move OUTPUT.
*  MOVE-CORRESPONDING g_tc931_wa TO j_1imovend.
  MOVE-CORRESPONDING g_tc931_wa TO LFA1.
  lfa1-name1 = g_tc931_wa-name1.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC931'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc931_get_lines OUTPUT.
  g_tc931_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0931  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0931 OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  IF sy-uname+0(1) <> 'C'.
    APPEND 'DELE' TO fcode.
    SET PF-STATUS 'S931' EXCLUDING fcode.


*begin RD1K982287       CAB_ALOK     Remove changeTab from tcode ZJ1INVPAN - CR 30008047
*Begin RD1K984875     CAB_ALOK     Include new fields in tcode ZJ1INVPAN - CR 30009141
**'Change' enabled for end user again.
*   APPEND 'CHANGE' TO fcode.
*   SET PF-STATUS 'S931' EXCLUDING fcode.
*end RD1K984875     CAB_ALOK     Include new fields in tcode ZJ1INVPAN - CR 30009141
*end RD1K982287       CAB_ALOK     Remove changeTab from tcode ZJ1INVPAN - CR 30008047


  ELSE.
    SET PF-STATUS 'S931'.
  ENDIF.
  CASE g_okcode.
    WHEN 'CREATE' .
      g_text = 'Create New Entries'.
      SET TITLEBAR  'T931' WITH g_text .

    WHEN 'CHANGE' .
      g_text = 'Change Entries'.
      SET TITLEBAR  'T931' WITH g_text .

    WHEN 'DELE'.
      g_text = 'Delete the Selected Entries'.
      SET TITLEBAR  'T931' WITH g_text .


  ENDCASE.
ENDMODULE.                 " STATUS_0931  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_ATTRIBUTE_931  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_attribute_931 OUTPUT.



  DATA : lines TYPE i .
  lines = sy-loopc.
  "break cab_sudha.

  CASE g_okcode1.
    WHEN 'CREATE' OR 'INSR'.
      LOOP AT SCREEN.
        IF g_tc931_wa-flag = 'X'.
          IF tc931-top_line = 1.
            IF screen-group1 = 'KEY'.
              screen-input = 1.
*          screen-required = 1.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ELSE.
          IF screen-group2 = 'DIS'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    WHEN 'CHANGE'.
*     break cab_sudha.
*    LOOP AT tc931-cols INTO cols .
*     IF g_tc931_wa-flag = 'X' AND
*       g_cflag = 'X'.
*
*        IF  cols-SCREEN-NAME  = 'J_1IMOVEND-LIFNR'.
*               cols-SCREEN-INPUT = 0.
*       MODIFY tc931-cols FROM cols INDEX sy-tabix.
*       elseif cols-SCREEN-NAME  = 'J_1IMOVEND-J1IPANNO'.
*                   cols-SCREEN-INPUT = 1.
*       MODIFY tc931-cols FROM cols INDEX sy-tabix.
*        ENDIF.
*       clear g_cflag.
*     else.
*       if  cols-screen-group2 = 'DIS'.
*           cols-screen-input = 0.
*        endif.
*           MODIFY tc931-cols FROM cols INDEX sy-tabix.
*     endif.
*      ENDLOOP.

      LOOP AT SCREEN.
        IF g_tc931_wa-flag = 'X' AND
           g_cflag = 'X'.
          IF screen-group1 = 'KEY'.
            screen-input = 0.
            SCreen-active = 1.
            MODIFY SCREEN.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*          ELSEIF screen-name = 'J_1IMOVEND-J1IPANNO'.
          ELSEIF screen-name = 'LFA1-J1IPANNO'.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            screen-input = 1.
            SCreen-active = 1.
            MODIFY SCREEN.
          ENDIF.

        ELSEIF g_tc931_wa-flag <> 'X'."  or g_cflag <> 'X'.
          IF screen-group2 = 'DIS'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.
      ENDLOOP.
    WHEN ' ' OR 'ENTER'.
      LOOP AT SCREEN .
        IF screen-group2 = 'DIS'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
      LOOP AT SCREEN .
        IF screen-group1 = 'KEY'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.


  ENDCASE.


*Begin RD1K984875 CAB_ALOK Include new fields - CR 30009141
** for non core team users, make following fields display only, if some value is altready there.
*            J_1IMOVEND-J_1IPANNO
*          J_1IEXRN TYPE j_1imovend-J_1IEXRN,
*          J_1ICSTNO TYPE j_1imovend-J_1ICSTNO,
*          J_1ILSTNO TYPE j_1imovend-J_1ILSTNO,
*          J_1ISERN TYPE j_1imovend-J_1ISERN.

  IF sy-uname+0(1) <> 'C'.
    CASE g_okcode1.
      WHEN 'CHANGE'.

        LOOP AT SCREEN.

*******Start of change by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*          IF  screen-name = 'J_1IMOVEND-J_1IPANNO'.
          IF  screen-name = 'LFA1-J_1IPANNO'.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
*****End of change by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************


****Start of comment by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************

*     IF ( screen-name = 'J_1IMOVEND-J_1IPANNO'
*           and g_tc931_wa-J_1IPANNO is NOT INITIAL )
*       or


****End of comment by Anamika on 03.06.2015 for deactivation of PAN field for vendor RD1K997375************


*******Start of comment by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997
**          IF ( screen-name = 'J_1IMOVEND-J_1IEXRN')
**             and g_tc931_wa-J_1IEXRN is NOT INITIAL )
**         or
**          ( screen-name = 'J_1IMOVEND-J_1ICSTNO')
**             and g_tc931_wa-J_1ICSTNO is NOT INITIAL )
**         or
**          ( screen-name = 'J_1IMOVEND-J_1ILSTNO')
**             and g_tc931_wa-J_1ILSTNO is NOT INITIAL )
**         or
**          ( screen-name = 'J_1IMOVEND-J_1ISERN').
**             and g_tc931_wa-J_1ISERN is NOT INITIAL ).
**
**            screen-input = 0.
*******End of comment by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997


*******Start of change by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*          IF ( screen-name = 'J_1IMOVEND-J_1IEXRN')
          IF ( screen-name = 'LFA1-J_1IEXRN')
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        OR
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*         ( screen-name = 'J_1IMOVEND-J_1ICSTNO')
         ( screen-name = 'LFA1-J_1ICSTNO')
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        OR
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*         ( screen-name = 'J_1IMOVEND-J_1ILSTNO')
         ( screen-name = 'LFA1-J_1ILSTNO')
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        OR
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*         ( screen-name = 'J_1IMOVEND-J_1ISERN').
         ( screen-name = 'LFA1-J_1ISERN').
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

            screen-input = 1.
*******End of change by Anamika on 22.06.2015 for deactivation of PAN field for vendor RD1K997

          ENDIF.
          MODIFY SCREEN.

        ENDLOOP.



    ENDCASE.

  ENDIF.
*End RD1K984875 CAB_ALOK Include new fields - CR 30009141

ENDMODULE.                 " SCREEN_ATTRIBUTE_931  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0932  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0932 OUTPUT.
  g_text = 'Enter Vendor Number'.
  SET PF-STATUS 'S932'.
  SET TITLEBAR 'V932' WITH g_text.

ENDMODULE.                 " STATUS_0932  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr_status OUTPUT.
  LOOP AT SCREEN .
    IF screen-group1 = 'KEY'.
      screen-input = 0.
      screen-active = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " SCR_STATUS  OUTPUT
