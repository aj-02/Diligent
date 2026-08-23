# ABAP rule audit

`scripts/abap-audit.py` over 51 file(s): **433 finding(s)** in 41 file(s).

| Count | Rule | From CLAUDE.md |
|---:|---|---|
| 238 | `SELECT_IN_LOOP` | no SELECT inside a LOOP where FOR ALL ENTRIES or a join would do |
| 101 | `SELECT_ENDSEL` | SELECT ... ENDSELECT — use an internal table |
| 40 | `FAE_NO_GUARD` | IS NOT INITIAL guard before every FOR ALL ENTRIES |
| 26 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY only on SELECT * |
| 10 | `CLAUSE_ORDER` | UP TO n ROWS / OFFSET come after INTO; INTO comes after ORDER BY |
| 9 | `INTO_BEFORE_FROM` | strict Open SQL: INTO is the last clause, never before FROM/WHERE |
| 7 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES needs a matching SORT outside any loop |
| 1 | `CLIENT_MANDT` | dropping CLIENT SPECIFIED means dropping mandt from the field list |
| 1 | `DUP_INLINE_DATA` | the same @DATA(name) declared twice in one unit — will not activate |

## ovl/atc/corrections/MZMMCODREQF01.abap

| Line | Rule | Detail |
|---:|---|---|
| 1412 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM IST_TEXTID_ITEMS with no SORT IST_TEXTID_ITEMS seen in INSERT_INTO_TAB |
| 1425 | `SELECT_IN_LOOP` | SELECT inside a loop in INSERT_INTO_TAB: SELECT SINGLE * INTO G_STXL FROM STXL WHERE TDOBJECT = WA_TEXTID-TDOBJECT AND TDID = WA_T… |
| 1964 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4560 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN WHERE REASON = 'E'. |
| 4566 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN WHERE REASON = 'N'. |
| 4708 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE NAME1 FROM LFA1 INTO L_MFGNAME WHERE LIFNR = G_TABLCTRL120_WA-MANU. |
| 4812 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN WHERE REASON = 'E'. |
| 4818 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN WHERE REASON = 'N'. |
| 4996 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT * FROM ZMM_CAP_GROUP INTO TABLE IT_CAP_GROUP1 WHERE DESCRIPTION = G_TABLCTRL130_WA… |
| 5104 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN WHERE REASON = 'E'. |
| 5110 | `SELECT_IN_LOOP` | SELECT inside a loop in CREATE_MATCODE: SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN WHERE REASON = 'N'. |
| 6239 | `SELECT_IN_LOOP` | SELECT inside a loop in MODI_CHECK: SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_TABCTRL110_WA-DESC1 AND DESC2 = G_TABCT… |
| 6446 | `SELECT_IN_LOOP` | SELECT inside a loop in INSERT_MDLNO: SELECT SINGLE MDLNO FROM ZMM_MDL INTO L_MDLNO WHERE MDLNO = G_TABLCTRL120_WA-MDLNO. |
| 7319 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7380 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7501 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7578 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7588 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7608 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7627 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 7672 | `SELECT_IN_LOOP` | SELECT inside a loop in CHECK_DUPL_REC1: SELECT REQNO SRNO DESC_FIN APPENDING CORRESPONDING FIELDS OF TABLE G_CDITEM_ITAB FROM ZMM… |
| 7672 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 7679 | `SELECT_IN_LOOP` | SELECT inside a loop in CHECK_DUPL_REC1: SELECT REQNO SRNO DESC_FIN APPENDING CORRESPONDING FIELDS OF TABLE G_CDITEM_ITAB FROM ZMM… |
| 7679 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 7715 | `SELECT_IN_LOOP` | SELECT inside a loop in CHECK_DUPL_REC1: SELECT REQNO SRNO DESC_FIN APPENDING CORRESPONDING FIELDS OF TABLE G_CDITEM_ITAB FROM ZMM… |
| 7726 | `SELECT_IN_LOOP` | SELECT inside a loop in CHECK_DUPL_REC1: SELECT REQNO SRNO DESC_FIN APPENDING CORRESPONDING FIELDS OF TABLE G_CDITEM_ITAB FROM ZMM… |
| 7767 | `SELECT_IN_LOOP` | SELECT inside a loop in CHECK_DUPL_REC1: SELECT REQNO SRNO DESC_FIN APPENDING CORRESPONDING FIELDS OF TABLE G_CDITEM_ITAB FROM ZMM… |
| 7773 | `SELECT_IN_LOOP` | SELECT inside a loop in CHECK_DUPL_REC1: SELECT REQNO SRNO DESC_FIN APPENDING CORRESPONDING FIELDS OF TABLE G_CDITEM_ITAB FROM ZMM… |

## ovl/atc/corrections/MZMMCODREQO01.abap

| Line | Rule | Detail |
|---:|---|---|
| 75 | `SELECT_IN_LOOP` | SELECT inside a loop in TABCTRL110_init: select single * from zmm_cdcodifier where codifier = sy-uname and matgp = g_tabctrl110_wa… |
| 283 | `SELECT_IN_LOOP` | SELECT inside a loop in TABLCTRL130_init: select single * from zmm_cdcodifier where codifier = sy-uname and matgp = g_tablctrl130_w… |
| 747 | `SELECT_IN_LOOP` | SELECT inside a loop in TABLCTRL140_init: Select single * into l_stxl from stxl where TDOBJECT = 'ZMMCD' and TDNAME = l_tdname and … |
| 840 | `SELECT_IN_LOOP` | SELECT inside a loop in TABLCTRL120_init: select single * from zmm_cdcodifier where codifier = sy-uname and matgp = g_tablctrl120_w… |
| 1381 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1810 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3073 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 3076 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3094 | `SELECT_IN_LOOP` | SELECT inside a loop in TABCTRL120_check: select single J_1KFTBUS from lfa1 into l_manuf_ty where lifnr = g_TABLCTRL120_wa-manu. |

## ovl/atc/corrections/MZMMCODREQ_ERROR_RESETF01.abap

