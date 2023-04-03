
USE `H_Accounting`;
DROP PROCEDURE IF EXISTS `nivi_BS`;

DELIMITER $$
USE `H_Accounting`$$
CREATE PROCEDURE `nivi_BS` (varCalendarYear YEAR)

BEGIN

-- Define variables inside procedure for current year
    DECLARE FA 					DOUBLE DEFAULT 0;
    DECLARE CA 					DOUBLE DEFAULT 0;
    DECLARE CL 					DOUBLE DEFAULT 0;
    DECLARE EQ					DOUBLE DEFAULT 0;
    DECLARE TA					DOUBLE DEFAULT 0;
    DECLARE TL					DOUBLE DEFAULT 0;
    DECLARE CR					DOUBLE DEFAULT 0;
    DECLARE DA					DOUBLE DEFAULT 0;
    DECLARE LLL					DOUBLE DEFAULT 0;
    DECLARE DL					DOUBLE DEFAULT 0;
    
    
-- Variables for previous year
	DECLARE FA_p 				DOUBLE DEFAULT 0;
    DECLARE CA_p  				DOUBLE DEFAULT 0;
    DECLARE CL_p  				DOUBLE DEFAULT 0;
    DECLARE EQ_p 				DOUBLE DEFAULT 0;
    DECLARE TA_p 				DOUBLE DEFAULT 0;
    DECLARE TL_p 				DOUBLE DEFAULT 0;
    DECLARE CR_p				DOUBLE DEFAULT 0;
    DECLARE DA_p				DOUBLE DEFAULT 0;
    DECLARE LLL_p				DOUBLE DEFAULT 0;
    DECLARE DL_p				DOUBLE DEFAULT 0;
    
-- Variables for YOY change
	DECLARE FA_yoy 				DOUBLE DEFAULT 0;
    DECLARE CA_yoy  			DOUBLE DEFAULT 0;
    DECLARE CL_yoy  			DOUBLE DEFAULT 0;
    DECLARE EQ_yoy 				DOUBLE DEFAULT 0;
    DECLARE TA_yoy 				DOUBLE DEFAULT 0;
    DECLARE TL_yoy				DOUBLE DEFAULT 0;
    DECLARE CR_yoy				DOUBLE DEFAULT 0;
    DECLARE DA_yoy				DOUBLE DEFAULT 0;
    DECLARE LLL_yoy				DOUBLE DEFAULT 0;
    DECLARE DL_yoy				DOUBLE DEFAULT 0;

    -- Creating a view for faster querying and avoiding repeating the same lines over and over again
    DROP VIEW IF EXISTS `H_Accounting`.`nvenkatramanan_view`;
	CREATE VIEW `H_Accounting`.`nvenkatramanan_view` AS 

	SELECT `je`.`journal_entry_id`, `je`.`journal_entry`, `je`.`entry_date`, `je`.`cancelled`, 
	`jel`.`description`, `jel`.`debit`, `jel`.`credit`, `a`.`account`, `a`.`balance_sheet_section_id`,
	`a`.`profit_loss_section_id`, `ss`.`statement_section_code`, `ss`.`statement_section`, `je`.`closing_type`
	FROM `journal_entry` AS `je`
	INNER JOIN `journal_entry_line_item` AS `jel` ON `je`.`journal_entry_id` = `jel`.`journal_entry_id`
	INNER JOIN `account` AS `a` ON `a`.`account_id` = `jel`.`account_id`
	INNER JOIN `statement_section` AS `ss` ON `ss`.`statement_section_id` = `a`.`balance_sheet_section_id`
	WHERE je.cancelled <> 1
    ;
    
    -- Calculate the value and store them into the variables declared, calculation both current and previous year (_p)
    
    ##### FA
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO FA 
    FROM `H_Accounting`.`nvenkatramanan_view`
    
    WHERE statement_section_code = 'FA'
    AND YEAR(entry_date) <= varCalendarYear
    ;
    
    #FA Previous
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO FA_p
    FROM `H_Accounting`.`nvenkatramanan_view`
    
    WHERE statement_section_code = 'FA'
    AND YEAR(entry_date) <= varCalendarYear-1
    ;
    
    # CA
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO CA 
    FROM `H_Accounting`.`nvenkatramanan_view`
    
    WHERE statement_section_code = 'CA'
    AND YEAR(entry_date) <= varCalendarYear;
    
    # CA Previous
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO CA_p
    FROM `H_Accounting`.`nvenkatramanan_view`
    
    WHERE statement_section_code = 'CA'
    AND YEAR(entry_date) <= varCalendarYear-1;
    
    # Deferred Assets
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO DA 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'DA'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    # Deferred Assets P
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO DA_p 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'DA'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    
    # CL
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO CL 
	FROM `H_Accounting`.`nvenkatramanan_view`
    
    WHERE statement_section_code = 'CL'
    AND YEAR(entry_date) <= varCalendarYear
    ;
    
    # CL Previous
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO CL_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    
    WHERE statement_section_code = 'CL'
    AND YEAR(entry_date) <= varCalendarYear-1
    ;
    
     # Long term liabilities
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO LLL 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'LLL'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    # Long Term Liabilitiess P
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO LLL_p 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'LLL'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    # Deferred liabilities
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO DL 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'DL'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    # Deferred Liabilities P
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO DL_p 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'DL'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
   # EQ
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO EQ 
	FROM `H_Accounting`.`nvenkatramanan_view`

    WHERE statement_section_code = 'EQ'
    AND YEAR(entry_date) <= varCalendarYear
    ;
    
    # EQ Previous
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO EQ_p
	FROM `H_Accounting`.`nvenkatramanan_view`

    WHERE statement_section_code = 'EQ'
    AND YEAR(entry_date) <= varCalendarYear-1
    ;
    
    #TA
    SELECT FA + CA + DA INTO TA
    ;
    
    #TA Previous
    SELECT FA_p + CA_p + DA_p INTO TA_p
    ;
    
    #TL
    SELECT CL + EQ + DL + LLL INTO TL
    ;
    
    #TL Previous
    SELECT CL_p + EQ_p + DL_p + LLL_p INTO TL_p
    ;
    
