# ZMM_PO_BUDGET — import and manual steps

Astral / UDAY / WRICEF **050_BRD_FS** — Budget control on indirect purchase.

---

## 1. What is in `ZMM_PO_BUDGET.zip`

Import via `ZABAPGIT_STANDALONE` → New Offline Repo → Import package from ZIP → Pull.

| File | Object | Type |
|---|---|---|
| `zdo_budget_amt.doma.xml` | `ZDO_BUDGET_AMT` | Domain CURR 15,2 |
| `zde_budget.dtel.xml` | `ZDE_BUDGET` | Data element |
| `zde_add_budget.dtel.xml` | `ZDE_ADD_BUDGET` | Data element |
| `zmm_po_budget.tabl.xml` | `ZMM_PO_BUDGET` | Transparent table, 11 fields |
| `zmm_budget.msag.xml` | `ZMM_BUDGET` | Message class, 10 messages |
| `zcl_mm_po_budget_check.clas.*` | `ZCL_MM_PO_BUDGET_CHECK` | Budget check logic |

**Before importing, confirm none of those names already exist** in the target system.

### Table `ZMM_PO_BUDGET`

| Key | Field | Type |
|:--:|---|---|
| ✔ | `MANDT` / `WERKS` / `EKGRP` / `GJAHR` | Client, Plant, Purchasing Group, Year |
| | `WAERS` | Currency — **not in the FS**, added because the FS compares an amount with no currency |
| | `BUDGET` | `ZDE_BUDGET` |
| | `ADD_BUDGET` | `ZDE_ADD_BUDGET` |
| | `ERNAM` `ERDAT` `AENAM` `AEDAT` | Created / changed audit |

`MAINFLAG = X` is set, so the table is ready for the maintenance generator.

---

## 2. Manual — Table Maintenance Generator

abapGit does not serialise a generated TMG, so this is done by hand once.

1. `SE11` → `ZMM_PO_BUDGET` → **Utilities → Table Maintenance Generator**
2. Authorization group: your MM group · Function group: `ZMM_PO_BUDGET`
3. Maintenance type: **one step** · Overview screen: `0001` · Recording routine: standard
4. **Create**
5. `SE93` → transaction **`ZMM_PO_BUDGET`** → parameter transaction on `SM30`, skip initial screen,
   `VIEWNAME = ZMM_PO_BUDGET`, `UPDATE = X`

### 2.1 The rule: everything editable on create, only Additional Budget afterwards

Two pieces. Do **both** — the event is the enforcement, the screen module is the UX.

#### (a) Event 01 — the enforcement (regeneration safe)

`SE54` → Edit → **Environment → Events** → New entry, event **01** (*Before saving the data
in the database*), form routine `ZMM_BUDGET_BEFORE_SAVE`. Click the editor icon and paste:

```abap
FORM zmm_budget_before_save.

  DATA: ls_new TYPE zmm_po_budget,
        ls_db  TYPE zmm_po_budget.

  LOOP AT total.

    ls_new = <vim_total_struc>.

    IF <action> = 'U'.

      SELECT SINGLE * FROM zmm_po_budget INTO ls_db
        WHERE werks = ls_new-werks
          AND ekgrp = ls_new-ekgrp
          AND gjahr = ls_new-gjahr.

      IF sy-subrc = 0
     AND ( ls_new-budget <> ls_db-budget OR ls_new-waers <> ls_db-waers ).
        MESSAGE e003(zmm_budget).
        sy-subrc = 4.
        EXIT.
      ENDIF.

    ENDIF.

    IF ls_new-add_budget < 0.
      MESSAGE e007(zmm_budget).
      sy-subrc = 4.
      EXIT.
    ENDIF.

    IF ls_new-budget <= 0.
      MESSAGE e006(zmm_budget).
      sy-subrc = 4.
      EXIT.
    ENDIF.

    IF ls_new-waers IS INITIAL.
      MESSAGE e005(zmm_budget).
      sy-subrc = 4.
      EXIT.
    ENDIF.

    " Audit stamps
    IF <action> = 'N'.
      <vim_total_struc>-ernam = sy-uname.
      <vim_total_struc>-erdat = sy-datum.
    ENDIF.
    <vim_total_struc>-aenam = sy-uname.
    <vim_total_struc>-aedat = sy-datum.
    MODIFY total FROM <vim_total_struc>.

  ENDLOOP.

ENDFORM.
```

This is the part that actually guarantees the rule. It survives regeneration of the TMG
and cannot be bypassed, because it runs on the database write.

#### (b) Screen module — greys the field out

This is cosmetic but is what the users will actually notice. `SE80` → function group
`ZMM_PO_BUDGET` → screen `0001` → **Flow logic**, add one line inside the existing loop:

```
PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL tctrl_zmm_po_budget CURSOR nextline.
    MODULE liste_show_liste.
    MODULE zmm_budget_modify_screen.      "<-- add this line
  ENDLOOP.
```

Then create the module in a Z include of the same function group:

