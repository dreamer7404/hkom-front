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

-- 함수 hkomms.FU_CHECK_RDCS_ST_CD 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_CHECK_RDCS_ST_CD`(P_N_PRNT_PBCN_NO VARCHAR(100),
														P_STATE VARCHAR(1),
														P_RDCS_ST_CD VARCHAR(2)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_CHECK_RDCS_ST_CD
 * Function 설명 : 제작의뢰 정보 저장시의 상태값 체크하는 함수
 * 입력 파라미터    : P_N_PRNT_PBCN_NO    신인쇄발간번호
 *                P_STATE			  상태 S저장 Q승인의뢰 C승인 R반려 W취소  외 삭제
 *                P_RDCS_ST_CD        결재상태코드
 * 리턴값         : V_RETURN            처리결과(Y) 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     안상천   최초 전환함
 ****************************************************************************/		
	DECLARE V_RETURN CHAR(1);

		   SET V_RETURN = 'Y';
		   
		   SELECT MAX(DL_EXPD_RDCS_ST_CD) INTO P_RDCS_ST_CD
		   FROM TB_PRNT_BKGD_INFO
		   WHERE N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;
		   
		   /*제작의뢰의 저장인 경우 */
		   IF P_STATE = 'S' THEN
			  IF P_RDCS_ST_CD  IS NULL  OR P_RDCS_ST_CD IN ('03', '05') THEN
				 SET V_RETURN = 'Y';
			  	 SET P_RDCS_ST_CD = '05';
			  END IF;
		   /*제작의뢰의 승인의뢰인 경우  */
		   ELSEIF P_STATE = 'Q' THEN
		   	  /*신규작성, 반려, 저장된 항목은 승인의뢰 할 수  있다. */
			  IF P_RDCS_ST_CD  IS NULL OR P_RDCS_ST_CD IN ('03', '05') THEN
				 SET V_RETURN = 'Y';
				 IF P_RDCS_ST_CD = '03' THEN
					 SET P_RDCS_ST_CD = '04';
				  ELSE
					 SET P_RDCS_ST_CD = '01';
				  END IF;
			  END IF;
		   /*발주/승인의 승인인 경우  */
		   ELSEIF P_STATE = 'C' THEN
			  /*의뢰, 재의뢰 된 항목은 승인할 수 있다. */
			  IF P_RDCS_ST_CD IN ('01', '04') THEN
				 SET V_RETURN = 'Y';
				 SET P_RDCS_ST_CD = '02';
			  END IF;
		   /*발주/승인의 반려인 경우  */
		   ELSEIF P_STATE = 'R' THEN
			  /*의뢰, 재의뢰 된 항목은 반려 할 수 있다. */
			  IF P_RDCS_ST_CD IN ('01', '04') THEN
				 SET V_RETURN = 'Y';
				 SET P_RDCS_ST_CD = '03';
			  END IF;
		   /*승인 취소인 경우  */
		   ELSEIF P_STATE = 'W'  THEN
			  /*승인된 항목만 취소할 수 있다. */
			  IF P_RDCS_ST_CD IN ('02') THEN
				 SET V_RETURN = 'Y';
				 SET P_RDCS_ST_CD = '01';
			  END IF;
		   /*삭제인 경우 	   */
		   ELSE 
			 /*반려, 저장된 항목은  삭제가 가능한다.  */
			 IF P_RDCS_ST_CD IN ('03', '05') THEN
				 SET V_RETURN = 'Y';
			  END IF;
		   END IF;
		   RETURN V_RETURN;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_LANG_LIST 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_LANG_LIST`(P_EXPD_CO_CD 		VARCHAR(30), 
			  		   					    P_EXPD_NAT_CD	    VARCHAR(30),
			  		   					    P_QLTY_VEHL_CD	    VARCHAR(30),
										    P_MDL_MDY_CD    VARCHAR(30)) RETURNS varchar(8000) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_LANG_LIST
 * Function 설명 : 취급설명서 국가코드, 차종, 연식에 해당하는 언어코드 내역 리턴하는 함수
 * 입력 파라미터    : P_EXPD_CO_CD      취급설명서회사코드
 *                P_EXPD_NAT_CD     취급설명서국가코드
 *                P_QLTY_VEHL_CD    품질차종코드
 *                P_MDL_MDY_CD      모델연식코드
 * 리턴값         : V_LANG_LIST       취급설명서 국가코드, 차종, 연식에 해당하는 언어코드에 해당되는 언어코드목록 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-04     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE V_LANG_LIST VARCHAR(8000);

	DECLARE i		INT;

	DECLARE V_LANG_CD_1 VARCHAR(30);

	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE NATL_LANG_LIST CURSOR FOR
                                  SELECT LANG_CD
	   	                          FROM TB_NATL_LANG_MGMT
								  WHERE DL_EXPD_CO_CD = P_EXPD_CO_CD
								  AND DL_EXPD_NAT_CD = P_EXPD_NAT_CD
								  AND QLTY_VEHL_CD = P_QLTY_VEHL_CD
								  AND MDL_MDY_CD = P_MDL_MDY_CD;
								 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/
	SET V_LANG_LIST = '';
	
	OPEN NATL_LANG_LIST; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH NATL_LANG_LIST INTO V_LANG_CD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

	IF LENGTH(V_LANG_CD_1) > 0 THEN
		SET V_LANG_LIST = CONCAT(V_LANG_LIST , V_LANG_CD_1 , ',');
	END IF;

	END LOOP JOBLOOP1 ;
	CLOSE NATL_LANG_LIST;

   	IF LENGTH(V_LANG_LIST) > 0 THEN	   
	   	  SET V_LANG_LIST = CONCAT(SUBSTR(V_LANG_LIST, 1, LENGTH(V_LANG_LIST) - 1));    
   	END IF;
   	RETURN V_LANG_LIST;

END//
DELIMITER ;

-- 함수 hkomms.FU_GET_LANG_LIST_BY_VEHL 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_LANG_LIST_BY_VEHL`(P_EXPD_ALTR_NO VARCHAR(100),
                                                	P_QLTY_VEHL_CD VARCHAR(100)) RETURNS varchar(8000) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_LANG_LIST_BY_VEHL
 * Function 설명 : 변경번호, 차종에 관계된  언어코드 리스트를 얻어오는 함수
 * 입력 파라미터    : P_EXPD_ALTR_NO  취급설명서변경번호
 *                P_QLTY_VEHL_CD  품질차종코드
 * 리턴값         : V_LANG_LIST     취급설명서변경번호와 품질차종코드에 해당 되는 언어코드를
 *                                TB_CHKLIST_DTL_INFO(체크리스트변경상세정보)에서
 *								  조회하여 ','로 구분하여 하나의 변수에 담아 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/	
	DECLARE V_LANG_LIST VARCHAR(8000);
	DECLARE V_LANG_CD VARCHAR(30);
	DECLARE V_LANG_CD_1 VARCHAR(30);
	DECLARE i		INT; 
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE CHK_DTL_LANG_LIST CURSOR FOR
									SELECT LANG_CD
	   	                            FROM TB_CHKLIST_DTL_INFO
									WHERE DL_EXPD_ALTR_NO = P_EXPD_ALTR_NO
									AND QLTY_VEHL_CD = P_QLTY_VEHL_CD
									GROUP BY LANG_CD
									ORDER BY LANG_CD;		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/						
	SET V_LANG_LIST = '';

	OPEN CHK_DTL_LANG_LIST; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH CHK_DTL_LANG_LIST INTO V_LANG_CD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

		SET V_LANG_LIST = CONCAT(V_LANG_LIST, V_LANG_CD_1, ',');		

	END LOOP JOBLOOP1 ;
	CLOSE CHK_DTL_LANG_LIST;
	
	IF LENGTH(V_LANG_LIST) > 0 THEN		   
		SET V_LANG_LIST = SUBSTR(V_LANG_LIST, 1, LENGTH(V_LANG_LIST) - 1);		   
	END IF;		

	RETURN V_LANG_LIST;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_MAX_YMDHM 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_MAX_YMDHM`(P_PAC_SCN_CD          VARCHAR(30),
			  		   					    P_PDI_CD	          VARCHAR(30),
										    P_LANG_CD			  VARCHAR(30),
										    P_TH9_POW_FNH_YMDHM   VARCHAR(16),
											P_TH10_POW_FNH_YMDHM  VARCHAR(16),
											P_TH11_POW_FNH_YMDHM  VARCHAR(16),
											P_TH12_POW_FNH_YMDHM  VARCHAR(16),
											P_TH13_POW_FNH_YMDHM  VARCHAR(16),
											P_TH14_POW_FNH_YMDHM  VARCHAR(16),
											P_TH15_POW_FNH_YMDHM  VARCHAR(16),
											P_TH16_POW_FNH_YMDHM  VARCHAR(16)) RETURNS varchar(20) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_MAX_YMDHM
 * Function 설명 : 9공정부터 16공정까지 투입전 공정 사이의 최대 시각 얻어오는 함수
 * 입력 파라미터    : P_PAC_SCN_CD                   승상구분코드(01 승용, 02 상용)
 *                P_PDI_CD                       PDI코드(01 울산, 02 아산,03 화성, 04 광주)
 *                P_LANG_CD                      언어코드(KO 한글/국내, EU 영어/미국,..)
 *                P_TH9_POW_FNH_YMDHM            9번째공정종료년월일시분
 *                P_TH10_POW_FNH_YMDHM           10번째공정종료년월일시분
 *                P_TH11_POW_FNH_YMDHM           11번째공정종료년월일시분
 *                P_TH12_POW_FNH_YMDHM           12번째공정종료년월일시분
 *                P_TH13_POW_FNH_YMDHM           13번째공정종료년월일시분
 *                P_TH14_POW_FNH_YMDHM           14번째공정종료년월일시분
 *                P_TH15_POW_FNH_YMDHM           15번째공정종료년월일시분
 *                P_TH16_POW_FNH_YMDHM           16번째공정종료년월일시분
 * 리턴값         : V_POW_FNH_YMDHM                국내인 경우에는 9~16공정종료년월일시분 중에
 *								                 가장 큰 공정종료년월일시분을 리턴
 *								                 국내가 아닌 경우에는
 *								                 승용인 경우에는 광주는 9/10/11중 가장 큰 종료년월일시분을 리턴,
 *								                 그외는 9/10중에 가장 큰 종료년월일시분을 리턴함
 *								                 상용인 경우에는 9/10/11중 가장 큰 종료년월일시분을 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-03     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE V_POW_FNH_YMDHM VARCHAR(16);	   		
	SET V_POW_FNH_YMDHM = '0000/00/00 00:00';
	
	IF P_TH9_POW_FNH_YMDHM IS NOT NULL THEN		  	 
	   SET V_POW_FNH_YMDHM = P_TH9_POW_FNH_YMDHM;			 
	END IF;
	   
	IF P_LANG_CD = 'KO' THEN	   
	   IF P_TH10_POW_FNH_YMDHM IS NOT NULL THEN	   
	      IF V_POW_FNH_YMDHM < P_TH10_POW_FNH_YMDHM THEN		  	 
	          SET V_POW_FNH_YMDHM = P_TH10_POW_FNH_YMDHM;		  
		  END IF;			 
	   END IF;
		  
	   IF P_TH11_POW_FNH_YMDHM IS NOT NULL THEN	   
		  IF V_POW_FNH_YMDHM < P_TH11_POW_FNH_YMDHM THEN		  	 
		      SET V_POW_FNH_YMDHM = P_TH11_POW_FNH_YMDHM;		  
		  END IF;			 
	   END IF;
	   
	   IF P_TH12_POW_FNH_YMDHM IS NOT NULL THEN	   
		  IF V_POW_FNH_YMDHM < P_TH12_POW_FNH_YMDHM THEN		  	 
	          SET V_POW_FNH_YMDHM = P_TH12_POW_FNH_YMDHM;		  
		  END IF;			 
	   END IF;
		  
	   IF P_TH13_POW_FNH_YMDHM IS NOT NULL THEN	   
		  IF V_POW_FNH_YMDHM < P_TH13_POW_FNH_YMDHM THEN		  	 
		      SET V_POW_FNH_YMDHM = P_TH13_POW_FNH_YMDHM;		   
		  END IF;			 
	   END IF;
	   
	   IF P_TH14_POW_FNH_YMDHM IS NOT NULL THEN	   
		  IF V_POW_FNH_YMDHM < P_TH14_POW_FNH_YMDHM THEN		  	 
		      SET V_POW_FNH_YMDHM = P_TH14_POW_FNH_YMDHM;		   
		  END IF;			 
	   END IF;
	   
	   IF P_TH15_POW_FNH_YMDHM IS NOT NULL THEN	   
		  IF V_POW_FNH_YMDHM < P_TH15_POW_FNH_YMDHM THEN		  	 
		      SET V_POW_FNH_YMDHM = P_TH15_POW_FNH_YMDHM;		   
		  END IF;			 
	   END IF;
	   
	    IF P_TH16_POW_FNH_YMDHM IS NOT NULL THEN		
		   IF V_POW_FNH_YMDHM < P_TH16_POW_FNH_YMDHM THEN		  	 
		       SET V_POW_FNH_YMDHM = P_TH16_POW_FNH_YMDHM;		   
		   END IF;		   	 
	   END IF;	   	  
	ELSE		
		IF P_PAC_SCN_CD = '01' THEN	   
	   	   IF P_PDI_CD = '04' THEN	   	  
		   	  IF P_TH10_POW_FNH_YMDHM IS NOT NULL THEN			  
	          	 IF V_POW_FNH_YMDHM < P_TH10_POW_FNH_YMDHM THEN		  	 
	                 SET V_POW_FNH_YMDHM = P_TH10_POW_FNH_YMDHM;				  
				 END IF;			 
	          END IF;
		  
	          IF P_TH11_POW_FNH_YMDHM IS NOT NULL THEN	             
		         IF V_POW_FNH_YMDHM < P_TH11_POW_FNH_YMDHM THEN		  	 
		             SET V_POW_FNH_YMDHM = P_TH11_POW_FNH_YMDHM;				 
				 END IF;			 
	          END IF;		  
	       ELSE	   	  
		      IF P_TH10_POW_FNH_YMDHM IS NOT NULL THEN			  
	             IF V_POW_FNH_YMDHM < P_TH10_POW_FNH_YMDHM THEN		  	 
	                 SET V_POW_FNH_YMDHM = P_TH10_POW_FNH_YMDHM;					 
				 END IF;			 
	          END IF;		  
	       END IF;	   
	   ELSE	       
		   IF P_TH10_POW_FNH_YMDHM IS NOT NULL THEN			  
	          IF V_POW_FNH_YMDHM < P_TH10_POW_FNH_YMDHM THEN		  	 
	              SET V_POW_FNH_YMDHM = P_TH10_POW_FNH_YMDHM;				  
			  END IF;			 
	       END IF;
		  
	       IF P_TH11_POW_FNH_YMDHM IS NOT NULL THEN	             
		      IF V_POW_FNH_YMDHM < P_TH11_POW_FNH_YMDHM THEN		  	 
		          SET V_POW_FNH_YMDHM = P_TH11_POW_FNH_YMDHM;				 
			  END IF;			 
	       END IF;			  
	   END IF;
	END IF;
	
	IF V_POW_FNH_YMDHM = '0000/00/00 00:00' THEN	   
	   SET V_POW_FNH_YMDHM = '';	   
	END IF;			
	RETURN V_POW_FNH_YMDHM;

END//
DELIMITER ;

-- 함수 hkomms.FU_GET_MIN_YMDHM 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_MIN_YMDHM`(P_PAC_SCN_CD          VARCHAR(30),
		  		   						P_PDI_CD	          VARCHAR(30),
										P_LANG_CD			  VARCHAR(30),
										P_TH9_POW_STRT_YMDHM  VARCHAR(16),
										P_TH10_POW_STRT_YMDHM VARCHAR(16),
										P_TH11_POW_STRT_YMDHM VARCHAR(16),
										P_TH12_POW_STRT_YMDHM VARCHAR(16),
										P_TH13_POW_STRT_YMDHM VARCHAR(16),
										P_TH14_POW_STRT_YMDHM VARCHAR(16),
										P_TH15_POW_STRT_YMDHM VARCHAR(16),
										P_TH16_POW_STRT_YMDHM VARCHAR(16)) RETURNS varchar(16) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_MIN_YMDHM
 * Function 설명 : 9공정부터 16공정까지 투입전 공정 사이의 최소 시각 얻어오는 함수
 * 입력 파라미터    : P_PAC_SCN_CD                   승상구분코드(01 승용, 02 상용)
 *                P_PDI_CD                       PDI코드(01 울산, 02 아산,03 화성, 04 광주)
 *                P_LANG_CD                      언어코드(KO 한글/국내, EU 영어/미국,..)
 *                P_TH9_POW_STRT_YMDHM           9번째공정시작년월일시분
 *                P_TH10_POW_STRT_YMDHM          10번째공정시작년월일시분
 *                P_TH11_POW_STRT_YMDHM          11번째공정시작년월일시분
 *                P_TH12_POW_STRT_YMDHM          12번째공정시작년월일시분
 *                P_TH13_POW_STRT_YMDHM          13번째공정시작년월일시분
 *                P_TH14_POW_STRT_YMDHM          14번째공정시작년월일시분
 *                P_TH15_POW_STRT_YMDHM          15번째공정시작년월일시분
 *                P_TH16_POW_STRT_YMDHM          16번째공정시작년월일시분
 * 리턴값         : V_POW_STRT_YMDHM               국내인 경우에는 9~16공정시작년월일시분 중에
 *								                 가장 작은 공정시작년월일시분을 리턴
 *								                 국내가 아닌 경우에는
 *								                 승용인 경우에는 광주는 9/10/11중 가장 작은 시작년월일시분을 리턴,
 *								                 그외는 9/10중에 가장 작은 시작년월일시분을 리턴함
 *								                 상용인 경우에는 9/10/11중 가장 작은 시작년월일시분을 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-03     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE V_POW_STRT_YMDHM VARCHAR(16);	   		
	SET V_POW_STRT_YMDHM = '9999/12/31 23:59';
	
	IF P_TH9_POW_STRT_YMDHM IS NOT NULL THEN		  	 
	    SET V_POW_STRT_YMDHM = P_TH9_POW_STRT_YMDHM;			 
	END IF;
	   
	IF P_LANG_CD = 'KO' THEN	   
	   IF P_TH10_POW_STRT_YMDHM IS NOT NULL THEN	   
	      IF V_POW_STRT_YMDHM > P_TH10_POW_STRT_YMDHM THEN		  	 
	          SET V_POW_STRT_YMDHM = P_TH10_POW_STRT_YMDHM;		  
		  END IF;			 
	   END IF;
		  
	   IF P_TH11_POW_STRT_YMDHM IS NOT NULL THEN	   
		  IF V_POW_STRT_YMDHM > P_TH11_POW_STRT_YMDHM THEN		  	 
		      SET V_POW_STRT_YMDHM = P_TH11_POW_STRT_YMDHM;		  
		  END IF;			 
	   END IF;
	   
	   IF P_TH12_POW_STRT_YMDHM IS NOT NULL THEN	   
		  IF V_POW_STRT_YMDHM > P_TH12_POW_STRT_YMDHM THEN		  	 
	          SET V_POW_STRT_YMDHM = P_TH12_POW_STRT_YMDHM;		  
		  END IF;			 
	   END IF;
		  
	   IF P_TH13_POW_STRT_YMDHM IS NOT NULL THEN	   
		  IF V_POW_STRT_YMDHM > P_TH13_POW_STRT_YMDHM THEN		  	 
		      SET V_POW_STRT_YMDHM = P_TH13_POW_STRT_YMDHM;		   
		  END IF;			 
	   END IF;
	   
	   IF P_TH14_POW_STRT_YMDHM IS NOT NULL THEN	   
		  IF V_POW_STRT_YMDHM > P_TH14_POW_STRT_YMDHM THEN		  	 
		      SET V_POW_STRT_YMDHM = P_TH14_POW_STRT_YMDHM;		   
		  END IF;			 
	   END IF;
	   
	   IF P_TH15_POW_STRT_YMDHM IS NOT NULL THEN	   
		  IF V_POW_STRT_YMDHM > P_TH15_POW_STRT_YMDHM THEN		  	 
		      SET V_POW_STRT_YMDHM = P_TH15_POW_STRT_YMDHM;		   
		  END IF;			 
	   END IF;
	   
	    IF P_TH16_POW_STRT_YMDHM IS NOT NULL THEN		
		   IF V_POW_STRT_YMDHM > P_TH16_POW_STRT_YMDHM THEN		  	 
		       SET V_POW_STRT_YMDHM = P_TH16_POW_STRT_YMDHM;		   
		   END IF;		   	 
	   END IF;	   	  
	ELSE		
		IF P_PAC_SCN_CD = '01' THEN	   
	   	   IF P_PDI_CD = '04' THEN	   	  
		   	  IF P_TH10_POW_STRT_YMDHM IS NOT NULL THEN			  
	          	 IF V_POW_STRT_YMDHM > P_TH10_POW_STRT_YMDHM THEN		  	 
	                 SET V_POW_STRT_YMDHM = P_TH10_POW_STRT_YMDHM;				  
				 END IF;			 
	          END IF;
		  
	          IF P_TH11_POW_STRT_YMDHM IS NOT NULL THEN	             
		         IF V_POW_STRT_YMDHM > P_TH11_POW_STRT_YMDHM THEN		  	 
		             SET V_POW_STRT_YMDHM = P_TH11_POW_STRT_YMDHM;				 
				 END IF;			 
	          END IF;		  
	       ELSE	   	  
		      IF P_TH10_POW_STRT_YMDHM IS NOT NULL THEN			  
	             IF V_POW_STRT_YMDHM > P_TH10_POW_STRT_YMDHM THEN		  	 
	                 SET V_POW_STRT_YMDHM = P_TH10_POW_STRT_YMDHM;					 
				 END IF;			 
	          END IF;		  
	       END IF;	   
	   ELSE	       
		   IF P_TH10_POW_STRT_YMDHM IS NOT NULL THEN			  
	          IF V_POW_STRT_YMDHM > P_TH10_POW_STRT_YMDHM THEN		  	 
	              SET V_POW_STRT_YMDHM = P_TH10_POW_STRT_YMDHM;				  
			  END IF;			 
	       END IF;
		  
	       IF P_TH11_POW_STRT_YMDHM IS NOT NULL THEN	             
		      IF V_POW_STRT_YMDHM > P_TH11_POW_STRT_YMDHM THEN		  	 
		         SET V_POW_STRT_YMDHM = P_TH11_POW_STRT_YMDHM;				 
			  END IF;			 
	       END IF;			  
	   END IF;	
	END IF;
	
	IF V_POW_STRT_YMDHM = '9999/12/31 23:59' THEN	   
	  SET  V_POW_STRT_YMDHM = '';	   
	END IF;
	
	RETURN V_POW_STRT_YMDHM;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_PBCN_LIST_BY_VEHL 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_PBCN_LIST_BY_VEHL`(P_EXPD_ALTR_NO VARCHAR(100),
                                                P_QLTY_VEHL_CD VARCHAR(100)) RETURNS varchar(8000) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_PBCN_LIST_BY_VEHL
 * Function 설명 : 변경번호, 차종에 관계된  신인쇄발간코드 리스트를 얻어오는 함수
 *                언어와 신인쇄발간코드를 - 로 구분지어서 표시해 준다.
 * 입력 파라미터    : P_EXPD_ALTR_NO  취급설명서변경번호
 *                P_QLTY_VEHL_CD  품질차종코드
 * 리턴값         : V_PBCN_LIST     취급설명서변경번호와 품질차종코드에 해당 되는 언어코드와 신인쇄발간번호를
 *                                TB_CHKLIST_DTL_INFO(체크리스트변경상세정보)에서
 *								  조회하여 두 컬럼간'-'로 구분하고 조회되는 목록정보를 ','로 묶어 하나의 변수에 담아 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE V_PBCN_LIST VARCHAR(8000);
	DECLARE V_LANG_CD VARCHAR(30);
	DECLARE V_N_PRNT_PBCN_NO VARCHAR(30);
	DECLARE V_LANG_CD_1 VARCHAR(30);
	DECLARE V_N_PRNT_PBCN_NO_1 VARCHAR(30);
	DECLARE i		INT; 
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE CHK_DTL_PBCN_LIST CURSOR FOR
									SELECT LANG_CD, IFNULL(SUBSTR(MAX(N_PRNT_PBCN_NO), -3), '') AS N_PRNT_PBCN_NO
	   	                            FROM TB_CHKLIST_DTL_INFO
									WHERE DL_EXPD_ALTR_NO = P_EXPD_ALTR_NO
									AND QLTY_VEHL_CD = P_QLTY_VEHL_CD
									GROUP BY LANG_CD
									ORDER BY LANG_CD;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/				
	SET V_PBCN_LIST = '';

	OPEN CHK_DTL_PBCN_LIST; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH CHK_DTL_PBCN_LIST INTO V_LANG_CD_1,V_N_PRNT_PBCN_NO_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
	
		SET V_PBCN_LIST = CONCAT(V_PBCN_LIST, V_LANG_CD_1, '-', V_N_PRNT_PBCN_NO_1, ',');	

	END LOOP JOBLOOP1 ;
	CLOSE CHK_DTL_PBCN_LIST;
		
	IF LENGTH(V_PBCN_LIST) > 0 THEN		   
		SET V_PBCN_LIST = SUBSTR(V_PBCN_LIST, 1, LENGTH(V_PBCN_LIST) - 1);		   
	END IF;

	RETURN V_PBCN_LIST;							

END//
DELIMITER ;

-- 함수 hkomms.FU_GET_PDI_IV_TEXT 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_PDI_IV_TEXT`(P_CURR_YMD   VARCHAR(30),
		  		   						    P_VEHL_CD    VARCHAR(30),
										    P_MDL_MDY_CD VARCHAR(30),
										    P_LANG_CD	 VARCHAR(30)) RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_PDI_IV_TEXT
 * Function 설명 : 세원 차종연식에 소속된 취급설명서 연식의 재고수량을 이전연식부터 문자형태로 표현해서 리턴하는 함수
 * 입력 파라미터    : P_CURR_YMD    마감년월일
 *                P_VEHL_CD     품질차종코드
 *                P_MDL_MDY_CD  모델연식코드
 *                P_LANG_CD     언어코드
 * 리턴값         : V_IV_QTY_TEXT   TB_PDI_IV_INFO_DTL(PDI재고정보상세)에서
 *                                넘겨받은 마감년월일,품질차종코드,모델연식코드,언어코드에 해당되는
 *								  정보를 모델연식코드별로 취급설명서모델연식코드와 재고수량, 안전재고수량을 조합하여 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-03     안상천   표준화를 위해 변경
 ****************************************************************************/	
	DECLARE V_IV_QTY_TEXT VARCHAR(100);	
	DECLARE V_DL_EXPD_MDL_MDY_CD VARCHAR(30);
	DECLARE V_IV_QTY INT;
	DECLARE V_SFTY_IV_QTY INT;
	DECLARE i				INT;
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_IV_QTY_1 INT;
	DECLARE V_SFTY_IV_QTY_1 INT;
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE PDI_IV_DTL_LIST_INFO CURSOR FOR
										SELECT DL_EXPD_MDL_MDY_CD,
		   						  	      		CASE WHEN DL_EXPD_MDL_MDY_CD = P_MDL_MDY_CD THEN SUM(IV_QTY) ELSE SUM(SFTY_IV_QTY) END AS IV_QTY,
										  		CASE WHEN DL_EXPD_MDL_MDY_CD = P_MDL_MDY_CD THEN SUM(SFTY_IV_QTY - IV_QTY) ELSE 0 END AS SFTY_IV_QTY
         							   	FROM TB_PDI_IV_INFO_DTL
		   							   	WHERE CLS_YMD = P_CURR_YMD
		   							   	AND QLTY_VEHL_CD = P_VEHL_CD
		   							   	AND MDL_MDY_CD = P_MDL_MDY_CD
		   							   	AND LANG_CD = P_LANG_CD
           							   	GROUP BY DL_EXPD_MDL_MDY_CD;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/
	
	SET V_IV_QTY_TEXT = '';

	OPEN PDI_IV_DTL_LIST_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_DTL_LIST_INFO INTO V_DL_EXPD_MDL_MDY_CD_1,V_IV_QTY_1,V_SFTY_IV_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
			IF V_IV_QTY_1 > 0 THEN		   	  
				SET V_IV_QTY_TEXT = CONCAT(V_IV_QTY_TEXT, 
			  				   			   V_DL_EXPD_MDL_MDY_CD_1, 'MY:', 
			  						   	   FORMAT(V_IV_QTY_1, '0'), 
										   (CASE WHEN V_SFTY_IV_QTY_1 < 0 THEN CONCAT('(타연식:', FORMAT(V_SFTY_IV_QTY_1, '0'), ')') ELSE '' END), ' ');
			END IF;	

	END LOOP JOBLOOP1 ;
	CLOSE PDI_IV_DTL_LIST_INFO;
  
   	IF LENGTH(V_IV_QTY_TEXT) > 0 THEN	   
	   	  SET V_IV_QTY_TEXT = CONCAT(SUBSTR(V_IV_QTY_TEXT, 1, LENGTH(V_IV_QTY_TEXT) - 1));    
   	END IF;
   	RETURN V_IV_QTY_TEXT;   
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_PRV1DAY_INCL_HOLIDAY 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_PRV1DAY_INCL_HOLIDAY`(P_CURR_YMD VARCHAR(20)) RETURNS varchar(8) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_PRV1DAY_INCL_HOLIDAY
 * Function 설명 : P_CURR_YMD 날짜에서 휴일을 고려한 하루 전 일자를 리턴해 주는 함수
 * 입력 파라미터    : P_CURR_YMD    확인할 년월일 정보
 * 리턴값         : 정상이면 휴일제외 최근일을 찾지 못한 경우에는 전날정보 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE V_CUR_DATE DATETIME;
	DECLARE V_PRV1_YMD VARCHAR(8);

	DECLARE V_S0_YMD VARCHAR(8);
	DECLARE V_S1_YMD VARCHAR(8);
	
   
    SELECT MAX(WK_YMD) INTO V_S0_YMD
    FROM TB_WRK_DATE_MGMT
    WHERE WK_YMD < P_CURR_YMD 
    AND HOLI_YN = 'N';
   
    IF (STR_TO_DATE(P_CURR_YMD, '%Y%m%d')-STR_TO_DATE(V_S0_YMD, '%Y%m%d')) = 1 THEN
        SET V_S1_YMD = V_S0_YMD;
    ELSE
        SET V_S1_YMD = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_S0_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d');
    END IF;
            
    SET V_PRV1_YMD = V_S1_YMD;

    RETURN V_PRV1_YMD;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_REVICE_COUNT 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_REVICE_COUNT`(P_VEHL_CD	    	VARCHAR(30),
			   			 	              P_LANG_CD	    	VARCHAR(30),
										  P_N_PRNT_PBCN_NO 	VARCHAR(30)) RETURNS int(11)
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_REVICE_COUNT
 * Function 설명 : 개정내역 개수를 리턴하는 함수
 * 입력 파라미터    : P_VEHL_CD          차종코드
 *                P_LANG_CD          언어코드
 *                P_N_PRNT_PBCN_NO   신인쇄발간번호
 * 리턴값         : V_COUNT            TB_CHKLIST_DTL_INFO(체크리스트변경상세정보)에서
 *                                   넘겨받은 정보에 부함되는 취급설명서발간번호 수를 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE V_COUNT INT;
	SELECT COUNT(T.DL_EXPD_ALTR_NO) INTO V_COUNT
   	FROM (SELECT DL_EXPD_ALTR_NO
		 	FROM TB_CHKLIST_DTL_INFO
		 	WHERE QLTY_VEHL_CD = P_VEHL_CD
	     		AND LANG_CD = P_LANG_CD
		 		AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO
         	GROUP BY DL_EXPD_ALTR_NO
		) T;				
	RETURN V_COUNT;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_SEWON_IV_TEXT 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_SEWON_IV_TEXT`(P_CURR_YMD 		VARCHAR(30), 
			  		   					    P_VEHL_CD	    VARCHAR(30),
										    P_MDL_MDY_CD    VARCHAR(30),
  		   						     		P_LANG_CD 		VARCHAR(30)) RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_SEWON_IV_TEXT
 * Function 설명 : 세원 차종연식에 소속된 취급설명서 연식의 재고수량을 이전연식부터 문자형태로 표현해서 리턴하는 함수
 * 입력 파라미터    : P_CURR_YMD    마감년월일
 *                P_VEHL_CD     품질차종코드
 *                P_MDL_MDY_CD  모델연식코드
 *                P_LANG_CD     언어코드
 * 리턴값         : V_IV_QTY_TEXT        세원 차종연식에 소속된 취급설명서 연식의 재고수량을 이전연식부터 문자형태로 표현한 값 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-04     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_IV_QTY_TEXT VARCHAR(100);
	DECLARE V_DL_EXPD_MDL_MDY_CD VARCHAR(30);
	DECLARE V_IV_QTY INT;
	DECLARE V_SFTY_IV_QTY INT;	
	DECLARE i				INT;
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_IV_QTY_1 INT;
	DECLARE V_SFTY_IV_QTY_1 INT;
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE SEWON_IV_DTL_LIST_INFO CURSOR FOR
	                                    SELECT DL_EXPD_MDL_MDY_CD,
			   						  	        CASE WHEN DL_EXPD_MDL_MDY_CD = P_MDL_MDY_CD THEN SUM(IV_QTY) ELSE SUM(SFTY_IV_QTY) END AS IV_QTY,
												CASE WHEN DL_EXPD_MDL_MDY_CD = P_MDL_MDY_CD THEN SUM(SFTY_IV_QTY - IV_QTY) ELSE 0 END AS SFTY_IV_QTY
           							     FROM TB_SEWON_IV_INFO_DTL
		   							     WHERE CLS_YMD = P_CURR_YMD
		   							     AND QLTY_VEHL_CD = P_VEHL_CD
		   							     AND MDL_MDY_CD = P_MDL_MDY_CD
		   							     AND LANG_CD = P_LANG_CD
           							     GROUP BY DL_EXPD_MDL_MDY_CD; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/
	
	SET V_IV_QTY_TEXT = '';
	
	OPEN SEWON_IV_DTL_LIST_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_DTL_LIST_INFO INTO V_DL_EXPD_MDL_MDY_CD_1,V_IV_QTY_1,V_SFTY_IV_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
			IF V_IV_QTY_1 > 0 THEN		   	  
				SET V_IV_QTY_TEXT = CONCAT(V_IV_QTY_TEXT, 
			  				   			   V_DL_EXPD_MDL_MDY_CD_1, 'MY:', 
			  						   	   FORMAT(V_IV_QTY_1, '0'), 
										   (CASE WHEN V_SFTY_IV_QTY_1 < 0 THEN CONCAT('(타연식:', FORMAT(V_SFTY_IV_QTY_1, '0'), ')') ELSE '' END), ' ');
			END IF;

	END LOOP JOBLOOP1 ;
	CLOSE SEWON_IV_DTL_LIST_INFO;

   	IF LENGTH(V_IV_QTY_TEXT) > 0 THEN	   
	   	  SET V_IV_QTY_TEXT = CONCAT(SUBSTR(V_IV_QTY_TEXT, 1, LENGTH(V_IV_QTY_TEXT) - 1));    
   	END IF;
   	RETURN V_IV_QTY_TEXT;

END//
DELIMITER ;

-- 함수 hkomms.FU_GET_SORT_PBCN 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_SORT_PBCN`(P_N_PRNT_PBCN_NO VARCHAR(30)) RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_SORT_PBCN
 * Function 설명 : 신인쇄발간번호를 이용하여 정렬처리 위한 문자열 생성하는 신인쇄발간번호 값 리턴하는 함수(2023년 통합하면서 변경)
 * 입력 파라미터    : P_N_PRNT_PBCN_NO			신인쇄발간번호
 *                P_FROM_YEAR_APPLICATION	인쇄발간번호규칙변경시점년도
 * 리턴값         : V_N_PRNT_PBCN_NO    신인쇄발간번호를 생성하여 생성된 번호 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/		
	DECLARE V_N_PRNT_PBCN_NO VARCHAR(100);	 
	DECLARE V_YEAR  VARCHAR(2);
	DECLARE V_MONTH VARCHAR(2);
	DECLARE V_EXTEN VARCHAR(2);
	/*IF P_FROM_YEAR_APPLICATION = '2023' THEN*/
		IF LENGTH(P_N_PRNT_PBCN_NO) >= 10 THEN			   
		   SET V_N_PRNT_PBCN_NO = SUBSTRING(P_N_PRNT_PBCN_NO, 1, 7);	   
		   SET V_YEAR = SUBSTRING(P_N_PRNT_PBCN_NO, 8, 1);
		   SET V_MONTH = SUBSTRING(P_N_PRNT_PBCN_NO, 9, 1);
		   SET V_EXTEN = SUBSTRING(P_N_PRNT_PBCN_NO, 10, 1);
		   
		   IF V_YEAR = '1' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '31');
		   ELSEIF V_YEAR = '2' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '32');
		   ELSEIF V_YEAR = '3' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '23');
		   ELSEIF V_YEAR = '4' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '24');
		   ELSEIF V_YEAR = '5' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '25');
		   ELSEIF V_YEAR = '6' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '26');
		   ELSEIF V_YEAR = '7' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '27');
		   ELSEIF V_YEAR = '8' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '28');
		   ELSEIF V_YEAR = '9' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '29');
		   ELSEIF V_YEAR = '0' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '30');
		   ELSE
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, V_YEAR);
		   END IF;
		   
		   IF V_MONTH = '1' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '01');
		   ELSEIF V_MONTH = '2' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '02');
		   ELSEIF V_MONTH = '3' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '03');
		   ELSEIF V_MONTH = '4' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '04');
		   ELSEIF V_MONTH = '5' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '05');
		   ELSEIF V_MONTH = '6' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '06');
		   ELSEIF V_MONTH = '7' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '07');
		   ELSEIF V_MONTH = '8' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '08');
		   ELSEIF V_MONTH = '9' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '09');
		   ELSEIF V_MONTH = 'A' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '10');
		   ELSEIF V_MONTH = 'B' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '11');
		   ELSEIF V_MONTH = 'C' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '12');
		   ELSE
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, V_MONTH);
		   END IF;
		   
		   IF V_EXTEN = 'A' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, 'Z');
		   ELSE
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, V_EXTEN);
		   END IF;	   
		ELSE		
			SET V_N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;		
		END IF;	
	/*ELSE
		IF LENGTH(P_N_PRNT_PBCN_NO) >= 10 THEN			   
		   SET V_N_PRNT_PBCN_NO = SUBSTRING(P_N_PRNT_PBCN_NO, 1, 7);	   
		   SET V_YEAR = SUBSTRING(P_N_PRNT_PBCN_NO, 8, 1);
		   SET V_MONTH = SUBSTRING(P_N_PRNT_PBCN_NO, 9, 1);
		   SET V_EXTEN = SUBSTRING(P_N_PRNT_PBCN_NO, 10, 1);
		   
		   IF V_YEAR = '1' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '11');
		   ELSEIF V_YEAR = '2' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '12');
		   ELSEIF V_YEAR = '3' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '13');
		   ELSEIF V_YEAR = '4' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '14');
		   ELSEIF V_YEAR = '5' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '15');
		   ELSEIF V_YEAR = '6' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '16');
		   ELSEIF V_YEAR = '7' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '17');
		   ELSEIF V_YEAR = '8' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '08');
		   ELSEIF V_YEAR = '9' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '09');
		   ELSEIF V_YEAR = '0' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '10');
		   ELSE
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, V_YEAR);
		   END IF;
		   
		   IF V_MONTH = '1' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '01');
		   ELSEIF V_MONTH = '2' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '02');
		   ELSEIF V_MONTH = '3' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '03');
		   ELSEIF V_MONTH = '4' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '04');
		   ELSEIF V_MONTH = '5' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '05');
		   ELSEIF V_MONTH = '6' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '06');
		   ELSEIF V_MONTH = '7' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '07');
		   ELSEIF V_MONTH = '8' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '08');
		   ELSEIF V_MONTH = '9' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '09');
		   ELSEIF V_MONTH = 'O' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '10');
		   ELSEIF V_MONTH = 'N' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '11');
		   ELSEIF V_MONTH = 'D' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, '12');
		   ELSE
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, V_MONTH);
		   END IF;
		   
		   IF V_EXTEN = 'A' THEN
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, 'Z');
		   ELSE
			  SET V_N_PRNT_PBCN_NO = CONCAT(V_N_PRNT_PBCN_NO, V_EXTEN);
		   END IF;	   
		ELSE		
			SET V_N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;		
		END IF;	
	END IF;*/
	RETURN V_N_PRNT_PBCN_NO;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_VALID_YMDHM 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_VALID_YMDHM`(P_YMDHM VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_VALID_YMDHM
 * Function 설명 : 년월일에 00000000으로 들어오는 값에 대하여 널로 리턴하고 정상적인 날짜는 그대로 리턴하는 함수
 * 입력 파라미터    : P_YMDHM    확인할 년월일 정보
 * 리턴값         : 정상이면 입력된 년월일을 리턴하고 00000000는 널로 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/	
	DECLARE V_CURR_YER CHAR(4);
	DECLARE V_CURR_MTH CHAR(2);
	DECLARE V_CURR_DAY CHAR(2); 
 	SET V_CURR_YER = SUBSTRING(P_YMDHM, 1, 4);
	SET V_CURR_MTH = SUBSTRING(P_YMDHM, 5, 2);
	SET V_CURR_DAY = SUBSTRING(P_YMDHM, 7, 2);
	
	IF V_CURR_YER = '0000' OR
	   V_CURR_MTH = '00' OR
	   V_CURR_DAY = '00' THEN	   
	   RETURN NULL; 	   
	ELSE	   
	   RETURN TRIM(P_YMDHM);	   
	END IF;
END//
DELIMITER ;

-- 함수 hkomms.FU_GET_WRKDATE 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_GET_WRKDATE`(P_CURR_YMD VARCHAR(8),
   						   			  P_CNT	  INT(3)) RETURNS varchar(8) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_GET_WRKDATE
 * Function 설명 : P_CURR_YMD 날짜에서 P_CNT 갯수만큼 경과한 영업기준 일자를 리턴해 주는 함수
 *                최대 이전과 이후에 대하여 5일까지만 리턴
 * 입력 파라미터    : P_CURR_YMD      현재 yyyymmdd
 *                P_CNT           영업기준일자수
 * 리턴값         : V_WRK_YMD       TB_WRK_DATE_MGMT(날짜정보관리)에서
 *								  현 기준일자를 기준으로 영업일수번째에 해당되는 일자 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE	V_CUR_DATE DATETIME;
	DECLARE V_WRK_YMD VARCHAR(8);
	DECLARE EXIT HANDLER FOR 1062	
	IF P_CNT > 5 OR P_CNT < -5 THEN		   
		   CALL RAISE_APPLICATION_ERROR(-20001, 'Invalid Date Duration(from -5 to 5 is valid)'); 
		   SIGNAL SQLSTATE '45000';
	END IF;		
	SET	V_CUR_DATE = STR_TO_DATE(P_CURR_YMD, '%Y%m%d');
	IF P_CNT > 0 THEN
	   SELECT MAX(K.WK_YMD)
	   INTO V_WRK_YMD
	   FROM (SELECT P.WK_YMD,
	   				ROW_NUMBER() OVER() AS ROWNM
			 FROM (SELECT WK_YMD
			 	   FROM TB_WRK_DATE_MGMT
				   WHERE WK_YMD > P_CURR_YMD 
				   /* 최대 5일 까지만 조회하므로 토,일요일을 감안하여 7일까지만 조회하여 내역을 확인한다.*/
				   AND WK_YMD <= DATE_FORMAT(DATE_ADD(V_CUR_DATE, INTERVAL 7 DAY), '%Y%m%d')
				   AND HOLI_YN = 'N'
				   ORDER BY WK_YMD
                  ) P
			) K
	   WHERE K.ROWNM = P_CNT;	
	ELSE	
	   SELECT MAX(K.WK_YMD)
	   INTO V_WRK_YMD
	   FROM (SELECT P.WK_YMD,
	   				ROW_NUMBER() OVER() AS ROWNM
			 FROM (SELECT WK_YMD
			 	   FROM TB_WRK_DATE_MGMT
				   WHERE WK_YMD < P_CURR_YMD 
				   /* 최대 5일 까지만 조회하므로 토,일요일을 감안하여 7일까지만 조회하여 내역을 확인한다.*/
				   AND WK_YMD >= DATE_FORMAT(DATE_SUB(V_CUR_DATE, INTERVAL 7 DAY), '%Y%m%d')
				   AND HOLI_YN = 'N'
				   ORDER BY WK_YMD DESC 
                  ) P
			) K
	   WHERE K.ROWNM = ABS(P_CNT);	   	
	END IF;
	
	IF V_WRK_YMD IS NULL THEN	   
	   SET V_WRK_YMD = DATE_FORMAT(DATE_ADD(V_CUR_DATE, INTERVAL P_CNT DAY), '%Y%m%d');	   
	END IF;	
	RETURN V_WRK_YMD;
END//
DELIMITER ;

-- 함수 hkomms.FU_RPAD 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_RPAD`(P_VALUE   VARCHAR(300),
										    P_LENGTH	 INT) RETURNS varchar(1000) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_RPAD
 * Function 설명 : 지정한 길이만큼 오른쪽부터 채움문자로 채워주어 리턴하는 함수
 * 입력 파라미터    : P_VALUE   처리할 문자열
 *                P_LENGTH  요청된 문자열길이에서 채워준 문자열까지 총길이
 * 리턴값         : 처리할 문자열에서 요청된 길이만큼 오른쪽에 채워진 문자열 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-04     안상천   최초 전환함
 ****************************************************************************/	
RETURN RPAD(P_VALUE, P_LENGTH, ' ');	   
END//
DELIMITER ;

-- 함수 hkomms.FU_TO_CLOSE_DATE_CHAR 구조 내보내기
DELIMITER //
CREATE FUNCTION `FU_TO_CLOSE_DATE_CHAR`(P_CURR_YMD 		VARCHAR(30)) RETURNS varchar(30) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : FU_TO_CLOSE_DATE_CHAR
 * Function 설명 : 마감일자에 마감시간을 더해서 한글 형태로 변경하여 리턴하는 함수
 * 입력 파라미터    : P_CURR_YMD          년월일
 *                P_EXPD_CO_CD        취급설명서회사코드
 * 리턴값         : V_LOCAL_CHAR        년월일 정보를 받아서 한글형으로 날짜를 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-04     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE V_LOCAL_CHAR VARCHAR(30);	    
	DECLARE	V_LOCAL_DATE DATETIME;
	SET V_LOCAL_DATE = STR_TO_DATE(CONCAT(P_CURR_YMD, '0530'), '%Y%m%d%H%i');
	SET V_LOCAL_CHAR = CONCAT(DATE_FORMAT(V_LOCAL_DATE, '%m'), '월', 
						   	  DATE_FORMAT(V_LOCAL_DATE, '%d'), '일', '(',
						      DATE_FORMAT(V_LOCAL_DATE, '%H'), '시',
					          DATE_FORMAT(V_LOCAL_DATE, '%i'), '분', ')');
	RETURN V_LOCAL_CHAR;
END//
DELIMITER ;

-- 함수 hkomms.GET_APS_PROD_EXIST_YN 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_APS_PROD_EXIST_YN`(CURR_YMD VARCHAR(8),
                                                                                     EXPD_CO_CD VARCHAR(4)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_APS_PROD_EXIST_YN
 * Function 설명 : APS 계획 데이터 존재 여부 조회하는 함수
 *                PSE06AC_HMC(현대), PSE06AC_KMC(기아)
 * 입력 파라미터    : P_CURR_YMD    확인할 년월일 정보
 * 리턴값         : 정상이면 휴일제외 최근일을 찾지 못한 경우에는 전날정보 리턴
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_BTCH_YMD VARCHAR(8);

	IF EXPD_CO_CD = '01' THEN
		    SELECT IFNULL(SUBSTR(CONCAT(MAX(PS06A_STTM)), 1, 8),'29991231')
		   INTO V_BTCH_YMD
		   FROM PSE06AC_HMC;
	ELSE
		    SELECT IFNULL(SUBSTR(CONCAT(MAX(PS06A_STTM)), 1, 8),'29991231')
		   INTO V_BTCH_YMD
		   FROM PSE06AC_KMC;
	END IF;
	
	IF V_BTCH_YMD <= CURR_YMD THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;
END//
DELIMITER ;

-- 함수 hkomms.GET_BTCH_FNH_YN 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_BTCH_FNH_YN`(CURR_YMD	    	VARCHAR(8),
			   			 	              EXPD_CO_CD	    	VARCHAR(4),
										  P_ET_GUBN_CD 	VARCHAR(2)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_BTCH_FNH_YN
 * Function 설명 : 배치결과 정보 존재 여부 조회하는 함수
 * 입력 파라미터    : CURR_YMD          현재년월일
 *                EXPD_CO_CD        취급설명서회사코드
 *                P_ET_GUBN_CD      전송구분코드
 * 리턴값         : V_STATE           존재하면 Y, 존재하지 않으면 N
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_BTCH_YMD VARCHAR(8);
	DECLARE V_STATE VARCHAR(1);
	DECLARE V_AFFR_SCN_CD VARCHAR(2); 

			IF P_ET_GUBN_CD = '01' THEN	 
 			   /* 당일 인터페이스	*/ 
               SET V_AFFR_SCN_CD = '04';	 
			ELSE	 
			   /* 전일 인터페이스	 */
               SET V_AFFR_SCN_CD = '03';	 
			END IF;	 
	 
			SELECT MAX(BTCH_FNH_YMD)	 
			  INTO V_BTCH_YMD	 
			  FROM TB_BATCH_FNH_INFO	 
			 WHERE AFFR_SCN_CD = V_AFFR_SCN_CD	 
			   AND DL_EXPD_CO_CD = EXPD_CO_CD	 
			   AND BTCH_FNH_YMD = CURR_YMD;	 
	 
			IF V_BTCH_YMD IS NULL THEN
			   SET V_STATE = 'N';
			ELSEIF CURR_YMD = V_BTCH_YMD THEN
			   SET V_STATE = 'Y';
			ELSE
			   SET V_STATE = 'N';
			END IF;	 
	 
			RETURN V_STATE;	 
END//
DELIMITER ;

-- 함수 hkomms.GET_BTCH_ODR_FNH_YN 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_BTCH_ODR_FNH_YN`(CURR_YMD	    	VARCHAR(8),
										  EXPD_CO_CD 	VARCHAR(4)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_BTCH_ODR_FNH_YN
 * Function 설명 : 오더 배치결과 정보 존재 여부 조회하는 함수
 * 입력 파라미터    : CURR_YMD          현재년월일
 *                EXPD_CO_CD        취급설명서회사코드
 * 리턴값         : V_STATE           존재하면 Y, 존재하지 않으면 N
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_BTCH_YMD VARCHAR(8);
	DECLARE V_STATE VARCHAR(1);

			SELECT MAX(BTCH_FNH_YMD)	 
			INTO V_BTCH_YMD	 
			FROM TB_BATCH_FNH_INFO	 
			WHERE AFFR_SCN_CD = '01'	 
			AND DL_EXPD_CO_CD = EXPD_CO_CD	 
			AND BTCH_FNH_YMD = CURR_YMD;	 
	 
			IF V_BTCH_YMD IS NULL THEN
			   SET V_STATE = 'N';
			ELSEIF CURR_YMD = V_BTCH_YMD THEN
			   SET V_STATE = 'Y';
			ELSE
			   SET V_STATE = 'N';
			END IF;	 
	 
			RETURN V_STATE;	 
END//
DELIMITER ;

-- 함수 hkomms.GET_BTCH_PROD_FNH_YN 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_BTCH_PROD_FNH_YN`(CURR_YMD	    	VARCHAR(8),
										  EXPD_CO_CD 	VARCHAR(4)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN 
/***************************************************************************
 * Function 명칭 : GET_BTCH_PROD_FNH_YN
 * Function 설명 : 계획 배치결과 정보 존재 여부 조회하는 함수
 * 입력 파라미터    : CURR_YMD          현재년월일
 *                EXPD_CO_CD        취급설명서회사코드
 * 리턴값         : V_STATE           존재하면 Y, 존재하지 않으면 N
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_BTCH_YMD VARCHAR(8);
	DECLARE V_STATE VARCHAR(1);

			SELECT MAX(BTCH_FNH_YMD)	 
			INTO V_BTCH_YMD	 
			FROM TB_BATCH_FNH_INFO	 
			WHERE AFFR_SCN_CD = '02'	 
			AND DL_EXPD_CO_CD = EXPD_CO_CD	 
			AND BTCH_FNH_YMD = CURR_YMD;	 
	 
			IF V_BTCH_YMD IS NULL THEN
			   SET V_STATE = 'N';
			ELSEIF CURR_YMD = V_BTCH_YMD THEN
			   SET V_STATE = 'Y';
			ELSE
			   SET V_STATE = 'N';
			END IF;	 
	 
			RETURN V_STATE;	 
END//
DELIMITER ;

-- 함수 hkomms.GET_ERP_ET_INFO_EXIST_YN 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_ERP_ET_INFO_EXIST_YN`(P_CURR_YMD	    	VARCHAR(30),
			   			 	              P_DL_EXPD_CO_CD	    	VARCHAR(4),
										  P_ET_GUBN_CD 	VARCHAR(2)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_ERP_ET_INFO_EXIST_YN
 * Function 설명 : 생산마스터 데이터 전송 완료 여부 확인하는 함수
 * 입력 파라미터    : P_CURR_YMD          현재년월일
 *                P_DL_EXPD_CO_CD     취급설명서회사코드
 *                P_ET_GUBN_CD        전송구분코드
 * 리턴값         : 존재하면 Y, 존재하지 않으면 N
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CNT INT;

			SELECT COUNT(*)	 
              INTO V_CNT	 
              FROM TB_BATCH_ERP_ET_INFO	 
             WHERE DL_EXPD_CO_CD = P_DL_EXPD_CO_CD	 
               AND BTCH_FNH_YMD  = P_CURR_YMD	 
               AND ET_GUBN_CD    = P_ET_GUBN_CD;
	 
            IF V_CNT > 0 THEN	 
            	RETURN 'Y';	 
            ELSE	 
            	RETURN 'N';	 
            END IF;	 
END//
DELIMITER ;

-- 함수 hkomms.GET_MDY_CD 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_MDY_CD`(P_EXPD_CO_CD VARCHAR(4),MDL_MDY_CD VARCHAR(4)) RETURNS varchar(2) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_MDY_CD
 * Function 설명 : 생산마스터 모델년식코드 추출 함수
 *                생산마스터의 연식을 오너스매뉴얼 연식으로 변환하는 함수
 * 입력 파라미터    : MDL_MDY_CD    모델년식코드
 * 리턴값         : MDY_CD        년식코드
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE MDY_CD VARCHAR(2);	
	IF P_EXPD_CO_CD='02' THEN
	   		IF MDL_MDY_CD = '1' THEN	 
			   SET MDY_CD = '01';	 
			ELSEIF MDL_MDY_CD = '2' THEN	 
			   SET MDY_CD = '02';	 
			ELSEIF MDL_MDY_CD = '3' THEN	 
			   SET MDY_CD = '03';	 
			ELSEIF MDL_MDY_CD = '4' THEN	 
			   SET MDY_CD = '04';	 
			ELSEIF MDL_MDY_CD = '5' THEN	 
			   SET MDY_CD = '05';	 
			ELSEIF MDL_MDY_CD = '6' THEN	 
			   SET MDY_CD = '06';	 
			ELSEIF MDL_MDY_CD = '7' THEN	 
			   SET MDY_CD = '07';	 
			ELSEIF MDL_MDY_CD = '8' THEN	 
			   SET MDY_CD = '08';	 
			ELSEIF MDL_MDY_CD = '9' THEN	 
			   SET MDY_CD = '09';	 
			ELSEIF MDL_MDY_CD = 'A' THEN	 
			   SET MDY_CD = '10';	 
			ELSEIF MDL_MDY_CD = 'B' THEN	 
			   SET MDY_CD = '11';	 
			ELSEIF MDL_MDY_CD = 'C' THEN	 
			   SET MDY_CD = '12';	 
			ELSEIF MDL_MDY_CD = 'D' THEN	 
			   SET MDY_CD = '13';	 
			ELSEIF MDL_MDY_CD = 'E' THEN	 
			   SET MDY_CD = '14';	 
			ELSEIF MDL_MDY_CD = 'F' THEN	 
			   SET MDY_CD = '15';	 
			ELSEIF MDL_MDY_CD = 'G' THEN	 
			   SET MDY_CD = '16';	 
			ELSEIF MDL_MDY_CD = 'H' THEN	 
			   SET MDY_CD = '17';	 
			ELSEIF MDL_MDY_CD = 'I' THEN	 
			   SET MDY_CD = '18';	 
			ELSEIF MDL_MDY_CD = 'J' THEN	 
			   SET MDY_CD = '19';	 
			ELSEIF MDL_MDY_CD = 'K' THEN	 
			   SET MDY_CD = '20';	 
			ELSEIF MDL_MDY_CD = 'L' THEN	 
			   SET MDY_CD = '21';	 
			ELSEIF MDL_MDY_CD = 'M' THEN	 
			   SET MDY_CD = '22';	 
			ELSEIF MDL_MDY_CD = 'N' THEN	 
			   SET MDY_CD = '23';	 
			ELSEIF MDL_MDY_CD = 'O' THEN	 
			   SET MDY_CD = '24';	 
			ELSEIF MDL_MDY_CD = 'P' THEN	 
			   SET MDY_CD = '25';	 
			ELSEIF MDL_MDY_CD = 'Q' THEN	 
			   SET MDY_CD = '26';	 
			ELSEIF MDL_MDY_CD = 'R' THEN	 
			   SET MDY_CD = '27';	 
			ELSEIF MDL_MDY_CD = 'S' THEN	 
			   SET MDY_CD = '28';	 
			ELSEIF MDL_MDY_CD = 'T' THEN	 
			   SET MDY_CD = '29';	 
			ELSEIF MDL_MDY_CD = 'U' THEN	 
			   SET MDY_CD = '30';	 
			ELSEIF MDL_MDY_CD = 'V' THEN	 
			   SET MDY_CD = '31';	 
			ELSEIF MDL_MDY_CD = 'W' THEN	 
			   SET MDY_CD = '32';	 
			ELSEIF MDL_MDY_CD = 'X' THEN	 
			   SET MDY_CD = '33';	 
			ELSEIF MDL_MDY_CD = 'Y' THEN	 
			   SET MDY_CD = '34';	 
			ELSEIF MDL_MDY_CD = 'Z' THEN	 
			   SET MDY_CD = '35';	 
			END IF;	  
	ELSE
	   		IF MDL_MDY_CD = '1' THEN
			   SET MDY_CD = '01';
			ELSEIF MDL_MDY_CD = '2' THEN
			   SET MDY_CD = '02';
			ELSEIF MDL_MDY_CD = '3' THEN
			   SET MDY_CD = '03';
			ELSEIF MDL_MDY_CD = '4' THEN
			   SET MDY_CD = '04';
			ELSEIF MDL_MDY_CD = '5' THEN
			   SET MDY_CD = '05';
			ELSEIF MDL_MDY_CD = '6' THEN
			   SET MDY_CD = '06';
			ELSEIF MDL_MDY_CD = '7' THEN
			   SET MDY_CD = '07';
			ELSEIF MDL_MDY_CD = '8' THEN
			   SET MDY_CD = '08';
			ELSEIF MDL_MDY_CD = '9' THEN
			   SET MDY_CD = '09';
			ELSEIF MDL_MDY_CD = 'A' THEN
			   SET MDY_CD = '10';
			ELSEIF MDL_MDY_CD = 'B' THEN
			   SET MDY_CD = '11';
			ELSEIF MDL_MDY_CD = 'C' THEN
			   SET MDY_CD = '12';
			ELSEIF MDL_MDY_CD = 'D' THEN
			   SET MDY_CD = '13';
			ELSEIF MDL_MDY_CD = 'E' THEN
			   SET MDY_CD = '14';
			ELSEIF MDL_MDY_CD = 'F' THEN
			   SET MDY_CD = '15';
			ELSEIF MDL_MDY_CD = 'G' THEN
			   SET MDY_CD = '16';
			ELSEIF MDL_MDY_CD = 'H' THEN
			   SET MDY_CD = '17';
			ELSEIF MDL_MDY_CD = 'J' THEN
			   SET MDY_CD = '18';
			ELSEIF MDL_MDY_CD = 'K' THEN
			   SET MDY_CD = '19';
			ELSEIF MDL_MDY_CD = 'M' THEN
			   SET MDY_CD = '20';
			ELSEIF MDL_MDY_CD = 'N' THEN
			   SET MDY_CD = '21';
			ELSEIF MDL_MDY_CD = 'O' THEN 
			   SET MDY_CD = '22';
			ELSEIF MDL_MDY_CD = 'P' THEN
			   SET MDY_CD = '23';
			ELSEIF MDL_MDY_CD = 'Q' THEN
			   SET MDY_CD = '24';
			ELSEIF MDL_MDY_CD = 'R' THEN
			   SET MDY_CD = '25';
			ELSEIF MDL_MDY_CD = 'S' THEN
			   SET MDY_CD = '26';
			ELSEIF MDL_MDY_CD = 'T' THEN
			   SET MDY_CD = '27';
			ELSEIF MDL_MDY_CD = 'U' THEN
			   SET MDY_CD = '28';
			ELSEIF MDL_MDY_CD = 'V' THEN
			   SET MDY_CD = '29';
			ELSEIF MDL_MDY_CD = 'W' THEN
			   SET MDY_CD = '30';
			ELSEIF MDL_MDY_CD = 'X' THEN
			   SET MDY_CD = '31';
			ELSEIF MDL_MDY_CD = 'Y' THEN
			   SET MDY_CD = '32';
			ELSEIF MDL_MDY_CD = 'Z' THEN
			   SET MDY_CD = '33';
			END IF; /* 영문자 I, L은 숫자 1과 혼동 될 수 있으므로 제외함 */

	END IF;
	RETURN MDY_CD;

END//
DELIMITER ;

-- 함수 hkomms.GET_MDY_CD_HMC 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_MDY_CD_HMC`(MDL_MDY_CD VARCHAR(4)) RETURNS varchar(2) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_MDY_CD_HMC
 * Function 설명 : 생산마스터 모델년식코드 추출 함수
 *                생산마스터의 연식을 오너스매뉴얼 연식으로 변환하는 함수
 * 입력 파라미터    : MDL_MDY_CD    모델년식코드
 * 리턴값         : MDY_CD        년식코드
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE MDY_CD VARCHAR(2);

	   		IF MDL_MDY_CD = '1' THEN
			   SET MDY_CD = '01';
			ELSEIF MDL_MDY_CD = '2' THEN
			   SET MDY_CD = '02';
			ELSEIF MDL_MDY_CD = '3' THEN
			   SET MDY_CD = '03';
			ELSEIF MDL_MDY_CD = '4' THEN
			   SET MDY_CD = '04';
			ELSEIF MDL_MDY_CD = '5' THEN
			   SET MDY_CD = '05';
			ELSEIF MDL_MDY_CD = '6' THEN
			   SET MDY_CD = '06';
			ELSEIF MDL_MDY_CD = '7' THEN
			   SET MDY_CD = '07';
			ELSEIF MDL_MDY_CD = '8' THEN
			   SET MDY_CD = '08';
			ELSEIF MDL_MDY_CD = '9' THEN
			   SET MDY_CD = '09';
			ELSEIF MDL_MDY_CD = 'A' THEN
			   SET MDY_CD = '10';
			ELSEIF MDL_MDY_CD = 'B' THEN
			   SET MDY_CD = '11';
			ELSEIF MDL_MDY_CD = 'C' THEN
			   SET MDY_CD = '12';
			ELSEIF MDL_MDY_CD = 'D' THEN
			   SET MDY_CD = '13';
			ELSEIF MDL_MDY_CD = 'E' THEN
			   SET MDY_CD = '14';
			ELSEIF MDL_MDY_CD = 'F' THEN
			   SET MDY_CD = '15';
			ELSEIF MDL_MDY_CD = 'G' THEN
			   SET MDY_CD = '16';
			ELSEIF MDL_MDY_CD = 'H' THEN
			   SET MDY_CD = '17';
			ELSEIF MDL_MDY_CD = 'J' THEN
			   SET MDY_CD = '18';
			ELSEIF MDL_MDY_CD = 'K' THEN
			   SET MDY_CD = '19';
			ELSEIF MDL_MDY_CD = 'M' THEN
			   SET MDY_CD = '20';
			ELSEIF MDL_MDY_CD = 'N' THEN
			   SET MDY_CD = '21';
			ELSEIF MDL_MDY_CD = 'O' THEN 
			   SET MDY_CD = '22';
			ELSEIF MDL_MDY_CD = 'P' THEN
			   SET MDY_CD = '23';
			ELSEIF MDL_MDY_CD = 'Q' THEN
			   SET MDY_CD = '24';
			ELSEIF MDL_MDY_CD = 'R' THEN
			   SET MDY_CD = '25';
			ELSEIF MDL_MDY_CD = 'S' THEN
			   SET MDY_CD = '26';
			ELSEIF MDL_MDY_CD = 'T' THEN
			   SET MDY_CD = '27';
			ELSEIF MDL_MDY_CD = 'U' THEN
			   SET MDY_CD = '28';
			ELSEIF MDL_MDY_CD = 'V' THEN
			   SET MDY_CD = '29';
			ELSEIF MDL_MDY_CD = 'W' THEN
			   SET MDY_CD = '30';
			ELSEIF MDL_MDY_CD = 'X' THEN
			   SET MDY_CD = '31';
			ELSEIF MDL_MDY_CD = 'Y' THEN
			   SET MDY_CD = '32';
			ELSEIF MDL_MDY_CD = 'Z' THEN
			   SET MDY_CD = '33';
			END IF; /* 영문자 I, L은 숫자 1과 혼동 될 수 있으므로 제외함 */

			RETURN MDY_CD;


END//
DELIMITER ;

-- 함수 hkomms.GET_MDY_CD_KMC 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_MDY_CD_KMC`(MDL_MDY_CD VARCHAR(4)) RETURNS varchar(2) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_MDY_CD_KMC
 * Function 설명 : 생산마스터 모델년식코드 추출 함수
 *                생산마스터의 연식을 오너스매뉴얼 연식으로 변환하는 함수
 * 입력 파라미터    : MDL_MDY_CD    모델년식코드
 * 리턴값         : MDY_CD        년식코드
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE MDY_CD VARCHAR(2);	

	   		IF MDL_MDY_CD = '1' THEN	 
			   SET MDY_CD = '01';	 
			ELSEIF MDL_MDY_CD = '2' THEN	 
			   SET MDY_CD = '02';	 
			ELSEIF MDL_MDY_CD = '3' THEN	 
			   SET MDY_CD = '03';	 
			ELSEIF MDL_MDY_CD = '4' THEN	 
			   SET MDY_CD = '04';	 
			ELSEIF MDL_MDY_CD = '5' THEN	 
			   SET MDY_CD = '05';	 
			ELSEIF MDL_MDY_CD = '6' THEN	 
			   SET MDY_CD = '06';	 
			ELSEIF MDL_MDY_CD = '7' THEN	 
			   SET MDY_CD = '07';	 
			ELSEIF MDL_MDY_CD = '8' THEN	 
			   SET MDY_CD = '08';	 
			ELSEIF MDL_MDY_CD = '9' THEN	 
			   SET MDY_CD = '09';	 
			ELSEIF MDL_MDY_CD = 'A' THEN	 
			   SET MDY_CD = '10';	 
			ELSEIF MDL_MDY_CD = 'B' THEN	 
			   SET MDY_CD = '11';	 
			ELSEIF MDL_MDY_CD = 'C' THEN	 
			   SET MDY_CD = '12';	 
			ELSEIF MDL_MDY_CD = 'D' THEN	 
			   SET MDY_CD = '13';	 
			ELSEIF MDL_MDY_CD = 'E' THEN	 
			   SET MDY_CD = '14';	 
			ELSEIF MDL_MDY_CD = 'F' THEN	 
			   SET MDY_CD = '15';	 
			ELSEIF MDL_MDY_CD = 'G' THEN	 
			   SET MDY_CD = '16';	 
			ELSEIF MDL_MDY_CD = 'H' THEN	 
			   SET MDY_CD = '17';	 
			ELSEIF MDL_MDY_CD = 'I' THEN	 
			   SET MDY_CD = '18';	 
			ELSEIF MDL_MDY_CD = 'J' THEN	 
			   SET MDY_CD = '19';	 
			ELSEIF MDL_MDY_CD = 'K' THEN	 
			   SET MDY_CD = '20';	 
			ELSEIF MDL_MDY_CD = 'L' THEN	 
			   SET MDY_CD = '21';	 
			ELSEIF MDL_MDY_CD = 'M' THEN	 
			   SET MDY_CD = '22';	 
			ELSEIF MDL_MDY_CD = 'N' THEN	 
			   SET MDY_CD = '23';	 
			ELSEIF MDL_MDY_CD = 'O' THEN	 
			   SET MDY_CD = '24';	 
			ELSEIF MDL_MDY_CD = 'P' THEN	 
			   SET MDY_CD = '25';	 
			ELSEIF MDL_MDY_CD = 'Q' THEN	 
			   SET MDY_CD = '26';	 
			ELSEIF MDL_MDY_CD = 'R' THEN	 
			   SET MDY_CD = '27';	 
			ELSEIF MDL_MDY_CD = 'S' THEN	 
			   SET MDY_CD = '28';	 
			ELSEIF MDL_MDY_CD = 'T' THEN	 
			   SET MDY_CD = '29';	 
			ELSEIF MDL_MDY_CD = 'U' THEN	 
			   SET MDY_CD = '30';	 
			ELSEIF MDL_MDY_CD = 'V' THEN	 
			   SET MDY_CD = '31';	 
			ELSEIF MDL_MDY_CD = 'W' THEN	 
			   SET MDY_CD = '32';	 
			ELSEIF MDL_MDY_CD = 'X' THEN	 
			   SET MDY_CD = '33';	 
			ELSEIF MDL_MDY_CD = 'Y' THEN	 
			   SET MDY_CD = '34';	 
			ELSEIF MDL_MDY_CD = 'Z' THEN	 
			   SET MDY_CD = '35';	 
			END IF;	 
	 
			RETURN MDY_CD;	 

END//
DELIMITER ;

-- 함수 hkomms.GET_NAT_CD 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_NAT_CD`(P_DL_EXPD_NAT_CD VARCHAR(30),
										P_EXPD_CO_CD VARCHAR(4)) RETURNS varchar(5) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_NAT_CD
 * Function 설명 : 국가마스터에서 5자리 OR 3자리 국가코드 반환하는 함수
 * 입력 파라미터    : P_DL_EXPD_NAT_CD          취급설명서국가코드
 *                P_EXPD_CO_CD              취급설명서회사코드
 * 리턴값         : NAT_CD                    국가코드
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE NAT_CD VARCHAR(5);

	   	SET NAT_CD = NULL;	 
	   	 
	   	SELECT MAX(DL_EXPD_NAT_CD)	 
	   	INTO NAT_CD	 
	   	FROM TB_NATL_MGMT	 
	   	WHERE DL_EXPD_CO_CD = P_EXPD_CO_CD	 
	   	AND (DL_EXPD_NAT_CD = P_DL_EXPD_NAT_CD OR DL_EXPD_NAT_CD = SUBSTR(P_DL_EXPD_NAT_CD, 1, 3));
	   		 
	   	RETURN NAT_CD;	 
	 
		 /*EXCEPTION	 
		     WHEN OTHERS THEN	 
			 /*PG_INTERFACE_APS.WRITE_BATCH_EXE_LOG('PG_INTERFACE_APS.GET_NAT_CD', SYSDATE, 'F', 'P_DL_EXPD_NAT_CD : ' || P_DL_EXPD_NAT_CD);	
			 CALL RAISE_APPLICATION_ERROR(-20001, 'Invalid Date Duration(from -5 to 5 is valid)'); */

END//
DELIMITER ;

-- 함수 hkomms.GET_POW_LOC_CD_ERP 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_POW_LOC_CD_ERP`(P_POW_LOC_CD          VARCHAR(4),
										P_EXPD_CO_CD VARCHAR(4)) RETURNS varchar(2) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_POW_LOC_CD_ERP
 * Function 설명 : ERP 공정위치 코드를 01 ~ 16 사이의 공정위치 코드로 변환하는 함수
 *                01 : 차체투입
 *                02 : 도장투입
 *                03 : 상도입구
 *                04 : 도장완료
 *                05 : PBS입구
 *                06 : PBS OUT
 *                07 : OK LINE(C/FINAL)
 *                08 : S/OFF
 *                09 : 통제소
 *                10 : PDI IN
 *                11 : PDI OUT,선적
 *                00 : 기타
 * 입력 파라미터    : P_POW_LOC_CD    공장위치코드
 *                P_EXPD_CO_CD    취급설명서회사코드
 * 리턴값         : V_POW_LOC_CD    공정위치코드
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE V_POW_LOC_CD VARCHAR(2);	

         IF P_EXPD_CO_CD = '01' THEN
             /* 차체IN, 차체OUT */
             IF P_POW_LOC_CD IN ('B010', 'B020') THEN        		 	
                SET V_POW_LOC_CD = '01';
             /* 도장IN, UBS, 중도IN, 상도IN */
             ELSEIF P_POW_LOC_CD IN ('P010', 'P020', 'P030') THEN
                SET V_POW_LOC_CD = '02';
             ELSEIF P_POW_LOC_CD IN ('P040') THEN
             	SET V_POW_LOC_CD = '03';
             /* 도장OUT, PBS */
             ELSEIF P_POW_LOC_CD IN ('P050', 'P060') THEN
                SET V_POW_LOC_CD = '04';
             /* PBS */
             ELSEIF P_POW_LOC_CD = 'T000' THEN
                SET V_POW_LOC_CD = '05';
             /* 트림1, 트림2, 트림3, 샤시1, 샤시2, 화이날1, 화이날2, 화이날3, 화이날4  */
             ELSEIF P_POW_LOC_CD IN ('T010', 'T020', 'T030', 'T040', 'T050', 'T060', 'T070', 'T080', 'T090') THEN        		    
                SET V_POW_LOC_CD = '06';
             /* C/F(OK) */
             ELSEIF P_POW_LOC_CD = 'T100' THEN
                SET V_POW_LOC_CD = '07';
             /* S/OFF */
             ELSEIF P_POW_LOC_CD = 'T110' THEN
                SET V_POW_LOC_CD = '08';
             /* 통제소 */
             ELSEIF P_POW_LOC_CD = 'T120' THEN
                SET V_POW_LOC_CD = '09';
             ELSEIF P_POW_LOC_CD IN ('V010') THEN
                SET V_POW_LOC_CD = '10';
             ELSEIF P_POW_LOC_CD IN ('V020') THEN
                SET V_POW_LOC_CD = '10';
             ELSEIF P_POW_LOC_CD IN ('V030', 'V040', 'V050', 'V060') THEN
                SET V_POW_LOC_CD = '10';
             /* 선적,출문 */
             ELSEIF P_POW_LOC_CD = 'V070' THEN
                SET V_POW_LOC_CD = '10';
             ELSE
                SET V_POW_LOC_CD = '00';
             END IF;
         ELSEIF P_EXPD_CO_CD = '02' THEN	 
             /* 차체투입	 */
             IF P_POW_LOC_CD IN ('B010', 'B020') THEN	 
                SET V_POW_LOC_CD = '01';	 
             /* 도장투입	 */
             ELSEIF P_POW_LOC_CD IN ('P010', 'P020', 'P030') THEN
                SET V_POW_LOC_CD = '02';
             /* 상도입구	 */
             ELSEIF P_POW_LOC_CD IN ('P040') THEN
                SET V_POW_LOC_CD = '03';
             /* 도장완료	 */
             ELSEIF P_POW_LOC_CD IN ('P050', 'P060') THEN
                SET V_POW_LOC_CD = '04';
             /* PBS입구	 */
             ELSEIF P_POW_LOC_CD IN ('T000') THEN
                SET V_POW_LOC_CD = '05';
             /* PBS OUT	 */
             ELSEIF P_POW_LOC_CD IN ('T010', 'T020', 'T030', 'T040', 'T050', 'T060', 'T070', 'T080', 'T090') THEN
                SET V_POW_LOC_CD = '06';
             /* OK LINE(C/FINAL)	 */
             ELSEIF P_POW_LOC_CD IN ('T100') THEN
                SET V_POW_LOC_CD = '07';
             /* S/OFF	 */
             ELSEIF P_POW_LOC_CD = 'T110' THEN
                SET V_POW_LOC_CD = '08';
             /* 통제소	 */
             ELSEIF P_POW_LOC_CD IN ('T120') THEN
                SET V_POW_LOC_CD = '09';
             /* PDI IN	 */
             ELSEIF P_POW_LOC_CD IN ('V010') THEN
                SET V_POW_LOC_CD = '10';
             /* PDI OUT	 */
             ELSEIF P_POW_LOC_CD IN ('V020') THEN
                SET V_POW_LOC_CD = '11';
             /* MP 입고	 */
             ELSEIF P_POW_LOC_CD IN ('V030', 'V040', 'V050', 'V060') THEN
                SET V_POW_LOC_CD = '11';
             /* 선적	 */
             ELSEIF P_POW_LOC_CD IN ('V070', 'V080', 'V090') THEN
                SET V_POW_LOC_CD = '11';
             ELSE
                SET V_POW_LOC_CD = '00';
             END IF;
         ELSE
             /* 차체투입 */
             IF P_POW_LOC_CD IN ('B010', 'B020') THEN    		 	
                SET V_POW_LOC_CD = '01';
             /* 도장투입 */
             ELSEIF P_POW_LOC_CD IN ('P010', 'P020', 'P030') THEN
                SET V_POW_LOC_CD = '02';
             /* 상도입구 */
             ELSEIF P_POW_LOC_CD IN ('P040') THEN
                SET V_POW_LOC_CD = '03';
             /* 도장완료 */
             ELSEIF P_POW_LOC_CD IN ('P050', 'P060') THEN
                SET V_POW_LOC_CD = '04';
             /* PBS입구 */
             ELSEIF P_POW_LOC_CD IN ('T000') THEN
                SET V_POW_LOC_CD = '05';
             /* PBS OUT */
             ELSEIF P_POW_LOC_CD IN ('T010', 'T020', 'T030', 'T040', 'T050', 'T060', 'T070', 'T080', 'T090') THEN
                SET V_POW_LOC_CD = '06';
             /* OK LINE(C/FINAL) */
             ELSEIF P_POW_LOC_CD IN ('T100') THEN    		    
                SET V_POW_LOC_CD = '07';
             /* S/OFF */
             ELSEIF P_POW_LOC_CD = 'T110' THEN
                SET V_POW_LOC_CD = '08';
             /* 통제소 */
             ELSEIF P_POW_LOC_CD IN ('T120') THEN
                SET V_POW_LOC_CD = '09';
             /* PDI IN  */
             ELSEIF P_POW_LOC_CD IN ('V010') THEN
                SET V_POW_LOC_CD = '10';
             /* PDI OUT  */
             ELSEIF P_POW_LOC_CD IN ('V020') THEN
                SET V_POW_LOC_CD = '11';
             /* MP 입고 */
             ELSEIF P_POW_LOC_CD IN ('V030', 'V040', 'V050', 'V060') THEN
                SET V_POW_LOC_CD = '11';
             /* 선적 */
             ELSEIF P_POW_LOC_CD IN ('V070', 'V080', 'V090') THEN
                SET V_POW_LOC_CD = '11';
             ELSE
                SET V_POW_LOC_CD = '00';
             END IF;
         END IF;
		 RETURN V_POW_LOC_CD;	 

END//
DELIMITER ;

-- 함수 hkomms.GET_PRDN_PLNT_CD_ERP 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_PRDN_PLNT_CD_ERP`(P_PLNT_CD          VARCHAR(4),
										P_EXPD_CO_CD VARCHAR(4)) RETURNS varchar(3) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_PRDN_PLNT_CD_ERP
 * Function 설명 : ERP 공장코드를 APS 의 공장코드로 변환하는 함수
 *                현대는 없고 기아만 존재하여 기아자동차만 적용함
 * 입력 파라미터    : P_PLNT_CD        생산공장코드
 *                P_EXPD_CO_CD     취급설명서회사코드
 * 리턴값         : V_PRDN_PLNT_CD   생상공장코드
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE V_PRDN_PLNT_CD VARCHAR(3);

	SET V_PRDN_PLNT_CD = 'N';

	IF P_EXPD_CO_CD = '02' THEN
		/* 광주 1공장	 */
		IF P_PLNT_CD = 'KV31' THEN
			SET V_PRDN_PLNT_CD = '7';
		/* 광주 2공장	 */
		ELSEIF P_PLNT_CD = 'KV32' THEN
			SET V_PRDN_PLNT_CD = '6';
		ELSE
			SET V_PRDN_PLNT_CD = 'N';
		END IF;
	ELSE
		SET V_PRDN_PLNT_CD = ' ';
	END IF;	 
	 
	RETURN V_PRDN_PLNT_CD;	 

END//
DELIMITER ;

-- 함수 hkomms.GET_PROD_MST_PROG_MAX_DTL_SN 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_PROD_MST_PROG_MAX_DTL_SN`(P_PRDN_MST_VEHL_CD	    	VARCHAR(4),
			   			 	              P_BN_SN	    	VARCHAR(30),
			   			 	              P_EXPD_CO_CD	    	VARCHAR(4),
			   			 	              P_APL_STRT_YMD	    	VARCHAR(8),
			   			 	              P_APL_FNH_YMD	    	VARCHAR(8),
										  P_VIN 	VARCHAR(17)) RETURNS int(11)
BEGIN
/***************************************************************************
 * Function 명칭 : GET_PROD_MST_PROG_MAX_DTL_SN
 * Function 설명 : 생산마스터 진행 최대 상세일련번호 조회하는 함수
 * 입력 파라미터    : P_PRDN_MST_VEHL_CD          생산마스터차종코드
 *                P_BN_SN                     BODY-NO일련번호
 *                P_EXPD_CO_CD                취급설명서회사코드
 *                P_APL_STRT_YMD              적용시작년월일
 *                P_APL_FNH_YMD               적용종료년월일
 *                P_VIN                       차대번호
 * 리턴값         : V_DTL_SN                    상세일련번호
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_DTL_SN INT; 

			SELECT IFNULL(MAX(DTL_SN), 0) + 1	 
			INTO V_DTL_SN	 
			FROM TB_PROD_MST_PROG_INFO	 
			WHERE PRDN_MST_VEHL_CD = P_PRDN_MST_VEHL_CD	 
			AND BN_SN              = P_BN_SN	 
			AND DL_EXPD_CO_CD      = P_EXPD_CO_CD	 
			AND APL_STRT_YMD       = P_APL_STRT_YMD	 
			AND APL_FNH_YMD        = P_APL_FNH_YMD	 
            AND VIN                = P_VIN;            	 
	 
			RETURN V_DTL_SN;	 
END//
DELIMITER ;

-- 함수 hkomms.GET_TIME_CHK 구조 내보내기
DELIMITER //
CREATE FUNCTION `GET_TIME_CHK`(ET_GUBN_CD VARCHAR(2)) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_general_ci
BEGIN
/***************************************************************************
 * Function 명칭 : GET_TIME_CHK
 * Function 설명 : 오전 배치는 오후2시까지 시도, 오후배치는 오후 10시까지 시도하는 함수
 * 입력 파라미터    : ET_GUBN_CD          전송구분코드
 * 리턴값         : T_CHK               생산결과값
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE T_CHK VARCHAR(1);

            IF ET_GUBN_CD = '02' THEN	 
                  /* 오후 2시까지 Try	 */
                SELECT CASE WHEN SYSDATE() < (DATE_ADD(STR_TO_DATE(DATE_FORMAT(SYSDATE(), '%Y-%m-%d'),'%Y-%m-%d'), INTERVAL 14 HOUR)) THEN 'Y'	 
                            ELSE 'N'	 
                       END CHK	 
                  INTO T_CHK	 
                  FROM DUAL;
            ELSE	 
                 /* 오후 10시까지 Try	  */
                SELECT CASE WHEN SYSDATE() < (DATE_ADD(STR_TO_DATE(DATE_FORMAT(SYSDATE(), '%Y-%m-%d'),'%Y-%m-%d'), INTERVAL 22 HOUR)) THEN 'Y'	 
                            ELSE 'N'	 
                       END CHK	 
                  INTO T_CHK	 
                  FROM DUAL;
            END IF;
            RETURN T_CHK;	 
END//
DELIMITER ;

-- 프로시저 hkomms.SAVE_ODR_BTCH_FNH_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SAVE_ODR_BTCH_FNH_INFO`(IN CURR_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SAVE_ODR_BTCH_FNH_INFO
 * Procedure 설명 : 오더 인터페이스 성공시에 완료일자를 저장
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SAVE_ODR_BTCH_FNH_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

			/*등록전 PK별 정보 있는지 확인*/
			SET V_INEXCNT = 0;
			SELECT COUNT(*)	 
			  INTO V_INEXCNT	 
			  FROM TB_BATCH_FNH_INFO
			WHERE AFFR_SCN_CD = '01'
			AND DL_EXPD_CO_CD =EXPD_CO_CD
			AND BTCH_FNH_YMD = CURR_YMD;
				
			IF V_INEXCNT = 0 THEN
				INSERT INTO TB_BATCH_FNH_INFO	 
				(AFFR_SCN_CD,	 
				 DL_EXPD_CO_CD,	 
				 BTCH_FNH_YMD,	 
				 FRAM_DTM	 
				)	 
				VALUES	 
				('01',	 
				 EXPD_CO_CD,	 
				 CURR_YMD,	 
				 SYSDATE()	 
				);	 
			END IF;


    SET CURR_LOC_NUM = 2;

	COMMIT;
	    

    SET CURR_LOC_NUM = 3;

END//
DELIMITER ;

-- 프로시저 hkomms.SAVE_PROD_BTCH_FNH_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SAVE_PROD_BTCH_FNH_INFO`(IN CURR_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SAVE_PROD_BTCH_FNH_INFO
 * Procedure 설명 : 계획 인터페이스 성공시에 완료일자를 저장
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SAVE_PROD_BTCH_FNH_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

			/*등록전 PK별 정보 있는지 확인*/
			SET V_INEXCNT = 0;
			SELECT COUNT(*)	 
			INTO V_INEXCNT	 
			FROM TB_BATCH_FNH_INFO
			WHERE AFFR_SCN_CD = '02'
			AND DL_EXPD_CO_CD =EXPD_CO_CD
			AND BTCH_FNH_YMD = CURR_YMD;
				
			IF V_INEXCNT = 0 THEN
				INSERT INTO TB_BATCH_FNH_INFO	 
				(AFFR_SCN_CD,	 
				 DL_EXPD_CO_CD,	 
				 BTCH_FNH_YMD,	 
				 FRAM_DTM	 
				)	 
				VALUES	 
				('02',	 
				 EXPD_CO_CD,	 
				 CURR_YMD,	 
				 SYSDATE()	 
				);	 
			END IF;

    SET CURR_LOC_NUM = 2;

	COMMIT;
	    

    SET CURR_LOC_NUM = 3;

END//
DELIMITER ;

-- 프로시저 hkomms.SAVE_PROD_MST_BTCH_FNH_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SAVE_PROD_MST_BTCH_FNH_INFO`(IN CURR_YMD VARCHAR(8),
                                        IN P_ET_GUBN_CD VARCHAR(2),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SAVE_PROD_MST_BTCH_FNH_INFO
 * Procedure 설명 : 인터페이스 성공시에 완료일자를 저장
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 P_ET_GUBN_CD               전송구분코드
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_AFFR_SCN_CD VARCHAR(2);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SAVE_PROD_MST_BTCH_FNH_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',P_ET_GUBN_CD:',IFNULL(P_ET_GUBN_CD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_AFFR_SCN_CD:',IFNULL(V_AFFR_SCN_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

			SET V_AFFR_SCN_CD = '03';	 
	 
			IF P_ET_GUBN_CD = '01' THEN	 
 			   /* 당일 인터페이스 성공시	 */
               SET V_AFFR_SCN_CD = '04';	 
			END IF;	 
	 
			/*등록전 PK별 정보 있는지 확인*/
			SET V_INEXCNT = 0;
			SELECT COUNT(*)	 
			INTO V_INEXCNT	 
			FROM TB_BATCH_FNH_INFO
			WHERE AFFR_SCN_CD = V_AFFR_SCN_CD
			AND DL_EXPD_CO_CD =EXPD_CO_CD
			AND BTCH_FNH_YMD = CURR_YMD;
				
			IF V_INEXCNT = 0 THEN
				INSERT INTO TB_BATCH_FNH_INFO	 
				(	 
					 AFFR_SCN_CD,	 
					 DL_EXPD_CO_CD,	 
					 BTCH_FNH_YMD,	 
					 FRAM_DTM	 
				)	 
				VALUES	 
				(	 
					 V_AFFR_SCN_CD,	 
					 EXPD_CO_CD,	 
					 CURR_YMD,	 
					 SYSDATE()	 
				);	
			END IF;

    SET CURR_LOC_NUM = 2;

	COMMIT;
	    

    SET CURR_LOC_NUM = 3;

END//
DELIMITER ;

-- 프로시저 hkomms.SEND_ERROR_MAIL_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SEND_ERROR_MAIL_HMC`(IN BTCH_NM VARCHAR(100),
                                        IN BTCH_WK_RSLT_SBC VARCHAR(400),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SEND_ERROR_MAIL_HMC
 * Procedure 설명 : 에러발생시 배치관리자에게 메세지를 전송하는 역할 수행
 *                 메일 발송
 *                 배치에러 메일 발송
 * 입력 파라미터    :  BTCH_NM                   배치명
 *                 BTCH_WK_RSLT_SBC          배치작업결과내용
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_MAIL_TITLE		VARCHAR(8000);
	DECLARE V_MAIL_CONTENT		VARCHAR(8000);
	
	DECLARE V_USERNM_1 VARCHAR(50);
	DECLARE V_EMAIL_1 VARCHAR(100);
	DECLARE V_USERID_1 VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE INFO_LIST CURSOR FOR
                    SELECT IFNULL(U.USER_NM,' ') USERNM, IFNULL(U.USER_EML_ADR,' ') EMAIL, IFNULL(U.USER_EENO,' ') USERID 
                    FROM TB_CODE_MGMT C, TB_USR_MGMT U 
                    WHERE C.DL_EXPD_PRVS_NM = U.USER_EENO   
                    AND C.DL_EXPD_G_CD='0037'
                    AND C.USE_YN='Y';

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SEND_ERROR_MAIL_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',BTCH_NM:',IFNULL(BTCH_NM,'')
							,',BTCH_WK_RSLT_SBC:',IFNULL(BTCH_WK_RSLT_SBC,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_MAIL_TITLE:',IFNULL(V_MAIL_TITLE,'')
							,',V_MAIL_CONTENT:',IFNULL(V_MAIL_CONTENT,'')
							,',V_USERNM_1:',IFNULL(V_USERNM_1,'')
							,',V_EMAIL_1:',IFNULL(V_EMAIL_1,'')
							,',V_USERID_1:',IFNULL(V_USERID_1,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END; 

    SET CURR_LOC_NUM = 1;

			/*메일 발송  */
			SET V_MAIL_TITLE   = CONCAT('오너스매뉴얼 ' , BTCH_NM , ' 배치 작업 에러가 발생되었습니다.');
			SET V_MAIL_CONTENT = CONCAT('<HTML><BODY>' ,
						      '배치 에러 정보는 다음과 같습니다.<br>' ,
							  '배치명칭: ' , BTCH_NM , '<br>' ,
							  '에러내용: ' , BTCH_WK_RSLT_SBC , '<br>' ,
							  '시간    : ' , DATE_FORMAT(SYSDATE(), '%Y-%m-%d %H:%i:%s') , '<br>' ,
							  '</BODY></HTML>');


    SET CURR_LOC_NUM = 2;

	OPEN INFO_LIST; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH INFO_LIST INTO V_USERNM_1,V_EMAIL_1,V_USERID_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

			/*배치에러 메일 발송	  */
			/*IF V_EMAIL_1 <> ' ' THEN
			   CALL SP_CHNL_INSERTSIMPLEEMAIL(V_USERNM_1, 
				   						 V_EMAIL_1, 
										 V_USERID_1, 
										 'H', 
										 '0', 
										 '0', 
										 V_MAIL_CONTENT,
                               			 SYSDATE(), 
										 V_MAIL_TITLE, 
										 '0', 
										 '0', 
									     V_USERNM_1, 
                                         V_EMAIL_1,
                                         V_USERID_1);	 
			
			END IF;			*/

	END LOOP JOBLOOP1 ;
	CLOSE INFO_LIST;
	 

    SET CURR_LOC_NUM = 3;


	/*END;
	DELIMITER;
	다음처리*/
	    

	    
END//
DELIMITER ;

-- 프로시저 hkomms.SEND_ERROR_MAIL_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SEND_ERROR_MAIL_KMC`(IN BTCH_NM VARCHAR(100),
                                        IN BTCH_WK_RSLT_SBC VARCHAR(400),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SEND_ERROR_MAIL_KMC
 * Procedure 설명 : 에러발생시 배치관리자에게 메세지를 전송하는 역할 수행
 *                 메일 발송
 *                 배치에러 메일 발송
 * 입력 파라미터    :  BTCH_NM                   배치명
 *                 BTCH_WK_RSLT_SBC          배치작업결과내용
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_USER_NM			VARCHAR(50);
	DECLARE V_USER_EML_ADR		VARCHAR(100);
	DECLARE V_MAIL_TITLE		VARCHAR(8000);
	DECLARE V_MAIL_CONTENT		VARCHAR(8000);

	DECLARE V_USER_EENO_1		VARCHAR(100);
	DECLARE V_USERID_1			VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE USER_LIST CURSOR FOR
                    SELECT C.DL_EXPD_PRVS_NM AS USER_EENO, 
						(SELECT MAX(U.USER_EENO) FROM TB_USR_MGMT U WHERE U.USER_EENO = C.DL_EXPD_PRVS_NM ) USERID
					FROM TB_CODE_MGMT C WHERE C.DL_EXPD_G_CD = '0037' AND C.USE_YN='Y';

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SEND_ERROR_MAIL_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',BTCH_NM:',IFNULL(BTCH_NM,'')
							,',BTCH_WK_RSLT_SBC:',IFNULL(BTCH_WK_RSLT_SBC,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_USER_NM:',IFNULL(V_USER_NM,'')
							,',V_USER_EML_ADR:',IFNULL(V_USER_EML_ADR,'')
							,',V_MAIL_TITLE:',IFNULL(V_MAIL_TITLE,'')
							,',V_MAIL_CONTENT:',IFNULL(V_MAIL_CONTENT,'')
							,',V_USER_EENO_1:',IFNULL(V_USER_EENO_1,'')
							,',V_USERID_1:',IFNULL(V_USERID_1,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

	OPEN USER_LIST; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH USER_LIST INTO V_USER_EENO_1, V_USERID_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

			SELECT IFNULL(USER_NM, ' '),	 
			       IFNULL(USER_EML_ADR, ' ')	 
			INTO V_USER_NM,	 
			     V_USER_EML_ADR	 
			FROM TB_USR_MGMT
			WHERE USER_EENO = FU_RPAD(V_USER_EENO_1, 7);
	 
			/*메일 발송	  */
			SET V_MAIL_TITLE   = CONCAT('오너스매뉴얼 ' , BTCH_NM , ' 배치 작업 에러가 발생되었습니다.');	 
			SET V_MAIL_CONTENT = CONCAT('<HTML><BODY>' ,	 
						      '배치 에러 정보는 다음과 같습니다.<br>' ,	 
							  '배치명칭: ' , BTCH_NM , '<br>' ,	 
							  '에러내용: ' , BTCH_WK_RSLT_SBC , '<br>' ,	 
							  '시간    : ' , DATE_FORMAT(SYSDATE(), '%Y-%m-%d %H:%i:%s') , '<br>' ,	 
							  '</BODY></HTML>');	 
	 
			/*배치에러 메일 발송	  */
			/*IF V_USER_EML_ADR <> ' ' THEN
			   CALL SP_CHNL_INSERTSIMPLEEMAIL(V_USER_NM,	 
				   						 V_USER_EML_ADR,	 
										 V_USERID_1,	 
										 'H',	 
										 '0',	 
										 '0',	 
										 V_MAIL_CONTENT,	 
                               			 SYSDATE(),	 
										 V_MAIL_TITLE,	 
										 '0',	 
										 '0',	 
										 V_USER_NM,	 
				   						 V_USER_EML_ADR,	 
										 V_USERID_1);	 
			
			END IF;	*/	

	END LOOP JOBLOOP1 ;
	CLOSE USER_LIST;
	 

    SET CURR_LOC_NUM = 2;


END//
DELIMITER ;

-- 프로시저 hkomms.SEND_NOAPIM_NATL_INFO_MAIL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SEND_NOAPIM_NATL_INFO_MAIL`(IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_AFFR_SCN_CD VARCHAR(4),
                                        IN P_CURR_YMD VARCHAR(8))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SEND_NOAPIM_NATL_INFO_MAIL
 * Procedure 설명 : 미지정 국가코드 발생 정보 메일 전송하는 역할 수행
 * 입력 파라미터    :  P_EXPD_CO_CD               회사코드
 *                 P_AFFR_SCN_CD              업무구분코드
 *                 P_CURR_YMD                 현재년월일
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CNT INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SEND_NOAPIM_NATL_INFO_MAIL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_AFFR_SCN_CD:',IFNULL(P_AFFR_SCN_CD,'')
							,',P_CURR_YMD:',IFNULL(P_CURR_YMD,'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

			/* 생산마스터인 경우에는 생산계획 배치가 이미 실행된 이후에만 메일을 전송하도록 한다.  */
			IF P_AFFR_SCN_CD = '03' THEN
			   SELECT COUNT(*)
			   INTO V_CNT
			   FROM TB_BATCH_FNH_INFO
			   WHERE AFFR_SCN_CD = '01'
			   AND DL_EXPD_CO_CD = P_EXPD_CO_CD
			   AND BTCH_FNH_YMD = P_CURR_YMD;
			ELSE
			   /* 생산계획인 경우에는 생산마스터 배치가 이미 실행된 이후에만 메일을 전송하도록 한다.  */
			   SELECT COUNT(*)
			   INTO V_CNT
			   FROM TB_BATCH_FNH_INFO
			   WHERE AFFR_SCN_CD = '03'
			   AND DL_EXPD_CO_CD = P_EXPD_CO_CD
			   AND BTCH_FNH_YMD = P_CURR_YMD;
			END IF;
			

    SET CURR_LOC_NUM = 2;

			IF V_CNT > 0 THEN
			   CALL SEND_NOAPIM_NATL_INFO_MAIL_DTL(P_EXPD_CO_CD);
			END IF;


    SET CURR_LOC_NUM = 3;


END//
DELIMITER ;

-- 프로시저 hkomms.SEND_NOAPIM_NATL_INFO_MAIL_DTL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SEND_NOAPIM_NATL_INFO_MAIL_DTL`(IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SEND_NOAPIM_NATL_INFO_MAIL_DTL
 * Procedure 설명 : 미지정 메일 전송
 * 입력 파라미터    :  EXPD_CO_CD                  회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_MAIL_TITLE		VARCHAR(8000);
	DECLARE V_MAIL_CONTENT		VARCHAR(8000);
	DECLARE V_CNT				INT;

	DECLARE V_USER_EENO_1			VARCHAR(20);
	DECLARE V_USER_NM_1			VARCHAR(50);
	DECLARE V_USER_EML_ADR_1		VARCHAR(100);

	DECLARE V_DL_EXPD_NAT_CD_2	VARCHAR(5);
	DECLARE V_NAT_NM_2			VARCHAR(50);
										   
	DECLARE V_QLTY_VEHL_CD_3		VARCHAR(4);
	DECLARE V_MDL_MDY_CD_3		VARCHAR(4);
	DECLARE V_PRDN_MST_NAT_CD_3	VARCHAR(5);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow3 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE CRGR_USER_LIST_INFO CURSOR FOR
           							   SELECT A.USER_EENO AS USER_EENO,
                					   		  IFNULL(A.USER_NM, ' ') AS USER_NM,
											  A.USER_EML_ADR AS USER_EML_ADR
           							   FROM TB_USR_MGMT A,
		   							   		TB_CODE_MGMT B
									   WHERE B.DL_EXPD_G_CD = '0030'
									   AND A.USER_EENO = FU_RPAD(B.DL_EXPD_PRVS_NM, 7)
									   AND B.USE_YN = 'Y'
		   							   AND A.USE_YN = 'Y';

	DECLARE NOAPIM_NATL_INFO CURSOR FOR
		 						    SELECT DL_EXPD_NAT_CD,
		                                   NAT_NM
		 						    FROM TB_NATL_NOAPIM_MGMT
									WHERE DL_EXPD_CO_CD = EXPD_CO_CD
									ORDER BY DL_EXPD_NAT_CD;

	DECLARE PROD_MST_NOAPIM_INFO CURSOR FOR
										SELECT
											A.QLTY_VEHL_CD,
											A.MDL_MDY_CD,
											A.PRDN_MST_NAT_CD
										FROM TB_PROD_MST_NOAPIM_INFO A
										WHERE  (SELECT COUNT(C.QLTY_VEHL_CD)	 
							                        FROM TB_VEHL_MGMT C	 
										            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	 
										            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0
										GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.PRDN_MST_NAT_CD
										ORDER BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.PRDN_MST_NAT_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE, endOfRow3 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SEND_NOAPIM_NATL_INFO_MAIL_DTL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_MAIL_TITLE:',IFNULL(V_MAIL_TITLE,'')
							,',V_MAIL_CONTENT:',IFNULL(V_MAIL_CONTENT,'')
							,',V_USER_EENO_1:',IFNULL(V_USER_EENO_1,'')
							,',V_USER_NM_1:',IFNULL(V_USER_NM_1,'')
							,',V_USER_EML_ADR_1:',IFNULL(V_USER_EML_ADR_1,'')
							,',V_DL_EXPD_NAT_CD_2:',IFNULL(V_DL_EXPD_NAT_CD_2,'')
							,',V_NAT_NM_2:',IFNULL(V_NAT_NM_2,'')
							,',V_QLTY_VEHL_CD_3:',IFNULL(V_QLTY_VEHL_CD_3,'')
							,',V_MDL_MDY_CD_3:',IFNULL(V_MDL_MDY_CD_3,'')
							,',V_PRDN_MST_NAT_CD_3:',IFNULL(V_PRDN_MST_NAT_CD_3,'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

	SET V_CNT = 0;

	OPEN NOAPIM_NATL_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH NOAPIM_NATL_INFO INTO V_DL_EXPD_NAT_CD_2,V_NAT_NM_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;
				
				IF V_CNT = 0 THEN
					SET V_MAIL_CONTENT = CONCAT(V_MAIL_CONTENT ,  '국가/언어 미지정 리스트<br>');
				END IF;
				SET V_MAIL_CONTENT = CONCAT(V_MAIL_CONTENT ,  '&nbsp;&nbsp;' ,  V_DL_EXPD_NAT_CD_2 ,  CASE WHEN V_NAT_NM_2 IS NULL THEN ' '
				                                                                                       ELSE CONCAT(' - ' ,  V_NAT_NM_2)
																								  END
																							   ,  '<br>');
				SET V_CNT = V_CNT + 1;

	END LOOP JOBLOOP2 ;
	CLOSE NOAPIM_NATL_INFO;


    SET CURR_LOC_NUM = 2;

	SET V_CNT = 0;

	OPEN PROD_MST_NOAPIM_INFO; /* cursor 열기 */
	JOBLOOP3 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_NOAPIM_INFO INTO V_QLTY_VEHL_CD_3,V_MDL_MDY_CD_3,V_PRDN_MST_NAT_CD_3;
	IF endOfRow3 THEN
	 LEAVE JOBLOOP3 ;
	END IF;

				IF V_CNT = 0 THEN
					SET V_MAIL_CONTENT = CONCAT(V_MAIL_CONTENT ,  '<br><br>년식 미지정 리스트<br>');
				END IF;
				SET V_MAIL_CONTENT = CONCAT(V_MAIL_CONTENT ,  '&nbsp;&nbsp;' ,  V_QLTY_VEHL_CD_3 ,  '&nbsp;&nbsp;' ,  V_MDL_MDY_CD_3 ,  '&nbsp;&nbsp;' ,  V_PRDN_MST_NAT_CD_3 ,  '<br>');
				SET V_CNT = V_CNT + 1;

	END LOOP JOBLOOP3 ;
	CLOSE PROD_MST_NOAPIM_INFO;


    SET CURR_LOC_NUM = 3;

			IF V_MAIL_CONTENT IS NOT NULL THEN			   
			   SET V_MAIL_TITLE   = CONCAT('오너스매뉴얼 ' ,  ' 현대/기아' ,  ' 국가/언어코드 미지정 국가 내역 확인 바랍니다.');
			   SET V_MAIL_CONTENT = CONCAT('<HTML><BODY>' , 
				                 '현대/기아' ,  ' 국가/언어코드 미지정 국가 내역입니다.<br>확인 후 조치 바랍니다.<br><br>' , 
						         V_MAIL_CONTENT , 
							     '</BODY></HTML>');
			END IF;


    SET CURR_LOC_NUM = 4;

	OPEN CRGR_USER_LIST_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH CRGR_USER_LIST_INFO INTO V_USER_EENO_1,V_USER_NM_1,V_USER_EML_ADR_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
			   	/*IF V_USER_EML_ADR_1 IS NOT NULL THEN
				   CALL SP_CHNL_INSERTSIMPLEEMAIL(V_USER_NM_1,
											 V_USER_EML_ADR_1, 
											 V_USER_EENO_1, 
											 'H', 
											 '0', 
											 '0', 
											 V_MAIL_CONTENT,
                               				 SYSDATE(), 
											 V_MAIL_TITLE, 
											 '0', 
											 '0', 
											 V_USER_NM_1, 
											 V_USER_EML_ADR_1, 
											 V_USER_EENO_1); 	   
				END IF;*/

	END LOOP JOBLOOP1 ;
	CLOSE CRGR_USER_LIST_INFO;

    SET CURR_LOC_NUM = 5;

/*
			EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				WRITE_BATCH_LOG('미지정 국가 메일 발송', SYSDATE(), 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));
				COMMIT;
*/
	/*END;
	DELIMITER;
	다음처리*/	    

	    
END//
DELIMITER ;

-- 프로시저 hkomms.SEND_URGENT_PRINT_MAIL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SEND_URGENT_PRINT_MAIL`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SEND_URGENT_PRINT_MAIL
 * Procedure 설명 : 메일 발송
 * 입력 파라미터    :  P_EXPD_CO_CD       회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_MAIL_TITLE		VARCHAR(8000);
	DECLARE V_MAIL_CONTENT		VARCHAR(8000);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SEND_URGENT_PRINT_MAIL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_MAIL_TITLE:',IFNULL(V_MAIL_TITLE,'')
							,',V_MAIL_CONTENT:',IFNULL(V_MAIL_CONTENT,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	    

    SET CURR_LOC_NUM = 1;

END//
DELIMITER ;

-- 프로시저 hkomms.SET_ERP_ET_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SET_ERP_ET_INFO`(IN P_DL_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SET_ERP_ET_INFO
 * Procedure 설명 : 생산마스터 데이터 전송 완료 일자 설정
 * 입력 파라미터    :  P_DL_EXPD_CO_CD   취급설명서회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-05     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_YMD   VARCHAR(8);
	DECLARE V_APL_YMD    VARCHAR(8);
	DECLARE V_ET_GUBN_CD VARCHAR(2);
	DECLARE V_CNT_HMC		INT;
	DECLARE V_CNT_KMC		INT;
	DECLARE V_EXCNT			INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SET_ERP_ET_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',V_APL_YMD:',IFNULL(V_APL_YMD,'')
							,',P_DL_EXPD_CO_CD:',IFNULL(P_DL_EXPD_CO_CD,'')
							,',V_ET_GUBN_CD:',IFNULL(V_ET_GUBN_CD,'')
							,',V_CNT_HMC:',IFNULL(CONCAT(V_CNT_HMC),'')
							,',V_CNT_KMC:',IFNULL(CONCAT(V_CNT_KMC),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	

    SET CURR_LOC_NUM = 1;

			SET V_CURR_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d');
			SET V_APL_YMD  = DATE_FORMAT(DATE_ADD(SYSDATE(), INTERVAL -1/2 DAY), '%Y%m%d');

			SET V_CNT_HMC = 0;
			SET V_CNT_KMC = 0;

    SET CURR_LOC_NUM = 2;

			IF V_CURR_YMD = V_APL_YMD THEN
				SET V_ET_GUBN_CD = '01';

				SELECT  COUNT(*)
						INTO V_CNT_KMC
					   FROM TB_PROD_MST_INFO_ERP_KMC
					  WHERE APL_YMD = V_CURR_YMD
					  AND ET_GUBN_CD IS NULL;

				SELECT  COUNT(*)
						INTO V_CNT_HMC
					   FROM TB_PROD_MST_INFO_ERP_HMC
					  WHERE APL_YMD = V_CURR_YMD
					  AND ET_GUBN_CD IS NULL;

			ELSE
				SET V_ET_GUBN_CD = '02';

				SELECT  COUNT(*)
						INTO V_CNT_KMC
					   FROM TB_PROD_MST_INFO_ERP_KMC
					  WHERE APL_YMD = V_APL_YMD
					  AND ET_GUBN_CD IS NULL;

				SELECT  COUNT(*)
						INTO V_CNT_HMC
					   FROM TB_PROD_MST_INFO_ERP_HMC
					  WHERE APL_YMD = V_APL_YMD
					  AND ET_GUBN_CD IS NULL;

			END IF;
    SET CURR_LOC_NUM = 3;
            IF ( V_CNT_KMC + V_CNT_HMC ) > 0 THEN
	            UPDATE TB_BATCH_ERP_ET_INFO
	               SET   FRAM_DTM          = SYSDATE(),
	                       ET_GUBN_CD        = V_ET_GUBN_CD
	             WHERE DL_EXPD_CO_CD = P_DL_EXPD_CO_CD
	                AND BTCH_FNH_YMD  = V_APL_YMD
	                AND ET_GUBN_CD       = V_ET_GUBN_CD;

				  SET V_EXCNT = 0;
				  SELECT COUNT(DL_EXPD_CO_CD)	 
				  INTO V_EXCNT	 
				  FROM TB_BATCH_ERP_ET_INFO 
    			  WHERE DL_EXPD_CO_CD = P_DL_EXPD_CO_CD
	                AND BTCH_FNH_YMD  = V_APL_YMD
	                AND ET_GUBN_CD       = V_ET_GUBN_CD;

	            IF V_EXCNT = 0 THEN
	            	INSERT INTO TB_BATCH_ERP_ET_INFO
	                (
	                 DL_EXPD_CO_CD, BTCH_FNH_YMD, ET_GUBN_CD, FRAM_DTM
	                 )
	                 VALUES
	                (
	                 P_DL_EXPD_CO_CD, V_APL_YMD, V_ET_GUBN_CD, SYSDATE()
	                 );
	            END IF;
            END IF;       
    SET CURR_LOC_NUM = 4;     
            COMMIT;

    SET CURR_LOC_NUM = 5;

	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_APS_INTERFACE_DATE_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_APS_INTERFACE_DATE_HMC`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN   
/***************************************************************************
 * Procedure 명칭 : SP_APS_INTERFACE_DATE_HMC
 * Procedure 설명 : 현대 날짜가 변경될 경우 데이터 Summary 작업 수행(외부 호출, 오라클 스케쥴링)
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE STRT_DATE  DATETIME;
	DECLARE CURR_YMD   VARCHAR(8);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_APS_INTERFACE_DATE_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

		 SET STRT_DATE  = SYSDATE();
		 SET CURR_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d');
		 
		 /* 전일의 데이터를 기준으로 취합작업을 수행한다. */
		 /* 오더정보 취합 작업 수행  */
		 CALL SP_GET_APS_ODR_SUM_DTL(CURR_YMD, 
		 					 DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d'),
							 P_EXPD_CO_CD);
									

    SET CURR_LOC_NUM = 2;

		 /* 생산계획정보 취합 작업 수행  */
		 CALL SP_GET_APS_PROD_SUM_DTL(CURR_YMD, 
		 					  DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d'),
							  P_EXPD_CO_CD);
		 

    SET CURR_LOC_NUM = 3;


		 CALL WRITE_BATCH_LOG('0.3 APS일자변경배치작업_HMC', STRT_DATE, 'S', '배치처리완료');

    SET CURR_LOC_NUM = 4;

/*
		 EXCEPTION
		     WHEN OTHERS THEN
			     ROLLBACK;
				 WRITE_BATCH_LOG('0.ERR APS일자변경배치작업_HMC', STRT_DATE, 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));

	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_APS_INTERFACE_DATE_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_APS_INTERFACE_DATE_KMC`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_APS_INTERFACE_DATE_KMC
 * Procedure 설명 : 기아 날짜가 변경될 경우 데이터 Summary 작업 수행(외부 호출, 오라클 스케쥴링)	 
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE CURR_YMD		VARCHAR(8);
	DECLARE STRT_DATE		DATETIME;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_APS_INTERFACE_DATE_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;


		 SET STRT_DATE  = SYSDATE();	 
	 
   		 SET CURR_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d');	 
	 
   		 /*전일의 데이터를 기준으로 취합작업을 수행한다.	 
   		   오더정보 취합 작업 수행	 */
   		 CALL SP_GET_APS_ODR_SUM_DTL(CURR_YMD,	 
		 					 DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d'),	 
   							 '02');	 
	 

    SET CURR_LOC_NUM = 2;

   		 /*생산계획정보 취합 작업 수행	 */
   		 CALL SP_GET_APS_PROD_SUM_DTL(CURR_YMD,	
		 					  DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d'),	 
   							  '02');	 
	 

    SET CURR_LOC_NUM = 3;

	 
   		 CALL WRITE_BATCH_LOG('APS일자변경배치작업_KMC', STRT_DATE, 'S', '배치처리완료');	

    SET CURR_LOC_NUM = 4;
 
	 /*
   		 EXCEPTION	 
   		     WHEN OTHERS THEN	 
   			     ROLLBACK;	 
   				 PG_INTERFACE_APS.WRITE_BATCH_LOG('APS일자변경배치작업_KMC', STRT_DATE, 'F', CONCAT('배치처리실패:[' , SQLERRM , ']'));	 
	 


	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_APS_INTERFACE_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_APS_INTERFACE_HMC`(IN P_EXPD_CO_CD VARCHAR(4))
PROC_BODY : BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_APS_INTERFACE_HMC
 * Procedure 설명 : 현대 APS 인터페이스(외부 호출)
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE STRT_DATE  DATETIME;
	DECLARE CURR_YMD   VARCHAR(8);
	DECLARE V_STATE1   VARCHAR(1);
	DECLARE V_STATE2   VARCHAR(1);
	DECLARE V_APS_STAT VARCHAR(1);
	DECLARE V_FNH_STAT VARCHAR(1);
	DECLARE V_APS_STAT2 VARCHAR(1);
	DECLARE V_FNH_STAT2 VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_APS_INTERFACE_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',V_STATE1:',IFNULL(V_STATE1,'')
							,',V_STATE2:',IFNULL(V_STATE2,'')
							,',V_APS_STAT:',IFNULL(V_APS_STAT,'')
							,',V_FNH_STAT:',IFNULL(V_FNH_STAT,'')
							,',V_APS_STAT2:',IFNULL(V_APS_STAT2,'')
							,',V_FNH_STAT2:',IFNULL(V_FNH_STAT2,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

		 SET STRT_DATE  = SYSDATE();
		 SET CURR_YMD   = DATE_FORMAT(SYSDATE(), '%Y%m%d');
		 
		 /*SET V_STATE1 = APS_ODR_INTERFACE_HMC(CURR_YMD,P_EXPD_CO_CD);*/ 		 	   			 
	     SET V_APS_STAT = 'Y';
	     SET V_FNH_STAT = GET_BTCH_ODR_FNH_YN(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 2;
	     /*APS 데이터가 현재일자의 데이터이며 현재일에 한번도 배치작업을 수행하지 않은 경우라면 배치작업을 수행한다. */
	     IF V_APS_STAT = 'Y' AND V_FNH_STAT = 'N' THEN
    SET CURR_LOC_NUM = 3;
	    	CALL LOAD_APS_ODR_INFO_HMC(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 4;
	    	CALL SP_GET_APS_ODR_SUM2(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 5;
	    	CALL SAVE_ODR_BTCH_FNH_INFO(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 6;
	    	SET V_STATE1 = 'Y';
	     ELSE
    SET CURR_LOC_NUM = 7;
	    	SET V_STATE1 = 'N';
	     END IF;
		

    SET CURR_LOC_NUM = 8;
		 /*SET V_STATE2 = APS_PROD_INTERFACE_HMC(CURR_YMD,P_EXPD_CO_CD);*/	
		 SET V_APS_STAT2  = GET_APS_PROD_EXIST_YN(CURR_YMD, P_EXPD_CO_CD);
		 SET V_FNH_STAT2  = GET_BTCH_PROD_FNH_YN(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 9;
		 /*APS 데이터가 현재일자의 데이터이며 현재일에 한번도 배치작업을 수행하지 않은 경우라면 배치작업을 수행한다.*/
		 IF V_APS_STAT2 = 'Y' AND V_FNH_STAT2 = 'N' THEN
    SET CURR_LOC_NUM = 10;
		 		CALL LOAD_APS_PROD_INFO_HMC(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 11;
				CALL SP_GET_APS_PROD_SUM2(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 12;
			    CALL SAVE_PROD_BTCH_FNH_INFO(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 13;
				SET V_STATE2 = 'Y';
		 ELSE
    SET CURR_LOC_NUM = 14;
				SET V_STATE2 = 'N';
		 END IF;
    SET CURR_LOC_NUM = 15;
         /*
	   	 WRITE_BATCH_LOG('1.2 생산계획정보', STRT_DATE, 'S', '생산계획정보존재여부:' || V_APS_STAT || ', 기처리여부:' || V_FNH_STAT || ', 처리결과:' || V_STATE ); */
		 
		 IF V_STATE1 = 'N' AND V_STATE2 = 'N' THEN
		 	CALL WRITE_BATCH_LOG('1.ERR APS배치작업_HMC', STRT_DATE, 'S', '해당 조건 데이터 없음');
			LEAVE PROC_BODY;
		 END IF;


    SET CURR_LOC_NUM = 16;


		 CALL WRITE_BATCH_LOG('1.3 APS배치작업_HMC', STRT_DATE, 'S', '배치처리완료');
				 

    SET CURR_LOC_NUM = 17;

		 /* 미지정 국가 항목 메일 전송  */
		 /*CALL SEND_NOAPIM_NATL_INFO_MAIL(P_EXPD_CO_CD, '01', CURR_YMD);*/

    SET CURR_LOC_NUM = 18;

		 /*
		 EXCEPTION
		     WHEN OTHERS THEN
			     ROLLBACK;
				 WRITE_BATCH_LOG('1.ERR APS배치작업_HMC', STRT_DATE, 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));

	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_APS_INTERFACE_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_APS_INTERFACE_KMC`(IN P_EXPD_CO_CD VARCHAR(4))
PROC_BODY : BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_APS_INTERFACE_KMC
 * Procedure 설명 : 기아 APS 인터페이스(외부 호출)
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE STRT_DATE  DATE;	 
	DECLARE CURR_YMD   VARCHAR(8);	 
	DECLARE V_STATE1   VARCHAR(1);	 
	DECLARE V_STATE2   VARCHAR(1);
	DECLARE V_APS_STAT VARCHAR(1);
	DECLARE V_FNH_STAT VARCHAR(1); 
	DECLARE V_APS_STAT2 VARCHAR(1);
	DECLARE V_FNH_STAT2 VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_APS_INTERFACE_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',V_STATE1:',IFNULL(V_STATE1,'')
							,',V_STATE2:',IFNULL(V_STATE2,'')
							,',V_APS_STAT:',IFNULL(V_APS_STAT,'')
							,',V_FNH_STAT:',IFNULL(V_FNH_STAT,'')
							,',V_APS_STAT2:',IFNULL(V_APS_STAT2,'')
							,',V_FNH_STAT2:',IFNULL(V_FNH_STAT2,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

		 SET STRT_DATE  = SYSDATE();	 
		 SET CURR_YMD   = DATE_FORMAT(SYSDATE(), '%Y%m%d');	 
	 
		 /*SET V_STATE1 = APS_ODR_INTERFACE_KMC(CURR_YMD,P_EXPD_CO_CD);	 */
	     SET V_APS_STAT = 'Y';
	     SET V_FNH_STAT = GET_BTCH_ODR_FNH_YN(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 2;
    	 /*APS 데이터가 현재일자의 데이터이며 현재일에 한번도 배치작업을 수행하지 않은 경우라면 배치작업을 수행한다.	 */
	     IF V_APS_STAT = 'Y' AND V_FNH_STAT = 'N' THEN
    SET CURR_LOC_NUM = 3;
	    	CALL LOAD_APS_ODR_INFO_KMC(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 4;
	    	CALL SP_GET_APS_ODR_SUM2(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 5;
	    	CALL SAVE_ODR_BTCH_FNH_INFO(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 6;
	    	SET V_STATE1 = 'Y';
	     ELSE
    SET CURR_LOC_NUM = 7;
	    	SET V_STATE1 = 'N';	
	     END IF;
		
    SET CURR_LOC_NUM = 8;
		 /*SET V_STATE2 = APS_PROD_INTERFACE_KMC(CURR_YMD,P_EXPD_CO_CD);	 */		
		 SET V_APS_STAT2  = GET_APS_PROD_EXIST_YN(CURR_YMD, P_EXPD_CO_CD);	 
		 SET V_FNH_STAT2  = GET_BTCH_PROD_FNH_YN(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 9;
		 /*APS 데이터가 현재일자의 데이터이며 현재일에 한번도 배치작업을 수행하지 않은 경우라면 배치작업을 수행한다.	*/ 
		 IF V_APS_STAT2 = 'Y' AND V_FNH_STAT2 = 'N' THEN
    SET CURR_LOC_NUM = 10;
		 	 	CALL LOAD_APS_PROD_INFO_KMC(CURR_YMD, P_EXPD_CO_CD);	 
    SET CURR_LOC_NUM = 11;
				CALL SP_GET_APS_PROD_SUM2(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 12;
			    CALL SAVE_PROD_BTCH_FNH_INFO(CURR_YMD, P_EXPD_CO_CD);
    SET CURR_LOC_NUM = 13;
				SET V_STATE2 = 'Y';
		 ELSE
    SET CURR_LOC_NUM = 14;
				SET V_STATE2 = 'N';
		 END IF;		
	 
    SET CURR_LOC_NUM = 15;
		 IF V_STATE1 = 'N' AND V_STATE2 = 'N' THEN
			LEAVE PROC_BODY;
		 END IF;	 
	 	 
	 
    SET CURR_LOC_NUM = 16;
		 CALL WRITE_BATCH_LOG('APS배치작업_KMC', STRT_DATE, 'S', '배치처리완료');	 
	 

    SET CURR_LOC_NUM = 17;

		 /* 미지정 국가 항목 메일 전송	  */
		 /*CALL SEND_NOAPIM_NATL_INFO_MAIL(P_EXPD_CO_CD, '01', CURR_YMD);	 */

    SET CURR_LOC_NUM = 18;

	 /*
		 EXCEPTION	 
		     WHEN OTHERS THEN ROLLBACK;	 
			 WRITE_BATCH_LOG('APS배치작업_KMC', STRT_DATE, 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));

	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_IF_APM_LOG 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_IF_APM_LOG`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_IF_APM_LOG
 * Procedure 설명 : IF_APM_LOG 테이블 등록 (화면 활용도를 취합하는 시스템에서 조회하여 가져감. 우리는 등록만 하면 됨)
 * 입력 파라미터    :  P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-03     김정은   최초 전환함
 * 수정보완          2023-04-11     안상천   표준화를 위해 변경
 ****************************************************************************/
	DECLARE ID_RUN_START_DT DATETIME DEFAULT SYSDATE();

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_IF_APM_LOG',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',ID_RUN_START_DT:',IFNULL(DATE_FORMAT(ID_RUN_START_DT, '%Y%m%d'),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
  

    SET CURR_LOC_NUM = 8;

    START TRANSACTION;
		
    SET CURR_LOC_NUM = 9;
		DELETE FROM IF_APM_LOG WHERE CRTN_TM >= DATE_SUB(SYSDATE(),INTERVAL 1 DAY) AND CRTN_TM < DATE_SUB(SYSDATE(),INTERVAL 0 DAY);
		
    SET CURR_LOC_NUM = 10;
				
			INSERT INTO IF_APM_LOG
				(
					INFO_SYS_CODE
				   ,SCRIN_ID
				   ,SCRIN_SKLL_CODE
				   ,EMPLYR_ID
				   ,CALL_URL
				   ,CRTN_TM
				   ,FLAG
				)
				(	/* (AS-IS) 현대: C0337, 기아: G0008 (TO-BE) C0337로 사용!!! */
					SELECT 'C0337' AS INFO_SYS_CODE, A.SCRIN_ID AS SCRIN_ID, A.SCRIN_SKLL_CODE AS SCRIN_SKLL_CODE, A.EMPLYR_ID AS EMPLYR_ID, B.PGM_PATH_ADR AS CALL_URL, A.CRTN_TM AS CRTN_TM, '1' AS FLAG
					  FROM (
							SELECT PGM_ID AS SCRIN_ID, USE_TYPE AS SCRIN_SKLL_CODE, USER_ID AS EMPLYR_ID, USE_DTM AS CRTN_TM
							  FROM TB_LOG_USE
							 WHERE DATE_FORMAT(USE_DTM,'%Y%m%d') = DATE_FORMAT(DATE_SUB(SYSDATE(), INTERVAL 1 DAY),'%Y%m%d')
					  ) A, TB_PGM_MGMT B
					 WHERE A.SCRIN_ID = B.MENU_ID
				);

    SET CURR_LOC_NUM = 11;

		
		CALL WRITE_BATCH_LOG('APM로그정보배치', SYSDATE(), 'S', '배치처리완료');   
		

    SET CURR_LOC_NUM = 12;

	COMMIT;
		

    SET CURR_LOC_NUM = 13;

	/*EXCEPTION 
		WHEN OTHERS THEN
        	ROLLBACK;
			CALL WRITE_BATCH_LOG('APM로그정보배치', ID_RUN_START_DT, 'F', '배치처리실패:[' || SQLERRM || ']');*/
		
END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_NEXT_DATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_NEXT_DATE`(IN P_EXEC_NO INT,
                                        IN P_EXEC_DATE_OPT VARCHAR(1),
                                        IN P_HOUR_VAL INT,
                                        IN P_MINUTE_VAL INT)
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_NEXT_DATE
 * Procedure 설명 : 실행번호를 받아 다음 실행을 설정해 주는 프로시져
 * 입력 파라미터    :  P_EXEC_NO                   실행번호
 *                 P_EXEC_DATE_OPT             실행일자구분 (A 금일, B 다음날)
 *                 P_HOUR_VAL             시간값
 *                 P_MINUTE_VAL                 분값
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_NEXT_DATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXEC_DATE_OPT:',IFNULL(P_EXEC_DATE_OPT,'')
							,',P_EXEC_NO:',IFNULL(CONCAT(P_EXEC_NO),'')
							,',P_HOUR_VAL:',IFNULL(CONCAT(P_HOUR_VAL),'')
							,',P_MINUTE_VAL:',IFNULL(CONCAT(P_MINUTE_VAL),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

/*
	IF P_EXEC_DATE_OPT='B' THEN
		DBMS_JOB.NEXT_DATE(P_EXEC_NO, ((STR_TO_DATE(DATE_FORMAT(DATE_ADD(SYSDATE(), INTERVAL 1 DAY), '%Y-%m-%d')) + INTERVAL P_HOUR_VAL HOUR) + INTERVAL P_MINUTE_VAL MINUTE) );
	ELSE
		DBMS_JOB.NEXT_DATE(P_EXEC_NO, (SYSDATE() + INTERVAL P_MINUTE_VAL MINUTE) );
	END IF;
*/


	 /*
EXCEPTION	 
	WHEN OTHERS THEN	 
		ROLLBACK;	 
		PG_INTERFACE_APS.WRITE_BATCH_LOG('생산마스터배치작업_KMC', STRT_DATE, 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));

	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK`(IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_ET_GUBN_CD VARCHAR(2))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK
 * Procedure 설명 : 배치 작업 수행
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_HMC     VARCHAR(1);
	DECLARE V_T_CHK       VARCHAR(1);
	DECLARE V_DATE_DIFF_CNT INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_ET_GUBN_CD:',IFNULL(P_ET_GUBN_CD,'')
							,',V_CHK_HMC:',IFNULL(V_CHK_HMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;
			SET V_DATE_DIFF_CNT = 7;

			CALL SP_NATL_VEHL_LANG_UPDATE(P_EXPD_CO_CD);

    SET CURR_LOC_NUM = 2;

			CALL SP_APS_INTERFACE_HMC(P_EXPD_CO_CD);

    SET CURR_LOC_NUM = 3;

			CALL PROD_MST_INTERFACE_HMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02',  P_EXPD_CO_CD);

    SET CURR_LOC_NUM = 4;


            SELECT CASE WHEN  COUNT(*)=3 THEN 'Y' ELSE 'N' END
              INTO V_CHK_HMC
			  FROM TB_BATCH_FNH_INFO
			 WHERE AFFR_SCN_CD in ('01','02','03')
			   AND DL_EXPD_CO_CD = '01'
			   AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');
			

    SET CURR_LOC_NUM = 5;

			IF V_CHK_HMC = 'Y' THEN
				CALL SP_BATCH_NEXT_DATE(31,
										'B',
										6,
										5
										);

    SET CURR_LOC_NUM = 6;

				CALL SEND_URGENT_PRINT_MAIL(P_EXPD_CO_CD);

    SET CURR_LOC_NUM = 7;

			ELSE
				SET V_T_CHK = GET_TIME_CHK('02');
				IF V_T_CHK = 'Y' THEN
					CALL SP_BATCH_NEXT_DATE(31,
											'A',
											0,
											10
											);

    SET CURR_LOC_NUM = 8;

			    ELSE
			        /*  작업 실패 로그 저장 후 TIME SET */
			        CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_HMC2(02) :: ERP 배치 미실행 확인');

    SET CURR_LOC_NUM = 9;

					CALL SP_BATCH_NEXT_DATE(31,
											'B',
											6,
											5
											);

    SET CURR_LOC_NUM = 10;

			    END IF;
			END IF;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK01 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK01`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK01
 * Procedure 설명 : 오후 생산실적 처리(01)
 *                 배치 처리 전에 국가별 차종코드나 언어 코드 관리에 설정이 없는 경우 체크하여 업데이트 한다.
 *                 긴급인쇄 리스트 이메일 발송	
 *                 작업 실패 로그 저장 후 다음 날 NEXT_DATE SET	
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_KMC		VARCHAR(1);
	DECLARE V_T_CHK		VARCHAR(1);
	DECLARE V_DATE_DIFF_CNT INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK01',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_CHK_KMC:',IFNULL(V_CHK_KMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
       		SET V_DATE_DIFF_CNT = 7;


       		/* 배치 처리 전에 국가별 차종코드나 언어 코드 관리에 설정이 없는 경우 체크하여 업데이트 한다.	  */
       		CALL SP_UPDATE_NATL_VEHL_MGMT(P_EXPD_CO_CD);	 

    SET CURR_LOC_NUM = 2;

       		CALL SP_UPDATE_LANG_MGMT(P_EXPD_CO_CD);	

    SET CURR_LOC_NUM = 3;

            CALL PROD_MST_INTERFACE_KMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01', P_EXPD_CO_CD);  /* 생산정보 처리(당일 기준)	  */
	 

    SET CURR_LOC_NUM = 4;

            SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END	 
              INTO V_CHK_KMC	 
              FROM TB_BATCH_FNH_INFO	 
             WHERE AFFR_SCN_CD = '04'	 
               AND DL_EXPD_CO_CD = '02'	 
               AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');	 
	 

    SET CURR_LOC_NUM = 5;

            IF V_CHK_KMC = 'Y' THEN	 
                /* 기준시간 이전이면 JOB NEXT_DATE 10분 후 SET	  */
				CALL SP_BATCH_NEXT_DATE(10,
										'B',
										14,
										40
										);
                	 

    SET CURR_LOC_NUM = 6;

                /* 긴급인쇄 리스트 이메일 발송	  */
                CALL SEND_URGENT_PRINT_MAIL(P_EXPD_CO_CD);	 

    SET CURR_LOC_NUM = 7;

            ELSE	 
                SET V_T_CHK = GET_TIME_CHK('01');
                IF V_T_CHK = 'Y' THEN	 
                    /* JOB 10MIN DELAY	  */
					CALL SP_BATCH_NEXT_DATE(10,
											'A',
											0,
											10
											);

    SET CURR_LOC_NUM = 8;

                ELSE	 
                    /* 작업 실패 로그 저장 후 다음 날 NEXT_DATE SET	  */
                    CALL WRITE_BATCH_LOG('생산마스터배치작업_KMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_KMC2(01) :: ERP 배치 미실행 확인');

    SET CURR_LOC_NUM = 9;
	
					CALL SP_BATCH_NEXT_DATE(10,
											'B',
											14,
											40
											);

    SET CURR_LOC_NUM = 10;

                END IF;	 
            END IF;	


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK02 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK02`(IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_ET_GUBN_CD VARCHAR(2))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK02
 * Procedure 설명 : 오전 생산실적 처리(02)
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_KMC     VARCHAR(1);	 
	DECLARE V_T_CHK       VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK02',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_ET_GUBN_CD:',IFNULL(P_ET_GUBN_CD,'')
							,',V_CHK_KMC:',IFNULL(V_CHK_KMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

       		/*  배치 처리 전에 국가별 차종코드나 언어 코드 관리에 설정이 없는 경우 체크하여 업데이트 한다.	  */
       		CALL SP_UPDATE_NATL_VEHL_MGMT(P_EXPD_CO_CD);	 

    SET CURR_LOC_NUM = 2;

       		CALL SP_UPDATE_LANG_MGMT(P_EXPD_CO_CD);

    SET CURR_LOC_NUM = 3;

            CALL PROD_MST_INTERFACE_KMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02', P_EXPD_CO_CD);  /*  생산정보 처리(전일 기준)	  */

    SET CURR_LOC_NUM = 4;


            CALL SP_APS_INTERFACE_KMC(P_EXPD_CO_CD);   /*  오더/생산계획 정보 처리	  */

    SET CURR_LOC_NUM = 5;

	 
            SELECT CASE WHEN  COUNT(*)=3 THEN 'Y' ELSE 'N' END
              INTO V_CHK_KMC	 
              FROM TB_BATCH_FNH_INFO	 
             WHERE AFFR_SCN_CD in ('01','02','03')	 
               AND DL_EXPD_CO_CD = '02'	 
               AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');	 
	 

    SET CURR_LOC_NUM = 6;

            IF V_CHK_KMC = 'Y' THEN	 
            /*  JOB NEXT TIME SET	  */
				CALL SP_BATCH_NEXT_DATE(11,
										'B',
										5,
										30
										);

    SET CURR_LOC_NUM = 7;

                /*  긴급인쇄 리스트 이메일 발송	  */
                CALL SEND_URGENT_PRINT_MAIL(P_EXPD_CO_CD);	

    SET CURR_LOC_NUM = 8;
 
            ELSE	 
                SET V_T_CHK = GET_TIME_CHK('01');
                IF V_T_CHK = 'Y' THEN	 
                    /*  JOB 10MIN DELAY	  */
					CALL SP_BATCH_NEXT_DATE(11,
											'A',
											0,
											10
											);

    SET CURR_LOC_NUM = 9;

                ELSE	 
                    /*  작업 실패 로그 저장 후 TIME SET	  */
                    CALL WRITE_BATCH_LOG('생산마스터배치작업_KMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_KMC2(02) :: ERP 배치 미실행 확인');	

    SET CURR_LOC_NUM = 10;

					CALL SP_BATCH_NEXT_DATE(11,
											'B',
											5,
											30
											);

    SET CURR_LOC_NUM = 11;

                END IF;	 
            END IF;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK2 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK2`(IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_ET_GUBN_CD VARCHAR(2))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK2
 * Procedure 설명 : 배치 작업 수행
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_HMC     VARCHAR(1);
	DECLARE V_T_CHK       VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK2',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_ET_GUBN_CD:',IFNULL(P_ET_GUBN_CD,'')
							,',V_CHK_HMC:',IFNULL(V_CHK_HMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

			CALL SP_NATL_VEHL_LANG_UPDATE(P_EXPD_CO_CD);

    SET CURR_LOC_NUM = 2;

			CALL PROD_MST_INTERFACE_HMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01', P_EXPD_CO_CD);


    SET CURR_LOC_NUM = 3;

            SELECT CASE WHEN  COUNT(*)=0 THEN 'N' ELSE 'Y' END
              INTO V_CHK_HMC
			  FROM TB_BATCH_FNH_INFO
			 WHERE AFFR_SCN_CD = '04'
			   AND DL_EXPD_CO_CD = '01'
			   AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');
			

    SET CURR_LOC_NUM = 4;

			IF V_CHK_HMC = 'Y' THEN
			    /*  JOB NEXT TIME SET */
				CALL SP_BATCH_NEXT_DATE(51,
										'B',
										15,
										0
										);

    SET CURR_LOC_NUM = 5;

			ELSE
				SET V_T_CHK = GET_TIME_CHK('01');
				IF V_T_CHK = 'Y' THEN
					CALL SP_BATCH_NEXT_DATE(51,
											'A',
											0,
											10
											);

    SET CURR_LOC_NUM = 6;

			    ELSE
			        /*  작업 실패 로그 저장 후 TIME SET */
			        CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_HMC2(01) :: ERP 배치 미실행 확인');

    SET CURR_LOC_NUM = 7;

					CALL SP_BATCH_NEXT_DATE(51,
											'B',
											15,
											0
											);

    SET CURR_LOC_NUM = 8;

			    END IF;
			END IF;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK_HMC_AM 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK_HMC_AM`()
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK_HMC_AM
 * Procedure 설명 : 오전 생산실적 처리(02)
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_HMC     VARCHAR(1);
	DECLARE V_T_CHK       VARCHAR(1);
	DECLARE V_DATE_DIFF_CNT INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK_HMC_AM',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_CHK_HMC:',IFNULL(V_CHK_HMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;
			SET V_DATE_DIFF_CNT = 7;

			CALL SP_NATL_VEHL_LANG_UPDATE('01');

    SET CURR_LOC_NUM = 2;

			CALL SP_APS_INTERFACE_HMC('01');

    SET CURR_LOC_NUM = 3;

			CALL PROD_MST_INTERFACE_HMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02',  '01');

    SET CURR_LOC_NUM = 4;


            SELECT CASE WHEN  COUNT(*)=3 THEN 'Y' ELSE 'N' END
              INTO V_CHK_HMC
			  FROM TB_BATCH_FNH_INFO
			 WHERE AFFR_SCN_CD in ('01','02','03')
			   AND DL_EXPD_CO_CD = '01'
			   AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');
			

    SET CURR_LOC_NUM = 5;

			IF V_CHK_HMC = 'Y' THEN
				CALL SP_BATCH_NEXT_DATE(31,
										'B',
										6,
										5
										);

    SET CURR_LOC_NUM = 6;

                /*  긴급인쇄 리스트 이메일 발송	  */
				/*CALL SEND_URGENT_PRINT_MAIL('01');*/

    SET CURR_LOC_NUM = 7;

			ELSE
				SET V_T_CHK = GET_TIME_CHK('02');
				IF V_T_CHK = 'Y' THEN
					CALL SP_BATCH_NEXT_DATE(31,
											'A',
											15,
											0
											);

    SET CURR_LOC_NUM = 8;

			    ELSE
			        /*  작업 실패 로그 저장 후 TIME SET */
			        CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_HMC2(02) :: ERP 배치 미실행 확인');

    SET CURR_LOC_NUM = 9;

					CALL SP_BATCH_NEXT_DATE(31,
											'B',
											6,
											5
											);

    SET CURR_LOC_NUM = 10;

			    END IF;
			END IF;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK_HMC_PM 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK_HMC_PM`()
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK_HMC_PM
 * Procedure 설명 : 오후 생산실적 처리(01)
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_HMC     VARCHAR(1);
	DECLARE V_T_CHK       VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK_HMC_PM',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_CHK_HMC:',IFNULL(V_CHK_HMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

			CALL SP_NATL_VEHL_LANG_UPDATE('01');

    SET CURR_LOC_NUM = 2;

			CALL PROD_MST_INTERFACE_HMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01', '01');


    SET CURR_LOC_NUM = 3;

            SELECT CASE WHEN  COUNT(*)=0 THEN 'N' ELSE 'Y' END
              INTO V_CHK_HMC
			  FROM TB_BATCH_FNH_INFO
			 WHERE AFFR_SCN_CD = '04'
			   AND DL_EXPD_CO_CD = '01'
			   AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');
			

    SET CURR_LOC_NUM = 4;

			IF V_CHK_HMC = 'Y' THEN
			    /*  JOB NEXT TIME SET */
				CALL SP_BATCH_NEXT_DATE(51,
										'B',
										15,
										0
										);

    SET CURR_LOC_NUM = 5;

                /*  긴급인쇄 리스트 이메일 발송	  */
				/*CALL SEND_URGENT_PRINT_MAIL('01');*/

			ELSE
				SET V_T_CHK = GET_TIME_CHK('01');
				IF V_T_CHK = 'Y' THEN
					CALL SP_BATCH_NEXT_DATE(51,
											'A',
											6,
											5
											);

    SET CURR_LOC_NUM = 6;

			    ELSE
			        /*  작업 실패 로그 저장 후 TIME SET */
			        CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_HMC2(01) :: ERP 배치 미실행 확인');

    SET CURR_LOC_NUM = 7;

					CALL SP_BATCH_NEXT_DATE(51,
											'B',
											15,
											0
											);

    SET CURR_LOC_NUM = 8;

			    END IF;
			END IF;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK_KMC_AM 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK_KMC_AM`()
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK_KMC_AM
 * Procedure 설명 : 오전 생산실적 처리(02)
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_KMC     VARCHAR(1);	 
	DECLARE V_T_CHK       VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK_KMC_AM',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_CHK_KMC:',IFNULL(V_CHK_KMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

       		/*  배치 처리 전에 국가별 차종코드나 언어 코드 관리에 설정이 없는 경우 체크하여 업데이트 한다.	  */
       		CALL SP_UPDATE_NATL_VEHL_MGMT('02');	 

    SET CURR_LOC_NUM = 2;

       		CALL SP_UPDATE_LANG_MGMT('02');

    SET CURR_LOC_NUM = 3;

            CALL PROD_MST_INTERFACE_KMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02', '02');  /*  생산정보 처리(전일 기준)	  */

    SET CURR_LOC_NUM = 4;


            CALL SP_APS_INTERFACE_KMC('02');   /*  오더/생산계획 정보 처리	  */

    SET CURR_LOC_NUM = 5;

	 
            SELECT CASE WHEN  COUNT(*)=3 THEN 'Y' ELSE 'N' END
              INTO V_CHK_KMC	 
              FROM TB_BATCH_FNH_INFO	 
             WHERE AFFR_SCN_CD in ('01','02','03')	 
               AND DL_EXPD_CO_CD = '02'	 
               AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');	 
	 

    SET CURR_LOC_NUM = 6;

            IF V_CHK_KMC = 'Y' THEN	 
            /*  JOB NEXT TIME SET	  */
				CALL SP_BATCH_NEXT_DATE(11,
										'B',
										5,
										30
										);

    SET CURR_LOC_NUM = 7;

                /*  긴급인쇄 리스트 이메일 발송	  */
                /*CALL SEND_URGENT_PRINT_MAIL('02');*/

    SET CURR_LOC_NUM = 8;
 
            ELSE	 
                SET V_T_CHK = GET_TIME_CHK('02');
                IF V_T_CHK = 'Y' THEN	 
                    /*  JOB 10MIN DELAY	  */
					CALL SP_BATCH_NEXT_DATE(11,
											'A',
										     14,
										     40
											);

    SET CURR_LOC_NUM = 9;

                ELSE	 
                    /*  작업 실패 로그 저장 후 TIME SET	  */
                    CALL WRITE_BATCH_LOG('생산마스터배치작업_KMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_KMC2(02) :: ERP 배치 미실행 확인');	

    SET CURR_LOC_NUM = 10;

					CALL SP_BATCH_NEXT_DATE(11,
											'B',
											5,
											30
											);

    SET CURR_LOC_NUM = 11;

                END IF;	 
            END IF;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_BATCH_WORK_KMC_PM 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_BATCH_WORK_KMC_PM`()
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_BATCH_WORK_KMC_PM
 * Procedure 설명 : 오후 생산실적 처리(01)
 *                 배치 처리 전에 국가별 차종코드나 언어 코드 관리에 설정이 없는 경우 체크하여 업데이트 한다.
 *                 긴급인쇄 리스트 이메일 발송	
 *                 작업 실패 로그 저장 후 다음 날 NEXT_DATE SET	
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CHK_KMC		VARCHAR(1);
	DECLARE V_T_CHK		VARCHAR(1);
	DECLARE V_DATE_DIFF_CNT INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_BATCH_WORK_KMC_PM',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_CHK_KMC:',IFNULL(V_CHK_KMC,'')
							,',V_T_CHK:',IFNULL(V_T_CHK,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
       		SET V_DATE_DIFF_CNT = 7;


       		/* 배치 처리 전에 국가별 차종코드나 언어 코드 관리에 설정이 없는 경우 체크하여 업데이트 한다.	  */
       		CALL SP_UPDATE_NATL_VEHL_MGMT('02');	 

    SET CURR_LOC_NUM = 2;

       		CALL SP_UPDATE_LANG_MGMT('02');	

    SET CURR_LOC_NUM = 3;

            CALL PROD_MST_INTERFACE_KMC2(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01', '02');  /* 생산정보 처리(당일 기준)	  */
	 

    SET CURR_LOC_NUM = 4;

            SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END	 
              INTO V_CHK_KMC	 
              FROM TB_BATCH_FNH_INFO	 
             WHERE AFFR_SCN_CD = '04'	 
               AND DL_EXPD_CO_CD = '02'	 
               AND BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(),'%Y%m%d');	 
	 

    SET CURR_LOC_NUM = 5;

            IF V_CHK_KMC = 'Y' THEN	 
                /* 기준시간 이전이면 JOB NEXT_DATE 10분 후 SET	  */
				CALL SP_BATCH_NEXT_DATE(10,
										'B',
										14,
										40
										);
                	 

    SET CURR_LOC_NUM = 6;

                /* 긴급인쇄 리스트 이메일 발송	  */
                /*CALL SEND_URGENT_PRINT_MAIL('02');*/

    SET CURR_LOC_NUM = 7;

            ELSE	 
                SET V_T_CHK = GET_TIME_CHK('01');
                IF V_T_CHK = 'Y' THEN	 
                    /* JOB 10MIN DELAY	  */
					CALL SP_BATCH_NEXT_DATE(10,
											'A',
											5,
											30
											);

    SET CURR_LOC_NUM = 8;

                ELSE	 
                    /* 작업 실패 로그 저장 후 다음 날 NEXT_DATE SET	  */
                    CALL WRITE_BATCH_LOG('생산마스터배치작업_KMC2', SYSDATE(), 'F', 'PROD_MST_INTERFACE_KMC2(01) :: ERP 배치 미실행 확인');

    SET CURR_LOC_NUM = 9;
	
					CALL SP_BATCH_NEXT_DATE(10,
											'B',
											14,
											40
											);

    SET CURR_LOC_NUM = 10;

                END IF;	 
            END IF;	


END//
DELIMITER ;

-- 프로시저 hkomms.SP_CHNL_INSERTSIMPLEEMAIL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_CHNL_INSERTSIMPLEEMAIL`(IN P_SNAME VARCHAR(50),
                                        IN P_SMAIL VARCHAR(100),
                                        IN P_SID VARCHAR(20),
                                        IN P_SPOS VARCHAR(1),
                                        IN P_RPOS VARCHAR(20),
                                        IN P_CTNSPOS VARCHAR(20),
                                        IN P_CONTENTS VARCHAR(1000),
                                        IN P_SDATE DATETIME,
                                        IN P_SUBJECT VARCHAR(100),
                                        IN P_STATUS VARCHAR(1),
                                        IN P_CTID VARCHAR(20),
                                        IN P_RNAME VARCHAR(20),
                                        IN P_RMAIL VARCHAR(100),
                                        IN P_RID VARCHAR(20))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_CHNL_INSERTSIMPLEEMAIL
 * Procedure 설명 : EMS 단건 발송
 * 입력 파라미터    :  P_SNAME                   발송자명
 *                 P_SMAIL          발송자 이메일 주소
 *                 P_SID              발송자 아이디
 *                 P_SPOS              회사구분필드 (H, K)
 *                 P_RPOS              수신자 그룹위치 (입력값 고정 0)
 *                 P_CTNSPOS              컨텐트위치 (컨텐트 필드에 저장 : 0, 컨텐트가 위치한 URL : 1, 컨텐트 파일의 절대경로 : 2)
 *                 P_CONTENTS              컨텐트 템플릿
 *                 P_SDATE              메일발송일자 (YYYY/MM/DD HH24:MI)
 *                 P_SUBJECT              메일제목
 *                 P_STATUS              예약항목 상태코드 (초기값 0 )
 *                 P_CTID               카테고리 ID (CT_DESC 테이블 참조)
 *                 P_RNAME              수신자명
 *                 P_RMAIL              수신자이메일주소
 *                 P_RID              수신자 아이디
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_MAIL_TITLE		VARCHAR(8000);
	DECLARE V_MAIL_CONTENT		VARCHAR(8000);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_CHNL_INSERTSIMPLEEMAIL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'),
			          		SYSDATE()
			          		  );
				COMMIT;
			END IF;
	     END;
	

    SET CURR_LOC_NUM = 1;

	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_CREATE_WK_DATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_CREATE_WK_DATE`()
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_CREATE_WK_DATE
 * Procedure 설명 : 날짜 데이터 생성(외부 호출)
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_CREATE_WK_DATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생')
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

	CALL SP_CREATE_WK_DATE_DTL(DATE_FORMAT(SYSDATE(), '%Y%m%d'));


    SET CURR_LOC_NUM = 2;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_CREATE_WK_DATE_DTL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_CREATE_WK_DATE_DTL`(IN CURR_YMD VARCHAR(8))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_CREATE_WK_DATE_DTL
 * Procedure 설명 : 날짜 데이터 생성(외부 호출) 세부 실행
 * 입력 파라미터    :  CURR_YMD                  현재년월일
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_DATE		DATETIME;
	DECLARE V_CURR_YMD		VARCHAR(8);
	DECLARE V_CNT			INT;
	DECLARE STRT_DATE		DATETIME;	 
	DECLARE V_DOW_CD		CHAR(1);
	DECLARE i			    INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_CREATE_WK_DATE_DTL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',V_DOW_CD:',IFNULL(V_DOW_CD,'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',i:',IFNULL(CONCAT(i),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

		 SET STRT_DATE = SYSDATE();
		 SET V_CURR_DATE = STR_TO_DATE(CURR_YMD, '%Y%m%d');	

		 SET i=1;
		 JOBLOOPT: LOOP
			 SET V_CURR_YMD = DATE_FORMAT(V_CURR_DATE, '%Y%m%d');	 
			 SET V_DOW_CD   = CONCAT(DAYOFWEEK(V_CURR_DATE));
			 
	 
			 SELECT COUNT(*) INTO V_CNT	 
			 FROM TB_WRK_DATE_MGMT	 
			 WHERE WK_YMD = V_CURR_YMD;	 
	 
			 IF V_CNT = 0 THEN
				INSERT INTO TB_WRK_DATE_MGMT	 
				(WK_YMD,	 
				 DOW_CD,	 
				 HOLI_YN	 
				)	 
				VALUES	 
				(V_CURR_YMD,	 
				 V_DOW_CD,	 
				 CASE WHEN V_DOW_CD IN ('1', '7') THEN 'Y' ELSE 'N' END	 
				);
			 END IF;	 
	 
			SET V_CURR_DATE = DATE_ADD(V_CURR_DATE,INTERVAL 1 DAY);

			SET i=i+1; 
			IF i=365 THEN
				LEAVE JOBLOOPT;
			END IF;
		 END LOOP JOBLOOPT;
	 

    SET CURR_LOC_NUM = 2;

		 COMMIT;	 
	 

    SET CURR_LOC_NUM = 3;

		 CALL WRITE_BATCH_LOG('날짜정보배치', STRT_DATE, 'S', '배치처리완료');	 

    SET CURR_LOC_NUM = 4;

	 /*
		 EXCEPTION	 
		     WHEN OTHERS THEN	 
			     ROLLBACK;	 
				 WRITE_BATCH_LOG('날짜정보배치', STRT_DATE, 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));

	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_DEL_ERP_DATA 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_DEL_ERP_DATA`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_DEL_ERP_DATA
 * Procedure 설명 : ERP 정보 삭제
 * 입력 파라미터    :  P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_DEL_ERP_DATA',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

    DELETE FROM TB_PROD_MST_INFO_ERP_KMC WHERE APL_YMD < DATE_FORMAT(DATE_SUB(SYSDATE(), INTERVAL 60 DAY), '%Y%m%d');

    SET CURR_LOC_NUM = 2;

    COMMIT;	 

    SET CURR_LOC_NUM = 3;


	/* EXCEPTION 처리 */
END//
DELIMITER ;

-- 프로시저 hkomms.SP_EXTRA_REQ_UPDATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_EXTRA_REQ_UPDATE`(IN P_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_EXPD_RQ_SCN_CD VARCHAR(4),
                                        IN P_RQ_QTY INT,
                                        IN P_PREV_RQ_QTY INT,
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(2))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_EXTRA_REQ_UPDATE
 * Procedure 설명 : 별도요청 출고 정보 저장
 *                 이전에 이미 요청등록 처리한 항목에 대한 출고정보를 취소해 준다.
 * 입력 파라미터    :  P_VEHL_CD                   차종코드
 *                 P_MDL_MDY_CD                취급설명서모델년식코드
 *                 P_LANG_CD                   언어코드(KO 한글/국내, EU 영어/미국,..)
 *                 P_N_PRNT_PBCN_NO            신인쇄발간번호
 *                 P_EXPD_RQ_SCN_CD            취급설명서요청구분코드
 *                 P_RQ_QTY                    요청수량
 *                 P_PREV_RQ_QTY               이전요청수량
 *                 P_PRDN_PLNT_CD              생산공장코드
 *                 P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-05     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_RQ_YMD	VARCHAR(8);	 
	DECLARE V_DTL_SN	INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_EXTRA_REQ_UPDATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_RQ_SCN_CD:',IFNULL(P_EXPD_RQ_SCN_CD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_RQ_YMD:',IFNULL(V_RQ_YMD,'')
							,',P_RQ_QTY:',IFNULL(CONCAT(P_RQ_QTY),'')
							,',P_PREV_RQ_QTY:',IFNULL(CONCAT(P_PREV_RQ_QTY),'')
							,',V_DTL_SN:',IFNULL(CONCAT(V_DTL_SN),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

                          
    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			/*이전에 이미 요청등록 처리한 항목에 대한 출고정보를 취소해 준다.	 */
			IF P_PREV_RQ_QTY IS NOT NULL THEN	 
			   SELECT MIN(RQ_YMD)	 
			   INTO V_RQ_YMD	 
			   FROM TB_EXTRA_REQ_INFO	 
			   WHERE QLTY_VEHL_CD = P_VEHL_CD	 
			   AND MDL_MDY_CD = P_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_RQ_SCN_CD = P_EXPD_RQ_SCN_CD	 
			   AND RQ_QTY = P_PREV_RQ_QTY	 
			   AND DLVG_YN = 'Y'	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;


    SET CURR_LOC_NUM = 2;

			   IF V_RQ_YMD IS NOT NULL THEN	 
			   	  SELECT MIN(DTL_SN)	 
			   	  INTO V_DTL_SN	 
			   	  FROM TB_EXTRA_REQ_INFO	 
			   	  WHERE RQ_YMD = V_RQ_YMD	 
			   	  AND QLTY_VEHL_CD = P_VEHL_CD	 
			   	  AND MDL_MDY_CD = P_MDL_MDY_CD	 
			   	  AND LANG_CD = P_LANG_CD	 
			   	  AND DL_EXPD_RQ_SCN_CD = P_EXPD_RQ_SCN_CD	 
			   	  AND RQ_QTY = P_PREV_RQ_QTY	 
			   	  AND DLVG_YN = 'Y'	 
			   	  AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			      AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 

    SET CURR_LOC_NUM = 3;

			   	  IF V_DTL_SN IS NOT NULL THEN	 
				  	 UPDATE TB_EXTRA_REQ_INFO	 
				  	 SET DLVG_YN = 'N',	 
			          	 UPDR_EENO = V_BATCH_USER_EENO,	 
					  	 MDFY_DTM = SYSDATE()	 
				  	 WHERE RQ_YMD = V_RQ_YMD	 
			      	 AND QLTY_VEHL_CD = P_VEHL_CD	 
				  	 AND MDL_MDY_CD = P_MDL_MDY_CD	 
				  	 AND LANG_CD = P_LANG_CD	 
				  	 AND DTL_SN = V_DTL_SN	 
			         AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 
			   	  END IF;	 
			   END IF;	 
			END IF;	 
	 

    SET CURR_LOC_NUM = 4;

			IF P_RQ_QTY IS NOT NULL THEN	 
			   SELECT MIN(RQ_YMD)	 
			   INTO V_RQ_YMD	 
			   FROM TB_EXTRA_REQ_INFO	 
			   WHERE QLTY_VEHL_CD = P_VEHL_CD	 
			   AND MDL_MDY_CD = P_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_RQ_SCN_CD = P_EXPD_RQ_SCN_CD	 
			   AND RQ_QTY = P_RQ_QTY	 
			   AND DLVG_YN = 'N'	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 

    SET CURR_LOC_NUM = 5;

			   IF V_RQ_YMD IS NOT NULL THEN	 
			   	  SELECT MIN(DTL_SN)	 
			   	  INTO V_DTL_SN	 
			   	  FROM TB_EXTRA_REQ_INFO	 
			   	  WHERE RQ_YMD = V_RQ_YMD	 
			   	  AND QLTY_VEHL_CD = P_VEHL_CD	 
			   	  AND MDL_MDY_CD = P_MDL_MDY_CD	 
			   	  AND LANG_CD = P_LANG_CD	 
			   	  AND DL_EXPD_RQ_SCN_CD = P_EXPD_RQ_SCN_CD	 
			   	  AND RQ_QTY = P_RQ_QTY	 
			   	  AND DLVG_YN = 'N'	 
			   	  AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 

    SET CURR_LOC_NUM = 6;

			   	  IF V_DTL_SN IS NOT NULL THEN	 
				  	 UPDATE TB_EXTRA_REQ_INFO	 
				  	 SET DLVG_YN = 'Y',	 
				  	  	 N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO,	 
			          	 UPDR_EENO = V_BATCH_USER_EENO,	 
					  	 MDFY_DTM = SYSDATE()	 
				  	 WHERE RQ_YMD = V_RQ_YMD	 
			      	 AND QLTY_VEHL_CD = P_VEHL_CD	 
				  	 AND MDL_MDY_CD = P_MDL_MDY_CD	 
				  	 AND LANG_CD = P_LANG_CD	 
				  	 AND DTL_SN = V_DTL_SN	 
				  	 AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
			      END IF;	 
			   END IF;	 
			END IF;	 

    SET CURR_LOC_NUM = 7;

	COMMIT;
	    

    SET CURR_LOC_NUM = 8;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_APS_ODR_SUM2 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_APS_ODR_SUM2`(IN CURR_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_GET_APS_ODR_SUM2
 * Procedure 설명 : APS 오더 합계 처리
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_APL_FNH_YMD		VARCHAR(8);
	DECLARE V_MDL_MDY_CD		VARCHAR(2);
	DECLARE V_CNT	            INT;
	
	DECLARE V_QLTY_VEHL_CD_1	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1	VARCHAR(3);
	DECLARE V_MO_PACK_CD_1	VARCHAR(4);
	DECLARE V_ORD_QTY_1	INT;
	DECLARE V_PRDN_PLN_QTY_1	INT;
							
	DECLARE V_QLTY_VEHL_CD_2	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2	VARCHAR(4);
	DECLARE V_LANG_CD_2	VARCHAR(3);
	DECLARE V_MO_PACK_CD_2	VARCHAR(4);
	DECLARE V_ORD_QTY_2	INT;
	DECLARE V_PRDN_PLN_QTY_2	INT;
	DECLARE V_PRDN_PLNT_CD_2	VARCHAR(3); 
	
	DECLARE V_EXCNT   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE APS_ODR_INFO CURSOR FOR
		                                  /*오더내역 조회를 위한 부분	(PDI 공통차종 오더내역 조회 부분 포함) */ 
		 					               WITH T AS (SELECT A.QLTY_VEHL_CD,	 
									              A.MDL_MDY_CD,	 
									   			  B.LANG_CD,	 
									   			  A.MO_PACK_CD,	 
									   			  SUM(A.ORD_QTY) AS ORD_QTY,	 
									   			  SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY	 
		 					               FROM (SELECT QLTY_VEHL_CD,	 
									 		            MDL_MDY_CD,	 
											            MO_PACK_CD,	 
											 			DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											 			SUM(ORD_QTY) AS ORD_QTY,	 
       	                                     			SUM(PRDN_PLN_QTY) AS PRDN_PLN_QTY	 
									             FROM TB_APS_ODR_INFO	 
									  			 WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
                                      			 AND APL_STRT_YMD <= CURR_YMD	 
                                      			 AND APL_FNH_YMD >= CURR_YMD	 
									  			 AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
									  			 AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
									  			 AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
									  			 GROUP BY QLTY_VEHL_CD,	 
									  		   	 	      MDL_MDY_CD,	 
       								           			  MO_PACK_CD,	 
											   			  DL_EXPD_NAT_CD	 
								                ) A,	 
									 			TB_NATL_LANG_MGMT B	 
								           WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
										   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, B.LANG_CD, A.MO_PACK_CD	 
		 					 		   	  )	 
                                SELECT K.QLTY_VEHL_CD,	 
                                       K.MDL_MDY_CD,	 
                                       K.LANG_CD,	 
                                       K.MO_PACK_CD,	 
                                       SUM(K.ORD_QTY) ORD_QTY,	 
                                       SUM(K.PRDN_PLN_QTY) PRDN_PLN_QTY	 
                                FROM	 
                                (	 
                                    SELECT QLTY_VEHL_CD,	 
                                           MDL_MDY_CD,	 
                                           LANG_CD,	 
                                           MO_PACK_CD,	 
                                           ORD_QTY,	 
                                           PRDN_PLN_QTY	 
                                    FROM T	 
	 
                                    UNION ALL	 
	 
                                    SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
                                           B.MDL_MDY_CD,	 
                                           B.LANG_CD,	 
                                           A.MO_PACK_CD,	 
                                           SUM(A.ORD_QTY) AS ORD_QTY,	 
                                           SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY	 
                                    FROM T A,	 
                                         TB_PDI_COM_VEHL_MGMT B	 
                                    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                                    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                                    AND A.LANG_CD = B.LANG_CD	 
                                    GROUP BY B.DIVS_QLTY_VEHL_CD, B.MDL_MDY_CD, B.LANG_CD, A.MO_PACK_CD	 
                                ) K	 
                                GROUP BY K.QLTY_VEHL_CD, K.MDL_MDY_CD, K.LANG_CD, K.MO_PACK_CD;	 

	DECLARE PLNT_ODR_INFO CURSOR FOR
											/*[추가] 2010.04.14.김동근 오더정보 현황 - 공장별 내역 조회	 */
		 					                 WITH T AS (SELECT A.QLTY_VEHL_CD,	 
									                A.MDL_MDY_CD,	 
									   			    B.LANG_CD,	 
									   			    A.MO_PACK_CD,	 
									   			    SUM(A.ORD_QTY) AS ORD_QTY,	 
									   			    SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
													A.PRDN_PLNT_CD	 
		 					                 FROM (SELECT A.QLTY_VEHL_CD,	 
									 		              A.MDL_MDY_CD,	 
											              A.MO_PACK_CD,	 
											 			  A.DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											 			  SUM(A.ORD_QTY) AS ORD_QTY,	 
       	                                     			  SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
														  B.PRDN_PLNT_CD	 
									               FROM TB_APS_ODR_INFO A,	 
												        TB_PLNT_VEHL_MGMT B	 
									  			   WHERE A.DL_EXPD_CO_CD = EXPD_CO_CD	 
                                      			   AND A.APL_STRT_YMD <= CURR_YMD	 
                                      			   AND A.APL_FNH_YMD >= CURR_YMD	 
												   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
												   /*TB_APS_ODR_INFO테이블의 공장코드에는 빈문자가 포함되어 있을 수 있다.	 
												   그래서 TRIM 함수를 사용함	 */
												   AND A.PRDN_PLNT_CD = B.PRDN_PLNT_CD	 
									  			   AND A.QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
									  			   AND A.MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
									  			   AND A.DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
									  			   GROUP BY A.QLTY_VEHL_CD,	 
									  		   	 	        A.MDL_MDY_CD,	 
       								           			    A.MO_PACK_CD,	 
											   			    A.DL_EXPD_NAT_CD,	 
															B.PRDN_PLNT_CD	 
								                  ) A,	 
									 			  TB_NATL_LANG_MGMT B	 
								             WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
										     AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										     AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										     AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										     GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, B.LANG_CD, A.MO_PACK_CD, A.PRDN_PLNT_CD	 
		 					 		   	    )	 
								  SELECT QLTY_VEHL_CD,	 
									     MDL_MDY_CD,	 
									     LANG_CD,	 
									     MO_PACK_CD,	 
									     ORD_QTY,	 
									     PRDN_PLN_QTY,	 
										 PRDN_PLNT_CD	 
								  FROM T	 
	 
								  UNION ALL	 
	 
								  SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								         B.MDL_MDY_CD,	 
									     B.LANG_CD,	 
									     A.MO_PACK_CD,	 
									     SUM(A.ORD_QTY) AS ORD_QTY,	 
									     SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
										 A.PRDN_PLNT_CD	 
								  FROM T A,	 
								       TB_PDI_COM_VEHL_MGMT B	 
							      WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								  AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								  AND A.LANG_CD = B.LANG_CD	 
								  GROUP BY B.DIVS_QLTY_VEHL_CD, B.MDL_MDY_CD, B.LANG_CD, A.MO_PACK_CD, A.PRDN_PLNT_CD;	 



	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE,endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_APS_ODR_SUM2',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_APL_FNH_YMD:',IFNULL(V_APL_FNH_YMD,'')
							,',V_MDL_MDY_CD:',IFNULL(V_MDL_MDY_CD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_MO_PACK_CD_1:',IFNULL(V_MO_PACK_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_MO_PACK_CD_2:',IFNULL(V_MO_PACK_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_ORD_QTY_1:',IFNULL(CONCAT(V_ORD_QTY_1),'')
							,',V_PRDN_PLN_QTY_1:',IFNULL(CONCAT(V_PRDN_PLN_QTY_1),'')
							,',V_ORD_QTY_2:',IFNULL(CONCAT(V_ORD_QTY_2),'')
							,',V_PRDN_PLN_QTY_2:',IFNULL(CONCAT(V_PRDN_PLN_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

			/*과거일에 입력되었으나 데이터가 변경되지 않아서 현재일 이후로 종료일이 설정 되어 있는 경우에는	 
			 종료일을 하루전으로 설정해 준다.	 */
			UPDATE TB_APS_ODR_SUM_INFO A
			SET A.APL_FNH_YMD = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d')	 
			WHERE A.APL_STRT_YMD < CURR_YMD	 
			AND A.APL_FNH_YMD >= CURR_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 2;

			/*현재일에 순수하게 입력된 항목은 삭제하도록 한다.	*/ 
			DELETE FROM TB_APS_ODR_SUM_INFO
			WHERE APL_STRT_YMD = CURR_YMD	 
			AND APL_FNH_YMD >= CURR_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 3;

			/*[추가] 2010.04.14.김동근 오더정보 현황 - 공장별 내역 삭제 기능 추가	 */	 
			UPDATE TB_PLNT_APS_ODR_SUM_INFO A	
			SET A.APL_FNH_YMD = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d')	 
			WHERE A.APL_STRT_YMD < CURR_YMD	 
			AND A.APL_FNH_YMD >= CURR_YMD	
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0; 
	 

    SET CURR_LOC_NUM = 4;

			DELETE FROM TB_PLNT_APS_ODR_SUM_INFO
			WHERE APL_STRT_YMD = CURR_YMD	 
			AND APL_FNH_YMD >= CURR_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0; 



    SET CURR_LOC_NUM = 5;

	OPEN APS_ODR_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH APS_ODR_INFO INTO V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_MO_PACK_CD_1,V_ORD_QTY_1,V_PRDN_PLN_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

    SET CURR_LOC_NUM = 6;
			   /*변경여부를 검사할 데이터가 존재하는지의 여부를 확인	 */
			   SELECT MAX(APL_FNH_YMD)	 
			   INTO V_APL_FNH_YMD	 
			   FROM TB_APS_ODR_SUM_INFO A	 
			   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   AND A.APL_FNH_YMD <= CURR_YMD /*현재일 이전의 데이터에서 조회하도록 한다...	 */
			   AND A.MO_PACK_CD = V_MO_PACK_CD_1	 
		       AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
		       AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
		       AND A.LANG_CD = V_LANG_CD_1;	 
	 
    SET CURR_LOC_NUM = 7;
			   IF V_APL_FNH_YMD IS NULL THEN	 
	 
    SET CURR_LOC_NUM = 8;
				  /*지금까지 한번도 추가되지 않은 경우(무조건 Insert 해 준다.)	 */
				  INSERT INTO TB_APS_ODR_SUM_INFO	 
   		    	  (APL_STRT_YMD,	 
				   APL_FNH_YMD,	 
				   MO_PACK_CD,	 
				   DATA_SN,	 
   				   QLTY_VEHL_CD,	 
   			 	   MDL_MDY_CD,	 
   			 	   LANG_CD,	 
   			 	   ORD_QTY,	 
   			 	   PRDN_PLN_QTY,	 
   			 	   PRDN_QTY,	 
   			 	   FRAM_DTM	 
   				  )	 
				  SELECT CURR_YMD,	 
				         CURR_YMD,	 
						 V_MO_PACK_CD_1,	 
				         A.DATA_SN,	 
						 V_QLTY_VEHL_CD_1,	 
						 V_MDL_MDY_CD_1,	 
						 V_LANG_CD_1,	 
						 V_ORD_QTY_1,	 
						 V_PRDN_PLN_QTY_1,	 
						 V_ORD_QTY_1 - V_PRDN_PLN_QTY_1,	 
						 SYSDATE()	 
				  FROM TB_LANG_MGMT A	 
				  WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
				  AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
				  AND A.LANG_CD = V_LANG_CD_1;	 
	 
    SET CURR_LOC_NUM = 9;
			   ELSE	 
	 
    SET CURR_LOC_NUM = 10;
				   /*바로이전의 데이터가 변경되지 않은 경우에는 종료일 업데이트만 해준다.	 */
				   UPDATE TB_APS_ODR_SUM_INFO A	 
		 	   	   SET APL_FNH_YMD = CURR_YMD /*적용완료일을 현재일로 해준다.	 */
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.MO_PACK_CD = V_MO_PACK_CD_1	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
		       	   AND A.LANG_CD = V_LANG_CD_1	 
				   AND A.ORD_QTY = V_ORD_QTY_1	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_1;

				   SET V_EXCNT = 0;

    SET CURR_LOC_NUM = 11;
				   SELECT COUNT(A.APL_STRT_YMD)
				   INTO V_EXCNT	 
				   FROM TB_APS_ODR_SUM_INFO A
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.MO_PACK_CD = V_MO_PACK_CD_1	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
		       	   AND A.LANG_CD = V_LANG_CD_1	 
				   AND A.ORD_QTY = V_ORD_QTY_1	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_1;
	 
    SET CURR_LOC_NUM = 12;
				   IF V_EXCNT = 0 THEN	 
	 
    SET CURR_LOC_NUM = 13;
					  INSERT INTO TB_APS_ODR_SUM_INFO	 
     		    	      (APL_STRT_YMD,	 
 					       APL_FNH_YMD,	 
 					       MO_PACK_CD,	 
 					       DATA_SN,	 
     				       QLTY_VEHL_CD,	 
     			 	       MDL_MDY_CD,	 
     			 	       LANG_CD,	 
     			 	       ORD_QTY,	 
     			 	       PRDN_PLN_QTY,	 
     			 	       PRDN_QTY,	 
     			 	       FRAM_DTM	 
     				      )	 
 					      SELECT CURR_YMD,	 
 					             CURR_YMD,	 
 							     V_MO_PACK_CD_1,	 
 					             A.DATA_SN,	 
 							     V_QLTY_VEHL_CD_1,	 
 							     V_MDL_MDY_CD_1,	 
 							     V_LANG_CD_1,	 
 							     V_ORD_QTY_1,	 
 							     V_PRDN_PLN_QTY_1,	 
 							     V_ORD_QTY_1 - V_PRDN_PLN_QTY_1,	 
 							     SYSDATE()	 
 					      FROM TB_LANG_MGMT A	 
 					      WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
 					      AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
 					      AND A.LANG_CD = V_LANG_CD_1;
    SET CURR_LOC_NUM = 14;
				   END IF;
			   END IF;

	END LOOP JOBLOOP1 ;
	CLOSE APS_ODR_INFO;
	

    SET CURR_LOC_NUM = 15;

	 
	OPEN PLNT_ODR_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_ODR_INFO INTO V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_MO_PACK_CD_2,V_ORD_QTY_2,V_PRDN_PLN_QTY_2,V_PRDN_PLNT_CD_2; 
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

    SET CURR_LOC_NUM = 16;
			/*[추가] 2010.04.14.김동근 오더정보 현황 - 공장별 내역 저장	 */
			   /*변경여부를 검사할 데이터가 존재하는지의 여부를 확인	  */
			   SELECT MAX(APL_FNH_YMD)	 
			   INTO V_APL_FNH_YMD	 
			   FROM TB_PLNT_APS_ODR_SUM_INFO A	 
			   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   AND A.APL_FNH_YMD <= CURR_YMD /*현재일 이전의 데이터에서 조회하도록 한다...	  */
			   AND A.MO_PACK_CD = V_MO_PACK_CD_2	 
		       AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
		       AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
		       AND A.LANG_CD = V_LANG_CD_2	 
			   AND A.PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;	 
	 
    SET CURR_LOC_NUM = 17;
			   IF V_APL_FNH_YMD IS NULL THEN	 
	 
    SET CURR_LOC_NUM = 18;
				  /*지금까지 한번도 추가되지 않은 경우(무조건 Insert 해 준다.)	 */
				  INSERT INTO TB_PLNT_APS_ODR_SUM_INFO	 
   		    	  (APL_STRT_YMD,	 
				   APL_FNH_YMD,	 
				   MO_PACK_CD,	 
				   DATA_SN,	 
   				   QLTY_VEHL_CD,	 
   			 	   MDL_MDY_CD,	 
   			 	   LANG_CD,	 
   			 	   ORD_QTY,	 
   			 	   PRDN_PLN_QTY,	 
   			 	   PRDN_QTY,	 
   			 	   FRAM_DTM,	 
				   PRDN_PLNT_CD	 
   				  )	 
				  SELECT CURR_YMD,	 
				         CURR_YMD,	 
						 V_MO_PACK_CD_2,	 
				         A.DATA_SN,	 
						 V_QLTY_VEHL_CD_2,	 
						 V_MDL_MDY_CD_2,	 
						 V_LANG_CD_2,	 
						 V_ORD_QTY_2,	 
						 V_PRDN_PLN_QTY_2,	 
						 V_ORD_QTY_2 - V_PRDN_PLN_QTY_2,	 
						 SYSDATE(),	 
						 V_PRDN_PLNT_CD_2	 
				  FROM TB_LANG_MGMT A	 
				  WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
				  AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
				  AND A.LANG_CD = V_LANG_CD_2;	 
	 
    SET CURR_LOC_NUM = 19;
			   ELSE	 
	 
    SET CURR_LOC_NUM = 20;
				   /*바로이전의 데이터가 변경되지 않은 경우에는 종료일 업데이트만 해준다.	 */
				   UPDATE TB_PLNT_APS_ODR_SUM_INFO A	 
		 	   	   SET APL_FNH_YMD = CURR_YMD /*적용완료일을 현재일로 해준다.	 */
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.MO_PACK_CD = V_MO_PACK_CD_2	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
		       	   AND A.LANG_CD = V_LANG_CD_2	 
				   AND A.ORD_QTY = V_ORD_QTY_2	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_2	 
				   AND A.PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				   SET V_EXCNT = 0;

    SET CURR_LOC_NUM = 21;
				   SELECT COUNT(APL_STRT_YMD)
				   INTO V_EXCNT	 
				   FROM TB_PLNT_APS_ODR_SUM_INFO 
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.MO_PACK_CD = V_MO_PACK_CD_2	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
		       	   AND A.LANG_CD = V_LANG_CD_2	 
				   AND A.ORD_QTY = V_ORD_QTY_2	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_2	 
				   AND A.PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;
	 
    SET CURR_LOC_NUM = 22;
				   IF V_EXCNT = 0 THEN	 
	 
    SET CURR_LOC_NUM = 23;
					  INSERT INTO TB_PLNT_APS_ODR_SUM_INFO	 
     		    	      (APL_STRT_YMD,	 
 					       APL_FNH_YMD,	 
 					       MO_PACK_CD,	 
 					       DATA_SN,	 
     				       QLTY_VEHL_CD,	 
     			 	       MDL_MDY_CD,	 
     			 	       LANG_CD,	 
     			 	       ORD_QTY,	 
     			 	       PRDN_PLN_QTY,	 
     			 	       PRDN_QTY,	 
     			 	       FRAM_DTM,	 
						   PRDN_PLNT_CD	 
     				      )	 
 					      SELECT CURR_YMD,	 
 					             CURR_YMD,	 
 							     V_MO_PACK_CD_2,	 
 					             A.DATA_SN,	 
 							     V_QLTY_VEHL_CD_2,	 
 							     V_MDL_MDY_CD_2,	 
 							     V_LANG_CD_2,	 
 							     V_ORD_QTY_2,	 
 							     V_PRDN_PLN_QTY_2,	 
 							     V_ORD_QTY_2 - V_PRDN_PLN_QTY_2,	 
 							     SYSDATE(),	 
								 V_PRDN_PLNT_CD_2	 
 					      FROM TB_LANG_MGMT A	 
 					      WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
 					      AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
 					      AND A.LANG_CD = V_LANG_CD_2;
    SET CURR_LOC_NUM = 24;
				   END IF;
			   END IF;

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_ODR_INFO;


    SET CURR_LOC_NUM = 25;

	/*오더정보 취합 작업 수행	 */
	CALL SP_GET_APS_ODR_SUM_DTL(CURR_YMD,	 
						     CURR_YMD,	 
						     EXPD_CO_CD);



    SET CURR_LOC_NUM = 26;

	/*END;
	DELIMITER;
	다음처리*/


	COMMIT;
	    

    SET CURR_LOC_NUM = 27;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_APS_ODR_SUM_DTL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_APS_ODR_SUM_DTL`(IN CURR_YMD VARCHAR(8),
                                        IN SRCH_YMD VARCHAR(8),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GET_APS_ODR_SUM_DTL
 * Procedure 설명 : 화면에 표시되는 데이터의 형태로 오더 정보를 취합하는 작업을 수행
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 SRCH_YMD                   조회년월일
 *                 P_EXPD_CO_CD               회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_PACK		VARCHAR(4);
	DECLARE V_PREV_PACK		VARCHAR(4);
	DECLARE V_CURR_DATE		DATETIME;
	
	DECLARE V_DATA_SN_1 INT;
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1 VARCHAR(4); 
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_CURR_ORD_QTY_1 INT;
	DECLARE V_PREV_ORD_QTY_1 INT;	 
											  
	DECLARE V_DATA_SN_2 INT;
	DECLARE V_QLTY_VEHL_CD_2 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2 VARCHAR(4); 
	DECLARE V_LANG_CD_2 VARCHAR(3);
	DECLARE V_CURR_ORD_QTY_2 INT;
	DECLARE V_PREV_ORD_QTY_2 INT;
	DECLARE V_PRDN_PLNT_CD_2 VARCHAR(3);
	
	DECLARE V_EXCNT			        INT;
	DECLARE V_EXCNT2			    INT;

	DECLARE EXPD_CO_CD VARCHAR(4);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE APS_ODR_SUM_INFO CURSOR FOR
				   					   SELECT MAX(K.DATA_SN) AS DATA_SN,	 
									   		  K.QLTY_VEHL_CD,	 
											  K.MDL_MDY_CD,	 
											  K.LANG_CD,	 
									   		  SUM(K.CURR_ORD_QTY) AS CURR_ORD_QTY,	 
											  SUM(K.PREV_ORD_QTY) AS PREV_ORD_QTY	 
				   					   FROM (SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				SUM(A.ORD_QTY) AS CURR_ORD_QTY,	 
													0 AS PREV_ORD_QTY	 
									   		 FROM TB_APS_ODR_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 			 AND A.APL_FNH_YMD >= SRCH_YMD	 
											 AND A.MO_PACK_CD = V_CURR_PACK	 											 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS CURR_ORD_QTY,	 
													SUM(PRDN_PLN_QTY) AS PREV_ORD_QTY	 
									   		 FROM TB_APS_ODR_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 			 AND A.APL_FNH_YMD >= SRCH_YMD	 
											 AND A.MO_PACK_CD <= V_PREV_PACK
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
											) K	 
									   WHERE K.CURR_ORD_QTY + K.PREV_ORD_QTY > 0	 
									   GROUP BY K.QLTY_VEHL_CD, K.MDL_MDY_CD, K.LANG_CD;	 

	DECLARE PLNT_ODR_SUM_INFO CURSOR FOR
									/* 2010.04.14.김동근 오더정보 현황 - 공장별 Summary 내역 조회	 */
				   					    SELECT MAX(K.DATA_SN) AS DATA_SN,	 
									   		   K.QLTY_VEHL_CD,	 
											   K.MDL_MDY_CD,	 
											   K.LANG_CD,	 
									   		   SUM(K.CURR_ORD_QTY) AS CURR_ORD_QTY,	 
											   SUM(K.PREV_ORD_QTY) AS PREV_ORD_QTY,	 
											   K.PRDN_PLNT_CD	 
				   					    FROM (SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				 A.QLTY_VEHL_CD,	 
													 A.MDL_MDY_CD,	 
													 A.LANG_CD,	 
									   				 SUM(A.ORD_QTY) AS CURR_ORD_QTY,	 
													 0 AS PREV_ORD_QTY,	 
													 A.PRDN_PLNT_CD	 
									   		  FROM TB_PLNT_APS_ODR_SUM_INFO A,	 
									   		       TB_VEHL_MGMT B	 
											  WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											  AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											  AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											  AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 			  AND A.APL_FNH_YMD >= SRCH_YMD	 
											  AND A.MO_PACK_CD = V_CURR_PACK	 
											  GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											  UNION ALL	 
	 
											  SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				 A.QLTY_VEHL_CD,	 
													 A.MDL_MDY_CD,	 
													 A.LANG_CD,	 
									   				 0 AS CURR_ORD_QTY,	 
													 SUM(PRDN_PLN_QTY) AS PREV_ORD_QTY,	 
													 A.PRDN_PLNT_CD	 
									   		  FROM TB_PLNT_APS_ODR_SUM_INFO A,	 
									   		       TB_VEHL_MGMT B	 
											  WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											  AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											  AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											  AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 			  AND A.APL_FNH_YMD >= SRCH_YMD	 
											  AND A.MO_PACK_CD <= V_PREV_PACK	 
											  GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
											 ) K	 
									    WHERE K.CURR_ORD_QTY + K.PREV_ORD_QTY > 0	 
									    GROUP BY K.QLTY_VEHL_CD, K.MDL_MDY_CD, K.LANG_CD, K.PRDN_PLNT_CD;	

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_APS_ODR_SUM_DTL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',SRCH_YMD:',IFNULL(SRCH_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_CURR_PACK:',IFNULL(V_CURR_PACK,'')
							,',V_PREV_PACK:',IFNULL(V_PREV_PACK,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',V_DATA_SN_1:',IFNULL(CONCAT(V_DATA_SN_1),'')
							,',V_CURR_ORD_QTY_1:',IFNULL(CONCAT(V_CURR_ORD_QTY_1),'')
							,',V_PREV_ORD_QTY_1:',IFNULL(CONCAT(V_PREV_ORD_QTY_1),'')
							,',V_DATA_SN_2:',IFNULL(CONCAT(V_DATA_SN_2),'')
							,',V_CURR_ORD_QTY_2:',IFNULL(CONCAT(V_CURR_ORD_QTY_2),'')
							,',V_PREV_ORD_QTY_2:',IFNULL(CONCAT(V_PREV_ORD_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_EXCNT2:',IFNULL(CONCAT(V_EXCNT2),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET EXPD_CO_CD = P_EXPD_CO_CD;

    SET CURR_LOC_NUM = 2;
	SET V_CURR_DATE = STR_TO_DATE(CURR_YMD, '%Y%m%d');
    SET CURR_LOC_NUM = 3;
	SET V_CURR_PACK = SUBSTR(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),3,4);
    SET CURR_LOC_NUM = 4;
	SET V_PREV_PACK = SUBSTR(DATE_FORMAT(ADDDATE(DATE_FORMAT(V_CURR_DATE,'%Y-%m-%d'), INTERVAL -1 MONTH), '%Y%m%d'),3,4);
    SET CURR_LOC_NUM = 5;

			/*이미 입력되었던 항목이 있다면 초기화 해준 후 진행한다.	 
			  [주의] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된	 
			         내역만을 삭제해 주어야 한다.*/
	 
			UPDATE TB_APS_PROD_SUM_INFO A	 
			SET A.TMM_ORD_QTY = 0,	 
			    A.BORD_QTY = 0,	 
				A.MDFY_DTM = SYSDATE()	 
			WHERE A.APL_YMD = CURR_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0; 
	 

    SET CURR_LOC_NUM = 6;

			/*[추가] 2010.04.14.김동근 오더정보 현황 - 공장별 Summary 내역 초기화	 */
			UPDATE TB_PLNT_APS_PROD_SUM_INFO A	 
			SET A.TMM_ORD_QTY = 0,	 
			    A.BORD_QTY = 0,	 
				A.MDFY_DTM = SYSDATE()	 
			WHERE A.APL_YMD = CURR_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0; 
	 


    SET CURR_LOC_NUM = 7;


	OPEN APS_ODR_SUM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH APS_ODR_SUM_INFO INTO V_DATA_SN_1,V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_CURR_ORD_QTY_1,V_PREV_ORD_QTY_1;	
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

    SET CURR_LOC_NUM = 8;

				UPDATE TB_APS_PROD_SUM_INFO	 
				SET TMM_ORD_QTY = V_CURR_ORD_QTY_1,	 
				    BORD_QTY = V_PREV_ORD_QTY_1,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;	

    SET CURR_LOC_NUM = 9; 

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_APS_PROD_SUM_INFO 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;

    SET CURR_LOC_NUM = 10;
					 
				IF V_EXCNT = 0 THEN

    SET CURR_LOC_NUM = 11;
					UPDATE TB_APS_PROD_SUM_INFO	 
					SET DATA_SN = V_DATA_SN_1,	 
						TMM_ORD_QTY = V_CURR_ORD_QTY_1,	 
					    BORD_QTY = V_PREV_ORD_QTY_1,	 
						MDFY_DTM = SYSDATE()	 
					WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
						AND LANG_CD = V_LANG_CD_1;	


    SET CURR_LOC_NUM = 12;
					SET V_EXCNT2 = 0;
					SELECT COUNT(APL_YMD)	 
					  INTO V_EXCNT2	 
					  FROM TB_APS_PROD_SUM_INFO 
					WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND DATA_SN      = V_DATA_SN_1;
						/*AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
						AND LANG_CD = V_LANG_CD_1*/


    SET CURR_LOC_NUM = 13;
					IF V_EXCNT2 = 0 THEN

    SET CURR_LOC_NUM = 14;
					   INSERT INTO TB_APS_PROD_SUM_INFO	 
					   (APL_YMD,	 
					    DATA_SN,	 
						QLTY_VEHL_CD,	 
						MDL_MDY_CD,	 
						LANG_CD,	 
						TMM_ORD_QTY,	 
						BORD_QTY,	 
						FRAM_DTM,	 
						MDFY_DTM	 
					   )	 
					   VALUES	 
					   (CURR_YMD,	 
					    V_DATA_SN_1,	 
						V_QLTY_VEHL_CD_1,	 
						V_MDL_MDY_CD_1,	 
						V_LANG_CD_1,	 
						V_CURR_ORD_QTY_1,	 
						V_PREV_ORD_QTY_1,	 
						SYSDATE(),	 
						SYSDATE()	 
					   );

    SET CURR_LOC_NUM = 15;
					END IF;
				END IF;	 
	 

	END LOOP JOBLOOP1 ;
	CLOSE APS_ODR_SUM_INFO;
	 


    SET CURR_LOC_NUM = 20;


	OPEN PLNT_ODR_SUM_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_ODR_SUM_INFO INTO V_DATA_SN_2,V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_CURR_ORD_QTY_2,V_PREV_ORD_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;


    SET CURR_LOC_NUM = 21;
				UPDATE TB_PLNT_APS_PROD_SUM_INFO	 
				SET TMM_ORD_QTY = V_CURR_ORD_QTY_2,	 
				    BORD_QTY = V_PREV_ORD_QTY_2,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

    SET CURR_LOC_NUM = 22;

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PLNT_APS_PROD_SUM_INFO	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

    SET CURR_LOC_NUM = 23;

				IF V_EXCNT = 0 THEN

    SET CURR_LOC_NUM = 24;
				   INSERT INTO TB_PLNT_APS_PROD_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					TMM_ORD_QTY,	 
					BORD_QTY,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					PRDN_PLNT_CD	 
				   )	 
				   VALUES	 
				   (CURR_YMD,	 
				    V_DATA_SN_2,	 
					V_QLTY_VEHL_CD_2,	 
					V_MDL_MDY_CD_2,	 
					V_LANG_CD_2,	 
					V_CURR_ORD_QTY_2,	 
					V_PREV_ORD_QTY_2,	 
					SYSDATE(),	 
					SYSDATE(),	 
					V_PRDN_PLNT_CD_2	 
				   );

    SET CURR_LOC_NUM = 25;
				END IF;	 

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_ODR_SUM_INFO;
	 

    SET CURR_LOC_NUM = 30;




	/*END;
	DELIMITER;
	다음처리*/
	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 31;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_APS_PROD_SUM2 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_APS_PROD_SUM2`(IN CURR_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GET_APS_PROD_SUM2
 * Procedure 설명 : 국가코드 조회
 *                 생산계획 데이터 조회(PDI 공통차종 오더내역 조회 부분 포함)
 *                 생산계획정보 현황 - 공장별 내역 조회
 *                 연계국가코드 미사용으로 제외
 *                 국가미지정 생산 계획정보는 현시점부터 가져오지 않도록 한다.
 *                 과거일에 입력되었으나 데이터가 변경되지 않아서 현재일 이후로 종료일이 설정 되어 있는 경우에는 종료일을 하루전으로 설정해 준다.
 *                 현재일에 순수하게 입력된 항목은 삭제하도록 한다.
 *                 생산계획정보 현황 - 공장별 내역 삭제 기능 추가
 * 입력 파라미터    :  CURR_YMD                    마감년월일
 *                 EXPD_CO_CD                  회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_APL_FNH_YMD		VARCHAR(4);
	DECLARE V_MDL_MDY_CD		VARCHAR(2);
	DECLARE V_CNT				INT;
	
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_PLN_PARR_YMD_1 VARCHAR(8);
	DECLARE V_PRDN_PLN_QTY_1 INT;
	DECLARE V_DCSN_YN_1 VARCHAR(1);
	DECLARE V_DCSN_YMD_1 VARCHAR(8);
										
	DECLARE V_QLTY_VEHL_CD_2 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2 VARCHAR(4); 
	DECLARE V_LANG_CD_2 VARCHAR(3);
	DECLARE V_PLN_PARR_YMD_2 VARCHAR(8);
	DECLARE V_PRDN_PLN_QTY_2 INT;
	DECLARE V_DCSN_YN_2 VARCHAR(1);
	DECLARE V_DCSN_YMD_2 VARCHAR(8);
	DECLARE V_PRDN_PLNT_CD_2 VARCHAR(3);
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE APS_PROD_INFO CURSOR FOR
		 /*생산계획 데이터 조회를 위한 부분	(PDI 공통차종 오더내역 조회 부분 포함) */ 
		 					  	 			WITH T AS (SELECT A.QLTY_VEHL_CD,	 
		 					  	           		   A.MDL_MDY_CD,	 
		 					  	 				   B.LANG_CD,	 
       								    		   A.PLN_PARR_YMD,	 
       								    		   SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
       											   MIN(A.DCSN_YN) AS DCSN_YN,	 
												   MAX(A.DCSN_YMD) AS DCSN_YMD	 
		 					  	 			FROM (SELECT QLTY_VEHL_CD,	 
								 	  		  	 		 MDL_MDY_CD,	 
											  			 DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											  			 PLN_PARR_YMD,	 
											  			 SUM(PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
											  			 MIN(DCSN_YN) AS DCSN_YN,	 
											  			 MAX(DCSN_YMD) AS DCSN_YMD	 
									   			  FROM TB_APS_PROD_PLAN_INFO	 
									   			  WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
                                       			  AND APL_STRT_YMD <= CURR_YMD	 
                                       			  AND APL_FNH_YMD >= CURR_YMD	 
									   			  AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
									   			  AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	  */
									   			  AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	  */
									   			  GROUP BY QLTY_VEHL_CD,	 
									  		      		   MDL_MDY_CD,	 
														   PLN_PARR_YMD,	 
       													   DL_EXPD_NAT_CD	 
								      			 ) A,	 
									  			 TB_NATL_LANG_MGMT B	 
								            WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
								 			AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
								 			AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 			AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 			GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, B.LANG_CD, A.PLN_PARR_YMD	 
		 					  	 	  	   )	 
								 SELECT QLTY_VEHL_CD,	 
								 		MDL_MDY_CD,	 
										LANG_CD,	 
										PLN_PARR_YMD,	 
										PRDN_PLN_QTY,	 
										DCSN_YN,	 
										DCSN_YMD	 
								 FROM T	 
	 
								 UNION ALL	 
	 
								 SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								        B.MDL_MDY_CD,	 
									    B.LANG_CD,	 
									    A.PLN_PARR_YMD,	 
									   SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
									   MIN(A.DCSN_YN) AS DCSN_YN,	 
									   MAX(A.DCSN_YMD) AS DCSN_YMD	 
								 FROM T A,	 
								      TB_PDI_COM_VEHL_MGMT B	 
							     WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 AND A.LANG_CD = B.LANG_CD	 
								 GROUP BY B.DIVS_QLTY_VEHL_CD, B.MDL_MDY_CD, B.LANG_CD, A.PLN_PARR_YMD;	 

	DECLARE PLNT_PROD_INFO CURSOR FOR
		 /*[추가] 2010.04.15.김동근 생산계획정보 현황 - 공장별 내역 조회	 */
		 					  	 			 WITH T AS (SELECT A.QLTY_VEHL_CD,	 
		 					  	           		    A.MDL_MDY_CD,	 
		 					  	 				    B.LANG_CD,	 
       								    		    A.PLN_PARR_YMD,	 
       								    		    SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
       											    MIN(A.DCSN_YN) AS DCSN_YN,	 
												    MAX(A.DCSN_YMD) AS DCSN_YMD,	 
													A.PRDN_PLNT_CD	 
		 					  	 			 FROM (SELECT A.QLTY_VEHL_CD,	 
								 	  		  	 		  A.MDL_MDY_CD,	 
											  			  A.DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											  			  A.PLN_PARR_YMD,	 
											  			  SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
											  			  MIN(A.DCSN_YN) AS DCSN_YN,	 
											  			  MAX(A.DCSN_YMD) AS DCSN_YMD,	 
														  B.PRDN_PLNT_CD	 
									   			   FROM TB_APS_PROD_PLAN_INFO A,	 
												   		TB_PLNT_VEHL_MGMT B	 
									   			   WHERE A.DL_EXPD_CO_CD = EXPD_CO_CD	 
                                       			   AND A.APL_STRT_YMD <= CURR_YMD	 
                                       			   AND A.APL_FNH_YMD >= CURR_YMD	 
												   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
												   /*TB_APS_PROD_PLAN_INFO테이블의 공장코드에는 빈문자가 포함되어 있을 수 있다.	 
												     그래서 TRIM 함수를 사용함	*/ 
												   AND TRIM(A.PRDN_PLNT_CD) = B.PRDN_PLNT_CD	 
									   			   AND A.QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */ 
									   			   AND A.MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */ 
									   			   AND A.DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	*/  
									   			   GROUP BY A.QLTY_VEHL_CD,	 
									  		      		    A.MDL_MDY_CD,	 
														    A.PLN_PARR_YMD,	 
       													    A.DL_EXPD_NAT_CD,	 
															B.PRDN_PLNT_CD	 
								      			  ) A,	 
									  			  TB_NATL_LANG_MGMT B	 
								             WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
								 			 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
								 			 AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 			 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, B.LANG_CD, A.PLN_PARR_YMD, A.PRDN_PLNT_CD	 
		 					  	 	  	    )	 
								  SELECT QLTY_VEHL_CD,	 
								 		 MDL_MDY_CD,	 
										 LANG_CD,	 
										 PLN_PARR_YMD,	 
										 PRDN_PLN_QTY,	 
										 DCSN_YN,	 
										 DCSN_YMD,	 
										 PRDN_PLNT_CD	 
								  FROM T	 
	 
								  UNION ALL	 
	 
								  SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								         B.MDL_MDY_CD,	 
									     B.LANG_CD,	 
									     A.PLN_PARR_YMD,	 
									     SUM(A.PRDN_PLN_QTY) AS PRDN_PLN_QTY,	 
									     MIN(A.DCSN_YN) AS DCSN_YN,	 
									     MAX(A.DCSN_YMD) AS DCSN_YMD,	 
										 A.PRDN_PLNT_CD	 
								  FROM T A,	 
								       TB_PDI_COM_VEHL_MGMT B	 
							      WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								  AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								  AND A.LANG_CD = B.LANG_CD	 
								  GROUP BY B.DIVS_QLTY_VEHL_CD, B.MDL_MDY_CD, B.LANG_CD, A.PLN_PARR_YMD, A.PRDN_PLNT_CD;	

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_APS_PROD_SUM2',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_APL_FNH_YMD:',IFNULL(V_APL_FNH_YMD,'')
							,',V_MDL_MDY_CD:',IFNULL(V_MDL_MDY_CD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_PLN_PARR_YMD_1:',IFNULL(V_PLN_PARR_YMD_1,'')
							,',V_DCSN_YN_1:',IFNULL(V_DCSN_YN_1,'')
							,',V_DCSN_YMD_1:',IFNULL(V_DCSN_YMD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PLN_PARR_YMD_2:',IFNULL(V_PLN_PARR_YMD_2,'')
							,',V_DCSN_YN_2:',IFNULL(V_DCSN_YN_2,'')
							,',V_DCSN_YMD_2:',IFNULL(V_DCSN_YMD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_PRDN_PLN_QTY_1:',IFNULL(CONCAT(V_PRDN_PLN_QTY_1),'')
							,',V_PRDN_PLN_QTY_2:',IFNULL(CONCAT(V_PRDN_PLN_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
	 
			/*과거일에 입력되었으나 데이터가 변경되지 않아서 현재일 이후로 종료일이 설정 되어 있는 경우에는	 
			  종료일을 하루전으로 설정해 준다.	 */
			UPDATE TB_APS_PROD_PLAN_SUM_INFO A	 
			SET A.APL_FNH_YMD = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d')	
			WHERE A.APL_STRT_YMD < CURR_YMD	 
			AND A.APL_FNH_YMD >= CURR_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;

	 

    SET CURR_LOC_NUM = 2;

			/*현재일에 순수하게 입력된 항목은 삭제하도록 한다.	 */
			DELETE FROM TB_APS_PROD_PLAN_SUM_INFO
			WHERE APL_STRT_YMD = CURR_YMD	 
			AND APL_FNH_YMD >= CURR_YMD	 	  
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 3;

			/*[추가] 2010.04.15.김동근 생산계획정보 현황 - 공장별 내역 삭제 기능 추가	 */
	 
			UPDATE TB_PLNT_APS_PROD_PLAN_SUM_INFO A	 
			SET A.APL_FNH_YMD = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CURR_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d')
			WHERE A.APL_STRT_YMD < CURR_YMD	 
			AND A.APL_FNH_YMD >= CURR_YMD	  
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0; 
	 

    SET CURR_LOC_NUM = 4;

			DELETE FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO
			WHERE APL_STRT_YMD = CURR_YMD	 
			AND APL_FNH_YMD >= CURR_YMD	 	  
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;  
	 


    SET CURR_LOC_NUM = 5;


	OPEN APS_PROD_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH APS_PROD_INFO INTO V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_PLN_PARR_YMD_1,V_PRDN_PLN_QTY_1,V_DCSN_YN_1,V_DCSN_YMD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
									
			   /*변경여부를 검사할 데이터가 존재하는지의 여부를 확인	 */
			   SELECT MAX(APL_FNH_YMD)	 
			   INTO V_APL_FNH_YMD	 
			   FROM TB_APS_PROD_PLAN_SUM_INFO A	 
			   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   AND A.APL_FNH_YMD <= CURR_YMD /*현재일 이전의 데이터에서 조회하도록 한다...	 */
			   AND A.PLN_PARR_YMD = V_PLN_PARR_YMD_1	 
		       AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
		       AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
		       AND A.LANG_CD = V_LANG_CD_1;	 
	 
			   IF V_APL_FNH_YMD IS NULL THEN
				  /*지금까지 한번도 추가되지 않은 경우(무조건 Insert 해 준다.)	 */
				  INSERT INTO TB_APS_PROD_PLAN_SUM_INFO	 
   		    	  (APL_STRT_YMD,	 
				   APL_FNH_YMD,	 
				   PLN_PARR_YMD,	 
				   DATA_SN,	 
   				   QLTY_VEHL_CD,	 
   			 	   MDL_MDY_CD,	 
   			 	   LANG_CD,	 
   			 	   PRDN_PLN_QTY,	 
				   DCSN_YN,	 
				   DCSN_YMD,	 
   			 	   FRAM_DTM	 
   				  )	 
				  SELECT CURR_YMD,	 
				         CURR_YMD,	 
						 V_PLN_PARR_YMD_1,	 
				         A.DATA_SN,	 
						 V_QLTY_VEHL_CD_1,	 
						 V_MDL_MDY_CD_1,	 
						 V_LANG_CD_1,	 
						 V_PRDN_PLN_QTY_1,	 
						 V_DCSN_YN_1,	 
						 V_DCSN_YMD_1,	 
						 SYSDATE()	 
				  FROM TB_LANG_MGMT A	 
				  WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
				  AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
				  AND A.LANG_CD = V_LANG_CD_1;
			   ELSE	 
				   /*바로이전의 데이터가 변경되지 않은 경우에는 종료일 업데이트만 해준다.	 */
			   	   UPDATE TB_APS_PROD_PLAN_SUM_INFO A	 
		 	   	   SET APL_FNH_YMD = CURR_YMD /*적용완료일을 현재일로 해준다.	 */
					   , MDFY_DTM = SYSDATE()	/* 170104 추가*/
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.PLN_PARR_YMD = V_PLN_PARR_YMD_1	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
		       	   AND A.LANG_CD = V_LANG_CD_1	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_1	 
				   AND A.DCSN_YN = V_DCSN_YN_1	 
				   AND A.DCSN_YMD = V_DCSN_YMD_1;	

				SET V_EXCNT = 0;
				SELECT COUNT(A.APL_STRT_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_APS_PROD_PLAN_SUM_INFO A
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.PLN_PARR_YMD = V_PLN_PARR_YMD_1	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
		       	   AND A.LANG_CD = V_LANG_CD_1	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_1	 
				   AND A.DCSN_YN = V_DCSN_YN_1	 
				   AND A.DCSN_YMD = V_DCSN_YMD_1;

				   IF V_EXCNT = 0 THEN
					  INSERT INTO TB_APS_PROD_PLAN_SUM_INFO	 
   		    	  	  (APL_STRT_YMD,	 
				   	   APL_FNH_YMD,	 
				   	   PLN_PARR_YMD,	 
				   	   DATA_SN,	 
   				   	   QLTY_VEHL_CD,	 
   			 	   	   MDL_MDY_CD,	 
   			 	   	   LANG_CD,	 
   			 	   	   PRDN_PLN_QTY,	 
				   	   DCSN_YN,	 
				   	   DCSN_YMD,	 
   			 	   	   FRAM_DTM	 
   				  	  )	 
				  	  SELECT CURR_YMD,	 
				             CURR_YMD,	 
						     V_PLN_PARR_YMD_1,	 
				             A.DATA_SN,	 
						     V_QLTY_VEHL_CD_1,	 
						     V_MDL_MDY_CD_1,	 
						     V_LANG_CD_1,	 
						     V_PRDN_PLN_QTY_1,	 
						     V_DCSN_YN_1,	 
						     V_DCSN_YMD_1,	 
						     SYSDATE()	 
				     FROM TB_LANG_MGMT A	 
				     WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
				     AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
				     AND A.LANG_CD = V_LANG_CD_1;
				   END IF;
			   END IF;	 

	END LOOP JOBLOOP1 ;
	CLOSE APS_PROD_INFO;
	 


    SET CURR_LOC_NUM = 6;


	OPEN PLNT_PROD_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_PROD_INFO INTO V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_PLN_PARR_YMD_2,V_PRDN_PLN_QTY_2,V_DCSN_YN_2,V_DCSN_YMD_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;
	
			   /*변경여부를 검사할 데이터가 존재하는지의 여부를 확인	 */
			   SELECT MAX(APL_FNH_YMD)	 
			   INTO V_APL_FNH_YMD	 
			   FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A	 
			   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   AND A.APL_FNH_YMD <= CURR_YMD /*현재일 이전의 데이터에서 조회하도록 한다...	 */
			   AND A.PLN_PARR_YMD = V_PLN_PARR_YMD_2	 
		       AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
		       AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
		       AND A.LANG_CD = V_LANG_CD_2	 
			   AND A.PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;	 
	 
			   IF V_APL_FNH_YMD IS NULL THEN
				  /*지금까지 한번도 추가되지 않은 경우(무조건 Insert 해 준다.)	 */
				  INSERT INTO TB_PLNT_APS_PROD_PLAN_SUM_INFO	 
   		    	  (APL_STRT_YMD,	 
				   APL_FNH_YMD,	 
				   PLN_PARR_YMD,	 
				   DATA_SN,	 
   				   QLTY_VEHL_CD,	 
   			 	   MDL_MDY_CD,	 
   			 	   LANG_CD,	 
   			 	   PRDN_PLN_QTY,	 
				   DCSN_YN,	 
				   DCSN_YMD,	 
   			 	   FRAM_DTM,	 
				   PRDN_PLNT_CD	 
   				  )	 
				  SELECT CURR_YMD,	 
				         CURR_YMD,	 
						 V_PLN_PARR_YMD_2,	 
				         A.DATA_SN,	 
						 V_QLTY_VEHL_CD_2,	 
						 V_MDL_MDY_CD_2,	 
						 V_LANG_CD_2,	 
						 V_PRDN_PLN_QTY_2,	 
						 V_DCSN_YN_2,	 
						 V_DCSN_YMD_2,	 
						 SYSDATE(),	 
						 V_PRDN_PLNT_CD_2	 
				  FROM TB_LANG_MGMT A	 
				  WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
				  AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
				  AND A.LANG_CD = V_LANG_CD_2;
			   ELSE	
				   /*바로이전의 데이터가 변경되지 않은 경우에는 종료일 업데이트만 해준다.	 */
			   	   UPDATE TB_PLNT_APS_PROD_PLAN_SUM_INFO A	 
		 	   	   SET APL_FNH_YMD = CURR_YMD /*적용완료일을 현재일로 해준다.	 */
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.PLN_PARR_YMD = V_PLN_PARR_YMD_2	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
		       	   AND A.LANG_CD = V_LANG_CD_2	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_2	 
				   AND A.DCSN_YN = V_DCSN_YN_2	 
				   AND A.DCSN_YMD = V_DCSN_YMD_2	 
				   AND A.PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;	

				SET V_EXCNT = 0;
				SELECT COUNT(A.APL_STRT_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A	
			   	   WHERE A.APL_STRT_YMD <= CURR_YMD	 
			   	   AND A.APL_FNH_YMD = V_APL_FNH_YMD	 
			   	   AND A.PLN_PARR_YMD = V_PLN_PARR_YMD_2	 
		       	   AND A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
		       	   AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
		       	   AND A.LANG_CD = V_LANG_CD_2	 
				   AND A.PRDN_PLN_QTY = V_PRDN_PLN_QTY_2	 
				   AND A.DCSN_YN = V_DCSN_YN_2	 
				   AND A.DCSN_YMD = V_DCSN_YMD_2	 
				   AND A.PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;	 

				   IF V_EXCNT = 0 THEN
					  INSERT INTO TB_PLNT_APS_PROD_PLAN_SUM_INFO	 
   		    	  	  (APL_STRT_YMD,	 
				   	   APL_FNH_YMD,	 
				   	   PLN_PARR_YMD,	 
				   	   DATA_SN,	 
   				   	   QLTY_VEHL_CD,	 
   			 	   	   MDL_MDY_CD,	 
   			 	   	   LANG_CD,	 
   			 	   	   PRDN_PLN_QTY,	 
				   	   DCSN_YN,	 
				   	   DCSN_YMD,	 
   			 	   	   FRAM_DTM,	 
					   PRDN_PLNT_CD	 
   				  	  )	 
				  	  SELECT CURR_YMD,	 
				             CURR_YMD,	 
						     V_PLN_PARR_YMD_2,	 
				             A.DATA_SN,	 
						     V_QLTY_VEHL_CD_2,	 
						     V_MDL_MDY_CD_2,	 
						     V_LANG_CD_2,	 
						     V_PRDN_PLN_QTY_2,	 
						     V_DCSN_YN_2,	 
						     V_DCSN_YMD_2,	 
						     SYSDATE(),	 
							 V_PRDN_PLNT_CD_2	 
				     FROM TB_LANG_MGMT A	 
				     WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
				     AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
				     AND A.LANG_CD = V_LANG_CD_2;
				   END IF;
			   END IF;	 

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_PROD_INFO;


    SET CURR_LOC_NUM = 7;

	/*생산계획정보 취합 작업 수행	 */
	CALL SP_GET_APS_PROD_SUM_DTL(CURR_YMD,	 
			                     CURR_YMD,	 
								 EXPD_CO_CD);	 
	 

    SET CURR_LOC_NUM = 8;

	/*재고상세 내역 재계산 작업 수행(생산계획정보 정보 취합 후 작업이 수행되어야 한다.)	 
	  (반드시 세원재고 재계산 작업이 이루어진 후에 PDI 재고 데이터 재계산이 이루어 져야 한다.)	 */
	CALL SP_RECALCULATE_SEWON_IV_DTL2(CURR_YMD, EXPD_CO_CD);	

    SET CURR_LOC_NUM = 9;
 
	CALL SP_RECALCULATE_PDI_IV_DTL2(CURR_YMD, EXPD_CO_CD);


    SET CURR_LOC_NUM = 10;


	/*END;
	DELIMITER;
	다음처리*/
	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 11;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_APS_PROD_SUM_DTL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_APS_PROD_SUM_DTL`(IN CURR_YMD VARCHAR(8),
                                        IN SRCH_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GET_APS_PROD_SUM_DTL
 * Procedure 설명 : 화면에 표시되는 데이터의 형태로 생산계획 정보를 취합하는 작업을 수행	
 *                 영업일 기준(토, 일 제외)으로 3일 뒤 날짜를 얻어오도록 함
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 SRCH_YMD                   조회년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_DATE		    DATETIME;
	DECLARE V_CURR_FSTD_YMD		VARCHAR(8);
	DECLARE V_NEXT_2WEK_YMD		VARCHAR(8);
	DECLARE V_CURR_LAST_YMD		VARCHAR(8);
	DECLARE V_NEXT_2DAY_YMD		VARCHAR(8);
	DECLARE V_NEXT_4DAY_YMD		VARCHAR(8);
	DECLARE V_NEXT_1DAY_YMD		VARCHAR(8);
	
	DECLARE V_DATA_SN_1	INT;
	DECLARE V_QLTY_VEHL_CD_1	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1	VARCHAR(3);
	DECLARE V_TDD_PRDN_PLN_QTY_1	INT;
	DECLARE V_WEK2_PRDN_PLN_QTY_1	INT;
	DECLARE V_TMM_PRDN_PLN_QTY_1	INT;
	DECLARE V_TDD_PRDN_PLN_QTY2_1	INT;
	DECLARE V_TDD_PRDN_PLN_QTY3_1	INT; 
											
	DECLARE V_DATA_SN_2	INT;
	DECLARE V_QLTY_VEHL_CD_2	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2	VARCHAR(4);
	DECLARE V_LANG_CD_2	VARCHAR(3);
	DECLARE V_TDD_PRDN_PLN_QTY_2	INT;
	DECLARE V_WEK2_PRDN_PLN_QTY_2	INT;
	DECLARE V_TMM_PRDN_PLN_QTY_2	INT;
	DECLARE V_TDD_PRDN_PLN_QTY2_2	INT;
	DECLARE V_TDD_PRDN_PLN_QTY3_2	INT;
	DECLARE V_PRDN_PLNT_CD_2	VARCHAR(3);											 
	
	DECLARE V_EXCNT   INT;
	DECLARE V_EXCNT2   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE APS_PROD_SUM_INFO CURSOR FOR
				   					 SELECT MAX(DATA_SN) AS DATA_SN,	 
									   		QLTY_VEHL_CD,	 
											MDL_MDY_CD,	 
											LANG_CD,	 
									   		SUM(TDD_PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY,	 
											SUM(WEK2_PRDN_PLN_QTY) AS WEK2_PRDN_PLN_QTY,	 
											SUM(TMM_PRDN_PLN_QTY) AS TMM_PRDN_PLN_QTY,	 
											SUM(TDD_PRDN_PLN_QTY2) AS TDD_PRDN_PLN_QTY2,	 
											SUM(TDD_PRDN_PLN_QTY3) AS TDD_PRDN_PLN_QTY3	 
				   					 FROM (	 
									 	   /*금일 생산계획 데이터 조회(영업일기준 3일)	 */
									 	   SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			  A.QLTY_VEHL_CD,	 
												  A.MDL_MDY_CD,	 
												  A.LANG_CD,	 
									   			  SUM(A.PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY,	 
												  0 AS WEK2_PRDN_PLN_QTY,	 
												  0 AS TMM_PRDN_PLN_QTY,	 
												  0 AS TDD_PRDN_PLN_QTY2,	 
												  0 AS TDD_PRDN_PLN_QTY3	 
									   	   FROM TB_APS_PROD_PLAN_SUM_INFO A,	 
									   		    TB_VEHL_MGMT B	 
										   WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										   AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		   AND A.APL_FNH_YMD >= SRCH_YMD	 
										   /*현재일부터 2일 뒤까지의 생산계획 데이터를 금일생산계획데이터로 본다.	  */
										   AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_2DAY_YMD	 
										   GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
										   UNION ALL	 
	 
										   /*2주 생산계획 데이터 조회	  */
										   SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			  A.QLTY_VEHL_CD,	 
												  A.MDL_MDY_CD,	 
												  A.LANG_CD,	 
									   			  0 AS TDD_PRDN_PLN_QTY,	 
												  SUM(A.PRDN_PLN_QTY) AS WEK2_PRDN_PLN_QTY,	 
												  0 AS TMM_PRDN_PLN_QTY,	 
												  0 AS TDD_PRDN_PLN_QTY2,	 
												  0 AS TDD_PRDN_PLN_QTY3	 
									   	   FROM TB_APS_PROD_PLAN_SUM_INFO A,	 
									   		    TB_VEHL_MGMT B	 
										   WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										   AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		   AND A.APL_FNH_YMD >= SRCH_YMD	 
										   AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_2WEK_YMD	 
										   GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
										   UNION ALL	 
	 
										   /*금일부터 당월말까지의 예산 계획 데이터 조회	 */
										   SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			  A.QLTY_VEHL_CD,	 
												  A.MDL_MDY_CD,	 
												  A.LANG_CD,	 
									   			  0 AS TDD_PRDN_PLN_QTY,	 
												  0 AS WEK2_PRDN_PLN_QTY,	 
												  SUM(A.PRDN_PLN_QTY) AS TMM_PRDN_PLN_QTY,	 
												  0 AS TDD_PRDN_PLN_QTY2,	 
												  0 AS TDD_PRDN_PLN_QTY3	 
									   	   FROM TB_APS_PROD_PLAN_SUM_INFO A,	 
									   		    TB_VEHL_MGMT B	 
										   WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										   AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		   AND A.APL_FNH_YMD >= SRCH_YMD	 
										   AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_CURR_LAST_YMD	 
										   GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
										   UNION ALL	 
	 
										   /*금일 생산계획 데이터 조회(영업일기준 5일)	 */
										   SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			  A.QLTY_VEHL_CD,	 
												  A.MDL_MDY_CD,	 
												  A.LANG_CD,	 
									   			  0 AS TDD_PRDN_PLN_QTY2,	 
												  0 AS WEK2_PRDN_PLN_QTY,	 
												  0 AS TMM_PRDN_PLN_QTY,	 
												  SUM(A.PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY2,	 
												  0 AS TDD_PRDN_PLN_QTY3	 
									   	   FROM TB_APS_PROD_PLAN_SUM_INFO A,	 
									   		    TB_VEHL_MGMT B	 
										   WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										   AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		   AND A.APL_FNH_YMD >= SRCH_YMD	 
										   /*현재일부터 4일 뒤까지의 생산계획 데이터를 금일생산계획데이터로 본다.	 */
										   AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_4DAY_YMD	 
										   GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
										   UNION ALL	 
	 
										   /*금일 생산계획 데이터 조회(영업일기준 2일)	  */
										   SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			  A.QLTY_VEHL_CD,	 
												  A.MDL_MDY_CD,	 
												  A.LANG_CD,	 
									   			  0 AS TDD_PRDN_PLN_QTY2,	 
												  0 AS WEK2_PRDN_PLN_QTY,	 
												  0 AS TMM_PRDN_PLN_QTY,	 
												  0 AS TDD_PRDN_PLN_QTY2,	 
												  SUM(A.PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY3	 
									   	   FROM TB_APS_PROD_PLAN_SUM_INFO A,	 
									   		    TB_VEHL_MGMT B	 
										   WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										   AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		   AND A.APL_FNH_YMD >= SRCH_YMD	 
										   /*현재일부터 4일 뒤까지의 생산계획 데이터를 금일생산계획데이터로 본다.	  */
										   AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_1DAY_YMD	 
										   GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
										  ) A	 
									 WHERE A.TDD_PRDN_PLN_QTY + A.WEK2_PRDN_PLN_QTY + A.TMM_PRDN_PLN_QTY +	 
									       A.TDD_PRDN_PLN_QTY2 + A.TDD_PRDN_PLN_QTY3 > 0	 
									 GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD;	 
	 

	DECLARE PLNT_PROD_SUM_INFO CURSOR FOR
		                             /*[추가] 2010.04.15.김동근 생산계획정보 현황 - 공장별 Summary 내역 조회	 */
				   					  SELECT MAX(DATA_SN) AS DATA_SN,	 
									   		 QLTY_VEHL_CD,	 
											 MDL_MDY_CD,	 
											 LANG_CD,	 
									   		 SUM(TDD_PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY,	 
											 SUM(WEK2_PRDN_PLN_QTY) AS WEK2_PRDN_PLN_QTY,	 
											 SUM(TMM_PRDN_PLN_QTY) AS TMM_PRDN_PLN_QTY,	 
											 SUM(TDD_PRDN_PLN_QTY2) AS TDD_PRDN_PLN_QTY2,	 
											 SUM(TDD_PRDN_PLN_QTY3) AS TDD_PRDN_PLN_QTY3,	 
											 PRDN_PLNT_CD	 
				   					  FROM (	 
									 	    /*금일 생산계획 데이터 조회(영업일기준 3일)	 */
									 	    SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			   A.QLTY_VEHL_CD,	 
												   A.MDL_MDY_CD,	 
												   A.LANG_CD,	 
									   			   SUM(A.PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY,	 
												   0 AS WEK2_PRDN_PLN_QTY,	 
												   0 AS TMM_PRDN_PLN_QTY,	 
												   0 AS TDD_PRDN_PLN_QTY2,	 
												   0 AS TDD_PRDN_PLN_QTY3,	 
												   A.PRDN_PLNT_CD	 
									   	    FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A,	 
									   		     TB_VEHL_MGMT B	 
										    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										    AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										    AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		    AND A.APL_FNH_YMD >= SRCH_YMD	 
										    /*현재일부터 2일 뒤까지의 생산계획 데이터를 금일생산계획데이터로 본다.	  */
										    AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_2DAY_YMD	 
										    GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
										    UNION ALL	 
	 
										    /*2주 생산계획 데이터 조회	  */
										    SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			   A.QLTY_VEHL_CD,	 
												   A.MDL_MDY_CD,	 
												   A.LANG_CD,	 
									   			   0 AS TDD_PRDN_PLN_QTY,	 
												   SUM(A.PRDN_PLN_QTY) AS WEK2_PRDN_PLN_QTY,	 
												   0 AS TMM_PRDN_PLN_QTY,	 
												   0 AS TDD_PRDN_PLN_QTY2,	 
												   0 AS TDD_PRDN_PLN_QTY3,	 
												   A.PRDN_PLNT_CD	 
									   	    FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A,	 
									   		     TB_VEHL_MGMT B	 
										    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										    AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										    AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		    AND A.APL_FNH_YMD >= SRCH_YMD	 
										    AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_2WEK_YMD	 
										    GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
										    UNION ALL	 
	 
										    /*금일부터 당월말까지의 예산 계획 데이터 조회	 */ 
										    SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			   A.QLTY_VEHL_CD,	 
												   A.MDL_MDY_CD,	 
												   A.LANG_CD,	 
									   			   0 AS TDD_PRDN_PLN_QTY,	 
												   0 AS WEK2_PRDN_PLN_QTY,	 
												   SUM(A.PRDN_PLN_QTY) AS TMM_PRDN_PLN_QTY,	 
												   0 AS TDD_PRDN_PLN_QTY2,	 
												   0 AS TDD_PRDN_PLN_QTY3,	 
												   A.PRDN_PLNT_CD	 
									   	    FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A,	 
									   		     TB_VEHL_MGMT B	 
										    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										    AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										    AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		    AND A.APL_FNH_YMD >= SRCH_YMD	 
										    AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_CURR_LAST_YMD	 
										    GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
										    UNION ALL	 
	 
										    /*금일 생산계획 데이터 조회(영업일기준 5일)	  */
										    SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			   A.QLTY_VEHL_CD,	 
												   A.MDL_MDY_CD,	 
												   A.LANG_CD,	 
									   			   0 AS TDD_PRDN_PLN_QTY2,	 
												   0 AS WEK2_PRDN_PLN_QTY,	 
												   0 AS TMM_PRDN_PLN_QTY,	 
												   SUM(A.PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY2,	 
												   0 AS TDD_PRDN_PLN_QTY3,	 
												   A.PRDN_PLNT_CD	 
									   	    FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A,	 
									   		     TB_VEHL_MGMT B	 
										    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										    AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										    AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		    AND A.APL_FNH_YMD >= SRCH_YMD	 
										    /*현재일부터 4일 뒤까지의 생산계획 데이터를 금일생산계획데이터로 본다.	 */
										    AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_4DAY_YMD	 
										    GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
										    UNION ALL	 
	 
										    /*금일 생산계획 데이터 조회(영업일기준 2일)	 */ 
										    SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			   A.QLTY_VEHL_CD,	 
												   A.MDL_MDY_CD,	 
												   A.LANG_CD,	 
									   			   0 AS TDD_PRDN_PLN_QTY2,	 
												   0 AS WEK2_PRDN_PLN_QTY,	 
												   0 AS TMM_PRDN_PLN_QTY,	 
												   0 AS TDD_PRDN_PLN_QTY2,	 
												   SUM(A.PRDN_PLN_QTY) AS TDD_PRDN_PLN_QTY3,	 
												   A.PRDN_PLNT_CD	 
									   	    FROM TB_PLNT_APS_PROD_PLAN_SUM_INFO A,	 
									   		     TB_VEHL_MGMT B	 
										    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
										    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										    AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
										    AND A.APL_STRT_YMD <= SRCH_YMD	 
                                 		    AND A.APL_FNH_YMD >= SRCH_YMD	 
										    /*현재일부터 4일 뒤까지의 생산계획 데이터를 금일생산계획데이터로 본다.	  */
										    AND A.PLN_PARR_YMD BETWEEN CURR_YMD AND V_NEXT_1DAY_YMD	 
										    GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
										   ) A	 
									  WHERE A.TDD_PRDN_PLN_QTY + A.WEK2_PRDN_PLN_QTY + A.TMM_PRDN_PLN_QTY +	 
									        A.TDD_PRDN_PLN_QTY2 + A.TDD_PRDN_PLN_QTY3 > 0	 
									  GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, PRDN_PLNT_CD;	


	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE,endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_APS_PROD_SUM_DTL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',SRCH_YMD:',IFNULL(SRCH_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_CURR_FSTD_YMD:',IFNULL(V_CURR_FSTD_YMD,'')
							,',V_NEXT_2WEK_YMD:',IFNULL(V_NEXT_2WEK_YMD,'')
							,',V_CURR_LAST_YMD:',IFNULL(V_CURR_LAST_YMD,'')
							,',V_NEXT_2DAY_YMD:',IFNULL(V_NEXT_2DAY_YMD,'')
							,',V_NEXT_4DAY_YMD:',IFNULL(V_NEXT_4DAY_YMD,'')
							,',V_NEXT_1DAY_YMD:',IFNULL(V_NEXT_1DAY_YMD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',V_DATA_SN_1:',IFNULL(CONCAT(V_DATA_SN_1),'')
							,',V_TDD_PRDN_PLN_QTY_1:',IFNULL(CONCAT(V_TDD_PRDN_PLN_QTY_1),'')
							,',V_WEK2_PRDN_PLN_QTY_1:',IFNULL(CONCAT(V_WEK2_PRDN_PLN_QTY_1),'')
							,',V_TMM_PRDN_PLN_QTY_1:',IFNULL(CONCAT(V_TMM_PRDN_PLN_QTY_1),'')
							,',V_TDD_PRDN_PLN_QTY2_1:',IFNULL(CONCAT(V_TDD_PRDN_PLN_QTY2_1),'')
							,',V_TDD_PRDN_PLN_QTY3_1:',IFNULL(CONCAT(V_TDD_PRDN_PLN_QTY3_1),'')
							,',V_DATA_SN_2:',IFNULL(CONCAT(V_DATA_SN_2),'')
							,',V_TDD_PRDN_PLN_QTY_2:',IFNULL(CONCAT(V_TDD_PRDN_PLN_QTY_2),'')
							,',V_WEK2_PRDN_PLN_QTY_2:',IFNULL(CONCAT(V_WEK2_PRDN_PLN_QTY_2),'')
							,',V_TMM_PRDN_PLN_QTY_2:',IFNULL(CONCAT(V_TMM_PRDN_PLN_QTY_2),'')
							,',V_TDD_PRDN_PLN_QTY2_2:',IFNULL(CONCAT(V_TDD_PRDN_PLN_QTY2_2),'')
							,',V_TDD_PRDN_PLN_QTY3_2:',IFNULL(CONCAT(V_TDD_PRDN_PLN_QTY3_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_EXCNT2:',IFNULL(CONCAT(V_EXCNT2),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

	
	SET V_CURR_DATE	= STR_TO_DATE(CURR_YMD, '%Y%m%d');
	SET V_CURR_FSTD_YMD = CONCAT(DATE_FORMAT(V_CURR_DATE, '%Y%m'), '01');
	SET V_NEXT_2WEK_YMD = DATE_FORMAT(DATE_ADD(V_CURR_DATE, INTERVAL 14 DAY), '%Y%m%d');	 
    SET V_CURR_LAST_YMD = DATE_FORMAT(LAST_DAY(V_CURR_DATE), '%Y%m%d');	 
	SET V_NEXT_2DAY_YMD = FU_GET_WRKDATE(CURR_YMD, 2);
	SET V_NEXT_4DAY_YMD = FU_GET_WRKDATE(CURR_YMD, 4);
	SET V_NEXT_1DAY_YMD = FU_GET_WRKDATE(CURR_YMD, 1);


			/*이미 입력되었던 항목이 있다면 초기화 해준 후 진행한다.	 
			 [주의] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된	 
			        내역만을 삭제해 주어야 한다.	 */
			UPDATE TB_APS_PROD_SUM_INFO A	 
			SET TDD_PRDN_PLN_QTY = 0,	 
				WEK2_PRDN_PLN_QTY = 0,	 
				TMM_PRDN_PLN_QTY = 0,	 
				TDD_PRDN_PLN_QTY2 = 0,	 
				TDD_PRDN_PLN_QTY3 = 0,	 
				MDFY_DTM = SYSDATE()	 
			WHERE APL_YMD = CURR_YMD	
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 2;

			/*[추가] 2010.04.15.김동근 생산계획정보 현황 - 공장별 Summary 내역 초기화	 */
			UPDATE TB_PLNT_APS_PROD_SUM_INFO A	 
			SET TDD_PRDN_PLN_QTY = 0,	 
				WEK2_PRDN_PLN_QTY = 0,	 
				TMM_PRDN_PLN_QTY = 0,	 
				TDD_PRDN_PLN_QTY2 = 0,	 
				TDD_PRDN_PLN_QTY3 = 0,	 
				MDFY_DTM = SYSDATE()	 
			WHERE APL_YMD = CURR_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 3;


	OPEN APS_PROD_SUM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH APS_PROD_SUM_INFO INTO V_DATA_SN_1,V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_TDD_PRDN_PLN_QTY_1,V_WEK2_PRDN_PLN_QTY_1,V_TMM_PRDN_PLN_QTY_1,V_TDD_PRDN_PLN_QTY2_1,V_TDD_PRDN_PLN_QTY3_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

				UPDATE TB_APS_PROD_SUM_INFO	 
				SET TDD_PRDN_PLN_QTY  = V_TDD_PRDN_PLN_QTY_1,	 
				    WEK2_PRDN_PLN_QTY = V_WEK2_PRDN_PLN_QTY_1,	 
					TMM_PRDN_PLN_QTY  = V_TMM_PRDN_PLN_QTY_1,	 
					TDD_PRDN_PLN_QTY2 = V_TDD_PRDN_PLN_QTY2_1,	 
					TDD_PRDN_PLN_QTY3 = V_TDD_PRDN_PLN_QTY3_1,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;

			    SET V_EXCNT = 0;

	   		    SELECT COUNT(APL_YMD)
	   		    INTO V_EXCNT	 
	   		    FROM TB_APS_PROD_SUM_INFO  
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;
					 
				IF V_EXCNT = 0 THEN	 
					 
					UPDATE TB_APS_PROD_SUM_INFO	 
					SET DATA_SN = V_DATA_SN_1,	 
						TDD_PRDN_PLN_QTY  = V_TDD_PRDN_PLN_QTY_1,	 
					    WEK2_PRDN_PLN_QTY = V_WEK2_PRDN_PLN_QTY_1,	 
						TMM_PRDN_PLN_QTY  = V_TMM_PRDN_PLN_QTY_1,	 
						TDD_PRDN_PLN_QTY2 = V_TDD_PRDN_PLN_QTY2_1,	 
						TDD_PRDN_PLN_QTY3 = V_TDD_PRDN_PLN_QTY3_1,	 
						MDFY_DTM = SYSDATE()	 
					WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
						AND LANG_CD = V_LANG_CD_1;

					SET V_EXCNT2 = 0;

					SELECT COUNT(APL_YMD)
					INTO V_EXCNT2	 
					FROM TB_APS_PROD_SUM_INFO 
					WHERE APL_YMD = CURR_YMD	 
					AND DATA_SN = V_DATA_SN_1
					AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1;

					IF V_EXCNT2 = 0 THEN	 
		 
					   INSERT INTO TB_APS_PROD_SUM_INFO	 
					   (APL_YMD,	 
					    DATA_SN,	 
						QLTY_VEHL_CD,	 
						MDL_MDY_CD,	 
						LANG_CD,	 
						TDD_PRDN_PLN_QTY,	 
						WEK2_PRDN_PLN_QTY,	 
						TMM_PRDN_PLN_QTY,	 
						FRAM_DTM,	 
						MDFY_DTM,	 
						TDD_PRDN_PLN_QTY2,	 
						TDD_PRDN_PLN_QTY3	 
					   )	 
					   VALUES	 
					   (CURR_YMD,	 
					    V_DATA_SN_1,	 
						V_QLTY_VEHL_CD_1,	 
						V_MDL_MDY_CD_1,	 
						V_LANG_CD_1,	 
						V_TDD_PRDN_PLN_QTY_1,	 
						V_WEK2_PRDN_PLN_QTY_1,	 
						V_TMM_PRDN_PLN_QTY_1,	 
						SYSDATE(),	 
						SYSDATE(),	 
						V_TDD_PRDN_PLN_QTY2_1,	 
						V_TDD_PRDN_PLN_QTY3_1	 
					   );		 
					END IF;
				END IF;

	END LOOP JOBLOOP1 ;
	CLOSE APS_PROD_SUM_INFO;

	 

    SET CURR_LOC_NUM = 4;

	OPEN PLNT_PROD_SUM_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_PROD_SUM_INFO INTO V_DATA_SN_2,V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_TDD_PRDN_PLN_QTY_2,V_WEK2_PRDN_PLN_QTY_2,V_TMM_PRDN_PLN_QTY_2,V_TDD_PRDN_PLN_QTY2_2,V_TDD_PRDN_PLN_QTY3_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

			/*[추가] 2010.04.15.김동근 생산계획정보 현황 - 공장별 Summary 내역 저장 기능 추가	 */
				UPDATE TB_PLNT_APS_PROD_SUM_INFO	 
				SET TDD_PRDN_PLN_QTY  = V_TDD_PRDN_PLN_QTY_2,	 
				    WEK2_PRDN_PLN_QTY = V_WEK2_PRDN_PLN_QTY_2,	 
					TMM_PRDN_PLN_QTY  = V_TMM_PRDN_PLN_QTY_2,	 
					TDD_PRDN_PLN_QTY2 = V_TDD_PRDN_PLN_QTY2_2,	 
					TDD_PRDN_PLN_QTY3 = V_TDD_PRDN_PLN_QTY3_2,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

			    SET V_EXCNT = 0;

	   		    SELECT COUNT(APL_YMD)
	   		    INTO V_EXCNT	 
	   		    FROM TB_PLNT_APS_PROD_SUM_INFO 	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;
	 
				IF V_EXCNT = 0 THEN	 
	 
				   INSERT INTO TB_PLNT_APS_PROD_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					TDD_PRDN_PLN_QTY,	 
					WEK2_PRDN_PLN_QTY,	 
					TMM_PRDN_PLN_QTY,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					TDD_PRDN_PLN_QTY2,	 
					TDD_PRDN_PLN_QTY3,	 
					PRDN_PLNT_CD	 
				   )	 
				   VALUES	 
				   (CURR_YMD,	 
				    V_DATA_SN_2,	 
					V_QLTY_VEHL_CD_2,	 
					V_MDL_MDY_CD_2,	 
					V_LANG_CD_2,	 
					V_TDD_PRDN_PLN_QTY_2,	 
					V_WEK2_PRDN_PLN_QTY_2,	 
					V_TMM_PRDN_PLN_QTY_2,	 
					SYSDATE(),	 
					SYSDATE(),	 
					V_TDD_PRDN_PLN_QTY2_2,	 
					V_TDD_PRDN_PLN_QTY3_2,	 
					V_PRDN_PLNT_CD_2	 
				   );
				END IF;

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_PROD_SUM_INFO;
				 


    SET CURR_LOC_NUM = 5;

	/*END;
	DELIMITER;
	다음처리*/


	COMMIT;

	    

    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_MDL_MDY_CD_EXTRA_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_MDL_MDY_CD_EXTRA_HMC`(IN P_CURR_YMD VARCHAR(8),
                                        IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_NAT_CD VARCHAR(5),
                                        IN P_MO_PACK_CD VARCHAR(4),
                                        IN P_MODE VARCHAR(20),
                                        IN P_BASC_MDL_CD VARCHAR(12),
                                        IN P_MDL_MDY_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_GET_MDL_MDY_CD_EXTRA_HMC
 * Procedure 설명 : 연식지정관련 별도 작업 프로시저 	
 *                 HD 차종의, 국가가 이집트인 내역에서 월팩이 0903인 팩은 08년식으로 지정해 준다.
 * 입력 파라미터    :  P_CURR_YMD                   현재년월일
 *                 P_EXPD_CO_CD                 회사코드
 *                 P_QLTY_VEHL_CD               생산차종코드
 *                 P_EXPD_NAT_CD                취급설명서국가코드
 *                 P_MO_PACK_CD                 원팩코드
 *                 P_MODE                       모드
 *                 P_BASC_MDL_CD                기본모델코드
 *                 P_MDL_MDY_CD                 모델년식코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_MDL_MDY_CD_EXTRA_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CURR_YMD:',IFNULL(P_CURR_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_EXPD_NAT_CD:',IFNULL(P_EXPD_NAT_CD,'')
							,',P_MO_PACK_CD:',IFNULL(P_MO_PACK_CD,'')
							,',P_MODE:',IFNULL(P_MODE,'')
							,',P_BASC_MDL_CD:',IFNULL(P_BASC_MDL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

	/*HD 차종의, 국가가 이집트인 내역에서 월팩이 0903인 팩은 08년식으로 지정해 준다. */
	IF P_QLTY_VEHL_CD = 'HD' AND P_EXPD_NAT_CD = 'D03' AND P_MO_PACK_CD = '0903' THEN
		/*생산마스터 I/F 일 경우 */
		IF P_MODE = '03' THEN
			IF P_CURR_YMD >= '20090415' THEN
				SET P_MDL_MDY_CD = '08';
			END IF;
		/*생산계획 및 오더 I/F 인 경우 */
		ELSE
			IF P_CURR_YMD >= '20090416' THEN
				SET P_MDL_MDY_CD = '08';
			END IF;
		END IF;
	END IF;


    SET CURR_LOC_NUM = 2;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_MDL_MDY_CD_EXTRA_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_MDL_MDY_CD_EXTRA_KMC`(IN P_CURR_YMD VARCHAR(8),
                                        IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_NAT_CD VARCHAR(5),
                                        IN P_MO_PACK_CD VARCHAR(4),
                                        IN P_MODE VARCHAR(20),
                                        IN P_BASC_MDL_CD VARCHAR(12),
                                        IN P_MDL_MDY_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_GET_MDL_MDY_CD_EXTRA_KMC
 * Procedure 설명 : 연식지정관련 별도 작업 프로시저		
 * 입력 파라미터    :  P_CURR_YMD                   현재년월일
 *                 P_EXPD_CO_CD                 회사코드
 *                 P_QLTY_VEHL_CD               생산차종코드
 *                 P_EXPD_NAT_CD                취급설명서국가코드
 *                 P_MO_PACK_CD                 원팩코드
 *                 P_MODE                       모드
 *                 P_BASC_MDL_CD                기본모델코드
 *                 P_MDL_MDY_CD                 모델년식코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_MDL_MDY_CD_EXTRA_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CURR_YMD:',IFNULL(P_CURR_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_EXPD_NAT_CD:',IFNULL(P_EXPD_NAT_CD,'')
							,',P_MO_PACK_CD:',IFNULL(P_MO_PACK_CD,'')
							,',P_MODE:',IFNULL(P_MODE,'')
							,',P_BASC_MDL_CD:',IFNULL(P_BASC_MDL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

	/*IF P_EXPD_CO_CD = EXPD_CO_CD_KMC THEN */
		/*JB 차종의 07월 팩 중에서 4DR 인 경우에는 10연식으로 지정해 준다.	 */
		IF P_QLTY_VEHL_CD = 'JB' AND P_MO_PACK_CD = '0907' AND SUBSTR(P_BASC_MDL_CD, 3, 2) = 'S4' THEN 
			IF P_CURR_YMD >= '20090701' THEN
				SET P_MDL_MDY_CD = '10';
			END IF;
		END IF;
	/*END IF;*/


    SET CURR_LOC_NUM = 2;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_PROG_SUM 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_PROG_SUM`(IN CURR_YMD VARCHAR(8),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_PROG_SUM
 * Procedure 설명 : 생산마스터내역 조회(PDI 공통차종 오더내역 조회 부분 포함)
 *                 생산정보 현황 - 공장별 내역 조회
 *                 국가미지정 생산정보는 현시점부터 가져오지 않도록 한다.
 *                 생산정보 현황 - 공장별 내역 저장 기능 추가	 
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 P_EXPD_CO_CD               회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_APL_YMD_1 VARCHAR(8);
	DECLARE V_PRDN_QTY_1 INT;
	DECLARE V_PRDN_QTY2_1 INT;
	DECLARE V_PRDN_QTY3_1 INT;
	DECLARE V_TH0_POW_TRWI_QTY_1 INT;
	DECLARE V_TH0_POS_STRT_YMD_1 VARCHAR(8);
	DECLARE V_TH0_POS_FNH_YMD_1 VARCHAR(8); 
	DECLARE V_TH1_POW_TRWI_QTY_1 INT;
	DECLARE V_TH1_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH1_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH2_POW_TRWI_QTY_1 INT;
	DECLARE V_TH2_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH2_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH3_POW_TRWI_QTY_1 INT;
	DECLARE V_TH3_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH3_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH4_POW_TRWI_QTY_1 INT;
	DECLARE V_TH4_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH4_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH5_POW_TRWI_QTY_1 INT;
	DECLARE V_TH5_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH5_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH6_POW_TRWI_QTY_1 INT;
	DECLARE V_TH6_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH6_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH7_POW_TRWI_QTY_1 INT;
	DECLARE V_TH7_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH7_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH8_POW_TRWI_QTY_1 INT;
	DECLARE V_TH8_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH8_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH9_POW_TRWI_QTY_1 INT;
	DECLARE V_TH9_POS_STRT_YMDHM_1 VARCHAR(12);
	DECLARE V_TH9_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH10_POW_TRWI_QTY_1 INT;
	DECLARE V_T10PS1_YMDHM_1 VARCHAR(12);   
	DECLARE V_TH10_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH11_POW_TRWI_QTY_1 INT;
	DECLARE V_T11PS1_YMDHM_1 VARCHAR(12); 
	DECLARE V_TH11_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH12_POW_TRWI_QTY_1 INT;
	DECLARE V_T12PS1_YMDHM_1 VARCHAR(12);
	DECLARE V_TH12_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH13_POW_TRWI_QTY_1 INT;
	DECLARE V_T13PS1_YMDHM_1 VARCHAR(12);
	DECLARE V_TH13_POS_FNH_YMDHM_1 VARCHAR(12);
	DECLARE V_TH16_POW_TRWI_QTY_1 INT;
	DECLARE V_T16PS1_YMDHM_1 VARCHAR(12);
	DECLARE V_TH16_POS_FNH_YMDHM_1 VARCHAR(12);	
 
	DECLARE V_QLTY_VEHL_CD_2 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2 VARCHAR(4);
	DECLARE V_LANG_CD_2 VARCHAR(3);
	DECLARE V_APL_YMD_2 VARCHAR(8);
	DECLARE V_PRDN_QTY_2 INT;
	DECLARE V_PRDN_QTY2_2 INT;
	DECLARE V_PRDN_QTY3_2 INT;
	DECLARE V_TH0_POW_TRWI_QTY_2 INT;
	DECLARE V_TH0_POS_STRT_YMD_2 VARCHAR(8);
	DECLARE V_TH0_POS_FNH_YMD_2 VARCHAR(8);
	DECLARE V_TH1_POW_TRWI_QTY_2 INT;
	DECLARE V_TH1_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH1_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH2_POW_TRWI_QTY_2 INT;
	DECLARE V_TH2_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH2_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH3_POW_TRWI_QTY_2 INT;
	DECLARE V_TH3_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH3_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH4_POW_TRWI_QTY_2 INT;
	DECLARE V_TH4_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH4_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH5_POW_TRWI_QTY_2 INT;
	DECLARE V_TH5_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH5_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH6_POW_TRWI_QTY_2 INT;
	DECLARE V_TH6_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH6_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH7_POW_TRWI_QTY_2 INT;
	DECLARE V_TH7_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH7_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH8_POW_TRWI_QTY_2 INT;
	DECLARE V_TH8_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH8_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH9_POW_TRWI_QTY_2 INT;
	DECLARE V_TH9_POS_STRT_YMDHM_2 VARCHAR(12);
	DECLARE V_TH9_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH10_POW_TRWI_QTY_2 INT;
	DECLARE V_T10PS1_YMDHM_2 VARCHAR(12); 
	DECLARE V_TH10_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH11_POW_TRWI_QTY_2 INT;
	DECLARE V_T11PS1_YMDHM_2 VARCHAR(12);
	DECLARE V_TH11_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH12_POW_TRWI_QTY_2 INT;
	DECLARE V_T12PS1_YMDHM_2 VARCHAR(12);
	DECLARE V_TH12_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH13_POW_TRWI_QTY_2 INT;
	DECLARE V_T13PS1_YMDHM_2 VARCHAR(12);
	DECLARE V_TH13_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_TH16_POW_TRWI_QTY_2 INT;
	DECLARE V_T16PS1_YMDHM_2 VARCHAR(12);
	DECLARE V_TH16_POS_FNH_YMDHM_2 VARCHAR(12);
	DECLARE V_PRDN_PLNT_CD_2 VARCHAR(3);	
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PROD_MST_INFO CURSOR FOR
									/*(PDI 공통차종 오더내역 조회 부분 포함)	 */
		 					  	            WITH T AS (SELECT A.QLTY_VEHL_CD,	 
		 					  	 		   		   A.MDL_MDY_CD,	 
												   B.LANG_CD,	 
												   A.APL_YMD,	 
												   SUM(A.PRDN_QTY) AS PRDN_QTY,	 
												   SUM(A.PRDN_QTY2) AS PRDN_QTY2,	 
												   SUM(A.PRDN_QTY3) AS PRDN_QTY3,	 
												   SUM(A.TH0_POW_TRWI_QTY) AS TH0_POW_TRWI_QTY,	 
												   MIN(A.TH0_POS_STRT_YMD) AS TH0_POS_STRT_YMD,	 
												   MAX(A.TH0_POS_FNH_YMD) AS TH0_POS_FNH_YMD,	 
												   SUM(A.TH1_POW_TRWI_QTY) AS TH1_POW_TRWI_QTY,	 
												   MIN(A.TH1_POS_STRT_YMDHM) AS TH1_POS_STRT_YMDHM,	 
												   MAX(A.TH1_POS_FNH_YMDHM) AS TH1_POS_FNH_YMDHM,	 
												   SUM(A.TH2_POW_TRWI_QTY) AS TH2_POW_TRWI_QTY,	 
												   MIN(A.TH2_POS_STRT_YMDHM) AS TH2_POS_STRT_YMDHM,	 
												   MAX(A.TH2_POS_FNH_YMDHM) AS TH2_POS_FNH_YMDHM,	 
												   SUM(A.TH3_POW_TRWI_QTY) AS TH3_POW_TRWI_QTY,	 
												   MIN(A.TH3_POS_STRT_YMDHM) AS TH3_POS_STRT_YMDHM,	 
												   MAX(A.TH3_POS_FNH_YMDHM) AS TH3_POS_FNH_YMDHM,	 
												   SUM(A.TH4_POW_TRWI_QTY) AS TH4_POW_TRWI_QTY,	 
												   MIN(A.TH4_POS_STRT_YMDHM) AS TH4_POS_STRT_YMDHM,	 
												   MAX(A.TH4_POS_FNH_YMDHM) AS TH4_POS_FNH_YMDHM,	 
												   SUM(A.TH5_POW_TRWI_QTY) AS TH5_POW_TRWI_QTY,	 
												   MIN(A.TH5_POS_STRT_YMDHM) AS TH5_POS_STRT_YMDHM,	 
												   MAX(A.TH5_POS_FNH_YMDHM) AS TH5_POS_FNH_YMDHM,	 
												   SUM(A.TH6_POW_TRWI_QTY) AS TH6_POW_TRWI_QTY,	 
												   MIN(A.TH6_POS_STRT_YMDHM) AS TH6_POS_STRT_YMDHM,	 
												   MAX(A.TH6_POS_FNH_YMDHM) AS TH6_POS_FNH_YMDHM,	 
												   SUM(A.TH7_POW_TRWI_QTY) AS TH7_POW_TRWI_QTY,	 
												   MIN(A.TH7_POS_STRT_YMDHM) AS TH7_POS_STRT_YMDHM,	 
												   MAX(A.TH7_POS_FNH_YMDHM) AS TH7_POS_FNH_YMDHM,	 
												   SUM(A.TH8_POW_TRWI_QTY) AS TH8_POW_TRWI_QTY,	 
												   MIN(A.TH8_POS_STRT_YMDHM) AS TH8_POS_STRT_YMDHM,	 
												   MAX(A.TH8_POS_FNH_YMDHM) AS TH8_POS_FNH_YMDHM,	 
												   SUM(A.TH9_POW_TRWI_QTY) AS TH9_POW_TRWI_QTY,	 
												   MIN(A.TH9_POS_STRT_YMDHM) AS TH9_POS_STRT_YMDHM,	 
												   MAX(A.TH9_POS_FNH_YMDHM) AS TH9_POS_FNH_YMDHM,	 
												   SUM(A.TH10_POW_TRWI_QTY) AS TH10_POW_TRWI_QTY,	 
												   MIN(A.T10PS1_YMDHM) AS T10PS1_YMDHM,	 
												   MAX(A.TH10_POS_FNH_YMDHM) AS TH10_POS_FNH_YMDHM,	 
												   SUM(A.TH11_POW_TRWI_QTY) AS TH11_POW_TRWI_QTY,	 
												   MIN(A.T11PS1_YMDHM) AS T11PS1_YMDHM,	 
												   MAX(A.TH11_POS_FNH_YMDHM) AS TH11_POS_FNH_YMDHM,	 
												   SUM(A.TH12_POW_TRWI_QTY) AS TH12_POW_TRWI_QTY,	 
												   MIN(A.T12PS1_YMDHM) AS T12PS1_YMDHM,	 
												   MAX(A.TH12_POS_FNH_YMDHM) AS TH12_POS_FNH_YMDHM,	 
												   SUM(A.TH13_POW_TRWI_QTY) AS TH13_POW_TRWI_QTY,	 
												   MIN(A.T13PS1_YMDHM) AS T13PS1_YMDHM,	 
												   MAX(A.TH13_POS_FNH_YMDHM) AS TH13_POS_FNH_YMDHM,	
												   SUM(A.TH16_POW_TRWI_QTY) AS TH16_POW_TRWI_QTY,	 
												   MIN(A.T16PS1_YMDHM) AS T16PS1_YMDHM,	 
												   MAX(A.TH16_POS_FNH_YMDHM) AS TH16_POS_FNH_YMDHM	 
		 					  	            FROM (SELECT QLTY_VEHL_CD,	 
								 	  		  	 		 MDL_MDY_CD,	 
											  			 DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											  			 CURR_YMD AS APL_YMD,	 
											  			 SUM(CASE WHEN TRWI_USED_YN IS NULL THEN 1 ELSE 0 END) AS PRDN_QTY,	 
											  			 SUM(CASE WHEN TRWI_USED_YN IS NULL AND POW_LOC_CD >= '08' THEN 1 ELSE 0 END) AS PRDN_QTY2,	 
											  			 SUM(CASE WHEN TRWI_USED_YN IS NULL AND POW_LOC_CD >= '09' THEN 1 ELSE 0 END) AS PRDN_QTY3,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '00' THEN 1 ELSE 0 END) AS TH0_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '00' THEN TH0_POW_STRT_YMD ELSE '' END) AS TH0_POS_STRT_YMD,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '00' THEN TH0_POW_STRT_YMD ELSE '' END) AS TH0_POS_FNH_YMD,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '01' THEN 1 ELSE 0 END) AS TH1_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '01' THEN TH1_POW_STRT_YMDHM ELSE '' END) AS TH1_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '01' THEN TH1_POW_STRT_YMDHM ELSE '' END) AS TH1_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '02' THEN 1 ELSE 0 END) AS TH2_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '02' THEN TH2_POW_STRT_YMDHM ELSE '' END) AS TH2_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '02' THEN TH2_POW_STRT_YMDHM ELSE '' END) AS TH2_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '03' THEN 1 ELSE 0 END) AS TH3_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '03' THEN TH3_POW_STRT_YMDHM ELSE '' END) AS TH3_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '03' THEN TH3_POW_STRT_YMDHM ELSE '' END) AS TH3_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '04' THEN 1 ELSE 0 END) AS TH4_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '04' THEN TH4_POW_STRT_YMDHM ELSE '' END) AS TH4_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '04' THEN TH4_POW_STRT_YMDHM ELSE '' END) AS TH4_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '05' THEN 1 ELSE 0 END) AS TH5_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '05' THEN TH5_POW_STRT_YMDHM ELSE '' END) AS TH5_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '05' THEN TH5_POW_STRT_YMDHM ELSE '' END) AS TH5_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '06' THEN 1 ELSE 0 END) AS TH6_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '06' THEN TH6_POW_STRT_YMDHM ELSE '' END) AS TH6_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '06' THEN TH6_POW_STRT_YMDHM ELSE '' END) AS TH6_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '07' THEN 1 ELSE 0 END) AS TH7_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '07' THEN TH7_POW_STRT_YMDHM ELSE '' END) AS TH7_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '07' THEN TH7_POW_STRT_YMDHM ELSE '' END) AS TH7_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '08' THEN 1 ELSE 0 END) AS TH8_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '08' THEN TH8_POW_STRT_YMDHM ELSE '' END) AS TH8_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '08' THEN TH8_POW_STRT_YMDHM ELSE '' END) AS TH8_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '09' THEN 1 ELSE 0 END) AS TH9_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '09' THEN TH9_POW_STRT_YMDHM ELSE '' END) AS TH9_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '09' THEN TH9_POW_STRT_YMDHM ELSE '' END) AS TH9_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '10' THEN 1 ELSE 0 END) AS TH10_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '10' THEN T10PS1_YMDHM ELSE '' END) AS T10PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '10' THEN T10PS1_YMDHM ELSE '' END) AS TH10_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '11' THEN 1 ELSE 0 END) AS TH11_POW_TRWI_QTY,	 
											 			 MIN(CASE WHEN POW_LOC_CD = '11' THEN T11PS1_YMDHM ELSE '' END) AS T11PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '11' THEN T11PS1_YMDHM ELSE '' END) AS TH11_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '12' THEN 1 ELSE 0 END) AS TH12_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '12' THEN T12PS1_YMDHM ELSE '' END) AS T12PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '12' THEN T12PS1_YMDHM ELSE '' END) AS TH12_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '13' THEN 1 ELSE 0 END) AS TH13_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '13' THEN T13PS1_YMDHM ELSE '' END) AS T13PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '13' THEN T13PS1_YMDHM ELSE '' END) AS TH13_POS_FNH_YMDHM,		 
											  			 SUM(CASE WHEN POW_LOC_CD = '16' THEN 1 ELSE 0 END) AS TH16_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '16' THEN T16PS1_YMDHM ELSE '' END) AS T16PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '16' THEN T16PS1_YMDHM ELSE '' END) AS TH16_POS_FNH_YMDHM	 
									               FROM TB_PROD_MST_PROG_INFO	 
									   			   WHERE DL_EXPD_CO_CD = P_EXPD_CO_CD	 
									   			   AND APL_STRT_YMD <= CURR_YMD	 
									   			   AND APL_FNH_YMD > CURR_YMD	 
									   			   AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
									   			   AND QLTY_VEHL_CD NOT IN (SELECT QLTY_VEHL_CD FROM TB_PLNT_VEHL_MGMT GROUP BY QLTY_VEHL_CD)	 
									   			   AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
									   			   AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
									   			   GROUP BY QLTY_VEHL_CD,	 
									  		       		 	MDL_MDY_CD,	 
															DL_EXPD_NAT_CD	 
								                 ) A,	 
									  			 TB_NATL_LANG_MGMT B	 
								            WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
								 			AND B.DL_EXPD_CO_CD = P_EXPD_CO_CD	 
								 			AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 			AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 			GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD	 
		 					  	 	  	   )	 
								 SELECT QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, APL_YMD,	 
										PRDN_QTY, PRDN_QTY2, PRDN_QTY3,	 
										TH0_POW_TRWI_QTY,  TH0_POS_STRT_YMD,   TH0_POS_FNH_YMD,	 
										TH1_POW_TRWI_QTY,  TH1_POS_STRT_YMDHM, TH1_POS_FNH_YMDHM,	 
										TH2_POW_TRWI_QTY,  TH2_POS_STRT_YMDHM, TH2_POS_FNH_YMDHM,	 
										TH3_POW_TRWI_QTY,  TH3_POS_STRT_YMDHM, TH3_POS_FNH_YMDHM,	 
										TH4_POW_TRWI_QTY,  TH4_POS_STRT_YMDHM, TH4_POS_FNH_YMDHM,	 
										TH5_POW_TRWI_QTY,  TH5_POS_STRT_YMDHM, TH5_POS_FNH_YMDHM,	 
										TH6_POW_TRWI_QTY,  TH6_POS_STRT_YMDHM, TH6_POS_FNH_YMDHM,	 
										TH7_POW_TRWI_QTY,  TH7_POS_STRT_YMDHM, TH7_POS_FNH_YMDHM,	 
										TH8_POW_TRWI_QTY,  TH8_POS_STRT_YMDHM, TH8_POS_FNH_YMDHM,	 
										TH9_POW_TRWI_QTY,  TH9_POS_STRT_YMDHM, TH9_POS_FNH_YMDHM,	 
										TH10_POW_TRWI_QTY, T10PS1_YMDHM,       TH10_POS_FNH_YMDHM,	 
										TH11_POW_TRWI_QTY, T11PS1_YMDHM,       TH11_POS_FNH_YMDHM,	 
										TH12_POW_TRWI_QTY, T12PS1_YMDHM,       TH12_POS_FNH_YMDHM,	 
										TH13_POW_TRWI_QTY, T13PS1_YMDHM,       TH13_POS_FNH_YMDHM,
										TH16_POW_TRWI_QTY, T16PS1_YMDHM,       TH16_POS_FNH_YMDHM	 
								 FROM T	 
	 
								 UNION ALL	 
	 
								 SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								        B.MDL_MDY_CD,	 
									    B.LANG_CD,	 
										A.APL_YMD,	 
										SUM(A.PRDN_QTY) AS PRDN_QTY,	 
										SUM(A.PRDN_QTY2) AS PRDN_QTY2,	 
										SUM(A.PRDN_QTY3) AS PRDN_QTY3,	 
										SUM(A.TH0_POW_TRWI_QTY) AS TH0_POW_TRWI_QTY,	 
										MIN(A.TH0_POS_STRT_YMD) AS TH0_POS_STRT_YMD,	 
										MAX(A.TH0_POS_FNH_YMD) AS TH0_POS_FNH_YMD,	 
										SUM(A.TH1_POW_TRWI_QTY) AS TH1_POW_TRWI_QTY,	 
										MIN(A.TH1_POS_STRT_YMDHM) AS TH1_POS_STRT_YMDHM,	 
										MAX(A.TH1_POS_FNH_YMDHM) AS TH1_POS_FNH_YMDHM,	 
										SUM(A.TH2_POW_TRWI_QTY) AS TH2_POW_TRWI_QTY,	 
										MIN(A.TH2_POS_STRT_YMDHM) AS TH2_POS_STRT_YMDHM,	 
										MAX(A.TH2_POS_FNH_YMDHM) AS TH2_POS_FNH_YMDHM,	 
										SUM(A.TH3_POW_TRWI_QTY) AS TH3_POW_TRWI_QTY,	 
										MIN(A.TH3_POS_STRT_YMDHM) AS TH3_POS_STRT_YMDHM,	 
										MAX(A.TH3_POS_FNH_YMDHM) AS TH3_POS_FNH_YMDHM,	 
										SUM(A.TH4_POW_TRWI_QTY) AS TH4_POW_TRWI_QTY,	 
										MIN(A.TH4_POS_STRT_YMDHM) AS TH4_POS_STRT_YMDHM,	 
										MAX(A.TH4_POS_FNH_YMDHM) AS TH4_POS_FNH_YMDHM,	 
										SUM(A.TH5_POW_TRWI_QTY) AS TH5_POW_TRWI_QTY,	 
										MIN(A.TH5_POS_STRT_YMDHM) AS TH5_POS_STRT_YMDHM,	 
										MAX(A.TH5_POS_FNH_YMDHM) AS TH5_POS_FNH_YMDHM,	 
										SUM(A.TH6_POW_TRWI_QTY) AS TH6_POW_TRWI_QTY,	 
										MIN(A.TH6_POS_STRT_YMDHM) AS TH6_POS_STRT_YMDHM,	 
										MAX(A.TH6_POS_FNH_YMDHM) AS TH6_POS_FNH_YMDHM,	 
										SUM(A.TH7_POW_TRWI_QTY) AS TH7_POW_TRWI_QTY,	 
										MIN(A.TH7_POS_STRT_YMDHM) AS TH7_POS_STRT_YMDHM,	 
										MAX(A.TH7_POS_FNH_YMDHM) AS TH7_POS_FNH_YMDHM,	 
										SUM(A.TH8_POW_TRWI_QTY) AS TH8_POW_TRWI_QTY,	 
										MIN(A.TH8_POS_STRT_YMDHM) AS TH8_POS_STRT_YMDHM,	 
										MAX(A.TH8_POS_FNH_YMDHM) AS TH8_POS_FNH_YMDHM,	 
										SUM(A.TH9_POW_TRWI_QTY) AS TH9_POW_TRWI_QTY,	 
										MIN(A.TH9_POS_STRT_YMDHM) AS TH9_POS_STRT_YMDHM,	 
										MAX(A.TH9_POS_FNH_YMDHM) AS TH9_POS_FNH_YMDHM,	 
										SUM(A.TH10_POW_TRWI_QTY) AS TH10_POW_TRWI_QTY,	 
										MIN(A.T10PS1_YMDHM) AS T10PS1_YMDHM,	 
										MAX(A.TH10_POS_FNH_YMDHM) AS TH10_POS_FNH_YMDHM,	 
										SUM(A.TH11_POW_TRWI_QTY) AS TH11_POW_TRWI_QTY,	 
										MIN(A.T11PS1_YMDHM) AS T11PS1_YMDHM,	 
										MAX(A.TH11_POS_FNH_YMDHM) AS TH11_POS_FNH_YMDHM,	 
										SUM(A.TH12_POW_TRWI_QTY) AS TH12_POW_TRWI_QTY,	 
										MIN(A.T12PS1_YMDHM) AS T12PS1_YMDHM,	 
										MAX(A.TH12_POS_FNH_YMDHM) AS TH12_POS_FNH_YMDHM,	 
										SUM(A.TH13_POW_TRWI_QTY) AS TH13_POW_TRWI_QTY,	 
										MIN(A.T13PS1_YMDHM) AS T13PS1_YMDHM,	 
										MAX(A.TH13_POS_FNH_YMDHM) AS TH13_POS_FNH_YMDHM,	 
										SUM(A.TH16_POW_TRWI_QTY) AS TH16_POW_TRWI_QTY,	 
										MIN(A.T16PS1_YMDHM) AS T16PS1_YMDHM,	 
										MAX(A.TH16_POS_FNH_YMDHM) AS TH16_POS_FNH_YMDHM	 
								 FROM T A,	 
								      TB_PDI_COM_VEHL_MGMT B	 
							     WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 AND A.LANG_CD = B.LANG_CD	 
								 GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD;	 

	DECLARE PLNT_MST_INFO CURSOR FOR
										/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 조회	 */
		 					  	            WITH T AS (SELECT A.QLTY_VEHL_CD,	 
		 					  	 		   		   A.MDL_MDY_CD,	 
												   B.LANG_CD,	 
												   A.APL_YMD,	 
												   A.PRDN_PLNT_CD,	 
												   SUM(A.PRDN_QTY) AS PRDN_QTY,	 
												   SUM(A.PRDN_QTY2) AS PRDN_QTY2,	 
												   SUM(A.PRDN_QTY3) AS PRDN_QTY3,	 
												   SUM(A.TH0_POW_TRWI_QTY) AS TH0_POW_TRWI_QTY,	 
												   MIN(A.TH0_POS_STRT_YMD) AS TH0_POS_STRT_YMD,	 
												   MAX(A.TH0_POS_FNH_YMD) AS TH0_POS_FNH_YMD,	 
												   SUM(A.TH1_POW_TRWI_QTY) AS TH1_POW_TRWI_QTY,	 
												   MIN(A.TH1_POS_STRT_YMDHM) AS TH1_POS_STRT_YMDHM,	 
												   MAX(A.TH1_POS_FNH_YMDHM) AS TH1_POS_FNH_YMDHM,	 
												   SUM(A.TH2_POW_TRWI_QTY) AS TH2_POW_TRWI_QTY,	 
												   MIN(A.TH2_POS_STRT_YMDHM) AS TH2_POS_STRT_YMDHM,	 
												   MAX(A.TH2_POS_FNH_YMDHM) AS TH2_POS_FNH_YMDHM,	 
												   SUM(A.TH3_POW_TRWI_QTY) AS TH3_POW_TRWI_QTY,	 
												   MIN(A.TH3_POS_STRT_YMDHM) AS TH3_POS_STRT_YMDHM,	 
												   MAX(A.TH3_POS_FNH_YMDHM) AS TH3_POS_FNH_YMDHM,	 
												   SUM(A.TH4_POW_TRWI_QTY) AS TH4_POW_TRWI_QTY,	 
												   MIN(A.TH4_POS_STRT_YMDHM) AS TH4_POS_STRT_YMDHM,	 
												   MAX(A.TH4_POS_FNH_YMDHM) AS TH4_POS_FNH_YMDHM,	 
												   SUM(A.TH5_POW_TRWI_QTY) AS TH5_POW_TRWI_QTY,	 
												   MIN(A.TH5_POS_STRT_YMDHM) AS TH5_POS_STRT_YMDHM,	 
												   MAX(A.TH5_POS_FNH_YMDHM) AS TH5_POS_FNH_YMDHM,	 
												   SUM(A.TH6_POW_TRWI_QTY) AS TH6_POW_TRWI_QTY,	 
												   MIN(A.TH6_POS_STRT_YMDHM) AS TH6_POS_STRT_YMDHM,	 
												   MAX(A.TH6_POS_FNH_YMDHM) AS TH6_POS_FNH_YMDHM,	 
												   SUM(A.TH7_POW_TRWI_QTY) AS TH7_POW_TRWI_QTY,	 
												   MIN(A.TH7_POS_STRT_YMDHM) AS TH7_POS_STRT_YMDHM,	 
												   MAX(A.TH7_POS_FNH_YMDHM) AS TH7_POS_FNH_YMDHM,	 
												   SUM(A.TH8_POW_TRWI_QTY) AS TH8_POW_TRWI_QTY,	 
												   MIN(A.TH8_POS_STRT_YMDHM) AS TH8_POS_STRT_YMDHM,	 
												   MAX(A.TH8_POS_FNH_YMDHM) AS TH8_POS_FNH_YMDHM,	 
												   SUM(A.TH9_POW_TRWI_QTY) AS TH9_POW_TRWI_QTY,	 
												   MIN(A.TH9_POS_STRT_YMDHM) AS TH9_POS_STRT_YMDHM,	 
												   MAX(A.TH9_POS_FNH_YMDHM) AS TH9_POS_FNH_YMDHM,	 
												   SUM(A.TH10_POW_TRWI_QTY) AS TH10_POW_TRWI_QTY,	 
												   MIN(A.T10PS1_YMDHM) AS T10PS1_YMDHM,	 
												   MAX(A.TH10_POS_FNH_YMDHM) AS TH10_POS_FNH_YMDHM,	 
												   SUM(A.TH11_POW_TRWI_QTY) AS TH11_POW_TRWI_QTY,	 
												   MIN(A.T11PS1_YMDHM) AS T11PS1_YMDHM,	 
												   MAX(A.TH11_POS_FNH_YMDHM) AS TH11_POS_FNH_YMDHM,	 
												   SUM(A.TH12_POW_TRWI_QTY) AS TH12_POW_TRWI_QTY,	 
												   MIN(A.T12PS1_YMDHM) AS T12PS1_YMDHM,	 
												   MAX(A.TH12_POS_FNH_YMDHM) AS TH12_POS_FNH_YMDHM,	 
												   SUM(A.TH13_POW_TRWI_QTY) AS TH13_POW_TRWI_QTY,	 
												   MIN(A.T13PS1_YMDHM) AS T13PS1_YMDHM,	 
												   MAX(A.TH13_POS_FNH_YMDHM) AS TH13_POS_FNH_YMDHM,	 
												   SUM(A.TH16_POW_TRWI_QTY) AS TH16_POW_TRWI_QTY,	 
												   MIN(A.T16PS1_YMDHM) AS T16PS1_YMDHM,	 
												   MAX(A.TH16_POS_FNH_YMDHM) AS TH16_POS_FNH_YMDHM	 
		 					  	            FROM (SELECT A.QLTY_VEHL_CD,	 
								 	  		  	 		 A.MDL_MDY_CD,	 
											  			 A.DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											  			 CURR_YMD AS APL_YMD,	 
														 B.PRDN_PLNT_CD,	 
											  			 SUM(CASE WHEN TRWI_USED_YN IS NULL THEN 1 ELSE 0 END) AS PRDN_QTY,	 
											  			 SUM(CASE WHEN TRWI_USED_YN IS NULL AND POW_LOC_CD >= '08' THEN 1 ELSE 0 END) AS PRDN_QTY2,	 
											  			 SUM(CASE WHEN TRWI_USED_YN IS NULL AND POW_LOC_CD >= '09' THEN 1 ELSE 0 END) AS PRDN_QTY3,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '00' THEN 1 ELSE 0 END) AS TH0_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '00' THEN TH0_POW_STRT_YMD ELSE '' END) AS TH0_POS_STRT_YMD,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '00' THEN TH0_POW_STRT_YMD ELSE '' END) AS TH0_POS_FNH_YMD,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '01' THEN 1 ELSE 0 END) AS TH1_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '01' THEN TH1_POW_STRT_YMDHM ELSE '' END) AS TH1_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '01' THEN TH1_POW_STRT_YMDHM ELSE '' END) AS TH1_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '02' THEN 1 ELSE 0 END) AS TH2_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '02' THEN TH2_POW_STRT_YMDHM ELSE '' END) AS TH2_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '02' THEN TH2_POW_STRT_YMDHM ELSE '' END) AS TH2_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '03' THEN 1 ELSE 0 END) AS TH3_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '03' THEN TH3_POW_STRT_YMDHM ELSE '' END) AS TH3_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '03' THEN TH3_POW_STRT_YMDHM ELSE '' END) AS TH3_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '04' THEN 1 ELSE 0 END) AS TH4_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '04' THEN TH4_POW_STRT_YMDHM ELSE '' END) AS TH4_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '04' THEN TH4_POW_STRT_YMDHM ELSE '' END) AS TH4_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '05' THEN 1 ELSE 0 END) AS TH5_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '05' THEN TH5_POW_STRT_YMDHM ELSE '' END) AS TH5_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '05' THEN TH5_POW_STRT_YMDHM ELSE '' END) AS TH5_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '06' THEN 1 ELSE 0 END) AS TH6_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '06' THEN TH6_POW_STRT_YMDHM ELSE '' END) AS TH6_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '06' THEN TH6_POW_STRT_YMDHM ELSE '' END) AS TH6_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '07' THEN 1 ELSE 0 END) AS TH7_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '07' THEN TH7_POW_STRT_YMDHM ELSE '' END) AS TH7_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '07' THEN TH7_POW_STRT_YMDHM ELSE '' END) AS TH7_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '08' THEN 1 ELSE 0 END) AS TH8_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '08' THEN TH8_POW_STRT_YMDHM ELSE '' END) AS TH8_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '08' THEN TH8_POW_STRT_YMDHM ELSE '' END) AS TH8_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '09' THEN 1 ELSE 0 END) AS TH9_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '09' THEN TH9_POW_STRT_YMDHM ELSE '' END) AS TH9_POS_STRT_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '09' THEN TH9_POW_STRT_YMDHM ELSE '' END) AS TH9_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '10' THEN 1 ELSE 0 END) AS TH10_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '10' THEN T10PS1_YMDHM ELSE '' END) AS T10PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '10' THEN T10PS1_YMDHM ELSE '' END) AS TH10_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '11' THEN 1 ELSE 0 END) AS TH11_POW_TRWI_QTY,	 
											 			 MIN(CASE WHEN POW_LOC_CD = '11' THEN T11PS1_YMDHM ELSE '' END) AS T11PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '11' THEN T11PS1_YMDHM ELSE '' END) AS TH11_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '12' THEN 1 ELSE 0 END) AS TH12_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '12' THEN T12PS1_YMDHM ELSE '' END) AS T12PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '12' THEN T12PS1_YMDHM ELSE '' END) AS TH12_POS_FNH_YMDHM,	 
											  			 SUM(CASE WHEN POW_LOC_CD = '13' THEN 1 ELSE 0 END) AS TH13_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '13' THEN T13PS1_YMDHM ELSE '' END) AS T13PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '13' THEN T13PS1_YMDHM ELSE '' END) AS TH13_POS_FNH_YMDHM,
											  			 SUM(CASE WHEN POW_LOC_CD = '16' THEN 1 ELSE 0 END) AS TH16_POW_TRWI_QTY,	 
											  			 MIN(CASE WHEN POW_LOC_CD = '16' THEN T16PS1_YMDHM ELSE '' END) AS T16PS1_YMDHM,	 
											  			 MAX(CASE WHEN POW_LOC_CD = '16' THEN T16PS1_YMDHM ELSE '' END) AS TH16_POS_FNH_YMDHM	 
									               FROM TB_PROD_MST_PROG_INFO A,	 
												   		TB_PLNT_VEHL_MGMT B	 
									   			   WHERE A.DL_EXPD_CO_CD = P_EXPD_CO_CD	 
									   			   AND A.APL_STRT_YMD <= CURR_YMD	 
									   			   AND A.APL_FNH_YMD > CURR_YMD	 
												   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
												   AND A.PRDN_PLNT_CD = B.PRDN_PLNT_CD	 
									   			   AND A.QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
									   			   AND A.MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
									   			   AND A.DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
									   			   GROUP BY A.QLTY_VEHL_CD,	 
									  		       		 	A.MDL_MDY_CD,	 
															A.DL_EXPD_NAT_CD,	 
															B.PRDN_PLNT_CD	 
								                 ) A,	 
									  			 TB_NATL_LANG_MGMT B	 
								            WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
								 			AND B.DL_EXPD_CO_CD = P_EXPD_CO_CD	 
								 			AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 			AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 			GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.PRDN_PLNT_CD	 
		 					  	 	  	   )	 
								 SELECT QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, APL_YMD,	 
										PRDN_QTY, PRDN_QTY2, PRDN_QTY3,	 
										TH0_POW_TRWI_QTY,  TH0_POS_STRT_YMD,   TH0_POS_FNH_YMD,	 
										TH1_POW_TRWI_QTY,  TH1_POS_STRT_YMDHM, TH1_POS_FNH_YMDHM,	 
										TH2_POW_TRWI_QTY,  TH2_POS_STRT_YMDHM, TH2_POS_FNH_YMDHM,	 
										TH3_POW_TRWI_QTY,  TH3_POS_STRT_YMDHM, TH3_POS_FNH_YMDHM,	 
										TH4_POW_TRWI_QTY,  TH4_POS_STRT_YMDHM, TH4_POS_FNH_YMDHM,	 
										TH5_POW_TRWI_QTY,  TH5_POS_STRT_YMDHM, TH5_POS_FNH_YMDHM,	 
										TH6_POW_TRWI_QTY,  TH6_POS_STRT_YMDHM, TH6_POS_FNH_YMDHM,	 
										TH7_POW_TRWI_QTY,  TH7_POS_STRT_YMDHM, TH7_POS_FNH_YMDHM,	 
										TH8_POW_TRWI_QTY,  TH8_POS_STRT_YMDHM, TH8_POS_FNH_YMDHM,	 
										TH9_POW_TRWI_QTY,  TH9_POS_STRT_YMDHM, TH9_POS_FNH_YMDHM,	 
										TH10_POW_TRWI_QTY, T10PS1_YMDHM,       TH10_POS_FNH_YMDHM,	 
										TH11_POW_TRWI_QTY, T11PS1_YMDHM,       TH11_POS_FNH_YMDHM,	 
										TH12_POW_TRWI_QTY, T12PS1_YMDHM,       TH12_POS_FNH_YMDHM,	 
										TH13_POW_TRWI_QTY, T13PS1_YMDHM,       TH13_POS_FNH_YMDHM,
										TH16_POW_TRWI_QTY, T16PS1_YMDHM,       TH16_POS_FNH_YMDHM,	 
										PRDN_PLNT_CD	 
								 FROM T	 
	 
								 UNION ALL	 
	 
								 SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								        B.MDL_MDY_CD,	 
									    B.LANG_CD,	 
										A.APL_YMD,	 
										SUM(A.PRDN_QTY) AS PRDN_QTY,	 
										SUM(A.PRDN_QTY2) AS PRDN_QTY2,	 
										SUM(A.PRDN_QTY3) AS PRDN_QTY3,	 
										SUM(A.TH0_POW_TRWI_QTY) AS TH0_POW_TRWI_QTY,	 
										MIN(A.TH0_POS_STRT_YMD) AS TH0_POS_STRT_YMD,	 
										MAX(A.TH0_POS_FNH_YMD) AS TH0_POS_FNH_YMD,	 
										SUM(A.TH1_POW_TRWI_QTY) AS TH1_POW_TRWI_QTY,	 
										MIN(A.TH1_POS_STRT_YMDHM) AS TH1_POS_STRT_YMDHM,	 
										MAX(A.TH1_POS_FNH_YMDHM) AS TH1_POS_FNH_YMDHM,	 
										SUM(A.TH2_POW_TRWI_QTY) AS TH2_POW_TRWI_QTY,	 
										MIN(A.TH2_POS_STRT_YMDHM) AS TH2_POS_STRT_YMDHM,	 
										MAX(A.TH2_POS_FNH_YMDHM) AS TH2_POS_FNH_YMDHM,	 
										SUM(A.TH3_POW_TRWI_QTY) AS TH3_POW_TRWI_QTY,	 
										MIN(A.TH3_POS_STRT_YMDHM) AS TH3_POS_STRT_YMDHM,	 
										MAX(A.TH3_POS_FNH_YMDHM) AS TH3_POS_FNH_YMDHM,	 
										SUM(A.TH4_POW_TRWI_QTY) AS TH4_POW_TRWI_QTY,	 
										MIN(A.TH4_POS_STRT_YMDHM) AS TH4_POS_STRT_YMDHM,	 
										MAX(A.TH4_POS_FNH_YMDHM) AS TH4_POS_FNH_YMDHM,	 
										SUM(A.TH5_POW_TRWI_QTY) AS TH5_POW_TRWI_QTY,	 
										MIN(A.TH5_POS_STRT_YMDHM) AS TH5_POS_STRT_YMDHM,	 
										MAX(A.TH5_POS_FNH_YMDHM) AS TH5_POS_FNH_YMDHM,	 
										SUM(A.TH6_POW_TRWI_QTY) AS TH6_POW_TRWI_QTY,	 
										MIN(A.TH6_POS_STRT_YMDHM) AS TH6_POS_STRT_YMDHM,	 
										MAX(A.TH6_POS_FNH_YMDHM) AS TH6_POS_FNH_YMDHM,	 
										SUM(A.TH7_POW_TRWI_QTY) AS TH7_POW_TRWI_QTY,	 
										MIN(A.TH7_POS_STRT_YMDHM) AS TH7_POS_STRT_YMDHM,	 
										MAX(A.TH7_POS_FNH_YMDHM) AS TH7_POS_FNH_YMDHM,	 
										SUM(A.TH8_POW_TRWI_QTY) AS TH8_POW_TRWI_QTY,	 
										MIN(A.TH8_POS_STRT_YMDHM) AS TH8_POS_STRT_YMDHM,	 
										MAX(A.TH8_POS_FNH_YMDHM) AS TH8_POS_FNH_YMDHM,	 
										SUM(A.TH9_POW_TRWI_QTY) AS TH9_POW_TRWI_QTY,	 
										MIN(A.TH9_POS_STRT_YMDHM) AS TH9_POS_STRT_YMDHM,	 
										MAX(A.TH9_POS_FNH_YMDHM) AS TH9_POS_FNH_YMDHM,	 
										SUM(A.TH10_POW_TRWI_QTY) AS TH10_POW_TRWI_QTY,	 
										MIN(A.T10PS1_YMDHM) AS T10PS1_YMDHM,	 
										MAX(A.TH10_POS_FNH_YMDHM) AS TH10_POS_FNH_YMDHM,	 
										SUM(A.TH11_POW_TRWI_QTY) AS TH11_POW_TRWI_QTY,	 
										MIN(A.T11PS1_YMDHM) AS T11PS1_YMDHM,	 
										MAX(A.TH11_POS_FNH_YMDHM) AS TH11_POS_FNH_YMDHM,	 
										SUM(A.TH12_POW_TRWI_QTY) AS TH12_POW_TRWI_QTY,	 
										MIN(A.T12PS1_YMDHM) AS T12PS1_YMDHM,	 
										MAX(A.TH12_POS_FNH_YMDHM) AS TH12_POS_FNH_YMDHM,	 
										SUM(A.TH13_POW_TRWI_QTY) AS TH13_POW_TRWI_QTY,	 
										MIN(A.T13PS1_YMDHM) AS T13PS1_YMDHM,	 
										MAX(A.TH13_POS_FNH_YMDHM) AS TH13_POS_FNH_YMDHM,	 
										SUM(A.TH16_POW_TRWI_QTY) AS TH16_POW_TRWI_QTY,	 
										MIN(A.T16PS1_YMDHM) AS T16PS1_YMDHM,	 
										MAX(A.TH16_POS_FNH_YMDHM) AS TH16_POS_FNH_YMDHM,	 
										A.PRDN_PLNT_CD	 
								 FROM T A,	 
								      TB_PDI_COM_VEHL_MGMT B	 
							     WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 AND A.LANG_CD = B.LANG_CD	 
								 GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD, A.PRDN_PLNT_CD;	 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_PROG_SUM',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_APL_YMD_1:',IFNULL(V_APL_YMD_1,'')
							,',V_PRDN_QTY_1:',IFNULL(CONCAT(V_PRDN_QTY_1),'')
							,',V_PRDN_QTY2_1:',IFNULL(CONCAT(V_PRDN_QTY2_1),'')
							,',V_PRDN_QTY3_1:',IFNULL(CONCAT(V_PRDN_QTY3_1),'')
							,',V_TH0_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH0_POW_TRWI_QTY_1),'')
							,',V_TH0_POS_STRT_YMD_1:',IFNULL(V_TH0_POS_STRT_YMD_1,'')
							,',V_TH0_POS_FNH_YMD_1:',IFNULL(V_TH0_POS_FNH_YMD_1,'')
							,',V_TH1_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH1_POW_TRWI_QTY_1),'')
							,',V_TH1_POS_STRT_YMDHM_1:',IFNULL(V_TH1_POS_STRT_YMDHM_1,'')
							,',V_TH1_POS_FNH_YMDHM_1:',IFNULL(V_TH1_POS_FNH_YMDHM_1,'')
							,',V_TH2_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH2_POW_TRWI_QTY_1),'')
							,',V_TH2_POS_STRT_YMDHM_1:',IFNULL(V_TH2_POS_STRT_YMDHM_1,'')
							,',V_TH2_POS_FNH_YMDHM_1:',IFNULL(V_TH2_POS_FNH_YMDHM_1,'')
							,',V_TH3_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH3_POW_TRWI_QTY_1),'')
							,',V_TH3_POS_STRT_YMDHM_1:',IFNULL(V_TH3_POS_STRT_YMDHM_1,'')
							,',V_TH3_POS_FNH_YMDHM_1:',IFNULL(V_TH3_POS_FNH_YMDHM_1,'')
							,',V_TH4_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH4_POW_TRWI_QTY_1),'')
							,',V_TH4_POS_STRT_YMDHM_1:',IFNULL(V_TH4_POS_STRT_YMDHM_1,'')
							,',V_TH4_POS_FNH_YMDHM_1:',IFNULL(V_TH4_POS_FNH_YMDHM_1,'')
							,',V_TH5_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH5_POW_TRWI_QTY_1),'')
							,',V_TH5_POS_STRT_YMDHM_1:',IFNULL(V_TH5_POS_STRT_YMDHM_1,'')
							,',V_TH5_POS_FNH_YMDHM_1:',IFNULL(V_TH5_POS_FNH_YMDHM_1,'')
							,',V_TH6_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH6_POW_TRWI_QTY_1),'')
							,',V_TH6_POS_STRT_YMDHM_1:',IFNULL(V_TH6_POS_STRT_YMDHM_1,'')
							,',V_TH6_POS_FNH_YMDHM_1:',IFNULL(V_TH6_POS_FNH_YMDHM_1,'')
							,',V_TH7_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH7_POW_TRWI_QTY_1),'')
							,',V_TH7_POS_STRT_YMDHM_1:',IFNULL(V_TH7_POS_STRT_YMDHM_1,'')
							,',V_TH7_POS_FNH_YMDHM_1:',IFNULL(V_TH7_POS_FNH_YMDHM_1,'')
							,',V_TH8_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH8_POW_TRWI_QTY_1),'')
							,',V_TH8_POS_STRT_YMDHM_1:',IFNULL(V_TH8_POS_STRT_YMDHM_1,'')
							,',V_TH8_POS_FNH_YMDHM_1:',IFNULL(V_TH8_POS_FNH_YMDHM_1,'')
							,',V_TH9_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH9_POW_TRWI_QTY_1),'')
							,',V_TH9_POS_STRT_YMDHM_1:',IFNULL(V_TH9_POS_STRT_YMDHM_1,'')
							,',V_TH9_POS_FNH_YMDHM_1:',IFNULL(V_TH9_POS_FNH_YMDHM_1,'')
							,',V_TH10_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH10_POW_TRWI_QTY_1),'')
							,',V_T10PS1_YMDHM_1:',IFNULL(V_T10PS1_YMDHM_1,'')
							,',V_TH10_POS_FNH_YMDHM_1:',IFNULL(V_TH10_POS_FNH_YMDHM_1,'')
							,',V_TH11_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH11_POW_TRWI_QTY_1),'')
							,',V_T11PS1_YMDHM_1:',IFNULL(V_T11PS1_YMDHM_1,'')
							,',V_TH11_POS_FNH_YMDHM_1:',IFNULL(V_TH11_POS_FNH_YMDHM_1,'')
							,',V_TH12_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH12_POW_TRWI_QTY_1),'')
							,',V_T12PS1_YMDHM_1:',IFNULL(V_T12PS1_YMDHM_1,'')
							,',V_TH12_POS_FNH_YMDHM_1:',IFNULL(V_TH12_POS_FNH_YMDHM_1,'')
							,',V_TH13_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH13_POW_TRWI_QTY_1),'')
							,',V_T13PS1_YMDHM_1:',IFNULL(V_T13PS1_YMDHM_1,'')
							,',V_TH13_POS_FNH_YMDHM_1:',IFNULL(V_TH13_POS_FNH_YMDHM_1,'')
							,',V_TH16_POW_TRWI_QTY_1:',IFNULL(CONCAT(V_TH16_POW_TRWI_QTY_1),'')
							,',V_T16PS1_YMDHM_1:',IFNULL(V_T16PS1_YMDHM_1,'')
							,',V_TH16_POS_FNH_YMDHM_1:',IFNULL(V_TH16_POS_FNH_YMDHM_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_APL_YMD_2:',IFNULL(V_APL_YMD_2,'')
							,',V_PRDN_QTY_2:',IFNULL(CONCAT(V_PRDN_QTY_2),'')
							,',V_PRDN_QTY2_2:',IFNULL(CONCAT(V_PRDN_QTY2_2),'')
							,',V_PRDN_QTY3_2:',IFNULL(CONCAT(V_PRDN_QTY3_2),'')
							,',V_TH0_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH0_POW_TRWI_QTY_2),'')
							,',V_TH0_POS_STRT_YMD_2:',IFNULL(V_TH0_POS_STRT_YMD_2,'')
							,',V_TH0_POS_FNH_YMD_2:',IFNULL(V_TH0_POS_FNH_YMD_2,'')
							,',V_TH1_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH1_POW_TRWI_QTY_2),'')
							,',V_TH1_POS_STRT_YMDHM_2:',IFNULL(V_TH1_POS_STRT_YMDHM_2,'')
							,',V_TH1_POS_FNH_YMDHM_2:',IFNULL(V_TH1_POS_FNH_YMDHM_2,'')
							,',V_TH2_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH2_POW_TRWI_QTY_2),'')
							,',V_TH2_POS_STRT_YMDHM_2:',IFNULL(V_TH2_POS_STRT_YMDHM_2,'')
							,',V_TH2_POS_FNH_YMDHM_2:',IFNULL(V_TH2_POS_FNH_YMDHM_2,'')
							,',V_TH3_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH3_POW_TRWI_QTY_2),'')
							,',V_TH3_POS_STRT_YMDHM_2:',IFNULL(V_TH3_POS_STRT_YMDHM_2,'')
							,',V_TH3_POS_FNH_YMDHM_2:',IFNULL(V_TH3_POS_FNH_YMDHM_2,'')
							,',V_TH4_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH4_POW_TRWI_QTY_2),'')
							,',V_TH4_POS_STRT_YMDHM_2:',IFNULL(V_TH4_POS_STRT_YMDHM_2,'')
							,',V_TH4_POS_FNH_YMDHM_2:',IFNULL(V_TH4_POS_FNH_YMDHM_2,'')
							,',V_TH5_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH5_POW_TRWI_QTY_2),'')
							,',V_TH5_POS_STRT_YMDHM_2:',IFNULL(V_TH5_POS_STRT_YMDHM_2,'')
							,',V_TH5_POS_FNH_YMDHM_2:',IFNULL(V_TH5_POS_FNH_YMDHM_2,'')
							,',V_TH6_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH6_POW_TRWI_QTY_2),'')
							,',V_TH6_POS_STRT_YMDHM_2:',IFNULL(V_TH6_POS_STRT_YMDHM_2,'')
							,',V_TH6_POS_FNH_YMDHM_2:',IFNULL(V_TH6_POS_FNH_YMDHM_2,'')
							,',V_TH7_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH7_POW_TRWI_QTY_2),'')
							,',V_TH7_POS_STRT_YMDHM_2:',IFNULL(V_TH7_POS_STRT_YMDHM_2,'')
							,',V_TH7_POS_FNH_YMDHM_2:',IFNULL(V_TH7_POS_FNH_YMDHM_2,'')
							,',V_TH8_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH8_POW_TRWI_QTY_2),'')
							,',V_TH8_POS_STRT_YMDHM_2:',IFNULL(V_TH8_POS_STRT_YMDHM_2,'')
							,',V_TH8_POS_FNH_YMDHM_2:',IFNULL(V_TH8_POS_FNH_YMDHM_2,'')
							,',V_TH9_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH9_POW_TRWI_QTY_2),'')
							,',V_TH9_POS_STRT_YMDHM_2:',IFNULL(V_TH9_POS_STRT_YMDHM_2,'')
							,',V_TH9_POS_FNH_YMDHM_2:',IFNULL(V_TH9_POS_FNH_YMDHM_2,'')
							,',V_TH10_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH10_POW_TRWI_QTY_2),'')
							,',V_T10PS1_YMDHM_2:',IFNULL(V_T10PS1_YMDHM_2,'')
							,',V_TH10_POS_FNH_YMDHM_2:',IFNULL(V_TH10_POS_FNH_YMDHM_2,'')
							,',V_TH11_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH11_POW_TRWI_QTY_2),'')
							,',V_T11PS1_YMDHM_2:',IFNULL(V_T11PS1_YMDHM_2,'')
							,',V_TH11_POS_FNH_YMDHM_2:',IFNULL(V_TH11_POS_FNH_YMDHM_2,'')
							,',V_TH12_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH12_POW_TRWI_QTY_2),'')
							,',V_T12PS1_YMDHM_2:',IFNULL(V_T12PS1_YMDHM_2,'')
							,',V_TH12_POS_FNH_YMDHM_2:',IFNULL(V_TH12_POS_FNH_YMDHM_2,'')
							,',V_TH13_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH13_POW_TRWI_QTY_2),'')
							,',V_T13PS1_YMDHM_2:',IFNULL(V_T13PS1_YMDHM_2,'')
							,',V_TH13_POS_FNH_YMDHM_2:',IFNULL(V_TH13_POS_FNH_YMDHM_2,'')
							,',V_TH16_POW_TRWI_QTY_2:',IFNULL(CONCAT(V_TH16_POW_TRWI_QTY_2),'')
							,',V_T16PS1_YMDHM_2:',IFNULL(V_T16PS1_YMDHM_2,'')
							,',V_TH16_POS_FNH_YMDHM_2:',IFNULL(V_TH16_POS_FNH_YMDHM_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

	OPEN PROD_MST_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_INFO INTO V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_APL_YMD_1,V_PRDN_QTY_1,V_PRDN_QTY2_1,V_PRDN_QTY3_1,V_TH0_POW_TRWI_QTY_1,V_TH0_POS_STRT_YMD_1,V_TH0_POS_FNH_YMD_1,V_TH1_POW_TRWI_QTY_1,V_TH1_POS_STRT_YMDHM_1,V_TH1_POS_FNH_YMDHM_1,V_TH2_POW_TRWI_QTY_1,V_TH2_POS_STRT_YMDHM_1,V_TH2_POS_FNH_YMDHM_1,V_TH3_POW_TRWI_QTY_1,V_TH3_POS_STRT_YMDHM_1,V_TH3_POS_FNH_YMDHM_1,V_TH4_POW_TRWI_QTY_1,V_TH4_POS_STRT_YMDHM_1,V_TH4_POS_FNH_YMDHM_1,V_TH5_POW_TRWI_QTY_1,V_TH5_POS_STRT_YMDHM_1,V_TH5_POS_FNH_YMDHM_1,V_TH6_POW_TRWI_QTY_1,V_TH6_POS_STRT_YMDHM_1,V_TH6_POS_FNH_YMDHM_1,V_TH7_POW_TRWI_QTY_1,V_TH7_POS_STRT_YMDHM_1,V_TH7_POS_FNH_YMDHM_1,V_TH8_POW_TRWI_QTY_1,V_TH8_POS_STRT_YMDHM_1,V_TH8_POS_FNH_YMDHM_1,V_TH9_POW_TRWI_QTY_1,V_TH9_POS_STRT_YMDHM_1,V_TH9_POS_FNH_YMDHM_1,V_TH10_POW_TRWI_QTY_1,V_T10PS1_YMDHM_1,V_TH10_POS_FNH_YMDHM_1,V_TH11_POW_TRWI_QTY_1,V_T11PS1_YMDHM_1,V_TH11_POS_FNH_YMDHM_1,V_TH12_POW_TRWI_QTY_1,V_T12PS1_YMDHM_1,V_TH12_POS_FNH_YMDHM_1,V_TH13_POW_TRWI_QTY_1,V_T13PS1_YMDHM_1,V_TH13_POS_FNH_YMDHM_1,V_TH16_POW_TRWI_QTY_1,V_T16PS1_YMDHM_1,V_TH16_POS_FNH_YMDHM_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

    SET CURR_LOC_NUM = 2;
				UPDATE TB_PROD_MST_SUM_INFO	 
				SET PRDN_QTY = V_PRDN_QTY_1,	 
					PRDN_QTY2 = V_PRDN_QTY2_1,	 
					PRDN_QTY3 = V_PRDN_QTY3_1,	 
					TH0_POW_TRWI_QTY = V_TH0_POW_TRWI_QTY_1,	 
					TH0_POW_STRT_YMD = V_TH0_POS_STRT_YMD_1,	 
					TH0_POW_FNH_YMD = V_TH0_POS_FNH_YMD_1,	 
					TH1_POW_TRWI_QTY = V_TH1_POW_TRWI_QTY_1,	 
					TH1_POW_STRT_YMDHM = V_TH1_POS_STRT_YMDHM_1,	 
					TH1_POW_FNH_YMDHM = V_TH1_POS_FNH_YMDHM_1,	 
					TH2_POW_TRWI_QTY = V_TH2_POW_TRWI_QTY_1,	 
					TH2_POW_STRT_YMDHM = V_TH2_POS_STRT_YMDHM_1,	 
					TH2_POW_FNH_YMDHM = V_TH2_POS_FNH_YMDHM_1,	 
					TH3_POW_TRWI_QTY = V_TH3_POW_TRWI_QTY_1,	 
					TH3_POW_STRT_YMDHM = V_TH3_POS_STRT_YMDHM_1,	 
					TH3_POW_FNH_YMDHM = V_TH3_POS_FNH_YMDHM_1,	 
					TH4_POW_TRWI_QTY = V_TH4_POW_TRWI_QTY_1,	 
					TH4_POW_STRT_YMDHM = V_TH4_POS_STRT_YMDHM_1,	 
					TH4_POW_FNH_YMDHM = V_TH4_POS_FNH_YMDHM_1,	 
					TH5_POW_TRWI_QTY = V_TH5_POW_TRWI_QTY_1,	 
					TH5_POW_STRT_YMDHM = V_TH5_POS_STRT_YMDHM_1,	 
					TH5_POW_FNH_YMDHM = V_TH5_POS_FNH_YMDHM_1,	 
					TH6_POW_TRWI_QTY = V_TH6_POW_TRWI_QTY_1,	 
					TH6_POW_STRT_YMDHM = V_TH6_POS_STRT_YMDHM_1,	 
					TH6_POW_FNH_YMDHM = V_TH6_POS_FNH_YMDHM_1,	 
					TH7_POW_TRWI_QTY = V_TH7_POW_TRWI_QTY_1,	 
					TH7_POW_STRT_YMDHM = V_TH7_POS_STRT_YMDHM_1,	 
					TH7_POW_FNH_YMDHM = V_TH7_POS_FNH_YMDHM_1,	 
					TH8_POW_TRWI_QTY = V_TH8_POW_TRWI_QTY_1,	 
					TH8_POW_STRT_YMDHM = V_TH8_POS_STRT_YMDHM_1,	 
					TH8_POW_FNH_YMDHM = V_TH8_POS_FNH_YMDHM_1,	 
					TH9_POW_TRWI_QTY = V_TH9_POW_TRWI_QTY_1,	 
					TH9_POW_STRT_YMDHM = V_TH9_POS_STRT_YMDHM_1,	 
					TH9_POW_FNH_YMDHM = V_TH9_POS_FNH_YMDHM_1,	 
					TH10_POW_TRWI_QTY = V_TH10_POW_TRWI_QTY_1,	 
					T10PS1_YMDHM = V_T10PS1_YMDHM_1,	 
					TH10_POW_FNH_YMDHM = V_TH10_POS_FNH_YMDHM_1,	 
					TH11_POW_TRWI_QTY = V_TH11_POW_TRWI_QTY_1,	 
					T11PS1_YMDHM = V_T11PS1_YMDHM_1,	 
					TH11_POW_FNH_YMDHM = V_TH11_POS_FNH_YMDHM_1,	 
					TH12_POW_TRWI_QTY = V_TH12_POW_TRWI_QTY_1,	 
					T12PS1_YMDHM = V_T12PS1_YMDHM_1,	 
					TH12_POW_FNH_YMDHM = V_TH12_POS_FNH_YMDHM_1,	 
					TH13_POW_TRWI_QTY = V_TH13_POW_TRWI_QTY_1,	 
					T13PS1_YMDHM = V_T13PS1_YMDHM_1,	 
					TH13_POW_FNH_YMDHM = V_TH13_POS_FNH_YMDHM_1,	
					TH16_POW_TRWI_QTY = V_TH16_POW_TRWI_QTY_1,	 
					T16PS1_YMDHM = V_T16PS1_YMDHM_1,	 
					TH16_POW_FNH_YMDHM = V_TH16_POS_FNH_YMDHM_1,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = V_APL_YMD_1	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
				AND LANG_CD = V_LANG_CD_1;	

    SET CURR_LOC_NUM = 3;
				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PROD_MST_SUM_INFO 
				WHERE APL_YMD = V_APL_YMD_1	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
				AND LANG_CD = V_LANG_CD_1;	


    SET CURR_LOC_NUM = 4;
				IF V_EXCNT = 0 THEN	 
	 
    SET CURR_LOC_NUM = 5;
				   INSERT INTO TB_PROD_MST_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					PRDN_TRWI_QTY,	 
					PRDN_QTY,	 
					TH1_POW_TRWI_QTY,	 
				   	TH1_POW_STRT_YMDHM,	 
					TH1_POW_FNH_YMDHM,	 
					TH2_POW_TRWI_QTY,	 
					TH2_POW_STRT_YMDHM,	 
					TH2_POW_FNH_YMDHM,	 
					TH3_POW_TRWI_QTY,	 
					TH3_POW_STRT_YMDHM,	 
					TH3_POW_FNH_YMDHM,	 
					TH4_POW_TRWI_QTY,	 
					TH4_POW_STRT_YMDHM,	 
					TH4_POW_FNH_YMDHM,	 
					TH5_POW_TRWI_QTY,	 
					TH5_POW_STRT_YMDHM,	 
					TH5_POW_FNH_YMDHM,	 
					TH6_POW_TRWI_QTY,	 
					TH6_POW_STRT_YMDHM,	 
					TH6_POW_FNH_YMDHM,	 
					TH7_POW_TRWI_QTY,	 
					TH7_POW_STRT_YMDHM,	 
					TH7_POW_FNH_YMDHM,	 
					TH8_POW_TRWI_QTY,	 
					TH8_POW_STRT_YMDHM,	 
					TH8_POW_FNH_YMDHM,	 
					TH9_POW_TRWI_QTY,	 
					TH9_POW_STRT_YMDHM,	 
					TH9_POW_FNH_YMDHM,	 
					TH10_POW_TRWI_QTY,	 
					T10PS1_YMDHM,	 
					TH10_POW_FNH_YMDHM,	 
					TH11_POW_TRWI_QTY,	 
					T11PS1_YMDHM,	 
					TH11_POW_FNH_YMDHM,	 
					TH12_POW_TRWI_QTY,	 
					T12PS1_YMDHM,	 
					TH12_POW_FNH_YMDHM,	 
					TH13_POW_TRWI_QTY,	 
					T13PS1_YMDHM,	 
					TH13_POW_FNH_YMDHM,		 
					TH16_POW_TRWI_QTY,	 
					T16PS1_YMDHM,	 
					TH16_POW_FNH_YMDHM,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					TH0_POW_STRT_YMD,	 
					TH0_POW_FNH_YMD,	 
					TH0_POW_TRWI_QTY,	 
					PRDN_QTY2,	 
					PRDN_QTY3	 
				   )	 
				   SELECT V_APL_YMD_1,	 
				          DATA_SN,	 
						  V_QLTY_VEHL_CD_1,	 
						  V_MDL_MDY_CD_1,	 
						  V_LANG_CD_1,	 
						  0,	 
						  V_PRDN_QTY_1,	 
						  V_TH1_POW_TRWI_QTY_1,	 
					      V_TH1_POS_STRT_YMDHM_1,	 
						  V_TH1_POS_FNH_YMDHM_1,	 
						  V_TH2_POW_TRWI_QTY_1,	 
						  V_TH2_POS_STRT_YMDHM_1,	 
						  V_TH2_POS_FNH_YMDHM_1,	 
						  V_TH3_POW_TRWI_QTY_1,	 
						  V_TH3_POS_STRT_YMDHM_1,	 
						  V_TH3_POS_FNH_YMDHM_1,	 
						  V_TH4_POW_TRWI_QTY_1,	 
						  V_TH4_POS_STRT_YMDHM_1,	 
						  V_TH4_POS_FNH_YMDHM_1,	 
						  V_TH5_POW_TRWI_QTY_1,	 
						  V_TH5_POS_STRT_YMDHM_1,	 
						  V_TH5_POS_FNH_YMDHM_1,	 
						  V_TH6_POW_TRWI_QTY_1,	 
						  V_TH6_POS_STRT_YMDHM_1,	 
						  V_TH6_POS_FNH_YMDHM_1,	 
						  V_TH7_POW_TRWI_QTY_1,	 
						  V_TH7_POS_STRT_YMDHM_1,	 
						  V_TH7_POS_FNH_YMDHM_1,	 
						  V_TH8_POW_TRWI_QTY_1,	 
						  V_TH8_POS_STRT_YMDHM_1,	 
						  V_TH8_POS_FNH_YMDHM_1,	 
						  V_TH9_POW_TRWI_QTY_1,	 
						  V_TH9_POS_STRT_YMDHM_1,	 
						  V_TH9_POS_FNH_YMDHM_1,	 
						  V_TH10_POW_TRWI_QTY_1,	 
						  V_T10PS1_YMDHM_1,	 
						  V_TH10_POS_FNH_YMDHM_1,	 
						  V_TH11_POW_TRWI_QTY_1,	 
						  V_T11PS1_YMDHM_1,	 
						  V_TH11_POS_FNH_YMDHM_1,	 
						  V_TH12_POW_TRWI_QTY_1,	 
						  V_T12PS1_YMDHM_1,	 
						  V_TH12_POS_FNH_YMDHM_1,	 
						  V_TH13_POW_TRWI_QTY_1,	 
						  V_T13PS1_YMDHM_1,	 
						  V_TH13_POS_FNH_YMDHM_1,
						  V_TH16_POW_TRWI_QTY_1,	 
						  V_T16PS1_YMDHM_1,	 
						  V_TH16_POS_FNH_YMDHM_1,	 
						  SYSDATE(),	 
						  SYSDATE(),	 
						  V_TH0_POS_STRT_YMD_1,	 
						  V_TH0_POS_FNH_YMD_1,	 
						  V_TH0_POW_TRWI_QTY_1,	 
						  V_PRDN_QTY2_1,	 
						  V_PRDN_QTY3_1	 
				   FROM TB_LANG_MGMT A	 
				   WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
				   AND A.MDL_MDY_CD = V_MDL_MDY_CD_1	 
				   AND A.LANG_CD = V_LANG_CD_1;	 
	 
    SET CURR_LOC_NUM = 6;
				END IF;	 

    SET CURR_LOC_NUM = 7;
	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_INFO;


    SET CURR_LOC_NUM = 8;

	OPEN PLNT_MST_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_MST_INFO INTO V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_APL_YMD_2,V_PRDN_QTY_2,V_PRDN_QTY2_2,V_PRDN_QTY3_2,V_TH0_POW_TRWI_QTY_2,V_TH0_POS_STRT_YMD_2,V_TH0_POS_FNH_YMD_2,V_TH1_POW_TRWI_QTY_2,V_TH1_POS_STRT_YMDHM_2,V_TH1_POS_FNH_YMDHM_2,V_TH2_POW_TRWI_QTY_2,V_TH2_POS_STRT_YMDHM_2,V_TH2_POS_FNH_YMDHM_2,V_TH3_POW_TRWI_QTY_2,V_TH3_POS_STRT_YMDHM_2,V_TH3_POS_FNH_YMDHM_2,V_TH4_POW_TRWI_QTY_2,V_TH4_POS_STRT_YMDHM_2,V_TH4_POS_FNH_YMDHM_2,V_TH5_POW_TRWI_QTY_2,V_TH5_POS_STRT_YMDHM_2,V_TH5_POS_FNH_YMDHM_2,V_TH6_POW_TRWI_QTY_2,V_TH6_POS_STRT_YMDHM_2,V_TH6_POS_FNH_YMDHM_2,V_TH7_POW_TRWI_QTY_2,V_TH7_POS_STRT_YMDHM_2,V_TH7_POS_FNH_YMDHM_2,V_TH8_POW_TRWI_QTY_2,V_TH8_POS_STRT_YMDHM_2,V_TH8_POS_FNH_YMDHM_2,V_TH9_POW_TRWI_QTY_2,V_TH9_POS_STRT_YMDHM_2,V_TH9_POS_FNH_YMDHM_2,V_TH10_POW_TRWI_QTY_2,V_T10PS1_YMDHM_2,V_TH10_POS_FNH_YMDHM_2,V_TH11_POW_TRWI_QTY_2,V_T11PS1_YMDHM_2,V_TH11_POS_FNH_YMDHM_2,V_TH12_POW_TRWI_QTY_2,V_T12PS1_YMDHM_2,V_TH12_POS_FNH_YMDHM_2,V_TH13_POW_TRWI_QTY_2,V_T13PS1_YMDHM_2,V_TH13_POS_FNH_YMDHM_2,V_TH16_POW_TRWI_QTY_2,V_T16PS1_YMDHM_2,V_TH16_POS_FNH_YMDHM_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

    SET CURR_LOC_NUM = 9;
				UPDATE TB_PLNT_PROD_MST_SUM_INFO	 
				SET PRDN_QTY = PLNT_LIST.PRDN_QTY_2,	 
					PRDN_QTY2 = PLNT_LIST.PRDN_QTY2_2,	 
					PRDN_QTY3 = PLNT_LIST.PRDN_QTY3_2,	 
					TH0_POW_TRWI_QTY = PLNT_LIST.TH0_POW_TRWI_QTY_2,	 
					TH0_POW_STRT_YMD = PLNT_LIST.TH0_POS_STRT_YMD_2,	 
					TH0_POW_FNH_YMD = PLNT_LIST.TH0_POS_FNH_YMD_2,	 
					TH1_POW_TRWI_QTY = PLNT_LIST.TH1_POW_TRWI_QTY_2,	 
					TH1_POW_STRT_YMDHM = PLNT_LIST.TH1_POS_STRT_YMDHM_2,	 
					TH1_POW_FNH_YMDHM = PLNT_LIST.TH1_POS_FNH_YMDHM_2,	 
					TH2_POW_TRWI_QTY = PLNT_LIST.TH2_POW_TRWI_QTY_2,	 
					TH2_POW_STRT_YMDHM = PLNT_LIST.TH2_POS_STRT_YMDHM_2,	 
					TH2_POW_FNH_YMDHM = PLNT_LIST.TH2_POS_FNH_YMDHM_2,	 
					TH3_POW_TRWI_QTY = PLNT_LIST.TH3_POW_TRWI_QTY_2,	 
					TH3_POW_STRT_YMDHM = PLNT_LIST.TH3_POS_STRT_YMDHM_2,	 
					TH3_POW_FNH_YMDHM = PLNT_LIST.TH3_POS_FNH_YMDHM_2,	 
					TH4_POW_TRWI_QTY = PLNT_LIST.TH4_POW_TRWI_QTY_2,	 
					TH4_POW_STRT_YMDHM = PLNT_LIST.TH4_POS_STRT_YMDHM_2,	 
					TH4_POW_FNH_YMDHM = PLNT_LIST.TH4_POS_FNH_YMDHM_2,	 
					TH5_POW_TRWI_QTY = PLNT_LIST.TH5_POW_TRWI_QTY_2,	 
					TH5_POW_STRT_YMDHM = PLNT_LIST.TH5_POS_STRT_YMDHM_2,	 
					TH5_POW_FNH_YMDHM = PLNT_LIST.TH5_POS_FNH_YMDHM_2,	 
					TH6_POW_TRWI_QTY = PLNT_LIST.TH6_POW_TRWI_QTY_2,	 
					TH6_POW_STRT_YMDHM = PLNT_LIST.TH6_POS_STRT_YMDHM_2,	 
					TH6_POW_FNH_YMDHM = PLNT_LIST.TH6_POS_FNH_YMDHM_2,	 
					TH7_POW_TRWI_QTY = PLNT_LIST.TH7_POW_TRWI_QTY_2,	 
					TH7_POW_STRT_YMDHM = PLNT_LIST.TH7_POS_STRT_YMDHM_2,	 
					TH7_POW_FNH_YMDHM = PLNT_LIST.TH7_POS_FNH_YMDHM_2,	 
					TH8_POW_TRWI_QTY = PLNT_LIST.TH8_POW_TRWI_QTY_2,	 
					TH8_POW_STRT_YMDHM = PLNT_LIST.TH8_POS_STRT_YMDHM_2,	 
					TH8_POW_FNH_YMDHM = PLNT_LIST.TH8_POS_FNH_YMDHM_2,	 
					TH9_POW_TRWI_QTY = PLNT_LIST.TH9_POW_TRWI_QTY_2,	 
					TH9_POW_STRT_YMDHM = PLNT_LIST.TH9_POS_STRT_YMDHM_2,	 
					TH9_POW_FNH_YMDHM = PLNT_LIST.TH9_POS_FNH_YMDHM_2,	 
					TH10_POW_TRWI_QTY = PLNT_LIST.TH10_POW_TRWI_QTY_2,	 
					T10PS1_YMDHM = PLNT_LIST.T10PS1_YMDHM_2,	 
					TH10_POW_FNH_YMDHM = PLNT_LIST.TH10_POS_FNH_YMDHM_2,	 
					TH11_POW_TRWI_QTY = PLNT_LIST.TH11_POW_TRWI_QTY_2,	 
					T11PS1_YMDHM = PLNT_LIST.T11PS1_YMDHM_2,	 
					TH11_POW_FNH_YMDHM = PLNT_LIST.TH11_POS_FNH_YMDHM_2,	 
					TH12_POW_TRWI_QTY = PLNT_LIST.TH12_POW_TRWI_QTY_2,	 
					T12PS1_YMDHM = PLNT_LIST.T12PS1_YMDHM_2,	 
					TH12_POW_FNH_YMDHM = PLNT_LIST.TH12_POS_FNH_YMDHM_2,	 
					TH13_POW_TRWI_QTY = PLNT_LIST.TH13_POW_TRWI_QTY_2,	 
					T13PS1_YMDHM = PLNT_LIST.T13PS1_YMDHM_2,	 
					TH13_POW_FNH_YMDHM = PLNT_LIST.TH13_POS_FNH_YMDHM_2,
					TH16_POW_TRWI_QTY = PLNT_LIST.TH16_POW_TRWI_QTY_2,	 
					T16PS1_YMDHM = PLNT_LIST.T16PS1_YMDHM_2,	 
					TH16_POW_FNH_YMDHM = PLNT_LIST.TH16_POS_FNH_YMDHM_2,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = PLNT_LIST.APL_YMD_2	 
				AND QLTY_VEHL_CD = PLNT_LIST.QLTY_VEHL_CD_2	 
				AND MDL_MDY_CD = PLNT_LIST.MDL_MDY_CD_2	 
				AND LANG_CD = PLNT_LIST.LANG_CD_2	 
				AND PRDN_PLNT_CD = PLNT_LIST.PRDN_PLNT_CD_2;

    SET CURR_LOC_NUM = 10;
				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PLNT_PROD_MST_SUM_INFO
				WHERE APL_YMD = PLNT_LIST.APL_YMD_2	 
				AND QLTY_VEHL_CD = PLNT_LIST.QLTY_VEHL_CD_2	 
				AND MDL_MDY_CD = PLNT_LIST.MDL_MDY_CD_2	 
				AND LANG_CD = PLNT_LIST.LANG_CD_2	 
				AND PRDN_PLNT_CD = PLNT_LIST.PRDN_PLNT_CD_2;

    SET CURR_LOC_NUM = 11;
				IF V_EXCNT = 0 THEN	 
	 
    SET CURR_LOC_NUM = 12;
				   INSERT INTO TB_PLNT_PROD_MST_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					PRDN_TRWI_QTY,	 
					PRDN_QTY,	 
					TH1_POW_TRWI_QTY,	 
				   	TH1_POW_STRT_YMDHM,	 
					TH1_POW_FNH_YMDHM,	 
					TH2_POW_TRWI_QTY,	 
					TH2_POW_STRT_YMDHM,	 
					TH2_POW_FNH_YMDHM,	 
					TH3_POW_TRWI_QTY,	 
					TH3_POW_STRT_YMDHM,	 
					TH3_POW_FNH_YMDHM,	 
					TH4_POW_TRWI_QTY,	 
					TH4_POW_STRT_YMDHM,	 
					TH4_POW_FNH_YMDHM,	 
					TH5_POW_TRWI_QTY,	 
					TH5_POW_STRT_YMDHM,	 
					TH5_POW_FNH_YMDHM,	 
					TH6_POW_TRWI_QTY,	 
					TH6_POW_STRT_YMDHM,	 
					TH6_POW_FNH_YMDHM,	 
					TH7_POW_TRWI_QTY,	 
					TH7_POW_STRT_YMDHM,	 
					TH7_POW_FNH_YMDHM,	 
					TH8_POW_TRWI_QTY,	 
					TH8_POW_STRT_YMDHM,	 
					TH8_POW_FNH_YMDHM,	 
					TH9_POW_TRWI_QTY,	 
					TH9_POW_STRT_YMDHM,	 
					TH9_POW_FNH_YMDHM,	 
					TH10_POW_TRWI_QTY,	 
					T10PS1_YMDHM,	 
					TH10_POW_FNH_YMDHM,	 
					TH11_POW_TRWI_QTY,	 
					T11PS1_YMDHM,	 
					TH11_POW_FNH_YMDHM,	 
					TH12_POW_TRWI_QTY,	 
					T12PS1_YMDHM,	 
					TH12_POW_FNH_YMDHM,	 
					TH13_POW_TRWI_QTY,	 
					T13PS1_YMDHM,	 
					TH13_POW_FNH_YMDHM,
					TH16_POW_TRWI_QTY,	 
					T16PS1_YMDHM,	 
					TH16_POW_FNH_YMDHM,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					TH0_POW_STRT_YMD,	 
					TH0_POW_FNH_YMD,	 
					TH0_POW_TRWI_QTY,	 
					PRDN_QTY2,	 
					PRDN_QTY3,	 
					PRDN_PLNT_CD	 
				   )	 
				   SELECT PLNT_LIST.APL_YMD_2,	 
				          DATA_SN,	 
						  PLNT_LIST.QLTY_VEHL_CD_2,	 
						  PLNT_LIST.MDL_MDY_CD_2,	 
						  PLNT_LIST.LANG_CD_2,	 
						  0,	 
						  PLNT_LIST.PRDN_QTY_2,	 
						  PLNT_LIST.TH1_POW_TRWI_QTY_2,	 
					      PLNT_LIST.TH1_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH1_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH2_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH2_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH2_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH3_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH3_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH3_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH4_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH4_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH4_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH5_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH5_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH5_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH6_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH6_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH6_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH7_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH7_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH7_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH8_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH8_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH8_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH9_POW_TRWI_QTY_2,	 
						  PLNT_LIST.TH9_POS_STRT_YMDHM_2,	 
						  PLNT_LIST.TH9_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH10_POW_TRWI_QTY_2,	 
						  PLNT_LIST.T10PS1_YMDHM_2,	 
						  PLNT_LIST.TH10_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH11_POW_TRWI_QTY_2,	 
						  PLNT_LIST.T11PS1_YMDHM_2,	 
						  PLNT_LIST.TH11_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH12_POW_TRWI_QTY_2,	 
						  PLNT_LIST.T12PS1_YMDHM_2,	 
						  PLNT_LIST.TH12_POS_FNH_YMDHM_2,	 
						  PLNT_LIST.TH13_POW_TRWI_QTY_2,	 
						  PLNT_LIST.T13PS1_YMDHM_2,	 
						  PLNT_LIST.TH13_POS_FNH_YMDHM_2,
						  PLNT_LIST.TH16_POW_TRWI_QTY_2,	 
						  PLNT_LIST.T16PS1_YMDHM_2,	 
						  PLNT_LIST.TH16_POS_FNH_YMDHM_2,	 
						  SYSDATE(),	 
						  SYSDATE(),	 
						  PLNT_LIST.TH0_POS_STRT_YMD_2,	 
						  PLNT_LIST.TH0_POS_FNH_YMD_2,	 
						  PLNT_LIST.TH0_POW_TRWI_QTY_2,	 
						  PLNT_LIST.PRDN_QTY2_2,	 
						  PLNT_LIST.PRDN_QTY3_2,	 
						  PLNT_LIST.PRDN_PLNT_CD_2	 
				   FROM TB_LANG_MGMT A	 
				   WHERE A.QLTY_VEHL_CD = PLNT_LIST.QLTY_VEHL_CD_2	 
				   AND A.MDL_MDY_CD = PLNT_LIST.MDL_MDY_CD_2	 
				   AND A.LANG_CD = PLNT_LIST.LANG_CD_2;
    SET CURR_LOC_NUM = 13;
				END IF;	 

    SET CURR_LOC_NUM = 14;
	END LOOP JOBLOOP2 ;
	CLOSE PLNT_MST_INFO;


    SET CURR_LOC_NUM = 15;

	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;
	    

    SET CURR_LOC_NUM = 16;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_SUM2_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_SUM2_HMC`(IN FROM_YMD VARCHAR(8),
                                        IN TO_YMD VARCHAR(8),
                                        IN P_APL_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_SUM2_HMC
 * Procedure 설명 : 국가미지정 정보조회
 *                 오더별생산내역 조회(현재는 날짜별로 오더에 관계된 생산된 데이터 전체를 무조건 처리해 준다.그리고 국가/언어가 제대로 설정된 데이터만 가져오도록 한다.(OUTER JOIN 필요없음)
 *                 공통차종 오더내역 조회
 *                 생산마스터내역 조회(PDI 공통차종 오더내역 조회 부분 포함)
 *                 생산정보 현황 - 공장별 내역 조회
 *                 적용 기간동안의 미지정내역을 삭제한 뒤 작업을 진행한다.
 *                 [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된 내역만을 삭제해 주어야 한다.
 * 입력 파라미터    :  FROM_YMD               시작년월일
 *                 TO_YMD                 종료년월일
 *                 P_APL_YMD              적용년월일
 *                 EXPD_CO_CD             회사코드 01
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_YMD				VARCHAR(8);
	DECLARE V_DATE_CNT				INT;
	DECLARE V_CNT					INT;
	DECLARE V_FROM_DATE				DATETIME;
	DECLARE V_TO_DATE				DATETIME;
	DECLARE V_CURR_DATE				DATETIME;
	DECLARE i						INT;	   			
	DECLARE V_PREV_WHOT_QTY	        INT;
	DECLARE V_TRWI_DIFF	            INT;
	DECLARE EXPD_DOM_NAT_CD			VARCHAR(5);  /* 내수 국가코드 A99VA */
	
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_EXPD_NAT_CD_1 VARCHAR(5);
	DECLARE V_APL_YMD_1 VARCHAR(8);
	DECLARE V_PRDN_QTY_1 INT;
	DECLARE V_TRWI_QTY_1 INT;
	DECLARE V_PRDN_QTY2_1 INT;

	DECLARE V_QLTY_VEHL_CD_2 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2 VARCHAR(4);
	DECLARE V_LANG_CD_2 VARCHAR(3);
	DECLARE V_APL_YMD_2 VARCHAR(8);
	DECLARE V_MO_PACK_CD_2 VARCHAR(4);
	DECLARE V_TRWI_QTY_2 INT;
	DECLARE V_PRDN_PLNT_CD_2 VARCHAR(3);	
					   
	DECLARE V_QLTY_VEHL_CD_3 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_3 VARCHAR(4);
	DECLARE V_LANG_CD_3 VARCHAR(3);
	DECLARE V_APL_YMD_3 VARCHAR(8);
	DECLARE V_TRWI_QTY_3 INT;
	DECLARE V_PRDN_PLNT_CD_3 VARCHAR(3);

	DECLARE V_QLTY_VEHL_CD_4 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_4 VARCHAR(4);
	DECLARE V_LANG_CD_4 VARCHAR(3);
	DECLARE V_APL_YMD_4 VARCHAR(8);
	DECLARE V_TRWI_QTY_4 INT;
	DECLARE V_PRDN_PLNT_CD_4 VARCHAR(3);
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow3 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow4 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PROD_MST_NOAPIM_INFO CURSOR FOR
		 /*국가미지정 정보를 가져오는 부분 */
										WITH AAA AS (
										SELECT K.QLTY_VEHL_CD,
												SUBSTR(K.MDL_MDY_CD, 1,4) AS MDL_MDY_CD,			
												K.EXPD_NAT_CD,
												K.APL_YMD,
												CASE WHEN K.PAC_SCN_CD = '01' THEN K.PRDN_PAS_QTY  /* 승용 생산수량*/
												ELSE K.PRDN_COM_QTY                         /* 상용 생산수량*/
												END AS PRDN_QTY,
												CASE WHEN K.PAC_SCN_CD = '01' THEN K.TRWI_PAS_QTY  /* 승용 투입수량*/
												ELSE K.TRWI_COM_QTY                         /* 상용 투입수량*/
												END AS TRWI_QTY,
												CASE WHEN K.PAC_SCN_CD = '01' THEN K.PRDN_PAS_QTY2  /* 승용 생산수량2*/
												ELSE K.PRDN_COM_QTY2                         /* 상용 생산수량2*/
												END AS PRDN_QTY2
										FROM (SELECT A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.EXPD_NAT_CD,
													A.APL_YMD,
													(SELECT MAX(DL_EXPD_PAC_SCN_CD)	FROM TB_VEHL_MGMT WHERE QLTY_VEHL_CD = A.QLTY_VEHL_CD AND MDL_MDY_CD = A.MDL_MDY_CD) AS PAC_SCN_CD,
													SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY /* 글로비스 생산수량*/
													ELSE A.PRDN_PAS_QTY                     /* 승용 생산수량*/
													END											            ) AS PRDN_PAS_QTY,
													SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY /* 글로비스 생산수량*/
													ELSE A.PRDN_COM_QTY                     /* 상용 생산수량*/
													END											            ) AS PRDN_COM_QTY,
													SUM(CASE WHEN A.USF_CD = 'D' THEN A.TRWI_DOM_QTY /* 글로비스 투입수량*/
													ELSE A.TRWI_PAS_QTY                     /* 승용 투입수량*/
													END											            ) AS TRWI_PAS_QTY,
													SUM(CASE WHEN A.USF_CD = 'D' THEN A.TRWI_DOM_QTY /* 글로비스 투입수량*/
													ELSE A.TRWI_COM_QTY                     /* 상용 투입수량*/
													END											            ) AS TRWI_COM_QTY,
													SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY2 /* 글로비스 생산수량*/
													ELSE A.PRDN_PAS_QTY2                     /* 승용 생산수량*/
													END											            ) AS PRDN_PAS_QTY2,
													SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY2 /* 글로비스 생산수량*/
													ELSE A.PRDN_COM_QTY2                     /* 상용 생산수량*/
													END											            ) AS PRDN_COM_QTY2
												FROM (
												/*미지정 국가 항목의 경우에는 투입일 기준이 아닌 적용일 기준으로 계산해 주도록 한다. */
														SELECT B.QLTY_VEHL_CD,
																/*A.MDL_MDY_CD, tibero CONCAT(DISTINCT TRIM(C.MDL_MDY_CD),',') AS MDL_MDY_CD  */ 
																TRIM(C.MDL_MDY_CD) AS MDL_MDY_CD,/*AGGR_CONCAT(DISTINCT TRIM(C.MDL_MDY_CD),',') AS MDL_MDY_CD,*/
																(SELECT MAX(DL_EXPD_NAT_CD)	FROM TB_NATL_MGMT
																		WHERE DL_EXPD_CO_CD = EXPD_CO_CD AND (DL_EXPD_NAT_CD = A.DEST_NAT_CD OR DL_EXPD_NAT_CD = SUBSTR(A.DEST_NAT_CD, 1, 3))) AS DL_EXPD_NAT_CD,
																A.DEST_NAT_CD AS EXPD_NAT_CD,
																A.TRWI_YMD AS APL_YMD,
																MAX(A.USF_CD) AS USF_CD, /* D:내수, E:수출 */
																SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD < '10' THEN 1 ELSE 0 END) AS PRDN_PAS_QTY,  /*승용 생산수량*/
																SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD < '11' THEN 1 ELSE 0 END) AS PRDN_COM_QTY,  /*상용 생산수량*/
																SUM(CASE WHEN A.USF_CD = 'D' AND A.POW_LOC_CD < '16' THEN 1 ELSE 0 END) AS PRDN_DOM_QTY,  /*내수 생산수량*/
																SUM(CASE WHEN A.USF_CD = 'E' AND A.TRWI_USED_YN = 'N' AND A.POW_LOC_CD >= '10' THEN 1 ELSE 0 END) AS TRWI_PAS_QTY,  /*승용 투입수량*/
																SUM(CASE WHEN A.USF_CD = 'E' AND A.TRWI_USED_YN = 'N' AND A.POW_LOC_CD >= '11' THEN 1 ELSE 0 END) AS TRWI_COM_QTY,  /*상용 투입수량*/
																SUM(CASE WHEN A.USF_CD = 'D' AND A.TRWI_USED_YN = 'N' AND A.POW_LOC_CD >= '16' THEN 1 ELSE 0 END) AS TRWI_DOM_QTY,  /*내수 투입수량*/
																SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD >= '08' AND A.POW_LOC_CD < '10' THEN 1 ELSE 0 END) AS PRDN_PAS_QTY2,  /*승용 생산수량2*/
																SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD >= '08' AND A.POW_LOC_CD < '11' THEN 1 ELSE 0 END) AS PRDN_COM_QTY2,  /*상용 생산수량2*/
																SUM(CASE WHEN A.USF_CD = 'D' AND A.POW_LOC_CD >= '08' AND A.POW_LOC_CD < '16' THEN 1 ELSE 0 END) AS PRDN_DOM_QTY2   /*내수 생산수량2*/
														FROM TB_PROD_MST_INFO A 
														LEFT JOIN TB_ALTN_VEHL_MGMT B ON (A.PRDN_MST_VEHL_CD = B.PRDN_VEHL_CD)
														INNER JOIN TB_PROD_MST_INFO_ERP_HMC C ON (A.BN_SN = C.BN_SN AND A.TRWI_YMD = C.APL_YMD)
														WHERE A.DL_EXPD_CO_CD = EXPD_CO_CD
														AND A.TRWI_YMD  = P_APL_YMD
														AND B.PRVS_SCN_CD = 'B'
														AND A.MDL_MDY_CD IS NULL
														GROUP BY B.QLTY_VEHL_CD,
																C.MDL_MDY_CD,
																A.DEST_NAT_CD,
																A.TRWI_YMD
												) A
										WHERE DL_EXPD_NAT_CD IS NOT NULL 
										/* 내수인 경우와 미투입 대리점 리스트에 해당하는 경우는 제외*/
										AND EXPD_NAT_CD <> EXPD_DOM_NAT_CD  /* 'A99VA' */
										AND EXPD_NAT_CD NOT IN (SELECT DYTM_PLN_NAT_CD FROM TB_ALTN_WIOUT_NATL_MGMT)
										/* 언어가 등록되어 있지 않은 국가는 제외*/
										AND SUBSTR(EXPD_NAT_CD,1,3) IN (SELECT DL_EXPD_NAT_CD FROM TB_NATL_LANG_MGMT WHERE DL_EXPD_CO_CD = '01')
										GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.APL_YMD, A.EXPD_NAT_CD 
										) K )
										SELECT V.QLTY_VEHL_CD,
													V.MDL_MDY_CD,			
													V.EXPD_NAT_CD,
													V.APL_YMD,
													V.PRDN_QTY,
													V.TRWI_QTY,
													V.PRDN_QTY2
										FROM (
												SELECT QLTY_VEHL_CD,
													MDL_MDY_CD,			
													EXPD_NAT_CD,
													APL_YMD,
													PRDN_QTY,
													TRWI_QTY,
													PRDN_QTY2,
													CASE 	WHEN MDL_MDY_CD = '1' THEN '01'
															WHEN MDL_MDY_CD = '2' THEN '02'
															WHEN MDL_MDY_CD = '3' THEN '03'
															WHEN MDL_MDY_CD = '4' THEN '04'
															WHEN MDL_MDY_CD = '5' THEN '05'
															WHEN MDL_MDY_CD = '6' THEN '06'
															WHEN MDL_MDY_CD = '7' THEN '07'
															WHEN MDL_MDY_CD = '8' THEN '08'
															WHEN MDL_MDY_CD = '9' THEN '09'
															WHEN MDL_MDY_CD = 'A' THEN '10'
															WHEN MDL_MDY_CD = 'B' THEN '11'
															WHEN MDL_MDY_CD = 'C' THEN '12'
															WHEN MDL_MDY_CD = 'D' THEN '13'
															WHEN MDL_MDY_CD = 'E' THEN '14'
															WHEN MDL_MDY_CD = 'F' THEN '15'
															WHEN MDL_MDY_CD = 'G' THEN '16'
															WHEN MDL_MDY_CD = 'H' THEN '17'
															WHEN MDL_MDY_CD = 'J' THEN '18'
															WHEN MDL_MDY_CD = 'K' THEN '19'
															WHEN MDL_MDY_CD = 'M' THEN '20'
															WHEN MDL_MDY_CD = 'N' THEN '21'
															WHEN MDL_MDY_CD = 'O' THEN '22' 
															WHEN MDL_MDY_CD = 'P' THEN '23'
															WHEN MDL_MDY_CD = 'Q' THEN '24'
															WHEN MDL_MDY_CD = 'R' THEN '25'
															WHEN MDL_MDY_CD = 'S' THEN '26'
															WHEN MDL_MDY_CD = 'T' THEN '27'
															WHEN MDL_MDY_CD = 'U' THEN '28'
															WHEN MDL_MDY_CD = 'V' THEN '29'
															WHEN MDL_MDY_CD = 'W' THEN '30'
															WHEN MDL_MDY_CD = 'X' THEN '31'
															WHEN MDL_MDY_CD = 'Y' THEN '32'
															WHEN MDL_MDY_CD = 'Z' THEN '33'
															ELSE 'XX'  END AS MDL_MDY_NUM  /* 영문자 I, L은 숫자 1과 혼동 될 수 있으므로 제외함*/
												FROM AAA
												) V
										WHERE ( V.QLTY_VEHL_CD, V.MDL_MDY_NUM ) NOT IN ( SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD FROM TB_VEHL_MDY_MGMT)
										ORDER BY V.QLTY_VEHL_CD, V.MDL_MDY_CD, V.EXPD_NAT_CD;

	DECLARE PROD_ODR_INFO CURSOR FOR
		 /*오더별생산내역 조회를 위한 부분 
		   (현재는 날짜별로 오더에 관계된 생산된 데이터 전체를 무조건 처리해 준다.
		    그리고 국가/언어가 제대로 설정된 데이터만 가져오도록 한다.(OUTER JOIN 필요없음) 
		   [변경] 2009.07.23 PDI 공통차종 오더내역 조회 부분 포함		*/
                WITH T AS	 
                (	 
                SELECT A.QLTY_VEHL_CD,	 
                       A.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       A.MO_PACK_CD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 
                  FROM (	 
                        SELECT QLTY_VEHL_CD,	 
                               MDL_MDY_CD,	 
                               DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
                               APL_YMD,	 
                               MO_PACK_CD,	 
                               COUNT(*) AS TRWI_QTY,
                               CASE WHEN QLTY_VEHL_CD = 'AM' THEN IFNULL(PRDN_PLNT_CD,'N')
                                    WHEN QLTY_VEHL_CD = 'PS' THEN IFNULL(PRDN_PLNT_CD,'N')
                                    WHEN QLTY_VEHL_CD = 'SK3' THEN IFNULL(PRDN_PLNT_CD,'N')
                                    ELSE 'N' END AS PRDN_PLNT_CD
                               /* QL 때문에 AM, PS 만 공장코드 부여	 */
                          FROM TB_PROD_MST_TRWI_INFO	 
                         WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
                           AND APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
                           AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
                           AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
                           AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
                         GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, DL_EXPD_NAT_CD, APL_YMD, MO_PACK_CD, PRDN_PLNT_CD	 
                       ) A,	 
                       TB_NATL_LANG_MGMT B	 
                 WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
                   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
                   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                 GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.MO_PACK_CD, A.PRDN_PLNT_CD	 
                )
                SELECT QLTY_VEHL_CD,	 
                       MDL_MDY_CD,	 
                       LANG_CD,	 
                       APL_YMD,	 
                       MO_PACK_CD,	 
                       TRWI_QTY,	 
                       PRDN_PLNT_CD	 
                  FROM T	 
	 
                 UNION ALL	 
	 
                SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
                       B.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       A.MO_PACK_CD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 
                  FROM T A,	 
                       TB_PDI_COM_VEHL_MGMT B	 
                 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                   AND A.LANG_CD = B.LANG_CD	 
                 GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD, A.MO_PACK_CD , A.PRDN_PLNT_CD;

	DECLARE PROD_MST_INFO CURSOR FOR
		 /*생산마스터내역 조회를 위한 부분 
		   (PDI 공통차종 오더내역 조회 부분 포함) 	*/		
                WITH T AS	 
                (	 
                SELECT A.QLTY_VEHL_CD,	 
                       A.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 		 
                  FROM (	 
                        SELECT QLTY_VEHL_CD,	 
                               MDL_MDY_CD,	 
                               DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
                               APL_YMD,	 
                               COUNT(*) AS TRWI_QTY	 
                               ,CASE WHEN QLTY_VEHL_CD IN ('AM', 'PS', 'SK3') THEN IFNULL(PRDN_PLNT_CD,'N') ELSE 'N' END AS PRDN_PLNT_CD	 
                          FROM TB_PROD_MST_TRWI_INFO	 
                         WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
                           AND APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
                           AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	*/
                           AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
                           AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
                         GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, DL_EXPD_NAT_CD, APL_YMD, PRDN_PLNT_CD	 
                        ) A,	 
                       TB_NATL_LANG_MGMT B
                 WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
                   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
                   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                 GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.PRDN_PLNT_CD	 
                   /*재고 수불 기준이 이전연식부터 처리되어야 하기 때문에	 
                     ORDER BY 의 순서를 아래와 같이 준수하여야 한다.	 */
                 ORDER BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD
                )	 
                SELECT QLTY_VEHL_CD,	 
                       MDL_MDY_CD,	 
                       LANG_CD,	 
                       APL_YMD,	 
                       TRWI_QTY,	 
                       PRDN_PLNT_CD	 
                  FROM T	 
	 
                 UNION ALL	 
	 
                SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
                       B.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 
                  FROM T A,	 
                       TB_PDI_COM_VEHL_MGMT B	 
                 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                   AND A.LANG_CD = B.LANG_CD	 
                 GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD , A.PRDN_PLNT_CD;

	DECLARE PLNT_PROD_MST_INFO CURSOR FOR
		/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 조회 */
		 					  	                WITH T AS (SELECT A.QLTY_VEHL_CD,	 
		 					  	 		   		       A.MDL_MDY_CD,	 
												       B.LANG_CD,	 
												       A.APL_YMD,	 
													   A.PRDN_PLNT_CD,	 
												       SUM(A.TRWI_QTY) AS TRWI_QTY	 
		 					  	                FROM (SELECT A.QLTY_VEHL_CD,	 
								 	  		  	 		     A.MDL_MDY_CD,	 
											  			     A.DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											  			     A.APL_YMD,	 
															 B.PRDN_PLNT_CD,	 
															 MAX(B.SORT_SN) AS SORT_SN,	 
											  			     COUNT(*) AS TRWI_QTY	 
									                  FROM TB_PROD_MST_TRWI_INFO A,	 
												           TB_PLNT_VEHL_MGMT B	 
									   			      WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
									   			      AND APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
												      AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
												      AND IFNULL(A.PRDN_PLNT_CD,'N') = B.PRDN_PLNT_CD	 
									   			      AND A.QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	*/
									   			      AND A.MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
									   			      AND A.DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
									   			      GROUP BY A.QLTY_VEHL_CD,	 
									  		      		       A.MDL_MDY_CD,	 
														       A.DL_EXPD_NAT_CD,	 
														       A.APL_YMD,	 
															   B.PRDN_PLNT_CD	 
								                     ) A,	 
									  			     TB_NATL_LANG_MGMT B  
								                WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
								 		        AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
								 		        AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 		        AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 		        GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.PRDN_PLNT_CD	 
								 		        /*재고 수불 기준이 이전연식부터 처리되어야 하기 때문에	 
								 		          ORDER BY 의 순서를 아래와 같이 준수하여야 한다.	 */
								 		        ORDER BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, MAX(A.SORT_SN)	 
		 					  	 	           )	 
								     SELECT QLTY_VEHL_CD,	 
								 	        MDL_MDY_CD,	 
									        LANG_CD,	 
									        APL_YMD,	 
											PRDN_PLNT_CD,	 
									        TRWI_QTY	 
								     FROM T	 
	 
								     UNION ALL	 
	 
								     SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								            B.MDL_MDY_CD,	 
									        B.LANG_CD,	 
									        A.APL_YMD,	 
											A.PRDN_PLNT_CD,	 
									        SUM(A.TRWI_QTY) AS TRWI_QTY	 
								     FROM T A,	 
								          TB_PDI_COM_VEHL_MGMT B	 
								     WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								     AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								     AND A.LANG_CD = B.LANG_CD	 
								     GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD, A.PRDN_PLNT_CD;	

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE, endOfRow3 =TRUE, endOfRow4 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_SUM2_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',FROM_YMD:',IFNULL(FROM_YMD,'')
							,',TO_YMD:',IFNULL(TO_YMD,'')
							,',P_APL_YMD:',IFNULL(P_APL_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',V_DATE_CNT:',IFNULL(CONCAT(V_DATE_CNT),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_FROM_DATE:',IFNULL(DATE_FORMAT(V_FROM_DATE, '%Y%m%d'),'')
							,',V_TO_DATE:',IFNULL(DATE_FORMAT(V_TO_DATE, '%Y%m%d'),'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',i:',IFNULL(CONCAT(i),'')   	
							,',V_PREV_WHOT_QTY:',IFNULL(CONCAT(V_PREV_WHOT_QTY),'')
							,',V_TRWI_DIFF:',IFNULL(CONCAT(V_TRWI_DIFF),'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_EXPD_NAT_CD_1:',IFNULL(V_EXPD_NAT_CD_1,'')
							,',V_APL_YMD_1:',IFNULL(V_APL_YMD_1,'')
							,',V_PRDN_QTY_1:',IFNULL(CONCAT(V_PRDN_QTY_1),'')
							,',V_TRWI_QTY_1:',IFNULL(CONCAT(V_TRWI_QTY_1),'')
							,',V_PRDN_QTY2_1:',IFNULL(CONCAT(V_PRDN_QTY2_1),'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_APL_YMD_2:',IFNULL(V_APL_YMD_2,'')
							,',V_MO_PACK_CD_2:',IFNULL(V_MO_PACK_CD_2,'')
							,',V_TRWI_QTY_2:',IFNULL(CONCAT(V_TRWI_QTY_2),'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_QLTY_VEHL_CD_3:',IFNULL(V_QLTY_VEHL_CD_3,'')
							,',V_MDL_MDY_CD_3:',IFNULL(V_MDL_MDY_CD_3,'')
							,',V_LANG_CD_3:',IFNULL(V_LANG_CD_3,'')
							,',V_APL_YMD_3:',IFNULL(V_APL_YMD_3,'')
							,',V_TRWI_QTY_3:',IFNULL(CONCAT(V_TRWI_QTY_3),'')
							,',V_PRDN_PLNT_CD_3:',IFNULL(V_PRDN_PLNT_CD_3,'')
							,',V_QLTY_VEHL_CD_4:',IFNULL(V_QLTY_VEHL_CD_4,'')
							,',V_MDL_MDY_CD_4:',IFNULL(V_MDL_MDY_CD_4,'')
							,',V_LANG_CD_4:',IFNULL(V_LANG_CD_4,'')
							,',V_APL_YMD_4:',IFNULL(V_APL_YMD_4,'')
							,',EXPD_DOM_NAT_CD:',IFNULL(EXPD_DOM_NAT_CD,'')
							,',V_TRWI_QTY_4:',IFNULL(CONCAT(V_TRWI_QTY_4),'')
							,',V_PRDN_PLNT_CD_4:',IFNULL(V_PRDN_PLNT_CD_4,'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;



    SET CURR_LOC_NUM = 1;
	
	SET EXPD_DOM_NAT_CD='A99VA';


			/*적용 기간동안의 미지정내역을 삭제한 뒤 작업을 진행한다.
			  [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된
			         내역만을 삭제해 주어야 한다. */
			DELETE FROM TB_PROD_MST_NOAPIM_INFO
			WHERE 1 = 1 /*APL_YMD BETWEEN FROM_YMD AND TO_YMD  */
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 2;

			CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PROD_MST_NOAPIM_INFO START');


    SET CURR_LOC_NUM = 3;

	OPEN PROD_MST_NOAPIM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_NOAPIM_INFO INTO V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_EXPD_NAT_CD_1,V_APL_YMD_1,V_PRDN_QTY_1,V_TRWI_QTY_1,V_PRDN_QTY2_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

				UPDATE TB_PROD_MST_NOAPIM_INFO
				SET PRDN_TRWI_QTY = V_TRWI_QTY_1,
					PRDN_QTY = V_PRDN_QTY_1,
					MDFY_DTM = SYSDATE(),
					PRDN_QTY2 = V_PRDN_QTY2_1
				WHERE APL_YMD = V_APL_YMD_1
					AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
					AND MDL_MDY_CD = V_MDL_MDY_CD_1
					AND PRDN_MST_NAT_CD = V_EXPD_NAT_CD_1;

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PROD_MST_NOAPIM_INFO
				WHERE APL_YMD = V_APL_YMD_1
					AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
					AND MDL_MDY_CD = V_MDL_MDY_CD_1
					AND PRDN_MST_NAT_CD = V_EXPD_NAT_CD_1;
				
				IF V_EXCNT = 0 THEN
					INSERT INTO TB_PROD_MST_NOAPIM_INFO
				    (APL_YMD,
					 QLTY_VEHL_CD,
					 MDL_MDY_CD,
					 PRDN_MST_NAT_CD,
					 PRDN_TRWI_QTY,
					 PRDN_QTY,
					 FRAM_DTM,
					 MDFY_DTM,
					 PRDN_QTY2
				    )
					VALUES
					(V_APL_YMD_1,
					 V_QLTY_VEHL_CD_1,
					 V_MDL_MDY_CD_1,
					 V_EXPD_NAT_CD_1,
					 V_TRWI_QTY_1,
					 V_PRDN_QTY_1,
					 SYSDATE(),
					 SYSDATE(),
					 V_PRDN_QTY2_1
				    );
					END IF;

	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_NOAPIM_INFO;


    SET CURR_LOC_NUM = 4;

			CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PROD_MST_NOAPIM_INFO END');


    SET CURR_LOC_NUM = 5;

			/*해당기간동안의 데이터를 삭제해 준다. */
			
			DELETE FROM TB_PROD_MST_SUM_INFO
			WHERE APL_YMD BETWEEN FROM_YMD AND TO_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
			

    SET CURR_LOC_NUM = 6;

			DELETE FROM TB_PROD_ODR_INFO
			WHERE APL_YMD BETWEEN FROM_YMD AND TO_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
			

    SET CURR_LOC_NUM = 7;

			/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 삭제 기능 추가  */
			DELETE FROM TB_PLNT_PROD_MST_SUM_INFO
			WHERE APL_YMD BETWEEN FROM_YMD AND TO_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 8;

			CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PROD_ODR_INFO START');


    SET CURR_LOC_NUM = 9;


	OPEN PROD_ODR_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_ODR_INFO INTO V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_APL_YMD_2,V_MO_PACK_CD_2,V_TRWI_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

			/* 1.선행생산 데이터 처리   */
				UPDATE TB_PROD_ODR_INFO
				SET PRDN_TRWI_QTY = V_TRWI_QTY_2, 
					MDFY_DTM = SYSDATE()
				WHERE MO_PACK_CD = V_MO_PACK_CD_2
				AND APL_YMD = V_APL_YMD_2
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_2
				AND MDL_MDY_CD = V_MDL_MDY_CD_2
				AND LANG_CD = V_LANG_CD_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				SET V_EXCNT = 0;
				SELECT COUNT(MO_PACK_CD)	 
				  INTO V_EXCNT	 
				  FROM TB_PROD_ODR_INFO
				WHERE MO_PACK_CD = V_MO_PACK_CD_2
				AND APL_YMD = V_APL_YMD_2
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_2
				AND MDL_MDY_CD = V_MDL_MDY_CD_2
				AND LANG_CD = V_LANG_CD_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				IF V_EXCNT = 0 THEN
				    INSERT INTO TB_PROD_ODR_INFO
					(MO_PACK_CD,
					 DATA_SN,
					 APL_YMD,
					 QLTY_VEHL_CD,
					 MDL_MDY_CD,
					 LANG_CD,
					 PRDN_TRWI_QTY,
					 FRAM_DTM,
					 MDFY_DTM,	 
					 PRDN_PLNT_CD
					)
					SELECT V_MO_PACK_CD_2,
					       A.DATA_SN,
						   V_APL_YMD_2,
						   V_QLTY_VEHL_CD_2,
						   V_MDL_MDY_CD_2,
						   V_LANG_CD_2,
						   V_TRWI_QTY_2,
						   SYSDATE(),
						   SYSDATE(),	 
						   V_PRDN_PLNT_CD_2	
					FROM TB_LANG_MGMT A
					WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2
					AND A.MDL_MDY_CD = V_MDL_MDY_CD_2
					AND A.LANG_CD = V_LANG_CD_2;
				END IF;				   

	END LOOP JOBLOOP2 ;
	CLOSE PROD_ODR_INFO;


    SET CURR_LOC_NUM = 10;

	CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PROD_ODR_INFO END');

    SET CURR_LOC_NUM = 11;


	CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PROD_MST_INFO START');

    SET CURR_LOC_NUM = 12;


	OPEN PROD_MST_INFO; /* cursor 열기 */
	JOBLOOP3 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_INFO INTO V_QLTY_VEHL_CD_3,V_MDL_MDY_CD_3,V_LANG_CD_3,V_APL_YMD_3,V_TRWI_QTY_3,V_PRDN_PLNT_CD_3;
	IF endOfRow3 THEN
	 LEAVE JOBLOOP3 ;
	END IF;

			/* 2.TB_PROD_MST_SUM_INFO 에 값 저장  */
				UPDATE TB_PROD_MST_SUM_INFO
				SET PRDN_TRWI_QTY = V_TRWI_QTY_3,
				    PRDN_QTY = 0,
					PRDN_QTY2 = 0,
					PRDN_QTY3 = 0,
					MDFY_DTM = SYSDATE()
				WHERE APL_YMD = V_APL_YMD_3
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_3
				AND MDL_MDY_CD = V_MDL_MDY_CD_3
				AND LANG_CD = V_LANG_CD_3;

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PROD_MST_SUM_INFO
				WHERE APL_YMD = V_APL_YMD_3
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_3
				AND MDL_MDY_CD = V_MDL_MDY_CD_3
				AND LANG_CD = V_LANG_CD_3;

				IF V_EXCNT = 0 THEN				   
				   INSERT INTO TB_PROD_MST_SUM_INFO
				   (APL_YMD,
				    DATA_SN,
					QLTY_VEHL_CD,
					MDL_MDY_CD,
					LANG_CD,
					PRDN_TRWI_QTY,
					PRDN_QTY,
					FRAM_DTM,
					MDFY_DTM,
					PRDN_QTY2,
					PRDN_QTY3
				   )
				   SELECT V_APL_YMD_3,
				          DATA_SN,
						  V_QLTY_VEHL_CD_3,
						  V_MDL_MDY_CD_3,
						  V_LANG_CD_3,
						  V_TRWI_QTY_3,
						  0,
						  SYSDATE(),
						  SYSDATE(),
						  0,
						  0
				   FROM TB_LANG_MGMT A
				   WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_3
				   AND A.MDL_MDY_CD = V_MDL_MDY_CD_3
				   AND A.LANG_CD = V_LANG_CD_3;					
				END IF;
				
				/* 3.PDI재고에서 투입수량 빼주기  */				
				IF V_APL_YMD_3 >= FROM_YMD AND  V_APL_YMD_3 <= TO_YMD THEN 
				   /*CALL SP_PROD_MST_PDI_IV_UPDATE(V_QLTY_VEHL_CD_3,	 
	   			 			   		       			 V_MDL_MDY_CD_3,	 
							   			   			 V_LANG_CD_3,	 
							   			   			 V_APL_YMD_3,	 
										   			 V_TRWI_QTY_3,	 
										   			 V_PRDN_PLNT_CD_3,	  
										   			 EXPD_CO_CD	
										   			 );	 */
										   	
					/* PRDN_PLNT_CD 값이 'N' 으로 고정되어 있는 문제 처리 요망  2016.06.06 JHKIM	 */
					SELECT IFNULL(SUM(DL_EXPD_WHOT_QTY), 0)	 
					  INTO V_PREV_WHOT_QTY	 
					  FROM TB_PDI_WHOT_INFO	 
					WHERE QLTY_VEHL_CD = V_QLTY_VEHL_CD_3	 
					  AND MDL_MDY_CD = V_MDL_MDY_CD_3	 
					  AND LANG_CD = V_LANG_CD_3	 
					  AND WHOT_YMD = V_APL_YMD_3	 
					  AND DEL_YN = 'N'	 
					  /* 출고로 빠진 데이터만을 가져오도록 한다.	 */
					  AND DL_EXPD_WHOT_ST_CD = '01'	 
					  AND PRDN_PLNT_CD = IFNULL(V_PRDN_PLNT_CD_3, 'N');
				
					/*원래 0보다 작은 값은 존재하면 안된다. 그러나 현재 존재하고 있어서 아래와 같은 체크로직을 추가함	 */
					IF V_PREV_WHOT_QTY < 0 THEN
						SET V_PREV_WHOT_QTY = 0;
					END IF;	 
					 
					/*원래의 출고수량과 투입된 수량이 같으면 작업을 진행하지 않는다.	 */
					SET V_TRWI_DIFF = V_TRWI_QTY_3 - V_PREV_WHOT_QTY;	 
					 
					/*원래의 출고수량보다 투입수량이 많아진 경우	 */
					IF V_TRWI_DIFF > 0 THEN
							    CALL SP_UPDATE_PDI_IV_INFO1(V_QLTY_VEHL_CD_3,	 
												       V_MDL_MDY_CD_3,	 
												       V_LANG_CD_3,	 
								                       V_APL_YMD_3,	 
													   V_TRWI_DIFF,	 	 
							                           V_PRDN_PLNT_CD_3,
							                           EXPD_CO_CD
													   );
				
						    /*원래의 출고수량보다 투입수량이 적어진 경우	 */
					ELSEIF V_TRWI_DIFF < 0 THEN
								CALL SP_UPDATE_PDI_IV_INFO2(V_QLTY_VEHL_CD_3,	 
												       V_MDL_MDY_CD_3,	 
												       V_LANG_CD_3,	 
								                       V_APL_YMD_3,	 
													   V_TRWI_DIFF * (-1),	 
							                           V_PRDN_PLNT_CD_3,
							                           EXPD_CO_CD
													   );
					END IF;					   			
										   			
				END IF;
						

	END LOOP JOBLOOP3 ;
	CLOSE PROD_MST_INFO;	 


    SET CURR_LOC_NUM = 13;

	CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PROD_MST_INFO END');	

    SET CURR_LOC_NUM = 14;
		
	CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PLNT_PROD_MST_INFO START');

    SET CURR_LOC_NUM = 15;


	OPEN PLNT_PROD_MST_INFO; /* cursor 열기 */
	JOBLOOP4 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_PROD_MST_INFO INTO V_QLTY_VEHL_CD_4,V_MDL_MDY_CD_4,V_LANG_CD_4,V_APL_YMD_4,V_PRDN_PLNT_CD_4,V_TRWI_QTY_4;
	IF endOfRow4 THEN
	 LEAVE JOBLOOP4 ;
	END IF;

			/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 저장 기능 추가  */				
				UPDATE TB_PLNT_PROD_MST_SUM_INFO
				SET PRDN_TRWI_QTY = V_TRWI_QTY_4,
				    PRDN_QTY = 0,
					PRDN_QTY2 = 0,
					PRDN_QTY3 = 0,
					MDFY_DTM = SYSDATE()
				WHERE APL_YMD = V_APL_YMD_4
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_4
				AND MDL_MDY_CD = V_MDL_MDY_CD_4
				AND LANG_CD = V_LANG_CD_4	 
				AND PRDN_PLNT_CD = IFNULL(V_PRDN_PLNT_CD_4, 'N');	

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PLNT_PROD_MST_SUM_INFO
				WHERE APL_YMD = V_APL_YMD_4
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_4
				AND MDL_MDY_CD = V_MDL_MDY_CD_4
				AND LANG_CD = V_LANG_CD_4	 
				AND PRDN_PLNT_CD = IFNULL(V_PRDN_PLNT_CD_4, 'N');

				IF V_EXCNT = 0 THEN
				   
				   INSERT INTO TB_PLNT_PROD_MST_SUM_INFO
				   (APL_YMD,
				    DATA_SN,
					QLTY_VEHL_CD,
					MDL_MDY_CD,
					LANG_CD,
					PRDN_TRWI_QTY,
					PRDN_QTY,
					FRAM_DTM,
					MDFY_DTM,
					PRDN_QTY2,
					PRDN_QTY3,	 
					PRDN_PLNT_CD
				   )
				   SELECT V_APL_YMD_4,
				          DATA_SN,
						  V_QLTY_VEHL_CD_4,
						  V_MDL_MDY_CD_4,
						  V_LANG_CD_4,
						  V_TRWI_QTY_4,
						  0,
						  SYSDATE(),
						  SYSDATE(),
						  0,
						  0,	 
						  IFNULL(V_PRDN_PLNT_CD_4,'N')
				   FROM TB_LANG_MGMT A
				   WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_4
				   AND A.MDL_MDY_CD = V_MDL_MDY_CD_4
				   AND A.LANG_CD = V_LANG_CD_4;
				END IF;

	END LOOP JOBLOOP4 ;
	CLOSE PLNT_PROD_MST_INFO;
	 

    SET CURR_LOC_NUM = 16;

	CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_HMC', SYSDATE(), 'S', 'GET_PROD_MST_SUM2 : PLNT_PROD_MST_INFO END');

    SET CURR_LOC_NUM = 17;


	SET V_FROM_DATE = STR_TO_DATE(FROM_YMD, '%Y%m%d');	
	SET V_TO_DATE = STR_TO_DATE(TO_YMD, '%Y%m%d'); 
	SET V_DATE_CNT  = ROUND(V_TO_DATE - V_FROM_DATE);	

	SET i=0;
	JOBLOOP: LOOP
			
				SET V_CURR_DATE = DATE_ADD(V_FROM_DATE,INTERVAL i DAY);
				SET V_CURR_YMD = DATE_FORMAT(V_CURR_DATE, '%Y%m%d');
				/*로직변경... 하루 이전까지만 수행하지 않고 현재일까지 수행하도록 한다.	
				  생산마스터 생산 진행정보 업데이트	 */
				CALL SP_GET_PROD_MST_PROG_SUM(V_CURR_YMD, EXPD_CO_CD);	 
	 
				/*생산마스터정보 취합 작업 수행	 */
				CALL SP_GET_PROD_MST_SUM_DTL_HMC(V_CURR_YMD, V_CURR_YMD, EXPD_CO_CD);	 
	 
				/*재고 상세 내역 재 계산 작업 수행(생산마스터 정보 취합 후 작업이 수행되어야 한다.)	 
				  (반드시 세원재고 재계산 작업이 이루어진 후에 PDI 재고 데이터 재계산이 이루어 져야 한다.)	 */
				CALL SP_RECALCULATE_SEWON_IV_DTL2(V_CURR_YMD, EXPD_CO_CD);	 
				CALL SP_RECALCULATE_PDI_IV_DTL2(V_CURR_YMD, EXPD_CO_CD);	 

				SET i=i+1; 
				IF i=V_DATE_CNT THEN
					LEAVE JOBLOOP;
				END IF;
	END LOOP JOBLOOP;


    SET CURR_LOC_NUM = 18;

	/*END;
	DELIMITER;
	다음처리*/
	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 19;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_SUM2_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_SUM2_KMC`(IN FROM_YMD VARCHAR(8),
                                        IN TO_YMD VARCHAR(8),
                                        IN P_APL_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_SUM2_KMC
 * Procedure 설명 : 생산마스터내역 조회(PDI 공통차종 오더내역 조회 부분 포함)
 *                 생산정보 현황 - 공장별 내역 조회
 *                 적용 기간동안의 미지정내역을 삭제한 뒤 작업을 진행한다.
 *                 [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된	 내역만을 삭제해 주어야 한다. 
 *                 선행생산 데이터 처리
 *                 TB_PROD_MST_SUM_INFO 에 값 저장
 *                 PDI재고에서 투입수량 빼주기
 *                 생산정보 현황 - 공장별 내역 저장
 *                 생산마스터 생산 진행정보 업데이트
 *                 생산마스터정보 취합 작업 수행
 *                 재고 상세 내역 재 계산 작업 수행(생산마스터 정보 취합 후 작업이 수행되어야 한다.)
 *                 (반드시 세원재고 재계산 작업이 이루어진 후에 PDI 재고 데이터 재계산이 이루어 져야 한다.)
 * 입력 파라미터    :  FROM_YMD               시작년월일
 *                 TO_YMD                 종료년월일
 *                 P_APL_YMD              적용년월일
 *                 EXPD_CO_CD             회사코드 02
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_YMD				VARCHAR(8);
	DECLARE V_DATE_CNT				INT;
	DECLARE V_CNT					INT;
	DECLARE V_CNT2					INT;
	DECLARE V_FROM_DATE				DATETIME;
	DECLARE V_TO_DATE				DATETIME;
	DECLARE V_CURR_DATE				DATETIME;
	DECLARE i						INT;	   			
	DECLARE V_PREV_WHOT_QTY	        INT;
	DECLARE V_TRWI_DIFF	            INT;
	DECLARE EXPD_DOM_NAT_CD			VARCHAR(5);  /* 내수 국가코드 A99VA */
	
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_EXPD_NAT_CD_1 VARCHAR(5);
	DECLARE V_APL_YMD_1 VARCHAR(8);
	DECLARE V_PRDN_QTY_1 INT;
	DECLARE V_TRWI_QTY_1 INT;
	DECLARE V_PRDN_QTY2_1 INT;

	DECLARE V_QLTY_VEHL_CD_2 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2 VARCHAR(4);
	DECLARE V_LANG_CD_2 VARCHAR(3);
	DECLARE V_APL_YMD_2 VARCHAR(8);
	DECLARE V_MO_PACK_CD_2 VARCHAR(4);
	DECLARE V_TRWI_QTY_2 INT;
	DECLARE V_PRDN_PLNT_CD_2 VARCHAR(3);
					   
	DECLARE V_QLTY_VEHL_CD_3 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_3 VARCHAR(4);
	DECLARE V_LANG_CD_3 VARCHAR(3);
	DECLARE V_APL_YMD_3 VARCHAR(8);
	DECLARE V_TRWI_QTY_3 INT;
	DECLARE V_PRDN_PLNT_CD_3 VARCHAR(3);

	DECLARE V_QLTY_VEHL_CD_4 VARCHAR(4);
	DECLARE V_MDL_MDY_CD_4 VARCHAR(4);
	DECLARE V_LANG_CD_4 VARCHAR(3);
	DECLARE V_APL_YMD_4 VARCHAR(8);
	DECLARE V_PRDN_PLNT_CD_4 VARCHAR(3);
	DECLARE V_TRWI_QTY_4 INT;
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow3 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow4 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PROD_MST_NOAPIM_INFO CURSOR FOR
							/*국가미지정 정보를 가져오는 부분	 */
		 					  	        SELECT K.QLTY_VEHL_CD,	 
									    	   IFNULL(K.MDL_MDY_CD, '00') MDL_MDY_CD,	 
											   K.EXPD_NAT_CD,	 
									    	   K.APL_YMD,	 
											   CASE WHEN K.PAC_SCN_CD = '01' THEN K.PRDN_PAS_QTY  /* 승용 생산수량	  */
										     		ELSE K.PRDN_COM_QTY                         /* 상용 생산수량	  */
									    	   END AS PRDN_QTY,	 
											   CASE WHEN K.PAC_SCN_CD = '01' THEN K.TRWI_PAS_QTY  /* 승용 투입수량	  */
										     		ELSE K.TRWI_COM_QTY                         /* 상용 투입수량	  */
									           END AS TRWI_QTY,	 
											   CASE WHEN K.PAC_SCN_CD = '01' THEN K.PRDN_PAS_QTY2  /* 승용 생산수량2	 */ 
										     		ELSE K.PRDN_COM_QTY2                         /* 상용 생산수량2	 */ 
									    	   END AS PRDN_QTY2	 
		 					  	        FROM (SELECT A.QLTY_VEHL_CD,	 
									    	         A.MDL_MDY_CD,	 
													 A.EXPD_NAT_CD,	 
									    	         A.APL_YMD,	 
											         (SELECT MAX(DL_EXPD_PAC_SCN_CD)	 
								 		              FROM TB_VEHL_MGMT	 
										              WHERE QLTY_VEHL_CD = A.QLTY_VEHL_CD	 
													  AND MDL_MDY_CD = A.MDL_MDY_CD	 
										             ) AS PAC_SCN_CD,	 
											         SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY /* 글로비스 생산수량	 */ 
											                  ELSE A.PRDN_PAS_QTY                     /* 승용 생산수량	  */
											             END	 
											            ) AS PRDN_PAS_QTY,	 
											         SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY /* 글로비스 생산수량	 */ 
											                  ELSE A.PRDN_COM_QTY                     /* 상용 생산수량	  */
											             END	 
											            ) AS PRDN_COM_QTY,	 
											         SUM(CASE WHEN A.USF_CD = 'D' THEN A.TRWI_DOM_QTY /* 글로비스 투입수량	  */
											                  ELSE A.TRWI_PAS_QTY                     /* 승용 투입수량	  */
											             END	 
											            ) AS TRWI_PAS_QTY,	 
											         SUM(CASE WHEN A.USF_CD = 'D' THEN A.TRWI_DOM_QTY /* 글로비스 투입수량	  */
											                  ELSE A.TRWI_COM_QTY                     /* 상용 투입수량	  */
											             END	 
											            ) AS TRWI_COM_QTY,	 
													 SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY2 /* 글로비스 생산수량	 */ 
											                  ELSE A.PRDN_PAS_QTY2                     /* 승용 생산수량	  */
											             END	 
											            ) AS PRDN_PAS_QTY2,	 
											         SUM(CASE WHEN A.USF_CD = 'D' THEN A.PRDN_DOM_QTY2 /* 글로비스 생산수량	  */
											                  ELSE A.PRDN_COM_QTY2                     /* 상용 생산수량	  */
											             END	 
											            ) AS PRDN_COM_QTY2	 
								       		  FROM (	 
														  /*미지정 국가 항목의 경우에는 투입일 기준이 아닌 적용일 기준으로 계산해 주도록 한다.	 */ 
														  SELECT B.QLTY_VEHL_CD,	 
		 					  	 			 	          	     A.MDL_MDY_CD,	 
														  		 GET_NAT_CD(A.DEST_NAT_CD) AS DL_EXPD_NAT_CD,	 
														  	     A.DEST_NAT_CD AS EXPD_NAT_CD,	 
			                                			  	     A.TRWI_YMD AS APL_YMD,	 
														  		 MAX(A.USF_CD) AS USF_CD,	 
														  		 SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD < '10' THEN 1 ELSE 0 END) AS PRDN_PAS_QTY,  /*승용 생산수량	 */
														  		 SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD < '11' THEN 1 ELSE 0 END) AS PRDN_COM_QTY,  /*상용 생산수량	 */
														  		 SUM(CASE WHEN A.USF_CD = 'D' AND A.POW_LOC_CD < '16' THEN 1 ELSE 0 END) AS PRDN_DOM_QTY,  /*내수 생산수량	 */
														  		 SUM(CASE WHEN A.USF_CD = 'E' AND A.TRWI_USED_YN = 'N' AND A.POW_LOC_CD >= '10' THEN 1 ELSE 0 END) AS TRWI_PAS_QTY,  /*승용 투입수량	 */
														  		 SUM(CASE WHEN A.USF_CD = 'E' AND A.TRWI_USED_YN = 'N' AND A.POW_LOC_CD >= '11' THEN 1 ELSE 0 END) AS TRWI_COM_QTY,  /*상용 투입수량	 */
														  		 SUM(CASE WHEN A.USF_CD = 'D' AND A.TRWI_USED_YN = 'N' AND A.POW_LOC_CD >= '16' THEN 1 ELSE 0 END) AS TRWI_DOM_QTY,  /*내수 투입수량	 */
																 SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD >= '08' AND A.POW_LOC_CD < '10' THEN 1 ELSE 0 END) AS PRDN_PAS_QTY2,  /*승용 생산수량2	 */
														  		 SUM(CASE WHEN A.USF_CD = 'E' AND A.POW_LOC_CD >= '08' AND A.POW_LOC_CD < '11' THEN 1 ELSE 0 END) AS PRDN_COM_QTY2,  /*상용 생산수량2	 */
														  		 SUM(CASE WHEN A.USF_CD = 'D' AND A.POW_LOC_CD >= '08' AND A.POW_LOC_CD < '16' THEN 1 ELSE 0 END) AS PRDN_DOM_QTY2   /*내수 생산수량2	 */
								 			              FROM TB_PROD_MST_INFO A,	 
								      			        	   TB_ALTN_VEHL_MGMT B	 
								 			              WHERE A.DL_EXPD_CO_CD = EXPD_CO_CD	 
	 
								 			       		  AND A.TRWI_YMD  = P_APL_YMD	 
								                   		  AND A.PRDN_MST_VEHL_CD = B.PRDN_VEHL_CD	 
								                   		  AND B.PRVS_SCN_CD = 'B'	 
								                   		  GROUP BY B.QLTY_VEHL_CD,	 
								 	   	                       	   A.MDL_MDY_CD,	 
										                    	   A.DEST_NAT_CD,	 
										                    	   A.TRWI_YMD
									               ) A	 
											  WHERE DL_EXPD_NAT_CD IS NOT NULL AND MDL_MDY_CD IS NULL	 
											  	/* 내수인 경우와 미투입 대리점 리스트에 해당하는 경우는 제외	  */
											  	AND EXPD_NAT_CD <> EXPD_DOM_NAT_CD AND EXPD_NAT_CD NOT IN (SELECT DYTM_PLN_NAT_CD FROM TB_ALTN_WIOUT_NATL_MGMT)	 
										        AND SUBSTR(EXPD_NAT_CD,1,3) IN (SELECT DL_EXPD_NAT_CD FROM TB_NATL_LANG_MGMT WHERE DL_EXPD_CO_CD = '02')
											  GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.APL_YMD, A.EXPD_NAT_CD	 
								 	         ) K;	 

	DECLARE PROD_ODR_INFO CURSOR FOR
		 /*오더별생산내역 조회를 위한 부분	 
		   (현재는 날짜별로 오더에 관계된 생산된 데이터 전체를 무조건 처리해 준다.	 
		    그리고 국가/언어가 제대로 설정된 데이터만 가져오도록 한다.(OUTER JOIN 필요없음)	 
		   [변경] 2009.07.23 PDI 공통차종 오더내역 조회 부분 포함	 */
                WITH T AS	 
                (	 
                SELECT A.QLTY_VEHL_CD,	 
                       A.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       A.MO_PACK_CD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 
                  FROM (	 
                        SELECT QLTY_VEHL_CD,	 
                               MDL_MDY_CD,	 
                               DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
                               APL_YMD,	 
                               MO_PACK_CD,	 
                               COUNT(*) AS TRWI_QTY,
                               CASE WHEN QLTY_VEHL_CD = 'AM' THEN IFNULL(PRDN_PLNT_CD,'N')
                                    WHEN QLTY_VEHL_CD = 'PS' THEN IFNULL(PRDN_PLNT_CD,'N')
                                    WHEN QLTY_VEHL_CD = 'SK3' THEN IFNULL(PRDN_PLNT_CD,'N')
                                    ELSE 'N' END AS PRDN_PLNT_CD
                               /* QL 때문에 AM, PS 만 공장코드 부여	 */
                          FROM TB_PROD_MST_TRWI_INFO	 
                         WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
                           AND APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
                           AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	 */
                           AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
                           AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
                         GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, DL_EXPD_NAT_CD, APL_YMD, MO_PACK_CD, PRDN_PLNT_CD	 
                       ) A,	 
                       TB_NATL_LANG_MGMT B	 
                 WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
                   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
                   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                 GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.MO_PACK_CD, A.PRDN_PLNT_CD	 
                )
                SELECT QLTY_VEHL_CD,	 
                       MDL_MDY_CD,	 
                       LANG_CD,	 
                       APL_YMD,	 
                       MO_PACK_CD,	 
                       TRWI_QTY,	 
                       PRDN_PLNT_CD	 
                  FROM T	 
	 
                 UNION ALL	 
	 
                SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
                       B.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       A.MO_PACK_CD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 
                  FROM T A,	 
                       TB_PDI_COM_VEHL_MGMT B	 
                 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                   AND A.LANG_CD = B.LANG_CD	 
                 GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD, A.MO_PACK_CD , A.PRDN_PLNT_CD;

	DECLARE PROD_MST_INFO CURSOR FOR
		 /*생산마스터내역 조회를 위한 부분	 
		   (PDI 공통차종 오더내역 조회 부분 포함)	 */
                WITH T AS	 
                (	 
                SELECT A.QLTY_VEHL_CD,	 
                       A.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY	 
                       , A.PRDN_PLNT_CD	 
                  FROM (	 
                        SELECT QLTY_VEHL_CD,	 
                               MDL_MDY_CD,	 
                               DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
                               APL_YMD,	 
                               COUNT(*) AS TRWI_QTY	 
                               ,CASE WHEN QLTY_VEHL_CD IN ('AM', 'PS', 'SK3') THEN IFNULL(PRDN_PLNT_CD,'N') ELSE 'N' END AS PRDN_PLNT_CD	 
                          FROM TB_PROD_MST_TRWI_INFO	 
                         WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
                           AND APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
                           AND QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	*/
                           AND MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
                           AND DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
                         GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, DL_EXPD_NAT_CD, APL_YMD, PRDN_PLNT_CD	 
                        ) A,	 
                       TB_NATL_LANG_MGMT B	 
                 WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
                   AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
                   AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                 GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.PRDN_PLNT_CD	 
                   /*재고 수불 기준이 이전연식부터 처리되어야 하기 때문에	 
                     ORDER BY 의 순서를 아래와 같이 준수하여야 한다.	 */
                 ORDER BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD	 
                )	 
                SELECT QLTY_VEHL_CD,	 
                       MDL_MDY_CD,	 
                       LANG_CD,	 
                       APL_YMD,	 
                       TRWI_QTY,	 
                       PRDN_PLNT_CD	 
                  FROM T	 
	 
                 UNION ALL	 
	 
                SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
                       B.MDL_MDY_CD,	 
                       B.LANG_CD,	 
                       A.APL_YMD,	 
                       SUM(A.TRWI_QTY) AS TRWI_QTY,	 
                       A.PRDN_PLNT_CD	 
                  FROM T A,	 
                       TB_PDI_COM_VEHL_MGMT B	 
                 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                   AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
                   AND A.LANG_CD = B.LANG_CD	 
                 GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD , A.PRDN_PLNT_CD;

	DECLARE PLNT_PROD_MST_INFO CURSOR FOR
		/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 조회	 */
		 					  	                WITH T AS (SELECT A.QLTY_VEHL_CD,	 
		 					  	 		   		       A.MDL_MDY_CD,	 
												       B.LANG_CD,	 
												       A.APL_YMD,	 
													   A.PRDN_PLNT_CD,	 
												       SUM(A.TRWI_QTY) AS TRWI_QTY	 
		 					  	                FROM (SELECT A.QLTY_VEHL_CD,	 
								 	  		  	 		     A.MDL_MDY_CD,	 
											  			     A.DL_EXPD_NAT_CD AS EXPD_NAT_CD,	 
											  			     A.APL_YMD,	 
															 B.PRDN_PLNT_CD,	 
															 MAX(B.SORT_SN) AS SORT_SN,	 
											  			     COUNT(*) AS TRWI_QTY	 
									                  FROM TB_PROD_MST_TRWI_INFO A,	 
												           TB_PLNT_VEHL_MGMT B	 
									   			      WHERE DL_EXPD_CO_CD = EXPD_CO_CD	 
									   			      AND APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
												      AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
												      AND IFNULL(A.PRDN_PLNT_CD,'N') = B.PRDN_PLNT_CD	 
									   			      AND A.QLTY_VEHL_CD IS NOT NULL   /*현재 사용중인 차종에 대해서만 가져오도록 한다.	*/
									   			      AND A.MDL_MDY_CD IS NOT NULL     /*연식이 지정된 항목만 가져온다.	 */
									   			      AND A.DL_EXPD_NAT_CD IS NOT NULL /*취급설명서국가코드가 등록된 항목만 가져온다.	 */
									   			      GROUP BY A.QLTY_VEHL_CD,	 
									  		      		       A.MDL_MDY_CD,	 
														       A.DL_EXPD_NAT_CD,	 
														       A.APL_YMD,	 
															   B.PRDN_PLNT_CD	 
								                     ) A,	 
									  			     TB_NATL_LANG_MGMT B	 
								                WHERE A.EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
								 		        AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
								 		        AND A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								 		        AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								 		        GROUP BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, A.PRDN_PLNT_CD	 
								 		        /*재고 수불 기준이 이전연식부터 처리되어야 하기 때문에	 
								 		          ORDER BY 의 순서를 아래와 같이 준수하여야 한다.	 */
								 		        ORDER BY A.QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, A.MDL_MDY_CD, MAX(A.SORT_SN)	 
		 					  	 	           )	 
								     SELECT QLTY_VEHL_CD,	 
								 	        MDL_MDY_CD,	 
									        LANG_CD,	 
									        APL_YMD,	 
											PRDN_PLNT_CD,	 
									        TRWI_QTY	 
								     FROM T	 
	 
								     UNION ALL	 
	 
								     SELECT B.DIVS_QLTY_VEHL_CD AS QLTY_VEHL_CD,	 
								            B.MDL_MDY_CD,	 
									        B.LANG_CD,	 
									        A.APL_YMD,	 
											A.PRDN_PLNT_CD,	 
									        SUM(A.TRWI_QTY) AS TRWI_QTY	 
								     FROM T A,	 
								          TB_PDI_COM_VEHL_MGMT B	 
								     WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								     AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
								     AND A.LANG_CD = B.LANG_CD	 
								     GROUP BY B.DIVS_QLTY_VEHL_CD, A.APL_YMD, B.LANG_CD, B.MDL_MDY_CD, A.PRDN_PLNT_CD;	 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE, endOfRow3 =TRUE, endOfRow4 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_SUM2_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',FROM_YMD:',IFNULL(FROM_YMD,'')
							,',TO_YMD:',IFNULL(TO_YMD,'')
							,',P_APL_YMD:',IFNULL(P_APL_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',V_DATE_CNT:',IFNULL(CONCAT(V_DATE_CNT),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_CNT2:',IFNULL(CONCAT(V_CNT2),'')
							,',V_FROM_DATE:',IFNULL(DATE_FORMAT(V_FROM_DATE, '%Y%m%d'),'')
							,',V_TO_DATE:',IFNULL(DATE_FORMAT(V_TO_DATE, '%Y%m%d'),'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',i:',IFNULL(CONCAT(i),'')  	
							,',V_PREV_WHOT_QTY:',IFNULL(CONCAT(V_PREV_WHOT_QTY),'')
							,',V_TRWI_DIFF:',IFNULL(CONCAT(V_TRWI_DIFF),'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_EXPD_NAT_CD_1:',IFNULL(V_EXPD_NAT_CD_1,'')
							,',V_APL_YMD_1:',IFNULL(V_APL_YMD_1,'')
							,',V_PRDN_QTY_1:',IFNULL(CONCAT(V_PRDN_QTY_1),'')
							,',V_TRWI_QTY_1:',IFNULL(CONCAT(V_TRWI_QTY_1),'')
							,',V_PRDN_QTY2_1:',IFNULL(CONCAT(V_PRDN_QTY2_1),'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_APL_YMD_2:',IFNULL(V_APL_YMD_2,'')
							,',V_MO_PACK_CD_2:',IFNULL(V_MO_PACK_CD_2,'')
							,',V_TRWI_QTY_2:',IFNULL(CONCAT(V_TRWI_QTY_2),'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_QLTY_VEHL_CD_3:',IFNULL(V_QLTY_VEHL_CD_3,'')
							,',V_MDL_MDY_CD_3:',IFNULL(V_MDL_MDY_CD_3,'')
							,',V_LANG_CD_3:',IFNULL(V_LANG_CD_3,'')
							,',V_APL_YMD_3:',IFNULL(V_APL_YMD_3,'')
							,',V_TRWI_QTY_3:',IFNULL(CONCAT(V_TRWI_QTY_3),'')
							,',V_PRDN_PLNT_CD_3:',IFNULL(V_PRDN_PLNT_CD_3,'')
							,',V_QLTY_VEHL_CD_4:',IFNULL(V_QLTY_VEHL_CD_4,'')
							,',V_MDL_MDY_CD_4:',IFNULL(V_MDL_MDY_CD_4,'')
							,',V_LANG_CD_4:',IFNULL(V_LANG_CD_4,'')
							,',EXPD_DOM_NAT_CD:',IFNULL(EXPD_DOM_NAT_CD,'')
							,',V_APL_YMD_4:',IFNULL(V_APL_YMD_4,'')
							,',V_PRDN_PLNT_CD_4:',IFNULL(V_PRDN_PLNT_CD_4,'')
							,',V_TRWI_QTY_4:',IFNULL(CONCAT(V_TRWI_QTY_4),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;





    SET CURR_LOC_NUM = 1;
	
	SET EXPD_DOM_NAT_CD='A99VA';

	/*적용 기간동안의 미지정내역을 삭제한 뒤 작업을 진행한다.	 */
	/*[참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된	 */
	/*       내역만을 삭제해 주어야 한다.	 */
	DELETE FROM TB_PROD_MST_NOAPIM_INFO
	WHERE 1 = 1 /*APL_YMD BETWEEN FROM_YMD AND TO_YMD	 */
	AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 2;

	OPEN PROD_MST_NOAPIM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_NOAPIM_INFO INTO V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_EXPD_NAT_CD_1,V_APL_YMD_1,V_PRDN_QTY_1,V_TRWI_QTY_1,V_PRDN_QTY2_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

				/*등록전 PK별 정보 있는지 확인*/
				SET V_INEXCNT = 0;
				SELECT COUNT(*)	 
				  INTO V_INEXCNT	 
				  FROM TB_PROD_MST_NOAPIM_INFO
				WHERE APL_YMD = V_APL_YMD_1
					AND QLTY_VEHL_CD =V_QLTY_VEHL_CD_1
					AND MDL_MDY_CD = V_MDL_MDY_CD_1
					AND PRDN_MST_NAT_CD = V_EXPD_NAT_CD_1;
				
				IF V_INEXCNT = 0 THEN
					INSERT INTO TB_PROD_MST_NOAPIM_INFO	 
					(APL_YMD,	 
					 QLTY_VEHL_CD,	 
					 MDL_MDY_CD,	 
					 PRDN_MST_NAT_CD,	 
					 PRDN_TRWI_QTY,	 
					 PRDN_QTY,	 
					 FRAM_DTM,	 
					 MDFY_DTM,	 
					 PRDN_QTY2	 
					)	 
					VALUES	 
					(V_APL_YMD_1,	 
					 V_QLTY_VEHL_CD_1,	 
					 V_MDL_MDY_CD_1,	 
					 V_EXPD_NAT_CD_1,	 
					 V_TRWI_QTY_1,	 
					 V_PRDN_QTY_1,	 
					 SYSDATE(),	 
					 SYSDATE(),	 
					 V_PRDN_QTY2_1	 
					);	
				END IF; 

	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_NOAPIM_INFO;
	 

    SET CURR_LOC_NUM = 3;

	DELETE FROM TB_PROD_MST_SUM_INFO
	WHERE APL_YMD BETWEEN FROM_YMD AND TO_YMD	
	AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 4;

	DELETE FROM TB_PROD_ODR_INFO
	WHERE APL_YMD BETWEEN FROM_YMD AND TO_YMD	 
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 5;

	/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 삭제 기능 추가	 */
	DELETE FROM TB_PLNT_PROD_MST_SUM_INFO
	WHERE APL_YMD BETWEEN FROM_YMD AND TO_YMD	
	AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 6;

	OPEN PROD_ODR_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_ODR_INFO INTO V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_APL_YMD_2,V_MO_PACK_CD_2,V_TRWI_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

			/* 1.선행생산 데이터 처리*/
				UPDATE TB_PROD_ODR_INFO	 
				SET PRDN_TRWI_QTY = V_TRWI_QTY_2,	 
					MDFY_DTM = SYSDATE()	 
				WHERE MO_PACK_CD = V_MO_PACK_CD_2	 
				AND APL_YMD = V_APL_YMD_2	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_2	 
				AND LANG_CD = V_LANG_CD_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				SET V_EXCNT = 0;
				SELECT COUNT(MO_PACK_CD)	 
				  INTO V_EXCNT	 
				  FROM TB_PROD_ODR_INFO
				WHERE MO_PACK_CD = V_MO_PACK_CD_2	 
				AND APL_YMD = V_APL_YMD_2	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_2	 
				AND LANG_CD = V_LANG_CD_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				IF V_EXCNT = 0 THEN	
				    INSERT INTO TB_PROD_ODR_INFO	 
					(MO_PACK_CD,	 
					 DATA_SN,	 
					 APL_YMD,	 
					 QLTY_VEHL_CD,	 
					 MDL_MDY_CD,	 
					 LANG_CD,	 
					 PRDN_TRWI_QTY,	 
					 FRAM_DTM,	 
					 MDFY_DTM,	 
					 PRDN_PLNT_CD	 
					)	 
					SELECT V_MO_PACK_CD_2,	 
					       A.DATA_SN,	 
						   V_APL_YMD_2,	 
						   V_QLTY_VEHL_CD_2,	 
						   V_MDL_MDY_CD_2,	 
						   V_LANG_CD_2,	 
						   V_TRWI_QTY_2,	 
						   SYSDATE(),	 
						   SYSDATE(),	 
						   V_PRDN_PLNT_CD_2	 
					FROM TB_LANG_MGMT A	 
					WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_2	 
					AND A.MDL_MDY_CD = V_MDL_MDY_CD_2	 
					AND A.LANG_CD = V_LANG_CD_2;
				END IF;

	END LOOP JOBLOOP2 ;
	CLOSE PROD_ODR_INFO;


    SET CURR_LOC_NUM = 7;

	OPEN PROD_MST_INFO; /* cursor 열기 */
	JOBLOOP3 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_INFO INTO V_QLTY_VEHL_CD_3,V_MDL_MDY_CD_3,V_LANG_CD_3,V_APL_YMD_3,V_TRWI_QTY_3,V_PRDN_PLNT_CD_3;
	IF endOfRow3 THEN
	 LEAVE JOBLOOP3 ;
	END IF;

			/* 2.TB_PROD_MST_SUM_INFO 에 값 저장	 */
				UPDATE TB_PROD_MST_SUM_INFO	 
				SET PRDN_TRWI_QTY = V_TRWI_QTY_3,	 
				    PRDN_QTY  = 0,	 
					PRDN_QTY2 = 0,	 
					PRDN_QTY3 = 0,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = V_APL_YMD_3	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_3	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_3	 
				AND LANG_CD = V_LANG_CD_3;	

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PROD_MST_SUM_INFO	 
				WHERE APL_YMD = V_APL_YMD_3	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_3	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_3	 
				AND LANG_CD = V_LANG_CD_3;	

				IF V_EXCNT = 0 THEN
				   INSERT INTO TB_PROD_MST_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					PRDN_TRWI_QTY,	 
					PRDN_QTY,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					PRDN_QTY2,	 
					PRDN_QTY3	 
				   )	 
				   SELECT V_APL_YMD_3,	 
				          DATA_SN,	 
						  V_QLTY_VEHL_CD_3,	 
						  V_MDL_MDY_CD_3,	 
						  V_LANG_CD_3,	 
						  V_TRWI_QTY_3,	 
						  0,	 
						  SYSDATE(),	 
						  SYSDATE(),	 
						  0,	 
						  0	 
				   FROM TB_LANG_MGMT A	 
				   WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_3	 
				   AND A.MDL_MDY_CD = V_MDL_MDY_CD_3	 
				   AND A.LANG_CD = V_LANG_CD_3;	
				END IF;

				/* 3.PDI재고에서 투입수량 빼주기	 */	 
				IF V_APL_YMD_3 >= FROM_YMD AND  V_APL_YMD_3 <= TO_YMD THEN
				   /*CALL SP_PROD_MST_PDI_IV_UPDATE(V_QLTY_VEHL_CD_3,	 
	   			 			   		       			 V_MDL_MDY_CD_3,	 
							   			   			 V_LANG_CD_3,	 
							   			   			 V_APL_YMD_3,	 
										   			 V_TRWI_QTY_3,	  
										   			 V_PRDN_PLNT_CD_3,	  
										   			 EXPD_CO_CD	
										   			 );	 */
				
				
							
					/* PRDN_PLNT_CD 값이 'N' 으로 고정되어 있는 문제 처리 요망  2016.06.06 JHKIM	 */
					SELECT IFNULL(SUM(DL_EXPD_WHOT_QTY), 0)	 
					  INTO V_PREV_WHOT_QTY	 
					  FROM TB_PDI_WHOT_INFO	 
					WHERE QLTY_VEHL_CD = V_QLTY_VEHL_CD_3	 
					  AND MDL_MDY_CD = V_MDL_MDY_CD_3	 
					  AND LANG_CD = V_LANG_CD_3	 
					  AND WHOT_YMD = V_APL_YMD_3	 
					  AND DEL_YN = 'N'	 
					  /* 출고로 빠진 데이터만을 가져오도록 한다.	 */
					  AND DL_EXPD_WHOT_ST_CD = '01'	 
					  AND PRDN_PLNT_CD = IFNULL(V_PRDN_PLNT_CD_3, 'N');
				
					/*원래 0보다 작은 값은 존재하면 안된다. 그러나 현재 존재하고 있어서 아래와 같은 체크로직을 추가함	 */
					IF V_PREV_WHOT_QTY < 0 THEN
						SET V_PREV_WHOT_QTY = 0;
					END IF;	 
					 
					/*원래의 출고수량과 투입된 수량이 같으면 작업을 진행하지 않는다.	 */
					SET V_TRWI_DIFF = V_TRWI_QTY_3 - V_PREV_WHOT_QTY;	 
					 
					/*원래의 출고수량보다 투입수량이 많아진 경우	 */
					IF V_TRWI_DIFF > 0 THEN
							    CALL SP_UPDATE_PDI_IV_INFO1(V_QLTY_VEHL_CD_3,	 
												       V_MDL_MDY_CD_3,	 
												       V_LANG_CD_3,	 
								                       V_APL_YMD_3,	 
													   V_TRWI_DIFF,	 
							                           V_PRDN_PLNT_CD_3,
							                           EXPD_CO_CD
													   );
				
						    /*원래의 출고수량보다 투입수량이 적어진 경우	 */
					ELSEIF V_TRWI_DIFF < 0 THEN
								CALL SP_UPDATE_PDI_IV_INFO2(V_QLTY_VEHL_CD_3,	 
												       V_MDL_MDY_CD_3,	 
												       V_LANG_CD_3,	 
								                       V_APL_YMD_3,	 
													   V_TRWI_DIFF * (-1),	 
							                           V_PRDN_PLNT_CD_3,
							                           EXPD_CO_CD
													   );
					END IF;					   			
										   			
				END IF;	

	END LOOP JOBLOOP3 ;
	CLOSE PROD_MST_INFO;


    SET CURR_LOC_NUM = 8;

	OPEN PLNT_PROD_MST_INFO; /* cursor 열기 */
	JOBLOOP4 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_PROD_MST_INFO INTO V_QLTY_VEHL_CD_4,V_MDL_MDY_CD_4,V_LANG_CD_4,V_APL_YMD_4,V_PRDN_PLNT_CD_4,V_TRWI_QTY_4;
	IF endOfRow4 THEN
	 LEAVE JOBLOOP4 ;
	END IF;

			/*[추가] 2010.04.13.김동근 생산정보 현황 - 공장별 내역 저장 기능 추가	*/ 
				UPDATE TB_PLNT_PROD_MST_SUM_INFO	 
				SET PRDN_TRWI_QTY = V_TRWI_QTY_4,	 
				    PRDN_QTY = 0,	 
					PRDN_QTY2 = 0,	 
					PRDN_QTY3 = 0,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = V_APL_YMD_4	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_4	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_4	 
				AND LANG_CD = V_LANG_CD_4	 
				AND PRDN_PLNT_CD = IFNULL(V_PRDN_PLNT_CD_4, 'N');	

				SET V_EXCNT = 0;
				SELECT COUNT(APL_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PLNT_PROD_MST_SUM_INFO
				WHERE APL_YMD = V_APL_YMD_4	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_4	 
				AND MDL_MDY_CD = V_MDL_MDY_CD_4	 
				AND LANG_CD = V_LANG_CD_4	 
				AND PRDN_PLNT_CD = IFNULL(V_PRDN_PLNT_CD_4, 'N');

				IF V_EXCNT = 0 THEN
				   INSERT INTO TB_PLNT_PROD_MST_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					PRDN_TRWI_QTY,	 
					PRDN_QTY,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					PRDN_QTY2,	 
					PRDN_QTY3,	 
					PRDN_PLNT_CD	 
				   )	 
				   SELECT V_APL_YMD_4,	 
				          DATA_SN,	 
						  V_QLTY_VEHL_CD_4,	 
						  V_MDL_MDY_CD_4,	 
						  V_LANG_CD_4,	 
						  V_TRWI_QTY_4,	 
						  0,	 
						  SYSDATE(),	 
						  SYSDATE(),	 
						  0,	 
						  0,	 
						  IFNULL(V_PRDN_PLNT_CD_4,'N')	 
				   FROM TB_LANG_MGMT A	 
				   WHERE A.QLTY_VEHL_CD = V_QLTY_VEHL_CD_4	 
				   AND A.MDL_MDY_CD = V_MDL_MDY_CD_4	 
				   AND A.LANG_CD = V_LANG_CD_4;
				END IF;	 
	 	 
                /* 공장별 분리 후 각각 PDI재고에서 투입수량 빼주기 (AM, PS)  	*/
	 

	END LOOP JOBLOOP4 ;
	CLOSE PLNT_PROD_MST_INFO;


    SET CURR_LOC_NUM = 9;

	SET V_FROM_DATE = STR_TO_DATE(FROM_YMD, '%Y%m%d');	
	SET V_TO_DATE = STR_TO_DATE(TO_YMD, '%Y%m%d'); 
	SET V_DATE_CNT  = ROUND(V_TO_DATE - V_FROM_DATE);	

	SET i=0;
	JOBLOOP: LOOP
			
				SET V_CURR_DATE = DATE_ADD(V_FROM_DATE,INTERVAL i DAY);
				SET V_CURR_YMD = DATE_FORMAT(V_CURR_DATE, '%Y%m%d');
				/*로직변경... 하루 이전까지만 수행하지 않고 현재일까지 수행하도록 한다.	
				  생산마스터 생산 진행정보 업데이트	 */
				CALL SP_GET_PROD_MST_PROG_SUM(V_CURR_YMD, EXPD_CO_CD);	 
	 
				/*생산마스터정보 취합 작업 수행	 */
				CALL SP_GET_PROD_MST_SUM_DTL_KMC(V_CURR_YMD, V_CURR_YMD, EXPD_CO_CD);	 
	 
				/*재고 상세 내역 재 계산 작업 수행(생산마스터 정보 취합 후 작업이 수행되어야 한다.)	 
				  (반드시 세원재고 재계산 작업이 이루어진 후에 PDI 재고 데이터 재계산이 이루어 져야 한다.)	 */
				CALL SP_RECALCULATE_SEWON_IV_DTL2(V_CURR_YMD, EXPD_CO_CD);	 
				CALL SP_RECALCULATE_PDI_IV_DTL2(V_CURR_YMD, EXPD_CO_CD);	 
				SET i=i+1; 
				IF i=V_DATE_CNT THEN
					LEAVE JOBLOOP;
				END IF;
	END LOOP JOBLOOP;

    SET CURR_LOC_NUM = 10;

	/*END;
	DELIMITER;
	다음처리*/	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 11;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_SUM_DTL_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_SUM_DTL_HMC`(IN CURR_YMD VARCHAR(8),
                                        IN SRCH_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_SUM_DTL_HMC
 * Procedure 설명 : 화면에 표시되는 데이터의 형태로 생산마스터 정보를 취합하는 작업을 수행	
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 SRCH_YMD                   조회년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_SRCH_DATE	DATETIME;
	DECLARE V_PREV_YEAR_YMD		VARCHAR(8);
	DECLARE V_PREV_3MTH_YMD		VARCHAR(8);
	DECLARE V_PREV_1MTH_YMD		VARCHAR(8);
	DECLARE V_CURR_FSTD_YMD		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD1		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD2		VARCHAR(8);
	DECLARE V_PREV_1DAY_INCL_HLD_YMD2		VARCHAR(8);
	DECLARE V_PREV_2WEK_YMD		VARCHAR(8);
	DECLARE V_PREV_1WEK_YMD		VARCHAR(8);
	
	DECLARE V_DATA_SN_1	INT;
	DECLARE V_QLTY_VEHL_CD_1	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_1	INT;
	DECLARE V_TMM_TRWI_QTY_1	INT;
	DECLARE V_BOD_TRWI_QTY_1	INT;
	DECLARE V_BOD_TRWI_QTY_INCL_1	INT;
	DECLARE V_TDD_PRDN_QTY_1	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_1	INT; 
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_TDD_PRDN_QTY2_1	INT;
	DECLARE V_TDD_PRDN_QTY3_1	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_1	INT;
											
	DECLARE V_DATA_SN_2	INT;
	DECLARE V_QLTY_VEHL_CD_2	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2	VARCHAR(4);
	DECLARE V_LANG_CD_2	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_2	INT;
	DECLARE V_TMM_TRWI_QTY_2	INT;
	DECLARE V_BOD_TRWI_QTY_2	INT;
	DECLARE V_BOD_TRWI_QTY_INCL_2	INT;
	DECLARE V_TDD_PRDN_QTY_2	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_TDD_PRDN_QTY2_2	INT;
	DECLARE V_TDD_PRDN_QTY3_2	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_PRDN_PLNT_CD_2	VARCHAR(3);
	
	DECLARE V_EXCNT   INT;
	DECLARE V_EXCNT2   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PROD_MST_SUM_INFO CURSOR FOR
				   					 SELECT MAX(DATA_SN) AS DATA_SN,
									   		QLTY_VEHL_CD,
											MDL_MDY_CD,
											LANG_CD, 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY, 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,
											SUM(BOD_TRWI_QTY_INCL) AS BOD_TRWI_QTY_INCL,
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY
				   					 FROM (
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,
									   			    A.QLTY_VEHL_CD,
												    A.MDL_MDY_CD,
												    A.LANG_CD, 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
 
											 UNION ALL
											 
											 /*당월 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*전일 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.*/
											 AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*휴일 포함 기준 계산한 전일 투입수량 조회 */
                                             SELECT MAX(A.DATA_SN) AS DATA_SN,
                                                    A.QLTY_VEHL_CD,
                                                    A.MDL_MDY_CD,
                                                    A.LANG_CD, 
                                                    0 AS MTH3_MO_AVG_TRWI_QTY, 
                                                    0 AS TMM_TRWI_QTY,
                                                    0 AS BOD_TRWI_QTY,
                                                    SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY_INCL,
                                                    0 AS TDD_PRDN_QTY,
                                                    0 AS YER1_DLY_AVG_TRWI_QTY,
                                                    0 AS MTH3_DLY_AVG_TRWI_QTY,
                                                    0 AS WEK2_DLY_AVG_TRWI_QTY,
                                                    0 AS TDD_PRDN_QTY2,
                                                    0 AS TDD_PRDN_QTY3,
                                                    0 AS WEK1_DLY_AVG_TRWI_QTY
                                             FROM TB_PROD_MST_SUM_INFO A,
                                                  TB_VEHL_MGMT B
                                             WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
                                             AND A.MDL_MDY_CD = B.MDL_MDY_CD
                                             AND B.DL_EXPD_CO_CD = EXPD_CO_CD
                                             /*휴일 포함한 전일기준에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.*/
                                             AND A.APL_YMD BETWEEN V_PREV_1DAY_INCL_HLD_YMD2 AND V_PREV_1DAY_YMD1
                                             GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
                                             
                                             UNION ALL
											 
											 /*당일 생산(예정)수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD = SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*1년 일평균 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*2주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*1주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											) A
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY + A.BOD_TRWI_QTY_INCL +
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD;

									   

	DECLARE PLNT_MST_SUM_INFO CURSOR FOR
						             /*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 조회			*/	   
				   					 SELECT MAX(DATA_SN) AS DATA_SN,
									   		QLTY_VEHL_CD,
											MDL_MDY_CD,
											LANG_CD, 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY, 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,
											SUM(BOD_TRWI_QTY_INCL) AS BOD_TRWI_QTY_INCL,
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY,
											PRDN_PLNT_CD
				   					 FROM (
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,
									   			    A.QLTY_VEHL_CD,
												    A.MDL_MDY_CD,
												    A.LANG_CD, 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
 
											 UNION ALL
											 
											 /*당월 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*전일 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.*/
                                             AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
                                             /*휴일 포함 기준 계산한 전일 투입수량 조회 */
                                             SELECT MAX(A.DATA_SN) AS DATA_SN,
                                                    A.QLTY_VEHL_CD,
                                                    A.MDL_MDY_CD,
                                                    A.LANG_CD, 
                                                    0 AS MTH3_MO_AVG_TRWI_QTY, 
                                                    0 AS TMM_TRWI_QTY,
                                                    0 AS BOD_TRWI_QTY,
                                                    SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY_INCL,
                                                    0 AS TDD_PRDN_QTY,
                                                    0 AS YER1_DLY_AVG_TRWI_QTY,
                                                    0 AS MTH3_DLY_AVG_TRWI_QTY,
                                                    0 AS WEK2_DLY_AVG_TRWI_QTY,
                                                    0 AS TDD_PRDN_QTY2,
                                                    0 AS TDD_PRDN_QTY3,
                                                    0 AS WEK1_DLY_AVG_TRWI_QTY,
                                                    A.PRDN_PLNT_CD
                                             FROM TB_PLNT_PROD_MST_SUM_INFO A,
                                                  TB_VEHL_MGMT B
                                             WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
                                             AND A.MDL_MDY_CD = B.MDL_MDY_CD
                                             AND B.DL_EXPD_CO_CD = EXPD_CO_CD
                                             /*휴일 포함한 전일기준에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.   */                                 
                                             AND A.APL_YMD BETWEEN V_PREV_1DAY_INCL_HLD_YMD2 AND V_PREV_1DAY_YMD1
                                             GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
                                             
                                             UNION ALL
											 
											 /*당일 생산(예정)수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD = SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*1년 일평균 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*2주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*1주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											) A
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY + A.BOD_TRWI_QTY_INCL +
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, PRDN_PLNT_CD;



	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_SUM_DTL_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',SRCH_YMD:',IFNULL(SRCH_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_PREV_YEAR_YMD:',IFNULL(V_PREV_YEAR_YMD,'')
							,',V_PREV_3MTH_YMD:',IFNULL(V_PREV_3MTH_YMD,'')
							,',V_PREV_1MTH_YMD:',IFNULL(V_PREV_1MTH_YMD,'')
							,',V_CURR_FSTD_YMD:',IFNULL(V_CURR_FSTD_YMD,'')
							,',V_PREV_1DAY_YMD1:',IFNULL(V_PREV_1DAY_YMD1,'')
							,',V_PREV_1DAY_YMD2:',IFNULL(V_PREV_1DAY_YMD2,'')
							,',V_PREV_1DAY_INCL_HLD_YMD2:',IFNULL(V_PREV_1DAY_INCL_HLD_YMD2,'')
							,',V_PREV_2WEK_YMD:',IFNULL(V_PREV_2WEK_YMD,'')
							,',V_PREV_1WEK_YMD:',IFNULL(V_PREV_1WEK_YMD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_SRCH_DATE:',IFNULL(DATE_FORMAT(V_SRCH_DATE, '%Y%m%d'),'')
							,',V_DATA_SN_1:',IFNULL(CONCAT(V_DATA_SN_1),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_1),'')
							,',V_TMM_TRWI_QTY_1:',IFNULL(CONCAT(V_TMM_TRWI_QTY_1),'')
							,',V_BOD_TRWI_QTY_1:',IFNULL(CONCAT(V_BOD_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY_1),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_1),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_1),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY2_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_1),'')
							,',V_TDD_PRDN_QTY3_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_1),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_1),'')
							,',V_DATA_SN_2:',IFNULL(CONCAT(V_DATA_SN_2),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_2),'')
							,',V_TMM_TRWI_QTY_2:',IFNULL(CONCAT(V_TMM_TRWI_QTY_2),'')
							,',V_BOD_TRWI_QTY_2:',IFNULL(CONCAT(V_BOD_TRWI_QTY_2),'')
							,',V_BOD_TRWI_QTY_INCL_2:',IFNULL(CONCAT(V_BOD_TRWI_QTY_INCL_2),'')
							,',V_TDD_PRDN_QTY_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY_2),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_2),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_2),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_2),'')
							,',V_TDD_PRDN_QTY2_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_2),'')
							,',V_TDD_PRDN_QTY3_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_2),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_EXCNT2:',IFNULL(CONCAT(V_EXCNT2),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	

    SET CURR_LOC_NUM = 1;

	SET V_SRCH_DATE	= STR_TO_DATE(SRCH_YMD, '%Y%m%d');	     
	SET V_PREV_YEAR_YMD = CONCAT(DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -12 MONTH), '%Y%m'), '01');
	SET V_PREV_3MTH_YMD = CONCAT(DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -3 MONTH), '%Y%m'), '01');
	SET V_PREV_1MTH_YMD = DATE_FORMAT(LAST_DAY(DATE_ADD(V_SRCH_DATE, INTERVAL -1 MONTH)), '%Y%m%d');
	SET V_CURR_FSTD_YMD = CONCAT(DATE_FORMAT(V_SRCH_DATE, '%Y%m'), '01');
	SET V_PREV_1DAY_YMD1 = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 1 DAY), '%Y%m%d');
	/*영업일 기준 전일날짜*/
	SET V_PREV_1DAY_YMD2 = FU_GET_WRKDATE(SRCH_YMD, -1);
	/*휴일을 포함한 전일 날짜*/ 
	SET V_PREV_1DAY_INCL_HLD_YMD2 = FU_GET_PRV1DAY_INCL_HOLIDAY(SRCH_YMD);
	SET V_PREV_2WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 14 DAY), '%Y%m%d');
	SET V_PREV_1WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 7 DAY), '%Y%m%d');



			/*이미 입력되었던 항목이 있다면 초기화 해준 후 진행한다. 
			 [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된 내역만을 삭제해 주어야 한다. */
			UPDATE TB_APS_PROD_SUM_INFO A
			SET MTH3_MO_AVG_TRWI_QTY = 0,
			    TMM_TRWI_QTY = 0,
				BOD_TRWI_QTY = 0,
				TDD_PRDN_QTY = 0,
				YER1_DLY_AVG_TRWI_QTY = 0,
				MTH3_DLY_AVG_TRWI_QTY = 0,
				WEK2_DLY_AVG_TRWI_QTY = 0,
				TDD_PRDN_QTY2 = 0,
				TDD_PRDN_QTY3 = 0,
				WEK1_DLY_AVG_TRWI_QTY = 0,
				MDFY_DTM = SYSDATE()
			WHERE APL_YMD = CURR_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
			

    SET CURR_LOC_NUM = 2;

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 초기화  */
			UPDATE TB_PLNT_APS_PROD_SUM_INFO A
			SET MTH3_MO_AVG_TRWI_QTY = 0,
			    TMM_TRWI_QTY = 0,
				BOD_TRWI_QTY = 0,
				TDD_PRDN_QTY = 0,
				YER1_DLY_AVG_TRWI_QTY = 0,
				MTH3_DLY_AVG_TRWI_QTY = 0,
				WEK2_DLY_AVG_TRWI_QTY = 0,
				TDD_PRDN_QTY2 = 0,
				TDD_PRDN_QTY3 = 0,
				WEK1_DLY_AVG_TRWI_QTY = 0,
				MDFY_DTM = SYSDATE()
			WHERE APL_YMD = CURR_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;



    SET CURR_LOC_NUM = 3;

	OPEN PROD_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_SUM_INFO INTO V_DATA_SN_1,V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_MTH3_MO_AVG_TRWI_QTY_1,V_TMM_TRWI_QTY_1,V_BOD_TRWI_QTY_1,V_BOD_TRWI_QTY_INCL_1,V_TDD_PRDN_QTY_1,V_YER1_DLY_AVG_TRWI_QTY_1,V_MTH3_DLY_AVG_TRWI_QTY_1,V_WEK2_DLY_AVG_TRWI_QTY_1,V_TDD_PRDN_QTY2_1,V_TDD_PRDN_QTY3_1,V_WEK1_DLY_AVG_TRWI_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

				UPDATE TB_APS_PROD_SUM_INFO
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,
					BOD_TRWI_QTY = CASE 
					               WHEN V_BOD_TRWI_QTY_INCL_1 > 0 THEN V_BOD_TRWI_QTY_INCL_1
                                   ELSE V_BOD_TRWI_QTY_1 
                                   END,
					TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,
					MDFY_DTM = SYSDATE()
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_1;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_APS_PROD_SUM_INFO 
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_1;
				
				IF V_EXCNT = 0 THEN
				   
				   UPDATE TB_APS_PROD_SUM_INFO
					SET DATA_SN = V_DATA_SN_1,
						MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,
					    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,
                        BOD_TRWI_QTY = CASE 
                                       WHEN V_BOD_TRWI_QTY_INCL_1 > 0 THEN V_BOD_TRWI_QTY_INCL_1
                                       ELSE V_BOD_TRWI_QTY_1 
                                       END,
						TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,
						YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,
						MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,
						WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,
						TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,
						TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,
						WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,
						MDFY_DTM = SYSDATE()
					WHERE APL_YMD = CURR_YMD
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
						AND MDL_MDY_CD = V_MDL_MDY_CD_1
						AND LANG_CD = V_LANG_CD_1;
					
		   		   SELECT COUNT(APL_YMD)
		   		   INTO V_EXCNT2	 
		   		   FROM TB_APS_PROD_SUM_INFO 
					WHERE APL_YMD = CURR_YMD
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
						AND DATA_SN = V_DATA_SN_1;

					IF V_EXCNT2 = 0 THEN
	
					   INSERT INTO TB_APS_PROD_SUM_INFO
					   (APL_YMD,
					    DATA_SN,
						QLTY_VEHL_CD,
						MDL_MDY_CD,
						LANG_CD,
						MTH3_MO_AVG_TRWI_QTY,
						TMM_TRWI_QTY,
						BOD_TRWI_QTY,
						TDD_PRDN_QTY,
						YER1_DLY_AVG_TRWI_QTY,
						MTH3_DLY_AVG_TRWI_QTY,
						WEK2_DLY_AVG_TRWI_QTY,
						FRAM_DTM,
						MDFY_DTM,
						TDD_PRDN_QTY2,
						TDD_PRDN_QTY3,
						WEK1_DLY_AVG_TRWI_QTY
					   )
					   VALUES
					   (CURR_YMD,
					    V_DATA_SN_1,
						V_QLTY_VEHL_CD_1,
						V_MDL_MDY_CD_1,
						V_LANG_CD_1,
						V_MTH3_MO_AVG_TRWI_QTY_1,
						V_TMM_TRWI_QTY_1,
						CASE 
                                   WHEN V_BOD_TRWI_QTY_INCL_1 > 0 THEN V_BOD_TRWI_QTY_INCL_1
                                   ELSE V_BOD_TRWI_QTY_1 
                                   END,
						V_TDD_PRDN_QTY_1,
						V_YER1_DLY_AVG_TRWI_QTY_1,
						V_MTH3_DLY_AVG_TRWI_QTY_1,
						V_WEK2_DLY_AVG_TRWI_QTY_1,
						SYSDATE(),
						SYSDATE(),
						V_TDD_PRDN_QTY2_1,
						V_TDD_PRDN_QTY3_1,
						V_WEK1_DLY_AVG_TRWI_QTY_1
					   );
					END IF;
				END IF;


	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_SUM_INFO;


    SET CURR_LOC_NUM = 4;




	OPEN PLNT_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_MST_SUM_INFO INTO V_DATA_SN_2,V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_MTH3_MO_AVG_TRWI_QTY_2,V_TMM_TRWI_QTY_2,V_BOD_TRWI_QTY_2,V_BOD_TRWI_QTY_INCL_2,V_TDD_PRDN_QTY_2,V_YER1_DLY_AVG_TRWI_QTY_2,V_MTH3_DLY_AVG_TRWI_QTY_2,V_WEK2_DLY_AVG_TRWI_QTY_2,V_TDD_PRDN_QTY2_2,V_TDD_PRDN_QTY3_2,V_WEK1_DLY_AVG_TRWI_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 저장 기능 추가 */				
				UPDATE TB_PLNT_APS_PROD_SUM_INFO
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_2,
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_2,
                    BOD_TRWI_QTY = CASE 
                                   WHEN V_BOD_TRWI_QTY_INCL_2 > 0 THEN V_BOD_TRWI_QTY_INCL_2
                                   ELSE V_BOD_TRWI_QTY_2 
                                   END,					
                    TDD_PRDN_QTY = V_TDD_PRDN_QTY_2,
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_2,
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_2,
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_2,
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_2,
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_2,
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_2,
					MDFY_DTM = SYSDATE()
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_2
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_PLNT_APS_PROD_SUM_INFO 
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_2
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;
				
				IF V_EXCNT = 0 THEN
				   
				   INSERT INTO TB_PLNT_APS_PROD_SUM_INFO
				   (APL_YMD,
				    DATA_SN,
					QLTY_VEHL_CD,
					MDL_MDY_CD,
					LANG_CD,
					MTH3_MO_AVG_TRWI_QTY,
					TMM_TRWI_QTY,
					BOD_TRWI_QTY,
					TDD_PRDN_QTY,
					YER1_DLY_AVG_TRWI_QTY,
					MTH3_DLY_AVG_TRWI_QTY,
					WEK2_DLY_AVG_TRWI_QTY,
					FRAM_DTM,
					MDFY_DTM,
					TDD_PRDN_QTY2,
					TDD_PRDN_QTY3,
					WEK1_DLY_AVG_TRWI_QTY,
					PRDN_PLNT_CD
				   )
				   VALUES
				   (CURR_YMD,
				    V_DATA_SN_2,
					V_QLTY_VEHL_CD_2,
					V_MDL_MDY_CD_2,
					V_LANG_CD_2,
					V_MTH3_MO_AVG_TRWI_QTY_2,
					V_TMM_TRWI_QTY_2,
                    CASE 
                                   WHEN V_BOD_TRWI_QTY_INCL_2 > 0 THEN V_BOD_TRWI_QTY_INCL_2
                                   ELSE V_BOD_TRWI_QTY_2 
                                   END,					
                    V_TDD_PRDN_QTY_2,
					V_YER1_DLY_AVG_TRWI_QTY_2,
					V_MTH3_DLY_AVG_TRWI_QTY_2,
					V_WEK2_DLY_AVG_TRWI_QTY_2,
					SYSDATE(),
					SYSDATE(),
					V_TDD_PRDN_QTY2_2,
					V_TDD_PRDN_QTY3_2,
					V_WEK1_DLY_AVG_TRWI_QTY_2,
					V_PRDN_PLNT_CD_2
				   );
				END IF;

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_MST_SUM_INFO;


    SET CURR_LOC_NUM = 5;



	/*END;
	DELIMITER;
	다음처리*/


	COMMIT;


    SET CURR_LOC_NUM = 6;

	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_SUM_DTL_INFO_HMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_SUM_DTL_INFO_HMC`(IN CURR_YMD VARCHAR(8),
                                        IN SRCH_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_SUM_DTL_INFO_HMC
 * Procedure 설명 : 화면에 표시되는 데이터의 형태로 생산마스터 정보를 취합하는 작업을 수행	
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 SRCH_YMD                   조회년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_SRCH_DATE	DATETIME;
	DECLARE V_PREV_YEAR_YMD		VARCHAR(8);
	DECLARE V_PREV_3MTH_YMD		VARCHAR(8);
	DECLARE V_PREV_1MTH_YMD		VARCHAR(8);
	DECLARE V_CURR_FSTD_YMD		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD1		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD2		VARCHAR(8);
	DECLARE V_PREV_1DAY_INCL_HLD_YMD2		VARCHAR(8);
	DECLARE V_PREV_2WEK_YMD		VARCHAR(8);
	DECLARE V_PREV_1WEK_YMD		VARCHAR(8);
	
	DECLARE V_DATA_SN_1	INT;
	DECLARE V_QLTY_VEHL_CD_1	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_1	INT;
	DECLARE V_TMM_TRWI_QTY_1	INT;
	DECLARE V_BOD_TRWI_QTY_1	INT;
	DECLARE V_BOD_TRWI_QTY_INCL_1	INT;
	DECLARE V_TDD_PRDN_QTY_1	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_1	INT; 
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_TDD_PRDN_QTY2_1	INT;
	DECLARE V_TDD_PRDN_QTY3_1	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_1	INT;
											
	DECLARE V_DATA_SN_2	INT;
	DECLARE V_QLTY_VEHL_CD_2	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2	VARCHAR(4);
	DECLARE V_LANG_CD_2	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_2	INT;
	DECLARE V_TMM_TRWI_QTY_2	INT;
	DECLARE V_BOD_TRWI_QTY_2	INT;
	DECLARE V_BOD_TRWI_QTY_INCL_2	INT;
	DECLARE V_TDD_PRDN_QTY_2	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_TDD_PRDN_QTY2_2	INT;
	DECLARE V_TDD_PRDN_QTY3_2	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_PRDN_PLNT_CD_2	VARCHAR(3);
	
	DECLARE V_EXCNT   INT;
	DECLARE V_EXCNT2   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PROD_MST_SUM_INFO CURSOR FOR
				   					 SELECT MAX(DATA_SN) AS DATA_SN,
									   		QLTY_VEHL_CD,
											MDL_MDY_CD,
											LANG_CD, 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY, 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,
											SUM(BOD_TRWI_QTY_INCL) AS BOD_TRWI_QTY_INCL,
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY
				   					 FROM (
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,
									   			    A.QLTY_VEHL_CD,
												    A.MDL_MDY_CD,
												    A.LANG_CD, 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
 
											 UNION ALL
											 
											 /*당월 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*전일 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.*/
											 AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*휴일 포함 기준 계산한 전일 투입수량 조회 */
                                             SELECT MAX(A.DATA_SN) AS DATA_SN,
                                                    A.QLTY_VEHL_CD,
                                                    A.MDL_MDY_CD,
                                                    A.LANG_CD, 
                                                    0 AS MTH3_MO_AVG_TRWI_QTY, 
                                                    0 AS TMM_TRWI_QTY,
                                                    0 AS BOD_TRWI_QTY,
                                                    SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY_INCL,
                                                    0 AS TDD_PRDN_QTY,
                                                    0 AS YER1_DLY_AVG_TRWI_QTY,
                                                    0 AS MTH3_DLY_AVG_TRWI_QTY,
                                                    0 AS WEK2_DLY_AVG_TRWI_QTY,
                                                    0 AS TDD_PRDN_QTY2,
                                                    0 AS TDD_PRDN_QTY3,
                                                    0 AS WEK1_DLY_AVG_TRWI_QTY
                                             FROM TB_PROD_MST_SUM_INFO A,
                                                  TB_VEHL_MGMT B
                                             WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
                                             AND A.MDL_MDY_CD = B.MDL_MDY_CD
                                             AND B.DL_EXPD_CO_CD = EXPD_CO_CD
                                             /*휴일 포함한 전일기준에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.*/
                                             AND A.APL_YMD BETWEEN V_PREV_1DAY_INCL_HLD_YMD2 AND V_PREV_1DAY_YMD1
                                             GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
                                             
                                             UNION ALL
											 
											 /*당일 생산(예정)수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD = SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*1년 일평균 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*2주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											 UNION ALL
											 
											 /*1주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY
									   		 FROM TB_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD
											 
											) A
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY + A.BOD_TRWI_QTY_INCL +
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD;

									   

	DECLARE PLNT_MST_SUM_INFO CURSOR FOR
						             /*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 조회			*/	   
				   					 SELECT MAX(DATA_SN) AS DATA_SN,
									   		QLTY_VEHL_CD,
											MDL_MDY_CD,
											LANG_CD, 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY, 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,
											SUM(BOD_TRWI_QTY_INCL) AS BOD_TRWI_QTY_INCL,
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY,
											PRDN_PLNT_CD
				   					 FROM (
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,
									   			    A.QLTY_VEHL_CD,
												    A.MDL_MDY_CD,
												    A.LANG_CD, 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
													0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
 
											 UNION ALL
											 
											 /*당월 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*전일 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.*/
                                             AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
                                             /*휴일 포함 기준 계산한 전일 투입수량 조회 */
                                             SELECT MAX(A.DATA_SN) AS DATA_SN,
                                                    A.QLTY_VEHL_CD,
                                                    A.MDL_MDY_CD,
                                                    A.LANG_CD, 
                                                    0 AS MTH3_MO_AVG_TRWI_QTY, 
                                                    0 AS TMM_TRWI_QTY,
                                                    0 AS BOD_TRWI_QTY,
                                                    SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY_INCL,
                                                    0 AS TDD_PRDN_QTY,
                                                    0 AS YER1_DLY_AVG_TRWI_QTY,
                                                    0 AS MTH3_DLY_AVG_TRWI_QTY,
                                                    0 AS WEK2_DLY_AVG_TRWI_QTY,
                                                    0 AS TDD_PRDN_QTY2,
                                                    0 AS TDD_PRDN_QTY3,
                                                    0 AS WEK1_DLY_AVG_TRWI_QTY,
                                                    A.PRDN_PLNT_CD
                                             FROM TB_PLNT_PROD_MST_SUM_INFO A,
                                                  TB_VEHL_MGMT B
                                             WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
                                             AND A.MDL_MDY_CD = B.MDL_MDY_CD
                                             AND B.DL_EXPD_CO_CD = EXPD_CO_CD
                                             /*휴일 포함한 전일기준에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.   */                                 
                                             AND A.APL_YMD BETWEEN V_PREV_1DAY_INCL_HLD_YMD2 AND V_PREV_1DAY_YMD1
                                             GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
                                             
                                             UNION ALL
											 
											 /*당일 생산(예정)수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD = SRCH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*1년 일평균 투입수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*2주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													0 AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											 
											 UNION ALL
											 
											 /*1주 일평균 생산수량 조회 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,
									   				A.QLTY_VEHL_CD,
													A.MDL_MDY_CD,
													A.LANG_CD, 
									   				0 AS MTH3_MO_AVG_TRWI_QTY, 
													0 AS TMM_TRWI_QTY,
													0 AS BOD_TRWI_QTY,
												    0 AS BOD_TRWI_QTY_INCL,
													0 AS TDD_PRDN_QTY,
													0 AS YER1_DLY_AVG_TRWI_QTY,
													0 AS MTH3_DLY_AVG_TRWI_QTY,
													0 AS WEK2_DLY_AVG_TRWI_QTY,
													0 AS TDD_PRDN_QTY2,
													0 AS TDD_PRDN_QTY3,
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY,
													A.PRDN_PLNT_CD
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,
									   		      TB_VEHL_MGMT B
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											) A
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY + A.BOD_TRWI_QTY_INCL +
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, PRDN_PLNT_CD;



	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_SUM_DTL_HMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',SRCH_YMD:',IFNULL(SRCH_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_PREV_YEAR_YMD:',IFNULL(V_PREV_YEAR_YMD,'')
							,',V_PREV_3MTH_YMD:',IFNULL(V_PREV_3MTH_YMD,'')
							,',V_PREV_1MTH_YMD:',IFNULL(V_PREV_1MTH_YMD,'')
							,',V_CURR_FSTD_YMD:',IFNULL(V_CURR_FSTD_YMD,'')
							,',V_PREV_1DAY_YMD1:',IFNULL(V_PREV_1DAY_YMD1,'')
							,',V_PREV_1DAY_YMD2:',IFNULL(V_PREV_1DAY_YMD2,'')
							,',V_PREV_1DAY_INCL_HLD_YMD2:',IFNULL(V_PREV_1DAY_INCL_HLD_YMD2,'')
							,',V_PREV_2WEK_YMD:',IFNULL(V_PREV_2WEK_YMD,'')
							,',V_PREV_1WEK_YMD:',IFNULL(V_PREV_1WEK_YMD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_SRCH_DATE:',IFNULL(DATE_FORMAT(V_SRCH_DATE, '%Y%m%d'),'')
							,',V_DATA_SN_1:',IFNULL(CONCAT(V_DATA_SN_1),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_1),'')
							,',V_TMM_TRWI_QTY_1:',IFNULL(CONCAT(V_TMM_TRWI_QTY_1),'')
							,',V_BOD_TRWI_QTY_1:',IFNULL(CONCAT(V_BOD_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY_1),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_1),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_1),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY2_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_1),'')
							,',V_TDD_PRDN_QTY3_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_1),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_1),'')
							,',V_DATA_SN_2:',IFNULL(CONCAT(V_DATA_SN_2),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_2),'')
							,',V_TMM_TRWI_QTY_2:',IFNULL(CONCAT(V_TMM_TRWI_QTY_2),'')
							,',V_BOD_TRWI_QTY_2:',IFNULL(CONCAT(V_BOD_TRWI_QTY_2),'')
							,',V_BOD_TRWI_QTY_INCL_2:',IFNULL(CONCAT(V_BOD_TRWI_QTY_INCL_2),'')
							,',V_TDD_PRDN_QTY_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY_2),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_2),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_2),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_2),'')
							,',V_TDD_PRDN_QTY2_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_2),'')
							,',V_TDD_PRDN_QTY3_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_2),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_EXCNT2:',IFNULL(CONCAT(V_EXCNT2),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	

    SET CURR_LOC_NUM = 1;

	SET V_SRCH_DATE	= STR_TO_DATE(SRCH_YMD, '%Y%m%d');	     
	SET V_PREV_YEAR_YMD = CONCAT(DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -12 MONTH), '%Y%m'), '01');
	SET V_PREV_3MTH_YMD = CONCAT(DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -3 MONTH), '%Y%m'), '01');
	SET V_PREV_1MTH_YMD = DATE_FORMAT(LAST_DAY(DATE_ADD(V_SRCH_DATE, INTERVAL -1 MONTH)), '%Y%m%d');
	SET V_CURR_FSTD_YMD = CONCAT(DATE_FORMAT(V_SRCH_DATE, '%Y%m'), '01');
	SET V_PREV_1DAY_YMD1 = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 1 DAY), '%Y%m%d');
	/*영업일 기준 전일날짜*/
	SET V_PREV_1DAY_YMD2 = FU_GET_WRKDATE(SRCH_YMD, -1);
	/*휴일을 포함한 전일 날짜*/ 
	SET V_PREV_1DAY_INCL_HLD_YMD2 = FU_GET_PRV1DAY_INCL_HOLIDAY(SRCH_YMD);
	SET V_PREV_2WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 14 DAY), '%Y%m%d');
	SET V_PREV_1WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 7 DAY), '%Y%m%d');



			/*이미 입력되었던 항목이 있다면 초기화 해준 후 진행한다. 
			 [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된 내역만을 삭제해 주어야 한다. */
			UPDATE TB_APS_PROD_SUM_INFO A
			SET MTH3_MO_AVG_TRWI_QTY = 0,
			    TMM_TRWI_QTY = 0,
				BOD_TRWI_QTY = 0,
				TDD_PRDN_QTY = 0,
				YER1_DLY_AVG_TRWI_QTY = 0,
				MTH3_DLY_AVG_TRWI_QTY = 0,
				WEK2_DLY_AVG_TRWI_QTY = 0,
				TDD_PRDN_QTY2 = 0,
				TDD_PRDN_QTY3 = 0,
				WEK1_DLY_AVG_TRWI_QTY = 0,
				MDFY_DTM = SYSDATE()
			WHERE APL_YMD = CURR_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
			

    SET CURR_LOC_NUM = 2;

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 초기화  */
			UPDATE TB_PLNT_APS_PROD_SUM_INFO A
			SET MTH3_MO_AVG_TRWI_QTY = 0,
			    TMM_TRWI_QTY = 0,
				BOD_TRWI_QTY = 0,
				TDD_PRDN_QTY = 0,
				YER1_DLY_AVG_TRWI_QTY = 0,
				MTH3_DLY_AVG_TRWI_QTY = 0,
				WEK2_DLY_AVG_TRWI_QTY = 0,
				TDD_PRDN_QTY2 = 0,
				TDD_PRDN_QTY3 = 0,
				WEK1_DLY_AVG_TRWI_QTY = 0,
				MDFY_DTM = SYSDATE()
			WHERE APL_YMD = CURR_YMD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	 
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;



    SET CURR_LOC_NUM = 3;

	OPEN PROD_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_SUM_INFO INTO V_DATA_SN_1,V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_MTH3_MO_AVG_TRWI_QTY_1,V_TMM_TRWI_QTY_1,V_BOD_TRWI_QTY_1,V_BOD_TRWI_QTY_INCL_1,V_TDD_PRDN_QTY_1,V_YER1_DLY_AVG_TRWI_QTY_1,V_MTH3_DLY_AVG_TRWI_QTY_1,V_WEK2_DLY_AVG_TRWI_QTY_1,V_TDD_PRDN_QTY2_1,V_TDD_PRDN_QTY3_1,V_WEK1_DLY_AVG_TRWI_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

				UPDATE TB_APS_PROD_SUM_INFO
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,
					BOD_TRWI_QTY = CASE 
					               WHEN V_BOD_TRWI_QTY_INCL_1 > 0 THEN V_BOD_TRWI_QTY_INCL_1
                                   ELSE V_BOD_TRWI_QTY_1 
                                   END,
					TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,
					MDFY_DTM = SYSDATE()
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_1;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_APS_PROD_SUM_INFO 
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_1;
				
				IF V_EXCNT = 0 THEN
				   
				   UPDATE TB_APS_PROD_SUM_INFO
					SET DATA_SN = V_DATA_SN_1,
						MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,
					    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,
                        BOD_TRWI_QTY = CASE 
                                       WHEN V_BOD_TRWI_QTY_INCL_1 > 0 THEN V_BOD_TRWI_QTY_INCL_1
                                       ELSE V_BOD_TRWI_QTY_1 
                                       END,
						TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,
						YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,
						MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,
						WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,
						TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,
						TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,
						WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,
						MDFY_DTM = SYSDATE()
					WHERE APL_YMD = CURR_YMD
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
						AND MDL_MDY_CD = V_MDL_MDY_CD_1
						AND LANG_CD = V_LANG_CD_1;
					
		   		   SELECT COUNT(APL_YMD)
		   		   INTO V_EXCNT2	 
		   		   FROM TB_APS_PROD_SUM_INFO 
					WHERE APL_YMD = CURR_YMD
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
						AND DATA_SN = V_DATA_SN_1;

					IF V_EXCNT2 = 0 THEN
	
					   INSERT INTO TB_APS_PROD_SUM_INFO
					   (APL_YMD,
					    DATA_SN,
						QLTY_VEHL_CD,
						MDL_MDY_CD,
						LANG_CD,
						MTH3_MO_AVG_TRWI_QTY,
						TMM_TRWI_QTY,
						BOD_TRWI_QTY,
						TDD_PRDN_QTY,
						YER1_DLY_AVG_TRWI_QTY,
						MTH3_DLY_AVG_TRWI_QTY,
						WEK2_DLY_AVG_TRWI_QTY,
						FRAM_DTM,
						MDFY_DTM,
						TDD_PRDN_QTY2,
						TDD_PRDN_QTY3,
						WEK1_DLY_AVG_TRWI_QTY
					   )
					   VALUES
					   (CURR_YMD,
					    V_DATA_SN_1,
						V_QLTY_VEHL_CD_1,
						V_MDL_MDY_CD_1,
						V_LANG_CD_1,
						V_MTH3_MO_AVG_TRWI_QTY_1,
						V_TMM_TRWI_QTY_1,
						CASE 
                                   WHEN V_BOD_TRWI_QTY_INCL_1 > 0 THEN V_BOD_TRWI_QTY_INCL_1
                                   ELSE V_BOD_TRWI_QTY_1 
                                   END,
						V_TDD_PRDN_QTY_1,
						V_YER1_DLY_AVG_TRWI_QTY_1,
						V_MTH3_DLY_AVG_TRWI_QTY_1,
						V_WEK2_DLY_AVG_TRWI_QTY_1,
						SYSDATE(),
						SYSDATE(),
						V_TDD_PRDN_QTY2_1,
						V_TDD_PRDN_QTY3_1,
						V_WEK1_DLY_AVG_TRWI_QTY_1
					   );
					END IF;
				END IF;


	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_SUM_INFO;


    SET CURR_LOC_NUM = 4;




	OPEN PLNT_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_MST_SUM_INFO INTO V_DATA_SN_2,V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_MTH3_MO_AVG_TRWI_QTY_2,V_TMM_TRWI_QTY_2,V_BOD_TRWI_QTY_2,V_BOD_TRWI_QTY_INCL_2,V_TDD_PRDN_QTY_2,V_YER1_DLY_AVG_TRWI_QTY_2,V_MTH3_DLY_AVG_TRWI_QTY_2,V_WEK2_DLY_AVG_TRWI_QTY_2,V_TDD_PRDN_QTY2_2,V_TDD_PRDN_QTY3_2,V_WEK1_DLY_AVG_TRWI_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 저장 기능 추가 */				
				UPDATE TB_PLNT_APS_PROD_SUM_INFO
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_2,
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_2,
                    BOD_TRWI_QTY = CASE 
                                   WHEN V_BOD_TRWI_QTY_INCL_2 > 0 THEN V_BOD_TRWI_QTY_INCL_2
                                   ELSE V_BOD_TRWI_QTY_2 
                                   END,					
                    TDD_PRDN_QTY = V_TDD_PRDN_QTY_2,
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_2,
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_2,
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_2,
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_2,
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_2,
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_2,
					MDFY_DTM = SYSDATE()
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_2
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_PLNT_APS_PROD_SUM_INFO 
				WHERE APL_YMD = CURR_YMD
				AND DATA_SN = V_DATA_SN_2
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;
				
				IF V_EXCNT = 0 THEN
				   
				   INSERT INTO TB_PLNT_APS_PROD_SUM_INFO
				   (APL_YMD,
				    DATA_SN,
					QLTY_VEHL_CD,
					MDL_MDY_CD,
					LANG_CD,
					MTH3_MO_AVG_TRWI_QTY,
					TMM_TRWI_QTY,
					BOD_TRWI_QTY,
					TDD_PRDN_QTY,
					YER1_DLY_AVG_TRWI_QTY,
					MTH3_DLY_AVG_TRWI_QTY,
					WEK2_DLY_AVG_TRWI_QTY,
					FRAM_DTM,
					MDFY_DTM,
					TDD_PRDN_QTY2,
					TDD_PRDN_QTY3,
					WEK1_DLY_AVG_TRWI_QTY,
					PRDN_PLNT_CD
				   )
				   VALUES
				   (CURR_YMD,
				    V_DATA_SN_2,
					V_QLTY_VEHL_CD_2,
					V_MDL_MDY_CD_2,
					V_LANG_CD_2,
					V_MTH3_MO_AVG_TRWI_QTY_2,
					V_TMM_TRWI_QTY_2,
                    CASE 
                                   WHEN V_BOD_TRWI_QTY_INCL_2 > 0 THEN V_BOD_TRWI_QTY_INCL_2
                                   ELSE V_BOD_TRWI_QTY_2 
                                   END,					
                    V_TDD_PRDN_QTY_2,
					V_YER1_DLY_AVG_TRWI_QTY_2,
					V_MTH3_DLY_AVG_TRWI_QTY_2,
					V_WEK2_DLY_AVG_TRWI_QTY_2,
					SYSDATE(),
					SYSDATE(),
					V_TDD_PRDN_QTY2_2,
					V_TDD_PRDN_QTY3_2,
					V_WEK1_DLY_AVG_TRWI_QTY_2,
					V_PRDN_PLNT_CD_2
				   );
				END IF;

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_MST_SUM_INFO;


    SET CURR_LOC_NUM = 5;



	/*END;
	DELIMITER;
	다음처리*/


	COMMIT;


    SET CURR_LOC_NUM = 6;

   
   
   
   
   
  /* 
SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD
FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD='01'

SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD
FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD='02'

SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD
FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD NOT IN ('01','02')
   */
   
   
   
   
   
   
   
   
	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_SUM_DTL_INFO_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_SUM_DTL_INFO_KMC`(IN CURR_YMD VARCHAR(8),
                                        IN SRCH_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN	
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_SUM_DTL_INFO_KMC
 * Procedure 설명 : 화면에 표시되는 데이터의 형태로 생산마스터 정보를 취합하는 작업을 수행	
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 SRCH_YMD                   조회년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_SRCH_DATE		DATETIME;
	DECLARE V_PREV_YEAR_YMD		VARCHAR(8);
	DECLARE V_PREV_3MTH_YMD		VARCHAR(8);
	DECLARE V_CURR_FSTD_YMD		VARCHAR(8);
	DECLARE V_PREV_1MTH_YMD		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD1		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD2		VARCHAR(8);
	DECLARE V_PREV_2WEK_YMD		VARCHAR(8);
	DECLARE V_PREV_1WEK_YMD		VARCHAR(8);
	
	DECLARE V_DATA_SN_1	INT;
	DECLARE V_QLTY_VEHL_CD_1	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_1	INT;
	DECLARE V_TMM_TRWI_QTY_1	INT;
	DECLARE V_BOD_TRWI_QTY_1	INT;
	DECLARE V_TDD_PRDN_QTY_1	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_1	INT; 
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_TDD_PRDN_QTY2_1	INT;
	DECLARE V_TDD_PRDN_QTY3_1	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_1	INT;
											
	DECLARE V_DATA_SN_2	INT;
	DECLARE V_QLTY_VEHL_CD_2	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2	VARCHAR(4);
	DECLARE V_LANG_CD_2	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_2	INT;
	DECLARE V_TMM_TRWI_QTY_2	INT;
	DECLARE V_BOD_TRWI_QTY_2	INT;
	DECLARE V_TDD_PRDN_QTY_2	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_TDD_PRDN_QTY2_2	INT;
	DECLARE V_TDD_PRDN_QTY3_2	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_PRDN_PLNT_CD_2	VARCHAR(3);
	
	DECLARE V_EXCNT   INT;
	DECLARE V_EXCNT2   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	/* BEGIN */
	DECLARE PROD_MST_SUM_INFO CURSOR FOR
				   					 SELECT MAX(DATA_SN) AS DATA_SN,	 
									   		QLTY_VEHL_CD,	 
											MDL_MDY_CD,	 
											LANG_CD,	 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY,	 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,	 
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,	 
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,	 
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,	 
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,	 
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,	 
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY	 
				   					 FROM (	 
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회	 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			    A.QLTY_VEHL_CD,	 
												    A.MDL_MDY_CD,	 
												    A.LANG_CD,	 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD	 
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*당월 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*전일 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.	 */
											 AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*당일 생산(예정)수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,	 
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD = SRCH_YMD	 
											 /*현재 진행 수량은 실제 전일 날짜의 데이터를 가져온다.	 */	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*1년 일평균 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													/*ROUND(SUM(PRDN_TRWI_QTY) / 365 + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 */
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*2주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*1주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
											) A	 
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY +	 
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +	 
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0	 
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD;
	 
	 

	DECLARE PLNT_MST_SUM_INFO CURSOR FOR
									/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 조회	 */
				   					 SELECT MAX(DATA_SN) AS DATA_SN,	 
									   		QLTY_VEHL_CD,	 
											MDL_MDY_CD,	 
											LANG_CD,	 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY,	 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,	 
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,	 
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,	 
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,	 
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,	 
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,	 
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY,	 
											PRDN_PLNT_CD	  
				   					 FROM (	 
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회	 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			    A.QLTY_VEHL_CD,	 
												    A.MDL_MDY_CD,	 
												    A.LANG_CD,	 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD	 
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*당월 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*전일 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.	 */
											 AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*당일 생산(예정)수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,	 
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD = SRCH_YMD	 
											 /*현재 진행 수량은 실제 전일 날짜의 데이터를 가져온다.	 */	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*1년 일평균 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													/*ROUND(SUM(PRDN_TRWI_QTY) / 365 + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 */
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*2주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*1주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											) A	 
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY +	 
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +	 
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0	 
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, PRDN_PLNT_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =true,endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_SUM_DTL_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',SRCH_YMD:',IFNULL(SRCH_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_PREV_YEAR_YMD:',IFNULL(V_PREV_YEAR_YMD,'')
							,',V_PREV_3MTH_YMD:',IFNULL(V_PREV_3MTH_YMD,'')
							,',V_CURR_FSTD_YMD:',IFNULL(V_CURR_FSTD_YMD,'')
							,',V_PREV_1MTH_YMD:',IFNULL(V_PREV_1MTH_YMD,'')
							,',V_PREV_1DAY_YMD1:',IFNULL(V_PREV_1DAY_YMD1,'')
							,',V_PREV_1DAY_YMD2:',IFNULL(V_PREV_1DAY_YMD2,'')
							,',V_PREV_2WEK_YMD:',IFNULL(V_PREV_2WEK_YMD,'')
							,',V_PREV_1WEK_YMD:',IFNULL(V_PREV_1WEK_YMD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_SRCH_DATE:',IFNULL(DATE_FORMAT(V_SRCH_DATE, '%Y%m%d'),'')
							,',V_DATA_SN_1:',IFNULL(CONCAT(V_DATA_SN_1),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_1),'')
							,',V_TMM_TRWI_QTY_1:',IFNULL(CONCAT(V_TMM_TRWI_QTY_1),'')
							,',V_BOD_TRWI_QTY_1:',IFNULL(CONCAT(V_BOD_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY_1),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_1),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_1),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY2_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_1),'')
							,',V_TDD_PRDN_QTY3_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_1),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_1),'')
							,',V_DATA_SN_2:',IFNULL(CONCAT(V_DATA_SN_2),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_2),'')
							,',V_TMM_TRWI_QTY_2:',IFNULL(CONCAT(V_TMM_TRWI_QTY_2),'')
							,',V_BOD_TRWI_QTY_2:',IFNULL(CONCAT(V_BOD_TRWI_QTY_2),'')
							,',V_TDD_PRDN_QTY_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY_2),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_2),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_2),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_2),'')
							,',V_TDD_PRDN_QTY2_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_2),'')
							,',V_TDD_PRDN_QTY3_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_2),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_EXCNT2:',IFNULL(CONCAT(V_EXCNT2),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

	
	SET V_SRCH_DATE	= STR_TO_DATE(SRCH_YMD, '%Y%m%d');
	SET V_PREV_YEAR_YMD = CONCAT( DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -12 MONTH), '%Y%m'), '01');
	SET V_PREV_3MTH_YMD = CONCAT( DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -3 MONTH), '%Y%m'), '01');	 
	SET V_PREV_1MTH_YMD = DATE_FORMAT(LAST_DAY(DATE_ADD(V_SRCH_DATE, INTERVAL -1 MONTH)), '%Y%m%d');	 
	SET V_CURR_FSTD_YMD = CONCAT(DATE_FORMAT(V_SRCH_DATE, '%Y%m'), '01');
	SET V_PREV_1DAY_YMD1 = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 1 DAY), '%Y%m%d');
	SET V_PREV_1DAY_YMD2 = FU_GET_WRKDATE(SRCH_YMD, -1);
	SET V_PREV_2WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 14 DAY), '%Y%m%d');
	SET V_PREV_1WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 7 DAY), '%Y%m%d');

			/*이미 입력되었던 항목이 있다면 초기화 해준 후 진행한다.	 
			 [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된	 
			        내역만을 삭제해 주어야 한다.	*/ 
			UPDATE TB_APS_PROD_SUM_INFO A	 
			SET MTH3_MO_AVG_TRWI_QTY = 0,	 
			    TMM_TRWI_QTY = 0,	 
				BOD_TRWI_QTY = 0,	 
				TDD_PRDN_QTY = 0,	 
				YER1_DLY_AVG_TRWI_QTY = 0,	 
				MTH3_DLY_AVG_TRWI_QTY = 0,	 
				WEK2_DLY_AVG_TRWI_QTY = 0,	 
				TDD_PRDN_QTY2 = 0,	 
				TDD_PRDN_QTY3 = 0,	 
				WEK1_DLY_AVG_TRWI_QTY = 0,	 
				MDFY_DTM = SYSDATE()	 
			WHERE APL_YMD = CURR_YMD	
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 2;

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 초기화	 */
			UPDATE TB_PLNT_APS_PROD_SUM_INFO A	 
			SET MTH3_MO_AVG_TRWI_QTY = 0,	 
			    TMM_TRWI_QTY = 0,	 
				BOD_TRWI_QTY = 0,	 
				TDD_PRDN_QTY = 0,	 
				YER1_DLY_AVG_TRWI_QTY = 0,	 
				MTH3_DLY_AVG_TRWI_QTY = 0,	 
				WEK2_DLY_AVG_TRWI_QTY = 0,	 
				TDD_PRDN_QTY2 = 0,	 
				TDD_PRDN_QTY3 = 0,	 
				WEK1_DLY_AVG_TRWI_QTY = 0,	 
				MDFY_DTM = SYSDATE()	 
			WHERE APL_YMD = CURR_YMD	
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;



    SET CURR_LOC_NUM = 3;

	OPEN PROD_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_SUM_INFO INTO V_DATA_SN_1,V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_MTH3_MO_AVG_TRWI_QTY_1,V_TMM_TRWI_QTY_1,V_BOD_TRWI_QTY_1,V_TDD_PRDN_QTY_1,V_YER1_DLY_AVG_TRWI_QTY_1,V_MTH3_DLY_AVG_TRWI_QTY_1,V_WEK2_DLY_AVG_TRWI_QTY_1,V_TDD_PRDN_QTY2_1,V_TDD_PRDN_QTY3_1,V_WEK1_DLY_AVG_TRWI_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;					
				 
				CALL WRITE_BATCH_EXE_LOG('GET_PROD_MST_SUM_DTL', SYSDATE(), 'S', CONCAT('DATA_SN : [' , V_DATA_SN_1 , '], APL_YMD : [' , CURR_YMD , '], QLTY_VEHL_CD : [' , V_QLTY_VEHL_CD_1 , '], MDL_MDY_CD : [' , V_MDL_MDY_CD_1 , '], LANG_CD : [' , V_LANG_CD_1 , ']'));
	 
				UPDATE TB_APS_PROD_SUM_INFO	 
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,	 
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,	 
					BOD_TRWI_QTY = V_BOD_TRWI_QTY_1,	 
					TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,	 
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,	 
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,	 
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,	 
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,	 
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,	 
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_APS_PROD_SUM_INFO 
			   WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;
					 
				IF V_EXCNT = 0 THEN	 
	 
					UPDATE TB_APS_PROD_SUM_INFO	 
					SET DATA_SN = V_DATA_SN_1,	 
						MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,	 
					    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,	 
						BOD_TRWI_QTY = V_BOD_TRWI_QTY_1,	 
						TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,	 
						YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,	 
						MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,	 
						WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,	 
						TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,	 
						TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,	 
						WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,	 
						MDFY_DTM = SYSDATE()	 
					WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
						AND LANG_CD = V_LANG_CD_1;
						 
				   SET V_EXCNT2 = 0;

				   SELECT COUNT(APL_YMD)
				   INTO V_EXCNT2	 
				   FROM TB_APS_PROD_SUM_INFO 
				   WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND DATA_SN = V_DATA_SN_1;

					IF V_EXCNT2 = 0 THEN
					   INSERT INTO TB_APS_PROD_SUM_INFO	 
					   (APL_YMD,	 
					    DATA_SN,	 
						QLTY_VEHL_CD,	 
						MDL_MDY_CD,	 
						LANG_CD,	 
						MTH3_MO_AVG_TRWI_QTY,	 
						TMM_TRWI_QTY,	 
						BOD_TRWI_QTY,	 
						TDD_PRDN_QTY,	 
						YER1_DLY_AVG_TRWI_QTY,	 
						MTH3_DLY_AVG_TRWI_QTY,	 
						WEK2_DLY_AVG_TRWI_QTY,	 
						FRAM_DTM,	 
						MDFY_DTM,	 
						TDD_PRDN_QTY2,	 
						TDD_PRDN_QTY3,	 
						WEK1_DLY_AVG_TRWI_QTY	 
					   )	 
					   VALUES	 
					   (CURR_YMD,	 
					    V_DATA_SN_1,	 
						V_QLTY_VEHL_CD_1,	 
						V_MDL_MDY_CD_1,	 
						V_LANG_CD_1,	 
						V_MTH3_MO_AVG_TRWI_QTY_1,	 
						V_TMM_TRWI_QTY_1,	 
						V_BOD_TRWI_QTY_1,	 
						V_TDD_PRDN_QTY_1,	 
						V_YER1_DLY_AVG_TRWI_QTY_1,	 
						V_MTH3_DLY_AVG_TRWI_QTY_1,	 
						V_WEK2_DLY_AVG_TRWI_QTY_1,	 
						SYSDATE(),	 
						SYSDATE(),	 
						V_TDD_PRDN_QTY2_1,	 
						V_TDD_PRDN_QTY3_1,	 
						V_WEK1_DLY_AVG_TRWI_QTY_1	 
					   );
					END IF;
				END IF;	 
	  

	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_SUM_INFO;


    SET CURR_LOC_NUM = 4;



	OPEN PLNT_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_MST_SUM_INFO INTO V_DATA_SN_2,V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_MTH3_MO_AVG_TRWI_QTY_2,V_TMM_TRWI_QTY_2,V_BOD_TRWI_QTY_2,V_TDD_PRDN_QTY_2,V_YER1_DLY_AVG_TRWI_QTY_2,V_MTH3_DLY_AVG_TRWI_QTY_2,V_WEK2_DLY_AVG_TRWI_QTY_2,V_TDD_PRDN_QTY2_2,V_TDD_PRDN_QTY3_2,V_WEK1_DLY_AVG_TRWI_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;
			

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 저장 기능 추가	 */	 
				UPDATE TB_PLNT_APS_PROD_SUM_INFO	 
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_2,	 
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_2,	 
					BOD_TRWI_QTY = V_BOD_TRWI_QTY_2,	 
					TDD_PRDN_QTY = V_TDD_PRDN_QTY_2,	 
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_2,	 
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_2,	 
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_2,	 
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_2,	 
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_2,	 
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_2,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_PLNT_APS_PROD_SUM_INFO 
			   WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				IF V_EXCNT = 0 THEN
				   INSERT INTO TB_PLNT_APS_PROD_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					MTH3_MO_AVG_TRWI_QTY,	 
					TMM_TRWI_QTY,	 
					BOD_TRWI_QTY,	 
					TDD_PRDN_QTY,	 
					YER1_DLY_AVG_TRWI_QTY,	 
					MTH3_DLY_AVG_TRWI_QTY,	 
					WEK2_DLY_AVG_TRWI_QTY,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					TDD_PRDN_QTY2,	 
					TDD_PRDN_QTY3,	 
					WEK1_DLY_AVG_TRWI_QTY,	 
					PRDN_PLNT_CD	 
				   )	 
				   VALUES	 
				   (CURR_YMD,	 
				    V_DATA_SN_2,	 
					V_QLTY_VEHL_CD_2,	 
					V_MDL_MDY_CD_2,	 
					V_LANG_CD_2,	 
					V_MTH3_MO_AVG_TRWI_QTY_2,	 
					V_TMM_TRWI_QTY_2,	 
					V_BOD_TRWI_QTY_2,	 
					V_TDD_PRDN_QTY_2,	 
					V_YER1_DLY_AVG_TRWI_QTY_2,	 
					V_MTH3_DLY_AVG_TRWI_QTY_2,	 
					V_WEK2_DLY_AVG_TRWI_QTY_2,	 
					SYSDATE(),	 
					SYSDATE(),	 
					V_TDD_PRDN_QTY2_2,	 
					V_TDD_PRDN_QTY3_2,	 
					V_WEK1_DLY_AVG_TRWI_QTY_2,	 
					V_PRDN_PLNT_CD_2	 
				   );	 
	 
				END IF;	 

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_MST_SUM_INFO;
	
	 

    SET CURR_LOC_NUM = 5;




	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;


    SET CURR_LOC_NUM = 6;

   
   
   
  /* 
SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD
FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD='01'

SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD
FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD='02'

SELECT DISTINCT QLTY_VEHL_CD, MDL_MDY_CD
FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD NOT IN ('01','02')
   */
   
   
   
   
END//
DELIMITER ;

-- 프로시저 hkomms.SP_GET_PROD_MST_SUM_DTL_KMC 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GET_PROD_MST_SUM_DTL_KMC`(IN CURR_YMD VARCHAR(8),
                                        IN SRCH_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN	
/***************************************************************************
 * Procedure 명칭 : SP_GET_PROD_MST_SUM_DTL_KMC
 * Procedure 설명 : 화면에 표시되는 데이터의 형태로 생산마스터 정보를 취합하는 작업을 수행	
 * 입력 파라미터    :  CURR_YMD                   현재년월일
 *                 SRCH_YMD                   조회년월일
 *                 EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_SRCH_DATE		DATETIME;
	DECLARE V_PREV_YEAR_YMD		VARCHAR(8);
	DECLARE V_PREV_3MTH_YMD		VARCHAR(8);
	DECLARE V_CURR_FSTD_YMD		VARCHAR(8);
	DECLARE V_PREV_1MTH_YMD		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD1		VARCHAR(8);
	DECLARE V_PREV_1DAY_YMD2		VARCHAR(8);
	DECLARE V_PREV_2WEK_YMD		VARCHAR(8);
	DECLARE V_PREV_1WEK_YMD		VARCHAR(8);
	
	DECLARE V_DATA_SN_1	INT;
	DECLARE V_QLTY_VEHL_CD_1	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_1	INT;
	DECLARE V_TMM_TRWI_QTY_1	INT;
	DECLARE V_BOD_TRWI_QTY_1	INT;
	DECLARE V_TDD_PRDN_QTY_1	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_1	INT; 
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_1	INT;
	DECLARE V_TDD_PRDN_QTY2_1	INT;
	DECLARE V_TDD_PRDN_QTY3_1	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_1	INT;
											
	DECLARE V_DATA_SN_2	INT;
	DECLARE V_QLTY_VEHL_CD_2	VARCHAR(4);
	DECLARE V_MDL_MDY_CD_2	VARCHAR(4);
	DECLARE V_LANG_CD_2	VARCHAR(3);
	DECLARE V_MTH3_MO_AVG_TRWI_QTY_2	INT;
	DECLARE V_TMM_TRWI_QTY_2	INT;
	DECLARE V_BOD_TRWI_QTY_2	INT;
	DECLARE V_TDD_PRDN_QTY_2	INT;
	DECLARE V_YER1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_MTH3_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_WEK2_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_TDD_PRDN_QTY2_2	INT;
	DECLARE V_TDD_PRDN_QTY3_2	INT;
	DECLARE V_WEK1_DLY_AVG_TRWI_QTY_2	INT;
	DECLARE V_PRDN_PLNT_CD_2	VARCHAR(3);
	
	DECLARE V_EXCNT   INT;
	DECLARE V_EXCNT2   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	/* BEGIN */
	DECLARE PROD_MST_SUM_INFO CURSOR FOR
				   					 SELECT MAX(DATA_SN) AS DATA_SN,	 
									   		QLTY_VEHL_CD,	 
											MDL_MDY_CD,	 
											LANG_CD,	 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY,	 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,	 
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,	 
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,	 
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,	 
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,	 
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,	 
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY	 
				   					 FROM (	 
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회	 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			    A.QLTY_VEHL_CD,	 
												    A.MDL_MDY_CD,	 
												    A.LANG_CD,	 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD	 
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*당월 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*전일 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.	 */
											 AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*당일 생산(예정)수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,	 
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD = SRCH_YMD	 
											 /*현재 진행 수량은 실제 전일 날짜의 데이터를 가져온다.	 */	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*1년 일평균 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													/*ROUND(SUM(PRDN_TRWI_QTY) / 365 + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 */
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*2주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
	 
											 UNION ALL	 
	 
											 /*1주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY	 
									   		 FROM TB_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD	 
											) A	 
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY +	 
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +	 
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0	 
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD;
	 
	 

	DECLARE PLNT_MST_SUM_INFO CURSOR FOR
									/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 조회	 */
				   					 SELECT MAX(DATA_SN) AS DATA_SN,	 
									   		QLTY_VEHL_CD,	 
											MDL_MDY_CD,	 
											LANG_CD,	 
									   		SUM(MTH3_MO_AVG_TRWI_QTY) AS MTH3_MO_AVG_TRWI_QTY,	 
											SUM(TMM_TRWI_QTY) AS TMM_TRWI_QTY,	 
											SUM(BOD_TRWI_QTY) AS BOD_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY) AS TDD_PRDN_QTY,	 
											SUM(YER1_DLY_AVG_TRWI_QTY) AS YER1_DLY_AVG_TRWI_QTY,	 
											SUM(MTH3_DLY_AVG_TRWI_QTY) AS MTH3_DLY_AVG_TRWI_QTY,	 
											SUM(WEK2_DLY_AVG_TRWI_QTY) AS WEK2_DLY_AVG_TRWI_QTY,	 
											SUM(TDD_PRDN_QTY2) AS TDD_PRDN_QTY2,	 
											SUM(TDD_PRDN_QTY3) AS TDD_PRDN_QTY3,	 
											SUM(WEK1_DLY_AVG_TRWI_QTY) AS WEK1_DLY_AVG_TRWI_QTY,	 
											PRDN_PLNT_CD	  
				   					 FROM (	 
									   	     /*3개월 월평균 투입수량, 3개월 일평균 투입수량 조회	 */
									   	     SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   			    A.QLTY_VEHL_CD,	 
												    A.MDL_MDY_CD,	 
												    A.LANG_CD,	 
									   				ROUND(SUM(A.PRDN_TRWI_QTY) / 3) AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_3MTH_YMD AND V_PREV_1MTH_YMD	 
                                 			 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*당월 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_CURR_FSTD_YMD AND SRCH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*전일 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													SUM(A.PRDN_TRWI_QTY) AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 /*영업일기준(토,일 제외) 전일에서 실제날짜의 전일까지의 수량을 합해서 표시해 준다.	 */
											 AND A.APL_YMD BETWEEN V_PREV_1DAY_YMD2 AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*당일 생산(예정)수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													SUM(A.PRDN_QTY) AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													SUM(A.PRDN_QTY2) AS TDD_PRDN_QTY2,	 
													SUM(A.PRDN_QTY3) AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD = SRCH_YMD	 
											 /*현재 진행 수량은 실제 전일 날짜의 데이터를 가져온다.	 */	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*1년 일평균 투입수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													/*ROUND(SUM(PRDN_TRWI_QTY) / 365 + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 */
													ROUND(AVG(PRDN_TRWI_QTY) + 1.96 + STDDEV(PRDN_TRWI_QTY)) AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_YEAR_YMD AND V_PREV_1MTH_YMD	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*2주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													0 AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_2WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD	 
	 
											 UNION ALL	 
	 
											 /*1주 일평균 생산수량 조회	 */
											 SELECT MAX(A.DATA_SN) AS DATA_SN,	 
									   				A.QLTY_VEHL_CD,	 
													A.MDL_MDY_CD,	 
													A.LANG_CD,	 
									   				0 AS MTH3_MO_AVG_TRWI_QTY,	 
													0 AS TMM_TRWI_QTY,	 
													0 AS BOD_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY,	 
													0 AS YER1_DLY_AVG_TRWI_QTY,	 
													0 AS MTH3_DLY_AVG_TRWI_QTY,	 
													0 AS WEK2_DLY_AVG_TRWI_QTY,	 
													0 AS TDD_PRDN_QTY2,	 
													0 AS TDD_PRDN_QTY3,	 
													ROUND(AVG(PRDN_TRWI_QTY)) AS WEK1_DLY_AVG_TRWI_QTY,	 
													A.PRDN_PLNT_CD	 
									   		 FROM TB_PLNT_PROD_MST_SUM_INFO A,	 
									   		      TB_VEHL_MGMT B	 
											 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											 AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
											 AND B.DL_EXPD_CO_CD = EXPD_CO_CD	 
											 AND A.APL_YMD BETWEEN V_PREV_1WEK_YMD AND V_PREV_1DAY_YMD1	 
											 GROUP BY A.QLTY_VEHL_CD, A.MDL_MDY_CD, A.LANG_CD, A.PRDN_PLNT_CD
											) A	 
									   WHERE A.MTH3_MO_AVG_TRWI_QTY + A.TMM_TRWI_QTY + A.BOD_TRWI_QTY +	 
									         A.TDD_PRDN_QTY + A.YER1_DLY_AVG_TRWI_QTY + A.MTH3_DLY_AVG_TRWI_QTY +	 
											 A.WEK2_DLY_AVG_TRWI_QTY + A.TDD_PRDN_QTY2 + A.TDD_PRDN_QTY3 + WEK1_DLY_AVG_TRWI_QTY > 0	 
									   GROUP BY QLTY_VEHL_CD, MDL_MDY_CD, LANG_CD, PRDN_PLNT_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =true,endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GET_PROD_MST_SUM_DTL_KMC',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',CURR_YMD:',IFNULL(CURR_YMD,'')
							,',SRCH_YMD:',IFNULL(SRCH_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_PREV_YEAR_YMD:',IFNULL(V_PREV_YEAR_YMD,'')
							,',V_PREV_3MTH_YMD:',IFNULL(V_PREV_3MTH_YMD,'')
							,',V_CURR_FSTD_YMD:',IFNULL(V_CURR_FSTD_YMD,'')
							,',V_PREV_1MTH_YMD:',IFNULL(V_PREV_1MTH_YMD,'')
							,',V_PREV_1DAY_YMD1:',IFNULL(V_PREV_1DAY_YMD1,'')
							,',V_PREV_1DAY_YMD2:',IFNULL(V_PREV_1DAY_YMD2,'')
							,',V_PREV_2WEK_YMD:',IFNULL(V_PREV_2WEK_YMD,'')
							,',V_PREV_1WEK_YMD:',IFNULL(V_PREV_1WEK_YMD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_MDL_MDY_CD_2:',IFNULL(V_MDL_MDY_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',V_SRCH_DATE:',IFNULL(DATE_FORMAT(V_SRCH_DATE, '%Y%m%d'),'')
							,',V_DATA_SN_1:',IFNULL(CONCAT(V_DATA_SN_1),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_1),'')
							,',V_TMM_TRWI_QTY_1:',IFNULL(CONCAT(V_TMM_TRWI_QTY_1),'')
							,',V_BOD_TRWI_QTY_1:',IFNULL(CONCAT(V_BOD_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY_1),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_1),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_1),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_1),'')
							,',V_TDD_PRDN_QTY2_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_1),'')
							,',V_TDD_PRDN_QTY3_1:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_1),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_1:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_1),'')
							,',V_DATA_SN_2:',IFNULL(CONCAT(V_DATA_SN_2),'')
							,',V_MTH3_MO_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_MO_AVG_TRWI_QTY_2),'')
							,',V_TMM_TRWI_QTY_2:',IFNULL(CONCAT(V_TMM_TRWI_QTY_2),'')
							,',V_BOD_TRWI_QTY_2:',IFNULL(CONCAT(V_BOD_TRWI_QTY_2),'')
							,',V_TDD_PRDN_QTY_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY_2),'')
							,',V_YER1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_YER1_DLY_AVG_TRWI_QTY_2),'')
							,',V_MTH3_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_MTH3_DLY_AVG_TRWI_QTY_2),'')
							,',V_WEK2_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK2_DLY_AVG_TRWI_QTY_2),'')
							,',V_TDD_PRDN_QTY2_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY2_2),'')
							,',V_TDD_PRDN_QTY3_2:',IFNULL(CONCAT(V_TDD_PRDN_QTY3_2),'')
							,',V_WEK1_DLY_AVG_TRWI_QTY_2:',IFNULL(CONCAT(V_WEK1_DLY_AVG_TRWI_QTY_2),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_EXCNT2:',IFNULL(CONCAT(V_EXCNT2),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

	
	SET V_SRCH_DATE	= STR_TO_DATE(SRCH_YMD, '%Y%m%d');
	SET V_PREV_YEAR_YMD = CONCAT( DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -12 MONTH), '%Y%m'), '01');
	SET V_PREV_3MTH_YMD = CONCAT( DATE_FORMAT(DATE_ADD(V_SRCH_DATE, INTERVAL -3 MONTH), '%Y%m'), '01');	 
	SET V_PREV_1MTH_YMD = DATE_FORMAT(LAST_DAY(DATE_ADD(V_SRCH_DATE, INTERVAL -1 MONTH)), '%Y%m%d');	 
	SET V_CURR_FSTD_YMD = CONCAT(DATE_FORMAT(V_SRCH_DATE, '%Y%m'), '01');
	SET V_PREV_1DAY_YMD1 = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 1 DAY), '%Y%m%d');
	SET V_PREV_1DAY_YMD2 = FU_GET_WRKDATE(SRCH_YMD, -1);
	SET V_PREV_2WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 14 DAY), '%Y%m%d');
	SET V_PREV_1WEK_YMD = DATE_FORMAT(DATE_SUB(V_SRCH_DATE, INTERVAL 7 DAY), '%Y%m%d');

			/*이미 입력되었던 항목이 있다면 초기화 해준 후 진행한다.	 
			 [참고] 회사구분이 존재하지 않으므로 아래와 같이 차종이 회사에 소속된	 
			        내역만을 삭제해 주어야 한다.	*/ 
			UPDATE TB_APS_PROD_SUM_INFO A	 
			SET MTH3_MO_AVG_TRWI_QTY = 0,	 
			    TMM_TRWI_QTY = 0,	 
				BOD_TRWI_QTY = 0,	 
				TDD_PRDN_QTY = 0,	 
				YER1_DLY_AVG_TRWI_QTY = 0,	 
				MTH3_DLY_AVG_TRWI_QTY = 0,	 
				WEK2_DLY_AVG_TRWI_QTY = 0,	 
				TDD_PRDN_QTY2 = 0,	 
				TDD_PRDN_QTY3 = 0,	 
				WEK1_DLY_AVG_TRWI_QTY = 0,	 
				MDFY_DTM = SYSDATE()	 
			WHERE APL_YMD = CURR_YMD	
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 2;

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 초기화	 */
			UPDATE TB_PLNT_APS_PROD_SUM_INFO A	 
			SET MTH3_MO_AVG_TRWI_QTY = 0,	 
			    TMM_TRWI_QTY = 0,	 
				BOD_TRWI_QTY = 0,	 
				TDD_PRDN_QTY = 0,	 
				YER1_DLY_AVG_TRWI_QTY = 0,	 
				MTH3_DLY_AVG_TRWI_QTY = 0,	 
				WEK2_DLY_AVG_TRWI_QTY = 0,	 
				TDD_PRDN_QTY2 = 0,	 
				TDD_PRDN_QTY3 = 0,	 
				WEK1_DLY_AVG_TRWI_QTY = 0,	 
				MDFY_DTM = SYSDATE()	 
			WHERE APL_YMD = CURR_YMD	
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
                        FROM TB_VEHL_MGMT C	 
			            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD	
			            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;



    SET CURR_LOC_NUM = 3;

	OPEN PROD_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_SUM_INFO INTO V_DATA_SN_1,V_QLTY_VEHL_CD_1,V_MDL_MDY_CD_1,V_LANG_CD_1,V_MTH3_MO_AVG_TRWI_QTY_1,V_TMM_TRWI_QTY_1,V_BOD_TRWI_QTY_1,V_TDD_PRDN_QTY_1,V_YER1_DLY_AVG_TRWI_QTY_1,V_MTH3_DLY_AVG_TRWI_QTY_1,V_WEK2_DLY_AVG_TRWI_QTY_1,V_TDD_PRDN_QTY2_1,V_TDD_PRDN_QTY3_1,V_WEK1_DLY_AVG_TRWI_QTY_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;					
				 
				CALL WRITE_BATCH_EXE_LOG('GET_PROD_MST_SUM_DTL', SYSDATE(), 'S', CONCAT('DATA_SN : [' , V_DATA_SN_1 , '], APL_YMD : [' , CURR_YMD , '], QLTY_VEHL_CD : [' , V_QLTY_VEHL_CD_1 , '], MDL_MDY_CD : [' , V_MDL_MDY_CD_1 , '], LANG_CD : [' , V_LANG_CD_1 , ']'));
	 
				UPDATE TB_APS_PROD_SUM_INFO	 
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,	 
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,	 
					BOD_TRWI_QTY = V_BOD_TRWI_QTY_1,	 
					TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,	 
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,	 
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,	 
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,	 
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,	 
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,	 
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_APS_PROD_SUM_INFO 
			   WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_1;
					 
				IF V_EXCNT = 0 THEN	 
	 
					UPDATE TB_APS_PROD_SUM_INFO	 
					SET DATA_SN = V_DATA_SN_1,	 
						MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_1,	 
					    TMM_TRWI_QTY = V_TMM_TRWI_QTY_1,	 
						BOD_TRWI_QTY = V_BOD_TRWI_QTY_1,	 
						TDD_PRDN_QTY = V_TDD_PRDN_QTY_1,	 
						YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_1,	 
						MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_1,	 
						WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_1,	 
						TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_1,	 
						TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_1,	 
						WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_1,	 
						MDFY_DTM = SYSDATE()	 
					WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND MDL_MDY_CD = V_MDL_MDY_CD_1	 
						AND LANG_CD = V_LANG_CD_1;
						 
				   SET V_EXCNT2 = 0;

				   SELECT COUNT(APL_YMD)
				   INTO V_EXCNT2	 
				   FROM TB_APS_PROD_SUM_INFO 
				   WHERE APL_YMD = CURR_YMD	 
						AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
						AND DATA_SN = V_DATA_SN_1;

					IF V_EXCNT2 = 0 THEN
					   INSERT INTO TB_APS_PROD_SUM_INFO	 
					   (APL_YMD,	 
					    DATA_SN,	 
						QLTY_VEHL_CD,	 
						MDL_MDY_CD,	 
						LANG_CD,	 
						MTH3_MO_AVG_TRWI_QTY,	 
						TMM_TRWI_QTY,	 
						BOD_TRWI_QTY,	 
						TDD_PRDN_QTY,	 
						YER1_DLY_AVG_TRWI_QTY,	 
						MTH3_DLY_AVG_TRWI_QTY,	 
						WEK2_DLY_AVG_TRWI_QTY,	 
						FRAM_DTM,	 
						MDFY_DTM,	 
						TDD_PRDN_QTY2,	 
						TDD_PRDN_QTY3,	 
						WEK1_DLY_AVG_TRWI_QTY	 
					   )	 
					   VALUES	 
					   (CURR_YMD,	 
					    V_DATA_SN_1,	 
						V_QLTY_VEHL_CD_1,	 
						V_MDL_MDY_CD_1,	 
						V_LANG_CD_1,	 
						V_MTH3_MO_AVG_TRWI_QTY_1,	 
						V_TMM_TRWI_QTY_1,	 
						V_BOD_TRWI_QTY_1,	 
						V_TDD_PRDN_QTY_1,	 
						V_YER1_DLY_AVG_TRWI_QTY_1,	 
						V_MTH3_DLY_AVG_TRWI_QTY_1,	 
						V_WEK2_DLY_AVG_TRWI_QTY_1,	 
						SYSDATE(),	 
						SYSDATE(),	 
						V_TDD_PRDN_QTY2_1,	 
						V_TDD_PRDN_QTY3_1,	 
						V_WEK1_DLY_AVG_TRWI_QTY_1	 
					   );
					END IF;
				END IF;	 
	  

	END LOOP JOBLOOP1 ;
	CLOSE PROD_MST_SUM_INFO;


    SET CURR_LOC_NUM = 4;



	OPEN PLNT_MST_SUM_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PLNT_MST_SUM_INFO INTO V_DATA_SN_2,V_QLTY_VEHL_CD_2,V_MDL_MDY_CD_2,V_LANG_CD_2,V_MTH3_MO_AVG_TRWI_QTY_2,V_TMM_TRWI_QTY_2,V_BOD_TRWI_QTY_2,V_TDD_PRDN_QTY_2,V_YER1_DLY_AVG_TRWI_QTY_2,V_MTH3_DLY_AVG_TRWI_QTY_2,V_WEK2_DLY_AVG_TRWI_QTY_2,V_TDD_PRDN_QTY2_2,V_TDD_PRDN_QTY3_2,V_WEK1_DLY_AVG_TRWI_QTY_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;
			

			/*[추가] 2010.04.14.김동근 생산정보 현황 - 공장별 Summary 내역 저장 기능 추가	 */	 
				UPDATE TB_PLNT_APS_PROD_SUM_INFO	 
				SET MTH3_MO_AVG_TRWI_QTY = V_MTH3_MO_AVG_TRWI_QTY_2,	 
				    TMM_TRWI_QTY = V_TMM_TRWI_QTY_2,	 
					BOD_TRWI_QTY = V_BOD_TRWI_QTY_2,	 
					TDD_PRDN_QTY = V_TDD_PRDN_QTY_2,	 
					YER1_DLY_AVG_TRWI_QTY = V_YER1_DLY_AVG_TRWI_QTY_2,	 
					MTH3_DLY_AVG_TRWI_QTY = V_MTH3_DLY_AVG_TRWI_QTY_2,	 
					WEK2_DLY_AVG_TRWI_QTY = V_WEK2_DLY_AVG_TRWI_QTY_2,	 
					TDD_PRDN_QTY2 = V_TDD_PRDN_QTY2_2,	 
					TDD_PRDN_QTY3 = V_TDD_PRDN_QTY3_2,	 
					WEK1_DLY_AVG_TRWI_QTY = V_WEK1_DLY_AVG_TRWI_QTY_2,	 
					MDFY_DTM = SYSDATE()	 
				WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(APL_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_PLNT_APS_PROD_SUM_INFO 
			   WHERE APL_YMD = CURR_YMD	 
				AND DATA_SN = V_DATA_SN_2	 
				AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_2;

				IF V_EXCNT = 0 THEN
				   INSERT INTO TB_PLNT_APS_PROD_SUM_INFO	 
				   (APL_YMD,	 
				    DATA_SN,	 
					QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					MTH3_MO_AVG_TRWI_QTY,	 
					TMM_TRWI_QTY,	 
					BOD_TRWI_QTY,	 
					TDD_PRDN_QTY,	 
					YER1_DLY_AVG_TRWI_QTY,	 
					MTH3_DLY_AVG_TRWI_QTY,	 
					WEK2_DLY_AVG_TRWI_QTY,	 
					FRAM_DTM,	 
					MDFY_DTM,	 
					TDD_PRDN_QTY2,	 
					TDD_PRDN_QTY3,	 
					WEK1_DLY_AVG_TRWI_QTY,	 
					PRDN_PLNT_CD	 
				   )	 
				   VALUES	 
				   (CURR_YMD,	 
				    V_DATA_SN_2,	 
					V_QLTY_VEHL_CD_2,	 
					V_MDL_MDY_CD_2,	 
					V_LANG_CD_2,	 
					V_MTH3_MO_AVG_TRWI_QTY_2,	 
					V_TMM_TRWI_QTY_2,	 
					V_BOD_TRWI_QTY_2,	 
					V_TDD_PRDN_QTY_2,	 
					V_YER1_DLY_AVG_TRWI_QTY_2,	 
					V_MTH3_DLY_AVG_TRWI_QTY_2,	 
					V_WEK2_DLY_AVG_TRWI_QTY_2,	 
					SYSDATE(),	 
					SYSDATE(),	 
					V_TDD_PRDN_QTY2_2,	 
					V_TDD_PRDN_QTY3_2,	 
					V_WEK1_DLY_AVG_TRWI_QTY_2,	 
					V_PRDN_PLNT_CD_2	 
				   );	 
	 
				END IF;	 

	END LOOP JOBLOOP2 ;
	CLOSE PLNT_MST_SUM_INFO;
	
	 

    SET CURR_LOC_NUM = 5;




	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;


    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_GLOVIS_WHSN_INFO_BATCH 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_GLOVIS_WHSN_INFO_BATCH`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_GLOVIS_WHSN_INFO_BATCH
 * Procedure 설명 : 글로비스 자동 입고 처리 배치 작업
 * 입력 파라미터    :  P_EXPD_CO_CD                  회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD_1		VARCHAR(8);
	DECLARE V_DL_EXPD_MDL_MDY_CD_1  VARCHAR(8);
	DECLARE V_LANG_CD_1				VARCHAR(8);
	DECLARE V_N_PRNT_PBCN_NO_1		VARCHAR(100);
	DECLARE V_DTL_SN_1				INT;
	DECLARE V_MDL_MDY_CD_1			VARCHAR(8);
	DECLARE V_DL_EXPD_WHSN_ST_CD_1  VARCHAR(8);
	DECLARE V_DL_EXPD_BOX_QTY_1		INT;
	DECLARE V_WHSN_QTY_1			INT;
	DECLARE V_DEEI1_QTY_1			INT;
	DECLARE V_USER_EENO_1			VARCHAR(8);
	DECLARE V_PRDN_PLNT_CD_1		VARCHAR(8);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE SEWON_WHOT_LIST CURSOR FOR
								   SELECT QLTY_VEHL_CD,	 
	   	 						   		  DL_EXPD_MDL_MDY_CD,	 
	   									  LANG_CD,	 
	   									  N_PRNT_PBCN_NO,	 
	   									  DTL_SN,	 
	   									  MDL_MDY_CD,	 
	   									  '01' AS DL_EXPD_WHSN_ST_CD,	 
	   									  IFNULL(DL_EXPD_BOX_QTY, 0) AS DL_EXPD_BOX_QTY,	 
	   									  RQ_QTY AS WHSN_QTY,	 
	   									  0 AS DEEI1_QTY,	 
	   									  'SYSTEM' AS USER_EENO,	 
	   									  PRDN_PLNT_CD  
								   FROM TB_SEWON_WHOT_INFO	 
								   WHERE DL_EXPD_RQ_SCN_CD = '01'	 
								   AND CMPL_YN = 'N'	 
								   AND DEL_YN  = 'N'	 
								   AND LANG_CD = 'KO';	 


	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_GLOVIS_WHSN_INFO_BATCH',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,'')
							,',V_MDL_MDY_CD_1:',IFNULL(V_MDL_MDY_CD_1,'')
							,',V_DL_EXPD_WHSN_ST_CD_1:',IFNULL(V_DL_EXPD_WHSN_ST_CD_1,'')
							,',V_USER_EENO_1:',IFNULL(V_USER_EENO_1,'')
							,',V_PRDN_PLNT_CD_1:',IFNULL(V_PRDN_PLNT_CD_1,'')
							,',V_DTL_SN_1:',IFNULL(CONCAT(V_DTL_SN_1),'')
							,',V_DL_EXPD_BOX_QTY_1:',IFNULL(CONCAT(V_DL_EXPD_BOX_QTY_1),'')
							,',V_WHSN_QTY_1:',IFNULL(CONCAT(V_WHSN_QTY_1),'')
							,',V_DEEI1_QTY_1:',IFNULL(CONCAT(V_DEEI1_QTY_1),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

	OPEN SEWON_WHOT_LIST; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_WHOT_LIST INTO V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1,V_N_PRNT_PBCN_NO_1,V_DTL_SN_1,V_MDL_MDY_CD_1,V_DL_EXPD_WHSN_ST_CD_1,V_DL_EXPD_BOX_QTY_1,V_WHSN_QTY_1,V_DEEI1_QTY_1,V_USER_EENO_1,V_PRDN_PLNT_CD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
					 
				CALL SP_PDI_WHSN_INFO_SAVE(V_QLTY_VEHL_CD_1, 	 
	   			 					  V_MDL_MDY_CD_1,	 
								      V_LANG_CD_1,	 
									  V_DL_EXPD_MDL_MDY_CD_1,	 
								      V_N_PRNT_PBCN_NO_1,	 
								      V_DTL_SN_1,	 
								      V_DL_EXPD_WHSN_ST_CD_1,	 
								      V_DL_EXPD_BOX_QTY_1,	 
								      V_WHSN_QTY_1,	 
								      V_DEEI1_QTY_1,	 
								      V_USER_EENO_1,	 
								      V_PRDN_PLNT_CD_1, 
								      P_EXPD_CO_CD
								      );

	END LOOP JOBLOOP1 ;
	CLOSE SEWON_WHOT_LIST;
	 

    SET CURR_LOC_NUM = 2;

			/*	 
	EXCEPTION	 
		     WHEN OTHERS THEN	 
			     ROLLBACK;	 

	/*END;
	DELIMITER;
	다음처리*/
/*
	COMMIT;
	    */
END//
DELIMITER ;

-- 프로시저 hkomms.SP_NATL_VEHL_LANG_UPDATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_NATL_VEHL_LANG_UPDATE`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_NATL_VEHL_LANG_UPDATE
 * Procedure 설명 : 국가별 언어코드에는 추가되어 있으나, 국가별 차종코드에는 추가되어 있지 않은 경우 데이터 업데이트 처리
 * 입력 파라미터    :  P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_NATL_VEHL_LANG_UPDATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

		BEGIN
				/* 국가별 언어코드에는 추가되어있으나, 국가별 차종코드에는 추가되지 않은 경우 처리 */
				INSERT INTO TB_NATL_VEHL_MGMT (
					 DL_EXPD_CO_CD
					,DL_EXPD_NAT_CD
					,QLTY_VEHL_CD
					,DL_EXPD_REGN_CD
					,PPRR_EENO
					,FRAM_DTM
					,UPDR_EENO
					,MDFY_DTM
					)
				SELECT
					DISTINCT
					  A.DL_EXPD_CO_CD
					, A.DL_EXPD_NAT_CD
					, A.QLTY_VEHL_CD
					, C.DL_EXPD_REGN_CD
					, 'SYSTEM'
					, SYSDATE()
					, 'SYSTEM'
					, SYSDATE()
				FROM TB_NATL_LANG_MGMT A
				LEFT OUTER JOIN TB_NATL_VEHL_MGMT B ON A.QLTY_VEHL_CD = B.QLTY_VEHL_CD AND A.DL_EXPD_NAT_CD = B.DL_EXPD_NAT_CD
				INNER JOIN TB_NATL_MGMT C ON A.DL_EXPD_CO_CD = C.DL_EXPD_CO_CD AND A.DL_EXPD_NAT_CD = C.DL_EXPD_NAT_CD
				WHERE B.QLTY_VEHL_CD IS NULL;
			
			COMMIT;
		END;
		

    SET CURR_LOC_NUM = 2;

		BEGIN
				/* 국가코드관리에서는 국가별 차종/언어 설정이 추가되어 있으나 
				   언어코드 관리 화면에 차종별 언어 설정이 없는 경우 추가 처리 */
				INSERT INTO TB_LANG_MGMT (
					 DATA_SN,
					 QLTY_VEHL_CD,
					 MDL_MDY_CD,
					 LANG_CD,
					 DL_EXPD_REGN_CD,
					 LANG_CD_NM,
					 USE_YN,
					 NAPC_YN,
					 PPRR_EENO,
					 FRAM_DTM,
					 UPDR_EENO,
					 MDFY_DTM,
					 SORT_SN,
					 A_CODE,
					 N1_INS_YN,
					 ET_YN
					)			    
				  SELECT
						ROWNM+DATA_SN DATA_SN,
						QLTY_VEHL_CD,
						MDL_MDY_CD,
						LANG_CD,
						DL_EXPD_REGN_CD,
						LANG_CD_NM,
						USE_YN,
						NAPC_YN,
						PPRR_EENO,
						FRAM_DTM,
						UPDR_EENO,
						MDFY_DTM,
						SORT_SN,
						A_CODE,
						N1_INS_YN,
						ET_YN
				  FROM
					(SELECT
						A.DATA_SN,
						QLTY_VEHL_CD,
						MDL_MDY_CD,
						LANG_CD,
						DL_EXPD_REGN_CD,
						LANG_CD_NM,
						USE_YN,
						NAPC_YN,
						PPRR_EENO,
						FRAM_DTM,
						UPDR_EENO,
						MDFY_DTM,
						SORT_SN,
						A_CODE,
						N1_INS_YN,
						ET_YN,
						(SELECT COUNT(K.DATA_SN) 
						   FROM TB_LANG_MGMT K 
						  WHERE K.QLTY_VEHL_CD = A.QLTY_VEHL_CD 
							AND K.MDL_MDY_CD = A.MDL_MDY_CD 
							AND K.LANG_CD = A.LANG_CD) AS EXCNT,
						ROW_NUMBER() OVER() AS ROWNM
					FROM (
						SELECT
							DISTINCT
							(SELECT IFNULL(MAX(DATA_SN), 0) FROM TB_LANG_MGMT) DATA_SN,
							A.QLTY_VEHL_CD,
							A.MDL_MDY_CD,
							A.LANG_CD,
							D.DL_EXPD_REGN_CD,
							D.LANG_CD_NM,
							'Y' USE_YN,
							'N' NAPC_YN,
							'SYSTEM' PPRR_EENO,
							SYSDATE() FRAM_DTM,
							NULL UPDR_EENO,
							NULL MDFY_DTM,
							NULL SORT_SN,
							NULL A_CODE,
							'N' N1_INS_YN,
							NULL ET_YN
						FROM TB_NATL_LANG_MGMT A
						LEFT OUTER JOIN TB_LANG_MGMT B ON (A.QLTY_VEHL_CD = B.QLTY_VEHL_CD AND A.MDL_MDY_CD = B.MDL_MDY_CD AND A.LANG_CD = B.LANG_CD)
						INNER JOIN TB_NATL_MGMT C ON (A.DL_EXPD_CO_CD = C.DL_EXPD_CO_CD AND A.DL_EXPD_NAT_CD = C.DL_EXPD_NAT_CD)
						INNER JOIN TB_LANG_MAST D ON (A.LANG_CD = D.LANG_CD)
						WHERE B.QLTY_VEHL_CD IS NULL
							AND A.MDL_MDY_CD >= SUBSTR(DATE_FORMAT(DATE_SUB(SYSDATE(), INTERVAL 2 YEAR), '%Y'),3,2)
						) A
				  ) T
				  WHERE T.EXCNT=0;
			

    SET CURR_LOC_NUM = 3;

			COMMIT;
		END;

    SET CURR_LOC_NUM = 4;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_PDI_IV_INFO_BATCH 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_PDI_IV_INFO_BATCH`()
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_PDI_IV_INFO_BATCH
 * Procedure 설명 : PDI 재고정보 일배치 정리작업 수행
 *                 반드시 현재일 시작시간에 돌려야 한다. 
 *                 전일의 재고내역을 기반으로 재고상세 내역을 다시 생성하는 방식
 *                 배치 작업이 도는 시점에 입고확인이 이루어 질수 있으므로 그것을 체크해 주기 위해서 로직이 추가됨	 
 *                 배치 작업이 도는 시점에 입고된 내역이 없음
 *                 전일의 재고내역을 기반으로 재고상세 내역을 다시 생성하는 방식의 경우 
 *                 재고상세 테이블에 취급설명서연식과 같은 차종연식으로 데이터를 신규입력하여 준다.
 *                 (왜냐하면 연식 연계 관계에서 취급설명서 연식과 연계된 차종 연식에는 취급설명서 연식과 동일한 차종연식은 반드시 있기 때문이다.) 
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_CLS_YMD		VARCHAR(8);
	DECLARE V_PREV_CLS_YMD		VARCHAR(8);
	DECLARE V_QTY				INT;
	DECLARE V_CNT				INT;
	DECLARE STRT_DATE				DATETIME;
	
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO_1 VARCHAR(100);
	DECLARE V_IV_QTY_1 INT;
	DECLARE V_PRDN_PLNT_CD_1 VARCHAR(3);
									   
	DECLARE V_QLTY_VEHL_CD_2 VARCHAR(4);
	DECLARE V_LANG_CD_2 VARCHAR(3);
	DECLARE V_PRDN_PLNT_CD_2 VARCHAR(3);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);
	DECLARE BTCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_INFO CURSOR FOR
		 					   SELECT QLTY_VEHL_CD,	 
		 					  	 	  DL_EXPD_MDL_MDY_CD,	 
									  LANG_CD,	 
									  N_PRNT_PBCN_NO,	 
									  IV_QTY,	 
									  PRDN_PLNT_CD
		 					   FROM TB_PDI_IV_INFO	 
							   WHERE CLS_YMD = V_PREV_CLS_YMD	 
							   AND IV_QTY > 0;

	DECLARE PDI_IV_DTL_INFO CURSOR FOR
		 /*전일의 재고내역을 기반으로 재고상세 내역을 다시 생성하는 방식 */ 	 
		 						   SELECT QLTY_VEHL_CD,	 
		 						  	 	  LANG_CD,	 
		 						  	 	  PRDN_PLNT_CD
		 						   FROM TB_PDI_IV_INFO	 
								   WHERE CLS_YMD = V_PREV_CLS_YMD	 
								   AND IV_QTY > 0 	 
								   GROUP BY QLTY_VEHL_CD, LANG_CD, PRDN_PLNT_CD 
								   ORDER BY QLTY_VEHL_CD, LANG_CD;	

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_PDI_IV_INFO_BATCH',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',V_CURR_CLS_YMD:',IFNULL(V_CURR_CLS_YMD,'')
							,',V_PREV_CLS_YMD:',IFNULL(V_PREV_CLS_YMD,'')
							,',BTCH_USER_EENO:',IFNULL(BTCH_USER_EENO,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,'')
							,',V_PRDN_PLNT_CD_1:',IFNULL(V_PRDN_PLNT_CD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),'')
							,',V_QTY:',IFNULL(CONCAT(V_QTY),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_IV_QTY_1:',IFNULL(CONCAT(V_IV_QTY_1),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';
    SET BTCH_USER_EENO = V_BATCH_USER_EENO; /* 배치작업 담당자 코드 	 */

	SET V_CURR_CLS_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d');	 
	SET V_PREV_CLS_YMD = DATE_FORMAT(DATE_SUB(SYSDATE(), INTERVAL 1 DAY), '%Y%m%d');

	SET STRT_DATE  = SYSDATE();


    SET CURR_LOC_NUM = 2;

	OPEN PDI_IV_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_INFO INTO V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1,V_N_PRNT_PBCN_NO_1,V_IV_QTY_1,V_PRDN_PLNT_CD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
								   
                /* 배치 작업이 도는 시점에 입고확인이 이루어 질수 있으므로	 
                   그것을 체크해 주기 위해서 로직이 추가됨	  */
                SELECT COUNT(*)	 
                INTO V_CNT	 
                FROM TB_PDI_IV_INFO	 
                WHERE CLS_YMD = V_CURR_CLS_YMD	 
                AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
                AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
                AND LANG_CD = V_LANG_CD_1	 
                AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
                AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_1;
                	 
                /*배치 작업이 도는 시점에 입고된 내역이 없음	  */
                IF V_CNT = 0 THEN
                    INSERT INTO TB_PDI_IV_INFO	 
                    (CLS_YMD,	 
                     QLTY_VEHL_CD,	 
                     DL_EXPD_MDL_MDY_CD,	 
                     LANG_CD,	 
                     N_PRNT_PBCN_NO,	 
                     IV_QTY,	 
                     CMPL_YN,	 
                     PPRR_EENO,	 
                     FRAM_DTM,	 
                     UPDR_EENO,	 
                     MDFY_DTM,	 
                     PRDN_PLNT_CD 
                    )	 
                    VALUES	 
                    (V_CURR_CLS_YMD,	 
                     V_QLTY_VEHL_CD_1,	 
                     V_DL_EXPD_MDL_MDY_CD_1,	 
                     V_LANG_CD_1,	 
                     V_N_PRNT_PBCN_NO_1,	 
                     V_IV_QTY_1,	 
                     'N',	 
                     BTCH_USER_EENO,	 
                     SYSDATE(),	 
                     BTCH_USER_EENO,	 
                     SYSDATE(),	 
                     V_PRDN_PLNT_CD_1  
                    );	 
                    	 
                    /*전일의 재고내역을 기반으로 재고상세 내역을 다시 생성하는 방식의 경우 	 
                      재고상세 테이블에 취급설명서연식과 같은 차종연식으로 데이터를 신규입력하여 준다.	 
                      (왜냐하면 연식 연계 관계에서 취급설명서 연식과 연계된 차종 연식에는 	 
                       취급설명서 연식과 동일한 차종연식은 반드시 있기 때문이다.) 	  */
                    INSERT INTO TB_PDI_IV_INFO_DTL	 
                    (CLS_YMD,	 
                     QLTY_VEHL_CD,	 
                     MDL_MDY_CD,	 
                     LANG_CD,	 
                     DL_EXPD_MDL_MDY_CD,	 
                     N_PRNT_PBCN_NO,	 
                     IV_QTY,	 
                     SFTY_IV_QTY,	 
                     CMPL_YN,	 
                     PPRR_EENO,	 
                     FRAM_DTM,	 
                     UPDR_EENO,	 
                     MDFY_DTM,	 
                     PRDN_PLNT_CD
                    )	 
                    VALUES	 
                    (V_CURR_CLS_YMD,	 
                     V_QLTY_VEHL_CD_1,	 
                     V_DL_EXPD_MDL_MDY_CD_1, /*차종연식을 취급설명서 연식과 동일한 값으로 입력 	  */
                     V_LANG_CD_1,	 
                     V_DL_EXPD_MDL_MDY_CD_1,	 
                     V_N_PRNT_PBCN_NO_1,	 
                     V_IV_QTY_1,	 
                     V_IV_QTY_1,             /*안전재고수량 역시 현재의 재고수량과 동일한 값으로 입력한다.(나중에 재고 재계산 시에 다시 계산됨) 	  */
                     'N',	 
                     BTCH_USER_EENO,	 
                     SYSDATE(),	 
                     BTCH_USER_EENO,	 
                     SYSDATE(),	 
                     V_PRDN_PLNT_CD_1 
                    ); 
                ELSE	 
                    SELECT IFNULL(SUM(IV_QTY), 0)	 
                    INTO V_QTY	 
                    FROM TB_PDI_IV_INFO	 
                    WHERE CLS_YMD = V_CURR_CLS_YMD	 
                    AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
                    AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
                    AND LANG_CD = V_LANG_CD_1	 
                    AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
                    AND IV_SCN_CD = 'Y' /*배치가 도는 시점에 입고된 데이터인지의 여부를 확인 	  */
                    AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_1;
                    	 
                    IF V_QTY > 0 THEN
                        /*배치가 도는 시점에 입고로 잡을 경우를 대비하여 로직 수정함	  */
                        UPDATE TB_PDI_IV_INFO	 
                        SET IV_QTY = (V_IV_QTY_1 + V_QTY),	 
                            CMPL_YN = 'N',	 
                            UPDR_EENO = BTCH_USER_EENO,	 
                            MDFY_DTM = SYSDATE(),	 
                            IV_SCN_CD = NULL	 
                        WHERE CLS_YMD = V_CURR_CLS_YMD	 
                        AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
                        AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
                        AND LANG_CD = V_LANG_CD_1	 
                        AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
                        AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_1;
                        	 
                        UPDATE TB_PDI_IV_INFO_DTL	 
                        SET IV_QTY = (V_IV_QTY_1 + V_QTY),	 
                            SFTY_IV_QTY = (V_IV_QTY_1 + V_QTY),	 
                            CMPL_YN = 'N',	 
                            UPDR_EENO = BTCH_USER_EENO,	 
                            MDFY_DTM = SYSDATE()	 
                        WHERE CLS_YMD = V_CURR_CLS_YMD	 
                        AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1	 
                        AND MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
                        AND LANG_CD = V_LANG_CD_1	 
                        AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
                        AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
                        AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_1;
                    END IF;
                END IF;	 

	END LOOP JOBLOOP1 ;
	CLOSE PDI_IV_INFO;


    SET CURR_LOC_NUM = 3;

	UPDATE TB_PDI_IV_INFO	 
	SET CMPL_YN = 'Y',	 
		IV_SCN_CD = NULL	 
	WHERE CLS_YMD = V_PREV_CLS_YMD;

	OPEN PDI_IV_DTL_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_DTL_INFO INTO V_QLTY_VEHL_CD_2,V_LANG_CD_2,V_PRDN_PLNT_CD_2;
	IF endOfRow2 THEN
	 LEAVE JOBLOOP2 ;
	END IF;

	CALL SP_RECALCULATE_PDI_IV_DTL4(V_CURR_CLS_YMD,	 
												   V_QLTY_VEHL_CD_2,	 
												   V_LANG_CD_2,	 
												   V_PRDN_PLNT_CD_2									   	 
												   );	 

	END LOOP JOBLOOP2 ;
	CLOSE PDI_IV_DTL_INFO;


    SET CURR_LOC_NUM = 4;

	UPDATE TB_PDI_IV_INFO_DTL	 
	SET CMPL_YN = 'Y'	 
	WHERE CLS_YMD = V_PREV_CLS_YMD;	 
				

    SET CURR_LOC_NUM = 5;
 
	COMMIT;	 
	 

    SET CURR_LOC_NUM = 6;

	CALL WRITE_BATCH_LOG('PDI재고배치작업', STRT_DATE, 'S', '배치처리완료');	


    SET CURR_LOC_NUM = 7;

	/*END;
	DELIMITER;
	다음처리*/
	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_PDI_IV_INFO_SAVE_BY_WHSN 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_PDI_IV_INFO_SAVE_BY_WHSN`(IN P_CURR_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(8),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_DTL_SN INT,
                                        IN P_EXPD_WHSN_ST_CD VARCHAR(4),
                                        IN P_EXPD_BOX_QTY INT,
                                        IN P_WHSN_QTY INT,
                                        IN P_DEEI1_QTY INT,
                                        IN P_PRDN_PLNT_CD VARCHAR(4),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_PDI_IV_INFO_SAVE_BY_WHSN
 * Procedure 설명 : PDI 재고정보 Insert(입고확인)
 *                 PDI재고 Insert 작업 수행	
 *                 현재의 입고 내역을 재고상세 테이블에 저장한다.	 
 *                 입고내역에 대한 재고상세 테이블 재계산 작업 수행
 * 입력 파라미터    :  P_CURR_YMD                현재년월일
 *                 P_VEHL_CD                 차종코드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_DTL_SN                  상세일련번호
 *                 P_EXPD_WHSN_ST_CD         취급설명서입고상태코드
 *                 P_EXPD_BOX_QTY            취급설명서박스량
 *                 P_WHSN_QTY                입고량
 *                 P_DEEI1_QTY               초과부족량
 *                 P_PRDN_PLNT_CD            생산공장코드
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_PDI_IV_INFO_SAVE_BY_WHSN',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CURR_YMD:',IFNULL(P_CURR_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_EXPD_WHSN_ST_CD:',IFNULL(P_EXPD_WHSN_ST_CD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_DTL_SN:',IFNULL(CONCAT(P_DTL_SN),'')
							,',P_EXPD_BOX_QTY:',IFNULL(CONCAT(P_EXPD_BOX_QTY),'')
							,',P_WHSN_QTY:',IFNULL(CONCAT(P_WHSN_QTY),'')
							,',P_DEEI1_QTY:',IFNULL(CONCAT(P_DEEI1_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			/*등록전 PK별 정보 있는지 확인*/
			SET V_INEXCNT = 0;
			SELECT COUNT(*)	 
			INTO V_INEXCNT	 
			FROM TB_PDI_IV_INFO
			WHERE CLS_YMD = P_CURR_YMD
			AND QLTY_VEHL_CD =P_VEHL_CD
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD
			AND LANG_CD = P_LANG_CD
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
				
			IF V_INEXCNT = 0 THEN
				/*PDI재고 Insert 작업 수행	  */
				INSERT INTO TB_PDI_IV_INFO	 
				(CLS_YMD,	 
				 QLTY_VEHL_CD,	 
				 DL_EXPD_MDL_MDY_CD,	 
				 LANG_CD,	 
				 N_PRNT_PBCN_NO,	 
				 IV_QTY,	 
				 CMPL_YN,	 
				 PPRR_EENO,	 
				 FRAM_DTM,	 
				 UPDR_EENO,	 
				 MDFY_DTM,	 
				 IV_SCN_CD,	 
				 PRDN_PLNT_CD
				)	 
				VALUES	 
				(P_CURR_YMD,	 
				 P_VEHL_CD,	 
				 P_EXPD_MDL_MDY_CD,	 
				 P_LANG_CD,	 
				 P_N_PRNT_PBCN_NO,	 
				 P_WHSN_QTY,	 
				 'N',	 
				 V_BATCH_USER_EENO,	 
				 SYSDATE(),	 
				 V_BATCH_USER_EENO,	 
				 SYSDATE(),	 
				 'Y',	 
				 P_PRDN_PLNT_CD
				);	 
			END IF;
	 

    SET CURR_LOC_NUM = 2;

			/*현재의 입고 내역을 재고상세 테이블에 저장한다.	  */
			CALL SP_UPDATE_PDI_IV_DTL_INFO(P_VEHL_CD,	 
									  P_EXPD_MDL_MDY_CD,	 
									  P_LANG_CD,	 
									  P_N_PRNT_PBCN_NO,	 
									  P_CURR_YMD,	
									  P_PRDN_PLNT_CD
									  );	 
	 

    SET CURR_LOC_NUM = 3;

			/*입고내역에 대한 재고상세 테이블 재계산 작업 수행	  */
			CALL SP_RECALCULATE_PDI_IV_DTL4(P_CURR_YMD,	 
									   P_VEHL_CD,	 
									   P_LANG_CD,	 
									   P_PRDN_PLNT_CD
									   );


    SET CURR_LOC_NUM = 4;


	COMMIT;


    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_PDI_IV_INFO_UPDATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_PDI_IV_INFO_UPDATE`(IN P_VEHL_CD VARCHAR(8),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_CLS_YMD VARCHAR(8),
                                        IN P_DIFF_WHOT_QTY INT,
                                        IN P_BATCH_FLAG VARCHAR(1),
                                        IN P_CASCADE_FLAG VARCHAR(1),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_PDI_IV_INFO_UPDATE
 * Procedure 설명 : PDI 재고 정보 저장	 
 * 입력 파라미터    :  P_VEHL_CD                 차종코드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_CLS_YMD                 마감년월일
 *                 P_DIFF_WHOT_QTY           출고차이량
 *                 P_BATCH_FLAG              배치플래그
 *                 P_CASCADE_FLAG            CASCADE플레그
 *                 P_PRDN_PLNT_CD            생산공장코드
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_YMD		VARCHAR(8);
	DECLARE V_SYST_YMD		VARCHAR(8);
	DECLARE V_CNT	INT;
	DECLARE V_QTY	INT;
	DECLARE V_DIFF_QTY	INT;
	DECLARE V_DEEI1_QTY	INT;
	DECLARE V_FROM_DATE	DATETIME;
	DECLARE V_TO_DATE	DATETIME;
	DECLARE V_CURR_DATE	DATETIME;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);
	
	DECLARE V_EXCNT			        INT;
	DECLARE i			            INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_PDI_IV_INFO_UPDATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_BATCH_FLAG:',IFNULL(P_BATCH_FLAG,'')
							,',P_CASCADE_FLAG:',IFNULL(P_CASCADE_FLAG,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',V_SYST_YMD:',IFNULL(V_SYST_YMD,'')
							,',V_FROM_DATE:',IFNULL(DATE_FORMAT(V_FROM_DATE, '%Y%m%d'),'')
							,',V_TO_DATE:',IFNULL(DATE_FORMAT(V_TO_DATE, '%Y%m%d'),'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',P_DIFF_WHOT_QTY:',IFNULL(CONCAT(P_DIFF_WHOT_QTY),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_QTY:',IFNULL(CONCAT(V_QTY),'')
							,',V_DIFF_QTY:',IFNULL(CONCAT(V_DIFF_QTY),'')
							,',V_DEEI1_QTY:',IFNULL(CONCAT(V_DEEI1_QTY),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',i:',IFNULL(CONCAT(i),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			IF P_BATCH_FLAG = 'N' THEN
			   IF P_CASCADE_FLAG = 'N' THEN
				   SELECT IFNULL(SUM(IV_QTY), 0)	 
			   	   INTO V_QTY	 
			   	   FROM TB_PDI_IV_INFO	 
			   	   WHERE CLS_YMD = P_CLS_YMD	 
			   	   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   	   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   	   AND LANG_CD = P_LANG_CD	 
			   	   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   	   AND CMPL_YN = 'N'	 
			   	   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 

    SET CURR_LOC_NUM = 2;

			   	   IF V_QTY >= P_DIFF_WHOT_QTY THEN
				   	  /*현재 남아있는 재고수량보다 출고수량이 큰 경우에는 재고보정을 수행하지 않는다.	 
				  	    (만일 재고보정이 가능하게 되면 예기치 않은 여러 문제가 발생될 수 있다.)	 
			   	  		CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid pdi inventory quantity ' ,	 
			   								   	  	  'date:' , DATE_FORMAT(STR_TO_DATE(P_CLS_YMD, '%Y%m%d'), '%Y-%m-%d') , ',' ,	 
											   	  	  'vehl:' , P_VEHL_CD , ',' ,	 
											   	  	  'mkyr:' , P_EXPD_MDL_MDY_CD , ',' ,	 
											   	  	  'lang:' , P_LANG_CD , ',' , P_N_PRNT_PBCN_NO , ',' ,	 
											   	  	  'qty :' , CONCAT(P_DIFF_WHOT_QTY)));
						SIGNAL SQLSTATE '45000';	 
			   	   ELSE*/
				   	  SET V_DIFF_QTY  = P_DIFF_WHOT_QTY;
			   	   END IF;	 
	 

    SET CURR_LOC_NUM = 3;

			   	   UPDATE TB_PDI_IV_INFO	 
			   	   SET IV_QTY = (IV_QTY - V_DIFF_QTY),
				   	   UPDR_EENO = V_BATCH_USER_EENO,	 
				   	   MDFY_DTM = SYSDATE()	 
			       WHERE CLS_YMD = P_CLS_YMD	 
			   	   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   	   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   	   AND LANG_CD = P_LANG_CD	 
			   	   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   	   AND CMPL_YN = 'N'	 
			   	   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
			   	    /*이전날짜의 데이터인 경우에는 입력이 되지 않도록 한다..	 */


    SET CURR_LOC_NUM = 4;

				SET V_EXCNT = 0;
				SELECT COUNT(CLS_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PDI_IV_INFO
			       WHERE CLS_YMD = P_CLS_YMD	 
			   	   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   	   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   	   AND LANG_CD = P_LANG_CD	 
			   	   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   	   AND CMPL_YN = 'N'	 
			   	   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
			   	    /*이전날짜의 데이터인 경우에는 입력이 되지 않도록 한다..	 */

			   	   /*IF V_EXCNT = 0 THEN
			   	  		CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid input value ' ,	 
			   								   	  	  'date:' , DATE_FORMAT(STR_TO_DATE(P_CLS_YMD, '%Y%m%d'), '%Y-%m-%d') , ',' ,	 
											   	  	  'vehl:' , P_VEHL_CD , ',' ,	 
											   	  	  'mkyr:' , P_EXPD_MDL_MDY_CD , ',' ,	 
											   	  	  'lang:' , P_LANG_CD , ',' , P_N_PRNT_PBCN_NO ));	 

    SET CURR_LOC_NUM = 5;

						SIGNAL SQLSTATE '45000';	
			       END IF;	 */ 
	 
			   	   /*현재의 재고보정 내역을 재고상세 테이블에 저장한다.	 */
			   	   CALL SP_UPDATE_PDI_IV_DTL_INFO(P_VEHL_CD,	 
									         P_EXPD_MDL_MDY_CD,	 
									     	 P_LANG_CD,	 
									     	 P_N_PRNT_PBCN_NO,	 
									     	 P_CLS_YMD,	 
									     	 P_PRDN_PLNT_CD
									     	 );	 
	 

    SET CURR_LOC_NUM = 6;

			       /*재고보정에 대한 재고상세 테이블 재계산 작업 수행	 */
			   	   CALL SP_RECALCULATE_PDI_IV_DTL4(P_CLS_YMD,	 
										  	  P_VEHL_CD,	 
									      	  P_LANG_CD,	 
										  	  P_PRDN_PLNT_CD
										  	  );	 
	 

    SET CURR_LOC_NUM = 7;

			   /*ELSE	
				   현재는 가장 최근의 재고내역만 수정하므로 아무런 작업을 수행하지 않는다.	 
				     (현재일 이전의 재고보정 기능은 현재 지원해 주지 않는다.)	
				   RETURN; */
			   END IF;
			ELSE
				SET V_FROM_DATE = STR_TO_DATE(P_CLS_YMD, '%Y%m%d');	 
				SET V_TO_DATE   = STR_TO_DATE(DATE_FORMAT(SYSDATE(), '%Y%m%d'), '%Y%m%d');	 
				SET V_SYST_YMD  = DATE_FORMAT(V_TO_DATE, '%Y%m%d');	 
				SET V_CNT = ROUND(V_TO_DATE - V_FROM_DATE);	


    SET CURR_LOC_NUM = 8;

				SET i=0;
				JOBLOOPT: LOOP 
	 
					SET V_CURR_DATE = V_FROM_DATE + i;
					SET V_CURR_YMD = DATE_FORMAT(V_CURR_DATE, '%Y%m%d');	 
	 
					SELECT IFNULL(SUM(IV_QTY), 0),	 
						   IFNULL(SUM(DEEI1_QTY), 0)	 
			   		INTO V_QTY,	 
						 V_DEEI1_QTY	 
			   		FROM TB_PDI_IV_INFO	 
			   		WHERE CLS_YMD = V_CURR_YMD	 
			   		AND QLTY_VEHL_CD = P_VEHL_CD	 
			   		AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   		AND LANG_CD = P_LANG_CD	 
			   		AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   		AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;			   			 
	 
					IF V_QTY < P_DIFF_WHOT_QTY THEN
					   /*재고 수량보다 출고수량이 많은 경우에는 재고수량을 0 으로 해준다.	 */
					   SET V_DIFF_QTY  = V_QTY;	
					   /*배치 프로그램이 아닌 다름 프로그램에서 호출시에 문제 발생 여지 있음	 */
					   SET V_DEEI1_QTY = V_DEEI1_QTY + (P_DIFF_WHOT_QTY - V_QTY);
					ELSE
					   /*배치 프로그램이 아닌 다름 프로그램에서 호출시에 문제 발생 여지 있음	 
					     초과부족수량이 존재하며 현재 재고수량이 0 인 경우에만 아래의 작업을 수행한다.	 */
					   IF V_DEEI1_QTY > 0 AND V_QTY = 0 THEN
						  IF (P_DIFF_WHOT_QTY + V_DEEI1_QTY) > 0 THEN
							 SET V_DIFF_QTY  = V_QTY;	 
							 SET V_DEEI1_QTY = P_DIFF_WHOT_QTY + V_DEEI1_QTY;	
						  ELSE
							 SET V_DIFF_QTY  = P_DIFF_WHOT_QTY + V_DEEI1_QTY;	 
							 SET V_DEEI1_QTY = 0;
						  END IF;
					   ELSE
						   SET V_DIFF_QTY  = P_DIFF_WHOT_QTY;
					   END IF;
					END IF;	 
	 
					UPDATE TB_PDI_IV_INFO	 
			   		SET IV_QTY = IV_QTY - V_DIFF_QTY,	 
				   		UPDR_EENO = V_BATCH_USER_EENO,	 
				   		MDFY_DTM = SYSDATE(),	 
						DEEI1_QTY = CASE WHEN V_DEEI1_QTY > 0 THEN V_DEEI1_QTY ELSE NULL END	 
			   		WHERE CLS_YMD = V_CURR_YMD	 
			   		AND QLTY_VEHL_CD = P_VEHL_CD	 
			   		AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   		AND LANG_CD = P_LANG_CD	 
			   		AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   		AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;

					SET V_EXCNT = 0;
					SELECT COUNT(CLS_YMD)	 
					  INTO V_EXCNT	 
					  FROM TB_PDI_IV_INFO 
			   		WHERE CLS_YMD = V_CURR_YMD	 
			   		AND QLTY_VEHL_CD = P_VEHL_CD	 
			   		AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   		AND LANG_CD = P_LANG_CD	 
			   		AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   		AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
					IF V_EXCNT = 0 THEN
					   /*과잉출고 되어 재고 보정작업하는 경우에만 신규로 추가해 주면 된다.	 
					     (V_DIFF_QTY 로 비교하지 않도록 주의 할 것)	 */
					   IF P_DIFF_WHOT_QTY < 0 THEN
						  INSERT INTO TB_PDI_IV_INFO	 
						  (CLS_YMD,	 
			 			   QLTY_VEHL_CD,	 
			 			   DL_EXPD_MDL_MDY_CD,	 
			 			   LANG_CD,	 
			 			   N_PRNT_PBCN_NO,	 
			 			   IV_QTY,	 
			 			   CMPL_YN,	 
			 			   PPRR_EENO,	 
			 			   FRAM_DTM,	 
			 			   UPDR_EENO,	 
			 			   MDFY_DTM,	 
						   TMP_TRTM_YN,	 
						   PRDN_PLNT_CD
						  )	 
					   	  VALUES(V_CURR_YMD,	 
							     P_VEHL_CD,	 
							     P_EXPD_MDL_MDY_CD,	 
							     P_LANG_CD,	 
							     P_N_PRNT_PBCN_NO,	 
								 P_DIFF_WHOT_QTY * (-1),	 
								 CASE WHEN V_CURR_YMD = V_SYST_YMD THEN 'N' ELSE 'Y' END,	 
								 V_BATCH_USER_EENO,	 
								 SYSDATE(),	 
								 V_BATCH_USER_EENO,	 
								 SYSDATE(),	 
								 'Y',	 
								 P_PRDN_PLNT_CD
								);
					   END IF;
					END IF;	 
	 
					/*현재의 재고보정 내역을 재고상세 테이블에 저장한다.	 */
					CALL SP_UPDATE_PDI_IV_DTL_INFO(P_VEHL_CD,	 
									          P_EXPD_MDL_MDY_CD,	 
									          P_LANG_CD,	 
									          P_N_PRNT_PBCN_NO,	 
									          V_CURR_YMD,	 
									          P_PRDN_PLNT_CD
									          );	
	 
					/*재고상세 테이블 재계산 작업은 외부(배치프로그램)에서 수행해 준다.	*/ 
	 
					SET i=i+1; 
					IF i=V_CNT THEN
						LEAVE JOBLOOPT;
					END IF;
				END LOOP JOBLOOPT;


    SET CURR_LOC_NUM = 9;


			END IF;

	COMMIT;


    SET CURR_LOC_NUM = 10;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_PDI_IV_INFO_UPDATE3 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_PDI_IV_INFO_UPDATE3`(IN P_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_CLS_YMD VARCHAR(8),
                                        IN P_DIFF_RQ_QTY INT,
                                        IN P_FLAG VARCHAR(1),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_PDI_IV_INFO_UPDATE3
 * Procedure 설명 : PDI 재고정보 업데이트 수행(재고전환 기능)
 * 입력 파라미터    :  P_VEHL_CD                 현재년월일
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_CLS_YMD                 마감년월일
 *                 P_DIFF_RQ_QTY             요청차이량
 *                 P_FLAG                    플래그
 *                 P_PRDN_PLNT_CD            생산공장코드
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QTY		   INT;	 
	DECLARE V_DIFF_RQ_QTY  INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);
	
	DECLARE V_EXCNT		   INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_PDI_IV_INFO_UPDATE3',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_FLAG:',IFNULL(P_FLAG,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_DIFF_RQ_QTY:',IFNULL(CONCAT(P_DIFF_RQ_QTY),'')
							,',V_QTY:',IFNULL(CONCAT(V_QTY),'')
							,',V_DIFF_RQ_QTY:',IFNULL(CONCAT(V_DIFF_RQ_QTY),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';


			SELECT IFNULL(SUM(IV_QTY), 0)	 
			INTO V_QTY	 
			FROM TB_PDI_IV_INFO	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND CMPL_YN = 'N'	 
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 

    SET CURR_LOC_NUM = 2;

			/* 재고수량이 출고수량보다 작은 경우에는 출고 하지 못한다.	 */
			IF V_QTY < P_DIFF_RQ_QTY THEN	 
			   CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid pdi inventory quantity ' , 	 
			   								   'date:' ,  DATE_FORMAT(STR_TO_DATE(P_CLS_YMD, '%Y%m%d'), '%Y-%m-%d') ,  ',' , 	 
											   'vehl:' ,  P_VEHL_CD ,  ',' , 	 
											   'mkyr:' ,  P_EXPD_MDL_MDY_CD ,  ',' , 	 
											   'lang:' ,  P_LANG_CD ,  ',' ,  P_N_PRNT_PBCN_NO ,  ',' , 	 
											   'qty :' ,  DATE_FORMAT(P_DIFF_RQ_QTY,'%Y%m%d')));

    SET CURR_LOC_NUM = 3;

			   SIGNAL SQLSTATE '45000';
			END IF;	 
	 

    SET CURR_LOC_NUM = 4;

			UPDATE TB_PDI_IV_INFO	 
			SET IV_QTY = (IV_QTY - P_DIFF_RQ_QTY),	 
				UPDR_EENO = V_BATCH_USER_EENO,	 
				MDFY_DTM = SYSDATE()	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND CMPL_YN = 'N'	 
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;  /* 이전날짜의 데이터인 경우에는 입력이 되지 않도록 한다 */


    SET CURR_LOC_NUM = 5;

			SET V_EXCNT = 0;
			SELECT COUNT(CLS_YMD)	 
				  INTO V_EXCNT	 
			FROM TB_PDI_IV_INFO 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			/*AND CMPL_YN = 'N'	 */
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD; 


    SET CURR_LOC_NUM = 6;

			IF V_EXCNT = 0 THEN
			   IF P_FLAG = 'Y' THEN
				  CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid input value ' , 	 
			   								      'date:' ,  DATE_FORMAT(STR_TO_DATE(P_CLS_YMD, '%Y%m%d'), '%Y-%m-%d') ,  ',' , 	 
											      'vehl:' ,  P_VEHL_CD ,  ',' , 	 
											      'mkyr:' ,  P_EXPD_MDL_MDY_CD ,  ',' , 	 
											      'lang:' ,  P_LANG_CD ,  ',' ,  P_N_PRNT_PBCN_NO));		 
				  SIGNAL SQLSTATE '45000';
			   ELSE	
				  INSERT INTO TB_PDI_IV_INFO	 
				  (CLS_YMD,	 
			 	   QLTY_VEHL_CD,	 
			 	   DL_EXPD_MDL_MDY_CD,	 
			 	   LANG_CD,	 
			 	   N_PRNT_PBCN_NO,	 
			 	   IV_QTY,	 
			 	   CMPL_YN,	 
			 	   PPRR_EENO,	 
			 	   FRAM_DTM,	 
			 	   UPDR_EENO,	 
			 	   MDFY_DTM,	 
				   TMP_TRTM_YN,	 
				   PRDN_PLNT_CD 
				  )	 
				  VALUES(P_CLS_YMD,	 
						 P_VEHL_CD,	 
						 P_EXPD_MDL_MDY_CD,	 
					     P_LANG_CD,	 
						 P_N_PRNT_PBCN_NO,	   /* P_DIFF_RQ_QTY가 - 로 들어오기 때문에 이때는 -1을 곱해주어야 한다.	  */						 
						 P_DIFF_RQ_QTY * (-1),	 
						 'N',	 
						 V_BATCH_USER_EENO,	 
						 SYSDATE(),	 
						 V_BATCH_USER_EENO,	 
						 SYSDATE(),	 /* 재고보정에 의해서 임시 생성된 데이터이므로 무조건 'Y' 로 설정해 준다.	 */						 
						 'Y',	 
						 P_PRDN_PLNT_CD
						);	 
			   END IF;	 
		    END IF;	 
	 

    SET CURR_LOC_NUM = 7;

			/* 현재의 출고 내역을 재고상세 테이블에 저장한다.	  */
			CALL SP_UPDATE_PDI_IV_DTL_INFO(P_VEHL_CD,	 
									  P_EXPD_MDL_MDY_CD,	 
									  P_LANG_CD,	 
									  P_N_PRNT_PBCN_NO,	 
									  P_CLS_YMD,	 
									  P_PRDN_PLNT_CD
									  );	

    SET CURR_LOC_NUM = 8;
 
			/* 출고 내역에 대한 재고상세 테이블 재계산 작업 수행	  */
			CALL SP_RECALCULATE_PDI_IV_DTL4(P_CLS_YMD,	 
									   P_VEHL_CD,	 
									   P_LANG_CD,	 
									   P_PRDN_PLNT_CD
									   );


    SET CURR_LOC_NUM = 9;

	COMMIT;


    SET CURR_LOC_NUM = 10;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_PDI_WHSN_INFO_SAVE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_PDI_WHSN_INFO_SAVE`(IN P_VEHL_CD VARCHAR(8),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_DTL_SN INT,
                                        IN P_EXPD_WHSN_ST_CD VARCHAR(4),
                                        IN P_EXPD_BOX_QTY INT,
                                        IN P_WHSN_QTY INT,
                                        IN P_DEEI1_QTY INT,
                                        IN P_USER_EENO VARCHAR(20),
                                        IN P_PRDN_PLNT_CD VARCHAR(4),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_PDI_WHSN_INFO_SAVE
 * Procedure 설명 : 입고확인된 데이터가 아닌지의 여부 확인 
 *                 현재 가장 최근의 세화 출고요청수량을 다시 읽어온다. 
 *                 입고확인되지 않은 데이터만을 저장하도록 한다.
 *                 이미 재고등록된 항목이 존재하는지의 여부를 확인한다.	
 *                 재고데이터 업데이트 작업 수행
 *                 세화 출고내역에서 입고확인상태로 변경하는 작업 수행(세화재고에서 제외하는 작업도 같이 수행)
 * 입력 파라미터    :  P_VEHL_CD                   차종코드
 *                 P_MDL_MDY_CD                모델년식코드
 *                 P_LANG_CD                   언어코드
 *                 P_EXPD_MDL_MDY_CD           취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO            신인쇄발간번호
 *                 P_DTL_SN                    상세식별번호
 *                 P_EXPD_WHSN_ST_CD           취급설명서입고상태코드
 *                                             (01:정상,02:부족,03:과잉,04:추가입고)
 *                 P_EXPD_BOX_QTY              취급설명서박스량
 *                 P_WHSN_QTY                  입고량
 *                 P_DEEI1_QTY                 부족량
 *                 P_USER_EENO                 사원번호
 *                 P_PRDN_PLNT_CD              생산공장코드
 *                 P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_YMD		VARCHAR(8);
	DECLARE V_WHSN_QTY	INT;
	DECLARE V_CNT	INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_PDI_WHSN_INFO_SAVE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_EXPD_WHSN_ST_CD:',IFNULL(P_EXPD_WHSN_ST_CD,'')
							,',P_USER_EENO:',IFNULL(P_USER_EENO,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',P_DTL_SN:',IFNULL(CONCAT(P_DTL_SN),'')
							,',P_EXPD_BOX_QTY:',IFNULL(CONCAT(P_EXPD_BOX_QTY),'')
							,',P_WHSN_QTY:',IFNULL(CONCAT(P_WHSN_QTY),'')
							,',P_DEEI1_QTY:',IFNULL(CONCAT(P_DEEI1_QTY),'')
							,',V_WHSN_QTY:',IFNULL(CONCAT(V_WHSN_QTY),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
   
			SET V_CURR_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d');	 
				 
			/*입고확인된 데이터가 아닌지의 여부 확인, 현재 가장 최근의 세화 출고요청수량을 다시 읽어온다. 	 */
			SELECT SUM(RQ_QTY)	 
			INTO V_WHSN_QTY	 
			FROM TB_SEWON_WHOT_INFO	 
			WHERE QLTY_VEHL_CD = P_VEHL_CD	 
			AND MDL_MDY_CD = P_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND DTL_SN = P_DTL_SN	 
			AND CMPL_YN = 'N'	 
			AND DEL_YN = 'N'	 
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;


    SET CURR_LOC_NUM = 2;

			/*입고확인되지 않은 데이터만을 저장하도록 한다. 	 */
			IF V_WHSN_QTY IS NOT NULL THEN
			   /*입고상태가 부족인 경우 에는 입고수량에서 부족 수량을 빼준다.	 */
			   IF P_EXPD_WHSN_ST_CD = '02' THEN
				  SET V_WHSN_QTY = P_WHSN_QTY - IFNULL(P_DEEI1_QTY, 0);
				  /*IF V_WHSN_QTY < 0 THEN
			   	  		CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Sewon delivery quantity(include shortage qty) is more than zero ' , 	 
			   								    	 'date:' , DATE_FORMAT(STR_TO_DATE(V_CURR_YMD, '%Y%m%d'), '%Y-%m-%d') , ',' ,	 
											    	 'vehl:' , P_VEHL_CD , ',' , 	 
											    	 'mkyr:' , P_EXPD_MDL_MDY_CD , ',' , 	 
											    	 'lang:' , P_LANG_CD , ',' , P_N_PRNT_PBCN_NO , ',' ,	 
											    	 'sn  :' , CONCAT(P_DTL_SN)));	 
						SIGNAL SQLSTATE '45000';
													 
				  END IF;	 */
				  	 
			   ELSE
				  SET V_WHSN_QTY = P_WHSN_QTY;
			   END IF;	 
				 

    SET CURR_LOC_NUM = 3;


				SET V_INEXCNT = 0;
				SELECT COUNT(QLTY_VEHL_CD)	 
				  INTO V_INEXCNT	 
				  FROM TB_PDI_WHSN_INFO
				WHERE QLTY_VEHL_CD = P_VEHL_CD
					AND DL_EXPD_MDL_MDY_CD =P_EXPD_MDL_MDY_CD
					AND LANG_CD = P_LANG_CD
					AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO
					AND MDL_MDY_CD = P_MDL_MDY_CD
					AND PRDN_PLNT_CD = P_PRDN_PLNT_CD
					AND DTL_SN = P_DTL_SN;
				
				IF V_INEXCNT = 0 THEN
				   INSERT INTO TB_PDI_WHSN_INFO	 
				   (QLTY_VEHL_CD,	 
					DL_EXPD_MDL_MDY_CD,	 
					LANG_CD,	 
					N_PRNT_PBCN_NO,	 
					DTL_SN,	 
					WHSN_YMD,	 
					DL_EXPD_WHSN_ST_CD,	 
					WHSN_QTY,	 
					DEEI1_QTY,	 
					CRGR_EENO,	 
					DL_EXPD_BOX_QTY,	 
					PPRR_EENO,	 
					FRAM_DTM,	 
					UPDR_EENO,	 
					MDFY_DTM,	 
					MDL_MDY_CD,	 
					PRDN_PLNT_CD
				   )	 
				   VALUES	 
				   (P_VEHL_CD,	 
					P_EXPD_MDL_MDY_CD,	 
					P_LANG_CD,	 
					P_N_PRNT_PBCN_NO,	 
					P_DTL_SN,	 
					V_CURR_YMD,	 
					P_EXPD_WHSN_ST_CD,	 
					V_WHSN_QTY, 
					CASE WHEN P_EXPD_WHSN_ST_CD = '01' THEN 0
						 ELSE P_DEEI1_QTY END,
					P_USER_EENO,	 
					P_EXPD_BOX_QTY,	 
					P_USER_EENO,	 
					SYSDATE(),	 
					P_USER_EENO,	 
					SYSDATE(),	 
					P_MDL_MDY_CD,	 
					P_PRDN_PLNT_CD  
				   );	 

				END IF;
			   	 

    SET CURR_LOC_NUM = 4;

			   /*이미 재고등록된 항목이 존재하는지의 여부를 확인한다.	 */
			   SELECT COUNT(*)	 
			   INTO V_CNT	 
			   FROM TB_PDI_IV_INFO	 
			   WHERE CLS_YMD = V_CURR_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
			   	 

    SET CURR_LOC_NUM = 5;

			   IF V_CNT = 0 THEN
				  CALL SP_PDI_IV_INFO_SAVE_BY_WHSN(V_CURR_YMD,	 
	   			 							 		  P_VEHL_CD,	 
													  P_MDL_MDY_CD,	 
								          	 		  P_LANG_CD,	 
													  P_EXPD_MDL_MDY_CD,	 
								    	  	 		  P_N_PRNT_PBCN_NO,	 
								    	  	 		  P_DTL_SN,	 
								    	  	 		  P_EXPD_WHSN_ST_CD,	 
								    	  	 		  P_EXPD_BOX_QTY,	 
								    	  	 		  V_WHSN_QTY,	 
								    	  	 		  P_DEEI1_QTY,	 
								    	  	 		  P_PRDN_PLNT_CD,  
								    	  	 		  P_EXPD_CO_CD 
								    	  	 		  );

    SET CURR_LOC_NUM = 6;

			   ELSE
				   /*재고데이터 업데이트 작업 수행 	 */
				   CALL SP_PDI_IV_INFO_UPDATE(P_VEHL_CD,	 
				                                 P_MDL_MDY_CD,	 
							                     P_LANG_CD,	 
												 P_EXPD_MDL_MDY_CD,	 
								         		 P_N_PRNT_PBCN_NO,	 
								         		 V_CURR_YMD,	 
										 		 V_WHSN_QTY * (-1),	 
								         		 'N',	 
												 'N',	 
								         		 P_PRDN_PLNT_CD, 
								         		 P_EXPD_CO_CD
								         		 );	 

    SET CURR_LOC_NUM = 7;

								  	 
			   END IF;
    SET CURR_LOC_NUM = 8;
			   /*세원 출고내역에서 입고확인상태로 변경하는 작업 수행(세원재고에서 제외하는 작업도 같이 수행)	 */
			   CALL SP_SEWON_WHOT_INFO_UPDATE(P_VEHL_CD,	 
			                                              P_MDL_MDY_CD,	 
				                                          P_LANG_CD,	 
														  P_EXPD_MDL_MDY_CD,	 
				                                          P_N_PRNT_PBCN_NO,	 
				                                          P_DTL_SN,	 
														  V_CURR_YMD,	 
														  V_WHSN_QTY,	 
														  P_EXPD_CO_CD
														  );	

    SET CURR_LOC_NUM = 9;
 
			/*ELSE 
			   	  		CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Sewon delivery quantity is not exist ' , 	 
			   								    	 'date:' , DATE_FORMAT(STR_TO_DATE(V_CURR_YMD, '%Y%m%d'), '%Y-%m-%d') , ',' ,	 
											    	 'vehl:' , P_VEHL_CD , ',' , 	 
											    	 'mkyr:' , P_EXPD_MDL_MDY_CD , ',' , 	 
											    	 'lang:' , P_LANG_CD , ',' , P_N_PRNT_PBCN_NO , ',' ,	 
											    	 'sn  :' , CONCAT(P_DTL_SN)));	 

    SET CURR_LOC_NUM = 9;

						SIGNAL SQLSTATE '45000';*/
			END IF;	 

    SET CURR_LOC_NUM = 10;

	COMMIT;

    SET CURR_LOC_NUM = 11;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_PRNT_APVL_INFO_CANCEL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_PRNT_APVL_INFO_CANCEL`(IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_STATE VARCHAR(2),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_PRNT_APVL_INFO_CANCEL
 * Procedure 설명 : 제작승인 취소 작업 수행
 * 입력 파라미터    :  P_QLTY_VEHL_CD            품질차종코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_STATE                   상태
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_RDCS_ST_CD		VARCHAR(4);		
	DECLARE V_CSET_YMD			VARCHAR(8);		
	DECLARE V_PARR_QTY			INT;		
	DECLARE V_I_WAY_CD			VARCHAR(4);
	DECLARE V_QLTY_VEHL_CD		VARCHAR(4);
	DECLARE V_MDL_MDY_CD		VARCHAR(2);
	DECLARE V_LANG_CD			VARCHAR(3);
	DECLARE V_EXPD_MDL_MDY_CD	VARCHAR(2);	
	DECLARE V_RETURN 			CHAR(1);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_PRNT_APVL_INFO_CANCEL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_STATE:',IFNULL(P_STATE,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_RDCS_ST_CD:',IFNULL(V_RDCS_ST_CD,'')
							,',V_CSET_YMD:',IFNULL(V_CSET_YMD,'')
							,',V_I_WAY_CD:',IFNULL(V_I_WAY_CD,'')
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_MDL_MDY_CD:',IFNULL(V_MDL_MDY_CD,'')
							,',V_LANG_CD:',IFNULL(V_LANG_CD,'')
							,',V_EXPD_MDL_MDY_CD:',IFNULL(V_EXPD_MDL_MDY_CD,'')
							,',FU_CHECK_RDCS_ST_CD:',IFNULL(FU_CHECK_RDCS_ST_CD(P_N_PRNT_PBCN_NO, P_STATE, V_RDCS_ST_CD),'')
							,',V_RETURN:',IFNULL(V_RETURN,'')
							,',V_PARR_QTY:',IFNULL(CONCAT(V_PARR_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;	

    SET CURR_LOC_NUM = 1;
		   SET V_BATCH_USER_EENO = 'BATCH';

		   SET V_RETURN = 'N';
		   
		   SELECT MAX(DL_EXPD_RDCS_ST_CD) INTO V_RDCS_ST_CD
		   FROM TB_PRNT_BKGD_INFO
		   WHERE N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;
		   
		   /*제작의뢰의 저장인 경우 */
		   IF P_STATE = 'S' THEN
			  IF V_RDCS_ST_CD  IS NULL  OR V_RDCS_ST_CD IN ('03', '05') THEN
				 SET V_RETURN = 'Y';
			  	 SET V_RDCS_ST_CD = '05';
			  END IF;
		   /*제작의뢰의 승인의뢰인 경우  */
		   ELSEIF P_STATE = 'Q' THEN
		   	  /*신규작성, 반려, 저장된 항목은 승인의뢰 할 수  있다. */
			  IF V_RDCS_ST_CD  IS NULL OR V_RDCS_ST_CD IN ('03', '05') THEN
				 SET V_RETURN = 'Y';
				 IF V_RDCS_ST_CD = '03' THEN
					 SET V_RDCS_ST_CD = '04';
				  ELSE
					 SET V_RDCS_ST_CD = '01';
				  END IF;
			  END IF;
		   /*발주/승인의 승인인 경우  */
		   ELSEIF P_STATE = 'C' THEN
			  /*의뢰, 재의뢰 된 항목은 승인할 수 있다. */
			  IF V_RDCS_ST_CD IN ('01', '04') THEN
				 SET V_RETURN = 'Y';
				 SET V_RDCS_ST_CD = '02';
			  END IF;
		   /*발주/승인의 반려인 경우  */
		   ELSEIF P_STATE = 'R' THEN
			  /*의뢰, 재의뢰 된 항목은 반려 할 수 있다. */
			  IF V_RDCS_ST_CD IN ('01', '04') THEN
				 SET V_RETURN = 'Y';
				 SET V_RDCS_ST_CD = '03';
			  END IF;
		   /*승인 취소인 경우  */
		   ELSEIF P_STATE = 'W'  THEN
			  /*승인된 항목만 취소할 수 있다. */
			  IF V_RDCS_ST_CD IN ('02') THEN
				 SET V_RETURN = 'Y';
				 SET V_RDCS_ST_CD = '01';
			  END IF;
		   /*삭제인 경우 	   */
		   ELSE 
			 /*반려, 저장된 항목은  삭제가 가능한다.  */
			 IF V_RDCS_ST_CD IN ('03', '05') THEN
				 SET V_RETURN = 'Y';
			  END IF;
		   END IF;   
   
   
		   IF V_RETURN = 'Y' THEN
    SET CURR_LOC_NUM = 11;
			  UPDATE TB_PRNT_BKGD_INFO	 
			  SET DL_EXPD_RDCS_ST_CD = V_RDCS_ST_CD,	 
			      TRTM_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d'),	 
				  UPDR_EENO = V_BATCH_USER_EENO,	 
				  MDFY_DTM = SYSDATE()	 
			  WHERE N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;	 
	 

    SET CURR_LOC_NUM = 2;

			  SELECT ORDN_CSET_CDT, PRNT_PARR_QTY	 
			  INTO V_CSET_YMD, V_PARR_QTY	 
			  FROM TB_PRNT_REQ_INFO	 
			  WHERE N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;	 
	 

    SET CURR_LOC_NUM = 3;

			  /* 발주의뢰 내역에 승인일, 승인자정보를 제거한다.	  */
			  UPDATE TB_PRNT_REQ_INFO	 
			  SET ORDN_CSET_CDT = NULL,	 
				  CSET_CRGR_EENO = NULL,	 
				  UPDR_EENO = V_BATCH_USER_EENO,	 
				  MDFY_DTM = SYSDATE()	 
			  WHERE N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;	 
	 

    SET CURR_LOC_NUM = 4;

			  /* 조회조건에 차종, 언어 항목을 임의로 변경 후에 취소 작업 진행시에는	 
			    인자로 들어온 차종, 언어 내역이 잘못 들어 오게 된다. 그래서 아래 부분에서 다시 테이블에서 읽어와서 처리하도록 변경함	  */
			  SELECT I_WAY_CD,	 
			         QLTY_VEHL_CD,	 
					 MDL_MDY_CD,	 
					 LANG_CD,	 
					 DL_EXPD_MDL_MDY_CD	 
			  INTO V_I_WAY_CD,	 
			       V_QLTY_VEHL_CD,	 
				   V_MDL_MDY_CD,	 
				   V_LANG_CD,	 
				   V_EXPD_MDL_MDY_CD	 
			  FROM TB_PRNT_REQ_INFO	 
			  WHERE N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;
			  

    SET CURR_LOC_NUM = 5;

			  IF P_EXPD_CO_CD='02' THEN
				  /* 기아 : 스티커, 리플렛의 경우에는 재고보정 해 주지 않는다.	  */
				  IF V_I_WAY_CD NOT IN ('04', '05') THEN
					 /* 세원 재고내역 취소 작업 수행	  */
					 CALL SP_SEWON_WHSN_INFO_CANCEL(V_CSET_YMD,	 
																V_QLTY_VEHL_CD,	 
																V_MDL_MDY_CD,	 
																V_LANG_CD,	 
																V_EXPD_MDL_MDY_CD,	 
																P_N_PRNT_PBCN_NO,	 
																V_PARR_QTY,	 
																P_EXPD_CO_CD
																);

    SET CURR_LOC_NUM = 6;


				  END IF;
			  ELSE
				  /* 현대 : 스티커, 리플렛, 퀵가이드의 경우에는 재고보정 해 주지 않는다.  */
				  IF V_I_WAY_CD NOT IN ('04', '05', '06') THEN
					 /* 세원 재고내역 취소 작업 수행	  */
					 CALL SP_SEWON_WHSN_INFO_CANCEL(V_CSET_YMD,	 
																V_QLTY_VEHL_CD,	 
																V_MDL_MDY_CD,	 
																V_LANG_CD,	 
																V_EXPD_MDL_MDY_CD,	 
																P_N_PRNT_PBCN_NO,	 
																V_PARR_QTY,	 
																P_EXPD_CO_CD
																);	 

    SET CURR_LOC_NUM = 7;

				  END IF;
			  END IF;
		   ELSE
    SET CURR_LOC_NUM = 71;
			   /*CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid State Code - STATE:[' ,  P_STATE ,  '] RDCS_ST_CD:[' ,  V_RDCS_ST_CD ,  ']'));*/

    SET CURR_LOC_NUM = 8;

			   /*SIGNAL SQLSTATE '45000';*/
    SET CURR_LOC_NUM = 81;
		   END IF;	 
	 

    SET CURR_LOC_NUM = 9;

		   COMMIT;	 

    SET CURR_LOC_NUM = 10;

		   	 /*
			EXCEPTION	 
				WHEN OTHERS THEN	 
					ROLLBACK;	 
					PG_INTERFACE_APS.WRITE_BATCH_EXE_LOG('승인취소 에러', SYSDATE(), 'F', CONCAT('SP_PRNT_APVL_INFO_CANCEL 배치처리실패 : [' ,  SQLERRM ,  ']'));	
	    
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_PDI_IV_DTL2 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_PDI_IV_DTL2`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_PDI_IV_DTL2
 * Procedure 설명 : 재고상세 내역 재계산 작업 수행(배치 프로그램 전용)
 *                 취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.
 *                 취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.
 * 입력 파라미터    :  P_CLS_YMD                   마감년월일
 *                 P_EXPD_CO_CD                  회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO_1 VARCHAR(100);
	DECLARE V_PRDN_PLNT_CD_1 VARCHAR(3);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_LIST_INFO CURSOR FOR
		 						  	SELECT A.QLTY_VEHL_CD,	 
		 						 		   A.DL_EXPD_MDL_MDY_CD,	 
		 						  	 	   A.LANG_CD,	 
										   A.N_PRNT_PBCN_NO,	 
										   A.PRDN_PLNT_CD 
		 						  	FROM TB_PDI_IV_INFO	A 
									/*재고수량이 0보다 큰 것 보다 현재일에 존재하는 모든 항목을 해 주어야 한다.	*/ 
									WHERE A.CLS_YMD = P_CLS_YMD
									AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
							                        FROM TB_VEHL_MGMT C	 
										            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
										            AND C.DL_EXPD_CO_CD = P_EXPD_CO_CD)>0	 
									GROUP BY A.QLTY_VEHL_CD, A.LANG_CD, A.N_PRNT_PBCN_NO, A.DL_EXPD_MDL_MDY_CD, A.PRDN_PLNT_CD 
									/*정렬조건을 아래와 같은 순서를 준수하여야 한다.	 */
									ORDER BY A.QLTY_VEHL_CD, A.LANG_CD, A.N_PRNT_PBCN_NO, A.DL_EXPD_MDL_MDY_CD;	 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_PDI_IV_DTL2',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,'')
							,',V_PRDN_PLNT_CD_1:',IFNULL(V_PRDN_PLNT_CD_1,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';

	/*취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.	 */
	DELETE FROM TB_PDI_IV_INFO_DTL	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD 
	AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
	        FROM TB_VEHL_MGMT C	 
			WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
			AND C.DL_EXPD_CO_CD = P_EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 2;

	/*취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.	 */
	UPDATE TB_PDI_IV_INFO_DTL A	 
	SET A.SFTY_IV_QTY = IV_QTY,	 
	    A.UPDR_EENO = V_BATCH_USER_EENO,	 
		A.MDFY_DTM = SYSDATE()	 
	WHERE A.CLS_YMD = P_CLS_YMD	 
	AND A.MDL_MDY_CD = A.DL_EXPD_MDL_MDY_CD
	AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
	        FROM TB_VEHL_MGMT C	 
			WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
			AND C.DL_EXPD_CO_CD = P_EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 3;

	OPEN PDI_IV_LIST_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_LIST_INFO INTO V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1, V_N_PRNT_PBCN_NO_1,V_PRDN_PLNT_CD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

	CALL SP_RECALCULATE_PDI_IV_SUB(P_CLS_YMD,	 
							  V_QLTY_VEHL_CD_1,	 
							  V_DL_EXPD_MDL_MDY_CD_1,	 
							  V_LANG_CD_1,	 
							  V_N_PRNT_PBCN_NO_1,
							  V_PRDN_PLNT_CD_1
							);	 

	END LOOP JOBLOOP1 ;
	CLOSE PDI_IV_LIST_INFO;
	 

    SET CURR_LOC_NUM = 4;

	/*PDI 재고 재계산 작업이 이루어지면 이에 맞추어 세원 재고 재계산 작업도 이루어져야 한다.	 */
	CALL SP_RECALCULATE_SEWON_IV_DTL2(P_CLS_YMD,P_EXPD_CO_CD);


    SET CURR_LOC_NUM = 5;

	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;
	    

    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_PDI_IV_DTL3 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_PDI_IV_DTL3`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(4),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_PDI_IV_DTL3
 * Procedure 설명 : 재고상세 내역 재계산 작업수행
 * 입력 파라미터    :  P_CLS_YMD                   마감년월일
 *                 P_VEHL_CD                   차종코드
 *                 EXPD_CO_CD                  회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD				VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD		VARCHAR(4);
	DECLARE V_LANG_CD					VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO			VARCHAR(100);
	DECLARE V_PRDN_PLNT_CD				VARCHAR(3);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_LIST_INFO CURSOR FOR
		 						  	SELECT QLTY_VEHL_CD,	 
		 						 		   DL_EXPD_MDL_MDY_CD,	 
		 						  	 	   LANG_CD,	 
										   N_PRNT_PBCN_NO,	 
										   PRDN_PLNT_CD 
		 						  	FROM TB_PDI_IV_INFO	 
									/*재고수량이 0보다 큰 것 보다 현재일에 존재하는 모든 항목을 해 주어야 한다.	*/
									WHERE CLS_YMD = P_CLS_YMD	 
									AND QLTY_VEHL_CD = P_VEHL_CD	 
									GROUP BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD, PRDN_PLNT_CD  
									/*정렬조건을 아래와 같은 순서를 준수하여야 한다.	 */
									ORDER BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD;	

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow = TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_PDI_IV_DTL3',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_LANG_CD:',IFNULL(V_LANG_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,''))
							,SYSDATE()
			          		  );
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';

	/*취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.	 */
	DELETE FROM TB_PDI_IV_INFO_DTL	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND QLTY_VEHL_CD = P_VEHL_CD	 
	AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD;	 
	 

    SET CURR_LOC_NUM = 2;

	/*취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.	  */
	UPDATE TB_PDI_IV_INFO_DTL	 
	SET SFTY_IV_QTY = IV_QTY,	 
		UPDR_EENO = V_BATCH_USER_EENO,	 
		MDFY_DTM = SYSDATE()	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND QLTY_VEHL_CD = P_VEHL_CD	 
	AND MDL_MDY_CD = DL_EXPD_MDL_MDY_CD;


    SET CURR_LOC_NUM = 3;

	OPEN PDI_IV_LIST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_LIST_INFO INTO V_QLTY_VEHL_CD,V_DL_EXPD_MDL_MDY_CD,V_LANG_CD,V_N_PRNT_PBCN_NO,V_PRDN_PLNT_CD;

	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

	CALL SP_RECALCULATE_PDI_IV_SUB(P_CLS_YMD,	 
								V_QLTY_VEHL_CD,	 
								V_DL_EXPD_MDL_MDY_CD,	 
								V_LANG_CD,	 
								V_N_PRNT_PBCN_NO,
								V_PRDN_PLNT_CD
								);

	END LOOP JOBLOOP ;
	CLOSE PDI_IV_LIST_INFO;
	 

    SET CURR_LOC_NUM = 4;

	/*PDI 재고 재계산 작업이 이루어지면 이에 맞추어 세원 재고 재계산 작업도 이루어져야 한다.	 */
	CALL SP_RECALCULATE_SEWON_IV_DTL3(P_CLS_YMD,	 
									P_VEHL_CD,	 
									EXPD_CO_CD
									);


    SET CURR_LOC_NUM = 5;

	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;
	    

    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_PDI_IV_DTL4 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_PDI_IV_DTL4`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_PRDN_PLNT_CD VARCHAR(3))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_PDI_IV_DTL4
 * Procedure 설명 : 취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.
 *                 취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.
 *                 PDI 재고 재계산 작업이 이루어지면 이에 맞추어 세원 재고 재계산 작업도 이루어져야 한다.
 * 입력 파라미터    :  P_CLS_YMD                 마감년월일
 *                 P_VEHL_CD                 차종코드
 *                 P_LANG_CD                 언어코드
 *                 P_PRDN_PLNT_CD            생산공장코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO_1 VARCHAR(100);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_LIST_INFO CURSOR FOR
	   	        SELECT QLTY_VEHL_CD,	 
				 	   DL_EXPD_MDL_MDY_CD,	 
				  	   LANG_CD,	 
					   N_PRNT_PBCN_NO	 
				  FROM TB_PDI_IV_INFO	 
				/*재고수량이 0보다 큰 것 보다 현재일에 존재하는 모든 항목을 해 주어야 한다.	 */
				 WHERE CLS_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND LANG_CD = P_LANG_CD	 
				   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD	 
				 GROUP BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD	 
				/*정렬조건을 아래와 같은 순서를 준수하여야 한다.	 */
				 ORDER BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD;	 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_PDI_IV_DTL4',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			/*취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.	 */
			DELETE FROM TB_PDI_IV_INFO_DTL	 
			 WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 

    SET CURR_LOC_NUM = 2;

			/*취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.	 */
			UPDATE TB_PDI_IV_INFO_DTL	 
			   SET SFTY_IV_QTY = IV_QTY,	 
			       UPDR_EENO = V_BATCH_USER_EENO,	 
				   MDFY_DTM = SYSDATE()	 
			 WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   AND MDL_MDY_CD = DL_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;


    SET CURR_LOC_NUM = 3;

	OPEN PDI_IV_LIST_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_LIST_INFO INTO V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1,V_N_PRNT_PBCN_NO_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
 
				CALL SP_RECALCULATE_PDI_IV_SUB(P_CLS_YMD,	 
										  V_QLTY_VEHL_CD_1,	 
										  V_DL_EXPD_MDL_MDY_CD_1,	 
										  V_LANG_CD_1,	 
										  V_N_PRNT_PBCN_NO_1,	
										  P_PRDN_PLNT_CD
										  );

	END LOOP JOBLOOP1 ;
	CLOSE PDI_IV_LIST_INFO;
	 

    SET CURR_LOC_NUM = 4;

			/*PDI 재고 재계산 작업이 이루어지면 이에 맞추어 세원 재고 재계산 작업도 이루어져야 한다.	 */
			CALL SP_RECALCULATE_SEWON_IV_DTL4(P_CLS_YMD,	 
										 P_VEHL_CD,	 
										 P_LANG_CD,	 
										 P_PRDN_PLNT_CD
										 );	 

    SET CURR_LOC_NUM = 5;


	/*END;
	DELIMITER;
	다음처리*/
	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_PDI_IV_SUB 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_PDI_IV_SUB`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_PRDN_PLNT_CD VARCHAR(3))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_PDI_IV_SUB
 * Procedure 설명 : 재고상세 내역 재계산 세부작업 수행(배치 프로그램 전용)
 *                 전방통합, 전체통합과 같이 이전 연식의 수량을 이후 연식에서 사용할 경우를 대비하여
 *                   차종연식과 취급설명서 연식이 같은 경우도 가져와야 한다.
 *                 차종연식과 취급설명서 연식이 같은 경우도 가져와서 계산하게 되면 수량이 남더라도
 *                   이전연식의 안전재고수량은 무조건 2주생산계획 만큼만 남게 되고 나머지 수량은 가장 최근의 연식으로 포함되게 된다.
 *                   그래서 다시 차종연식과 취급설명서 연식이 같은 경우는 제외하도록 하고 로직에서 위의 문제를 해결하도록 한다.
 *                 취급설명서 연식의 3일생산 계획 데이터 조회
 *                 2주 생산계획과 안전재고의 차이가 0 보다 큰 경우에만 계산 작업을 진행한다.
 *                 (왜냐하면 사전에 초기화 한 상태에서 진행하므로 순수하게 현재 연식에 관계된 것만 있으므로 0 보다 작으면
 *                  재고가 충분하다는 것이므로 작업할 필요가 없다.)
 * 입력 파라미터    :  P_CLS_YMD                   마감년월일
 *                 P_VEHL_CD                   차종코드
 *                 P_EXPD_MDL_MDY_CD           취급설명서모델년식코드
 *                 P_LANG_CD                   언어코드(KO 한글/국내, EU 영어/미국,..)
 *                 P_N_PRNT_PBCN_NO            신인쇄발간번호
 *                 P_PRDN_PLNT_CD              생산공장코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-05     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_MDL_MDY_CD		VARCHAR(2);	 
	DECLARE V_CURR_DAY3_PLAN_QTY	INT;	 
	DECLARE V_CURR_SFTY_IV_QTY		INT;	 
	DECLARE V_SFTY_IV_DIFF_QTY		INT;	 
	DECLARE V_SFTY_IV_DIFF 			INT;	 
	DECLARE V_DL_IV_QTY				INT;	 
	DECLARE V_DL_CMPL_YN			VARCHAR(1);	 
	DECLARE V_DL_TMP_TRTM_YN		VARCHAR(1);	 
	DECLARE V_DL_DAY3_PLAN_QTY		INT;	 
	DECLARE V_CURR_IV_QTY			INT;	 
	DECLARE V_TEMP_IV_QTY			INT;	 
	DECLARE V_FLAG					VARCHAR(1); 
	DECLARE V_DL_MDL_MDY_CD		    VARCHAR(4);	
	DECLARE V_EXCNT			        INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_DTL_LIST_INFO CURSOR FOR
									    SELECT T.MDL_MDY_CD	 
									    FROM (	 
											  /*[변경2]차종연식과 취급설명서 연식이 같은 경우도 가져와서 계산하게 되면 수량이 남더라도	 
											  이전연식의 안전재고수량은 무조건 2주생산계획 만큼만 남게 되고 나머지 수량은 가장 최근의 연식으로 포함되게 된다.	 
											  이것 역시 문제가 될 수 있다.	 
											  그래서 다시 차종연식과 취급설명서 연식이 같은 경우는 제외하도록 하고 로직에서 [변경1]의 문제를 해결하도록 한다.	 
										      [변경1]전방통합, 전체통합과 같이 이전 연식의 수량을 이후 연식에서 사용할 경우를 대비하여	 
											  차종연식과 취급설명서 연식이 같은 경우도 가져와야 한다.	 */
											  SELECT MDL_MDY_CD	 
                                                FROM TB_PDI_WHSN_INFO	 
											   WHERE WHSN_YMD = P_CLS_YMD	 
											     AND QLTY_VEHL_CD = P_VEHL_CD	 
											     AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
											     AND LANG_CD = P_LANG_CD	 
											     AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
											     /*차종연식과 취급설명서 연식이 다른 항목만을 가져온다.	  */
                                                 AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD	 
                                                 AND PRDN_PLNT_CD = P_PRDN_PLNT_CD	 
											   GROUP BY MDL_MDY_CD	 
	 
											   UNION ALL	 
	 
											  SELECT MDL_MDY_CD	 
											    FROM TB_PDI_WHOT_INFO	 
											   WHERE WHOT_YMD = P_CLS_YMD	 
											     AND QLTY_VEHL_CD = P_VEHL_CD	 
											     AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
											     AND LANG_CD = P_LANG_CD	 
											     AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
											     /*차종연식과 취급설명서 연식이 다른 항목만을 가져온다.	  */
											     AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD	 
											     AND DEL_YN = 'N'	 
											     AND PRDN_PLNT_CD = P_PRDN_PLNT_CD	 
											   GROUP BY MDL_MDY_CD	 
	 
											  UNION ALL	 
	 
											  SELECT A.MDL_MDY_CD	 
											    FROM TB_LANG_MGMT A,	 
     										         TB_DL_EXPD_MDY_MGMT B,	 
	 											     TB_PDI_IV_INFO C	 
                                               WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											     AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
			 			 		   			     AND A.DL_EXPD_REGN_CD = B.DL_EXPD_REGN_CD	 
											     AND A.QLTY_VEHL_CD = C.QLTY_VEHL_CD	 
											     AND B.DL_EXPD_MDL_MDY_CD = C.DL_EXPD_MDL_MDY_CD	 
											     AND A.LANG_CD = C.LANG_CD	 
											     /*차종연식과 취급설명서 연식이 다른 항목만을 가져온다.	  */
											     AND B.MDL_MDY_CD <> B.DL_EXPD_MDL_MDY_CD	 
											     AND C.CLS_YMD = P_CLS_YMD	 
											     AND C.QLTY_VEHL_CD = P_VEHL_CD	 
											     AND C.DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
											     AND C.LANG_CD = P_LANG_CD	 
											     AND C.N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
											     AND PRDN_PLNT_CD = P_PRDN_PLNT_CD	 
											   GROUP BY A.MDL_MDY_CD	 
										     ) T	 
										GROUP BY T.MDL_MDY_CD	 
										/*정렬순서를 아래와 같이 하여야 한다.	  */
										ORDER BY T.MDL_MDY_CD;	



	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_PDI_IV_SUB',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',V_CURR_MDL_MDY_CD:',IFNULL(V_CURR_MDL_MDY_CD,'')
							,',V_DL_CMPL_YN:',IFNULL(V_DL_CMPL_YN,'')
							,',V_DL_TMP_TRTM_YN:',IFNULL(V_DL_TMP_TRTM_YN,'')
							,',V_FLAG:',IFNULL(V_FLAG,'')
							,',V_DL_MDL_MDY_CD:',IFNULL(V_DL_MDL_MDY_CD,'')
							,',V_CURR_DAY3_PLAN_QTY:',IFNULL(CONCAT(V_CURR_DAY3_PLAN_QTY),'')
							,',V_CURR_SFTY_IV_QTY:',IFNULL(CONCAT(V_CURR_SFTY_IV_QTY),'')
							,',V_SFTY_IV_DIFF_QTY:',IFNULL(CONCAT(V_SFTY_IV_DIFF_QTY),'')
							,',V_SFTY_IV_DIFF:',IFNULL(CONCAT(V_SFTY_IV_DIFF),'')
							,',V_DL_IV_QTY:',IFNULL(CONCAT(V_DL_IV_QTY),'')
							,',V_DL_DAY3_PLAN_QTY:',IFNULL(CONCAT(V_DL_DAY3_PLAN_QTY),'')
							,',V_CURR_IV_QTY:',IFNULL(CONCAT(V_CURR_IV_QTY),'')
							,',V_TEMP_IV_QTY:',IFNULL(CONCAT(V_TEMP_IV_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
                                        

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';


			SELECT MAX(IV_QTY),	 
				   MAX(CMPL_YN),	 
				   MAX(TMP_TRTM_YN)	 
			INTO V_DL_IV_QTY,	 
				 V_DL_CMPL_YN,	 
				 V_DL_TMP_TRTM_YN	 
			FROM TB_PDI_IV_INFO	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 

    SET CURR_LOC_NUM = 2;

			/*취급설명서 연식의 3일생산 계획 데이터 조회	  */
			IF P_VEHL_CD = 'PS' OR P_VEHL_CD = 'AM' OR P_VEHL_CD = 'SK3' THEN	 
				SELECT IFNULL(SUM(TDD_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
				  INTO V_DL_DAY3_PLAN_QTY	 
				  FROM TB_PLNT_APS_PROD_SUM_INFO	 
				 WHERE APL_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				   AND LANG_CD = P_LANG_CD	 
				   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
			ELSE	 
				SELECT IFNULL(SUM(TDD_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
				  INTO V_DL_DAY3_PLAN_QTY	 
				  FROM TB_APS_PROD_SUM_INFO	 
				 WHERE APL_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				   AND LANG_CD = P_LANG_CD;
			END IF;
	 

    SET CURR_LOC_NUM = 3;

			SET V_CURR_IV_QTY = V_DL_IV_QTY;

	OPEN PDI_IV_DTL_LIST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_DTL_LIST_INFO INTO V_DL_MDL_MDY_CD;
	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

				SET V_CURR_MDL_MDY_CD = V_DL_MDL_MDY_CD;
				IF P_VEHL_CD = 'PS' OR P_VEHL_CD = 'AM' OR P_VEHL_CD = 'SK3' THEN	 
					SELECT IFNULL(SUM(TDD_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
					  INTO V_CURR_DAY3_PLAN_QTY	 
					  FROM TB_PLNT_APS_PROD_SUM_INFO	 
					 WHERE APL_YMD = P_CLS_YMD	 
					   AND QLTY_VEHL_CD = P_VEHL_CD	 
					   AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
					   AND LANG_CD = P_LANG_CD	 
					   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
				ELSE	 
					/*3일 생산 계획 데이터 조회	  */
					SELECT IFNULL(SUM(TDD_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
					  INTO V_CURR_DAY3_PLAN_QTY	 
					  FROM TB_APS_PROD_SUM_INFO	 
					 WHERE APL_YMD = P_CLS_YMD	 
					   AND QLTY_VEHL_CD = P_VEHL_CD	 
					   AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
					   AND LANG_CD = P_LANG_CD;	 
				END IF;
	 
				/*현재 안전재고 수량 조회	  */
				SELECT IFNULL(SUM(SFTY_IV_QTY), 0)	 
				  INTO V_CURR_SFTY_IV_QTY	 
				  FROM TB_PDI_IV_INFO_DTL	 
				 WHERE CLS_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
				   AND LANG_CD = P_LANG_CD	 
				   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 
				SET V_SFTY_IV_DIFF_QTY = V_CURR_DAY3_PLAN_QTY - V_CURR_SFTY_IV_QTY;	 
	 
				/*2주 생산계획과 안전재고의 차이가 0 보다 큰 경우에만 계산 작업을 진행한다.	 
				(왜냐하면 사전에 초기화 한 상태에서 진행하므로 순수하게 현재 연식에 관계된 것만 있으므로 0 보다 작으면	 
				 재고가 충분하다는 것이므로 작업할 필요가 없다.)	 */
				IF V_SFTY_IV_DIFF_QTY > 0 THEN
				   /*재계산할 재고수량이 존재하는 경우에만 재계산 작업을 수행한다.	  */
				   IF V_CURR_IV_QTY > 0 THEN
					  /*재계산할 연식이 취급설명서 연식보다 이전 연식이라면	 
					  재계산 작업을 수행한다.	 */
					  IF V_CURR_MDL_MDY_CD <= P_EXPD_MDL_MDY_CD THEN
				   	  	 IF V_SFTY_IV_DIFF_QTY >= V_CURR_IV_QTY THEN
					  	 	SET V_SFTY_IV_DIFF = V_CURR_IV_QTY;	 
					  	 	SET V_CURR_IV_QTY  = 0;
				   	  	 ELSE
					  	 	SET V_SFTY_IV_DIFF = V_SFTY_IV_DIFF_QTY;	 
					  	 	SET V_CURR_IV_QTY  = V_CURR_IV_QTY - V_SFTY_IV_DIFF_QTY;
				         END IF;	 
	 
						 SET V_FLAG = 'Y';	 
	 
					  /*재계산할 연식이 취급설명서 연식보다 최근 연식이라면	 
					  이전연식의 2주생산계획 수량보다 재고수량이 큰 경우에만 작업해 주도록 한다.	*/ 
				   	  ELSE
						  SELECT IFNULL(SUM(SFTY_IV_QTY), 0)	 
						    INTO V_TEMP_IV_QTY	 
						    FROM TB_PDI_IV_INFO_DTL	 
						   WHERE CLS_YMD = P_CLS_YMD	 
						     AND QLTY_VEHL_CD = P_VEHL_CD	 
						     AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
						     AND LANG_CD = P_LANG_CD	 
						     AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	 
	 
						  SET V_TEMP_IV_QTY = V_TEMP_IV_QTY - V_DL_DAY3_PLAN_QTY;	 
	 
						  IF V_TEMP_IV_QTY > 0 THEN
							 IF V_CURR_IV_QTY < V_TEMP_IV_QTY THEN
								SET V_TEMP_IV_QTY = V_CURR_IV_QTY;
							 END IF;	 
	 
							 IF V_SFTY_IV_DIFF_QTY >= V_TEMP_IV_QTY THEN
					  	  	 	SET V_SFTY_IV_DIFF = V_TEMP_IV_QTY;	 
					  	 	 	SET V_CURR_IV_QTY  = V_CURR_IV_QTY - V_TEMP_IV_QTY;
				   	  	     ELSE
					  	 	 	SET V_SFTY_IV_DIFF = V_SFTY_IV_DIFF_QTY;	 
					  	 	 	SET V_CURR_IV_QTY  = V_CURR_IV_QTY - V_SFTY_IV_DIFF_QTY;
				             END IF;	 
	 
							 SET V_FLAG = 'Y';	
						  ELSE
							  SET V_FLAG         = 'N';	 
							  SET V_SFTY_IV_DIFF = 0;	 
						  END IF;
					  END IF; /*이전연식여부 비교 End */
				   ELSE
					   SET V_FLAG         = 'N';	 
					   SET V_SFTY_IV_DIFF = 0;	 
				   END IF; /*재계산할 재고수량 존재여부 확인 End */
				ELSE
					SET V_FLAG         = 'N';	 
					SET V_SFTY_IV_DIFF = 0;
				END IF; /*2주생산 계획 수량 존재여부 확인 End	 */ 
	 
				/*재고 재계산에 의하여 취급설명서 연식의 안전재고 수량이 변경된 경우	  */
				IF V_FLAG = 'Y' THEN
				   /*차종연식과 취급설명서연식이 같은 항목에	 
				   재고 상세 재계산 후 남은 수량을 업데이트 해 준다.	 */
				   UPDATE TB_PDI_IV_INFO_DTL	 
				      SET SFTY_IV_QTY        = V_CURR_IV_QTY,	 
					      UPDR_EENO          = V_BATCH_USER_EENO,	 
					      MDFY_DTM           = SYSDATE()	 
				    WHERE CLS_YMD          = P_CLS_YMD	 
				      AND QLTY_VEHL_CD       = P_VEHL_CD	 
				      AND MDL_MDY_CD         = P_EXPD_MDL_MDY_CD	 
				      AND LANG_CD            = P_LANG_CD	 
				      AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				      AND N_PRNT_PBCN_NO     = P_N_PRNT_PBCN_NO	 
				      AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
				END IF;	 
	 
				UPDATE TB_PDI_IV_INFO_DTL	 
				   SET IV_QTY = V_DL_IV_QTY,	 
				       SFTY_IV_QTY = V_SFTY_IV_DIFF,	 
				   	   CMPL_YN = V_DL_CMPL_YN,	 
					   UPDR_EENO = V_BATCH_USER_EENO,	 
					   MDFY_DTM = SYSDATE(),	 
					   TMP_TRTM_YN = V_DL_TMP_TRTM_YN	 
				 WHERE CLS_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
				   AND LANG_CD = P_LANG_CD	 
				   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
				   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;	

				SET V_EXCNT = 0;
				SELECT COUNT(CLS_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PDI_IV_INFO_DTL
				 WHERE CLS_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
				   AND LANG_CD = P_LANG_CD	 
				   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
				   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;

				IF V_EXCNT = 0 THEN
				   INSERT INTO TB_PDI_IV_INFO_DTL	 
				   (CLS_YMD,	 
				    QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					DL_EXPD_MDL_MDY_CD,	 
					N_PRNT_PBCN_NO,	  
					PRDN_PLNT_CD,	
					IV_QTY,	 
					SFTY_IV_QTY,	 
					CMPL_YN,	 
					PPRR_EENO,	 
					FRAM_DTM,	 
					UPDR_EENO,	 
					MDFY_DTM,	 
					TMP_TRTM_YN	 
				   )	 
				   VALUES	 
				   (P_CLS_YMD,	 
				    P_VEHL_CD,	 
					V_CURR_MDL_MDY_CD,	 
					P_LANG_CD,	 
					P_EXPD_MDL_MDY_CD,	 
					P_N_PRNT_PBCN_NO,	 
					P_PRDN_PLNT_CD,	  
					V_DL_IV_QTY,	 
					V_SFTY_IV_DIFF,	 
					V_DL_CMPL_YN,	 
					V_BATCH_USER_EENO,	 
					SYSDATE(),	 
					V_BATCH_USER_EENO,	 
					SYSDATE(),	 
					V_DL_TMP_TRTM_YN	
				   );
				END IF; 
	 

	END LOOP JOBLOOP ;
	CLOSE PDI_IV_DTL_LIST_INFO;



    SET CURR_LOC_NUM = 4;

	

	/*END;
	DELIMITER;
	다음처리*/
	    



	COMMIT;
	    

    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_SEWON_IV_DTL2 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_SEWON_IV_DTL2`(IN P_CLS_YMD VARCHAR(8),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_SEWON_IV_DTL2
 * Procedure 설명 : 재고상세 내역 재계산 작업 수행(배치 프로그램 전용)	
 * 입력 파라미터    :  P_CLS_YMD                   마감년월일
 *                 EXPD_CO_CD                  회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD				VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD		VARCHAR(4);
	DECLARE V_LANG_CD					VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO			VARCHAR(100);
	DECLARE V_PRDN_PLNT_CD				VARCHAR(3);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE SEWON_IV_LIST_INFO CURSOR FOR
		 						  	  SELECT A.QLTY_VEHL_CD,	 
		 						   	  		 A.DL_EXPD_MDL_MDY_CD,	 
		 						  	 	     A.LANG_CD,	 
										     A.N_PRNT_PBCN_NO,	 
                                             A.PRDN_PLNT_CD 
		 						  	  FROM TB_SEWON_IV_INFO	A 
									  /*재고수량이 0보다 큰 것 보다 현재일에 존재하는 모든 항목을 해 주어야 한다.	*/
									  WHERE A.CLS_YMD = P_CLS_YMD
									  AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
							                        FROM TB_VEHL_MGMT C	 
										            WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
										            AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0
									  GROUP BY A.QLTY_VEHL_CD, A.LANG_CD, A.N_PRNT_PBCN_NO, A.DL_EXPD_MDL_MDY_CD, A.PRDN_PLNT_CD
									  /*정렬조건을 아래와 같은 순서를 준수하여야 한다.	 */
									  ORDER BY A.QLTY_VEHL_CD, A.LANG_CD, A.N_PRNT_PBCN_NO, A.DL_EXPD_MDL_MDY_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_SEWON_IV_DTL2',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_LANG_CD:',IFNULL(V_LANG_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			/*취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.	 */
			DELETE FROM TB_SEWON_IV_INFO_DTL
			WHERE CLS_YMD = P_CLS_YMD	 
			AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
				FROM TB_VEHL_MGMT C	 
				WHERE C.QLTY_VEHL_CD = QLTY_VEHL_CD
				AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;
	 

    SET CURR_LOC_NUM = 2;

			/*취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.	 */
			UPDATE TB_SEWON_IV_INFO_DTL	A 
			SET A.SFTY_IV_QTY = IV_QTY,	 
			    A.UPDR_EENO = V_BATCH_USER_EENO,	 
				A.MDFY_DTM = SYSDATE()	 
			WHERE A.CLS_YMD = P_CLS_YMD	 
			AND A.MDL_MDY_CD = A.DL_EXPD_MDL_MDY_CD
			AND  (SELECT COUNT(C.QLTY_VEHL_CD)	 
				FROM TB_VEHL_MGMT C	 
				WHERE C.QLTY_VEHL_CD = A.QLTY_VEHL_CD
				AND C.DL_EXPD_CO_CD = EXPD_CO_CD)>0;


    SET CURR_LOC_NUM = 3;


	OPEN SEWON_IV_LIST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_LIST_INFO INTO V_QLTY_VEHL_CD,V_DL_EXPD_MDL_MDY_CD,V_LANG_CD,V_N_PRNT_PBCN_NO,V_PRDN_PLNT_CD;
	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

				CALL SP_RECALCULATE_SEWON_IV_SUB(P_CLS_YMD,	 
										    V_QLTY_VEHL_CD,	 
										    V_DL_EXPD_MDL_MDY_CD,	 
										    V_LANG_CD,	 
										    V_N_PRNT_PBCN_NO,	
                                            V_PRDN_PLNT_CD
										    );

	END LOOP JOBLOOP ;
	CLOSE SEWON_IV_LIST_INFO;
	 


    SET CURR_LOC_NUM = 4;

	/*END;
	DELIMITER;
	다음처리*/



	COMMIT;
	    

    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_SEWON_IV_DTL3 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_SEWON_IV_DTL3`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_SEWON_IV_DTL3
 * Procedure 설명 : 재고상세 내역 재계산 작업 수행
 * 입력 파라미터    :  P_CLS_YMD                종료년월일
 *                 P_VEHL_CD                품질차종코드
 *                 P_EXPD_CO_CD             회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD				VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD		VARCHAR(4);
	DECLARE V_LANG_CD					VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO			VARCHAR(100);
	DECLARE V_PRDN_PLNT_CD				VARCHAR(3);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE SEWON_IV_LIST_INFO CURSOR FOR
		 						  	  SELECT QLTY_VEHL_CD,	 
		 						   	  		 DL_EXPD_MDL_MDY_CD,	 
		 						  	 	     LANG_CD,	 
										     N_PRNT_PBCN_NO,	 
										     PRDN_PLNT_CD	 
		 						  	  FROM TB_SEWON_IV_INFO	 
									  /*재고수량이 0보다 큰 것 보다 현재일에 존재하는 모든 항목을 해 주어야 한다.	 */
									  WHERE CLS_YMD = P_CLS_YMD	 
									  AND QLTY_VEHL_CD = P_VEHL_CD	 
									  GROUP BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD, PRDN_PLNT_CD 
									  /*정렬조건을 아래와 같은 순서를 준수하여야 한다.	 */
									  ORDER BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_SEWON_IV_DTL3',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')							
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_LANG_CD:',IFNULL(V_LANG_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';

	/*취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.	 */
	DELETE FROM TB_SEWON_IV_INFO_DTL	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND QLTY_VEHL_CD = P_VEHL_CD	 
	AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD;	 
	 

    SET CURR_LOC_NUM = 2;

	/*취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.	 */
	UPDATE TB_SEWON_IV_INFO_DTL	 
	SET SFTY_IV_QTY = IV_QTY,	 
	    UPDR_EENO = V_BATCH_USER_EENO,	 
		MDFY_DTM = SYSDATE()	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND QLTY_VEHL_CD = P_VEHL_CD	 
	AND MDL_MDY_CD = DL_EXPD_MDL_MDY_CD;	


    SET CURR_LOC_NUM = 3;

	OPEN SEWON_IV_LIST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_LIST_INFO INTO V_QLTY_VEHL_CD,V_DL_EXPD_MDL_MDY_CD,V_LANG_CD,V_N_PRNT_PBCN_NO,V_PRDN_PLNT_CD;
	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

				CALL SP_RECALCULATE_SEWON_IV_SUB(P_CLS_YMD,	 
										    V_QLTY_VEHL_CD,	 
										    V_DL_EXPD_MDL_MDY_CD,	 
										    V_LANG_CD,	 
										    V_N_PRNT_PBCN_NO,	 
										    V_PRDN_PLNT_CD
										    );

	END LOOP JOBLOOP ;
	CLOSE SEWON_IV_LIST_INFO;	 


    SET CURR_LOC_NUM = 4;

	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;
	    

    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_SEWON_IV_DTL4 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_SEWON_IV_DTL4`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_PRDN_PLNT_CD VARCHAR(3))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_SEWON_IV_DTL4
 * Procedure 설명 : 재고상세 내역 재계산 작업 수행
 *                 취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.
 *                 취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.
 * 입력 파라미터    :  P_CLS_YMD             종료년월일
 *                 P_VEHL_CD             품질차종코드
 *                 P_LANG_CD             언어코드(KO 한글/국내, EU 영어/미국,..)
 *                 P_PRDN_PLNT_CD        생산공장코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QLTY_VEHL_CD				VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD		VARCHAR(4);
	DECLARE V_LANG_CD					VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO			VARCHAR(100);
	DECLARE V_PRDN_PLNT_CD				VARCHAR(3);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE SEWON_IV_LIST_INFO CURSOR FOR
		 		  SELECT QLTY_VEHL_CD,	 
		 			   DL_EXPD_MDL_MDY_CD,	 
		 			   LANG_CD,	 
					   N_PRNT_PBCN_NO,	 
					   PRDN_PLNT_CD
		 		  FROM TB_SEWON_IV_INFO	 
				/*재고수량이 0보다 큰 것 보다 현재일에 존재하는 모든 항목을 해 주어야 한다.	 */	 
				 WHERE CLS_YMD = P_CLS_YMD	 
				   AND QLTY_VEHL_CD = P_VEHL_CD	 
				   AND LANG_CD = P_LANG_CD	 
				 GROUP BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD, PRDN_PLNT_CD 
				/*정렬조건을 아래와 같은 순서를 준수하여야 한다.	 */
				 ORDER BY QLTY_VEHL_CD, LANG_CD, N_PRNT_PBCN_NO, DL_EXPD_MDL_MDY_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_SEWON_IV_DTL4',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_LANG_CD:',IFNULL(V_LANG_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';

	/*취급설명서 연식과 차종연식이 다른 항목은 우선 삭제한다.	 */
	DELETE FROM TB_SEWON_IV_INFO_DTL	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND QLTY_VEHL_CD = P_VEHL_CD	 
	AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD	 
	AND LANG_CD = P_LANG_CD;	 
	 

    SET CURR_LOC_NUM = 2;

	/*취급설명서 연식과 차종연식이 같은 경우에는 안전재고수량을 재고수량으로 업데이트 해 준다.	 */
	UPDATE TB_SEWON_IV_INFO_DTL	 
	SET SFTY_IV_QTY = IV_QTY,	 
	    UPDR_EENO = V_BATCH_USER_EENO,	 
		MDFY_DTM = SYSDATE()	 
	WHERE CLS_YMD = P_CLS_YMD	 
	AND QLTY_VEHL_CD = P_VEHL_CD	 
	AND MDL_MDY_CD = DL_EXPD_MDL_MDY_CD	 
	AND LANG_CD = P_LANG_CD;	 


    SET CURR_LOC_NUM = 3;


	OPEN SEWON_IV_LIST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_LIST_INFO INTO V_QLTY_VEHL_CD,V_DL_EXPD_MDL_MDY_CD,V_LANG_CD,V_N_PRNT_PBCN_NO,V_PRDN_PLNT_CD;
	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

				CALL SP_RECALCULATE_SEWON_IV_SUB(P_CLS_YMD,	 
										    V_QLTY_VEHL_CD,	 
										    V_DL_EXPD_MDL_MDY_CD,	 
										    V_LANG_CD,	 
										    V_N_PRNT_PBCN_NO,	
										    V_PRDN_PLNT_CD
										    );

	END LOOP JOBLOOP ;
	CLOSE SEWON_IV_LIST_INFO;


    SET CURR_LOC_NUM = 4;

	/*END;
	DELIMITER;
	다음처리*/

	 
	COMMIT;
	    

    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_RECALCULATE_SEWON_IV_SUB 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_RECALCULATE_SEWON_IV_SUB`(IN P_CLS_YMD VARCHAR(8),
                                        IN P_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_PRDN_PLNT_CD VARCHAR(3))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_RECALCULATE_SEWON_IV_SUB
 * Procedure 설명 : 재고 상세 내역 재계산 작업
 *                 전방통합, 전체통합과 같이 이전 연식의 수량을 이후 연식에서 사용할 경우를 대비하여	
 *                   차종연식과 취급설명서 연식이 같은 경우도 가져와야 한다.
 *                 차종연식과 취급설명서 연식이 같은 경우도 가져와서 계산하게 되면 수량이 남더라도
 *                   이전연식의 안전재고수량은 무조건 2주생산계획 만큼만 남게 되고 나머지 수량은 가장 최근의 연식으로 포함되게 된다.
 *                   그래서 다시 차종연식과 취급설명서 연식이 같은 경우는 제외하도록 하고 로직에서 위의 문제를 해결하도록 한다.	
 *                 취급설명서 연식의 2주생산 계획 데이터 조회
 *                 2주 생산계획과 안전재고의 차이가 0 보다 큰 경우에만 계산 작업을 진행한다.
 *                 (왜냐하면 사전에 초기화 한 상태에서 진행하므로 순수하게 현재 연식에 관계된 것만 있으므로 0 보다 작으면
 *                  재고가 충분하다는 것이므로 작업할 필요가 없다.)
 * 입력 파라미터    :  P_CLS_YMD                   마감년월일
 *                 P_VEHL_CD                   차종코드
 *                 P_EXPD_MDL_MDY_CD           취급설명서모델년식코드
 *                 P_LANG_CD                   언어코드(KO 한글/국내, EU 영어/미국,..)
 *                 P_N_PRNT_PBCN_NO            신인쇄발간번호
 *                 P_PRDN_PLNT_CD              생산공장코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-05     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CURR_MDL_MDY_CD		VARCHAR(2);	 
	DECLARE V_CURR_WEK2_PLAN_QTY	INT;	 
	DECLARE V_CURR_SFTY_IV_QTY		INT;	 
	DECLARE V_CURR_PDI_IV_QTY		INT;	 
	DECLARE V_SFTY_IV_DIFF_QTY		INT;	 
	DECLARE V_SFTY_IV_DIFF 			INT;	 
	DECLARE V_DL_IV_QTY				INT;	 
	DECLARE V_DL_PDI_IV_QTY			INT;	 
	DECLARE V_DL_EXPD_TMP_IV_QTY	INT;	 
	DECLARE V_DL_CMPL_YN			VARCHAR(1);	 
	DECLARE V_DL_TMP_TRTM_YN		VARCHAR(1);	 
	DECLARE V_DL_WEK2_PLAN_QTY		INT;	 
	DECLARE V_CURR_IV_QTY			INT;	 
	DECLARE V_TEMP_IV_QTY			INT;	 
	DECLARE V_FLAG					VARCHAR(1); 
	DECLARE V_MDL_MDY_CD			VARCHAR(4);
	DECLARE V_EXCNT			        INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE SEWON_IV_DTL_LIST_INFO CURSOR FOR
									      SELECT T.MDL_MDY_CD	 
									      FROM (	 
										        /*[변경2]차종연식과 취급설명서 연식이 같은 경우도 가져와서 계산하게 되면 수량이 남더라도	 
												이전연식의 안전재고수량은 무조건 2주생산계획 만큼만 남게 되고 나머지 수량은 가장 최근의 연식으로 포함되게 된다.	 
												이것 역시 문제가 될 수 있다.	 
												그래서 다시 차종연식과 취급설명서 연식이 같은 경우는 제외하도록 하고 로직에서 [변경1]의 문제를 해결하도록 한다.	 
										        [변경1]전방통합, 전체통합과 같이 이전 연식의 수량을 이후 연식에서 사용할 경우를 대비하여	 
												차종연식과 취급설명서 연식이 같은 경우도 가져와야 한다.	*/
											    SELECT MDL_MDY_CD	 
											    FROM TB_SEWON_WHOT_INFO	 
												WHERE WHOT_YMD = P_CLS_YMD	 
												AND QLTY_VEHL_CD = P_VEHL_CD	 
												AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
												AND LANG_CD = P_LANG_CD	 
												AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
												/*차종연식과 취급설명서 연식이 다른 항목만을 가져온다.	  */
											    AND MDL_MDY_CD <> DL_EXPD_MDL_MDY_CD	 
												AND DEL_YN = 'N'	 
												AND PRDN_PLNT_CD = P_PRDN_PLNT_CD   /* 광주분리(단독프로시져에는 없음) */
												GROUP BY MDL_MDY_CD	 
	 
											    UNION ALL	 
	 
											    SELECT A.MDL_MDY_CD	 
											    FROM TB_LANG_MGMT A,	 
     										         TB_DL_EXPD_MDY_MGMT B,	 
	 											     TB_SEWON_IV_INFO C	 
                                                WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
											    AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
			 			 		   			    AND A.DL_EXPD_REGN_CD = B.DL_EXPD_REGN_CD	 
											    AND A.QLTY_VEHL_CD = C.QLTY_VEHL_CD	 
											    AND B.DL_EXPD_MDL_MDY_CD = C.DL_EXPD_MDL_MDY_CD	 
											    AND A.LANG_CD = C.LANG_CD	 
											    /*차종연식과 취급설명서 연식이 다른 항목만을 가져온다.	  */
											    AND B.MDL_MDY_CD <> B.DL_EXPD_MDL_MDY_CD	 
											    AND C.CLS_YMD = P_CLS_YMD	 
											    AND C.QLTY_VEHL_CD = P_VEHL_CD	 
											    AND C.DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
											    AND C.LANG_CD = P_LANG_CD	 
											    AND C.N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
											    AND C.PRDN_PLNT_CD = P_PRDN_PLNT_CD   /* 광주분리(단독프로시져에는 없음) */
											    GROUP BY A.MDL_MDY_CD
											    ) T
										  GROUP BY T.MDL_MDY_CD
										  ORDER BY T.MDL_MDY_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_RECALCULATE_SEWON_IV_SUB',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',V_CURR_MDL_MDY_CD:',IFNULL(V_CURR_MDL_MDY_CD,'')
							,',V_DL_CMPL_YN:',IFNULL(V_DL_CMPL_YN,'')
							,',V_DL_TMP_TRTM_YN:',IFNULL(V_DL_TMP_TRTM_YN,'')
							,',V_FLAG:',IFNULL(V_FLAG,'')
							,',V_MDL_MDY_CD:',IFNULL(V_MDL_MDY_CD,'')
							,',V_CURR_WEK2_PLAN_QTY:',IFNULL(CONCAT(V_CURR_WEK2_PLAN_QTY),'')
							,',V_CURR_SFTY_IV_QTY:',IFNULL(CONCAT(V_CURR_SFTY_IV_QTY),'')
							,',V_CURR_PDI_IV_QTY:',IFNULL(CONCAT(V_CURR_PDI_IV_QTY),'')
							,',V_SFTY_IV_DIFF_QTY:',IFNULL(CONCAT(V_SFTY_IV_DIFF_QTY),'')
							,',V_SFTY_IV_DIFF:',IFNULL(CONCAT(V_SFTY_IV_DIFF),'')
							,',V_DL_IV_QTY:',IFNULL(CONCAT(V_DL_IV_QTY),'')
							,',V_DL_PDI_IV_QTY:',IFNULL(CONCAT(V_DL_PDI_IV_QTY),'')
							,',V_DL_EXPD_TMP_IV_QTY:',IFNULL(CONCAT(V_DL_EXPD_TMP_IV_QTY),'')
							,',V_DL_WEK2_PLAN_QTY:',IFNULL(CONCAT(V_DL_WEK2_PLAN_QTY),'')
							,',V_CURR_IV_QTY:',IFNULL(CONCAT(V_CURR_IV_QTY),'')
							,',V_TEMP_IV_QTY:',IFNULL(CONCAT(V_TEMP_IV_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			SELECT MAX(IV_QTY),	 
				   MAX(DL_EXPD_TMP_IV_QTY),	 
				   MAX(CMPL_YN),	 
				   MAX(TMP_TRTM_YN)	 
			INTO V_DL_IV_QTY,	 
			     V_DL_EXPD_TMP_IV_QTY,	 
				 V_DL_CMPL_YN,	 
				 V_DL_TMP_TRTM_YN	 
			FROM TB_SEWON_IV_INFO	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO 
			AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                    WHEN P_PRDN_PLNT_CD='6' THEN '7'
												ELSE P_PRDN_PLNT_CD END;  /* 광주분리(원프로시져에는 decode가 없음)	 */
			

    SET CURR_LOC_NUM = 2;

			/*취급설명서 연식의 2주생산 계획 데이터 조회	  */
			IF P_VEHL_CD = 'PS' OR P_VEHL_CD = 'AM' OR P_VEHL_CD = 'SK3' THEN	   /* 원프로시져에는 SK로 되어 있음 */
				SELECT IFNULL(SUM(WEK2_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
				INTO V_DL_WEK2_PLAN_QTY	 
				FROM TB_PLNT_APS_PROD_SUM_INFO	 
				WHERE APL_YMD = P_CLS_YMD	 
				AND QLTY_VEHL_CD = P_VEHL_CD	 
				AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				AND LANG_CD = P_LANG_CD	 
				AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                        WHEN P_PRDN_PLNT_CD='6' THEN '7'
												    ELSE P_PRDN_PLNT_CD END;  /* 광주분리(원프로시져에는 decode가 없음)	 */
	 
			ELSE	 
                /*취급설명서 연식의 2주생산 계획 데이터 조회	  */
				SELECT IFNULL(SUM(WEK2_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
				INTO V_DL_WEK2_PLAN_QTY	 
				FROM TB_APS_PROD_SUM_INFO	 
				WHERE APL_YMD = P_CLS_YMD	 
				AND QLTY_VEHL_CD = P_VEHL_CD	 
				AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				AND LANG_CD = P_LANG_CD;
			END IF;	 
	 

    SET CURR_LOC_NUM = 3;

			/*취급설명서 연식의 PDI 안전재고수량 조회	  */
			SELECT SUM(SFTY_IV_QTY)	 
			INTO V_DL_PDI_IV_QTY	 
			FROM TB_PDI_IV_INFO_DTL	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
			SET V_CURR_IV_QTY = V_DL_IV_QTY;	 


    SET CURR_LOC_NUM = 4;


	OPEN SEWON_IV_DTL_LIST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_DTL_LIST_INFO INTO V_MDL_MDY_CD;
	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

				SET V_CURR_MDL_MDY_CD = V_MDL_MDY_CD;
				IF P_VEHL_CD = 'PS' OR P_VEHL_CD = 'AM' OR P_VEHL_CD = 'SK3' THEN	    /* 원프로시져에는 SK로 되어 있음 */
					/*2주생산 계획 데이터 조회	 */
					SELECT IFNULL(SUM(WEK2_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
					INTO V_CURR_WEK2_PLAN_QTY	 
					FROM TB_PLNT_APS_PROD_SUM_INFO	 
					WHERE APL_YMD = P_CLS_YMD	 
					AND QLTY_VEHL_CD = P_VEHL_CD	 
					AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
					AND LANG_CD = P_LANG_CD	 
					AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;   -- 광주분리
				ELSE	 
					/*2주생산 계획 데이터 조회	  */
					SELECT IFNULL(SUM(WEK2_PRDN_PLN_QTY), 0) + IFNULL(SUM(TDD_PRDN_QTY3), 0)	 
					INTO V_CURR_WEK2_PLAN_QTY	 
					FROM TB_APS_PROD_SUM_INFO	 
					WHERE APL_YMD = P_CLS_YMD	 
					AND QLTY_VEHL_CD = P_VEHL_CD	 
					AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
					AND LANG_CD = P_LANG_CD;	
				END IF;
	 
				/*현재 안전재고 수량 조회	  */
				SELECT IFNULL(SUM(SFTY_IV_QTY), 0)	 
				INTO V_CURR_SFTY_IV_QTY	 
				FROM TB_SEWON_IV_INFO_DTL	 
				WHERE CLS_YMD = P_CLS_YMD	 
				AND QLTY_VEHL_CD = P_VEHL_CD	 
				AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
				AND LANG_CD = P_LANG_CD	 
				AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;   /* 광주분리	 */
	 
				/*PDI 안전재고수량 조회	  */
				SELECT SUM(SFTY_IV_QTY)	 
				INTO V_CURR_PDI_IV_QTY	 
				FROM TB_PDI_IV_INFO_DTL	 
				WHERE CLS_YMD = P_CLS_YMD	 
				AND QLTY_VEHL_CD = P_VEHL_CD	 
				AND MDL_MDY_CD = V_CURR_MDL_MDY_CD	 
				AND LANG_CD = P_LANG_CD	 
				AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;   /* 광주분리 */
	 
				/* 2주생산계획 수량 - (현재의 안전재고 수량 + PDI 안전재고 수량)	  */
				SET V_SFTY_IV_DIFF_QTY = V_CURR_WEK2_PLAN_QTY - (V_CURR_SFTY_IV_QTY + V_CURR_PDI_IV_QTY);	 
	 
				/*2주 생산계획과 안전재고의 차이가 0 보다 큰 경우에만 계산 작업을 진행한다.	 
				(왜냐하면 사전에 초기화 한 상태에서 진행하므로 순수하게 현재 연식에 관계된 것만 있으므로 0 보다 작으면	 
				 재고가 충분하다는 것이므로 작업할 필요가 없다.)	 */
				IF V_SFTY_IV_DIFF_QTY > 0 THEN
				   /*재계산할 재고수량이 존재하는 경우에만 재계산 작업을 수행한다.	 */
				   IF V_CURR_IV_QTY > 0 THEN
					  /*재계산할 연식이 취급설명서 연식보다 이전 연식이라면	 
					  재계산 작업을 수행한다.	 */
					  IF V_CURR_MDL_MDY_CD <= P_EXPD_MDL_MDY_CD THEN
				   	  	 IF V_SFTY_IV_DIFF_QTY >= V_CURR_IV_QTY THEN
					  	 	SET V_SFTY_IV_DIFF = V_CURR_IV_QTY;	 
					  	 	SET V_CURR_IV_QTY  = 0;
				   	  	 ELSE
					  	 	SET V_SFTY_IV_DIFF = V_SFTY_IV_DIFF_QTY;	 
					  	 	SET V_CURR_IV_QTY  = V_CURR_IV_QTY - V_SFTY_IV_DIFF_QTY;
				         END IF;	 
	 
						 SET V_FLAG = 'Y';	 
	 
					  /*재계산할 연식이 취급설명서 연식보다 최근 연식이라면	 
					  이전연식의 2주생산계획 수량보다 재고수량이 큰 경우에만 작업해 주도록 한다.	*/ 
				   	  ELSE	
						  SELECT IFNULL(SUM(SFTY_IV_QTY), 0)	 
						  INTO V_TEMP_IV_QTY	 
						  FROM TB_SEWON_IV_INFO_DTL	 
						  WHERE CLS_YMD = P_CLS_YMD	 
						  AND QLTY_VEHL_CD = P_VEHL_CD	 
						  AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
						  AND LANG_CD = P_LANG_CD	 
						  AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                                  WHEN P_PRDN_PLNT_CD='6' THEN '7'
												              ELSE P_PRDN_PLNT_CD END;  /* 광주분리(원프로시져에는 decode가 없음)	 */
	 
						  SET V_TEMP_IV_QTY = (V_TEMP_IV_QTY + V_DL_PDI_IV_QTY) - V_DL_WEK2_PLAN_QTY;	 
	 
						  IF V_TEMP_IV_QTY > 0 THEN
							 IF V_CURR_IV_QTY < V_TEMP_IV_QTY THEN
								SET V_TEMP_IV_QTY = V_CURR_IV_QTY;
							 END IF;	 
	 
							 IF V_SFTY_IV_DIFF_QTY >= V_TEMP_IV_QTY THEN
					  	  	 	SET V_SFTY_IV_DIFF = V_TEMP_IV_QTY;	 
					  	 	 	SET V_CURR_IV_QTY  = V_CURR_IV_QTY - V_TEMP_IV_QTY;
				   	  	     ELSE
					  	 	 	SET V_SFTY_IV_DIFF = V_SFTY_IV_DIFF_QTY;	 
					  	 	 	SET V_CURR_IV_QTY  = V_CURR_IV_QTY - V_SFTY_IV_DIFF_QTY;
				             END IF;	 
	 
							 SET V_FLAG = 'Y';	 
	 
						  ELSE
							  SET V_FLAG         = 'N';	 
							  SET V_SFTY_IV_DIFF = 0;	 
						  END IF;	 
					  END IF; /*이전연식여부 비교 End */
				   ELSE
					   SET V_FLAG         = 'N';	 
					   SET V_SFTY_IV_DIFF = 0;		 
				   END IF; /*재계산할 재고수량 존재여부 확인 End	 */
				ELSE
					SET V_FLAG         = 'N';	 
					SET V_SFTY_IV_DIFF = 0;
				END IF; /* 2주생산 계획 수량 존재여부 확인 End	 */ 
	 
				/*재고 재계산에 의하여 취급설명서 연식의 안전재고 수량이 변경된 경우	 */
				IF V_FLAG = 'Y' THEN
				   /*차종연식과 취급설명서연식이 같은 항목에	 
				   재고 상세 재계산 후 남은 수량을 업데이트 해 준다.	 */
				   UPDATE TB_SEWON_IV_INFO_DTL	 
				   SET SFTY_IV_QTY        = V_CURR_IV_QTY,	 
					   UPDR_EENO          = V_BATCH_USER_EENO,	 
					   MDFY_DTM           = SYSDATE()	 
				   WHERE CLS_YMD          = P_CLS_YMD	 
				   AND QLTY_VEHL_CD       = P_VEHL_CD	 
				   AND MDL_MDY_CD         = P_EXPD_MDL_MDY_CD	 
				   AND LANG_CD            = P_LANG_CD	 
				   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				   AND N_PRNT_PBCN_NO     = P_N_PRNT_PBCN_NO	 
				   AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                           WHEN P_PRDN_PLNT_CD='6' THEN '7'
												       ELSE P_PRDN_PLNT_CD END;  /* 광주분리(원프로시져에는 decode가 없음)	 */
				END IF;	 
	 
				UPDATE TB_SEWON_IV_INFO_DTL	 
				SET IV_QTY             = V_DL_IV_QTY,	 
				    SFTY_IV_QTY        = V_SFTY_IV_DIFF,	 
					DL_EXPD_TMP_IV_QTY = V_DL_EXPD_TMP_IV_QTY,	 
					CMPL_YN            = V_DL_CMPL_YN,	 
					UPDR_EENO          = V_BATCH_USER_EENO,	 
					MDFY_DTM           = SYSDATE(),	 
					TMP_TRTM_YN        = V_DL_TMP_TRTM_YN	 
				WHERE CLS_YMD          = P_CLS_YMD	 
				AND QLTY_VEHL_CD       = P_VEHL_CD	 
				AND MDL_MDY_CD         = V_CURR_MDL_MDY_CD	 
				AND LANG_CD            = P_LANG_CD	 
				AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				AND N_PRNT_PBCN_NO     = P_N_PRNT_PBCN_NO	 
				AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                        WHEN P_PRDN_PLNT_CD='6' THEN '7'
												    ELSE P_PRDN_PLNT_CD END;  /* 광주분리(원프로시져에는 decode가 없음)	 */
	 

				SET V_EXCNT = 0;
				SELECT COUNT(CLS_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_SEWON_IV_INFO_DTL
				 WHERE CLS_YMD          = P_CLS_YMD	 
				 AND QLTY_VEHL_CD       = P_VEHL_CD	 
				 AND MDL_MDY_CD         = V_CURR_MDL_MDY_CD	 
				 AND LANG_CD            = P_LANG_CD	 
				 AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
				 AND N_PRNT_PBCN_NO     = P_N_PRNT_PBCN_NO	 
				 AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                        WHEN P_PRDN_PLNT_CD='6' THEN '7'
												    ELSE P_PRDN_PLNT_CD END;  /* 광주분리(원프로시져에는 decode가 없음)	 */


				IF V_EXCNT = 0 THEN
				   INSERT INTO TB_SEWON_IV_INFO_DTL	 
				   (CLS_YMD,	 
				    QLTY_VEHL_CD,	 
					MDL_MDY_CD,	 
					LANG_CD,	 
					DL_EXPD_MDL_MDY_CD,	 
					N_PRNT_PBCN_NO,	 	 
					PRDN_PLNT_CD, 
					IV_QTY,	 
					SFTY_IV_QTY,	 
					DL_EXPD_TMP_IV_QTY,	 
					CMPL_YN,	 
					PPRR_EENO,	 
					FRAM_DTM,	 
					UPDR_EENO,	 
					MDFY_DTM,	 
					TMP_TRTM_YN
				   )	 
				   VALUES	 
				   (P_CLS_YMD,	 
				    P_VEHL_CD,	 
					V_CURR_MDL_MDY_CD,	 
					P_LANG_CD,	 
					P_EXPD_MDL_MDY_CD,	 
					P_N_PRNT_PBCN_NO,	 
					CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                    WHEN P_PRDN_PLNT_CD='6' THEN '7'
												ELSE P_PRDN_PLNT_CD END,   /* 광주분리(원프로시져에는 decode가 없음) 	 */ 
					V_DL_IV_QTY,	 
					V_SFTY_IV_DIFF,	 
					V_DL_EXPD_TMP_IV_QTY,	 
					V_DL_CMPL_YN,	 
					V_BATCH_USER_EENO,	 
					SYSDATE(),	 
					V_BATCH_USER_EENO,	 
					SYSDATE(),	 
					V_DL_TMP_TRTM_YN	
				   );
				END IF;

	END LOOP JOBLOOP ;
	CLOSE SEWON_IV_DTL_LIST_INFO;


    SET CURR_LOC_NUM = 5;

	/*END;
	DELIMITER;
	다음처리*/	 

	COMMIT;
	    

    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_REMAKE_SEWON_IV_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_REMAKE_SEWON_IV_INFO`(IN P_DATA_SN_LIST VARCHAR(1000),
                                        IN P_CURR_YMD VARCHAR(8),
                                        IN P_SYST_YMD VARCHAR(8),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN  
/***************************************************************************
 * Procedure 명칭 : SP_REMAKE_SEWON_IV_INFO
 * Procedure 설명 : 이미 재고데이터가 이전 날짜에 소진된 항목에 대해서 인자로 주어진 날짜의 재고 데이터를 새로이 생성해 주는 작업 수행
 * 입력 파라미터    :  P_DATA_SN_LIST           데이터식별목록
 *                 P_CURR_YMD               현재년월일
 *                 P_SYST_YMD               시스템년월일
 *                 P_PRDN_PLNT_CD           생산공장코드
 *                 P_EXPD_CO_CD             회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/ 
	DECLARE V_CNT       INT;
	/*DECLARE V_DATA_SN_LIST PG_COMMON.LIST_TYPE;*/
	DECLARE V_DATA_SN_LIST VARCHAR(1000);
	DECLARE V_DATA_SN_CNT  INT;
	DECLARE V_QLTY_VEHL_CD VARCHAR(4);	 
	DECLARE V_MDL_MDY_CD	VARCHAR(4);	 
	DECLARE V_LANG_CD		VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD VARCHAR(2);	 
	DECLARE V_N_PRNT_PBCN_NO	  VARCHAR(100);
	DECLARE V_DL_EXPD_REGN_CD	  VARCHAR(4);	
	DECLARE i					INT; 
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_REMAKE_SEWON_IV_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_DATA_SN_LIST:',IFNULL(P_DATA_SN_LIST,'')
							,',P_CURR_YMD:',IFNULL(P_CURR_YMD,'')
							,',P_SYST_YMD:',IFNULL(P_SYST_YMD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_DATA_SN_LIST:',IFNULL(V_DATA_SN_LIST,'')
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_MDL_MDY_CD:',IFNULL(V_MDL_MDY_CD,'')
							,',V_LANG_CD:',IFNULL(V_LANG_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',V_DL_EXPD_REGN_CD:',IFNULL(V_DL_EXPD_REGN_CD,'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_DATA_SN_CNT:',IFNULL(CONCAT(V_DATA_SN_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			SET V_DATA_SN_CNT = 100;
			SET V_DATA_SN_LIST = FU_SPLIT(P_DATA_SN_LIST, V_DATA_SN_CNT);


			/*체크리스트 상세정보에서 현재 차종에 발간번호가 설정되지 않은 항목을 삭제한다. 	 */ 
			SET i=1;
			JOBLOOPT: LOOP

				SELECT QLTY_VEHL_CD,	 
					   MDL_MDY_CD,	 
					   LANG_CD,	 
					   DL_EXPD_REGN_CD	 
				INTO V_QLTY_VEHL_CD,	 
				     V_MDL_MDY_CD,	 
					 V_LANG_CD,	 
					 V_DL_EXPD_REGN_CD	 
				FROM TB_LANG_MGMT	 
				WHERE DATA_SN = CAST(V_DATA_SN_LIST(DATA_SN_NUM) AS SIGNED); 	 
	 
				SELECT COUNT(*)	 
				INTO V_CNT	 
				FROM TB_SEWON_IV_INFO_DTL	 
				WHERE CLS_YMD = P_CURR_YMD	 
				AND QLTY_VEHL_CD = V_QLTY_VEHL_CD	 
				AND MDL_MDY_CD = V_MDL_MDY_CD	 
				AND LANG_CD = V_LANG_CD	 
				/*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	 */
				AND DL_EXPD_TMP_IV_QTY = 0	 
				AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
				IF V_CNT = 0 THEN
				   /*현재는 무조건 가장 최근(큰) 연식을 가져오도록 처리함	 
				    (필요에 따라 현재의 차종연식과 같은 연식이 있으면 그것을 가져오도록 변경할 여지도 있을듯함)	  */
				   SELECT MAX(A.DL_EXPD_MDL_MDY_CD)	 
				   INTO V_DL_EXPD_MDL_MDY_CD	 
				   FROM TB_SEWON_IV_INFO A,	 
				        TB_DL_EXPD_MDY_MGMT B	 
				   WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
				   AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
				   AND A.CLS_YMD <= P_CURR_YMD	 
				   /*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	  */ 
				   AND A.DL_EXPD_TMP_IV_QTY = 0	 
				   AND B.QLTY_VEHL_CD = V_QLTY_VEHL_CD	 
				   AND B.MDL_MDY_CD = V_MDL_MDY_CD	 
				   AND B.DL_EXPD_REGN_CD = V_DL_EXPD_REGN_CD	 
				   AND A.LANG_CD = V_LANG_CD	 
				   AND A.PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
				   IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL THEN
					  SELECT MAX(N_PRNT_PBCN_NO)	 
				   	  INTO V_N_PRNT_PBCN_NO	 
				   	  FROM TB_SEWON_IV_INFO	 
					  WHERE QLTY_VEHL_CD = V_QLTY_VEHL_CD	 
					  AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
					  AND LANG_CD = V_LANG_CD	 
					  AND CLS_YMD <= P_CURR_YMD	 
					  /*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	  */ 
				   	  AND DL_EXPD_TMP_IV_QTY = 0	 
				   	  AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
					  IF V_N_PRNT_PBCN_NO IS NOT NULL THEN
						  SELECT COUNT(*)	 
						  INTO V_CNT	 
						  FROM TB_SEWON_IV_INFO	 
						  WHERE CLS_YMD = P_CURR_YMD	 
						  AND QLTY_VEHL_CD = V_QLTY_VEHL_CD	 
						  AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
						  AND LANG_CD = V_LANG_CD	 
						  AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
						  AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
						  IF V_CNT = 0 THEN
							 INSERT INTO TB_SEWON_IV_INFO	 
						     (CLS_YMD,	 
						   	  QLTY_VEHL_CD,	 
						   	  DL_EXPD_MDL_MDY_CD,	 
						   	  LANG_CD,	 
						      N_PRNT_PBCN_NO,	 
						   	  IV_QTY,	 
						   	  DL_EXPD_TMP_IV_QTY,	 
						   	  CMPL_YN,	 
						   	  PPRR_EENO,	 
						   	  FRAM_DTM,	 
						   	  UPDR_EENO,	 
						   	  MDFY_DTM,	 
						   	  TMP_TRTM_YN,	 
						   	  PRDN_PLNT_CD 
						     )	 
						  	 VALUES	 
							 (P_CURR_YMD,	 
							  V_QLTY_VEHL_CD,	 
							  V_DL_EXPD_MDL_MDY_CD,	 
							  V_LANG_CD,	 
							  V_N_PRNT_PBCN_NO,	 
							  0,	 
							  0,	 
							  CASE WHEN P_CURR_YMD = P_SYST_YMD THEN 'N' ELSE 'Y' END,	 
							  V_BATCH_USER_EENO,	 
							  SYSDATE(),	 
							  V_BATCH_USER_EENO,	 
							  SYSDATE(),	 
							  /*임시 생성하는 데이터란 정보를 표시하여 준다.	 */
							  'Y',	 
							  P_PRDN_PLNT_CD
							 );	 
	 
						  END IF;	 
	 
						  /*재고상세 내역에도 데이터를 추가해 준다.	 
						   (재고보정작업이 자동으로 이루어지지 않기 때문에 재고상세 내역에도 데이터를 추가해 주는 것이다.)	 */	 
						  SELECT COUNT(*)	 
						  INTO V_CNT	 
						  FROM TB_SEWON_IV_INFO_DTL	 
						  WHERE CLS_YMD = P_CURR_YMD	 
						  AND QLTY_VEHL_CD = V_QLTY_VEHL_CD	 
						  AND MDL_MDY_CD = V_MDL_MDY_CD	 
						  AND LANG_CD = V_LANG_CD	 
						  AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
						  AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
						  AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
	 
						  IF V_CNT = 0 THEN
							 INSERT INTO TB_SEWON_IV_INFO_DTL	 
							 (CLS_YMD,	 
							  QLTY_VEHL_CD,	 
							  MDL_MDY_CD,	 
							  LANG_CD,	 
							  DL_EXPD_MDL_MDY_CD,	 
							  N_PRNT_PBCN_NO,	 
							  IV_QTY,	 
							  SFTY_IV_QTY,	 
							  DL_EXPD_TMP_IV_QTY,	 
							  CMPL_YN,	 
							  PPRR_EENO,	 
							  FRAM_DTM,	 
							  UPDR_EENO,	 
							  MDFY_DTM,	 
							  TMP_TRTM_YN,	 
							  PRDN_PLNT_CD
							 )	 
							 VALUES	 
							 (P_CURR_YMD,	 
							  V_QLTY_VEHL_CD,	 
							  V_MDL_MDY_CD,	 
							  V_LANG_CD,	 
							  V_DL_EXPD_MDL_MDY_CD,	 
							  V_N_PRNT_PBCN_NO,	 
							  0,	 
							  0,	 
							  0,	 
							  CASE WHEN P_CURR_YMD = P_SYST_YMD THEN 'N' ELSE 'Y' END,	 
							  V_BATCH_USER_EENO,	 
							  SYSDATE(),	 
							  V_BATCH_USER_EENO,	 
							  SYSDATE(),	 
							  /*임시 생성하는 데이터란 정보를 표시하여 준다.	 */
							  'Y',	 
							  P_PRDN_PLNT_CD
							 );
						  END IF;
					   END IF;
				   END IF;
				END IF;


				SET i=i+1; 
				IF i=V_DATA_SN_CNT THEN
					LEAVE JOBLOOPT;
				END IF;
			END LOOP JOBLOOPT;


    SET CURR_LOC_NUM = 2;


	COMMIT;
	    

    SET CURR_LOC_NUM = 3;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_IV_INFO_BATCH 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_IV_INFO_BATCH`()
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_IV_INFO_BATCH
 * Procedure 설명 : 세원 재고정보 일배치 정리작업 수행,반드시 현재일 시작시간에 돌려야 한다.	
 * 입력 파라미터    :  
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE STRT_DATE				DATETIME;
	DECLARE V_CURR_CLS_YMD			VARCHAR(8);	 
	DECLARE V_PREV_CLS_YMD			VARCHAR(8); 
	DECLARE V_DLVG_PARR_YMD			VARCHAR(8);
	DECLARE V_TMP_IV_QTY			INT;
	DECLARE BTCH_USER_EENO			VARCHAR(20);
	DECLARE V_BATCH_USER_EENO       VARCHAR(20);
		 	 
	DECLARE V_QLTY_VEHL_CD_1			VARCHAR(4);	 
	DECLARE V_DL_EXPD_MDL_MDY_CD_1	VARCHAR(4); 
	DECLARE V_LANG_CD_1				VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO_1		VARCHAR(100);
	DECLARE V_IV_QTY_1				INT;
	DECLARE V_TMP_IV_QTY_1			INT;
	DECLARE V_PRDN_PLNT_CD_1			VARCHAR(3);
	DECLARE V_DLVG_PARR_YMD_1			VARCHAR(8);
	
	DECLARE V_QLTY_VEHL_CD_2			VARCHAR(4);
	DECLARE V_LANG_CD_2				VARCHAR(3);
	DECLARE V_PRDN_PLNT_CD_2			VARCHAR(3);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */
	DECLARE endOfRow2 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE SEWON_IV_INFO CURSOR FOR		 	 
				SELECT   K.QLTY_VEHL_CD	 
				       , K.DL_EXPD_MDL_MDY_CD	 
				       , K.LANG_CD	 
				       , K.N_PRNT_PBCN_NO	 
				       , K.IV_QTY	 
				       , CASE WHEN K.DLVG_PARR_YMD > V_PREV_CLS_YMD AND K.DL_EXPD_TMP_IV_QTY <>  0 THEN K.DL_EXPD_TMP_IV_QTY	 
				              ELSE K.TMP_IV_QTY	 
				         END TMP_IV_QTY	 
				       , K.PRDN_PLNT_CD	 
				       , K.DLVG_PARR_YMD	 
				  FROM (	 
						SELECT   B.DLVG_PARR_YMD	 
						       , A.QLTY_VEHL_CD	 
						       , A.DL_EXPD_MDL_MDY_CD	 
						       , A.LANG_CD	 
						       , A.N_PRNT_PBCN_NO	 
						       , A.IV_QTY	 
						       , A.DL_EXPD_TMP_IV_QTY	 
						       , A.PRDN_PLNT_CD	 
						       , 0 AS TMP_IV_QTY	 
						  FROM (	 
								SELECT  QLTY_VEHL_CD,	 
										DL_EXPD_MDL_MDY_CD,	 
										LANG_CD,	 
										N_PRNT_PBCN_NO,	 
										IV_QTY,	 
										DL_EXPD_TMP_IV_QTY,	 
										PRDN_PLNT_CD  
								   FROM TB_SEWON_IV_INFO	 
								  WHERE CLS_YMD = V_PREV_CLS_YMD	 
							 	    AND QLTY_VEHL_CD IN (SELECT QLTY_VEHL_CD FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD = '02' AND USE_YN = 'Y')	 
								    AND IV_QTY > 0	 
						       ) A
							   LEFT JOIN TB_SEWON_WHSN_INFO B
							   ON (A.QLTY_VEHL_CD = B.QLTY_VEHL_CD AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD AND A.LANG_CD = B.LANG_CD AND A.N_PRNT_PBCN_NO = B.N_PRNT_PBCN_NO)
						 WHERE 1=1 
				       ) K;
	 
	DECLARE SEWON_IV_DTL_INFO CURSOR FOR
				 SELECT QLTY_VEHL_CD,	 
			  	 		LANG_CD,	 
			  	 	    PRDN_PLNT_CD 
				   FROM TB_SEWON_IV_INFO	 
				  WHERE CLS_YMD = V_PREV_CLS_YMD	 
				    AND IV_QTY > 0	 
				    AND QLTY_VEHL_CD IN (SELECT QLTY_VEHL_CD FROM TB_VEHL_MGMT WHERE DL_EXPD_CO_CD = '02' AND USE_YN = 'Y')	 
				  GROUP BY QLTY_VEHL_CD, LANG_CD , PRDN_PLNT_CD
				  ORDER BY QLTY_VEHL_CD, LANG_CD;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE, endOfRow2 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_IV_INFO_BATCH',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_BTCH_USER_EENO:',IFNULL(P_BTCH_USER_EENO,'')
							,',V_CURR_CLS_YMD:',IFNULL(V_CURR_CLS_YMD,'')
							,',V_PREV_CLS_YMD:',IFNULL(V_PREV_CLS_YMD,'')
							,',V_DLVG_PARR_YMD:',IFNULL(V_DLVG_PARR_YMD,'')
							,',BTCH_USER_EENO:',IFNULL(BTCH_USER_EENO,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,'')
							,',V_PRDN_PLNT_CD_1:',IFNULL(V_PRDN_PLNT_CD_1,'')
							,',V_DLVG_PARR_YMD_1:',IFNULL(V_DLVG_PARR_YMD_1,'')
							,',V_QLTY_VEHL_CD_2:',IFNULL(V_QLTY_VEHL_CD_2,'')
							,',V_LANG_CD_2:',IFNULL(V_LANG_CD_2,'')
							,',V_PRDN_PLNT_CD_2:',IFNULL(V_PRDN_PLNT_CD_2,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),'')
							,',V_TMP_IV_QTY:',IFNULL(CONCAT(V_TMP_IV_QTY),'')
							,',V_IV_QTY_1:',IFNULL(CONCAT(V_IV_QTY_1),'')
							,',V_TMP_IV_QTY_1:',IFNULL(CONCAT(V_TMP_IV_QTY_1),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';
    SET BTCH_USER_EENO = V_BATCH_USER_EENO;

	SET V_CURR_CLS_YMD  = DATE_FORMAT(SYSDATE(), '%Y%m%d');	 
	SET V_PREV_CLS_YMD  = DATE_FORMAT(DATE_SUB(SYSDATE(), INTERVAL 1 DAY), '%Y%m%d'); 

	SET STRT_DATE  = SYSDATE();


    SET CURR_LOC_NUM = 2;

	OPEN SEWON_IV_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_INFO INTO V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1,V_N_PRNT_PBCN_NO_1,V_IV_QTY_1,V_TMP_IV_QTY_1,V_PRDN_PLNT_CD_1,V_DLVG_PARR_YMD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;
					SET V_TMP_IV_QTY = V_TMP_IV_QTY_1;
					
				/*등록전 PK별 정보 있는지 확인*/
				SET V_INEXCNT = 0;
				SELECT COUNT(*)	 
				  INTO V_INEXCNT	 
				  FROM TB_SEWON_IV_INFO
				WHERE CLS_YMD = V_CURR_CLS_YMD
					AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1
					AND LANG_CD = V_LANG_CD_1
					AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1
					AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_1;
				
				IF V_INEXCNT = 0 THEN
					INSERT INTO TB_SEWON_IV_INFO	 
					(	 
					 CLS_YMD,	 
					 QLTY_VEHL_CD,	 
					 DL_EXPD_MDL_MDY_CD,	 
					 LANG_CD,	 
					 N_PRNT_PBCN_NO,	 
					 IV_QTY,	 
					 DL_EXPD_TMP_IV_QTY,	 
					 CMPL_YN,	 
					 PPRR_EENO,	 
					 FRAM_DTM,	 
					 UPDR_EENO,	 
					 MDFY_DTM,	 
					 PRDN_PLNT_CD
					)	 
					VALUES	 
					(	 
					 V_CURR_CLS_YMD,	 
					 V_QLTY_VEHL_CD_1,	 
					 V_DL_EXPD_MDL_MDY_CD_1,	 
					 V_LANG_CD_1,	 
					 V_N_PRNT_PBCN_NO_1,	 
					 V_IV_QTY_1,	 
					 V_TMP_IV_QTY,	 
					 'N',	 
					 BTCH_USER_EENO,	 
					 SYSDATE(),	 
					 BTCH_USER_EENO,	 
					 SYSDATE(),	 
					 V_PRDN_PLNT_CD_1
					);	 
				END IF;
						 
				/*등록전 PK별 정보 있는지 확인*/
				SET V_INEXCNT = 0;
				SELECT COUNT(*)	 
				  INTO V_INEXCNT	 
				  FROM TB_SEWON_IV_INFO_DTL
				WHERE CLS_YMD = V_CURR_CLS_YMD
					AND QLTY_VEHL_CD = V_QLTY_VEHL_CD_1
					AND MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1
					AND LANG_CD = V_LANG_CD_1
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1
					AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1
					AND PRDN_PLNT_CD = V_PRDN_PLNT_CD_1;
				
				IF V_INEXCNT = 0 THEN
					/* 전일의 재고내역을 기반으로 재고상세 내역을 다시 생성하는 방식의 경우 	 
					  재고상세 테이블에 취급설명서연식과 같은 차종연식으로 데이터를 신규입력하여 준다.	 
					  (왜냐하면 연식 연계 관계에서 취급설명서 연식과 연계된 차종 연식에는 	 
					   취급설명서 연식과 동일한 차종연식은 반드시 있기 때문이다.) 	  */
					INSERT INTO TB_SEWON_IV_INFO_DTL	 
					(CLS_YMD,	 
					 QLTY_VEHL_CD,	 
					 MDL_MDY_CD,	 
					 LANG_CD,	 
					 DL_EXPD_MDL_MDY_CD,	 
					 N_PRNT_PBCN_NO,	 
					 IV_QTY,	 
					 SFTY_IV_QTY,	 
					 DL_EXPD_TMP_IV_QTY,	 
					 CMPL_YN,	 
					 PPRR_EENO,	 
					 FRAM_DTM,	 
					 UPDR_EENO,	 
					 MDFY_DTM,	 
					 PRDN_PLNT_CD
					)	 
					VALUES	 
					(V_CURR_CLS_YMD,	 
					 V_QLTY_VEHL_CD_1,	 
					 V_DL_EXPD_MDL_MDY_CD_1, /* 차종연식을 취급설명서 연식과 동일한 값으로 입력 	  */
					 V_LANG_CD_1,	 
					 V_DL_EXPD_MDL_MDY_CD_1,	 
					 V_N_PRNT_PBCN_NO_1,	 
					 V_IV_QTY_1,	 
					 V_IV_QTY_1,             /* 안전재고수량 역시 현재의 재고수량과 동일한 값으로 입력한다.(나중에 재고 재계산 시에 다시 계산됨) 	  */
					 V_TMP_IV_QTY,	 
					 'N',	 
					 BTCH_USER_EENO,	 
					 SYSDATE(),	 
					 BTCH_USER_EENO,	 
					 SYSDATE(),	 
					 V_PRDN_PLNT_CD_1
					);
				END IF;

	END LOOP JOBLOOP1 ;
	CLOSE SEWON_IV_INFO;


    SET CURR_LOC_NUM = 3;

	UPDATE TB_SEWON_IV_INFO	 
	  SET CMPL_YN = 'Y'	 
	WHERE CLS_YMD = V_PREV_CLS_YMD;	
	


    SET CURR_LOC_NUM = 4;

	OPEN SEWON_IV_DTL_INFO; /* cursor 열기 */
	JOBLOOP2 : LOOP  /*루프명 : LOOP 시작*/
	FETCH SEWON_IV_DTL_INFO INTO V_QLTY_VEHL_CD_2,V_LANG_CD_2,V_PRDN_PLNT_CD_2;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP2 ;
	END IF;
					 
	CALL SP_RECALCULATE_SEWON_IV_DTL4(V_CURR_CLS_YMD,	 
									V_QLTY_VEHL_CD_2,	 
									V_LANG_CD_2, 
									V_PRDN_PLNT_CD_2
									);

	END LOOP JOBLOOP2 ;
	CLOSE SEWON_IV_DTL_INFO;
	 

    SET CURR_LOC_NUM = 5;

	UPDATE TB_SEWON_IV_INFO_DTL	 
	  SET CMPL_YN = 'Y'	 
	WHERE CLS_YMD = V_PREV_CLS_YMD;	 
	 

    SET CURR_LOC_NUM = 6;

	COMMIT;	 
	 

    SET CURR_LOC_NUM = 7;

	CALL WRITE_BATCH_LOG('세원재고배치작업', STRT_DATE, 'S', '배치처리완료');	 
	 

    SET CURR_LOC_NUM = 8;

	/*	 EXCEPTION	 
		     WHEN OTHERS THEN	 
			     ROLLBACK;	 
				 PG_INTERFACE_APS.WRITE_BATCH_LOG('세원재고배치작업', STRT_DATE, 'F', CONCAT('배치처리실패:[' ,  SQLERRM ,  ']'));	*/

	/*END;
	DELIMITER;
	다음처리*/
	    
	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_IV_INFO_CANCL_BY_WHSN 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_IV_INFO_CANCL_BY_WHSN`(IN P_WHSN_YMD VARCHAR(8),
                                        IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN EXPD_CO_CD VARCHAR(4))
BEGIN	 	
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_IV_INFO_CANCL_BY_WHSN
 * Procedure 설명 : 세원 재고정보 취소 수행(세원 입고)	
 * 입력 파라미터    :  P_WHSN_YMD                   입고년월일
 *                 P_QLTY_VEHL_CD               품질차종코드
 *                 P_MDL_MDY_CD                 모델년식코드
 *                 P_LANG_CD                    언어코드
 *                 P_EXPD_MDL_MDY_CD            취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO             신인쇄발간번호
 *                 P_PRDN_PLNT_CD               생산공장코드
 *                 EXPD_CO_CD                   회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_FROM_YMD VARCHAR(8);	 
	DECLARE V_TO_YMD	VARCHAR(8);
	DECLARE V_FROM_DATE DATETIME;	 
	DECLARE V_TO_DATE   DATETIME;	 
	DECLARE V_CNT		 INT;
	DECLARE V_INCNT		 INT;
	DECLARE V_CURR_DATE DATETIME;	 
	DECLARE V_CURR_YMD	 VARCHAR(8);	 
	DECLARE V_PRDN_PLNT_CD VARCHAR(1);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_IV_INFO_CANCL_BY_WHSN',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_WHSN_YMD:',IFNULL(P_WHSN_YMD,'')
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',EXPD_CO_CD:',IFNULL(EXPD_CO_CD,'')
							,',V_FROM_YMD:',IFNULL(V_FROM_YMD,'')
							,',V_TO_YMD:',IFNULL(V_TO_YMD,'')
							,',V_CURR_YMD:',IFNULL(V_CURR_YMD,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,'')
							,',V_FROM_DATE:',IFNULL(DATE_FORMAT(V_FROM_DATE, '%Y%m%d'),'')
							,',V_TO_DATE:',IFNULL(DATE_FORMAT(V_TO_DATE, '%Y%m%d'),'')
							,',V_CURR_DATE:',IFNULL(DATE_FORMAT(V_CURR_DATE, '%Y%m%d'),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_INCNT:',IFNULL(CONCAT(V_INCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

          IF P_QLTY_VEHL_CD = 'AM' OR P_QLTY_VEHL_CD = 'PS' OR P_QLTY_VEHL_CD = 'SK3' THEN	 
				SET V_PRDN_PLNT_CD = '7';   /* 세원재고는 광주 7로 통일	 */
		  ELSE	 
		  		SET V_PRDN_PLNT_CD = 'N';	 
          END IF;	 
	   	 
	 
			SELECT MIN(CLS_YMD),	 
				   MAX(CLS_YMD)	 
			INTO V_FROM_YMD,	 
				 V_TO_YMD	 
			FROM TB_SEWON_IV_INFO	 
			WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
		   	AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
		   	AND LANG_CD = P_LANG_CD	 
		   	AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
		   	AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;
	 

    SET CURR_LOC_NUM = 2;

	   		/*입고일 이후의 모든 재고정보를 삭제한다.	 */
			DELETE FROM TB_SEWON_IV_INFO	 
			WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
		   	AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
		   	AND LANG_CD = P_LANG_CD	 
		   	AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
		   	AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;
	 

    SET CURR_LOC_NUM = 3;

			/*재고상세 정보도 역시 삭제한다.	 */
			DELETE FROM TB_SEWON_IV_INFO_DTL	 
			WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
		   	AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
		   	AND LANG_CD = P_LANG_CD	 
		   	AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
		   	AND PRDN_PLNT_CD = V_PRDN_PLNT_CD; 
	 

    SET CURR_LOC_NUM = 4;

			/*삭제내역에 대한 재고상세 테이블 재계산 작업 수행	 */
			IF V_FROM_YMD IS NOT NULL AND V_TO_YMD IS NOT NULL THEN	
			   SET V_FROM_DATE = STR_TO_DATE(V_FROM_YMD, '%Y%m%d');	 
			   SET V_TO_DATE   = STR_TO_DATE(V_TO_YMD, '%Y%m%d');	 
			   SET V_CNT = ROUND(V_TO_DATE - V_FROM_DATE);	


				SET V_INCNT = 0;
				JOBLOOP: LOOP
				  SET V_CURR_DATE = DATE_ADD(V_FROM_DATE,INTERVAL V_INCNT DAY);	
				  SET V_CURR_YMD  = DATE_FORMAT(V_CURR_DATE, '%Y%m%d');
				 
				  CALL SP_RECALCULATE_SEWON_IV_DTL4(V_CURR_YMD,	 
										 	   P_QLTY_VEHL_CD,	 
			  						     	   P_LANG_CD,	 
										 	   V_PRDN_PLNT_CD
										 	   );

					SET V_INCNT = V_INCNT + 1; 
					IF V_INCNT = V_CNT THEN
						LEAVE JOBLOOP;
					END IF;
				END LOOP JOBLOOP;

			END IF;	 
	 
	 

    SET CURR_LOC_NUM = 5;

	COMMIT;

    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_IV_INFO_SAVE_BY_WHSN 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_IV_INFO_SAVE_BY_WHSN`(IN P_WHSN_YMD VARCHAR(8),
                                        IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_WHSN_QTY INT,
                                        IN P_DLVG_PARR_YMD VARCHAR(8),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_IV_INFO_SAVE_BY_WHSN
 * Procedure 설명 : 세원 재고정보 Insert(세원 입고)
 * 입력 파라미터    :  P_WHSN_YMD                   입고년월일
 *                 P_QLTY_VEHL_CD               품질차종코드
 *                 P_MDL_MDY_CD                 모델년식코드
 *                 P_LANG_CD                    언어코드
 *                 P_EXPD_MDL_MDY_CD            취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO             신인쇄발간번호
 *                 P_WHSN_QTY                   입고수량
 *                 P_DLVG_PARR_YMD              납품예정년월일
 *                 P_PRDN_PLNT_CD               생산공장코드
 *                 P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_PRDN_PLNT_CD		VARCHAR(1);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_IV_INFO_SAVE_BY_WHSN',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_WHSN_YMD:',IFNULL(P_WHSN_YMD,'')
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_DLVG_PARR_YMD:',IFNULL(P_DLVG_PARR_YMD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,'')
							,',P_WHSN_QTY:',IFNULL(CONCAT(P_WHSN_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	    
    SET CURR_LOC_NUM = 1;
          SET V_BATCH_USER_EENO = 'BATCH';

          IF P_QLTY_VEHL_CD = 'AM' OR P_QLTY_VEHL_CD = 'PS' OR P_QLTY_VEHL_CD = 'SK3' THEN	 
				SET V_PRDN_PLNT_CD = '7';   /*  세원재고는 광주 7로 통일	 */
		  ELSE	 
		  		SET V_PRDN_PLNT_CD = 'N';	 
          END IF;	 
	 
			/*등록전 PK별 정보 있는지 확인*/
			SET V_INEXCNT = 0;
			SELECT COUNT(*)	 
			INTO V_INEXCNT	 
			FROM TB_SEWON_IV_INFO
			WHERE CLS_YMD = P_WHSN_YMD
			AND QLTY_VEHL_CD = P_QLTY_VEHL_CD
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD
			AND LANG_CD = P_LANG_CD
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO
			AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;
				
			IF V_INEXCNT = 0 THEN
				/*재고정보 테이블에 데이터 Insert	 */
				INSERT INTO TB_SEWON_IV_INFO	 
				(CLS_YMD,	 
				 QLTY_VEHL_CD,	 
				 DL_EXPD_MDL_MDY_CD,	 
				 LANG_CD,	 
				 N_PRNT_PBCN_NO,	 
				 IV_QTY,	 
				 DL_EXPD_TMP_IV_QTY,	 
				 CMPL_YN,	 
				 PPRR_EENO,	 
				 FRAM_DTM,	 
				 UPDR_EENO,	 
				 MDFY_DTM,	 
				 PRDN_PLNT_CD	 
				)	 
				VALUES	 
				(P_WHSN_YMD,	 
				 P_QLTY_VEHL_CD,	 
				 P_EXPD_MDL_MDY_CD,	 
				 P_LANG_CD,	 
				 P_N_PRNT_PBCN_NO,	 
				 P_WHSN_QTY,	 
				 CASE WHEN P_WHSN_YMD >= P_DLVG_PARR_YMD THEN 0 ELSE P_WHSN_QTY END,	 
				 'N',	 
				 V_BATCH_USER_EENO,	 
				 SYSDATE(),	 
				 V_BATCH_USER_EENO,	 
				 SYSDATE(),	 
				 V_PRDN_PLNT_CD
				);	 
			END IF;
	 

    SET CURR_LOC_NUM = 2;

			/*현재의 입고 내역을 재고상세 테이블에 저장한다.	 */
			CALL SP_UPDATE_SEWON_IV_DTL_INFO(P_QLTY_VEHL_CD,	 
			  						    P_EXPD_MDL_MDY_CD,	 
									    P_LANG_CD,	 
									    P_N_PRNT_PBCN_NO,	 
									    P_WHSN_YMD,	  
										V_PRDN_PLNT_CD, 
										P_EXPD_CO_CD
										);



    SET CURR_LOC_NUM = 3;

			/*입고내역에 대한 재고상세 테이블 재계산 작업 수행	 */
		    CALL SP_RECALCULATE_SEWON_IV_DTL4(P_WHSN_YMD,	 
										 P_QLTY_VEHL_CD,	 
									     P_LANG_CD,	 
										 V_PRDN_PLNT_CD
										 );

    SET CURR_LOC_NUM = 4;



	COMMIT;

    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_IV_INFO_UPDATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_IV_INFO_UPDATE`(IN P_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_CLS_YMD VARCHAR(8),
                                        IN P_DIFF_RQ_QTY INT,
                                        IN P_FLAG VARCHAR(1),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_IV_INFO_UPDATE
 * Procedure 설명 : 세원 재고정보 업데이트 수행
 * 입력 파라미터    :  P_VEHL_CD                   품질차종코드
 *                 P_MDL_MDY_CD                모델년식코드
 *                 P_LANG_CD                   언어코드
 *                 P_EXPD_MDL_MDY_CD           취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO            신인쇄발간번호
 *                 P_CLS_YMD                   마감년월일
 *                 P_DIFF_RQ_QTY               요청수량
 *                 P_FLAG                      상태
 *                 P_PRDN_PLNT_CD              생산공장코드
 *                 P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QTY		   INT;	 
	DECLARE V_DIFF_RQ_QTY INT;	 
	DECLARE V_DEEI1_QTY   INT;	 
	DECLARE V_EXCNT   INT;	 
	DECLARE V_PRDN_PLNT_CD VARCHAR(1);
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_IV_INFO_UPDATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_FLAG:',IFNULL(P_FLAG,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,'')
							,',P_DIFF_RQ_QTY:',IFNULL(CONCAT(P_DIFF_RQ_QTY),'')
							,',V_QTY:',IFNULL(CONCAT(V_QTY),'')
							,',V_DIFF_RQ_QTY:',IFNULL(CONCAT(V_DIFF_RQ_QTY),'')
							,',V_DEEI1_QTY:',IFNULL(CONCAT(V_DEEI1_QTY),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
          SET V_BATCH_USER_EENO = 'BATCH';

          IF P_VEHL_CD = 'AM' OR P_VEHL_CD = 'PS' OR P_VEHL_CD = 'SK3' THEN	 
				SET V_PRDN_PLNT_CD = '7';   /* 세원재고는 광주 7로 통일	 */
		  ELSE	 
		  		SET V_PRDN_PLNT_CD = 'N';	 
          END IF;	 
	 
	   		SELECT IFNULL(SUM(IV_QTY), 0),	 
				   IFNULL(SUM(DEEI1_QTY), 0)	 
			INTO V_QTY,	 
				 V_DEEI1_QTY	 
			FROM TB_SEWON_IV_INFO	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND CMPL_YN = 'N'	 
			AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;
	 

    SET CURR_LOC_NUM = 2;

			/*입고확인시의 재고보정인 경우	 
			 입고확인작업은 수정기능이 없고, 수량이 증가만 되고 감소가 되지 않으므로	 
			 재고수량보다 출고요청수량이 큰지의 여부만을 확인해 주면 된다.	 */
			IF P_FLAG = 'Y' THEN
			   IF V_QTY < P_DIFF_RQ_QTY THEN
				  /*출고요청된 데이터의 경우 재고가 없거나 출고수량이 재고수량보다 큰 경우에도 출고가 될수 있도록	 
			   	   처리해 달라는 요청에 따라서 아래와 같은 조건 검사 부분을 추가함(재고수량보다 출고수량이 큰 경우 재고수량을 0으로 설정해 준다.)	  */
				  SET V_DIFF_RQ_QTY = V_QTY;	 
				  /*입고확인시에만 사용되므로 기존의 초과,부족 수량에 신규 부족수량을 더해 주면 된다.	 */ 
				  SET V_DEEI1_QTY   = V_DEEI1_QTY + (P_DIFF_RQ_QTY - V_QTY);	 
			   ELSE
				  SET V_DIFF_RQ_QTY = P_DIFF_RQ_QTY;
			   END IF;	 
	 
			   /*현재 날짜에 재고 데이터가 존재하지 않더라도 예외발생 없이 그대로 진행하도록 한다.	 */
			   UPDATE TB_SEWON_IV_INFO	 
			   SET IV_QTY = (IV_QTY - V_DIFF_RQ_QTY),	 
				   UPDR_EENO = V_BATCH_USER_EENO,	 
				   MDFY_DTM = SYSDATE(),	 
				   DEEI1_QTY = CASE WHEN V_DEEI1_QTY > 0 THEN V_DEEI1_QTY ELSE NULL END	 
			   WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND CMPL_YN = 'N'	 
			   AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;	 /*이전날짜의 데이터인 경우에는 입력이 되지 않도록 한다..	*/
			   

    SET CURR_LOC_NUM = 3;

			   SET V_EXCNT = 0;

	   		   SELECT COUNT(CLS_YMD)
	   		   INTO V_EXCNT	 
	   		   FROM TB_SEWON_IV_INFO 
			   WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   /*AND CMPL_YN = 'N'	*/ 
			   AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;

    SET CURR_LOC_NUM = 4;

			   /*재고 데이터가 없어서 입력이 되지 않은 경우에는 0 으로 추가해 준다.	 */
			   IF V_EXCNT = 0 THEN
				  INSERT INTO TB_SEWON_IV_INFO	 
				  (CLS_YMD,	 
			 	   QLTY_VEHL_CD,	 
			 	   DL_EXPD_MDL_MDY_CD,	 
			 	   LANG_CD,	 
			 	   N_PRNT_PBCN_NO,	 
				   PRDN_PLNT_CD,
			 	   IV_QTY,	 
			 	   DL_EXPD_TMP_IV_QTY,	 
			 	   CMPL_YN,	 
			 	   PPRR_EENO,	 
			 	   FRAM_DTM,	 
			 	   UPDR_EENO,	 
			 	   MDFY_DTM,	 
				   TMP_TRTM_YN,	 
				   DEEI1_QTY	 
			      )
				  VALUES
				  (
				         P_CLS_YMD,	 
					     P_VEHL_CD,	 
						 P_EXPD_MDL_MDY_CD,	 
						 P_LANG_CD,	 
						 P_N_PRNT_PBCN_NO,	  
						 V_PRDN_PLNT_CD, 
						 0,	 
						 0,	 
						 'N',	 
						 V_BATCH_USER_EENO,	 
						 SYSDATE(),	 
						 V_BATCH_USER_EENO,	 
						 SYSDATE(),
						 'Y',	 /*재고 데이터가 0 이므로 임시생성된다는 표시를 해준다.	*/
						 CASE WHEN V_DEEI1_QTY > 0 THEN V_DEEI1_QTY ELSE 0 END	
				 );	 
			   END IF;	 
	 

    SET CURR_LOC_NUM = 5;

			/*별도요청 관련 재고보정인 경우	 */
			ELSE
				/*재고수량이 출고수량보다 작은 경우에는 출고 하지 못한다.	 */
				/*IF V_QTY < P_DIFF_RQ_QTY THEN
			   	   CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid sewon inventory quantity ','date:', DATE_FORMAT(STR_TO_DATE(P_CLS_YMD, '%Y%m%d'), '%Y-%m-%d'), ',',	'vehl:', P_VEHL_CD, ',','mkyr:', P_EXPD_MDL_MDY_CD, ',','lang:', P_LANG_CD, ',', P_N_PRNT_PBCN_NO, ',','qty :', CONCAT(P_DIFF_RQ_QTY)));
			   	   
				   SIGNAL SQLSTATE '45000';
			    END IF;	 */
	 
				UPDATE TB_SEWON_IV_INFO	 
				SET IV_QTY = (IV_QTY - P_DIFF_RQ_QTY),	 
					UPDR_EENO = V_BATCH_USER_EENO,	 
					MDFY_DTM = SYSDATE()	 
			    WHERE CLS_YMD = P_CLS_YMD	 
			    AND QLTY_VEHL_CD = P_VEHL_CD	 
			    AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			    AND LANG_CD = P_LANG_CD	 
			    AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			    AND CMPL_YN = 'N'	 
			    AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;   /*이전날짜의 데이터인 경우에는 입력이 되지 않도록 한다..	*/			      
	 

    SET CURR_LOC_NUM = 6;


			    SET V_EXCNT = 0;

	   		    SELECT COUNT(CLS_YMD)
	   		    INTO V_EXCNT	 
	   		    FROM TB_SEWON_IV_INFO 
			    WHERE CLS_YMD = P_CLS_YMD	 
			    AND QLTY_VEHL_CD = P_VEHL_CD	 
			    AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			    AND LANG_CD = P_LANG_CD	 
			    AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			    AND CMPL_YN = 'N'	 
			    AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;


    SET CURR_LOC_NUM = 7;

			    /*IF V_EXCNT = 0 THEN	 
			   	   CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid input value ','date:', DATE_FORMAT(STR_TO_DATE(P_CLS_YMD, '%Y%m%d'), '%Y-%m-%d'), ',',	'vehl:', P_VEHL_CD, ',','mkyr:', P_EXPD_MDL_MDY_CD, ',','lang:', P_LANG_CD, ',', P_N_PRNT_PBCN_NO));
				   SIGNAL SQLSTATE '45000'; 
	 
			    END IF;	 */
	 

    SET CURR_LOC_NUM = 8;

			END IF;	 
	 
			/*현재의 출고 내역을 재고상세 테이블에 저장한다.	 */
			CALL SP_UPDATE_SEWON_IV_DTL_INFO(P_VEHL_CD,	 
			  						    P_EXPD_MDL_MDY_CD,	 
									    P_LANG_CD,	 
									    P_N_PRNT_PBCN_NO,	 
									    P_CLS_YMD,	  
										V_PRDN_PLNT_CD, 
										P_EXPD_CO_CD 
										);	 
	 

    SET CURR_LOC_NUM = 9;

			/*출고 내역에 대한 재고상세 테이블 재계산 작업 수행	 */
		    CALL SP_RECALCULATE_SEWON_IV_DTL4(P_CLS_YMD,	 
										 P_VEHL_CD,	 
									     P_LANG_CD,	  
										 V_PRDN_PLNT_CD
										 );	 



    SET CURR_LOC_NUM = 10;

	COMMIT;

    SET CURR_LOC_NUM = 11;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_WHOT_INFO_UPDATE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_WHOT_INFO_UPDATE`(IN P_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_DTL_SN INT,
                                        IN P_WHSN_YMD VARCHAR(8),
                                        IN P_RQ_QTY INT,
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_WHOT_INFO_UPDATE
 * Procedure 설명 : 입고확인시에 세원 출고내역에서 입고확인상태로 변경하는 작업 수행
 * 입력 파라미터    :  P_VEHL_CD                 차종코드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_DTL_SN                  상세일련번호
 *                 P_WHSN_YMD                입고년월일
 *                 P_RQ_QTY                  요청량
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/	
	DECLARE V_EXCNT			        INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_WHOT_INFO_UPDATE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_WHSN_YMD:',IFNULL(P_WHSN_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_DTL_SN:',IFNULL(CONCAT(P_DTL_SN),'')
							,',P_RQ_QTY:',IFNULL(CONCAT(P_RQ_QTY),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;
	   		SET V_BATCH_USER_EENO = 'BATCH';

	   		UPDATE TB_SEWON_WHOT_INFO	 
			SET RQ_QTY = P_RQ_QTY,	 
				CMPL_YN = 'Y',	 
				WHSN_YMD = P_WHSN_YMD,	 
				UPDR_EENO = V_BATCH_USER_EENO,	 
				MDFY_DTM = SYSDATE()	 
		    WHERE QLTY_VEHL_CD = P_VEHL_CD	 
			AND MDL_MDY_CD = P_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND DTL_SN = P_DTL_SN;
			

    SET CURR_LOC_NUM = 2;

			SET V_EXCNT = 0;
			SELECT COUNT(QLTY_VEHL_CD)	 
				  INTO V_EXCNT	 
			FROM TB_SEWON_WHOT_INFO 
			WHERE QLTY_VEHL_CD = P_VEHL_CD	 
			AND MDL_MDY_CD = P_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND DTL_SN = P_DTL_SN;				
				 

    SET CURR_LOC_NUM = 3;

			/*IF V_EXCNT = 0 THEN			   	 
			   CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Invalid input value ' ,  	 
			   								   'date:' ,  DATE_FORMAT(STR_TO_DATE(P_WHSN_YMD, '%Y%m%d'), '%Y-%m-%d') ,  ',' , 	 
											   'vehl:' ,  P_VEHL_CD ,  ',' ,  	 
											   'mkyr:' ,  P_EXPD_MDL_MDY_CD ,  ',' ,  	 
											   'lang:' ,  P_LANG_CD ,  ',' ,  P_N_PRNT_PBCN_NO , 	 
											   'sn:'   ,  DATE_FORMAT(P_DTL_SN,'%Y%m%d')));	 
			   SIGNAL SQLSTATE '45000';
			   	 
			END IF;	 */
				 

    SET CURR_LOC_NUM = 4;

			/* 재고정보 업데이트 작업 수행 	  */
			CALL SP_SEWON_IV_INFO_UPDATE(P_VEHL_CD,	 
											P_MDL_MDY_CD, 	 
											P_LANG_CD,	 
											P_EXPD_MDL_MDY_CD,  	 
											P_N_PRNT_PBCN_NO, 	 
											P_WHSN_YMD, 	 
											P_RQ_QTY, 	 	 
											'Y',	 
											NULL,
											P_EXPD_CO_CD
											);


    SET CURR_LOC_NUM = 5;

	COMMIT;


    SET CURR_LOC_NUM = 6;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_WHSN_INFO_CANCEL 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_WHSN_INFO_CANCEL`(IN P_WHSN_YMD VARCHAR(8),
                                        IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_WHSN_QTY INT,
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN	
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_WHSN_INFO_CANCEL
 * Procedure 설명 : 세원 입고정보 취소 수행
 * 입력 파라미터    :  P_WHSN_YMD                입고년월일
 *                 P_QLTY_VEHL_CD            품질차종코드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_WHSN_QTY                입고량
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_QTY			INT;	 
	DECLARE V_PRDN_PLNT_CD	VARCHAR(1);	

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_WHSN_INFO_CANCEL',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_WHSN_YMD:',IFNULL(P_WHSN_YMD,'')
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_WHSN_QTY:',IFNULL(CONCAT(P_WHSN_QTY),'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,'')
							,',V_QTY:',IFNULL(CONCAT(V_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

          IF P_QLTY_VEHL_CD = 'AM' OR P_QLTY_VEHL_CD = 'PS' OR P_QLTY_VEHL_CD = 'SK3' THEN	 
				SET V_PRDN_PLNT_CD = '7';   /*   세원재고는 광주 7로 통일	  */
		  ELSE	 
		  		SET V_PRDN_PLNT_CD = 'N';	 
          END IF;	 
	  	   	 
		   /* 현재날짜의 재고수량을 확인해 본다. 	  */
		   SELECT IFNULL(SUM(IV_QTY), 0)	 
		   INTO V_QTY	 
		   FROM TB_SEWON_IV_INFO	 
		   WHERE CLS_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d')	 
		   AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
		   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
		   AND LANG_CD = P_LANG_CD	 
		   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
		   AND CMPL_YN = 'N';	 
		   	 

    SET CURR_LOC_NUM = 2;

		   IF V_QTY <> P_WHSN_QTY THEN
			  /*CALL RAISE_APPLICATION_ERROR(-20001, CONCAT('Sewon inventory quantity is already used ' ,  	 
			   								  'date:' ,  DATE_FORMAT(STR_TO_DATE(P_WHSN_YMD, '%Y%m%d'), '%Y-%m-%d') ,  ',' , 	 
											  'vehl:' ,  P_QLTY_VEHL_CD ,  ',' ,  	 
											  'mkyr:' ,  P_EXPD_MDL_MDY_CD ,  ',' ,  	 
											  'lang:' ,  P_LANG_CD ,  ',' ,  P_N_PRNT_PBCN_NO));
			   SIGNAL SQLSTATE '45000';*/

    SET CURR_LOC_NUM = 3;

		   ELSE
			   /* 1.입고된 내역 삭제 	 
			     입고된 내역에서 입고일 상관없이 관련 신인쇄발간번호에 대해 모두 삭제처리되어야 함.	  */
			   DELETE FROM TB_SEWON_WHSN_INFO	 
			   WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
			   AND MDL_MDY_CD = P_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO;	 
			   	 

    SET CURR_LOC_NUM = 4;

			   /* 2.재고정보 삭제 	  */
			   CALL SP_SEWON_IV_INFO_CANCL_BY_WHSN(P_WHSN_YMD,	 
			  						       	  	      P_QLTY_VEHL_CD,	 
													  P_MDL_MDY_CD,	 
									       	  	      P_LANG_CD,	 
													  P_EXPD_MDL_MDY_CD,	 
									       	  	      P_N_PRNT_PBCN_NO,
									       	  	      V_PRDN_PLNT_CD,
									       	  	      P_EXPD_CO_CD
									       	  	      );	

    SET CURR_LOC_NUM = 5;
 
		   END IF;	 
	  	 /*
			EXCEPTION	 
				WHEN OTHERS THEN	 
					ROLLBACK;	 
					PG_INTERFACE_APS.WRITE_BATCH_EXE_LOG('승인취소 에러', SYSDATE(), 'F', CONCAT('SP_SEWON_WHSN_INFO_CANCEL 배치처리실패 : [' ,  SQLERRM ,  ']'));	
*/


	COMMIT;

    SET CURR_LOC_NUM = 6;


END//
DELIMITER ;

-- 프로시저 hkomms.SP_SEWON_WHSN_INFO_SAVE 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_SEWON_WHSN_INFO_SAVE`(IN P_WHSN_YMD VARCHAR(8),
                                        IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_WHSN_QTY INT,
                                        IN P_CRGR_EENO VARCHAR(20),
                                        IN P_PRNT_PARR_YMD VARCHAR(8),
                                        IN P_DLVG_PARR_YMD VARCHAR(8),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_SEWON_WHSN_INFO_SAVE
 * Procedure 설명 : 세화 입고정보/재고정보 Insert
 * 입력 파라미터    :  P_WHSN_YMD                입고년월일
 *                 P_QLTY_VEHL_CD            품질차종콩드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_WHSN_QTY                입고량
 *                 P_CRGR_EENO               담당자사원번호
 *                 P_PRNT_PARR_YMD           인쇄예정년월일
 *                 P_DLVG_PARR_YMD           배송예정년월일
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_PRDN_PLNT_CD		VARCHAR(1); 
	DECLARE V_EXCNT   			INT;	
	DECLARE V_BATCH_USER_EENO VARCHAR(20); 

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_SEWON_WHSN_INFO_SAVE',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_WHSN_YMD:',IFNULL(P_WHSN_YMD,'')
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_CRGR_EENO:',IFNULL(P_CRGR_EENO,'')
							,',P_PRNT_PARR_YMD:',IFNULL(P_PRNT_PARR_YMD,'')
							,',P_DLVG_PARR_YMD:',IFNULL(P_DLVG_PARR_YMD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,'')
							,',P_WHSN_QTY:',IFNULL(CONCAT(P_WHSN_QTY),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';

	IF P_QLTY_VEHL_CD = 'AM' OR P_QLTY_VEHL_CD = 'PS' OR P_QLTY_VEHL_CD = 'SK3' THEN	 
		SET V_PRDN_PLNT_CD = '7';	 
	ELSE 	 
   		SET V_PRDN_PLNT_CD = 'N';	 
	END IF;	 
	        	 
    SET CURR_LOC_NUM = 2;
	/*입고정보 테이블에 데이터 Insert 	 */
   
    SET V_EXCNT = 0;

    SELECT COUNT(WHSN_YMD)
    INTO V_EXCNT	 
    FROM TB_SEWON_WHSN_INFO 
    WHERE WHSN_YMD = P_WHSN_YMD	 
    AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
    AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD 
    AND LANG_CD = P_LANG_CD	 
    AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
    AND MDL_MDY_CD = P_MDL_MDY_CD 
    AND PRDN_PLNT_CD = V_PRDN_PLNT_CD;
   
    SET CURR_LOC_NUM = 3;
   
    IF V_EXCNT = 0 THEN
    SET CURR_LOC_NUM = 4;
		INSERT INTO TB_SEWON_WHSN_INFO	 
		(
		         WHSN_YMD,	 
				 QLTY_VEHL_CD,	 
				 DL_EXPD_MDL_MDY_CD,	 
				 LANG_CD,	 
				 N_PRNT_PBCN_NO,	 
				 WHSN_QTY,	 
				 CRGR_EENO,	 
				 PRNT_PARR_YMD,	 
				 DLVG_PARR_YMD,	 
				 PPRR_EENO,	 
				 FRAM_DTM,	 
				 UPDR_EENO,	 
				 MDFY_DTM,	 
				 MDL_MDY_CD,	 
				 PRDN_PLNT_CD	 
		)	 
		VALUES	 
		(
		         P_WHSN_YMD,	 
				 P_QLTY_VEHL_CD,	 
				 P_EXPD_MDL_MDY_CD,	 
				 P_LANG_CD,	 
				 P_N_PRNT_PBCN_NO,	 
				 P_WHSN_QTY,	 
				 P_CRGR_EENO,	 
				 P_PRNT_PARR_YMD,	 
				 P_DLVG_PARR_YMD,	 
				 V_BATCH_USER_EENO,	 
				 SYSDATE(),	 
				 V_BATCH_USER_EENO,	 
				 SYSDATE(),	 
				 P_MDL_MDY_CD,	 
				 V_PRDN_PLNT_CD	 
		);	 
    SET CURR_LOC_NUM = 5;
    END IF;		

   
    SET CURR_LOC_NUM = 6;

	CALL SP_SEWON_IV_INFO_SAVE_BY_WHSN(P_WHSN_YMD,	 
			  						     		  P_QLTY_VEHL_CD,	 
												  P_MDL_MDY_CD,	 
									     		  P_LANG_CD,	 
												  P_EXPD_MDL_MDY_CD,	 
									     		  P_N_PRNT_PBCN_NO,	 
									     		  P_WHSN_QTY,	 
									     		  P_DLVG_PARR_YMD,	
									     		  V_PRDN_PLNT_CD, 
									     		  P_EXPD_CO_CD 
									     		  );	 
								     		  	 



    SET CURR_LOC_NUM = 7;

	COMMIT;


    SET CURR_LOC_NUM = 8;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_APS_DATA 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_APS_DATA`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_APS_DATA
 * Procedure 설명 : TB_BATCH_FNH_INFO 금일정보 삭제후 APS 인터페이스 실행
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_APS_DATA',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

	DELETE FROM TB_BATCH_FNH_INFO
	WHERE BTCH_FNH_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d')
		AND AFFR_SCN_CD IN ('01', '02');
	

    SET CURR_LOC_NUM = 2;

	COMMIT;
	
	IF P_EXPD_CO_CD='02' THEN
		CALL SP_APS_INTERFACE_KMC(P_EXPD_CO_CD);
	ELSE
		CALL SP_APS_INTERFACE_HMC(P_EXPD_CO_CD);
	END IF;

    SET CURR_LOC_NUM = 3;

	/*
    EXCEPTION
          WHEN OTHERS THEN
                   ROLLBACK ;
               CALL RAISE_APPLICATION_ERROR(-20102, CONCAT(' CODE=' ,  SQLCODE ,  ',ERRM=' ,  SQLERRM) );
			   SIGNAL SQLSTATE '45000';



	COMMIT;
*/
END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_LANG_MGMT 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_LANG_MGMT`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_LANG_MGMT
 * Procedure 설명 : 언어정보 수정
 * 입력 파라미터    :  P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_LANG_MGMT',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

		/* 국가코드관리에서는 국가별 차종/언어 설정이 추가되어 있으나 	 
		   언어코드 관리 화면에 차종별 언어 설정이 없는 경우 추가 처리	 */
			INSERT INTO TB_LANG_MGMT (
					 DATA_SN,
					 QLTY_VEHL_CD,
					 MDL_MDY_CD,
					 LANG_CD,
					 DL_EXPD_REGN_CD,
					 LANG_CD_NM,
					 USE_YN,
					 NAPC_YN,
					 PPRR_EENO,
					 FRAM_DTM,
					 UPDR_EENO,
					 MDFY_DTM,
					 SORT_SN,
					 A_CODE,
					 N1_INS_YN,
					 ET_YN
					)			    
				  SELECT
						ROWNM+DATA_SN DATA_SN,
						QLTY_VEHL_CD,
						MDL_MDY_CD,
						LANG_CD,
						DL_EXPD_REGN_CD,
						LANG_CD_NM,
						USE_YN,
						NAPC_YN,
						PPRR_EENO,
						FRAM_DTM,
						UPDR_EENO,
						MDFY_DTM,
						SORT_SN,
						A_CODE,
						N1_INS_YN,
						ET_YN
				  FROM
					(SELECT
						A.DATA_SN,
						QLTY_VEHL_CD,
						MDL_MDY_CD,
						LANG_CD,
						DL_EXPD_REGN_CD,
						LANG_CD_NM,
						USE_YN,
						NAPC_YN,
						PPRR_EENO,
						FRAM_DTM,
						UPDR_EENO,
						MDFY_DTM,
						SORT_SN,
						A_CODE,
						N1_INS_YN,
						ET_YN,
						(SELECT COUNT(K.DATA_SN) 
						   FROM TB_LANG_MGMT K 
						  WHERE K.QLTY_VEHL_CD = A.QLTY_VEHL_CD 
							AND K.MDL_MDY_CD = A.MDL_MDY_CD 
							AND K.LANG_CD = A.LANG_CD) AS EXCNT,
						ROW_NUMBER() OVER() AS ROWNM
					FROM (
						SELECT
							DISTINCT
							(SELECT IFNULL(MAX(DATA_SN), 0) FROM TB_LANG_MGMT) DATA_SN,
							A.QLTY_VEHL_CD,
							A.MDL_MDY_CD,
							A.LANG_CD,
							D.DL_EXPD_REGN_CD,
							D.LANG_CD_NM,
							'Y' USE_YN,
							'N' NAPC_YN,
							'SYSTEM' PPRR_EENO,
							SYSDATE() FRAM_DTM,
							NULL UPDR_EENO,
							NULL MDFY_DTM,
							NULL SORT_SN,
							NULL A_CODE,
							'N' N1_INS_YN,
							NULL ET_YN
						FROM TB_NATL_LANG_MGMT A
						LEFT OUTER JOIN TB_LANG_MGMT B ON (A.QLTY_VEHL_CD = B.QLTY_VEHL_CD AND A.MDL_MDY_CD = B.MDL_MDY_CD AND A.LANG_CD = B.LANG_CD)
						INNER JOIN TB_NATL_MGMT C ON (A.DL_EXPD_CO_CD = C.DL_EXPD_CO_CD AND A.DL_EXPD_NAT_CD = C.DL_EXPD_NAT_CD)
						INNER JOIN TB_LANG_MAST D ON (A.LANG_CD = D.LANG_CD)
						WHERE B.QLTY_VEHL_CD IS NULL
							AND A.MDL_MDY_CD >= '17'	 
						) A
				  ) T
				  WHERE T.EXCNT=0;


    SET CURR_LOC_NUM = 2;

	COMMIT;
	    

    SET CURR_LOC_NUM = 3;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_NATL_VEHL_MGMT 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_NATL_VEHL_MGMT`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_NATL_VEHL_MGMT
 * Procedure 설명 : 국가차량정보 수정
 *                 국가별 언어코드에는 추가되어있으나, 국가별 차종코드에는 추가되지 않은 경우 처리
 * 입력 파라미터    :  P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_RQ_YMD	VARCHAR(8);	 
	DECLARE V_DTL_SN	INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_NATL_VEHL_MGMT',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_RQ_YMD:',IFNULL(V_RQ_YMD,'')
							,',V_DTL_SN:',IFNULL(CONCAT(V_DTL_SN),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;

				INSERT INTO TB_NATL_VEHL_MGMT (
					 DL_EXPD_CO_CD
					,DL_EXPD_NAT_CD
					,QLTY_VEHL_CD
					,DL_EXPD_REGN_CD
					,PPRR_EENO
					,FRAM_DTM
					,UPDR_EENO
					,MDFY_DTM
					) 
				SELECT	 
					DISTINCT	 
					  A.DL_EXPD_CO_CD	 
					, A.DL_EXPD_NAT_CD	 
					, A.QLTY_VEHL_CD	 
					, C.DL_EXPD_REGN_CD	 
					, 'SYSTEM'	 
					, SYSDATE()	 
					, 'SYSTEM'	 
					, SYSDATE()	 
				FROM TB_NATL_LANG_MGMT A	 
				LEFT OUTER JOIN TB_NATL_VEHL_MGMT B	 
					ON A.QLTY_VEHL_CD = B.QLTY_VEHL_CD AND A.DL_EXPD_NAT_CD = B.DL_EXPD_NAT_CD	 
				INNER JOIN TB_NATL_MGMT C	 
					ON A.DL_EXPD_CO_CD = C.DL_EXPD_CO_CD AND A.DL_EXPD_NAT_CD = C.DL_EXPD_NAT_CD	 
				WHERE B.QLTY_VEHL_CD IS NULL;

    SET CURR_LOC_NUM = 2;

	COMMIT;

    SET CURR_LOC_NUM = 3;

	    
END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_PDI_IV_DTL_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_PDI_IV_DTL_INFO`(IN P_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_CLS_YMD VARCHAR(8),
                                        IN P_PRDN_PLNT_CD VARCHAR(3))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_PDI_IV_DTL_INFO
 * Procedure 설명 : 입고/출고된 항목에 대한 재고상세 테이블 업데이트 작업 수행	 
 * 입력 파라미터    :  P_VEHL_CD                 차종코드
 *                 P_EXPD_MDL_MDY_CD         취급설명서모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_N_PRNT_PBCN_NO          신인쇄발간번호
 *                 P_CLS_YMD                 마감년월일
 *                 P_PRDN_PLNT_CD            생산공장코드
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CMPL_YN		VARCHAR(1);
	DECLARE V_TMP_TRTM_YN	VARCHAR(1);
	DECLARE V_IV_QTY		INT;
	DECLARE V_CNT			INT;
	DECLARE V_BATCH_USER_EENO VARCHAR(20);
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_PDI_IV_DTL_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',V_CMPL_YN:',IFNULL(V_CMPL_YN,'')
							,',V_TMP_TRTM_YN:',IFNULL(V_TMP_TRTM_YN,'')
							,',V_IV_QTY:',IFNULL(CONCAT(V_IV_QTY),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			/*재고 테이블 재고 수량 조회	 */
			SELECT SUM(IV_QTY),	 
			   	   MAX(CMPL_YN),	 
				   MAX(TMP_TRTM_YN)	 
			INTO V_IV_QTY,	 
			     V_CMPL_YN,	 
				 V_TMP_TRTM_YN	 
			FROM TB_PDI_IV_INFO	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND PRDN_PLNT_CD = P_PRDN_PLNT_CD; 
	 

    SET CURR_LOC_NUM = 2;

			/*재고 테이블에 데이터가 존재하는 경우에 아래의 작업을 수행한다.	 */
			IF V_CMPL_YN IS NOT NULL THEN
			   /*재고상세 테이블내에 취급설명서연식으로 적용된 항목의 재고수량을 변경된 수량으로	 
			     모두 업데이트 해 준다.	 
			     단, 차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해준다.	 
			     (왜냐하면 같은 않은 항목은 재고 상세 내역 재계산시에 우선 삭제된 뒤에 다시 계산하기 때문에 의미가 없다.)	 */
			   UPDATE TB_PDI_IV_INFO_DTL	 
			   SET IV_QTY = V_IV_QTY,	 
			   	   /*안전재고의 수량을 재고수량과 같게 해준다.	 */
			   	   SFTY_IV_QTY = V_IV_QTY,	 
			   	   CMPL_YN = V_CMPL_YN,	 
				   UPDR_EENO = V_BATCH_USER_EENO,	 
				   MDFY_DTM = SYSDATE(),	 
				   TMP_TRTM_YN = V_TMP_TRTM_YN	 
			   WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   /*차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해 주도록 한다.	 */
			   AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;

				SET V_EXCNT = 0;
				SELECT COUNT(CLS_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PDI_IV_INFO_DTL 
			   WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   /*차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해 주도록 한다.	 */
			   AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;

			   IF V_EXCNT = 0 THEN	 
	 
				  INSERT INTO TB_PDI_IV_INFO_DTL	 
				   (CLS_YMD,	 
				   	QLTY_VEHL_CD,	 
				   	MDL_MDY_CD,	 
				   	LANG_CD,	 
				   	DL_EXPD_MDL_MDY_CD,	 
				   	N_PRNT_PBCN_NO,	 
				   	IV_QTY,	 
				   	SFTY_IV_QTY,	 
				   	CMPL_YN,	 
				   	PPRR_EENO,	 
				   	FRAM_DTM,	 
				   	UPDR_EENO,	 
				   	MDFY_DTM,	 
					TMP_TRTM_YN,	 
					PRDN_PLNT_CD
				   )	 
				   VALUES	 
				   (P_CLS_YMD,	 
				   	P_VEHL_CD,	 
					/*차종의 연식과 취급설명서의 연식을 같은 값으로 입력해 준다.(반드시 취급설명서의 연식으로 입력)	 */
				   	P_EXPD_MDL_MDY_CD,	 
				   	P_LANG_CD,	 
				   	P_EXPD_MDL_MDY_CD,	 
				   	P_N_PRNT_PBCN_NO,	 
				   	V_IV_QTY,	 
					/*차종의 연식과 취급설명서의 연식이 같은 경우에는 안전재고의 수량을 재고수량과 같게 해준다.	 */
				   	V_IV_QTY,	 
				   	V_CMPL_YN,	 
				   	V_BATCH_USER_EENO,	 
				   	SYSDATE(),	 
				   	V_BATCH_USER_EENO,	 
				   	SYSDATE(),	 
					V_TMP_TRTM_YN,	 
					P_PRDN_PLNT_CD
				   );
			   END IF;
			END IF;

    SET CURR_LOC_NUM = 3;

	COMMIT;


    SET CURR_LOC_NUM = 4;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_PDI_IV_INFO1 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_PDI_IV_INFO1`(IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_APL_YMD VARCHAR(8),
                                        IN P_TRWI_DIFF INT,
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN 
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_PDI_IV_INFO1
 * Procedure 설명 : 원래의 출고수량보다 투입수량이 많아진 경우 호출
 *                 출고항목 업데이트 작업 수행
 *                 수정된 항목이 없다면 Insert 해준다.
 * 입력 파라미터    :  P_QLTY_VEHL_CD            품질차종코드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_APL_YMD                 적용년월일
 *                 P_TRWI_DIFF               투입차
 *                 P_PRDN_PLNT_CD            생산공장코드
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_DL_EXPD_MDL_MDY_CD	VARCHAR(4);
	DECLARE V_N_PRNT_PBCN_NO		VARCHAR(100);
	DECLARE BTCH_USER_EENO		    VARCHAR(20);
	DECLARE V_BATCH_USER_EENO       VARCHAR(20);
	DECLARE V_TRWI_DIFF				INT;
	DECLARE V_WHOT_DIFF				INT;
	DECLARE V_IV_DIFF				INT;
	DECLARE V_DTL_SN				INT;
	
	DECLARE V_CLS_YMD_1 VARCHAR(8);
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO_1 VARCHAR(100);
	DECLARE V_DTL_SN_1 INT;
	DECLARE V_IV_QTY_1 INT;
	DECLARE V_EXPD_WHOT_QTY_1 INT;
	DECLARE V_PRDN_PLNT_CD_1 VARCHAR(3);

	DECLARE V_DL_EXPD_REGN_CD		VARCHAR(4);
	DECLARE V_CNT	INT;
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_INFO CURSOR FOR
							   SELECT A.CLS_YMD,	 
							   		  A.QLTY_VEHL_CD,	 
									  A.DL_EXPD_MDL_MDY_CD,	 
									  A.LANG_CD,	 
									  A.N_PRNT_PBCN_NO,	 
									  IFNULL(B.DTL_SN, 0) AS DTL_SN,	 
									  A.IV_QTY,	 
									  IFNULL(B.DL_EXPD_WHOT_QTY, 0) AS EXPD_WHOT_QTY,	 
									  A.PRDN_PLNT_CD	 
							   FROM (SELECT B.CLS_YMD,	 
									 	    B.QLTY_VEHL_CD,	 
										    B.DL_EXPD_MDL_MDY_CD,	 
											B.LANG_CD,	 
											B.N_PRNT_PBCN_NO,	 
											B.IV_QTY,	 
											A.MDL_MDY_CD,	 
											B.PRDN_PLNT_CD	 
									 FROM (SELECT A.QLTY_VEHL_CD,	 
						   		                  B.DL_EXPD_MDL_MDY_CD,	 
								                  A.LANG_CD,	 
												  A.MDL_MDY_CD	 
                                           FROM TB_LANG_MGMT A,	 
								                TB_DL_EXPD_MDY_MGMT B	 
                                           WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                                           AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND A.DL_EXPD_REGN_CD = B.DL_EXPD_REGN_CD
						                   AND A.QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
						                   AND A.MDL_MDY_CD = P_MDL_MDY_CD	 
						                   AND A.LANG_CD = P_LANG_CD	 
										  ) A,	 
										  TB_PDI_IV_INFO B	 
									 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
					                 AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
					                 AND A.LANG_CD = B.LANG_CD	 
								     AND B.CLS_YMD = P_APL_YMD	 
								     AND B.PRDN_PLNT_CD = P_PRDN_PLNT_CD
									 /*재고 데이터가 0 보다 큰 값만을 가져온다.	 */
									 AND B.IV_QTY > 0	 
									) A LEFT JOIN TB_PDI_WHOT_INFO B	 
								    ON (A.QLTY_VEHL_CD = B.QLTY_VEHL_CD
										AND A.MDL_MDY_CD = B.MDL_MDY_CD
										AND A.LANG_CD = B.LANG_CD
										AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD
										AND A.N_PRNT_PBCN_NO = B.N_PRNT_PBCN_NO
										AND A.CLS_YMD = B.WHOT_YMD
										AND B.DEL_YN = 'N'
										/*출고로 빠진 데이터만을 가져오도록 한다.	  */
										AND B.DL_EXPD_WHOT_ST_CD = '01'
										AND A.PRDN_PLNT_CD = B.PRDN_PLNT_CD
										/*[변경] 2010.02.03.김동근 발간번호 정렬방식 변경	 이전연식의 재고부터 빼주도록 한다.	  */
									  )
							    WHERE 1=1
								ORDER BY A.DL_EXPD_MDL_MDY_CD, FU_GET_SORT_PBCN(A.N_PRNT_PBCN_NO);

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_PDI_IV_INFO1',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_APL_YMD:',IFNULL(P_APL_YMD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',BTCH_USER_EENO:',IFNULL(BTCH_USER_EENO,'')
							,',V_CLS_YMD_1:',IFNULL(V_CLS_YMD_1,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,'')
							,',V_PRDN_PLNT_CD_1:',IFNULL(V_PRDN_PLNT_CD_1,'')
							,',V_DL_EXPD_REGN_CD:',IFNULL(V_DL_EXPD_REGN_CD,'')
							,',P_TRWI_DIFF:',IFNULL(CONCAT(P_TRWI_DIFF),'')
							,',V_TRWI_DIFF:',IFNULL(CONCAT(V_TRWI_DIFF),'')
							,',V_WHOT_DIFF:',IFNULL(CONCAT(V_WHOT_DIFF),'')
							,',V_IV_DIFF:',IFNULL(CONCAT(V_IV_DIFF),'')
							,',V_DTL_SN:',IFNULL(CONCAT(V_DTL_SN),'')
							,',V_DTL_SN_1:',IFNULL(CONCAT(V_DTL_SN_1),'')
							,',V_IV_QTY_1:',IFNULL(CONCAT(V_IV_QTY_1),'')
							,',V_EXPD_WHOT_QTY_1:',IFNULL(CONCAT(V_EXPD_WHOT_QTY_1),'')
							,',V_EXCNT:',IFNULL(CONCAT(V_EXCNT),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';
    SET BTCH_USER_EENO = V_BATCH_USER_EENO;

	SET V_TRWI_DIFF = P_TRWI_DIFF;

	OPEN PDI_IV_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_INFO INTO V_CLS_YMD_1,V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1,V_N_PRNT_PBCN_NO_1,V_DTL_SN_1,V_IV_QTY_1,V_EXPD_WHOT_QTY_1,V_PRDN_PLNT_CD_1;
    SET CURR_LOC_NUM = 2;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

    SET CURR_LOC_NUM = 3;
				IF V_TRWI_DIFF > 0 THEN
    SET CURR_LOC_NUM = 4;
				   IF V_IV_QTY_1 >= V_TRWI_DIFF THEN
    SET CURR_LOC_NUM = 5;
				   	  SET V_WHOT_DIFF = V_TRWI_DIFF; /*출고로 추가 빼주어야 하는 수량	 */
					  SET V_IV_DIFF   = V_TRWI_DIFF; /*재고에서 추가 빼주어야 하는 수량	 */
					  SET V_TRWI_DIFF = 0;
    SET CURR_LOC_NUM = 6;
				   ELSE
    SET CURR_LOC_NUM = 7;
					  SET V_WHOT_DIFF = V_IV_QTY_1; /*출고로 추가 빼주어야 하는 수량	 */
					  SET V_IV_DIFF   = V_IV_QTY_1; /*재고에서 추가 빼주어야 하는 수량	 */
					  SET V_TRWI_DIFF = V_TRWI_DIFF - V_IV_QTY_1;
    SET CURR_LOC_NUM = 8;
				   END IF;
	 
    SET CURR_LOC_NUM = 9;
				    /*출고항목 업데이트 작업 수행	 */
    			    UPDATE TB_PDI_WHOT_INFO	 
    		        SET CRGR_EENO = BTCH_USER_EENO,	 
    			        DL_EXPD_WHOT_QTY = DL_EXPD_WHOT_QTY + V_WHOT_DIFF,	 
    			        DEL_YN = 'N',	 
    			        UPDR_EENO = BTCH_USER_EENO,	 
    			        MDFY_DTM = SYSDATE()	 
    			    WHERE WHOT_YMD = P_APL_YMD	 
    	        	AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		        AND LANG_CD = P_LANG_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
    		        AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
    		        AND DTL_SN = V_DTL_SN_1	 
    		        AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;
	 
    SET CURR_LOC_NUM = 10;
				  SET V_EXCNT = 0;
				  SELECT COUNT(WHOT_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_PDI_WHOT_INFO 
    			    WHERE WHOT_YMD = P_APL_YMD	 
    	        	AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		        AND LANG_CD = P_LANG_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
    		        AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
    		        AND DTL_SN = V_DTL_SN_1	 
    		        AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;
    SET CURR_LOC_NUM = 11;
    				/*수정된 항목이 없다면 Insert 해준다.	 */
    		    	IF V_EXCNT = 0 THEN	 
    SET CURR_LOC_NUM = 12;
    			  	   INSERT INTO TB_PDI_WHOT_INFO	 
       			  	   (WHOT_YMD,	 
    			   	    QLTY_VEHL_CD,	 
       			        DL_EXPD_MDL_MDY_CD,	 
       			        LANG_CD,	 
       			        N_PRNT_PBCN_NO,	 
       			        DTL_SN,	 
    			        DL_EXPD_WHOT_ST_CD,	 
    			        CRGR_EENO,	 
    			        DL_EXPD_WHOT_QTY,	 
    			        DEL_YN,	 
    			        PPRR_EENO,	 
       			        FRAM_DTM,	 
       			        UPDR_EENO,	 
       			        MDFY_DTM,	 
						MDL_MDY_CD,	 
						PRDN_PLNT_CD	 
       			       )	 
       			       SELECT P_APL_YMD,	 
    			  		      P_QLTY_VEHL_CD,	 
       			              V_DL_EXPD_MDL_MDY_CD_1,	 
       					      P_LANG_CD,	 
       					      V_N_PRNT_PBCN_NO_1,	 
       					      IFNULL(MAX(DTL_SN), 0) + 1,	 
       		                  '01',	 
    					      BTCH_USER_EENO,	 
    					      V_WHOT_DIFF,	 
    					      'N',	 
    					      BTCH_USER_EENO,	 
    					      SYSDATE(),	 
    					      BTCH_USER_EENO,	 
    					      SYSDATE(),	 
							  P_MDL_MDY_CD,	 
							  P_PRDN_PLNT_CD	 
       			       FROM TB_PDI_WHOT_INFO	 
    			       WHERE WHOT_YMD = P_APL_YMD	 
       			       AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
       			       AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
       			       AND LANG_CD = P_LANG_CD	 
       			       AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
       			       AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;
	 
    SET CURR_LOC_NUM = 13;
    		        END IF;	 	 
    SET CURR_LOC_NUM = 14;
					/*재고항목 업데이트 작업 수행	 */
					CALL SP_PDI_IV_INFO_UPDATE(P_QLTY_VEHL_CD,	 
										  P_MDL_MDY_CD,	 
										  P_LANG_CD,	 
										  V_DL_EXPD_MDL_MDY_CD_1,	 
										  V_N_PRNT_PBCN_NO_1,	 
										  P_APL_YMD,	 
										  V_IV_DIFF,	 
										  'Y',	 
										  'Y',	 
										  P_PRDN_PLNT_CD,	 
										  P_EXPD_CO_CD 
										  );
				/*ELSE	 
					출고처리해야할 수량이 0 이 되면 작업을 종료한다.
					RETURN;	 	 */	 
    SET CURR_LOC_NUM = 15;
				END IF;

    SET CURR_LOC_NUM = 16;
	END LOOP JOBLOOP1 ;
	CLOSE PDI_IV_INFO;
	 

    SET CURR_LOC_NUM = 17;

			/*재고를 다 소진하였는데도 아직 출고해야할 항목이 더 존재한다면....	 */
			IF V_TRWI_DIFF > 0 THEN
    SET CURR_LOC_NUM = 18;
			   /*CALL SP_GET_PDI_N_PRNT_PBCN_NO(P_QLTY_VEHL_CD,	 
                                   	     P_MDL_MDY_CD,	 
                                   	     P_LANG_CD,	 
                                   	     P_APL_YMD,	 
								   	     V_DL_EXPD_MDL_MDY_CD,	 
		 								 V_N_PRNT_PBCN_NO,	 
		 								 P_PRDN_PLNT_CD,
		 								 P_EXPD_CO_CD
										 );	 */


				SET V_DL_EXPD_MDL_MDY_CD = NULL;	 
				SET V_N_PRNT_PBCN_NO     = NULL;	 
				 
    SET CURR_LOC_NUM = 19;
				SELECT MAX(DL_EXPD_REGN_CD)	 
				INTO V_DL_EXPD_REGN_CD	 
				FROM TB_LANG_MGMT	 
				WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
				AND MDL_MDY_CD = P_MDL_MDY_CD	 
				AND LANG_CD = P_LANG_CD;	
			
			
    SET CURR_LOC_NUM = 20;
				/*TB_PDI_IV_INFO_DTL  테이블이 아니라 TB_PDI_IV_INFO 테이블에서 조회하면 된다.	 
				  왜냐하면 이곳에서는 즉시 재고 재계산 작업이 즉시 이루어지기 때문이다.	
				  현재는 무조건 가장 최근(큰) 연식을 가져오도록 처리함	 
				  (필요에 따라 현재의 차종연식과 같은 연식이 있으면 그것을 가져오도록 변경할 여지도 있을듯함)	 */
				SELECT MAX(A.DL_EXPD_MDL_MDY_CD)	 
				INTO V_DL_EXPD_MDL_MDY_CD	 
				FROM TB_PDI_IV_INFO A,	 
					 TB_DL_EXPD_MDY_MGMT B	 
				WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
				AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
				AND A.CLS_YMD <= P_APL_YMD	 
				AND B.QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
				AND B.MDL_MDY_CD = P_MDL_MDY_CD	 
				AND B.DL_EXPD_REGN_CD = V_DL_EXPD_REGN_CD	 
				AND A.LANG_CD = P_LANG_CD	 
				AND A.PRDN_PLNT_CD = P_PRDN_PLNT_CD; 
			
			
    SET CURR_LOC_NUM = 21;
				IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL THEN
    SET CURR_LOC_NUM = 22;
					SELECT MAX(N_PRNT_PBCN_NO)	 
					INTO V_N_PRNT_PBCN_NO	 
					FROM TB_PDI_IV_INFO	 
					WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
					AND LANG_CD = P_LANG_CD	 
					AND CLS_YMD <= P_APL_YMD	 
					AND PRDN_PLNT_CD = P_PRDN_PLNT_CD; 	 
			
    SET CURR_LOC_NUM = 23;
			
				/*PDI에 한번도 입고되지 않은 항목에 대해서는 세화재고에 데이터가 존재하는 내역을 이용하도록 한다.	*/ 
				ELSE
    SET CURR_LOC_NUM = 24;
					/*현재는 무조건 가장 최근(큰) 연식을 가져오도록 처리함	 
					  (필요에 따라 현재의 차종연식과 같은 연식이 있으면 그것을 가져오도록 변경할 여지도 있을듯함)	 */
					SELECT MAX(A.DL_EXPD_MDL_MDY_CD)	 
					INTO V_DL_EXPD_MDL_MDY_CD	 
					FROM TB_SEWON_IV_INFO A,	 
					    TB_DL_EXPD_MDY_MGMT B	 
					WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
					AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
					AND A.CLS_YMD <= P_APL_YMD	 
					/*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	 */
					AND A.DL_EXPD_TMP_IV_QTY = 0	 
					AND B.QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND B.MDL_MDY_CD = P_MDL_MDY_CD	 
					AND B.DL_EXPD_REGN_CD = V_DL_EXPD_REGN_CD	 
					AND A.LANG_CD = P_LANG_CD	 
					AND A.PRDN_PLNT_CD= P_PRDN_PLNT_CD;
				 
    SET CURR_LOC_NUM = 25;
			
					IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL THEN	
    SET CURR_LOC_NUM = 26; 
						SELECT MAX(N_PRNT_PBCN_NO)	 
						INTO V_N_PRNT_PBCN_NO	 
						FROM TB_SEWON_IV_INFO	 
						 WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
						AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
						AND LANG_CD = P_LANG_CD	 
						AND CLS_YMD <= P_APL_YMD	 
						/*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	 */
						AND DL_EXPD_TMP_IV_QTY = 0	 
						AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
    SET CURR_LOC_NUM = 27;
					END IF;
				END IF;	 
			
    SET CURR_LOC_NUM = 28;
				 
				IF V_N_PRNT_PBCN_NO IS NOT NULL THEN
    SET CURR_LOC_NUM = 29;
					SELECT COUNT(*)	 
					INTO V_CNT	 
					FROM TB_PDI_IV_INFO	 
					WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
					AND LANG_CD = P_LANG_CD	 
					AND CLS_YMD = P_APL_YMD	 
					AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
					AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
			
			
    SET CURR_LOC_NUM = 30;
					IF V_CNT = 0 THEN	 
    SET CURR_LOC_NUM = 31;
						INSERT INTO TB_PDI_IV_INFO	 
								(CLS_YMD,	 
						 		 QLTY_VEHL_CD,	 
						 		 DL_EXPD_MDL_MDY_CD,	 
						 		 LANG_CD,	 
						 		 N_PRNT_PBCN_NO,	 
						 		 IV_QTY,	 
						 		 CMPL_YN,	 
						 		 PPRR_EENO,	 
						 		 FRAM_DTM,	 
						 		 UPDR_EENO,	 
						 		 MDFY_DTM,	 
								 TMP_TRTM_YN,	 
								 PRDN_PLNT_CD 
						)	 
						VALUES	 
						(        P_APL_YMD,	 
								 P_QLTY_VEHL_CD,	 
								 V_DL_EXPD_MDL_MDY_CD,	 
								 P_LANG_CD,	 
								 V_N_PRNT_PBCN_NO,	 
								 0,	 
								 CASE WHEN P_APL_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d') THEN 'N' ELSE 'Y' END,	 
								 'SYSTEM',	 
								 SYSDATE(),	 
								 'SYSTEM',	 
								 SYSDATE(),	 
								 /*임시 생성하는 데이터란 정보를 표시하여 준다.	 */
								 'Y',	 
								 P_PRDN_PLNT_CD
								);	 
    SET CURR_LOC_NUM = 32;
				 		END IF;
			
			
					/*재고상세 내역에는 별도로 추가해 주지 않아도 된다.	 
					 (왜냐하면 배치 실행시 임시 재고 데이터 생성 후 보정작업이 자동으로 이루어 지기 때문이다.)	 */
				END IF;					

										
    SET CURR_LOC_NUM = 33;

			   IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL AND V_N_PRNT_PBCN_NO IS NOT NULL THEN
    SET CURR_LOC_NUM = 34;
					SELECT MAX(DTL_SN)	 
					INTO V_DTL_SN	 
					FROM TB_PDI_WHOT_INFO	 
					WHERE WHOT_YMD = P_APL_YMD	 
    	        	AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		        AND LANG_CD = P_LANG_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
    		        AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
					AND DL_EXPD_WHOT_ST_CD = '01'	 
					AND DEL_YN = 'N'	 
					AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;	 

    SET CURR_LOC_NUM = 35;

					IF V_DTL_SN IS NOT NULL THEN
    SET CURR_LOC_NUM = 36;
					   /*출고항목 업데이트 작업 수행	 */
    			       UPDATE TB_PDI_WHOT_INFO	 
    		           SET CRGR_EENO = BTCH_USER_EENO,	 
    			           DL_EXPD_WHOT_QTY = DL_EXPD_WHOT_QTY + V_TRWI_DIFF,	 
    			           DEL_YN = 'N',	 
    			           UPDR_EENO = BTCH_USER_EENO,	 
    			           MDFY_DTM = SYSDATE(),	 
						   MDL_MDY_CD = P_MDL_MDY_CD	 
    			       WHERE WHOT_YMD = P_APL_YMD	 
    	        	   AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					   AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		       	   AND LANG_CD = P_LANG_CD	 
					   AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
    		           AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
    		           AND DTL_SN = V_DTL_SN	 
    		           AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;

    SET CURR_LOC_NUM = 37;

					ELSE
    SET CURR_LOC_NUM = 38;
					   INSERT INTO TB_PDI_WHOT_INFO	 
       			  	   (WHOT_YMD,	 
    			   	    QLTY_VEHL_CD,	 
       			        DL_EXPD_MDL_MDY_CD,	 
       			        LANG_CD,	 
       			        N_PRNT_PBCN_NO,	 
       			        DTL_SN,	 
    			        DL_EXPD_WHOT_ST_CD,	 
    			        CRGR_EENO,	 
    			        DL_EXPD_WHOT_QTY,	 
    			        DEL_YN,	 
    			        PPRR_EENO,	 
       			        FRAM_DTM,	 
       			        UPDR_EENO,	 
       			        MDFY_DTM,	 
						MDL_MDY_CD,	 
						PRDN_PLNT_CD	 
       			       )	 
       			       SELECT P_APL_YMD,	 
    			  		      P_QLTY_VEHL_CD,	 
       			              V_DL_EXPD_MDL_MDY_CD,	 
       					      P_LANG_CD,	 
       					      V_N_PRNT_PBCN_NO,	 
       					      IFNULL(MAX(DTL_SN), 0) + 1,	 
       		                  '01',	 
    					      BTCH_USER_EENO,	 
    					      V_TRWI_DIFF,	 
    					      'N',	 
    					      BTCH_USER_EENO,	 
    					      SYSDATE(),	 
    					      BTCH_USER_EENO,	 
    					      SYSDATE(),	 
							  P_MDL_MDY_CD,	 
							  P_PRDN_PLNT_CD	 
       			       FROM TB_PDI_WHOT_INFO	 
    			       WHERE WHOT_YMD = P_APL_YMD	 
       			       AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
       			       AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
       			       AND LANG_CD = P_LANG_CD	 
       			       AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
       			       AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;	
    SET CURR_LOC_NUM = 39; 
					END IF;	 
	 

    SET CURR_LOC_NUM = 40;

				    CALL SP_PDI_IV_INFO_UPDATE(P_QLTY_VEHL_CD,	 
										  P_MDL_MDY_CD,	 
										  P_LANG_CD,	 
										  V_DL_EXPD_MDL_MDY_CD,	 
										  V_N_PRNT_PBCN_NO,	 
										  P_APL_YMD,	 
										  V_TRWI_DIFF,	 
										  'Y',	 
										  'Y',	 	 
										  P_PRDN_PLNT_CD,  
										  P_EXPD_CO_CD
										  );	

    SET CURR_LOC_NUM = 41;

			   END IF;
			END IF;

	/*END;
	DELIMITER;
	다음처리*/
	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 42;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_PDI_IV_INFO2 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_PDI_IV_INFO2`(IN P_QLTY_VEHL_CD VARCHAR(4),
                                        IN P_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_APL_YMD VARCHAR(8),
                                        IN P_TRWI_DIFF INT,
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_PDI_IV_INFO2
 * Procedure 설명 : 원래의 출고수량보다 투입수량이 적어진 경우 호출	
 *                 출고항목 업데이트 작업 수행
 *                 재고항목 업데이트 작업 수행
 *                 출고처리해야할 수량이 0 이 되면 작업을 종료한다.
 * 입력 파라미터    :  P_QLTY_VEHL_CD            품질차종코드
 *                 P_MDL_MDY_CD              모델년식코드
 *                 P_LANG_CD                 언어코드
 *                 P_APL_YMD                 적용년월일
 *                 P_TRWI_DIFF               투입차이
 *                 P_PRDN_PLNT_CD            생산공장코드
 *                 P_EXPD_CO_CD              회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_DL_EXPD_MDL_MDY_CD	VARCHAR(4);
	DECLARE V_N_PRNT_PBCN_NO		VARCHAR(100);
	DECLARE BTCH_USER_EENO		    VARCHAR(20);
	DECLARE V_BATCH_USER_EENO       VARCHAR(20);
	DECLARE V_TRWI_DIFF				INT;
	DECLARE V_WHOT_DIFF				INT;
	DECLARE V_IV_DIFF				INT;
	DECLARE V_DTL_SN				INT;
	
	DECLARE V_CLS_YMD_1 VARCHAR(8);
	DECLARE V_QLTY_VEHL_CD_1 VARCHAR(4);
	DECLARE V_DL_EXPD_MDL_MDY_CD_1 VARCHAR(4);
	DECLARE V_LANG_CD_1 VARCHAR(3);
	DECLARE V_N_PRNT_PBCN_NO_1 VARCHAR(100);
	DECLARE V_DTL_SN_1 INT;
	DECLARE V_IV_QTY_1 INT;
	DECLARE V_EXPD_WHOT_QTY_1 INT;
	DECLARE V_PRDN_PLNT_CD_1 VARCHAR(3);

	DECLARE V_DL_EXPD_REGN_CD		VARCHAR(4);
	DECLARE V_CNT	INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/* BEGIN */
	DECLARE endOfRow1 BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PDI_IV_INFO CURSOR FOR
							   SELECT A.CLS_YMD,	 
							   		  A.QLTY_VEHL_CD,	 
									  A.DL_EXPD_MDL_MDY_CD,	 
									  A.LANG_CD,	 
									  A.N_PRNT_PBCN_NO,	 
									  B.DTL_SN,	 
									  A.IV_QTY,	 
									  B.DL_EXPD_WHOT_QTY AS EXPD_WHOT_QTY,	 
									  A.PRDN_PLNT_CD	 
							   FROM (SELECT B.CLS_YMD,	 
									 	    B.QLTY_VEHL_CD,	 
										    B.DL_EXPD_MDL_MDY_CD,	 
											B.LANG_CD,	 
											B.N_PRNT_PBCN_NO,	 
											B.IV_QTY,	 
											A.MDL_MDY_CD,	 
											B.PRDN_PLNT_CD	 
									 FROM (SELECT A.QLTY_VEHL_CD,	 
						   		                  B.DL_EXPD_MDL_MDY_CD,	 
								                  A.LANG_CD,	 
												  A.MDL_MDY_CD	 
                                           FROM TB_LANG_MGMT A,	 
								                TB_DL_EXPD_MDY_MGMT B	 
                                           WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
                                           AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
										   AND A.DL_EXPD_REGN_CD = B.DL_EXPD_REGN_CD	 
						                   AND A.QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
						                   AND A.MDL_MDY_CD = P_MDL_MDY_CD	 
						                   AND A.LANG_CD = P_LANG_CD	 
										  ) A,	 
										  TB_PDI_IV_INFO B	 
									 WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
					                 AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
					                 AND A.LANG_CD = B.LANG_CD	 
								     AND B.CLS_YMD = P_APL_YMD	 
								     AND B.PRDN_PLNT_CD = 
											CASE WHEN A.QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN A.QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN A.QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END
									) A,	 
								    TB_PDI_WHOT_INFO B	 
							    WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
								AND A.MDL_MDY_CD = B.MDL_MDY_CD	 
				      			AND A.LANG_CD = B.LANG_CD	 
								AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
				      			AND A.N_PRNT_PBCN_NO = B.N_PRNT_PBCN_NO	 
								AND A.CLS_YMD = B.WHOT_YMD	 
								AND B.DEL_YN = 'N'	 
								/*출고로 빠진 데이터만을 가져오도록 한다.	 */
								AND B.DL_EXPD_WHOT_ST_CD = '01'	 
								/*값은 가져오지 않는다.	  */
								AND B.DL_EXPD_WHOT_QTY > 0	 
								AND A.PRDN_PLNT_CD = 
											CASE WHEN B.QLTY_VEHL_CD = 'AM' THEN B.PRDN_PLNT_CD
											     WHEN B.QLTY_VEHL_CD = 'PS' THEN B.PRDN_PLNT_CD
											     WHEN B.QLTY_VEHL_CD = 'SK3' THEN B.PRDN_PLNT_CD
												 ELSE 'N' END
								/*[변경] 2010.02.03.김동근 발간번호 정렬방식 변경	 
								  최근연식의 재고부터 더해주도록 한다.	  */
								ORDER BY A.DL_EXPD_MDL_MDY_CD DESC, FU_GET_SORT_PBCN(A.N_PRNT_PBCN_NO) DESC;		 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow1 =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_PDI_IV_INFO2',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_QLTY_VEHL_CD:',IFNULL(P_QLTY_VEHL_CD,'')
							,',P_MDL_MDY_CD:',IFNULL(P_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_APL_YMD:',IFNULL(P_APL_YMD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_DL_EXPD_MDL_MDY_CD:',IFNULL(V_DL_EXPD_MDL_MDY_CD,'')
							,',V_N_PRNT_PBCN_NO:',IFNULL(V_N_PRNT_PBCN_NO,'')
							,',BTCH_USER_EENO:',IFNULL(BTCH_USER_EENO,'')
							,',V_CLS_YMD_1:',IFNULL(V_CLS_YMD_1,'')
							,',V_QLTY_VEHL_CD_1:',IFNULL(V_QLTY_VEHL_CD_1,'')
							,',V_DL_EXPD_MDL_MDY_CD_1:',IFNULL(V_DL_EXPD_MDL_MDY_CD_1,'')
							,',V_LANG_CD_1:',IFNULL(V_LANG_CD_1,'')
							,',V_N_PRNT_PBCN_NO_1:',IFNULL(V_N_PRNT_PBCN_NO_1,'')
							,',V_PRDN_PLNT_CD_1:',IFNULL(V_PRDN_PLNT_CD_1,'')
							,',V_DL_EXPD_REGN_CD:',IFNULL(V_DL_EXPD_REGN_CD,'')
							,',P_TRWI_DIFF:',IFNULL(CONCAT(P_TRWI_DIFF),'')
							,',V_TRWI_DIFF:',IFNULL(CONCAT(V_TRWI_DIFF),'')
							,',V_WHOT_DIFF:',IFNULL(CONCAT(V_WHOT_DIFF),'')
							,',V_IV_DIFF:',IFNULL(CONCAT(V_IV_DIFF),'')
							,',V_DTL_SN:',IFNULL(CONCAT(V_DTL_SN),'')
							,',V_DTL_SN_1:',IFNULL(CONCAT(V_DTL_SN_1),'')
							,',V_IV_QTY_1:',IFNULL(CONCAT(V_IV_QTY_1),'')
							,',V_EXPD_WHOT_QTY_1:',IFNULL(CONCAT(V_EXPD_WHOT_QTY_1),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;                          

    SET CURR_LOC_NUM = 1;
    SET V_BATCH_USER_EENO = 'BATCH';
    SET BTCH_USER_EENO = V_BATCH_USER_EENO;

	SET V_TRWI_DIFF = P_TRWI_DIFF;

	OPEN PDI_IV_INFO; /* cursor 열기 */
	JOBLOOP1 : LOOP  /*루프명 : LOOP 시작*/
	FETCH PDI_IV_INFO INTO V_CLS_YMD_1,V_QLTY_VEHL_CD_1,V_DL_EXPD_MDL_MDY_CD_1,V_LANG_CD_1,V_N_PRNT_PBCN_NO_1,V_DTL_SN_1,V_IV_QTY_1,V_EXPD_WHOT_QTY_1,V_PRDN_PLNT_CD_1;
	IF endOfRow1 THEN
	 LEAVE JOBLOOP1 ;
	END IF;

				IF V_TRWI_DIFF > 0 THEN
				   IF V_EXPD_WHOT_QTY_1 >= V_TRWI_DIFF THEN
				   	  SET V_WHOT_DIFF = V_TRWI_DIFF * (-1); /*출고로 추가 빼주어야 하는 수량	 */
					  SET V_IV_DIFF   = V_TRWI_DIFF * (-1); /*재고에서 추가 빼주어야 하는 수량	 */
					  SET V_TRWI_DIFF = 0;
				   ELSE
					  SET V_WHOT_DIFF = V_EXPD_WHOT_QTY_1 * (-1); /*출고로 추가 빼주어야 하는 수량	 */
					  SET V_IV_DIFF   = V_EXPD_WHOT_QTY_1 * (-1); /*재고에서 추가 빼주어야 하는 수량	*/ 
					  SET V_TRWI_DIFF = V_TRWI_DIFF - V_EXPD_WHOT_QTY_1;
				   END IF;

				   /*출고항목 업데이트 작업 수행	 */
    			   UPDATE TB_PDI_WHOT_INFO	 
    		       SET CRGR_EENO = BTCH_USER_EENO,	 
    			       DL_EXPD_WHOT_QTY = DL_EXPD_WHOT_QTY + V_WHOT_DIFF,	 
    			       DEL_YN = 'N',	 
    			       UPDR_EENO = BTCH_USER_EENO,	 
    			       MDFY_DTM = SYSDATE()	 
    			   WHERE WHOT_YMD = P_APL_YMD	 
    	           AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
				   AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		       AND LANG_CD = P_LANG_CD	 
				   AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD_1	 
    		       AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO_1	 
    		       AND DTL_SN = V_DTL_SN_1	 
    		       AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN V_PRDN_PLNT_CD_1
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN V_PRDN_PLNT_CD_1
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN V_PRDN_PLNT_CD_1
												 ELSE 'N' END;
				   /*재고항목 업데이트 작업 수행	 */
				   CALL SP_PDI_IV_INFO_UPDATE(P_QLTY_VEHL_CD,	 
				   						 P_MDL_MDY_CD,	 
										 P_LANG_CD,	 
										 V_DL_EXPD_MDL_MDY_CD_1,	 
										 V_N_PRNT_PBCN_NO_1,	 
										 P_APL_YMD,	 
										 V_IV_DIFF,	 
										 'Y',	 
										 'Y',	 
										 P_PRDN_PLNT_CD, 
										 P_EXPD_CO_CD 
										 );	
	 
				/*ELSE
					출고처리해야할 수량이 0 이 되면 작업을 종료한다.	 
					RETURN;*/
				END IF;	 

	END LOOP JOBLOOP1 ;
	CLOSE PDI_IV_INFO;
	 

    SET CURR_LOC_NUM = 2;

			/*재고 항목을 모두 업데이트 하였는데도 출고에서 더 빼주어야할 데이터가 존재한다면....	 */
			IF V_TRWI_DIFF > 0 THEN
			   SET V_TRWI_DIFF = V_TRWI_DIFF * (-1);
			   /*CALL SP_GET_PDI_N_PRNT_PBCN_NO(P_QLTY_VEHL_CD,	 
                                   	     P_MDL_MDY_CD,	 
                                   	     P_LANG_CD,	 
                                   	     P_APL_YMD,	 
								   	     V_DL_EXPD_MDL_MDY_CD,	 
		 								 V_N_PRNT_PBCN_NO,	 
		 								 P_PRDN_PLNT_CD, 
		 								 P_EXPD_CO_CD
		 								 );	 */

			
				SET V_DL_EXPD_MDL_MDY_CD = NULL;	 
				SET V_N_PRNT_PBCN_NO     = NULL;	 
				 
				SELECT MAX(DL_EXPD_REGN_CD)	 
				INTO V_DL_EXPD_REGN_CD	 
				FROM TB_LANG_MGMT	 
				WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
				AND MDL_MDY_CD = P_MDL_MDY_CD	 
				AND LANG_CD = P_LANG_CD;
			
			
				/*TB_PDI_IV_INFO_DTL  테이블이 아니라 TB_PDI_IV_INFO 테이블에서 조회하면 된다.	 
				  왜냐하면 이곳에서는 즉시 재고 재계산 작업이 즉시 이루어지기 때문이다.	
				  현재는 무조건 가장 최근(큰) 연식을 가져오도록 처리함	 
				  (필요에 따라 현재의 차종연식과 같은 연식이 있으면 그것을 가져오도록 변경할 여지도 있을듯함)	 */
				SELECT MAX(A.DL_EXPD_MDL_MDY_CD)	 
				INTO V_DL_EXPD_MDL_MDY_CD	 
				FROM TB_PDI_IV_INFO A,	 
					 TB_DL_EXPD_MDY_MGMT B	 
				WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
				AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
				AND A.CLS_YMD <= P_APL_YMD	 
				AND B.QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
				AND B.MDL_MDY_CD = P_MDL_MDY_CD	 
				AND B.DL_EXPD_REGN_CD = V_DL_EXPD_REGN_CD	 
				AND A.LANG_CD = P_LANG_CD	 
				AND A.PRDN_PLNT_CD = P_PRDN_PLNT_CD; 
			
				IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL THEN
					SELECT MAX(N_PRNT_PBCN_NO)	 
					INTO V_N_PRNT_PBCN_NO	 
					FROM TB_PDI_IV_INFO	 
					WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
					AND LANG_CD = P_LANG_CD	 
					AND CLS_YMD <= P_APL_YMD	 
					AND PRDN_PLNT_CD = P_PRDN_PLNT_CD; 
			
				/*PDI에 한번도 입고되지 않은 항목에 대해서는 세화재고에 데이터가 존재하는 내역을 이용하도록 한다.	*/ 
				ELSE
					/*현재는 무조건 가장 최근(큰) 연식을 가져오도록 처리함	 
					  (필요에 따라 현재의 차종연식과 같은 연식이 있으면 그것을 가져오도록 변경할 여지도 있을듯함)	 */
					SELECT MAX(A.DL_EXPD_MDL_MDY_CD)	 
					INTO V_DL_EXPD_MDL_MDY_CD	 
					FROM TB_SEWON_IV_INFO A,	 
					    TB_DL_EXPD_MDY_MGMT B	 
					WHERE A.QLTY_VEHL_CD = B.QLTY_VEHL_CD	 
					AND A.DL_EXPD_MDL_MDY_CD = B.DL_EXPD_MDL_MDY_CD	 
					AND A.CLS_YMD <= P_APL_YMD	 
					/*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	 */
					AND A.DL_EXPD_TMP_IV_QTY = 0	 
					AND B.QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND B.MDL_MDY_CD = P_MDL_MDY_CD	 
					AND B.DL_EXPD_REGN_CD = V_DL_EXPD_REGN_CD	 
					AND A.LANG_CD = P_LANG_CD	 
					AND A.PRDN_PLNT_CD= P_PRDN_PLNT_CD;
			
					IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL THEN	 
						SELECT MAX(N_PRNT_PBCN_NO)	 
						INTO V_N_PRNT_PBCN_NO	 
						FROM TB_SEWON_IV_INFO	 
						 WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
						AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
						AND LANG_CD = P_LANG_CD	 
						AND CLS_YMD <= P_APL_YMD	 
						/*인쇄중인 항목은 제외하고.... 납품되었던 항목만을 조회한다.	 */
						AND DL_EXPD_TMP_IV_QTY = 0	 
						AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
					END IF;
				END IF;	 
			
				 
				IF V_N_PRNT_PBCN_NO IS NOT NULL THEN
					SELECT COUNT(*)	 
					INTO V_CNT	 
					FROM TB_PDI_IV_INFO	 
					WHERE QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
					AND LANG_CD = P_LANG_CD	 
					AND CLS_YMD = P_APL_YMD	 
					AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
					AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
			
			
					IF V_CNT = 0 THEN	 
						INSERT INTO TB_PDI_IV_INFO	 
								(CLS_YMD,	 
						 		 QLTY_VEHL_CD,	 
						 		 DL_EXPD_MDL_MDY_CD,	 
						 		 LANG_CD,	 
						 		 N_PRNT_PBCN_NO,	 
						 		 IV_QTY,	 
						 		 CMPL_YN,	 
						 		 PPRR_EENO,	 
						 		 FRAM_DTM,	 
						 		 UPDR_EENO,	 
						 		 MDFY_DTM,	 
								 TMP_TRTM_YN,	 
								 PRDN_PLNT_CD 
						)	 
						VALUES	 
						(        P_APL_YMD,	 
								 P_QLTY_VEHL_CD,	 
								 V_DL_EXPD_MDL_MDY_CD,	 
								 P_LANG_CD,	 
								 V_N_PRNT_PBCN_NO,	 
								 0,	 
								 CASE WHEN P_APL_YMD = DATE_FORMAT(SYSDATE(), '%Y%m%d') THEN 'N' ELSE 'Y' END,	 
								 'SYSTEM',	 
								 SYSDATE(),	 
								 'SYSTEM',	 
								 SYSDATE(),	 
								 /*임시 생성하는 데이터란 정보를 표시하여 준다.	 */
								 'Y',	 
								 P_PRDN_PLNT_CD
								);	 
				 		END IF;
			
					/*재고상세 내역에는 별도로 추가해 주지 않아도 된다.	 
					 (왜냐하면 배치 실행시 임시 재고 데이터 생성 후 보정작업이 자동으로 이루어 지기 때문이다.)	 */
				END IF;



    SET CURR_LOC_NUM = 3;

			   IF V_DL_EXPD_MDL_MDY_CD IS NOT NULL AND V_N_PRNT_PBCN_NO IS NOT NULL THEN
					SELECT MAX(DTL_SN)	 
					INTO V_DTL_SN	 
					FROM TB_PDI_WHOT_INFO	 
					WHERE WHOT_YMD = P_APL_YMD	 
    	        	AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		        AND LANG_CD = P_LANG_CD	 
					AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
    		        AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
					AND DL_EXPD_WHOT_ST_CD = '01'	 
					AND DEL_YN = 'N'	 
					AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;
	 

    SET CURR_LOC_NUM = 4;

					IF V_DTL_SN IS NOT NULL THEN
					   /*출고항목 업데이트 작업 수행	 */
    			       UPDATE TB_PDI_WHOT_INFO	 
    		           SET CRGR_EENO = BTCH_USER_EENO,	 
    			           DL_EXPD_WHOT_QTY = DL_EXPD_WHOT_QTY + V_TRWI_DIFF,	 
    			           DEL_YN = 'N',	 
    			           UPDR_EENO = BTCH_USER_EENO,	 
    			           MDFY_DTM = SYSDATE()	 
    			       WHERE WHOT_YMD = P_APL_YMD	 
    	        	   AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
					   AND MDL_MDY_CD = P_MDL_MDY_CD	 
    		       	   AND LANG_CD = P_LANG_CD	 
					   AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
    		           AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
    		           AND DTL_SN = V_DTL_SN	 
    		           AND PRDN_PLNT_CD = 
											CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
											     WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
												 ELSE 'N' END;

    SET CURR_LOC_NUM = 5;

					ELSE
					   INSERT INTO TB_PDI_WHOT_INFO	 
       			  	   (WHOT_YMD,	 
    			   	    QLTY_VEHL_CD,	 
       			        DL_EXPD_MDL_MDY_CD,	 
       			        LANG_CD,	 
       			        N_PRNT_PBCN_NO,	 
       			        DTL_SN,	 
    			        DL_EXPD_WHOT_ST_CD,	 
    			        CRGR_EENO,	 
    			        DL_EXPD_WHOT_QTY,	 
    			        DEL_YN,	 
    			        PPRR_EENO,	 
       			        FRAM_DTM,	 
       			        UPDR_EENO,	 
       			        MDFY_DTM,	 
						MDL_MDY_CD,	 
						PRDN_PLNT_CD
       			       )	 
       			       SELECT P_APL_YMD,	 
    			  		      P_QLTY_VEHL_CD,	 
       			              V_DL_EXPD_MDL_MDY_CD,	 
       					      P_LANG_CD,	 
       					      V_N_PRNT_PBCN_NO,	 
       					      IFNULL(MAX(DTL_SN), 0) + 1,	 
       		                  '01',	 
    					      BTCH_USER_EENO,	 
    					      V_TRWI_DIFF,	 
    					      'N',	 
    					      BTCH_USER_EENO,	 
    					      SYSDATE(),	 
    					      BTCH_USER_EENO,	 
    					      SYSDATE(),	 
							  P_MDL_MDY_CD,	 
							  CASE WHEN P_QLTY_VEHL_CD = 'AM' THEN P_PRDN_PLNT_CD
							       WHEN P_QLTY_VEHL_CD = 'PS' THEN P_PRDN_PLNT_CD
							       WHEN P_QLTY_VEHL_CD = 'SK3' THEN P_PRDN_PLNT_CD
							       ELSE 'N' END
       			       FROM TB_PDI_WHOT_INFO	 
    			       WHERE WHOT_YMD = P_APL_YMD	 
       			       AND QLTY_VEHL_CD = P_QLTY_VEHL_CD	 
       			       AND DL_EXPD_MDL_MDY_CD = V_DL_EXPD_MDL_MDY_CD	 
       			       AND LANG_CD = P_LANG_CD	 
       			       AND N_PRNT_PBCN_NO = V_N_PRNT_PBCN_NO	 
       			       AND PRDN_PLNT_CD = P_PRDN_PLNT_CD;
					END IF;	 
	 

    SET CURR_LOC_NUM = 6;

				    CALL SP_PDI_IV_INFO_UPDATE(P_QLTY_VEHL_CD,	 
										  P_MDL_MDY_CD,	 
										  P_LANG_CD,	 
										  V_DL_EXPD_MDL_MDY_CD,	 
										  V_N_PRNT_PBCN_NO,	 
										  P_APL_YMD,	 
										  V_TRWI_DIFF,	 
										  'Y',	 
										  'Y',	 
										  P_PRDN_PLNT_CD, 
										  P_EXPD_CO_CD 
										  ); 

    SET CURR_LOC_NUM = 7;

			   END IF;
			END IF;	 

	/*END;
	DELIMITER;
	다음처리*/
	    

	COMMIT;
	    

    SET CURR_LOC_NUM = 8;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_PROD_MST_PROG_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_PROD_MST_PROG_INFO`(IN P_PRDN_MST_VEHL_CD VARCHAR(4),
                                        IN P_BN_SN VARCHAR(6),
                                        IN P_EXPD_CO_CD VARCHAR(4),
                                        IN P_APL_YMD VARCHAR(8),
                                        IN P_VIN VARCHAR(17),
                                        IN P_PLNT_CD VARCHAR(3))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_PROD_MST_PROG_INFO
 * Procedure 설명 : 생산마스터 진행정보 수정
 * 입력 파라미터    :  P_PRDN_MST_VEHL_CD      생산마스터차종코드
 *                 P_BN_SN                 BODY-NO일련번호
 *                 P_EXPD_CO_CD            회사코드
 *                 P_APL_YMD               적용년월일
 *                 P_VIN                   차대번호
 *                 P_PLNT_CD               공장코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-06     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_PAC_SCN_CD  VARCHAR(4); 
	DECLARE V_PDI_CD	   VARCHAR(4);
	DECLARE V_POW_LOC_CD  VARCHAR(2);	 
	DECLARE V_APL_FNH_YMD VARCHAR(8);	 
	DECLARE V_DTL_SN	   INT;
	
	DECLARE V_PRDN_MST_VEHL_CD  VARCHAR(4);
	DECLARE V_BN_SN  VARCHAR(6); 
	DECLARE V_DL_EXPD_CO_CD  VARCHAR(4); 
	DECLARE V_APL_YMD  VARCHAR(8); 
	DECLARE V_USF_CD  VARCHAR(2); 
	DECLARE V_MO_PACK_CD  VARCHAR(4); 
	DECLARE V_DEST_NAT_CD  VARCHAR(5);
	DECLARE V_POW_LOC_CD2  VARCHAR(2);
	DECLARE V_TH1_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH2_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH3_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH4_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH5_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH6_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH7_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH8_POW_STRT_YMDHM  VARCHAR(12); 
	DECLARE V_TH9_POW_STRT_YMDHM  VARCHAR(12);
	DECLARE V_T10PS1_YMDHM  VARCHAR(12);
	DECLARE V_T11PS1_YMDHM  VARCHAR(12);
	DECLARE V_T12PS1_YMDHM  VARCHAR(12);
	DECLARE V_T13PS1_YMDHM  VARCHAR(12);
	DECLARE V_T14PS1_YMDHM  VARCHAR(12);
	DECLARE V_T15PS1_YMDHM  VARCHAR(12);
	DECLARE V_T16PS1_YMDHM  VARCHAR(12);
	DECLARE V_MDL_MDY_CD  VARCHAR(4); 
	DECLARE V_VIN  VARCHAR(17); 
	DECLARE V_TH0_POW_STRT_YMD  VARCHAR(8); 
	DECLARE V_TRWI_YMD  VARCHAR(8);  
	DECLARE V_TRWI_USED_YN  VARCHAR(1);  
	DECLARE V_PRDN_MDL_MDY_CD  VARCHAR(4);  
	DECLARE V_QLTY_VEHL_CD  VARCHAR(4);  
	DECLARE V_DL_EXPD_NAT_CD  VARCHAR(5);  
	DECLARE V_PRDN_PLNT_CD  VARCHAR(3);  

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;
	DECLARE V_INEXCNT			        INT;

	/* BEGIN */
	DECLARE endOfRow BOOLEAN DEFAULT FALSE;  /*변수 endOfRow  기본값 FALSE로 선언 */

	DECLARE PROD_MST_INFO CURSOR FOR
		                         SELECT PRDN_MST_VEHL_CD,	 
		 					  	 		BN_SN,	 
										DL_EXPD_CO_CD,	 
										APL_YMD,	 
										USF_CD,	 
										MO_PACK_CD,	 
										DEST_NAT_CD,	 
										POW_LOC_CD,	 
										TH1_POW_STRT_YMDHM,	 
	    				   				TH2_POW_STRT_YMDHM,	 
	    				   				TH3_POW_STRT_YMDHM,	 
	    				   				TH4_POW_STRT_YMDHM,	 
	    				   				TH5_POW_STRT_YMDHM,	 
	    				   				TH6_POW_STRT_YMDHM,	 
	    				   				TH7_POW_STRT_YMDHM,	 
	    				   				TH8_POW_STRT_YMDHM,	 
	    				   				TH9_POW_STRT_YMDHM,	 
	    				   				T10PS1_YMDHM,	 
	    				   				T11PS1_YMDHM,	 
	    				   				T12PS1_YMDHM,	 
	    				   				T13PS1_YMDHM,	 
	    				   				T14PS1_YMDHM,	 
	    				   				T15PS1_YMDHM,	 
	    				   				T16PS1_YMDHM,	 
										MDL_MDY_CD,	 
										VIN,	 
										TH0_POW_STRT_YMD,	 
										TRWI_YMD,	 
										TRWI_USED_YN,	 
										PRDN_MDL_MDY_CD,	 
										QLTY_VEHL_CD,	 
										DL_EXPD_NAT_CD,	 
										PRDN_PLNT_CD	 
		                         FROM TB_PROD_MST_INFO	 
								 WHERE PRDN_MST_VEHL_CD = P_PRDN_MST_VEHL_CD
                                 AND BN_SN              = P_BN_SN	 
								 AND DL_EXPD_CO_CD      = P_EXPD_CO_CD	 
								 AND APL_YMD            = P_APL_YMD	 
                                 AND VIN                = P_VIN;


	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endOfRow =TRUE; /*행의 끝까지 가서 더이상 찾을수없을때 변수 endOfRow 를 TRUE로 선언*/

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_PROD_MST_PROG_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_PRDN_MST_VEHL_CD:',IFNULL(P_PRDN_MST_VEHL_CD,'')
							,',P_BN_SN:',IFNULL(P_BN_SN,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',P_APL_YMD:',IFNULL(P_APL_YMD,'')
							,',P_VIN:',IFNULL(P_VIN,'')
							,',P_PLNT_CD:',IFNULL(P_PLNT_CD,'')
							,',V_PAC_SCN_CD:',IFNULL(V_PAC_SCN_CD,'')
							,',V_PDI_CD:',IFNULL(V_PDI_CD,'')
							,',V_POW_LOC_CD:',IFNULL(V_POW_LOC_CD,'')
							,',V_APL_FNH_YMD:',IFNULL(V_APL_FNH_YMD,'')
							,',V_PRDN_MST_VEHL_CD:',IFNULL(V_PRDN_MST_VEHL_CD,'')
							,',V_BN_SN:',IFNULL(V_BN_SN,'')
							,',V_DL_EXPD_CO_CD:',IFNULL(V_DL_EXPD_CO_CD,'')
							,',V_APL_YMD:',IFNULL(V_APL_YMD,'')
							,',V_USF_CD:',IFNULL(V_USF_CD,'')
							,',V_MO_PACK_CD:',IFNULL(V_MO_PACK_CD,'')
							,',V_DEST_NAT_CD:',IFNULL(V_DEST_NAT_CD,'')
							,',V_POW_LOC_CD2:',IFNULL(V_POW_LOC_CD2,'')
							,',V_TH1_POW_STRT_YMDHM:',IFNULL(V_TH1_POW_STRT_YMDHM,'')
							,',V_TH2_POW_STRT_YMDHM:',IFNULL(V_TH2_POW_STRT_YMDHM,'')
							,',V_TH3_POW_STRT_YMDHM:',IFNULL(V_TH3_POW_STRT_YMDHM,'')
							,',V_TH4_POW_STRT_YMDHM:',IFNULL(V_TH4_POW_STRT_YMDHM,'')
							,',V_TH5_POW_STRT_YMDHM:',IFNULL(V_TH5_POW_STRT_YMDHM,'')
							,',V_TH6_POW_STRT_YMDHM:',IFNULL(V_TH6_POW_STRT_YMDHM,'')
							,',V_TH7_POW_STRT_YMDHM:',IFNULL(V_TH7_POW_STRT_YMDHM,'')
							,',V_TH8_POW_STRT_YMDHM:',IFNULL(V_TH8_POW_STRT_YMDHM,'')
							,',V_TH9_POW_STRT_YMDHM:',IFNULL(V_TH9_POW_STRT_YMDHM,'')
							,',V_T10PS1_YMDHM:',IFNULL(V_T10PS1_YMDHM,'')
							,',V_T11PS1_YMDHM:',IFNULL(V_T11PS1_YMDHM,'')
							,',V_T12PS1_YMDHM:',IFNULL(V_T12PS1_YMDHM,'')
							,',V_T13PS1_YMDHM:',IFNULL(V_T13PS1_YMDHM,'')
							,',V_T14PS1_YMDHM:',IFNULL(V_T14PS1_YMDHM,'')
							,',V_T15PS1_YMDHM:',IFNULL(V_T15PS1_YMDHM,'')
							,',V_T16PS1_YMDHM:',IFNULL(V_T16PS1_YMDHM,'')
							,',V_MDL_MDY_CD:',IFNULL(V_MDL_MDY_CD,'')
							,',V_VIN:',IFNULL(V_VIN,'')
							,',V_TH0_POW_STRT_YMD:',IFNULL(V_TH0_POW_STRT_YMD,'')
							,',V_TRWI_YMD:',IFNULL(V_TRWI_YMD,'')
							,',V_TRWI_USED_YN:',IFNULL(V_TRWI_USED_YN,'')
							,',V_PRDN_MDL_MDY_CD:',IFNULL(V_PRDN_MDL_MDY_CD,'')
							,',V_QLTY_VEHL_CD:',IFNULL(V_QLTY_VEHL_CD,'')
							,',V_DL_EXPD_NAT_CD:',IFNULL(V_DL_EXPD_NAT_CD,'')
							,',V_PRDN_PLNT_CD:',IFNULL(V_PRDN_PLNT_CD,'')
							,',V_DTL_SN:',IFNULL(CONCAT(V_DTL_SN),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;
	 

    SET CURR_LOC_NUM = 1;

	OPEN PROD_MST_INFO; /* cursor 열기 */
	JOBLOOP : LOOP  /*루프명 : LOOP 시작*/
	FETCH PROD_MST_INFO INTO V_PRDN_MST_VEHL_CD,V_BN_SN,V_DL_EXPD_CO_CD,V_APL_YMD,V_USF_CD,V_MO_PACK_CD,V_DEST_NAT_CD,V_POW_LOC_CD2,V_TH1_POW_STRT_YMDHM,V_TH2_POW_STRT_YMDHM,V_TH3_POW_STRT_YMDHM,V_TH4_POW_STRT_YMDHM,V_TH5_POW_STRT_YMDHM,V_TH6_POW_STRT_YMDHM,V_TH7_POW_STRT_YMDHM,V_TH8_POW_STRT_YMDHM,V_TH9_POW_STRT_YMDHM,V_T10PS1_YMDHM,V_T11PS1_YMDHM,V_T12PS1_YMDHM,V_T13PS1_YMDHM,V_T14PS1_YMDHM,V_T15PS1_YMDHM,V_T16PS1_YMDHM,V_MDL_MDY_CD,V_VIN,V_TH0_POW_STRT_YMD,V_TRWI_YMD,V_TRWI_USED_YN,V_PRDN_MDL_MDY_CD,V_QLTY_VEHL_CD,V_DL_EXPD_NAT_CD,V_PRDN_PLNT_CD;
	
    SET CURR_LOC_NUM = 2;
	IF endOfRow THEN
	 LEAVE JOBLOOP ;
	END IF;

    SET CURR_LOC_NUM = 3;
				SELECT MAX(DL_EXPD_PAC_SCN_CD),	 
				       MAX(DL_EXPD_PDI_CD)	 
				INTO V_PAC_SCN_CD,	 
				     V_PDI_CD	 
				FROM TB_VEHL_MGMT	 
				WHERE QLTY_VEHL_CD = V_QLTY_VEHL_CD	 
				AND MDL_MDY_CD     = V_MDL_MDY_CD;	
	 
    SET CURR_LOC_NUM = 4;
				/*승용인 경우의 처리	 
				 (승용의 경우에는 투입된 이후의 라인모니터링 정보가 필요없으므로 별도로 처리하지 않고,	 
				  현재 진행중인 항목만 추가해 주도록 한다.)	*/ 
				IF V_PAC_SCN_CD = '01' THEN	 
				   CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_PAC_SCN_CD = 01 THEN');

				   
	 
    SET CURR_LOC_NUM = 5;
				    /*이미 투입된 물량인지의 여부를 체크한다.	 
					 (투입된 항목 이거나 투입된 물량이 라인백 된 경우는 TRWI_USED_YN값이 NULL이 아니어서 제외된다.)	 */
					IF V_TRWI_USED_YN IS NOT NULL THEN	 
    SET CURR_LOC_NUM = 6;
					   CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_TRWI_USED_YN IS NOT NULL THEN');	 
	 
    SET CURR_LOC_NUM = 7;
					   SET V_DTL_SN = GET_PROD_MST_PROG_MAX_DTL_SN(V_PRDN_MST_VEHL_CD,	 
								 					            V_BN_SN,	 
							     							    V_DL_EXPD_CO_CD,	 
							     							    V_TRWI_YMD,	 
							     							    V_TRWI_YMD,	 
                                                                V_VIN	 
                                                                );	 
	 
    SET CURR_LOC_NUM = 8;
				   	   IF V_TRWI_USED_YN = 'N' THEN	 
    SET CURR_LOC_NUM = 9;
				   	      CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_TRWI_USED_YN = N THEN');	 
						  	  
    SET CURR_LOC_NUM = 10;
						  UPDATE TB_PROD_MST_PROG_INFO	 
				   	   	  SET
					       	  APL_FNH_YMD = V_TRWI_YMD,	 
					   	   	  MDFY_DTM    = SYSDATE(),	 
							  DTL_SN      = V_DTL_SN,	 
							  PRDN_PLNT_CD = V_PRDN_PLNT_CD	 
				          WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
				   	   	  AND BN_SN              = V_BN_SN	 
				   	   	  AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
				   	   	  AND APL_STRT_YMD      <= V_TRWI_YMD	 
				   	   	  AND APL_FNH_YMD        > V_TRWI_YMD	 
                          AND VIN                = V_VIN;                          	 
	 
    SET CURR_LOC_NUM = 11;
				       ELSE	 
    SET CURR_LOC_NUM = 12;
				          CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : ELSE IF V_TRWI_USED_YN = N THEN');	 
	 
    SET CURR_LOC_NUM = 13;
					   	  UPDATE TB_PROD_MST_PROG_INFO	 
				   	   	  SET	 
					       	  APL_FNH_YMD = V_TRWI_YMD,	 
					   	   	  MDFY_DTM    = SYSDATE(),	 
							  DTL_SN      = V_DTL_SN,	 
							  PRDN_PLNT_CD = V_PRDN_PLNT_CD	 
				          WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
				   	   	  AND BN_SN              = V_BN_SN	 
				   	   	  AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
				   	   	  AND APL_STRT_YMD      <= V_TRWI_YMD	 
				   	   	  AND APL_FNH_YMD        = '99991231'	 
                          AND VIN                = V_VIN;
    SET CURR_LOC_NUM = 14;
				       END IF;
				    ELSE	 
    SET CURR_LOC_NUM = 15;
					   CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : ELSE IF V_TRWI_USED_YN IS NOT NULL THEN');	 
	 
    SET CURR_LOC_NUM = 16;
				   	   SELECT MAX(APL_FNH_YMD)	 
				   	   INTO V_APL_FNH_YMD	 
				   	   FROM TB_PROD_MST_PROG_INFO	 
				   	   WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
				   	   AND BN_SN = V_BN_SN	 
				   	   AND DL_EXPD_CO_CD = V_DL_EXPD_CO_CD	 
				   	   AND APL_STRT_YMD <= V_TRWI_YMD	 
				   	   AND APL_FNH_YMD   > V_TRWI_YMD	 
                       AND VIN           = V_VIN;                       	 
	 
    SET CURR_LOC_NUM = 17;
				       IF V_APL_FNH_YMD IS NULL THEN	
    SET CURR_LOC_NUM = 18; 
						  CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_APL_FNH_YMD IS NULL THEN');	 
	 
    SET CURR_LOC_NUM = 19;
					   	  /*현재 한번도 저장된 적이 없는 데이터 이면 신규 추가해 준다.	 */
						/*등록전 PK별 정보 있는지 확인*/
						SET V_INEXCNT = 0;
						SELECT COUNT(*)	 
						  INTO V_INEXCNT	 
						  FROM TB_PROD_MST_PROG_INFO
						WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD
							AND BN_SN = V_BN_SN
							AND DL_EXPD_CO_CD = V_DL_EXPD_CO_CD
							AND APL_STRT_YMD = V_TRWI_YMD
							AND APL_FNH_YMD = '99991231'
							AND VIN = V_VIN
							AND DTL_SN = 1;

						IF V_INEXCNT = 0 THEN
							  INSERT INTO TB_PROD_MST_PROG_INFO	(
									PRDN_MST_VEHL_CD,
									BN_SN,
									DL_EXPD_CO_CD,
									APL_STRT_YMD,
									APL_FNH_YMD,
									USF_CD,
									MO_PACK_CD,
									DEST_NAT_CD,
									POW_LOC_CD,
									TH1_POW_STRT_YMDHM,
									TH2_POW_STRT_YMDHM,
									TH3_POW_STRT_YMDHM,
									TH4_POW_STRT_YMDHM,
									TH5_POW_STRT_YMDHM,
									TH6_POW_STRT_YMDHM,
									TH7_POW_STRT_YMDHM,
									TH8_POW_STRT_YMDHM,
									TH9_POW_STRT_YMDHM,
									T10PS1_YMDHM,
									T11PS1_YMDHM,
									T12PS1_YMDHM,
									T13PS1_YMDHM,
									T14PS1_YMDHM,
									T15PS1_YMDHM,
									T16PS1_YMDHM,
									MDL_MDY_CD,
									VIN,
									FRAM_DTM,
									MDFY_DTM,
									TH0_POW_STRT_YMD,
									PRDN_MDL_MDY_CD,
									QLTY_VEHL_CD,
									DL_EXPD_NAT_CD,
									TRWI_USED_YN,
									DTL_SN,
									PRDN_PLNT_CD
							  )
							  VALUES(V_PRDN_MST_VEHL_CD,	 
									 V_BN_SN,	 
									 V_DL_EXPD_CO_CD,	 
									 V_TRWI_YMD,	 
									 '99991231',	 
									 V_USF_CD,	 
									 V_MO_PACK_CD,	 
									 V_DEST_NAT_CD,	 
									 V_POW_LOC_CD2,	 
									 V_TH1_POW_STRT_YMDHM,	 
									 V_TH2_POW_STRT_YMDHM,	 
									 V_TH3_POW_STRT_YMDHM,	 
									 V_TH4_POW_STRT_YMDHM,	 
									 V_TH5_POW_STRT_YMDHM,	 
									 V_TH6_POW_STRT_YMDHM,	 
									 V_TH7_POW_STRT_YMDHM,	 
									 V_TH8_POW_STRT_YMDHM,	 
									 V_TH9_POW_STRT_YMDHM,	 
									 V_T10PS1_YMDHM,	 
									 V_T11PS1_YMDHM,	 
									 V_T12PS1_YMDHM,	 
									 V_T13PS1_YMDHM,	 
									 V_T14PS1_YMDHM,	 
									 V_T15PS1_YMDHM,	 
									 V_T16PS1_YMDHM,	 
									 V_MDL_MDY_CD,	 
									 V_VIN,	 
									 SYSDATE(),	 
									 SYSDATE(),	 
									 V_TH0_POW_STRT_YMD,	 
									 V_PRDN_MDL_MDY_CD,	 
									 V_QLTY_VEHL_CD,	 
									 V_DL_EXPD_NAT_CD,	 
									 V_TRWI_USED_YN,	 
									 1,	
									 V_PRDN_PLNT_CD	 
									);	 
						END IF;
	 
    SET CURR_LOC_NUM = 20;
				   	   /*현재 진행중인 물량이 존재하는지의 여부를 확인한다.	 
				   	    (과거에 진행된 물량은 업데이트 작업을 수행해 주지 않는다.)	 */
				   	   ELSEIF V_APL_FNH_YMD = '99991231' THEN
    SET CURR_LOC_NUM = 21;	 
				   	      CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : ELSEIF V_APL_FNH_YMD = 99991231 THEN');	 
	 
    SET CURR_LOC_NUM = 22;
					      SELECT MAX(POW_LOC_CD)	 
				   	   	  INTO V_POW_LOC_CD	 
				   	   	  FROM TB_PROD_MST_PROG_INFO	 
				   	   	  WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
				   	   	  AND BN_SN              = V_BN_SN	 
				   	   	  AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
				   	   	  AND APL_STRT_YMD      <= V_TRWI_YMD	 
				   	   	  AND APL_FNH_YMD        = '99991231'	 
                          AND VIN                = V_VIN;	
                          	 
	 
    SET CURR_LOC_NUM = 23;
                          /*[참고] 당일날 I/F 데이터의 현재 진행공정이 당일날 또 바뀐다면 이곳에서	 
					   	         에러가 발생할 수 있으니 주의 요망됨	 
					   	  과거 진행중인 물량과 현재 진행중인 물량의 공정위치코드가 다른 경우에는	 
					   	  과거 진행 물량의 종료일을 변경한 뒤에 현재 진행중인 물량의 정보를 추가해 준다.	 */
					   	  IF V_POW_LOC_CD <> V_POW_LOC_CD2 THEN	
    SET CURR_LOC_NUM = 24; 
					   	     CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_POW_LOC_CD <> V_POW_LOC_CD2 THEN');	 
	 
    SET CURR_LOC_NUM = 25;
							 SET V_DTL_SN = GET_PROD_MST_PROG_MAX_DTL_SN(V_PRDN_MST_VEHL_CD,	 
								 					                  V_BN_SN,	 
							     							          V_DL_EXPD_CO_CD,	 
							     							          V_TRWI_YMD,	 
							     							          V_TRWI_YMD,	 
                                                                      V_VIN	 
                                                                      );	 

    SET CURR_LOC_NUM = 26;
					   	  	 UPDATE TB_PROD_MST_PROG_INFO	 
					  	  	 SET	 
						      	 APL_FNH_YMD = V_TRWI_YMD,	 
					      	  	 MDFY_DTM = SYSDATE(),	 
								 DTL_SN = V_DTL_SN,	 
								 PRDN_PLNT_CD = V_PRDN_PLNT_CD	 
					         WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
					      	 AND BN_SN              = V_BN_SN	 
					      	 AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
					      	 AND APL_STRT_YMD      <= V_TRWI_YMD	 
					      	 AND APL_FNH_YMD        = '99991231'	 
                             AND VIN                = V_VIN;

    SET CURR_LOC_NUM = 27;
							/*등록전 PK별 정보 있는지 확인*/
							SET V_INEXCNT = 0;
							SELECT COUNT(*)	 
							  INTO V_INEXCNT	 
							  FROM TB_PROD_MST_PROG_INFO
							WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD
								AND BN_SN = V_BN_SN
								AND DL_EXPD_CO_CD = V_DL_EXPD_CO_CD
								AND APL_STRT_YMD = V_TRWI_YMD
								AND APL_FNH_YMD = '99991231'
								AND VIN = V_VIN
								AND DTL_SN = 1;
							
							IF V_INEXCNT = 0 THEN
								 INSERT INTO TB_PROD_MST_PROG_INFO	(
									PRDN_MST_VEHL_CD,
									BN_SN,
									DL_EXPD_CO_CD,
									APL_STRT_YMD,
									APL_FNH_YMD,
									USF_CD,
									MO_PACK_CD,
									DEST_NAT_CD,
									POW_LOC_CD,
									TH1_POW_STRT_YMDHM,
									TH2_POW_STRT_YMDHM,
									TH3_POW_STRT_YMDHM,
									TH4_POW_STRT_YMDHM,
									TH5_POW_STRT_YMDHM,
									TH6_POW_STRT_YMDHM,
									TH7_POW_STRT_YMDHM,
									TH8_POW_STRT_YMDHM,
									TH9_POW_STRT_YMDHM,
									T10PS1_YMDHM,
									T11PS1_YMDHM,
									T12PS1_YMDHM,
									T13PS1_YMDHM,
									T14PS1_YMDHM,
									T15PS1_YMDHM,
									T16PS1_YMDHM,
									MDL_MDY_CD,
									VIN,
									FRAM_DTM,
									MDFY_DTM,
									TH0_POW_STRT_YMD,
									PRDN_MDL_MDY_CD,
									QLTY_VEHL_CD,
									DL_EXPD_NAT_CD,
									TRWI_USED_YN,
									DTL_SN,
									PRDN_PLNT_CD
							      )	 
								 VALUES(V_PRDN_MST_VEHL_CD,	 
										V_BN_SN,	 
										V_DL_EXPD_CO_CD,	 
										V_TRWI_YMD,	 
										'99991231',	 
										V_USF_CD,	 
										V_MO_PACK_CD,	 
										V_DEST_NAT_CD,	 
										V_POW_LOC_CD2,	 
										V_TH1_POW_STRT_YMDHM,	 
										V_TH2_POW_STRT_YMDHM,	 
										V_TH3_POW_STRT_YMDHM,	 
										V_TH4_POW_STRT_YMDHM,	 
										V_TH5_POW_STRT_YMDHM,	 
										V_TH6_POW_STRT_YMDHM,	 
										V_TH7_POW_STRT_YMDHM,	 
										V_TH8_POW_STRT_YMDHM,	 
										V_TH9_POW_STRT_YMDHM,	 
										V_T10PS1_YMDHM,	 
										V_T11PS1_YMDHM,	 
										V_T12PS1_YMDHM,	 
										V_T13PS1_YMDHM,	 
										V_T14PS1_YMDHM,	 
										V_T15PS1_YMDHM,	 
										V_T16PS1_YMDHM,	 
										V_MDL_MDY_CD,	 
										V_VIN,	 
										SYSDATE(),	 
										SYSDATE(),	 
										V_TH0_POW_STRT_YMD,	 
										V_PRDN_MDL_MDY_CD,	 
										V_QLTY_VEHL_CD,	 
										V_DL_EXPD_NAT_CD,	 
										V_TRWI_USED_YN,	 
										1, 
										V_PRDN_PLNT_CD	 
									  );
							END IF;
    SET CURR_LOC_NUM = 28;
					      END IF;
				       END IF;
				    END IF; 
	 
				/*상용의 경우의 처리	 */
				ELSEIF V_PAC_SCN_CD = '02' THEN	 
    SET CURR_LOC_NUM = 29;
				   CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : ELSEIF V_PAC_SCN_CD = 02 THEN');	 
	 
    SET CURR_LOC_NUM = 30;
                    SELECT MAX(APL_FNH_YMD)	 
				   	INTO V_APL_FNH_YMD	 
				   	FROM TB_PROD_MST_PROG_INFO	 
				   	WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
				   	AND BN_SN              = V_BN_SN	 
				   	AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
				   	AND APL_STRT_YMD      <= V_TRWI_YMD	 
				   	AND APL_FNH_YMD        > V_TRWI_YMD	 
                    AND VIN                = V_VIN;
	 
    SET CURR_LOC_NUM = 31;
				    IF V_APL_FNH_YMD IS NULL THEN	
    SET CURR_LOC_NUM = 32; 
				       CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_APL_FNH_YMD IS NULL THEN');	 
	 
    SET CURR_LOC_NUM = 33;
                      /*현재 한번도 저장된 적이 없는 데이터 이면 신규 추가해 준다.	 */
					/*등록전 PK별 정보 있는지 확인*/
					SET V_INEXCNT = 0;
					SELECT COUNT(*)	 
					  INTO V_INEXCNT	 
					FROM TB_PROD_MST_PROG_INFO
					WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD
					AND BN_SN = V_BN_SN
					AND DL_EXPD_CO_CD = V_DL_EXPD_CO_CD
					AND APL_STRT_YMD = V_TRWI_YMD
					AND APL_FNH_YMD = CASE WHEN V_POW_LOC_CD2='16' THEN DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TRWI_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') ELSE '99991231' END
					AND VIN = V_VIN
					AND DTL_SN = 1;
					
					IF V_INEXCNT = 0 THEN
					  INSERT INTO TB_PROD_MST_PROG_INFO	(
									PRDN_MST_VEHL_CD,
									BN_SN,
									DL_EXPD_CO_CD,
									APL_STRT_YMD,
									APL_FNH_YMD,
									USF_CD,
									MO_PACK_CD,
									DEST_NAT_CD,
									POW_LOC_CD,
									TH1_POW_STRT_YMDHM,
									TH2_POW_STRT_YMDHM,
									TH3_POW_STRT_YMDHM,
									TH4_POW_STRT_YMDHM,
									TH5_POW_STRT_YMDHM,
									TH6_POW_STRT_YMDHM,
									TH7_POW_STRT_YMDHM,
									TH8_POW_STRT_YMDHM,
									TH9_POW_STRT_YMDHM,
									T10PS1_YMDHM,
									T11PS1_YMDHM,
									T12PS1_YMDHM,
									T13PS1_YMDHM,
									T14PS1_YMDHM,
									T15PS1_YMDHM,
									T16PS1_YMDHM,
									MDL_MDY_CD,
									VIN,
									FRAM_DTM,
									MDFY_DTM,
									TH0_POW_STRT_YMD,
									PRDN_MDL_MDY_CD,
									QLTY_VEHL_CD,
									DL_EXPD_NAT_CD,
									TRWI_USED_YN,
									DTL_SN,
									PRDN_PLNT_CD
					   )	 
					  VALUES(V_PRDN_MST_VEHL_CD,	 
		 					 V_BN_SN,	 
							 V_DL_EXPD_CO_CD,	 
							 V_TRWI_YMD,	 
							 /*마지막 공정인 경우에는 완료일을 투입일보다 하루 뒤로 설정해 준다.	 */
							 CASE WHEN V_POW_LOC_CD2='16' THEN DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TRWI_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') ELSE '99991231' END,	 
							 V_USF_CD,	 
							 V_MO_PACK_CD,	 
							 V_DEST_NAT_CD,	 
							 V_POW_LOC_CD2,	 
							 V_TH1_POW_STRT_YMDHM,	 
	    				   	 V_TH2_POW_STRT_YMDHM,	 
	    				   	 V_TH3_POW_STRT_YMDHM,	 
	    				   	 V_TH4_POW_STRT_YMDHM,	 
	    				   	 V_TH5_POW_STRT_YMDHM,	 
	    				   	 V_TH6_POW_STRT_YMDHM,	 
	    				   	 V_TH7_POW_STRT_YMDHM,	 
	    				   	 V_TH8_POW_STRT_YMDHM,	 
	    				   	 V_TH9_POW_STRT_YMDHM,	 
	    				   	 V_T10PS1_YMDHM,	 
	    				   	 V_T11PS1_YMDHM,	 
	    				   	 V_T12PS1_YMDHM,	 
	    				   	 V_T13PS1_YMDHM,	 
	    				   	 V_T14PS1_YMDHM,	 
	    				   	 V_T15PS1_YMDHM,	 
	    				   	 V_T16PS1_YMDHM,	 
							 V_MDL_MDY_CD,	 
							 V_VIN,	 
							 SYSDATE(),	 
							 SYSDATE(),	 
							 V_TH0_POW_STRT_YMD,	 
							 V_PRDN_MDL_MDY_CD,	 
							 V_QLTY_VEHL_CD,	 
							 V_DL_EXPD_NAT_CD,	 
							 V_TRWI_USED_YN,	 
							 1,	 
                             V_PRDN_PLNT_CD	 
						   );	 
					END IF;
					  
	 
    SET CURR_LOC_NUM = 34;
				   	 /*현재 진행중인 물량이 존재하는지의 여부를 확인한다.	 
				   	  (과거에 진행된 물량은 업데이트 작업을 수행해 주지 않는다.)	 */
				   	 ELSEIF V_APL_FNH_YMD = '99991231' THEN	 
    SET CURR_LOC_NUM = 35;
				   	     CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : ELSEIF V_APL_FNH_YMD = 99991231 THEN');	 
	 
    SET CURR_LOC_NUM = 36;
					     SELECT MAX(POW_LOC_CD)	 
				   	   	 INTO V_POW_LOC_CD	 
				   	   	 FROM TB_PROD_MST_PROG_INFO	 
				   	   	 WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
				   	   	 AND BN_SN              = V_BN_SN	 
				   	   	 AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
				   	   	 AND APL_STRT_YMD      <= V_TRWI_YMD	 
				   	   	 AND APL_FNH_YMD        = '99991231'	 
                         AND VIN                = V_VIN;
                         	 
    SET CURR_LOC_NUM = 37;
	 
                         /*[참고] 당일날 I/F 데이터의 현재 진행공정이 당일날 또 바뀐다면 이곳에서	 
					   	        에러가 발생할 수 있으니 주의 요망됨	 
					   	 과거 진행중인 물량과 현재 진행중인 물량의 공정위치코드가 다른 경우에는	 
					   	 과거 진행 물량의 종료일을 변경한 뒤에 현재 진행중인 물량의 정보를 추가해 준다.	 */
					   	 IF V_POW_LOC_CD <> V_POW_LOC_CD2 THEN
    SET CURR_LOC_NUM = 38;	 
					   	     CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'S', 'SP_UPDATE_PROD_MST_PROG_INFO : IF V_POW_LOC_CD <> V_POW_LOC_CD2 THEN');	 
	 
    SET CURR_LOC_NUM = 39;
							 SET V_DTL_SN = GET_PROD_MST_PROG_MAX_DTL_SN(V_PRDN_MST_VEHL_CD,	 
								 					                  V_BN_SN,	 
							     							          V_DL_EXPD_CO_CD,	 
							     							          V_TRWI_YMD,	 
							     							          V_TRWI_YMD,	 
                                                                      V_VIN	 
                                                                      );

    SET CURR_LOC_NUM = 40;
					   	     UPDATE TB_PROD_MST_PROG_INFO	 
					  	  	 SET 
						      	 APL_FNH_YMD = V_TRWI_YMD,	 
					      	  	 MDFY_DTM    = SYSDATE(),	 
								 DTL_SN      = V_DTL_SN,	 
								 PRDN_PLNT_CD = V_PRDN_PLNT_CD	 
					         WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD	 
					      	 AND BN_SN              = V_BN_SN	 
					      	 AND DL_EXPD_CO_CD      = V_DL_EXPD_CO_CD	 
					      	 AND APL_STRT_YMD      <= V_TRWI_YMD	 
					      	 AND APL_FNH_YMD        = '99991231'	 
                             AND VIN                = V_VIN;

    SET CURR_LOC_NUM = 41;
							/*등록전 PK별 정보 있는지 확인*/
							SET V_INEXCNT = 0;
							SELECT COUNT(*)	 
							  INTO V_INEXCNT	 
							FROM TB_PROD_MST_PROG_INFO
							WHERE PRDN_MST_VEHL_CD = V_PRDN_MST_VEHL_CD
							AND BN_SN = V_BN_SN
							AND DL_EXPD_CO_CD = V_DL_EXPD_CO_CD
							AND APL_STRT_YMD = V_TRWI_YMD
							AND APL_FNH_YMD = CASE WHEN V_POW_LOC_CD2='16' THEN DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TRWI_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') ELSE '99991231' END
							AND VIN = V_VIN
							AND DTL_SN = 1;
							
							IF V_INEXCNT = 0 THEN
								 INSERT INTO TB_PROD_MST_PROG_INFO (
									PRDN_MST_VEHL_CD,
									BN_SN,
									DL_EXPD_CO_CD,
									APL_STRT_YMD,
									APL_FNH_YMD,
									USF_CD,
									MO_PACK_CD,
									DEST_NAT_CD,
									POW_LOC_CD,
									TH1_POW_STRT_YMDHM,
									TH2_POW_STRT_YMDHM,
									TH3_POW_STRT_YMDHM,
									TH4_POW_STRT_YMDHM,
									TH5_POW_STRT_YMDHM,
									TH6_POW_STRT_YMDHM,
									TH7_POW_STRT_YMDHM,
									TH8_POW_STRT_YMDHM,
									TH9_POW_STRT_YMDHM,
									T10PS1_YMDHM,
									T11PS1_YMDHM,
									T12PS1_YMDHM,
									T13PS1_YMDHM,
									T14PS1_YMDHM,
									T15PS1_YMDHM,
									T16PS1_YMDHM,
									MDL_MDY_CD,
									VIN,
									FRAM_DTM,
									MDFY_DTM,
									TH0_POW_STRT_YMD,
									PRDN_MDL_MDY_CD,
									QLTY_VEHL_CD,
									DL_EXPD_NAT_CD,
									TRWI_USED_YN,
									DTL_SN,
									PRDN_PLNT_CD
								  )		 
								 VALUES(V_PRDN_MST_VEHL_CD,	 
										V_BN_SN,	 
										V_DL_EXPD_CO_CD,	 
										V_TRWI_YMD,	 
										/*마지막 공정인 경우에는 완료일을 투입일보다 하루 뒤로 설정해 준다.	 */
										CASE WHEN V_POW_LOC_CD2='16' THEN DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TRWI_YMD, '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') ELSE '99991231' END,
										V_USF_CD,	 
										V_MO_PACK_CD,	 
										V_DEST_NAT_CD,	 
										V_POW_LOC_CD2,	 
										V_TH1_POW_STRT_YMDHM,	 
										V_TH2_POW_STRT_YMDHM,	 
										V_TH3_POW_STRT_YMDHM,	 
										V_TH4_POW_STRT_YMDHM,	 
										V_TH5_POW_STRT_YMDHM,	 
										V_TH6_POW_STRT_YMDHM,	 
										V_TH7_POW_STRT_YMDHM,	 
										V_TH8_POW_STRT_YMDHM,	 
										V_TH9_POW_STRT_YMDHM,	 
										V_T10PS1_YMDHM,	 
										V_T11PS1_YMDHM,	 
										V_T12PS1_YMDHM,	 
										V_T13PS1_YMDHM,	 
										V_T14PS1_YMDHM,	 
										V_T15PS1_YMDHM,	 
										V_T16PS1_YMDHM,	 
										V_MDL_MDY_CD,	 
										V_VIN,	 
										SYSDATE(),	 
										SYSDATE(),	 
										V_TH0_POW_STRT_YMD,	 
										V_PRDN_MDL_MDY_CD,	 
										V_QLTY_VEHL_CD,	 
										V_DL_EXPD_NAT_CD,	 
										V_TRWI_USED_YN,	 
										1,	 
										V_PRDN_PLNT_CD	 
									   );
							END IF;
    SET CURR_LOC_NUM = 42;
					      END IF;
				     END IF;
				END IF;	 
	 
			/*EXCEPTION	 
				WHEN OTHERS THEN	 
					CALL WRITE_BATCH_EXE_LOG('생산마스터배치작업_KMC', SYSDATE(), 'F', 'SP_UPDATE_PROD_MST_PROG_INFO : V_PAC_SCN_CD(' || V_PAC_SCN_CD || '), V_PDI_CD(' || V_PDI_CD || '), V_DTL_SN(' || V_DTL_SN || '), TRWI_USED_YN(' || V_TRWI_USED_YN ||'), QLTY_VEHL_CD(' || V_QLTY_VEHL_CD || '), MDL_MDY_CD(' || V_MDL_MDY_CD || '), PRDN_MST_VEHL_CD(' || V_PRDN_MST_VEHL_CD || '), BN_SN(' || V_BN_SN || '), APL_YMD(' || V_APL_YMD || '), MO_PACK_CD(' || V_MO_PACK_CD || '), TRWI_YMD(' || V_TRWI_YMD || '), PRDN_PLNT_CD(' || V_PRDN_PLNT_CD ||'), VIN(' || V_VIN ||')',P_EXPD_CO_CD);	 
					RAISE;	 */

    SET CURR_LOC_NUM = 43;
	END LOOP JOBLOOP ;
	CLOSE PROD_MST_INFO;

    SET CURR_LOC_NUM = 44;


	/*END;
	DELIMITER;
	다음처리*/

	COMMIT;
	    

    SET CURR_LOC_NUM = 45;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_UPDATE_SEWON_IV_DTL_INFO 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_UPDATE_SEWON_IV_DTL_INFO`(IN P_VEHL_CD VARCHAR(4),
                                        IN P_EXPD_MDL_MDY_CD VARCHAR(4),
                                        IN P_LANG_CD VARCHAR(3),
                                        IN P_N_PRNT_PBCN_NO VARCHAR(100),
                                        IN P_CLS_YMD VARCHAR(8),
                                        IN P_PRDN_PLNT_CD VARCHAR(3),
                                        IN P_EXPD_CO_CD VARCHAR(2))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_UPDATE_SEWON_IV_DTL_INFO
 * Procedure 설명 : 입고/출고된 항목에 대한 세원 재고상세 테이블 업데이트 작업 수행
 *                 재고 테이블 재고 수량 조회
 *                 재고 테이블에 데이터가 존재하는 경우에 아래의 작업을 수행한다.
 *                 재고상세 테이블내에 취급설명서연식으로 적용된 항목의 재고수량을 변경된 수량으로 모두 업데이트 해 준다.
 *                 단, 차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해준다.
 *                 (왜냐하면 같은 않은 항목은 재고 상세 내역 재계산시에 우선 삭제된 뒤에 다시 계산하기 때문에 의미가 없다.)
 * 입력 파라미터    :  P_VEHL_CD                   차종코드
 *                 P_EXPD_MDL_MDY_CD           취급설명서모델년식코드
 *                 P_LANG_CD                   언어코드(KO 한글/국내, EU 영어/미국,..)
 *                 P_N_PRNT_PBCN_NO            신인쇄발간번호
 *                 P_CLS_YMD                   마감년월일
 *                 P_PRDN_PLNT_CD              생산공장코드
 *                 P_EXPD_CO_CD                회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-05     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_IV_QTY      		INT;	 
	DECLARE V_EXPD_TMP_IV_QTY	INT;	 
	DECLARE V_CNT				INT;	 
	DECLARE V_CMPL_YN     		VARCHAR(1);	 
	DECLARE V_TMP_TRTM_YN 		VARCHAR(1);	 
	DECLARE V_BATCH_USER_EENO VARCHAR(20);
	
	DECLARE V_EXCNT			        INT;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_UPDATE_SEWON_IV_DTL_INFO',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_VEHL_CD:',IFNULL(P_VEHL_CD,'')
							,',P_EXPD_MDL_MDY_CD:',IFNULL(P_EXPD_MDL_MDY_CD,'')
							,',P_LANG_CD:',IFNULL(P_LANG_CD,'')
							,',P_N_PRNT_PBCN_NO:',IFNULL(P_N_PRNT_PBCN_NO,'')
							,',P_CLS_YMD:',IFNULL(P_CLS_YMD,'')
							,',P_PRDN_PLNT_CD:',IFNULL(P_PRDN_PLNT_CD,'')
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',V_CMPL_YN:',IFNULL(V_CMPL_YN,'')
							,',V_TMP_TRTM_YN:',IFNULL(V_TMP_TRTM_YN,'')
							,',V_IV_QTY:',IFNULL(CONCAT(V_IV_QTY),'')
							,',V_EXPD_TMP_IV_QTY:',IFNULL(CONCAT(V_EXPD_TMP_IV_QTY),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;

    SET CURR_LOC_NUM = 1;
			SET V_BATCH_USER_EENO = 'BATCH';

			/*재고 테이블 재고 수량 조회	 */
			SELECT SUM(IV_QTY),	 
				   SUM(DL_EXPD_TMP_IV_QTY),	 
			   	   MAX(CMPL_YN),	 
				   MAX(TMP_TRTM_YN)	 
			INTO V_IV_QTY,	 
				 V_EXPD_TMP_IV_QTY,	 
			     V_CMPL_YN,	 
				 V_TMP_TRTM_YN	 
			FROM TB_SEWON_IV_INFO	 
			WHERE CLS_YMD = P_CLS_YMD	 
			AND QLTY_VEHL_CD = P_VEHL_CD	 
			AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			AND LANG_CD = P_LANG_CD	 
			AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                    WHEN P_PRDN_PLNT_CD='6' THEN '7'
												ELSE P_PRDN_PLNT_CD END;  /* 광주분리	 (원프로시져에는 decode가 없음)*/
	 

    SET CURR_LOC_NUM = 2;

			/*재고 테이블에 데이터가 존재하는 경우에 아래의 작업을 수행한다.	 */
			IF V_CMPL_YN IS NOT NULL THEN	 
			   /*재고상세 테이블내에 취급설명서연식으로 적용된 항목의 재고수량을 변경된 수량으로	 
			   --모두 업데이트 해 준다.	 
			   --단, 차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해준다.	 
			   --(왜냐하면 같은 않은 항목은 재고 상세 내역 재계산시에 우선 삭제된 뒤에 다시 계산하기 때문에 의미가 없다.)	 */
			   UPDATE TB_SEWON_IV_INFO_DTL	 
			   SET IV_QTY = V_IV_QTY,	 
			   	   /*안전재고의 수량을 재고수량과 같게 해준다.	 */
			   	   DL_EXPD_TMP_IV_QTY = V_EXPD_TMP_IV_QTY,	 
			   	   CMPL_YN = V_CMPL_YN,	 
				   UPDR_EENO = V_BATCH_USER_EENO,	 
				   MDFY_DTM = SYSDATE(),	 
				   TMP_TRTM_YN = V_TMP_TRTM_YN	 
			   WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   /*차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해 주도록 한다.	*/ 
			   AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                    WHEN P_PRDN_PLNT_CD='6' THEN '7'
												ELSE P_PRDN_PLNT_CD END;  /* 광주분리	 (원프로시져에는 decode가 없음)*/
	 


				SET V_EXCNT = 0;
				SELECT COUNT(CLS_YMD)	 
				  INTO V_EXCNT	 
				  FROM TB_SEWON_IV_INFO_DTL 
			   WHERE CLS_YMD = P_CLS_YMD	 
			   AND QLTY_VEHL_CD = P_VEHL_CD	 
			   /*차종의 연식과 취급설명서의 연식이 같은 경우에만 업데이트 해 주도록 한다.	*/ 
			   AND MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND LANG_CD = P_LANG_CD	 
			   AND DL_EXPD_MDL_MDY_CD = P_EXPD_MDL_MDY_CD	 
			   AND N_PRNT_PBCN_NO = P_N_PRNT_PBCN_NO	 
			   AND PRDN_PLNT_CD = CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                    WHEN P_PRDN_PLNT_CD='6' THEN '7'
												ELSE P_PRDN_PLNT_CD END;  /* 광주분리	 (원프로시져에는 decode가 없음)*/
				
    SET CURR_LOC_NUM = 3;

			   IF V_EXCNT = 0 THEN	 
				  INSERT INTO TB_SEWON_IV_INFO_DTL	 
				   (CLS_YMD,	 
				   	QLTY_VEHL_CD,	 
				   	MDL_MDY_CD,	 
				   	LANG_CD,	 
				   	DL_EXPD_MDL_MDY_CD,	 
				   	N_PRNT_PBCN_NO,	  
					PRDN_PLNT_CD, 
				   	IV_QTY,	 
				   	SFTY_IV_QTY,	 
					DL_EXPD_TMP_IV_QTY,	 
				   	CMPL_YN,	 
				   	PPRR_EENO,	 
				   	FRAM_DTM,	 
				   	UPDR_EENO,	 
				   	MDFY_DTM,	 
					TMP_TRTM_YN	
				   )	 
				   VALUES	 
				   (P_CLS_YMD,	 
				   	P_VEHL_CD,	 
					/*차종의 연식과 취급설명서의 연식을 같은 값으로 입력해 준다.(반드시 취급설명서의 연식으로 입력)	 */
				   	P_EXPD_MDL_MDY_CD,	 
				   	P_LANG_CD,	 
				   	P_EXPD_MDL_MDY_CD,	 
				   	P_N_PRNT_PBCN_NO, 
					CASE WHEN P_PRDN_PLNT_CD='7' THEN '7'
			                                    WHEN P_PRDN_PLNT_CD='6' THEN '7'
												ELSE P_PRDN_PLNT_CD END,  /* 광주분리	 (원프로시져에는 decode가 없음)*/
				   	V_IV_QTY,	 
					/*차종의 연식과 취급설명서의 연식이 같은 경우에는 안전재고의 수량을 재고수량과 같게 해준다.	 */
				   	V_IV_QTY,	 
					V_EXPD_TMP_IV_QTY,	 
				   	V_CMPL_YN,	 
				   	V_BATCH_USER_EENO,	 
				   	SYSDATE(),	 
				   	V_BATCH_USER_EENO,	 
				   	SYSDATE(),	 
					V_TMP_TRTM_YN	
				   );	 
			   END IF;	 
			END IF;	 


    SET CURR_LOC_NUM = 4;


	COMMIT;
	    

    SET CURR_LOC_NUM = 5;

END//
DELIMITER ;

-- 프로시저 hkomms.SP_USER_MGMT_BTCH 구조 내보내기
DELIMITER //
CREATE PROCEDURE `SP_USER_MGMT_BTCH`(IN P_EXPD_CO_CD VARCHAR(4))
BEGIN
/***************************************************************************
 * Procedure 명칭 : SP_USER_MGMT_BTCH
 * Procedure 설명 : 계정 휴면 처리 및 미사용 계정 삭제 처리
 * 입력 파라미터    :  P_EXPD_CO_CD                 회사코드
 * 리턴값         :  해당사항없음
 ****************************************************************************
 * 작업내용
 * 최초작성          2023-04-10     안상천   최초 전환함
 ****************************************************************************/
	DECLARE V_CNT      INT;
	DECLARE STRT_DATE  DATETIME;

	DECLARE ERR_CNT INT DEFAULT 0;
	DECLARE CURR_LOC_NUM INT DEFAULT 0;

	/*SQLEXCEPTION 오류 처리*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	     BEGIN
	        ROLLBACK;
	        SET ERR_CNT = 1;
			IF ERR_CNT > 0 THEN
				ROLLBACK;
				INSERT INTO TB_DEBUG_INFO (DEBUG_TITL,DEBUG_DATE) 
			           VALUES (
			          		CONCAT('SP_USER_MGMT_BTCH',':','실행종료위치:',CONCAT(CURR_LOC_NUM),' 오류발생'
							,',P_EXPD_CO_CD:',IFNULL(P_EXPD_CO_CD,'')
							,',STRT_DATE:',IFNULL(DATE_FORMAT(STRT_DATE, '%Y%m%d'),'')
							,',V_CNT:',IFNULL(CONCAT(V_CNT),''))
							,SYSDATE()
			          	);
				COMMIT;
			END IF;
	     END;


    SET CURR_LOC_NUM = 1;

    BEGIN
        SET V_CNT = 0;
        SET STRT_DATE  = SYSDATE();
        /*  90일 이상 미사용 휴면 계정 처리
           최종 로그인 기록이 90일 경과한 계정은 USE_YN = 'N' 처리
           17.9.15 (GRP계정 제외) */
        SELECT COUNT(*)
            INTO V_CNT
        FROM TB_USR_MGMT
        WHERE USE_YN = 'Y'
            AND DATEDIFF(SYSDATE(), FIN_LGI_DTM) >= 90
            AND USE_GBN <> 'G';


    SET CURR_LOC_NUM = 2;
		IF V_CNT > 0 THEN
	        UPDATE TB_USR_MGMT
	        SET
	            USE_YN = 'N',
	            UPDR_EENO = 'BATCH',
	            MDFY_DTM = SYSDATE()
	        WHERE USE_YN = 'Y'
	            AND DATEDIFF(SYSDATE(), FIN_LGI_DTM) >= 90
	            AND USE_GBN <> 'G';
		END IF;
        

    SET CURR_LOC_NUM = 3;

        COMMIT;
        

    SET CURR_LOC_NUM = 4;

        CALL WRITE_BATCH_LOG('휴면계정 처리', STRT_DATE, 'S', CONCAT('배치 ', V_CNT, ' 건 처리완료'));

    SET CURR_LOC_NUM = 5;

    END;

    BEGIN
        SET V_CNT = 0;
        SET STRT_DATE  = SYSDATE();
        /*  휴면계정 처리 90일 이상 지난 계정은 삭제 처리 */
        SELECT COUNT(*)
            INTO V_CNT
        FROM TB_USR_MGMT
        WHERE USE_YN = 'N'
            AND DATEDIFF(SYSDATE(), MDFY_DTM) >= 90
            AND USE_GBN <> 'G';
        

    SET CURR_LOC_NUM = 6;

		IF V_CNT > 0 THEN
	        DELETE FROM TB_USR_MGMT
	        WHERE USE_YN = 'N'
	            AND DATEDIFF(SYSDATE(), MDFY_DTM) >= 90
	            AND USE_GBN <> 'G';
		END IF;
        

    SET CURR_LOC_NUM = 7;

        COMMIT;
        

    SET CURR_LOC_NUM = 8;

        CALL WRITE_BATCH_LOG('미사용 계정 처리', STRT_DATE, 'S', CONCAT('배치 ', V_CNT, ' 건 처리완료'));

    SET CURR_LOC_NUM = 9;

    END;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