| Line | Rule | Detail |
|---:|---|---|
| 772 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 775 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 779 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 782 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 789 | `SELECT_IN_LOOP` | SELECT inside a loop in select_mat_data: SELECT atwrt FROM ausp INTO wa_srchlp-atwrt UP TO 1 ROWS WHERE objek = wa_srchlp-matnr AN… |
| 789 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 792 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 798 | `SELECT_IN_LOOP` | SELECT inside a loop in select_mat_data: SELECT atwrt FROM ausp INTO wa_srchlp-mdlno UP TO 1 ROWS WHERE objek = wa_srchlp-matnr AN… |
| 798 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 801 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1323 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM IST_TEXTID_ITEMS with no SORT IST_TEXTID_ITEMS seen in Insert_into_tab |
| 1336 | `SELECT_IN_LOOP` | SELECT inside a loop in Insert_into_tab: SELECT SINGLE * INTO g_stxl FROM stxl WHERE tdobject = wa_textid-tdobject AND tdid = wa_t… |
| 1914 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4160 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn WHERE reason = 'E'. |
| 4166 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn WHERE reason = 'N'. |
| 4304 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE name1 FROM lfa1 INTO l_mfgname WHERE lifnr = g_TABLCTRL120_wa-manu. |
| 4400 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn WHERE reason = 'E'. |
| 4406 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn WHERE reason = 'N'. |
| 4572 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT * FROM zmm_cap_group INTO TABLE it_cap_group1 WHERE description = g_TABLCTRL130_wa… |
| 4648 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn WHERE reason = 'E'. |
| 4654 | `SELECT_IN_LOOP` | SELECT inside a loop in create_matcode: SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn WHERE reason = 'N'. |
| 5737 | `SELECT_IN_LOOP` | SELECT inside a loop in modi_check: SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_tabctrl110_wa-desc1 AND desc2 = g_tabct… |

## ovl/atc/corrections/MZMMVENDORF01.abap

| Line | Rule | Detail |
|---:|---|---|
| 547 | `CLIENT_MANDT` | mandt in the field list without CLIENT SPECIFIED |
| 570 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_LFA1 with no IS NOT INITIAL guard within 25 statements |
| 780 | `SELECT_IN_LOOP` | SELECT inside a loop in check_mandatory_fields: SELECT SINGLE brsch , udyog_aadhaar_no FROM zmm_vms_industry INTO @DATA(ls_vms) WHERE udy… |
| 1647 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 LIKE … |
| 1656 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt APPENDING CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 … |
| 1671 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 = wa_… |
| 1685 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 = wa_… |
| 1710 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 LIKE … |
| 1723 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT SINGLE reqcl FROM zmm_hvencrt INTO @DATA(v_reqst) WHERE reqno = @ist_vendor-reqno. |
| 1765 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 LIKE … |
| 1775 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt APPENDING CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 … |
| 1790 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 = wa_… |
| 1805 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 = wa_… |
| 1819 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 = wa_… |
| 1831 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT * FROM zmm_dvencrt INTO CORRESPONDING FIELDS OF TABLE ist_vendor WHERE name1 LIKE … |
| 1857 | `SELECT_IN_LOOP` | SELECT inside a loop in search_zmm_dvencrt: SELECT SINGLE reqcl FROM zmm_hvencrt INTO @DATA(v_reqsta) WHERE reqno = @ist_vendor-reqno. |
| 2568 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc: SELECT SINGLE * FROM setleaf INTO @DATA(wa_cc) WHERE setname = 'ZFI_BCM_PM_BUKRS' AND val… |
| 2704 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc: SELECT SINGLE * INTO wa_lfa1 FROM lfa1 WHERE lifnr = ist_vend-vend-lifnr. |
| 2784 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc: SELECT SINGLE * INTO wa_j_1imovend FROM lfa1 WHERE lifnr = ist_vend-vend-lifnr. |
| 3833 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE * FROM lfb1 WHERE lifnr = ist_extn-lifnr AND bukrs = zmm_hvenext-bukrs . |
| 3840 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE * FROM lfm1 WHERE lifnr = ist_extn-lifnr AND ekorg = ist_extn-ekorg . |
| 3848 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE * FROM lfa1 INTO ist_lfa1 WHERE lifnr = ist_extn-lifnr. |
| 3861 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE * FROM t001w WHERE werks = ist_extn-werks. |
| 3943 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE * FROM setleaf INTO @DATA(wa_cc) WHERE setname = 'ZFI_BCM_PM_BUKRS' AND val… |
| 3957 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE bankl FROM lfbk INTO l_bankl WHERE lifnr = ist_extn-lifnr. |
| 3986 | `SELECT_IN_LOOP` | SELECT inside a loop in run_bdc_ext: SELECT SINGLE bankl FROM lfbk INTO l_bankl WHERE lifnr = ist_extn-lifnr. |
| 4202 | `SELECT_IN_LOOP` | SELECT inside a loop in list_box: SELECT SINGLE name1 FROM t001w INTO g_value-text WHERE werks = ist_plant-werks. |
| 5849 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_LFA1 with no IS NOT INITIAL guard within 25 statements |
| 6582 | `SELECT_IN_LOOP` | SELECT inside a loop in call_xk02: SELECT SINGLE sperq FROM lfa1 INTO (ist_lfa1-sperq) WHERE lifnr = g_lifnr_rfq. |
| 8797 | `SELECT_IN_LOOP` | SELECT inside a loop in bdc_transaction: SELECT SINGLE * FROM t100 INTO wa_t100 WHERE sprsl = messtab-msgspra AND arbgb = messtab-… |
| 9113 | `SELECT_IN_LOOP` | SELECT inside a loop in check_bankl_bankn: SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE bankl = … |
| 9130 | `SELECT_IN_LOOP` | SELECT inside a loop in check_bankl_bankn: SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE ba… |
| 9979 | `SELECT_IN_LOOP` | SELECT inside a loop in update_email: SELECT SINGLE smtp_addr INTO l_email FROM adr6 WHERE addrnumber = v_addnr. |
| 10707 | `SELECT_IN_LOOP` | SELECT inside a loop in fetch_lifnr: SELECT SINGLE name1 FROM zmm_dvencrt INTO wa_zmm_vms_tp_set-name1 WHERE lifnr = wa_zmm_vm… |
| 10750 | `SELECT_IN_LOOP` | SELECT inside a loop in fetch_lifnr: SELECT SINGLE name1 FROM zmm_dvencrt INTO wa_zmm_vms_tp_set-name1 WHERE lifnr = wa_zmm_vm… |
| 10793 | `SELECT_IN_LOOP` | SELECT inside a loop in fetch_lifnr: SELECT SINGLE name1 FROM zmm_dvencrt INTO wa_zmm_vms_tp_set-name1 WHERE lifnr = wa_zmm_vm… |
| 11513 | `SELECT_IN_LOOP` | SELECT inside a loop in replicate_vendors_srm_cmm: SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF wa_lfa1_compare WHERE lifnr = ist_… |
| 11516 | `SELECT_IN_LOOP` | SELECT inside a loop in replicate_vendors_srm_cmm: SELECT SINGLE * FROM adr6 INTO CORRESPONDING FIELDS OF wa_adr6_compare WHERE addrnumber =… |
| 11642 | `SELECT_IN_LOOP` | SELECT inside a loop in replicate_vendors_srm_cmm: SELECT SINGLE * FROM adrc INTO CORRESPONDING FIELDS OF wa_adrc_comparetel WHERE addrnumbe… |
| 11913 | `SELECT_IN_LOOP` | SELECT inside a loop in check_bankl_bankn1: SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE bankl = … |
| 11930 | `SELECT_IN_LOOP` | SELECT inside a loop in check_bankl_bankn1: SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE ba… |
| 12030 | `CLAUSE_ORDER` | ORDER BY after INTO — INTO must follow ORDER BY |
| 12030 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |

## ovl/atc/corrections/MZMMVENDORI01.abap

| Line | Rule | Detail |
|---:|---|---|
| 1503 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM IST_EXTN with no SORT IST_EXTN seen in update_tc |
| 1526 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN VAL_LFA1 with no IS NOT INITIAL guard within 25 statements |
| 3195 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM G_TC319_ITAB with no SORT G_TC319_ITAB seen in user_command_0319 |
| 4075 | `SELECT_IN_LOOP` | SELECT inside a loop in user_command_0531: SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE bankl = … |
| 4101 | `SELECT_IN_LOOP` | SELECT inside a loop in user_command_0531: SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE ba… |
| 4212 | `SELECT_IN_LOOP` | SELECT inside a loop in user_command_0531: SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE bankl = … |
| 4234 | `SELECT_IN_LOOP` | SELECT inside a loop in user_command_0531: SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl WHERE ba… |
| 4278 | `SELECT_IN_LOOP` | SELECT inside a loop in user_command_0531: SELECT * FROM lfa1 INTO CORRESPONDING FIELDS OF TABLE ist_lfbk_lfa1 FOR ALL ENTRIES IN is… |
| 4278 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_ZFIVMSBANK_BANKL with no IS NOT INITIAL guard within 25 statements |
| 5675 | `SELECT_IN_LOOP` | SELECT inside a loop in fetch_data_bl_440: SELECT SINGLE * FROM lfa1 WHERE lifnr = wa_zmm_vend_block-lifnr. |
| 6476 | `SELECT_IN_LOOP` | SELECT inside a loop in call_bloc_xk02: SELECT SINGLE sperq FROM lfa1 INTO (ist_lfa1-sperq) WHERE lifnr = ist_bl-lifnr. |
| 8775 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM G_TC321_ITAB with no SORT G_TC321_ITAB seen in user_command_0321 |
| 9635 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT SINGLE but000~partner INTO @lv_bp FROM cvi_vend_link INNER JOI… |

## ovl/atc/corrections/MZMMVENDORO01.abap

| Line | Rule | Detail |
|---:|---|---|
| 2236 | `SELECT_IN_LOOP` | SELECT inside a loop in init_screen_410: SELECT SINGLE * FROM lfa1 WHERE lifnr = wa_zmm_vend_unblock-lifnr. |
| 3274 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3307 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/MZPSJVCCFCFORMS_GET_TOTALS_F01.abap

| Line | Rule | Detail |
|---:|---|---|
| 16 | `CLAUSE_ORDER` | ORDER BY after INTO — INTO must follow ORDER BY |
| 16 | `CLAUSE_ORDER` | UP TO n ROWS before INTO — it must come after INTO |
| 27 | `CLAUSE_ORDER` | ORDER BY after INTO — INTO must follow ORDER BY |
| 27 | `CLAUSE_ORDER` | UP TO n ROWS before INTO — it must come after INTO |
| 39 | `CLAUSE_ORDER` | ORDER BY after INTO — INTO must follow ORDER BY |
| 39 | `CLAUSE_ORDER` | UP TO n ROWS before INTO — it must come after INTO |
| 60 | `CLAUSE_ORDER` | ORDER BY after INTO — INTO must follow ORDER BY |
| 60 | `CLAUSE_ORDER` | UP TO n ROWS before INTO — it must come after INTO |

## ovl/atc/corrections/MZPZ9920_MED_INPATIENT_F01.abap

| Line | Rule | Detail |
|---:|---|---|
| 23 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 26 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 78 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_LIST_BOX: SELECT SINGLE stext FROM t591s INTO g_value-text WHERE sprsl = 'E' AND infty = '0021' AND… |
| 82 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_LIST_BOX: SELECT FAVOR FANAM FROM PA0021 INTO ( FNAME , LNAME ) UP TO 1 ROWS WHERE PERNR = P9920-PE… |
| 82 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 85 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 91 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_LIST_BOX: SELECT ENAME FROM PA0001 INTO (FNAME ) UP TO 1 ROWS WHERE PERNR = P9920-PERNR AND BEGDA <… |
| 91 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 94 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2184 | `SELECT_IN_LOOP` | SELECT inside a loop in GETDATA_IST_9920_PAY: select single * from ZHR_MED_VENDORS into l_vendors where lifnr = wa_9920_PAY1-zhospid an… |
| 2851 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: SELECT PERSK PERSG FROM PA0001 INTO ( L_PERSK , L_PERSG ) UP TO 1 ROWS WHERE PERNR = WA_9… |
| 2851 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 2854 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2947 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: select single * from PA0027 into WA_PA0027 where PERNR = WA_9920_PAY_SEL-PERNR and SUBTY … |
| 3025 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: SELECT * FROM CSKS INTO WA_CSKS UP TO 1 ROWS WHERE KOSTL = <FS_COST_CTR> AND DATAB =< SY-… |
| 3028 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3042 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: select single * from TKA3G into WA_TKA3G where BUKRS = L_BUK and GSBER = L_GSBER. |
| 3348 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: select single bukrs from ZFIHOSPBUKRSEXEM into WA_ZFIHOSPBUKRSEXEM-BUKRS where bukrs = wa… |
| 3361 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction wher… |
| 3379 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: select single * from zhrhospsanc_utl into wa_zhrhospsanc_utl_curr where bukrs = wa_zhrhos… |
| 3514 | `SELECT_IN_LOOP` | SELECT inside a loop in PAY_0605: select COUNT(*) FROM ZHRMED_EMP_RECOV into l_bvorg where CNTER = WA_9920_PAY_SEL1-CNTER. |
| 4549 | `SELECT_IN_LOOP` | SELECT inside a loop in GETDATA_IST_9920_STATUS: SELECT * FROM PA9919 INTO WA_9919 UP TO 1 ROWS WHERE PERNR = WA_9920_SUBMIT1-PERNR AND ZC… |
| 4552 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4555 | `SELECT_IN_LOOP` | SELECT inside a loop in GETDATA_IST_9920_STATUS: SELECT FAVOR FANAM FROM PA0021 INTO ( FNAME , LNAME ) UP TO 1 ROWS WHERE PERNR = WA_9919-… |
| 4555 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 4558 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4560 | `SELECT_IN_LOOP` | SELECT inside a loop in GETDATA_IST_9920_STATUS: SELECT ENAME FROM PA0001 INTO FNAME UP TO 1 ROWS WHERE PERNR = WA_9919-PERNR AND BEGDA <=… |
| 4560 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 4563 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4924 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 4927 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4947 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 4982 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 4985 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 5394 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 5397 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 6557 | `SELECT_IN_LOOP` | SELECT inside a loop in REVERSE_1005: select COUNT(*) FROM ZHRMED_EMP_RECOV into l_bvorg where CNTER = WA_9920_REV_SEL1-CNTER. |
| 6653 | `SELECT_IN_LOOP` | SELECT inside a loop in REVERSE_1005: SELECT PERSK PERSG FROM PA0001 INTO ( L_PERSK , L_PERSG ) UP TO 1 ROWS WHERE PERNR = WA_9… |
| 6653 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 6656 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 6817 | `SELECT_IN_LOOP` | SELECT inside a loop in REVERSE_1005: SELECT TaxSection AS secco FROM i_operationalacctgdocitem WHERE CompanyCode = @l_wa_9920_… |
| 6826 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 6843 | `SELECT_IN_LOOP` | SELECT inside a loop in REVERSE_1005: select single bukrs from ZFIHOSPBUKRSEXEM into WA_ZFIHOSPBUKRSEXEM-BUKRS where bukrs = WA… |
| 6857 | `SELECT_IN_LOOP` | SELECT inside a loop in REVERSE_1005: Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction wher… |
| 6872 | `SELECT_IN_LOOP` | SELECT inside a loop in REVERSE_1005: select single * from zhrhospsanc_utl into wa_zhrhospsanc_utl where BUKRS = L_BUKRS AND SE… |

