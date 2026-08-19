*&---------------------------------------------------------------------*
*& Class         ZCL_SD_SCHEME_UI
*& Package       ZSD_SCHEME
*& Description   Scheme (Pipes) - presentation helpers shared by the
*&               module pool SAPMZSD_SCHEME and the report programs.
*&               Field texts and the switchable value help for the
*&               generic selection-criteria grid.
*&
*& Created by    Arnav Johri
*&---------------------------------------------------------------------*
CLASS zcl_sd_scheme_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    "! Description of a selection field for the ALV description column.
    CLASS-METHODS get_field_text
      IMPORTING iv_fieldname   TYPE zde_schm_fld
      RETURNING VALUE(rv_text) TYPE char40.

    "! Value help for the LOW / HIGH columns. Which help is offered
    "! depends on the FIELDNAME of the row, so one grid serves all
    "! selection fields (A05, A06).
    CLASS-METHODS f4_for_field
      IMPORTING iv_fieldname    TYPE zde_schm_fld
                iv_vkorg        TYPE vkorg OPTIONAL
                iv_vtweg        TYPE vtweg OPTIONAL
                iv_spart        TYPE spart OPTIONAL
      RETURNING VALUE(rv_value) TYPE char40.

    CLASS-METHODS get_status_text
      IMPORTING iv_status      TYPE zde_schm_stat
      RETURNING VALUE(rv_text) TYPE char20.

    CLASS-METHODS get_setl_status_text
      IMPORTING iv_status      TYPE zde_setl_stat
      RETURNING VALUE(rv_text) TYPE char20.

  PRIVATE SECTION.

    CLASS-METHODS popup_from_table
      IMPORTING it_values       TYPE STANDARD TABLE
                iv_retfield     TYPE fieldname
      RETURNING VALUE(rv_value) TYPE char40.

ENDCLASS.


CLASS zcl_sd_scheme_ui IMPLEMENTATION.

*&---------------------------------------------------------------------*
  METHOD get_field_text.

    rv_text = SWITCH #( iv_fieldname
      WHEN 'MVGR1' THEN 'Material Group 1'
      WHEN 'MVGR2' THEN 'Material Group 2'
      WHEN 'MVGR3' THEN 'Material Group 3'
      WHEN 'MVGR4' THEN 'Material Group 4'
      WHEN 'MVGR5' THEN 'Material Group 5'
      WHEN 'REGIO' THEN 'State'
      WHEN 'KUNNR' THEN 'Customer'
      WHEN 'KVGR1' THEN 'Customer Group 1'
      WHEN 'KVGR2' THEN 'Customer Group 2'
      WHEN 'ZONE1' THEN 'Zone'                      "source field open, Q8
      WHEN 'ZONE2' THEN 'Sub-Zone'                  "source field open, Q8
      ELSE              '' ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD f4_for_field.

    CASE iv_fieldname.

      WHEN 'MVGR1'.
        SELECT mvgr1 AS value, bezei AS text FROM tvm1t
          INTO TABLE @DATA(lt_v1) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_v1 iv_retfield = 'VALUE' ).

      WHEN 'MVGR2'.
        SELECT mvgr2 AS value, bezei AS text FROM tvm2t
          INTO TABLE @DATA(lt_v2) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_v2 iv_retfield = 'VALUE' ).

      WHEN 'MVGR3'.
        SELECT mvgr3 AS value, bezei AS text FROM tvm3t
          INTO TABLE @DATA(lt_v3) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_v3 iv_retfield = 'VALUE' ).

      WHEN 'MVGR4'.
        SELECT mvgr4 AS value, bezei AS text FROM tvm4t
          INTO TABLE @DATA(lt_v4) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_v4 iv_retfield = 'VALUE' ).

      WHEN 'MVGR5'.
        SELECT mvgr5 AS value, bezei AS text FROM tvm5t
          INTO TABLE @DATA(lt_v5) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_v5 iv_retfield = 'VALUE' ).

      WHEN 'REGIO'.
        SELECT bland AS value, bezei AS text FROM t005u
          INTO TABLE @DATA(lt_rg) WHERE spras = @sy-langu AND land1 = 'IN'.
        rv_value = popup_from_table( it_values = lt_rg iv_retfield = 'VALUE' ).

      WHEN 'KUNNR'.
        SELECT v~kunnr AS value, k~name1 AS text
          FROM knvv AS v INNER JOIN kna1 AS k ON k~kunnr = v~kunnr
          INTO TABLE @DATA(lt_cu)
          WHERE v~vkorg = @iv_vkorg
            AND v~vtweg = @iv_vtweg
            AND v~spart = @iv_spart.
        rv_value = popup_from_table( it_values = lt_cu iv_retfield = 'VALUE' ).

      WHEN 'KVGR1'.
        SELECT kvgr1 AS value, bezei AS text FROM tvv1t
          INTO TABLE @DATA(lt_g1) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_g1 iv_retfield = 'VALUE' ).

      WHEN 'KVGR2'.
        SELECT kvgr2 AS value, bezei AS text FROM tvv2t
          INTO TABLE @DATA(lt_g2) WHERE spras = @sy-langu.
        rv_value = popup_from_table( it_values = lt_g2 iv_retfield = 'VALUE' ).

      WHEN 'ZONE1' OR 'ZONE2'.
        " No value help until the source fields are confirmed (Q8).
        " Add the SELECT here and nothing else in the application changes.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD popup_from_table.

    DATA lt_ret TYPE STANDARD TABLE OF ddshretval.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING  retfield        = iv_retfield
                 value_org       = 'S'
      TABLES     value_tab       = it_values
                 return_tab      = lt_ret
      EXCEPTIONS parameter_error = 1
                 no_values_found = 2
                 OTHERS          = 3.

    IF sy-subrc = 0.
      rv_value = VALUE #( lt_ret[ 1 ]-fieldval OPTIONAL ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD get_status_text.

    rv_text = SWITCH #( iv_status
      WHEN zcl_sd_scheme=>gc_status-new       THEN 'New'
      WHEN zcl_sd_scheme=>gc_status-released  THEN 'Released'
      WHEN zcl_sd_scheme=>gc_status-part_setl THEN 'Partially Settled'
      WHEN zcl_sd_scheme=>gc_status-closed    THEN 'Closed'
      ELSE '' ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD get_setl_status_text.

    rv_text = SWITCH #( iv_status
      WHEN 'O' THEN 'Open'
      WHEN 'P' THEN 'CN Request Posted'
      WHEN 'B' THEN 'Credit Memo Created'
      WHEN 'E' THEN 'Error'
      WHEN 'X' THEN 'Target Not Achieved'
      ELSE '' ).

  ENDMETHOD.

ENDCLASS.