```abap
MODULE zmm_budget_modify_screen OUTPUT.

  DATA lv_existing TYPE abap_bool.

  IF <action> <> 'N'.
    lv_existing = abap_true.
  ENDIF.

  LOOP AT SCREEN.

    CASE screen-name.

        "key and base budget: open only while the record is new
      WHEN 'ZMM_PO_BUDGET-WERKS'  OR 'ZMM_PO_BUDGET-EKGRP'
        OR 'ZMM_PO_BUDGET-GJAHR'  OR 'ZMM_PO_BUDGET-BUDGET'
        OR 'ZMM_PO_BUDGET-WAERS'.
        IF lv_existing = abap_true.
          screen-input = 0.
        ENDIF.

        "audit fields never editable
      WHEN 'ZMM_PO_BUDGET-ERNAM' OR 'ZMM_PO_BUDGET-ERDAT'
        OR 'ZMM_PO_BUDGET-AENAM' OR 'ZMM_PO_BUDGET-AEDAT'.
        screen-input = 0.

    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

ENDMODULE.
```

> **Note.** Point (b) is lost whenever the TMG is regenerated and must be re-added.
> Point (a) is not. That is why both exist — if you only did the greying, a regeneration
> would silently reopen the budget field for editing.
>
> The field symbols `<action>` and `<vim_total_struc>` are supplied by the maintenance
> framework. Check the exact names in the generated function group before activating.

---

## 3. Manual — BAdI implementation

`ME_PROCESS_PO_CUST` is a **classic** BAdI, so `SE19` generates the implementation class
itself. Nothing to import; only the body of one method is pasted.

1. `SE19` → **Classic BAdI** → `ME_PROCESS_PO_CUST` → Create Impl.
2. Implementation name `ZMM_PO_BUDGET`, class name accept the default.
3. Open method **`IF_EX_ME_PROCESS_PO_CUST~CHECK`** and paste:

```abap
METHOD if_ex_me_process_po_cust~check.

  DATA lt_item TYPE zcl_mm_po_budget_check=>tt_item.

  DATA(ls_head) = im_header->get_data( ).

  LOOP AT im_header->get_items( ) INTO DATA(ls_line).

    DATA(ls_data) = ls_line-item->get_data( ).

    APPEND VALUE #( ebelp = ls_data-ebelp
                    werks = ls_data-werks
                    knttp = ls_data-knttp
                    loekz = ls_data-loekz
                    effwr = ls_data-effwr ) TO lt_item.
  ENDLOOP.

  DATA(lt_msg) = zcl_mm_po_budget_check=>check_document(
                   iv_ebeln = ls_head-ebeln
                   iv_ekgrp = ls_head-ekgrp
                   iv_bedat = ls_head-bedat
                   iv_waers = ls_head-waers
                   it_item  = lt_item ).

  LOOP AT lt_msg INTO DATA(ls_msg) WHERE type = 'E'.

    mmpur_message_forced 'E' ls_msg-id ls_msg-number
                         ls_msg-message_v1 ls_msg-message_v2
                         ls_msg-message_v3 ls_msg-message_v4.

    ch_failed = abap_true.

  ENDLOOP.

ENDMETHOD.
```

4. Leave every other method empty. Activate the implementation.

`CHECK` is the correct method, not `POST` — `CHECK` is where `ch_failed = 'X'` actually
stops the save. `mmpur_message_forced` is the standard macro in the ME BAdIs and attaches
the message to the document properly.

---

## 4. Still open — needs a decision before this goes to test

| # | Question | Where it bites |
|---|---|---|
| 1 | **Scheduling agreements.** ME31L / ME32L do not run through `ME_PROCESS_PO_CUST`. A separate enhancement (`MM06E005`) is required, or the scope drops to POs only. | Half the FS scope |
| 2 | **No budget row exists** for plant / group / year — block or allow? Currently blocks (message 002). One statement to change. | First weeks after go-live |
| 3 | **Calendar or fiscal year** for `GJAHR`? Calendar assumed, taken from `EKKO-BEDAT`. | `get_consumed` |
| 4 | **Currency.** Budget currency vs PO currency — currently reported as an error, no conversion. | `check_document` |
| 5 | **Direct vs indirect.** The logic filters `KNTTP = K`, so stock POs are never checked, but the FS overview claims both direct and indirect are covered. | Scope |
| 6 | **Who may maintain?** No authorisation object is named in the FS. The TMG currently protects by auth group only. Needs `ZMM_BUDGET` auth object if Budget and Additional Budget must be separated by role. | Security design |
| 7 | **No visibility report.** Nothing lets a user see remaining budget before being blocked. Not in the FS — recommend adding. | User experience |

Items 1 and 5 are scope decisions. Items 2, 3, 4 are each a one-line change in
`ZCL_MM_PO_BUDGET_CHECK`, marked `OPEN POINT` in the source.

---

## 5. Sequence

1. Import the ZIP → activate the six objects
2. Generate the TMG, add the event 01 routine, add the screen module
3. Create the `SE93` transaction
4. Maintain one budget row for a test plant / purchasing group / year
5. Create the `SE19` implementation, paste the `CHECK` method, activate
6. Test in `ME21N`: within budget passes, over budget blocks
7. Test `ME22N` on an existing PO — this is the double-count case, and the value must not
   be counted twice