-- Calculating YOY growth for all variables

    #fa_yoy
    SELECT IF(FA_p = 0, 0, ((FA - FA_p)/FA_p)*100) INTO FA_yoy
    ;
    
    #ca_yoy
    SELECT IF(CA_p = 0, 0, ((CA - CA_p)/CA_p)*100) INTO CA_yoy
    ;
    
    #cl_yoy
    SELECT IF(CL_p = 0, 0, ((CL - CL_p)/CL_p)*100) INTO CL_yoy
    ;
    
    #EQ_yoy
    SELECT IF(EQ_p = 0, 0, ((EQ - EQ_p)/EQ_p)*100) INTO EQ_yoy
    ;
    
    #TA_yoy
    SELECT IF(TA_p = 0, 0,((TA - TA_p)/TA_p)*100) INTO TA_yoy
    ;
    
    #TL_yoy
    SELECT IF(TL_p = 0, 0,((TL - TL_p)/TL_p)*100) INTO TL_yoy
    ;
    
    #DA_yoy
    SELECT IF(DA_p = 0, 0, ((DA - DA_p)/DA_p)*100) INTO DA_yoy
    ;
    
    #LLL_yoy
    SELECT IF(LLL_p = 0, 0, ((LLL - LLL_p)/LLL_p)*100) INTO LLL_yoy
    ;
    
    #DL_yoy
    SELECT IF(DL_p = 0, 0, ((DL - DL_p)/DL_p)*100) INTO DL_yoy
    ;
    
    ### Adding a financial ratio
    -- Current ratio
    
    SELECT IF(CL = 0, 0, (CA/CL)) INTO CR;
    
    SELECT IF(CL_p = 0, 0, (CA_p/CL_p)) INTO CR_p;
    
    SELECT IF(CR_p = 0, 0, ((CR - CR_p)/CR_p)*100) INTO CR_yoy;
    
    
    DROP TABLE IF EXISTS H_Accounting.nvenkatramanan_tmp;
  
	-- Creating colums for the new table
	CREATE TABLE H_Accounting.nvenkatramanan_tmp
		(line_number INT, 
		 Description VARCHAR(50), 
	     Amount VARCHAR(50),
         Previous_Year VARCHAR(50),
         YOY_Change VARCHAR(50)
		);
        
  
  -- Now we insert the a header for the report
  INSERT INTO H_Accounting.nvenkatramanan_tmp
		   (line_number, Description, Amount, Previous_Year, YOY_Change)
	VALUES (1, 'BALANCE SHEET', "In '000s of USD","Previous Year", "YOY Change");
  
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.nvenkatramanan_tmp
				(line_number, Description, Amount, Previous_Year, YOY_Change)
		VALUES 	(2, 'For the Year Ending', varCalendarYear, varCalendarYear-1 , " - "),
				(3, '', '',"", "");
    
	INSERT INTO H_Accounting.nvenkatramanan_tmp
			(line_number, Description, Amount, Previous_Year, YOY_Change)
	VALUES 	(4, 'Fixed Assets', format(FA / 1000, 2), format(FA_p/ 1000, 2), FA_yoy),
			(5, 'Current Assets', format(CA /1000 , 2),format(CA_p/ 1000, 2), CONCAT(format(CA_yoy, 2),'%')),
            (6, 'Deferred Assets', format(DA /1000 , 2),format(DA_p/ 1000, 2), DA_yoy),
            (7, 'TOTAL ASSETS', format(TA / 1000, 2), format(TA_p/ 1000, 2), CONCAT(format(TA_yoy, 2),'%')), 
            (8, '', '' , "", ""),
            (9, 'Current Liabilities', format(CL / 1000, 2),format(CL_p/ 1000, 2), CONCAT(format(CL_yoy, 2),'%')),
            (10, 'Long Term Liabilities', format(LLL / 1000, 2),format(LLL_p/ 1000, 2), LLL_yoy),
            (11, 'Deferred Liabilities', format(DL / 1000, 2),format(DL_p/ 1000, 2), DL_yoy),
            (12, 'Equity', format(EQ / 1000, 2),format(EQ_p/ 1000, 2), CONCAT(format(EQ_yoy, 2),'%')),
            (13, 'TOTAL LIABILITIES', format(TL / 1000, 2),format(TL_p/ 1000, 2), CONCAT(format(TL_yoy, 2),'%')),
            (14, '', '' , "", ""),
            (15, 'Financial Ratios', "-----" , "-----", "----"),
            (16, 'Current Ratio', format(CR, 2), format(CR_p, 2), CONCAT(format(CR_yoy, 2),'%'))
            
            ;
    
    SELECT * FROM nvenkatramanan_tmp;
    
END$$
DELIMITER ;

