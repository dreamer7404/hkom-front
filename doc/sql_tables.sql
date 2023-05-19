-- --------------------------------------------------------
-- 호스트:                          10.5.189.207
-- 서버 버전:                        10.6.11-MariaDB-log - MariaDB Server
-- 서버 OS:                        linux-systemd
-- HeidiSQL 버전:                  11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- hkomms 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `hkomms` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci */;
USE `hkomms`;

-- 테이블 hkomms.tb_able_adm_log_temp 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_able_adm_log_temp` (
  `WK_YMD` varchar(8) DEFAULT NULL,
  `IDX` char(2) DEFAULT NULL,
  `VALUE` int(9) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용하지 않아서 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_act_auth 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_act_auth` (
  `GRP_CD` varchar(3) NOT NULL COMMENT '그룹코드',
  `ACT_ID` varchar(50) NOT NULL COMMENT '액션아이디',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`GRP_CD`,`ACT_ID`),
  UNIQUE KEY `PK_TB_ACT_AUTH` (`GRP_CD`,`ACT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='액션권한';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_act_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_act_mgmt` (
  `ACT_SN` int(10) NOT NULL AUTO_INCREMENT COMMENT '액션일련번호',
  `ACT_ID` varchar(50) NOT NULL COMMENT '액션아이디',
  `MENU_ID` varchar(4) NOT NULL COMMENT '메뉴아이디',
  `ACT_NM` varchar(100) NOT NULL COMMENT '액션명',
  `ACT_TYPE` varchar(1) NOT NULL COMMENT '액션타입(C,U,D,F)',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`ACT_SN`),
  UNIQUE KEY `PK_TB_ACT_MGMT` (`ACT_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='액션관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_alc_mst_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_alc_mst_info` (
  `PRDN_MST_VEHL_CD` varchar(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `VIN` char(17) NOT NULL COMMENT '차대번호',
  `T10PS1_YMDHM` char(12) NOT NULL COMMENT '10번째공정시작년월일시분',
  `T11PS1_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정시작년월일시분',
  `FRAM_DTM` datetime DEFAULT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`VIN`),
  UNIQUE KEY `TB_ALC_MST_INFO_PK` (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`VIN`),
  KEY `TB_ALC_MST_INFO_IDX1` (`T10PS1_YMDHM`,`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`),
  KEY `TB_ALC_MST_INFO_IDX2` (`T11PS1_YMDHM`,`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='ALC마스터정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_altn_natl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_altn_natl_mgmt` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '취급설명서국가코드',
  `DYTM_PLN_NAT_CD` varchar(5) NOT NULL COMMENT '주간계획국가코드',
  `PRVS_SCN_CD` char(1) NOT NULL COMMENT '항목구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`DYTM_PLN_NAT_CD`,`PRVS_SCN_CD`),
  UNIQUE KEY `TB_ALTN_NATL_MGMT_PK` (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`DYTM_PLN_NAT_CD`,`PRVS_SCN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='연계국가코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_altn_vehl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_altn_vehl_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `PRDN_VEHL_CD` varchar(4) NOT NULL COMMENT '생산차종코드',
  `PRVS_SCN_CD` char(1) NOT NULL COMMENT '항목구분코드',
  `ET_YN` char(1) DEFAULT NULL COMMENT '전송여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`PRDN_VEHL_CD`,`PRVS_SCN_CD`),
  UNIQUE KEY `TB_ALTN_VEHL_MGMT_PK` (`QLTY_VEHL_CD`,`PRDN_VEHL_CD`,`PRVS_SCN_CD`),
  KEY `TB_ALTN_VEHL_MGMT_IDX1` (`PRDN_VEHL_CD`,`PRVS_SCN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='연계차종코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_altn_wiout_natl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_altn_wiout_natl_mgmt` (
  `DL_EXPD_CO_CD` varchar(2) NOT NULL COMMENT '회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '국가코드',
  `DYTM_PLN_NAT_CD` varchar(5) NOT NULL COMMENT '대리점코드',
  `PRVS_SCN_CD` varchar(1) NOT NULL COMMENT '항목구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`DYTM_PLN_NAT_CD`,`PRVS_SCN_CD`),
  UNIQUE KEY `PK_TB_ALTN_WIOUT_NATL_MGMT` (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`DYTM_PLN_NAT_CD`,`PRVS_SCN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='연계국가제외대리점관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_odr_acum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_odr_acum_info` (
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `ORD_QTY` int(16) NOT NULL COMMENT '주문수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime NOT NULL COMMENT '수정일시',
  PRIMARY KEY (`MO_PACK_CD`,`DATA_SN`,`APL_YMD`),
  UNIQUE KEY `TB_APS_ODR_ACUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`MO_PACK_CD`,`APL_YMD`),
  UNIQUE KEY `TB_APS_ODR_ACUM_INFO_PK` (`MO_PACK_CD`,`DATA_SN`,`APL_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS오더누적정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_odr_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_odr_info` (
  `PRDN_ORD_NO` varchar(15) NOT NULL COMMENT '생산주문번호',
  `DYTM_PLN_NAT_CD` varchar(5) NOT NULL COMMENT '주간계획국가코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `DYTM_PLN_VEHL_CD` varchar(4) NOT NULL COMMENT '주간계획차종코드',
  `USF_CD` varchar(2) NOT NULL COMMENT '용도코드',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `BASC_MDL_CD` varchar(12) DEFAULT NULL COMMENT '기본모델코드',
  `DEST_NAT_CD` varchar(5) NOT NULL COMMENT '목적지국가코드',
  `ORD_QTY` int(16) NOT NULL COMMENT '주문수량',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `PRDN_OCN_CD` varchar(4) DEFAULT NULL COMMENT '생산OCN코드',
  `VER_CD` varchar(3) DEFAULT NULL COMMENT '버전코드',
  `QLTY_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '모델년식코드',
  `DL_EXPD_NAT_CD` varchar(5) DEFAULT NULL COMMENT '취급설명서국가코드',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`PRDN_ORD_NO`,`DYTM_PLN_NAT_CD`,`PRDN_PLNT_CD`,`DYTM_PLN_VEHL_CD`,`USF_CD`,`MO_PACK_CD`,`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`),
  UNIQUE KEY `TB_APS_ODR_INFO_PK` (`PRDN_ORD_NO`,`DYTM_PLN_NAT_CD`,`PRDN_PLNT_CD`,`DYTM_PLN_VEHL_CD`,`USF_CD`,`MO_PACK_CD`,`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`),
  KEY `TB_APS_ODR_INFO_IDX1` (`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`),
  KEY `TB_APS_ODR_INFO_IDX2` (`DL_EXPD_CO_CD`,`QLTY_VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS오더정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_odr_noapim_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_odr_noapim_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(4) NOT NULL COMMENT '모델년식코드',
  `DYTM_PLN_NAT_CD` varchar(5) NOT NULL COMMENT '주간계획국가코드',
  `ORD_QTY` int(16) NOT NULL COMMENT '주문수량',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime NOT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DYTM_PLN_NAT_CD`,`MO_PACK_CD`),
  UNIQUE KEY `TB_APS_ODR_NOAPIM_INFO_PK` (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DYTM_PLN_NAT_CD`,`MO_PACK_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS오더미지정Summay정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_odr_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_odr_sum_info` (
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `ORD_QTY` int(16) NOT NULL COMMENT '주문수량',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `PRDN_QTY` int(10) NOT NULL COMMENT '생산수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_STRT_YMD`,`APL_FNH_YMD`,`MO_PACK_CD`,`DATA_SN`),
  UNIQUE KEY `TB_APS_ODR_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`MO_PACK_CD`),
  UNIQUE KEY `TB_APS_ODR_SUM_INFO_PK` (`APL_STRT_YMD`,`APL_FNH_YMD`,`MO_PACK_CD`,`DATA_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS오더Summay정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_plan_noapim_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_plan_noapim_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `PLN_PARR_YMD` char(8) NOT NULL COMMENT '계획예정년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(4) NOT NULL COMMENT '모델년식코드',
  `DYTM_PLN_NAT_CD` varchar(5) NOT NULL COMMENT '주간계획국가코드',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime NOT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DYTM_PLN_NAT_CD`,`PLN_PARR_YMD`),
  UNIQUE KEY `TB_APS_PLAN_NOAPIM_INFO_PK` (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DYTM_PLN_NAT_CD`,`PLN_PARR_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획미지정Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_prod_plan_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_prod_plan_info` (
  `PRDN_ORD_NO` varchar(15) NOT NULL COMMENT '생산주문번호',
  `DYTM_PLN_NAT_CD` varchar(5) NOT NULL COMMENT '주간계획국가코드',
  `PRDN_PLN_SCN_CD` char(1) NOT NULL COMMENT '생산계획구분코드',
  `APL_CRTN_CD` char(1) NOT NULL COMMENT '적용기준코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `DYTM_PLN_VEHL_CD` varchar(4) NOT NULL COMMENT '주간계획차종코드',
  `PLN_PARR_YMD` char(8) NOT NULL COMMENT '계획예정년월일',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `DEST_NAT_CD` varchar(5) NOT NULL COMMENT '목적지국가코드',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `DCSN_YN` char(1) NOT NULL COMMENT '확정여부',
  `DCSN_YMD` char(8) DEFAULT NULL COMMENT '확정년월일',
  `QLTY_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '모델년식코드',
  `DL_EXPD_NAT_CD` varchar(5) DEFAULT NULL COMMENT '취급설명서국가코드',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`PRDN_ORD_NO`,`DYTM_PLN_NAT_CD`,`PRDN_PLN_SCN_CD`,`APL_CRTN_CD`,`PRDN_PLNT_CD`,`DYTM_PLN_VEHL_CD`,`PLN_PARR_YMD`,`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`),
  UNIQUE KEY `TB_APS_PROD_PLAN_INFO_PK` (`PRDN_ORD_NO`,`DYTM_PLN_NAT_CD`,`PRDN_PLN_SCN_CD`,`APL_CRTN_CD`,`PRDN_PLNT_CD`,`DYTM_PLN_VEHL_CD`,`PLN_PARR_YMD`,`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`),
  KEY `TB_APS_PROD_PLAN_INFO_IDX1` (`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`),
  KEY `TB_APS_PROD_PLAN_INFO_IDX2` (`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DL_EXPD_NAT_CD`),
  KEY `TB_APS_PROD_PLAN_INFO_IDX3` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`PLN_PARR_YMD`,`DL_EXPD_NAT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_prod_plan_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_prod_plan_sum_info` (
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `PLN_PARR_YMD` char(8) NOT NULL COMMENT '계획예정년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `DCSN_YN` char(1) NOT NULL COMMENT '확정여부',
  `DCSN_YMD` char(8) DEFAULT NULL COMMENT '확정년월일',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_STRT_YMD`,`APL_FNH_YMD`,`PLN_PARR_YMD`,`DATA_SN`),
  UNIQUE KEY `TB_APS_PROD_PLAN_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`PLN_PARR_YMD`),
  UNIQUE KEY `TB_APS_PROD_PLAN_SUM_INFO_PK` (`APL_STRT_YMD`,`APL_FNH_YMD`,`PLN_PARR_YMD`,`DATA_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_prod_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_prod_sum_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `TMM_ORD_QTY` int(10) DEFAULT NULL COMMENT '금월주문수량',
  `BORD_QTY` int(10) DEFAULT NULL COMMENT '이전미생산주문수량',
  `TDD_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '금일생산계획수량 - 영업일3일기준',
  `WEK2_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '2주생산계획수량',
  `TMM_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '금월예상생산계획수량',
  `MTH3_MO_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3개월월평균투입수량',
  `TMM_TRWI_QTY` int(10) DEFAULT NULL COMMENT '금월투입수량',
  `BOD_TRWI_QTY` int(10) DEFAULT NULL COMMENT '전일투입수량',
  `TDD_PRDN_QTY` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량 - 0공정~투입직전공정',
  `YER1_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1년일평균투입수량',
  `MTH3_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3개월일평균투입수량',
  `WEK2_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '2주일평균투입수량',
  `AVP_TRWI_QTY` int(10) DEFAULT NULL COMMENT '선행생산수량',
  `TDD_PRDN_QTY2` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량2 - 8공정~투입직전공정',
  `TDD_PRDN_PLN_QTY2` int(10) DEFAULT NULL COMMENT '금일생산계획수량2 - 영업일5일기준',
  `TDD_PRDN_PLN_QTY3` int(10) DEFAULT NULL COMMENT '금일생산계획수량3 - 영업일2일기준',
  `TDD_PRDN_QTY3` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량3 - 9공정~투입직전공정',
  `WEK1_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1주일평균투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_APS_PROD_SUM_INFO_PK` (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`),
  KEY `TB_APS_PROD_SUM_INFO_IDX1` (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`),
  KEY `ID_TB_APS_PROD_SUM_INFO_01` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획및 생산마스터 Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_aps_prod_sum_info_temp 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_aps_prod_sum_info_temp` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `TMM_ORD_QTY` int(10) DEFAULT NULL COMMENT '금월주문수량',
  `BORD_QTY` int(10) DEFAULT NULL COMMENT '이전미생산주문수량',
  `TDD_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '금일생산계획수량 - 영업일3일기준',
  `WEK2_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '2주생산계획수량',
  `TMM_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '금월예상생산계획수량',
  `MTH3_MO_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3개월월평균투입수량',
  `TMM_TRWI_QTY` int(10) DEFAULT NULL COMMENT '금월투입수량',
  `BOD_TRWI_QTY` int(10) DEFAULT NULL COMMENT '전일투입수량',
  `TDD_PRDN_QTY` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량 - 0공정~투입직전공정',
  `YER1_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1년일평균투입수량',
  `MTH3_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3개월일평균투입수량',
  `WEK2_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '2주일평균투입수량',
  `AVP_TRWI_QTY` int(10) DEFAULT NULL COMMENT '선행생산수량',
  `TDD_PRDN_QTY2` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량2 - 8공정~투입직전공정',
  `TDD_PRDN_PLN_QTY2` int(10) DEFAULT NULL COMMENT '금일생산계획수량2 - 영업일5일기준',
  `TDD_PRDN_PLN_QTY3` int(10) DEFAULT NULL COMMENT '금일생산계획수량3 - 영업일2일기준',
  `TDD_PRDN_QTY3` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량3 - 9공정~투입직전공정',
  `WEK1_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1주일평균투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_APS_PROD_SUM_INFO_PK` (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`),
  KEY `TB_APS_PROD_SUM_INFO_IDX1` (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`),
  KEY `ID_TB_APS_PROD_SUM_INFO_01` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획및 생산마스터 Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_attc_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_attc_mgmt` (
  `ATTC_SN` int(16) NOT NULL AUTO_INCREMENT COMMENT '첨부일련번호',
  `ATTC_GBN` varchar(10) NOT NULL COMMENT '항목구분(0040)',
  `GBN_SN` varchar(30) NOT NULL COMMENT '항목의게시물정보',
  `FILE_TYPE` varchar(20) NOT NULL COMMENT '파일형식',
  `FILE_NM` varchar(400) NOT NULL COMMENT '파일명',
  `FILE_RE_NM` varchar(400) NOT NULL COMMENT '신규파일명',
  `FILE_PATH` varchar(400) NOT NULL COMMENT '파일경로',
  `FILE_SIZE` int(16) NOT NULL COMMENT '파일크기',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`ATTC_SN`),
  UNIQUE KEY `PK_TB_ATTC_MGMT` (`ATTC_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='첨부파일관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_auth_affr_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_auth_affr_mgmt` (
  `GRP_CD` varchar(3) NOT NULL COMMENT '그룹코드',
  `MENU_ID` varchar(10) NOT NULL COMMENT '메뉴ID',
  `MENU_AUTH_CD` varchar(1) NOT NULL COMMENT '메뉴권한코드',
  `USE_YN` varchar(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`GRP_CD`,`MENU_ID`),
  UNIQUE KEY `TB_AUTH_AFFR_MGMT_PK` (`GRP_CD`,`MENU_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='업무권한정보관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_auth_vehl 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_auth_vehl` (
  `USER_EENO` varchar(20) NOT NULL COMMENT '사용자사원번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `CL_SCN_CD` varchar(1) NOT NULL COMMENT '분류구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`USER_EENO`,`QLTY_VEHL_CD`,`DL_EXPD_CO_CD`),
  UNIQUE KEY `PK_TB_AUTH_VEHL` (`USER_EENO`,`QLTY_VEHL_CD`,`DL_EXPD_CO_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='권한차종';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_auth_vehl_0424back 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_auth_vehl_0424back` (
  `USER_EENO` varchar(20) NOT NULL COMMENT '사용자사원번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `CL_SCN_CD` varchar(1) NOT NULL COMMENT '분류구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`USER_EENO`,`QLTY_VEHL_CD`),
  UNIQUE KEY `PK_TB_AUTH_VEHL` (`USER_EENO`,`QLTY_VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='권한차종';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_auth_vehl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_auth_vehl_mgmt` (
  `USER_EENO` varchar(20) NOT NULL COMMENT '사용자사원번호',
  `MENU_ID` varchar(10) NOT NULL COMMENT '메뉴ID',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `CL_SCN_CD` char(1) NOT NULL COMMENT '분류구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`USER_EENO`,`MENU_ID`,`QLTY_VEHL_CD`,`CL_SCN_CD`),
  UNIQUE KEY `TB_AUTH_VEHL_MGMT_PK` (`USER_EENO`,`MENU_ID`,`QLTY_VEHL_CD`,`CL_SCN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='권한차종코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_batch_aps_et_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_batch_aps_et_info` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '회사구분코드',
  `BTCH_FNH_YMD` varchar(8) NOT NULL DEFAULT date_format(current_timestamp(),'%Y%m%d') COMMENT '전송완료일자(YYYYMMDD)',
  `ET_GUBN_CD` varchar(20) NOT NULL COMMENT '전송구분코드(전송테이블)',
  `FRAM_DTM` datetime NOT NULL DEFAULT current_timestamp() COMMENT '작성일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`BTCH_FNH_YMD`,`ET_GUBN_CD`) USING BTREE,
  UNIQUE KEY `TB_BATCH_ERP_ET_INFO_PK` (`DL_EXPD_CO_CD`,`BTCH_FNH_YMD`,`ET_GUBN_CD`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS 데이터전송완료정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_batch_erp_et_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_batch_erp_et_info` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '회사구분코드',
  `BTCH_FNH_YMD` char(8) NOT NULL DEFAULT date_format(current_timestamp(),'%Y%m%d') COMMENT '전송완료일자(YYYYMMDD)',
  `ET_GUBN_CD` char(2) NOT NULL COMMENT '전송구분코드(''01'':오후,''02'':명일오전)',
  `FRAM_DTM` datetime NOT NULL DEFAULT current_timestamp() COMMENT '작성일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`BTCH_FNH_YMD`,`ET_GUBN_CD`),
  UNIQUE KEY `TB_BATCH_ERP_ET_INFO_PK` (`DL_EXPD_CO_CD`,`BTCH_FNH_YMD`,`ET_GUBN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='ERP데이터전송완료정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_batch_exe_log 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_batch_exe_log` (
  `LOG_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '로그일련번호',
  `BTCH_NM` varchar(100) DEFAULT NULL COMMENT 'BATCH명',
  `BTCH_FNH_STRT_DTM` datetime DEFAULT NULL COMMENT 'BATCH취종시작일시',
  `BTCH_FNH_DTM` datetime DEFAULT NULL COMMENT 'BATCH종료일시',
  `BTCH_WK_CD` varchar(3) DEFAULT NULL COMMENT 'BATCH작업코드',
  `BTCH_WK_RSLT_SBC` varchar(400) DEFAULT NULL COMMENT 'BATCH작업결과내용',
  `AH_SCD_CD` varchar(4) DEFAULT NULL COMMENT '자동수동구분코드',
  PRIMARY KEY (`LOG_SN`),
  UNIQUE KEY `PK_TB_BATCH_EXE_LOG` (`LOG_SN`)
) ENGINE=InnoDB AUTO_INCREMENT=30006177 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배치실행로그';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_batch_fnh_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_batch_fnh_info` (
  `AFFR_SCN_CD` varchar(4) NOT NULL,
  `DL_EXPD_CO_CD` varchar(4) NOT NULL,
  `BTCH_FNH_YMD` char(8) NOT NULL,
  `FRAM_DTM` datetime NOT NULL,
  PRIMARY KEY (`AFFR_SCN_CD`,`DL_EXPD_CO_CD`,`BTCH_FNH_YMD`),
  UNIQUE KEY `TB_BATCH_FNH_INFO_PK` (`AFFR_SCN_CD`,`DL_EXPD_CO_CD`,`BTCH_FNH_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배치완료정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_batch_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_batch_info` (
  `BTCH_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT 'BATCH일련번호',
  `BTCH_NM` varchar(100) DEFAULT NULL COMMENT 'BATCH명',
  `BTCH_SBC` varchar(300) DEFAULT NULL COMMENT 'BATCH내용',
  `BTCH_EXE_TM` varchar(200) DEFAULT NULL COMMENT 'BATCH실행시간',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`BTCH_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배치정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_batch_rslt_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_batch_rslt_info` (
  `BTCH_NM` varchar(100) NOT NULL COMMENT 'BATCH명',
  `BTCH_FIN_STRT_DTM` datetime NOT NULL COMMENT 'BATCH최종시작일시',
  `BTCH_FNH_DTM` datetime NOT NULL COMMENT 'BATCH종료일시',
  `BTCH_WK_CD` varchar(3) NOT NULL COMMENT 'BATCH작업코드',
  `BTCH_WK_RSLT_SBC` varchar(4000) DEFAULT NULL COMMENT 'BATCH작업결과내용',
  PRIMARY KEY (`BTCH_NM`,`BTCH_FIN_STRT_DTM`,`BTCH_FNH_DTM`),
  UNIQUE KEY `TB_BATCH_RSLT_INFO_PK` (`BTCH_NM`,`BTCH_FIN_STRT_DTM`,`BTCH_FNH_DTM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='배치결과정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_board_affr_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_board_affr_mgmt` (
  `BLC_SN` int(14) NOT NULL COMMENT '업무게시물번호',
  `BLC_SCN_CD` varchar(2) NOT NULL COMMENT '게시물구분코드(0039)',
  `RGN_EENO` varchar(20) NOT NULL COMMENT '등록자사원번호',
  `BLC_RGST_YMD` varchar(8) NOT NULL COMMENT '게시물등록년월일',
  `BEFMY_TRWI_YN` char(1) DEFAULT NULL COMMENT '전MY투입가능여부',
  `BB_YN` char(1) DEFAULT NULL COMMENT '책등여부',
  `BB_VAL` varchar(30) DEFAULT NULL COMMENT '책등값',
  `DTRWI_YN` char(1) DEFAULT NULL COMMENT '분리투입여부',
  `DTRWI_RQ_YMD` varchar(8) DEFAULT NULL COMMENT '분리투입요청일',
  `DTRWI_MIDCSN_YN` char(1) DEFAULT NULL COMMENT '분리투입미확정여부',
  `ALTR_TRWI_YN` char(1) DEFAULT NULL COMMENT '교체투입여부',
  `NMTRWI_RQ_YMD` varchar(8) DEFAULT NULL COMMENT '신규매뉴얼투입요청일',
  `NMTRWI_MIDCSN_YN` char(1) DEFAULT NULL COMMENT '신규매뉴얼투입미확정여부',
  `BLC_TITL_NM` varchar(100) NOT NULL COMMENT '게시물제목명',
  `BLC_SBC` longtext NOT NULL COMMENT '게시물내용',
  `ATTC_YN` char(1) NOT NULL COMMENT '첨부여부',
  `REPLY_YN` char(1) NOT NULL COMMENT '댓글여부',
  `DEL_YN` char(1) NOT NULL COMMENT '삭제여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BLC_SN`),
  UNIQUE KEY `tb_affr_board_mast_PK` (`BLC_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='업무게시판관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_board_affr_reply 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_board_affr_reply` (
  `BLC_SN` int(14) NOT NULL COMMENT '게시물일련번호',
  `BLC_REPLY_SN` int(14) NOT NULL COMMENT '게시물댓글일련번호',
  `BLC_REPLY_SBC` longtext NOT NULL COMMENT '게시물댓글내용호',
  `DEL_YN` char(1) NOT NULL COMMENT '삭제여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BLC_SN`,`BLC_REPLY_SN`),
  UNIQUE KEY `tb_board_affr_reply_PK` (`BLC_SN`,`BLC_REPLY_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='업무게시판_댓글';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_board_affr_vehl 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_board_affr_vehl` (
  `BLC_SN` int(14) NOT NULL COMMENT '게시물일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`BLC_SN`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`),
  UNIQUE KEY `TB_AFFR_BOARD_VEHL_PK` (`BLC_SN`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='업무게시판차종';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_board_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_board_mgmt` (
  `BLC_SN` int(14) NOT NULL AUTO_INCREMENT COMMENT '게시물일련번호',
  `AFFR_SCN_CD` varchar(2) NOT NULL COMMENT '업무구분코드(0027)',
  `RGN_EENO` varchar(20) NOT NULL COMMENT '등록자사원번호',
  `BLC_RGST_YMD` varchar(8) NOT NULL COMMENT '게시물등록년월일',
  `BLC_TITL_NM` varchar(100) DEFAULT NULL COMMENT '게시물제목명',
  `BLC_SBC` longtext DEFAULT NULL COMMENT '게시물내용',
  `ATTC_YN` char(1) DEFAULT NULL COMMENT '첨부여부',
  `N1AFP2_ADR` varchar(200) DEFAULT NULL COMMENT '1차첨부파일경로주소',
  `BUL_STRT_YMD` varchar(8) DEFAULT NULL COMMENT '게시시작년월일',
  `BUL_FNH_YMD` varchar(8) DEFAULT NULL COMMENT '게시종료년월일',
  `BUL_YN` char(1) DEFAULT NULL COMMENT '게시여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BLC_SN`),
  UNIQUE KEY `TB_BOARD_MGMT_PK` (`BLC_SN`)
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='게시판관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_chklist_dtl_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_chklist_dtl_info` (
  `DL_EXPD_ALTR_NO` varchar(10) NOT NULL COMMENT '취급설명서변경번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) DEFAULT NULL COMMENT '신인쇄발간번호',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  `ET_YN` char(1) DEFAULT NULL,
  PRIMARY KEY (`DL_EXPD_ALTR_NO`,`QLTY_VEHL_CD`,`LANG_CD`),
  UNIQUE KEY `TB_CHKLIST_DTL_INFO_PK` (`DL_EXPD_ALTR_NO`,`QLTY_VEHL_CD`,`LANG_CD`),
  KEY `TB_CHKLIST_DTL_INFO_IDX1` (`QLTY_VEHL_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='체크리스트변경상세정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_chklist_dtl_info_if 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_chklist_dtl_info_if` (
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `DL_EXPD_ALTR_NO` varchar(10) NOT NULL COMMENT '취급설명서변경번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) DEFAULT NULL COMMENT '신인쇄발간번호',
  `IF_WK_RSLT_CD` char(1) DEFAULT NULL COMMENT 'I/F작업결과코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DTL_SN`),
  UNIQUE KEY `TB_CHKLIST_DTL_INFO_IF_PK` (`DTL_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='체크리스트변경상세정보_I/F';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_chklist_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_chklist_info` (
  `DL_EXPD_ALTR_NO` varchar(10) NOT NULL COMMENT '취급설명서변경번호',
  `ALTR_YMD` char(8) NOT NULL COMMENT '변경년월일',
  `RCPM_SHAP_CD` varchar(4) NOT NULL COMMENT '수신형태코드',
  `DSPP_NM` varchar(100) DEFAULT NULL COMMENT '발신처명',
  `CHGR_EENO` varchar(20) NOT NULL COMMENT '변경자사원번호',
  `CRGR_NM` varchar(100) DEFAULT NULL COMMENT '담당자명',
  `ALTR_SBC` longtext DEFAULT NULL COMMENT '변경내용',
  `DEL_YN` char(1) DEFAULT NULL COMMENT '삭제여부',
  `N1AFP2_ADR` varchar(200) DEFAULT NULL COMMENT '1차첨부파일경로주소',
  `N1AFP2_ADR1` varchar(200) DEFAULT NULL COMMENT '2차첨부파일경로주소',
  `ET_YN` char(1) DEFAULT NULL COMMENT '전송여부',
  `ATTC_YN` char(1) DEFAULT NULL COMMENT '첨부여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_ALTR_NO`),
  UNIQUE KEY `TB_CHKLIST_INFO_PK` (`DL_EXPD_ALTR_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='체크리스트변경정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_code_grp_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_code_grp_mgmt` (
  `DL_EXPD_G_CD` varchar(4) NOT NULL COMMENT '취급설명서그룹코드',
  `DL_EXPD_G_NM` varchar(200) DEFAULT NULL COMMENT '취급설명서그룹명',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_G_CD`),
  UNIQUE KEY `TB_CODE_GRP_MGMT_PK` (`DL_EXPD_G_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='코드그룹관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_code_lang_sb 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_code_lang_sb` (
  `LANG_SN` int(4) NOT NULL COMMENT '언어코드순번',
  `LAGN_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `LRNK_CD` varchar(2) NOT NULL COMMENT '발간번호순번',
  `SB_NM` varchar(2) NOT NULL COMMENT '심볼명',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`LANG_SN`,`LAGN_CD`,`LRNK_CD`,`SB_NM`),
  UNIQUE KEY `tb_code_lang_sb_PK` (`LANG_SN`,`LAGN_CD`,`LRNK_CD`,`SB_NM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='심볼언어코드';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_code_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_code_mgmt` (
  `DL_EXPD_G_CD` varchar(4) NOT NULL COMMENT '취급설명서그룹코드',
  `DL_EXPD_PRVS_CD` varchar(4) NOT NULL COMMENT '취급설명서항목코드',
  `DL_EXPD_PRVS_NM` varchar(200) DEFAULT NULL COMMENT '취급설명서항목명',
  `SORT_SN` int(4) NOT NULL COMMENT '정렬일련번호',
  `USE_YN` char(1) NOT NULL COMMENT '사용여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_G_CD`,`DL_EXPD_PRVS_CD`),
  UNIQUE KEY `TB_CODE_MGMT_PK` (`DL_EXPD_G_CD`,`DL_EXPD_PRVS_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_debug_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_debug_info` (
  `DEBUG_ID` int(14) NOT NULL AUTO_INCREMENT COMMENT '디버그ID',
  `DEBUG_TITL` varchar(8000) DEFAULT NULL COMMENT '디버그제목',
  `DEBUG_DATE` datetime DEFAULT NULL COMMENT '디버그일시',
  `WK_STAT` varchar(100) DEFAULT NULL COMMENT '작업상태',
  `ERR_SBC` varchar(4000) DEFAULT NULL COMMENT '오류내용',
  `ERR_NO` int(10) DEFAULT NULL COMMENT '오류번호',
  PRIMARY KEY (`DEBUG_ID`),
  UNIQUE KEY `PK_TB_DEBUG_INFO` (`DEBUG_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=517 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='디버그정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_dl_expd_mdy_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_dl_expd_mdy_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DL_EXPD_REGN_CD`,`DL_EXPD_MDL_MDY_CD`),
  UNIQUE KEY `TB_DL_EXPD_MDY_MGMT_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DL_EXPD_REGN_CD`,`DL_EXPD_MDL_MDY_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='취급설명서년식관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_dl_lang_mdy_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_dl_lang_mdy_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`LANG_CD`,`MDL_MDY_CD`,`DL_EXPD_REGN_CD`,`DL_EXPD_MDL_MDY_CD`),
  UNIQUE KEY `TB_DL_LANG_MDY_MGMT_PK` (`QLTY_VEHL_CD`,`LANG_CD`,`MDL_MDY_CD`,`DL_EXPD_REGN_CD`,`DL_EXPD_MDL_MDY_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='취급설명서언어별년식관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_eml_rcvr_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_eml_rcvr_mgmt` (
  `RCVR_ID` varchar(20) NOT NULL COMMENT '수신자ID',
  `EML_SCD_CD` varchar(4) NOT NULL COMMENT '이메일구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`RCVR_ID`,`EML_SCD_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='이메일수신자관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_eo_cd_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_eo_cd_info` (
  `DL_EXPD_ALTR_NO` varchar(10) NOT NULL COMMENT '취급설명서변경번호',
  `EO_CD` varchar(100) NOT NULL COMMENT 'EO코드',
  `PPRR_EENO` varchar(20) NOT NULL,
  `FRAM_DTM` datetime NOT NULL,
  PRIMARY KEY (`EO_CD`,`DL_EXPD_ALTR_NO`),
  UNIQUE KEY `TB_EO_CD_INFO_PK` (`EO_CD`,`DL_EXPD_ALTR_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='EO코드정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_extra_req_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_extra_req_info` (
  `RQ_YMD` varchar(8) NOT NULL COMMENT '요청년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `PRDN_PLNT_CD` varchar(1) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_RQ_SCN_CD` varchar(4) NOT NULL COMMENT '취급설명서요청구분코드',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `DLVH_RQ_OPS_NM` varchar(50) DEFAULT NULL COMMENT '배송요청부서명',
  `PWMR_EENO` varchar(20) NOT NULL COMMENT '요청자사원번호',
  `RQ_RSON_SBC` varchar(256) DEFAULT NULL COMMENT '요청사유내용',
  `DLVG_YN` char(1) DEFAULT NULL COMMENT '배송여부',
  `N_PRNT_PBCN_NO` varchar(100) DEFAULT NULL COMMENT '신인쇄발간번호',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`RQ_YMD`,`DATA_SN`,`DTL_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_EXTRA_REQ_INFO_PK` (`RQ_YMD`,`DATA_SN`,`DTL_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  KEY `TB_EXTRA_REQ_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='별도요청정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_glovis_dlvh_req_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_glovis_dlvh_req_info` (
  `RQ_YMD` char(8) NOT NULL COMMENT '요청년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_RQ_SCN_CD` varchar(4) NOT NULL COMMENT '취급설명서요청구분코드',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `PWMR_EENO` varchar(20) NOT NULL COMMENT '요청자사원번호',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `DEL_YN` char(1) NOT NULL COMMENT '삭제여부',
  `SPMN_IMTR_SBC` varchar(100) DEFAULT NULL COMMENT '특기사항내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`RQ_YMD`,`DATA_SN`,`DTL_SN`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_GLOVIS_DLVH_REQ_INFO_PK` (`RQ_YMD`,`DATA_SN`,`DTL_SN`,`QLTY_VEHL_CD`),
  KEY `TB_GLOVIS_DLVH_REQ_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='글로비스배송요청정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_glovis_dpcr_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_glovis_dpcr_info` (
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `DPCR_QTY` int(10) DEFAULT NULL COMMENT '전시차수량',
  `DPCR_SALE_DCSN_QTY` int(10) DEFAULT NULL COMMENT '전시차판매확정수량',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`WHOT_YMD`,`DATA_SN`,`DTL_SN`),
  UNIQUE KEY `TB_GLOVIS_DPCR_INFO_PK` (`WHOT_YMD`,`DATA_SN`,`DTL_SN`),
  KEY `TB_GLOVIS_DPCR_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='글로비스전시차정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_kdcs_if_kmc 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_kdcs_if_kmc` (
  `VIN` varchar(17) NOT NULL COMMENT '차대번호',
  `SHIP_DIST_CD` varchar(10) DEFAULT NULL COMMENT '선적대리점코드',
  `SHIP_DIST_NM` varchar(50) DEFAULT NULL COMMENT '선적대리점명칭',
  `SALE_DIST_CD` varchar(10) DEFAULT NULL COMMENT '판매대리점코드',
  `SALE_DIST_NM` varchar(50) DEFAULT NULL COMMENT '판매대리점명칭',
  `PORT_CD` varchar(5) DEFAULT NULL COMMENT '포트코드',
  `PORT_NM` varchar(50) DEFAULT NULL COMMENT '포트명칭',
  `MDL_CD` varchar(4) DEFAULT NULL COMMENT '모델코드',
  `MDL_NM` varchar(50) DEFAULT NULL COMMENT '모델명칭',
  `MDY_CD` varchar(4) DEFAULT NULL COMMENT '모델년식코드',
  `STAT_CD` varchar(4) DEFAULT NULL COMMENT '현재상태코드',
  `STAT_NM` varchar(50) DEFAULT NULL COMMENT '상태명칭',
  `PROD_YMD` varchar(8) DEFAULT NULL COMMENT 'Production Date(Sign Off)',
  `MPOOL_YMD` varchar(8) DEFAULT NULL COMMENT 'M/Pool Date',
  `SHIP_YMD` varchar(8) DEFAULT NULL COMMENT 'Shipment Date',
  `ETA_YMD` varchar(8) DEFAULT NULL COMMENT 'ETA Date',
  `PORT_ARRV_YMD` varchar(8) DEFAULT NULL COMMENT 'Port Arrival Date',
  `COMP_IN_YMD` varchar(8) DEFAULT NULL COMMENT 'Compound In Date',
  `WHOL_SALE_YMD` varchar(8) DEFAULT NULL COMMENT 'Wholesale Date',
  `RT_YMD` varchar(8) DEFAULT NULL COMMENT 'Retail Date',
  `CR_DT` varchar(14) DEFAULT NULL COMMENT '인터페이스데이터생성일',
  `EXCL_CD` varchar(5) DEFAULT NULL COMMENT '외장칼라코드',
  `EXCL_NM` varchar(100) DEFAULT NULL COMMENT '외장칼라영문명',
  `CDGB` varchar(1) DEFAULT NULL COMMENT 'CKD VIN 구분값',
  PRIMARY KEY (`VIN`),
  UNIQUE KEY `PK_TB_KDCS_IF_KMC` (`VIN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='선적현황정보_I/F_KMC';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_lang_mast 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_lang_mast` (
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `LANG_CD_NM` varchar(200) DEFAULT NULL COMMENT '언어명',
  `DL_EXPD_REGN_CD` varchar(2) DEFAULT NULL COMMENT '지역코드',
  `USE_YN` varchar(1) NOT NULL COMMENT '사용여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`LANG_CD`),
  UNIQUE KEY `PK_TB_LANG_MAST` (`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='언어마스터';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_lang_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_lang_mgmt` (
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `LANG_CD_NM` varchar(200) DEFAULT NULL COMMENT '언어코드명',
  `USE_YN` char(1) NOT NULL COMMENT '사용여부',
  `NAPC_YN` char(1) NOT NULL COMMENT 'N/A여부',
  `SORT_SN` int(8) DEFAULT NULL COMMENT '정렬일련번호',
  `A_CODE` varchar(100) DEFAULT NULL COMMENT 'A코드',
  `N1_INS_YN` char(1) DEFAULT NULL COMMENT '1차점검여부',
  `ET_YN` char(1) DEFAULT NULL COMMENT '전송여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DATA_SN`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_LANG_MGMT_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`),
  UNIQUE KEY `TB_LANG_MGMT_PK` (`DATA_SN`,`QLTY_VEHL_CD`),
  KEY `TB_LANG_MGMT_IDX2` (`MDL_MDY_CD`,`DL_EXPD_REGN_CD`,`LANG_CD`),
  KEY `TB_LANG_MGMT_IDX3` (`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='언어코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_lang_mgmt_if 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_lang_mgmt_if` (
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `LANG_CD_NM` varchar(200) DEFAULT NULL COMMENT '언어코드명',
  `USE_YN` char(1) NOT NULL COMMENT '사용여부',
  `NAPC_YN` char(1) NOT NULL COMMENT 'N/A여부',
  `SORT_SN` int(8) DEFAULT NULL COMMENT '정렬일련번호',
  `A_CODE` varchar(100) DEFAULT NULL COMMENT 'A코드',
  `N1_INS_YN` char(1) DEFAULT NULL COMMENT '1차점검여부',
  `IF_WK_RSLT_CD` char(1) DEFAULT NULL COMMENT 'I/F작업결과코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DTL_SN`),
  UNIQUE KEY `TB_LANG_MGMT_IF_PK` (`DTL_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='언어코드관리_I/F';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_lang_mgmt_original 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_lang_mgmt_original` (
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_REGN_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서지역코드',
  `LANG_CD_NM` varchar(200) DEFAULT NULL COMMENT '언어코드명',
  PRIMARY KEY (`LANG_CD`),
  UNIQUE KEY `TB_LANG_MGMT_ORIGINAL_PK` (`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='언어코드관리_원본';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_eml 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_eml` (
  `EML_CD` int(14) NOT NULL AUTO_INCREMENT COMMENT '이메일순번',
  `EML_SCD_CD` varchar(4) NOT NULL COMMENT '이메일구분코드(0042)',
  `EML_ID` varchar(20) NOT NULL COMMENT '사용자ID',
  `SNDR_ID` varchar(20) NOT NULL COMMENT '발신자ID',
  `EML_TITL` varchar(200) NOT NULL COMMENT '제목',
  `EML_SBC` longtext NOT NULL COMMENT '발신내용',
  `FS_SND_DATE` datetime NOT NULL COMMENT '최초발송일시',
  PRIMARY KEY (`EML_CD`),
  UNIQUE KEY `PK_TB_LOG_EML` (`EML_CD`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='이메일로그';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_eml_snd 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_eml_snd` (
  `EML_CD` int(14) NOT NULL COMMENT '이메일순번',
  `RCVR_ID` varchar(20) NOT NULL COMMENT '수신자ID',
  `ADRE_EML` varchar(200) DEFAULT NULL COMMENT '이메일주소',
  `EML_ST_CD` varchar(20) DEFAULT NULL COMMENT '이메일상태코드',
  `SND_DATE` datetime DEFAULT NULL COMMENT '발송일시',
  PRIMARY KEY (`EML_CD`,`RCVR_ID`),
  UNIQUE KEY `PK_TB_LOG_EML` (`EML_CD`,`RCVR_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='이메일로그_발송정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_fil 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_fil` (
  `FIL_CD` int(14) NOT NULL AUTO_INCREMENT COMMENT '파일로그순번',
  `FIL_DTM` datetime NOT NULL COMMENT '파일작업일시',
  `USE_TYPE` varchar(2) NOT NULL COMMENT '사용유형(06:다운로드, 07:업로드)',
  `USER_ID` varchar(20) NOT NULL COMMENT '사용자아이디',
  `USER_IP` varchar(50) DEFAULT NULL COMMENT '사용자아이피',
  `FIL_GBN` varchar(4) NOT NULL COMMENT '파일항목구분',
  `ATTC_SN` int(16) DEFAULT NULL COMMENT '첨부일련번호',
  `PGM_ID` varchar(10) NOT NULL COMMENT '프로그램ID',
  `ACT_ID` varchar(50) DEFAULT NULL COMMENT '액션아이디',
  `DNL_MGN` varchar(4000) DEFAULT NULL COMMENT '다운로드사유',
  PRIMARY KEY (`FIL_CD`),
  UNIQUE KEY `PK_TB_LOG_FIL` (`FIL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='파일로그';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_lgi 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_lgi` (
  `LGI_LOG_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '로그인로그일련번호',
  `USER_ID` varchar(20) NOT NULL COMMENT '사용자ID',
  `LGI_DTM` datetime NOT NULL COMMENT '로그인일시',
  `SUCS_YN` char(1) NOT NULL COMMENT '성공여부',
  `USER_IP_ADR` varchar(100) NOT NULL COMMENT '사용자IP',
  `ID_EXIST_YN` char(1) NOT NULL DEFAULT 'N' COMMENT 'ID존재여부',
  `SESS_ID` varchar(200) DEFAULT NULL COMMENT '세션ID',
  `LGO_DTM` datetime DEFAULT NULL COMMENT '로그아웃시간',
  `LGO_TYPE` char(1) DEFAULT NULL COMMENT 'L:로그아웃버튼, X:창닫기, S:세션아웃',
  PRIMARY KEY (`LGI_LOG_SN`),
  UNIQUE KEY `TB_LGI_LOG_PK` (`LGI_LOG_SN`)
) ENGINE=InnoDB AUTO_INCREMENT=45905 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='로그인로그(as-is:TB_LGI_LOG)';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_sched 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_sched` (
  `SCHED_ID` varchar(20) NOT NULL COMMENT '스케쥴러 아이디',
  `SCHED_NM` varchar(20) NOT NULL COMMENT '스케줄러 이름',
  `START_DTM` datetime NOT NULL COMMENT '시작 일시',
  `END_DTM` datetime NOT NULL COMMENT '종료일시',
  `API_URL` varchar(200) NOT NULL COMMENT 'API URL',
  `GET_DATA_CNT` int(11) NOT NULL COMMENT '가져온 데이터 수',
  `SAVE_DATA_CNT` int(11) NOT NULL COMMENT '저장한 데이타 수',
  `CALL_RSLT` varchar(10) NOT NULL COMMENT '조회응답결과',
  PRIMARY KEY (`SCHED_ID`,`START_DTM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='스케줄러 구동 로그 ';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_use 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_use` (
  `USE_LOG_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '사용로그일련번호',
  `USER_ID` varchar(20) NOT NULL COMMENT '사용자ID',
  `PGM_ID` varchar(10) NOT NULL COMMENT '프로그램ID',
  `PGM_NM` varchar(50) DEFAULT NULL COMMENT '프로그램명',
  `ACT_ID` varchar(50) DEFAULT NULL COMMENT '액션아이디',
  `USE_TYPE` varchar(2) NOT NULL COMMENT '사용유형(01:조회, 02:수정, 03:삭제, 04:인쇄, 05:등록)',
  `USE_SBC` varchar(1000) DEFAULT NULL COMMENT '사용내용',
  `USE_DTM` datetime NOT NULL COMMENT '사용일시',
  PRIMARY KEY (`USE_LOG_SN`),
  UNIQUE KEY `PK_TB_LOG_USE` (`USE_LOG_SN`)
) ENGINE=InnoDB AUTO_INCREMENT=450809 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용로그';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_log_user_altr 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_log_user_altr` (
  `ALTR_CD` int(14) NOT NULL AUTO_INCREMENT COMMENT '변경순번',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '변경대상ID',
  `CHGR_ID` varchar(30) DEFAULT NULL COMMENT '변경자ID',
  `CHGR_IP` varchar(30) DEFAULT NULL COMMENT '변경자IP',
  `AFT_TYPE` varchar(30) DEFAULT NULL COMMENT '변경유형(생성/변경/삭제)',
  `BEFR_VALUE` varchar(1000) DEFAULT NULL COMMENT '변경이전값',
  `AFTR_VALUE` varchar(1000) DEFAULT NULL COMMENT '변경이후값',
  `BEF_AUTH` varchar(30) DEFAULT NULL COMMENT '변경이전권한',
  `AFT_AUTH` varchar(30) DEFAULT NULL COMMENT '변경이후권한',
  `ALTR_DATE` datetime DEFAULT NULL COMMENT '변경일시',
  UNIQUE KEY `PK_TB_LOG_USER_ALTR` (`ALTR_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용자변경로그';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_mo_pack_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_mo_pack_mgmt` (
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  PRIMARY KEY (`MO_PACK_CD`),
  UNIQUE KEY `TB_MO_PACK_MGMT_PK` (`MO_PACK_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='월팩정보관리_사용하지 않아서 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_msg_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_msg_mgmt` (
  `MSG_CD` varchar(4) NOT NULL COMMENT '메시지코드',
  `MSG_SCN_CD` char(1) NOT NULL COMMENT '메시지구분코드',
  `MSG_SBC` varchar(200) DEFAULT NULL COMMENT '메시지내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`MSG_CD`,`MSG_SCN_CD`),
  UNIQUE KEY `TB_MSG_MGMT_PK` (`MSG_CD`,`MSG_SCN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='메시지관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_natl_lang_excel 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_natl_lang_excel` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '취급설명서국가코드',
  `NAT_NM` varchar(40) DEFAULT NULL COMMENT '국가명',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD_LIST` varchar(100) NOT NULL COMMENT '언어코드리스트'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='국가/언어코드엑셀';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_natl_lang_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_natl_lang_mgmt` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '취급설명서국가코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `USE_YN` char(1) NOT NULL COMMENT '사용여부',
  `NAPC_YN` char(1) NOT NULL DEFAULT 'N' COMMENT 'N/A여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`),
  UNIQUE KEY `TB_NATL_LANG_MGMT_PK` (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='국가/언어코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_natl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_natl_mgmt` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '취급설명서국가코드',
  `DL_EXPD_REGN_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서지역코드',
  `NAT_NM` varchar(40) DEFAULT NULL COMMENT '국가명',
  `DYTM_PLN_NAT_CD` varchar(5) DEFAULT NULL COMMENT '주간계획국가코드',
  `PRDN_MST_NAT_CD` varchar(5) DEFAULT NULL COMMENT '생산마스터국가코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`),
  UNIQUE KEY `TB_NATL_MGMT_PK` (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='국가코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_natl_noapim_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_natl_noapim_mgmt` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '취급설명서국가코드',
  `DL_EXPD_REGN_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서지역코드',
  `NAT_NM` varchar(40) DEFAULT NULL COMMENT '국가명',
  `DYTM_PLN_NAT_CD` varchar(5) DEFAULT NULL COMMENT '주간계획국가코드',
  `PRDN_MST_NAT_CD` varchar(5) DEFAULT NULL COMMENT '생산마스터국가코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`),
  UNIQUE KEY `TB_NATL_NOAPIM_MGMT_PK` (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='미지정국가코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_natl_vehl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_natl_vehl_mgmt` (
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `DL_EXPD_NAT_CD` varchar(5) NOT NULL COMMENT '취급설명서국가코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`QLTY_VEHL_CD`,`DL_EXPD_REGN_CD`),
  UNIQUE KEY `TB_NATL_VEHL_MGMT_PK` (`DL_EXPD_CO_CD`,`DL_EXPD_NAT_CD`,`QLTY_VEHL_CD`,`DL_EXPD_REGN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='국가/차종코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_ordr_req_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_ordr_req_info` (
  `ORDR_SN` int(10) NOT NULL AUTO_INCREMENT COMMENT '오더일련번호',
  `GUBUN` varchar(6) NOT NULL COMMENT '구분',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `RQ_QTY` int(5) NOT NULL COMMENT '요청수량',
  `ORDN_RQST_YMD` varchar(8) NOT NULL COMMENT '발주요청년월일',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  PRIMARY KEY (`ORDR_SN`),
  UNIQUE KEY `PK_TB_ACT_MGMT` (`ORDR_SN`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='오더요청정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_page_code_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_page_code_mgmt` (
  `DL_EXPD_PG_NM` varchar(50) NOT NULL COMMENT '취급설명서페이지명',
  `DEPPG1_CD` varchar(4) NOT NULL COMMENT '취급설명서페이지항목그룹코드',
  `DL_EXPD_PG_PRVS_CD` varchar(4) NOT NULL COMMENT '취급설명서페이지항목코드',
  `DEPPH1_NM` varchar(200) DEFAULT NULL COMMENT '취급설명서페이지항목한글명',
  `DEPPE1_NM` varchar(200) DEFAULT NULL COMMENT '취급설명서페이지항목영문명',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`DL_EXPD_PG_NM`,`DEPPG1_CD`,`DL_EXPD_PG_PRVS_CD`),
  UNIQUE KEY `TB_PAGE_CODE_MGMT_PK` (`DL_EXPD_PG_NM`,`DEPPG1_CD`,`DL_EXPD_PG_PRVS_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='페이지코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_com_vehl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_com_vehl_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DIVS_QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '전환품질차종코드',
  `DL_EXPD_PDI_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서PDI코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DIVS_QLTY_VEHL_CD`),
  UNIQUE KEY `TB_PDI_COM_VEHL_MGMT_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DIVS_QLTY_VEHL_CD`),
  KEY `TB_PDI_COM_VEHL_MGMT_IDX1` (`DIVS_QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI공통차종관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_divs_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_divs_info` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `DL_EXPD_RQ_SCN_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서요청구분코드',
  `RQ_QTY` int(5) NOT NULL COMMENT '요청수량',
  `DIVS_QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '재고전환품질차종코드',
  `DIVS_DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '재고전환취급설명서모델연식코드',
  `DIVS_LANG_CD` varchar(3) NOT NULL COMMENT '재고전환언어코드',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`WHOT_YMD`),
  UNIQUE KEY `TB_PDI_DIVS_INFO_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`WHOT_YMD`),
  KEY `TB_PDI_DIVS_INFO_IDX1` (`WHOT_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI재고전환정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_dlvh_req_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_dlvh_req_info` (
  `RQ_YMD` char(8) NOT NULL COMMENT '요청년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `PWMR_EENO` varchar(20) NOT NULL COMMENT '요청자사원번호',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`RQ_YMD`,`DATA_SN`,`DTL_SN`,`PRDN_PLNT_CD`),
  UNIQUE KEY `PK_TB_PDI_DLVH_REQ_INFO` (`RQ_YMD`,`DATA_SN`,`DTL_SN`,`PRDN_PLNT_CD`),
  KEY `TB_PDI_DLVH_REQ_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI배송요청정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_iv_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_iv_info` (
  `CLS_YMD` char(8) NOT NULL COMMENT '마감년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `IV_QTY` int(10) NOT NULL COMMENT '재고수량',
  `CMPL_YN` char(1) NOT NULL COMMENT '완료여부',
  `TMP_TRTM_YN` char(1) DEFAULT NULL COMMENT '임시처리여부',
  `DEEI1_QTY` int(10) DEFAULT NULL COMMENT '취급설명서초과부족수량',
  `IV_SCN_CD` char(1) DEFAULT NULL COMMENT '재고구분코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) NOT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime NOT NULL COMMENT '수정일시',
  PRIMARY KEY (`CLS_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PDI_IV_INFO_PK` (`CLS_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI재고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_iv_info_dtl 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_iv_info_dtl` (
  `CLS_YMD` char(8) NOT NULL COMMENT '마감년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `IV_QTY` int(10) NOT NULL COMMENT '재고수량',
  `SFTY_IV_QTY` int(10) NOT NULL COMMENT '안전재고수량',
  `CMPL_YN` char(1) DEFAULT NULL COMMENT '완료여부',
  `TMP_TRTM_YN` char(1) DEFAULT NULL COMMENT '임시처리여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`CLS_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  UNIQUE KEY `PK_TB_PDI_IV_INFO_DTL` (`CLS_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  KEY `IDX_PDI_IV_INFO_DTL_01` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`CLS_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI재고정보상세';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_whot_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_whot_info` (
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `DL_EXPD_WHOT_ST_CD` varchar(4) NOT NULL COMMENT '취급설명서출고상태코드',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `DL_EXPD_WHOT_QTY` int(10) NOT NULL COMMENT '취급설명서출고수량',
  `DEL_YN` char(1) NOT NULL COMMENT '삭제여부',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`WHOT_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PDI_WHOT_INFO_PK` (`WHOT_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI출고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pdi_whsn_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pdi_whsn_info` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `WHSN_YMD` char(8) NOT NULL COMMENT '입고년월일',
  `DL_EXPD_WHSN_ST_CD` varchar(4) NOT NULL COMMENT '취급설명서입고상태코드',
  `WHSN_QTY` int(10) NOT NULL COMMENT '입고수량',
  `DEEI1_QTY` int(10) DEFAULT NULL COMMENT '취급설명서초과부족수량',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `DL_EXPD_BOX_QTY` int(10) DEFAULT NULL COMMENT '취급설명서박스수량',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PDI_WHSN_INFO_PK` (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  KEY `TB_PDI_WHSN_INFO_IDX1` (`WHSN_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDI입고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_pgm_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_pgm_mgmt` (
  `MENU_ID` varchar(10) NOT NULL COMMENT '메뉴ID',
  `PGM_ID` varchar(10) NOT NULL COMMENT '프로그램ID',
  `PGM_ID_SN` int(6) NOT NULL COMMENT '프로그램ID일련번호',
  `PGM_NM` varchar(50) DEFAULT NULL COMMENT '프로그램명',
  `PGM_PATH_ADR` varchar(256) DEFAULT NULL COMMENT '프로그램경로주소',
  `INP_SCN_CD` varchar(1) NOT NULL COMMENT '입력구분코드',
  `USE_YN` varchar(1) NOT NULL COMMENT '사용여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`MENU_ID`),
  UNIQUE KEY `TB_PGM_MGMT_PK` (`MENU_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='프로그램정보관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_plnt_aps_odr_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_plnt_aps_odr_sum_info` (
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `ORD_QTY` int(16) NOT NULL COMMENT '주문수량',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `PRDN_QTY` int(10) NOT NULL COMMENT '생산수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL,
  PRIMARY KEY (`APL_STRT_YMD`,`APL_FNH_YMD`,`MO_PACK_CD`,`DATA_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_APS_ODR_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`MO_PACK_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_APS_ODR_SUM_INFO_PK` (`APL_STRT_YMD`,`APL_FNH_YMD`,`MO_PACK_CD`,`DATA_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS오더Summay정보_공장포함';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_plnt_aps_prod_plan_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_plnt_aps_prod_plan_sum_info` (
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `PLN_PARR_YMD` char(8) NOT NULL COMMENT '계획예정년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRDN_PLN_QTY` int(10) NOT NULL COMMENT '생산계획수량',
  `DCSN_YN` char(1) NOT NULL COMMENT '확정여부',
  `DCSN_YMD` char(8) DEFAULT NULL COMMENT '확정년월일',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  PRIMARY KEY (`APL_STRT_YMD`,`APL_FNH_YMD`,`PLN_PARR_YMD`,`DATA_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_APS_PLAN_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`PLN_PARR_YMD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_APS_PLAN_SUM_INFO_PK` (`APL_STRT_YMD`,`APL_FNH_YMD`,`PLN_PARR_YMD`,`DATA_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획Summary정보_공장포함';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_plnt_aps_prod_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_plnt_aps_prod_sum_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `TMM_ORD_QTY` int(10) DEFAULT NULL COMMENT '금월주문수량',
  `BORD_QTY` int(10) DEFAULT NULL COMMENT '이전미생산주문수량',
  `TDD_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '금일생산계획수량 - 영업일3일기준',
  `WEK2_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '2주생산계획수량',
  `TMM_PRDN_PLN_QTY` int(10) DEFAULT NULL COMMENT '금월예상생산계획수량',
  `MTH3_MO_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3개월월평균투입수량',
  `TMM_TRWI_QTY` int(10) DEFAULT NULL COMMENT '금월투입수량',
  `BOD_TRWI_QTY` int(10) DEFAULT NULL COMMENT '전일투입수량',
  `TDD_PRDN_QTY` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량 - 0공정~투입직전공정',
  `YER1_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1년일평균투입수량',
  `MTH3_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3개월일평균투입수량',
  `WEK2_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '2주일평균투입수량',
  `AVP_TRWI_QTY` int(10) DEFAULT NULL COMMENT '선행생산수량',
  `TDD_PRDN_QTY2` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량2 - 8공정~투입직전공정',
  `TDD_PRDN_PLN_QTY2` int(10) DEFAULT NULL COMMENT '금일생산계획수량2 - 영업일5일기준',
  `TDD_PRDN_PLN_QTY3` int(10) DEFAULT NULL COMMENT '금일생산계획수량3 - 영업일2일기준',
  `TDD_PRDN_QTY3` int(10) DEFAULT NULL COMMENT '금일생산(예정)수량3 - 9공정~투입직전공정',
  `WEK1_DLY_AVG_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1주일평균투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime NOT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`DATA_SN`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_APS_PROD_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_YMD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_APS_PROD_SUM_INFO_PK` (`APL_YMD`,`DATA_SN`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='APS주간계획및 생산마스터 Summary정보_공장포함';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_plnt_prod_mst_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_plnt_prod_mst_sum_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRDN_TRWI_QTY` int(10) NOT NULL COMMENT '생산투입수량',
  `PRDN_QTY` int(10) NOT NULL COMMENT '생산수량',
  `PRDN_QTY2` int(10) DEFAULT NULL COMMENT '생산수량2',
  `PRDN_QTY3` int(10) DEFAULT NULL COMMENT '생산수량3',
  `TH0_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '0번째공정시작년월일',
  `TH0_POW_FNH_YMD` char(8) DEFAULT NULL COMMENT '0번째공정종료년월일',
  `TH0_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '0번째공정투입수량',
  `TH1_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정시작년월일시분',
  `TH1_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정종료년월일시분',
  `TH1_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1번째공정투입수량',
  `TH2_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정시작년월일시분',
  `TH2_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정종료년월일시분',
  `TH2_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '2번째공정투입수량',
  `TH3_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정시작년월일시분',
  `TH3_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정종료년월일시분',
  `TH3_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3번째공정투입수량',
  `TH4_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정시작년월일시분',
  `TH4_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정종료년월일시분',
  `TH4_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '4번째공정투입수량',
  `TH5_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정시작년월일시분',
  `TH5_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정종료년월일시분',
  `TH5_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '5번째공정투입수량',
  `TH6_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정시작년월일시분',
  `TH6_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정종료년월일시분',
  `TH6_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '6번째공정투입수량',
  `TH7_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정시작년월일시분',
  `TH7_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정종료년월일시분',
  `TH7_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '7번째공정투입수량',
  `TH8_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정시작년월일시분',
  `TH8_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정종료년월일시분',
  `TH8_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '8번째공정투입수량',
  `TH9_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정시작년월일시분',
  `TH9_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정종료년월일시분',
  `TH9_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '9번째공정투입수량',
  `T10PS1_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정시작년월일시분',
  `TH10_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정종료년월일시분',
  `TH10_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '10번째공정투입수량',
  `T11PS1_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정시작년월일시분',
  `TH11_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정종료년월일시분',
  `TH11_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '11번째공정투입수량',
  `T12PS1_YMDHM` char(12) DEFAULT NULL COMMENT '12번째공정시작년월일시분',
  `TH12_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '12번째공정종료년월일시분',
  `TH12_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '12번째공정투입수량',
  `T13PS1_YMDHM` char(12) DEFAULT NULL COMMENT '13번째공정시작년월일시분',
  `TH13_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '13번째공정종료년월일시분',
  `TH13_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '13번째공정투입수량',
  `T14PS1_YMDHM` char(12) DEFAULT NULL COMMENT '14번째공정시작년월일시분',
  `TH14_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '14번째공정종료년월일시분',
  `TH14_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '14번째공정투입수량',
  `T15PS1_YMDHM` char(12) DEFAULT NULL COMMENT '15번째공정시작년월일시분',
  `TH15_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '15번째공정종료년월일시분',
  `TH15_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '15번째공정투입수량',
  `T16PS1_YMDHM` char(12) DEFAULT NULL COMMENT '16번째공정시작년월일시분',
  `TH16_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '16번째공정종료년월일시분',
  `TH16_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '16번째공정투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_PROD_MST_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_YMD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_PROD_MST_SUM_INFO_PK` (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터Summary정보_공장포함';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_plnt_vehl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_plnt_vehl_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL COMMENT '생산공장코드',
  `SORT_SN` int(4) NOT NULL COMMENT '정렬일련번호',
  `PLNT_NM` varchar(50) DEFAULT NULL COMMENT '공장명',
  PRIMARY KEY (`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PLNT_VEHL_MGMT_PK` (`QLTY_VEHL_CD`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='차종코드관리_공장포함';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prdn_ord_no_excel 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prdn_ord_no_excel` (
  `PRDN_ORD_NO` varchar(15) NOT NULL,
  `BASC_MDL_CD` varchar(12) DEFAULT NULL,
  `DEST_NAT_CD` varchar(5) DEFAULT NULL,
  `ORD_QTY` int(16) DEFAULT NULL,
  `PRDN_QTY` int(10) DEFAULT NULL,
  `PRDN_PLN_QTY` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용하지 않아서 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prdn_ord_no_temp 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prdn_ord_no_temp` (
  `PRDN_ORD_NO` varchar(15) NOT NULL,
  `BASC_MDL_CD` varchar(12) DEFAULT NULL,
  `DEST_NAT_CD` varchar(5) DEFAULT NULL,
  `ORD_QTY` int(16) DEFAULT NULL,
  `PRDN_QTY` int(10) DEFAULT NULL,
  `PRDN_PLN_QTY` int(10) DEFAULT NULL,
  `DYTM_PLN_NAT_CD` char(5) NOT NULL,
  PRIMARY KEY (`PRDN_ORD_NO`,`DYTM_PLN_NAT_CD`),
  UNIQUE KEY `TB_PRDN_ORD_NO_TEMP_PK` (`PRDN_ORD_NO`,`DYTM_PLN_NAT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용하지 않아서 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prnt_algn_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prnt_algn_info` (
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `DEPPC1_SN` int(6) NOT NULL COMMENT '취급설명서인쇄페이지목차일련번호',
  `DEPPC2_SN` int(2) NOT NULL DEFAULT 1 COMMENT '취급설명서인쇄페이지목차일련번호2',
  `DL_EXPD_PRNT_PG_SN` int(6) NOT NULL COMMENT '취급설명서인쇄페이지일련번호',
  `LRNK_CD` varchar(4) NOT NULL COMMENT '하위코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRNT_INSD_PG_SBC` varchar(100) DEFAULT NULL COMMENT '인쇄내부페이지내용',
  `DEPPR1_YN` char(1) DEFAULT NULL COMMENT '취급설명서인쇄페이지교체여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`N_PRNT_PBCN_NO`,`LRNK_CD`,`DEPPC1_SN`,`DEPPC2_SN`,`DL_EXPD_PRNT_PG_SN`),
  UNIQUE KEY `TB_PRNT_ALGN_INFO_PK` (`N_PRNT_PBCN_NO`,`LRNK_CD`,`DEPPC1_SN`,`DEPPC2_SN`,`DL_EXPD_PRNT_PG_SN`),
  KEY `TB_PRNT_ALGN_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='인쇄배열표정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prnt_bkgd_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prnt_bkgd_info` (
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `OLD_PRNT_PBCN_NO` varchar(100) DEFAULT NULL COMMENT '구인쇄발간번호',
  `CRE_YMD` char(8) NOT NULL COMMENT '생성년월일',
  `DL_EXPD_RDCS_ST_CD` varchar(4) NOT NULL COMMENT '취급설명서결재상태코드',
  `TRTM_YMD` char(8) NOT NULL COMMENT '처리년월일',
  `PRTL_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`N_PRNT_PBCN_NO`),
  UNIQUE KEY `TB_PRNT_BKGD_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`),
  UNIQUE KEY `TB_PRNT_BKGD_INFO_PK` (`N_PRNT_PBCN_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='발간물이력정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prnt_fp_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prnt_fp_info` (
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DLVG_PARR_YMD` char(8) NOT NULL COMMENT '납품예정년월일',
  `DL_EXPD_DLVG_PL_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서납품장소코드',
  `OLD_PRNT_PBCN_NO` varchar(100) DEFAULT NULL COMMENT '구인쇄발간번호',
  `I_WAY_SBC` varchar(100) DEFAULT NULL COMMENT '발행방법내용',
  `BKBD_WAY_SBC` varchar(100) DEFAULT NULL COMMENT '제본방법내용',
  `PG_MGN_SBC` varchar(100) DEFAULT NULL COMMENT '페이지크기내용',
  `DEPCQ1_SBC` varchar(100) DEFAULT NULL COMMENT '취급설명서인쇄표지지질내용',
  `DEIPQ1_SBC` varchar(100) DEFAULT NULL COMMENT '취급설명서내부페이지지질내용',
  `PRNT_CVR_SBC` varchar(100) DEFAULT NULL COMMENT '인쇄표지내용',
  `PRNT_INSD_PG_SBC` varchar(100) DEFAULT NULL COMMENT '인쇄내부페이지내용',
  `C_PRNT_CVR_SBC` varchar(100) DEFAULT NULL COMMENT '칼라인쇄표지내용',
  `C_PRNT_INSD_PG_SBC` varchar(100) DEFAULT NULL COMMENT '칼라인쇄내부페이지내용',
  `CVR_CEG_SBC` varchar(100) DEFAULT NULL COMMENT '표지코팅내용',
  `PG_NL` int(6) DEFAULT NULL COMMENT '페이지매수',
  `CVR_NL` int(6) DEFAULT NULL COMMENT '표지매수',
  `EXPD_NL` int(6) DEFAULT NULL COMMENT '설명서매수',
  `GRN_DOC_NL` int(6) DEFAULT NULL COMMENT '보증문서매수',
  `POST_CRD_NL` int(6) DEFAULT NULL COMMENT '우편카드매수',
  `EOFU1_NL` int(6) DEFAULT NULL COMMENT '기존옵셋필름이용매수',
  `NR_FLM_MKO_NL` int(6) DEFAULT NULL COMMENT '신규필름제작매수',
  `DGTL_PRNT_NL` int(6) DEFAULT NULL COMMENT '디지털인쇄매수',
  `OORD_EDIT_PG_NL` int(6) DEFAULT NULL COMMENT '외주편집페이지매수',
  `DEPC1_QTY` int(6) DEFAULT NULL COMMENT '취급설명서인쇄커버수량',
  `REM` varchar(100) DEFAULT NULL COMMENT '비고',
  `IV_QTY` int(10) DEFAULT NULL COMMENT '재고수량',
  `ORD_QTY` int(16) DEFAULT NULL COMMENT '주문수량',
  `MO_AVG_PRDN_QTY` int(10) DEFAULT NULL COMMENT '월평균생산수량',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `OORD_EDIT_CO_CD` varchar(4) DEFAULT NULL COMMENT '외주편집업체코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`N_PRNT_PBCN_NO`),
  UNIQUE KEY `TB_PRNT_FP_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`),
  UNIQUE KEY `TB_PRNT_FP_INFO_PK` (`N_PRNT_PBCN_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='인쇄세부내역정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prnt_page_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prnt_page_mgmt` (
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `LRNK_CD` varchar(4) NOT NULL COMMENT '하위코드',
  `DEPPC1_SN` int(6) NOT NULL COMMENT '취급설명서인쇄페이지목차일련번호',
  `DEPPC2_SN` int(2) NOT NULL DEFAULT 1 COMMENT '서문1,2,3',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `RGST_YMD` char(8) NOT NULL COMMENT '등록년월일',
  `END_PG_SN` int(6) NOT NULL COMMENT '끝페이지일련번호',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`N_PRNT_PBCN_NO`,`LRNK_CD`,`DEPPC1_SN`,`DEPPC2_SN`),
  UNIQUE KEY `TB_PRNT_PAGE_MGMT_PK` (`N_PRNT_PBCN_NO`,`LRNK_CD`,`DEPPC1_SN`,`DEPPC2_SN`),
  KEY `TB_PRNT_PAGE_MGMT_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='인쇄페이지관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prnt_req_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prnt_req_info` (
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRNT_PARR_YMD` char(8) NOT NULL COMMENT '인쇄예정년월일',
  `DLVG_PARR_YMD` char(8) NOT NULL COMMENT '납품예정년월일',
  `I_WAY_CD` varchar(4) DEFAULT NULL COMMENT '발행방법코드',
  `PRNT_PARR_QTY` int(10) NOT NULL COMMENT '인쇄예정수량',
  `PRNT_WAY_CD` varchar(4) DEFAULT NULL COMMENT '표지인쇄방법코드',
  `DEPQ1_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서인쇄지질코드',
  `OLD_PRNT_PBCN_NO` varchar(100) DEFAULT NULL COMMENT '구인쇄발간번호',
  `PG_MGN_SBC` varchar(100) DEFAULT NULL COMMENT '페이지크기내용',
  `PG_NL` int(6) DEFAULT NULL COMMENT '페이지매수',
  `OORD_EDIT_PG_NL` int(6) DEFAULT NULL COMMENT '외주편집페이지매수',
  `GRN_DOC_NL` int(6) DEFAULT NULL COMMENT '보증문서매수',
  `MDFY_PG_NL` int(6) DEFAULT NULL COMMENT '수정페이지매수',
  `DEPC1_YN` char(1) DEFAULT NULL COMMENT '취급설명서인쇄커버유무',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `SALE_UNP` decimal(16,2) DEFAULT NULL COMMENT '판매단가',
  `ORDN_RQST_YMD` char(8) NOT NULL COMMENT '발주의뢰년월일',
  `ORDN_CSET_CDT` char(8) DEFAULT NULL COMMENT '발주승인문자형일자',
  `N1AFP2_ADR` varchar(200) DEFAULT NULL COMMENT '1차첨부파일경로주소',
  `N2AFP2_ADR` varchar(200) DEFAULT NULL COMMENT '2차첨부파일경로주소',
  `CRGR_EENO` varchar(20) NOT NULL COMMENT '담당자사원번호',
  `CSET_CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '승인담당자사원번호',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `PRTL_IMTR_SBC2` varchar(4000) DEFAULT NULL COMMENT '발간현황특이사항내용2',
  `PRNT_WAY_CD2` varchar(15) DEFAULT NULL COMMENT '내지인쇄방법코드',
  `PRNT_PARR_BGT` decimal(16,2) DEFAULT NULL COMMENT '소요인쇄예산',
  `PRTL_IMTR_SBC3` varchar(20) DEFAULT NULL COMMENT '발간현황특이사항내용3',
  `ATTC_YN` varchar(1) DEFAULT NULL COMMENT '첨부파일유무',
  `COVER_ATTC_SN` int(16) DEFAULT NULL COMMENT '표지 첨부파일 순번',
  `INNER_ATTC_SN` int(16) DEFAULT NULL COMMENT '내지 첨부파일 순번',
  `OORD_EDIT_CO_CD` varchar(4) DEFAULT NULL COMMENT '외주편집업체코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  `BLC_SN` int(14) DEFAULT NULL COMMENT '게시물일련번호',
  PRIMARY KEY (`N_PRNT_PBCN_NO`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_PRNT_REQ_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`),
  UNIQUE KEY `TB_PRNT_REQ_INFO_PK` (`N_PRNT_PBCN_NO`,`QLTY_VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='발간물제작의뢰정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_info` (
  `PRDN_MST_VEHL_CD` varchar(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `VIN` char(17) NOT NULL COMMENT '차대번호',
  `USF_CD` varchar(2) NOT NULL COMMENT '용도코드',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '모델년식코드',
  `QLTY_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '품질차종코드',
  `DL_EXPD_NAT_CD` varchar(5) DEFAULT NULL COMMENT '취급설명서국가코드',
  `PRDN_ORD_NO` varchar(15) NOT NULL COMMENT '생산주문번호',
  `PRDN_MST_NAT_CD` varchar(5) NOT NULL COMMENT '생산마스터국가코드',
  `PRDN_PLNT_CD` varchar(3) DEFAULT 'N' COMMENT '생산공장코드',
  `PRDN_OCN_CD` varchar(4) DEFAULT NULL COMMENT '생산OCN코드',
  `BASC_MDL_CD` varchar(12) DEFAULT NULL COMMENT '기본모델코드',
  `VER_CD` varchar(3) DEFAULT NULL COMMENT '버전코드',
  `DEST_NAT_CD` varchar(5) NOT NULL COMMENT '목적지국가코드',
  `POW_LOC_CD` varchar(2) NOT NULL COMMENT '공정위치코드',
  `TRWI_YMD` char(8) NOT NULL COMMENT '투입년월일',
  `TRWI_USED_YN` char(1) DEFAULT NULL COMMENT '투입수량기사용여부',
  `PRDN_POW_LOC_CD` varchar(2) DEFAULT NULL COMMENT '생산공정위치코드',
  `PRDN_MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '생산모델년식코드',
  `TH0_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '0번째공정시작년월일',
  `TH1_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '1번째공정시작년월일시분',
  `TH2_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '2번째공정시작년월일시분',
  `TH3_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '3번째공정시작년월일시분',
  `TH4_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '4번째공정시작년월일시분',
  `TH5_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '5번째공정시작년월일시분',
  `TH6_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '6번째공정시작년월일시분',
  `TH7_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '7번째공정시작년월일시분',
  `TH8_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '8번째공정시작년월일시분',
  `TH9_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '9번째공정시작년월일시분',
  `T10PS1_YMDHM` char(12) NOT NULL COMMENT '10번째공정시작년월일시분',
  `T11PS1_YMDHM` char(12) NOT NULL COMMENT '11번째공정시작년월일시분',
  `T12PS1_YMDHM` char(12) NOT NULL COMMENT '12번째공정시작년월일시분',
  `T13PS1_YMDHM` char(12) NOT NULL COMMENT '13번째공정시작년월일시분',
  `T14PS1_YMDHM` char(12) NOT NULL COMMENT '14번째공정시작년월일시분',
  `T15PS1_YMDHM` char(12) NOT NULL COMMENT '15번째공정시작년월일시분',
  `T16PS1_YMDHM` char(12) NOT NULL COMMENT '16번째공정시작년월일시분',
  `TH1_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '1번째공정마감기준시작년월일',
  `TH2_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '2번째공정마감기준시작년월일',
  `TH3_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '3번째공정마감기준시작년월일',
  `TH4_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '4번째공정마감기준시작년월일',
  `TH5_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '5번째공정마감기준시작년월일',
  `TH6_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '6번째공정마감기준시작년월일',
  `TH7_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '7번째공정마감기준시작년월일',
  `TH8_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '8번째공정마감기준시작년월일',
  `TH9_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '9번째공정마감기준시작년월일',
  `T10PS1_YMD` char(8) DEFAULT NULL COMMENT '10번째공정마감기준시작년월일',
  `T11PS1_YMD` char(8) DEFAULT NULL COMMENT '11번째공정마감기준시작년월일',
  `T12PS1_YMD` char(8) DEFAULT NULL COMMENT '12번째공정마감기준시작년월일',
  `T13PS1_YMD` char(8) DEFAULT NULL COMMENT '13번째공정마감기준시작년월일',
  `T14PS1_YMD` char(8) DEFAULT NULL COMMENT '14번째공정마감기준시작년월일',
  `T15PS1_YMD` char(8) DEFAULT NULL COMMENT '15번째공정마감기준시작년월일',
  `T16PS1_YMD` char(8) DEFAULT NULL COMMENT '16번째공정마감기준시작년월일',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`APL_YMD`,`VIN`),
  UNIQUE KEY `TB_PROD_MST_INFO_PK` (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`APL_YMD`,`VIN`),
  KEY `TB_PROD_MST_INFO_IDX1` (`APL_YMD`,`DL_EXPD_CO_CD`),
  KEY `TB_PROD_MST_INFO_IDX2` (`TRWI_YMD`,`DL_EXPD_CO_CD`,`PRDN_MST_VEHL_CD`),
  KEY `TB_PROD_MST_INFO_IDX3` (`VIN`,`DL_EXPD_CO_CD`),
  KEY `TB_PROD_MST_INFO_IX099` (`APL_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_info_erp_hmc 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_info_erp_hmc` (
  `PRDN_MST_VEHL_CD` char(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `USF_CD` char(1) DEFAULT NULL COMMENT '용도코드',
  `MO_PACK_CD` char(4) DEFAULT NULL COMMENT '월팩코드',
  `PRDN_ORD_NO` char(9) DEFAULT NULL COMMENT '생산주문번호',
  `PRDN_MST_NAT_CD` char(5) DEFAULT NULL COMMENT '생산마스터국가코드',
  `BASC_MDL_CD` char(12) DEFAULT NULL COMMENT '기본모델코드',
  `PRDN_OCN_CD` char(4) DEFAULT NULL COMMENT '생산OCN코드',
  `VER_CD` char(3) DEFAULT NULL COMMENT '버전코드',
  `DEST_NAT_CD` char(5) DEFAULT NULL COMMENT '목적지국가코드',
  `POW_LOC_CD` char(4) DEFAULT NULL COMMENT '공정위치코드',
  `TH1_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정시작년월일시분',
  `TH2_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정시작년월일시분',
  `TH3_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정시작년월일시분',
  `TH4_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정시작년월일시분',
  `TH5_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정시작년월일시분',
  `TH6_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정시작년월일시분',
  `TH7_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정시작년월일시분',
  `TH8_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정시작년월일시분',
  `TH9_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정시작년월일시분',
  `T10PS1_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정시작년월일시분',
  `T11PS1_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정시작년월일시분',
  `MDL_MDY_CD` char(2) DEFAULT NULL COMMENT '모델년식코드',
  `VIN` char(17) DEFAULT NULL COMMENT '차대번호',
  `PLNT_CD` char(4) DEFAULT NULL COMMENT '공장코드',
  `RCPM_TRTM_YN` char(1) DEFAULT NULL COMMENT '수신투입여부',
  `TRTM_YMD` char(8) DEFAULT NULL COMMENT '투입년월일',
  `TH1_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '1번째공정마감기준시작년월일',
  `TH2_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '2번째공정마감기준시작년월일',
  `TH3_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '3번째공정마감기준시작년월일',
  `TH4_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '4번째공정마감기준시작년월일',
  `TH5_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '5번째공정마감기준시작년월일',
  `TH6_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '6번째공정마감기준시작년월일',
  `TH7_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '7번째공정마감기준시작년월일',
  `TH8_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '8번째공정마감기준시작년월일',
  `TH9_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '9번째공정마감기준시작년월일',
  `T10PS1_YMD` char(8) DEFAULT NULL COMMENT '10번째공정마감기준시작년월일',
  `T11PS1_YMD` char(8) DEFAULT NULL COMMENT '11번째공정마감기준시작년월일',
  `ET_GUBN_CD` char(2) DEFAULT NULL COMMENT '전송구분코드(''01'':오후,''02'':명일오전)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터정보_ERP_HMC';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_info_erp_kmc 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_info_erp_kmc` (
  `PRDN_MST_VEHL_CD` char(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `USF_CD` char(1) DEFAULT NULL COMMENT '용도코드',
  `MO_PACK_CD` char(4) DEFAULT NULL COMMENT '월팩코드',
  `PRDN_ORD_NO` char(9) DEFAULT NULL COMMENT '생산주문번호',
  `PRDN_MST_NAT_CD` char(5) DEFAULT NULL COMMENT '생산마스터국가코드',
  `BASC_MDL_CD` char(12) DEFAULT NULL COMMENT '기본모델코드',
  `PRDN_OCN_CD` char(4) DEFAULT NULL COMMENT '생산OCN코드',
  `VER_CD` char(3) DEFAULT NULL COMMENT '버전코드',
  `DEST_NAT_CD` char(5) DEFAULT NULL COMMENT '목적지국가코드',
  `POW_LOC_CD` char(4) DEFAULT NULL COMMENT '공정위치코드',
  `TH1_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정시작년월일시분',
  `TH2_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정시작년월일시분',
  `TH3_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정시작년월일시분',
  `TH4_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정시작년월일시분',
  `TH5_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정시작년월일시분',
  `TH6_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정시작년월일시분',
  `TH7_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정시작년월일시분',
  `TH8_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정시작년월일시분',
  `TH9_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정시작년월일시분',
  `T10PS1_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정시작년월일시분',
  `T11PS1_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정시작년월일시분',
  `MDL_MDY_CD` char(2) DEFAULT NULL COMMENT '모델년식코드',
  `VIN` char(17) DEFAULT NULL COMMENT '차대번호',
  `PLNT_CD` char(4) DEFAULT NULL COMMENT '공장코드',
  `RCPM_TRTM_YN` char(1) DEFAULT NULL COMMENT '수신투입여부',
  `TRTM_YMD` char(8) DEFAULT NULL COMMENT '투입년월일',
  `TH1_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '1번째공정마감기준시작년월일',
  `TH2_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '2번째공정마감기준시작년월일',
  `TH3_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '3번째공정마감기준시작년월일',
  `TH4_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '4번째공정마감기준시작년월일',
  `TH5_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '5번째공정마감기준시작년월일',
  `TH6_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '6번째공정마감기준시작년월일',
  `TH7_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '7번째공정마감기준시작년월일',
  `TH8_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '8번째공정마감기준시작년월일',
  `TH9_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '9번째공정마감기준시작년월일',
  `T10PS1_YMD` char(8) DEFAULT NULL COMMENT '10번째공정마감기준시작년월일',
  `T11PS1_YMD` char(8) DEFAULT NULL COMMENT '11번째공정마감기준시작년월일',
  `ET_GUBN_CD` char(2) DEFAULT NULL COMMENT '전송구분코드(''01'':오후,''02'':명일오전)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터정보_ERP_KMC';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_noapim_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_noapim_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(4) NOT NULL COMMENT '모델년식코드',
  `PRDN_MST_NAT_CD` varchar(5) NOT NULL COMMENT '생산마스터국가코드',
  `PRDN_TRWI_QTY` int(10) NOT NULL COMMENT '생산투입수량',
  `PRDN_QTY` int(10) NOT NULL COMMENT '생산수량',
  `PRDN_QTY2` int(10) DEFAULT NULL COMMENT '생산수량2',
  `PRDN_QTY3` int(10) DEFAULT NULL COMMENT '생산수량3',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`PRDN_MST_NAT_CD`),
  UNIQUE KEY `TB_PROD_MST_NOAPIM_INFO_PK` (`APL_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`PRDN_MST_NAT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터미지정Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_prog_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_prog_info` (
  `PRDN_MST_VEHL_CD` varchar(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `APL_STRT_YMD` char(8) NOT NULL COMMENT '적용시작년월일',
  `APL_FNH_YMD` char(8) NOT NULL COMMENT '적용종료년월일',
  `VIN` char(17) NOT NULL COMMENT '차대번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `USF_CD` varchar(2) NOT NULL COMMENT '용도코드',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DEST_NAT_CD` varchar(5) NOT NULL COMMENT '목적지국가코드',
  `POW_LOC_CD` varchar(2) NOT NULL COMMENT '공정위치코드',
  `MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) DEFAULT 'N' COMMENT '생산공장코드',
  `PRDN_MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '생산모델년식코드',
  `QLTY_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '품질차종코드',
  `DL_EXPD_NAT_CD` varchar(5) DEFAULT NULL COMMENT '취급설명서국가코드',
  `TH0_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '0번째공정시작년월일',
  `TH1_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '1번째공정시작년월일시분',
  `TH2_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '2번째공정시작년월일시분',
  `TH3_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '3번째공정시작년월일시분',
  `TH4_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '4번째공정시작년월일시분',
  `TH5_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '5번째공정시작년월일시분',
  `TH6_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '6번째공정시작년월일시분',
  `TH7_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '7번째공정시작년월일시분',
  `TH8_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '8번째공정시작년월일시분',
  `TH9_POW_STRT_YMDHM` char(12) NOT NULL COMMENT '9번째공정시작년월일시분',
  `T10PS1_YMDHM` char(12) NOT NULL COMMENT '10번째공정시작년월일시분',
  `T11PS1_YMDHM` char(12) NOT NULL COMMENT '11번째공정시작년월일시분',
  `T12PS1_YMDHM` char(12) NOT NULL COMMENT '12번째공정시작년월일시분',
  `T13PS1_YMDHM` char(12) NOT NULL COMMENT '13번째공정시작년월일시분',
  `T14PS1_YMDHM` char(12) NOT NULL COMMENT '14번째공정시작년월일시분',
  `T15PS1_YMDHM` char(12) NOT NULL COMMENT '15번째공정시작년월일시분',
  `T16PS1_YMDHM` char(12) NOT NULL COMMENT '16번째공정시작년월일시분',
  `TRWI_USED_YN` char(1) DEFAULT NULL COMMENT '투입수량기사용여부',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`DTL_SN`,`VIN`),
  UNIQUE KEY `TB_PROD_MST_PROG_INFO_PK` (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`APL_STRT_YMD`,`APL_FNH_YMD`,`DTL_SN`,`VIN`),
  KEY `TB_PROD_MST_PROG_INFO_IDX2` (`VIN`,`DL_EXPD_CO_CD`),
  KEY `TB_PROD_MST_PROG_INFO_IDX1` (`APL_STRT_YMD`,`APL_FNH_YMD`,`DL_EXPD_CO_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터진행정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_sum_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_sum_info` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRDN_TRWI_QTY` int(10) NOT NULL COMMENT '생산투입수량',
  `PRDN_QTY` int(10) NOT NULL COMMENT '생산수량',
  `PRDN_QTY2` int(10) DEFAULT NULL COMMENT '생산수량2',
  `PRDN_QTY3` int(10) DEFAULT NULL COMMENT '생산수량3',
  `TH0_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '0번째공정시작년월일',
  `TH0_POW_FNH_YMD` char(8) DEFAULT NULL COMMENT '0번째공정종료년월일',
  `TH0_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '0번째공정투입수량',
  `TH1_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정시작년월일시분',
  `TH1_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정종료년월일시분',
  `TH1_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1번째공정투입수량',
  `TH2_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정시작년월일시분',
  `TH2_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정종료년월일시분',
  `TH2_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '2번째공정투입수량',
  `TH3_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정시작년월일시분',
  `TH3_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정종료년월일시분',
  `TH3_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3번째공정투입수량',
  `TH4_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정시작년월일시분',
  `TH4_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정종료년월일시분',
  `TH4_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '4번째공정투입수량',
  `TH5_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정시작년월일시분',
  `TH5_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정종료년월일시분',
  `TH5_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '5번째공정투입수량',
  `TH6_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정시작년월일시분',
  `TH6_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정종료년월일시분',
  `TH6_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '6번째공정투입수량',
  `TH7_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정시작년월일시분',
  `TH7_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정종료년월일시분',
  `TH7_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '7번째공정투입수량',
  `TH8_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정시작년월일시분',
  `TH8_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정종료년월일시분',
  `TH8_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '8번째공정투입수량',
  `TH9_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정시작년월일시분',
  `TH9_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정종료년월일시분',
  `TH9_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '9번째공정투입수량',
  `T10PS1_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정시작년월일시분',
  `TH10_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정종료년월일시분',
  `TH10_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '10번째공정투입수량',
  `T11PS1_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정시작년월일시분',
  `TH11_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정종료년월일시분',
  `TH11_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '11번째공정투입수량',
  `T12PS1_YMDHM` char(12) DEFAULT NULL COMMENT '12번째공정시작년월일시분',
  `TH12_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '12번째공정종료년월일시분',
  `TH12_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '12번째공정투입수량',
  `T13PS1_YMDHM` char(12) DEFAULT NULL COMMENT '13번째공정시작년월일시분',
  `TH13_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '13번째공정종료년월일시분',
  `TH13_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '13번째공정투입수량',
  `T14PS1_YMDHM` char(12) DEFAULT NULL COMMENT '14번째공정시작년월일시분',
  `TH14_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '14번째공정종료년월일시분',
  `TH14_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '14번째공정투입수량',
  `T15PS1_YMDHM` char(12) DEFAULT NULL COMMENT '15번째공정시작년월일시분',
  `TH15_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '15번째공정종료년월일시분',
  `TH15_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '15번째공정투입수량',
  `T16PS1_YMDHM` char(12) DEFAULT NULL COMMENT '16번째공정시작년월일시분',
  `TH16_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '16번째공정종료년월일시분',
  `TH16_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '16번째공정투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_PROD_MST_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_YMD`),
  UNIQUE KEY `TB_PROD_MST_SUM_INFO_PK` (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_sum_info_temp 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_sum_info_temp` (
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRDN_TRWI_QTY` int(10) NOT NULL COMMENT '생산투입수량',
  `PRDN_QTY` int(10) NOT NULL COMMENT '생산수량',
  `PRDN_QTY2` int(10) DEFAULT NULL COMMENT '생산수량2',
  `PRDN_QTY3` int(10) DEFAULT NULL COMMENT '생산수량3',
  `TH0_POW_STRT_YMD` char(8) DEFAULT NULL COMMENT '0번째공정시작년월일',
  `TH0_POW_FNH_YMD` char(8) DEFAULT NULL COMMENT '0번째공정종료년월일',
  `TH0_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '0번째공정투입수량',
  `TH1_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정시작년월일시분',
  `TH1_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '1번째공정종료년월일시분',
  `TH1_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '1번째공정투입수량',
  `TH2_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정시작년월일시분',
  `TH2_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '2번째공정종료년월일시분',
  `TH2_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '2번째공정투입수량',
  `TH3_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정시작년월일시분',
  `TH3_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '3번째공정종료년월일시분',
  `TH3_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '3번째공정투입수량',
  `TH4_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정시작년월일시분',
  `TH4_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '4번째공정종료년월일시분',
  `TH4_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '4번째공정투입수량',
  `TH5_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정시작년월일시분',
  `TH5_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '5번째공정종료년월일시분',
  `TH5_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '5번째공정투입수량',
  `TH6_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정시작년월일시분',
  `TH6_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '6번째공정종료년월일시분',
  `TH6_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '6번째공정투입수량',
  `TH7_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정시작년월일시분',
  `TH7_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '7번째공정종료년월일시분',
  `TH7_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '7번째공정투입수량',
  `TH8_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정시작년월일시분',
  `TH8_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '8번째공정종료년월일시분',
  `TH8_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '8번째공정투입수량',
  `TH9_POW_STRT_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정시작년월일시분',
  `TH9_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '9번째공정종료년월일시분',
  `TH9_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '9번째공정투입수량',
  `T10PS1_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정시작년월일시분',
  `TH10_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '10번째공정종료년월일시분',
  `TH10_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '10번째공정투입수량',
  `T11PS1_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정시작년월일시분',
  `TH11_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '11번째공정종료년월일시분',
  `TH11_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '11번째공정투입수량',
  `T12PS1_YMDHM` char(12) DEFAULT NULL COMMENT '12번째공정시작년월일시분',
  `TH12_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '12번째공정종료년월일시분',
  `TH12_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '12번째공정투입수량',
  `T13PS1_YMDHM` char(12) DEFAULT NULL COMMENT '13번째공정시작년월일시분',
  `TH13_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '13번째공정종료년월일시분',
  `TH13_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '13번째공정투입수량',
  `T14PS1_YMDHM` char(12) DEFAULT NULL COMMENT '14번째공정시작년월일시분',
  `TH14_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '14번째공정종료년월일시분',
  `TH14_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '14번째공정투입수량',
  `T15PS1_YMDHM` char(12) DEFAULT NULL COMMENT '15번째공정시작년월일시분',
  `TH15_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '15번째공정종료년월일시분',
  `TH15_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '15번째공정투입수량',
  `T16PS1_YMDHM` char(12) DEFAULT NULL COMMENT '16번째공정시작년월일시분',
  `TH16_POW_FNH_YMDHM` char(12) DEFAULT NULL COMMENT '16번째공정종료년월일시분',
  `TH16_POW_TRWI_QTY` int(10) DEFAULT NULL COMMENT '16번째공정투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`),
  UNIQUE KEY `TB_PROD_MST_SUM_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`APL_YMD`),
  UNIQUE KEY `TB_PROD_MST_SUM_INFO_PK` (`APL_YMD`,`DATA_SN`,`QLTY_VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터Summary정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_mst_trwi_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_mst_trwi_info` (
  `PRDN_MST_VEHL_CD` varchar(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `DL_EXPD_CO_CD` varchar(4) NOT NULL COMMENT '취급설명서회사코드',
  `APL_YMD` char(8) NOT NULL COMMENT '적용년월일',
  `VIN` char(17) NOT NULL COMMENT '차대번호',
  `TRWI_YMD` char(8) NOT NULL COMMENT '투입년월일',
  `USF_CD` varchar(2) NOT NULL COMMENT '용도코드',
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DEST_NAT_CD` varchar(5) NOT NULL COMMENT '목적지국가코드',
  `POW_LOC_CD` varchar(2) NOT NULL COMMENT '공정위치코드',
  `MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '모델년식코드',
  `PRDN_MDL_MDY_CD` varchar(2) DEFAULT NULL COMMENT '생산모델년식코드',
  `QLTY_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '품질차종코드',
  `DL_EXPD_NAT_CD` varchar(5) DEFAULT NULL COMMENT '취급설명서국가코드',
  `PRDN_PLNT_CD` varchar(3) DEFAULT 'N' COMMENT '생산공장코드',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`APL_YMD`,`VIN`),
  UNIQUE KEY `TB_PROD_MST_TRWI_INFO_PK` (`PRDN_MST_VEHL_CD`,`BN_SN`,`DL_EXPD_CO_CD`,`APL_YMD`,`VIN`),
  KEY `TB_PROD_MST_TRWI_INFO_IDX2` (`TRWI_YMD`,`DL_EXPD_CO_CD`,`PRDN_MST_VEHL_CD`),
  KEY `TB_PROD_MST_TRWI_INFO_IDX3` (`VIN`,`DL_EXPD_CO_CD`),
  KEY `TB_PROD_MST_TRWI_INFO_IDX1` (`APL_YMD`,`DL_EXPD_CO_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산마스터투입정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_prod_odr_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_prod_odr_info` (
  `MO_PACK_CD` varchar(4) NOT NULL COMMENT '월팩코드',
  `DATA_SN` int(8) NOT NULL COMMENT '데이터일련번호',
  `APL_YMD` varchar(8) NOT NULL COMMENT '적용년월일',
  `PRDN_PLNT_CD` varchar(1) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `PRDN_TRWI_QTY` int(10) NOT NULL COMMENT '생산투입수량',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`MO_PACK_CD`,`DATA_SN`,`APL_YMD`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_PROD_ODR_INFO_IDX1` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`MO_PACK_CD`,`APL_YMD`),
  UNIQUE KEY `TB_PROD_ODR_INFO_PK` (`MO_PACK_CD`,`DATA_SN`,`APL_YMD`,`QLTY_VEHL_CD`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='생산오더정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_rcvr_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_rcvr_mgmt` (
  `RCVR_GBN` varchar(10) NOT NULL COMMENT '수신자구분(0041)',
  `GBN_SN` varchar(30) NOT NULL COMMENT '구분정보',
  `RCVR_EENO` varchar(20) NOT NULL COMMENT '수신자사원번호',
  `SORT_SN` int(4) NOT NULL COMMENT '정렬일련번호',
  `POP_CK_DTM` varchar(8) DEFAULT NULL COMMENT '공지확인일자',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`RCVR_GBN`,`GBN_SN`,`RCVR_EENO`),
  UNIQUE KEY `tb_rcvr_mgmt_PK` (`RCVR_GBN`,`GBN_SN`,`RCVR_EENO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='수신자관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewha_divs_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewha_divs_info` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `DL_EXPD_RQ_SCN_CD` varchar(4) NOT NULL COMMENT '취급설명서요청구분코드',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `DIVS_QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '재고전환품질차종코드',
  `DIVS_DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '재고전환취급설명서모델연식코드',
  `DIVS_LANG_CD` varchar(3) NOT NULL COMMENT '재고전환언어코드',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`WHOT_YMD`,`DL_EXPD_RQ_SCN_CD`),
  UNIQUE KEY `TB_SEWHA_DIVS_INFO_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`WHOT_YMD`,`DL_EXPD_RQ_SCN_CD`),
  KEY `TB_SEWHA_DIVS_INFO_IDX1` (`WHOT_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원재고전환정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewha_iv_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewha_iv_info` (
  `CLS_YMD` char(8) NOT NULL COMMENT '마감년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `IV_QTY` int(10) NOT NULL COMMENT '재고수량',
  `DL_EXPD_TMP_IV_QTY` int(10) DEFAULT NULL COMMENT '취급설명서임시재고수량',
  `CMPL_YN` char(1) NOT NULL COMMENT '완료여부',
  `TMP_TRTM_YN` char(1) DEFAULT NULL COMMENT '임시처리여부',
  `DEEI1_QTY` int(10) DEFAULT NULL COMMENT '취급설명서초과부족수량',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`CLS_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_IV_INFO_PK` (`CLS_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원재고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewha_iv_info_dtl 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewha_iv_info_dtl` (
  `CLS_YMD` char(8) NOT NULL COMMENT '마감년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `IV_QTY` int(10) NOT NULL COMMENT '재고수량',
  `SFTY_IV_QTY` int(10) NOT NULL COMMENT '안전재고수량',
  `DL_EXPD_TMP_IV_QTY` int(10) DEFAULT NULL COMMENT '취급설명서임시재고수량',
  `CMPL_YN` char(1) DEFAULT NULL COMMENT '완료여부',
  `TMP_TRTM_YN` char(1) DEFAULT NULL COMMENT '임시처리여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`CLS_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_IV_INFO_DTL_PK` (`CLS_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원재고정보상세';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewha_whot_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewha_whot_info` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `DL_EXPD_RQ_SCN_CD` varchar(4) NOT NULL COMMENT '취급설명서요청구분코드',
  `DLVG_PARR_YMD` char(8) DEFAULT NULL COMMENT '납품예정년월일',
  `DLVG_PARR_HHMM` char(4) DEFAULT NULL COMMENT '납품예정시분',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `PWTI_EENO` varchar(20) DEFAULT NULL COMMENT '인수자사원번호',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `DL_EXPD_BOX_QTY` int(10) DEFAULT NULL COMMENT '취급설명서박스수량',
  `CMPL_YN` char(1) DEFAULT NULL COMMENT '완료여부',
  `WHSN_YMD` char(8) DEFAULT NULL COMMENT '입고년월일',
  `DEL_YN` char(1) DEFAULT NULL COMMENT '삭제여부',
  `PWTI_NM` varchar(20) DEFAULT NULL COMMENT '인수자명',
  `DL_EXPD_WHOT_ST_CD` varchar(4) DEFAULT '01' COMMENT '재고보정코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_WHOT_INFO_PK` (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  KEY `TB_SEWHA_WHOT_INFO_IDX1` (`WHOT_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원출고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewha_whsn_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewha_whsn_info` (
  `WHSN_YMD` char(8) NOT NULL COMMENT '입고년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `WHSN_QTY` int(10) NOT NULL COMMENT '입고수량',
  `CRGR_EENO` varchar(20) NOT NULL COMMENT '담당자사원번호',
  `PRNT_PARR_YMD` char(8) NOT NULL COMMENT '인쇄예정년월일',
  `DLVG_PARR_YMD` char(8) NOT NULL COMMENT '납품예정년월일',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`WHSN_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_WHSN_INFO_PK` (`WHSN_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  KEY `TB_SEWHA_WHSN_INFO_IDX1` (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원입고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewon_divs_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewon_divs_info` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `DL_EXPD_RQ_SCN_CD` varchar(4) NOT NULL COMMENT '취급설명서요청구분코드',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `DIVS_QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '재고전환품질차종코드',
  `DIVS_DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '재고전환취급설명서모델연식코드',
  `DIVS_LANG_CD` varchar(3) NOT NULL COMMENT '재고전환언어코드',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`WHOT_YMD`,`DL_EXPD_RQ_SCN_CD`),
  UNIQUE KEY `TB_SEWHA_DIVS_INFO_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`WHOT_YMD`,`DL_EXPD_RQ_SCN_CD`),
  KEY `TB_SEWHA_DIVS_INFO_IDX1` (`WHOT_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원재고전환정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewon_iv_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewon_iv_info` (
  `CLS_YMD` char(8) NOT NULL COMMENT '마감년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `IV_QTY` int(10) NOT NULL COMMENT '재고수량',
  `DL_EXPD_TMP_IV_QTY` int(10) DEFAULT NULL COMMENT '취급설명서임시재고수량',
  `CMPL_YN` char(1) NOT NULL COMMENT '완료여부',
  `TMP_TRTM_YN` char(1) DEFAULT NULL COMMENT '임시처리여부',
  `DEEI1_QTY` int(10) DEFAULT NULL COMMENT '취급설명서초과부족수량',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`CLS_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_IV_INFO_PK` (`CLS_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원재고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewon_iv_info_dtl 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewon_iv_info_dtl` (
  `CLS_YMD` char(8) NOT NULL COMMENT '마감년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `IV_QTY` int(10) NOT NULL COMMENT '재고수량',
  `SFTY_IV_QTY` int(10) NOT NULL COMMENT '안전재고수량',
  `DL_EXPD_TMP_IV_QTY` int(10) DEFAULT NULL COMMENT '취급설명서임시재고수량',
  `CMPL_YN` char(1) DEFAULT NULL COMMENT '완료여부',
  `TMP_TRTM_YN` char(1) DEFAULT NULL COMMENT '임시처리여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`CLS_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_IV_INFO_DTL_PK` (`CLS_YMD`,`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`,`DL_EXPD_MDL_MDY_CD`,`N_PRNT_PBCN_NO`,`PRDN_PLNT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원재고정보상세';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewon_whot_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewon_whot_info` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `DTL_SN` int(12) NOT NULL COMMENT '상세일련번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `WHOT_YMD` char(8) NOT NULL COMMENT '출고년월일',
  `DL_EXPD_RQ_SCN_CD` varchar(4) NOT NULL COMMENT '취급설명서요청구분코드',
  `DLVG_PARR_YMD` char(8) DEFAULT NULL COMMENT '납품예정년월일',
  `DLVG_PARR_HHMM` char(4) DEFAULT NULL COMMENT '납품예정시분',
  `RQ_QTY` int(6) NOT NULL COMMENT '요청수량',
  `PWTI_EENO` varchar(20) DEFAULT NULL COMMENT '인수자사원번호',
  `PRTL_IMTR_SBC` varchar(4000) DEFAULT NULL COMMENT '특이사항내용',
  `CRGR_EENO` varchar(20) DEFAULT NULL COMMENT '담당자사원번호',
  `DL_EXPD_BOX_QTY` int(10) DEFAULT NULL COMMENT '취급설명서박스수량',
  `CMPL_YN` char(1) DEFAULT NULL COMMENT '완료여부',
  `WHSN_YMD` char(8) DEFAULT NULL COMMENT '입고년월일',
  `DEL_YN` char(1) DEFAULT NULL COMMENT '삭제여부',
  `PWTI_NM` varchar(20) DEFAULT NULL COMMENT '인수자명',
  `DL_EXPD_WHOT_ST_CD` varchar(4) DEFAULT '01' COMMENT '재고보정코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_WHOT_INFO_PK` (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`DTL_SN`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  KEY `TB_SEWHA_WHOT_INFO_IDX1` (`WHOT_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원출고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sewon_whsn_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sewon_whsn_info` (
  `WHSN_YMD` char(8) NOT NULL COMMENT '입고년월일',
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_MDL_MDY_CD` varchar(2) NOT NULL COMMENT '취급설명서모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `N_PRNT_PBCN_NO` varchar(100) NOT NULL COMMENT '신인쇄발간번호',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PRDN_PLNT_CD` varchar(3) NOT NULL DEFAULT 'N' COMMENT '생산공장코드',
  `WHSN_QTY` int(10) NOT NULL COMMENT '입고수량',
  `CRGR_EENO` varchar(20) NOT NULL COMMENT '담당자사원번호',
  `PRNT_PARR_YMD` char(8) NOT NULL COMMENT '인쇄예정년월일',
  `DLVG_PARR_YMD` char(8) NOT NULL COMMENT '납품예정년월일',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`WHSN_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  UNIQUE KEY `TB_SEWHA_WHSN_INFO_PK` (`WHSN_YMD`,`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`,`MDL_MDY_CD`,`PRDN_PLNT_CD`),
  KEY `TB_SEWHA_WHSN_INFO_IDX1` (`QLTY_VEHL_CD`,`DL_EXPD_MDL_MDY_CD`,`LANG_CD`,`N_PRNT_PBCN_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='세원입고정보';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_sfty_iv_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_sfty_iv_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `LANG_CD` varchar(3) NOT NULL COMMENT '언어코드',
  `MO_AVG_ORD_QTY` int(10) DEFAULT NULL COMMENT '월평균주문수량',
  `MAPP1_QTY` int(10) DEFAULT NULL COMMENT '월평균생산계획수량',
  `MO_AVG_PRDN_QTY` int(10) DEFAULT NULL COMMENT '월평균생산수량',
  `TSID141_QTY` int(10) DEFAULT NULL COMMENT '이론안전재고14일수량',
  `TSID31_QTY` int(10) DEFAULT NULL COMMENT '이론안전재고3일수량',
  `DSID141_QTY` int(10) DEFAULT NULL COMMENT '확정안전재고14일수량',
  `DSID31_QTY` int(10) DEFAULT NULL COMMENT '확정안전재고3일수량',
  `USE_YN` char(1) NOT NULL COMMENT '사용여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`),
  UNIQUE KEY `TB_SFTY_IV_MGMT_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`LANG_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='안전재고관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_use_dpmst 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_use_dpmst` (
  `DP_ID` varchar(9) NOT NULL COMMENT '화면ID',
  `DP_SEQ` int(4) NOT NULL COMMENT 'SEQ',
  `DP_NM` varchar(100) NOT NULL COMMENT '화면명',
  `USE_GBN` varchar(1) NOT NULL COMMENT '사용자구분',
  `DP_GBN` varchar(1) NOT NULL COMMENT '화면구분',
  `DP_LVL` varchar(1) NOT NULL COMMENT '레벨',
  `DP_URL` varchar(100) NOT NULL COMMENT 'URL',
  `DP_MN_NM1` varchar(100) NOT NULL COMMENT '메뉴명1',
  `DP_MN_NM2` varchar(100) DEFAULT NULL COMMENT '메뉴명2',
  `DP_MN_NM3` varchar(100) DEFAULT NULL COMMENT '메뉴명3',
  `DP_MN_NM4` varchar(100) DEFAULT NULL COMMENT '메뉴명4',
  `DP_MN_NM5` varchar(100) DEFAULT NULL COMMENT '메뉴명5',
  `USE_TERM` varchar(1) DEFAULT NULL COMMENT '사용주기',
  `DP_STRT_REV_DTM` varchar(8) DEFAULT NULL COMMENT '화면가동예정일',
  `DP_APV_DTM` varchar(8) DEFAULT NULL COMMENT '변경검토승인일',
  `DP_STRT_DTM` varchar(8) DEFAULT NULL COMMENT '화면가동일',
  `DP_END_DTM` varchar(8) DEFAULT NULL COMMENT '서비스종료일',
  `DP_DEL_DTM` varchar(8) DEFAULT NULL COMMENT '화면폐기일',
  `USE_LOG_YN` varchar(1) DEFAULT NULL COMMENT '로그관리여부',
  `N_LOG_SBC` varchar(200) DEFAULT NULL COMMENT '미관리사유',
  `DP_USE_TYPE` varchar(2) DEFAULT NULL COMMENT '화면특성',
  `USE_SSL_1M` varchar(1) DEFAULT NULL COMMENT '사용월(1월)',
  `USE_SSL_2M` varchar(1) DEFAULT NULL COMMENT '사용월(2월)',
  `USE_SSL_3M` varchar(1) DEFAULT NULL COMMENT '사용월(3월)',
  `USE_SSL_4M` varchar(1) DEFAULT NULL COMMENT '사용월(4월)',
  `USE_SSL_5M` varchar(1) DEFAULT NULL COMMENT '사용월(5월)',
  `USE_SSL_6M` varchar(1) DEFAULT NULL COMMENT '사용월(6월)',
  `USE_SSL_7M` varchar(1) DEFAULT NULL COMMENT '사용월(7월)',
  `USE_SSL_8M` varchar(1) DEFAULT NULL COMMENT '사용월(8월)',
  `USE_SSL_9M` varchar(1) DEFAULT NULL COMMENT '사용월(9월)',
  `USE_SSL_10M` varchar(1) DEFAULT NULL COMMENT '사용월(10월)',
  `USE_SSL_11M` varchar(1) DEFAULT NULL COMMENT '사용월(11월)',
  `USE_SSL_12M` varchar(1) DEFAULT NULL COMMENT '사용월(12월)',
  `TG_USR_CNT` int(9) DEFAULT NULL COMMENT '목표사용자수',
  `TG_USE_CNT` int(9) DEFAULT NULL COMMENT '목표사용횟수',
  `ACT_ID` varchar(100) NOT NULL COMMENT '액션아이디',
  `PGM_ID` varchar(20) DEFAULT NULL COMMENT '프로그램ID',
  PRIMARY KEY (`DP_ID`,`DP_SEQ`),
  UNIQUE KEY `tb_use_dpmst_pk` (`DP_ID`,`DP_SEQ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_nopad_ci COMMENT='tb_log_use만 사용하기로 결정하여 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_use_dp_log 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_use_dp_log` (
  `LOG_SN` int(10) NOT NULL AUTO_INCREMENT COMMENT '순번',
  `SYTM_CD` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '시스템코드',
  `SYTM_NM` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '시스템명',
  `PGM_ID` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '프로그램ID',
  `DP_NM` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '프로그램명',
  `USER_ID` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '사용자ID',
  `USER_NM` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '사용자명',
  `COMP_CD` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '회사코드',
  `COMP_NM` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '회사명',
  `DEPT_CD` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '부서코드',
  `DEPT_NM` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '부서명',
  `LOG_DTM` datetime NOT NULL COMMENT '로그일시',
  `LOG_CNT` int(5) NOT NULL COMMENT '로그횟수',
  `HAE_GBN` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'HAE구분',
  PRIMARY KEY (`LOG_SN`),
  UNIQUE KEY `TB_USE_DP_LOG` (`LOG_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_nopad_ci COMMENT='tb_log_use만 사용하기로 결정하여 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_usr_grp_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_usr_grp_mgmt` (
  `GRP_CD` varchar(3) NOT NULL COMMENT '그룹코드',
  `GRP_NM` varchar(50) NOT NULL COMMENT '그룹명',
  `SORT_SN` int(4) NOT NULL COMMENT '정렬일련번호',
  `REM` varchar(100) DEFAULT NULL COMMENT '비고',
  `USE_YN` varchar(1) NOT NULL COMMENT '사용여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`GRP_CD`),
  UNIQUE KEY `SORT_SN_UNIQUE` (`SORT_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용자그룹관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_usr_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_usr_mgmt` (
  `USER_EENO` varchar(20) NOT NULL COMMENT '사용자사원번호',
  `USER_PW` varchar(256) NOT NULL COMMENT '사용자비밀번호',
  `USER_NM` varchar(50) NOT NULL COMMENT '사용자명',
  `GRP_CD` varchar(3) NOT NULL COMMENT '그룹코드',
  `BLNS_CO_CD` varchar(4) NOT NULL COMMENT '소속회사코드',
  `USER_DCD` varchar(8) NOT NULL COMMENT '사용자부서코드',
  `USER_EML_ADR` varchar(100) DEFAULT NULL COMMENT '사용자이메일주소',
  `USE_YN` varchar(1) NOT NULL COMMENT '사용여부',
  `PW_ALTR_DTM` datetime NOT NULL DEFAULT current_timestamp() COMMENT '비밀번호변경일시',
  `FIN_LGI_DTM` datetime NOT NULL DEFAULT current_timestamp() COMMENT '최종로그인일',
  `PW_LOCK_DTM` datetime DEFAULT NULL COMMENT '비밀번호잠김일시',
  `PW_ERR_OFT` int(11) NOT NULL DEFAULT 0 COMMENT '연속비밀번호오입력회수',
  `USER_CHG_PW` varchar(1) NOT NULL DEFAULT '0' COMMENT '비밀번호복잡도레벨',
  `USER_OSET_LGI` varchar(1) DEFAULT NULL COMMENT '비번변경',
  `USE_GBN` varchar(1) NOT NULL DEFAULT 'U' COMMENT 'U:사용자, G:그룹',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  `DEL_YN` char(1) DEFAULT 'N' COMMENT '삭제여부',
  `DEL_EENO` varchar(20) DEFAULT NULL COMMENT '삭제사원번호',
  `DEL_DTM` datetime DEFAULT NULL COMMENT '삭제일시',
  PRIMARY KEY (`USER_EENO`),
  UNIQUE KEY `TB_USR_MGMT_PK` (`USER_EENO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용자관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_usr_mgmt_excel 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_usr_mgmt_excel` (
  `USER_EENO` varchar(20) DEFAULT NULL,
  `USER_PW` varchar(10) DEFAULT NULL,
  `USER_NM` varchar(20) DEFAULT NULL,
  `BLNS_CO_NM` varchar(100) DEFAULT NULL,
  `USER_OPS_NM` varchar(100) DEFAULT NULL,
  `USER_EML_ADR` varchar(100) DEFAULT NULL,
  `USER_TN` varchar(14) DEFAULT NULL,
  `USER_HP_NO` char(14) DEFAULT NULL,
  `USE_YN` char(1) DEFAULT NULL,
  `PGM01_IQ_VEHL` longtext DEFAULT NULL,
  `PGM01_INP_VEHL` longtext DEFAULT NULL,
  `PGM02_IQ_VEHL` longtext DEFAULT NULL,
  `PGM02_INP_VEHL` longtext DEFAULT NULL,
  `PGM03_IQ_VEHL` longtext DEFAULT NULL,
  `PGM03_INP_VEHL` longtext DEFAULT NULL,
  `PGM04_IQ_VEHL` longtext DEFAULT NULL,
  `PGM04_INP_VEHL` longtext DEFAULT NULL,
  `PGM05_IQ_VEHL` longtext DEFAULT NULL,
  `PGM05_INP_VEHL` longtext DEFAULT NULL,
  `PGM06_IQ_VEHL` longtext DEFAULT NULL,
  `PGM06_INP_VEHL` longtext DEFAULT NULL,
  `PGM07_IQ_VEHL` longtext DEFAULT NULL,
  `PGM07_INP_VEHL` longtext DEFAULT NULL,
  `PGM08_IQ_VEHL` longtext DEFAULT NULL,
  `PGM08_INP_VEHL` longtext DEFAULT NULL,
  `PGM09_IQ_VEHL` longtext DEFAULT NULL,
  `PGM09_INP_VEHL` longtext DEFAULT NULL,
  `PGM10_IQ_VEHL` longtext DEFAULT NULL,
  `PGM10_INP_VEHL` longtext DEFAULT NULL,
  `PGM11_IQ_VEHL` longtext DEFAULT NULL,
  `PGM11_INP_VEHL` longtext DEFAULT NULL,
  `PGM12_IQ_VEHL` longtext DEFAULT NULL,
  `PGM12_INP_VEHL` longtext DEFAULT NULL,
  `PGM13_IQ_VEHL` longtext DEFAULT NULL,
  `PGM13_INP_VEHL` longtext DEFAULT NULL,
  `PGM14_IQ_VEHL` longtext DEFAULT NULL,
  `PGM14_INP_VEHL` longtext DEFAULT NULL,
  `PGM15_IQ_VEHL` longtext DEFAULT NULL,
  `PGM15_INP_VEHL` longtext DEFAULT NULL,
  `PGM16_IQ_VEHL` longtext DEFAULT NULL,
  `PGM16_INP_VEHL` longtext DEFAULT NULL,
  `PGM17_IQ_VEHL` longtext DEFAULT NULL,
  `PGM17_INP_VEHL` longtext DEFAULT NULL,
  `PGM18_IQ_VEHL` longtext DEFAULT NULL,
  `PGM18_INP_VEHL` longtext DEFAULT NULL,
  `PGM19_IQ_VEHL` longtext DEFAULT NULL,
  `PGM19_INP_VEHL` longtext DEFAULT NULL,
  `PGM20_IQ_VEHL` longtext DEFAULT NULL,
  `PGM20_INP_VEHL` longtext DEFAULT NULL,
  `PGM21_IQ_VEHL` longtext DEFAULT NULL,
  `PGM21_INP_VEHL` longtext DEFAULT NULL,
  `PGM22_IQ_VEHL` longtext DEFAULT NULL,
  `PGM22_INP_VEHL` longtext DEFAULT NULL,
  `PGM23_IQ_VEHL` longtext DEFAULT NULL,
  `PGM23_INP_VEHL` longtext DEFAULT NULL,
  `PGM24_IQ_VEHL` longtext DEFAULT NULL,
  `PGM24_INP_VEHL` longtext DEFAULT NULL,
  `PGM25_IQ_VEHL` longtext DEFAULT NULL,
  `PGM25_INP_VEHL` longtext DEFAULT NULL,
  `PGM26_IQ_VEHL` longtext DEFAULT NULL,
  `PGM26_INP_VEHL` longtext DEFAULT NULL,
  `PGM27_IQ_VEHL` longtext DEFAULT NULL,
  `PGM27_INP_VEHL` longtext DEFAULT NULL,
  `PGM28_IQ_VEHL` longtext DEFAULT NULL,
  `PGM28_INP_VEHL` longtext DEFAULT NULL,
  `PGM29_IQ_VEHL` longtext DEFAULT NULL,
  `PGM29_INP_VEHL` longtext DEFAULT NULL,
  `PGM30_IQ_VEHL` longtext DEFAULT NULL,
  `PGM30_INP_VEHL` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='사용하지 않아서 삭제예정';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_usr_token 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_usr_token` (
  `USER_EENO` varchar(20) NOT NULL COMMENT '사용자번호',
  `IP` varchar(20) NOT NULL COMMENT '리모트 IP',
  `ACCESS_TIME` datetime NOT NULL,
  `BROWSER_ID` varchar(100) NOT NULL,
  `REFRESH_TOKEN` varchar(300) NOT NULL COMMENT '리프레시 토큰',
  `REFRESH_TOKEN_VALID_TIME` bigint(20) NOT NULL COMMENT '리프레시 토큰 만료시간',
  `REFRESH_TOKEN_DTM` datetime NOT NULL COMMENT '리프레시 토큰 생성시간',
  PRIMARY KEY (`USER_EENO`),
  UNIQUE KEY `REFRESH_TOKEN_UNIQUE` (`REFRESH_TOKEN`),
  UNIQUE KEY `BROWSER_ID_UNIQUE` (`BROWSER_ID`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_vehl_crgr_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_vehl_crgr_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `CRGR_EENO` varchar(20) NOT NULL COMMENT '담당자사원번호',
  `BLNS_CO_CD` varchar(4) NOT NULL COMMENT '소속회사코드',
  `USE_YN` char(1) NOT NULL COMMENT '사용여부',
  `ET_YN` char(1) DEFAULT NULL COMMENT '전송여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`CRGR_EENO`),
  KEY `TB_VEHL_CRGR_MGMT_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`CRGR_EENO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='차종담당자관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_vehl_mdy_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_vehl_mdy_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `DESMP1_CD` varchar(4) NOT NULL COMMENT '취급설명서시작월팩코드',
  `DEFMP1_CD` varchar(4) NOT NULL COMMENT '취급설명서종료월팩코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`DL_EXPD_REGN_CD`,`DESMP1_CD`,`DEFMP1_CD`),
  UNIQUE KEY `TB_VEHL_MDY_MGMT_PK` (`QLTY_VEHL_CD`,`DL_EXPD_REGN_CD`,`DESMP1_CD`,`DEFMP1_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='주간계획차종년식관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_vehl_mdy_rel_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_vehl_mdy_rel_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `DL_EXPD_REGN_CD` varchar(4) NOT NULL COMMENT '취급설명서지역코드',
  `JB_MDY_REL_CD` varchar(4) NOT NULL COMMENT '직전년식관계코드',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DL_EXPD_REGN_CD`),
  UNIQUE KEY `TB_VEHL_MDY_REL_MGMT_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`,`DL_EXPD_REGN_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='차종연식관계관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_vehl_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_vehl_mgmt` (
  `QLTY_VEHL_CD` varchar(4) NOT NULL COMMENT '품질차종코드',
  `MDL_MDY_CD` varchar(2) NOT NULL COMMENT '모델년식코드',
  `DL_EXPD_CO_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서회사코드',
  `QLTY_VEHL_NM` varchar(100) DEFAULT NULL COMMENT '품질차종명',
  `DL_EXPD_PAC_SCN_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서승상구분코드',
  `DL_EXPD_PDI_CD` varchar(4) DEFAULT NULL COMMENT '취급설명서PDI코드',
  `JB_MDY_REL_CD` varchar(4) DEFAULT NULL COMMENT '직전년식관계코드',
  `DYTM_PLN_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '주간계획차종코드',
  `PRDN_MST_VEHL_CD` varchar(4) DEFAULT NULL COMMENT '생산마스터차종코드',
  `BOM_VEHL_CD` varchar(4) DEFAULT NULL COMMENT 'BOM차종코드',
  `USE_YN` char(1) DEFAULT NULL COMMENT '사용여부',
  `ET_YN` char(1) DEFAULT NULL COMMENT '전송여부',
  `PPRR_EENO` varchar(20) NOT NULL COMMENT '작성자사원번호',
  `FRAM_DTM` datetime NOT NULL COMMENT '작성일시',
  `UPDR_EENO` varchar(20) DEFAULT NULL COMMENT '수정자사원번호',
  `MDFY_DTM` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QLTY_VEHL_CD`,`MDL_MDY_CD`),
  UNIQUE KEY `TB_VEHL_MGMT_PK` (`QLTY_VEHL_CD`,`MDL_MDY_CD`),
  KEY `TB_VEHL_MGMT_IDX1` (`MDL_MDY_CD`,`DL_EXPD_CO_CD`,`DL_EXPD_PAC_SCN_CD`,`DL_EXPD_PDI_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='차종코드관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_vin 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_vin` (
  `PRDN_MST_VEHL_CD` varchar(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `VIN` char(17) DEFAULT NULL COMMENT '차대번호',
  `PDI_IN` datetime DEFAULT NULL COMMENT 'PDI유입',
  `PDI_IN_YMD` varchar(8) DEFAULT NULL COMMENT 'PDI유입년월일'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='차대번호';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_vin_noexist 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_vin_noexist` (
  `PRDN_MST_VEHL_CD` varchar(4) NOT NULL COMMENT '생산마스터차종코드',
  `BN_SN` char(6) NOT NULL COMMENT 'BODY-NO일련번호',
  `VIN` char(17) DEFAULT NULL COMMENT '차대번호',
  `PDI_IN` datetime DEFAULT NULL COMMENT 'PDI유입'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='차대번호미존재';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_wrk_date_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_wrk_date_mgmt` (
  `WK_YMD` char(8) NOT NULL COMMENT '작업년월일',
  `DOW_CD` char(1) NOT NULL COMMENT '요일코드',
  `HOLI_YN` char(1) NOT NULL COMMENT '휴일여부',
  PRIMARY KEY (`WK_YMD`),
  UNIQUE KEY `TB_WRK_DATE_MGMT_PK` (`WK_YMD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='날짜정보관리';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_yongsan_iv_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_yongsan_iv_info` (
  `APL_YML` char(8) NOT NULL COMMENT '적용(기준)일자',
  `CO_CD` varchar(2) NOT NULL COMMENT '회사코드',
  `VEHL_CD` varchar(7) NOT NULL COMMENT '차종코드',
  `MTRL_CD` varchar(30) DEFAULT NULL,
  `V_QTY` int(9) NOT NULL COMMENT '재고합계',
  `IV_ON_MOVE_QTY` int(9) NOT NULL COMMENT '이동중재고',
  `IV_ONEALL_ITME_QTY` int(9) NOT NULL COMMENT '원올단품',
  `IV_ONEALL_KIT_QTY` int(9) NOT NULL COMMENT '원올KIT',
  `IV_ON_LOCAL_QTY` int(9) NOT NULL COMMENT '지역재고',
  `IV_SUM` int(9) NOT NULL,
  `WHOT_QTY` int(9) NOT NULL COMMENT '출고대수(수량)',
  `RESP_QTY` int(9) NOT NULL COMMENT '대응일수',
  `ORD_QTY` int(9) NOT NULL COMMENT '발주수량',
  `REST_QTY` int(9) NOT NULL COMMENT '입고잔량',
  PRIMARY KEY (`APL_YML`,`VEHL_CD`),
  UNIQUE KEY `PK_TB_YONGSAN_IV_INFO_IF_HMC` (`APL_YML`,`VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='용산재고정보_I/F';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_yongsan_iv_info_if 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_yongsan_iv_info_if` (
  `APL_YMD` char(8) NOT NULL,
  `COMPANY` varchar(1) NOT NULL COMMENT '회사코드',
  `VEH_CD` varchar(10) NOT NULL COMMENT '차종코드(KA4 23)',
  `MTRL_CD` varchar(30) NOT NULL COMMENT '품번(KA4 23 VER1)',
  `VEHL_STOCK` int(9) NOT NULL COMMENT '재고합계',
  `STOCK_ON_MOVE` int(9) NOT NULL COMMENT '이동중재고',
  `STOCK_ONE_ALL_ITEM` int(9) NOT NULL COMMENT '원올단품',
  `STOCK_ONE_ALL_KIT` int(9) NOT NULL COMMENT '원올KIT',
  `STOCK_ON_LOCAL` int(9) NOT NULL COMMENT '지역재고',
  `STOCK_SUM` int(9) NOT NULL,
  `DELIVER_VEHL_CNT` int(9) NOT NULL COMMENT '출고대수(수량)',
  `RESPONSE_DAYS` int(9) NOT NULL COMMENT '대응일수',
  `ORDER_AMOUNT` int(9) NOT NULL COMMENT '발주수량',
  `REST_AMOUNT` int(9) NOT NULL COMMENT '입고잔량',
  `FRAM_DTM` datetime NOT NULL,
  PRIMARY KEY (`APL_YMD`,`MTRL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='용산재고정보_I/F';

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 hkomms.tb_yongsan_vehl_info_if 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_yongsan_vehl_info_if` (
  `CO_CD` varchar(2) NOT NULL COMMENT '회사코드',
  `VEHL_CD` varchar(7) NOT NULL COMMENT '차종코드',
  `VEHL_NM` varchar(50) NOT NULL COMMENT '차종명칭',
  PRIMARY KEY (`VEHL_CD`),
  UNIQUE KEY `PK_TB_YONGSAN_VEHL_INFO_IF_HMC` (`VEHL_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='용산차종정보_I/F';

-- 내보낼 데이터가 선택되어 있지 않습니다.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
