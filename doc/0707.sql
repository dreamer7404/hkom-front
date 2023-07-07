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

-- 테이블 hkomms.tb_api_auth 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_api_auth` (
  `grp_cd` varchar(3) NOT NULL COMMENT '권한그룹 코드 (tb_user_grp_mgmt)',
  `api_url` varchar(100) NOT NULL COMMENT 'API URL (tb_api_mgmt)',
  `pprr_eeno` varchar(20) NOT NULL,
  `fram_dtm` datetime NOT NULL,
  PRIMARY KEY (`grp_cd`,`api_url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='API 권한';

-- 테이블 데이터 hkomms.tb_api_auth:~41 rows (대략적) 내보내기
/*!40000 ALTER TABLE `tb_api_auth` DISABLE KEYS */;
INSERT INTO `tb_api_auth` (`grp_cd`, `api_url`, `pprr_eeno`, `fram_dtm`) VALUES
	('100', '/changePgmMgmtUseYn', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/changeToken', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/changeUserUseYn', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/codeCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/grpCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/initUserPw', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivm2WeekPlan', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivm3DayPlan', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmIvModInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmMonthOrdPrdInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmNatlProdPlanInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmOrderRequestInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmPdiIvInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmPdiOrYongsanIvs', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmPdiPrndMonitorInfo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmPdiWhsnInfo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmSeparatelyRequest', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmSewonIvmInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmSewonRequestInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmSewonWhotInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmSewonWhotInfos2', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmThisMonTrwis', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmTotIvInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/ivmVehlIvInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/langCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/mdyCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/pdiCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/pgmMgmts', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/pgmMgmtsAll', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/printOrderInfos', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/printState', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/printStates', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/regionCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/sewonIvm', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/subCdCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/Test', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/usrGrpMgmts', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/usrmgmt', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/usrmgmts', 'H2212239', '2023-07-07 13:32:05'),
	('100', '/vehlCombo', 'H2212239', '2023-07-07 13:32:05'),
	('100', 'ivmSewonIvs', 'H2212239', '2023-07-07 13:32:05');
/*!40000 ALTER TABLE `tb_api_auth` ENABLE KEYS */;

-- 테이블 hkomms.tb_api_mgmt 구조 내보내기
CREATE TABLE IF NOT EXISTS `tb_api_mgmt` (
  `api_url` varchar(100) NOT NULL COMMENT 'API URL',
  `api_nm` varchar(45) NOT NULL COMMENT 'API 이름',
  `method` varchar(5) NOT NULL COMMENT 'SELECT, INSERT , DELETE, UPDATE',
  `menu_id` varchar(10) DEFAULT NULL COMMENT '메뉴 아이디',
  `pprr_eeno` varchar(20) NOT NULL,
  `fram_dtm` datetime NOT NULL,
  `updr_eeno` varchar(20) DEFAULT NULL,
  `mdfy_dtm` datetime DEFAULT NULL,
  PRIMARY KEY (`api_url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='API URL 관리용';

-- 테이블 데이터 hkomms.tb_api_mgmt:~38 rows (대략적) 내보내기
/*!40000 ALTER TABLE `tb_api_mgmt` DISABLE KEYS */;
INSERT INTO `tb_api_mgmt` (`api_url`, `api_nm`, `method`, `menu_id`, `pprr_eeno`, `fram_dtm`, `updr_eeno`, `mdfy_dtm`) VALUES
	('/changePgmMgmtUseYn', '메뉴 사용여부 변경', 'POST', '0023', 'H2212239', '2023-05-25 13:35:28', NULL, NULL),
	('/changeToken', '토큰교체', 'POST', '9999', 'H2212239', '2023-05-25 15:08:47', NULL, NULL),
	('/changeUserUseYn', '사용자 사용여부', 'POST', '0022', 'H2212239', '2023-05-25 13:24:16', NULL, NULL),
	('/codeCombo', '코드 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:07:42', NULL, NULL),
	('/grpCombo', '권한그룹 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:08:16', NULL, NULL),
	('/initUserPw', '비밀번호 초기화', 'POST', '0022', 'H2212239', '2023-05-25 13:38:37', NULL, NULL),
	('/ivm2WeekPlan', '2주 생산계획', 'GET', '0002', 'H2212239', '2023-05-25 15:10:57', NULL, NULL),
	('/ivm3DayPlan', '단기계획(3일)', 'GET', '0002', 'H2212239', '2023-05-25 15:14:42', NULL, NULL),
	('/ivmIvModInfos', '세원재고보정', 'POST', '0003', 'H2212239', '2023-05-25 15:21:51', NULL, NULL),
	('/ivmMonthOrdPrdInfos', '월간오더/생산정보', 'GET', '0002', 'H2212239', '2023-05-25 15:19:27', NULL, NULL),
	('/ivmNatlProdPlanInfos', '국가별생산정보', 'GET', '0002', 'H2212239', '2023-05-25 15:19:53', NULL, NULL),
	('/ivmOrderRequestInfos', '요청현황', 'GET', '0002', 'H2212239', '2023-05-25 15:20:32', NULL, NULL),
	('/ivmPdiIvInfos', 'PDI재고관리', 'GET', '0004', 'H2212239', '2023-05-25 15:23:22', NULL, NULL),
	('/ivmPdiOrYongsanIvs', 'PDI/용산재고', 'GET', '0002', 'H2212239', '2023-05-25 15:18:47', NULL, NULL),
	('/ivmPdiPrndMonitorInfo', '생산라인모니터링', 'GET', '0004', 'H2212239', '2023-05-25 15:23:46', NULL, NULL),
	('/ivmPdiWhsnInfo', '입고확인', 'GET', '0004', 'H2212239', '2023-05-25 15:24:07', 'H2212236', '2023-07-04 15:01:57'),
	('/ivmSeparatelyRequest', '별도요청 저장', 'POST', '0002', 'H2212239', '2023-05-25 15:10:30', NULL, NULL),
	('/ivmSewonIvmInfos', '세원재고관리', 'GET', '0003', 'H2212239', '2023-05-25 15:20:51', NULL, NULL),
	('/ivmSewonRequestInfos', '요청현황', 'GET', '0003', 'H2212239', '2023-05-25 15:22:28', NULL, NULL),
	('/ivmSewonWhotInfos', '출고현황입력 팝업', 'POST', '0003', 'H2212239', '2023-05-25 15:21:30', NULL, NULL),
	('/ivmSewonWhotInfos2', '출고현황', 'GET', '0003', 'H2212239', '2023-05-25 15:22:50', NULL, NULL),
	('/ivmThisMonTrwis', '당월투입(누적)', 'GET', '0002', 'H2212239', '2023-05-25 15:17:25', NULL, NULL),
	('/ivmTotIvInfos', '총재고관리 조회', 'GET', '0002', 'H2212239', '2023-05-24 09:45:36', NULL, NULL),
	('/ivmVehlIvInfos', '차종별재고분석', 'GET', '0002', 'H2212239', '2023-05-25 15:20:13', NULL, NULL),
	('/langCombo', '언어코드 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:06:26', NULL, NULL),
	('/mdyCombo', 'MDY코드 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:02:34', NULL, NULL),
	('/pdiCombo', 'PDI 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 13:52:35', 'H2212239', '2023-05-25 15:02:04'),
	('/pgmMgmts', '메뉴 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:09:13', NULL, NULL),
	('/pgmMgmtsAll', '메뉴관리용 목록조회', 'GET', '0023', 'H2212239', '2023-05-25 13:34:36', NULL, NULL),
	('/printOrderInfos', 'O/M발주 목록', 'GET', '0009', 'H2212239', '2023-05-25 15:24:53', NULL, NULL),
	('/printState', '발간현황 상세 / 저장', 'POST', '0011', 'H2212239', '2023-05-25 15:25:42', NULL, NULL),
	('/printStates', '발간현황 목록', 'GET', '0011', 'H2212239', '2023-05-25 15:25:19', NULL, NULL),
	('/regionCombo', '지역코드 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:05:54', NULL, NULL),
	('/sewonIvm', '세원재고관리 조회', 'GET', '0003', 'H2212239', '2023-05-24 09:47:10', NULL, NULL),
	('/subCdCombo', '재고상태 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:06:59', 'H2212239', '2023-05-25 15:07:12'),
	('/Test', '테스트', 'POST', '0029', 'H2302603', '2023-06-12 17:09:28', NULL, NULL),
	('/usrGrpMgmts', '사용자 권한그룹 목록조회', 'GET', '0022', 'H2212239', '2023-05-25 13:26:43', NULL, NULL),
	('/usrmgmt', '사용자 등록, 수정, 삭제, 조회', 'POST', '0022', 'H2212239', '2023-05-25 13:22:37', 'H2212239', '2023-05-25 13:31:54'),
	('/usrmgmts', '사용자정보 조회', 'GET', '0022', 'H2212239', '2023-05-24 09:47:10', NULL, NULL),
	('/vehlCombo', '차량코드 목록조회용', 'GET', '9999', 'H2212239', '2023-05-25 15:01:22', 'H2212239', '2023-05-25 15:02:10'),
	('ivmSewonIvs', '재고현황-세원보유재고', 'GET', '0002', 'H2212239', '2023-05-25 15:17:47', NULL, NULL);
/*!40000 ALTER TABLE `tb_api_mgmt` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