## ovl/atc/corrections/MZPZ9920_MED_INPATIENT_I01.abap

| Line | Rule | Detail |
|---:|---|---|
| 180 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1285 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_IMS_T with no IS NOT INITIAL guard within 25 statements |
| 1441 | `SELECT_IN_LOOP` | SELECT inside a loop in LOV_G_WITHT: select SINGLE TEXT40 into WA_WITHT-TEXT40 from T059U where SPRAS = 'EN' and LAND1 = 'IN' … |
| 1501 | `SELECT_IN_LOOP` | SELECT inside a loop in LOV_G_WT_WITHCD: select SINGLE TEXT40 into WA_WT_WITHCD-TEXT40 from T059ZT where SPRAS = 'EN' and LAND1 = … |
| 2491 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 2494 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2556 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 2559 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZFI_BCM_REJREC.abap

| Line | Rule | Detail |
|---:|---|---|
| 1081 | `SELECT_IN_LOOP` | SELECT inside a loop in make_command: SELECT MAX( gjahr ) FROM fmioi INTO l_year_max WHERE refbn = wa_srcbsik_l-ebeln AND rfpos… |
| 1085 | `SELECT_IN_LOOP` | SELECT inside a loop in make_command: SELECT SINGLE bukrs budat FROM bkpf INTO (l_bukrs,l_budat) WHERE bukrs = wa_srcbsik_l-buk… |
| 1538 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs: SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcb… |
| 1731 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs_cust: SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcb… |
| 2638 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2671 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2712 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2940 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2950 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_docs: SELECT SINGLE * FROM zfi_c_b_blockpm1 INTO wa_zfi_c_b_blockpm1 WHERE zlsch = wa_srcbsik-z… |
| 2981 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2991 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_docs: SELECT SINGLE * FROM zfi_c_b_blockpm2 INTO wa_zfi_c_b_blockpm2 WHERE zlsch = wa_srcbsik-z… |
| 3169 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3180 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3245 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3273 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3291 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_CUST with no IS NOT INITIAL guard within 25 statements |
| 4067 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_liab_doc_credit_memo: SELECT SINGLE awkey FROM bkpf INTO t_awkey WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_… |
| 4079 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_liab_doc_credit_memo: SELECT SINGLE ebeln FROM rseg INTO t_ebeln WHERE belnr = t_belnr AND gjahr = t_gjahr. |
| 4086 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_liab_doc_credit_memo: SELECT SINGLE * FROM setleaf WHERE setclass = '0000' AND setname = 'PO_CR_MEMO' AND valfr… |
| 4093 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_liab_doc_credit_memo: SELECT * FROM ekbe INTO CORRESPONDING FIELDS OF TABLE ist_ekbe1 WHERE ebeln = t_ebeln AND… |
| 4106 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_liab_doc_credit_memo: SELECT * FROM bkpf INTO CORRESPONDING FIELDS OF TABLE ist_bkpf1 FOR ALL ENTRIES IN ist_ek… |
| 4118 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_liab_doc_credit_memo: SELECT * FROM bsik INTO CORRESPONDING FIELDS OF TABLE ist_bsik1 FOR ALL ENTRIES IN ist_bk… |

## ovl/atc/corrections/ZFI_CHNG_PYBLCK.abap

| Line | Rule | Detail |
|---:|---|---|
| 923 | `SELECT_IN_LOOP` | SELECT inside a loop in make_command: select * from ZFI_PAYREF_CC into CORRESPONDING FIELDS OF table ist_ZFI_PAYREF_CC where BU… |
| 1350 | `SELECT_IN_LOOP` | SELECT inside a loop in get_rel_docs: SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcb… |
| 1501 | `SELECT_IN_LOOP` | SELECT inside a loop in get_rel_docs_cust: SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcb… |

## ovl/atc/corrections/ZFI_CHNG_PYBLCKD.abap

| Line | Rule | Detail |
|---:|---|---|
| 980 | `SELECT_IN_LOOP` | SELECT inside a loop in get_rel_docs: select single * from bkpf into wa_bkpf where bukrs = wa_srcbsik-bukrs and belnr = wa_srcb… |
| 1129 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs_cust: select single * from bkpf into wa_bkpf where bukrs = wa_srcbsid-bukrs and belnr = wa_srcb… |

## ovl/atc/corrections/ZFI_CP_MAS_VEN_E0001.abap

| Line | Rule | Detail |
|---:|---|---|
| 87 | `SELECT_IN_LOOP` | SELECT inside a loop in rem_pay_block: select single * FROM zfi_bcm_payordr where lifnr = wa_bsik-lifnr and belnr = wa_bsik-beln… |
| 99 | `SELECT_IN_LOOP` | SELECT inside a loop in rem_pay_block: select single * from lfa1 where lifnr = wa_bsik-lifnr and sperr = 'X'. |
| 141 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_BSIKS with no IS NOT INITIAL guard within 25 statements |
| 483 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_BSIKS with no IS NOT INITIAL guard within 25 statements |
| 702 | `SELECT_IN_LOOP` | SELECT inside a loop in get_vendors: select single * from bsik where bukrs = p_bukrs and lifnr = ist_lifnr1-lifnr. |
| 769 | `SELECT_IN_LOOP` | SELECT inside a loop in PRE_POST_CHECKS: SELECT * FROM setleaf INTO CORRESPONDING FIELDS OF TABLE ist_setleaf WHERE setclass = g_s… |

