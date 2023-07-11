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
  `menu_id` varchar(10) NOT NULL COMMENT '메뉴 아이디',
  `pprr_eeno` varchar(20) NOT NULL,
  `fram_dtm` datetime NOT NULL,
  `updr_eeno` varchar(20) DEFAULT NULL,
  `mdfy_dtm` datetime DEFAULT NULL,
  PRIMARY KEY (`api_url`,`method`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='API URL 관리용';

-- 테이블 데이터 hkomms.tb_api_mgmt:~122 rows (대략적) 내보내기
/*!40000 ALTER TABLE `tb_api_mgmt` DISABLE KEYS */;
INSERT INTO `tb_api_mgmt` (`api_url`, `api_nm`, `method`, `menu_id`, `pprr_eeno`, `fram_dtm`, `updr_eeno`, `mdfy_dtm`) VALUES
	('/boardAffrMgmt', '게시판 상세', 'GET', '0006', 'H2212239', '2023-07-10 15:40:55', NULL, NULL),
	('/boardAffrMgmt', '게시판 등록, 수정, 삭제', 'POST', '0006', 'H2212239', '2023-07-10 15:40:55', NULL, NULL),
	('/boardAffrMgmtReply', '게시판댓글 등록, 삭제', 'POST', '0006', 'H2212239', '2023-07-10 15:40:55', NULL, NULL),
	('/boardAffrMgmtReplys', '게시판댓글 목록', 'GET', '0006', 'H2212239', '2023-07-10 15:40:55', NULL, NULL),
	('/boardAffrMgmts', '게시판 목록', 'GET', '0006', 'H2212239', '2023-07-10 15:40:55', NULL, NULL),
	('/boardMgmt', '공지사항 조회', 'GET', '0020', 'H2212239', '2023-07-10 17:10:01', NULL, NULL),
	('/boardMgmt', '공지사항 등록', 'POST', '0020', 'H2212239', '2023-07-10 17:11:02', NULL, NULL),
	('/boardMgmts', '공지사항 목록조회', 'GET', '0020', 'H2212239', '2023-07-10 17:09:09', NULL, NULL),
	('/changePgmMgmtUseYn', '메뉴 사용여부 변경', 'POST', '0012', 'H2212239', '2023-05-25 13:35:28', NULL, NULL),
	('/changeToken', '토큰교체', 'POST', '0012', 'H2212239', '2023-05-25 15:08:47', NULL, NULL),
	('/changeUserPw', '비번변경', 'POST', '9999', 'H2212239', '2023-07-10 17:16:59', NULL, NULL),
	('/changeUserUseYn', '사용자 사용여부', 'POST', '0022', 'H2212239', '2023-05-25 13:24:16', NULL, NULL),
	('/checkUserEeno', '사용자아이디 중복조회', 'GET', '9999', 'H2212239', '2023-07-10 17:14:08', NULL, NULL),
	('/codeCombo', '코드 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:07:42', NULL, NULL),
	('/dlExpdPacScnCombo', '차종 승상코드콤보박스', 'GET', '0016', 'H2212239', '2023-07-10 16:19:54', NULL, NULL),
	('/dlExpdPrvsCombo', '차종 수신형태콤보박스', 'GET', '0016', 'H2212239', '2023-07-10 16:19:54', NULL, NULL),
	('/grpCombo', '권한그룹 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:08:16', NULL, NULL),
	('/initUserPw', '비밀번호 초기화', 'POST', '9999', 'H2212239', '2023-05-25 13:38:37', NULL, NULL),
	('/ivm2WeekPlan', '2주 생산계획', 'GET', '0002', 'H2212239', '2023-05-25 15:10:57', NULL, NULL),
	('/ivm3DayPlan', '단기계획(3일)', 'GET', '0002', 'H2212239', '2023-05-25 15:14:42', NULL, NULL),
	('/ivmIvModInfos', '재고보정입력 팝업', 'GET', '0003', 'H2212239', '2023-07-10 15:37:04', NULL, NULL),
	('/ivmIvModInfos', '세원재고보정', 'POST', '0003', 'H2212239', '2023-05-25 15:21:51', NULL, NULL),
	('/ivmMonthOrdPrdInfos', '월간오더/생산정보', 'GET', '0002', 'H2212239', '2023-05-25 15:19:27', NULL, NULL),
	('/ivmNatlProdPlanInfos', '국가별생산정보', 'GET', '0002', 'H2212239', '2023-05-25 15:19:53', NULL, NULL),
	('/ivmOrderRequestInfos', '요청현황', 'GET', '0002', 'H2212239', '2023-05-25 15:20:32', NULL, NULL),
	('/ivmPdiDlvtRequest', 'PDI재고 배송요청', 'POST', '0004', 'H2212239', '2023-07-10 15:36:35', NULL, NULL),
	('/ivmPdiIvInfos', 'PDI재고관리', 'GET', '0004', 'H2212239', '2023-05-25 15:23:22', NULL, NULL),
	('/ivmPdiOrderRequest', 'PDI재고 발주요청', 'POST', '0004', 'H2212239', '2023-07-10 15:36:32', NULL, NULL),
	('/ivmPdiOrYongsanIvs', 'PDI/용산재고', 'GET', '0004', 'H2212239', '2023-05-25 15:18:47', NULL, NULL),
	('/ivmPdiPrndMonitorInfo', '생산라인모니터링', 'GET', '0004', 'H2212239', '2023-05-25 15:23:46', NULL, NULL),
	('/ivmPdiRequestInfos', 'PDI재고 요청현황', 'GET', '0004', 'H2212239', '2023-07-10 15:36:25', NULL, NULL),
	('/ivmPdiWhsnInfo', '입고확인', 'GET', '0004', 'H2212239', '2023-05-25 15:24:07', 'H2212236', '2023-07-04 15:01:57'),
	('/ivmPdiWhsnInfo', 'PDI재고 입고확인 등록', 'POST', '0004', 'H2212239', '2023-07-10 15:36:38', NULL, NULL),
	('/ivmPdiWhsnStatInfos', 'PDI재고 입고현황 조회', 'GET', '0004', 'H2212239', '2023-07-10 15:36:29', NULL, NULL),
	('/ivmSeparatelyRequest', '별도요청 저장', 'POST', '0002', 'H2212239', '2023-05-25 15:10:30', NULL, NULL),
	('/ivmSewonIvmInfos', '세원재고관리', 'GET', '0003', 'H2212239', '2023-05-25 15:20:51', NULL, NULL),
	('/ivmSewonIvs', '재고현황-세원보유재고', 'GET', '0003', 'H2212239', '2023-07-10 15:37:07', NULL, NULL),
	('/ivmSewonPrintInfos', '세원재고 인쇄현황', 'GET', '0003', 'H2212239', '2023-07-10 15:37:13', NULL, NULL),
	('/ivmSewonPrintInfos', '세원재고 인쇄현황 수정', 'POST', '0003', 'H2212239', '2023-07-10 15:37:10', NULL, NULL),
	('/ivmSewonRequestInfos', '요청현황', 'GET', '0003', 'H2212239', '2023-05-25 15:22:28', NULL, NULL),
	('/ivmSewonWhotInfo', '세원재고관리 출고현황입력 팝업', 'GET', '0012', 'H2212239', '2023-07-10 15:37:24', NULL, NULL),
	('/ivmSewonWhotInfos', '출고현황입력 팝업', 'POST', '0003', 'H2212239', '2023-05-25 15:21:30', NULL, NULL),
	('/ivmSewonWhotInfos2', '출고현황', 'GET', '0003', 'H2212239', '2023-05-25 15:22:50', NULL, NULL),
	('/ivmThisMonTrwis', '당월투입(누적)', 'GET', '0002', 'H2212239', '2023-05-25 15:17:25', NULL, NULL),
	('/ivmTotIvInfos', '총재고관리 조회', 'GET', '0002', 'H2212239', '2023-05-24 09:45:36', NULL, NULL),
	('/ivmVehlIvInfos', '차종별재고분석', 'GET', '0002', 'H2212239', '2023-05-25 15:20:13', NULL, NULL),
	('/ivmYongsanIvmInfos', '용산재고관리 조회', 'GET', '0005', 'H2212239', '2023-07-10 15:35:44', NULL, NULL),
	('/ivmYsnRequestInfos', '용산 요청현황', 'GET', '0005', 'H2212239', '2023-07-10 15:35:30', NULL, NULL),
	('/langCombo', '언어코드 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:06:26', NULL, NULL),
	('/langCopys', '차종복사', 'GET', '0016', 'H2212239', '2023-07-10 16:19:54', NULL, NULL),
	('/langMgmt', '언어코드상세', 'GET', '0017', 'H2212239', '2023-07-10 16:23:16', NULL, NULL),
	('/langMgmt', '언어코드저장', 'POST', '0017', 'H2212239', '2023-07-10 16:23:58', NULL, NULL),
	('/langMgmts', '언어코드조회', 'GET', '0017', 'H2212239', '2023-07-10 16:23:03', NULL, NULL),
	('/langMgmtsCopy', '차종코드 복사목록', 'GET', '0017', 'H2212239', '2023-07-10 16:24:40', NULL, NULL),
	('/langMst', '언어마스터 상세', 'GET', '0017', 'H2212239', '2023-07-10 16:25:19', NULL, NULL),
	('/langMst', '언어마스터 등록', 'POST', '0017', 'H2212239', '2023-07-10 16:25:36', NULL, NULL),
	('/langMsts', '언어마스터 목록', 'GET', '0017', 'H2212239', '2023-07-10 16:25:03', NULL, NULL),
	('/mdyCombo', 'MDY코드 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:02:34', NULL, NULL),
	('/monthPutInfos', '월간투입현황', 'GET', '0011', 'H2212239', '2023-07-10 15:55:09', NULL, NULL),
	('/mriClcmInfo', '법규 및 변경관리 상세 조회', 'GET', '0008', 'H2212239', '2023-07-10 15:44:13', NULL, NULL),
	('/mriClcmInfoPop', '법규 및 변경관리 팝업 저장, 수정', 'POST', '0008', 'H2212239', '2023-07-10 15:44:13', NULL, NULL),
	('/mriClcmInfos', '법규 및 변경관리 목록 조회', 'GET', '0008', 'H2212239', '2023-07-10 15:44:13', NULL, NULL),
	('/mriClcmLangCdInfos', '법규 및 변경관리 수정 차종 별 언어 조회', 'GET', '0008', 'H2212239', '2023-07-10 15:44:02', NULL, NULL),
	('/mriDelClcmInfo', '법규 및 변경관리 삭제', 'POST', '0012', 'H2212239', '2023-07-10 15:44:13', NULL, NULL),
	('/natlCopys', '국가코드 복사 리스트', 'GET', '0018', 'H2212239', '2023-07-10 17:05:18', NULL, NULL),
	('/natlExcelUpload', '차종에 해당하는 엑셀 저장', 'POST', '0018', 'H2212239', '2023-07-10 17:06:12', NULL, NULL),
	('/natlLangMgmt', '국가별 언어코드상세', 'GET', '0018', 'H2212239', '2023-07-10 17:02:22', NULL, NULL),
	('/natlLangMgmt', '국가별 언어코드저장', 'POST', '0018', 'H2212239', '2023-07-10 17:03:10', NULL, NULL),
	('/natlLangMgmts', '국가별 언어코드목록', 'GET', '0018', 'H2212239', '2023-07-10 17:02:04', NULL, NULL),
	('/natlMdyCombo', '기존 국가별 연식별 조회(콤보박스)', 'GET', '0018', 'H2212239', '2023-07-10 17:05:01', NULL, NULL),
	('/natlMgmtPop', '국가코드 선택 팝업', 'GET', '0018', 'H2212239', '2023-07-10 17:03:28', NULL, NULL),
	('/natlMst', '국가코드 마스터 상세', 'GET', '0018', 'H2212239', '2023-07-10 17:04:22', NULL, NULL),
	('/natlMst', '국가코드 저장', 'POST', '0018', 'H2212239', '2023-07-10 17:04:43', NULL, NULL),
	('/natlMsts', '국가코드 마스터 목록', 'GET', '0018', 'H2212239', '2023-07-10 17:04:04', NULL, NULL),
	('/natlVehlDtList', '국가코드 상세-> 차종리스트', 'GET', '0018', 'H2212239', '2023-07-10 17:02:45', NULL, NULL),
	('/natlVehlList', '국가코드 추가 -> 차종리스트', 'GET', '0018', 'H2212239', '2023-07-10 17:03:46', NULL, NULL),
	('/natlVehlRegn', '차종에 해당하는 설정 지역정보', 'GET', '0018', 'H2212239', '2023-07-10 17:05:33', NULL, NULL),
	('/newPrntPbcnNoLrnkCdInfos', 'O/M발주 인쇄배열표 콤보박스', 'GET', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/outRequestChange', '납품요청일자 변경', 'POST', '0012', 'H2212239', '2023-07-10 15:55:29', NULL, NULL),
	('/pdiCombo', 'PDI 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 13:52:35', 'H2212239', '2023-05-25 15:02:04'),
	('/pgmMgmts', '메뉴 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:09:13', NULL, NULL),
	('/pgmMgmtsAll', '메뉴관리용 목록조회', 'GET', '0012', 'H2212239', '2023-05-25 13:34:36', NULL, NULL),
	('/printOrderClcmInfos', 'O/M발주 개정정보', 'GET', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderInfo', 'O/M 발주 등록', 'POST', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderInfoDelete', 'O/M 발주 삭제', 'POST', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderInfos', 'O/M발주 목록', 'GET', '0009', 'H2212239', '2023-05-25 15:24:53', NULL, NULL),
	('/printOrderInfos', 'O/M 발주 목록', 'POST', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderPageInfo', 'O/M발주 발간번호별 인쇄배열표', 'GET', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderPageInfo', '발간번호별 인쇄배열표 수정', 'POST', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderPrntPbcnNoInfos', 'O/M발주 발간번호코드정보', 'GET', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printOrderReqInfo', 'O/M발주 발간번호별 세부내역', 'GET', '0009', 'H2212239', '2023-07-10 15:50:10', NULL, NULL),
	('/printState', '발간현황상세', 'GET', '0012', 'H2212239', '2023-07-10 15:55:29', NULL, NULL),
	('/printState', '발간현황 상세 / 저장', 'POST', '0012', 'H2212239', '2023-05-25 15:25:42', NULL, NULL),
	('/printStates', '발간현황 목록', 'GET', '0012', 'H2212239', '2023-05-25 15:25:19', NULL, NULL),
	('/prntAlgnPop', '인쇄배열표', 'GET', '0012', 'H2212239', '2023-07-10 15:55:29', NULL, NULL),
	('/prntPageMgmt', '인쇄페이지관리 상세 조회', 'GET', '0019', 'H2212239', '2023-07-10 17:07:05', NULL, NULL),
	('/prntPageMgmt', '인쇄페이지 관리 저장', 'POST', '0019', 'H2212239', '2023-07-10 17:07:25', NULL, NULL),
	('/prntPageMgmts', '인쇄페이지관리 조회', 'GET', '0019', 'H2212239', '2023-07-10 17:06:48', NULL, NULL),
	('/qltyVehlMdyCombo', '기존 차종 연식별 조회(콤보박스)', 'GET', '0016', 'H2212239', '2023-07-10 16:19:54', NULL, NULL),
	('/regionCombo', '지역코드 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:05:54', NULL, NULL),
	('/savePrintCostInputNo', '인쇄품의번호 입력', 'POST', '0012', 'H2212239', '2023-07-10 15:55:29', NULL, NULL),
	('/savePrntBgt', '인쇄비용 입력', 'POST', '0012', 'H2212239', '2023-07-10 15:55:29', NULL, NULL),
	('/selectBoardModal', '공지사항 추가 모달', 'GET', '0020', 'H2212239', '2023-07-10 17:09:26', NULL, NULL),
	('/sewonIvm', '세원재고관리 조회', 'GET', '0012', 'H2212239', '2023-05-24 09:47:10', NULL, NULL),
	('/subCdCombo', '재고상태 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:06:59', 'H2212239', '2023-05-25 15:07:12'),
	('/Test', '테스트', 'POST', '0012', 'H2302603', '2023-06-12 17:09:28', NULL, NULL),
	('/updRegnCd', '차종에 해당하는 지역설정 저장', 'POST', '0018', 'H2212239', '2023-07-10 17:05:59', NULL, NULL),
	('/userVehls', '사용자 차종권한 리스트', 'GET', '0022', 'H2212239', '2023-07-10 17:15:09', NULL, NULL),
	('/usrAndVehls', '사용자 & 차종권한 리스트', 'GET', '0022', 'H2212239', '2023-07-10 17:15:36', NULL, NULL),
	('/usrGrpMgmts', '사용자 권한그룹 목록조회', 'GET', '0012', 'H2212239', '2023-05-25 13:26:43', NULL, NULL),
	('/usrmgmt', '사용자 정보 조회', 'GET', '0022', 'H2212239', '2023-07-10 17:13:33', NULL, NULL),
	('/usrmgmt', '사용자 등록, 수정, 삭제, 조회', 'POST', '0022', 'H2212239', '2023-05-25 13:22:37', 'H2212239', '2023-05-25 13:31:54'),
	('/usrmgmts', '사용자정보 조회', 'GET', '0022', 'H2212239', '2023-05-24 09:47:10', NULL, NULL),
	('/vehlCombo', '차량코드 목록조회용', 'GET', '0012', 'H2212239', '2023-05-25 15:01:22', 'H2212239', '2023-05-25 15:02:10'),
	('/vehlMdyMgmt', '차종연식 상세', 'GET', '0016', 'H2212239', '2023-07-10 16:20:39', NULL, NULL),
	('/vehlMdyMgmt', '차종연식 관리저장', 'POST', '0016', 'H2212239', '2023-07-10 16:20:39', NULL, NULL),
	('/vehlMdyMgmts', '차종연식 조회', 'GET', '0016', 'H2212239', '2023-07-10 16:20:35', NULL, NULL),
	('/vehlMgmt', '차종 상세조회', 'GET', '0016', 'H2212239', '2023-07-10 16:22:02', NULL, NULL),
	('/vehlMgmt', '차종 관리 등록', 'POST', '0016', 'H2212239', '2023-07-10 16:20:24', NULL, NULL),
	('/vehlMgmtExcelList', '차종관리 엑실다운로드', 'GET', '0016', 'H2212239', '2023-07-10 16:20:31', NULL, NULL),
	('/vehlMgmts', '차종 조회', 'GET', '0016', 'H2212239', '2023-07-10 16:19:54', NULL, NULL),
	('ivmSewonIvs', '재고현황-세원보유재고', 'GET', '0003', 'H2212239', '2023-05-25 15:17:47', NULL, NULL);
/*!40000 ALTER TABLE `tb_api_mgmt` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
