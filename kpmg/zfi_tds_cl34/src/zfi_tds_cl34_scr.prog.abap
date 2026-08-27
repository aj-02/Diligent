*&---------------------------------------------------------------------*
*& Report/Include : ZFI_TDS_CL34_SCR
*& Title          : TDS Report Clause 34 - selection screen
*& Project        : KPMG - UDAY / Astral          Module: FI
*& Related FS     : Clause 34 TDS Report FS.xlsx, v1, 21.08.2026
*& Author         : Arnav Johri                   Date: 26.08.2026
*& Transport      : <TR>
*&---------------------------------------------------------------------*
*& DESCRIPTION
*&   Selection screen for report ZFI_TDS_CL34. Declarations only - the
*&   default values are proposed in INIT_DEFAULTS and the plausibility
*&   checks run in VALIDATE_SELECTION, both in ZFI_TDS_CL34_FORMS.
*&
*& CHANGE HISTORY
*&   26.08.2026  Arnav Johri  <TR>  Initial development
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& The five fields of the FS "Input Screen" tab, in the FS's own order.
*&
*& Company code, fiscal year and posting date are the FS's mandatory
*& filter and are therefore OBLIGATORY; section code and vendor code are
*& optional narrowing filters. Company codes 1000 and 4000 are stated in
*& the FS as applicability, not as a filter, so nothing is defaulted or
*& hardcoded to them.
*&
*& Every SELECT-OPTIONS sits on the field it actually filters, not on a
*& convenient look-alike, so the length and the dictionary value help are
*& the correct ones:
*&   S_BUKRS  BKPF-BUKRS       - company code of the FI document header
*&   S_SECCO  BSEG-SECCO       - section code; it exists on the line item
*&                               only, neither BKPF nor WITH_ITEM has it
*&   S_LIFNR  WITH_ITEM-WT_ACCO- the account of the withholding tax item,
*&                               which is also output column C
*&   P_GJAHR  BKPF-GJAHR       - single value, per the FS input screen
*&   S_BUDAT  BKPF-BUDAT       - posting date From / To
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs OBLIGATORY,
                s_secco FOR bseg-secco,
                s_lifnr FOR with_item-wt_acco.

PARAMETERS:     p_gjahr TYPE bkpf-gjahr OBLIGATORY.

SELECT-OPTIONS: s_budat FOR bkpf-budat OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& MANUAL POST-CREATION STEPS
*&
*& This object ships by paste, so nothing below travels with the source -
*& neither the text pool nor the program attributes. Work through the
*& whole list after creating the program; the same list is the paste
*& sheet's checklist.
*&
*& 1. OBJECT CREATION
*&    ZFI_TDS_CL34                      executable program (type 1)
*&    ZFI_TDS_CL34_TOP                  INCLUDE (type I)
*&    ZFI_TDS_CL34_SCR                  INCLUDE (type I)
*&    ZFI_TDS_CL34_FORMS                INCLUDE (type I)
*&    The three includes must be created as type INCLUDE (I), NOT as
*&    executable programs, and ZFI_TDS_CL34_TOP must not carry a REPORT
*&    or PROGRAM statement of its own - the main program owns it.
*&
*& 2. Goto -> Attributes
*&    Title                    TDS Report - Clause 34 compliance
*&    Fixed point arithmetic   MUST be ticked. Every SELECT in this
*&                             program uses strict ABAP SQL
*&                             (comma-separated field lists, @ escaped
*&                             host variables), which the compiler only
*&                             accepts when this attribute is on. With
*&                             it off the first strict SELECT fails with
*&                             "This ABAP SQL statement uses additions
*&                             that can only be used when the fixed
*&                             point arithmetic flag is activated", and
*&                             the follow-on errors point at the inline
*&                             declared target ("Field LT_CC is
*&                             unknown") rather than at the attribute.
*&                             SE38 ticks it for a new program, but a
*&                             program created by copy or by a wizard
*&                             can arrive with it off.
*&
*& 3. Goto -> Text elements -> Selection texts
*&     S_BUKRS   Company Code
*&     S_SECCO   Section Code
*&     S_LIFNR   Vendor Code
*&     P_GJAHR   Fiscal Year
*&     S_BUDAT   Posting Date
*&
*&    Do not tick "Dictionary reference" on the selection texts - the
*&    dictionary labels for WT_ACCO and SECCO are not the words the FS
*&    asks for.
*&
*& 4. Goto -> Text elements -> Text symbols
*&     b01       Selection
*&
*& Until steps 3 and 4 are done the block frame is blank and the fields
*& show their technical names.
*&---------------------------------------------------------------------*