## ovl/atc/corrections/ZFI_JV_TB.abap

| Line | Rule | Detail |
|---:|---|---|
| 595 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_JVT with no IS NOT INITIAL guard within 25 statements |
| 1995 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |

## ovl/atc/corrections/ZFI_REM_PYBLCK.abap

| Line | Rule | Detail |
|---:|---|---|
| 1031 | `SELECT_IN_LOOP` | SELECT inside a loop in make_command: select * from ZFI_PAYREF_CC into CORRESPONDING FIELDS OF table ist_ZFI_PAYREF_CC where BU… |
| 1152 | `SELECT_IN_LOOP` | SELECT inside a loop in make_command: SELECT MAX( gjahr ) FROM fmioi INTO l_year_max WHERE refbn = wa_srcbsik_l-ebeln AND rfpos… |
| 1156 | `SELECT_IN_LOOP` | SELECT inside a loop in make_command: select single bukrs budat from bkpf into (l_bukrs,l_budat) where bukrs = wa_srcbsik_l-buk… |
| 1642 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs: SELECT SINGLE * FROM ZFI_BCM_PAYORDR INTO CORRESPONDING FIELDS OF WA_ZFI_BCM_PAYORDR WHER… |
| 1668 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs: SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcb… |
| 1861 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs_cust: SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcb… |
| 2772 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2805 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 2846 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 3074 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 3084 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_docs: select single * from ZFI_C_B_BLOCKPM1 into WA_ZFI_C_B_BLOCKPM1 where ZLSCH = wa_srcbsik-z… |
| 3115 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSIK with no IS NOT INITIAL guard within 25 statements |
| 3125 | `SELECT_IN_LOOP` | SELECT inside a loop in validate_docs: select single * from ZFI_C_B_BLOCKPM2 into WA_ZFI_C_B_BLOCKPM2 where ZLSCH = wa_srcbsik-z… |
| 3303 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3314 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3391 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3419 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_SRCBSID with no IS NOT INITIAL guard within 25 statements |
| 3437 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN IST_CUST with no IS NOT INITIAL guard within 25 statements |
| 4213 | `SELECT_IN_LOOP` | SELECT inside a loop in VALIDATE_LIAB_DOC_CREDIT_MEMO: SELECT SINGLE AWKEY from BKPF into T_AWKEY where BUKRS = wa_srcbsik-BUKRS and BELNR = wa_… |
| 4225 | `SELECT_IN_LOOP` | SELECT inside a loop in VALIDATE_LIAB_DOC_CREDIT_MEMO: select single EBELN from RSEG into T_EBELN where BELNR = T_BELNR and GJAHR = T_GJAHR. |
| 4232 | `SELECT_IN_LOOP` | SELECT inside a loop in VALIDATE_LIAB_DOC_CREDIT_MEMO: select single * from SETLEAF where SETCLASS = '0000' and SETNAME = 'PO_CR_MEMO' and VALFR… |
| 4239 | `SELECT_IN_LOOP` | SELECT inside a loop in VALIDATE_LIAB_DOC_CREDIT_MEMO: select * from EKBE into CORRESPONDING FIELDS OF TABLE IST_EKBE1 where EBELN = T_EBELN and… |
| 4252 | `SELECT_IN_LOOP` | SELECT inside a loop in VALIDATE_LIAB_DOC_CREDIT_MEMO: select * from BKPF into CORRESPONDING FIELDS OF TABLE IST_BKPF1 FOR ALL ENTRIES IN IST_EK… |
| 4264 | `SELECT_IN_LOOP` | SELECT inside a loop in VALIDATE_LIAB_DOC_CREDIT_MEMO: select * from BSIK into CORRESPONDING FIELDS OF TABLE IST_BSIK1 FOR ALL ENTRIES IN IST_BK… |

## ovl/atc/corrections/ZFI_REP_BLOCK.abap

| Line | Rule | Detail |
|---:|---|---|
| 867 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs: select single * from bkpf into wa_bkpf where bukrs = wa_srcbsik-bukrs and belnr = wa_srcb… |
| 947 | `SELECT_IN_LOOP` | SELECT inside a loop in get_docs_cust: select single * from bkpf into wa_bkpf where bukrs = wa_srcbsid-bukrs and belnr = wa_srcb… |

## ovl/atc/corrections/ZFI_RFSEPA03.abap

| Line | Rule | Detail |
|---:|---|---|
| 382 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 393 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZFI_TAX_CAPEX_POSTING_E01.abap

| Line | Rule | Detail |
|---:|---|---|
| 24 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_2 with no IS NOT INITIAL guard within 25 statements |
| 24 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT racct INTO TABLE @DATA(lt_act) FROM jvto1 FOR ALL ENTRIES IN @… |

## ovl/atc/corrections/ZFI_TAX_CAPEX_POSTING_F01.abap

| Line | Rule | Detail |
|---:|---|---|
| 182 | `SELECT_IN_LOOP` | SELECT inside a loop in calculate_jv_amort: SELECT * FROM zfi_tax_sec42_2 INTO TABLE gt_gl_post_comm WHERE bukrs = p_bukrs. |
| 208 | `SELECT_IN_LOOP` | SELECT inside a loop in calculate_jv_amort: SELECT SINGLE GLAccount AS saknr FROM i_glaccountincompanycode WHERE CompanyCode = @p_buk… |
| 256 | `SELECT_IN_LOOP` | SELECT inside a loop in calculate_jv_amort: SELECT * FROM zfi_tax_sec42_3 INTO TABLE gt_gl_post_comm WHERE bukrs = p_bukrs. |
| 281 | `SELECT_IN_LOOP` | SELECT inside a loop in calculate_jv_amort: SELECT SINGLE GLAccount AS saknr FROM i_glaccountincompanycode WHERE CompanyCode = @p_buk… |
| 377 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT SUM( hslvt ) AS hslvt, SUM( hsl01 ) AS hsl01, SUM( hsl02 ) AS … |

## ovl/atc/corrections/ZFI_TAX_CREDIT_REPORT.abap

