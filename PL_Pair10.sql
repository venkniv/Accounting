
USE `H_Accounting`;
DROP PROCEDURE IF EXISTS `nivi_PL`;

DELIMITER $$
USE `H_Accounting`$$
CREATE PROCEDURE `nivi_PL` (varCalendarYear SMALLINT)

BEGIN
	-- -------------------------------------------------------------
	-- Defining variables for the current year 
    DECLARE Revenue 			DOUBLE DEFAULT 0;
    DECLARE COGS 				DOUBLE DEFAULT 0;
    DECLARE Gross_profit 		DOUBLE DEFAULT 0;
    DECLARE Other_Income		DOUBLE DEFAULT 0;
    DECLARE Other_Expenses		DOUBLE DEFAULT 0;
    DECLARE Selling_Expenses	DOUBLE DEFAULT 0;
    DECLARE Profit_bef_tax		DOUBLE DEFAULT 0;
    DECLARE IncomeTax			DOUBLE DEFAULT 0;
	DECLARE Net_Profit			DOUBLE DEFAULT 0;
    DECLARE `Returns` 			DOUBLE DEFAULT 0;
    DECLARE Admin_Expense		DOUBLE DEFAULT 0;
    DECLARE Other_Tax			DOUBLE DEFAULT 0;
    
    
    -- Defining variables for previous year
	DECLARE Revenue_p 				DOUBLE DEFAULT 0;
    DECLARE COGS_p 					DOUBLE DEFAULT 0;
    DECLARE Gross_profit_p 			DOUBLE DEFAULT 0;
    DECLARE Other_Income_p			DOUBLE DEFAULT 0;
    DECLARE Other_Expenses_p		DOUBLE DEFAULT 0;
    DECLARE Selling_Expenses_p		DOUBLE DEFAULT 0;
    DECLARE Profit_bef_tax_p		DOUBLE DEFAULT 0;
    DECLARE IncomeTax_p				DOUBLE DEFAULT 0;
	DECLARE Net_Profit_p			DOUBLE DEFAULT 0;
    DECLARE Returns_p				DOUBLE DEFAULT 0;
    DECLARE Admin_Expense_p			DOUBLE DEFAULT 0;
    DECLARE Other_Tax_p				DOUBLE DEFAULT 0;
   
   -- defining variables for year of year percentage change
	DECLARE rev_yoy 				DOUBLE DEFAULT 0;
    DECLARE cogs_yoy				DOUBLE DEFAULT 0;
    DECLARE gp_yoy					DOUBLE DEFAULT 0;
    DECLARE otherinc_yoy			DOUBLE DEFAULT 0;
    DECLARE otherexp_yoy			DOUBLE DEFAULT 0;
    DECLARE sellexp_yoy				DOUBLE DEFAULT 0;
    DECLARE pbt_yoy 				DOUBLE DEFAULT 0;
    DECLARE inctax_yoy				DOUBLE DEFAULT 0;	
    DECLARE netprofit_yoy			DOUBLE DEFAULT 0;
    DECLARE ret_yoy					DOUBLE DEFAULT 0;
    DECLARE gexp_yoy				DOUBLE DEFAULT 0;
    DECLARE othertax_yoy   			DOUBLE DEFAULT 0;
    
    -- declaring variables for financial ratio 
    DECLARE npm 					DOUBLE DEFAULT 0;
    DECLARE npm_p					DOUBLE DEFAULT 0;
    DECLARE npm_yoy					DOUBLE DEFAULT 0;
    -- ---------------------------------------------------------------------------------------
    -- Creating a view with the data that we need by using necessary inner joins -
    -- this is to enable us to query faster 
    
	DROP VIEW IF EXISTS `H_Accounting`.`nvenkatramanan_view`;
	CREATE VIEW `H_Accounting`.`nvenkatramanan_view` AS 

	SELECT `je`.`journal_entry_id`, `je`.`journal_entry`, `je`.`entry_date`, `je`.`cancelled`, 
	`jel`.`description`, `jel`.`debit`, `jel`.`credit`, `a`.`account`, `a`.`balance_sheet_section_id`,
	`a`.`profit_loss_section_id`, `ss`.`statement_section_code`, 
    `ss`.`statement_section`,`je`.`closing_type`
	FROM `journal_entry` AS `je`
	INNER JOIN `journal_entry_line_item` AS `jel` ON `je`.`journal_entry_id` = `jel`.`journal_entry_id`
	INNER JOIN `account` AS `a` ON `a`.`account_id` = `jel`.`account_id`
	INNER JOIN `statement_section` AS `ss` ON `ss`.`statement_section_id` = `a`.`profit_loss_section_id`
	WHERE `je`.`cancelled` <> 1
    ;

    -- Calculate the value and storing them into the declared variables 
    
    ########## REVENUE & REVENUE_p
    SELECT COALESCE(SUM(IFNULL(credit,0)),0) INTO Revenue 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'REV'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(credit,0)),0) INTO Revenue_p 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'REV'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ######### COGS & COGS_p
    SELECT COALESCE(SUM(IFNULL(debit,0)),0) INTO COGS 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'COGS'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(debit,0)),0) INTO COGS_p 
    FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'COGS'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ######## Returns & Returns_p
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Returns
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'RET'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Returns_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'RET'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ###### Gross_profit
    SELECT Revenue - `Returns` - COGS INTO Gross_profit
    ;
    
    SELECT Revenue_p - Returns_p - COGS_p INTO Gross_profit_p
    ;
    
    ########## Other_Income & # Other_Income_p
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO Other_Income 
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'OI'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(credit,0) - IFNULL(debit,0)),0) INTO Other_Income_p 
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'OI'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    
    ####### Other_Expenses & # Other_Expenses_p
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Other_Expenses
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'OEXP'
    AND closing_type = 0
    AND description NOT LIKE '%FY Closing%'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Other_Expenses_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'OEXP'
    AND closing_type = 0
    AND description NOT LIKE '%FY Closing%'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ######## Selling_Expenses & # Selling_Expenses_p
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Selling_Expenses
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'SEXP'
	AND closing_type = 0
    AND description NOT LIKE '%FY Closing%'
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Selling_Expenses_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'SEXP'
	AND closing_type = 0
    AND description NOT LIKE '%FY Closing%'
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ########### Admin expense & # Admin expense_p
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Admin_Expense
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'GEXP'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Admin_Expense_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'GEXP'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ######## Profit_bef_tax
    SELECT SUM(Gross_Profit + Other_Income - Other_Expenses - Selling_Expenses - Admin_Expense) INTO Profit_bef_tax
    ;
    
    # Profit_bef_tax_p
    SELECT SUM(Gross_Profit_p + Other_Income_p - Other_Expenses_p - Selling_Expenses_p - Admin_Expense_p) INTO Profit_bef_tax_p
    ;
    
    
    ############ IncomeTax
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO IncomeTax
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'INCTAX'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    # IncomeTax_p
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO IncomeTax_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'INCTAX'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    
    ######### Other tax
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Other_Tax
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'OTHTAX'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear
    ;
    
    # OTHER tax_p
    SELECT COALESCE(SUM(IFNULL(debit,0) - IFNULL(credit,0)),0) INTO Other_Tax_p
	FROM `H_Accounting`.`nvenkatramanan_view`
    WHERE statement_section_code = 'OTHTAX'
    AND closing_type = 0
    AND YEAR(entry_date) = varCalendarYear-1
    ;
    
    ####### Net_Profit
    SELECT Profit_bef_tax - IncomeTax - Other_Tax INTO Net_Profit
    ;
    
    # Net_Profit_p
    SELECT Profit_bef_tax_p - IncomeTax_p - Other_Tax_p INTO Net_Profit_p
    ;
    
    
    ##### rev_yoy
    SELECT IF(Revenue_p = 0, 0, ((Revenue - Revenue_p)/Revenue_p)*100) INTO rev_yoy
    ;
    
	#### ret_yoy
    SELECT IF(Returns_p = 0, 0, ((`Returns` - Returns_p)/Returns_p)*100) INTO ret_yoy
    ;
    
    ##### cogs_yoy
    SELECT IF(COGS_p = 0, 0, ((COGS - COGS_p)/COGS_p)*100) INTO cogs_yoy
    ;
    
    ##### gp_yoy
    SELECT IF(Gross_profit_p = 0, 0, ((Gross_profit - Gross_profit_p)/Gross_profit_p)*100) INTO gp_yoy
    ;
    
    #### otherinc_yoy
    SELECT IF(Other_Income_p = 0, 0, ((Other_Income - Other_Income_p)/Other_Income_p)*100) INTO otherinc_yoy
    ;
	
    ###### otherexp_yoy
    SELECT IF(Other_Expenses_p = 0, 0, ((Other_Expenses - Other_Expenses_p)/Other_Expenses_p)*100) INTO otherexp_yoy
    ;
    
    ##### sellexp_yoy
    SELECT IF(Selling_Expenses_p = 0, 0, ((Selling_Expenses - Selling_Expenses_p)/Selling_Expenses_p)*100) INTO sellexp_yoy
    ;
    
    ####### gexp_yoy
    SELECT IF(Admin_Expense_p = 0, 0, ((Admin_Expense - Admin_Expense_p)/Admin_Expense_p)*100) INTO gexp_yoy
    ;
    
    ##### pbt_yoy
    SELECT IF(Profit_bef_tax_p = 0, 0, ((Profit_bef_tax - Profit_bef_tax_p)/Profit_bef_tax_p)*100) INTO pbt_yoy
    ;
    
    
    ###### netprofit_yoy
    SELECT IF(Net_Profit_p = 0, 0, ((Net_Profit - Net_Profit_p)/Net_Profit_p)*100) INTO netprofit_yoy
    ;
    
    
    ###### npm - Net Profit Margin (Financial Ratio)
    SELECT IF(Revenue = 0, 0, (Net_Profit/Revenue)*100) INTO npm
    ;
    
    ##### npm_p - Net Profit Margin (Financial Ratio)
    SELECT IF(Revenue_p = 0, 0, (Net_Profit_p/Revenue_p)*100) INTO npm_p
    ;
    
    ##### npm_yoy
    SELECT IF(npm_p = 0, 0, ((npm - npm_p)/npm_p)*100) INTO npm_yoy
    ;
    
    DROP TABLE IF EXISTS H_Accounting.nvenkatramanan_tmp;
	-- Creating a temp table with the columns that we need for the output
	CREATE TABLE H_Accounting.nvenkatramanan_tmp
		(line_number INT, 
		 Description VARCHAR(50), 
	     Amount VARCHAR(50),
         Info1 VARCHAR(50),
         Info2 VARCHAR(50) 
         );
  
  -- Inserting a header for the report
  INSERT INTO H_Accounting.nvenkatramanan_tmp
		   (line_number, Description, Amount, Info1, Info2)
	VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD", 'Previous Year', 'YOY % Difference');
  
	-- Inserting sub heading a blank line before the actual report 
	INSERT INTO H_Accounting.nvenkatramanan_tmp
				(line_number, Description, Amount, Info1, Info2)
		VALUES 	(2, 'For the Year Ending', varCalendarYear, varCalendarYear-1, ''),
				(3, '', '','', '');
    

	-- Inserting the values into the table 

	INSERT INTO H_Accounting.nvenkatramanan_tmp
			(line_number, Description, Amount, Info1, Info2)
	VALUES 	(4, 'Total Revenue', format(Revenue / 1000, 2), format(Revenue_p / 1000, 2), CONCAT(format(rev_yoy,2),'%')),
			(5, 'Returns, Refunds, Discounts', format(Returns /1000 , 2), format(Returns_p / 1000, 2), CONCAT(format(ret_yoy,2),'%')),
			(6, 'Cost of Goods Sold', format(COGS /1000 , 2), format(COGS_p / 1000, 2), CONCAT(format(cogs_yoy,2),'%')),
            (7, 'Gross Profit', format(Gross_profit / 1000, 2), format(Gross_profit_p / 1000, 2), CONCAT(format(gp_yoy,2),'%')), 
            (8, '', '','',''),
            (9, 'Selling Expenses', format(Selling_Expenses / 1000, 2), format(Selling_Expenses_p / 1000, 2), CONCAT(format(sellexp_yoy,2),'%')),
            (10, 'Other Expenses', format(Other_Expenses / 1000, 2), format(Other_Expenses_p / 1000, 2), CONCAT(format(otherexp_yoy,2),'%')),
            (11, 'Admin Expenses', format(Admin_Expense / 1000, 2), format(Admin_Expense_p / 1000, 2), CONCAT(format(gexp_yoy,2),'%')),
            (12, '', '','',''),
            (13, 'Other Income', format(Other_Income / 1000, 2),format(Other_Income_p / 1000, 2), CONCAT(format(otherinc_yoy,2),'%')),
            (14, 'Profit before Tax', format(Profit_bef_tax / 1000, 2),format(Profit_bef_tax_p / 1000, 2), CONCAT(format(pbt_yoy,2),'%')), 
            (15, 'Income Tax', format(IncomeTax / 1000, 2),'', ''),
            (16, 'Other Tax', format(Other_Tax / 1000, 2),'', ''),
            (17, '', '','',''),
            (18, 'NET PROFIT', format(Net_Profit / 1000, 2),format(Net_Profit_p / 1000, 2), IF(Net_Profit_p < 0, 'N.A.', CONCAT(format(netprofit_yoy, 2),'%'))),
            (19, '','','',''),
            (20, 'Financial Ratios', '----','----','----'),
            (21, 'Net Profit Margin', CONCAT(format(npm,2),'%'), CONCAT(format(npm_p,2),'%'),'')
            ;
            
	-- For NetProfit % change, we have used a IF condition : 
    -- Since Net Profit of a previous year can be negative, it can cause miscalculation, hence to avoid that we have 
    -- used a condition that will output as NA if previous year Net profit is negative. 
    
    -- Select command from the table to get the output
    SELECT * FROM nvenkatramanan_tmp;
END $$
DELIMITER ;