| Line | Rule | Detail |
|---:|---|---|
| 119 | `SELECT_IN_LOOP` | SELECT inside a loop in process_data: SELECT SUM( hsl ) FROM jvso1 INTO @DATA(lv_amnt) WHERE ryear = @year AND rbukrs = @c_code… |
| 141 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_DATA with no IS NOT INITIAL guard within 25 statements |
| 143 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_DATA with no IS NOT INITIAL guard within 25 statements |
| 252 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_RACCT with no IS NOT INITIAL guard within 25 statements |
| 515 | `SELECT_IN_LOOP` | SELECT inside a loop in process_data: SELECT SUM( exdiff ) FROM zfitax_dif INTO @DATA(lv_sum1). |
| 596 | `SELECT_IN_LOOP` | SELECT inside a loop in process_data: SELECT AccountingDocument AS belnr, FiscalYear AS gjahr, CompanyCode AS bukrs, Accounting… |
| 596 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_FAGL with no IS NOT INITIAL guard within 25 statements |
| 611 | `SELECT_IN_LOOP` | SELECT inside a loop in process_data: SELECT belnr, gjahr, bukrs, BUZEI INTO TABLE @DATA(lt_bseg_add) FROM bseg FOR ALL ENTRIES… |
| 611 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_FAGL with no IS NOT INITIAL guard within 25 statements |
| 611 | `CLAUSE_ORDER` | ORDER BY after INTO — INTO must follow ORDER BY |
| 611 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT belnr, gjahr, bukrs, BUZEI INTO TABLE @DATA(lt_bseg_add) FROM … |
| 611 | `DUP_INLINE_DATA` | @DATA(lt_bseg_add) already declared inline at line 596 in process_data |
| 611 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |

## ovl/atc/corrections/ZFI_TAX_POSTING_F01.abap

| Line | Rule | Detail |
|---:|---|---|
| 189 | `SELECT_IN_LOOP` | SELECT inside a loop in calculate_jv_amort: SELECT * FROM zfi_tax_sec42_2 INTO TABLE gt_gl_post_comm WHERE bukrs = p_bukrs. |
| 214 | `SELECT_IN_LOOP` | SELECT inside a loop in calculate_jv_amort: SELECT SINGLE GLAccount AS saknr FROM i_glaccountincompanycode WHERE CompanyCode = @p_buk… |
| 307 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT SUM( hslvt ) AS hslvt, SUM( hsl01 ) AS hsl01, SUM( hsl02 ) AS … |

## ovl/atc/corrections/ZFI_TAX_SEC42_AMORT_SCH_F01.abap

| Line | Rule | Detail |
|---:|---|---|
| 237 | `SELECT_IN_LOOP` | SELECT inside a loop in process_surrendered_venture: SELECT SINGLE GLAccount AS saknr FROM i_glaccountincompanycode WHERE CompanyCode = @p_buk… |
| 402 | `SELECT_IN_LOOP` | SELECT inside a loop in process_active_venture: SELECT SINGLE GLAccount AS saknr FROM i_glaccountincompanycode WHERE CompanyCode = @p_buk… |
| 677 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT sum( hslvt ) as hslvt, SUM( hsl01 ) AS hsl01, SUM( hsl02 ) AS … |

## ovl/atc/corrections/ZFI_UPDATE_KIDNO.abap

| Line | Rule | Detail |
|---:|---|---|
| 203 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZFI_VOUCHER_PRINT.abap

| Line | Rule | Detail |
|---:|---|---|
| 292 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT valfrom valto INTO (valfrom, valto) FROM setleaf WHERE setname… |
| 304 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 308 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT valfrom valto INTO (valfrom, valto) FROM setleaf WHERE setname… |
| 320 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 324 | `INTO_BEFORE_FROM` | strict Open SQL with INTO ahead of FROM — INTO must be the last clause: SELECT valfrom valto INTO (valfrom, valto) FROM setleaf WHERE setname… |
| 336 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 356 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 396 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT * INTO CORRESPONDING FIELDS OF TABLE it_with_item FROM with_item WHERE bukrs = hea… |
| 534 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT * FROM bseg WHERE bukrs = header-bukrs AND belnr = header-belnr AND gjahr = header… |
| 582 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE waers FROM bkpf INTO l_curr WHERE bukrs = bseg-bukrs AND belnr = bseg-belnr… |
| 615 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE name1 FROM lfa1 INTO l_name1 WHERE lifnr = bseg-empfb. |
| 625 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE ktokd INTO l_ktokd FROM kna1 WHERE kunnr = bseg-kunnr. |
| 637 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE valfrom INTO l_valfrom FROM setleaf WHERE setclass = '0000' AND setname = '… |
| 655 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE ccname FROM vcnum INTO inrec-name1 WHERE ccins = 'PPC' AND ccnum = l_ccnum. |
| 666 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 682 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE * FROM lfb1 WHERE lifnr = inrec-lifnr AND bukrs = inrec-bukrs. |
| 688 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT * FROM lfbk UP TO 1 ROWS WHERE lifnr = lfb1-lifnr AND banks = 'IN' ORDER BY PRIMAR… |
| 690 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 707 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE ktokk INTO l_ktokk FROM lfa1 WHERE lifnr = inrec-lifnr. |
| 718 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE zwels INTO l_zwels FROM lfb1 WHERE lifnr = inrec-lifnr AND bukrs = inrec-bu… |
| 737 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM IST_ZLSCH with no SORT IST_ZLSCH seen in START-OF-SELECTION |
| 742 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE text1 INTO l_aztxt FROM t042z WHERE land1 = 'IN' AND zlsch = ist_zlsch-zlsc… |
| 890 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1100 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT * FROM user_addr UP TO 1 ROWS WHERE bname = header-usnam ORDER BY PRIMARY KEY. |
| 1101 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1210 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT * FROM skat UP TO 1 ROWS WHERE saknr = hkont AND ktopl = 'ONGC' ORDER BY PRIMARY K… |
| 1212 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1224 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT SINGLE * FROM bseg WHERE bukrs = inrec-bukrs AND gjahr = inrec-gjahr AND belnr = i… |
| 1258 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT * FROM skat UP TO 1 ROWS WHERE saknr = hkont AND ktopl = 'ONGC' ORDER BY PRIMARY K… |
| 1260 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1270 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT SINGLE * FROM bseg WHERE bukrs = inrec-bukrs AND gjahr = inrec-gjahr AND belnr = i… |
| 1297 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT * FROM anla UP TO 1 ROWS WHERE anln1 = inrec-anln1 AND bukrs = tbukrs ORDER BY PRI… |
| 1298 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1311 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT * FROM skat UP TO 1 ROWS WHERE saknr = hkont AND ktopl = 'ONGC' ORDER BY PRIMARY K… |
| 1313 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1437 | `SELECT_IN_LOOP` | SELECT inside a loop in printcontrol: SELECT SINGLE * FROM t001 WHERE bukrs = header-bukrs. |
| 1715 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZF_CHECK_OI_BALANCE_EXT.abap

| Line | Rule | Detail |
|---:|---|---|
| 206 | `SELECT_IN_LOOP` | SELECT inside a loop in collect_s: SELECT * FROM bsis INTO wa_bsas WHERE bukrs EQ p_bukrs AND hkont EQ it_skb1-saknr AND bud… |
| 221 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 223 | `SELECT_IN_LOOP` | SELECT inside a loop in collect_s: SELECT * FROM bsas INTO wa_bsas WHERE bukrs EQ p_bukrs AND hkont EQ it_skb1-saknr AND aug… |
| 239 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 295 | `SELECT_IN_LOOP` | SELECT inside a loop in collect_s: SELECT SINGLE * FROM ska1 INTO wa_ska1 WHERE ktopl = wa_t001-ktopl AND saknr = it_coll-hk… |
| 340 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 357 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 399 | `SELECT_IN_LOOP` | SELECT inside a loop in collect_d: SELECT SINGLE * FROM ska1 INTO wa_ska1 WHERE ktopl = wa_t001-ktopl AND saknr = it_coll-hk… |
| 444 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 461 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 503 | `SELECT_IN_LOOP` | SELECT inside a loop in collect_k: SELECT SINGLE * FROM ska1 INTO wa_ska1 WHERE ktopl = wa_t001-ktopl AND saknr = it_coll-hk… |
| 1047 | `SELECT_IN_LOOP` | SELECT inside a loop in select_skb1: SELECT * FROM t074 INTO TABLE it_t074 WHERE ktopl = wa_t001-ktopl AND koart = 'D' AND sko… |
| 1086 | `SELECT_IN_LOOP` | SELECT inside a loop in select_skb1: SELECT * FROM t074 INTO TABLE it_t074 WHERE ktopl = wa_t001-ktopl AND koart = 'K' AND sko… |

## ovl/atc/corrections/ZF_CORR_PSWSL.abap

| Line | Rule | Detail |
|---:|---|---|
| 100 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 121 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT CompanyCode AS bukrs, AccountingDocument AS belnr, FiscalYear AS gjahr, Accounting… |
| 145 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZF_FILL_MISSING_AUGGJ_NGLM.abap

| Line | Rule | Detail |
|---:|---|---|
| 296 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN T_BUKRS with no IS NOT INITIAL guard within 25 statements |
| 378 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAS: SELECT * FROM BSAS APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAS WHERE BUKRS = IT_CLEAR… |
| 413 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAS: SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG WHERE BUKRS = IT_BSAS-BUKR… |
| 420 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAS: SELECT SINGLE * FROM BKPF INTO WA_BKPF WHERE BUKRS = IT_CLEARING_DOC_BSAS-BUKRS AND BELNR… |
| 475 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAS: SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG WHERE BUKRS = IT_BSAS-… |
| 736 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN T_BUKRS with no IS NOT INITIAL guard within 25 statements |
| 817 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAK: SELECT * FROM BSAK APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAK WHERE BUKRS = IT_CLEAR… |
| 849 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAK: SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG WHERE BUKRS = IT_BSAK-BUKR… |
| 856 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAK: SELECT SINGLE * FROM BKPF INTO WA_BKPF WHERE BUKRS = IT_CLEARING_DOC_BSAK-BUKRS AND BELNR… |
| 910 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAK: SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG WHERE BUKRS = IT_BSAK-… |
| 1074 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN T_BUKRS with no IS NOT INITIAL guard within 25 statements |
| 1155 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAD: SELECT * FROM BSAD APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAD WHERE BUKRS = IT_CLEAR… |
| 1187 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAD: SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG WHERE BUKRS = IT_BSAD-BUKR… |
| 1194 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAD: SELECT SINGLE * FROM BKPF INTO WA_BKPF WHERE BUKRS = IT_CLEARING_DOC_BSAD-BUKRS AND BELNR… |
| 1248 | `SELECT_IN_LOOP` | SELECT inside a loop in GET_DATA_BSAD: SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG WHERE BUKRS = IT_BSAD-… |

## ovl/atc/corrections/ZF_RESET_CLEARING.abap

| Line | Rule | Detail |
|---:|---|---|
| 95 | `SELECT_IN_LOOP` | SELECT inside a loop in START-OF-SELECTION: SELECT SINGLE * FROM bseg WHERE bukrs = <fs_bseg>-bukrs AND belnr = <fs_bseg>-belnr AND g… |
| 236 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZF_RESET_CLR.abap

| Line | Rule | Detail |
|---:|---|---|
| 416 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 469 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 494 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 541 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 549 | `SELECT_IN_LOOP` | SELECT inside a loop in select_bsas_skv: SELECT * FROM bsas INTO ls_bsas WHERE bukrs EQ p_bukrs AND hkont EQ lt_t030-konts AND aug… |
| 570 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 626 | `SELECT_IN_LOOP` | SELECT inside a loop in process_clearings: SELECT SINGLE * FROM (table) INTO CORRESPONDING FIELDS OF old_bseg WHERE bukrs EQ gt_inde… |
| 1694 | `SELECT_IN_LOOP` | SELECT inside a loop in get_bstat_a: SELECT SINGLE * FROM bkpf INTO ls_bkpf WHERE bukrs EQ gt_key-bukrs AND belnr EQ gt_key-au… |
| 1757 | `SELECT_IN_LOOP` | SELECT inside a loop in check_clr_doc: SELECT SINGLE * FROM bkpf INTO ls_bkpf WHERE bukrs EQ gt_key-bukrs AND belnr EQ gt_key-au… |
| 1826 | `SELECT_IN_LOOP` | SELECT inside a loop in check_clr_doc: SELECT COUNT( * ) FROM (table) INTO cnt_kdf WHERE bukrs EQ gt_key-bukrs AND belnr EQ gt_k… |
| 1864 | `SELECT_IN_LOOP` | SELECT inside a loop in check_clr_doc: SELECT SINGLE * FROM t041c INTO ls_t041c WHERE stgrd EQ p_stgrd. |
| 2252 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2647 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZJVC_LOG_REPORT.abap

| Line | Rule | Detail |
|---:|---|---|
| 75 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_BSEG with no IS NOT INITIAL guard within 25 statements |
| 102 | `SELECT_IN_LOOP` | SELECT inside a loop in process_data: SELECT SINGLE * FROM zjvc_approve INTO @DATA(app) WHERE doc_no EQ @ls_data-doc_no AND ei_… |
| 144 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN LT_FINAL with no IS NOT INITIAL guard within 25 statements |

## ovl/atc/corrections/ZJV_SAPF100.abap

| Line | Rule | Detail |
|---:|---|---|
| 1004 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1017 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1064 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1065 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1966 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1982 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1990 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2205 | `SELECT_IN_LOOP` | SELECT inside a loop in f100_bel_rfdt: SELECT * FROM bkpf WHERE bukrs = if100_bel-bukrs AND belnr = if100_bel-augbl ORDER BY PRI… |
| 2215 | `SELECT_IN_LOOP` | SELECT inside a loop in f100_bel_rfdt: SELECT ClearingJournalEntry AS augbl FROM i_operationalacctgdocitem WHERE CompanyCode = @… |
| 2226 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2231 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2252 | `SELECT_IN_LOOP` | SELECT inside a loop in f100_bel_rfdt: SELECT * FROM bkpf UP TO 1 ROWS WHERE bukrs = if100_bel-bukrs AND budat = if100_bel-budat… |
| 2759 | `SELECT_IN_LOOP` | SELECT inside a loop in bseg_update: SELECT SINGLE FOR UPDATE * FROM bseg WHERE bukrs = belege_upd-bukrs AND belnr = belege_up… |
| 3165 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3183 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3272 | `SELECT_IN_LOOP` | SELECT inside a loop in gr_ir_get_order: SELECT SINGLE awkey FROM bkpf INTO bkpf-awkey WHERE bukrs = belege-bukrs AND belnr = bele… |
| 3299 | `SELECT_IN_LOOP` | SELECT inside a loop in gr_ir_get_order: SELECT SINGLE * FROM t003 WHERE blart = belege-blart. |
| 3341 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3471 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3569 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3662 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 3715 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZPME_SFORM_REPORT.abap

| Line | Rule | Detail |
|---:|---|---|
| 213 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 217 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 229 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |
| 233 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZRCCWFL01.abap

| Line | Rule | Detail |
|---:|---|---|
| 65 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZRIWFWA01.abap

| Line | Rule | Detail |
|---:|---|---|
| 110 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 211 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 297 | `DAD_NO_SORT` | DELETE ADJACENT DUPLICATES FROM ZACTIVITY with no SORT ZACTIVITY seen in this unit |
| 416 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1364 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1478 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/ZR_JV_POST.abap

| Line | Rule | Detail |
|---:|---|---|
| 311 | `FAE_NO_GUARD` | FOR ALL ENTRIES IN GT_JV_MAP with no IS NOT INITIAL guard within 25 statements |

## ovl/atc/corrections/ZSD_INVOICE_VAPEXP_DP.abap

| Line | Rule | Detail |
|---:|---|---|
| 895 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1626 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM lipso2 WHERE vbeln = vbdkr-vbeln_vl AND msehi = 'KLN' AND posnr = vb… |
| 1766 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM lipso2 WHERE vbeln = vbdkr-vbeln_vl AND msehi = 'KLN' AND posnr = vb… |
| 1780 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 1799 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 1820 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 1848 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 1872 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 1895 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 1915 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kvewe = 'A' AND kappl = 'V' AND ksc… |
| 1929 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM vbrp WHERE vbeln = vbdkr-vbeln AND posnr = vbdpr-posnr. |
| 1937 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kvewe = 'A' AND kappl = 'V' AND ksc… |
| 1954 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = 'EN' AND kschl = tkomv-kschl AND kvewe = 'A' AND… |
| 1971 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kvewe = 'A' AND kappl = 'V' AND ksc… |
| 1988 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kvewe = 'A' AND kappl = 'V' AND ksc… |
| 2005 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = 'EN' AND kschl = tkomv-kschl AND kvewe = 'A' AND… |
| 2025 | `SELECT_IN_LOOP` | SELECT inside a loop in item_print: SELECT SINGLE * FROM t685t WHERE spras = sy-langu AND kschl = tkomv-kschl AND kvewe = 'A'… |
| 2343 | `SELECT_IN_LOOP` | SELECT inside a loop in get_data_italy: SELECT * FROM konh UP TO 1 ROWS WHERE knumh = tkomv-knumh ORDER BY PRIMARY KEY. |
| 2344 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 2349 | `SELECT_IN_LOOP` | SELECT inside a loop in get_data_italy: SELECT * FROM tlic UP TO 1 rows WHERE licno = konh-licno ORDER BY PRIMARY KEY. ENDSELECT. |

## ovl/atc/corrections/ZZRBUS2105.abap

| Line | Rule | Detail |
|---:|---|---|
| 259 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 883 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 1430 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/Z_CORR_PRCTR.abap

| Line | Rule | Detail |
|---:|---|---|
| 94 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM bkpf APPENDING TABLE it_bkpf1 WHERE bukrs = p_bukrs AND gjahr = p_year AND … |
| 101 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM bkpf APPENDING TABLE it_bkpf2 WHERE bukrs = p_bukrs AND gjahr = p_year AND … |
| 108 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM bkpf APPENDING TABLE it_bkpf3 WHERE bukrs = p_bukrs AND gjahr = p_year AND … |
| 156 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM t8a30 UP TO 1 ROWS WHERE kokrs = wa_bseg-kokrs AND konto_von <= wa_bseg-hko… |
| 371 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT gl_sirid INTO g_sirid FROM glpca UP TO 1 ROWS WHERE docnr = it_doc-docnr AND rbukr… |
| 371 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |

## ovl/atc/corrections/Z_CORR_PRCTR2.abap

| Line | Rule | Detail |
|---:|---|---|
| 62 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 86 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 115 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

## ovl/atc/corrections/Z_CORR_PRCTR_OVL.abap

| Line | Rule | Detail |
|---:|---|---|
| 94 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM bkpf APPENDING TABLE it_bkpf1 WHERE bukrs = p_bukrs AND gjahr = p_year AND … |
| 101 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM bkpf APPENDING TABLE it_bkpf2 WHERE bukrs = p_bukrs AND gjahr = p_year AND … |
| 108 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM bkpf APPENDING TABLE it_bkpf3 WHERE bukrs = p_bukrs AND gjahr = p_year AND … |
| 156 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT * FROM t8a30 UP TO 1 ROWS WHERE kokrs = wa_bseg-kokrs AND konto_von <= wa_bseg-hko… |
| 371 | `SELECT_IN_LOOP` | SELECT inside a loop in this unit: SELECT gl_sirid INTO g_sirid FROM glpca UP TO 1 ROWS WHERE docnr = it_doc-docnr AND rbukr… |
| 371 | `ORDER_PRIMARY` | ORDER BY PRIMARY KEY on a field list — only valid on SELECT * |

## ovl/atc/corrections/Z_REVERSE_CLEARING.abap

| Line | Rule | Detail |
|---:|---|---|
| 143 | `SELECT_IN_LOOP` | SELECT inside a loop in ap_reverse: select single * from bseg into wa_bseg where bukrs = i_bsak-bukrs and belnr = i_bsak-beln… |
| 152 | `SELECT_IN_LOOP` | SELECT inside a loop in ap_reverse: select single * from bsas into i_bsas where bukrs = wa_bseg-bukrs and hkont = wa_bseg-hko… |
| 248 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |
| 294 | `SELECT_IN_LOOP` | SELECT inside a loop in ar_reverse: select single * from bseg into wa_bseg where bukrs = i_bsad-bukrs and belnr = i_bsad-beln… |
| 303 | `SELECT_IN_LOOP` | SELECT inside a loop in ar_reverse: select single * from bsas into i_bsas where bukrs = wa_bseg-bukrs and hkont = wa_bseg-hko… |
| 402 | `SELECT_ENDSEL` | SELECT ... ENDSELECT loop |

